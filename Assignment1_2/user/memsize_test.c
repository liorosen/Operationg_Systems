#include "kernel/types.h"
#include "user/user.h"

int main() {
  printf("Initial memory size: %d bytes\n", memsize());

  void* ptr = malloc(20 * 1024);  // 20KB
  printf("After malloc(20KB): %d bytes\n", memsize());

  free(ptr);
  printf("After free: %d bytes\n", memsize());

  exit(0);
}
