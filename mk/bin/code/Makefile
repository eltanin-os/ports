.POSIX:
.SUFFIXES:
.SUFFIXES: .c .o

all: dbman install list

dbman: dbman.o
	$(CC) $(LDFLAGS) -o $@ $< -ltertium
install: install.o
	$(CC) $(LDFLAGS) -o $@ $< -ltertium
list: list.o
	$(CC) $(LDFLAGS) -o $@ $< -ltertium

.c.o:
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<

bootstrap: all
	mv dbman install list ..
