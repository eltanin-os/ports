<| cat $PORTS/mk/config.mk

BIN= utilchest

SYM=\
	src/basename\
	src/cat\
	src/chgrp\
	src/chmod\
	src/chown\
	src/chroot\
	src/clear\
	src/cp\
	src/date\
	src/dirname\
	src/domainname\
	src/echo\
	src/env\
	src/false\
	src/head\
	src/hostname\
	src/id\
	src/link\
	src/ln\
	src/ls\
	src/mkdir\
	src/mkfifo\
	src/mknod\
	src/mv\
	src/nice\
	src/printenv\
	src/pwd\
	src/readlink\
	src/rm\
	src/rmdir\
	src/sleep\
	src/sync\
	src/true\
	src/tty\
	src/uname\
	src/unlink\
	src/whoami\
	src/yes

SRC= ${SYM:%=%.c}

LIBUTILOBJ=\
	lib/util/chown.o\
	lib/util/cp.o\
	lib/util/dir.o\
	lib/util/ealloc.o\
	lib/util/mode.o\
	lib/util/pathcat.o\
	lib/util/stoll.o

LIBUTFOBJ=\
	lib/utf/chartorune.o\
	lib/utf/iscntrlrune.o\
	lib/utf/isprintrune.o\
	lib/utf/isvalidrune.o\
	lib/utf/runetype.o

LIB= lib/libutil.a lib/libutf.a

<$PORTS/mk/mk.build

CFLAGS = $CFLAGS -I inc
LDLIBS = ${LIB}

lib/libutil.a: $LIBUTILOBJ
lib/libutf.a:  $LIBUTFOBJ

build:QV: utilchest
install:QV: utilchest-install

utilchest: $LIB
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

utilchest-install:QV: build
	install -dm 755 ${ROOT}/${BINDIR}
	install -csm 755 utilchest ${ROOT}/${BINDIR}
	for f in $(echo $SYM | sed 's/src\///g'); do ln -s utilchest ${ROOT}/${BINDIR}/$f; done
