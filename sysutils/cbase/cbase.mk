<| cat $PORTS/mk/config.mk

build:QV:
	make AR=$AR CC=$CC RANLIB=$RANLIB cbase

install:QV:
	make PREFIX=$ROOT cbase-install

clean:QV:
	make clean
