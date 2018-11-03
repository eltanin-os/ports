#!/bin/sh
. $PORTS/mk/config.mk

# BACK FUNCS
__error() {
	echo "${0}: $1 failed" 1>&2
	exit 1
}

__checksum() {
	test -e "$1" && cat checksums | $SUM -c && rval=0 || rval=1
	return "$rval"
}

__gendbfile() {
	size=`du -sk .pkgroot | awk '{printf "%u", $1*1024}'`
	pkgsize=`du -sk ${name} | awk '{printf "%u", $1*1024}'`
	dirs=`find .pkgroot -type d -print | sed -e 's/.pkgroot\///g' -e 's/.pkgroot//g'`
	files=`find -L .pkgroot -type f -print | sed -e 's/.pkgroot\///g' -e 's/.pkgroot//g'`
	[ "$VERSION" == "master" ] && VERSION="$(cat ._mk_v)"
	rm -f ._mk_v
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
__fetch_git() {
	if [ ! -d "$SRC" ]; then
		git clone "$GIT" "$SRC"
		( cd "$SRC"
		[ "$VERSION" == "master" ] || git checkout tags/v${VERSION} \
		  && printf "git-$(git rev-parse HEAD)" > ../._mk_v )
	fi
}

__fetch_url() {
	rval=1
	pkgsrc=`basename $URL`
	__checksum checksum "$pkgsrc" && rval=0 || rval=1
	if test "$rval" -ne "0"; then
		$FETCH "$URL"
		__checksum "$pkgsrc" || __error "fetching"
		tar -xf "$pkgsrc"
	fi
}

__apply_patches() {
	cd "$SRC"
	for p in $PATCHES; do
		patch -p1 < $p;
	done
}
