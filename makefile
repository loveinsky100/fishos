BUILD_DIR = build
ENTRY_POINT = 0xc0001500
AS = nasm
ASIB = -I include/ 
ASFLAGS = -f elf
CC = i386-elf-gcc
LD = i386-elf-ld
LIB = -I lib/ -I kernel/ -I device/
CFLAGS = -Wall -m32 -fno-stack-protector $(LIB) -c -fno-builtin -W -Wstrict-prototypes -Wmissing-prototypes
LDFLAGS = -m elf_i386 -Ttext $(ENTRY_POINT) -e main -Map $(BUILD_DIR)/kernel.map
OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/init.o $(BUILD_DIR)/interrupt.o $(BUILD_DIR)/timer.o $(BUILD_DIR)/interrupt.asm.o $(BUILD_DIR)/print.o  \
	   $(BUILD_DIR)/bitmap.o $(BUILD_DIR)/memory.o $(BUILD_DIR)/string.o $(BUILD_DIR)/debug.o $(BUILD_DIR)/thread.o $(BUILD_DIR)/switch.o \
	   $(BUILD_DIR)/list.o $(BUILD_DIR)/sync.o  $(BUILD_DIR)/console.o $(BUILD_DIR)/keyboard.o $(BUILD_DIR)/ioqueue.o

$(BUILD_DIR)/boot.bin: boot.asm
	$(AS) $(ASIB) $< -o $@

$(BUILD_DIR)/loader.bin: loader.asm
	$(AS) $(ASIB) $< -o $@

$(BUILD_DIR)/print.o: lib/kernel/print.asm
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/interrupt.asm.o: kernel/interrupt.asm
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/switch.o: kernel/switch.asm
	$(AS) $(ASFLAGS) $< -o $@

# C编译
$(BUILD_DIR)/main.o: kernel/main.c lib/kernel/print.h lib/stdint.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/interrupt.o: kernel/interrupt.c kernel/interrupt.h kernel/io.h lib/stdint.h 
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/init.o: kernel/init.c kernel/init.h lib/kernel/print.h kernel/interrupt.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/timer.o: device/timer.c device/timer.h lib/stdint.h kernel/io.h lib/kernel/print.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/sync.o: kernel/thread/sync.c kernel/thread/sync.h kernel/interrupt.h kernel/debug.h lib/stdint.h lib/kernel/list.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/console.o: device/console.c device/console.h kernel/thread/thread.h kernel/thread/sync.h lib/stdint.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/debug.o: kernel/debug.c kernel/debug.h lib/kernel/print.h lib/stdint.h kernel/interrupt.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/string.o: lib/string.c lib/string.h kernel/global.h kernel/debug.h
	$(CC) $(CFLAGS) $< -o $@
 
$(BUILD_DIR)/bitmap.o: lib/bitmap.c lib/bitmap.h kernel/debug.h kernel/interrupt.h lib/stdint.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/list.o: lib/kernel/list.c lib/kernel/list.h kernel/interrupt.h kernel/global.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/memory.o: kernel/memory.c kernel/memory.h lib/bitmap.h lib/stdint.h lib/kernel/print.h kernel/debug.h lib/string.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/thread.o: kernel/thread/thread.c kernel/thread/thread.h lib/stdint.h lib/string.c kernel/global.h kernel/memory.h kernel/debug.h kernel/interrupt.h lib/kernel/print.h \
			           lib/kernel/list.h device/console.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/keyboard.o: device/keyboard.c device/keyboard.h kernel/global.h kernel/interrupt.h kernel/io.h lib/kernel/print.h device/ioqueue.h
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/ioqueue.o: device/ioqueue.c device/ioqueue.h lib/stdint.h kernel/thread/thread.h kernel/thread/sync.h kernel/interrupt.h kernel/global.h kernel/debug.h
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