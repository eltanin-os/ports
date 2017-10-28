<| cat $PORTS/mk/config.mk

build:QV:
	# prepare env
	sed -e "s/CC=cc/CC=$CC/g" -e "s/CFLAGS=/CFLAGS+= $CPPFLAGS /g"\
	    -e "s/LDFLAGS=/LDFLAGS+=/g" Makefile > tmp
	mv tmp Makefile
	#
	make

install:QV:
	mkdir -p ${ROOT}/${BINDIR} ${ROOT}/${MANDIR}/man1
	install -c -s -m 555 pigz ${ROOT}/${BINDIR}/pigz
	install -c -s -m 555 unpigz ${ROOT}/${BINDIR}/unpigz
	install -c -m 444 pigz.1 ${ROOT}/${MANDIR}/man1


clean:QV:
	make clean
