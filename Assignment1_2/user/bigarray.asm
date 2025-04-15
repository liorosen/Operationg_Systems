
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
  16:	9ae50513          	addi	a0,a0,-1618 # 9c0 <malloc+0xf2>
  1a:	00000097          	auipc	ra,0x0
  1e:	7f6080e7          	jalr	2038(ra) # 810 <printf>

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN] ;
  int n = NUM_CHILDREN;
  22:	4791                	li	a5,4
  24:	faf42623          	sw	a5,-84(s0)

  int ret = forkn(NUM_CHILDREN, pids);
  28:	fc040593          	addi	a1,s0,-64
  2c:	4511                	li	a0,4
  2e:	00000097          	auipc	ra,0x0
  32:	4f2080e7          	jalr	1266(ra) # 520 <forkn>

  if (ret == -1) {
  36:	57fd                	li	a5,-1
  38:	0af50163          	beq	a0,a5,da <main+0xda>
  3c:	892a                	mv	s2,a0
    printf("forkn failed\n");
    exit(-1);
  } else if (ret >= 0 && ret < NUM_CHILDREN) {
  3e:	0005079b          	sext.w	a5,a0
  42:	470d                	li	a4,3
  44:	0af76a63          	bltu	a4,a5,f8 <main+0xf8>
    long long start = ret * CHUNK_SIZE;
  48:	00e5169b          	slliw	a3,a0,0xe
  4c:	0006879b          	sext.w	a5,a3
    long long end = (ret + 1) * CHUNK_SIZE;
  50:	6711                	lui	a4,0x4
  52:	9f35                	addw	a4,a4,a3
    long long sum = 0;

    for (long long i = start + 1; i <= end; i++) {
  54:	0785                	addi	a5,a5,1
  56:	08f74f63          	blt	a4,a5,f4 <main+0xf4>
    long long sum = 0;
  5a:	4981                	li	s3,0
      sum += i;
  5c:	99be                	add	s3,s3,a5
    for (long long i = start + 1; i <= end; i++) {
  5e:	0785                	addi	a5,a5,1
  60:	fef75ee3          	bge	a4,a5,5c <main+0x5c>
    }

    for (int i = 0; i < ret; i++) {
  64:	01205f63          	blez	s2,82 <main+0x82>
      sleep(50 * ret);  // let lower-numbered children print first
  68:	03200a13          	li	s4,50
  6c:	032a0a3b          	mulw	s4,s4,s2
    for (int i = 0; i < ret; i++) {
  70:	4481                	li	s1,0
      sleep(50 * ret);  // let lower-numbered children print first
  72:	8552                	mv	a0,s4
  74:	00000097          	auipc	ra,0x0
  78:	494080e7          	jalr	1172(ra) # 508 <sleep>
    for (int i = 0; i < ret; i++) {
  7c:	2485                	addiw	s1,s1,1
  7e:	fe991ae3          	bne	s2,s1,72 <main+0x72>
    }

    //  Use printf directly instead of manual string building
    
    printf("Child %d calculated sum: %d\n", ret, (int)sum);
  82:	0009849b          	sext.w	s1,s3
  86:	8626                	mv	a2,s1
  88:	85ca                	mv	a1,s2
  8a:	00001517          	auipc	a0,0x1
  8e:	96650513          	addi	a0,a0,-1690 # 9f0 <malloc+0x122>
  92:	00000097          	auipc	ra,0x0
  96:	77e080e7          	jalr	1918(ra) # 810 <printf>
    statuses[ret] = (int)sum;
  9a:	00291793          	slli	a5,s2,0x2
  9e:	fd040713          	addi	a4,s0,-48
  a2:	97ba                	add	a5,a5,a4
  a4:	fe97a023          	sw	s1,-32(a5)
    sleep(50 * ret);  // let lower-numbered children print first
  a8:	03200513          	li	a0,50
  ac:	0325053b          	mulw	a0,a0,s2
  b0:	00000097          	auipc	ra,0x0
  b4:	458080e7          	jalr	1112(ra) # 508 <sleep>
    exit_num((int)(sum / CHUNK_SIZE));  // ✅ unique, small, preserves value pattern
  b8:	6511                	lui	a0,0x4
  ba:	02a9c533          	div	a0,s3,a0
  be:	2501                	sext.w	a0,a0
  c0:	00000097          	auipc	ra,0x0
  c4:	470080e7          	jalr	1136(ra) # 530 <exit_num>

    exit(0);
  }

  return 0;
}
  c8:	4501                	li	a0,0
  ca:	60e6                	ld	ra,88(sp)
  cc:	6446                	ld	s0,80(sp)
  ce:	64a6                	ld	s1,72(sp)
  d0:	6906                	ld	s2,64(sp)
  d2:	79e2                	ld	s3,56(sp)
  d4:	7a42                	ld	s4,48(sp)
  d6:	6125                	addi	sp,sp,96
  d8:	8082                	ret
    printf("forkn failed\n");
  da:	00001517          	auipc	a0,0x1
  de:	90650513          	addi	a0,a0,-1786 # 9e0 <malloc+0x112>
  e2:	00000097          	auipc	ra,0x0
  e6:	72e080e7          	jalr	1838(ra) # 810 <printf>
    exit(-1);
  ea:	557d                	li	a0,-1
  ec:	00000097          	auipc	ra,0x0
  f0:	384080e7          	jalr	900(ra) # 470 <exit>
    long long sum = 0;
  f4:	4981                	li	s3,0
  f6:	b7bd                	j	64 <main+0x64>
  } else if (ret == -2) {
  f8:	57f9                	li	a5,-2
  fa:	fcf517e3          	bne	a0,a5,c8 <main+0xc8>
    sleep(100);
  fe:	06400513          	li	a0,100
 102:	00000097          	auipc	ra,0x0
 106:	406080e7          	jalr	1030(ra) # 508 <sleep>
    printf("===> Waiting for children with waitall()\n");
 10a:	00001517          	auipc	a0,0x1
 10e:	90650513          	addi	a0,a0,-1786 # a10 <malloc+0x142>
 112:	00000097          	auipc	ra,0x0
 116:	6fe080e7          	jalr	1790(ra) # 810 <printf>
    if (waitall(&n, statuses) < 0) {
 11a:	fb040593          	addi	a1,s0,-80
 11e:	fac40513          	addi	a0,s0,-84
 122:	00000097          	auipc	ra,0x0
 126:	406080e7          	jalr	1030(ra) # 528 <waitall>
 12a:	00054b63          	bltz	a0,140 <main+0x140>
 12e:	fb040913          	addi	s2,s0,-80
    for (int i = 0; i < n; i++) {
 132:	4481                	li	s1,0
    long long total = 0;
 134:	4981                	li	s3,0
      printf("statuses[%d] = %d\n", i, statuses[i]);
 136:	00001a17          	auipc	s4,0x1
 13a:	91aa0a13          	addi	s4,s4,-1766 # a50 <malloc+0x182>
 13e:	a825                	j	176 <main+0x176>
      printf("waitall failed\n");
 140:	00001517          	auipc	a0,0x1
 144:	90050513          	addi	a0,a0,-1792 # a40 <malloc+0x172>
 148:	00000097          	auipc	ra,0x0
 14c:	6c8080e7          	jalr	1736(ra) # 810 <printf>
      exit(-1);
 150:	557d                	li	a0,-1
 152:	00000097          	auipc	ra,0x0
 156:	31e080e7          	jalr	798(ra) # 470 <exit>
      printf("statuses[%d] = %d\n", i, statuses[i]);
 15a:	00092603          	lw	a2,0(s2)
 15e:	85a6                	mv	a1,s1
 160:	8552                	mv	a0,s4
 162:	00000097          	auipc	ra,0x0
 166:	6ae080e7          	jalr	1710(ra) # 810 <printf>
      total += (long long)statuses[i] * CHUNK_SIZE;
 16a:	00092783          	lw	a5,0(s2)
 16e:	07ba                	slli	a5,a5,0xe
 170:	99be                	add	s3,s3,a5
    for (int i = 0; i < n; i++) {
 172:	2485                	addiw	s1,s1,1
 174:	0911                	addi	s2,s2,4
 176:	fac42583          	lw	a1,-84(s0)
 17a:	feb4c0e3          	blt	s1,a1,15a <main+0x15a>
    printf("===> All %d children finished\n", n);
 17e:	00001517          	auipc	a0,0x1
 182:	8ea50513          	addi	a0,a0,-1814 # a68 <malloc+0x19a>
 186:	00000097          	auipc	ra,0x0
 18a:	68a080e7          	jalr	1674(ra) # 810 <printf>
    printf("Sum of all children's sums: %lld\n", total);
 18e:	85ce                	mv	a1,s3
 190:	00001517          	auipc	a0,0x1
 194:	8f850513          	addi	a0,a0,-1800 # a88 <malloc+0x1ba>
 198:	00000097          	auipc	ra,0x0
 19c:	678080e7          	jalr	1656(ra) # 810 <printf>
    if (total == expected) {
 1a0:	100017b7          	lui	a5,0x10001
 1a4:	078e                	slli	a5,a5,0x3
 1a6:	02f98363          	beq	s3,a5,1cc <main+0x1cc>
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);
 1aa:	10001637          	lui	a2,0x10001
 1ae:	060e                	slli	a2,a2,0x3
 1b0:	85ce                	mv	a1,s3
 1b2:	00001517          	auipc	a0,0x1
 1b6:	91e50513          	addi	a0,a0,-1762 # ad0 <malloc+0x202>
 1ba:	00000097          	auipc	ra,0x0
 1be:	656080e7          	jalr	1622(ra) # 810 <printf>
    exit(0);
 1c2:	4501                	li	a0,0
 1c4:	00000097          	auipc	ra,0x0
 1c8:	2ac080e7          	jalr	684(ra) # 470 <exit>
      printf("Correct total sum: %lld\n", total);
 1cc:	85be                	mv	a1,a5
 1ce:	00001517          	auipc	a0,0x1
 1d2:	8e250513          	addi	a0,a0,-1822 # ab0 <malloc+0x1e2>
 1d6:	00000097          	auipc	ra,0x0
 1da:	63a080e7          	jalr	1594(ra) # 810 <printf>
 1de:	b7d5                	j	1c2 <main+0x1c2>

00000000000001e0 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e406                	sd	ra,8(sp)
 1e4:	e022                	sd	s0,0(sp)
 1e6:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1e8:	00000097          	auipc	ra,0x0
 1ec:	e18080e7          	jalr	-488(ra) # 0 <main>
  exit(0);
 1f0:	4501                	li	a0,0
 1f2:	00000097          	auipc	ra,0x0
 1f6:	27e080e7          	jalr	638(ra) # 470 <exit>

00000000000001fa <strcpy>:
}

char* strcpy(char *s, const char *t)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 200:	87aa                	mv	a5,a0
 202:	0585                	addi	a1,a1,1
 204:	0785                	addi	a5,a5,1
 206:	fff5c703          	lbu	a4,-1(a1)
 20a:	fee78fa3          	sb	a4,-1(a5) # 10000fff <base+0xfffffef>
 20e:	fb75                	bnez	a4,202 <strcpy+0x8>
    ;
  return os;
}
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret

0000000000000216 <strcmp>:

int strcmp(const char *p, const char *q)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 21c:	00054783          	lbu	a5,0(a0)
 220:	cb91                	beqz	a5,234 <strcmp+0x1e>
 222:	0005c703          	lbu	a4,0(a1)
 226:	00f71763          	bne	a4,a5,234 <strcmp+0x1e>
    p++, q++;
 22a:	0505                	addi	a0,a0,1
 22c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 22e:	00054783          	lbu	a5,0(a0)
 232:	fbe5                	bnez	a5,222 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 234:	0005c503          	lbu	a0,0(a1)
}
 238:	40a7853b          	subw	a0,a5,a0
 23c:	6422                	ld	s0,8(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret

0000000000000242 <strlen>:

uint strlen(const char *s)
{
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 248:	00054783          	lbu	a5,0(a0)
 24c:	cf91                	beqz	a5,268 <strlen+0x26>
 24e:	0505                	addi	a0,a0,1
 250:	87aa                	mv	a5,a0
 252:	4685                	li	a3,1
 254:	9e89                	subw	a3,a3,a0
 256:	00f6853b          	addw	a0,a3,a5
 25a:	0785                	addi	a5,a5,1
 25c:	fff7c703          	lbu	a4,-1(a5)
 260:	fb7d                	bnez	a4,256 <strlen+0x14>
    ;
  return n;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  for(n = 0; s[n]; n++)
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <strlen+0x20>

000000000000026c <memset>:

void* memset(void *dst, int c, uint n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 272:	ce09                	beqz	a2,28c <memset+0x20>
 274:	87aa                	mv	a5,a0
 276:	fff6071b          	addiw	a4,a2,-1
 27a:	1702                	slli	a4,a4,0x20
 27c:	9301                	srli	a4,a4,0x20
 27e:	0705                	addi	a4,a4,1
 280:	972a                	add	a4,a4,a0
    cdst[i] = c;
 282:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 286:	0785                	addi	a5,a5,1
 288:	fee79de3          	bne	a5,a4,282 <memset+0x16>
  }
  return dst;
}
 28c:	6422                	ld	s0,8(sp)
 28e:	0141                	addi	sp,sp,16
 290:	8082                	ret

0000000000000292 <strchr>:

char* strchr(const char *s, char c)
{
 292:	1141                	addi	sp,sp,-16
 294:	e422                	sd	s0,8(sp)
 296:	0800                	addi	s0,sp,16
  for(; *s; s++)
 298:	00054783          	lbu	a5,0(a0)
 29c:	cb99                	beqz	a5,2b2 <strchr+0x20>
    if(*s == c)
 29e:	00f58763          	beq	a1,a5,2ac <strchr+0x1a>
  for(; *s; s++)
 2a2:	0505                	addi	a0,a0,1
 2a4:	00054783          	lbu	a5,0(a0)
 2a8:	fbfd                	bnez	a5,29e <strchr+0xc>
      return (char*)s;
  return 0;
 2aa:	4501                	li	a0,0
}
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret
  return 0;
 2b2:	4501                	li	a0,0
 2b4:	bfe5                	j	2ac <strchr+0x1a>

00000000000002b6 <gets>:

char* gets(char *buf, int max)
{
 2b6:	711d                	addi	sp,sp,-96
 2b8:	ec86                	sd	ra,88(sp)
 2ba:	e8a2                	sd	s0,80(sp)
 2bc:	e4a6                	sd	s1,72(sp)
 2be:	e0ca                	sd	s2,64(sp)
 2c0:	fc4e                	sd	s3,56(sp)
 2c2:	f852                	sd	s4,48(sp)
 2c4:	f456                	sd	s5,40(sp)
 2c6:	f05a                	sd	s6,32(sp)
 2c8:	ec5e                	sd	s7,24(sp)
 2ca:	1080                	addi	s0,sp,96
 2cc:	8baa                	mv	s7,a0
 2ce:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d0:	892a                	mv	s2,a0
 2d2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2d4:	4aa9                	li	s5,10
 2d6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2d8:	89a6                	mv	s3,s1
 2da:	2485                	addiw	s1,s1,1
 2dc:	0344d863          	bge	s1,s4,30c <gets+0x56>
    cc = read(0, &c, 1);
 2e0:	4605                	li	a2,1
 2e2:	faf40593          	addi	a1,s0,-81
 2e6:	4501                	li	a0,0
 2e8:	00000097          	auipc	ra,0x0
 2ec:	1a8080e7          	jalr	424(ra) # 490 <read>
    if(cc < 1)
 2f0:	00a05e63          	blez	a0,30c <gets+0x56>
    buf[i++] = c;
 2f4:	faf44783          	lbu	a5,-81(s0)
 2f8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2fc:	01578763          	beq	a5,s5,30a <gets+0x54>
 300:	0905                	addi	s2,s2,1
 302:	fd679be3          	bne	a5,s6,2d8 <gets+0x22>
  for(i=0; i+1 < max; ){
 306:	89a6                	mv	s3,s1
 308:	a011                	j	30c <gets+0x56>
 30a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 30c:	99de                	add	s3,s3,s7
 30e:	00098023          	sb	zero,0(s3)
  return buf;
}
 312:	855e                	mv	a0,s7
 314:	60e6                	ld	ra,88(sp)
 316:	6446                	ld	s0,80(sp)
 318:	64a6                	ld	s1,72(sp)
 31a:	6906                	ld	s2,64(sp)
 31c:	79e2                	ld	s3,56(sp)
 31e:	7a42                	ld	s4,48(sp)
 320:	7aa2                	ld	s5,40(sp)
 322:	7b02                	ld	s6,32(sp)
 324:	6be2                	ld	s7,24(sp)
 326:	6125                	addi	sp,sp,96
 328:	8082                	ret

000000000000032a <stat>:

int stat(const char *n, struct stat *st)
{
 32a:	1101                	addi	sp,sp,-32
 32c:	ec06                	sd	ra,24(sp)
 32e:	e822                	sd	s0,16(sp)
 330:	e426                	sd	s1,8(sp)
 332:	e04a                	sd	s2,0(sp)
 334:	1000                	addi	s0,sp,32
 336:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 338:	4581                	li	a1,0
 33a:	00000097          	auipc	ra,0x0
 33e:	17e080e7          	jalr	382(ra) # 4b8 <open>
  if(fd < 0)
 342:	02054563          	bltz	a0,36c <stat+0x42>
 346:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 348:	85ca                	mv	a1,s2
 34a:	00000097          	auipc	ra,0x0
 34e:	186080e7          	jalr	390(ra) # 4d0 <fstat>
 352:	892a                	mv	s2,a0
  close(fd);
 354:	8526                	mv	a0,s1
 356:	00000097          	auipc	ra,0x0
 35a:	14a080e7          	jalr	330(ra) # 4a0 <close>
  return r;
}
 35e:	854a                	mv	a0,s2
 360:	60e2                	ld	ra,24(sp)
 362:	6442                	ld	s0,16(sp)
 364:	64a2                	ld	s1,8(sp)
 366:	6902                	ld	s2,0(sp)
 368:	6105                	addi	sp,sp,32
 36a:	8082                	ret
    return -1;
 36c:	597d                	li	s2,-1
 36e:	bfc5                	j	35e <stat+0x34>

0000000000000370 <atoi>:

int atoi(const char *s)
{
 370:	1141                	addi	sp,sp,-16
 372:	e422                	sd	s0,8(sp)
 374:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 376:	00054603          	lbu	a2,0(a0)
 37a:	fd06079b          	addiw	a5,a2,-48
 37e:	0ff7f793          	andi	a5,a5,255
 382:	4725                	li	a4,9
 384:	02f76963          	bltu	a4,a5,3b6 <atoi+0x46>
 388:	86aa                	mv	a3,a0
  n = 0;
 38a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 38c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 38e:	0685                	addi	a3,a3,1
 390:	0025179b          	slliw	a5,a0,0x2
 394:	9fa9                	addw	a5,a5,a0
 396:	0017979b          	slliw	a5,a5,0x1
 39a:	9fb1                	addw	a5,a5,a2
 39c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3a0:	0006c603          	lbu	a2,0(a3)
 3a4:	fd06071b          	addiw	a4,a2,-48
 3a8:	0ff77713          	andi	a4,a4,255
 3ac:	fee5f1e3          	bgeu	a1,a4,38e <atoi+0x1e>
  return n;
}
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret
  n = 0;
 3b6:	4501                	li	a0,0
 3b8:	bfe5                	j	3b0 <atoi+0x40>

00000000000003ba <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e422                	sd	s0,8(sp)
 3be:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3c0:	02b57663          	bgeu	a0,a1,3ec <memmove+0x32>
    while(n-- > 0)
 3c4:	02c05163          	blez	a2,3e6 <memmove+0x2c>
 3c8:	fff6079b          	addiw	a5,a2,-1
 3cc:	1782                	slli	a5,a5,0x20
 3ce:	9381                	srli	a5,a5,0x20
 3d0:	0785                	addi	a5,a5,1
 3d2:	97aa                	add	a5,a5,a0
  dst = vdst;
 3d4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3d6:	0585                	addi	a1,a1,1
 3d8:	0705                	addi	a4,a4,1
 3da:	fff5c683          	lbu	a3,-1(a1)
 3de:	fed70fa3          	sb	a3,-1(a4) # 3fff <base+0x2fef>
    while(n-- > 0)
 3e2:	fee79ae3          	bne	a5,a4,3d6 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3e6:	6422                	ld	s0,8(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret
    dst += n;
 3ec:	00c50733          	add	a4,a0,a2
    src += n;
 3f0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3f2:	fec05ae3          	blez	a2,3e6 <memmove+0x2c>
 3f6:	fff6079b          	addiw	a5,a2,-1
 3fa:	1782                	slli	a5,a5,0x20
 3fc:	9381                	srli	a5,a5,0x20
 3fe:	fff7c793          	not	a5,a5
 402:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 404:	15fd                	addi	a1,a1,-1
 406:	177d                	addi	a4,a4,-1
 408:	0005c683          	lbu	a3,0(a1)
 40c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 410:	fee79ae3          	bne	a5,a4,404 <memmove+0x4a>
 414:	bfc9                	j	3e6 <memmove+0x2c>

0000000000000416 <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 416:	1141                	addi	sp,sp,-16
 418:	e422                	sd	s0,8(sp)
 41a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 41c:	ca05                	beqz	a2,44c <memcmp+0x36>
 41e:	fff6069b          	addiw	a3,a2,-1
 422:	1682                	slli	a3,a3,0x20
 424:	9281                	srli	a3,a3,0x20
 426:	0685                	addi	a3,a3,1
 428:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 42a:	00054783          	lbu	a5,0(a0)
 42e:	0005c703          	lbu	a4,0(a1)
 432:	00e79863          	bne	a5,a4,442 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 436:	0505                	addi	a0,a0,1
    p2++;
 438:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 43a:	fed518e3          	bne	a0,a3,42a <memcmp+0x14>
  }
  return 0;
 43e:	4501                	li	a0,0
 440:	a019                	j	446 <memcmp+0x30>
      return *p1 - *p2;
 442:	40e7853b          	subw	a0,a5,a4
}
 446:	6422                	ld	s0,8(sp)
 448:	0141                	addi	sp,sp,16
 44a:	8082                	ret
  return 0;
 44c:	4501                	li	a0,0
 44e:	bfe5                	j	446 <memcmp+0x30>

0000000000000450 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 450:	1141                	addi	sp,sp,-16
 452:	e406                	sd	ra,8(sp)
 454:	e022                	sd	s0,0(sp)
 456:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 458:	00000097          	auipc	ra,0x0
 45c:	f62080e7          	jalr	-158(ra) # 3ba <memmove>
}
 460:	60a2                	ld	ra,8(sp)
 462:	6402                	ld	s0,0(sp)
 464:	0141                	addi	sp,sp,16
 466:	8082                	ret

0000000000000468 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 468:	4885                	li	a7,1
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <exit>:
.global exit
exit:
 li a7, SYS_exit
 470:	4889                	li	a7,2
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 478:	48e1                	li	a7,24
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <wait>:
.global wait
wait:
 li a7, SYS_wait
 480:	488d                	li	a7,3
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 488:	4891                	li	a7,4
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <read>:
.global read
read:
 li a7, SYS_read
 490:	4895                	li	a7,5
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <write>:
.global write
write:
 li a7, SYS_write
 498:	48c1                	li	a7,16
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <close>:
.global close
close:
 li a7, SYS_close
 4a0:	48d5                	li	a7,21
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a8:	4899                	li	a7,6
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4b0:	489d                	li	a7,7
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <open>:
.global open
open:
 li a7, SYS_open
 4b8:	48bd                	li	a7,15
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4c0:	48c5                	li	a7,17
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c8:	48c9                	li	a7,18
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4d0:	48a1                	li	a7,8
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <link>:
.global link
link:
 li a7, SYS_link
 4d8:	48cd                	li	a7,19
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4e0:	48d1                	li	a7,20
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e8:	48a5                	li	a7,9
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4f0:	48a9                	li	a7,10
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f8:	48ad                	li	a7,11
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 500:	48b1                	li	a7,12
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 508:	48b5                	li	a7,13
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 510:	48b9                	li	a7,14
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 518:	48dd                	li	a7,23
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 520:	48e5                	li	a7,25
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 528:	48e9                	li	a7,26
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 530:	48ed                	li	a7,27
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 538:	1101                	addi	sp,sp,-32
 53a:	ec06                	sd	ra,24(sp)
 53c:	e822                	sd	s0,16(sp)
 53e:	1000                	addi	s0,sp,32
 540:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 544:	4605                	li	a2,1
 546:	fef40593          	addi	a1,s0,-17
 54a:	00000097          	auipc	ra,0x0
 54e:	f4e080e7          	jalr	-178(ra) # 498 <write>
}
 552:	60e2                	ld	ra,24(sp)
 554:	6442                	ld	s0,16(sp)
 556:	6105                	addi	sp,sp,32
 558:	8082                	ret

000000000000055a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 55a:	7139                	addi	sp,sp,-64
 55c:	fc06                	sd	ra,56(sp)
 55e:	f822                	sd	s0,48(sp)
 560:	f426                	sd	s1,40(sp)
 562:	f04a                	sd	s2,32(sp)
 564:	ec4e                	sd	s3,24(sp)
 566:	0080                	addi	s0,sp,64
 568:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 56a:	c299                	beqz	a3,570 <printint+0x16>
 56c:	0805c863          	bltz	a1,5fc <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 570:	2581                	sext.w	a1,a1
  neg = 0;
 572:	4881                	li	a7,0
 574:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 578:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 57a:	2601                	sext.w	a2,a2
 57c:	00000517          	auipc	a0,0x0
 580:	58450513          	addi	a0,a0,1412 # b00 <digits>
 584:	883a                	mv	a6,a4
 586:	2705                	addiw	a4,a4,1
 588:	02c5f7bb          	remuw	a5,a1,a2
 58c:	1782                	slli	a5,a5,0x20
 58e:	9381                	srli	a5,a5,0x20
 590:	97aa                	add	a5,a5,a0
 592:	0007c783          	lbu	a5,0(a5)
 596:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 59a:	0005879b          	sext.w	a5,a1
 59e:	02c5d5bb          	divuw	a1,a1,a2
 5a2:	0685                	addi	a3,a3,1
 5a4:	fec7f0e3          	bgeu	a5,a2,584 <printint+0x2a>
  if(neg)
 5a8:	00088b63          	beqz	a7,5be <printint+0x64>
    buf[i++] = '-';
 5ac:	fd040793          	addi	a5,s0,-48
 5b0:	973e                	add	a4,a4,a5
 5b2:	02d00793          	li	a5,45
 5b6:	fef70823          	sb	a5,-16(a4)
 5ba:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5be:	02e05863          	blez	a4,5ee <printint+0x94>
 5c2:	fc040793          	addi	a5,s0,-64
 5c6:	00e78933          	add	s2,a5,a4
 5ca:	fff78993          	addi	s3,a5,-1
 5ce:	99ba                	add	s3,s3,a4
 5d0:	377d                	addiw	a4,a4,-1
 5d2:	1702                	slli	a4,a4,0x20
 5d4:	9301                	srli	a4,a4,0x20
 5d6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5da:	fff94583          	lbu	a1,-1(s2)
 5de:	8526                	mv	a0,s1
 5e0:	00000097          	auipc	ra,0x0
 5e4:	f58080e7          	jalr	-168(ra) # 538 <putc>
  while(--i >= 0)
 5e8:	197d                	addi	s2,s2,-1
 5ea:	ff3918e3          	bne	s2,s3,5da <printint+0x80>
}
 5ee:	70e2                	ld	ra,56(sp)
 5f0:	7442                	ld	s0,48(sp)
 5f2:	74a2                	ld	s1,40(sp)
 5f4:	7902                	ld	s2,32(sp)
 5f6:	69e2                	ld	s3,24(sp)
 5f8:	6121                	addi	sp,sp,64
 5fa:	8082                	ret
    x = -xx;
 5fc:	40b005bb          	negw	a1,a1
    neg = 1;
 600:	4885                	li	a7,1
    x = -xx;
 602:	bf8d                	j	574 <printint+0x1a>

0000000000000604 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 604:	7119                	addi	sp,sp,-128
 606:	fc86                	sd	ra,120(sp)
 608:	f8a2                	sd	s0,112(sp)
 60a:	f4a6                	sd	s1,104(sp)
 60c:	f0ca                	sd	s2,96(sp)
 60e:	ecce                	sd	s3,88(sp)
 610:	e8d2                	sd	s4,80(sp)
 612:	e4d6                	sd	s5,72(sp)
 614:	e0da                	sd	s6,64(sp)
 616:	fc5e                	sd	s7,56(sp)
 618:	f862                	sd	s8,48(sp)
 61a:	f466                	sd	s9,40(sp)
 61c:	f06a                	sd	s10,32(sp)
 61e:	ec6e                	sd	s11,24(sp)
 620:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 622:	0005c903          	lbu	s2,0(a1)
 626:	18090f63          	beqz	s2,7c4 <vprintf+0x1c0>
 62a:	8aaa                	mv	s5,a0
 62c:	8b32                	mv	s6,a2
 62e:	00158493          	addi	s1,a1,1
  state = 0;
 632:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 634:	02500a13          	li	s4,37
      if(c == 'd'){
 638:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 63c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 640:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 644:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 648:	00000b97          	auipc	s7,0x0
 64c:	4b8b8b93          	addi	s7,s7,1208 # b00 <digits>
 650:	a839                	j	66e <vprintf+0x6a>
        putc(fd, c);
 652:	85ca                	mv	a1,s2
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	ee2080e7          	jalr	-286(ra) # 538 <putc>
 65e:	a019                	j	664 <vprintf+0x60>
    } else if(state == '%'){
 660:	01498f63          	beq	s3,s4,67e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 664:	0485                	addi	s1,s1,1
 666:	fff4c903          	lbu	s2,-1(s1)
 66a:	14090d63          	beqz	s2,7c4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 66e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 672:	fe0997e3          	bnez	s3,660 <vprintf+0x5c>
      if(c == '%'){
 676:	fd479ee3          	bne	a5,s4,652 <vprintf+0x4e>
        state = '%';
 67a:	89be                	mv	s3,a5
 67c:	b7e5                	j	664 <vprintf+0x60>
      if(c == 'd'){
 67e:	05878063          	beq	a5,s8,6be <vprintf+0xba>
      } else if(c == 'l') {
 682:	05978c63          	beq	a5,s9,6da <vprintf+0xd6>
      } else if(c == 'x') {
 686:	07a78863          	beq	a5,s10,6f6 <vprintf+0xf2>
      } else if(c == 'p') {
 68a:	09b78463          	beq	a5,s11,712 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 68e:	07300713          	li	a4,115
 692:	0ce78663          	beq	a5,a4,75e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 696:	06300713          	li	a4,99
 69a:	0ee78e63          	beq	a5,a4,796 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 69e:	11478863          	beq	a5,s4,7ae <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6a2:	85d2                	mv	a1,s4
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e92080e7          	jalr	-366(ra) # 538 <putc>
        putc(fd, c);
 6ae:	85ca                	mv	a1,s2
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	e86080e7          	jalr	-378(ra) # 538 <putc>
      }
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b765                	j	664 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6be:	008b0913          	addi	s2,s6,8
 6c2:	4685                	li	a3,1
 6c4:	4629                	li	a2,10
 6c6:	000b2583          	lw	a1,0(s6)
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	e8e080e7          	jalr	-370(ra) # 55a <printint>
 6d4:	8b4a                	mv	s6,s2
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	b771                	j	664 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6da:	008b0913          	addi	s2,s6,8
 6de:	4681                	li	a3,0
 6e0:	4629                	li	a2,10
 6e2:	000b2583          	lw	a1,0(s6)
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	e72080e7          	jalr	-398(ra) # 55a <printint>
 6f0:	8b4a                	mv	s6,s2
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	bf85                	j	664 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6f6:	008b0913          	addi	s2,s6,8
 6fa:	4681                	li	a3,0
 6fc:	4641                	li	a2,16
 6fe:	000b2583          	lw	a1,0(s6)
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	e56080e7          	jalr	-426(ra) # 55a <printint>
 70c:	8b4a                	mv	s6,s2
      state = 0;
 70e:	4981                	li	s3,0
 710:	bf91                	j	664 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 712:	008b0793          	addi	a5,s6,8
 716:	f8f43423          	sd	a5,-120(s0)
 71a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 71e:	03000593          	li	a1,48
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	e14080e7          	jalr	-492(ra) # 538 <putc>
  putc(fd, 'x');
 72c:	85ea                	mv	a1,s10
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	e08080e7          	jalr	-504(ra) # 538 <putc>
 738:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 73a:	03c9d793          	srli	a5,s3,0x3c
 73e:	97de                	add	a5,a5,s7
 740:	0007c583          	lbu	a1,0(a5)
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	df2080e7          	jalr	-526(ra) # 538 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 74e:	0992                	slli	s3,s3,0x4
 750:	397d                	addiw	s2,s2,-1
 752:	fe0914e3          	bnez	s2,73a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 756:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 75a:	4981                	li	s3,0
 75c:	b721                	j	664 <vprintf+0x60>
        s = va_arg(ap, char*);
 75e:	008b0993          	addi	s3,s6,8
 762:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 766:	02090163          	beqz	s2,788 <vprintf+0x184>
        while(*s != 0){
 76a:	00094583          	lbu	a1,0(s2)
 76e:	c9a1                	beqz	a1,7be <vprintf+0x1ba>
          putc(fd, *s);
 770:	8556                	mv	a0,s5
 772:	00000097          	auipc	ra,0x0
 776:	dc6080e7          	jalr	-570(ra) # 538 <putc>
          s++;
 77a:	0905                	addi	s2,s2,1
        while(*s != 0){
 77c:	00094583          	lbu	a1,0(s2)
 780:	f9e5                	bnez	a1,770 <vprintf+0x16c>
        s = va_arg(ap, char*);
 782:	8b4e                	mv	s6,s3
      state = 0;
 784:	4981                	li	s3,0
 786:	bdf9                	j	664 <vprintf+0x60>
          s = "(null)";
 788:	00000917          	auipc	s2,0x0
 78c:	37090913          	addi	s2,s2,880 # af8 <malloc+0x22a>
        while(*s != 0){
 790:	02800593          	li	a1,40
 794:	bff1                	j	770 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 796:	008b0913          	addi	s2,s6,8
 79a:	000b4583          	lbu	a1,0(s6)
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	d98080e7          	jalr	-616(ra) # 538 <putc>
 7a8:	8b4a                	mv	s6,s2
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	bd65                	j	664 <vprintf+0x60>
        putc(fd, c);
 7ae:	85d2                	mv	a1,s4
 7b0:	8556                	mv	a0,s5
 7b2:	00000097          	auipc	ra,0x0
 7b6:	d86080e7          	jalr	-634(ra) # 538 <putc>
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	b565                	j	664 <vprintf+0x60>
        s = va_arg(ap, char*);
 7be:	8b4e                	mv	s6,s3
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	b54d                	j	664 <vprintf+0x60>
    }
  }
}
 7c4:	70e6                	ld	ra,120(sp)
 7c6:	7446                	ld	s0,112(sp)
 7c8:	74a6                	ld	s1,104(sp)
 7ca:	7906                	ld	s2,96(sp)
 7cc:	69e6                	ld	s3,88(sp)
 7ce:	6a46                	ld	s4,80(sp)
 7d0:	6aa6                	ld	s5,72(sp)
 7d2:	6b06                	ld	s6,64(sp)
 7d4:	7be2                	ld	s7,56(sp)
 7d6:	7c42                	ld	s8,48(sp)
 7d8:	7ca2                	ld	s9,40(sp)
 7da:	7d02                	ld	s10,32(sp)
 7dc:	6de2                	ld	s11,24(sp)
 7de:	6109                	addi	sp,sp,128
 7e0:	8082                	ret

00000000000007e2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7e2:	715d                	addi	sp,sp,-80
 7e4:	ec06                	sd	ra,24(sp)
 7e6:	e822                	sd	s0,16(sp)
 7e8:	1000                	addi	s0,sp,32
 7ea:	e010                	sd	a2,0(s0)
 7ec:	e414                	sd	a3,8(s0)
 7ee:	e818                	sd	a4,16(s0)
 7f0:	ec1c                	sd	a5,24(s0)
 7f2:	03043023          	sd	a6,32(s0)
 7f6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7fa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7fe:	8622                	mv	a2,s0
 800:	00000097          	auipc	ra,0x0
 804:	e04080e7          	jalr	-508(ra) # 604 <vprintf>
}
 808:	60e2                	ld	ra,24(sp)
 80a:	6442                	ld	s0,16(sp)
 80c:	6161                	addi	sp,sp,80
 80e:	8082                	ret

0000000000000810 <printf>:

void
printf(const char *fmt, ...)
{
 810:	711d                	addi	sp,sp,-96
 812:	ec06                	sd	ra,24(sp)
 814:	e822                	sd	s0,16(sp)
 816:	1000                	addi	s0,sp,32
 818:	e40c                	sd	a1,8(s0)
 81a:	e810                	sd	a2,16(s0)
 81c:	ec14                	sd	a3,24(s0)
 81e:	f018                	sd	a4,32(s0)
 820:	f41c                	sd	a5,40(s0)
 822:	03043823          	sd	a6,48(s0)
 826:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 82a:	00840613          	addi	a2,s0,8
 82e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 832:	85aa                	mv	a1,a0
 834:	4505                	li	a0,1
 836:	00000097          	auipc	ra,0x0
 83a:	dce080e7          	jalr	-562(ra) # 604 <vprintf>
}
 83e:	60e2                	ld	ra,24(sp)
 840:	6442                	ld	s0,16(sp)
 842:	6125                	addi	sp,sp,96
 844:	8082                	ret

0000000000000846 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 846:	1141                	addi	sp,sp,-16
 848:	e422                	sd	s0,8(sp)
 84a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 84c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 850:	00000797          	auipc	a5,0x0
 854:	7b07b783          	ld	a5,1968(a5) # 1000 <freep>
 858:	a805                	j	888 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 85a:	4618                	lw	a4,8(a2)
 85c:	9db9                	addw	a1,a1,a4
 85e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 862:	6398                	ld	a4,0(a5)
 864:	6318                	ld	a4,0(a4)
 866:	fee53823          	sd	a4,-16(a0)
 86a:	a091                	j	8ae <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 86c:	ff852703          	lw	a4,-8(a0)
 870:	9e39                	addw	a2,a2,a4
 872:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 874:	ff053703          	ld	a4,-16(a0)
 878:	e398                	sd	a4,0(a5)
 87a:	a099                	j	8c0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87c:	6398                	ld	a4,0(a5)
 87e:	00e7e463          	bltu	a5,a4,886 <free+0x40>
 882:	00e6ea63          	bltu	a3,a4,896 <free+0x50>
{
 886:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 888:	fed7fae3          	bgeu	a5,a3,87c <free+0x36>
 88c:	6398                	ld	a4,0(a5)
 88e:	00e6e463          	bltu	a3,a4,896 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 892:	fee7eae3          	bltu	a5,a4,886 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 896:	ff852583          	lw	a1,-8(a0)
 89a:	6390                	ld	a2,0(a5)
 89c:	02059713          	slli	a4,a1,0x20
 8a0:	9301                	srli	a4,a4,0x20
 8a2:	0712                	slli	a4,a4,0x4
 8a4:	9736                	add	a4,a4,a3
 8a6:	fae60ae3          	beq	a2,a4,85a <free+0x14>
    bp->s.ptr = p->s.ptr;
 8aa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ae:	4790                	lw	a2,8(a5)
 8b0:	02061713          	slli	a4,a2,0x20
 8b4:	9301                	srli	a4,a4,0x20
 8b6:	0712                	slli	a4,a4,0x4
 8b8:	973e                	add	a4,a4,a5
 8ba:	fae689e3          	beq	a3,a4,86c <free+0x26>
  } else
    p->s.ptr = bp;
 8be:	e394                	sd	a3,0(a5)
  freep = p;
 8c0:	00000717          	auipc	a4,0x0
 8c4:	74f73023          	sd	a5,1856(a4) # 1000 <freep>
}
 8c8:	6422                	ld	s0,8(sp)
 8ca:	0141                	addi	sp,sp,16
 8cc:	8082                	ret

00000000000008ce <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ce:	7139                	addi	sp,sp,-64
 8d0:	fc06                	sd	ra,56(sp)
 8d2:	f822                	sd	s0,48(sp)
 8d4:	f426                	sd	s1,40(sp)
 8d6:	f04a                	sd	s2,32(sp)
 8d8:	ec4e                	sd	s3,24(sp)
 8da:	e852                	sd	s4,16(sp)
 8dc:	e456                	sd	s5,8(sp)
 8de:	e05a                	sd	s6,0(sp)
 8e0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e2:	02051493          	slli	s1,a0,0x20
 8e6:	9081                	srli	s1,s1,0x20
 8e8:	04bd                	addi	s1,s1,15
 8ea:	8091                	srli	s1,s1,0x4
 8ec:	0014899b          	addiw	s3,s1,1
 8f0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8f2:	00000517          	auipc	a0,0x0
 8f6:	70e53503          	ld	a0,1806(a0) # 1000 <freep>
 8fa:	c515                	beqz	a0,926 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8fe:	4798                	lw	a4,8(a5)
 900:	02977f63          	bgeu	a4,s1,93e <malloc+0x70>
 904:	8a4e                	mv	s4,s3
 906:	0009871b          	sext.w	a4,s3
 90a:	6685                	lui	a3,0x1
 90c:	00d77363          	bgeu	a4,a3,912 <malloc+0x44>
 910:	6a05                	lui	s4,0x1
 912:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 916:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 91a:	00000917          	auipc	s2,0x0
 91e:	6e690913          	addi	s2,s2,1766 # 1000 <freep>
  if(p == (char*)-1)
 922:	5afd                	li	s5,-1
 924:	a88d                	j	996 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 926:	00000797          	auipc	a5,0x0
 92a:	6ea78793          	addi	a5,a5,1770 # 1010 <base>
 92e:	00000717          	auipc	a4,0x0
 932:	6cf73923          	sd	a5,1746(a4) # 1000 <freep>
 936:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 938:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 93c:	b7e1                	j	904 <malloc+0x36>
      if(p->s.size == nunits)
 93e:	02e48b63          	beq	s1,a4,974 <malloc+0xa6>
        p->s.size -= nunits;
 942:	4137073b          	subw	a4,a4,s3
 946:	c798                	sw	a4,8(a5)
        p += p->s.size;
 948:	1702                	slli	a4,a4,0x20
 94a:	9301                	srli	a4,a4,0x20
 94c:	0712                	slli	a4,a4,0x4
 94e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 950:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 954:	00000717          	auipc	a4,0x0
 958:	6aa73623          	sd	a0,1708(a4) # 1000 <freep>
      return (void*)(p + 1);
 95c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 960:	70e2                	ld	ra,56(sp)
 962:	7442                	ld	s0,48(sp)
 964:	74a2                	ld	s1,40(sp)
 966:	7902                	ld	s2,32(sp)
 968:	69e2                	ld	s3,24(sp)
 96a:	6a42                	ld	s4,16(sp)
 96c:	6aa2                	ld	s5,8(sp)
 96e:	6b02                	ld	s6,0(sp)
 970:	6121                	addi	sp,sp,64
 972:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 974:	6398                	ld	a4,0(a5)
 976:	e118                	sd	a4,0(a0)
 978:	bff1                	j	954 <malloc+0x86>
  hp->s.size = nu;
 97a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 97e:	0541                	addi	a0,a0,16
 980:	00000097          	auipc	ra,0x0
 984:	ec6080e7          	jalr	-314(ra) # 846 <free>
  return freep;
 988:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 98c:	d971                	beqz	a0,960 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 990:	4798                	lw	a4,8(a5)
 992:	fa9776e3          	bgeu	a4,s1,93e <malloc+0x70>
    if(p == freep)
 996:	00093703          	ld	a4,0(s2)
 99a:	853e                	mv	a0,a5
 99c:	fef719e3          	bne	a4,a5,98e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9a0:	8552                	mv	a0,s4
 9a2:	00000097          	auipc	ra,0x0
 9a6:	b5e080e7          	jalr	-1186(ra) # 500 <sbrk>
  if(p == (char*)-1)
 9aa:	fd5518e3          	bne	a0,s5,97a <malloc+0xac>
        return 0;
 9ae:	4501                	li	a0,0
 9b0:	bf45                	j	960 <malloc+0x92>
