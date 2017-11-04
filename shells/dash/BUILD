#!/bin/sh

NAME="dash"
LONGNAME="$NAME"
VERSION="0.5.9"
LICENSE="BSD-3"
DESCRIPTION="A POSIX compliant shell that aims to be as small as possible."
MAKEDEPS="libc"

SRC="${NAME}-${VERSION}"
URL="http://gondor.apana.org.au/~herbert/dash/files/${NAME}-${VERSION}.tar.gz"
INFILE=""

. ${PORTS}/mk/default.sh

prepare() {
	default_prepare
}

build() {
	cd $SRC
	./configure --prefix="$PREFIX" --enable-static
	make
}

install() {
	true
}

$@
