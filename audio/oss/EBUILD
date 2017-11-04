#!/bin/sh

NAME="oss"
LONGNAME="$NAME"
VERSION="4.2-build2017"
LICENSE="GPL2"
DESCRIPTION="Open Sound System UNIX audio architecture."
MAKEDEPS="libc linux-headers"

SRC="${NAME}-v${VERSION}-src-gpl"
URL="http://www.4front-tech.com/developer/sources/stable/gpl/${NAME}-v${VERSION}-src-gpl.tar.bz2"
PATCHES="../patches/musl_linux_static_hack.patch"

. ${PORTS}/mk/default.sh

prepare() {
	default_prepare
}

build() {
	cd "$SRC"
	oldpwd="$(pwd)"
	mkdir build
	cd build
	${oldpwd}/configure --enable-libsalsa=NO --portable-build
	make
}

install() {
	true
}

$@
