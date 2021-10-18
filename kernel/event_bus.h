#ifndef _KERNEL_EVENT_BUS_H
#define _KERNEL_EVENT_BUS_H

typedef void *EventHandler;
typedef void *EventArg;

void publish(uint8_t event, EventArg arg);
void subscribe(uint8_t event, EventHandler handler);

#endif