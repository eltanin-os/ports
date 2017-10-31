<| cat $PORTS/mk/config.mk

BINS =\
	utilchest

SRC  =\
	src/basename.c\
	src/cat.c\
	src/chgrp.c\
	src/chmod.c\
	src/chown.c\
	src/chroot.c\
	src/clear.c\
	src/cp.c\
	src/date.c\
	src/dirname.c\
	src/domainname.c\
	src/echo.c\
	src/env.c\
	src/false.c\
	src/head.c\
	src/hostname.c\
	src/id.c\
	src/link.c\
	src/ln.c\
	src/ls.c\
	src/mkdir.c\
	src/mkfifo.c\
	src/mknod.c\
	src/mv.c\
	src/nice.c\
	src/printenv.c\
	src/pwd.c\
	src/readlink.c\
	src/rm.c\
	src/rmdir.c\
	src/sleep.c\
	src/sync.c\
	src/true.c\
	src/tty.c\
	src/uname.c\
	src/unlink.c\
	src/whoami.c\
	src/yes.c

LIBUTILOBJ =\
	lib/util/chown.o\
	lib/util/cp.o\
	lib/util/dir.o\
	lib/util/ealloc.o\
	lib/util/mode.o\
	lib/util/pathcat.o\
	lib/util/stoll.o

LIBUTFOBJ =\
	lib/utf/chartorune.o\
	lib/utf/iscntrlrune.o\
	lib/utf/isprintrune.o\
	lib/utf/isvalidrune.o\
	lib/utf/runetype.o

LOCAL_LIB =\
	lib/libutil.a\
	lib/libutf.a

SYMS =\
	utilchest ${BINDIR}/basename\
	utilchest ${BINDIR}/cat\
	utilchest ${BINDIR}/chgrp\
	utilchest ${BINDIR}/chmod\
	utilchest ${BINDIR}/chown\
	utilchest ${BINDIR}/chroot\
	utilchest ${BINDIR}/clear\
	utilchest ${BINDIR}/cp\
	utilchest ${BINDIR}/date\
	utilchest ${BINDIR}/dirname\
	utilchest ${BINDIR}/domainname\
	utilchest ${BINDIR}/echo\
	utilchest ${BINDIR}/env\
	utilchest ${BINDIR}/false\
	utilchest ${BINDIR}/head\
	utilchest ${BINDIR}/hostname\
	utilchest ${BINDIR}/id\
	utilchest ${BINDIR}/link\
	utilchest ${BINDIR}/ln\
	utilchest ${BINDIR}/ls\
	utilchest ${BINDIR}/mkdir\
	utilchest ${BINDIR}/mkfifo\
	utilchest ${BINDIR}/mknod\
	utilchest ${BINDIR}/mv\
	utilchest ${BINDIR}/nice\
	utilchest ${BINDIR}/printenv\
	utilchest ${BINDIR}/pwd\
	utilchest ${BINDIR}/readlink\
	utilchest ${BINDIR}/rm\
	utilchest ${BINDIR}/rmdir\
	utilchest ${BINDIR}/sleep\
	utilchest ${BINDIR}/sync\
	utilchest ${BINDIR}/true\
	utilchest ${BINDIR}/tty\
	utilchest ${BINDIR}/uname\
	utilchest ${BINDIR}/unlink\
	utilchest ${BINDIR}/whoami\
	utilchest ${BINDIR}/yes

OBJS =\
	$LIBUTILOBJ\
	$LIBUTFOBJ\
	${SRC:%.c=%.o}

<$PORTS/mk/mk.build

CFLAGS = $CFLAGS -I inc

lib/libutil.a: $LIBUTILOBJ
lib/libutf.a:  $LIBUTFOBJ

utilchest: $LOCAL_LIB
	mkdir -p build
	for f in ${SRC}; do sed "s/^main(/$(echo "$(basename ${f%.c})" | sed s/-/_/g)_&/" < $f > build/$(basename $f); done
	echo '#include <libgen.h>'                                                                                                                              > build/$target.c
	echo '#include <stdio.h>'                                                                                                                               >> build/$target.c
	echo '#include <string.h>'                                                                                                                              >> build/$target.c
	for f in ${SRC}; do echo "int $(echo "$(basename ${f%.c})" | sed s/-/_/g)_main(int, char **);"; done                                                    >> build/$target.c
	echo 'int main(int argc, char *argv[]) { char *s = basename(argv[0]);'                                                                                  >> build/$target.c
	echo 'if(!strcmp(s,"utilchest")) { argc--; argv++; s = basename(argv[0]); } if(0) ;'                                                                    >> build/$target.c
	for f in ${SRC}; do echo "else if(!strcmp(s, \"$(basename ${f%.c})\")) return $(echo "$(basename ${f%.c})" | sed s/-/_/g)_main(argc, argv);"; done      >> build/$target.c
	echo 'else { '                                                                                                                                          >> build/$target.c
	for f in ${SRC}; do echo "fputs(\"$(basename ${f%.c}) \", stdout);"; done                                                                               >> build/$target.c
	echo 'putchar(0xa); }; return 0; }'                                                                                                                     >> build/$target.c
	$CC $CFLAGS $CPPFLAGS $LDFLAGS -o $target build/*.c $prereq
	rm -rf build
