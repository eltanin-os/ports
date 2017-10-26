<| cat $PORTS/mk/config.mk

build:QV:
	# edit config.mk
	sed -e "s/cc/$CC/g" -e "s/ar/$AR/g" -e "s/ranlib/$RANLIB/g"\
	    -e "s/\/usr\/local//g" config.mk > tmp
	mv tmp config.mk
	#
	make utilchest

install:QV:
	make DESTDIR="$ROOT" utilchest-install

clean:QV:
	make clean
