#!/bin/sh

_C="$CFLAGS"
_P="$CPPFLAGS"
_L="$LDFLAGS"

. ${PORTS}/mk/config.mk

make -j $nprocs\
     CC="$CC"\
     CXX="$CXX"\
     CFLAGS="$_C"\
     CPPFLAGS="$_P"\
     LDFLAGS="$_L"\
     PREFIX="$PREFIX"\
     BINDIR="$BINDIR"\
     LIBDIR="$LIBDIR"\
     ETCDIR="$ETCDIR"\
     DFLDIR="$DFLDIR"\
     MANDIR="$MANDIR"\
     INCDIR="$INCDIR"\
     $@
