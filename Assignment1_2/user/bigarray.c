/* -1-  #include "kernel/types.h"
#include "user/user.h"

#define SIZE (1 << 16)
#define NUM_CHILDREN 4

int arr[SIZE];

// Minimal itoa (integer to string) function
void itoa(int n, char *buf) {
  int i = 0, j;
  if (n == 0) {
    buf[i++] = '0';
  } else {
    while (n > 0) {
      buf[i++] = (n % 10) + '0';
      n /= 10;
    }
    for (j = 0; j < i / 2; j++) {
      char tmp = buf[j];
      buf[j] = buf[i - j - 1];
      buf[i - j - 1] = tmp;
    }
  }
  buf[i] = 0;
}

int main() {
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);

  // Initialize array with consecutive numbers
  for (int i = 0; i < SIZE; i++) arr[i] = i;

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN];
  int n = NUM_CHILDREN;

  long long expected = ((long long)(SIZE - 1) * SIZE) / 2;

  // Custom system call forkn to create child processes
  int ret = forkn(NUM_CHILDREN, pids);
  if (ret > 0) {
    int id = ret - 1;
    int chunk = SIZE / NUM_CHILDREN;
    long long sum = 0;  // Use long long to prevent overflow

    for (int i = id * chunk; i < (id + 1) * chunk; i++)
      sum += arr[i];

    // Print sum without printf to avoid interleaving output
    char buf[100], tmp[20];
    char *p = buf;

    char *s1 = "Child ", *s2 = " calculated sum: ";
    while (*s1) *p++ = *s1++;
    itoa(id, tmp); char *tp = tmp;
    while (*tp) *p++ = *tp++;
    while (*s2) *p++ = *s2++;
    itoa(sum, tmp); tp = tmp;
    while (*tp) *p++ = *tp++;
    *p++ = '\n'; *p = 0;

    write(1, buf, p - buf);
    exit(sum); // Send sum as exit status
  } else if (ret == 0) {
    printf("===> Waiting for children with waitall()\n");

    if (waitall(&n, statuses) < 0) {
      printf("waitall failed\n");
      exit(-1);
    }

    long long total = 0;
    for (int i = 0; i < n; i++)
      total += statuses[i];  // Accumulate child exit statuses

    printf("===> All %d children finished\n", n);
    printf("Total sum: %lld\n", total);

    if (total == expected)
      printf("Correct total sum: %lld\n", total);
    else
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);

    exit(0);
  } else {
    printf("forkn failed\n");
    exit(-1);
  }
  return 0;
}

*/

/* - last - #include "kernel/types.h"
#include "user/user.h"

#define SIZE (1 << 16)
#define NUM_CHILDREN 4

int arr[SIZE];

// Minimal itoa (integer to string) function
void itoa(int n, char *buf) {
  int i = 0, j;
  if (n == 0) {
    buf[i++] = '0';
  } else {
    while (n > 0) {
      buf[i++] = (n % 10) + '0';
      n /= 10;
    }
    for (j = 0; j < i / 2; j++) {
      char tmp = buf[j];
      buf[j] = buf[i - j - 1];
      buf[i - j - 1] = tmp;
    }
  }
  buf[i] = 0;
}

int main() {
  for (int i = 0; i < SIZE; i++) arr[i] = i;

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN];
  int n = NUM_CHILDREN;

  int ret = forkn(NUM_CHILDREN, pids);
  if (ret > 0) {
    int id = ret - 1;
    int chunk = SIZE / NUM_CHILDREN;
    int sum = 0;
    for (int i = id * chunk; i < (id + 1) * chunk; i++)
      sum += arr[i];

    // Print sum without printf (to prevent interleaving output)
    char buf[100], tmp[20];
    char *p = buf;

    char *s1 = "Child ", *s2 = " calculated sum: ";
    while (*s1) *p++ = *s1++;
    itoa(id, tmp); char *tp = tmp;
    while (*tp) *p++ = *tp++;
    while (*s2) *p++ = *s2++;
    itoa(sum, tmp); tp = tmp;
    while (*tp) *p++ = *tp++;
    *p++ = '\n'; *p = 0;

    write(1, buf, p - buf);
    exit(sum);
  } else if (ret == 0) {
    printf("===> Waiting for children with waitall()\n");
    if (waitall(&n, statuses) < 0) {
      printf("waitall failed\n");
      exit(-1);
    }

    long long total = 0;
    for (int i = 0; i < n; i++)
      total += statuses[i];

    printf("===> All %d children finished\n", n);
    printf("Total sum: %lld\n", total);

    long long expected = ((long long)(SIZE - 1) * SIZE) / 2;
    if (total == expected)
      printf("Correct total sum: %lld\n", total);
    else
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);

    exit(0);
  } else {
    printf("forkn failed\n");
    exit(-1);
  }
  return 0;
}
*/
/* - 2 - #include "kernel/types.h"
#include "user/user.h"

#define SIZE (1 << 12)  // Reduced size to avoid memory issues
#define NUM_CHILDREN 4

int arr[SIZE];

// Minimal itoa (integer to string) function
void itoa(int n, char *buf) {
  int i = 0, j;
  if (n == 0) {
    buf[i++] = '0';
  } else {
    while (n > 0) {
      buf[i++] = (n % 10) + '0';
      n /= 10;
    }
    for (j = 0; j < i / 2; j++) {
      char tmp = buf[j];
      buf[j] = buf[i - j - 1];
      buf[i - j - 1] = tmp;
    }
  }
  buf[i] = 0;
}

int main() {
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);

  // Initialize array with consecutive numbers
  for (int i = 0; i < SIZE; i++) {
    arr[i] = i;
  }

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN];
  int n = NUM_CHILDREN;

  // Calculate expected sum using smaller chunks to avoid overflow
  long long expected = 0;
  for (int i = 0; i < SIZE; i++) {
    expected += i;
  }

  // Custom system call forkn to create child processes
  int ret = forkn(NUM_CHILDREN, pids);
  
  if (ret == -1) {
    printf("forkn failed\n");
    exit(-1);
  } else if (ret >= 0) { // Child process (returns 0 to n-1)
    int chunk = SIZE / NUM_CHILDREN;
    int start = ret * chunk;
    int end = (ret == NUM_CHILDREN - 1) ? SIZE : (ret + 1) * chunk;
    int sum = 0;  // Use int since we reduced the size

    // Calculate sum for this child's chunk
    for (int i = start; i < end; i++) {
      sum += arr[i];
    }

    // Sleep briefly to allow parent's message to print first
    sleep(10);
    printf("Child %d calculated sum: %d\n", ret, sum);
    exit(sum); // Send sum as exit status
  } else { // Parent process (ret == -2)
    printf("===> Waiting for children with waitall()\n");

    if (waitall(&n, statuses) < 0) {
      printf("waitall failed\n");
      exit(-1);
    }

    long long total = 0;
    for (int i = 0; i < n; i++) {
      total += statuses[i];
    }

    printf("===> All %d children finished\n", n);
    printf("Total sum: %lld\n", total);

    if (total == expected)
      printf("Correct total sum: %lld\n", total);
    else
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);

    exit(0);
  }
}
*/

///* another solutoin work messy :
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

//*/