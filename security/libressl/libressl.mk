<| cat $PORTS/mk/config.mk

build:QV:
	./configure --prefix=/
	make

install:QV:
	make DESTDIR="$ROOT" install

clean:QV:
	make clean
