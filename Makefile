CC      := gcc
CFLAGS  := -std=c99 -O0 -Wall

ARCHIVE  := min-bnf-parser.a
REGEX    := min-regex/min-regex.a
TARGET   := min-bnf-parser.out

ALL_CH  := $(wildcard src/*.c include/*.h)
ALL_BNF := $(wildcard bnf/*)
ALL_O   := $(patsubst src/%.c,object/%.o,$(wildcard src/*.c))
ALL_CH_WITHOUT_MAIN := $(filter-out src/main.c,$(ALL_CH))
ALL_O_WITHOUT_MAIN  := $(filter-out object/main.o,$(ALL_O))

ALL_REGEX_CH := $(filter-out min-regex/src/main.c,$(wildcard min-regex/src/*.c min-regex/include/*.h))

dummy: $(TARGET)

$(ALL_O_WITHOUT_MAIN): $(ALL_CH_WITHOUT_MAIN)
	cd object && $(MAKE) $(patsubst object/%.o,%.o,$@) "CC=$(CC)" "CFLAGS=$(CFLAGS)"

$(ARCHIVE): $(ALL_O_WITHOUT_MAIN)
	ar -r $@ $^

$(REGEX): $(ALL_REGEX_CH)
	cd min-regex && $(MAKE) $(patsubst min-regex/%.a,%.a,$@) "CC=$(CC)" "CFLAGS=$(CFLAGS)"

$(TARGET): $(ARCHIVE) $(REGEX) $(ALL_BNF) src/main.c
	cd object && $(MAKE) main.o "CC=$(CC)" "CFLAGS=$(CFLAGS)"
	$(CC) $(CFLAGS) object/main.o $(ARCHIVE) $(REGEX) -o $@

.PHONY: clean
clean:
	rm -rf *.a *.out *.stackdump *.dot *.png
	cd object && rm -rf *.o *.d
	cd min-regex && $(MAKE) clean
