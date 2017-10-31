<| cat $PORTS/mk/config.mk

all:QV: build

build:QV:
	./configure --prefix="$PREFIX" --disable-shared
	make

install:QV:
	make DESTDIR="$ROOT" install

clean:QV:
	make clean
