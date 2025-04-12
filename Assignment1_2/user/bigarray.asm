
user/_bigarray:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <itoa>:
#define SIZE (1 << 16)  // 65536 elements
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
  ba:	7115                	addi	sp,sp,-224
  bc:	ed86                	sd	ra,216(sp)
  be:	e9a2                	sd	s0,208(sp)
  c0:	e5a6                	sd	s1,200(sp)
  c2:	e1ca                	sd	s2,192(sp)
  c4:	fd4e                	sd	s3,184(sp)
  c6:	1180                	addi	s0,sp,224
  printf("===> Calling forkn with n = %d\n", NUM_CHILDREN);
  c8:	4591                	li	a1,4
  ca:	00001517          	auipc	a0,0x1
  ce:	a2650513          	addi	a0,a0,-1498 # af0 <malloc+0xee>
  d2:	00001097          	auipc	ra,0x1
  d6:	872080e7          	jalr	-1934(ra) # 944 <printf>

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
  ea:	56e080e7          	jalr	1390(ra) # 654 <forkn>
  
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
    // Exit without printing message
    int result = (int)sum;
    write(2, &result, sizeof(result));  // Write result to stderr
    exit(result);  // Use  exit to avoid exit message
    
  } else if (ret == -2) { // Parent process
 100:	57f9                	li	a5,-2
 102:	12f50863          	beq	a0,a5,232 <main+0x178>
    }

    exit(0);  // Use _exit in parent too
  }
  return 0;
}
 106:	4501                	li	a0,0
 108:	60ee                	ld	ra,216(sp)
 10a:	644e                	ld	s0,208(sp)
 10c:	64ae                	ld	s1,200(sp)
 10e:	690e                	ld	s2,192(sp)
 110:	79ea                	ld	s3,184(sp)
 112:	612d                	addi	sp,sp,224
 114:	8082                	ret
    printf("forkn failed\n");
 116:	00001517          	auipc	a0,0x1
 11a:	9fa50513          	addi	a0,a0,-1542 # b10 <malloc+0x10e>
 11e:	00001097          	auipc	ra,0x1
 122:	826080e7          	jalr	-2010(ra) # 944 <printf>
    exit(-1);
 126:	557d                	li	a0,-1
 128:	00000097          	auipc	ra,0x0
 12c:	47c080e7          	jalr	1148(ra) # 5a4 <exit>
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
    char msg[100] = "Child ";
 14a:	00001797          	auipc	a5,0x1
 14e:	abe78793          	addi	a5,a5,-1346 # c08 <malloc+0x206>
 152:	4398                	lw	a4,0(a5)
 154:	f4e42423          	sw	a4,-184(s0)
 158:	0047d703          	lhu	a4,4(a5)
 15c:	f4e41623          	sh	a4,-180(s0)
 160:	0067c783          	lbu	a5,6(a5)
 164:	f4f40723          	sb	a5,-178(s0)
 168:	05d00613          	li	a2,93
 16c:	4581                	li	a1,0
 16e:	f4f40513          	addi	a0,s0,-177
 172:	00000097          	auipc	ra,0x0
 176:	22e080e7          	jalr	558(ra) # 3a0 <memset>
    itoa(ret, num);
 17a:	f3040593          	addi	a1,s0,-208
 17e:	8526                	mv	a0,s1
 180:	00000097          	auipc	ra,0x0
 184:	e80080e7          	jalr	-384(ra) # 0 <itoa>
    str_append(msg, num);
 188:	f3040593          	addi	a1,s0,-208
 18c:	f4840513          	addi	a0,s0,-184
 190:	00000097          	auipc	ra,0x0
 194:	f02080e7          	jalr	-254(ra) # 92 <str_append>
    str_append(msg, " calculated sum: ");
 198:	00001597          	auipc	a1,0x1
 19c:	98858593          	addi	a1,a1,-1656 # b20 <malloc+0x11e>
 1a0:	f4840513          	addi	a0,s0,-184
 1a4:	00000097          	auipc	ra,0x0
 1a8:	eee080e7          	jalr	-274(ra) # 92 <str_append>
    itoa((int)sum, num);
 1ac:	2901                	sext.w	s2,s2
 1ae:	f3040593          	addi	a1,s0,-208
 1b2:	854a                	mv	a0,s2
 1b4:	00000097          	auipc	ra,0x0
 1b8:	e4c080e7          	jalr	-436(ra) # 0 <itoa>
    str_append(msg, num);
 1bc:	f3040593          	addi	a1,s0,-208
 1c0:	f4840513          	addi	a0,s0,-184
 1c4:	00000097          	auipc	ra,0x0
 1c8:	ece080e7          	jalr	-306(ra) # 92 <str_append>
    str_append(msg, "\n");
 1cc:	00001597          	auipc	a1,0x1
 1d0:	99458593          	addi	a1,a1,-1644 # b60 <malloc+0x15e>
 1d4:	f4840513          	addi	a0,s0,-184
 1d8:	00000097          	auipc	ra,0x0
 1dc:	eba080e7          	jalr	-326(ra) # 92 <str_append>
    while (*p) {
 1e0:	4781                	li	a5,0
 1e2:	0007899b          	sext.w	s3,a5
 1e6:	0785                	addi	a5,a5,1
 1e8:	f4840713          	addi	a4,s0,-184
 1ec:	973e                	add	a4,a4,a5
 1ee:	fff74703          	lbu	a4,-1(a4) # 3fff <base+0x2fef>
 1f2:	fb65                	bnez	a4,1e2 <main+0x128>
    sleep(ret * 20);
 1f4:	4551                	li	a0,20
 1f6:	0295053b          	mulw	a0,a0,s1
 1fa:	00000097          	auipc	ra,0x0
 1fe:	442080e7          	jalr	1090(ra) # 63c <sleep>
    write(1, msg, len);
 202:	864e                	mv	a2,s3
 204:	f4840593          	addi	a1,s0,-184
 208:	4505                	li	a0,1
 20a:	00000097          	auipc	ra,0x0
 20e:	3c2080e7          	jalr	962(ra) # 5cc <write>
    int result = (int)sum;
 212:	f3242623          	sw	s2,-212(s0)
    write(2, &result, sizeof(result));  // Write result to stderr
 216:	4611                	li	a2,4
 218:	f2c40593          	addi	a1,s0,-212
 21c:	4509                	li	a0,2
 21e:	00000097          	auipc	ra,0x0
 222:	3ae080e7          	jalr	942(ra) # 5cc <write>
    exit(result);  // Use  exit to avoid exit message
 226:	f2c42503          	lw	a0,-212(s0)
 22a:	00000097          	auipc	ra,0x0
 22e:	37a080e7          	jalr	890(ra) # 5a4 <exit>
    printf("===> Waiting for children with waitall()\n");
 232:	00001517          	auipc	a0,0x1
 236:	90650513          	addi	a0,a0,-1786 # b38 <malloc+0x136>
 23a:	00000097          	auipc	ra,0x0
 23e:	70a080e7          	jalr	1802(ra) # 944 <printf>
    if (waitall(&n, statuses) < 0) {
 242:	fb040593          	addi	a1,s0,-80
 246:	fac40513          	addi	a0,s0,-84
 24a:	00000097          	auipc	ra,0x0
 24e:	412080e7          	jalr	1042(ra) # 65c <waitall>
 252:	06054763          	bltz	a0,2c0 <main+0x206>
    for (int i = 0; i < n; i++) {
 256:	fac42583          	lw	a1,-84(s0)
 25a:	08b05a63          	blez	a1,2ee <main+0x234>
 25e:	fb040713          	addi	a4,s0,-80
 262:	4781                	li	a5,0
    long long total = 0;
 264:	4481                	li	s1,0
      total += (long long)statuses[i];
 266:	4314                	lw	a3,0(a4)
 268:	94b6                	add	s1,s1,a3
    for (int i = 0; i < n; i++) {
 26a:	2785                	addiw	a5,a5,1
 26c:	0711                	addi	a4,a4,4
 26e:	feb79ce3          	bne	a5,a1,266 <main+0x1ac>
    printf("===> All %d children finished\n", n);
 272:	00001517          	auipc	a0,0x1
 276:	90650513          	addi	a0,a0,-1786 # b78 <malloc+0x176>
 27a:	00000097          	auipc	ra,0x0
 27e:	6ca080e7          	jalr	1738(ra) # 944 <printf>
    printf("Sum of all children's sums: %lld\n", total);
 282:	85a6                	mv	a1,s1
 284:	00001517          	auipc	a0,0x1
 288:	91450513          	addi	a0,a0,-1772 # b98 <malloc+0x196>
 28c:	00000097          	auipc	ra,0x0
 290:	6b8080e7          	jalr	1720(ra) # 944 <printf>
    if (total == expected) {
 294:	100017b7          	lui	a5,0x10001
 298:	078e                	slli	a5,a5,0x3
 29a:	04f48063          	beq	s1,a5,2da <main+0x220>
      printf("Wrong total sum: %lld (expected %lld)\n", total, expected);
 29e:	10001637          	lui	a2,0x10001
 2a2:	060e                	slli	a2,a2,0x3
 2a4:	85a6                	mv	a1,s1
 2a6:	00001517          	auipc	a0,0x1
 2aa:	93a50513          	addi	a0,a0,-1734 # be0 <malloc+0x1de>
 2ae:	00000097          	auipc	ra,0x0
 2b2:	696080e7          	jalr	1686(ra) # 944 <printf>
    exit(0);  // Use _exit in parent too
 2b6:	4501                	li	a0,0
 2b8:	00000097          	auipc	ra,0x0
 2bc:	2ec080e7          	jalr	748(ra) # 5a4 <exit>
      printf("waitall failed\n");
 2c0:	00001517          	auipc	a0,0x1
 2c4:	8a850513          	addi	a0,a0,-1880 # b68 <malloc+0x166>
 2c8:	00000097          	auipc	ra,0x0
 2cc:	67c080e7          	jalr	1660(ra) # 944 <printf>
      exit(-1);
 2d0:	557d                	li	a0,-1
 2d2:	00000097          	auipc	ra,0x0
 2d6:	2d2080e7          	jalr	722(ra) # 5a4 <exit>
      printf("Correct total sum: %lld\n", total);
 2da:	85be                	mv	a1,a5
 2dc:	00001517          	auipc	a0,0x1
 2e0:	8e450513          	addi	a0,a0,-1820 # bc0 <malloc+0x1be>
 2e4:	00000097          	auipc	ra,0x0
 2e8:	660080e7          	jalr	1632(ra) # 944 <printf>
 2ec:	b7e9                	j	2b6 <main+0x1fc>
    printf("===> All %d children finished\n", n);
 2ee:	00001517          	auipc	a0,0x1
 2f2:	88a50513          	addi	a0,a0,-1910 # b78 <malloc+0x176>
 2f6:	00000097          	auipc	ra,0x0
 2fa:	64e080e7          	jalr	1614(ra) # 944 <printf>
    printf("Sum of all children's sums: %lld\n", total);
 2fe:	4581                	li	a1,0
 300:	00001517          	auipc	a0,0x1
 304:	89850513          	addi	a0,a0,-1896 # b98 <malloc+0x196>
 308:	00000097          	auipc	ra,0x0
 30c:	63c080e7          	jalr	1596(ra) # 944 <printf>
    long long total = 0;
 310:	4481                	li	s1,0
 312:	b771                	j	29e <main+0x1e4>

0000000000000314 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 314:	1141                	addi	sp,sp,-16
 316:	e406                	sd	ra,8(sp)
 318:	e022                	sd	s0,0(sp)
 31a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 31c:	00000097          	auipc	ra,0x0
 320:	d9e080e7          	jalr	-610(ra) # ba <main>
  exit(0);
 324:	4501                	li	a0,0
 326:	00000097          	auipc	ra,0x0
 32a:	27e080e7          	jalr	638(ra) # 5a4 <exit>

000000000000032e <strcpy>:
}

char* strcpy(char *s, const char *t)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e422                	sd	s0,8(sp)
 332:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 334:	87aa                	mv	a5,a0
 336:	0585                	addi	a1,a1,1
 338:	0785                	addi	a5,a5,1
 33a:	fff5c703          	lbu	a4,-1(a1)
 33e:	fee78fa3          	sb	a4,-1(a5) # 10000fff <base+0xfffffef>
 342:	fb75                	bnez	a4,336 <strcpy+0x8>
    ;
  return os;
}
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret

000000000000034a <strcmp>:

int strcmp(const char *p, const char *q)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e422                	sd	s0,8(sp)
 34e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 350:	00054783          	lbu	a5,0(a0)
 354:	cb91                	beqz	a5,368 <strcmp+0x1e>
 356:	0005c703          	lbu	a4,0(a1)
 35a:	00f71763          	bne	a4,a5,368 <strcmp+0x1e>
    p++, q++;
 35e:	0505                	addi	a0,a0,1
 360:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 362:	00054783          	lbu	a5,0(a0)
 366:	fbe5                	bnez	a5,356 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 368:	0005c503          	lbu	a0,0(a1)
}
 36c:	40a7853b          	subw	a0,a5,a0
 370:	6422                	ld	s0,8(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret

0000000000000376 <strlen>:

uint strlen(const char *s)
{
 376:	1141                	addi	sp,sp,-16
 378:	e422                	sd	s0,8(sp)
 37a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 37c:	00054783          	lbu	a5,0(a0)
 380:	cf91                	beqz	a5,39c <strlen+0x26>
 382:	0505                	addi	a0,a0,1
 384:	87aa                	mv	a5,a0
 386:	4685                	li	a3,1
 388:	9e89                	subw	a3,a3,a0
 38a:	00f6853b          	addw	a0,a3,a5
 38e:	0785                	addi	a5,a5,1
 390:	fff7c703          	lbu	a4,-1(a5)
 394:	fb7d                	bnez	a4,38a <strlen+0x14>
    ;
  return n;
}
 396:	6422                	ld	s0,8(sp)
 398:	0141                	addi	sp,sp,16
 39a:	8082                	ret
  for(n = 0; s[n]; n++)
 39c:	4501                	li	a0,0
 39e:	bfe5                	j	396 <strlen+0x20>

00000000000003a0 <memset>:

void* memset(void *dst, int c, uint n)
{
 3a0:	1141                	addi	sp,sp,-16
 3a2:	e422                	sd	s0,8(sp)
 3a4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3a6:	ce09                	beqz	a2,3c0 <memset+0x20>
 3a8:	87aa                	mv	a5,a0
 3aa:	fff6071b          	addiw	a4,a2,-1
 3ae:	1702                	slli	a4,a4,0x20
 3b0:	9301                	srli	a4,a4,0x20
 3b2:	0705                	addi	a4,a4,1
 3b4:	972a                	add	a4,a4,a0
    cdst[i] = c;
 3b6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3ba:	0785                	addi	a5,a5,1
 3bc:	fee79de3          	bne	a5,a4,3b6 <memset+0x16>
  }
  return dst;
}
 3c0:	6422                	ld	s0,8(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret

00000000000003c6 <strchr>:

char* strchr(const char *s, char c)
{
 3c6:	1141                	addi	sp,sp,-16
 3c8:	e422                	sd	s0,8(sp)
 3ca:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3cc:	00054783          	lbu	a5,0(a0)
 3d0:	cb99                	beqz	a5,3e6 <strchr+0x20>
    if(*s == c)
 3d2:	00f58763          	beq	a1,a5,3e0 <strchr+0x1a>
  for(; *s; s++)
 3d6:	0505                	addi	a0,a0,1
 3d8:	00054783          	lbu	a5,0(a0)
 3dc:	fbfd                	bnez	a5,3d2 <strchr+0xc>
      return (char*)s;
  return 0;
 3de:	4501                	li	a0,0
}
 3e0:	6422                	ld	s0,8(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret
  return 0;
 3e6:	4501                	li	a0,0
 3e8:	bfe5                	j	3e0 <strchr+0x1a>

00000000000003ea <gets>:

char* gets(char *buf, int max)
{
 3ea:	711d                	addi	sp,sp,-96
 3ec:	ec86                	sd	ra,88(sp)
 3ee:	e8a2                	sd	s0,80(sp)
 3f0:	e4a6                	sd	s1,72(sp)
 3f2:	e0ca                	sd	s2,64(sp)
 3f4:	fc4e                	sd	s3,56(sp)
 3f6:	f852                	sd	s4,48(sp)
 3f8:	f456                	sd	s5,40(sp)
 3fa:	f05a                	sd	s6,32(sp)
 3fc:	ec5e                	sd	s7,24(sp)
 3fe:	1080                	addi	s0,sp,96
 400:	8baa                	mv	s7,a0
 402:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 404:	892a                	mv	s2,a0
 406:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 408:	4aa9                	li	s5,10
 40a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 40c:	89a6                	mv	s3,s1
 40e:	2485                	addiw	s1,s1,1
 410:	0344d863          	bge	s1,s4,440 <gets+0x56>
    cc = read(0, &c, 1);
 414:	4605                	li	a2,1
 416:	faf40593          	addi	a1,s0,-81
 41a:	4501                	li	a0,0
 41c:	00000097          	auipc	ra,0x0
 420:	1a8080e7          	jalr	424(ra) # 5c4 <read>
    if(cc < 1)
 424:	00a05e63          	blez	a0,440 <gets+0x56>
    buf[i++] = c;
 428:	faf44783          	lbu	a5,-81(s0)
 42c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 430:	01578763          	beq	a5,s5,43e <gets+0x54>
 434:	0905                	addi	s2,s2,1
 436:	fd679be3          	bne	a5,s6,40c <gets+0x22>
  for(i=0; i+1 < max; ){
 43a:	89a6                	mv	s3,s1
 43c:	a011                	j	440 <gets+0x56>
 43e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 440:	99de                	add	s3,s3,s7
 442:	00098023          	sb	zero,0(s3)
  return buf;
}
 446:	855e                	mv	a0,s7
 448:	60e6                	ld	ra,88(sp)
 44a:	6446                	ld	s0,80(sp)
 44c:	64a6                	ld	s1,72(sp)
 44e:	6906                	ld	s2,64(sp)
 450:	79e2                	ld	s3,56(sp)
 452:	7a42                	ld	s4,48(sp)
 454:	7aa2                	ld	s5,40(sp)
 456:	7b02                	ld	s6,32(sp)
 458:	6be2                	ld	s7,24(sp)
 45a:	6125                	addi	sp,sp,96
 45c:	8082                	ret

000000000000045e <stat>:

int stat(const char *n, struct stat *st)
{
 45e:	1101                	addi	sp,sp,-32
 460:	ec06                	sd	ra,24(sp)
 462:	e822                	sd	s0,16(sp)
 464:	e426                	sd	s1,8(sp)
 466:	e04a                	sd	s2,0(sp)
 468:	1000                	addi	s0,sp,32
 46a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 46c:	4581                	li	a1,0
 46e:	00000097          	auipc	ra,0x0
 472:	17e080e7          	jalr	382(ra) # 5ec <open>
  if(fd < 0)
 476:	02054563          	bltz	a0,4a0 <stat+0x42>
 47a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 47c:	85ca                	mv	a1,s2
 47e:	00000097          	auipc	ra,0x0
 482:	186080e7          	jalr	390(ra) # 604 <fstat>
 486:	892a                	mv	s2,a0
  close(fd);
 488:	8526                	mv	a0,s1
 48a:	00000097          	auipc	ra,0x0
 48e:	14a080e7          	jalr	330(ra) # 5d4 <close>
  return r;
}
 492:	854a                	mv	a0,s2
 494:	60e2                	ld	ra,24(sp)
 496:	6442                	ld	s0,16(sp)
 498:	64a2                	ld	s1,8(sp)
 49a:	6902                	ld	s2,0(sp)
 49c:	6105                	addi	sp,sp,32
 49e:	8082                	ret
    return -1;
 4a0:	597d                	li	s2,-1
 4a2:	bfc5                	j	492 <stat+0x34>

00000000000004a4 <atoi>:

int atoi(const char *s)
{
 4a4:	1141                	addi	sp,sp,-16
 4a6:	e422                	sd	s0,8(sp)
 4a8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4aa:	00054603          	lbu	a2,0(a0)
 4ae:	fd06079b          	addiw	a5,a2,-48
 4b2:	0ff7f793          	andi	a5,a5,255
 4b6:	4725                	li	a4,9
 4b8:	02f76963          	bltu	a4,a5,4ea <atoi+0x46>
 4bc:	86aa                	mv	a3,a0
  n = 0;
 4be:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4c0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4c2:	0685                	addi	a3,a3,1
 4c4:	0025179b          	slliw	a5,a0,0x2
 4c8:	9fa9                	addw	a5,a5,a0
 4ca:	0017979b          	slliw	a5,a5,0x1
 4ce:	9fb1                	addw	a5,a5,a2
 4d0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4d4:	0006c603          	lbu	a2,0(a3)
 4d8:	fd06071b          	addiw	a4,a2,-48
 4dc:	0ff77713          	andi	a4,a4,255
 4e0:	fee5f1e3          	bgeu	a1,a4,4c2 <atoi+0x1e>
  return n;
}
 4e4:	6422                	ld	s0,8(sp)
 4e6:	0141                	addi	sp,sp,16
 4e8:	8082                	ret
  n = 0;
 4ea:	4501                	li	a0,0
 4ec:	bfe5                	j	4e4 <atoi+0x40>

00000000000004ee <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 4ee:	1141                	addi	sp,sp,-16
 4f0:	e422                	sd	s0,8(sp)
 4f2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4f4:	02b57663          	bgeu	a0,a1,520 <memmove+0x32>
    while(n-- > 0)
 4f8:	02c05163          	blez	a2,51a <memmove+0x2c>
 4fc:	fff6079b          	addiw	a5,a2,-1
 500:	1782                	slli	a5,a5,0x20
 502:	9381                	srli	a5,a5,0x20
 504:	0785                	addi	a5,a5,1
 506:	97aa                	add	a5,a5,a0
  dst = vdst;
 508:	872a                	mv	a4,a0
      *dst++ = *src++;
 50a:	0585                	addi	a1,a1,1
 50c:	0705                	addi	a4,a4,1
 50e:	fff5c683          	lbu	a3,-1(a1)
 512:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 516:	fee79ae3          	bne	a5,a4,50a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 51a:	6422                	ld	s0,8(sp)
 51c:	0141                	addi	sp,sp,16
 51e:	8082                	ret
    dst += n;
 520:	00c50733          	add	a4,a0,a2
    src += n;
 524:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 526:	fec05ae3          	blez	a2,51a <memmove+0x2c>
 52a:	fff6079b          	addiw	a5,a2,-1
 52e:	1782                	slli	a5,a5,0x20
 530:	9381                	srli	a5,a5,0x20
 532:	fff7c793          	not	a5,a5
 536:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 538:	15fd                	addi	a1,a1,-1
 53a:	177d                	addi	a4,a4,-1
 53c:	0005c683          	lbu	a3,0(a1)
 540:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 544:	fee79ae3          	bne	a5,a4,538 <memmove+0x4a>
 548:	bfc9                	j	51a <memmove+0x2c>

000000000000054a <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 54a:	1141                	addi	sp,sp,-16
 54c:	e422                	sd	s0,8(sp)
 54e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 550:	ca05                	beqz	a2,580 <memcmp+0x36>
 552:	fff6069b          	addiw	a3,a2,-1
 556:	1682                	slli	a3,a3,0x20
 558:	9281                	srli	a3,a3,0x20
 55a:	0685                	addi	a3,a3,1
 55c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 55e:	00054783          	lbu	a5,0(a0)
 562:	0005c703          	lbu	a4,0(a1)
 566:	00e79863          	bne	a5,a4,576 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 56a:	0505                	addi	a0,a0,1
    p2++;
 56c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 56e:	fed518e3          	bne	a0,a3,55e <memcmp+0x14>
  }
  return 0;
 572:	4501                	li	a0,0
 574:	a019                	j	57a <memcmp+0x30>
      return *p1 - *p2;
 576:	40e7853b          	subw	a0,a5,a4
}
 57a:	6422                	ld	s0,8(sp)
 57c:	0141                	addi	sp,sp,16
 57e:	8082                	ret
  return 0;
 580:	4501                	li	a0,0
 582:	bfe5                	j	57a <memcmp+0x30>

0000000000000584 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 584:	1141                	addi	sp,sp,-16
 586:	e406                	sd	ra,8(sp)
 588:	e022                	sd	s0,0(sp)
 58a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 58c:	00000097          	auipc	ra,0x0
 590:	f62080e7          	jalr	-158(ra) # 4ee <memmove>
}
 594:	60a2                	ld	ra,8(sp)
 596:	6402                	ld	s0,0(sp)
 598:	0141                	addi	sp,sp,16
 59a:	8082                	ret

000000000000059c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 59c:	4885                	li	a7,1
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5a4:	4889                	li	a7,2
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 5ac:	48e1                	li	a7,24
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5b4:	488d                	li	a7,3
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5bc:	4891                	li	a7,4
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <read>:
.global read
read:
 li a7, SYS_read
 5c4:	4895                	li	a7,5
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <write>:
.global write
write:
 li a7, SYS_write
 5cc:	48c1                	li	a7,16
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <close>:
.global close
close:
 li a7, SYS_close
 5d4:	48d5                	li	a7,21
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <kill>:
.global kill
kill:
 li a7, SYS_kill
 5dc:	4899                	li	a7,6
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5e4:	489d                	li	a7,7
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <open>:
.global open
open:
 li a7, SYS_open
 5ec:	48bd                	li	a7,15
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5f4:	48c5                	li	a7,17
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5fc:	48c9                	li	a7,18
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 604:	48a1                	li	a7,8
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <link>:
.global link
link:
 li a7, SYS_link
 60c:	48cd                	li	a7,19
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 614:	48d1                	li	a7,20
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 61c:	48a5                	li	a7,9
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <dup>:
.global dup
dup:
 li a7, SYS_dup
 624:	48a9                	li	a7,10
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 62c:	48ad                	li	a7,11
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 634:	48b1                	li	a7,12
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 63c:	48b5                	li	a7,13
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 644:	48b9                	li	a7,14
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 64c:	48dd                	li	a7,23
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 654:	48e5                	li	a7,25
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 65c:	48e9                	li	a7,26
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 664:	48ed                	li	a7,27
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 66c:	1101                	addi	sp,sp,-32
 66e:	ec06                	sd	ra,24(sp)
 670:	e822                	sd	s0,16(sp)
 672:	1000                	addi	s0,sp,32
 674:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 678:	4605                	li	a2,1
 67a:	fef40593          	addi	a1,s0,-17
 67e:	00000097          	auipc	ra,0x0
 682:	f4e080e7          	jalr	-178(ra) # 5cc <write>
}
 686:	60e2                	ld	ra,24(sp)
 688:	6442                	ld	s0,16(sp)
 68a:	6105                	addi	sp,sp,32
 68c:	8082                	ret

000000000000068e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 68e:	7139                	addi	sp,sp,-64
 690:	fc06                	sd	ra,56(sp)
 692:	f822                	sd	s0,48(sp)
 694:	f426                	sd	s1,40(sp)
 696:	f04a                	sd	s2,32(sp)
 698:	ec4e                	sd	s3,24(sp)
 69a:	0080                	addi	s0,sp,64
 69c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 69e:	c299                	beqz	a3,6a4 <printint+0x16>
 6a0:	0805c863          	bltz	a1,730 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6a4:	2581                	sext.w	a1,a1
  neg = 0;
 6a6:	4881                	li	a7,0
 6a8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6ac:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6ae:	2601                	sext.w	a2,a2
 6b0:	00000517          	auipc	a0,0x0
 6b4:	5c850513          	addi	a0,a0,1480 # c78 <digits>
 6b8:	883a                	mv	a6,a4
 6ba:	2705                	addiw	a4,a4,1
 6bc:	02c5f7bb          	remuw	a5,a1,a2
 6c0:	1782                	slli	a5,a5,0x20
 6c2:	9381                	srli	a5,a5,0x20
 6c4:	97aa                	add	a5,a5,a0
 6c6:	0007c783          	lbu	a5,0(a5)
 6ca:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6ce:	0005879b          	sext.w	a5,a1
 6d2:	02c5d5bb          	divuw	a1,a1,a2
 6d6:	0685                	addi	a3,a3,1
 6d8:	fec7f0e3          	bgeu	a5,a2,6b8 <printint+0x2a>
  if(neg)
 6dc:	00088b63          	beqz	a7,6f2 <printint+0x64>
    buf[i++] = '-';
 6e0:	fd040793          	addi	a5,s0,-48
 6e4:	973e                	add	a4,a4,a5
 6e6:	02d00793          	li	a5,45
 6ea:	fef70823          	sb	a5,-16(a4)
 6ee:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6f2:	02e05863          	blez	a4,722 <printint+0x94>
 6f6:	fc040793          	addi	a5,s0,-64
 6fa:	00e78933          	add	s2,a5,a4
 6fe:	fff78993          	addi	s3,a5,-1
 702:	99ba                	add	s3,s3,a4
 704:	377d                	addiw	a4,a4,-1
 706:	1702                	slli	a4,a4,0x20
 708:	9301                	srli	a4,a4,0x20
 70a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 70e:	fff94583          	lbu	a1,-1(s2)
 712:	8526                	mv	a0,s1
 714:	00000097          	auipc	ra,0x0
 718:	f58080e7          	jalr	-168(ra) # 66c <putc>
  while(--i >= 0)
 71c:	197d                	addi	s2,s2,-1
 71e:	ff3918e3          	bne	s2,s3,70e <printint+0x80>
}
 722:	70e2                	ld	ra,56(sp)
 724:	7442                	ld	s0,48(sp)
 726:	74a2                	ld	s1,40(sp)
 728:	7902                	ld	s2,32(sp)
 72a:	69e2                	ld	s3,24(sp)
 72c:	6121                	addi	sp,sp,64
 72e:	8082                	ret
    x = -xx;
 730:	40b005bb          	negw	a1,a1
    neg = 1;
 734:	4885                	li	a7,1
    x = -xx;
 736:	bf8d                	j	6a8 <printint+0x1a>

0000000000000738 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 738:	7119                	addi	sp,sp,-128
 73a:	fc86                	sd	ra,120(sp)
 73c:	f8a2                	sd	s0,112(sp)
 73e:	f4a6                	sd	s1,104(sp)
 740:	f0ca                	sd	s2,96(sp)
 742:	ecce                	sd	s3,88(sp)
 744:	e8d2                	sd	s4,80(sp)
 746:	e4d6                	sd	s5,72(sp)
 748:	e0da                	sd	s6,64(sp)
 74a:	fc5e                	sd	s7,56(sp)
 74c:	f862                	sd	s8,48(sp)
 74e:	f466                	sd	s9,40(sp)
 750:	f06a                	sd	s10,32(sp)
 752:	ec6e                	sd	s11,24(sp)
 754:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 756:	0005c903          	lbu	s2,0(a1)
 75a:	18090f63          	beqz	s2,8f8 <vprintf+0x1c0>
 75e:	8aaa                	mv	s5,a0
 760:	8b32                	mv	s6,a2
 762:	00158493          	addi	s1,a1,1
  state = 0;
 766:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 768:	02500a13          	li	s4,37
      if(c == 'd'){
 76c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 770:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 774:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 778:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 77c:	00000b97          	auipc	s7,0x0
 780:	4fcb8b93          	addi	s7,s7,1276 # c78 <digits>
 784:	a839                	j	7a2 <vprintf+0x6a>
        putc(fd, c);
 786:	85ca                	mv	a1,s2
 788:	8556                	mv	a0,s5
 78a:	00000097          	auipc	ra,0x0
 78e:	ee2080e7          	jalr	-286(ra) # 66c <putc>
 792:	a019                	j	798 <vprintf+0x60>
    } else if(state == '%'){
 794:	01498f63          	beq	s3,s4,7b2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 798:	0485                	addi	s1,s1,1
 79a:	fff4c903          	lbu	s2,-1(s1)
 79e:	14090d63          	beqz	s2,8f8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 7a2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7a6:	fe0997e3          	bnez	s3,794 <vprintf+0x5c>
      if(c == '%'){
 7aa:	fd479ee3          	bne	a5,s4,786 <vprintf+0x4e>
        state = '%';
 7ae:	89be                	mv	s3,a5
 7b0:	b7e5                	j	798 <vprintf+0x60>
      if(c == 'd'){
 7b2:	05878063          	beq	a5,s8,7f2 <vprintf+0xba>
      } else if(c == 'l') {
 7b6:	05978c63          	beq	a5,s9,80e <vprintf+0xd6>
      } else if(c == 'x') {
 7ba:	07a78863          	beq	a5,s10,82a <vprintf+0xf2>
      } else if(c == 'p') {
 7be:	09b78463          	beq	a5,s11,846 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7c2:	07300713          	li	a4,115
 7c6:	0ce78663          	beq	a5,a4,892 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7ca:	06300713          	li	a4,99
 7ce:	0ee78e63          	beq	a5,a4,8ca <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7d2:	11478863          	beq	a5,s4,8e2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7d6:	85d2                	mv	a1,s4
 7d8:	8556                	mv	a0,s5
 7da:	00000097          	auipc	ra,0x0
 7de:	e92080e7          	jalr	-366(ra) # 66c <putc>
        putc(fd, c);
 7e2:	85ca                	mv	a1,s2
 7e4:	8556                	mv	a0,s5
 7e6:	00000097          	auipc	ra,0x0
 7ea:	e86080e7          	jalr	-378(ra) # 66c <putc>
      }
      state = 0;
 7ee:	4981                	li	s3,0
 7f0:	b765                	j	798 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7f2:	008b0913          	addi	s2,s6,8
 7f6:	4685                	li	a3,1
 7f8:	4629                	li	a2,10
 7fa:	000b2583          	lw	a1,0(s6)
 7fe:	8556                	mv	a0,s5
 800:	00000097          	auipc	ra,0x0
 804:	e8e080e7          	jalr	-370(ra) # 68e <printint>
 808:	8b4a                	mv	s6,s2
      state = 0;
 80a:	4981                	li	s3,0
 80c:	b771                	j	798 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 80e:	008b0913          	addi	s2,s6,8
 812:	4681                	li	a3,0
 814:	4629                	li	a2,10
 816:	000b2583          	lw	a1,0(s6)
 81a:	8556                	mv	a0,s5
 81c:	00000097          	auipc	ra,0x0
 820:	e72080e7          	jalr	-398(ra) # 68e <printint>
 824:	8b4a                	mv	s6,s2
      state = 0;
 826:	4981                	li	s3,0
 828:	bf85                	j	798 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 82a:	008b0913          	addi	s2,s6,8
 82e:	4681                	li	a3,0
 830:	4641                	li	a2,16
 832:	000b2583          	lw	a1,0(s6)
 836:	8556                	mv	a0,s5
 838:	00000097          	auipc	ra,0x0
 83c:	e56080e7          	jalr	-426(ra) # 68e <printint>
 840:	8b4a                	mv	s6,s2
      state = 0;
 842:	4981                	li	s3,0
 844:	bf91                	j	798 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 846:	008b0793          	addi	a5,s6,8
 84a:	f8f43423          	sd	a5,-120(s0)
 84e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 852:	03000593          	li	a1,48
 856:	8556                	mv	a0,s5
 858:	00000097          	auipc	ra,0x0
 85c:	e14080e7          	jalr	-492(ra) # 66c <putc>
  putc(fd, 'x');
 860:	85ea                	mv	a1,s10
 862:	8556                	mv	a0,s5
 864:	00000097          	auipc	ra,0x0
 868:	e08080e7          	jalr	-504(ra) # 66c <putc>
 86c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 86e:	03c9d793          	srli	a5,s3,0x3c
 872:	97de                	add	a5,a5,s7
 874:	0007c583          	lbu	a1,0(a5)
 878:	8556                	mv	a0,s5
 87a:	00000097          	auipc	ra,0x0
 87e:	df2080e7          	jalr	-526(ra) # 66c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 882:	0992                	slli	s3,s3,0x4
 884:	397d                	addiw	s2,s2,-1
 886:	fe0914e3          	bnez	s2,86e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 88a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 88e:	4981                	li	s3,0
 890:	b721                	j	798 <vprintf+0x60>
        s = va_arg(ap, char*);
 892:	008b0993          	addi	s3,s6,8
 896:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 89a:	02090163          	beqz	s2,8bc <vprintf+0x184>
        while(*s != 0){
 89e:	00094583          	lbu	a1,0(s2)
 8a2:	c9a1                	beqz	a1,8f2 <vprintf+0x1ba>
          putc(fd, *s);
 8a4:	8556                	mv	a0,s5
 8a6:	00000097          	auipc	ra,0x0
 8aa:	dc6080e7          	jalr	-570(ra) # 66c <putc>
          s++;
 8ae:	0905                	addi	s2,s2,1
        while(*s != 0){
 8b0:	00094583          	lbu	a1,0(s2)
 8b4:	f9e5                	bnez	a1,8a4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 8b6:	8b4e                	mv	s6,s3
      state = 0;
 8b8:	4981                	li	s3,0
 8ba:	bdf9                	j	798 <vprintf+0x60>
          s = "(null)";
 8bc:	00000917          	auipc	s2,0x0
 8c0:	3b490913          	addi	s2,s2,948 # c70 <malloc+0x26e>
        while(*s != 0){
 8c4:	02800593          	li	a1,40
 8c8:	bff1                	j	8a4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8ca:	008b0913          	addi	s2,s6,8
 8ce:	000b4583          	lbu	a1,0(s6)
 8d2:	8556                	mv	a0,s5
 8d4:	00000097          	auipc	ra,0x0
 8d8:	d98080e7          	jalr	-616(ra) # 66c <putc>
 8dc:	8b4a                	mv	s6,s2
      state = 0;
 8de:	4981                	li	s3,0
 8e0:	bd65                	j	798 <vprintf+0x60>
        putc(fd, c);
 8e2:	85d2                	mv	a1,s4
 8e4:	8556                	mv	a0,s5
 8e6:	00000097          	auipc	ra,0x0
 8ea:	d86080e7          	jalr	-634(ra) # 66c <putc>
      state = 0;
 8ee:	4981                	li	s3,0
 8f0:	b565                	j	798 <vprintf+0x60>
        s = va_arg(ap, char*);
 8f2:	8b4e                	mv	s6,s3
      state = 0;
 8f4:	4981                	li	s3,0
 8f6:	b54d                	j	798 <vprintf+0x60>
    }
  }
}
 8f8:	70e6                	ld	ra,120(sp)
 8fa:	7446                	ld	s0,112(sp)
 8fc:	74a6                	ld	s1,104(sp)
 8fe:	7906                	ld	s2,96(sp)
 900:	69e6                	ld	s3,88(sp)
 902:	6a46                	ld	s4,80(sp)
 904:	6aa6                	ld	s5,72(sp)
 906:	6b06                	ld	s6,64(sp)
 908:	7be2                	ld	s7,56(sp)
 90a:	7c42                	ld	s8,48(sp)
 90c:	7ca2                	ld	s9,40(sp)
 90e:	7d02                	ld	s10,32(sp)
 910:	6de2                	ld	s11,24(sp)
 912:	6109                	addi	sp,sp,128
 914:	8082                	ret

0000000000000916 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 916:	715d                	addi	sp,sp,-80
 918:	ec06                	sd	ra,24(sp)
 91a:	e822                	sd	s0,16(sp)
 91c:	1000                	addi	s0,sp,32
 91e:	e010                	sd	a2,0(s0)
 920:	e414                	sd	a3,8(s0)
 922:	e818                	sd	a4,16(s0)
 924:	ec1c                	sd	a5,24(s0)
 926:	03043023          	sd	a6,32(s0)
 92a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 92e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 932:	8622                	mv	a2,s0
 934:	00000097          	auipc	ra,0x0
 938:	e04080e7          	jalr	-508(ra) # 738 <vprintf>
}
 93c:	60e2                	ld	ra,24(sp)
 93e:	6442                	ld	s0,16(sp)
 940:	6161                	addi	sp,sp,80
 942:	8082                	ret

0000000000000944 <printf>:

void
printf(const char *fmt, ...)
{
 944:	711d                	addi	sp,sp,-96
 946:	ec06                	sd	ra,24(sp)
 948:	e822                	sd	s0,16(sp)
 94a:	1000                	addi	s0,sp,32
 94c:	e40c                	sd	a1,8(s0)
 94e:	e810                	sd	a2,16(s0)
 950:	ec14                	sd	a3,24(s0)
 952:	f018                	sd	a4,32(s0)
 954:	f41c                	sd	a5,40(s0)
 956:	03043823          	sd	a6,48(s0)
 95a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 95e:	00840613          	addi	a2,s0,8
 962:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 966:	85aa                	mv	a1,a0
 968:	4505                	li	a0,1
 96a:	00000097          	auipc	ra,0x0
 96e:	dce080e7          	jalr	-562(ra) # 738 <vprintf>
}
 972:	60e2                	ld	ra,24(sp)
 974:	6442                	ld	s0,16(sp)
 976:	6125                	addi	sp,sp,96
 978:	8082                	ret

000000000000097a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 97a:	1141                	addi	sp,sp,-16
 97c:	e422                	sd	s0,8(sp)
 97e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 980:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 984:	00000797          	auipc	a5,0x0
 988:	67c7b783          	ld	a5,1660(a5) # 1000 <freep>
 98c:	a805                	j	9bc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 98e:	4618                	lw	a4,8(a2)
 990:	9db9                	addw	a1,a1,a4
 992:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 996:	6398                	ld	a4,0(a5)
 998:	6318                	ld	a4,0(a4)
 99a:	fee53823          	sd	a4,-16(a0)
 99e:	a091                	j	9e2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9a0:	ff852703          	lw	a4,-8(a0)
 9a4:	9e39                	addw	a2,a2,a4
 9a6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9a8:	ff053703          	ld	a4,-16(a0)
 9ac:	e398                	sd	a4,0(a5)
 9ae:	a099                	j	9f4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b0:	6398                	ld	a4,0(a5)
 9b2:	00e7e463          	bltu	a5,a4,9ba <free+0x40>
 9b6:	00e6ea63          	bltu	a3,a4,9ca <free+0x50>
{
 9ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9bc:	fed7fae3          	bgeu	a5,a3,9b0 <free+0x36>
 9c0:	6398                	ld	a4,0(a5)
 9c2:	00e6e463          	bltu	a3,a4,9ca <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c6:	fee7eae3          	bltu	a5,a4,9ba <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9ca:	ff852583          	lw	a1,-8(a0)
 9ce:	6390                	ld	a2,0(a5)
 9d0:	02059713          	slli	a4,a1,0x20
 9d4:	9301                	srli	a4,a4,0x20
 9d6:	0712                	slli	a4,a4,0x4
 9d8:	9736                	add	a4,a4,a3
 9da:	fae60ae3          	beq	a2,a4,98e <free+0x14>
    bp->s.ptr = p->s.ptr;
 9de:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9e2:	4790                	lw	a2,8(a5)
 9e4:	02061713          	slli	a4,a2,0x20
 9e8:	9301                	srli	a4,a4,0x20
 9ea:	0712                	slli	a4,a4,0x4
 9ec:	973e                	add	a4,a4,a5
 9ee:	fae689e3          	beq	a3,a4,9a0 <free+0x26>
  } else
    p->s.ptr = bp;
 9f2:	e394                	sd	a3,0(a5)
  freep = p;
 9f4:	00000717          	auipc	a4,0x0
 9f8:	60f73623          	sd	a5,1548(a4) # 1000 <freep>
}
 9fc:	6422                	ld	s0,8(sp)
 9fe:	0141                	addi	sp,sp,16
 a00:	8082                	ret

0000000000000a02 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a02:	7139                	addi	sp,sp,-64
 a04:	fc06                	sd	ra,56(sp)
 a06:	f822                	sd	s0,48(sp)
 a08:	f426                	sd	s1,40(sp)
 a0a:	f04a                	sd	s2,32(sp)
 a0c:	ec4e                	sd	s3,24(sp)
 a0e:	e852                	sd	s4,16(sp)
 a10:	e456                	sd	s5,8(sp)
 a12:	e05a                	sd	s6,0(sp)
 a14:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a16:	02051493          	slli	s1,a0,0x20
 a1a:	9081                	srli	s1,s1,0x20
 a1c:	04bd                	addi	s1,s1,15
 a1e:	8091                	srli	s1,s1,0x4
 a20:	0014899b          	addiw	s3,s1,1
 a24:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a26:	00000517          	auipc	a0,0x0
 a2a:	5da53503          	ld	a0,1498(a0) # 1000 <freep>
 a2e:	c515                	beqz	a0,a5a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a30:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a32:	4798                	lw	a4,8(a5)
 a34:	02977f63          	bgeu	a4,s1,a72 <malloc+0x70>
 a38:	8a4e                	mv	s4,s3
 a3a:	0009871b          	sext.w	a4,s3
 a3e:	6685                	lui	a3,0x1
 a40:	00d77363          	bgeu	a4,a3,a46 <malloc+0x44>
 a44:	6a05                	lui	s4,0x1
 a46:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a4a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a4e:	00000917          	auipc	s2,0x0
 a52:	5b290913          	addi	s2,s2,1458 # 1000 <freep>
  if(p == (char*)-1)
 a56:	5afd                	li	s5,-1
 a58:	a88d                	j	aca <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a5a:	00000797          	auipc	a5,0x0
 a5e:	5b678793          	addi	a5,a5,1462 # 1010 <base>
 a62:	00000717          	auipc	a4,0x0
 a66:	58f73f23          	sd	a5,1438(a4) # 1000 <freep>
 a6a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a6c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a70:	b7e1                	j	a38 <malloc+0x36>
      if(p->s.size == nunits)
 a72:	02e48b63          	beq	s1,a4,aa8 <malloc+0xa6>
        p->s.size -= nunits;
 a76:	4137073b          	subw	a4,a4,s3
 a7a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a7c:	1702                	slli	a4,a4,0x20
 a7e:	9301                	srli	a4,a4,0x20
 a80:	0712                	slli	a4,a4,0x4
 a82:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a84:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a88:	00000717          	auipc	a4,0x0
 a8c:	56a73c23          	sd	a0,1400(a4) # 1000 <freep>
      return (void*)(p + 1);
 a90:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a94:	70e2                	ld	ra,56(sp)
 a96:	7442                	ld	s0,48(sp)
 a98:	74a2                	ld	s1,40(sp)
 a9a:	7902                	ld	s2,32(sp)
 a9c:	69e2                	ld	s3,24(sp)
 a9e:	6a42                	ld	s4,16(sp)
 aa0:	6aa2                	ld	s5,8(sp)
 aa2:	6b02                	ld	s6,0(sp)
 aa4:	6121                	addi	sp,sp,64
 aa6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 aa8:	6398                	ld	a4,0(a5)
 aaa:	e118                	sd	a4,0(a0)
 aac:	bff1                	j	a88 <malloc+0x86>
  hp->s.size = nu;
 aae:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ab2:	0541                	addi	a0,a0,16
 ab4:	00000097          	auipc	ra,0x0
 ab8:	ec6080e7          	jalr	-314(ra) # 97a <free>
  return freep;
 abc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ac0:	d971                	beqz	a0,a94 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ac4:	4798                	lw	a4,8(a5)
 ac6:	fa9776e3          	bgeu	a4,s1,a72 <malloc+0x70>
    if(p == freep)
 aca:	00093703          	ld	a4,0(s2)
 ace:	853e                	mv	a0,a5
 ad0:	fef719e3          	bne	a4,a5,ac2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 ad4:	8552                	mv	a0,s4
 ad6:	00000097          	auipc	ra,0x0
 ada:	b5e080e7          	jalr	-1186(ra) # 634 <sbrk>
  if(p == (char*)-1)
 ade:	fd5518e3          	bne	a0,s5,aae <malloc+0xac>
        return 0;
 ae2:	4501                	li	a0,0
 ae4:	bf45                	j	a94 <malloc+0x92>
