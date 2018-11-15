#!/bin/sh
. $PORTS/mk/config.mk

_portsys_io_error()
{
	echo "$0: <error> $@" 1>&2
	exit 1
}

_portsys_io_message()
{
	echo "$0: <message> $@"
}

_portsys_io_warning()
{
	echo "$0: <warning> $@" 1>&2
}

_portsys_apply_patches()
{
	[ "$#" -lt 2 ] && return 0
	d="$1"
	patches="$2"
	shift 2
	( cd $d
	for p in $patches; do
		patch -p1 < ${PORTS}/patches/$p \
		      || _portsys_io_error failed to apply patch
	done )
}

_portsys_cksum()
{
	[ "$#" -ne 2 ] && return 0
	lsum="$1"
	file="$2"
	[ ! -f "$file" ] && _portsys_io_error ${2}: $file does not exist
	rsum="$(sha512sum $file | $AWK '{print $1}')"
	[ "$rsum" != "$lsum" ] && _portsys_io_error ${2}: checksum mismatch
	true
}

# do not check errors for now, checksum will catch them later
_portsys_fetch()
{
	url=$1
	shift
	protocol="$(printf "%.3s" $url)"
	# for now treat only git as a exception
	case "$protocol" in
	"git")
		d="${name}-$version"
		git clone $url $d
		( cd $d
		v="git-$(git rev-parse HEAD)"
		if [ "$version" != "master" ]; then
			git checkout tags/v$version
		else
			$SED "s/version\:master/version\:$v/g"\
			     $_PORTSYS_CURRENT_PACKAGE\
			     1> ${_PORTSYS_CURRENT_PACKAGE}.new
			mv ${_PORTSYS_CURRENT_PACKAGE}.new\
			   ${_PORTSYS_CURRENT_PACKAGE}
		fi )
	;;
	*)
		$FETCH $url
	;;
	esac
}

_portsys_explode()
{
	n=$1
	shift
	case "$n" in
	*".tar.bz2" | *".tbz2")
		UNCOMPRESS="$BZ2"
	;;
	*".tar.gz" | *".tgz")
		UNCOMPRESS="$GZ"
	;;
	*".tar.lz" | *".tlz")
		UNCOMPRESS="$LZ"
	;;
	*".tar.xz" | *".txz")
		UNCOMPRESS="$XZ"
	;;
	*".tar.zz" | *".tzz")
		UNCOMPRESS="$ZZ"
	;;
	*)
		_portsys_io_warning extension $n is a unknown format
		return 0
	esac
	$UNCOMPRESS -- "$n" | $UNTAR
}

# currently doesn't check for the possibility of passing too many arguments
# to printf, as it's a hard thing to achieve (usually)
_portsys_gendb()
{
	size="$(du -sk .pkgroot | $AWK '{printf "%u", $1*1024}')"
	cat <<-EOF
		name:$name
		version:$version
		license:$license
		description:$description
		size:$size
	EOF
	printf "run-dep:%s\n" $rdeps
	for d in $mdeps; do
		v="$($SED -n 's/version://p' ${DBDIR}/$d 2> /dev/null)" ||\
		  _portsys_io_warning ${name}: failed to obtain $d version
		d="${d}#${v}"
		printf "make-dep:${d}\n"
	done
	dirs="$(find .pkgroot -type d | $SED -e 's/.pkgroot\///g' -e '/.pkgroot/d')"
	printf "dir:%s\n" $dirs
	files="$(find .pkgroot -type f | $SED -e 's/.pkgroot\///g' -e '/.pkgroot/d')"
	printf "file:%s\n" $files
}

_portsys_pack()
{
	export d="${1}/${name}#${version}.$pkgsuf"
	shift
	( cd .pkgroot
	fakeroot -- $TAR . | $COMPRESS > $d )
}
