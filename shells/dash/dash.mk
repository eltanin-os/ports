<| cat $PORTS/mk/config.mk

build:QV:
	./configure --prefix=/ --enable-static
	make

install:QV:
	# for some reason 'install' is set wrong
	sed 's/\/usr\/binstall/\/usr\/bin\/install/g' src/Makefile > tmp
	mv tmp src/Makefile
	#
	make DESTDIR="$ROOT" install

clean:QV:
	make clean
