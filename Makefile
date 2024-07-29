carboot.img:
	as --32 -o carboot.o carboot.S
	ld -m elf_i386 -Ttext 0x7c00 --oformat=binary -o carboot.img carboot.o
.PHONY: clean run
clean:
	rm carboot.img carboot.o
run:
	qemu-system-i386 -fda carboot.img
