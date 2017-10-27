<| cat $PORTS/mk/config.mk

build:QV:
	chmod +x Build.sh
	rm -rf build
	mkdir build
	cd build
	../Build.sh

install:QV:
	cd build
	mkdir -p ${ROOT}/${BINDIR} ${ROOT}/${MANDIR}/man1
	install -c -s -m 555 mksh ${ROOT}/${BINDIR}/mksh
	install -c -m 444 ../lksh.1 ../mksh.1 ${ROOT}/${MANDIR}/man1

clean:QV:
	rm -rf build
