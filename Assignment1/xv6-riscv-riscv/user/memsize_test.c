#include "kernel/types.h"
#include "user/user.h"

int main() {
    printf("Initial memory size: %d bytes\n", memsize());

    void *ptr = malloc(20 * 1024); // 20KB
    if (ptr == 0) {
        printf("Failed to allocate memory\n");
        exit(1);
    }

    printf("After malloc: %d bytes\n", memsize());

    free(ptr);

    printf("After free: %d bytes\n", memsize());

    exit(0);
    return 0;
}
