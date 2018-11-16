#!/bin/sh

_C="$CFLAGS"
_P="$CPPFLAGS"
_L="$LDFLAGS"

. ${PORTS}/mk/config.mk

CONFIGURE="./configure"

if [ -z "$_PORTSYS_MK_AUTO_NOBUILDDIR" ]; then
	mkdir build
	cd    build
	CONFIGURE="../configure"
fi

case "$_L" in
*"-static"*)
	static=yes
	shared=no
	;;
*)
	static=no
	shared=yes
	;;
esac

if [ "$1" == "install" ]; then
	make DESTDIR="$DESTDIR" $@
else
	[ ! -n "$PREFIX" ] && PREFIX="/"
	env CC="$CC" CXX="$CXX" CFLAGS="$_C" CPPFLAGS="$_P" LDFLAGS="$_L" \
	$CONFIGURE --prefix="$PREFIX"        \
	           --bindir="$BINDIR"        \
	           --sbindir="$BINDIR"       \
	           --libdir="$LIBDIR"        \
	           --includedir="$INCDIR"    \
	           --oldincludedir="$INCDIR" \
	           --datarootdir="$PREFIX"   \
	           --mandir="$MANDIR"        \
	           --enable-shared="$shared" \
	           --enable-static="$static" \
	           $_PORTSYS_MK_AUTO_EXTRAFLAGS
	make CC="$CC" CXX="$CXX" DESTDIR="$DESTDIR" $@
fi
