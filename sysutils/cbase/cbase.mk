<| cat $PORTS/mk/config.mk

build:QV:
	make AR=$AR CC=$CC RANLIB=$RANLIB

install:QV:
	make PREFIX=$ROOT install

clean:QV:
	make clean
