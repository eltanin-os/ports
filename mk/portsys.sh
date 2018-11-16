#!/bin/sh
. ${PORTS}/mk/config.mk
. ${PORTS}/mk/common.sh

cleanup()
{
	rm -Rf $bfile $ffile $tmpdir $tsysdir
}

section()
{
	$AWK -v RS="" -v section="\\\[$2\\\]" '$0~section,/\n/' $1 |\
	     $SED "/\[$2\]/d"
}

header()
{
	cat <<-EOF
	#!/bin/sh -e
	. \${PORTS}/mk/config.mk
	. \${PORTS}/mk/common.sh
	EOF
}

start_b_env()
{
	cat <<-EOF
	( _PORTSYS_CURRENT_PACKAGE="$1"
	. \${tmpdir}/\${_PORTSYS_CURRENT_PACKAGE}.vrs
	[ -z "\$src" ] && src="\${name}-\$version"
	cd \$src
	EOF
}

end_b_env()
{
	printf "%s\n\n" ")"
}

start_f_env()
{
	cat <<-EOF
	( _PORTSYS_CURRENT_PACKAGE="$1"
	. \${tmpdir}/\${_PORTSYS_CURRENT_PACKAGE}.vrs
	EOF
}

end_f_env()
{
	cat <<-EOF
	u="\$(printf "%s\n" $mirrors | $AWK '{print \$1}')"
	u="\$(basename "\$u")"
	_portsys_cksum \$cksum \$u
	_portsys_explode \$u
	[ -z "\$src" ] && src="\${name}-\$version"
	_portsys_apply_patches \$src \$patches )
	EOF
	printf "\n\n"
}

start_i_env()
{
	printf "%s "  "("
	printf "export %s\n" $@
}

end_i_env()
{
	cat <<-EOF
	[ -z "\$_PORTSYS_DB_DESTDIR" ] && _PORTSYS_DB_DESTDIR="\$DBDIR"
	dbfile="\${_PORTSYS_DB_DESTDIR}/\$name"
	dbdir="\$(dirname \$dbfile)"
	mkdir -p \$dbdir
	pkgroot="\$(find . -type d -name .pkgroot)"
	if [ -d "\$pkgroot" ]; then
		cd \$(dirname "\$pkgroot")
		_portsys_gendb \$dbdir 1> \$dbfile
		[ "\$_PORTSYS_PKG_GEN" -eq 1 ] &&\
		  _portsys_pack \$_PORTSYS_PKG_DESTDIR
	fi )
	EOF
	printf "\n\n"
}

alias die=_portsys_io_error
alias message=_portsys_io_message

DOPKG=0
DOLOCAL=0

case "$1" in
"opackage")
	DOPKG=1
	DOLOCAL=1
	;;
"package")
	DOPKG=1
	;;
"install")
	;;
*)
	die missing action
	;;
esac

shift
if [ $# -eq 0 ]; then
	message nothing to do
	exit 0
fi

trap cleanup EXIT

bfile=$(mktemp) || die failed to obtain temporary file path for build
ffile=$(mktemp) || die failed to obtain temporary file path for fetch

export bfile ffile tmpdir

message creating headers for files
header 1> $bfile
header 1> $ffile

message setting mode
chmod +x $bfile $ffile

message creating temporary environment
tmpdir=$(mktemp -d) || die failed to create temporary directory
if [ "$DOLOCAL" -eq 1 ]; then
	tsysdir=$(mktemp -d) || die failed to create temporary directory
	cat <<-EOF 1>> $bfile
	export CFLAGS="\$CFLAGS -I${tsysdir}\$INCDIR"
	export LDFLAGS="\$LDFLAGS -L${tsysdir}\$LIBDIR"
	EOF
fi

if [ "$DOPKG" -eq 1 ]; then
	[ -z "$_PORTSYS_PKG_DESTDIR" ] &&\
	  _PORTSYS_PKG_DESTDIR="$(pwd)/__portsys_packages"
	[ -z "$_PORTSYS_DB_DESTDIR" ] &&\
	  _PORTSYS_DB_DESTDIR="$_PORTSYS_PKG_DESTDIR"
	[ ! -d "$_PORTSYS_PKG_DESTDIR" ] &&\
	  mkdir -p "$_PORTSYS_PKG_DESTDIR"
	PKGVARS="$(cat <<-EOF
	_PORTSYS_DB_DESTDIR="$_PORTSYS_DB_DESTDIR"
	_PORTSYS_PKG_DESTDIR="$_PORTSYS_PKG_DESTDIR"
	_PORTSYS_PKG_GEN="$DOPKG"
	DESTDIR="./.pkgroot"
	EOF
	)"
fi

message generating script files
for p in $@; do
	pkg="$(basename $p)"
	message ${pkg}: creating vars file
	( section ${PORTS}/pkg/$p vars | tr '\n' '\t' |
	          sed -e 's/\=/\=\"/g'\
	              -e 's/\t/\"\n/g' 1> "${tmpdir}/${pkg}.vrs"
	patches="$(section ${PORTS}/pkg/$p patches)"
	rdeps="$(section ${PORTS}/pkg/$p rdeps)"
	mdeps="$(section ${PORTS}/pkg/$p mdeps)"
	cat <<-EOF 1>> "${tmpdir}/${pkg}.vrs"
	patches="$patches"
	rdeps="$rdeps"
	mdeps="$mdeps"
	EOF
	)
	message ${pkg}: merging fetch section
	( start_f_env $pkg 1>> $ffile
	mirrors="$(section ${PORTS}/pkg/$p mirrors)"
	printf "_portsys_fetch %s\n" $mirrors 1>> $ffile
	end_f_env 1>> $ffile )
	message ${pkg}: merging build section
	( start_b_env $pkg 1>> $bfile
	section ${PORTS}/pkg/$p build 1>> $bfile
	start_i_env $PKGVARS DESTDIR="$tsysdir" 1>> $bfile
	section ${PORTS}/pkg/$p install 1>> $bfile
	end_i_env 1>> $bfile
	if [ "$DOPKG" -eq 1 ]; then
		start_i_env $PKGVARS 1>> $bfile
		section ${PORTS}/pkg/$p install 1>> $bfile
		end_i_env 1>> $bfile
	fi
	end_b_env 1>> $bfile )
done

message starting fetch process
( cd $tmpdir
$ffile ) || die fetch process failed
message starting build process
( cd $tmpdir
$bfile ) || die build process failed
