<| cat $PORTS/mk/config.mk

build:QV:
	make CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" all-static

install:QV:
	make CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"\
	     PREFIX="$PREFIX" DESTDIR="$ROOT" install-static

clean:QV:
	make clean
