#!/bin/sh

NAME="pkgconfig"
LONGNAME="pkgconf"
VERSION="1.3.10"
LICENSE="custom-ISC"
DESCRIPTION="A program which helps to configure compiler and linker flags\
 for development frameworks."
MAKEDEPS="libc"

SRC="${LONGNAME}-${VERSION}"
URL="https://distfiles.dereferenced.org/pkgconf/${LONGNAME}-${VERSION}.tar.gz"
INFILE="../pkgconf.in"

. ${PORTS}/mk/default.sh

prepare() {
	default_prepare
}

build() {
	cd $SRC
	./configure --prefix="$PREFIX" --enable-shared=no
	make
}

install() {
	true
}

$@
