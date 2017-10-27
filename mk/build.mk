<| cat $PORTS/mk/config.mk

all:QV: build

build:QV: fetch patch
	oldpwd=`pwd`
	mkdir -p $SRC
	cd $SRC
	for f in $MKFILE; do
		cachefile="${oldpwd}/.cache-$(basename $f)"
		status=`cmp -s $f $cachefile || echo -n $?`
		if test -n "$status"; then
			env -i PATH="$PATH" PORTS="$PORTS"\
			    mk -f $f build
			cp $f $cachefile
		fi
	done

patch:QV: fetch
	mkdir -p $SRC
	cd $SRC
	for p in $PATCHES; do
		patch -p1 < $p;
	done

install:QV: all
	cd $SRC
	for f in $MKFILE; do
		env -i PATH="$PATH" PORTS="$PORTS"\
		    mk -f $f install ROOT="$ROOT"
	done

clean:QV:
	cd $SRC
	for f in $MKFILE; do
		env -i PATH="$PATH" PORTS="$PORTS"\
		    mk -f $f clean
	done

distclean:QV:
	if test -d $SRC; then
		rm -rf $SRC dbfile
		rm -rf *.pkg.tgz *.tar.gz
		rm -rf .cache*
	fi

<$PORTS/mk/fetch.mk
<$PORTS/mk/package.mk
