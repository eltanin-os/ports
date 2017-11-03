# ENV PATH
DBDIR= /var/pkg/local

# COMPILE
CC     = ecc
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
BINDIR = ${PREFIX}/bin
LIBDIR = ${PREFIX}/lib
ETCDIR = ${PREFIX}/etc
DFLDIR = ${ETC}/default
MANDIR = ${PREFIX}/share/man
INCDIR = ${PREFIX}/include

# TOOLS
INTERPRES = interpres
FETCH     = curl -LO
INSTALL   = /usr/bin/install
STRIP     = strip
SUM       = sha512sum
NINJA     = samu

# OTHERS
nprocs = 2
