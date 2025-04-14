
user/_bigarray:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#define SIZE (1 << 16)  // 65536
#define NUM_CHILDREN 4
#define CHUNK_SIZE (SIZE / NUM_CHILDREN)

int main() {
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	1080                	addi	s0,sp,96
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);
   e:	4591                	li	a1,4
  10:	00001517          	auipc	a0,0x1
  14:	98050513          	addi	a0,a0,-1664 # 990 <malloc+0xee>
  18:	00000097          	auipc	ra,0x0
  1c:	7cc080e7          	jalr	1996(ra) # 7e4 <printf>

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN];
  int n = NUM_CHILDREN;
  20:	4791                	li	a5,4
  22:	faf42623          	sw	a5,-84(s0)

  int ret = forkn(NUM_CHILDREN, pids);
  26:	fc040593          	addi	a1,s0,-64
  2a:	4511                	li	a0,4
  2c:	00000097          	auipc	ra,0x0
  30:	4c8080e7          	jalr	1224(ra) # 4f4 <forkn>

  if (ret == -1) {
  34:	57fd                	li	a5,-1
  36:	02f50363          	beq	a0,a5,5c <main+0x5c>
  3a:	84aa                	mv	s1,a0
    printf("forkn failed\n");
    exit(-1);
  } else if (ret >= 0 && ret < NUM_CHILDREN) {
  3c:	0005079b          	sext.w	a5,a0
  40:	470d                	li	a4,3
  42:	02f77a63          	bgeu	a4,a5,76 <main+0x76>
    }

    // ✅ Use printf directly instead of manual string building
    printf("Child %d calculated sum: %d\n", ret, (int)sum);
    exit((int)sum);
  } else if (ret == -2) {
  46:	57f9                	li	a5,-2
  48:	06f50f63          	beq	a0,a5,c6 <main+0xc6>

    exit(0);
  }

  return 0;
}
  4c:	4501                	li	a0,0
  4e:	60e6                	ld	ra,88(sp)
  50:	6446                	ld	s0,80(sp)
  52:	64a6                	ld	s1,72(sp)
  54:	6906                	ld	s2,64(sp)
  56:	79e2                	ld	s3,56(sp)
  58:	6125                	addi	sp,sp,96
  5a:	8082                	ret
    printf("forkn failed\n");
  5c:	00001517          	auipc	a0,0x1
  60:	95450513          	addi	a0,a0,-1708 # 9b0 <malloc+0x10e>
  64:	00000097          	auipc	ra,0x0
  68:	780080e7          	jalr	1920(ra) # 7e4 <printf>
    exit(-1);
  6c:	557d                	li	a0,-1
  6e:	00000097          	auipc	ra,0x0
  72:	3d6080e7          	jalr	982(ra) # 444 <exit>
    long long start = ret * CHUNK_SIZE;
  76:	00e5169b          	slliw	a3,a0,0xe
  7a:	0006879b          	sext.w	a5,a3
    long long end = (ret + 1) * CHUNK_SIZE;
  7e:	6711                	lui	a4,0x4
  80:	9f35                	addw	a4,a4,a3
    for (long long i = start + 1; i <= end; i++) {
  82:	0785                	addi	a5,a5,1
    long long sum = 0;
  84:	4901                	li	s2,0
    for (long long i = start + 1; i <= end; i++) {
  86:	a019                	j	8c <main+0x8c>
      sum += i;
  88:	993e                	add	s2,s2,a5
    for (long long i = start + 1; i <= end; i++) {
  8a:	0785                	addi	a5,a5,1
  8c:	fef75ee3          	bge	a4,a5,88 <main+0x88>
    for (int i = 0; i < ret; i++) {
  90:	4981                	li	s3,0
  92:	a801                	j	a2 <main+0xa2>
      sleep(50);  // Ensure clear print separation
  94:	03200513          	li	a0,50
  98:	00000097          	auipc	ra,0x0
  9c:	444080e7          	jalr	1092(ra) # 4dc <sleep>
    for (int i = 0; i < ret; i++) {
  a0:	2985                	addiw	s3,s3,1
  a2:	fe9999e3          	bne	s3,s1,94 <main+0x94>
    printf("Child %d calculated sum: %d\n", ret, (int)sum);
  a6:	2901                	sext.w	s2,s2
  a8:	864a                	mv	a2,s2
  aa:	85a6                	mv	a1,s1
  ac:	00001517          	auipc	a0,0x1
  b0:	91450513          	addi	a0,a0,-1772 # 9c0 <malloc+0x11e>
  b4:	00000097          	auipc	ra,0x0
  b8:	730080e7          	jalr	1840(ra) # 7e4 <printf>
    exit((int)sum);
  bc:	854a                	mv	a0,s2
  be:	00000097          	auipc	ra,0x0
  c2:	386080e7          	jalr	902(ra) # 444 <exit>
    sleep(100);
  c6:	06400513          	li	a0,100
  ca:	00000097          	auipc	ra,0x0
  ce:	412080e7          	jalr	1042(ra) # 4dc <sleep>
    printf("===> Waiting for children with waitall()\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	90e50513          	addi	a0,a0,-1778 # 9e0 <malloc+0x13e>
  da:	00000097          	auipc	ra,0x0
  de:	70a080e7          	jalr	1802(ra) # 7e4 <printf>
    if (waitall(&n, statuses) < 0) {
  e2:	fb040593          	addi	a1,s0,-80
  e6:	fac40513          	addi	a0,s0,-84
  ea:	00000097          	auipc	ra,0x0
  ee:	412080e7          	jalr	1042(ra) # 4fc <waitall>
  f2:	06054763          	bltz	a0,160 <main+0x160>
    for (int i = 0; i < n; i++) {
  f6:	fac42583          	lw	a1,-84(s0)
  fa:	08b05a63          	blez	a1,18e <main+0x18e>
  fe:	fb040713          	addi	a4,s0,-80
 102:	4781                	li	a5,0
    long long total = 0;
 104:	4481                	li	s1,0
      total += (long long)statuses[i];
 106:	4314                	lw	a3,0(a4)
 108:	94b6                	add	s1,s1,a3
    for (int i = 0; i < n; i++) {
 10a:	2785                	addiw	a5,a5,1
 10c:	0711                	addi	a4,a4,4
 10e:	feb79ce3          	bne	a5,a1,106 <main+0x106>
    printf("===> All %d children finished\n", n);
 112:	00001517          	auipc	a0,0x1
 116:	90e50513          	addi	a0,a0,-1778 # a20 <malloc+0x17e>
 11a:	00000097          	auipc	ra,0x0
 11e:	6ca080e7          	jalr	1738(ra) # 7e4 <printf>
    printf("Sum of all children's sums: %lld\n", total);
 122:	85a6                	mv	a1,s1
 124:	00001517          	auipc	a0,0x1
 128:	91c50513          	addi	a0,a0,-1764 # a40 <malloc+0x19e>
 12c:	00000097          	auipc	ra,0x0
 130:	6b8080e7          	jalr	1720(ra) # 7e4 <printf>
    if (total == expected) {
 134:	100017b7          	lui	a5,0x10001
 138:	078e                	slli	a5,a5,0x3
 13a:	04f48063          	beq	s1,a5,17a <main+0x17a>
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);
 13e:	10001637          	lui	a2,0x10001
 142:	060e                	slli	a2,a2,0x3
 144:	85a6                	mv	a1,s1
 146:	00001517          	auipc	a0,0x1
 14a:	94250513          	addi	a0,a0,-1726 # a88 <malloc+0x1e6>
 14e:	00000097          	auipc	ra,0x0
 152:	696080e7          	jalr	1686(ra) # 7e4 <printf>
    exit(0);
 156:	4501                	li	a0,0
 158:	00000097          	auipc	ra,0x0
 15c:	2ec080e7          	jalr	748(ra) # 444 <exit>
      printf("waitall failed\n");
 160:	00001517          	auipc	a0,0x1
 164:	8b050513          	addi	a0,a0,-1872 # a10 <malloc+0x16e>
 168:	00000097          	auipc	ra,0x0
 16c:	67c080e7          	jalr	1660(ra) # 7e4 <printf>
      exit(-1);
 170:	557d                	li	a0,-1
 172:	00000097          	auipc	ra,0x0
 176:	2d2080e7          	jalr	722(ra) # 444 <exit>
      printf("Correct total sum: %lld\n", total);
 17a:	85be                	mv	a1,a5
 17c:	00001517          	auipc	a0,0x1
 180:	8ec50513          	addi	a0,a0,-1812 # a68 <malloc+0x1c6>
 184:	00000097          	auipc	ra,0x0
 188:	660080e7          	jalr	1632(ra) # 7e4 <printf>
 18c:	b7e9                	j	156 <main+0x156>
    printf("===> All %d children finished\n", n);
 18e:	00001517          	auipc	a0,0x1
 192:	89250513          	addi	a0,a0,-1902 # a20 <malloc+0x17e>
 196:	00000097          	auipc	ra,0x0
 19a:	64e080e7          	jalr	1614(ra) # 7e4 <printf>
    printf("Sum of all children's sums: %lld\n", total);
 19e:	4581                	li	a1,0
 1a0:	00001517          	auipc	a0,0x1
 1a4:	8a050513          	addi	a0,a0,-1888 # a40 <malloc+0x19e>
 1a8:	00000097          	auipc	ra,0x0
 1ac:	63c080e7          	jalr	1596(ra) # 7e4 <printf>
    long long total = 0;
 1b0:	4481                	li	s1,0
 1b2:	b771                	j	13e <main+0x13e>

00000000000001b4 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e406                	sd	ra,8(sp)
 1b8:	e022                	sd	s0,0(sp)
 1ba:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1bc:	00000097          	auipc	ra,0x0
 1c0:	e44080e7          	jalr	-444(ra) # 0 <main>
  exit(0);
 1c4:	4501                	li	a0,0
 1c6:	00000097          	auipc	ra,0x0
 1ca:	27e080e7          	jalr	638(ra) # 444 <exit>

00000000000001ce <strcpy>:
}

char* strcpy(char *s, const char *t)
{
 1ce:	1141                	addi	sp,sp,-16
 1d0:	e422                	sd	s0,8(sp)
 1d2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1d4:	87aa                	mv	a5,a0
 1d6:	0585                	addi	a1,a1,1
 1d8:	0785                	addi	a5,a5,1
 1da:	fff5c703          	lbu	a4,-1(a1)
 1de:	fee78fa3          	sb	a4,-1(a5) # 10000fff <base+0xfffffef>
 1e2:	fb75                	bnez	a4,1d6 <strcpy+0x8>
    ;
  return os;
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strcmp>:

int strcmp(const char *p, const char *q)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	cb91                	beqz	a5,208 <strcmp+0x1e>
 1f6:	0005c703          	lbu	a4,0(a1)
 1fa:	00f71763          	bne	a4,a5,208 <strcmp+0x1e>
    p++, q++;
 1fe:	0505                	addi	a0,a0,1
 200:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 202:	00054783          	lbu	a5,0(a0)
 206:	fbe5                	bnez	a5,1f6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 208:	0005c503          	lbu	a0,0(a1)
}
 20c:	40a7853b          	subw	a0,a5,a0
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret

0000000000000216 <strlen>:

uint strlen(const char *s)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 21c:	00054783          	lbu	a5,0(a0)
 220:	cf91                	beqz	a5,23c <strlen+0x26>
 222:	0505                	addi	a0,a0,1
 224:	87aa                	mv	a5,a0
 226:	4685                	li	a3,1
 228:	9e89                	subw	a3,a3,a0
 22a:	00f6853b          	addw	a0,a3,a5
 22e:	0785                	addi	a5,a5,1
 230:	fff7c703          	lbu	a4,-1(a5)
 234:	fb7d                	bnez	a4,22a <strlen+0x14>
    ;
  return n;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
  for(n = 0; s[n]; n++)
 23c:	4501                	li	a0,0
 23e:	bfe5                	j	236 <strlen+0x20>

0000000000000240 <memset>:

void* memset(void *dst, int c, uint n)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 246:	ce09                	beqz	a2,260 <memset+0x20>
 248:	87aa                	mv	a5,a0
 24a:	fff6071b          	addiw	a4,a2,-1
 24e:	1702                	slli	a4,a4,0x20
 250:	9301                	srli	a4,a4,0x20
 252:	0705                	addi	a4,a4,1
 254:	972a                	add	a4,a4,a0
    cdst[i] = c;
 256:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 25a:	0785                	addi	a5,a5,1
 25c:	fee79de3          	bne	a5,a4,256 <memset+0x16>
  }
  return dst;
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret

0000000000000266 <strchr>:

char* strchr(const char *s, char c)
{
 266:	1141                	addi	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 26c:	00054783          	lbu	a5,0(a0)
 270:	cb99                	beqz	a5,286 <strchr+0x20>
    if(*s == c)
 272:	00f58763          	beq	a1,a5,280 <strchr+0x1a>
  for(; *s; s++)
 276:	0505                	addi	a0,a0,1
 278:	00054783          	lbu	a5,0(a0)
 27c:	fbfd                	bnez	a5,272 <strchr+0xc>
      return (char*)s;
  return 0;
 27e:	4501                	li	a0,0
}
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret
  return 0;
 286:	4501                	li	a0,0
 288:	bfe5                	j	280 <strchr+0x1a>

000000000000028a <gets>:

char* gets(char *buf, int max)
{
 28a:	711d                	addi	sp,sp,-96
 28c:	ec86                	sd	ra,88(sp)
 28e:	e8a2                	sd	s0,80(sp)
 290:	e4a6                	sd	s1,72(sp)
 292:	e0ca                	sd	s2,64(sp)
 294:	fc4e                	sd	s3,56(sp)
 296:	f852                	sd	s4,48(sp)
 298:	f456                	sd	s5,40(sp)
 29a:	f05a                	sd	s6,32(sp)
 29c:	ec5e                	sd	s7,24(sp)
 29e:	1080                	addi	s0,sp,96
 2a0:	8baa                	mv	s7,a0
 2a2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a4:	892a                	mv	s2,a0
 2a6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2a8:	4aa9                	li	s5,10
 2aa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ac:	89a6                	mv	s3,s1
 2ae:	2485                	addiw	s1,s1,1
 2b0:	0344d863          	bge	s1,s4,2e0 <gets+0x56>
    cc = read(0, &c, 1);
 2b4:	4605                	li	a2,1
 2b6:	faf40593          	addi	a1,s0,-81
 2ba:	4501                	li	a0,0
 2bc:	00000097          	auipc	ra,0x0
 2c0:	1a8080e7          	jalr	424(ra) # 464 <read>
    if(cc < 1)
 2c4:	00a05e63          	blez	a0,2e0 <gets+0x56>
    buf[i++] = c;
 2c8:	faf44783          	lbu	a5,-81(s0)
 2cc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2d0:	01578763          	beq	a5,s5,2de <gets+0x54>
 2d4:	0905                	addi	s2,s2,1
 2d6:	fd679be3          	bne	a5,s6,2ac <gets+0x22>
  for(i=0; i+1 < max; ){
 2da:	89a6                	mv	s3,s1
 2dc:	a011                	j	2e0 <gets+0x56>
 2de:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2e0:	99de                	add	s3,s3,s7
 2e2:	00098023          	sb	zero,0(s3)
  return buf;
}
 2e6:	855e                	mv	a0,s7
 2e8:	60e6                	ld	ra,88(sp)
 2ea:	6446                	ld	s0,80(sp)
 2ec:	64a6                	ld	s1,72(sp)
 2ee:	6906                	ld	s2,64(sp)
 2f0:	79e2                	ld	s3,56(sp)
 2f2:	7a42                	ld	s4,48(sp)
 2f4:	7aa2                	ld	s5,40(sp)
 2f6:	7b02                	ld	s6,32(sp)
 2f8:	6be2                	ld	s7,24(sp)
 2fa:	6125                	addi	sp,sp,96
 2fc:	8082                	ret

00000000000002fe <stat>:

int stat(const char *n, struct stat *st)
{
 2fe:	1101                	addi	sp,sp,-32
 300:	ec06                	sd	ra,24(sp)
 302:	e822                	sd	s0,16(sp)
 304:	e426                	sd	s1,8(sp)
 306:	e04a                	sd	s2,0(sp)
 308:	1000                	addi	s0,sp,32
 30a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 30c:	4581                	li	a1,0
 30e:	00000097          	auipc	ra,0x0
 312:	17e080e7          	jalr	382(ra) # 48c <open>
  if(fd < 0)
 316:	02054563          	bltz	a0,340 <stat+0x42>
 31a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 31c:	85ca                	mv	a1,s2
 31e:	00000097          	auipc	ra,0x0
 322:	186080e7          	jalr	390(ra) # 4a4 <fstat>
 326:	892a                	mv	s2,a0
  close(fd);
 328:	8526                	mv	a0,s1
 32a:	00000097          	auipc	ra,0x0
 32e:	14a080e7          	jalr	330(ra) # 474 <close>
  return r;
}
 332:	854a                	mv	a0,s2
 334:	60e2                	ld	ra,24(sp)
 336:	6442                	ld	s0,16(sp)
 338:	64a2                	ld	s1,8(sp)
 33a:	6902                	ld	s2,0(sp)
 33c:	6105                	addi	sp,sp,32
 33e:	8082                	ret
    return -1;
 340:	597d                	li	s2,-1
 342:	bfc5                	j	332 <stat+0x34>

0000000000000344 <atoi>:

int atoi(const char *s)
{
 344:	1141                	addi	sp,sp,-16
 346:	e422                	sd	s0,8(sp)
 348:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 34a:	00054603          	lbu	a2,0(a0)
 34e:	fd06079b          	addiw	a5,a2,-48
 352:	0ff7f793          	andi	a5,a5,255
 356:	4725                	li	a4,9
 358:	02f76963          	bltu	a4,a5,38a <atoi+0x46>
 35c:	86aa                	mv	a3,a0
  n = 0;
 35e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 360:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 362:	0685                	addi	a3,a3,1
 364:	0025179b          	slliw	a5,a0,0x2
 368:	9fa9                	addw	a5,a5,a0
 36a:	0017979b          	slliw	a5,a5,0x1
 36e:	9fb1                	addw	a5,a5,a2
 370:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 374:	0006c603          	lbu	a2,0(a3)
 378:	fd06071b          	addiw	a4,a2,-48
 37c:	0ff77713          	andi	a4,a4,255
 380:	fee5f1e3          	bgeu	a1,a4,362 <atoi+0x1e>
  return n;
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret
  n = 0;
 38a:	4501                	li	a0,0
 38c:	bfe5                	j	384 <atoi+0x40>

000000000000038e <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e422                	sd	s0,8(sp)
 392:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 394:	02b57663          	bgeu	a0,a1,3c0 <memmove+0x32>
    while(n-- > 0)
 398:	02c05163          	blez	a2,3ba <memmove+0x2c>
 39c:	fff6079b          	addiw	a5,a2,-1
 3a0:	1782                	slli	a5,a5,0x20
 3a2:	9381                	srli	a5,a5,0x20
 3a4:	0785                	addi	a5,a5,1
 3a6:	97aa                	add	a5,a5,a0
  dst = vdst;
 3a8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3aa:	0585                	addi	a1,a1,1
 3ac:	0705                	addi	a4,a4,1
 3ae:	fff5c683          	lbu	a3,-1(a1)
 3b2:	fed70fa3          	sb	a3,-1(a4) # 3fff <base+0x2fef>
    while(n-- > 0)
 3b6:	fee79ae3          	bne	a5,a4,3aa <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ba:	6422                	ld	s0,8(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret
    dst += n;
 3c0:	00c50733          	add	a4,a0,a2
    src += n;
 3c4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3c6:	fec05ae3          	blez	a2,3ba <memmove+0x2c>
 3ca:	fff6079b          	addiw	a5,a2,-1
 3ce:	1782                	slli	a5,a5,0x20
 3d0:	9381                	srli	a5,a5,0x20
 3d2:	fff7c793          	not	a5,a5
 3d6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3d8:	15fd                	addi	a1,a1,-1
 3da:	177d                	addi	a4,a4,-1
 3dc:	0005c683          	lbu	a3,0(a1)
 3e0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3e4:	fee79ae3          	bne	a5,a4,3d8 <memmove+0x4a>
 3e8:	bfc9                	j	3ba <memmove+0x2c>

00000000000003ea <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e422                	sd	s0,8(sp)
 3ee:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f0:	ca05                	beqz	a2,420 <memcmp+0x36>
 3f2:	fff6069b          	addiw	a3,a2,-1
 3f6:	1682                	slli	a3,a3,0x20
 3f8:	9281                	srli	a3,a3,0x20
 3fa:	0685                	addi	a3,a3,1
 3fc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3fe:	00054783          	lbu	a5,0(a0)
 402:	0005c703          	lbu	a4,0(a1)
 406:	00e79863          	bne	a5,a4,416 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 40a:	0505                	addi	a0,a0,1
    p2++;
 40c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 40e:	fed518e3          	bne	a0,a3,3fe <memcmp+0x14>
  }
  return 0;
 412:	4501                	li	a0,0
 414:	a019                	j	41a <memcmp+0x30>
      return *p1 - *p2;
 416:	40e7853b          	subw	a0,a5,a4
}
 41a:	6422                	ld	s0,8(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
  return 0;
 420:	4501                	li	a0,0
 422:	bfe5                	j	41a <memcmp+0x30>

0000000000000424 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 424:	1141                	addi	sp,sp,-16
 426:	e406                	sd	ra,8(sp)
 428:	e022                	sd	s0,0(sp)
 42a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 42c:	00000097          	auipc	ra,0x0
 430:	f62080e7          	jalr	-158(ra) # 38e <memmove>
}
 434:	60a2                	ld	ra,8(sp)
 436:	6402                	ld	s0,0(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret

000000000000043c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 43c:	4885                	li	a7,1
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <exit>:
.global exit
exit:
 li a7, SYS_exit
 444:	4889                	li	a7,2
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 44c:	48e1                	li	a7,24
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <wait>:
.global wait
wait:
 li a7, SYS_wait
 454:	488d                	li	a7,3
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 45c:	4891                	li	a7,4
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <read>:
.global read
read:
 li a7, SYS_read
 464:	4895                	li	a7,5
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <write>:
.global write
write:
 li a7, SYS_write
 46c:	48c1                	li	a7,16
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <close>:
.global close
close:
 li a7, SYS_close
 474:	48d5                	li	a7,21
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <kill>:
.global kill
kill:
 li a7, SYS_kill
 47c:	4899                	li	a7,6
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <exec>:
.global exec
exec:
 li a7, SYS_exec
 484:	489d                	li	a7,7
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <open>:
.global open
open:
 li a7, SYS_open
 48c:	48bd                	li	a7,15
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 494:	48c5                	li	a7,17
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 49c:	48c9                	li	a7,18
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4a4:	48a1                	li	a7,8
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <link>:
.global link
link:
 li a7, SYS_link
 4ac:	48cd                	li	a7,19
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b4:	48d1                	li	a7,20
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4bc:	48a5                	li	a7,9
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c4:	48a9                	li	a7,10
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4cc:	48ad                	li	a7,11
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4d4:	48b1                	li	a7,12
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4dc:	48b5                	li	a7,13
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e4:	48b9                	li	a7,14
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 4ec:	48dd                	li	a7,23
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 4f4:	48e5                	li	a7,25
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 4fc:	48e9                	li	a7,26
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 504:	48ed                	li	a7,27
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 50c:	1101                	addi	sp,sp,-32
 50e:	ec06                	sd	ra,24(sp)
 510:	e822                	sd	s0,16(sp)
 512:	1000                	addi	s0,sp,32
 514:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 518:	4605                	li	a2,1
 51a:	fef40593          	addi	a1,s0,-17
 51e:	00000097          	auipc	ra,0x0
 522:	f4e080e7          	jalr	-178(ra) # 46c <write>
}
 526:	60e2                	ld	ra,24(sp)
 528:	6442                	ld	s0,16(sp)
 52a:	6105                	addi	sp,sp,32
 52c:	8082                	ret

000000000000052e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 52e:	7139                	addi	sp,sp,-64
 530:	fc06                	sd	ra,56(sp)
 532:	f822                	sd	s0,48(sp)
 534:	f426                	sd	s1,40(sp)
 536:	f04a                	sd	s2,32(sp)
 538:	ec4e                	sd	s3,24(sp)
 53a:	0080                	addi	s0,sp,64
 53c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 53e:	c299                	beqz	a3,544 <printint+0x16>
 540:	0805c863          	bltz	a1,5d0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 544:	2581                	sext.w	a1,a1
  neg = 0;
 546:	4881                	li	a7,0
 548:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 54c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 54e:	2601                	sext.w	a2,a2
 550:	00000517          	auipc	a0,0x0
 554:	56850513          	addi	a0,a0,1384 # ab8 <digits>
 558:	883a                	mv	a6,a4
 55a:	2705                	addiw	a4,a4,1
 55c:	02c5f7bb          	remuw	a5,a1,a2
 560:	1782                	slli	a5,a5,0x20
 562:	9381                	srli	a5,a5,0x20
 564:	97aa                	add	a5,a5,a0
 566:	0007c783          	lbu	a5,0(a5)
 56a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 56e:	0005879b          	sext.w	a5,a1
 572:	02c5d5bb          	divuw	a1,a1,a2
 576:	0685                	addi	a3,a3,1
 578:	fec7f0e3          	bgeu	a5,a2,558 <printint+0x2a>
  if(neg)
 57c:	00088b63          	beqz	a7,592 <printint+0x64>
    buf[i++] = '-';
 580:	fd040793          	addi	a5,s0,-48
 584:	973e                	add	a4,a4,a5
 586:	02d00793          	li	a5,45
 58a:	fef70823          	sb	a5,-16(a4)
 58e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 592:	02e05863          	blez	a4,5c2 <printint+0x94>
 596:	fc040793          	addi	a5,s0,-64
 59a:	00e78933          	add	s2,a5,a4
 59e:	fff78993          	addi	s3,a5,-1
 5a2:	99ba                	add	s3,s3,a4
 5a4:	377d                	addiw	a4,a4,-1
 5a6:	1702                	slli	a4,a4,0x20
 5a8:	9301                	srli	a4,a4,0x20
 5aa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5ae:	fff94583          	lbu	a1,-1(s2)
 5b2:	8526                	mv	a0,s1
 5b4:	00000097          	auipc	ra,0x0
 5b8:	f58080e7          	jalr	-168(ra) # 50c <putc>
  while(--i >= 0)
 5bc:	197d                	addi	s2,s2,-1
 5be:	ff3918e3          	bne	s2,s3,5ae <printint+0x80>
}
 5c2:	70e2                	ld	ra,56(sp)
 5c4:	7442                	ld	s0,48(sp)
 5c6:	74a2                	ld	s1,40(sp)
 5c8:	7902                	ld	s2,32(sp)
 5ca:	69e2                	ld	s3,24(sp)
 5cc:	6121                	addi	sp,sp,64
 5ce:	8082                	ret
    x = -xx;
 5d0:	40b005bb          	negw	a1,a1
    neg = 1;
 5d4:	4885                	li	a7,1
    x = -xx;
 5d6:	bf8d                	j	548 <printint+0x1a>

00000000000005d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d8:	7119                	addi	sp,sp,-128
 5da:	fc86                	sd	ra,120(sp)
 5dc:	f8a2                	sd	s0,112(sp)
 5de:	f4a6                	sd	s1,104(sp)
 5e0:	f0ca                	sd	s2,96(sp)
 5e2:	ecce                	sd	s3,88(sp)
 5e4:	e8d2                	sd	s4,80(sp)
 5e6:	e4d6                	sd	s5,72(sp)
 5e8:	e0da                	sd	s6,64(sp)
 5ea:	fc5e                	sd	s7,56(sp)
 5ec:	f862                	sd	s8,48(sp)
 5ee:	f466                	sd	s9,40(sp)
 5f0:	f06a                	sd	s10,32(sp)
 5f2:	ec6e                	sd	s11,24(sp)
 5f4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f6:	0005c903          	lbu	s2,0(a1)
 5fa:	18090f63          	beqz	s2,798 <vprintf+0x1c0>
 5fe:	8aaa                	mv	s5,a0
 600:	8b32                	mv	s6,a2
 602:	00158493          	addi	s1,a1,1
  state = 0;
 606:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 608:	02500a13          	li	s4,37
      if(c == 'd'){
 60c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 610:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 614:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 618:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61c:	00000b97          	auipc	s7,0x0
 620:	49cb8b93          	addi	s7,s7,1180 # ab8 <digits>
 624:	a839                	j	642 <vprintf+0x6a>
        putc(fd, c);
 626:	85ca                	mv	a1,s2
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	ee2080e7          	jalr	-286(ra) # 50c <putc>
 632:	a019                	j	638 <vprintf+0x60>
    } else if(state == '%'){
 634:	01498f63          	beq	s3,s4,652 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 638:	0485                	addi	s1,s1,1
 63a:	fff4c903          	lbu	s2,-1(s1)
 63e:	14090d63          	beqz	s2,798 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 642:	0009079b          	sext.w	a5,s2
    if(state == 0){
 646:	fe0997e3          	bnez	s3,634 <vprintf+0x5c>
      if(c == '%'){
 64a:	fd479ee3          	bne	a5,s4,626 <vprintf+0x4e>
        state = '%';
 64e:	89be                	mv	s3,a5
 650:	b7e5                	j	638 <vprintf+0x60>
      if(c == 'd'){
 652:	05878063          	beq	a5,s8,692 <vprintf+0xba>
      } else if(c == 'l') {
 656:	05978c63          	beq	a5,s9,6ae <vprintf+0xd6>
      } else if(c == 'x') {
 65a:	07a78863          	beq	a5,s10,6ca <vprintf+0xf2>
      } else if(c == 'p') {
 65e:	09b78463          	beq	a5,s11,6e6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 662:	07300713          	li	a4,115
 666:	0ce78663          	beq	a5,a4,732 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 66a:	06300713          	li	a4,99
 66e:	0ee78e63          	beq	a5,a4,76a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 672:	11478863          	beq	a5,s4,782 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 676:	85d2                	mv	a1,s4
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	e92080e7          	jalr	-366(ra) # 50c <putc>
        putc(fd, c);
 682:	85ca                	mv	a1,s2
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	e86080e7          	jalr	-378(ra) # 50c <putc>
      }
      state = 0;
 68e:	4981                	li	s3,0
 690:	b765                	j	638 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 692:	008b0913          	addi	s2,s6,8
 696:	4685                	li	a3,1
 698:	4629                	li	a2,10
 69a:	000b2583          	lw	a1,0(s6)
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	e8e080e7          	jalr	-370(ra) # 52e <printint>
 6a8:	8b4a                	mv	s6,s2
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b771                	j	638 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ae:	008b0913          	addi	s2,s6,8
 6b2:	4681                	li	a3,0
 6b4:	4629                	li	a2,10
 6b6:	000b2583          	lw	a1,0(s6)
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e72080e7          	jalr	-398(ra) # 52e <printint>
 6c4:	8b4a                	mv	s6,s2
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	bf85                	j	638 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6ca:	008b0913          	addi	s2,s6,8
 6ce:	4681                	li	a3,0
 6d0:	4641                	li	a2,16
 6d2:	000b2583          	lw	a1,0(s6)
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e56080e7          	jalr	-426(ra) # 52e <printint>
 6e0:	8b4a                	mv	s6,s2
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bf91                	j	638 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6e6:	008b0793          	addi	a5,s6,8
 6ea:	f8f43423          	sd	a5,-120(s0)
 6ee:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6f2:	03000593          	li	a1,48
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	e14080e7          	jalr	-492(ra) # 50c <putc>
  putc(fd, 'x');
 700:	85ea                	mv	a1,s10
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	e08080e7          	jalr	-504(ra) # 50c <putc>
 70c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70e:	03c9d793          	srli	a5,s3,0x3c
 712:	97de                	add	a5,a5,s7
 714:	0007c583          	lbu	a1,0(a5)
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	df2080e7          	jalr	-526(ra) # 50c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 722:	0992                	slli	s3,s3,0x4
 724:	397d                	addiw	s2,s2,-1
 726:	fe0914e3          	bnez	s2,70e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 72a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 72e:	4981                	li	s3,0
 730:	b721                	j	638 <vprintf+0x60>
        s = va_arg(ap, char*);
 732:	008b0993          	addi	s3,s6,8
 736:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 73a:	02090163          	beqz	s2,75c <vprintf+0x184>
        while(*s != 0){
 73e:	00094583          	lbu	a1,0(s2)
 742:	c9a1                	beqz	a1,792 <vprintf+0x1ba>
          putc(fd, *s);
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	dc6080e7          	jalr	-570(ra) # 50c <putc>
          s++;
 74e:	0905                	addi	s2,s2,1
        while(*s != 0){
 750:	00094583          	lbu	a1,0(s2)
 754:	f9e5                	bnez	a1,744 <vprintf+0x16c>
        s = va_arg(ap, char*);
 756:	8b4e                	mv	s6,s3
      state = 0;
 758:	4981                	li	s3,0
 75a:	bdf9                	j	638 <vprintf+0x60>
          s = "(null)";
 75c:	00000917          	auipc	s2,0x0
 760:	35490913          	addi	s2,s2,852 # ab0 <malloc+0x20e>
        while(*s != 0){
 764:	02800593          	li	a1,40
 768:	bff1                	j	744 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 76a:	008b0913          	addi	s2,s6,8
 76e:	000b4583          	lbu	a1,0(s6)
 772:	8556                	mv	a0,s5
 774:	00000097          	auipc	ra,0x0
 778:	d98080e7          	jalr	-616(ra) # 50c <putc>
 77c:	8b4a                	mv	s6,s2
      state = 0;
 77e:	4981                	li	s3,0
 780:	bd65                	j	638 <vprintf+0x60>
        putc(fd, c);
 782:	85d2                	mv	a1,s4
 784:	8556                	mv	a0,s5
 786:	00000097          	auipc	ra,0x0
 78a:	d86080e7          	jalr	-634(ra) # 50c <putc>
      state = 0;
 78e:	4981                	li	s3,0
 790:	b565                	j	638 <vprintf+0x60>
        s = va_arg(ap, char*);
 792:	8b4e                	mv	s6,s3
      state = 0;
 794:	4981                	li	s3,0
 796:	b54d                	j	638 <vprintf+0x60>
    }
  }
}
 798:	70e6                	ld	ra,120(sp)
 79a:	7446                	ld	s0,112(sp)
 79c:	74a6                	ld	s1,104(sp)
 79e:	7906                	ld	s2,96(sp)
 7a0:	69e6                	ld	s3,88(sp)
 7a2:	6a46                	ld	s4,80(sp)
 7a4:	6aa6                	ld	s5,72(sp)
 7a6:	6b06                	ld	s6,64(sp)
 7a8:	7be2                	ld	s7,56(sp)
 7aa:	7c42                	ld	s8,48(sp)
 7ac:	7ca2                	ld	s9,40(sp)
 7ae:	7d02                	ld	s10,32(sp)
 7b0:	6de2                	ld	s11,24(sp)
 7b2:	6109                	addi	sp,sp,128
 7b4:	8082                	ret

00000000000007b6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b6:	715d                	addi	sp,sp,-80
 7b8:	ec06                	sd	ra,24(sp)
 7ba:	e822                	sd	s0,16(sp)
 7bc:	1000                	addi	s0,sp,32
 7be:	e010                	sd	a2,0(s0)
 7c0:	e414                	sd	a3,8(s0)
 7c2:	e818                	sd	a4,16(s0)
 7c4:	ec1c                	sd	a5,24(s0)
 7c6:	03043023          	sd	a6,32(s0)
 7ca:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ce:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d2:	8622                	mv	a2,s0
 7d4:	00000097          	auipc	ra,0x0
 7d8:	e04080e7          	jalr	-508(ra) # 5d8 <vprintf>
}
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	6161                	addi	sp,sp,80
 7e2:	8082                	ret

00000000000007e4 <printf>:

void
printf(const char *fmt, ...)
{
 7e4:	711d                	addi	sp,sp,-96
 7e6:	ec06                	sd	ra,24(sp)
 7e8:	e822                	sd	s0,16(sp)
 7ea:	1000                	addi	s0,sp,32
 7ec:	e40c                	sd	a1,8(s0)
 7ee:	e810                	sd	a2,16(s0)
 7f0:	ec14                	sd	a3,24(s0)
 7f2:	f018                	sd	a4,32(s0)
 7f4:	f41c                	sd	a5,40(s0)
 7f6:	03043823          	sd	a6,48(s0)
 7fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fe:	00840613          	addi	a2,s0,8
 802:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 806:	85aa                	mv	a1,a0
 808:	4505                	li	a0,1
 80a:	00000097          	auipc	ra,0x0
 80e:	dce080e7          	jalr	-562(ra) # 5d8 <vprintf>
}
 812:	60e2                	ld	ra,24(sp)
 814:	6442                	ld	s0,16(sp)
 816:	6125                	addi	sp,sp,96
 818:	8082                	ret

000000000000081a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81a:	1141                	addi	sp,sp,-16
 81c:	e422                	sd	s0,8(sp)
 81e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 820:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 824:	00000797          	auipc	a5,0x0
 828:	7dc7b783          	ld	a5,2012(a5) # 1000 <freep>
 82c:	a805                	j	85c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 82e:	4618                	lw	a4,8(a2)
 830:	9db9                	addw	a1,a1,a4
 832:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 836:	6398                	ld	a4,0(a5)
 838:	6318                	ld	a4,0(a4)
 83a:	fee53823          	sd	a4,-16(a0)
 83e:	a091                	j	882 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 840:	ff852703          	lw	a4,-8(a0)
 844:	9e39                	addw	a2,a2,a4
 846:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 848:	ff053703          	ld	a4,-16(a0)
 84c:	e398                	sd	a4,0(a5)
 84e:	a099                	j	894 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 850:	6398                	ld	a4,0(a5)
 852:	00e7e463          	bltu	a5,a4,85a <free+0x40>
 856:	00e6ea63          	bltu	a3,a4,86a <free+0x50>
{
 85a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85c:	fed7fae3          	bgeu	a5,a3,850 <free+0x36>
 860:	6398                	ld	a4,0(a5)
 862:	00e6e463          	bltu	a3,a4,86a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 866:	fee7eae3          	bltu	a5,a4,85a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 86a:	ff852583          	lw	a1,-8(a0)
 86e:	6390                	ld	a2,0(a5)
 870:	02059713          	slli	a4,a1,0x20
 874:	9301                	srli	a4,a4,0x20
 876:	0712                	slli	a4,a4,0x4
 878:	9736                	add	a4,a4,a3
 87a:	fae60ae3          	beq	a2,a4,82e <free+0x14>
    bp->s.ptr = p->s.ptr;
 87e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 882:	4790                	lw	a2,8(a5)
 884:	02061713          	slli	a4,a2,0x20
 888:	9301                	srli	a4,a4,0x20
 88a:	0712                	slli	a4,a4,0x4
 88c:	973e                	add	a4,a4,a5
 88e:	fae689e3          	beq	a3,a4,840 <free+0x26>
  } else
    p->s.ptr = bp;
 892:	e394                	sd	a3,0(a5)
  freep = p;
 894:	00000717          	auipc	a4,0x0
 898:	76f73623          	sd	a5,1900(a4) # 1000 <freep>
}
 89c:	6422                	ld	s0,8(sp)
 89e:	0141                	addi	sp,sp,16
 8a0:	8082                	ret

00000000000008a2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a2:	7139                	addi	sp,sp,-64
 8a4:	fc06                	sd	ra,56(sp)
 8a6:	f822                	sd	s0,48(sp)
 8a8:	f426                	sd	s1,40(sp)
 8aa:	f04a                	sd	s2,32(sp)
 8ac:	ec4e                	sd	s3,24(sp)
 8ae:	e852                	sd	s4,16(sp)
 8b0:	e456                	sd	s5,8(sp)
 8b2:	e05a                	sd	s6,0(sp)
 8b4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b6:	02051493          	slli	s1,a0,0x20
 8ba:	9081                	srli	s1,s1,0x20
 8bc:	04bd                	addi	s1,s1,15
 8be:	8091                	srli	s1,s1,0x4
 8c0:	0014899b          	addiw	s3,s1,1
 8c4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8c6:	00000517          	auipc	a0,0x0
 8ca:	73a53503          	ld	a0,1850(a0) # 1000 <freep>
 8ce:	c515                	beqz	a0,8fa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	02977f63          	bgeu	a4,s1,912 <malloc+0x70>
 8d8:	8a4e                	mv	s4,s3
 8da:	0009871b          	sext.w	a4,s3
 8de:	6685                	lui	a3,0x1
 8e0:	00d77363          	bgeu	a4,a3,8e6 <malloc+0x44>
 8e4:	6a05                	lui	s4,0x1
 8e6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ea:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ee:	00000917          	auipc	s2,0x0
 8f2:	71290913          	addi	s2,s2,1810 # 1000 <freep>
  if(p == (char*)-1)
 8f6:	5afd                	li	s5,-1
 8f8:	a88d                	j	96a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8fa:	00000797          	auipc	a5,0x0
 8fe:	71678793          	addi	a5,a5,1814 # 1010 <base>
 902:	00000717          	auipc	a4,0x0
 906:	6ef73f23          	sd	a5,1790(a4) # 1000 <freep>
 90a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 90c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 910:	b7e1                	j	8d8 <malloc+0x36>
      if(p->s.size == nunits)
 912:	02e48b63          	beq	s1,a4,948 <malloc+0xa6>
        p->s.size -= nunits;
 916:	4137073b          	subw	a4,a4,s3
 91a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 91c:	1702                	slli	a4,a4,0x20
 91e:	9301                	srli	a4,a4,0x20
 920:	0712                	slli	a4,a4,0x4
 922:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 924:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 928:	00000717          	auipc	a4,0x0
 92c:	6ca73c23          	sd	a0,1752(a4) # 1000 <freep>
      return (void*)(p + 1);
 930:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 934:	70e2                	ld	ra,56(sp)
 936:	7442                	ld	s0,48(sp)
 938:	74a2                	ld	s1,40(sp)
 93a:	7902                	ld	s2,32(sp)
 93c:	69e2                	ld	s3,24(sp)
 93e:	6a42                	ld	s4,16(sp)
 940:	6aa2                	ld	s5,8(sp)
 942:	6b02                	ld	s6,0(sp)
 944:	6121                	addi	sp,sp,64
 946:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 948:	6398                	ld	a4,0(a5)
 94a:	e118                	sd	a4,0(a0)
 94c:	bff1                	j	928 <malloc+0x86>
  hp->s.size = nu;
 94e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 952:	0541                	addi	a0,a0,16
 954:	00000097          	auipc	ra,0x0
 958:	ec6080e7          	jalr	-314(ra) # 81a <free>
  return freep;
 95c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 960:	d971                	beqz	a0,934 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 962:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 964:	4798                	lw	a4,8(a5)
 966:	fa9776e3          	bgeu	a4,s1,912 <malloc+0x70>
    if(p == freep)
 96a:	00093703          	ld	a4,0(s2)
 96e:	853e                	mv	a0,a5
 970:	fef719e3          	bne	a4,a5,962 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 974:	8552                	mv	a0,s4
 976:	00000097          	auipc	ra,0x0
 97a:	b5e080e7          	jalr	-1186(ra) # 4d4 <sbrk>
  if(p == (char*)-1)
 97e:	fd5518e3          	bne	a0,s5,94e <malloc+0xac>
        return 0;
 982:	4501                	li	a0,0
 984:	bf45                	j	934 <malloc+0x92>
