# ENV PATH
DBDIR= /var/pkg/local

# COMPILE
CC     = ecc
CXX    = ecc++
LD     = $CC
AR     = ecc-ar
RANLIB = ecc-ranlib

# COMPILE FLAGS
CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE
CFLAGS   =
LDFLAGS  = -Os -static

# COMPILE PATH
PREFIX =
BINDIR = ${PREFIX}/bin
LIBDIR = ${PREFIX}/lib
ETCDIR = ${PREFIX}/etc
DFLDIR = ${ETC}/default
MANDIR = ${PREFIX}/share/man

# TOOLS
FETCH   = curl -LO
INSTALL = install
STRIP   = strip
SUM     = sha512sum

# OTHERS
nprocs = 2
