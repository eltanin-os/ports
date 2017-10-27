<| cat $PORTS/mk/config.mk

build:QV:
	./configure --prefix=/ --disable-shared
	make

install:QV:
	make DESTDIR="$ROOT" install

clean:QV:
	make clean
