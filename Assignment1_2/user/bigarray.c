#include "kernel/types.h"
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



/*#include "kernel/types.h"
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