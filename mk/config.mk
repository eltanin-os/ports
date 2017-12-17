#!/bin/sh

# COMPILE
export CC="ecc"
export CXX="ecc++"
export LD="$CC"
export AR="ecc-ar"
export RANLIB="ecc-ranlib"

# COMPILE FLAGS
export CPPFLAGS="-D_DEFAULT_SOURCE -D_BSD_SOURCE"
export CFLAGS="-Os -std=c99 -pedantic"
export LDFLAGS="-static"

# ENV PATH
DBDIR="/var/pkg/local"

# COMPILE PATH
PREFIX=""
BINDIR="${PREFIX}/bin"
LIBDIR="${PREFIX}/lib"
ETCDIR="${PREFIX}/etc"
DFLDIR="${ETC}/default"
MANDIR="${PREFIX}/share/man"
INCDIR="${PREFIX}/include"

# TOOLS
INTERPRES="interpres"
FETCH="curl -LO"
INSTALL="/usr/bin/install"
STRIP="strip"
SUM="sha512sum"
NINJA="samu"

# OTHERS
nprocs="2"
