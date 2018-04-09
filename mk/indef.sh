#!/bin/sh
. ${PORTS}/mk/common.sh

# INFILE
# Internal Install Functions
__install_bin() {
	$INSTALL -dm  755 ${ROOT}$BINDIR
	$INSTALL -csm 755 $binaries ${ROOT}$BINDIR
}

__install_inc() {
	true
}

__install_lib() {
	$INSTALL -dm  755 ${ROOT}$LIBDIR
	$INSTALL -csm 755 $libraries ${ROOT}$LIBDIR
}

__install_man() {
	for mfile in `eval echo ${manpages}`; do
		mdir="${ROOT}${MANDIR}/man$(printf $mfile | tail -c 1)"
		mfile="${mfile}.gz"
		$INSTALL -dm 755 $mdir
		$INSTALL -cm 755 $mfile $mdir
	done
}

__install_sym() {
	true
}

# Internal Infile Commands
__prepenv() {
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

__default_prepare() {
	test -n "$URL" && __fetch_url
	test -n "$GIT" && __fetch_git
	mkdir -p "$SRC"
	__apply_patches
}

__default_build() {
	cd "$SRC"
	__prepenv  1>  build.ninja
	sh $INFILE 1>> build.ninja
	$NINJA
}

__default_install() {
	cd $SRC
	. $INFILE
	[ -n "$binaries"  ] && __install_bin
	[ -n "$includes"  ] && __install_inc
	[ -n "$libraries" ] && __install_lib
	[ -n "$manpages"  ] && __install_man
	[ -n "$syms"      ] && __install_sym
}

__default_package() {
	rm -rf .pkgroot
	olddir="$(pwd)"
	ROOT="${olddir}/.pkgroot" Install
	[ -n "$VERSION" ] && PKG="${NAME}#${VERSION}" || PKG="$NAME"
	name="${PKG}.${PKGSUF}"
	( cd .pkgroot
	  fakeroot -- tar -c . | $COMPRESS > "${olddir}/${name}" )
	__gendbfile 1> dbfile
	rm -rf .pkgroot
}


# External Commands
Prepare() {
	( __default_prepare )
}

Build() {
	( __default_build )
}

Install() {
	( __default_install )
}

Package() {
	( __default_package )
}
