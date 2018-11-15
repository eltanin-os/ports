#!/bin/sh
. ${PORTS}/mk/config.mk

make -j $nprocs\
     CC="$CC"\
     CXX="$CXX"\
     CPPFLAGS="$CPPFLAGS"\
     CFLAGS="$CFLAGS"\
     LDFLAGS="$LDFLAGS"\
     PREFIX="$PREFIX"\
     BINDIR="$BINDIR"\
     LIBDIR="$LIBDIR"\
     ETCDIR="$ETCDIR"\
     DFLDIR="$DFLDIR"\
     MANDIR="$MANDIR"\
     INCDIR="$INCDIR"\
     $@
