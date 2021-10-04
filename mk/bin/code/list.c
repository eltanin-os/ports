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
#define CMP(a, b) c_mem_cmp((a), sizeof((a)) - 1, (b))

struct file {
	char buf[C_BIOSIZ];
	ctype_ioq ioq;
	ctype_fd fd;
};

static char *cdir[] = { ".", nil };
static char *drtdir, *incdir, *libdir, *mandir;
static usize prefixlen, drtlen, inclen, liblen, manlen;

static char *strtab[] = {
	"INSTALL@DEF",
	"INSTALL@MAN",
	"INSTALL@DEV",
	"INSTALL@DEVMAN",
	"INSTALL@DYNLIB",
};

static int
getdirnum(char *s)
{
	for (; *s == '/' || *s == '.'; ++s) ;
	if (!c_mem_cmp(mandir, manlen, s)) {
		return MANDIR;
	} else if (!c_mem_cmp(libdir, liblen, s)) {
		return DEVDIR;
	} else if (!c_mem_cmp(incdir, inclen, s)) {
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
getenv(char **sp, usize *len, char *env)
{
	char *tmp;

	if (!(tmp = c_std_getenv(env)))
		c_err_diex(1, "missing %s environmental variable", env);
	++tmp;
	*len = c_str_len(tmp, -1);
	*sp = tmp;
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

	getenv(&drtdir, &drtlen, "DRTDIR");
	getenv(&incdir, &inclen, "INCDIR");
	getenv(&libdir, &liblen, "LIBDIR");
	getenv(&mandir, &manlen, "MANDIR");

	if (!(fp = c_std_alloc(ALL, sizeof(*fp))))
		c_err_die(1, "c_std_alloc");

	for (num = 0; num < ALL; ++num) {
		if ((fd = c_nix_fdopen3(strtab[num], WMODE, 0666)) < 0)
			c_err_die(1, "c_nix_fdopen3 %s", strtab[num]);
		c_ioq_init(&fp[num].ioq, fd, fp[num].buf,
		    sizeof(fp[num].buf), c_nix_fdwrite);
	}

	if (c_dir_open(&dir, cdir, C_FSLOG, nil) < 0)
		c_err_die(1, "c_dir_open");
	r = 0;
	while ((p = c_dir_read(&dir))) {
		switch (p->info) {
		case C_FSD:
			switch (p->depth) {
			case 0:
				p->num = DEFDIR;
				break;
			default:
				/* could be faster to ignore PREFIX
				 * dirs and only call this function
				 * when necessary */
				p->num = getdirnum(p->path);
			}
			break;
		case C_FSDC:
		case C_FSDP:
			break;
		case C_FSDNR:
		case C_FSNS:
		case C_FSERR:
			r = c_err_warnx("%s: %r", p->path, p->err);
			break;
		default:
			if (!CMP("INSTALL@", p->name))
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
				if (!CMP(".", p->name + p->nlen - 2)) {
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
