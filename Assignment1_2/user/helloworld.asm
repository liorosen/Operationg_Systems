
user/_helloworld:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main() {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("Hello World xv6\n");
   8:	00000517          	auipc	a0,0x0
   c:	7f850513          	addi	a0,a0,2040 # 800 <malloc+0xf0>
  10:	00000097          	auipc	ra,0x0
  14:	642080e7          	jalr	1602(ra) # 652 <printf>
  exit(0);
  18:	4501                	li	a0,0
  1a:	00000097          	auipc	ra,0x0
  1e:	298080e7          	jalr	664(ra) # 2b2 <exit>

0000000000000022 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
  22:	1141                	addi	sp,sp,-16
  24:	e406                	sd	ra,8(sp)
  26:	e022                	sd	s0,0(sp)
  28:	0800                	addi	s0,sp,16
  extern int main();
  main();
  2a:	00000097          	auipc	ra,0x0
  2e:	fd6080e7          	jalr	-42(ra) # 0 <main>
  exit(0);
  32:	4501                	li	a0,0
  34:	00000097          	auipc	ra,0x0
  38:	27e080e7          	jalr	638(ra) # 2b2 <exit>

000000000000003c <strcpy>:
}

char* strcpy(char *s, const char *t)
{
  3c:	1141                	addi	sp,sp,-16
  3e:	e422                	sd	s0,8(sp)
  40:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  42:	87aa                	mv	a5,a0
  44:	0585                	addi	a1,a1,1
  46:	0785                	addi	a5,a5,1
  48:	fff5c703          	lbu	a4,-1(a1)
  4c:	fee78fa3          	sb	a4,-1(a5)
  50:	fb75                	bnez	a4,44 <strcpy+0x8>
    ;
  return os;
}
  52:	6422                	ld	s0,8(sp)
  54:	0141                	addi	sp,sp,16
  56:	8082                	ret

0000000000000058 <strcmp>:

int strcmp(const char *p, const char *q)
{
  58:	1141                	addi	sp,sp,-16
  5a:	e422                	sd	s0,8(sp)
  5c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  5e:	00054783          	lbu	a5,0(a0)
  62:	cb91                	beqz	a5,76 <strcmp+0x1e>
  64:	0005c703          	lbu	a4,0(a1)
  68:	00f71763          	bne	a4,a5,76 <strcmp+0x1e>
    p++, q++;
  6c:	0505                	addi	a0,a0,1
  6e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  70:	00054783          	lbu	a5,0(a0)
  74:	fbe5                	bnez	a5,64 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  76:	0005c503          	lbu	a0,0(a1)
}
  7a:	40a7853b          	subw	a0,a5,a0
  7e:	6422                	ld	s0,8(sp)
  80:	0141                	addi	sp,sp,16
  82:	8082                	ret

0000000000000084 <strlen>:

uint strlen(const char *s)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  8a:	00054783          	lbu	a5,0(a0)
  8e:	cf91                	beqz	a5,aa <strlen+0x26>
  90:	0505                	addi	a0,a0,1
  92:	87aa                	mv	a5,a0
  94:	4685                	li	a3,1
  96:	9e89                	subw	a3,a3,a0
  98:	00f6853b          	addw	a0,a3,a5
  9c:	0785                	addi	a5,a5,1
  9e:	fff7c703          	lbu	a4,-1(a5)
  a2:	fb7d                	bnez	a4,98 <strlen+0x14>
    ;
  return n;
}
  a4:	6422                	ld	s0,8(sp)
  a6:	0141                	addi	sp,sp,16
  a8:	8082                	ret
  for(n = 0; s[n]; n++)
  aa:	4501                	li	a0,0
  ac:	bfe5                	j	a4 <strlen+0x20>

00000000000000ae <memset>:

void* memset(void *dst, int c, uint n)
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e422                	sd	s0,8(sp)
  b2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  b4:	ce09                	beqz	a2,ce <memset+0x20>
  b6:	87aa                	mv	a5,a0
  b8:	fff6071b          	addiw	a4,a2,-1
  bc:	1702                	slli	a4,a4,0x20
  be:	9301                	srli	a4,a4,0x20
  c0:	0705                	addi	a4,a4,1
  c2:	972a                	add	a4,a4,a0
    cdst[i] = c;
  c4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  c8:	0785                	addi	a5,a5,1
  ca:	fee79de3          	bne	a5,a4,c4 <memset+0x16>
  }
  return dst;
}
  ce:	6422                	ld	s0,8(sp)
  d0:	0141                	addi	sp,sp,16
  d2:	8082                	ret

00000000000000d4 <strchr>:

char* strchr(const char *s, char c)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  for(; *s; s++)
  da:	00054783          	lbu	a5,0(a0)
  de:	cb99                	beqz	a5,f4 <strchr+0x20>
    if(*s == c)
  e0:	00f58763          	beq	a1,a5,ee <strchr+0x1a>
  for(; *s; s++)
  e4:	0505                	addi	a0,a0,1
  e6:	00054783          	lbu	a5,0(a0)
  ea:	fbfd                	bnez	a5,e0 <strchr+0xc>
      return (char*)s;
  return 0;
  ec:	4501                	li	a0,0
}
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret
  return 0;
  f4:	4501                	li	a0,0
  f6:	bfe5                	j	ee <strchr+0x1a>

00000000000000f8 <gets>:

char* gets(char *buf, int max)
{
  f8:	711d                	addi	sp,sp,-96
  fa:	ec86                	sd	ra,88(sp)
  fc:	e8a2                	sd	s0,80(sp)
  fe:	e4a6                	sd	s1,72(sp)
 100:	e0ca                	sd	s2,64(sp)
 102:	fc4e                	sd	s3,56(sp)
 104:	f852                	sd	s4,48(sp)
 106:	f456                	sd	s5,40(sp)
 108:	f05a                	sd	s6,32(sp)
 10a:	ec5e                	sd	s7,24(sp)
 10c:	1080                	addi	s0,sp,96
 10e:	8baa                	mv	s7,a0
 110:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 112:	892a                	mv	s2,a0
 114:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 116:	4aa9                	li	s5,10
 118:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 11a:	89a6                	mv	s3,s1
 11c:	2485                	addiw	s1,s1,1
 11e:	0344d863          	bge	s1,s4,14e <gets+0x56>
    cc = read(0, &c, 1);
 122:	4605                	li	a2,1
 124:	faf40593          	addi	a1,s0,-81
 128:	4501                	li	a0,0
 12a:	00000097          	auipc	ra,0x0
 12e:	1a8080e7          	jalr	424(ra) # 2d2 <read>
    if(cc < 1)
 132:	00a05e63          	blez	a0,14e <gets+0x56>
    buf[i++] = c;
 136:	faf44783          	lbu	a5,-81(s0)
 13a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 13e:	01578763          	beq	a5,s5,14c <gets+0x54>
 142:	0905                	addi	s2,s2,1
 144:	fd679be3          	bne	a5,s6,11a <gets+0x22>
  for(i=0; i+1 < max; ){
 148:	89a6                	mv	s3,s1
 14a:	a011                	j	14e <gets+0x56>
 14c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 14e:	99de                	add	s3,s3,s7
 150:	00098023          	sb	zero,0(s3)
  return buf;
}
 154:	855e                	mv	a0,s7
 156:	60e6                	ld	ra,88(sp)
 158:	6446                	ld	s0,80(sp)
 15a:	64a6                	ld	s1,72(sp)
 15c:	6906                	ld	s2,64(sp)
 15e:	79e2                	ld	s3,56(sp)
 160:	7a42                	ld	s4,48(sp)
 162:	7aa2                	ld	s5,40(sp)
 164:	7b02                	ld	s6,32(sp)
 166:	6be2                	ld	s7,24(sp)
 168:	6125                	addi	sp,sp,96
 16a:	8082                	ret

000000000000016c <stat>:

int stat(const char *n, struct stat *st)
{
 16c:	1101                	addi	sp,sp,-32
 16e:	ec06                	sd	ra,24(sp)
 170:	e822                	sd	s0,16(sp)
 172:	e426                	sd	s1,8(sp)
 174:	e04a                	sd	s2,0(sp)
 176:	1000                	addi	s0,sp,32
 178:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17a:	4581                	li	a1,0
 17c:	00000097          	auipc	ra,0x0
 180:	17e080e7          	jalr	382(ra) # 2fa <open>
  if(fd < 0)
 184:	02054563          	bltz	a0,1ae <stat+0x42>
 188:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 18a:	85ca                	mv	a1,s2
 18c:	00000097          	auipc	ra,0x0
 190:	186080e7          	jalr	390(ra) # 312 <fstat>
 194:	892a                	mv	s2,a0
  close(fd);
 196:	8526                	mv	a0,s1
 198:	00000097          	auipc	ra,0x0
 19c:	14a080e7          	jalr	330(ra) # 2e2 <close>
  return r;
}
 1a0:	854a                	mv	a0,s2
 1a2:	60e2                	ld	ra,24(sp)
 1a4:	6442                	ld	s0,16(sp)
 1a6:	64a2                	ld	s1,8(sp)
 1a8:	6902                	ld	s2,0(sp)
 1aa:	6105                	addi	sp,sp,32
 1ac:	8082                	ret
    return -1;
 1ae:	597d                	li	s2,-1
 1b0:	bfc5                	j	1a0 <stat+0x34>

00000000000001b2 <atoi>:

int atoi(const char *s)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e422                	sd	s0,8(sp)
 1b6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1b8:	00054603          	lbu	a2,0(a0)
 1bc:	fd06079b          	addiw	a5,a2,-48
 1c0:	0ff7f793          	andi	a5,a5,255
 1c4:	4725                	li	a4,9
 1c6:	02f76963          	bltu	a4,a5,1f8 <atoi+0x46>
 1ca:	86aa                	mv	a3,a0
  n = 0;
 1cc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1ce:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1d0:	0685                	addi	a3,a3,1
 1d2:	0025179b          	slliw	a5,a0,0x2
 1d6:	9fa9                	addw	a5,a5,a0
 1d8:	0017979b          	slliw	a5,a5,0x1
 1dc:	9fb1                	addw	a5,a5,a2
 1de:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e2:	0006c603          	lbu	a2,0(a3)
 1e6:	fd06071b          	addiw	a4,a2,-48
 1ea:	0ff77713          	andi	a4,a4,255
 1ee:	fee5f1e3          	bgeu	a1,a4,1d0 <atoi+0x1e>
  return n;
}
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret
  n = 0;
 1f8:	4501                	li	a0,0
 1fa:	bfe5                	j	1f2 <atoi+0x40>

00000000000001fc <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 1fc:	1141                	addi	sp,sp,-16
 1fe:	e422                	sd	s0,8(sp)
 200:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 202:	02b57663          	bgeu	a0,a1,22e <memmove+0x32>
    while(n-- > 0)
 206:	02c05163          	blez	a2,228 <memmove+0x2c>
 20a:	fff6079b          	addiw	a5,a2,-1
 20e:	1782                	slli	a5,a5,0x20
 210:	9381                	srli	a5,a5,0x20
 212:	0785                	addi	a5,a5,1
 214:	97aa                	add	a5,a5,a0
  dst = vdst;
 216:	872a                	mv	a4,a0
      *dst++ = *src++;
 218:	0585                	addi	a1,a1,1
 21a:	0705                	addi	a4,a4,1
 21c:	fff5c683          	lbu	a3,-1(a1)
 220:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 224:	fee79ae3          	bne	a5,a4,218 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
    dst += n;
 22e:	00c50733          	add	a4,a0,a2
    src += n;
 232:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 234:	fec05ae3          	blez	a2,228 <memmove+0x2c>
 238:	fff6079b          	addiw	a5,a2,-1
 23c:	1782                	slli	a5,a5,0x20
 23e:	9381                	srli	a5,a5,0x20
 240:	fff7c793          	not	a5,a5
 244:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 246:	15fd                	addi	a1,a1,-1
 248:	177d                	addi	a4,a4,-1
 24a:	0005c683          	lbu	a3,0(a1)
 24e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 252:	fee79ae3          	bne	a5,a4,246 <memmove+0x4a>
 256:	bfc9                	j	228 <memmove+0x2c>

0000000000000258 <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 25e:	ca05                	beqz	a2,28e <memcmp+0x36>
 260:	fff6069b          	addiw	a3,a2,-1
 264:	1682                	slli	a3,a3,0x20
 266:	9281                	srli	a3,a3,0x20
 268:	0685                	addi	a3,a3,1
 26a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 26c:	00054783          	lbu	a5,0(a0)
 270:	0005c703          	lbu	a4,0(a1)
 274:	00e79863          	bne	a5,a4,284 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 278:	0505                	addi	a0,a0,1
    p2++;
 27a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 27c:	fed518e3          	bne	a0,a3,26c <memcmp+0x14>
  }
  return 0;
 280:	4501                	li	a0,0
 282:	a019                	j	288 <memcmp+0x30>
      return *p1 - *p2;
 284:	40e7853b          	subw	a0,a5,a4
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
  return 0;
 28e:	4501                	li	a0,0
 290:	bfe5                	j	288 <memcmp+0x30>

0000000000000292 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 292:	1141                	addi	sp,sp,-16
 294:	e406                	sd	ra,8(sp)
 296:	e022                	sd	s0,0(sp)
 298:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 29a:	00000097          	auipc	ra,0x0
 29e:	f62080e7          	jalr	-158(ra) # 1fc <memmove>
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2aa:	4885                	li	a7,1
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b2:	4889                	li	a7,2
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 2ba:	48e1                	li	a7,24
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2c2:	488d                	li	a7,3
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ca:	4891                	li	a7,4
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <read>:
.global read
read:
 li a7, SYS_read
 2d2:	4895                	li	a7,5
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <write>:
.global write
write:
 li a7, SYS_write
 2da:	48c1                	li	a7,16
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <close>:
.global close
close:
 li a7, SYS_close
 2e2:	48d5                	li	a7,21
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <kill>:
.global kill
kill:
 li a7, SYS_kill
 2ea:	4899                	li	a7,6
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2f2:	489d                	li	a7,7
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <open>:
.global open
open:
 li a7, SYS_open
 2fa:	48bd                	li	a7,15
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 302:	48c5                	li	a7,17
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 30a:	48c9                	li	a7,18
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 312:	48a1                	li	a7,8
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <link>:
.global link
link:
 li a7, SYS_link
 31a:	48cd                	li	a7,19
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 322:	48d1                	li	a7,20
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 32a:	48a5                	li	a7,9
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <dup>:
.global dup
dup:
 li a7, SYS_dup
 332:	48a9                	li	a7,10
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 33a:	48ad                	li	a7,11
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 342:	48b1                	li	a7,12
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 34a:	48b5                	li	a7,13
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 352:	48b9                	li	a7,14
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 35a:	48dd                	li	a7,23
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 362:	48e5                	li	a7,25
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 36a:	48e9                	li	a7,26
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 372:	48ed                	li	a7,27
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 37a:	1101                	addi	sp,sp,-32
 37c:	ec06                	sd	ra,24(sp)
 37e:	e822                	sd	s0,16(sp)
 380:	1000                	addi	s0,sp,32
 382:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 386:	4605                	li	a2,1
 388:	fef40593          	addi	a1,s0,-17
 38c:	00000097          	auipc	ra,0x0
 390:	f4e080e7          	jalr	-178(ra) # 2da <write>
}
 394:	60e2                	ld	ra,24(sp)
 396:	6442                	ld	s0,16(sp)
 398:	6105                	addi	sp,sp,32
 39a:	8082                	ret

000000000000039c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 39c:	7139                	addi	sp,sp,-64
 39e:	fc06                	sd	ra,56(sp)
 3a0:	f822                	sd	s0,48(sp)
 3a2:	f426                	sd	s1,40(sp)
 3a4:	f04a                	sd	s2,32(sp)
 3a6:	ec4e                	sd	s3,24(sp)
 3a8:	0080                	addi	s0,sp,64
 3aa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ac:	c299                	beqz	a3,3b2 <printint+0x16>
 3ae:	0805c863          	bltz	a1,43e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3b2:	2581                	sext.w	a1,a1
  neg = 0;
 3b4:	4881                	li	a7,0
 3b6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ba:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3bc:	2601                	sext.w	a2,a2
 3be:	00000517          	auipc	a0,0x0
 3c2:	46250513          	addi	a0,a0,1122 # 820 <digits>
 3c6:	883a                	mv	a6,a4
 3c8:	2705                	addiw	a4,a4,1
 3ca:	02c5f7bb          	remuw	a5,a1,a2
 3ce:	1782                	slli	a5,a5,0x20
 3d0:	9381                	srli	a5,a5,0x20
 3d2:	97aa                	add	a5,a5,a0
 3d4:	0007c783          	lbu	a5,0(a5)
 3d8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3dc:	0005879b          	sext.w	a5,a1
 3e0:	02c5d5bb          	divuw	a1,a1,a2
 3e4:	0685                	addi	a3,a3,1
 3e6:	fec7f0e3          	bgeu	a5,a2,3c6 <printint+0x2a>
  if(neg)
 3ea:	00088b63          	beqz	a7,400 <printint+0x64>
    buf[i++] = '-';
 3ee:	fd040793          	addi	a5,s0,-48
 3f2:	973e                	add	a4,a4,a5
 3f4:	02d00793          	li	a5,45
 3f8:	fef70823          	sb	a5,-16(a4)
 3fc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 400:	02e05863          	blez	a4,430 <printint+0x94>
 404:	fc040793          	addi	a5,s0,-64
 408:	00e78933          	add	s2,a5,a4
 40c:	fff78993          	addi	s3,a5,-1
 410:	99ba                	add	s3,s3,a4
 412:	377d                	addiw	a4,a4,-1
 414:	1702                	slli	a4,a4,0x20
 416:	9301                	srli	a4,a4,0x20
 418:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 41c:	fff94583          	lbu	a1,-1(s2)
 420:	8526                	mv	a0,s1
 422:	00000097          	auipc	ra,0x0
 426:	f58080e7          	jalr	-168(ra) # 37a <putc>
  while(--i >= 0)
 42a:	197d                	addi	s2,s2,-1
 42c:	ff3918e3          	bne	s2,s3,41c <printint+0x80>
}
 430:	70e2                	ld	ra,56(sp)
 432:	7442                	ld	s0,48(sp)
 434:	74a2                	ld	s1,40(sp)
 436:	7902                	ld	s2,32(sp)
 438:	69e2                	ld	s3,24(sp)
 43a:	6121                	addi	sp,sp,64
 43c:	8082                	ret
    x = -xx;
 43e:	40b005bb          	negw	a1,a1
    neg = 1;
 442:	4885                	li	a7,1
    x = -xx;
 444:	bf8d                	j	3b6 <printint+0x1a>

0000000000000446 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 446:	7119                	addi	sp,sp,-128
 448:	fc86                	sd	ra,120(sp)
 44a:	f8a2                	sd	s0,112(sp)
 44c:	f4a6                	sd	s1,104(sp)
 44e:	f0ca                	sd	s2,96(sp)
 450:	ecce                	sd	s3,88(sp)
 452:	e8d2                	sd	s4,80(sp)
 454:	e4d6                	sd	s5,72(sp)
 456:	e0da                	sd	s6,64(sp)
 458:	fc5e                	sd	s7,56(sp)
 45a:	f862                	sd	s8,48(sp)
 45c:	f466                	sd	s9,40(sp)
 45e:	f06a                	sd	s10,32(sp)
 460:	ec6e                	sd	s11,24(sp)
 462:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 464:	0005c903          	lbu	s2,0(a1)
 468:	18090f63          	beqz	s2,606 <vprintf+0x1c0>
 46c:	8aaa                	mv	s5,a0
 46e:	8b32                	mv	s6,a2
 470:	00158493          	addi	s1,a1,1
  state = 0;
 474:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 476:	02500a13          	li	s4,37
      if(c == 'd'){
 47a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 47e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 482:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 486:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 48a:	00000b97          	auipc	s7,0x0
 48e:	396b8b93          	addi	s7,s7,918 # 820 <digits>
 492:	a839                	j	4b0 <vprintf+0x6a>
        putc(fd, c);
 494:	85ca                	mv	a1,s2
 496:	8556                	mv	a0,s5
 498:	00000097          	auipc	ra,0x0
 49c:	ee2080e7          	jalr	-286(ra) # 37a <putc>
 4a0:	a019                	j	4a6 <vprintf+0x60>
    } else if(state == '%'){
 4a2:	01498f63          	beq	s3,s4,4c0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4a6:	0485                	addi	s1,s1,1
 4a8:	fff4c903          	lbu	s2,-1(s1)
 4ac:	14090d63          	beqz	s2,606 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4b0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4b4:	fe0997e3          	bnez	s3,4a2 <vprintf+0x5c>
      if(c == '%'){
 4b8:	fd479ee3          	bne	a5,s4,494 <vprintf+0x4e>
        state = '%';
 4bc:	89be                	mv	s3,a5
 4be:	b7e5                	j	4a6 <vprintf+0x60>
      if(c == 'd'){
 4c0:	05878063          	beq	a5,s8,500 <vprintf+0xba>
      } else if(c == 'l') {
 4c4:	05978c63          	beq	a5,s9,51c <vprintf+0xd6>
      } else if(c == 'x') {
 4c8:	07a78863          	beq	a5,s10,538 <vprintf+0xf2>
      } else if(c == 'p') {
 4cc:	09b78463          	beq	a5,s11,554 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4d0:	07300713          	li	a4,115
 4d4:	0ce78663          	beq	a5,a4,5a0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4d8:	06300713          	li	a4,99
 4dc:	0ee78e63          	beq	a5,a4,5d8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4e0:	11478863          	beq	a5,s4,5f0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4e4:	85d2                	mv	a1,s4
 4e6:	8556                	mv	a0,s5
 4e8:	00000097          	auipc	ra,0x0
 4ec:	e92080e7          	jalr	-366(ra) # 37a <putc>
        putc(fd, c);
 4f0:	85ca                	mv	a1,s2
 4f2:	8556                	mv	a0,s5
 4f4:	00000097          	auipc	ra,0x0
 4f8:	e86080e7          	jalr	-378(ra) # 37a <putc>
      }
      state = 0;
 4fc:	4981                	li	s3,0
 4fe:	b765                	j	4a6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 500:	008b0913          	addi	s2,s6,8
 504:	4685                	li	a3,1
 506:	4629                	li	a2,10
 508:	000b2583          	lw	a1,0(s6)
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	e8e080e7          	jalr	-370(ra) # 39c <printint>
 516:	8b4a                	mv	s6,s2
      state = 0;
 518:	4981                	li	s3,0
 51a:	b771                	j	4a6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 51c:	008b0913          	addi	s2,s6,8
 520:	4681                	li	a3,0
 522:	4629                	li	a2,10
 524:	000b2583          	lw	a1,0(s6)
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	e72080e7          	jalr	-398(ra) # 39c <printint>
 532:	8b4a                	mv	s6,s2
      state = 0;
 534:	4981                	li	s3,0
 536:	bf85                	j	4a6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 538:	008b0913          	addi	s2,s6,8
 53c:	4681                	li	a3,0
 53e:	4641                	li	a2,16
 540:	000b2583          	lw	a1,0(s6)
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	e56080e7          	jalr	-426(ra) # 39c <printint>
 54e:	8b4a                	mv	s6,s2
      state = 0;
 550:	4981                	li	s3,0
 552:	bf91                	j	4a6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 554:	008b0793          	addi	a5,s6,8
 558:	f8f43423          	sd	a5,-120(s0)
 55c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 560:	03000593          	li	a1,48
 564:	8556                	mv	a0,s5
 566:	00000097          	auipc	ra,0x0
 56a:	e14080e7          	jalr	-492(ra) # 37a <putc>
  putc(fd, 'x');
 56e:	85ea                	mv	a1,s10
 570:	8556                	mv	a0,s5
 572:	00000097          	auipc	ra,0x0
 576:	e08080e7          	jalr	-504(ra) # 37a <putc>
 57a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 57c:	03c9d793          	srli	a5,s3,0x3c
 580:	97de                	add	a5,a5,s7
 582:	0007c583          	lbu	a1,0(a5)
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	df2080e7          	jalr	-526(ra) # 37a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 590:	0992                	slli	s3,s3,0x4
 592:	397d                	addiw	s2,s2,-1
 594:	fe0914e3          	bnez	s2,57c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 598:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 59c:	4981                	li	s3,0
 59e:	b721                	j	4a6 <vprintf+0x60>
        s = va_arg(ap, char*);
 5a0:	008b0993          	addi	s3,s6,8
 5a4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5a8:	02090163          	beqz	s2,5ca <vprintf+0x184>
        while(*s != 0){
 5ac:	00094583          	lbu	a1,0(s2)
 5b0:	c9a1                	beqz	a1,600 <vprintf+0x1ba>
          putc(fd, *s);
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	dc6080e7          	jalr	-570(ra) # 37a <putc>
          s++;
 5bc:	0905                	addi	s2,s2,1
        while(*s != 0){
 5be:	00094583          	lbu	a1,0(s2)
 5c2:	f9e5                	bnez	a1,5b2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5c4:	8b4e                	mv	s6,s3
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bdf9                	j	4a6 <vprintf+0x60>
          s = "(null)";
 5ca:	00000917          	auipc	s2,0x0
 5ce:	24e90913          	addi	s2,s2,590 # 818 <malloc+0x108>
        while(*s != 0){
 5d2:	02800593          	li	a1,40
 5d6:	bff1                	j	5b2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5d8:	008b0913          	addi	s2,s6,8
 5dc:	000b4583          	lbu	a1,0(s6)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	d98080e7          	jalr	-616(ra) # 37a <putc>
 5ea:	8b4a                	mv	s6,s2
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	bd65                	j	4a6 <vprintf+0x60>
        putc(fd, c);
 5f0:	85d2                	mv	a1,s4
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	d86080e7          	jalr	-634(ra) # 37a <putc>
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b565                	j	4a6 <vprintf+0x60>
        s = va_arg(ap, char*);
 600:	8b4e                	mv	s6,s3
      state = 0;
 602:	4981                	li	s3,0
 604:	b54d                	j	4a6 <vprintf+0x60>
    }
  }
}
 606:	70e6                	ld	ra,120(sp)
 608:	7446                	ld	s0,112(sp)
 60a:	74a6                	ld	s1,104(sp)
 60c:	7906                	ld	s2,96(sp)
 60e:	69e6                	ld	s3,88(sp)
 610:	6a46                	ld	s4,80(sp)
 612:	6aa6                	ld	s5,72(sp)
 614:	6b06                	ld	s6,64(sp)
 616:	7be2                	ld	s7,56(sp)
 618:	7c42                	ld	s8,48(sp)
 61a:	7ca2                	ld	s9,40(sp)
 61c:	7d02                	ld	s10,32(sp)
 61e:	6de2                	ld	s11,24(sp)
 620:	6109                	addi	sp,sp,128
 622:	8082                	ret

0000000000000624 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 624:	715d                	addi	sp,sp,-80
 626:	ec06                	sd	ra,24(sp)
 628:	e822                	sd	s0,16(sp)
 62a:	1000                	addi	s0,sp,32
 62c:	e010                	sd	a2,0(s0)
 62e:	e414                	sd	a3,8(s0)
 630:	e818                	sd	a4,16(s0)
 632:	ec1c                	sd	a5,24(s0)
 634:	03043023          	sd	a6,32(s0)
 638:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 63c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 640:	8622                	mv	a2,s0
 642:	00000097          	auipc	ra,0x0
 646:	e04080e7          	jalr	-508(ra) # 446 <vprintf>
}
 64a:	60e2                	ld	ra,24(sp)
 64c:	6442                	ld	s0,16(sp)
 64e:	6161                	addi	sp,sp,80
 650:	8082                	ret

0000000000000652 <printf>:

void
printf(const char *fmt, ...)
{
 652:	711d                	addi	sp,sp,-96
 654:	ec06                	sd	ra,24(sp)
 656:	e822                	sd	s0,16(sp)
 658:	1000                	addi	s0,sp,32
 65a:	e40c                	sd	a1,8(s0)
 65c:	e810                	sd	a2,16(s0)
 65e:	ec14                	sd	a3,24(s0)
 660:	f018                	sd	a4,32(s0)
 662:	f41c                	sd	a5,40(s0)
 664:	03043823          	sd	a6,48(s0)
 668:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 66c:	00840613          	addi	a2,s0,8
 670:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 674:	85aa                	mv	a1,a0
 676:	4505                	li	a0,1
 678:	00000097          	auipc	ra,0x0
 67c:	dce080e7          	jalr	-562(ra) # 446 <vprintf>
}
 680:	60e2                	ld	ra,24(sp)
 682:	6442                	ld	s0,16(sp)
 684:	6125                	addi	sp,sp,96
 686:	8082                	ret

0000000000000688 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 688:	1141                	addi	sp,sp,-16
 68a:	e422                	sd	s0,8(sp)
 68c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 68e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 692:	00001797          	auipc	a5,0x1
 696:	96e7b783          	ld	a5,-1682(a5) # 1000 <freep>
 69a:	a805                	j	6ca <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 69c:	4618                	lw	a4,8(a2)
 69e:	9db9                	addw	a1,a1,a4
 6a0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a4:	6398                	ld	a4,0(a5)
 6a6:	6318                	ld	a4,0(a4)
 6a8:	fee53823          	sd	a4,-16(a0)
 6ac:	a091                	j	6f0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ae:	ff852703          	lw	a4,-8(a0)
 6b2:	9e39                	addw	a2,a2,a4
 6b4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6b6:	ff053703          	ld	a4,-16(a0)
 6ba:	e398                	sd	a4,0(a5)
 6bc:	a099                	j	702 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6be:	6398                	ld	a4,0(a5)
 6c0:	00e7e463          	bltu	a5,a4,6c8 <free+0x40>
 6c4:	00e6ea63          	bltu	a3,a4,6d8 <free+0x50>
{
 6c8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ca:	fed7fae3          	bgeu	a5,a3,6be <free+0x36>
 6ce:	6398                	ld	a4,0(a5)
 6d0:	00e6e463          	bltu	a3,a4,6d8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d4:	fee7eae3          	bltu	a5,a4,6c8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6d8:	ff852583          	lw	a1,-8(a0)
 6dc:	6390                	ld	a2,0(a5)
 6de:	02059713          	slli	a4,a1,0x20
 6e2:	9301                	srli	a4,a4,0x20
 6e4:	0712                	slli	a4,a4,0x4
 6e6:	9736                	add	a4,a4,a3
 6e8:	fae60ae3          	beq	a2,a4,69c <free+0x14>
    bp->s.ptr = p->s.ptr;
 6ec:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6f0:	4790                	lw	a2,8(a5)
 6f2:	02061713          	slli	a4,a2,0x20
 6f6:	9301                	srli	a4,a4,0x20
 6f8:	0712                	slli	a4,a4,0x4
 6fa:	973e                	add	a4,a4,a5
 6fc:	fae689e3          	beq	a3,a4,6ae <free+0x26>
  } else
    p->s.ptr = bp;
 700:	e394                	sd	a3,0(a5)
  freep = p;
 702:	00001717          	auipc	a4,0x1
 706:	8ef73f23          	sd	a5,-1794(a4) # 1000 <freep>
}
 70a:	6422                	ld	s0,8(sp)
 70c:	0141                	addi	sp,sp,16
 70e:	8082                	ret

0000000000000710 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 710:	7139                	addi	sp,sp,-64
 712:	fc06                	sd	ra,56(sp)
 714:	f822                	sd	s0,48(sp)
 716:	f426                	sd	s1,40(sp)
 718:	f04a                	sd	s2,32(sp)
 71a:	ec4e                	sd	s3,24(sp)
 71c:	e852                	sd	s4,16(sp)
 71e:	e456                	sd	s5,8(sp)
 720:	e05a                	sd	s6,0(sp)
 722:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 724:	02051493          	slli	s1,a0,0x20
 728:	9081                	srli	s1,s1,0x20
 72a:	04bd                	addi	s1,s1,15
 72c:	8091                	srli	s1,s1,0x4
 72e:	0014899b          	addiw	s3,s1,1
 732:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 734:	00001517          	auipc	a0,0x1
 738:	8cc53503          	ld	a0,-1844(a0) # 1000 <freep>
 73c:	c515                	beqz	a0,768 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 73e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 740:	4798                	lw	a4,8(a5)
 742:	02977f63          	bgeu	a4,s1,780 <malloc+0x70>
 746:	8a4e                	mv	s4,s3
 748:	0009871b          	sext.w	a4,s3
 74c:	6685                	lui	a3,0x1
 74e:	00d77363          	bgeu	a4,a3,754 <malloc+0x44>
 752:	6a05                	lui	s4,0x1
 754:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 758:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 75c:	00001917          	auipc	s2,0x1
 760:	8a490913          	addi	s2,s2,-1884 # 1000 <freep>
  if(p == (char*)-1)
 764:	5afd                	li	s5,-1
 766:	a88d                	j	7d8 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 768:	00001797          	auipc	a5,0x1
 76c:	8a878793          	addi	a5,a5,-1880 # 1010 <base>
 770:	00001717          	auipc	a4,0x1
 774:	88f73823          	sd	a5,-1904(a4) # 1000 <freep>
 778:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 77a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 77e:	b7e1                	j	746 <malloc+0x36>
      if(p->s.size == nunits)
 780:	02e48b63          	beq	s1,a4,7b6 <malloc+0xa6>
        p->s.size -= nunits;
 784:	4137073b          	subw	a4,a4,s3
 788:	c798                	sw	a4,8(a5)
        p += p->s.size;
 78a:	1702                	slli	a4,a4,0x20
 78c:	9301                	srli	a4,a4,0x20
 78e:	0712                	slli	a4,a4,0x4
 790:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 792:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 796:	00001717          	auipc	a4,0x1
 79a:	86a73523          	sd	a0,-1942(a4) # 1000 <freep>
      return (void*)(p + 1);
 79e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7a2:	70e2                	ld	ra,56(sp)
 7a4:	7442                	ld	s0,48(sp)
 7a6:	74a2                	ld	s1,40(sp)
 7a8:	7902                	ld	s2,32(sp)
 7aa:	69e2                	ld	s3,24(sp)
 7ac:	6a42                	ld	s4,16(sp)
 7ae:	6aa2                	ld	s5,8(sp)
 7b0:	6b02                	ld	s6,0(sp)
 7b2:	6121                	addi	sp,sp,64
 7b4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7b6:	6398                	ld	a4,0(a5)
 7b8:	e118                	sd	a4,0(a0)
 7ba:	bff1                	j	796 <malloc+0x86>
  hp->s.size = nu;
 7bc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7c0:	0541                	addi	a0,a0,16
 7c2:	00000097          	auipc	ra,0x0
 7c6:	ec6080e7          	jalr	-314(ra) # 688 <free>
  return freep;
 7ca:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7ce:	d971                	beqz	a0,7a2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d2:	4798                	lw	a4,8(a5)
 7d4:	fa9776e3          	bgeu	a4,s1,780 <malloc+0x70>
    if(p == freep)
 7d8:	00093703          	ld	a4,0(s2)
 7dc:	853e                	mv	a0,a5
 7de:	fef719e3          	bne	a4,a5,7d0 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7e2:	8552                	mv	a0,s4
 7e4:	00000097          	auipc	ra,0x0
 7e8:	b5e080e7          	jalr	-1186(ra) # 342 <sbrk>
  if(p == (char*)-1)
 7ec:	fd5518e3          	bne	a0,s5,7bc <malloc+0xac>
        return 0;
 7f0:	4501                	li	a0,0
 7f2:	bf45                	j	7a2 <malloc+0x92>
