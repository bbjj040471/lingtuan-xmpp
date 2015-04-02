# $Id: Makefile.in 2842 2009-12-29 19:10:52Z badlop $

CC = gcc
CFLAGS = -g -O2 -Wall 
CPPFLAGS = -I/usr/local/ssl/include -g -O2 -Wall 
LDFLAGS = 
LIBS = 

ASN_FLAGS = -bber_bin +optimize

ERLANG_CFLAGS = -I/usr/local/erlang/lib/erlang/lib/erl_interface-3.7.11/include -I/usr/local/erlang/lib/erlang/usr/include
ERLANG_LIBS = -L/usr/local/erlang/lib/erlang/lib/erl_interface-3.7.11/lib -lerl_interface -lei

EFLAGS += -DSSL40
EFLAGS += -I ..
EFLAGS += -pz ..

# make debug=true to compile Erlang module with debug informations.
ifdef debug
	EFLAGS+=+debug_info +export_all
endif

OUTDIR = ..
SOURCES = $(wildcard *.erl) ELDAPv3.erl eldap_filter_yecc.erl
BEAMS = $(addprefix $(OUTDIR)/,$(SOURCES:.erl=.beam))


all:    $(BEAMS) ELDAPv3.beam eldap_filter_yecc.beam

ELDAPv3.beam: ELDAPv3.erl

ELDAPv3.erl:       ELDAPv3.asn
	/usr/local/erlang/bin/erlc $(ASN_FLAGS) -W $(EFLAGS) $<

eldap_filter_yecc.beam: eldap_filter_yecc.erl

eldap_filter_yecc.erl: eldap_filter_yecc.yrl
	/usr/local/erlang/bin/erlc -W $<

$(OUTDIR)/%.beam:	%.erl ELDAPv3.erl eldap_filter_yecc.erl
	/usr/local/erlang/bin/erlc -W $(EFLAGS) -o $(OUTDIR) $<

clean:
	rm -f ELDAPv3.asn1db
	rm -f ELDAPv3.erl
	rm -f ELDAPv3.hrl
	rm -f ELDAPv3.beam
	rm -f eldap_filter_yecc.erl
	rm -f eldap_filter_yecc.beam
	rm -f $(BEAMS)

distclean: clean
	rm -f Makefile

TAGS:
	etags *.erl

