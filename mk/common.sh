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
	shift 1
	( cd $d
	for p in $@; do
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
		( olddir="$(pwd)"
		cd $d
		if [ "$version" != "master" ]; then
			git checkout tags/v$version
		else
			v="git-$(git rev-parse HEAD)"
			n="${_PORTSYS_CURRENT_PACKAGE}.vrs"
			$SED "s/version\=\"master\"/version\=\"${v}\"/g"\
			     ${olddir}/$n 1> ${olddir}/${n}.new
			cd "$olddir"
			mv ${n}.new $n
			mv $d "${name}-$v"
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
	dbdir="$1"
	shift
	size="$(du -sk .pkgroot | $AWK '{printf "%u", $1*1024}')"
	cat <<-EOF
		name:$name
		version:$version
		license:$license
		description:$description
		size:$size
	EOF
	[ -n "$rdeps" ] && printf "run-dep:%s\n" $rdeps
	for d in $mdeps; do
		v="$($SED -n 's/version://p' ${dbdir}/$d 2> /dev/null)" ||\
		  _portsys_io_warning ${name}: failed to obtain $d version
		d="${d}#${v}"
		printf "make-dep:${d}\n"
	done
	dirs="$(find .pkgroot -type d | $SED -e 's/.pkgroot\///g' -e '/.pkgroot/d')"
	printf "dir:%s\n" $dirs
	files="$(find .pkgroot -type f -o -type l | $SED -e 's/.pkgroot\///g' -e '/.pkgroot/d')"
	printf "file:%s\n" $files
}

_portsys_pack()
{
	export d="${1}/${name}#${version}.$pkgsuf"
	shift
	( cd .pkgroot
	fakeroot -- $TAR . | $COMPRESS > $d )
}
