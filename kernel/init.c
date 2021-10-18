# include "init.h"
# include "kernel/print.h"
# include "interrupt.h"
# include "timer.h"
# include "memory.h"
# include "thread/thread.h"
# include "console.h"
# include "keyboard.h"

void init() {
    put_str("init_all.\n");
    idt_init();
    mem_init();
    thread_init();
    timer_init();
    console_init();
    keyboard_init();
}