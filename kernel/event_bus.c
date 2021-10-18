# include "event_bus.h"

# define EVENT_MAX_SIZE 256

struct event_node
{
    EventHandler handler;
};

struct event_node *event_subscribe_node[EVENT_MAX_SIZE];

void publish(uint8_t event, EventArg arg) {
    struct event_node *node = event_subscribe_node[event];
    if (__null == node) {
        return;
    }

    node->handler(arg);
}

void subscribe(uint8_t event, EventHandler handler) {
    struct event_node node;
    node.handler = handler;

    event_subscribe_node[event] = &node;
}
