pkgroot:QV:
	rm -rf .pkgroot
	env -i PATH="$PATH" PORTS="$PORTS" mk install ROOT="$(pwd)/.pkgroot"
	if test -n "$VERSION"; then
		NAME="$NAME#$VERSION"
	fi
	fakeroot -- tar -zcf "${NAME}.pkg.tgz" -C .pkgroot .

dbfile:QV: pkgroot
	size=`du -sk .pkgroot | awk '{printf "%u", $1*1024}'`
	pkgsize=`du -sk $name | awk '{printf "%u", $1*1024}'`
	dirs=`find .pkgroot -type d -print | sed -e 's/.pkgroot\///g' -e 's/.pkgroot//g'`
	files=`find -L .pkgroot -type f -print | sed -e 's/.pkgroot\///g' -e 's/.pkgroot//g'`
	echo "name:$NAME"               >> dbfile
	[ -z "$LONGNAME" ] && LONGNAME=$NAME
	echo "name-long:$LONGNAME"      >> dbfile
	echo "version:$VERSION"         >> dbfile
	echo "license:$LICENSE"         >> dbfile
	echo "description:$DESCRIPTION" >> dbfile
	echo "size:$size"               >> dbfile
	echo "pkgsize:$pkgsize"         >> dbfile
	for d in $RUNDEPS; do
		echo "run-dep:$d" >> dbfile
	done
	for d in $MAKEDEPS; do
		# get package version from dbfile
		d="$d#`grep 'version' ${DBDIR}/$d | sed 's/version://g'`"
		echo "make-dep:$d" >> dbfile
	done
	for d in $dirs; do
		echo "dir:$d" >> dbfile
	done
	for f in $files; do
		echo "file:$f" >> dbfile
	done

package:QV: dbfile
	rm -rf .pkgroot
