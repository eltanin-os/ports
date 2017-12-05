#!/bin/dash

prepare_box() {
	cd $SRC
	CFILES=`ls src/*.c`
	mkdir -p build
	for f in ${CFILES}; do sed "s/^main(/$(echo "$(basename $f .c)" | sed s/-/_/g)_&/" < $f > build/$(basename $f); done
	echo '#include <libgen.h>'                                                                                                                         > build/utilchest.c
	echo '#include <stdio.h>'                                                                                                                          >> build/utilchest.c
	echo '#include <string.h>'                                                                                                                         >> build/utilchest.c
	for f in ${CFILES}; do echo "int $(echo "$(basename $f .c)" | sed s/-/_/g)_main(int, char **);"; done                                              >> build/utilchest.c
	echo 'int main(int argc, char *argv[]) { char *s = basename(argv[0]);'                                                                             >> build/utilchest.c
	echo 'if(!strcmp(s,"utilchest")) { argc--; argv++; s = basename(argv[0]); } if(0) ;'                                                               >> build/utilchest.c
	for f in ${CFILES}; do echo "else if(!strcmp(s, \"$(basename $f .c)\")) return $(echo "$(basename $f .c)" | sed s/-/_/g)_main(argc, argv);"; done  >> build/utilchest.c
	echo 'else { '                                                                                                                                     >> build/utilchest.c
	for f in ${CFILES}; do echo "fputs(\"$(basename $f .c) \", stdout);"; done                                                                         >> build/utilchest.c
	echo 'putchar(0xa); }; return 0; }'                                                                                                                >> build/utilchest.c
}
