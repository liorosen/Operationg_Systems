
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	ef8080e7          	jalr	-264(ra) # f88 <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	3a650513          	addi	a0,a0,934 # 1440 <malloc+0xea>
      a2:	00001097          	auipc	ra,0x1
      a6:	ec6080e7          	jalr	-314(ra) # f68 <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	39650513          	addi	a0,a0,918 # 1440 <malloc+0xea>
      b2:	00001097          	auipc	ra,0x1
      b6:	ebe080e7          	jalr	-322(ra) # f70 <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	38c50513          	addi	a0,a0,908 # 1448 <malloc+0xf2>
      c4:	00001097          	auipc	ra,0x1
      c8:	1d4080e7          	jalr	468(ra) # 1298 <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	e2a080e7          	jalr	-470(ra) # ef8 <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	39250513          	addi	a0,a0,914 # 1468 <malloc+0x112>
      de:	00001097          	auipc	ra,0x1
      e2:	e92080e7          	jalr	-366(ra) # f70 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      e6:	00001997          	auipc	s3,0x1
      ea:	39298993          	addi	s3,s3,914 # 1478 <malloc+0x122>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	38098993          	addi	s3,s3,896 # 1470 <malloc+0x11a>
    iters++;
      f8:	4485                	li	s1,1
  int fd = -1;
      fa:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
      fc:	00002a17          	auipc	s4,0x2
     100:	f24a0a13          	addi	s4,s4,-220 # 2020 <buf.1254>
     104:	a825                	j	13c <go+0xc4>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	37650513          	addi	a0,a0,886 # 1480 <malloc+0x12a>
     112:	00001097          	auipc	ra,0x1
     116:	e2e080e7          	jalr	-466(ra) # f40 <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	e0e080e7          	jalr	-498(ra) # f28 <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	dec080e7          	jalr	-532(ra) # f20 <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	4789                	li	a5,2
     152:	18f50d63          	beq	a0,a5,2ec <go+0x274>
    } else if(what == 3){
     156:	478d                	li	a5,3
     158:	1af50963          	beq	a0,a5,30a <go+0x292>
    } else if(what == 4){
     15c:	4791                	li	a5,4
     15e:	1af50f63          	beq	a0,a5,31c <go+0x2a4>
    } else if(what == 5){
     162:	4795                	li	a5,5
     164:	20f50363          	beq	a0,a5,36a <go+0x2f2>
    } else if(what == 6){
     168:	4799                	li	a5,6
     16a:	22f50163          	beq	a0,a5,38c <go+0x314>
    } else if(what == 7){
     16e:	479d                	li	a5,7
     170:	22f50f63          	beq	a0,a5,3ae <go+0x336>
    } else if(what == 8){
     174:	47a1                	li	a5,8
     176:	24f50563          	beq	a0,a5,3c0 <go+0x348>
    } else if(what == 9){
     17a:	47a5                	li	a5,9
     17c:	24f50b63          	beq	a0,a5,3d2 <go+0x35a>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     180:	47a9                	li	a5,10
     182:	28f50763          	beq	a0,a5,410 <go+0x398>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     186:	47ad                	li	a5,11
     188:	2cf50363          	beq	a0,a5,44e <go+0x3d6>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     18c:	47b1                	li	a5,12
     18e:	2ef50563          	beq	a0,a5,478 <go+0x400>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     192:	47b5                	li	a5,13
     194:	30f50763          	beq	a0,a5,4a2 <go+0x42a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0, "");
    } else if(what == 14){
     198:	47b9                	li	a5,14
     19a:	34f50663          	beq	a0,a5,4e6 <go+0x46e>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0, "");
    } else if(what == 15){
     19e:	47bd                	li	a5,15
     1a0:	38f50e63          	beq	a0,a5,53c <go+0x4c4>
      sbrk(6011);
    } else if(what == 16){
     1a4:	47c1                	li	a5,16
     1a6:	3af50363          	beq	a0,a5,54c <go+0x4d4>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     1aa:	47c5                	li	a5,17
     1ac:	3cf50363          	beq	a0,a5,572 <go+0x4fa>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0, "");
    } else if(what == 18){
     1b0:	47c9                	li	a5,18
     1b2:	44f50d63          	beq	a0,a5,60c <go+0x594>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0, "");
    } else if(what == 19){
     1b6:	47cd                	li	a5,19
     1b8:	4af50563          	beq	a0,a5,662 <go+0x5ea>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0, "");
    } else if(what == 20){
     1bc:	47d1                	li	a5,20
     1be:	58f50a63          	beq	a0,a5,752 <go+0x6da>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0, "");
    } else if(what == 21){
     1c2:	47d5                	li	a5,21
     1c4:	62f50c63          	beq	a0,a5,7fc <go+0x784>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     1c8:	47d9                	li	a5,22
     1ca:	f4f51ce3          	bne	a0,a5,122 <go+0xaa>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1ce:	f9840513          	addi	a0,s0,-104
     1d2:	00001097          	auipc	ra,0x1
     1d6:	d3e080e7          	jalr	-706(ra) # f10 <pipe>
     1da:	72054563          	bltz	a0,904 <go+0x88c>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1de:	fa040513          	addi	a0,s0,-96
     1e2:	00001097          	auipc	ra,0x1
     1e6:	d2e080e7          	jalr	-722(ra) # f10 <pipe>
     1ea:	72054b63          	bltz	a0,920 <go+0x8a8>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1ee:	00001097          	auipc	ra,0x1
     1f2:	d02080e7          	jalr	-766(ra) # ef0 <fork>
      if(pid1 == 0){
     1f6:	74050363          	beqz	a0,93c <go+0x8c4>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1fa:	7e054b63          	bltz	a0,9f0 <go+0x978>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1fe:	00001097          	auipc	ra,0x1
     202:	cf2080e7          	jalr	-782(ra) # ef0 <fork>
      if(pid2 == 0){
     206:	000503e3          	beqz	a0,a0c <go+0x994>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     20a:	0c054fe3          	bltz	a0,ae8 <go+0xa70>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     20e:	f9842503          	lw	a0,-104(s0)
     212:	00001097          	auipc	ra,0x1
     216:	d16080e7          	jalr	-746(ra) # f28 <close>
      close(aa[1]);
     21a:	f9c42503          	lw	a0,-100(s0)
     21e:	00001097          	auipc	ra,0x1
     222:	d0a080e7          	jalr	-758(ra) # f28 <close>
      close(bb[1]);
     226:	fa442503          	lw	a0,-92(s0)
     22a:	00001097          	auipc	ra,0x1
     22e:	cfe080e7          	jalr	-770(ra) # f28 <close>
      char buf[4] = { 0, 0, 0, 0 };
     232:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     236:	4605                	li	a2,1
     238:	f9040593          	addi	a1,s0,-112
     23c:	fa042503          	lw	a0,-96(s0)
     240:	00001097          	auipc	ra,0x1
     244:	cd8080e7          	jalr	-808(ra) # f18 <read>
      read(bb[0], buf+1, 1);
     248:	4605                	li	a2,1
     24a:	f9140593          	addi	a1,s0,-111
     24e:	fa042503          	lw	a0,-96(s0)
     252:	00001097          	auipc	ra,0x1
     256:	cc6080e7          	jalr	-826(ra) # f18 <read>
      read(bb[0], buf+2, 1);
     25a:	4605                	li	a2,1
     25c:	f9240593          	addi	a1,s0,-110
     260:	fa042503          	lw	a0,-96(s0)
     264:	00001097          	auipc	ra,0x1
     268:	cb4080e7          	jalr	-844(ra) # f18 <read>
      close(bb[0]);
     26c:	fa042503          	lw	a0,-96(s0)
     270:	00001097          	auipc	ra,0x1
     274:	cb8080e7          	jalr	-840(ra) # f28 <close>
      int st1, st2;
      wait(&st1, "");
     278:	00001597          	auipc	a1,0x1
     27c:	36058593          	addi	a1,a1,864 # 15d8 <malloc+0x282>
     280:	f9440513          	addi	a0,s0,-108
     284:	00001097          	auipc	ra,0x1
     288:	c84080e7          	jalr	-892(ra) # f08 <wait>
      wait(&st2, "");
     28c:	00001597          	auipc	a1,0x1
     290:	34c58593          	addi	a1,a1,844 # 15d8 <malloc+0x282>
     294:	fa840513          	addi	a0,s0,-88
     298:	00001097          	auipc	ra,0x1
     29c:	c70080e7          	jalr	-912(ra) # f08 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     2a0:	f9442783          	lw	a5,-108(s0)
     2a4:	fa842703          	lw	a4,-88(s0)
     2a8:	8fd9                	or	a5,a5,a4
     2aa:	2781                	sext.w	a5,a5
     2ac:	ef89                	bnez	a5,2c6 <go+0x24e>
     2ae:	00001597          	auipc	a1,0x1
     2b2:	44a58593          	addi	a1,a1,1098 # 16f8 <malloc+0x3a2>
     2b6:	f9040513          	addi	a0,s0,-112
     2ba:	00001097          	auipc	ra,0x1
     2be:	9e4080e7          	jalr	-1564(ra) # c9e <strcmp>
     2c2:	e60500e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2c6:	f9040693          	addi	a3,s0,-112
     2ca:	fa842603          	lw	a2,-88(s0)
     2ce:	f9442583          	lw	a1,-108(s0)
     2d2:	00001517          	auipc	a0,0x1
     2d6:	42e50513          	addi	a0,a0,1070 # 1700 <malloc+0x3aa>
     2da:	00001097          	auipc	ra,0x1
     2de:	fbe080e7          	jalr	-66(ra) # 1298 <printf>
        exit(1);
     2e2:	4505                	li	a0,1
     2e4:	00001097          	auipc	ra,0x1
     2e8:	c14080e7          	jalr	-1004(ra) # ef8 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2ec:	20200593          	li	a1,514
     2f0:	00001517          	auipc	a0,0x1
     2f4:	1a050513          	addi	a0,a0,416 # 1490 <malloc+0x13a>
     2f8:	00001097          	auipc	ra,0x1
     2fc:	c48080e7          	jalr	-952(ra) # f40 <open>
     300:	00001097          	auipc	ra,0x1
     304:	c28080e7          	jalr	-984(ra) # f28 <close>
     308:	bd29                	j	122 <go+0xaa>
      unlink("grindir/../a");
     30a:	00001517          	auipc	a0,0x1
     30e:	17650513          	addi	a0,a0,374 # 1480 <malloc+0x12a>
     312:	00001097          	auipc	ra,0x1
     316:	c3e080e7          	jalr	-962(ra) # f50 <unlink>
     31a:	b521                	j	122 <go+0xaa>
      if(chdir("grindir") != 0){
     31c:	00001517          	auipc	a0,0x1
     320:	12450513          	addi	a0,a0,292 # 1440 <malloc+0xea>
     324:	00001097          	auipc	ra,0x1
     328:	c4c080e7          	jalr	-948(ra) # f70 <chdir>
     32c:	e115                	bnez	a0,350 <go+0x2d8>
      unlink("../b");
     32e:	00001517          	auipc	a0,0x1
     332:	17a50513          	addi	a0,a0,378 # 14a8 <malloc+0x152>
     336:	00001097          	auipc	ra,0x1
     33a:	c1a080e7          	jalr	-998(ra) # f50 <unlink>
      chdir("/");
     33e:	00001517          	auipc	a0,0x1
     342:	12a50513          	addi	a0,a0,298 # 1468 <malloc+0x112>
     346:	00001097          	auipc	ra,0x1
     34a:	c2a080e7          	jalr	-982(ra) # f70 <chdir>
     34e:	bbd1                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     350:	00001517          	auipc	a0,0x1
     354:	0f850513          	addi	a0,a0,248 # 1448 <malloc+0xf2>
     358:	00001097          	auipc	ra,0x1
     35c:	f40080e7          	jalr	-192(ra) # 1298 <printf>
        exit(1);
     360:	4505                	li	a0,1
     362:	00001097          	auipc	ra,0x1
     366:	b96080e7          	jalr	-1130(ra) # ef8 <exit>
      close(fd);
     36a:	854a                	mv	a0,s2
     36c:	00001097          	auipc	ra,0x1
     370:	bbc080e7          	jalr	-1092(ra) # f28 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     374:	20200593          	li	a1,514
     378:	00001517          	auipc	a0,0x1
     37c:	13850513          	addi	a0,a0,312 # 14b0 <malloc+0x15a>
     380:	00001097          	auipc	ra,0x1
     384:	bc0080e7          	jalr	-1088(ra) # f40 <open>
     388:	892a                	mv	s2,a0
     38a:	bb61                	j	122 <go+0xaa>
      close(fd);
     38c:	854a                	mv	a0,s2
     38e:	00001097          	auipc	ra,0x1
     392:	b9a080e7          	jalr	-1126(ra) # f28 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     396:	20200593          	li	a1,514
     39a:	00001517          	auipc	a0,0x1
     39e:	12650513          	addi	a0,a0,294 # 14c0 <malloc+0x16a>
     3a2:	00001097          	auipc	ra,0x1
     3a6:	b9e080e7          	jalr	-1122(ra) # f40 <open>
     3aa:	892a                	mv	s2,a0
     3ac:	bb9d                	j	122 <go+0xaa>
      write(fd, buf, sizeof(buf));
     3ae:	3e700613          	li	a2,999
     3b2:	85d2                	mv	a1,s4
     3b4:	854a                	mv	a0,s2
     3b6:	00001097          	auipc	ra,0x1
     3ba:	b6a080e7          	jalr	-1174(ra) # f20 <write>
     3be:	b395                	j	122 <go+0xaa>
      read(fd, buf, sizeof(buf));
     3c0:	3e700613          	li	a2,999
     3c4:	85d2                	mv	a1,s4
     3c6:	854a                	mv	a0,s2
     3c8:	00001097          	auipc	ra,0x1
     3cc:	b50080e7          	jalr	-1200(ra) # f18 <read>
     3d0:	bb89                	j	122 <go+0xaa>
      mkdir("grindir/../a");
     3d2:	00001517          	auipc	a0,0x1
     3d6:	0ae50513          	addi	a0,a0,174 # 1480 <malloc+0x12a>
     3da:	00001097          	auipc	ra,0x1
     3de:	b8e080e7          	jalr	-1138(ra) # f68 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3e2:	20200593          	li	a1,514
     3e6:	00001517          	auipc	a0,0x1
     3ea:	0f250513          	addi	a0,a0,242 # 14d8 <malloc+0x182>
     3ee:	00001097          	auipc	ra,0x1
     3f2:	b52080e7          	jalr	-1198(ra) # f40 <open>
     3f6:	00001097          	auipc	ra,0x1
     3fa:	b32080e7          	jalr	-1230(ra) # f28 <close>
      unlink("a/a");
     3fe:	00001517          	auipc	a0,0x1
     402:	0ea50513          	addi	a0,a0,234 # 14e8 <malloc+0x192>
     406:	00001097          	auipc	ra,0x1
     40a:	b4a080e7          	jalr	-1206(ra) # f50 <unlink>
     40e:	bb11                	j	122 <go+0xaa>
      mkdir("/../b");
     410:	00001517          	auipc	a0,0x1
     414:	0e050513          	addi	a0,a0,224 # 14f0 <malloc+0x19a>
     418:	00001097          	auipc	ra,0x1
     41c:	b50080e7          	jalr	-1200(ra) # f68 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     420:	20200593          	li	a1,514
     424:	00001517          	auipc	a0,0x1
     428:	0d450513          	addi	a0,a0,212 # 14f8 <malloc+0x1a2>
     42c:	00001097          	auipc	ra,0x1
     430:	b14080e7          	jalr	-1260(ra) # f40 <open>
     434:	00001097          	auipc	ra,0x1
     438:	af4080e7          	jalr	-1292(ra) # f28 <close>
      unlink("b/b");
     43c:	00001517          	auipc	a0,0x1
     440:	0cc50513          	addi	a0,a0,204 # 1508 <malloc+0x1b2>
     444:	00001097          	auipc	ra,0x1
     448:	b0c080e7          	jalr	-1268(ra) # f50 <unlink>
     44c:	b9d9                	j	122 <go+0xaa>
      unlink("b");
     44e:	00001517          	auipc	a0,0x1
     452:	08250513          	addi	a0,a0,130 # 14d0 <malloc+0x17a>
     456:	00001097          	auipc	ra,0x1
     45a:	afa080e7          	jalr	-1286(ra) # f50 <unlink>
      link("../grindir/./../a", "../b");
     45e:	00001597          	auipc	a1,0x1
     462:	04a58593          	addi	a1,a1,74 # 14a8 <malloc+0x152>
     466:	00001517          	auipc	a0,0x1
     46a:	0aa50513          	addi	a0,a0,170 # 1510 <malloc+0x1ba>
     46e:	00001097          	auipc	ra,0x1
     472:	af2080e7          	jalr	-1294(ra) # f60 <link>
     476:	b175                	j	122 <go+0xaa>
      unlink("../grindir/../a");
     478:	00001517          	auipc	a0,0x1
     47c:	0b050513          	addi	a0,a0,176 # 1528 <malloc+0x1d2>
     480:	00001097          	auipc	ra,0x1
     484:	ad0080e7          	jalr	-1328(ra) # f50 <unlink>
      link(".././b", "/grindir/../a");
     488:	00001597          	auipc	a1,0x1
     48c:	02858593          	addi	a1,a1,40 # 14b0 <malloc+0x15a>
     490:	00001517          	auipc	a0,0x1
     494:	0a850513          	addi	a0,a0,168 # 1538 <malloc+0x1e2>
     498:	00001097          	auipc	ra,0x1
     49c:	ac8080e7          	jalr	-1336(ra) # f60 <link>
     4a0:	b149                	j	122 <go+0xaa>
      int pid = fork();
     4a2:	00001097          	auipc	ra,0x1
     4a6:	a4e080e7          	jalr	-1458(ra) # ef0 <fork>
      if(pid == 0){
     4aa:	cd09                	beqz	a0,4c4 <go+0x44c>
      } else if(pid < 0){
     4ac:	02054063          	bltz	a0,4cc <go+0x454>
      wait(0, "");
     4b0:	00001597          	auipc	a1,0x1
     4b4:	12858593          	addi	a1,a1,296 # 15d8 <malloc+0x282>
     4b8:	4501                	li	a0,0
     4ba:	00001097          	auipc	ra,0x1
     4be:	a4e080e7          	jalr	-1458(ra) # f08 <wait>
     4c2:	b185                	j	122 <go+0xaa>
        exit(0);
     4c4:	00001097          	auipc	ra,0x1
     4c8:	a34080e7          	jalr	-1484(ra) # ef8 <exit>
        printf("grind: fork failed\n");
     4cc:	00001517          	auipc	a0,0x1
     4d0:	07450513          	addi	a0,a0,116 # 1540 <malloc+0x1ea>
     4d4:	00001097          	auipc	ra,0x1
     4d8:	dc4080e7          	jalr	-572(ra) # 1298 <printf>
        exit(1);
     4dc:	4505                	li	a0,1
     4de:	00001097          	auipc	ra,0x1
     4e2:	a1a080e7          	jalr	-1510(ra) # ef8 <exit>
      int pid = fork();
     4e6:	00001097          	auipc	ra,0x1
     4ea:	a0a080e7          	jalr	-1526(ra) # ef0 <fork>
      if(pid == 0){
     4ee:	cd09                	beqz	a0,508 <go+0x490>
      } else if(pid < 0){
     4f0:	02054963          	bltz	a0,522 <go+0x4aa>
      wait(0, "");
     4f4:	00001597          	auipc	a1,0x1
     4f8:	0e458593          	addi	a1,a1,228 # 15d8 <malloc+0x282>
     4fc:	4501                	li	a0,0
     4fe:	00001097          	auipc	ra,0x1
     502:	a0a080e7          	jalr	-1526(ra) # f08 <wait>
     506:	b931                	j	122 <go+0xaa>
        fork();
     508:	00001097          	auipc	ra,0x1
     50c:	9e8080e7          	jalr	-1560(ra) # ef0 <fork>
        fork();
     510:	00001097          	auipc	ra,0x1
     514:	9e0080e7          	jalr	-1568(ra) # ef0 <fork>
        exit(0);
     518:	4501                	li	a0,0
     51a:	00001097          	auipc	ra,0x1
     51e:	9de080e7          	jalr	-1570(ra) # ef8 <exit>
        printf("grind: fork failed\n");
     522:	00001517          	auipc	a0,0x1
     526:	01e50513          	addi	a0,a0,30 # 1540 <malloc+0x1ea>
     52a:	00001097          	auipc	ra,0x1
     52e:	d6e080e7          	jalr	-658(ra) # 1298 <printf>
        exit(1);
     532:	4505                	li	a0,1
     534:	00001097          	auipc	ra,0x1
     538:	9c4080e7          	jalr	-1596(ra) # ef8 <exit>
      sbrk(6011);
     53c:	6505                	lui	a0,0x1
     53e:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x4b>
     542:	00001097          	auipc	ra,0x1
     546:	a46080e7          	jalr	-1466(ra) # f88 <sbrk>
     54a:	bee1                	j	122 <go+0xaa>
      if(sbrk(0) > break0)
     54c:	4501                	li	a0,0
     54e:	00001097          	auipc	ra,0x1
     552:	a3a080e7          	jalr	-1478(ra) # f88 <sbrk>
     556:	bcaaf6e3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     55a:	4501                	li	a0,0
     55c:	00001097          	auipc	ra,0x1
     560:	a2c080e7          	jalr	-1492(ra) # f88 <sbrk>
     564:	40aa853b          	subw	a0,s5,a0
     568:	00001097          	auipc	ra,0x1
     56c:	a20080e7          	jalr	-1504(ra) # f88 <sbrk>
     570:	be4d                	j	122 <go+0xaa>
      int pid = fork();
     572:	00001097          	auipc	ra,0x1
     576:	97e080e7          	jalr	-1666(ra) # ef0 <fork>
     57a:	8b2a                	mv	s6,a0
      if(pid == 0){
     57c:	c91d                	beqz	a0,5b2 <go+0x53a>
      } else if(pid < 0){
     57e:	04054d63          	bltz	a0,5d8 <go+0x560>
      if(chdir("../grindir/..") != 0){
     582:	00001517          	auipc	a0,0x1
     586:	fd650513          	addi	a0,a0,-42 # 1558 <malloc+0x202>
     58a:	00001097          	auipc	ra,0x1
     58e:	9e6080e7          	jalr	-1562(ra) # f70 <chdir>
     592:	e125                	bnez	a0,5f2 <go+0x57a>
      kill(pid);
     594:	855a                	mv	a0,s6
     596:	00001097          	auipc	ra,0x1
     59a:	99a080e7          	jalr	-1638(ra) # f30 <kill>
      wait(0, "");
     59e:	00001597          	auipc	a1,0x1
     5a2:	03a58593          	addi	a1,a1,58 # 15d8 <malloc+0x282>
     5a6:	4501                	li	a0,0
     5a8:	00001097          	auipc	ra,0x1
     5ac:	960080e7          	jalr	-1696(ra) # f08 <wait>
     5b0:	be8d                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     5b2:	20200593          	li	a1,514
     5b6:	00001517          	auipc	a0,0x1
     5ba:	f6a50513          	addi	a0,a0,-150 # 1520 <malloc+0x1ca>
     5be:	00001097          	auipc	ra,0x1
     5c2:	982080e7          	jalr	-1662(ra) # f40 <open>
     5c6:	00001097          	auipc	ra,0x1
     5ca:	962080e7          	jalr	-1694(ra) # f28 <close>
        exit(0);
     5ce:	4501                	li	a0,0
     5d0:	00001097          	auipc	ra,0x1
     5d4:	928080e7          	jalr	-1752(ra) # ef8 <exit>
        printf("grind: fork failed\n");
     5d8:	00001517          	auipc	a0,0x1
     5dc:	f6850513          	addi	a0,a0,-152 # 1540 <malloc+0x1ea>
     5e0:	00001097          	auipc	ra,0x1
     5e4:	cb8080e7          	jalr	-840(ra) # 1298 <printf>
        exit(1);
     5e8:	4505                	li	a0,1
     5ea:	00001097          	auipc	ra,0x1
     5ee:	90e080e7          	jalr	-1778(ra) # ef8 <exit>
        printf("grind: chdir failed\n");
     5f2:	00001517          	auipc	a0,0x1
     5f6:	f7650513          	addi	a0,a0,-138 # 1568 <malloc+0x212>
     5fa:	00001097          	auipc	ra,0x1
     5fe:	c9e080e7          	jalr	-866(ra) # 1298 <printf>
        exit(1);
     602:	4505                	li	a0,1
     604:	00001097          	auipc	ra,0x1
     608:	8f4080e7          	jalr	-1804(ra) # ef8 <exit>
      int pid = fork();
     60c:	00001097          	auipc	ra,0x1
     610:	8e4080e7          	jalr	-1820(ra) # ef0 <fork>
      if(pid == 0){
     614:	cd09                	beqz	a0,62e <go+0x5b6>
      } else if(pid < 0){
     616:	02054963          	bltz	a0,648 <go+0x5d0>
      wait(0, "");
     61a:	00001597          	auipc	a1,0x1
     61e:	fbe58593          	addi	a1,a1,-66 # 15d8 <malloc+0x282>
     622:	4501                	li	a0,0
     624:	00001097          	auipc	ra,0x1
     628:	8e4080e7          	jalr	-1820(ra) # f08 <wait>
     62c:	bcdd                	j	122 <go+0xaa>
        kill(getpid());
     62e:	00001097          	auipc	ra,0x1
     632:	952080e7          	jalr	-1710(ra) # f80 <getpid>
     636:	00001097          	auipc	ra,0x1
     63a:	8fa080e7          	jalr	-1798(ra) # f30 <kill>
        exit(0);
     63e:	4501                	li	a0,0
     640:	00001097          	auipc	ra,0x1
     644:	8b8080e7          	jalr	-1864(ra) # ef8 <exit>
        printf("grind: fork failed\n");
     648:	00001517          	auipc	a0,0x1
     64c:	ef850513          	addi	a0,a0,-264 # 1540 <malloc+0x1ea>
     650:	00001097          	auipc	ra,0x1
     654:	c48080e7          	jalr	-952(ra) # 1298 <printf>
        exit(1);
     658:	4505                	li	a0,1
     65a:	00001097          	auipc	ra,0x1
     65e:	89e080e7          	jalr	-1890(ra) # ef8 <exit>
      if(pipe(fds) < 0){
     662:	fa840513          	addi	a0,s0,-88
     666:	00001097          	auipc	ra,0x1
     66a:	8aa080e7          	jalr	-1878(ra) # f10 <pipe>
     66e:	02054f63          	bltz	a0,6ac <go+0x634>
      int pid = fork();
     672:	00001097          	auipc	ra,0x1
     676:	87e080e7          	jalr	-1922(ra) # ef0 <fork>
      if(pid == 0){
     67a:	c531                	beqz	a0,6c6 <go+0x64e>
      } else if(pid < 0){
     67c:	0a054e63          	bltz	a0,738 <go+0x6c0>
      close(fds[0]);
     680:	fa842503          	lw	a0,-88(s0)
     684:	00001097          	auipc	ra,0x1
     688:	8a4080e7          	jalr	-1884(ra) # f28 <close>
      close(fds[1]);
     68c:	fac42503          	lw	a0,-84(s0)
     690:	00001097          	auipc	ra,0x1
     694:	898080e7          	jalr	-1896(ra) # f28 <close>
      wait(0, "");
     698:	00001597          	auipc	a1,0x1
     69c:	f4058593          	addi	a1,a1,-192 # 15d8 <malloc+0x282>
     6a0:	4501                	li	a0,0
     6a2:	00001097          	auipc	ra,0x1
     6a6:	866080e7          	jalr	-1946(ra) # f08 <wait>
     6aa:	bca5                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     6ac:	00001517          	auipc	a0,0x1
     6b0:	ed450513          	addi	a0,a0,-300 # 1580 <malloc+0x22a>
     6b4:	00001097          	auipc	ra,0x1
     6b8:	be4080e7          	jalr	-1052(ra) # 1298 <printf>
        exit(1);
     6bc:	4505                	li	a0,1
     6be:	00001097          	auipc	ra,0x1
     6c2:	83a080e7          	jalr	-1990(ra) # ef8 <exit>
        fork();
     6c6:	00001097          	auipc	ra,0x1
     6ca:	82a080e7          	jalr	-2006(ra) # ef0 <fork>
        fork();
     6ce:	00001097          	auipc	ra,0x1
     6d2:	822080e7          	jalr	-2014(ra) # ef0 <fork>
        if(write(fds[1], "x", 1) != 1)
     6d6:	4605                	li	a2,1
     6d8:	00001597          	auipc	a1,0x1
     6dc:	ec058593          	addi	a1,a1,-320 # 1598 <malloc+0x242>
     6e0:	fac42503          	lw	a0,-84(s0)
     6e4:	00001097          	auipc	ra,0x1
     6e8:	83c080e7          	jalr	-1988(ra) # f20 <write>
     6ec:	4785                	li	a5,1
     6ee:	02f51363          	bne	a0,a5,714 <go+0x69c>
        if(read(fds[0], &c, 1) != 1)
     6f2:	4605                	li	a2,1
     6f4:	fa040593          	addi	a1,s0,-96
     6f8:	fa842503          	lw	a0,-88(s0)
     6fc:	00001097          	auipc	ra,0x1
     700:	81c080e7          	jalr	-2020(ra) # f18 <read>
     704:	4785                	li	a5,1
     706:	02f51063          	bne	a0,a5,726 <go+0x6ae>
        exit(0);
     70a:	4501                	li	a0,0
     70c:	00000097          	auipc	ra,0x0
     710:	7ec080e7          	jalr	2028(ra) # ef8 <exit>
          printf("grind: pipe write failed\n");
     714:	00001517          	auipc	a0,0x1
     718:	e8c50513          	addi	a0,a0,-372 # 15a0 <malloc+0x24a>
     71c:	00001097          	auipc	ra,0x1
     720:	b7c080e7          	jalr	-1156(ra) # 1298 <printf>
     724:	b7f9                	j	6f2 <go+0x67a>
          printf("grind: pipe read failed\n");
     726:	00001517          	auipc	a0,0x1
     72a:	e9a50513          	addi	a0,a0,-358 # 15c0 <malloc+0x26a>
     72e:	00001097          	auipc	ra,0x1
     732:	b6a080e7          	jalr	-1174(ra) # 1298 <printf>
     736:	bfd1                	j	70a <go+0x692>
        printf("grind: fork failed\n");
     738:	00001517          	auipc	a0,0x1
     73c:	e0850513          	addi	a0,a0,-504 # 1540 <malloc+0x1ea>
     740:	00001097          	auipc	ra,0x1
     744:	b58080e7          	jalr	-1192(ra) # 1298 <printf>
        exit(1);
     748:	4505                	li	a0,1
     74a:	00000097          	auipc	ra,0x0
     74e:	7ae080e7          	jalr	1966(ra) # ef8 <exit>
      int pid = fork();
     752:	00000097          	auipc	ra,0x0
     756:	79e080e7          	jalr	1950(ra) # ef0 <fork>
      if(pid == 0){
     75a:	cd09                	beqz	a0,774 <go+0x6fc>
      } else if(pid < 0){
     75c:	08054363          	bltz	a0,7e2 <go+0x76a>
      wait(0, "");
     760:	00001597          	auipc	a1,0x1
     764:	e7858593          	addi	a1,a1,-392 # 15d8 <malloc+0x282>
     768:	4501                	li	a0,0
     76a:	00000097          	auipc	ra,0x0
     76e:	79e080e7          	jalr	1950(ra) # f08 <wait>
     772:	ba45                	j	122 <go+0xaa>
        unlink("a");
     774:	00001517          	auipc	a0,0x1
     778:	dac50513          	addi	a0,a0,-596 # 1520 <malloc+0x1ca>
     77c:	00000097          	auipc	ra,0x0
     780:	7d4080e7          	jalr	2004(ra) # f50 <unlink>
        mkdir("a");
     784:	00001517          	auipc	a0,0x1
     788:	d9c50513          	addi	a0,a0,-612 # 1520 <malloc+0x1ca>
     78c:	00000097          	auipc	ra,0x0
     790:	7dc080e7          	jalr	2012(ra) # f68 <mkdir>
        chdir("a");
     794:	00001517          	auipc	a0,0x1
     798:	d8c50513          	addi	a0,a0,-628 # 1520 <malloc+0x1ca>
     79c:	00000097          	auipc	ra,0x0
     7a0:	7d4080e7          	jalr	2004(ra) # f70 <chdir>
        unlink("../a");
     7a4:	00001517          	auipc	a0,0x1
     7a8:	ce450513          	addi	a0,a0,-796 # 1488 <malloc+0x132>
     7ac:	00000097          	auipc	ra,0x0
     7b0:	7a4080e7          	jalr	1956(ra) # f50 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     7b4:	20200593          	li	a1,514
     7b8:	00001517          	auipc	a0,0x1
     7bc:	de050513          	addi	a0,a0,-544 # 1598 <malloc+0x242>
     7c0:	00000097          	auipc	ra,0x0
     7c4:	780080e7          	jalr	1920(ra) # f40 <open>
        unlink("x");
     7c8:	00001517          	auipc	a0,0x1
     7cc:	dd050513          	addi	a0,a0,-560 # 1598 <malloc+0x242>
     7d0:	00000097          	auipc	ra,0x0
     7d4:	780080e7          	jalr	1920(ra) # f50 <unlink>
        exit(0);
     7d8:	4501                	li	a0,0
     7da:	00000097          	auipc	ra,0x0
     7de:	71e080e7          	jalr	1822(ra) # ef8 <exit>
        printf("grind: fork failed\n");
     7e2:	00001517          	auipc	a0,0x1
     7e6:	d5e50513          	addi	a0,a0,-674 # 1540 <malloc+0x1ea>
     7ea:	00001097          	auipc	ra,0x1
     7ee:	aae080e7          	jalr	-1362(ra) # 1298 <printf>
        exit(1);
     7f2:	4505                	li	a0,1
     7f4:	00000097          	auipc	ra,0x0
     7f8:	704080e7          	jalr	1796(ra) # ef8 <exit>
      unlink("c");
     7fc:	00001517          	auipc	a0,0x1
     800:	de450513          	addi	a0,a0,-540 # 15e0 <malloc+0x28a>
     804:	00000097          	auipc	ra,0x0
     808:	74c080e7          	jalr	1868(ra) # f50 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     80c:	20200593          	li	a1,514
     810:	00001517          	auipc	a0,0x1
     814:	dd050513          	addi	a0,a0,-560 # 15e0 <malloc+0x28a>
     818:	00000097          	auipc	ra,0x0
     81c:	728080e7          	jalr	1832(ra) # f40 <open>
     820:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     822:	04054f63          	bltz	a0,880 <go+0x808>
      if(write(fd1, "x", 1) != 1){
     826:	4605                	li	a2,1
     828:	00001597          	auipc	a1,0x1
     82c:	d7058593          	addi	a1,a1,-656 # 1598 <malloc+0x242>
     830:	00000097          	auipc	ra,0x0
     834:	6f0080e7          	jalr	1776(ra) # f20 <write>
     838:	4785                	li	a5,1
     83a:	06f51063          	bne	a0,a5,89a <go+0x822>
      if(fstat(fd1, &st) != 0){
     83e:	fa840593          	addi	a1,s0,-88
     842:	855a                	mv	a0,s6
     844:	00000097          	auipc	ra,0x0
     848:	714080e7          	jalr	1812(ra) # f58 <fstat>
     84c:	e525                	bnez	a0,8b4 <go+0x83c>
      if(st.size != 1){
     84e:	fb843583          	ld	a1,-72(s0)
     852:	4785                	li	a5,1
     854:	06f59d63          	bne	a1,a5,8ce <go+0x856>
      if(st.ino > 200){
     858:	fac42583          	lw	a1,-84(s0)
     85c:	0c800793          	li	a5,200
     860:	08b7e563          	bltu	a5,a1,8ea <go+0x872>
      close(fd1);
     864:	855a                	mv	a0,s6
     866:	00000097          	auipc	ra,0x0
     86a:	6c2080e7          	jalr	1730(ra) # f28 <close>
      unlink("c");
     86e:	00001517          	auipc	a0,0x1
     872:	d7250513          	addi	a0,a0,-654 # 15e0 <malloc+0x28a>
     876:	00000097          	auipc	ra,0x0
     87a:	6da080e7          	jalr	1754(ra) # f50 <unlink>
     87e:	b055                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     880:	00001517          	auipc	a0,0x1
     884:	d6850513          	addi	a0,a0,-664 # 15e8 <malloc+0x292>
     888:	00001097          	auipc	ra,0x1
     88c:	a10080e7          	jalr	-1520(ra) # 1298 <printf>
        exit(1);
     890:	4505                	li	a0,1
     892:	00000097          	auipc	ra,0x0
     896:	666080e7          	jalr	1638(ra) # ef8 <exit>
        printf("grind: write c failed\n");
     89a:	00001517          	auipc	a0,0x1
     89e:	d6650513          	addi	a0,a0,-666 # 1600 <malloc+0x2aa>
     8a2:	00001097          	auipc	ra,0x1
     8a6:	9f6080e7          	jalr	-1546(ra) # 1298 <printf>
        exit(1);
     8aa:	4505                	li	a0,1
     8ac:	00000097          	auipc	ra,0x0
     8b0:	64c080e7          	jalr	1612(ra) # ef8 <exit>
        printf("grind: fstat failed\n");
     8b4:	00001517          	auipc	a0,0x1
     8b8:	d6450513          	addi	a0,a0,-668 # 1618 <malloc+0x2c2>
     8bc:	00001097          	auipc	ra,0x1
     8c0:	9dc080e7          	jalr	-1572(ra) # 1298 <printf>
        exit(1);
     8c4:	4505                	li	a0,1
     8c6:	00000097          	auipc	ra,0x0
     8ca:	632080e7          	jalr	1586(ra) # ef8 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     8ce:	2581                	sext.w	a1,a1
     8d0:	00001517          	auipc	a0,0x1
     8d4:	d6050513          	addi	a0,a0,-672 # 1630 <malloc+0x2da>
     8d8:	00001097          	auipc	ra,0x1
     8dc:	9c0080e7          	jalr	-1600(ra) # 1298 <printf>
        exit(1);
     8e0:	4505                	li	a0,1
     8e2:	00000097          	auipc	ra,0x0
     8e6:	616080e7          	jalr	1558(ra) # ef8 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     8ea:	00001517          	auipc	a0,0x1
     8ee:	d6e50513          	addi	a0,a0,-658 # 1658 <malloc+0x302>
     8f2:	00001097          	auipc	ra,0x1
     8f6:	9a6080e7          	jalr	-1626(ra) # 1298 <printf>
        exit(1);
     8fa:	4505                	li	a0,1
     8fc:	00000097          	auipc	ra,0x0
     900:	5fc080e7          	jalr	1532(ra) # ef8 <exit>
        fprintf(2, "grind: pipe failed\n");
     904:	00001597          	auipc	a1,0x1
     908:	c7c58593          	addi	a1,a1,-900 # 1580 <malloc+0x22a>
     90c:	4509                	li	a0,2
     90e:	00001097          	auipc	ra,0x1
     912:	95c080e7          	jalr	-1700(ra) # 126a <fprintf>
        exit(1);
     916:	4505                	li	a0,1
     918:	00000097          	auipc	ra,0x0
     91c:	5e0080e7          	jalr	1504(ra) # ef8 <exit>
        fprintf(2, "grind: pipe failed\n");
     920:	00001597          	auipc	a1,0x1
     924:	c6058593          	addi	a1,a1,-928 # 1580 <malloc+0x22a>
     928:	4509                	li	a0,2
     92a:	00001097          	auipc	ra,0x1
     92e:	940080e7          	jalr	-1728(ra) # 126a <fprintf>
        exit(1);
     932:	4505                	li	a0,1
     934:	00000097          	auipc	ra,0x0
     938:	5c4080e7          	jalr	1476(ra) # ef8 <exit>
        close(bb[0]);
     93c:	fa042503          	lw	a0,-96(s0)
     940:	00000097          	auipc	ra,0x0
     944:	5e8080e7          	jalr	1512(ra) # f28 <close>
        close(bb[1]);
     948:	fa442503          	lw	a0,-92(s0)
     94c:	00000097          	auipc	ra,0x0
     950:	5dc080e7          	jalr	1500(ra) # f28 <close>
        close(aa[0]);
     954:	f9842503          	lw	a0,-104(s0)
     958:	00000097          	auipc	ra,0x0
     95c:	5d0080e7          	jalr	1488(ra) # f28 <close>
        close(1);
     960:	4505                	li	a0,1
     962:	00000097          	auipc	ra,0x0
     966:	5c6080e7          	jalr	1478(ra) # f28 <close>
        if(dup(aa[1]) != 1){
     96a:	f9c42503          	lw	a0,-100(s0)
     96e:	00000097          	auipc	ra,0x0
     972:	60a080e7          	jalr	1546(ra) # f78 <dup>
     976:	4785                	li	a5,1
     978:	02f50063          	beq	a0,a5,998 <go+0x920>
          fprintf(2, "grind: dup failed\n");
     97c:	00001597          	auipc	a1,0x1
     980:	d0458593          	addi	a1,a1,-764 # 1680 <malloc+0x32a>
     984:	4509                	li	a0,2
     986:	00001097          	auipc	ra,0x1
     98a:	8e4080e7          	jalr	-1820(ra) # 126a <fprintf>
          exit(1);
     98e:	4505                	li	a0,1
     990:	00000097          	auipc	ra,0x0
     994:	568080e7          	jalr	1384(ra) # ef8 <exit>
        close(aa[1]);
     998:	f9c42503          	lw	a0,-100(s0)
     99c:	00000097          	auipc	ra,0x0
     9a0:	58c080e7          	jalr	1420(ra) # f28 <close>
        char *args[3] = { "echo", "hi", 0 };
     9a4:	00001797          	auipc	a5,0x1
     9a8:	cf478793          	addi	a5,a5,-780 # 1698 <malloc+0x342>
     9ac:	faf43423          	sd	a5,-88(s0)
     9b0:	00001797          	auipc	a5,0x1
     9b4:	cf078793          	addi	a5,a5,-784 # 16a0 <malloc+0x34a>
     9b8:	faf43823          	sd	a5,-80(s0)
     9bc:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     9c0:	fa840593          	addi	a1,s0,-88
     9c4:	00001517          	auipc	a0,0x1
     9c8:	ce450513          	addi	a0,a0,-796 # 16a8 <malloc+0x352>
     9cc:	00000097          	auipc	ra,0x0
     9d0:	56c080e7          	jalr	1388(ra) # f38 <exec>
        fprintf(2, "grind: echo: not found\n");
     9d4:	00001597          	auipc	a1,0x1
     9d8:	ce458593          	addi	a1,a1,-796 # 16b8 <malloc+0x362>
     9dc:	4509                	li	a0,2
     9de:	00001097          	auipc	ra,0x1
     9e2:	88c080e7          	jalr	-1908(ra) # 126a <fprintf>
        exit(2);
     9e6:	4509                	li	a0,2
     9e8:	00000097          	auipc	ra,0x0
     9ec:	510080e7          	jalr	1296(ra) # ef8 <exit>
        fprintf(2, "grind: fork failed\n");
     9f0:	00001597          	auipc	a1,0x1
     9f4:	b5058593          	addi	a1,a1,-1200 # 1540 <malloc+0x1ea>
     9f8:	4509                	li	a0,2
     9fa:	00001097          	auipc	ra,0x1
     9fe:	870080e7          	jalr	-1936(ra) # 126a <fprintf>
        exit(3);
     a02:	450d                	li	a0,3
     a04:	00000097          	auipc	ra,0x0
     a08:	4f4080e7          	jalr	1268(ra) # ef8 <exit>
        close(aa[1]);
     a0c:	f9c42503          	lw	a0,-100(s0)
     a10:	00000097          	auipc	ra,0x0
     a14:	518080e7          	jalr	1304(ra) # f28 <close>
        close(bb[0]);
     a18:	fa042503          	lw	a0,-96(s0)
     a1c:	00000097          	auipc	ra,0x0
     a20:	50c080e7          	jalr	1292(ra) # f28 <close>
        close(0);
     a24:	4501                	li	a0,0
     a26:	00000097          	auipc	ra,0x0
     a2a:	502080e7          	jalr	1282(ra) # f28 <close>
        if(dup(aa[0]) != 0){
     a2e:	f9842503          	lw	a0,-104(s0)
     a32:	00000097          	auipc	ra,0x0
     a36:	546080e7          	jalr	1350(ra) # f78 <dup>
     a3a:	cd19                	beqz	a0,a58 <go+0x9e0>
          fprintf(2, "grind: dup failed\n");
     a3c:	00001597          	auipc	a1,0x1
     a40:	c4458593          	addi	a1,a1,-956 # 1680 <malloc+0x32a>
     a44:	4509                	li	a0,2
     a46:	00001097          	auipc	ra,0x1
     a4a:	824080e7          	jalr	-2012(ra) # 126a <fprintf>
          exit(4);
     a4e:	4511                	li	a0,4
     a50:	00000097          	auipc	ra,0x0
     a54:	4a8080e7          	jalr	1192(ra) # ef8 <exit>
        close(aa[0]);
     a58:	f9842503          	lw	a0,-104(s0)
     a5c:	00000097          	auipc	ra,0x0
     a60:	4cc080e7          	jalr	1228(ra) # f28 <close>
        close(1);
     a64:	4505                	li	a0,1
     a66:	00000097          	auipc	ra,0x0
     a6a:	4c2080e7          	jalr	1218(ra) # f28 <close>
        if(dup(bb[1]) != 1){
     a6e:	fa442503          	lw	a0,-92(s0)
     a72:	00000097          	auipc	ra,0x0
     a76:	506080e7          	jalr	1286(ra) # f78 <dup>
     a7a:	4785                	li	a5,1
     a7c:	02f50063          	beq	a0,a5,a9c <go+0xa24>
          fprintf(2, "grind: dup failed\n");
     a80:	00001597          	auipc	a1,0x1
     a84:	c0058593          	addi	a1,a1,-1024 # 1680 <malloc+0x32a>
     a88:	4509                	li	a0,2
     a8a:	00000097          	auipc	ra,0x0
     a8e:	7e0080e7          	jalr	2016(ra) # 126a <fprintf>
          exit(5);
     a92:	4515                	li	a0,5
     a94:	00000097          	auipc	ra,0x0
     a98:	464080e7          	jalr	1124(ra) # ef8 <exit>
        close(bb[1]);
     a9c:	fa442503          	lw	a0,-92(s0)
     aa0:	00000097          	auipc	ra,0x0
     aa4:	488080e7          	jalr	1160(ra) # f28 <close>
        char *args[2] = { "cat", 0 };
     aa8:	00001797          	auipc	a5,0x1
     aac:	c2878793          	addi	a5,a5,-984 # 16d0 <malloc+0x37a>
     ab0:	faf43423          	sd	a5,-88(s0)
     ab4:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     ab8:	fa840593          	addi	a1,s0,-88
     abc:	00001517          	auipc	a0,0x1
     ac0:	c1c50513          	addi	a0,a0,-996 # 16d8 <malloc+0x382>
     ac4:	00000097          	auipc	ra,0x0
     ac8:	474080e7          	jalr	1140(ra) # f38 <exec>
        fprintf(2, "grind: cat: not found\n");
     acc:	00001597          	auipc	a1,0x1
     ad0:	c1458593          	addi	a1,a1,-1004 # 16e0 <malloc+0x38a>
     ad4:	4509                	li	a0,2
     ad6:	00000097          	auipc	ra,0x0
     ada:	794080e7          	jalr	1940(ra) # 126a <fprintf>
        exit(6);
     ade:	4519                	li	a0,6
     ae0:	00000097          	auipc	ra,0x0
     ae4:	418080e7          	jalr	1048(ra) # ef8 <exit>
        fprintf(2, "grind: fork failed\n");
     ae8:	00001597          	auipc	a1,0x1
     aec:	a5858593          	addi	a1,a1,-1448 # 1540 <malloc+0x1ea>
     af0:	4509                	li	a0,2
     af2:	00000097          	auipc	ra,0x0
     af6:	778080e7          	jalr	1912(ra) # 126a <fprintf>
        exit(7);
     afa:	451d                	li	a0,7
     afc:	00000097          	auipc	ra,0x0
     b00:	3fc080e7          	jalr	1020(ra) # ef8 <exit>

0000000000000b04 <iter>:
  }
}

void
iter()
{
     b04:	7179                	addi	sp,sp,-48
     b06:	f406                	sd	ra,40(sp)
     b08:	f022                	sd	s0,32(sp)
     b0a:	ec26                	sd	s1,24(sp)
     b0c:	e84a                	sd	s2,16(sp)
     b0e:	1800                	addi	s0,sp,48
  unlink("a");
     b10:	00001517          	auipc	a0,0x1
     b14:	a1050513          	addi	a0,a0,-1520 # 1520 <malloc+0x1ca>
     b18:	00000097          	auipc	ra,0x0
     b1c:	438080e7          	jalr	1080(ra) # f50 <unlink>
  unlink("b");
     b20:	00001517          	auipc	a0,0x1
     b24:	9b050513          	addi	a0,a0,-1616 # 14d0 <malloc+0x17a>
     b28:	00000097          	auipc	ra,0x0
     b2c:	428080e7          	jalr	1064(ra) # f50 <unlink>
  
  int pid1 = fork();
     b30:	00000097          	auipc	ra,0x0
     b34:	3c0080e7          	jalr	960(ra) # ef0 <fork>
  if(pid1 < 0){
     b38:	02054163          	bltz	a0,b5a <iter+0x56>
     b3c:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     b3e:	e91d                	bnez	a0,b74 <iter+0x70>
    rand_next ^= 31;
     b40:	00001717          	auipc	a4,0x1
     b44:	4c070713          	addi	a4,a4,1216 # 2000 <rand_next>
     b48:	631c                	ld	a5,0(a4)
     b4a:	01f7c793          	xori	a5,a5,31
     b4e:	e31c                	sd	a5,0(a4)
    go(0);
     b50:	4501                	li	a0,0
     b52:	fffff097          	auipc	ra,0xfffff
     b56:	526080e7          	jalr	1318(ra) # 78 <go>
    printf("grind: fork failed\n");
     b5a:	00001517          	auipc	a0,0x1
     b5e:	9e650513          	addi	a0,a0,-1562 # 1540 <malloc+0x1ea>
     b62:	00000097          	auipc	ra,0x0
     b66:	736080e7          	jalr	1846(ra) # 1298 <printf>
    exit(1);
     b6a:	4505                	li	a0,1
     b6c:	00000097          	auipc	ra,0x0
     b70:	38c080e7          	jalr	908(ra) # ef8 <exit>
    exit(0);
  }

  int pid2 = fork();
     b74:	00000097          	auipc	ra,0x0
     b78:	37c080e7          	jalr	892(ra) # ef0 <fork>
     b7c:	892a                	mv	s2,a0
  if(pid2 < 0){
     b7e:	02054263          	bltz	a0,ba2 <iter+0x9e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     b82:	ed0d                	bnez	a0,bbc <iter+0xb8>
    rand_next ^= 7177;
     b84:	00001697          	auipc	a3,0x1
     b88:	47c68693          	addi	a3,a3,1148 # 2000 <rand_next>
     b8c:	629c                	ld	a5,0(a3)
     b8e:	6709                	lui	a4,0x2
     b90:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x4d9>
     b94:	8fb9                	xor	a5,a5,a4
     b96:	e29c                	sd	a5,0(a3)
    go(1);
     b98:	4505                	li	a0,1
     b9a:	fffff097          	auipc	ra,0xfffff
     b9e:	4de080e7          	jalr	1246(ra) # 78 <go>
    printf("grind: fork failed\n");
     ba2:	00001517          	auipc	a0,0x1
     ba6:	99e50513          	addi	a0,a0,-1634 # 1540 <malloc+0x1ea>
     baa:	00000097          	auipc	ra,0x0
     bae:	6ee080e7          	jalr	1774(ra) # 1298 <printf>
    exit(1);
     bb2:	4505                	li	a0,1
     bb4:	00000097          	auipc	ra,0x0
     bb8:	344080e7          	jalr	836(ra) # ef8 <exit>
    exit(0);
  }

  int st1 = -1;
     bbc:	57fd                	li	a5,-1
     bbe:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1, "");
     bc2:	00001597          	auipc	a1,0x1
     bc6:	a1658593          	addi	a1,a1,-1514 # 15d8 <malloc+0x282>
     bca:	fdc40513          	addi	a0,s0,-36
     bce:	00000097          	auipc	ra,0x0
     bd2:	33a080e7          	jalr	826(ra) # f08 <wait>
  if(st1 != 0){
     bd6:	fdc42783          	lw	a5,-36(s0)
     bda:	e39d                	bnez	a5,c00 <iter+0xfc>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     bdc:	57fd                	li	a5,-1
     bde:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2,"");
     be2:	00001597          	auipc	a1,0x1
     be6:	9f658593          	addi	a1,a1,-1546 # 15d8 <malloc+0x282>
     bea:	fd840513          	addi	a0,s0,-40
     bee:	00000097          	auipc	ra,0x0
     bf2:	31a080e7          	jalr	794(ra) # f08 <wait>

  exit(0);
     bf6:	4501                	li	a0,0
     bf8:	00000097          	auipc	ra,0x0
     bfc:	300080e7          	jalr	768(ra) # ef8 <exit>
    kill(pid1);
     c00:	8526                	mv	a0,s1
     c02:	00000097          	auipc	ra,0x0
     c06:	32e080e7          	jalr	814(ra) # f30 <kill>
    kill(pid2);
     c0a:	854a                	mv	a0,s2
     c0c:	00000097          	auipc	ra,0x0
     c10:	324080e7          	jalr	804(ra) # f30 <kill>
     c14:	b7e1                	j	bdc <iter+0xd8>

0000000000000c16 <main>:
}

int
main()
{
     c16:	1101                	addi	sp,sp,-32
     c18:	ec06                	sd	ra,24(sp)
     c1a:	e822                	sd	s0,16(sp)
     c1c:	e426                	sd	s1,8(sp)
     c1e:	e04a                	sd	s2,0(sp)
     c20:	1000                	addi	s0,sp,32
    if(pid == 0){
      iter();
      exit(0);
    }
    if(pid > 0){
      wait(0,"");
     c22:	00001917          	auipc	s2,0x1
     c26:	9b690913          	addi	s2,s2,-1610 # 15d8 <malloc+0x282>
    }
    sleep(20);
    rand_next += 1;
     c2a:	00001497          	auipc	s1,0x1
     c2e:	3d648493          	addi	s1,s1,982 # 2000 <rand_next>
     c32:	a829                	j	c4c <main+0x36>
      iter();
     c34:	00000097          	auipc	ra,0x0
     c38:	ed0080e7          	jalr	-304(ra) # b04 <iter>
    sleep(20);
     c3c:	4551                	li	a0,20
     c3e:	00000097          	auipc	ra,0x0
     c42:	352080e7          	jalr	850(ra) # f90 <sleep>
    rand_next += 1;
     c46:	609c                	ld	a5,0(s1)
     c48:	0785                	addi	a5,a5,1
     c4a:	e09c                	sd	a5,0(s1)
    int pid = fork();
     c4c:	00000097          	auipc	ra,0x0
     c50:	2a4080e7          	jalr	676(ra) # ef0 <fork>
    if(pid == 0){
     c54:	d165                	beqz	a0,c34 <main+0x1e>
    if(pid > 0){
     c56:	fea053e3          	blez	a0,c3c <main+0x26>
      wait(0,"");
     c5a:	85ca                	mv	a1,s2
     c5c:	4501                	li	a0,0
     c5e:	00000097          	auipc	ra,0x0
     c62:	2aa080e7          	jalr	682(ra) # f08 <wait>
     c66:	bfd9                	j	c3c <main+0x26>

0000000000000c68 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
     c68:	1141                	addi	sp,sp,-16
     c6a:	e406                	sd	ra,8(sp)
     c6c:	e022                	sd	s0,0(sp)
     c6e:	0800                	addi	s0,sp,16
  extern int main();
  main();
     c70:	00000097          	auipc	ra,0x0
     c74:	fa6080e7          	jalr	-90(ra) # c16 <main>
  exit(0);
     c78:	4501                	li	a0,0
     c7a:	00000097          	auipc	ra,0x0
     c7e:	27e080e7          	jalr	638(ra) # ef8 <exit>

0000000000000c82 <strcpy>:
}

char* strcpy(char *s, const char *t)
{
     c82:	1141                	addi	sp,sp,-16
     c84:	e422                	sd	s0,8(sp)
     c86:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c88:	87aa                	mv	a5,a0
     c8a:	0585                	addi	a1,a1,1
     c8c:	0785                	addi	a5,a5,1
     c8e:	fff5c703          	lbu	a4,-1(a1)
     c92:	fee78fa3          	sb	a4,-1(a5)
     c96:	fb75                	bnez	a4,c8a <strcpy+0x8>
    ;
  return os;
}
     c98:	6422                	ld	s0,8(sp)
     c9a:	0141                	addi	sp,sp,16
     c9c:	8082                	ret

0000000000000c9e <strcmp>:

int strcmp(const char *p, const char *q)
{
     c9e:	1141                	addi	sp,sp,-16
     ca0:	e422                	sd	s0,8(sp)
     ca2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     ca4:	00054783          	lbu	a5,0(a0)
     ca8:	cb91                	beqz	a5,cbc <strcmp+0x1e>
     caa:	0005c703          	lbu	a4,0(a1)
     cae:	00f71763          	bne	a4,a5,cbc <strcmp+0x1e>
    p++, q++;
     cb2:	0505                	addi	a0,a0,1
     cb4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     cb6:	00054783          	lbu	a5,0(a0)
     cba:	fbe5                	bnez	a5,caa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     cbc:	0005c503          	lbu	a0,0(a1)
}
     cc0:	40a7853b          	subw	a0,a5,a0
     cc4:	6422                	ld	s0,8(sp)
     cc6:	0141                	addi	sp,sp,16
     cc8:	8082                	ret

0000000000000cca <strlen>:

uint strlen(const char *s)
{
     cca:	1141                	addi	sp,sp,-16
     ccc:	e422                	sd	s0,8(sp)
     cce:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     cd0:	00054783          	lbu	a5,0(a0)
     cd4:	cf91                	beqz	a5,cf0 <strlen+0x26>
     cd6:	0505                	addi	a0,a0,1
     cd8:	87aa                	mv	a5,a0
     cda:	4685                	li	a3,1
     cdc:	9e89                	subw	a3,a3,a0
     cde:	00f6853b          	addw	a0,a3,a5
     ce2:	0785                	addi	a5,a5,1
     ce4:	fff7c703          	lbu	a4,-1(a5)
     ce8:	fb7d                	bnez	a4,cde <strlen+0x14>
    ;
  return n;
}
     cea:	6422                	ld	s0,8(sp)
     cec:	0141                	addi	sp,sp,16
     cee:	8082                	ret
  for(n = 0; s[n]; n++)
     cf0:	4501                	li	a0,0
     cf2:	bfe5                	j	cea <strlen+0x20>

0000000000000cf4 <memset>:

void* memset(void *dst, int c, uint n)
{
     cf4:	1141                	addi	sp,sp,-16
     cf6:	e422                	sd	s0,8(sp)
     cf8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     cfa:	ce09                	beqz	a2,d14 <memset+0x20>
     cfc:	87aa                	mv	a5,a0
     cfe:	fff6071b          	addiw	a4,a2,-1
     d02:	1702                	slli	a4,a4,0x20
     d04:	9301                	srli	a4,a4,0x20
     d06:	0705                	addi	a4,a4,1
     d08:	972a                	add	a4,a4,a0
    cdst[i] = c;
     d0a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     d0e:	0785                	addi	a5,a5,1
     d10:	fee79de3          	bne	a5,a4,d0a <memset+0x16>
  }
  return dst;
}
     d14:	6422                	ld	s0,8(sp)
     d16:	0141                	addi	sp,sp,16
     d18:	8082                	ret

0000000000000d1a <strchr>:

char* strchr(const char *s, char c)
{
     d1a:	1141                	addi	sp,sp,-16
     d1c:	e422                	sd	s0,8(sp)
     d1e:	0800                	addi	s0,sp,16
  for(; *s; s++)
     d20:	00054783          	lbu	a5,0(a0)
     d24:	cb99                	beqz	a5,d3a <strchr+0x20>
    if(*s == c)
     d26:	00f58763          	beq	a1,a5,d34 <strchr+0x1a>
  for(; *s; s++)
     d2a:	0505                	addi	a0,a0,1
     d2c:	00054783          	lbu	a5,0(a0)
     d30:	fbfd                	bnez	a5,d26 <strchr+0xc>
      return (char*)s;
  return 0;
     d32:	4501                	li	a0,0
}
     d34:	6422                	ld	s0,8(sp)
     d36:	0141                	addi	sp,sp,16
     d38:	8082                	ret
  return 0;
     d3a:	4501                	li	a0,0
     d3c:	bfe5                	j	d34 <strchr+0x1a>

0000000000000d3e <gets>:

char* gets(char *buf, int max)
{
     d3e:	711d                	addi	sp,sp,-96
     d40:	ec86                	sd	ra,88(sp)
     d42:	e8a2                	sd	s0,80(sp)
     d44:	e4a6                	sd	s1,72(sp)
     d46:	e0ca                	sd	s2,64(sp)
     d48:	fc4e                	sd	s3,56(sp)
     d4a:	f852                	sd	s4,48(sp)
     d4c:	f456                	sd	s5,40(sp)
     d4e:	f05a                	sd	s6,32(sp)
     d50:	ec5e                	sd	s7,24(sp)
     d52:	1080                	addi	s0,sp,96
     d54:	8baa                	mv	s7,a0
     d56:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d58:	892a                	mv	s2,a0
     d5a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d5c:	4aa9                	li	s5,10
     d5e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d60:	89a6                	mv	s3,s1
     d62:	2485                	addiw	s1,s1,1
     d64:	0344d863          	bge	s1,s4,d94 <gets+0x56>
    cc = read(0, &c, 1);
     d68:	4605                	li	a2,1
     d6a:	faf40593          	addi	a1,s0,-81
     d6e:	4501                	li	a0,0
     d70:	00000097          	auipc	ra,0x0
     d74:	1a8080e7          	jalr	424(ra) # f18 <read>
    if(cc < 1)
     d78:	00a05e63          	blez	a0,d94 <gets+0x56>
    buf[i++] = c;
     d7c:	faf44783          	lbu	a5,-81(s0)
     d80:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d84:	01578763          	beq	a5,s5,d92 <gets+0x54>
     d88:	0905                	addi	s2,s2,1
     d8a:	fd679be3          	bne	a5,s6,d60 <gets+0x22>
  for(i=0; i+1 < max; ){
     d8e:	89a6                	mv	s3,s1
     d90:	a011                	j	d94 <gets+0x56>
     d92:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d94:	99de                	add	s3,s3,s7
     d96:	00098023          	sb	zero,0(s3)
  return buf;
}
     d9a:	855e                	mv	a0,s7
     d9c:	60e6                	ld	ra,88(sp)
     d9e:	6446                	ld	s0,80(sp)
     da0:	64a6                	ld	s1,72(sp)
     da2:	6906                	ld	s2,64(sp)
     da4:	79e2                	ld	s3,56(sp)
     da6:	7a42                	ld	s4,48(sp)
     da8:	7aa2                	ld	s5,40(sp)
     daa:	7b02                	ld	s6,32(sp)
     dac:	6be2                	ld	s7,24(sp)
     dae:	6125                	addi	sp,sp,96
     db0:	8082                	ret

0000000000000db2 <stat>:

int stat(const char *n, struct stat *st)
{
     db2:	1101                	addi	sp,sp,-32
     db4:	ec06                	sd	ra,24(sp)
     db6:	e822                	sd	s0,16(sp)
     db8:	e426                	sd	s1,8(sp)
     dba:	e04a                	sd	s2,0(sp)
     dbc:	1000                	addi	s0,sp,32
     dbe:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     dc0:	4581                	li	a1,0
     dc2:	00000097          	auipc	ra,0x0
     dc6:	17e080e7          	jalr	382(ra) # f40 <open>
  if(fd < 0)
     dca:	02054563          	bltz	a0,df4 <stat+0x42>
     dce:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     dd0:	85ca                	mv	a1,s2
     dd2:	00000097          	auipc	ra,0x0
     dd6:	186080e7          	jalr	390(ra) # f58 <fstat>
     dda:	892a                	mv	s2,a0
  close(fd);
     ddc:	8526                	mv	a0,s1
     dde:	00000097          	auipc	ra,0x0
     de2:	14a080e7          	jalr	330(ra) # f28 <close>
  return r;
}
     de6:	854a                	mv	a0,s2
     de8:	60e2                	ld	ra,24(sp)
     dea:	6442                	ld	s0,16(sp)
     dec:	64a2                	ld	s1,8(sp)
     dee:	6902                	ld	s2,0(sp)
     df0:	6105                	addi	sp,sp,32
     df2:	8082                	ret
    return -1;
     df4:	597d                	li	s2,-1
     df6:	bfc5                	j	de6 <stat+0x34>

0000000000000df8 <atoi>:

int atoi(const char *s)
{
     df8:	1141                	addi	sp,sp,-16
     dfa:	e422                	sd	s0,8(sp)
     dfc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     dfe:	00054603          	lbu	a2,0(a0)
     e02:	fd06079b          	addiw	a5,a2,-48
     e06:	0ff7f793          	andi	a5,a5,255
     e0a:	4725                	li	a4,9
     e0c:	02f76963          	bltu	a4,a5,e3e <atoi+0x46>
     e10:	86aa                	mv	a3,a0
  n = 0;
     e12:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     e14:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     e16:	0685                	addi	a3,a3,1
     e18:	0025179b          	slliw	a5,a0,0x2
     e1c:	9fa9                	addw	a5,a5,a0
     e1e:	0017979b          	slliw	a5,a5,0x1
     e22:	9fb1                	addw	a5,a5,a2
     e24:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     e28:	0006c603          	lbu	a2,0(a3)
     e2c:	fd06071b          	addiw	a4,a2,-48
     e30:	0ff77713          	andi	a4,a4,255
     e34:	fee5f1e3          	bgeu	a1,a4,e16 <atoi+0x1e>
  return n;
}
     e38:	6422                	ld	s0,8(sp)
     e3a:	0141                	addi	sp,sp,16
     e3c:	8082                	ret
  n = 0;
     e3e:	4501                	li	a0,0
     e40:	bfe5                	j	e38 <atoi+0x40>

0000000000000e42 <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
     e42:	1141                	addi	sp,sp,-16
     e44:	e422                	sd	s0,8(sp)
     e46:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     e48:	02b57663          	bgeu	a0,a1,e74 <memmove+0x32>
    while(n-- > 0)
     e4c:	02c05163          	blez	a2,e6e <memmove+0x2c>
     e50:	fff6079b          	addiw	a5,a2,-1
     e54:	1782                	slli	a5,a5,0x20
     e56:	9381                	srli	a5,a5,0x20
     e58:	0785                	addi	a5,a5,1
     e5a:	97aa                	add	a5,a5,a0
  dst = vdst;
     e5c:	872a                	mv	a4,a0
      *dst++ = *src++;
     e5e:	0585                	addi	a1,a1,1
     e60:	0705                	addi	a4,a4,1
     e62:	fff5c683          	lbu	a3,-1(a1)
     e66:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e6a:	fee79ae3          	bne	a5,a4,e5e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e6e:	6422                	ld	s0,8(sp)
     e70:	0141                	addi	sp,sp,16
     e72:	8082                	ret
    dst += n;
     e74:	00c50733          	add	a4,a0,a2
    src += n;
     e78:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e7a:	fec05ae3          	blez	a2,e6e <memmove+0x2c>
     e7e:	fff6079b          	addiw	a5,a2,-1
     e82:	1782                	slli	a5,a5,0x20
     e84:	9381                	srli	a5,a5,0x20
     e86:	fff7c793          	not	a5,a5
     e8a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e8c:	15fd                	addi	a1,a1,-1
     e8e:	177d                	addi	a4,a4,-1
     e90:	0005c683          	lbu	a3,0(a1)
     e94:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e98:	fee79ae3          	bne	a5,a4,e8c <memmove+0x4a>
     e9c:	bfc9                	j	e6e <memmove+0x2c>

0000000000000e9e <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
     e9e:	1141                	addi	sp,sp,-16
     ea0:	e422                	sd	s0,8(sp)
     ea2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     ea4:	ca05                	beqz	a2,ed4 <memcmp+0x36>
     ea6:	fff6069b          	addiw	a3,a2,-1
     eaa:	1682                	slli	a3,a3,0x20
     eac:	9281                	srli	a3,a3,0x20
     eae:	0685                	addi	a3,a3,1
     eb0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     eb2:	00054783          	lbu	a5,0(a0)
     eb6:	0005c703          	lbu	a4,0(a1)
     eba:	00e79863          	bne	a5,a4,eca <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     ebe:	0505                	addi	a0,a0,1
    p2++;
     ec0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     ec2:	fed518e3          	bne	a0,a3,eb2 <memcmp+0x14>
  }
  return 0;
     ec6:	4501                	li	a0,0
     ec8:	a019                	j	ece <memcmp+0x30>
      return *p1 - *p2;
     eca:	40e7853b          	subw	a0,a5,a4
}
     ece:	6422                	ld	s0,8(sp)
     ed0:	0141                	addi	sp,sp,16
     ed2:	8082                	ret
  return 0;
     ed4:	4501                	li	a0,0
     ed6:	bfe5                	j	ece <memcmp+0x30>

0000000000000ed8 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
     ed8:	1141                	addi	sp,sp,-16
     eda:	e406                	sd	ra,8(sp)
     edc:	e022                	sd	s0,0(sp)
     ede:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     ee0:	00000097          	auipc	ra,0x0
     ee4:	f62080e7          	jalr	-158(ra) # e42 <memmove>
}
     ee8:	60a2                	ld	ra,8(sp)
     eea:	6402                	ld	s0,0(sp)
     eec:	0141                	addi	sp,sp,16
     eee:	8082                	ret

0000000000000ef0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ef0:	4885                	li	a7,1
 ecall
     ef2:	00000073          	ecall
 ret
     ef6:	8082                	ret

0000000000000ef8 <exit>:
.global exit
exit:
 li a7, SYS_exit
     ef8:	4889                	li	a7,2
 ecall
     efa:	00000073          	ecall
 ret
     efe:	8082                	ret

0000000000000f00 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
     f00:	48e1                	li	a7,24
 ecall
     f02:	00000073          	ecall
 ret
     f06:	8082                	ret

0000000000000f08 <wait>:
.global wait
wait:
 li a7, SYS_wait
     f08:	488d                	li	a7,3
 ecall
     f0a:	00000073          	ecall
 ret
     f0e:	8082                	ret

0000000000000f10 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     f10:	4891                	li	a7,4
 ecall
     f12:	00000073          	ecall
 ret
     f16:	8082                	ret

0000000000000f18 <read>:
.global read
read:
 li a7, SYS_read
     f18:	4895                	li	a7,5
 ecall
     f1a:	00000073          	ecall
 ret
     f1e:	8082                	ret

0000000000000f20 <write>:
.global write
write:
 li a7, SYS_write
     f20:	48c1                	li	a7,16
 ecall
     f22:	00000073          	ecall
 ret
     f26:	8082                	ret

0000000000000f28 <close>:
.global close
close:
 li a7, SYS_close
     f28:	48d5                	li	a7,21
 ecall
     f2a:	00000073          	ecall
 ret
     f2e:	8082                	ret

0000000000000f30 <kill>:
.global kill
kill:
 li a7, SYS_kill
     f30:	4899                	li	a7,6
 ecall
     f32:	00000073          	ecall
 ret
     f36:	8082                	ret

0000000000000f38 <exec>:
.global exec
exec:
 li a7, SYS_exec
     f38:	489d                	li	a7,7
 ecall
     f3a:	00000073          	ecall
 ret
     f3e:	8082                	ret

0000000000000f40 <open>:
.global open
open:
 li a7, SYS_open
     f40:	48bd                	li	a7,15
 ecall
     f42:	00000073          	ecall
 ret
     f46:	8082                	ret

0000000000000f48 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     f48:	48c5                	li	a7,17
 ecall
     f4a:	00000073          	ecall
 ret
     f4e:	8082                	ret

0000000000000f50 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     f50:	48c9                	li	a7,18
 ecall
     f52:	00000073          	ecall
 ret
     f56:	8082                	ret

0000000000000f58 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f58:	48a1                	li	a7,8
 ecall
     f5a:	00000073          	ecall
 ret
     f5e:	8082                	ret

0000000000000f60 <link>:
.global link
link:
 li a7, SYS_link
     f60:	48cd                	li	a7,19
 ecall
     f62:	00000073          	ecall
 ret
     f66:	8082                	ret

0000000000000f68 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f68:	48d1                	li	a7,20
 ecall
     f6a:	00000073          	ecall
 ret
     f6e:	8082                	ret

0000000000000f70 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f70:	48a5                	li	a7,9
 ecall
     f72:	00000073          	ecall
 ret
     f76:	8082                	ret

0000000000000f78 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f78:	48a9                	li	a7,10
 ecall
     f7a:	00000073          	ecall
 ret
     f7e:	8082                	ret

0000000000000f80 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f80:	48ad                	li	a7,11
 ecall
     f82:	00000073          	ecall
 ret
     f86:	8082                	ret

0000000000000f88 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f88:	48b1                	li	a7,12
 ecall
     f8a:	00000073          	ecall
 ret
     f8e:	8082                	ret

0000000000000f90 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f90:	48b5                	li	a7,13
 ecall
     f92:	00000073          	ecall
 ret
     f96:	8082                	ret

0000000000000f98 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f98:	48b9                	li	a7,14
 ecall
     f9a:	00000073          	ecall
 ret
     f9e:	8082                	ret

0000000000000fa0 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
     fa0:	48dd                	li	a7,23
 ecall
     fa2:	00000073          	ecall
 ret
     fa6:	8082                	ret

0000000000000fa8 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
     fa8:	48e5                	li	a7,25
 ecall
     faa:	00000073          	ecall
 ret
     fae:	8082                	ret

0000000000000fb0 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
     fb0:	48e9                	li	a7,26
 ecall
     fb2:	00000073          	ecall
 ret
     fb6:	8082                	ret

0000000000000fb8 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
     fb8:	48ed                	li	a7,27
 ecall
     fba:	00000073          	ecall
 ret
     fbe:	8082                	ret

0000000000000fc0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     fc0:	1101                	addi	sp,sp,-32
     fc2:	ec06                	sd	ra,24(sp)
     fc4:	e822                	sd	s0,16(sp)
     fc6:	1000                	addi	s0,sp,32
     fc8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     fcc:	4605                	li	a2,1
     fce:	fef40593          	addi	a1,s0,-17
     fd2:	00000097          	auipc	ra,0x0
     fd6:	f4e080e7          	jalr	-178(ra) # f20 <write>
}
     fda:	60e2                	ld	ra,24(sp)
     fdc:	6442                	ld	s0,16(sp)
     fde:	6105                	addi	sp,sp,32
     fe0:	8082                	ret

0000000000000fe2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     fe2:	7139                	addi	sp,sp,-64
     fe4:	fc06                	sd	ra,56(sp)
     fe6:	f822                	sd	s0,48(sp)
     fe8:	f426                	sd	s1,40(sp)
     fea:	f04a                	sd	s2,32(sp)
     fec:	ec4e                	sd	s3,24(sp)
     fee:	0080                	addi	s0,sp,64
     ff0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     ff2:	c299                	beqz	a3,ff8 <printint+0x16>
     ff4:	0805c863          	bltz	a1,1084 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     ff8:	2581                	sext.w	a1,a1
  neg = 0;
     ffa:	4881                	li	a7,0
     ffc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    1000:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    1002:	2601                	sext.w	a2,a2
    1004:	00000517          	auipc	a0,0x0
    1008:	72c50513          	addi	a0,a0,1836 # 1730 <digits>
    100c:	883a                	mv	a6,a4
    100e:	2705                	addiw	a4,a4,1
    1010:	02c5f7bb          	remuw	a5,a1,a2
    1014:	1782                	slli	a5,a5,0x20
    1016:	9381                	srli	a5,a5,0x20
    1018:	97aa                	add	a5,a5,a0
    101a:	0007c783          	lbu	a5,0(a5)
    101e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    1022:	0005879b          	sext.w	a5,a1
    1026:	02c5d5bb          	divuw	a1,a1,a2
    102a:	0685                	addi	a3,a3,1
    102c:	fec7f0e3          	bgeu	a5,a2,100c <printint+0x2a>
  if(neg)
    1030:	00088b63          	beqz	a7,1046 <printint+0x64>
    buf[i++] = '-';
    1034:	fd040793          	addi	a5,s0,-48
    1038:	973e                	add	a4,a4,a5
    103a:	02d00793          	li	a5,45
    103e:	fef70823          	sb	a5,-16(a4)
    1042:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    1046:	02e05863          	blez	a4,1076 <printint+0x94>
    104a:	fc040793          	addi	a5,s0,-64
    104e:	00e78933          	add	s2,a5,a4
    1052:	fff78993          	addi	s3,a5,-1
    1056:	99ba                	add	s3,s3,a4
    1058:	377d                	addiw	a4,a4,-1
    105a:	1702                	slli	a4,a4,0x20
    105c:	9301                	srli	a4,a4,0x20
    105e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1062:	fff94583          	lbu	a1,-1(s2)
    1066:	8526                	mv	a0,s1
    1068:	00000097          	auipc	ra,0x0
    106c:	f58080e7          	jalr	-168(ra) # fc0 <putc>
  while(--i >= 0)
    1070:	197d                	addi	s2,s2,-1
    1072:	ff3918e3          	bne	s2,s3,1062 <printint+0x80>
}
    1076:	70e2                	ld	ra,56(sp)
    1078:	7442                	ld	s0,48(sp)
    107a:	74a2                	ld	s1,40(sp)
    107c:	7902                	ld	s2,32(sp)
    107e:	69e2                	ld	s3,24(sp)
    1080:	6121                	addi	sp,sp,64
    1082:	8082                	ret
    x = -xx;
    1084:	40b005bb          	negw	a1,a1
    neg = 1;
    1088:	4885                	li	a7,1
    x = -xx;
    108a:	bf8d                	j	ffc <printint+0x1a>

000000000000108c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    108c:	7119                	addi	sp,sp,-128
    108e:	fc86                	sd	ra,120(sp)
    1090:	f8a2                	sd	s0,112(sp)
    1092:	f4a6                	sd	s1,104(sp)
    1094:	f0ca                	sd	s2,96(sp)
    1096:	ecce                	sd	s3,88(sp)
    1098:	e8d2                	sd	s4,80(sp)
    109a:	e4d6                	sd	s5,72(sp)
    109c:	e0da                	sd	s6,64(sp)
    109e:	fc5e                	sd	s7,56(sp)
    10a0:	f862                	sd	s8,48(sp)
    10a2:	f466                	sd	s9,40(sp)
    10a4:	f06a                	sd	s10,32(sp)
    10a6:	ec6e                	sd	s11,24(sp)
    10a8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    10aa:	0005c903          	lbu	s2,0(a1)
    10ae:	18090f63          	beqz	s2,124c <vprintf+0x1c0>
    10b2:	8aaa                	mv	s5,a0
    10b4:	8b32                	mv	s6,a2
    10b6:	00158493          	addi	s1,a1,1
  state = 0;
    10ba:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    10bc:	02500a13          	li	s4,37
      if(c == 'd'){
    10c0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    10c4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    10c8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    10cc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10d0:	00000b97          	auipc	s7,0x0
    10d4:	660b8b93          	addi	s7,s7,1632 # 1730 <digits>
    10d8:	a839                	j	10f6 <vprintf+0x6a>
        putc(fd, c);
    10da:	85ca                	mv	a1,s2
    10dc:	8556                	mv	a0,s5
    10de:	00000097          	auipc	ra,0x0
    10e2:	ee2080e7          	jalr	-286(ra) # fc0 <putc>
    10e6:	a019                	j	10ec <vprintf+0x60>
    } else if(state == '%'){
    10e8:	01498f63          	beq	s3,s4,1106 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    10ec:	0485                	addi	s1,s1,1
    10ee:	fff4c903          	lbu	s2,-1(s1)
    10f2:	14090d63          	beqz	s2,124c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    10f6:	0009079b          	sext.w	a5,s2
    if(state == 0){
    10fa:	fe0997e3          	bnez	s3,10e8 <vprintf+0x5c>
      if(c == '%'){
    10fe:	fd479ee3          	bne	a5,s4,10da <vprintf+0x4e>
        state = '%';
    1102:	89be                	mv	s3,a5
    1104:	b7e5                	j	10ec <vprintf+0x60>
      if(c == 'd'){
    1106:	05878063          	beq	a5,s8,1146 <vprintf+0xba>
      } else if(c == 'l') {
    110a:	05978c63          	beq	a5,s9,1162 <vprintf+0xd6>
      } else if(c == 'x') {
    110e:	07a78863          	beq	a5,s10,117e <vprintf+0xf2>
      } else if(c == 'p') {
    1112:	09b78463          	beq	a5,s11,119a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1116:	07300713          	li	a4,115
    111a:	0ce78663          	beq	a5,a4,11e6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    111e:	06300713          	li	a4,99
    1122:	0ee78e63          	beq	a5,a4,121e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    1126:	11478863          	beq	a5,s4,1236 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    112a:	85d2                	mv	a1,s4
    112c:	8556                	mv	a0,s5
    112e:	00000097          	auipc	ra,0x0
    1132:	e92080e7          	jalr	-366(ra) # fc0 <putc>
        putc(fd, c);
    1136:	85ca                	mv	a1,s2
    1138:	8556                	mv	a0,s5
    113a:	00000097          	auipc	ra,0x0
    113e:	e86080e7          	jalr	-378(ra) # fc0 <putc>
      }
      state = 0;
    1142:	4981                	li	s3,0
    1144:	b765                	j	10ec <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    1146:	008b0913          	addi	s2,s6,8
    114a:	4685                	li	a3,1
    114c:	4629                	li	a2,10
    114e:	000b2583          	lw	a1,0(s6)
    1152:	8556                	mv	a0,s5
    1154:	00000097          	auipc	ra,0x0
    1158:	e8e080e7          	jalr	-370(ra) # fe2 <printint>
    115c:	8b4a                	mv	s6,s2
      state = 0;
    115e:	4981                	li	s3,0
    1160:	b771                	j	10ec <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1162:	008b0913          	addi	s2,s6,8
    1166:	4681                	li	a3,0
    1168:	4629                	li	a2,10
    116a:	000b2583          	lw	a1,0(s6)
    116e:	8556                	mv	a0,s5
    1170:	00000097          	auipc	ra,0x0
    1174:	e72080e7          	jalr	-398(ra) # fe2 <printint>
    1178:	8b4a                	mv	s6,s2
      state = 0;
    117a:	4981                	li	s3,0
    117c:	bf85                	j	10ec <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    117e:	008b0913          	addi	s2,s6,8
    1182:	4681                	li	a3,0
    1184:	4641                	li	a2,16
    1186:	000b2583          	lw	a1,0(s6)
    118a:	8556                	mv	a0,s5
    118c:	00000097          	auipc	ra,0x0
    1190:	e56080e7          	jalr	-426(ra) # fe2 <printint>
    1194:	8b4a                	mv	s6,s2
      state = 0;
    1196:	4981                	li	s3,0
    1198:	bf91                	j	10ec <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    119a:	008b0793          	addi	a5,s6,8
    119e:	f8f43423          	sd	a5,-120(s0)
    11a2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    11a6:	03000593          	li	a1,48
    11aa:	8556                	mv	a0,s5
    11ac:	00000097          	auipc	ra,0x0
    11b0:	e14080e7          	jalr	-492(ra) # fc0 <putc>
  putc(fd, 'x');
    11b4:	85ea                	mv	a1,s10
    11b6:	8556                	mv	a0,s5
    11b8:	00000097          	auipc	ra,0x0
    11bc:	e08080e7          	jalr	-504(ra) # fc0 <putc>
    11c0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    11c2:	03c9d793          	srli	a5,s3,0x3c
    11c6:	97de                	add	a5,a5,s7
    11c8:	0007c583          	lbu	a1,0(a5)
    11cc:	8556                	mv	a0,s5
    11ce:	00000097          	auipc	ra,0x0
    11d2:	df2080e7          	jalr	-526(ra) # fc0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    11d6:	0992                	slli	s3,s3,0x4
    11d8:	397d                	addiw	s2,s2,-1
    11da:	fe0914e3          	bnez	s2,11c2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    11de:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    11e2:	4981                	li	s3,0
    11e4:	b721                	j	10ec <vprintf+0x60>
        s = va_arg(ap, char*);
    11e6:	008b0993          	addi	s3,s6,8
    11ea:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    11ee:	02090163          	beqz	s2,1210 <vprintf+0x184>
        while(*s != 0){
    11f2:	00094583          	lbu	a1,0(s2)
    11f6:	c9a1                	beqz	a1,1246 <vprintf+0x1ba>
          putc(fd, *s);
    11f8:	8556                	mv	a0,s5
    11fa:	00000097          	auipc	ra,0x0
    11fe:	dc6080e7          	jalr	-570(ra) # fc0 <putc>
          s++;
    1202:	0905                	addi	s2,s2,1
        while(*s != 0){
    1204:	00094583          	lbu	a1,0(s2)
    1208:	f9e5                	bnez	a1,11f8 <vprintf+0x16c>
        s = va_arg(ap, char*);
    120a:	8b4e                	mv	s6,s3
      state = 0;
    120c:	4981                	li	s3,0
    120e:	bdf9                	j	10ec <vprintf+0x60>
          s = "(null)";
    1210:	00000917          	auipc	s2,0x0
    1214:	51890913          	addi	s2,s2,1304 # 1728 <malloc+0x3d2>
        while(*s != 0){
    1218:	02800593          	li	a1,40
    121c:	bff1                	j	11f8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    121e:	008b0913          	addi	s2,s6,8
    1222:	000b4583          	lbu	a1,0(s6)
    1226:	8556                	mv	a0,s5
    1228:	00000097          	auipc	ra,0x0
    122c:	d98080e7          	jalr	-616(ra) # fc0 <putc>
    1230:	8b4a                	mv	s6,s2
      state = 0;
    1232:	4981                	li	s3,0
    1234:	bd65                	j	10ec <vprintf+0x60>
        putc(fd, c);
    1236:	85d2                	mv	a1,s4
    1238:	8556                	mv	a0,s5
    123a:	00000097          	auipc	ra,0x0
    123e:	d86080e7          	jalr	-634(ra) # fc0 <putc>
      state = 0;
    1242:	4981                	li	s3,0
    1244:	b565                	j	10ec <vprintf+0x60>
        s = va_arg(ap, char*);
    1246:	8b4e                	mv	s6,s3
      state = 0;
    1248:	4981                	li	s3,0
    124a:	b54d                	j	10ec <vprintf+0x60>
    }
  }
}
    124c:	70e6                	ld	ra,120(sp)
    124e:	7446                	ld	s0,112(sp)
    1250:	74a6                	ld	s1,104(sp)
    1252:	7906                	ld	s2,96(sp)
    1254:	69e6                	ld	s3,88(sp)
    1256:	6a46                	ld	s4,80(sp)
    1258:	6aa6                	ld	s5,72(sp)
    125a:	6b06                	ld	s6,64(sp)
    125c:	7be2                	ld	s7,56(sp)
    125e:	7c42                	ld	s8,48(sp)
    1260:	7ca2                	ld	s9,40(sp)
    1262:	7d02                	ld	s10,32(sp)
    1264:	6de2                	ld	s11,24(sp)
    1266:	6109                	addi	sp,sp,128
    1268:	8082                	ret

000000000000126a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    126a:	715d                	addi	sp,sp,-80
    126c:	ec06                	sd	ra,24(sp)
    126e:	e822                	sd	s0,16(sp)
    1270:	1000                	addi	s0,sp,32
    1272:	e010                	sd	a2,0(s0)
    1274:	e414                	sd	a3,8(s0)
    1276:	e818                	sd	a4,16(s0)
    1278:	ec1c                	sd	a5,24(s0)
    127a:	03043023          	sd	a6,32(s0)
    127e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1282:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1286:	8622                	mv	a2,s0
    1288:	00000097          	auipc	ra,0x0
    128c:	e04080e7          	jalr	-508(ra) # 108c <vprintf>
}
    1290:	60e2                	ld	ra,24(sp)
    1292:	6442                	ld	s0,16(sp)
    1294:	6161                	addi	sp,sp,80
    1296:	8082                	ret

0000000000001298 <printf>:

void
printf(const char *fmt, ...)
{
    1298:	711d                	addi	sp,sp,-96
    129a:	ec06                	sd	ra,24(sp)
    129c:	e822                	sd	s0,16(sp)
    129e:	1000                	addi	s0,sp,32
    12a0:	e40c                	sd	a1,8(s0)
    12a2:	e810                	sd	a2,16(s0)
    12a4:	ec14                	sd	a3,24(s0)
    12a6:	f018                	sd	a4,32(s0)
    12a8:	f41c                	sd	a5,40(s0)
    12aa:	03043823          	sd	a6,48(s0)
    12ae:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    12b2:	00840613          	addi	a2,s0,8
    12b6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    12ba:	85aa                	mv	a1,a0
    12bc:	4505                	li	a0,1
    12be:	00000097          	auipc	ra,0x0
    12c2:	dce080e7          	jalr	-562(ra) # 108c <vprintf>
}
    12c6:	60e2                	ld	ra,24(sp)
    12c8:	6442                	ld	s0,16(sp)
    12ca:	6125                	addi	sp,sp,96
    12cc:	8082                	ret

00000000000012ce <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12ce:	1141                	addi	sp,sp,-16
    12d0:	e422                	sd	s0,8(sp)
    12d2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12d4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12d8:	00001797          	auipc	a5,0x1
    12dc:	d387b783          	ld	a5,-712(a5) # 2010 <freep>
    12e0:	a805                	j	1310 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    12e2:	4618                	lw	a4,8(a2)
    12e4:	9db9                	addw	a1,a1,a4
    12e6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    12ea:	6398                	ld	a4,0(a5)
    12ec:	6318                	ld	a4,0(a4)
    12ee:	fee53823          	sd	a4,-16(a0)
    12f2:	a091                	j	1336 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    12f4:	ff852703          	lw	a4,-8(a0)
    12f8:	9e39                	addw	a2,a2,a4
    12fa:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    12fc:	ff053703          	ld	a4,-16(a0)
    1300:	e398                	sd	a4,0(a5)
    1302:	a099                	j	1348 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1304:	6398                	ld	a4,0(a5)
    1306:	00e7e463          	bltu	a5,a4,130e <free+0x40>
    130a:	00e6ea63          	bltu	a3,a4,131e <free+0x50>
{
    130e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1310:	fed7fae3          	bgeu	a5,a3,1304 <free+0x36>
    1314:	6398                	ld	a4,0(a5)
    1316:	00e6e463          	bltu	a3,a4,131e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    131a:	fee7eae3          	bltu	a5,a4,130e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    131e:	ff852583          	lw	a1,-8(a0)
    1322:	6390                	ld	a2,0(a5)
    1324:	02059713          	slli	a4,a1,0x20
    1328:	9301                	srli	a4,a4,0x20
    132a:	0712                	slli	a4,a4,0x4
    132c:	9736                	add	a4,a4,a3
    132e:	fae60ae3          	beq	a2,a4,12e2 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1332:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1336:	4790                	lw	a2,8(a5)
    1338:	02061713          	slli	a4,a2,0x20
    133c:	9301                	srli	a4,a4,0x20
    133e:	0712                	slli	a4,a4,0x4
    1340:	973e                	add	a4,a4,a5
    1342:	fae689e3          	beq	a3,a4,12f4 <free+0x26>
  } else
    p->s.ptr = bp;
    1346:	e394                	sd	a3,0(a5)
  freep = p;
    1348:	00001717          	auipc	a4,0x1
    134c:	ccf73423          	sd	a5,-824(a4) # 2010 <freep>
}
    1350:	6422                	ld	s0,8(sp)
    1352:	0141                	addi	sp,sp,16
    1354:	8082                	ret

0000000000001356 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1356:	7139                	addi	sp,sp,-64
    1358:	fc06                	sd	ra,56(sp)
    135a:	f822                	sd	s0,48(sp)
    135c:	f426                	sd	s1,40(sp)
    135e:	f04a                	sd	s2,32(sp)
    1360:	ec4e                	sd	s3,24(sp)
    1362:	e852                	sd	s4,16(sp)
    1364:	e456                	sd	s5,8(sp)
    1366:	e05a                	sd	s6,0(sp)
    1368:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    136a:	02051493          	slli	s1,a0,0x20
    136e:	9081                	srli	s1,s1,0x20
    1370:	04bd                	addi	s1,s1,15
    1372:	8091                	srli	s1,s1,0x4
    1374:	0014899b          	addiw	s3,s1,1
    1378:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    137a:	00001517          	auipc	a0,0x1
    137e:	c9653503          	ld	a0,-874(a0) # 2010 <freep>
    1382:	c515                	beqz	a0,13ae <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1384:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1386:	4798                	lw	a4,8(a5)
    1388:	02977f63          	bgeu	a4,s1,13c6 <malloc+0x70>
    138c:	8a4e                	mv	s4,s3
    138e:	0009871b          	sext.w	a4,s3
    1392:	6685                	lui	a3,0x1
    1394:	00d77363          	bgeu	a4,a3,139a <malloc+0x44>
    1398:	6a05                	lui	s4,0x1
    139a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    139e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    13a2:	00001917          	auipc	s2,0x1
    13a6:	c6e90913          	addi	s2,s2,-914 # 2010 <freep>
  if(p == (char*)-1)
    13aa:	5afd                	li	s5,-1
    13ac:	a88d                	j	141e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    13ae:	00001797          	auipc	a5,0x1
    13b2:	05a78793          	addi	a5,a5,90 # 2408 <base>
    13b6:	00001717          	auipc	a4,0x1
    13ba:	c4f73d23          	sd	a5,-934(a4) # 2010 <freep>
    13be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    13c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    13c4:	b7e1                	j	138c <malloc+0x36>
      if(p->s.size == nunits)
    13c6:	02e48b63          	beq	s1,a4,13fc <malloc+0xa6>
        p->s.size -= nunits;
    13ca:	4137073b          	subw	a4,a4,s3
    13ce:	c798                	sw	a4,8(a5)
        p += p->s.size;
    13d0:	1702                	slli	a4,a4,0x20
    13d2:	9301                	srli	a4,a4,0x20
    13d4:	0712                	slli	a4,a4,0x4
    13d6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    13d8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    13dc:	00001717          	auipc	a4,0x1
    13e0:	c2a73a23          	sd	a0,-972(a4) # 2010 <freep>
      return (void*)(p + 1);
    13e4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    13e8:	70e2                	ld	ra,56(sp)
    13ea:	7442                	ld	s0,48(sp)
    13ec:	74a2                	ld	s1,40(sp)
    13ee:	7902                	ld	s2,32(sp)
    13f0:	69e2                	ld	s3,24(sp)
    13f2:	6a42                	ld	s4,16(sp)
    13f4:	6aa2                	ld	s5,8(sp)
    13f6:	6b02                	ld	s6,0(sp)
    13f8:	6121                	addi	sp,sp,64
    13fa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    13fc:	6398                	ld	a4,0(a5)
    13fe:	e118                	sd	a4,0(a0)
    1400:	bff1                	j	13dc <malloc+0x86>
  hp->s.size = nu;
    1402:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1406:	0541                	addi	a0,a0,16
    1408:	00000097          	auipc	ra,0x0
    140c:	ec6080e7          	jalr	-314(ra) # 12ce <free>
  return freep;
    1410:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1414:	d971                	beqz	a0,13e8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1416:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1418:	4798                	lw	a4,8(a5)
    141a:	fa9776e3          	bgeu	a4,s1,13c6 <malloc+0x70>
    if(p == freep)
    141e:	00093703          	ld	a4,0(s2)
    1422:	853e                	mv	a0,a5
    1424:	fef719e3          	bne	a4,a5,1416 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    1428:	8552                	mv	a0,s4
    142a:	00000097          	auipc	ra,0x0
    142e:	b5e080e7          	jalr	-1186(ra) # f88 <sbrk>
  if(p == (char*)-1)
    1432:	fd5518e3          	bne	a0,s5,1402 <malloc+0xac>
        return 0;
    1436:	4501                	li	a0,0
    1438:	bf45                	j	13e8 <malloc+0x92>
