#!/bin/sh
. $PORTS/mk/config.mk

__common_warning() {
	echo "$0: <warning> $@" 1>&2
}

_portsys_apply_patches()
{
	true
}

_portsys_cksum()
{
	true
}

_portsys_fetch()
{
	true
}

_portsys_gendb()
{
	cat <<-EOF
		name:$name
		version:$version
		license:$license
		description:$description
		size:size
	EOF
	printf "run-dep:%s\n" $rdeps
	for d in $mdeps; do
		v="$($SED -n 's/version://p' ${DBDIR}/$d 2> /dev/null)" ||\
		  __common_warning ${name}: failed to obtain $d version
		d="${d}#${v}"
		printf "make-dep:${d}\n"
	done
}
