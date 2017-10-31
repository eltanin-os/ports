<| cat $PORTS/mk/config.mk

BINS =\
	bzip2\
	bzip2recover

INCS =\
	bzlib.h

LIBS =\
	libbz2.a

MANS =\
	1 bzdiff.1\
	1 bzgrep.1\
	1 bzip2.1\
	1 bzmore.1

OBJS =\
	blocksort.o\
	huffman.o\
	crctable.o\
	randtable.o\
	compress.o\
	decompress.o\
	bzlib.o

SYMS =\
	bzip2 ${BINDIR}/bunzip2\
	bzip2 ${BINDIR}/bzcat

<$PORTS/mk/mk.build

${BINS}: ${OBJS}
