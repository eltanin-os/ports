#!/bin/sh
OUTPUT="build.ninja"

#bin(bin, deps...)
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

#sets(var, value)
sets() {
	var="${1}"
	shift
	printf "${var} ="
	for value in ${@}; do
		printf " ${value}"
	done
	printf "\n"
}