<| cat $PORTS/mk/config.mk

build:QV:
	make AR="$AR" CC="$CC" RANLIB="$RANLIB" PREFIX="$PREFIX" utilchest

install:QV:
	make DESTDIR="$ROOT" utilchest-install

clean:QV:
	make clean
