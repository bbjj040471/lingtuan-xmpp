# $Id$

CC = gcc
CFLAGS = -g -O2 -Wall 
CPPFLAGS = -I/usr/local/ssl/include -g -O2 -Wall 
LDFLAGS = 
LIBS = 

ERLANG_CFLAGS = -I/usr/local/erlang/lib/erlang/lib/erl_interface-3.7.11/include -I/usr/local/erlang/lib/erlang/usr/include
ERLANG_LIBS = -L/usr/local/erlang/lib/erlang/lib/erl_interface-3.7.11/lib -lerl_interface -lei

EFLAGS += -I ..
EFLAGS += -pz ..

# make debug=true to compile Erlang module with debug informations.
ifdef debug
	EFLAGS+=+debug_info +export_all
endif

OUTDIR = ..
ERLBEHAVS = gen_pubsub_node.erl gen_pubsub_nodetree.erl
SOURCES_ALL = $(wildcard *.erl)
SOURCES = $(filter-out $(ERLBEHAVS),$(SOURCES_ALL))
ERLBEHAVBEAMS = $(addprefix $(OUTDIR)/,$(ERLBEHAVS:.erl=.beam))
BEAMS = $(addprefix $(OUTDIR)/,$(SOURCES:.erl=.beam))


all: mod_pubsub_odbc.erl $(ERLBEHAVBEAMS) $(BEAMS)

$(BEAMS): $(ERLBEHAVBEAMS)

$(OUTDIR)/%.beam:       %.erl
	/usr/local/erlang/bin/erlc -W $(EFLAGS) -o $(OUTDIR) $<

clean:
	rm -f $(BEAMS)

distclean: clean
	rm -f Makefile

mod_pubsub_odbc.erl:
	patch -o mod_pubsub_odbc.erl mod_pubsub.erl pubsub_odbc.patch

TAGS:
	etags *.erl

