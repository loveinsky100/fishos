BUILD_DIR = build
ENTRY_POINT = 0xc0001500
AS = nasm
ASIB = -I include/
CC = i386-elf-gcc
LD = i386-elf-ld

$(BUILD_DIR)/boot.bin: boot.asm
	$(AS) $(ASIB) $< -o $@

$(BUILD_DIR)/loader.bin: loader.asm
	$(AS) $(ASIB) $< -o $@

.PHONY: mk_dir hd clean all

mk_dir:
	if [ ! -d $(BUILD_DIR) ]; then mkdir $(BUILD_DIR); fi
	bximage -func=create -hd=10M -q disk.img
	echo "Create image done."

hd:
	dd if=$(BUILD_DIR)/boot.bin of=disk.img bs=512 count=1 conv=notrunc
	dd if=$(BUILD_DIR)/loader.bin of=disk.img bs=512 count=1 seek=2 conv=notrunc

clean:
	rm -rf disk.img $(BUILD_DIR)

build: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/loader.bin

run:
	bochs -f bochsrc 

all: clean mk_dir build hd run