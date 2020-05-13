# Makefile for llir-zlib

RANLIB=ranlib

CFLAGS=-O3 -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN
LDFLAGS=
TEST_LDFLAGS=-L. libz.a

STATICLIB=libz.a
ARFLAGS=rc
EXE=

SRCDIR=
ZINC=
ZINCOUT=-I.

OBJZ = adler32.o crc32.o deflate.o infback.o inffast.o inflate.o inftrees.o trees.o zutil.o
OBJG = compress.o uncompr.o gzclose.o gzlib.o gzread.o gzwrite.o
OBJC = $(OBJZ) $(OBJG)
OBJS = $(OBJC)
OBJD = $(OBJS:.o=.lo)

all: libz.a libz.so static all64

static: example$(EXE) minigzip$(EXE)

all64: example64$(EXE) minigzip64$(EXE)

check: test

test: all teststatic test64

teststatic: static
	@TMPST=tmpst_$$; \
	if echo hello world | ./minigzip | ./minigzip -d && ./example $$TMPST ; then \
	  echo '		*** zlib test OK ***'; \
	else \
	  echo '		*** zlib test FAILED ***'; false; \
	fi; \
	rm -f $$TMPST

test64: all64
	@TMP64=tmp64_$$; \
	if echo hello world | ./minigzip64 | ./minigzip64 -d && ./example64 $$TMP64; then \
	  echo '		*** zlib 64-bit test OK ***'; \
	else \
	  echo '		*** zlib 64-bit test FAILED ***'; false; \
	fi; \
	rm -f $$TMP64

libz.a: $(OBJS)
	$(AR) $(ARFLAGS) $@ $^
	-@ ($(RANLIB) $@ || true) >/dev/null 2>&1

libz.so: $(OBJD)
	$(CC) $(LDFLAGS) -shared -o $@ $^

example.o: $(SRCDIR)test/example.c $(SRCDIR)zlib.h zconf.h
	$(CC) $(CFLAGS) $(ZINCOUT) -c -o $@ $(SRCDIR)test/example.c

minigzip.o: $(SRCDIR)test/minigzip.c $(SRCDIR)zlib.h zconf.h
	$(CC) $(CFLAGS) $(ZINCOUT) -c -o $@ $(SRCDIR)test/minigzip.c

example64.o: $(SRCDIR)test/example.c $(SRCDIR)zlib.h zconf.h
	$(CC) $(CFLAGS) $(ZINCOUT) -D_FILE_OFFSET_BITS=64 -c -o $@ $(SRCDIR)test/example.c

minigzip64.o: $(SRCDIR)test/minigzip.c $(SRCDIR)zlib.h zconf.h
	$(CC) $(CFLAGS) $(ZINCOUT) -D_FILE_OFFSET_BITS=64 -c -o $@ $(SRCDIR)test/minigzip.c


%.o: $(SRCDIR)%.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $<

%.lo: $(SRCDIR)%.c
	$(CC) $(CFLAGS) $(ZINC) -c -fPIC -o $@ $<

example$(EXE): example.o $(STATICLIB)
	$(CC) $(CFLAGS) -o $@ example.o $(TEST_LDFLAGS)

minigzip$(EXE): minigzip.o $(STATICLIB)
	$(CC) $(CFLAGS) -o $@ minigzip.o $(TEST_LDFLAGS)

example64$(EXE): example64.o $(STATICLIB)
	$(CC) $(CFLAGS) -o $@ example64.o $(TEST_LDFLAGS)

minigzip64$(EXE): minigzip64.o $(STATICLIB)
	$(CC) $(CFLAGS) -o $@ minigzip64.o $(TEST_LDFLAGS)

clean:
	rm -f *.o *.llir \
		 example$(EXE) minigzip$(EXE) example64$(EXE) minigzip64$(EXE) \
	   libz.* foo.gz

install: libz.a libz.so
	mkdir -p $(PREFIX)/lib
	cp libz.a $(PREFIX)/lib/libz.a
	cp libz.so $(PREFIX)/lib/libz.so
	mkdir -p $(PREFIX)/include
	cp zlib.h $(PREFIX)/include/zlib.h
	cp zconf.h $(PREFIX)/include/zconf.h

adler32.o zutil.o: $(SRCDIR)zutil.h $(SRCDIR)zlib.h zconf.h
gzclose.o gzlib.o gzread.o gzwrite.o: $(SRCDIR)zlib.h zconf.h $(SRCDIR)gzguts.h
compress.o example.o minigzip.o uncompr.o: $(SRCDIR)zlib.h zconf.h
crc32.o: $(SRCDIR)zutil.h $(SRCDIR)zlib.h zconf.h $(SRCDIR)crc32.h
deflate.o: $(SRCDIR)deflate.h $(SRCDIR)zutil.h $(SRCDIR)zlib.h zconf.h
infback.o inflate.o: $(SRCDIR)zutil.h $(SRCDIR)zlib.h zconf.h $(SRCDIR)inftrees.h $(SRCDIR)inflate.h $(SRCDIR)inffast.h $(SRCDIR)inffixed.h
inffast.o: $(SRCDIR)zutil.h $(SRCDIR)zlib.h zconf.h $(SRCDIR)inftrees.h $(SRCDIR)inflate.h $(SRCDIR)inffast.h
inftrees.o: $(SRCDIR)zutil.h $(SRCDIR)zlib.h zconf.h $(SRCDIR)inftrees.h
trees.o: $(SRCDIR)deflate.h $(SRCDIR)zutil.h $(SRCDIR)zlib.h zconf.h $(SRCDIR)trees.h
