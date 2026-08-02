
hex: bin
	hexdump -v -e '1/4 "%08x\n"' program.bin > program.hex

bin: elf
	riscv64-unknown-elf-objcopy -O binary program.elf program.bin

elf: 
	riscv64-unknown-elf-gcc -O2 -ffreestanding -nostdlib -Wl,-Ttext=0x0 -march=rv32i -mabi=ilp32 main.c -o program.elf
