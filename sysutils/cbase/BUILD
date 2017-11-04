#!/bin/sh

NAME="cbase"
LONGNAME="$NAME"
VERSION="0.0"
LICENSE="MULTIPLE"
DESCRIPTION="Complementary set of unix utilities for utilchest."
MAKEDEPS="libc ncurses"

SRC="$NAME"
GIT="https://github.com/eltanin-os/$NAME"
INFILE=""

. ${PORTS}/mk/default.sh

prepare() {
	default_prepare
}

build() {
	cd $SRC
	make AR=$AR CC=$CC RANLIB=$RANLIB cbase
}

install() {
	true
}

$@
