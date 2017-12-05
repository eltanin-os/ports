# TODO: ORGANIZE 'CDS'\
. $PORTS/mk/config.mk

# BACK FUNCS
error() {
	echo "$0: $1 failed" 1>&2
	exit 1
}

prepenv() {
	[ -z $srcdir ] && srcdir="."
	[ -z $outdir ] && outdir="."
	printf "include ${PORTS}/mk/rules.ninja\n"
	printf "srcdir=$srcdir\n"
	printf "outdir=$outdir\n"
	printf "ar = ${AR}\n"
	printf "as = ${AS}\n"
	printf "cc = ${CC}\n"
	printf "ld = ${LD}\n"
	printf "ranlib = ${RANLIB}\n"
	printf "cflags = ${CFLAGS}\n"
	printf "cppflags = ${CPPFLAGS}\n"
}

checksum() {
	test -e "$1" && cat checksums | $SUM -c && rval=0 || rval=1
	return "$rval"
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
	prepenv      1>> build.ninja
	dash $INFILE 1>> build.ninja
	$NINJA
}

# TODO: FIX INSTALL
default_install() {
	cd $SRC
	[ -n "$bins"     ] && install_bin
	[ -n "$incs"     ] && install_inc
	[ -n "$libs"     ] && install_lib
	[ -n "$manpages" ] && install_man
	[ -n "$syms"     ] && install_sym
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

# INSTALL FUNCS
install_bin() {
	$INSTALL -dm 755 ${ROOT}$BINDIR
	$INSTALL -csm 755 $BINS ${ROOT}$BINDIR
}

install_inc() {
	true
}

install_lib() {
	$INSTALL -dm 755 ${ROOT}$LIBDIR
	$INSTALL -csm 755 $LIBS ${ROOT}$LIBDIR
}

install_man() {
	for mfile in "${MANS}"; do
		man=`basename $mfile .gz`
		mdir="${ROOT}$MANDIR/man$(echo -n $man | tail -c 1)"
		$INSTALL -dm 755 $mdir
		$INSTALL -csm 755 $man $mdir
	done
}

install_sym() {
	true
}
