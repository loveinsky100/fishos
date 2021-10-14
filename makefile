BUILD_DIR = build
ENTRY_POINT = 0xc0001500
AS = nasm
ASIB = -I include/ 
ASFLAGS = -f elf
CC = i386-elf-gcc
LD = i386-elf-ld
LIB = -I lib/ -I kernel/
CFLAGS = -Wall -m32 -fno-stack-protector $(LIB) -c -fno-builtin -W -Wstrict-prototypes -Wmissing-prototypes
LDFLAGS = -m elf_i386 -Ttext $(ENTRY_POINT) -e main -Map $(BUILD_DIR)/kernel.map
OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/print.o

$(BUILD_DIR)/boot.bin: boot.asm
	$(AS) $(ASIB) $< -o $@

$(BUILD_DIR)/loader.bin: loader.asm
	$(AS) $(ASIB) $< -o $@

$(BUILD_DIR)/print.o: lib/kernel/print.asm
	$(AS) $(ASFLAGS) $< -o $@

# C编译
$(BUILD_DIR)/main.o: kernel/main.c lib/kernel/print.h lib/stdint.h
	$(CC) $(CFLAGS) $< -o $@

# 链接
$(BUILD_DIR)/kernel.bin: $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

.PHONY: mk_dir hd clean all

mk_dir:
	if [ ! -d $(BUILD_DIR) ]; then mkdir $(BUILD_DIR); fi
	bximage -func=create -hd=10M -q disk.img
	echo "Create image done."

hd:
	dd if=$(BUILD_DIR)/boot.bin of=disk.img bs=512 count=1 conv=notrunc
	dd if=$(BUILD_DIR)/loader.bin of=disk.img bs=512 count=4 seek=2 conv=notrunc
	dd if=$(BUILD_DIR)/kernel.bin of=disk.img bs=512 count=200 seek=9 conv=notrunc

clean:
	rm -rf disk.img $(BUILD_DIR)

build: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/loader.bin $(BUILD_DIR)/kernel.bin

run:
	bochs -f bochsrc 

all: clean mk_dir build hd run