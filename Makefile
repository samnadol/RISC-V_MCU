.PHONY: view clean 

compile: 
	verilator --cc --exe --trace -Irtl/pkg -Irtl/mem -Irtl/core rtl/pkg/riscv_pkg.sv rtl/soc_top.sv sim.cpp

build: compile
	make -C obj_dir -f Vriscv_pkg.mk

sim: build
	./obj_dir/Vriscv_pkg

view:
	gtkwave waveform.vcd