
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	da4080e7          	jalr	-604(ra) # 5db4 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	d92080e7          	jalr	-622(ra) # 5db4 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	29250513          	addi	a0,a0,658 # 62d0 <malloc+0x106>
      46:	00006097          	auipc	ra,0x6
      4a:	0c6080e7          	jalr	198(ra) # 610c <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	d1c080e7          	jalr	-740(ra) # 5d6c <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	0000a797          	auipc	a5,0xa
      5c:	51078793          	addi	a5,a5,1296 # a568 <uninit>
      60:	0000d697          	auipc	a3,0xd
      64:	c1868693          	addi	a3,a3,-1000 # cc78 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	27050513          	addi	a0,a0,624 # 62f0 <malloc+0x126>
      88:	00006097          	auipc	ra,0x6
      8c:	084080e7          	jalr	132(ra) # 610c <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00006097          	auipc	ra,0x6
      96:	cda080e7          	jalr	-806(ra) # 5d6c <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	26050513          	addi	a0,a0,608 # 6308 <malloc+0x13e>
      b0:	00006097          	auipc	ra,0x6
      b4:	d04080e7          	jalr	-764(ra) # 5db4 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00006097          	auipc	ra,0x6
      c0:	ce0080e7          	jalr	-800(ra) # 5d9c <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	26250513          	addi	a0,a0,610 # 6328 <malloc+0x15e>
      ce:	00006097          	auipc	ra,0x6
      d2:	ce6080e7          	jalr	-794(ra) # 5db4 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	22a50513          	addi	a0,a0,554 # 6310 <malloc+0x146>
      ee:	00006097          	auipc	ra,0x6
      f2:	01e080e7          	jalr	30(ra) # 610c <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00006097          	auipc	ra,0x6
      fc:	c74080e7          	jalr	-908(ra) # 5d6c <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	23650513          	addi	a0,a0,566 # 6338 <malloc+0x16e>
     10a:	00006097          	auipc	ra,0x6
     10e:	002080e7          	jalr	2(ra) # 610c <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00006097          	auipc	ra,0x6
     118:	c58080e7          	jalr	-936(ra) # 5d6c <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	23450513          	addi	a0,a0,564 # 6360 <malloc+0x196>
     134:	00006097          	auipc	ra,0x6
     138:	c90080e7          	jalr	-880(ra) # 5dc4 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	22050513          	addi	a0,a0,544 # 6360 <malloc+0x196>
     148:	00006097          	auipc	ra,0x6
     14c:	c6c080e7          	jalr	-916(ra) # 5db4 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	21c58593          	addi	a1,a1,540 # 6370 <malloc+0x1a6>
     15c:	00006097          	auipc	ra,0x6
     160:	c38080e7          	jalr	-968(ra) # 5d94 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	1f850513          	addi	a0,a0,504 # 6360 <malloc+0x196>
     170:	00006097          	auipc	ra,0x6
     174:	c44080e7          	jalr	-956(ra) # 5db4 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	1fc58593          	addi	a1,a1,508 # 6378 <malloc+0x1ae>
     184:	8526                	mv	a0,s1
     186:	00006097          	auipc	ra,0x6
     18a:	c0e080e7          	jalr	-1010(ra) # 5d94 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	1cc50513          	addi	a0,a0,460 # 6360 <malloc+0x196>
     19c:	00006097          	auipc	ra,0x6
     1a0:	c28080e7          	jalr	-984(ra) # 5dc4 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00006097          	auipc	ra,0x6
     1aa:	bf6080e7          	jalr	-1034(ra) # 5d9c <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00006097          	auipc	ra,0x6
     1b4:	bec080e7          	jalr	-1044(ra) # 5d9c <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	1b650513          	addi	a0,a0,438 # 6380 <malloc+0x1b6>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	f3a080e7          	jalr	-198(ra) # 610c <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00006097          	auipc	ra,0x6
     1e0:	b90080e7          	jalr	-1136(ra) # 5d6c <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00006097          	auipc	ra,0x6
     214:	ba4080e7          	jalr	-1116(ra) # 5db4 <open>
    close(fd);
     218:	00006097          	auipc	ra,0x6
     21c:	b84080e7          	jalr	-1148(ra) # 5d9c <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	andi	s1,s1,255
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00006097          	auipc	ra,0x6
     24a:	b7e080e7          	jalr	-1154(ra) # 5dc4 <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	andi	s1,s1,255
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	12c50513          	addi	a0,a0,300 # 63a8 <malloc+0x1de>
     284:	00006097          	auipc	ra,0x6
     288:	b40080e7          	jalr	-1216(ra) # 5dc4 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	118a8a93          	addi	s5,s5,280 # 63a8 <malloc+0x1de>
      int cc = write(fd, buf, sz);
     298:	0000da17          	auipc	s4,0xd
     29c:	9e0a0a13          	addi	s4,s4,-1568 # cc78 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <fourteen+0xa7>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00006097          	auipc	ra,0x6
     2b0:	b08080e7          	jalr	-1272(ra) # 5db4 <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00006097          	auipc	ra,0x6
     2c2:	ad6080e7          	jalr	-1322(ra) # 5d94 <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00006097          	auipc	ra,0x6
     2d6:	ac2080e7          	jalr	-1342(ra) # 5d94 <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00006097          	auipc	ra,0x6
     2e4:	abc080e7          	jalr	-1348(ra) # 5d9c <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00006097          	auipc	ra,0x6
     2ee:	ada080e7          	jalr	-1318(ra) # 5dc4 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	0a650513          	addi	a0,a0,166 # 63b8 <malloc+0x1ee>
     31a:	00006097          	auipc	ra,0x6
     31e:	df2080e7          	jalr	-526(ra) # 610c <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00006097          	auipc	ra,0x6
     328:	a48080e7          	jalr	-1464(ra) # 5d6c <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	0a250513          	addi	a0,a0,162 # 63d8 <malloc+0x20e>
     33e:	00006097          	auipc	ra,0x6
     342:	dce080e7          	jalr	-562(ra) # 610c <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00006097          	auipc	ra,0x6
     34c:	a24080e7          	jalr	-1500(ra) # 5d6c <exit>

0000000000000350 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     350:	7179                	addi	sp,sp,-48
     352:	f406                	sd	ra,40(sp)
     354:	f022                	sd	s0,32(sp)
     356:	ec26                	sd	s1,24(sp)
     358:	e84a                	sd	s2,16(sp)
     35a:	e44e                	sd	s3,8(sp)
     35c:	e052                	sd	s4,0(sp)
     35e:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
     360:	00006517          	auipc	a0,0x6
     364:	09050513          	addi	a0,a0,144 # 63f0 <malloc+0x226>
     368:	00006097          	auipc	ra,0x6
     36c:	a5c080e7          	jalr	-1444(ra) # 5dc4 <unlink>
     370:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     374:	00006997          	auipc	s3,0x6
     378:	07c98993          	addi	s3,s3,124 # 63f0 <malloc+0x226>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     37c:	5a7d                	li	s4,-1
     37e:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     382:	20100593          	li	a1,513
     386:	854e                	mv	a0,s3
     388:	00006097          	auipc	ra,0x6
     38c:	a2c080e7          	jalr	-1492(ra) # 5db4 <open>
     390:	84aa                	mv	s1,a0
    if(fd < 0){
     392:	06054b63          	bltz	a0,408 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
     396:	4605                	li	a2,1
     398:	85d2                	mv	a1,s4
     39a:	00006097          	auipc	ra,0x6
     39e:	9fa080e7          	jalr	-1542(ra) # 5d94 <write>
    close(fd);
     3a2:	8526                	mv	a0,s1
     3a4:	00006097          	auipc	ra,0x6
     3a8:	9f8080e7          	jalr	-1544(ra) # 5d9c <close>
    unlink("junk");
     3ac:	854e                	mv	a0,s3
     3ae:	00006097          	auipc	ra,0x6
     3b2:	a16080e7          	jalr	-1514(ra) # 5dc4 <unlink>
  for(int i = 0; i < assumed_free; i++){
     3b6:	397d                	addiw	s2,s2,-1
     3b8:	fc0915e3          	bnez	s2,382 <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     3bc:	20100593          	li	a1,513
     3c0:	00006517          	auipc	a0,0x6
     3c4:	03050513          	addi	a0,a0,48 # 63f0 <malloc+0x226>
     3c8:	00006097          	auipc	ra,0x6
     3cc:	9ec080e7          	jalr	-1556(ra) # 5db4 <open>
     3d0:	84aa                	mv	s1,a0
  if(fd < 0){
     3d2:	04054863          	bltz	a0,422 <badwrite+0xd2>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     3d6:	4605                	li	a2,1
     3d8:	00006597          	auipc	a1,0x6
     3dc:	fa058593          	addi	a1,a1,-96 # 6378 <malloc+0x1ae>
     3e0:	00006097          	auipc	ra,0x6
     3e4:	9b4080e7          	jalr	-1612(ra) # 5d94 <write>
     3e8:	4785                	li	a5,1
     3ea:	04f50963          	beq	a0,a5,43c <badwrite+0xec>
    printf("write failed\n");
     3ee:	00006517          	auipc	a0,0x6
     3f2:	02250513          	addi	a0,a0,34 # 6410 <malloc+0x246>
     3f6:	00006097          	auipc	ra,0x6
     3fa:	d16080e7          	jalr	-746(ra) # 610c <printf>
    exit(1);
     3fe:	4505                	li	a0,1
     400:	00006097          	auipc	ra,0x6
     404:	96c080e7          	jalr	-1684(ra) # 5d6c <exit>
      printf("open junk failed\n");
     408:	00006517          	auipc	a0,0x6
     40c:	ff050513          	addi	a0,a0,-16 # 63f8 <malloc+0x22e>
     410:	00006097          	auipc	ra,0x6
     414:	cfc080e7          	jalr	-772(ra) # 610c <printf>
      exit(1);
     418:	4505                	li	a0,1
     41a:	00006097          	auipc	ra,0x6
     41e:	952080e7          	jalr	-1710(ra) # 5d6c <exit>
    printf("open junk failed\n");
     422:	00006517          	auipc	a0,0x6
     426:	fd650513          	addi	a0,a0,-42 # 63f8 <malloc+0x22e>
     42a:	00006097          	auipc	ra,0x6
     42e:	ce2080e7          	jalr	-798(ra) # 610c <printf>
    exit(1);
     432:	4505                	li	a0,1
     434:	00006097          	auipc	ra,0x6
     438:	938080e7          	jalr	-1736(ra) # 5d6c <exit>
  }
  close(fd);
     43c:	8526                	mv	a0,s1
     43e:	00006097          	auipc	ra,0x6
     442:	95e080e7          	jalr	-1698(ra) # 5d9c <close>
  unlink("junk");
     446:	00006517          	auipc	a0,0x6
     44a:	faa50513          	addi	a0,a0,-86 # 63f0 <malloc+0x226>
     44e:	00006097          	auipc	ra,0x6
     452:	976080e7          	jalr	-1674(ra) # 5dc4 <unlink>

  exit(0);
     456:	4501                	li	a0,0
     458:	00006097          	auipc	ra,0x6
     45c:	914080e7          	jalr	-1772(ra) # 5d6c <exit>

0000000000000460 <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     460:	715d                	addi	sp,sp,-80
     462:	e486                	sd	ra,72(sp)
     464:	e0a2                	sd	s0,64(sp)
     466:	fc26                	sd	s1,56(sp)
     468:	f84a                	sd	s2,48(sp)
     46a:	f44e                	sd	s3,40(sp)
     46c:	0880                	addi	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     46e:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     470:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     474:	40000993          	li	s3,1024
    name[0] = 'z';
     478:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     47c:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     480:	41f4d79b          	sraiw	a5,s1,0x1f
     484:	01b7d71b          	srliw	a4,a5,0x1b
     488:	009707bb          	addw	a5,a4,s1
     48c:	4057d69b          	sraiw	a3,a5,0x5
     490:	0306869b          	addiw	a3,a3,48
     494:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     498:	8bfd                	andi	a5,a5,31
     49a:	9f99                	subw	a5,a5,a4
     49c:	0307879b          	addiw	a5,a5,48
     4a0:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     4a4:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     4a8:	fb040513          	addi	a0,s0,-80
     4ac:	00006097          	auipc	ra,0x6
     4b0:	918080e7          	jalr	-1768(ra) # 5dc4 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     4b4:	60200593          	li	a1,1538
     4b8:	fb040513          	addi	a0,s0,-80
     4bc:	00006097          	auipc	ra,0x6
     4c0:	8f8080e7          	jalr	-1800(ra) # 5db4 <open>
    if(fd < 0){
     4c4:	00054963          	bltz	a0,4d6 <outofinodes+0x76>
      // failure is eventually expected.
      break;
    }
    close(fd);
     4c8:	00006097          	auipc	ra,0x6
     4cc:	8d4080e7          	jalr	-1836(ra) # 5d9c <close>
  for(int i = 0; i < nzz; i++){
     4d0:	2485                	addiw	s1,s1,1
     4d2:	fb3493e3          	bne	s1,s3,478 <outofinodes+0x18>
     4d6:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     4d8:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     4dc:	40000993          	li	s3,1024
    name[0] = 'z';
     4e0:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     4e4:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     4e8:	41f4d79b          	sraiw	a5,s1,0x1f
     4ec:	01b7d71b          	srliw	a4,a5,0x1b
     4f0:	009707bb          	addw	a5,a4,s1
     4f4:	4057d69b          	sraiw	a3,a5,0x5
     4f8:	0306869b          	addiw	a3,a3,48
     4fc:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     500:	8bfd                	andi	a5,a5,31
     502:	9f99                	subw	a5,a5,a4
     504:	0307879b          	addiw	a5,a5,48
     508:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     50c:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     510:	fb040513          	addi	a0,s0,-80
     514:	00006097          	auipc	ra,0x6
     518:	8b0080e7          	jalr	-1872(ra) # 5dc4 <unlink>
  for(int i = 0; i < nzz; i++){
     51c:	2485                	addiw	s1,s1,1
     51e:	fd3491e3          	bne	s1,s3,4e0 <outofinodes+0x80>
  }
}
     522:	60a6                	ld	ra,72(sp)
     524:	6406                	ld	s0,64(sp)
     526:	74e2                	ld	s1,56(sp)
     528:	7942                	ld	s2,48(sp)
     52a:	79a2                	ld	s3,40(sp)
     52c:	6161                	addi	sp,sp,80
     52e:	8082                	ret

0000000000000530 <copyin>:
{
     530:	715d                	addi	sp,sp,-80
     532:	e486                	sd	ra,72(sp)
     534:	e0a2                	sd	s0,64(sp)
     536:	fc26                	sd	s1,56(sp)
     538:	f84a                	sd	s2,48(sp)
     53a:	f44e                	sd	s3,40(sp)
     53c:	f052                	sd	s4,32(sp)
     53e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     540:	4785                	li	a5,1
     542:	07fe                	slli	a5,a5,0x1f
     544:	fcf43023          	sd	a5,-64(s0)
     548:	57fd                	li	a5,-1
     54a:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     54e:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     552:	00006a17          	auipc	s4,0x6
     556:	ecea0a13          	addi	s4,s4,-306 # 6420 <malloc+0x256>
    uint64 addr = addrs[ai];
     55a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     55e:	20100593          	li	a1,513
     562:	8552                	mv	a0,s4
     564:	00006097          	auipc	ra,0x6
     568:	850080e7          	jalr	-1968(ra) # 5db4 <open>
     56c:	84aa                	mv	s1,a0
    if(fd < 0){
     56e:	08054863          	bltz	a0,5fe <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     572:	6609                	lui	a2,0x2
     574:	85ce                	mv	a1,s3
     576:	00006097          	auipc	ra,0x6
     57a:	81e080e7          	jalr	-2018(ra) # 5d94 <write>
    if(n >= 0){
     57e:	08055d63          	bgez	a0,618 <copyin+0xe8>
    close(fd);
     582:	8526                	mv	a0,s1
     584:	00006097          	auipc	ra,0x6
     588:	818080e7          	jalr	-2024(ra) # 5d9c <close>
    unlink("copyin1");
     58c:	8552                	mv	a0,s4
     58e:	00006097          	auipc	ra,0x6
     592:	836080e7          	jalr	-1994(ra) # 5dc4 <unlink>
    n = write(1, (char*)addr, 8192);
     596:	6609                	lui	a2,0x2
     598:	85ce                	mv	a1,s3
     59a:	4505                	li	a0,1
     59c:	00005097          	auipc	ra,0x5
     5a0:	7f8080e7          	jalr	2040(ra) # 5d94 <write>
    if(n > 0){
     5a4:	08a04963          	bgtz	a0,636 <copyin+0x106>
    if(pipe(fds) < 0){
     5a8:	fb840513          	addi	a0,s0,-72
     5ac:	00005097          	auipc	ra,0x5
     5b0:	7d8080e7          	jalr	2008(ra) # 5d84 <pipe>
     5b4:	0a054063          	bltz	a0,654 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     5b8:	6609                	lui	a2,0x2
     5ba:	85ce                	mv	a1,s3
     5bc:	fbc42503          	lw	a0,-68(s0)
     5c0:	00005097          	auipc	ra,0x5
     5c4:	7d4080e7          	jalr	2004(ra) # 5d94 <write>
    if(n > 0){
     5c8:	0aa04363          	bgtz	a0,66e <copyin+0x13e>
    close(fds[0]);
     5cc:	fb842503          	lw	a0,-72(s0)
     5d0:	00005097          	auipc	ra,0x5
     5d4:	7cc080e7          	jalr	1996(ra) # 5d9c <close>
    close(fds[1]);
     5d8:	fbc42503          	lw	a0,-68(s0)
     5dc:	00005097          	auipc	ra,0x5
     5e0:	7c0080e7          	jalr	1984(ra) # 5d9c <close>
  for(int ai = 0; ai < 2; ai++){
     5e4:	0921                	addi	s2,s2,8
     5e6:	fd040793          	addi	a5,s0,-48
     5ea:	f6f918e3          	bne	s2,a5,55a <copyin+0x2a>
}
     5ee:	60a6                	ld	ra,72(sp)
     5f0:	6406                	ld	s0,64(sp)
     5f2:	74e2                	ld	s1,56(sp)
     5f4:	7942                	ld	s2,48(sp)
     5f6:	79a2                	ld	s3,40(sp)
     5f8:	7a02                	ld	s4,32(sp)
     5fa:	6161                	addi	sp,sp,80
     5fc:	8082                	ret
      printf("open(copyin1) failed\n");
     5fe:	00006517          	auipc	a0,0x6
     602:	e2a50513          	addi	a0,a0,-470 # 6428 <malloc+0x25e>
     606:	00006097          	auipc	ra,0x6
     60a:	b06080e7          	jalr	-1274(ra) # 610c <printf>
      exit(1);
     60e:	4505                	li	a0,1
     610:	00005097          	auipc	ra,0x5
     614:	75c080e7          	jalr	1884(ra) # 5d6c <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     618:	862a                	mv	a2,a0
     61a:	85ce                	mv	a1,s3
     61c:	00006517          	auipc	a0,0x6
     620:	e2450513          	addi	a0,a0,-476 # 6440 <malloc+0x276>
     624:	00006097          	auipc	ra,0x6
     628:	ae8080e7          	jalr	-1304(ra) # 610c <printf>
      exit(1);
     62c:	4505                	li	a0,1
     62e:	00005097          	auipc	ra,0x5
     632:	73e080e7          	jalr	1854(ra) # 5d6c <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     636:	862a                	mv	a2,a0
     638:	85ce                	mv	a1,s3
     63a:	00006517          	auipc	a0,0x6
     63e:	e3650513          	addi	a0,a0,-458 # 6470 <malloc+0x2a6>
     642:	00006097          	auipc	ra,0x6
     646:	aca080e7          	jalr	-1334(ra) # 610c <printf>
      exit(1);
     64a:	4505                	li	a0,1
     64c:	00005097          	auipc	ra,0x5
     650:	720080e7          	jalr	1824(ra) # 5d6c <exit>
      printf("pipe() failed\n");
     654:	00006517          	auipc	a0,0x6
     658:	e4c50513          	addi	a0,a0,-436 # 64a0 <malloc+0x2d6>
     65c:	00006097          	auipc	ra,0x6
     660:	ab0080e7          	jalr	-1360(ra) # 610c <printf>
      exit(1);
     664:	4505                	li	a0,1
     666:	00005097          	auipc	ra,0x5
     66a:	706080e7          	jalr	1798(ra) # 5d6c <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     66e:	862a                	mv	a2,a0
     670:	85ce                	mv	a1,s3
     672:	00006517          	auipc	a0,0x6
     676:	e3e50513          	addi	a0,a0,-450 # 64b0 <malloc+0x2e6>
     67a:	00006097          	auipc	ra,0x6
     67e:	a92080e7          	jalr	-1390(ra) # 610c <printf>
      exit(1);
     682:	4505                	li	a0,1
     684:	00005097          	auipc	ra,0x5
     688:	6e8080e7          	jalr	1768(ra) # 5d6c <exit>

000000000000068c <copyout>:
{
     68c:	711d                	addi	sp,sp,-96
     68e:	ec86                	sd	ra,88(sp)
     690:	e8a2                	sd	s0,80(sp)
     692:	e4a6                	sd	s1,72(sp)
     694:	e0ca                	sd	s2,64(sp)
     696:	fc4e                	sd	s3,56(sp)
     698:	f852                	sd	s4,48(sp)
     69a:	f456                	sd	s5,40(sp)
     69c:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     69e:	4785                	li	a5,1
     6a0:	07fe                	slli	a5,a5,0x1f
     6a2:	faf43823          	sd	a5,-80(s0)
     6a6:	57fd                	li	a5,-1
     6a8:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     6ac:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     6b0:	00006a17          	auipc	s4,0x6
     6b4:	e30a0a13          	addi	s4,s4,-464 # 64e0 <malloc+0x316>
    n = write(fds[1], "x", 1);
     6b8:	00006a97          	auipc	s5,0x6
     6bc:	cc0a8a93          	addi	s5,s5,-832 # 6378 <malloc+0x1ae>
    uint64 addr = addrs[ai];
     6c0:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     6c4:	4581                	li	a1,0
     6c6:	8552                	mv	a0,s4
     6c8:	00005097          	auipc	ra,0x5
     6cc:	6ec080e7          	jalr	1772(ra) # 5db4 <open>
     6d0:	84aa                	mv	s1,a0
    if(fd < 0){
     6d2:	08054663          	bltz	a0,75e <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     6d6:	6609                	lui	a2,0x2
     6d8:	85ce                	mv	a1,s3
     6da:	00005097          	auipc	ra,0x5
     6de:	6b2080e7          	jalr	1714(ra) # 5d8c <read>
    if(n > 0){
     6e2:	08a04b63          	bgtz	a0,778 <copyout+0xec>
    close(fd);
     6e6:	8526                	mv	a0,s1
     6e8:	00005097          	auipc	ra,0x5
     6ec:	6b4080e7          	jalr	1716(ra) # 5d9c <close>
    if(pipe(fds) < 0){
     6f0:	fa840513          	addi	a0,s0,-88
     6f4:	00005097          	auipc	ra,0x5
     6f8:	690080e7          	jalr	1680(ra) # 5d84 <pipe>
     6fc:	08054d63          	bltz	a0,796 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     700:	4605                	li	a2,1
     702:	85d6                	mv	a1,s5
     704:	fac42503          	lw	a0,-84(s0)
     708:	00005097          	auipc	ra,0x5
     70c:	68c080e7          	jalr	1676(ra) # 5d94 <write>
    if(n != 1){
     710:	4785                	li	a5,1
     712:	08f51f63          	bne	a0,a5,7b0 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     716:	6609                	lui	a2,0x2
     718:	85ce                	mv	a1,s3
     71a:	fa842503          	lw	a0,-88(s0)
     71e:	00005097          	auipc	ra,0x5
     722:	66e080e7          	jalr	1646(ra) # 5d8c <read>
    if(n > 0){
     726:	0aa04263          	bgtz	a0,7ca <copyout+0x13e>
    close(fds[0]);
     72a:	fa842503          	lw	a0,-88(s0)
     72e:	00005097          	auipc	ra,0x5
     732:	66e080e7          	jalr	1646(ra) # 5d9c <close>
    close(fds[1]);
     736:	fac42503          	lw	a0,-84(s0)
     73a:	00005097          	auipc	ra,0x5
     73e:	662080e7          	jalr	1634(ra) # 5d9c <close>
  for(int ai = 0; ai < 2; ai++){
     742:	0921                	addi	s2,s2,8
     744:	fc040793          	addi	a5,s0,-64
     748:	f6f91ce3          	bne	s2,a5,6c0 <copyout+0x34>
}
     74c:	60e6                	ld	ra,88(sp)
     74e:	6446                	ld	s0,80(sp)
     750:	64a6                	ld	s1,72(sp)
     752:	6906                	ld	s2,64(sp)
     754:	79e2                	ld	s3,56(sp)
     756:	7a42                	ld	s4,48(sp)
     758:	7aa2                	ld	s5,40(sp)
     75a:	6125                	addi	sp,sp,96
     75c:	8082                	ret
      printf("open(README) failed\n");
     75e:	00006517          	auipc	a0,0x6
     762:	d8a50513          	addi	a0,a0,-630 # 64e8 <malloc+0x31e>
     766:	00006097          	auipc	ra,0x6
     76a:	9a6080e7          	jalr	-1626(ra) # 610c <printf>
      exit(1);
     76e:	4505                	li	a0,1
     770:	00005097          	auipc	ra,0x5
     774:	5fc080e7          	jalr	1532(ra) # 5d6c <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     778:	862a                	mv	a2,a0
     77a:	85ce                	mv	a1,s3
     77c:	00006517          	auipc	a0,0x6
     780:	d8450513          	addi	a0,a0,-636 # 6500 <malloc+0x336>
     784:	00006097          	auipc	ra,0x6
     788:	988080e7          	jalr	-1656(ra) # 610c <printf>
      exit(1);
     78c:	4505                	li	a0,1
     78e:	00005097          	auipc	ra,0x5
     792:	5de080e7          	jalr	1502(ra) # 5d6c <exit>
      printf("pipe() failed\n");
     796:	00006517          	auipc	a0,0x6
     79a:	d0a50513          	addi	a0,a0,-758 # 64a0 <malloc+0x2d6>
     79e:	00006097          	auipc	ra,0x6
     7a2:	96e080e7          	jalr	-1682(ra) # 610c <printf>
      exit(1);
     7a6:	4505                	li	a0,1
     7a8:	00005097          	auipc	ra,0x5
     7ac:	5c4080e7          	jalr	1476(ra) # 5d6c <exit>
      printf("pipe write failed\n");
     7b0:	00006517          	auipc	a0,0x6
     7b4:	d8050513          	addi	a0,a0,-640 # 6530 <malloc+0x366>
     7b8:	00006097          	auipc	ra,0x6
     7bc:	954080e7          	jalr	-1708(ra) # 610c <printf>
      exit(1);
     7c0:	4505                	li	a0,1
     7c2:	00005097          	auipc	ra,0x5
     7c6:	5aa080e7          	jalr	1450(ra) # 5d6c <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     7ca:	862a                	mv	a2,a0
     7cc:	85ce                	mv	a1,s3
     7ce:	00006517          	auipc	a0,0x6
     7d2:	d7a50513          	addi	a0,a0,-646 # 6548 <malloc+0x37e>
     7d6:	00006097          	auipc	ra,0x6
     7da:	936080e7          	jalr	-1738(ra) # 610c <printf>
      exit(1);
     7de:	4505                	li	a0,1
     7e0:	00005097          	auipc	ra,0x5
     7e4:	58c080e7          	jalr	1420(ra) # 5d6c <exit>

00000000000007e8 <truncate1>:
{
     7e8:	711d                	addi	sp,sp,-96
     7ea:	ec86                	sd	ra,88(sp)
     7ec:	e8a2                	sd	s0,80(sp)
     7ee:	e4a6                	sd	s1,72(sp)
     7f0:	e0ca                	sd	s2,64(sp)
     7f2:	fc4e                	sd	s3,56(sp)
     7f4:	f852                	sd	s4,48(sp)
     7f6:	f456                	sd	s5,40(sp)
     7f8:	1080                	addi	s0,sp,96
     7fa:	8aaa                	mv	s5,a0
  unlink("truncfile");
     7fc:	00006517          	auipc	a0,0x6
     800:	b6450513          	addi	a0,a0,-1180 # 6360 <malloc+0x196>
     804:	00005097          	auipc	ra,0x5
     808:	5c0080e7          	jalr	1472(ra) # 5dc4 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     80c:	60100593          	li	a1,1537
     810:	00006517          	auipc	a0,0x6
     814:	b5050513          	addi	a0,a0,-1200 # 6360 <malloc+0x196>
     818:	00005097          	auipc	ra,0x5
     81c:	59c080e7          	jalr	1436(ra) # 5db4 <open>
     820:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     822:	4611                	li	a2,4
     824:	00006597          	auipc	a1,0x6
     828:	b4c58593          	addi	a1,a1,-1204 # 6370 <malloc+0x1a6>
     82c:	00005097          	auipc	ra,0x5
     830:	568080e7          	jalr	1384(ra) # 5d94 <write>
  close(fd1);
     834:	8526                	mv	a0,s1
     836:	00005097          	auipc	ra,0x5
     83a:	566080e7          	jalr	1382(ra) # 5d9c <close>
  int fd2 = open("truncfile", O_RDONLY);
     83e:	4581                	li	a1,0
     840:	00006517          	auipc	a0,0x6
     844:	b2050513          	addi	a0,a0,-1248 # 6360 <malloc+0x196>
     848:	00005097          	auipc	ra,0x5
     84c:	56c080e7          	jalr	1388(ra) # 5db4 <open>
     850:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     852:	02000613          	li	a2,32
     856:	fa040593          	addi	a1,s0,-96
     85a:	00005097          	auipc	ra,0x5
     85e:	532080e7          	jalr	1330(ra) # 5d8c <read>
  if(n != 4){
     862:	4791                	li	a5,4
     864:	0cf51e63          	bne	a0,a5,940 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     868:	40100593          	li	a1,1025
     86c:	00006517          	auipc	a0,0x6
     870:	af450513          	addi	a0,a0,-1292 # 6360 <malloc+0x196>
     874:	00005097          	auipc	ra,0x5
     878:	540080e7          	jalr	1344(ra) # 5db4 <open>
     87c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     87e:	4581                	li	a1,0
     880:	00006517          	auipc	a0,0x6
     884:	ae050513          	addi	a0,a0,-1312 # 6360 <malloc+0x196>
     888:	00005097          	auipc	ra,0x5
     88c:	52c080e7          	jalr	1324(ra) # 5db4 <open>
     890:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     892:	02000613          	li	a2,32
     896:	fa040593          	addi	a1,s0,-96
     89a:	00005097          	auipc	ra,0x5
     89e:	4f2080e7          	jalr	1266(ra) # 5d8c <read>
     8a2:	8a2a                	mv	s4,a0
  if(n != 0){
     8a4:	ed4d                	bnez	a0,95e <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     8a6:	02000613          	li	a2,32
     8aa:	fa040593          	addi	a1,s0,-96
     8ae:	8526                	mv	a0,s1
     8b0:	00005097          	auipc	ra,0x5
     8b4:	4dc080e7          	jalr	1244(ra) # 5d8c <read>
     8b8:	8a2a                	mv	s4,a0
  if(n != 0){
     8ba:	e971                	bnez	a0,98e <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     8bc:	4619                	li	a2,6
     8be:	00006597          	auipc	a1,0x6
     8c2:	d1a58593          	addi	a1,a1,-742 # 65d8 <malloc+0x40e>
     8c6:	854e                	mv	a0,s3
     8c8:	00005097          	auipc	ra,0x5
     8cc:	4cc080e7          	jalr	1228(ra) # 5d94 <write>
  n = read(fd3, buf, sizeof(buf));
     8d0:	02000613          	li	a2,32
     8d4:	fa040593          	addi	a1,s0,-96
     8d8:	854a                	mv	a0,s2
     8da:	00005097          	auipc	ra,0x5
     8de:	4b2080e7          	jalr	1202(ra) # 5d8c <read>
  if(n != 6){
     8e2:	4799                	li	a5,6
     8e4:	0cf51d63          	bne	a0,a5,9be <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     8e8:	02000613          	li	a2,32
     8ec:	fa040593          	addi	a1,s0,-96
     8f0:	8526                	mv	a0,s1
     8f2:	00005097          	auipc	ra,0x5
     8f6:	49a080e7          	jalr	1178(ra) # 5d8c <read>
  if(n != 2){
     8fa:	4789                	li	a5,2
     8fc:	0ef51063          	bne	a0,a5,9dc <truncate1+0x1f4>
  unlink("truncfile");
     900:	00006517          	auipc	a0,0x6
     904:	a6050513          	addi	a0,a0,-1440 # 6360 <malloc+0x196>
     908:	00005097          	auipc	ra,0x5
     90c:	4bc080e7          	jalr	1212(ra) # 5dc4 <unlink>
  close(fd1);
     910:	854e                	mv	a0,s3
     912:	00005097          	auipc	ra,0x5
     916:	48a080e7          	jalr	1162(ra) # 5d9c <close>
  close(fd2);
     91a:	8526                	mv	a0,s1
     91c:	00005097          	auipc	ra,0x5
     920:	480080e7          	jalr	1152(ra) # 5d9c <close>
  close(fd3);
     924:	854a                	mv	a0,s2
     926:	00005097          	auipc	ra,0x5
     92a:	476080e7          	jalr	1142(ra) # 5d9c <close>
}
     92e:	60e6                	ld	ra,88(sp)
     930:	6446                	ld	s0,80(sp)
     932:	64a6                	ld	s1,72(sp)
     934:	6906                	ld	s2,64(sp)
     936:	79e2                	ld	s3,56(sp)
     938:	7a42                	ld	s4,48(sp)
     93a:	7aa2                	ld	s5,40(sp)
     93c:	6125                	addi	sp,sp,96
     93e:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     940:	862a                	mv	a2,a0
     942:	85d6                	mv	a1,s5
     944:	00006517          	auipc	a0,0x6
     948:	c3450513          	addi	a0,a0,-972 # 6578 <malloc+0x3ae>
     94c:	00005097          	auipc	ra,0x5
     950:	7c0080e7          	jalr	1984(ra) # 610c <printf>
    exit(1);
     954:	4505                	li	a0,1
     956:	00005097          	auipc	ra,0x5
     95a:	416080e7          	jalr	1046(ra) # 5d6c <exit>
    printf("aaa fd3=%d\n", fd3);
     95e:	85ca                	mv	a1,s2
     960:	00006517          	auipc	a0,0x6
     964:	c3850513          	addi	a0,a0,-968 # 6598 <malloc+0x3ce>
     968:	00005097          	auipc	ra,0x5
     96c:	7a4080e7          	jalr	1956(ra) # 610c <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     970:	8652                	mv	a2,s4
     972:	85d6                	mv	a1,s5
     974:	00006517          	auipc	a0,0x6
     978:	c3450513          	addi	a0,a0,-972 # 65a8 <malloc+0x3de>
     97c:	00005097          	auipc	ra,0x5
     980:	790080e7          	jalr	1936(ra) # 610c <printf>
    exit(1);
     984:	4505                	li	a0,1
     986:	00005097          	auipc	ra,0x5
     98a:	3e6080e7          	jalr	998(ra) # 5d6c <exit>
    printf("bbb fd2=%d\n", fd2);
     98e:	85a6                	mv	a1,s1
     990:	00006517          	auipc	a0,0x6
     994:	c3850513          	addi	a0,a0,-968 # 65c8 <malloc+0x3fe>
     998:	00005097          	auipc	ra,0x5
     99c:	774080e7          	jalr	1908(ra) # 610c <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9a0:	8652                	mv	a2,s4
     9a2:	85d6                	mv	a1,s5
     9a4:	00006517          	auipc	a0,0x6
     9a8:	c0450513          	addi	a0,a0,-1020 # 65a8 <malloc+0x3de>
     9ac:	00005097          	auipc	ra,0x5
     9b0:	760080e7          	jalr	1888(ra) # 610c <printf>
    exit(1);
     9b4:	4505                	li	a0,1
     9b6:	00005097          	auipc	ra,0x5
     9ba:	3b6080e7          	jalr	950(ra) # 5d6c <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     9be:	862a                	mv	a2,a0
     9c0:	85d6                	mv	a1,s5
     9c2:	00006517          	auipc	a0,0x6
     9c6:	c1e50513          	addi	a0,a0,-994 # 65e0 <malloc+0x416>
     9ca:	00005097          	auipc	ra,0x5
     9ce:	742080e7          	jalr	1858(ra) # 610c <printf>
    exit(1);
     9d2:	4505                	li	a0,1
     9d4:	00005097          	auipc	ra,0x5
     9d8:	398080e7          	jalr	920(ra) # 5d6c <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     9dc:	862a                	mv	a2,a0
     9de:	85d6                	mv	a1,s5
     9e0:	00006517          	auipc	a0,0x6
     9e4:	c2050513          	addi	a0,a0,-992 # 6600 <malloc+0x436>
     9e8:	00005097          	auipc	ra,0x5
     9ec:	724080e7          	jalr	1828(ra) # 610c <printf>
    exit(1);
     9f0:	4505                	li	a0,1
     9f2:	00005097          	auipc	ra,0x5
     9f6:	37a080e7          	jalr	890(ra) # 5d6c <exit>

00000000000009fa <writetest>:
{
     9fa:	7139                	addi	sp,sp,-64
     9fc:	fc06                	sd	ra,56(sp)
     9fe:	f822                	sd	s0,48(sp)
     a00:	f426                	sd	s1,40(sp)
     a02:	f04a                	sd	s2,32(sp)
     a04:	ec4e                	sd	s3,24(sp)
     a06:	e852                	sd	s4,16(sp)
     a08:	e456                	sd	s5,8(sp)
     a0a:	e05a                	sd	s6,0(sp)
     a0c:	0080                	addi	s0,sp,64
     a0e:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     a10:	20200593          	li	a1,514
     a14:	00006517          	auipc	a0,0x6
     a18:	c0c50513          	addi	a0,a0,-1012 # 6620 <malloc+0x456>
     a1c:	00005097          	auipc	ra,0x5
     a20:	398080e7          	jalr	920(ra) # 5db4 <open>
  if(fd < 0){
     a24:	0a054d63          	bltz	a0,ade <writetest+0xe4>
     a28:	892a                	mv	s2,a0
     a2a:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a2c:	00006997          	auipc	s3,0x6
     a30:	c1c98993          	addi	s3,s3,-996 # 6648 <malloc+0x47e>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a34:	00006a97          	auipc	s5,0x6
     a38:	c4ca8a93          	addi	s5,s5,-948 # 6680 <malloc+0x4b6>
  for(i = 0; i < N; i++){
     a3c:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a40:	4629                	li	a2,10
     a42:	85ce                	mv	a1,s3
     a44:	854a                	mv	a0,s2
     a46:	00005097          	auipc	ra,0x5
     a4a:	34e080e7          	jalr	846(ra) # 5d94 <write>
     a4e:	47a9                	li	a5,10
     a50:	0af51563          	bne	a0,a5,afa <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a54:	4629                	li	a2,10
     a56:	85d6                	mv	a1,s5
     a58:	854a                	mv	a0,s2
     a5a:	00005097          	auipc	ra,0x5
     a5e:	33a080e7          	jalr	826(ra) # 5d94 <write>
     a62:	47a9                	li	a5,10
     a64:	0af51a63          	bne	a0,a5,b18 <writetest+0x11e>
  for(i = 0; i < N; i++){
     a68:	2485                	addiw	s1,s1,1
     a6a:	fd449be3          	bne	s1,s4,a40 <writetest+0x46>
  close(fd);
     a6e:	854a                	mv	a0,s2
     a70:	00005097          	auipc	ra,0x5
     a74:	32c080e7          	jalr	812(ra) # 5d9c <close>
  fd = open("small", O_RDONLY);
     a78:	4581                	li	a1,0
     a7a:	00006517          	auipc	a0,0x6
     a7e:	ba650513          	addi	a0,a0,-1114 # 6620 <malloc+0x456>
     a82:	00005097          	auipc	ra,0x5
     a86:	332080e7          	jalr	818(ra) # 5db4 <open>
     a8a:	84aa                	mv	s1,a0
  if(fd < 0){
     a8c:	0a054563          	bltz	a0,b36 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     a90:	7d000613          	li	a2,2000
     a94:	0000c597          	auipc	a1,0xc
     a98:	1e458593          	addi	a1,a1,484 # cc78 <buf>
     a9c:	00005097          	auipc	ra,0x5
     aa0:	2f0080e7          	jalr	752(ra) # 5d8c <read>
  if(i != N*SZ*2){
     aa4:	7d000793          	li	a5,2000
     aa8:	0af51563          	bne	a0,a5,b52 <writetest+0x158>
  close(fd);
     aac:	8526                	mv	a0,s1
     aae:	00005097          	auipc	ra,0x5
     ab2:	2ee080e7          	jalr	750(ra) # 5d9c <close>
  if(unlink("small") < 0){
     ab6:	00006517          	auipc	a0,0x6
     aba:	b6a50513          	addi	a0,a0,-1174 # 6620 <malloc+0x456>
     abe:	00005097          	auipc	ra,0x5
     ac2:	306080e7          	jalr	774(ra) # 5dc4 <unlink>
     ac6:	0a054463          	bltz	a0,b6e <writetest+0x174>
}
     aca:	70e2                	ld	ra,56(sp)
     acc:	7442                	ld	s0,48(sp)
     ace:	74a2                	ld	s1,40(sp)
     ad0:	7902                	ld	s2,32(sp)
     ad2:	69e2                	ld	s3,24(sp)
     ad4:	6a42                	ld	s4,16(sp)
     ad6:	6aa2                	ld	s5,8(sp)
     ad8:	6b02                	ld	s6,0(sp)
     ada:	6121                	addi	sp,sp,64
     adc:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     ade:	85da                	mv	a1,s6
     ae0:	00006517          	auipc	a0,0x6
     ae4:	b4850513          	addi	a0,a0,-1208 # 6628 <malloc+0x45e>
     ae8:	00005097          	auipc	ra,0x5
     aec:	624080e7          	jalr	1572(ra) # 610c <printf>
    exit(1);
     af0:	4505                	li	a0,1
     af2:	00005097          	auipc	ra,0x5
     af6:	27a080e7          	jalr	634(ra) # 5d6c <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     afa:	8626                	mv	a2,s1
     afc:	85da                	mv	a1,s6
     afe:	00006517          	auipc	a0,0x6
     b02:	b5a50513          	addi	a0,a0,-1190 # 6658 <malloc+0x48e>
     b06:	00005097          	auipc	ra,0x5
     b0a:	606080e7          	jalr	1542(ra) # 610c <printf>
      exit(1);
     b0e:	4505                	li	a0,1
     b10:	00005097          	auipc	ra,0x5
     b14:	25c080e7          	jalr	604(ra) # 5d6c <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     b18:	8626                	mv	a2,s1
     b1a:	85da                	mv	a1,s6
     b1c:	00006517          	auipc	a0,0x6
     b20:	b7450513          	addi	a0,a0,-1164 # 6690 <malloc+0x4c6>
     b24:	00005097          	auipc	ra,0x5
     b28:	5e8080e7          	jalr	1512(ra) # 610c <printf>
      exit(1);
     b2c:	4505                	li	a0,1
     b2e:	00005097          	auipc	ra,0x5
     b32:	23e080e7          	jalr	574(ra) # 5d6c <exit>
    printf("%s: error: open small failed!\n", s);
     b36:	85da                	mv	a1,s6
     b38:	00006517          	auipc	a0,0x6
     b3c:	b8050513          	addi	a0,a0,-1152 # 66b8 <malloc+0x4ee>
     b40:	00005097          	auipc	ra,0x5
     b44:	5cc080e7          	jalr	1484(ra) # 610c <printf>
    exit(1);
     b48:	4505                	li	a0,1
     b4a:	00005097          	auipc	ra,0x5
     b4e:	222080e7          	jalr	546(ra) # 5d6c <exit>
    printf("%s: read failed\n", s);
     b52:	85da                	mv	a1,s6
     b54:	00006517          	auipc	a0,0x6
     b58:	b8450513          	addi	a0,a0,-1148 # 66d8 <malloc+0x50e>
     b5c:	00005097          	auipc	ra,0x5
     b60:	5b0080e7          	jalr	1456(ra) # 610c <printf>
    exit(1);
     b64:	4505                	li	a0,1
     b66:	00005097          	auipc	ra,0x5
     b6a:	206080e7          	jalr	518(ra) # 5d6c <exit>
    printf("%s: unlink small failed\n", s);
     b6e:	85da                	mv	a1,s6
     b70:	00006517          	auipc	a0,0x6
     b74:	b8050513          	addi	a0,a0,-1152 # 66f0 <malloc+0x526>
     b78:	00005097          	auipc	ra,0x5
     b7c:	594080e7          	jalr	1428(ra) # 610c <printf>
    exit(1);
     b80:	4505                	li	a0,1
     b82:	00005097          	auipc	ra,0x5
     b86:	1ea080e7          	jalr	490(ra) # 5d6c <exit>

0000000000000b8a <writebig>:
{
     b8a:	7139                	addi	sp,sp,-64
     b8c:	fc06                	sd	ra,56(sp)
     b8e:	f822                	sd	s0,48(sp)
     b90:	f426                	sd	s1,40(sp)
     b92:	f04a                	sd	s2,32(sp)
     b94:	ec4e                	sd	s3,24(sp)
     b96:	e852                	sd	s4,16(sp)
     b98:	e456                	sd	s5,8(sp)
     b9a:	0080                	addi	s0,sp,64
     b9c:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     b9e:	20200593          	li	a1,514
     ba2:	00006517          	auipc	a0,0x6
     ba6:	b6e50513          	addi	a0,a0,-1170 # 6710 <malloc+0x546>
     baa:	00005097          	auipc	ra,0x5
     bae:	20a080e7          	jalr	522(ra) # 5db4 <open>
     bb2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     bb4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     bb6:	0000c917          	auipc	s2,0xc
     bba:	0c290913          	addi	s2,s2,194 # cc78 <buf>
  for(i = 0; i < MAXFILE; i++){
     bbe:	10c00a13          	li	s4,268
  if(fd < 0){
     bc2:	06054c63          	bltz	a0,c3a <writebig+0xb0>
    ((int*)buf)[0] = i;
     bc6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     bca:	40000613          	li	a2,1024
     bce:	85ca                	mv	a1,s2
     bd0:	854e                	mv	a0,s3
     bd2:	00005097          	auipc	ra,0x5
     bd6:	1c2080e7          	jalr	450(ra) # 5d94 <write>
     bda:	40000793          	li	a5,1024
     bde:	06f51c63          	bne	a0,a5,c56 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     be2:	2485                	addiw	s1,s1,1
     be4:	ff4491e3          	bne	s1,s4,bc6 <writebig+0x3c>
  close(fd);
     be8:	854e                	mv	a0,s3
     bea:	00005097          	auipc	ra,0x5
     bee:	1b2080e7          	jalr	434(ra) # 5d9c <close>
  fd = open("big", O_RDONLY);
     bf2:	4581                	li	a1,0
     bf4:	00006517          	auipc	a0,0x6
     bf8:	b1c50513          	addi	a0,a0,-1252 # 6710 <malloc+0x546>
     bfc:	00005097          	auipc	ra,0x5
     c00:	1b8080e7          	jalr	440(ra) # 5db4 <open>
     c04:	89aa                	mv	s3,a0
  n = 0;
     c06:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     c08:	0000c917          	auipc	s2,0xc
     c0c:	07090913          	addi	s2,s2,112 # cc78 <buf>
  if(fd < 0){
     c10:	06054263          	bltz	a0,c74 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     c14:	40000613          	li	a2,1024
     c18:	85ca                	mv	a1,s2
     c1a:	854e                	mv	a0,s3
     c1c:	00005097          	auipc	ra,0x5
     c20:	170080e7          	jalr	368(ra) # 5d8c <read>
    if(i == 0){
     c24:	c535                	beqz	a0,c90 <writebig+0x106>
    } else if(i != BSIZE){
     c26:	40000793          	li	a5,1024
     c2a:	0af51f63          	bne	a0,a5,ce8 <writebig+0x15e>
    if(((int*)buf)[0] != n){
     c2e:	00092683          	lw	a3,0(s2)
     c32:	0c969a63          	bne	a3,s1,d06 <writebig+0x17c>
    n++;
     c36:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     c38:	bff1                	j	c14 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     c3a:	85d6                	mv	a1,s5
     c3c:	00006517          	auipc	a0,0x6
     c40:	adc50513          	addi	a0,a0,-1316 # 6718 <malloc+0x54e>
     c44:	00005097          	auipc	ra,0x5
     c48:	4c8080e7          	jalr	1224(ra) # 610c <printf>
    exit(1);
     c4c:	4505                	li	a0,1
     c4e:	00005097          	auipc	ra,0x5
     c52:	11e080e7          	jalr	286(ra) # 5d6c <exit>
      printf("%s: error: write big file failed\n", s, i);
     c56:	8626                	mv	a2,s1
     c58:	85d6                	mv	a1,s5
     c5a:	00006517          	auipc	a0,0x6
     c5e:	ade50513          	addi	a0,a0,-1314 # 6738 <malloc+0x56e>
     c62:	00005097          	auipc	ra,0x5
     c66:	4aa080e7          	jalr	1194(ra) # 610c <printf>
      exit(1);
     c6a:	4505                	li	a0,1
     c6c:	00005097          	auipc	ra,0x5
     c70:	100080e7          	jalr	256(ra) # 5d6c <exit>
    printf("%s: error: open big failed!\n", s);
     c74:	85d6                	mv	a1,s5
     c76:	00006517          	auipc	a0,0x6
     c7a:	aea50513          	addi	a0,a0,-1302 # 6760 <malloc+0x596>
     c7e:	00005097          	auipc	ra,0x5
     c82:	48e080e7          	jalr	1166(ra) # 610c <printf>
    exit(1);
     c86:	4505                	li	a0,1
     c88:	00005097          	auipc	ra,0x5
     c8c:	0e4080e7          	jalr	228(ra) # 5d6c <exit>
      if(n == MAXFILE - 1){
     c90:	10b00793          	li	a5,267
     c94:	02f48a63          	beq	s1,a5,cc8 <writebig+0x13e>
  close(fd);
     c98:	854e                	mv	a0,s3
     c9a:	00005097          	auipc	ra,0x5
     c9e:	102080e7          	jalr	258(ra) # 5d9c <close>
  if(unlink("big") < 0){
     ca2:	00006517          	auipc	a0,0x6
     ca6:	a6e50513          	addi	a0,a0,-1426 # 6710 <malloc+0x546>
     caa:	00005097          	auipc	ra,0x5
     cae:	11a080e7          	jalr	282(ra) # 5dc4 <unlink>
     cb2:	06054963          	bltz	a0,d24 <writebig+0x19a>
}
     cb6:	70e2                	ld	ra,56(sp)
     cb8:	7442                	ld	s0,48(sp)
     cba:	74a2                	ld	s1,40(sp)
     cbc:	7902                	ld	s2,32(sp)
     cbe:	69e2                	ld	s3,24(sp)
     cc0:	6a42                	ld	s4,16(sp)
     cc2:	6aa2                	ld	s5,8(sp)
     cc4:	6121                	addi	sp,sp,64
     cc6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     cc8:	10b00613          	li	a2,267
     ccc:	85d6                	mv	a1,s5
     cce:	00006517          	auipc	a0,0x6
     cd2:	ab250513          	addi	a0,a0,-1358 # 6780 <malloc+0x5b6>
     cd6:	00005097          	auipc	ra,0x5
     cda:	436080e7          	jalr	1078(ra) # 610c <printf>
        exit(1);
     cde:	4505                	li	a0,1
     ce0:	00005097          	auipc	ra,0x5
     ce4:	08c080e7          	jalr	140(ra) # 5d6c <exit>
      printf("%s: read failed %d\n", s, i);
     ce8:	862a                	mv	a2,a0
     cea:	85d6                	mv	a1,s5
     cec:	00006517          	auipc	a0,0x6
     cf0:	abc50513          	addi	a0,a0,-1348 # 67a8 <malloc+0x5de>
     cf4:	00005097          	auipc	ra,0x5
     cf8:	418080e7          	jalr	1048(ra) # 610c <printf>
      exit(1);
     cfc:	4505                	li	a0,1
     cfe:	00005097          	auipc	ra,0x5
     d02:	06e080e7          	jalr	110(ra) # 5d6c <exit>
      printf("%s: read content of block %d is %d\n", s,
     d06:	8626                	mv	a2,s1
     d08:	85d6                	mv	a1,s5
     d0a:	00006517          	auipc	a0,0x6
     d0e:	ab650513          	addi	a0,a0,-1354 # 67c0 <malloc+0x5f6>
     d12:	00005097          	auipc	ra,0x5
     d16:	3fa080e7          	jalr	1018(ra) # 610c <printf>
      exit(1);
     d1a:	4505                	li	a0,1
     d1c:	00005097          	auipc	ra,0x5
     d20:	050080e7          	jalr	80(ra) # 5d6c <exit>
    printf("%s: unlink big failed\n", s);
     d24:	85d6                	mv	a1,s5
     d26:	00006517          	auipc	a0,0x6
     d2a:	ac250513          	addi	a0,a0,-1342 # 67e8 <malloc+0x61e>
     d2e:	00005097          	auipc	ra,0x5
     d32:	3de080e7          	jalr	990(ra) # 610c <printf>
    exit(1);
     d36:	4505                	li	a0,1
     d38:	00005097          	auipc	ra,0x5
     d3c:	034080e7          	jalr	52(ra) # 5d6c <exit>

0000000000000d40 <unlinkread>:
{
     d40:	7179                	addi	sp,sp,-48
     d42:	f406                	sd	ra,40(sp)
     d44:	f022                	sd	s0,32(sp)
     d46:	ec26                	sd	s1,24(sp)
     d48:	e84a                	sd	s2,16(sp)
     d4a:	e44e                	sd	s3,8(sp)
     d4c:	1800                	addi	s0,sp,48
     d4e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     d50:	20200593          	li	a1,514
     d54:	00006517          	auipc	a0,0x6
     d58:	aac50513          	addi	a0,a0,-1364 # 6800 <malloc+0x636>
     d5c:	00005097          	auipc	ra,0x5
     d60:	058080e7          	jalr	88(ra) # 5db4 <open>
  if(fd < 0){
     d64:	0e054563          	bltz	a0,e4e <unlinkread+0x10e>
     d68:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     d6a:	4615                	li	a2,5
     d6c:	00006597          	auipc	a1,0x6
     d70:	ac458593          	addi	a1,a1,-1340 # 6830 <malloc+0x666>
     d74:	00005097          	auipc	ra,0x5
     d78:	020080e7          	jalr	32(ra) # 5d94 <write>
  close(fd);
     d7c:	8526                	mv	a0,s1
     d7e:	00005097          	auipc	ra,0x5
     d82:	01e080e7          	jalr	30(ra) # 5d9c <close>
  fd = open("unlinkread", O_RDWR);
     d86:	4589                	li	a1,2
     d88:	00006517          	auipc	a0,0x6
     d8c:	a7850513          	addi	a0,a0,-1416 # 6800 <malloc+0x636>
     d90:	00005097          	auipc	ra,0x5
     d94:	024080e7          	jalr	36(ra) # 5db4 <open>
     d98:	84aa                	mv	s1,a0
  if(fd < 0){
     d9a:	0c054863          	bltz	a0,e6a <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     d9e:	00006517          	auipc	a0,0x6
     da2:	a6250513          	addi	a0,a0,-1438 # 6800 <malloc+0x636>
     da6:	00005097          	auipc	ra,0x5
     daa:	01e080e7          	jalr	30(ra) # 5dc4 <unlink>
     dae:	ed61                	bnez	a0,e86 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     db0:	20200593          	li	a1,514
     db4:	00006517          	auipc	a0,0x6
     db8:	a4c50513          	addi	a0,a0,-1460 # 6800 <malloc+0x636>
     dbc:	00005097          	auipc	ra,0x5
     dc0:	ff8080e7          	jalr	-8(ra) # 5db4 <open>
     dc4:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     dc6:	460d                	li	a2,3
     dc8:	00006597          	auipc	a1,0x6
     dcc:	ab058593          	addi	a1,a1,-1360 # 6878 <malloc+0x6ae>
     dd0:	00005097          	auipc	ra,0x5
     dd4:	fc4080e7          	jalr	-60(ra) # 5d94 <write>
  close(fd1);
     dd8:	854a                	mv	a0,s2
     dda:	00005097          	auipc	ra,0x5
     dde:	fc2080e7          	jalr	-62(ra) # 5d9c <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     de2:	660d                	lui	a2,0x3
     de4:	0000c597          	auipc	a1,0xc
     de8:	e9458593          	addi	a1,a1,-364 # cc78 <buf>
     dec:	8526                	mv	a0,s1
     dee:	00005097          	auipc	ra,0x5
     df2:	f9e080e7          	jalr	-98(ra) # 5d8c <read>
     df6:	4795                	li	a5,5
     df8:	0af51563          	bne	a0,a5,ea2 <unlinkread+0x162>
  if(buf[0] != 'h'){
     dfc:	0000c717          	auipc	a4,0xc
     e00:	e7c74703          	lbu	a4,-388(a4) # cc78 <buf>
     e04:	06800793          	li	a5,104
     e08:	0af71b63          	bne	a4,a5,ebe <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     e0c:	4629                	li	a2,10
     e0e:	0000c597          	auipc	a1,0xc
     e12:	e6a58593          	addi	a1,a1,-406 # cc78 <buf>
     e16:	8526                	mv	a0,s1
     e18:	00005097          	auipc	ra,0x5
     e1c:	f7c080e7          	jalr	-132(ra) # 5d94 <write>
     e20:	47a9                	li	a5,10
     e22:	0af51c63          	bne	a0,a5,eda <unlinkread+0x19a>
  close(fd);
     e26:	8526                	mv	a0,s1
     e28:	00005097          	auipc	ra,0x5
     e2c:	f74080e7          	jalr	-140(ra) # 5d9c <close>
  unlink("unlinkread");
     e30:	00006517          	auipc	a0,0x6
     e34:	9d050513          	addi	a0,a0,-1584 # 6800 <malloc+0x636>
     e38:	00005097          	auipc	ra,0x5
     e3c:	f8c080e7          	jalr	-116(ra) # 5dc4 <unlink>
}
     e40:	70a2                	ld	ra,40(sp)
     e42:	7402                	ld	s0,32(sp)
     e44:	64e2                	ld	s1,24(sp)
     e46:	6942                	ld	s2,16(sp)
     e48:	69a2                	ld	s3,8(sp)
     e4a:	6145                	addi	sp,sp,48
     e4c:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     e4e:	85ce                	mv	a1,s3
     e50:	00006517          	auipc	a0,0x6
     e54:	9c050513          	addi	a0,a0,-1600 # 6810 <malloc+0x646>
     e58:	00005097          	auipc	ra,0x5
     e5c:	2b4080e7          	jalr	692(ra) # 610c <printf>
    exit(1);
     e60:	4505                	li	a0,1
     e62:	00005097          	auipc	ra,0x5
     e66:	f0a080e7          	jalr	-246(ra) # 5d6c <exit>
    printf("%s: open unlinkread failed\n", s);
     e6a:	85ce                	mv	a1,s3
     e6c:	00006517          	auipc	a0,0x6
     e70:	9cc50513          	addi	a0,a0,-1588 # 6838 <malloc+0x66e>
     e74:	00005097          	auipc	ra,0x5
     e78:	298080e7          	jalr	664(ra) # 610c <printf>
    exit(1);
     e7c:	4505                	li	a0,1
     e7e:	00005097          	auipc	ra,0x5
     e82:	eee080e7          	jalr	-274(ra) # 5d6c <exit>
    printf("%s: unlink unlinkread failed\n", s);
     e86:	85ce                	mv	a1,s3
     e88:	00006517          	auipc	a0,0x6
     e8c:	9d050513          	addi	a0,a0,-1584 # 6858 <malloc+0x68e>
     e90:	00005097          	auipc	ra,0x5
     e94:	27c080e7          	jalr	636(ra) # 610c <printf>
    exit(1);
     e98:	4505                	li	a0,1
     e9a:	00005097          	auipc	ra,0x5
     e9e:	ed2080e7          	jalr	-302(ra) # 5d6c <exit>
    printf("%s: unlinkread read failed", s);
     ea2:	85ce                	mv	a1,s3
     ea4:	00006517          	auipc	a0,0x6
     ea8:	9dc50513          	addi	a0,a0,-1572 # 6880 <malloc+0x6b6>
     eac:	00005097          	auipc	ra,0x5
     eb0:	260080e7          	jalr	608(ra) # 610c <printf>
    exit(1);
     eb4:	4505                	li	a0,1
     eb6:	00005097          	auipc	ra,0x5
     eba:	eb6080e7          	jalr	-330(ra) # 5d6c <exit>
    printf("%s: unlinkread wrong data\n", s);
     ebe:	85ce                	mv	a1,s3
     ec0:	00006517          	auipc	a0,0x6
     ec4:	9e050513          	addi	a0,a0,-1568 # 68a0 <malloc+0x6d6>
     ec8:	00005097          	auipc	ra,0x5
     ecc:	244080e7          	jalr	580(ra) # 610c <printf>
    exit(1);
     ed0:	4505                	li	a0,1
     ed2:	00005097          	auipc	ra,0x5
     ed6:	e9a080e7          	jalr	-358(ra) # 5d6c <exit>
    printf("%s: unlinkread write failed\n", s);
     eda:	85ce                	mv	a1,s3
     edc:	00006517          	auipc	a0,0x6
     ee0:	9e450513          	addi	a0,a0,-1564 # 68c0 <malloc+0x6f6>
     ee4:	00005097          	auipc	ra,0x5
     ee8:	228080e7          	jalr	552(ra) # 610c <printf>
    exit(1);
     eec:	4505                	li	a0,1
     eee:	00005097          	auipc	ra,0x5
     ef2:	e7e080e7          	jalr	-386(ra) # 5d6c <exit>

0000000000000ef6 <linktest>:
{
     ef6:	1101                	addi	sp,sp,-32
     ef8:	ec06                	sd	ra,24(sp)
     efa:	e822                	sd	s0,16(sp)
     efc:	e426                	sd	s1,8(sp)
     efe:	e04a                	sd	s2,0(sp)
     f00:	1000                	addi	s0,sp,32
     f02:	892a                	mv	s2,a0
  unlink("lf1");
     f04:	00006517          	auipc	a0,0x6
     f08:	9dc50513          	addi	a0,a0,-1572 # 68e0 <malloc+0x716>
     f0c:	00005097          	auipc	ra,0x5
     f10:	eb8080e7          	jalr	-328(ra) # 5dc4 <unlink>
  unlink("lf2");
     f14:	00006517          	auipc	a0,0x6
     f18:	9d450513          	addi	a0,a0,-1580 # 68e8 <malloc+0x71e>
     f1c:	00005097          	auipc	ra,0x5
     f20:	ea8080e7          	jalr	-344(ra) # 5dc4 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     f24:	20200593          	li	a1,514
     f28:	00006517          	auipc	a0,0x6
     f2c:	9b850513          	addi	a0,a0,-1608 # 68e0 <malloc+0x716>
     f30:	00005097          	auipc	ra,0x5
     f34:	e84080e7          	jalr	-380(ra) # 5db4 <open>
  if(fd < 0){
     f38:	10054763          	bltz	a0,1046 <linktest+0x150>
     f3c:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     f3e:	4615                	li	a2,5
     f40:	00006597          	auipc	a1,0x6
     f44:	8f058593          	addi	a1,a1,-1808 # 6830 <malloc+0x666>
     f48:	00005097          	auipc	ra,0x5
     f4c:	e4c080e7          	jalr	-436(ra) # 5d94 <write>
     f50:	4795                	li	a5,5
     f52:	10f51863          	bne	a0,a5,1062 <linktest+0x16c>
  close(fd);
     f56:	8526                	mv	a0,s1
     f58:	00005097          	auipc	ra,0x5
     f5c:	e44080e7          	jalr	-444(ra) # 5d9c <close>
  if(link("lf1", "lf2") < 0){
     f60:	00006597          	auipc	a1,0x6
     f64:	98858593          	addi	a1,a1,-1656 # 68e8 <malloc+0x71e>
     f68:	00006517          	auipc	a0,0x6
     f6c:	97850513          	addi	a0,a0,-1672 # 68e0 <malloc+0x716>
     f70:	00005097          	auipc	ra,0x5
     f74:	e64080e7          	jalr	-412(ra) # 5dd4 <link>
     f78:	10054363          	bltz	a0,107e <linktest+0x188>
  unlink("lf1");
     f7c:	00006517          	auipc	a0,0x6
     f80:	96450513          	addi	a0,a0,-1692 # 68e0 <malloc+0x716>
     f84:	00005097          	auipc	ra,0x5
     f88:	e40080e7          	jalr	-448(ra) # 5dc4 <unlink>
  if(open("lf1", 0) >= 0){
     f8c:	4581                	li	a1,0
     f8e:	00006517          	auipc	a0,0x6
     f92:	95250513          	addi	a0,a0,-1710 # 68e0 <malloc+0x716>
     f96:	00005097          	auipc	ra,0x5
     f9a:	e1e080e7          	jalr	-482(ra) # 5db4 <open>
     f9e:	0e055e63          	bgez	a0,109a <linktest+0x1a4>
  fd = open("lf2", 0);
     fa2:	4581                	li	a1,0
     fa4:	00006517          	auipc	a0,0x6
     fa8:	94450513          	addi	a0,a0,-1724 # 68e8 <malloc+0x71e>
     fac:	00005097          	auipc	ra,0x5
     fb0:	e08080e7          	jalr	-504(ra) # 5db4 <open>
     fb4:	84aa                	mv	s1,a0
  if(fd < 0){
     fb6:	10054063          	bltz	a0,10b6 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     fba:	660d                	lui	a2,0x3
     fbc:	0000c597          	auipc	a1,0xc
     fc0:	cbc58593          	addi	a1,a1,-836 # cc78 <buf>
     fc4:	00005097          	auipc	ra,0x5
     fc8:	dc8080e7          	jalr	-568(ra) # 5d8c <read>
     fcc:	4795                	li	a5,5
     fce:	10f51263          	bne	a0,a5,10d2 <linktest+0x1dc>
  close(fd);
     fd2:	8526                	mv	a0,s1
     fd4:	00005097          	auipc	ra,0x5
     fd8:	dc8080e7          	jalr	-568(ra) # 5d9c <close>
  if(link("lf2", "lf2") >= 0){
     fdc:	00006597          	auipc	a1,0x6
     fe0:	90c58593          	addi	a1,a1,-1780 # 68e8 <malloc+0x71e>
     fe4:	852e                	mv	a0,a1
     fe6:	00005097          	auipc	ra,0x5
     fea:	dee080e7          	jalr	-530(ra) # 5dd4 <link>
     fee:	10055063          	bgez	a0,10ee <linktest+0x1f8>
  unlink("lf2");
     ff2:	00006517          	auipc	a0,0x6
     ff6:	8f650513          	addi	a0,a0,-1802 # 68e8 <malloc+0x71e>
     ffa:	00005097          	auipc	ra,0x5
     ffe:	dca080e7          	jalr	-566(ra) # 5dc4 <unlink>
  if(link("lf2", "lf1") >= 0){
    1002:	00006597          	auipc	a1,0x6
    1006:	8de58593          	addi	a1,a1,-1826 # 68e0 <malloc+0x716>
    100a:	00006517          	auipc	a0,0x6
    100e:	8de50513          	addi	a0,a0,-1826 # 68e8 <malloc+0x71e>
    1012:	00005097          	auipc	ra,0x5
    1016:	dc2080e7          	jalr	-574(ra) # 5dd4 <link>
    101a:	0e055863          	bgez	a0,110a <linktest+0x214>
  if(link(".", "lf1") >= 0){
    101e:	00006597          	auipc	a1,0x6
    1022:	8c258593          	addi	a1,a1,-1854 # 68e0 <malloc+0x716>
    1026:	00006517          	auipc	a0,0x6
    102a:	9ca50513          	addi	a0,a0,-1590 # 69f0 <malloc+0x826>
    102e:	00005097          	auipc	ra,0x5
    1032:	da6080e7          	jalr	-602(ra) # 5dd4 <link>
    1036:	0e055863          	bgez	a0,1126 <linktest+0x230>
}
    103a:	60e2                	ld	ra,24(sp)
    103c:	6442                	ld	s0,16(sp)
    103e:	64a2                	ld	s1,8(sp)
    1040:	6902                	ld	s2,0(sp)
    1042:	6105                	addi	sp,sp,32
    1044:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    1046:	85ca                	mv	a1,s2
    1048:	00006517          	auipc	a0,0x6
    104c:	8a850513          	addi	a0,a0,-1880 # 68f0 <malloc+0x726>
    1050:	00005097          	auipc	ra,0x5
    1054:	0bc080e7          	jalr	188(ra) # 610c <printf>
    exit(1);
    1058:	4505                	li	a0,1
    105a:	00005097          	auipc	ra,0x5
    105e:	d12080e7          	jalr	-750(ra) # 5d6c <exit>
    printf("%s: write lf1 failed\n", s);
    1062:	85ca                	mv	a1,s2
    1064:	00006517          	auipc	a0,0x6
    1068:	8a450513          	addi	a0,a0,-1884 # 6908 <malloc+0x73e>
    106c:	00005097          	auipc	ra,0x5
    1070:	0a0080e7          	jalr	160(ra) # 610c <printf>
    exit(1);
    1074:	4505                	li	a0,1
    1076:	00005097          	auipc	ra,0x5
    107a:	cf6080e7          	jalr	-778(ra) # 5d6c <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    107e:	85ca                	mv	a1,s2
    1080:	00006517          	auipc	a0,0x6
    1084:	8a050513          	addi	a0,a0,-1888 # 6920 <malloc+0x756>
    1088:	00005097          	auipc	ra,0x5
    108c:	084080e7          	jalr	132(ra) # 610c <printf>
    exit(1);
    1090:	4505                	li	a0,1
    1092:	00005097          	auipc	ra,0x5
    1096:	cda080e7          	jalr	-806(ra) # 5d6c <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    109a:	85ca                	mv	a1,s2
    109c:	00006517          	auipc	a0,0x6
    10a0:	8a450513          	addi	a0,a0,-1884 # 6940 <malloc+0x776>
    10a4:	00005097          	auipc	ra,0x5
    10a8:	068080e7          	jalr	104(ra) # 610c <printf>
    exit(1);
    10ac:	4505                	li	a0,1
    10ae:	00005097          	auipc	ra,0x5
    10b2:	cbe080e7          	jalr	-834(ra) # 5d6c <exit>
    printf("%s: open lf2 failed\n", s);
    10b6:	85ca                	mv	a1,s2
    10b8:	00006517          	auipc	a0,0x6
    10bc:	8b850513          	addi	a0,a0,-1864 # 6970 <malloc+0x7a6>
    10c0:	00005097          	auipc	ra,0x5
    10c4:	04c080e7          	jalr	76(ra) # 610c <printf>
    exit(1);
    10c8:	4505                	li	a0,1
    10ca:	00005097          	auipc	ra,0x5
    10ce:	ca2080e7          	jalr	-862(ra) # 5d6c <exit>
    printf("%s: read lf2 failed\n", s);
    10d2:	85ca                	mv	a1,s2
    10d4:	00006517          	auipc	a0,0x6
    10d8:	8b450513          	addi	a0,a0,-1868 # 6988 <malloc+0x7be>
    10dc:	00005097          	auipc	ra,0x5
    10e0:	030080e7          	jalr	48(ra) # 610c <printf>
    exit(1);
    10e4:	4505                	li	a0,1
    10e6:	00005097          	auipc	ra,0x5
    10ea:	c86080e7          	jalr	-890(ra) # 5d6c <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    10ee:	85ca                	mv	a1,s2
    10f0:	00006517          	auipc	a0,0x6
    10f4:	8b050513          	addi	a0,a0,-1872 # 69a0 <malloc+0x7d6>
    10f8:	00005097          	auipc	ra,0x5
    10fc:	014080e7          	jalr	20(ra) # 610c <printf>
    exit(1);
    1100:	4505                	li	a0,1
    1102:	00005097          	auipc	ra,0x5
    1106:	c6a080e7          	jalr	-918(ra) # 5d6c <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    110a:	85ca                	mv	a1,s2
    110c:	00006517          	auipc	a0,0x6
    1110:	8bc50513          	addi	a0,a0,-1860 # 69c8 <malloc+0x7fe>
    1114:	00005097          	auipc	ra,0x5
    1118:	ff8080e7          	jalr	-8(ra) # 610c <printf>
    exit(1);
    111c:	4505                	li	a0,1
    111e:	00005097          	auipc	ra,0x5
    1122:	c4e080e7          	jalr	-946(ra) # 5d6c <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    1126:	85ca                	mv	a1,s2
    1128:	00006517          	auipc	a0,0x6
    112c:	8d050513          	addi	a0,a0,-1840 # 69f8 <malloc+0x82e>
    1130:	00005097          	auipc	ra,0x5
    1134:	fdc080e7          	jalr	-36(ra) # 610c <printf>
    exit(1);
    1138:	4505                	li	a0,1
    113a:	00005097          	auipc	ra,0x5
    113e:	c32080e7          	jalr	-974(ra) # 5d6c <exit>

0000000000001142 <validatetest>:
{
    1142:	7139                	addi	sp,sp,-64
    1144:	fc06                	sd	ra,56(sp)
    1146:	f822                	sd	s0,48(sp)
    1148:	f426                	sd	s1,40(sp)
    114a:	f04a                	sd	s2,32(sp)
    114c:	ec4e                	sd	s3,24(sp)
    114e:	e852                	sd	s4,16(sp)
    1150:	e456                	sd	s5,8(sp)
    1152:	e05a                	sd	s6,0(sp)
    1154:	0080                	addi	s0,sp,64
    1156:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1158:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    115a:	00006997          	auipc	s3,0x6
    115e:	8be98993          	addi	s3,s3,-1858 # 6a18 <malloc+0x84e>
    1162:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1164:	6a85                	lui	s5,0x1
    1166:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    116a:	85a6                	mv	a1,s1
    116c:	854e                	mv	a0,s3
    116e:	00005097          	auipc	ra,0x5
    1172:	c66080e7          	jalr	-922(ra) # 5dd4 <link>
    1176:	01251f63          	bne	a0,s2,1194 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    117a:	94d6                	add	s1,s1,s5
    117c:	ff4497e3          	bne	s1,s4,116a <validatetest+0x28>
}
    1180:	70e2                	ld	ra,56(sp)
    1182:	7442                	ld	s0,48(sp)
    1184:	74a2                	ld	s1,40(sp)
    1186:	7902                	ld	s2,32(sp)
    1188:	69e2                	ld	s3,24(sp)
    118a:	6a42                	ld	s4,16(sp)
    118c:	6aa2                	ld	s5,8(sp)
    118e:	6b02                	ld	s6,0(sp)
    1190:	6121                	addi	sp,sp,64
    1192:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1194:	85da                	mv	a1,s6
    1196:	00006517          	auipc	a0,0x6
    119a:	89250513          	addi	a0,a0,-1902 # 6a28 <malloc+0x85e>
    119e:	00005097          	auipc	ra,0x5
    11a2:	f6e080e7          	jalr	-146(ra) # 610c <printf>
      exit(1);
    11a6:	4505                	li	a0,1
    11a8:	00005097          	auipc	ra,0x5
    11ac:	bc4080e7          	jalr	-1084(ra) # 5d6c <exit>

00000000000011b0 <bigdir>:
{
    11b0:	715d                	addi	sp,sp,-80
    11b2:	e486                	sd	ra,72(sp)
    11b4:	e0a2                	sd	s0,64(sp)
    11b6:	fc26                	sd	s1,56(sp)
    11b8:	f84a                	sd	s2,48(sp)
    11ba:	f44e                	sd	s3,40(sp)
    11bc:	f052                	sd	s4,32(sp)
    11be:	ec56                	sd	s5,24(sp)
    11c0:	e85a                	sd	s6,16(sp)
    11c2:	0880                	addi	s0,sp,80
    11c4:	89aa                	mv	s3,a0
  unlink("bd");
    11c6:	00006517          	auipc	a0,0x6
    11ca:	88250513          	addi	a0,a0,-1918 # 6a48 <malloc+0x87e>
    11ce:	00005097          	auipc	ra,0x5
    11d2:	bf6080e7          	jalr	-1034(ra) # 5dc4 <unlink>
  fd = open("bd", O_CREATE);
    11d6:	20000593          	li	a1,512
    11da:	00006517          	auipc	a0,0x6
    11de:	86e50513          	addi	a0,a0,-1938 # 6a48 <malloc+0x87e>
    11e2:	00005097          	auipc	ra,0x5
    11e6:	bd2080e7          	jalr	-1070(ra) # 5db4 <open>
  if(fd < 0){
    11ea:	0c054963          	bltz	a0,12bc <bigdir+0x10c>
  close(fd);
    11ee:	00005097          	auipc	ra,0x5
    11f2:	bae080e7          	jalr	-1106(ra) # 5d9c <close>
  for(i = 0; i < N; i++){
    11f6:	4901                	li	s2,0
    name[0] = 'x';
    11f8:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    11fc:	00006a17          	auipc	s4,0x6
    1200:	84ca0a13          	addi	s4,s4,-1972 # 6a48 <malloc+0x87e>
  for(i = 0; i < N; i++){
    1204:	1f400b13          	li	s6,500
    name[0] = 'x';
    1208:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    120c:	41f9579b          	sraiw	a5,s2,0x1f
    1210:	01a7d71b          	srliw	a4,a5,0x1a
    1214:	012707bb          	addw	a5,a4,s2
    1218:	4067d69b          	sraiw	a3,a5,0x6
    121c:	0306869b          	addiw	a3,a3,48
    1220:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1224:	03f7f793          	andi	a5,a5,63
    1228:	9f99                	subw	a5,a5,a4
    122a:	0307879b          	addiw	a5,a5,48
    122e:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1232:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    1236:	fb040593          	addi	a1,s0,-80
    123a:	8552                	mv	a0,s4
    123c:	00005097          	auipc	ra,0x5
    1240:	b98080e7          	jalr	-1128(ra) # 5dd4 <link>
    1244:	84aa                	mv	s1,a0
    1246:	e949                	bnez	a0,12d8 <bigdir+0x128>
  for(i = 0; i < N; i++){
    1248:	2905                	addiw	s2,s2,1
    124a:	fb691fe3          	bne	s2,s6,1208 <bigdir+0x58>
  unlink("bd");
    124e:	00005517          	auipc	a0,0x5
    1252:	7fa50513          	addi	a0,a0,2042 # 6a48 <malloc+0x87e>
    1256:	00005097          	auipc	ra,0x5
    125a:	b6e080e7          	jalr	-1170(ra) # 5dc4 <unlink>
    name[0] = 'x';
    125e:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1262:	1f400a13          	li	s4,500
    name[0] = 'x';
    1266:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    126a:	41f4d79b          	sraiw	a5,s1,0x1f
    126e:	01a7d71b          	srliw	a4,a5,0x1a
    1272:	009707bb          	addw	a5,a4,s1
    1276:	4067d69b          	sraiw	a3,a5,0x6
    127a:	0306869b          	addiw	a3,a3,48
    127e:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1282:	03f7f793          	andi	a5,a5,63
    1286:	9f99                	subw	a5,a5,a4
    1288:	0307879b          	addiw	a5,a5,48
    128c:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1290:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1294:	fb040513          	addi	a0,s0,-80
    1298:	00005097          	auipc	ra,0x5
    129c:	b2c080e7          	jalr	-1236(ra) # 5dc4 <unlink>
    12a0:	ed21                	bnez	a0,12f8 <bigdir+0x148>
  for(i = 0; i < N; i++){
    12a2:	2485                	addiw	s1,s1,1
    12a4:	fd4491e3          	bne	s1,s4,1266 <bigdir+0xb6>
}
    12a8:	60a6                	ld	ra,72(sp)
    12aa:	6406                	ld	s0,64(sp)
    12ac:	74e2                	ld	s1,56(sp)
    12ae:	7942                	ld	s2,48(sp)
    12b0:	79a2                	ld	s3,40(sp)
    12b2:	7a02                	ld	s4,32(sp)
    12b4:	6ae2                	ld	s5,24(sp)
    12b6:	6b42                	ld	s6,16(sp)
    12b8:	6161                	addi	sp,sp,80
    12ba:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    12bc:	85ce                	mv	a1,s3
    12be:	00005517          	auipc	a0,0x5
    12c2:	79250513          	addi	a0,a0,1938 # 6a50 <malloc+0x886>
    12c6:	00005097          	auipc	ra,0x5
    12ca:	e46080e7          	jalr	-442(ra) # 610c <printf>
    exit(1);
    12ce:	4505                	li	a0,1
    12d0:	00005097          	auipc	ra,0x5
    12d4:	a9c080e7          	jalr	-1380(ra) # 5d6c <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    12d8:	fb040613          	addi	a2,s0,-80
    12dc:	85ce                	mv	a1,s3
    12de:	00005517          	auipc	a0,0x5
    12e2:	79250513          	addi	a0,a0,1938 # 6a70 <malloc+0x8a6>
    12e6:	00005097          	auipc	ra,0x5
    12ea:	e26080e7          	jalr	-474(ra) # 610c <printf>
      exit(1);
    12ee:	4505                	li	a0,1
    12f0:	00005097          	auipc	ra,0x5
    12f4:	a7c080e7          	jalr	-1412(ra) # 5d6c <exit>
      printf("%s: bigdir unlink failed", s);
    12f8:	85ce                	mv	a1,s3
    12fa:	00005517          	auipc	a0,0x5
    12fe:	79650513          	addi	a0,a0,1942 # 6a90 <malloc+0x8c6>
    1302:	00005097          	auipc	ra,0x5
    1306:	e0a080e7          	jalr	-502(ra) # 610c <printf>
      exit(1);
    130a:	4505                	li	a0,1
    130c:	00005097          	auipc	ra,0x5
    1310:	a60080e7          	jalr	-1440(ra) # 5d6c <exit>

0000000000001314 <pgbug>:
{
    1314:	7179                	addi	sp,sp,-48
    1316:	f406                	sd	ra,40(sp)
    1318:	f022                	sd	s0,32(sp)
    131a:	ec26                	sd	s1,24(sp)
    131c:	1800                	addi	s0,sp,48
  argv[0] = 0;
    131e:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1322:	00008497          	auipc	s1,0x8
    1326:	cde48493          	addi	s1,s1,-802 # 9000 <big>
    132a:	fd840593          	addi	a1,s0,-40
    132e:	6088                	ld	a0,0(s1)
    1330:	00005097          	auipc	ra,0x5
    1334:	a7c080e7          	jalr	-1412(ra) # 5dac <exec>
  pipe(big);
    1338:	6088                	ld	a0,0(s1)
    133a:	00005097          	auipc	ra,0x5
    133e:	a4a080e7          	jalr	-1462(ra) # 5d84 <pipe>
  exit(0);
    1342:	4501                	li	a0,0
    1344:	00005097          	auipc	ra,0x5
    1348:	a28080e7          	jalr	-1496(ra) # 5d6c <exit>

000000000000134c <badarg>:
{
    134c:	7139                	addi	sp,sp,-64
    134e:	fc06                	sd	ra,56(sp)
    1350:	f822                	sd	s0,48(sp)
    1352:	f426                	sd	s1,40(sp)
    1354:	f04a                	sd	s2,32(sp)
    1356:	ec4e                	sd	s3,24(sp)
    1358:	0080                	addi	s0,sp,64
    135a:	64b1                	lui	s1,0xc
    135c:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1de8>
    argv[0] = (char*)0xffffffff;
    1360:	597d                	li	s2,-1
    1362:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    1366:	00005997          	auipc	s3,0x5
    136a:	fa298993          	addi	s3,s3,-94 # 6308 <malloc+0x13e>
    argv[0] = (char*)0xffffffff;
    136e:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1372:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1376:	fc040593          	addi	a1,s0,-64
    137a:	854e                	mv	a0,s3
    137c:	00005097          	auipc	ra,0x5
    1380:	a30080e7          	jalr	-1488(ra) # 5dac <exec>
  for(int i = 0; i < 50000; i++){
    1384:	34fd                	addiw	s1,s1,-1
    1386:	f4e5                	bnez	s1,136e <badarg+0x22>
  exit(0);
    1388:	4501                	li	a0,0
    138a:	00005097          	auipc	ra,0x5
    138e:	9e2080e7          	jalr	-1566(ra) # 5d6c <exit>

0000000000001392 <copyinstr2>:
{
    1392:	7155                	addi	sp,sp,-208
    1394:	e586                	sd	ra,200(sp)
    1396:	e1a2                	sd	s0,192(sp)
    1398:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    139a:	f6840793          	addi	a5,s0,-152
    139e:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    13a2:	07800713          	li	a4,120
    13a6:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    13aa:	0785                	addi	a5,a5,1
    13ac:	fed79de3          	bne	a5,a3,13a6 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    13b0:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    13b4:	f6840513          	addi	a0,s0,-152
    13b8:	00005097          	auipc	ra,0x5
    13bc:	a0c080e7          	jalr	-1524(ra) # 5dc4 <unlink>
  if(ret != -1){
    13c0:	57fd                	li	a5,-1
    13c2:	0ef51063          	bne	a0,a5,14a2 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    13c6:	20100593          	li	a1,513
    13ca:	f6840513          	addi	a0,s0,-152
    13ce:	00005097          	auipc	ra,0x5
    13d2:	9e6080e7          	jalr	-1562(ra) # 5db4 <open>
  if(fd != -1){
    13d6:	57fd                	li	a5,-1
    13d8:	0ef51563          	bne	a0,a5,14c2 <copyinstr2+0x130>
  ret = link(b, b);
    13dc:	f6840593          	addi	a1,s0,-152
    13e0:	852e                	mv	a0,a1
    13e2:	00005097          	auipc	ra,0x5
    13e6:	9f2080e7          	jalr	-1550(ra) # 5dd4 <link>
  if(ret != -1){
    13ea:	57fd                	li	a5,-1
    13ec:	0ef51b63          	bne	a0,a5,14e2 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    13f0:	00007797          	auipc	a5,0x7
    13f4:	8f878793          	addi	a5,a5,-1800 # 7ce8 <malloc+0x1b1e>
    13f8:	f4f43c23          	sd	a5,-168(s0)
    13fc:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1400:	f5840593          	addi	a1,s0,-168
    1404:	f6840513          	addi	a0,s0,-152
    1408:	00005097          	auipc	ra,0x5
    140c:	9a4080e7          	jalr	-1628(ra) # 5dac <exec>
  if(ret != -1){
    1410:	57fd                	li	a5,-1
    1412:	0ef51963          	bne	a0,a5,1504 <copyinstr2+0x172>
  int pid = fork();
    1416:	00005097          	auipc	ra,0x5
    141a:	94e080e7          	jalr	-1714(ra) # 5d64 <fork>
  if(pid < 0){
    141e:	10054363          	bltz	a0,1524 <copyinstr2+0x192>
  if(pid == 0){
    1422:	12051463          	bnez	a0,154a <copyinstr2+0x1b8>
    1426:	00008797          	auipc	a5,0x8
    142a:	13a78793          	addi	a5,a5,314 # 9560 <big.1287>
    142e:	00009697          	auipc	a3,0x9
    1432:	13268693          	addi	a3,a3,306 # a560 <big.1287+0x1000>
      big[i] = 'x';
    1436:	07800713          	li	a4,120
    143a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    143e:	0785                	addi	a5,a5,1
    1440:	fed79de3          	bne	a5,a3,143a <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1444:	00009797          	auipc	a5,0x9
    1448:	10078e23          	sb	zero,284(a5) # a560 <big.1287+0x1000>
    char *args2[] = { big, big, big, 0 };
    144c:	00007797          	auipc	a5,0x7
    1450:	2bc78793          	addi	a5,a5,700 # 8708 <malloc+0x253e>
    1454:	6390                	ld	a2,0(a5)
    1456:	6794                	ld	a3,8(a5)
    1458:	6b98                	ld	a4,16(a5)
    145a:	6f9c                	ld	a5,24(a5)
    145c:	f2c43823          	sd	a2,-208(s0)
    1460:	f2d43c23          	sd	a3,-200(s0)
    1464:	f4e43023          	sd	a4,-192(s0)
    1468:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    146c:	f3040593          	addi	a1,s0,-208
    1470:	00005517          	auipc	a0,0x5
    1474:	e9850513          	addi	a0,a0,-360 # 6308 <malloc+0x13e>
    1478:	00005097          	auipc	ra,0x5
    147c:	934080e7          	jalr	-1740(ra) # 5dac <exec>
    if(ret != -1){
    1480:	57fd                	li	a5,-1
    1482:	0af50e63          	beq	a0,a5,153e <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1486:	55fd                	li	a1,-1
    1488:	00005517          	auipc	a0,0x5
    148c:	6b050513          	addi	a0,a0,1712 # 6b38 <malloc+0x96e>
    1490:	00005097          	auipc	ra,0x5
    1494:	c7c080e7          	jalr	-900(ra) # 610c <printf>
      exit(1);
    1498:	4505                	li	a0,1
    149a:	00005097          	auipc	ra,0x5
    149e:	8d2080e7          	jalr	-1838(ra) # 5d6c <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    14a2:	862a                	mv	a2,a0
    14a4:	f6840593          	addi	a1,s0,-152
    14a8:	00005517          	auipc	a0,0x5
    14ac:	60850513          	addi	a0,a0,1544 # 6ab0 <malloc+0x8e6>
    14b0:	00005097          	auipc	ra,0x5
    14b4:	c5c080e7          	jalr	-932(ra) # 610c <printf>
    exit(1);
    14b8:	4505                	li	a0,1
    14ba:	00005097          	auipc	ra,0x5
    14be:	8b2080e7          	jalr	-1870(ra) # 5d6c <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    14c2:	862a                	mv	a2,a0
    14c4:	f6840593          	addi	a1,s0,-152
    14c8:	00005517          	auipc	a0,0x5
    14cc:	60850513          	addi	a0,a0,1544 # 6ad0 <malloc+0x906>
    14d0:	00005097          	auipc	ra,0x5
    14d4:	c3c080e7          	jalr	-964(ra) # 610c <printf>
    exit(1);
    14d8:	4505                	li	a0,1
    14da:	00005097          	auipc	ra,0x5
    14de:	892080e7          	jalr	-1902(ra) # 5d6c <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    14e2:	86aa                	mv	a3,a0
    14e4:	f6840613          	addi	a2,s0,-152
    14e8:	85b2                	mv	a1,a2
    14ea:	00005517          	auipc	a0,0x5
    14ee:	60650513          	addi	a0,a0,1542 # 6af0 <malloc+0x926>
    14f2:	00005097          	auipc	ra,0x5
    14f6:	c1a080e7          	jalr	-998(ra) # 610c <printf>
    exit(1);
    14fa:	4505                	li	a0,1
    14fc:	00005097          	auipc	ra,0x5
    1500:	870080e7          	jalr	-1936(ra) # 5d6c <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1504:	567d                	li	a2,-1
    1506:	f6840593          	addi	a1,s0,-152
    150a:	00005517          	auipc	a0,0x5
    150e:	60e50513          	addi	a0,a0,1550 # 6b18 <malloc+0x94e>
    1512:	00005097          	auipc	ra,0x5
    1516:	bfa080e7          	jalr	-1030(ra) # 610c <printf>
    exit(1);
    151a:	4505                	li	a0,1
    151c:	00005097          	auipc	ra,0x5
    1520:	850080e7          	jalr	-1968(ra) # 5d6c <exit>
    printf("fork failed\n");
    1524:	00006517          	auipc	a0,0x6
    1528:	a7450513          	addi	a0,a0,-1420 # 6f98 <malloc+0xdce>
    152c:	00005097          	auipc	ra,0x5
    1530:	be0080e7          	jalr	-1056(ra) # 610c <printf>
    exit(1);
    1534:	4505                	li	a0,1
    1536:	00005097          	auipc	ra,0x5
    153a:	836080e7          	jalr	-1994(ra) # 5d6c <exit>
    exit(747); // OK
    153e:	2eb00513          	li	a0,747
    1542:	00005097          	auipc	ra,0x5
    1546:	82a080e7          	jalr	-2006(ra) # 5d6c <exit>
  int st = 0;
    154a:	f4042a23          	sw	zero,-172(s0)
  wait(&st,"");
    154e:	00006597          	auipc	a1,0x6
    1552:	3aa58593          	addi	a1,a1,938 # 78f8 <malloc+0x172e>
    1556:	f5440513          	addi	a0,s0,-172
    155a:	00005097          	auipc	ra,0x5
    155e:	822080e7          	jalr	-2014(ra) # 5d7c <wait>
  if(st != 747){
    1562:	f5442703          	lw	a4,-172(s0)
    1566:	2eb00793          	li	a5,747
    156a:	00f71663          	bne	a4,a5,1576 <copyinstr2+0x1e4>
}
    156e:	60ae                	ld	ra,200(sp)
    1570:	640e                	ld	s0,192(sp)
    1572:	6169                	addi	sp,sp,208
    1574:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    1576:	00005517          	auipc	a0,0x5
    157a:	5ea50513          	addi	a0,a0,1514 # 6b60 <malloc+0x996>
    157e:	00005097          	auipc	ra,0x5
    1582:	b8e080e7          	jalr	-1138(ra) # 610c <printf>
    exit(1);
    1586:	4505                	li	a0,1
    1588:	00004097          	auipc	ra,0x4
    158c:	7e4080e7          	jalr	2020(ra) # 5d6c <exit>

0000000000001590 <truncate3>:
{
    1590:	7159                	addi	sp,sp,-112
    1592:	f486                	sd	ra,104(sp)
    1594:	f0a2                	sd	s0,96(sp)
    1596:	eca6                	sd	s1,88(sp)
    1598:	e8ca                	sd	s2,80(sp)
    159a:	e4ce                	sd	s3,72(sp)
    159c:	e0d2                	sd	s4,64(sp)
    159e:	fc56                	sd	s5,56(sp)
    15a0:	1880                	addi	s0,sp,112
    15a2:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    15a4:	60100593          	li	a1,1537
    15a8:	00005517          	auipc	a0,0x5
    15ac:	db850513          	addi	a0,a0,-584 # 6360 <malloc+0x196>
    15b0:	00005097          	auipc	ra,0x5
    15b4:	804080e7          	jalr	-2044(ra) # 5db4 <open>
    15b8:	00004097          	auipc	ra,0x4
    15bc:	7e4080e7          	jalr	2020(ra) # 5d9c <close>
  pid = fork();
    15c0:	00004097          	auipc	ra,0x4
    15c4:	7a4080e7          	jalr	1956(ra) # 5d64 <fork>
  if(pid < 0){
    15c8:	08054063          	bltz	a0,1648 <truncate3+0xb8>
  if(pid == 0){
    15cc:	e969                	bnez	a0,169e <truncate3+0x10e>
    15ce:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    15d2:	00005a17          	auipc	s4,0x5
    15d6:	d8ea0a13          	addi	s4,s4,-626 # 6360 <malloc+0x196>
      int n = write(fd, "1234567890", 10);
    15da:	00005a97          	auipc	s5,0x5
    15de:	5e6a8a93          	addi	s5,s5,1510 # 6bc0 <malloc+0x9f6>
      int fd = open("truncfile", O_WRONLY);
    15e2:	4585                	li	a1,1
    15e4:	8552                	mv	a0,s4
    15e6:	00004097          	auipc	ra,0x4
    15ea:	7ce080e7          	jalr	1998(ra) # 5db4 <open>
    15ee:	84aa                	mv	s1,a0
      if(fd < 0){
    15f0:	06054a63          	bltz	a0,1664 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    15f4:	4629                	li	a2,10
    15f6:	85d6                	mv	a1,s5
    15f8:	00004097          	auipc	ra,0x4
    15fc:	79c080e7          	jalr	1948(ra) # 5d94 <write>
      if(n != 10){
    1600:	47a9                	li	a5,10
    1602:	06f51f63          	bne	a0,a5,1680 <truncate3+0xf0>
      close(fd);
    1606:	8526                	mv	a0,s1
    1608:	00004097          	auipc	ra,0x4
    160c:	794080e7          	jalr	1940(ra) # 5d9c <close>
      fd = open("truncfile", O_RDONLY);
    1610:	4581                	li	a1,0
    1612:	8552                	mv	a0,s4
    1614:	00004097          	auipc	ra,0x4
    1618:	7a0080e7          	jalr	1952(ra) # 5db4 <open>
    161c:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    161e:	02000613          	li	a2,32
    1622:	f9840593          	addi	a1,s0,-104
    1626:	00004097          	auipc	ra,0x4
    162a:	766080e7          	jalr	1894(ra) # 5d8c <read>
      close(fd);
    162e:	8526                	mv	a0,s1
    1630:	00004097          	auipc	ra,0x4
    1634:	76c080e7          	jalr	1900(ra) # 5d9c <close>
    for(int i = 0; i < 100; i++){
    1638:	39fd                	addiw	s3,s3,-1
    163a:	fa0994e3          	bnez	s3,15e2 <truncate3+0x52>
    exit(0);
    163e:	4501                	li	a0,0
    1640:	00004097          	auipc	ra,0x4
    1644:	72c080e7          	jalr	1836(ra) # 5d6c <exit>
    printf("%s: fork failed\n", s);
    1648:	85ca                	mv	a1,s2
    164a:	00005517          	auipc	a0,0x5
    164e:	54650513          	addi	a0,a0,1350 # 6b90 <malloc+0x9c6>
    1652:	00005097          	auipc	ra,0x5
    1656:	aba080e7          	jalr	-1350(ra) # 610c <printf>
    exit(1);
    165a:	4505                	li	a0,1
    165c:	00004097          	auipc	ra,0x4
    1660:	710080e7          	jalr	1808(ra) # 5d6c <exit>
        printf("%s: open failed\n", s);
    1664:	85ca                	mv	a1,s2
    1666:	00005517          	auipc	a0,0x5
    166a:	54250513          	addi	a0,a0,1346 # 6ba8 <malloc+0x9de>
    166e:	00005097          	auipc	ra,0x5
    1672:	a9e080e7          	jalr	-1378(ra) # 610c <printf>
        exit(1);
    1676:	4505                	li	a0,1
    1678:	00004097          	auipc	ra,0x4
    167c:	6f4080e7          	jalr	1780(ra) # 5d6c <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1680:	862a                	mv	a2,a0
    1682:	85ca                	mv	a1,s2
    1684:	00005517          	auipc	a0,0x5
    1688:	54c50513          	addi	a0,a0,1356 # 6bd0 <malloc+0xa06>
    168c:	00005097          	auipc	ra,0x5
    1690:	a80080e7          	jalr	-1408(ra) # 610c <printf>
        exit(1);
    1694:	4505                	li	a0,1
    1696:	00004097          	auipc	ra,0x4
    169a:	6d6080e7          	jalr	1750(ra) # 5d6c <exit>
    169e:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    16a2:	00005a17          	auipc	s4,0x5
    16a6:	cbea0a13          	addi	s4,s4,-834 # 6360 <malloc+0x196>
    int n = write(fd, "xxx", 3);
    16aa:	00005a97          	auipc	s5,0x5
    16ae:	546a8a93          	addi	s5,s5,1350 # 6bf0 <malloc+0xa26>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    16b2:	60100593          	li	a1,1537
    16b6:	8552                	mv	a0,s4
    16b8:	00004097          	auipc	ra,0x4
    16bc:	6fc080e7          	jalr	1788(ra) # 5db4 <open>
    16c0:	84aa                	mv	s1,a0
    if(fd < 0){
    16c2:	04054b63          	bltz	a0,1718 <truncate3+0x188>
    int n = write(fd, "xxx", 3);
    16c6:	460d                	li	a2,3
    16c8:	85d6                	mv	a1,s5
    16ca:	00004097          	auipc	ra,0x4
    16ce:	6ca080e7          	jalr	1738(ra) # 5d94 <write>
    if(n != 3){
    16d2:	478d                	li	a5,3
    16d4:	06f51063          	bne	a0,a5,1734 <truncate3+0x1a4>
    close(fd);
    16d8:	8526                	mv	a0,s1
    16da:	00004097          	auipc	ra,0x4
    16de:	6c2080e7          	jalr	1730(ra) # 5d9c <close>
  for(int i = 0; i < 150; i++){
    16e2:	39fd                	addiw	s3,s3,-1
    16e4:	fc0997e3          	bnez	s3,16b2 <truncate3+0x122>
  wait(&xstatus,"");
    16e8:	00006597          	auipc	a1,0x6
    16ec:	21058593          	addi	a1,a1,528 # 78f8 <malloc+0x172e>
    16f0:	fbc40513          	addi	a0,s0,-68
    16f4:	00004097          	auipc	ra,0x4
    16f8:	688080e7          	jalr	1672(ra) # 5d7c <wait>
  unlink("truncfile");
    16fc:	00005517          	auipc	a0,0x5
    1700:	c6450513          	addi	a0,a0,-924 # 6360 <malloc+0x196>
    1704:	00004097          	auipc	ra,0x4
    1708:	6c0080e7          	jalr	1728(ra) # 5dc4 <unlink>
  exit(xstatus);
    170c:	fbc42503          	lw	a0,-68(s0)
    1710:	00004097          	auipc	ra,0x4
    1714:	65c080e7          	jalr	1628(ra) # 5d6c <exit>
      printf("%s: open failed\n", s);
    1718:	85ca                	mv	a1,s2
    171a:	00005517          	auipc	a0,0x5
    171e:	48e50513          	addi	a0,a0,1166 # 6ba8 <malloc+0x9de>
    1722:	00005097          	auipc	ra,0x5
    1726:	9ea080e7          	jalr	-1558(ra) # 610c <printf>
      exit(1);
    172a:	4505                	li	a0,1
    172c:	00004097          	auipc	ra,0x4
    1730:	640080e7          	jalr	1600(ra) # 5d6c <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1734:	862a                	mv	a2,a0
    1736:	85ca                	mv	a1,s2
    1738:	00005517          	auipc	a0,0x5
    173c:	4c050513          	addi	a0,a0,1216 # 6bf8 <malloc+0xa2e>
    1740:	00005097          	auipc	ra,0x5
    1744:	9cc080e7          	jalr	-1588(ra) # 610c <printf>
      exit(1);
    1748:	4505                	li	a0,1
    174a:	00004097          	auipc	ra,0x4
    174e:	622080e7          	jalr	1570(ra) # 5d6c <exit>

0000000000001752 <exectest>:
{
    1752:	715d                	addi	sp,sp,-80
    1754:	e486                	sd	ra,72(sp)
    1756:	e0a2                	sd	s0,64(sp)
    1758:	fc26                	sd	s1,56(sp)
    175a:	f84a                	sd	s2,48(sp)
    175c:	0880                	addi	s0,sp,80
    175e:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1760:	00005797          	auipc	a5,0x5
    1764:	ba878793          	addi	a5,a5,-1112 # 6308 <malloc+0x13e>
    1768:	fcf43023          	sd	a5,-64(s0)
    176c:	00005797          	auipc	a5,0x5
    1770:	4ac78793          	addi	a5,a5,1196 # 6c18 <malloc+0xa4e>
    1774:	fcf43423          	sd	a5,-56(s0)
    1778:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    177c:	00005517          	auipc	a0,0x5
    1780:	4a450513          	addi	a0,a0,1188 # 6c20 <malloc+0xa56>
    1784:	00004097          	auipc	ra,0x4
    1788:	640080e7          	jalr	1600(ra) # 5dc4 <unlink>
  pid = fork();
    178c:	00004097          	auipc	ra,0x4
    1790:	5d8080e7          	jalr	1496(ra) # 5d64 <fork>
  if(pid < 0) {
    1794:	04054663          	bltz	a0,17e0 <exectest+0x8e>
    1798:	84aa                	mv	s1,a0
  if(pid == 0) {
    179a:	e959                	bnez	a0,1830 <exectest+0xde>
    close(1);
    179c:	4505                	li	a0,1
    179e:	00004097          	auipc	ra,0x4
    17a2:	5fe080e7          	jalr	1534(ra) # 5d9c <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    17a6:	20100593          	li	a1,513
    17aa:	00005517          	auipc	a0,0x5
    17ae:	47650513          	addi	a0,a0,1142 # 6c20 <malloc+0xa56>
    17b2:	00004097          	auipc	ra,0x4
    17b6:	602080e7          	jalr	1538(ra) # 5db4 <open>
    if(fd < 0) {
    17ba:	04054163          	bltz	a0,17fc <exectest+0xaa>
    if(fd != 1) {
    17be:	4785                	li	a5,1
    17c0:	04f50c63          	beq	a0,a5,1818 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    17c4:	85ca                	mv	a1,s2
    17c6:	00005517          	auipc	a0,0x5
    17ca:	47a50513          	addi	a0,a0,1146 # 6c40 <malloc+0xa76>
    17ce:	00005097          	auipc	ra,0x5
    17d2:	93e080e7          	jalr	-1730(ra) # 610c <printf>
      exit(1);
    17d6:	4505                	li	a0,1
    17d8:	00004097          	auipc	ra,0x4
    17dc:	594080e7          	jalr	1428(ra) # 5d6c <exit>
     printf("%s: fork failed\n", s);
    17e0:	85ca                	mv	a1,s2
    17e2:	00005517          	auipc	a0,0x5
    17e6:	3ae50513          	addi	a0,a0,942 # 6b90 <malloc+0x9c6>
    17ea:	00005097          	auipc	ra,0x5
    17ee:	922080e7          	jalr	-1758(ra) # 610c <printf>
     exit(1);
    17f2:	4505                	li	a0,1
    17f4:	00004097          	auipc	ra,0x4
    17f8:	578080e7          	jalr	1400(ra) # 5d6c <exit>
      printf("%s: create failed\n", s);
    17fc:	85ca                	mv	a1,s2
    17fe:	00005517          	auipc	a0,0x5
    1802:	42a50513          	addi	a0,a0,1066 # 6c28 <malloc+0xa5e>
    1806:	00005097          	auipc	ra,0x5
    180a:	906080e7          	jalr	-1786(ra) # 610c <printf>
      exit(1);
    180e:	4505                	li	a0,1
    1810:	00004097          	auipc	ra,0x4
    1814:	55c080e7          	jalr	1372(ra) # 5d6c <exit>
    if(exec("echo", echoargv) < 0){
    1818:	fc040593          	addi	a1,s0,-64
    181c:	00005517          	auipc	a0,0x5
    1820:	aec50513          	addi	a0,a0,-1300 # 6308 <malloc+0x13e>
    1824:	00004097          	auipc	ra,0x4
    1828:	588080e7          	jalr	1416(ra) # 5dac <exec>
    182c:	02054563          	bltz	a0,1856 <exectest+0x104>
  if (wait(&xstatus,"") != pid) {
    1830:	00006597          	auipc	a1,0x6
    1834:	0c858593          	addi	a1,a1,200 # 78f8 <malloc+0x172e>
    1838:	fdc40513          	addi	a0,s0,-36
    183c:	00004097          	auipc	ra,0x4
    1840:	540080e7          	jalr	1344(ra) # 5d7c <wait>
    1844:	02951763          	bne	a0,s1,1872 <exectest+0x120>
  if(xstatus != 0)
    1848:	fdc42503          	lw	a0,-36(s0)
    184c:	cd0d                	beqz	a0,1886 <exectest+0x134>
    exit(xstatus);
    184e:	00004097          	auipc	ra,0x4
    1852:	51e080e7          	jalr	1310(ra) # 5d6c <exit>
      printf("%s: exec echo failed\n", s);
    1856:	85ca                	mv	a1,s2
    1858:	00005517          	auipc	a0,0x5
    185c:	3f850513          	addi	a0,a0,1016 # 6c50 <malloc+0xa86>
    1860:	00005097          	auipc	ra,0x5
    1864:	8ac080e7          	jalr	-1876(ra) # 610c <printf>
      exit(1);
    1868:	4505                	li	a0,1
    186a:	00004097          	auipc	ra,0x4
    186e:	502080e7          	jalr	1282(ra) # 5d6c <exit>
    printf("%s: wait failed!\n", s);
    1872:	85ca                	mv	a1,s2
    1874:	00005517          	auipc	a0,0x5
    1878:	3f450513          	addi	a0,a0,1012 # 6c68 <malloc+0xa9e>
    187c:	00005097          	auipc	ra,0x5
    1880:	890080e7          	jalr	-1904(ra) # 610c <printf>
    1884:	b7d1                	j	1848 <exectest+0xf6>
  fd = open("echo-ok", O_RDONLY);
    1886:	4581                	li	a1,0
    1888:	00005517          	auipc	a0,0x5
    188c:	39850513          	addi	a0,a0,920 # 6c20 <malloc+0xa56>
    1890:	00004097          	auipc	ra,0x4
    1894:	524080e7          	jalr	1316(ra) # 5db4 <open>
  if(fd < 0) {
    1898:	02054a63          	bltz	a0,18cc <exectest+0x17a>
  if (read(fd, buf, 2) != 2) {
    189c:	4609                	li	a2,2
    189e:	fb840593          	addi	a1,s0,-72
    18a2:	00004097          	auipc	ra,0x4
    18a6:	4ea080e7          	jalr	1258(ra) # 5d8c <read>
    18aa:	4789                	li	a5,2
    18ac:	02f50e63          	beq	a0,a5,18e8 <exectest+0x196>
    printf("%s: read failed\n", s);
    18b0:	85ca                	mv	a1,s2
    18b2:	00005517          	auipc	a0,0x5
    18b6:	e2650513          	addi	a0,a0,-474 # 66d8 <malloc+0x50e>
    18ba:	00005097          	auipc	ra,0x5
    18be:	852080e7          	jalr	-1966(ra) # 610c <printf>
    exit(1);
    18c2:	4505                	li	a0,1
    18c4:	00004097          	auipc	ra,0x4
    18c8:	4a8080e7          	jalr	1192(ra) # 5d6c <exit>
    printf("%s: open failed\n", s);
    18cc:	85ca                	mv	a1,s2
    18ce:	00005517          	auipc	a0,0x5
    18d2:	2da50513          	addi	a0,a0,730 # 6ba8 <malloc+0x9de>
    18d6:	00005097          	auipc	ra,0x5
    18da:	836080e7          	jalr	-1994(ra) # 610c <printf>
    exit(1);
    18de:	4505                	li	a0,1
    18e0:	00004097          	auipc	ra,0x4
    18e4:	48c080e7          	jalr	1164(ra) # 5d6c <exit>
  unlink("echo-ok");
    18e8:	00005517          	auipc	a0,0x5
    18ec:	33850513          	addi	a0,a0,824 # 6c20 <malloc+0xa56>
    18f0:	00004097          	auipc	ra,0x4
    18f4:	4d4080e7          	jalr	1236(ra) # 5dc4 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    18f8:	fb844703          	lbu	a4,-72(s0)
    18fc:	04f00793          	li	a5,79
    1900:	00f71863          	bne	a4,a5,1910 <exectest+0x1be>
    1904:	fb944703          	lbu	a4,-71(s0)
    1908:	04b00793          	li	a5,75
    190c:	02f70063          	beq	a4,a5,192c <exectest+0x1da>
    printf("%s: wrong output\n", s);
    1910:	85ca                	mv	a1,s2
    1912:	00005517          	auipc	a0,0x5
    1916:	36e50513          	addi	a0,a0,878 # 6c80 <malloc+0xab6>
    191a:	00004097          	auipc	ra,0x4
    191e:	7f2080e7          	jalr	2034(ra) # 610c <printf>
    exit(1);
    1922:	4505                	li	a0,1
    1924:	00004097          	auipc	ra,0x4
    1928:	448080e7          	jalr	1096(ra) # 5d6c <exit>
    exit(0);
    192c:	4501                	li	a0,0
    192e:	00004097          	auipc	ra,0x4
    1932:	43e080e7          	jalr	1086(ra) # 5d6c <exit>

0000000000001936 <pipe1>:
{
    1936:	711d                	addi	sp,sp,-96
    1938:	ec86                	sd	ra,88(sp)
    193a:	e8a2                	sd	s0,80(sp)
    193c:	e4a6                	sd	s1,72(sp)
    193e:	e0ca                	sd	s2,64(sp)
    1940:	fc4e                	sd	s3,56(sp)
    1942:	f852                	sd	s4,48(sp)
    1944:	f456                	sd	s5,40(sp)
    1946:	f05a                	sd	s6,32(sp)
    1948:	ec5e                	sd	s7,24(sp)
    194a:	1080                	addi	s0,sp,96
    194c:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    194e:	fa840513          	addi	a0,s0,-88
    1952:	00004097          	auipc	ra,0x4
    1956:	432080e7          	jalr	1074(ra) # 5d84 <pipe>
    195a:	ed25                	bnez	a0,19d2 <pipe1+0x9c>
    195c:	84aa                	mv	s1,a0
  pid = fork();
    195e:	00004097          	auipc	ra,0x4
    1962:	406080e7          	jalr	1030(ra) # 5d64 <fork>
    1966:	8a2a                	mv	s4,a0
  if(pid == 0){
    1968:	c159                	beqz	a0,19ee <pipe1+0xb8>
  } else if(pid > 0){
    196a:	18a05263          	blez	a0,1aee <pipe1+0x1b8>
    close(fds[1]);
    196e:	fac42503          	lw	a0,-84(s0)
    1972:	00004097          	auipc	ra,0x4
    1976:	42a080e7          	jalr	1066(ra) # 5d9c <close>
    total = 0;
    197a:	8a26                	mv	s4,s1
    cc = 1;
    197c:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    197e:	0000ba97          	auipc	s5,0xb
    1982:	2faa8a93          	addi	s5,s5,762 # cc78 <buf>
      if(cc > sizeof(buf))
    1986:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1988:	864e                	mv	a2,s3
    198a:	85d6                	mv	a1,s5
    198c:	fa842503          	lw	a0,-88(s0)
    1990:	00004097          	auipc	ra,0x4
    1994:	3fc080e7          	jalr	1020(ra) # 5d8c <read>
    1998:	10a05263          	blez	a0,1a9c <pipe1+0x166>
      for(i = 0; i < n; i++){
    199c:	0000b717          	auipc	a4,0xb
    19a0:	2dc70713          	addi	a4,a4,732 # cc78 <buf>
    19a4:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    19a8:	00074683          	lbu	a3,0(a4)
    19ac:	0ff4f793          	andi	a5,s1,255
    19b0:	2485                	addiw	s1,s1,1
    19b2:	0cf69163          	bne	a3,a5,1a74 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    19b6:	0705                	addi	a4,a4,1
    19b8:	fec498e3          	bne	s1,a2,19a8 <pipe1+0x72>
      total += n;
    19bc:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    19c0:	0019979b          	slliw	a5,s3,0x1
    19c4:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    19c8:	013b7363          	bgeu	s6,s3,19ce <pipe1+0x98>
        cc = sizeof(buf);
    19cc:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    19ce:	84b2                	mv	s1,a2
    19d0:	bf65                	j	1988 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    19d2:	85ca                	mv	a1,s2
    19d4:	00005517          	auipc	a0,0x5
    19d8:	2c450513          	addi	a0,a0,708 # 6c98 <malloc+0xace>
    19dc:	00004097          	auipc	ra,0x4
    19e0:	730080e7          	jalr	1840(ra) # 610c <printf>
    exit(1);
    19e4:	4505                	li	a0,1
    19e6:	00004097          	auipc	ra,0x4
    19ea:	386080e7          	jalr	902(ra) # 5d6c <exit>
    close(fds[0]);
    19ee:	fa842503          	lw	a0,-88(s0)
    19f2:	00004097          	auipc	ra,0x4
    19f6:	3aa080e7          	jalr	938(ra) # 5d9c <close>
    for(n = 0; n < N; n++){
    19fa:	0000bb17          	auipc	s6,0xb
    19fe:	27eb0b13          	addi	s6,s6,638 # cc78 <buf>
    1a02:	416004bb          	negw	s1,s6
    1a06:	0ff4f493          	andi	s1,s1,255
    1a0a:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1a0e:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1a10:	6a85                	lui	s5,0x1
    1a12:	42da8a93          	addi	s5,s5,1069 # 142d <copyinstr2+0x9b>
{
    1a16:	87da                	mv	a5,s6
        buf[i] = seq++;
    1a18:	0097873b          	addw	a4,a5,s1
    1a1c:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1a20:	0785                	addi	a5,a5,1
    1a22:	fef99be3          	bne	s3,a5,1a18 <pipe1+0xe2>
    1a26:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1a2a:	40900613          	li	a2,1033
    1a2e:	85de                	mv	a1,s7
    1a30:	fac42503          	lw	a0,-84(s0)
    1a34:	00004097          	auipc	ra,0x4
    1a38:	360080e7          	jalr	864(ra) # 5d94 <write>
    1a3c:	40900793          	li	a5,1033
    1a40:	00f51c63          	bne	a0,a5,1a58 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1a44:	24a5                	addiw	s1,s1,9
    1a46:	0ff4f493          	andi	s1,s1,255
    1a4a:	fd5a16e3          	bne	s4,s5,1a16 <pipe1+0xe0>
    exit(0);
    1a4e:	4501                	li	a0,0
    1a50:	00004097          	auipc	ra,0x4
    1a54:	31c080e7          	jalr	796(ra) # 5d6c <exit>
        printf("%s: pipe1 oops 1\n", s);
    1a58:	85ca                	mv	a1,s2
    1a5a:	00005517          	auipc	a0,0x5
    1a5e:	25650513          	addi	a0,a0,598 # 6cb0 <malloc+0xae6>
    1a62:	00004097          	auipc	ra,0x4
    1a66:	6aa080e7          	jalr	1706(ra) # 610c <printf>
        exit(1);
    1a6a:	4505                	li	a0,1
    1a6c:	00004097          	auipc	ra,0x4
    1a70:	300080e7          	jalr	768(ra) # 5d6c <exit>
          printf("%s: pipe1 oops 2\n", s);
    1a74:	85ca                	mv	a1,s2
    1a76:	00005517          	auipc	a0,0x5
    1a7a:	25250513          	addi	a0,a0,594 # 6cc8 <malloc+0xafe>
    1a7e:	00004097          	auipc	ra,0x4
    1a82:	68e080e7          	jalr	1678(ra) # 610c <printf>
}
    1a86:	60e6                	ld	ra,88(sp)
    1a88:	6446                	ld	s0,80(sp)
    1a8a:	64a6                	ld	s1,72(sp)
    1a8c:	6906                	ld	s2,64(sp)
    1a8e:	79e2                	ld	s3,56(sp)
    1a90:	7a42                	ld	s4,48(sp)
    1a92:	7aa2                	ld	s5,40(sp)
    1a94:	7b02                	ld	s6,32(sp)
    1a96:	6be2                	ld	s7,24(sp)
    1a98:	6125                	addi	sp,sp,96
    1a9a:	8082                	ret
    if(total != N * SZ){
    1a9c:	6785                	lui	a5,0x1
    1a9e:	42d78793          	addi	a5,a5,1069 # 142d <copyinstr2+0x9b>
    1aa2:	02fa0063          	beq	s4,a5,1ac2 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1aa6:	85d2                	mv	a1,s4
    1aa8:	00005517          	auipc	a0,0x5
    1aac:	23850513          	addi	a0,a0,568 # 6ce0 <malloc+0xb16>
    1ab0:	00004097          	auipc	ra,0x4
    1ab4:	65c080e7          	jalr	1628(ra) # 610c <printf>
      exit(1);
    1ab8:	4505                	li	a0,1
    1aba:	00004097          	auipc	ra,0x4
    1abe:	2b2080e7          	jalr	690(ra) # 5d6c <exit>
    close(fds[0]);
    1ac2:	fa842503          	lw	a0,-88(s0)
    1ac6:	00004097          	auipc	ra,0x4
    1aca:	2d6080e7          	jalr	726(ra) # 5d9c <close>
    wait(&xstatus,"");
    1ace:	00006597          	auipc	a1,0x6
    1ad2:	e2a58593          	addi	a1,a1,-470 # 78f8 <malloc+0x172e>
    1ad6:	fa440513          	addi	a0,s0,-92
    1ada:	00004097          	auipc	ra,0x4
    1ade:	2a2080e7          	jalr	674(ra) # 5d7c <wait>
    exit(xstatus);
    1ae2:	fa442503          	lw	a0,-92(s0)
    1ae6:	00004097          	auipc	ra,0x4
    1aea:	286080e7          	jalr	646(ra) # 5d6c <exit>
    printf("%s: fork() failed\n", s);
    1aee:	85ca                	mv	a1,s2
    1af0:	00005517          	auipc	a0,0x5
    1af4:	21050513          	addi	a0,a0,528 # 6d00 <malloc+0xb36>
    1af8:	00004097          	auipc	ra,0x4
    1afc:	614080e7          	jalr	1556(ra) # 610c <printf>
    exit(1);
    1b00:	4505                	li	a0,1
    1b02:	00004097          	auipc	ra,0x4
    1b06:	26a080e7          	jalr	618(ra) # 5d6c <exit>

0000000000001b0a <exitwait>:
{
    1b0a:	715d                	addi	sp,sp,-80
    1b0c:	e486                	sd	ra,72(sp)
    1b0e:	e0a2                	sd	s0,64(sp)
    1b10:	fc26                	sd	s1,56(sp)
    1b12:	f84a                	sd	s2,48(sp)
    1b14:	f44e                	sd	s3,40(sp)
    1b16:	f052                	sd	s4,32(sp)
    1b18:	ec56                	sd	s5,24(sp)
    1b1a:	0880                	addi	s0,sp,80
    1b1c:	8aaa                	mv	s5,a0
  for(i = 0; i < 100; i++){
    1b1e:	4901                	li	s2,0
      if(wait(&xstate,"") != pid){
    1b20:	00006997          	auipc	s3,0x6
    1b24:	dd898993          	addi	s3,s3,-552 # 78f8 <malloc+0x172e>
  for(i = 0; i < 100; i++){
    1b28:	06400a13          	li	s4,100
    pid = fork();
    1b2c:	00004097          	auipc	ra,0x4
    1b30:	238080e7          	jalr	568(ra) # 5d64 <fork>
    1b34:	84aa                	mv	s1,a0
    if(pid < 0){
    1b36:	02054c63          	bltz	a0,1b6e <exitwait+0x64>
    if(pid){
    1b3a:	c541                	beqz	a0,1bc2 <exitwait+0xb8>
      if(wait(&xstate,"") != pid){
    1b3c:	85ce                	mv	a1,s3
    1b3e:	fbc40513          	addi	a0,s0,-68
    1b42:	00004097          	auipc	ra,0x4
    1b46:	23a080e7          	jalr	570(ra) # 5d7c <wait>
    1b4a:	04951063          	bne	a0,s1,1b8a <exitwait+0x80>
      if(i != xstate) {
    1b4e:	fbc42783          	lw	a5,-68(s0)
    1b52:	05279a63          	bne	a5,s2,1ba6 <exitwait+0x9c>
  for(i = 0; i < 100; i++){
    1b56:	2905                	addiw	s2,s2,1
    1b58:	fd491ae3          	bne	s2,s4,1b2c <exitwait+0x22>
}
    1b5c:	60a6                	ld	ra,72(sp)
    1b5e:	6406                	ld	s0,64(sp)
    1b60:	74e2                	ld	s1,56(sp)
    1b62:	7942                	ld	s2,48(sp)
    1b64:	79a2                	ld	s3,40(sp)
    1b66:	7a02                	ld	s4,32(sp)
    1b68:	6ae2                	ld	s5,24(sp)
    1b6a:	6161                	addi	sp,sp,80
    1b6c:	8082                	ret
      printf("%s: fork failed\n", s);
    1b6e:	85d6                	mv	a1,s5
    1b70:	00005517          	auipc	a0,0x5
    1b74:	02050513          	addi	a0,a0,32 # 6b90 <malloc+0x9c6>
    1b78:	00004097          	auipc	ra,0x4
    1b7c:	594080e7          	jalr	1428(ra) # 610c <printf>
      exit(1);
    1b80:	4505                	li	a0,1
    1b82:	00004097          	auipc	ra,0x4
    1b86:	1ea080e7          	jalr	490(ra) # 5d6c <exit>
        printf("%s: wait wrong pid\n", s);
    1b8a:	85d6                	mv	a1,s5
    1b8c:	00005517          	auipc	a0,0x5
    1b90:	18c50513          	addi	a0,a0,396 # 6d18 <malloc+0xb4e>
    1b94:	00004097          	auipc	ra,0x4
    1b98:	578080e7          	jalr	1400(ra) # 610c <printf>
        exit(1);
    1b9c:	4505                	li	a0,1
    1b9e:	00004097          	auipc	ra,0x4
    1ba2:	1ce080e7          	jalr	462(ra) # 5d6c <exit>
        printf("%s: wait wrong exit status\n", s);
    1ba6:	85d6                	mv	a1,s5
    1ba8:	00005517          	auipc	a0,0x5
    1bac:	18850513          	addi	a0,a0,392 # 6d30 <malloc+0xb66>
    1bb0:	00004097          	auipc	ra,0x4
    1bb4:	55c080e7          	jalr	1372(ra) # 610c <printf>
        exit(1);
    1bb8:	4505                	li	a0,1
    1bba:	00004097          	auipc	ra,0x4
    1bbe:	1b2080e7          	jalr	434(ra) # 5d6c <exit>
      exit(i);
    1bc2:	854a                	mv	a0,s2
    1bc4:	00004097          	auipc	ra,0x4
    1bc8:	1a8080e7          	jalr	424(ra) # 5d6c <exit>

0000000000001bcc <twochildren>:
{
    1bcc:	7179                	addi	sp,sp,-48
    1bce:	f406                	sd	ra,40(sp)
    1bd0:	f022                	sd	s0,32(sp)
    1bd2:	ec26                	sd	s1,24(sp)
    1bd4:	e84a                	sd	s2,16(sp)
    1bd6:	e44e                	sd	s3,8(sp)
    1bd8:	1800                	addi	s0,sp,48
    1bda:	89aa                	mv	s3,a0
    1bdc:	3e800493          	li	s1,1000
        wait(0,"");
    1be0:	00006917          	auipc	s2,0x6
    1be4:	d1890913          	addi	s2,s2,-744 # 78f8 <malloc+0x172e>
    int pid1 = fork();
    1be8:	00004097          	auipc	ra,0x4
    1bec:	17c080e7          	jalr	380(ra) # 5d64 <fork>
    if(pid1 < 0){
    1bf0:	02054f63          	bltz	a0,1c2e <twochildren+0x62>
    if(pid1 == 0){
    1bf4:	c939                	beqz	a0,1c4a <twochildren+0x7e>
      int pid2 = fork();
    1bf6:	00004097          	auipc	ra,0x4
    1bfa:	16e080e7          	jalr	366(ra) # 5d64 <fork>
      if(pid2 < 0){
    1bfe:	04054a63          	bltz	a0,1c52 <twochildren+0x86>
      if(pid2 == 0){
    1c02:	c535                	beqz	a0,1c6e <twochildren+0xa2>
        wait(0,"");
    1c04:	85ca                	mv	a1,s2
    1c06:	4501                	li	a0,0
    1c08:	00004097          	auipc	ra,0x4
    1c0c:	174080e7          	jalr	372(ra) # 5d7c <wait>
        wait(0,"");
    1c10:	85ca                	mv	a1,s2
    1c12:	4501                	li	a0,0
    1c14:	00004097          	auipc	ra,0x4
    1c18:	168080e7          	jalr	360(ra) # 5d7c <wait>
  for(int i = 0; i < 1000; i++){
    1c1c:	34fd                	addiw	s1,s1,-1
    1c1e:	f4e9                	bnez	s1,1be8 <twochildren+0x1c>
}
    1c20:	70a2                	ld	ra,40(sp)
    1c22:	7402                	ld	s0,32(sp)
    1c24:	64e2                	ld	s1,24(sp)
    1c26:	6942                	ld	s2,16(sp)
    1c28:	69a2                	ld	s3,8(sp)
    1c2a:	6145                	addi	sp,sp,48
    1c2c:	8082                	ret
      printf("%s: fork failed\n", s);
    1c2e:	85ce                	mv	a1,s3
    1c30:	00005517          	auipc	a0,0x5
    1c34:	f6050513          	addi	a0,a0,-160 # 6b90 <malloc+0x9c6>
    1c38:	00004097          	auipc	ra,0x4
    1c3c:	4d4080e7          	jalr	1236(ra) # 610c <printf>
      exit(1);
    1c40:	4505                	li	a0,1
    1c42:	00004097          	auipc	ra,0x4
    1c46:	12a080e7          	jalr	298(ra) # 5d6c <exit>
      exit(0);
    1c4a:	00004097          	auipc	ra,0x4
    1c4e:	122080e7          	jalr	290(ra) # 5d6c <exit>
        printf("%s: fork failed\n", s);
    1c52:	85ce                	mv	a1,s3
    1c54:	00005517          	auipc	a0,0x5
    1c58:	f3c50513          	addi	a0,a0,-196 # 6b90 <malloc+0x9c6>
    1c5c:	00004097          	auipc	ra,0x4
    1c60:	4b0080e7          	jalr	1200(ra) # 610c <printf>
        exit(1);
    1c64:	4505                	li	a0,1
    1c66:	00004097          	auipc	ra,0x4
    1c6a:	106080e7          	jalr	262(ra) # 5d6c <exit>
        exit(0);
    1c6e:	00004097          	auipc	ra,0x4
    1c72:	0fe080e7          	jalr	254(ra) # 5d6c <exit>

0000000000001c76 <forkfork>:
{
    1c76:	7179                	addi	sp,sp,-48
    1c78:	f406                	sd	ra,40(sp)
    1c7a:	f022                	sd	s0,32(sp)
    1c7c:	ec26                	sd	s1,24(sp)
    1c7e:	e84a                	sd	s2,16(sp)
    1c80:	1800                	addi	s0,sp,48
    1c82:	84aa                	mv	s1,a0
    int pid = fork();
    1c84:	00004097          	auipc	ra,0x4
    1c88:	0e0080e7          	jalr	224(ra) # 5d64 <fork>
    if(pid < 0){
    1c8c:	04054a63          	bltz	a0,1ce0 <forkfork+0x6a>
    if(pid == 0){
    1c90:	c535                	beqz	a0,1cfc <forkfork+0x86>
    int pid = fork();
    1c92:	00004097          	auipc	ra,0x4
    1c96:	0d2080e7          	jalr	210(ra) # 5d64 <fork>
    if(pid < 0){
    1c9a:	04054363          	bltz	a0,1ce0 <forkfork+0x6a>
    if(pid == 0){
    1c9e:	cd39                	beqz	a0,1cfc <forkfork+0x86>
    wait(&xstatus,"");
    1ca0:	00006597          	auipc	a1,0x6
    1ca4:	c5858593          	addi	a1,a1,-936 # 78f8 <malloc+0x172e>
    1ca8:	fdc40513          	addi	a0,s0,-36
    1cac:	00004097          	auipc	ra,0x4
    1cb0:	0d0080e7          	jalr	208(ra) # 5d7c <wait>
    if(xstatus != 0) {
    1cb4:	fdc42783          	lw	a5,-36(s0)
    1cb8:	e7c9                	bnez	a5,1d42 <forkfork+0xcc>
    wait(&xstatus,"");
    1cba:	00006597          	auipc	a1,0x6
    1cbe:	c3e58593          	addi	a1,a1,-962 # 78f8 <malloc+0x172e>
    1cc2:	fdc40513          	addi	a0,s0,-36
    1cc6:	00004097          	auipc	ra,0x4
    1cca:	0b6080e7          	jalr	182(ra) # 5d7c <wait>
    if(xstatus != 0) {
    1cce:	fdc42783          	lw	a5,-36(s0)
    1cd2:	eba5                	bnez	a5,1d42 <forkfork+0xcc>
}
    1cd4:	70a2                	ld	ra,40(sp)
    1cd6:	7402                	ld	s0,32(sp)
    1cd8:	64e2                	ld	s1,24(sp)
    1cda:	6942                	ld	s2,16(sp)
    1cdc:	6145                	addi	sp,sp,48
    1cde:	8082                	ret
      printf("%s: fork failed", s);
    1ce0:	85a6                	mv	a1,s1
    1ce2:	00005517          	auipc	a0,0x5
    1ce6:	06e50513          	addi	a0,a0,110 # 6d50 <malloc+0xb86>
    1cea:	00004097          	auipc	ra,0x4
    1cee:	422080e7          	jalr	1058(ra) # 610c <printf>
      exit(1);
    1cf2:	4505                	li	a0,1
    1cf4:	00004097          	auipc	ra,0x4
    1cf8:	078080e7          	jalr	120(ra) # 5d6c <exit>
{
    1cfc:	0c800493          	li	s1,200
        wait(0,"");
    1d00:	00006917          	auipc	s2,0x6
    1d04:	bf890913          	addi	s2,s2,-1032 # 78f8 <malloc+0x172e>
        int pid1 = fork();
    1d08:	00004097          	auipc	ra,0x4
    1d0c:	05c080e7          	jalr	92(ra) # 5d64 <fork>
        if(pid1 < 0){
    1d10:	02054063          	bltz	a0,1d30 <forkfork+0xba>
        if(pid1 == 0){
    1d14:	c11d                	beqz	a0,1d3a <forkfork+0xc4>
        wait(0,"");
    1d16:	85ca                	mv	a1,s2
    1d18:	4501                	li	a0,0
    1d1a:	00004097          	auipc	ra,0x4
    1d1e:	062080e7          	jalr	98(ra) # 5d7c <wait>
      for(int j = 0; j < 200; j++){
    1d22:	34fd                	addiw	s1,s1,-1
    1d24:	f0f5                	bnez	s1,1d08 <forkfork+0x92>
      exit(0);
    1d26:	4501                	li	a0,0
    1d28:	00004097          	auipc	ra,0x4
    1d2c:	044080e7          	jalr	68(ra) # 5d6c <exit>
          exit(1);
    1d30:	4505                	li	a0,1
    1d32:	00004097          	auipc	ra,0x4
    1d36:	03a080e7          	jalr	58(ra) # 5d6c <exit>
          exit(0);
    1d3a:	00004097          	auipc	ra,0x4
    1d3e:	032080e7          	jalr	50(ra) # 5d6c <exit>
      printf("%s: fork in child failed", s);
    1d42:	85a6                	mv	a1,s1
    1d44:	00005517          	auipc	a0,0x5
    1d48:	01c50513          	addi	a0,a0,28 # 6d60 <malloc+0xb96>
    1d4c:	00004097          	auipc	ra,0x4
    1d50:	3c0080e7          	jalr	960(ra) # 610c <printf>
      exit(1);
    1d54:	4505                	li	a0,1
    1d56:	00004097          	auipc	ra,0x4
    1d5a:	016080e7          	jalr	22(ra) # 5d6c <exit>

0000000000001d5e <reparent2>:
{
    1d5e:	1101                	addi	sp,sp,-32
    1d60:	ec06                	sd	ra,24(sp)
    1d62:	e822                	sd	s0,16(sp)
    1d64:	e426                	sd	s1,8(sp)
    1d66:	e04a                	sd	s2,0(sp)
    1d68:	1000                	addi	s0,sp,32
    1d6a:	32000493          	li	s1,800
    wait(0,"");
    1d6e:	00006917          	auipc	s2,0x6
    1d72:	b8a90913          	addi	s2,s2,-1142 # 78f8 <malloc+0x172e>
    int pid1 = fork();
    1d76:	00004097          	auipc	ra,0x4
    1d7a:	fee080e7          	jalr	-18(ra) # 5d64 <fork>
    if(pid1 < 0){
    1d7e:	02054063          	bltz	a0,1d9e <reparent2+0x40>
    if(pid1 == 0){
    1d82:	c91d                	beqz	a0,1db8 <reparent2+0x5a>
    wait(0,"");
    1d84:	85ca                	mv	a1,s2
    1d86:	4501                	li	a0,0
    1d88:	00004097          	auipc	ra,0x4
    1d8c:	ff4080e7          	jalr	-12(ra) # 5d7c <wait>
  for(int i = 0; i < 800; i++){
    1d90:	34fd                	addiw	s1,s1,-1
    1d92:	f0f5                	bnez	s1,1d76 <reparent2+0x18>
  exit(0);
    1d94:	4501                	li	a0,0
    1d96:	00004097          	auipc	ra,0x4
    1d9a:	fd6080e7          	jalr	-42(ra) # 5d6c <exit>
      printf("fork failed\n");
    1d9e:	00005517          	auipc	a0,0x5
    1da2:	1fa50513          	addi	a0,a0,506 # 6f98 <malloc+0xdce>
    1da6:	00004097          	auipc	ra,0x4
    1daa:	366080e7          	jalr	870(ra) # 610c <printf>
      exit(1);
    1dae:	4505                	li	a0,1
    1db0:	00004097          	auipc	ra,0x4
    1db4:	fbc080e7          	jalr	-68(ra) # 5d6c <exit>
      fork();
    1db8:	00004097          	auipc	ra,0x4
    1dbc:	fac080e7          	jalr	-84(ra) # 5d64 <fork>
      fork();
    1dc0:	00004097          	auipc	ra,0x4
    1dc4:	fa4080e7          	jalr	-92(ra) # 5d64 <fork>
      exit(0);
    1dc8:	4501                	li	a0,0
    1dca:	00004097          	auipc	ra,0x4
    1dce:	fa2080e7          	jalr	-94(ra) # 5d6c <exit>

0000000000001dd2 <createdelete>:
{
    1dd2:	7175                	addi	sp,sp,-144
    1dd4:	e506                	sd	ra,136(sp)
    1dd6:	e122                	sd	s0,128(sp)
    1dd8:	fca6                	sd	s1,120(sp)
    1dda:	f8ca                	sd	s2,112(sp)
    1ddc:	f4ce                	sd	s3,104(sp)
    1dde:	f0d2                	sd	s4,96(sp)
    1de0:	ecd6                	sd	s5,88(sp)
    1de2:	e8da                	sd	s6,80(sp)
    1de4:	e4de                	sd	s7,72(sp)
    1de6:	e0e2                	sd	s8,64(sp)
    1de8:	fc66                	sd	s9,56(sp)
    1dea:	0900                	addi	s0,sp,144
    1dec:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1dee:	4901                	li	s2,0
    1df0:	4991                	li	s3,4
    pid = fork();
    1df2:	00004097          	auipc	ra,0x4
    1df6:	f72080e7          	jalr	-142(ra) # 5d64 <fork>
    1dfa:	84aa                	mv	s1,a0
    if(pid < 0){
    1dfc:	04054463          	bltz	a0,1e44 <createdelete+0x72>
    if(pid == 0){
    1e00:	c125                	beqz	a0,1e60 <createdelete+0x8e>
  for(pi = 0; pi < NCHILD; pi++){
    1e02:	2905                	addiw	s2,s2,1
    1e04:	ff3917e3          	bne	s2,s3,1df2 <createdelete+0x20>
    1e08:	4491                	li	s1,4
    wait(&xstatus,"");
    1e0a:	00006997          	auipc	s3,0x6
    1e0e:	aee98993          	addi	s3,s3,-1298 # 78f8 <malloc+0x172e>
    1e12:	85ce                	mv	a1,s3
    1e14:	f7c40513          	addi	a0,s0,-132
    1e18:	00004097          	auipc	ra,0x4
    1e1c:	f64080e7          	jalr	-156(ra) # 5d7c <wait>
    if(xstatus != 0)
    1e20:	f7c42903          	lw	s2,-132(s0)
    1e24:	0e091263          	bnez	s2,1f08 <createdelete+0x136>
  for(pi = 0; pi < NCHILD; pi++){
    1e28:	34fd                	addiw	s1,s1,-1
    1e2a:	f4e5                	bnez	s1,1e12 <createdelete+0x40>
  name[0] = name[1] = name[2] = 0;
    1e2c:	f8040123          	sb	zero,-126(s0)
    1e30:	03000993          	li	s3,48
    1e34:	5a7d                	li	s4,-1
    1e36:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1e3a:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1e3c:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1e3e:	07400a93          	li	s5,116
    1e42:	a29d                	j	1fa8 <createdelete+0x1d6>
      printf("fork failed\n", s);
    1e44:	85e6                	mv	a1,s9
    1e46:	00005517          	auipc	a0,0x5
    1e4a:	15250513          	addi	a0,a0,338 # 6f98 <malloc+0xdce>
    1e4e:	00004097          	auipc	ra,0x4
    1e52:	2be080e7          	jalr	702(ra) # 610c <printf>
      exit(1);
    1e56:	4505                	li	a0,1
    1e58:	00004097          	auipc	ra,0x4
    1e5c:	f14080e7          	jalr	-236(ra) # 5d6c <exit>
      name[0] = 'p' + pi;
    1e60:	0709091b          	addiw	s2,s2,112
    1e64:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1e68:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1e6c:	4951                	li	s2,20
    1e6e:	a015                	j	1e92 <createdelete+0xc0>
          printf("%s: create failed\n", s);
    1e70:	85e6                	mv	a1,s9
    1e72:	00005517          	auipc	a0,0x5
    1e76:	db650513          	addi	a0,a0,-586 # 6c28 <malloc+0xa5e>
    1e7a:	00004097          	auipc	ra,0x4
    1e7e:	292080e7          	jalr	658(ra) # 610c <printf>
          exit(1);
    1e82:	4505                	li	a0,1
    1e84:	00004097          	auipc	ra,0x4
    1e88:	ee8080e7          	jalr	-280(ra) # 5d6c <exit>
      for(i = 0; i < N; i++){
    1e8c:	2485                	addiw	s1,s1,1
    1e8e:	07248863          	beq	s1,s2,1efe <createdelete+0x12c>
        name[1] = '0' + i;
    1e92:	0304879b          	addiw	a5,s1,48
    1e96:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1e9a:	20200593          	li	a1,514
    1e9e:	f8040513          	addi	a0,s0,-128
    1ea2:	00004097          	auipc	ra,0x4
    1ea6:	f12080e7          	jalr	-238(ra) # 5db4 <open>
        if(fd < 0){
    1eaa:	fc0543e3          	bltz	a0,1e70 <createdelete+0x9e>
        close(fd);
    1eae:	00004097          	auipc	ra,0x4
    1eb2:	eee080e7          	jalr	-274(ra) # 5d9c <close>
        if(i > 0 && (i % 2 ) == 0){
    1eb6:	fc905be3          	blez	s1,1e8c <createdelete+0xba>
    1eba:	0014f793          	andi	a5,s1,1
    1ebe:	f7f9                	bnez	a5,1e8c <createdelete+0xba>
          name[1] = '0' + (i / 2);
    1ec0:	01f4d79b          	srliw	a5,s1,0x1f
    1ec4:	9fa5                	addw	a5,a5,s1
    1ec6:	4017d79b          	sraiw	a5,a5,0x1
    1eca:	0307879b          	addiw	a5,a5,48
    1ece:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1ed2:	f8040513          	addi	a0,s0,-128
    1ed6:	00004097          	auipc	ra,0x4
    1eda:	eee080e7          	jalr	-274(ra) # 5dc4 <unlink>
    1ede:	fa0557e3          	bgez	a0,1e8c <createdelete+0xba>
            printf("%s: unlink failed\n", s);
    1ee2:	85e6                	mv	a1,s9
    1ee4:	00005517          	auipc	a0,0x5
    1ee8:	e9c50513          	addi	a0,a0,-356 # 6d80 <malloc+0xbb6>
    1eec:	00004097          	auipc	ra,0x4
    1ef0:	220080e7          	jalr	544(ra) # 610c <printf>
            exit(1);
    1ef4:	4505                	li	a0,1
    1ef6:	00004097          	auipc	ra,0x4
    1efa:	e76080e7          	jalr	-394(ra) # 5d6c <exit>
      exit(0);
    1efe:	4501                	li	a0,0
    1f00:	00004097          	auipc	ra,0x4
    1f04:	e6c080e7          	jalr	-404(ra) # 5d6c <exit>
      exit(1);
    1f08:	4505                	li	a0,1
    1f0a:	00004097          	auipc	ra,0x4
    1f0e:	e62080e7          	jalr	-414(ra) # 5d6c <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1f12:	f8040613          	addi	a2,s0,-128
    1f16:	85e6                	mv	a1,s9
    1f18:	00005517          	auipc	a0,0x5
    1f1c:	e8050513          	addi	a0,a0,-384 # 6d98 <malloc+0xbce>
    1f20:	00004097          	auipc	ra,0x4
    1f24:	1ec080e7          	jalr	492(ra) # 610c <printf>
        exit(1);
    1f28:	4505                	li	a0,1
    1f2a:	00004097          	auipc	ra,0x4
    1f2e:	e42080e7          	jalr	-446(ra) # 5d6c <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1f32:	054b7163          	bgeu	s6,s4,1f74 <createdelete+0x1a2>
      if(fd >= 0)
    1f36:	02055a63          	bgez	a0,1f6a <createdelete+0x198>
    for(pi = 0; pi < NCHILD; pi++){
    1f3a:	2485                	addiw	s1,s1,1
    1f3c:	0ff4f493          	andi	s1,s1,255
    1f40:	05548c63          	beq	s1,s5,1f98 <createdelete+0x1c6>
      name[0] = 'p' + pi;
    1f44:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1f48:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1f4c:	4581                	li	a1,0
    1f4e:	f8040513          	addi	a0,s0,-128
    1f52:	00004097          	auipc	ra,0x4
    1f56:	e62080e7          	jalr	-414(ra) # 5db4 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1f5a:	00090463          	beqz	s2,1f62 <createdelete+0x190>
    1f5e:	fd2bdae3          	bge	s7,s2,1f32 <createdelete+0x160>
    1f62:	fa0548e3          	bltz	a0,1f12 <createdelete+0x140>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1f66:	014b7963          	bgeu	s6,s4,1f78 <createdelete+0x1a6>
        close(fd);
    1f6a:	00004097          	auipc	ra,0x4
    1f6e:	e32080e7          	jalr	-462(ra) # 5d9c <close>
    1f72:	b7e1                	j	1f3a <createdelete+0x168>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1f74:	fc0543e3          	bltz	a0,1f3a <createdelete+0x168>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1f78:	f8040613          	addi	a2,s0,-128
    1f7c:	85e6                	mv	a1,s9
    1f7e:	00005517          	auipc	a0,0x5
    1f82:	e4250513          	addi	a0,a0,-446 # 6dc0 <malloc+0xbf6>
    1f86:	00004097          	auipc	ra,0x4
    1f8a:	186080e7          	jalr	390(ra) # 610c <printf>
        exit(1);
    1f8e:	4505                	li	a0,1
    1f90:	00004097          	auipc	ra,0x4
    1f94:	ddc080e7          	jalr	-548(ra) # 5d6c <exit>
  for(i = 0; i < N; i++){
    1f98:	2905                	addiw	s2,s2,1
    1f9a:	2a05                	addiw	s4,s4,1
    1f9c:	2985                	addiw	s3,s3,1
    1f9e:	0ff9f993          	andi	s3,s3,255
    1fa2:	47d1                	li	a5,20
    1fa4:	02f90a63          	beq	s2,a5,1fd8 <createdelete+0x206>
    for(pi = 0; pi < NCHILD; pi++){
    1fa8:	84e2                	mv	s1,s8
    1faa:	bf69                	j	1f44 <createdelete+0x172>
  for(i = 0; i < N; i++){
    1fac:	2905                	addiw	s2,s2,1
    1fae:	0ff97913          	andi	s2,s2,255
    1fb2:	2985                	addiw	s3,s3,1
    1fb4:	0ff9f993          	andi	s3,s3,255
    1fb8:	03490863          	beq	s2,s4,1fe8 <createdelete+0x216>
  name[0] = name[1] = name[2] = 0;
    1fbc:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1fbe:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1fc2:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1fc6:	f8040513          	addi	a0,s0,-128
    1fca:	00004097          	auipc	ra,0x4
    1fce:	dfa080e7          	jalr	-518(ra) # 5dc4 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1fd2:	34fd                	addiw	s1,s1,-1
    1fd4:	f4ed                	bnez	s1,1fbe <createdelete+0x1ec>
    1fd6:	bfd9                	j	1fac <createdelete+0x1da>
    1fd8:	03000993          	li	s3,48
    1fdc:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1fe0:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1fe2:	08400a13          	li	s4,132
    1fe6:	bfd9                	j	1fbc <createdelete+0x1ea>
}
    1fe8:	60aa                	ld	ra,136(sp)
    1fea:	640a                	ld	s0,128(sp)
    1fec:	74e6                	ld	s1,120(sp)
    1fee:	7946                	ld	s2,112(sp)
    1ff0:	79a6                	ld	s3,104(sp)
    1ff2:	7a06                	ld	s4,96(sp)
    1ff4:	6ae6                	ld	s5,88(sp)
    1ff6:	6b46                	ld	s6,80(sp)
    1ff8:	6ba6                	ld	s7,72(sp)
    1ffa:	6c06                	ld	s8,64(sp)
    1ffc:	7ce2                	ld	s9,56(sp)
    1ffe:	6149                	addi	sp,sp,144
    2000:	8082                	ret

0000000000002002 <linkunlink>:
{
    2002:	711d                	addi	sp,sp,-96
    2004:	ec86                	sd	ra,88(sp)
    2006:	e8a2                	sd	s0,80(sp)
    2008:	e4a6                	sd	s1,72(sp)
    200a:	e0ca                	sd	s2,64(sp)
    200c:	fc4e                	sd	s3,56(sp)
    200e:	f852                	sd	s4,48(sp)
    2010:	f456                	sd	s5,40(sp)
    2012:	f05a                	sd	s6,32(sp)
    2014:	ec5e                	sd	s7,24(sp)
    2016:	e862                	sd	s8,16(sp)
    2018:	e466                	sd	s9,8(sp)
    201a:	1080                	addi	s0,sp,96
    201c:	84aa                	mv	s1,a0
  unlink("x");
    201e:	00004517          	auipc	a0,0x4
    2022:	35a50513          	addi	a0,a0,858 # 6378 <malloc+0x1ae>
    2026:	00004097          	auipc	ra,0x4
    202a:	d9e080e7          	jalr	-610(ra) # 5dc4 <unlink>
  pid = fork();
    202e:	00004097          	auipc	ra,0x4
    2032:	d36080e7          	jalr	-714(ra) # 5d64 <fork>
  if(pid < 0){
    2036:	02054b63          	bltz	a0,206c <linkunlink+0x6a>
    203a:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    203c:	4c85                	li	s9,1
    203e:	e119                	bnez	a0,2044 <linkunlink+0x42>
    2040:	06100c93          	li	s9,97
    2044:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    2048:	41c659b7          	lui	s3,0x41c65
    204c:	e6d9899b          	addiw	s3,s3,-403
    2050:	690d                	lui	s2,0x3
    2052:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    2056:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    2058:	4b05                	li	s6,1
      unlink("x");
    205a:	00004a97          	auipc	s5,0x4
    205e:	31ea8a93          	addi	s5,s5,798 # 6378 <malloc+0x1ae>
      link("cat", "x");
    2062:	00005b97          	auipc	s7,0x5
    2066:	d86b8b93          	addi	s7,s7,-634 # 6de8 <malloc+0xc1e>
    206a:	a091                	j	20ae <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    206c:	85a6                	mv	a1,s1
    206e:	00005517          	auipc	a0,0x5
    2072:	b2250513          	addi	a0,a0,-1246 # 6b90 <malloc+0x9c6>
    2076:	00004097          	auipc	ra,0x4
    207a:	096080e7          	jalr	150(ra) # 610c <printf>
    exit(1);
    207e:	4505                	li	a0,1
    2080:	00004097          	auipc	ra,0x4
    2084:	cec080e7          	jalr	-788(ra) # 5d6c <exit>
      close(open("x", O_RDWR | O_CREATE));
    2088:	20200593          	li	a1,514
    208c:	8556                	mv	a0,s5
    208e:	00004097          	auipc	ra,0x4
    2092:	d26080e7          	jalr	-730(ra) # 5db4 <open>
    2096:	00004097          	auipc	ra,0x4
    209a:	d06080e7          	jalr	-762(ra) # 5d9c <close>
    209e:	a031                	j	20aa <linkunlink+0xa8>
      unlink("x");
    20a0:	8556                	mv	a0,s5
    20a2:	00004097          	auipc	ra,0x4
    20a6:	d22080e7          	jalr	-734(ra) # 5dc4 <unlink>
  for(i = 0; i < 100; i++){
    20aa:	34fd                	addiw	s1,s1,-1
    20ac:	c09d                	beqz	s1,20d2 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    20ae:	033c87bb          	mulw	a5,s9,s3
    20b2:	012787bb          	addw	a5,a5,s2
    20b6:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    20ba:	0347f7bb          	remuw	a5,a5,s4
    20be:	d7e9                	beqz	a5,2088 <linkunlink+0x86>
    } else if((x % 3) == 1){
    20c0:	ff6790e3          	bne	a5,s6,20a0 <linkunlink+0x9e>
      link("cat", "x");
    20c4:	85d6                	mv	a1,s5
    20c6:	855e                	mv	a0,s7
    20c8:	00004097          	auipc	ra,0x4
    20cc:	d0c080e7          	jalr	-756(ra) # 5dd4 <link>
    20d0:	bfe9                	j	20aa <linkunlink+0xa8>
  if(pid)
    20d2:	020c0863          	beqz	s8,2102 <linkunlink+0x100>
    wait(0,"");
    20d6:	00006597          	auipc	a1,0x6
    20da:	82258593          	addi	a1,a1,-2014 # 78f8 <malloc+0x172e>
    20de:	4501                	li	a0,0
    20e0:	00004097          	auipc	ra,0x4
    20e4:	c9c080e7          	jalr	-868(ra) # 5d7c <wait>
}
    20e8:	60e6                	ld	ra,88(sp)
    20ea:	6446                	ld	s0,80(sp)
    20ec:	64a6                	ld	s1,72(sp)
    20ee:	6906                	ld	s2,64(sp)
    20f0:	79e2                	ld	s3,56(sp)
    20f2:	7a42                	ld	s4,48(sp)
    20f4:	7aa2                	ld	s5,40(sp)
    20f6:	7b02                	ld	s6,32(sp)
    20f8:	6be2                	ld	s7,24(sp)
    20fa:	6c42                	ld	s8,16(sp)
    20fc:	6ca2                	ld	s9,8(sp)
    20fe:	6125                	addi	sp,sp,96
    2100:	8082                	ret
    exit(0);
    2102:	4501                	li	a0,0
    2104:	00004097          	auipc	ra,0x4
    2108:	c68080e7          	jalr	-920(ra) # 5d6c <exit>

000000000000210c <forktest>:
{
    210c:	7179                	addi	sp,sp,-48
    210e:	f406                	sd	ra,40(sp)
    2110:	f022                	sd	s0,32(sp)
    2112:	ec26                	sd	s1,24(sp)
    2114:	e84a                	sd	s2,16(sp)
    2116:	e44e                	sd	s3,8(sp)
    2118:	1800                	addi	s0,sp,48
    211a:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    211c:	4481                	li	s1,0
    211e:	3e800913          	li	s2,1000
    pid = fork();
    2122:	00004097          	auipc	ra,0x4
    2126:	c42080e7          	jalr	-958(ra) # 5d64 <fork>
    if(pid < 0)
    212a:	02054863          	bltz	a0,215a <forktest+0x4e>
    if(pid == 0)
    212e:	c115                	beqz	a0,2152 <forktest+0x46>
  for(n=0; n<N; n++){
    2130:	2485                	addiw	s1,s1,1
    2132:	ff2498e3          	bne	s1,s2,2122 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    2136:	85ce                	mv	a1,s3
    2138:	00005517          	auipc	a0,0x5
    213c:	cd050513          	addi	a0,a0,-816 # 6e08 <malloc+0xc3e>
    2140:	00004097          	auipc	ra,0x4
    2144:	fcc080e7          	jalr	-52(ra) # 610c <printf>
    exit(1);
    2148:	4505                	li	a0,1
    214a:	00004097          	auipc	ra,0x4
    214e:	c22080e7          	jalr	-990(ra) # 5d6c <exit>
      exit(0);
    2152:	00004097          	auipc	ra,0x4
    2156:	c1a080e7          	jalr	-998(ra) # 5d6c <exit>
  if (n == 0) {
    215a:	c8a1                	beqz	s1,21aa <forktest+0x9e>
  if(n == N){
    215c:	3e800793          	li	a5,1000
    2160:	fcf48be3          	beq	s1,a5,2136 <forktest+0x2a>
    if(wait(0,"") < 0){
    2164:	00005917          	auipc	s2,0x5
    2168:	79490913          	addi	s2,s2,1940 # 78f8 <malloc+0x172e>
  for(; n > 0; n--){
    216c:	00905c63          	blez	s1,2184 <forktest+0x78>
    if(wait(0,"") < 0){
    2170:	85ca                	mv	a1,s2
    2172:	4501                	li	a0,0
    2174:	00004097          	auipc	ra,0x4
    2178:	c08080e7          	jalr	-1016(ra) # 5d7c <wait>
    217c:	04054563          	bltz	a0,21c6 <forktest+0xba>
  for(; n > 0; n--){
    2180:	34fd                	addiw	s1,s1,-1
    2182:	f4fd                	bnez	s1,2170 <forktest+0x64>
  if(wait(0,"") != -1){
    2184:	00005597          	auipc	a1,0x5
    2188:	77458593          	addi	a1,a1,1908 # 78f8 <malloc+0x172e>
    218c:	4501                	li	a0,0
    218e:	00004097          	auipc	ra,0x4
    2192:	bee080e7          	jalr	-1042(ra) # 5d7c <wait>
    2196:	57fd                	li	a5,-1
    2198:	04f51563          	bne	a0,a5,21e2 <forktest+0xd6>
}
    219c:	70a2                	ld	ra,40(sp)
    219e:	7402                	ld	s0,32(sp)
    21a0:	64e2                	ld	s1,24(sp)
    21a2:	6942                	ld	s2,16(sp)
    21a4:	69a2                	ld	s3,8(sp)
    21a6:	6145                	addi	sp,sp,48
    21a8:	8082                	ret
    printf("%s: no fork at all!\n", s);
    21aa:	85ce                	mv	a1,s3
    21ac:	00005517          	auipc	a0,0x5
    21b0:	c4450513          	addi	a0,a0,-956 # 6df0 <malloc+0xc26>
    21b4:	00004097          	auipc	ra,0x4
    21b8:	f58080e7          	jalr	-168(ra) # 610c <printf>
    exit(1);
    21bc:	4505                	li	a0,1
    21be:	00004097          	auipc	ra,0x4
    21c2:	bae080e7          	jalr	-1106(ra) # 5d6c <exit>
      printf("%s: wait stopped early\n", s);
    21c6:	85ce                	mv	a1,s3
    21c8:	00005517          	auipc	a0,0x5
    21cc:	c6850513          	addi	a0,a0,-920 # 6e30 <malloc+0xc66>
    21d0:	00004097          	auipc	ra,0x4
    21d4:	f3c080e7          	jalr	-196(ra) # 610c <printf>
      exit(1);
    21d8:	4505                	li	a0,1
    21da:	00004097          	auipc	ra,0x4
    21de:	b92080e7          	jalr	-1134(ra) # 5d6c <exit>
    printf("%s: wait got too many\n", s);
    21e2:	85ce                	mv	a1,s3
    21e4:	00005517          	auipc	a0,0x5
    21e8:	c6450513          	addi	a0,a0,-924 # 6e48 <malloc+0xc7e>
    21ec:	00004097          	auipc	ra,0x4
    21f0:	f20080e7          	jalr	-224(ra) # 610c <printf>
    exit(1);
    21f4:	4505                	li	a0,1
    21f6:	00004097          	auipc	ra,0x4
    21fa:	b76080e7          	jalr	-1162(ra) # 5d6c <exit>

00000000000021fe <kernmem>:
{
    21fe:	715d                	addi	sp,sp,-80
    2200:	e486                	sd	ra,72(sp)
    2202:	e0a2                	sd	s0,64(sp)
    2204:	fc26                	sd	s1,56(sp)
    2206:	f84a                	sd	s2,48(sp)
    2208:	f44e                	sd	s3,40(sp)
    220a:	f052                	sd	s4,32(sp)
    220c:	ec56                	sd	s5,24(sp)
    220e:	e85a                	sd	s6,16(sp)
    2210:	0880                	addi	s0,sp,80
    2212:	8b2a                	mv	s6,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2214:	4485                	li	s1,1
    2216:	04fe                	slli	s1,s1,0x1f
    wait(&xstatus,"");
    2218:	00005a97          	auipc	s5,0x5
    221c:	6e0a8a93          	addi	s5,s5,1760 # 78f8 <malloc+0x172e>
    if(xstatus != -1)  // did kernel kill child?
    2220:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2222:	69b1                	lui	s3,0xc
    2224:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1de8>
    2228:	1003d937          	lui	s2,0x1003d
    222c:	090e                	slli	s2,s2,0x3
    222e:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d808>
    pid = fork();
    2232:	00004097          	auipc	ra,0x4
    2236:	b32080e7          	jalr	-1230(ra) # 5d64 <fork>
    if(pid < 0){
    223a:	02054b63          	bltz	a0,2270 <kernmem+0x72>
    if(pid == 0){
    223e:	c539                	beqz	a0,228c <kernmem+0x8e>
    wait(&xstatus,"");
    2240:	85d6                	mv	a1,s5
    2242:	fbc40513          	addi	a0,s0,-68
    2246:	00004097          	auipc	ra,0x4
    224a:	b36080e7          	jalr	-1226(ra) # 5d7c <wait>
    if(xstatus != -1)  // did kernel kill child?
    224e:	fbc42783          	lw	a5,-68(s0)
    2252:	05479e63          	bne	a5,s4,22ae <kernmem+0xb0>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2256:	94ce                	add	s1,s1,s3
    2258:	fd249de3          	bne	s1,s2,2232 <kernmem+0x34>
}
    225c:	60a6                	ld	ra,72(sp)
    225e:	6406                	ld	s0,64(sp)
    2260:	74e2                	ld	s1,56(sp)
    2262:	7942                	ld	s2,48(sp)
    2264:	79a2                	ld	s3,40(sp)
    2266:	7a02                	ld	s4,32(sp)
    2268:	6ae2                	ld	s5,24(sp)
    226a:	6b42                	ld	s6,16(sp)
    226c:	6161                	addi	sp,sp,80
    226e:	8082                	ret
      printf("%s: fork failed\n", s);
    2270:	85da                	mv	a1,s6
    2272:	00005517          	auipc	a0,0x5
    2276:	91e50513          	addi	a0,a0,-1762 # 6b90 <malloc+0x9c6>
    227a:	00004097          	auipc	ra,0x4
    227e:	e92080e7          	jalr	-366(ra) # 610c <printf>
      exit(1);
    2282:	4505                	li	a0,1
    2284:	00004097          	auipc	ra,0x4
    2288:	ae8080e7          	jalr	-1304(ra) # 5d6c <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    228c:	0004c683          	lbu	a3,0(s1)
    2290:	8626                	mv	a2,s1
    2292:	85da                	mv	a1,s6
    2294:	00005517          	auipc	a0,0x5
    2298:	bcc50513          	addi	a0,a0,-1076 # 6e60 <malloc+0xc96>
    229c:	00004097          	auipc	ra,0x4
    22a0:	e70080e7          	jalr	-400(ra) # 610c <printf>
      exit(1);
    22a4:	4505                	li	a0,1
    22a6:	00004097          	auipc	ra,0x4
    22aa:	ac6080e7          	jalr	-1338(ra) # 5d6c <exit>
      exit(1);
    22ae:	4505                	li	a0,1
    22b0:	00004097          	auipc	ra,0x4
    22b4:	abc080e7          	jalr	-1348(ra) # 5d6c <exit>

00000000000022b8 <MAXVAplus>:
{
    22b8:	7139                	addi	sp,sp,-64
    22ba:	fc06                	sd	ra,56(sp)
    22bc:	f822                	sd	s0,48(sp)
    22be:	f426                	sd	s1,40(sp)
    22c0:	f04a                	sd	s2,32(sp)
    22c2:	ec4e                	sd	s3,24(sp)
    22c4:	0080                	addi	s0,sp,64
  volatile uint64 a = MAXVA;
    22c6:	4785                	li	a5,1
    22c8:	179a                	slli	a5,a5,0x26
    22ca:	fcf43423          	sd	a5,-56(s0)
  for( ; a != 0; a <<= 1){
    22ce:	fc843783          	ld	a5,-56(s0)
    22d2:	c3a9                	beqz	a5,2314 <MAXVAplus+0x5c>
    22d4:	89aa                	mv	s3,a0
    wait(&xstatus,"");
    22d6:	00005917          	auipc	s2,0x5
    22da:	62290913          	addi	s2,s2,1570 # 78f8 <malloc+0x172e>
    if(xstatus != -1)  // did kernel kill child?
    22de:	54fd                	li	s1,-1
    pid = fork();
    22e0:	00004097          	auipc	ra,0x4
    22e4:	a84080e7          	jalr	-1404(ra) # 5d64 <fork>
    if(pid < 0){
    22e8:	02054d63          	bltz	a0,2322 <MAXVAplus+0x6a>
    if(pid == 0){
    22ec:	c929                	beqz	a0,233e <MAXVAplus+0x86>
    wait(&xstatus,"");
    22ee:	85ca                	mv	a1,s2
    22f0:	fc440513          	addi	a0,s0,-60
    22f4:	00004097          	auipc	ra,0x4
    22f8:	a88080e7          	jalr	-1400(ra) # 5d7c <wait>
    if(xstatus != -1)  // did kernel kill child?
    22fc:	fc442783          	lw	a5,-60(s0)
    2300:	06979563          	bne	a5,s1,236a <MAXVAplus+0xb2>
  for( ; a != 0; a <<= 1){
    2304:	fc843783          	ld	a5,-56(s0)
    2308:	0786                	slli	a5,a5,0x1
    230a:	fcf43423          	sd	a5,-56(s0)
    230e:	fc843783          	ld	a5,-56(s0)
    2312:	f7f9                	bnez	a5,22e0 <MAXVAplus+0x28>
}
    2314:	70e2                	ld	ra,56(sp)
    2316:	7442                	ld	s0,48(sp)
    2318:	74a2                	ld	s1,40(sp)
    231a:	7902                	ld	s2,32(sp)
    231c:	69e2                	ld	s3,24(sp)
    231e:	6121                	addi	sp,sp,64
    2320:	8082                	ret
      printf("%s: fork failed\n", s);
    2322:	85ce                	mv	a1,s3
    2324:	00005517          	auipc	a0,0x5
    2328:	86c50513          	addi	a0,a0,-1940 # 6b90 <malloc+0x9c6>
    232c:	00004097          	auipc	ra,0x4
    2330:	de0080e7          	jalr	-544(ra) # 610c <printf>
      exit(1);
    2334:	4505                	li	a0,1
    2336:	00004097          	auipc	ra,0x4
    233a:	a36080e7          	jalr	-1482(ra) # 5d6c <exit>
      *(char*)a = 99;
    233e:	fc843783          	ld	a5,-56(s0)
    2342:	06300713          	li	a4,99
    2346:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    234a:	fc843603          	ld	a2,-56(s0)
    234e:	85ce                	mv	a1,s3
    2350:	00005517          	auipc	a0,0x5
    2354:	b3050513          	addi	a0,a0,-1232 # 6e80 <malloc+0xcb6>
    2358:	00004097          	auipc	ra,0x4
    235c:	db4080e7          	jalr	-588(ra) # 610c <printf>
      exit(1);
    2360:	4505                	li	a0,1
    2362:	00004097          	auipc	ra,0x4
    2366:	a0a080e7          	jalr	-1526(ra) # 5d6c <exit>
      exit(1);
    236a:	4505                	li	a0,1
    236c:	00004097          	auipc	ra,0x4
    2370:	a00080e7          	jalr	-1536(ra) # 5d6c <exit>

0000000000002374 <bigargtest>:
{
    2374:	7179                	addi	sp,sp,-48
    2376:	f406                	sd	ra,40(sp)
    2378:	f022                	sd	s0,32(sp)
    237a:	ec26                	sd	s1,24(sp)
    237c:	1800                	addi	s0,sp,48
    237e:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2380:	00005517          	auipc	a0,0x5
    2384:	b1850513          	addi	a0,a0,-1256 # 6e98 <malloc+0xcce>
    2388:	00004097          	auipc	ra,0x4
    238c:	a3c080e7          	jalr	-1476(ra) # 5dc4 <unlink>
  pid = fork();
    2390:	00004097          	auipc	ra,0x4
    2394:	9d4080e7          	jalr	-1580(ra) # 5d64 <fork>
  if(pid == 0){
    2398:	c521                	beqz	a0,23e0 <bigargtest+0x6c>
  } else if(pid < 0){
    239a:	0a054463          	bltz	a0,2442 <bigargtest+0xce>
  wait(&xstatus,"");
    239e:	00005597          	auipc	a1,0x5
    23a2:	55a58593          	addi	a1,a1,1370 # 78f8 <malloc+0x172e>
    23a6:	fdc40513          	addi	a0,s0,-36
    23aa:	00004097          	auipc	ra,0x4
    23ae:	9d2080e7          	jalr	-1582(ra) # 5d7c <wait>
  if(xstatus != 0)
    23b2:	fdc42503          	lw	a0,-36(s0)
    23b6:	e545                	bnez	a0,245e <bigargtest+0xea>
  fd = open("bigarg-ok", 0);
    23b8:	4581                	li	a1,0
    23ba:	00005517          	auipc	a0,0x5
    23be:	ade50513          	addi	a0,a0,-1314 # 6e98 <malloc+0xcce>
    23c2:	00004097          	auipc	ra,0x4
    23c6:	9f2080e7          	jalr	-1550(ra) # 5db4 <open>
  if(fd < 0){
    23ca:	08054e63          	bltz	a0,2466 <bigargtest+0xf2>
  close(fd);
    23ce:	00004097          	auipc	ra,0x4
    23d2:	9ce080e7          	jalr	-1586(ra) # 5d9c <close>
}
    23d6:	70a2                	ld	ra,40(sp)
    23d8:	7402                	ld	s0,32(sp)
    23da:	64e2                	ld	s1,24(sp)
    23dc:	6145                	addi	sp,sp,48
    23de:	8082                	ret
    23e0:	00007797          	auipc	a5,0x7
    23e4:	08078793          	addi	a5,a5,128 # 9460 <args.1835>
    23e8:	00007697          	auipc	a3,0x7
    23ec:	17068693          	addi	a3,a3,368 # 9558 <args.1835+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    23f0:	00005717          	auipc	a4,0x5
    23f4:	ab870713          	addi	a4,a4,-1352 # 6ea8 <malloc+0xcde>
    23f8:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    23fa:	07a1                	addi	a5,a5,8
    23fc:	fed79ee3          	bne	a5,a3,23f8 <bigargtest+0x84>
    args[MAXARG-1] = 0;
    2400:	00007597          	auipc	a1,0x7
    2404:	06058593          	addi	a1,a1,96 # 9460 <args.1835>
    2408:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    240c:	00004517          	auipc	a0,0x4
    2410:	efc50513          	addi	a0,a0,-260 # 6308 <malloc+0x13e>
    2414:	00004097          	auipc	ra,0x4
    2418:	998080e7          	jalr	-1640(ra) # 5dac <exec>
    fd = open("bigarg-ok", O_CREATE);
    241c:	20000593          	li	a1,512
    2420:	00005517          	auipc	a0,0x5
    2424:	a7850513          	addi	a0,a0,-1416 # 6e98 <malloc+0xcce>
    2428:	00004097          	auipc	ra,0x4
    242c:	98c080e7          	jalr	-1652(ra) # 5db4 <open>
    close(fd);
    2430:	00004097          	auipc	ra,0x4
    2434:	96c080e7          	jalr	-1684(ra) # 5d9c <close>
    exit(0);
    2438:	4501                	li	a0,0
    243a:	00004097          	auipc	ra,0x4
    243e:	932080e7          	jalr	-1742(ra) # 5d6c <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2442:	85a6                	mv	a1,s1
    2444:	00005517          	auipc	a0,0x5
    2448:	b4450513          	addi	a0,a0,-1212 # 6f88 <malloc+0xdbe>
    244c:	00004097          	auipc	ra,0x4
    2450:	cc0080e7          	jalr	-832(ra) # 610c <printf>
    exit(1);
    2454:	4505                	li	a0,1
    2456:	00004097          	auipc	ra,0x4
    245a:	916080e7          	jalr	-1770(ra) # 5d6c <exit>
    exit(xstatus);
    245e:	00004097          	auipc	ra,0x4
    2462:	90e080e7          	jalr	-1778(ra) # 5d6c <exit>
    printf("%s: bigarg test failed!\n", s);
    2466:	85a6                	mv	a1,s1
    2468:	00005517          	auipc	a0,0x5
    246c:	b4050513          	addi	a0,a0,-1216 # 6fa8 <malloc+0xdde>
    2470:	00004097          	auipc	ra,0x4
    2474:	c9c080e7          	jalr	-868(ra) # 610c <printf>
    exit(1);
    2478:	4505                	li	a0,1
    247a:	00004097          	auipc	ra,0x4
    247e:	8f2080e7          	jalr	-1806(ra) # 5d6c <exit>

0000000000002482 <stacktest>:
{
    2482:	7179                	addi	sp,sp,-48
    2484:	f406                	sd	ra,40(sp)
    2486:	f022                	sd	s0,32(sp)
    2488:	ec26                	sd	s1,24(sp)
    248a:	1800                	addi	s0,sp,48
    248c:	84aa                	mv	s1,a0
  pid = fork();
    248e:	00004097          	auipc	ra,0x4
    2492:	8d6080e7          	jalr	-1834(ra) # 5d64 <fork>
  if(pid == 0) {
    2496:	c515                	beqz	a0,24c2 <stacktest+0x40>
  } else if(pid < 0){
    2498:	04054863          	bltz	a0,24e8 <stacktest+0x66>
  wait(&xstatus,"");
    249c:	00005597          	auipc	a1,0x5
    24a0:	45c58593          	addi	a1,a1,1116 # 78f8 <malloc+0x172e>
    24a4:	fdc40513          	addi	a0,s0,-36
    24a8:	00004097          	auipc	ra,0x4
    24ac:	8d4080e7          	jalr	-1836(ra) # 5d7c <wait>
  if(xstatus == -1)  // kernel killed child?
    24b0:	fdc42503          	lw	a0,-36(s0)
    24b4:	57fd                	li	a5,-1
    24b6:	04f50763          	beq	a0,a5,2504 <stacktest+0x82>
    exit(xstatus);
    24ba:	00004097          	auipc	ra,0x4
    24be:	8b2080e7          	jalr	-1870(ra) # 5d6c <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    24c2:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    24c4:	77fd                	lui	a5,0xfffff
    24c6:	97ba                	add	a5,a5,a4
    24c8:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef388>
    24cc:	85a6                	mv	a1,s1
    24ce:	00005517          	auipc	a0,0x5
    24d2:	afa50513          	addi	a0,a0,-1286 # 6fc8 <malloc+0xdfe>
    24d6:	00004097          	auipc	ra,0x4
    24da:	c36080e7          	jalr	-970(ra) # 610c <printf>
    exit(1);
    24de:	4505                	li	a0,1
    24e0:	00004097          	auipc	ra,0x4
    24e4:	88c080e7          	jalr	-1908(ra) # 5d6c <exit>
    printf("%s: fork failed\n", s);
    24e8:	85a6                	mv	a1,s1
    24ea:	00004517          	auipc	a0,0x4
    24ee:	6a650513          	addi	a0,a0,1702 # 6b90 <malloc+0x9c6>
    24f2:	00004097          	auipc	ra,0x4
    24f6:	c1a080e7          	jalr	-998(ra) # 610c <printf>
    exit(1);
    24fa:	4505                	li	a0,1
    24fc:	00004097          	auipc	ra,0x4
    2500:	870080e7          	jalr	-1936(ra) # 5d6c <exit>
    exit(0);
    2504:	4501                	li	a0,0
    2506:	00004097          	auipc	ra,0x4
    250a:	866080e7          	jalr	-1946(ra) # 5d6c <exit>

000000000000250e <textwrite>:
{
    250e:	7179                	addi	sp,sp,-48
    2510:	f406                	sd	ra,40(sp)
    2512:	f022                	sd	s0,32(sp)
    2514:	ec26                	sd	s1,24(sp)
    2516:	1800                	addi	s0,sp,48
    2518:	84aa                	mv	s1,a0
  pid = fork();
    251a:	00004097          	auipc	ra,0x4
    251e:	84a080e7          	jalr	-1974(ra) # 5d64 <fork>
  if(pid == 0) {
    2522:	c515                	beqz	a0,254e <textwrite+0x40>
  } else if(pid < 0){
    2524:	02054d63          	bltz	a0,255e <textwrite+0x50>
  wait(&xstatus,"");
    2528:	00005597          	auipc	a1,0x5
    252c:	3d058593          	addi	a1,a1,976 # 78f8 <malloc+0x172e>
    2530:	fdc40513          	addi	a0,s0,-36
    2534:	00004097          	auipc	ra,0x4
    2538:	848080e7          	jalr	-1976(ra) # 5d7c <wait>
  if(xstatus == -1)  // kernel killed child?
    253c:	fdc42503          	lw	a0,-36(s0)
    2540:	57fd                	li	a5,-1
    2542:	02f50c63          	beq	a0,a5,257a <textwrite+0x6c>
    exit(xstatus);
    2546:	00004097          	auipc	ra,0x4
    254a:	826080e7          	jalr	-2010(ra) # 5d6c <exit>
    *addr = 10;
    254e:	47a9                	li	a5,10
    2550:	00f02023          	sw	a5,0(zero) # 0 <copyinstr1>
    exit(1);
    2554:	4505                	li	a0,1
    2556:	00004097          	auipc	ra,0x4
    255a:	816080e7          	jalr	-2026(ra) # 5d6c <exit>
    printf("%s: fork failed\n", s);
    255e:	85a6                	mv	a1,s1
    2560:	00004517          	auipc	a0,0x4
    2564:	63050513          	addi	a0,a0,1584 # 6b90 <malloc+0x9c6>
    2568:	00004097          	auipc	ra,0x4
    256c:	ba4080e7          	jalr	-1116(ra) # 610c <printf>
    exit(1);
    2570:	4505                	li	a0,1
    2572:	00003097          	auipc	ra,0x3
    2576:	7fa080e7          	jalr	2042(ra) # 5d6c <exit>
    exit(0);
    257a:	4501                	li	a0,0
    257c:	00003097          	auipc	ra,0x3
    2580:	7f0080e7          	jalr	2032(ra) # 5d6c <exit>

0000000000002584 <manywrites>:
{
    2584:	711d                	addi	sp,sp,-96
    2586:	ec86                	sd	ra,88(sp)
    2588:	e8a2                	sd	s0,80(sp)
    258a:	e4a6                	sd	s1,72(sp)
    258c:	e0ca                	sd	s2,64(sp)
    258e:	fc4e                	sd	s3,56(sp)
    2590:	f852                	sd	s4,48(sp)
    2592:	f456                	sd	s5,40(sp)
    2594:	f05a                	sd	s6,32(sp)
    2596:	ec5e                	sd	s7,24(sp)
    2598:	1080                	addi	s0,sp,96
    259a:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    259c:	4901                	li	s2,0
    259e:	4991                	li	s3,4
    int pid = fork();
    25a0:	00003097          	auipc	ra,0x3
    25a4:	7c4080e7          	jalr	1988(ra) # 5d64 <fork>
    25a8:	84aa                	mv	s1,a0
    if(pid < 0){
    25aa:	02054e63          	bltz	a0,25e6 <manywrites+0x62>
    if(pid == 0){
    25ae:	c929                	beqz	a0,2600 <manywrites+0x7c>
  for(int ci = 0; ci < nchildren; ci++){
    25b0:	2905                	addiw	s2,s2,1
    25b2:	ff3917e3          	bne	s2,s3,25a0 <manywrites+0x1c>
    25b6:	4491                	li	s1,4
    wait(&st,"");
    25b8:	00005917          	auipc	s2,0x5
    25bc:	34090913          	addi	s2,s2,832 # 78f8 <malloc+0x172e>
    int st = 0;
    25c0:	fa042423          	sw	zero,-88(s0)
    wait(&st,"");
    25c4:	85ca                	mv	a1,s2
    25c6:	fa840513          	addi	a0,s0,-88
    25ca:	00003097          	auipc	ra,0x3
    25ce:	7b2080e7          	jalr	1970(ra) # 5d7c <wait>
    if(st != 0)
    25d2:	fa842503          	lw	a0,-88(s0)
    25d6:	ed6d                	bnez	a0,26d0 <manywrites+0x14c>
  for(int ci = 0; ci < nchildren; ci++){
    25d8:	34fd                	addiw	s1,s1,-1
    25da:	f0fd                	bnez	s1,25c0 <manywrites+0x3c>
  exit(0);
    25dc:	4501                	li	a0,0
    25de:	00003097          	auipc	ra,0x3
    25e2:	78e080e7          	jalr	1934(ra) # 5d6c <exit>
      printf("fork failed\n");
    25e6:	00005517          	auipc	a0,0x5
    25ea:	9b250513          	addi	a0,a0,-1614 # 6f98 <malloc+0xdce>
    25ee:	00004097          	auipc	ra,0x4
    25f2:	b1e080e7          	jalr	-1250(ra) # 610c <printf>
      exit(1);
    25f6:	4505                	li	a0,1
    25f8:	00003097          	auipc	ra,0x3
    25fc:	774080e7          	jalr	1908(ra) # 5d6c <exit>
      name[0] = 'b';
    2600:	06200793          	li	a5,98
    2604:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    2608:	0619079b          	addiw	a5,s2,97
    260c:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    2610:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    2614:	fa840513          	addi	a0,s0,-88
    2618:	00003097          	auipc	ra,0x3
    261c:	7ac080e7          	jalr	1964(ra) # 5dc4 <unlink>
    2620:	4b79                	li	s6,30
          int cc = write(fd, buf, sz);
    2622:	0000ab97          	auipc	s7,0xa
    2626:	656b8b93          	addi	s7,s7,1622 # cc78 <buf>
        for(int i = 0; i < ci+1; i++){
    262a:	8a26                	mv	s4,s1
    262c:	02094e63          	bltz	s2,2668 <manywrites+0xe4>
          int fd = open(name, O_CREATE | O_RDWR);
    2630:	20200593          	li	a1,514
    2634:	fa840513          	addi	a0,s0,-88
    2638:	00003097          	auipc	ra,0x3
    263c:	77c080e7          	jalr	1916(ra) # 5db4 <open>
    2640:	89aa                	mv	s3,a0
          if(fd < 0){
    2642:	04054763          	bltz	a0,2690 <manywrites+0x10c>
          int cc = write(fd, buf, sz);
    2646:	660d                	lui	a2,0x3
    2648:	85de                	mv	a1,s7
    264a:	00003097          	auipc	ra,0x3
    264e:	74a080e7          	jalr	1866(ra) # 5d94 <write>
          if(cc != sz){
    2652:	678d                	lui	a5,0x3
    2654:	04f51e63          	bne	a0,a5,26b0 <manywrites+0x12c>
          close(fd);
    2658:	854e                	mv	a0,s3
    265a:	00003097          	auipc	ra,0x3
    265e:	742080e7          	jalr	1858(ra) # 5d9c <close>
        for(int i = 0; i < ci+1; i++){
    2662:	2a05                	addiw	s4,s4,1
    2664:	fd4956e3          	bge	s2,s4,2630 <manywrites+0xac>
        unlink(name);
    2668:	fa840513          	addi	a0,s0,-88
    266c:	00003097          	auipc	ra,0x3
    2670:	758080e7          	jalr	1880(ra) # 5dc4 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    2674:	3b7d                	addiw	s6,s6,-1
    2676:	fa0b1ae3          	bnez	s6,262a <manywrites+0xa6>
      unlink(name);
    267a:	fa840513          	addi	a0,s0,-88
    267e:	00003097          	auipc	ra,0x3
    2682:	746080e7          	jalr	1862(ra) # 5dc4 <unlink>
      exit(0);
    2686:	4501                	li	a0,0
    2688:	00003097          	auipc	ra,0x3
    268c:	6e4080e7          	jalr	1764(ra) # 5d6c <exit>
            printf("%s: cannot create %s\n", s, name);
    2690:	fa840613          	addi	a2,s0,-88
    2694:	85d6                	mv	a1,s5
    2696:	00005517          	auipc	a0,0x5
    269a:	95a50513          	addi	a0,a0,-1702 # 6ff0 <malloc+0xe26>
    269e:	00004097          	auipc	ra,0x4
    26a2:	a6e080e7          	jalr	-1426(ra) # 610c <printf>
            exit(1);
    26a6:	4505                	li	a0,1
    26a8:	00003097          	auipc	ra,0x3
    26ac:	6c4080e7          	jalr	1732(ra) # 5d6c <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    26b0:	86aa                	mv	a3,a0
    26b2:	660d                	lui	a2,0x3
    26b4:	85d6                	mv	a1,s5
    26b6:	00004517          	auipc	a0,0x4
    26ba:	d2250513          	addi	a0,a0,-734 # 63d8 <malloc+0x20e>
    26be:	00004097          	auipc	ra,0x4
    26c2:	a4e080e7          	jalr	-1458(ra) # 610c <printf>
            exit(1);
    26c6:	4505                	li	a0,1
    26c8:	00003097          	auipc	ra,0x3
    26cc:	6a4080e7          	jalr	1700(ra) # 5d6c <exit>
      exit(st);
    26d0:	00003097          	auipc	ra,0x3
    26d4:	69c080e7          	jalr	1692(ra) # 5d6c <exit>

00000000000026d8 <copyinstr3>:
{
    26d8:	7179                	addi	sp,sp,-48
    26da:	f406                	sd	ra,40(sp)
    26dc:	f022                	sd	s0,32(sp)
    26de:	ec26                	sd	s1,24(sp)
    26e0:	1800                	addi	s0,sp,48
  sbrk(8192);
    26e2:	6509                	lui	a0,0x2
    26e4:	00003097          	auipc	ra,0x3
    26e8:	718080e7          	jalr	1816(ra) # 5dfc <sbrk>
  uint64 top = (uint64) sbrk(0);
    26ec:	4501                	li	a0,0
    26ee:	00003097          	auipc	ra,0x3
    26f2:	70e080e7          	jalr	1806(ra) # 5dfc <sbrk>
  if((top % PGSIZE) != 0){
    26f6:	03451793          	slli	a5,a0,0x34
    26fa:	e3c9                	bnez	a5,277c <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    26fc:	4501                	li	a0,0
    26fe:	00003097          	auipc	ra,0x3
    2702:	6fe080e7          	jalr	1790(ra) # 5dfc <sbrk>
  if(top % PGSIZE){
    2706:	03451793          	slli	a5,a0,0x34
    270a:	e3d9                	bnez	a5,2790 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    270c:	fff50493          	addi	s1,a0,-1 # 1fff <createdelete+0x22d>
  *b = 'x';
    2710:	07800793          	li	a5,120
    2714:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2718:	8526                	mv	a0,s1
    271a:	00003097          	auipc	ra,0x3
    271e:	6aa080e7          	jalr	1706(ra) # 5dc4 <unlink>
  if(ret != -1){
    2722:	57fd                	li	a5,-1
    2724:	08f51363          	bne	a0,a5,27aa <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2728:	20100593          	li	a1,513
    272c:	8526                	mv	a0,s1
    272e:	00003097          	auipc	ra,0x3
    2732:	686080e7          	jalr	1670(ra) # 5db4 <open>
  if(fd != -1){
    2736:	57fd                	li	a5,-1
    2738:	08f51863          	bne	a0,a5,27c8 <copyinstr3+0xf0>
  ret = link(b, b);
    273c:	85a6                	mv	a1,s1
    273e:	8526                	mv	a0,s1
    2740:	00003097          	auipc	ra,0x3
    2744:	694080e7          	jalr	1684(ra) # 5dd4 <link>
  if(ret != -1){
    2748:	57fd                	li	a5,-1
    274a:	08f51e63          	bne	a0,a5,27e6 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    274e:	00005797          	auipc	a5,0x5
    2752:	59a78793          	addi	a5,a5,1434 # 7ce8 <malloc+0x1b1e>
    2756:	fcf43823          	sd	a5,-48(s0)
    275a:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    275e:	fd040593          	addi	a1,s0,-48
    2762:	8526                	mv	a0,s1
    2764:	00003097          	auipc	ra,0x3
    2768:	648080e7          	jalr	1608(ra) # 5dac <exec>
  if(ret != -1){
    276c:	57fd                	li	a5,-1
    276e:	08f51c63          	bne	a0,a5,2806 <copyinstr3+0x12e>
}
    2772:	70a2                	ld	ra,40(sp)
    2774:	7402                	ld	s0,32(sp)
    2776:	64e2                	ld	s1,24(sp)
    2778:	6145                	addi	sp,sp,48
    277a:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    277c:	0347d513          	srli	a0,a5,0x34
    2780:	6785                	lui	a5,0x1
    2782:	40a7853b          	subw	a0,a5,a0
    2786:	00003097          	auipc	ra,0x3
    278a:	676080e7          	jalr	1654(ra) # 5dfc <sbrk>
    278e:	b7bd                	j	26fc <copyinstr3+0x24>
    printf("oops\n");
    2790:	00005517          	auipc	a0,0x5
    2794:	87850513          	addi	a0,a0,-1928 # 7008 <malloc+0xe3e>
    2798:	00004097          	auipc	ra,0x4
    279c:	974080e7          	jalr	-1676(ra) # 610c <printf>
    exit(1);
    27a0:	4505                	li	a0,1
    27a2:	00003097          	auipc	ra,0x3
    27a6:	5ca080e7          	jalr	1482(ra) # 5d6c <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    27aa:	862a                	mv	a2,a0
    27ac:	85a6                	mv	a1,s1
    27ae:	00004517          	auipc	a0,0x4
    27b2:	30250513          	addi	a0,a0,770 # 6ab0 <malloc+0x8e6>
    27b6:	00004097          	auipc	ra,0x4
    27ba:	956080e7          	jalr	-1706(ra) # 610c <printf>
    exit(1);
    27be:	4505                	li	a0,1
    27c0:	00003097          	auipc	ra,0x3
    27c4:	5ac080e7          	jalr	1452(ra) # 5d6c <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    27c8:	862a                	mv	a2,a0
    27ca:	85a6                	mv	a1,s1
    27cc:	00004517          	auipc	a0,0x4
    27d0:	30450513          	addi	a0,a0,772 # 6ad0 <malloc+0x906>
    27d4:	00004097          	auipc	ra,0x4
    27d8:	938080e7          	jalr	-1736(ra) # 610c <printf>
    exit(1);
    27dc:	4505                	li	a0,1
    27de:	00003097          	auipc	ra,0x3
    27e2:	58e080e7          	jalr	1422(ra) # 5d6c <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    27e6:	86aa                	mv	a3,a0
    27e8:	8626                	mv	a2,s1
    27ea:	85a6                	mv	a1,s1
    27ec:	00004517          	auipc	a0,0x4
    27f0:	30450513          	addi	a0,a0,772 # 6af0 <malloc+0x926>
    27f4:	00004097          	auipc	ra,0x4
    27f8:	918080e7          	jalr	-1768(ra) # 610c <printf>
    exit(1);
    27fc:	4505                	li	a0,1
    27fe:	00003097          	auipc	ra,0x3
    2802:	56e080e7          	jalr	1390(ra) # 5d6c <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2806:	567d                	li	a2,-1
    2808:	85a6                	mv	a1,s1
    280a:	00004517          	auipc	a0,0x4
    280e:	30e50513          	addi	a0,a0,782 # 6b18 <malloc+0x94e>
    2812:	00004097          	auipc	ra,0x4
    2816:	8fa080e7          	jalr	-1798(ra) # 610c <printf>
    exit(1);
    281a:	4505                	li	a0,1
    281c:	00003097          	auipc	ra,0x3
    2820:	550080e7          	jalr	1360(ra) # 5d6c <exit>

0000000000002824 <rwsbrk>:
{
    2824:	1101                	addi	sp,sp,-32
    2826:	ec06                	sd	ra,24(sp)
    2828:	e822                	sd	s0,16(sp)
    282a:	e426                	sd	s1,8(sp)
    282c:	e04a                	sd	s2,0(sp)
    282e:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2830:	6509                	lui	a0,0x2
    2832:	00003097          	auipc	ra,0x3
    2836:	5ca080e7          	jalr	1482(ra) # 5dfc <sbrk>
  if(a == 0xffffffffffffffffLL) {
    283a:	57fd                	li	a5,-1
    283c:	06f50363          	beq	a0,a5,28a2 <rwsbrk+0x7e>
    2840:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2842:	7579                	lui	a0,0xffffe
    2844:	00003097          	auipc	ra,0x3
    2848:	5b8080e7          	jalr	1464(ra) # 5dfc <sbrk>
    284c:	57fd                	li	a5,-1
    284e:	06f50763          	beq	a0,a5,28bc <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2852:	20100593          	li	a1,513
    2856:	00004517          	auipc	a0,0x4
    285a:	7f250513          	addi	a0,a0,2034 # 7048 <malloc+0xe7e>
    285e:	00003097          	auipc	ra,0x3
    2862:	556080e7          	jalr	1366(ra) # 5db4 <open>
    2866:	892a                	mv	s2,a0
  if(fd < 0){
    2868:	06054763          	bltz	a0,28d6 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    286c:	6505                	lui	a0,0x1
    286e:	94aa                	add	s1,s1,a0
    2870:	40000613          	li	a2,1024
    2874:	85a6                	mv	a1,s1
    2876:	854a                	mv	a0,s2
    2878:	00003097          	auipc	ra,0x3
    287c:	51c080e7          	jalr	1308(ra) # 5d94 <write>
    2880:	862a                	mv	a2,a0
  if(n >= 0){
    2882:	06054763          	bltz	a0,28f0 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    2886:	85a6                	mv	a1,s1
    2888:	00004517          	auipc	a0,0x4
    288c:	7e050513          	addi	a0,a0,2016 # 7068 <malloc+0xe9e>
    2890:	00004097          	auipc	ra,0x4
    2894:	87c080e7          	jalr	-1924(ra) # 610c <printf>
    exit(1);
    2898:	4505                	li	a0,1
    289a:	00003097          	auipc	ra,0x3
    289e:	4d2080e7          	jalr	1234(ra) # 5d6c <exit>
    printf("sbrk(rwsbrk) failed\n");
    28a2:	00004517          	auipc	a0,0x4
    28a6:	76e50513          	addi	a0,a0,1902 # 7010 <malloc+0xe46>
    28aa:	00004097          	auipc	ra,0x4
    28ae:	862080e7          	jalr	-1950(ra) # 610c <printf>
    exit(1);
    28b2:	4505                	li	a0,1
    28b4:	00003097          	auipc	ra,0x3
    28b8:	4b8080e7          	jalr	1208(ra) # 5d6c <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    28bc:	00004517          	auipc	a0,0x4
    28c0:	76c50513          	addi	a0,a0,1900 # 7028 <malloc+0xe5e>
    28c4:	00004097          	auipc	ra,0x4
    28c8:	848080e7          	jalr	-1976(ra) # 610c <printf>
    exit(1);
    28cc:	4505                	li	a0,1
    28ce:	00003097          	auipc	ra,0x3
    28d2:	49e080e7          	jalr	1182(ra) # 5d6c <exit>
    printf("open(rwsbrk) failed\n");
    28d6:	00004517          	auipc	a0,0x4
    28da:	77a50513          	addi	a0,a0,1914 # 7050 <malloc+0xe86>
    28de:	00004097          	auipc	ra,0x4
    28e2:	82e080e7          	jalr	-2002(ra) # 610c <printf>
    exit(1);
    28e6:	4505                	li	a0,1
    28e8:	00003097          	auipc	ra,0x3
    28ec:	484080e7          	jalr	1156(ra) # 5d6c <exit>
  close(fd);
    28f0:	854a                	mv	a0,s2
    28f2:	00003097          	auipc	ra,0x3
    28f6:	4aa080e7          	jalr	1194(ra) # 5d9c <close>
  unlink("rwsbrk");
    28fa:	00004517          	auipc	a0,0x4
    28fe:	74e50513          	addi	a0,a0,1870 # 7048 <malloc+0xe7e>
    2902:	00003097          	auipc	ra,0x3
    2906:	4c2080e7          	jalr	1218(ra) # 5dc4 <unlink>
  fd = open("README", O_RDONLY);
    290a:	4581                	li	a1,0
    290c:	00004517          	auipc	a0,0x4
    2910:	bd450513          	addi	a0,a0,-1068 # 64e0 <malloc+0x316>
    2914:	00003097          	auipc	ra,0x3
    2918:	4a0080e7          	jalr	1184(ra) # 5db4 <open>
    291c:	892a                	mv	s2,a0
  if(fd < 0){
    291e:	02054963          	bltz	a0,2950 <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    2922:	4629                	li	a2,10
    2924:	85a6                	mv	a1,s1
    2926:	00003097          	auipc	ra,0x3
    292a:	466080e7          	jalr	1126(ra) # 5d8c <read>
    292e:	862a                	mv	a2,a0
  if(n >= 0){
    2930:	02054d63          	bltz	a0,296a <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2934:	85a6                	mv	a1,s1
    2936:	00004517          	auipc	a0,0x4
    293a:	76250513          	addi	a0,a0,1890 # 7098 <malloc+0xece>
    293e:	00003097          	auipc	ra,0x3
    2942:	7ce080e7          	jalr	1998(ra) # 610c <printf>
    exit(1);
    2946:	4505                	li	a0,1
    2948:	00003097          	auipc	ra,0x3
    294c:	424080e7          	jalr	1060(ra) # 5d6c <exit>
    printf("open(rwsbrk) failed\n");
    2950:	00004517          	auipc	a0,0x4
    2954:	70050513          	addi	a0,a0,1792 # 7050 <malloc+0xe86>
    2958:	00003097          	auipc	ra,0x3
    295c:	7b4080e7          	jalr	1972(ra) # 610c <printf>
    exit(1);
    2960:	4505                	li	a0,1
    2962:	00003097          	auipc	ra,0x3
    2966:	40a080e7          	jalr	1034(ra) # 5d6c <exit>
  close(fd);
    296a:	854a                	mv	a0,s2
    296c:	00003097          	auipc	ra,0x3
    2970:	430080e7          	jalr	1072(ra) # 5d9c <close>
  exit(0);
    2974:	4501                	li	a0,0
    2976:	00003097          	auipc	ra,0x3
    297a:	3f6080e7          	jalr	1014(ra) # 5d6c <exit>

000000000000297e <sbrkbasic>:
{
    297e:	715d                	addi	sp,sp,-80
    2980:	e486                	sd	ra,72(sp)
    2982:	e0a2                	sd	s0,64(sp)
    2984:	fc26                	sd	s1,56(sp)
    2986:	f84a                	sd	s2,48(sp)
    2988:	f44e                	sd	s3,40(sp)
    298a:	f052                	sd	s4,32(sp)
    298c:	ec56                	sd	s5,24(sp)
    298e:	0880                	addi	s0,sp,80
    2990:	8a2a                	mv	s4,a0
  pid = fork();
    2992:	00003097          	auipc	ra,0x3
    2996:	3d2080e7          	jalr	978(ra) # 5d64 <fork>
  if(pid < 0){
    299a:	02054c63          	bltz	a0,29d2 <sbrkbasic+0x54>
  if(pid == 0){
    299e:	ed21                	bnez	a0,29f6 <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    29a0:	40000537          	lui	a0,0x40000
    29a4:	00003097          	auipc	ra,0x3
    29a8:	458080e7          	jalr	1112(ra) # 5dfc <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    29ac:	57fd                	li	a5,-1
    29ae:	02f50f63          	beq	a0,a5,29ec <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    29b2:	400007b7          	lui	a5,0x40000
    29b6:	97aa                	add	a5,a5,a0
      *b = 99;
    29b8:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    29bc:	6705                	lui	a4,0x1
      *b = 99;
    29be:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0388>
    for(b = a; b < a+TOOMUCH; b += 4096){
    29c2:	953a                	add	a0,a0,a4
    29c4:	fef51de3          	bne	a0,a5,29be <sbrkbasic+0x40>
    exit(1);
    29c8:	4505                	li	a0,1
    29ca:	00003097          	auipc	ra,0x3
    29ce:	3a2080e7          	jalr	930(ra) # 5d6c <exit>
    printf("fork failed in sbrkbasic\n");
    29d2:	00004517          	auipc	a0,0x4
    29d6:	6ee50513          	addi	a0,a0,1774 # 70c0 <malloc+0xef6>
    29da:	00003097          	auipc	ra,0x3
    29de:	732080e7          	jalr	1842(ra) # 610c <printf>
    exit(1);
    29e2:	4505                	li	a0,1
    29e4:	00003097          	auipc	ra,0x3
    29e8:	388080e7          	jalr	904(ra) # 5d6c <exit>
      exit(0);
    29ec:	4501                	li	a0,0
    29ee:	00003097          	auipc	ra,0x3
    29f2:	37e080e7          	jalr	894(ra) # 5d6c <exit>
  wait(&xstatus,"");
    29f6:	00005597          	auipc	a1,0x5
    29fa:	f0258593          	addi	a1,a1,-254 # 78f8 <malloc+0x172e>
    29fe:	fbc40513          	addi	a0,s0,-68
    2a02:	00003097          	auipc	ra,0x3
    2a06:	37a080e7          	jalr	890(ra) # 5d7c <wait>
  if(xstatus == 1){
    2a0a:	fbc42703          	lw	a4,-68(s0)
    2a0e:	4785                	li	a5,1
    2a10:	00f70e63          	beq	a4,a5,2a2c <sbrkbasic+0xae>
  a = sbrk(0);
    2a14:	4501                	li	a0,0
    2a16:	00003097          	auipc	ra,0x3
    2a1a:	3e6080e7          	jalr	998(ra) # 5dfc <sbrk>
    2a1e:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2a20:	4901                	li	s2,0
    *b = 1;
    2a22:	4a85                	li	s5,1
  for(i = 0; i < 5000; i++){
    2a24:	6985                	lui	s3,0x1
    2a26:	38898993          	addi	s3,s3,904 # 1388 <badarg+0x3c>
    2a2a:	a005                	j	2a4a <sbrkbasic+0xcc>
    printf("%s: too much memory allocated!\n", s);
    2a2c:	85d2                	mv	a1,s4
    2a2e:	00004517          	auipc	a0,0x4
    2a32:	6b250513          	addi	a0,a0,1714 # 70e0 <malloc+0xf16>
    2a36:	00003097          	auipc	ra,0x3
    2a3a:	6d6080e7          	jalr	1750(ra) # 610c <printf>
    exit(1);
    2a3e:	4505                	li	a0,1
    2a40:	00003097          	auipc	ra,0x3
    2a44:	32c080e7          	jalr	812(ra) # 5d6c <exit>
    a = b + 1;
    2a48:	84be                	mv	s1,a5
    b = sbrk(1);
    2a4a:	4505                	li	a0,1
    2a4c:	00003097          	auipc	ra,0x3
    2a50:	3b0080e7          	jalr	944(ra) # 5dfc <sbrk>
    if(b != a){
    2a54:	04951b63          	bne	a0,s1,2aaa <sbrkbasic+0x12c>
    *b = 1;
    2a58:	01548023          	sb	s5,0(s1)
    a = b + 1;
    2a5c:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2a60:	2905                	addiw	s2,s2,1
    2a62:	ff3913e3          	bne	s2,s3,2a48 <sbrkbasic+0xca>
  pid = fork();
    2a66:	00003097          	auipc	ra,0x3
    2a6a:	2fe080e7          	jalr	766(ra) # 5d64 <fork>
    2a6e:	892a                	mv	s2,a0
  if(pid < 0){
    2a70:	04054e63          	bltz	a0,2acc <sbrkbasic+0x14e>
  c = sbrk(1);
    2a74:	4505                	li	a0,1
    2a76:	00003097          	auipc	ra,0x3
    2a7a:	386080e7          	jalr	902(ra) # 5dfc <sbrk>
  c = sbrk(1);
    2a7e:	4505                	li	a0,1
    2a80:	00003097          	auipc	ra,0x3
    2a84:	37c080e7          	jalr	892(ra) # 5dfc <sbrk>
  if(c != a + 1){
    2a88:	0489                	addi	s1,s1,2
    2a8a:	04a48f63          	beq	s1,a0,2ae8 <sbrkbasic+0x16a>
    printf("%s: sbrk test failed post-fork\n", s);
    2a8e:	85d2                	mv	a1,s4
    2a90:	00004517          	auipc	a0,0x4
    2a94:	6b050513          	addi	a0,a0,1712 # 7140 <malloc+0xf76>
    2a98:	00003097          	auipc	ra,0x3
    2a9c:	674080e7          	jalr	1652(ra) # 610c <printf>
    exit(1);
    2aa0:	4505                	li	a0,1
    2aa2:	00003097          	auipc	ra,0x3
    2aa6:	2ca080e7          	jalr	714(ra) # 5d6c <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    2aaa:	872a                	mv	a4,a0
    2aac:	86a6                	mv	a3,s1
    2aae:	864a                	mv	a2,s2
    2ab0:	85d2                	mv	a1,s4
    2ab2:	00004517          	auipc	a0,0x4
    2ab6:	64e50513          	addi	a0,a0,1614 # 7100 <malloc+0xf36>
    2aba:	00003097          	auipc	ra,0x3
    2abe:	652080e7          	jalr	1618(ra) # 610c <printf>
      exit(1);
    2ac2:	4505                	li	a0,1
    2ac4:	00003097          	auipc	ra,0x3
    2ac8:	2a8080e7          	jalr	680(ra) # 5d6c <exit>
    printf("%s: sbrk test fork failed\n", s);
    2acc:	85d2                	mv	a1,s4
    2ace:	00004517          	auipc	a0,0x4
    2ad2:	65250513          	addi	a0,a0,1618 # 7120 <malloc+0xf56>
    2ad6:	00003097          	auipc	ra,0x3
    2ada:	636080e7          	jalr	1590(ra) # 610c <printf>
    exit(1);
    2ade:	4505                	li	a0,1
    2ae0:	00003097          	auipc	ra,0x3
    2ae4:	28c080e7          	jalr	652(ra) # 5d6c <exit>
  if(pid == 0)
    2ae8:	00091763          	bnez	s2,2af6 <sbrkbasic+0x178>
    exit(0);
    2aec:	4501                	li	a0,0
    2aee:	00003097          	auipc	ra,0x3
    2af2:	27e080e7          	jalr	638(ra) # 5d6c <exit>
  wait(&xstatus,"");
    2af6:	00005597          	auipc	a1,0x5
    2afa:	e0258593          	addi	a1,a1,-510 # 78f8 <malloc+0x172e>
    2afe:	fbc40513          	addi	a0,s0,-68
    2b02:	00003097          	auipc	ra,0x3
    2b06:	27a080e7          	jalr	634(ra) # 5d7c <wait>
  exit(xstatus);
    2b0a:	fbc42503          	lw	a0,-68(s0)
    2b0e:	00003097          	auipc	ra,0x3
    2b12:	25e080e7          	jalr	606(ra) # 5d6c <exit>

0000000000002b16 <sbrkmuch>:
{
    2b16:	7179                	addi	sp,sp,-48
    2b18:	f406                	sd	ra,40(sp)
    2b1a:	f022                	sd	s0,32(sp)
    2b1c:	ec26                	sd	s1,24(sp)
    2b1e:	e84a                	sd	s2,16(sp)
    2b20:	e44e                	sd	s3,8(sp)
    2b22:	e052                	sd	s4,0(sp)
    2b24:	1800                	addi	s0,sp,48
    2b26:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2b28:	4501                	li	a0,0
    2b2a:	00003097          	auipc	ra,0x3
    2b2e:	2d2080e7          	jalr	722(ra) # 5dfc <sbrk>
    2b32:	892a                	mv	s2,a0
  a = sbrk(0);
    2b34:	4501                	li	a0,0
    2b36:	00003097          	auipc	ra,0x3
    2b3a:	2c6080e7          	jalr	710(ra) # 5dfc <sbrk>
    2b3e:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2b40:	06400537          	lui	a0,0x6400
    2b44:	9d05                	subw	a0,a0,s1
    2b46:	00003097          	auipc	ra,0x3
    2b4a:	2b6080e7          	jalr	694(ra) # 5dfc <sbrk>
  if (p != a) {
    2b4e:	0ca49863          	bne	s1,a0,2c1e <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2b52:	4501                	li	a0,0
    2b54:	00003097          	auipc	ra,0x3
    2b58:	2a8080e7          	jalr	680(ra) # 5dfc <sbrk>
    2b5c:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2b5e:	00a4f963          	bgeu	s1,a0,2b70 <sbrkmuch+0x5a>
    *pp = 1;
    2b62:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2b64:	6705                	lui	a4,0x1
    *pp = 1;
    2b66:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2b6a:	94ba                	add	s1,s1,a4
    2b6c:	fef4ede3          	bltu	s1,a5,2b66 <sbrkmuch+0x50>
  *lastaddr = 99;
    2b70:	064007b7          	lui	a5,0x6400
    2b74:	06300713          	li	a4,99
    2b78:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0387>
  a = sbrk(0);
    2b7c:	4501                	li	a0,0
    2b7e:	00003097          	auipc	ra,0x3
    2b82:	27e080e7          	jalr	638(ra) # 5dfc <sbrk>
    2b86:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2b88:	757d                	lui	a0,0xfffff
    2b8a:	00003097          	auipc	ra,0x3
    2b8e:	272080e7          	jalr	626(ra) # 5dfc <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2b92:	57fd                	li	a5,-1
    2b94:	0af50363          	beq	a0,a5,2c3a <sbrkmuch+0x124>
  c = sbrk(0);
    2b98:	4501                	li	a0,0
    2b9a:	00003097          	auipc	ra,0x3
    2b9e:	262080e7          	jalr	610(ra) # 5dfc <sbrk>
  if(c != a - PGSIZE){
    2ba2:	77fd                	lui	a5,0xfffff
    2ba4:	97a6                	add	a5,a5,s1
    2ba6:	0af51863          	bne	a0,a5,2c56 <sbrkmuch+0x140>
  a = sbrk(0);
    2baa:	4501                	li	a0,0
    2bac:	00003097          	auipc	ra,0x3
    2bb0:	250080e7          	jalr	592(ra) # 5dfc <sbrk>
    2bb4:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2bb6:	6505                	lui	a0,0x1
    2bb8:	00003097          	auipc	ra,0x3
    2bbc:	244080e7          	jalr	580(ra) # 5dfc <sbrk>
    2bc0:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2bc2:	0aa49a63          	bne	s1,a0,2c76 <sbrkmuch+0x160>
    2bc6:	4501                	li	a0,0
    2bc8:	00003097          	auipc	ra,0x3
    2bcc:	234080e7          	jalr	564(ra) # 5dfc <sbrk>
    2bd0:	6785                	lui	a5,0x1
    2bd2:	97a6                	add	a5,a5,s1
    2bd4:	0af51163          	bne	a0,a5,2c76 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    2bd8:	064007b7          	lui	a5,0x6400
    2bdc:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0387>
    2be0:	06300793          	li	a5,99
    2be4:	0af70963          	beq	a4,a5,2c96 <sbrkmuch+0x180>
  a = sbrk(0);
    2be8:	4501                	li	a0,0
    2bea:	00003097          	auipc	ra,0x3
    2bee:	212080e7          	jalr	530(ra) # 5dfc <sbrk>
    2bf2:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2bf4:	4501                	li	a0,0
    2bf6:	00003097          	auipc	ra,0x3
    2bfa:	206080e7          	jalr	518(ra) # 5dfc <sbrk>
    2bfe:	40a9053b          	subw	a0,s2,a0
    2c02:	00003097          	auipc	ra,0x3
    2c06:	1fa080e7          	jalr	506(ra) # 5dfc <sbrk>
  if(c != a){
    2c0a:	0aa49463          	bne	s1,a0,2cb2 <sbrkmuch+0x19c>
}
    2c0e:	70a2                	ld	ra,40(sp)
    2c10:	7402                	ld	s0,32(sp)
    2c12:	64e2                	ld	s1,24(sp)
    2c14:	6942                	ld	s2,16(sp)
    2c16:	69a2                	ld	s3,8(sp)
    2c18:	6a02                	ld	s4,0(sp)
    2c1a:	6145                	addi	sp,sp,48
    2c1c:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2c1e:	85ce                	mv	a1,s3
    2c20:	00004517          	auipc	a0,0x4
    2c24:	54050513          	addi	a0,a0,1344 # 7160 <malloc+0xf96>
    2c28:	00003097          	auipc	ra,0x3
    2c2c:	4e4080e7          	jalr	1252(ra) # 610c <printf>
    exit(1);
    2c30:	4505                	li	a0,1
    2c32:	00003097          	auipc	ra,0x3
    2c36:	13a080e7          	jalr	314(ra) # 5d6c <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2c3a:	85ce                	mv	a1,s3
    2c3c:	00004517          	auipc	a0,0x4
    2c40:	56c50513          	addi	a0,a0,1388 # 71a8 <malloc+0xfde>
    2c44:	00003097          	auipc	ra,0x3
    2c48:	4c8080e7          	jalr	1224(ra) # 610c <printf>
    exit(1);
    2c4c:	4505                	li	a0,1
    2c4e:	00003097          	auipc	ra,0x3
    2c52:	11e080e7          	jalr	286(ra) # 5d6c <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2c56:	86aa                	mv	a3,a0
    2c58:	8626                	mv	a2,s1
    2c5a:	85ce                	mv	a1,s3
    2c5c:	00004517          	auipc	a0,0x4
    2c60:	56c50513          	addi	a0,a0,1388 # 71c8 <malloc+0xffe>
    2c64:	00003097          	auipc	ra,0x3
    2c68:	4a8080e7          	jalr	1192(ra) # 610c <printf>
    exit(1);
    2c6c:	4505                	li	a0,1
    2c6e:	00003097          	auipc	ra,0x3
    2c72:	0fe080e7          	jalr	254(ra) # 5d6c <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2c76:	86d2                	mv	a3,s4
    2c78:	8626                	mv	a2,s1
    2c7a:	85ce                	mv	a1,s3
    2c7c:	00004517          	auipc	a0,0x4
    2c80:	58c50513          	addi	a0,a0,1420 # 7208 <malloc+0x103e>
    2c84:	00003097          	auipc	ra,0x3
    2c88:	488080e7          	jalr	1160(ra) # 610c <printf>
    exit(1);
    2c8c:	4505                	li	a0,1
    2c8e:	00003097          	auipc	ra,0x3
    2c92:	0de080e7          	jalr	222(ra) # 5d6c <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2c96:	85ce                	mv	a1,s3
    2c98:	00004517          	auipc	a0,0x4
    2c9c:	5a050513          	addi	a0,a0,1440 # 7238 <malloc+0x106e>
    2ca0:	00003097          	auipc	ra,0x3
    2ca4:	46c080e7          	jalr	1132(ra) # 610c <printf>
    exit(1);
    2ca8:	4505                	li	a0,1
    2caa:	00003097          	auipc	ra,0x3
    2cae:	0c2080e7          	jalr	194(ra) # 5d6c <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2cb2:	86aa                	mv	a3,a0
    2cb4:	8626                	mv	a2,s1
    2cb6:	85ce                	mv	a1,s3
    2cb8:	00004517          	auipc	a0,0x4
    2cbc:	5b850513          	addi	a0,a0,1464 # 7270 <malloc+0x10a6>
    2cc0:	00003097          	auipc	ra,0x3
    2cc4:	44c080e7          	jalr	1100(ra) # 610c <printf>
    exit(1);
    2cc8:	4505                	li	a0,1
    2cca:	00003097          	auipc	ra,0x3
    2cce:	0a2080e7          	jalr	162(ra) # 5d6c <exit>

0000000000002cd2 <sbrkarg>:
{
    2cd2:	7179                	addi	sp,sp,-48
    2cd4:	f406                	sd	ra,40(sp)
    2cd6:	f022                	sd	s0,32(sp)
    2cd8:	ec26                	sd	s1,24(sp)
    2cda:	e84a                	sd	s2,16(sp)
    2cdc:	e44e                	sd	s3,8(sp)
    2cde:	1800                	addi	s0,sp,48
    2ce0:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2ce2:	6505                	lui	a0,0x1
    2ce4:	00003097          	auipc	ra,0x3
    2ce8:	118080e7          	jalr	280(ra) # 5dfc <sbrk>
    2cec:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2cee:	20100593          	li	a1,513
    2cf2:	00004517          	auipc	a0,0x4
    2cf6:	5a650513          	addi	a0,a0,1446 # 7298 <malloc+0x10ce>
    2cfa:	00003097          	auipc	ra,0x3
    2cfe:	0ba080e7          	jalr	186(ra) # 5db4 <open>
    2d02:	84aa                	mv	s1,a0
  unlink("sbrk");
    2d04:	00004517          	auipc	a0,0x4
    2d08:	59450513          	addi	a0,a0,1428 # 7298 <malloc+0x10ce>
    2d0c:	00003097          	auipc	ra,0x3
    2d10:	0b8080e7          	jalr	184(ra) # 5dc4 <unlink>
  if(fd < 0)  {
    2d14:	0404c163          	bltz	s1,2d56 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2d18:	6605                	lui	a2,0x1
    2d1a:	85ca                	mv	a1,s2
    2d1c:	8526                	mv	a0,s1
    2d1e:	00003097          	auipc	ra,0x3
    2d22:	076080e7          	jalr	118(ra) # 5d94 <write>
    2d26:	04054663          	bltz	a0,2d72 <sbrkarg+0xa0>
  close(fd);
    2d2a:	8526                	mv	a0,s1
    2d2c:	00003097          	auipc	ra,0x3
    2d30:	070080e7          	jalr	112(ra) # 5d9c <close>
  a = sbrk(PGSIZE);
    2d34:	6505                	lui	a0,0x1
    2d36:	00003097          	auipc	ra,0x3
    2d3a:	0c6080e7          	jalr	198(ra) # 5dfc <sbrk>
  if(pipe((int *) a) != 0){
    2d3e:	00003097          	auipc	ra,0x3
    2d42:	046080e7          	jalr	70(ra) # 5d84 <pipe>
    2d46:	e521                	bnez	a0,2d8e <sbrkarg+0xbc>
}
    2d48:	70a2                	ld	ra,40(sp)
    2d4a:	7402                	ld	s0,32(sp)
    2d4c:	64e2                	ld	s1,24(sp)
    2d4e:	6942                	ld	s2,16(sp)
    2d50:	69a2                	ld	s3,8(sp)
    2d52:	6145                	addi	sp,sp,48
    2d54:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2d56:	85ce                	mv	a1,s3
    2d58:	00004517          	auipc	a0,0x4
    2d5c:	54850513          	addi	a0,a0,1352 # 72a0 <malloc+0x10d6>
    2d60:	00003097          	auipc	ra,0x3
    2d64:	3ac080e7          	jalr	940(ra) # 610c <printf>
    exit(1);
    2d68:	4505                	li	a0,1
    2d6a:	00003097          	auipc	ra,0x3
    2d6e:	002080e7          	jalr	2(ra) # 5d6c <exit>
    printf("%s: write sbrk failed\n", s);
    2d72:	85ce                	mv	a1,s3
    2d74:	00004517          	auipc	a0,0x4
    2d78:	54450513          	addi	a0,a0,1348 # 72b8 <malloc+0x10ee>
    2d7c:	00003097          	auipc	ra,0x3
    2d80:	390080e7          	jalr	912(ra) # 610c <printf>
    exit(1);
    2d84:	4505                	li	a0,1
    2d86:	00003097          	auipc	ra,0x3
    2d8a:	fe6080e7          	jalr	-26(ra) # 5d6c <exit>
    printf("%s: pipe() failed\n", s);
    2d8e:	85ce                	mv	a1,s3
    2d90:	00004517          	auipc	a0,0x4
    2d94:	f0850513          	addi	a0,a0,-248 # 6c98 <malloc+0xace>
    2d98:	00003097          	auipc	ra,0x3
    2d9c:	374080e7          	jalr	884(ra) # 610c <printf>
    exit(1);
    2da0:	4505                	li	a0,1
    2da2:	00003097          	auipc	ra,0x3
    2da6:	fca080e7          	jalr	-54(ra) # 5d6c <exit>

0000000000002daa <argptest>:
{
    2daa:	1101                	addi	sp,sp,-32
    2dac:	ec06                	sd	ra,24(sp)
    2dae:	e822                	sd	s0,16(sp)
    2db0:	e426                	sd	s1,8(sp)
    2db2:	e04a                	sd	s2,0(sp)
    2db4:	1000                	addi	s0,sp,32
    2db6:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2db8:	4581                	li	a1,0
    2dba:	00004517          	auipc	a0,0x4
    2dbe:	51650513          	addi	a0,a0,1302 # 72d0 <malloc+0x1106>
    2dc2:	00003097          	auipc	ra,0x3
    2dc6:	ff2080e7          	jalr	-14(ra) # 5db4 <open>
  if (fd < 0) {
    2dca:	02054b63          	bltz	a0,2e00 <argptest+0x56>
    2dce:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2dd0:	4501                	li	a0,0
    2dd2:	00003097          	auipc	ra,0x3
    2dd6:	02a080e7          	jalr	42(ra) # 5dfc <sbrk>
    2dda:	567d                	li	a2,-1
    2ddc:	fff50593          	addi	a1,a0,-1
    2de0:	8526                	mv	a0,s1
    2de2:	00003097          	auipc	ra,0x3
    2de6:	faa080e7          	jalr	-86(ra) # 5d8c <read>
  close(fd);
    2dea:	8526                	mv	a0,s1
    2dec:	00003097          	auipc	ra,0x3
    2df0:	fb0080e7          	jalr	-80(ra) # 5d9c <close>
}
    2df4:	60e2                	ld	ra,24(sp)
    2df6:	6442                	ld	s0,16(sp)
    2df8:	64a2                	ld	s1,8(sp)
    2dfa:	6902                	ld	s2,0(sp)
    2dfc:	6105                	addi	sp,sp,32
    2dfe:	8082                	ret
    printf("%s: open failed\n", s);
    2e00:	85ca                	mv	a1,s2
    2e02:	00004517          	auipc	a0,0x4
    2e06:	da650513          	addi	a0,a0,-602 # 6ba8 <malloc+0x9de>
    2e0a:	00003097          	auipc	ra,0x3
    2e0e:	302080e7          	jalr	770(ra) # 610c <printf>
    exit(1);
    2e12:	4505                	li	a0,1
    2e14:	00003097          	auipc	ra,0x3
    2e18:	f58080e7          	jalr	-168(ra) # 5d6c <exit>

0000000000002e1c <sbrkbugs>:
{
    2e1c:	1141                	addi	sp,sp,-16
    2e1e:	e406                	sd	ra,8(sp)
    2e20:	e022                	sd	s0,0(sp)
    2e22:	0800                	addi	s0,sp,16
  int pid = fork();
    2e24:	00003097          	auipc	ra,0x3
    2e28:	f40080e7          	jalr	-192(ra) # 5d64 <fork>
  if(pid < 0){
    2e2c:	02054263          	bltz	a0,2e50 <sbrkbugs+0x34>
  if(pid == 0){
    2e30:	ed0d                	bnez	a0,2e6a <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2e32:	00003097          	auipc	ra,0x3
    2e36:	fca080e7          	jalr	-54(ra) # 5dfc <sbrk>
    sbrk(-sz);
    2e3a:	40a0053b          	negw	a0,a0
    2e3e:	00003097          	auipc	ra,0x3
    2e42:	fbe080e7          	jalr	-66(ra) # 5dfc <sbrk>
    exit(0);
    2e46:	4501                	li	a0,0
    2e48:	00003097          	auipc	ra,0x3
    2e4c:	f24080e7          	jalr	-220(ra) # 5d6c <exit>
    printf("fork failed\n");
    2e50:	00004517          	auipc	a0,0x4
    2e54:	14850513          	addi	a0,a0,328 # 6f98 <malloc+0xdce>
    2e58:	00003097          	auipc	ra,0x3
    2e5c:	2b4080e7          	jalr	692(ra) # 610c <printf>
    exit(1);
    2e60:	4505                	li	a0,1
    2e62:	00003097          	auipc	ra,0x3
    2e66:	f0a080e7          	jalr	-246(ra) # 5d6c <exit>
  wait(0,"");
    2e6a:	00005597          	auipc	a1,0x5
    2e6e:	a8e58593          	addi	a1,a1,-1394 # 78f8 <malloc+0x172e>
    2e72:	4501                	li	a0,0
    2e74:	00003097          	auipc	ra,0x3
    2e78:	f08080e7          	jalr	-248(ra) # 5d7c <wait>
  pid = fork();
    2e7c:	00003097          	auipc	ra,0x3
    2e80:	ee8080e7          	jalr	-280(ra) # 5d64 <fork>
  if(pid < 0){
    2e84:	02054563          	bltz	a0,2eae <sbrkbugs+0x92>
  if(pid == 0){
    2e88:	e121                	bnez	a0,2ec8 <sbrkbugs+0xac>
    int sz = (uint64) sbrk(0);
    2e8a:	00003097          	auipc	ra,0x3
    2e8e:	f72080e7          	jalr	-142(ra) # 5dfc <sbrk>
    sbrk(-(sz - 3500));
    2e92:	6785                	lui	a5,0x1
    2e94:	dac7879b          	addiw	a5,a5,-596
    2e98:	40a7853b          	subw	a0,a5,a0
    2e9c:	00003097          	auipc	ra,0x3
    2ea0:	f60080e7          	jalr	-160(ra) # 5dfc <sbrk>
    exit(0);
    2ea4:	4501                	li	a0,0
    2ea6:	00003097          	auipc	ra,0x3
    2eaa:	ec6080e7          	jalr	-314(ra) # 5d6c <exit>
    printf("fork failed\n");
    2eae:	00004517          	auipc	a0,0x4
    2eb2:	0ea50513          	addi	a0,a0,234 # 6f98 <malloc+0xdce>
    2eb6:	00003097          	auipc	ra,0x3
    2eba:	256080e7          	jalr	598(ra) # 610c <printf>
    exit(1);
    2ebe:	4505                	li	a0,1
    2ec0:	00003097          	auipc	ra,0x3
    2ec4:	eac080e7          	jalr	-340(ra) # 5d6c <exit>
  wait(0,"");
    2ec8:	00005597          	auipc	a1,0x5
    2ecc:	a3058593          	addi	a1,a1,-1488 # 78f8 <malloc+0x172e>
    2ed0:	4501                	li	a0,0
    2ed2:	00003097          	auipc	ra,0x3
    2ed6:	eaa080e7          	jalr	-342(ra) # 5d7c <wait>
  pid = fork();
    2eda:	00003097          	auipc	ra,0x3
    2ede:	e8a080e7          	jalr	-374(ra) # 5d64 <fork>
  if(pid < 0){
    2ee2:	02054a63          	bltz	a0,2f16 <sbrkbugs+0xfa>
  if(pid == 0){
    2ee6:	e529                	bnez	a0,2f30 <sbrkbugs+0x114>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2ee8:	00003097          	auipc	ra,0x3
    2eec:	f14080e7          	jalr	-236(ra) # 5dfc <sbrk>
    2ef0:	67ad                	lui	a5,0xb
    2ef2:	8007879b          	addiw	a5,a5,-2048
    2ef6:	40a7853b          	subw	a0,a5,a0
    2efa:	00003097          	auipc	ra,0x3
    2efe:	f02080e7          	jalr	-254(ra) # 5dfc <sbrk>
    sbrk(-10);
    2f02:	5559                	li	a0,-10
    2f04:	00003097          	auipc	ra,0x3
    2f08:	ef8080e7          	jalr	-264(ra) # 5dfc <sbrk>
    exit(0);
    2f0c:	4501                	li	a0,0
    2f0e:	00003097          	auipc	ra,0x3
    2f12:	e5e080e7          	jalr	-418(ra) # 5d6c <exit>
    printf("fork failed\n");
    2f16:	00004517          	auipc	a0,0x4
    2f1a:	08250513          	addi	a0,a0,130 # 6f98 <malloc+0xdce>
    2f1e:	00003097          	auipc	ra,0x3
    2f22:	1ee080e7          	jalr	494(ra) # 610c <printf>
    exit(1);
    2f26:	4505                	li	a0,1
    2f28:	00003097          	auipc	ra,0x3
    2f2c:	e44080e7          	jalr	-444(ra) # 5d6c <exit>
  wait(0,"");
    2f30:	00005597          	auipc	a1,0x5
    2f34:	9c858593          	addi	a1,a1,-1592 # 78f8 <malloc+0x172e>
    2f38:	4501                	li	a0,0
    2f3a:	00003097          	auipc	ra,0x3
    2f3e:	e42080e7          	jalr	-446(ra) # 5d7c <wait>
  exit(0);
    2f42:	4501                	li	a0,0
    2f44:	00003097          	auipc	ra,0x3
    2f48:	e28080e7          	jalr	-472(ra) # 5d6c <exit>

0000000000002f4c <sbrklast>:
{
    2f4c:	7179                	addi	sp,sp,-48
    2f4e:	f406                	sd	ra,40(sp)
    2f50:	f022                	sd	s0,32(sp)
    2f52:	ec26                	sd	s1,24(sp)
    2f54:	e84a                	sd	s2,16(sp)
    2f56:	e44e                	sd	s3,8(sp)
    2f58:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    2f5a:	4501                	li	a0,0
    2f5c:	00003097          	auipc	ra,0x3
    2f60:	ea0080e7          	jalr	-352(ra) # 5dfc <sbrk>
  if((top % 4096) != 0)
    2f64:	03451793          	slli	a5,a0,0x34
    2f68:	efc1                	bnez	a5,3000 <sbrklast+0xb4>
  sbrk(4096);
    2f6a:	6505                	lui	a0,0x1
    2f6c:	00003097          	auipc	ra,0x3
    2f70:	e90080e7          	jalr	-368(ra) # 5dfc <sbrk>
  sbrk(10);
    2f74:	4529                	li	a0,10
    2f76:	00003097          	auipc	ra,0x3
    2f7a:	e86080e7          	jalr	-378(ra) # 5dfc <sbrk>
  sbrk(-20);
    2f7e:	5531                	li	a0,-20
    2f80:	00003097          	auipc	ra,0x3
    2f84:	e7c080e7          	jalr	-388(ra) # 5dfc <sbrk>
  top = (uint64) sbrk(0);
    2f88:	4501                	li	a0,0
    2f8a:	00003097          	auipc	ra,0x3
    2f8e:	e72080e7          	jalr	-398(ra) # 5dfc <sbrk>
    2f92:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2f94:	fc050913          	addi	s2,a0,-64 # fc0 <linktest+0xca>
  p[0] = 'x';
    2f98:	07800793          	li	a5,120
    2f9c:	fcf50023          	sb	a5,-64(a0)
  p[1] = '\0';
    2fa0:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2fa4:	20200593          	li	a1,514
    2fa8:	854a                	mv	a0,s2
    2faa:	00003097          	auipc	ra,0x3
    2fae:	e0a080e7          	jalr	-502(ra) # 5db4 <open>
    2fb2:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2fb4:	4605                	li	a2,1
    2fb6:	85ca                	mv	a1,s2
    2fb8:	00003097          	auipc	ra,0x3
    2fbc:	ddc080e7          	jalr	-548(ra) # 5d94 <write>
  close(fd);
    2fc0:	854e                	mv	a0,s3
    2fc2:	00003097          	auipc	ra,0x3
    2fc6:	dda080e7          	jalr	-550(ra) # 5d9c <close>
  fd = open(p, O_RDWR);
    2fca:	4589                	li	a1,2
    2fcc:	854a                	mv	a0,s2
    2fce:	00003097          	auipc	ra,0x3
    2fd2:	de6080e7          	jalr	-538(ra) # 5db4 <open>
  p[0] = '\0';
    2fd6:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2fda:	4605                	li	a2,1
    2fdc:	85ca                	mv	a1,s2
    2fde:	00003097          	auipc	ra,0x3
    2fe2:	dae080e7          	jalr	-594(ra) # 5d8c <read>
  if(p[0] != 'x')
    2fe6:	fc04c703          	lbu	a4,-64(s1)
    2fea:	07800793          	li	a5,120
    2fee:	02f71363          	bne	a4,a5,3014 <sbrklast+0xc8>
}
    2ff2:	70a2                	ld	ra,40(sp)
    2ff4:	7402                	ld	s0,32(sp)
    2ff6:	64e2                	ld	s1,24(sp)
    2ff8:	6942                	ld	s2,16(sp)
    2ffa:	69a2                	ld	s3,8(sp)
    2ffc:	6145                	addi	sp,sp,48
    2ffe:	8082                	ret
    sbrk(4096 - (top % 4096));
    3000:	0347d513          	srli	a0,a5,0x34
    3004:	6785                	lui	a5,0x1
    3006:	40a7853b          	subw	a0,a5,a0
    300a:	00003097          	auipc	ra,0x3
    300e:	df2080e7          	jalr	-526(ra) # 5dfc <sbrk>
    3012:	bfa1                	j	2f6a <sbrklast+0x1e>
    exit(1);
    3014:	4505                	li	a0,1
    3016:	00003097          	auipc	ra,0x3
    301a:	d56080e7          	jalr	-682(ra) # 5d6c <exit>

000000000000301e <sbrk8000>:
{
    301e:	1141                	addi	sp,sp,-16
    3020:	e406                	sd	ra,8(sp)
    3022:	e022                	sd	s0,0(sp)
    3024:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    3026:	80000537          	lui	a0,0x80000
    302a:	0511                	addi	a0,a0,4
    302c:	00003097          	auipc	ra,0x3
    3030:	dd0080e7          	jalr	-560(ra) # 5dfc <sbrk>
  volatile char *top = sbrk(0);
    3034:	4501                	li	a0,0
    3036:	00003097          	auipc	ra,0x3
    303a:	dc6080e7          	jalr	-570(ra) # 5dfc <sbrk>
  *(top-1) = *(top-1) + 1;
    303e:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <base+0xffffffff7fff0387>
    3042:	0785                	addi	a5,a5,1
    3044:	0ff7f793          	andi	a5,a5,255
    3048:	fef50fa3          	sb	a5,-1(a0)
}
    304c:	60a2                	ld	ra,8(sp)
    304e:	6402                	ld	s0,0(sp)
    3050:	0141                	addi	sp,sp,16
    3052:	8082                	ret

0000000000003054 <execout>:
{
    3054:	715d                	addi	sp,sp,-80
    3056:	e486                	sd	ra,72(sp)
    3058:	e0a2                	sd	s0,64(sp)
    305a:	fc26                	sd	s1,56(sp)
    305c:	f84a                	sd	s2,48(sp)
    305e:	f44e                	sd	s3,40(sp)
    3060:	f052                	sd	s4,32(sp)
    3062:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    3064:	4901                	li	s2,0
      wait((int*)0, "");
    3066:	00005a17          	auipc	s4,0x5
    306a:	892a0a13          	addi	s4,s4,-1902 # 78f8 <malloc+0x172e>
  for(int avail = 0; avail < 15; avail++){
    306e:	49bd                	li	s3,15
    int pid = fork();
    3070:	00003097          	auipc	ra,0x3
    3074:	cf4080e7          	jalr	-780(ra) # 5d64 <fork>
    3078:	84aa                	mv	s1,a0
    if(pid < 0){
    307a:	02054163          	bltz	a0,309c <execout+0x48>
    } else if(pid == 0){
    307e:	cd05                	beqz	a0,30b6 <execout+0x62>
      wait((int*)0, "");
    3080:	85d2                	mv	a1,s4
    3082:	4501                	li	a0,0
    3084:	00003097          	auipc	ra,0x3
    3088:	cf8080e7          	jalr	-776(ra) # 5d7c <wait>
  for(int avail = 0; avail < 15; avail++){
    308c:	2905                	addiw	s2,s2,1
    308e:	ff3911e3          	bne	s2,s3,3070 <execout+0x1c>
  exit(0);
    3092:	4501                	li	a0,0
    3094:	00003097          	auipc	ra,0x3
    3098:	cd8080e7          	jalr	-808(ra) # 5d6c <exit>
      printf("fork failed\n");
    309c:	00004517          	auipc	a0,0x4
    30a0:	efc50513          	addi	a0,a0,-260 # 6f98 <malloc+0xdce>
    30a4:	00003097          	auipc	ra,0x3
    30a8:	068080e7          	jalr	104(ra) # 610c <printf>
      exit(1);
    30ac:	4505                	li	a0,1
    30ae:	00003097          	auipc	ra,0x3
    30b2:	cbe080e7          	jalr	-834(ra) # 5d6c <exit>
        if(a == 0xffffffffffffffffLL)
    30b6:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    30b8:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    30ba:	6505                	lui	a0,0x1
    30bc:	00003097          	auipc	ra,0x3
    30c0:	d40080e7          	jalr	-704(ra) # 5dfc <sbrk>
        if(a == 0xffffffffffffffffLL)
    30c4:	01350763          	beq	a0,s3,30d2 <execout+0x7e>
        *(char*)(a + 4096 - 1) = 1;
    30c8:	6785                	lui	a5,0x1
    30ca:	953e                	add	a0,a0,a5
    30cc:	ff450fa3          	sb	s4,-1(a0) # fff <linktest+0x109>
      while(1){
    30d0:	b7ed                	j	30ba <execout+0x66>
      for(int i = 0; i < avail; i++)
    30d2:	01205a63          	blez	s2,30e6 <execout+0x92>
        sbrk(-4096);
    30d6:	757d                	lui	a0,0xfffff
    30d8:	00003097          	auipc	ra,0x3
    30dc:	d24080e7          	jalr	-732(ra) # 5dfc <sbrk>
      for(int i = 0; i < avail; i++)
    30e0:	2485                	addiw	s1,s1,1
    30e2:	ff249ae3          	bne	s1,s2,30d6 <execout+0x82>
      close(1);
    30e6:	4505                	li	a0,1
    30e8:	00003097          	auipc	ra,0x3
    30ec:	cb4080e7          	jalr	-844(ra) # 5d9c <close>
      char *args[] = { "echo", "x", 0 };
    30f0:	00003517          	auipc	a0,0x3
    30f4:	21850513          	addi	a0,a0,536 # 6308 <malloc+0x13e>
    30f8:	faa43c23          	sd	a0,-72(s0)
    30fc:	00003797          	auipc	a5,0x3
    3100:	27c78793          	addi	a5,a5,636 # 6378 <malloc+0x1ae>
    3104:	fcf43023          	sd	a5,-64(s0)
    3108:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    310c:	fb840593          	addi	a1,s0,-72
    3110:	00003097          	auipc	ra,0x3
    3114:	c9c080e7          	jalr	-868(ra) # 5dac <exec>
      exit(0);
    3118:	4501                	li	a0,0
    311a:	00003097          	auipc	ra,0x3
    311e:	c52080e7          	jalr	-942(ra) # 5d6c <exit>

0000000000003122 <fourteen>:
{
    3122:	1101                	addi	sp,sp,-32
    3124:	ec06                	sd	ra,24(sp)
    3126:	e822                	sd	s0,16(sp)
    3128:	e426                	sd	s1,8(sp)
    312a:	1000                	addi	s0,sp,32
    312c:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    312e:	00004517          	auipc	a0,0x4
    3132:	37a50513          	addi	a0,a0,890 # 74a8 <malloc+0x12de>
    3136:	00003097          	auipc	ra,0x3
    313a:	ca6080e7          	jalr	-858(ra) # 5ddc <mkdir>
    313e:	e165                	bnez	a0,321e <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    3140:	00004517          	auipc	a0,0x4
    3144:	1c050513          	addi	a0,a0,448 # 7300 <malloc+0x1136>
    3148:	00003097          	auipc	ra,0x3
    314c:	c94080e7          	jalr	-876(ra) # 5ddc <mkdir>
    3150:	e56d                	bnez	a0,323a <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    3152:	20000593          	li	a1,512
    3156:	00004517          	auipc	a0,0x4
    315a:	20250513          	addi	a0,a0,514 # 7358 <malloc+0x118e>
    315e:	00003097          	auipc	ra,0x3
    3162:	c56080e7          	jalr	-938(ra) # 5db4 <open>
  if(fd < 0){
    3166:	0e054863          	bltz	a0,3256 <fourteen+0x134>
  close(fd);
    316a:	00003097          	auipc	ra,0x3
    316e:	c32080e7          	jalr	-974(ra) # 5d9c <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    3172:	4581                	li	a1,0
    3174:	00004517          	auipc	a0,0x4
    3178:	25c50513          	addi	a0,a0,604 # 73d0 <malloc+0x1206>
    317c:	00003097          	auipc	ra,0x3
    3180:	c38080e7          	jalr	-968(ra) # 5db4 <open>
  if(fd < 0){
    3184:	0e054763          	bltz	a0,3272 <fourteen+0x150>
  close(fd);
    3188:	00003097          	auipc	ra,0x3
    318c:	c14080e7          	jalr	-1004(ra) # 5d9c <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    3190:	00004517          	auipc	a0,0x4
    3194:	2b050513          	addi	a0,a0,688 # 7440 <malloc+0x1276>
    3198:	00003097          	auipc	ra,0x3
    319c:	c44080e7          	jalr	-956(ra) # 5ddc <mkdir>
    31a0:	c57d                	beqz	a0,328e <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    31a2:	00004517          	auipc	a0,0x4
    31a6:	2f650513          	addi	a0,a0,758 # 7498 <malloc+0x12ce>
    31aa:	00003097          	auipc	ra,0x3
    31ae:	c32080e7          	jalr	-974(ra) # 5ddc <mkdir>
    31b2:	cd65                	beqz	a0,32aa <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    31b4:	00004517          	auipc	a0,0x4
    31b8:	2e450513          	addi	a0,a0,740 # 7498 <malloc+0x12ce>
    31bc:	00003097          	auipc	ra,0x3
    31c0:	c08080e7          	jalr	-1016(ra) # 5dc4 <unlink>
  unlink("12345678901234/12345678901234");
    31c4:	00004517          	auipc	a0,0x4
    31c8:	27c50513          	addi	a0,a0,636 # 7440 <malloc+0x1276>
    31cc:	00003097          	auipc	ra,0x3
    31d0:	bf8080e7          	jalr	-1032(ra) # 5dc4 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    31d4:	00004517          	auipc	a0,0x4
    31d8:	1fc50513          	addi	a0,a0,508 # 73d0 <malloc+0x1206>
    31dc:	00003097          	auipc	ra,0x3
    31e0:	be8080e7          	jalr	-1048(ra) # 5dc4 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    31e4:	00004517          	auipc	a0,0x4
    31e8:	17450513          	addi	a0,a0,372 # 7358 <malloc+0x118e>
    31ec:	00003097          	auipc	ra,0x3
    31f0:	bd8080e7          	jalr	-1064(ra) # 5dc4 <unlink>
  unlink("12345678901234/123456789012345");
    31f4:	00004517          	auipc	a0,0x4
    31f8:	10c50513          	addi	a0,a0,268 # 7300 <malloc+0x1136>
    31fc:	00003097          	auipc	ra,0x3
    3200:	bc8080e7          	jalr	-1080(ra) # 5dc4 <unlink>
  unlink("12345678901234");
    3204:	00004517          	auipc	a0,0x4
    3208:	2a450513          	addi	a0,a0,676 # 74a8 <malloc+0x12de>
    320c:	00003097          	auipc	ra,0x3
    3210:	bb8080e7          	jalr	-1096(ra) # 5dc4 <unlink>
}
    3214:	60e2                	ld	ra,24(sp)
    3216:	6442                	ld	s0,16(sp)
    3218:	64a2                	ld	s1,8(sp)
    321a:	6105                	addi	sp,sp,32
    321c:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    321e:	85a6                	mv	a1,s1
    3220:	00004517          	auipc	a0,0x4
    3224:	0b850513          	addi	a0,a0,184 # 72d8 <malloc+0x110e>
    3228:	00003097          	auipc	ra,0x3
    322c:	ee4080e7          	jalr	-284(ra) # 610c <printf>
    exit(1);
    3230:	4505                	li	a0,1
    3232:	00003097          	auipc	ra,0x3
    3236:	b3a080e7          	jalr	-1222(ra) # 5d6c <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    323a:	85a6                	mv	a1,s1
    323c:	00004517          	auipc	a0,0x4
    3240:	0e450513          	addi	a0,a0,228 # 7320 <malloc+0x1156>
    3244:	00003097          	auipc	ra,0x3
    3248:	ec8080e7          	jalr	-312(ra) # 610c <printf>
    exit(1);
    324c:	4505                	li	a0,1
    324e:	00003097          	auipc	ra,0x3
    3252:	b1e080e7          	jalr	-1250(ra) # 5d6c <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    3256:	85a6                	mv	a1,s1
    3258:	00004517          	auipc	a0,0x4
    325c:	13050513          	addi	a0,a0,304 # 7388 <malloc+0x11be>
    3260:	00003097          	auipc	ra,0x3
    3264:	eac080e7          	jalr	-340(ra) # 610c <printf>
    exit(1);
    3268:	4505                	li	a0,1
    326a:	00003097          	auipc	ra,0x3
    326e:	b02080e7          	jalr	-1278(ra) # 5d6c <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    3272:	85a6                	mv	a1,s1
    3274:	00004517          	auipc	a0,0x4
    3278:	18c50513          	addi	a0,a0,396 # 7400 <malloc+0x1236>
    327c:	00003097          	auipc	ra,0x3
    3280:	e90080e7          	jalr	-368(ra) # 610c <printf>
    exit(1);
    3284:	4505                	li	a0,1
    3286:	00003097          	auipc	ra,0x3
    328a:	ae6080e7          	jalr	-1306(ra) # 5d6c <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    328e:	85a6                	mv	a1,s1
    3290:	00004517          	auipc	a0,0x4
    3294:	1d050513          	addi	a0,a0,464 # 7460 <malloc+0x1296>
    3298:	00003097          	auipc	ra,0x3
    329c:	e74080e7          	jalr	-396(ra) # 610c <printf>
    exit(1);
    32a0:	4505                	li	a0,1
    32a2:	00003097          	auipc	ra,0x3
    32a6:	aca080e7          	jalr	-1334(ra) # 5d6c <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    32aa:	85a6                	mv	a1,s1
    32ac:	00004517          	auipc	a0,0x4
    32b0:	20c50513          	addi	a0,a0,524 # 74b8 <malloc+0x12ee>
    32b4:	00003097          	auipc	ra,0x3
    32b8:	e58080e7          	jalr	-424(ra) # 610c <printf>
    exit(1);
    32bc:	4505                	li	a0,1
    32be:	00003097          	auipc	ra,0x3
    32c2:	aae080e7          	jalr	-1362(ra) # 5d6c <exit>

00000000000032c6 <diskfull>:
{
    32c6:	b9010113          	addi	sp,sp,-1136
    32ca:	46113423          	sd	ra,1128(sp)
    32ce:	46813023          	sd	s0,1120(sp)
    32d2:	44913c23          	sd	s1,1112(sp)
    32d6:	45213823          	sd	s2,1104(sp)
    32da:	45313423          	sd	s3,1096(sp)
    32de:	45413023          	sd	s4,1088(sp)
    32e2:	43513c23          	sd	s5,1080(sp)
    32e6:	43613823          	sd	s6,1072(sp)
    32ea:	43713423          	sd	s7,1064(sp)
    32ee:	43813023          	sd	s8,1056(sp)
    32f2:	47010413          	addi	s0,sp,1136
    32f6:	8c2a                	mv	s8,a0
  unlink("diskfulldir");
    32f8:	00004517          	auipc	a0,0x4
    32fc:	1f850513          	addi	a0,a0,504 # 74f0 <malloc+0x1326>
    3300:	00003097          	auipc	ra,0x3
    3304:	ac4080e7          	jalr	-1340(ra) # 5dc4 <unlink>
  for(fi = 0; done == 0; fi++){
    3308:	4a01                	li	s4,0
    name[0] = 'b';
    330a:	06200b13          	li	s6,98
    name[1] = 'i';
    330e:	06900a93          	li	s5,105
    name[2] = 'g';
    3312:	06700993          	li	s3,103
    3316:	10c00b93          	li	s7,268
    331a:	aabd                	j	3498 <diskfull+0x1d2>
      printf("%s: could not create file %s\n", s, name);
    331c:	b9040613          	addi	a2,s0,-1136
    3320:	85e2                	mv	a1,s8
    3322:	00004517          	auipc	a0,0x4
    3326:	1de50513          	addi	a0,a0,478 # 7500 <malloc+0x1336>
    332a:	00003097          	auipc	ra,0x3
    332e:	de2080e7          	jalr	-542(ra) # 610c <printf>
      break;
    3332:	a821                	j	334a <diskfull+0x84>
        close(fd);
    3334:	854a                	mv	a0,s2
    3336:	00003097          	auipc	ra,0x3
    333a:	a66080e7          	jalr	-1434(ra) # 5d9c <close>
    close(fd);
    333e:	854a                	mv	a0,s2
    3340:	00003097          	auipc	ra,0x3
    3344:	a5c080e7          	jalr	-1444(ra) # 5d9c <close>
  for(fi = 0; done == 0; fi++){
    3348:	2a05                	addiw	s4,s4,1
  for(int i = 0; i < nzz; i++){
    334a:	4481                	li	s1,0
    name[0] = 'z';
    334c:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    3350:	08000993          	li	s3,128
    name[0] = 'z';
    3354:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    3358:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    335c:	41f4d79b          	sraiw	a5,s1,0x1f
    3360:	01b7d71b          	srliw	a4,a5,0x1b
    3364:	009707bb          	addw	a5,a4,s1
    3368:	4057d69b          	sraiw	a3,a5,0x5
    336c:	0306869b          	addiw	a3,a3,48
    3370:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3374:	8bfd                	andi	a5,a5,31
    3376:	9f99                	subw	a5,a5,a4
    3378:	0307879b          	addiw	a5,a5,48
    337c:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3380:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3384:	bb040513          	addi	a0,s0,-1104
    3388:	00003097          	auipc	ra,0x3
    338c:	a3c080e7          	jalr	-1476(ra) # 5dc4 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    3390:	60200593          	li	a1,1538
    3394:	bb040513          	addi	a0,s0,-1104
    3398:	00003097          	auipc	ra,0x3
    339c:	a1c080e7          	jalr	-1508(ra) # 5db4 <open>
    if(fd < 0)
    33a0:	00054963          	bltz	a0,33b2 <diskfull+0xec>
    close(fd);
    33a4:	00003097          	auipc	ra,0x3
    33a8:	9f8080e7          	jalr	-1544(ra) # 5d9c <close>
  for(int i = 0; i < nzz; i++){
    33ac:	2485                	addiw	s1,s1,1
    33ae:	fb3493e3          	bne	s1,s3,3354 <diskfull+0x8e>
  if(mkdir("diskfulldir") == 0)
    33b2:	00004517          	auipc	a0,0x4
    33b6:	13e50513          	addi	a0,a0,318 # 74f0 <malloc+0x1326>
    33ba:	00003097          	auipc	ra,0x3
    33be:	a22080e7          	jalr	-1502(ra) # 5ddc <mkdir>
    33c2:	12050963          	beqz	a0,34f4 <diskfull+0x22e>
  unlink("diskfulldir");
    33c6:	00004517          	auipc	a0,0x4
    33ca:	12a50513          	addi	a0,a0,298 # 74f0 <malloc+0x1326>
    33ce:	00003097          	auipc	ra,0x3
    33d2:	9f6080e7          	jalr	-1546(ra) # 5dc4 <unlink>
  for(int i = 0; i < nzz; i++){
    33d6:	4481                	li	s1,0
    name[0] = 'z';
    33d8:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    33dc:	08000993          	li	s3,128
    name[0] = 'z';
    33e0:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    33e4:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    33e8:	41f4d79b          	sraiw	a5,s1,0x1f
    33ec:	01b7d71b          	srliw	a4,a5,0x1b
    33f0:	009707bb          	addw	a5,a4,s1
    33f4:	4057d69b          	sraiw	a3,a5,0x5
    33f8:	0306869b          	addiw	a3,a3,48
    33fc:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3400:	8bfd                	andi	a5,a5,31
    3402:	9f99                	subw	a5,a5,a4
    3404:	0307879b          	addiw	a5,a5,48
    3408:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    340c:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3410:	bb040513          	addi	a0,s0,-1104
    3414:	00003097          	auipc	ra,0x3
    3418:	9b0080e7          	jalr	-1616(ra) # 5dc4 <unlink>
  for(int i = 0; i < nzz; i++){
    341c:	2485                	addiw	s1,s1,1
    341e:	fd3491e3          	bne	s1,s3,33e0 <diskfull+0x11a>
  for(int i = 0; i < fi; i++){
    3422:	03405e63          	blez	s4,345e <diskfull+0x198>
    3426:	4481                	li	s1,0
    name[0] = 'b';
    3428:	06200a93          	li	s5,98
    name[1] = 'i';
    342c:	06900993          	li	s3,105
    name[2] = 'g';
    3430:	06700913          	li	s2,103
    name[0] = 'b';
    3434:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
    3438:	bb3408a3          	sb	s3,-1103(s0)
    name[2] = 'g';
    343c:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
    3440:	0304879b          	addiw	a5,s1,48
    3444:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3448:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    344c:	bb040513          	addi	a0,s0,-1104
    3450:	00003097          	auipc	ra,0x3
    3454:	974080e7          	jalr	-1676(ra) # 5dc4 <unlink>
  for(int i = 0; i < fi; i++){
    3458:	2485                	addiw	s1,s1,1
    345a:	fd449de3          	bne	s1,s4,3434 <diskfull+0x16e>
}
    345e:	46813083          	ld	ra,1128(sp)
    3462:	46013403          	ld	s0,1120(sp)
    3466:	45813483          	ld	s1,1112(sp)
    346a:	45013903          	ld	s2,1104(sp)
    346e:	44813983          	ld	s3,1096(sp)
    3472:	44013a03          	ld	s4,1088(sp)
    3476:	43813a83          	ld	s5,1080(sp)
    347a:	43013b03          	ld	s6,1072(sp)
    347e:	42813b83          	ld	s7,1064(sp)
    3482:	42013c03          	ld	s8,1056(sp)
    3486:	47010113          	addi	sp,sp,1136
    348a:	8082                	ret
    close(fd);
    348c:	854a                	mv	a0,s2
    348e:	00003097          	auipc	ra,0x3
    3492:	90e080e7          	jalr	-1778(ra) # 5d9c <close>
  for(fi = 0; done == 0; fi++){
    3496:	2a05                	addiw	s4,s4,1
    name[0] = 'b';
    3498:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    349c:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    34a0:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + fi;
    34a4:	030a079b          	addiw	a5,s4,48
    34a8:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    34ac:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    34b0:	b9040513          	addi	a0,s0,-1136
    34b4:	00003097          	auipc	ra,0x3
    34b8:	910080e7          	jalr	-1776(ra) # 5dc4 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    34bc:	60200593          	li	a1,1538
    34c0:	b9040513          	addi	a0,s0,-1136
    34c4:	00003097          	auipc	ra,0x3
    34c8:	8f0080e7          	jalr	-1808(ra) # 5db4 <open>
    34cc:	892a                	mv	s2,a0
    if(fd < 0){
    34ce:	e40547e3          	bltz	a0,331c <diskfull+0x56>
    34d2:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    34d4:	40000613          	li	a2,1024
    34d8:	bb040593          	addi	a1,s0,-1104
    34dc:	854a                	mv	a0,s2
    34de:	00003097          	auipc	ra,0x3
    34e2:	8b6080e7          	jalr	-1866(ra) # 5d94 <write>
    34e6:	40000793          	li	a5,1024
    34ea:	e4f515e3          	bne	a0,a5,3334 <diskfull+0x6e>
    for(int i = 0; i < MAXFILE; i++){
    34ee:	34fd                	addiw	s1,s1,-1
    34f0:	f0f5                	bnez	s1,34d4 <diskfull+0x20e>
    34f2:	bf69                	j	348c <diskfull+0x1c6>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    34f4:	00004517          	auipc	a0,0x4
    34f8:	02c50513          	addi	a0,a0,44 # 7520 <malloc+0x1356>
    34fc:	00003097          	auipc	ra,0x3
    3500:	c10080e7          	jalr	-1008(ra) # 610c <printf>
    3504:	b5c9                	j	33c6 <diskfull+0x100>

0000000000003506 <iputtest>:
{
    3506:	1101                	addi	sp,sp,-32
    3508:	ec06                	sd	ra,24(sp)
    350a:	e822                	sd	s0,16(sp)
    350c:	e426                	sd	s1,8(sp)
    350e:	1000                	addi	s0,sp,32
    3510:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    3512:	00004517          	auipc	a0,0x4
    3516:	03e50513          	addi	a0,a0,62 # 7550 <malloc+0x1386>
    351a:	00003097          	auipc	ra,0x3
    351e:	8c2080e7          	jalr	-1854(ra) # 5ddc <mkdir>
    3522:	04054563          	bltz	a0,356c <iputtest+0x66>
  if(chdir("iputdir") < 0){
    3526:	00004517          	auipc	a0,0x4
    352a:	02a50513          	addi	a0,a0,42 # 7550 <malloc+0x1386>
    352e:	00003097          	auipc	ra,0x3
    3532:	8b6080e7          	jalr	-1866(ra) # 5de4 <chdir>
    3536:	04054963          	bltz	a0,3588 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    353a:	00004517          	auipc	a0,0x4
    353e:	05650513          	addi	a0,a0,86 # 7590 <malloc+0x13c6>
    3542:	00003097          	auipc	ra,0x3
    3546:	882080e7          	jalr	-1918(ra) # 5dc4 <unlink>
    354a:	04054d63          	bltz	a0,35a4 <iputtest+0x9e>
  if(chdir("/") < 0){
    354e:	00004517          	auipc	a0,0x4
    3552:	07250513          	addi	a0,a0,114 # 75c0 <malloc+0x13f6>
    3556:	00003097          	auipc	ra,0x3
    355a:	88e080e7          	jalr	-1906(ra) # 5de4 <chdir>
    355e:	06054163          	bltz	a0,35c0 <iputtest+0xba>
}
    3562:	60e2                	ld	ra,24(sp)
    3564:	6442                	ld	s0,16(sp)
    3566:	64a2                	ld	s1,8(sp)
    3568:	6105                	addi	sp,sp,32
    356a:	8082                	ret
    printf("%s: mkdir failed\n", s);
    356c:	85a6                	mv	a1,s1
    356e:	00004517          	auipc	a0,0x4
    3572:	fea50513          	addi	a0,a0,-22 # 7558 <malloc+0x138e>
    3576:	00003097          	auipc	ra,0x3
    357a:	b96080e7          	jalr	-1130(ra) # 610c <printf>
    exit(1);
    357e:	4505                	li	a0,1
    3580:	00002097          	auipc	ra,0x2
    3584:	7ec080e7          	jalr	2028(ra) # 5d6c <exit>
    printf("%s: chdir iputdir failed\n", s);
    3588:	85a6                	mv	a1,s1
    358a:	00004517          	auipc	a0,0x4
    358e:	fe650513          	addi	a0,a0,-26 # 7570 <malloc+0x13a6>
    3592:	00003097          	auipc	ra,0x3
    3596:	b7a080e7          	jalr	-1158(ra) # 610c <printf>
    exit(1);
    359a:	4505                	li	a0,1
    359c:	00002097          	auipc	ra,0x2
    35a0:	7d0080e7          	jalr	2000(ra) # 5d6c <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    35a4:	85a6                	mv	a1,s1
    35a6:	00004517          	auipc	a0,0x4
    35aa:	ffa50513          	addi	a0,a0,-6 # 75a0 <malloc+0x13d6>
    35ae:	00003097          	auipc	ra,0x3
    35b2:	b5e080e7          	jalr	-1186(ra) # 610c <printf>
    exit(1);
    35b6:	4505                	li	a0,1
    35b8:	00002097          	auipc	ra,0x2
    35bc:	7b4080e7          	jalr	1972(ra) # 5d6c <exit>
    printf("%s: chdir / failed\n", s);
    35c0:	85a6                	mv	a1,s1
    35c2:	00004517          	auipc	a0,0x4
    35c6:	00650513          	addi	a0,a0,6 # 75c8 <malloc+0x13fe>
    35ca:	00003097          	auipc	ra,0x3
    35ce:	b42080e7          	jalr	-1214(ra) # 610c <printf>
    exit(1);
    35d2:	4505                	li	a0,1
    35d4:	00002097          	auipc	ra,0x2
    35d8:	798080e7          	jalr	1944(ra) # 5d6c <exit>

00000000000035dc <exitiputtest>:
{
    35dc:	7179                	addi	sp,sp,-48
    35de:	f406                	sd	ra,40(sp)
    35e0:	f022                	sd	s0,32(sp)
    35e2:	ec26                	sd	s1,24(sp)
    35e4:	1800                	addi	s0,sp,48
    35e6:	84aa                	mv	s1,a0
  pid = fork();
    35e8:	00002097          	auipc	ra,0x2
    35ec:	77c080e7          	jalr	1916(ra) # 5d64 <fork>
  if(pid < 0){
    35f0:	04054663          	bltz	a0,363c <exitiputtest+0x60>
  if(pid == 0){
    35f4:	ed45                	bnez	a0,36ac <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    35f6:	00004517          	auipc	a0,0x4
    35fa:	f5a50513          	addi	a0,a0,-166 # 7550 <malloc+0x1386>
    35fe:	00002097          	auipc	ra,0x2
    3602:	7de080e7          	jalr	2014(ra) # 5ddc <mkdir>
    3606:	04054963          	bltz	a0,3658 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    360a:	00004517          	auipc	a0,0x4
    360e:	f4650513          	addi	a0,a0,-186 # 7550 <malloc+0x1386>
    3612:	00002097          	auipc	ra,0x2
    3616:	7d2080e7          	jalr	2002(ra) # 5de4 <chdir>
    361a:	04054d63          	bltz	a0,3674 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    361e:	00004517          	auipc	a0,0x4
    3622:	f7250513          	addi	a0,a0,-142 # 7590 <malloc+0x13c6>
    3626:	00002097          	auipc	ra,0x2
    362a:	79e080e7          	jalr	1950(ra) # 5dc4 <unlink>
    362e:	06054163          	bltz	a0,3690 <exitiputtest+0xb4>
    exit(0);
    3632:	4501                	li	a0,0
    3634:	00002097          	auipc	ra,0x2
    3638:	738080e7          	jalr	1848(ra) # 5d6c <exit>
    printf("%s: fork failed\n", s);
    363c:	85a6                	mv	a1,s1
    363e:	00003517          	auipc	a0,0x3
    3642:	55250513          	addi	a0,a0,1362 # 6b90 <malloc+0x9c6>
    3646:	00003097          	auipc	ra,0x3
    364a:	ac6080e7          	jalr	-1338(ra) # 610c <printf>
    exit(1);
    364e:	4505                	li	a0,1
    3650:	00002097          	auipc	ra,0x2
    3654:	71c080e7          	jalr	1820(ra) # 5d6c <exit>
      printf("%s: mkdir failed\n", s);
    3658:	85a6                	mv	a1,s1
    365a:	00004517          	auipc	a0,0x4
    365e:	efe50513          	addi	a0,a0,-258 # 7558 <malloc+0x138e>
    3662:	00003097          	auipc	ra,0x3
    3666:	aaa080e7          	jalr	-1366(ra) # 610c <printf>
      exit(1);
    366a:	4505                	li	a0,1
    366c:	00002097          	auipc	ra,0x2
    3670:	700080e7          	jalr	1792(ra) # 5d6c <exit>
      printf("%s: child chdir failed\n", s);
    3674:	85a6                	mv	a1,s1
    3676:	00004517          	auipc	a0,0x4
    367a:	f6a50513          	addi	a0,a0,-150 # 75e0 <malloc+0x1416>
    367e:	00003097          	auipc	ra,0x3
    3682:	a8e080e7          	jalr	-1394(ra) # 610c <printf>
      exit(1);
    3686:	4505                	li	a0,1
    3688:	00002097          	auipc	ra,0x2
    368c:	6e4080e7          	jalr	1764(ra) # 5d6c <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    3690:	85a6                	mv	a1,s1
    3692:	00004517          	auipc	a0,0x4
    3696:	f0e50513          	addi	a0,a0,-242 # 75a0 <malloc+0x13d6>
    369a:	00003097          	auipc	ra,0x3
    369e:	a72080e7          	jalr	-1422(ra) # 610c <printf>
      exit(1);
    36a2:	4505                	li	a0,1
    36a4:	00002097          	auipc	ra,0x2
    36a8:	6c8080e7          	jalr	1736(ra) # 5d6c <exit>
  wait(&xstatus,"");
    36ac:	00004597          	auipc	a1,0x4
    36b0:	24c58593          	addi	a1,a1,588 # 78f8 <malloc+0x172e>
    36b4:	fdc40513          	addi	a0,s0,-36
    36b8:	00002097          	auipc	ra,0x2
    36bc:	6c4080e7          	jalr	1732(ra) # 5d7c <wait>
  exit(xstatus);
    36c0:	fdc42503          	lw	a0,-36(s0)
    36c4:	00002097          	auipc	ra,0x2
    36c8:	6a8080e7          	jalr	1704(ra) # 5d6c <exit>

00000000000036cc <dirtest>:
{
    36cc:	1101                	addi	sp,sp,-32
    36ce:	ec06                	sd	ra,24(sp)
    36d0:	e822                	sd	s0,16(sp)
    36d2:	e426                	sd	s1,8(sp)
    36d4:	1000                	addi	s0,sp,32
    36d6:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    36d8:	00004517          	auipc	a0,0x4
    36dc:	f2050513          	addi	a0,a0,-224 # 75f8 <malloc+0x142e>
    36e0:	00002097          	auipc	ra,0x2
    36e4:	6fc080e7          	jalr	1788(ra) # 5ddc <mkdir>
    36e8:	04054563          	bltz	a0,3732 <dirtest+0x66>
  if(chdir("dir0") < 0){
    36ec:	00004517          	auipc	a0,0x4
    36f0:	f0c50513          	addi	a0,a0,-244 # 75f8 <malloc+0x142e>
    36f4:	00002097          	auipc	ra,0x2
    36f8:	6f0080e7          	jalr	1776(ra) # 5de4 <chdir>
    36fc:	04054963          	bltz	a0,374e <dirtest+0x82>
  if(chdir("..") < 0){
    3700:	00004517          	auipc	a0,0x4
    3704:	f1850513          	addi	a0,a0,-232 # 7618 <malloc+0x144e>
    3708:	00002097          	auipc	ra,0x2
    370c:	6dc080e7          	jalr	1756(ra) # 5de4 <chdir>
    3710:	04054d63          	bltz	a0,376a <dirtest+0x9e>
  if(unlink("dir0") < 0){
    3714:	00004517          	auipc	a0,0x4
    3718:	ee450513          	addi	a0,a0,-284 # 75f8 <malloc+0x142e>
    371c:	00002097          	auipc	ra,0x2
    3720:	6a8080e7          	jalr	1704(ra) # 5dc4 <unlink>
    3724:	06054163          	bltz	a0,3786 <dirtest+0xba>
}
    3728:	60e2                	ld	ra,24(sp)
    372a:	6442                	ld	s0,16(sp)
    372c:	64a2                	ld	s1,8(sp)
    372e:	6105                	addi	sp,sp,32
    3730:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3732:	85a6                	mv	a1,s1
    3734:	00004517          	auipc	a0,0x4
    3738:	e2450513          	addi	a0,a0,-476 # 7558 <malloc+0x138e>
    373c:	00003097          	auipc	ra,0x3
    3740:	9d0080e7          	jalr	-1584(ra) # 610c <printf>
    exit(1);
    3744:	4505                	li	a0,1
    3746:	00002097          	auipc	ra,0x2
    374a:	626080e7          	jalr	1574(ra) # 5d6c <exit>
    printf("%s: chdir dir0 failed\n", s);
    374e:	85a6                	mv	a1,s1
    3750:	00004517          	auipc	a0,0x4
    3754:	eb050513          	addi	a0,a0,-336 # 7600 <malloc+0x1436>
    3758:	00003097          	auipc	ra,0x3
    375c:	9b4080e7          	jalr	-1612(ra) # 610c <printf>
    exit(1);
    3760:	4505                	li	a0,1
    3762:	00002097          	auipc	ra,0x2
    3766:	60a080e7          	jalr	1546(ra) # 5d6c <exit>
    printf("%s: chdir .. failed\n", s);
    376a:	85a6                	mv	a1,s1
    376c:	00004517          	auipc	a0,0x4
    3770:	eb450513          	addi	a0,a0,-332 # 7620 <malloc+0x1456>
    3774:	00003097          	auipc	ra,0x3
    3778:	998080e7          	jalr	-1640(ra) # 610c <printf>
    exit(1);
    377c:	4505                	li	a0,1
    377e:	00002097          	auipc	ra,0x2
    3782:	5ee080e7          	jalr	1518(ra) # 5d6c <exit>
    printf("%s: unlink dir0 failed\n", s);
    3786:	85a6                	mv	a1,s1
    3788:	00004517          	auipc	a0,0x4
    378c:	eb050513          	addi	a0,a0,-336 # 7638 <malloc+0x146e>
    3790:	00003097          	auipc	ra,0x3
    3794:	97c080e7          	jalr	-1668(ra) # 610c <printf>
    exit(1);
    3798:	4505                	li	a0,1
    379a:	00002097          	auipc	ra,0x2
    379e:	5d2080e7          	jalr	1490(ra) # 5d6c <exit>

00000000000037a2 <subdir>:
{
    37a2:	1101                	addi	sp,sp,-32
    37a4:	ec06                	sd	ra,24(sp)
    37a6:	e822                	sd	s0,16(sp)
    37a8:	e426                	sd	s1,8(sp)
    37aa:	e04a                	sd	s2,0(sp)
    37ac:	1000                	addi	s0,sp,32
    37ae:	892a                	mv	s2,a0
  unlink("ff");
    37b0:	00004517          	auipc	a0,0x4
    37b4:	fd050513          	addi	a0,a0,-48 # 7780 <malloc+0x15b6>
    37b8:	00002097          	auipc	ra,0x2
    37bc:	60c080e7          	jalr	1548(ra) # 5dc4 <unlink>
  if(mkdir("dd") != 0){
    37c0:	00004517          	auipc	a0,0x4
    37c4:	e9050513          	addi	a0,a0,-368 # 7650 <malloc+0x1486>
    37c8:	00002097          	auipc	ra,0x2
    37cc:	614080e7          	jalr	1556(ra) # 5ddc <mkdir>
    37d0:	38051663          	bnez	a0,3b5c <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    37d4:	20200593          	li	a1,514
    37d8:	00004517          	auipc	a0,0x4
    37dc:	e9850513          	addi	a0,a0,-360 # 7670 <malloc+0x14a6>
    37e0:	00002097          	auipc	ra,0x2
    37e4:	5d4080e7          	jalr	1492(ra) # 5db4 <open>
    37e8:	84aa                	mv	s1,a0
  if(fd < 0){
    37ea:	38054763          	bltz	a0,3b78 <subdir+0x3d6>
  write(fd, "ff", 2);
    37ee:	4609                	li	a2,2
    37f0:	00004597          	auipc	a1,0x4
    37f4:	f9058593          	addi	a1,a1,-112 # 7780 <malloc+0x15b6>
    37f8:	00002097          	auipc	ra,0x2
    37fc:	59c080e7          	jalr	1436(ra) # 5d94 <write>
  close(fd);
    3800:	8526                	mv	a0,s1
    3802:	00002097          	auipc	ra,0x2
    3806:	59a080e7          	jalr	1434(ra) # 5d9c <close>
  if(unlink("dd") >= 0){
    380a:	00004517          	auipc	a0,0x4
    380e:	e4650513          	addi	a0,a0,-442 # 7650 <malloc+0x1486>
    3812:	00002097          	auipc	ra,0x2
    3816:	5b2080e7          	jalr	1458(ra) # 5dc4 <unlink>
    381a:	36055d63          	bgez	a0,3b94 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    381e:	00004517          	auipc	a0,0x4
    3822:	eaa50513          	addi	a0,a0,-342 # 76c8 <malloc+0x14fe>
    3826:	00002097          	auipc	ra,0x2
    382a:	5b6080e7          	jalr	1462(ra) # 5ddc <mkdir>
    382e:	38051163          	bnez	a0,3bb0 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    3832:	20200593          	li	a1,514
    3836:	00004517          	auipc	a0,0x4
    383a:	eba50513          	addi	a0,a0,-326 # 76f0 <malloc+0x1526>
    383e:	00002097          	auipc	ra,0x2
    3842:	576080e7          	jalr	1398(ra) # 5db4 <open>
    3846:	84aa                	mv	s1,a0
  if(fd < 0){
    3848:	38054263          	bltz	a0,3bcc <subdir+0x42a>
  write(fd, "FF", 2);
    384c:	4609                	li	a2,2
    384e:	00004597          	auipc	a1,0x4
    3852:	ed258593          	addi	a1,a1,-302 # 7720 <malloc+0x1556>
    3856:	00002097          	auipc	ra,0x2
    385a:	53e080e7          	jalr	1342(ra) # 5d94 <write>
  close(fd);
    385e:	8526                	mv	a0,s1
    3860:	00002097          	auipc	ra,0x2
    3864:	53c080e7          	jalr	1340(ra) # 5d9c <close>
  fd = open("dd/dd/../ff", 0);
    3868:	4581                	li	a1,0
    386a:	00004517          	auipc	a0,0x4
    386e:	ebe50513          	addi	a0,a0,-322 # 7728 <malloc+0x155e>
    3872:	00002097          	auipc	ra,0x2
    3876:	542080e7          	jalr	1346(ra) # 5db4 <open>
    387a:	84aa                	mv	s1,a0
  if(fd < 0){
    387c:	36054663          	bltz	a0,3be8 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3880:	660d                	lui	a2,0x3
    3882:	00009597          	auipc	a1,0x9
    3886:	3f658593          	addi	a1,a1,1014 # cc78 <buf>
    388a:	00002097          	auipc	ra,0x2
    388e:	502080e7          	jalr	1282(ra) # 5d8c <read>
  if(cc != 2 || buf[0] != 'f'){
    3892:	4789                	li	a5,2
    3894:	36f51863          	bne	a0,a5,3c04 <subdir+0x462>
    3898:	00009717          	auipc	a4,0x9
    389c:	3e074703          	lbu	a4,992(a4) # cc78 <buf>
    38a0:	06600793          	li	a5,102
    38a4:	36f71063          	bne	a4,a5,3c04 <subdir+0x462>
  close(fd);
    38a8:	8526                	mv	a0,s1
    38aa:	00002097          	auipc	ra,0x2
    38ae:	4f2080e7          	jalr	1266(ra) # 5d9c <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    38b2:	00004597          	auipc	a1,0x4
    38b6:	ec658593          	addi	a1,a1,-314 # 7778 <malloc+0x15ae>
    38ba:	00004517          	auipc	a0,0x4
    38be:	e3650513          	addi	a0,a0,-458 # 76f0 <malloc+0x1526>
    38c2:	00002097          	auipc	ra,0x2
    38c6:	512080e7          	jalr	1298(ra) # 5dd4 <link>
    38ca:	34051b63          	bnez	a0,3c20 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    38ce:	00004517          	auipc	a0,0x4
    38d2:	e2250513          	addi	a0,a0,-478 # 76f0 <malloc+0x1526>
    38d6:	00002097          	auipc	ra,0x2
    38da:	4ee080e7          	jalr	1262(ra) # 5dc4 <unlink>
    38de:	34051f63          	bnez	a0,3c3c <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    38e2:	4581                	li	a1,0
    38e4:	00004517          	auipc	a0,0x4
    38e8:	e0c50513          	addi	a0,a0,-500 # 76f0 <malloc+0x1526>
    38ec:	00002097          	auipc	ra,0x2
    38f0:	4c8080e7          	jalr	1224(ra) # 5db4 <open>
    38f4:	36055263          	bgez	a0,3c58 <subdir+0x4b6>
  if(chdir("dd") != 0){
    38f8:	00004517          	auipc	a0,0x4
    38fc:	d5850513          	addi	a0,a0,-680 # 7650 <malloc+0x1486>
    3900:	00002097          	auipc	ra,0x2
    3904:	4e4080e7          	jalr	1252(ra) # 5de4 <chdir>
    3908:	36051663          	bnez	a0,3c74 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    390c:	00004517          	auipc	a0,0x4
    3910:	f0450513          	addi	a0,a0,-252 # 7810 <malloc+0x1646>
    3914:	00002097          	auipc	ra,0x2
    3918:	4d0080e7          	jalr	1232(ra) # 5de4 <chdir>
    391c:	36051a63          	bnez	a0,3c90 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    3920:	00004517          	auipc	a0,0x4
    3924:	f2050513          	addi	a0,a0,-224 # 7840 <malloc+0x1676>
    3928:	00002097          	auipc	ra,0x2
    392c:	4bc080e7          	jalr	1212(ra) # 5de4 <chdir>
    3930:	36051e63          	bnez	a0,3cac <subdir+0x50a>
  if(chdir("./..") != 0){
    3934:	00004517          	auipc	a0,0x4
    3938:	f3c50513          	addi	a0,a0,-196 # 7870 <malloc+0x16a6>
    393c:	00002097          	auipc	ra,0x2
    3940:	4a8080e7          	jalr	1192(ra) # 5de4 <chdir>
    3944:	38051263          	bnez	a0,3cc8 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    3948:	4581                	li	a1,0
    394a:	00004517          	auipc	a0,0x4
    394e:	e2e50513          	addi	a0,a0,-466 # 7778 <malloc+0x15ae>
    3952:	00002097          	auipc	ra,0x2
    3956:	462080e7          	jalr	1122(ra) # 5db4 <open>
    395a:	84aa                	mv	s1,a0
  if(fd < 0){
    395c:	38054463          	bltz	a0,3ce4 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3960:	660d                	lui	a2,0x3
    3962:	00009597          	auipc	a1,0x9
    3966:	31658593          	addi	a1,a1,790 # cc78 <buf>
    396a:	00002097          	auipc	ra,0x2
    396e:	422080e7          	jalr	1058(ra) # 5d8c <read>
    3972:	4789                	li	a5,2
    3974:	38f51663          	bne	a0,a5,3d00 <subdir+0x55e>
  close(fd);
    3978:	8526                	mv	a0,s1
    397a:	00002097          	auipc	ra,0x2
    397e:	422080e7          	jalr	1058(ra) # 5d9c <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3982:	4581                	li	a1,0
    3984:	00004517          	auipc	a0,0x4
    3988:	d6c50513          	addi	a0,a0,-660 # 76f0 <malloc+0x1526>
    398c:	00002097          	auipc	ra,0x2
    3990:	428080e7          	jalr	1064(ra) # 5db4 <open>
    3994:	38055463          	bgez	a0,3d1c <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3998:	20200593          	li	a1,514
    399c:	00004517          	auipc	a0,0x4
    39a0:	f6450513          	addi	a0,a0,-156 # 7900 <malloc+0x1736>
    39a4:	00002097          	auipc	ra,0x2
    39a8:	410080e7          	jalr	1040(ra) # 5db4 <open>
    39ac:	38055663          	bgez	a0,3d38 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    39b0:	20200593          	li	a1,514
    39b4:	00004517          	auipc	a0,0x4
    39b8:	f7c50513          	addi	a0,a0,-132 # 7930 <malloc+0x1766>
    39bc:	00002097          	auipc	ra,0x2
    39c0:	3f8080e7          	jalr	1016(ra) # 5db4 <open>
    39c4:	38055863          	bgez	a0,3d54 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    39c8:	20000593          	li	a1,512
    39cc:	00004517          	auipc	a0,0x4
    39d0:	c8450513          	addi	a0,a0,-892 # 7650 <malloc+0x1486>
    39d4:	00002097          	auipc	ra,0x2
    39d8:	3e0080e7          	jalr	992(ra) # 5db4 <open>
    39dc:	38055a63          	bgez	a0,3d70 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    39e0:	4589                	li	a1,2
    39e2:	00004517          	auipc	a0,0x4
    39e6:	c6e50513          	addi	a0,a0,-914 # 7650 <malloc+0x1486>
    39ea:	00002097          	auipc	ra,0x2
    39ee:	3ca080e7          	jalr	970(ra) # 5db4 <open>
    39f2:	38055d63          	bgez	a0,3d8c <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    39f6:	4585                	li	a1,1
    39f8:	00004517          	auipc	a0,0x4
    39fc:	c5850513          	addi	a0,a0,-936 # 7650 <malloc+0x1486>
    3a00:	00002097          	auipc	ra,0x2
    3a04:	3b4080e7          	jalr	948(ra) # 5db4 <open>
    3a08:	3a055063          	bgez	a0,3da8 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3a0c:	00004597          	auipc	a1,0x4
    3a10:	fb458593          	addi	a1,a1,-76 # 79c0 <malloc+0x17f6>
    3a14:	00004517          	auipc	a0,0x4
    3a18:	eec50513          	addi	a0,a0,-276 # 7900 <malloc+0x1736>
    3a1c:	00002097          	auipc	ra,0x2
    3a20:	3b8080e7          	jalr	952(ra) # 5dd4 <link>
    3a24:	3a050063          	beqz	a0,3dc4 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3a28:	00004597          	auipc	a1,0x4
    3a2c:	f9858593          	addi	a1,a1,-104 # 79c0 <malloc+0x17f6>
    3a30:	00004517          	auipc	a0,0x4
    3a34:	f0050513          	addi	a0,a0,-256 # 7930 <malloc+0x1766>
    3a38:	00002097          	auipc	ra,0x2
    3a3c:	39c080e7          	jalr	924(ra) # 5dd4 <link>
    3a40:	3a050063          	beqz	a0,3de0 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3a44:	00004597          	auipc	a1,0x4
    3a48:	d3458593          	addi	a1,a1,-716 # 7778 <malloc+0x15ae>
    3a4c:	00004517          	auipc	a0,0x4
    3a50:	c2450513          	addi	a0,a0,-988 # 7670 <malloc+0x14a6>
    3a54:	00002097          	auipc	ra,0x2
    3a58:	380080e7          	jalr	896(ra) # 5dd4 <link>
    3a5c:	3a050063          	beqz	a0,3dfc <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3a60:	00004517          	auipc	a0,0x4
    3a64:	ea050513          	addi	a0,a0,-352 # 7900 <malloc+0x1736>
    3a68:	00002097          	auipc	ra,0x2
    3a6c:	374080e7          	jalr	884(ra) # 5ddc <mkdir>
    3a70:	3a050463          	beqz	a0,3e18 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3a74:	00004517          	auipc	a0,0x4
    3a78:	ebc50513          	addi	a0,a0,-324 # 7930 <malloc+0x1766>
    3a7c:	00002097          	auipc	ra,0x2
    3a80:	360080e7          	jalr	864(ra) # 5ddc <mkdir>
    3a84:	3a050863          	beqz	a0,3e34 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3a88:	00004517          	auipc	a0,0x4
    3a8c:	cf050513          	addi	a0,a0,-784 # 7778 <malloc+0x15ae>
    3a90:	00002097          	auipc	ra,0x2
    3a94:	34c080e7          	jalr	844(ra) # 5ddc <mkdir>
    3a98:	3a050c63          	beqz	a0,3e50 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3a9c:	00004517          	auipc	a0,0x4
    3aa0:	e9450513          	addi	a0,a0,-364 # 7930 <malloc+0x1766>
    3aa4:	00002097          	auipc	ra,0x2
    3aa8:	320080e7          	jalr	800(ra) # 5dc4 <unlink>
    3aac:	3c050063          	beqz	a0,3e6c <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3ab0:	00004517          	auipc	a0,0x4
    3ab4:	e5050513          	addi	a0,a0,-432 # 7900 <malloc+0x1736>
    3ab8:	00002097          	auipc	ra,0x2
    3abc:	30c080e7          	jalr	780(ra) # 5dc4 <unlink>
    3ac0:	3c050463          	beqz	a0,3e88 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3ac4:	00004517          	auipc	a0,0x4
    3ac8:	bac50513          	addi	a0,a0,-1108 # 7670 <malloc+0x14a6>
    3acc:	00002097          	auipc	ra,0x2
    3ad0:	318080e7          	jalr	792(ra) # 5de4 <chdir>
    3ad4:	3c050863          	beqz	a0,3ea4 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3ad8:	00004517          	auipc	a0,0x4
    3adc:	03850513          	addi	a0,a0,56 # 7b10 <malloc+0x1946>
    3ae0:	00002097          	auipc	ra,0x2
    3ae4:	304080e7          	jalr	772(ra) # 5de4 <chdir>
    3ae8:	3c050c63          	beqz	a0,3ec0 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3aec:	00004517          	auipc	a0,0x4
    3af0:	c8c50513          	addi	a0,a0,-884 # 7778 <malloc+0x15ae>
    3af4:	00002097          	auipc	ra,0x2
    3af8:	2d0080e7          	jalr	720(ra) # 5dc4 <unlink>
    3afc:	3e051063          	bnez	a0,3edc <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    3b00:	00004517          	auipc	a0,0x4
    3b04:	b7050513          	addi	a0,a0,-1168 # 7670 <malloc+0x14a6>
    3b08:	00002097          	auipc	ra,0x2
    3b0c:	2bc080e7          	jalr	700(ra) # 5dc4 <unlink>
    3b10:	3e051463          	bnez	a0,3ef8 <subdir+0x756>
  if(unlink("dd") == 0){
    3b14:	00004517          	auipc	a0,0x4
    3b18:	b3c50513          	addi	a0,a0,-1220 # 7650 <malloc+0x1486>
    3b1c:	00002097          	auipc	ra,0x2
    3b20:	2a8080e7          	jalr	680(ra) # 5dc4 <unlink>
    3b24:	3e050863          	beqz	a0,3f14 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3b28:	00004517          	auipc	a0,0x4
    3b2c:	05850513          	addi	a0,a0,88 # 7b80 <malloc+0x19b6>
    3b30:	00002097          	auipc	ra,0x2
    3b34:	294080e7          	jalr	660(ra) # 5dc4 <unlink>
    3b38:	3e054c63          	bltz	a0,3f30 <subdir+0x78e>
  if(unlink("dd") < 0){
    3b3c:	00004517          	auipc	a0,0x4
    3b40:	b1450513          	addi	a0,a0,-1260 # 7650 <malloc+0x1486>
    3b44:	00002097          	auipc	ra,0x2
    3b48:	280080e7          	jalr	640(ra) # 5dc4 <unlink>
    3b4c:	40054063          	bltz	a0,3f4c <subdir+0x7aa>
}
    3b50:	60e2                	ld	ra,24(sp)
    3b52:	6442                	ld	s0,16(sp)
    3b54:	64a2                	ld	s1,8(sp)
    3b56:	6902                	ld	s2,0(sp)
    3b58:	6105                	addi	sp,sp,32
    3b5a:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3b5c:	85ca                	mv	a1,s2
    3b5e:	00004517          	auipc	a0,0x4
    3b62:	afa50513          	addi	a0,a0,-1286 # 7658 <malloc+0x148e>
    3b66:	00002097          	auipc	ra,0x2
    3b6a:	5a6080e7          	jalr	1446(ra) # 610c <printf>
    exit(1);
    3b6e:	4505                	li	a0,1
    3b70:	00002097          	auipc	ra,0x2
    3b74:	1fc080e7          	jalr	508(ra) # 5d6c <exit>
    printf("%s: create dd/ff failed\n", s);
    3b78:	85ca                	mv	a1,s2
    3b7a:	00004517          	auipc	a0,0x4
    3b7e:	afe50513          	addi	a0,a0,-1282 # 7678 <malloc+0x14ae>
    3b82:	00002097          	auipc	ra,0x2
    3b86:	58a080e7          	jalr	1418(ra) # 610c <printf>
    exit(1);
    3b8a:	4505                	li	a0,1
    3b8c:	00002097          	auipc	ra,0x2
    3b90:	1e0080e7          	jalr	480(ra) # 5d6c <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3b94:	85ca                	mv	a1,s2
    3b96:	00004517          	auipc	a0,0x4
    3b9a:	b0250513          	addi	a0,a0,-1278 # 7698 <malloc+0x14ce>
    3b9e:	00002097          	auipc	ra,0x2
    3ba2:	56e080e7          	jalr	1390(ra) # 610c <printf>
    exit(1);
    3ba6:	4505                	li	a0,1
    3ba8:	00002097          	auipc	ra,0x2
    3bac:	1c4080e7          	jalr	452(ra) # 5d6c <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3bb0:	85ca                	mv	a1,s2
    3bb2:	00004517          	auipc	a0,0x4
    3bb6:	b1e50513          	addi	a0,a0,-1250 # 76d0 <malloc+0x1506>
    3bba:	00002097          	auipc	ra,0x2
    3bbe:	552080e7          	jalr	1362(ra) # 610c <printf>
    exit(1);
    3bc2:	4505                	li	a0,1
    3bc4:	00002097          	auipc	ra,0x2
    3bc8:	1a8080e7          	jalr	424(ra) # 5d6c <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3bcc:	85ca                	mv	a1,s2
    3bce:	00004517          	auipc	a0,0x4
    3bd2:	b3250513          	addi	a0,a0,-1230 # 7700 <malloc+0x1536>
    3bd6:	00002097          	auipc	ra,0x2
    3bda:	536080e7          	jalr	1334(ra) # 610c <printf>
    exit(1);
    3bde:	4505                	li	a0,1
    3be0:	00002097          	auipc	ra,0x2
    3be4:	18c080e7          	jalr	396(ra) # 5d6c <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3be8:	85ca                	mv	a1,s2
    3bea:	00004517          	auipc	a0,0x4
    3bee:	b4e50513          	addi	a0,a0,-1202 # 7738 <malloc+0x156e>
    3bf2:	00002097          	auipc	ra,0x2
    3bf6:	51a080e7          	jalr	1306(ra) # 610c <printf>
    exit(1);
    3bfa:	4505                	li	a0,1
    3bfc:	00002097          	auipc	ra,0x2
    3c00:	170080e7          	jalr	368(ra) # 5d6c <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3c04:	85ca                	mv	a1,s2
    3c06:	00004517          	auipc	a0,0x4
    3c0a:	b5250513          	addi	a0,a0,-1198 # 7758 <malloc+0x158e>
    3c0e:	00002097          	auipc	ra,0x2
    3c12:	4fe080e7          	jalr	1278(ra) # 610c <printf>
    exit(1);
    3c16:	4505                	li	a0,1
    3c18:	00002097          	auipc	ra,0x2
    3c1c:	154080e7          	jalr	340(ra) # 5d6c <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3c20:	85ca                	mv	a1,s2
    3c22:	00004517          	auipc	a0,0x4
    3c26:	b6650513          	addi	a0,a0,-1178 # 7788 <malloc+0x15be>
    3c2a:	00002097          	auipc	ra,0x2
    3c2e:	4e2080e7          	jalr	1250(ra) # 610c <printf>
    exit(1);
    3c32:	4505                	li	a0,1
    3c34:	00002097          	auipc	ra,0x2
    3c38:	138080e7          	jalr	312(ra) # 5d6c <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3c3c:	85ca                	mv	a1,s2
    3c3e:	00004517          	auipc	a0,0x4
    3c42:	b7250513          	addi	a0,a0,-1166 # 77b0 <malloc+0x15e6>
    3c46:	00002097          	auipc	ra,0x2
    3c4a:	4c6080e7          	jalr	1222(ra) # 610c <printf>
    exit(1);
    3c4e:	4505                	li	a0,1
    3c50:	00002097          	auipc	ra,0x2
    3c54:	11c080e7          	jalr	284(ra) # 5d6c <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3c58:	85ca                	mv	a1,s2
    3c5a:	00004517          	auipc	a0,0x4
    3c5e:	b7650513          	addi	a0,a0,-1162 # 77d0 <malloc+0x1606>
    3c62:	00002097          	auipc	ra,0x2
    3c66:	4aa080e7          	jalr	1194(ra) # 610c <printf>
    exit(1);
    3c6a:	4505                	li	a0,1
    3c6c:	00002097          	auipc	ra,0x2
    3c70:	100080e7          	jalr	256(ra) # 5d6c <exit>
    printf("%s: chdir dd failed\n", s);
    3c74:	85ca                	mv	a1,s2
    3c76:	00004517          	auipc	a0,0x4
    3c7a:	b8250513          	addi	a0,a0,-1150 # 77f8 <malloc+0x162e>
    3c7e:	00002097          	auipc	ra,0x2
    3c82:	48e080e7          	jalr	1166(ra) # 610c <printf>
    exit(1);
    3c86:	4505                	li	a0,1
    3c88:	00002097          	auipc	ra,0x2
    3c8c:	0e4080e7          	jalr	228(ra) # 5d6c <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3c90:	85ca                	mv	a1,s2
    3c92:	00004517          	auipc	a0,0x4
    3c96:	b8e50513          	addi	a0,a0,-1138 # 7820 <malloc+0x1656>
    3c9a:	00002097          	auipc	ra,0x2
    3c9e:	472080e7          	jalr	1138(ra) # 610c <printf>
    exit(1);
    3ca2:	4505                	li	a0,1
    3ca4:	00002097          	auipc	ra,0x2
    3ca8:	0c8080e7          	jalr	200(ra) # 5d6c <exit>
    printf("chdir dd/../../dd failed\n", s);
    3cac:	85ca                	mv	a1,s2
    3cae:	00004517          	auipc	a0,0x4
    3cb2:	ba250513          	addi	a0,a0,-1118 # 7850 <malloc+0x1686>
    3cb6:	00002097          	auipc	ra,0x2
    3cba:	456080e7          	jalr	1110(ra) # 610c <printf>
    exit(1);
    3cbe:	4505                	li	a0,1
    3cc0:	00002097          	auipc	ra,0x2
    3cc4:	0ac080e7          	jalr	172(ra) # 5d6c <exit>
    printf("%s: chdir ./.. failed\n", s);
    3cc8:	85ca                	mv	a1,s2
    3cca:	00004517          	auipc	a0,0x4
    3cce:	bae50513          	addi	a0,a0,-1106 # 7878 <malloc+0x16ae>
    3cd2:	00002097          	auipc	ra,0x2
    3cd6:	43a080e7          	jalr	1082(ra) # 610c <printf>
    exit(1);
    3cda:	4505                	li	a0,1
    3cdc:	00002097          	auipc	ra,0x2
    3ce0:	090080e7          	jalr	144(ra) # 5d6c <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3ce4:	85ca                	mv	a1,s2
    3ce6:	00004517          	auipc	a0,0x4
    3cea:	baa50513          	addi	a0,a0,-1110 # 7890 <malloc+0x16c6>
    3cee:	00002097          	auipc	ra,0x2
    3cf2:	41e080e7          	jalr	1054(ra) # 610c <printf>
    exit(1);
    3cf6:	4505                	li	a0,1
    3cf8:	00002097          	auipc	ra,0x2
    3cfc:	074080e7          	jalr	116(ra) # 5d6c <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3d00:	85ca                	mv	a1,s2
    3d02:	00004517          	auipc	a0,0x4
    3d06:	bae50513          	addi	a0,a0,-1106 # 78b0 <malloc+0x16e6>
    3d0a:	00002097          	auipc	ra,0x2
    3d0e:	402080e7          	jalr	1026(ra) # 610c <printf>
    exit(1);
    3d12:	4505                	li	a0,1
    3d14:	00002097          	auipc	ra,0x2
    3d18:	058080e7          	jalr	88(ra) # 5d6c <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3d1c:	85ca                	mv	a1,s2
    3d1e:	00004517          	auipc	a0,0x4
    3d22:	bb250513          	addi	a0,a0,-1102 # 78d0 <malloc+0x1706>
    3d26:	00002097          	auipc	ra,0x2
    3d2a:	3e6080e7          	jalr	998(ra) # 610c <printf>
    exit(1);
    3d2e:	4505                	li	a0,1
    3d30:	00002097          	auipc	ra,0x2
    3d34:	03c080e7          	jalr	60(ra) # 5d6c <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3d38:	85ca                	mv	a1,s2
    3d3a:	00004517          	auipc	a0,0x4
    3d3e:	bd650513          	addi	a0,a0,-1066 # 7910 <malloc+0x1746>
    3d42:	00002097          	auipc	ra,0x2
    3d46:	3ca080e7          	jalr	970(ra) # 610c <printf>
    exit(1);
    3d4a:	4505                	li	a0,1
    3d4c:	00002097          	auipc	ra,0x2
    3d50:	020080e7          	jalr	32(ra) # 5d6c <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3d54:	85ca                	mv	a1,s2
    3d56:	00004517          	auipc	a0,0x4
    3d5a:	bea50513          	addi	a0,a0,-1046 # 7940 <malloc+0x1776>
    3d5e:	00002097          	auipc	ra,0x2
    3d62:	3ae080e7          	jalr	942(ra) # 610c <printf>
    exit(1);
    3d66:	4505                	li	a0,1
    3d68:	00002097          	auipc	ra,0x2
    3d6c:	004080e7          	jalr	4(ra) # 5d6c <exit>
    printf("%s: create dd succeeded!\n", s);
    3d70:	85ca                	mv	a1,s2
    3d72:	00004517          	auipc	a0,0x4
    3d76:	bee50513          	addi	a0,a0,-1042 # 7960 <malloc+0x1796>
    3d7a:	00002097          	auipc	ra,0x2
    3d7e:	392080e7          	jalr	914(ra) # 610c <printf>
    exit(1);
    3d82:	4505                	li	a0,1
    3d84:	00002097          	auipc	ra,0x2
    3d88:	fe8080e7          	jalr	-24(ra) # 5d6c <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3d8c:	85ca                	mv	a1,s2
    3d8e:	00004517          	auipc	a0,0x4
    3d92:	bf250513          	addi	a0,a0,-1038 # 7980 <malloc+0x17b6>
    3d96:	00002097          	auipc	ra,0x2
    3d9a:	376080e7          	jalr	886(ra) # 610c <printf>
    exit(1);
    3d9e:	4505                	li	a0,1
    3da0:	00002097          	auipc	ra,0x2
    3da4:	fcc080e7          	jalr	-52(ra) # 5d6c <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3da8:	85ca                	mv	a1,s2
    3daa:	00004517          	auipc	a0,0x4
    3dae:	bf650513          	addi	a0,a0,-1034 # 79a0 <malloc+0x17d6>
    3db2:	00002097          	auipc	ra,0x2
    3db6:	35a080e7          	jalr	858(ra) # 610c <printf>
    exit(1);
    3dba:	4505                	li	a0,1
    3dbc:	00002097          	auipc	ra,0x2
    3dc0:	fb0080e7          	jalr	-80(ra) # 5d6c <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3dc4:	85ca                	mv	a1,s2
    3dc6:	00004517          	auipc	a0,0x4
    3dca:	c0a50513          	addi	a0,a0,-1014 # 79d0 <malloc+0x1806>
    3dce:	00002097          	auipc	ra,0x2
    3dd2:	33e080e7          	jalr	830(ra) # 610c <printf>
    exit(1);
    3dd6:	4505                	li	a0,1
    3dd8:	00002097          	auipc	ra,0x2
    3ddc:	f94080e7          	jalr	-108(ra) # 5d6c <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3de0:	85ca                	mv	a1,s2
    3de2:	00004517          	auipc	a0,0x4
    3de6:	c1650513          	addi	a0,a0,-1002 # 79f8 <malloc+0x182e>
    3dea:	00002097          	auipc	ra,0x2
    3dee:	322080e7          	jalr	802(ra) # 610c <printf>
    exit(1);
    3df2:	4505                	li	a0,1
    3df4:	00002097          	auipc	ra,0x2
    3df8:	f78080e7          	jalr	-136(ra) # 5d6c <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3dfc:	85ca                	mv	a1,s2
    3dfe:	00004517          	auipc	a0,0x4
    3e02:	c2250513          	addi	a0,a0,-990 # 7a20 <malloc+0x1856>
    3e06:	00002097          	auipc	ra,0x2
    3e0a:	306080e7          	jalr	774(ra) # 610c <printf>
    exit(1);
    3e0e:	4505                	li	a0,1
    3e10:	00002097          	auipc	ra,0x2
    3e14:	f5c080e7          	jalr	-164(ra) # 5d6c <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3e18:	85ca                	mv	a1,s2
    3e1a:	00004517          	auipc	a0,0x4
    3e1e:	c2e50513          	addi	a0,a0,-978 # 7a48 <malloc+0x187e>
    3e22:	00002097          	auipc	ra,0x2
    3e26:	2ea080e7          	jalr	746(ra) # 610c <printf>
    exit(1);
    3e2a:	4505                	li	a0,1
    3e2c:	00002097          	auipc	ra,0x2
    3e30:	f40080e7          	jalr	-192(ra) # 5d6c <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3e34:	85ca                	mv	a1,s2
    3e36:	00004517          	auipc	a0,0x4
    3e3a:	c3250513          	addi	a0,a0,-974 # 7a68 <malloc+0x189e>
    3e3e:	00002097          	auipc	ra,0x2
    3e42:	2ce080e7          	jalr	718(ra) # 610c <printf>
    exit(1);
    3e46:	4505                	li	a0,1
    3e48:	00002097          	auipc	ra,0x2
    3e4c:	f24080e7          	jalr	-220(ra) # 5d6c <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3e50:	85ca                	mv	a1,s2
    3e52:	00004517          	auipc	a0,0x4
    3e56:	c3650513          	addi	a0,a0,-970 # 7a88 <malloc+0x18be>
    3e5a:	00002097          	auipc	ra,0x2
    3e5e:	2b2080e7          	jalr	690(ra) # 610c <printf>
    exit(1);
    3e62:	4505                	li	a0,1
    3e64:	00002097          	auipc	ra,0x2
    3e68:	f08080e7          	jalr	-248(ra) # 5d6c <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3e6c:	85ca                	mv	a1,s2
    3e6e:	00004517          	auipc	a0,0x4
    3e72:	c4250513          	addi	a0,a0,-958 # 7ab0 <malloc+0x18e6>
    3e76:	00002097          	auipc	ra,0x2
    3e7a:	296080e7          	jalr	662(ra) # 610c <printf>
    exit(1);
    3e7e:	4505                	li	a0,1
    3e80:	00002097          	auipc	ra,0x2
    3e84:	eec080e7          	jalr	-276(ra) # 5d6c <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3e88:	85ca                	mv	a1,s2
    3e8a:	00004517          	auipc	a0,0x4
    3e8e:	c4650513          	addi	a0,a0,-954 # 7ad0 <malloc+0x1906>
    3e92:	00002097          	auipc	ra,0x2
    3e96:	27a080e7          	jalr	634(ra) # 610c <printf>
    exit(1);
    3e9a:	4505                	li	a0,1
    3e9c:	00002097          	auipc	ra,0x2
    3ea0:	ed0080e7          	jalr	-304(ra) # 5d6c <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3ea4:	85ca                	mv	a1,s2
    3ea6:	00004517          	auipc	a0,0x4
    3eaa:	c4a50513          	addi	a0,a0,-950 # 7af0 <malloc+0x1926>
    3eae:	00002097          	auipc	ra,0x2
    3eb2:	25e080e7          	jalr	606(ra) # 610c <printf>
    exit(1);
    3eb6:	4505                	li	a0,1
    3eb8:	00002097          	auipc	ra,0x2
    3ebc:	eb4080e7          	jalr	-332(ra) # 5d6c <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3ec0:	85ca                	mv	a1,s2
    3ec2:	00004517          	auipc	a0,0x4
    3ec6:	c5650513          	addi	a0,a0,-938 # 7b18 <malloc+0x194e>
    3eca:	00002097          	auipc	ra,0x2
    3ece:	242080e7          	jalr	578(ra) # 610c <printf>
    exit(1);
    3ed2:	4505                	li	a0,1
    3ed4:	00002097          	auipc	ra,0x2
    3ed8:	e98080e7          	jalr	-360(ra) # 5d6c <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3edc:	85ca                	mv	a1,s2
    3ede:	00004517          	auipc	a0,0x4
    3ee2:	8d250513          	addi	a0,a0,-1838 # 77b0 <malloc+0x15e6>
    3ee6:	00002097          	auipc	ra,0x2
    3eea:	226080e7          	jalr	550(ra) # 610c <printf>
    exit(1);
    3eee:	4505                	li	a0,1
    3ef0:	00002097          	auipc	ra,0x2
    3ef4:	e7c080e7          	jalr	-388(ra) # 5d6c <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3ef8:	85ca                	mv	a1,s2
    3efa:	00004517          	auipc	a0,0x4
    3efe:	c3e50513          	addi	a0,a0,-962 # 7b38 <malloc+0x196e>
    3f02:	00002097          	auipc	ra,0x2
    3f06:	20a080e7          	jalr	522(ra) # 610c <printf>
    exit(1);
    3f0a:	4505                	li	a0,1
    3f0c:	00002097          	auipc	ra,0x2
    3f10:	e60080e7          	jalr	-416(ra) # 5d6c <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3f14:	85ca                	mv	a1,s2
    3f16:	00004517          	auipc	a0,0x4
    3f1a:	c4250513          	addi	a0,a0,-958 # 7b58 <malloc+0x198e>
    3f1e:	00002097          	auipc	ra,0x2
    3f22:	1ee080e7          	jalr	494(ra) # 610c <printf>
    exit(1);
    3f26:	4505                	li	a0,1
    3f28:	00002097          	auipc	ra,0x2
    3f2c:	e44080e7          	jalr	-444(ra) # 5d6c <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3f30:	85ca                	mv	a1,s2
    3f32:	00004517          	auipc	a0,0x4
    3f36:	c5650513          	addi	a0,a0,-938 # 7b88 <malloc+0x19be>
    3f3a:	00002097          	auipc	ra,0x2
    3f3e:	1d2080e7          	jalr	466(ra) # 610c <printf>
    exit(1);
    3f42:	4505                	li	a0,1
    3f44:	00002097          	auipc	ra,0x2
    3f48:	e28080e7          	jalr	-472(ra) # 5d6c <exit>
    printf("%s: unlink dd failed\n", s);
    3f4c:	85ca                	mv	a1,s2
    3f4e:	00004517          	auipc	a0,0x4
    3f52:	c5a50513          	addi	a0,a0,-934 # 7ba8 <malloc+0x19de>
    3f56:	00002097          	auipc	ra,0x2
    3f5a:	1b6080e7          	jalr	438(ra) # 610c <printf>
    exit(1);
    3f5e:	4505                	li	a0,1
    3f60:	00002097          	auipc	ra,0x2
    3f64:	e0c080e7          	jalr	-500(ra) # 5d6c <exit>

0000000000003f68 <rmdot>:
{
    3f68:	1101                	addi	sp,sp,-32
    3f6a:	ec06                	sd	ra,24(sp)
    3f6c:	e822                	sd	s0,16(sp)
    3f6e:	e426                	sd	s1,8(sp)
    3f70:	1000                	addi	s0,sp,32
    3f72:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3f74:	00004517          	auipc	a0,0x4
    3f78:	c4c50513          	addi	a0,a0,-948 # 7bc0 <malloc+0x19f6>
    3f7c:	00002097          	auipc	ra,0x2
    3f80:	e60080e7          	jalr	-416(ra) # 5ddc <mkdir>
    3f84:	e549                	bnez	a0,400e <rmdot+0xa6>
  if(chdir("dots") != 0){
    3f86:	00004517          	auipc	a0,0x4
    3f8a:	c3a50513          	addi	a0,a0,-966 # 7bc0 <malloc+0x19f6>
    3f8e:	00002097          	auipc	ra,0x2
    3f92:	e56080e7          	jalr	-426(ra) # 5de4 <chdir>
    3f96:	e951                	bnez	a0,402a <rmdot+0xc2>
  if(unlink(".") == 0){
    3f98:	00003517          	auipc	a0,0x3
    3f9c:	a5850513          	addi	a0,a0,-1448 # 69f0 <malloc+0x826>
    3fa0:	00002097          	auipc	ra,0x2
    3fa4:	e24080e7          	jalr	-476(ra) # 5dc4 <unlink>
    3fa8:	cd59                	beqz	a0,4046 <rmdot+0xde>
  if(unlink("..") == 0){
    3faa:	00003517          	auipc	a0,0x3
    3fae:	66e50513          	addi	a0,a0,1646 # 7618 <malloc+0x144e>
    3fb2:	00002097          	auipc	ra,0x2
    3fb6:	e12080e7          	jalr	-494(ra) # 5dc4 <unlink>
    3fba:	c545                	beqz	a0,4062 <rmdot+0xfa>
  if(chdir("/") != 0){
    3fbc:	00003517          	auipc	a0,0x3
    3fc0:	60450513          	addi	a0,a0,1540 # 75c0 <malloc+0x13f6>
    3fc4:	00002097          	auipc	ra,0x2
    3fc8:	e20080e7          	jalr	-480(ra) # 5de4 <chdir>
    3fcc:	e94d                	bnez	a0,407e <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3fce:	00004517          	auipc	a0,0x4
    3fd2:	c5a50513          	addi	a0,a0,-934 # 7c28 <malloc+0x1a5e>
    3fd6:	00002097          	auipc	ra,0x2
    3fda:	dee080e7          	jalr	-530(ra) # 5dc4 <unlink>
    3fde:	cd55                	beqz	a0,409a <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3fe0:	00004517          	auipc	a0,0x4
    3fe4:	c7050513          	addi	a0,a0,-912 # 7c50 <malloc+0x1a86>
    3fe8:	00002097          	auipc	ra,0x2
    3fec:	ddc080e7          	jalr	-548(ra) # 5dc4 <unlink>
    3ff0:	c179                	beqz	a0,40b6 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3ff2:	00004517          	auipc	a0,0x4
    3ff6:	bce50513          	addi	a0,a0,-1074 # 7bc0 <malloc+0x19f6>
    3ffa:	00002097          	auipc	ra,0x2
    3ffe:	dca080e7          	jalr	-566(ra) # 5dc4 <unlink>
    4002:	e961                	bnez	a0,40d2 <rmdot+0x16a>
}
    4004:	60e2                	ld	ra,24(sp)
    4006:	6442                	ld	s0,16(sp)
    4008:	64a2                	ld	s1,8(sp)
    400a:	6105                	addi	sp,sp,32
    400c:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    400e:	85a6                	mv	a1,s1
    4010:	00004517          	auipc	a0,0x4
    4014:	bb850513          	addi	a0,a0,-1096 # 7bc8 <malloc+0x19fe>
    4018:	00002097          	auipc	ra,0x2
    401c:	0f4080e7          	jalr	244(ra) # 610c <printf>
    exit(1);
    4020:	4505                	li	a0,1
    4022:	00002097          	auipc	ra,0x2
    4026:	d4a080e7          	jalr	-694(ra) # 5d6c <exit>
    printf("%s: chdir dots failed\n", s);
    402a:	85a6                	mv	a1,s1
    402c:	00004517          	auipc	a0,0x4
    4030:	bb450513          	addi	a0,a0,-1100 # 7be0 <malloc+0x1a16>
    4034:	00002097          	auipc	ra,0x2
    4038:	0d8080e7          	jalr	216(ra) # 610c <printf>
    exit(1);
    403c:	4505                	li	a0,1
    403e:	00002097          	auipc	ra,0x2
    4042:	d2e080e7          	jalr	-722(ra) # 5d6c <exit>
    printf("%s: rm . worked!\n", s);
    4046:	85a6                	mv	a1,s1
    4048:	00004517          	auipc	a0,0x4
    404c:	bb050513          	addi	a0,a0,-1104 # 7bf8 <malloc+0x1a2e>
    4050:	00002097          	auipc	ra,0x2
    4054:	0bc080e7          	jalr	188(ra) # 610c <printf>
    exit(1);
    4058:	4505                	li	a0,1
    405a:	00002097          	auipc	ra,0x2
    405e:	d12080e7          	jalr	-750(ra) # 5d6c <exit>
    printf("%s: rm .. worked!\n", s);
    4062:	85a6                	mv	a1,s1
    4064:	00004517          	auipc	a0,0x4
    4068:	bac50513          	addi	a0,a0,-1108 # 7c10 <malloc+0x1a46>
    406c:	00002097          	auipc	ra,0x2
    4070:	0a0080e7          	jalr	160(ra) # 610c <printf>
    exit(1);
    4074:	4505                	li	a0,1
    4076:	00002097          	auipc	ra,0x2
    407a:	cf6080e7          	jalr	-778(ra) # 5d6c <exit>
    printf("%s: chdir / failed\n", s);
    407e:	85a6                	mv	a1,s1
    4080:	00003517          	auipc	a0,0x3
    4084:	54850513          	addi	a0,a0,1352 # 75c8 <malloc+0x13fe>
    4088:	00002097          	auipc	ra,0x2
    408c:	084080e7          	jalr	132(ra) # 610c <printf>
    exit(1);
    4090:	4505                	li	a0,1
    4092:	00002097          	auipc	ra,0x2
    4096:	cda080e7          	jalr	-806(ra) # 5d6c <exit>
    printf("%s: unlink dots/. worked!\n", s);
    409a:	85a6                	mv	a1,s1
    409c:	00004517          	auipc	a0,0x4
    40a0:	b9450513          	addi	a0,a0,-1132 # 7c30 <malloc+0x1a66>
    40a4:	00002097          	auipc	ra,0x2
    40a8:	068080e7          	jalr	104(ra) # 610c <printf>
    exit(1);
    40ac:	4505                	li	a0,1
    40ae:	00002097          	auipc	ra,0x2
    40b2:	cbe080e7          	jalr	-834(ra) # 5d6c <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    40b6:	85a6                	mv	a1,s1
    40b8:	00004517          	auipc	a0,0x4
    40bc:	ba050513          	addi	a0,a0,-1120 # 7c58 <malloc+0x1a8e>
    40c0:	00002097          	auipc	ra,0x2
    40c4:	04c080e7          	jalr	76(ra) # 610c <printf>
    exit(1);
    40c8:	4505                	li	a0,1
    40ca:	00002097          	auipc	ra,0x2
    40ce:	ca2080e7          	jalr	-862(ra) # 5d6c <exit>
    printf("%s: unlink dots failed!\n", s);
    40d2:	85a6                	mv	a1,s1
    40d4:	00004517          	auipc	a0,0x4
    40d8:	ba450513          	addi	a0,a0,-1116 # 7c78 <malloc+0x1aae>
    40dc:	00002097          	auipc	ra,0x2
    40e0:	030080e7          	jalr	48(ra) # 610c <printf>
    exit(1);
    40e4:	4505                	li	a0,1
    40e6:	00002097          	auipc	ra,0x2
    40ea:	c86080e7          	jalr	-890(ra) # 5d6c <exit>

00000000000040ee <dirfile>:
{
    40ee:	1101                	addi	sp,sp,-32
    40f0:	ec06                	sd	ra,24(sp)
    40f2:	e822                	sd	s0,16(sp)
    40f4:	e426                	sd	s1,8(sp)
    40f6:	e04a                	sd	s2,0(sp)
    40f8:	1000                	addi	s0,sp,32
    40fa:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    40fc:	20000593          	li	a1,512
    4100:	00004517          	auipc	a0,0x4
    4104:	b9850513          	addi	a0,a0,-1128 # 7c98 <malloc+0x1ace>
    4108:	00002097          	auipc	ra,0x2
    410c:	cac080e7          	jalr	-852(ra) # 5db4 <open>
  if(fd < 0){
    4110:	0e054d63          	bltz	a0,420a <dirfile+0x11c>
  close(fd);
    4114:	00002097          	auipc	ra,0x2
    4118:	c88080e7          	jalr	-888(ra) # 5d9c <close>
  if(chdir("dirfile") == 0){
    411c:	00004517          	auipc	a0,0x4
    4120:	b7c50513          	addi	a0,a0,-1156 # 7c98 <malloc+0x1ace>
    4124:	00002097          	auipc	ra,0x2
    4128:	cc0080e7          	jalr	-832(ra) # 5de4 <chdir>
    412c:	cd6d                	beqz	a0,4226 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    412e:	4581                	li	a1,0
    4130:	00004517          	auipc	a0,0x4
    4134:	bb050513          	addi	a0,a0,-1104 # 7ce0 <malloc+0x1b16>
    4138:	00002097          	auipc	ra,0x2
    413c:	c7c080e7          	jalr	-900(ra) # 5db4 <open>
  if(fd >= 0){
    4140:	10055163          	bgez	a0,4242 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    4144:	20000593          	li	a1,512
    4148:	00004517          	auipc	a0,0x4
    414c:	b9850513          	addi	a0,a0,-1128 # 7ce0 <malloc+0x1b16>
    4150:	00002097          	auipc	ra,0x2
    4154:	c64080e7          	jalr	-924(ra) # 5db4 <open>
  if(fd >= 0){
    4158:	10055363          	bgez	a0,425e <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    415c:	00004517          	auipc	a0,0x4
    4160:	b8450513          	addi	a0,a0,-1148 # 7ce0 <malloc+0x1b16>
    4164:	00002097          	auipc	ra,0x2
    4168:	c78080e7          	jalr	-904(ra) # 5ddc <mkdir>
    416c:	10050763          	beqz	a0,427a <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    4170:	00004517          	auipc	a0,0x4
    4174:	b7050513          	addi	a0,a0,-1168 # 7ce0 <malloc+0x1b16>
    4178:	00002097          	auipc	ra,0x2
    417c:	c4c080e7          	jalr	-948(ra) # 5dc4 <unlink>
    4180:	10050b63          	beqz	a0,4296 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    4184:	00004597          	auipc	a1,0x4
    4188:	b5c58593          	addi	a1,a1,-1188 # 7ce0 <malloc+0x1b16>
    418c:	00002517          	auipc	a0,0x2
    4190:	35450513          	addi	a0,a0,852 # 64e0 <malloc+0x316>
    4194:	00002097          	auipc	ra,0x2
    4198:	c40080e7          	jalr	-960(ra) # 5dd4 <link>
    419c:	10050b63          	beqz	a0,42b2 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    41a0:	00004517          	auipc	a0,0x4
    41a4:	af850513          	addi	a0,a0,-1288 # 7c98 <malloc+0x1ace>
    41a8:	00002097          	auipc	ra,0x2
    41ac:	c1c080e7          	jalr	-996(ra) # 5dc4 <unlink>
    41b0:	10051f63          	bnez	a0,42ce <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    41b4:	4589                	li	a1,2
    41b6:	00003517          	auipc	a0,0x3
    41ba:	83a50513          	addi	a0,a0,-1990 # 69f0 <malloc+0x826>
    41be:	00002097          	auipc	ra,0x2
    41c2:	bf6080e7          	jalr	-1034(ra) # 5db4 <open>
  if(fd >= 0){
    41c6:	12055263          	bgez	a0,42ea <dirfile+0x1fc>
  fd = open(".", 0);
    41ca:	4581                	li	a1,0
    41cc:	00003517          	auipc	a0,0x3
    41d0:	82450513          	addi	a0,a0,-2012 # 69f0 <malloc+0x826>
    41d4:	00002097          	auipc	ra,0x2
    41d8:	be0080e7          	jalr	-1056(ra) # 5db4 <open>
    41dc:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    41de:	4605                	li	a2,1
    41e0:	00002597          	auipc	a1,0x2
    41e4:	19858593          	addi	a1,a1,408 # 6378 <malloc+0x1ae>
    41e8:	00002097          	auipc	ra,0x2
    41ec:	bac080e7          	jalr	-1108(ra) # 5d94 <write>
    41f0:	10a04b63          	bgtz	a0,4306 <dirfile+0x218>
  close(fd);
    41f4:	8526                	mv	a0,s1
    41f6:	00002097          	auipc	ra,0x2
    41fa:	ba6080e7          	jalr	-1114(ra) # 5d9c <close>
}
    41fe:	60e2                	ld	ra,24(sp)
    4200:	6442                	ld	s0,16(sp)
    4202:	64a2                	ld	s1,8(sp)
    4204:	6902                	ld	s2,0(sp)
    4206:	6105                	addi	sp,sp,32
    4208:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    420a:	85ca                	mv	a1,s2
    420c:	00004517          	auipc	a0,0x4
    4210:	a9450513          	addi	a0,a0,-1388 # 7ca0 <malloc+0x1ad6>
    4214:	00002097          	auipc	ra,0x2
    4218:	ef8080e7          	jalr	-264(ra) # 610c <printf>
    exit(1);
    421c:	4505                	li	a0,1
    421e:	00002097          	auipc	ra,0x2
    4222:	b4e080e7          	jalr	-1202(ra) # 5d6c <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    4226:	85ca                	mv	a1,s2
    4228:	00004517          	auipc	a0,0x4
    422c:	a9850513          	addi	a0,a0,-1384 # 7cc0 <malloc+0x1af6>
    4230:	00002097          	auipc	ra,0x2
    4234:	edc080e7          	jalr	-292(ra) # 610c <printf>
    exit(1);
    4238:	4505                	li	a0,1
    423a:	00002097          	auipc	ra,0x2
    423e:	b32080e7          	jalr	-1230(ra) # 5d6c <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    4242:	85ca                	mv	a1,s2
    4244:	00004517          	auipc	a0,0x4
    4248:	aac50513          	addi	a0,a0,-1364 # 7cf0 <malloc+0x1b26>
    424c:	00002097          	auipc	ra,0x2
    4250:	ec0080e7          	jalr	-320(ra) # 610c <printf>
    exit(1);
    4254:	4505                	li	a0,1
    4256:	00002097          	auipc	ra,0x2
    425a:	b16080e7          	jalr	-1258(ra) # 5d6c <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    425e:	85ca                	mv	a1,s2
    4260:	00004517          	auipc	a0,0x4
    4264:	a9050513          	addi	a0,a0,-1392 # 7cf0 <malloc+0x1b26>
    4268:	00002097          	auipc	ra,0x2
    426c:	ea4080e7          	jalr	-348(ra) # 610c <printf>
    exit(1);
    4270:	4505                	li	a0,1
    4272:	00002097          	auipc	ra,0x2
    4276:	afa080e7          	jalr	-1286(ra) # 5d6c <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    427a:	85ca                	mv	a1,s2
    427c:	00004517          	auipc	a0,0x4
    4280:	a9c50513          	addi	a0,a0,-1380 # 7d18 <malloc+0x1b4e>
    4284:	00002097          	auipc	ra,0x2
    4288:	e88080e7          	jalr	-376(ra) # 610c <printf>
    exit(1);
    428c:	4505                	li	a0,1
    428e:	00002097          	auipc	ra,0x2
    4292:	ade080e7          	jalr	-1314(ra) # 5d6c <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    4296:	85ca                	mv	a1,s2
    4298:	00004517          	auipc	a0,0x4
    429c:	aa850513          	addi	a0,a0,-1368 # 7d40 <malloc+0x1b76>
    42a0:	00002097          	auipc	ra,0x2
    42a4:	e6c080e7          	jalr	-404(ra) # 610c <printf>
    exit(1);
    42a8:	4505                	li	a0,1
    42aa:	00002097          	auipc	ra,0x2
    42ae:	ac2080e7          	jalr	-1342(ra) # 5d6c <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    42b2:	85ca                	mv	a1,s2
    42b4:	00004517          	auipc	a0,0x4
    42b8:	ab450513          	addi	a0,a0,-1356 # 7d68 <malloc+0x1b9e>
    42bc:	00002097          	auipc	ra,0x2
    42c0:	e50080e7          	jalr	-432(ra) # 610c <printf>
    exit(1);
    42c4:	4505                	li	a0,1
    42c6:	00002097          	auipc	ra,0x2
    42ca:	aa6080e7          	jalr	-1370(ra) # 5d6c <exit>
    printf("%s: unlink dirfile failed!\n", s);
    42ce:	85ca                	mv	a1,s2
    42d0:	00004517          	auipc	a0,0x4
    42d4:	ac050513          	addi	a0,a0,-1344 # 7d90 <malloc+0x1bc6>
    42d8:	00002097          	auipc	ra,0x2
    42dc:	e34080e7          	jalr	-460(ra) # 610c <printf>
    exit(1);
    42e0:	4505                	li	a0,1
    42e2:	00002097          	auipc	ra,0x2
    42e6:	a8a080e7          	jalr	-1398(ra) # 5d6c <exit>
    printf("%s: open . for writing succeeded!\n", s);
    42ea:	85ca                	mv	a1,s2
    42ec:	00004517          	auipc	a0,0x4
    42f0:	ac450513          	addi	a0,a0,-1340 # 7db0 <malloc+0x1be6>
    42f4:	00002097          	auipc	ra,0x2
    42f8:	e18080e7          	jalr	-488(ra) # 610c <printf>
    exit(1);
    42fc:	4505                	li	a0,1
    42fe:	00002097          	auipc	ra,0x2
    4302:	a6e080e7          	jalr	-1426(ra) # 5d6c <exit>
    printf("%s: write . succeeded!\n", s);
    4306:	85ca                	mv	a1,s2
    4308:	00004517          	auipc	a0,0x4
    430c:	ad050513          	addi	a0,a0,-1328 # 7dd8 <malloc+0x1c0e>
    4310:	00002097          	auipc	ra,0x2
    4314:	dfc080e7          	jalr	-516(ra) # 610c <printf>
    exit(1);
    4318:	4505                	li	a0,1
    431a:	00002097          	auipc	ra,0x2
    431e:	a52080e7          	jalr	-1454(ra) # 5d6c <exit>

0000000000004322 <iref>:
{
    4322:	7139                	addi	sp,sp,-64
    4324:	fc06                	sd	ra,56(sp)
    4326:	f822                	sd	s0,48(sp)
    4328:	f426                	sd	s1,40(sp)
    432a:	f04a                	sd	s2,32(sp)
    432c:	ec4e                	sd	s3,24(sp)
    432e:	e852                	sd	s4,16(sp)
    4330:	e456                	sd	s5,8(sp)
    4332:	e05a                	sd	s6,0(sp)
    4334:	0080                	addi	s0,sp,64
    4336:	8b2a                	mv	s6,a0
    4338:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    433c:	00004a17          	auipc	s4,0x4
    4340:	ab4a0a13          	addi	s4,s4,-1356 # 7df0 <malloc+0x1c26>
    mkdir("");
    4344:	00003497          	auipc	s1,0x3
    4348:	5b448493          	addi	s1,s1,1460 # 78f8 <malloc+0x172e>
    link("README", "");
    434c:	00002a97          	auipc	s5,0x2
    4350:	194a8a93          	addi	s5,s5,404 # 64e0 <malloc+0x316>
    fd = open("xx", O_CREATE);
    4354:	00004997          	auipc	s3,0x4
    4358:	99498993          	addi	s3,s3,-1644 # 7ce8 <malloc+0x1b1e>
    435c:	a891                	j	43b0 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    435e:	85da                	mv	a1,s6
    4360:	00004517          	auipc	a0,0x4
    4364:	a9850513          	addi	a0,a0,-1384 # 7df8 <malloc+0x1c2e>
    4368:	00002097          	auipc	ra,0x2
    436c:	da4080e7          	jalr	-604(ra) # 610c <printf>
      exit(1);
    4370:	4505                	li	a0,1
    4372:	00002097          	auipc	ra,0x2
    4376:	9fa080e7          	jalr	-1542(ra) # 5d6c <exit>
      printf("%s: chdir irefd failed\n", s);
    437a:	85da                	mv	a1,s6
    437c:	00004517          	auipc	a0,0x4
    4380:	a9450513          	addi	a0,a0,-1388 # 7e10 <malloc+0x1c46>
    4384:	00002097          	auipc	ra,0x2
    4388:	d88080e7          	jalr	-632(ra) # 610c <printf>
      exit(1);
    438c:	4505                	li	a0,1
    438e:	00002097          	auipc	ra,0x2
    4392:	9de080e7          	jalr	-1570(ra) # 5d6c <exit>
      close(fd);
    4396:	00002097          	auipc	ra,0x2
    439a:	a06080e7          	jalr	-1530(ra) # 5d9c <close>
    439e:	a889                	j	43f0 <iref+0xce>
    unlink("xx");
    43a0:	854e                	mv	a0,s3
    43a2:	00002097          	auipc	ra,0x2
    43a6:	a22080e7          	jalr	-1502(ra) # 5dc4 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    43aa:	397d                	addiw	s2,s2,-1
    43ac:	06090063          	beqz	s2,440c <iref+0xea>
    if(mkdir("irefd") != 0){
    43b0:	8552                	mv	a0,s4
    43b2:	00002097          	auipc	ra,0x2
    43b6:	a2a080e7          	jalr	-1494(ra) # 5ddc <mkdir>
    43ba:	f155                	bnez	a0,435e <iref+0x3c>
    if(chdir("irefd") != 0){
    43bc:	8552                	mv	a0,s4
    43be:	00002097          	auipc	ra,0x2
    43c2:	a26080e7          	jalr	-1498(ra) # 5de4 <chdir>
    43c6:	f955                	bnez	a0,437a <iref+0x58>
    mkdir("");
    43c8:	8526                	mv	a0,s1
    43ca:	00002097          	auipc	ra,0x2
    43ce:	a12080e7          	jalr	-1518(ra) # 5ddc <mkdir>
    link("README", "");
    43d2:	85a6                	mv	a1,s1
    43d4:	8556                	mv	a0,s5
    43d6:	00002097          	auipc	ra,0x2
    43da:	9fe080e7          	jalr	-1538(ra) # 5dd4 <link>
    fd = open("", O_CREATE);
    43de:	20000593          	li	a1,512
    43e2:	8526                	mv	a0,s1
    43e4:	00002097          	auipc	ra,0x2
    43e8:	9d0080e7          	jalr	-1584(ra) # 5db4 <open>
    if(fd >= 0)
    43ec:	fa0555e3          	bgez	a0,4396 <iref+0x74>
    fd = open("xx", O_CREATE);
    43f0:	20000593          	li	a1,512
    43f4:	854e                	mv	a0,s3
    43f6:	00002097          	auipc	ra,0x2
    43fa:	9be080e7          	jalr	-1602(ra) # 5db4 <open>
    if(fd >= 0)
    43fe:	fa0541e3          	bltz	a0,43a0 <iref+0x7e>
      close(fd);
    4402:	00002097          	auipc	ra,0x2
    4406:	99a080e7          	jalr	-1638(ra) # 5d9c <close>
    440a:	bf59                	j	43a0 <iref+0x7e>
    440c:	03300493          	li	s1,51
    chdir("..");
    4410:	00003997          	auipc	s3,0x3
    4414:	20898993          	addi	s3,s3,520 # 7618 <malloc+0x144e>
    unlink("irefd");
    4418:	00004917          	auipc	s2,0x4
    441c:	9d890913          	addi	s2,s2,-1576 # 7df0 <malloc+0x1c26>
    chdir("..");
    4420:	854e                	mv	a0,s3
    4422:	00002097          	auipc	ra,0x2
    4426:	9c2080e7          	jalr	-1598(ra) # 5de4 <chdir>
    unlink("irefd");
    442a:	854a                	mv	a0,s2
    442c:	00002097          	auipc	ra,0x2
    4430:	998080e7          	jalr	-1640(ra) # 5dc4 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4434:	34fd                	addiw	s1,s1,-1
    4436:	f4ed                	bnez	s1,4420 <iref+0xfe>
  chdir("/");
    4438:	00003517          	auipc	a0,0x3
    443c:	18850513          	addi	a0,a0,392 # 75c0 <malloc+0x13f6>
    4440:	00002097          	auipc	ra,0x2
    4444:	9a4080e7          	jalr	-1628(ra) # 5de4 <chdir>
}
    4448:	70e2                	ld	ra,56(sp)
    444a:	7442                	ld	s0,48(sp)
    444c:	74a2                	ld	s1,40(sp)
    444e:	7902                	ld	s2,32(sp)
    4450:	69e2                	ld	s3,24(sp)
    4452:	6a42                	ld	s4,16(sp)
    4454:	6aa2                	ld	s5,8(sp)
    4456:	6b02                	ld	s6,0(sp)
    4458:	6121                	addi	sp,sp,64
    445a:	8082                	ret

000000000000445c <openiputtest>:
{
    445c:	7179                	addi	sp,sp,-48
    445e:	f406                	sd	ra,40(sp)
    4460:	f022                	sd	s0,32(sp)
    4462:	ec26                	sd	s1,24(sp)
    4464:	1800                	addi	s0,sp,48
    4466:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    4468:	00004517          	auipc	a0,0x4
    446c:	9c050513          	addi	a0,a0,-1600 # 7e28 <malloc+0x1c5e>
    4470:	00002097          	auipc	ra,0x2
    4474:	96c080e7          	jalr	-1684(ra) # 5ddc <mkdir>
    4478:	04054263          	bltz	a0,44bc <openiputtest+0x60>
  pid = fork();
    447c:	00002097          	auipc	ra,0x2
    4480:	8e8080e7          	jalr	-1816(ra) # 5d64 <fork>
  if(pid < 0){
    4484:	04054a63          	bltz	a0,44d8 <openiputtest+0x7c>
  if(pid == 0){
    4488:	e93d                	bnez	a0,44fe <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    448a:	4589                	li	a1,2
    448c:	00004517          	auipc	a0,0x4
    4490:	99c50513          	addi	a0,a0,-1636 # 7e28 <malloc+0x1c5e>
    4494:	00002097          	auipc	ra,0x2
    4498:	920080e7          	jalr	-1760(ra) # 5db4 <open>
    if(fd >= 0){
    449c:	04054c63          	bltz	a0,44f4 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    44a0:	85a6                	mv	a1,s1
    44a2:	00004517          	auipc	a0,0x4
    44a6:	9a650513          	addi	a0,a0,-1626 # 7e48 <malloc+0x1c7e>
    44aa:	00002097          	auipc	ra,0x2
    44ae:	c62080e7          	jalr	-926(ra) # 610c <printf>
      exit(1);
    44b2:	4505                	li	a0,1
    44b4:	00002097          	auipc	ra,0x2
    44b8:	8b8080e7          	jalr	-1864(ra) # 5d6c <exit>
    printf("%s: mkdir oidir failed\n", s);
    44bc:	85a6                	mv	a1,s1
    44be:	00004517          	auipc	a0,0x4
    44c2:	97250513          	addi	a0,a0,-1678 # 7e30 <malloc+0x1c66>
    44c6:	00002097          	auipc	ra,0x2
    44ca:	c46080e7          	jalr	-954(ra) # 610c <printf>
    exit(1);
    44ce:	4505                	li	a0,1
    44d0:	00002097          	auipc	ra,0x2
    44d4:	89c080e7          	jalr	-1892(ra) # 5d6c <exit>
    printf("%s: fork failed\n", s);
    44d8:	85a6                	mv	a1,s1
    44da:	00002517          	auipc	a0,0x2
    44de:	6b650513          	addi	a0,a0,1718 # 6b90 <malloc+0x9c6>
    44e2:	00002097          	auipc	ra,0x2
    44e6:	c2a080e7          	jalr	-982(ra) # 610c <printf>
    exit(1);
    44ea:	4505                	li	a0,1
    44ec:	00002097          	auipc	ra,0x2
    44f0:	880080e7          	jalr	-1920(ra) # 5d6c <exit>
    exit(0);
    44f4:	4501                	li	a0,0
    44f6:	00002097          	auipc	ra,0x2
    44fa:	876080e7          	jalr	-1930(ra) # 5d6c <exit>
  sleep(1);
    44fe:	4505                	li	a0,1
    4500:	00002097          	auipc	ra,0x2
    4504:	904080e7          	jalr	-1788(ra) # 5e04 <sleep>
  if(unlink("oidir") != 0){
    4508:	00004517          	auipc	a0,0x4
    450c:	92050513          	addi	a0,a0,-1760 # 7e28 <malloc+0x1c5e>
    4510:	00002097          	auipc	ra,0x2
    4514:	8b4080e7          	jalr	-1868(ra) # 5dc4 <unlink>
    4518:	cd19                	beqz	a0,4536 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    451a:	85a6                	mv	a1,s1
    451c:	00003517          	auipc	a0,0x3
    4520:	86450513          	addi	a0,a0,-1948 # 6d80 <malloc+0xbb6>
    4524:	00002097          	auipc	ra,0x2
    4528:	be8080e7          	jalr	-1048(ra) # 610c <printf>
    exit(1);
    452c:	4505                	li	a0,1
    452e:	00002097          	auipc	ra,0x2
    4532:	83e080e7          	jalr	-1986(ra) # 5d6c <exit>
  wait(&xstatus,"");
    4536:	00003597          	auipc	a1,0x3
    453a:	3c258593          	addi	a1,a1,962 # 78f8 <malloc+0x172e>
    453e:	fdc40513          	addi	a0,s0,-36
    4542:	00002097          	auipc	ra,0x2
    4546:	83a080e7          	jalr	-1990(ra) # 5d7c <wait>
  exit(xstatus);
    454a:	fdc42503          	lw	a0,-36(s0)
    454e:	00002097          	auipc	ra,0x2
    4552:	81e080e7          	jalr	-2018(ra) # 5d6c <exit>

0000000000004556 <forkforkfork>:
{
    4556:	1101                	addi	sp,sp,-32
    4558:	ec06                	sd	ra,24(sp)
    455a:	e822                	sd	s0,16(sp)
    455c:	e426                	sd	s1,8(sp)
    455e:	1000                	addi	s0,sp,32
    4560:	84aa                	mv	s1,a0
  unlink("stopforking");
    4562:	00004517          	auipc	a0,0x4
    4566:	90e50513          	addi	a0,a0,-1778 # 7e70 <malloc+0x1ca6>
    456a:	00002097          	auipc	ra,0x2
    456e:	85a080e7          	jalr	-1958(ra) # 5dc4 <unlink>
  int pid = fork();
    4572:	00001097          	auipc	ra,0x1
    4576:	7f2080e7          	jalr	2034(ra) # 5d64 <fork>
  if(pid < 0){
    457a:	04054963          	bltz	a0,45cc <forkforkfork+0x76>
  if(pid == 0){
    457e:	c52d                	beqz	a0,45e8 <forkforkfork+0x92>
  sleep(20); // two seconds
    4580:	4551                	li	a0,20
    4582:	00002097          	auipc	ra,0x2
    4586:	882080e7          	jalr	-1918(ra) # 5e04 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    458a:	20200593          	li	a1,514
    458e:	00004517          	auipc	a0,0x4
    4592:	8e250513          	addi	a0,a0,-1822 # 7e70 <malloc+0x1ca6>
    4596:	00002097          	auipc	ra,0x2
    459a:	81e080e7          	jalr	-2018(ra) # 5db4 <open>
    459e:	00001097          	auipc	ra,0x1
    45a2:	7fe080e7          	jalr	2046(ra) # 5d9c <close>
  wait(0,"");
    45a6:	00003597          	auipc	a1,0x3
    45aa:	35258593          	addi	a1,a1,850 # 78f8 <malloc+0x172e>
    45ae:	4501                	li	a0,0
    45b0:	00001097          	auipc	ra,0x1
    45b4:	7cc080e7          	jalr	1996(ra) # 5d7c <wait>
  sleep(10); // one second
    45b8:	4529                	li	a0,10
    45ba:	00002097          	auipc	ra,0x2
    45be:	84a080e7          	jalr	-1974(ra) # 5e04 <sleep>
}
    45c2:	60e2                	ld	ra,24(sp)
    45c4:	6442                	ld	s0,16(sp)
    45c6:	64a2                	ld	s1,8(sp)
    45c8:	6105                	addi	sp,sp,32
    45ca:	8082                	ret
    printf("%s: fork failed", s);
    45cc:	85a6                	mv	a1,s1
    45ce:	00002517          	auipc	a0,0x2
    45d2:	78250513          	addi	a0,a0,1922 # 6d50 <malloc+0xb86>
    45d6:	00002097          	auipc	ra,0x2
    45da:	b36080e7          	jalr	-1226(ra) # 610c <printf>
    exit(1);
    45de:	4505                	li	a0,1
    45e0:	00001097          	auipc	ra,0x1
    45e4:	78c080e7          	jalr	1932(ra) # 5d6c <exit>
      int fd = open("stopforking", 0);
    45e8:	00004497          	auipc	s1,0x4
    45ec:	88848493          	addi	s1,s1,-1912 # 7e70 <malloc+0x1ca6>
    45f0:	4581                	li	a1,0
    45f2:	8526                	mv	a0,s1
    45f4:	00001097          	auipc	ra,0x1
    45f8:	7c0080e7          	jalr	1984(ra) # 5db4 <open>
      if(fd >= 0){
    45fc:	02055463          	bgez	a0,4624 <forkforkfork+0xce>
      if(fork() < 0){
    4600:	00001097          	auipc	ra,0x1
    4604:	764080e7          	jalr	1892(ra) # 5d64 <fork>
    4608:	fe0554e3          	bgez	a0,45f0 <forkforkfork+0x9a>
        close(open("stopforking", O_CREATE|O_RDWR));
    460c:	20200593          	li	a1,514
    4610:	8526                	mv	a0,s1
    4612:	00001097          	auipc	ra,0x1
    4616:	7a2080e7          	jalr	1954(ra) # 5db4 <open>
    461a:	00001097          	auipc	ra,0x1
    461e:	782080e7          	jalr	1922(ra) # 5d9c <close>
    4622:	b7f9                	j	45f0 <forkforkfork+0x9a>
        exit(0);
    4624:	4501                	li	a0,0
    4626:	00001097          	auipc	ra,0x1
    462a:	746080e7          	jalr	1862(ra) # 5d6c <exit>

000000000000462e <killstatus>:
{
    462e:	715d                	addi	sp,sp,-80
    4630:	e486                	sd	ra,72(sp)
    4632:	e0a2                	sd	s0,64(sp)
    4634:	fc26                	sd	s1,56(sp)
    4636:	f84a                	sd	s2,48(sp)
    4638:	f44e                	sd	s3,40(sp)
    463a:	f052                	sd	s4,32(sp)
    463c:	ec56                	sd	s5,24(sp)
    463e:	0880                	addi	s0,sp,80
    4640:	8aaa                	mv	s5,a0
    4642:	06400913          	li	s2,100
    wait(&xst,"");
    4646:	00003a17          	auipc	s4,0x3
    464a:	2b2a0a13          	addi	s4,s4,690 # 78f8 <malloc+0x172e>
    if(xst != -1) {
    464e:	59fd                	li	s3,-1
    int pid1 = fork();
    4650:	00001097          	auipc	ra,0x1
    4654:	714080e7          	jalr	1812(ra) # 5d64 <fork>
    4658:	84aa                	mv	s1,a0
    if(pid1 < 0){
    465a:	04054063          	bltz	a0,469a <killstatus+0x6c>
    if(pid1 == 0){
    465e:	cd21                	beqz	a0,46b6 <killstatus+0x88>
    sleep(1);
    4660:	4505                	li	a0,1
    4662:	00001097          	auipc	ra,0x1
    4666:	7a2080e7          	jalr	1954(ra) # 5e04 <sleep>
    kill(pid1);
    466a:	8526                	mv	a0,s1
    466c:	00001097          	auipc	ra,0x1
    4670:	738080e7          	jalr	1848(ra) # 5da4 <kill>
    wait(&xst,"");
    4674:	85d2                	mv	a1,s4
    4676:	fbc40513          	addi	a0,s0,-68
    467a:	00001097          	auipc	ra,0x1
    467e:	702080e7          	jalr	1794(ra) # 5d7c <wait>
    if(xst != -1) {
    4682:	fbc42783          	lw	a5,-68(s0)
    4686:	03379d63          	bne	a5,s3,46c0 <killstatus+0x92>
  for(int i = 0; i < 100; i++){
    468a:	397d                	addiw	s2,s2,-1
    468c:	fc0912e3          	bnez	s2,4650 <killstatus+0x22>
  exit(0);
    4690:	4501                	li	a0,0
    4692:	00001097          	auipc	ra,0x1
    4696:	6da080e7          	jalr	1754(ra) # 5d6c <exit>
      printf("%s: fork failed\n", s);
    469a:	85d6                	mv	a1,s5
    469c:	00002517          	auipc	a0,0x2
    46a0:	4f450513          	addi	a0,a0,1268 # 6b90 <malloc+0x9c6>
    46a4:	00002097          	auipc	ra,0x2
    46a8:	a68080e7          	jalr	-1432(ra) # 610c <printf>
      exit(1);
    46ac:	4505                	li	a0,1
    46ae:	00001097          	auipc	ra,0x1
    46b2:	6be080e7          	jalr	1726(ra) # 5d6c <exit>
        getpid();
    46b6:	00001097          	auipc	ra,0x1
    46ba:	73e080e7          	jalr	1854(ra) # 5df4 <getpid>
      while(1) {
    46be:	bfe5                	j	46b6 <killstatus+0x88>
       printf("%s: status should be -1\n", s);
    46c0:	85d6                	mv	a1,s5
    46c2:	00003517          	auipc	a0,0x3
    46c6:	7be50513          	addi	a0,a0,1982 # 7e80 <malloc+0x1cb6>
    46ca:	00002097          	auipc	ra,0x2
    46ce:	a42080e7          	jalr	-1470(ra) # 610c <printf>
       exit(1);
    46d2:	4505                	li	a0,1
    46d4:	00001097          	auipc	ra,0x1
    46d8:	698080e7          	jalr	1688(ra) # 5d6c <exit>

00000000000046dc <preempt>:
{
    46dc:	7139                	addi	sp,sp,-64
    46de:	fc06                	sd	ra,56(sp)
    46e0:	f822                	sd	s0,48(sp)
    46e2:	f426                	sd	s1,40(sp)
    46e4:	f04a                	sd	s2,32(sp)
    46e6:	ec4e                	sd	s3,24(sp)
    46e8:	e852                	sd	s4,16(sp)
    46ea:	0080                	addi	s0,sp,64
    46ec:	84aa                	mv	s1,a0
  pid1 = fork();
    46ee:	00001097          	auipc	ra,0x1
    46f2:	676080e7          	jalr	1654(ra) # 5d64 <fork>
  if(pid1 < 0) {
    46f6:	00054563          	bltz	a0,4700 <preempt+0x24>
    46fa:	8a2a                	mv	s4,a0
  if(pid1 == 0)
    46fc:	e105                	bnez	a0,471c <preempt+0x40>
    for(;;)
    46fe:	a001                	j	46fe <preempt+0x22>
    printf("%s: fork failed", s);
    4700:	85a6                	mv	a1,s1
    4702:	00002517          	auipc	a0,0x2
    4706:	64e50513          	addi	a0,a0,1614 # 6d50 <malloc+0xb86>
    470a:	00002097          	auipc	ra,0x2
    470e:	a02080e7          	jalr	-1534(ra) # 610c <printf>
    exit(1);
    4712:	4505                	li	a0,1
    4714:	00001097          	auipc	ra,0x1
    4718:	658080e7          	jalr	1624(ra) # 5d6c <exit>
  pid2 = fork();
    471c:	00001097          	auipc	ra,0x1
    4720:	648080e7          	jalr	1608(ra) # 5d64 <fork>
    4724:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    4726:	00054463          	bltz	a0,472e <preempt+0x52>
  if(pid2 == 0)
    472a:	e105                	bnez	a0,474a <preempt+0x6e>
    for(;;)
    472c:	a001                	j	472c <preempt+0x50>
    printf("%s: fork failed\n", s);
    472e:	85a6                	mv	a1,s1
    4730:	00002517          	auipc	a0,0x2
    4734:	46050513          	addi	a0,a0,1120 # 6b90 <malloc+0x9c6>
    4738:	00002097          	auipc	ra,0x2
    473c:	9d4080e7          	jalr	-1580(ra) # 610c <printf>
    exit(1);
    4740:	4505                	li	a0,1
    4742:	00001097          	auipc	ra,0x1
    4746:	62a080e7          	jalr	1578(ra) # 5d6c <exit>
  pipe(pfds);
    474a:	fc840513          	addi	a0,s0,-56
    474e:	00001097          	auipc	ra,0x1
    4752:	636080e7          	jalr	1590(ra) # 5d84 <pipe>
  pid3 = fork();
    4756:	00001097          	auipc	ra,0x1
    475a:	60e080e7          	jalr	1550(ra) # 5d64 <fork>
    475e:	892a                	mv	s2,a0
  if(pid3 < 0) {
    4760:	02054e63          	bltz	a0,479c <preempt+0xc0>
  if(pid3 == 0){
    4764:	e525                	bnez	a0,47cc <preempt+0xf0>
    close(pfds[0]);
    4766:	fc842503          	lw	a0,-56(s0)
    476a:	00001097          	auipc	ra,0x1
    476e:	632080e7          	jalr	1586(ra) # 5d9c <close>
    if(write(pfds[1], "x", 1) != 1)
    4772:	4605                	li	a2,1
    4774:	00002597          	auipc	a1,0x2
    4778:	c0458593          	addi	a1,a1,-1020 # 6378 <malloc+0x1ae>
    477c:	fcc42503          	lw	a0,-52(s0)
    4780:	00001097          	auipc	ra,0x1
    4784:	614080e7          	jalr	1556(ra) # 5d94 <write>
    4788:	4785                	li	a5,1
    478a:	02f51763          	bne	a0,a5,47b8 <preempt+0xdc>
    close(pfds[1]);
    478e:	fcc42503          	lw	a0,-52(s0)
    4792:	00001097          	auipc	ra,0x1
    4796:	60a080e7          	jalr	1546(ra) # 5d9c <close>
    for(;;)
    479a:	a001                	j	479a <preempt+0xbe>
     printf("%s: fork failed\n", s);
    479c:	85a6                	mv	a1,s1
    479e:	00002517          	auipc	a0,0x2
    47a2:	3f250513          	addi	a0,a0,1010 # 6b90 <malloc+0x9c6>
    47a6:	00002097          	auipc	ra,0x2
    47aa:	966080e7          	jalr	-1690(ra) # 610c <printf>
     exit(1);
    47ae:	4505                	li	a0,1
    47b0:	00001097          	auipc	ra,0x1
    47b4:	5bc080e7          	jalr	1468(ra) # 5d6c <exit>
      printf("%s: preempt write error", s);
    47b8:	85a6                	mv	a1,s1
    47ba:	00003517          	auipc	a0,0x3
    47be:	6e650513          	addi	a0,a0,1766 # 7ea0 <malloc+0x1cd6>
    47c2:	00002097          	auipc	ra,0x2
    47c6:	94a080e7          	jalr	-1718(ra) # 610c <printf>
    47ca:	b7d1                	j	478e <preempt+0xb2>
  close(pfds[1]);
    47cc:	fcc42503          	lw	a0,-52(s0)
    47d0:	00001097          	auipc	ra,0x1
    47d4:	5cc080e7          	jalr	1484(ra) # 5d9c <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    47d8:	660d                	lui	a2,0x3
    47da:	00008597          	auipc	a1,0x8
    47de:	49e58593          	addi	a1,a1,1182 # cc78 <buf>
    47e2:	fc842503          	lw	a0,-56(s0)
    47e6:	00001097          	auipc	ra,0x1
    47ea:	5a6080e7          	jalr	1446(ra) # 5d8c <read>
    47ee:	4785                	li	a5,1
    47f0:	02f50363          	beq	a0,a5,4816 <preempt+0x13a>
    printf("%s: preempt read error", s);
    47f4:	85a6                	mv	a1,s1
    47f6:	00003517          	auipc	a0,0x3
    47fa:	6c250513          	addi	a0,a0,1730 # 7eb8 <malloc+0x1cee>
    47fe:	00002097          	auipc	ra,0x2
    4802:	90e080e7          	jalr	-1778(ra) # 610c <printf>
}
    4806:	70e2                	ld	ra,56(sp)
    4808:	7442                	ld	s0,48(sp)
    480a:	74a2                	ld	s1,40(sp)
    480c:	7902                	ld	s2,32(sp)
    480e:	69e2                	ld	s3,24(sp)
    4810:	6a42                	ld	s4,16(sp)
    4812:	6121                	addi	sp,sp,64
    4814:	8082                	ret
  close(pfds[0]);
    4816:	fc842503          	lw	a0,-56(s0)
    481a:	00001097          	auipc	ra,0x1
    481e:	582080e7          	jalr	1410(ra) # 5d9c <close>
  printf("kill... ");
    4822:	00003517          	auipc	a0,0x3
    4826:	6ae50513          	addi	a0,a0,1710 # 7ed0 <malloc+0x1d06>
    482a:	00002097          	auipc	ra,0x2
    482e:	8e2080e7          	jalr	-1822(ra) # 610c <printf>
  kill(pid1);
    4832:	8552                	mv	a0,s4
    4834:	00001097          	auipc	ra,0x1
    4838:	570080e7          	jalr	1392(ra) # 5da4 <kill>
  kill(pid2);
    483c:	854e                	mv	a0,s3
    483e:	00001097          	auipc	ra,0x1
    4842:	566080e7          	jalr	1382(ra) # 5da4 <kill>
  kill(pid3);
    4846:	854a                	mv	a0,s2
    4848:	00001097          	auipc	ra,0x1
    484c:	55c080e7          	jalr	1372(ra) # 5da4 <kill>
  printf("wait... ");
    4850:	00003517          	auipc	a0,0x3
    4854:	69050513          	addi	a0,a0,1680 # 7ee0 <malloc+0x1d16>
    4858:	00002097          	auipc	ra,0x2
    485c:	8b4080e7          	jalr	-1868(ra) # 610c <printf>
  wait(0,"");
    4860:	00003597          	auipc	a1,0x3
    4864:	09858593          	addi	a1,a1,152 # 78f8 <malloc+0x172e>
    4868:	4501                	li	a0,0
    486a:	00001097          	auipc	ra,0x1
    486e:	512080e7          	jalr	1298(ra) # 5d7c <wait>
  wait(0,"");
    4872:	00003597          	auipc	a1,0x3
    4876:	08658593          	addi	a1,a1,134 # 78f8 <malloc+0x172e>
    487a:	4501                	li	a0,0
    487c:	00001097          	auipc	ra,0x1
    4880:	500080e7          	jalr	1280(ra) # 5d7c <wait>
  wait(0,"");
    4884:	00003597          	auipc	a1,0x3
    4888:	07458593          	addi	a1,a1,116 # 78f8 <malloc+0x172e>
    488c:	4501                	li	a0,0
    488e:	00001097          	auipc	ra,0x1
    4892:	4ee080e7          	jalr	1262(ra) # 5d7c <wait>
    4896:	bf85                	j	4806 <preempt+0x12a>

0000000000004898 <reparent>:
{
    4898:	7139                	addi	sp,sp,-64
    489a:	fc06                	sd	ra,56(sp)
    489c:	f822                	sd	s0,48(sp)
    489e:	f426                	sd	s1,40(sp)
    48a0:	f04a                	sd	s2,32(sp)
    48a2:	ec4e                	sd	s3,24(sp)
    48a4:	e852                	sd	s4,16(sp)
    48a6:	e456                	sd	s5,8(sp)
    48a8:	0080                	addi	s0,sp,64
    48aa:	8a2a                	mv	s4,a0
  int master_pid = getpid();
    48ac:	00001097          	auipc	ra,0x1
    48b0:	548080e7          	jalr	1352(ra) # 5df4 <getpid>
    48b4:	8aaa                	mv	s5,a0
    48b6:	0c800913          	li	s2,200
      if(wait(0,"") != pid){
    48ba:	00003997          	auipc	s3,0x3
    48be:	03e98993          	addi	s3,s3,62 # 78f8 <malloc+0x172e>
    int pid = fork();
    48c2:	00001097          	auipc	ra,0x1
    48c6:	4a2080e7          	jalr	1186(ra) # 5d64 <fork>
    48ca:	84aa                	mv	s1,a0
    if(pid < 0){
    48cc:	02054363          	bltz	a0,48f2 <reparent+0x5a>
    if(pid){
    48d0:	cd29                	beqz	a0,492a <reparent+0x92>
      if(wait(0,"") != pid){
    48d2:	85ce                	mv	a1,s3
    48d4:	4501                	li	a0,0
    48d6:	00001097          	auipc	ra,0x1
    48da:	4a6080e7          	jalr	1190(ra) # 5d7c <wait>
    48de:	02951863          	bne	a0,s1,490e <reparent+0x76>
  for(int i = 0; i < 200; i++){
    48e2:	397d                	addiw	s2,s2,-1
    48e4:	fc091fe3          	bnez	s2,48c2 <reparent+0x2a>
  exit(0);
    48e8:	4501                	li	a0,0
    48ea:	00001097          	auipc	ra,0x1
    48ee:	482080e7          	jalr	1154(ra) # 5d6c <exit>
      printf("%s: fork failed\n", s);
    48f2:	85d2                	mv	a1,s4
    48f4:	00002517          	auipc	a0,0x2
    48f8:	29c50513          	addi	a0,a0,668 # 6b90 <malloc+0x9c6>
    48fc:	00002097          	auipc	ra,0x2
    4900:	810080e7          	jalr	-2032(ra) # 610c <printf>
      exit(1);
    4904:	4505                	li	a0,1
    4906:	00001097          	auipc	ra,0x1
    490a:	466080e7          	jalr	1126(ra) # 5d6c <exit>
        printf("%s: wait wrong pid\n", s);
    490e:	85d2                	mv	a1,s4
    4910:	00002517          	auipc	a0,0x2
    4914:	40850513          	addi	a0,a0,1032 # 6d18 <malloc+0xb4e>
    4918:	00001097          	auipc	ra,0x1
    491c:	7f4080e7          	jalr	2036(ra) # 610c <printf>
        exit(1);
    4920:	4505                	li	a0,1
    4922:	00001097          	auipc	ra,0x1
    4926:	44a080e7          	jalr	1098(ra) # 5d6c <exit>
      int pid2 = fork();
    492a:	00001097          	auipc	ra,0x1
    492e:	43a080e7          	jalr	1082(ra) # 5d64 <fork>
      if(pid2 < 0){
    4932:	00054763          	bltz	a0,4940 <reparent+0xa8>
      exit(0);
    4936:	4501                	li	a0,0
    4938:	00001097          	auipc	ra,0x1
    493c:	434080e7          	jalr	1076(ra) # 5d6c <exit>
        kill(master_pid);
    4940:	8556                	mv	a0,s5
    4942:	00001097          	auipc	ra,0x1
    4946:	462080e7          	jalr	1122(ra) # 5da4 <kill>
        exit(1);
    494a:	4505                	li	a0,1
    494c:	00001097          	auipc	ra,0x1
    4950:	420080e7          	jalr	1056(ra) # 5d6c <exit>

0000000000004954 <sbrkfail>:
{
    4954:	7119                	addi	sp,sp,-128
    4956:	fc86                	sd	ra,120(sp)
    4958:	f8a2                	sd	s0,112(sp)
    495a:	f4a6                	sd	s1,104(sp)
    495c:	f0ca                	sd	s2,96(sp)
    495e:	ecce                	sd	s3,88(sp)
    4960:	e8d2                	sd	s4,80(sp)
    4962:	e4d6                	sd	s5,72(sp)
    4964:	e0da                	sd	s6,64(sp)
    4966:	0100                	addi	s0,sp,128
    4968:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    496a:	fb040513          	addi	a0,s0,-80
    496e:	00001097          	auipc	ra,0x1
    4972:	416080e7          	jalr	1046(ra) # 5d84 <pipe>
    4976:	e901                	bnez	a0,4986 <sbrkfail+0x32>
    4978:	f8040493          	addi	s1,s0,-128
    497c:	fa840a13          	addi	s4,s0,-88
    4980:	89a6                	mv	s3,s1
    if(pids[i] != -1)
    4982:	5afd                	li	s5,-1
    4984:	a08d                	j	49e6 <sbrkfail+0x92>
    printf("%s: pipe() failed\n", s);
    4986:	85ca                	mv	a1,s2
    4988:	00002517          	auipc	a0,0x2
    498c:	31050513          	addi	a0,a0,784 # 6c98 <malloc+0xace>
    4990:	00001097          	auipc	ra,0x1
    4994:	77c080e7          	jalr	1916(ra) # 610c <printf>
    exit(1);
    4998:	4505                	li	a0,1
    499a:	00001097          	auipc	ra,0x1
    499e:	3d2080e7          	jalr	978(ra) # 5d6c <exit>
      sbrk(BIG - (uint64)sbrk(0));
    49a2:	4501                	li	a0,0
    49a4:	00001097          	auipc	ra,0x1
    49a8:	458080e7          	jalr	1112(ra) # 5dfc <sbrk>
    49ac:	064007b7          	lui	a5,0x6400
    49b0:	40a7853b          	subw	a0,a5,a0
    49b4:	00001097          	auipc	ra,0x1
    49b8:	448080e7          	jalr	1096(ra) # 5dfc <sbrk>
      write(fds[1], "x", 1);
    49bc:	4605                	li	a2,1
    49be:	00002597          	auipc	a1,0x2
    49c2:	9ba58593          	addi	a1,a1,-1606 # 6378 <malloc+0x1ae>
    49c6:	fb442503          	lw	a0,-76(s0)
    49ca:	00001097          	auipc	ra,0x1
    49ce:	3ca080e7          	jalr	970(ra) # 5d94 <write>
      for(;;) sleep(1000);
    49d2:	3e800513          	li	a0,1000
    49d6:	00001097          	auipc	ra,0x1
    49da:	42e080e7          	jalr	1070(ra) # 5e04 <sleep>
    49de:	bfd5                	j	49d2 <sbrkfail+0x7e>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    49e0:	0991                	addi	s3,s3,4
    49e2:	03498563          	beq	s3,s4,4a0c <sbrkfail+0xb8>
    if((pids[i] = fork()) == 0){
    49e6:	00001097          	auipc	ra,0x1
    49ea:	37e080e7          	jalr	894(ra) # 5d64 <fork>
    49ee:	00a9a023          	sw	a0,0(s3)
    49f2:	d945                	beqz	a0,49a2 <sbrkfail+0x4e>
    if(pids[i] != -1)
    49f4:	ff5506e3          	beq	a0,s5,49e0 <sbrkfail+0x8c>
      read(fds[0], &scratch, 1);
    49f8:	4605                	li	a2,1
    49fa:	faf40593          	addi	a1,s0,-81
    49fe:	fb042503          	lw	a0,-80(s0)
    4a02:	00001097          	auipc	ra,0x1
    4a06:	38a080e7          	jalr	906(ra) # 5d8c <read>
    4a0a:	bfd9                	j	49e0 <sbrkfail+0x8c>
  c = sbrk(PGSIZE);
    4a0c:	6505                	lui	a0,0x1
    4a0e:	00001097          	auipc	ra,0x1
    4a12:	3ee080e7          	jalr	1006(ra) # 5dfc <sbrk>
    4a16:	89aa                	mv	s3,a0
    if(pids[i] == -1)
    4a18:	5afd                	li	s5,-1
    wait(0,"");
    4a1a:	00003b17          	auipc	s6,0x3
    4a1e:	edeb0b13          	addi	s6,s6,-290 # 78f8 <malloc+0x172e>
    4a22:	a021                	j	4a2a <sbrkfail+0xd6>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4a24:	0491                	addi	s1,s1,4
    4a26:	03448063          	beq	s1,s4,4a46 <sbrkfail+0xf2>
    if(pids[i] == -1)
    4a2a:	4088                	lw	a0,0(s1)
    4a2c:	ff550ce3          	beq	a0,s5,4a24 <sbrkfail+0xd0>
    kill(pids[i]);
    4a30:	00001097          	auipc	ra,0x1
    4a34:	374080e7          	jalr	884(ra) # 5da4 <kill>
    wait(0,"");
    4a38:	85da                	mv	a1,s6
    4a3a:	4501                	li	a0,0
    4a3c:	00001097          	auipc	ra,0x1
    4a40:	340080e7          	jalr	832(ra) # 5d7c <wait>
    4a44:	b7c5                	j	4a24 <sbrkfail+0xd0>
  if(c == (char*)0xffffffffffffffffL){
    4a46:	57fd                	li	a5,-1
    4a48:	04f98663          	beq	s3,a5,4a94 <sbrkfail+0x140>
  pid = fork();
    4a4c:	00001097          	auipc	ra,0x1
    4a50:	318080e7          	jalr	792(ra) # 5d64 <fork>
    4a54:	84aa                	mv	s1,a0
  if(pid < 0){
    4a56:	04054d63          	bltz	a0,4ab0 <sbrkfail+0x15c>
  if(pid == 0){
    4a5a:	c92d                	beqz	a0,4acc <sbrkfail+0x178>
  wait(&xstatus,"");
    4a5c:	00003597          	auipc	a1,0x3
    4a60:	e9c58593          	addi	a1,a1,-356 # 78f8 <malloc+0x172e>
    4a64:	fbc40513          	addi	a0,s0,-68
    4a68:	00001097          	auipc	ra,0x1
    4a6c:	314080e7          	jalr	788(ra) # 5d7c <wait>
  if(xstatus != -1 && xstatus != 2)
    4a70:	fbc42783          	lw	a5,-68(s0)
    4a74:	577d                	li	a4,-1
    4a76:	00e78563          	beq	a5,a4,4a80 <sbrkfail+0x12c>
    4a7a:	4709                	li	a4,2
    4a7c:	08e79e63          	bne	a5,a4,4b18 <sbrkfail+0x1c4>
}
    4a80:	70e6                	ld	ra,120(sp)
    4a82:	7446                	ld	s0,112(sp)
    4a84:	74a6                	ld	s1,104(sp)
    4a86:	7906                	ld	s2,96(sp)
    4a88:	69e6                	ld	s3,88(sp)
    4a8a:	6a46                	ld	s4,80(sp)
    4a8c:	6aa6                	ld	s5,72(sp)
    4a8e:	6b06                	ld	s6,64(sp)
    4a90:	6109                	addi	sp,sp,128
    4a92:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4a94:	85ca                	mv	a1,s2
    4a96:	00003517          	auipc	a0,0x3
    4a9a:	45a50513          	addi	a0,a0,1114 # 7ef0 <malloc+0x1d26>
    4a9e:	00001097          	auipc	ra,0x1
    4aa2:	66e080e7          	jalr	1646(ra) # 610c <printf>
    exit(1);
    4aa6:	4505                	li	a0,1
    4aa8:	00001097          	auipc	ra,0x1
    4aac:	2c4080e7          	jalr	708(ra) # 5d6c <exit>
    printf("%s: fork failed\n", s);
    4ab0:	85ca                	mv	a1,s2
    4ab2:	00002517          	auipc	a0,0x2
    4ab6:	0de50513          	addi	a0,a0,222 # 6b90 <malloc+0x9c6>
    4aba:	00001097          	auipc	ra,0x1
    4abe:	652080e7          	jalr	1618(ra) # 610c <printf>
    exit(1);
    4ac2:	4505                	li	a0,1
    4ac4:	00001097          	auipc	ra,0x1
    4ac8:	2a8080e7          	jalr	680(ra) # 5d6c <exit>
    a = sbrk(0);
    4acc:	4501                	li	a0,0
    4ace:	00001097          	auipc	ra,0x1
    4ad2:	32e080e7          	jalr	814(ra) # 5dfc <sbrk>
    4ad6:	89aa                	mv	s3,a0
    sbrk(10*BIG);
    4ad8:	3e800537          	lui	a0,0x3e800
    4adc:	00001097          	auipc	ra,0x1
    4ae0:	320080e7          	jalr	800(ra) # 5dfc <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4ae4:	874e                	mv	a4,s3
    4ae6:	3e8007b7          	lui	a5,0x3e800
    4aea:	97ce                	add	a5,a5,s3
    4aec:	6685                	lui	a3,0x1
      n += *(a+i);
    4aee:	00074603          	lbu	a2,0(a4)
    4af2:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4af4:	9736                	add	a4,a4,a3
    4af6:	fef71ce3          	bne	a4,a5,4aee <sbrkfail+0x19a>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4afa:	8626                	mv	a2,s1
    4afc:	85ca                	mv	a1,s2
    4afe:	00003517          	auipc	a0,0x3
    4b02:	41250513          	addi	a0,a0,1042 # 7f10 <malloc+0x1d46>
    4b06:	00001097          	auipc	ra,0x1
    4b0a:	606080e7          	jalr	1542(ra) # 610c <printf>
    exit(1);
    4b0e:	4505                	li	a0,1
    4b10:	00001097          	auipc	ra,0x1
    4b14:	25c080e7          	jalr	604(ra) # 5d6c <exit>
    exit(1);
    4b18:	4505                	li	a0,1
    4b1a:	00001097          	auipc	ra,0x1
    4b1e:	252080e7          	jalr	594(ra) # 5d6c <exit>

0000000000004b22 <mem>:
{
    4b22:	7139                	addi	sp,sp,-64
    4b24:	fc06                	sd	ra,56(sp)
    4b26:	f822                	sd	s0,48(sp)
    4b28:	f426                	sd	s1,40(sp)
    4b2a:	f04a                	sd	s2,32(sp)
    4b2c:	ec4e                	sd	s3,24(sp)
    4b2e:	0080                	addi	s0,sp,64
    4b30:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    4b32:	00001097          	auipc	ra,0x1
    4b36:	232080e7          	jalr	562(ra) # 5d64 <fork>
    m1 = 0;
    4b3a:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4b3c:	6909                	lui	s2,0x2
    4b3e:	71190913          	addi	s2,s2,1809 # 2711 <copyinstr3+0x39>
  if((pid = fork()) == 0){
    4b42:	ed39                	bnez	a0,4ba0 <mem+0x7e>
    while((m2 = malloc(10001)) != 0){
    4b44:	854a                	mv	a0,s2
    4b46:	00001097          	auipc	ra,0x1
    4b4a:	684080e7          	jalr	1668(ra) # 61ca <malloc>
    4b4e:	c501                	beqz	a0,4b56 <mem+0x34>
      *(char**)m2 = m1;
    4b50:	e104                	sd	s1,0(a0)
      m1 = m2;
    4b52:	84aa                	mv	s1,a0
    4b54:	bfc5                	j	4b44 <mem+0x22>
    while(m1){
    4b56:	c881                	beqz	s1,4b66 <mem+0x44>
      m2 = *(char**)m1;
    4b58:	8526                	mv	a0,s1
    4b5a:	6084                	ld	s1,0(s1)
      free(m1);
    4b5c:	00001097          	auipc	ra,0x1
    4b60:	5e6080e7          	jalr	1510(ra) # 6142 <free>
    while(m1){
    4b64:	f8f5                	bnez	s1,4b58 <mem+0x36>
    m1 = malloc(1024*20);
    4b66:	6515                	lui	a0,0x5
    4b68:	00001097          	auipc	ra,0x1
    4b6c:	662080e7          	jalr	1634(ra) # 61ca <malloc>
    if(m1 == 0){
    4b70:	c911                	beqz	a0,4b84 <mem+0x62>
    free(m1);
    4b72:	00001097          	auipc	ra,0x1
    4b76:	5d0080e7          	jalr	1488(ra) # 6142 <free>
    exit(0);
    4b7a:	4501                	li	a0,0
    4b7c:	00001097          	auipc	ra,0x1
    4b80:	1f0080e7          	jalr	496(ra) # 5d6c <exit>
      printf("couldn't allocate mem?!!\n", s);
    4b84:	85ce                	mv	a1,s3
    4b86:	00003517          	auipc	a0,0x3
    4b8a:	3ba50513          	addi	a0,a0,954 # 7f40 <malloc+0x1d76>
    4b8e:	00001097          	auipc	ra,0x1
    4b92:	57e080e7          	jalr	1406(ra) # 610c <printf>
      exit(1);
    4b96:	4505                	li	a0,1
    4b98:	00001097          	auipc	ra,0x1
    4b9c:	1d4080e7          	jalr	468(ra) # 5d6c <exit>
    wait(&xstatus,"");
    4ba0:	00003597          	auipc	a1,0x3
    4ba4:	d5858593          	addi	a1,a1,-680 # 78f8 <malloc+0x172e>
    4ba8:	fcc40513          	addi	a0,s0,-52
    4bac:	00001097          	auipc	ra,0x1
    4bb0:	1d0080e7          	jalr	464(ra) # 5d7c <wait>
    if(xstatus == -1){
    4bb4:	fcc42503          	lw	a0,-52(s0)
    4bb8:	57fd                	li	a5,-1
    4bba:	00f50663          	beq	a0,a5,4bc6 <mem+0xa4>
    exit(xstatus);
    4bbe:	00001097          	auipc	ra,0x1
    4bc2:	1ae080e7          	jalr	430(ra) # 5d6c <exit>
      exit(0);
    4bc6:	4501                	li	a0,0
    4bc8:	00001097          	auipc	ra,0x1
    4bcc:	1a4080e7          	jalr	420(ra) # 5d6c <exit>

0000000000004bd0 <sharedfd>:
{
    4bd0:	7159                	addi	sp,sp,-112
    4bd2:	f486                	sd	ra,104(sp)
    4bd4:	f0a2                	sd	s0,96(sp)
    4bd6:	eca6                	sd	s1,88(sp)
    4bd8:	e8ca                	sd	s2,80(sp)
    4bda:	e4ce                	sd	s3,72(sp)
    4bdc:	e0d2                	sd	s4,64(sp)
    4bde:	fc56                	sd	s5,56(sp)
    4be0:	f85a                	sd	s6,48(sp)
    4be2:	f45e                	sd	s7,40(sp)
    4be4:	1880                	addi	s0,sp,112
    4be6:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4be8:	00003517          	auipc	a0,0x3
    4bec:	37850513          	addi	a0,a0,888 # 7f60 <malloc+0x1d96>
    4bf0:	00001097          	auipc	ra,0x1
    4bf4:	1d4080e7          	jalr	468(ra) # 5dc4 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4bf8:	20200593          	li	a1,514
    4bfc:	00003517          	auipc	a0,0x3
    4c00:	36450513          	addi	a0,a0,868 # 7f60 <malloc+0x1d96>
    4c04:	00001097          	auipc	ra,0x1
    4c08:	1b0080e7          	jalr	432(ra) # 5db4 <open>
  if(fd < 0){
    4c0c:	04054a63          	bltz	a0,4c60 <sharedfd+0x90>
    4c10:	892a                	mv	s2,a0
  pid = fork();
    4c12:	00001097          	auipc	ra,0x1
    4c16:	152080e7          	jalr	338(ra) # 5d64 <fork>
    4c1a:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4c1c:	06300593          	li	a1,99
    4c20:	c119                	beqz	a0,4c26 <sharedfd+0x56>
    4c22:	07000593          	li	a1,112
    4c26:	4629                	li	a2,10
    4c28:	fa040513          	addi	a0,s0,-96
    4c2c:	00001097          	auipc	ra,0x1
    4c30:	f3c080e7          	jalr	-196(ra) # 5b68 <memset>
    4c34:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    4c38:	4629                	li	a2,10
    4c3a:	fa040593          	addi	a1,s0,-96
    4c3e:	854a                	mv	a0,s2
    4c40:	00001097          	auipc	ra,0x1
    4c44:	154080e7          	jalr	340(ra) # 5d94 <write>
    4c48:	47a9                	li	a5,10
    4c4a:	02f51963          	bne	a0,a5,4c7c <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4c4e:	34fd                	addiw	s1,s1,-1
    4c50:	f4e5                	bnez	s1,4c38 <sharedfd+0x68>
  if(pid == 0) {
    4c52:	04099363          	bnez	s3,4c98 <sharedfd+0xc8>
    exit(0);
    4c56:	4501                	li	a0,0
    4c58:	00001097          	auipc	ra,0x1
    4c5c:	114080e7          	jalr	276(ra) # 5d6c <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4c60:	85d2                	mv	a1,s4
    4c62:	00003517          	auipc	a0,0x3
    4c66:	30e50513          	addi	a0,a0,782 # 7f70 <malloc+0x1da6>
    4c6a:	00001097          	auipc	ra,0x1
    4c6e:	4a2080e7          	jalr	1186(ra) # 610c <printf>
    exit(1);
    4c72:	4505                	li	a0,1
    4c74:	00001097          	auipc	ra,0x1
    4c78:	0f8080e7          	jalr	248(ra) # 5d6c <exit>
      printf("%s: write sharedfd failed\n", s);
    4c7c:	85d2                	mv	a1,s4
    4c7e:	00003517          	auipc	a0,0x3
    4c82:	31a50513          	addi	a0,a0,794 # 7f98 <malloc+0x1dce>
    4c86:	00001097          	auipc	ra,0x1
    4c8a:	486080e7          	jalr	1158(ra) # 610c <printf>
      exit(1);
    4c8e:	4505                	li	a0,1
    4c90:	00001097          	auipc	ra,0x1
    4c94:	0dc080e7          	jalr	220(ra) # 5d6c <exit>
    wait(&xstatus,"");
    4c98:	00003597          	auipc	a1,0x3
    4c9c:	c6058593          	addi	a1,a1,-928 # 78f8 <malloc+0x172e>
    4ca0:	f9c40513          	addi	a0,s0,-100
    4ca4:	00001097          	auipc	ra,0x1
    4ca8:	0d8080e7          	jalr	216(ra) # 5d7c <wait>
    if(xstatus != 0)
    4cac:	f9c42983          	lw	s3,-100(s0)
    4cb0:	00098763          	beqz	s3,4cbe <sharedfd+0xee>
      exit(xstatus);
    4cb4:	854e                	mv	a0,s3
    4cb6:	00001097          	auipc	ra,0x1
    4cba:	0b6080e7          	jalr	182(ra) # 5d6c <exit>
  close(fd);
    4cbe:	854a                	mv	a0,s2
    4cc0:	00001097          	auipc	ra,0x1
    4cc4:	0dc080e7          	jalr	220(ra) # 5d9c <close>
  fd = open("sharedfd", 0);
    4cc8:	4581                	li	a1,0
    4cca:	00003517          	auipc	a0,0x3
    4cce:	29650513          	addi	a0,a0,662 # 7f60 <malloc+0x1d96>
    4cd2:	00001097          	auipc	ra,0x1
    4cd6:	0e2080e7          	jalr	226(ra) # 5db4 <open>
    4cda:	8baa                	mv	s7,a0
  nc = np = 0;
    4cdc:	8ace                	mv	s5,s3
  if(fd < 0){
    4cde:	02054563          	bltz	a0,4d08 <sharedfd+0x138>
    4ce2:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4ce6:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4cea:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4cee:	4629                	li	a2,10
    4cf0:	fa040593          	addi	a1,s0,-96
    4cf4:	855e                	mv	a0,s7
    4cf6:	00001097          	auipc	ra,0x1
    4cfa:	096080e7          	jalr	150(ra) # 5d8c <read>
    4cfe:	02a05f63          	blez	a0,4d3c <sharedfd+0x16c>
    4d02:	fa040793          	addi	a5,s0,-96
    4d06:	a01d                	j	4d2c <sharedfd+0x15c>
    printf("%s: cannot open sharedfd for reading\n", s);
    4d08:	85d2                	mv	a1,s4
    4d0a:	00003517          	auipc	a0,0x3
    4d0e:	2ae50513          	addi	a0,a0,686 # 7fb8 <malloc+0x1dee>
    4d12:	00001097          	auipc	ra,0x1
    4d16:	3fa080e7          	jalr	1018(ra) # 610c <printf>
    exit(1);
    4d1a:	4505                	li	a0,1
    4d1c:	00001097          	auipc	ra,0x1
    4d20:	050080e7          	jalr	80(ra) # 5d6c <exit>
        nc++;
    4d24:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    4d26:	0785                	addi	a5,a5,1
    4d28:	fd2783e3          	beq	a5,s2,4cee <sharedfd+0x11e>
      if(buf[i] == 'c')
    4d2c:	0007c703          	lbu	a4,0(a5) # 3e800000 <base+0x3e7f0388>
    4d30:	fe970ae3          	beq	a4,s1,4d24 <sharedfd+0x154>
      if(buf[i] == 'p')
    4d34:	ff6719e3          	bne	a4,s6,4d26 <sharedfd+0x156>
        np++;
    4d38:	2a85                	addiw	s5,s5,1
    4d3a:	b7f5                	j	4d26 <sharedfd+0x156>
  close(fd);
    4d3c:	855e                	mv	a0,s7
    4d3e:	00001097          	auipc	ra,0x1
    4d42:	05e080e7          	jalr	94(ra) # 5d9c <close>
  unlink("sharedfd");
    4d46:	00003517          	auipc	a0,0x3
    4d4a:	21a50513          	addi	a0,a0,538 # 7f60 <malloc+0x1d96>
    4d4e:	00001097          	auipc	ra,0x1
    4d52:	076080e7          	jalr	118(ra) # 5dc4 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4d56:	6789                	lui	a5,0x2
    4d58:	71078793          	addi	a5,a5,1808 # 2710 <copyinstr3+0x38>
    4d5c:	00f99763          	bne	s3,a5,4d6a <sharedfd+0x19a>
    4d60:	6789                	lui	a5,0x2
    4d62:	71078793          	addi	a5,a5,1808 # 2710 <copyinstr3+0x38>
    4d66:	02fa8063          	beq	s5,a5,4d86 <sharedfd+0x1b6>
    printf("%s: nc/np test fails\n", s);
    4d6a:	85d2                	mv	a1,s4
    4d6c:	00003517          	auipc	a0,0x3
    4d70:	27450513          	addi	a0,a0,628 # 7fe0 <malloc+0x1e16>
    4d74:	00001097          	auipc	ra,0x1
    4d78:	398080e7          	jalr	920(ra) # 610c <printf>
    exit(1);
    4d7c:	4505                	li	a0,1
    4d7e:	00001097          	auipc	ra,0x1
    4d82:	fee080e7          	jalr	-18(ra) # 5d6c <exit>
    exit(0);
    4d86:	4501                	li	a0,0
    4d88:	00001097          	auipc	ra,0x1
    4d8c:	fe4080e7          	jalr	-28(ra) # 5d6c <exit>

0000000000004d90 <fourfiles>:
{
    4d90:	7171                	addi	sp,sp,-176
    4d92:	f506                	sd	ra,168(sp)
    4d94:	f122                	sd	s0,160(sp)
    4d96:	ed26                	sd	s1,152(sp)
    4d98:	e94a                	sd	s2,144(sp)
    4d9a:	e54e                	sd	s3,136(sp)
    4d9c:	e152                	sd	s4,128(sp)
    4d9e:	fcd6                	sd	s5,120(sp)
    4da0:	f8da                	sd	s6,112(sp)
    4da2:	f4de                	sd	s7,104(sp)
    4da4:	f0e2                	sd	s8,96(sp)
    4da6:	ece6                	sd	s9,88(sp)
    4da8:	e8ea                	sd	s10,80(sp)
    4daa:	e4ee                	sd	s11,72(sp)
    4dac:	1900                	addi	s0,sp,176
    4dae:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    4db0:	00001797          	auipc	a5,0x1
    4db4:	50078793          	addi	a5,a5,1280 # 62b0 <malloc+0xe6>
    4db8:	f6f43823          	sd	a5,-144(s0)
    4dbc:	00001797          	auipc	a5,0x1
    4dc0:	4fc78793          	addi	a5,a5,1276 # 62b8 <malloc+0xee>
    4dc4:	f6f43c23          	sd	a5,-136(s0)
    4dc8:	00001797          	auipc	a5,0x1
    4dcc:	4f878793          	addi	a5,a5,1272 # 62c0 <malloc+0xf6>
    4dd0:	f8f43023          	sd	a5,-128(s0)
    4dd4:	00001797          	auipc	a5,0x1
    4dd8:	4f478793          	addi	a5,a5,1268 # 62c8 <malloc+0xfe>
    4ddc:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4de0:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4de4:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    4de6:	4481                	li	s1,0
    4de8:	4a11                	li	s4,4
    fname = names[pi];
    4dea:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4dee:	854e                	mv	a0,s3
    4df0:	00001097          	auipc	ra,0x1
    4df4:	fd4080e7          	jalr	-44(ra) # 5dc4 <unlink>
    pid = fork();
    4df8:	00001097          	auipc	ra,0x1
    4dfc:	f6c080e7          	jalr	-148(ra) # 5d64 <fork>
    if(pid < 0){
    4e00:	04054a63          	bltz	a0,4e54 <fourfiles+0xc4>
    if(pid == 0){
    4e04:	c535                	beqz	a0,4e70 <fourfiles+0xe0>
  for(pi = 0; pi < NCHILD; pi++){
    4e06:	2485                	addiw	s1,s1,1
    4e08:	0921                	addi	s2,s2,8
    4e0a:	ff4490e3          	bne	s1,s4,4dea <fourfiles+0x5a>
    4e0e:	4491                	li	s1,4
    wait(&xstatus,"");
    4e10:	00003917          	auipc	s2,0x3
    4e14:	ae890913          	addi	s2,s2,-1304 # 78f8 <malloc+0x172e>
    4e18:	85ca                	mv	a1,s2
    4e1a:	f6c40513          	addi	a0,s0,-148
    4e1e:	00001097          	auipc	ra,0x1
    4e22:	f5e080e7          	jalr	-162(ra) # 5d7c <wait>
    if(xstatus != 0)
    4e26:	f6c42503          	lw	a0,-148(s0)
    4e2a:	ed69                	bnez	a0,4f04 <fourfiles+0x174>
  for(pi = 0; pi < NCHILD; pi++){
    4e2c:	34fd                	addiw	s1,s1,-1
    4e2e:	f4ed                	bnez	s1,4e18 <fourfiles+0x88>
    4e30:	03000b13          	li	s6,48
    total = 0;
    4e34:	f4a43c23          	sd	a0,-168(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4e38:	00008a17          	auipc	s4,0x8
    4e3c:	e40a0a13          	addi	s4,s4,-448 # cc78 <buf>
    4e40:	00008a97          	auipc	s5,0x8
    4e44:	e39a8a93          	addi	s5,s5,-455 # cc79 <buf+0x1>
    if(total != N*SZ){
    4e48:	6d05                	lui	s10,0x1
    4e4a:	770d0d13          	addi	s10,s10,1904 # 1770 <exectest+0x1e>
  for(i = 0; i < NCHILD; i++){
    4e4e:	03400d93          	li	s11,52
    4e52:	a23d                	j	4f80 <fourfiles+0x1f0>
      printf("fork failed\n", s);
    4e54:	85e6                	mv	a1,s9
    4e56:	00002517          	auipc	a0,0x2
    4e5a:	14250513          	addi	a0,a0,322 # 6f98 <malloc+0xdce>
    4e5e:	00001097          	auipc	ra,0x1
    4e62:	2ae080e7          	jalr	686(ra) # 610c <printf>
      exit(1);
    4e66:	4505                	li	a0,1
    4e68:	00001097          	auipc	ra,0x1
    4e6c:	f04080e7          	jalr	-252(ra) # 5d6c <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4e70:	20200593          	li	a1,514
    4e74:	854e                	mv	a0,s3
    4e76:	00001097          	auipc	ra,0x1
    4e7a:	f3e080e7          	jalr	-194(ra) # 5db4 <open>
    4e7e:	892a                	mv	s2,a0
      if(fd < 0){
    4e80:	04054763          	bltz	a0,4ece <fourfiles+0x13e>
      memset(buf, '0'+pi, SZ);
    4e84:	1f400613          	li	a2,500
    4e88:	0304859b          	addiw	a1,s1,48
    4e8c:	00008517          	auipc	a0,0x8
    4e90:	dec50513          	addi	a0,a0,-532 # cc78 <buf>
    4e94:	00001097          	auipc	ra,0x1
    4e98:	cd4080e7          	jalr	-812(ra) # 5b68 <memset>
    4e9c:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4e9e:	00008997          	auipc	s3,0x8
    4ea2:	dda98993          	addi	s3,s3,-550 # cc78 <buf>
    4ea6:	1f400613          	li	a2,500
    4eaa:	85ce                	mv	a1,s3
    4eac:	854a                	mv	a0,s2
    4eae:	00001097          	auipc	ra,0x1
    4eb2:	ee6080e7          	jalr	-282(ra) # 5d94 <write>
    4eb6:	85aa                	mv	a1,a0
    4eb8:	1f400793          	li	a5,500
    4ebc:	02f51763          	bne	a0,a5,4eea <fourfiles+0x15a>
      for(i = 0; i < N; i++){
    4ec0:	34fd                	addiw	s1,s1,-1
    4ec2:	f0f5                	bnez	s1,4ea6 <fourfiles+0x116>
      exit(0);
    4ec4:	4501                	li	a0,0
    4ec6:	00001097          	auipc	ra,0x1
    4eca:	ea6080e7          	jalr	-346(ra) # 5d6c <exit>
        printf("create failed\n", s);
    4ece:	85e6                	mv	a1,s9
    4ed0:	00003517          	auipc	a0,0x3
    4ed4:	12850513          	addi	a0,a0,296 # 7ff8 <malloc+0x1e2e>
    4ed8:	00001097          	auipc	ra,0x1
    4edc:	234080e7          	jalr	564(ra) # 610c <printf>
        exit(1);
    4ee0:	4505                	li	a0,1
    4ee2:	00001097          	auipc	ra,0x1
    4ee6:	e8a080e7          	jalr	-374(ra) # 5d6c <exit>
          printf("write failed %d\n", n);
    4eea:	00003517          	auipc	a0,0x3
    4eee:	11e50513          	addi	a0,a0,286 # 8008 <malloc+0x1e3e>
    4ef2:	00001097          	auipc	ra,0x1
    4ef6:	21a080e7          	jalr	538(ra) # 610c <printf>
          exit(1);
    4efa:	4505                	li	a0,1
    4efc:	00001097          	auipc	ra,0x1
    4f00:	e70080e7          	jalr	-400(ra) # 5d6c <exit>
      exit(xstatus);
    4f04:	00001097          	auipc	ra,0x1
    4f08:	e68080e7          	jalr	-408(ra) # 5d6c <exit>
          printf("wrong char\n", s);
    4f0c:	85e6                	mv	a1,s9
    4f0e:	00003517          	auipc	a0,0x3
    4f12:	11250513          	addi	a0,a0,274 # 8020 <malloc+0x1e56>
    4f16:	00001097          	auipc	ra,0x1
    4f1a:	1f6080e7          	jalr	502(ra) # 610c <printf>
          exit(1);
    4f1e:	4505                	li	a0,1
    4f20:	00001097          	auipc	ra,0x1
    4f24:	e4c080e7          	jalr	-436(ra) # 5d6c <exit>
      total += n;
    4f28:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4f2c:	660d                	lui	a2,0x3
    4f2e:	85d2                	mv	a1,s4
    4f30:	854e                	mv	a0,s3
    4f32:	00001097          	auipc	ra,0x1
    4f36:	e5a080e7          	jalr	-422(ra) # 5d8c <read>
    4f3a:	02a05363          	blez	a0,4f60 <fourfiles+0x1d0>
    4f3e:	00008797          	auipc	a5,0x8
    4f42:	d3a78793          	addi	a5,a5,-710 # cc78 <buf>
    4f46:	fff5069b          	addiw	a3,a0,-1
    4f4a:	1682                	slli	a3,a3,0x20
    4f4c:	9281                	srli	a3,a3,0x20
    4f4e:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    4f50:	0007c703          	lbu	a4,0(a5)
    4f54:	fa971ce3          	bne	a4,s1,4f0c <fourfiles+0x17c>
      for(j = 0; j < n; j++){
    4f58:	0785                	addi	a5,a5,1
    4f5a:	fed79be3          	bne	a5,a3,4f50 <fourfiles+0x1c0>
    4f5e:	b7e9                	j	4f28 <fourfiles+0x198>
    close(fd);
    4f60:	854e                	mv	a0,s3
    4f62:	00001097          	auipc	ra,0x1
    4f66:	e3a080e7          	jalr	-454(ra) # 5d9c <close>
    if(total != N*SZ){
    4f6a:	03a91963          	bne	s2,s10,4f9c <fourfiles+0x20c>
    unlink(fname);
    4f6e:	8562                	mv	a0,s8
    4f70:	00001097          	auipc	ra,0x1
    4f74:	e54080e7          	jalr	-428(ra) # 5dc4 <unlink>
  for(i = 0; i < NCHILD; i++){
    4f78:	0ba1                	addi	s7,s7,8
    4f7a:	2b05                	addiw	s6,s6,1
    4f7c:	03bb0e63          	beq	s6,s11,4fb8 <fourfiles+0x228>
    fname = names[i];
    4f80:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    4f84:	4581                	li	a1,0
    4f86:	8562                	mv	a0,s8
    4f88:	00001097          	auipc	ra,0x1
    4f8c:	e2c080e7          	jalr	-468(ra) # 5db4 <open>
    4f90:	89aa                	mv	s3,a0
    total = 0;
    4f92:	f5843903          	ld	s2,-168(s0)
        if(buf[j] != '0'+i){
    4f96:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4f9a:	bf49                	j	4f2c <fourfiles+0x19c>
      printf("wrong length %d\n", total);
    4f9c:	85ca                	mv	a1,s2
    4f9e:	00003517          	auipc	a0,0x3
    4fa2:	09250513          	addi	a0,a0,146 # 8030 <malloc+0x1e66>
    4fa6:	00001097          	auipc	ra,0x1
    4faa:	166080e7          	jalr	358(ra) # 610c <printf>
      exit(1);
    4fae:	4505                	li	a0,1
    4fb0:	00001097          	auipc	ra,0x1
    4fb4:	dbc080e7          	jalr	-580(ra) # 5d6c <exit>
}
    4fb8:	70aa                	ld	ra,168(sp)
    4fba:	740a                	ld	s0,160(sp)
    4fbc:	64ea                	ld	s1,152(sp)
    4fbe:	694a                	ld	s2,144(sp)
    4fc0:	69aa                	ld	s3,136(sp)
    4fc2:	6a0a                	ld	s4,128(sp)
    4fc4:	7ae6                	ld	s5,120(sp)
    4fc6:	7b46                	ld	s6,112(sp)
    4fc8:	7ba6                	ld	s7,104(sp)
    4fca:	7c06                	ld	s8,96(sp)
    4fcc:	6ce6                	ld	s9,88(sp)
    4fce:	6d46                	ld	s10,80(sp)
    4fd0:	6da6                	ld	s11,72(sp)
    4fd2:	614d                	addi	sp,sp,176
    4fd4:	8082                	ret

0000000000004fd6 <concreate>:
{
    4fd6:	7135                	addi	sp,sp,-160
    4fd8:	ed06                	sd	ra,152(sp)
    4fda:	e922                	sd	s0,144(sp)
    4fdc:	e526                	sd	s1,136(sp)
    4fde:	e14a                	sd	s2,128(sp)
    4fe0:	fcce                	sd	s3,120(sp)
    4fe2:	f8d2                	sd	s4,112(sp)
    4fe4:	f4d6                	sd	s5,104(sp)
    4fe6:	f0da                	sd	s6,96(sp)
    4fe8:	ecde                	sd	s7,88(sp)
    4fea:	e8e2                	sd	s8,80(sp)
    4fec:	1100                	addi	s0,sp,160
    4fee:	89aa                	mv	s3,a0
  file[0] = 'C';
    4ff0:	04300793          	li	a5,67
    4ff4:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4ff8:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4ffc:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4ffe:	4b8d                	li	s7,3
    5000:	4b05                	li	s6,1
      link("C0", file);
    5002:	00003c17          	auipc	s8,0x3
    5006:	046c0c13          	addi	s8,s8,70 # 8048 <malloc+0x1e7e>
      wait(&xstatus,"");
    500a:	00003a97          	auipc	s5,0x3
    500e:	8eea8a93          	addi	s5,s5,-1810 # 78f8 <malloc+0x172e>
  for(i = 0; i < N; i++){
    5012:	02800a13          	li	s4,40
    5016:	acf1                	j	52f2 <concreate+0x31c>
      link("C0", file);
    5018:	fa840593          	addi	a1,s0,-88
    501c:	8562                	mv	a0,s8
    501e:	00001097          	auipc	ra,0x1
    5022:	db6080e7          	jalr	-586(ra) # 5dd4 <link>
    if(pid == 0) {
    5026:	ac45                	j	52d6 <concreate+0x300>
    } else if(pid == 0 && (i % 5) == 1){
    5028:	4795                	li	a5,5
    502a:	02f9693b          	remw	s2,s2,a5
    502e:	4785                	li	a5,1
    5030:	02f90b63          	beq	s2,a5,5066 <concreate+0x90>
      fd = open(file, O_CREATE | O_RDWR);
    5034:	20200593          	li	a1,514
    5038:	fa840513          	addi	a0,s0,-88
    503c:	00001097          	auipc	ra,0x1
    5040:	d78080e7          	jalr	-648(ra) # 5db4 <open>
      if(fd < 0){
    5044:	28055063          	bgez	a0,52c4 <concreate+0x2ee>
        printf("concreate create %s failed\n", file);
    5048:	fa840593          	addi	a1,s0,-88
    504c:	00003517          	auipc	a0,0x3
    5050:	00450513          	addi	a0,a0,4 # 8050 <malloc+0x1e86>
    5054:	00001097          	auipc	ra,0x1
    5058:	0b8080e7          	jalr	184(ra) # 610c <printf>
        exit(1);
    505c:	4505                	li	a0,1
    505e:	00001097          	auipc	ra,0x1
    5062:	d0e080e7          	jalr	-754(ra) # 5d6c <exit>
      link("C0", file);
    5066:	fa840593          	addi	a1,s0,-88
    506a:	00003517          	auipc	a0,0x3
    506e:	fde50513          	addi	a0,a0,-34 # 8048 <malloc+0x1e7e>
    5072:	00001097          	auipc	ra,0x1
    5076:	d62080e7          	jalr	-670(ra) # 5dd4 <link>
      exit(0);
    507a:	4501                	li	a0,0
    507c:	00001097          	auipc	ra,0x1
    5080:	cf0080e7          	jalr	-784(ra) # 5d6c <exit>
        exit(1);
    5084:	4505                	li	a0,1
    5086:	00001097          	auipc	ra,0x1
    508a:	ce6080e7          	jalr	-794(ra) # 5d6c <exit>
  memset(fa, 0, sizeof(fa));
    508e:	02800613          	li	a2,40
    5092:	4581                	li	a1,0
    5094:	f8040513          	addi	a0,s0,-128
    5098:	00001097          	auipc	ra,0x1
    509c:	ad0080e7          	jalr	-1328(ra) # 5b68 <memset>
  fd = open(".", 0);
    50a0:	4581                	li	a1,0
    50a2:	00002517          	auipc	a0,0x2
    50a6:	94e50513          	addi	a0,a0,-1714 # 69f0 <malloc+0x826>
    50aa:	00001097          	auipc	ra,0x1
    50ae:	d0a080e7          	jalr	-758(ra) # 5db4 <open>
    50b2:	892a                	mv	s2,a0
  n = 0;
    50b4:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    50b6:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    50ba:	02700b13          	li	s6,39
      fa[i] = 1;
    50be:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    50c0:	a03d                	j	50ee <concreate+0x118>
        printf("%s: concreate weird file %s\n", s, de.name);
    50c2:	f7240613          	addi	a2,s0,-142
    50c6:	85ce                	mv	a1,s3
    50c8:	00003517          	auipc	a0,0x3
    50cc:	fa850513          	addi	a0,a0,-88 # 8070 <malloc+0x1ea6>
    50d0:	00001097          	auipc	ra,0x1
    50d4:	03c080e7          	jalr	60(ra) # 610c <printf>
        exit(1);
    50d8:	4505                	li	a0,1
    50da:	00001097          	auipc	ra,0x1
    50de:	c92080e7          	jalr	-878(ra) # 5d6c <exit>
      fa[i] = 1;
    50e2:	fb040793          	addi	a5,s0,-80
    50e6:	973e                	add	a4,a4,a5
    50e8:	fd770823          	sb	s7,-48(a4)
      n++;
    50ec:	2a85                	addiw	s5,s5,1
  while(read(fd, &de, sizeof(de)) > 0){
    50ee:	4641                	li	a2,16
    50f0:	f7040593          	addi	a1,s0,-144
    50f4:	854a                	mv	a0,s2
    50f6:	00001097          	auipc	ra,0x1
    50fa:	c96080e7          	jalr	-874(ra) # 5d8c <read>
    50fe:	04a05a63          	blez	a0,5152 <concreate+0x17c>
    if(de.inum == 0)
    5102:	f7045783          	lhu	a5,-144(s0)
    5106:	d7e5                	beqz	a5,50ee <concreate+0x118>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    5108:	f7244783          	lbu	a5,-142(s0)
    510c:	ff4791e3          	bne	a5,s4,50ee <concreate+0x118>
    5110:	f7444783          	lbu	a5,-140(s0)
    5114:	ffe9                	bnez	a5,50ee <concreate+0x118>
      i = de.name[1] - '0';
    5116:	f7344783          	lbu	a5,-141(s0)
    511a:	fd07879b          	addiw	a5,a5,-48
    511e:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    5122:	faeb60e3          	bltu	s6,a4,50c2 <concreate+0xec>
      if(fa[i]){
    5126:	fb040793          	addi	a5,s0,-80
    512a:	97ba                	add	a5,a5,a4
    512c:	fd07c783          	lbu	a5,-48(a5)
    5130:	dbcd                	beqz	a5,50e2 <concreate+0x10c>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    5132:	f7240613          	addi	a2,s0,-142
    5136:	85ce                	mv	a1,s3
    5138:	00003517          	auipc	a0,0x3
    513c:	f5850513          	addi	a0,a0,-168 # 8090 <malloc+0x1ec6>
    5140:	00001097          	auipc	ra,0x1
    5144:	fcc080e7          	jalr	-52(ra) # 610c <printf>
        exit(1);
    5148:	4505                	li	a0,1
    514a:	00001097          	auipc	ra,0x1
    514e:	c22080e7          	jalr	-990(ra) # 5d6c <exit>
  close(fd);
    5152:	854a                	mv	a0,s2
    5154:	00001097          	auipc	ra,0x1
    5158:	c48080e7          	jalr	-952(ra) # 5d9c <close>
  if(n != N){
    515c:	02800793          	li	a5,40
    5160:	00fa9b63          	bne	s5,a5,5176 <concreate+0x1a0>
    if(((i % 3) == 0 && pid == 0) ||
    5164:	4b0d                	li	s6,3
    5166:	4b85                	li	s7,1
      wait(0,"");
    5168:	00002a97          	auipc	s5,0x2
    516c:	790a8a93          	addi	s5,s5,1936 # 78f8 <malloc+0x172e>
  for(i = 0; i < N; i++){
    5170:	02800a13          	li	s4,40
    5174:	a8d1                	j	5248 <concreate+0x272>
    printf("%s: concreate not enough files in directory listing\n", s);
    5176:	85ce                	mv	a1,s3
    5178:	00003517          	auipc	a0,0x3
    517c:	f4050513          	addi	a0,a0,-192 # 80b8 <malloc+0x1eee>
    5180:	00001097          	auipc	ra,0x1
    5184:	f8c080e7          	jalr	-116(ra) # 610c <printf>
    exit(1);
    5188:	4505                	li	a0,1
    518a:	00001097          	auipc	ra,0x1
    518e:	be2080e7          	jalr	-1054(ra) # 5d6c <exit>
      printf("%s: fork failed\n", s);
    5192:	85ce                	mv	a1,s3
    5194:	00002517          	auipc	a0,0x2
    5198:	9fc50513          	addi	a0,a0,-1540 # 6b90 <malloc+0x9c6>
    519c:	00001097          	auipc	ra,0x1
    51a0:	f70080e7          	jalr	-144(ra) # 610c <printf>
      exit(1);
    51a4:	4505                	li	a0,1
    51a6:	00001097          	auipc	ra,0x1
    51aa:	bc6080e7          	jalr	-1082(ra) # 5d6c <exit>
      close(open(file, 0));
    51ae:	4581                	li	a1,0
    51b0:	fa840513          	addi	a0,s0,-88
    51b4:	00001097          	auipc	ra,0x1
    51b8:	c00080e7          	jalr	-1024(ra) # 5db4 <open>
    51bc:	00001097          	auipc	ra,0x1
    51c0:	be0080e7          	jalr	-1056(ra) # 5d9c <close>
      close(open(file, 0));
    51c4:	4581                	li	a1,0
    51c6:	fa840513          	addi	a0,s0,-88
    51ca:	00001097          	auipc	ra,0x1
    51ce:	bea080e7          	jalr	-1046(ra) # 5db4 <open>
    51d2:	00001097          	auipc	ra,0x1
    51d6:	bca080e7          	jalr	-1078(ra) # 5d9c <close>
      close(open(file, 0));
    51da:	4581                	li	a1,0
    51dc:	fa840513          	addi	a0,s0,-88
    51e0:	00001097          	auipc	ra,0x1
    51e4:	bd4080e7          	jalr	-1068(ra) # 5db4 <open>
    51e8:	00001097          	auipc	ra,0x1
    51ec:	bb4080e7          	jalr	-1100(ra) # 5d9c <close>
      close(open(file, 0));
    51f0:	4581                	li	a1,0
    51f2:	fa840513          	addi	a0,s0,-88
    51f6:	00001097          	auipc	ra,0x1
    51fa:	bbe080e7          	jalr	-1090(ra) # 5db4 <open>
    51fe:	00001097          	auipc	ra,0x1
    5202:	b9e080e7          	jalr	-1122(ra) # 5d9c <close>
      close(open(file, 0));
    5206:	4581                	li	a1,0
    5208:	fa840513          	addi	a0,s0,-88
    520c:	00001097          	auipc	ra,0x1
    5210:	ba8080e7          	jalr	-1112(ra) # 5db4 <open>
    5214:	00001097          	auipc	ra,0x1
    5218:	b88080e7          	jalr	-1144(ra) # 5d9c <close>
      close(open(file, 0));
    521c:	4581                	li	a1,0
    521e:	fa840513          	addi	a0,s0,-88
    5222:	00001097          	auipc	ra,0x1
    5226:	b92080e7          	jalr	-1134(ra) # 5db4 <open>
    522a:	00001097          	auipc	ra,0x1
    522e:	b72080e7          	jalr	-1166(ra) # 5d9c <close>
    if(pid == 0)
    5232:	08090463          	beqz	s2,52ba <concreate+0x2e4>
      wait(0,"");
    5236:	85d6                	mv	a1,s5
    5238:	4501                	li	a0,0
    523a:	00001097          	auipc	ra,0x1
    523e:	b42080e7          	jalr	-1214(ra) # 5d7c <wait>
  for(i = 0; i < N; i++){
    5242:	2485                	addiw	s1,s1,1
    5244:	0f448663          	beq	s1,s4,5330 <concreate+0x35a>
    file[1] = '0' + i;
    5248:	0304879b          	addiw	a5,s1,48
    524c:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    5250:	00001097          	auipc	ra,0x1
    5254:	b14080e7          	jalr	-1260(ra) # 5d64 <fork>
    5258:	892a                	mv	s2,a0
    if(pid < 0){
    525a:	f2054ce3          	bltz	a0,5192 <concreate+0x1bc>
    if(((i % 3) == 0 && pid == 0) ||
    525e:	0364e73b          	remw	a4,s1,s6
    5262:	00a767b3          	or	a5,a4,a0
    5266:	2781                	sext.w	a5,a5
    5268:	d3b9                	beqz	a5,51ae <concreate+0x1d8>
    526a:	01771363          	bne	a4,s7,5270 <concreate+0x29a>
       ((i % 3) == 1 && pid != 0)){
    526e:	f121                	bnez	a0,51ae <concreate+0x1d8>
      unlink(file);
    5270:	fa840513          	addi	a0,s0,-88
    5274:	00001097          	auipc	ra,0x1
    5278:	b50080e7          	jalr	-1200(ra) # 5dc4 <unlink>
      unlink(file);
    527c:	fa840513          	addi	a0,s0,-88
    5280:	00001097          	auipc	ra,0x1
    5284:	b44080e7          	jalr	-1212(ra) # 5dc4 <unlink>
      unlink(file);
    5288:	fa840513          	addi	a0,s0,-88
    528c:	00001097          	auipc	ra,0x1
    5290:	b38080e7          	jalr	-1224(ra) # 5dc4 <unlink>
      unlink(file);
    5294:	fa840513          	addi	a0,s0,-88
    5298:	00001097          	auipc	ra,0x1
    529c:	b2c080e7          	jalr	-1236(ra) # 5dc4 <unlink>
      unlink(file);
    52a0:	fa840513          	addi	a0,s0,-88
    52a4:	00001097          	auipc	ra,0x1
    52a8:	b20080e7          	jalr	-1248(ra) # 5dc4 <unlink>
      unlink(file);
    52ac:	fa840513          	addi	a0,s0,-88
    52b0:	00001097          	auipc	ra,0x1
    52b4:	b14080e7          	jalr	-1260(ra) # 5dc4 <unlink>
    52b8:	bfad                	j	5232 <concreate+0x25c>
      exit(0);
    52ba:	4501                	li	a0,0
    52bc:	00001097          	auipc	ra,0x1
    52c0:	ab0080e7          	jalr	-1360(ra) # 5d6c <exit>
      close(fd);
    52c4:	00001097          	auipc	ra,0x1
    52c8:	ad8080e7          	jalr	-1320(ra) # 5d9c <close>
    if(pid == 0) {
    52cc:	b37d                	j	507a <concreate+0xa4>
      close(fd);
    52ce:	00001097          	auipc	ra,0x1
    52d2:	ace080e7          	jalr	-1330(ra) # 5d9c <close>
      wait(&xstatus,"");
    52d6:	85d6                	mv	a1,s5
    52d8:	f6c40513          	addi	a0,s0,-148
    52dc:	00001097          	auipc	ra,0x1
    52e0:	aa0080e7          	jalr	-1376(ra) # 5d7c <wait>
      if(xstatus != 0)
    52e4:	f6c42483          	lw	s1,-148(s0)
    52e8:	d8049ee3          	bnez	s1,5084 <concreate+0xae>
  for(i = 0; i < N; i++){
    52ec:	2905                	addiw	s2,s2,1
    52ee:	db4900e3          	beq	s2,s4,508e <concreate+0xb8>
    file[1] = '0' + i;
    52f2:	0309079b          	addiw	a5,s2,48
    52f6:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    52fa:	fa840513          	addi	a0,s0,-88
    52fe:	00001097          	auipc	ra,0x1
    5302:	ac6080e7          	jalr	-1338(ra) # 5dc4 <unlink>
    pid = fork();
    5306:	00001097          	auipc	ra,0x1
    530a:	a5e080e7          	jalr	-1442(ra) # 5d64 <fork>
    if(pid && (i % 3) == 1){
    530e:	d0050de3          	beqz	a0,5028 <concreate+0x52>
    5312:	037967bb          	remw	a5,s2,s7
    5316:	d16781e3          	beq	a5,s6,5018 <concreate+0x42>
      fd = open(file, O_CREATE | O_RDWR);
    531a:	20200593          	li	a1,514
    531e:	fa840513          	addi	a0,s0,-88
    5322:	00001097          	auipc	ra,0x1
    5326:	a92080e7          	jalr	-1390(ra) # 5db4 <open>
      if(fd < 0){
    532a:	fa0552e3          	bgez	a0,52ce <concreate+0x2f8>
    532e:	bb29                	j	5048 <concreate+0x72>
}
    5330:	60ea                	ld	ra,152(sp)
    5332:	644a                	ld	s0,144(sp)
    5334:	64aa                	ld	s1,136(sp)
    5336:	690a                	ld	s2,128(sp)
    5338:	79e6                	ld	s3,120(sp)
    533a:	7a46                	ld	s4,112(sp)
    533c:	7aa6                	ld	s5,104(sp)
    533e:	7b06                	ld	s6,96(sp)
    5340:	6be6                	ld	s7,88(sp)
    5342:	6c46                	ld	s8,80(sp)
    5344:	610d                	addi	sp,sp,160
    5346:	8082                	ret

0000000000005348 <bigfile>:
{
    5348:	7139                	addi	sp,sp,-64
    534a:	fc06                	sd	ra,56(sp)
    534c:	f822                	sd	s0,48(sp)
    534e:	f426                	sd	s1,40(sp)
    5350:	f04a                	sd	s2,32(sp)
    5352:	ec4e                	sd	s3,24(sp)
    5354:	e852                	sd	s4,16(sp)
    5356:	e456                	sd	s5,8(sp)
    5358:	0080                	addi	s0,sp,64
    535a:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    535c:	00003517          	auipc	a0,0x3
    5360:	d9450513          	addi	a0,a0,-620 # 80f0 <malloc+0x1f26>
    5364:	00001097          	auipc	ra,0x1
    5368:	a60080e7          	jalr	-1440(ra) # 5dc4 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    536c:	20200593          	li	a1,514
    5370:	00003517          	auipc	a0,0x3
    5374:	d8050513          	addi	a0,a0,-640 # 80f0 <malloc+0x1f26>
    5378:	00001097          	auipc	ra,0x1
    537c:	a3c080e7          	jalr	-1476(ra) # 5db4 <open>
    5380:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    5382:	4481                	li	s1,0
    memset(buf, i, SZ);
    5384:	00008917          	auipc	s2,0x8
    5388:	8f490913          	addi	s2,s2,-1804 # cc78 <buf>
  for(i = 0; i < N; i++){
    538c:	4a51                	li	s4,20
  if(fd < 0){
    538e:	0a054063          	bltz	a0,542e <bigfile+0xe6>
    memset(buf, i, SZ);
    5392:	25800613          	li	a2,600
    5396:	85a6                	mv	a1,s1
    5398:	854a                	mv	a0,s2
    539a:	00000097          	auipc	ra,0x0
    539e:	7ce080e7          	jalr	1998(ra) # 5b68 <memset>
    if(write(fd, buf, SZ) != SZ){
    53a2:	25800613          	li	a2,600
    53a6:	85ca                	mv	a1,s2
    53a8:	854e                	mv	a0,s3
    53aa:	00001097          	auipc	ra,0x1
    53ae:	9ea080e7          	jalr	-1558(ra) # 5d94 <write>
    53b2:	25800793          	li	a5,600
    53b6:	08f51a63          	bne	a0,a5,544a <bigfile+0x102>
  for(i = 0; i < N; i++){
    53ba:	2485                	addiw	s1,s1,1
    53bc:	fd449be3          	bne	s1,s4,5392 <bigfile+0x4a>
  close(fd);
    53c0:	854e                	mv	a0,s3
    53c2:	00001097          	auipc	ra,0x1
    53c6:	9da080e7          	jalr	-1574(ra) # 5d9c <close>
  fd = open("bigfile.dat", 0);
    53ca:	4581                	li	a1,0
    53cc:	00003517          	auipc	a0,0x3
    53d0:	d2450513          	addi	a0,a0,-732 # 80f0 <malloc+0x1f26>
    53d4:	00001097          	auipc	ra,0x1
    53d8:	9e0080e7          	jalr	-1568(ra) # 5db4 <open>
    53dc:	8a2a                	mv	s4,a0
  total = 0;
    53de:	4981                	li	s3,0
  for(i = 0; ; i++){
    53e0:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    53e2:	00008917          	auipc	s2,0x8
    53e6:	89690913          	addi	s2,s2,-1898 # cc78 <buf>
  if(fd < 0){
    53ea:	06054e63          	bltz	a0,5466 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    53ee:	12c00613          	li	a2,300
    53f2:	85ca                	mv	a1,s2
    53f4:	8552                	mv	a0,s4
    53f6:	00001097          	auipc	ra,0x1
    53fa:	996080e7          	jalr	-1642(ra) # 5d8c <read>
    if(cc < 0){
    53fe:	08054263          	bltz	a0,5482 <bigfile+0x13a>
    if(cc == 0)
    5402:	c971                	beqz	a0,54d6 <bigfile+0x18e>
    if(cc != SZ/2){
    5404:	12c00793          	li	a5,300
    5408:	08f51b63          	bne	a0,a5,549e <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    540c:	01f4d79b          	srliw	a5,s1,0x1f
    5410:	9fa5                	addw	a5,a5,s1
    5412:	4017d79b          	sraiw	a5,a5,0x1
    5416:	00094703          	lbu	a4,0(s2)
    541a:	0af71063          	bne	a4,a5,54ba <bigfile+0x172>
    541e:	12b94703          	lbu	a4,299(s2)
    5422:	08f71c63          	bne	a4,a5,54ba <bigfile+0x172>
    total += cc;
    5426:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    542a:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    542c:	b7c9                	j	53ee <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    542e:	85d6                	mv	a1,s5
    5430:	00003517          	auipc	a0,0x3
    5434:	cd050513          	addi	a0,a0,-816 # 8100 <malloc+0x1f36>
    5438:	00001097          	auipc	ra,0x1
    543c:	cd4080e7          	jalr	-812(ra) # 610c <printf>
    exit(1);
    5440:	4505                	li	a0,1
    5442:	00001097          	auipc	ra,0x1
    5446:	92a080e7          	jalr	-1750(ra) # 5d6c <exit>
      printf("%s: write bigfile failed\n", s);
    544a:	85d6                	mv	a1,s5
    544c:	00003517          	auipc	a0,0x3
    5450:	cd450513          	addi	a0,a0,-812 # 8120 <malloc+0x1f56>
    5454:	00001097          	auipc	ra,0x1
    5458:	cb8080e7          	jalr	-840(ra) # 610c <printf>
      exit(1);
    545c:	4505                	li	a0,1
    545e:	00001097          	auipc	ra,0x1
    5462:	90e080e7          	jalr	-1778(ra) # 5d6c <exit>
    printf("%s: cannot open bigfile\n", s);
    5466:	85d6                	mv	a1,s5
    5468:	00003517          	auipc	a0,0x3
    546c:	cd850513          	addi	a0,a0,-808 # 8140 <malloc+0x1f76>
    5470:	00001097          	auipc	ra,0x1
    5474:	c9c080e7          	jalr	-868(ra) # 610c <printf>
    exit(1);
    5478:	4505                	li	a0,1
    547a:	00001097          	auipc	ra,0x1
    547e:	8f2080e7          	jalr	-1806(ra) # 5d6c <exit>
      printf("%s: read bigfile failed\n", s);
    5482:	85d6                	mv	a1,s5
    5484:	00003517          	auipc	a0,0x3
    5488:	cdc50513          	addi	a0,a0,-804 # 8160 <malloc+0x1f96>
    548c:	00001097          	auipc	ra,0x1
    5490:	c80080e7          	jalr	-896(ra) # 610c <printf>
      exit(1);
    5494:	4505                	li	a0,1
    5496:	00001097          	auipc	ra,0x1
    549a:	8d6080e7          	jalr	-1834(ra) # 5d6c <exit>
      printf("%s: short read bigfile\n", s);
    549e:	85d6                	mv	a1,s5
    54a0:	00003517          	auipc	a0,0x3
    54a4:	ce050513          	addi	a0,a0,-800 # 8180 <malloc+0x1fb6>
    54a8:	00001097          	auipc	ra,0x1
    54ac:	c64080e7          	jalr	-924(ra) # 610c <printf>
      exit(1);
    54b0:	4505                	li	a0,1
    54b2:	00001097          	auipc	ra,0x1
    54b6:	8ba080e7          	jalr	-1862(ra) # 5d6c <exit>
      printf("%s: read bigfile wrong data\n", s);
    54ba:	85d6                	mv	a1,s5
    54bc:	00003517          	auipc	a0,0x3
    54c0:	cdc50513          	addi	a0,a0,-804 # 8198 <malloc+0x1fce>
    54c4:	00001097          	auipc	ra,0x1
    54c8:	c48080e7          	jalr	-952(ra) # 610c <printf>
      exit(1);
    54cc:	4505                	li	a0,1
    54ce:	00001097          	auipc	ra,0x1
    54d2:	89e080e7          	jalr	-1890(ra) # 5d6c <exit>
  close(fd);
    54d6:	8552                	mv	a0,s4
    54d8:	00001097          	auipc	ra,0x1
    54dc:	8c4080e7          	jalr	-1852(ra) # 5d9c <close>
  if(total != N*SZ){
    54e0:	678d                	lui	a5,0x3
    54e2:	ee078793          	addi	a5,a5,-288 # 2ee0 <sbrkbugs+0xc4>
    54e6:	02f99363          	bne	s3,a5,550c <bigfile+0x1c4>
  unlink("bigfile.dat");
    54ea:	00003517          	auipc	a0,0x3
    54ee:	c0650513          	addi	a0,a0,-1018 # 80f0 <malloc+0x1f26>
    54f2:	00001097          	auipc	ra,0x1
    54f6:	8d2080e7          	jalr	-1838(ra) # 5dc4 <unlink>
}
    54fa:	70e2                	ld	ra,56(sp)
    54fc:	7442                	ld	s0,48(sp)
    54fe:	74a2                	ld	s1,40(sp)
    5500:	7902                	ld	s2,32(sp)
    5502:	69e2                	ld	s3,24(sp)
    5504:	6a42                	ld	s4,16(sp)
    5506:	6aa2                	ld	s5,8(sp)
    5508:	6121                	addi	sp,sp,64
    550a:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    550c:	85d6                	mv	a1,s5
    550e:	00003517          	auipc	a0,0x3
    5512:	caa50513          	addi	a0,a0,-854 # 81b8 <malloc+0x1fee>
    5516:	00001097          	auipc	ra,0x1
    551a:	bf6080e7          	jalr	-1034(ra) # 610c <printf>
    exit(1);
    551e:	4505                	li	a0,1
    5520:	00001097          	auipc	ra,0x1
    5524:	84c080e7          	jalr	-1972(ra) # 5d6c <exit>

0000000000005528 <fsfull>:
{
    5528:	7171                	addi	sp,sp,-176
    552a:	f506                	sd	ra,168(sp)
    552c:	f122                	sd	s0,160(sp)
    552e:	ed26                	sd	s1,152(sp)
    5530:	e94a                	sd	s2,144(sp)
    5532:	e54e                	sd	s3,136(sp)
    5534:	e152                	sd	s4,128(sp)
    5536:	fcd6                	sd	s5,120(sp)
    5538:	f8da                	sd	s6,112(sp)
    553a:	f4de                	sd	s7,104(sp)
    553c:	f0e2                	sd	s8,96(sp)
    553e:	ece6                	sd	s9,88(sp)
    5540:	e8ea                	sd	s10,80(sp)
    5542:	e4ee                	sd	s11,72(sp)
    5544:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    5546:	00003517          	auipc	a0,0x3
    554a:	c9250513          	addi	a0,a0,-878 # 81d8 <malloc+0x200e>
    554e:	00001097          	auipc	ra,0x1
    5552:	bbe080e7          	jalr	-1090(ra) # 610c <printf>
  for(nfiles = 0; ; nfiles++){
    5556:	4481                	li	s1,0
    name[0] = 'f';
    5558:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    555c:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    5560:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    5564:	4b29                	li	s6,10
    printf("writing %s\n", name);
    5566:	00003c97          	auipc	s9,0x3
    556a:	c82c8c93          	addi	s9,s9,-894 # 81e8 <malloc+0x201e>
    int total = 0;
    556e:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    5570:	00007a17          	auipc	s4,0x7
    5574:	708a0a13          	addi	s4,s4,1800 # cc78 <buf>
    name[0] = 'f';
    5578:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    557c:	0384c7bb          	divw	a5,s1,s8
    5580:	0307879b          	addiw	a5,a5,48
    5584:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5588:	0384e7bb          	remw	a5,s1,s8
    558c:	0377c7bb          	divw	a5,a5,s7
    5590:	0307879b          	addiw	a5,a5,48
    5594:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5598:	0374e7bb          	remw	a5,s1,s7
    559c:	0367c7bb          	divw	a5,a5,s6
    55a0:	0307879b          	addiw	a5,a5,48
    55a4:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    55a8:	0364e7bb          	remw	a5,s1,s6
    55ac:	0307879b          	addiw	a5,a5,48
    55b0:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    55b4:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    55b8:	f5040593          	addi	a1,s0,-176
    55bc:	8566                	mv	a0,s9
    55be:	00001097          	auipc	ra,0x1
    55c2:	b4e080e7          	jalr	-1202(ra) # 610c <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    55c6:	20200593          	li	a1,514
    55ca:	f5040513          	addi	a0,s0,-176
    55ce:	00000097          	auipc	ra,0x0
    55d2:	7e6080e7          	jalr	2022(ra) # 5db4 <open>
    55d6:	892a                	mv	s2,a0
    if(fd < 0){
    55d8:	0a055663          	bgez	a0,5684 <fsfull+0x15c>
      printf("open %s failed\n", name);
    55dc:	f5040593          	addi	a1,s0,-176
    55e0:	00003517          	auipc	a0,0x3
    55e4:	c1850513          	addi	a0,a0,-1000 # 81f8 <malloc+0x202e>
    55e8:	00001097          	auipc	ra,0x1
    55ec:	b24080e7          	jalr	-1244(ra) # 610c <printf>
  while(nfiles >= 0){
    55f0:	0604c363          	bltz	s1,5656 <fsfull+0x12e>
    name[0] = 'f';
    55f4:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    55f8:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    55fc:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    5600:	4929                	li	s2,10
  while(nfiles >= 0){
    5602:	5afd                	li	s5,-1
    name[0] = 'f';
    5604:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    5608:	0344c7bb          	divw	a5,s1,s4
    560c:	0307879b          	addiw	a5,a5,48
    5610:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5614:	0344e7bb          	remw	a5,s1,s4
    5618:	0337c7bb          	divw	a5,a5,s3
    561c:	0307879b          	addiw	a5,a5,48
    5620:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5624:	0334e7bb          	remw	a5,s1,s3
    5628:	0327c7bb          	divw	a5,a5,s2
    562c:	0307879b          	addiw	a5,a5,48
    5630:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    5634:	0324e7bb          	remw	a5,s1,s2
    5638:	0307879b          	addiw	a5,a5,48
    563c:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    5640:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    5644:	f5040513          	addi	a0,s0,-176
    5648:	00000097          	auipc	ra,0x0
    564c:	77c080e7          	jalr	1916(ra) # 5dc4 <unlink>
    nfiles--;
    5650:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    5652:	fb5499e3          	bne	s1,s5,5604 <fsfull+0xdc>
  printf("fsfull test finished\n");
    5656:	00003517          	auipc	a0,0x3
    565a:	bc250513          	addi	a0,a0,-1086 # 8218 <malloc+0x204e>
    565e:	00001097          	auipc	ra,0x1
    5662:	aae080e7          	jalr	-1362(ra) # 610c <printf>
}
    5666:	70aa                	ld	ra,168(sp)
    5668:	740a                	ld	s0,160(sp)
    566a:	64ea                	ld	s1,152(sp)
    566c:	694a                	ld	s2,144(sp)
    566e:	69aa                	ld	s3,136(sp)
    5670:	6a0a                	ld	s4,128(sp)
    5672:	7ae6                	ld	s5,120(sp)
    5674:	7b46                	ld	s6,112(sp)
    5676:	7ba6                	ld	s7,104(sp)
    5678:	7c06                	ld	s8,96(sp)
    567a:	6ce6                	ld	s9,88(sp)
    567c:	6d46                	ld	s10,80(sp)
    567e:	6da6                	ld	s11,72(sp)
    5680:	614d                	addi	sp,sp,176
    5682:	8082                	ret
    int total = 0;
    5684:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    5686:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    568a:	40000613          	li	a2,1024
    568e:	85d2                	mv	a1,s4
    5690:	854a                	mv	a0,s2
    5692:	00000097          	auipc	ra,0x0
    5696:	702080e7          	jalr	1794(ra) # 5d94 <write>
      if(cc < BSIZE)
    569a:	00aad563          	bge	s5,a0,56a4 <fsfull+0x17c>
      total += cc;
    569e:	00a989bb          	addw	s3,s3,a0
    while(1){
    56a2:	b7e5                	j	568a <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    56a4:	85ce                	mv	a1,s3
    56a6:	00003517          	auipc	a0,0x3
    56aa:	b6250513          	addi	a0,a0,-1182 # 8208 <malloc+0x203e>
    56ae:	00001097          	auipc	ra,0x1
    56b2:	a5e080e7          	jalr	-1442(ra) # 610c <printf>
    close(fd);
    56b6:	854a                	mv	a0,s2
    56b8:	00000097          	auipc	ra,0x0
    56bc:	6e4080e7          	jalr	1764(ra) # 5d9c <close>
    if(total == 0)
    56c0:	f20988e3          	beqz	s3,55f0 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    56c4:	2485                	addiw	s1,s1,1
    56c6:	bd4d                	j	5578 <fsfull+0x50>

00000000000056c8 <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    56c8:	7179                	addi	sp,sp,-48
    56ca:	f406                	sd	ra,40(sp)
    56cc:	f022                	sd	s0,32(sp)
    56ce:	ec26                	sd	s1,24(sp)
    56d0:	e84a                	sd	s2,16(sp)
    56d2:	1800                	addi	s0,sp,48
    56d4:	84aa                	mv	s1,a0
    56d6:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    56d8:	00003517          	auipc	a0,0x3
    56dc:	b5850513          	addi	a0,a0,-1192 # 8230 <malloc+0x2066>
    56e0:	00001097          	auipc	ra,0x1
    56e4:	a2c080e7          	jalr	-1492(ra) # 610c <printf>
  if((pid = fork()) < 0) {
    56e8:	00000097          	auipc	ra,0x0
    56ec:	67c080e7          	jalr	1660(ra) # 5d64 <fork>
    56f0:	04054263          	bltz	a0,5734 <run+0x6c>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    56f4:	cd29                	beqz	a0,574e <run+0x86>
    f(s);
    exit(0);
  } else {
    wait(&xstatus,"");
    56f6:	00002597          	auipc	a1,0x2
    56fa:	20258593          	addi	a1,a1,514 # 78f8 <malloc+0x172e>
    56fe:	fdc40513          	addi	a0,s0,-36
    5702:	00000097          	auipc	ra,0x0
    5706:	67a080e7          	jalr	1658(ra) # 5d7c <wait>
    if(xstatus != 0) 
    570a:	fdc42783          	lw	a5,-36(s0)
    570e:	c7b9                	beqz	a5,575c <run+0x94>
      printf("FAILED\n");
    5710:	00003517          	auipc	a0,0x3
    5714:	b4850513          	addi	a0,a0,-1208 # 8258 <malloc+0x208e>
    5718:	00001097          	auipc	ra,0x1
    571c:	9f4080e7          	jalr	-1548(ra) # 610c <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5720:	fdc42503          	lw	a0,-36(s0)
  }
}
    5724:	00153513          	seqz	a0,a0
    5728:	70a2                	ld	ra,40(sp)
    572a:	7402                	ld	s0,32(sp)
    572c:	64e2                	ld	s1,24(sp)
    572e:	6942                	ld	s2,16(sp)
    5730:	6145                	addi	sp,sp,48
    5732:	8082                	ret
    printf("runtest: fork error\n");
    5734:	00003517          	auipc	a0,0x3
    5738:	b0c50513          	addi	a0,a0,-1268 # 8240 <malloc+0x2076>
    573c:	00001097          	auipc	ra,0x1
    5740:	9d0080e7          	jalr	-1584(ra) # 610c <printf>
    exit(1);
    5744:	4505                	li	a0,1
    5746:	00000097          	auipc	ra,0x0
    574a:	626080e7          	jalr	1574(ra) # 5d6c <exit>
    f(s);
    574e:	854a                	mv	a0,s2
    5750:	9482                	jalr	s1
    exit(0);
    5752:	4501                	li	a0,0
    5754:	00000097          	auipc	ra,0x0
    5758:	618080e7          	jalr	1560(ra) # 5d6c <exit>
      printf("OK\n");
    575c:	00003517          	auipc	a0,0x3
    5760:	b0450513          	addi	a0,a0,-1276 # 8260 <malloc+0x2096>
    5764:	00001097          	auipc	ra,0x1
    5768:	9a8080e7          	jalr	-1624(ra) # 610c <printf>
    576c:	bf55                	j	5720 <run+0x58>

000000000000576e <runtests>:

int
runtests(struct test *tests, char *justone) {
    576e:	1101                	addi	sp,sp,-32
    5770:	ec06                	sd	ra,24(sp)
    5772:	e822                	sd	s0,16(sp)
    5774:	e426                	sd	s1,8(sp)
    5776:	e04a                	sd	s2,0(sp)
    5778:	1000                	addi	s0,sp,32
    577a:	84aa                	mv	s1,a0
    577c:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++) {
    577e:	6508                	ld	a0,8(a0)
    5780:	ed09                	bnez	a0,579a <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    5782:	4501                	li	a0,0
    5784:	a82d                	j	57be <runtests+0x50>
      if(!run(t->f, t->s)){
    5786:	648c                	ld	a1,8(s1)
    5788:	6088                	ld	a0,0(s1)
    578a:	00000097          	auipc	ra,0x0
    578e:	f3e080e7          	jalr	-194(ra) # 56c8 <run>
    5792:	cd09                	beqz	a0,57ac <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++) {
    5794:	04c1                	addi	s1,s1,16
    5796:	6488                	ld	a0,8(s1)
    5798:	c11d                	beqz	a0,57be <runtests+0x50>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    579a:	fe0906e3          	beqz	s2,5786 <runtests+0x18>
    579e:	85ca                	mv	a1,s2
    57a0:	00000097          	auipc	ra,0x0
    57a4:	372080e7          	jalr	882(ra) # 5b12 <strcmp>
    57a8:	f575                	bnez	a0,5794 <runtests+0x26>
    57aa:	bff1                	j	5786 <runtests+0x18>
        printf("SOME TESTS FAILED\n");
    57ac:	00003517          	auipc	a0,0x3
    57b0:	abc50513          	addi	a0,a0,-1348 # 8268 <malloc+0x209e>
    57b4:	00001097          	auipc	ra,0x1
    57b8:	958080e7          	jalr	-1704(ra) # 610c <printf>
        return 1;
    57bc:	4505                	li	a0,1
}
    57be:	60e2                	ld	ra,24(sp)
    57c0:	6442                	ld	s0,16(sp)
    57c2:	64a2                	ld	s1,8(sp)
    57c4:	6902                	ld	s2,0(sp)
    57c6:	6105                	addi	sp,sp,32
    57c8:	8082                	ret

00000000000057ca <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    57ca:	7139                	addi	sp,sp,-64
    57cc:	fc06                	sd	ra,56(sp)
    57ce:	f822                	sd	s0,48(sp)
    57d0:	f426                	sd	s1,40(sp)
    57d2:	f04a                	sd	s2,32(sp)
    57d4:	ec4e                	sd	s3,24(sp)
    57d6:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    57d8:	fc840513          	addi	a0,s0,-56
    57dc:	00000097          	auipc	ra,0x0
    57e0:	5a8080e7          	jalr	1448(ra) # 5d84 <pipe>
    57e4:	06054863          	bltz	a0,5854 <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    57e8:	00000097          	auipc	ra,0x0
    57ec:	57c080e7          	jalr	1404(ra) # 5d64 <fork>

  if(pid < 0){
    57f0:	06054f63          	bltz	a0,586e <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    57f4:	ed59                	bnez	a0,5892 <countfree+0xc8>
    close(fds[0]);
    57f6:	fc842503          	lw	a0,-56(s0)
    57fa:	00000097          	auipc	ra,0x0
    57fe:	5a2080e7          	jalr	1442(ra) # 5d9c <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    5802:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    5804:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    5806:	00001917          	auipc	s2,0x1
    580a:	b7290913          	addi	s2,s2,-1166 # 6378 <malloc+0x1ae>
      uint64 a = (uint64) sbrk(4096);
    580e:	6505                	lui	a0,0x1
    5810:	00000097          	auipc	ra,0x0
    5814:	5ec080e7          	jalr	1516(ra) # 5dfc <sbrk>
      if(a == 0xffffffffffffffff){
    5818:	06950863          	beq	a0,s1,5888 <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    581c:	6785                	lui	a5,0x1
    581e:	953e                	add	a0,a0,a5
    5820:	ff350fa3          	sb	s3,-1(a0) # fff <linktest+0x109>
      if(write(fds[1], "x", 1) != 1){
    5824:	4605                	li	a2,1
    5826:	85ca                	mv	a1,s2
    5828:	fcc42503          	lw	a0,-52(s0)
    582c:	00000097          	auipc	ra,0x0
    5830:	568080e7          	jalr	1384(ra) # 5d94 <write>
    5834:	4785                	li	a5,1
    5836:	fcf50ce3          	beq	a0,a5,580e <countfree+0x44>
        printf("write() failed in countfree()\n");
    583a:	00003517          	auipc	a0,0x3
    583e:	a8650513          	addi	a0,a0,-1402 # 82c0 <malloc+0x20f6>
    5842:	00001097          	auipc	ra,0x1
    5846:	8ca080e7          	jalr	-1846(ra) # 610c <printf>
        exit(1);
    584a:	4505                	li	a0,1
    584c:	00000097          	auipc	ra,0x0
    5850:	520080e7          	jalr	1312(ra) # 5d6c <exit>
    printf("pipe() failed in countfree()\n");
    5854:	00003517          	auipc	a0,0x3
    5858:	a2c50513          	addi	a0,a0,-1492 # 8280 <malloc+0x20b6>
    585c:	00001097          	auipc	ra,0x1
    5860:	8b0080e7          	jalr	-1872(ra) # 610c <printf>
    exit(1);
    5864:	4505                	li	a0,1
    5866:	00000097          	auipc	ra,0x0
    586a:	506080e7          	jalr	1286(ra) # 5d6c <exit>
    printf("fork failed in countfree()\n");
    586e:	00003517          	auipc	a0,0x3
    5872:	a3250513          	addi	a0,a0,-1486 # 82a0 <malloc+0x20d6>
    5876:	00001097          	auipc	ra,0x1
    587a:	896080e7          	jalr	-1898(ra) # 610c <printf>
    exit(1);
    587e:	4505                	li	a0,1
    5880:	00000097          	auipc	ra,0x0
    5884:	4ec080e7          	jalr	1260(ra) # 5d6c <exit>
      }
    }

    exit(0);
    5888:	4501                	li	a0,0
    588a:	00000097          	auipc	ra,0x0
    588e:	4e2080e7          	jalr	1250(ra) # 5d6c <exit>
  }

  close(fds[1]);
    5892:	fcc42503          	lw	a0,-52(s0)
    5896:	00000097          	auipc	ra,0x0
    589a:	506080e7          	jalr	1286(ra) # 5d9c <close>

  int n = 0;
    589e:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    58a0:	4605                	li	a2,1
    58a2:	fc740593          	addi	a1,s0,-57
    58a6:	fc842503          	lw	a0,-56(s0)
    58aa:	00000097          	auipc	ra,0x0
    58ae:	4e2080e7          	jalr	1250(ra) # 5d8c <read>
    if(cc < 0){
    58b2:	00054563          	bltz	a0,58bc <countfree+0xf2>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    58b6:	c105                	beqz	a0,58d6 <countfree+0x10c>
      break;
    n += 1;
    58b8:	2485                	addiw	s1,s1,1
  while(1){
    58ba:	b7dd                	j	58a0 <countfree+0xd6>
      printf("read() failed in countfree()\n");
    58bc:	00003517          	auipc	a0,0x3
    58c0:	a2450513          	addi	a0,a0,-1500 # 82e0 <malloc+0x2116>
    58c4:	00001097          	auipc	ra,0x1
    58c8:	848080e7          	jalr	-1976(ra) # 610c <printf>
      exit(1);
    58cc:	4505                	li	a0,1
    58ce:	00000097          	auipc	ra,0x0
    58d2:	49e080e7          	jalr	1182(ra) # 5d6c <exit>
  }

  close(fds[0]);
    58d6:	fc842503          	lw	a0,-56(s0)
    58da:	00000097          	auipc	ra,0x0
    58de:	4c2080e7          	jalr	1218(ra) # 5d9c <close>
  wait((int*)0, "");
    58e2:	00002597          	auipc	a1,0x2
    58e6:	01658593          	addi	a1,a1,22 # 78f8 <malloc+0x172e>
    58ea:	4501                	li	a0,0
    58ec:	00000097          	auipc	ra,0x0
    58f0:	490080e7          	jalr	1168(ra) # 5d7c <wait>
  
  return n;
}
    58f4:	8526                	mv	a0,s1
    58f6:	70e2                	ld	ra,56(sp)
    58f8:	7442                	ld	s0,48(sp)
    58fa:	74a2                	ld	s1,40(sp)
    58fc:	7902                	ld	s2,32(sp)
    58fe:	69e2                	ld	s3,24(sp)
    5900:	6121                	addi	sp,sp,64
    5902:	8082                	ret

0000000000005904 <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    5904:	711d                	addi	sp,sp,-96
    5906:	ec86                	sd	ra,88(sp)
    5908:	e8a2                	sd	s0,80(sp)
    590a:	e4a6                	sd	s1,72(sp)
    590c:	e0ca                	sd	s2,64(sp)
    590e:	fc4e                	sd	s3,56(sp)
    5910:	f852                	sd	s4,48(sp)
    5912:	f456                	sd	s5,40(sp)
    5914:	f05a                	sd	s6,32(sp)
    5916:	ec5e                	sd	s7,24(sp)
    5918:	e862                	sd	s8,16(sp)
    591a:	e466                	sd	s9,8(sp)
    591c:	e06a                	sd	s10,0(sp)
    591e:	1080                	addi	s0,sp,96
    5920:	8a2a                	mv	s4,a0
    5922:	89ae                	mv	s3,a1
    5924:	8932                	mv	s2,a2
  do {
    printf("usertests starting\n");
    5926:	00003b97          	auipc	s7,0x3
    592a:	9dab8b93          	addi	s7,s7,-1574 # 8300 <malloc+0x2136>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone)) {
    592e:	00003b17          	auipc	s6,0x3
    5932:	6e2b0b13          	addi	s6,s6,1762 # 9010 <quicktests>
      if(continuous != 2) {
    5936:	4a89                	li	s5,2
          return 1;
        }
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5938:	00003c97          	auipc	s9,0x3
    593c:	a00c8c93          	addi	s9,s9,-1536 # 8338 <malloc+0x216e>
      if (runtests(slowtests, justone)) {
    5940:	00004c17          	auipc	s8,0x4
    5944:	aa0c0c13          	addi	s8,s8,-1376 # 93e0 <slowtests>
        printf("usertests slow tests starting\n");
    5948:	00003d17          	auipc	s10,0x3
    594c:	9d0d0d13          	addi	s10,s10,-1584 # 8318 <malloc+0x214e>
    5950:	a839                	j	596e <drivetests+0x6a>
    5952:	856a                	mv	a0,s10
    5954:	00000097          	auipc	ra,0x0
    5958:	7b8080e7          	jalr	1976(ra) # 610c <printf>
    595c:	a081                	j	599c <drivetests+0x98>
    if((free1 = countfree()) < free0) {
    595e:	00000097          	auipc	ra,0x0
    5962:	e6c080e7          	jalr	-404(ra) # 57ca <countfree>
    5966:	06954263          	blt	a0,s1,59ca <drivetests+0xc6>
      if(continuous != 2) {
        return 1;
      }
    }
  } while(continuous);
    596a:	06098f63          	beqz	s3,59e8 <drivetests+0xe4>
    printf("usertests starting\n");
    596e:	855e                	mv	a0,s7
    5970:	00000097          	auipc	ra,0x0
    5974:	79c080e7          	jalr	1948(ra) # 610c <printf>
    int free0 = countfree();
    5978:	00000097          	auipc	ra,0x0
    597c:	e52080e7          	jalr	-430(ra) # 57ca <countfree>
    5980:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone)) {
    5982:	85ca                	mv	a1,s2
    5984:	855a                	mv	a0,s6
    5986:	00000097          	auipc	ra,0x0
    598a:	de8080e7          	jalr	-536(ra) # 576e <runtests>
    598e:	c119                	beqz	a0,5994 <drivetests+0x90>
      if(continuous != 2) {
    5990:	05599863          	bne	s3,s5,59e0 <drivetests+0xdc>
    if(!quick) {
    5994:	fc0a15e3          	bnez	s4,595e <drivetests+0x5a>
      if (justone == 0)
    5998:	fa090de3          	beqz	s2,5952 <drivetests+0x4e>
      if (runtests(slowtests, justone)) {
    599c:	85ca                	mv	a1,s2
    599e:	8562                	mv	a0,s8
    59a0:	00000097          	auipc	ra,0x0
    59a4:	dce080e7          	jalr	-562(ra) # 576e <runtests>
    59a8:	d95d                	beqz	a0,595e <drivetests+0x5a>
        if(continuous != 2) {
    59aa:	03599d63          	bne	s3,s5,59e4 <drivetests+0xe0>
    if((free1 = countfree()) < free0) {
    59ae:	00000097          	auipc	ra,0x0
    59b2:	e1c080e7          	jalr	-484(ra) # 57ca <countfree>
    59b6:	fa955ae3          	bge	a0,s1,596a <drivetests+0x66>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    59ba:	8626                	mv	a2,s1
    59bc:	85aa                	mv	a1,a0
    59be:	8566                	mv	a0,s9
    59c0:	00000097          	auipc	ra,0x0
    59c4:	74c080e7          	jalr	1868(ra) # 610c <printf>
      if(continuous != 2) {
    59c8:	b75d                	j	596e <drivetests+0x6a>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    59ca:	8626                	mv	a2,s1
    59cc:	85aa                	mv	a1,a0
    59ce:	8566                	mv	a0,s9
    59d0:	00000097          	auipc	ra,0x0
    59d4:	73c080e7          	jalr	1852(ra) # 610c <printf>
      if(continuous != 2) {
    59d8:	f9598be3          	beq	s3,s5,596e <drivetests+0x6a>
        return 1;
    59dc:	4505                	li	a0,1
    59de:	a031                	j	59ea <drivetests+0xe6>
        return 1;
    59e0:	4505                	li	a0,1
    59e2:	a021                	j	59ea <drivetests+0xe6>
          return 1;
    59e4:	4505                	li	a0,1
    59e6:	a011                	j	59ea <drivetests+0xe6>
  return 0;
    59e8:	854e                	mv	a0,s3
}
    59ea:	60e6                	ld	ra,88(sp)
    59ec:	6446                	ld	s0,80(sp)
    59ee:	64a6                	ld	s1,72(sp)
    59f0:	6906                	ld	s2,64(sp)
    59f2:	79e2                	ld	s3,56(sp)
    59f4:	7a42                	ld	s4,48(sp)
    59f6:	7aa2                	ld	s5,40(sp)
    59f8:	7b02                	ld	s6,32(sp)
    59fa:	6be2                	ld	s7,24(sp)
    59fc:	6c42                	ld	s8,16(sp)
    59fe:	6ca2                	ld	s9,8(sp)
    5a00:	6d02                	ld	s10,0(sp)
    5a02:	6125                	addi	sp,sp,96
    5a04:	8082                	ret

0000000000005a06 <main>:

int
main(int argc, char *argv[])
{
    5a06:	1101                	addi	sp,sp,-32
    5a08:	ec06                	sd	ra,24(sp)
    5a0a:	e822                	sd	s0,16(sp)
    5a0c:	e426                	sd	s1,8(sp)
    5a0e:	e04a                	sd	s2,0(sp)
    5a10:	1000                	addi	s0,sp,32
    5a12:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    5a14:	4789                	li	a5,2
    5a16:	02f50363          	beq	a0,a5,5a3c <main+0x36>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5a1a:	4785                	li	a5,1
    5a1c:	06a7cd63          	blt	a5,a0,5a96 <main+0x90>
  char *justone = 0;
    5a20:	4601                	li	a2,0
  int quick = 0;
    5a22:	4501                	li	a0,0
  int continuous = 0;
    5a24:	4481                	li	s1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    5a26:	85a6                	mv	a1,s1
    5a28:	00000097          	auipc	ra,0x0
    5a2c:	edc080e7          	jalr	-292(ra) # 5904 <drivetests>
    5a30:	c949                	beqz	a0,5ac2 <main+0xbc>
    exit(1);
    5a32:	4505                	li	a0,1
    5a34:	00000097          	auipc	ra,0x0
    5a38:	338080e7          	jalr	824(ra) # 5d6c <exit>
    5a3c:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    5a3e:	00003597          	auipc	a1,0x3
    5a42:	92a58593          	addi	a1,a1,-1750 # 8368 <malloc+0x219e>
    5a46:	00893503          	ld	a0,8(s2)
    5a4a:	00000097          	auipc	ra,0x0
    5a4e:	0c8080e7          	jalr	200(ra) # 5b12 <strcmp>
    5a52:	cd39                	beqz	a0,5ab0 <main+0xaa>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5a54:	00003597          	auipc	a1,0x3
    5a58:	96c58593          	addi	a1,a1,-1684 # 83c0 <malloc+0x21f6>
    5a5c:	00893503          	ld	a0,8(s2)
    5a60:	00000097          	auipc	ra,0x0
    5a64:	0b2080e7          	jalr	178(ra) # 5b12 <strcmp>
    5a68:	c931                	beqz	a0,5abc <main+0xb6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5a6a:	00003597          	auipc	a1,0x3
    5a6e:	94e58593          	addi	a1,a1,-1714 # 83b8 <malloc+0x21ee>
    5a72:	00893503          	ld	a0,8(s2)
    5a76:	00000097          	auipc	ra,0x0
    5a7a:	09c080e7          	jalr	156(ra) # 5b12 <strcmp>
    5a7e:	cd0d                	beqz	a0,5ab8 <main+0xb2>
  } else if(argc == 2 && argv[1][0] != '-'){
    5a80:	00893603          	ld	a2,8(s2)
    5a84:	00064703          	lbu	a4,0(a2) # 3000 <sbrklast+0xb4>
    5a88:	02d00793          	li	a5,45
    5a8c:	00f70563          	beq	a4,a5,5a96 <main+0x90>
  int quick = 0;
    5a90:	4501                	li	a0,0
  int continuous = 0;
    5a92:	4481                	li	s1,0
    5a94:	bf49                	j	5a26 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    5a96:	00003517          	auipc	a0,0x3
    5a9a:	8da50513          	addi	a0,a0,-1830 # 8370 <malloc+0x21a6>
    5a9e:	00000097          	auipc	ra,0x0
    5aa2:	66e080e7          	jalr	1646(ra) # 610c <printf>
    exit(1);
    5aa6:	4505                	li	a0,1
    5aa8:	00000097          	auipc	ra,0x0
    5aac:	2c4080e7          	jalr	708(ra) # 5d6c <exit>
  int continuous = 0;
    5ab0:	84aa                	mv	s1,a0
  char *justone = 0;
    5ab2:	4601                	li	a2,0
    quick = 1;
    5ab4:	4505                	li	a0,1
    5ab6:	bf85                	j	5a26 <main+0x20>
  char *justone = 0;
    5ab8:	4601                	li	a2,0
    5aba:	b7b5                	j	5a26 <main+0x20>
    5abc:	4601                	li	a2,0
    continuous = 1;
    5abe:	4485                	li	s1,1
    5ac0:	b79d                	j	5a26 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    5ac2:	00003517          	auipc	a0,0x3
    5ac6:	8de50513          	addi	a0,a0,-1826 # 83a0 <malloc+0x21d6>
    5aca:	00000097          	auipc	ra,0x0
    5ace:	642080e7          	jalr	1602(ra) # 610c <printf>
  exit(0);
    5ad2:	4501                	li	a0,0
    5ad4:	00000097          	auipc	ra,0x0
    5ad8:	298080e7          	jalr	664(ra) # 5d6c <exit>

0000000000005adc <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
    5adc:	1141                	addi	sp,sp,-16
    5ade:	e406                	sd	ra,8(sp)
    5ae0:	e022                	sd	s0,0(sp)
    5ae2:	0800                	addi	s0,sp,16
  extern int main();
  main();
    5ae4:	00000097          	auipc	ra,0x0
    5ae8:	f22080e7          	jalr	-222(ra) # 5a06 <main>
  exit(0);
    5aec:	4501                	li	a0,0
    5aee:	00000097          	auipc	ra,0x0
    5af2:	27e080e7          	jalr	638(ra) # 5d6c <exit>

0000000000005af6 <strcpy>:
}

char* strcpy(char *s, const char *t)
{
    5af6:	1141                	addi	sp,sp,-16
    5af8:	e422                	sd	s0,8(sp)
    5afa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5afc:	87aa                	mv	a5,a0
    5afe:	0585                	addi	a1,a1,1
    5b00:	0785                	addi	a5,a5,1
    5b02:	fff5c703          	lbu	a4,-1(a1)
    5b06:	fee78fa3          	sb	a4,-1(a5) # fff <linktest+0x109>
    5b0a:	fb75                	bnez	a4,5afe <strcpy+0x8>
    ;
  return os;
}
    5b0c:	6422                	ld	s0,8(sp)
    5b0e:	0141                	addi	sp,sp,16
    5b10:	8082                	ret

0000000000005b12 <strcmp>:

int strcmp(const char *p, const char *q)
{
    5b12:	1141                	addi	sp,sp,-16
    5b14:	e422                	sd	s0,8(sp)
    5b16:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    5b18:	00054783          	lbu	a5,0(a0)
    5b1c:	cb91                	beqz	a5,5b30 <strcmp+0x1e>
    5b1e:	0005c703          	lbu	a4,0(a1)
    5b22:	00f71763          	bne	a4,a5,5b30 <strcmp+0x1e>
    p++, q++;
    5b26:	0505                	addi	a0,a0,1
    5b28:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5b2a:	00054783          	lbu	a5,0(a0)
    5b2e:	fbe5                	bnez	a5,5b1e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5b30:	0005c503          	lbu	a0,0(a1)
}
    5b34:	40a7853b          	subw	a0,a5,a0
    5b38:	6422                	ld	s0,8(sp)
    5b3a:	0141                	addi	sp,sp,16
    5b3c:	8082                	ret

0000000000005b3e <strlen>:

uint strlen(const char *s)
{
    5b3e:	1141                	addi	sp,sp,-16
    5b40:	e422                	sd	s0,8(sp)
    5b42:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5b44:	00054783          	lbu	a5,0(a0)
    5b48:	cf91                	beqz	a5,5b64 <strlen+0x26>
    5b4a:	0505                	addi	a0,a0,1
    5b4c:	87aa                	mv	a5,a0
    5b4e:	4685                	li	a3,1
    5b50:	9e89                	subw	a3,a3,a0
    5b52:	00f6853b          	addw	a0,a3,a5
    5b56:	0785                	addi	a5,a5,1
    5b58:	fff7c703          	lbu	a4,-1(a5)
    5b5c:	fb7d                	bnez	a4,5b52 <strlen+0x14>
    ;
  return n;
}
    5b5e:	6422                	ld	s0,8(sp)
    5b60:	0141                	addi	sp,sp,16
    5b62:	8082                	ret
  for(n = 0; s[n]; n++)
    5b64:	4501                	li	a0,0
    5b66:	bfe5                	j	5b5e <strlen+0x20>

0000000000005b68 <memset>:

void* memset(void *dst, int c, uint n)
{
    5b68:	1141                	addi	sp,sp,-16
    5b6a:	e422                	sd	s0,8(sp)
    5b6c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    5b6e:	ce09                	beqz	a2,5b88 <memset+0x20>
    5b70:	87aa                	mv	a5,a0
    5b72:	fff6071b          	addiw	a4,a2,-1
    5b76:	1702                	slli	a4,a4,0x20
    5b78:	9301                	srli	a4,a4,0x20
    5b7a:	0705                	addi	a4,a4,1
    5b7c:	972a                	add	a4,a4,a0
    cdst[i] = c;
    5b7e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5b82:	0785                	addi	a5,a5,1
    5b84:	fee79de3          	bne	a5,a4,5b7e <memset+0x16>
  }
  return dst;
}
    5b88:	6422                	ld	s0,8(sp)
    5b8a:	0141                	addi	sp,sp,16
    5b8c:	8082                	ret

0000000000005b8e <strchr>:

char* strchr(const char *s, char c)
{
    5b8e:	1141                	addi	sp,sp,-16
    5b90:	e422                	sd	s0,8(sp)
    5b92:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5b94:	00054783          	lbu	a5,0(a0)
    5b98:	cb99                	beqz	a5,5bae <strchr+0x20>
    if(*s == c)
    5b9a:	00f58763          	beq	a1,a5,5ba8 <strchr+0x1a>
  for(; *s; s++)
    5b9e:	0505                	addi	a0,a0,1
    5ba0:	00054783          	lbu	a5,0(a0)
    5ba4:	fbfd                	bnez	a5,5b9a <strchr+0xc>
      return (char*)s;
  return 0;
    5ba6:	4501                	li	a0,0
}
    5ba8:	6422                	ld	s0,8(sp)
    5baa:	0141                	addi	sp,sp,16
    5bac:	8082                	ret
  return 0;
    5bae:	4501                	li	a0,0
    5bb0:	bfe5                	j	5ba8 <strchr+0x1a>

0000000000005bb2 <gets>:

char* gets(char *buf, int max)
{
    5bb2:	711d                	addi	sp,sp,-96
    5bb4:	ec86                	sd	ra,88(sp)
    5bb6:	e8a2                	sd	s0,80(sp)
    5bb8:	e4a6                	sd	s1,72(sp)
    5bba:	e0ca                	sd	s2,64(sp)
    5bbc:	fc4e                	sd	s3,56(sp)
    5bbe:	f852                	sd	s4,48(sp)
    5bc0:	f456                	sd	s5,40(sp)
    5bc2:	f05a                	sd	s6,32(sp)
    5bc4:	ec5e                	sd	s7,24(sp)
    5bc6:	1080                	addi	s0,sp,96
    5bc8:	8baa                	mv	s7,a0
    5bca:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5bcc:	892a                	mv	s2,a0
    5bce:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5bd0:	4aa9                	li	s5,10
    5bd2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5bd4:	89a6                	mv	s3,s1
    5bd6:	2485                	addiw	s1,s1,1
    5bd8:	0344d863          	bge	s1,s4,5c08 <gets+0x56>
    cc = read(0, &c, 1);
    5bdc:	4605                	li	a2,1
    5bde:	faf40593          	addi	a1,s0,-81
    5be2:	4501                	li	a0,0
    5be4:	00000097          	auipc	ra,0x0
    5be8:	1a8080e7          	jalr	424(ra) # 5d8c <read>
    if(cc < 1)
    5bec:	00a05e63          	blez	a0,5c08 <gets+0x56>
    buf[i++] = c;
    5bf0:	faf44783          	lbu	a5,-81(s0)
    5bf4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5bf8:	01578763          	beq	a5,s5,5c06 <gets+0x54>
    5bfc:	0905                	addi	s2,s2,1
    5bfe:	fd679be3          	bne	a5,s6,5bd4 <gets+0x22>
  for(i=0; i+1 < max; ){
    5c02:	89a6                	mv	s3,s1
    5c04:	a011                	j	5c08 <gets+0x56>
    5c06:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5c08:	99de                	add	s3,s3,s7
    5c0a:	00098023          	sb	zero,0(s3)
  return buf;
}
    5c0e:	855e                	mv	a0,s7
    5c10:	60e6                	ld	ra,88(sp)
    5c12:	6446                	ld	s0,80(sp)
    5c14:	64a6                	ld	s1,72(sp)
    5c16:	6906                	ld	s2,64(sp)
    5c18:	79e2                	ld	s3,56(sp)
    5c1a:	7a42                	ld	s4,48(sp)
    5c1c:	7aa2                	ld	s5,40(sp)
    5c1e:	7b02                	ld	s6,32(sp)
    5c20:	6be2                	ld	s7,24(sp)
    5c22:	6125                	addi	sp,sp,96
    5c24:	8082                	ret

0000000000005c26 <stat>:

int stat(const char *n, struct stat *st)
{
    5c26:	1101                	addi	sp,sp,-32
    5c28:	ec06                	sd	ra,24(sp)
    5c2a:	e822                	sd	s0,16(sp)
    5c2c:	e426                	sd	s1,8(sp)
    5c2e:	e04a                	sd	s2,0(sp)
    5c30:	1000                	addi	s0,sp,32
    5c32:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5c34:	4581                	li	a1,0
    5c36:	00000097          	auipc	ra,0x0
    5c3a:	17e080e7          	jalr	382(ra) # 5db4 <open>
  if(fd < 0)
    5c3e:	02054563          	bltz	a0,5c68 <stat+0x42>
    5c42:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5c44:	85ca                	mv	a1,s2
    5c46:	00000097          	auipc	ra,0x0
    5c4a:	186080e7          	jalr	390(ra) # 5dcc <fstat>
    5c4e:	892a                	mv	s2,a0
  close(fd);
    5c50:	8526                	mv	a0,s1
    5c52:	00000097          	auipc	ra,0x0
    5c56:	14a080e7          	jalr	330(ra) # 5d9c <close>
  return r;
}
    5c5a:	854a                	mv	a0,s2
    5c5c:	60e2                	ld	ra,24(sp)
    5c5e:	6442                	ld	s0,16(sp)
    5c60:	64a2                	ld	s1,8(sp)
    5c62:	6902                	ld	s2,0(sp)
    5c64:	6105                	addi	sp,sp,32
    5c66:	8082                	ret
    return -1;
    5c68:	597d                	li	s2,-1
    5c6a:	bfc5                	j	5c5a <stat+0x34>

0000000000005c6c <atoi>:

int atoi(const char *s)
{
    5c6c:	1141                	addi	sp,sp,-16
    5c6e:	e422                	sd	s0,8(sp)
    5c70:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5c72:	00054603          	lbu	a2,0(a0)
    5c76:	fd06079b          	addiw	a5,a2,-48
    5c7a:	0ff7f793          	andi	a5,a5,255
    5c7e:	4725                	li	a4,9
    5c80:	02f76963          	bltu	a4,a5,5cb2 <atoi+0x46>
    5c84:	86aa                	mv	a3,a0
  n = 0;
    5c86:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5c88:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5c8a:	0685                	addi	a3,a3,1
    5c8c:	0025179b          	slliw	a5,a0,0x2
    5c90:	9fa9                	addw	a5,a5,a0
    5c92:	0017979b          	slliw	a5,a5,0x1
    5c96:	9fb1                	addw	a5,a5,a2
    5c98:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5c9c:	0006c603          	lbu	a2,0(a3) # 1000 <linktest+0x10a>
    5ca0:	fd06071b          	addiw	a4,a2,-48
    5ca4:	0ff77713          	andi	a4,a4,255
    5ca8:	fee5f1e3          	bgeu	a1,a4,5c8a <atoi+0x1e>
  return n;
}
    5cac:	6422                	ld	s0,8(sp)
    5cae:	0141                	addi	sp,sp,16
    5cb0:	8082                	ret
  n = 0;
    5cb2:	4501                	li	a0,0
    5cb4:	bfe5                	j	5cac <atoi+0x40>

0000000000005cb6 <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
    5cb6:	1141                	addi	sp,sp,-16
    5cb8:	e422                	sd	s0,8(sp)
    5cba:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5cbc:	02b57663          	bgeu	a0,a1,5ce8 <memmove+0x32>
    while(n-- > 0)
    5cc0:	02c05163          	blez	a2,5ce2 <memmove+0x2c>
    5cc4:	fff6079b          	addiw	a5,a2,-1
    5cc8:	1782                	slli	a5,a5,0x20
    5cca:	9381                	srli	a5,a5,0x20
    5ccc:	0785                	addi	a5,a5,1
    5cce:	97aa                	add	a5,a5,a0
  dst = vdst;
    5cd0:	872a                	mv	a4,a0
      *dst++ = *src++;
    5cd2:	0585                	addi	a1,a1,1
    5cd4:	0705                	addi	a4,a4,1
    5cd6:	fff5c683          	lbu	a3,-1(a1)
    5cda:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5cde:	fee79ae3          	bne	a5,a4,5cd2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5ce2:	6422                	ld	s0,8(sp)
    5ce4:	0141                	addi	sp,sp,16
    5ce6:	8082                	ret
    dst += n;
    5ce8:	00c50733          	add	a4,a0,a2
    src += n;
    5cec:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5cee:	fec05ae3          	blez	a2,5ce2 <memmove+0x2c>
    5cf2:	fff6079b          	addiw	a5,a2,-1
    5cf6:	1782                	slli	a5,a5,0x20
    5cf8:	9381                	srli	a5,a5,0x20
    5cfa:	fff7c793          	not	a5,a5
    5cfe:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5d00:	15fd                	addi	a1,a1,-1
    5d02:	177d                	addi	a4,a4,-1
    5d04:	0005c683          	lbu	a3,0(a1)
    5d08:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5d0c:	fee79ae3          	bne	a5,a4,5d00 <memmove+0x4a>
    5d10:	bfc9                	j	5ce2 <memmove+0x2c>

0000000000005d12 <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
    5d12:	1141                	addi	sp,sp,-16
    5d14:	e422                	sd	s0,8(sp)
    5d16:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5d18:	ca05                	beqz	a2,5d48 <memcmp+0x36>
    5d1a:	fff6069b          	addiw	a3,a2,-1
    5d1e:	1682                	slli	a3,a3,0x20
    5d20:	9281                	srli	a3,a3,0x20
    5d22:	0685                	addi	a3,a3,1
    5d24:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5d26:	00054783          	lbu	a5,0(a0)
    5d2a:	0005c703          	lbu	a4,0(a1)
    5d2e:	00e79863          	bne	a5,a4,5d3e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    5d32:	0505                	addi	a0,a0,1
    p2++;
    5d34:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5d36:	fed518e3          	bne	a0,a3,5d26 <memcmp+0x14>
  }
  return 0;
    5d3a:	4501                	li	a0,0
    5d3c:	a019                	j	5d42 <memcmp+0x30>
      return *p1 - *p2;
    5d3e:	40e7853b          	subw	a0,a5,a4
}
    5d42:	6422                	ld	s0,8(sp)
    5d44:	0141                	addi	sp,sp,16
    5d46:	8082                	ret
  return 0;
    5d48:	4501                	li	a0,0
    5d4a:	bfe5                	j	5d42 <memcmp+0x30>

0000000000005d4c <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
    5d4c:	1141                	addi	sp,sp,-16
    5d4e:	e406                	sd	ra,8(sp)
    5d50:	e022                	sd	s0,0(sp)
    5d52:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5d54:	00000097          	auipc	ra,0x0
    5d58:	f62080e7          	jalr	-158(ra) # 5cb6 <memmove>
}
    5d5c:	60a2                	ld	ra,8(sp)
    5d5e:	6402                	ld	s0,0(sp)
    5d60:	0141                	addi	sp,sp,16
    5d62:	8082                	ret

0000000000005d64 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5d64:	4885                	li	a7,1
 ecall
    5d66:	00000073          	ecall
 ret
    5d6a:	8082                	ret

0000000000005d6c <exit>:
.global exit
exit:
 li a7, SYS_exit
    5d6c:	4889                	li	a7,2
 ecall
    5d6e:	00000073          	ecall
 ret
    5d72:	8082                	ret

0000000000005d74 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
    5d74:	48e1                	li	a7,24
 ecall
    5d76:	00000073          	ecall
 ret
    5d7a:	8082                	ret

0000000000005d7c <wait>:
.global wait
wait:
 li a7, SYS_wait
    5d7c:	488d                	li	a7,3
 ecall
    5d7e:	00000073          	ecall
 ret
    5d82:	8082                	ret

0000000000005d84 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5d84:	4891                	li	a7,4
 ecall
    5d86:	00000073          	ecall
 ret
    5d8a:	8082                	ret

0000000000005d8c <read>:
.global read
read:
 li a7, SYS_read
    5d8c:	4895                	li	a7,5
 ecall
    5d8e:	00000073          	ecall
 ret
    5d92:	8082                	ret

0000000000005d94 <write>:
.global write
write:
 li a7, SYS_write
    5d94:	48c1                	li	a7,16
 ecall
    5d96:	00000073          	ecall
 ret
    5d9a:	8082                	ret

0000000000005d9c <close>:
.global close
close:
 li a7, SYS_close
    5d9c:	48d5                	li	a7,21
 ecall
    5d9e:	00000073          	ecall
 ret
    5da2:	8082                	ret

0000000000005da4 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5da4:	4899                	li	a7,6
 ecall
    5da6:	00000073          	ecall
 ret
    5daa:	8082                	ret

0000000000005dac <exec>:
.global exec
exec:
 li a7, SYS_exec
    5dac:	489d                	li	a7,7
 ecall
    5dae:	00000073          	ecall
 ret
    5db2:	8082                	ret

0000000000005db4 <open>:
.global open
open:
 li a7, SYS_open
    5db4:	48bd                	li	a7,15
 ecall
    5db6:	00000073          	ecall
 ret
    5dba:	8082                	ret

0000000000005dbc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5dbc:	48c5                	li	a7,17
 ecall
    5dbe:	00000073          	ecall
 ret
    5dc2:	8082                	ret

0000000000005dc4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5dc4:	48c9                	li	a7,18
 ecall
    5dc6:	00000073          	ecall
 ret
    5dca:	8082                	ret

0000000000005dcc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5dcc:	48a1                	li	a7,8
 ecall
    5dce:	00000073          	ecall
 ret
    5dd2:	8082                	ret

0000000000005dd4 <link>:
.global link
link:
 li a7, SYS_link
    5dd4:	48cd                	li	a7,19
 ecall
    5dd6:	00000073          	ecall
 ret
    5dda:	8082                	ret

0000000000005ddc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5ddc:	48d1                	li	a7,20
 ecall
    5dde:	00000073          	ecall
 ret
    5de2:	8082                	ret

0000000000005de4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5de4:	48a5                	li	a7,9
 ecall
    5de6:	00000073          	ecall
 ret
    5dea:	8082                	ret

0000000000005dec <dup>:
.global dup
dup:
 li a7, SYS_dup
    5dec:	48a9                	li	a7,10
 ecall
    5dee:	00000073          	ecall
 ret
    5df2:	8082                	ret

0000000000005df4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5df4:	48ad                	li	a7,11
 ecall
    5df6:	00000073          	ecall
 ret
    5dfa:	8082                	ret

0000000000005dfc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5dfc:	48b1                	li	a7,12
 ecall
    5dfe:	00000073          	ecall
 ret
    5e02:	8082                	ret

0000000000005e04 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5e04:	48b5                	li	a7,13
 ecall
    5e06:	00000073          	ecall
 ret
    5e0a:	8082                	ret

0000000000005e0c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5e0c:	48b9                	li	a7,14
 ecall
    5e0e:	00000073          	ecall
 ret
    5e12:	8082                	ret

0000000000005e14 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
    5e14:	48dd                	li	a7,23
 ecall
    5e16:	00000073          	ecall
 ret
    5e1a:	8082                	ret

0000000000005e1c <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
    5e1c:	48e5                	li	a7,25
 ecall
    5e1e:	00000073          	ecall
 ret
    5e22:	8082                	ret

0000000000005e24 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
    5e24:	48e9                	li	a7,26
 ecall
    5e26:	00000073          	ecall
 ret
    5e2a:	8082                	ret

0000000000005e2c <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
    5e2c:	48ed                	li	a7,27
 ecall
    5e2e:	00000073          	ecall
 ret
    5e32:	8082                	ret

0000000000005e34 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5e34:	1101                	addi	sp,sp,-32
    5e36:	ec06                	sd	ra,24(sp)
    5e38:	e822                	sd	s0,16(sp)
    5e3a:	1000                	addi	s0,sp,32
    5e3c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5e40:	4605                	li	a2,1
    5e42:	fef40593          	addi	a1,s0,-17
    5e46:	00000097          	auipc	ra,0x0
    5e4a:	f4e080e7          	jalr	-178(ra) # 5d94 <write>
}
    5e4e:	60e2                	ld	ra,24(sp)
    5e50:	6442                	ld	s0,16(sp)
    5e52:	6105                	addi	sp,sp,32
    5e54:	8082                	ret

0000000000005e56 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5e56:	7139                	addi	sp,sp,-64
    5e58:	fc06                	sd	ra,56(sp)
    5e5a:	f822                	sd	s0,48(sp)
    5e5c:	f426                	sd	s1,40(sp)
    5e5e:	f04a                	sd	s2,32(sp)
    5e60:	ec4e                	sd	s3,24(sp)
    5e62:	0080                	addi	s0,sp,64
    5e64:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5e66:	c299                	beqz	a3,5e6c <printint+0x16>
    5e68:	0805c863          	bltz	a1,5ef8 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5e6c:	2581                	sext.w	a1,a1
  neg = 0;
    5e6e:	4881                	li	a7,0
    5e70:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5e74:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5e76:	2601                	sext.w	a2,a2
    5e78:	00003517          	auipc	a0,0x3
    5e7c:	8b850513          	addi	a0,a0,-1864 # 8730 <digits>
    5e80:	883a                	mv	a6,a4
    5e82:	2705                	addiw	a4,a4,1
    5e84:	02c5f7bb          	remuw	a5,a1,a2
    5e88:	1782                	slli	a5,a5,0x20
    5e8a:	9381                	srli	a5,a5,0x20
    5e8c:	97aa                	add	a5,a5,a0
    5e8e:	0007c783          	lbu	a5,0(a5)
    5e92:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5e96:	0005879b          	sext.w	a5,a1
    5e9a:	02c5d5bb          	divuw	a1,a1,a2
    5e9e:	0685                	addi	a3,a3,1
    5ea0:	fec7f0e3          	bgeu	a5,a2,5e80 <printint+0x2a>
  if(neg)
    5ea4:	00088b63          	beqz	a7,5eba <printint+0x64>
    buf[i++] = '-';
    5ea8:	fd040793          	addi	a5,s0,-48
    5eac:	973e                	add	a4,a4,a5
    5eae:	02d00793          	li	a5,45
    5eb2:	fef70823          	sb	a5,-16(a4)
    5eb6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5eba:	02e05863          	blez	a4,5eea <printint+0x94>
    5ebe:	fc040793          	addi	a5,s0,-64
    5ec2:	00e78933          	add	s2,a5,a4
    5ec6:	fff78993          	addi	s3,a5,-1
    5eca:	99ba                	add	s3,s3,a4
    5ecc:	377d                	addiw	a4,a4,-1
    5ece:	1702                	slli	a4,a4,0x20
    5ed0:	9301                	srli	a4,a4,0x20
    5ed2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5ed6:	fff94583          	lbu	a1,-1(s2)
    5eda:	8526                	mv	a0,s1
    5edc:	00000097          	auipc	ra,0x0
    5ee0:	f58080e7          	jalr	-168(ra) # 5e34 <putc>
  while(--i >= 0)
    5ee4:	197d                	addi	s2,s2,-1
    5ee6:	ff3918e3          	bne	s2,s3,5ed6 <printint+0x80>
}
    5eea:	70e2                	ld	ra,56(sp)
    5eec:	7442                	ld	s0,48(sp)
    5eee:	74a2                	ld	s1,40(sp)
    5ef0:	7902                	ld	s2,32(sp)
    5ef2:	69e2                	ld	s3,24(sp)
    5ef4:	6121                	addi	sp,sp,64
    5ef6:	8082                	ret
    x = -xx;
    5ef8:	40b005bb          	negw	a1,a1
    neg = 1;
    5efc:	4885                	li	a7,1
    x = -xx;
    5efe:	bf8d                	j	5e70 <printint+0x1a>

0000000000005f00 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5f00:	7119                	addi	sp,sp,-128
    5f02:	fc86                	sd	ra,120(sp)
    5f04:	f8a2                	sd	s0,112(sp)
    5f06:	f4a6                	sd	s1,104(sp)
    5f08:	f0ca                	sd	s2,96(sp)
    5f0a:	ecce                	sd	s3,88(sp)
    5f0c:	e8d2                	sd	s4,80(sp)
    5f0e:	e4d6                	sd	s5,72(sp)
    5f10:	e0da                	sd	s6,64(sp)
    5f12:	fc5e                	sd	s7,56(sp)
    5f14:	f862                	sd	s8,48(sp)
    5f16:	f466                	sd	s9,40(sp)
    5f18:	f06a                	sd	s10,32(sp)
    5f1a:	ec6e                	sd	s11,24(sp)
    5f1c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5f1e:	0005c903          	lbu	s2,0(a1)
    5f22:	18090f63          	beqz	s2,60c0 <vprintf+0x1c0>
    5f26:	8aaa                	mv	s5,a0
    5f28:	8b32                	mv	s6,a2
    5f2a:	00158493          	addi	s1,a1,1
  state = 0;
    5f2e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5f30:	02500a13          	li	s4,37
      if(c == 'd'){
    5f34:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5f38:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5f3c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5f40:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5f44:	00002b97          	auipc	s7,0x2
    5f48:	7ecb8b93          	addi	s7,s7,2028 # 8730 <digits>
    5f4c:	a839                	j	5f6a <vprintf+0x6a>
        putc(fd, c);
    5f4e:	85ca                	mv	a1,s2
    5f50:	8556                	mv	a0,s5
    5f52:	00000097          	auipc	ra,0x0
    5f56:	ee2080e7          	jalr	-286(ra) # 5e34 <putc>
    5f5a:	a019                	j	5f60 <vprintf+0x60>
    } else if(state == '%'){
    5f5c:	01498f63          	beq	s3,s4,5f7a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5f60:	0485                	addi	s1,s1,1
    5f62:	fff4c903          	lbu	s2,-1(s1)
    5f66:	14090d63          	beqz	s2,60c0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5f6a:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5f6e:	fe0997e3          	bnez	s3,5f5c <vprintf+0x5c>
      if(c == '%'){
    5f72:	fd479ee3          	bne	a5,s4,5f4e <vprintf+0x4e>
        state = '%';
    5f76:	89be                	mv	s3,a5
    5f78:	b7e5                	j	5f60 <vprintf+0x60>
      if(c == 'd'){
    5f7a:	05878063          	beq	a5,s8,5fba <vprintf+0xba>
      } else if(c == 'l') {
    5f7e:	05978c63          	beq	a5,s9,5fd6 <vprintf+0xd6>
      } else if(c == 'x') {
    5f82:	07a78863          	beq	a5,s10,5ff2 <vprintf+0xf2>
      } else if(c == 'p') {
    5f86:	09b78463          	beq	a5,s11,600e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5f8a:	07300713          	li	a4,115
    5f8e:	0ce78663          	beq	a5,a4,605a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5f92:	06300713          	li	a4,99
    5f96:	0ee78e63          	beq	a5,a4,6092 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5f9a:	11478863          	beq	a5,s4,60aa <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5f9e:	85d2                	mv	a1,s4
    5fa0:	8556                	mv	a0,s5
    5fa2:	00000097          	auipc	ra,0x0
    5fa6:	e92080e7          	jalr	-366(ra) # 5e34 <putc>
        putc(fd, c);
    5faa:	85ca                	mv	a1,s2
    5fac:	8556                	mv	a0,s5
    5fae:	00000097          	auipc	ra,0x0
    5fb2:	e86080e7          	jalr	-378(ra) # 5e34 <putc>
      }
      state = 0;
    5fb6:	4981                	li	s3,0
    5fb8:	b765                	j	5f60 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5fba:	008b0913          	addi	s2,s6,8
    5fbe:	4685                	li	a3,1
    5fc0:	4629                	li	a2,10
    5fc2:	000b2583          	lw	a1,0(s6)
    5fc6:	8556                	mv	a0,s5
    5fc8:	00000097          	auipc	ra,0x0
    5fcc:	e8e080e7          	jalr	-370(ra) # 5e56 <printint>
    5fd0:	8b4a                	mv	s6,s2
      state = 0;
    5fd2:	4981                	li	s3,0
    5fd4:	b771                	j	5f60 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5fd6:	008b0913          	addi	s2,s6,8
    5fda:	4681                	li	a3,0
    5fdc:	4629                	li	a2,10
    5fde:	000b2583          	lw	a1,0(s6)
    5fe2:	8556                	mv	a0,s5
    5fe4:	00000097          	auipc	ra,0x0
    5fe8:	e72080e7          	jalr	-398(ra) # 5e56 <printint>
    5fec:	8b4a                	mv	s6,s2
      state = 0;
    5fee:	4981                	li	s3,0
    5ff0:	bf85                	j	5f60 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5ff2:	008b0913          	addi	s2,s6,8
    5ff6:	4681                	li	a3,0
    5ff8:	4641                	li	a2,16
    5ffa:	000b2583          	lw	a1,0(s6)
    5ffe:	8556                	mv	a0,s5
    6000:	00000097          	auipc	ra,0x0
    6004:	e56080e7          	jalr	-426(ra) # 5e56 <printint>
    6008:	8b4a                	mv	s6,s2
      state = 0;
    600a:	4981                	li	s3,0
    600c:	bf91                	j	5f60 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    600e:	008b0793          	addi	a5,s6,8
    6012:	f8f43423          	sd	a5,-120(s0)
    6016:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    601a:	03000593          	li	a1,48
    601e:	8556                	mv	a0,s5
    6020:	00000097          	auipc	ra,0x0
    6024:	e14080e7          	jalr	-492(ra) # 5e34 <putc>
  putc(fd, 'x');
    6028:	85ea                	mv	a1,s10
    602a:	8556                	mv	a0,s5
    602c:	00000097          	auipc	ra,0x0
    6030:	e08080e7          	jalr	-504(ra) # 5e34 <putc>
    6034:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    6036:	03c9d793          	srli	a5,s3,0x3c
    603a:	97de                	add	a5,a5,s7
    603c:	0007c583          	lbu	a1,0(a5)
    6040:	8556                	mv	a0,s5
    6042:	00000097          	auipc	ra,0x0
    6046:	df2080e7          	jalr	-526(ra) # 5e34 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    604a:	0992                	slli	s3,s3,0x4
    604c:	397d                	addiw	s2,s2,-1
    604e:	fe0914e3          	bnez	s2,6036 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    6052:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    6056:	4981                	li	s3,0
    6058:	b721                	j	5f60 <vprintf+0x60>
        s = va_arg(ap, char*);
    605a:	008b0993          	addi	s3,s6,8
    605e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    6062:	02090163          	beqz	s2,6084 <vprintf+0x184>
        while(*s != 0){
    6066:	00094583          	lbu	a1,0(s2)
    606a:	c9a1                	beqz	a1,60ba <vprintf+0x1ba>
          putc(fd, *s);
    606c:	8556                	mv	a0,s5
    606e:	00000097          	auipc	ra,0x0
    6072:	dc6080e7          	jalr	-570(ra) # 5e34 <putc>
          s++;
    6076:	0905                	addi	s2,s2,1
        while(*s != 0){
    6078:	00094583          	lbu	a1,0(s2)
    607c:	f9e5                	bnez	a1,606c <vprintf+0x16c>
        s = va_arg(ap, char*);
    607e:	8b4e                	mv	s6,s3
      state = 0;
    6080:	4981                	li	s3,0
    6082:	bdf9                	j	5f60 <vprintf+0x60>
          s = "(null)";
    6084:	00002917          	auipc	s2,0x2
    6088:	6a490913          	addi	s2,s2,1700 # 8728 <malloc+0x255e>
        while(*s != 0){
    608c:	02800593          	li	a1,40
    6090:	bff1                	j	606c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    6092:	008b0913          	addi	s2,s6,8
    6096:	000b4583          	lbu	a1,0(s6)
    609a:	8556                	mv	a0,s5
    609c:	00000097          	auipc	ra,0x0
    60a0:	d98080e7          	jalr	-616(ra) # 5e34 <putc>
    60a4:	8b4a                	mv	s6,s2
      state = 0;
    60a6:	4981                	li	s3,0
    60a8:	bd65                	j	5f60 <vprintf+0x60>
        putc(fd, c);
    60aa:	85d2                	mv	a1,s4
    60ac:	8556                	mv	a0,s5
    60ae:	00000097          	auipc	ra,0x0
    60b2:	d86080e7          	jalr	-634(ra) # 5e34 <putc>
      state = 0;
    60b6:	4981                	li	s3,0
    60b8:	b565                	j	5f60 <vprintf+0x60>
        s = va_arg(ap, char*);
    60ba:	8b4e                	mv	s6,s3
      state = 0;
    60bc:	4981                	li	s3,0
    60be:	b54d                	j	5f60 <vprintf+0x60>
    }
  }
}
    60c0:	70e6                	ld	ra,120(sp)
    60c2:	7446                	ld	s0,112(sp)
    60c4:	74a6                	ld	s1,104(sp)
    60c6:	7906                	ld	s2,96(sp)
    60c8:	69e6                	ld	s3,88(sp)
    60ca:	6a46                	ld	s4,80(sp)
    60cc:	6aa6                	ld	s5,72(sp)
    60ce:	6b06                	ld	s6,64(sp)
    60d0:	7be2                	ld	s7,56(sp)
    60d2:	7c42                	ld	s8,48(sp)
    60d4:	7ca2                	ld	s9,40(sp)
    60d6:	7d02                	ld	s10,32(sp)
    60d8:	6de2                	ld	s11,24(sp)
    60da:	6109                	addi	sp,sp,128
    60dc:	8082                	ret

00000000000060de <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    60de:	715d                	addi	sp,sp,-80
    60e0:	ec06                	sd	ra,24(sp)
    60e2:	e822                	sd	s0,16(sp)
    60e4:	1000                	addi	s0,sp,32
    60e6:	e010                	sd	a2,0(s0)
    60e8:	e414                	sd	a3,8(s0)
    60ea:	e818                	sd	a4,16(s0)
    60ec:	ec1c                	sd	a5,24(s0)
    60ee:	03043023          	sd	a6,32(s0)
    60f2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    60f6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    60fa:	8622                	mv	a2,s0
    60fc:	00000097          	auipc	ra,0x0
    6100:	e04080e7          	jalr	-508(ra) # 5f00 <vprintf>
}
    6104:	60e2                	ld	ra,24(sp)
    6106:	6442                	ld	s0,16(sp)
    6108:	6161                	addi	sp,sp,80
    610a:	8082                	ret

000000000000610c <printf>:

void
printf(const char *fmt, ...)
{
    610c:	711d                	addi	sp,sp,-96
    610e:	ec06                	sd	ra,24(sp)
    6110:	e822                	sd	s0,16(sp)
    6112:	1000                	addi	s0,sp,32
    6114:	e40c                	sd	a1,8(s0)
    6116:	e810                	sd	a2,16(s0)
    6118:	ec14                	sd	a3,24(s0)
    611a:	f018                	sd	a4,32(s0)
    611c:	f41c                	sd	a5,40(s0)
    611e:	03043823          	sd	a6,48(s0)
    6122:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    6126:	00840613          	addi	a2,s0,8
    612a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    612e:	85aa                	mv	a1,a0
    6130:	4505                	li	a0,1
    6132:	00000097          	auipc	ra,0x0
    6136:	dce080e7          	jalr	-562(ra) # 5f00 <vprintf>
}
    613a:	60e2                	ld	ra,24(sp)
    613c:	6442                	ld	s0,16(sp)
    613e:	6125                	addi	sp,sp,96
    6140:	8082                	ret

0000000000006142 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    6142:	1141                	addi	sp,sp,-16
    6144:	e422                	sd	s0,8(sp)
    6146:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    6148:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    614c:	00003797          	auipc	a5,0x3
    6150:	3047b783          	ld	a5,772(a5) # 9450 <freep>
    6154:	a805                	j	6184 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    6156:	4618                	lw	a4,8(a2)
    6158:	9db9                	addw	a1,a1,a4
    615a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    615e:	6398                	ld	a4,0(a5)
    6160:	6318                	ld	a4,0(a4)
    6162:	fee53823          	sd	a4,-16(a0)
    6166:	a091                	j	61aa <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    6168:	ff852703          	lw	a4,-8(a0)
    616c:	9e39                	addw	a2,a2,a4
    616e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    6170:	ff053703          	ld	a4,-16(a0)
    6174:	e398                	sd	a4,0(a5)
    6176:	a099                	j	61bc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    6178:	6398                	ld	a4,0(a5)
    617a:	00e7e463          	bltu	a5,a4,6182 <free+0x40>
    617e:	00e6ea63          	bltu	a3,a4,6192 <free+0x50>
{
    6182:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    6184:	fed7fae3          	bgeu	a5,a3,6178 <free+0x36>
    6188:	6398                	ld	a4,0(a5)
    618a:	00e6e463          	bltu	a3,a4,6192 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    618e:	fee7eae3          	bltu	a5,a4,6182 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    6192:	ff852583          	lw	a1,-8(a0)
    6196:	6390                	ld	a2,0(a5)
    6198:	02059713          	slli	a4,a1,0x20
    619c:	9301                	srli	a4,a4,0x20
    619e:	0712                	slli	a4,a4,0x4
    61a0:	9736                	add	a4,a4,a3
    61a2:	fae60ae3          	beq	a2,a4,6156 <free+0x14>
    bp->s.ptr = p->s.ptr;
    61a6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    61aa:	4790                	lw	a2,8(a5)
    61ac:	02061713          	slli	a4,a2,0x20
    61b0:	9301                	srli	a4,a4,0x20
    61b2:	0712                	slli	a4,a4,0x4
    61b4:	973e                	add	a4,a4,a5
    61b6:	fae689e3          	beq	a3,a4,6168 <free+0x26>
  } else
    p->s.ptr = bp;
    61ba:	e394                	sd	a3,0(a5)
  freep = p;
    61bc:	00003717          	auipc	a4,0x3
    61c0:	28f73a23          	sd	a5,660(a4) # 9450 <freep>
}
    61c4:	6422                	ld	s0,8(sp)
    61c6:	0141                	addi	sp,sp,16
    61c8:	8082                	ret

00000000000061ca <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    61ca:	7139                	addi	sp,sp,-64
    61cc:	fc06                	sd	ra,56(sp)
    61ce:	f822                	sd	s0,48(sp)
    61d0:	f426                	sd	s1,40(sp)
    61d2:	f04a                	sd	s2,32(sp)
    61d4:	ec4e                	sd	s3,24(sp)
    61d6:	e852                	sd	s4,16(sp)
    61d8:	e456                	sd	s5,8(sp)
    61da:	e05a                	sd	s6,0(sp)
    61dc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    61de:	02051493          	slli	s1,a0,0x20
    61e2:	9081                	srli	s1,s1,0x20
    61e4:	04bd                	addi	s1,s1,15
    61e6:	8091                	srli	s1,s1,0x4
    61e8:	0014899b          	addiw	s3,s1,1
    61ec:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    61ee:	00003517          	auipc	a0,0x3
    61f2:	26253503          	ld	a0,610(a0) # 9450 <freep>
    61f6:	c515                	beqz	a0,6222 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    61f8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    61fa:	4798                	lw	a4,8(a5)
    61fc:	02977f63          	bgeu	a4,s1,623a <malloc+0x70>
    6200:	8a4e                	mv	s4,s3
    6202:	0009871b          	sext.w	a4,s3
    6206:	6685                	lui	a3,0x1
    6208:	00d77363          	bgeu	a4,a3,620e <malloc+0x44>
    620c:	6a05                	lui	s4,0x1
    620e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    6212:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    6216:	00003917          	auipc	s2,0x3
    621a:	23a90913          	addi	s2,s2,570 # 9450 <freep>
  if(p == (char*)-1)
    621e:	5afd                	li	s5,-1
    6220:	a88d                	j	6292 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    6222:	0000a797          	auipc	a5,0xa
    6226:	a5678793          	addi	a5,a5,-1450 # fc78 <base>
    622a:	00003717          	auipc	a4,0x3
    622e:	22f73323          	sd	a5,550(a4) # 9450 <freep>
    6232:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    6234:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    6238:	b7e1                	j	6200 <malloc+0x36>
      if(p->s.size == nunits)
    623a:	02e48b63          	beq	s1,a4,6270 <malloc+0xa6>
        p->s.size -= nunits;
    623e:	4137073b          	subw	a4,a4,s3
    6242:	c798                	sw	a4,8(a5)
        p += p->s.size;
    6244:	1702                	slli	a4,a4,0x20
    6246:	9301                	srli	a4,a4,0x20
    6248:	0712                	slli	a4,a4,0x4
    624a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    624c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    6250:	00003717          	auipc	a4,0x3
    6254:	20a73023          	sd	a0,512(a4) # 9450 <freep>
      return (void*)(p + 1);
    6258:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    625c:	70e2                	ld	ra,56(sp)
    625e:	7442                	ld	s0,48(sp)
    6260:	74a2                	ld	s1,40(sp)
    6262:	7902                	ld	s2,32(sp)
    6264:	69e2                	ld	s3,24(sp)
    6266:	6a42                	ld	s4,16(sp)
    6268:	6aa2                	ld	s5,8(sp)
    626a:	6b02                	ld	s6,0(sp)
    626c:	6121                	addi	sp,sp,64
    626e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    6270:	6398                	ld	a4,0(a5)
    6272:	e118                	sd	a4,0(a0)
    6274:	bff1                	j	6250 <malloc+0x86>
  hp->s.size = nu;
    6276:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    627a:	0541                	addi	a0,a0,16
    627c:	00000097          	auipc	ra,0x0
    6280:	ec6080e7          	jalr	-314(ra) # 6142 <free>
  return freep;
    6284:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    6288:	d971                	beqz	a0,625c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    628a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    628c:	4798                	lw	a4,8(a5)
    628e:	fa9776e3          	bgeu	a4,s1,623a <malloc+0x70>
    if(p == freep)
    6292:	00093703          	ld	a4,0(s2)
    6296:	853e                	mv	a0,a5
    6298:	fef719e3          	bne	a4,a5,628a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    629c:	8552                	mv	a0,s4
    629e:	00000097          	auipc	ra,0x0
    62a2:	b5e080e7          	jalr	-1186(ra) # 5dfc <sbrk>
  if(p == (char*)-1)
    62a6:	fd5518e3          	bne	a0,s5,6276 <malloc+0xac>
        return 0;
    62aa:	4501                	li	a0,0
    62ac:	bf45                	j	625c <malloc+0x92>
