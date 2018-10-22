#!/bin/sh
. ${PORTS}/mk/common.sh

__default_prepare() {
	test -n  "$URL" && __fetch_url
	test -n  "$GIT" && __fetch_git
	mkdir -p "$SRC"
	__apply_patches
}

__default_build() {
	cd    "$SRC"
	mkdir build
	cd    build

	case "$LDFLAGS" in
	*"-static"*)
		static=yes
		shared=no
		;;
	*)
		static=no
		shared=yes
		;;
	esac

	[ -n "$PREFIX" ] || PREFIX="/"
	../configure --prefix="$PREFIX"        \
	             --bindir="$BINDIR"        \
	             --sbindir="$BINDIR"       \
	             --libdir="$LIBDIR"        \
	             --includedir="$INCDIR"    \
	             --oldincludedir="$INCDIR" \
	             --datarootdir="$PREFIX"   \
	             --mandir="$MANDIR"        \
	             --enable-shared="$shared" \
	             --enable-static="$static"

	make
}

__default_install() {
	[ -n "$ROOT" ] || ROOT="/"
	env DESTDIR="$ROOT" make install
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
