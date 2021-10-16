#include <tertium/cpu.h>
#include <tertium/std.h>

#define INITAV4(a, b, c, d, e) \
{ (a)[0] = (b); (a)[1] = (c); (a)[2] = (d); (a)[3] = (e); (a)[4] = nil; }

static int cflag;
static char *rootdir;

static ctype_status
copy(char *d, char *s)
{
	ctype_status r;

	if ((r = c_nix_link(d, s)) < 0 &&
	    errno == C_EEXIST) {
		c_nix_unlink(d);
		r = c_nix_link(d, s);
	}
	return r;
}

static void
sysmove(char *p)
{
	static ctype_arr arr; /* "memory leak" */
	ctype_id id;
	ctype_status r;
	char *argv[5];
	char *d;

	c_arr_trunc(&arr, 0, sizeof(uchar));
	if (c_dyn_fmt(&arr, "%s/%s", rootdir, p) < 0)
		c_err_die(1, "c_dyn_fmt");

	d = c_arr_data(&arr);
	if (c_nix_mkpath(c_gen_dirname(d), 0755, 0755) < 0)
		c_err_die(1, "c_nix_mkpath %s", d);

	c_arr_trunc(&arr, 0, sizeof(uchar));
	c_arr_fmt(&arr, "%s/%s", rootdir, p);

	r = cflag ? copy(d, p) : c_nix_rename(d, p);
	if (r < 0) {
		if (errno != C_EXDEV)
			c_err_die(1, "sysmove %s <- %s", d, p);
		INITAV4(argv, "cp", "-Pp", p, d);
		if (!(id = c_exc_spawn0(*argv, argv, environ)))
			c_err_die(1, "c_exc_spawn0 %s", *argv);
		c_nix_waitpid(id, nil, 0);
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
			if (c_nix_lstat(&st, dest) < 0)
				c_err_die(1, "c_nix_lstat %s", dest);
			len += st.size;
			c_arr_trunc(&arr, 0, sizeof(uchar));
		}
		c_dyn_free(&arr);

		if (r < 0)
			c_std_exit(-1);

		c_ioq_fmt(ioq1, "%llud\n", (uvlong)C_HOWMANY(len, 1024/512));
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
	c_dyn_free(&arr);
	return r;
}
