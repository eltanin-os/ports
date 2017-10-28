fetch:QV: fetch-git fetch-other

fetch-git:QV:
	if test -n "$GIT"; then
		if test -z "$BRANCH"; then
			BRANCH="master";
		fi
		test -d $SRC || git clone --depth 1 -b $BRANCH $GIT $SRC
	fi

fetch-other:QV:
	rval=1
	pkgsrc=`basename $URL`
	if test -e "$pkgsrc"; then
		cat checksums | $SUM -c && rval=0 || rval=1
	fi
	if test "$rval" -ne "0" && test -n "$URL"; then
		$FETCH $URL
		cat checksums | $SUM -c && rval=0 || rval=1
		if test "$rval" -ne "0"; then
			echo "Package fetching failed" 1>&2
			false
		fi
		if test -e "$pkgsrc"; then
			tar -xf "$pkgsrc"
		fi
	fi

