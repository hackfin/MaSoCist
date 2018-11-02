# Opensource makefile

DUTIES = opensource.pdf

opensource.pdf: reference/quickstart.xml reference/vendor.xml


all: $(DUTIES)

clean:
	-rm $(DUTIES)

%.pdf: %.xml
	dblatex $<

