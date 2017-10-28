# ENV PATH
DBDIR= /var/pkg/local

# COMPILE
CC     = cc
CXX    = c++
LD     = $CC
AR     = ar
RANLIB = ranlib

# COMPILE FLAGS
CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE
CFLAGS   = -std=c99 -pedantic
LDFLAGS  = -Os -static

# COMPILE PATH
PREFIX =
USRDIR = ${PREFIX}/usr
BINDIR = ${PREFIX}/bin
LIBDIR = ${PREFIX}/lib
ETCDIR = ${PREFIX}/etc
DFLDIR = ${ETC}/default
MANDIR = ${USRDIR}/share/man

# TOOLS
FETCH   = curl -LO
INSTALL = /usr/bin/install
STRIP   = strip
SUM     = sha512sum

# OTHERS
nprocs = 2
