#!/bin/sh
. ${PORTS}/mk/common.sh

# INFILE
# Internal Install Functions
__install_bin() {
	$INSTALL -dm 755           ${ROOT}$BINDIR
	$STRIP $binaries
	$INSTALL -cm 755 $binaries ${ROOT}$BINDIR
}

__install_inc() {
	$INSTALL -dm 755           ${ROOT}${INCDIR}/$incprefix
	$INSTALL -cm 644 $includes ${ROOT}${INCDIR}/$incprefix
}

__install_lib() {
	$INSTALL -dm 755            ${ROOT}$LIBDIR
	$INSTALL -cm 644 $libraries ${ROOT}$LIBDIR
}

__install_man() {
	for mfile in `eval echo ${manpages}`; do
		mdir="${ROOT}${MANDIR}/man$(printf $mfile | tail -c 1)"
		mfile="${mfile}.gz"
		$INSTALL -dm 755 $mdir
		$INSTALL -cm 644 $mfile $mdir
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
		srcdir   = $srcdir
		outdir   = $outdir
		ar       = $AR
		as       = $AS
		cc       = $CC
		ld       = $LD
		ranlib   = $RANLIB
		cflags   = $CFLAGS
		cppflags = $CPPFLAGS
		ldflags  = $LDFLAGS
		yacc     = $YACC
		yccflags = $YCCFLAGS
	EOF
}

__prepvenv() {
	case "$MK_PACKAGE" in
	bin)
		unset $includes
		unset $libraries
		unset $symlinks
		;;
	dev)
		unset $binaries
		;;
	devman)
		;;
	man)
		;;
	*)
		;;
	esac
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
	__prepvenv

	[ -n "$binaries"  ] && __install_bin
	[ -n "$includes"  ] && __install_inc
	[ -n "$libraries" ] && __install_lib
	[ -n "$manpages"  ] && __install_man
	[ -n "$symlinks"  ] && __install_sym
}

__default_package() {
	rm -rf .pkgroot
	olddir="$(pwd)"
	ROOT="${olddir}/.pkgroot" Install
	[ -n "$VERSION" ] && PKG="${NAME}#${VERSION}" || PKG="$NAME"
	name="${PKG}.${PKGSUF}"
	( cd .pkgroot
	  fakeroot -- $TAR . | $COMPRESS > "${olddir}/${name}" )
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
