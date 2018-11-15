#!/bin/sh -a
#

# COMPILE
CC="cc"
CXX="c++"
LD="${CC}"
AR="ar"
RANLIB="ranlib"

# COMPILE FLAGS
CPPFLAGS="-D_DEFAULT_SOURCE -D_BSD_SOURCE -D_GNU_SOURCE"
CFLAGS="-Os"
LDFLAGS="-static"
LOCALE="en_US.utf8"

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
AWK="awk"
SED="sed"
TAR="pax -x ustar -w"
UNTAR="pax -x ustar -r"
COMPRESS="pigz -z -9"
FETCH="curl -LO"
CKSUM="sha512sum"
SU="true"
INSTALL="install"
STRIP="strip"
FETCH="curl -LO"

# UNCOMPRESSION TOOLS
BZ2="bzip2 -dc"
GZ="pigz -dc"
LZ=true"
XZ="true"
ZZ="pigz -dc"

# OTHERS
pkgsuf="pkg.tzz"
nprocs="2"
