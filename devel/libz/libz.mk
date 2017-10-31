<| cat $PORTS/mk/config.mk

LIBS =\
	libz.a

MANS =\
	3 libz.3

OBJS =\
	adler32.o\
	compress.o\
	crc32.o\
	deflate.o\
	gzclose.o\
	gzlib.o\
	gzread.o\
	gzwrite.o\
	infback.o\
	inffast.o\
	inflate.o\
	inftrees.o\
	trees.o\
	uncompr.o\
	zutil.o\

<$PORTS/mk/mk.build

CFLAGS   = $CFLAGS -I.
CPPFLAGS = $CPPFLAGS -DZ_INSIDE_LIBZ

${LIBS}: ${OBJS}
