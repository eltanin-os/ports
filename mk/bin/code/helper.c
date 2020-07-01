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
	ctype_arr arr;
	ctype_ioq ioq;
	int tag;
	char buf[C_BIOSIZ];
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
		case C_FSF:
			if (!CSTRCMP("build", ep->name) ||
			    !CSTRCMP("vars", ep->name))
				++ep->parent->num; /* tag the parent */
			break;
		case C_FSDP:
			if (ep->num)
				if (c_cdb_mkadd(&cdbmk, ep->name, ep->nlen,
				    ep->path, ep->len) < 0)
					c_err_die(1, "c_cdb_mkadd");
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

/* conf routines */
static void
findstart(struct cfg *p)
{
	ctype_fd fd;

	fd = c_ioq_fileno(&p->ioq);
	c_sys_seek(fd, 0, C_SEEKSET);
	c_ioq_init(&p->ioq, fd, p->buf, sizeof(p->buf), &c_sys_read);
}

static ctype_fssize
getpos(struct cfg *p)
{
	return c_sys_seek(c_ioq_fileno(&p->ioq), 0, C_SEEKCUR);
}

static void
tagsetpos(struct cfg *p, ctype_fssize off)
{
	findstart(p);
	c_sys_seek(c_ioq_fileno(&p->ioq), off, C_SEEKSET);
	++p->tag;
}

static char *
getline(struct cfg *p, ctype_status *r)
{
	char *s;

	c_arr_trunc(&p->arr, 0, sizeof(uchar));
	if ((*r = c_ioq_getln(&p->ioq, &p->arr)) < 0)
		return (void *)-1;
	if (!*r)
		goto end;

	s = c_arr_data(&p->arr);
	s[c_arr_bytes(&p->arr) - 1] = 0;
	return s;
end:
	*r = -1;
	return nil;
}

static void
cfginit(struct cfg *p, ctype_fd fd)
{
	/* c_arr_init(&p->arr, nil, 0); */
	c_ioq_init(&p->ioq, fd, p->buf, sizeof(p->buf), &c_sys_read);
	p->tag = 0;
}

static char *
cfgfind(struct cfg *cfg, char *k)
{
	ctype_status r;
	char *p, *s;

	findstart(cfg);
	for (;;) {
		s = getline(cfg, &r);
		if (r < 0)
			return s;
		if (!(p = c_mem_chr(s, c_arr_bytes(&cfg->arr), ':')))
			continue;
		*p++ = 0;
		if (!(c_str_cmp(s, C_USIZEMAX, k)))
			return p;
	}
}

static char *
cfgfindtag(struct cfg *cfg, char *k)
{
	ctype_status r;
	char *s;

	if (!cfg->tag) {
		findstart(cfg);
		do {
			s = getline(cfg, &r);
			if (r < 0)
				return s;
			if (!c_str_cmp(s, C_USIZEMAX, k))
				++cfg->tag;
		} while(!cfg->tag);
	}
	s = getline(cfg, &r);
	if (r < 0)
		return s;
	if (*s == '}') {
		cfg->tag = 0;
		return nil;
	}
	if (*s != '\t') {
		cfg->tag = 0;
		errno = C_EINVAL;
		return (void *)-1;
	}
	return ++s;
}

/* args utils routines */
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

static struct cfg *
getcfg(char *s)
{
	static struct cfg cfg;
	ctype_fd fd;

	if (c_arr_data(&cfg.arr))
		c_sys_close(c_ioq_fileno(&cfg.ioq));

	s = fmtstr("%s/vars", s);
	if ((fd = c_sys_open(s, C_OREAD, 0)) < 0)
		c_err_die(1, "c_sys_open %s", s);

	cfginit(&cfg, fd);
	return &cfg;
}

static char *
getkey(struct cfg *cfg, char *k, int istag)
{
	ctype_fssize off;
	usize len;
	int ch;
	char *(*func)(struct cfg *, char *);
	char *e, *p, *s;

	func = istag ? cfgfindtag : cfgfind;
	if ((s = func(cfg, k)) == (void *)-1)
		c_err_die(1, "getkey");
	if (s && (p = c_str_chr(s, -1, '$'))) {
		len = p - s;
		if (!(s = c_str_dup(s, c_arr_bytes(&cfg->arr))))
			c_err_die(1, "c_str_dup");
		p = s + len;
		*p++ = 0;
		for (e = p; *e && c_str_casechr(ALPHA, 26, *e); ++e) ;
		off = getpos(cfg);
		if (*e) {
			ch = *e;
			*e++ = 0;
			s = fmtstr("%s%s%c%s", s, getkey(cfg, p, 0), ch, e);
		} else {
			s = fmtstr("%s%s", s, getkey(cfg, p, 0));
		}
		len = c_arr_bytes(&cfg->arr);
		c_arr_trunc(&cfg->arr, 0, sizeof(uchar));
		if (c_dyn_fmt(&cfg->arr, "%s", s) < 0)
			c_err_die(1, "c_dyn_fmt");
		c_std_free(s);
		s = c_arr_data(&cfg->arr);
		tagsetpos(cfg, off + len);
	}
	return s;
}

/* args routines */
static int
populatedeps(ctype_node **np, ctype_node *list)
{
	struct cfg *cfg;
	ctype_stat st;
	ctype_node *wp;
	ctype_status r;
	int n;
	char *path, *s;

	if (!list)
		return 0;

	wp = list->next;
	r = n = 0;
	do {
		cfg = getcfg(wp->p);
		if (!(s = getkey(cfg, "mdeps{", 1)))
			break;
		do {
			path = fmtstr("%s/%s-dev", dbdir, s);
			if (!c_sys_stat(&st, path))
				continue;
			if (!(path = getpath(s))) {
				r = c_err_warnx("%s: package not found", s);
				continue;
			}
			if (c_adt_ltpush(np,
			    c_adt_lnew(path, c_str_len(path, -1) + 1)) < 0)
				c_err_die(1, "c_adt_lpush %s", path);
			n = 1;
		} while ((s = getkey(cfg, nil, 1)));
		c_sys_close(c_ioq_fileno(&cfg->ioq));
	} while ((wp = wp->next)->prev);

	if (r)
		c_sys_exit(1);
	if (n)
		populatedeps(np, *np);
	return n;
}

static void
printdeps(char **argv)
{
	ctype_node *deps, *list;
	ctype_status r;
	char *s;

	list = nil;
	r = 0;
	for (; *argv; ++argv) {
		if (!(s = getpath(*argv))) {
			r = c_err_warnx("%s: package not found", *argv);
			continue;
		}
		if (c_adt_lpush(&list, c_adt_lnew(s, c_str_len(s, -1) + 1)) < 0)
			c_err_die(1, "c_adt_lpush %s", s);
	}

	if (r)
		c_sys_exit(1);

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
	    "       %s [-u] -d pkg ...\n",
	    "          -u\n",
	    c_std_getprogname(), c_std_getprogname(), c_std_getprogname());
	c_std_exit(1);
}

ctype_status
main(int argc, char **argv)
{
	struct cfg *cfg;
	ctype_fd fd;
	int mode, uflag;
	char *key, *s;

	c_std_setprogname(argv[0]);

	mode = PMODE;
	uflag = 0;

	C_ARGBEGIN {
	case 'd':
		mode = DMODE;
		break;
	case 'k':
		key = C_EARGF(usage());
		mode = KMODE;
		break;
	case 't':
		key = C_EARGF(usage());
		mode = TMODE;
		break;
	case 'u':
		uflag = 1;
		break;
	default:
		usage();
	} C_ARGEND


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

	if (!(dbdir = c_std_getenv("DBDIR")))
		c_err_diex(1, "missing DBDIR environmental variable");

	if ((fd = c_sys_open(s, C_OREAD, 0)) < 0)
		c_err_die(1, "c_sys_open %s", s);
	c_cdb_init(&cdb, fd);

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
		cfg = getcfg(s);
		c_ioq_fmt(ioq1, "%s\n", getkey(cfg, key, 0));
		c_sys_close(c_ioq_fileno(&cfg->ioq));
		break;
	case TMODE:
		if (!(s = getpath(*argv)))
			c_err_diex(1, "%s: package not found", *argv);
		cfg = getcfg(s);
		if (!(s = getkey(cfg, fmtstr("%s{", key), 1)))
			break;
		do {
			c_ioq_fmt(ioq1, "%s\n", s);
		} while ((s = getkey(cfg, nil, 1)));
	}
	c_ioq_flush(ioq1);
	return 0;
}
