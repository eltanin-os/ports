#!/bin/sh
OUTPUT="build.ninja"

#bin(bin, num, deps...)
bin() {
	binary="${1}"
	ldlibs=`echo ${ldlibs} | tr '\n' ' '`
	shift
	printf "build \${outdir}/${binary}: link"
	for dep in ${@}; do
		printf " \${outdir}/${dep}.o"
	done
	printf " ${ldlibs}\n"
	for dep in ${@}; do
		printf "build \${outdir}/${dep}.o: cc \${srcdir}/${dep}\n"
	done
}

#bins(bins...)
bins() {
	ldlibs=`echo ${ldlibs} | tr '\n' ' '`
	for binary in ${@}; do
		printf "build \${outdir}/${binary}: link  "
		printf "\${outdir}/${binary}.c.o ${ldlibs}\n"
		printf "build \${outdir}/${binary}.c.o:   "
		printf "cc \${srcdir}/${binary}.c\n"
	done
}

#mbin(bins, deps...)
mbin() {
	binary="${1}"
	ldlibs=`echo ${ldlibs} | tr '\n' ' '`
	shift
	printf "build \${outdir}/${binary}: link"
	for dep in ${@}; do
		printf " \${outdir}/${dep}.o"
	done
	printf " ${ldlibs}\n"
}

#copy(src, dest)
copy() {
	printf "build \${outdir}/${1}: copy \${srcdir}/${2}\n"
}

#lib(lib, deps...)
lib() {
	library="${1}"
	shift
	printf "build \${outdir}/${library}: ar"
	for dep in ${@}; do
		printf " \${outdir}/${dep}.o";
	done
	printf "\n"
	for dep in ${@}; do
		printf "build \${outdir}/${dep}.o: cc \${srcdir}/${dep}\n"
	done
	printf "build \${outdir}/${library}.d: lines \${outdir}/${library}\n"
}

#mans(mans...)
mans() {
	for man in ${@}; do
		printf "build \${outdir}/${man}.gz: gzip \${srcdir}/${man}\n"
	done
}

#objs(objs...)
objs() {
	objs=`printf "%s\n" ${@} | sort | uniq`
	for obj in ${objs}; do
		printf "build \${outdir}/${obj}.o: cc \${srcdir}/${obj}\n"
	done
}

#sets(var, value)
sets() {
	var="${1}"
	shift
	printf "${var} ="
	printf " %s" ${@}
	printf "\n"
}

#yacc()
yacc() {
	printf "build \${outdir}/${2}: yacc \${srcdir}/${1}\n"
}

#auto()
auto() {
	[ -n "$cflags"   ] && sets cflags   "\$cflags   $cflags"
	[ -n "$cppflags" ] && sets cppflags "\$cppflags $cppflags"
	[ -n "$ldflags"  ] && sets ldflags  "\$ldflags  $ldflags"
}
