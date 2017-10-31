<| cat $PORTS/mk/config.mk

build:QV:
	./configure --prefix=$PREFIX --enable-shared=no
	make

install:QV:
	make DESTDIR="$ROOT" install

clean:QV:
	make clean
