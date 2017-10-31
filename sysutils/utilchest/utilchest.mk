<| cat $PORTS/mk/config.mk

BINS =\
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

LOCAL_LIBS = lib/libutil.a lib/libutf.a
OBJS       = ${BINS:%=%.o} $LIBUTILOBJ $LIBUTFOBJ

<$PORTS/mk/mk.build

all:QV: $LOCAL_LIBS

CFLAGS = $CFLAGS -I inc
LDLIBS = ${LOCAL_LIBS}

lib/libutil.a: $LIBUTILOBJ
lib/libutf.a:  $LIBUTFOBJ

# TODO: SEE A BETER WAY TO HANDLE PREREQ
${BINS}: ${LOCAL_LIBS}
