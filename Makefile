.PHONY: rtl_compile rtl_sim c_elf c_bin c_hex

rtl_compile: 
	verilator --cc --exe --trace -Irtl/pkg -Irtl/peripherals -Irtl/dbus -Irtl/mem -Irtl/core rtl/pkg/riscv_pkg.sv rtl/soc_top.sv sim.cpp
rtl_build: rtl_compile
	make -C obj_dir -f Vriscv_pkg.mk
rtl_sim: rtl_build
	./obj_dir/Vriscv_pkg
rtl_view: rtl_sim
	gtkwave waveform.vcd

c_elf: 
	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 c/crt0.S -o c/crt0.o
	riscv64-unknown-elf-gcc -ffreestanding -nostdlib -Wl,-gc-sections -T c/link.ld -march=rv32i -mabi=ilp32 c/crt0.o c/main.c -o c/program.elf -lgcc
c_hex: c_elf
	riscv64-unknown-elf-objcopy -O verilog --only-section=.text* --only-section=.rodata* c/program.elf imem.hex
	riscv64-unknown-elf-objcopy -O verilog \
		--only-section=.data* --only-section=.bss* \
		--only-section=.sdata* --only-section=.sbss* \
		--change-section-lma '*-0x00100000' \
		c/program.elf dmem.hex
c_dump:
	riscv64-unknown-elf-objdump -d c/program.elf