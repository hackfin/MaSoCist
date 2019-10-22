SOFTWARE = ../../sw
SIMULATION = ../../sim
SIM_OPTIONS = --max-stack-alloc=256

ELFFILE = $(SOFTWARE)/main.elf

RV32TEST_LOGFILE = rv32ui.log

$(SIMULATION)/net_virtual_riscv:
	$(MAKE) -C $(SIMULATION) clean all

run-test: $(SIMULATION)/net_virtual_riscv
	export LD_LIBRARY_PATH=$(SIMULATION):$(HOME)/lib; \
	$< $(SIM_OPTIONS) 2> virtual_riscv.log >/dev/null & \
	(MYPID=$$!; sleep 2; \
	python emulation.py $(RV32TEST_LOGFILE); \
	echo Killing test bench with PID $$MYPID; kill $$MYPID)

	@fail=`grep FAIL $(RV32TEST_LOGFILE)`; \
	if [ -z "$$fail" ] ; then \
		true; \
	else \
		cat $(RV32TEST_LOGFILE) | grep FAILED; \
		false; \
	fi
	

ASMFLAGS = -x assembler-with-cpp
CROSS_COMPILE = riscv32-unknown-elf-
CC      = $(CROSS_COMPILE)gcc
OBJDUMP = $(CROSS_COMPILE)objdump

CFLAGS += -I$(SOFTWARE) -Os

crt%.o: crt%.s
	$(CC) -c $(ASMFLAGS) -o $@ $<


test.elf: test.o crt0.o
	$(CC) -o $@ -T riscv_default.x -nostdlib $<

test.lst: test.elf
	$(OBJDUMP) -S $< >$@

	
all: test.elf run-test
