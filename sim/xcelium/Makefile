# Xcelium Makefile for Wally
XRUN = xrun
XRUN_OPTS = -access +rwc -sv -timescale 1ns/1ps

compile:
	$(XRUN) -compile -f compile.f

run: compile
	$(XRUN) -R -f run.f $(PLUS_ARGS)

clean:
	rm -rf xcelium.d *.shm *.log *.history *.key *.shm *.diag
	rm -rf xrun.*
	rm -rf .simvision
	rm -rf INCA_libs
	rm -rf cov_work
	rm -rf .bpad

