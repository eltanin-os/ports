<| cat $PORTS/mk/config.mk

build:QV:
	# set env
	echo "CC=\"$CC\""                    >> configure.local
	echo "CFLAGS=\"$CFLAGS\""            >> configure.local
	echo "LDFLAGS=\"$LDFLAGS\""          >> configure.local
	echo "BUILD_CATMAN=1"                >> configure.local
	echo "PREFIX=\"${PREFIX}/\""         >> configure.local
	echo "INSTALL_PROGRAM=\"$INSTALL -s\""        >> configure.local
	echo "MANPATH_DEFAULT=\"${MANDIR}\"" >> configure.local
	#
	./configure
	make

install:QV:
	make DESTDIR="$ROOT" install

clean:QV:
	make clean
