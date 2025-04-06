
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	35e58593          	addi	a1,a1,862 # 1370 <malloc+0xea>
      1a:	4509                	li	a0,2
      1c:	00001097          	auipc	ra,0x1
      20:	e34080e7          	jalr	-460(ra) # e50 <write>
  memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	bfa080e7          	jalr	-1030(ra) # c24 <memset>
  gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	c38080e7          	jalr	-968(ra) # c6e <gets>
  if(buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      46:	40a00533          	neg	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
  


void
panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	31858593          	addi	a1,a1,792 # 1378 <malloc+0xf2>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	130080e7          	jalr	304(ra) # 119a <fprintf>
  exit(1);
      72:	4505                	li	a0,1
      74:	00001097          	auipc	ra,0x1
      78:	db4080e7          	jalr	-588(ra) # e28 <exit>

000000000000007c <fork1>:
}

int
fork1(void)
{
      7c:	1141                	addi	sp,sp,-16
      7e:	e406                	sd	ra,8(sp)
      80:	e022                	sd	s0,0(sp)
      82:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      84:	00001097          	auipc	ra,0x1
      88:	d9c080e7          	jalr	-612(ra) # e20 <fork>
  if(pid == -1)
      8c:	57fd                	li	a5,-1
      8e:	00f50663          	beq	a0,a5,9a <fork1+0x1e>
    panic("fork");
  return pid;
}
      92:	60a2                	ld	ra,8(sp)
      94:	6402                	ld	s0,0(sp)
      96:	0141                	addi	sp,sp,16
      98:	8082                	ret
    panic("fork");
      9a:	00001517          	auipc	a0,0x1
      9e:	2e650513          	addi	a0,a0,742 # 1380 <malloc+0xfa>
      a2:	00000097          	auipc	ra,0x0
      a6:	fb4080e7          	jalr	-76(ra) # 56 <panic>

00000000000000aa <runcmd>:
{
      aa:	7179                	addi	sp,sp,-48
      ac:	f406                	sd	ra,40(sp)
      ae:	f022                	sd	s0,32(sp)
      b0:	ec26                	sd	s1,24(sp)
      b2:	1800                	addi	s0,sp,48
  if(cmd == 0)
      b4:	c10d                	beqz	a0,d6 <runcmd+0x2c>
      b6:	84aa                	mv	s1,a0
  switch(cmd->type){
      b8:	4118                	lw	a4,0(a0)
      ba:	4795                	li	a5,5
      bc:	02e7e263          	bltu	a5,a4,e0 <runcmd+0x36>
      c0:	00056783          	lwu	a5,0(a0)
      c4:	078a                	slli	a5,a5,0x2
      c6:	00001717          	auipc	a4,0x1
      ca:	3ce70713          	addi	a4,a4,974 # 1494 <malloc+0x20e>
      ce:	97ba                	add	a5,a5,a4
      d0:	439c                	lw	a5,0(a5)
      d2:	97ba                	add	a5,a5,a4
      d4:	8782                	jr	a5
    exit(1);
      d6:	4505                	li	a0,1
      d8:	00001097          	auipc	ra,0x1
      dc:	d50080e7          	jalr	-688(ra) # e28 <exit>
    panic("runcmd");
      e0:	00001517          	auipc	a0,0x1
      e4:	2a850513          	addi	a0,a0,680 # 1388 <malloc+0x102>
      e8:	00000097          	auipc	ra,0x0
      ec:	f6e080e7          	jalr	-146(ra) # 56 <panic>
    if(ecmd->argv[0] == 0)
      f0:	6508                	ld	a0,8(a0)
      f2:	c515                	beqz	a0,11e <runcmd+0x74>
    exec(ecmd->argv[0], ecmd->argv);
      f4:	00848593          	addi	a1,s1,8
      f8:	00001097          	auipc	ra,0x1
      fc:	d70080e7          	jalr	-656(ra) # e68 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     100:	6490                	ld	a2,8(s1)
     102:	00001597          	auipc	a1,0x1
     106:	28e58593          	addi	a1,a1,654 # 1390 <malloc+0x10a>
     10a:	4509                	li	a0,2
     10c:	00001097          	auipc	ra,0x1
     110:	08e080e7          	jalr	142(ra) # 119a <fprintf>
  exit(0);
     114:	4501                	li	a0,0
     116:	00001097          	auipc	ra,0x1
     11a:	d12080e7          	jalr	-750(ra) # e28 <exit>
      exit(1);
     11e:	4505                	li	a0,1
     120:	00001097          	auipc	ra,0x1
     124:	d08080e7          	jalr	-760(ra) # e28 <exit>
    close(rcmd->fd);
     128:	5148                	lw	a0,36(a0)
     12a:	00001097          	auipc	ra,0x1
     12e:	d2e080e7          	jalr	-722(ra) # e58 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     132:	508c                	lw	a1,32(s1)
     134:	6888                	ld	a0,16(s1)
     136:	00001097          	auipc	ra,0x1
     13a:	d3a080e7          	jalr	-710(ra) # e70 <open>
     13e:	00054763          	bltz	a0,14c <runcmd+0xa2>
    runcmd(rcmd->cmd);
     142:	6488                	ld	a0,8(s1)
     144:	00000097          	auipc	ra,0x0
     148:	f66080e7          	jalr	-154(ra) # aa <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     14c:	6890                	ld	a2,16(s1)
     14e:	00001597          	auipc	a1,0x1
     152:	25258593          	addi	a1,a1,594 # 13a0 <malloc+0x11a>
     156:	4509                	li	a0,2
     158:	00001097          	auipc	ra,0x1
     15c:	042080e7          	jalr	66(ra) # 119a <fprintf>
      exit(1);
     160:	4505                	li	a0,1
     162:	00001097          	auipc	ra,0x1
     166:	cc6080e7          	jalr	-826(ra) # e28 <exit>
    if(fork1() == 0)
     16a:	00000097          	auipc	ra,0x0
     16e:	f12080e7          	jalr	-238(ra) # 7c <fork1>
     172:	e511                	bnez	a0,17e <runcmd+0xd4>
      runcmd(lcmd->left);
     174:	6488                	ld	a0,8(s1)
     176:	00000097          	auipc	ra,0x0
     17a:	f34080e7          	jalr	-204(ra) # aa <runcmd>
    wait(0, "");
     17e:	00001597          	auipc	a1,0x1
     182:	23258593          	addi	a1,a1,562 # 13b0 <malloc+0x12a>
     186:	4501                	li	a0,0
     188:	00001097          	auipc	ra,0x1
     18c:	cb0080e7          	jalr	-848(ra) # e38 <wait>
    runcmd(lcmd->right);
     190:	6888                	ld	a0,16(s1)
     192:	00000097          	auipc	ra,0x0
     196:	f18080e7          	jalr	-232(ra) # aa <runcmd>
    if(pipe(p) < 0)
     19a:	fd840513          	addi	a0,s0,-40
     19e:	00001097          	auipc	ra,0x1
     1a2:	ca2080e7          	jalr	-862(ra) # e40 <pipe>
     1a6:	04054363          	bltz	a0,1ec <runcmd+0x142>
    if(fork1() == 0){
     1aa:	00000097          	auipc	ra,0x0
     1ae:	ed2080e7          	jalr	-302(ra) # 7c <fork1>
     1b2:	e529                	bnez	a0,1fc <runcmd+0x152>
      close(1);
     1b4:	4505                	li	a0,1
     1b6:	00001097          	auipc	ra,0x1
     1ba:	ca2080e7          	jalr	-862(ra) # e58 <close>
      dup(p[1]);
     1be:	fdc42503          	lw	a0,-36(s0)
     1c2:	00001097          	auipc	ra,0x1
     1c6:	ce6080e7          	jalr	-794(ra) # ea8 <dup>
      close(p[0]);
     1ca:	fd842503          	lw	a0,-40(s0)
     1ce:	00001097          	auipc	ra,0x1
     1d2:	c8a080e7          	jalr	-886(ra) # e58 <close>
      close(p[1]);
     1d6:	fdc42503          	lw	a0,-36(s0)
     1da:	00001097          	auipc	ra,0x1
     1de:	c7e080e7          	jalr	-898(ra) # e58 <close>
      runcmd(pcmd->left);
     1e2:	6488                	ld	a0,8(s1)
     1e4:	00000097          	auipc	ra,0x0
     1e8:	ec6080e7          	jalr	-314(ra) # aa <runcmd>
      panic("pipe");
     1ec:	00001517          	auipc	a0,0x1
     1f0:	1cc50513          	addi	a0,a0,460 # 13b8 <malloc+0x132>
     1f4:	00000097          	auipc	ra,0x0
     1f8:	e62080e7          	jalr	-414(ra) # 56 <panic>
    if(fork1() == 0){
     1fc:	00000097          	auipc	ra,0x0
     200:	e80080e7          	jalr	-384(ra) # 7c <fork1>
     204:	ed05                	bnez	a0,23c <runcmd+0x192>
      close(0);
     206:	00001097          	auipc	ra,0x1
     20a:	c52080e7          	jalr	-942(ra) # e58 <close>
      dup(p[0]);
     20e:	fd842503          	lw	a0,-40(s0)
     212:	00001097          	auipc	ra,0x1
     216:	c96080e7          	jalr	-874(ra) # ea8 <dup>
      close(p[0]);
     21a:	fd842503          	lw	a0,-40(s0)
     21e:	00001097          	auipc	ra,0x1
     222:	c3a080e7          	jalr	-966(ra) # e58 <close>
      close(p[1]);
     226:	fdc42503          	lw	a0,-36(s0)
     22a:	00001097          	auipc	ra,0x1
     22e:	c2e080e7          	jalr	-978(ra) # e58 <close>
      runcmd(pcmd->right);
     232:	6888                	ld	a0,16(s1)
     234:	00000097          	auipc	ra,0x0
     238:	e76080e7          	jalr	-394(ra) # aa <runcmd>
    close(p[0]);
     23c:	fd842503          	lw	a0,-40(s0)
     240:	00001097          	auipc	ra,0x1
     244:	c18080e7          	jalr	-1000(ra) # e58 <close>
    close(p[1]);
     248:	fdc42503          	lw	a0,-36(s0)
     24c:	00001097          	auipc	ra,0x1
     250:	c0c080e7          	jalr	-1012(ra) # e58 <close>
    wait(0, "");
     254:	00001597          	auipc	a1,0x1
     258:	15c58593          	addi	a1,a1,348 # 13b0 <malloc+0x12a>
     25c:	4501                	li	a0,0
     25e:	00001097          	auipc	ra,0x1
     262:	bda080e7          	jalr	-1062(ra) # e38 <wait>
    wait(0, "");
     266:	00001597          	auipc	a1,0x1
     26a:	14a58593          	addi	a1,a1,330 # 13b0 <malloc+0x12a>
     26e:	4501                	li	a0,0
     270:	00001097          	auipc	ra,0x1
     274:	bc8080e7          	jalr	-1080(ra) # e38 <wait>
    break;
     278:	bd71                	j	114 <runcmd+0x6a>
    if(fork1() == 0)
     27a:	00000097          	auipc	ra,0x0
     27e:	e02080e7          	jalr	-510(ra) # 7c <fork1>
     282:	e80519e3          	bnez	a0,114 <runcmd+0x6a>
      runcmd(bcmd->cmd);
     286:	6488                	ld	a0,8(s1)
     288:	00000097          	auipc	ra,0x0
     28c:	e22080e7          	jalr	-478(ra) # aa <runcmd>

0000000000000290 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     290:	1101                	addi	sp,sp,-32
     292:	ec06                	sd	ra,24(sp)
     294:	e822                	sd	s0,16(sp)
     296:	e426                	sd	s1,8(sp)
     298:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     29a:	0a800513          	li	a0,168
     29e:	00001097          	auipc	ra,0x1
     2a2:	fe8080e7          	jalr	-24(ra) # 1286 <malloc>
     2a6:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2a8:	0a800613          	li	a2,168
     2ac:	4581                	li	a1,0
     2ae:	00001097          	auipc	ra,0x1
     2b2:	976080e7          	jalr	-1674(ra) # c24 <memset>
  cmd->type = EXEC;
     2b6:	4785                	li	a5,1
     2b8:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     2ba:	8526                	mv	a0,s1
     2bc:	60e2                	ld	ra,24(sp)
     2be:	6442                	ld	s0,16(sp)
     2c0:	64a2                	ld	s1,8(sp)
     2c2:	6105                	addi	sp,sp,32
     2c4:	8082                	ret

00000000000002c6 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2c6:	7139                	addi	sp,sp,-64
     2c8:	fc06                	sd	ra,56(sp)
     2ca:	f822                	sd	s0,48(sp)
     2cc:	f426                	sd	s1,40(sp)
     2ce:	f04a                	sd	s2,32(sp)
     2d0:	ec4e                	sd	s3,24(sp)
     2d2:	e852                	sd	s4,16(sp)
     2d4:	e456                	sd	s5,8(sp)
     2d6:	e05a                	sd	s6,0(sp)
     2d8:	0080                	addi	s0,sp,64
     2da:	8b2a                	mv	s6,a0
     2dc:	8aae                	mv	s5,a1
     2de:	8a32                	mv	s4,a2
     2e0:	89b6                	mv	s3,a3
     2e2:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2e4:	02800513          	li	a0,40
     2e8:	00001097          	auipc	ra,0x1
     2ec:	f9e080e7          	jalr	-98(ra) # 1286 <malloc>
     2f0:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2f2:	02800613          	li	a2,40
     2f6:	4581                	li	a1,0
     2f8:	00001097          	auipc	ra,0x1
     2fc:	92c080e7          	jalr	-1748(ra) # c24 <memset>
  cmd->type = REDIR;
     300:	4789                	li	a5,2
     302:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     304:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     308:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     30c:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     310:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     314:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     318:	8526                	mv	a0,s1
     31a:	70e2                	ld	ra,56(sp)
     31c:	7442                	ld	s0,48(sp)
     31e:	74a2                	ld	s1,40(sp)
     320:	7902                	ld	s2,32(sp)
     322:	69e2                	ld	s3,24(sp)
     324:	6a42                	ld	s4,16(sp)
     326:	6aa2                	ld	s5,8(sp)
     328:	6b02                	ld	s6,0(sp)
     32a:	6121                	addi	sp,sp,64
     32c:	8082                	ret

000000000000032e <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     32e:	7179                	addi	sp,sp,-48
     330:	f406                	sd	ra,40(sp)
     332:	f022                	sd	s0,32(sp)
     334:	ec26                	sd	s1,24(sp)
     336:	e84a                	sd	s2,16(sp)
     338:	e44e                	sd	s3,8(sp)
     33a:	1800                	addi	s0,sp,48
     33c:	89aa                	mv	s3,a0
     33e:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     340:	4561                	li	a0,24
     342:	00001097          	auipc	ra,0x1
     346:	f44080e7          	jalr	-188(ra) # 1286 <malloc>
     34a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     34c:	4661                	li	a2,24
     34e:	4581                	li	a1,0
     350:	00001097          	auipc	ra,0x1
     354:	8d4080e7          	jalr	-1836(ra) # c24 <memset>
  cmd->type = PIPE;
     358:	478d                	li	a5,3
     35a:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     35c:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     360:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     364:	8526                	mv	a0,s1
     366:	70a2                	ld	ra,40(sp)
     368:	7402                	ld	s0,32(sp)
     36a:	64e2                	ld	s1,24(sp)
     36c:	6942                	ld	s2,16(sp)
     36e:	69a2                	ld	s3,8(sp)
     370:	6145                	addi	sp,sp,48
     372:	8082                	ret

0000000000000374 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     374:	7179                	addi	sp,sp,-48
     376:	f406                	sd	ra,40(sp)
     378:	f022                	sd	s0,32(sp)
     37a:	ec26                	sd	s1,24(sp)
     37c:	e84a                	sd	s2,16(sp)
     37e:	e44e                	sd	s3,8(sp)
     380:	1800                	addi	s0,sp,48
     382:	89aa                	mv	s3,a0
     384:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     386:	4561                	li	a0,24
     388:	00001097          	auipc	ra,0x1
     38c:	efe080e7          	jalr	-258(ra) # 1286 <malloc>
     390:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     392:	4661                	li	a2,24
     394:	4581                	li	a1,0
     396:	00001097          	auipc	ra,0x1
     39a:	88e080e7          	jalr	-1906(ra) # c24 <memset>
  cmd->type = LIST;
     39e:	4791                	li	a5,4
     3a0:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     3a2:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     3a6:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     3aa:	8526                	mv	a0,s1
     3ac:	70a2                	ld	ra,40(sp)
     3ae:	7402                	ld	s0,32(sp)
     3b0:	64e2                	ld	s1,24(sp)
     3b2:	6942                	ld	s2,16(sp)
     3b4:	69a2                	ld	s3,8(sp)
     3b6:	6145                	addi	sp,sp,48
     3b8:	8082                	ret

00000000000003ba <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     3ba:	1101                	addi	sp,sp,-32
     3bc:	ec06                	sd	ra,24(sp)
     3be:	e822                	sd	s0,16(sp)
     3c0:	e426                	sd	s1,8(sp)
     3c2:	e04a                	sd	s2,0(sp)
     3c4:	1000                	addi	s0,sp,32
     3c6:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3c8:	4541                	li	a0,16
     3ca:	00001097          	auipc	ra,0x1
     3ce:	ebc080e7          	jalr	-324(ra) # 1286 <malloc>
     3d2:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3d4:	4641                	li	a2,16
     3d6:	4581                	li	a1,0
     3d8:	00001097          	auipc	ra,0x1
     3dc:	84c080e7          	jalr	-1972(ra) # c24 <memset>
  cmd->type = BACK;
     3e0:	4795                	li	a5,5
     3e2:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3e4:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     3e8:	8526                	mv	a0,s1
     3ea:	60e2                	ld	ra,24(sp)
     3ec:	6442                	ld	s0,16(sp)
     3ee:	64a2                	ld	s1,8(sp)
     3f0:	6902                	ld	s2,0(sp)
     3f2:	6105                	addi	sp,sp,32
     3f4:	8082                	ret

00000000000003f6 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     3f6:	7139                	addi	sp,sp,-64
     3f8:	fc06                	sd	ra,56(sp)
     3fa:	f822                	sd	s0,48(sp)
     3fc:	f426                	sd	s1,40(sp)
     3fe:	f04a                	sd	s2,32(sp)
     400:	ec4e                	sd	s3,24(sp)
     402:	e852                	sd	s4,16(sp)
     404:	e456                	sd	s5,8(sp)
     406:	e05a                	sd	s6,0(sp)
     408:	0080                	addi	s0,sp,64
     40a:	8a2a                	mv	s4,a0
     40c:	892e                	mv	s2,a1
     40e:	8ab2                	mv	s5,a2
     410:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     412:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     414:	00002997          	auipc	s3,0x2
     418:	bf498993          	addi	s3,s3,-1036 # 2008 <whitespace>
     41c:	00b4fd63          	bgeu	s1,a1,436 <gettoken+0x40>
     420:	0004c583          	lbu	a1,0(s1)
     424:	854e                	mv	a0,s3
     426:	00001097          	auipc	ra,0x1
     42a:	824080e7          	jalr	-2012(ra) # c4a <strchr>
     42e:	c501                	beqz	a0,436 <gettoken+0x40>
    s++;
     430:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     432:	fe9917e3          	bne	s2,s1,420 <gettoken+0x2a>
  if(q)
     436:	000a8463          	beqz	s5,43e <gettoken+0x48>
    *q = s;
     43a:	009ab023          	sd	s1,0(s5)
  ret = *s;
     43e:	0004c783          	lbu	a5,0(s1)
     442:	00078a9b          	sext.w	s5,a5
  switch(*s){
     446:	03c00713          	li	a4,60
     44a:	06f76563          	bltu	a4,a5,4b4 <gettoken+0xbe>
     44e:	03a00713          	li	a4,58
     452:	00f76e63          	bltu	a4,a5,46e <gettoken+0x78>
     456:	cf89                	beqz	a5,470 <gettoken+0x7a>
     458:	02600713          	li	a4,38
     45c:	00e78963          	beq	a5,a4,46e <gettoken+0x78>
     460:	fd87879b          	addiw	a5,a5,-40
     464:	0ff7f793          	andi	a5,a5,255
     468:	4705                	li	a4,1
     46a:	06f76c63          	bltu	a4,a5,4e2 <gettoken+0xec>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     46e:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     470:	000b0463          	beqz	s6,478 <gettoken+0x82>
    *eq = s;
     474:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     478:	00002997          	auipc	s3,0x2
     47c:	b9098993          	addi	s3,s3,-1136 # 2008 <whitespace>
     480:	0124fd63          	bgeu	s1,s2,49a <gettoken+0xa4>
     484:	0004c583          	lbu	a1,0(s1)
     488:	854e                	mv	a0,s3
     48a:	00000097          	auipc	ra,0x0
     48e:	7c0080e7          	jalr	1984(ra) # c4a <strchr>
     492:	c501                	beqz	a0,49a <gettoken+0xa4>
    s++;
     494:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     496:	fe9917e3          	bne	s2,s1,484 <gettoken+0x8e>
  *ps = s;
     49a:	009a3023          	sd	s1,0(s4)
  return ret;
}
     49e:	8556                	mv	a0,s5
     4a0:	70e2                	ld	ra,56(sp)
     4a2:	7442                	ld	s0,48(sp)
     4a4:	74a2                	ld	s1,40(sp)
     4a6:	7902                	ld	s2,32(sp)
     4a8:	69e2                	ld	s3,24(sp)
     4aa:	6a42                	ld	s4,16(sp)
     4ac:	6aa2                	ld	s5,8(sp)
     4ae:	6b02                	ld	s6,0(sp)
     4b0:	6121                	addi	sp,sp,64
     4b2:	8082                	ret
  switch(*s){
     4b4:	03e00713          	li	a4,62
     4b8:	02e79163          	bne	a5,a4,4da <gettoken+0xe4>
    s++;
     4bc:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     4c0:	0014c703          	lbu	a4,1(s1)
     4c4:	03e00793          	li	a5,62
      s++;
     4c8:	0489                	addi	s1,s1,2
      ret = '+';
     4ca:	02b00a93          	li	s5,43
    if(*s == '>'){
     4ce:	faf701e3          	beq	a4,a5,470 <gettoken+0x7a>
    s++;
     4d2:	84b6                	mv	s1,a3
  ret = *s;
     4d4:	03e00a93          	li	s5,62
     4d8:	bf61                	j	470 <gettoken+0x7a>
  switch(*s){
     4da:	07c00713          	li	a4,124
     4de:	f8e788e3          	beq	a5,a4,46e <gettoken+0x78>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4e2:	00002997          	auipc	s3,0x2
     4e6:	b2698993          	addi	s3,s3,-1242 # 2008 <whitespace>
     4ea:	00002a97          	auipc	s5,0x2
     4ee:	b16a8a93          	addi	s5,s5,-1258 # 2000 <symbols>
     4f2:	0324f563          	bgeu	s1,s2,51c <gettoken+0x126>
     4f6:	0004c583          	lbu	a1,0(s1)
     4fa:	854e                	mv	a0,s3
     4fc:	00000097          	auipc	ra,0x0
     500:	74e080e7          	jalr	1870(ra) # c4a <strchr>
     504:	e505                	bnez	a0,52c <gettoken+0x136>
     506:	0004c583          	lbu	a1,0(s1)
     50a:	8556                	mv	a0,s5
     50c:	00000097          	auipc	ra,0x0
     510:	73e080e7          	jalr	1854(ra) # c4a <strchr>
     514:	e909                	bnez	a0,526 <gettoken+0x130>
      s++;
     516:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     518:	fc991fe3          	bne	s2,s1,4f6 <gettoken+0x100>
  if(eq)
     51c:	06100a93          	li	s5,97
     520:	f40b1ae3          	bnez	s6,474 <gettoken+0x7e>
     524:	bf9d                	j	49a <gettoken+0xa4>
    ret = 'a';
     526:	06100a93          	li	s5,97
     52a:	b799                	j	470 <gettoken+0x7a>
     52c:	06100a93          	li	s5,97
     530:	b781                	j	470 <gettoken+0x7a>

0000000000000532 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     532:	7139                	addi	sp,sp,-64
     534:	fc06                	sd	ra,56(sp)
     536:	f822                	sd	s0,48(sp)
     538:	f426                	sd	s1,40(sp)
     53a:	f04a                	sd	s2,32(sp)
     53c:	ec4e                	sd	s3,24(sp)
     53e:	e852                	sd	s4,16(sp)
     540:	e456                	sd	s5,8(sp)
     542:	0080                	addi	s0,sp,64
     544:	8a2a                	mv	s4,a0
     546:	892e                	mv	s2,a1
     548:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     54a:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     54c:	00002997          	auipc	s3,0x2
     550:	abc98993          	addi	s3,s3,-1348 # 2008 <whitespace>
     554:	00b4fd63          	bgeu	s1,a1,56e <peek+0x3c>
     558:	0004c583          	lbu	a1,0(s1)
     55c:	854e                	mv	a0,s3
     55e:	00000097          	auipc	ra,0x0
     562:	6ec080e7          	jalr	1772(ra) # c4a <strchr>
     566:	c501                	beqz	a0,56e <peek+0x3c>
    s++;
     568:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     56a:	fe9917e3          	bne	s2,s1,558 <peek+0x26>
  *ps = s;
     56e:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     572:	0004c583          	lbu	a1,0(s1)
     576:	4501                	li	a0,0
     578:	e991                	bnez	a1,58c <peek+0x5a>
}
     57a:	70e2                	ld	ra,56(sp)
     57c:	7442                	ld	s0,48(sp)
     57e:	74a2                	ld	s1,40(sp)
     580:	7902                	ld	s2,32(sp)
     582:	69e2                	ld	s3,24(sp)
     584:	6a42                	ld	s4,16(sp)
     586:	6aa2                	ld	s5,8(sp)
     588:	6121                	addi	sp,sp,64
     58a:	8082                	ret
  return *s && strchr(toks, *s);
     58c:	8556                	mv	a0,s5
     58e:	00000097          	auipc	ra,0x0
     592:	6bc080e7          	jalr	1724(ra) # c4a <strchr>
     596:	00a03533          	snez	a0,a0
     59a:	b7c5                	j	57a <peek+0x48>

000000000000059c <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     59c:	7159                	addi	sp,sp,-112
     59e:	f486                	sd	ra,104(sp)
     5a0:	f0a2                	sd	s0,96(sp)
     5a2:	eca6                	sd	s1,88(sp)
     5a4:	e8ca                	sd	s2,80(sp)
     5a6:	e4ce                	sd	s3,72(sp)
     5a8:	e0d2                	sd	s4,64(sp)
     5aa:	fc56                	sd	s5,56(sp)
     5ac:	f85a                	sd	s6,48(sp)
     5ae:	f45e                	sd	s7,40(sp)
     5b0:	f062                	sd	s8,32(sp)
     5b2:	ec66                	sd	s9,24(sp)
     5b4:	1880                	addi	s0,sp,112
     5b6:	8a2a                	mv	s4,a0
     5b8:	89ae                	mv	s3,a1
     5ba:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5bc:	00001b97          	auipc	s7,0x1
     5c0:	e24b8b93          	addi	s7,s7,-476 # 13e0 <malloc+0x15a>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     5c4:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     5c8:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     5cc:	a02d                	j	5f6 <parseredirs+0x5a>
      panic("missing file for redirection");
     5ce:	00001517          	auipc	a0,0x1
     5d2:	df250513          	addi	a0,a0,-526 # 13c0 <malloc+0x13a>
     5d6:	00000097          	auipc	ra,0x0
     5da:	a80080e7          	jalr	-1408(ra) # 56 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5de:	4701                	li	a4,0
     5e0:	4681                	li	a3,0
     5e2:	f9043603          	ld	a2,-112(s0)
     5e6:	f9843583          	ld	a1,-104(s0)
     5ea:	8552                	mv	a0,s4
     5ec:	00000097          	auipc	ra,0x0
     5f0:	cda080e7          	jalr	-806(ra) # 2c6 <redircmd>
     5f4:	8a2a                	mv	s4,a0
    switch(tok){
     5f6:	03e00b13          	li	s6,62
     5fa:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     5fe:	865e                	mv	a2,s7
     600:	85ca                	mv	a1,s2
     602:	854e                	mv	a0,s3
     604:	00000097          	auipc	ra,0x0
     608:	f2e080e7          	jalr	-210(ra) # 532 <peek>
     60c:	c925                	beqz	a0,67c <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     60e:	4681                	li	a3,0
     610:	4601                	li	a2,0
     612:	85ca                	mv	a1,s2
     614:	854e                	mv	a0,s3
     616:	00000097          	auipc	ra,0x0
     61a:	de0080e7          	jalr	-544(ra) # 3f6 <gettoken>
     61e:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     620:	f9040693          	addi	a3,s0,-112
     624:	f9840613          	addi	a2,s0,-104
     628:	85ca                	mv	a1,s2
     62a:	854e                	mv	a0,s3
     62c:	00000097          	auipc	ra,0x0
     630:	dca080e7          	jalr	-566(ra) # 3f6 <gettoken>
     634:	f9851de3          	bne	a0,s8,5ce <parseredirs+0x32>
    switch(tok){
     638:	fb9483e3          	beq	s1,s9,5de <parseredirs+0x42>
     63c:	03648263          	beq	s1,s6,660 <parseredirs+0xc4>
     640:	fb549fe3          	bne	s1,s5,5fe <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     644:	4705                	li	a4,1
     646:	20100693          	li	a3,513
     64a:	f9043603          	ld	a2,-112(s0)
     64e:	f9843583          	ld	a1,-104(s0)
     652:	8552                	mv	a0,s4
     654:	00000097          	auipc	ra,0x0
     658:	c72080e7          	jalr	-910(ra) # 2c6 <redircmd>
     65c:	8a2a                	mv	s4,a0
      break;
     65e:	bf61                	j	5f6 <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     660:	4705                	li	a4,1
     662:	60100693          	li	a3,1537
     666:	f9043603          	ld	a2,-112(s0)
     66a:	f9843583          	ld	a1,-104(s0)
     66e:	8552                	mv	a0,s4
     670:	00000097          	auipc	ra,0x0
     674:	c56080e7          	jalr	-938(ra) # 2c6 <redircmd>
     678:	8a2a                	mv	s4,a0
      break;
     67a:	bfb5                	j	5f6 <parseredirs+0x5a>
    }
  }
  return cmd;
}
     67c:	8552                	mv	a0,s4
     67e:	70a6                	ld	ra,104(sp)
     680:	7406                	ld	s0,96(sp)
     682:	64e6                	ld	s1,88(sp)
     684:	6946                	ld	s2,80(sp)
     686:	69a6                	ld	s3,72(sp)
     688:	6a06                	ld	s4,64(sp)
     68a:	7ae2                	ld	s5,56(sp)
     68c:	7b42                	ld	s6,48(sp)
     68e:	7ba2                	ld	s7,40(sp)
     690:	7c02                	ld	s8,32(sp)
     692:	6ce2                	ld	s9,24(sp)
     694:	6165                	addi	sp,sp,112
     696:	8082                	ret

0000000000000698 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     698:	7159                	addi	sp,sp,-112
     69a:	f486                	sd	ra,104(sp)
     69c:	f0a2                	sd	s0,96(sp)
     69e:	eca6                	sd	s1,88(sp)
     6a0:	e8ca                	sd	s2,80(sp)
     6a2:	e4ce                	sd	s3,72(sp)
     6a4:	e0d2                	sd	s4,64(sp)
     6a6:	fc56                	sd	s5,56(sp)
     6a8:	f85a                	sd	s6,48(sp)
     6aa:	f45e                	sd	s7,40(sp)
     6ac:	f062                	sd	s8,32(sp)
     6ae:	ec66                	sd	s9,24(sp)
     6b0:	1880                	addi	s0,sp,112
     6b2:	8a2a                	mv	s4,a0
     6b4:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     6b6:	00001617          	auipc	a2,0x1
     6ba:	d3260613          	addi	a2,a2,-718 # 13e8 <malloc+0x162>
     6be:	00000097          	auipc	ra,0x0
     6c2:	e74080e7          	jalr	-396(ra) # 532 <peek>
     6c6:	e905                	bnez	a0,6f6 <parseexec+0x5e>
     6c8:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     6ca:	00000097          	auipc	ra,0x0
     6ce:	bc6080e7          	jalr	-1082(ra) # 290 <execcmd>
     6d2:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     6d4:	8656                	mv	a2,s5
     6d6:	85d2                	mv	a1,s4
     6d8:	00000097          	auipc	ra,0x0
     6dc:	ec4080e7          	jalr	-316(ra) # 59c <parseredirs>
     6e0:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     6e2:	008c0913          	addi	s2,s8,8
     6e6:	00001b17          	auipc	s6,0x1
     6ea:	d22b0b13          	addi	s6,s6,-734 # 1408 <malloc+0x182>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     6ee:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     6f2:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     6f4:	a0b1                	j	740 <parseexec+0xa8>
    return parseblock(ps, es);
     6f6:	85d6                	mv	a1,s5
     6f8:	8552                	mv	a0,s4
     6fa:	00000097          	auipc	ra,0x0
     6fe:	1bc080e7          	jalr	444(ra) # 8b6 <parseblock>
     702:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     704:	8526                	mv	a0,s1
     706:	70a6                	ld	ra,104(sp)
     708:	7406                	ld	s0,96(sp)
     70a:	64e6                	ld	s1,88(sp)
     70c:	6946                	ld	s2,80(sp)
     70e:	69a6                	ld	s3,72(sp)
     710:	6a06                	ld	s4,64(sp)
     712:	7ae2                	ld	s5,56(sp)
     714:	7b42                	ld	s6,48(sp)
     716:	7ba2                	ld	s7,40(sp)
     718:	7c02                	ld	s8,32(sp)
     71a:	6ce2                	ld	s9,24(sp)
     71c:	6165                	addi	sp,sp,112
     71e:	8082                	ret
      panic("syntax");
     720:	00001517          	auipc	a0,0x1
     724:	cd050513          	addi	a0,a0,-816 # 13f0 <malloc+0x16a>
     728:	00000097          	auipc	ra,0x0
     72c:	92e080e7          	jalr	-1746(ra) # 56 <panic>
    ret = parseredirs(ret, ps, es);
     730:	8656                	mv	a2,s5
     732:	85d2                	mv	a1,s4
     734:	8526                	mv	a0,s1
     736:	00000097          	auipc	ra,0x0
     73a:	e66080e7          	jalr	-410(ra) # 59c <parseredirs>
     73e:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     740:	865a                	mv	a2,s6
     742:	85d6                	mv	a1,s5
     744:	8552                	mv	a0,s4
     746:	00000097          	auipc	ra,0x0
     74a:	dec080e7          	jalr	-532(ra) # 532 <peek>
     74e:	e131                	bnez	a0,792 <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     750:	f9040693          	addi	a3,s0,-112
     754:	f9840613          	addi	a2,s0,-104
     758:	85d6                	mv	a1,s5
     75a:	8552                	mv	a0,s4
     75c:	00000097          	auipc	ra,0x0
     760:	c9a080e7          	jalr	-870(ra) # 3f6 <gettoken>
     764:	c51d                	beqz	a0,792 <parseexec+0xfa>
    if(tok != 'a')
     766:	fb951de3          	bne	a0,s9,720 <parseexec+0x88>
    cmd->argv[argc] = q;
     76a:	f9843783          	ld	a5,-104(s0)
     76e:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     772:	f9043783          	ld	a5,-112(s0)
     776:	04f93823          	sd	a5,80(s2)
    argc++;
     77a:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     77c:	0921                	addi	s2,s2,8
     77e:	fb7999e3          	bne	s3,s7,730 <parseexec+0x98>
      panic("too many args");
     782:	00001517          	auipc	a0,0x1
     786:	c7650513          	addi	a0,a0,-906 # 13f8 <malloc+0x172>
     78a:	00000097          	auipc	ra,0x0
     78e:	8cc080e7          	jalr	-1844(ra) # 56 <panic>
  cmd->argv[argc] = 0;
     792:	098e                	slli	s3,s3,0x3
     794:	99e2                	add	s3,s3,s8
     796:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     79a:	0409bc23          	sd	zero,88(s3)
  return ret;
     79e:	b79d                	j	704 <parseexec+0x6c>

00000000000007a0 <parsepipe>:
{
     7a0:	7179                	addi	sp,sp,-48
     7a2:	f406                	sd	ra,40(sp)
     7a4:	f022                	sd	s0,32(sp)
     7a6:	ec26                	sd	s1,24(sp)
     7a8:	e84a                	sd	s2,16(sp)
     7aa:	e44e                	sd	s3,8(sp)
     7ac:	1800                	addi	s0,sp,48
     7ae:	892a                	mv	s2,a0
     7b0:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     7b2:	00000097          	auipc	ra,0x0
     7b6:	ee6080e7          	jalr	-282(ra) # 698 <parseexec>
     7ba:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     7bc:	00001617          	auipc	a2,0x1
     7c0:	c5460613          	addi	a2,a2,-940 # 1410 <malloc+0x18a>
     7c4:	85ce                	mv	a1,s3
     7c6:	854a                	mv	a0,s2
     7c8:	00000097          	auipc	ra,0x0
     7cc:	d6a080e7          	jalr	-662(ra) # 532 <peek>
     7d0:	e909                	bnez	a0,7e2 <parsepipe+0x42>
}
     7d2:	8526                	mv	a0,s1
     7d4:	70a2                	ld	ra,40(sp)
     7d6:	7402                	ld	s0,32(sp)
     7d8:	64e2                	ld	s1,24(sp)
     7da:	6942                	ld	s2,16(sp)
     7dc:	69a2                	ld	s3,8(sp)
     7de:	6145                	addi	sp,sp,48
     7e0:	8082                	ret
    gettoken(ps, es, 0, 0);
     7e2:	4681                	li	a3,0
     7e4:	4601                	li	a2,0
     7e6:	85ce                	mv	a1,s3
     7e8:	854a                	mv	a0,s2
     7ea:	00000097          	auipc	ra,0x0
     7ee:	c0c080e7          	jalr	-1012(ra) # 3f6 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     7f2:	85ce                	mv	a1,s3
     7f4:	854a                	mv	a0,s2
     7f6:	00000097          	auipc	ra,0x0
     7fa:	faa080e7          	jalr	-86(ra) # 7a0 <parsepipe>
     7fe:	85aa                	mv	a1,a0
     800:	8526                	mv	a0,s1
     802:	00000097          	auipc	ra,0x0
     806:	b2c080e7          	jalr	-1236(ra) # 32e <pipecmd>
     80a:	84aa                	mv	s1,a0
  return cmd;
     80c:	b7d9                	j	7d2 <parsepipe+0x32>

000000000000080e <parseline>:
{
     80e:	7179                	addi	sp,sp,-48
     810:	f406                	sd	ra,40(sp)
     812:	f022                	sd	s0,32(sp)
     814:	ec26                	sd	s1,24(sp)
     816:	e84a                	sd	s2,16(sp)
     818:	e44e                	sd	s3,8(sp)
     81a:	e052                	sd	s4,0(sp)
     81c:	1800                	addi	s0,sp,48
     81e:	892a                	mv	s2,a0
     820:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     822:	00000097          	auipc	ra,0x0
     826:	f7e080e7          	jalr	-130(ra) # 7a0 <parsepipe>
     82a:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     82c:	00001a17          	auipc	s4,0x1
     830:	beca0a13          	addi	s4,s4,-1044 # 1418 <malloc+0x192>
     834:	8652                	mv	a2,s4
     836:	85ce                	mv	a1,s3
     838:	854a                	mv	a0,s2
     83a:	00000097          	auipc	ra,0x0
     83e:	cf8080e7          	jalr	-776(ra) # 532 <peek>
     842:	c105                	beqz	a0,862 <parseline+0x54>
    gettoken(ps, es, 0, 0);
     844:	4681                	li	a3,0
     846:	4601                	li	a2,0
     848:	85ce                	mv	a1,s3
     84a:	854a                	mv	a0,s2
     84c:	00000097          	auipc	ra,0x0
     850:	baa080e7          	jalr	-1110(ra) # 3f6 <gettoken>
    cmd = backcmd(cmd);
     854:	8526                	mv	a0,s1
     856:	00000097          	auipc	ra,0x0
     85a:	b64080e7          	jalr	-1180(ra) # 3ba <backcmd>
     85e:	84aa                	mv	s1,a0
     860:	bfd1                	j	834 <parseline+0x26>
  if(peek(ps, es, ";")){
     862:	00001617          	auipc	a2,0x1
     866:	bbe60613          	addi	a2,a2,-1090 # 1420 <malloc+0x19a>
     86a:	85ce                	mv	a1,s3
     86c:	854a                	mv	a0,s2
     86e:	00000097          	auipc	ra,0x0
     872:	cc4080e7          	jalr	-828(ra) # 532 <peek>
     876:	e911                	bnez	a0,88a <parseline+0x7c>
}
     878:	8526                	mv	a0,s1
     87a:	70a2                	ld	ra,40(sp)
     87c:	7402                	ld	s0,32(sp)
     87e:	64e2                	ld	s1,24(sp)
     880:	6942                	ld	s2,16(sp)
     882:	69a2                	ld	s3,8(sp)
     884:	6a02                	ld	s4,0(sp)
     886:	6145                	addi	sp,sp,48
     888:	8082                	ret
    gettoken(ps, es, 0, 0);
     88a:	4681                	li	a3,0
     88c:	4601                	li	a2,0
     88e:	85ce                	mv	a1,s3
     890:	854a                	mv	a0,s2
     892:	00000097          	auipc	ra,0x0
     896:	b64080e7          	jalr	-1180(ra) # 3f6 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     89a:	85ce                	mv	a1,s3
     89c:	854a                	mv	a0,s2
     89e:	00000097          	auipc	ra,0x0
     8a2:	f70080e7          	jalr	-144(ra) # 80e <parseline>
     8a6:	85aa                	mv	a1,a0
     8a8:	8526                	mv	a0,s1
     8aa:	00000097          	auipc	ra,0x0
     8ae:	aca080e7          	jalr	-1334(ra) # 374 <listcmd>
     8b2:	84aa                	mv	s1,a0
  return cmd;
     8b4:	b7d1                	j	878 <parseline+0x6a>

00000000000008b6 <parseblock>:
{
     8b6:	7179                	addi	sp,sp,-48
     8b8:	f406                	sd	ra,40(sp)
     8ba:	f022                	sd	s0,32(sp)
     8bc:	ec26                	sd	s1,24(sp)
     8be:	e84a                	sd	s2,16(sp)
     8c0:	e44e                	sd	s3,8(sp)
     8c2:	1800                	addi	s0,sp,48
     8c4:	84aa                	mv	s1,a0
     8c6:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8c8:	00001617          	auipc	a2,0x1
     8cc:	b2060613          	addi	a2,a2,-1248 # 13e8 <malloc+0x162>
     8d0:	00000097          	auipc	ra,0x0
     8d4:	c62080e7          	jalr	-926(ra) # 532 <peek>
     8d8:	c12d                	beqz	a0,93a <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     8da:	4681                	li	a3,0
     8dc:	4601                	li	a2,0
     8de:	85ca                	mv	a1,s2
     8e0:	8526                	mv	a0,s1
     8e2:	00000097          	auipc	ra,0x0
     8e6:	b14080e7          	jalr	-1260(ra) # 3f6 <gettoken>
  cmd = parseline(ps, es);
     8ea:	85ca                	mv	a1,s2
     8ec:	8526                	mv	a0,s1
     8ee:	00000097          	auipc	ra,0x0
     8f2:	f20080e7          	jalr	-224(ra) # 80e <parseline>
     8f6:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     8f8:	00001617          	auipc	a2,0x1
     8fc:	b4060613          	addi	a2,a2,-1216 # 1438 <malloc+0x1b2>
     900:	85ca                	mv	a1,s2
     902:	8526                	mv	a0,s1
     904:	00000097          	auipc	ra,0x0
     908:	c2e080e7          	jalr	-978(ra) # 532 <peek>
     90c:	cd1d                	beqz	a0,94a <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     90e:	4681                	li	a3,0
     910:	4601                	li	a2,0
     912:	85ca                	mv	a1,s2
     914:	8526                	mv	a0,s1
     916:	00000097          	auipc	ra,0x0
     91a:	ae0080e7          	jalr	-1312(ra) # 3f6 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     91e:	864a                	mv	a2,s2
     920:	85a6                	mv	a1,s1
     922:	854e                	mv	a0,s3
     924:	00000097          	auipc	ra,0x0
     928:	c78080e7          	jalr	-904(ra) # 59c <parseredirs>
}
     92c:	70a2                	ld	ra,40(sp)
     92e:	7402                	ld	s0,32(sp)
     930:	64e2                	ld	s1,24(sp)
     932:	6942                	ld	s2,16(sp)
     934:	69a2                	ld	s3,8(sp)
     936:	6145                	addi	sp,sp,48
     938:	8082                	ret
    panic("parseblock");
     93a:	00001517          	auipc	a0,0x1
     93e:	aee50513          	addi	a0,a0,-1298 # 1428 <malloc+0x1a2>
     942:	fffff097          	auipc	ra,0xfffff
     946:	714080e7          	jalr	1812(ra) # 56 <panic>
    panic("syntax - missing )");
     94a:	00001517          	auipc	a0,0x1
     94e:	af650513          	addi	a0,a0,-1290 # 1440 <malloc+0x1ba>
     952:	fffff097          	auipc	ra,0xfffff
     956:	704080e7          	jalr	1796(ra) # 56 <panic>

000000000000095a <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     95a:	1101                	addi	sp,sp,-32
     95c:	ec06                	sd	ra,24(sp)
     95e:	e822                	sd	s0,16(sp)
     960:	e426                	sd	s1,8(sp)
     962:	1000                	addi	s0,sp,32
     964:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     966:	c521                	beqz	a0,9ae <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     968:	4118                	lw	a4,0(a0)
     96a:	4795                	li	a5,5
     96c:	04e7e163          	bltu	a5,a4,9ae <nulterminate+0x54>
     970:	00056783          	lwu	a5,0(a0)
     974:	078a                	slli	a5,a5,0x2
     976:	00001717          	auipc	a4,0x1
     97a:	b3670713          	addi	a4,a4,-1226 # 14ac <malloc+0x226>
     97e:	97ba                	add	a5,a5,a4
     980:	439c                	lw	a5,0(a5)
     982:	97ba                	add	a5,a5,a4
     984:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     986:	651c                	ld	a5,8(a0)
     988:	c39d                	beqz	a5,9ae <nulterminate+0x54>
     98a:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     98e:	67b8                	ld	a4,72(a5)
     990:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     994:	07a1                	addi	a5,a5,8
     996:	ff87b703          	ld	a4,-8(a5)
     99a:	fb75                	bnez	a4,98e <nulterminate+0x34>
     99c:	a809                	j	9ae <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     99e:	6508                	ld	a0,8(a0)
     9a0:	00000097          	auipc	ra,0x0
     9a4:	fba080e7          	jalr	-70(ra) # 95a <nulterminate>
    *rcmd->efile = 0;
     9a8:	6c9c                	ld	a5,24(s1)
     9aa:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     9ae:	8526                	mv	a0,s1
     9b0:	60e2                	ld	ra,24(sp)
     9b2:	6442                	ld	s0,16(sp)
     9b4:	64a2                	ld	s1,8(sp)
     9b6:	6105                	addi	sp,sp,32
     9b8:	8082                	ret
    nulterminate(pcmd->left);
     9ba:	6508                	ld	a0,8(a0)
     9bc:	00000097          	auipc	ra,0x0
     9c0:	f9e080e7          	jalr	-98(ra) # 95a <nulterminate>
    nulterminate(pcmd->right);
     9c4:	6888                	ld	a0,16(s1)
     9c6:	00000097          	auipc	ra,0x0
     9ca:	f94080e7          	jalr	-108(ra) # 95a <nulterminate>
    break;
     9ce:	b7c5                	j	9ae <nulterminate+0x54>
    nulterminate(lcmd->left);
     9d0:	6508                	ld	a0,8(a0)
     9d2:	00000097          	auipc	ra,0x0
     9d6:	f88080e7          	jalr	-120(ra) # 95a <nulterminate>
    nulterminate(lcmd->right);
     9da:	6888                	ld	a0,16(s1)
     9dc:	00000097          	auipc	ra,0x0
     9e0:	f7e080e7          	jalr	-130(ra) # 95a <nulterminate>
    break;
     9e4:	b7e9                	j	9ae <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     9e6:	6508                	ld	a0,8(a0)
     9e8:	00000097          	auipc	ra,0x0
     9ec:	f72080e7          	jalr	-142(ra) # 95a <nulterminate>
    break;
     9f0:	bf7d                	j	9ae <nulterminate+0x54>

00000000000009f2 <parsecmd>:
{
     9f2:	7179                	addi	sp,sp,-48
     9f4:	f406                	sd	ra,40(sp)
     9f6:	f022                	sd	s0,32(sp)
     9f8:	ec26                	sd	s1,24(sp)
     9fa:	e84a                	sd	s2,16(sp)
     9fc:	1800                	addi	s0,sp,48
     9fe:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     a02:	84aa                	mv	s1,a0
     a04:	00000097          	auipc	ra,0x0
     a08:	1f6080e7          	jalr	502(ra) # bfa <strlen>
     a0c:	1502                	slli	a0,a0,0x20
     a0e:	9101                	srli	a0,a0,0x20
     a10:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     a12:	85a6                	mv	a1,s1
     a14:	fd840513          	addi	a0,s0,-40
     a18:	00000097          	auipc	ra,0x0
     a1c:	df6080e7          	jalr	-522(ra) # 80e <parseline>
     a20:	892a                	mv	s2,a0
  peek(&s, es, "");
     a22:	00001617          	auipc	a2,0x1
     a26:	98e60613          	addi	a2,a2,-1650 # 13b0 <malloc+0x12a>
     a2a:	85a6                	mv	a1,s1
     a2c:	fd840513          	addi	a0,s0,-40
     a30:	00000097          	auipc	ra,0x0
     a34:	b02080e7          	jalr	-1278(ra) # 532 <peek>
  if(s != es){
     a38:	fd843603          	ld	a2,-40(s0)
     a3c:	00961e63          	bne	a2,s1,a58 <parsecmd+0x66>
  nulterminate(cmd);
     a40:	854a                	mv	a0,s2
     a42:	00000097          	auipc	ra,0x0
     a46:	f18080e7          	jalr	-232(ra) # 95a <nulterminate>
}
     a4a:	854a                	mv	a0,s2
     a4c:	70a2                	ld	ra,40(sp)
     a4e:	7402                	ld	s0,32(sp)
     a50:	64e2                	ld	s1,24(sp)
     a52:	6942                	ld	s2,16(sp)
     a54:	6145                	addi	sp,sp,48
     a56:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a58:	00001597          	auipc	a1,0x1
     a5c:	a0058593          	addi	a1,a1,-1536 # 1458 <malloc+0x1d2>
     a60:	4509                	li	a0,2
     a62:	00000097          	auipc	ra,0x0
     a66:	738080e7          	jalr	1848(ra) # 119a <fprintf>
    panic("syntax");
     a6a:	00001517          	auipc	a0,0x1
     a6e:	98650513          	addi	a0,a0,-1658 # 13f0 <malloc+0x16a>
     a72:	fffff097          	auipc	ra,0xfffff
     a76:	5e4080e7          	jalr	1508(ra) # 56 <panic>

0000000000000a7a <main>:
  {
     a7a:	711d                	addi	sp,sp,-96
     a7c:	ec86                	sd	ra,88(sp)
     a7e:	e8a2                	sd	s0,80(sp)
     a80:	e4a6                	sd	s1,72(sp)
     a82:	e0ca                	sd	s2,64(sp)
     a84:	fc4e                	sd	s3,56(sp)
     a86:	f852                	sd	s4,48(sp)
     a88:	f456                	sd	s5,40(sp)
     a8a:	f05a                	sd	s6,32(sp)
     a8c:	ec5e                	sd	s7,24(sp)
     a8e:	1080                	addi	s0,sp,96
    while((fd = open("console", O_RDWR)) >= 0){
     a90:	00001497          	auipc	s1,0x1
     a94:	9d848493          	addi	s1,s1,-1576 # 1468 <malloc+0x1e2>
     a98:	4589                	li	a1,2
     a9a:	8526                	mv	a0,s1
     a9c:	00000097          	auipc	ra,0x0
     aa0:	3d4080e7          	jalr	980(ra) # e70 <open>
     aa4:	00054963          	bltz	a0,ab6 <main+0x3c>
      if(fd >= 3){
     aa8:	4789                	li	a5,2
     aaa:	fea7d7e3          	bge	a5,a0,a98 <main+0x1e>
        close(fd);
     aae:	00000097          	auipc	ra,0x0
     ab2:	3aa080e7          	jalr	938(ra) # e58 <close>
    while(getcmd(buf, sizeof(buf)) >= 0){
     ab6:	00001497          	auipc	s1,0x1
     aba:	56a48493          	addi	s1,s1,1386 # 2020 <buf.1155>
      if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     abe:	06300993          	li	s3,99
      if (wait(&st, "") > 0)
     ac2:	00001917          	auipc	s2,0x1
     ac6:	8ee90913          	addi	s2,s2,-1810 # 13b0 <malloc+0x12a>
        printf("Exit message: %s\n", "");
     aca:	00001a17          	auipc	s4,0x1
     ace:	9b6a0a13          	addi	s4,s4,-1610 # 1480 <malloc+0x1fa>
      if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     ad2:	02000a93          	li	s5,32
        if(chdir(buf+3) < 0)
     ad6:	00001b17          	auipc	s6,0x1
     ada:	54db0b13          	addi	s6,s6,1357 # 2023 <buf.1155+0x3>
          fprintf(2, "cannot cd %s\n", buf+3);
     ade:	00001b97          	auipc	s7,0x1
     ae2:	992b8b93          	addi	s7,s7,-1646 # 1470 <malloc+0x1ea>
     ae6:	a839                	j	b04 <main+0x8a>
      if(fork1() == 0)
     ae8:	fffff097          	auipc	ra,0xfffff
     aec:	594080e7          	jalr	1428(ra) # 7c <fork1>
     af0:	cd25                	beqz	a0,b68 <main+0xee>
      if (wait(&st, "") > 0)
     af2:	85ca                	mv	a1,s2
     af4:	fac40513          	addi	a0,s0,-84
     af8:	00000097          	auipc	ra,0x0
     afc:	340080e7          	jalr	832(ra) # e38 <wait>
     b00:	08a04063          	bgtz	a0,b80 <main+0x106>
    while(getcmd(buf, sizeof(buf)) >= 0){
     b04:	06400593          	li	a1,100
     b08:	8526                	mv	a0,s1
     b0a:	fffff097          	auipc	ra,0xfffff
     b0e:	4f6080e7          	jalr	1270(ra) # 0 <getcmd>
     b12:	06054e63          	bltz	a0,b8e <main+0x114>
      if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b16:	0004c783          	lbu	a5,0(s1)
     b1a:	fd3797e3          	bne	a5,s3,ae8 <main+0x6e>
     b1e:	0014c703          	lbu	a4,1(s1)
     b22:	06400793          	li	a5,100
     b26:	fcf711e3          	bne	a4,a5,ae8 <main+0x6e>
     b2a:	0024c783          	lbu	a5,2(s1)
     b2e:	fb579de3          	bne	a5,s5,ae8 <main+0x6e>
        buf[strlen(buf)-1] = 0;  // chop \n
     b32:	8526                	mv	a0,s1
     b34:	00000097          	auipc	ra,0x0
     b38:	0c6080e7          	jalr	198(ra) # bfa <strlen>
     b3c:	fff5079b          	addiw	a5,a0,-1
     b40:	1782                	slli	a5,a5,0x20
     b42:	9381                	srli	a5,a5,0x20
     b44:	97a6                	add	a5,a5,s1
     b46:	00078023          	sb	zero,0(a5)
        if(chdir(buf+3) < 0)
     b4a:	855a                	mv	a0,s6
     b4c:	00000097          	auipc	ra,0x0
     b50:	354080e7          	jalr	852(ra) # ea0 <chdir>
     b54:	fa0558e3          	bgez	a0,b04 <main+0x8a>
          fprintf(2, "cannot cd %s\n", buf+3);
     b58:	865a                	mv	a2,s6
     b5a:	85de                	mv	a1,s7
     b5c:	4509                	li	a0,2
     b5e:	00000097          	auipc	ra,0x0
     b62:	63c080e7          	jalr	1596(ra) # 119a <fprintf>
        continue;
     b66:	bf79                	j	b04 <main+0x8a>
        runcmd(parsecmd(buf));
     b68:	00001517          	auipc	a0,0x1
     b6c:	4b850513          	addi	a0,a0,1208 # 2020 <buf.1155>
     b70:	00000097          	auipc	ra,0x0
     b74:	e82080e7          	jalr	-382(ra) # 9f2 <parsecmd>
     b78:	fffff097          	auipc	ra,0xfffff
     b7c:	532080e7          	jalr	1330(ra) # aa <runcmd>
        printf("Exit message: %s\n", "");
     b80:	85ca                	mv	a1,s2
     b82:	8552                	mv	a0,s4
     b84:	00000097          	auipc	ra,0x0
     b88:	644080e7          	jalr	1604(ra) # 11c8 <printf>
     b8c:	bfa5                	j	b04 <main+0x8a>
    exit(0);
     b8e:	4501                	li	a0,0
     b90:	00000097          	auipc	ra,0x0
     b94:	298080e7          	jalr	664(ra) # e28 <exit>

0000000000000b98 <_main>:

//
// wrapper so that it's OK if main() does not call exit().
//
void _main()
{
     b98:	1141                	addi	sp,sp,-16
     b9a:	e406                	sd	ra,8(sp)
     b9c:	e022                	sd	s0,0(sp)
     b9e:	0800                	addi	s0,sp,16
  extern int main();
  main();
     ba0:	00000097          	auipc	ra,0x0
     ba4:	eda080e7          	jalr	-294(ra) # a7a <main>
  exit(0);
     ba8:	4501                	li	a0,0
     baa:	00000097          	auipc	ra,0x0
     bae:	27e080e7          	jalr	638(ra) # e28 <exit>

0000000000000bb2 <strcpy>:
}

char* strcpy(char *s, const char *t)
{
     bb2:	1141                	addi	sp,sp,-16
     bb4:	e422                	sd	s0,8(sp)
     bb6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bb8:	87aa                	mv	a5,a0
     bba:	0585                	addi	a1,a1,1
     bbc:	0785                	addi	a5,a5,1
     bbe:	fff5c703          	lbu	a4,-1(a1)
     bc2:	fee78fa3          	sb	a4,-1(a5)
     bc6:	fb75                	bnez	a4,bba <strcpy+0x8>
    ;
  return os;
}
     bc8:	6422                	ld	s0,8(sp)
     bca:	0141                	addi	sp,sp,16
     bcc:	8082                	ret

0000000000000bce <strcmp>:

int strcmp(const char *p, const char *q)
{
     bce:	1141                	addi	sp,sp,-16
     bd0:	e422                	sd	s0,8(sp)
     bd2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     bd4:	00054783          	lbu	a5,0(a0)
     bd8:	cb91                	beqz	a5,bec <strcmp+0x1e>
     bda:	0005c703          	lbu	a4,0(a1)
     bde:	00f71763          	bne	a4,a5,bec <strcmp+0x1e>
    p++, q++;
     be2:	0505                	addi	a0,a0,1
     be4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     be6:	00054783          	lbu	a5,0(a0)
     bea:	fbe5                	bnez	a5,bda <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     bec:	0005c503          	lbu	a0,0(a1)
}
     bf0:	40a7853b          	subw	a0,a5,a0
     bf4:	6422                	ld	s0,8(sp)
     bf6:	0141                	addi	sp,sp,16
     bf8:	8082                	ret

0000000000000bfa <strlen>:

uint strlen(const char *s)
{
     bfa:	1141                	addi	sp,sp,-16
     bfc:	e422                	sd	s0,8(sp)
     bfe:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c00:	00054783          	lbu	a5,0(a0)
     c04:	cf91                	beqz	a5,c20 <strlen+0x26>
     c06:	0505                	addi	a0,a0,1
     c08:	87aa                	mv	a5,a0
     c0a:	4685                	li	a3,1
     c0c:	9e89                	subw	a3,a3,a0
     c0e:	00f6853b          	addw	a0,a3,a5
     c12:	0785                	addi	a5,a5,1
     c14:	fff7c703          	lbu	a4,-1(a5)
     c18:	fb7d                	bnez	a4,c0e <strlen+0x14>
    ;
  return n;
}
     c1a:	6422                	ld	s0,8(sp)
     c1c:	0141                	addi	sp,sp,16
     c1e:	8082                	ret
  for(n = 0; s[n]; n++)
     c20:	4501                	li	a0,0
     c22:	bfe5                	j	c1a <strlen+0x20>

0000000000000c24 <memset>:

void* memset(void *dst, int c, uint n)
{
     c24:	1141                	addi	sp,sp,-16
     c26:	e422                	sd	s0,8(sp)
     c28:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c2a:	ce09                	beqz	a2,c44 <memset+0x20>
     c2c:	87aa                	mv	a5,a0
     c2e:	fff6071b          	addiw	a4,a2,-1
     c32:	1702                	slli	a4,a4,0x20
     c34:	9301                	srli	a4,a4,0x20
     c36:	0705                	addi	a4,a4,1
     c38:	972a                	add	a4,a4,a0
    cdst[i] = c;
     c3a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c3e:	0785                	addi	a5,a5,1
     c40:	fee79de3          	bne	a5,a4,c3a <memset+0x16>
  }
  return dst;
}
     c44:	6422                	ld	s0,8(sp)
     c46:	0141                	addi	sp,sp,16
     c48:	8082                	ret

0000000000000c4a <strchr>:

char* strchr(const char *s, char c)
{
     c4a:	1141                	addi	sp,sp,-16
     c4c:	e422                	sd	s0,8(sp)
     c4e:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c50:	00054783          	lbu	a5,0(a0)
     c54:	cb99                	beqz	a5,c6a <strchr+0x20>
    if(*s == c)
     c56:	00f58763          	beq	a1,a5,c64 <strchr+0x1a>
  for(; *s; s++)
     c5a:	0505                	addi	a0,a0,1
     c5c:	00054783          	lbu	a5,0(a0)
     c60:	fbfd                	bnez	a5,c56 <strchr+0xc>
      return (char*)s;
  return 0;
     c62:	4501                	li	a0,0
}
     c64:	6422                	ld	s0,8(sp)
     c66:	0141                	addi	sp,sp,16
     c68:	8082                	ret
  return 0;
     c6a:	4501                	li	a0,0
     c6c:	bfe5                	j	c64 <strchr+0x1a>

0000000000000c6e <gets>:

char* gets(char *buf, int max)
{
     c6e:	711d                	addi	sp,sp,-96
     c70:	ec86                	sd	ra,88(sp)
     c72:	e8a2                	sd	s0,80(sp)
     c74:	e4a6                	sd	s1,72(sp)
     c76:	e0ca                	sd	s2,64(sp)
     c78:	fc4e                	sd	s3,56(sp)
     c7a:	f852                	sd	s4,48(sp)
     c7c:	f456                	sd	s5,40(sp)
     c7e:	f05a                	sd	s6,32(sp)
     c80:	ec5e                	sd	s7,24(sp)
     c82:	1080                	addi	s0,sp,96
     c84:	8baa                	mv	s7,a0
     c86:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c88:	892a                	mv	s2,a0
     c8a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c8c:	4aa9                	li	s5,10
     c8e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     c90:	89a6                	mv	s3,s1
     c92:	2485                	addiw	s1,s1,1
     c94:	0344d863          	bge	s1,s4,cc4 <gets+0x56>
    cc = read(0, &c, 1);
     c98:	4605                	li	a2,1
     c9a:	faf40593          	addi	a1,s0,-81
     c9e:	4501                	li	a0,0
     ca0:	00000097          	auipc	ra,0x0
     ca4:	1a8080e7          	jalr	424(ra) # e48 <read>
    if(cc < 1)
     ca8:	00a05e63          	blez	a0,cc4 <gets+0x56>
    buf[i++] = c;
     cac:	faf44783          	lbu	a5,-81(s0)
     cb0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cb4:	01578763          	beq	a5,s5,cc2 <gets+0x54>
     cb8:	0905                	addi	s2,s2,1
     cba:	fd679be3          	bne	a5,s6,c90 <gets+0x22>
  for(i=0; i+1 < max; ){
     cbe:	89a6                	mv	s3,s1
     cc0:	a011                	j	cc4 <gets+0x56>
     cc2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     cc4:	99de                	add	s3,s3,s7
     cc6:	00098023          	sb	zero,0(s3)
  return buf;
}
     cca:	855e                	mv	a0,s7
     ccc:	60e6                	ld	ra,88(sp)
     cce:	6446                	ld	s0,80(sp)
     cd0:	64a6                	ld	s1,72(sp)
     cd2:	6906                	ld	s2,64(sp)
     cd4:	79e2                	ld	s3,56(sp)
     cd6:	7a42                	ld	s4,48(sp)
     cd8:	7aa2                	ld	s5,40(sp)
     cda:	7b02                	ld	s6,32(sp)
     cdc:	6be2                	ld	s7,24(sp)
     cde:	6125                	addi	sp,sp,96
     ce0:	8082                	ret

0000000000000ce2 <stat>:

int stat(const char *n, struct stat *st)
{
     ce2:	1101                	addi	sp,sp,-32
     ce4:	ec06                	sd	ra,24(sp)
     ce6:	e822                	sd	s0,16(sp)
     ce8:	e426                	sd	s1,8(sp)
     cea:	e04a                	sd	s2,0(sp)
     cec:	1000                	addi	s0,sp,32
     cee:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     cf0:	4581                	li	a1,0
     cf2:	00000097          	auipc	ra,0x0
     cf6:	17e080e7          	jalr	382(ra) # e70 <open>
  if(fd < 0)
     cfa:	02054563          	bltz	a0,d24 <stat+0x42>
     cfe:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d00:	85ca                	mv	a1,s2
     d02:	00000097          	auipc	ra,0x0
     d06:	186080e7          	jalr	390(ra) # e88 <fstat>
     d0a:	892a                	mv	s2,a0
  close(fd);
     d0c:	8526                	mv	a0,s1
     d0e:	00000097          	auipc	ra,0x0
     d12:	14a080e7          	jalr	330(ra) # e58 <close>
  return r;
}
     d16:	854a                	mv	a0,s2
     d18:	60e2                	ld	ra,24(sp)
     d1a:	6442                	ld	s0,16(sp)
     d1c:	64a2                	ld	s1,8(sp)
     d1e:	6902                	ld	s2,0(sp)
     d20:	6105                	addi	sp,sp,32
     d22:	8082                	ret
    return -1;
     d24:	597d                	li	s2,-1
     d26:	bfc5                	j	d16 <stat+0x34>

0000000000000d28 <atoi>:

int atoi(const char *s)
{
     d28:	1141                	addi	sp,sp,-16
     d2a:	e422                	sd	s0,8(sp)
     d2c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d2e:	00054603          	lbu	a2,0(a0)
     d32:	fd06079b          	addiw	a5,a2,-48
     d36:	0ff7f793          	andi	a5,a5,255
     d3a:	4725                	li	a4,9
     d3c:	02f76963          	bltu	a4,a5,d6e <atoi+0x46>
     d40:	86aa                	mv	a3,a0
  n = 0;
     d42:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d44:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d46:	0685                	addi	a3,a3,1
     d48:	0025179b          	slliw	a5,a0,0x2
     d4c:	9fa9                	addw	a5,a5,a0
     d4e:	0017979b          	slliw	a5,a5,0x1
     d52:	9fb1                	addw	a5,a5,a2
     d54:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d58:	0006c603          	lbu	a2,0(a3)
     d5c:	fd06071b          	addiw	a4,a2,-48
     d60:	0ff77713          	andi	a4,a4,255
     d64:	fee5f1e3          	bgeu	a1,a4,d46 <atoi+0x1e>
  return n;
}
     d68:	6422                	ld	s0,8(sp)
     d6a:	0141                	addi	sp,sp,16
     d6c:	8082                	ret
  n = 0;
     d6e:	4501                	li	a0,0
     d70:	bfe5                	j	d68 <atoi+0x40>

0000000000000d72 <memmove>:

void* memmove(void *vdst, const void *vsrc, int n)
{
     d72:	1141                	addi	sp,sp,-16
     d74:	e422                	sd	s0,8(sp)
     d76:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d78:	02b57663          	bgeu	a0,a1,da4 <memmove+0x32>
    while(n-- > 0)
     d7c:	02c05163          	blez	a2,d9e <memmove+0x2c>
     d80:	fff6079b          	addiw	a5,a2,-1
     d84:	1782                	slli	a5,a5,0x20
     d86:	9381                	srli	a5,a5,0x20
     d88:	0785                	addi	a5,a5,1
     d8a:	97aa                	add	a5,a5,a0
  dst = vdst;
     d8c:	872a                	mv	a4,a0
      *dst++ = *src++;
     d8e:	0585                	addi	a1,a1,1
     d90:	0705                	addi	a4,a4,1
     d92:	fff5c683          	lbu	a3,-1(a1)
     d96:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     d9a:	fee79ae3          	bne	a5,a4,d8e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     d9e:	6422                	ld	s0,8(sp)
     da0:	0141                	addi	sp,sp,16
     da2:	8082                	ret
    dst += n;
     da4:	00c50733          	add	a4,a0,a2
    src += n;
     da8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     daa:	fec05ae3          	blez	a2,d9e <memmove+0x2c>
     dae:	fff6079b          	addiw	a5,a2,-1
     db2:	1782                	slli	a5,a5,0x20
     db4:	9381                	srli	a5,a5,0x20
     db6:	fff7c793          	not	a5,a5
     dba:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dbc:	15fd                	addi	a1,a1,-1
     dbe:	177d                	addi	a4,a4,-1
     dc0:	0005c683          	lbu	a3,0(a1)
     dc4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     dc8:	fee79ae3          	bne	a5,a4,dbc <memmove+0x4a>
     dcc:	bfc9                	j	d9e <memmove+0x2c>

0000000000000dce <memcmp>:

int memcmp(const void *s1, const void *s2, uint n)
{
     dce:	1141                	addi	sp,sp,-16
     dd0:	e422                	sd	s0,8(sp)
     dd2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     dd4:	ca05                	beqz	a2,e04 <memcmp+0x36>
     dd6:	fff6069b          	addiw	a3,a2,-1
     dda:	1682                	slli	a3,a3,0x20
     ddc:	9281                	srli	a3,a3,0x20
     dde:	0685                	addi	a3,a3,1
     de0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     de2:	00054783          	lbu	a5,0(a0)
     de6:	0005c703          	lbu	a4,0(a1)
     dea:	00e79863          	bne	a5,a4,dfa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     dee:	0505                	addi	a0,a0,1
    p2++;
     df0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     df2:	fed518e3          	bne	a0,a3,de2 <memcmp+0x14>
  }
  return 0;
     df6:	4501                	li	a0,0
     df8:	a019                	j	dfe <memcmp+0x30>
      return *p1 - *p2;
     dfa:	40e7853b          	subw	a0,a5,a4
}
     dfe:	6422                	ld	s0,8(sp)
     e00:	0141                	addi	sp,sp,16
     e02:	8082                	ret
  return 0;
     e04:	4501                	li	a0,0
     e06:	bfe5                	j	dfe <memcmp+0x30>

0000000000000e08 <memcpy>:

void * memcpy(void *dst, const void *src, uint n)
{
     e08:	1141                	addi	sp,sp,-16
     e0a:	e406                	sd	ra,8(sp)
     e0c:	e022                	sd	s0,0(sp)
     e0e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e10:	00000097          	auipc	ra,0x0
     e14:	f62080e7          	jalr	-158(ra) # d72 <memmove>
}
     e18:	60a2                	ld	ra,8(sp)
     e1a:	6402                	ld	s0,0(sp)
     e1c:	0141                	addi	sp,sp,16
     e1e:	8082                	ret

0000000000000e20 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e20:	4885                	li	a7,1
 ecall
     e22:	00000073          	ecall
 ret
     e26:	8082                	ret

0000000000000e28 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e28:	4889                	li	a7,2
 ecall
     e2a:	00000073          	ecall
 ret
     e2e:	8082                	ret

0000000000000e30 <exitmsg>:
.global exitmsg
exitmsg:
 li a7, SYS_exitmsg
     e30:	48e1                	li	a7,24
 ecall
     e32:	00000073          	ecall
 ret
     e36:	8082                	ret

0000000000000e38 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e38:	488d                	li	a7,3
 ecall
     e3a:	00000073          	ecall
 ret
     e3e:	8082                	ret

0000000000000e40 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e40:	4891                	li	a7,4
 ecall
     e42:	00000073          	ecall
 ret
     e46:	8082                	ret

0000000000000e48 <read>:
.global read
read:
 li a7, SYS_read
     e48:	4895                	li	a7,5
 ecall
     e4a:	00000073          	ecall
 ret
     e4e:	8082                	ret

0000000000000e50 <write>:
.global write
write:
 li a7, SYS_write
     e50:	48c1                	li	a7,16
 ecall
     e52:	00000073          	ecall
 ret
     e56:	8082                	ret

0000000000000e58 <close>:
.global close
close:
 li a7, SYS_close
     e58:	48d5                	li	a7,21
 ecall
     e5a:	00000073          	ecall
 ret
     e5e:	8082                	ret

0000000000000e60 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e60:	4899                	li	a7,6
 ecall
     e62:	00000073          	ecall
 ret
     e66:	8082                	ret

0000000000000e68 <exec>:
.global exec
exec:
 li a7, SYS_exec
     e68:	489d                	li	a7,7
 ecall
     e6a:	00000073          	ecall
 ret
     e6e:	8082                	ret

0000000000000e70 <open>:
.global open
open:
 li a7, SYS_open
     e70:	48bd                	li	a7,15
 ecall
     e72:	00000073          	ecall
 ret
     e76:	8082                	ret

0000000000000e78 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e78:	48c5                	li	a7,17
 ecall
     e7a:	00000073          	ecall
 ret
     e7e:	8082                	ret

0000000000000e80 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     e80:	48c9                	li	a7,18
 ecall
     e82:	00000073          	ecall
 ret
     e86:	8082                	ret

0000000000000e88 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     e88:	48a1                	li	a7,8
 ecall
     e8a:	00000073          	ecall
 ret
     e8e:	8082                	ret

0000000000000e90 <link>:
.global link
link:
 li a7, SYS_link
     e90:	48cd                	li	a7,19
 ecall
     e92:	00000073          	ecall
 ret
     e96:	8082                	ret

0000000000000e98 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     e98:	48d1                	li	a7,20
 ecall
     e9a:	00000073          	ecall
 ret
     e9e:	8082                	ret

0000000000000ea0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ea0:	48a5                	li	a7,9
 ecall
     ea2:	00000073          	ecall
 ret
     ea6:	8082                	ret

0000000000000ea8 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ea8:	48a9                	li	a7,10
 ecall
     eaa:	00000073          	ecall
 ret
     eae:	8082                	ret

0000000000000eb0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     eb0:	48ad                	li	a7,11
 ecall
     eb2:	00000073          	ecall
 ret
     eb6:	8082                	ret

0000000000000eb8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     eb8:	48b1                	li	a7,12
 ecall
     eba:	00000073          	ecall
 ret
     ebe:	8082                	ret

0000000000000ec0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ec0:	48b5                	li	a7,13
 ecall
     ec2:	00000073          	ecall
 ret
     ec6:	8082                	ret

0000000000000ec8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ec8:	48b9                	li	a7,14
 ecall
     eca:	00000073          	ecall
 ret
     ece:	8082                	ret

0000000000000ed0 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
     ed0:	48dd                	li	a7,23
 ecall
     ed2:	00000073          	ecall
 ret
     ed6:	8082                	ret

0000000000000ed8 <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
     ed8:	48e5                	li	a7,25
 ecall
     eda:	00000073          	ecall
 ret
     ede:	8082                	ret

0000000000000ee0 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
     ee0:	48e9                	li	a7,26
 ecall
     ee2:	00000073          	ecall
 ret
     ee6:	8082                	ret

0000000000000ee8 <exit_num>:
.global exit_num
exit_num:
 li a7, SYS_exit_num
     ee8:	48ed                	li	a7,27
 ecall
     eea:	00000073          	ecall
 ret
     eee:	8082                	ret

0000000000000ef0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     ef0:	1101                	addi	sp,sp,-32
     ef2:	ec06                	sd	ra,24(sp)
     ef4:	e822                	sd	s0,16(sp)
     ef6:	1000                	addi	s0,sp,32
     ef8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     efc:	4605                	li	a2,1
     efe:	fef40593          	addi	a1,s0,-17
     f02:	00000097          	auipc	ra,0x0
     f06:	f4e080e7          	jalr	-178(ra) # e50 <write>
}
     f0a:	60e2                	ld	ra,24(sp)
     f0c:	6442                	ld	s0,16(sp)
     f0e:	6105                	addi	sp,sp,32
     f10:	8082                	ret

0000000000000f12 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f12:	7139                	addi	sp,sp,-64
     f14:	fc06                	sd	ra,56(sp)
     f16:	f822                	sd	s0,48(sp)
     f18:	f426                	sd	s1,40(sp)
     f1a:	f04a                	sd	s2,32(sp)
     f1c:	ec4e                	sd	s3,24(sp)
     f1e:	0080                	addi	s0,sp,64
     f20:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f22:	c299                	beqz	a3,f28 <printint+0x16>
     f24:	0805c863          	bltz	a1,fb4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f28:	2581                	sext.w	a1,a1
  neg = 0;
     f2a:	4881                	li	a7,0
     f2c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f30:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f32:	2601                	sext.w	a2,a2
     f34:	00000517          	auipc	a0,0x0
     f38:	59c50513          	addi	a0,a0,1436 # 14d0 <digits>
     f3c:	883a                	mv	a6,a4
     f3e:	2705                	addiw	a4,a4,1
     f40:	02c5f7bb          	remuw	a5,a1,a2
     f44:	1782                	slli	a5,a5,0x20
     f46:	9381                	srli	a5,a5,0x20
     f48:	97aa                	add	a5,a5,a0
     f4a:	0007c783          	lbu	a5,0(a5)
     f4e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f52:	0005879b          	sext.w	a5,a1
     f56:	02c5d5bb          	divuw	a1,a1,a2
     f5a:	0685                	addi	a3,a3,1
     f5c:	fec7f0e3          	bgeu	a5,a2,f3c <printint+0x2a>
  if(neg)
     f60:	00088b63          	beqz	a7,f76 <printint+0x64>
    buf[i++] = '-';
     f64:	fd040793          	addi	a5,s0,-48
     f68:	973e                	add	a4,a4,a5
     f6a:	02d00793          	li	a5,45
     f6e:	fef70823          	sb	a5,-16(a4)
     f72:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f76:	02e05863          	blez	a4,fa6 <printint+0x94>
     f7a:	fc040793          	addi	a5,s0,-64
     f7e:	00e78933          	add	s2,a5,a4
     f82:	fff78993          	addi	s3,a5,-1
     f86:	99ba                	add	s3,s3,a4
     f88:	377d                	addiw	a4,a4,-1
     f8a:	1702                	slli	a4,a4,0x20
     f8c:	9301                	srli	a4,a4,0x20
     f8e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     f92:	fff94583          	lbu	a1,-1(s2)
     f96:	8526                	mv	a0,s1
     f98:	00000097          	auipc	ra,0x0
     f9c:	f58080e7          	jalr	-168(ra) # ef0 <putc>
  while(--i >= 0)
     fa0:	197d                	addi	s2,s2,-1
     fa2:	ff3918e3          	bne	s2,s3,f92 <printint+0x80>
}
     fa6:	70e2                	ld	ra,56(sp)
     fa8:	7442                	ld	s0,48(sp)
     faa:	74a2                	ld	s1,40(sp)
     fac:	7902                	ld	s2,32(sp)
     fae:	69e2                	ld	s3,24(sp)
     fb0:	6121                	addi	sp,sp,64
     fb2:	8082                	ret
    x = -xx;
     fb4:	40b005bb          	negw	a1,a1
    neg = 1;
     fb8:	4885                	li	a7,1
    x = -xx;
     fba:	bf8d                	j	f2c <printint+0x1a>

0000000000000fbc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fbc:	7119                	addi	sp,sp,-128
     fbe:	fc86                	sd	ra,120(sp)
     fc0:	f8a2                	sd	s0,112(sp)
     fc2:	f4a6                	sd	s1,104(sp)
     fc4:	f0ca                	sd	s2,96(sp)
     fc6:	ecce                	sd	s3,88(sp)
     fc8:	e8d2                	sd	s4,80(sp)
     fca:	e4d6                	sd	s5,72(sp)
     fcc:	e0da                	sd	s6,64(sp)
     fce:	fc5e                	sd	s7,56(sp)
     fd0:	f862                	sd	s8,48(sp)
     fd2:	f466                	sd	s9,40(sp)
     fd4:	f06a                	sd	s10,32(sp)
     fd6:	ec6e                	sd	s11,24(sp)
     fd8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     fda:	0005c903          	lbu	s2,0(a1)
     fde:	18090f63          	beqz	s2,117c <vprintf+0x1c0>
     fe2:	8aaa                	mv	s5,a0
     fe4:	8b32                	mv	s6,a2
     fe6:	00158493          	addi	s1,a1,1
  state = 0;
     fea:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     fec:	02500a13          	li	s4,37
      if(c == 'd'){
     ff0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     ff4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     ff8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     ffc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1000:	00000b97          	auipc	s7,0x0
    1004:	4d0b8b93          	addi	s7,s7,1232 # 14d0 <digits>
    1008:	a839                	j	1026 <vprintf+0x6a>
        putc(fd, c);
    100a:	85ca                	mv	a1,s2
    100c:	8556                	mv	a0,s5
    100e:	00000097          	auipc	ra,0x0
    1012:	ee2080e7          	jalr	-286(ra) # ef0 <putc>
    1016:	a019                	j	101c <vprintf+0x60>
    } else if(state == '%'){
    1018:	01498f63          	beq	s3,s4,1036 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    101c:	0485                	addi	s1,s1,1
    101e:	fff4c903          	lbu	s2,-1(s1)
    1022:	14090d63          	beqz	s2,117c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1026:	0009079b          	sext.w	a5,s2
    if(state == 0){
    102a:	fe0997e3          	bnez	s3,1018 <vprintf+0x5c>
      if(c == '%'){
    102e:	fd479ee3          	bne	a5,s4,100a <vprintf+0x4e>
        state = '%';
    1032:	89be                	mv	s3,a5
    1034:	b7e5                	j	101c <vprintf+0x60>
      if(c == 'd'){
    1036:	05878063          	beq	a5,s8,1076 <vprintf+0xba>
      } else if(c == 'l') {
    103a:	05978c63          	beq	a5,s9,1092 <vprintf+0xd6>
      } else if(c == 'x') {
    103e:	07a78863          	beq	a5,s10,10ae <vprintf+0xf2>
      } else if(c == 'p') {
    1042:	09b78463          	beq	a5,s11,10ca <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1046:	07300713          	li	a4,115
    104a:	0ce78663          	beq	a5,a4,1116 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    104e:	06300713          	li	a4,99
    1052:	0ee78e63          	beq	a5,a4,114e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    1056:	11478863          	beq	a5,s4,1166 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    105a:	85d2                	mv	a1,s4
    105c:	8556                	mv	a0,s5
    105e:	00000097          	auipc	ra,0x0
    1062:	e92080e7          	jalr	-366(ra) # ef0 <putc>
        putc(fd, c);
    1066:	85ca                	mv	a1,s2
    1068:	8556                	mv	a0,s5
    106a:	00000097          	auipc	ra,0x0
    106e:	e86080e7          	jalr	-378(ra) # ef0 <putc>
      }
      state = 0;
    1072:	4981                	li	s3,0
    1074:	b765                	j	101c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    1076:	008b0913          	addi	s2,s6,8
    107a:	4685                	li	a3,1
    107c:	4629                	li	a2,10
    107e:	000b2583          	lw	a1,0(s6)
    1082:	8556                	mv	a0,s5
    1084:	00000097          	auipc	ra,0x0
    1088:	e8e080e7          	jalr	-370(ra) # f12 <printint>
    108c:	8b4a                	mv	s6,s2
      state = 0;
    108e:	4981                	li	s3,0
    1090:	b771                	j	101c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1092:	008b0913          	addi	s2,s6,8
    1096:	4681                	li	a3,0
    1098:	4629                	li	a2,10
    109a:	000b2583          	lw	a1,0(s6)
    109e:	8556                	mv	a0,s5
    10a0:	00000097          	auipc	ra,0x0
    10a4:	e72080e7          	jalr	-398(ra) # f12 <printint>
    10a8:	8b4a                	mv	s6,s2
      state = 0;
    10aa:	4981                	li	s3,0
    10ac:	bf85                	j	101c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    10ae:	008b0913          	addi	s2,s6,8
    10b2:	4681                	li	a3,0
    10b4:	4641                	li	a2,16
    10b6:	000b2583          	lw	a1,0(s6)
    10ba:	8556                	mv	a0,s5
    10bc:	00000097          	auipc	ra,0x0
    10c0:	e56080e7          	jalr	-426(ra) # f12 <printint>
    10c4:	8b4a                	mv	s6,s2
      state = 0;
    10c6:	4981                	li	s3,0
    10c8:	bf91                	j	101c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    10ca:	008b0793          	addi	a5,s6,8
    10ce:	f8f43423          	sd	a5,-120(s0)
    10d2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    10d6:	03000593          	li	a1,48
    10da:	8556                	mv	a0,s5
    10dc:	00000097          	auipc	ra,0x0
    10e0:	e14080e7          	jalr	-492(ra) # ef0 <putc>
  putc(fd, 'x');
    10e4:	85ea                	mv	a1,s10
    10e6:	8556                	mv	a0,s5
    10e8:	00000097          	auipc	ra,0x0
    10ec:	e08080e7          	jalr	-504(ra) # ef0 <putc>
    10f0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10f2:	03c9d793          	srli	a5,s3,0x3c
    10f6:	97de                	add	a5,a5,s7
    10f8:	0007c583          	lbu	a1,0(a5)
    10fc:	8556                	mv	a0,s5
    10fe:	00000097          	auipc	ra,0x0
    1102:	df2080e7          	jalr	-526(ra) # ef0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1106:	0992                	slli	s3,s3,0x4
    1108:	397d                	addiw	s2,s2,-1
    110a:	fe0914e3          	bnez	s2,10f2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    110e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1112:	4981                	li	s3,0
    1114:	b721                	j	101c <vprintf+0x60>
        s = va_arg(ap, char*);
    1116:	008b0993          	addi	s3,s6,8
    111a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    111e:	02090163          	beqz	s2,1140 <vprintf+0x184>
        while(*s != 0){
    1122:	00094583          	lbu	a1,0(s2)
    1126:	c9a1                	beqz	a1,1176 <vprintf+0x1ba>
          putc(fd, *s);
    1128:	8556                	mv	a0,s5
    112a:	00000097          	auipc	ra,0x0
    112e:	dc6080e7          	jalr	-570(ra) # ef0 <putc>
          s++;
    1132:	0905                	addi	s2,s2,1
        while(*s != 0){
    1134:	00094583          	lbu	a1,0(s2)
    1138:	f9e5                	bnez	a1,1128 <vprintf+0x16c>
        s = va_arg(ap, char*);
    113a:	8b4e                	mv	s6,s3
      state = 0;
    113c:	4981                	li	s3,0
    113e:	bdf9                	j	101c <vprintf+0x60>
          s = "(null)";
    1140:	00000917          	auipc	s2,0x0
    1144:	38890913          	addi	s2,s2,904 # 14c8 <malloc+0x242>
        while(*s != 0){
    1148:	02800593          	li	a1,40
    114c:	bff1                	j	1128 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    114e:	008b0913          	addi	s2,s6,8
    1152:	000b4583          	lbu	a1,0(s6)
    1156:	8556                	mv	a0,s5
    1158:	00000097          	auipc	ra,0x0
    115c:	d98080e7          	jalr	-616(ra) # ef0 <putc>
    1160:	8b4a                	mv	s6,s2
      state = 0;
    1162:	4981                	li	s3,0
    1164:	bd65                	j	101c <vprintf+0x60>
        putc(fd, c);
    1166:	85d2                	mv	a1,s4
    1168:	8556                	mv	a0,s5
    116a:	00000097          	auipc	ra,0x0
    116e:	d86080e7          	jalr	-634(ra) # ef0 <putc>
      state = 0;
    1172:	4981                	li	s3,0
    1174:	b565                	j	101c <vprintf+0x60>
        s = va_arg(ap, char*);
    1176:	8b4e                	mv	s6,s3
      state = 0;
    1178:	4981                	li	s3,0
    117a:	b54d                	j	101c <vprintf+0x60>
    }
  }
}
    117c:	70e6                	ld	ra,120(sp)
    117e:	7446                	ld	s0,112(sp)
    1180:	74a6                	ld	s1,104(sp)
    1182:	7906                	ld	s2,96(sp)
    1184:	69e6                	ld	s3,88(sp)
    1186:	6a46                	ld	s4,80(sp)
    1188:	6aa6                	ld	s5,72(sp)
    118a:	6b06                	ld	s6,64(sp)
    118c:	7be2                	ld	s7,56(sp)
    118e:	7c42                	ld	s8,48(sp)
    1190:	7ca2                	ld	s9,40(sp)
    1192:	7d02                	ld	s10,32(sp)
    1194:	6de2                	ld	s11,24(sp)
    1196:	6109                	addi	sp,sp,128
    1198:	8082                	ret

000000000000119a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    119a:	715d                	addi	sp,sp,-80
    119c:	ec06                	sd	ra,24(sp)
    119e:	e822                	sd	s0,16(sp)
    11a0:	1000                	addi	s0,sp,32
    11a2:	e010                	sd	a2,0(s0)
    11a4:	e414                	sd	a3,8(s0)
    11a6:	e818                	sd	a4,16(s0)
    11a8:	ec1c                	sd	a5,24(s0)
    11aa:	03043023          	sd	a6,32(s0)
    11ae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11b2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    11b6:	8622                	mv	a2,s0
    11b8:	00000097          	auipc	ra,0x0
    11bc:	e04080e7          	jalr	-508(ra) # fbc <vprintf>
}
    11c0:	60e2                	ld	ra,24(sp)
    11c2:	6442                	ld	s0,16(sp)
    11c4:	6161                	addi	sp,sp,80
    11c6:	8082                	ret

00000000000011c8 <printf>:

void
printf(const char *fmt, ...)
{
    11c8:	711d                	addi	sp,sp,-96
    11ca:	ec06                	sd	ra,24(sp)
    11cc:	e822                	sd	s0,16(sp)
    11ce:	1000                	addi	s0,sp,32
    11d0:	e40c                	sd	a1,8(s0)
    11d2:	e810                	sd	a2,16(s0)
    11d4:	ec14                	sd	a3,24(s0)
    11d6:	f018                	sd	a4,32(s0)
    11d8:	f41c                	sd	a5,40(s0)
    11da:	03043823          	sd	a6,48(s0)
    11de:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11e2:	00840613          	addi	a2,s0,8
    11e6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11ea:	85aa                	mv	a1,a0
    11ec:	4505                	li	a0,1
    11ee:	00000097          	auipc	ra,0x0
    11f2:	dce080e7          	jalr	-562(ra) # fbc <vprintf>
}
    11f6:	60e2                	ld	ra,24(sp)
    11f8:	6442                	ld	s0,16(sp)
    11fa:	6125                	addi	sp,sp,96
    11fc:	8082                	ret

00000000000011fe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    11fe:	1141                	addi	sp,sp,-16
    1200:	e422                	sd	s0,8(sp)
    1202:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1204:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1208:	00001797          	auipc	a5,0x1
    120c:	e087b783          	ld	a5,-504(a5) # 2010 <freep>
    1210:	a805                	j	1240 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1212:	4618                	lw	a4,8(a2)
    1214:	9db9                	addw	a1,a1,a4
    1216:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    121a:	6398                	ld	a4,0(a5)
    121c:	6318                	ld	a4,0(a4)
    121e:	fee53823          	sd	a4,-16(a0)
    1222:	a091                	j	1266 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1224:	ff852703          	lw	a4,-8(a0)
    1228:	9e39                	addw	a2,a2,a4
    122a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    122c:	ff053703          	ld	a4,-16(a0)
    1230:	e398                	sd	a4,0(a5)
    1232:	a099                	j	1278 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1234:	6398                	ld	a4,0(a5)
    1236:	00e7e463          	bltu	a5,a4,123e <free+0x40>
    123a:	00e6ea63          	bltu	a3,a4,124e <free+0x50>
{
    123e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1240:	fed7fae3          	bgeu	a5,a3,1234 <free+0x36>
    1244:	6398                	ld	a4,0(a5)
    1246:	00e6e463          	bltu	a3,a4,124e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    124a:	fee7eae3          	bltu	a5,a4,123e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    124e:	ff852583          	lw	a1,-8(a0)
    1252:	6390                	ld	a2,0(a5)
    1254:	02059713          	slli	a4,a1,0x20
    1258:	9301                	srli	a4,a4,0x20
    125a:	0712                	slli	a4,a4,0x4
    125c:	9736                	add	a4,a4,a3
    125e:	fae60ae3          	beq	a2,a4,1212 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1262:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1266:	4790                	lw	a2,8(a5)
    1268:	02061713          	slli	a4,a2,0x20
    126c:	9301                	srli	a4,a4,0x20
    126e:	0712                	slli	a4,a4,0x4
    1270:	973e                	add	a4,a4,a5
    1272:	fae689e3          	beq	a3,a4,1224 <free+0x26>
  } else
    p->s.ptr = bp;
    1276:	e394                	sd	a3,0(a5)
  freep = p;
    1278:	00001717          	auipc	a4,0x1
    127c:	d8f73c23          	sd	a5,-616(a4) # 2010 <freep>
}
    1280:	6422                	ld	s0,8(sp)
    1282:	0141                	addi	sp,sp,16
    1284:	8082                	ret

0000000000001286 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1286:	7139                	addi	sp,sp,-64
    1288:	fc06                	sd	ra,56(sp)
    128a:	f822                	sd	s0,48(sp)
    128c:	f426                	sd	s1,40(sp)
    128e:	f04a                	sd	s2,32(sp)
    1290:	ec4e                	sd	s3,24(sp)
    1292:	e852                	sd	s4,16(sp)
    1294:	e456                	sd	s5,8(sp)
    1296:	e05a                	sd	s6,0(sp)
    1298:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    129a:	02051493          	slli	s1,a0,0x20
    129e:	9081                	srli	s1,s1,0x20
    12a0:	04bd                	addi	s1,s1,15
    12a2:	8091                	srli	s1,s1,0x4
    12a4:	0014899b          	addiw	s3,s1,1
    12a8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12aa:	00001517          	auipc	a0,0x1
    12ae:	d6653503          	ld	a0,-666(a0) # 2010 <freep>
    12b2:	c515                	beqz	a0,12de <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12b6:	4798                	lw	a4,8(a5)
    12b8:	02977f63          	bgeu	a4,s1,12f6 <malloc+0x70>
    12bc:	8a4e                	mv	s4,s3
    12be:	0009871b          	sext.w	a4,s3
    12c2:	6685                	lui	a3,0x1
    12c4:	00d77363          	bgeu	a4,a3,12ca <malloc+0x44>
    12c8:	6a05                	lui	s4,0x1
    12ca:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    12ce:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    12d2:	00001917          	auipc	s2,0x1
    12d6:	d3e90913          	addi	s2,s2,-706 # 2010 <freep>
  if(p == (char*)-1)
    12da:	5afd                	li	s5,-1
    12dc:	a88d                	j	134e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    12de:	00001797          	auipc	a5,0x1
    12e2:	daa78793          	addi	a5,a5,-598 # 2088 <base>
    12e6:	00001717          	auipc	a4,0x1
    12ea:	d2f73523          	sd	a5,-726(a4) # 2010 <freep>
    12ee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    12f0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    12f4:	b7e1                	j	12bc <malloc+0x36>
      if(p->s.size == nunits)
    12f6:	02e48b63          	beq	s1,a4,132c <malloc+0xa6>
        p->s.size -= nunits;
    12fa:	4137073b          	subw	a4,a4,s3
    12fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1300:	1702                	slli	a4,a4,0x20
    1302:	9301                	srli	a4,a4,0x20
    1304:	0712                	slli	a4,a4,0x4
    1306:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1308:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    130c:	00001717          	auipc	a4,0x1
    1310:	d0a73223          	sd	a0,-764(a4) # 2010 <freep>
      return (void*)(p + 1);
    1314:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1318:	70e2                	ld	ra,56(sp)
    131a:	7442                	ld	s0,48(sp)
    131c:	74a2                	ld	s1,40(sp)
    131e:	7902                	ld	s2,32(sp)
    1320:	69e2                	ld	s3,24(sp)
    1322:	6a42                	ld	s4,16(sp)
    1324:	6aa2                	ld	s5,8(sp)
    1326:	6b02                	ld	s6,0(sp)
    1328:	6121                	addi	sp,sp,64
    132a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    132c:	6398                	ld	a4,0(a5)
    132e:	e118                	sd	a4,0(a0)
    1330:	bff1                	j	130c <malloc+0x86>
  hp->s.size = nu;
    1332:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1336:	0541                	addi	a0,a0,16
    1338:	00000097          	auipc	ra,0x0
    133c:	ec6080e7          	jalr	-314(ra) # 11fe <free>
  return freep;
    1340:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1344:	d971                	beqz	a0,1318 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1346:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1348:	4798                	lw	a4,8(a5)
    134a:	fa9776e3          	bgeu	a4,s1,12f6 <malloc+0x70>
    if(p == freep)
    134e:	00093703          	ld	a4,0(s2)
    1352:	853e                	mv	a0,a5
    1354:	fef719e3          	bne	a4,a5,1346 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    1358:	8552                	mv	a0,s4
    135a:	00000097          	auipc	ra,0x0
    135e:	b5e080e7          	jalr	-1186(ra) # eb8 <sbrk>
  if(p == (char*)-1)
    1362:	fd5518e3          	bne	a0,s5,1332 <malloc+0xac>
        return 0;
    1366:	4501                	li	a0,0
    1368:	bf45                	j	1318 <malloc+0x92>
