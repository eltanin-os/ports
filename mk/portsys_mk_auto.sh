#!/bin/sh

_C="$CFLAGS"
_P="$CPPFLAGS"
_L="$LDFLAGS"

. ${PORTS}/mk/config.mk

[ -z "$_C" ] && _C="$CFLAGS"
[ -z "$_P" ] && _P="$CPPFLAGS"
[ -z "$_L" ] && _L="$LDFLAGS"

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
	env AR="$AR" CC="$CC" CXX="$CXX" CFLAGS="$_C" \
	    CPPFLAGS="$_P" LDFLAGS="$_L" YACC="$YACC" \
	    RANLIB="$RANLIB" STRIP="$STRIP"           \
	    $CONFIGURE --prefix="$PREFIX"             \
	               --bindir="$BINDIR"             \
	               --sbindir="$BINDIR"            \
	               --libdir="$LIBDIR"             \
	               --includedir="$INCDIR"         \
	               --oldincludedir="$INCDIR"      \
	               --datarootdir="$PREFIX"        \
	               --mandir="$MANDIR"             \
	               --enable-shared="$shared"      \
	               --enable-static="$static"      \
	               $_PORTSYS_MK_AUTO_EXTRAFLAGS
	make $@
fi
