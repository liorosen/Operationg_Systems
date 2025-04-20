#include "kernel/types.h"
#include "user/user.h"

#define SIZE (1 << 16)  
#define NUM_CHILDREN 8
#define CHUNK_SIZE (SIZE / NUM_CHILDREN)



int main() {
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN] ;
  int n = NUM_CHILDREN;

  int ret = forkn(NUM_CHILDREN, pids);

  if (ret == -1) {
    printf("forkn failed\n");
    exit(-1);
  } else if (ret >= 0 && ret < NUM_CHILDREN) {
    // Calculate correct start and end 
    long long base = SIZE / NUM_CHILDREN;
    long long rem = SIZE % NUM_CHILDREN;

    long long start = ret * base + (ret < rem ? ret : rem);
    long long end = start + base + (ret < rem ? 1 : 0);

    // long long start = ret * CHUNK_SIZE;
    // long long end = (ret + 1) * CHUNK_SIZE;
    long long sum = 0;

    for (long long i = start ; i < end; i++) {
      sum += i;
    }

    for (int i = 0; i < ret; i++) {
      sleep(50 * ret);  // let lower-numbered children print first
    }

    
    printf("Child %d calculated sum: %d\n", ret, (int)sum);
    statuses[ret] = (int)sum;
    sleep(10 * ret);  // let lower-numbered children print first
    exit_num((int)(sum)); 

  } else if (ret == -2) {
    sleep(100);
    printf("===> Waiting for children with waitall()\n");

    if (waitall(&n, statuses) < 0) {
      printf("waitall failed\n");
      exit(-1);
    }

    long long total = 0;
    for (int i = 0; i < n; i++) {
      printf("statuses[%d] = %d\n", i, statuses[i]);
      total += (long long)statuses[i] ;
    }

    printf("===> All %d children finished\n", n);
    printf("Sum of all children's sums: %d\n", total);

    long long expected = ((long long)(SIZE - 1) * SIZE) / 2;

    if (total == expected) {
      printf("Correct total sum: %d\n",total);

    } else {
      printf("Wrong total sum: %d (expected %d)\n", total, expected);
    }

    exit(0);
  }

  return 0;
}

