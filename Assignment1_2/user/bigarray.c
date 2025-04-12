
// Correct solutoin - Cant calculate parent :
#include "kernel/types.h"
#include "user/user.h"

#define SIZE (1 << 16)  // 65536 elements
#define NUM_CHILDREN 4
#define CHUNK_SIZE (SIZE / NUM_CHILDREN)  // 16384 elements per child


// Simple function to convert integer to string
void itoa(int num, char *str) {
  int i = 0;
  int is_negative = 0;

  if (num == 0) {
    str[i++] = '0';
    str[i] = '\0';
    return;
  }

  if (num < 0) {
    is_negative = 1;
    num = -num;
  }

  while (num != 0) {
    str[i++] = (num % 10) + '0';
    num = num / 10;
  }

  if (is_negative) {
    str[i++] = '-';
  }

  str[i] = '\0';

  // Reverse the string
  int j;
  for (j = 0; j < i/2; j++) {
    char temp = str[j];
    str[j] = str[i-1-j];
    str[i-1-j] = temp;
  }
}

// Simple string concatenation
void str_append(char *dest, const char *src) {
  while (*dest) dest++;
  while ((*dest++ = *src++));
  *--dest = '\0';
}

int main() {
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN];
  int n = NUM_CHILDREN;

  // Custom system call forkn to create child processes
  int ret = forkn(NUM_CHILDREN, pids);
  
  if (ret == -1) {
    printf("forkn failed\n");
    exit(-1);
  } else if (ret >= 0 && ret < NUM_CHILDREN) { // Child process (returns 0 to n-1)
    // Calculate chunk boundaries
    long long start = ret * CHUNK_SIZE;
    long long end = (ret + 1) * CHUNK_SIZE;
    long long sum = 0;

    // Calculate sum for this chunk
    for (long long i = start + 1; i <= end; i++) {
      sum += i;
    }

    // Wait for previous children to print
    for (int i = 0; i < ret; i++) {
      sleep(50);  // Sleep longer to ensure clear separation
    }

    // Format and print result
    char msg[100] = "Child ";
    char num[20];
    itoa(ret, num);
    str_append(msg, num);
    str_append(msg, " calculated sum: ");
    itoa((int)sum, num);
    str_append(msg, num);
    str_append(msg, "\n");
    
    // Get length of message
    int len = 0;
    char *p = msg;
    while (*p) {
      len++;
      p++;
    }
    
    write(1, msg, len);
    exit((int)sum);
  } else if (ret == -2) { // Parent process
    // Wait a bit to let all creation messages print
    sleep(100);
    printf("===> Waiting for children with waitall()\n");

    // Parent waits for all children to finish
    if (waitall(&n, statuses) < 0) {
      printf("waitall failed\n");
      exit(-1);
    }

    // Calculate total sum from all children
    long long total = 0;
    for (int i = 0; i < n; i++) {
      total += (long long)statuses[i];
    }

    printf("===> All %d children finished\n", n);
    printf("Sum of all children's sums: %lld\n", total);

    // Calculate expected sum using arithmetic sequence formula
    long long expected = ((long long)SIZE * (SIZE + 1)) / 2;
    if (total == expected) {
      printf("Correct total sum: %lld\n", total);
    } else {
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);
    }

    exit(0);
  }
  return 0;
}


