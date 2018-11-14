#!/bin/sh
. ${PORTS}/mk/config.mk
. ${PORTS}/mk/common.sh

die()
{
	echo "$0: <error> $@" 1>&2
	exit 1
}

warning()
{
	echo "$0: <warning> $@" 1>&2
}

message()
{
	echo "$0: <message> $@"
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
	. \${tmpdir}/\$_PORTSYS_CURRENT_PACKAGE
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
	. \${tmpdir}/\$_PORTSYS_CURRENT_PACKAGE
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

bfile=$(mktemp -u)  || die failed to obtain temporary file path for build
ffile=$(mktemp -u)  || die failed to obtain temporary file path for fetch
ifile=$(mktemp -u)  || die failed to obtain temporary file path for install

export bfile ffile ifile tmpdir

message creating headers for files
header 1> $bfile
header 1> $ffile
header 1> $ifile

message setting mode
chmod +x $bfile $ffile $ifile

message creating temporary environment
tmpdir=$(mktemp -d) || die failed to create temporary directory
if [ "$DOLOCAL" -eq 1 ]; then
	tsysdir=$(mktemp -d)       || die failed to create temporary directory
	mkdir -p ${tsysdir}/$DBDIR || die failed to create temporary directory
fi

message generating script files
for p in $@; do
	pkg="$(basename $p)"
	message ${pkg}: creating vars file
	( section ${PORTS}/pkg/$p vars | tr '\n' '\t' |
	          sed -e 's/\=/\=\"/g' -e 's/\t/\"\n/g' 1> "${tmpdir}/$pkg"
	patches="$(section ${PORTS}/pkg/$p patches)"
	rdeps="$(section ${PORTS}/pkg/$p rdeps)"
	mdeps="$(section ${PORTS}/pkg/$p mdeps)"
	cat <<-EOF 1>> "${tmpdir}/$pkg"
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
	end_b_env 1>> $bfile )
	message ${pkg}: merging install section
	( start_b_env $pkg 1>> $ifile
	section ${PORTS}/pkg/$p install 1>> $ifile
	cat <<-EOF 1>> $ifile
	dbfile="\${name}.portsys.dbfile"
	[ -f "\$dbfile" ] && mv \$dbfile \${DBDIR}/\${name}
	if [ "\$_PORTSYS_LOCAL_INST" -eq 1 ]; then
		_portsys_gendb 1> \$dbfile
		[ "\$_PORTSYS_PKG_GEN" -eq 1 ] && _portsys_pack
	fi
	EOF
	end_b_env 1>> $ifile )
done

message starting fetch process
( cd ${tmpdir}
$ifile ) || die fetch process failed
message starting build process
( cd ${tmpdir}
$bfile ) || die build process failed
message starting install process
if [ "$DOLOCAL" -eq 0 ]; then
	message using real system
	$SU '( cd ${tmpdir}
	${ifile} )'
else
	message using temporary system
	( cd ${tmpdir}
	env DESTDIR=${tsysdir} _PORTSYS_PKG_GEN=$DOPKG $ifile )
fi
message starting database file generation process
( cd ${tmpdir}
env DESTDIR=./.pkgroot _PORTSYS_LOCAL_INST=1 _PORTSYS_PKG_GEN=$DOPKG $ifile )
