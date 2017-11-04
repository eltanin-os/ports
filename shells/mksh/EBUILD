#!/bin/sh

NAME="mksh"
LONGNAME="$NAME"
VERSION="56b"
LICENSE="MIROS"
DESCRIPTION="An enhanced version of the public domain ksh."
MAKEDEPS="libc"

SRC="$NAME"
URL="https://www.mirbsd.org/MirOS/dist/mir/mksh/${NAME}-R${VERSION}.tgz"
INFILE=""

. ${PORTS}/mk/default.sh

prepare() {
	default_prepare
}

build() {
	cd $SRC
	chmod +x Build.sh
	rm -rf build
	mkdir build
	cd build
	../Build.sh
}

install() {
	true
}

$@
