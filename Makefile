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

all: static all64

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
	$(AR) $(ARFLAGS) $@ $(OBJS)
	-@ ($(RANLIB) $@ || true) >/dev/null 2>&1

example.o: $(SRCDIR)test/example.c $(SRCDIR)zlib.h zconf.h
	$(CC) $(CFLAGS) $(ZINCOUT) -c -o $@ $(SRCDIR)test/example.c

minigzip.o: $(SRCDIR)test/minigzip.c $(SRCDIR)zlib.h zconf.h
	$(CC) $(CFLAGS) $(ZINCOUT) -c -o $@ $(SRCDIR)test/minigzip.c

example64.o: $(SRCDIR)test/example.c $(SRCDIR)zlib.h zconf.h
	$(CC) $(CFLAGS) $(ZINCOUT) -D_FILE_OFFSET_BITS=64 -c -o $@ $(SRCDIR)test/example.c

minigzip64.o: $(SRCDIR)test/minigzip.c $(SRCDIR)zlib.h zconf.h
	$(CC) $(CFLAGS) $(ZINCOUT) -D_FILE_OFFSET_BITS=64 -c -o $@ $(SRCDIR)test/minigzip.c


adler32.o: $(SRCDIR)adler32.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)adler32.c

crc32.o: $(SRCDIR)crc32.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)crc32.c

deflate.o: $(SRCDIR)deflate.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)deflate.c

infback.o: $(SRCDIR)infback.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)infback.c

inffast.o: $(SRCDIR)inffast.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)inffast.c

inflate.o: $(SRCDIR)inflate.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)inflate.c

inftrees.o: $(SRCDIR)inftrees.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)inftrees.c

trees.o: $(SRCDIR)trees.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)trees.c

zutil.o: $(SRCDIR)zutil.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)zutil.c

compress.o: $(SRCDIR)compress.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)compress.c

uncompr.o: $(SRCDIR)uncompr.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)uncompr.c

gzclose.o: $(SRCDIR)gzclose.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)gzclose.c

gzlib.o: $(SRCDIR)gzlib.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)gzlib.c

gzread.o: $(SRCDIR)gzread.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)gzread.c

gzwrite.o: $(SRCDIR)gzwrite.c
	$(CC) $(CFLAGS) $(ZINC) -c -o $@ $(SRCDIR)gzwrite.c


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

install: libz.a
	mkdir -p $(PREFIX)/lib
	cp libz.a $(PREFIX)/lib/libz.a
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
