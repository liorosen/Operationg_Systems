
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dd010113          	addi	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	addi	s0,sp,560
  int fd, i;
  char path[] = "stressfs0";
  16:	00001797          	auipc	a5,0x1
  1a:	91278793          	addi	a5,a5,-1774 # 928 <malloc+0x126>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	8c450513          	addi	a0,a0,-1852 # 8f0 <malloc+0xee>
  34:	00000097          	auipc	ra,0x0
  38:	710080e7          	jalr	1808(ra) # 744 <printf>
  memset(data, 'a', sizeof(data));
  3c:	20000613          	li	a2,512
  40:	06100593          	li	a1,97
  44:	dd040513          	addi	a0,s0,-560
  48:	00000097          	auipc	ra,0x0
  4c:	158080e7          	jalr	344(ra) # 1a0 <memset>

  for(i = 0; i < 4; i++)
  50:	4481                	li	s1,0
  52:	4911                	li	s2,4
    if(fork() > 0)
  54:	00000097          	auipc	ra,0x0
  58:	348080e7          	jalr	840(ra) # 39c <fork>
  5c:	00a04563          	bgtz	a0,66 <main+0x66>
  for(i = 0; i < 4; i++)
  60:	2485                	addiw	s1,s1,1
  62:	ff2499e3          	bne	s1,s2,54 <main+0x54>
      break;

  printf("write %d\n", i);
  66:	85a6                	mv	a1,s1
  68:	00001517          	auipc	a0,0x1
  6c:	8a050513          	addi	a0,a0,-1888 # 908 <malloc+0x106>
  70:	00000097          	auipc	ra,0x0
  74:	6d4080e7          	jalr	1748(ra) # 744 <printf>

  path[8] += i;
  78:	fd844783          	lbu	a5,-40(s0)
  7c:	9cbd                	addw	s1,s1,a5
  7e:	fc940c23          	sb	s1,-40(s0)
  fd = open(path, O_CREATE | O_RDWR);
  82:	20200593          	li	a1,514
  86:	fd040513          	addi	a0,s0,-48
  8a:	00000097          	auipc	ra,0x0
  8e:	362080e7          	jalr	866(ra) # 3ec <open>
  92:	892a                	mv	s2,a0
  94:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  96:	20000613          	li	a2,512
  9a:	dd040593          	addi	a1,s0,-560
  9e:	854a                	mv	a0,s2
  a0:	00000097          	auipc	ra,0x0
  a4:	32c080e7          	jalr	812(ra) # 3cc <write>
  for(i = 0; i < 20; i++)
  a8:	34fd                	addiw	s1,s1,-1
  aa:	f4f5                	bnez	s1,96 <main+0x96>
  close(fd);
  ac:	854a                	mv	a0,s2
  ae:	00000097          	auipc	ra,0x0
  b2:	326080e7          	jalr	806(ra) # 3d4 <close>

  printf("read\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	86250513          	addi	a0,a0,-1950 # 918 <malloc+0x116>
  be:	00000097          	auipc	ra,0x0
  c2:	686080e7          	jalr	1670(ra) # 744 <printf>

  fd = open(path, O_RDONLY);
  c6:	4581                	li	a1,0
  c8:	fd040513          	addi	a0,s0,-48
  cc:	00000097          	auipc	ra,0x0
  d0:	320080e7          	jalr	800(ra) # 3ec <open>
  d4:	892a                	mv	s2,a0
  d6:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  d8:	20000613          	li	a2,512
  dc:	dd040593          	addi	a1,s0,-560
  e0:	854a                	mv	a0,s2
  e2:	00000097          	auipc	ra,0x0
  e6:	2e2080e7          	jalr	738(ra) # 3c4 <read>
  for (i = 0; i < 20; i++)
  ea:	34fd                	addiw	s1,s1,-1
  ec:	f4f5                	bnez	s1,d8 <main+0xd8>
  close(fd);
  ee:	854a                	mv	a0,s2
  f0:	00000097          	auipc	ra,0x0
  f4:	2e4080e7          	jalr	740(ra) # 3d4 <close>

  wait(0,"");
  f8:	00001597          	auipc	a1,0x1
  fc:	82858593          	addi	a1,a1,-2008 # 920 <malloc+0x11e>
 100:	4501                	li	a0,0
 102:	00000097          	auipc	ra,0x0
 106:	2b2080e7          	jalr	690(ra) # 3b4 <wait>

  exit(0);
 10a:	4501                	li	a0,0
 10c:	00000097          	auipc	ra,0x0
 110:	298080e7          	jalr	664(ra) # 3a4 <exit>

0000000000000114 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
 114:	1141                	addi	sp,sp,-16
 116:	e406                	sd	ra,8(sp)
 118:	e022                	sd	s0,0(sp)
 11a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 11c:	00000097          	auipc	ra,0x0
 120:	ee4080e7          	jalr	-284(ra) # 0 <main>
  exit(0);
 124:	4501                	li	a0,0
 126:	00000097          	auipc	ra,0x0
 12a:	27e080e7          	jalr	638(ra) # 3a4 <exit>

000000000000012e <strcpy>:
}

char* strcpy(char *s, const char *t)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 134:	87aa                	mv	a5,a0
 136:	0585                	addi	a1,a1,1
 138:	0785                	addi	a5,a5,1
 13a:	fff5c703          	lbu	a4,-1(a1)
 13e:	fee78fa3          	sb	a4,-1(a5)
 142:	fb75                	bnez	a4,136 <strcpy+0x8>
    ;
  return os;
}
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <strcmp>:

int strcmp(const char *p, const char *q)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 150:	00054783          	lbu	a5,0(a0)
 154:	cb91                	beqz	a5,168 <strcmp+0x1e>
 156:	0005c703          	lbu	a4,0(a1)
 15a:	00f71763          	bne	a4,a5,168 <strcmp+0x1e>
    p++, q++;
 15e:	0505                	addi	a0,a0,1
 160:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 162:	00054783          	lbu	a5,0(a0)
 166:	fbe5                	bnez	a5,156 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 168:	0005c503          	lbu	a0,0(a1)
}
 16c:	40a7853b          	subw	a0,a5,a0
 170:	6422                	ld	s0,8(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret

0000000000000176 <strlen>:

uint strlen(const char *s)
{
 176:	1141                	addi	sp,sp,-16
 178:	e422                	sd	s0,8(sp)
 17a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 17c:	00054783          	lbu	a5,0(a0)
 180:	cf91                	beqz	a5,19c <strlen+0x26>
 182:	0505                	addi	a0,a0,1
 184:	87aa                	mv	a5,a0
 186:	4685                	li	a3,1
 188:	9e89                	subw	a3,a3,a0
 18a:	00f6853b          	addw	a0,a3,a5
 18e:	0785                	addi	a5,a5,1
 190:	fff7c703          	lbu	a4,-1(a5)
 194:	fb7d                	bnez	a4,18a <strlen+0x14>
    ;
  return n;
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret
  for(n = 0; s[n]; n++)
 19c:	4501                	li	a0,0
 19e:	bfe5                	j	196 <strlen+0x20>

00000000000001a0 <memset>:

void* memset(void *dst, int c, uint n)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1a6:	ce09                	beqz	a2,1c0 <memset+0x20>
 1a8:	87aa                	mv	a5,a0
 1aa:	fff6071b          	addiw	a4,a2,-1
 1ae:	1702                	slli	a4,a4,0x20
 1b0:	9301                	srli	a4,a4,0x20
 1b2:	0705                	addi	a4,a4,1
 1b4:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1b6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ba:	0785                	addi	a5,a5,1
 1bc:	fee79de3          	bne	a5,a4,1b6 <memset+0x16>
  }
  return dst;
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret

00000000000001c6 <strchr>:

char* strchr(const char *s, char c)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	cb99                	beqz	a5,1e6 <strchr+0x20>
    if(*s == c)
 1d2:	00f58763          	beq	a1,a5,1e0 <strchr+0x1a>
  for(; *s; s++)
 1d6:	0505                	addi	a0,a0,1
 1d8:	00054783          	lbu	a5,0(a0)
 1dc:	fbfd                	bnez	a5,1d2 <strchr+0xc>
      return (char*)s;
  return 0;
 1de:	4501                	li	a0,0
}
 1e0:	6422                	ld	s0,8(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret
  return 0;
 1e6:	4501                	li	a0,0
 1e8:	bfe5                	j	1e0 <strchr+0x1a>

00000000000001ea <gets>:

char* gets(char *buf, int max)
{
 1ea:	711d                	addi	sp,sp,-96
 1ec:	ec86                	sd	ra,88(sp)
 1ee:	e8a2                	sd	s0,80(sp)
 1f0:	e4a6                	sd	s1,72(sp)
 1f2:	e0ca                	sd	s2,64(sp)
 1f4:	fc4e                	sd	s3,56(sp)
 1f6:	f852                	sd	s4,48(sp)
 1f8:	f456                	sd	s5,40(sp)
 1fa:	f05a                	sd	s6,32(sp)
 1fc:	ec5e                	sd	s7,24(sp)
 1fe:	1080                	addi	s0,sp,96
 200:	8baa                	mv	s7,a0
 202:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 204:	892a                	mv	s2,a0
 206:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 208:	4aa9                	li	s5,10
 20a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 20c:	89a6                	mv	s3,s1
 20e:	2485                	addiw	s1,s1,1
 210:	0344d863          	bge	s1,s4,240 <gets+0x56>
    cc = read(0, &c, 1);
 214:	4605                	li	a2,1
 216:	faf40593          	addi	a1,s0,-81
 21a:	4501                	li	a0,0
 21c:	00000097          	auipc	ra,0x0
 220:	1a8080e7          	jalr	424(ra) # 3c4 <read>
    if(cc < 1)
 224:	00a05e63          	blez	a0,240 <gets+0x56>
    buf[i++] = c;
 228:	faf44783          	lbu	a5,-81(s0)
 22c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 230:	01578763          	beq	a5,s5,23e <gets+0x54>
 234:	0905                	addi	s2,s2,1
 236:	fd679be3          	bne	a5,s6,20c <gets+0x22>
  for(i=0; i+1 < max; ){
 23a:	89a6                	mv	s3,s1
 23c:	a011                	j	240 <gets+0x56>
 23e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 240:	99de                	add	s3,s3,s7
 242:	00098023          	sb	zero,0(s3)
  return buf;
}
 246:	855e                	mv	a0,s7
 248:	60e6                	ld	ra,88(sp)
 24a:	6446                	ld	s0,80(sp)
 24c:	64a6                	ld	s1,72(sp)
 24e:	6906                	ld	s2,64(sp)
 250:	79e2                	ld	s3,56(sp)
 252:	7a42                	ld	s4,48(sp)
 254:	7aa2                	ld	s5,40(sp)
 256:	7b02                	ld	s6,32(sp)
 258:	6be2                	ld	s7,24(sp)
 25a:	6125                	addi	sp,sp,96
 25c:	8082                	ret

000000000000025e <stat>:

int stat(const char *n, struct stat *st)
{
 25e:	1101                	addi	sp,sp,-32
 260:	ec06                	sd	ra,24(sp)
 262:	e822                	sd	s0,16(sp)
 264:	e426                	sd	s1,8(sp)
 266:	e04a                	sd	s2,0(sp)
 268:	1000                	addi	s0,sp,32
 26a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 26c:	4581                	li	a1,0
 26e:	00000097          	auipc	ra,0x0
 272:	17e080e7          	jalr	382(ra) # 3ec <open>
  if(fd < 0)
 276:	02054563          	bltz	a0,2a0 <stat+0x42>
 27a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 27c:	85ca                	mv	a1,s2
 27e:	00000097          	auipc	ra,0x0
 282:	186080e7          	jalr	390(ra) # 404 <fstat>
 286:	892a                	mv	s2,a0
  close(fd);
 288:	8526                	mv	a0,s1
 28a:	00000097          	auipc	ra,0x0
 28e:	14a080e7          	jalr	330(ra) # 3d4 <close>
  return r;
}
 292:	854a                	mv	a0,s2
 294:	60e2                	ld	ra,24(sp)
 296:	6442                	ld	s0,16(sp)
 298:	64a2                	ld	s1,8(sp)
 29a:	6902                	ld	s2,0(sp)
 29c:	6105                	addi	sp,sp,32
 29e:	8082                	ret
    return -1;
 2a0:	597d                	li	s2,-1
 2a2:	bfc5                	j	292 <stat+0x34>

00000000000002a4 <atoi>:

int atoi(const char *s)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e422                	sd	s0,8(sp)
 2a8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2aa:	00054603          	lbu	a2,0(a0)
 2ae:	fd06079b          	addiw	a5,a2,-48
 2b2:	0ff7f793          	andi	a5,a5,255
 2b6:	4725                	li	a4,9
 2b8:	02f76963          	bltu	a4,a5,2ea <atoi+0x46>
 2bc:	86aa                	mv	a3,a0
  n = 0;
 2be:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2c0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2c2:	0685                	addi	a3,a3,1
 2c4:	0025179b          	slliw	a5,a0,0x2
 2c8:	9fa9                	addw	a5,a5,a0
 2ca:	0017979b          	slliw	a5,a5,0x1
 2ce:	9fb1                	addw	a5,a5,a2
 2d0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2d4:	0006c603          	lbu	a2,0(a3)
 2d8:	fd06071b          	addiw	a4,a2,-48
 2dc:	0ff77713          	andi	a4,a4,255
 2e0:	fee5f1e3          	bgeu	a1,a4,2c2 <atoi+0x1e>
  return n;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  n = 0;
 2ea:	4501                	li	a0,0
 2ec:	bfe5                	j	2e4 <atoi+0x40>

00000000000002ee <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2f4:	02b57663          	bgeu	a0,a1,320 <memmove+0x32>
    while(n-- > 0)
 2f8:	02c05163          	blez	a2,31a <memmove+0x2c>
 2fc:	fff6079b          	addiw	a5,a2,-1
 300:	1782                	slli	a5,a5,0x20
 302:	9381                	srli	a5,a5,0x20
 304:	0785                	addi	a5,a5,1
 306:	97aa                	add	a5,a5,a0
  dst = vdst;
 308:	872a                	mv	a4,a0
      *dst++ = *src++;
 30a:	0585                	addi	a1,a1,1
 30c:	0705                	addi	a4,a4,1
 30e:	fff5c683          	lbu	a3,-1(a1)
 312:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 316:	fee79ae3          	bne	a5,a4,30a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31a:	6422                	ld	s0,8(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
    dst += n;
 320:	00c50733          	add	a4,a0,a2
    src += n;
 324:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 326:	fec05ae3          	blez	a2,31a <memmove+0x2c>
 32a:	fff6079b          	addiw	a5,a2,-1
 32e:	1782                	slli	a5,a5,0x20
 330:	9381                	srli	a5,a5,0x20
 332:	fff7c793          	not	a5,a5
 336:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 338:	15fd                	addi	a1,a1,-1
 33a:	177d                	addi	a4,a4,-1
 33c:	0005c683          	lbu	a3,0(a1)
 340:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 344:	fee79ae3          	bne	a5,a4,338 <memmove+0x4a>
 348:	bfc9                	j	31a <memmove+0x2c>

000000000000034a <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e422                	sd	s0,8(sp)
 34e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 350:	ca05                	beqz	a2,380 <memcmp+0x36>
 352:	fff6069b          	addiw	a3,a2,-1
 356:	1682                	slli	a3,a3,0x20
 358:	9281                	srli	a3,a3,0x20
 35a:	0685                	addi	a3,a3,1
 35c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 35e:	00054783          	lbu	a5,0(a0)
 362:	0005c703          	lbu	a4,0(a1)
 366:	00e79863          	bne	a5,a4,376 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36a:	0505                	addi	a0,a0,1
    p2++;
 36c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 36e:	fed518e3          	bne	a0,a3,35e <memcmp+0x14>
  }
  return 0;
 372:	4501                	li	a0,0
 374:	a019                	j	37a <memcmp+0x30>
      return *p1 - *p2;
 376:	40e7853b          	subw	a0,a5,a4
}
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret
  return 0;
 380:	4501                	li	a0,0
 382:	bfe5                	j	37a <memcmp+0x30>

0000000000000384 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
 384:	1141                	addi	sp,sp,-16
 386:	e406                	sd	ra,8(sp)
 388:	e022                	sd	s0,0(sp)
 38a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 38c:	00000097          	auipc	ra,0x0
 390:	f62080e7          	jalr	-158(ra) # 2ee <memmove>
}
 394:	60a2                	ld	ra,8(sp)
 396:	6402                	ld	s0,0(sp)
 398:	0141                	addi	sp,sp,16
 39a:	8082                	ret

000000000000039c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 39c:	4885                	li	a7,1
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a4:	4889                	li	a7,2
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
 3ac:	48e1                	li	a7,24
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3b4:	488d                	li	a7,3
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3bc:	4891                	li	a7,4
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <read>:
.global read
read:
 li a7, SYS_read
 3c4:	4895                	li	a7,5
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <write>:
.global write
write:
 li a7, SYS_write
 3cc:	48c1                	li	a7,16
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <close>:
.global close
close:
 li a7, SYS_close
 3d4:	48d5                	li	a7,21
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3dc:	4899                	li	a7,6
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3e4:	489d                	li	a7,7
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <open>:
.global open
open:
 li a7, SYS_open
 3ec:	48bd                	li	a7,15
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3f4:	48c5                	li	a7,17
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3fc:	48c9                	li	a7,18
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 404:	48a1                	li	a7,8
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <link>:
.global link
link:
 li a7, SYS_link
 40c:	48cd                	li	a7,19
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 414:	48d1                	li	a7,20
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 41c:	48a5                	li	a7,9
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <dup>:
.global dup
dup:
 li a7, SYS_dup
 424:	48a9                	li	a7,10
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 42c:	48ad                	li	a7,11
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 434:	48b1                	li	a7,12
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 43c:	48b5                	li	a7,13
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 444:	48b9                	li	a7,14
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 44c:	48dd                	li	a7,23
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
 454:	48e5                	li	a7,25
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
 45c:	48e9                	li	a7,26
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
 464:	48ed                	li	a7,27
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 46c:	1101                	addi	sp,sp,-32
 46e:	ec06                	sd	ra,24(sp)
 470:	e822                	sd	s0,16(sp)
 472:	1000                	addi	s0,sp,32
 474:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 478:	4605                	li	a2,1
 47a:	fef40593          	addi	a1,s0,-17
 47e:	00000097          	auipc	ra,0x0
 482:	f4e080e7          	jalr	-178(ra) # 3cc <write>
}
 486:	60e2                	ld	ra,24(sp)
 488:	6442                	ld	s0,16(sp)
 48a:	6105                	addi	sp,sp,32
 48c:	8082                	ret

000000000000048e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 48e:	7139                	addi	sp,sp,-64
 490:	fc06                	sd	ra,56(sp)
 492:	f822                	sd	s0,48(sp)
 494:	f426                	sd	s1,40(sp)
 496:	f04a                	sd	s2,32(sp)
 498:	ec4e                	sd	s3,24(sp)
 49a:	0080                	addi	s0,sp,64
 49c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 49e:	c299                	beqz	a3,4a4 <printint+0x16>
 4a0:	0805c863          	bltz	a1,530 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4a4:	2581                	sext.w	a1,a1
  neg = 0;
 4a6:	4881                	li	a7,0
 4a8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ac:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ae:	2601                	sext.w	a2,a2
 4b0:	00000517          	auipc	a0,0x0
 4b4:	49050513          	addi	a0,a0,1168 # 940 <digits>
 4b8:	883a                	mv	a6,a4
 4ba:	2705                	addiw	a4,a4,1
 4bc:	02c5f7bb          	remuw	a5,a1,a2
 4c0:	1782                	slli	a5,a5,0x20
 4c2:	9381                	srli	a5,a5,0x20
 4c4:	97aa                	add	a5,a5,a0
 4c6:	0007c783          	lbu	a5,0(a5)
 4ca:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ce:	0005879b          	sext.w	a5,a1
 4d2:	02c5d5bb          	divuw	a1,a1,a2
 4d6:	0685                	addi	a3,a3,1
 4d8:	fec7f0e3          	bgeu	a5,a2,4b8 <printint+0x2a>
  if(neg)
 4dc:	00088b63          	beqz	a7,4f2 <printint+0x64>
    buf[i++] = '-';
 4e0:	fd040793          	addi	a5,s0,-48
 4e4:	973e                	add	a4,a4,a5
 4e6:	02d00793          	li	a5,45
 4ea:	fef70823          	sb	a5,-16(a4)
 4ee:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4f2:	02e05863          	blez	a4,522 <printint+0x94>
 4f6:	fc040793          	addi	a5,s0,-64
 4fa:	00e78933          	add	s2,a5,a4
 4fe:	fff78993          	addi	s3,a5,-1
 502:	99ba                	add	s3,s3,a4
 504:	377d                	addiw	a4,a4,-1
 506:	1702                	slli	a4,a4,0x20
 508:	9301                	srli	a4,a4,0x20
 50a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 50e:	fff94583          	lbu	a1,-1(s2)
 512:	8526                	mv	a0,s1
 514:	00000097          	auipc	ra,0x0
 518:	f58080e7          	jalr	-168(ra) # 46c <putc>
  while(--i >= 0)
 51c:	197d                	addi	s2,s2,-1
 51e:	ff3918e3          	bne	s2,s3,50e <printint+0x80>
}
 522:	70e2                	ld	ra,56(sp)
 524:	7442                	ld	s0,48(sp)
 526:	74a2                	ld	s1,40(sp)
 528:	7902                	ld	s2,32(sp)
 52a:	69e2                	ld	s3,24(sp)
 52c:	6121                	addi	sp,sp,64
 52e:	8082                	ret
    x = -xx;
 530:	40b005bb          	negw	a1,a1
    neg = 1;
 534:	4885                	li	a7,1
    x = -xx;
 536:	bf8d                	j	4a8 <printint+0x1a>

0000000000000538 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 538:	7119                	addi	sp,sp,-128
 53a:	fc86                	sd	ra,120(sp)
 53c:	f8a2                	sd	s0,112(sp)
 53e:	f4a6                	sd	s1,104(sp)
 540:	f0ca                	sd	s2,96(sp)
 542:	ecce                	sd	s3,88(sp)
 544:	e8d2                	sd	s4,80(sp)
 546:	e4d6                	sd	s5,72(sp)
 548:	e0da                	sd	s6,64(sp)
 54a:	fc5e                	sd	s7,56(sp)
 54c:	f862                	sd	s8,48(sp)
 54e:	f466                	sd	s9,40(sp)
 550:	f06a                	sd	s10,32(sp)
 552:	ec6e                	sd	s11,24(sp)
 554:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 556:	0005c903          	lbu	s2,0(a1)
 55a:	18090f63          	beqz	s2,6f8 <vprintf+0x1c0>
 55e:	8aaa                	mv	s5,a0
 560:	8b32                	mv	s6,a2
 562:	00158493          	addi	s1,a1,1
  state = 0;
 566:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 568:	02500a13          	li	s4,37
      if(c == 'd'){
 56c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 570:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 574:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 578:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 57c:	00000b97          	auipc	s7,0x0
 580:	3c4b8b93          	addi	s7,s7,964 # 940 <digits>
 584:	a839                	j	5a2 <vprintf+0x6a>
        putc(fd, c);
 586:	85ca                	mv	a1,s2
 588:	8556                	mv	a0,s5
 58a:	00000097          	auipc	ra,0x0
 58e:	ee2080e7          	jalr	-286(ra) # 46c <putc>
 592:	a019                	j	598 <vprintf+0x60>
    } else if(state == '%'){
 594:	01498f63          	beq	s3,s4,5b2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 598:	0485                	addi	s1,s1,1
 59a:	fff4c903          	lbu	s2,-1(s1)
 59e:	14090d63          	beqz	s2,6f8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5a2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5a6:	fe0997e3          	bnez	s3,594 <vprintf+0x5c>
      if(c == '%'){
 5aa:	fd479ee3          	bne	a5,s4,586 <vprintf+0x4e>
        state = '%';
 5ae:	89be                	mv	s3,a5
 5b0:	b7e5                	j	598 <vprintf+0x60>
      if(c == 'd'){
 5b2:	05878063          	beq	a5,s8,5f2 <vprintf+0xba>
      } else if(c == 'l') {
 5b6:	05978c63          	beq	a5,s9,60e <vprintf+0xd6>
      } else if(c == 'x') {
 5ba:	07a78863          	beq	a5,s10,62a <vprintf+0xf2>
      } else if(c == 'p') {
 5be:	09b78463          	beq	a5,s11,646 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5c2:	07300713          	li	a4,115
 5c6:	0ce78663          	beq	a5,a4,692 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5ca:	06300713          	li	a4,99
 5ce:	0ee78e63          	beq	a5,a4,6ca <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5d2:	11478863          	beq	a5,s4,6e2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5d6:	85d2                	mv	a1,s4
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	e92080e7          	jalr	-366(ra) # 46c <putc>
        putc(fd, c);
 5e2:	85ca                	mv	a1,s2
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	e86080e7          	jalr	-378(ra) # 46c <putc>
      }
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	b765                	j	598 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5f2:	008b0913          	addi	s2,s6,8
 5f6:	4685                	li	a3,1
 5f8:	4629                	li	a2,10
 5fa:	000b2583          	lw	a1,0(s6)
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e8e080e7          	jalr	-370(ra) # 48e <printint>
 608:	8b4a                	mv	s6,s2
      state = 0;
 60a:	4981                	li	s3,0
 60c:	b771                	j	598 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60e:	008b0913          	addi	s2,s6,8
 612:	4681                	li	a3,0
 614:	4629                	li	a2,10
 616:	000b2583          	lw	a1,0(s6)
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	e72080e7          	jalr	-398(ra) # 48e <printint>
 624:	8b4a                	mv	s6,s2
      state = 0;
 626:	4981                	li	s3,0
 628:	bf85                	j	598 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 62a:	008b0913          	addi	s2,s6,8
 62e:	4681                	li	a3,0
 630:	4641                	li	a2,16
 632:	000b2583          	lw	a1,0(s6)
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	e56080e7          	jalr	-426(ra) # 48e <printint>
 640:	8b4a                	mv	s6,s2
      state = 0;
 642:	4981                	li	s3,0
 644:	bf91                	j	598 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 646:	008b0793          	addi	a5,s6,8
 64a:	f8f43423          	sd	a5,-120(s0)
 64e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 652:	03000593          	li	a1,48
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	e14080e7          	jalr	-492(ra) # 46c <putc>
  putc(fd, 'x');
 660:	85ea                	mv	a1,s10
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e08080e7          	jalr	-504(ra) # 46c <putc>
 66c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66e:	03c9d793          	srli	a5,s3,0x3c
 672:	97de                	add	a5,a5,s7
 674:	0007c583          	lbu	a1,0(a5)
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	df2080e7          	jalr	-526(ra) # 46c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 682:	0992                	slli	s3,s3,0x4
 684:	397d                	addiw	s2,s2,-1
 686:	fe0914e3          	bnez	s2,66e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 68a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 68e:	4981                	li	s3,0
 690:	b721                	j	598 <vprintf+0x60>
        s = va_arg(ap, char*);
 692:	008b0993          	addi	s3,s6,8
 696:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 69a:	02090163          	beqz	s2,6bc <vprintf+0x184>
        while(*s != 0){
 69e:	00094583          	lbu	a1,0(s2)
 6a2:	c9a1                	beqz	a1,6f2 <vprintf+0x1ba>
          putc(fd, *s);
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	dc6080e7          	jalr	-570(ra) # 46c <putc>
          s++;
 6ae:	0905                	addi	s2,s2,1
        while(*s != 0){
 6b0:	00094583          	lbu	a1,0(s2)
 6b4:	f9e5                	bnez	a1,6a4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6b6:	8b4e                	mv	s6,s3
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	bdf9                	j	598 <vprintf+0x60>
          s = "(null)";
 6bc:	00000917          	auipc	s2,0x0
 6c0:	27c90913          	addi	s2,s2,636 # 938 <malloc+0x136>
        while(*s != 0){
 6c4:	02800593          	li	a1,40
 6c8:	bff1                	j	6a4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6ca:	008b0913          	addi	s2,s6,8
 6ce:	000b4583          	lbu	a1,0(s6)
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	d98080e7          	jalr	-616(ra) # 46c <putc>
 6dc:	8b4a                	mv	s6,s2
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bd65                	j	598 <vprintf+0x60>
        putc(fd, c);
 6e2:	85d2                	mv	a1,s4
 6e4:	8556                	mv	a0,s5
 6e6:	00000097          	auipc	ra,0x0
 6ea:	d86080e7          	jalr	-634(ra) # 46c <putc>
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b565                	j	598 <vprintf+0x60>
        s = va_arg(ap, char*);
 6f2:	8b4e                	mv	s6,s3
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	b54d                	j	598 <vprintf+0x60>
    }
  }
}
 6f8:	70e6                	ld	ra,120(sp)
 6fa:	7446                	ld	s0,112(sp)
 6fc:	74a6                	ld	s1,104(sp)
 6fe:	7906                	ld	s2,96(sp)
 700:	69e6                	ld	s3,88(sp)
 702:	6a46                	ld	s4,80(sp)
 704:	6aa6                	ld	s5,72(sp)
 706:	6b06                	ld	s6,64(sp)
 708:	7be2                	ld	s7,56(sp)
 70a:	7c42                	ld	s8,48(sp)
 70c:	7ca2                	ld	s9,40(sp)
 70e:	7d02                	ld	s10,32(sp)
 710:	6de2                	ld	s11,24(sp)
 712:	6109                	addi	sp,sp,128
 714:	8082                	ret

0000000000000716 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 716:	715d                	addi	sp,sp,-80
 718:	ec06                	sd	ra,24(sp)
 71a:	e822                	sd	s0,16(sp)
 71c:	1000                	addi	s0,sp,32
 71e:	e010                	sd	a2,0(s0)
 720:	e414                	sd	a3,8(s0)
 722:	e818                	sd	a4,16(s0)
 724:	ec1c                	sd	a5,24(s0)
 726:	03043023          	sd	a6,32(s0)
 72a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 72e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 732:	8622                	mv	a2,s0
 734:	00000097          	auipc	ra,0x0
 738:	e04080e7          	jalr	-508(ra) # 538 <vprintf>
}
 73c:	60e2                	ld	ra,24(sp)
 73e:	6442                	ld	s0,16(sp)
 740:	6161                	addi	sp,sp,80
 742:	8082                	ret

0000000000000744 <printf>:

void
printf(const char *fmt, ...)
{
 744:	711d                	addi	sp,sp,-96
 746:	ec06                	sd	ra,24(sp)
 748:	e822                	sd	s0,16(sp)
 74a:	1000                	addi	s0,sp,32
 74c:	e40c                	sd	a1,8(s0)
 74e:	e810                	sd	a2,16(s0)
 750:	ec14                	sd	a3,24(s0)
 752:	f018                	sd	a4,32(s0)
 754:	f41c                	sd	a5,40(s0)
 756:	03043823          	sd	a6,48(s0)
 75a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 75e:	00840613          	addi	a2,s0,8
 762:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 766:	85aa                	mv	a1,a0
 768:	4505                	li	a0,1
 76a:	00000097          	auipc	ra,0x0
 76e:	dce080e7          	jalr	-562(ra) # 538 <vprintf>
}
 772:	60e2                	ld	ra,24(sp)
 774:	6442                	ld	s0,16(sp)
 776:	6125                	addi	sp,sp,96
 778:	8082                	ret

000000000000077a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77a:	1141                	addi	sp,sp,-16
 77c:	e422                	sd	s0,8(sp)
 77e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 780:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 784:	00001797          	auipc	a5,0x1
 788:	87c7b783          	ld	a5,-1924(a5) # 1000 <freep>
 78c:	a805                	j	7bc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 78e:	4618                	lw	a4,8(a2)
 790:	9db9                	addw	a1,a1,a4
 792:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 796:	6398                	ld	a4,0(a5)
 798:	6318                	ld	a4,0(a4)
 79a:	fee53823          	sd	a4,-16(a0)
 79e:	a091                	j	7e2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7a0:	ff852703          	lw	a4,-8(a0)
 7a4:	9e39                	addw	a2,a2,a4
 7a6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7a8:	ff053703          	ld	a4,-16(a0)
 7ac:	e398                	sd	a4,0(a5)
 7ae:	a099                	j	7f4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b0:	6398                	ld	a4,0(a5)
 7b2:	00e7e463          	bltu	a5,a4,7ba <free+0x40>
 7b6:	00e6ea63          	bltu	a3,a4,7ca <free+0x50>
{
 7ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bc:	fed7fae3          	bgeu	a5,a3,7b0 <free+0x36>
 7c0:	6398                	ld	a4,0(a5)
 7c2:	00e6e463          	bltu	a3,a4,7ca <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c6:	fee7eae3          	bltu	a5,a4,7ba <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7ca:	ff852583          	lw	a1,-8(a0)
 7ce:	6390                	ld	a2,0(a5)
 7d0:	02059713          	slli	a4,a1,0x20
 7d4:	9301                	srli	a4,a4,0x20
 7d6:	0712                	slli	a4,a4,0x4
 7d8:	9736                	add	a4,a4,a3
 7da:	fae60ae3          	beq	a2,a4,78e <free+0x14>
    bp->s.ptr = p->s.ptr;
 7de:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7e2:	4790                	lw	a2,8(a5)
 7e4:	02061713          	slli	a4,a2,0x20
 7e8:	9301                	srli	a4,a4,0x20
 7ea:	0712                	slli	a4,a4,0x4
 7ec:	973e                	add	a4,a4,a5
 7ee:	fae689e3          	beq	a3,a4,7a0 <free+0x26>
  } else
    p->s.ptr = bp;
 7f2:	e394                	sd	a3,0(a5)
  freep = p;
 7f4:	00001717          	auipc	a4,0x1
 7f8:	80f73623          	sd	a5,-2036(a4) # 1000 <freep>
}
 7fc:	6422                	ld	s0,8(sp)
 7fe:	0141                	addi	sp,sp,16
 800:	8082                	ret

0000000000000802 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 802:	7139                	addi	sp,sp,-64
 804:	fc06                	sd	ra,56(sp)
 806:	f822                	sd	s0,48(sp)
 808:	f426                	sd	s1,40(sp)
 80a:	f04a                	sd	s2,32(sp)
 80c:	ec4e                	sd	s3,24(sp)
 80e:	e852                	sd	s4,16(sp)
 810:	e456                	sd	s5,8(sp)
 812:	e05a                	sd	s6,0(sp)
 814:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 816:	02051493          	slli	s1,a0,0x20
 81a:	9081                	srli	s1,s1,0x20
 81c:	04bd                	addi	s1,s1,15
 81e:	8091                	srli	s1,s1,0x4
 820:	0014899b          	addiw	s3,s1,1
 824:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 826:	00000517          	auipc	a0,0x0
 82a:	7da53503          	ld	a0,2010(a0) # 1000 <freep>
 82e:	c515                	beqz	a0,85a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 830:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 832:	4798                	lw	a4,8(a5)
 834:	02977f63          	bgeu	a4,s1,872 <malloc+0x70>
 838:	8a4e                	mv	s4,s3
 83a:	0009871b          	sext.w	a4,s3
 83e:	6685                	lui	a3,0x1
 840:	00d77363          	bgeu	a4,a3,846 <malloc+0x44>
 844:	6a05                	lui	s4,0x1
 846:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 84a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84e:	00000917          	auipc	s2,0x0
 852:	7b290913          	addi	s2,s2,1970 # 1000 <freep>
  if(p == (char*)-1)
 856:	5afd                	li	s5,-1
 858:	a88d                	j	8ca <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 85a:	00000797          	auipc	a5,0x0
 85e:	7b678793          	addi	a5,a5,1974 # 1010 <base>
 862:	00000717          	auipc	a4,0x0
 866:	78f73f23          	sd	a5,1950(a4) # 1000 <freep>
 86a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 86c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 870:	b7e1                	j	838 <malloc+0x36>
      if(p->s.size == nunits)
 872:	02e48b63          	beq	s1,a4,8a8 <malloc+0xa6>
        p->s.size -= nunits;
 876:	4137073b          	subw	a4,a4,s3
 87a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 87c:	1702                	slli	a4,a4,0x20
 87e:	9301                	srli	a4,a4,0x20
 880:	0712                	slli	a4,a4,0x4
 882:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 884:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 888:	00000717          	auipc	a4,0x0
 88c:	76a73c23          	sd	a0,1912(a4) # 1000 <freep>
      return (void*)(p + 1);
 890:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 894:	70e2                	ld	ra,56(sp)
 896:	7442                	ld	s0,48(sp)
 898:	74a2                	ld	s1,40(sp)
 89a:	7902                	ld	s2,32(sp)
 89c:	69e2                	ld	s3,24(sp)
 89e:	6a42                	ld	s4,16(sp)
 8a0:	6aa2                	ld	s5,8(sp)
 8a2:	6b02                	ld	s6,0(sp)
 8a4:	6121                	addi	sp,sp,64
 8a6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8a8:	6398                	ld	a4,0(a5)
 8aa:	e118                	sd	a4,0(a0)
 8ac:	bff1                	j	888 <malloc+0x86>
  hp->s.size = nu;
 8ae:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b2:	0541                	addi	a0,a0,16
 8b4:	00000097          	auipc	ra,0x0
 8b8:	ec6080e7          	jalr	-314(ra) # 77a <free>
  return freep;
 8bc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8c0:	d971                	beqz	a0,894 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c4:	4798                	lw	a4,8(a5)
 8c6:	fa9776e3          	bgeu	a4,s1,872 <malloc+0x70>
    if(p == freep)
 8ca:	00093703          	ld	a4,0(s2)
 8ce:	853e                	mv	a0,a5
 8d0:	fef719e3          	bne	a4,a5,8c2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8d4:	8552                	mv	a0,s4
 8d6:	00000097          	auipc	ra,0x0
 8da:	b5e080e7          	jalr	-1186(ra) # 434 <sbrk>
  if(p == (char*)-1)
 8de:	fd5518e3          	bne	a0,s5,8ae <malloc+0xac>
        return 0;
 8e2:	4501                	li	a0,0
 8e4:	bf45                	j	894 <malloc+0x92>
