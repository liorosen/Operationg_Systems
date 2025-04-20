
user/_bigarray:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define NUM_CHILDREN 8
#define CHUNK_SIZE (SIZE / NUM_CHILDREN)



int main() {
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	0100                	addi	s0,sp,128
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);
  10:	45a1                	li	a1,8
  12:	00001517          	auipc	a0,0x1
  16:	9be50513          	addi	a0,a0,-1602 # 9d0 <malloc+0xe4>
  1a:	00001097          	auipc	ra,0x1
  1e:	814080e7          	jalr	-2028(ra) # 82e <printf>

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN] ;
  int n = NUM_CHILDREN;
  22:	47a1                	li	a5,8
  24:	f8f42623          	sw	a5,-116(s0)

  int ret = forkn(NUM_CHILDREN, pids);
  28:	fb040593          	addi	a1,s0,-80
  2c:	4521                	li	a0,8
  2e:	00000097          	auipc	ra,0x0
  32:	510080e7          	jalr	1296(ra) # 53e <forkn>

  if (ret == -1) {
  36:	57fd                	li	a5,-1
  38:	08f50e63          	beq	a0,a5,d4 <main+0xd4>
  3c:	892a                	mv	s2,a0
    printf("forkn failed\n");
    exit(-1);
  } else if (ret >= 0 && ret < NUM_CHILDREN) {
  3e:	0005079b          	sext.w	a5,a0
  42:	471d                	li	a4,7
  44:	0af76563          	bltu	a4,a5,ee <main+0xee>
    // Calculate correct start and end for any NUM_CHILDREN and SIZE
    long long base = SIZE / NUM_CHILDREN;
    long long rem = SIZE % NUM_CHILDREN;

    long long start = ret * base + (ret < rem ? ret : rem);
  48:	00d51713          	slli	a4,a0,0xd
  4c:	6789                	lui	a5,0x2

    // long long start = ret * CHUNK_SIZE;
    // long long end = (ret + 1) * CHUNK_SIZE;
    long long sum = 0;

    for (long long i = start ; i < end; i++) {
  4e:	17fd                	addi	a5,a5,-1
  50:	fffd                	bnez	a5,4e <main+0x4e>
  52:	00170493          	addi	s1,a4,1
  56:	6a09                	lui	s4,0x2
  58:	1a7d                	addi	s4,s4,-1
  5a:	034484b3          	mul	s1,s1,s4
  5e:	01ffda37          	lui	s4,0x1ffd
  62:	0a05                	addi	s4,s4,1
  64:	9a3a                	add	s4,s4,a4
  66:	9a26                	add	s4,s4,s1
      sum += i;
    }

    for (int i = 0; i < ret; i++) {
  68:	01205f63          	blez	s2,86 <main+0x86>
      sleep(50 * ret);  // let lower-numbered children print first
  6c:	03200993          	li	s3,50
  70:	032989bb          	mulw	s3,s3,s2
    for (int i = 0; i < ret; i++) {
  74:	4481                	li	s1,0
      sleep(50 * ret);  // let lower-numbered children print first
  76:	854e                	mv	a0,s3
  78:	00000097          	auipc	ra,0x0
  7c:	4ae080e7          	jalr	1198(ra) # 526 <sleep>
    for (int i = 0; i < ret; i++) {
  80:	2485                	addiw	s1,s1,1
  82:	fe991ae3          	bne	s2,s1,76 <main+0x76>
    }

    
    printf("Child %d calculated sum: %d\n", ret, (int)sum);
  86:	2a01                	sext.w	s4,s4
  88:	8652                	mv	a2,s4
  8a:	85ca                	mv	a1,s2
  8c:	00001517          	auipc	a0,0x1
  90:	97450513          	addi	a0,a0,-1676 # a00 <malloc+0x114>
  94:	00000097          	auipc	ra,0x0
  98:	79a080e7          	jalr	1946(ra) # 82e <printf>
    statuses[ret] = (int)sum;
  9c:	00291793          	slli	a5,s2,0x2
  a0:	fd040713          	addi	a4,s0,-48
  a4:	97ba                	add	a5,a5,a4
  a6:	fd47a023          	sw	s4,-64(a5) # 1fc0 <base+0xfb0>
    sleep(10 * ret);  // let lower-numbered children print first
  aa:	4529                	li	a0,10
  ac:	0325053b          	mulw	a0,a0,s2
  b0:	00000097          	auipc	ra,0x0
  b4:	476080e7          	jalr	1142(ra) # 526 <sleep>
    exit_num((int)(sum)); 
  b8:	8552                	mv	a0,s4
  ba:	00000097          	auipc	ra,0x0
  be:	494080e7          	jalr	1172(ra) # 54e <exit_num>

    exit(0);
  }

  return 0;
}
  c2:	4501                	li	a0,0
  c4:	70e6                	ld	ra,120(sp)
  c6:	7446                	ld	s0,112(sp)
  c8:	74a6                	ld	s1,104(sp)
  ca:	7906                	ld	s2,96(sp)
  cc:	69e6                	ld	s3,88(sp)
  ce:	6a46                	ld	s4,80(sp)
  d0:	6109                	addi	sp,sp,128
  d2:	8082                	ret
    printf("forkn failed\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	91c50513          	addi	a0,a0,-1764 # 9f0 <malloc+0x104>
  dc:	00000097          	auipc	ra,0x0
  e0:	752080e7          	jalr	1874(ra) # 82e <printf>
    exit(-1);
  e4:	557d                	li	a0,-1
  e6:	00000097          	auipc	ra,0x0
  ea:	3a8080e7          	jalr	936(ra) # 48e <exit>
  } else if (ret == -2) {
  ee:	57f9                	li	a5,-2
  f0:	fcf519e3          	bne	a0,a5,c2 <main+0xc2>
    sleep(100);
  f4:	06400513          	li	a0,100
  f8:	00000097          	auipc	ra,0x0
  fc:	42e080e7          	jalr	1070(ra) # 526 <sleep>
    printf("===> Waiting for children with waitall()\n");
 100:	00001517          	auipc	a0,0x1
 104:	92050513          	addi	a0,a0,-1760 # a20 <malloc+0x134>
 108:	00000097          	auipc	ra,0x0
 10c:	726080e7          	jalr	1830(ra) # 82e <printf>
    if (waitall(&n, statuses) < 0) {
 110:	f9040593          	addi	a1,s0,-112
 114:	f8c40513          	addi	a0,s0,-116
 118:	00000097          	auipc	ra,0x0
 11c:	42e080e7          	jalr	1070(ra) # 546 <waitall>
 120:	08054463          	bltz	a0,1a8 <main+0x1a8>
    for (int i = 0; i < n; i++) {
 124:	f8c42583          	lw	a1,-116(s0)
 128:	0ab05863          	blez	a1,1d8 <main+0x1d8>
 12c:	f9040913          	addi	s2,s0,-112
 130:	4481                	li	s1,0
    long long total = 0;
 132:	4981                	li	s3,0
      printf("statuses[%d] = %d\n", i, statuses[i]);
 134:	00001a17          	auipc	s4,0x1
 138:	92ca0a13          	addi	s4,s4,-1748 # a60 <malloc+0x174>
 13c:	00092603          	lw	a2,0(s2)
 140:	85a6                	mv	a1,s1
 142:	8552                	mv	a0,s4
 144:	00000097          	auipc	ra,0x0
 148:	6ea080e7          	jalr	1770(ra) # 82e <printf>
      total += (long long)statuses[i] ;
 14c:	00092783          	lw	a5,0(s2)
 150:	99be                	add	s3,s3,a5
    for (int i = 0; i < n; i++) {
 152:	2485                	addiw	s1,s1,1
 154:	f8c42583          	lw	a1,-116(s0)
 158:	0911                	addi	s2,s2,4
 15a:	feb4c1e3          	blt	s1,a1,13c <main+0x13c>
    printf("===> All %d children finished\n", n);
 15e:	00001517          	auipc	a0,0x1
 162:	91a50513          	addi	a0,a0,-1766 # a78 <malloc+0x18c>
 166:	00000097          	auipc	ra,0x0
 16a:	6c8080e7          	jalr	1736(ra) # 82e <printf>
    printf("Sum of all children's sums: %d\n", total);
 16e:	85ce                	mv	a1,s3
 170:	00001517          	auipc	a0,0x1
 174:	92850513          	addi	a0,a0,-1752 # a98 <malloc+0x1ac>
 178:	00000097          	auipc	ra,0x0
 17c:	6b6080e7          	jalr	1718(ra) # 82e <printf>
    if (total == expected) {
 180:	7fff87b7          	lui	a5,0x7fff8
 184:	02f98f63          	beq	s3,a5,1c2 <main+0x1c2>
      printf("Wrong total sum: %d (expected %d)\n", total, expected);
 188:	7fff8637          	lui	a2,0x7fff8
 18c:	85ce                	mv	a1,s3
 18e:	00001517          	auipc	a0,0x1
 192:	94250513          	addi	a0,a0,-1726 # ad0 <malloc+0x1e4>
 196:	00000097          	auipc	ra,0x0
 19a:	698080e7          	jalr	1688(ra) # 82e <printf>
    exit(0);
 19e:	4501                	li	a0,0
 1a0:	00000097          	auipc	ra,0x0
 1a4:	2ee080e7          	jalr	750(ra) # 48e <exit>
      printf("waitall failed\n");
 1a8:	00001517          	auipc	a0,0x1
 1ac:	8a850513          	addi	a0,a0,-1880 # a50 <malloc+0x164>
 1b0:	00000097          	auipc	ra,0x0
 1b4:	67e080e7          	jalr	1662(ra) # 82e <printf>
      exit(-1);
 1b8:	557d                	li	a0,-1
 1ba:	00000097          	auipc	ra,0x0
 1be:	2d4080e7          	jalr	724(ra) # 48e <exit>
      printf("Correct total sum: %d\n",total);
 1c2:	7fff85b7          	lui	a1,0x7fff8
 1c6:	00001517          	auipc	a0,0x1
 1ca:	8f250513          	addi	a0,a0,-1806 # ab8 <malloc+0x1cc>
 1ce:	00000097          	auipc	ra,0x0
 1d2:	660080e7          	jalr	1632(ra) # 82e <printf>
 1d6:	b7e1                	j	19e <main+0x19e>
    printf("===> All %d children finished\n", n);
 1d8:	00001517          	auipc	a0,0x1
 1dc:	8a050513          	addi	a0,a0,-1888 # a78 <malloc+0x18c>
 1e0:	00000097          	auipc	ra,0x0
 1e4:	64e080e7          	jalr	1614(ra) # 82e <printf>
    printf("Sum of all children's sums: %d\n", total);
 1e8:	4581                	li	a1,0
 1ea:	00001517          	auipc	a0,0x1
 1ee:	8ae50513          	addi	a0,a0,-1874 # a98 <malloc+0x1ac>
 1f2:	00000097          	auipc	ra,0x0
 1f6:	63c080e7          	jalr	1596(ra) # 82e <printf>
    long long total = 0;
 1fa:	4981                	li	s3,0
 1fc:	b771                	j	188 <main+0x188>

00000000000001fe <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e406                	sd	ra,8(sp)
 202:	e022                	sd	s0,0(sp)
 204:	0800                	addi	s0,sp,16
  extern int main();
  main();
 206:	00000097          	auipc	ra,0x0
 20a:	dfa080e7          	jalr	-518(ra) # 0 <main>
  exit(0);
 20e:	4501                	li	a0,0
 210:	00000097          	auipc	ra,0x0
 214:	27e080e7          	jalr	638(ra) # 48e <exit>

0000000000000218 <strcpy>:
}

char* strcpy(char *s, const char *t)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 21e:	87aa                	mv	a5,a0
 220:	0585                	addi	a1,a1,1
 222:	0785                	addi	a5,a5,1
 224:	fff5c703          	lbu	a4,-1(a1) # 7fff7fff <base+0x7fff6fef>
 228:	fee78fa3          	sb	a4,-1(a5) # 7fff7fff <base+0x7fff6fef>
 22c:	fb75                	bnez	a4,220 <strcpy+0x8>
    ;
  return os;
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret

0000000000000234 <strcmp>:

int strcmp(const char *p, const char *q)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 23a:	00054783          	lbu	a5,0(a0)
 23e:	cb91                	beqz	a5,252 <strcmp+0x1e>
 240:	0005c703          	lbu	a4,0(a1)
 244:	00f71763          	bne	a4,a5,252 <strcmp+0x1e>
    p++, q++;
 248:	0505                	addi	a0,a0,1
 24a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 24c:	00054783          	lbu	a5,0(a0)
 250:	fbe5                	bnez	a5,240 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 252:	0005c503          	lbu	a0,0(a1)
}
 256:	40a7853b          	subw	a0,a5,a0
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret

0000000000000260 <strlen>:

uint strlen(const char *s)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 266:	00054783          	lbu	a5,0(a0)
 26a:	cf91                	beqz	a5,286 <strlen+0x26>
 26c:	0505                	addi	a0,a0,1
 26e:	87aa                	mv	a5,a0
 270:	4685                	li	a3,1
 272:	9e89                	subw	a3,a3,a0
 274:	00f6853b          	addw	a0,a3,a5
 278:	0785                	addi	a5,a5,1
 27a:	fff7c703          	lbu	a4,-1(a5)
 27e:	fb7d                	bnez	a4,274 <strlen+0x14>
    ;
  return n;
}
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret
  for(n = 0; s[n]; n++)
 286:	4501                	li	a0,0
 288:	bfe5                	j	280 <strlen+0x20>

000000000000028a <memset>:

void* memset(void *dst, int c, uint n)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 290:	ce09                	beqz	a2,2aa <memset+0x20>
 292:	87aa                	mv	a5,a0
 294:	fff6071b          	addiw	a4,a2,-1
 298:	1702                	slli	a4,a4,0x20
 29a:	9301                	srli	a4,a4,0x20
 29c:	0705                	addi	a4,a4,1
 29e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 2a0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2a4:	0785                	addi	a5,a5,1
 2a6:	fee79de3          	bne	a5,a4,2a0 <memset+0x16>
  }
  return dst;
}
 2aa:	6422                	ld	s0,8(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret

00000000000002b0 <strchr>:

char* strchr(const char *s, char c)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e422                	sd	s0,8(sp)
 2b4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2b6:	00054783          	lbu	a5,0(a0)
 2ba:	cb99                	beqz	a5,2d0 <strchr+0x20>
    if(*s == c)
 2bc:	00f58763          	beq	a1,a5,2ca <strchr+0x1a>
  for(; *s; s++)
 2c0:	0505                	addi	a0,a0,1
 2c2:	00054783          	lbu	a5,0(a0)
 2c6:	fbfd                	bnez	a5,2bc <strchr+0xc>
      return (char*)s;
  return 0;
 2c8:	4501                	li	a0,0
}
 2ca:	6422                	ld	s0,8(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
  return 0;
 2d0:	4501                	li	a0,0
 2d2:	bfe5                	j	2ca <strchr+0x1a>

00000000000002d4 <gets>:

char* gets(char *buf, int max)
{
 2d4:	711d                	addi	sp,sp,-96
 2d6:	ec86                	sd	ra,88(sp)
 2d8:	e8a2                	sd	s0,80(sp)
 2da:	e4a6                	sd	s1,72(sp)
 2dc:	e0ca                	sd	s2,64(sp)
 2de:	fc4e                	sd	s3,56(sp)
 2e0:	f852                	sd	s4,48(sp)
 2e2:	f456                	sd	s5,40(sp)
 2e4:	f05a                	sd	s6,32(sp)
 2e6:	ec5e                	sd	s7,24(sp)
 2e8:	1080                	addi	s0,sp,96
 2ea:	8baa                	mv	s7,a0
 2ec:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ee:	892a                	mv	s2,a0
 2f0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2f2:	4aa9                	li	s5,10
 2f4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2f6:	89a6                	mv	s3,s1
 2f8:	2485                	addiw	s1,s1,1
 2fa:	0344d863          	bge	s1,s4,32a <gets+0x56>
    cc = read(0, &c, 1);
 2fe:	4605                	li	a2,1
 300:	faf40593          	addi	a1,s0,-81
 304:	4501                	li	a0,0
 306:	00000097          	auipc	ra,0x0
 30a:	1a8080e7          	jalr	424(ra) # 4ae <read>
    if(cc < 1)
 30e:	00a05e63          	blez	a0,32a <gets+0x56>
    buf[i++] = c;
 312:	faf44783          	lbu	a5,-81(s0)
 316:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 31a:	01578763          	beq	a5,s5,328 <gets+0x54>
 31e:	0905                	addi	s2,s2,1
 320:	fd679be3          	bne	a5,s6,2f6 <gets+0x22>
  for(i=0; i+1 < max; ){
 324:	89a6                	mv	s3,s1
 326:	a011                	j	32a <gets+0x56>
 328:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 32a:	99de                	add	s3,s3,s7
 32c:	00098023          	sb	zero,0(s3)
  return buf;
}
 330:	855e                	mv	a0,s7
 332:	60e6                	ld	ra,88(sp)
 334:	6446                	ld	s0,80(sp)
 336:	64a6                	ld	s1,72(sp)
 338:	6906                	ld	s2,64(sp)
 33a:	79e2                	ld	s3,56(sp)
 33c:	7a42                	ld	s4,48(sp)
 33e:	7aa2                	ld	s5,40(sp)
 340:	7b02                	ld	s6,32(sp)
 342:	6be2                	ld	s7,24(sp)
 344:	6125                	addi	sp,sp,96
 346:	8082                	ret

0000000000000348 <stat>:

int stat(const char *n, struct stat *st)
{
 348:	1101                	addi	sp,sp,-32
 34a:	ec06                	sd	ra,24(sp)
 34c:	e822                	sd	s0,16(sp)
 34e:	e426                	sd	s1,8(sp)
 350:	e04a                	sd	s2,0(sp)
 352:	1000                	addi	s0,sp,32
 354:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 356:	4581                	li	a1,0
 358:	00000097          	auipc	ra,0x0
 35c:	17e080e7          	jalr	382(ra) # 4d6 <open>
  if(fd < 0)
 360:	02054563          	bltz	a0,38a <stat+0x42>
 364:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 366:	85ca                	mv	a1,s2
 368:	00000097          	auipc	ra,0x0
 36c:	186080e7          	jalr	390(ra) # 4ee <fstat>
 370:	892a                	mv	s2,a0
  close(fd);
 372:	8526                	mv	a0,s1
 374:	00000097          	auipc	ra,0x0
 378:	14a080e7          	jalr	330(ra) # 4be <close>
  return r;
}
 37c:	854a                	mv	a0,s2
 37e:	60e2                	ld	ra,24(sp)
 380:	6442                	ld	s0,16(sp)
 382:	64a2                	ld	s1,8(sp)
 384:	6902                	ld	s2,0(sp)
 386:	6105                	addi	sp,sp,32
 388:	8082                	ret
    return -1;
 38a:	597d                	li	s2,-1
 38c:	bfc5                	j	37c <stat+0x34>

000000000000038e <atoi>:

int atoi(const char *s)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e422                	sd	s0,8(sp)
 392:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 394:	00054603          	lbu	a2,0(a0)
 398:	fd06079b          	addiw	a5,a2,-48
 39c:	0ff7f793          	andi	a5,a5,255
 3a0:	4725                	li	a4,9
 3a2:	02f76963          	bltu	a4,a5,3d4 <atoi+0x46>
 3a6:	86aa                	mv	a3,a0
  n = 0;
 3a8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3aa:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3ac:	0685                	addi	a3,a3,1
 3ae:	0025179b          	slliw	a5,a0,0x2
 3b2:	9fa9                	addw	a5,a5,a0
 3b4:	0017979b          	slliw	a5,a5,0x1
 3b8:	9fb1                	addw	a5,a5,a2
 3ba:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3be:	0006c603          	lbu	a2,0(a3)
 3c2:	fd06071b          	addiw	a4,a2,-48
 3c6:	0ff77713          	andi	a4,a4,255
 3ca:	fee5f1e3          	bgeu	a1,a4,3ac <atoi+0x1e>
  return n;
}
 3ce:	6422                	ld	s0,8(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret
  n = 0;
 3d4:	4501                	li	a0,0
 3d6:	bfe5                	j	3ce <atoi+0x40>

00000000000003d8 <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e422                	sd	s0,8(sp)
 3dc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3de:	02b57663          	bgeu	a0,a1,40a <memmove+0x32>
    while(n-- > 0)
 3e2:	02c05163          	blez	a2,404 <memmove+0x2c>
 3e6:	fff6079b          	addiw	a5,a2,-1
 3ea:	1782                	slli	a5,a5,0x20
 3ec:	9381                	srli	a5,a5,0x20
 3ee:	0785                	addi	a5,a5,1
 3f0:	97aa                	add	a5,a5,a0
  dst = vdst;
 3f2:	872a                	mv	a4,a0
      *dst++ = *src++;
 3f4:	0585                	addi	a1,a1,1
 3f6:	0705                	addi	a4,a4,1
 3f8:	fff5c683          	lbu	a3,-1(a1)
 3fc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 400:	fee79ae3          	bne	a5,a4,3f4 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 404:	6422                	ld	s0,8(sp)
 406:	0141                	addi	sp,sp,16
 408:	8082                	ret
    dst += n;
 40a:	00c50733          	add	a4,a0,a2
    src += n;
 40e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 410:	fec05ae3          	blez	a2,404 <memmove+0x2c>
 414:	fff6079b          	addiw	a5,a2,-1
 418:	1782                	slli	a5,a5,0x20
 41a:	9381                	srli	a5,a5,0x20
 41c:	fff7c793          	not	a5,a5
 420:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 422:	15fd                	addi	a1,a1,-1
 424:	177d                	addi	a4,a4,-1
 426:	0005c683          	lbu	a3,0(a1)
 42a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 42e:	fee79ae3          	bne	a5,a4,422 <memmove+0x4a>
 432:	bfc9                	j	404 <memmove+0x2c>

0000000000000434 <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 434:	1141                	addi	sp,sp,-16
 436:	e422                	sd	s0,8(sp)
 438:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 43a:	ca05                	beqz	a2,46a <memcmp+0x36>
 43c:	fff6069b          	addiw	a3,a2,-1
 440:	1682                	slli	a3,a3,0x20
 442:	9281                	srli	a3,a3,0x20
 444:	0685                	addi	a3,a3,1
 446:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 448:	00054783          	lbu	a5,0(a0)
 44c:	0005c703          	lbu	a4,0(a1)
 450:	00e79863          	bne	a5,a4,460 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 454:	0505                	addi	a0,a0,1
    p2++;
 456:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 458:	fed518e3          	bne	a0,a3,448 <memcmp+0x14>
  }
  return 0;
 45c:	4501                	li	a0,0
 45e:	a019                	j	464 <memcmp+0x30>
      return *p1 - *p2;
 460:	40e7853b          	subw	a0,a5,a4
}
 464:	6422                	ld	s0,8(sp)
 466:	0141                	addi	sp,sp,16
 468:	8082                	ret
  return 0;
 46a:	4501                	li	a0,0
 46c:	bfe5                	j	464 <memcmp+0x30>

000000000000046e <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 46e:	1141                	addi	sp,sp,-16
 470:	e406                	sd	ra,8(sp)
 472:	e022                	sd	s0,0(sp)
 474:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 476:	00000097          	auipc	ra,0x0
 47a:	f62080e7          	jalr	-158(ra) # 3d8 <memmove>
}
 47e:	60a2                	ld	ra,8(sp)
 480:	6402                	ld	s0,0(sp)
 482:	0141                	addi	sp,sp,16
 484:	8082                	ret

0000000000000486 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 486:	4885                	li	a7,1
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <exit>:
.global exit
exit:
 li a7, SYS_exit
 48e:	4889                	li	a7,2
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 496:	48e1                	li	a7,24
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <wait>:
.global wait
wait:
 li a7, SYS_wait
 49e:	488d                	li	a7,3
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4a6:	4891                	li	a7,4
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <read>:
.global read
read:
 li a7, SYS_read
 4ae:	4895                	li	a7,5
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <write>:
.global write
write:
 li a7, SYS_write
 4b6:	48c1                	li	a7,16
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <close>:
.global close
close:
 li a7, SYS_close
 4be:	48d5                	li	a7,21
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4c6:	4899                	li	a7,6
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ce:	489d                	li	a7,7
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <open>:
.global open
open:
 li a7, SYS_open
 4d6:	48bd                	li	a7,15
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4de:	48c5                	li	a7,17
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4e6:	48c9                	li	a7,18
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4ee:	48a1                	li	a7,8
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <link>:
.global link
link:
 li a7, SYS_link
 4f6:	48cd                	li	a7,19
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4fe:	48d1                	li	a7,20
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 506:	48a5                	li	a7,9
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <dup>:
.global dup
dup:
 li a7, SYS_dup
 50e:	48a9                	li	a7,10
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 516:	48ad                	li	a7,11
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 51e:	48b1                	li	a7,12
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 526:	48b5                	li	a7,13
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 52e:	48b9                	li	a7,14
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 536:	48dd                	li	a7,23
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 53e:	48e5                	li	a7,25
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 546:	48e9                	li	a7,26
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 54e:	48ed                	li	a7,27
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 556:	1101                	addi	sp,sp,-32
 558:	ec06                	sd	ra,24(sp)
 55a:	e822                	sd	s0,16(sp)
 55c:	1000                	addi	s0,sp,32
 55e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 562:	4605                	li	a2,1
 564:	fef40593          	addi	a1,s0,-17
 568:	00000097          	auipc	ra,0x0
 56c:	f4e080e7          	jalr	-178(ra) # 4b6 <write>
}
 570:	60e2                	ld	ra,24(sp)
 572:	6442                	ld	s0,16(sp)
 574:	6105                	addi	sp,sp,32
 576:	8082                	ret

0000000000000578 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 578:	7139                	addi	sp,sp,-64
 57a:	fc06                	sd	ra,56(sp)
 57c:	f822                	sd	s0,48(sp)
 57e:	f426                	sd	s1,40(sp)
 580:	f04a                	sd	s2,32(sp)
 582:	ec4e                	sd	s3,24(sp)
 584:	0080                	addi	s0,sp,64
 586:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 588:	c299                	beqz	a3,58e <printint+0x16>
 58a:	0805c863          	bltz	a1,61a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 58e:	2581                	sext.w	a1,a1
  neg = 0;
 590:	4881                	li	a7,0
 592:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 596:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 598:	2601                	sext.w	a2,a2
 59a:	00000517          	auipc	a0,0x0
 59e:	56650513          	addi	a0,a0,1382 # b00 <digits>
 5a2:	883a                	mv	a6,a4
 5a4:	2705                	addiw	a4,a4,1
 5a6:	02c5f7bb          	remuw	a5,a1,a2
 5aa:	1782                	slli	a5,a5,0x20
 5ac:	9381                	srli	a5,a5,0x20
 5ae:	97aa                	add	a5,a5,a0
 5b0:	0007c783          	lbu	a5,0(a5)
 5b4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5b8:	0005879b          	sext.w	a5,a1
 5bc:	02c5d5bb          	divuw	a1,a1,a2
 5c0:	0685                	addi	a3,a3,1
 5c2:	fec7f0e3          	bgeu	a5,a2,5a2 <printint+0x2a>
  if(neg)
 5c6:	00088b63          	beqz	a7,5dc <printint+0x64>
    buf[i++] = '-';
 5ca:	fd040793          	addi	a5,s0,-48
 5ce:	973e                	add	a4,a4,a5
 5d0:	02d00793          	li	a5,45
 5d4:	fef70823          	sb	a5,-16(a4)
 5d8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5dc:	02e05863          	blez	a4,60c <printint+0x94>
 5e0:	fc040793          	addi	a5,s0,-64
 5e4:	00e78933          	add	s2,a5,a4
 5e8:	fff78993          	addi	s3,a5,-1
 5ec:	99ba                	add	s3,s3,a4
 5ee:	377d                	addiw	a4,a4,-1
 5f0:	1702                	slli	a4,a4,0x20
 5f2:	9301                	srli	a4,a4,0x20
 5f4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5f8:	fff94583          	lbu	a1,-1(s2)
 5fc:	8526                	mv	a0,s1
 5fe:	00000097          	auipc	ra,0x0
 602:	f58080e7          	jalr	-168(ra) # 556 <putc>
  while(--i >= 0)
 606:	197d                	addi	s2,s2,-1
 608:	ff3918e3          	bne	s2,s3,5f8 <printint+0x80>
}
 60c:	70e2                	ld	ra,56(sp)
 60e:	7442                	ld	s0,48(sp)
 610:	74a2                	ld	s1,40(sp)
 612:	7902                	ld	s2,32(sp)
 614:	69e2                	ld	s3,24(sp)
 616:	6121                	addi	sp,sp,64
 618:	8082                	ret
    x = -xx;
 61a:	40b005bb          	negw	a1,a1
    neg = 1;
 61e:	4885                	li	a7,1
    x = -xx;
 620:	bf8d                	j	592 <printint+0x1a>

0000000000000622 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 622:	7119                	addi	sp,sp,-128
 624:	fc86                	sd	ra,120(sp)
 626:	f8a2                	sd	s0,112(sp)
 628:	f4a6                	sd	s1,104(sp)
 62a:	f0ca                	sd	s2,96(sp)
 62c:	ecce                	sd	s3,88(sp)
 62e:	e8d2                	sd	s4,80(sp)
 630:	e4d6                	sd	s5,72(sp)
 632:	e0da                	sd	s6,64(sp)
 634:	fc5e                	sd	s7,56(sp)
 636:	f862                	sd	s8,48(sp)
 638:	f466                	sd	s9,40(sp)
 63a:	f06a                	sd	s10,32(sp)
 63c:	ec6e                	sd	s11,24(sp)
 63e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 640:	0005c903          	lbu	s2,0(a1)
 644:	18090f63          	beqz	s2,7e2 <vprintf+0x1c0>
 648:	8aaa                	mv	s5,a0
 64a:	8b32                	mv	s6,a2
 64c:	00158493          	addi	s1,a1,1
  state = 0;
 650:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 652:	02500a13          	li	s4,37
      if(c == 'd'){
 656:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 65a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 65e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 662:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 666:	00000b97          	auipc	s7,0x0
 66a:	49ab8b93          	addi	s7,s7,1178 # b00 <digits>
 66e:	a839                	j	68c <vprintf+0x6a>
        putc(fd, c);
 670:	85ca                	mv	a1,s2
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	ee2080e7          	jalr	-286(ra) # 556 <putc>
 67c:	a019                	j	682 <vprintf+0x60>
    } else if(state == '%'){
 67e:	01498f63          	beq	s3,s4,69c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 682:	0485                	addi	s1,s1,1
 684:	fff4c903          	lbu	s2,-1(s1)
 688:	14090d63          	beqz	s2,7e2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 68c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 690:	fe0997e3          	bnez	s3,67e <vprintf+0x5c>
      if(c == '%'){
 694:	fd479ee3          	bne	a5,s4,670 <vprintf+0x4e>
        state = '%';
 698:	89be                	mv	s3,a5
 69a:	b7e5                	j	682 <vprintf+0x60>
      if(c == 'd'){
 69c:	05878063          	beq	a5,s8,6dc <vprintf+0xba>
      } else if(c == 'l') {
 6a0:	05978c63          	beq	a5,s9,6f8 <vprintf+0xd6>
      } else if(c == 'x') {
 6a4:	07a78863          	beq	a5,s10,714 <vprintf+0xf2>
      } else if(c == 'p') {
 6a8:	09b78463          	beq	a5,s11,730 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6ac:	07300713          	li	a4,115
 6b0:	0ce78663          	beq	a5,a4,77c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6b4:	06300713          	li	a4,99
 6b8:	0ee78e63          	beq	a5,a4,7b4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6bc:	11478863          	beq	a5,s4,7cc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6c0:	85d2                	mv	a1,s4
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	e92080e7          	jalr	-366(ra) # 556 <putc>
        putc(fd, c);
 6cc:	85ca                	mv	a1,s2
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e86080e7          	jalr	-378(ra) # 556 <putc>
      }
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	b765                	j	682 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6dc:	008b0913          	addi	s2,s6,8
 6e0:	4685                	li	a3,1
 6e2:	4629                	li	a2,10
 6e4:	000b2583          	lw	a1,0(s6)
 6e8:	8556                	mv	a0,s5
 6ea:	00000097          	auipc	ra,0x0
 6ee:	e8e080e7          	jalr	-370(ra) # 578 <printint>
 6f2:	8b4a                	mv	s6,s2
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	b771                	j	682 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f8:	008b0913          	addi	s2,s6,8
 6fc:	4681                	li	a3,0
 6fe:	4629                	li	a2,10
 700:	000b2583          	lw	a1,0(s6)
 704:	8556                	mv	a0,s5
 706:	00000097          	auipc	ra,0x0
 70a:	e72080e7          	jalr	-398(ra) # 578 <printint>
 70e:	8b4a                	mv	s6,s2
      state = 0;
 710:	4981                	li	s3,0
 712:	bf85                	j	682 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 714:	008b0913          	addi	s2,s6,8
 718:	4681                	li	a3,0
 71a:	4641                	li	a2,16
 71c:	000b2583          	lw	a1,0(s6)
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	e56080e7          	jalr	-426(ra) # 578 <printint>
 72a:	8b4a                	mv	s6,s2
      state = 0;
 72c:	4981                	li	s3,0
 72e:	bf91                	j	682 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 730:	008b0793          	addi	a5,s6,8
 734:	f8f43423          	sd	a5,-120(s0)
 738:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 73c:	03000593          	li	a1,48
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	e14080e7          	jalr	-492(ra) # 556 <putc>
  putc(fd, 'x');
 74a:	85ea                	mv	a1,s10
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	e08080e7          	jalr	-504(ra) # 556 <putc>
 756:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 758:	03c9d793          	srli	a5,s3,0x3c
 75c:	97de                	add	a5,a5,s7
 75e:	0007c583          	lbu	a1,0(a5)
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	df2080e7          	jalr	-526(ra) # 556 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 76c:	0992                	slli	s3,s3,0x4
 76e:	397d                	addiw	s2,s2,-1
 770:	fe0914e3          	bnez	s2,758 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 774:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 778:	4981                	li	s3,0
 77a:	b721                	j	682 <vprintf+0x60>
        s = va_arg(ap, char*);
 77c:	008b0993          	addi	s3,s6,8
 780:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 784:	02090163          	beqz	s2,7a6 <vprintf+0x184>
        while(*s != 0){
 788:	00094583          	lbu	a1,0(s2)
 78c:	c9a1                	beqz	a1,7dc <vprintf+0x1ba>
          putc(fd, *s);
 78e:	8556                	mv	a0,s5
 790:	00000097          	auipc	ra,0x0
 794:	dc6080e7          	jalr	-570(ra) # 556 <putc>
          s++;
 798:	0905                	addi	s2,s2,1
        while(*s != 0){
 79a:	00094583          	lbu	a1,0(s2)
 79e:	f9e5                	bnez	a1,78e <vprintf+0x16c>
        s = va_arg(ap, char*);
 7a0:	8b4e                	mv	s6,s3
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	bdf9                	j	682 <vprintf+0x60>
          s = "(null)";
 7a6:	00000917          	auipc	s2,0x0
 7aa:	35290913          	addi	s2,s2,850 # af8 <malloc+0x20c>
        while(*s != 0){
 7ae:	02800593          	li	a1,40
 7b2:	bff1                	j	78e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7b4:	008b0913          	addi	s2,s6,8
 7b8:	000b4583          	lbu	a1,0(s6)
 7bc:	8556                	mv	a0,s5
 7be:	00000097          	auipc	ra,0x0
 7c2:	d98080e7          	jalr	-616(ra) # 556 <putc>
 7c6:	8b4a                	mv	s6,s2
      state = 0;
 7c8:	4981                	li	s3,0
 7ca:	bd65                	j	682 <vprintf+0x60>
        putc(fd, c);
 7cc:	85d2                	mv	a1,s4
 7ce:	8556                	mv	a0,s5
 7d0:	00000097          	auipc	ra,0x0
 7d4:	d86080e7          	jalr	-634(ra) # 556 <putc>
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	b565                	j	682 <vprintf+0x60>
        s = va_arg(ap, char*);
 7dc:	8b4e                	mv	s6,s3
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	b54d                	j	682 <vprintf+0x60>
    }
  }
}
 7e2:	70e6                	ld	ra,120(sp)
 7e4:	7446                	ld	s0,112(sp)
 7e6:	74a6                	ld	s1,104(sp)
 7e8:	7906                	ld	s2,96(sp)
 7ea:	69e6                	ld	s3,88(sp)
 7ec:	6a46                	ld	s4,80(sp)
 7ee:	6aa6                	ld	s5,72(sp)
 7f0:	6b06                	ld	s6,64(sp)
 7f2:	7be2                	ld	s7,56(sp)
 7f4:	7c42                	ld	s8,48(sp)
 7f6:	7ca2                	ld	s9,40(sp)
 7f8:	7d02                	ld	s10,32(sp)
 7fa:	6de2                	ld	s11,24(sp)
 7fc:	6109                	addi	sp,sp,128
 7fe:	8082                	ret

0000000000000800 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 800:	715d                	addi	sp,sp,-80
 802:	ec06                	sd	ra,24(sp)
 804:	e822                	sd	s0,16(sp)
 806:	1000                	addi	s0,sp,32
 808:	e010                	sd	a2,0(s0)
 80a:	e414                	sd	a3,8(s0)
 80c:	e818                	sd	a4,16(s0)
 80e:	ec1c                	sd	a5,24(s0)
 810:	03043023          	sd	a6,32(s0)
 814:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 818:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 81c:	8622                	mv	a2,s0
 81e:	00000097          	auipc	ra,0x0
 822:	e04080e7          	jalr	-508(ra) # 622 <vprintf>
}
 826:	60e2                	ld	ra,24(sp)
 828:	6442                	ld	s0,16(sp)
 82a:	6161                	addi	sp,sp,80
 82c:	8082                	ret

000000000000082e <printf>:

void
printf(const char *fmt, ...)
{
 82e:	711d                	addi	sp,sp,-96
 830:	ec06                	sd	ra,24(sp)
 832:	e822                	sd	s0,16(sp)
 834:	1000                	addi	s0,sp,32
 836:	e40c                	sd	a1,8(s0)
 838:	e810                	sd	a2,16(s0)
 83a:	ec14                	sd	a3,24(s0)
 83c:	f018                	sd	a4,32(s0)
 83e:	f41c                	sd	a5,40(s0)
 840:	03043823          	sd	a6,48(s0)
 844:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 848:	00840613          	addi	a2,s0,8
 84c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 850:	85aa                	mv	a1,a0
 852:	4505                	li	a0,1
 854:	00000097          	auipc	ra,0x0
 858:	dce080e7          	jalr	-562(ra) # 622 <vprintf>
}
 85c:	60e2                	ld	ra,24(sp)
 85e:	6442                	ld	s0,16(sp)
 860:	6125                	addi	sp,sp,96
 862:	8082                	ret

0000000000000864 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 864:	1141                	addi	sp,sp,-16
 866:	e422                	sd	s0,8(sp)
 868:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 86a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86e:	00000797          	auipc	a5,0x0
 872:	7927b783          	ld	a5,1938(a5) # 1000 <freep>
 876:	a805                	j	8a6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 878:	4618                	lw	a4,8(a2)
 87a:	9db9                	addw	a1,a1,a4
 87c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 880:	6398                	ld	a4,0(a5)
 882:	6318                	ld	a4,0(a4)
 884:	fee53823          	sd	a4,-16(a0)
 888:	a091                	j	8cc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 88a:	ff852703          	lw	a4,-8(a0)
 88e:	9e39                	addw	a2,a2,a4
 890:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 892:	ff053703          	ld	a4,-16(a0)
 896:	e398                	sd	a4,0(a5)
 898:	a099                	j	8de <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 89a:	6398                	ld	a4,0(a5)
 89c:	00e7e463          	bltu	a5,a4,8a4 <free+0x40>
 8a0:	00e6ea63          	bltu	a3,a4,8b4 <free+0x50>
{
 8a4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a6:	fed7fae3          	bgeu	a5,a3,89a <free+0x36>
 8aa:	6398                	ld	a4,0(a5)
 8ac:	00e6e463          	bltu	a3,a4,8b4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b0:	fee7eae3          	bltu	a5,a4,8a4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8b4:	ff852583          	lw	a1,-8(a0)
 8b8:	6390                	ld	a2,0(a5)
 8ba:	02059713          	slli	a4,a1,0x20
 8be:	9301                	srli	a4,a4,0x20
 8c0:	0712                	slli	a4,a4,0x4
 8c2:	9736                	add	a4,a4,a3
 8c4:	fae60ae3          	beq	a2,a4,878 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8c8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8cc:	4790                	lw	a2,8(a5)
 8ce:	02061713          	slli	a4,a2,0x20
 8d2:	9301                	srli	a4,a4,0x20
 8d4:	0712                	slli	a4,a4,0x4
 8d6:	973e                	add	a4,a4,a5
 8d8:	fae689e3          	beq	a3,a4,88a <free+0x26>
  } else
    p->s.ptr = bp;
 8dc:	e394                	sd	a3,0(a5)
  freep = p;
 8de:	00000717          	auipc	a4,0x0
 8e2:	72f73123          	sd	a5,1826(a4) # 1000 <freep>
}
 8e6:	6422                	ld	s0,8(sp)
 8e8:	0141                	addi	sp,sp,16
 8ea:	8082                	ret

00000000000008ec <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ec:	7139                	addi	sp,sp,-64
 8ee:	fc06                	sd	ra,56(sp)
 8f0:	f822                	sd	s0,48(sp)
 8f2:	f426                	sd	s1,40(sp)
 8f4:	f04a                	sd	s2,32(sp)
 8f6:	ec4e                	sd	s3,24(sp)
 8f8:	e852                	sd	s4,16(sp)
 8fa:	e456                	sd	s5,8(sp)
 8fc:	e05a                	sd	s6,0(sp)
 8fe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 900:	02051493          	slli	s1,a0,0x20
 904:	9081                	srli	s1,s1,0x20
 906:	04bd                	addi	s1,s1,15
 908:	8091                	srli	s1,s1,0x4
 90a:	0014899b          	addiw	s3,s1,1
 90e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 910:	00000517          	auipc	a0,0x0
 914:	6f053503          	ld	a0,1776(a0) # 1000 <freep>
 918:	c515                	beqz	a0,944 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 91c:	4798                	lw	a4,8(a5)
 91e:	02977f63          	bgeu	a4,s1,95c <malloc+0x70>
 922:	8a4e                	mv	s4,s3
 924:	0009871b          	sext.w	a4,s3
 928:	6685                	lui	a3,0x1
 92a:	00d77363          	bgeu	a4,a3,930 <malloc+0x44>
 92e:	6a05                	lui	s4,0x1
 930:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 934:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 938:	00000917          	auipc	s2,0x0
 93c:	6c890913          	addi	s2,s2,1736 # 1000 <freep>
  if(p == (char*)-1)
 940:	5afd                	li	s5,-1
 942:	a88d                	j	9b4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 944:	00000797          	auipc	a5,0x0
 948:	6cc78793          	addi	a5,a5,1740 # 1010 <base>
 94c:	00000717          	auipc	a4,0x0
 950:	6af73a23          	sd	a5,1716(a4) # 1000 <freep>
 954:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 956:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 95a:	b7e1                	j	922 <malloc+0x36>
      if(p->s.size == nunits)
 95c:	02e48b63          	beq	s1,a4,992 <malloc+0xa6>
        p->s.size -= nunits;
 960:	4137073b          	subw	a4,a4,s3
 964:	c798                	sw	a4,8(a5)
        p += p->s.size;
 966:	1702                	slli	a4,a4,0x20
 968:	9301                	srli	a4,a4,0x20
 96a:	0712                	slli	a4,a4,0x4
 96c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 96e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 972:	00000717          	auipc	a4,0x0
 976:	68a73723          	sd	a0,1678(a4) # 1000 <freep>
      return (void*)(p + 1);
 97a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 97e:	70e2                	ld	ra,56(sp)
 980:	7442                	ld	s0,48(sp)
 982:	74a2                	ld	s1,40(sp)
 984:	7902                	ld	s2,32(sp)
 986:	69e2                	ld	s3,24(sp)
 988:	6a42                	ld	s4,16(sp)
 98a:	6aa2                	ld	s5,8(sp)
 98c:	6b02                	ld	s6,0(sp)
 98e:	6121                	addi	sp,sp,64
 990:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 992:	6398                	ld	a4,0(a5)
 994:	e118                	sd	a4,0(a0)
 996:	bff1                	j	972 <malloc+0x86>
  hp->s.size = nu;
 998:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 99c:	0541                	addi	a0,a0,16
 99e:	00000097          	auipc	ra,0x0
 9a2:	ec6080e7          	jalr	-314(ra) # 864 <free>
  return freep;
 9a6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9aa:	d971                	beqz	a0,97e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ae:	4798                	lw	a4,8(a5)
 9b0:	fa9776e3          	bgeu	a4,s1,95c <malloc+0x70>
    if(p == freep)
 9b4:	00093703          	ld	a4,0(s2)
 9b8:	853e                	mv	a0,a5
 9ba:	fef719e3          	bne	a4,a5,9ac <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9be:	8552                	mv	a0,s4
 9c0:	00000097          	auipc	ra,0x0
 9c4:	b5e080e7          	jalr	-1186(ra) # 51e <sbrk>
  if(p == (char*)-1)
 9c8:	fd5518e3          	bne	a0,s5,998 <malloc+0xac>
        return 0;
 9cc:	4501                	li	a0,0
 9ce:	bf45                	j	97e <malloc+0x92>
