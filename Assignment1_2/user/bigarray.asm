
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
  16:	99e50513          	addi	a0,a0,-1634 # 9b0 <malloc+0xf2>
  1a:	00000097          	auipc	ra,0x0
  1e:	7e6080e7          	jalr	2022(ra) # 800 <printf>

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN] ;
  int n = NUM_CHILDREN;
  22:	4791                	li	a5,4
  24:	faf42623          	sw	a5,-84(s0)

  int ret = forkn(NUM_CHILDREN, pids);
  28:	fc040593          	addi	a1,s0,-64
  2c:	4511                	li	a0,4
  2e:	00000097          	auipc	ra,0x0
  32:	4e2080e7          	jalr	1250(ra) # 510 <forkn>

  if (ret == -1) {
  36:	57fd                	li	a5,-1
  38:	08f50b63          	beq	a0,a5,ce <main+0xce>
  3c:	892a                	mv	s2,a0
    printf("forkn failed\n");
    exit(-1);
  } else if (ret >= 0 && ret < NUM_CHILDREN) {
  3e:	0005079b          	sext.w	a5,a0
  42:	470d                	li	a4,3
  44:	0af76463          	bltu	a4,a5,ec <main+0xec>
    long long start = ret * CHUNK_SIZE;
  48:	00e5169b          	slliw	a3,a0,0xe
  4c:	0006879b          	sext.w	a5,a3
    long long end = (ret + 1) * CHUNK_SIZE;
  50:	6711                	lui	a4,0x4
  52:	9f35                	addw	a4,a4,a3
    long long sum = 0;

    for (long long i = start /*+ 1*/; i < end; i++) {
  54:	08e7da63          	bge	a5,a4,e8 <main+0xe8>
    long long sum = 0;
  58:	4981                	li	s3,0
      sum += i;
  5a:	99be                	add	s3,s3,a5
    for (long long i = start /*+ 1*/; i < end; i++) {
  5c:	0785                	addi	a5,a5,1
  5e:	fef71ee3          	bne	a4,a5,5a <main+0x5a>
    }

    for (int i = 0; i < ret; i++) {
  62:	01205f63          	blez	s2,80 <main+0x80>
      sleep(50 * ret);  // let lower-numbered children print first
  66:	03200a13          	li	s4,50
  6a:	032a0a3b          	mulw	s4,s4,s2
    for (int i = 0; i < ret; i++) {
  6e:	4481                	li	s1,0
      sleep(50 * ret);  // let lower-numbered children print first
  70:	8552                	mv	a0,s4
  72:	00000097          	auipc	ra,0x0
  76:	486080e7          	jalr	1158(ra) # 4f8 <sleep>
    for (int i = 0; i < ret; i++) {
  7a:	2485                	addiw	s1,s1,1
  7c:	fe991ae3          	bne	s2,s1,70 <main+0x70>
    }

    //  Use printf directly instead of manual string building
    
    printf("Child %d calculated sum: %d\n", ret, (int)sum);
  80:	2981                	sext.w	s3,s3
  82:	864e                	mv	a2,s3
  84:	85ca                	mv	a1,s2
  86:	00001517          	auipc	a0,0x1
  8a:	95a50513          	addi	a0,a0,-1702 # 9e0 <malloc+0x122>
  8e:	00000097          	auipc	ra,0x0
  92:	772080e7          	jalr	1906(ra) # 800 <printf>
    statuses[ret] = (int)sum;
  96:	00291793          	slli	a5,s2,0x2
  9a:	fd040713          	addi	a4,s0,-48
  9e:	97ba                	add	a5,a5,a4
  a0:	ff37a023          	sw	s3,-32(a5)
    sleep(10 * ret);  // let lower-numbered children print first
  a4:	4529                	li	a0,10
  a6:	0325053b          	mulw	a0,a0,s2
  aa:	00000097          	auipc	ra,0x0
  ae:	44e080e7          	jalr	1102(ra) # 4f8 <sleep>
    exit_num((int)(sum )); /// CHUNK_SIZE)); 
  b2:	854e                	mv	a0,s3
  b4:	00000097          	auipc	ra,0x0
  b8:	46c080e7          	jalr	1132(ra) # 520 <exit_num>

    exit(0);
  }

  return 0;
}
  bc:	4501                	li	a0,0
  be:	60e6                	ld	ra,88(sp)
  c0:	6446                	ld	s0,80(sp)
  c2:	64a6                	ld	s1,72(sp)
  c4:	6906                	ld	s2,64(sp)
  c6:	79e2                	ld	s3,56(sp)
  c8:	7a42                	ld	s4,48(sp)
  ca:	6125                	addi	sp,sp,96
  cc:	8082                	ret
    printf("forkn failed\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	90250513          	addi	a0,a0,-1790 # 9d0 <malloc+0x112>
  d6:	00000097          	auipc	ra,0x0
  da:	72a080e7          	jalr	1834(ra) # 800 <printf>
    exit(-1);
  de:	557d                	li	a0,-1
  e0:	00000097          	auipc	ra,0x0
  e4:	380080e7          	jalr	896(ra) # 460 <exit>
    long long sum = 0;
  e8:	4981                	li	s3,0
  ea:	bfa5                	j	62 <main+0x62>
  } else if (ret == -2) {
  ec:	57f9                	li	a5,-2
  ee:	fcf517e3          	bne	a0,a5,bc <main+0xbc>
    sleep(100);
  f2:	06400513          	li	a0,100
  f6:	00000097          	auipc	ra,0x0
  fa:	402080e7          	jalr	1026(ra) # 4f8 <sleep>
    printf("===> Waiting for children with waitall()\n");
  fe:	00001517          	auipc	a0,0x1
 102:	90250513          	addi	a0,a0,-1790 # a00 <malloc+0x142>
 106:	00000097          	auipc	ra,0x0
 10a:	6fa080e7          	jalr	1786(ra) # 800 <printf>
    if (waitall(&n, statuses) < 0) {
 10e:	fb040593          	addi	a1,s0,-80
 112:	fac40513          	addi	a0,s0,-84
 116:	00000097          	auipc	ra,0x0
 11a:	402080e7          	jalr	1026(ra) # 518 <waitall>
 11e:	00054b63          	bltz	a0,134 <main+0x134>
 122:	fb040913          	addi	s2,s0,-80
    for (int i = 0; i < n; i++) {
 126:	4481                	li	s1,0
    long long total = 0;
 128:	4981                	li	s3,0
      printf("statuses[%d] = %d\n", i, statuses[i]);
 12a:	00001a17          	auipc	s4,0x1
 12e:	916a0a13          	addi	s4,s4,-1770 # a40 <malloc+0x182>
 132:	a81d                	j	168 <main+0x168>
      printf("waitall failed\n");
 134:	00001517          	auipc	a0,0x1
 138:	8fc50513          	addi	a0,a0,-1796 # a30 <malloc+0x172>
 13c:	00000097          	auipc	ra,0x0
 140:	6c4080e7          	jalr	1732(ra) # 800 <printf>
      exit(-1);
 144:	557d                	li	a0,-1
 146:	00000097          	auipc	ra,0x0
 14a:	31a080e7          	jalr	794(ra) # 460 <exit>
      printf("statuses[%d] = %d\n", i, statuses[i]);
 14e:	00092603          	lw	a2,0(s2)
 152:	85a6                	mv	a1,s1
 154:	8552                	mv	a0,s4
 156:	00000097          	auipc	ra,0x0
 15a:	6aa080e7          	jalr	1706(ra) # 800 <printf>
      total += (long long)statuses[i] ;// * CHUNK_SIZE;
 15e:	00092783          	lw	a5,0(s2)
 162:	99be                	add	s3,s3,a5
    for (int i = 0; i < n; i++) {
 164:	2485                	addiw	s1,s1,1
 166:	0911                	addi	s2,s2,4
 168:	fac42583          	lw	a1,-84(s0)
 16c:	feb4c1e3          	blt	s1,a1,14e <main+0x14e>
    printf("===> All %d children finished\n", n);
 170:	00001517          	auipc	a0,0x1
 174:	8e850513          	addi	a0,a0,-1816 # a58 <malloc+0x19a>
 178:	00000097          	auipc	ra,0x0
 17c:	688080e7          	jalr	1672(ra) # 800 <printf>
    printf("Sum of all children's sums: %d\n", total);
 180:	85ce                	mv	a1,s3
 182:	00001517          	auipc	a0,0x1
 186:	8f650513          	addi	a0,a0,-1802 # a78 <malloc+0x1ba>
 18a:	00000097          	auipc	ra,0x0
 18e:	676080e7          	jalr	1654(ra) # 800 <printf>
    if (total == expected) {
 192:	7fff87b7          	lui	a5,0x7fff8
 196:	02f98263          	beq	s3,a5,1ba <main+0x1ba>
      printf("Wrong total sum: %d (expected %d)\n", total, expected);
 19a:	7fff8637          	lui	a2,0x7fff8
 19e:	85ce                	mv	a1,s3
 1a0:	00001517          	auipc	a0,0x1
 1a4:	91050513          	addi	a0,a0,-1776 # ab0 <malloc+0x1f2>
 1a8:	00000097          	auipc	ra,0x0
 1ac:	658080e7          	jalr	1624(ra) # 800 <printf>
    exit(0);
 1b0:	4501                	li	a0,0
 1b2:	00000097          	auipc	ra,0x0
 1b6:	2ae080e7          	jalr	686(ra) # 460 <exit>
      printf("Correct total sum: %d\n",total);
 1ba:	7fff85b7          	lui	a1,0x7fff8
 1be:	00001517          	auipc	a0,0x1
 1c2:	8da50513          	addi	a0,a0,-1830 # a98 <malloc+0x1da>
 1c6:	00000097          	auipc	ra,0x0
 1ca:	63a080e7          	jalr	1594(ra) # 800 <printf>
 1ce:	b7cd                	j	1b0 <main+0x1b0>

00000000000001d0 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e406                	sd	ra,8(sp)
 1d4:	e022                	sd	s0,0(sp)
 1d6:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1d8:	00000097          	auipc	ra,0x0
 1dc:	e28080e7          	jalr	-472(ra) # 0 <main>
  exit(0);
 1e0:	4501                	li	a0,0
 1e2:	00000097          	auipc	ra,0x0
 1e6:	27e080e7          	jalr	638(ra) # 460 <exit>

00000000000001ea <strcpy>:
}

char* strcpy(char *s, const char *t)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f0:	87aa                	mv	a5,a0
 1f2:	0585                	addi	a1,a1,1
 1f4:	0785                	addi	a5,a5,1
 1f6:	fff5c703          	lbu	a4,-1(a1) # 7fff7fff <base+0x7fff6fef>
 1fa:	fee78fa3          	sb	a4,-1(a5) # 7fff7fff <base+0x7fff6fef>
 1fe:	fb75                	bnez	a4,1f2 <strcpy+0x8>
    ;
  return os;
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret

0000000000000206 <strcmp>:

int strcmp(const char *p, const char *q)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 20c:	00054783          	lbu	a5,0(a0)
 210:	cb91                	beqz	a5,224 <strcmp+0x1e>
 212:	0005c703          	lbu	a4,0(a1)
 216:	00f71763          	bne	a4,a5,224 <strcmp+0x1e>
    p++, q++;
 21a:	0505                	addi	a0,a0,1
 21c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 21e:	00054783          	lbu	a5,0(a0)
 222:	fbe5                	bnez	a5,212 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 224:	0005c503          	lbu	a0,0(a1)
}
 228:	40a7853b          	subw	a0,a5,a0
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret

0000000000000232 <strlen>:

uint strlen(const char *s)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 238:	00054783          	lbu	a5,0(a0)
 23c:	cf91                	beqz	a5,258 <strlen+0x26>
 23e:	0505                	addi	a0,a0,1
 240:	87aa                	mv	a5,a0
 242:	4685                	li	a3,1
 244:	9e89                	subw	a3,a3,a0
 246:	00f6853b          	addw	a0,a3,a5
 24a:	0785                	addi	a5,a5,1
 24c:	fff7c703          	lbu	a4,-1(a5)
 250:	fb7d                	bnez	a4,246 <strlen+0x14>
    ;
  return n;
}
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  for(n = 0; s[n]; n++)
 258:	4501                	li	a0,0
 25a:	bfe5                	j	252 <strlen+0x20>

000000000000025c <memset>:

void* memset(void *dst, int c, uint n)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e422                	sd	s0,8(sp)
 260:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 262:	ce09                	beqz	a2,27c <memset+0x20>
 264:	87aa                	mv	a5,a0
 266:	fff6071b          	addiw	a4,a2,-1
 26a:	1702                	slli	a4,a4,0x20
 26c:	9301                	srli	a4,a4,0x20
 26e:	0705                	addi	a4,a4,1
 270:	972a                	add	a4,a4,a0
    cdst[i] = c;
 272:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 276:	0785                	addi	a5,a5,1
 278:	fee79de3          	bne	a5,a4,272 <memset+0x16>
  }
  return dst;
}
 27c:	6422                	ld	s0,8(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret

0000000000000282 <strchr>:

char* strchr(const char *s, char c)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  for(; *s; s++)
 288:	00054783          	lbu	a5,0(a0)
 28c:	cb99                	beqz	a5,2a2 <strchr+0x20>
    if(*s == c)
 28e:	00f58763          	beq	a1,a5,29c <strchr+0x1a>
  for(; *s; s++)
 292:	0505                	addi	a0,a0,1
 294:	00054783          	lbu	a5,0(a0)
 298:	fbfd                	bnez	a5,28e <strchr+0xc>
      return (char*)s;
  return 0;
 29a:	4501                	li	a0,0
}
 29c:	6422                	ld	s0,8(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret
  return 0;
 2a2:	4501                	li	a0,0
 2a4:	bfe5                	j	29c <strchr+0x1a>

00000000000002a6 <gets>:

char* gets(char *buf, int max)
{
 2a6:	711d                	addi	sp,sp,-96
 2a8:	ec86                	sd	ra,88(sp)
 2aa:	e8a2                	sd	s0,80(sp)
 2ac:	e4a6                	sd	s1,72(sp)
 2ae:	e0ca                	sd	s2,64(sp)
 2b0:	fc4e                	sd	s3,56(sp)
 2b2:	f852                	sd	s4,48(sp)
 2b4:	f456                	sd	s5,40(sp)
 2b6:	f05a                	sd	s6,32(sp)
 2b8:	ec5e                	sd	s7,24(sp)
 2ba:	1080                	addi	s0,sp,96
 2bc:	8baa                	mv	s7,a0
 2be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c0:	892a                	mv	s2,a0
 2c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2c4:	4aa9                	li	s5,10
 2c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2c8:	89a6                	mv	s3,s1
 2ca:	2485                	addiw	s1,s1,1
 2cc:	0344d863          	bge	s1,s4,2fc <gets+0x56>
    cc = read(0, &c, 1);
 2d0:	4605                	li	a2,1
 2d2:	faf40593          	addi	a1,s0,-81
 2d6:	4501                	li	a0,0
 2d8:	00000097          	auipc	ra,0x0
 2dc:	1a8080e7          	jalr	424(ra) # 480 <read>
    if(cc < 1)
 2e0:	00a05e63          	blez	a0,2fc <gets+0x56>
    buf[i++] = c;
 2e4:	faf44783          	lbu	a5,-81(s0)
 2e8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ec:	01578763          	beq	a5,s5,2fa <gets+0x54>
 2f0:	0905                	addi	s2,s2,1
 2f2:	fd679be3          	bne	a5,s6,2c8 <gets+0x22>
  for(i=0; i+1 < max; ){
 2f6:	89a6                	mv	s3,s1
 2f8:	a011                	j	2fc <gets+0x56>
 2fa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2fc:	99de                	add	s3,s3,s7
 2fe:	00098023          	sb	zero,0(s3)
  return buf;
}
 302:	855e                	mv	a0,s7
 304:	60e6                	ld	ra,88(sp)
 306:	6446                	ld	s0,80(sp)
 308:	64a6                	ld	s1,72(sp)
 30a:	6906                	ld	s2,64(sp)
 30c:	79e2                	ld	s3,56(sp)
 30e:	7a42                	ld	s4,48(sp)
 310:	7aa2                	ld	s5,40(sp)
 312:	7b02                	ld	s6,32(sp)
 314:	6be2                	ld	s7,24(sp)
 316:	6125                	addi	sp,sp,96
 318:	8082                	ret

000000000000031a <stat>:

int stat(const char *n, struct stat *st)
{
 31a:	1101                	addi	sp,sp,-32
 31c:	ec06                	sd	ra,24(sp)
 31e:	e822                	sd	s0,16(sp)
 320:	e426                	sd	s1,8(sp)
 322:	e04a                	sd	s2,0(sp)
 324:	1000                	addi	s0,sp,32
 326:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 328:	4581                	li	a1,0
 32a:	00000097          	auipc	ra,0x0
 32e:	17e080e7          	jalr	382(ra) # 4a8 <open>
  if(fd < 0)
 332:	02054563          	bltz	a0,35c <stat+0x42>
 336:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 338:	85ca                	mv	a1,s2
 33a:	00000097          	auipc	ra,0x0
 33e:	186080e7          	jalr	390(ra) # 4c0 <fstat>
 342:	892a                	mv	s2,a0
  close(fd);
 344:	8526                	mv	a0,s1
 346:	00000097          	auipc	ra,0x0
 34a:	14a080e7          	jalr	330(ra) # 490 <close>
  return r;
}
 34e:	854a                	mv	a0,s2
 350:	60e2                	ld	ra,24(sp)
 352:	6442                	ld	s0,16(sp)
 354:	64a2                	ld	s1,8(sp)
 356:	6902                	ld	s2,0(sp)
 358:	6105                	addi	sp,sp,32
 35a:	8082                	ret
    return -1;
 35c:	597d                	li	s2,-1
 35e:	bfc5                	j	34e <stat+0x34>

0000000000000360 <atoi>:

int atoi(const char *s)
{
 360:	1141                	addi	sp,sp,-16
 362:	e422                	sd	s0,8(sp)
 364:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 366:	00054603          	lbu	a2,0(a0)
 36a:	fd06079b          	addiw	a5,a2,-48
 36e:	0ff7f793          	andi	a5,a5,255
 372:	4725                	li	a4,9
 374:	02f76963          	bltu	a4,a5,3a6 <atoi+0x46>
 378:	86aa                	mv	a3,a0
  n = 0;
 37a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 37c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 37e:	0685                	addi	a3,a3,1
 380:	0025179b          	slliw	a5,a0,0x2
 384:	9fa9                	addw	a5,a5,a0
 386:	0017979b          	slliw	a5,a5,0x1
 38a:	9fb1                	addw	a5,a5,a2
 38c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 390:	0006c603          	lbu	a2,0(a3)
 394:	fd06071b          	addiw	a4,a2,-48
 398:	0ff77713          	andi	a4,a4,255
 39c:	fee5f1e3          	bgeu	a1,a4,37e <atoi+0x1e>
  return n;
}
 3a0:	6422                	ld	s0,8(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret
  n = 0;
 3a6:	4501                	li	a0,0
 3a8:	bfe5                	j	3a0 <atoi+0x40>

00000000000003aa <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 3aa:	1141                	addi	sp,sp,-16
 3ac:	e422                	sd	s0,8(sp)
 3ae:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3b0:	02b57663          	bgeu	a0,a1,3dc <memmove+0x32>
    while(n-- > 0)
 3b4:	02c05163          	blez	a2,3d6 <memmove+0x2c>
 3b8:	fff6079b          	addiw	a5,a2,-1
 3bc:	1782                	slli	a5,a5,0x20
 3be:	9381                	srli	a5,a5,0x20
 3c0:	0785                	addi	a5,a5,1
 3c2:	97aa                	add	a5,a5,a0
  dst = vdst;
 3c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3c6:	0585                	addi	a1,a1,1
 3c8:	0705                	addi	a4,a4,1
 3ca:	fff5c683          	lbu	a3,-1(a1)
 3ce:	fed70fa3          	sb	a3,-1(a4) # 3fff <base+0x2fef>
    while(n-- > 0)
 3d2:	fee79ae3          	bne	a5,a4,3c6 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3d6:	6422                	ld	s0,8(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret
    dst += n;
 3dc:	00c50733          	add	a4,a0,a2
    src += n;
 3e0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e2:	fec05ae3          	blez	a2,3d6 <memmove+0x2c>
 3e6:	fff6079b          	addiw	a5,a2,-1
 3ea:	1782                	slli	a5,a5,0x20
 3ec:	9381                	srli	a5,a5,0x20
 3ee:	fff7c793          	not	a5,a5
 3f2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3f4:	15fd                	addi	a1,a1,-1
 3f6:	177d                	addi	a4,a4,-1
 3f8:	0005c683          	lbu	a3,0(a1)
 3fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 400:	fee79ae3          	bne	a5,a4,3f4 <memmove+0x4a>
 404:	bfc9                	j	3d6 <memmove+0x2c>

0000000000000406 <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 406:	1141                	addi	sp,sp,-16
 408:	e422                	sd	s0,8(sp)
 40a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 40c:	ca05                	beqz	a2,43c <memcmp+0x36>
 40e:	fff6069b          	addiw	a3,a2,-1
 412:	1682                	slli	a3,a3,0x20
 414:	9281                	srli	a3,a3,0x20
 416:	0685                	addi	a3,a3,1
 418:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 41a:	00054783          	lbu	a5,0(a0)
 41e:	0005c703          	lbu	a4,0(a1)
 422:	00e79863          	bne	a5,a4,432 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 426:	0505                	addi	a0,a0,1
    p2++;
 428:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 42a:	fed518e3          	bne	a0,a3,41a <memcmp+0x14>
  }
  return 0;
 42e:	4501                	li	a0,0
 430:	a019                	j	436 <memcmp+0x30>
      return *p1 - *p2;
 432:	40e7853b          	subw	a0,a5,a4
}
 436:	6422                	ld	s0,8(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret
  return 0;
 43c:	4501                	li	a0,0
 43e:	bfe5                	j	436 <memcmp+0x30>

0000000000000440 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 440:	1141                	addi	sp,sp,-16
 442:	e406                	sd	ra,8(sp)
 444:	e022                	sd	s0,0(sp)
 446:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 448:	00000097          	auipc	ra,0x0
 44c:	f62080e7          	jalr	-158(ra) # 3aa <memmove>
}
 450:	60a2                	ld	ra,8(sp)
 452:	6402                	ld	s0,0(sp)
 454:	0141                	addi	sp,sp,16
 456:	8082                	ret

0000000000000458 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 458:	4885                	li	a7,1
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <exit>:
.global exit
exit:
 li a7, SYS_exit
 460:	4889                	li	a7,2
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 468:	48e1                	li	a7,24
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <wait>:
.global wait
wait:
 li a7, SYS_wait
 470:	488d                	li	a7,3
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 478:	4891                	li	a7,4
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <read>:
.global read
read:
 li a7, SYS_read
 480:	4895                	li	a7,5
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <write>:
.global write
write:
 li a7, SYS_write
 488:	48c1                	li	a7,16
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <close>:
.global close
close:
 li a7, SYS_close
 490:	48d5                	li	a7,21
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <kill>:
.global kill
kill:
 li a7, SYS_kill
 498:	4899                	li	a7,6
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a0:	489d                	li	a7,7
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <open>:
.global open
open:
 li a7, SYS_open
 4a8:	48bd                	li	a7,15
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4b0:	48c5                	li	a7,17
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b8:	48c9                	li	a7,18
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4c0:	48a1                	li	a7,8
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <link>:
.global link
link:
 li a7, SYS_link
 4c8:	48cd                	li	a7,19
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4d0:	48d1                	li	a7,20
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d8:	48a5                	li	a7,9
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4e0:	48a9                	li	a7,10
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e8:	48ad                	li	a7,11
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4f0:	48b1                	li	a7,12
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f8:	48b5                	li	a7,13
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 500:	48b9                	li	a7,14
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 508:	48dd                	li	a7,23
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 510:	48e5                	li	a7,25
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 518:	48e9                	li	a7,26
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 520:	48ed                	li	a7,27
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 528:	1101                	addi	sp,sp,-32
 52a:	ec06                	sd	ra,24(sp)
 52c:	e822                	sd	s0,16(sp)
 52e:	1000                	addi	s0,sp,32
 530:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 534:	4605                	li	a2,1
 536:	fef40593          	addi	a1,s0,-17
 53a:	00000097          	auipc	ra,0x0
 53e:	f4e080e7          	jalr	-178(ra) # 488 <write>
}
 542:	60e2                	ld	ra,24(sp)
 544:	6442                	ld	s0,16(sp)
 546:	6105                	addi	sp,sp,32
 548:	8082                	ret

000000000000054a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 54a:	7139                	addi	sp,sp,-64
 54c:	fc06                	sd	ra,56(sp)
 54e:	f822                	sd	s0,48(sp)
 550:	f426                	sd	s1,40(sp)
 552:	f04a                	sd	s2,32(sp)
 554:	ec4e                	sd	s3,24(sp)
 556:	0080                	addi	s0,sp,64
 558:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 55a:	c299                	beqz	a3,560 <printint+0x16>
 55c:	0805c863          	bltz	a1,5ec <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 560:	2581                	sext.w	a1,a1
  neg = 0;
 562:	4881                	li	a7,0
 564:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 568:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 56a:	2601                	sext.w	a2,a2
 56c:	00000517          	auipc	a0,0x0
 570:	57450513          	addi	a0,a0,1396 # ae0 <digits>
 574:	883a                	mv	a6,a4
 576:	2705                	addiw	a4,a4,1
 578:	02c5f7bb          	remuw	a5,a1,a2
 57c:	1782                	slli	a5,a5,0x20
 57e:	9381                	srli	a5,a5,0x20
 580:	97aa                	add	a5,a5,a0
 582:	0007c783          	lbu	a5,0(a5)
 586:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 58a:	0005879b          	sext.w	a5,a1
 58e:	02c5d5bb          	divuw	a1,a1,a2
 592:	0685                	addi	a3,a3,1
 594:	fec7f0e3          	bgeu	a5,a2,574 <printint+0x2a>
  if(neg)
 598:	00088b63          	beqz	a7,5ae <printint+0x64>
    buf[i++] = '-';
 59c:	fd040793          	addi	a5,s0,-48
 5a0:	973e                	add	a4,a4,a5
 5a2:	02d00793          	li	a5,45
 5a6:	fef70823          	sb	a5,-16(a4)
 5aa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5ae:	02e05863          	blez	a4,5de <printint+0x94>
 5b2:	fc040793          	addi	a5,s0,-64
 5b6:	00e78933          	add	s2,a5,a4
 5ba:	fff78993          	addi	s3,a5,-1
 5be:	99ba                	add	s3,s3,a4
 5c0:	377d                	addiw	a4,a4,-1
 5c2:	1702                	slli	a4,a4,0x20
 5c4:	9301                	srli	a4,a4,0x20
 5c6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5ca:	fff94583          	lbu	a1,-1(s2)
 5ce:	8526                	mv	a0,s1
 5d0:	00000097          	auipc	ra,0x0
 5d4:	f58080e7          	jalr	-168(ra) # 528 <putc>
  while(--i >= 0)
 5d8:	197d                	addi	s2,s2,-1
 5da:	ff3918e3          	bne	s2,s3,5ca <printint+0x80>
}
 5de:	70e2                	ld	ra,56(sp)
 5e0:	7442                	ld	s0,48(sp)
 5e2:	74a2                	ld	s1,40(sp)
 5e4:	7902                	ld	s2,32(sp)
 5e6:	69e2                	ld	s3,24(sp)
 5e8:	6121                	addi	sp,sp,64
 5ea:	8082                	ret
    x = -xx;
 5ec:	40b005bb          	negw	a1,a1
    neg = 1;
 5f0:	4885                	li	a7,1
    x = -xx;
 5f2:	bf8d                	j	564 <printint+0x1a>

00000000000005f4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5f4:	7119                	addi	sp,sp,-128
 5f6:	fc86                	sd	ra,120(sp)
 5f8:	f8a2                	sd	s0,112(sp)
 5fa:	f4a6                	sd	s1,104(sp)
 5fc:	f0ca                	sd	s2,96(sp)
 5fe:	ecce                	sd	s3,88(sp)
 600:	e8d2                	sd	s4,80(sp)
 602:	e4d6                	sd	s5,72(sp)
 604:	e0da                	sd	s6,64(sp)
 606:	fc5e                	sd	s7,56(sp)
 608:	f862                	sd	s8,48(sp)
 60a:	f466                	sd	s9,40(sp)
 60c:	f06a                	sd	s10,32(sp)
 60e:	ec6e                	sd	s11,24(sp)
 610:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 612:	0005c903          	lbu	s2,0(a1)
 616:	18090f63          	beqz	s2,7b4 <vprintf+0x1c0>
 61a:	8aaa                	mv	s5,a0
 61c:	8b32                	mv	s6,a2
 61e:	00158493          	addi	s1,a1,1
  state = 0;
 622:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 624:	02500a13          	li	s4,37
      if(c == 'd'){
 628:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 62c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 630:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 634:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 638:	00000b97          	auipc	s7,0x0
 63c:	4a8b8b93          	addi	s7,s7,1192 # ae0 <digits>
 640:	a839                	j	65e <vprintf+0x6a>
        putc(fd, c);
 642:	85ca                	mv	a1,s2
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	ee2080e7          	jalr	-286(ra) # 528 <putc>
 64e:	a019                	j	654 <vprintf+0x60>
    } else if(state == '%'){
 650:	01498f63          	beq	s3,s4,66e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 654:	0485                	addi	s1,s1,1
 656:	fff4c903          	lbu	s2,-1(s1)
 65a:	14090d63          	beqz	s2,7b4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 65e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 662:	fe0997e3          	bnez	s3,650 <vprintf+0x5c>
      if(c == '%'){
 666:	fd479ee3          	bne	a5,s4,642 <vprintf+0x4e>
        state = '%';
 66a:	89be                	mv	s3,a5
 66c:	b7e5                	j	654 <vprintf+0x60>
      if(c == 'd'){
 66e:	05878063          	beq	a5,s8,6ae <vprintf+0xba>
      } else if(c == 'l') {
 672:	05978c63          	beq	a5,s9,6ca <vprintf+0xd6>
      } else if(c == 'x') {
 676:	07a78863          	beq	a5,s10,6e6 <vprintf+0xf2>
      } else if(c == 'p') {
 67a:	09b78463          	beq	a5,s11,702 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 67e:	07300713          	li	a4,115
 682:	0ce78663          	beq	a5,a4,74e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 686:	06300713          	li	a4,99
 68a:	0ee78e63          	beq	a5,a4,786 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 68e:	11478863          	beq	a5,s4,79e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 692:	85d2                	mv	a1,s4
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e92080e7          	jalr	-366(ra) # 528 <putc>
        putc(fd, c);
 69e:	85ca                	mv	a1,s2
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	e86080e7          	jalr	-378(ra) # 528 <putc>
      }
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b765                	j	654 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6ae:	008b0913          	addi	s2,s6,8
 6b2:	4685                	li	a3,1
 6b4:	4629                	li	a2,10
 6b6:	000b2583          	lw	a1,0(s6)
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e8e080e7          	jalr	-370(ra) # 54a <printint>
 6c4:	8b4a                	mv	s6,s2
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b771                	j	654 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ca:	008b0913          	addi	s2,s6,8
 6ce:	4681                	li	a3,0
 6d0:	4629                	li	a2,10
 6d2:	000b2583          	lw	a1,0(s6)
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e72080e7          	jalr	-398(ra) # 54a <printint>
 6e0:	8b4a                	mv	s6,s2
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bf85                	j	654 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6e6:	008b0913          	addi	s2,s6,8
 6ea:	4681                	li	a3,0
 6ec:	4641                	li	a2,16
 6ee:	000b2583          	lw	a1,0(s6)
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	e56080e7          	jalr	-426(ra) # 54a <printint>
 6fc:	8b4a                	mv	s6,s2
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bf91                	j	654 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 702:	008b0793          	addi	a5,s6,8
 706:	f8f43423          	sd	a5,-120(s0)
 70a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 70e:	03000593          	li	a1,48
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e14080e7          	jalr	-492(ra) # 528 <putc>
  putc(fd, 'x');
 71c:	85ea                	mv	a1,s10
 71e:	8556                	mv	a0,s5
 720:	00000097          	auipc	ra,0x0
 724:	e08080e7          	jalr	-504(ra) # 528 <putc>
 728:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 72a:	03c9d793          	srli	a5,s3,0x3c
 72e:	97de                	add	a5,a5,s7
 730:	0007c583          	lbu	a1,0(a5)
 734:	8556                	mv	a0,s5
 736:	00000097          	auipc	ra,0x0
 73a:	df2080e7          	jalr	-526(ra) # 528 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 73e:	0992                	slli	s3,s3,0x4
 740:	397d                	addiw	s2,s2,-1
 742:	fe0914e3          	bnez	s2,72a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 746:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 74a:	4981                	li	s3,0
 74c:	b721                	j	654 <vprintf+0x60>
        s = va_arg(ap, char*);
 74e:	008b0993          	addi	s3,s6,8
 752:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 756:	02090163          	beqz	s2,778 <vprintf+0x184>
        while(*s != 0){
 75a:	00094583          	lbu	a1,0(s2)
 75e:	c9a1                	beqz	a1,7ae <vprintf+0x1ba>
          putc(fd, *s);
 760:	8556                	mv	a0,s5
 762:	00000097          	auipc	ra,0x0
 766:	dc6080e7          	jalr	-570(ra) # 528 <putc>
          s++;
 76a:	0905                	addi	s2,s2,1
        while(*s != 0){
 76c:	00094583          	lbu	a1,0(s2)
 770:	f9e5                	bnez	a1,760 <vprintf+0x16c>
        s = va_arg(ap, char*);
 772:	8b4e                	mv	s6,s3
      state = 0;
 774:	4981                	li	s3,0
 776:	bdf9                	j	654 <vprintf+0x60>
          s = "(null)";
 778:	00000917          	auipc	s2,0x0
 77c:	36090913          	addi	s2,s2,864 # ad8 <malloc+0x21a>
        while(*s != 0){
 780:	02800593          	li	a1,40
 784:	bff1                	j	760 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 786:	008b0913          	addi	s2,s6,8
 78a:	000b4583          	lbu	a1,0(s6)
 78e:	8556                	mv	a0,s5
 790:	00000097          	auipc	ra,0x0
 794:	d98080e7          	jalr	-616(ra) # 528 <putc>
 798:	8b4a                	mv	s6,s2
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bd65                	j	654 <vprintf+0x60>
        putc(fd, c);
 79e:	85d2                	mv	a1,s4
 7a0:	8556                	mv	a0,s5
 7a2:	00000097          	auipc	ra,0x0
 7a6:	d86080e7          	jalr	-634(ra) # 528 <putc>
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b565                	j	654 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ae:	8b4e                	mv	s6,s3
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	b54d                	j	654 <vprintf+0x60>
    }
  }
}
 7b4:	70e6                	ld	ra,120(sp)
 7b6:	7446                	ld	s0,112(sp)
 7b8:	74a6                	ld	s1,104(sp)
 7ba:	7906                	ld	s2,96(sp)
 7bc:	69e6                	ld	s3,88(sp)
 7be:	6a46                	ld	s4,80(sp)
 7c0:	6aa6                	ld	s5,72(sp)
 7c2:	6b06                	ld	s6,64(sp)
 7c4:	7be2                	ld	s7,56(sp)
 7c6:	7c42                	ld	s8,48(sp)
 7c8:	7ca2                	ld	s9,40(sp)
 7ca:	7d02                	ld	s10,32(sp)
 7cc:	6de2                	ld	s11,24(sp)
 7ce:	6109                	addi	sp,sp,128
 7d0:	8082                	ret

00000000000007d2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d2:	715d                	addi	sp,sp,-80
 7d4:	ec06                	sd	ra,24(sp)
 7d6:	e822                	sd	s0,16(sp)
 7d8:	1000                	addi	s0,sp,32
 7da:	e010                	sd	a2,0(s0)
 7dc:	e414                	sd	a3,8(s0)
 7de:	e818                	sd	a4,16(s0)
 7e0:	ec1c                	sd	a5,24(s0)
 7e2:	03043023          	sd	a6,32(s0)
 7e6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ee:	8622                	mv	a2,s0
 7f0:	00000097          	auipc	ra,0x0
 7f4:	e04080e7          	jalr	-508(ra) # 5f4 <vprintf>
}
 7f8:	60e2                	ld	ra,24(sp)
 7fa:	6442                	ld	s0,16(sp)
 7fc:	6161                	addi	sp,sp,80
 7fe:	8082                	ret

0000000000000800 <printf>:

void
printf(const char *fmt, ...)
{
 800:	711d                	addi	sp,sp,-96
 802:	ec06                	sd	ra,24(sp)
 804:	e822                	sd	s0,16(sp)
 806:	1000                	addi	s0,sp,32
 808:	e40c                	sd	a1,8(s0)
 80a:	e810                	sd	a2,16(s0)
 80c:	ec14                	sd	a3,24(s0)
 80e:	f018                	sd	a4,32(s0)
 810:	f41c                	sd	a5,40(s0)
 812:	03043823          	sd	a6,48(s0)
 816:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 81a:	00840613          	addi	a2,s0,8
 81e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 822:	85aa                	mv	a1,a0
 824:	4505                	li	a0,1
 826:	00000097          	auipc	ra,0x0
 82a:	dce080e7          	jalr	-562(ra) # 5f4 <vprintf>
}
 82e:	60e2                	ld	ra,24(sp)
 830:	6442                	ld	s0,16(sp)
 832:	6125                	addi	sp,sp,96
 834:	8082                	ret

0000000000000836 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 836:	1141                	addi	sp,sp,-16
 838:	e422                	sd	s0,8(sp)
 83a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 840:	00000797          	auipc	a5,0x0
 844:	7c07b783          	ld	a5,1984(a5) # 1000 <freep>
 848:	a805                	j	878 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 84a:	4618                	lw	a4,8(a2)
 84c:	9db9                	addw	a1,a1,a4
 84e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 852:	6398                	ld	a4,0(a5)
 854:	6318                	ld	a4,0(a4)
 856:	fee53823          	sd	a4,-16(a0)
 85a:	a091                	j	89e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 85c:	ff852703          	lw	a4,-8(a0)
 860:	9e39                	addw	a2,a2,a4
 862:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 864:	ff053703          	ld	a4,-16(a0)
 868:	e398                	sd	a4,0(a5)
 86a:	a099                	j	8b0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86c:	6398                	ld	a4,0(a5)
 86e:	00e7e463          	bltu	a5,a4,876 <free+0x40>
 872:	00e6ea63          	bltu	a3,a4,886 <free+0x50>
{
 876:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 878:	fed7fae3          	bgeu	a5,a3,86c <free+0x36>
 87c:	6398                	ld	a4,0(a5)
 87e:	00e6e463          	bltu	a3,a4,886 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 882:	fee7eae3          	bltu	a5,a4,876 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 886:	ff852583          	lw	a1,-8(a0)
 88a:	6390                	ld	a2,0(a5)
 88c:	02059713          	slli	a4,a1,0x20
 890:	9301                	srli	a4,a4,0x20
 892:	0712                	slli	a4,a4,0x4
 894:	9736                	add	a4,a4,a3
 896:	fae60ae3          	beq	a2,a4,84a <free+0x14>
    bp->s.ptr = p->s.ptr;
 89a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 89e:	4790                	lw	a2,8(a5)
 8a0:	02061713          	slli	a4,a2,0x20
 8a4:	9301                	srli	a4,a4,0x20
 8a6:	0712                	slli	a4,a4,0x4
 8a8:	973e                	add	a4,a4,a5
 8aa:	fae689e3          	beq	a3,a4,85c <free+0x26>
  } else
    p->s.ptr = bp;
 8ae:	e394                	sd	a3,0(a5)
  freep = p;
 8b0:	00000717          	auipc	a4,0x0
 8b4:	74f73823          	sd	a5,1872(a4) # 1000 <freep>
}
 8b8:	6422                	ld	s0,8(sp)
 8ba:	0141                	addi	sp,sp,16
 8bc:	8082                	ret

00000000000008be <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8be:	7139                	addi	sp,sp,-64
 8c0:	fc06                	sd	ra,56(sp)
 8c2:	f822                	sd	s0,48(sp)
 8c4:	f426                	sd	s1,40(sp)
 8c6:	f04a                	sd	s2,32(sp)
 8c8:	ec4e                	sd	s3,24(sp)
 8ca:	e852                	sd	s4,16(sp)
 8cc:	e456                	sd	s5,8(sp)
 8ce:	e05a                	sd	s6,0(sp)
 8d0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d2:	02051493          	slli	s1,a0,0x20
 8d6:	9081                	srli	s1,s1,0x20
 8d8:	04bd                	addi	s1,s1,15
 8da:	8091                	srli	s1,s1,0x4
 8dc:	0014899b          	addiw	s3,s1,1
 8e0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8e2:	00000517          	auipc	a0,0x0
 8e6:	71e53503          	ld	a0,1822(a0) # 1000 <freep>
 8ea:	c515                	beqz	a0,916 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ee:	4798                	lw	a4,8(a5)
 8f0:	02977f63          	bgeu	a4,s1,92e <malloc+0x70>
 8f4:	8a4e                	mv	s4,s3
 8f6:	0009871b          	sext.w	a4,s3
 8fa:	6685                	lui	a3,0x1
 8fc:	00d77363          	bgeu	a4,a3,902 <malloc+0x44>
 900:	6a05                	lui	s4,0x1
 902:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 906:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 90a:	00000917          	auipc	s2,0x0
 90e:	6f690913          	addi	s2,s2,1782 # 1000 <freep>
  if(p == (char*)-1)
 912:	5afd                	li	s5,-1
 914:	a88d                	j	986 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 916:	00000797          	auipc	a5,0x0
 91a:	6fa78793          	addi	a5,a5,1786 # 1010 <base>
 91e:	00000717          	auipc	a4,0x0
 922:	6ef73123          	sd	a5,1762(a4) # 1000 <freep>
 926:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 928:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92c:	b7e1                	j	8f4 <malloc+0x36>
      if(p->s.size == nunits)
 92e:	02e48b63          	beq	s1,a4,964 <malloc+0xa6>
        p->s.size -= nunits;
 932:	4137073b          	subw	a4,a4,s3
 936:	c798                	sw	a4,8(a5)
        p += p->s.size;
 938:	1702                	slli	a4,a4,0x20
 93a:	9301                	srli	a4,a4,0x20
 93c:	0712                	slli	a4,a4,0x4
 93e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 940:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 944:	00000717          	auipc	a4,0x0
 948:	6aa73e23          	sd	a0,1724(a4) # 1000 <freep>
      return (void*)(p + 1);
 94c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 950:	70e2                	ld	ra,56(sp)
 952:	7442                	ld	s0,48(sp)
 954:	74a2                	ld	s1,40(sp)
 956:	7902                	ld	s2,32(sp)
 958:	69e2                	ld	s3,24(sp)
 95a:	6a42                	ld	s4,16(sp)
 95c:	6aa2                	ld	s5,8(sp)
 95e:	6b02                	ld	s6,0(sp)
 960:	6121                	addi	sp,sp,64
 962:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 964:	6398                	ld	a4,0(a5)
 966:	e118                	sd	a4,0(a0)
 968:	bff1                	j	944 <malloc+0x86>
  hp->s.size = nu;
 96a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 96e:	0541                	addi	a0,a0,16
 970:	00000097          	auipc	ra,0x0
 974:	ec6080e7          	jalr	-314(ra) # 836 <free>
  return freep;
 978:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 97c:	d971                	beqz	a0,950 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 980:	4798                	lw	a4,8(a5)
 982:	fa9776e3          	bgeu	a4,s1,92e <malloc+0x70>
    if(p == freep)
 986:	00093703          	ld	a4,0(s2)
 98a:	853e                	mv	a0,a5
 98c:	fef719e3          	bne	a4,a5,97e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 990:	8552                	mv	a0,s4
 992:	00000097          	auipc	ra,0x0
 996:	b5e080e7          	jalr	-1186(ra) # 4f0 <sbrk>
  if(p == (char*)-1)
 99a:	fd5518e3          	bne	a0,s5,96a <malloc+0xac>
        return 0;
 99e:	4501                	li	a0,0
 9a0:	bf45                	j	950 <malloc+0x92>
