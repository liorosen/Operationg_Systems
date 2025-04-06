#include "kernel/types.h"
#include "user/user.h"

int main() {
    int size = memsize();
    printf("Process memory size: %d bytes\n", size);
    exit(0);
}
