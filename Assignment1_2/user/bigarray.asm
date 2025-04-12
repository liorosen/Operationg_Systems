
user/_bigarray:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <itoa>:
#define NUM_CHILDREN 4
#define CHUNK_SIZE (SIZE / NUM_CHILDREN)  // 16384 elements per child


// Simple function to convert integer to string
void itoa(int num, char *str) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  int i = 0;
  int is_negative = 0;

  if (num == 0) {
   6:	c93d                	beqz	a0,7c <itoa+0x7c>
  int is_negative = 0;
   8:	4301                	li	t1,0
    str[i++] = '0';
    str[i] = '\0';
    return;
  }

  if (num < 0) {
   a:	08054063          	bltz	a0,8a <itoa+0x8a>
    is_negative = 1;
    num = -num;
  }

  while (num != 0) {
   e:	872e                	mv	a4,a1
  int is_negative = 0;
  10:	862e                	mv	a2,a1
  12:	4781                	li	a5,0
    str[i++] = (num % 10) + '0';
  14:	4829                	li	a6,10
  16:	88be                	mv	a7,a5
  18:	2785                	addiw	a5,a5,1
  1a:	030566bb          	remw	a3,a0,a6
  1e:	0306869b          	addiw	a3,a3,48
  22:	00d60023          	sb	a3,0(a2)
    num = num / 10;
  26:	0305453b          	divw	a0,a0,a6
  while (num != 0) {
  2a:	0605                	addi	a2,a2,1
  2c:	f56d                	bnez	a0,16 <itoa+0x16>
  }

  if (is_negative) {
  2e:	00030963          	beqz	t1,40 <itoa+0x40>
    str[i++] = '-';
  32:	97ae                	add	a5,a5,a1
  34:	02d00693          	li	a3,45
  38:	00d78023          	sb	a3,0(a5)
  3c:	0028879b          	addiw	a5,a7,2
  }

  str[i] = '\0';
  40:	00f586b3          	add	a3,a1,a5
  44:	00068023          	sb	zero,0(a3)

  // Reverse the string
  int j;
  for (j = 0; j < i/2; j++) {
  48:	01f7d61b          	srliw	a2,a5,0x1f
  4c:	9e3d                	addw	a2,a2,a5
  4e:	4016561b          	sraiw	a2,a2,0x1
  52:	4685                	li	a3,1
  54:	02f6d163          	bge	a3,a5,76 <itoa+0x76>
  58:	17fd                	addi	a5,a5,-1
  5a:	95be                	add	a1,a1,a5
    char temp = str[j];
  5c:	00074783          	lbu	a5,0(a4)
    str[j] = str[i-1-j];
  60:	0005c683          	lbu	a3,0(a1)
  64:	00d70023          	sb	a3,0(a4)
    str[i-1-j] = temp;
  68:	00f58023          	sb	a5,0(a1)
  for (j = 0; j < i/2; j++) {
  6c:	2505                	addiw	a0,a0,1
  6e:	0705                	addi	a4,a4,1
  70:	15fd                	addi	a1,a1,-1
  72:	fec545e3          	blt	a0,a2,5c <itoa+0x5c>
  }
}
  76:	6422                	ld	s0,8(sp)
  78:	0141                	addi	sp,sp,16
  7a:	8082                	ret
    str[i++] = '0';
  7c:	03000793          	li	a5,48
  80:	00f58023          	sb	a5,0(a1)
    str[i] = '\0';
  84:	000580a3          	sb	zero,1(a1)
    return;
  88:	b7fd                	j	76 <itoa+0x76>
    num = -num;
  8a:	40a0053b          	negw	a0,a0
    is_negative = 1;
  8e:	4305                	li	t1,1
  90:	bfbd                	j	e <itoa+0xe>

0000000000000092 <str_append>:

// Simple string concatenation
void str_append(char *dest, const char *src) {
  92:	1141                	addi	sp,sp,-16
  94:	e422                	sd	s0,8(sp)
  96:	0800                	addi	s0,sp,16
  while (*dest) dest++;
  98:	00054783          	lbu	a5,0(a0)
  9c:	c789                	beqz	a5,a6 <str_append+0x14>
  9e:	0505                	addi	a0,a0,1
  a0:	00054783          	lbu	a5,0(a0)
  a4:	ffed                	bnez	a5,9e <str_append+0xc>
  while ((*dest++ = *src++));
  a6:	0585                	addi	a1,a1,1
  a8:	0505                	addi	a0,a0,1
  aa:	fff5c783          	lbu	a5,-1(a1)
  ae:	fef50fa3          	sb	a5,-1(a0)
  b2:	fbf5                	bnez	a5,a6 <str_append+0x14>
  *--dest = '\0';
}
  b4:	6422                	ld	s0,8(sp)
  b6:	0141                	addi	sp,sp,16
  b8:	8082                	ret

00000000000000ba <main>:

int main() {
  ba:	7155                	addi	sp,sp,-208
  bc:	e586                	sd	ra,200(sp)
  be:	e1a2                	sd	s0,192(sp)
  c0:	fd26                	sd	s1,184(sp)
  c2:	f94a                	sd	s2,176(sp)
  c4:	f54e                	sd	s3,168(sp)
  c6:	0980                	addi	s0,sp,208
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);
  c8:	4591                	li	a1,4
  ca:	00001517          	auipc	a0,0x1
  ce:	a2650513          	addi	a0,a0,-1498 # af0 <malloc+0xf2>
  d2:	00001097          	auipc	ra,0x1
  d6:	86e080e7          	jalr	-1938(ra) # 940 <printf>

  int pids[NUM_CHILDREN];
  int statuses[NUM_CHILDREN];
  int n = NUM_CHILDREN;
  da:	4791                	li	a5,4
  dc:	faf42623          	sw	a5,-84(s0)

  // Custom system call forkn to create child processes
  int ret = forkn(NUM_CHILDREN, pids);
  e0:	fc040593          	addi	a1,s0,-64
  e4:	4511                	li	a0,4
  e6:	00000097          	auipc	ra,0x0
  ea:	56a080e7          	jalr	1386(ra) # 650 <forkn>
  
  if (ret == -1) {
  ee:	57fd                	li	a5,-1
  f0:	02f50363          	beq	a0,a5,116 <main+0x5c>
  f4:	84aa                	mv	s1,a0
    printf("forkn failed\n");
    exit(-1);
  } else if (ret >= 0 && ret < NUM_CHILDREN) { // Child process (returns 0 to n-1)
  f6:	0005079b          	sext.w	a5,a0
  fa:	470d                	li	a4,3
  fc:	02f77a63          	bgeu	a4,a5,130 <main+0x76>
      p++;
    }
    
    write(1, msg, len);
    exit((int)sum);
  } else if (ret == -2) { // Parent process
 100:	57f9                	li	a5,-2
 102:	12f50063          	beq	a0,a5,222 <main+0x168>
    }

    exit(0);
  }
  return 0;
}
 106:	4501                	li	a0,0
 108:	60ae                	ld	ra,200(sp)
 10a:	640e                	ld	s0,192(sp)
 10c:	74ea                	ld	s1,184(sp)
 10e:	794a                	ld	s2,176(sp)
 110:	79aa                	ld	s3,168(sp)
 112:	6169                	addi	sp,sp,208
 114:	8082                	ret
    printf("forkn failed\n");
 116:	00001517          	auipc	a0,0x1
 11a:	9fa50513          	addi	a0,a0,-1542 # b10 <malloc+0x112>
 11e:	00001097          	auipc	ra,0x1
 122:	822080e7          	jalr	-2014(ra) # 940 <printf>
    exit(-1);
 126:	557d                	li	a0,-1
 128:	00000097          	auipc	ra,0x0
 12c:	478080e7          	jalr	1144(ra) # 5a0 <exit>
    long long start = ret * CHUNK_SIZE;
 130:	00e5169b          	slliw	a3,a0,0xe
 134:	0006879b          	sext.w	a5,a3
    long long end = (ret + 1) * CHUNK_SIZE;
 138:	6711                	lui	a4,0x4
 13a:	9f35                	addw	a4,a4,a3
    for (long long i = start + 1; i <= end; i++) {
 13c:	0785                	addi	a5,a5,1
    long long sum = 0;
 13e:	4901                	li	s2,0
    for (long long i = start + 1; i <= end; i++) {
 140:	a019                	j	146 <main+0x8c>
      sum += i;
 142:	993e                	add	s2,s2,a5
    for (long long i = start + 1; i <= end; i++) {
 144:	0785                	addi	a5,a5,1
 146:	fef75ee3          	bge	a4,a5,142 <main+0x88>
    for (int i = 0; i < ret; i++) {
 14a:	4981                	li	s3,0
 14c:	a801                	j	15c <main+0xa2>
      sleep(50);  // Sleep longer to ensure clear separation
 14e:	03200513          	li	a0,50
 152:	00000097          	auipc	ra,0x0
 156:	4e6080e7          	jalr	1254(ra) # 638 <sleep>
    for (int i = 0; i < ret; i++) {
 15a:	2985                	addiw	s3,s3,1
 15c:	fe9999e3          	bne	s3,s1,14e <main+0x94>
    char msg[100] = "Child ";
 160:	00001797          	auipc	a5,0x1
 164:	aa878793          	addi	a5,a5,-1368 # c08 <malloc+0x20a>
 168:	4398                	lw	a4,0(a5)
 16a:	f4e42423          	sw	a4,-184(s0)
 16e:	0047d703          	lhu	a4,4(a5)
 172:	f4e41623          	sh	a4,-180(s0)
 176:	0067c783          	lbu	a5,6(a5)
 17a:	f4f40723          	sb	a5,-178(s0)
 17e:	05d00613          	li	a2,93
 182:	4581                	li	a1,0
 184:	f4f40513          	addi	a0,s0,-177
 188:	00000097          	auipc	ra,0x0
 18c:	214080e7          	jalr	532(ra) # 39c <memset>
    itoa(ret, num);
 190:	f3040593          	addi	a1,s0,-208
 194:	8526                	mv	a0,s1
 196:	00000097          	auipc	ra,0x0
 19a:	e6a080e7          	jalr	-406(ra) # 0 <itoa>
    str_append(msg, num);
 19e:	f3040593          	addi	a1,s0,-208
 1a2:	f4840513          	addi	a0,s0,-184
 1a6:	00000097          	auipc	ra,0x0
 1aa:	eec080e7          	jalr	-276(ra) # 92 <str_append>
    str_append(msg, " calculated sum: ");
 1ae:	00001597          	auipc	a1,0x1
 1b2:	97258593          	addi	a1,a1,-1678 # b20 <malloc+0x122>
 1b6:	f4840513          	addi	a0,s0,-184
 1ba:	00000097          	auipc	ra,0x0
 1be:	ed8080e7          	jalr	-296(ra) # 92 <str_append>
    itoa((int)sum, num);
 1c2:	2901                	sext.w	s2,s2
 1c4:	f3040593          	addi	a1,s0,-208
 1c8:	854a                	mv	a0,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	e36080e7          	jalr	-458(ra) # 0 <itoa>
    str_append(msg, num);
 1d2:	f3040593          	addi	a1,s0,-208
 1d6:	f4840513          	addi	a0,s0,-184
 1da:	00000097          	auipc	ra,0x0
 1de:	eb8080e7          	jalr	-328(ra) # 92 <str_append>
    str_append(msg, "\n");
 1e2:	00001597          	auipc	a1,0x1
 1e6:	97e58593          	addi	a1,a1,-1666 # b60 <malloc+0x162>
 1ea:	f4840513          	addi	a0,s0,-184
 1ee:	00000097          	auipc	ra,0x0
 1f2:	ea4080e7          	jalr	-348(ra) # 92 <str_append>
    while (*p) {
 1f6:	4781                	li	a5,0
 1f8:	0007861b          	sext.w	a2,a5
 1fc:	0785                	addi	a5,a5,1
 1fe:	f4840713          	addi	a4,s0,-184
 202:	973e                	add	a4,a4,a5
 204:	fff74703          	lbu	a4,-1(a4) # 3fff <base+0x2fef>
 208:	fb65                	bnez	a4,1f8 <main+0x13e>
    write(1, msg, len);
 20a:	f4840593          	addi	a1,s0,-184
 20e:	4505                	li	a0,1
 210:	00000097          	auipc	ra,0x0
 214:	3b8080e7          	jalr	952(ra) # 5c8 <write>
    exit((int)sum);
 218:	854a                	mv	a0,s2
 21a:	00000097          	auipc	ra,0x0
 21e:	386080e7          	jalr	902(ra) # 5a0 <exit>
    sleep(100);
 222:	06400513          	li	a0,100
 226:	00000097          	auipc	ra,0x0
 22a:	412080e7          	jalr	1042(ra) # 638 <sleep>
    printf("===> Waiting for children with waitall()\n");
 22e:	00001517          	auipc	a0,0x1
 232:	90a50513          	addi	a0,a0,-1782 # b38 <malloc+0x13a>
 236:	00000097          	auipc	ra,0x0
 23a:	70a080e7          	jalr	1802(ra) # 940 <printf>
    if (waitall(&n, statuses) < 0) {
 23e:	fb040593          	addi	a1,s0,-80
 242:	fac40513          	addi	a0,s0,-84
 246:	00000097          	auipc	ra,0x0
 24a:	412080e7          	jalr	1042(ra) # 658 <waitall>
 24e:	06054763          	bltz	a0,2bc <main+0x202>
    for (int i = 0; i < n; i++) {
 252:	fac42583          	lw	a1,-84(s0)
 256:	08b05a63          	blez	a1,2ea <main+0x230>
 25a:	fb040713          	addi	a4,s0,-80
 25e:	4781                	li	a5,0
    long long total = 0;
 260:	4481                	li	s1,0
      total += (long long)statuses[i];
 262:	4314                	lw	a3,0(a4)
 264:	94b6                	add	s1,s1,a3
    for (int i = 0; i < n; i++) {
 266:	2785                	addiw	a5,a5,1
 268:	0711                	addi	a4,a4,4
 26a:	feb79ce3          	bne	a5,a1,262 <main+0x1a8>
    printf("===> All %d children finished\n", n);
 26e:	00001517          	auipc	a0,0x1
 272:	90a50513          	addi	a0,a0,-1782 # b78 <malloc+0x17a>
 276:	00000097          	auipc	ra,0x0
 27a:	6ca080e7          	jalr	1738(ra) # 940 <printf>
    printf("Sum of all children's sums: %lld\n", total);
 27e:	85a6                	mv	a1,s1
 280:	00001517          	auipc	a0,0x1
 284:	91850513          	addi	a0,a0,-1768 # b98 <malloc+0x19a>
 288:	00000097          	auipc	ra,0x0
 28c:	6b8080e7          	jalr	1720(ra) # 940 <printf>
    if (total == expected) {
 290:	100017b7          	lui	a5,0x10001
 294:	078e                	slli	a5,a5,0x3
 296:	04f48063          	beq	s1,a5,2d6 <main+0x21c>
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);
 29a:	10001637          	lui	a2,0x10001
 29e:	060e                	slli	a2,a2,0x3
 2a0:	85a6                	mv	a1,s1
 2a2:	00001517          	auipc	a0,0x1
 2a6:	93e50513          	addi	a0,a0,-1730 # be0 <malloc+0x1e2>
 2aa:	00000097          	auipc	ra,0x0
 2ae:	696080e7          	jalr	1686(ra) # 940 <printf>
    exit(0);
 2b2:	4501                	li	a0,0
 2b4:	00000097          	auipc	ra,0x0
 2b8:	2ec080e7          	jalr	748(ra) # 5a0 <exit>
      printf("waitall failed\n");
 2bc:	00001517          	auipc	a0,0x1
 2c0:	8ac50513          	addi	a0,a0,-1876 # b68 <malloc+0x16a>
 2c4:	00000097          	auipc	ra,0x0
 2c8:	67c080e7          	jalr	1660(ra) # 940 <printf>
      exit(-1);
 2cc:	557d                	li	a0,-1
 2ce:	00000097          	auipc	ra,0x0
 2d2:	2d2080e7          	jalr	722(ra) # 5a0 <exit>
      printf("Correct total sum: %lld\n", total);
 2d6:	85be                	mv	a1,a5
 2d8:	00001517          	auipc	a0,0x1
 2dc:	8e850513          	addi	a0,a0,-1816 # bc0 <malloc+0x1c2>
 2e0:	00000097          	auipc	ra,0x0
 2e4:	660080e7          	jalr	1632(ra) # 940 <printf>
 2e8:	b7e9                	j	2b2 <main+0x1f8>
    printf("===> All %d children finished\n", n);
 2ea:	00001517          	auipc	a0,0x1
 2ee:	88e50513          	addi	a0,a0,-1906 # b78 <malloc+0x17a>
 2f2:	00000097          	auipc	ra,0x0
 2f6:	64e080e7          	jalr	1614(ra) # 940 <printf>
    printf("Sum of all children's sums: %lld\n", total);
 2fa:	4581                	li	a1,0
 2fc:	00001517          	auipc	a0,0x1
 300:	89c50513          	addi	a0,a0,-1892 # b98 <malloc+0x19a>
 304:	00000097          	auipc	ra,0x0
 308:	63c080e7          	jalr	1596(ra) # 940 <printf>
    long long total = 0;
 30c:	4481                	li	s1,0
 30e:	b771                	j	29a <main+0x1e0>

0000000000000310 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  extern int main();
  main();
 318:	00000097          	auipc	ra,0x0
 31c:	da2080e7          	jalr	-606(ra) # ba <main>
  exit(0);
 320:	4501                	li	a0,0
 322:	00000097          	auipc	ra,0x0
 326:	27e080e7          	jalr	638(ra) # 5a0 <exit>

000000000000032a <strcpy>:
}

char* strcpy(char *s, const char *t)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 330:	87aa                	mv	a5,a0
 332:	0585                	addi	a1,a1,1
 334:	0785                	addi	a5,a5,1
 336:	fff5c703          	lbu	a4,-1(a1)
 33a:	fee78fa3          	sb	a4,-1(a5) # 10000fff <base+0xfffffef>
 33e:	fb75                	bnez	a4,332 <strcpy+0x8>
    ;
  return os;
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret

0000000000000346 <strcmp>:

int strcmp(const char *p, const char *q)
{
 346:	1141                	addi	sp,sp,-16
 348:	e422                	sd	s0,8(sp)
 34a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 34c:	00054783          	lbu	a5,0(a0)
 350:	cb91                	beqz	a5,364 <strcmp+0x1e>
 352:	0005c703          	lbu	a4,0(a1)
 356:	00f71763          	bne	a4,a5,364 <strcmp+0x1e>
    p++, q++;
 35a:	0505                	addi	a0,a0,1
 35c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 35e:	00054783          	lbu	a5,0(a0)
 362:	fbe5                	bnez	a5,352 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 364:	0005c503          	lbu	a0,0(a1)
}
 368:	40a7853b          	subw	a0,a5,a0
 36c:	6422                	ld	s0,8(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret

0000000000000372 <strlen>:

uint strlen(const char *s)
{
 372:	1141                	addi	sp,sp,-16
 374:	e422                	sd	s0,8(sp)
 376:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 378:	00054783          	lbu	a5,0(a0)
 37c:	cf91                	beqz	a5,398 <strlen+0x26>
 37e:	0505                	addi	a0,a0,1
 380:	87aa                	mv	a5,a0
 382:	4685                	li	a3,1
 384:	9e89                	subw	a3,a3,a0
 386:	00f6853b          	addw	a0,a3,a5
 38a:	0785                	addi	a5,a5,1
 38c:	fff7c703          	lbu	a4,-1(a5)
 390:	fb7d                	bnez	a4,386 <strlen+0x14>
    ;
  return n;
}
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
  for(n = 0; s[n]; n++)
 398:	4501                	li	a0,0
 39a:	bfe5                	j	392 <strlen+0x20>

000000000000039c <memset>:

void* memset(void *dst, int c, uint n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e422                	sd	s0,8(sp)
 3a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3a2:	ce09                	beqz	a2,3bc <memset+0x20>
 3a4:	87aa                	mv	a5,a0
 3a6:	fff6071b          	addiw	a4,a2,-1
 3aa:	1702                	slli	a4,a4,0x20
 3ac:	9301                	srli	a4,a4,0x20
 3ae:	0705                	addi	a4,a4,1
 3b0:	972a                	add	a4,a4,a0
    cdst[i] = c;
 3b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3b6:	0785                	addi	a5,a5,1
 3b8:	fee79de3          	bne	a5,a4,3b2 <memset+0x16>
  }
  return dst;
}
 3bc:	6422                	ld	s0,8(sp)
 3be:	0141                	addi	sp,sp,16
 3c0:	8082                	ret

00000000000003c2 <strchr>:

char* strchr(const char *s, char c)
{
 3c2:	1141                	addi	sp,sp,-16
 3c4:	e422                	sd	s0,8(sp)
 3c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3c8:	00054783          	lbu	a5,0(a0)
 3cc:	cb99                	beqz	a5,3e2 <strchr+0x20>
    if(*s == c)
 3ce:	00f58763          	beq	a1,a5,3dc <strchr+0x1a>
  for(; *s; s++)
 3d2:	0505                	addi	a0,a0,1
 3d4:	00054783          	lbu	a5,0(a0)
 3d8:	fbfd                	bnez	a5,3ce <strchr+0xc>
      return (char*)s;
  return 0;
 3da:	4501                	li	a0,0
}
 3dc:	6422                	ld	s0,8(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret
  return 0;
 3e2:	4501                	li	a0,0
 3e4:	bfe5                	j	3dc <strchr+0x1a>

00000000000003e6 <gets>:

char* gets(char *buf, int max)
{
 3e6:	711d                	addi	sp,sp,-96
 3e8:	ec86                	sd	ra,88(sp)
 3ea:	e8a2                	sd	s0,80(sp)
 3ec:	e4a6                	sd	s1,72(sp)
 3ee:	e0ca                	sd	s2,64(sp)
 3f0:	fc4e                	sd	s3,56(sp)
 3f2:	f852                	sd	s4,48(sp)
 3f4:	f456                	sd	s5,40(sp)
 3f6:	f05a                	sd	s6,32(sp)
 3f8:	ec5e                	sd	s7,24(sp)
 3fa:	1080                	addi	s0,sp,96
 3fc:	8baa                	mv	s7,a0
 3fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 400:	892a                	mv	s2,a0
 402:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 404:	4aa9                	li	s5,10
 406:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 408:	89a6                	mv	s3,s1
 40a:	2485                	addiw	s1,s1,1
 40c:	0344d863          	bge	s1,s4,43c <gets+0x56>
    cc = read(0, &c, 1);
 410:	4605                	li	a2,1
 412:	faf40593          	addi	a1,s0,-81
 416:	4501                	li	a0,0
 418:	00000097          	auipc	ra,0x0
 41c:	1a8080e7          	jalr	424(ra) # 5c0 <read>
    if(cc < 1)
 420:	00a05e63          	blez	a0,43c <gets+0x56>
    buf[i++] = c;
 424:	faf44783          	lbu	a5,-81(s0)
 428:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 42c:	01578763          	beq	a5,s5,43a <gets+0x54>
 430:	0905                	addi	s2,s2,1
 432:	fd679be3          	bne	a5,s6,408 <gets+0x22>
  for(i=0; i+1 < max; ){
 436:	89a6                	mv	s3,s1
 438:	a011                	j	43c <gets+0x56>
 43a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 43c:	99de                	add	s3,s3,s7
 43e:	00098023          	sb	zero,0(s3)
  return buf;
}
 442:	855e                	mv	a0,s7
 444:	60e6                	ld	ra,88(sp)
 446:	6446                	ld	s0,80(sp)
 448:	64a6                	ld	s1,72(sp)
 44a:	6906                	ld	s2,64(sp)
 44c:	79e2                	ld	s3,56(sp)
 44e:	7a42                	ld	s4,48(sp)
 450:	7aa2                	ld	s5,40(sp)
 452:	7b02                	ld	s6,32(sp)
 454:	6be2                	ld	s7,24(sp)
 456:	6125                	addi	sp,sp,96
 458:	8082                	ret

000000000000045a <stat>:

int stat(const char *n, struct stat *st)
{
 45a:	1101                	addi	sp,sp,-32
 45c:	ec06                	sd	ra,24(sp)
 45e:	e822                	sd	s0,16(sp)
 460:	e426                	sd	s1,8(sp)
 462:	e04a                	sd	s2,0(sp)
 464:	1000                	addi	s0,sp,32
 466:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 468:	4581                	li	a1,0
 46a:	00000097          	auipc	ra,0x0
 46e:	17e080e7          	jalr	382(ra) # 5e8 <open>
  if(fd < 0)
 472:	02054563          	bltz	a0,49c <stat+0x42>
 476:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 478:	85ca                	mv	a1,s2
 47a:	00000097          	auipc	ra,0x0
 47e:	186080e7          	jalr	390(ra) # 600 <fstat>
 482:	892a                	mv	s2,a0
  close(fd);
 484:	8526                	mv	a0,s1
 486:	00000097          	auipc	ra,0x0
 48a:	14a080e7          	jalr	330(ra) # 5d0 <close>
  return r;
}
 48e:	854a                	mv	a0,s2
 490:	60e2                	ld	ra,24(sp)
 492:	6442                	ld	s0,16(sp)
 494:	64a2                	ld	s1,8(sp)
 496:	6902                	ld	s2,0(sp)
 498:	6105                	addi	sp,sp,32
 49a:	8082                	ret
    return -1;
 49c:	597d                	li	s2,-1
 49e:	bfc5                	j	48e <stat+0x34>

00000000000004a0 <atoi>:

int atoi(const char *s)
{
 4a0:	1141                	addi	sp,sp,-16
 4a2:	e422                	sd	s0,8(sp)
 4a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4a6:	00054603          	lbu	a2,0(a0)
 4aa:	fd06079b          	addiw	a5,a2,-48
 4ae:	0ff7f793          	andi	a5,a5,255
 4b2:	4725                	li	a4,9
 4b4:	02f76963          	bltu	a4,a5,4e6 <atoi+0x46>
 4b8:	86aa                	mv	a3,a0
  n = 0;
 4ba:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4bc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4be:	0685                	addi	a3,a3,1
 4c0:	0025179b          	slliw	a5,a0,0x2
 4c4:	9fa9                	addw	a5,a5,a0
 4c6:	0017979b          	slliw	a5,a5,0x1
 4ca:	9fb1                	addw	a5,a5,a2
 4cc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4d0:	0006c603          	lbu	a2,0(a3)
 4d4:	fd06071b          	addiw	a4,a2,-48
 4d8:	0ff77713          	andi	a4,a4,255
 4dc:	fee5f1e3          	bgeu	a1,a4,4be <atoi+0x1e>
  return n;
}
 4e0:	6422                	ld	s0,8(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret
  n = 0;
 4e6:	4501                	li	a0,0
 4e8:	bfe5                	j	4e0 <atoi+0x40>

00000000000004ea <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 4ea:	1141                	addi	sp,sp,-16
 4ec:	e422                	sd	s0,8(sp)
 4ee:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4f0:	02b57663          	bgeu	a0,a1,51c <memmove+0x32>
    while(n-- > 0)
 4f4:	02c05163          	blez	a2,516 <memmove+0x2c>
 4f8:	fff6079b          	addiw	a5,a2,-1
 4fc:	1782                	slli	a5,a5,0x20
 4fe:	9381                	srli	a5,a5,0x20
 500:	0785                	addi	a5,a5,1
 502:	97aa                	add	a5,a5,a0
  dst = vdst;
 504:	872a                	mv	a4,a0
      *dst++ = *src++;
 506:	0585                	addi	a1,a1,1
 508:	0705                	addi	a4,a4,1
 50a:	fff5c683          	lbu	a3,-1(a1)
 50e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 512:	fee79ae3          	bne	a5,a4,506 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 516:	6422                	ld	s0,8(sp)
 518:	0141                	addi	sp,sp,16
 51a:	8082                	ret
    dst += n;
 51c:	00c50733          	add	a4,a0,a2
    src += n;
 520:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 522:	fec05ae3          	blez	a2,516 <memmove+0x2c>
 526:	fff6079b          	addiw	a5,a2,-1
 52a:	1782                	slli	a5,a5,0x20
 52c:	9381                	srli	a5,a5,0x20
 52e:	fff7c793          	not	a5,a5
 532:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 534:	15fd                	addi	a1,a1,-1
 536:	177d                	addi	a4,a4,-1
 538:	0005c683          	lbu	a3,0(a1)
 53c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 540:	fee79ae3          	bne	a5,a4,534 <memmove+0x4a>
 544:	bfc9                	j	516 <memmove+0x2c>

0000000000000546 <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 546:	1141                	addi	sp,sp,-16
 548:	e422                	sd	s0,8(sp)
 54a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 54c:	ca05                	beqz	a2,57c <memcmp+0x36>
 54e:	fff6069b          	addiw	a3,a2,-1
 552:	1682                	slli	a3,a3,0x20
 554:	9281                	srli	a3,a3,0x20
 556:	0685                	addi	a3,a3,1
 558:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 55a:	00054783          	lbu	a5,0(a0)
 55e:	0005c703          	lbu	a4,0(a1)
 562:	00e79863          	bne	a5,a4,572 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 566:	0505                	addi	a0,a0,1
    p2++;
 568:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 56a:	fed518e3          	bne	a0,a3,55a <memcmp+0x14>
  }
  return 0;
 56e:	4501                	li	a0,0
 570:	a019                	j	576 <memcmp+0x30>
      return *p1 - *p2;
 572:	40e7853b          	subw	a0,a5,a4
}
 576:	6422                	ld	s0,8(sp)
 578:	0141                	addi	sp,sp,16
 57a:	8082                	ret
  return 0;
 57c:	4501                	li	a0,0
 57e:	bfe5                	j	576 <memcmp+0x30>

0000000000000580 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 580:	1141                	addi	sp,sp,-16
 582:	e406                	sd	ra,8(sp)
 584:	e022                	sd	s0,0(sp)
 586:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 588:	00000097          	auipc	ra,0x0
 58c:	f62080e7          	jalr	-158(ra) # 4ea <memmove>
}
 590:	60a2                	ld	ra,8(sp)
 592:	6402                	ld	s0,0(sp)
 594:	0141                	addi	sp,sp,16
 596:	8082                	ret

0000000000000598 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 598:	4885                	li	a7,1
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5a0:	4889                	li	a7,2
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 5a8:	48e1                	li	a7,24
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5b0:	488d                	li	a7,3
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5b8:	4891                	li	a7,4
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <read>:
.global read
read:
 li a7, SYS_read
 5c0:	4895                	li	a7,5
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <write>:
.global write
write:
 li a7, SYS_write
 5c8:	48c1                	li	a7,16
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <close>:
.global close
close:
 li a7, SYS_close
 5d0:	48d5                	li	a7,21
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5d8:	4899                	li	a7,6
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5e0:	489d                	li	a7,7
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <open>:
.global open
open:
 li a7, SYS_open
 5e8:	48bd                	li	a7,15
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5f0:	48c5                	li	a7,17
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5f8:	48c9                	li	a7,18
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 600:	48a1                	li	a7,8
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <link>:
.global link
link:
 li a7, SYS_link
 608:	48cd                	li	a7,19
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 610:	48d1                	li	a7,20
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 618:	48a5                	li	a7,9
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <dup>:
.global dup
dup:
 li a7, SYS_dup
 620:	48a9                	li	a7,10
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 628:	48ad                	li	a7,11
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 630:	48b1                	li	a7,12
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 638:	48b5                	li	a7,13
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 640:	48b9                	li	a7,14
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 648:	48dd                	li	a7,23
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 650:	48e5                	li	a7,25
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 658:	48e9                	li	a7,26
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 660:	48ed                	li	a7,27
 ecall
 662:	00000073          	ecall
 ret
 666:	8082                	ret

0000000000000668 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 668:	1101                	addi	sp,sp,-32
 66a:	ec06                	sd	ra,24(sp)
 66c:	e822                	sd	s0,16(sp)
 66e:	1000                	addi	s0,sp,32
 670:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 674:	4605                	li	a2,1
 676:	fef40593          	addi	a1,s0,-17
 67a:	00000097          	auipc	ra,0x0
 67e:	f4e080e7          	jalr	-178(ra) # 5c8 <write>
}
 682:	60e2                	ld	ra,24(sp)
 684:	6442                	ld	s0,16(sp)
 686:	6105                	addi	sp,sp,32
 688:	8082                	ret

000000000000068a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 68a:	7139                	addi	sp,sp,-64
 68c:	fc06                	sd	ra,56(sp)
 68e:	f822                	sd	s0,48(sp)
 690:	f426                	sd	s1,40(sp)
 692:	f04a                	sd	s2,32(sp)
 694:	ec4e                	sd	s3,24(sp)
 696:	0080                	addi	s0,sp,64
 698:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 69a:	c299                	beqz	a3,6a0 <printint+0x16>
 69c:	0805c863          	bltz	a1,72c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6a0:	2581                	sext.w	a1,a1
  neg = 0;
 6a2:	4881                	li	a7,0
 6a4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6a8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6aa:	2601                	sext.w	a2,a2
 6ac:	00000517          	auipc	a0,0x0
 6b0:	5cc50513          	addi	a0,a0,1484 # c78 <digits>
 6b4:	883a                	mv	a6,a4
 6b6:	2705                	addiw	a4,a4,1
 6b8:	02c5f7bb          	remuw	a5,a1,a2
 6bc:	1782                	slli	a5,a5,0x20
 6be:	9381                	srli	a5,a5,0x20
 6c0:	97aa                	add	a5,a5,a0
 6c2:	0007c783          	lbu	a5,0(a5)
 6c6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6ca:	0005879b          	sext.w	a5,a1
 6ce:	02c5d5bb          	divuw	a1,a1,a2
 6d2:	0685                	addi	a3,a3,1
 6d4:	fec7f0e3          	bgeu	a5,a2,6b4 <printint+0x2a>
  if(neg)
 6d8:	00088b63          	beqz	a7,6ee <printint+0x64>
    buf[i++] = '-';
 6dc:	fd040793          	addi	a5,s0,-48
 6e0:	973e                	add	a4,a4,a5
 6e2:	02d00793          	li	a5,45
 6e6:	fef70823          	sb	a5,-16(a4)
 6ea:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6ee:	02e05863          	blez	a4,71e <printint+0x94>
 6f2:	fc040793          	addi	a5,s0,-64
 6f6:	00e78933          	add	s2,a5,a4
 6fa:	fff78993          	addi	s3,a5,-1
 6fe:	99ba                	add	s3,s3,a4
 700:	377d                	addiw	a4,a4,-1
 702:	1702                	slli	a4,a4,0x20
 704:	9301                	srli	a4,a4,0x20
 706:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 70a:	fff94583          	lbu	a1,-1(s2)
 70e:	8526                	mv	a0,s1
 710:	00000097          	auipc	ra,0x0
 714:	f58080e7          	jalr	-168(ra) # 668 <putc>
  while(--i >= 0)
 718:	197d                	addi	s2,s2,-1
 71a:	ff3918e3          	bne	s2,s3,70a <printint+0x80>
}
 71e:	70e2                	ld	ra,56(sp)
 720:	7442                	ld	s0,48(sp)
 722:	74a2                	ld	s1,40(sp)
 724:	7902                	ld	s2,32(sp)
 726:	69e2                	ld	s3,24(sp)
 728:	6121                	addi	sp,sp,64
 72a:	8082                	ret
    x = -xx;
 72c:	40b005bb          	negw	a1,a1
    neg = 1;
 730:	4885                	li	a7,1
    x = -xx;
 732:	bf8d                	j	6a4 <printint+0x1a>

0000000000000734 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 734:	7119                	addi	sp,sp,-128
 736:	fc86                	sd	ra,120(sp)
 738:	f8a2                	sd	s0,112(sp)
 73a:	f4a6                	sd	s1,104(sp)
 73c:	f0ca                	sd	s2,96(sp)
 73e:	ecce                	sd	s3,88(sp)
 740:	e8d2                	sd	s4,80(sp)
 742:	e4d6                	sd	s5,72(sp)
 744:	e0da                	sd	s6,64(sp)
 746:	fc5e                	sd	s7,56(sp)
 748:	f862                	sd	s8,48(sp)
 74a:	f466                	sd	s9,40(sp)
 74c:	f06a                	sd	s10,32(sp)
 74e:	ec6e                	sd	s11,24(sp)
 750:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 752:	0005c903          	lbu	s2,0(a1)
 756:	18090f63          	beqz	s2,8f4 <vprintf+0x1c0>
 75a:	8aaa                	mv	s5,a0
 75c:	8b32                	mv	s6,a2
 75e:	00158493          	addi	s1,a1,1
  state = 0;
 762:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 764:	02500a13          	li	s4,37
      if(c == 'd'){
 768:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 76c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 770:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 774:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 778:	00000b97          	auipc	s7,0x0
 77c:	500b8b93          	addi	s7,s7,1280 # c78 <digits>
 780:	a839                	j	79e <vprintf+0x6a>
        putc(fd, c);
 782:	85ca                	mv	a1,s2
 784:	8556                	mv	a0,s5
 786:	00000097          	auipc	ra,0x0
 78a:	ee2080e7          	jalr	-286(ra) # 668 <putc>
 78e:	a019                	j	794 <vprintf+0x60>
    } else if(state == '%'){
 790:	01498f63          	beq	s3,s4,7ae <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 794:	0485                	addi	s1,s1,1
 796:	fff4c903          	lbu	s2,-1(s1)
 79a:	14090d63          	beqz	s2,8f4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 79e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7a2:	fe0997e3          	bnez	s3,790 <vprintf+0x5c>
      if(c == '%'){
 7a6:	fd479ee3          	bne	a5,s4,782 <vprintf+0x4e>
        state = '%';
 7aa:	89be                	mv	s3,a5
 7ac:	b7e5                	j	794 <vprintf+0x60>
      if(c == 'd'){
 7ae:	05878063          	beq	a5,s8,7ee <vprintf+0xba>
      } else if(c == 'l') {
 7b2:	05978c63          	beq	a5,s9,80a <vprintf+0xd6>
      } else if(c == 'x') {
 7b6:	07a78863          	beq	a5,s10,826 <vprintf+0xf2>
      } else if(c == 'p') {
 7ba:	09b78463          	beq	a5,s11,842 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7be:	07300713          	li	a4,115
 7c2:	0ce78663          	beq	a5,a4,88e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7c6:	06300713          	li	a4,99
 7ca:	0ee78e63          	beq	a5,a4,8c6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7ce:	11478863          	beq	a5,s4,8de <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7d2:	85d2                	mv	a1,s4
 7d4:	8556                	mv	a0,s5
 7d6:	00000097          	auipc	ra,0x0
 7da:	e92080e7          	jalr	-366(ra) # 668 <putc>
        putc(fd, c);
 7de:	85ca                	mv	a1,s2
 7e0:	8556                	mv	a0,s5
 7e2:	00000097          	auipc	ra,0x0
 7e6:	e86080e7          	jalr	-378(ra) # 668 <putc>
      }
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	b765                	j	794 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7ee:	008b0913          	addi	s2,s6,8
 7f2:	4685                	li	a3,1
 7f4:	4629                	li	a2,10
 7f6:	000b2583          	lw	a1,0(s6)
 7fa:	8556                	mv	a0,s5
 7fc:	00000097          	auipc	ra,0x0
 800:	e8e080e7          	jalr	-370(ra) # 68a <printint>
 804:	8b4a                	mv	s6,s2
      state = 0;
 806:	4981                	li	s3,0
 808:	b771                	j	794 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 80a:	008b0913          	addi	s2,s6,8
 80e:	4681                	li	a3,0
 810:	4629                	li	a2,10
 812:	000b2583          	lw	a1,0(s6)
 816:	8556                	mv	a0,s5
 818:	00000097          	auipc	ra,0x0
 81c:	e72080e7          	jalr	-398(ra) # 68a <printint>
 820:	8b4a                	mv	s6,s2
      state = 0;
 822:	4981                	li	s3,0
 824:	bf85                	j	794 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 826:	008b0913          	addi	s2,s6,8
 82a:	4681                	li	a3,0
 82c:	4641                	li	a2,16
 82e:	000b2583          	lw	a1,0(s6)
 832:	8556                	mv	a0,s5
 834:	00000097          	auipc	ra,0x0
 838:	e56080e7          	jalr	-426(ra) # 68a <printint>
 83c:	8b4a                	mv	s6,s2
      state = 0;
 83e:	4981                	li	s3,0
 840:	bf91                	j	794 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 842:	008b0793          	addi	a5,s6,8
 846:	f8f43423          	sd	a5,-120(s0)
 84a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 84e:	03000593          	li	a1,48
 852:	8556                	mv	a0,s5
 854:	00000097          	auipc	ra,0x0
 858:	e14080e7          	jalr	-492(ra) # 668 <putc>
  putc(fd, 'x');
 85c:	85ea                	mv	a1,s10
 85e:	8556                	mv	a0,s5
 860:	00000097          	auipc	ra,0x0
 864:	e08080e7          	jalr	-504(ra) # 668 <putc>
 868:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 86a:	03c9d793          	srli	a5,s3,0x3c
 86e:	97de                	add	a5,a5,s7
 870:	0007c583          	lbu	a1,0(a5)
 874:	8556                	mv	a0,s5
 876:	00000097          	auipc	ra,0x0
 87a:	df2080e7          	jalr	-526(ra) # 668 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 87e:	0992                	slli	s3,s3,0x4
 880:	397d                	addiw	s2,s2,-1
 882:	fe0914e3          	bnez	s2,86a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 886:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 88a:	4981                	li	s3,0
 88c:	b721                	j	794 <vprintf+0x60>
        s = va_arg(ap, char*);
 88e:	008b0993          	addi	s3,s6,8
 892:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 896:	02090163          	beqz	s2,8b8 <vprintf+0x184>
        while(*s != 0){
 89a:	00094583          	lbu	a1,0(s2)
 89e:	c9a1                	beqz	a1,8ee <vprintf+0x1ba>
          putc(fd, *s);
 8a0:	8556                	mv	a0,s5
 8a2:	00000097          	auipc	ra,0x0
 8a6:	dc6080e7          	jalr	-570(ra) # 668 <putc>
          s++;
 8aa:	0905                	addi	s2,s2,1
        while(*s != 0){
 8ac:	00094583          	lbu	a1,0(s2)
 8b0:	f9e5                	bnez	a1,8a0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 8b2:	8b4e                	mv	s6,s3
      state = 0;
 8b4:	4981                	li	s3,0
 8b6:	bdf9                	j	794 <vprintf+0x60>
          s = "(null)";
 8b8:	00000917          	auipc	s2,0x0
 8bc:	3b890913          	addi	s2,s2,952 # c70 <malloc+0x272>
        while(*s != 0){
 8c0:	02800593          	li	a1,40
 8c4:	bff1                	j	8a0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8c6:	008b0913          	addi	s2,s6,8
 8ca:	000b4583          	lbu	a1,0(s6)
 8ce:	8556                	mv	a0,s5
 8d0:	00000097          	auipc	ra,0x0
 8d4:	d98080e7          	jalr	-616(ra) # 668 <putc>
 8d8:	8b4a                	mv	s6,s2
      state = 0;
 8da:	4981                	li	s3,0
 8dc:	bd65                	j	794 <vprintf+0x60>
        putc(fd, c);
 8de:	85d2                	mv	a1,s4
 8e0:	8556                	mv	a0,s5
 8e2:	00000097          	auipc	ra,0x0
 8e6:	d86080e7          	jalr	-634(ra) # 668 <putc>
      state = 0;
 8ea:	4981                	li	s3,0
 8ec:	b565                	j	794 <vprintf+0x60>
        s = va_arg(ap, char*);
 8ee:	8b4e                	mv	s6,s3
      state = 0;
 8f0:	4981                	li	s3,0
 8f2:	b54d                	j	794 <vprintf+0x60>
    }
  }
}
 8f4:	70e6                	ld	ra,120(sp)
 8f6:	7446                	ld	s0,112(sp)
 8f8:	74a6                	ld	s1,104(sp)
 8fa:	7906                	ld	s2,96(sp)
 8fc:	69e6                	ld	s3,88(sp)
 8fe:	6a46                	ld	s4,80(sp)
 900:	6aa6                	ld	s5,72(sp)
 902:	6b06                	ld	s6,64(sp)
 904:	7be2                	ld	s7,56(sp)
 906:	7c42                	ld	s8,48(sp)
 908:	7ca2                	ld	s9,40(sp)
 90a:	7d02                	ld	s10,32(sp)
 90c:	6de2                	ld	s11,24(sp)
 90e:	6109                	addi	sp,sp,128
 910:	8082                	ret

0000000000000912 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 912:	715d                	addi	sp,sp,-80
 914:	ec06                	sd	ra,24(sp)
 916:	e822                	sd	s0,16(sp)
 918:	1000                	addi	s0,sp,32
 91a:	e010                	sd	a2,0(s0)
 91c:	e414                	sd	a3,8(s0)
 91e:	e818                	sd	a4,16(s0)
 920:	ec1c                	sd	a5,24(s0)
 922:	03043023          	sd	a6,32(s0)
 926:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 92a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 92e:	8622                	mv	a2,s0
 930:	00000097          	auipc	ra,0x0
 934:	e04080e7          	jalr	-508(ra) # 734 <vprintf>
}
 938:	60e2                	ld	ra,24(sp)
 93a:	6442                	ld	s0,16(sp)
 93c:	6161                	addi	sp,sp,80
 93e:	8082                	ret

0000000000000940 <printf>:

void
printf(const char *fmt, ...)
{
 940:	711d                	addi	sp,sp,-96
 942:	ec06                	sd	ra,24(sp)
 944:	e822                	sd	s0,16(sp)
 946:	1000                	addi	s0,sp,32
 948:	e40c                	sd	a1,8(s0)
 94a:	e810                	sd	a2,16(s0)
 94c:	ec14                	sd	a3,24(s0)
 94e:	f018                	sd	a4,32(s0)
 950:	f41c                	sd	a5,40(s0)
 952:	03043823          	sd	a6,48(s0)
 956:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 95a:	00840613          	addi	a2,s0,8
 95e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 962:	85aa                	mv	a1,a0
 964:	4505                	li	a0,1
 966:	00000097          	auipc	ra,0x0
 96a:	dce080e7          	jalr	-562(ra) # 734 <vprintf>
}
 96e:	60e2                	ld	ra,24(sp)
 970:	6442                	ld	s0,16(sp)
 972:	6125                	addi	sp,sp,96
 974:	8082                	ret

0000000000000976 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 976:	1141                	addi	sp,sp,-16
 978:	e422                	sd	s0,8(sp)
 97a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 97c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 980:	00000797          	auipc	a5,0x0
 984:	6807b783          	ld	a5,1664(a5) # 1000 <freep>
 988:	a805                	j	9b8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 98a:	4618                	lw	a4,8(a2)
 98c:	9db9                	addw	a1,a1,a4
 98e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 992:	6398                	ld	a4,0(a5)
 994:	6318                	ld	a4,0(a4)
 996:	fee53823          	sd	a4,-16(a0)
 99a:	a091                	j	9de <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 99c:	ff852703          	lw	a4,-8(a0)
 9a0:	9e39                	addw	a2,a2,a4
 9a2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9a4:	ff053703          	ld	a4,-16(a0)
 9a8:	e398                	sd	a4,0(a5)
 9aa:	a099                	j	9f0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ac:	6398                	ld	a4,0(a5)
 9ae:	00e7e463          	bltu	a5,a4,9b6 <free+0x40>
 9b2:	00e6ea63          	bltu	a3,a4,9c6 <free+0x50>
{
 9b6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b8:	fed7fae3          	bgeu	a5,a3,9ac <free+0x36>
 9bc:	6398                	ld	a4,0(a5)
 9be:	00e6e463          	bltu	a3,a4,9c6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c2:	fee7eae3          	bltu	a5,a4,9b6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9c6:	ff852583          	lw	a1,-8(a0)
 9ca:	6390                	ld	a2,0(a5)
 9cc:	02059713          	slli	a4,a1,0x20
 9d0:	9301                	srli	a4,a4,0x20
 9d2:	0712                	slli	a4,a4,0x4
 9d4:	9736                	add	a4,a4,a3
 9d6:	fae60ae3          	beq	a2,a4,98a <free+0x14>
    bp->s.ptr = p->s.ptr;
 9da:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9de:	4790                	lw	a2,8(a5)
 9e0:	02061713          	slli	a4,a2,0x20
 9e4:	9301                	srli	a4,a4,0x20
 9e6:	0712                	slli	a4,a4,0x4
 9e8:	973e                	add	a4,a4,a5
 9ea:	fae689e3          	beq	a3,a4,99c <free+0x26>
  } else
    p->s.ptr = bp;
 9ee:	e394                	sd	a3,0(a5)
  freep = p;
 9f0:	00000717          	auipc	a4,0x0
 9f4:	60f73823          	sd	a5,1552(a4) # 1000 <freep>
}
 9f8:	6422                	ld	s0,8(sp)
 9fa:	0141                	addi	sp,sp,16
 9fc:	8082                	ret

00000000000009fe <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9fe:	7139                	addi	sp,sp,-64
 a00:	fc06                	sd	ra,56(sp)
 a02:	f822                	sd	s0,48(sp)
 a04:	f426                	sd	s1,40(sp)
 a06:	f04a                	sd	s2,32(sp)
 a08:	ec4e                	sd	s3,24(sp)
 a0a:	e852                	sd	s4,16(sp)
 a0c:	e456                	sd	s5,8(sp)
 a0e:	e05a                	sd	s6,0(sp)
 a10:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a12:	02051493          	slli	s1,a0,0x20
 a16:	9081                	srli	s1,s1,0x20
 a18:	04bd                	addi	s1,s1,15
 a1a:	8091                	srli	s1,s1,0x4
 a1c:	0014899b          	addiw	s3,s1,1
 a20:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a22:	00000517          	auipc	a0,0x0
 a26:	5de53503          	ld	a0,1502(a0) # 1000 <freep>
 a2a:	c515                	beqz	a0,a56 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a2e:	4798                	lw	a4,8(a5)
 a30:	02977f63          	bgeu	a4,s1,a6e <malloc+0x70>
 a34:	8a4e                	mv	s4,s3
 a36:	0009871b          	sext.w	a4,s3
 a3a:	6685                	lui	a3,0x1
 a3c:	00d77363          	bgeu	a4,a3,a42 <malloc+0x44>
 a40:	6a05                	lui	s4,0x1
 a42:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a46:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a4a:	00000917          	auipc	s2,0x0
 a4e:	5b690913          	addi	s2,s2,1462 # 1000 <freep>
  if(p == (char*)-1)
 a52:	5afd                	li	s5,-1
 a54:	a88d                	j	ac6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a56:	00000797          	auipc	a5,0x0
 a5a:	5ba78793          	addi	a5,a5,1466 # 1010 <base>
 a5e:	00000717          	auipc	a4,0x0
 a62:	5af73123          	sd	a5,1442(a4) # 1000 <freep>
 a66:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a68:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a6c:	b7e1                	j	a34 <malloc+0x36>
      if(p->s.size == nunits)
 a6e:	02e48b63          	beq	s1,a4,aa4 <malloc+0xa6>
        p->s.size -= nunits;
 a72:	4137073b          	subw	a4,a4,s3
 a76:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a78:	1702                	slli	a4,a4,0x20
 a7a:	9301                	srli	a4,a4,0x20
 a7c:	0712                	slli	a4,a4,0x4
 a7e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a80:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a84:	00000717          	auipc	a4,0x0
 a88:	56a73e23          	sd	a0,1404(a4) # 1000 <freep>
      return (void*)(p + 1);
 a8c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a90:	70e2                	ld	ra,56(sp)
 a92:	7442                	ld	s0,48(sp)
 a94:	74a2                	ld	s1,40(sp)
 a96:	7902                	ld	s2,32(sp)
 a98:	69e2                	ld	s3,24(sp)
 a9a:	6a42                	ld	s4,16(sp)
 a9c:	6aa2                	ld	s5,8(sp)
 a9e:	6b02                	ld	s6,0(sp)
 aa0:	6121                	addi	sp,sp,64
 aa2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 aa4:	6398                	ld	a4,0(a5)
 aa6:	e118                	sd	a4,0(a0)
 aa8:	bff1                	j	a84 <malloc+0x86>
  hp->s.size = nu;
 aaa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 aae:	0541                	addi	a0,a0,16
 ab0:	00000097          	auipc	ra,0x0
 ab4:	ec6080e7          	jalr	-314(ra) # 976 <free>
  return freep;
 ab8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 abc:	d971                	beqz	a0,a90 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 abe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ac0:	4798                	lw	a4,8(a5)
 ac2:	fa9776e3          	bgeu	a4,s1,a6e <malloc+0x70>
    if(p == freep)
 ac6:	00093703          	ld	a4,0(s2)
 aca:	853e                	mv	a0,a5
 acc:	fef719e3          	bne	a4,a5,abe <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 ad0:	8552                	mv	a0,s4
 ad2:	00000097          	auipc	ra,0x0
 ad6:	b5e080e7          	jalr	-1186(ra) # 630 <sbrk>
  if(p == (char*)-1)
 ada:	fd5518e3          	bne	a0,s5,aaa <malloc+0xac>
        return 0;
 ade:	4501                	li	a0,0
 ae0:	bf45                	j	a90 <malloc+0x92>
