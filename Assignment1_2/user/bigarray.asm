
user/_bigarray:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <itoa>:
#define NUM_CHILDREN 4

int arr[SIZE];

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
  86:	7131                	addi	sp,sp,-192
  88:	fd06                	sd	ra,184(sp)
  8a:	f922                	sd	s0,176(sp)
  8c:	f526                	sd	s1,168(sp)
  8e:	f14a                	sd	s2,160(sp)
  90:	0180                	addi	s0,sp,192
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);
  92:	4591                	li	a1,4
  94:	00001517          	auipc	a0,0x1
  98:	a0c50513          	addi	a0,a0,-1524 # aa0 <malloc+0x108>
  9c:	00001097          	auipc	ra,0x1
  a0:	83e080e7          	jalr	-1986(ra) # 8da <printf>

  // Initialize array with consecutive numbers
  for (int i = 0; i < SIZE; i++) arr[i] = i;
  a4:	00001717          	auipc	a4,0x1
  a8:	f6c70713          	addi	a4,a4,-148 # 1010 <arr>
  ac:	4781                	li	a5,0
  ae:	66c1                	lui	a3,0x10
  b0:	c31c                	sw	a5,0(a4)
  b2:	2785                	addiw	a5,a5,1
  b4:	0711                	addi	a4,a4,4
  b6:	fed79de3          	bne	a5,a3,b0 <main+0x2a>

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN];
  int n = NUM_CHILDREN;
  ba:	4791                	li	a5,4
  bc:	faf42e23          	sw	a5,-68(s0)

  long long expected = ((long long)(SIZE - 1) * SIZE) / 2;

  // Custom system call forkn to create child processes
  int ret = forkn(NUM_CHILDREN, pids);
  c0:	fd040593          	addi	a1,s0,-48
  c4:	4511                	li	a0,4
  c6:	00000097          	auipc	ra,0x0
  ca:	524080e7          	jalr	1316(ra) # 5ea <forkn>
  ce:	84aa                	mv	s1,a0
  if (ret > 0) {
  d0:	0ea05063          	blez	a0,1b0 <main+0x12a>
    int id = ret - 1;
  d4:	fff5079b          	addiw	a5,a0,-1
  d8:	0007851b          	sext.w	a0,a5
    int chunk = SIZE / NUM_CHILDREN;
    long long sum = 0;  // Use long long to prevent overflow

    for (int i = id * chunk; i < (id + 1) * chunk; i++)
  dc:	00e7979b          	slliw	a5,a5,0xe
  e0:	0007871b          	sext.w	a4,a5
  e4:	6611                	lui	a2,0x4
  e6:	9e3d                	addw	a2,a2,a5
  e8:	00271793          	slli	a5,a4,0x2
  ec:	00001697          	auipc	a3,0x1
  f0:	f2468693          	addi	a3,a3,-220 # 1010 <arr>
  f4:	97b6                	add	a5,a5,a3
    long long sum = 0;  // Use long long to prevent overflow
  f6:	4901                	li	s2,0
      sum += arr[i];
  f8:	4394                	lw	a3,0(a5)
  fa:	9936                	add	s2,s2,a3
    for (int i = id * chunk; i < (id + 1) * chunk; i++)
  fc:	2705                	addiw	a4,a4,1
  fe:	0791                	addi	a5,a5,4
 100:	fec74ce3          	blt	a4,a2,f8 <main+0x72>

    // Print sum without printf to avoid interleaving output
    char buf[100], tmp[20];
    char *p = buf;

    char *s1 = "Child ", *s2 = " calculated sum: ";
 104:	00001717          	auipc	a4,0x1
 108:	97c70713          	addi	a4,a4,-1668 # a80 <malloc+0xe8>
    char *p = buf;
 10c:	f5840493          	addi	s1,s0,-168
    while (*s1) *p++ = *s1++;
 110:	04300793          	li	a5,67
 114:	0705                	addi	a4,a4,1
 116:	0485                	addi	s1,s1,1
 118:	fef48fa3          	sb	a5,-1(s1)
 11c:	00074783          	lbu	a5,0(a4)
 120:	fbf5                	bnez	a5,114 <main+0x8e>
    itoa(id, tmp); char *tp = tmp;
 122:	f4040593          	addi	a1,s0,-192
 126:	00000097          	auipc	ra,0x0
 12a:	eda080e7          	jalr	-294(ra) # 0 <itoa>
    while (*tp) *p++ = *tp++;
 12e:	f4044783          	lbu	a5,-192(s0)
 132:	cb91                	beqz	a5,146 <main+0xc0>
    itoa(id, tmp); char *tp = tmp;
 134:	f4040713          	addi	a4,s0,-192
    while (*tp) *p++ = *tp++;
 138:	0705                	addi	a4,a4,1
 13a:	0485                	addi	s1,s1,1
 13c:	fef48fa3          	sb	a5,-1(s1)
 140:	00074783          	lbu	a5,0(a4)
 144:	fbf5                	bnez	a5,138 <main+0xb2>
    char *s1 = "Child ", *s2 = " calculated sum: ";
 146:	00001717          	auipc	a4,0x1
 14a:	94270713          	addi	a4,a4,-1726 # a88 <malloc+0xf0>
    while (*s2) *p++ = *s2++;
 14e:	02000793          	li	a5,32
 152:	0705                	addi	a4,a4,1
 154:	0485                	addi	s1,s1,1
 156:	fef48fa3          	sb	a5,-1(s1)
 15a:	00074783          	lbu	a5,0(a4)
 15e:	fbf5                	bnez	a5,152 <main+0xcc>
    itoa(sum, tmp); tp = tmp;
 160:	2901                	sext.w	s2,s2
 162:	f4040593          	addi	a1,s0,-192
 166:	854a                	mv	a0,s2
 168:	00000097          	auipc	ra,0x0
 16c:	e98080e7          	jalr	-360(ra) # 0 <itoa>
    while (*tp) *p++ = *tp++;
 170:	f4044783          	lbu	a5,-192(s0)
 174:	cb91                	beqz	a5,188 <main+0x102>
    itoa(sum, tmp); tp = tmp;
 176:	f4040713          	addi	a4,s0,-192
    while (*tp) *p++ = *tp++;
 17a:	0705                	addi	a4,a4,1
 17c:	0485                	addi	s1,s1,1
 17e:	fef48fa3          	sb	a5,-1(s1)
 182:	00074783          	lbu	a5,0(a4)
 186:	fbf5                	bnez	a5,17a <main+0xf4>
    *p++ = '\n'; *p = 0;
 188:	47a9                	li	a5,10
 18a:	00f48023          	sb	a5,0(s1)
 18e:	000480a3          	sb	zero,1(s1)
 192:	00148613          	addi	a2,s1,1

    write(1, buf, p - buf);
 196:	f5840593          	addi	a1,s0,-168
 19a:	9e0d                	subw	a2,a2,a1
 19c:	4505                	li	a0,1
 19e:	00000097          	auipc	ra,0x0
 1a2:	3c4080e7          	jalr	964(ra) # 562 <write>
    exit(sum); // Send sum as exit status
 1a6:	854a                	mv	a0,s2
 1a8:	00000097          	auipc	ra,0x0
 1ac:	392080e7          	jalr	914(ra) # 53a <exit>
  } else if (ret == 0) {
 1b0:	ed4d                	bnez	a0,26a <main+0x1e4>
    printf("===> Waiting for children with waitall()\n");
 1b2:	00001517          	auipc	a0,0x1
 1b6:	90e50513          	addi	a0,a0,-1778 # ac0 <malloc+0x128>
 1ba:	00000097          	auipc	ra,0x0
 1be:	720080e7          	jalr	1824(ra) # 8da <printf>

    if (waitall(&n, statuses) < 0) {
 1c2:	fc040593          	addi	a1,s0,-64
 1c6:	fbc40513          	addi	a0,s0,-68
 1ca:	00000097          	auipc	ra,0x0
 1ce:	428080e7          	jalr	1064(ra) # 5f2 <waitall>
 1d2:	06054463          	bltz	a0,23a <main+0x1b4>
      printf("waitall failed\n");
      exit(-1);
    }

    long long total = 0;
    for (int i = 0; i < n; i++)
 1d6:	fbc42583          	lw	a1,-68(s0)
 1da:	0ab05563          	blez	a1,284 <main+0x1fe>
 1de:	fc040793          	addi	a5,s0,-64
    long long total = 0;
 1e2:	4901                	li	s2,0
      total += statuses[i];  // Accumulate child exit statuses
 1e4:	4398                	lw	a4,0(a5)
 1e6:	993a                	add	s2,s2,a4
    for (int i = 0; i < n; i++)
 1e8:	2485                	addiw	s1,s1,1
 1ea:	0791                	addi	a5,a5,4
 1ec:	feb49ce3          	bne	s1,a1,1e4 <main+0x15e>

    printf("===> All %d children finished\n", n);
 1f0:	00001517          	auipc	a0,0x1
 1f4:	91050513          	addi	a0,a0,-1776 # b00 <malloc+0x168>
 1f8:	00000097          	auipc	ra,0x0
 1fc:	6e2080e7          	jalr	1762(ra) # 8da <printf>
    printf("Total sum: %lld\n", total);
 200:	85ca                	mv	a1,s2
 202:	00001517          	auipc	a0,0x1
 206:	91e50513          	addi	a0,a0,-1762 # b20 <malloc+0x188>
 20a:	00000097          	auipc	ra,0x0
 20e:	6d0080e7          	jalr	1744(ra) # 8da <printf>

    if (total == expected)
 212:	7fff87b7          	lui	a5,0x7fff8
 216:	02f90f63          	beq	s2,a5,254 <main+0x1ce>
      printf("Correct total sum: %lld\n", total);
    else
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);
 21a:	7fff8637          	lui	a2,0x7fff8
 21e:	85ca                	mv	a1,s2
 220:	00001517          	auipc	a0,0x1
 224:	93850513          	addi	a0,a0,-1736 # b58 <malloc+0x1c0>
 228:	00000097          	auipc	ra,0x0
 22c:	6b2080e7          	jalr	1714(ra) # 8da <printf>

    exit(0);
 230:	4501                	li	a0,0
 232:	00000097          	auipc	ra,0x0
 236:	308080e7          	jalr	776(ra) # 53a <exit>
      printf("waitall failed\n");
 23a:	00001517          	auipc	a0,0x1
 23e:	8b650513          	addi	a0,a0,-1866 # af0 <malloc+0x158>
 242:	00000097          	auipc	ra,0x0
 246:	698080e7          	jalr	1688(ra) # 8da <printf>
      exit(-1);
 24a:	557d                	li	a0,-1
 24c:	00000097          	auipc	ra,0x0
 250:	2ee080e7          	jalr	750(ra) # 53a <exit>
      printf("Correct total sum: %lld\n", total);
 254:	7fff85b7          	lui	a1,0x7fff8
 258:	00001517          	auipc	a0,0x1
 25c:	8e050513          	addi	a0,a0,-1824 # b38 <malloc+0x1a0>
 260:	00000097          	auipc	ra,0x0
 264:	67a080e7          	jalr	1658(ra) # 8da <printf>
 268:	b7e1                	j	230 <main+0x1aa>
  } else {
    printf("forkn failed\n");
 26a:	00001517          	auipc	a0,0x1
 26e:	91650513          	addi	a0,a0,-1770 # b80 <malloc+0x1e8>
 272:	00000097          	auipc	ra,0x0
 276:	668080e7          	jalr	1640(ra) # 8da <printf>
    exit(-1);
 27a:	557d                	li	a0,-1
 27c:	00000097          	auipc	ra,0x0
 280:	2be080e7          	jalr	702(ra) # 53a <exit>
    printf("===> All %d children finished\n", n);
 284:	00001517          	auipc	a0,0x1
 288:	87c50513          	addi	a0,a0,-1924 # b00 <malloc+0x168>
 28c:	00000097          	auipc	ra,0x0
 290:	64e080e7          	jalr	1614(ra) # 8da <printf>
    printf("Total sum: %lld\n", total);
 294:	4581                	li	a1,0
 296:	00001517          	auipc	a0,0x1
 29a:	88a50513          	addi	a0,a0,-1910 # b20 <malloc+0x188>
 29e:	00000097          	auipc	ra,0x0
 2a2:	63c080e7          	jalr	1596(ra) # 8da <printf>
    long long total = 0;
 2a6:	4901                	li	s2,0
 2a8:	bf8d                	j	21a <main+0x194>

00000000000002aa <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e406                	sd	ra,8(sp)
 2ae:	e022                	sd	s0,0(sp)
 2b0:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2b2:	00000097          	auipc	ra,0x0
 2b6:	dd4080e7          	jalr	-556(ra) # 86 <main>
  exit(0);
 2ba:	4501                	li	a0,0
 2bc:	00000097          	auipc	ra,0x0
 2c0:	27e080e7          	jalr	638(ra) # 53a <exit>

00000000000002c4 <strcpy>:
}

char* strcpy(char *s, const char *t)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2ca:	87aa                	mv	a5,a0
 2cc:	0585                	addi	a1,a1,1
 2ce:	0785                	addi	a5,a5,1
 2d0:	fff5c703          	lbu	a4,-1(a1) # 7fff7fff <base+0x7ffb6fef>
 2d4:	fee78fa3          	sb	a4,-1(a5) # 7fff7fff <base+0x7ffb6fef>
 2d8:	fb75                	bnez	a4,2cc <strcpy+0x8>
    ;
  return os;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret

00000000000002e0 <strcmp>:

int strcmp(const char *p, const char *q)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2e6:	00054783          	lbu	a5,0(a0)
 2ea:	cb91                	beqz	a5,2fe <strcmp+0x1e>
 2ec:	0005c703          	lbu	a4,0(a1)
 2f0:	00f71763          	bne	a4,a5,2fe <strcmp+0x1e>
    p++, q++;
 2f4:	0505                	addi	a0,a0,1
 2f6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	fbe5                	bnez	a5,2ec <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2fe:	0005c503          	lbu	a0,0(a1)
}
 302:	40a7853b          	subw	a0,a5,a0
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <strlen>:

uint strlen(const char *s)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 312:	00054783          	lbu	a5,0(a0)
 316:	cf91                	beqz	a5,332 <strlen+0x26>
 318:	0505                	addi	a0,a0,1
 31a:	87aa                	mv	a5,a0
 31c:	4685                	li	a3,1
 31e:	9e89                	subw	a3,a3,a0
 320:	00f6853b          	addw	a0,a3,a5
 324:	0785                	addi	a5,a5,1
 326:	fff7c703          	lbu	a4,-1(a5)
 32a:	fb7d                	bnez	a4,320 <strlen+0x14>
    ;
  return n;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  for(n = 0; s[n]; n++)
 332:	4501                	li	a0,0
 334:	bfe5                	j	32c <strlen+0x20>

0000000000000336 <memset>:

void* memset(void *dst, int c, uint n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 33c:	ce09                	beqz	a2,356 <memset+0x20>
 33e:	87aa                	mv	a5,a0
 340:	fff6071b          	addiw	a4,a2,-1
 344:	1702                	slli	a4,a4,0x20
 346:	9301                	srli	a4,a4,0x20
 348:	0705                	addi	a4,a4,1
 34a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 34c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 350:	0785                	addi	a5,a5,1
 352:	fee79de3          	bne	a5,a4,34c <memset+0x16>
  }
  return dst;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret

000000000000035c <strchr>:

char* strchr(const char *s, char c)
{
 35c:	1141                	addi	sp,sp,-16
 35e:	e422                	sd	s0,8(sp)
 360:	0800                	addi	s0,sp,16
  for(; *s; s++)
 362:	00054783          	lbu	a5,0(a0)
 366:	cb99                	beqz	a5,37c <strchr+0x20>
    if(*s == c)
 368:	00f58763          	beq	a1,a5,376 <strchr+0x1a>
  for(; *s; s++)
 36c:	0505                	addi	a0,a0,1
 36e:	00054783          	lbu	a5,0(a0)
 372:	fbfd                	bnez	a5,368 <strchr+0xc>
      return (char*)s;
  return 0;
 374:	4501                	li	a0,0
}
 376:	6422                	ld	s0,8(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret
  return 0;
 37c:	4501                	li	a0,0
 37e:	bfe5                	j	376 <strchr+0x1a>

0000000000000380 <gets>:

char* gets(char *buf, int max)
{
 380:	711d                	addi	sp,sp,-96
 382:	ec86                	sd	ra,88(sp)
 384:	e8a2                	sd	s0,80(sp)
 386:	e4a6                	sd	s1,72(sp)
 388:	e0ca                	sd	s2,64(sp)
 38a:	fc4e                	sd	s3,56(sp)
 38c:	f852                	sd	s4,48(sp)
 38e:	f456                	sd	s5,40(sp)
 390:	f05a                	sd	s6,32(sp)
 392:	ec5e                	sd	s7,24(sp)
 394:	1080                	addi	s0,sp,96
 396:	8baa                	mv	s7,a0
 398:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 39a:	892a                	mv	s2,a0
 39c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 39e:	4aa9                	li	s5,10
 3a0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3a2:	89a6                	mv	s3,s1
 3a4:	2485                	addiw	s1,s1,1
 3a6:	0344d863          	bge	s1,s4,3d6 <gets+0x56>
    cc = read(0, &c, 1);
 3aa:	4605                	li	a2,1
 3ac:	faf40593          	addi	a1,s0,-81
 3b0:	4501                	li	a0,0
 3b2:	00000097          	auipc	ra,0x0
 3b6:	1a8080e7          	jalr	424(ra) # 55a <read>
    if(cc < 1)
 3ba:	00a05e63          	blez	a0,3d6 <gets+0x56>
    buf[i++] = c;
 3be:	faf44783          	lbu	a5,-81(s0)
 3c2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3c6:	01578763          	beq	a5,s5,3d4 <gets+0x54>
 3ca:	0905                	addi	s2,s2,1
 3cc:	fd679be3          	bne	a5,s6,3a2 <gets+0x22>
  for(i=0; i+1 < max; ){
 3d0:	89a6                	mv	s3,s1
 3d2:	a011                	j	3d6 <gets+0x56>
 3d4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3d6:	99de                	add	s3,s3,s7
 3d8:	00098023          	sb	zero,0(s3)
  return buf;
}
 3dc:	855e                	mv	a0,s7
 3de:	60e6                	ld	ra,88(sp)
 3e0:	6446                	ld	s0,80(sp)
 3e2:	64a6                	ld	s1,72(sp)
 3e4:	6906                	ld	s2,64(sp)
 3e6:	79e2                	ld	s3,56(sp)
 3e8:	7a42                	ld	s4,48(sp)
 3ea:	7aa2                	ld	s5,40(sp)
 3ec:	7b02                	ld	s6,32(sp)
 3ee:	6be2                	ld	s7,24(sp)
 3f0:	6125                	addi	sp,sp,96
 3f2:	8082                	ret

00000000000003f4 <stat>:

int stat(const char *n, struct stat *st)
{
 3f4:	1101                	addi	sp,sp,-32
 3f6:	ec06                	sd	ra,24(sp)
 3f8:	e822                	sd	s0,16(sp)
 3fa:	e426                	sd	s1,8(sp)
 3fc:	e04a                	sd	s2,0(sp)
 3fe:	1000                	addi	s0,sp,32
 400:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 402:	4581                	li	a1,0
 404:	00000097          	auipc	ra,0x0
 408:	17e080e7          	jalr	382(ra) # 582 <open>
  if(fd < 0)
 40c:	02054563          	bltz	a0,436 <stat+0x42>
 410:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 412:	85ca                	mv	a1,s2
 414:	00000097          	auipc	ra,0x0
 418:	186080e7          	jalr	390(ra) # 59a <fstat>
 41c:	892a                	mv	s2,a0
  close(fd);
 41e:	8526                	mv	a0,s1
 420:	00000097          	auipc	ra,0x0
 424:	14a080e7          	jalr	330(ra) # 56a <close>
  return r;
}
 428:	854a                	mv	a0,s2
 42a:	60e2                	ld	ra,24(sp)
 42c:	6442                	ld	s0,16(sp)
 42e:	64a2                	ld	s1,8(sp)
 430:	6902                	ld	s2,0(sp)
 432:	6105                	addi	sp,sp,32
 434:	8082                	ret
    return -1;
 436:	597d                	li	s2,-1
 438:	bfc5                	j	428 <stat+0x34>

000000000000043a <atoi>:

int atoi(const char *s)
{
 43a:	1141                	addi	sp,sp,-16
 43c:	e422                	sd	s0,8(sp)
 43e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 440:	00054603          	lbu	a2,0(a0)
 444:	fd06079b          	addiw	a5,a2,-48
 448:	0ff7f793          	andi	a5,a5,255
 44c:	4725                	li	a4,9
 44e:	02f76963          	bltu	a4,a5,480 <atoi+0x46>
 452:	86aa                	mv	a3,a0
  n = 0;
 454:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 456:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 458:	0685                	addi	a3,a3,1
 45a:	0025179b          	slliw	a5,a0,0x2
 45e:	9fa9                	addw	a5,a5,a0
 460:	0017979b          	slliw	a5,a5,0x1
 464:	9fb1                	addw	a5,a5,a2
 466:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 46a:	0006c603          	lbu	a2,0(a3)
 46e:	fd06071b          	addiw	a4,a2,-48
 472:	0ff77713          	andi	a4,a4,255
 476:	fee5f1e3          	bgeu	a1,a4,458 <atoi+0x1e>
  return n;
}
 47a:	6422                	ld	s0,8(sp)
 47c:	0141                	addi	sp,sp,16
 47e:	8082                	ret
  n = 0;
 480:	4501                	li	a0,0
 482:	bfe5                	j	47a <atoi+0x40>

0000000000000484 <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 484:	1141                	addi	sp,sp,-16
 486:	e422                	sd	s0,8(sp)
 488:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 48a:	02b57663          	bgeu	a0,a1,4b6 <memmove+0x32>
    while(n-- > 0)
 48e:	02c05163          	blez	a2,4b0 <memmove+0x2c>
 492:	fff6079b          	addiw	a5,a2,-1
 496:	1782                	slli	a5,a5,0x20
 498:	9381                	srli	a5,a5,0x20
 49a:	0785                	addi	a5,a5,1
 49c:	97aa                	add	a5,a5,a0
  dst = vdst;
 49e:	872a                	mv	a4,a0
      *dst++ = *src++;
 4a0:	0585                	addi	a1,a1,1
 4a2:	0705                	addi	a4,a4,1
 4a4:	fff5c683          	lbu	a3,-1(a1)
 4a8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4ac:	fee79ae3          	bne	a5,a4,4a0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4b0:	6422                	ld	s0,8(sp)
 4b2:	0141                	addi	sp,sp,16
 4b4:	8082                	ret
    dst += n;
 4b6:	00c50733          	add	a4,a0,a2
    src += n;
 4ba:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4bc:	fec05ae3          	blez	a2,4b0 <memmove+0x2c>
 4c0:	fff6079b          	addiw	a5,a2,-1
 4c4:	1782                	slli	a5,a5,0x20
 4c6:	9381                	srli	a5,a5,0x20
 4c8:	fff7c793          	not	a5,a5
 4cc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4ce:	15fd                	addi	a1,a1,-1
 4d0:	177d                	addi	a4,a4,-1
 4d2:	0005c683          	lbu	a3,0(a1)
 4d6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4da:	fee79ae3          	bne	a5,a4,4ce <memmove+0x4a>
 4de:	bfc9                	j	4b0 <memmove+0x2c>

00000000000004e0 <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e422                	sd	s0,8(sp)
 4e4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4e6:	ca05                	beqz	a2,516 <memcmp+0x36>
 4e8:	fff6069b          	addiw	a3,a2,-1
 4ec:	1682                	slli	a3,a3,0x20
 4ee:	9281                	srli	a3,a3,0x20
 4f0:	0685                	addi	a3,a3,1
 4f2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4f4:	00054783          	lbu	a5,0(a0)
 4f8:	0005c703          	lbu	a4,0(a1)
 4fc:	00e79863          	bne	a5,a4,50c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 500:	0505                	addi	a0,a0,1
    p2++;
 502:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 504:	fed518e3          	bne	a0,a3,4f4 <memcmp+0x14>
  }
  return 0;
 508:	4501                	li	a0,0
 50a:	a019                	j	510 <memcmp+0x30>
      return *p1 - *p2;
 50c:	40e7853b          	subw	a0,a5,a4
}
 510:	6422                	ld	s0,8(sp)
 512:	0141                	addi	sp,sp,16
 514:	8082                	ret
  return 0;
 516:	4501                	li	a0,0
 518:	bfe5                	j	510 <memcmp+0x30>

000000000000051a <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 51a:	1141                	addi	sp,sp,-16
 51c:	e406                	sd	ra,8(sp)
 51e:	e022                	sd	s0,0(sp)
 520:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 522:	00000097          	auipc	ra,0x0
 526:	f62080e7          	jalr	-158(ra) # 484 <memmove>
}
 52a:	60a2                	ld	ra,8(sp)
 52c:	6402                	ld	s0,0(sp)
 52e:	0141                	addi	sp,sp,16
 530:	8082                	ret

0000000000000532 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 532:	4885                	li	a7,1
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <exit>:
.global exit
exit:
 li a7, SYS_exit
 53a:	4889                	li	a7,2
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 542:	48e1                	li	a7,24
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <wait>:
.global wait
wait:
 li a7, SYS_wait
 54a:	488d                	li	a7,3
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 552:	4891                	li	a7,4
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <read>:
.global read
read:
 li a7, SYS_read
 55a:	4895                	li	a7,5
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <write>:
.global write
write:
 li a7, SYS_write
 562:	48c1                	li	a7,16
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <close>:
.global close
close:
 li a7, SYS_close
 56a:	48d5                	li	a7,21
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <kill>:
.global kill
kill:
 li a7, SYS_kill
 572:	4899                	li	a7,6
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <exec>:
.global exec
exec:
 li a7, SYS_exec
 57a:	489d                	li	a7,7
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <open>:
.global open
open:
 li a7, SYS_open
 582:	48bd                	li	a7,15
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 58a:	48c5                	li	a7,17
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 592:	48c9                	li	a7,18
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 59a:	48a1                	li	a7,8
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <link>:
.global link
link:
 li a7, SYS_link
 5a2:	48cd                	li	a7,19
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5aa:	48d1                	li	a7,20
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5b2:	48a5                	li	a7,9
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <dup>:
.global dup
dup:
 li a7, SYS_dup
 5ba:	48a9                	li	a7,10
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5c2:	48ad                	li	a7,11
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5ca:	48b1                	li	a7,12
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5d2:	48b5                	li	a7,13
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5da:	48b9                	li	a7,14
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 5e2:	48dd                	li	a7,23
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 5ea:	48e5                	li	a7,25
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 5f2:	48e9                	li	a7,26
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 5fa:	48ed                	li	a7,27
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 602:	1101                	addi	sp,sp,-32
 604:	ec06                	sd	ra,24(sp)
 606:	e822                	sd	s0,16(sp)
 608:	1000                	addi	s0,sp,32
 60a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 60e:	4605                	li	a2,1
 610:	fef40593          	addi	a1,s0,-17
 614:	00000097          	auipc	ra,0x0
 618:	f4e080e7          	jalr	-178(ra) # 562 <write>
}
 61c:	60e2                	ld	ra,24(sp)
 61e:	6442                	ld	s0,16(sp)
 620:	6105                	addi	sp,sp,32
 622:	8082                	ret

0000000000000624 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 624:	7139                	addi	sp,sp,-64
 626:	fc06                	sd	ra,56(sp)
 628:	f822                	sd	s0,48(sp)
 62a:	f426                	sd	s1,40(sp)
 62c:	f04a                	sd	s2,32(sp)
 62e:	ec4e                	sd	s3,24(sp)
 630:	0080                	addi	s0,sp,64
 632:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 634:	c299                	beqz	a3,63a <printint+0x16>
 636:	0805c863          	bltz	a1,6c6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 63a:	2581                	sext.w	a1,a1
  neg = 0;
 63c:	4881                	li	a7,0
 63e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 642:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 644:	2601                	sext.w	a2,a2
 646:	00000517          	auipc	a0,0x0
 64a:	55250513          	addi	a0,a0,1362 # b98 <digits>
 64e:	883a                	mv	a6,a4
 650:	2705                	addiw	a4,a4,1
 652:	02c5f7bb          	remuw	a5,a1,a2
 656:	1782                	slli	a5,a5,0x20
 658:	9381                	srli	a5,a5,0x20
 65a:	97aa                	add	a5,a5,a0
 65c:	0007c783          	lbu	a5,0(a5)
 660:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 664:	0005879b          	sext.w	a5,a1
 668:	02c5d5bb          	divuw	a1,a1,a2
 66c:	0685                	addi	a3,a3,1
 66e:	fec7f0e3          	bgeu	a5,a2,64e <printint+0x2a>
  if(neg)
 672:	00088b63          	beqz	a7,688 <printint+0x64>
    buf[i++] = '-';
 676:	fd040793          	addi	a5,s0,-48
 67a:	973e                	add	a4,a4,a5
 67c:	02d00793          	li	a5,45
 680:	fef70823          	sb	a5,-16(a4)
 684:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 688:	02e05863          	blez	a4,6b8 <printint+0x94>
 68c:	fc040793          	addi	a5,s0,-64
 690:	00e78933          	add	s2,a5,a4
 694:	fff78993          	addi	s3,a5,-1
 698:	99ba                	add	s3,s3,a4
 69a:	377d                	addiw	a4,a4,-1
 69c:	1702                	slli	a4,a4,0x20
 69e:	9301                	srli	a4,a4,0x20
 6a0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6a4:	fff94583          	lbu	a1,-1(s2)
 6a8:	8526                	mv	a0,s1
 6aa:	00000097          	auipc	ra,0x0
 6ae:	f58080e7          	jalr	-168(ra) # 602 <putc>
  while(--i >= 0)
 6b2:	197d                	addi	s2,s2,-1
 6b4:	ff3918e3          	bne	s2,s3,6a4 <printint+0x80>
}
 6b8:	70e2                	ld	ra,56(sp)
 6ba:	7442                	ld	s0,48(sp)
 6bc:	74a2                	ld	s1,40(sp)
 6be:	7902                	ld	s2,32(sp)
 6c0:	69e2                	ld	s3,24(sp)
 6c2:	6121                	addi	sp,sp,64
 6c4:	8082                	ret
    x = -xx;
 6c6:	40b005bb          	negw	a1,a1
    neg = 1;
 6ca:	4885                	li	a7,1
    x = -xx;
 6cc:	bf8d                	j	63e <printint+0x1a>

00000000000006ce <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6ce:	7119                	addi	sp,sp,-128
 6d0:	fc86                	sd	ra,120(sp)
 6d2:	f8a2                	sd	s0,112(sp)
 6d4:	f4a6                	sd	s1,104(sp)
 6d6:	f0ca                	sd	s2,96(sp)
 6d8:	ecce                	sd	s3,88(sp)
 6da:	e8d2                	sd	s4,80(sp)
 6dc:	e4d6                	sd	s5,72(sp)
 6de:	e0da                	sd	s6,64(sp)
 6e0:	fc5e                	sd	s7,56(sp)
 6e2:	f862                	sd	s8,48(sp)
 6e4:	f466                	sd	s9,40(sp)
 6e6:	f06a                	sd	s10,32(sp)
 6e8:	ec6e                	sd	s11,24(sp)
 6ea:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6ec:	0005c903          	lbu	s2,0(a1)
 6f0:	18090f63          	beqz	s2,88e <vprintf+0x1c0>
 6f4:	8aaa                	mv	s5,a0
 6f6:	8b32                	mv	s6,a2
 6f8:	00158493          	addi	s1,a1,1
  state = 0;
 6fc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6fe:	02500a13          	li	s4,37
      if(c == 'd'){
 702:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 706:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 70a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 70e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 712:	00000b97          	auipc	s7,0x0
 716:	486b8b93          	addi	s7,s7,1158 # b98 <digits>
 71a:	a839                	j	738 <vprintf+0x6a>
        putc(fd, c);
 71c:	85ca                	mv	a1,s2
 71e:	8556                	mv	a0,s5
 720:	00000097          	auipc	ra,0x0
 724:	ee2080e7          	jalr	-286(ra) # 602 <putc>
 728:	a019                	j	72e <vprintf+0x60>
    } else if(state == '%'){
 72a:	01498f63          	beq	s3,s4,748 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 72e:	0485                	addi	s1,s1,1
 730:	fff4c903          	lbu	s2,-1(s1)
 734:	14090d63          	beqz	s2,88e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 738:	0009079b          	sext.w	a5,s2
    if(state == 0){
 73c:	fe0997e3          	bnez	s3,72a <vprintf+0x5c>
      if(c == '%'){
 740:	fd479ee3          	bne	a5,s4,71c <vprintf+0x4e>
        state = '%';
 744:	89be                	mv	s3,a5
 746:	b7e5                	j	72e <vprintf+0x60>
      if(c == 'd'){
 748:	05878063          	beq	a5,s8,788 <vprintf+0xba>
      } else if(c == 'l') {
 74c:	05978c63          	beq	a5,s9,7a4 <vprintf+0xd6>
      } else if(c == 'x') {
 750:	07a78863          	beq	a5,s10,7c0 <vprintf+0xf2>
      } else if(c == 'p') {
 754:	09b78463          	beq	a5,s11,7dc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 758:	07300713          	li	a4,115
 75c:	0ce78663          	beq	a5,a4,828 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 760:	06300713          	li	a4,99
 764:	0ee78e63          	beq	a5,a4,860 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 768:	11478863          	beq	a5,s4,878 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 76c:	85d2                	mv	a1,s4
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	e92080e7          	jalr	-366(ra) # 602 <putc>
        putc(fd, c);
 778:	85ca                	mv	a1,s2
 77a:	8556                	mv	a0,s5
 77c:	00000097          	auipc	ra,0x0
 780:	e86080e7          	jalr	-378(ra) # 602 <putc>
      }
      state = 0;
 784:	4981                	li	s3,0
 786:	b765                	j	72e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 788:	008b0913          	addi	s2,s6,8
 78c:	4685                	li	a3,1
 78e:	4629                	li	a2,10
 790:	000b2583          	lw	a1,0(s6)
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	e8e080e7          	jalr	-370(ra) # 624 <printint>
 79e:	8b4a                	mv	s6,s2
      state = 0;
 7a0:	4981                	li	s3,0
 7a2:	b771                	j	72e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a4:	008b0913          	addi	s2,s6,8
 7a8:	4681                	li	a3,0
 7aa:	4629                	li	a2,10
 7ac:	000b2583          	lw	a1,0(s6)
 7b0:	8556                	mv	a0,s5
 7b2:	00000097          	auipc	ra,0x0
 7b6:	e72080e7          	jalr	-398(ra) # 624 <printint>
 7ba:	8b4a                	mv	s6,s2
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	bf85                	j	72e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7c0:	008b0913          	addi	s2,s6,8
 7c4:	4681                	li	a3,0
 7c6:	4641                	li	a2,16
 7c8:	000b2583          	lw	a1,0(s6)
 7cc:	8556                	mv	a0,s5
 7ce:	00000097          	auipc	ra,0x0
 7d2:	e56080e7          	jalr	-426(ra) # 624 <printint>
 7d6:	8b4a                	mv	s6,s2
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	bf91                	j	72e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7dc:	008b0793          	addi	a5,s6,8
 7e0:	f8f43423          	sd	a5,-120(s0)
 7e4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7e8:	03000593          	li	a1,48
 7ec:	8556                	mv	a0,s5
 7ee:	00000097          	auipc	ra,0x0
 7f2:	e14080e7          	jalr	-492(ra) # 602 <putc>
  putc(fd, 'x');
 7f6:	85ea                	mv	a1,s10
 7f8:	8556                	mv	a0,s5
 7fa:	00000097          	auipc	ra,0x0
 7fe:	e08080e7          	jalr	-504(ra) # 602 <putc>
 802:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 804:	03c9d793          	srli	a5,s3,0x3c
 808:	97de                	add	a5,a5,s7
 80a:	0007c583          	lbu	a1,0(a5)
 80e:	8556                	mv	a0,s5
 810:	00000097          	auipc	ra,0x0
 814:	df2080e7          	jalr	-526(ra) # 602 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 818:	0992                	slli	s3,s3,0x4
 81a:	397d                	addiw	s2,s2,-1
 81c:	fe0914e3          	bnez	s2,804 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 820:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 824:	4981                	li	s3,0
 826:	b721                	j	72e <vprintf+0x60>
        s = va_arg(ap, char*);
 828:	008b0993          	addi	s3,s6,8
 82c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 830:	02090163          	beqz	s2,852 <vprintf+0x184>
        while(*s != 0){
 834:	00094583          	lbu	a1,0(s2)
 838:	c9a1                	beqz	a1,888 <vprintf+0x1ba>
          putc(fd, *s);
 83a:	8556                	mv	a0,s5
 83c:	00000097          	auipc	ra,0x0
 840:	dc6080e7          	jalr	-570(ra) # 602 <putc>
          s++;
 844:	0905                	addi	s2,s2,1
        while(*s != 0){
 846:	00094583          	lbu	a1,0(s2)
 84a:	f9e5                	bnez	a1,83a <vprintf+0x16c>
        s = va_arg(ap, char*);
 84c:	8b4e                	mv	s6,s3
      state = 0;
 84e:	4981                	li	s3,0
 850:	bdf9                	j	72e <vprintf+0x60>
          s = "(null)";
 852:	00000917          	auipc	s2,0x0
 856:	33e90913          	addi	s2,s2,830 # b90 <malloc+0x1f8>
        while(*s != 0){
 85a:	02800593          	li	a1,40
 85e:	bff1                	j	83a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 860:	008b0913          	addi	s2,s6,8
 864:	000b4583          	lbu	a1,0(s6)
 868:	8556                	mv	a0,s5
 86a:	00000097          	auipc	ra,0x0
 86e:	d98080e7          	jalr	-616(ra) # 602 <putc>
 872:	8b4a                	mv	s6,s2
      state = 0;
 874:	4981                	li	s3,0
 876:	bd65                	j	72e <vprintf+0x60>
        putc(fd, c);
 878:	85d2                	mv	a1,s4
 87a:	8556                	mv	a0,s5
 87c:	00000097          	auipc	ra,0x0
 880:	d86080e7          	jalr	-634(ra) # 602 <putc>
      state = 0;
 884:	4981                	li	s3,0
 886:	b565                	j	72e <vprintf+0x60>
        s = va_arg(ap, char*);
 888:	8b4e                	mv	s6,s3
      state = 0;
 88a:	4981                	li	s3,0
 88c:	b54d                	j	72e <vprintf+0x60>
    }
  }
}
 88e:	70e6                	ld	ra,120(sp)
 890:	7446                	ld	s0,112(sp)
 892:	74a6                	ld	s1,104(sp)
 894:	7906                	ld	s2,96(sp)
 896:	69e6                	ld	s3,88(sp)
 898:	6a46                	ld	s4,80(sp)
 89a:	6aa6                	ld	s5,72(sp)
 89c:	6b06                	ld	s6,64(sp)
 89e:	7be2                	ld	s7,56(sp)
 8a0:	7c42                	ld	s8,48(sp)
 8a2:	7ca2                	ld	s9,40(sp)
 8a4:	7d02                	ld	s10,32(sp)
 8a6:	6de2                	ld	s11,24(sp)
 8a8:	6109                	addi	sp,sp,128
 8aa:	8082                	ret

00000000000008ac <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8ac:	715d                	addi	sp,sp,-80
 8ae:	ec06                	sd	ra,24(sp)
 8b0:	e822                	sd	s0,16(sp)
 8b2:	1000                	addi	s0,sp,32
 8b4:	e010                	sd	a2,0(s0)
 8b6:	e414                	sd	a3,8(s0)
 8b8:	e818                	sd	a4,16(s0)
 8ba:	ec1c                	sd	a5,24(s0)
 8bc:	03043023          	sd	a6,32(s0)
 8c0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8c4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8c8:	8622                	mv	a2,s0
 8ca:	00000097          	auipc	ra,0x0
 8ce:	e04080e7          	jalr	-508(ra) # 6ce <vprintf>
}
 8d2:	60e2                	ld	ra,24(sp)
 8d4:	6442                	ld	s0,16(sp)
 8d6:	6161                	addi	sp,sp,80
 8d8:	8082                	ret

00000000000008da <printf>:

void
printf(const char *fmt, ...)
{
 8da:	711d                	addi	sp,sp,-96
 8dc:	ec06                	sd	ra,24(sp)
 8de:	e822                	sd	s0,16(sp)
 8e0:	1000                	addi	s0,sp,32
 8e2:	e40c                	sd	a1,8(s0)
 8e4:	e810                	sd	a2,16(s0)
 8e6:	ec14                	sd	a3,24(s0)
 8e8:	f018                	sd	a4,32(s0)
 8ea:	f41c                	sd	a5,40(s0)
 8ec:	03043823          	sd	a6,48(s0)
 8f0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8f4:	00840613          	addi	a2,s0,8
 8f8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8fc:	85aa                	mv	a1,a0
 8fe:	4505                	li	a0,1
 900:	00000097          	auipc	ra,0x0
 904:	dce080e7          	jalr	-562(ra) # 6ce <vprintf>
}
 908:	60e2                	ld	ra,24(sp)
 90a:	6442                	ld	s0,16(sp)
 90c:	6125                	addi	sp,sp,96
 90e:	8082                	ret

0000000000000910 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 910:	1141                	addi	sp,sp,-16
 912:	e422                	sd	s0,8(sp)
 914:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 916:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 91a:	00000797          	auipc	a5,0x0
 91e:	6e67b783          	ld	a5,1766(a5) # 1000 <freep>
 922:	a805                	j	952 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 924:	4618                	lw	a4,8(a2)
 926:	9db9                	addw	a1,a1,a4
 928:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 92c:	6398                	ld	a4,0(a5)
 92e:	6318                	ld	a4,0(a4)
 930:	fee53823          	sd	a4,-16(a0)
 934:	a091                	j	978 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 936:	ff852703          	lw	a4,-8(a0)
 93a:	9e39                	addw	a2,a2,a4
 93c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 93e:	ff053703          	ld	a4,-16(a0)
 942:	e398                	sd	a4,0(a5)
 944:	a099                	j	98a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 946:	6398                	ld	a4,0(a5)
 948:	00e7e463          	bltu	a5,a4,950 <free+0x40>
 94c:	00e6ea63          	bltu	a3,a4,960 <free+0x50>
{
 950:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 952:	fed7fae3          	bgeu	a5,a3,946 <free+0x36>
 956:	6398                	ld	a4,0(a5)
 958:	00e6e463          	bltu	a3,a4,960 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 95c:	fee7eae3          	bltu	a5,a4,950 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 960:	ff852583          	lw	a1,-8(a0)
 964:	6390                	ld	a2,0(a5)
 966:	02059713          	slli	a4,a1,0x20
 96a:	9301                	srli	a4,a4,0x20
 96c:	0712                	slli	a4,a4,0x4
 96e:	9736                	add	a4,a4,a3
 970:	fae60ae3          	beq	a2,a4,924 <free+0x14>
    bp->s.ptr = p->s.ptr;
 974:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 978:	4790                	lw	a2,8(a5)
 97a:	02061713          	slli	a4,a2,0x20
 97e:	9301                	srli	a4,a4,0x20
 980:	0712                	slli	a4,a4,0x4
 982:	973e                	add	a4,a4,a5
 984:	fae689e3          	beq	a3,a4,936 <free+0x26>
  } else
    p->s.ptr = bp;
 988:	e394                	sd	a3,0(a5)
  freep = p;
 98a:	00000717          	auipc	a4,0x0
 98e:	66f73b23          	sd	a5,1654(a4) # 1000 <freep>
}
 992:	6422                	ld	s0,8(sp)
 994:	0141                	addi	sp,sp,16
 996:	8082                	ret

0000000000000998 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 998:	7139                	addi	sp,sp,-64
 99a:	fc06                	sd	ra,56(sp)
 99c:	f822                	sd	s0,48(sp)
 99e:	f426                	sd	s1,40(sp)
 9a0:	f04a                	sd	s2,32(sp)
 9a2:	ec4e                	sd	s3,24(sp)
 9a4:	e852                	sd	s4,16(sp)
 9a6:	e456                	sd	s5,8(sp)
 9a8:	e05a                	sd	s6,0(sp)
 9aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ac:	02051493          	slli	s1,a0,0x20
 9b0:	9081                	srli	s1,s1,0x20
 9b2:	04bd                	addi	s1,s1,15
 9b4:	8091                	srli	s1,s1,0x4
 9b6:	0014899b          	addiw	s3,s1,1
 9ba:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9bc:	00000517          	auipc	a0,0x0
 9c0:	64453503          	ld	a0,1604(a0) # 1000 <freep>
 9c4:	c515                	beqz	a0,9f0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c8:	4798                	lw	a4,8(a5)
 9ca:	02977f63          	bgeu	a4,s1,a08 <malloc+0x70>
 9ce:	8a4e                	mv	s4,s3
 9d0:	0009871b          	sext.w	a4,s3
 9d4:	6685                	lui	a3,0x1
 9d6:	00d77363          	bgeu	a4,a3,9dc <malloc+0x44>
 9da:	6a05                	lui	s4,0x1
 9dc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9e0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9e4:	00000917          	auipc	s2,0x0
 9e8:	61c90913          	addi	s2,s2,1564 # 1000 <freep>
  if(p == (char*)-1)
 9ec:	5afd                	li	s5,-1
 9ee:	a88d                	j	a60 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 9f0:	00040797          	auipc	a5,0x40
 9f4:	62078793          	addi	a5,a5,1568 # 41010 <base>
 9f8:	00000717          	auipc	a4,0x0
 9fc:	60f73423          	sd	a5,1544(a4) # 1000 <freep>
 a00:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a02:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a06:	b7e1                	j	9ce <malloc+0x36>
      if(p->s.size == nunits)
 a08:	02e48b63          	beq	s1,a4,a3e <malloc+0xa6>
        p->s.size -= nunits;
 a0c:	4137073b          	subw	a4,a4,s3
 a10:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a12:	1702                	slli	a4,a4,0x20
 a14:	9301                	srli	a4,a4,0x20
 a16:	0712                	slli	a4,a4,0x4
 a18:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a1a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a1e:	00000717          	auipc	a4,0x0
 a22:	5ea73123          	sd	a0,1506(a4) # 1000 <freep>
      return (void*)(p + 1);
 a26:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a2a:	70e2                	ld	ra,56(sp)
 a2c:	7442                	ld	s0,48(sp)
 a2e:	74a2                	ld	s1,40(sp)
 a30:	7902                	ld	s2,32(sp)
 a32:	69e2                	ld	s3,24(sp)
 a34:	6a42                	ld	s4,16(sp)
 a36:	6aa2                	ld	s5,8(sp)
 a38:	6b02                	ld	s6,0(sp)
 a3a:	6121                	addi	sp,sp,64
 a3c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a3e:	6398                	ld	a4,0(a5)
 a40:	e118                	sd	a4,0(a0)
 a42:	bff1                	j	a1e <malloc+0x86>
  hp->s.size = nu;
 a44:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a48:	0541                	addi	a0,a0,16
 a4a:	00000097          	auipc	ra,0x0
 a4e:	ec6080e7          	jalr	-314(ra) # 910 <free>
  return freep;
 a52:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a56:	d971                	beqz	a0,a2a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a58:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a5a:	4798                	lw	a4,8(a5)
 a5c:	fa9776e3          	bgeu	a4,s1,a08 <malloc+0x70>
    if(p == freep)
 a60:	00093703          	ld	a4,0(s2)
 a64:	853e                	mv	a0,a5
 a66:	fef719e3          	bne	a4,a5,a58 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a6a:	8552                	mv	a0,s4
 a6c:	00000097          	auipc	ra,0x0
 a70:	b5e080e7          	jalr	-1186(ra) # 5ca <sbrk>
  if(p == (char*)-1)
 a74:	fd5518e3          	bne	a0,s5,a44 <malloc+0xac>
        return 0;
 a78:	4501                	li	a0,0
 a7a:	bf45                	j	a2a <malloc+0x92>
