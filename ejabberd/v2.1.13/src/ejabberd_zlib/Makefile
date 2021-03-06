# $Id$

CC = gcc
CFLAGS = -g -O2 -Wall 
CPPFLAGS = -I/usr/local/ssl/include -g -O2 -Wall 
LDFLAGS = 
LIBS = 

ZLIB_CFLAGS = 
ZLIB_LIBS =  -lz

ERLANG_CFLAGS = -I/usr/local/erlang/lib/erlang/lib/erl_interface-3.7.11/include -I/usr/local/erlang/lib/erlang/usr/include
ERLANG_LIBS = -L/usr/local/erlang/lib/erlang/lib/erl_interface-3.7.11/lib -lerl_interface -lei

# Assume Linux-style dynamic library flags
DYNAMIC_LIB_CFLAGS = -fpic -shared
ifeq ($(shell uname),Darwin)
    DYNAMIC_LIB_CFLAGS = -fPIC -bundle -flat_namespace -undefined suppress
endif
ifeq ($(shell uname),SunOs)
    DYNAMIC_LIB_CFLAGS = -KPIC -G -z text
endif

EFLAGS += -I ..
EFLAGS += -pz ..

# make debug=true to compile Erlang module with debug informations.
ifdef debug
	EFLAGS+=+debug_info +export_all
endif

ERLSHLIBS = ../ejabberd_zlib_drv.so
OUTDIR = ..
SOURCES = $(wildcard *.erl)
BEAMS = $(addprefix $(OUTDIR)/,$(SOURCES:.erl=.beam))

all:    $(BEAMS) $(ERLSHLIBS)

$(OUTDIR)/%.beam:       %.erl
	/usr/local/erlang/bin/erlc -W $(EFLAGS) -o $(OUTDIR) $<

#all:	$(ERLSHLIBS)
#	erl -s make all report "{outdir, \"..\"}" -noinput -s erlang halt

$(ERLSHLIBS):	../%.so:	%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) \
		$(subst ../,,$(subst .so,.c,$@)) \
		$(LIBS) \
		$(ZLIB_LIBS) \
		$(ZLIB_CFLAGS) \
		$(ERLANG_LIBS) \
		$(ERLANG_CFLAGS) \
		-o $@ \
		$(DYNAMIC_LIB_CFLAGS)

clean:
	rm -f $(BEAMS) $(ERLSHLIBS)

distclean: clean
	rm -f Makefile

TAGS:
	etags *.erl
