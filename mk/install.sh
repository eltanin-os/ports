#!/bin/sh

install_bin() {
	$INSTALL -dm 755 ${ROOT}$BINDIR
	$INSTALL -csm 755 $BINS ${ROOT}$BINDIR
}

install_inc() {
	true
}

install_lib() {
	$INSTALL -dm 755 ${ROOT}$LIBDIR
	$INSTALL -csm 755 $LIBS ${ROOT}$LIBDIR
}

install_man() {
	for mfile in "${MANS}"; do
		man=`basename $mfile .gz`
		mdir="${ROOT}$MANDIR/man$(echo -n $man | tail -c 1)"
		$INSTALL -dm 755 $mdir
		$INSTALL -csm 755 $man $mdir
	done
}

install_sym() {
	true
}

