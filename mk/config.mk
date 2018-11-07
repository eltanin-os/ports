#!/bin/sh
# PORTS ENVIRONMENT
# _C_  = COMPILER
# _LC_ = LIBC
# _OS_ = OPERATING SYSTEM
_MK_PORTS_ENV="-D_MK_C_CLANG -D_MK_LC_MUSL -D_MK_OS_LINUX"

# COMPILE
export CC="cc"
export CXX="c++"
export LD="$CC"
export AR="ar"
export RANLIB="ranlib"

# COMPILE FLAGS
export CPPFLAGS="-D_DEFAULT_SOURCE -D_BSD_SOURCE -D_GNU_SOURCE ${_MK_PORTS_ENV}"
export CFLAGS="-I${PORTS}/mk/inc -Os"
export LDFLAGS="-static"
export LOCALE="en_US.utf8"

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
YACC="yacc -d"
TAR="pax -x ustar -w"
COMPRESS="pigz -z -9"
FETCH="curl -LO"
INSTALL="install"
STRIP="strip --strip-all"
SUM="sha512sum"
NINJA="samu"

# OTHERS
PKGSUF="pkg.tzz"
nprocs="2"
