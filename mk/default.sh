#!/bin/sh
. $PORTS/mk/config.mk

# BACK FUNCS
error() {
	echo "$0: $1 failed" 1>&2
	exit 1
}

checksum() {
	test -e "$1" && cat checksums | $SUM -c && rval=0 || rval=1
	return "$rval"
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
