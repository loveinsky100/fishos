#include "print.h"
#include "init.h"
#include "thread.h"
#include "interrupt.h"
#include "console.h"
#include "process.h"
#include "syscall-init.h"
#include "syscall.h"
#include "stdio.h"
#include "memory.h"
#include "dir.h"
#include "fs.h"
#include "assert.h"
#include "shell.h"

void init(void);

void main(void) {
    put_str("Hello World, Fishos!\n");
    init_all();
    // cls_screen();
    console_put_str("[fish@localhost /]$ ");
    thread_exit(running_thread(), true);
    return 0;
}

/* init进程 */
void init(void) {
    uint32_t ret_pid = fork();
    if (ret_pid) {  // 父进程
        int status;
        int child_pid;
        while (1) {
            child_pid = wait(&status);
            printf("I`m init, My pid is 1, I recieve a child, It`s pid is %d, status is %d\n", child_pid, status);
        }
    } else {    // 子进程
        my_shell();
    }
    panic("init: should not be here");
}
