#!/bin/sh

NAME="ncurses"
LONGNAME="netbsd-curses"
VERSION="0.2.1"
LICENSE="BSD-3"
DESCRIPTION="Netbsd curses library."
MAKEDEPS="libc"

SRC="${LONGNAME}-${VERSION}"
URL="http://ftp.barfooze.de/pub/sabotage/tarballs/${LONGNAME}-${VERSION}.tar.xz"
INFILE="../ncurses.in"

. ${PORTS}/mk/default.sh

prepare() {
	default_prepare
}

build() {
	cd $SRC
	make CC="$CC" CFLAGS="$CPPFLAGS $CFLAGS" LDFLAGS="$LDFLAGS" all-static
}

install() {
	true
}

$@
