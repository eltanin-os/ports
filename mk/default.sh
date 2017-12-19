#!/bin/sh
# TODO: ORGANIZE 'CDS'
. $PORTS/mk/config.mk

# BACK FUNCS
error() {
	echo "${0}: $1 failed" 1>&2
	exit 1
}

prepenv() {
	[ -z $srcdir ] && srcdir="."
	[ -z $outdir ] && outdir="."
	cat <<-EOF
		include ${PORTS}/mk/rules.ninja
		srcdir=$srcdir
		outdir=$outdir
		ar = $AR
		as = $AS
		cc = $CC
		ld = $LD
		ranlib = $RANLIB
		cflags = $CFLAGS
		cppflags = $CPPFLAGS
		ldflags  = $LDFLAGS
	EOF
}

checksum() {
	test -e "$1" && cat checksums | $SUM -c && rval=0 || rval=1
	return "$rval"
}

gendbfile() {
	size=`du -sk .pkgroot | awk '{printf "%u", $1*1024}'`
	pkgsize=`du -sk ${name} | awk '{printf "%u", $1*1024}'`
	dirs=`find .pkgroot -type d -print | sed -e 's/.pkgroot\///g' -e 's/.pkgroot//g'`
	files=`find -L .pkgroot -type f -print | sed -e 's/.pkgroot\///g' -e 's/.pkgroot//g'`
	cat <<-EOF
		name:$NAME
		version:$VERSION
		license:$LICENSE
		description:$DESCRIPTION
		size:$size
		pkgsize:$pkgsize
	EOF
	for d in $RUNDEPS; do
		printf "run-dep:${d}\n"
	done
	for d in $MAKEDEPS; do
		# get package version from dbfile
		d="${d}#`grep 'version' ${DBDIR}/${d} | sed 's/version://g'`"
		printf "make-dep:${d}\n"
	done
	for d in $dirs; do
		printf "dir:${d}\n"
	done
	for f in $files; do
		printf "file:${f}\n"
	done
}

# MANUAL FUNCS
fetch_git() {
	test -z "$BRANCH" && BRANCH="master"
	test -d "$SRC" || git clone --depth 1 -b "$BRANCH" "$GIT" "$SRC"
}

fetch_url() {
	rval=1
	pkgsrc=`basename $URL`
	checksum "$pkgsrc" && rval=0 || rval=1
	if test "$rval" -ne "0"; then
		$FETCH "$URL"
		checksum "$pkgsrc" || error "fetching"
		tar -xf "$pkgsrc"
	fi
}

apply_patches() {
	cd "$SRC"
	for p in $PATCHES; do
		patch -p1 < $p;
	done
}

# DEFAULT FUNCS
default_prepare() {
	test -n "$URL" && fetch_url
	test -n "$GIT" && fetch_git
	mkdir -p "$SRC"
	apply_patches
}

default_build() {
	cd "$SRC"
	prepenv      1>  build.ninja
	dash $INFILE 1>> build.ninja
	$NINJA
}

default_install() {
	cd $SRC
	. $INFILE
	[ -n "$binaries"  ] && install_bin
	[ -n "$includes"  ] && install_inc
	[ -n "$libraries" ] && install_lib
	[ -n "$manpages"  ] && install_man
	[ -n "$syms"      ] && install_sym
}

default_package() {
	oldpwd=`pwd`
	rm -rf .pkgroot
	ROOT="${oldpwd}/.pkgroot" Install
	[ -n "$VERSION" ] && PKG="${NAME}#${VERSION}" || PKG="$NAME"
	cd "$oldpwd"
	fakeroot -- tar -zcf "${PKG}.pkg.tgz" -C .pkgroot .
	gendbfile 1> dbfile
	rm -rf .pkgroot
}

# INSTALL FUNCS
install_bin() {
	$INSTALL -dm 755 ${ROOT}$BINDIR
	$INSTALL -csm 755 $binaries ${ROOT}$BINDIR
}

install_inc() {
	true
}

install_lib() {
	$INSTALL -dm 755 ${ROOT}$LIBDIR
	$INSTALL -csm 755 $libraries ${ROOT}$LIBDIR
}

install_man() {
	for mfile in `eval echo ${manpages}`; do
		mdir="${ROOT}${MANDIR}/man$(printf $mfile | tail -c 1)"
		mfile="${mfile}.gz"
		$INSTALL -dm 755 $mdir
		$INSTALL -cm 755 $mfile $mdir
	done
}

install_sym() {
	true
}
