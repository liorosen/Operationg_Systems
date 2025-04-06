
user/_goodbye:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  exitmsg("Goodbye World xv6");
   8:	00000517          	auipc	a0,0x0
   c:	7e850513          	addi	a0,a0,2024 # 7f0 <malloc+0xea>
  10:	00000097          	auipc	ra,0x0
  14:	2a0080e7          	jalr	672(ra) # 2b0 <exitmsg>

0000000000000018 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
  18:	1141                	addi	sp,sp,-16
  1a:	e406                	sd	ra,8(sp)
  1c:	e022                	sd	s0,0(sp)
  1e:	0800                	addi	s0,sp,16
  extern int main();
  main();
  20:	00000097          	auipc	ra,0x0
  24:	fe0080e7          	jalr	-32(ra) # 0 <main>
  exit(0);
  28:	4501                	li	a0,0
  2a:	00000097          	auipc	ra,0x0
  2e:	27e080e7          	jalr	638(ra) # 2a8 <exit>

0000000000000032 <strcpy>:
}

char* strcpy(char *s, const char *t)
{
  32:	1141                	addi	sp,sp,-16
  34:	e422                	sd	s0,8(sp)
  36:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  38:	87aa                	mv	a5,a0
  3a:	0585                	addi	a1,a1,1
  3c:	0785                	addi	a5,a5,1
  3e:	fff5c703          	lbu	a4,-1(a1)
  42:	fee78fa3          	sb	a4,-1(a5)
  46:	fb75                	bnez	a4,3a <strcpy+0x8>
    ;
  return os;
}
  48:	6422                	ld	s0,8(sp)
  4a:	0141                	addi	sp,sp,16
  4c:	8082                	ret

000000000000004e <strcmp>:

int strcmp(const char *p, const char *q)
{
  4e:	1141                	addi	sp,sp,-16
  50:	e422                	sd	s0,8(sp)
  52:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  54:	00054783          	lbu	a5,0(a0)
  58:	cb91                	beqz	a5,6c <strcmp+0x1e>
  5a:	0005c703          	lbu	a4,0(a1)
  5e:	00f71763          	bne	a4,a5,6c <strcmp+0x1e>
    p++, q++;
  62:	0505                	addi	a0,a0,1
  64:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  66:	00054783          	lbu	a5,0(a0)
  6a:	fbe5                	bnez	a5,5a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  6c:	0005c503          	lbu	a0,0(a1)
}
  70:	40a7853b          	subw	a0,a5,a0
  74:	6422                	ld	s0,8(sp)
  76:	0141                	addi	sp,sp,16
  78:	8082                	ret

000000000000007a <strlen>:

uint strlen(const char *s)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  80:	00054783          	lbu	a5,0(a0)
  84:	cf91                	beqz	a5,a0 <strlen+0x26>
  86:	0505                	addi	a0,a0,1
  88:	87aa                	mv	a5,a0
  8a:	4685                	li	a3,1
  8c:	9e89                	subw	a3,a3,a0
  8e:	00f6853b          	addw	a0,a3,a5
  92:	0785                	addi	a5,a5,1
  94:	fff7c703          	lbu	a4,-1(a5)
  98:	fb7d                	bnez	a4,8e <strlen+0x14>
    ;
  return n;
}
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret
  for(n = 0; s[n]; n++)
  a0:	4501                	li	a0,0
  a2:	bfe5                	j	9a <strlen+0x20>

00000000000000a4 <memset>:

void* memset(void *dst, int c, uint n)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  aa:	ce09                	beqz	a2,c4 <memset+0x20>
  ac:	87aa                	mv	a5,a0
  ae:	fff6071b          	addiw	a4,a2,-1
  b2:	1702                	slli	a4,a4,0x20
  b4:	9301                	srli	a4,a4,0x20
  b6:	0705                	addi	a4,a4,1
  b8:	972a                	add	a4,a4,a0
    cdst[i] = c;
  ba:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  be:	0785                	addi	a5,a5,1
  c0:	fee79de3          	bne	a5,a4,ba <memset+0x16>
  }
  return dst;
}
  c4:	6422                	ld	s0,8(sp)
  c6:	0141                	addi	sp,sp,16
  c8:	8082                	ret

00000000000000ca <strchr>:

char* strchr(const char *s, char c)
{
  ca:	1141                	addi	sp,sp,-16
  cc:	e422                	sd	s0,8(sp)
  ce:	0800                	addi	s0,sp,16
  for(; *s; s++)
  d0:	00054783          	lbu	a5,0(a0)
  d4:	cb99                	beqz	a5,ea <strchr+0x20>
    if(*s == c)
  d6:	00f58763          	beq	a1,a5,e4 <strchr+0x1a>
  for(; *s; s++)
  da:	0505                	addi	a0,a0,1
  dc:	00054783          	lbu	a5,0(a0)
  e0:	fbfd                	bnez	a5,d6 <strchr+0xc>
      return (char*)s;
  return 0;
  e2:	4501                	li	a0,0
}
  e4:	6422                	ld	s0,8(sp)
  e6:	0141                	addi	sp,sp,16
  e8:	8082                	ret
  return 0;
  ea:	4501                	li	a0,0
  ec:	bfe5                	j	e4 <strchr+0x1a>

00000000000000ee <gets>:

char* gets(char *buf, int max)
{
  ee:	711d                	addi	sp,sp,-96
  f0:	ec86                	sd	ra,88(sp)
  f2:	e8a2                	sd	s0,80(sp)
  f4:	e4a6                	sd	s1,72(sp)
  f6:	e0ca                	sd	s2,64(sp)
  f8:	fc4e                	sd	s3,56(sp)
  fa:	f852                	sd	s4,48(sp)
  fc:	f456                	sd	s5,40(sp)
  fe:	f05a                	sd	s6,32(sp)
 100:	ec5e                	sd	s7,24(sp)
 102:	1080                	addi	s0,sp,96
 104:	8baa                	mv	s7,a0
 106:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 108:	892a                	mv	s2,a0
 10a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 10c:	4aa9                	li	s5,10
 10e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 110:	89a6                	mv	s3,s1
 112:	2485                	addiw	s1,s1,1
 114:	0344d863          	bge	s1,s4,144 <gets+0x56>
    cc = read(0, &c, 1);
 118:	4605                	li	a2,1
 11a:	faf40593          	addi	a1,s0,-81
 11e:	4501                	li	a0,0
 120:	00000097          	auipc	ra,0x0
 124:	1a8080e7          	jalr	424(ra) # 2c8 <read>
    if(cc < 1)
 128:	00a05e63          	blez	a0,144 <gets+0x56>
    buf[i++] = c;
 12c:	faf44783          	lbu	a5,-81(s0)
 130:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 134:	01578763          	beq	a5,s5,142 <gets+0x54>
 138:	0905                	addi	s2,s2,1
 13a:	fd679be3          	bne	a5,s6,110 <gets+0x22>
  for(i=0; i+1 < max; ){
 13e:	89a6                	mv	s3,s1
 140:	a011                	j	144 <gets+0x56>
 142:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 144:	99de                	add	s3,s3,s7
 146:	00098023          	sb	zero,0(s3)
  return buf;
}
 14a:	855e                	mv	a0,s7
 14c:	60e6                	ld	ra,88(sp)
 14e:	6446                	ld	s0,80(sp)
 150:	64a6                	ld	s1,72(sp)
 152:	6906                	ld	s2,64(sp)
 154:	79e2                	ld	s3,56(sp)
 156:	7a42                	ld	s4,48(sp)
 158:	7aa2                	ld	s5,40(sp)
 15a:	7b02                	ld	s6,32(sp)
 15c:	6be2                	ld	s7,24(sp)
 15e:	6125                	addi	sp,sp,96
 160:	8082                	ret

0000000000000162 <stat>:

int stat(const char *n, struct stat *st)
{
 162:	1101                	addi	sp,sp,-32
 164:	ec06                	sd	ra,24(sp)
 166:	e822                	sd	s0,16(sp)
 168:	e426                	sd	s1,8(sp)
 16a:	e04a                	sd	s2,0(sp)
 16c:	1000                	addi	s0,sp,32
 16e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 170:	4581                	li	a1,0
 172:	00000097          	auipc	ra,0x0
 176:	17e080e7          	jalr	382(ra) # 2f0 <open>
  if(fd < 0)
 17a:	02054563          	bltz	a0,1a4 <stat+0x42>
 17e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 180:	85ca                	mv	a1,s2
 182:	00000097          	auipc	ra,0x0
 186:	186080e7          	jalr	390(ra) # 308 <fstat>
 18a:	892a                	mv	s2,a0
  close(fd);
 18c:	8526                	mv	a0,s1
 18e:	00000097          	auipc	ra,0x0
 192:	14a080e7          	jalr	330(ra) # 2d8 <close>
  return r;
}
 196:	854a                	mv	a0,s2
 198:	60e2                	ld	ra,24(sp)
 19a:	6442                	ld	s0,16(sp)
 19c:	64a2                	ld	s1,8(sp)
 19e:	6902                	ld	s2,0(sp)
 1a0:	6105                	addi	sp,sp,32
 1a2:	8082                	ret
    return -1;
 1a4:	597d                	li	s2,-1
 1a6:	bfc5                	j	196 <stat+0x34>

00000000000001a8 <atoi>:

int atoi(const char *s)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ae:	00054603          	lbu	a2,0(a0)
 1b2:	fd06079b          	addiw	a5,a2,-48
 1b6:	0ff7f793          	andi	a5,a5,255
 1ba:	4725                	li	a4,9
 1bc:	02f76963          	bltu	a4,a5,1ee <atoi+0x46>
 1c0:	86aa                	mv	a3,a0
  n = 0;
 1c2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1c4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1c6:	0685                	addi	a3,a3,1
 1c8:	0025179b          	slliw	a5,a0,0x2
 1cc:	9fa9                	addw	a5,a5,a0
 1ce:	0017979b          	slliw	a5,a5,0x1
 1d2:	9fb1                	addw	a5,a5,a2
 1d4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d8:	0006c603          	lbu	a2,0(a3)
 1dc:	fd06071b          	addiw	a4,a2,-48
 1e0:	0ff77713          	andi	a4,a4,255
 1e4:	fee5f1e3          	bgeu	a1,a4,1c6 <atoi+0x1e>
  return n;
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	addi	sp,sp,16
 1ec:	8082                	ret
  n = 0;
 1ee:	4501                	li	a0,0
 1f0:	bfe5                	j	1e8 <atoi+0x40>

00000000000001f2 <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f8:	02b57663          	bgeu	a0,a1,224 <memmove+0x32>
    while(n-- > 0)
 1fc:	02c05163          	blez	a2,21e <memmove+0x2c>
 200:	fff6079b          	addiw	a5,a2,-1
 204:	1782                	slli	a5,a5,0x20
 206:	9381                	srli	a5,a5,0x20
 208:	0785                	addi	a5,a5,1
 20a:	97aa                	add	a5,a5,a0
  dst = vdst;
 20c:	872a                	mv	a4,a0
      *dst++ = *src++;
 20e:	0585                	addi	a1,a1,1
 210:	0705                	addi	a4,a4,1
 212:	fff5c683          	lbu	a3,-1(a1)
 216:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 21a:	fee79ae3          	bne	a5,a4,20e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 21e:	6422                	ld	s0,8(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret
    dst += n;
 224:	00c50733          	add	a4,a0,a2
    src += n;
 228:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 22a:	fec05ae3          	blez	a2,21e <memmove+0x2c>
 22e:	fff6079b          	addiw	a5,a2,-1
 232:	1782                	slli	a5,a5,0x20
 234:	9381                	srli	a5,a5,0x20
 236:	fff7c793          	not	a5,a5
 23a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 23c:	15fd                	addi	a1,a1,-1
 23e:	177d                	addi	a4,a4,-1
 240:	0005c683          	lbu	a3,0(a1)
 244:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 248:	fee79ae3          	bne	a5,a4,23c <memmove+0x4a>
 24c:	bfc9                	j	21e <memmove+0x2c>

000000000000024e <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 254:	ca05                	beqz	a2,284 <memcmp+0x36>
 256:	fff6069b          	addiw	a3,a2,-1
 25a:	1682                	slli	a3,a3,0x20
 25c:	9281                	srli	a3,a3,0x20
 25e:	0685                	addi	a3,a3,1
 260:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 262:	00054783          	lbu	a5,0(a0)
 266:	0005c703          	lbu	a4,0(a1)
 26a:	00e79863          	bne	a5,a4,27a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 26e:	0505                	addi	a0,a0,1
    p2++;
 270:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 272:	fed518e3          	bne	a0,a3,262 <memcmp+0x14>
  }
  return 0;
 276:	4501                	li	a0,0
 278:	a019                	j	27e <memcmp+0x30>
      return *p1 - *p2;
 27a:	40e7853b          	subw	a0,a5,a4
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
  return 0;
 284:	4501                	li	a0,0
 286:	bfe5                	j	27e <memcmp+0x30>

0000000000000288 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e406                	sd	ra,8(sp)
 28c:	e022                	sd	s0,0(sp)
 28e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 290:	00000097          	auipc	ra,0x0
 294:	f62080e7          	jalr	-158(ra) # 1f2 <memmove>
}
 298:	60a2                	ld	ra,8(sp)
 29a:	6402                	ld	s0,0(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret

00000000000002a0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2a0:	4885                	li	a7,1
 ecall
 2a2:	00000073          	ecall
 ret
 2a6:	8082                	ret

00000000000002a8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2a8:	4889                	li	a7,2
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 2b0:	48e1                	li	a7,24
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2b8:	488d                	li	a7,3
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c0:	4891                	li	a7,4
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <read>:
.global read
read:
 li a7, SYS_read
 2c8:	4895                	li	a7,5
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <write>:
.global write
write:
 li a7, SYS_write
 2d0:	48c1                	li	a7,16
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <close>:
.global close
close:
 li a7, SYS_close
 2d8:	48d5                	li	a7,21
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e0:	4899                	li	a7,6
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2e8:	489d                	li	a7,7
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <open>:
.global open
open:
 li a7, SYS_open
 2f0:	48bd                	li	a7,15
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2f8:	48c5                	li	a7,17
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 300:	48c9                	li	a7,18
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 308:	48a1                	li	a7,8
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <link>:
.global link
link:
 li a7, SYS_link
 310:	48cd                	li	a7,19
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 318:	48d1                	li	a7,20
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 320:	48a5                	li	a7,9
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <dup>:
.global dup
dup:
 li a7, SYS_dup
 328:	48a9                	li	a7,10
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 330:	48ad                	li	a7,11
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 338:	48b1                	li	a7,12
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 340:	48b5                	li	a7,13
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 348:	48b9                	li	a7,14
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 350:	48dd                	li	a7,23
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 358:	48e5                	li	a7,25
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 360:	48e9                	li	a7,26
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 368:	48ed                	li	a7,27
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 370:	1101                	addi	sp,sp,-32
 372:	ec06                	sd	ra,24(sp)
 374:	e822                	sd	s0,16(sp)
 376:	1000                	addi	s0,sp,32
 378:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 37c:	4605                	li	a2,1
 37e:	fef40593          	addi	a1,s0,-17
 382:	00000097          	auipc	ra,0x0
 386:	f4e080e7          	jalr	-178(ra) # 2d0 <write>
}
 38a:	60e2                	ld	ra,24(sp)
 38c:	6442                	ld	s0,16(sp)
 38e:	6105                	addi	sp,sp,32
 390:	8082                	ret

0000000000000392 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 392:	7139                	addi	sp,sp,-64
 394:	fc06                	sd	ra,56(sp)
 396:	f822                	sd	s0,48(sp)
 398:	f426                	sd	s1,40(sp)
 39a:	f04a                	sd	s2,32(sp)
 39c:	ec4e                	sd	s3,24(sp)
 39e:	0080                	addi	s0,sp,64
 3a0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a2:	c299                	beqz	a3,3a8 <printint+0x16>
 3a4:	0805c863          	bltz	a1,434 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3a8:	2581                	sext.w	a1,a1
  neg = 0;
 3aa:	4881                	li	a7,0
 3ac:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3b0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3b2:	2601                	sext.w	a2,a2
 3b4:	00000517          	auipc	a0,0x0
 3b8:	45c50513          	addi	a0,a0,1116 # 810 <digits>
 3bc:	883a                	mv	a6,a4
 3be:	2705                	addiw	a4,a4,1
 3c0:	02c5f7bb          	remuw	a5,a1,a2
 3c4:	1782                	slli	a5,a5,0x20
 3c6:	9381                	srli	a5,a5,0x20
 3c8:	97aa                	add	a5,a5,a0
 3ca:	0007c783          	lbu	a5,0(a5)
 3ce:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3d2:	0005879b          	sext.w	a5,a1
 3d6:	02c5d5bb          	divuw	a1,a1,a2
 3da:	0685                	addi	a3,a3,1
 3dc:	fec7f0e3          	bgeu	a5,a2,3bc <printint+0x2a>
  if(neg)
 3e0:	00088b63          	beqz	a7,3f6 <printint+0x64>
    buf[i++] = '-';
 3e4:	fd040793          	addi	a5,s0,-48
 3e8:	973e                	add	a4,a4,a5
 3ea:	02d00793          	li	a5,45
 3ee:	fef70823          	sb	a5,-16(a4)
 3f2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3f6:	02e05863          	blez	a4,426 <printint+0x94>
 3fa:	fc040793          	addi	a5,s0,-64
 3fe:	00e78933          	add	s2,a5,a4
 402:	fff78993          	addi	s3,a5,-1
 406:	99ba                	add	s3,s3,a4
 408:	377d                	addiw	a4,a4,-1
 40a:	1702                	slli	a4,a4,0x20
 40c:	9301                	srli	a4,a4,0x20
 40e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 412:	fff94583          	lbu	a1,-1(s2)
 416:	8526                	mv	a0,s1
 418:	00000097          	auipc	ra,0x0
 41c:	f58080e7          	jalr	-168(ra) # 370 <putc>
  while(--i >= 0)
 420:	197d                	addi	s2,s2,-1
 422:	ff3918e3          	bne	s2,s3,412 <printint+0x80>
}
 426:	70e2                	ld	ra,56(sp)
 428:	7442                	ld	s0,48(sp)
 42a:	74a2                	ld	s1,40(sp)
 42c:	7902                	ld	s2,32(sp)
 42e:	69e2                	ld	s3,24(sp)
 430:	6121                	addi	sp,sp,64
 432:	8082                	ret
    x = -xx;
 434:	40b005bb          	negw	a1,a1
    neg = 1;
 438:	4885                	li	a7,1
    x = -xx;
 43a:	bf8d                	j	3ac <printint+0x1a>

000000000000043c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 43c:	7119                	addi	sp,sp,-128
 43e:	fc86                	sd	ra,120(sp)
 440:	f8a2                	sd	s0,112(sp)
 442:	f4a6                	sd	s1,104(sp)
 444:	f0ca                	sd	s2,96(sp)
 446:	ecce                	sd	s3,88(sp)
 448:	e8d2                	sd	s4,80(sp)
 44a:	e4d6                	sd	s5,72(sp)
 44c:	e0da                	sd	s6,64(sp)
 44e:	fc5e                	sd	s7,56(sp)
 450:	f862                	sd	s8,48(sp)
 452:	f466                	sd	s9,40(sp)
 454:	f06a                	sd	s10,32(sp)
 456:	ec6e                	sd	s11,24(sp)
 458:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 45a:	0005c903          	lbu	s2,0(a1)
 45e:	18090f63          	beqz	s2,5fc <vprintf+0x1c0>
 462:	8aaa                	mv	s5,a0
 464:	8b32                	mv	s6,a2
 466:	00158493          	addi	s1,a1,1
  state = 0;
 46a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 46c:	02500a13          	li	s4,37
      if(c == 'd'){
 470:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 474:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 478:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 47c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 480:	00000b97          	auipc	s7,0x0
 484:	390b8b93          	addi	s7,s7,912 # 810 <digits>
 488:	a839                	j	4a6 <vprintf+0x6a>
        putc(fd, c);
 48a:	85ca                	mv	a1,s2
 48c:	8556                	mv	a0,s5
 48e:	00000097          	auipc	ra,0x0
 492:	ee2080e7          	jalr	-286(ra) # 370 <putc>
 496:	a019                	j	49c <vprintf+0x60>
    } else if(state == '%'){
 498:	01498f63          	beq	s3,s4,4b6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 49c:	0485                	addi	s1,s1,1
 49e:	fff4c903          	lbu	s2,-1(s1)
 4a2:	14090d63          	beqz	s2,5fc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4a6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4aa:	fe0997e3          	bnez	s3,498 <vprintf+0x5c>
      if(c == '%'){
 4ae:	fd479ee3          	bne	a5,s4,48a <vprintf+0x4e>
        state = '%';
 4b2:	89be                	mv	s3,a5
 4b4:	b7e5                	j	49c <vprintf+0x60>
      if(c == 'd'){
 4b6:	05878063          	beq	a5,s8,4f6 <vprintf+0xba>
      } else if(c == 'l') {
 4ba:	05978c63          	beq	a5,s9,512 <vprintf+0xd6>
      } else if(c == 'x') {
 4be:	07a78863          	beq	a5,s10,52e <vprintf+0xf2>
      } else if(c == 'p') {
 4c2:	09b78463          	beq	a5,s11,54a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4c6:	07300713          	li	a4,115
 4ca:	0ce78663          	beq	a5,a4,596 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4ce:	06300713          	li	a4,99
 4d2:	0ee78e63          	beq	a5,a4,5ce <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4d6:	11478863          	beq	a5,s4,5e6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4da:	85d2                	mv	a1,s4
 4dc:	8556                	mv	a0,s5
 4de:	00000097          	auipc	ra,0x0
 4e2:	e92080e7          	jalr	-366(ra) # 370 <putc>
        putc(fd, c);
 4e6:	85ca                	mv	a1,s2
 4e8:	8556                	mv	a0,s5
 4ea:	00000097          	auipc	ra,0x0
 4ee:	e86080e7          	jalr	-378(ra) # 370 <putc>
      }
      state = 0;
 4f2:	4981                	li	s3,0
 4f4:	b765                	j	49c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4f6:	008b0913          	addi	s2,s6,8
 4fa:	4685                	li	a3,1
 4fc:	4629                	li	a2,10
 4fe:	000b2583          	lw	a1,0(s6)
 502:	8556                	mv	a0,s5
 504:	00000097          	auipc	ra,0x0
 508:	e8e080e7          	jalr	-370(ra) # 392 <printint>
 50c:	8b4a                	mv	s6,s2
      state = 0;
 50e:	4981                	li	s3,0
 510:	b771                	j	49c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 512:	008b0913          	addi	s2,s6,8
 516:	4681                	li	a3,0
 518:	4629                	li	a2,10
 51a:	000b2583          	lw	a1,0(s6)
 51e:	8556                	mv	a0,s5
 520:	00000097          	auipc	ra,0x0
 524:	e72080e7          	jalr	-398(ra) # 392 <printint>
 528:	8b4a                	mv	s6,s2
      state = 0;
 52a:	4981                	li	s3,0
 52c:	bf85                	j	49c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 52e:	008b0913          	addi	s2,s6,8
 532:	4681                	li	a3,0
 534:	4641                	li	a2,16
 536:	000b2583          	lw	a1,0(s6)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	e56080e7          	jalr	-426(ra) # 392 <printint>
 544:	8b4a                	mv	s6,s2
      state = 0;
 546:	4981                	li	s3,0
 548:	bf91                	j	49c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 54a:	008b0793          	addi	a5,s6,8
 54e:	f8f43423          	sd	a5,-120(s0)
 552:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 556:	03000593          	li	a1,48
 55a:	8556                	mv	a0,s5
 55c:	00000097          	auipc	ra,0x0
 560:	e14080e7          	jalr	-492(ra) # 370 <putc>
  putc(fd, 'x');
 564:	85ea                	mv	a1,s10
 566:	8556                	mv	a0,s5
 568:	00000097          	auipc	ra,0x0
 56c:	e08080e7          	jalr	-504(ra) # 370 <putc>
 570:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 572:	03c9d793          	srli	a5,s3,0x3c
 576:	97de                	add	a5,a5,s7
 578:	0007c583          	lbu	a1,0(a5)
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	df2080e7          	jalr	-526(ra) # 370 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 586:	0992                	slli	s3,s3,0x4
 588:	397d                	addiw	s2,s2,-1
 58a:	fe0914e3          	bnez	s2,572 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 58e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 592:	4981                	li	s3,0
 594:	b721                	j	49c <vprintf+0x60>
        s = va_arg(ap, char*);
 596:	008b0993          	addi	s3,s6,8
 59a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 59e:	02090163          	beqz	s2,5c0 <vprintf+0x184>
        while(*s != 0){
 5a2:	00094583          	lbu	a1,0(s2)
 5a6:	c9a1                	beqz	a1,5f6 <vprintf+0x1ba>
          putc(fd, *s);
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	dc6080e7          	jalr	-570(ra) # 370 <putc>
          s++;
 5b2:	0905                	addi	s2,s2,1
        while(*s != 0){
 5b4:	00094583          	lbu	a1,0(s2)
 5b8:	f9e5                	bnez	a1,5a8 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5ba:	8b4e                	mv	s6,s3
      state = 0;
 5bc:	4981                	li	s3,0
 5be:	bdf9                	j	49c <vprintf+0x60>
          s = "(null)";
 5c0:	00000917          	auipc	s2,0x0
 5c4:	24890913          	addi	s2,s2,584 # 808 <malloc+0x102>
        while(*s != 0){
 5c8:	02800593          	li	a1,40
 5cc:	bff1                	j	5a8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5ce:	008b0913          	addi	s2,s6,8
 5d2:	000b4583          	lbu	a1,0(s6)
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	d98080e7          	jalr	-616(ra) # 370 <putc>
 5e0:	8b4a                	mv	s6,s2
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	bd65                	j	49c <vprintf+0x60>
        putc(fd, c);
 5e6:	85d2                	mv	a1,s4
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	d86080e7          	jalr	-634(ra) # 370 <putc>
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b565                	j	49c <vprintf+0x60>
        s = va_arg(ap, char*);
 5f6:	8b4e                	mv	s6,s3
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	b54d                	j	49c <vprintf+0x60>
    }
  }
}
 5fc:	70e6                	ld	ra,120(sp)
 5fe:	7446                	ld	s0,112(sp)
 600:	74a6                	ld	s1,104(sp)
 602:	7906                	ld	s2,96(sp)
 604:	69e6                	ld	s3,88(sp)
 606:	6a46                	ld	s4,80(sp)
 608:	6aa6                	ld	s5,72(sp)
 60a:	6b06                	ld	s6,64(sp)
 60c:	7be2                	ld	s7,56(sp)
 60e:	7c42                	ld	s8,48(sp)
 610:	7ca2                	ld	s9,40(sp)
 612:	7d02                	ld	s10,32(sp)
 614:	6de2                	ld	s11,24(sp)
 616:	6109                	addi	sp,sp,128
 618:	8082                	ret

000000000000061a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 61a:	715d                	addi	sp,sp,-80
 61c:	ec06                	sd	ra,24(sp)
 61e:	e822                	sd	s0,16(sp)
 620:	1000                	addi	s0,sp,32
 622:	e010                	sd	a2,0(s0)
 624:	e414                	sd	a3,8(s0)
 626:	e818                	sd	a4,16(s0)
 628:	ec1c                	sd	a5,24(s0)
 62a:	03043023          	sd	a6,32(s0)
 62e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 632:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 636:	8622                	mv	a2,s0
 638:	00000097          	auipc	ra,0x0
 63c:	e04080e7          	jalr	-508(ra) # 43c <vprintf>
}
 640:	60e2                	ld	ra,24(sp)
 642:	6442                	ld	s0,16(sp)
 644:	6161                	addi	sp,sp,80
 646:	8082                	ret

0000000000000648 <printf>:

void
printf(const char *fmt, ...)
{
 648:	711d                	addi	sp,sp,-96
 64a:	ec06                	sd	ra,24(sp)
 64c:	e822                	sd	s0,16(sp)
 64e:	1000                	addi	s0,sp,32
 650:	e40c                	sd	a1,8(s0)
 652:	e810                	sd	a2,16(s0)
 654:	ec14                	sd	a3,24(s0)
 656:	f018                	sd	a4,32(s0)
 658:	f41c                	sd	a5,40(s0)
 65a:	03043823          	sd	a6,48(s0)
 65e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 662:	00840613          	addi	a2,s0,8
 666:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 66a:	85aa                	mv	a1,a0
 66c:	4505                	li	a0,1
 66e:	00000097          	auipc	ra,0x0
 672:	dce080e7          	jalr	-562(ra) # 43c <vprintf>
}
 676:	60e2                	ld	ra,24(sp)
 678:	6442                	ld	s0,16(sp)
 67a:	6125                	addi	sp,sp,96
 67c:	8082                	ret

000000000000067e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 67e:	1141                	addi	sp,sp,-16
 680:	e422                	sd	s0,8(sp)
 682:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 684:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 688:	00001797          	auipc	a5,0x1
 68c:	9787b783          	ld	a5,-1672(a5) # 1000 <freep>
 690:	a805                	j	6c0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 692:	4618                	lw	a4,8(a2)
 694:	9db9                	addw	a1,a1,a4
 696:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 69a:	6398                	ld	a4,0(a5)
 69c:	6318                	ld	a4,0(a4)
 69e:	fee53823          	sd	a4,-16(a0)
 6a2:	a091                	j	6e6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6a4:	ff852703          	lw	a4,-8(a0)
 6a8:	9e39                	addw	a2,a2,a4
 6aa:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6ac:	ff053703          	ld	a4,-16(a0)
 6b0:	e398                	sd	a4,0(a5)
 6b2:	a099                	j	6f8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b4:	6398                	ld	a4,0(a5)
 6b6:	00e7e463          	bltu	a5,a4,6be <free+0x40>
 6ba:	00e6ea63          	bltu	a3,a4,6ce <free+0x50>
{
 6be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c0:	fed7fae3          	bgeu	a5,a3,6b4 <free+0x36>
 6c4:	6398                	ld	a4,0(a5)
 6c6:	00e6e463          	bltu	a3,a4,6ce <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ca:	fee7eae3          	bltu	a5,a4,6be <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6ce:	ff852583          	lw	a1,-8(a0)
 6d2:	6390                	ld	a2,0(a5)
 6d4:	02059713          	slli	a4,a1,0x20
 6d8:	9301                	srli	a4,a4,0x20
 6da:	0712                	slli	a4,a4,0x4
 6dc:	9736                	add	a4,a4,a3
 6de:	fae60ae3          	beq	a2,a4,692 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6e6:	4790                	lw	a2,8(a5)
 6e8:	02061713          	slli	a4,a2,0x20
 6ec:	9301                	srli	a4,a4,0x20
 6ee:	0712                	slli	a4,a4,0x4
 6f0:	973e                	add	a4,a4,a5
 6f2:	fae689e3          	beq	a3,a4,6a4 <free+0x26>
  } else
    p->s.ptr = bp;
 6f6:	e394                	sd	a3,0(a5)
  freep = p;
 6f8:	00001717          	auipc	a4,0x1
 6fc:	90f73423          	sd	a5,-1784(a4) # 1000 <freep>
}
 700:	6422                	ld	s0,8(sp)
 702:	0141                	addi	sp,sp,16
 704:	8082                	ret

0000000000000706 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 706:	7139                	addi	sp,sp,-64
 708:	fc06                	sd	ra,56(sp)
 70a:	f822                	sd	s0,48(sp)
 70c:	f426                	sd	s1,40(sp)
 70e:	f04a                	sd	s2,32(sp)
 710:	ec4e                	sd	s3,24(sp)
 712:	e852                	sd	s4,16(sp)
 714:	e456                	sd	s5,8(sp)
 716:	e05a                	sd	s6,0(sp)
 718:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 71a:	02051493          	slli	s1,a0,0x20
 71e:	9081                	srli	s1,s1,0x20
 720:	04bd                	addi	s1,s1,15
 722:	8091                	srli	s1,s1,0x4
 724:	0014899b          	addiw	s3,s1,1
 728:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 72a:	00001517          	auipc	a0,0x1
 72e:	8d653503          	ld	a0,-1834(a0) # 1000 <freep>
 732:	c515                	beqz	a0,75e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 734:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 736:	4798                	lw	a4,8(a5)
 738:	02977f63          	bgeu	a4,s1,776 <malloc+0x70>
 73c:	8a4e                	mv	s4,s3
 73e:	0009871b          	sext.w	a4,s3
 742:	6685                	lui	a3,0x1
 744:	00d77363          	bgeu	a4,a3,74a <malloc+0x44>
 748:	6a05                	lui	s4,0x1
 74a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 74e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 752:	00001917          	auipc	s2,0x1
 756:	8ae90913          	addi	s2,s2,-1874 # 1000 <freep>
  if(p == (char*)-1)
 75a:	5afd                	li	s5,-1
 75c:	a88d                	j	7ce <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 75e:	00001797          	auipc	a5,0x1
 762:	8b278793          	addi	a5,a5,-1870 # 1010 <base>
 766:	00001717          	auipc	a4,0x1
 76a:	88f73d23          	sd	a5,-1894(a4) # 1000 <freep>
 76e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 770:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 774:	b7e1                	j	73c <malloc+0x36>
      if(p->s.size == nunits)
 776:	02e48b63          	beq	s1,a4,7ac <malloc+0xa6>
        p->s.size -= nunits;
 77a:	4137073b          	subw	a4,a4,s3
 77e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 780:	1702                	slli	a4,a4,0x20
 782:	9301                	srli	a4,a4,0x20
 784:	0712                	slli	a4,a4,0x4
 786:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 788:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 78c:	00001717          	auipc	a4,0x1
 790:	86a73a23          	sd	a0,-1932(a4) # 1000 <freep>
      return (void*)(p + 1);
 794:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 798:	70e2                	ld	ra,56(sp)
 79a:	7442                	ld	s0,48(sp)
 79c:	74a2                	ld	s1,40(sp)
 79e:	7902                	ld	s2,32(sp)
 7a0:	69e2                	ld	s3,24(sp)
 7a2:	6a42                	ld	s4,16(sp)
 7a4:	6aa2                	ld	s5,8(sp)
 7a6:	6b02                	ld	s6,0(sp)
 7a8:	6121                	addi	sp,sp,64
 7aa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7ac:	6398                	ld	a4,0(a5)
 7ae:	e118                	sd	a4,0(a0)
 7b0:	bff1                	j	78c <malloc+0x86>
  hp->s.size = nu;
 7b2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b6:	0541                	addi	a0,a0,16
 7b8:	00000097          	auipc	ra,0x0
 7bc:	ec6080e7          	jalr	-314(ra) # 67e <free>
  return freep;
 7c0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7c4:	d971                	beqz	a0,798 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c8:	4798                	lw	a4,8(a5)
 7ca:	fa9776e3          	bgeu	a4,s1,776 <malloc+0x70>
    if(p == freep)
 7ce:	00093703          	ld	a4,0(s2)
 7d2:	853e                	mv	a0,a5
 7d4:	fef719e3          	bne	a4,a5,7c6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7d8:	8552                	mv	a0,s4
 7da:	00000097          	auipc	ra,0x0
 7de:	b5e080e7          	jalr	-1186(ra) # 338 <sbrk>
  if(p == (char*)-1)
 7e2:	fd5518e3          	bne	a0,s5,7b2 <malloc+0xac>
        return 0;
 7e6:	4501                	li	a0,0
 7e8:	bf45                	j	798 <malloc+0x92>
