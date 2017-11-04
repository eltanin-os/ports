# COMPILE
export CC="cc"
export CXX="c++"
export LD="$CC"
export AR="ar"
export RANLIB="ranlib"

# COMPILE FLAGS
export CPPFLAGS="-D_DEFAULT_SOURCE -D_BSD_SOURCE"
export CFLAGS="$CPPFLAGS -std=c99 -pedantic"
export LDFLAGS="-Os -static"

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
