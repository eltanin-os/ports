<| cat $PORTS/mk/config.mk

all:QV: all

build:QV:
	./configure --prefix="$PREFIX" --enable-shared=no
	make

install:QV:
	make DESTDIR="$ROOT" install

clean:QV:
	make clean
