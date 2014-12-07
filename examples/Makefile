#=====================================================================
# DIRECTORIES
#=====================================================================
#ALL_SUBDIRS	= examples
#SUBDIRS		= $(foreach dir,$(ALL_SUBDIRS), \
#			$(shell test -d $(dir) && echo $(dir)))

XSLDIR          = $(HOME)/import/mathweb/omdoc/xsl

XT		= saxon
SAXON		= saxon
LATEX		= latex
DVIPS		= dvips
XMLPARSE 	= xmlnorm -V -s

OMDOCFILES	= $(basename $(shell ls *.omdoc))
PHXSLFILES	= $(addsuffix -html.xsl,$(OMDOCFILES))
PTXSLFILES	= $(addsuffix -tex.xsl,$(OMDOCFILES))
HTMLFILES	= $(addsuffix .html,$(OMDOCFILES))
TEXFILES	= $(addsuffix .tex,$(OMDOCFILES))
POSTFILES	= $(addsuffix .post,$(OMDOCFILES))
PSFILES		= $(addsuffix .ps,$(OMDOCFILES))
DVIFILES	= $(addsuffix .dvi,$(OMDOCFILES))
CDFILES		= $(addsuffix .ocd,$(OMDOCFILES))
DEFMPFILES	= $(addsuffix .dmp,$(OMDOCFILES))
SIGFILES	= $(addsuffix .sig,$(OMDOCFILES))

#=====================================================================
# RULES
#=====================================================================
#all clean test:: $(SUB_MAKEFILES)
#	dirs="$(SUBDIRS)"; \
#	for i in $$dirs; do \
#	  if (cd $$i && $(MAKE) $@); \
#	  then true; else exit 1; fi; \
#        done
#$(SUBDIRS):: %: %/Makefile
#$(SUBDIRS)::
#	if (cd $@ && $(MAKE)); \
#	then true; else exit 1; fi
#distclean:: clean

all:		$(PHXSLFILES) $(HTMLFILES) $(CDFILES) $(DEFMPFILES) $(SIGFILES) $(PSFILES) 

test:		*.omdoc
		$(XMLPARSE) $<

clean:
		rm -f *.xsl *.aux *.log *.bbl *.blg *.dvi 

$(HTMLFILES): %.html: %.omdoc %-html.xsl $(XSLDIR)/omdoc-html-nice.xsl
		$(XT) $(firstword $<) $(basename $(firstword $<))-html.xsl $@

$(PHXSLFILES): %-html.xsl: %.omdoc $(XSLDIR)/expres.xsl 
		$(SAXON) $(firstword $<) $(XSLDIR)/expres.xsl $@ stylesheet="$(XSLDIR)/omdoc-html-nice.xsl" omdochome="$(OMDOCHOME)" format="html"

$(PTXSLFILES): %-tex.xsl: %.omdoc $(XSLDIR)/expres.xsl 
		$(SAXON) $(firstword $<) $(XSLDIR)/expres.xsl $@ stylesheet="$(XSLDIR)/omdoc2tex.xsl" omdochome="$(OMDOCHOME)" format="TeX"

$(TEXFILES): %.tex: %.omdoc %-tex.xsl $(XSLDIR)/omdoc2tex.xsl 
		$(XT) $(firstword $<) $(basename $(firstword $<))-tex.xsl $@

$(POSTFILES): %.post: %.omdoc $(XSLDIR)/omdoc2post.xsl
		$(XT) $(firstword $<) $(XSLDIR)/omdoc2post.xsl $@

$(DVIFILES): %.dvi: %.tex %.omdoc 
		$(LATEX) $(firstword $<)
		$(LATEX) $(firstword $<)

$(PSFILES): %.ps: %.dvi
		$(DVIPS) -o $@ $<



