#!/bin/sh
# TODO: ORGANIZE 'CDS'
. $PORTS/mk/config.mk
. $PORTS/mk/install.sh

# BACK FUNCS
error() {
	echo "$0: $1 failed" 1>&2
	exit 1
}

checksum() {
	test -e "$1" && cat checksums | $SUM -c && rval=0 || rval=1
	return "$rval"
}

getval() {
	cd $SRC
	$INTERPRES -p $1 $INFILE
}

gendbfile() {
	rm dbfile
	size=`du -sk .pkgroot | awk '{printf "%u", $1*1024}'`
	pkgsize=`du -sk $name | awk '{printf "%u", $1*1024}'`
	dirs=`find .pkgroot -type d -print | sed -e 's/.pkgroot\///g' -e 's/.pkgroot//g'`
	files=`find -L .pkgroot -type f -print | sed -e 's/.pkgroot\///g' -e 's/.pkgroot//g'`
	echo "name:$NAME"               >> dbfile
	[ -z "$LONGNAME" ] && LONGNAME=$NAME
	echo "name-long:$LONGNAME"      >> dbfile
	echo "version:$VERSION"         >> dbfile
	echo "license:$LICENSE"         >> dbfile
	echo "description:$DESCRIPTION" >> dbfile
	echo "size:$size"               >> dbfile
	echo "pkgsize:$pkgsize"         >> dbfile
	for d in $RUNDEPS; do
		echo "run-dep:$d" >> dbfile
	done
	for d in $MAKEDEPS; do
		# get package version from dbfile
		d="$d#`grep 'version' ${DBDIR}/$d | sed 's/version://g'`"
		echo "make-dep:$d" >> dbfile
	done
	for d in $dirs; do
		echo "dir:$d" >> dbfile
	done
	for f in $files; do
		echo "file:$f" >> dbfile
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
	$INTERPRES $INFILE
	$NINJA
}

# TODO: REMOVE SED WHEN INTERPRES REPLACE "$outdir"
default_install() {
	BINS=`getval -b | sed 's/\$outdir/\./g'`
	LIBS=`getval -l | sed 's/\$outdir/\./g'`
	MANS=`getval -m | sed 's/\$outdir/\./g'`
	for arg in "$@"; do
		unset ${arg}
	done
	cd $SRC
	[ -n "$BINS" ] && install_bin
	[ -n "$INCS" ] && install_inc
	[ -n "$LIBS" ] && install_lib
	[ -n "$MANS" ] && install_man
	[ -n "$SYMS" ] && install_sym
}

default_package() {
	oldpwd=`pwd`
	rm -rf .pkgroot
	ROOT="$oldpwd/.pkgroot" Install
	[ -n "$VERSION" ] && NAME="$NAME#$VERSION"
	cd $oldpwd
	fakeroot -- tar -zcf "${NAME}.pkg.tgz" -C .pkgroot .
	gendbfile
	rm -rf .pkgroot
}
