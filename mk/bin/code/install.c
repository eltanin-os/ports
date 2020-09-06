#include <tertium/cpu.h>
#include <tertium/std.h>

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

static void
sysmove(char *p)
{
	static ctype_arr arr;
	char *d;

	c_arr_trunc(&arr, 0, sizeof(uchar));
	if (c_dyn_fmt(&arr, "%s/%s", rootdir, p) < 0)
		c_err_die(1, "c_dyn_fmt");
	d = c_arr_data(&arr);
	if (mkpath(d, 0755) < 0)
		c_err_die(1, "mkpath %s", d);
	if (c_sys_rename(p, d) < 0)
		c_err_die(1, "c_sys_rename %s %s", p, d);
}

static void
usage(void)
{
	c_ioq_fmt(ioq2, "usage: %s [-n]\n", c_std_getprogname());
	c_std_exit(1);
}

ctype_status
main(int argc, char **argv)
{
	ctype_stat st;
	ctype_arr arr;
	usize len;
	ctype_status r;
	int nflag;
	char *dest;

	c_std_setprogname(argv[0]);
	--argc, ++argv;

	nflag = 0;

	while (c_std_getopt(argmain, argc, argv, "n")) {
		switch (argmain->opt) {
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
	if (nflag) {
		len = 0;
		c_mem_set(&arr, sizeof(arr), 0);
		while ((r = c_ioq_getln(ioq0, &arr)) > 0) {
			dest = c_arr_data(&arr);
			dest[c_arr_bytes(&arr) - 1] = 0;
			if (c_sys_lstat(&st, dest) < 0)
				c_err_die(1, "c_sys_lstat %s", dest);
			len += st.blocks;
			c_arr_trunc(&arr, 0, sizeof(uchar));
		}
		c_ioq_fmt(ioq1, "%lluo\n", (uvlong)C_HOWMANY(len, 2));
		c_ioq_flush(ioq1);
		return 0;
	}

	if (!(rootdir = c_std_getenv("SYSPATH")))
		c_err_diex(1, "missing PREFIX environmental variable");

	c_mem_set(&arr, sizeof(arr), 0);
	while ((r = c_ioq_getln(ioq0, &arr)) > 0) {
		dest = c_arr_data(&arr);
		dest[c_arr_bytes(&arr) - 1] = 0;
		sysmove(dest);
		c_arr_trunc(&arr, 0, sizeof(uchar));
	}
	return 0;
}
