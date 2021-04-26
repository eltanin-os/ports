#include <tertium/cpu.h>
#include <tertium/std.h>

#define INITAV4(a, b, c, d, e) \
{ (a)[0] = (b); (a)[1] = (c); (a)[2] = (d); (a)[3] = (e); }

static int cflag;
static char *rootdir;

static ctype_status
makedir(char *s, uint mode)
{
	ctype_stat st;

	if (c_sys_mkdir(s, mode) < 0) {
		if (errno == C_EEXIST) {
			if ((c_sys_stat(&st, s) < 0) || !C_ISDIR(st.mode)) {
				errno = C_ENOTDIR;
				return -1;
			}
		} else {
			return -1;
		}
	}
	return 0;
}

static ctype_status
mkpath(char *dir, uint mode)
{
	char *s;

	s = dir;
	if (*s == '/')
		++s;

	for (;;) {
		if (!(s = c_str_chr(s, C_USIZEMAX, '/')))
			break;
		*s = 0;
		if (makedir(dir, mode) < 0)
			return c_err_warn("makedir %s", dir);
		*s++ = '/';
	}
	return 0;
}

static ctype_status
copy(char *s, char *d)
{
	ctype_status r;

	if ((r = c_sys_link(s, d)) < 0 &&
	    errno == C_EEXIST) {
		c_sys_unlink(d);
		r = c_sys_link(s, d);
	}
	return r;
}

static void
sysmove(char *p)
{
	static ctype_arr arr;
	ctype_id id;
	ctype_status r;
	char *argv[4];
	char *d;

	c_arr_trunc(&arr, 0, sizeof(uchar));
	if (c_dyn_fmt(&arr, "%s/%s", rootdir, p) < 0)
		c_err_die(1, "c_dyn_fmt");
	d = c_arr_data(&arr);
	if (mkpath(d, 0755) < 0)
		c_err_die(1, "mkpath %s", d);

	r = cflag ? copy(p, d) : c_sys_rename(p, d);
	if (r < 0) {
		if (errno != C_EXDEV)
			c_err_die(1, "sysmove %s %s", p, d);
		INITAV4(argv, "cp", "-p", p, d);
		if (!(id = c_exc_spawn0(*argv, argv, environ)))
			c_err_die(1, "c_exc_spawn0 %s", *argv);
		c_sys_waitpid(id, nil, 0);
	}
}

static void
usage(void)
{
	c_ioq_fmt(ioq2, "usage: %s [-cn]\n", c_std_getprogname());
	c_std_exit(1);
}

ctype_status
main(int argc, char **argv)
{
	ctype_stat st;
	ctype_ioq *file;
	ctype_arr arr;
	usize len;
	ctype_status r;
	int nflag;
	char *dest;

	c_std_setprogname(argv[0]);
	--argc, ++argv;

	cflag = 0;
	nflag = 0;

	while (c_std_getopt(argmain, argc, argv, "cn")) {
		switch (argmain->opt) {
		case 'c':
			cflag = 1;
			break;
		case 'n':
			nflag = 1;
			break;

		default:
			usage();
		}
	}
	argc -= argmain->idx;
	argv += argmain->idx;

	if (argc)
		usage();

	file = ioq0;

	if (nflag) {
		len = 0;
		c_mem_set(&arr, sizeof(arr), 0);
		while ((r = c_ioq_getln(file, &arr)) > 0) {
			dest = c_arr_data(&arr);
			dest[c_arr_bytes(&arr) - 1] = 0;
			if (c_sys_lstat(&st, dest) < 0)
				c_err_die(1, "c_sys_lstat %s", dest);
			len += st.blocks;
			c_arr_trunc(&arr, 0, sizeof(uchar));
		}
		/* free arr */

		if (r < 0)
			c_std_exit(-1);

		c_ioq_fmt(ioq1, "%lluo\n", (uvlong)C_HOWMANY(len, 2));
		c_std_exit(0);
	}

	if (!(rootdir = c_std_getenv("SYSPATH")))
		c_err_diex(1, "missing SYSPATH environmental variable");

	c_mem_set(&arr, sizeof(arr), 0);
	while ((r = c_ioq_getln(file, &arr)) > 0) {
		dest = c_arr_data(&arr);
		dest[c_arr_bytes(&arr) - 1] = 0;
		sysmove(dest);
		c_arr_trunc(&arr, 0, sizeof(uchar));
	}
	/* free arr */
	return r;
}
