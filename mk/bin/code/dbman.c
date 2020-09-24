#include <tertium/cpu.h>
#include <tertium/std.h>

enum {
	PMODE,
	DMODE,
	KMODE,
	TMODE,
};

#define ALPHA "abcdefghijklmnopqrstuvxwyz"
#define CSTRCMP(a, b) c_mem_cmp((a), sizeof((a)), (b))
#define fmtstr(...) fmtstr_(__VA_ARGS__, nil)

struct cfg {
	ctype_ioq ioq;
	ctype_arr *arr;
	ctype_fd fd;
	int tag;
	char buf[C_SMALLBIOSIZ];
};

static ctype_cdb cdb;
static char *dbdir;
static char *ports;

/* misc routines */
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

/* conf routines */
static void
findstart(struct cfg *c)
{
	c_sys_seek(c->fd, 0, C_SEEKSET);
	c_ioq_init(&c->ioq, c->fd, c->buf, sizeof(c->buf), &c_sys_read);
}

static char *
getline(struct cfg *p, ctype_status *r)
{
	char *s;

	c_arr_trunc(p->arr, 0, sizeof(uchar));
	if ((*r = c_ioq_getln(&p->ioq, p->arr)) < 0)
		return (void *)-1;
	if (!*r) {
		*r = -1;
		return nil;
	}
	s = c_arr_data(p->arr);
	s[c_arr_bytes(p->arr) - 1] = 0;
	return s;
}

void
cfginit(struct cfg *c, ctype_fd fd)
{
	/* c_arr_init(&c->arr, nil, 0); */
	c_ioq_init(&c->ioq, fd, c->buf, sizeof(c->buf), &c_sys_read);
	c->tag = 0;
	c->fd = fd;
}

char *
cfgfind(struct cfg *c, char *k)
{
	ctype_status r;
	char *p, *s;

	findstart(c);
	for (;;) {
		s = getline(c, &r);
		if (r < 0)
			return s;
		if (!(p = c_mem_chr(s, c_arr_bytes(c->arr), ':')))
			continue;
		*p++ = 0;
		if (!(c_str_cmp(s, C_USIZEMAX, k)))
			return p;
	}
}

char *
cfgfindtag(struct cfg *c, char *k)
{
	ctype_status r;
	char *s;

	if (!c->tag) {
		findstart(c);
		do {
			s = getline(c, &r);
			if (r < 0)
				return s;
			if (!c_str_cmp(s, C_USIZEMAX, k))
				++c->tag;
		} while(!c->tag);
	}
	s = getline(c, &r);
	if (r < 0)
		return s;
	if (*s == '}') {
		c->tag = 0;
		return nil;
	}
	if (*s != '\t') {
		c->tag = 0;
		errno = C_EINVAL;
		return (void *)-1;
	}
	return ++s;
}

/* easy conf routines */
static void *
getcfg(char *s)
{
	static ctype_arr arr;
	struct cfg *c;
	ctype_fd fd;

	if (!(c = c_std_alloc(1, sizeof(c))))
		c_err_die(1, "c_std_alloc");
	c->arr = &arr;

	s = fmtstr("%s/vars", s);
	if ((fd = c_sys_open(s, C_OREAD, 0)) < 0)
		c_err_die(1, "c_sys_open %s", s);
	cfginit(c, fd);
	return c;
}

static void *
dupcfg(struct cfg *c)
{
	struct cfg *nc;

	if (!(nc = c_std_alloc(1, sizeof(*nc))))
		c_err_die(1, "c_std_alloc");
	nc->arr = c->arr;
	cfginit(nc, c->fd);
	return nc;
}

static void
closecfg(struct cfg *c)
{
	c_sys_close(c->fd);
	c_std_free(c);
}

static char *
getkey(struct cfg *c, char *k, int istag)
{
	struct cfg *nc;
	usize len;
	int ch;
	char *e, *p, *s;

	if ((s = (istag ? cfgfindtag : cfgfind)(c, k)) == (void *)-1)
		c_err_die(1, "getkey");
	if (!s)
		return nil;
	while ((p = c_str_chr(s, c_arr_bytes(c->arr), '$'))) {
		len = p - s;
		if (!(s = c_str_dup(s, c_arr_bytes(c->arr))))
			c_err_die(1, "c_str_dup");
		p = s + len;
		*p++ = 0;
		for (e = p; *e && c_str_casechr(ALPHA, 26, *e); ++e) ;
		nc = dupcfg(c);
		if (*e) {
			ch = *e;
			*e++ = 0;
			s = fmtstr("%s%s%c%s", s, getkey(nc, p, 0), ch, e);
		} else {
			s = fmtstr("%s%s", s, getkey(nc, p, 0));
		}
		c_std_free(nc);
		len = c_arr_bytes(c->arr);
		c_arr_trunc(c->arr, 0, sizeof(uchar));
		if (c_dyn_fmt(c->arr, "%s", s) < 0)
			c_err_die(1, "c_dyn_fmt");
		c_std_free(s);
		s = c_arr_data(c->arr);
	}
	return s;
}

static char *
getpath(char *s)
{
	static ctype_arr arr;
	usize len, pos;

	if (c_cdb_find(&cdb, s, c_str_len(s, -1)) <= 0)
		return nil;
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

/* arg routines */
static void
gencache(char *path)
{
	ctype_dir dir;
	ctype_dent *ep;
	ctype_cdbmk cdbmk;
	ctype_fd fd;
	char tmp[21];
	char *argv[2];

	c_mem_cpy(tmp, sizeof(tmp), "/tmp/PORTS@XXXXXXXXX");
	if ((fd = c_std_mktemp(tmp, sizeof(tmp), 0)) < 0)
		c_err_die(1, "c_std_mktemp %s", tmp);

	if (c_cdb_mkstart(&cdbmk, fd) < 0)
		c_err_die(1, "c_cdb_init");

	argv[0] = ports;
	argv[1] = nil;
	if (c_dir_open(&dir, argv, C_FSLOG, nil) < 0)
		c_err_die(1, "c_dir_open");

	while ((ep = c_dir_read(&dir))) {
		switch (ep->info) {
		case C_FSD:
			if (ep->name[0] == '.' && ep->name[1]) {
				c_dir_set(&dir, ep, C_FSSKP);
				continue;
			}
			break;
		case C_FSDP:
			if (ep->num)
				if (c_cdb_mkadd(&cdbmk, ep->name, ep->nlen,
				    ep->path, ep->len) < 0)
					c_err_die(1, "c_cdb_mkadd");
			break;
		case C_FSF:
			if (!CSTRCMP("build", ep->name) ||
			    !CSTRCMP("vars", ep->name))
				++ep->parent->num; /* tag the parent */
			break;
		case C_FSDNR:
		case C_FSNS:
		case C_FSERR:
			c_err_warnx("%s: %r", ep->path, ep->err);
			/* FALLTHROUGH */
		default:
			continue;
		}
	}
	c_dir_close(&dir);

	if (c_cdb_mkfinish(&cdbmk) < 0)
		c_err_die(1, "c_cdb_mkfinish");
	c_sys_close(fd);

	if (c_sys_rename(tmp, path) < 0)
		c_err_die(1, "c_sys_rename %s %s", tmp, path);
}

static int
checknode(ctype_node *p, char *s)
{
	if (!p)
		return 0;
	p = p->next;
	do {
		if (!c_str_cmp(p->p, -1, s))
			return 1;
	} while ((p = p->next)->prev);
	return 0;
}

static int
populatedeps(ctype_node **np, ctype_node *list)
{
	struct cfg *c;
	ctype_stat st;
	ctype_node *deps, *wp;
	usize len, n;
	ctype_status r;
	char *p, *s;

	if (!list)
		return 0;

	n = r = 0;
	wp = list->next;
	do {
		c = getcfg(wp->p);
		if (!(s = getkey(c, "mdeps{", 1)))
			break;
		do {
			p = fmtstr("%s/%s-dev", dbdir, s);
			if (!c_sys_stat(&st, p))
				continue;
			if (!(p = getpath(s))) {
				r = c_err_warnx("%s: package not found", s);
				continue;
			}
			if (checknode(*np, p))
				continue;
			len = c_str_len(p, -1) + 1;
			if (c_adt_ltpush(np, c_adt_lnew(p, len)) < 0)
				c_err_die(1, "c_adt_ltpush %s", p);
			++n;
		} while ((s = getkey(c, nil, 1)));
		closecfg(c);
	} while ((wp = wp->next)->prev);

	if (n) {
		deps = nil;
		r |= populatedeps(&deps, *np);
		c_adt_ltpush(np, deps);
	}

	return r ? (c_std_exit(1), -1) : 0;
}

static void
printdeps(char **argv)
{
	ctype_node *deps, *list;
	ctype_status r;
	char *s;

	r = 0;
	list = nil;
	for (; *argv; ++argv) {
		if (!(s = getpath(*argv))) {
			r = c_err_warnx("%s: package not found", *argv);
			continue;
		}
		if (c_adt_lpush(&list, c_adt_lnew(s, c_str_len(s, -1) + 1)) < 0)
			c_err_die(1, "c_adt_lpush %s", s);
	}

	if (r)
		c_std_exit(1);

	deps = nil;
	populatedeps(&deps, list);

	if (!deps)
		return;

	deps = deps->next;
	do {
		c_ioq_fmt(ioq1, "%s\n", c_gen_basename(deps->p));
	} while ((deps = deps->next)->prev);
}

static void
usage(void)
{
	c_ioq_fmt(ioq2,
	    "usage: %s [-u] pkg\n"
	    "       %s [-u] -k|-t key pkg\n"
	    "       %s [-u] -d pkg ...\n"
	    "       %s -u\n",
	    c_std_getprogname(), c_std_getprogname(),
	    c_std_getprogname(), c_std_getprogname());
	c_std_exit(1);
}

ctype_status
main(int argc, char **argv)
{
	struct cfg *c;
	ctype_fd fd;
	int mode, uflag;
	char *k, *s;
	char *syspath;

	c_std_setprogname(argv[0]);
	--argc, ++argv;

	mode = PMODE;
	uflag = 0;

	while (c_std_getopt(argmain, argc, argv, "dk:t:u")) {
		switch (argmain->opt) {
		case 'd':
			mode = DMODE;
			break;
		case 'k':
			k = argmain->arg;
			mode = KMODE;
			break;
		case 't':
			k = argmain->arg;
			mode = TMODE;
			break;
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
		gencache(s);
		if (!argc)
			return 0;
	}

	if (!argc)
		usage();

	if ((fd = c_sys_open(s, C_OREAD, 0)) < 0)
		c_err_die(1, "c_sys_open %s", s);
	c_cdb_init(&cdb, fd);

	if (!(syspath = c_std_getenv("SYSPATH")))
		c_err_diex(1, "missing SYSPATH environmental variable");
	if (!(dbdir = c_std_getenv("DBDIR")))
		c_err_diex(1, "missing DBDIR environmental variable");
	if (!(dbdir = c_str_dup(fmtstr("%s/%s", syspath, dbdir), -1)))
		c_err_die(1, "c_str_dup");

	switch (mode) {
	case PMODE:
		if (!(s = getpath(*argv)))
			c_err_diex(1, "%s: package not found", *argv);
		c_ioq_fmt(ioq1, "%s\n", s);
		break;
	case DMODE:
		printdeps(argv);
		break;
	case KMODE:
		if (!(s = getpath(*argv)))
			c_err_diex(1, "%s: package not found", *argv);
		c = getcfg(s);
		c_ioq_fmt(ioq1, "%s\n", getkey(c, k, 0));
		closecfg(c);
		break;
	case TMODE:
		if (!(s = getpath(*argv)))
			c_err_diex(1, "%s: package not found", *argv);
		c = getcfg(s);
		if (!(s = getkey(c, fmtstr("%s{", k), 1)))
			break;
		do {
			c_ioq_fmt(ioq1, "%s\n", s);
		} while ((s = getkey(c, nil, 1)));
		closecfg(c);
	}
	c_ioq_flush(ioq1);
	return 0;
}
