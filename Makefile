.PHONY: rtl_compile rtl_build rtl_sim rtl_view c_elf c_bin c_hex c_dump

rtl_compile: 
	verilator --cc --exe --trace --timescale 1ns/1ps -Irtl/pkg -Irtl/peripherals -Irtl/dbus -Irtl/mem -Irtl/core rtl/pkg/riscv_pkg.sv rtl/soc_top.sv sim.cpp
rtl_build: rtl_compile
	make -C obj_dir -f Vriscv_pkg.mk
rtl_sim: rtl_build
	./obj_dir/Vriscv_pkg
rtl_view: rtl_sim
	gtkwave waveform.vcd savefile.gtkw

c_elf: 
	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 c/crt0.S -o c/crt0.o
	riscv64-unknown-elf-gcc -ffreestanding -nostdlib -Wl,-gc-sections -T c/link.ld -march=rv32i -mabi=ilp32 c/crt0.o c/main.c c/lib/gpio.c c/lib/uart.c -o c/program.elf -lgcc
c_hex: c_elf
	riscv64-unknown-elf-objcopy -O verilog --only-section=.text* c/program.elf imem.hex
	riscv64-unknown-elf-objcopy -O verilog \
		--only-section=.rodata* --only-section=.srodata* \
		--only-section=.data* --only-section=.bss* \
		--only-section=.sdata* --only-section=.sbss* \
		--change-section-lma '*-0x00100000' \
		c/program.elf dmem.hex
c_dump:
	riscv64-unknown-elf-objdump -d c/program.elf