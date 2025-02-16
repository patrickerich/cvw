TARGET = dhrystone

$(TARGET): dhry_1.c dhry_2.c dhry_utils.c Makefile
	riscv64-unknown-elf-gcc -o $(TARGET) -gdwarf-2 -O2 \
	  -march=rv64gc -mabi=lp64d -mcmodel=medany \
	  -nostdlib -static -lm -fno-tree-loop-distribute-patterns \
	  -T../common/test.ld -I../common \
	  dhry_1.c dhry_2.c dhry_utils.c ../common/crt.S ../common/syscalls.c

clean:
	rm -f $(TARGET) $(TARGET).objdump* $(TARGET).memfile
