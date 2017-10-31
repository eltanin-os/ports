<| cat $PORTS/mk/config.mk

all:QV: build

build:QV:
	make AR="$AR" CC="$CC" RANLIB="$RANLIB"\
	     CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"

install:QV:
	make PREFIX="$ROOT" install

clean:QV:
	make clean
