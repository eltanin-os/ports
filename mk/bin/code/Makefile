.POSIX:
.SUFFIXES:
.SUFFIXES: .c .o

all: dbman dbread install list

dbman: dbman.o
	$(CC) $(LDFLAGS) -o $@ $< -ltertium
dbread: dbread.o
	$(CC) $(LDFLAGS) -o $@ $< -ltertium
install: install.o
	$(CC) $(LDFLAGS) -o $@ $< -ltertium
list: list.o
	$(CC) $(LDFLAGS) -o $@ $< -ltertium

.c.o:
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<

bootstrap: all
	mv dbman dbread install list ..
