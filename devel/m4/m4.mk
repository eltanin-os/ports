<| cat $PORTS/mk/config.mk

BINS  = m4
MANS  = m4.1

OBJS  =\
	eval.o\
	expr.o\
	look.o\
	main.o\
	misc.o\
	gnum4.o\
	trace.o

<$PORTS/mk/mk.build

m4: $OBJS
	$CC $LDFLAGS -o $target $prereq
