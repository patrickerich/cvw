# Xcelium Makefile for Wally
XRUN = xrun
XRUN_OPTS = -access +rwc -sv -timescale 1ns/1ps

compile:
	$(XRUN) -compile -f compile.f

run: compile
	$(XRUN) -R -f run.f $(PLUS_ARGS)

