#include <tertium/cpu.h>
#include <tertium/std.h>

enum {
	/* packages types */
	DEF,
	DEF_MAN,
	DEV,
	DEV_MAN,
	DYNLIB,
	ALL,

	/* directories */
	DEFDIR,
	DEVDIR,
	MANDIR,
};

#define WMODE (C_OCREATE | C_OWRITE | C_OCEXEC)
#define fmtstr(...) fmtstr_(__VA_ARGS__, nil)
#define CMP(a, b) c_mem_cmp((a), sizeof((a)), (b))
#define SCMP(a, b) c_mem_cmp((a), sizeof((a)) - 1, (b))
#define DCMP(a, b, c) ((!c[(b)] || c[(b)] == '/') && !c_mem_cmp((a), (b), (c)))

struct file {
	char buf[C_BIOSIZ];
	ctype_ioq ioq;
	ctype_fd fd;
};

static char *drtdir, *incdir, *libdir, *mandir;
static usize drtlen, inclen, liblen, manlen;

static char *strtab[] = {
	"INSTALL@DEF",
	"INSTALL@MAN",
	"INSTALL@DEV",
	"INSTALL@DEVMAN",
	"INSTALL@DYNLIB",
};

static char *
estrdup(char *s)
{
	if (!(s = c_str_dup(s, -1)))
		c_err_die(1, "c_str_dup");
	return s;
}

static char *
fmtstr_(char *fmt, ...)
{
	static ctype_arr arr;
	va_list ap;

	va_start(ap, fmt);
	c_arr_trunc(&arr, 0, sizeof(uchar));
	if (c_dyn_vfmt(&arr, fmt, ap) < 0)
		c_err_die(1, "c_dyn_vfmt");
	va_end(ap);
	return c_arr_data(&arr);
}

static int
getdirnum(char *s)
{
	if (DCMP(mandir, manlen, s)) {
		return MANDIR;
	} else if (DCMP(libdir, liblen, s)) {
		return DEVDIR;
	} else if (DCMP(incdir, inclen, s)) {
		return DEVDIR;
	} else {
		if (!c_mem_cmp(drtdir, drtlen, s)) {
			if (!CMP("/aclocal", s + drtlen) ||
			    !CMP("/xcb", s + drtlen) ||
			    !CMP("/pkgconfig", s + drtlen))
				return DEVDIR;
			else if (!CMP("/doc", s + drtlen))
				return MANDIR;
			else
				return DEFDIR;
		} else {
			return DEFDIR;
		}
	}
}

static void
usage(void)
{
	c_ioq_fmt(ioq2, "usage: %s\n", c_std_getprogname());
	c_std_exit(1);
}

ctype_status
main(int argc, char **argv)
{
	struct file *fp;
	ctype_dir dir;
	ctype_dent *p;
	ctype_fd fd;
	ctype_status r;
	int num;
	char *curdir[2];

	c_std_setprogname(argv[0]);
	--argc, ++argv;

	while (c_std_getopt(argmain, argc, argv, "")) {
		switch (argmain->opt) {
		default:
			usage();
		}
	}
	argc -= argmain->idx;
	argv += argmain->idx;

	if (argc)
		usage();

	if (!(drtdir = c_std_getenv("DRTDIR")))
		c_err_diex(1, "missing DRTDIR environmental variable");
	drtdir = estrdup(fmtstr(".%s", drtdir));
	drtlen = c_str_len(drtdir, -1);
	if (!(incdir = c_std_getenv("INCDIR")))
		c_err_diex(1, "missing INCDIR environmental variable");
	incdir = estrdup(fmtstr(".%s", incdir));
	inclen = c_str_len(incdir, -1);
	if (!(libdir = c_std_getenv("LIBDIR")))
		c_err_diex(1, "missing LIBDIR environmental variable");
	libdir = estrdup(fmtstr(".%s", libdir));
	liblen = c_str_len(libdir, -1);
	if (!(mandir = c_std_getenv("MANDIR")))
		c_err_diex(1, "missing MANDIR environmental variable");
	mandir = estrdup(fmtstr(".%s", mandir));
	manlen = c_str_len(mandir, -1);

	if (!(fp = c_std_alloc(ALL, sizeof(*fp))))
		c_err_die(1, "c_std_alloc");

	for (num = 0; num < ALL; ++num) {
		if ((fd = c_sys_open(strtab[num], WMODE, 0666)) < 0)
			c_err_die(1, "c_sys_open %s", strtab[num]);
		c_ioq_init(&fp[num].ioq, fd, fp[num].buf,
		    sizeof(fp[num].buf), c_sys_write);
	}

	curdir[0] = ".";
	curdir[1] = nil;
	if (c_dir_open(&dir, curdir, 0, nil) < 0)
		c_err_die(1, "c_dir_open");
	r = 0;
	while ((p = c_dir_read(&dir))) {
		switch (p->info) {
		case C_FSD:
			switch (p->depth) {
			case 0:
				p->num = DEFDIR;
				break;
			case 1:
			case 2:
				p->num = getdirnum(p->path);
				break;
			default:
				p->num = p->parent->num;
			}
			break;
		case C_FSDP:
			break;
		case C_FSDNR:
		case C_FSNS:
		case C_FSERR:
			r = c_err_warnx("%s: %r", p->path, p->err);
			break;
		default:
			if (!SCMP("INSTALL@", p->name))
				continue;
			switch (p->parent->num) {
			case DEFDIR:
				c_ioq_fmt(&fp[DEF].ioq, "%s\n", p->path);
				break;
			case DEVDIR:
				if (c_str_str(p->name, p->nlen, ".so"))
					num = DYNLIB;
				else
					num = DEV;
				c_ioq_fmt(&fp[num].ioq, "%s\n", p->path);
				break;
			case MANDIR:
				if (!SCMP(".", p->name + p->nlen - 2)) {
					switch (*(p->name + p->nlen - 1)) {
					case '2':
					case '3':
						num = DEV_MAN;
						break;
					default:
						num = DEF_MAN;
					}
				} else {
					num = DEF_MAN;
				}
				c_ioq_fmt(&fp[num].ioq, "%s\n", p->path);
				break;
			}
			break;
		}
	}
	c_dir_close(&dir);

	for (num = 0; num < ALL; ++num)
		c_ioq_flush(&fp[num].ioq);

	return r;
}
