
src:
	mkdir $@

src/vhdl: | src
	mkdir $@

all: src/vhdl
