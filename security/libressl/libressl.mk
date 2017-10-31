<| cat $PORTS/mk/config.mk

all:QV: build

build:QV:
	./configure --prefix="$PREFIX"
	make

install:QV:
	make DESTDIR="$ROOT" install

clean:QV:
	make clean
