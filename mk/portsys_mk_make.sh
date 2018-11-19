#!/bin/sh

_C="$CFLAGS"
_P="$CPPFLAGS"
_L="$LDFLAGS"

. ${PORTS}/mk/config.mk

[ -z "$_C" ] && _C="$CFLAGS"
[ -z "$_P" ] && _P="$CPPFLAGS"
[ -z "$_L" ] && _L="$LDFLAGS"

make -j $nprocs         \
     AR="$AR"           \
     CC="$CC"           \
     CXX="$CXX"         \
     CFLAGS="$_C"       \
     CPPFLAGS="$_P"     \
     LDFLAGS="$_L"      \
     YACC="$YACC"       \
     STRIP="$STRIP"     \
     RANLIB="$RANLIB"   \
     PREFIX="$PREFIX"   \
     BINDIR="$BINDIR"   \
     LIBDIR="$LIBDIR"   \
     ETCDIR="$ETCDIR"   \
     DFLDIR="$DFLDIR"   \
     MANDIR="$MANDIR"   \
     INCDIR="$INCDIR"   \
     DESTDIR="$DESTDIR" \
     $@
