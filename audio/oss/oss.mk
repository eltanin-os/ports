<| cat $PORTS/mk/config.mk

build:QV:
	mkdir build
	cd build
	$(pwd)/../configure --enable-libsalsa=NO --portable-build
	make

install:QV:
	cd build
	make DESTDIR="$ROOT" install

clean:QV:
	cd build
	make
