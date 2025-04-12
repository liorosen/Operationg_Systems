
user/_bigarray:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <itoa>:

// Declare array with static to ensure it's in data segment
//static int arr[SIZE];

// Minimal itoa (integer to string) function
void itoa(int n, char *buf) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  int i = 0, j;
  if (n == 0) {
   6:	c52d                	beqz	a0,70 <itoa+0x70>
    buf[i++] = '0';
  } else {
    while (n > 0) {
   8:	872e                	mv	a4,a1
   a:	87ae                	mv	a5,a1
   c:	06a05063          	blez	a0,6c <itoa+0x6c>
  10:	4885                	li	a7,1
  12:	40b888bb          	subw	a7,a7,a1
      buf[i++] = (n % 10) + '0';
  16:	4629                	li	a2,10
    while (n > 0) {
  18:	4325                	li	t1,9
      buf[i++] = (n % 10) + '0';
  1a:	00f8883b          	addw	a6,a7,a5
  1e:	02c566bb          	remw	a3,a0,a2
  22:	0306869b          	addiw	a3,a3,48
  26:	00d78023          	sb	a3,0(a5)
      n /= 10;
  2a:	86aa                	mv	a3,a0
  2c:	02c5453b          	divw	a0,a0,a2
    while (n > 0) {
  30:	0785                	addi	a5,a5,1
  32:	fed344e3          	blt	t1,a3,1a <itoa+0x1a>
    }
    for (j = 0; j < i / 2; j++) {
  36:	01f8589b          	srliw	a7,a6,0x1f
  3a:	010888bb          	addw	a7,a7,a6
  3e:	4018d89b          	sraiw	a7,a7,0x1
  42:	4785                	li	a5,1
  44:	0307db63          	bge	a5,a6,7a <itoa+0x7a>
  48:	fff80793          	addi	a5,a6,-1
  4c:	97ae                	add	a5,a5,a1
  4e:	4681                	li	a3,0
      char tmp = buf[j];
  50:	00074603          	lbu	a2,0(a4)
      buf[j] = buf[i - j - 1];
  54:	0007c503          	lbu	a0,0(a5)
  58:	00a70023          	sb	a0,0(a4)
      buf[i - j - 1] = tmp;
  5c:	00c78023          	sb	a2,0(a5)
    for (j = 0; j < i / 2; j++) {
  60:	2685                	addiw	a3,a3,1
  62:	0705                	addi	a4,a4,1
  64:	17fd                	addi	a5,a5,-1
  66:	ff16c5e3          	blt	a3,a7,50 <itoa+0x50>
  6a:	a801                	j	7a <itoa+0x7a>
  int i = 0, j;
  6c:	4801                	li	a6,0
  6e:	a031                	j	7a <itoa+0x7a>
    buf[i++] = '0';
  70:	03000793          	li	a5,48
  74:	00f58023          	sb	a5,0(a1)
  78:	4805                	li	a6,1
    }
  }
  buf[i] = 0;
  7a:	95c2                	add	a1,a1,a6
  7c:	00058023          	sb	zero,0(a1)
}
  80:	6422                	ld	s0,8(sp)
  82:	0141                	addi	sp,sp,16
  84:	8082                	ret

0000000000000086 <main>:

int main() {
  86:	715d                	addi	sp,sp,-80
  88:	e486                	sd	ra,72(sp)
  8a:	e0a2                	sd	s0,64(sp)
  8c:	fc26                	sd	s1,56(sp)
  8e:	f84a                	sd	s2,48(sp)
  90:	0880                	addi	s0,sp,80
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);
  92:	4591                	li	a1,4
  94:	00001517          	auipc	a0,0x1
  98:	93c50513          	addi	a0,a0,-1732 # 9d0 <malloc+0xea>
  9c:	00000097          	auipc	ra,0x0
  a0:	78c080e7          	jalr	1932(ra) # 828 <printf>

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN];
  int n = NUM_CHILDREN;
  a4:	4791                	li	a5,4
  a6:	faf42e23          	sw	a5,-68(s0)

  // Custom system call forkn to create child processes
  int ret = forkn(NUM_CHILDREN, pids);
  aa:	fd040593          	addi	a1,s0,-48
  ae:	4511                	li	a0,4
  b0:	00000097          	auipc	ra,0x0
  b4:	488080e7          	jalr	1160(ra) # 538 <forkn>
  
  if (ret == -1) {
  b8:	57fd                	li	a5,-1
  ba:	06f50463          	beq	a0,a5,122 <main+0x9c>
  be:	84aa                	mv	s1,a0
    printf("forkn failed\n");
    exit(-1);
  } else if (ret >= 0) { // Child process (returns 0 to n-1)
  c0:	08054063          	bltz	a0,140 <main+0xba>
    // Calculate chunk boundaries
    int start = ret * CHUNK_SIZE;
  c4:	00e5169b          	slliw	a3,a0,0xe
    int end = start + CHUNK_SIZE;
    long long local_sum = 0;  // Use long long for large sums

    // Calculate sum for this chunk using the range directly
    for (long long i = start + 1; i <= end; i++) {
  c8:	0016871b          	addiw	a4,a3,1
  cc:	6791                	lui	a5,0x4
  ce:	9fb5                	addw	a5,a5,a3
  d0:	06e7c663          	blt	a5,a4,13c <main+0xb6>
  d4:	6791                	lui	a5,0x4
  d6:	17fd                	addi	a5,a5,-1
  d8:	fffd                	bnez	a5,d6 <main+0x50>
  da:	00170913          	addi	s2,a4,1
  de:	6791                	lui	a5,0x4
  e0:	17fd                	addi	a5,a5,-1
  e2:	02f90933          	mul	s2,s2,a5
  e6:	07ffa7b7          	lui	a5,0x7ffa
  ea:	0785                	addi	a5,a5,1
  ec:	973e                	add	a4,a4,a5
  ee:	993a                	add	s2,s2,a4
      local_sum += i;
    }

    // Wait proportionally to process ID to ensure ordered output
    sleep(30 + ret * 30);
  f0:	0014851b          	addiw	a0,s1,1
  f4:	47f9                	li	a5,30
  f6:	02f5053b          	mulw	a0,a0,a5
  fa:	00000097          	auipc	ra,0x0
  fe:	426080e7          	jalr	1062(ra) # 520 <sleep>
    printf("Child %d calculated sum: %d\n", ret, (int)local_sum);
 102:	2901                	sext.w	s2,s2
 104:	864a                	mv	a2,s2
 106:	85a6                	mv	a1,s1
 108:	00001517          	auipc	a0,0x1
 10c:	8f850513          	addi	a0,a0,-1800 # a00 <malloc+0x11a>
 110:	00000097          	auipc	ra,0x0
 114:	718080e7          	jalr	1816(ra) # 828 <printf>
    exit((int)local_sum);
 118:	854a                	mv	a0,s2
 11a:	00000097          	auipc	ra,0x0
 11e:	36e080e7          	jalr	878(ra) # 488 <exit>
    printf("forkn failed\n");
 122:	00001517          	auipc	a0,0x1
 126:	8ce50513          	addi	a0,a0,-1842 # 9f0 <malloc+0x10a>
 12a:	00000097          	auipc	ra,0x0
 12e:	6fe080e7          	jalr	1790(ra) # 828 <printf>
    exit(-1);
 132:	557d                	li	a0,-1
 134:	00000097          	auipc	ra,0x0
 138:	354080e7          	jalr	852(ra) # 488 <exit>
    long long local_sum = 0;  // Use long long for large sums
 13c:	4901                	li	s2,0
 13e:	bf4d                	j	f0 <main+0x6a>
  } else { // Parent process (ret == -2)
    printf("===> Waiting for children with waitall()\n");
 140:	00001517          	auipc	a0,0x1
 144:	8e050513          	addi	a0,a0,-1824 # a20 <malloc+0x13a>
 148:	00000097          	auipc	ra,0x0
 14c:	6e0080e7          	jalr	1760(ra) # 828 <printf>

    // Wait for all children and collect their sums
    if (waitall(&n, statuses) < 0) {
 150:	fc040593          	addi	a1,s0,-64
 154:	fbc40513          	addi	a0,s0,-68
 158:	00000097          	auipc	ra,0x0
 15c:	3e8080e7          	jalr	1000(ra) # 540 <waitall>
 160:	06054563          	bltz	a0,1ca <main+0x144>
    }

    // Calculate total sum from all children
    long long total = 0;
    for (int i = 0; i < NUM_CHILDREN; i++) {
      total += (long long)statuses[i];
 164:	fc042783          	lw	a5,-64(s0)
 168:	fc442483          	lw	s1,-60(s0)
 16c:	94be                	add	s1,s1,a5
 16e:	fc842783          	lw	a5,-56(s0)
 172:	97a6                	add	a5,a5,s1
 174:	fcc42483          	lw	s1,-52(s0)
 178:	94be                	add	s1,s1,a5
    }

    printf("===> All %d children finished\n", NUM_CHILDREN);
 17a:	4591                	li	a1,4
 17c:	00001517          	auipc	a0,0x1
 180:	8e450513          	addi	a0,a0,-1820 # a60 <malloc+0x17a>
 184:	00000097          	auipc	ra,0x0
 188:	6a4080e7          	jalr	1700(ra) # 828 <printf>
    printf("Sum of all children's sums: %lld\n", total);
 18c:	85a6                	mv	a1,s1
 18e:	00001517          	auipc	a0,0x1
 192:	8f250513          	addi	a0,a0,-1806 # a80 <malloc+0x19a>
 196:	00000097          	auipc	ra,0x0
 19a:	692080e7          	jalr	1682(ra) # 828 <printf>

    // Calculate expected sum using arithmetic sequence formula
    long long expected = ((long long)SIZE * (SIZE + 1)) / 2;
    if (total == expected)
 19e:	100017b7          	lui	a5,0x10001
 1a2:	078e                	slli	a5,a5,0x3
 1a4:	04f48063          	beq	s1,a5,1e4 <main+0x15e>
      printf("Correct total sum: %lld\n", total);
    else
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);
 1a8:	10001637          	lui	a2,0x10001
 1ac:	060e                	slli	a2,a2,0x3
 1ae:	85a6                	mv	a1,s1
 1b0:	00001517          	auipc	a0,0x1
 1b4:	91850513          	addi	a0,a0,-1768 # ac8 <malloc+0x1e2>
 1b8:	00000097          	auipc	ra,0x0
 1bc:	670080e7          	jalr	1648(ra) # 828 <printf>

    exit(0);
 1c0:	4501                	li	a0,0
 1c2:	00000097          	auipc	ra,0x0
 1c6:	2c6080e7          	jalr	710(ra) # 488 <exit>
      printf("waitall failed\n");
 1ca:	00001517          	auipc	a0,0x1
 1ce:	88650513          	addi	a0,a0,-1914 # a50 <malloc+0x16a>
 1d2:	00000097          	auipc	ra,0x0
 1d6:	656080e7          	jalr	1622(ra) # 828 <printf>
      exit(-1);
 1da:	557d                	li	a0,-1
 1dc:	00000097          	auipc	ra,0x0
 1e0:	2ac080e7          	jalr	684(ra) # 488 <exit>
      printf("Correct total sum: %lld\n", total);
 1e4:	85be                	mv	a1,a5
 1e6:	00001517          	auipc	a0,0x1
 1ea:	8c250513          	addi	a0,a0,-1854 # aa8 <malloc+0x1c2>
 1ee:	00000097          	auipc	ra,0x0
 1f2:	63a080e7          	jalr	1594(ra) # 828 <printf>
 1f6:	b7e9                	j	1c0 <main+0x13a>

00000000000001f8 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e406                	sd	ra,8(sp)
 1fc:	e022                	sd	s0,0(sp)
 1fe:	0800                	addi	s0,sp,16
  extern int main();
  main();
 200:	00000097          	auipc	ra,0x0
 204:	e86080e7          	jalr	-378(ra) # 86 <main>
  exit(0);
 208:	4501                	li	a0,0
 20a:	00000097          	auipc	ra,0x0
 20e:	27e080e7          	jalr	638(ra) # 488 <exit>

0000000000000212 <strcpy>:
}

char* strcpy(char *s, const char *t)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 218:	87aa                	mv	a5,a0
 21a:	0585                	addi	a1,a1,1
 21c:	0785                	addi	a5,a5,1
 21e:	fff5c703          	lbu	a4,-1(a1)
 222:	fee78fa3          	sb	a4,-1(a5) # 10000fff <base+0xfffffef>
 226:	fb75                	bnez	a4,21a <strcpy+0x8>
    ;
  return os;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret

000000000000022e <strcmp>:

int strcmp(const char *p, const char *q)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 234:	00054783          	lbu	a5,0(a0)
 238:	cb91                	beqz	a5,24c <strcmp+0x1e>
 23a:	0005c703          	lbu	a4,0(a1)
 23e:	00f71763          	bne	a4,a5,24c <strcmp+0x1e>
    p++, q++;
 242:	0505                	addi	a0,a0,1
 244:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 246:	00054783          	lbu	a5,0(a0)
 24a:	fbe5                	bnez	a5,23a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 24c:	0005c503          	lbu	a0,0(a1)
}
 250:	40a7853b          	subw	a0,a5,a0
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret

000000000000025a <strlen>:

uint strlen(const char *s)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 260:	00054783          	lbu	a5,0(a0)
 264:	cf91                	beqz	a5,280 <strlen+0x26>
 266:	0505                	addi	a0,a0,1
 268:	87aa                	mv	a5,a0
 26a:	4685                	li	a3,1
 26c:	9e89                	subw	a3,a3,a0
 26e:	00f6853b          	addw	a0,a3,a5
 272:	0785                	addi	a5,a5,1
 274:	fff7c703          	lbu	a4,-1(a5)
 278:	fb7d                	bnez	a4,26e <strlen+0x14>
    ;
  return n;
}
 27a:	6422                	ld	s0,8(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret
  for(n = 0; s[n]; n++)
 280:	4501                	li	a0,0
 282:	bfe5                	j	27a <strlen+0x20>

0000000000000284 <memset>:

void* memset(void *dst, int c, uint n)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 28a:	ce09                	beqz	a2,2a4 <memset+0x20>
 28c:	87aa                	mv	a5,a0
 28e:	fff6071b          	addiw	a4,a2,-1
 292:	1702                	slli	a4,a4,0x20
 294:	9301                	srli	a4,a4,0x20
 296:	0705                	addi	a4,a4,1
 298:	972a                	add	a4,a4,a0
    cdst[i] = c;
 29a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 29e:	0785                	addi	a5,a5,1
 2a0:	fee79de3          	bne	a5,a4,29a <memset+0x16>
  }
  return dst;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <strchr>:

char* strchr(const char *s, char c)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	cb99                	beqz	a5,2ca <strchr+0x20>
    if(*s == c)
 2b6:	00f58763          	beq	a1,a5,2c4 <strchr+0x1a>
  for(; *s; s++)
 2ba:	0505                	addi	a0,a0,1
 2bc:	00054783          	lbu	a5,0(a0)
 2c0:	fbfd                	bnez	a5,2b6 <strchr+0xc>
      return (char*)s;
  return 0;
 2c2:	4501                	li	a0,0
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret
  return 0;
 2ca:	4501                	li	a0,0
 2cc:	bfe5                	j	2c4 <strchr+0x1a>

00000000000002ce <gets>:

char* gets(char *buf, int max)
{
 2ce:	711d                	addi	sp,sp,-96
 2d0:	ec86                	sd	ra,88(sp)
 2d2:	e8a2                	sd	s0,80(sp)
 2d4:	e4a6                	sd	s1,72(sp)
 2d6:	e0ca                	sd	s2,64(sp)
 2d8:	fc4e                	sd	s3,56(sp)
 2da:	f852                	sd	s4,48(sp)
 2dc:	f456                	sd	s5,40(sp)
 2de:	f05a                	sd	s6,32(sp)
 2e0:	ec5e                	sd	s7,24(sp)
 2e2:	1080                	addi	s0,sp,96
 2e4:	8baa                	mv	s7,a0
 2e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e8:	892a                	mv	s2,a0
 2ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ec:	4aa9                	li	s5,10
 2ee:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2f0:	89a6                	mv	s3,s1
 2f2:	2485                	addiw	s1,s1,1
 2f4:	0344d863          	bge	s1,s4,324 <gets+0x56>
    cc = read(0, &c, 1);
 2f8:	4605                	li	a2,1
 2fa:	faf40593          	addi	a1,s0,-81
 2fe:	4501                	li	a0,0
 300:	00000097          	auipc	ra,0x0
 304:	1a8080e7          	jalr	424(ra) # 4a8 <read>
    if(cc < 1)
 308:	00a05e63          	blez	a0,324 <gets+0x56>
    buf[i++] = c;
 30c:	faf44783          	lbu	a5,-81(s0)
 310:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 314:	01578763          	beq	a5,s5,322 <gets+0x54>
 318:	0905                	addi	s2,s2,1
 31a:	fd679be3          	bne	a5,s6,2f0 <gets+0x22>
  for(i=0; i+1 < max; ){
 31e:	89a6                	mv	s3,s1
 320:	a011                	j	324 <gets+0x56>
 322:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 324:	99de                	add	s3,s3,s7
 326:	00098023          	sb	zero,0(s3)
  return buf;
}
 32a:	855e                	mv	a0,s7
 32c:	60e6                	ld	ra,88(sp)
 32e:	6446                	ld	s0,80(sp)
 330:	64a6                	ld	s1,72(sp)
 332:	6906                	ld	s2,64(sp)
 334:	79e2                	ld	s3,56(sp)
 336:	7a42                	ld	s4,48(sp)
 338:	7aa2                	ld	s5,40(sp)
 33a:	7b02                	ld	s6,32(sp)
 33c:	6be2                	ld	s7,24(sp)
 33e:	6125                	addi	sp,sp,96
 340:	8082                	ret

0000000000000342 <stat>:

int stat(const char *n, struct stat *st)
{
 342:	1101                	addi	sp,sp,-32
 344:	ec06                	sd	ra,24(sp)
 346:	e822                	sd	s0,16(sp)
 348:	e426                	sd	s1,8(sp)
 34a:	e04a                	sd	s2,0(sp)
 34c:	1000                	addi	s0,sp,32
 34e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 350:	4581                	li	a1,0
 352:	00000097          	auipc	ra,0x0
 356:	17e080e7          	jalr	382(ra) # 4d0 <open>
  if(fd < 0)
 35a:	02054563          	bltz	a0,384 <stat+0x42>
 35e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 360:	85ca                	mv	a1,s2
 362:	00000097          	auipc	ra,0x0
 366:	186080e7          	jalr	390(ra) # 4e8 <fstat>
 36a:	892a                	mv	s2,a0
  close(fd);
 36c:	8526                	mv	a0,s1
 36e:	00000097          	auipc	ra,0x0
 372:	14a080e7          	jalr	330(ra) # 4b8 <close>
  return r;
}
 376:	854a                	mv	a0,s2
 378:	60e2                	ld	ra,24(sp)
 37a:	6442                	ld	s0,16(sp)
 37c:	64a2                	ld	s1,8(sp)
 37e:	6902                	ld	s2,0(sp)
 380:	6105                	addi	sp,sp,32
 382:	8082                	ret
    return -1;
 384:	597d                	li	s2,-1
 386:	bfc5                	j	376 <stat+0x34>

0000000000000388 <atoi>:

int atoi(const char *s)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e422                	sd	s0,8(sp)
 38c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 38e:	00054603          	lbu	a2,0(a0)
 392:	fd06079b          	addiw	a5,a2,-48
 396:	0ff7f793          	andi	a5,a5,255
 39a:	4725                	li	a4,9
 39c:	02f76963          	bltu	a4,a5,3ce <atoi+0x46>
 3a0:	86aa                	mv	a3,a0
  n = 0;
 3a2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3a4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3a6:	0685                	addi	a3,a3,1
 3a8:	0025179b          	slliw	a5,a0,0x2
 3ac:	9fa9                	addw	a5,a5,a0
 3ae:	0017979b          	slliw	a5,a5,0x1
 3b2:	9fb1                	addw	a5,a5,a2
 3b4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3b8:	0006c603          	lbu	a2,0(a3)
 3bc:	fd06071b          	addiw	a4,a2,-48
 3c0:	0ff77713          	andi	a4,a4,255
 3c4:	fee5f1e3          	bgeu	a1,a4,3a6 <atoi+0x1e>
  return n;
}
 3c8:	6422                	ld	s0,8(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret
  n = 0;
 3ce:	4501                	li	a0,0
 3d0:	bfe5                	j	3c8 <atoi+0x40>

00000000000003d2 <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 3d2:	1141                	addi	sp,sp,-16
 3d4:	e422                	sd	s0,8(sp)
 3d6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3d8:	02b57663          	bgeu	a0,a1,404 <memmove+0x32>
    while(n-- > 0)
 3dc:	02c05163          	blez	a2,3fe <memmove+0x2c>
 3e0:	fff6079b          	addiw	a5,a2,-1
 3e4:	1782                	slli	a5,a5,0x20
 3e6:	9381                	srli	a5,a5,0x20
 3e8:	0785                	addi	a5,a5,1
 3ea:	97aa                	add	a5,a5,a0
  dst = vdst;
 3ec:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ee:	0585                	addi	a1,a1,1
 3f0:	0705                	addi	a4,a4,1
 3f2:	fff5c683          	lbu	a3,-1(a1)
 3f6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3fa:	fee79ae3          	bne	a5,a4,3ee <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3fe:	6422                	ld	s0,8(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret
    dst += n;
 404:	00c50733          	add	a4,a0,a2
    src += n;
 408:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 40a:	fec05ae3          	blez	a2,3fe <memmove+0x2c>
 40e:	fff6079b          	addiw	a5,a2,-1
 412:	1782                	slli	a5,a5,0x20
 414:	9381                	srli	a5,a5,0x20
 416:	fff7c793          	not	a5,a5
 41a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 41c:	15fd                	addi	a1,a1,-1
 41e:	177d                	addi	a4,a4,-1
 420:	0005c683          	lbu	a3,0(a1)
 424:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 428:	fee79ae3          	bne	a5,a4,41c <memmove+0x4a>
 42c:	bfc9                	j	3fe <memmove+0x2c>

000000000000042e <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 42e:	1141                	addi	sp,sp,-16
 430:	e422                	sd	s0,8(sp)
 432:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 434:	ca05                	beqz	a2,464 <memcmp+0x36>
 436:	fff6069b          	addiw	a3,a2,-1
 43a:	1682                	slli	a3,a3,0x20
 43c:	9281                	srli	a3,a3,0x20
 43e:	0685                	addi	a3,a3,1
 440:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 442:	00054783          	lbu	a5,0(a0)
 446:	0005c703          	lbu	a4,0(a1)
 44a:	00e79863          	bne	a5,a4,45a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 44e:	0505                	addi	a0,a0,1
    p2++;
 450:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 452:	fed518e3          	bne	a0,a3,442 <memcmp+0x14>
  }
  return 0;
 456:	4501                	li	a0,0
 458:	a019                	j	45e <memcmp+0x30>
      return *p1 - *p2;
 45a:	40e7853b          	subw	a0,a5,a4
}
 45e:	6422                	ld	s0,8(sp)
 460:	0141                	addi	sp,sp,16
 462:	8082                	ret
  return 0;
 464:	4501                	li	a0,0
 466:	bfe5                	j	45e <memcmp+0x30>

0000000000000468 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 468:	1141                	addi	sp,sp,-16
 46a:	e406                	sd	ra,8(sp)
 46c:	e022                	sd	s0,0(sp)
 46e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 470:	00000097          	auipc	ra,0x0
 474:	f62080e7          	jalr	-158(ra) # 3d2 <memmove>
}
 478:	60a2                	ld	ra,8(sp)
 47a:	6402                	ld	s0,0(sp)
 47c:	0141                	addi	sp,sp,16
 47e:	8082                	ret

0000000000000480 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 480:	4885                	li	a7,1
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <exit>:
.global exit
exit:
 li a7, SYS_exit
 488:	4889                	li	a7,2
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 490:	48e1                	li	a7,24
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <wait>:
.global wait
wait:
 li a7, SYS_wait
 498:	488d                	li	a7,3
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4a0:	4891                	li	a7,4
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <read>:
.global read
read:
 li a7, SYS_read
 4a8:	4895                	li	a7,5
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <write>:
.global write
write:
 li a7, SYS_write
 4b0:	48c1                	li	a7,16
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <close>:
.global close
close:
 li a7, SYS_close
 4b8:	48d5                	li	a7,21
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4c0:	4899                	li	a7,6
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4c8:	489d                	li	a7,7
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <open>:
.global open
open:
 li a7, SYS_open
 4d0:	48bd                	li	a7,15
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4d8:	48c5                	li	a7,17
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4e0:	48c9                	li	a7,18
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e8:	48a1                	li	a7,8
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <link>:
.global link
link:
 li a7, SYS_link
 4f0:	48cd                	li	a7,19
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4f8:	48d1                	li	a7,20
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 500:	48a5                	li	a7,9
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <dup>:
.global dup
dup:
 li a7, SYS_dup
 508:	48a9                	li	a7,10
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 510:	48ad                	li	a7,11
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 518:	48b1                	li	a7,12
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 520:	48b5                	li	a7,13
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 528:	48b9                	li	a7,14
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 530:	48dd                	li	a7,23
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 538:	48e5                	li	a7,25
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 540:	48e9                	li	a7,26
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 548:	48ed                	li	a7,27
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 550:	1101                	addi	sp,sp,-32
 552:	ec06                	sd	ra,24(sp)
 554:	e822                	sd	s0,16(sp)
 556:	1000                	addi	s0,sp,32
 558:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 55c:	4605                	li	a2,1
 55e:	fef40593          	addi	a1,s0,-17
 562:	00000097          	auipc	ra,0x0
 566:	f4e080e7          	jalr	-178(ra) # 4b0 <write>
}
 56a:	60e2                	ld	ra,24(sp)
 56c:	6442                	ld	s0,16(sp)
 56e:	6105                	addi	sp,sp,32
 570:	8082                	ret

0000000000000572 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 572:	7139                	addi	sp,sp,-64
 574:	fc06                	sd	ra,56(sp)
 576:	f822                	sd	s0,48(sp)
 578:	f426                	sd	s1,40(sp)
 57a:	f04a                	sd	s2,32(sp)
 57c:	ec4e                	sd	s3,24(sp)
 57e:	0080                	addi	s0,sp,64
 580:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 582:	c299                	beqz	a3,588 <printint+0x16>
 584:	0805c863          	bltz	a1,614 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 588:	2581                	sext.w	a1,a1
  neg = 0;
 58a:	4881                	li	a7,0
 58c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 590:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 592:	2601                	sext.w	a2,a2
 594:	00000517          	auipc	a0,0x0
 598:	56450513          	addi	a0,a0,1380 # af8 <digits>
 59c:	883a                	mv	a6,a4
 59e:	2705                	addiw	a4,a4,1
 5a0:	02c5f7bb          	remuw	a5,a1,a2
 5a4:	1782                	slli	a5,a5,0x20
 5a6:	9381                	srli	a5,a5,0x20
 5a8:	97aa                	add	a5,a5,a0
 5aa:	0007c783          	lbu	a5,0(a5)
 5ae:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5b2:	0005879b          	sext.w	a5,a1
 5b6:	02c5d5bb          	divuw	a1,a1,a2
 5ba:	0685                	addi	a3,a3,1
 5bc:	fec7f0e3          	bgeu	a5,a2,59c <printint+0x2a>
  if(neg)
 5c0:	00088b63          	beqz	a7,5d6 <printint+0x64>
    buf[i++] = '-';
 5c4:	fd040793          	addi	a5,s0,-48
 5c8:	973e                	add	a4,a4,a5
 5ca:	02d00793          	li	a5,45
 5ce:	fef70823          	sb	a5,-16(a4)
 5d2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5d6:	02e05863          	blez	a4,606 <printint+0x94>
 5da:	fc040793          	addi	a5,s0,-64
 5de:	00e78933          	add	s2,a5,a4
 5e2:	fff78993          	addi	s3,a5,-1
 5e6:	99ba                	add	s3,s3,a4
 5e8:	377d                	addiw	a4,a4,-1
 5ea:	1702                	slli	a4,a4,0x20
 5ec:	9301                	srli	a4,a4,0x20
 5ee:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5f2:	fff94583          	lbu	a1,-1(s2)
 5f6:	8526                	mv	a0,s1
 5f8:	00000097          	auipc	ra,0x0
 5fc:	f58080e7          	jalr	-168(ra) # 550 <putc>
  while(--i >= 0)
 600:	197d                	addi	s2,s2,-1
 602:	ff3918e3          	bne	s2,s3,5f2 <printint+0x80>
}
 606:	70e2                	ld	ra,56(sp)
 608:	7442                	ld	s0,48(sp)
 60a:	74a2                	ld	s1,40(sp)
 60c:	7902                	ld	s2,32(sp)
 60e:	69e2                	ld	s3,24(sp)
 610:	6121                	addi	sp,sp,64
 612:	8082                	ret
    x = -xx;
 614:	40b005bb          	negw	a1,a1
    neg = 1;
 618:	4885                	li	a7,1
    x = -xx;
 61a:	bf8d                	j	58c <printint+0x1a>

000000000000061c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 61c:	7119                	addi	sp,sp,-128
 61e:	fc86                	sd	ra,120(sp)
 620:	f8a2                	sd	s0,112(sp)
 622:	f4a6                	sd	s1,104(sp)
 624:	f0ca                	sd	s2,96(sp)
 626:	ecce                	sd	s3,88(sp)
 628:	e8d2                	sd	s4,80(sp)
 62a:	e4d6                	sd	s5,72(sp)
 62c:	e0da                	sd	s6,64(sp)
 62e:	fc5e                	sd	s7,56(sp)
 630:	f862                	sd	s8,48(sp)
 632:	f466                	sd	s9,40(sp)
 634:	f06a                	sd	s10,32(sp)
 636:	ec6e                	sd	s11,24(sp)
 638:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 63a:	0005c903          	lbu	s2,0(a1)
 63e:	18090f63          	beqz	s2,7dc <vprintf+0x1c0>
 642:	8aaa                	mv	s5,a0
 644:	8b32                	mv	s6,a2
 646:	00158493          	addi	s1,a1,1
  state = 0;
 64a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 64c:	02500a13          	li	s4,37
      if(c == 'd'){
 650:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 654:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 658:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 65c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 660:	00000b97          	auipc	s7,0x0
 664:	498b8b93          	addi	s7,s7,1176 # af8 <digits>
 668:	a839                	j	686 <vprintf+0x6a>
        putc(fd, c);
 66a:	85ca                	mv	a1,s2
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	ee2080e7          	jalr	-286(ra) # 550 <putc>
 676:	a019                	j	67c <vprintf+0x60>
    } else if(state == '%'){
 678:	01498f63          	beq	s3,s4,696 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 67c:	0485                	addi	s1,s1,1
 67e:	fff4c903          	lbu	s2,-1(s1)
 682:	14090d63          	beqz	s2,7dc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 686:	0009079b          	sext.w	a5,s2
    if(state == 0){
 68a:	fe0997e3          	bnez	s3,678 <vprintf+0x5c>
      if(c == '%'){
 68e:	fd479ee3          	bne	a5,s4,66a <vprintf+0x4e>
        state = '%';
 692:	89be                	mv	s3,a5
 694:	b7e5                	j	67c <vprintf+0x60>
      if(c == 'd'){
 696:	05878063          	beq	a5,s8,6d6 <vprintf+0xba>
      } else if(c == 'l') {
 69a:	05978c63          	beq	a5,s9,6f2 <vprintf+0xd6>
      } else if(c == 'x') {
 69e:	07a78863          	beq	a5,s10,70e <vprintf+0xf2>
      } else if(c == 'p') {
 6a2:	09b78463          	beq	a5,s11,72a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6a6:	07300713          	li	a4,115
 6aa:	0ce78663          	beq	a5,a4,776 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ae:	06300713          	li	a4,99
 6b2:	0ee78e63          	beq	a5,a4,7ae <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6b6:	11478863          	beq	a5,s4,7c6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ba:	85d2                	mv	a1,s4
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	e92080e7          	jalr	-366(ra) # 550 <putc>
        putc(fd, c);
 6c6:	85ca                	mv	a1,s2
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	e86080e7          	jalr	-378(ra) # 550 <putc>
      }
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	b765                	j	67c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6d6:	008b0913          	addi	s2,s6,8
 6da:	4685                	li	a3,1
 6dc:	4629                	li	a2,10
 6de:	000b2583          	lw	a1,0(s6)
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	e8e080e7          	jalr	-370(ra) # 572 <printint>
 6ec:	8b4a                	mv	s6,s2
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b771                	j	67c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f2:	008b0913          	addi	s2,s6,8
 6f6:	4681                	li	a3,0
 6f8:	4629                	li	a2,10
 6fa:	000b2583          	lw	a1,0(s6)
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	e72080e7          	jalr	-398(ra) # 572 <printint>
 708:	8b4a                	mv	s6,s2
      state = 0;
 70a:	4981                	li	s3,0
 70c:	bf85                	j	67c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 70e:	008b0913          	addi	s2,s6,8
 712:	4681                	li	a3,0
 714:	4641                	li	a2,16
 716:	000b2583          	lw	a1,0(s6)
 71a:	8556                	mv	a0,s5
 71c:	00000097          	auipc	ra,0x0
 720:	e56080e7          	jalr	-426(ra) # 572 <printint>
 724:	8b4a                	mv	s6,s2
      state = 0;
 726:	4981                	li	s3,0
 728:	bf91                	j	67c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 72a:	008b0793          	addi	a5,s6,8
 72e:	f8f43423          	sd	a5,-120(s0)
 732:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 736:	03000593          	li	a1,48
 73a:	8556                	mv	a0,s5
 73c:	00000097          	auipc	ra,0x0
 740:	e14080e7          	jalr	-492(ra) # 550 <putc>
  putc(fd, 'x');
 744:	85ea                	mv	a1,s10
 746:	8556                	mv	a0,s5
 748:	00000097          	auipc	ra,0x0
 74c:	e08080e7          	jalr	-504(ra) # 550 <putc>
 750:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 752:	03c9d793          	srli	a5,s3,0x3c
 756:	97de                	add	a5,a5,s7
 758:	0007c583          	lbu	a1,0(a5)
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	df2080e7          	jalr	-526(ra) # 550 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 766:	0992                	slli	s3,s3,0x4
 768:	397d                	addiw	s2,s2,-1
 76a:	fe0914e3          	bnez	s2,752 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 76e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 772:	4981                	li	s3,0
 774:	b721                	j	67c <vprintf+0x60>
        s = va_arg(ap, char*);
 776:	008b0993          	addi	s3,s6,8
 77a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 77e:	02090163          	beqz	s2,7a0 <vprintf+0x184>
        while(*s != 0){
 782:	00094583          	lbu	a1,0(s2)
 786:	c9a1                	beqz	a1,7d6 <vprintf+0x1ba>
          putc(fd, *s);
 788:	8556                	mv	a0,s5
 78a:	00000097          	auipc	ra,0x0
 78e:	dc6080e7          	jalr	-570(ra) # 550 <putc>
          s++;
 792:	0905                	addi	s2,s2,1
        while(*s != 0){
 794:	00094583          	lbu	a1,0(s2)
 798:	f9e5                	bnez	a1,788 <vprintf+0x16c>
        s = va_arg(ap, char*);
 79a:	8b4e                	mv	s6,s3
      state = 0;
 79c:	4981                	li	s3,0
 79e:	bdf9                	j	67c <vprintf+0x60>
          s = "(null)";
 7a0:	00000917          	auipc	s2,0x0
 7a4:	35090913          	addi	s2,s2,848 # af0 <malloc+0x20a>
        while(*s != 0){
 7a8:	02800593          	li	a1,40
 7ac:	bff1                	j	788 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7ae:	008b0913          	addi	s2,s6,8
 7b2:	000b4583          	lbu	a1,0(s6)
 7b6:	8556                	mv	a0,s5
 7b8:	00000097          	auipc	ra,0x0
 7bc:	d98080e7          	jalr	-616(ra) # 550 <putc>
 7c0:	8b4a                	mv	s6,s2
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	bd65                	j	67c <vprintf+0x60>
        putc(fd, c);
 7c6:	85d2                	mv	a1,s4
 7c8:	8556                	mv	a0,s5
 7ca:	00000097          	auipc	ra,0x0
 7ce:	d86080e7          	jalr	-634(ra) # 550 <putc>
      state = 0;
 7d2:	4981                	li	s3,0
 7d4:	b565                	j	67c <vprintf+0x60>
        s = va_arg(ap, char*);
 7d6:	8b4e                	mv	s6,s3
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	b54d                	j	67c <vprintf+0x60>
    }
  }
}
 7dc:	70e6                	ld	ra,120(sp)
 7de:	7446                	ld	s0,112(sp)
 7e0:	74a6                	ld	s1,104(sp)
 7e2:	7906                	ld	s2,96(sp)
 7e4:	69e6                	ld	s3,88(sp)
 7e6:	6a46                	ld	s4,80(sp)
 7e8:	6aa6                	ld	s5,72(sp)
 7ea:	6b06                	ld	s6,64(sp)
 7ec:	7be2                	ld	s7,56(sp)
 7ee:	7c42                	ld	s8,48(sp)
 7f0:	7ca2                	ld	s9,40(sp)
 7f2:	7d02                	ld	s10,32(sp)
 7f4:	6de2                	ld	s11,24(sp)
 7f6:	6109                	addi	sp,sp,128
 7f8:	8082                	ret

00000000000007fa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7fa:	715d                	addi	sp,sp,-80
 7fc:	ec06                	sd	ra,24(sp)
 7fe:	e822                	sd	s0,16(sp)
 800:	1000                	addi	s0,sp,32
 802:	e010                	sd	a2,0(s0)
 804:	e414                	sd	a3,8(s0)
 806:	e818                	sd	a4,16(s0)
 808:	ec1c                	sd	a5,24(s0)
 80a:	03043023          	sd	a6,32(s0)
 80e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 812:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 816:	8622                	mv	a2,s0
 818:	00000097          	auipc	ra,0x0
 81c:	e04080e7          	jalr	-508(ra) # 61c <vprintf>
}
 820:	60e2                	ld	ra,24(sp)
 822:	6442                	ld	s0,16(sp)
 824:	6161                	addi	sp,sp,80
 826:	8082                	ret

0000000000000828 <printf>:

void
printf(const char *fmt, ...)
{
 828:	711d                	addi	sp,sp,-96
 82a:	ec06                	sd	ra,24(sp)
 82c:	e822                	sd	s0,16(sp)
 82e:	1000                	addi	s0,sp,32
 830:	e40c                	sd	a1,8(s0)
 832:	e810                	sd	a2,16(s0)
 834:	ec14                	sd	a3,24(s0)
 836:	f018                	sd	a4,32(s0)
 838:	f41c                	sd	a5,40(s0)
 83a:	03043823          	sd	a6,48(s0)
 83e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 842:	00840613          	addi	a2,s0,8
 846:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 84a:	85aa                	mv	a1,a0
 84c:	4505                	li	a0,1
 84e:	00000097          	auipc	ra,0x0
 852:	dce080e7          	jalr	-562(ra) # 61c <vprintf>
}
 856:	60e2                	ld	ra,24(sp)
 858:	6442                	ld	s0,16(sp)
 85a:	6125                	addi	sp,sp,96
 85c:	8082                	ret

000000000000085e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 85e:	1141                	addi	sp,sp,-16
 860:	e422                	sd	s0,8(sp)
 862:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 864:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 868:	00000797          	auipc	a5,0x0
 86c:	7987b783          	ld	a5,1944(a5) # 1000 <freep>
 870:	a805                	j	8a0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 872:	4618                	lw	a4,8(a2)
 874:	9db9                	addw	a1,a1,a4
 876:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87a:	6398                	ld	a4,0(a5)
 87c:	6318                	ld	a4,0(a4)
 87e:	fee53823          	sd	a4,-16(a0)
 882:	a091                	j	8c6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 884:	ff852703          	lw	a4,-8(a0)
 888:	9e39                	addw	a2,a2,a4
 88a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 88c:	ff053703          	ld	a4,-16(a0)
 890:	e398                	sd	a4,0(a5)
 892:	a099                	j	8d8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 894:	6398                	ld	a4,0(a5)
 896:	00e7e463          	bltu	a5,a4,89e <free+0x40>
 89a:	00e6ea63          	bltu	a3,a4,8ae <free+0x50>
{
 89e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a0:	fed7fae3          	bgeu	a5,a3,894 <free+0x36>
 8a4:	6398                	ld	a4,0(a5)
 8a6:	00e6e463          	bltu	a3,a4,8ae <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8aa:	fee7eae3          	bltu	a5,a4,89e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8ae:	ff852583          	lw	a1,-8(a0)
 8b2:	6390                	ld	a2,0(a5)
 8b4:	02059713          	slli	a4,a1,0x20
 8b8:	9301                	srli	a4,a4,0x20
 8ba:	0712                	slli	a4,a4,0x4
 8bc:	9736                	add	a4,a4,a3
 8be:	fae60ae3          	beq	a2,a4,872 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8c2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c6:	4790                	lw	a2,8(a5)
 8c8:	02061713          	slli	a4,a2,0x20
 8cc:	9301                	srli	a4,a4,0x20
 8ce:	0712                	slli	a4,a4,0x4
 8d0:	973e                	add	a4,a4,a5
 8d2:	fae689e3          	beq	a3,a4,884 <free+0x26>
  } else
    p->s.ptr = bp;
 8d6:	e394                	sd	a3,0(a5)
  freep = p;
 8d8:	00000717          	auipc	a4,0x0
 8dc:	72f73423          	sd	a5,1832(a4) # 1000 <freep>
}
 8e0:	6422                	ld	s0,8(sp)
 8e2:	0141                	addi	sp,sp,16
 8e4:	8082                	ret

00000000000008e6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e6:	7139                	addi	sp,sp,-64
 8e8:	fc06                	sd	ra,56(sp)
 8ea:	f822                	sd	s0,48(sp)
 8ec:	f426                	sd	s1,40(sp)
 8ee:	f04a                	sd	s2,32(sp)
 8f0:	ec4e                	sd	s3,24(sp)
 8f2:	e852                	sd	s4,16(sp)
 8f4:	e456                	sd	s5,8(sp)
 8f6:	e05a                	sd	s6,0(sp)
 8f8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8fa:	02051493          	slli	s1,a0,0x20
 8fe:	9081                	srli	s1,s1,0x20
 900:	04bd                	addi	s1,s1,15
 902:	8091                	srli	s1,s1,0x4
 904:	0014899b          	addiw	s3,s1,1
 908:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 90a:	00000517          	auipc	a0,0x0
 90e:	6f653503          	ld	a0,1782(a0) # 1000 <freep>
 912:	c515                	beqz	a0,93e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 914:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 916:	4798                	lw	a4,8(a5)
 918:	02977f63          	bgeu	a4,s1,956 <malloc+0x70>
 91c:	8a4e                	mv	s4,s3
 91e:	0009871b          	sext.w	a4,s3
 922:	6685                	lui	a3,0x1
 924:	00d77363          	bgeu	a4,a3,92a <malloc+0x44>
 928:	6a05                	lui	s4,0x1
 92a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 932:	00000917          	auipc	s2,0x0
 936:	6ce90913          	addi	s2,s2,1742 # 1000 <freep>
  if(p == (char*)-1)
 93a:	5afd                	li	s5,-1
 93c:	a88d                	j	9ae <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 93e:	00000797          	auipc	a5,0x0
 942:	6d278793          	addi	a5,a5,1746 # 1010 <base>
 946:	00000717          	auipc	a4,0x0
 94a:	6af73d23          	sd	a5,1722(a4) # 1000 <freep>
 94e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 950:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 954:	b7e1                	j	91c <malloc+0x36>
      if(p->s.size == nunits)
 956:	02e48b63          	beq	s1,a4,98c <malloc+0xa6>
        p->s.size -= nunits;
 95a:	4137073b          	subw	a4,a4,s3
 95e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 960:	1702                	slli	a4,a4,0x20
 962:	9301                	srli	a4,a4,0x20
 964:	0712                	slli	a4,a4,0x4
 966:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 968:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 96c:	00000717          	auipc	a4,0x0
 970:	68a73a23          	sd	a0,1684(a4) # 1000 <freep>
      return (void*)(p + 1);
 974:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 978:	70e2                	ld	ra,56(sp)
 97a:	7442                	ld	s0,48(sp)
 97c:	74a2                	ld	s1,40(sp)
 97e:	7902                	ld	s2,32(sp)
 980:	69e2                	ld	s3,24(sp)
 982:	6a42                	ld	s4,16(sp)
 984:	6aa2                	ld	s5,8(sp)
 986:	6b02                	ld	s6,0(sp)
 988:	6121                	addi	sp,sp,64
 98a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 98c:	6398                	ld	a4,0(a5)
 98e:	e118                	sd	a4,0(a0)
 990:	bff1                	j	96c <malloc+0x86>
  hp->s.size = nu;
 992:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 996:	0541                	addi	a0,a0,16
 998:	00000097          	auipc	ra,0x0
 99c:	ec6080e7          	jalr	-314(ra) # 85e <free>
  return freep;
 9a0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9a4:	d971                	beqz	a0,978 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a8:	4798                	lw	a4,8(a5)
 9aa:	fa9776e3          	bgeu	a4,s1,956 <malloc+0x70>
    if(p == freep)
 9ae:	00093703          	ld	a4,0(s2)
 9b2:	853e                	mv	a0,a5
 9b4:	fef719e3          	bne	a4,a5,9a6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9b8:	8552                	mv	a0,s4
 9ba:	00000097          	auipc	ra,0x0
 9be:	b5e080e7          	jalr	-1186(ra) # 518 <sbrk>
  if(p == (char*)-1)
 9c2:	fd5518e3          	bne	a0,s5,992 <malloc+0xac>
        return 0;
 9c6:	4501                	li	a0,0
 9c8:	bf45                	j	978 <malloc+0x92>
