fetch:QV: fetch-git fetch-other

fetch-git:QV:
	if test -n "$GIT"; then
		if test -z "$BRANCH"; then
			BRANCH="master";
		fi
		test -d $SRC || git clone --depth 1 -b $BRANCH $GIT $SRC
	fi

fetch-other:QV:
	rval=""
	pkgsrc=`basename $URL`
	if test -e "$pkgsrc"; then
		rval=`cat checksums | $SUM -c || echo -n $?`
	fi
	if test -z "$rval" && test -n "$URL"; then
		$FETCH $URL
		rval=`cat checksums | $SUM -c || echo -n $?`
		if test -e "$pkgsrc"; then
			tar -xf "$pkgsrc"
		fi
		if test -z "$rval"; then
			echo "Package fetching failed" 1>&2
			false
		fi
	fi

