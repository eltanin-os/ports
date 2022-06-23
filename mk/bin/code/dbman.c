#include <tertium/cpu.h>
#include <tertium/std.h>

#define fmtstr(...) fmtstr_(__VA_ARGS__, nil)

static char *ports;
static ctype_cdb cdb;

static char *
fmtstr_(char *fmt, ...)
{
	static ctype_arr arr;
	va_list ap;
	va_start(ap, fmt);
	c_arr_trunc(&arr, 0, sizeof(uchar));
	if (c_dyn_vfmt(&arr, fmt, ap) < 0) c_err_die(1, "c_dyn_vfmt");
	va_end(ap);
	return c_arr_data(&arr);
}

static char *
getpath(char *s)
{
	static ctype_arr arr;
	usize len, pos;

	if (c_cdb_find(&cdb, s, c_str_len(s, -1)) <= 0) return nil;
	len = c_cdb_datalen(&cdb);
	c_arr_trunc(&arr, 0, sizeof(uchar));
	if (c_dyn_ready(&arr, len + 1, sizeof(uchar)) < 0)
		c_err_die(1, "c_dyn_ready");
	s = c_arr_data(&arr);
	pos = c_cdb_datapos(&cdb);
	if (c_cdb_read(&cdb, s, len, pos) < 0)
		c_err_die(1, "c_cdb_read %d %d", len, pos);
	s[len] = 0;
	return s;
}

static void
gencache(char *root, char *path)
{
	ctype_arr arr;
	ctype_dir dir;
	ctype_dent *ep;
	ctype_cdbmk cdbmk;
	ctype_fd fd;
	char *argv[2], *tmp;

	c_mem_set(&arr, sizeof(arr), 0);
	if (c_dyn_fmt(&arr, "%s/PORTS@XXXXXXXXX", root) < 0)
		c_err_die(1, "c_dyn_fmt");
	tmp = c_arr_data(&arr);
	if ((fd = c_nix_mktemp(tmp, c_arr_bytes(&arr))) < 0)
		c_err_die(1, "c_nix_mktemp %s", tmp);

	if (c_cdb_mkstart(&cdbmk, fd) < 0) c_err_die(1, "c_cdb_init");
	argv[0] = ports;
	argv[1] = nil;
	if (c_dir_open(&dir, argv, C_DIR_FSLOG, nil) < 0)
		c_err_die(1, "c_dir_open");
	while ((ep = c_dir_read(&dir))) {
		switch (ep->info) {
		case C_DIR_FSD:
			if (ep->name[0] == '.' && ep->name[1]) {
				c_dir_set(&dir, ep, C_DIR_FSSKP);
				continue;
			}
			break;
		case C_DIR_FSDP:
			if (ep->num)
				if (c_cdb_mkadd(&cdbmk, ep->name, ep->nlen,
				    ep->path, ep->len) < 0)
					c_err_die(1, "c_cdb_mkadd");
			break;
		case C_DIR_FSF:
			if (!C_STR_SCMP("build", ep->name) ||
			    !C_STR_SCMP("vars", ep->name))
				++ep->parent->num; /* tag the parent */
			break;
		case C_DIR_FSDNR:
		case C_DIR_FSNS:
		case C_DIR_FSERR:
			c_err_warnx("%s: %r", ep->path, ep->err);
			/* FALLTHROUGH */
		default:
			continue;
		}
	}
	c_dir_close(&dir);
	if (c_cdb_mkfinish(&cdbmk) < 0) c_err_die(1, "c_cdb_mkfinish");
	c_nix_fdclose(fd);

	if (c_nix_rename(path, tmp) < 0)
		c_err_die(1, "c_nix_rename %s <- %s", path, tmp);
	c_dyn_free(&arr);
}

static void
usage(void)
{
	c_ioq_fmt(ioq2,
	    "usage: %s [-u] pkg\n"
	    "       %s -u\n",
	    c_std_getprogname(), c_std_getprogname());
	c_std_exit(1);
}

ctype_status
main(int argc, char **argv)
{
	ctype_fd fd;
	int uflag;
	char *s;

	c_std_setprogname(argv[0]);
	--argc, ++argv;

	uflag = 0;

	while (c_std_getopt(argmain, argc, argv, "u")) {
		switch (argmain->opt) {
		case 'u':
			uflag = 1;
			break;
		default:
			usage();
		}
	}
	argc -= argmain->idx;
	argv += argmain->idx;

	if (!(ports = c_std_getenv("PORTS")))
		c_err_diex(1, "missing PORTS environmental variable");
	if (!(ports = c_str_dup(fmtstr("%s/pkg", ports), -1)))
		c_err_die(1, "c_str_dup");

	s = fmtstr("%s/cache.cdb", ports);
	if (uflag) {
		gencache(ports, s);
		/* free ports */
		if (!argc) return 0;
	}
	/* free ports */
	if (!argc) usage();

	if ((fd = c_nix_fdopen2(s, C_NIX_OREAD)) < 0)
		c_err_die(1, "c_nix_fdopen2 %s", s);
	c_cdb_init(&cdb, fd);
	if (!(s = getpath(*argv)))
		c_err_diex(1, "%s: package not found", *argv);
	c_ioq_fmt(ioq1, "%s\n", s);
	c_ioq_flush(ioq1);
	return 0;
}
