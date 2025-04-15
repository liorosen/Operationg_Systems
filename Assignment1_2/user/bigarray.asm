
user/_bigarray:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define NUM_CHILDREN 4
#define CHUNK_SIZE (SIZE / NUM_CHILDREN)



int main() {
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	f852                	sd	s4,48(sp)
   e:	1080                	addi	s0,sp,96
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);
  10:	4591                	li	a1,4
  12:	00001517          	auipc	a0,0x1
  16:	9be50513          	addi	a0,a0,-1602 # 9d0 <malloc+0xf2>
  1a:	00001097          	auipc	ra,0x1
  1e:	806080e7          	jalr	-2042(ra) # 820 <printf>

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN] ;
  int n = NUM_CHILDREN;
  22:	4791                	li	a5,4
  24:	faf42623          	sw	a5,-84(s0)

  int ret = forkn(NUM_CHILDREN, pids);
  28:	fc040593          	addi	a1,s0,-64
  2c:	4511                	li	a0,4
  2e:	00000097          	auipc	ra,0x0
  32:	502080e7          	jalr	1282(ra) # 530 <forkn>

  if (ret == -1) {
  36:	57fd                	li	a5,-1
  38:	02f50463          	beq	a0,a5,60 <main+0x60>
  3c:	84aa                	mv	s1,a0
    printf("forkn failed\n");
    exit(-1);
  } else if (ret >= 0 && ret < NUM_CHILDREN) {
  3e:	0005079b          	sext.w	a5,a0
  42:	470d                	li	a4,3
  44:	02f77b63          	bgeu	a4,a5,7a <main+0x7a>

    //  Use printf directly instead of manual string building
    printf("Child %d calculated sum: %d\n", ret, (int)sum);
    sleep(50 * ret);  // let lower-numbered children print first
    exit((int)(sum % 32768));  // Limit to 15 bits max
  } else if (ret == -2) {
  48:	57f9                	li	a5,-2
  4a:	08f50d63          	beq	a0,a5,e4 <main+0xe4>

    exit(0);
  }

  return 0;
}
  4e:	4501                	li	a0,0
  50:	60e6                	ld	ra,88(sp)
  52:	6446                	ld	s0,80(sp)
  54:	64a6                	ld	s1,72(sp)
  56:	6906                	ld	s2,64(sp)
  58:	79e2                	ld	s3,56(sp)
  5a:	7a42                	ld	s4,48(sp)
  5c:	6125                	addi	sp,sp,96
  5e:	8082                	ret
    printf("forkn failed\n");
  60:	00001517          	auipc	a0,0x1
  64:	99050513          	addi	a0,a0,-1648 # 9f0 <malloc+0x112>
  68:	00000097          	auipc	ra,0x0
  6c:	7b8080e7          	jalr	1976(ra) # 820 <printf>
    exit(-1);
  70:	557d                	li	a0,-1
  72:	00000097          	auipc	ra,0x0
  76:	40e080e7          	jalr	1038(ra) # 480 <exit>
    long long start = ret * CHUNK_SIZE;
  7a:	00e5161b          	slliw	a2,a0,0xe
  7e:	0006071b          	sext.w	a4,a2
    long long end = (ret + 1) * CHUNK_SIZE;
  82:	6691                	lui	a3,0x4
  84:	9eb1                	addw	a3,a3,a2
    for (long long i = start + 1; i <= end; i++) {
  86:	0705                	addi	a4,a4,1
    long long sum = 0;
  88:	4981                	li	s3,0
    for (long long i = start + 1; i <= end; i++) {
  8a:	a019                	j	90 <main+0x90>
      sum += i;
  8c:	99ba                	add	s3,s3,a4
    for (long long i = start + 1; i <= end; i++) {
  8e:	0705                	addi	a4,a4,1
  90:	fee6dee3          	bge	a3,a4,8c <main+0x8c>
  94:	03200a13          	li	s4,50
  98:	02fa0a3b          	mulw	s4,s4,a5
    for (int i = 0; i < ret; i++) {
  9c:	4901                	li	s2,0
  9e:	a039                	j	ac <main+0xac>
      sleep(50 * ret);  // let lower-numbered children print first
  a0:	8552                	mv	a0,s4
  a2:	00000097          	auipc	ra,0x0
  a6:	476080e7          	jalr	1142(ra) # 518 <sleep>
    for (int i = 0; i < ret; i++) {
  aa:	2905                	addiw	s2,s2,1
  ac:	fe991ae3          	bne	s2,s1,a0 <main+0xa0>
    printf("Child %d calculated sum: %d\n", ret, (int)sum);
  b0:	0009861b          	sext.w	a2,s3
  b4:	85a6                	mv	a1,s1
  b6:	00001517          	auipc	a0,0x1
  ba:	94a50513          	addi	a0,a0,-1718 # a00 <malloc+0x122>
  be:	00000097          	auipc	ra,0x0
  c2:	762080e7          	jalr	1890(ra) # 820 <printf>
    sleep(50 * ret);  // let lower-numbered children print first
  c6:	03200513          	li	a0,50
  ca:	0295053b          	mulw	a0,a0,s1
  ce:	00000097          	auipc	ra,0x0
  d2:	44a080e7          	jalr	1098(ra) # 518 <sleep>
    exit((int)(sum % 32768));  // Limit to 15 bits max
  d6:	6521                	lui	a0,0x8
  d8:	02a9e533          	rem	a0,s3,a0
  dc:	00000097          	auipc	ra,0x0
  e0:	3a4080e7          	jalr	932(ra) # 480 <exit>
    sleep(100);
  e4:	06400513          	li	a0,100
  e8:	00000097          	auipc	ra,0x0
  ec:	430080e7          	jalr	1072(ra) # 518 <sleep>
    printf("===> Waiting for children with waitall()\n");
  f0:	00001517          	auipc	a0,0x1
  f4:	93050513          	addi	a0,a0,-1744 # a20 <malloc+0x142>
  f8:	00000097          	auipc	ra,0x0
  fc:	728080e7          	jalr	1832(ra) # 820 <printf>
    if (waitall(&n, statuses) < 0) {
 100:	fb040593          	addi	a1,s0,-80
 104:	fac40513          	addi	a0,s0,-84
 108:	00000097          	auipc	ra,0x0
 10c:	430080e7          	jalr	1072(ra) # 538 <waitall>
 110:	08054663          	bltz	a0,19c <main+0x19c>
    for (int i = 0; i < n; i++) {
 114:	fac42583          	lw	a1,-84(s0)
 118:	0ab05963          	blez	a1,1ca <main+0x1ca>
 11c:	fb040913          	addi	s2,s0,-80
 120:	4481                	li	s1,0
    long long total = 0;
 122:	4981                	li	s3,0
      printf("statuses[%d] = %d\n", i, statuses[i]);
 124:	00001a17          	auipc	s4,0x1
 128:	93ca0a13          	addi	s4,s4,-1732 # a60 <malloc+0x182>
 12c:	00092603          	lw	a2,0(s2)
 130:	85a6                	mv	a1,s1
 132:	8552                	mv	a0,s4
 134:	00000097          	auipc	ra,0x0
 138:	6ec080e7          	jalr	1772(ra) # 820 <printf>
      total += (long long)statuses[i];
 13c:	00092783          	lw	a5,0(s2)
 140:	99be                	add	s3,s3,a5
    for (int i = 0; i < n; i++) {
 142:	2485                	addiw	s1,s1,1
 144:	fac42583          	lw	a1,-84(s0)
 148:	0911                	addi	s2,s2,4
 14a:	feb4c1e3          	blt	s1,a1,12c <main+0x12c>
    printf("===> All %d children finished\n", n);
 14e:	00001517          	auipc	a0,0x1
 152:	92a50513          	addi	a0,a0,-1750 # a78 <malloc+0x19a>
 156:	00000097          	auipc	ra,0x0
 15a:	6ca080e7          	jalr	1738(ra) # 820 <printf>
    printf("Sum of all children's sums: %lld\n", total);
 15e:	85ce                	mv	a1,s3
 160:	00001517          	auipc	a0,0x1
 164:	93850513          	addi	a0,a0,-1736 # a98 <malloc+0x1ba>
 168:	00000097          	auipc	ra,0x0
 16c:	6b8080e7          	jalr	1720(ra) # 820 <printf>
    if (total == expected) {
 170:	100017b7          	lui	a5,0x10001
 174:	078e                	slli	a5,a5,0x3
 176:	04f98063          	beq	s3,a5,1b6 <main+0x1b6>
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);
 17a:	10001637          	lui	a2,0x10001
 17e:	060e                	slli	a2,a2,0x3
 180:	85ce                	mv	a1,s3
 182:	00001517          	auipc	a0,0x1
 186:	95e50513          	addi	a0,a0,-1698 # ae0 <malloc+0x202>
 18a:	00000097          	auipc	ra,0x0
 18e:	696080e7          	jalr	1686(ra) # 820 <printf>
    exit(0);
 192:	4501                	li	a0,0
 194:	00000097          	auipc	ra,0x0
 198:	2ec080e7          	jalr	748(ra) # 480 <exit>
      printf("waitall failed\n");
 19c:	00001517          	auipc	a0,0x1
 1a0:	8b450513          	addi	a0,a0,-1868 # a50 <malloc+0x172>
 1a4:	00000097          	auipc	ra,0x0
 1a8:	67c080e7          	jalr	1660(ra) # 820 <printf>
      exit(-1);
 1ac:	557d                	li	a0,-1
 1ae:	00000097          	auipc	ra,0x0
 1b2:	2d2080e7          	jalr	722(ra) # 480 <exit>
      printf("Correct total sum: %lld\n", total);
 1b6:	85be                	mv	a1,a5
 1b8:	00001517          	auipc	a0,0x1
 1bc:	90850513          	addi	a0,a0,-1784 # ac0 <malloc+0x1e2>
 1c0:	00000097          	auipc	ra,0x0
 1c4:	660080e7          	jalr	1632(ra) # 820 <printf>
 1c8:	b7e9                	j	192 <main+0x192>
    printf("===> All %d children finished\n", n);
 1ca:	00001517          	auipc	a0,0x1
 1ce:	8ae50513          	addi	a0,a0,-1874 # a78 <malloc+0x19a>
 1d2:	00000097          	auipc	ra,0x0
 1d6:	64e080e7          	jalr	1614(ra) # 820 <printf>
    printf("Sum of all children's sums: %lld\n", total);
 1da:	4581                	li	a1,0
 1dc:	00001517          	auipc	a0,0x1
 1e0:	8bc50513          	addi	a0,a0,-1860 # a98 <malloc+0x1ba>
 1e4:	00000097          	auipc	ra,0x0
 1e8:	63c080e7          	jalr	1596(ra) # 820 <printf>
    long long total = 0;
 1ec:	4981                	li	s3,0
 1ee:	b771                	j	17a <main+0x17a>

00000000000001f0 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e406                	sd	ra,8(sp)
 1f4:	e022                	sd	s0,0(sp)
 1f6:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1f8:	00000097          	auipc	ra,0x0
 1fc:	e08080e7          	jalr	-504(ra) # 0 <main>
  exit(0);
 200:	4501                	li	a0,0
 202:	00000097          	auipc	ra,0x0
 206:	27e080e7          	jalr	638(ra) # 480 <exit>

000000000000020a <strcpy>:
}

char* strcpy(char *s, const char *t)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 210:	87aa                	mv	a5,a0
 212:	0585                	addi	a1,a1,1
 214:	0785                	addi	a5,a5,1
 216:	fff5c703          	lbu	a4,-1(a1)
 21a:	fee78fa3          	sb	a4,-1(a5) # 10000fff <base+0xfffffef>
 21e:	fb75                	bnez	a4,212 <strcpy+0x8>
    ;
  return os;
}
 220:	6422                	ld	s0,8(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret

0000000000000226 <strcmp>:

int strcmp(const char *p, const char *q)
{
 226:	1141                	addi	sp,sp,-16
 228:	e422                	sd	s0,8(sp)
 22a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 22c:	00054783          	lbu	a5,0(a0)
 230:	cb91                	beqz	a5,244 <strcmp+0x1e>
 232:	0005c703          	lbu	a4,0(a1)
 236:	00f71763          	bne	a4,a5,244 <strcmp+0x1e>
    p++, q++;
 23a:	0505                	addi	a0,a0,1
 23c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 23e:	00054783          	lbu	a5,0(a0)
 242:	fbe5                	bnez	a5,232 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 244:	0005c503          	lbu	a0,0(a1)
}
 248:	40a7853b          	subw	a0,a5,a0
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret

0000000000000252 <strlen>:

uint strlen(const char *s)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 258:	00054783          	lbu	a5,0(a0)
 25c:	cf91                	beqz	a5,278 <strlen+0x26>
 25e:	0505                	addi	a0,a0,1
 260:	87aa                	mv	a5,a0
 262:	4685                	li	a3,1
 264:	9e89                	subw	a3,a3,a0
 266:	00f6853b          	addw	a0,a3,a5
 26a:	0785                	addi	a5,a5,1
 26c:	fff7c703          	lbu	a4,-1(a5)
 270:	fb7d                	bnez	a4,266 <strlen+0x14>
    ;
  return n;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
  for(n = 0; s[n]; n++)
 278:	4501                	li	a0,0
 27a:	bfe5                	j	272 <strlen+0x20>

000000000000027c <memset>:

void* memset(void *dst, int c, uint n)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 282:	ce09                	beqz	a2,29c <memset+0x20>
 284:	87aa                	mv	a5,a0
 286:	fff6071b          	addiw	a4,a2,-1
 28a:	1702                	slli	a4,a4,0x20
 28c:	9301                	srli	a4,a4,0x20
 28e:	0705                	addi	a4,a4,1
 290:	972a                	add	a4,a4,a0
    cdst[i] = c;
 292:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 296:	0785                	addi	a5,a5,1
 298:	fee79de3          	bne	a5,a4,292 <memset+0x16>
  }
  return dst;
}
 29c:	6422                	ld	s0,8(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret

00000000000002a2 <strchr>:

char* strchr(const char *s, char c)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2a8:	00054783          	lbu	a5,0(a0)
 2ac:	cb99                	beqz	a5,2c2 <strchr+0x20>
    if(*s == c)
 2ae:	00f58763          	beq	a1,a5,2bc <strchr+0x1a>
  for(; *s; s++)
 2b2:	0505                	addi	a0,a0,1
 2b4:	00054783          	lbu	a5,0(a0)
 2b8:	fbfd                	bnez	a5,2ae <strchr+0xc>
      return (char*)s;
  return 0;
 2ba:	4501                	li	a0,0
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
  return 0;
 2c2:	4501                	li	a0,0
 2c4:	bfe5                	j	2bc <strchr+0x1a>

00000000000002c6 <gets>:

char* gets(char *buf, int max)
{
 2c6:	711d                	addi	sp,sp,-96
 2c8:	ec86                	sd	ra,88(sp)
 2ca:	e8a2                	sd	s0,80(sp)
 2cc:	e4a6                	sd	s1,72(sp)
 2ce:	e0ca                	sd	s2,64(sp)
 2d0:	fc4e                	sd	s3,56(sp)
 2d2:	f852                	sd	s4,48(sp)
 2d4:	f456                	sd	s5,40(sp)
 2d6:	f05a                	sd	s6,32(sp)
 2d8:	ec5e                	sd	s7,24(sp)
 2da:	1080                	addi	s0,sp,96
 2dc:	8baa                	mv	s7,a0
 2de:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e0:	892a                	mv	s2,a0
 2e2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2e4:	4aa9                	li	s5,10
 2e6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2e8:	89a6                	mv	s3,s1
 2ea:	2485                	addiw	s1,s1,1
 2ec:	0344d863          	bge	s1,s4,31c <gets+0x56>
    cc = read(0, &c, 1);
 2f0:	4605                	li	a2,1
 2f2:	faf40593          	addi	a1,s0,-81
 2f6:	4501                	li	a0,0
 2f8:	00000097          	auipc	ra,0x0
 2fc:	1a8080e7          	jalr	424(ra) # 4a0 <read>
    if(cc < 1)
 300:	00a05e63          	blez	a0,31c <gets+0x56>
    buf[i++] = c;
 304:	faf44783          	lbu	a5,-81(s0)
 308:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 30c:	01578763          	beq	a5,s5,31a <gets+0x54>
 310:	0905                	addi	s2,s2,1
 312:	fd679be3          	bne	a5,s6,2e8 <gets+0x22>
  for(i=0; i+1 < max; ){
 316:	89a6                	mv	s3,s1
 318:	a011                	j	31c <gets+0x56>
 31a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 31c:	99de                	add	s3,s3,s7
 31e:	00098023          	sb	zero,0(s3)
  return buf;
}
 322:	855e                	mv	a0,s7
 324:	60e6                	ld	ra,88(sp)
 326:	6446                	ld	s0,80(sp)
 328:	64a6                	ld	s1,72(sp)
 32a:	6906                	ld	s2,64(sp)
 32c:	79e2                	ld	s3,56(sp)
 32e:	7a42                	ld	s4,48(sp)
 330:	7aa2                	ld	s5,40(sp)
 332:	7b02                	ld	s6,32(sp)
 334:	6be2                	ld	s7,24(sp)
 336:	6125                	addi	sp,sp,96
 338:	8082                	ret

000000000000033a <stat>:

int stat(const char *n, struct stat *st)
{
 33a:	1101                	addi	sp,sp,-32
 33c:	ec06                	sd	ra,24(sp)
 33e:	e822                	sd	s0,16(sp)
 340:	e426                	sd	s1,8(sp)
 342:	e04a                	sd	s2,0(sp)
 344:	1000                	addi	s0,sp,32
 346:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 348:	4581                	li	a1,0
 34a:	00000097          	auipc	ra,0x0
 34e:	17e080e7          	jalr	382(ra) # 4c8 <open>
  if(fd < 0)
 352:	02054563          	bltz	a0,37c <stat+0x42>
 356:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 358:	85ca                	mv	a1,s2
 35a:	00000097          	auipc	ra,0x0
 35e:	186080e7          	jalr	390(ra) # 4e0 <fstat>
 362:	892a                	mv	s2,a0
  close(fd);
 364:	8526                	mv	a0,s1
 366:	00000097          	auipc	ra,0x0
 36a:	14a080e7          	jalr	330(ra) # 4b0 <close>
  return r;
}
 36e:	854a                	mv	a0,s2
 370:	60e2                	ld	ra,24(sp)
 372:	6442                	ld	s0,16(sp)
 374:	64a2                	ld	s1,8(sp)
 376:	6902                	ld	s2,0(sp)
 378:	6105                	addi	sp,sp,32
 37a:	8082                	ret
    return -1;
 37c:	597d                	li	s2,-1
 37e:	bfc5                	j	36e <stat+0x34>

0000000000000380 <atoi>:

int atoi(const char *s)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 386:	00054603          	lbu	a2,0(a0)
 38a:	fd06079b          	addiw	a5,a2,-48
 38e:	0ff7f793          	andi	a5,a5,255
 392:	4725                	li	a4,9
 394:	02f76963          	bltu	a4,a5,3c6 <atoi+0x46>
 398:	86aa                	mv	a3,a0
  n = 0;
 39a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 39c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 39e:	0685                	addi	a3,a3,1
 3a0:	0025179b          	slliw	a5,a0,0x2
 3a4:	9fa9                	addw	a5,a5,a0
 3a6:	0017979b          	slliw	a5,a5,0x1
 3aa:	9fb1                	addw	a5,a5,a2
 3ac:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3b0:	0006c603          	lbu	a2,0(a3) # 4000 <base+0x2ff0>
 3b4:	fd06071b          	addiw	a4,a2,-48
 3b8:	0ff77713          	andi	a4,a4,255
 3bc:	fee5f1e3          	bgeu	a1,a4,39e <atoi+0x1e>
  return n;
}
 3c0:	6422                	ld	s0,8(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret
  n = 0;
 3c6:	4501                	li	a0,0
 3c8:	bfe5                	j	3c0 <atoi+0x40>

00000000000003ca <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 3ca:	1141                	addi	sp,sp,-16
 3cc:	e422                	sd	s0,8(sp)
 3ce:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3d0:	02b57663          	bgeu	a0,a1,3fc <memmove+0x32>
    while(n-- > 0)
 3d4:	02c05163          	blez	a2,3f6 <memmove+0x2c>
 3d8:	fff6079b          	addiw	a5,a2,-1
 3dc:	1782                	slli	a5,a5,0x20
 3de:	9381                	srli	a5,a5,0x20
 3e0:	0785                	addi	a5,a5,1
 3e2:	97aa                	add	a5,a5,a0
  dst = vdst;
 3e4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3e6:	0585                	addi	a1,a1,1
 3e8:	0705                	addi	a4,a4,1
 3ea:	fff5c683          	lbu	a3,-1(a1)
 3ee:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3f2:	fee79ae3          	bne	a5,a4,3e6 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3f6:	6422                	ld	s0,8(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret
    dst += n;
 3fc:	00c50733          	add	a4,a0,a2
    src += n;
 400:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 402:	fec05ae3          	blez	a2,3f6 <memmove+0x2c>
 406:	fff6079b          	addiw	a5,a2,-1
 40a:	1782                	slli	a5,a5,0x20
 40c:	9381                	srli	a5,a5,0x20
 40e:	fff7c793          	not	a5,a5
 412:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 414:	15fd                	addi	a1,a1,-1
 416:	177d                	addi	a4,a4,-1
 418:	0005c683          	lbu	a3,0(a1)
 41c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 420:	fee79ae3          	bne	a5,a4,414 <memmove+0x4a>
 424:	bfc9                	j	3f6 <memmove+0x2c>

0000000000000426 <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 42c:	ca05                	beqz	a2,45c <memcmp+0x36>
 42e:	fff6069b          	addiw	a3,a2,-1
 432:	1682                	slli	a3,a3,0x20
 434:	9281                	srli	a3,a3,0x20
 436:	0685                	addi	a3,a3,1
 438:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 43a:	00054783          	lbu	a5,0(a0)
 43e:	0005c703          	lbu	a4,0(a1)
 442:	00e79863          	bne	a5,a4,452 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 446:	0505                	addi	a0,a0,1
    p2++;
 448:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 44a:	fed518e3          	bne	a0,a3,43a <memcmp+0x14>
  }
  return 0;
 44e:	4501                	li	a0,0
 450:	a019                	j	456 <memcmp+0x30>
      return *p1 - *p2;
 452:	40e7853b          	subw	a0,a5,a4
}
 456:	6422                	ld	s0,8(sp)
 458:	0141                	addi	sp,sp,16
 45a:	8082                	ret
  return 0;
 45c:	4501                	li	a0,0
 45e:	bfe5                	j	456 <memcmp+0x30>

0000000000000460 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 460:	1141                	addi	sp,sp,-16
 462:	e406                	sd	ra,8(sp)
 464:	e022                	sd	s0,0(sp)
 466:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 468:	00000097          	auipc	ra,0x0
 46c:	f62080e7          	jalr	-158(ra) # 3ca <memmove>
}
 470:	60a2                	ld	ra,8(sp)
 472:	6402                	ld	s0,0(sp)
 474:	0141                	addi	sp,sp,16
 476:	8082                	ret

0000000000000478 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 478:	4885                	li	a7,1
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <exit>:
.global exit
exit:
 li a7, SYS_exit
 480:	4889                	li	a7,2
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 488:	48e1                	li	a7,24
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <wait>:
.global wait
wait:
 li a7, SYS_wait
 490:	488d                	li	a7,3
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 498:	4891                	li	a7,4
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <read>:
.global read
read:
 li a7, SYS_read
 4a0:	4895                	li	a7,5
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <write>:
.global write
write:
 li a7, SYS_write
 4a8:	48c1                	li	a7,16
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <close>:
.global close
close:
 li a7, SYS_close
 4b0:	48d5                	li	a7,21
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4b8:	4899                	li	a7,6
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4c0:	489d                	li	a7,7
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <open>:
.global open
open:
 li a7, SYS_open
 4c8:	48bd                	li	a7,15
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4d0:	48c5                	li	a7,17
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4d8:	48c9                	li	a7,18
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e0:	48a1                	li	a7,8
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <link>:
.global link
link:
 li a7, SYS_link
 4e8:	48cd                	li	a7,19
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4f0:	48d1                	li	a7,20
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4f8:	48a5                	li	a7,9
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <dup>:
.global dup
dup:
 li a7, SYS_dup
 500:	48a9                	li	a7,10
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 508:	48ad                	li	a7,11
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 510:	48b1                	li	a7,12
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 518:	48b5                	li	a7,13
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 520:	48b9                	li	a7,14
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 528:	48dd                	li	a7,23
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 530:	48e5                	li	a7,25
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 538:	48e9                	li	a7,26
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 540:	48ed                	li	a7,27
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 548:	1101                	addi	sp,sp,-32
 54a:	ec06                	sd	ra,24(sp)
 54c:	e822                	sd	s0,16(sp)
 54e:	1000                	addi	s0,sp,32
 550:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 554:	4605                	li	a2,1
 556:	fef40593          	addi	a1,s0,-17
 55a:	00000097          	auipc	ra,0x0
 55e:	f4e080e7          	jalr	-178(ra) # 4a8 <write>
}
 562:	60e2                	ld	ra,24(sp)
 564:	6442                	ld	s0,16(sp)
 566:	6105                	addi	sp,sp,32
 568:	8082                	ret

000000000000056a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 56a:	7139                	addi	sp,sp,-64
 56c:	fc06                	sd	ra,56(sp)
 56e:	f822                	sd	s0,48(sp)
 570:	f426                	sd	s1,40(sp)
 572:	f04a                	sd	s2,32(sp)
 574:	ec4e                	sd	s3,24(sp)
 576:	0080                	addi	s0,sp,64
 578:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 57a:	c299                	beqz	a3,580 <printint+0x16>
 57c:	0805c863          	bltz	a1,60c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 580:	2581                	sext.w	a1,a1
  neg = 0;
 582:	4881                	li	a7,0
 584:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 588:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 58a:	2601                	sext.w	a2,a2
 58c:	00000517          	auipc	a0,0x0
 590:	58450513          	addi	a0,a0,1412 # b10 <digits>
 594:	883a                	mv	a6,a4
 596:	2705                	addiw	a4,a4,1
 598:	02c5f7bb          	remuw	a5,a1,a2
 59c:	1782                	slli	a5,a5,0x20
 59e:	9381                	srli	a5,a5,0x20
 5a0:	97aa                	add	a5,a5,a0
 5a2:	0007c783          	lbu	a5,0(a5)
 5a6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5aa:	0005879b          	sext.w	a5,a1
 5ae:	02c5d5bb          	divuw	a1,a1,a2
 5b2:	0685                	addi	a3,a3,1
 5b4:	fec7f0e3          	bgeu	a5,a2,594 <printint+0x2a>
  if(neg)
 5b8:	00088b63          	beqz	a7,5ce <printint+0x64>
    buf[i++] = '-';
 5bc:	fd040793          	addi	a5,s0,-48
 5c0:	973e                	add	a4,a4,a5
 5c2:	02d00793          	li	a5,45
 5c6:	fef70823          	sb	a5,-16(a4)
 5ca:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5ce:	02e05863          	blez	a4,5fe <printint+0x94>
 5d2:	fc040793          	addi	a5,s0,-64
 5d6:	00e78933          	add	s2,a5,a4
 5da:	fff78993          	addi	s3,a5,-1
 5de:	99ba                	add	s3,s3,a4
 5e0:	377d                	addiw	a4,a4,-1
 5e2:	1702                	slli	a4,a4,0x20
 5e4:	9301                	srli	a4,a4,0x20
 5e6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5ea:	fff94583          	lbu	a1,-1(s2)
 5ee:	8526                	mv	a0,s1
 5f0:	00000097          	auipc	ra,0x0
 5f4:	f58080e7          	jalr	-168(ra) # 548 <putc>
  while(--i >= 0)
 5f8:	197d                	addi	s2,s2,-1
 5fa:	ff3918e3          	bne	s2,s3,5ea <printint+0x80>
}
 5fe:	70e2                	ld	ra,56(sp)
 600:	7442                	ld	s0,48(sp)
 602:	74a2                	ld	s1,40(sp)
 604:	7902                	ld	s2,32(sp)
 606:	69e2                	ld	s3,24(sp)
 608:	6121                	addi	sp,sp,64
 60a:	8082                	ret
    x = -xx;
 60c:	40b005bb          	negw	a1,a1
    neg = 1;
 610:	4885                	li	a7,1
    x = -xx;
 612:	bf8d                	j	584 <printint+0x1a>

0000000000000614 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 614:	7119                	addi	sp,sp,-128
 616:	fc86                	sd	ra,120(sp)
 618:	f8a2                	sd	s0,112(sp)
 61a:	f4a6                	sd	s1,104(sp)
 61c:	f0ca                	sd	s2,96(sp)
 61e:	ecce                	sd	s3,88(sp)
 620:	e8d2                	sd	s4,80(sp)
 622:	e4d6                	sd	s5,72(sp)
 624:	e0da                	sd	s6,64(sp)
 626:	fc5e                	sd	s7,56(sp)
 628:	f862                	sd	s8,48(sp)
 62a:	f466                	sd	s9,40(sp)
 62c:	f06a                	sd	s10,32(sp)
 62e:	ec6e                	sd	s11,24(sp)
 630:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 632:	0005c903          	lbu	s2,0(a1)
 636:	18090f63          	beqz	s2,7d4 <vprintf+0x1c0>
 63a:	8aaa                	mv	s5,a0
 63c:	8b32                	mv	s6,a2
 63e:	00158493          	addi	s1,a1,1
  state = 0;
 642:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 644:	02500a13          	li	s4,37
      if(c == 'd'){
 648:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 64c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 650:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 654:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 658:	00000b97          	auipc	s7,0x0
 65c:	4b8b8b93          	addi	s7,s7,1208 # b10 <digits>
 660:	a839                	j	67e <vprintf+0x6a>
        putc(fd, c);
 662:	85ca                	mv	a1,s2
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	ee2080e7          	jalr	-286(ra) # 548 <putc>
 66e:	a019                	j	674 <vprintf+0x60>
    } else if(state == '%'){
 670:	01498f63          	beq	s3,s4,68e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 674:	0485                	addi	s1,s1,1
 676:	fff4c903          	lbu	s2,-1(s1)
 67a:	14090d63          	beqz	s2,7d4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 67e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 682:	fe0997e3          	bnez	s3,670 <vprintf+0x5c>
      if(c == '%'){
 686:	fd479ee3          	bne	a5,s4,662 <vprintf+0x4e>
        state = '%';
 68a:	89be                	mv	s3,a5
 68c:	b7e5                	j	674 <vprintf+0x60>
      if(c == 'd'){
 68e:	05878063          	beq	a5,s8,6ce <vprintf+0xba>
      } else if(c == 'l') {
 692:	05978c63          	beq	a5,s9,6ea <vprintf+0xd6>
      } else if(c == 'x') {
 696:	07a78863          	beq	a5,s10,706 <vprintf+0xf2>
      } else if(c == 'p') {
 69a:	09b78463          	beq	a5,s11,722 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 69e:	07300713          	li	a4,115
 6a2:	0ce78663          	beq	a5,a4,76e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6a6:	06300713          	li	a4,99
 6aa:	0ee78e63          	beq	a5,a4,7a6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6ae:	11478863          	beq	a5,s4,7be <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6b2:	85d2                	mv	a1,s4
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e92080e7          	jalr	-366(ra) # 548 <putc>
        putc(fd, c);
 6be:	85ca                	mv	a1,s2
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e86080e7          	jalr	-378(ra) # 548 <putc>
      }
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b765                	j	674 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6ce:	008b0913          	addi	s2,s6,8
 6d2:	4685                	li	a3,1
 6d4:	4629                	li	a2,10
 6d6:	000b2583          	lw	a1,0(s6)
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	e8e080e7          	jalr	-370(ra) # 56a <printint>
 6e4:	8b4a                	mv	s6,s2
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b771                	j	674 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ea:	008b0913          	addi	s2,s6,8
 6ee:	4681                	li	a3,0
 6f0:	4629                	li	a2,10
 6f2:	000b2583          	lw	a1,0(s6)
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	e72080e7          	jalr	-398(ra) # 56a <printint>
 700:	8b4a                	mv	s6,s2
      state = 0;
 702:	4981                	li	s3,0
 704:	bf85                	j	674 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 706:	008b0913          	addi	s2,s6,8
 70a:	4681                	li	a3,0
 70c:	4641                	li	a2,16
 70e:	000b2583          	lw	a1,0(s6)
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e56080e7          	jalr	-426(ra) # 56a <printint>
 71c:	8b4a                	mv	s6,s2
      state = 0;
 71e:	4981                	li	s3,0
 720:	bf91                	j	674 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 722:	008b0793          	addi	a5,s6,8
 726:	f8f43423          	sd	a5,-120(s0)
 72a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 72e:	03000593          	li	a1,48
 732:	8556                	mv	a0,s5
 734:	00000097          	auipc	ra,0x0
 738:	e14080e7          	jalr	-492(ra) # 548 <putc>
  putc(fd, 'x');
 73c:	85ea                	mv	a1,s10
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	e08080e7          	jalr	-504(ra) # 548 <putc>
 748:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 74a:	03c9d793          	srli	a5,s3,0x3c
 74e:	97de                	add	a5,a5,s7
 750:	0007c583          	lbu	a1,0(a5)
 754:	8556                	mv	a0,s5
 756:	00000097          	auipc	ra,0x0
 75a:	df2080e7          	jalr	-526(ra) # 548 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 75e:	0992                	slli	s3,s3,0x4
 760:	397d                	addiw	s2,s2,-1
 762:	fe0914e3          	bnez	s2,74a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 766:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 76a:	4981                	li	s3,0
 76c:	b721                	j	674 <vprintf+0x60>
        s = va_arg(ap, char*);
 76e:	008b0993          	addi	s3,s6,8
 772:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 776:	02090163          	beqz	s2,798 <vprintf+0x184>
        while(*s != 0){
 77a:	00094583          	lbu	a1,0(s2)
 77e:	c9a1                	beqz	a1,7ce <vprintf+0x1ba>
          putc(fd, *s);
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	dc6080e7          	jalr	-570(ra) # 548 <putc>
          s++;
 78a:	0905                	addi	s2,s2,1
        while(*s != 0){
 78c:	00094583          	lbu	a1,0(s2)
 790:	f9e5                	bnez	a1,780 <vprintf+0x16c>
        s = va_arg(ap, char*);
 792:	8b4e                	mv	s6,s3
      state = 0;
 794:	4981                	li	s3,0
 796:	bdf9                	j	674 <vprintf+0x60>
          s = "(null)";
 798:	00000917          	auipc	s2,0x0
 79c:	37090913          	addi	s2,s2,880 # b08 <malloc+0x22a>
        while(*s != 0){
 7a0:	02800593          	li	a1,40
 7a4:	bff1                	j	780 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7a6:	008b0913          	addi	s2,s6,8
 7aa:	000b4583          	lbu	a1,0(s6)
 7ae:	8556                	mv	a0,s5
 7b0:	00000097          	auipc	ra,0x0
 7b4:	d98080e7          	jalr	-616(ra) # 548 <putc>
 7b8:	8b4a                	mv	s6,s2
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	bd65                	j	674 <vprintf+0x60>
        putc(fd, c);
 7be:	85d2                	mv	a1,s4
 7c0:	8556                	mv	a0,s5
 7c2:	00000097          	auipc	ra,0x0
 7c6:	d86080e7          	jalr	-634(ra) # 548 <putc>
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b565                	j	674 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ce:	8b4e                	mv	s6,s3
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	b54d                	j	674 <vprintf+0x60>
    }
  }
}
 7d4:	70e6                	ld	ra,120(sp)
 7d6:	7446                	ld	s0,112(sp)
 7d8:	74a6                	ld	s1,104(sp)
 7da:	7906                	ld	s2,96(sp)
 7dc:	69e6                	ld	s3,88(sp)
 7de:	6a46                	ld	s4,80(sp)
 7e0:	6aa6                	ld	s5,72(sp)
 7e2:	6b06                	ld	s6,64(sp)
 7e4:	7be2                	ld	s7,56(sp)
 7e6:	7c42                	ld	s8,48(sp)
 7e8:	7ca2                	ld	s9,40(sp)
 7ea:	7d02                	ld	s10,32(sp)
 7ec:	6de2                	ld	s11,24(sp)
 7ee:	6109                	addi	sp,sp,128
 7f0:	8082                	ret

00000000000007f2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7f2:	715d                	addi	sp,sp,-80
 7f4:	ec06                	sd	ra,24(sp)
 7f6:	e822                	sd	s0,16(sp)
 7f8:	1000                	addi	s0,sp,32
 7fa:	e010                	sd	a2,0(s0)
 7fc:	e414                	sd	a3,8(s0)
 7fe:	e818                	sd	a4,16(s0)
 800:	ec1c                	sd	a5,24(s0)
 802:	03043023          	sd	a6,32(s0)
 806:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 80a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 80e:	8622                	mv	a2,s0
 810:	00000097          	auipc	ra,0x0
 814:	e04080e7          	jalr	-508(ra) # 614 <vprintf>
}
 818:	60e2                	ld	ra,24(sp)
 81a:	6442                	ld	s0,16(sp)
 81c:	6161                	addi	sp,sp,80
 81e:	8082                	ret

0000000000000820 <printf>:

void
printf(const char *fmt, ...)
{
 820:	711d                	addi	sp,sp,-96
 822:	ec06                	sd	ra,24(sp)
 824:	e822                	sd	s0,16(sp)
 826:	1000                	addi	s0,sp,32
 828:	e40c                	sd	a1,8(s0)
 82a:	e810                	sd	a2,16(s0)
 82c:	ec14                	sd	a3,24(s0)
 82e:	f018                	sd	a4,32(s0)
 830:	f41c                	sd	a5,40(s0)
 832:	03043823          	sd	a6,48(s0)
 836:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 83a:	00840613          	addi	a2,s0,8
 83e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 842:	85aa                	mv	a1,a0
 844:	4505                	li	a0,1
 846:	00000097          	auipc	ra,0x0
 84a:	dce080e7          	jalr	-562(ra) # 614 <vprintf>
}
 84e:	60e2                	ld	ra,24(sp)
 850:	6442                	ld	s0,16(sp)
 852:	6125                	addi	sp,sp,96
 854:	8082                	ret

0000000000000856 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 856:	1141                	addi	sp,sp,-16
 858:	e422                	sd	s0,8(sp)
 85a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 85c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 860:	00000797          	auipc	a5,0x0
 864:	7a07b783          	ld	a5,1952(a5) # 1000 <freep>
 868:	a805                	j	898 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 86a:	4618                	lw	a4,8(a2)
 86c:	9db9                	addw	a1,a1,a4
 86e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 872:	6398                	ld	a4,0(a5)
 874:	6318                	ld	a4,0(a4)
 876:	fee53823          	sd	a4,-16(a0)
 87a:	a091                	j	8be <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 87c:	ff852703          	lw	a4,-8(a0)
 880:	9e39                	addw	a2,a2,a4
 882:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 884:	ff053703          	ld	a4,-16(a0)
 888:	e398                	sd	a4,0(a5)
 88a:	a099                	j	8d0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88c:	6398                	ld	a4,0(a5)
 88e:	00e7e463          	bltu	a5,a4,896 <free+0x40>
 892:	00e6ea63          	bltu	a3,a4,8a6 <free+0x50>
{
 896:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 898:	fed7fae3          	bgeu	a5,a3,88c <free+0x36>
 89c:	6398                	ld	a4,0(a5)
 89e:	00e6e463          	bltu	a3,a4,8a6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a2:	fee7eae3          	bltu	a5,a4,896 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8a6:	ff852583          	lw	a1,-8(a0)
 8aa:	6390                	ld	a2,0(a5)
 8ac:	02059713          	slli	a4,a1,0x20
 8b0:	9301                	srli	a4,a4,0x20
 8b2:	0712                	slli	a4,a4,0x4
 8b4:	9736                	add	a4,a4,a3
 8b6:	fae60ae3          	beq	a2,a4,86a <free+0x14>
    bp->s.ptr = p->s.ptr;
 8ba:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8be:	4790                	lw	a2,8(a5)
 8c0:	02061713          	slli	a4,a2,0x20
 8c4:	9301                	srli	a4,a4,0x20
 8c6:	0712                	slli	a4,a4,0x4
 8c8:	973e                	add	a4,a4,a5
 8ca:	fae689e3          	beq	a3,a4,87c <free+0x26>
  } else
    p->s.ptr = bp;
 8ce:	e394                	sd	a3,0(a5)
  freep = p;
 8d0:	00000717          	auipc	a4,0x0
 8d4:	72f73823          	sd	a5,1840(a4) # 1000 <freep>
}
 8d8:	6422                	ld	s0,8(sp)
 8da:	0141                	addi	sp,sp,16
 8dc:	8082                	ret

00000000000008de <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8de:	7139                	addi	sp,sp,-64
 8e0:	fc06                	sd	ra,56(sp)
 8e2:	f822                	sd	s0,48(sp)
 8e4:	f426                	sd	s1,40(sp)
 8e6:	f04a                	sd	s2,32(sp)
 8e8:	ec4e                	sd	s3,24(sp)
 8ea:	e852                	sd	s4,16(sp)
 8ec:	e456                	sd	s5,8(sp)
 8ee:	e05a                	sd	s6,0(sp)
 8f0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f2:	02051493          	slli	s1,a0,0x20
 8f6:	9081                	srli	s1,s1,0x20
 8f8:	04bd                	addi	s1,s1,15
 8fa:	8091                	srli	s1,s1,0x4
 8fc:	0014899b          	addiw	s3,s1,1
 900:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 902:	00000517          	auipc	a0,0x0
 906:	6fe53503          	ld	a0,1790(a0) # 1000 <freep>
 90a:	c515                	beqz	a0,936 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90e:	4798                	lw	a4,8(a5)
 910:	02977f63          	bgeu	a4,s1,94e <malloc+0x70>
 914:	8a4e                	mv	s4,s3
 916:	0009871b          	sext.w	a4,s3
 91a:	6685                	lui	a3,0x1
 91c:	00d77363          	bgeu	a4,a3,922 <malloc+0x44>
 920:	6a05                	lui	s4,0x1
 922:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 926:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 92a:	00000917          	auipc	s2,0x0
 92e:	6d690913          	addi	s2,s2,1750 # 1000 <freep>
  if(p == (char*)-1)
 932:	5afd                	li	s5,-1
 934:	a88d                	j	9a6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 936:	00000797          	auipc	a5,0x0
 93a:	6da78793          	addi	a5,a5,1754 # 1010 <base>
 93e:	00000717          	auipc	a4,0x0
 942:	6cf73123          	sd	a5,1730(a4) # 1000 <freep>
 946:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 948:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 94c:	b7e1                	j	914 <malloc+0x36>
      if(p->s.size == nunits)
 94e:	02e48b63          	beq	s1,a4,984 <malloc+0xa6>
        p->s.size -= nunits;
 952:	4137073b          	subw	a4,a4,s3
 956:	c798                	sw	a4,8(a5)
        p += p->s.size;
 958:	1702                	slli	a4,a4,0x20
 95a:	9301                	srli	a4,a4,0x20
 95c:	0712                	slli	a4,a4,0x4
 95e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 960:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 964:	00000717          	auipc	a4,0x0
 968:	68a73e23          	sd	a0,1692(a4) # 1000 <freep>
      return (void*)(p + 1);
 96c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 970:	70e2                	ld	ra,56(sp)
 972:	7442                	ld	s0,48(sp)
 974:	74a2                	ld	s1,40(sp)
 976:	7902                	ld	s2,32(sp)
 978:	69e2                	ld	s3,24(sp)
 97a:	6a42                	ld	s4,16(sp)
 97c:	6aa2                	ld	s5,8(sp)
 97e:	6b02                	ld	s6,0(sp)
 980:	6121                	addi	sp,sp,64
 982:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 984:	6398                	ld	a4,0(a5)
 986:	e118                	sd	a4,0(a0)
 988:	bff1                	j	964 <malloc+0x86>
  hp->s.size = nu;
 98a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 98e:	0541                	addi	a0,a0,16
 990:	00000097          	auipc	ra,0x0
 994:	ec6080e7          	jalr	-314(ra) # 856 <free>
  return freep;
 998:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 99c:	d971                	beqz	a0,970 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a0:	4798                	lw	a4,8(a5)
 9a2:	fa9776e3          	bgeu	a4,s1,94e <malloc+0x70>
    if(p == freep)
 9a6:	00093703          	ld	a4,0(s2)
 9aa:	853e                	mv	a0,a5
 9ac:	fef719e3          	bne	a4,a5,99e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9b0:	8552                	mv	a0,s4
 9b2:	00000097          	auipc	ra,0x0
 9b6:	b5e080e7          	jalr	-1186(ra) # 510 <sbrk>
  if(p == (char*)-1)
 9ba:	fd5518e3          	bne	a0,s5,98a <malloc+0xac>
        return 0;
 9be:	4501                	li	a0,0
 9c0:	bf45                	j	970 <malloc+0x92>
