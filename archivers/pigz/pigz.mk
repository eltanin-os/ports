<| cat $PORTS/mk/config.mk

BINS =\
	pigz

MANS =\
	1 pigz.1

OBJS =\
	pigz.o\
	try.o\
	yarn.o\
	zopfli/src/zopfli/blocksplitter.o\
	zopfli/src/zopfli/cache.o\
	zopfli/src/zopfli/deflate.o\
	zopfli/src/zopfli/hash.o\
	zopfli/src/zopfli/katajainen.o\
	zopfli/src/zopfli/lz77.o\
	zopfli/src/zopfli/squeeze.o\
	zopfli/src/zopfli/tree.o\
	zopfli/src/zopfli/util.o

SYMS =\
	pigz ${BINDIR}/unpigz

<$PORTS/mk/mk.build

LDLIBS= -lm -lpthread -lz

${BINS}: ${OBJS}
