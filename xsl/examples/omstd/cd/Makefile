OMPREFIX        = /home/$(USER)/import/mathweb/omdoc
XSLDIR          = $(OMPREFIX)/xsl

XT		= saxon
XMLPARSE 	= xmlnorm -V -s

CDFILES	= $(wildcard *.ocd)
OMDOCFILES = $(patsubst %.ocd,%.omdoc,$(CDFILES))

all: $(OMDOCFILES) 

$(OMDOCFILES): %.omdoc: %.ocd $(XSLDIR)/cd2omdoc.xsl Makefile
	$(XT) $(firstword $<) $(XSLDIR)/cd2omdoc.xsl $@;\

clean:
	rm -f *.omdoc 


