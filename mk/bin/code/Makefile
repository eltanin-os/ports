include config.mk

.SUFFIXES:
.SUFFIXES: .o .c

# BIN
BIN=\
	dbman\
	install\
	list

# ALL
OBJ=$(BIN:=.o)

# VAR RULES
all: $(BIN)

$(BIN): $(@:=.o)
$(OBJ): config.mk

# SUFFIX RULES
.o:
	$(CC) $(LDFLAGS) -o $@ $< $(LDLIBS)

.c.o:
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<

# USER ACTIONS
bootstrap: all
	mv $(BIN) ..

clean:
	rm -f $(BIN) $(OBJ)

.PHONY:
	all clean
