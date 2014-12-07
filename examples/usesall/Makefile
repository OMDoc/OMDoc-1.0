XSLDIR          = $(HOME)/import/mathweb/omdoc/xsl

XT		= saxon
SAXON		= saxon
LATEX		= latex
DVIPS		= dvips
XMLPARSE 	= nsgmls -wxml -s

OMDOCFILES	= $(basename $(shell ls *.omdoc))
PHXSLFILES	= $(addsuffix -html.xsl,$(OMDOCFILES))
PTXSLFILES	= $(addsuffix -tex.xsl,$(OMDOCFILES))
HTMLFILES	= $(addsuffix .html,$(OMDOCFILES))
TEXFILES	= $(addsuffix .tex,$(OMDOCFILES))
PSFILES		= $(addsuffix .ps,$(OMDOCFILES))
DVIFILES	= $(addsuffix .dvi,$(OMDOCFILES))

all:		$(PHXSLFILES) $(HTMLFILES) $(PTXSLFILES) $(PSFILES)

clean:
		rm -f *.xsl *.aux *.log *.bbl *.blg *.dvi 

test:		*.omdoc
		$(XMLPARSE) $<

$(PHXSLFILES): %-html.xsl: %.omdoc $(XSLDIR)/expres.xsl 
		$(SAXON) $(firstword $<) $(XSLDIR)/expres.xsl $@ stylesheet="$(XSLDIR)/omdoc-html-nice.xsl" omdochome="$(OMDOCHOME)" format="html"

$(PTXSLFILES): %-tex.xsl: %.omdoc $(XSLDIR)/expres.xsl 
		$(SAXON) $(firstword $<) $(XSLDIR)/expres.xsl $@ stylesheet="$(XSLDIR)/omdoc2tex.xsl" omdochome="$(OMDOCHOME)" format="TeX"

$(HTMLFILES): %.html: %.omdoc %-html.xsl $(XSLDIR)/omdoc-html-nice.xsl $(XSLDIR)/omdoc2share.xsl
		$(XT) $(firstword $<) $(basename $(firstword $<))-html.xsl $@

$(TEXFILES): %.tex: %.omdoc %-tex.xsl $(XSLDIR)/omdoc2tex.xsl $(XSLDIR)/omdoc2share.xsl 
		$(XT) $(firstword $<) $(basename $(firstword $<))-tex.xsl $@

$(DVIFILES): %.dvi: %.tex %.omdoc omdoc.sty
		$(LATEX) $(firstword $<)
		$(LATEX) $(firstword $<)

$(PSFILES): %.ps: %.dvi
		$(DVIPS) -o $@ $<




