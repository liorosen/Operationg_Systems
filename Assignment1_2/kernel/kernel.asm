
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c2010113          	addi	sp,sp,-992 # 80008c20 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	a8e70713          	addi	a4,a4,-1394 # 80008ae0 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	10c78793          	addi	a5,a5,268 # 80006170 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc0af>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de678793          	addi	a5,a5,-538 # 80000e94 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	47c080e7          	jalr	1148(ra) # 800025a8 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	794080e7          	jalr	1940(ra) # 800008d0 <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	a9450513          	addi	a0,a0,-1388 # 80010c20 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	a8448493          	addi	s1,s1,-1404 # 80010c20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	b1290913          	addi	s2,s2,-1262 # 80010cb8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405b63          	blez	s4,8000022a <consoleread+0xc6>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71763          	bne	a4,a5,800001ee <consoleread+0x8a>
      if(killed(myproc())){
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	802080e7          	jalr	-2046(ra) # 800019c6 <myproc>
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	1c0080e7          	jalr	448(ra) # 8000238c <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	e90080e7          	jalr	-368(ra) # 8000206a <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fcf70de3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000204:	079c0663          	beq	s8,s9,80000270 <consoleread+0x10c>
    cbuf = c;
    80000208:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f8f40613          	addi	a2,s0,-113
    80000212:	85d6                	mv	a1,s5
    80000214:	855a                	mv	a0,s6
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	33c080e7          	jalr	828(ra) # 80002552 <either_copyout>
    8000021e:	01a50663          	beq	a0,s10,8000022a <consoleread+0xc6>
    dst++;
    80000222:	0a85                	addi	s5,s5,1
    --n;
    80000224:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000226:	f9bc17e3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	9f650513          	addi	a0,a0,-1546 # 80010c20 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	9e050513          	addi	a0,a0,-1568 # 80010c20 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	a56080e7          	jalr	-1450(ra) # 80000c9e <release>
        return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70e6                	ld	ra,120(sp)
    80000254:	7446                	ld	s0,112(sp)
    80000256:	74a6                	ld	s1,104(sp)
    80000258:	7906                	ld	s2,96(sp)
    8000025a:	69e6                	ld	s3,88(sp)
    8000025c:	6a46                	ld	s4,80(sp)
    8000025e:	6aa6                	ld	s5,72(sp)
    80000260:	6b06                	ld	s6,64(sp)
    80000262:	7be2                	ld	s7,56(sp)
    80000264:	7c42                	ld	s8,48(sp)
    80000266:	7ca2                	ld	s9,40(sp)
    80000268:	7d02                	ld	s10,32(sp)
    8000026a:	6de2                	ld	s11,24(sp)
    8000026c:	6109                	addi	sp,sp,128
    8000026e:	8082                	ret
      if(n < target){
    80000270:	000a071b          	sext.w	a4,s4
    80000274:	fb777be3          	bgeu	a4,s7,8000022a <consoleread+0xc6>
        cons.r--;
    80000278:	00011717          	auipc	a4,0x11
    8000027c:	a4f72023          	sw	a5,-1472(a4) # 80010cb8 <cons+0x98>
    80000280:	b76d                	j	8000022a <consoleread+0xc6>

0000000080000282 <consputc>:
{
    80000282:	1141                	addi	sp,sp,-16
    80000284:	e406                	sd	ra,8(sp)
    80000286:	e022                	sd	s0,0(sp)
    80000288:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028a:	10000793          	li	a5,256
    8000028e:	00f50a63          	beq	a0,a5,800002a2 <consputc+0x20>
    uartputc_sync(c);
    80000292:	00000097          	auipc	ra,0x0
    80000296:	564080e7          	jalr	1380(ra) # 800007f6 <uartputc_sync>
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a2:	4521                	li	a0,8
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	552080e7          	jalr	1362(ra) # 800007f6 <uartputc_sync>
    800002ac:	02000513          	li	a0,32
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	546080e7          	jalr	1350(ra) # 800007f6 <uartputc_sync>
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	53c080e7          	jalr	1340(ra) # 800007f6 <uartputc_sync>
    800002c2:	bfe1                	j	8000029a <consputc+0x18>

00000000800002c4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c4:	1101                	addi	sp,sp,-32
    800002c6:	ec06                	sd	ra,24(sp)
    800002c8:	e822                	sd	s0,16(sp)
    800002ca:	e426                	sd	s1,8(sp)
    800002cc:	e04a                	sd	s2,0(sp)
    800002ce:	1000                	addi	s0,sp,32
    800002d0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d2:	00011517          	auipc	a0,0x11
    800002d6:	94e50513          	addi	a0,a0,-1714 # 80010c20 <cons>
    800002da:	00001097          	auipc	ra,0x1
    800002de:	910080e7          	jalr	-1776(ra) # 80000bea <acquire>

  switch(c){
    800002e2:	47d5                	li	a5,21
    800002e4:	0af48663          	beq	s1,a5,80000390 <consoleintr+0xcc>
    800002e8:	0297ca63          	blt	a5,s1,8000031c <consoleintr+0x58>
    800002ec:	47a1                	li	a5,8
    800002ee:	0ef48763          	beq	s1,a5,800003dc <consoleintr+0x118>
    800002f2:	47c1                	li	a5,16
    800002f4:	10f49a63          	bne	s1,a5,80000408 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f8:	00002097          	auipc	ra,0x2
    800002fc:	306080e7          	jalr	774(ra) # 800025fe <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	92050513          	addi	a0,a0,-1760 # 80010c20 <cons>
    80000308:	00001097          	auipc	ra,0x1
    8000030c:	996080e7          	jalr	-1642(ra) # 80000c9e <release>
}
    80000310:	60e2                	ld	ra,24(sp)
    80000312:	6442                	ld	s0,16(sp)
    80000314:	64a2                	ld	s1,8(sp)
    80000316:	6902                	ld	s2,0(sp)
    80000318:	6105                	addi	sp,sp,32
    8000031a:	8082                	ret
  switch(c){
    8000031c:	07f00793          	li	a5,127
    80000320:	0af48e63          	beq	s1,a5,800003dc <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000324:	00011717          	auipc	a4,0x11
    80000328:	8fc70713          	addi	a4,a4,-1796 # 80010c20 <cons>
    8000032c:	0a072783          	lw	a5,160(a4)
    80000330:	09872703          	lw	a4,152(a4)
    80000334:	9f99                	subw	a5,a5,a4
    80000336:	07f00713          	li	a4,127
    8000033a:	fcf763e3          	bltu	a4,a5,80000300 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033e:	47b5                	li	a5,13
    80000340:	0cf48763          	beq	s1,a5,8000040e <consoleintr+0x14a>
      consputc(c);
    80000344:	8526                	mv	a0,s1
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	f3c080e7          	jalr	-196(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000034e:	00011797          	auipc	a5,0x11
    80000352:	8d278793          	addi	a5,a5,-1838 # 80010c20 <cons>
    80000356:	0a07a683          	lw	a3,160(a5)
    8000035a:	0016871b          	addiw	a4,a3,1
    8000035e:	0007061b          	sext.w	a2,a4
    80000362:	0ae7a023          	sw	a4,160(a5)
    80000366:	07f6f693          	andi	a3,a3,127
    8000036a:	97b6                	add	a5,a5,a3
    8000036c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000370:	47a9                	li	a5,10
    80000372:	0cf48563          	beq	s1,a5,8000043c <consoleintr+0x178>
    80000376:	4791                	li	a5,4
    80000378:	0cf48263          	beq	s1,a5,8000043c <consoleintr+0x178>
    8000037c:	00011797          	auipc	a5,0x11
    80000380:	93c7a783          	lw	a5,-1732(a5) # 80010cb8 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	89070713          	addi	a4,a4,-1904 # 80010c20 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	88048493          	addi	s1,s1,-1920 # 80010c20 <cons>
    while(cons.e != cons.w &&
    800003a8:	4929                	li	s2,10
    800003aa:	f4f70be3          	beq	a4,a5,80000300 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003ae:	37fd                	addiw	a5,a5,-1
    800003b0:	07f7f713          	andi	a4,a5,127
    800003b4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b6:	01874703          	lbu	a4,24(a4)
    800003ba:	f52703e3          	beq	a4,s2,80000300 <consoleintr+0x3c>
      cons.e--;
    800003be:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c2:	10000513          	li	a0,256
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	ebc080e7          	jalr	-324(ra) # 80000282 <consputc>
    while(cons.e != cons.w &&
    800003ce:	0a04a783          	lw	a5,160(s1)
    800003d2:	09c4a703          	lw	a4,156(s1)
    800003d6:	fcf71ce3          	bne	a4,a5,800003ae <consoleintr+0xea>
    800003da:	b71d                	j	80000300 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003dc:	00011717          	auipc	a4,0x11
    800003e0:	84470713          	addi	a4,a4,-1980 # 80010c20 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	8cf72723          	sw	a5,-1842(a4) # 80010cc0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fa:	10000513          	li	a0,256
    800003fe:	00000097          	auipc	ra,0x0
    80000402:	e84080e7          	jalr	-380(ra) # 80000282 <consputc>
    80000406:	bded                	j	80000300 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000408:	ee048ce3          	beqz	s1,80000300 <consoleintr+0x3c>
    8000040c:	bf21                	j	80000324 <consoleintr+0x60>
      consputc(c);
    8000040e:	4529                	li	a0,10
    80000410:	00000097          	auipc	ra,0x0
    80000414:	e72080e7          	jalr	-398(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000418:	00011797          	auipc	a5,0x11
    8000041c:	80878793          	addi	a5,a5,-2040 # 80010c20 <cons>
    80000420:	0a07a703          	lw	a4,160(a5)
    80000424:	0017069b          	addiw	a3,a4,1
    80000428:	0006861b          	sext.w	a2,a3
    8000042c:	0ad7a023          	sw	a3,160(a5)
    80000430:	07f77713          	andi	a4,a4,127
    80000434:	97ba                	add	a5,a5,a4
    80000436:	4729                	li	a4,10
    80000438:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043c:	00011797          	auipc	a5,0x11
    80000440:	88c7a023          	sw	a2,-1920(a5) # 80010cbc <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	87450513          	addi	a0,a0,-1932 # 80010cb8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	c82080e7          	jalr	-894(ra) # 800020ce <wakeup>
    80000454:	b575                	j	80000300 <consoleintr+0x3c>

0000000080000456 <consoleinit>:

void
consoleinit(void)
{
    80000456:	1141                	addi	sp,sp,-16
    80000458:	e406                	sd	ra,8(sp)
    8000045a:	e022                	sd	s0,0(sp)
    8000045c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00010517          	auipc	a0,0x10
    8000046a:	7ba50513          	addi	a0,a0,1978 # 80010c20 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00021797          	auipc	a5,0x21
    80000482:	13a78793          	addi	a5,a5,314 # 800215b8 <devsw>
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	cde70713          	addi	a4,a4,-802 # 80000164 <consoleread>
    8000048e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c7270713          	addi	a4,a4,-910 # 80000102 <consolewrite>
    80000498:	ef98                	sd	a4,24(a5)
}
    8000049a:	60a2                	ld	ra,8(sp)
    8000049c:	6402                	ld	s0,0(sp)
    8000049e:	0141                	addi	sp,sp,16
    800004a0:	8082                	ret

00000000800004a2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a2:	7179                	addi	sp,sp,-48
    800004a4:	f406                	sd	ra,40(sp)
    800004a6:	f022                	sd	s0,32(sp)
    800004a8:	ec26                	sd	s1,24(sp)
    800004aa:	e84a                	sd	s2,16(sp)
    800004ac:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ae:	c219                	beqz	a2,800004b4 <printint+0x12>
    800004b0:	08054663          	bltz	a0,8000053c <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b4:	2501                	sext.w	a0,a0
    800004b6:	4881                	li	a7,0
    800004b8:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004bc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004be:	2581                	sext.w	a1,a1
    800004c0:	00008617          	auipc	a2,0x8
    800004c4:	b8060613          	addi	a2,a2,-1152 # 80008040 <digits>
    800004c8:	883a                	mv	a6,a4
    800004ca:	2705                	addiw	a4,a4,1
    800004cc:	02b577bb          	remuw	a5,a0,a1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	97b2                	add	a5,a5,a2
    800004d6:	0007c783          	lbu	a5,0(a5)
    800004da:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004de:	0005079b          	sext.w	a5,a0
    800004e2:	02b5553b          	divuw	a0,a0,a1
    800004e6:	0685                	addi	a3,a3,1
    800004e8:	feb7f0e3          	bgeu	a5,a1,800004c8 <printint+0x26>

  if(sign)
    800004ec:	00088b63          	beqz	a7,80000502 <printint+0x60>
    buf[i++] = '-';
    800004f0:	fe040793          	addi	a5,s0,-32
    800004f4:	973e                	add	a4,a4,a5
    800004f6:	02d00793          	li	a5,45
    800004fa:	fef70823          	sb	a5,-16(a4)
    800004fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000502:	02e05763          	blez	a4,80000530 <printint+0x8e>
    80000506:	fd040793          	addi	a5,s0,-48
    8000050a:	00e784b3          	add	s1,a5,a4
    8000050e:	fff78913          	addi	s2,a5,-1
    80000512:	993a                	add	s2,s2,a4
    80000514:	377d                	addiw	a4,a4,-1
    80000516:	1702                	slli	a4,a4,0x20
    80000518:	9301                	srli	a4,a4,0x20
    8000051a:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051e:	fff4c503          	lbu	a0,-1(s1)
    80000522:	00000097          	auipc	ra,0x0
    80000526:	d60080e7          	jalr	-672(ra) # 80000282 <consputc>
  while(--i >= 0)
    8000052a:	14fd                	addi	s1,s1,-1
    8000052c:	ff2499e3          	bne	s1,s2,8000051e <printint+0x7c>
}
    80000530:	70a2                	ld	ra,40(sp)
    80000532:	7402                	ld	s0,32(sp)
    80000534:	64e2                	ld	s1,24(sp)
    80000536:	6942                	ld	s2,16(sp)
    80000538:	6145                	addi	sp,sp,48
    8000053a:	8082                	ret
    x = -xx;
    8000053c:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000540:	4885                	li	a7,1
    x = -xx;
    80000542:	bf9d                	j	800004b8 <printint+0x16>

0000000080000544 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000544:	1101                	addi	sp,sp,-32
    80000546:	ec06                	sd	ra,24(sp)
    80000548:	e822                	sd	s0,16(sp)
    8000054a:	e426                	sd	s1,8(sp)
    8000054c:	1000                	addi	s0,sp,32
    8000054e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000550:	00010797          	auipc	a5,0x10
    80000554:	7807a823          	sw	zero,1936(a5) # 80010ce0 <pr+0x18>
  printf("panic: ");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	ac050513          	addi	a0,a0,-1344 # 80008018 <etext+0x18>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	02e080e7          	jalr	46(ra) # 8000058e <printf>
  printf(s);
    80000568:	8526                	mv	a0,s1
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	024080e7          	jalr	36(ra) # 8000058e <printf>
  printf("\n");
    80000572:	00008517          	auipc	a0,0x8
    80000576:	b5650513          	addi	a0,a0,-1194 # 800080c8 <digits+0x88>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	014080e7          	jalr	20(ra) # 8000058e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000582:	4785                	li	a5,1
    80000584:	00008717          	auipc	a4,0x8
    80000588:	50f72e23          	sw	a5,1308(a4) # 80008aa0 <panicked>
  for(;;)
    8000058c:	a001                	j	8000058c <panic+0x48>

000000008000058e <printf>:
{
    8000058e:	7131                	addi	sp,sp,-192
    80000590:	fc86                	sd	ra,120(sp)
    80000592:	f8a2                	sd	s0,112(sp)
    80000594:	f4a6                	sd	s1,104(sp)
    80000596:	f0ca                	sd	s2,96(sp)
    80000598:	ecce                	sd	s3,88(sp)
    8000059a:	e8d2                	sd	s4,80(sp)
    8000059c:	e4d6                	sd	s5,72(sp)
    8000059e:	e0da                	sd	s6,64(sp)
    800005a0:	fc5e                	sd	s7,56(sp)
    800005a2:	f862                	sd	s8,48(sp)
    800005a4:	f466                	sd	s9,40(sp)
    800005a6:	f06a                	sd	s10,32(sp)
    800005a8:	ec6e                	sd	s11,24(sp)
    800005aa:	0100                	addi	s0,sp,128
    800005ac:	8a2a                	mv	s4,a0
    800005ae:	e40c                	sd	a1,8(s0)
    800005b0:	e810                	sd	a2,16(s0)
    800005b2:	ec14                	sd	a3,24(s0)
    800005b4:	f018                	sd	a4,32(s0)
    800005b6:	f41c                	sd	a5,40(s0)
    800005b8:	03043823          	sd	a6,48(s0)
    800005bc:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c0:	00010d97          	auipc	s11,0x10
    800005c4:	720dad83          	lw	s11,1824(s11) # 80010ce0 <pr+0x18>
  if(locking)
    800005c8:	020d9b63          	bnez	s11,800005fe <printf+0x70>
  if (fmt == 0)
    800005cc:	040a0263          	beqz	s4,80000610 <printf+0x82>
  va_start(ap, fmt);
    800005d0:	00840793          	addi	a5,s0,8
    800005d4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d8:	000a4503          	lbu	a0,0(s4)
    800005dc:	16050263          	beqz	a0,80000740 <printf+0x1b2>
    800005e0:	4481                	li	s1,0
    if(c != '%'){
    800005e2:	02500a93          	li	s5,37
    switch(c){
    800005e6:	07000b13          	li	s6,112
  consputc('x');
    800005ea:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ec:	00008b97          	auipc	s7,0x8
    800005f0:	a54b8b93          	addi	s7,s7,-1452 # 80008040 <digits>
    switch(c){
    800005f4:	07300c93          	li	s9,115
    800005f8:	06400c13          	li	s8,100
    800005fc:	a82d                	j	80000636 <printf+0xa8>
    acquire(&pr.lock);
    800005fe:	00010517          	auipc	a0,0x10
    80000602:	6ca50513          	addi	a0,a0,1738 # 80010cc8 <pr>
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	5e4080e7          	jalr	1508(ra) # 80000bea <acquire>
    8000060e:	bf7d                	j	800005cc <printf+0x3e>
    panic("null fmt");
    80000610:	00008517          	auipc	a0,0x8
    80000614:	a1850513          	addi	a0,a0,-1512 # 80008028 <etext+0x28>
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	f2c080e7          	jalr	-212(ra) # 80000544 <panic>
      consputc(c);
    80000620:	00000097          	auipc	ra,0x0
    80000624:	c62080e7          	jalr	-926(ra) # 80000282 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000628:	2485                	addiw	s1,s1,1
    8000062a:	009a07b3          	add	a5,s4,s1
    8000062e:	0007c503          	lbu	a0,0(a5)
    80000632:	10050763          	beqz	a0,80000740 <printf+0x1b2>
    if(c != '%'){
    80000636:	ff5515e3          	bne	a0,s5,80000620 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063a:	2485                	addiw	s1,s1,1
    8000063c:	009a07b3          	add	a5,s4,s1
    80000640:	0007c783          	lbu	a5,0(a5)
    80000644:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000648:	cfe5                	beqz	a5,80000740 <printf+0x1b2>
    switch(c){
    8000064a:	05678a63          	beq	a5,s6,8000069e <printf+0x110>
    8000064e:	02fb7663          	bgeu	s6,a5,8000067a <printf+0xec>
    80000652:	09978963          	beq	a5,s9,800006e4 <printf+0x156>
    80000656:	07800713          	li	a4,120
    8000065a:	0ce79863          	bne	a5,a4,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4605                	li	a2,1
    8000066c:	85ea                	mv	a1,s10
    8000066e:	4388                	lw	a0,0(a5)
    80000670:	00000097          	auipc	ra,0x0
    80000674:	e32080e7          	jalr	-462(ra) # 800004a2 <printint>
      break;
    80000678:	bf45                	j	80000628 <printf+0x9a>
    switch(c){
    8000067a:	0b578263          	beq	a5,s5,8000071e <printf+0x190>
    8000067e:	0b879663          	bne	a5,s8,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4605                	li	a2,1
    80000690:	45a9                	li	a1,10
    80000692:	4388                	lw	a0,0(a5)
    80000694:	00000097          	auipc	ra,0x0
    80000698:	e0e080e7          	jalr	-498(ra) # 800004a2 <printint>
      break;
    8000069c:	b771                	j	80000628 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ae:	03000513          	li	a0,48
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bd0080e7          	jalr	-1072(ra) # 80000282 <consputc>
  consputc('x');
    800006ba:	07800513          	li	a0,120
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bc4080e7          	jalr	-1084(ra) # 80000282 <consputc>
    800006c6:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c8:	03c9d793          	srli	a5,s3,0x3c
    800006cc:	97de                	add	a5,a5,s7
    800006ce:	0007c503          	lbu	a0,0(a5)
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	bb0080e7          	jalr	-1104(ra) # 80000282 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006da:	0992                	slli	s3,s3,0x4
    800006dc:	397d                	addiw	s2,s2,-1
    800006de:	fe0915e3          	bnez	s2,800006c8 <printf+0x13a>
    800006e2:	b799                	j	80000628 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	0007b903          	ld	s2,0(a5)
    800006f4:	00090e63          	beqz	s2,80000710 <printf+0x182>
      for(; *s; s++)
    800006f8:	00094503          	lbu	a0,0(s2)
    800006fc:	d515                	beqz	a0,80000628 <printf+0x9a>
        consputc(*s);
    800006fe:	00000097          	auipc	ra,0x0
    80000702:	b84080e7          	jalr	-1148(ra) # 80000282 <consputc>
      for(; *s; s++)
    80000706:	0905                	addi	s2,s2,1
    80000708:	00094503          	lbu	a0,0(s2)
    8000070c:	f96d                	bnez	a0,800006fe <printf+0x170>
    8000070e:	bf29                	j	80000628 <printf+0x9a>
        s = "(null)";
    80000710:	00008917          	auipc	s2,0x8
    80000714:	91090913          	addi	s2,s2,-1776 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000718:	02800513          	li	a0,40
    8000071c:	b7cd                	j	800006fe <printf+0x170>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b62080e7          	jalr	-1182(ra) # 80000282 <consputc>
      break;
    80000728:	b701                	j	80000628 <printf+0x9a>
      consputc('%');
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b56080e7          	jalr	-1194(ra) # 80000282 <consputc>
      consputc(c);
    80000734:	854a                	mv	a0,s2
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	b4c080e7          	jalr	-1204(ra) # 80000282 <consputc>
      break;
    8000073e:	b5ed                	j	80000628 <printf+0x9a>
  if(locking)
    80000740:	020d9163          	bnez	s11,80000762 <printf+0x1d4>
}
    80000744:	70e6                	ld	ra,120(sp)
    80000746:	7446                	ld	s0,112(sp)
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	7906                	ld	s2,96(sp)
    8000074c:	69e6                	ld	s3,88(sp)
    8000074e:	6a46                	ld	s4,80(sp)
    80000750:	6aa6                	ld	s5,72(sp)
    80000752:	6b06                	ld	s6,64(sp)
    80000754:	7be2                	ld	s7,56(sp)
    80000756:	7c42                	ld	s8,48(sp)
    80000758:	7ca2                	ld	s9,40(sp)
    8000075a:	7d02                	ld	s10,32(sp)
    8000075c:	6de2                	ld	s11,24(sp)
    8000075e:	6129                	addi	sp,sp,192
    80000760:	8082                	ret
    release(&pr.lock);
    80000762:	00010517          	auipc	a0,0x10
    80000766:	56650513          	addi	a0,a0,1382 # 80010cc8 <pr>
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	534080e7          	jalr	1332(ra) # 80000c9e <release>
}
    80000772:	bfc9                	j	80000744 <printf+0x1b6>

0000000080000774 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000774:	1101                	addi	sp,sp,-32
    80000776:	ec06                	sd	ra,24(sp)
    80000778:	e822                	sd	s0,16(sp)
    8000077a:	e426                	sd	s1,8(sp)
    8000077c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077e:	00010497          	auipc	s1,0x10
    80000782:	54a48493          	addi	s1,s1,1354 # 80010cc8 <pr>
    80000786:	00008597          	auipc	a1,0x8
    8000078a:	8b258593          	addi	a1,a1,-1870 # 80008038 <etext+0x38>
    8000078e:	8526                	mv	a0,s1
    80000790:	00000097          	auipc	ra,0x0
    80000794:	3ca080e7          	jalr	970(ra) # 80000b5a <initlock>
  pr.locking = 1;
    80000798:	4785                	li	a5,1
    8000079a:	cc9c                	sw	a5,24(s1)
}
    8000079c:	60e2                	ld	ra,24(sp)
    8000079e:	6442                	ld	s0,16(sp)
    800007a0:	64a2                	ld	s1,8(sp)
    800007a2:	6105                	addi	sp,sp,32
    800007a4:	8082                	ret

00000000800007a6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a6:	1141                	addi	sp,sp,-16
    800007a8:	e406                	sd	ra,8(sp)
    800007aa:	e022                	sd	s0,0(sp)
    800007ac:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ae:	100007b7          	lui	a5,0x10000
    800007b2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b6:	f8000713          	li	a4,-128
    800007ba:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007be:	470d                	li	a4,3
    800007c0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007cc:	469d                	li	a3,7
    800007ce:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	88258593          	addi	a1,a1,-1918 # 80008058 <digits+0x18>
    800007de:	00010517          	auipc	a0,0x10
    800007e2:	50a50513          	addi	a0,a0,1290 # 80010ce8 <uart_tx_lock>
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	374080e7          	jalr	884(ra) # 80000b5a <initlock>
}
    800007ee:	60a2                	ld	ra,8(sp)
    800007f0:	6402                	ld	s0,0(sp)
    800007f2:	0141                	addi	sp,sp,16
    800007f4:	8082                	ret

00000000800007f6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f6:	1101                	addi	sp,sp,-32
    800007f8:	ec06                	sd	ra,24(sp)
    800007fa:	e822                	sd	s0,16(sp)
    800007fc:	e426                	sd	s1,8(sp)
    800007fe:	1000                	addi	s0,sp,32
    80000800:	84aa                	mv	s1,a0
  push_off();
    80000802:	00000097          	auipc	ra,0x0
    80000806:	39c080e7          	jalr	924(ra) # 80000b9e <push_off>

  if(panicked){
    8000080a:	00008797          	auipc	a5,0x8
    8000080e:	2967a783          	lw	a5,662(a5) # 80008aa0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	10000737          	lui	a4,0x10000
  if(panicked){
    80000816:	c391                	beqz	a5,8000081a <uartputc_sync+0x24>
    for(;;)
    80000818:	a001                	j	80000818 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000081e:	0ff7f793          	andi	a5,a5,255
    80000822:	0207f793          	andi	a5,a5,32
    80000826:	dbf5                	beqz	a5,8000081a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000828:	0ff4f793          	andi	a5,s1,255
    8000082c:	10000737          	lui	a4,0x10000
    80000830:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000834:	00000097          	auipc	ra,0x0
    80000838:	40a080e7          	jalr	1034(ra) # 80000c3e <pop_off>
}
    8000083c:	60e2                	ld	ra,24(sp)
    8000083e:	6442                	ld	s0,16(sp)
    80000840:	64a2                	ld	s1,8(sp)
    80000842:	6105                	addi	sp,sp,32
    80000844:	8082                	ret

0000000080000846 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000846:	00008717          	auipc	a4,0x8
    8000084a:	26273703          	ld	a4,610(a4) # 80008aa8 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	2627b783          	ld	a5,610(a5) # 80008ab0 <uart_tx_w>
    80000856:	06e78c63          	beq	a5,a4,800008ce <uartstart+0x88>
{
    8000085a:	7139                	addi	sp,sp,-64
    8000085c:	fc06                	sd	ra,56(sp)
    8000085e:	f822                	sd	s0,48(sp)
    80000860:	f426                	sd	s1,40(sp)
    80000862:	f04a                	sd	s2,32(sp)
    80000864:	ec4e                	sd	s3,24(sp)
    80000866:	e852                	sd	s4,16(sp)
    80000868:	e456                	sd	s5,8(sp)
    8000086a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000086c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000870:	00010a17          	auipc	s4,0x10
    80000874:	478a0a13          	addi	s4,s4,1144 # 80010ce8 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	23048493          	addi	s1,s1,560 # 80008aa8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	23098993          	addi	s3,s3,560 # 80008ab0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000888:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000088c:	0ff7f793          	andi	a5,a5,255
    80000890:	0207f793          	andi	a5,a5,32
    80000894:	c785                	beqz	a5,800008bc <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f77793          	andi	a5,a4,31
    8000089a:	97d2                	add	a5,a5,s4
    8000089c:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800008a0:	0705                	addi	a4,a4,1
    800008a2:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	828080e7          	jalr	-2008(ra) # 800020ce <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	6098                	ld	a4,0(s1)
    800008b4:	0009b783          	ld	a5,0(s3)
    800008b8:	fce798e3          	bne	a5,a4,80000888 <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	40650513          	addi	a0,a0,1030 # 80010ce8 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	1ae7a783          	lw	a5,430(a5) # 80008aa0 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	1b47b783          	ld	a5,436(a5) # 80008ab0 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	1a473703          	ld	a4,420(a4) # 80008aa8 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	3d8a0a13          	addi	s4,s4,984 # 80010ce8 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	19048493          	addi	s1,s1,400 # 80008aa8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	19090913          	addi	s2,s2,400 # 80008ab0 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00001097          	auipc	ra,0x1
    80000934:	73a080e7          	jalr	1850(ra) # 8000206a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	3a248493          	addi	s1,s1,930 # 80010ce8 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	14f73b23          	sd	a5,342(a4) # 80008ab0 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee4080e7          	jalr	-284(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	332080e7          	jalr	818(ra) # 80000c9e <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb91                	beqz	a5,800009aa <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009a0:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009a4:	6422                	ld	s0,8(sp)
    800009a6:	0141                	addi	sp,sp,16
    800009a8:	8082                	ret
    return -1;
    800009aa:	557d                	li	a0,-1
    800009ac:	bfe5                	j	800009a4 <uartgetc+0x1e>

00000000800009ae <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ae:	1101                	addi	sp,sp,-32
    800009b0:	ec06                	sd	ra,24(sp)
    800009b2:	e822                	sd	s0,16(sp)
    800009b4:	e426                	sd	s1,8(sp)
    800009b6:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b8:	54fd                	li	s1,-1
    int c = uartgetc();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	fcc080e7          	jalr	-52(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c2:	00950763          	beq	a0,s1,800009d0 <uartintr+0x22>
      break;
    consoleintr(c);
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	8fe080e7          	jalr	-1794(ra) # 800002c4 <consoleintr>
  while(1){
    800009ce:	b7f5                	j	800009ba <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009d0:	00010497          	auipc	s1,0x10
    800009d4:	31848493          	addi	s1,s1,792 # 80010ce8 <uart_tx_lock>
    800009d8:	8526                	mv	a0,s1
    800009da:	00000097          	auipc	ra,0x0
    800009de:	210080e7          	jalr	528(ra) # 80000bea <acquire>
  uartstart();
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	e64080e7          	jalr	-412(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    800009ea:	8526                	mv	a0,s1
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	2b2080e7          	jalr	690(ra) # 80000c9e <release>
}
    800009f4:	60e2                	ld	ra,24(sp)
    800009f6:	6442                	ld	s0,16(sp)
    800009f8:	64a2                	ld	s1,8(sp)
    800009fa:	6105                	addi	sp,sp,32
    800009fc:	8082                	ret

00000000800009fe <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009fe:	1101                	addi	sp,sp,-32
    80000a00:	ec06                	sd	ra,24(sp)
    80000a02:	e822                	sd	s0,16(sp)
    80000a04:	e426                	sd	s1,8(sp)
    80000a06:	e04a                	sd	s2,0(sp)
    80000a08:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a0a:	03451793          	slli	a5,a0,0x34
    80000a0e:	ebb9                	bnez	a5,80000a64 <kfree+0x66>
    80000a10:	84aa                	mv	s1,a0
    80000a12:	00022797          	auipc	a5,0x22
    80000a16:	d3e78793          	addi	a5,a5,-706 # 80022750 <end>
    80000a1a:	04f56563          	bltu	a0,a5,80000a64 <kfree+0x66>
    80000a1e:	47c5                	li	a5,17
    80000a20:	07ee                	slli	a5,a5,0x1b
    80000a22:	04f57163          	bgeu	a0,a5,80000a64 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a26:	6605                	lui	a2,0x1
    80000a28:	4585                	li	a1,1
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	2bc080e7          	jalr	700(ra) # 80000ce6 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a32:	00010917          	auipc	s2,0x10
    80000a36:	2ee90913          	addi	s2,s2,750 # 80010d20 <kmem>
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	1ae080e7          	jalr	430(ra) # 80000bea <acquire>
  r->next = kmem.freelist;
    80000a44:	01893783          	ld	a5,24(s2)
    80000a48:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a4a:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	24e080e7          	jalr	590(ra) # 80000c9e <release>
}
    80000a58:	60e2                	ld	ra,24(sp)
    80000a5a:	6442                	ld	s0,16(sp)
    80000a5c:	64a2                	ld	s1,8(sp)
    80000a5e:	6902                	ld	s2,0(sp)
    80000a60:	6105                	addi	sp,sp,32
    80000a62:	8082                	ret
    panic("kfree");
    80000a64:	00007517          	auipc	a0,0x7
    80000a68:	5fc50513          	addi	a0,a0,1532 # 80008060 <digits+0x20>
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	ad8080e7          	jalr	-1320(ra) # 80000544 <panic>

0000000080000a74 <freerange>:
{
    80000a74:	7179                	addi	sp,sp,-48
    80000a76:	f406                	sd	ra,40(sp)
    80000a78:	f022                	sd	s0,32(sp)
    80000a7a:	ec26                	sd	s1,24(sp)
    80000a7c:	e84a                	sd	s2,16(sp)
    80000a7e:	e44e                	sd	s3,8(sp)
    80000a80:	e052                	sd	s4,0(sp)
    80000a82:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a84:	6785                	lui	a5,0x1
    80000a86:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a8a:	94aa                	add	s1,s1,a0
    80000a8c:	757d                	lui	a0,0xfffff
    80000a8e:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94be                	add	s1,s1,a5
    80000a92:	0095ee63          	bltu	a1,s1,80000aae <freerange+0x3a>
    80000a96:	892e                	mv	s2,a1
    kfree(p);
    80000a98:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	6985                	lui	s3,0x1
    kfree(p);
    80000a9c:	01448533          	add	a0,s1,s4
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	f5e080e7          	jalr	-162(ra) # 800009fe <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa8:	94ce                	add	s1,s1,s3
    80000aaa:	fe9979e3          	bgeu	s2,s1,80000a9c <freerange+0x28>
}
    80000aae:	70a2                	ld	ra,40(sp)
    80000ab0:	7402                	ld	s0,32(sp)
    80000ab2:	64e2                	ld	s1,24(sp)
    80000ab4:	6942                	ld	s2,16(sp)
    80000ab6:	69a2                	ld	s3,8(sp)
    80000ab8:	6a02                	ld	s4,0(sp)
    80000aba:	6145                	addi	sp,sp,48
    80000abc:	8082                	ret

0000000080000abe <kinit>:
{
    80000abe:	1141                	addi	sp,sp,-16
    80000ac0:	e406                	sd	ra,8(sp)
    80000ac2:	e022                	sd	s0,0(sp)
    80000ac4:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac6:	00007597          	auipc	a1,0x7
    80000aca:	5a258593          	addi	a1,a1,1442 # 80008068 <digits+0x28>
    80000ace:	00010517          	auipc	a0,0x10
    80000ad2:	25250513          	addi	a0,a0,594 # 80010d20 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00022517          	auipc	a0,0x22
    80000ae6:	c6e50513          	addi	a0,a0,-914 # 80022750 <end>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	f8a080e7          	jalr	-118(ra) # 80000a74 <freerange>
}
    80000af2:	60a2                	ld	ra,8(sp)
    80000af4:	6402                	ld	s0,0(sp)
    80000af6:	0141                	addi	sp,sp,16
    80000af8:	8082                	ret

0000000080000afa <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afa:	1101                	addi	sp,sp,-32
    80000afc:	ec06                	sd	ra,24(sp)
    80000afe:	e822                	sd	s0,16(sp)
    80000b00:	e426                	sd	s1,8(sp)
    80000b02:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b04:	00010497          	auipc	s1,0x10
    80000b08:	21c48493          	addi	s1,s1,540 # 80010d20 <kmem>
    80000b0c:	8526                	mv	a0,s1
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	0dc080e7          	jalr	220(ra) # 80000bea <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c885                	beqz	s1,80000b48 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00010517          	auipc	a0,0x10
    80000b20:	20450513          	addi	a0,a0,516 # 80010d20 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	178080e7          	jalr	376(ra) # 80000c9e <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2e:	6605                	lui	a2,0x1
    80000b30:	4595                	li	a1,5
    80000b32:	8526                	mv	a0,s1
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	1b2080e7          	jalr	434(ra) # 80000ce6 <memset>
  return (void*)r;
}
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	60e2                	ld	ra,24(sp)
    80000b40:	6442                	ld	s0,16(sp)
    80000b42:	64a2                	ld	s1,8(sp)
    80000b44:	6105                	addi	sp,sp,32
    80000b46:	8082                	ret
  release(&kmem.lock);
    80000b48:	00010517          	auipc	a0,0x10
    80000b4c:	1d850513          	addi	a0,a0,472 # 80010d20 <kmem>
    80000b50:	00000097          	auipc	ra,0x0
    80000b54:	14e080e7          	jalr	334(ra) # 80000c9e <release>
  if(r)
    80000b58:	b7d5                	j	80000b3c <kalloc+0x42>

0000000080000b5a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b5a:	1141                	addi	sp,sp,-16
    80000b5c:	e422                	sd	s0,8(sp)
    80000b5e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b60:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b62:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b66:	00053823          	sd	zero,16(a0)
}
    80000b6a:	6422                	ld	s0,8(sp)
    80000b6c:	0141                	addi	sp,sp,16
    80000b6e:	8082                	ret

0000000080000b70 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b70:	411c                	lw	a5,0(a0)
    80000b72:	e399                	bnez	a5,80000b78 <holding+0x8>
    80000b74:	4501                	li	a0,0
  return r;
}
    80000b76:	8082                	ret
{
    80000b78:	1101                	addi	sp,sp,-32
    80000b7a:	ec06                	sd	ra,24(sp)
    80000b7c:	e822                	sd	s0,16(sp)
    80000b7e:	e426                	sd	s1,8(sp)
    80000b80:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b82:	6904                	ld	s1,16(a0)
    80000b84:	00001097          	auipc	ra,0x1
    80000b88:	e26080e7          	jalr	-474(ra) # 800019aa <mycpu>
    80000b8c:	40a48533          	sub	a0,s1,a0
    80000b90:	00153513          	seqz	a0,a0
}
    80000b94:	60e2                	ld	ra,24(sp)
    80000b96:	6442                	ld	s0,16(sp)
    80000b98:	64a2                	ld	s1,8(sp)
    80000b9a:	6105                	addi	sp,sp,32
    80000b9c:	8082                	ret

0000000080000b9e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b9e:	1101                	addi	sp,sp,-32
    80000ba0:	ec06                	sd	ra,24(sp)
    80000ba2:	e822                	sd	s0,16(sp)
    80000ba4:	e426                	sd	s1,8(sp)
    80000ba6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba8:	100024f3          	csrr	s1,sstatus
    80000bac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bb0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bb2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb6:	00001097          	auipc	ra,0x1
    80000bba:	df4080e7          	jalr	-524(ra) # 800019aa <mycpu>
    80000bbe:	5d3c                	lw	a5,120(a0)
    80000bc0:	cf89                	beqz	a5,80000bda <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	de8080e7          	jalr	-536(ra) # 800019aa <mycpu>
    80000bca:	5d3c                	lw	a5,120(a0)
    80000bcc:	2785                	addiw	a5,a5,1
    80000bce:	dd3c                	sw	a5,120(a0)
}
    80000bd0:	60e2                	ld	ra,24(sp)
    80000bd2:	6442                	ld	s0,16(sp)
    80000bd4:	64a2                	ld	s1,8(sp)
    80000bd6:	6105                	addi	sp,sp,32
    80000bd8:	8082                	ret
    mycpu()->intena = old;
    80000bda:	00001097          	auipc	ra,0x1
    80000bde:	dd0080e7          	jalr	-560(ra) # 800019aa <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000be2:	8085                	srli	s1,s1,0x1
    80000be4:	8885                	andi	s1,s1,1
    80000be6:	dd64                	sw	s1,124(a0)
    80000be8:	bfe9                	j	80000bc2 <push_off+0x24>

0000000080000bea <acquire>:
{
    80000bea:	1101                	addi	sp,sp,-32
    80000bec:	ec06                	sd	ra,24(sp)
    80000bee:	e822                	sd	s0,16(sp)
    80000bf0:	e426                	sd	s1,8(sp)
    80000bf2:	1000                	addi	s0,sp,32
    80000bf4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf6:	00000097          	auipc	ra,0x0
    80000bfa:	fa8080e7          	jalr	-88(ra) # 80000b9e <push_off>
  if(holding(lk))
    80000bfe:	8526                	mv	a0,s1
    80000c00:	00000097          	auipc	ra,0x0
    80000c04:	f70080e7          	jalr	-144(ra) # 80000b70 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c08:	4705                	li	a4,1
  if(holding(lk))
    80000c0a:	e115                	bnez	a0,80000c2e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0c:	87ba                	mv	a5,a4
    80000c0e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c12:	2781                	sext.w	a5,a5
    80000c14:	ffe5                	bnez	a5,80000c0c <acquire+0x22>
  __sync_synchronize();
    80000c16:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1a:	00001097          	auipc	ra,0x1
    80000c1e:	d90080e7          	jalr	-624(ra) # 800019aa <mycpu>
    80000c22:	e888                	sd	a0,16(s1)
}
    80000c24:	60e2                	ld	ra,24(sp)
    80000c26:	6442                	ld	s0,16(sp)
    80000c28:	64a2                	ld	s1,8(sp)
    80000c2a:	6105                	addi	sp,sp,32
    80000c2c:	8082                	ret
    panic("acquire");
    80000c2e:	00007517          	auipc	a0,0x7
    80000c32:	44250513          	addi	a0,a0,1090 # 80008070 <digits+0x30>
    80000c36:	00000097          	auipc	ra,0x0
    80000c3a:	90e080e7          	jalr	-1778(ra) # 80000544 <panic>

0000000080000c3e <pop_off>:

void
pop_off(void)
{
    80000c3e:	1141                	addi	sp,sp,-16
    80000c40:	e406                	sd	ra,8(sp)
    80000c42:	e022                	sd	s0,0(sp)
    80000c44:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c46:	00001097          	auipc	ra,0x1
    80000c4a:	d64080e7          	jalr	-668(ra) # 800019aa <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c54:	e78d                	bnez	a5,80000c7e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c56:	5d3c                	lw	a5,120(a0)
    80000c58:	02f05b63          	blez	a5,80000c8e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c5c:	37fd                	addiw	a5,a5,-1
    80000c5e:	0007871b          	sext.w	a4,a5
    80000c62:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c64:	eb09                	bnez	a4,80000c76 <pop_off+0x38>
    80000c66:	5d7c                	lw	a5,124(a0)
    80000c68:	c799                	beqz	a5,80000c76 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c6a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c72:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c76:	60a2                	ld	ra,8(sp)
    80000c78:	6402                	ld	s0,0(sp)
    80000c7a:	0141                	addi	sp,sp,16
    80000c7c:	8082                	ret
    panic("pop_off - interruptible");
    80000c7e:	00007517          	auipc	a0,0x7
    80000c82:	3fa50513          	addi	a0,a0,1018 # 80008078 <digits+0x38>
    80000c86:	00000097          	auipc	ra,0x0
    80000c8a:	8be080e7          	jalr	-1858(ra) # 80000544 <panic>
    panic("pop_off");
    80000c8e:	00007517          	auipc	a0,0x7
    80000c92:	40250513          	addi	a0,a0,1026 # 80008090 <digits+0x50>
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	8ae080e7          	jalr	-1874(ra) # 80000544 <panic>

0000000080000c9e <release>:
{
    80000c9e:	1101                	addi	sp,sp,-32
    80000ca0:	ec06                	sd	ra,24(sp)
    80000ca2:	e822                	sd	s0,16(sp)
    80000ca4:	e426                	sd	s1,8(sp)
    80000ca6:	1000                	addi	s0,sp,32
    80000ca8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	ec6080e7          	jalr	-314(ra) # 80000b70 <holding>
    80000cb2:	c115                	beqz	a0,80000cd6 <release+0x38>
  lk->cpu = 0;
    80000cb4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cbc:	0f50000f          	fence	iorw,ow
    80000cc0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	f7a080e7          	jalr	-134(ra) # 80000c3e <pop_off>
}
    80000ccc:	60e2                	ld	ra,24(sp)
    80000cce:	6442                	ld	s0,16(sp)
    80000cd0:	64a2                	ld	s1,8(sp)
    80000cd2:	6105                	addi	sp,sp,32
    80000cd4:	8082                	ret
    panic("release");
    80000cd6:	00007517          	auipc	a0,0x7
    80000cda:	3c250513          	addi	a0,a0,962 # 80008098 <digits+0x58>
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	866080e7          	jalr	-1946(ra) # 80000544 <panic>

0000000080000ce6 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce6:	1141                	addi	sp,sp,-16
    80000ce8:	e422                	sd	s0,8(sp)
    80000cea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cec:	ce09                	beqz	a2,80000d06 <memset+0x20>
    80000cee:	87aa                	mv	a5,a0
    80000cf0:	fff6071b          	addiw	a4,a2,-1
    80000cf4:	1702                	slli	a4,a4,0x20
    80000cf6:	9301                	srli	a4,a4,0x20
    80000cf8:	0705                	addi	a4,a4,1
    80000cfa:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cfc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d00:	0785                	addi	a5,a5,1
    80000d02:	fee79de3          	bne	a5,a4,80000cfc <memset+0x16>
  }
  return dst;
}
    80000d06:	6422                	ld	s0,8(sp)
    80000d08:	0141                	addi	sp,sp,16
    80000d0a:	8082                	ret

0000000080000d0c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d12:	ca05                	beqz	a2,80000d42 <memcmp+0x36>
    80000d14:	fff6069b          	addiw	a3,a2,-1
    80000d18:	1682                	slli	a3,a3,0x20
    80000d1a:	9281                	srli	a3,a3,0x20
    80000d1c:	0685                	addi	a3,a3,1
    80000d1e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d20:	00054783          	lbu	a5,0(a0)
    80000d24:	0005c703          	lbu	a4,0(a1)
    80000d28:	00e79863          	bne	a5,a4,80000d38 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d2c:	0505                	addi	a0,a0,1
    80000d2e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d30:	fed518e3          	bne	a0,a3,80000d20 <memcmp+0x14>
  }

  return 0;
    80000d34:	4501                	li	a0,0
    80000d36:	a019                	j	80000d3c <memcmp+0x30>
      return *s1 - *s2;
    80000d38:	40e7853b          	subw	a0,a5,a4
}
    80000d3c:	6422                	ld	s0,8(sp)
    80000d3e:	0141                	addi	sp,sp,16
    80000d40:	8082                	ret
  return 0;
    80000d42:	4501                	li	a0,0
    80000d44:	bfe5                	j	80000d3c <memcmp+0x30>

0000000080000d46 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e422                	sd	s0,8(sp)
    80000d4a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d4c:	ca0d                	beqz	a2,80000d7e <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d4e:	00a5f963          	bgeu	a1,a0,80000d60 <memmove+0x1a>
    80000d52:	02061693          	slli	a3,a2,0x20
    80000d56:	9281                	srli	a3,a3,0x20
    80000d58:	00d58733          	add	a4,a1,a3
    80000d5c:	02e56463          	bltu	a0,a4,80000d84 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	0785                	addi	a5,a5,1
    80000d6a:	97ae                	add	a5,a5,a1
    80000d6c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d6e:	0585                	addi	a1,a1,1
    80000d70:	0705                	addi	a4,a4,1
    80000d72:	fff5c683          	lbu	a3,-1(a1)
    80000d76:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7a:	fef59ae3          	bne	a1,a5,80000d6e <memmove+0x28>

  return dst;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret
    d += n;
    80000d84:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d86:	fff6079b          	addiw	a5,a2,-1
    80000d8a:	1782                	slli	a5,a5,0x20
    80000d8c:	9381                	srli	a5,a5,0x20
    80000d8e:	fff7c793          	not	a5,a5
    80000d92:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d94:	177d                	addi	a4,a4,-1
    80000d96:	16fd                	addi	a3,a3,-1
    80000d98:	00074603          	lbu	a2,0(a4)
    80000d9c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000da0:	fef71ae3          	bne	a4,a5,80000d94 <memmove+0x4e>
    80000da4:	bfe9                	j	80000d7e <memmove+0x38>

0000000080000da6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dae:	00000097          	auipc	ra,0x0
    80000db2:	f98080e7          	jalr	-104(ra) # 80000d46 <memmove>
}
    80000db6:	60a2                	ld	ra,8(sp)
    80000db8:	6402                	ld	s0,0(sp)
    80000dba:	0141                	addi	sp,sp,16
    80000dbc:	8082                	ret

0000000080000dbe <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dbe:	1141                	addi	sp,sp,-16
    80000dc0:	e422                	sd	s0,8(sp)
    80000dc2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dc4:	ce11                	beqz	a2,80000de0 <strncmp+0x22>
    80000dc6:	00054783          	lbu	a5,0(a0)
    80000dca:	cf89                	beqz	a5,80000de4 <strncmp+0x26>
    80000dcc:	0005c703          	lbu	a4,0(a1)
    80000dd0:	00f71a63          	bne	a4,a5,80000de4 <strncmp+0x26>
    n--, p++, q++;
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	0505                	addi	a0,a0,1
    80000dd8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dda:	f675                	bnez	a2,80000dc6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ddc:	4501                	li	a0,0
    80000dde:	a809                	j	80000df0 <strncmp+0x32>
    80000de0:	4501                	li	a0,0
    80000de2:	a039                	j	80000df0 <strncmp+0x32>
  if(n == 0)
    80000de4:	ca09                	beqz	a2,80000df6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de6:	00054503          	lbu	a0,0(a0)
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	9d1d                	subw	a0,a0,a5
}
    80000df0:	6422                	ld	s0,8(sp)
    80000df2:	0141                	addi	sp,sp,16
    80000df4:	8082                	ret
    return 0;
    80000df6:	4501                	li	a0,0
    80000df8:	bfe5                	j	80000df0 <strncmp+0x32>

0000000080000dfa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dfa:	1141                	addi	sp,sp,-16
    80000dfc:	e422                	sd	s0,8(sp)
    80000dfe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e00:	872a                	mv	a4,a0
    80000e02:	8832                	mv	a6,a2
    80000e04:	367d                	addiw	a2,a2,-1
    80000e06:	01005963          	blez	a6,80000e18 <strncpy+0x1e>
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	0005c783          	lbu	a5,0(a1)
    80000e10:	fef70fa3          	sb	a5,-1(a4)
    80000e14:	0585                	addi	a1,a1,1
    80000e16:	f7f5                	bnez	a5,80000e02 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e18:	00c05d63          	blez	a2,80000e32 <strncpy+0x38>
    80000e1c:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e1e:	0685                	addi	a3,a3,1
    80000e20:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e24:	fff6c793          	not	a5,a3
    80000e28:	9fb9                	addw	a5,a5,a4
    80000e2a:	010787bb          	addw	a5,a5,a6
    80000e2e:	fef048e3          	bgtz	a5,80000e1e <strncpy+0x24>
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e3e:	02c05363          	blez	a2,80000e64 <safestrcpy+0x2c>
    80000e42:	fff6069b          	addiw	a3,a2,-1
    80000e46:	1682                	slli	a3,a3,0x20
    80000e48:	9281                	srli	a3,a3,0x20
    80000e4a:	96ae                	add	a3,a3,a1
    80000e4c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e4e:	00d58963          	beq	a1,a3,80000e60 <safestrcpy+0x28>
    80000e52:	0585                	addi	a1,a1,1
    80000e54:	0785                	addi	a5,a5,1
    80000e56:	fff5c703          	lbu	a4,-1(a1)
    80000e5a:	fee78fa3          	sb	a4,-1(a5)
    80000e5e:	fb65                	bnez	a4,80000e4e <safestrcpy+0x16>
    ;
  *s = 0;
    80000e60:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <strlen>:

int
strlen(const char *s)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e70:	00054783          	lbu	a5,0(a0)
    80000e74:	cf91                	beqz	a5,80000e90 <strlen+0x26>
    80000e76:	0505                	addi	a0,a0,1
    80000e78:	87aa                	mv	a5,a0
    80000e7a:	4685                	li	a3,1
    80000e7c:	9e89                	subw	a3,a3,a0
    80000e7e:	00f6853b          	addw	a0,a3,a5
    80000e82:	0785                	addi	a5,a5,1
    80000e84:	fff7c703          	lbu	a4,-1(a5)
    80000e88:	fb7d                	bnez	a4,80000e7e <strlen+0x14>
    ;
  return n;
}
    80000e8a:	6422                	ld	s0,8(sp)
    80000e8c:	0141                	addi	sp,sp,16
    80000e8e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e90:	4501                	li	a0,0
    80000e92:	bfe5                	j	80000e8a <strlen+0x20>

0000000080000e94 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e406                	sd	ra,8(sp)
    80000e98:	e022                	sd	s0,0(sp)
    80000e9a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	afe080e7          	jalr	-1282(ra) # 8000199a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ea4:	00008717          	auipc	a4,0x8
    80000ea8:	c1470713          	addi	a4,a4,-1004 # 80008ab8 <started>
  if(cpuid() == 0){
    80000eac:	c139                	beqz	a0,80000ef2 <main+0x5e>
    while(started == 0)
    80000eae:	431c                	lw	a5,0(a4)
    80000eb0:	2781                	sext.w	a5,a5
    80000eb2:	dff5                	beqz	a5,80000eae <main+0x1a>
      ;
    __sync_synchronize();
    80000eb4:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	ae2080e7          	jalr	-1310(ra) # 8000199a <cpuid>
    80000ec0:	85aa                	mv	a1,a0
    80000ec2:	00007517          	auipc	a0,0x7
    80000ec6:	1f650513          	addi	a0,a0,502 # 800080b8 <digits+0x78>
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	6c4080e7          	jalr	1732(ra) # 8000058e <printf>
    kvminithart();    // turn on paging
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	0d8080e7          	jalr	216(ra) # 80000faa <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eda:	00002097          	auipc	ra,0x2
    80000ede:	c10080e7          	jalr	-1008(ra) # 80002aea <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	2ce080e7          	jalr	718(ra) # 800061b0 <plicinithart>
  }

  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	fce080e7          	jalr	-50(ra) # 80001eb8 <scheduler>
    consoleinit();
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	564080e7          	jalr	1380(ra) # 80000456 <consoleinit>
    printfinit();
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	87a080e7          	jalr	-1926(ra) # 80000774 <printfinit>
    printf("\n");
    80000f02:	00007517          	auipc	a0,0x7
    80000f06:	1c650513          	addi	a0,a0,454 # 800080c8 <digits+0x88>
    80000f0a:	fffff097          	auipc	ra,0xfffff
    80000f0e:	684080e7          	jalr	1668(ra) # 8000058e <printf>
    printf("xv6 kernel is booting\n");
    80000f12:	00007517          	auipc	a0,0x7
    80000f16:	18e50513          	addi	a0,a0,398 # 800080a0 <digits+0x60>
    80000f1a:	fffff097          	auipc	ra,0xfffff
    80000f1e:	674080e7          	jalr	1652(ra) # 8000058e <printf>
    printf("\n");
    80000f22:	00007517          	auipc	a0,0x7
    80000f26:	1a650513          	addi	a0,a0,422 # 800080c8 <digits+0x88>
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	664080e7          	jalr	1636(ra) # 8000058e <printf>
    kinit();         // physical page allocator
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	b8c080e7          	jalr	-1140(ra) # 80000abe <kinit>
    kvminit();       // create kernel page table
    80000f3a:	00000097          	auipc	ra,0x0
    80000f3e:	326080e7          	jalr	806(ra) # 80001260 <kvminit>
    kvminithart();   // turn on paging
    80000f42:	00000097          	auipc	ra,0x0
    80000f46:	068080e7          	jalr	104(ra) # 80000faa <kvminithart>
    procinit();      // process table
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	99c080e7          	jalr	-1636(ra) # 800018e6 <procinit>
    trapinit();      // trap vectors
    80000f52:	00002097          	auipc	ra,0x2
    80000f56:	b70080e7          	jalr	-1168(ra) # 80002ac2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	b90080e7          	jalr	-1136(ra) # 80002aea <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	238080e7          	jalr	568(ra) # 8000619a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	246080e7          	jalr	582(ra) # 800061b0 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	3fa080e7          	jalr	1018(ra) # 8000336c <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	a9e080e7          	jalr	-1378(ra) # 80003a18 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	a3c080e7          	jalr	-1476(ra) # 800049be <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	32e080e7          	jalr	814(ra) # 800062b8 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	d0c080e7          	jalr	-756(ra) # 80001c9e <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	b0f72c23          	sw	a5,-1256(a4) # 80008ab8 <started>
    80000fa8:	b789                	j	80000eea <main+0x56>

0000000080000faa <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000faa:	1141                	addi	sp,sp,-16
    80000fac:	e422                	sd	s0,8(sp)
    80000fae:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fb4:	00008797          	auipc	a5,0x8
    80000fb8:	b0c7b783          	ld	a5,-1268(a5) # 80008ac0 <kernel_pagetable>
    80000fbc:	83b1                	srli	a5,a5,0xc
    80000fbe:	577d                	li	a4,-1
    80000fc0:	177e                	slli	a4,a4,0x3f
    80000fc2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fc4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fc8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fcc:	6422                	ld	s0,8(sp)
    80000fce:	0141                	addi	sp,sp,16
    80000fd0:	8082                	ret

0000000080000fd2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fd2:	7139                	addi	sp,sp,-64
    80000fd4:	fc06                	sd	ra,56(sp)
    80000fd6:	f822                	sd	s0,48(sp)
    80000fd8:	f426                	sd	s1,40(sp)
    80000fda:	f04a                	sd	s2,32(sp)
    80000fdc:	ec4e                	sd	s3,24(sp)
    80000fde:	e852                	sd	s4,16(sp)
    80000fe0:	e456                	sd	s5,8(sp)
    80000fe2:	e05a                	sd	s6,0(sp)
    80000fe4:	0080                	addi	s0,sp,64
    80000fe6:	84aa                	mv	s1,a0
    80000fe8:	89ae                	mv	s3,a1
    80000fea:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fec:	57fd                	li	a5,-1
    80000fee:	83e9                	srli	a5,a5,0x1a
    80000ff0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ff2:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ff4:	04b7f263          	bgeu	a5,a1,80001038 <walk+0x66>
    panic("walk");
    80000ff8:	00007517          	auipc	a0,0x7
    80000ffc:	0d850513          	addi	a0,a0,216 # 800080d0 <digits+0x90>
    80001000:	fffff097          	auipc	ra,0xfffff
    80001004:	544080e7          	jalr	1348(ra) # 80000544 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001008:	060a8663          	beqz	s5,80001074 <walk+0xa2>
    8000100c:	00000097          	auipc	ra,0x0
    80001010:	aee080e7          	jalr	-1298(ra) # 80000afa <kalloc>
    80001014:	84aa                	mv	s1,a0
    80001016:	c529                	beqz	a0,80001060 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001018:	6605                	lui	a2,0x1
    8000101a:	4581                	li	a1,0
    8000101c:	00000097          	auipc	ra,0x0
    80001020:	cca080e7          	jalr	-822(ra) # 80000ce6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001024:	00c4d793          	srli	a5,s1,0xc
    80001028:	07aa                	slli	a5,a5,0xa
    8000102a:	0017e793          	ori	a5,a5,1
    8000102e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001032:	3a5d                	addiw	s4,s4,-9
    80001034:	036a0063          	beq	s4,s6,80001054 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001038:	0149d933          	srl	s2,s3,s4
    8000103c:	1ff97913          	andi	s2,s2,511
    80001040:	090e                	slli	s2,s2,0x3
    80001042:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001044:	00093483          	ld	s1,0(s2)
    80001048:	0014f793          	andi	a5,s1,1
    8000104c:	dfd5                	beqz	a5,80001008 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000104e:	80a9                	srli	s1,s1,0xa
    80001050:	04b2                	slli	s1,s1,0xc
    80001052:	b7c5                	j	80001032 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001054:	00c9d513          	srli	a0,s3,0xc
    80001058:	1ff57513          	andi	a0,a0,511
    8000105c:	050e                	slli	a0,a0,0x3
    8000105e:	9526                	add	a0,a0,s1
}
    80001060:	70e2                	ld	ra,56(sp)
    80001062:	7442                	ld	s0,48(sp)
    80001064:	74a2                	ld	s1,40(sp)
    80001066:	7902                	ld	s2,32(sp)
    80001068:	69e2                	ld	s3,24(sp)
    8000106a:	6a42                	ld	s4,16(sp)
    8000106c:	6aa2                	ld	s5,8(sp)
    8000106e:	6b02                	ld	s6,0(sp)
    80001070:	6121                	addi	sp,sp,64
    80001072:	8082                	ret
        return 0;
    80001074:	4501                	li	a0,0
    80001076:	b7ed                	j	80001060 <walk+0x8e>

0000000080001078 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001078:	57fd                	li	a5,-1
    8000107a:	83e9                	srli	a5,a5,0x1a
    8000107c:	00b7f463          	bgeu	a5,a1,80001084 <walkaddr+0xc>
    return 0;
    80001080:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001082:	8082                	ret
{
    80001084:	1141                	addi	sp,sp,-16
    80001086:	e406                	sd	ra,8(sp)
    80001088:	e022                	sd	s0,0(sp)
    8000108a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000108c:	4601                	li	a2,0
    8000108e:	00000097          	auipc	ra,0x0
    80001092:	f44080e7          	jalr	-188(ra) # 80000fd2 <walk>
  if(pte == 0)
    80001096:	c105                	beqz	a0,800010b6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001098:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000109a:	0117f693          	andi	a3,a5,17
    8000109e:	4745                	li	a4,17
    return 0;
    800010a0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a2:	00e68663          	beq	a3,a4,800010ae <walkaddr+0x36>
}
    800010a6:	60a2                	ld	ra,8(sp)
    800010a8:	6402                	ld	s0,0(sp)
    800010aa:	0141                	addi	sp,sp,16
    800010ac:	8082                	ret
  pa = PTE2PA(*pte);
    800010ae:	00a7d513          	srli	a0,a5,0xa
    800010b2:	0532                	slli	a0,a0,0xc
  return pa;
    800010b4:	bfcd                	j	800010a6 <walkaddr+0x2e>
    return 0;
    800010b6:	4501                	li	a0,0
    800010b8:	b7fd                	j	800010a6 <walkaddr+0x2e>

00000000800010ba <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ba:	715d                	addi	sp,sp,-80
    800010bc:	e486                	sd	ra,72(sp)
    800010be:	e0a2                	sd	s0,64(sp)
    800010c0:	fc26                	sd	s1,56(sp)
    800010c2:	f84a                	sd	s2,48(sp)
    800010c4:	f44e                	sd	s3,40(sp)
    800010c6:	f052                	sd	s4,32(sp)
    800010c8:	ec56                	sd	s5,24(sp)
    800010ca:	e85a                	sd	s6,16(sp)
    800010cc:	e45e                	sd	s7,8(sp)
    800010ce:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010d0:	c205                	beqz	a2,800010f0 <mappages+0x36>
    800010d2:	8aaa                	mv	s5,a0
    800010d4:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010d6:	77fd                	lui	a5,0xfffff
    800010d8:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010dc:	15fd                	addi	a1,a1,-1
    800010de:	00c589b3          	add	s3,a1,a2
    800010e2:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010e6:	8952                	mv	s2,s4
    800010e8:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ec:	6b85                	lui	s7,0x1
    800010ee:	a015                	j	80001112 <mappages+0x58>
    panic("mappages: size");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	44c080e7          	jalr	1100(ra) # 80000544 <panic>
      panic("mappages: remap");
    80001100:	00007517          	auipc	a0,0x7
    80001104:	fe850513          	addi	a0,a0,-24 # 800080e8 <digits+0xa8>
    80001108:	fffff097          	auipc	ra,0xfffff
    8000110c:	43c080e7          	jalr	1084(ra) # 80000544 <panic>
    a += PGSIZE;
    80001110:	995e                	add	s2,s2,s7
  for(;;){
    80001112:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001116:	4605                	li	a2,1
    80001118:	85ca                	mv	a1,s2
    8000111a:	8556                	mv	a0,s5
    8000111c:	00000097          	auipc	ra,0x0
    80001120:	eb6080e7          	jalr	-330(ra) # 80000fd2 <walk>
    80001124:	cd19                	beqz	a0,80001142 <mappages+0x88>
    if(*pte & PTE_V)
    80001126:	611c                	ld	a5,0(a0)
    80001128:	8b85                	andi	a5,a5,1
    8000112a:	fbf9                	bnez	a5,80001100 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000112c:	80b1                	srli	s1,s1,0xc
    8000112e:	04aa                	slli	s1,s1,0xa
    80001130:	0164e4b3          	or	s1,s1,s6
    80001134:	0014e493          	ori	s1,s1,1
    80001138:	e104                	sd	s1,0(a0)
    if(a == last)
    8000113a:	fd391be3          	bne	s2,s3,80001110 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    8000113e:	4501                	li	a0,0
    80001140:	a011                	j	80001144 <mappages+0x8a>
      return -1;
    80001142:	557d                	li	a0,-1
}
    80001144:	60a6                	ld	ra,72(sp)
    80001146:	6406                	ld	s0,64(sp)
    80001148:	74e2                	ld	s1,56(sp)
    8000114a:	7942                	ld	s2,48(sp)
    8000114c:	79a2                	ld	s3,40(sp)
    8000114e:	7a02                	ld	s4,32(sp)
    80001150:	6ae2                	ld	s5,24(sp)
    80001152:	6b42                	ld	s6,16(sp)
    80001154:	6ba2                	ld	s7,8(sp)
    80001156:	6161                	addi	sp,sp,80
    80001158:	8082                	ret

000000008000115a <kvmmap>:
{
    8000115a:	1141                	addi	sp,sp,-16
    8000115c:	e406                	sd	ra,8(sp)
    8000115e:	e022                	sd	s0,0(sp)
    80001160:	0800                	addi	s0,sp,16
    80001162:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001164:	86b2                	mv	a3,a2
    80001166:	863e                	mv	a2,a5
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	f52080e7          	jalr	-174(ra) # 800010ba <mappages>
    80001170:	e509                	bnez	a0,8000117a <kvmmap+0x20>
}
    80001172:	60a2                	ld	ra,8(sp)
    80001174:	6402                	ld	s0,0(sp)
    80001176:	0141                	addi	sp,sp,16
    80001178:	8082                	ret
    panic("kvmmap");
    8000117a:	00007517          	auipc	a0,0x7
    8000117e:	f7e50513          	addi	a0,a0,-130 # 800080f8 <digits+0xb8>
    80001182:	fffff097          	auipc	ra,0xfffff
    80001186:	3c2080e7          	jalr	962(ra) # 80000544 <panic>

000000008000118a <kvmmake>:
{
    8000118a:	1101                	addi	sp,sp,-32
    8000118c:	ec06                	sd	ra,24(sp)
    8000118e:	e822                	sd	s0,16(sp)
    80001190:	e426                	sd	s1,8(sp)
    80001192:	e04a                	sd	s2,0(sp)
    80001194:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001196:	00000097          	auipc	ra,0x0
    8000119a:	964080e7          	jalr	-1692(ra) # 80000afa <kalloc>
    8000119e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011a0:	6605                	lui	a2,0x1
    800011a2:	4581                	li	a1,0
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	b42080e7          	jalr	-1214(ra) # 80000ce6 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ac:	4719                	li	a4,6
    800011ae:	6685                	lui	a3,0x1
    800011b0:	10000637          	lui	a2,0x10000
    800011b4:	100005b7          	lui	a1,0x10000
    800011b8:	8526                	mv	a0,s1
    800011ba:	00000097          	auipc	ra,0x0
    800011be:	fa0080e7          	jalr	-96(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011c2:	4719                	li	a4,6
    800011c4:	6685                	lui	a3,0x1
    800011c6:	10001637          	lui	a2,0x10001
    800011ca:	100015b7          	lui	a1,0x10001
    800011ce:	8526                	mv	a0,s1
    800011d0:	00000097          	auipc	ra,0x0
    800011d4:	f8a080e7          	jalr	-118(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011d8:	4719                	li	a4,6
    800011da:	004006b7          	lui	a3,0x400
    800011de:	0c000637          	lui	a2,0xc000
    800011e2:	0c0005b7          	lui	a1,0xc000
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f72080e7          	jalr	-142(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011f0:	00007917          	auipc	s2,0x7
    800011f4:	e1090913          	addi	s2,s2,-496 # 80008000 <etext>
    800011f8:	4729                	li	a4,10
    800011fa:	80007697          	auipc	a3,0x80007
    800011fe:	e0668693          	addi	a3,a3,-506 # 8000 <_entry-0x7fff8000>
    80001202:	4605                	li	a2,1
    80001204:	067e                	slli	a2,a2,0x1f
    80001206:	85b2                	mv	a1,a2
    80001208:	8526                	mv	a0,s1
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	f50080e7          	jalr	-176(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001212:	4719                	li	a4,6
    80001214:	46c5                	li	a3,17
    80001216:	06ee                	slli	a3,a3,0x1b
    80001218:	412686b3          	sub	a3,a3,s2
    8000121c:	864a                	mv	a2,s2
    8000121e:	85ca                	mv	a1,s2
    80001220:	8526                	mv	a0,s1
    80001222:	00000097          	auipc	ra,0x0
    80001226:	f38080e7          	jalr	-200(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000122a:	4729                	li	a4,10
    8000122c:	6685                	lui	a3,0x1
    8000122e:	00006617          	auipc	a2,0x6
    80001232:	dd260613          	addi	a2,a2,-558 # 80007000 <_trampoline>
    80001236:	040005b7          	lui	a1,0x4000
    8000123a:	15fd                	addi	a1,a1,-1
    8000123c:	05b2                	slli	a1,a1,0xc
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	f1a080e7          	jalr	-230(ra) # 8000115a <kvmmap>
  proc_mapstacks(kpgtbl);
    80001248:	8526                	mv	a0,s1
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	606080e7          	jalr	1542(ra) # 80001850 <proc_mapstacks>
}
    80001252:	8526                	mv	a0,s1
    80001254:	60e2                	ld	ra,24(sp)
    80001256:	6442                	ld	s0,16(sp)
    80001258:	64a2                	ld	s1,8(sp)
    8000125a:	6902                	ld	s2,0(sp)
    8000125c:	6105                	addi	sp,sp,32
    8000125e:	8082                	ret

0000000080001260 <kvminit>:
{
    80001260:	1141                	addi	sp,sp,-16
    80001262:	e406                	sd	ra,8(sp)
    80001264:	e022                	sd	s0,0(sp)
    80001266:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001268:	00000097          	auipc	ra,0x0
    8000126c:	f22080e7          	jalr	-222(ra) # 8000118a <kvmmake>
    80001270:	00008797          	auipc	a5,0x8
    80001274:	84a7b823          	sd	a0,-1968(a5) # 80008ac0 <kernel_pagetable>
}
    80001278:	60a2                	ld	ra,8(sp)
    8000127a:	6402                	ld	s0,0(sp)
    8000127c:	0141                	addi	sp,sp,16
    8000127e:	8082                	ret

0000000080001280 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001280:	715d                	addi	sp,sp,-80
    80001282:	e486                	sd	ra,72(sp)
    80001284:	e0a2                	sd	s0,64(sp)
    80001286:	fc26                	sd	s1,56(sp)
    80001288:	f84a                	sd	s2,48(sp)
    8000128a:	f44e                	sd	s3,40(sp)
    8000128c:	f052                	sd	s4,32(sp)
    8000128e:	ec56                	sd	s5,24(sp)
    80001290:	e85a                	sd	s6,16(sp)
    80001292:	e45e                	sd	s7,8(sp)
    80001294:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001296:	03459793          	slli	a5,a1,0x34
    8000129a:	e795                	bnez	a5,800012c6 <uvmunmap+0x46>
    8000129c:	8a2a                	mv	s4,a0
    8000129e:	892e                	mv	s2,a1
    800012a0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a2:	0632                	slli	a2,a2,0xc
    800012a4:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012a8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012aa:	6b05                	lui	s6,0x1
    800012ac:	0735e863          	bltu	a1,s3,8000131c <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012b0:	60a6                	ld	ra,72(sp)
    800012b2:	6406                	ld	s0,64(sp)
    800012b4:	74e2                	ld	s1,56(sp)
    800012b6:	7942                	ld	s2,48(sp)
    800012b8:	79a2                	ld	s3,40(sp)
    800012ba:	7a02                	ld	s4,32(sp)
    800012bc:	6ae2                	ld	s5,24(sp)
    800012be:	6b42                	ld	s6,16(sp)
    800012c0:	6ba2                	ld	s7,8(sp)
    800012c2:	6161                	addi	sp,sp,80
    800012c4:	8082                	ret
    panic("uvmunmap: not aligned");
    800012c6:	00007517          	auipc	a0,0x7
    800012ca:	e3a50513          	addi	a0,a0,-454 # 80008100 <digits+0xc0>
    800012ce:	fffff097          	auipc	ra,0xfffff
    800012d2:	276080e7          	jalr	630(ra) # 80000544 <panic>
      panic("uvmunmap: walk");
    800012d6:	00007517          	auipc	a0,0x7
    800012da:	e4250513          	addi	a0,a0,-446 # 80008118 <digits+0xd8>
    800012de:	fffff097          	auipc	ra,0xfffff
    800012e2:	266080e7          	jalr	614(ra) # 80000544 <panic>
      panic("uvmunmap: not mapped");
    800012e6:	00007517          	auipc	a0,0x7
    800012ea:	e4250513          	addi	a0,a0,-446 # 80008128 <digits+0xe8>
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	256080e7          	jalr	598(ra) # 80000544 <panic>
      panic("uvmunmap: not a leaf");
    800012f6:	00007517          	auipc	a0,0x7
    800012fa:	e4a50513          	addi	a0,a0,-438 # 80008140 <digits+0x100>
    800012fe:	fffff097          	auipc	ra,0xfffff
    80001302:	246080e7          	jalr	582(ra) # 80000544 <panic>
      uint64 pa = PTE2PA(*pte);
    80001306:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001308:	0532                	slli	a0,a0,0xc
    8000130a:	fffff097          	auipc	ra,0xfffff
    8000130e:	6f4080e7          	jalr	1780(ra) # 800009fe <kfree>
    *pte = 0;
    80001312:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001316:	995a                	add	s2,s2,s6
    80001318:	f9397ce3          	bgeu	s2,s3,800012b0 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000131c:	4601                	li	a2,0
    8000131e:	85ca                	mv	a1,s2
    80001320:	8552                	mv	a0,s4
    80001322:	00000097          	auipc	ra,0x0
    80001326:	cb0080e7          	jalr	-848(ra) # 80000fd2 <walk>
    8000132a:	84aa                	mv	s1,a0
    8000132c:	d54d                	beqz	a0,800012d6 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000132e:	6108                	ld	a0,0(a0)
    80001330:	00157793          	andi	a5,a0,1
    80001334:	dbcd                	beqz	a5,800012e6 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001336:	3ff57793          	andi	a5,a0,1023
    8000133a:	fb778ee3          	beq	a5,s7,800012f6 <uvmunmap+0x76>
    if(do_free){
    8000133e:	fc0a8ae3          	beqz	s5,80001312 <uvmunmap+0x92>
    80001342:	b7d1                	j	80001306 <uvmunmap+0x86>

0000000080001344 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001344:	1101                	addi	sp,sp,-32
    80001346:	ec06                	sd	ra,24(sp)
    80001348:	e822                	sd	s0,16(sp)
    8000134a:	e426                	sd	s1,8(sp)
    8000134c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000134e:	fffff097          	auipc	ra,0xfffff
    80001352:	7ac080e7          	jalr	1964(ra) # 80000afa <kalloc>
    80001356:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001358:	c519                	beqz	a0,80001366 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	988080e7          	jalr	-1656(ra) # 80000ce6 <memset>
  return pagetable;
}
    80001366:	8526                	mv	a0,s1
    80001368:	60e2                	ld	ra,24(sp)
    8000136a:	6442                	ld	s0,16(sp)
    8000136c:	64a2                	ld	s1,8(sp)
    8000136e:	6105                	addi	sp,sp,32
    80001370:	8082                	ret

0000000080001372 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001372:	7179                	addi	sp,sp,-48
    80001374:	f406                	sd	ra,40(sp)
    80001376:	f022                	sd	s0,32(sp)
    80001378:	ec26                	sd	s1,24(sp)
    8000137a:	e84a                	sd	s2,16(sp)
    8000137c:	e44e                	sd	s3,8(sp)
    8000137e:	e052                	sd	s4,0(sp)
    80001380:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001382:	6785                	lui	a5,0x1
    80001384:	04f67863          	bgeu	a2,a5,800013d4 <uvmfirst+0x62>
    80001388:	8a2a                	mv	s4,a0
    8000138a:	89ae                	mv	s3,a1
    8000138c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000138e:	fffff097          	auipc	ra,0xfffff
    80001392:	76c080e7          	jalr	1900(ra) # 80000afa <kalloc>
    80001396:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001398:	6605                	lui	a2,0x1
    8000139a:	4581                	li	a1,0
    8000139c:	00000097          	auipc	ra,0x0
    800013a0:	94a080e7          	jalr	-1718(ra) # 80000ce6 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013a4:	4779                	li	a4,30
    800013a6:	86ca                	mv	a3,s2
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	8552                	mv	a0,s4
    800013ae:	00000097          	auipc	ra,0x0
    800013b2:	d0c080e7          	jalr	-756(ra) # 800010ba <mappages>
  memmove(mem, src, sz);
    800013b6:	8626                	mv	a2,s1
    800013b8:	85ce                	mv	a1,s3
    800013ba:	854a                	mv	a0,s2
    800013bc:	00000097          	auipc	ra,0x0
    800013c0:	98a080e7          	jalr	-1654(ra) # 80000d46 <memmove>
}
    800013c4:	70a2                	ld	ra,40(sp)
    800013c6:	7402                	ld	s0,32(sp)
    800013c8:	64e2                	ld	s1,24(sp)
    800013ca:	6942                	ld	s2,16(sp)
    800013cc:	69a2                	ld	s3,8(sp)
    800013ce:	6a02                	ld	s4,0(sp)
    800013d0:	6145                	addi	sp,sp,48
    800013d2:	8082                	ret
    panic("uvmfirst: more than a page");
    800013d4:	00007517          	auipc	a0,0x7
    800013d8:	d8450513          	addi	a0,a0,-636 # 80008158 <digits+0x118>
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	168080e7          	jalr	360(ra) # 80000544 <panic>

00000000800013e4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013e4:	1101                	addi	sp,sp,-32
    800013e6:	ec06                	sd	ra,24(sp)
    800013e8:	e822                	sd	s0,16(sp)
    800013ea:	e426                	sd	s1,8(sp)
    800013ec:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013ee:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013f0:	00b67d63          	bgeu	a2,a1,8000140a <uvmdealloc+0x26>
    800013f4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013f6:	6785                	lui	a5,0x1
    800013f8:	17fd                	addi	a5,a5,-1
    800013fa:	00f60733          	add	a4,a2,a5
    800013fe:	767d                	lui	a2,0xfffff
    80001400:	8f71                	and	a4,a4,a2
    80001402:	97ae                	add	a5,a5,a1
    80001404:	8ff1                	and	a5,a5,a2
    80001406:	00f76863          	bltu	a4,a5,80001416 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000140a:	8526                	mv	a0,s1
    8000140c:	60e2                	ld	ra,24(sp)
    8000140e:	6442                	ld	s0,16(sp)
    80001410:	64a2                	ld	s1,8(sp)
    80001412:	6105                	addi	sp,sp,32
    80001414:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001416:	8f99                	sub	a5,a5,a4
    80001418:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000141a:	4685                	li	a3,1
    8000141c:	0007861b          	sext.w	a2,a5
    80001420:	85ba                	mv	a1,a4
    80001422:	00000097          	auipc	ra,0x0
    80001426:	e5e080e7          	jalr	-418(ra) # 80001280 <uvmunmap>
    8000142a:	b7c5                	j	8000140a <uvmdealloc+0x26>

000000008000142c <uvmalloc>:
  if(newsz < oldsz)
    8000142c:	0ab66563          	bltu	a2,a1,800014d6 <uvmalloc+0xaa>
{
    80001430:	7139                	addi	sp,sp,-64
    80001432:	fc06                	sd	ra,56(sp)
    80001434:	f822                	sd	s0,48(sp)
    80001436:	f426                	sd	s1,40(sp)
    80001438:	f04a                	sd	s2,32(sp)
    8000143a:	ec4e                	sd	s3,24(sp)
    8000143c:	e852                	sd	s4,16(sp)
    8000143e:	e456                	sd	s5,8(sp)
    80001440:	e05a                	sd	s6,0(sp)
    80001442:	0080                	addi	s0,sp,64
    80001444:	8aaa                	mv	s5,a0
    80001446:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001448:	6985                	lui	s3,0x1
    8000144a:	19fd                	addi	s3,s3,-1
    8000144c:	95ce                	add	a1,a1,s3
    8000144e:	79fd                	lui	s3,0xfffff
    80001450:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001454:	08c9f363          	bgeu	s3,a2,800014da <uvmalloc+0xae>
    80001458:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000145e:	fffff097          	auipc	ra,0xfffff
    80001462:	69c080e7          	jalr	1692(ra) # 80000afa <kalloc>
    80001466:	84aa                	mv	s1,a0
    if(mem == 0){
    80001468:	c51d                	beqz	a0,80001496 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000146a:	6605                	lui	a2,0x1
    8000146c:	4581                	li	a1,0
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	878080e7          	jalr	-1928(ra) # 80000ce6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001476:	875a                	mv	a4,s6
    80001478:	86a6                	mv	a3,s1
    8000147a:	6605                	lui	a2,0x1
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	c3a080e7          	jalr	-966(ra) # 800010ba <mappages>
    80001488:	e90d                	bnez	a0,800014ba <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000148a:	6785                	lui	a5,0x1
    8000148c:	993e                	add	s2,s2,a5
    8000148e:	fd4968e3          	bltu	s2,s4,8000145e <uvmalloc+0x32>
  return newsz;
    80001492:	8552                	mv	a0,s4
    80001494:	a809                	j	800014a6 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001496:	864e                	mv	a2,s3
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f48080e7          	jalr	-184(ra) # 800013e4 <uvmdealloc>
      return 0;
    800014a4:	4501                	li	a0,0
}
    800014a6:	70e2                	ld	ra,56(sp)
    800014a8:	7442                	ld	s0,48(sp)
    800014aa:	74a2                	ld	s1,40(sp)
    800014ac:	7902                	ld	s2,32(sp)
    800014ae:	69e2                	ld	s3,24(sp)
    800014b0:	6a42                	ld	s4,16(sp)
    800014b2:	6aa2                	ld	s5,8(sp)
    800014b4:	6b02                	ld	s6,0(sp)
    800014b6:	6121                	addi	sp,sp,64
    800014b8:	8082                	ret
      kfree(mem);
    800014ba:	8526                	mv	a0,s1
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	542080e7          	jalr	1346(ra) # 800009fe <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014c4:	864e                	mv	a2,s3
    800014c6:	85ca                	mv	a1,s2
    800014c8:	8556                	mv	a0,s5
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	f1a080e7          	jalr	-230(ra) # 800013e4 <uvmdealloc>
      return 0;
    800014d2:	4501                	li	a0,0
    800014d4:	bfc9                	j	800014a6 <uvmalloc+0x7a>
    return oldsz;
    800014d6:	852e                	mv	a0,a1
}
    800014d8:	8082                	ret
  return newsz;
    800014da:	8532                	mv	a0,a2
    800014dc:	b7e9                	j	800014a6 <uvmalloc+0x7a>

00000000800014de <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014de:	7179                	addi	sp,sp,-48
    800014e0:	f406                	sd	ra,40(sp)
    800014e2:	f022                	sd	s0,32(sp)
    800014e4:	ec26                	sd	s1,24(sp)
    800014e6:	e84a                	sd	s2,16(sp)
    800014e8:	e44e                	sd	s3,8(sp)
    800014ea:	e052                	sd	s4,0(sp)
    800014ec:	1800                	addi	s0,sp,48
    800014ee:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014f0:	84aa                	mv	s1,a0
    800014f2:	6905                	lui	s2,0x1
    800014f4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	4985                	li	s3,1
    800014f8:	a821                	j	80001510 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014fa:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014fc:	0532                	slli	a0,a0,0xc
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	fe0080e7          	jalr	-32(ra) # 800014de <freewalk>
      pagetable[i] = 0;
    80001506:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000150a:	04a1                	addi	s1,s1,8
    8000150c:	03248163          	beq	s1,s2,8000152e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001510:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001512:	00f57793          	andi	a5,a0,15
    80001516:	ff3782e3          	beq	a5,s3,800014fa <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000151a:	8905                	andi	a0,a0,1
    8000151c:	d57d                	beqz	a0,8000150a <freewalk+0x2c>
      panic("freewalk: leaf");
    8000151e:	00007517          	auipc	a0,0x7
    80001522:	c5a50513          	addi	a0,a0,-934 # 80008178 <digits+0x138>
    80001526:	fffff097          	auipc	ra,0xfffff
    8000152a:	01e080e7          	jalr	30(ra) # 80000544 <panic>
    }
  }
  kfree((void*)pagetable);
    8000152e:	8552                	mv	a0,s4
    80001530:	fffff097          	auipc	ra,0xfffff
    80001534:	4ce080e7          	jalr	1230(ra) # 800009fe <kfree>
}
    80001538:	70a2                	ld	ra,40(sp)
    8000153a:	7402                	ld	s0,32(sp)
    8000153c:	64e2                	ld	s1,24(sp)
    8000153e:	6942                	ld	s2,16(sp)
    80001540:	69a2                	ld	s3,8(sp)
    80001542:	6a02                	ld	s4,0(sp)
    80001544:	6145                	addi	sp,sp,48
    80001546:	8082                	ret

0000000080001548 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001548:	1101                	addi	sp,sp,-32
    8000154a:	ec06                	sd	ra,24(sp)
    8000154c:	e822                	sd	s0,16(sp)
    8000154e:	e426                	sd	s1,8(sp)
    80001550:	1000                	addi	s0,sp,32
    80001552:	84aa                	mv	s1,a0
  if(sz > 0)
    80001554:	e999                	bnez	a1,8000156a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001556:	8526                	mv	a0,s1
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	f86080e7          	jalr	-122(ra) # 800014de <freewalk>
}
    80001560:	60e2                	ld	ra,24(sp)
    80001562:	6442                	ld	s0,16(sp)
    80001564:	64a2                	ld	s1,8(sp)
    80001566:	6105                	addi	sp,sp,32
    80001568:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000156a:	6605                	lui	a2,0x1
    8000156c:	167d                	addi	a2,a2,-1
    8000156e:	962e                	add	a2,a2,a1
    80001570:	4685                	li	a3,1
    80001572:	8231                	srli	a2,a2,0xc
    80001574:	4581                	li	a1,0
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	d0a080e7          	jalr	-758(ra) # 80001280 <uvmunmap>
    8000157e:	bfe1                	j	80001556 <uvmfree+0xe>

0000000080001580 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001580:	c679                	beqz	a2,8000164e <uvmcopy+0xce>
{
    80001582:	715d                	addi	sp,sp,-80
    80001584:	e486                	sd	ra,72(sp)
    80001586:	e0a2                	sd	s0,64(sp)
    80001588:	fc26                	sd	s1,56(sp)
    8000158a:	f84a                	sd	s2,48(sp)
    8000158c:	f44e                	sd	s3,40(sp)
    8000158e:	f052                	sd	s4,32(sp)
    80001590:	ec56                	sd	s5,24(sp)
    80001592:	e85a                	sd	s6,16(sp)
    80001594:	e45e                	sd	s7,8(sp)
    80001596:	0880                	addi	s0,sp,80
    80001598:	8b2a                	mv	s6,a0
    8000159a:	8aae                	mv	s5,a1
    8000159c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000159e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015a0:	4601                	li	a2,0
    800015a2:	85ce                	mv	a1,s3
    800015a4:	855a                	mv	a0,s6
    800015a6:	00000097          	auipc	ra,0x0
    800015aa:	a2c080e7          	jalr	-1492(ra) # 80000fd2 <walk>
    800015ae:	c531                	beqz	a0,800015fa <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015b0:	6118                	ld	a4,0(a0)
    800015b2:	00177793          	andi	a5,a4,1
    800015b6:	cbb1                	beqz	a5,8000160a <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015b8:	00a75593          	srli	a1,a4,0xa
    800015bc:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015c0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015c4:	fffff097          	auipc	ra,0xfffff
    800015c8:	536080e7          	jalr	1334(ra) # 80000afa <kalloc>
    800015cc:	892a                	mv	s2,a0
    800015ce:	c939                	beqz	a0,80001624 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015d0:	6605                	lui	a2,0x1
    800015d2:	85de                	mv	a1,s7
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	772080e7          	jalr	1906(ra) # 80000d46 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015dc:	8726                	mv	a4,s1
    800015de:	86ca                	mv	a3,s2
    800015e0:	6605                	lui	a2,0x1
    800015e2:	85ce                	mv	a1,s3
    800015e4:	8556                	mv	a0,s5
    800015e6:	00000097          	auipc	ra,0x0
    800015ea:	ad4080e7          	jalr	-1324(ra) # 800010ba <mappages>
    800015ee:	e515                	bnez	a0,8000161a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015f0:	6785                	lui	a5,0x1
    800015f2:	99be                	add	s3,s3,a5
    800015f4:	fb49e6e3          	bltu	s3,s4,800015a0 <uvmcopy+0x20>
    800015f8:	a081                	j	80001638 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015fa:	00007517          	auipc	a0,0x7
    800015fe:	b8e50513          	addi	a0,a0,-1138 # 80008188 <digits+0x148>
    80001602:	fffff097          	auipc	ra,0xfffff
    80001606:	f42080e7          	jalr	-190(ra) # 80000544 <panic>
      panic("uvmcopy: page not present");
    8000160a:	00007517          	auipc	a0,0x7
    8000160e:	b9e50513          	addi	a0,a0,-1122 # 800081a8 <digits+0x168>
    80001612:	fffff097          	auipc	ra,0xfffff
    80001616:	f32080e7          	jalr	-206(ra) # 80000544 <panic>
      kfree(mem);
    8000161a:	854a                	mv	a0,s2
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	3e2080e7          	jalr	994(ra) # 800009fe <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001624:	4685                	li	a3,1
    80001626:	00c9d613          	srli	a2,s3,0xc
    8000162a:	4581                	li	a1,0
    8000162c:	8556                	mv	a0,s5
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	c52080e7          	jalr	-942(ra) # 80001280 <uvmunmap>
  return -1;
    80001636:	557d                	li	a0,-1
}
    80001638:	60a6                	ld	ra,72(sp)
    8000163a:	6406                	ld	s0,64(sp)
    8000163c:	74e2                	ld	s1,56(sp)
    8000163e:	7942                	ld	s2,48(sp)
    80001640:	79a2                	ld	s3,40(sp)
    80001642:	7a02                	ld	s4,32(sp)
    80001644:	6ae2                	ld	s5,24(sp)
    80001646:	6b42                	ld	s6,16(sp)
    80001648:	6ba2                	ld	s7,8(sp)
    8000164a:	6161                	addi	sp,sp,80
    8000164c:	8082                	ret
  return 0;
    8000164e:	4501                	li	a0,0
}
    80001650:	8082                	ret

0000000080001652 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001652:	1141                	addi	sp,sp,-16
    80001654:	e406                	sd	ra,8(sp)
    80001656:	e022                	sd	s0,0(sp)
    80001658:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000165a:	4601                	li	a2,0
    8000165c:	00000097          	auipc	ra,0x0
    80001660:	976080e7          	jalr	-1674(ra) # 80000fd2 <walk>
  if(pte == 0)
    80001664:	c901                	beqz	a0,80001674 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001666:	611c                	ld	a5,0(a0)
    80001668:	9bbd                	andi	a5,a5,-17
    8000166a:	e11c                	sd	a5,0(a0)
}
    8000166c:	60a2                	ld	ra,8(sp)
    8000166e:	6402                	ld	s0,0(sp)
    80001670:	0141                	addi	sp,sp,16
    80001672:	8082                	ret
    panic("uvmclear");
    80001674:	00007517          	auipc	a0,0x7
    80001678:	b5450513          	addi	a0,a0,-1196 # 800081c8 <digits+0x188>
    8000167c:	fffff097          	auipc	ra,0xfffff
    80001680:	ec8080e7          	jalr	-312(ra) # 80000544 <panic>

0000000080001684 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001684:	c6bd                	beqz	a3,800016f2 <copyout+0x6e>
{
    80001686:	715d                	addi	sp,sp,-80
    80001688:	e486                	sd	ra,72(sp)
    8000168a:	e0a2                	sd	s0,64(sp)
    8000168c:	fc26                	sd	s1,56(sp)
    8000168e:	f84a                	sd	s2,48(sp)
    80001690:	f44e                	sd	s3,40(sp)
    80001692:	f052                	sd	s4,32(sp)
    80001694:	ec56                	sd	s5,24(sp)
    80001696:	e85a                	sd	s6,16(sp)
    80001698:	e45e                	sd	s7,8(sp)
    8000169a:	e062                	sd	s8,0(sp)
    8000169c:	0880                	addi	s0,sp,80
    8000169e:	8b2a                	mv	s6,a0
    800016a0:	8c2e                	mv	s8,a1
    800016a2:	8a32                	mv	s4,a2
    800016a4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016a6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016a8:	6a85                	lui	s5,0x1
    800016aa:	a015                	j	800016ce <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016ac:	9562                	add	a0,a0,s8
    800016ae:	0004861b          	sext.w	a2,s1
    800016b2:	85d2                	mv	a1,s4
    800016b4:	41250533          	sub	a0,a0,s2
    800016b8:	fffff097          	auipc	ra,0xfffff
    800016bc:	68e080e7          	jalr	1678(ra) # 80000d46 <memmove>

    len -= n;
    800016c0:	409989b3          	sub	s3,s3,s1
    src += n;
    800016c4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016c6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ca:	02098263          	beqz	s3,800016ee <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ce:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016d2:	85ca                	mv	a1,s2
    800016d4:	855a                	mv	a0,s6
    800016d6:	00000097          	auipc	ra,0x0
    800016da:	9a2080e7          	jalr	-1630(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    800016de:	cd01                	beqz	a0,800016f6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e0:	418904b3          	sub	s1,s2,s8
    800016e4:	94d6                	add	s1,s1,s5
    if(n > len)
    800016e6:	fc99f3e3          	bgeu	s3,s1,800016ac <copyout+0x28>
    800016ea:	84ce                	mv	s1,s3
    800016ec:	b7c1                	j	800016ac <copyout+0x28>
  }
  return 0;
    800016ee:	4501                	li	a0,0
    800016f0:	a021                	j	800016f8 <copyout+0x74>
    800016f2:	4501                	li	a0,0
}
    800016f4:	8082                	ret
      return -1;
    800016f6:	557d                	li	a0,-1
}
    800016f8:	60a6                	ld	ra,72(sp)
    800016fa:	6406                	ld	s0,64(sp)
    800016fc:	74e2                	ld	s1,56(sp)
    800016fe:	7942                	ld	s2,48(sp)
    80001700:	79a2                	ld	s3,40(sp)
    80001702:	7a02                	ld	s4,32(sp)
    80001704:	6ae2                	ld	s5,24(sp)
    80001706:	6b42                	ld	s6,16(sp)
    80001708:	6ba2                	ld	s7,8(sp)
    8000170a:	6c02                	ld	s8,0(sp)
    8000170c:	6161                	addi	sp,sp,80
    8000170e:	8082                	ret

0000000080001710 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001710:	c6bd                	beqz	a3,8000177e <copyin+0x6e>
{
    80001712:	715d                	addi	sp,sp,-80
    80001714:	e486                	sd	ra,72(sp)
    80001716:	e0a2                	sd	s0,64(sp)
    80001718:	fc26                	sd	s1,56(sp)
    8000171a:	f84a                	sd	s2,48(sp)
    8000171c:	f44e                	sd	s3,40(sp)
    8000171e:	f052                	sd	s4,32(sp)
    80001720:	ec56                	sd	s5,24(sp)
    80001722:	e85a                	sd	s6,16(sp)
    80001724:	e45e                	sd	s7,8(sp)
    80001726:	e062                	sd	s8,0(sp)
    80001728:	0880                	addi	s0,sp,80
    8000172a:	8b2a                	mv	s6,a0
    8000172c:	8a2e                	mv	s4,a1
    8000172e:	8c32                	mv	s8,a2
    80001730:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001732:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001734:	6a85                	lui	s5,0x1
    80001736:	a015                	j	8000175a <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001738:	9562                	add	a0,a0,s8
    8000173a:	0004861b          	sext.w	a2,s1
    8000173e:	412505b3          	sub	a1,a0,s2
    80001742:	8552                	mv	a0,s4
    80001744:	fffff097          	auipc	ra,0xfffff
    80001748:	602080e7          	jalr	1538(ra) # 80000d46 <memmove>

    len -= n;
    8000174c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001750:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001752:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001756:	02098263          	beqz	s3,8000177a <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000175a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175e:	85ca                	mv	a1,s2
    80001760:	855a                	mv	a0,s6
    80001762:	00000097          	auipc	ra,0x0
    80001766:	916080e7          	jalr	-1770(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    8000176a:	cd01                	beqz	a0,80001782 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000176c:	418904b3          	sub	s1,s2,s8
    80001770:	94d6                	add	s1,s1,s5
    if(n > len)
    80001772:	fc99f3e3          	bgeu	s3,s1,80001738 <copyin+0x28>
    80001776:	84ce                	mv	s1,s3
    80001778:	b7c1                	j	80001738 <copyin+0x28>
  }
  return 0;
    8000177a:	4501                	li	a0,0
    8000177c:	a021                	j	80001784 <copyin+0x74>
    8000177e:	4501                	li	a0,0
}
    80001780:	8082                	ret
      return -1;
    80001782:	557d                	li	a0,-1
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret

000000008000179c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000179c:	c6c5                	beqz	a3,80001844 <copyinstr+0xa8>
{
    8000179e:	715d                	addi	sp,sp,-80
    800017a0:	e486                	sd	ra,72(sp)
    800017a2:	e0a2                	sd	s0,64(sp)
    800017a4:	fc26                	sd	s1,56(sp)
    800017a6:	f84a                	sd	s2,48(sp)
    800017a8:	f44e                	sd	s3,40(sp)
    800017aa:	f052                	sd	s4,32(sp)
    800017ac:	ec56                	sd	s5,24(sp)
    800017ae:	e85a                	sd	s6,16(sp)
    800017b0:	e45e                	sd	s7,8(sp)
    800017b2:	0880                	addi	s0,sp,80
    800017b4:	8a2a                	mv	s4,a0
    800017b6:	8b2e                	mv	s6,a1
    800017b8:	8bb2                	mv	s7,a2
    800017ba:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017bc:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017be:	6985                	lui	s3,0x1
    800017c0:	a035                	j	800017ec <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017c2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017c6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017c8:	0017b793          	seqz	a5,a5
    800017cc:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d0:	60a6                	ld	ra,72(sp)
    800017d2:	6406                	ld	s0,64(sp)
    800017d4:	74e2                	ld	s1,56(sp)
    800017d6:	7942                	ld	s2,48(sp)
    800017d8:	79a2                	ld	s3,40(sp)
    800017da:	7a02                	ld	s4,32(sp)
    800017dc:	6ae2                	ld	s5,24(sp)
    800017de:	6b42                	ld	s6,16(sp)
    800017e0:	6ba2                	ld	s7,8(sp)
    800017e2:	6161                	addi	sp,sp,80
    800017e4:	8082                	ret
    srcva = va0 + PGSIZE;
    800017e6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017ea:	c8a9                	beqz	s1,8000183c <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017ec:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f0:	85ca                	mv	a1,s2
    800017f2:	8552                	mv	a0,s4
    800017f4:	00000097          	auipc	ra,0x0
    800017f8:	884080e7          	jalr	-1916(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    800017fc:	c131                	beqz	a0,80001840 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017fe:	41790833          	sub	a6,s2,s7
    80001802:	984e                	add	a6,a6,s3
    if(n > max)
    80001804:	0104f363          	bgeu	s1,a6,8000180a <copyinstr+0x6e>
    80001808:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000180a:	955e                	add	a0,a0,s7
    8000180c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001810:	fc080be3          	beqz	a6,800017e6 <copyinstr+0x4a>
    80001814:	985a                	add	a6,a6,s6
    80001816:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001818:	41650633          	sub	a2,a0,s6
    8000181c:	14fd                	addi	s1,s1,-1
    8000181e:	9b26                	add	s6,s6,s1
    80001820:	00f60733          	add	a4,a2,a5
    80001824:	00074703          	lbu	a4,0(a4)
    80001828:	df49                	beqz	a4,800017c2 <copyinstr+0x26>
        *dst = *p;
    8000182a:	00e78023          	sb	a4,0(a5)
      --max;
    8000182e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001832:	0785                	addi	a5,a5,1
    while(n > 0){
    80001834:	ff0796e3          	bne	a5,a6,80001820 <copyinstr+0x84>
      dst++;
    80001838:	8b42                	mv	s6,a6
    8000183a:	b775                	j	800017e6 <copyinstr+0x4a>
    8000183c:	4781                	li	a5,0
    8000183e:	b769                	j	800017c8 <copyinstr+0x2c>
      return -1;
    80001840:	557d                	li	a0,-1
    80001842:	b779                	j	800017d0 <copyinstr+0x34>
  int got_null = 0;
    80001844:	4781                	li	a5,0
  if(got_null){
    80001846:	0017b793          	seqz	a5,a5
    8000184a:	40f00533          	neg	a0,a5
}
    8000184e:	8082                	ret

0000000080001850 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001850:	7139                	addi	sp,sp,-64
    80001852:	fc06                	sd	ra,56(sp)
    80001854:	f822                	sd	s0,48(sp)
    80001856:	f426                	sd	s1,40(sp)
    80001858:	f04a                	sd	s2,32(sp)
    8000185a:	ec4e                	sd	s3,24(sp)
    8000185c:	e852                	sd	s4,16(sp)
    8000185e:	e456                	sd	s5,8(sp)
    80001860:	e05a                	sd	s6,0(sp)
    80001862:	0080                	addi	s0,sp,64
    80001864:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00010497          	auipc	s1,0x10
    8000186a:	90a48493          	addi	s1,s1,-1782 # 80011170 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000186e:	8b26                	mv	s6,s1
    80001870:	00006a97          	auipc	s5,0x6
    80001874:	790a8a93          	addi	s5,s5,1936 # 80008000 <etext>
    80001878:	04000937          	lui	s2,0x4000
    8000187c:	197d                	addi	s2,s2,-1
    8000187e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001880:	00016a17          	auipc	s4,0x16
    80001884:	af0a0a13          	addi	s4,s4,-1296 # 80017370 <tickslock>
    char *pa = kalloc();
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	272080e7          	jalr	626(ra) # 80000afa <kalloc>
    80001890:	862a                	mv	a2,a0
    if(pa == 0)
    80001892:	c131                	beqz	a0,800018d6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001894:	416485b3          	sub	a1,s1,s6
    80001898:	858d                	srai	a1,a1,0x3
    8000189a:	000ab783          	ld	a5,0(s5)
    8000189e:	02f585b3          	mul	a1,a1,a5
    800018a2:	2585                	addiw	a1,a1,1
    800018a4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018a8:	4719                	li	a4,6
    800018aa:	6685                	lui	a3,0x1
    800018ac:	40b905b3          	sub	a1,s2,a1
    800018b0:	854e                	mv	a0,s3
    800018b2:	00000097          	auipc	ra,0x0
    800018b6:	8a8080e7          	jalr	-1880(ra) # 8000115a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ba:	18848493          	addi	s1,s1,392
    800018be:	fd4495e3          	bne	s1,s4,80001888 <proc_mapstacks+0x38>
  }
}
    800018c2:	70e2                	ld	ra,56(sp)
    800018c4:	7442                	ld	s0,48(sp)
    800018c6:	74a2                	ld	s1,40(sp)
    800018c8:	7902                	ld	s2,32(sp)
    800018ca:	69e2                	ld	s3,24(sp)
    800018cc:	6a42                	ld	s4,16(sp)
    800018ce:	6aa2                	ld	s5,8(sp)
    800018d0:	6b02                	ld	s6,0(sp)
    800018d2:	6121                	addi	sp,sp,64
    800018d4:	8082                	ret
      panic("kalloc");
    800018d6:	00007517          	auipc	a0,0x7
    800018da:	90250513          	addi	a0,a0,-1790 # 800081d8 <digits+0x198>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	c66080e7          	jalr	-922(ra) # 80000544 <panic>

00000000800018e6 <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018e6:	7139                	addi	sp,sp,-64
    800018e8:	fc06                	sd	ra,56(sp)
    800018ea:	f822                	sd	s0,48(sp)
    800018ec:	f426                	sd	s1,40(sp)
    800018ee:	f04a                	sd	s2,32(sp)
    800018f0:	ec4e                	sd	s3,24(sp)
    800018f2:	e852                	sd	s4,16(sp)
    800018f4:	e456                	sd	s5,8(sp)
    800018f6:	e05a                	sd	s6,0(sp)
    800018f8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018fa:	00007597          	auipc	a1,0x7
    800018fe:	8e658593          	addi	a1,a1,-1818 # 800081e0 <digits+0x1a0>
    80001902:	0000f517          	auipc	a0,0xf
    80001906:	43e50513          	addi	a0,a0,1086 # 80010d40 <pid_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	250080e7          	jalr	592(ra) # 80000b5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001912:	00007597          	auipc	a1,0x7
    80001916:	8d658593          	addi	a1,a1,-1834 # 800081e8 <digits+0x1a8>
    8000191a:	0000f517          	auipc	a0,0xf
    8000191e:	43e50513          	addi	a0,a0,1086 # 80010d58 <wait_lock>
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	238080e7          	jalr	568(ra) # 80000b5a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192a:	00010497          	auipc	s1,0x10
    8000192e:	84648493          	addi	s1,s1,-1978 # 80011170 <proc>
      initlock(&p->lock, "proc");
    80001932:	00007b17          	auipc	s6,0x7
    80001936:	8c6b0b13          	addi	s6,s6,-1850 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000193a:	8aa6                	mv	s5,s1
    8000193c:	00006a17          	auipc	s4,0x6
    80001940:	6c4a0a13          	addi	s4,s4,1732 # 80008000 <etext>
    80001944:	04000937          	lui	s2,0x4000
    80001948:	197d                	addi	s2,s2,-1
    8000194a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194c:	00016997          	auipc	s3,0x16
    80001950:	a2498993          	addi	s3,s3,-1500 # 80017370 <tickslock>
      initlock(&p->lock, "proc");
    80001954:	85da                	mv	a1,s6
    80001956:	8526                	mv	a0,s1
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	202080e7          	jalr	514(ra) # 80000b5a <initlock>
      p->state = UNUSED;
    80001960:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001964:	415487b3          	sub	a5,s1,s5
    80001968:	878d                	srai	a5,a5,0x3
    8000196a:	000a3703          	ld	a4,0(s4)
    8000196e:	02e787b3          	mul	a5,a5,a4
    80001972:	2785                	addiw	a5,a5,1
    80001974:	00d7979b          	slliw	a5,a5,0xd
    80001978:	40f907b3          	sub	a5,s2,a5
    8000197c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197e:	18848493          	addi	s1,s1,392
    80001982:	fd3499e3          	bne	s1,s3,80001954 <procinit+0x6e>
  }
}
    80001986:	70e2                	ld	ra,56(sp)
    80001988:	7442                	ld	s0,48(sp)
    8000198a:	74a2                	ld	s1,40(sp)
    8000198c:	7902                	ld	s2,32(sp)
    8000198e:	69e2                	ld	s3,24(sp)
    80001990:	6a42                	ld	s4,16(sp)
    80001992:	6aa2                	ld	s5,8(sp)
    80001994:	6b02                	ld	s6,0(sp)
    80001996:	6121                	addi	sp,sp,64
    80001998:	8082                	ret

000000008000199a <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    8000199a:	1141                	addi	sp,sp,-16
    8000199c:	e422                	sd	s0,8(sp)
    8000199e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019a0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019a2:	2501                	sext.w	a0,a0
    800019a4:	6422                	ld	s0,8(sp)
    800019a6:	0141                	addi	sp,sp,16
    800019a8:	8082                	ret

00000000800019aa <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu* mycpu(void)
{
    800019aa:	1141                	addi	sp,sp,-16
    800019ac:	e422                	sd	s0,8(sp)
    800019ae:	0800                	addi	s0,sp,16
    800019b0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019b2:	2781                	sext.w	a5,a5
    800019b4:	079e                	slli	a5,a5,0x7
  return c;
}
    800019b6:	0000f517          	auipc	a0,0xf
    800019ba:	3ba50513          	addi	a0,a0,954 # 80010d70 <cpus>
    800019be:	953e                	add	a0,a0,a5
    800019c0:	6422                	ld	s0,8(sp)
    800019c2:	0141                	addi	sp,sp,16
    800019c4:	8082                	ret

00000000800019c6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc* myproc(void)
{
    800019c6:	1101                	addi	sp,sp,-32
    800019c8:	ec06                	sd	ra,24(sp)
    800019ca:	e822                	sd	s0,16(sp)
    800019cc:	e426                	sd	s1,8(sp)
    800019ce:	1000                	addi	s0,sp,32
  push_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	1ce080e7          	jalr	462(ra) # 80000b9e <push_off>
    800019d8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019da:	2781                	sext.w	a5,a5
    800019dc:	079e                	slli	a5,a5,0x7
    800019de:	0000f717          	auipc	a4,0xf
    800019e2:	36270713          	addi	a4,a4,866 # 80010d40 <pid_lock>
    800019e6:	97ba                	add	a5,a5,a4
    800019e8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	254080e7          	jalr	596(ra) # 80000c3e <pop_off>
  return p;
}
    800019f2:	8526                	mv	a0,s1
    800019f4:	60e2                	ld	ra,24(sp)
    800019f6:	6442                	ld	s0,16(sp)
    800019f8:	64a2                	ld	s1,8(sp)
    800019fa:	6105                	addi	sp,sp,32
    800019fc:	8082                	ret

00000000800019fe <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800019fe:	1141                	addi	sp,sp,-16
    80001a00:	e406                	sd	ra,8(sp)
    80001a02:	e022                	sd	s0,0(sp)
    80001a04:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a06:	00000097          	auipc	ra,0x0
    80001a0a:	fc0080e7          	jalr	-64(ra) # 800019c6 <myproc>
    80001a0e:	fffff097          	auipc	ra,0xfffff
    80001a12:	290080e7          	jalr	656(ra) # 80000c9e <release>

  if (first) {
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	03a7a783          	lw	a5,58(a5) # 80008a50 <first.1713>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	0e2080e7          	jalr	226(ra) # 80002b02 <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	0207a023          	sw	zero,32(a5) # 80008a50 <first.1713>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	f5e080e7          	jalr	-162(ra) # 80003998 <fsinit>
    80001a42:	bff9                	j	80001a20 <forkret+0x22>

0000000080001a44 <allocpid>:
{
    80001a44:	1101                	addi	sp,sp,-32
    80001a46:	ec06                	sd	ra,24(sp)
    80001a48:	e822                	sd	s0,16(sp)
    80001a4a:	e426                	sd	s1,8(sp)
    80001a4c:	e04a                	sd	s2,0(sp)
    80001a4e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a50:	0000f917          	auipc	s2,0xf
    80001a54:	2f090913          	addi	s2,s2,752 # 80010d40 <pid_lock>
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	190080e7          	jalr	400(ra) # 80000bea <acquire>
  pid = nextpid;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	ff278793          	addi	a5,a5,-14 # 80008a54 <nextpid>
    80001a6a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a6c:	0014871b          	addiw	a4,s1,1
    80001a70:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a72:	854a                	mv	a0,s2
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	22a080e7          	jalr	554(ra) # 80000c9e <release>
}
    80001a7c:	8526                	mv	a0,s1
    80001a7e:	60e2                	ld	ra,24(sp)
    80001a80:	6442                	ld	s0,16(sp)
    80001a82:	64a2                	ld	s1,8(sp)
    80001a84:	6902                	ld	s2,0(sp)
    80001a86:	6105                	addi	sp,sp,32
    80001a88:	8082                	ret

0000000080001a8a <proc_pagetable>:
{
    80001a8a:	1101                	addi	sp,sp,-32
    80001a8c:	ec06                	sd	ra,24(sp)
    80001a8e:	e822                	sd	s0,16(sp)
    80001a90:	e426                	sd	s1,8(sp)
    80001a92:	e04a                	sd	s2,0(sp)
    80001a94:	1000                	addi	s0,sp,32
    80001a96:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a98:	00000097          	auipc	ra,0x0
    80001a9c:	8ac080e7          	jalr	-1876(ra) # 80001344 <uvmcreate>
    80001aa0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aa2:	c121                	beqz	a0,80001ae2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aa4:	4729                	li	a4,10
    80001aa6:	00005697          	auipc	a3,0x5
    80001aaa:	55a68693          	addi	a3,a3,1370 # 80007000 <_trampoline>
    80001aae:	6605                	lui	a2,0x1
    80001ab0:	040005b7          	lui	a1,0x4000
    80001ab4:	15fd                	addi	a1,a1,-1
    80001ab6:	05b2                	slli	a1,a1,0xc
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	602080e7          	jalr	1538(ra) # 800010ba <mappages>
    80001ac0:	02054863          	bltz	a0,80001af0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac4:	4719                	li	a4,6
    80001ac6:	05893683          	ld	a3,88(s2)
    80001aca:	6605                	lui	a2,0x1
    80001acc:	020005b7          	lui	a1,0x2000
    80001ad0:	15fd                	addi	a1,a1,-1
    80001ad2:	05b6                	slli	a1,a1,0xd
    80001ad4:	8526                	mv	a0,s1
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	5e4080e7          	jalr	1508(ra) # 800010ba <mappages>
    80001ade:	02054163          	bltz	a0,80001b00 <proc_pagetable+0x76>
}
    80001ae2:	8526                	mv	a0,s1
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6902                	ld	s2,0(sp)
    80001aec:	6105                	addi	sp,sp,32
    80001aee:	8082                	ret
    uvmfree(pagetable, 0);
    80001af0:	4581                	li	a1,0
    80001af2:	8526                	mv	a0,s1
    80001af4:	00000097          	auipc	ra,0x0
    80001af8:	a54080e7          	jalr	-1452(ra) # 80001548 <uvmfree>
    return 0;
    80001afc:	4481                	li	s1,0
    80001afe:	b7d5                	j	80001ae2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b00:	4681                	li	a3,0
    80001b02:	4605                	li	a2,1
    80001b04:	040005b7          	lui	a1,0x4000
    80001b08:	15fd                	addi	a1,a1,-1
    80001b0a:	05b2                	slli	a1,a1,0xc
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	772080e7          	jalr	1906(ra) # 80001280 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b16:	4581                	li	a1,0
    80001b18:	8526                	mv	a0,s1
    80001b1a:	00000097          	auipc	ra,0x0
    80001b1e:	a2e080e7          	jalr	-1490(ra) # 80001548 <uvmfree>
    return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	bf7d                	j	80001ae2 <proc_pagetable+0x58>

0000000080001b26 <proc_freepagetable>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
    80001b32:	84aa                	mv	s1,a0
    80001b34:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b36:	4681                	li	a3,0
    80001b38:	4605                	li	a2,1
    80001b3a:	040005b7          	lui	a1,0x4000
    80001b3e:	15fd                	addi	a1,a1,-1
    80001b40:	05b2                	slli	a1,a1,0xc
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	73e080e7          	jalr	1854(ra) # 80001280 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b4a:	4681                	li	a3,0
    80001b4c:	4605                	li	a2,1
    80001b4e:	020005b7          	lui	a1,0x2000
    80001b52:	15fd                	addi	a1,a1,-1
    80001b54:	05b6                	slli	a1,a1,0xd
    80001b56:	8526                	mv	a0,s1
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	728080e7          	jalr	1832(ra) # 80001280 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b60:	85ca                	mv	a1,s2
    80001b62:	8526                	mv	a0,s1
    80001b64:	00000097          	auipc	ra,0x0
    80001b68:	9e4080e7          	jalr	-1564(ra) # 80001548 <uvmfree>
}
    80001b6c:	60e2                	ld	ra,24(sp)
    80001b6e:	6442                	ld	s0,16(sp)
    80001b70:	64a2                	ld	s1,8(sp)
    80001b72:	6902                	ld	s2,0(sp)
    80001b74:	6105                	addi	sp,sp,32
    80001b76:	8082                	ret

0000000080001b78 <freeproc>:
{
    80001b78:	1101                	addi	sp,sp,-32
    80001b7a:	ec06                	sd	ra,24(sp)
    80001b7c:	e822                	sd	s0,16(sp)
    80001b7e:	e426                	sd	s1,8(sp)
    80001b80:	1000                	addi	s0,sp,32
    80001b82:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b84:	6d28                	ld	a0,88(a0)
    80001b86:	c509                	beqz	a0,80001b90 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b88:	fffff097          	auipc	ra,0xfffff
    80001b8c:	e76080e7          	jalr	-394(ra) # 800009fe <kfree>
  p->trapframe = 0;
    80001b90:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b94:	68a8                	ld	a0,80(s1)
    80001b96:	c511                	beqz	a0,80001ba2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b98:	64ac                	ld	a1,72(s1)
    80001b9a:	00000097          	auipc	ra,0x0
    80001b9e:	f8c080e7          	jalr	-116(ra) # 80001b26 <proc_freepagetable>
  p->pagetable = 0;
    80001ba2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ba6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001baa:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bae:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bb2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bb6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bba:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bbe:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bc2:	0004ac23          	sw	zero,24(s1)
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <allocproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bdc:	0000f497          	auipc	s1,0xf
    80001be0:	59448493          	addi	s1,s1,1428 # 80011170 <proc>
    80001be4:	00015917          	auipc	s2,0x15
    80001be8:	78c90913          	addi	s2,s2,1932 # 80017370 <tickslock>
    acquire(&p->lock);
    80001bec:	8526                	mv	a0,s1
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	ffc080e7          	jalr	-4(ra) # 80000bea <acquire>
    if(p->state == UNUSED) {
    80001bf6:	4c9c                	lw	a5,24(s1)
    80001bf8:	cf81                	beqz	a5,80001c10 <allocproc+0x40>
      release(&p->lock);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	0a2080e7          	jalr	162(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c04:	18848493          	addi	s1,s1,392
    80001c08:	ff2492e3          	bne	s1,s2,80001bec <allocproc+0x1c>
  return 0;
    80001c0c:	4481                	li	s1,0
    80001c0e:	a889                	j	80001c60 <allocproc+0x90>
  p->pid = allocpid();
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	e34080e7          	jalr	-460(ra) # 80001a44 <allocpid>
    80001c18:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c1a:	4785                	li	a5,1
    80001c1c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	edc080e7          	jalr	-292(ra) # 80000afa <kalloc>
    80001c26:	892a                	mv	s2,a0
    80001c28:	eca8                	sd	a0,88(s1)
    80001c2a:	c131                	beqz	a0,80001c6e <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	00000097          	auipc	ra,0x0
    80001c32:	e5c080e7          	jalr	-420(ra) # 80001a8a <proc_pagetable>
    80001c36:	892a                	mv	s2,a0
    80001c38:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c3a:	c531                	beqz	a0,80001c86 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c3c:	07000613          	li	a2,112
    80001c40:	4581                	li	a1,0
    80001c42:	06048513          	addi	a0,s1,96
    80001c46:	fffff097          	auipc	ra,0xfffff
    80001c4a:	0a0080e7          	jalr	160(ra) # 80000ce6 <memset>
  p->context.ra = (uint64)forkret;
    80001c4e:	00000797          	auipc	a5,0x0
    80001c52:	db078793          	addi	a5,a5,-592 # 800019fe <forkret>
    80001c56:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c58:	60bc                	ld	a5,64(s1)
    80001c5a:	6705                	lui	a4,0x1
    80001c5c:	97ba                	add	a5,a5,a4
    80001c5e:	f4bc                	sd	a5,104(s1)
}
    80001c60:	8526                	mv	a0,s1
    80001c62:	60e2                	ld	ra,24(sp)
    80001c64:	6442                	ld	s0,16(sp)
    80001c66:	64a2                	ld	s1,8(sp)
    80001c68:	6902                	ld	s2,0(sp)
    80001c6a:	6105                	addi	sp,sp,32
    80001c6c:	8082                	ret
    freeproc(p);
    80001c6e:	8526                	mv	a0,s1
    80001c70:	00000097          	auipc	ra,0x0
    80001c74:	f08080e7          	jalr	-248(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	fffff097          	auipc	ra,0xfffff
    80001c7e:	024080e7          	jalr	36(ra) # 80000c9e <release>
    return 0;
    80001c82:	84ca                	mv	s1,s2
    80001c84:	bff1                	j	80001c60 <allocproc+0x90>
    freeproc(p);
    80001c86:	8526                	mv	a0,s1
    80001c88:	00000097          	auipc	ra,0x0
    80001c8c:	ef0080e7          	jalr	-272(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001c90:	8526                	mv	a0,s1
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	00c080e7          	jalr	12(ra) # 80000c9e <release>
    return 0;
    80001c9a:	84ca                	mv	s1,s2
    80001c9c:	b7d1                	j	80001c60 <allocproc+0x90>

0000000080001c9e <userinit>:
{
    80001c9e:	1101                	addi	sp,sp,-32
    80001ca0:	ec06                	sd	ra,24(sp)
    80001ca2:	e822                	sd	s0,16(sp)
    80001ca4:	e426                	sd	s1,8(sp)
    80001ca6:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ca8:	00000097          	auipc	ra,0x0
    80001cac:	f28080e7          	jalr	-216(ra) # 80001bd0 <allocproc>
    80001cb0:	84aa                	mv	s1,a0
  initproc = p;
    80001cb2:	00007797          	auipc	a5,0x7
    80001cb6:	e0a7bb23          	sd	a0,-490(a5) # 80008ac8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cba:	03400613          	li	a2,52
    80001cbe:	00007597          	auipc	a1,0x7
    80001cc2:	da258593          	addi	a1,a1,-606 # 80008a60 <initcode>
    80001cc6:	6928                	ld	a0,80(a0)
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	6aa080e7          	jalr	1706(ra) # 80001372 <uvmfirst>
  p->sz = PGSIZE;
    80001cd0:	6785                	lui	a5,0x1
    80001cd2:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd4:	6cb8                	ld	a4,88(s1)
    80001cd6:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cda:	6cb8                	ld	a4,88(s1)
    80001cdc:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cde:	4641                	li	a2,16
    80001ce0:	00006597          	auipc	a1,0x6
    80001ce4:	52058593          	addi	a1,a1,1312 # 80008200 <digits+0x1c0>
    80001ce8:	15848513          	addi	a0,s1,344
    80001cec:	fffff097          	auipc	ra,0xfffff
    80001cf0:	14c080e7          	jalr	332(ra) # 80000e38 <safestrcpy>
  p->cwd = namei("/");
    80001cf4:	00006517          	auipc	a0,0x6
    80001cf8:	51c50513          	addi	a0,a0,1308 # 80008210 <digits+0x1d0>
    80001cfc:	00002097          	auipc	ra,0x2
    80001d00:	6be080e7          	jalr	1726(ra) # 800043ba <namei>
    80001d04:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d08:	478d                	li	a5,3
    80001d0a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	f90080e7          	jalr	-112(ra) # 80000c9e <release>
}
    80001d16:	60e2                	ld	ra,24(sp)
    80001d18:	6442                	ld	s0,16(sp)
    80001d1a:	64a2                	ld	s1,8(sp)
    80001d1c:	6105                	addi	sp,sp,32
    80001d1e:	8082                	ret

0000000080001d20 <growproc>:
{
    80001d20:	1101                	addi	sp,sp,-32
    80001d22:	ec06                	sd	ra,24(sp)
    80001d24:	e822                	sd	s0,16(sp)
    80001d26:	e426                	sd	s1,8(sp)
    80001d28:	e04a                	sd	s2,0(sp)
    80001d2a:	1000                	addi	s0,sp,32
    80001d2c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d2e:	00000097          	auipc	ra,0x0
    80001d32:	c98080e7          	jalr	-872(ra) # 800019c6 <myproc>
    80001d36:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d38:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d3a:	01204c63          	bgtz	s2,80001d52 <growproc+0x32>
  } else if(n < 0){
    80001d3e:	02094663          	bltz	s2,80001d6a <growproc+0x4a>
  p->sz = sz;
    80001d42:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d44:	4501                	li	a0,0
}
    80001d46:	60e2                	ld	ra,24(sp)
    80001d48:	6442                	ld	s0,16(sp)
    80001d4a:	64a2                	ld	s1,8(sp)
    80001d4c:	6902                	ld	s2,0(sp)
    80001d4e:	6105                	addi	sp,sp,32
    80001d50:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d52:	4691                	li	a3,4
    80001d54:	00b90633          	add	a2,s2,a1
    80001d58:	6928                	ld	a0,80(a0)
    80001d5a:	fffff097          	auipc	ra,0xfffff
    80001d5e:	6d2080e7          	jalr	1746(ra) # 8000142c <uvmalloc>
    80001d62:	85aa                	mv	a1,a0
    80001d64:	fd79                	bnez	a0,80001d42 <growproc+0x22>
      return -1;
    80001d66:	557d                	li	a0,-1
    80001d68:	bff9                	j	80001d46 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d6a:	00b90633          	add	a2,s2,a1
    80001d6e:	6928                	ld	a0,80(a0)
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	674080e7          	jalr	1652(ra) # 800013e4 <uvmdealloc>
    80001d78:	85aa                	mv	a1,a0
    80001d7a:	b7e1                	j	80001d42 <growproc+0x22>

0000000080001d7c <fork>:
{
    80001d7c:	7179                	addi	sp,sp,-48
    80001d7e:	f406                	sd	ra,40(sp)
    80001d80:	f022                	sd	s0,32(sp)
    80001d82:	ec26                	sd	s1,24(sp)
    80001d84:	e84a                	sd	s2,16(sp)
    80001d86:	e44e                	sd	s3,8(sp)
    80001d88:	e052                	sd	s4,0(sp)
    80001d8a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d8c:	00000097          	auipc	ra,0x0
    80001d90:	c3a080e7          	jalr	-966(ra) # 800019c6 <myproc>
    80001d94:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001d96:	00000097          	auipc	ra,0x0
    80001d9a:	e3a080e7          	jalr	-454(ra) # 80001bd0 <allocproc>
    80001d9e:	10050b63          	beqz	a0,80001eb4 <fork+0x138>
    80001da2:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001da4:	04893603          	ld	a2,72(s2)
    80001da8:	692c                	ld	a1,80(a0)
    80001daa:	05093503          	ld	a0,80(s2)
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	7d2080e7          	jalr	2002(ra) # 80001580 <uvmcopy>
    80001db6:	04054663          	bltz	a0,80001e02 <fork+0x86>
  np->sz = p->sz;
    80001dba:	04893783          	ld	a5,72(s2)
    80001dbe:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dc2:	05893683          	ld	a3,88(s2)
    80001dc6:	87b6                	mv	a5,a3
    80001dc8:	0589b703          	ld	a4,88(s3)
    80001dcc:	12068693          	addi	a3,a3,288
    80001dd0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dd4:	6788                	ld	a0,8(a5)
    80001dd6:	6b8c                	ld	a1,16(a5)
    80001dd8:	6f90                	ld	a2,24(a5)
    80001dda:	01073023          	sd	a6,0(a4)
    80001dde:	e708                	sd	a0,8(a4)
    80001de0:	eb0c                	sd	a1,16(a4)
    80001de2:	ef10                	sd	a2,24(a4)
    80001de4:	02078793          	addi	a5,a5,32
    80001de8:	02070713          	addi	a4,a4,32
    80001dec:	fed792e3          	bne	a5,a3,80001dd0 <fork+0x54>
  np->trapframe->a0 = 0;
    80001df0:	0589b783          	ld	a5,88(s3)
    80001df4:	0607b823          	sd	zero,112(a5)
    80001df8:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001dfc:	15000a13          	li	s4,336
    80001e00:	a03d                	j	80001e2e <fork+0xb2>
    freeproc(np);
    80001e02:	854e                	mv	a0,s3
    80001e04:	00000097          	auipc	ra,0x0
    80001e08:	d74080e7          	jalr	-652(ra) # 80001b78 <freeproc>
    release(&np->lock);
    80001e0c:	854e                	mv	a0,s3
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	e90080e7          	jalr	-368(ra) # 80000c9e <release>
    return -1;
    80001e16:	5a7d                	li	s4,-1
    80001e18:	a069                	j	80001ea2 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e1a:	00003097          	auipc	ra,0x3
    80001e1e:	c36080e7          	jalr	-970(ra) # 80004a50 <filedup>
    80001e22:	009987b3          	add	a5,s3,s1
    80001e26:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e28:	04a1                	addi	s1,s1,8
    80001e2a:	01448763          	beq	s1,s4,80001e38 <fork+0xbc>
    if(p->ofile[i])
    80001e2e:	009907b3          	add	a5,s2,s1
    80001e32:	6388                	ld	a0,0(a5)
    80001e34:	f17d                	bnez	a0,80001e1a <fork+0x9e>
    80001e36:	bfcd                	j	80001e28 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e38:	15093503          	ld	a0,336(s2)
    80001e3c:	00002097          	auipc	ra,0x2
    80001e40:	d9a080e7          	jalr	-614(ra) # 80003bd6 <idup>
    80001e44:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e48:	4641                	li	a2,16
    80001e4a:	15890593          	addi	a1,s2,344
    80001e4e:	15898513          	addi	a0,s3,344
    80001e52:	fffff097          	auipc	ra,0xfffff
    80001e56:	fe6080e7          	jalr	-26(ra) # 80000e38 <safestrcpy>
  pid = np->pid;
    80001e5a:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001e5e:	854e                	mv	a0,s3
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	e3e080e7          	jalr	-450(ra) # 80000c9e <release>
  acquire(&wait_lock);
    80001e68:	0000f497          	auipc	s1,0xf
    80001e6c:	ef048493          	addi	s1,s1,-272 # 80010d58 <wait_lock>
    80001e70:	8526                	mv	a0,s1
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	d78080e7          	jalr	-648(ra) # 80000bea <acquire>
  np->parent = p;
    80001e7a:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001e7e:	8526                	mv	a0,s1
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	e1e080e7          	jalr	-482(ra) # 80000c9e <release>
  acquire(&np->lock);
    80001e88:	854e                	mv	a0,s3
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	d60080e7          	jalr	-672(ra) # 80000bea <acquire>
  np->state = RUNNABLE;
    80001e92:	478d                	li	a5,3
    80001e94:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e98:	854e                	mv	a0,s3
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	e04080e7          	jalr	-508(ra) # 80000c9e <release>
}
    80001ea2:	8552                	mv	a0,s4
    80001ea4:	70a2                	ld	ra,40(sp)
    80001ea6:	7402                	ld	s0,32(sp)
    80001ea8:	64e2                	ld	s1,24(sp)
    80001eaa:	6942                	ld	s2,16(sp)
    80001eac:	69a2                	ld	s3,8(sp)
    80001eae:	6a02                	ld	s4,0(sp)
    80001eb0:	6145                	addi	sp,sp,48
    80001eb2:	8082                	ret
    return -1;
    80001eb4:	5a7d                	li	s4,-1
    80001eb6:	b7f5                	j	80001ea2 <fork+0x126>

0000000080001eb8 <scheduler>:
{
    80001eb8:	7139                	addi	sp,sp,-64
    80001eba:	fc06                	sd	ra,56(sp)
    80001ebc:	f822                	sd	s0,48(sp)
    80001ebe:	f426                	sd	s1,40(sp)
    80001ec0:	f04a                	sd	s2,32(sp)
    80001ec2:	ec4e                	sd	s3,24(sp)
    80001ec4:	e852                	sd	s4,16(sp)
    80001ec6:	e456                	sd	s5,8(sp)
    80001ec8:	e05a                	sd	s6,0(sp)
    80001eca:	0080                	addi	s0,sp,64
    80001ecc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ece:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ed0:	00779a93          	slli	s5,a5,0x7
    80001ed4:	0000f717          	auipc	a4,0xf
    80001ed8:	e6c70713          	addi	a4,a4,-404 # 80010d40 <pid_lock>
    80001edc:	9756                	add	a4,a4,s5
    80001ede:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ee2:	0000f717          	auipc	a4,0xf
    80001ee6:	e9670713          	addi	a4,a4,-362 # 80010d78 <cpus+0x8>
    80001eea:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001eec:	498d                	li	s3,3
        p->state = RUNNING;
    80001eee:	4b11                	li	s6,4
        c->proc = p;
    80001ef0:	079e                	slli	a5,a5,0x7
    80001ef2:	0000fa17          	auipc	s4,0xf
    80001ef6:	e4ea0a13          	addi	s4,s4,-434 # 80010d40 <pid_lock>
    80001efa:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001efc:	00015917          	auipc	s2,0x15
    80001f00:	47490913          	addi	s2,s2,1140 # 80017370 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f04:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f08:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f0c:	10079073          	csrw	sstatus,a5
    80001f10:	0000f497          	auipc	s1,0xf
    80001f14:	26048493          	addi	s1,s1,608 # 80011170 <proc>
    80001f18:	a03d                	j	80001f46 <scheduler+0x8e>
        p->state = RUNNING;
    80001f1a:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f1e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f22:	06048593          	addi	a1,s1,96
    80001f26:	8556                	mv	a0,s5
    80001f28:	00001097          	auipc	ra,0x1
    80001f2c:	b30080e7          	jalr	-1232(ra) # 80002a58 <swtch>
        c->proc = 0;
    80001f30:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80001f34:	8526                	mv	a0,s1
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	d68080e7          	jalr	-664(ra) # 80000c9e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f3e:	18848493          	addi	s1,s1,392
    80001f42:	fd2481e3          	beq	s1,s2,80001f04 <scheduler+0x4c>
      acquire(&p->lock);
    80001f46:	8526                	mv	a0,s1
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	ca2080e7          	jalr	-862(ra) # 80000bea <acquire>
      if(p->state == RUNNABLE) {
    80001f50:	4c9c                	lw	a5,24(s1)
    80001f52:	ff3791e3          	bne	a5,s3,80001f34 <scheduler+0x7c>
    80001f56:	b7d1                	j	80001f1a <scheduler+0x62>

0000000080001f58 <sched>:
{
    80001f58:	7179                	addi	sp,sp,-48
    80001f5a:	f406                	sd	ra,40(sp)
    80001f5c:	f022                	sd	s0,32(sp)
    80001f5e:	ec26                	sd	s1,24(sp)
    80001f60:	e84a                	sd	s2,16(sp)
    80001f62:	e44e                	sd	s3,8(sp)
    80001f64:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f66:	00000097          	auipc	ra,0x0
    80001f6a:	a60080e7          	jalr	-1440(ra) # 800019c6 <myproc>
    80001f6e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	c00080e7          	jalr	-1024(ra) # 80000b70 <holding>
    80001f78:	c93d                	beqz	a0,80001fee <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f7a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f7c:	2781                	sext.w	a5,a5
    80001f7e:	079e                	slli	a5,a5,0x7
    80001f80:	0000f717          	auipc	a4,0xf
    80001f84:	dc070713          	addi	a4,a4,-576 # 80010d40 <pid_lock>
    80001f88:	97ba                	add	a5,a5,a4
    80001f8a:	0a87a703          	lw	a4,168(a5)
    80001f8e:	4785                	li	a5,1
    80001f90:	06f71763          	bne	a4,a5,80001ffe <sched+0xa6>
  if(p->state == RUNNING)
    80001f94:	4c98                	lw	a4,24(s1)
    80001f96:	4791                	li	a5,4
    80001f98:	06f70b63          	beq	a4,a5,8000200e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fa0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fa2:	efb5                	bnez	a5,8000201e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fa4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fa6:	0000f917          	auipc	s2,0xf
    80001faa:	d9a90913          	addi	s2,s2,-614 # 80010d40 <pid_lock>
    80001fae:	2781                	sext.w	a5,a5
    80001fb0:	079e                	slli	a5,a5,0x7
    80001fb2:	97ca                	add	a5,a5,s2
    80001fb4:	0ac7a983          	lw	s3,172(a5)
    80001fb8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fba:	2781                	sext.w	a5,a5
    80001fbc:	079e                	slli	a5,a5,0x7
    80001fbe:	0000f597          	auipc	a1,0xf
    80001fc2:	dba58593          	addi	a1,a1,-582 # 80010d78 <cpus+0x8>
    80001fc6:	95be                	add	a1,a1,a5
    80001fc8:	06048513          	addi	a0,s1,96
    80001fcc:	00001097          	auipc	ra,0x1
    80001fd0:	a8c080e7          	jalr	-1396(ra) # 80002a58 <swtch>
    80001fd4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fd6:	2781                	sext.w	a5,a5
    80001fd8:	079e                	slli	a5,a5,0x7
    80001fda:	97ca                	add	a5,a5,s2
    80001fdc:	0b37a623          	sw	s3,172(a5)
}
    80001fe0:	70a2                	ld	ra,40(sp)
    80001fe2:	7402                	ld	s0,32(sp)
    80001fe4:	64e2                	ld	s1,24(sp)
    80001fe6:	6942                	ld	s2,16(sp)
    80001fe8:	69a2                	ld	s3,8(sp)
    80001fea:	6145                	addi	sp,sp,48
    80001fec:	8082                	ret
    panic("sched p->lock");
    80001fee:	00006517          	auipc	a0,0x6
    80001ff2:	22a50513          	addi	a0,a0,554 # 80008218 <digits+0x1d8>
    80001ff6:	ffffe097          	auipc	ra,0xffffe
    80001ffa:	54e080e7          	jalr	1358(ra) # 80000544 <panic>
    panic("sched locks");
    80001ffe:	00006517          	auipc	a0,0x6
    80002002:	22a50513          	addi	a0,a0,554 # 80008228 <digits+0x1e8>
    80002006:	ffffe097          	auipc	ra,0xffffe
    8000200a:	53e080e7          	jalr	1342(ra) # 80000544 <panic>
    panic("sched running");
    8000200e:	00006517          	auipc	a0,0x6
    80002012:	22a50513          	addi	a0,a0,554 # 80008238 <digits+0x1f8>
    80002016:	ffffe097          	auipc	ra,0xffffe
    8000201a:	52e080e7          	jalr	1326(ra) # 80000544 <panic>
    panic("sched interruptible");
    8000201e:	00006517          	auipc	a0,0x6
    80002022:	22a50513          	addi	a0,a0,554 # 80008248 <digits+0x208>
    80002026:	ffffe097          	auipc	ra,0xffffe
    8000202a:	51e080e7          	jalr	1310(ra) # 80000544 <panic>

000000008000202e <yield>:
{
    8000202e:	1101                	addi	sp,sp,-32
    80002030:	ec06                	sd	ra,24(sp)
    80002032:	e822                	sd	s0,16(sp)
    80002034:	e426                	sd	s1,8(sp)
    80002036:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002038:	00000097          	auipc	ra,0x0
    8000203c:	98e080e7          	jalr	-1650(ra) # 800019c6 <myproc>
    80002040:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	ba8080e7          	jalr	-1112(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    8000204a:	478d                	li	a5,3
    8000204c:	cc9c                	sw	a5,24(s1)
  sched();
    8000204e:	00000097          	auipc	ra,0x0
    80002052:	f0a080e7          	jalr	-246(ra) # 80001f58 <sched>
  release(&p->lock);
    80002056:	8526                	mv	a0,s1
    80002058:	fffff097          	auipc	ra,0xfffff
    8000205c:	c46080e7          	jalr	-954(ra) # 80000c9e <release>
}
    80002060:	60e2                	ld	ra,24(sp)
    80002062:	6442                	ld	s0,16(sp)
    80002064:	64a2                	ld	s1,8(sp)
    80002066:	6105                	addi	sp,sp,32
    80002068:	8082                	ret

000000008000206a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000206a:	7179                	addi	sp,sp,-48
    8000206c:	f406                	sd	ra,40(sp)
    8000206e:	f022                	sd	s0,32(sp)
    80002070:	ec26                	sd	s1,24(sp)
    80002072:	e84a                	sd	s2,16(sp)
    80002074:	e44e                	sd	s3,8(sp)
    80002076:	1800                	addi	s0,sp,48
    80002078:	89aa                	mv	s3,a0
    8000207a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000207c:	00000097          	auipc	ra,0x0
    80002080:	94a080e7          	jalr	-1718(ra) # 800019c6 <myproc>
    80002084:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002086:	fffff097          	auipc	ra,0xfffff
    8000208a:	b64080e7          	jalr	-1180(ra) # 80000bea <acquire>
  release(lk);
    8000208e:	854a                	mv	a0,s2
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	c0e080e7          	jalr	-1010(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    80002098:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000209c:	4789                	li	a5,2
    8000209e:	cc9c                	sw	a5,24(s1)

  sched();
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	eb8080e7          	jalr	-328(ra) # 80001f58 <sched>

  // Tidy up.
  p->chan = 0;
    800020a8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020ac:	8526                	mv	a0,s1
    800020ae:	fffff097          	auipc	ra,0xfffff
    800020b2:	bf0080e7          	jalr	-1040(ra) # 80000c9e <release>
  acquire(lk);
    800020b6:	854a                	mv	a0,s2
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	b32080e7          	jalr	-1230(ra) # 80000bea <acquire>
}
    800020c0:	70a2                	ld	ra,40(sp)
    800020c2:	7402                	ld	s0,32(sp)
    800020c4:	64e2                	ld	s1,24(sp)
    800020c6:	6942                	ld	s2,16(sp)
    800020c8:	69a2                	ld	s3,8(sp)
    800020ca:	6145                	addi	sp,sp,48
    800020cc:	8082                	ret

00000000800020ce <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800020ce:	7139                	addi	sp,sp,-64
    800020d0:	fc06                	sd	ra,56(sp)
    800020d2:	f822                	sd	s0,48(sp)
    800020d4:	f426                	sd	s1,40(sp)
    800020d6:	f04a                	sd	s2,32(sp)
    800020d8:	ec4e                	sd	s3,24(sp)
    800020da:	e852                	sd	s4,16(sp)
    800020dc:	e456                	sd	s5,8(sp)
    800020de:	0080                	addi	s0,sp,64
    800020e0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020e2:	0000f497          	auipc	s1,0xf
    800020e6:	08e48493          	addi	s1,s1,142 # 80011170 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020ea:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020ec:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020ee:	00015917          	auipc	s2,0x15
    800020f2:	28290913          	addi	s2,s2,642 # 80017370 <tickslock>
    800020f6:	a821                	j	8000210e <wakeup+0x40>
        p->state = RUNNABLE;
    800020f8:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	fffff097          	auipc	ra,0xfffff
    80002102:	ba0080e7          	jalr	-1120(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002106:	18848493          	addi	s1,s1,392
    8000210a:	03248463          	beq	s1,s2,80002132 <wakeup+0x64>
    if(p != myproc()){
    8000210e:	00000097          	auipc	ra,0x0
    80002112:	8b8080e7          	jalr	-1864(ra) # 800019c6 <myproc>
    80002116:	fea488e3          	beq	s1,a0,80002106 <wakeup+0x38>
      acquire(&p->lock);
    8000211a:	8526                	mv	a0,s1
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	ace080e7          	jalr	-1330(ra) # 80000bea <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002124:	4c9c                	lw	a5,24(s1)
    80002126:	fd379be3          	bne	a5,s3,800020fc <wakeup+0x2e>
    8000212a:	709c                	ld	a5,32(s1)
    8000212c:	fd4798e3          	bne	a5,s4,800020fc <wakeup+0x2e>
    80002130:	b7e1                	j	800020f8 <wakeup+0x2a>
    }
  }
}
    80002132:	70e2                	ld	ra,56(sp)
    80002134:	7442                	ld	s0,48(sp)
    80002136:	74a2                	ld	s1,40(sp)
    80002138:	7902                	ld	s2,32(sp)
    8000213a:	69e2                	ld	s3,24(sp)
    8000213c:	6a42                	ld	s4,16(sp)
    8000213e:	6aa2                	ld	s5,8(sp)
    80002140:	6121                	addi	sp,sp,64
    80002142:	8082                	ret

0000000080002144 <reparent>:
{
    80002144:	7179                	addi	sp,sp,-48
    80002146:	f406                	sd	ra,40(sp)
    80002148:	f022                	sd	s0,32(sp)
    8000214a:	ec26                	sd	s1,24(sp)
    8000214c:	e84a                	sd	s2,16(sp)
    8000214e:	e44e                	sd	s3,8(sp)
    80002150:	e052                	sd	s4,0(sp)
    80002152:	1800                	addi	s0,sp,48
    80002154:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002156:	0000f497          	auipc	s1,0xf
    8000215a:	01a48493          	addi	s1,s1,26 # 80011170 <proc>
      pp->parent = initproc;
    8000215e:	00007a17          	auipc	s4,0x7
    80002162:	96aa0a13          	addi	s4,s4,-1686 # 80008ac8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002166:	00015997          	auipc	s3,0x15
    8000216a:	20a98993          	addi	s3,s3,522 # 80017370 <tickslock>
    8000216e:	a029                	j	80002178 <reparent+0x34>
    80002170:	18848493          	addi	s1,s1,392
    80002174:	01348d63          	beq	s1,s3,8000218e <reparent+0x4a>
    if(pp->parent == p){
    80002178:	7c9c                	ld	a5,56(s1)
    8000217a:	ff279be3          	bne	a5,s2,80002170 <reparent+0x2c>
      pp->parent = initproc;
    8000217e:	000a3503          	ld	a0,0(s4)
    80002182:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002184:	00000097          	auipc	ra,0x0
    80002188:	f4a080e7          	jalr	-182(ra) # 800020ce <wakeup>
    8000218c:	b7d5                	j	80002170 <reparent+0x2c>
}
    8000218e:	70a2                	ld	ra,40(sp)
    80002190:	7402                	ld	s0,32(sp)
    80002192:	64e2                	ld	s1,24(sp)
    80002194:	6942                	ld	s2,16(sp)
    80002196:	69a2                	ld	s3,8(sp)
    80002198:	6a02                	ld	s4,0(sp)
    8000219a:	6145                	addi	sp,sp,48
    8000219c:	8082                	ret

000000008000219e <exit>:
{
    8000219e:	7179                	addi	sp,sp,-48
    800021a0:	f406                	sd	ra,40(sp)
    800021a2:	f022                	sd	s0,32(sp)
    800021a4:	ec26                	sd	s1,24(sp)
    800021a6:	e84a                	sd	s2,16(sp)
    800021a8:	e44e                	sd	s3,8(sp)
    800021aa:	1800                	addi	s0,sp,48
    800021ac:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800021ae:	00000097          	auipc	ra,0x0
    800021b2:	818080e7          	jalr	-2024(ra) # 800019c6 <myproc>
  if(p == initproc)
    800021b6:	00007797          	auipc	a5,0x7
    800021ba:	9127b783          	ld	a5,-1774(a5) # 80008ac8 <initproc>
    800021be:	02a78363          	beq	a5,a0,800021e4 <exit+0x46>
    800021c2:	89aa                	mv	s3,a0
  strncpy(p->exit_msg, msg, sizeof(p->exit_msg));
    800021c4:	02000613          	li	a2,32
    800021c8:	85a6                	mv	a1,s1
    800021ca:	16850513          	addi	a0,a0,360
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	c2c080e7          	jalr	-980(ra) # 80000dfa <strncpy>
  p->exit_msg[sizeof(p->exit_msg) - 1] = 0;
    800021d6:	180983a3          	sb	zero,391(s3)
  for(int fd = 0; fd < NOFILE; fd++){
    800021da:	0d098493          	addi	s1,s3,208
    800021de:	15098913          	addi	s2,s3,336
    800021e2:	a015                	j	80002206 <exit+0x68>
    panic("init exiting");
    800021e4:	00006517          	auipc	a0,0x6
    800021e8:	07c50513          	addi	a0,a0,124 # 80008260 <digits+0x220>
    800021ec:	ffffe097          	auipc	ra,0xffffe
    800021f0:	358080e7          	jalr	856(ra) # 80000544 <panic>
      fileclose(f);
    800021f4:	00003097          	auipc	ra,0x3
    800021f8:	8ae080e7          	jalr	-1874(ra) # 80004aa2 <fileclose>
      p->ofile[fd] = 0;
    800021fc:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002200:	04a1                	addi	s1,s1,8
    80002202:	01248563          	beq	s1,s2,8000220c <exit+0x6e>
    if(p->ofile[fd]){
    80002206:	6088                	ld	a0,0(s1)
    80002208:	f575                	bnez	a0,800021f4 <exit+0x56>
    8000220a:	bfdd                	j	80002200 <exit+0x62>
  begin_op();
    8000220c:	00002097          	auipc	ra,0x2
    80002210:	3ca080e7          	jalr	970(ra) # 800045d6 <begin_op>
  iput(p->cwd);
    80002214:	1509b503          	ld	a0,336(s3)
    80002218:	00002097          	auipc	ra,0x2
    8000221c:	bb6080e7          	jalr	-1098(ra) # 80003dce <iput>
  end_op();
    80002220:	00002097          	auipc	ra,0x2
    80002224:	436080e7          	jalr	1078(ra) # 80004656 <end_op>
  p->cwd = 0;
    80002228:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000222c:	0000f497          	auipc	s1,0xf
    80002230:	b2c48493          	addi	s1,s1,-1236 # 80010d58 <wait_lock>
    80002234:	8526                	mv	a0,s1
    80002236:	fffff097          	auipc	ra,0xfffff
    8000223a:	9b4080e7          	jalr	-1612(ra) # 80000bea <acquire>
  reparent(p);
    8000223e:	854e                	mv	a0,s3
    80002240:	00000097          	auipc	ra,0x0
    80002244:	f04080e7          	jalr	-252(ra) # 80002144 <reparent>
  wakeup(p->parent);
    80002248:	0389b503          	ld	a0,56(s3)
    8000224c:	00000097          	auipc	ra,0x0
    80002250:	e82080e7          	jalr	-382(ra) # 800020ce <wakeup>
  acquire(&p->lock);
    80002254:	854e                	mv	a0,s3
    80002256:	fffff097          	auipc	ra,0xfffff
    8000225a:	994080e7          	jalr	-1644(ra) # 80000bea <acquire>
  p->xstate = 0;
    8000225e:	0209a623          	sw	zero,44(s3)
  p->state = ZOMBIE;
    80002262:	4795                	li	a5,5
    80002264:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002268:	8526                	mv	a0,s1
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	a34080e7          	jalr	-1484(ra) # 80000c9e <release>
  sched();
    80002272:	00000097          	auipc	ra,0x0
    80002276:	ce6080e7          	jalr	-794(ra) # 80001f58 <sched>
  panic("zombie exit");
    8000227a:	00006517          	auipc	a0,0x6
    8000227e:	ff650513          	addi	a0,a0,-10 # 80008270 <digits+0x230>
    80002282:	ffffe097          	auipc	ra,0xffffe
    80002286:	2c2080e7          	jalr	706(ra) # 80000544 <panic>

000000008000228a <exit_num>:
void exit_num(int status){
    8000228a:	1101                	addi	sp,sp,-32
    8000228c:	ec06                	sd	ra,24(sp)
    8000228e:	e822                	sd	s0,16(sp)
    80002290:	e426                	sd	s1,8(sp)
    80002292:	1000                	addi	s0,sp,32
    80002294:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	730080e7          	jalr	1840(ra) # 800019c6 <myproc>
  p->xstatus = status;
    8000229e:	d944                	sw	s1,52(a0)
  exit("exit_num");
    800022a0:	00006517          	auipc	a0,0x6
    800022a4:	fe050513          	addi	a0,a0,-32 # 80008280 <digits+0x240>
    800022a8:	00000097          	auipc	ra,0x0
    800022ac:	ef6080e7          	jalr	-266(ra) # 8000219e <exit>

00000000800022b0 <exit_msg>:
{
    800022b0:	1101                	addi	sp,sp,-32
    800022b2:	ec06                	sd	ra,24(sp)
    800022b4:	e822                	sd	s0,16(sp)
    800022b6:	e426                	sd	s1,8(sp)
    800022b8:	e04a                	sd	s2,0(sp)
    800022ba:	1000                	addi	s0,sp,32
    800022bc:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	708080e7          	jalr	1800(ra) # 800019c6 <myproc>
    800022c6:	84aa                	mv	s1,a0
  strncpy(p->exit_msg, msg, sizeof(p->exit_msg));
    800022c8:	02000613          	li	a2,32
    800022cc:	85ca                	mv	a1,s2
    800022ce:	16850513          	addi	a0,a0,360
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	b28080e7          	jalr	-1240(ra) # 80000dfa <strncpy>
  p->exit_msg[sizeof(p->exit_msg)-1] = '\0';
    800022da:	180483a3          	sb	zero,391(s1)
  exit("Goodbye World xv6");
    800022de:	00006517          	auipc	a0,0x6
    800022e2:	fb250513          	addi	a0,a0,-78 # 80008290 <digits+0x250>
    800022e6:	00000097          	auipc	ra,0x0
    800022ea:	eb8080e7          	jalr	-328(ra) # 8000219e <exit>

00000000800022ee <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800022ee:	7179                	addi	sp,sp,-48
    800022f0:	f406                	sd	ra,40(sp)
    800022f2:	f022                	sd	s0,32(sp)
    800022f4:	ec26                	sd	s1,24(sp)
    800022f6:	e84a                	sd	s2,16(sp)
    800022f8:	e44e                	sd	s3,8(sp)
    800022fa:	1800                	addi	s0,sp,48
    800022fc:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022fe:	0000f497          	auipc	s1,0xf
    80002302:	e7248493          	addi	s1,s1,-398 # 80011170 <proc>
    80002306:	00015997          	auipc	s3,0x15
    8000230a:	06a98993          	addi	s3,s3,106 # 80017370 <tickslock>
    acquire(&p->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	8da080e7          	jalr	-1830(ra) # 80000bea <acquire>
    if(p->pid == pid){
    80002318:	589c                	lw	a5,48(s1)
    8000231a:	01278d63          	beq	a5,s2,80002334 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	97e080e7          	jalr	-1666(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002328:	18848493          	addi	s1,s1,392
    8000232c:	ff3491e3          	bne	s1,s3,8000230e <kill+0x20>
  }
  return -1;
    80002330:	557d                	li	a0,-1
    80002332:	a829                	j	8000234c <kill+0x5e>
      p->killed = 1;
    80002334:	4785                	li	a5,1
    80002336:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002338:	4c98                	lw	a4,24(s1)
    8000233a:	4789                	li	a5,2
    8000233c:	00f70f63          	beq	a4,a5,8000235a <kill+0x6c>
      release(&p->lock);
    80002340:	8526                	mv	a0,s1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	95c080e7          	jalr	-1700(ra) # 80000c9e <release>
      return 0;
    8000234a:	4501                	li	a0,0
}
    8000234c:	70a2                	ld	ra,40(sp)
    8000234e:	7402                	ld	s0,32(sp)
    80002350:	64e2                	ld	s1,24(sp)
    80002352:	6942                	ld	s2,16(sp)
    80002354:	69a2                	ld	s3,8(sp)
    80002356:	6145                	addi	sp,sp,48
    80002358:	8082                	ret
        p->state = RUNNABLE;
    8000235a:	478d                	li	a5,3
    8000235c:	cc9c                	sw	a5,24(s1)
    8000235e:	b7cd                	j	80002340 <kill+0x52>

0000000080002360 <setkilled>:

void setkilled(struct proc *p)
{
    80002360:	1101                	addi	sp,sp,-32
    80002362:	ec06                	sd	ra,24(sp)
    80002364:	e822                	sd	s0,16(sp)
    80002366:	e426                	sd	s1,8(sp)
    80002368:	1000                	addi	s0,sp,32
    8000236a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	87e080e7          	jalr	-1922(ra) # 80000bea <acquire>
  p->killed = 1;
    80002374:	4785                	li	a5,1
    80002376:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002378:	8526                	mv	a0,s1
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	924080e7          	jalr	-1756(ra) # 80000c9e <release>
}
    80002382:	60e2                	ld	ra,24(sp)
    80002384:	6442                	ld	s0,16(sp)
    80002386:	64a2                	ld	s1,8(sp)
    80002388:	6105                	addi	sp,sp,32
    8000238a:	8082                	ret

000000008000238c <killed>:

int killed(struct proc *p)
{
    8000238c:	1101                	addi	sp,sp,-32
    8000238e:	ec06                	sd	ra,24(sp)
    80002390:	e822                	sd	s0,16(sp)
    80002392:	e426                	sd	s1,8(sp)
    80002394:	e04a                	sd	s2,0(sp)
    80002396:	1000                	addi	s0,sp,32
    80002398:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	850080e7          	jalr	-1968(ra) # 80000bea <acquire>
  k = p->killed;
    800023a2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023a6:	8526                	mv	a0,s1
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	8f6080e7          	jalr	-1802(ra) # 80000c9e <release>
  return k;
}
    800023b0:	854a                	mv	a0,s2
    800023b2:	60e2                	ld	ra,24(sp)
    800023b4:	6442                	ld	s0,16(sp)
    800023b6:	64a2                	ld	s1,8(sp)
    800023b8:	6902                	ld	s2,0(sp)
    800023ba:	6105                	addi	sp,sp,32
    800023bc:	8082                	ret

00000000800023be <wait>:
{
    800023be:	711d                	addi	sp,sp,-96
    800023c0:	ec86                	sd	ra,88(sp)
    800023c2:	e8a2                	sd	s0,80(sp)
    800023c4:	e4a6                	sd	s1,72(sp)
    800023c6:	e0ca                	sd	s2,64(sp)
    800023c8:	fc4e                	sd	s3,56(sp)
    800023ca:	f852                	sd	s4,48(sp)
    800023cc:	f456                	sd	s5,40(sp)
    800023ce:	f05a                	sd	s6,32(sp)
    800023d0:	ec5e                	sd	s7,24(sp)
    800023d2:	e862                	sd	s8,16(sp)
    800023d4:	e466                	sd	s9,8(sp)
    800023d6:	1080                	addi	s0,sp,96
    800023d8:	8baa                	mv	s7,a0
    800023da:	8b2e                	mv	s6,a1
  struct proc *p = myproc();
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	5ea080e7          	jalr	1514(ra) # 800019c6 <myproc>
    800023e4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023e6:	0000f517          	auipc	a0,0xf
    800023ea:	97250513          	addi	a0,a0,-1678 # 80010d58 <wait_lock>
    800023ee:	ffffe097          	auipc	ra,0xffffe
    800023f2:	7fc080e7          	jalr	2044(ra) # 80000bea <acquire>
    havekids = 0;
    800023f6:	4c01                	li	s8,0
        if(pp->state == ZOMBIE){
    800023f8:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023fa:	00015997          	auipc	s3,0x15
    800023fe:	f7698993          	addi	s3,s3,-138 # 80017370 <tickslock>
        havekids = 1;
    80002402:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002404:	0000fc97          	auipc	s9,0xf
    80002408:	954c8c93          	addi	s9,s9,-1708 # 80010d58 <wait_lock>
    havekids = 0;
    8000240c:	8762                	mv	a4,s8
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000240e:	0000f497          	auipc	s1,0xf
    80002412:	d6248493          	addi	s1,s1,-670 # 80011170 <proc>
    80002416:	a0f9                	j	800024e4 <wait+0x126>
          pid = pp->pid;
    80002418:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000241c:	000b8e63          	beqz	s7,80002438 <wait+0x7a>
    80002420:	4691                	li	a3,4
    80002422:	02c48613          	addi	a2,s1,44
    80002426:	85de                	mv	a1,s7
    80002428:	05093503          	ld	a0,80(s2)
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	258080e7          	jalr	600(ra) # 80001684 <copyout>
    80002434:	04054b63          	bltz	a0,8000248a <wait+0xcc>
          if(copyout(p->pagetable, msg_addr, pp->exit_msg,
    80002438:	05093a83          	ld	s5,80(s2)
    8000243c:	16848a13          	addi	s4,s1,360
                     strlen(pp->exit_msg) + 1) < 0) {
    80002440:	8552                	mv	a0,s4
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	a28080e7          	jalr	-1496(ra) # 80000e6a <strlen>
          if(copyout(p->pagetable, msg_addr, pp->exit_msg,
    8000244a:	0015069b          	addiw	a3,a0,1
    8000244e:	8652                	mv	a2,s4
    80002450:	85da                	mv	a1,s6
    80002452:	8556                	mv	a0,s5
    80002454:	fffff097          	auipc	ra,0xfffff
    80002458:	230080e7          	jalr	560(ra) # 80001684 <copyout>
    8000245c:	04054663          	bltz	a0,800024a8 <wait+0xea>
          if (msg_addr != 0) {
    80002460:	060b1363          	bnez	s6,800024c6 <wait+0x108>
          freeproc(pp);
    80002464:	8526                	mv	a0,s1
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	712080e7          	jalr	1810(ra) # 80001b78 <freeproc>
          release(&pp->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	fffff097          	auipc	ra,0xfffff
    80002474:	82e080e7          	jalr	-2002(ra) # 80000c9e <release>
          release(&wait_lock);
    80002478:	0000f517          	auipc	a0,0xf
    8000247c:	8e050513          	addi	a0,a0,-1824 # 80010d58 <wait_lock>
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	81e080e7          	jalr	-2018(ra) # 80000c9e <release>
          return pid;
    80002488:	a045                	j	80002528 <wait+0x16a>
            release(&pp->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	812080e7          	jalr	-2030(ra) # 80000c9e <release>
            release(&wait_lock);
    80002494:	0000f517          	auipc	a0,0xf
    80002498:	8c450513          	addi	a0,a0,-1852 # 80010d58 <wait_lock>
    8000249c:	fffff097          	auipc	ra,0xfffff
    800024a0:	802080e7          	jalr	-2046(ra) # 80000c9e <release>
            return -1;
    800024a4:	59fd                	li	s3,-1
    800024a6:	a049                	j	80002528 <wait+0x16a>
            release(&pp->lock);
    800024a8:	8526                	mv	a0,s1
    800024aa:	ffffe097          	auipc	ra,0xffffe
    800024ae:	7f4080e7          	jalr	2036(ra) # 80000c9e <release>
            release(&wait_lock);
    800024b2:	0000f517          	auipc	a0,0xf
    800024b6:	8a650513          	addi	a0,a0,-1882 # 80010d58 <wait_lock>
    800024ba:	ffffe097          	auipc	ra,0xffffe
    800024be:	7e4080e7          	jalr	2020(ra) # 80000c9e <release>
            return -1;
    800024c2:	59fd                	li	s3,-1
    800024c4:	a095                	j	80002528 <wait+0x16a>
            copyout(p->pagetable, msg_addr, pp->exit_msg, sizeof(pp->exit_msg));
    800024c6:	02000693          	li	a3,32
    800024ca:	8652                	mv	a2,s4
    800024cc:	85da                	mv	a1,s6
    800024ce:	05093503          	ld	a0,80(s2)
    800024d2:	fffff097          	auipc	ra,0xfffff
    800024d6:	1b2080e7          	jalr	434(ra) # 80001684 <copyout>
    800024da:	b769                	j	80002464 <wait+0xa6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024dc:	18848493          	addi	s1,s1,392
    800024e0:	03348463          	beq	s1,s3,80002508 <wait+0x14a>
      if(pp->parent == p){
    800024e4:	7c9c                	ld	a5,56(s1)
    800024e6:	ff279be3          	bne	a5,s2,800024dc <wait+0x11e>
        acquire(&pp->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	6fe080e7          	jalr	1790(ra) # 80000bea <acquire>
        if(pp->state == ZOMBIE){
    800024f4:	4c9c                	lw	a5,24(s1)
    800024f6:	f34781e3          	beq	a5,s4,80002418 <wait+0x5a>
        release(&pp->lock);
    800024fa:	8526                	mv	a0,s1
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	7a2080e7          	jalr	1954(ra) # 80000c9e <release>
        havekids = 1;
    80002504:	8756                	mv	a4,s5
    80002506:	bfd9                	j	800024dc <wait+0x11e>
    if(!havekids || killed(p)){
    80002508:	c719                	beqz	a4,80002516 <wait+0x158>
    8000250a:	854a                	mv	a0,s2
    8000250c:	00000097          	auipc	ra,0x0
    80002510:	e80080e7          	jalr	-384(ra) # 8000238c <killed>
    80002514:	c905                	beqz	a0,80002544 <wait+0x186>
      release(&wait_lock);
    80002516:	0000f517          	auipc	a0,0xf
    8000251a:	84250513          	addi	a0,a0,-1982 # 80010d58 <wait_lock>
    8000251e:	ffffe097          	auipc	ra,0xffffe
    80002522:	780080e7          	jalr	1920(ra) # 80000c9e <release>
      return -1;
    80002526:	59fd                	li	s3,-1
}
    80002528:	854e                	mv	a0,s3
    8000252a:	60e6                	ld	ra,88(sp)
    8000252c:	6446                	ld	s0,80(sp)
    8000252e:	64a6                	ld	s1,72(sp)
    80002530:	6906                	ld	s2,64(sp)
    80002532:	79e2                	ld	s3,56(sp)
    80002534:	7a42                	ld	s4,48(sp)
    80002536:	7aa2                	ld	s5,40(sp)
    80002538:	7b02                	ld	s6,32(sp)
    8000253a:	6be2                	ld	s7,24(sp)
    8000253c:	6c42                	ld	s8,16(sp)
    8000253e:	6ca2                	ld	s9,8(sp)
    80002540:	6125                	addi	sp,sp,96
    80002542:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002544:	85e6                	mv	a1,s9
    80002546:	854a                	mv	a0,s2
    80002548:	00000097          	auipc	ra,0x0
    8000254c:	b22080e7          	jalr	-1246(ra) # 8000206a <sleep>
    havekids = 0;
    80002550:	bd75                	j	8000240c <wait+0x4e>

0000000080002552 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002552:	7179                	addi	sp,sp,-48
    80002554:	f406                	sd	ra,40(sp)
    80002556:	f022                	sd	s0,32(sp)
    80002558:	ec26                	sd	s1,24(sp)
    8000255a:	e84a                	sd	s2,16(sp)
    8000255c:	e44e                	sd	s3,8(sp)
    8000255e:	e052                	sd	s4,0(sp)
    80002560:	1800                	addi	s0,sp,48
    80002562:	84aa                	mv	s1,a0
    80002564:	892e                	mv	s2,a1
    80002566:	89b2                	mv	s3,a2
    80002568:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000256a:	fffff097          	auipc	ra,0xfffff
    8000256e:	45c080e7          	jalr	1116(ra) # 800019c6 <myproc>
  if(user_dst){
    80002572:	c08d                	beqz	s1,80002594 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002574:	86d2                	mv	a3,s4
    80002576:	864e                	mv	a2,s3
    80002578:	85ca                	mv	a1,s2
    8000257a:	6928                	ld	a0,80(a0)
    8000257c:	fffff097          	auipc	ra,0xfffff
    80002580:	108080e7          	jalr	264(ra) # 80001684 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002584:	70a2                	ld	ra,40(sp)
    80002586:	7402                	ld	s0,32(sp)
    80002588:	64e2                	ld	s1,24(sp)
    8000258a:	6942                	ld	s2,16(sp)
    8000258c:	69a2                	ld	s3,8(sp)
    8000258e:	6a02                	ld	s4,0(sp)
    80002590:	6145                	addi	sp,sp,48
    80002592:	8082                	ret
    memmove((char *)dst, src, len);
    80002594:	000a061b          	sext.w	a2,s4
    80002598:	85ce                	mv	a1,s3
    8000259a:	854a                	mv	a0,s2
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	7aa080e7          	jalr	1962(ra) # 80000d46 <memmove>
    return 0;
    800025a4:	8526                	mv	a0,s1
    800025a6:	bff9                	j	80002584 <either_copyout+0x32>

00000000800025a8 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025a8:	7179                	addi	sp,sp,-48
    800025aa:	f406                	sd	ra,40(sp)
    800025ac:	f022                	sd	s0,32(sp)
    800025ae:	ec26                	sd	s1,24(sp)
    800025b0:	e84a                	sd	s2,16(sp)
    800025b2:	e44e                	sd	s3,8(sp)
    800025b4:	e052                	sd	s4,0(sp)
    800025b6:	1800                	addi	s0,sp,48
    800025b8:	892a                	mv	s2,a0
    800025ba:	84ae                	mv	s1,a1
    800025bc:	89b2                	mv	s3,a2
    800025be:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025c0:	fffff097          	auipc	ra,0xfffff
    800025c4:	406080e7          	jalr	1030(ra) # 800019c6 <myproc>
  if(user_src){
    800025c8:	c08d                	beqz	s1,800025ea <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025ca:	86d2                	mv	a3,s4
    800025cc:	864e                	mv	a2,s3
    800025ce:	85ca                	mv	a1,s2
    800025d0:	6928                	ld	a0,80(a0)
    800025d2:	fffff097          	auipc	ra,0xfffff
    800025d6:	13e080e7          	jalr	318(ra) # 80001710 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025da:	70a2                	ld	ra,40(sp)
    800025dc:	7402                	ld	s0,32(sp)
    800025de:	64e2                	ld	s1,24(sp)
    800025e0:	6942                	ld	s2,16(sp)
    800025e2:	69a2                	ld	s3,8(sp)
    800025e4:	6a02                	ld	s4,0(sp)
    800025e6:	6145                	addi	sp,sp,48
    800025e8:	8082                	ret
    memmove(dst, (char*)src, len);
    800025ea:	000a061b          	sext.w	a2,s4
    800025ee:	85ce                	mv	a1,s3
    800025f0:	854a                	mv	a0,s2
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	754080e7          	jalr	1876(ra) # 80000d46 <memmove>
    return 0;
    800025fa:	8526                	mv	a0,s1
    800025fc:	bff9                	j	800025da <either_copyin+0x32>

00000000800025fe <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800025fe:	715d                	addi	sp,sp,-80
    80002600:	e486                	sd	ra,72(sp)
    80002602:	e0a2                	sd	s0,64(sp)
    80002604:	fc26                	sd	s1,56(sp)
    80002606:	f84a                	sd	s2,48(sp)
    80002608:	f44e                	sd	s3,40(sp)
    8000260a:	f052                	sd	s4,32(sp)
    8000260c:	ec56                	sd	s5,24(sp)
    8000260e:	e85a                	sd	s6,16(sp)
    80002610:	e45e                	sd	s7,8(sp)
    80002612:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002614:	00006517          	auipc	a0,0x6
    80002618:	ab450513          	addi	a0,a0,-1356 # 800080c8 <digits+0x88>
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	f72080e7          	jalr	-142(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002624:	0000f497          	auipc	s1,0xf
    80002628:	ca448493          	addi	s1,s1,-860 # 800112c8 <proc+0x158>
    8000262c:	00015917          	auipc	s2,0x15
    80002630:	e9c90913          	addi	s2,s2,-356 # 800174c8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002634:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002636:	00006997          	auipc	s3,0x6
    8000263a:	c7298993          	addi	s3,s3,-910 # 800082a8 <digits+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    8000263e:	00006a97          	auipc	s5,0x6
    80002642:	c72a8a93          	addi	s5,s5,-910 # 800082b0 <digits+0x270>
    printf("\n");
    80002646:	00006a17          	auipc	s4,0x6
    8000264a:	a82a0a13          	addi	s4,s4,-1406 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000264e:	00006b97          	auipc	s7,0x6
    80002652:	e6ab8b93          	addi	s7,s7,-406 # 800084b8 <states.1757>
    80002656:	a00d                	j	80002678 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002658:	ed86a583          	lw	a1,-296(a3)
    8000265c:	8556                	mv	a0,s5
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	f30080e7          	jalr	-208(ra) # 8000058e <printf>
    printf("\n");
    80002666:	8552                	mv	a0,s4
    80002668:	ffffe097          	auipc	ra,0xffffe
    8000266c:	f26080e7          	jalr	-218(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002670:	18848493          	addi	s1,s1,392
    80002674:	03248163          	beq	s1,s2,80002696 <procdump+0x98>
    if(p->state == UNUSED)
    80002678:	86a6                	mv	a3,s1
    8000267a:	ec04a783          	lw	a5,-320(s1)
    8000267e:	dbed                	beqz	a5,80002670 <procdump+0x72>
      state = "???";
    80002680:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002682:	fcfb6be3          	bltu	s6,a5,80002658 <procdump+0x5a>
    80002686:	1782                	slli	a5,a5,0x20
    80002688:	9381                	srli	a5,a5,0x20
    8000268a:	078e                	slli	a5,a5,0x3
    8000268c:	97de                	add	a5,a5,s7
    8000268e:	6390                	ld	a2,0(a5)
    80002690:	f661                	bnez	a2,80002658 <procdump+0x5a>
      state = "???";
    80002692:	864e                	mv	a2,s3
    80002694:	b7d1                	j	80002658 <procdump+0x5a>
  }
}
    80002696:	60a6                	ld	ra,72(sp)
    80002698:	6406                	ld	s0,64(sp)
    8000269a:	74e2                	ld	s1,56(sp)
    8000269c:	7942                	ld	s2,48(sp)
    8000269e:	79a2                	ld	s3,40(sp)
    800026a0:	7a02                	ld	s4,32(sp)
    800026a2:	6ae2                	ld	s5,24(sp)
    800026a4:	6b42                	ld	s6,16(sp)
    800026a6:	6ba2                	ld	s7,8(sp)
    800026a8:	6161                	addi	sp,sp,80
    800026aa:	8082                	ret

00000000800026ac <forkn>:

// Question 4 added
 //the correct
int forkn(int n, int *pids) {
    800026ac:	7119                	addi	sp,sp,-128
    800026ae:	fc86                	sd	ra,120(sp)
    800026b0:	f8a2                	sd	s0,112(sp)
    800026b2:	f4a6                	sd	s1,104(sp)
    800026b4:	f0ca                	sd	s2,96(sp)
    800026b6:	ecce                	sd	s3,88(sp)
    800026b8:	e8d2                	sd	s4,80(sp)
    800026ba:	e4d6                	sd	s5,72(sp)
    800026bc:	e0da                	sd	s6,64(sp)
    800026be:	fc5e                	sd	s7,56(sp)
    800026c0:	f862                	sd	s8,48(sp)
    800026c2:	f466                	sd	s9,40(sp)
    800026c4:	f06a                	sd	s10,32(sp)
    800026c6:	ec6e                	sd	s11,24(sp)
    800026c8:	0100                	addi	s0,sp,128
    800026ca:	8baa                	mv	s7,a0
    800026cc:	84ae                	mv	s1,a1
    800026ce:	f8b43023          	sd	a1,-128(s0)
  struct proc *p = myproc();
    800026d2:	fffff097          	auipc	ra,0xfffff
    800026d6:	2f4080e7          	jalr	756(ra) # 800019c6 <myproc>
  struct proc *np;
  int i;

  if (n < 1 || n > 16)
    800026da:	3bfd                	addiw	s7,s7,-1
    800026dc:	000b871b          	sext.w	a4,s7
    800026e0:	47bd                	li	a5,15
    800026e2:	16e7e363          	bltu	a5,a4,80002848 <forkn+0x19c>
    800026e6:	89aa                	mv	s3,a0
    800026e8:	8d26                	mv	s10,s1
    800026ea:	1b82                	slli	s7,s7,0x20
    800026ec:	020bdb93          	srli	s7,s7,0x20
    800026f0:	8b26                	mv	s6,s1
    800026f2:	4a81                	li	s5,0
    }

    *(np->trapframe) = *(p->trapframe);
    np->trapframe->a0 = i ;  // child id

    for (int fd = 0; fd < NOFILE; fd++)
    800026f4:	15000a13          	li	s4,336
      if (p->ofile[fd])
        np->ofile[fd] = filedup(p->ofile[fd]);

    np->cwd = idup(p->cwd);
    safestrcpy(np->name, p->name, sizeof(p->name));
    800026f8:	15850793          	addi	a5,a0,344
    800026fc:	f8f43423          	sd	a5,-120(s0)

    acquire(&wait_lock);
    80002700:	0000ec97          	auipc	s9,0xe
    80002704:	658c8c93          	addi	s9,s9,1624 # 80010d58 <wait_lock>
    np->parent = p;
    release(&wait_lock);

    pids[i] = np->pid;
    np->state = RUNNABLE;
    80002708:	4d8d                	li	s11,3
    8000270a:	a8d9                	j	800027e0 <forkn+0x134>
      for(int j=0; j<i; j++)
    8000270c:	15805e63          	blez	s8,80002868 <forkn+0x1bc>
    80002710:	fffa849b          	addiw	s1,s5,-1
    80002714:	1482                	slli	s1,s1,0x20
    80002716:	9081                	srli	s1,s1,0x20
    80002718:	048a                	slli	s1,s1,0x2
    8000271a:	f8043783          	ld	a5,-128(s0)
    8000271e:	0791                	addi	a5,a5,4
    80002720:	94be                	add	s1,s1,a5
        kill(pids[j]);
    80002722:	000d2503          	lw	a0,0(s10)
    80002726:	00000097          	auipc	ra,0x0
    8000272a:	bc8080e7          	jalr	-1080(ra) # 800022ee <kill>
      for(int j=0; j<i; j++)
    8000272e:	0d11                	addi	s10,s10,4
    80002730:	fe9d19e3          	bne	s10,s1,80002722 <forkn+0x76>
      return -1;
    80002734:	557d                	li	a0,-1
    80002736:	aa11                	j	8000284a <forkn+0x19e>
      freeproc(np);
    80002738:	854a                	mv	a0,s2
    8000273a:	fffff097          	auipc	ra,0xfffff
    8000273e:	43e080e7          	jalr	1086(ra) # 80001b78 <freeproc>
      release(&np->lock);
    80002742:	854a                	mv	a0,s2
    80002744:	ffffe097          	auipc	ra,0xffffe
    80002748:	55a080e7          	jalr	1370(ra) # 80000c9e <release>
      return -1;
    8000274c:	557d                	li	a0,-1
    8000274e:	a8f5                	j	8000284a <forkn+0x19e>
        np->ofile[fd] = filedup(p->ofile[fd]);
    80002750:	00002097          	auipc	ra,0x2
    80002754:	300080e7          	jalr	768(ra) # 80004a50 <filedup>
    80002758:	009907b3          	add	a5,s2,s1
    8000275c:	e388                	sd	a0,0(a5)
    for (int fd = 0; fd < NOFILE; fd++)
    8000275e:	04a1                	addi	s1,s1,8
    80002760:	01448763          	beq	s1,s4,8000276e <forkn+0xc2>
      if (p->ofile[fd])
    80002764:	009987b3          	add	a5,s3,s1
    80002768:	6388                	ld	a0,0(a5)
    8000276a:	f17d                	bnez	a0,80002750 <forkn+0xa4>
    8000276c:	bfcd                	j	8000275e <forkn+0xb2>
    np->cwd = idup(p->cwd);
    8000276e:	1509b503          	ld	a0,336(s3)
    80002772:	00001097          	auipc	ra,0x1
    80002776:	464080e7          	jalr	1124(ra) # 80003bd6 <idup>
    8000277a:	14a93823          	sd	a0,336(s2)
    safestrcpy(np->name, p->name, sizeof(p->name));
    8000277e:	4641                	li	a2,16
    80002780:	f8843583          	ld	a1,-120(s0)
    80002784:	15890513          	addi	a0,s2,344
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	6b0080e7          	jalr	1712(ra) # 80000e38 <safestrcpy>
    acquire(&wait_lock);
    80002790:	8566                	mv	a0,s9
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	458080e7          	jalr	1112(ra) # 80000bea <acquire>
    np->parent = p;
    8000279a:	03393c23          	sd	s3,56(s2)
    release(&wait_lock);
    8000279e:	8566                	mv	a0,s9
    800027a0:	ffffe097          	auipc	ra,0xffffe
    800027a4:	4fe080e7          	jalr	1278(ra) # 80000c9e <release>
    pids[i] = np->pid;
    800027a8:	03092783          	lw	a5,48(s2)
    800027ac:	00fb2023          	sw	a5,0(s6)
    np->state = RUNNABLE;
    800027b0:	01b92c23          	sw	s11,24(s2)

    release(&np->lock);
    800027b4:	854a                	mv	a0,s2
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	4e8080e7          	jalr	1256(ra) # 80000c9e <release>

    printf("Successfully created child process %d with PID %d\n", i, np->pid);
    800027be:	03092603          	lw	a2,48(s2)
    800027c2:	85e2                	mv	a1,s8
    800027c4:	00006517          	auipc	a0,0x6
    800027c8:	afc50513          	addi	a0,a0,-1284 # 800082c0 <digits+0x280>
    800027cc:	ffffe097          	auipc	ra,0xffffe
    800027d0:	dc2080e7          	jalr	-574(ra) # 8000058e <printf>
  for (i = 0; i < n; i++) {
    800027d4:	001a8793          	addi	a5,s5,1
    800027d8:	0b11                	addi	s6,s6,4
    800027da:	077a8563          	beq	s5,s7,80002844 <forkn+0x198>
    800027de:	8abe                	mv	s5,a5
    800027e0:	000a8c1b          	sext.w	s8,s5
    if ((np = allocproc()) == 0) {
    800027e4:	fffff097          	auipc	ra,0xfffff
    800027e8:	3ec080e7          	jalr	1004(ra) # 80001bd0 <allocproc>
    800027ec:	892a                	mv	s2,a0
    800027ee:	dd19                	beqz	a0,8000270c <forkn+0x60>
    np->sz = p->sz;
    800027f0:	0489b603          	ld	a2,72(s3)
    800027f4:	e530                	sd	a2,72(a0)
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    800027f6:	692c                	ld	a1,80(a0)
    800027f8:	0509b503          	ld	a0,80(s3)
    800027fc:	fffff097          	auipc	ra,0xfffff
    80002800:	d84080e7          	jalr	-636(ra) # 80001580 <uvmcopy>
    80002804:	f2054ae3          	bltz	a0,80002738 <forkn+0x8c>
    *(np->trapframe) = *(p->trapframe);
    80002808:	0589b683          	ld	a3,88(s3)
    8000280c:	87b6                	mv	a5,a3
    8000280e:	05893703          	ld	a4,88(s2)
    80002812:	12068693          	addi	a3,a3,288
    80002816:	0007b803          	ld	a6,0(a5)
    8000281a:	6788                	ld	a0,8(a5)
    8000281c:	6b8c                	ld	a1,16(a5)
    8000281e:	6f90                	ld	a2,24(a5)
    80002820:	01073023          	sd	a6,0(a4)
    80002824:	e708                	sd	a0,8(a4)
    80002826:	eb0c                	sd	a1,16(a4)
    80002828:	ef10                	sd	a2,24(a4)
    8000282a:	02078793          	addi	a5,a5,32
    8000282e:	02070713          	addi	a4,a4,32
    80002832:	fed792e3          	bne	a5,a3,80002816 <forkn+0x16a>
    np->trapframe->a0 = i ;  // child id
    80002836:	05893783          	ld	a5,88(s2)
    8000283a:	0757b823          	sd	s5,112(a5)
    8000283e:	0d000493          	li	s1,208
    80002842:	b70d                	j	80002764 <forkn+0xb8>
  }
   
  return -2; // Parent process will receive 0
    80002844:	5579                	li	a0,-2
    80002846:	a011                	j	8000284a <forkn+0x19e>
    return -1;
    80002848:	557d                	li	a0,-1

} 
    8000284a:	70e6                	ld	ra,120(sp)
    8000284c:	7446                	ld	s0,112(sp)
    8000284e:	74a6                	ld	s1,104(sp)
    80002850:	7906                	ld	s2,96(sp)
    80002852:	69e6                	ld	s3,88(sp)
    80002854:	6a46                	ld	s4,80(sp)
    80002856:	6aa6                	ld	s5,72(sp)
    80002858:	6b06                	ld	s6,64(sp)
    8000285a:	7be2                	ld	s7,56(sp)
    8000285c:	7c42                	ld	s8,48(sp)
    8000285e:	7ca2                	ld	s9,40(sp)
    80002860:	7d02                	ld	s10,32(sp)
    80002862:	6de2                	ld	s11,24(sp)
    80002864:	6109                	addi	sp,sp,128
    80002866:	8082                	ret
      return -1;
    80002868:	557d                	li	a0,-1
    8000286a:	b7c5                	j	8000284a <forkn+0x19e>

000000008000286c <waitall>:

int waitall(int *n, int *statuses) {
    8000286c:	7109                	addi	sp,sp,-384
    8000286e:	fe86                	sd	ra,376(sp)
    80002870:	faa2                	sd	s0,368(sp)
    80002872:	f6a6                	sd	s1,360(sp)
    80002874:	f2ca                	sd	s2,352(sp)
    80002876:	eece                	sd	s3,344(sp)
    80002878:	ead2                	sd	s4,336(sp)
    8000287a:	e6d6                	sd	s5,328(sp)
    8000287c:	e2da                	sd	s6,320(sp)
    8000287e:	fe5e                	sd	s7,312(sp)
    80002880:	fa62                	sd	s8,304(sp)
    80002882:	f666                	sd	s9,296(sp)
    80002884:	f26a                	sd	s10,288(sp)
    80002886:	ee6e                	sd	s11,280(sp)
    80002888:	0300                	addi	s0,sp,384
    8000288a:	8aaa                	mv	s5,a0
    8000288c:	8b2e                	mv	s6,a1
  struct proc *p = myproc();
    8000288e:	fffff097          	auipc	ra,0xfffff
    80002892:	138080e7          	jalr	312(ra) # 800019c6 <myproc>
    80002896:	892a                	mv	s2,a0
  int count = 0;
    80002898:	f8042623          	sw	zero,-116(s0)
  int local_statuses[NPROC];
  int expected_n;

  printf("[waitall] Start waitall syscall\n");
    8000289c:	00006517          	auipc	a0,0x6
    800028a0:	a5c50513          	addi	a0,a0,-1444 # 800082f8 <digits+0x2b8>
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	cea080e7          	jalr	-790(ra) # 8000058e <printf>

  // Safely copy *n from user space
  if (copyin(p->pagetable, (char *)&expected_n, (uint64)n, sizeof(int)) < 0) {
    800028ac:	4691                	li	a3,4
    800028ae:	8656                	mv	a2,s5
    800028b0:	e8440593          	addi	a1,s0,-380
    800028b4:	05093503          	ld	a0,80(s2)
    800028b8:	fffff097          	auipc	ra,0xfffff
    800028bc:	e58080e7          	jalr	-424(ra) # 80001710 <copyin>
    800028c0:	02055a63          	bgez	a0,800028f4 <waitall+0x88>
    printf("[waitall] copyin failed for n\n");
    800028c4:	00006517          	auipc	a0,0x6
    800028c8:	a5c50513          	addi	a0,a0,-1444 # 80008320 <digits+0x2e0>
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	cc2080e7          	jalr	-830(ra) # 8000058e <printf>
    return -1;
    800028d4:	557d                	li	a0,-1
    return -1;
  }

  printf("[waitall] Successfully copied statuses and count\n");
  return 0;
}
    800028d6:	70f6                	ld	ra,376(sp)
    800028d8:	7456                	ld	s0,368(sp)
    800028da:	74b6                	ld	s1,360(sp)
    800028dc:	7916                	ld	s2,352(sp)
    800028de:	69f6                	ld	s3,344(sp)
    800028e0:	6a56                	ld	s4,336(sp)
    800028e2:	6ab6                	ld	s5,328(sp)
    800028e4:	6b16                	ld	s6,320(sp)
    800028e6:	7bf2                	ld	s7,312(sp)
    800028e8:	7c52                	ld	s8,304(sp)
    800028ea:	7cb2                	ld	s9,296(sp)
    800028ec:	7d12                	ld	s10,288(sp)
    800028ee:	6df2                	ld	s11,280(sp)
    800028f0:	6119                	addi	sp,sp,384
    800028f2:	8082                	ret
  acquire(&wait_lock);
    800028f4:	0000e517          	auipc	a0,0xe
    800028f8:	46450513          	addi	a0,a0,1124 # 80010d58 <wait_lock>
    800028fc:	ffffe097          	auipc	ra,0xffffe
    80002900:	2ee080e7          	jalr	750(ra) # 80000bea <acquire>
      if (pp->parent == p && pp->state == ZOMBIE) {
    80002904:	4a15                	li	s4,5
        printf("[waitall] Found zombie child PID %d with xstate = %d\n", pp->pid, pp->xstate);
    80002906:	00006c97          	auipc	s9,0x6
    8000290a:	a3ac8c93          	addi	s9,s9,-1478 # 80008340 <digits+0x300>
    for (struct proc *pp = proc; pp < &proc[NPROC]; pp++) {
    8000290e:	00015997          	auipc	s3,0x15
    80002912:	a6298993          	addi	s3,s3,-1438 # 80017370 <tickslock>
        found = 1;
    80002916:	4c05                	li	s8,1
    printf("[waitall] Sleeping... %d statuses collected so far\n", count);
    80002918:	00006d97          	auipc	s11,0x6
    8000291c:	a60d8d93          	addi	s11,s11,-1440 # 80008378 <digits+0x338>
    sleep(p, &wait_lock);
    80002920:	0000ed17          	auipc	s10,0xe
    80002924:	438d0d13          	addi	s10,s10,1080 # 80010d58 <wait_lock>
    for (struct proc *pp = proc; pp < &proc[NPROC]; pp++) {
    80002928:	0000f497          	auipc	s1,0xf
    8000292c:	84848493          	addi	s1,s1,-1976 # 80011170 <proc>
    int found = 0;
    80002930:	4b81                	li	s7,0
    80002932:	a811                	j	80002946 <waitall+0xda>
      release(&pp->lock);
    80002934:	8526                	mv	a0,s1
    80002936:	ffffe097          	auipc	ra,0xffffe
    8000293a:	368080e7          	jalr	872(ra) # 80000c9e <release>
    for (struct proc *pp = proc; pp < &proc[NPROC]; pp++) {
    8000293e:	18848493          	addi	s1,s1,392
    80002942:	05348d63          	beq	s1,s3,8000299c <waitall+0x130>
      acquire(&pp->lock);
    80002946:	8526                	mv	a0,s1
    80002948:	ffffe097          	auipc	ra,0xffffe
    8000294c:	2a2080e7          	jalr	674(ra) # 80000bea <acquire>
      if (pp->parent == p && pp->state == ZOMBIE) {
    80002950:	7c9c                	ld	a5,56(s1)
    80002952:	ff2791e3          	bne	a5,s2,80002934 <waitall+0xc8>
    80002956:	4c9c                	lw	a5,24(s1)
    80002958:	fd479ee3          	bne	a5,s4,80002934 <waitall+0xc8>
        local_statuses[count++] = pp->xstatus;
    8000295c:	f8c42783          	lw	a5,-116(s0)
    80002960:	0017871b          	addiw	a4,a5,1
    80002964:	f8e42623          	sw	a4,-116(s0)
    80002968:	078a                	slli	a5,a5,0x2
    8000296a:	f9040713          	addi	a4,s0,-112
    8000296e:	97ba                	add	a5,a5,a4
    80002970:	58d8                	lw	a4,52(s1)
    80002972:	eee7ac23          	sw	a4,-264(a5)
        printf("[waitall] Found zombie child PID %d with xstate = %d\n", pp->pid, pp->xstate);
    80002976:	54d0                	lw	a2,44(s1)
    80002978:	588c                	lw	a1,48(s1)
    8000297a:	8566                	mv	a0,s9
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	c12080e7          	jalr	-1006(ra) # 8000058e <printf>
        release(&pp->lock);
    80002984:	8526                	mv	a0,s1
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	318080e7          	jalr	792(ra) # 80000c9e <release>
        freeproc(pp);
    8000298e:	8526                	mv	a0,s1
    80002990:	fffff097          	auipc	ra,0xfffff
    80002994:	1e8080e7          	jalr	488(ra) # 80001b78 <freeproc>
        found = 1;
    80002998:	8be2                	mv	s7,s8
        continue;
    8000299a:	b755                	j	8000293e <waitall+0xd2>
    if (count >= expected_n || !found)
    8000299c:	f8c42583          	lw	a1,-116(s0)
    800029a0:	e8442783          	lw	a5,-380(s0)
    800029a4:	00f5d463          	bge	a1,a5,800029ac <waitall+0x140>
    800029a8:	060b9863          	bnez	s7,80002a18 <waitall+0x1ac>
  release(&wait_lock);
    800029ac:	0000e517          	auipc	a0,0xe
    800029b0:	3ac50513          	addi	a0,a0,940 # 80010d58 <wait_lock>
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	2ea080e7          	jalr	746(ra) # 80000c9e <release>
  printf("[waitall] All children handled, total statuses = %d\n", count);
    800029bc:	f8c42583          	lw	a1,-116(s0)
    800029c0:	00006517          	auipc	a0,0x6
    800029c4:	9f050513          	addi	a0,a0,-1552 # 800083b0 <digits+0x370>
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	bc6080e7          	jalr	-1082(ra) # 8000058e <printf>
  if (copyout(p->pagetable, (uint64)n, (char *)&count, sizeof(int)) < 0) {
    800029d0:	4691                	li	a3,4
    800029d2:	f8c40613          	addi	a2,s0,-116
    800029d6:	85d6                	mv	a1,s5
    800029d8:	05093503          	ld	a0,80(s2)
    800029dc:	fffff097          	auipc	ra,0xfffff
    800029e0:	ca8080e7          	jalr	-856(ra) # 80001684 <copyout>
    800029e4:	04054663          	bltz	a0,80002a30 <waitall+0x1c4>
  if (copyout(p->pagetable, (uint64)statuses, (char *)local_statuses, sizeof(int) * count) < 0) {
    800029e8:	f8c42683          	lw	a3,-116(s0)
    800029ec:	068a                	slli	a3,a3,0x2
    800029ee:	e8840613          	addi	a2,s0,-376
    800029f2:	85da                	mv	a1,s6
    800029f4:	05093503          	ld	a0,80(s2)
    800029f8:	fffff097          	auipc	ra,0xfffff
    800029fc:	c8c080e7          	jalr	-884(ra) # 80001684 <copyout>
    80002a00:	04054263          	bltz	a0,80002a44 <waitall+0x1d8>
  printf("[waitall] Successfully copied statuses and count\n");
    80002a04:	00006517          	auipc	a0,0x6
    80002a08:	a4c50513          	addi	a0,a0,-1460 # 80008450 <digits+0x410>
    80002a0c:	ffffe097          	auipc	ra,0xffffe
    80002a10:	b82080e7          	jalr	-1150(ra) # 8000058e <printf>
  return 0;
    80002a14:	4501                	li	a0,0
    80002a16:	b5c1                	j	800028d6 <waitall+0x6a>
    printf("[waitall] Sleeping... %d statuses collected so far\n", count);
    80002a18:	856e                	mv	a0,s11
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	b74080e7          	jalr	-1164(ra) # 8000058e <printf>
    sleep(p, &wait_lock);
    80002a22:	85ea                	mv	a1,s10
    80002a24:	854a                	mv	a0,s2
    80002a26:	fffff097          	auipc	ra,0xfffff
    80002a2a:	644080e7          	jalr	1604(ra) # 8000206a <sleep>
  while (1) {
    80002a2e:	bded                	j	80002928 <waitall+0xbc>
    printf("[waitall] Failed to copy 'n' to user space\n");
    80002a30:	00006517          	auipc	a0,0x6
    80002a34:	9b850513          	addi	a0,a0,-1608 # 800083e8 <digits+0x3a8>
    80002a38:	ffffe097          	auipc	ra,0xffffe
    80002a3c:	b56080e7          	jalr	-1194(ra) # 8000058e <printf>
    return -1;
    80002a40:	557d                	li	a0,-1
    80002a42:	bd51                	j	800028d6 <waitall+0x6a>
    printf("[waitall] Failed to copy statuses to user space\n");
    80002a44:	00006517          	auipc	a0,0x6
    80002a48:	9d450513          	addi	a0,a0,-1580 # 80008418 <digits+0x3d8>
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	b42080e7          	jalr	-1214(ra) # 8000058e <printf>
    return -1;
    80002a54:	557d                	li	a0,-1
    80002a56:	b541                	j	800028d6 <waitall+0x6a>

0000000080002a58 <swtch>:
    80002a58:	00153023          	sd	ra,0(a0)
    80002a5c:	00253423          	sd	sp,8(a0)
    80002a60:	e900                	sd	s0,16(a0)
    80002a62:	ed04                	sd	s1,24(a0)
    80002a64:	03253023          	sd	s2,32(a0)
    80002a68:	03353423          	sd	s3,40(a0)
    80002a6c:	03453823          	sd	s4,48(a0)
    80002a70:	03553c23          	sd	s5,56(a0)
    80002a74:	05653023          	sd	s6,64(a0)
    80002a78:	05753423          	sd	s7,72(a0)
    80002a7c:	05853823          	sd	s8,80(a0)
    80002a80:	05953c23          	sd	s9,88(a0)
    80002a84:	07a53023          	sd	s10,96(a0)
    80002a88:	07b53423          	sd	s11,104(a0)
    80002a8c:	0005b083          	ld	ra,0(a1)
    80002a90:	0085b103          	ld	sp,8(a1)
    80002a94:	6980                	ld	s0,16(a1)
    80002a96:	6d84                	ld	s1,24(a1)
    80002a98:	0205b903          	ld	s2,32(a1)
    80002a9c:	0285b983          	ld	s3,40(a1)
    80002aa0:	0305ba03          	ld	s4,48(a1)
    80002aa4:	0385ba83          	ld	s5,56(a1)
    80002aa8:	0405bb03          	ld	s6,64(a1)
    80002aac:	0485bb83          	ld	s7,72(a1)
    80002ab0:	0505bc03          	ld	s8,80(a1)
    80002ab4:	0585bc83          	ld	s9,88(a1)
    80002ab8:	0605bd03          	ld	s10,96(a1)
    80002abc:	0685bd83          	ld	s11,104(a1)
    80002ac0:	8082                	ret

0000000080002ac2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002ac2:	1141                	addi	sp,sp,-16
    80002ac4:	e406                	sd	ra,8(sp)
    80002ac6:	e022                	sd	s0,0(sp)
    80002ac8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002aca:	00006597          	auipc	a1,0x6
    80002ace:	a1e58593          	addi	a1,a1,-1506 # 800084e8 <states.1757+0x30>
    80002ad2:	00015517          	auipc	a0,0x15
    80002ad6:	89e50513          	addi	a0,a0,-1890 # 80017370 <tickslock>
    80002ada:	ffffe097          	auipc	ra,0xffffe
    80002ade:	080080e7          	jalr	128(ra) # 80000b5a <initlock>
}
    80002ae2:	60a2                	ld	ra,8(sp)
    80002ae4:	6402                	ld	s0,0(sp)
    80002ae6:	0141                	addi	sp,sp,16
    80002ae8:	8082                	ret

0000000080002aea <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002aea:	1141                	addi	sp,sp,-16
    80002aec:	e422                	sd	s0,8(sp)
    80002aee:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002af0:	00003797          	auipc	a5,0x3
    80002af4:	5f078793          	addi	a5,a5,1520 # 800060e0 <kernelvec>
    80002af8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002afc:	6422                	ld	s0,8(sp)
    80002afe:	0141                	addi	sp,sp,16
    80002b00:	8082                	ret

0000000080002b02 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b02:	1141                	addi	sp,sp,-16
    80002b04:	e406                	sd	ra,8(sp)
    80002b06:	e022                	sd	s0,0(sp)
    80002b08:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b0a:	fffff097          	auipc	ra,0xfffff
    80002b0e:	ebc080e7          	jalr	-324(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b12:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b16:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b18:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b1c:	00004617          	auipc	a2,0x4
    80002b20:	4e460613          	addi	a2,a2,1252 # 80007000 <_trampoline>
    80002b24:	00004697          	auipc	a3,0x4
    80002b28:	4dc68693          	addi	a3,a3,1244 # 80007000 <_trampoline>
    80002b2c:	8e91                	sub	a3,a3,a2
    80002b2e:	040007b7          	lui	a5,0x4000
    80002b32:	17fd                	addi	a5,a5,-1
    80002b34:	07b2                	slli	a5,a5,0xc
    80002b36:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b38:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b3c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b3e:	180026f3          	csrr	a3,satp
    80002b42:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b44:	6d38                	ld	a4,88(a0)
    80002b46:	6134                	ld	a3,64(a0)
    80002b48:	6585                	lui	a1,0x1
    80002b4a:	96ae                	add	a3,a3,a1
    80002b4c:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b4e:	6d38                	ld	a4,88(a0)
    80002b50:	00000697          	auipc	a3,0x0
    80002b54:	13068693          	addi	a3,a3,304 # 80002c80 <usertrap>
    80002b58:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b5a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b5c:	8692                	mv	a3,tp
    80002b5e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b60:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b64:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b68:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b6c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b70:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b72:	6f18                	ld	a4,24(a4)
    80002b74:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b78:	6928                	ld	a0,80(a0)
    80002b7a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b7c:	00004717          	auipc	a4,0x4
    80002b80:	52070713          	addi	a4,a4,1312 # 8000709c <userret>
    80002b84:	8f11                	sub	a4,a4,a2
    80002b86:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b88:	577d                	li	a4,-1
    80002b8a:	177e                	slli	a4,a4,0x3f
    80002b8c:	8d59                	or	a0,a0,a4
    80002b8e:	9782                	jalr	a5
}
    80002b90:	60a2                	ld	ra,8(sp)
    80002b92:	6402                	ld	s0,0(sp)
    80002b94:	0141                	addi	sp,sp,16
    80002b96:	8082                	ret

0000000080002b98 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b98:	1101                	addi	sp,sp,-32
    80002b9a:	ec06                	sd	ra,24(sp)
    80002b9c:	e822                	sd	s0,16(sp)
    80002b9e:	e426                	sd	s1,8(sp)
    80002ba0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ba2:	00014497          	auipc	s1,0x14
    80002ba6:	7ce48493          	addi	s1,s1,1998 # 80017370 <tickslock>
    80002baa:	8526                	mv	a0,s1
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	03e080e7          	jalr	62(ra) # 80000bea <acquire>
  ticks++;
    80002bb4:	00006517          	auipc	a0,0x6
    80002bb8:	f1c50513          	addi	a0,a0,-228 # 80008ad0 <ticks>
    80002bbc:	411c                	lw	a5,0(a0)
    80002bbe:	2785                	addiw	a5,a5,1
    80002bc0:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002bc2:	fffff097          	auipc	ra,0xfffff
    80002bc6:	50c080e7          	jalr	1292(ra) # 800020ce <wakeup>
  release(&tickslock);
    80002bca:	8526                	mv	a0,s1
    80002bcc:	ffffe097          	auipc	ra,0xffffe
    80002bd0:	0d2080e7          	jalr	210(ra) # 80000c9e <release>
}
    80002bd4:	60e2                	ld	ra,24(sp)
    80002bd6:	6442                	ld	s0,16(sp)
    80002bd8:	64a2                	ld	s1,8(sp)
    80002bda:	6105                	addi	sp,sp,32
    80002bdc:	8082                	ret

0000000080002bde <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002bde:	1101                	addi	sp,sp,-32
    80002be0:	ec06                	sd	ra,24(sp)
    80002be2:	e822                	sd	s0,16(sp)
    80002be4:	e426                	sd	s1,8(sp)
    80002be6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002be8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002bec:	00074d63          	bltz	a4,80002c06 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002bf0:	57fd                	li	a5,-1
    80002bf2:	17fe                	slli	a5,a5,0x3f
    80002bf4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002bf6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002bf8:	06f70363          	beq	a4,a5,80002c5e <devintr+0x80>
  }
}
    80002bfc:	60e2                	ld	ra,24(sp)
    80002bfe:	6442                	ld	s0,16(sp)
    80002c00:	64a2                	ld	s1,8(sp)
    80002c02:	6105                	addi	sp,sp,32
    80002c04:	8082                	ret
     (scause & 0xff) == 9){
    80002c06:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002c0a:	46a5                	li	a3,9
    80002c0c:	fed792e3          	bne	a5,a3,80002bf0 <devintr+0x12>
    int irq = plic_claim();
    80002c10:	00003097          	auipc	ra,0x3
    80002c14:	5d8080e7          	jalr	1496(ra) # 800061e8 <plic_claim>
    80002c18:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c1a:	47a9                	li	a5,10
    80002c1c:	02f50763          	beq	a0,a5,80002c4a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c20:	4785                	li	a5,1
    80002c22:	02f50963          	beq	a0,a5,80002c54 <devintr+0x76>
    return 1;
    80002c26:	4505                	li	a0,1
    } else if(irq){
    80002c28:	d8f1                	beqz	s1,80002bfc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c2a:	85a6                	mv	a1,s1
    80002c2c:	00006517          	auipc	a0,0x6
    80002c30:	8c450513          	addi	a0,a0,-1852 # 800084f0 <states.1757+0x38>
    80002c34:	ffffe097          	auipc	ra,0xffffe
    80002c38:	95a080e7          	jalr	-1702(ra) # 8000058e <printf>
      plic_complete(irq);
    80002c3c:	8526                	mv	a0,s1
    80002c3e:	00003097          	auipc	ra,0x3
    80002c42:	5ce080e7          	jalr	1486(ra) # 8000620c <plic_complete>
    return 1;
    80002c46:	4505                	li	a0,1
    80002c48:	bf55                	j	80002bfc <devintr+0x1e>
      uartintr();
    80002c4a:	ffffe097          	auipc	ra,0xffffe
    80002c4e:	d64080e7          	jalr	-668(ra) # 800009ae <uartintr>
    80002c52:	b7ed                	j	80002c3c <devintr+0x5e>
      virtio_disk_intr();
    80002c54:	00004097          	auipc	ra,0x4
    80002c58:	ae2080e7          	jalr	-1310(ra) # 80006736 <virtio_disk_intr>
    80002c5c:	b7c5                	j	80002c3c <devintr+0x5e>
    if(cpuid() == 0){
    80002c5e:	fffff097          	auipc	ra,0xfffff
    80002c62:	d3c080e7          	jalr	-708(ra) # 8000199a <cpuid>
    80002c66:	c901                	beqz	a0,80002c76 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c68:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c6c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c6e:	14479073          	csrw	sip,a5
    return 2;
    80002c72:	4509                	li	a0,2
    80002c74:	b761                	j	80002bfc <devintr+0x1e>
      clockintr();
    80002c76:	00000097          	auipc	ra,0x0
    80002c7a:	f22080e7          	jalr	-222(ra) # 80002b98 <clockintr>
    80002c7e:	b7ed                	j	80002c68 <devintr+0x8a>

0000000080002c80 <usertrap>:
{
    80002c80:	1101                	addi	sp,sp,-32
    80002c82:	ec06                	sd	ra,24(sp)
    80002c84:	e822                	sd	s0,16(sp)
    80002c86:	e426                	sd	s1,8(sp)
    80002c88:	e04a                	sd	s2,0(sp)
    80002c8a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c8c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c90:	1007f793          	andi	a5,a5,256
    80002c94:	e3b1                	bnez	a5,80002cd8 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c96:	00003797          	auipc	a5,0x3
    80002c9a:	44a78793          	addi	a5,a5,1098 # 800060e0 <kernelvec>
    80002c9e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ca2:	fffff097          	auipc	ra,0xfffff
    80002ca6:	d24080e7          	jalr	-732(ra) # 800019c6 <myproc>
    80002caa:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cac:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cae:	14102773          	csrr	a4,sepc
    80002cb2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cb4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cb8:	47a1                	li	a5,8
    80002cba:	02f70763          	beq	a4,a5,80002ce8 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002cbe:	00000097          	auipc	ra,0x0
    80002cc2:	f20080e7          	jalr	-224(ra) # 80002bde <devintr>
    80002cc6:	892a                	mv	s2,a0
    80002cc8:	c941                	beqz	a0,80002d58 <usertrap+0xd8>
  if(killed(p))
    80002cca:	8526                	mv	a0,s1
    80002ccc:	fffff097          	auipc	ra,0xfffff
    80002cd0:	6c0080e7          	jalr	1728(ra) # 8000238c <killed>
    80002cd4:	cd21                	beqz	a0,80002d2c <usertrap+0xac>
    80002cd6:	a099                	j	80002d1c <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002cd8:	00006517          	auipc	a0,0x6
    80002cdc:	83850513          	addi	a0,a0,-1992 # 80008510 <states.1757+0x58>
    80002ce0:	ffffe097          	auipc	ra,0xffffe
    80002ce4:	864080e7          	jalr	-1948(ra) # 80000544 <panic>
    if(killed(p))
    80002ce8:	fffff097          	auipc	ra,0xfffff
    80002cec:	6a4080e7          	jalr	1700(ra) # 8000238c <killed>
    80002cf0:	e939                	bnez	a0,80002d46 <usertrap+0xc6>
    p->trapframe->epc += 4;
    80002cf2:	6cb8                	ld	a4,88(s1)
    80002cf4:	6f1c                	ld	a5,24(a4)
    80002cf6:	0791                	addi	a5,a5,4
    80002cf8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002cfe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d02:	10079073          	csrw	sstatus,a5
    syscall();
    80002d06:	00000097          	auipc	ra,0x0
    80002d0a:	2b2080e7          	jalr	690(ra) # 80002fb8 <syscall>
  if(killed(p))
    80002d0e:	8526                	mv	a0,s1
    80002d10:	fffff097          	auipc	ra,0xfffff
    80002d14:	67c080e7          	jalr	1660(ra) # 8000238c <killed>
    80002d18:	cd09                	beqz	a0,80002d32 <usertrap+0xb2>
    80002d1a:	4901                	li	s2,0
    exit("killed");
    80002d1c:	00006517          	auipc	a0,0x6
    80002d20:	87450513          	addi	a0,a0,-1932 # 80008590 <states.1757+0xd8>
    80002d24:	fffff097          	auipc	ra,0xfffff
    80002d28:	47a080e7          	jalr	1146(ra) # 8000219e <exit>
  if(which_dev == 2)
    80002d2c:	4789                	li	a5,2
    80002d2e:	06f90263          	beq	s2,a5,80002d92 <usertrap+0x112>
  usertrapret();
    80002d32:	00000097          	auipc	ra,0x0
    80002d36:	dd0080e7          	jalr	-560(ra) # 80002b02 <usertrapret>
}
    80002d3a:	60e2                	ld	ra,24(sp)
    80002d3c:	6442                	ld	s0,16(sp)
    80002d3e:	64a2                	ld	s1,8(sp)
    80002d40:	6902                	ld	s2,0(sp)
    80002d42:	6105                	addi	sp,sp,32
    80002d44:	8082                	ret
      exit("syscall error");
    80002d46:	00005517          	auipc	a0,0x5
    80002d4a:	7ea50513          	addi	a0,a0,2026 # 80008530 <states.1757+0x78>
    80002d4e:	fffff097          	auipc	ra,0xfffff
    80002d52:	450080e7          	jalr	1104(ra) # 8000219e <exit>
    80002d56:	bf71                	j	80002cf2 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d58:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d5c:	5890                	lw	a2,48(s1)
    80002d5e:	00005517          	auipc	a0,0x5
    80002d62:	7e250513          	addi	a0,a0,2018 # 80008540 <states.1757+0x88>
    80002d66:	ffffe097          	auipc	ra,0xffffe
    80002d6a:	828080e7          	jalr	-2008(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d6e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d72:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d76:	00005517          	auipc	a0,0x5
    80002d7a:	7fa50513          	addi	a0,a0,2042 # 80008570 <states.1757+0xb8>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	810080e7          	jalr	-2032(ra) # 8000058e <printf>
    setkilled(p);
    80002d86:	8526                	mv	a0,s1
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	5d8080e7          	jalr	1496(ra) # 80002360 <setkilled>
    80002d90:	bfbd                	j	80002d0e <usertrap+0x8e>
    yield();
    80002d92:	fffff097          	auipc	ra,0xfffff
    80002d96:	29c080e7          	jalr	668(ra) # 8000202e <yield>
    80002d9a:	bf61                	j	80002d32 <usertrap+0xb2>

0000000080002d9c <kerneltrap>:
{
    80002d9c:	1101                	addi	sp,sp,-32
    80002d9e:	ec06                	sd	ra,24(sp)
    80002da0:	e822                	sd	s0,16(sp)
    80002da2:	e426                	sd	s1,8(sp)
    80002da4:	e04a                	sd	s2,0(sp)
    80002da6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002da8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dac:	100024f3          	csrr	s1,sstatus
  if((sstatus & SSTATUS_SPP) == 0)
    80002db0:	1004f793          	andi	a5,s1,256
    80002db4:	c79d                	beqz	a5,80002de2 <kerneltrap+0x46>
    80002db6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002dba:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002dbc:	eb9d                	bnez	a5,80002df2 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002dbe:	00000097          	auipc	ra,0x0
    80002dc2:	e20080e7          	jalr	-480(ra) # 80002bde <devintr>
    80002dc6:	cd15                	beqz	a0,80002e02 <kerneltrap+0x66>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dc8:	4789                	li	a5,2
    80002dca:	04f50463          	beq	a0,a5,80002e12 <kerneltrap+0x76>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002dce:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dd2:	10049073          	csrw	sstatus,s1
}
    80002dd6:	60e2                	ld	ra,24(sp)
    80002dd8:	6442                	ld	s0,16(sp)
    80002dda:	64a2                	ld	s1,8(sp)
    80002ddc:	6902                	ld	s2,0(sp)
    80002dde:	6105                	addi	sp,sp,32
    80002de0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002de2:	00005517          	auipc	a0,0x5
    80002de6:	7b650513          	addi	a0,a0,1974 # 80008598 <states.1757+0xe0>
    80002dea:	ffffd097          	auipc	ra,0xffffd
    80002dee:	75a080e7          	jalr	1882(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002df2:	00005517          	auipc	a0,0x5
    80002df6:	7ce50513          	addi	a0,a0,1998 # 800085c0 <states.1757+0x108>
    80002dfa:	ffffd097          	auipc	ra,0xffffd
    80002dfe:	74a080e7          	jalr	1866(ra) # 80000544 <panic>
    panic("kerneltrap");
    80002e02:	00005517          	auipc	a0,0x5
    80002e06:	7de50513          	addi	a0,a0,2014 # 800085e0 <states.1757+0x128>
    80002e0a:	ffffd097          	auipc	ra,0xffffd
    80002e0e:	73a080e7          	jalr	1850(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e12:	fffff097          	auipc	ra,0xfffff
    80002e16:	bb4080e7          	jalr	-1100(ra) # 800019c6 <myproc>
    80002e1a:	d955                	beqz	a0,80002dce <kerneltrap+0x32>
    80002e1c:	fffff097          	auipc	ra,0xfffff
    80002e20:	baa080e7          	jalr	-1110(ra) # 800019c6 <myproc>
    80002e24:	4d18                	lw	a4,24(a0)
    80002e26:	4791                	li	a5,4
    80002e28:	faf713e3          	bne	a4,a5,80002dce <kerneltrap+0x32>
    yield();
    80002e2c:	fffff097          	auipc	ra,0xfffff
    80002e30:	202080e7          	jalr	514(ra) # 8000202e <yield>
    80002e34:	bf69                	j	80002dce <kerneltrap+0x32>

0000000080002e36 <argraw>:
    return -1;
  return strlen(buf);
}

static uint64 argraw(int n)
{
    80002e36:	1101                	addi	sp,sp,-32
    80002e38:	ec06                	sd	ra,24(sp)
    80002e3a:	e822                	sd	s0,16(sp)
    80002e3c:	e426                	sd	s1,8(sp)
    80002e3e:	1000                	addi	s0,sp,32
    80002e40:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e42:	fffff097          	auipc	ra,0xfffff
    80002e46:	b84080e7          	jalr	-1148(ra) # 800019c6 <myproc>
  switch (n) {
    80002e4a:	4795                	li	a5,5
    80002e4c:	0497e163          	bltu	a5,s1,80002e8e <argraw+0x58>
    80002e50:	048a                	slli	s1,s1,0x2
    80002e52:	00005717          	auipc	a4,0x5
    80002e56:	7c670713          	addi	a4,a4,1990 # 80008618 <states.1757+0x160>
    80002e5a:	94ba                	add	s1,s1,a4
    80002e5c:	409c                	lw	a5,0(s1)
    80002e5e:	97ba                	add	a5,a5,a4
    80002e60:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e62:	6d3c                	ld	a5,88(a0)
    80002e64:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e66:	60e2                	ld	ra,24(sp)
    80002e68:	6442                	ld	s0,16(sp)
    80002e6a:	64a2                	ld	s1,8(sp)
    80002e6c:	6105                	addi	sp,sp,32
    80002e6e:	8082                	ret
    return p->trapframe->a1;
    80002e70:	6d3c                	ld	a5,88(a0)
    80002e72:	7fa8                	ld	a0,120(a5)
    80002e74:	bfcd                	j	80002e66 <argraw+0x30>
    return p->trapframe->a2;
    80002e76:	6d3c                	ld	a5,88(a0)
    80002e78:	63c8                	ld	a0,128(a5)
    80002e7a:	b7f5                	j	80002e66 <argraw+0x30>
    return p->trapframe->a3;
    80002e7c:	6d3c                	ld	a5,88(a0)
    80002e7e:	67c8                	ld	a0,136(a5)
    80002e80:	b7dd                	j	80002e66 <argraw+0x30>
    return p->trapframe->a4;
    80002e82:	6d3c                	ld	a5,88(a0)
    80002e84:	6bc8                	ld	a0,144(a5)
    80002e86:	b7c5                	j	80002e66 <argraw+0x30>
    return p->trapframe->a5;
    80002e88:	6d3c                	ld	a5,88(a0)
    80002e8a:	6fc8                	ld	a0,152(a5)
    80002e8c:	bfe9                	j	80002e66 <argraw+0x30>
  panic("argraw");
    80002e8e:	00005517          	auipc	a0,0x5
    80002e92:	76250513          	addi	a0,a0,1890 # 800085f0 <states.1757+0x138>
    80002e96:	ffffd097          	auipc	ra,0xffffd
    80002e9a:	6ae080e7          	jalr	1710(ra) # 80000544 <panic>

0000000080002e9e <fetchaddr>:
{
    80002e9e:	1101                	addi	sp,sp,-32
    80002ea0:	ec06                	sd	ra,24(sp)
    80002ea2:	e822                	sd	s0,16(sp)
    80002ea4:	e426                	sd	s1,8(sp)
    80002ea6:	e04a                	sd	s2,0(sp)
    80002ea8:	1000                	addi	s0,sp,32
    80002eaa:	84aa                	mv	s1,a0
    80002eac:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002eae:	fffff097          	auipc	ra,0xfffff
    80002eb2:	b18080e7          	jalr	-1256(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002eb6:	653c                	ld	a5,72(a0)
    80002eb8:	02f4f863          	bgeu	s1,a5,80002ee8 <fetchaddr+0x4a>
    80002ebc:	00848713          	addi	a4,s1,8
    80002ec0:	02e7e663          	bltu	a5,a4,80002eec <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ec4:	46a1                	li	a3,8
    80002ec6:	8626                	mv	a2,s1
    80002ec8:	85ca                	mv	a1,s2
    80002eca:	6928                	ld	a0,80(a0)
    80002ecc:	fffff097          	auipc	ra,0xfffff
    80002ed0:	844080e7          	jalr	-1980(ra) # 80001710 <copyin>
    80002ed4:	00a03533          	snez	a0,a0
    80002ed8:	40a00533          	neg	a0,a0
}
    80002edc:	60e2                	ld	ra,24(sp)
    80002ede:	6442                	ld	s0,16(sp)
    80002ee0:	64a2                	ld	s1,8(sp)
    80002ee2:	6902                	ld	s2,0(sp)
    80002ee4:	6105                	addi	sp,sp,32
    80002ee6:	8082                	ret
    return -1;
    80002ee8:	557d                	li	a0,-1
    80002eea:	bfcd                	j	80002edc <fetchaddr+0x3e>
    80002eec:	557d                	li	a0,-1
    80002eee:	b7fd                	j	80002edc <fetchaddr+0x3e>

0000000080002ef0 <fetchstr>:
{
    80002ef0:	7179                	addi	sp,sp,-48
    80002ef2:	f406                	sd	ra,40(sp)
    80002ef4:	f022                	sd	s0,32(sp)
    80002ef6:	ec26                	sd	s1,24(sp)
    80002ef8:	e84a                	sd	s2,16(sp)
    80002efa:	e44e                	sd	s3,8(sp)
    80002efc:	1800                	addi	s0,sp,48
    80002efe:	892a                	mv	s2,a0
    80002f00:	84ae                	mv	s1,a1
    80002f02:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f04:	fffff097          	auipc	ra,0xfffff
    80002f08:	ac2080e7          	jalr	-1342(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002f0c:	86ce                	mv	a3,s3
    80002f0e:	864a                	mv	a2,s2
    80002f10:	85a6                	mv	a1,s1
    80002f12:	6928                	ld	a0,80(a0)
    80002f14:	fffff097          	auipc	ra,0xfffff
    80002f18:	888080e7          	jalr	-1912(ra) # 8000179c <copyinstr>
    80002f1c:	00054e63          	bltz	a0,80002f38 <fetchstr+0x48>
  return strlen(buf);
    80002f20:	8526                	mv	a0,s1
    80002f22:	ffffe097          	auipc	ra,0xffffe
    80002f26:	f48080e7          	jalr	-184(ra) # 80000e6a <strlen>
}
    80002f2a:	70a2                	ld	ra,40(sp)
    80002f2c:	7402                	ld	s0,32(sp)
    80002f2e:	64e2                	ld	s1,24(sp)
    80002f30:	6942                	ld	s2,16(sp)
    80002f32:	69a2                	ld	s3,8(sp)
    80002f34:	6145                	addi	sp,sp,48
    80002f36:	8082                	ret
    return -1;
    80002f38:	557d                	li	a0,-1
    80002f3a:	bfc5                	j	80002f2a <fetchstr+0x3a>

0000000080002f3c <argint>:

// Fetch the nth 32-bit system call argument.
int argint(int n, int *ip)
{
    80002f3c:	1101                	addi	sp,sp,-32
    80002f3e:	ec06                	sd	ra,24(sp)
    80002f40:	e822                	sd	s0,16(sp)
    80002f42:	e426                	sd	s1,8(sp)
    80002f44:	1000                	addi	s0,sp,32
    80002f46:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f48:	00000097          	auipc	ra,0x0
    80002f4c:	eee080e7          	jalr	-274(ra) # 80002e36 <argraw>
    80002f50:	c088                	sw	a0,0(s1)
  return 0;
}
    80002f52:	4501                	li	a0,0
    80002f54:	60e2                	ld	ra,24(sp)
    80002f56:	6442                	ld	s0,16(sp)
    80002f58:	64a2                	ld	s1,8(sp)
    80002f5a:	6105                	addi	sp,sp,32
    80002f5c:	8082                	ret

0000000080002f5e <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int argaddr(int n, uint64 *ip)
{
    80002f5e:	1101                	addi	sp,sp,-32
    80002f60:	ec06                	sd	ra,24(sp)
    80002f62:	e822                	sd	s0,16(sp)
    80002f64:	e426                	sd	s1,8(sp)
    80002f66:	1000                	addi	s0,sp,32
    80002f68:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f6a:	00000097          	auipc	ra,0x0
    80002f6e:	ecc080e7          	jalr	-308(ra) # 80002e36 <argraw>
    80002f72:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f74:	4501                	li	a0,0
    80002f76:	60e2                	ld	ra,24(sp)
    80002f78:	6442                	ld	s0,16(sp)
    80002f7a:	64a2                	ld	s1,8(sp)
    80002f7c:	6105                	addi	sp,sp,32
    80002f7e:	8082                	ret

0000000080002f80 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002f80:	7179                	addi	sp,sp,-48
    80002f82:	f406                	sd	ra,40(sp)
    80002f84:	f022                	sd	s0,32(sp)
    80002f86:	ec26                	sd	s1,24(sp)
    80002f88:	e84a                	sd	s2,16(sp)
    80002f8a:	1800                	addi	s0,sp,48
    80002f8c:	84ae                	mv	s1,a1
    80002f8e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002f90:	fd840593          	addi	a1,s0,-40
    80002f94:	00000097          	auipc	ra,0x0
    80002f98:	fca080e7          	jalr	-54(ra) # 80002f5e <argaddr>
  return fetchstr(addr, buf, max);
    80002f9c:	864a                	mv	a2,s2
    80002f9e:	85a6                	mv	a1,s1
    80002fa0:	fd843503          	ld	a0,-40(s0)
    80002fa4:	00000097          	auipc	ra,0x0
    80002fa8:	f4c080e7          	jalr	-180(ra) # 80002ef0 <fetchstr>
}
    80002fac:	70a2                	ld	ra,40(sp)
    80002fae:	7402                	ld	s0,32(sp)
    80002fb0:	64e2                	ld	s1,24(sp)
    80002fb2:	6942                	ld	s2,16(sp)
    80002fb4:	6145                	addi	sp,sp,48
    80002fb6:	8082                	ret

0000000080002fb8 <syscall>:
[SYS_waitall] sys_waitall,
[SYS_exit_num] sys_exit_num,
};

void syscall(void)
{
    80002fb8:	1101                	addi	sp,sp,-32
    80002fba:	ec06                	sd	ra,24(sp)
    80002fbc:	e822                	sd	s0,16(sp)
    80002fbe:	e426                	sd	s1,8(sp)
    80002fc0:	e04a                	sd	s2,0(sp)
    80002fc2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002fc4:	fffff097          	auipc	ra,0xfffff
    80002fc8:	a02080e7          	jalr	-1534(ra) # 800019c6 <myproc>
    80002fcc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002fce:	05853903          	ld	s2,88(a0)
    80002fd2:	0a893783          	ld	a5,168(s2)
    80002fd6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002fda:	37fd                	addiw	a5,a5,-1
    80002fdc:	4769                	li	a4,26
    80002fde:	00f76f63          	bltu	a4,a5,80002ffc <syscall+0x44>
    80002fe2:	00369713          	slli	a4,a3,0x3
    80002fe6:	00005797          	auipc	a5,0x5
    80002fea:	64a78793          	addi	a5,a5,1610 # 80008630 <syscalls>
    80002fee:	97ba                	add	a5,a5,a4
    80002ff0:	639c                	ld	a5,0(a5)
    80002ff2:	c789                	beqz	a5,80002ffc <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ff4:	9782                	jalr	a5
    80002ff6:	06a93823          	sd	a0,112(s2)
    80002ffa:	a839                	j	80003018 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ffc:	15848613          	addi	a2,s1,344
    80003000:	588c                	lw	a1,48(s1)
    80003002:	00005517          	auipc	a0,0x5
    80003006:	5f650513          	addi	a0,a0,1526 # 800085f8 <states.1757+0x140>
    8000300a:	ffffd097          	auipc	ra,0xffffd
    8000300e:	584080e7          	jalr	1412(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003012:	6cbc                	ld	a5,88(s1)
    80003014:	577d                	li	a4,-1
    80003016:	fbb8                	sd	a4,112(a5)
  }
}
    80003018:	60e2                	ld	ra,24(sp)
    8000301a:	6442                	ld	s0,16(sp)
    8000301c:	64a2                	ld	s1,8(sp)
    8000301e:	6902                	ld	s2,0(sp)
    80003020:	6105                	addi	sp,sp,32
    80003022:	8082                	ret

0000000080003024 <sys_exit>:
// Add function declarations
extern struct proc* allocproc(void);
extern void freeproc(struct proc *p);

uint64 sys_exit(void)
{
    80003024:	1101                	addi	sp,sp,-32
    80003026:	ec06                	sd	ra,24(sp)
    80003028:	e822                	sd	s0,16(sp)
    8000302a:	1000                	addi	s0,sp,32
  int status;
  argint(0, &status);
    8000302c:	fec40593          	addi	a1,s0,-20
    80003030:	4501                	li	a0,0
    80003032:	00000097          	auipc	ra,0x0
    80003036:	f0a080e7          	jalr	-246(ra) # 80002f3c <argint>
  exit_num(status);  
    8000303a:	fec42503          	lw	a0,-20(s0)
    8000303e:	fffff097          	auipc	ra,0xfffff
    80003042:	24c080e7          	jalr	588(ra) # 8000228a <exit_num>
  return 0; // never returns
}
    80003046:	4501                	li	a0,0
    80003048:	60e2                	ld	ra,24(sp)
    8000304a:	6442                	ld	s0,16(sp)
    8000304c:	6105                	addi	sp,sp,32
    8000304e:	8082                	ret

0000000080003050 <sys_exitmsg>:

uint64 sys_exitmsg(void)
{
    80003050:	7179                	addi	sp,sp,-48
    80003052:	f406                	sd	ra,40(sp)
    80003054:	f022                	sd	s0,32(sp)
    80003056:	1800                	addi	s0,sp,48
  exit_msg(msg);
  return 0; // never returns
  */

  char msg[32];
  if (argstr(0, msg, sizeof(msg)) < 0)
    80003058:	02000613          	li	a2,32
    8000305c:	fd040593          	addi	a1,s0,-48
    80003060:	4501                	li	a0,0
    80003062:	00000097          	auipc	ra,0x0
    80003066:	f1e080e7          	jalr	-226(ra) # 80002f80 <argstr>
    return -1;
    8000306a:	57fd                	li	a5,-1
  if (argstr(0, msg, sizeof(msg)) < 0)
    8000306c:	00054963          	bltz	a0,8000307e <sys_exitmsg+0x2e>

  exit_msg(msg);
    80003070:	fd040513          	addi	a0,s0,-48
    80003074:	fffff097          	auipc	ra,0xfffff
    80003078:	23c080e7          	jalr	572(ra) # 800022b0 <exit_msg>
  return 0;
    8000307c:	4781                	li	a5,0

  
}
    8000307e:	853e                	mv	a0,a5
    80003080:	70a2                	ld	ra,40(sp)
    80003082:	7402                	ld	s0,32(sp)
    80003084:	6145                	addi	sp,sp,48
    80003086:	8082                	ret

0000000080003088 <sys_getpid>:

uint64 sys_getpid(void)
{
    80003088:	1141                	addi	sp,sp,-16
    8000308a:	e406                	sd	ra,8(sp)
    8000308c:	e022                	sd	s0,0(sp)
    8000308e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003090:	fffff097          	auipc	ra,0xfffff
    80003094:	936080e7          	jalr	-1738(ra) # 800019c6 <myproc>
}
    80003098:	5908                	lw	a0,48(a0)
    8000309a:	60a2                	ld	ra,8(sp)
    8000309c:	6402                	ld	s0,0(sp)
    8000309e:	0141                	addi	sp,sp,16
    800030a0:	8082                	ret

00000000800030a2 <sys_fork>:

uint64 sys_fork(void)
{
    800030a2:	1141                	addi	sp,sp,-16
    800030a4:	e406                	sd	ra,8(sp)
    800030a6:	e022                	sd	s0,0(sp)
    800030a8:	0800                	addi	s0,sp,16
  return fork();
    800030aa:	fffff097          	auipc	ra,0xfffff
    800030ae:	cd2080e7          	jalr	-814(ra) # 80001d7c <fork>
}
    800030b2:	60a2                	ld	ra,8(sp)
    800030b4:	6402                	ld	s0,0(sp)
    800030b6:	0141                	addi	sp,sp,16
    800030b8:	8082                	ret

00000000800030ba <sys_wait>:

uint64 sys_wait(void){
    800030ba:	1101                	addi	sp,sp,-32
    800030bc:	ec06                	sd	ra,24(sp)
    800030be:	e822                	sd	s0,16(sp)
    800030c0:	1000                	addi	s0,sp,32
  uint64 status_addr;
  uint64 msg_addr;

  argaddr(0, &status_addr);
    800030c2:	fe840593          	addi	a1,s0,-24
    800030c6:	4501                	li	a0,0
    800030c8:	00000097          	auipc	ra,0x0
    800030cc:	e96080e7          	jalr	-362(ra) # 80002f5e <argaddr>
  argaddr(1, &msg_addr);
    800030d0:	fe040593          	addi	a1,s0,-32
    800030d4:	4505                	li	a0,1
    800030d6:	00000097          	auipc	ra,0x0
    800030da:	e88080e7          	jalr	-376(ra) # 80002f5e <argaddr>

  return wait(status_addr, msg_addr);
    800030de:	fe043583          	ld	a1,-32(s0)
    800030e2:	fe843503          	ld	a0,-24(s0)
    800030e6:	fffff097          	auipc	ra,0xfffff
    800030ea:	2d8080e7          	jalr	728(ra) # 800023be <wait>
} 
    800030ee:	60e2                	ld	ra,24(sp)
    800030f0:	6442                	ld	s0,16(sp)
    800030f2:	6105                	addi	sp,sp,32
    800030f4:	8082                	ret

00000000800030f6 <sys_sbrk>:

uint64 sys_sbrk(void)
{
    800030f6:	7179                	addi	sp,sp,-48
    800030f8:	f406                	sd	ra,40(sp)
    800030fa:	f022                	sd	s0,32(sp)
    800030fc:	ec26                	sd	s1,24(sp)
    800030fe:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003100:	fdc40593          	addi	a1,s0,-36
    80003104:	4501                	li	a0,0
    80003106:	00000097          	auipc	ra,0x0
    8000310a:	e36080e7          	jalr	-458(ra) # 80002f3c <argint>
  addr = myproc()->sz;
    8000310e:	fffff097          	auipc	ra,0xfffff
    80003112:	8b8080e7          	jalr	-1864(ra) # 800019c6 <myproc>
    80003116:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80003118:	fdc42503          	lw	a0,-36(s0)
    8000311c:	fffff097          	auipc	ra,0xfffff
    80003120:	c04080e7          	jalr	-1020(ra) # 80001d20 <growproc>
    80003124:	00054863          	bltz	a0,80003134 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003128:	8526                	mv	a0,s1
    8000312a:	70a2                	ld	ra,40(sp)
    8000312c:	7402                	ld	s0,32(sp)
    8000312e:	64e2                	ld	s1,24(sp)
    80003130:	6145                	addi	sp,sp,48
    80003132:	8082                	ret
    return -1;
    80003134:	54fd                	li	s1,-1
    80003136:	bfcd                	j	80003128 <sys_sbrk+0x32>

0000000080003138 <sys_sleep>:

uint64 sys_sleep(void)
{
    80003138:	7139                	addi	sp,sp,-64
    8000313a:	fc06                	sd	ra,56(sp)
    8000313c:	f822                	sd	s0,48(sp)
    8000313e:	f426                	sd	s1,40(sp)
    80003140:	f04a                	sd	s2,32(sp)
    80003142:	ec4e                	sd	s3,24(sp)
    80003144:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003146:	fcc40593          	addi	a1,s0,-52
    8000314a:	4501                	li	a0,0
    8000314c:	00000097          	auipc	ra,0x0
    80003150:	df0080e7          	jalr	-528(ra) # 80002f3c <argint>
  acquire(&tickslock);
    80003154:	00014517          	auipc	a0,0x14
    80003158:	21c50513          	addi	a0,a0,540 # 80017370 <tickslock>
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	a8e080e7          	jalr	-1394(ra) # 80000bea <acquire>
  ticks0 = ticks;
    80003164:	00006917          	auipc	s2,0x6
    80003168:	96c92903          	lw	s2,-1684(s2) # 80008ad0 <ticks>
  while(ticks - ticks0 < n){
    8000316c:	fcc42783          	lw	a5,-52(s0)
    80003170:	cf9d                	beqz	a5,800031ae <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003172:	00014997          	auipc	s3,0x14
    80003176:	1fe98993          	addi	s3,s3,510 # 80017370 <tickslock>
    8000317a:	00006497          	auipc	s1,0x6
    8000317e:	95648493          	addi	s1,s1,-1706 # 80008ad0 <ticks>
    if(killed(myproc())){
    80003182:	fffff097          	auipc	ra,0xfffff
    80003186:	844080e7          	jalr	-1980(ra) # 800019c6 <myproc>
    8000318a:	fffff097          	auipc	ra,0xfffff
    8000318e:	202080e7          	jalr	514(ra) # 8000238c <killed>
    80003192:	ed15                	bnez	a0,800031ce <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003194:	85ce                	mv	a1,s3
    80003196:	8526                	mv	a0,s1
    80003198:	fffff097          	auipc	ra,0xfffff
    8000319c:	ed2080e7          	jalr	-302(ra) # 8000206a <sleep>
  while(ticks - ticks0 < n){
    800031a0:	409c                	lw	a5,0(s1)
    800031a2:	412787bb          	subw	a5,a5,s2
    800031a6:	fcc42703          	lw	a4,-52(s0)
    800031aa:	fce7ece3          	bltu	a5,a4,80003182 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800031ae:	00014517          	auipc	a0,0x14
    800031b2:	1c250513          	addi	a0,a0,450 # 80017370 <tickslock>
    800031b6:	ffffe097          	auipc	ra,0xffffe
    800031ba:	ae8080e7          	jalr	-1304(ra) # 80000c9e <release>
  return 0;
    800031be:	4501                	li	a0,0
}
    800031c0:	70e2                	ld	ra,56(sp)
    800031c2:	7442                	ld	s0,48(sp)
    800031c4:	74a2                	ld	s1,40(sp)
    800031c6:	7902                	ld	s2,32(sp)
    800031c8:	69e2                	ld	s3,24(sp)
    800031ca:	6121                	addi	sp,sp,64
    800031cc:	8082                	ret
      release(&tickslock);
    800031ce:	00014517          	auipc	a0,0x14
    800031d2:	1a250513          	addi	a0,a0,418 # 80017370 <tickslock>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	ac8080e7          	jalr	-1336(ra) # 80000c9e <release>
      return -1;
    800031de:	557d                	li	a0,-1
    800031e0:	b7c5                	j	800031c0 <sys_sleep+0x88>

00000000800031e2 <sys_kill>:

uint64 sys_kill(void)
{
    800031e2:	1101                	addi	sp,sp,-32
    800031e4:	ec06                	sd	ra,24(sp)
    800031e6:	e822                	sd	s0,16(sp)
    800031e8:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800031ea:	fec40593          	addi	a1,s0,-20
    800031ee:	4501                	li	a0,0
    800031f0:	00000097          	auipc	ra,0x0
    800031f4:	d4c080e7          	jalr	-692(ra) # 80002f3c <argint>
  return kill(pid);
    800031f8:	fec42503          	lw	a0,-20(s0)
    800031fc:	fffff097          	auipc	ra,0xfffff
    80003200:	0f2080e7          	jalr	242(ra) # 800022ee <kill>
}
    80003204:	60e2                	ld	ra,24(sp)
    80003206:	6442                	ld	s0,16(sp)
    80003208:	6105                	addi	sp,sp,32
    8000320a:	8082                	ret

000000008000320c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64 sys_uptime(void)
{
    8000320c:	1101                	addi	sp,sp,-32
    8000320e:	ec06                	sd	ra,24(sp)
    80003210:	e822                	sd	s0,16(sp)
    80003212:	e426                	sd	s1,8(sp)
    80003214:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003216:	00014517          	auipc	a0,0x14
    8000321a:	15a50513          	addi	a0,a0,346 # 80017370 <tickslock>
    8000321e:	ffffe097          	auipc	ra,0xffffe
    80003222:	9cc080e7          	jalr	-1588(ra) # 80000bea <acquire>
  xticks = ticks;
    80003226:	00006497          	auipc	s1,0x6
    8000322a:	8aa4a483          	lw	s1,-1878(s1) # 80008ad0 <ticks>
  release(&tickslock);
    8000322e:	00014517          	auipc	a0,0x14
    80003232:	14250513          	addi	a0,a0,322 # 80017370 <tickslock>
    80003236:	ffffe097          	auipc	ra,0xffffe
    8000323a:	a68080e7          	jalr	-1432(ra) # 80000c9e <release>
  return xticks;
}
    8000323e:	02049513          	slli	a0,s1,0x20
    80003242:	9101                	srli	a0,a0,0x20
    80003244:	60e2                	ld	ra,24(sp)
    80003246:	6442                	ld	s0,16(sp)
    80003248:	64a2                	ld	s1,8(sp)
    8000324a:	6105                	addi	sp,sp,32
    8000324c:	8082                	ret

000000008000324e <sys_memsize>:


//I Added
uint64 sys_memsize(void)
{
    8000324e:	1141                	addi	sp,sp,-16
    80003250:	e406                	sd	ra,8(sp)
    80003252:	e022                	sd	s0,0(sp)
    80003254:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003256:	ffffe097          	auipc	ra,0xffffe
    8000325a:	770080e7          	jalr	1904(ra) # 800019c6 <myproc>
  return p->sz;
}
    8000325e:	6528                	ld	a0,72(a0)
    80003260:	60a2                	ld	ra,8(sp)
    80003262:	6402                	ld	s0,0(sp)
    80003264:	0141                	addi	sp,sp,16
    80003266:	8082                	ret

0000000080003268 <sys_forkn>:

uint64 sys_forkn(void)
{
    80003268:	7159                	addi	sp,sp,-112
    8000326a:	f486                	sd	ra,104(sp)
    8000326c:	f0a2                	sd	s0,96(sp)
    8000326e:	eca6                	sd	s1,88(sp)
    80003270:	1880                	addi	s0,sp,112
  int n;
  uint64 pids_addr;

  // Get args from userspace
  if (argint(0, &n) < 0 || argaddr(1, &pids_addr) < 0)
    80003272:	fdc40593          	addi	a1,s0,-36
    80003276:	4501                	li	a0,0
    80003278:	00000097          	auipc	ra,0x0
    8000327c:	cc4080e7          	jalr	-828(ra) # 80002f3c <argint>
    return -1;
    80003280:	54fd                	li	s1,-1
  if (argint(0, &n) < 0 || argaddr(1, &pids_addr) < 0)
    80003282:	02054d63          	bltz	a0,800032bc <sys_forkn+0x54>
    80003286:	fd040593          	addi	a1,s0,-48
    8000328a:	4505                	li	a0,1
    8000328c:	00000097          	auipc	ra,0x0
    80003290:	cd2080e7          	jalr	-814(ra) # 80002f5e <argaddr>
    80003294:	04054e63          	bltz	a0,800032f0 <sys_forkn+0x88>

  // Check for invalid input
  if (n < 1 || n > 16 || pids_addr == 0)
    80003298:	fdc42503          	lw	a0,-36(s0)
    8000329c:	fff5069b          	addiw	a3,a0,-1
    800032a0:	473d                	li	a4,15
    800032a2:	00d76d63          	bltu	a4,a3,800032bc <sys_forkn+0x54>
    800032a6:	fd043703          	ld	a4,-48(s0)
    800032aa:	cb09                	beqz	a4,800032bc <sys_forkn+0x54>
    return -1;

  int pids[16]; // Temporary kernel buffer

  int result = forkn(n, pids);  
    800032ac:	f9040593          	addi	a1,s0,-112
    800032b0:	fffff097          	auipc	ra,0xfffff
    800032b4:	3fc080e7          	jalr	1020(ra) # 800026ac <forkn>
    800032b8:	84aa                	mv	s1,a0
  if (result == 0) {
    800032ba:	c519                	beqz	a0,800032c8 <sys_forkn+0x60>
    if (copyout(p->pagetable, pids_addr, (char *)pids, n * sizeof(int)) < 0)
      return -1;
  }

  return result;
}
    800032bc:	8526                	mv	a0,s1
    800032be:	70a6                	ld	ra,104(sp)
    800032c0:	7406                	ld	s0,96(sp)
    800032c2:	64e6                	ld	s1,88(sp)
    800032c4:	6165                	addi	sp,sp,112
    800032c6:	8082                	ret
    struct proc *p = myproc();
    800032c8:	ffffe097          	auipc	ra,0xffffe
    800032cc:	6fe080e7          	jalr	1790(ra) # 800019c6 <myproc>
    if (copyout(p->pagetable, pids_addr, (char *)pids, n * sizeof(int)) < 0)
    800032d0:	fdc42683          	lw	a3,-36(s0)
    800032d4:	068a                	slli	a3,a3,0x2
    800032d6:	f9040613          	addi	a2,s0,-112
    800032da:	fd043583          	ld	a1,-48(s0)
    800032de:	6928                	ld	a0,80(a0)
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	3a4080e7          	jalr	932(ra) # 80001684 <copyout>
    800032e8:	fc055ae3          	bgez	a0,800032bc <sys_forkn+0x54>
      return -1;
    800032ec:	54fd                	li	s1,-1
    800032ee:	b7f9                	j	800032bc <sys_forkn+0x54>
    return -1;
    800032f0:	54fd                	li	s1,-1
    800032f2:	b7e9                	j	800032bc <sys_forkn+0x54>

00000000800032f4 <sys_waitall>:

uint64 sys_waitall(void)
{
    800032f4:	1101                	addi	sp,sp,-32
    800032f6:	ec06                	sd	ra,24(sp)
    800032f8:	e822                	sd	s0,16(sp)
    800032fa:	1000                	addi	s0,sp,32
  uint64 n_addr, statuses_addr;

  argaddr(0, &n_addr);
    800032fc:	fe840593          	addi	a1,s0,-24
    80003300:	4501                	li	a0,0
    80003302:	00000097          	auipc	ra,0x0
    80003306:	c5c080e7          	jalr	-932(ra) # 80002f5e <argaddr>
  argaddr(1, &statuses_addr);
    8000330a:	fe040593          	addi	a1,s0,-32
    8000330e:	4505                	li	a0,1
    80003310:	00000097          	auipc	ra,0x0
    80003314:	c4e080e7          	jalr	-946(ra) # 80002f5e <argaddr>

  if (n_addr == 0 || statuses_addr == 0)
    80003318:	fe843783          	ld	a5,-24(s0)
    return -1;
    8000331c:	557d                	li	a0,-1
  if (n_addr == 0 || statuses_addr == 0)
    8000331e:	cb89                	beqz	a5,80003330 <sys_waitall+0x3c>
    80003320:	fe043583          	ld	a1,-32(s0)
    80003324:	c591                	beqz	a1,80003330 <sys_waitall+0x3c>

  return waitall((int *)n_addr, (int *)statuses_addr);
    80003326:	853e                	mv	a0,a5
    80003328:	fffff097          	auipc	ra,0xfffff
    8000332c:	544080e7          	jalr	1348(ra) # 8000286c <waitall>
}
    80003330:	60e2                	ld	ra,24(sp)
    80003332:	6442                	ld	s0,16(sp)
    80003334:	6105                	addi	sp,sp,32
    80003336:	8082                	ret

0000000080003338 <sys_exit_num>:

uint64 sys_exit_num(void) {
    80003338:	1101                	addi	sp,sp,-32
    8000333a:	ec06                	sd	ra,24(sp)
    8000333c:	e822                	sd	s0,16(sp)
    8000333e:	1000                	addi	s0,sp,32
  int status;
  if(argint(0, &status) < 0)
    80003340:	fec40593          	addi	a1,s0,-20
    80003344:	4501                	li	a0,0
    80003346:	00000097          	auipc	ra,0x0
    8000334a:	bf6080e7          	jalr	-1034(ra) # 80002f3c <argint>
    return -1;
    8000334e:	57fd                	li	a5,-1
  if(argint(0, &status) < 0)
    80003350:	00054963          	bltz	a0,80003362 <sys_exit_num+0x2a>
  exit_num(status);
    80003354:	fec42503          	lw	a0,-20(s0)
    80003358:	fffff097          	auipc	ra,0xfffff
    8000335c:	f32080e7          	jalr	-206(ra) # 8000228a <exit_num>
  return 0; 
    80003360:	4781                	li	a5,0
}
    80003362:	853e                	mv	a0,a5
    80003364:	60e2                	ld	ra,24(sp)
    80003366:	6442                	ld	s0,16(sp)
    80003368:	6105                	addi	sp,sp,32
    8000336a:	8082                	ret

000000008000336c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000336c:	7179                	addi	sp,sp,-48
    8000336e:	f406                	sd	ra,40(sp)
    80003370:	f022                	sd	s0,32(sp)
    80003372:	ec26                	sd	s1,24(sp)
    80003374:	e84a                	sd	s2,16(sp)
    80003376:	e44e                	sd	s3,8(sp)
    80003378:	e052                	sd	s4,0(sp)
    8000337a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000337c:	00005597          	auipc	a1,0x5
    80003380:	39458593          	addi	a1,a1,916 # 80008710 <syscalls+0xe0>
    80003384:	00014517          	auipc	a0,0x14
    80003388:	00450513          	addi	a0,a0,4 # 80017388 <bcache>
    8000338c:	ffffd097          	auipc	ra,0xffffd
    80003390:	7ce080e7          	jalr	1998(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003394:	0001c797          	auipc	a5,0x1c
    80003398:	ff478793          	addi	a5,a5,-12 # 8001f388 <bcache+0x8000>
    8000339c:	0001c717          	auipc	a4,0x1c
    800033a0:	25470713          	addi	a4,a4,596 # 8001f5f0 <bcache+0x8268>
    800033a4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033a8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033ac:	00014497          	auipc	s1,0x14
    800033b0:	ff448493          	addi	s1,s1,-12 # 800173a0 <bcache+0x18>
    b->next = bcache.head.next;
    800033b4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800033b6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800033b8:	00005a17          	auipc	s4,0x5
    800033bc:	360a0a13          	addi	s4,s4,864 # 80008718 <syscalls+0xe8>
    b->next = bcache.head.next;
    800033c0:	2b893783          	ld	a5,696(s2)
    800033c4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033c6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033ca:	85d2                	mv	a1,s4
    800033cc:	01048513          	addi	a0,s1,16
    800033d0:	00001097          	auipc	ra,0x1
    800033d4:	4c4080e7          	jalr	1220(ra) # 80004894 <initsleeplock>
    bcache.head.next->prev = b;
    800033d8:	2b893783          	ld	a5,696(s2)
    800033dc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033de:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033e2:	45848493          	addi	s1,s1,1112
    800033e6:	fd349de3          	bne	s1,s3,800033c0 <binit+0x54>
  }
}
    800033ea:	70a2                	ld	ra,40(sp)
    800033ec:	7402                	ld	s0,32(sp)
    800033ee:	64e2                	ld	s1,24(sp)
    800033f0:	6942                	ld	s2,16(sp)
    800033f2:	69a2                	ld	s3,8(sp)
    800033f4:	6a02                	ld	s4,0(sp)
    800033f6:	6145                	addi	sp,sp,48
    800033f8:	8082                	ret

00000000800033fa <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033fa:	7179                	addi	sp,sp,-48
    800033fc:	f406                	sd	ra,40(sp)
    800033fe:	f022                	sd	s0,32(sp)
    80003400:	ec26                	sd	s1,24(sp)
    80003402:	e84a                	sd	s2,16(sp)
    80003404:	e44e                	sd	s3,8(sp)
    80003406:	1800                	addi	s0,sp,48
    80003408:	89aa                	mv	s3,a0
    8000340a:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000340c:	00014517          	auipc	a0,0x14
    80003410:	f7c50513          	addi	a0,a0,-132 # 80017388 <bcache>
    80003414:	ffffd097          	auipc	ra,0xffffd
    80003418:	7d6080e7          	jalr	2006(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000341c:	0001c497          	auipc	s1,0x1c
    80003420:	2244b483          	ld	s1,548(s1) # 8001f640 <bcache+0x82b8>
    80003424:	0001c797          	auipc	a5,0x1c
    80003428:	1cc78793          	addi	a5,a5,460 # 8001f5f0 <bcache+0x8268>
    8000342c:	02f48f63          	beq	s1,a5,8000346a <bread+0x70>
    80003430:	873e                	mv	a4,a5
    80003432:	a021                	j	8000343a <bread+0x40>
    80003434:	68a4                	ld	s1,80(s1)
    80003436:	02e48a63          	beq	s1,a4,8000346a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000343a:	449c                	lw	a5,8(s1)
    8000343c:	ff379ce3          	bne	a5,s3,80003434 <bread+0x3a>
    80003440:	44dc                	lw	a5,12(s1)
    80003442:	ff2799e3          	bne	a5,s2,80003434 <bread+0x3a>
      b->refcnt++;
    80003446:	40bc                	lw	a5,64(s1)
    80003448:	2785                	addiw	a5,a5,1
    8000344a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000344c:	00014517          	auipc	a0,0x14
    80003450:	f3c50513          	addi	a0,a0,-196 # 80017388 <bcache>
    80003454:	ffffe097          	auipc	ra,0xffffe
    80003458:	84a080e7          	jalr	-1974(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    8000345c:	01048513          	addi	a0,s1,16
    80003460:	00001097          	auipc	ra,0x1
    80003464:	46e080e7          	jalr	1134(ra) # 800048ce <acquiresleep>
      return b;
    80003468:	a8b9                	j	800034c6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000346a:	0001c497          	auipc	s1,0x1c
    8000346e:	1ce4b483          	ld	s1,462(s1) # 8001f638 <bcache+0x82b0>
    80003472:	0001c797          	auipc	a5,0x1c
    80003476:	17e78793          	addi	a5,a5,382 # 8001f5f0 <bcache+0x8268>
    8000347a:	00f48863          	beq	s1,a5,8000348a <bread+0x90>
    8000347e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003480:	40bc                	lw	a5,64(s1)
    80003482:	cf81                	beqz	a5,8000349a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003484:	64a4                	ld	s1,72(s1)
    80003486:	fee49de3          	bne	s1,a4,80003480 <bread+0x86>
  panic("bget: no buffers");
    8000348a:	00005517          	auipc	a0,0x5
    8000348e:	29650513          	addi	a0,a0,662 # 80008720 <syscalls+0xf0>
    80003492:	ffffd097          	auipc	ra,0xffffd
    80003496:	0b2080e7          	jalr	178(ra) # 80000544 <panic>
      b->dev = dev;
    8000349a:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000349e:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800034a2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034a6:	4785                	li	a5,1
    800034a8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034aa:	00014517          	auipc	a0,0x14
    800034ae:	ede50513          	addi	a0,a0,-290 # 80017388 <bcache>
    800034b2:	ffffd097          	auipc	ra,0xffffd
    800034b6:	7ec080e7          	jalr	2028(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800034ba:	01048513          	addi	a0,s1,16
    800034be:	00001097          	auipc	ra,0x1
    800034c2:	410080e7          	jalr	1040(ra) # 800048ce <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034c6:	409c                	lw	a5,0(s1)
    800034c8:	cb89                	beqz	a5,800034da <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034ca:	8526                	mv	a0,s1
    800034cc:	70a2                	ld	ra,40(sp)
    800034ce:	7402                	ld	s0,32(sp)
    800034d0:	64e2                	ld	s1,24(sp)
    800034d2:	6942                	ld	s2,16(sp)
    800034d4:	69a2                	ld	s3,8(sp)
    800034d6:	6145                	addi	sp,sp,48
    800034d8:	8082                	ret
    virtio_disk_rw(b, 0);
    800034da:	4581                	li	a1,0
    800034dc:	8526                	mv	a0,s1
    800034de:	00003097          	auipc	ra,0x3
    800034e2:	fca080e7          	jalr	-54(ra) # 800064a8 <virtio_disk_rw>
    b->valid = 1;
    800034e6:	4785                	li	a5,1
    800034e8:	c09c                	sw	a5,0(s1)
  return b;
    800034ea:	b7c5                	j	800034ca <bread+0xd0>

00000000800034ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034ec:	1101                	addi	sp,sp,-32
    800034ee:	ec06                	sd	ra,24(sp)
    800034f0:	e822                	sd	s0,16(sp)
    800034f2:	e426                	sd	s1,8(sp)
    800034f4:	1000                	addi	s0,sp,32
    800034f6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034f8:	0541                	addi	a0,a0,16
    800034fa:	00001097          	auipc	ra,0x1
    800034fe:	46e080e7          	jalr	1134(ra) # 80004968 <holdingsleep>
    80003502:	cd01                	beqz	a0,8000351a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003504:	4585                	li	a1,1
    80003506:	8526                	mv	a0,s1
    80003508:	00003097          	auipc	ra,0x3
    8000350c:	fa0080e7          	jalr	-96(ra) # 800064a8 <virtio_disk_rw>
}
    80003510:	60e2                	ld	ra,24(sp)
    80003512:	6442                	ld	s0,16(sp)
    80003514:	64a2                	ld	s1,8(sp)
    80003516:	6105                	addi	sp,sp,32
    80003518:	8082                	ret
    panic("bwrite");
    8000351a:	00005517          	auipc	a0,0x5
    8000351e:	21e50513          	addi	a0,a0,542 # 80008738 <syscalls+0x108>
    80003522:	ffffd097          	auipc	ra,0xffffd
    80003526:	022080e7          	jalr	34(ra) # 80000544 <panic>

000000008000352a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000352a:	1101                	addi	sp,sp,-32
    8000352c:	ec06                	sd	ra,24(sp)
    8000352e:	e822                	sd	s0,16(sp)
    80003530:	e426                	sd	s1,8(sp)
    80003532:	e04a                	sd	s2,0(sp)
    80003534:	1000                	addi	s0,sp,32
    80003536:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003538:	01050913          	addi	s2,a0,16
    8000353c:	854a                	mv	a0,s2
    8000353e:	00001097          	auipc	ra,0x1
    80003542:	42a080e7          	jalr	1066(ra) # 80004968 <holdingsleep>
    80003546:	c92d                	beqz	a0,800035b8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003548:	854a                	mv	a0,s2
    8000354a:	00001097          	auipc	ra,0x1
    8000354e:	3da080e7          	jalr	986(ra) # 80004924 <releasesleep>

  acquire(&bcache.lock);
    80003552:	00014517          	auipc	a0,0x14
    80003556:	e3650513          	addi	a0,a0,-458 # 80017388 <bcache>
    8000355a:	ffffd097          	auipc	ra,0xffffd
    8000355e:	690080e7          	jalr	1680(ra) # 80000bea <acquire>
  b->refcnt--;
    80003562:	40bc                	lw	a5,64(s1)
    80003564:	37fd                	addiw	a5,a5,-1
    80003566:	0007871b          	sext.w	a4,a5
    8000356a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000356c:	eb05                	bnez	a4,8000359c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000356e:	68bc                	ld	a5,80(s1)
    80003570:	64b8                	ld	a4,72(s1)
    80003572:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003574:	64bc                	ld	a5,72(s1)
    80003576:	68b8                	ld	a4,80(s1)
    80003578:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000357a:	0001c797          	auipc	a5,0x1c
    8000357e:	e0e78793          	addi	a5,a5,-498 # 8001f388 <bcache+0x8000>
    80003582:	2b87b703          	ld	a4,696(a5)
    80003586:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003588:	0001c717          	auipc	a4,0x1c
    8000358c:	06870713          	addi	a4,a4,104 # 8001f5f0 <bcache+0x8268>
    80003590:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003592:	2b87b703          	ld	a4,696(a5)
    80003596:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003598:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000359c:	00014517          	auipc	a0,0x14
    800035a0:	dec50513          	addi	a0,a0,-532 # 80017388 <bcache>
    800035a4:	ffffd097          	auipc	ra,0xffffd
    800035a8:	6fa080e7          	jalr	1786(ra) # 80000c9e <release>
}
    800035ac:	60e2                	ld	ra,24(sp)
    800035ae:	6442                	ld	s0,16(sp)
    800035b0:	64a2                	ld	s1,8(sp)
    800035b2:	6902                	ld	s2,0(sp)
    800035b4:	6105                	addi	sp,sp,32
    800035b6:	8082                	ret
    panic("brelse");
    800035b8:	00005517          	auipc	a0,0x5
    800035bc:	18850513          	addi	a0,a0,392 # 80008740 <syscalls+0x110>
    800035c0:	ffffd097          	auipc	ra,0xffffd
    800035c4:	f84080e7          	jalr	-124(ra) # 80000544 <panic>

00000000800035c8 <bpin>:

void
bpin(struct buf *b) {
    800035c8:	1101                	addi	sp,sp,-32
    800035ca:	ec06                	sd	ra,24(sp)
    800035cc:	e822                	sd	s0,16(sp)
    800035ce:	e426                	sd	s1,8(sp)
    800035d0:	1000                	addi	s0,sp,32
    800035d2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035d4:	00014517          	auipc	a0,0x14
    800035d8:	db450513          	addi	a0,a0,-588 # 80017388 <bcache>
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	60e080e7          	jalr	1550(ra) # 80000bea <acquire>
  b->refcnt++;
    800035e4:	40bc                	lw	a5,64(s1)
    800035e6:	2785                	addiw	a5,a5,1
    800035e8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035ea:	00014517          	auipc	a0,0x14
    800035ee:	d9e50513          	addi	a0,a0,-610 # 80017388 <bcache>
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	6ac080e7          	jalr	1708(ra) # 80000c9e <release>
}
    800035fa:	60e2                	ld	ra,24(sp)
    800035fc:	6442                	ld	s0,16(sp)
    800035fe:	64a2                	ld	s1,8(sp)
    80003600:	6105                	addi	sp,sp,32
    80003602:	8082                	ret

0000000080003604 <bunpin>:

void
bunpin(struct buf *b) {
    80003604:	1101                	addi	sp,sp,-32
    80003606:	ec06                	sd	ra,24(sp)
    80003608:	e822                	sd	s0,16(sp)
    8000360a:	e426                	sd	s1,8(sp)
    8000360c:	1000                	addi	s0,sp,32
    8000360e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003610:	00014517          	auipc	a0,0x14
    80003614:	d7850513          	addi	a0,a0,-648 # 80017388 <bcache>
    80003618:	ffffd097          	auipc	ra,0xffffd
    8000361c:	5d2080e7          	jalr	1490(ra) # 80000bea <acquire>
  b->refcnt--;
    80003620:	40bc                	lw	a5,64(s1)
    80003622:	37fd                	addiw	a5,a5,-1
    80003624:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003626:	00014517          	auipc	a0,0x14
    8000362a:	d6250513          	addi	a0,a0,-670 # 80017388 <bcache>
    8000362e:	ffffd097          	auipc	ra,0xffffd
    80003632:	670080e7          	jalr	1648(ra) # 80000c9e <release>
}
    80003636:	60e2                	ld	ra,24(sp)
    80003638:	6442                	ld	s0,16(sp)
    8000363a:	64a2                	ld	s1,8(sp)
    8000363c:	6105                	addi	sp,sp,32
    8000363e:	8082                	ret

0000000080003640 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003640:	1101                	addi	sp,sp,-32
    80003642:	ec06                	sd	ra,24(sp)
    80003644:	e822                	sd	s0,16(sp)
    80003646:	e426                	sd	s1,8(sp)
    80003648:	e04a                	sd	s2,0(sp)
    8000364a:	1000                	addi	s0,sp,32
    8000364c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000364e:	00d5d59b          	srliw	a1,a1,0xd
    80003652:	0001c797          	auipc	a5,0x1c
    80003656:	4127a783          	lw	a5,1042(a5) # 8001fa64 <sb+0x1c>
    8000365a:	9dbd                	addw	a1,a1,a5
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	d9e080e7          	jalr	-610(ra) # 800033fa <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003664:	0074f713          	andi	a4,s1,7
    80003668:	4785                	li	a5,1
    8000366a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000366e:	14ce                	slli	s1,s1,0x33
    80003670:	90d9                	srli	s1,s1,0x36
    80003672:	00950733          	add	a4,a0,s1
    80003676:	05874703          	lbu	a4,88(a4)
    8000367a:	00e7f6b3          	and	a3,a5,a4
    8000367e:	c69d                	beqz	a3,800036ac <bfree+0x6c>
    80003680:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003682:	94aa                	add	s1,s1,a0
    80003684:	fff7c793          	not	a5,a5
    80003688:	8ff9                	and	a5,a5,a4
    8000368a:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000368e:	00001097          	auipc	ra,0x1
    80003692:	120080e7          	jalr	288(ra) # 800047ae <log_write>
  brelse(bp);
    80003696:	854a                	mv	a0,s2
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	e92080e7          	jalr	-366(ra) # 8000352a <brelse>
}
    800036a0:	60e2                	ld	ra,24(sp)
    800036a2:	6442                	ld	s0,16(sp)
    800036a4:	64a2                	ld	s1,8(sp)
    800036a6:	6902                	ld	s2,0(sp)
    800036a8:	6105                	addi	sp,sp,32
    800036aa:	8082                	ret
    panic("freeing free block");
    800036ac:	00005517          	auipc	a0,0x5
    800036b0:	09c50513          	addi	a0,a0,156 # 80008748 <syscalls+0x118>
    800036b4:	ffffd097          	auipc	ra,0xffffd
    800036b8:	e90080e7          	jalr	-368(ra) # 80000544 <panic>

00000000800036bc <balloc>:
{
    800036bc:	711d                	addi	sp,sp,-96
    800036be:	ec86                	sd	ra,88(sp)
    800036c0:	e8a2                	sd	s0,80(sp)
    800036c2:	e4a6                	sd	s1,72(sp)
    800036c4:	e0ca                	sd	s2,64(sp)
    800036c6:	fc4e                	sd	s3,56(sp)
    800036c8:	f852                	sd	s4,48(sp)
    800036ca:	f456                	sd	s5,40(sp)
    800036cc:	f05a                	sd	s6,32(sp)
    800036ce:	ec5e                	sd	s7,24(sp)
    800036d0:	e862                	sd	s8,16(sp)
    800036d2:	e466                	sd	s9,8(sp)
    800036d4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036d6:	0001c797          	auipc	a5,0x1c
    800036da:	3767a783          	lw	a5,886(a5) # 8001fa4c <sb+0x4>
    800036de:	10078163          	beqz	a5,800037e0 <balloc+0x124>
    800036e2:	8baa                	mv	s7,a0
    800036e4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036e6:	0001cb17          	auipc	s6,0x1c
    800036ea:	362b0b13          	addi	s6,s6,866 # 8001fa48 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036ee:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036f0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036f2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036f4:	6c89                	lui	s9,0x2
    800036f6:	a061                	j	8000377e <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036f8:	974a                	add	a4,a4,s2
    800036fa:	8fd5                	or	a5,a5,a3
    800036fc:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003700:	854a                	mv	a0,s2
    80003702:	00001097          	auipc	ra,0x1
    80003706:	0ac080e7          	jalr	172(ra) # 800047ae <log_write>
        brelse(bp);
    8000370a:	854a                	mv	a0,s2
    8000370c:	00000097          	auipc	ra,0x0
    80003710:	e1e080e7          	jalr	-482(ra) # 8000352a <brelse>
  bp = bread(dev, bno);
    80003714:	85a6                	mv	a1,s1
    80003716:	855e                	mv	a0,s7
    80003718:	00000097          	auipc	ra,0x0
    8000371c:	ce2080e7          	jalr	-798(ra) # 800033fa <bread>
    80003720:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003722:	40000613          	li	a2,1024
    80003726:	4581                	li	a1,0
    80003728:	05850513          	addi	a0,a0,88
    8000372c:	ffffd097          	auipc	ra,0xffffd
    80003730:	5ba080e7          	jalr	1466(ra) # 80000ce6 <memset>
  log_write(bp);
    80003734:	854a                	mv	a0,s2
    80003736:	00001097          	auipc	ra,0x1
    8000373a:	078080e7          	jalr	120(ra) # 800047ae <log_write>
  brelse(bp);
    8000373e:	854a                	mv	a0,s2
    80003740:	00000097          	auipc	ra,0x0
    80003744:	dea080e7          	jalr	-534(ra) # 8000352a <brelse>
}
    80003748:	8526                	mv	a0,s1
    8000374a:	60e6                	ld	ra,88(sp)
    8000374c:	6446                	ld	s0,80(sp)
    8000374e:	64a6                	ld	s1,72(sp)
    80003750:	6906                	ld	s2,64(sp)
    80003752:	79e2                	ld	s3,56(sp)
    80003754:	7a42                	ld	s4,48(sp)
    80003756:	7aa2                	ld	s5,40(sp)
    80003758:	7b02                	ld	s6,32(sp)
    8000375a:	6be2                	ld	s7,24(sp)
    8000375c:	6c42                	ld	s8,16(sp)
    8000375e:	6ca2                	ld	s9,8(sp)
    80003760:	6125                	addi	sp,sp,96
    80003762:	8082                	ret
    brelse(bp);
    80003764:	854a                	mv	a0,s2
    80003766:	00000097          	auipc	ra,0x0
    8000376a:	dc4080e7          	jalr	-572(ra) # 8000352a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000376e:	015c87bb          	addw	a5,s9,s5
    80003772:	00078a9b          	sext.w	s5,a5
    80003776:	004b2703          	lw	a4,4(s6)
    8000377a:	06eaf363          	bgeu	s5,a4,800037e0 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000377e:	41fad79b          	sraiw	a5,s5,0x1f
    80003782:	0137d79b          	srliw	a5,a5,0x13
    80003786:	015787bb          	addw	a5,a5,s5
    8000378a:	40d7d79b          	sraiw	a5,a5,0xd
    8000378e:	01cb2583          	lw	a1,28(s6)
    80003792:	9dbd                	addw	a1,a1,a5
    80003794:	855e                	mv	a0,s7
    80003796:	00000097          	auipc	ra,0x0
    8000379a:	c64080e7          	jalr	-924(ra) # 800033fa <bread>
    8000379e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037a0:	004b2503          	lw	a0,4(s6)
    800037a4:	000a849b          	sext.w	s1,s5
    800037a8:	8662                	mv	a2,s8
    800037aa:	faa4fde3          	bgeu	s1,a0,80003764 <balloc+0xa8>
      m = 1 << (bi % 8);
    800037ae:	41f6579b          	sraiw	a5,a2,0x1f
    800037b2:	01d7d69b          	srliw	a3,a5,0x1d
    800037b6:	00c6873b          	addw	a4,a3,a2
    800037ba:	00777793          	andi	a5,a4,7
    800037be:	9f95                	subw	a5,a5,a3
    800037c0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037c4:	4037571b          	sraiw	a4,a4,0x3
    800037c8:	00e906b3          	add	a3,s2,a4
    800037cc:	0586c683          	lbu	a3,88(a3)
    800037d0:	00d7f5b3          	and	a1,a5,a3
    800037d4:	d195                	beqz	a1,800036f8 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037d6:	2605                	addiw	a2,a2,1
    800037d8:	2485                	addiw	s1,s1,1
    800037da:	fd4618e3          	bne	a2,s4,800037aa <balloc+0xee>
    800037de:	b759                	j	80003764 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800037e0:	00005517          	auipc	a0,0x5
    800037e4:	f8050513          	addi	a0,a0,-128 # 80008760 <syscalls+0x130>
    800037e8:	ffffd097          	auipc	ra,0xffffd
    800037ec:	da6080e7          	jalr	-602(ra) # 8000058e <printf>
  return 0;
    800037f0:	4481                	li	s1,0
    800037f2:	bf99                	j	80003748 <balloc+0x8c>

00000000800037f4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037f4:	7179                	addi	sp,sp,-48
    800037f6:	f406                	sd	ra,40(sp)
    800037f8:	f022                	sd	s0,32(sp)
    800037fa:	ec26                	sd	s1,24(sp)
    800037fc:	e84a                	sd	s2,16(sp)
    800037fe:	e44e                	sd	s3,8(sp)
    80003800:	e052                	sd	s4,0(sp)
    80003802:	1800                	addi	s0,sp,48
    80003804:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003806:	47ad                	li	a5,11
    80003808:	02b7e763          	bltu	a5,a1,80003836 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000380c:	02059493          	slli	s1,a1,0x20
    80003810:	9081                	srli	s1,s1,0x20
    80003812:	048a                	slli	s1,s1,0x2
    80003814:	94aa                	add	s1,s1,a0
    80003816:	0504a903          	lw	s2,80(s1)
    8000381a:	06091e63          	bnez	s2,80003896 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000381e:	4108                	lw	a0,0(a0)
    80003820:	00000097          	auipc	ra,0x0
    80003824:	e9c080e7          	jalr	-356(ra) # 800036bc <balloc>
    80003828:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000382c:	06090563          	beqz	s2,80003896 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003830:	0524a823          	sw	s2,80(s1)
    80003834:	a08d                	j	80003896 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003836:	ff45849b          	addiw	s1,a1,-12
    8000383a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000383e:	0ff00793          	li	a5,255
    80003842:	08e7e563          	bltu	a5,a4,800038cc <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003846:	08052903          	lw	s2,128(a0)
    8000384a:	00091d63          	bnez	s2,80003864 <bmap+0x70>
      addr = balloc(ip->dev);
    8000384e:	4108                	lw	a0,0(a0)
    80003850:	00000097          	auipc	ra,0x0
    80003854:	e6c080e7          	jalr	-404(ra) # 800036bc <balloc>
    80003858:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000385c:	02090d63          	beqz	s2,80003896 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003860:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003864:	85ca                	mv	a1,s2
    80003866:	0009a503          	lw	a0,0(s3)
    8000386a:	00000097          	auipc	ra,0x0
    8000386e:	b90080e7          	jalr	-1136(ra) # 800033fa <bread>
    80003872:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003874:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003878:	02049593          	slli	a1,s1,0x20
    8000387c:	9181                	srli	a1,a1,0x20
    8000387e:	058a                	slli	a1,a1,0x2
    80003880:	00b784b3          	add	s1,a5,a1
    80003884:	0004a903          	lw	s2,0(s1)
    80003888:	02090063          	beqz	s2,800038a8 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000388c:	8552                	mv	a0,s4
    8000388e:	00000097          	auipc	ra,0x0
    80003892:	c9c080e7          	jalr	-868(ra) # 8000352a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003896:	854a                	mv	a0,s2
    80003898:	70a2                	ld	ra,40(sp)
    8000389a:	7402                	ld	s0,32(sp)
    8000389c:	64e2                	ld	s1,24(sp)
    8000389e:	6942                	ld	s2,16(sp)
    800038a0:	69a2                	ld	s3,8(sp)
    800038a2:	6a02                	ld	s4,0(sp)
    800038a4:	6145                	addi	sp,sp,48
    800038a6:	8082                	ret
      addr = balloc(ip->dev);
    800038a8:	0009a503          	lw	a0,0(s3)
    800038ac:	00000097          	auipc	ra,0x0
    800038b0:	e10080e7          	jalr	-496(ra) # 800036bc <balloc>
    800038b4:	0005091b          	sext.w	s2,a0
      if(addr){
    800038b8:	fc090ae3          	beqz	s2,8000388c <bmap+0x98>
        a[bn] = addr;
    800038bc:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800038c0:	8552                	mv	a0,s4
    800038c2:	00001097          	auipc	ra,0x1
    800038c6:	eec080e7          	jalr	-276(ra) # 800047ae <log_write>
    800038ca:	b7c9                	j	8000388c <bmap+0x98>
  panic("bmap: out of range");
    800038cc:	00005517          	auipc	a0,0x5
    800038d0:	eac50513          	addi	a0,a0,-340 # 80008778 <syscalls+0x148>
    800038d4:	ffffd097          	auipc	ra,0xffffd
    800038d8:	c70080e7          	jalr	-912(ra) # 80000544 <panic>

00000000800038dc <iget>:
{
    800038dc:	7179                	addi	sp,sp,-48
    800038de:	f406                	sd	ra,40(sp)
    800038e0:	f022                	sd	s0,32(sp)
    800038e2:	ec26                	sd	s1,24(sp)
    800038e4:	e84a                	sd	s2,16(sp)
    800038e6:	e44e                	sd	s3,8(sp)
    800038e8:	e052                	sd	s4,0(sp)
    800038ea:	1800                	addi	s0,sp,48
    800038ec:	89aa                	mv	s3,a0
    800038ee:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038f0:	0001c517          	auipc	a0,0x1c
    800038f4:	17850513          	addi	a0,a0,376 # 8001fa68 <itable>
    800038f8:	ffffd097          	auipc	ra,0xffffd
    800038fc:	2f2080e7          	jalr	754(ra) # 80000bea <acquire>
  empty = 0;
    80003900:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003902:	0001c497          	auipc	s1,0x1c
    80003906:	17e48493          	addi	s1,s1,382 # 8001fa80 <itable+0x18>
    8000390a:	0001e697          	auipc	a3,0x1e
    8000390e:	c0668693          	addi	a3,a3,-1018 # 80021510 <log>
    80003912:	a039                	j	80003920 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003914:	02090b63          	beqz	s2,8000394a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003918:	08848493          	addi	s1,s1,136
    8000391c:	02d48a63          	beq	s1,a3,80003950 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003920:	449c                	lw	a5,8(s1)
    80003922:	fef059e3          	blez	a5,80003914 <iget+0x38>
    80003926:	4098                	lw	a4,0(s1)
    80003928:	ff3716e3          	bne	a4,s3,80003914 <iget+0x38>
    8000392c:	40d8                	lw	a4,4(s1)
    8000392e:	ff4713e3          	bne	a4,s4,80003914 <iget+0x38>
      ip->ref++;
    80003932:	2785                	addiw	a5,a5,1
    80003934:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003936:	0001c517          	auipc	a0,0x1c
    8000393a:	13250513          	addi	a0,a0,306 # 8001fa68 <itable>
    8000393e:	ffffd097          	auipc	ra,0xffffd
    80003942:	360080e7          	jalr	864(ra) # 80000c9e <release>
      return ip;
    80003946:	8926                	mv	s2,s1
    80003948:	a03d                	j	80003976 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000394a:	f7f9                	bnez	a5,80003918 <iget+0x3c>
    8000394c:	8926                	mv	s2,s1
    8000394e:	b7e9                	j	80003918 <iget+0x3c>
  if(empty == 0)
    80003950:	02090c63          	beqz	s2,80003988 <iget+0xac>
  ip->dev = dev;
    80003954:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003958:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000395c:	4785                	li	a5,1
    8000395e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003962:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003966:	0001c517          	auipc	a0,0x1c
    8000396a:	10250513          	addi	a0,a0,258 # 8001fa68 <itable>
    8000396e:	ffffd097          	auipc	ra,0xffffd
    80003972:	330080e7          	jalr	816(ra) # 80000c9e <release>
}
    80003976:	854a                	mv	a0,s2
    80003978:	70a2                	ld	ra,40(sp)
    8000397a:	7402                	ld	s0,32(sp)
    8000397c:	64e2                	ld	s1,24(sp)
    8000397e:	6942                	ld	s2,16(sp)
    80003980:	69a2                	ld	s3,8(sp)
    80003982:	6a02                	ld	s4,0(sp)
    80003984:	6145                	addi	sp,sp,48
    80003986:	8082                	ret
    panic("iget: no inodes");
    80003988:	00005517          	auipc	a0,0x5
    8000398c:	e0850513          	addi	a0,a0,-504 # 80008790 <syscalls+0x160>
    80003990:	ffffd097          	auipc	ra,0xffffd
    80003994:	bb4080e7          	jalr	-1100(ra) # 80000544 <panic>

0000000080003998 <fsinit>:
fsinit(int dev) {
    80003998:	7179                	addi	sp,sp,-48
    8000399a:	f406                	sd	ra,40(sp)
    8000399c:	f022                	sd	s0,32(sp)
    8000399e:	ec26                	sd	s1,24(sp)
    800039a0:	e84a                	sd	s2,16(sp)
    800039a2:	e44e                	sd	s3,8(sp)
    800039a4:	1800                	addi	s0,sp,48
    800039a6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039a8:	4585                	li	a1,1
    800039aa:	00000097          	auipc	ra,0x0
    800039ae:	a50080e7          	jalr	-1456(ra) # 800033fa <bread>
    800039b2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039b4:	0001c997          	auipc	s3,0x1c
    800039b8:	09498993          	addi	s3,s3,148 # 8001fa48 <sb>
    800039bc:	02000613          	li	a2,32
    800039c0:	05850593          	addi	a1,a0,88
    800039c4:	854e                	mv	a0,s3
    800039c6:	ffffd097          	auipc	ra,0xffffd
    800039ca:	380080e7          	jalr	896(ra) # 80000d46 <memmove>
  brelse(bp);
    800039ce:	8526                	mv	a0,s1
    800039d0:	00000097          	auipc	ra,0x0
    800039d4:	b5a080e7          	jalr	-1190(ra) # 8000352a <brelse>
  if(sb.magic != FSMAGIC)
    800039d8:	0009a703          	lw	a4,0(s3)
    800039dc:	102037b7          	lui	a5,0x10203
    800039e0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039e4:	02f71263          	bne	a4,a5,80003a08 <fsinit+0x70>
  initlog(dev, &sb);
    800039e8:	0001c597          	auipc	a1,0x1c
    800039ec:	06058593          	addi	a1,a1,96 # 8001fa48 <sb>
    800039f0:	854a                	mv	a0,s2
    800039f2:	00001097          	auipc	ra,0x1
    800039f6:	b40080e7          	jalr	-1216(ra) # 80004532 <initlog>
}
    800039fa:	70a2                	ld	ra,40(sp)
    800039fc:	7402                	ld	s0,32(sp)
    800039fe:	64e2                	ld	s1,24(sp)
    80003a00:	6942                	ld	s2,16(sp)
    80003a02:	69a2                	ld	s3,8(sp)
    80003a04:	6145                	addi	sp,sp,48
    80003a06:	8082                	ret
    panic("invalid file system");
    80003a08:	00005517          	auipc	a0,0x5
    80003a0c:	d9850513          	addi	a0,a0,-616 # 800087a0 <syscalls+0x170>
    80003a10:	ffffd097          	auipc	ra,0xffffd
    80003a14:	b34080e7          	jalr	-1228(ra) # 80000544 <panic>

0000000080003a18 <iinit>:
{
    80003a18:	7179                	addi	sp,sp,-48
    80003a1a:	f406                	sd	ra,40(sp)
    80003a1c:	f022                	sd	s0,32(sp)
    80003a1e:	ec26                	sd	s1,24(sp)
    80003a20:	e84a                	sd	s2,16(sp)
    80003a22:	e44e                	sd	s3,8(sp)
    80003a24:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a26:	00005597          	auipc	a1,0x5
    80003a2a:	d9258593          	addi	a1,a1,-622 # 800087b8 <syscalls+0x188>
    80003a2e:	0001c517          	auipc	a0,0x1c
    80003a32:	03a50513          	addi	a0,a0,58 # 8001fa68 <itable>
    80003a36:	ffffd097          	auipc	ra,0xffffd
    80003a3a:	124080e7          	jalr	292(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a3e:	0001c497          	auipc	s1,0x1c
    80003a42:	05248493          	addi	s1,s1,82 # 8001fa90 <itable+0x28>
    80003a46:	0001e997          	auipc	s3,0x1e
    80003a4a:	ada98993          	addi	s3,s3,-1318 # 80021520 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a4e:	00005917          	auipc	s2,0x5
    80003a52:	d7290913          	addi	s2,s2,-654 # 800087c0 <syscalls+0x190>
    80003a56:	85ca                	mv	a1,s2
    80003a58:	8526                	mv	a0,s1
    80003a5a:	00001097          	auipc	ra,0x1
    80003a5e:	e3a080e7          	jalr	-454(ra) # 80004894 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a62:	08848493          	addi	s1,s1,136
    80003a66:	ff3498e3          	bne	s1,s3,80003a56 <iinit+0x3e>
}
    80003a6a:	70a2                	ld	ra,40(sp)
    80003a6c:	7402                	ld	s0,32(sp)
    80003a6e:	64e2                	ld	s1,24(sp)
    80003a70:	6942                	ld	s2,16(sp)
    80003a72:	69a2                	ld	s3,8(sp)
    80003a74:	6145                	addi	sp,sp,48
    80003a76:	8082                	ret

0000000080003a78 <ialloc>:
{
    80003a78:	715d                	addi	sp,sp,-80
    80003a7a:	e486                	sd	ra,72(sp)
    80003a7c:	e0a2                	sd	s0,64(sp)
    80003a7e:	fc26                	sd	s1,56(sp)
    80003a80:	f84a                	sd	s2,48(sp)
    80003a82:	f44e                	sd	s3,40(sp)
    80003a84:	f052                	sd	s4,32(sp)
    80003a86:	ec56                	sd	s5,24(sp)
    80003a88:	e85a                	sd	s6,16(sp)
    80003a8a:	e45e                	sd	s7,8(sp)
    80003a8c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a8e:	0001c717          	auipc	a4,0x1c
    80003a92:	fc672703          	lw	a4,-58(a4) # 8001fa54 <sb+0xc>
    80003a96:	4785                	li	a5,1
    80003a98:	04e7fa63          	bgeu	a5,a4,80003aec <ialloc+0x74>
    80003a9c:	8aaa                	mv	s5,a0
    80003a9e:	8bae                	mv	s7,a1
    80003aa0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003aa2:	0001ca17          	auipc	s4,0x1c
    80003aa6:	fa6a0a13          	addi	s4,s4,-90 # 8001fa48 <sb>
    80003aaa:	00048b1b          	sext.w	s6,s1
    80003aae:	0044d593          	srli	a1,s1,0x4
    80003ab2:	018a2783          	lw	a5,24(s4)
    80003ab6:	9dbd                	addw	a1,a1,a5
    80003ab8:	8556                	mv	a0,s5
    80003aba:	00000097          	auipc	ra,0x0
    80003abe:	940080e7          	jalr	-1728(ra) # 800033fa <bread>
    80003ac2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ac4:	05850993          	addi	s3,a0,88
    80003ac8:	00f4f793          	andi	a5,s1,15
    80003acc:	079a                	slli	a5,a5,0x6
    80003ace:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003ad0:	00099783          	lh	a5,0(s3)
    80003ad4:	c3a1                	beqz	a5,80003b14 <ialloc+0x9c>
    brelse(bp);
    80003ad6:	00000097          	auipc	ra,0x0
    80003ada:	a54080e7          	jalr	-1452(ra) # 8000352a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ade:	0485                	addi	s1,s1,1
    80003ae0:	00ca2703          	lw	a4,12(s4)
    80003ae4:	0004879b          	sext.w	a5,s1
    80003ae8:	fce7e1e3          	bltu	a5,a4,80003aaa <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003aec:	00005517          	auipc	a0,0x5
    80003af0:	cdc50513          	addi	a0,a0,-804 # 800087c8 <syscalls+0x198>
    80003af4:	ffffd097          	auipc	ra,0xffffd
    80003af8:	a9a080e7          	jalr	-1382(ra) # 8000058e <printf>
  return 0;
    80003afc:	4501                	li	a0,0
}
    80003afe:	60a6                	ld	ra,72(sp)
    80003b00:	6406                	ld	s0,64(sp)
    80003b02:	74e2                	ld	s1,56(sp)
    80003b04:	7942                	ld	s2,48(sp)
    80003b06:	79a2                	ld	s3,40(sp)
    80003b08:	7a02                	ld	s4,32(sp)
    80003b0a:	6ae2                	ld	s5,24(sp)
    80003b0c:	6b42                	ld	s6,16(sp)
    80003b0e:	6ba2                	ld	s7,8(sp)
    80003b10:	6161                	addi	sp,sp,80
    80003b12:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b14:	04000613          	li	a2,64
    80003b18:	4581                	li	a1,0
    80003b1a:	854e                	mv	a0,s3
    80003b1c:	ffffd097          	auipc	ra,0xffffd
    80003b20:	1ca080e7          	jalr	458(ra) # 80000ce6 <memset>
      dip->type = type;
    80003b24:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b28:	854a                	mv	a0,s2
    80003b2a:	00001097          	auipc	ra,0x1
    80003b2e:	c84080e7          	jalr	-892(ra) # 800047ae <log_write>
      brelse(bp);
    80003b32:	854a                	mv	a0,s2
    80003b34:	00000097          	auipc	ra,0x0
    80003b38:	9f6080e7          	jalr	-1546(ra) # 8000352a <brelse>
      return iget(dev, inum);
    80003b3c:	85da                	mv	a1,s6
    80003b3e:	8556                	mv	a0,s5
    80003b40:	00000097          	auipc	ra,0x0
    80003b44:	d9c080e7          	jalr	-612(ra) # 800038dc <iget>
    80003b48:	bf5d                	j	80003afe <ialloc+0x86>

0000000080003b4a <iupdate>:
{
    80003b4a:	1101                	addi	sp,sp,-32
    80003b4c:	ec06                	sd	ra,24(sp)
    80003b4e:	e822                	sd	s0,16(sp)
    80003b50:	e426                	sd	s1,8(sp)
    80003b52:	e04a                	sd	s2,0(sp)
    80003b54:	1000                	addi	s0,sp,32
    80003b56:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b58:	415c                	lw	a5,4(a0)
    80003b5a:	0047d79b          	srliw	a5,a5,0x4
    80003b5e:	0001c597          	auipc	a1,0x1c
    80003b62:	f025a583          	lw	a1,-254(a1) # 8001fa60 <sb+0x18>
    80003b66:	9dbd                	addw	a1,a1,a5
    80003b68:	4108                	lw	a0,0(a0)
    80003b6a:	00000097          	auipc	ra,0x0
    80003b6e:	890080e7          	jalr	-1904(ra) # 800033fa <bread>
    80003b72:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b74:	05850793          	addi	a5,a0,88
    80003b78:	40c8                	lw	a0,4(s1)
    80003b7a:	893d                	andi	a0,a0,15
    80003b7c:	051a                	slli	a0,a0,0x6
    80003b7e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003b80:	04449703          	lh	a4,68(s1)
    80003b84:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003b88:	04649703          	lh	a4,70(s1)
    80003b8c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003b90:	04849703          	lh	a4,72(s1)
    80003b94:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003b98:	04a49703          	lh	a4,74(s1)
    80003b9c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ba0:	44f8                	lw	a4,76(s1)
    80003ba2:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ba4:	03400613          	li	a2,52
    80003ba8:	05048593          	addi	a1,s1,80
    80003bac:	0531                	addi	a0,a0,12
    80003bae:	ffffd097          	auipc	ra,0xffffd
    80003bb2:	198080e7          	jalr	408(ra) # 80000d46 <memmove>
  log_write(bp);
    80003bb6:	854a                	mv	a0,s2
    80003bb8:	00001097          	auipc	ra,0x1
    80003bbc:	bf6080e7          	jalr	-1034(ra) # 800047ae <log_write>
  brelse(bp);
    80003bc0:	854a                	mv	a0,s2
    80003bc2:	00000097          	auipc	ra,0x0
    80003bc6:	968080e7          	jalr	-1688(ra) # 8000352a <brelse>
}
    80003bca:	60e2                	ld	ra,24(sp)
    80003bcc:	6442                	ld	s0,16(sp)
    80003bce:	64a2                	ld	s1,8(sp)
    80003bd0:	6902                	ld	s2,0(sp)
    80003bd2:	6105                	addi	sp,sp,32
    80003bd4:	8082                	ret

0000000080003bd6 <idup>:
{
    80003bd6:	1101                	addi	sp,sp,-32
    80003bd8:	ec06                	sd	ra,24(sp)
    80003bda:	e822                	sd	s0,16(sp)
    80003bdc:	e426                	sd	s1,8(sp)
    80003bde:	1000                	addi	s0,sp,32
    80003be0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003be2:	0001c517          	auipc	a0,0x1c
    80003be6:	e8650513          	addi	a0,a0,-378 # 8001fa68 <itable>
    80003bea:	ffffd097          	auipc	ra,0xffffd
    80003bee:	000080e7          	jalr	ra # 80000bea <acquire>
  ip->ref++;
    80003bf2:	449c                	lw	a5,8(s1)
    80003bf4:	2785                	addiw	a5,a5,1
    80003bf6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bf8:	0001c517          	auipc	a0,0x1c
    80003bfc:	e7050513          	addi	a0,a0,-400 # 8001fa68 <itable>
    80003c00:	ffffd097          	auipc	ra,0xffffd
    80003c04:	09e080e7          	jalr	158(ra) # 80000c9e <release>
}
    80003c08:	8526                	mv	a0,s1
    80003c0a:	60e2                	ld	ra,24(sp)
    80003c0c:	6442                	ld	s0,16(sp)
    80003c0e:	64a2                	ld	s1,8(sp)
    80003c10:	6105                	addi	sp,sp,32
    80003c12:	8082                	ret

0000000080003c14 <ilock>:
{
    80003c14:	1101                	addi	sp,sp,-32
    80003c16:	ec06                	sd	ra,24(sp)
    80003c18:	e822                	sd	s0,16(sp)
    80003c1a:	e426                	sd	s1,8(sp)
    80003c1c:	e04a                	sd	s2,0(sp)
    80003c1e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c20:	c115                	beqz	a0,80003c44 <ilock+0x30>
    80003c22:	84aa                	mv	s1,a0
    80003c24:	451c                	lw	a5,8(a0)
    80003c26:	00f05f63          	blez	a5,80003c44 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c2a:	0541                	addi	a0,a0,16
    80003c2c:	00001097          	auipc	ra,0x1
    80003c30:	ca2080e7          	jalr	-862(ra) # 800048ce <acquiresleep>
  if(ip->valid == 0){
    80003c34:	40bc                	lw	a5,64(s1)
    80003c36:	cf99                	beqz	a5,80003c54 <ilock+0x40>
}
    80003c38:	60e2                	ld	ra,24(sp)
    80003c3a:	6442                	ld	s0,16(sp)
    80003c3c:	64a2                	ld	s1,8(sp)
    80003c3e:	6902                	ld	s2,0(sp)
    80003c40:	6105                	addi	sp,sp,32
    80003c42:	8082                	ret
    panic("ilock");
    80003c44:	00005517          	auipc	a0,0x5
    80003c48:	b9c50513          	addi	a0,a0,-1124 # 800087e0 <syscalls+0x1b0>
    80003c4c:	ffffd097          	auipc	ra,0xffffd
    80003c50:	8f8080e7          	jalr	-1800(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c54:	40dc                	lw	a5,4(s1)
    80003c56:	0047d79b          	srliw	a5,a5,0x4
    80003c5a:	0001c597          	auipc	a1,0x1c
    80003c5e:	e065a583          	lw	a1,-506(a1) # 8001fa60 <sb+0x18>
    80003c62:	9dbd                	addw	a1,a1,a5
    80003c64:	4088                	lw	a0,0(s1)
    80003c66:	fffff097          	auipc	ra,0xfffff
    80003c6a:	794080e7          	jalr	1940(ra) # 800033fa <bread>
    80003c6e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c70:	05850593          	addi	a1,a0,88
    80003c74:	40dc                	lw	a5,4(s1)
    80003c76:	8bbd                	andi	a5,a5,15
    80003c78:	079a                	slli	a5,a5,0x6
    80003c7a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c7c:	00059783          	lh	a5,0(a1)
    80003c80:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c84:	00259783          	lh	a5,2(a1)
    80003c88:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c8c:	00459783          	lh	a5,4(a1)
    80003c90:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c94:	00659783          	lh	a5,6(a1)
    80003c98:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c9c:	459c                	lw	a5,8(a1)
    80003c9e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ca0:	03400613          	li	a2,52
    80003ca4:	05b1                	addi	a1,a1,12
    80003ca6:	05048513          	addi	a0,s1,80
    80003caa:	ffffd097          	auipc	ra,0xffffd
    80003cae:	09c080e7          	jalr	156(ra) # 80000d46 <memmove>
    brelse(bp);
    80003cb2:	854a                	mv	a0,s2
    80003cb4:	00000097          	auipc	ra,0x0
    80003cb8:	876080e7          	jalr	-1930(ra) # 8000352a <brelse>
    ip->valid = 1;
    80003cbc:	4785                	li	a5,1
    80003cbe:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003cc0:	04449783          	lh	a5,68(s1)
    80003cc4:	fbb5                	bnez	a5,80003c38 <ilock+0x24>
      panic("ilock: no type");
    80003cc6:	00005517          	auipc	a0,0x5
    80003cca:	b2250513          	addi	a0,a0,-1246 # 800087e8 <syscalls+0x1b8>
    80003cce:	ffffd097          	auipc	ra,0xffffd
    80003cd2:	876080e7          	jalr	-1930(ra) # 80000544 <panic>

0000000080003cd6 <iunlock>:
{
    80003cd6:	1101                	addi	sp,sp,-32
    80003cd8:	ec06                	sd	ra,24(sp)
    80003cda:	e822                	sd	s0,16(sp)
    80003cdc:	e426                	sd	s1,8(sp)
    80003cde:	e04a                	sd	s2,0(sp)
    80003ce0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ce2:	c905                	beqz	a0,80003d12 <iunlock+0x3c>
    80003ce4:	84aa                	mv	s1,a0
    80003ce6:	01050913          	addi	s2,a0,16
    80003cea:	854a                	mv	a0,s2
    80003cec:	00001097          	auipc	ra,0x1
    80003cf0:	c7c080e7          	jalr	-900(ra) # 80004968 <holdingsleep>
    80003cf4:	cd19                	beqz	a0,80003d12 <iunlock+0x3c>
    80003cf6:	449c                	lw	a5,8(s1)
    80003cf8:	00f05d63          	blez	a5,80003d12 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003cfc:	854a                	mv	a0,s2
    80003cfe:	00001097          	auipc	ra,0x1
    80003d02:	c26080e7          	jalr	-986(ra) # 80004924 <releasesleep>
}
    80003d06:	60e2                	ld	ra,24(sp)
    80003d08:	6442                	ld	s0,16(sp)
    80003d0a:	64a2                	ld	s1,8(sp)
    80003d0c:	6902                	ld	s2,0(sp)
    80003d0e:	6105                	addi	sp,sp,32
    80003d10:	8082                	ret
    panic("iunlock");
    80003d12:	00005517          	auipc	a0,0x5
    80003d16:	ae650513          	addi	a0,a0,-1306 # 800087f8 <syscalls+0x1c8>
    80003d1a:	ffffd097          	auipc	ra,0xffffd
    80003d1e:	82a080e7          	jalr	-2006(ra) # 80000544 <panic>

0000000080003d22 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d22:	7179                	addi	sp,sp,-48
    80003d24:	f406                	sd	ra,40(sp)
    80003d26:	f022                	sd	s0,32(sp)
    80003d28:	ec26                	sd	s1,24(sp)
    80003d2a:	e84a                	sd	s2,16(sp)
    80003d2c:	e44e                	sd	s3,8(sp)
    80003d2e:	e052                	sd	s4,0(sp)
    80003d30:	1800                	addi	s0,sp,48
    80003d32:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d34:	05050493          	addi	s1,a0,80
    80003d38:	08050913          	addi	s2,a0,128
    80003d3c:	a021                	j	80003d44 <itrunc+0x22>
    80003d3e:	0491                	addi	s1,s1,4
    80003d40:	01248d63          	beq	s1,s2,80003d5a <itrunc+0x38>
    if(ip->addrs[i]){
    80003d44:	408c                	lw	a1,0(s1)
    80003d46:	dde5                	beqz	a1,80003d3e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d48:	0009a503          	lw	a0,0(s3)
    80003d4c:	00000097          	auipc	ra,0x0
    80003d50:	8f4080e7          	jalr	-1804(ra) # 80003640 <bfree>
      ip->addrs[i] = 0;
    80003d54:	0004a023          	sw	zero,0(s1)
    80003d58:	b7dd                	j	80003d3e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d5a:	0809a583          	lw	a1,128(s3)
    80003d5e:	e185                	bnez	a1,80003d7e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d60:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d64:	854e                	mv	a0,s3
    80003d66:	00000097          	auipc	ra,0x0
    80003d6a:	de4080e7          	jalr	-540(ra) # 80003b4a <iupdate>
}
    80003d6e:	70a2                	ld	ra,40(sp)
    80003d70:	7402                	ld	s0,32(sp)
    80003d72:	64e2                	ld	s1,24(sp)
    80003d74:	6942                	ld	s2,16(sp)
    80003d76:	69a2                	ld	s3,8(sp)
    80003d78:	6a02                	ld	s4,0(sp)
    80003d7a:	6145                	addi	sp,sp,48
    80003d7c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d7e:	0009a503          	lw	a0,0(s3)
    80003d82:	fffff097          	auipc	ra,0xfffff
    80003d86:	678080e7          	jalr	1656(ra) # 800033fa <bread>
    80003d8a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d8c:	05850493          	addi	s1,a0,88
    80003d90:	45850913          	addi	s2,a0,1112
    80003d94:	a811                	j	80003da8 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003d96:	0009a503          	lw	a0,0(s3)
    80003d9a:	00000097          	auipc	ra,0x0
    80003d9e:	8a6080e7          	jalr	-1882(ra) # 80003640 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003da2:	0491                	addi	s1,s1,4
    80003da4:	01248563          	beq	s1,s2,80003dae <itrunc+0x8c>
      if(a[j])
    80003da8:	408c                	lw	a1,0(s1)
    80003daa:	dde5                	beqz	a1,80003da2 <itrunc+0x80>
    80003dac:	b7ed                	j	80003d96 <itrunc+0x74>
    brelse(bp);
    80003dae:	8552                	mv	a0,s4
    80003db0:	fffff097          	auipc	ra,0xfffff
    80003db4:	77a080e7          	jalr	1914(ra) # 8000352a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003db8:	0809a583          	lw	a1,128(s3)
    80003dbc:	0009a503          	lw	a0,0(s3)
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	880080e7          	jalr	-1920(ra) # 80003640 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003dc8:	0809a023          	sw	zero,128(s3)
    80003dcc:	bf51                	j	80003d60 <itrunc+0x3e>

0000000080003dce <iput>:
{
    80003dce:	1101                	addi	sp,sp,-32
    80003dd0:	ec06                	sd	ra,24(sp)
    80003dd2:	e822                	sd	s0,16(sp)
    80003dd4:	e426                	sd	s1,8(sp)
    80003dd6:	e04a                	sd	s2,0(sp)
    80003dd8:	1000                	addi	s0,sp,32
    80003dda:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ddc:	0001c517          	auipc	a0,0x1c
    80003de0:	c8c50513          	addi	a0,a0,-884 # 8001fa68 <itable>
    80003de4:	ffffd097          	auipc	ra,0xffffd
    80003de8:	e06080e7          	jalr	-506(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dec:	4498                	lw	a4,8(s1)
    80003dee:	4785                	li	a5,1
    80003df0:	02f70363          	beq	a4,a5,80003e16 <iput+0x48>
  ip->ref--;
    80003df4:	449c                	lw	a5,8(s1)
    80003df6:	37fd                	addiw	a5,a5,-1
    80003df8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dfa:	0001c517          	auipc	a0,0x1c
    80003dfe:	c6e50513          	addi	a0,a0,-914 # 8001fa68 <itable>
    80003e02:	ffffd097          	auipc	ra,0xffffd
    80003e06:	e9c080e7          	jalr	-356(ra) # 80000c9e <release>
}
    80003e0a:	60e2                	ld	ra,24(sp)
    80003e0c:	6442                	ld	s0,16(sp)
    80003e0e:	64a2                	ld	s1,8(sp)
    80003e10:	6902                	ld	s2,0(sp)
    80003e12:	6105                	addi	sp,sp,32
    80003e14:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e16:	40bc                	lw	a5,64(s1)
    80003e18:	dff1                	beqz	a5,80003df4 <iput+0x26>
    80003e1a:	04a49783          	lh	a5,74(s1)
    80003e1e:	fbf9                	bnez	a5,80003df4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e20:	01048913          	addi	s2,s1,16
    80003e24:	854a                	mv	a0,s2
    80003e26:	00001097          	auipc	ra,0x1
    80003e2a:	aa8080e7          	jalr	-1368(ra) # 800048ce <acquiresleep>
    release(&itable.lock);
    80003e2e:	0001c517          	auipc	a0,0x1c
    80003e32:	c3a50513          	addi	a0,a0,-966 # 8001fa68 <itable>
    80003e36:	ffffd097          	auipc	ra,0xffffd
    80003e3a:	e68080e7          	jalr	-408(ra) # 80000c9e <release>
    itrunc(ip);
    80003e3e:	8526                	mv	a0,s1
    80003e40:	00000097          	auipc	ra,0x0
    80003e44:	ee2080e7          	jalr	-286(ra) # 80003d22 <itrunc>
    ip->type = 0;
    80003e48:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e4c:	8526                	mv	a0,s1
    80003e4e:	00000097          	auipc	ra,0x0
    80003e52:	cfc080e7          	jalr	-772(ra) # 80003b4a <iupdate>
    ip->valid = 0;
    80003e56:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e5a:	854a                	mv	a0,s2
    80003e5c:	00001097          	auipc	ra,0x1
    80003e60:	ac8080e7          	jalr	-1336(ra) # 80004924 <releasesleep>
    acquire(&itable.lock);
    80003e64:	0001c517          	auipc	a0,0x1c
    80003e68:	c0450513          	addi	a0,a0,-1020 # 8001fa68 <itable>
    80003e6c:	ffffd097          	auipc	ra,0xffffd
    80003e70:	d7e080e7          	jalr	-642(ra) # 80000bea <acquire>
    80003e74:	b741                	j	80003df4 <iput+0x26>

0000000080003e76 <iunlockput>:
{
    80003e76:	1101                	addi	sp,sp,-32
    80003e78:	ec06                	sd	ra,24(sp)
    80003e7a:	e822                	sd	s0,16(sp)
    80003e7c:	e426                	sd	s1,8(sp)
    80003e7e:	1000                	addi	s0,sp,32
    80003e80:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e82:	00000097          	auipc	ra,0x0
    80003e86:	e54080e7          	jalr	-428(ra) # 80003cd6 <iunlock>
  iput(ip);
    80003e8a:	8526                	mv	a0,s1
    80003e8c:	00000097          	auipc	ra,0x0
    80003e90:	f42080e7          	jalr	-190(ra) # 80003dce <iput>
}
    80003e94:	60e2                	ld	ra,24(sp)
    80003e96:	6442                	ld	s0,16(sp)
    80003e98:	64a2                	ld	s1,8(sp)
    80003e9a:	6105                	addi	sp,sp,32
    80003e9c:	8082                	ret

0000000080003e9e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e9e:	1141                	addi	sp,sp,-16
    80003ea0:	e422                	sd	s0,8(sp)
    80003ea2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ea4:	411c                	lw	a5,0(a0)
    80003ea6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ea8:	415c                	lw	a5,4(a0)
    80003eaa:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003eac:	04451783          	lh	a5,68(a0)
    80003eb0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003eb4:	04a51783          	lh	a5,74(a0)
    80003eb8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ebc:	04c56783          	lwu	a5,76(a0)
    80003ec0:	e99c                	sd	a5,16(a1)
}
    80003ec2:	6422                	ld	s0,8(sp)
    80003ec4:	0141                	addi	sp,sp,16
    80003ec6:	8082                	ret

0000000080003ec8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ec8:	457c                	lw	a5,76(a0)
    80003eca:	0ed7e963          	bltu	a5,a3,80003fbc <readi+0xf4>
{
    80003ece:	7159                	addi	sp,sp,-112
    80003ed0:	f486                	sd	ra,104(sp)
    80003ed2:	f0a2                	sd	s0,96(sp)
    80003ed4:	eca6                	sd	s1,88(sp)
    80003ed6:	e8ca                	sd	s2,80(sp)
    80003ed8:	e4ce                	sd	s3,72(sp)
    80003eda:	e0d2                	sd	s4,64(sp)
    80003edc:	fc56                	sd	s5,56(sp)
    80003ede:	f85a                	sd	s6,48(sp)
    80003ee0:	f45e                	sd	s7,40(sp)
    80003ee2:	f062                	sd	s8,32(sp)
    80003ee4:	ec66                	sd	s9,24(sp)
    80003ee6:	e86a                	sd	s10,16(sp)
    80003ee8:	e46e                	sd	s11,8(sp)
    80003eea:	1880                	addi	s0,sp,112
    80003eec:	8b2a                	mv	s6,a0
    80003eee:	8bae                	mv	s7,a1
    80003ef0:	8a32                	mv	s4,a2
    80003ef2:	84b6                	mv	s1,a3
    80003ef4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ef6:	9f35                	addw	a4,a4,a3
    return 0;
    80003ef8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003efa:	0ad76063          	bltu	a4,a3,80003f9a <readi+0xd2>
  if(off + n > ip->size)
    80003efe:	00e7f463          	bgeu	a5,a4,80003f06 <readi+0x3e>
    n = ip->size - off;
    80003f02:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f06:	0a0a8963          	beqz	s5,80003fb8 <readi+0xf0>
    80003f0a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f0c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f10:	5c7d                	li	s8,-1
    80003f12:	a82d                	j	80003f4c <readi+0x84>
    80003f14:	020d1d93          	slli	s11,s10,0x20
    80003f18:	020ddd93          	srli	s11,s11,0x20
    80003f1c:	05890613          	addi	a2,s2,88
    80003f20:	86ee                	mv	a3,s11
    80003f22:	963a                	add	a2,a2,a4
    80003f24:	85d2                	mv	a1,s4
    80003f26:	855e                	mv	a0,s7
    80003f28:	ffffe097          	auipc	ra,0xffffe
    80003f2c:	62a080e7          	jalr	1578(ra) # 80002552 <either_copyout>
    80003f30:	05850d63          	beq	a0,s8,80003f8a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f34:	854a                	mv	a0,s2
    80003f36:	fffff097          	auipc	ra,0xfffff
    80003f3a:	5f4080e7          	jalr	1524(ra) # 8000352a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f3e:	013d09bb          	addw	s3,s10,s3
    80003f42:	009d04bb          	addw	s1,s10,s1
    80003f46:	9a6e                	add	s4,s4,s11
    80003f48:	0559f763          	bgeu	s3,s5,80003f96 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f4c:	00a4d59b          	srliw	a1,s1,0xa
    80003f50:	855a                	mv	a0,s6
    80003f52:	00000097          	auipc	ra,0x0
    80003f56:	8a2080e7          	jalr	-1886(ra) # 800037f4 <bmap>
    80003f5a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f5e:	cd85                	beqz	a1,80003f96 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f60:	000b2503          	lw	a0,0(s6)
    80003f64:	fffff097          	auipc	ra,0xfffff
    80003f68:	496080e7          	jalr	1174(ra) # 800033fa <bread>
    80003f6c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f6e:	3ff4f713          	andi	a4,s1,1023
    80003f72:	40ec87bb          	subw	a5,s9,a4
    80003f76:	413a86bb          	subw	a3,s5,s3
    80003f7a:	8d3e                	mv	s10,a5
    80003f7c:	2781                	sext.w	a5,a5
    80003f7e:	0006861b          	sext.w	a2,a3
    80003f82:	f8f679e3          	bgeu	a2,a5,80003f14 <readi+0x4c>
    80003f86:	8d36                	mv	s10,a3
    80003f88:	b771                	j	80003f14 <readi+0x4c>
      brelse(bp);
    80003f8a:	854a                	mv	a0,s2
    80003f8c:	fffff097          	auipc	ra,0xfffff
    80003f90:	59e080e7          	jalr	1438(ra) # 8000352a <brelse>
      tot = -1;
    80003f94:	59fd                	li	s3,-1
  }
  return tot;
    80003f96:	0009851b          	sext.w	a0,s3
}
    80003f9a:	70a6                	ld	ra,104(sp)
    80003f9c:	7406                	ld	s0,96(sp)
    80003f9e:	64e6                	ld	s1,88(sp)
    80003fa0:	6946                	ld	s2,80(sp)
    80003fa2:	69a6                	ld	s3,72(sp)
    80003fa4:	6a06                	ld	s4,64(sp)
    80003fa6:	7ae2                	ld	s5,56(sp)
    80003fa8:	7b42                	ld	s6,48(sp)
    80003faa:	7ba2                	ld	s7,40(sp)
    80003fac:	7c02                	ld	s8,32(sp)
    80003fae:	6ce2                	ld	s9,24(sp)
    80003fb0:	6d42                	ld	s10,16(sp)
    80003fb2:	6da2                	ld	s11,8(sp)
    80003fb4:	6165                	addi	sp,sp,112
    80003fb6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fb8:	89d6                	mv	s3,s5
    80003fba:	bff1                	j	80003f96 <readi+0xce>
    return 0;
    80003fbc:	4501                	li	a0,0
}
    80003fbe:	8082                	ret

0000000080003fc0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fc0:	457c                	lw	a5,76(a0)
    80003fc2:	10d7e863          	bltu	a5,a3,800040d2 <writei+0x112>
{
    80003fc6:	7159                	addi	sp,sp,-112
    80003fc8:	f486                	sd	ra,104(sp)
    80003fca:	f0a2                	sd	s0,96(sp)
    80003fcc:	eca6                	sd	s1,88(sp)
    80003fce:	e8ca                	sd	s2,80(sp)
    80003fd0:	e4ce                	sd	s3,72(sp)
    80003fd2:	e0d2                	sd	s4,64(sp)
    80003fd4:	fc56                	sd	s5,56(sp)
    80003fd6:	f85a                	sd	s6,48(sp)
    80003fd8:	f45e                	sd	s7,40(sp)
    80003fda:	f062                	sd	s8,32(sp)
    80003fdc:	ec66                	sd	s9,24(sp)
    80003fde:	e86a                	sd	s10,16(sp)
    80003fe0:	e46e                	sd	s11,8(sp)
    80003fe2:	1880                	addi	s0,sp,112
    80003fe4:	8aaa                	mv	s5,a0
    80003fe6:	8bae                	mv	s7,a1
    80003fe8:	8a32                	mv	s4,a2
    80003fea:	8936                	mv	s2,a3
    80003fec:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fee:	00e687bb          	addw	a5,a3,a4
    80003ff2:	0ed7e263          	bltu	a5,a3,800040d6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ff6:	00043737          	lui	a4,0x43
    80003ffa:	0ef76063          	bltu	a4,a5,800040da <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ffe:	0c0b0863          	beqz	s6,800040ce <writei+0x10e>
    80004002:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004004:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004008:	5c7d                	li	s8,-1
    8000400a:	a091                	j	8000404e <writei+0x8e>
    8000400c:	020d1d93          	slli	s11,s10,0x20
    80004010:	020ddd93          	srli	s11,s11,0x20
    80004014:	05848513          	addi	a0,s1,88
    80004018:	86ee                	mv	a3,s11
    8000401a:	8652                	mv	a2,s4
    8000401c:	85de                	mv	a1,s7
    8000401e:	953a                	add	a0,a0,a4
    80004020:	ffffe097          	auipc	ra,0xffffe
    80004024:	588080e7          	jalr	1416(ra) # 800025a8 <either_copyin>
    80004028:	07850263          	beq	a0,s8,8000408c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000402c:	8526                	mv	a0,s1
    8000402e:	00000097          	auipc	ra,0x0
    80004032:	780080e7          	jalr	1920(ra) # 800047ae <log_write>
    brelse(bp);
    80004036:	8526                	mv	a0,s1
    80004038:	fffff097          	auipc	ra,0xfffff
    8000403c:	4f2080e7          	jalr	1266(ra) # 8000352a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004040:	013d09bb          	addw	s3,s10,s3
    80004044:	012d093b          	addw	s2,s10,s2
    80004048:	9a6e                	add	s4,s4,s11
    8000404a:	0569f663          	bgeu	s3,s6,80004096 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000404e:	00a9559b          	srliw	a1,s2,0xa
    80004052:	8556                	mv	a0,s5
    80004054:	fffff097          	auipc	ra,0xfffff
    80004058:	7a0080e7          	jalr	1952(ra) # 800037f4 <bmap>
    8000405c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004060:	c99d                	beqz	a1,80004096 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004062:	000aa503          	lw	a0,0(s5)
    80004066:	fffff097          	auipc	ra,0xfffff
    8000406a:	394080e7          	jalr	916(ra) # 800033fa <bread>
    8000406e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004070:	3ff97713          	andi	a4,s2,1023
    80004074:	40ec87bb          	subw	a5,s9,a4
    80004078:	413b06bb          	subw	a3,s6,s3
    8000407c:	8d3e                	mv	s10,a5
    8000407e:	2781                	sext.w	a5,a5
    80004080:	0006861b          	sext.w	a2,a3
    80004084:	f8f674e3          	bgeu	a2,a5,8000400c <writei+0x4c>
    80004088:	8d36                	mv	s10,a3
    8000408a:	b749                	j	8000400c <writei+0x4c>
      brelse(bp);
    8000408c:	8526                	mv	a0,s1
    8000408e:	fffff097          	auipc	ra,0xfffff
    80004092:	49c080e7          	jalr	1180(ra) # 8000352a <brelse>
  }

  if(off > ip->size)
    80004096:	04caa783          	lw	a5,76(s5)
    8000409a:	0127f463          	bgeu	a5,s2,800040a2 <writei+0xe2>
    ip->size = off;
    8000409e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800040a2:	8556                	mv	a0,s5
    800040a4:	00000097          	auipc	ra,0x0
    800040a8:	aa6080e7          	jalr	-1370(ra) # 80003b4a <iupdate>

  return tot;
    800040ac:	0009851b          	sext.w	a0,s3
}
    800040b0:	70a6                	ld	ra,104(sp)
    800040b2:	7406                	ld	s0,96(sp)
    800040b4:	64e6                	ld	s1,88(sp)
    800040b6:	6946                	ld	s2,80(sp)
    800040b8:	69a6                	ld	s3,72(sp)
    800040ba:	6a06                	ld	s4,64(sp)
    800040bc:	7ae2                	ld	s5,56(sp)
    800040be:	7b42                	ld	s6,48(sp)
    800040c0:	7ba2                	ld	s7,40(sp)
    800040c2:	7c02                	ld	s8,32(sp)
    800040c4:	6ce2                	ld	s9,24(sp)
    800040c6:	6d42                	ld	s10,16(sp)
    800040c8:	6da2                	ld	s11,8(sp)
    800040ca:	6165                	addi	sp,sp,112
    800040cc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040ce:	89da                	mv	s3,s6
    800040d0:	bfc9                	j	800040a2 <writei+0xe2>
    return -1;
    800040d2:	557d                	li	a0,-1
}
    800040d4:	8082                	ret
    return -1;
    800040d6:	557d                	li	a0,-1
    800040d8:	bfe1                	j	800040b0 <writei+0xf0>
    return -1;
    800040da:	557d                	li	a0,-1
    800040dc:	bfd1                	j	800040b0 <writei+0xf0>

00000000800040de <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040de:	1141                	addi	sp,sp,-16
    800040e0:	e406                	sd	ra,8(sp)
    800040e2:	e022                	sd	s0,0(sp)
    800040e4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040e6:	4639                	li	a2,14
    800040e8:	ffffd097          	auipc	ra,0xffffd
    800040ec:	cd6080e7          	jalr	-810(ra) # 80000dbe <strncmp>
}
    800040f0:	60a2                	ld	ra,8(sp)
    800040f2:	6402                	ld	s0,0(sp)
    800040f4:	0141                	addi	sp,sp,16
    800040f6:	8082                	ret

00000000800040f8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040f8:	7139                	addi	sp,sp,-64
    800040fa:	fc06                	sd	ra,56(sp)
    800040fc:	f822                	sd	s0,48(sp)
    800040fe:	f426                	sd	s1,40(sp)
    80004100:	f04a                	sd	s2,32(sp)
    80004102:	ec4e                	sd	s3,24(sp)
    80004104:	e852                	sd	s4,16(sp)
    80004106:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004108:	04451703          	lh	a4,68(a0)
    8000410c:	4785                	li	a5,1
    8000410e:	00f71a63          	bne	a4,a5,80004122 <dirlookup+0x2a>
    80004112:	892a                	mv	s2,a0
    80004114:	89ae                	mv	s3,a1
    80004116:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004118:	457c                	lw	a5,76(a0)
    8000411a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000411c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000411e:	e79d                	bnez	a5,8000414c <dirlookup+0x54>
    80004120:	a8a5                	j	80004198 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004122:	00004517          	auipc	a0,0x4
    80004126:	6de50513          	addi	a0,a0,1758 # 80008800 <syscalls+0x1d0>
    8000412a:	ffffc097          	auipc	ra,0xffffc
    8000412e:	41a080e7          	jalr	1050(ra) # 80000544 <panic>
      panic("dirlookup read");
    80004132:	00004517          	auipc	a0,0x4
    80004136:	6e650513          	addi	a0,a0,1766 # 80008818 <syscalls+0x1e8>
    8000413a:	ffffc097          	auipc	ra,0xffffc
    8000413e:	40a080e7          	jalr	1034(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004142:	24c1                	addiw	s1,s1,16
    80004144:	04c92783          	lw	a5,76(s2)
    80004148:	04f4f763          	bgeu	s1,a5,80004196 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000414c:	4741                	li	a4,16
    8000414e:	86a6                	mv	a3,s1
    80004150:	fc040613          	addi	a2,s0,-64
    80004154:	4581                	li	a1,0
    80004156:	854a                	mv	a0,s2
    80004158:	00000097          	auipc	ra,0x0
    8000415c:	d70080e7          	jalr	-656(ra) # 80003ec8 <readi>
    80004160:	47c1                	li	a5,16
    80004162:	fcf518e3          	bne	a0,a5,80004132 <dirlookup+0x3a>
    if(de.inum == 0)
    80004166:	fc045783          	lhu	a5,-64(s0)
    8000416a:	dfe1                	beqz	a5,80004142 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000416c:	fc240593          	addi	a1,s0,-62
    80004170:	854e                	mv	a0,s3
    80004172:	00000097          	auipc	ra,0x0
    80004176:	f6c080e7          	jalr	-148(ra) # 800040de <namecmp>
    8000417a:	f561                	bnez	a0,80004142 <dirlookup+0x4a>
      if(poff)
    8000417c:	000a0463          	beqz	s4,80004184 <dirlookup+0x8c>
        *poff = off;
    80004180:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004184:	fc045583          	lhu	a1,-64(s0)
    80004188:	00092503          	lw	a0,0(s2)
    8000418c:	fffff097          	auipc	ra,0xfffff
    80004190:	750080e7          	jalr	1872(ra) # 800038dc <iget>
    80004194:	a011                	j	80004198 <dirlookup+0xa0>
  return 0;
    80004196:	4501                	li	a0,0
}
    80004198:	70e2                	ld	ra,56(sp)
    8000419a:	7442                	ld	s0,48(sp)
    8000419c:	74a2                	ld	s1,40(sp)
    8000419e:	7902                	ld	s2,32(sp)
    800041a0:	69e2                	ld	s3,24(sp)
    800041a2:	6a42                	ld	s4,16(sp)
    800041a4:	6121                	addi	sp,sp,64
    800041a6:	8082                	ret

00000000800041a8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041a8:	711d                	addi	sp,sp,-96
    800041aa:	ec86                	sd	ra,88(sp)
    800041ac:	e8a2                	sd	s0,80(sp)
    800041ae:	e4a6                	sd	s1,72(sp)
    800041b0:	e0ca                	sd	s2,64(sp)
    800041b2:	fc4e                	sd	s3,56(sp)
    800041b4:	f852                	sd	s4,48(sp)
    800041b6:	f456                	sd	s5,40(sp)
    800041b8:	f05a                	sd	s6,32(sp)
    800041ba:	ec5e                	sd	s7,24(sp)
    800041bc:	e862                	sd	s8,16(sp)
    800041be:	e466                	sd	s9,8(sp)
    800041c0:	1080                	addi	s0,sp,96
    800041c2:	84aa                	mv	s1,a0
    800041c4:	8b2e                	mv	s6,a1
    800041c6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041c8:	00054703          	lbu	a4,0(a0)
    800041cc:	02f00793          	li	a5,47
    800041d0:	02f70363          	beq	a4,a5,800041f6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041d4:	ffffd097          	auipc	ra,0xffffd
    800041d8:	7f2080e7          	jalr	2034(ra) # 800019c6 <myproc>
    800041dc:	15053503          	ld	a0,336(a0)
    800041e0:	00000097          	auipc	ra,0x0
    800041e4:	9f6080e7          	jalr	-1546(ra) # 80003bd6 <idup>
    800041e8:	89aa                	mv	s3,a0
  while(*path == '/')
    800041ea:	02f00913          	li	s2,47
  len = path - s;
    800041ee:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800041f0:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041f2:	4c05                	li	s8,1
    800041f4:	a865                	j	800042ac <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800041f6:	4585                	li	a1,1
    800041f8:	4505                	li	a0,1
    800041fa:	fffff097          	auipc	ra,0xfffff
    800041fe:	6e2080e7          	jalr	1762(ra) # 800038dc <iget>
    80004202:	89aa                	mv	s3,a0
    80004204:	b7dd                	j	800041ea <namex+0x42>
      iunlockput(ip);
    80004206:	854e                	mv	a0,s3
    80004208:	00000097          	auipc	ra,0x0
    8000420c:	c6e080e7          	jalr	-914(ra) # 80003e76 <iunlockput>
      return 0;
    80004210:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004212:	854e                	mv	a0,s3
    80004214:	60e6                	ld	ra,88(sp)
    80004216:	6446                	ld	s0,80(sp)
    80004218:	64a6                	ld	s1,72(sp)
    8000421a:	6906                	ld	s2,64(sp)
    8000421c:	79e2                	ld	s3,56(sp)
    8000421e:	7a42                	ld	s4,48(sp)
    80004220:	7aa2                	ld	s5,40(sp)
    80004222:	7b02                	ld	s6,32(sp)
    80004224:	6be2                	ld	s7,24(sp)
    80004226:	6c42                	ld	s8,16(sp)
    80004228:	6ca2                	ld	s9,8(sp)
    8000422a:	6125                	addi	sp,sp,96
    8000422c:	8082                	ret
      iunlock(ip);
    8000422e:	854e                	mv	a0,s3
    80004230:	00000097          	auipc	ra,0x0
    80004234:	aa6080e7          	jalr	-1370(ra) # 80003cd6 <iunlock>
      return ip;
    80004238:	bfe9                	j	80004212 <namex+0x6a>
      iunlockput(ip);
    8000423a:	854e                	mv	a0,s3
    8000423c:	00000097          	auipc	ra,0x0
    80004240:	c3a080e7          	jalr	-966(ra) # 80003e76 <iunlockput>
      return 0;
    80004244:	89d2                	mv	s3,s4
    80004246:	b7f1                	j	80004212 <namex+0x6a>
  len = path - s;
    80004248:	40b48633          	sub	a2,s1,a1
    8000424c:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004250:	094cd463          	bge	s9,s4,800042d8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004254:	4639                	li	a2,14
    80004256:	8556                	mv	a0,s5
    80004258:	ffffd097          	auipc	ra,0xffffd
    8000425c:	aee080e7          	jalr	-1298(ra) # 80000d46 <memmove>
  while(*path == '/')
    80004260:	0004c783          	lbu	a5,0(s1)
    80004264:	01279763          	bne	a5,s2,80004272 <namex+0xca>
    path++;
    80004268:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000426a:	0004c783          	lbu	a5,0(s1)
    8000426e:	ff278de3          	beq	a5,s2,80004268 <namex+0xc0>
    ilock(ip);
    80004272:	854e                	mv	a0,s3
    80004274:	00000097          	auipc	ra,0x0
    80004278:	9a0080e7          	jalr	-1632(ra) # 80003c14 <ilock>
    if(ip->type != T_DIR){
    8000427c:	04499783          	lh	a5,68(s3)
    80004280:	f98793e3          	bne	a5,s8,80004206 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004284:	000b0563          	beqz	s6,8000428e <namex+0xe6>
    80004288:	0004c783          	lbu	a5,0(s1)
    8000428c:	d3cd                	beqz	a5,8000422e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000428e:	865e                	mv	a2,s7
    80004290:	85d6                	mv	a1,s5
    80004292:	854e                	mv	a0,s3
    80004294:	00000097          	auipc	ra,0x0
    80004298:	e64080e7          	jalr	-412(ra) # 800040f8 <dirlookup>
    8000429c:	8a2a                	mv	s4,a0
    8000429e:	dd51                	beqz	a0,8000423a <namex+0x92>
    iunlockput(ip);
    800042a0:	854e                	mv	a0,s3
    800042a2:	00000097          	auipc	ra,0x0
    800042a6:	bd4080e7          	jalr	-1068(ra) # 80003e76 <iunlockput>
    ip = next;
    800042aa:	89d2                	mv	s3,s4
  while(*path == '/')
    800042ac:	0004c783          	lbu	a5,0(s1)
    800042b0:	05279763          	bne	a5,s2,800042fe <namex+0x156>
    path++;
    800042b4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042b6:	0004c783          	lbu	a5,0(s1)
    800042ba:	ff278de3          	beq	a5,s2,800042b4 <namex+0x10c>
  if(*path == 0)
    800042be:	c79d                	beqz	a5,800042ec <namex+0x144>
    path++;
    800042c0:	85a6                	mv	a1,s1
  len = path - s;
    800042c2:	8a5e                	mv	s4,s7
    800042c4:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800042c6:	01278963          	beq	a5,s2,800042d8 <namex+0x130>
    800042ca:	dfbd                	beqz	a5,80004248 <namex+0xa0>
    path++;
    800042cc:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800042ce:	0004c783          	lbu	a5,0(s1)
    800042d2:	ff279ce3          	bne	a5,s2,800042ca <namex+0x122>
    800042d6:	bf8d                	j	80004248 <namex+0xa0>
    memmove(name, s, len);
    800042d8:	2601                	sext.w	a2,a2
    800042da:	8556                	mv	a0,s5
    800042dc:	ffffd097          	auipc	ra,0xffffd
    800042e0:	a6a080e7          	jalr	-1430(ra) # 80000d46 <memmove>
    name[len] = 0;
    800042e4:	9a56                	add	s4,s4,s5
    800042e6:	000a0023          	sb	zero,0(s4)
    800042ea:	bf9d                	j	80004260 <namex+0xb8>
  if(nameiparent){
    800042ec:	f20b03e3          	beqz	s6,80004212 <namex+0x6a>
    iput(ip);
    800042f0:	854e                	mv	a0,s3
    800042f2:	00000097          	auipc	ra,0x0
    800042f6:	adc080e7          	jalr	-1316(ra) # 80003dce <iput>
    return 0;
    800042fa:	4981                	li	s3,0
    800042fc:	bf19                	j	80004212 <namex+0x6a>
  if(*path == 0)
    800042fe:	d7fd                	beqz	a5,800042ec <namex+0x144>
  while(*path != '/' && *path != 0)
    80004300:	0004c783          	lbu	a5,0(s1)
    80004304:	85a6                	mv	a1,s1
    80004306:	b7d1                	j	800042ca <namex+0x122>

0000000080004308 <dirlink>:
{
    80004308:	7139                	addi	sp,sp,-64
    8000430a:	fc06                	sd	ra,56(sp)
    8000430c:	f822                	sd	s0,48(sp)
    8000430e:	f426                	sd	s1,40(sp)
    80004310:	f04a                	sd	s2,32(sp)
    80004312:	ec4e                	sd	s3,24(sp)
    80004314:	e852                	sd	s4,16(sp)
    80004316:	0080                	addi	s0,sp,64
    80004318:	892a                	mv	s2,a0
    8000431a:	8a2e                	mv	s4,a1
    8000431c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000431e:	4601                	li	a2,0
    80004320:	00000097          	auipc	ra,0x0
    80004324:	dd8080e7          	jalr	-552(ra) # 800040f8 <dirlookup>
    80004328:	e93d                	bnez	a0,8000439e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000432a:	04c92483          	lw	s1,76(s2)
    8000432e:	c49d                	beqz	s1,8000435c <dirlink+0x54>
    80004330:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004332:	4741                	li	a4,16
    80004334:	86a6                	mv	a3,s1
    80004336:	fc040613          	addi	a2,s0,-64
    8000433a:	4581                	li	a1,0
    8000433c:	854a                	mv	a0,s2
    8000433e:	00000097          	auipc	ra,0x0
    80004342:	b8a080e7          	jalr	-1142(ra) # 80003ec8 <readi>
    80004346:	47c1                	li	a5,16
    80004348:	06f51163          	bne	a0,a5,800043aa <dirlink+0xa2>
    if(de.inum == 0)
    8000434c:	fc045783          	lhu	a5,-64(s0)
    80004350:	c791                	beqz	a5,8000435c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004352:	24c1                	addiw	s1,s1,16
    80004354:	04c92783          	lw	a5,76(s2)
    80004358:	fcf4ede3          	bltu	s1,a5,80004332 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000435c:	4639                	li	a2,14
    8000435e:	85d2                	mv	a1,s4
    80004360:	fc240513          	addi	a0,s0,-62
    80004364:	ffffd097          	auipc	ra,0xffffd
    80004368:	a96080e7          	jalr	-1386(ra) # 80000dfa <strncpy>
  de.inum = inum;
    8000436c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004370:	4741                	li	a4,16
    80004372:	86a6                	mv	a3,s1
    80004374:	fc040613          	addi	a2,s0,-64
    80004378:	4581                	li	a1,0
    8000437a:	854a                	mv	a0,s2
    8000437c:	00000097          	auipc	ra,0x0
    80004380:	c44080e7          	jalr	-956(ra) # 80003fc0 <writei>
    80004384:	1541                	addi	a0,a0,-16
    80004386:	00a03533          	snez	a0,a0
    8000438a:	40a00533          	neg	a0,a0
}
    8000438e:	70e2                	ld	ra,56(sp)
    80004390:	7442                	ld	s0,48(sp)
    80004392:	74a2                	ld	s1,40(sp)
    80004394:	7902                	ld	s2,32(sp)
    80004396:	69e2                	ld	s3,24(sp)
    80004398:	6a42                	ld	s4,16(sp)
    8000439a:	6121                	addi	sp,sp,64
    8000439c:	8082                	ret
    iput(ip);
    8000439e:	00000097          	auipc	ra,0x0
    800043a2:	a30080e7          	jalr	-1488(ra) # 80003dce <iput>
    return -1;
    800043a6:	557d                	li	a0,-1
    800043a8:	b7dd                	j	8000438e <dirlink+0x86>
      panic("dirlink read");
    800043aa:	00004517          	auipc	a0,0x4
    800043ae:	47e50513          	addi	a0,a0,1150 # 80008828 <syscalls+0x1f8>
    800043b2:	ffffc097          	auipc	ra,0xffffc
    800043b6:	192080e7          	jalr	402(ra) # 80000544 <panic>

00000000800043ba <namei>:

struct inode*
namei(char *path)
{
    800043ba:	1101                	addi	sp,sp,-32
    800043bc:	ec06                	sd	ra,24(sp)
    800043be:	e822                	sd	s0,16(sp)
    800043c0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043c2:	fe040613          	addi	a2,s0,-32
    800043c6:	4581                	li	a1,0
    800043c8:	00000097          	auipc	ra,0x0
    800043cc:	de0080e7          	jalr	-544(ra) # 800041a8 <namex>
}
    800043d0:	60e2                	ld	ra,24(sp)
    800043d2:	6442                	ld	s0,16(sp)
    800043d4:	6105                	addi	sp,sp,32
    800043d6:	8082                	ret

00000000800043d8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043d8:	1141                	addi	sp,sp,-16
    800043da:	e406                	sd	ra,8(sp)
    800043dc:	e022                	sd	s0,0(sp)
    800043de:	0800                	addi	s0,sp,16
    800043e0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043e2:	4585                	li	a1,1
    800043e4:	00000097          	auipc	ra,0x0
    800043e8:	dc4080e7          	jalr	-572(ra) # 800041a8 <namex>
}
    800043ec:	60a2                	ld	ra,8(sp)
    800043ee:	6402                	ld	s0,0(sp)
    800043f0:	0141                	addi	sp,sp,16
    800043f2:	8082                	ret

00000000800043f4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043f4:	1101                	addi	sp,sp,-32
    800043f6:	ec06                	sd	ra,24(sp)
    800043f8:	e822                	sd	s0,16(sp)
    800043fa:	e426                	sd	s1,8(sp)
    800043fc:	e04a                	sd	s2,0(sp)
    800043fe:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004400:	0001d917          	auipc	s2,0x1d
    80004404:	11090913          	addi	s2,s2,272 # 80021510 <log>
    80004408:	01892583          	lw	a1,24(s2)
    8000440c:	02892503          	lw	a0,40(s2)
    80004410:	fffff097          	auipc	ra,0xfffff
    80004414:	fea080e7          	jalr	-22(ra) # 800033fa <bread>
    80004418:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000441a:	02c92683          	lw	a3,44(s2)
    8000441e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004420:	02d05763          	blez	a3,8000444e <write_head+0x5a>
    80004424:	0001d797          	auipc	a5,0x1d
    80004428:	11c78793          	addi	a5,a5,284 # 80021540 <log+0x30>
    8000442c:	05c50713          	addi	a4,a0,92
    80004430:	36fd                	addiw	a3,a3,-1
    80004432:	1682                	slli	a3,a3,0x20
    80004434:	9281                	srli	a3,a3,0x20
    80004436:	068a                	slli	a3,a3,0x2
    80004438:	0001d617          	auipc	a2,0x1d
    8000443c:	10c60613          	addi	a2,a2,268 # 80021544 <log+0x34>
    80004440:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004442:	4390                	lw	a2,0(a5)
    80004444:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004446:	0791                	addi	a5,a5,4
    80004448:	0711                	addi	a4,a4,4
    8000444a:	fed79ce3          	bne	a5,a3,80004442 <write_head+0x4e>
  }
  bwrite(buf);
    8000444e:	8526                	mv	a0,s1
    80004450:	fffff097          	auipc	ra,0xfffff
    80004454:	09c080e7          	jalr	156(ra) # 800034ec <bwrite>
  brelse(buf);
    80004458:	8526                	mv	a0,s1
    8000445a:	fffff097          	auipc	ra,0xfffff
    8000445e:	0d0080e7          	jalr	208(ra) # 8000352a <brelse>
}
    80004462:	60e2                	ld	ra,24(sp)
    80004464:	6442                	ld	s0,16(sp)
    80004466:	64a2                	ld	s1,8(sp)
    80004468:	6902                	ld	s2,0(sp)
    8000446a:	6105                	addi	sp,sp,32
    8000446c:	8082                	ret

000000008000446e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000446e:	0001d797          	auipc	a5,0x1d
    80004472:	0ce7a783          	lw	a5,206(a5) # 8002153c <log+0x2c>
    80004476:	0af05d63          	blez	a5,80004530 <install_trans+0xc2>
{
    8000447a:	7139                	addi	sp,sp,-64
    8000447c:	fc06                	sd	ra,56(sp)
    8000447e:	f822                	sd	s0,48(sp)
    80004480:	f426                	sd	s1,40(sp)
    80004482:	f04a                	sd	s2,32(sp)
    80004484:	ec4e                	sd	s3,24(sp)
    80004486:	e852                	sd	s4,16(sp)
    80004488:	e456                	sd	s5,8(sp)
    8000448a:	e05a                	sd	s6,0(sp)
    8000448c:	0080                	addi	s0,sp,64
    8000448e:	8b2a                	mv	s6,a0
    80004490:	0001da97          	auipc	s5,0x1d
    80004494:	0b0a8a93          	addi	s5,s5,176 # 80021540 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004498:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000449a:	0001d997          	auipc	s3,0x1d
    8000449e:	07698993          	addi	s3,s3,118 # 80021510 <log>
    800044a2:	a035                	j	800044ce <install_trans+0x60>
      bunpin(dbuf);
    800044a4:	8526                	mv	a0,s1
    800044a6:	fffff097          	auipc	ra,0xfffff
    800044aa:	15e080e7          	jalr	350(ra) # 80003604 <bunpin>
    brelse(lbuf);
    800044ae:	854a                	mv	a0,s2
    800044b0:	fffff097          	auipc	ra,0xfffff
    800044b4:	07a080e7          	jalr	122(ra) # 8000352a <brelse>
    brelse(dbuf);
    800044b8:	8526                	mv	a0,s1
    800044ba:	fffff097          	auipc	ra,0xfffff
    800044be:	070080e7          	jalr	112(ra) # 8000352a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044c2:	2a05                	addiw	s4,s4,1
    800044c4:	0a91                	addi	s5,s5,4
    800044c6:	02c9a783          	lw	a5,44(s3)
    800044ca:	04fa5963          	bge	s4,a5,8000451c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044ce:	0189a583          	lw	a1,24(s3)
    800044d2:	014585bb          	addw	a1,a1,s4
    800044d6:	2585                	addiw	a1,a1,1
    800044d8:	0289a503          	lw	a0,40(s3)
    800044dc:	fffff097          	auipc	ra,0xfffff
    800044e0:	f1e080e7          	jalr	-226(ra) # 800033fa <bread>
    800044e4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044e6:	000aa583          	lw	a1,0(s5)
    800044ea:	0289a503          	lw	a0,40(s3)
    800044ee:	fffff097          	auipc	ra,0xfffff
    800044f2:	f0c080e7          	jalr	-244(ra) # 800033fa <bread>
    800044f6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044f8:	40000613          	li	a2,1024
    800044fc:	05890593          	addi	a1,s2,88
    80004500:	05850513          	addi	a0,a0,88
    80004504:	ffffd097          	auipc	ra,0xffffd
    80004508:	842080e7          	jalr	-1982(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000450c:	8526                	mv	a0,s1
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	fde080e7          	jalr	-34(ra) # 800034ec <bwrite>
    if(recovering == 0)
    80004516:	f80b1ce3          	bnez	s6,800044ae <install_trans+0x40>
    8000451a:	b769                	j	800044a4 <install_trans+0x36>
}
    8000451c:	70e2                	ld	ra,56(sp)
    8000451e:	7442                	ld	s0,48(sp)
    80004520:	74a2                	ld	s1,40(sp)
    80004522:	7902                	ld	s2,32(sp)
    80004524:	69e2                	ld	s3,24(sp)
    80004526:	6a42                	ld	s4,16(sp)
    80004528:	6aa2                	ld	s5,8(sp)
    8000452a:	6b02                	ld	s6,0(sp)
    8000452c:	6121                	addi	sp,sp,64
    8000452e:	8082                	ret
    80004530:	8082                	ret

0000000080004532 <initlog>:
{
    80004532:	7179                	addi	sp,sp,-48
    80004534:	f406                	sd	ra,40(sp)
    80004536:	f022                	sd	s0,32(sp)
    80004538:	ec26                	sd	s1,24(sp)
    8000453a:	e84a                	sd	s2,16(sp)
    8000453c:	e44e                	sd	s3,8(sp)
    8000453e:	1800                	addi	s0,sp,48
    80004540:	892a                	mv	s2,a0
    80004542:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004544:	0001d497          	auipc	s1,0x1d
    80004548:	fcc48493          	addi	s1,s1,-52 # 80021510 <log>
    8000454c:	00004597          	auipc	a1,0x4
    80004550:	2ec58593          	addi	a1,a1,748 # 80008838 <syscalls+0x208>
    80004554:	8526                	mv	a0,s1
    80004556:	ffffc097          	auipc	ra,0xffffc
    8000455a:	604080e7          	jalr	1540(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    8000455e:	0149a583          	lw	a1,20(s3)
    80004562:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004564:	0109a783          	lw	a5,16(s3)
    80004568:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000456a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000456e:	854a                	mv	a0,s2
    80004570:	fffff097          	auipc	ra,0xfffff
    80004574:	e8a080e7          	jalr	-374(ra) # 800033fa <bread>
  log.lh.n = lh->n;
    80004578:	4d3c                	lw	a5,88(a0)
    8000457a:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000457c:	02f05563          	blez	a5,800045a6 <initlog+0x74>
    80004580:	05c50713          	addi	a4,a0,92
    80004584:	0001d697          	auipc	a3,0x1d
    80004588:	fbc68693          	addi	a3,a3,-68 # 80021540 <log+0x30>
    8000458c:	37fd                	addiw	a5,a5,-1
    8000458e:	1782                	slli	a5,a5,0x20
    80004590:	9381                	srli	a5,a5,0x20
    80004592:	078a                	slli	a5,a5,0x2
    80004594:	06050613          	addi	a2,a0,96
    80004598:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000459a:	4310                	lw	a2,0(a4)
    8000459c:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000459e:	0711                	addi	a4,a4,4
    800045a0:	0691                	addi	a3,a3,4
    800045a2:	fef71ce3          	bne	a4,a5,8000459a <initlog+0x68>
  brelse(buf);
    800045a6:	fffff097          	auipc	ra,0xfffff
    800045aa:	f84080e7          	jalr	-124(ra) # 8000352a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045ae:	4505                	li	a0,1
    800045b0:	00000097          	auipc	ra,0x0
    800045b4:	ebe080e7          	jalr	-322(ra) # 8000446e <install_trans>
  log.lh.n = 0;
    800045b8:	0001d797          	auipc	a5,0x1d
    800045bc:	f807a223          	sw	zero,-124(a5) # 8002153c <log+0x2c>
  write_head(); // clear the log
    800045c0:	00000097          	auipc	ra,0x0
    800045c4:	e34080e7          	jalr	-460(ra) # 800043f4 <write_head>
}
    800045c8:	70a2                	ld	ra,40(sp)
    800045ca:	7402                	ld	s0,32(sp)
    800045cc:	64e2                	ld	s1,24(sp)
    800045ce:	6942                	ld	s2,16(sp)
    800045d0:	69a2                	ld	s3,8(sp)
    800045d2:	6145                	addi	sp,sp,48
    800045d4:	8082                	ret

00000000800045d6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045d6:	1101                	addi	sp,sp,-32
    800045d8:	ec06                	sd	ra,24(sp)
    800045da:	e822                	sd	s0,16(sp)
    800045dc:	e426                	sd	s1,8(sp)
    800045de:	e04a                	sd	s2,0(sp)
    800045e0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045e2:	0001d517          	auipc	a0,0x1d
    800045e6:	f2e50513          	addi	a0,a0,-210 # 80021510 <log>
    800045ea:	ffffc097          	auipc	ra,0xffffc
    800045ee:	600080e7          	jalr	1536(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    800045f2:	0001d497          	auipc	s1,0x1d
    800045f6:	f1e48493          	addi	s1,s1,-226 # 80021510 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045fa:	4979                	li	s2,30
    800045fc:	a039                	j	8000460a <begin_op+0x34>
      sleep(&log, &log.lock);
    800045fe:	85a6                	mv	a1,s1
    80004600:	8526                	mv	a0,s1
    80004602:	ffffe097          	auipc	ra,0xffffe
    80004606:	a68080e7          	jalr	-1432(ra) # 8000206a <sleep>
    if(log.committing){
    8000460a:	50dc                	lw	a5,36(s1)
    8000460c:	fbed                	bnez	a5,800045fe <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000460e:	509c                	lw	a5,32(s1)
    80004610:	0017871b          	addiw	a4,a5,1
    80004614:	0007069b          	sext.w	a3,a4
    80004618:	0027179b          	slliw	a5,a4,0x2
    8000461c:	9fb9                	addw	a5,a5,a4
    8000461e:	0017979b          	slliw	a5,a5,0x1
    80004622:	54d8                	lw	a4,44(s1)
    80004624:	9fb9                	addw	a5,a5,a4
    80004626:	00f95963          	bge	s2,a5,80004638 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000462a:	85a6                	mv	a1,s1
    8000462c:	8526                	mv	a0,s1
    8000462e:	ffffe097          	auipc	ra,0xffffe
    80004632:	a3c080e7          	jalr	-1476(ra) # 8000206a <sleep>
    80004636:	bfd1                	j	8000460a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004638:	0001d517          	auipc	a0,0x1d
    8000463c:	ed850513          	addi	a0,a0,-296 # 80021510 <log>
    80004640:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004642:	ffffc097          	auipc	ra,0xffffc
    80004646:	65c080e7          	jalr	1628(ra) # 80000c9e <release>
      break;
    }
  }
}
    8000464a:	60e2                	ld	ra,24(sp)
    8000464c:	6442                	ld	s0,16(sp)
    8000464e:	64a2                	ld	s1,8(sp)
    80004650:	6902                	ld	s2,0(sp)
    80004652:	6105                	addi	sp,sp,32
    80004654:	8082                	ret

0000000080004656 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004656:	7139                	addi	sp,sp,-64
    80004658:	fc06                	sd	ra,56(sp)
    8000465a:	f822                	sd	s0,48(sp)
    8000465c:	f426                	sd	s1,40(sp)
    8000465e:	f04a                	sd	s2,32(sp)
    80004660:	ec4e                	sd	s3,24(sp)
    80004662:	e852                	sd	s4,16(sp)
    80004664:	e456                	sd	s5,8(sp)
    80004666:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004668:	0001d497          	auipc	s1,0x1d
    8000466c:	ea848493          	addi	s1,s1,-344 # 80021510 <log>
    80004670:	8526                	mv	a0,s1
    80004672:	ffffc097          	auipc	ra,0xffffc
    80004676:	578080e7          	jalr	1400(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    8000467a:	509c                	lw	a5,32(s1)
    8000467c:	37fd                	addiw	a5,a5,-1
    8000467e:	0007891b          	sext.w	s2,a5
    80004682:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004684:	50dc                	lw	a5,36(s1)
    80004686:	efb9                	bnez	a5,800046e4 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004688:	06091663          	bnez	s2,800046f4 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000468c:	0001d497          	auipc	s1,0x1d
    80004690:	e8448493          	addi	s1,s1,-380 # 80021510 <log>
    80004694:	4785                	li	a5,1
    80004696:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004698:	8526                	mv	a0,s1
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	604080e7          	jalr	1540(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046a2:	54dc                	lw	a5,44(s1)
    800046a4:	06f04763          	bgtz	a5,80004712 <end_op+0xbc>
    acquire(&log.lock);
    800046a8:	0001d497          	auipc	s1,0x1d
    800046ac:	e6848493          	addi	s1,s1,-408 # 80021510 <log>
    800046b0:	8526                	mv	a0,s1
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	538080e7          	jalr	1336(ra) # 80000bea <acquire>
    log.committing = 0;
    800046ba:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800046be:	8526                	mv	a0,s1
    800046c0:	ffffe097          	auipc	ra,0xffffe
    800046c4:	a0e080e7          	jalr	-1522(ra) # 800020ce <wakeup>
    release(&log.lock);
    800046c8:	8526                	mv	a0,s1
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	5d4080e7          	jalr	1492(ra) # 80000c9e <release>
}
    800046d2:	70e2                	ld	ra,56(sp)
    800046d4:	7442                	ld	s0,48(sp)
    800046d6:	74a2                	ld	s1,40(sp)
    800046d8:	7902                	ld	s2,32(sp)
    800046da:	69e2                	ld	s3,24(sp)
    800046dc:	6a42                	ld	s4,16(sp)
    800046de:	6aa2                	ld	s5,8(sp)
    800046e0:	6121                	addi	sp,sp,64
    800046e2:	8082                	ret
    panic("log.committing");
    800046e4:	00004517          	auipc	a0,0x4
    800046e8:	15c50513          	addi	a0,a0,348 # 80008840 <syscalls+0x210>
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	e58080e7          	jalr	-424(ra) # 80000544 <panic>
    wakeup(&log);
    800046f4:	0001d497          	auipc	s1,0x1d
    800046f8:	e1c48493          	addi	s1,s1,-484 # 80021510 <log>
    800046fc:	8526                	mv	a0,s1
    800046fe:	ffffe097          	auipc	ra,0xffffe
    80004702:	9d0080e7          	jalr	-1584(ra) # 800020ce <wakeup>
  release(&log.lock);
    80004706:	8526                	mv	a0,s1
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	596080e7          	jalr	1430(ra) # 80000c9e <release>
  if(do_commit){
    80004710:	b7c9                	j	800046d2 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004712:	0001da97          	auipc	s5,0x1d
    80004716:	e2ea8a93          	addi	s5,s5,-466 # 80021540 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000471a:	0001da17          	auipc	s4,0x1d
    8000471e:	df6a0a13          	addi	s4,s4,-522 # 80021510 <log>
    80004722:	018a2583          	lw	a1,24(s4)
    80004726:	012585bb          	addw	a1,a1,s2
    8000472a:	2585                	addiw	a1,a1,1
    8000472c:	028a2503          	lw	a0,40(s4)
    80004730:	fffff097          	auipc	ra,0xfffff
    80004734:	cca080e7          	jalr	-822(ra) # 800033fa <bread>
    80004738:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000473a:	000aa583          	lw	a1,0(s5)
    8000473e:	028a2503          	lw	a0,40(s4)
    80004742:	fffff097          	auipc	ra,0xfffff
    80004746:	cb8080e7          	jalr	-840(ra) # 800033fa <bread>
    8000474a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000474c:	40000613          	li	a2,1024
    80004750:	05850593          	addi	a1,a0,88
    80004754:	05848513          	addi	a0,s1,88
    80004758:	ffffc097          	auipc	ra,0xffffc
    8000475c:	5ee080e7          	jalr	1518(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004760:	8526                	mv	a0,s1
    80004762:	fffff097          	auipc	ra,0xfffff
    80004766:	d8a080e7          	jalr	-630(ra) # 800034ec <bwrite>
    brelse(from);
    8000476a:	854e                	mv	a0,s3
    8000476c:	fffff097          	auipc	ra,0xfffff
    80004770:	dbe080e7          	jalr	-578(ra) # 8000352a <brelse>
    brelse(to);
    80004774:	8526                	mv	a0,s1
    80004776:	fffff097          	auipc	ra,0xfffff
    8000477a:	db4080e7          	jalr	-588(ra) # 8000352a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000477e:	2905                	addiw	s2,s2,1
    80004780:	0a91                	addi	s5,s5,4
    80004782:	02ca2783          	lw	a5,44(s4)
    80004786:	f8f94ee3          	blt	s2,a5,80004722 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000478a:	00000097          	auipc	ra,0x0
    8000478e:	c6a080e7          	jalr	-918(ra) # 800043f4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004792:	4501                	li	a0,0
    80004794:	00000097          	auipc	ra,0x0
    80004798:	cda080e7          	jalr	-806(ra) # 8000446e <install_trans>
    log.lh.n = 0;
    8000479c:	0001d797          	auipc	a5,0x1d
    800047a0:	da07a023          	sw	zero,-608(a5) # 8002153c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800047a4:	00000097          	auipc	ra,0x0
    800047a8:	c50080e7          	jalr	-944(ra) # 800043f4 <write_head>
    800047ac:	bdf5                	j	800046a8 <end_op+0x52>

00000000800047ae <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047ae:	1101                	addi	sp,sp,-32
    800047b0:	ec06                	sd	ra,24(sp)
    800047b2:	e822                	sd	s0,16(sp)
    800047b4:	e426                	sd	s1,8(sp)
    800047b6:	e04a                	sd	s2,0(sp)
    800047b8:	1000                	addi	s0,sp,32
    800047ba:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800047bc:	0001d917          	auipc	s2,0x1d
    800047c0:	d5490913          	addi	s2,s2,-684 # 80021510 <log>
    800047c4:	854a                	mv	a0,s2
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	424080e7          	jalr	1060(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047ce:	02c92603          	lw	a2,44(s2)
    800047d2:	47f5                	li	a5,29
    800047d4:	06c7c563          	blt	a5,a2,8000483e <log_write+0x90>
    800047d8:	0001d797          	auipc	a5,0x1d
    800047dc:	d547a783          	lw	a5,-684(a5) # 8002152c <log+0x1c>
    800047e0:	37fd                	addiw	a5,a5,-1
    800047e2:	04f65e63          	bge	a2,a5,8000483e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047e6:	0001d797          	auipc	a5,0x1d
    800047ea:	d4a7a783          	lw	a5,-694(a5) # 80021530 <log+0x20>
    800047ee:	06f05063          	blez	a5,8000484e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047f2:	4781                	li	a5,0
    800047f4:	06c05563          	blez	a2,8000485e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047f8:	44cc                	lw	a1,12(s1)
    800047fa:	0001d717          	auipc	a4,0x1d
    800047fe:	d4670713          	addi	a4,a4,-698 # 80021540 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004802:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004804:	4314                	lw	a3,0(a4)
    80004806:	04b68c63          	beq	a3,a1,8000485e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000480a:	2785                	addiw	a5,a5,1
    8000480c:	0711                	addi	a4,a4,4
    8000480e:	fef61be3          	bne	a2,a5,80004804 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004812:	0621                	addi	a2,a2,8
    80004814:	060a                	slli	a2,a2,0x2
    80004816:	0001d797          	auipc	a5,0x1d
    8000481a:	cfa78793          	addi	a5,a5,-774 # 80021510 <log>
    8000481e:	963e                	add	a2,a2,a5
    80004820:	44dc                	lw	a5,12(s1)
    80004822:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004824:	8526                	mv	a0,s1
    80004826:	fffff097          	auipc	ra,0xfffff
    8000482a:	da2080e7          	jalr	-606(ra) # 800035c8 <bpin>
    log.lh.n++;
    8000482e:	0001d717          	auipc	a4,0x1d
    80004832:	ce270713          	addi	a4,a4,-798 # 80021510 <log>
    80004836:	575c                	lw	a5,44(a4)
    80004838:	2785                	addiw	a5,a5,1
    8000483a:	d75c                	sw	a5,44(a4)
    8000483c:	a835                	j	80004878 <log_write+0xca>
    panic("too big a transaction");
    8000483e:	00004517          	auipc	a0,0x4
    80004842:	01250513          	addi	a0,a0,18 # 80008850 <syscalls+0x220>
    80004846:	ffffc097          	auipc	ra,0xffffc
    8000484a:	cfe080e7          	jalr	-770(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    8000484e:	00004517          	auipc	a0,0x4
    80004852:	01a50513          	addi	a0,a0,26 # 80008868 <syscalls+0x238>
    80004856:	ffffc097          	auipc	ra,0xffffc
    8000485a:	cee080e7          	jalr	-786(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    8000485e:	00878713          	addi	a4,a5,8
    80004862:	00271693          	slli	a3,a4,0x2
    80004866:	0001d717          	auipc	a4,0x1d
    8000486a:	caa70713          	addi	a4,a4,-854 # 80021510 <log>
    8000486e:	9736                	add	a4,a4,a3
    80004870:	44d4                	lw	a3,12(s1)
    80004872:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004874:	faf608e3          	beq	a2,a5,80004824 <log_write+0x76>
  }
  release(&log.lock);
    80004878:	0001d517          	auipc	a0,0x1d
    8000487c:	c9850513          	addi	a0,a0,-872 # 80021510 <log>
    80004880:	ffffc097          	auipc	ra,0xffffc
    80004884:	41e080e7          	jalr	1054(ra) # 80000c9e <release>
}
    80004888:	60e2                	ld	ra,24(sp)
    8000488a:	6442                	ld	s0,16(sp)
    8000488c:	64a2                	ld	s1,8(sp)
    8000488e:	6902                	ld	s2,0(sp)
    80004890:	6105                	addi	sp,sp,32
    80004892:	8082                	ret

0000000080004894 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004894:	1101                	addi	sp,sp,-32
    80004896:	ec06                	sd	ra,24(sp)
    80004898:	e822                	sd	s0,16(sp)
    8000489a:	e426                	sd	s1,8(sp)
    8000489c:	e04a                	sd	s2,0(sp)
    8000489e:	1000                	addi	s0,sp,32
    800048a0:	84aa                	mv	s1,a0
    800048a2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048a4:	00004597          	auipc	a1,0x4
    800048a8:	fe458593          	addi	a1,a1,-28 # 80008888 <syscalls+0x258>
    800048ac:	0521                	addi	a0,a0,8
    800048ae:	ffffc097          	auipc	ra,0xffffc
    800048b2:	2ac080e7          	jalr	684(ra) # 80000b5a <initlock>
  lk->name = name;
    800048b6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800048ba:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048be:	0204a423          	sw	zero,40(s1)
}
    800048c2:	60e2                	ld	ra,24(sp)
    800048c4:	6442                	ld	s0,16(sp)
    800048c6:	64a2                	ld	s1,8(sp)
    800048c8:	6902                	ld	s2,0(sp)
    800048ca:	6105                	addi	sp,sp,32
    800048cc:	8082                	ret

00000000800048ce <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048ce:	1101                	addi	sp,sp,-32
    800048d0:	ec06                	sd	ra,24(sp)
    800048d2:	e822                	sd	s0,16(sp)
    800048d4:	e426                	sd	s1,8(sp)
    800048d6:	e04a                	sd	s2,0(sp)
    800048d8:	1000                	addi	s0,sp,32
    800048da:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048dc:	00850913          	addi	s2,a0,8
    800048e0:	854a                	mv	a0,s2
    800048e2:	ffffc097          	auipc	ra,0xffffc
    800048e6:	308080e7          	jalr	776(ra) # 80000bea <acquire>
  while (lk->locked) {
    800048ea:	409c                	lw	a5,0(s1)
    800048ec:	cb89                	beqz	a5,800048fe <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048ee:	85ca                	mv	a1,s2
    800048f0:	8526                	mv	a0,s1
    800048f2:	ffffd097          	auipc	ra,0xffffd
    800048f6:	778080e7          	jalr	1912(ra) # 8000206a <sleep>
  while (lk->locked) {
    800048fa:	409c                	lw	a5,0(s1)
    800048fc:	fbed                	bnez	a5,800048ee <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048fe:	4785                	li	a5,1
    80004900:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004902:	ffffd097          	auipc	ra,0xffffd
    80004906:	0c4080e7          	jalr	196(ra) # 800019c6 <myproc>
    8000490a:	591c                	lw	a5,48(a0)
    8000490c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000490e:	854a                	mv	a0,s2
    80004910:	ffffc097          	auipc	ra,0xffffc
    80004914:	38e080e7          	jalr	910(ra) # 80000c9e <release>
}
    80004918:	60e2                	ld	ra,24(sp)
    8000491a:	6442                	ld	s0,16(sp)
    8000491c:	64a2                	ld	s1,8(sp)
    8000491e:	6902                	ld	s2,0(sp)
    80004920:	6105                	addi	sp,sp,32
    80004922:	8082                	ret

0000000080004924 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004924:	1101                	addi	sp,sp,-32
    80004926:	ec06                	sd	ra,24(sp)
    80004928:	e822                	sd	s0,16(sp)
    8000492a:	e426                	sd	s1,8(sp)
    8000492c:	e04a                	sd	s2,0(sp)
    8000492e:	1000                	addi	s0,sp,32
    80004930:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004932:	00850913          	addi	s2,a0,8
    80004936:	854a                	mv	a0,s2
    80004938:	ffffc097          	auipc	ra,0xffffc
    8000493c:	2b2080e7          	jalr	690(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004940:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004944:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004948:	8526                	mv	a0,s1
    8000494a:	ffffd097          	auipc	ra,0xffffd
    8000494e:	784080e7          	jalr	1924(ra) # 800020ce <wakeup>
  release(&lk->lk);
    80004952:	854a                	mv	a0,s2
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	34a080e7          	jalr	842(ra) # 80000c9e <release>
}
    8000495c:	60e2                	ld	ra,24(sp)
    8000495e:	6442                	ld	s0,16(sp)
    80004960:	64a2                	ld	s1,8(sp)
    80004962:	6902                	ld	s2,0(sp)
    80004964:	6105                	addi	sp,sp,32
    80004966:	8082                	ret

0000000080004968 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004968:	7179                	addi	sp,sp,-48
    8000496a:	f406                	sd	ra,40(sp)
    8000496c:	f022                	sd	s0,32(sp)
    8000496e:	ec26                	sd	s1,24(sp)
    80004970:	e84a                	sd	s2,16(sp)
    80004972:	e44e                	sd	s3,8(sp)
    80004974:	1800                	addi	s0,sp,48
    80004976:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004978:	00850913          	addi	s2,a0,8
    8000497c:	854a                	mv	a0,s2
    8000497e:	ffffc097          	auipc	ra,0xffffc
    80004982:	26c080e7          	jalr	620(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004986:	409c                	lw	a5,0(s1)
    80004988:	ef99                	bnez	a5,800049a6 <holdingsleep+0x3e>
    8000498a:	4481                	li	s1,0
  release(&lk->lk);
    8000498c:	854a                	mv	a0,s2
    8000498e:	ffffc097          	auipc	ra,0xffffc
    80004992:	310080e7          	jalr	784(ra) # 80000c9e <release>
  return r;
}
    80004996:	8526                	mv	a0,s1
    80004998:	70a2                	ld	ra,40(sp)
    8000499a:	7402                	ld	s0,32(sp)
    8000499c:	64e2                	ld	s1,24(sp)
    8000499e:	6942                	ld	s2,16(sp)
    800049a0:	69a2                	ld	s3,8(sp)
    800049a2:	6145                	addi	sp,sp,48
    800049a4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800049a6:	0284a983          	lw	s3,40(s1)
    800049aa:	ffffd097          	auipc	ra,0xffffd
    800049ae:	01c080e7          	jalr	28(ra) # 800019c6 <myproc>
    800049b2:	5904                	lw	s1,48(a0)
    800049b4:	413484b3          	sub	s1,s1,s3
    800049b8:	0014b493          	seqz	s1,s1
    800049bc:	bfc1                	j	8000498c <holdingsleep+0x24>

00000000800049be <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049be:	1141                	addi	sp,sp,-16
    800049c0:	e406                	sd	ra,8(sp)
    800049c2:	e022                	sd	s0,0(sp)
    800049c4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049c6:	00004597          	auipc	a1,0x4
    800049ca:	ed258593          	addi	a1,a1,-302 # 80008898 <syscalls+0x268>
    800049ce:	0001d517          	auipc	a0,0x1d
    800049d2:	c8a50513          	addi	a0,a0,-886 # 80021658 <ftable>
    800049d6:	ffffc097          	auipc	ra,0xffffc
    800049da:	184080e7          	jalr	388(ra) # 80000b5a <initlock>
}
    800049de:	60a2                	ld	ra,8(sp)
    800049e0:	6402                	ld	s0,0(sp)
    800049e2:	0141                	addi	sp,sp,16
    800049e4:	8082                	ret

00000000800049e6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049e6:	1101                	addi	sp,sp,-32
    800049e8:	ec06                	sd	ra,24(sp)
    800049ea:	e822                	sd	s0,16(sp)
    800049ec:	e426                	sd	s1,8(sp)
    800049ee:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049f0:	0001d517          	auipc	a0,0x1d
    800049f4:	c6850513          	addi	a0,a0,-920 # 80021658 <ftable>
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	1f2080e7          	jalr	498(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a00:	0001d497          	auipc	s1,0x1d
    80004a04:	c7048493          	addi	s1,s1,-912 # 80021670 <ftable+0x18>
    80004a08:	0001e717          	auipc	a4,0x1e
    80004a0c:	c0870713          	addi	a4,a4,-1016 # 80022610 <disk>
    if(f->ref == 0){
    80004a10:	40dc                	lw	a5,4(s1)
    80004a12:	cf99                	beqz	a5,80004a30 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a14:	02848493          	addi	s1,s1,40
    80004a18:	fee49ce3          	bne	s1,a4,80004a10 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a1c:	0001d517          	auipc	a0,0x1d
    80004a20:	c3c50513          	addi	a0,a0,-964 # 80021658 <ftable>
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	27a080e7          	jalr	634(ra) # 80000c9e <release>
  return 0;
    80004a2c:	4481                	li	s1,0
    80004a2e:	a819                	j	80004a44 <filealloc+0x5e>
      f->ref = 1;
    80004a30:	4785                	li	a5,1
    80004a32:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a34:	0001d517          	auipc	a0,0x1d
    80004a38:	c2450513          	addi	a0,a0,-988 # 80021658 <ftable>
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	262080e7          	jalr	610(ra) # 80000c9e <release>
}
    80004a44:	8526                	mv	a0,s1
    80004a46:	60e2                	ld	ra,24(sp)
    80004a48:	6442                	ld	s0,16(sp)
    80004a4a:	64a2                	ld	s1,8(sp)
    80004a4c:	6105                	addi	sp,sp,32
    80004a4e:	8082                	ret

0000000080004a50 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a50:	1101                	addi	sp,sp,-32
    80004a52:	ec06                	sd	ra,24(sp)
    80004a54:	e822                	sd	s0,16(sp)
    80004a56:	e426                	sd	s1,8(sp)
    80004a58:	1000                	addi	s0,sp,32
    80004a5a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a5c:	0001d517          	auipc	a0,0x1d
    80004a60:	bfc50513          	addi	a0,a0,-1028 # 80021658 <ftable>
    80004a64:	ffffc097          	auipc	ra,0xffffc
    80004a68:	186080e7          	jalr	390(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004a6c:	40dc                	lw	a5,4(s1)
    80004a6e:	02f05263          	blez	a5,80004a92 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a72:	2785                	addiw	a5,a5,1
    80004a74:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a76:	0001d517          	auipc	a0,0x1d
    80004a7a:	be250513          	addi	a0,a0,-1054 # 80021658 <ftable>
    80004a7e:	ffffc097          	auipc	ra,0xffffc
    80004a82:	220080e7          	jalr	544(ra) # 80000c9e <release>
  return f;
}
    80004a86:	8526                	mv	a0,s1
    80004a88:	60e2                	ld	ra,24(sp)
    80004a8a:	6442                	ld	s0,16(sp)
    80004a8c:	64a2                	ld	s1,8(sp)
    80004a8e:	6105                	addi	sp,sp,32
    80004a90:	8082                	ret
    panic("filedup");
    80004a92:	00004517          	auipc	a0,0x4
    80004a96:	e0e50513          	addi	a0,a0,-498 # 800088a0 <syscalls+0x270>
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	aaa080e7          	jalr	-1366(ra) # 80000544 <panic>

0000000080004aa2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004aa2:	7139                	addi	sp,sp,-64
    80004aa4:	fc06                	sd	ra,56(sp)
    80004aa6:	f822                	sd	s0,48(sp)
    80004aa8:	f426                	sd	s1,40(sp)
    80004aaa:	f04a                	sd	s2,32(sp)
    80004aac:	ec4e                	sd	s3,24(sp)
    80004aae:	e852                	sd	s4,16(sp)
    80004ab0:	e456                	sd	s5,8(sp)
    80004ab2:	0080                	addi	s0,sp,64
    80004ab4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ab6:	0001d517          	auipc	a0,0x1d
    80004aba:	ba250513          	addi	a0,a0,-1118 # 80021658 <ftable>
    80004abe:	ffffc097          	auipc	ra,0xffffc
    80004ac2:	12c080e7          	jalr	300(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004ac6:	40dc                	lw	a5,4(s1)
    80004ac8:	06f05163          	blez	a5,80004b2a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004acc:	37fd                	addiw	a5,a5,-1
    80004ace:	0007871b          	sext.w	a4,a5
    80004ad2:	c0dc                	sw	a5,4(s1)
    80004ad4:	06e04363          	bgtz	a4,80004b3a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004ad8:	0004a903          	lw	s2,0(s1)
    80004adc:	0094ca83          	lbu	s5,9(s1)
    80004ae0:	0104ba03          	ld	s4,16(s1)
    80004ae4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004ae8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004aec:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004af0:	0001d517          	auipc	a0,0x1d
    80004af4:	b6850513          	addi	a0,a0,-1176 # 80021658 <ftable>
    80004af8:	ffffc097          	auipc	ra,0xffffc
    80004afc:	1a6080e7          	jalr	422(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004b00:	4785                	li	a5,1
    80004b02:	04f90d63          	beq	s2,a5,80004b5c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b06:	3979                	addiw	s2,s2,-2
    80004b08:	4785                	li	a5,1
    80004b0a:	0527e063          	bltu	a5,s2,80004b4a <fileclose+0xa8>
    begin_op();
    80004b0e:	00000097          	auipc	ra,0x0
    80004b12:	ac8080e7          	jalr	-1336(ra) # 800045d6 <begin_op>
    iput(ff.ip);
    80004b16:	854e                	mv	a0,s3
    80004b18:	fffff097          	auipc	ra,0xfffff
    80004b1c:	2b6080e7          	jalr	694(ra) # 80003dce <iput>
    end_op();
    80004b20:	00000097          	auipc	ra,0x0
    80004b24:	b36080e7          	jalr	-1226(ra) # 80004656 <end_op>
    80004b28:	a00d                	j	80004b4a <fileclose+0xa8>
    panic("fileclose");
    80004b2a:	00004517          	auipc	a0,0x4
    80004b2e:	d7e50513          	addi	a0,a0,-642 # 800088a8 <syscalls+0x278>
    80004b32:	ffffc097          	auipc	ra,0xffffc
    80004b36:	a12080e7          	jalr	-1518(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004b3a:	0001d517          	auipc	a0,0x1d
    80004b3e:	b1e50513          	addi	a0,a0,-1250 # 80021658 <ftable>
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	15c080e7          	jalr	348(ra) # 80000c9e <release>
  }
}
    80004b4a:	70e2                	ld	ra,56(sp)
    80004b4c:	7442                	ld	s0,48(sp)
    80004b4e:	74a2                	ld	s1,40(sp)
    80004b50:	7902                	ld	s2,32(sp)
    80004b52:	69e2                	ld	s3,24(sp)
    80004b54:	6a42                	ld	s4,16(sp)
    80004b56:	6aa2                	ld	s5,8(sp)
    80004b58:	6121                	addi	sp,sp,64
    80004b5a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b5c:	85d6                	mv	a1,s5
    80004b5e:	8552                	mv	a0,s4
    80004b60:	00000097          	auipc	ra,0x0
    80004b64:	34c080e7          	jalr	844(ra) # 80004eac <pipeclose>
    80004b68:	b7cd                	j	80004b4a <fileclose+0xa8>

0000000080004b6a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b6a:	715d                	addi	sp,sp,-80
    80004b6c:	e486                	sd	ra,72(sp)
    80004b6e:	e0a2                	sd	s0,64(sp)
    80004b70:	fc26                	sd	s1,56(sp)
    80004b72:	f84a                	sd	s2,48(sp)
    80004b74:	f44e                	sd	s3,40(sp)
    80004b76:	0880                	addi	s0,sp,80
    80004b78:	84aa                	mv	s1,a0
    80004b7a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b7c:	ffffd097          	auipc	ra,0xffffd
    80004b80:	e4a080e7          	jalr	-438(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b84:	409c                	lw	a5,0(s1)
    80004b86:	37f9                	addiw	a5,a5,-2
    80004b88:	4705                	li	a4,1
    80004b8a:	04f76763          	bltu	a4,a5,80004bd8 <filestat+0x6e>
    80004b8e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b90:	6c88                	ld	a0,24(s1)
    80004b92:	fffff097          	auipc	ra,0xfffff
    80004b96:	082080e7          	jalr	130(ra) # 80003c14 <ilock>
    stati(f->ip, &st);
    80004b9a:	fb840593          	addi	a1,s0,-72
    80004b9e:	6c88                	ld	a0,24(s1)
    80004ba0:	fffff097          	auipc	ra,0xfffff
    80004ba4:	2fe080e7          	jalr	766(ra) # 80003e9e <stati>
    iunlock(f->ip);
    80004ba8:	6c88                	ld	a0,24(s1)
    80004baa:	fffff097          	auipc	ra,0xfffff
    80004bae:	12c080e7          	jalr	300(ra) # 80003cd6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004bb2:	46e1                	li	a3,24
    80004bb4:	fb840613          	addi	a2,s0,-72
    80004bb8:	85ce                	mv	a1,s3
    80004bba:	05093503          	ld	a0,80(s2)
    80004bbe:	ffffd097          	auipc	ra,0xffffd
    80004bc2:	ac6080e7          	jalr	-1338(ra) # 80001684 <copyout>
    80004bc6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004bca:	60a6                	ld	ra,72(sp)
    80004bcc:	6406                	ld	s0,64(sp)
    80004bce:	74e2                	ld	s1,56(sp)
    80004bd0:	7942                	ld	s2,48(sp)
    80004bd2:	79a2                	ld	s3,40(sp)
    80004bd4:	6161                	addi	sp,sp,80
    80004bd6:	8082                	ret
  return -1;
    80004bd8:	557d                	li	a0,-1
    80004bda:	bfc5                	j	80004bca <filestat+0x60>

0000000080004bdc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004bdc:	7179                	addi	sp,sp,-48
    80004bde:	f406                	sd	ra,40(sp)
    80004be0:	f022                	sd	s0,32(sp)
    80004be2:	ec26                	sd	s1,24(sp)
    80004be4:	e84a                	sd	s2,16(sp)
    80004be6:	e44e                	sd	s3,8(sp)
    80004be8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004bea:	00854783          	lbu	a5,8(a0)
    80004bee:	c3d5                	beqz	a5,80004c92 <fileread+0xb6>
    80004bf0:	84aa                	mv	s1,a0
    80004bf2:	89ae                	mv	s3,a1
    80004bf4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bf6:	411c                	lw	a5,0(a0)
    80004bf8:	4705                	li	a4,1
    80004bfa:	04e78963          	beq	a5,a4,80004c4c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bfe:	470d                	li	a4,3
    80004c00:	04e78d63          	beq	a5,a4,80004c5a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c04:	4709                	li	a4,2
    80004c06:	06e79e63          	bne	a5,a4,80004c82 <fileread+0xa6>
    ilock(f->ip);
    80004c0a:	6d08                	ld	a0,24(a0)
    80004c0c:	fffff097          	auipc	ra,0xfffff
    80004c10:	008080e7          	jalr	8(ra) # 80003c14 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c14:	874a                	mv	a4,s2
    80004c16:	5094                	lw	a3,32(s1)
    80004c18:	864e                	mv	a2,s3
    80004c1a:	4585                	li	a1,1
    80004c1c:	6c88                	ld	a0,24(s1)
    80004c1e:	fffff097          	auipc	ra,0xfffff
    80004c22:	2aa080e7          	jalr	682(ra) # 80003ec8 <readi>
    80004c26:	892a                	mv	s2,a0
    80004c28:	00a05563          	blez	a0,80004c32 <fileread+0x56>
      f->off += r;
    80004c2c:	509c                	lw	a5,32(s1)
    80004c2e:	9fa9                	addw	a5,a5,a0
    80004c30:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c32:	6c88                	ld	a0,24(s1)
    80004c34:	fffff097          	auipc	ra,0xfffff
    80004c38:	0a2080e7          	jalr	162(ra) # 80003cd6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c3c:	854a                	mv	a0,s2
    80004c3e:	70a2                	ld	ra,40(sp)
    80004c40:	7402                	ld	s0,32(sp)
    80004c42:	64e2                	ld	s1,24(sp)
    80004c44:	6942                	ld	s2,16(sp)
    80004c46:	69a2                	ld	s3,8(sp)
    80004c48:	6145                	addi	sp,sp,48
    80004c4a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c4c:	6908                	ld	a0,16(a0)
    80004c4e:	00000097          	auipc	ra,0x0
    80004c52:	3ce080e7          	jalr	974(ra) # 8000501c <piperead>
    80004c56:	892a                	mv	s2,a0
    80004c58:	b7d5                	j	80004c3c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c5a:	02451783          	lh	a5,36(a0)
    80004c5e:	03079693          	slli	a3,a5,0x30
    80004c62:	92c1                	srli	a3,a3,0x30
    80004c64:	4725                	li	a4,9
    80004c66:	02d76863          	bltu	a4,a3,80004c96 <fileread+0xba>
    80004c6a:	0792                	slli	a5,a5,0x4
    80004c6c:	0001d717          	auipc	a4,0x1d
    80004c70:	94c70713          	addi	a4,a4,-1716 # 800215b8 <devsw>
    80004c74:	97ba                	add	a5,a5,a4
    80004c76:	639c                	ld	a5,0(a5)
    80004c78:	c38d                	beqz	a5,80004c9a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c7a:	4505                	li	a0,1
    80004c7c:	9782                	jalr	a5
    80004c7e:	892a                	mv	s2,a0
    80004c80:	bf75                	j	80004c3c <fileread+0x60>
    panic("fileread");
    80004c82:	00004517          	auipc	a0,0x4
    80004c86:	c3650513          	addi	a0,a0,-970 # 800088b8 <syscalls+0x288>
    80004c8a:	ffffc097          	auipc	ra,0xffffc
    80004c8e:	8ba080e7          	jalr	-1862(ra) # 80000544 <panic>
    return -1;
    80004c92:	597d                	li	s2,-1
    80004c94:	b765                	j	80004c3c <fileread+0x60>
      return -1;
    80004c96:	597d                	li	s2,-1
    80004c98:	b755                	j	80004c3c <fileread+0x60>
    80004c9a:	597d                	li	s2,-1
    80004c9c:	b745                	j	80004c3c <fileread+0x60>

0000000080004c9e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c9e:	715d                	addi	sp,sp,-80
    80004ca0:	e486                	sd	ra,72(sp)
    80004ca2:	e0a2                	sd	s0,64(sp)
    80004ca4:	fc26                	sd	s1,56(sp)
    80004ca6:	f84a                	sd	s2,48(sp)
    80004ca8:	f44e                	sd	s3,40(sp)
    80004caa:	f052                	sd	s4,32(sp)
    80004cac:	ec56                	sd	s5,24(sp)
    80004cae:	e85a                	sd	s6,16(sp)
    80004cb0:	e45e                	sd	s7,8(sp)
    80004cb2:	e062                	sd	s8,0(sp)
    80004cb4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004cb6:	00954783          	lbu	a5,9(a0)
    80004cba:	10078663          	beqz	a5,80004dc6 <filewrite+0x128>
    80004cbe:	892a                	mv	s2,a0
    80004cc0:	8aae                	mv	s5,a1
    80004cc2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cc4:	411c                	lw	a5,0(a0)
    80004cc6:	4705                	li	a4,1
    80004cc8:	02e78263          	beq	a5,a4,80004cec <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ccc:	470d                	li	a4,3
    80004cce:	02e78663          	beq	a5,a4,80004cfa <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cd2:	4709                	li	a4,2
    80004cd4:	0ee79163          	bne	a5,a4,80004db6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cd8:	0ac05d63          	blez	a2,80004d92 <filewrite+0xf4>
    int i = 0;
    80004cdc:	4981                	li	s3,0
    80004cde:	6b05                	lui	s6,0x1
    80004ce0:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004ce4:	6b85                	lui	s7,0x1
    80004ce6:	c00b8b9b          	addiw	s7,s7,-1024
    80004cea:	a861                	j	80004d82 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004cec:	6908                	ld	a0,16(a0)
    80004cee:	00000097          	auipc	ra,0x0
    80004cf2:	22e080e7          	jalr	558(ra) # 80004f1c <pipewrite>
    80004cf6:	8a2a                	mv	s4,a0
    80004cf8:	a045                	j	80004d98 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cfa:	02451783          	lh	a5,36(a0)
    80004cfe:	03079693          	slli	a3,a5,0x30
    80004d02:	92c1                	srli	a3,a3,0x30
    80004d04:	4725                	li	a4,9
    80004d06:	0cd76263          	bltu	a4,a3,80004dca <filewrite+0x12c>
    80004d0a:	0792                	slli	a5,a5,0x4
    80004d0c:	0001d717          	auipc	a4,0x1d
    80004d10:	8ac70713          	addi	a4,a4,-1876 # 800215b8 <devsw>
    80004d14:	97ba                	add	a5,a5,a4
    80004d16:	679c                	ld	a5,8(a5)
    80004d18:	cbdd                	beqz	a5,80004dce <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d1a:	4505                	li	a0,1
    80004d1c:	9782                	jalr	a5
    80004d1e:	8a2a                	mv	s4,a0
    80004d20:	a8a5                	j	80004d98 <filewrite+0xfa>
    80004d22:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d26:	00000097          	auipc	ra,0x0
    80004d2a:	8b0080e7          	jalr	-1872(ra) # 800045d6 <begin_op>
      ilock(f->ip);
    80004d2e:	01893503          	ld	a0,24(s2)
    80004d32:	fffff097          	auipc	ra,0xfffff
    80004d36:	ee2080e7          	jalr	-286(ra) # 80003c14 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d3a:	8762                	mv	a4,s8
    80004d3c:	02092683          	lw	a3,32(s2)
    80004d40:	01598633          	add	a2,s3,s5
    80004d44:	4585                	li	a1,1
    80004d46:	01893503          	ld	a0,24(s2)
    80004d4a:	fffff097          	auipc	ra,0xfffff
    80004d4e:	276080e7          	jalr	630(ra) # 80003fc0 <writei>
    80004d52:	84aa                	mv	s1,a0
    80004d54:	00a05763          	blez	a0,80004d62 <filewrite+0xc4>
        f->off += r;
    80004d58:	02092783          	lw	a5,32(s2)
    80004d5c:	9fa9                	addw	a5,a5,a0
    80004d5e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d62:	01893503          	ld	a0,24(s2)
    80004d66:	fffff097          	auipc	ra,0xfffff
    80004d6a:	f70080e7          	jalr	-144(ra) # 80003cd6 <iunlock>
      end_op();
    80004d6e:	00000097          	auipc	ra,0x0
    80004d72:	8e8080e7          	jalr	-1816(ra) # 80004656 <end_op>

      if(r != n1){
    80004d76:	009c1f63          	bne	s8,s1,80004d94 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d7a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d7e:	0149db63          	bge	s3,s4,80004d94 <filewrite+0xf6>
      int n1 = n - i;
    80004d82:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004d86:	84be                	mv	s1,a5
    80004d88:	2781                	sext.w	a5,a5
    80004d8a:	f8fb5ce3          	bge	s6,a5,80004d22 <filewrite+0x84>
    80004d8e:	84de                	mv	s1,s7
    80004d90:	bf49                	j	80004d22 <filewrite+0x84>
    int i = 0;
    80004d92:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d94:	013a1f63          	bne	s4,s3,80004db2 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d98:	8552                	mv	a0,s4
    80004d9a:	60a6                	ld	ra,72(sp)
    80004d9c:	6406                	ld	s0,64(sp)
    80004d9e:	74e2                	ld	s1,56(sp)
    80004da0:	7942                	ld	s2,48(sp)
    80004da2:	79a2                	ld	s3,40(sp)
    80004da4:	7a02                	ld	s4,32(sp)
    80004da6:	6ae2                	ld	s5,24(sp)
    80004da8:	6b42                	ld	s6,16(sp)
    80004daa:	6ba2                	ld	s7,8(sp)
    80004dac:	6c02                	ld	s8,0(sp)
    80004dae:	6161                	addi	sp,sp,80
    80004db0:	8082                	ret
    ret = (i == n ? n : -1);
    80004db2:	5a7d                	li	s4,-1
    80004db4:	b7d5                	j	80004d98 <filewrite+0xfa>
    panic("filewrite");
    80004db6:	00004517          	auipc	a0,0x4
    80004dba:	b1250513          	addi	a0,a0,-1262 # 800088c8 <syscalls+0x298>
    80004dbe:	ffffb097          	auipc	ra,0xffffb
    80004dc2:	786080e7          	jalr	1926(ra) # 80000544 <panic>
    return -1;
    80004dc6:	5a7d                	li	s4,-1
    80004dc8:	bfc1                	j	80004d98 <filewrite+0xfa>
      return -1;
    80004dca:	5a7d                	li	s4,-1
    80004dcc:	b7f1                	j	80004d98 <filewrite+0xfa>
    80004dce:	5a7d                	li	s4,-1
    80004dd0:	b7e1                	j	80004d98 <filewrite+0xfa>

0000000080004dd2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004dd2:	7179                	addi	sp,sp,-48
    80004dd4:	f406                	sd	ra,40(sp)
    80004dd6:	f022                	sd	s0,32(sp)
    80004dd8:	ec26                	sd	s1,24(sp)
    80004dda:	e84a                	sd	s2,16(sp)
    80004ddc:	e44e                	sd	s3,8(sp)
    80004dde:	e052                	sd	s4,0(sp)
    80004de0:	1800                	addi	s0,sp,48
    80004de2:	84aa                	mv	s1,a0
    80004de4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004de6:	0005b023          	sd	zero,0(a1)
    80004dea:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004dee:	00000097          	auipc	ra,0x0
    80004df2:	bf8080e7          	jalr	-1032(ra) # 800049e6 <filealloc>
    80004df6:	e088                	sd	a0,0(s1)
    80004df8:	c551                	beqz	a0,80004e84 <pipealloc+0xb2>
    80004dfa:	00000097          	auipc	ra,0x0
    80004dfe:	bec080e7          	jalr	-1044(ra) # 800049e6 <filealloc>
    80004e02:	00aa3023          	sd	a0,0(s4)
    80004e06:	c92d                	beqz	a0,80004e78 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e08:	ffffc097          	auipc	ra,0xffffc
    80004e0c:	cf2080e7          	jalr	-782(ra) # 80000afa <kalloc>
    80004e10:	892a                	mv	s2,a0
    80004e12:	c125                	beqz	a0,80004e72 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e14:	4985                	li	s3,1
    80004e16:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e1a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e1e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e22:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e26:	00004597          	auipc	a1,0x4
    80004e2a:	ab258593          	addi	a1,a1,-1358 # 800088d8 <syscalls+0x2a8>
    80004e2e:	ffffc097          	auipc	ra,0xffffc
    80004e32:	d2c080e7          	jalr	-724(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004e36:	609c                	ld	a5,0(s1)
    80004e38:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e3c:	609c                	ld	a5,0(s1)
    80004e3e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e42:	609c                	ld	a5,0(s1)
    80004e44:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e48:	609c                	ld	a5,0(s1)
    80004e4a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e4e:	000a3783          	ld	a5,0(s4)
    80004e52:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e56:	000a3783          	ld	a5,0(s4)
    80004e5a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e5e:	000a3783          	ld	a5,0(s4)
    80004e62:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e66:	000a3783          	ld	a5,0(s4)
    80004e6a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e6e:	4501                	li	a0,0
    80004e70:	a025                	j	80004e98 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e72:	6088                	ld	a0,0(s1)
    80004e74:	e501                	bnez	a0,80004e7c <pipealloc+0xaa>
    80004e76:	a039                	j	80004e84 <pipealloc+0xb2>
    80004e78:	6088                	ld	a0,0(s1)
    80004e7a:	c51d                	beqz	a0,80004ea8 <pipealloc+0xd6>
    fileclose(*f0);
    80004e7c:	00000097          	auipc	ra,0x0
    80004e80:	c26080e7          	jalr	-986(ra) # 80004aa2 <fileclose>
  if(*f1)
    80004e84:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e88:	557d                	li	a0,-1
  if(*f1)
    80004e8a:	c799                	beqz	a5,80004e98 <pipealloc+0xc6>
    fileclose(*f1);
    80004e8c:	853e                	mv	a0,a5
    80004e8e:	00000097          	auipc	ra,0x0
    80004e92:	c14080e7          	jalr	-1004(ra) # 80004aa2 <fileclose>
  return -1;
    80004e96:	557d                	li	a0,-1
}
    80004e98:	70a2                	ld	ra,40(sp)
    80004e9a:	7402                	ld	s0,32(sp)
    80004e9c:	64e2                	ld	s1,24(sp)
    80004e9e:	6942                	ld	s2,16(sp)
    80004ea0:	69a2                	ld	s3,8(sp)
    80004ea2:	6a02                	ld	s4,0(sp)
    80004ea4:	6145                	addi	sp,sp,48
    80004ea6:	8082                	ret
  return -1;
    80004ea8:	557d                	li	a0,-1
    80004eaa:	b7fd                	j	80004e98 <pipealloc+0xc6>

0000000080004eac <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004eac:	1101                	addi	sp,sp,-32
    80004eae:	ec06                	sd	ra,24(sp)
    80004eb0:	e822                	sd	s0,16(sp)
    80004eb2:	e426                	sd	s1,8(sp)
    80004eb4:	e04a                	sd	s2,0(sp)
    80004eb6:	1000                	addi	s0,sp,32
    80004eb8:	84aa                	mv	s1,a0
    80004eba:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ebc:	ffffc097          	auipc	ra,0xffffc
    80004ec0:	d2e080e7          	jalr	-722(ra) # 80000bea <acquire>
  if(writable){
    80004ec4:	02090d63          	beqz	s2,80004efe <pipeclose+0x52>
    pi->writeopen = 0;
    80004ec8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ecc:	21848513          	addi	a0,s1,536
    80004ed0:	ffffd097          	auipc	ra,0xffffd
    80004ed4:	1fe080e7          	jalr	510(ra) # 800020ce <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ed8:	2204b783          	ld	a5,544(s1)
    80004edc:	eb95                	bnez	a5,80004f10 <pipeclose+0x64>
    release(&pi->lock);
    80004ede:	8526                	mv	a0,s1
    80004ee0:	ffffc097          	auipc	ra,0xffffc
    80004ee4:	dbe080e7          	jalr	-578(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004ee8:	8526                	mv	a0,s1
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	b14080e7          	jalr	-1260(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004ef2:	60e2                	ld	ra,24(sp)
    80004ef4:	6442                	ld	s0,16(sp)
    80004ef6:	64a2                	ld	s1,8(sp)
    80004ef8:	6902                	ld	s2,0(sp)
    80004efa:	6105                	addi	sp,sp,32
    80004efc:	8082                	ret
    pi->readopen = 0;
    80004efe:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f02:	21c48513          	addi	a0,s1,540
    80004f06:	ffffd097          	auipc	ra,0xffffd
    80004f0a:	1c8080e7          	jalr	456(ra) # 800020ce <wakeup>
    80004f0e:	b7e9                	j	80004ed8 <pipeclose+0x2c>
    release(&pi->lock);
    80004f10:	8526                	mv	a0,s1
    80004f12:	ffffc097          	auipc	ra,0xffffc
    80004f16:	d8c080e7          	jalr	-628(ra) # 80000c9e <release>
}
    80004f1a:	bfe1                	j	80004ef2 <pipeclose+0x46>

0000000080004f1c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f1c:	7159                	addi	sp,sp,-112
    80004f1e:	f486                	sd	ra,104(sp)
    80004f20:	f0a2                	sd	s0,96(sp)
    80004f22:	eca6                	sd	s1,88(sp)
    80004f24:	e8ca                	sd	s2,80(sp)
    80004f26:	e4ce                	sd	s3,72(sp)
    80004f28:	e0d2                	sd	s4,64(sp)
    80004f2a:	fc56                	sd	s5,56(sp)
    80004f2c:	f85a                	sd	s6,48(sp)
    80004f2e:	f45e                	sd	s7,40(sp)
    80004f30:	f062                	sd	s8,32(sp)
    80004f32:	ec66                	sd	s9,24(sp)
    80004f34:	1880                	addi	s0,sp,112
    80004f36:	84aa                	mv	s1,a0
    80004f38:	8aae                	mv	s5,a1
    80004f3a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f3c:	ffffd097          	auipc	ra,0xffffd
    80004f40:	a8a080e7          	jalr	-1398(ra) # 800019c6 <myproc>
    80004f44:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f46:	8526                	mv	a0,s1
    80004f48:	ffffc097          	auipc	ra,0xffffc
    80004f4c:	ca2080e7          	jalr	-862(ra) # 80000bea <acquire>
  while(i < n){
    80004f50:	0d405463          	blez	s4,80005018 <pipewrite+0xfc>
    80004f54:	8ba6                	mv	s7,s1
  int i = 0;
    80004f56:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f58:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f5a:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f5e:	21c48c13          	addi	s8,s1,540
    80004f62:	a08d                	j	80004fc4 <pipewrite+0xa8>
      release(&pi->lock);
    80004f64:	8526                	mv	a0,s1
    80004f66:	ffffc097          	auipc	ra,0xffffc
    80004f6a:	d38080e7          	jalr	-712(ra) # 80000c9e <release>
      return -1;
    80004f6e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f70:	854a                	mv	a0,s2
    80004f72:	70a6                	ld	ra,104(sp)
    80004f74:	7406                	ld	s0,96(sp)
    80004f76:	64e6                	ld	s1,88(sp)
    80004f78:	6946                	ld	s2,80(sp)
    80004f7a:	69a6                	ld	s3,72(sp)
    80004f7c:	6a06                	ld	s4,64(sp)
    80004f7e:	7ae2                	ld	s5,56(sp)
    80004f80:	7b42                	ld	s6,48(sp)
    80004f82:	7ba2                	ld	s7,40(sp)
    80004f84:	7c02                	ld	s8,32(sp)
    80004f86:	6ce2                	ld	s9,24(sp)
    80004f88:	6165                	addi	sp,sp,112
    80004f8a:	8082                	ret
      wakeup(&pi->nread);
    80004f8c:	8566                	mv	a0,s9
    80004f8e:	ffffd097          	auipc	ra,0xffffd
    80004f92:	140080e7          	jalr	320(ra) # 800020ce <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f96:	85de                	mv	a1,s7
    80004f98:	8562                	mv	a0,s8
    80004f9a:	ffffd097          	auipc	ra,0xffffd
    80004f9e:	0d0080e7          	jalr	208(ra) # 8000206a <sleep>
    80004fa2:	a839                	j	80004fc0 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fa4:	21c4a783          	lw	a5,540(s1)
    80004fa8:	0017871b          	addiw	a4,a5,1
    80004fac:	20e4ae23          	sw	a4,540(s1)
    80004fb0:	1ff7f793          	andi	a5,a5,511
    80004fb4:	97a6                	add	a5,a5,s1
    80004fb6:	f9f44703          	lbu	a4,-97(s0)
    80004fba:	00e78c23          	sb	a4,24(a5)
      i++;
    80004fbe:	2905                	addiw	s2,s2,1
  while(i < n){
    80004fc0:	05495063          	bge	s2,s4,80005000 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004fc4:	2204a783          	lw	a5,544(s1)
    80004fc8:	dfd1                	beqz	a5,80004f64 <pipewrite+0x48>
    80004fca:	854e                	mv	a0,s3
    80004fcc:	ffffd097          	auipc	ra,0xffffd
    80004fd0:	3c0080e7          	jalr	960(ra) # 8000238c <killed>
    80004fd4:	f941                	bnez	a0,80004f64 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004fd6:	2184a783          	lw	a5,536(s1)
    80004fda:	21c4a703          	lw	a4,540(s1)
    80004fde:	2007879b          	addiw	a5,a5,512
    80004fe2:	faf705e3          	beq	a4,a5,80004f8c <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fe6:	4685                	li	a3,1
    80004fe8:	01590633          	add	a2,s2,s5
    80004fec:	f9f40593          	addi	a1,s0,-97
    80004ff0:	0509b503          	ld	a0,80(s3)
    80004ff4:	ffffc097          	auipc	ra,0xffffc
    80004ff8:	71c080e7          	jalr	1820(ra) # 80001710 <copyin>
    80004ffc:	fb6514e3          	bne	a0,s6,80004fa4 <pipewrite+0x88>
  wakeup(&pi->nread);
    80005000:	21848513          	addi	a0,s1,536
    80005004:	ffffd097          	auipc	ra,0xffffd
    80005008:	0ca080e7          	jalr	202(ra) # 800020ce <wakeup>
  release(&pi->lock);
    8000500c:	8526                	mv	a0,s1
    8000500e:	ffffc097          	auipc	ra,0xffffc
    80005012:	c90080e7          	jalr	-880(ra) # 80000c9e <release>
  return i;
    80005016:	bfa9                	j	80004f70 <pipewrite+0x54>
  int i = 0;
    80005018:	4901                	li	s2,0
    8000501a:	b7dd                	j	80005000 <pipewrite+0xe4>

000000008000501c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000501c:	715d                	addi	sp,sp,-80
    8000501e:	e486                	sd	ra,72(sp)
    80005020:	e0a2                	sd	s0,64(sp)
    80005022:	fc26                	sd	s1,56(sp)
    80005024:	f84a                	sd	s2,48(sp)
    80005026:	f44e                	sd	s3,40(sp)
    80005028:	f052                	sd	s4,32(sp)
    8000502a:	ec56                	sd	s5,24(sp)
    8000502c:	e85a                	sd	s6,16(sp)
    8000502e:	0880                	addi	s0,sp,80
    80005030:	84aa                	mv	s1,a0
    80005032:	892e                	mv	s2,a1
    80005034:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005036:	ffffd097          	auipc	ra,0xffffd
    8000503a:	990080e7          	jalr	-1648(ra) # 800019c6 <myproc>
    8000503e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005040:	8b26                	mv	s6,s1
    80005042:	8526                	mv	a0,s1
    80005044:	ffffc097          	auipc	ra,0xffffc
    80005048:	ba6080e7          	jalr	-1114(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000504c:	2184a703          	lw	a4,536(s1)
    80005050:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005054:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005058:	02f71763          	bne	a4,a5,80005086 <piperead+0x6a>
    8000505c:	2244a783          	lw	a5,548(s1)
    80005060:	c39d                	beqz	a5,80005086 <piperead+0x6a>
    if(killed(pr)){
    80005062:	8552                	mv	a0,s4
    80005064:	ffffd097          	auipc	ra,0xffffd
    80005068:	328080e7          	jalr	808(ra) # 8000238c <killed>
    8000506c:	e941                	bnez	a0,800050fc <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000506e:	85da                	mv	a1,s6
    80005070:	854e                	mv	a0,s3
    80005072:	ffffd097          	auipc	ra,0xffffd
    80005076:	ff8080e7          	jalr	-8(ra) # 8000206a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000507a:	2184a703          	lw	a4,536(s1)
    8000507e:	21c4a783          	lw	a5,540(s1)
    80005082:	fcf70de3          	beq	a4,a5,8000505c <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005086:	09505263          	blez	s5,8000510a <piperead+0xee>
    8000508a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000508c:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000508e:	2184a783          	lw	a5,536(s1)
    80005092:	21c4a703          	lw	a4,540(s1)
    80005096:	02f70d63          	beq	a4,a5,800050d0 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000509a:	0017871b          	addiw	a4,a5,1
    8000509e:	20e4ac23          	sw	a4,536(s1)
    800050a2:	1ff7f793          	andi	a5,a5,511
    800050a6:	97a6                	add	a5,a5,s1
    800050a8:	0187c783          	lbu	a5,24(a5)
    800050ac:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050b0:	4685                	li	a3,1
    800050b2:	fbf40613          	addi	a2,s0,-65
    800050b6:	85ca                	mv	a1,s2
    800050b8:	050a3503          	ld	a0,80(s4)
    800050bc:	ffffc097          	auipc	ra,0xffffc
    800050c0:	5c8080e7          	jalr	1480(ra) # 80001684 <copyout>
    800050c4:	01650663          	beq	a0,s6,800050d0 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050c8:	2985                	addiw	s3,s3,1
    800050ca:	0905                	addi	s2,s2,1
    800050cc:	fd3a91e3          	bne	s5,s3,8000508e <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050d0:	21c48513          	addi	a0,s1,540
    800050d4:	ffffd097          	auipc	ra,0xffffd
    800050d8:	ffa080e7          	jalr	-6(ra) # 800020ce <wakeup>
  release(&pi->lock);
    800050dc:	8526                	mv	a0,s1
    800050de:	ffffc097          	auipc	ra,0xffffc
    800050e2:	bc0080e7          	jalr	-1088(ra) # 80000c9e <release>
  return i;
}
    800050e6:	854e                	mv	a0,s3
    800050e8:	60a6                	ld	ra,72(sp)
    800050ea:	6406                	ld	s0,64(sp)
    800050ec:	74e2                	ld	s1,56(sp)
    800050ee:	7942                	ld	s2,48(sp)
    800050f0:	79a2                	ld	s3,40(sp)
    800050f2:	7a02                	ld	s4,32(sp)
    800050f4:	6ae2                	ld	s5,24(sp)
    800050f6:	6b42                	ld	s6,16(sp)
    800050f8:	6161                	addi	sp,sp,80
    800050fa:	8082                	ret
      release(&pi->lock);
    800050fc:	8526                	mv	a0,s1
    800050fe:	ffffc097          	auipc	ra,0xffffc
    80005102:	ba0080e7          	jalr	-1120(ra) # 80000c9e <release>
      return -1;
    80005106:	59fd                	li	s3,-1
    80005108:	bff9                	j	800050e6 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000510a:	4981                	li	s3,0
    8000510c:	b7d1                	j	800050d0 <piperead+0xb4>

000000008000510e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000510e:	1141                	addi	sp,sp,-16
    80005110:	e422                	sd	s0,8(sp)
    80005112:	0800                	addi	s0,sp,16
    80005114:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005116:	8905                	andi	a0,a0,1
    80005118:	c111                	beqz	a0,8000511c <flags2perm+0xe>
      perm = PTE_X;
    8000511a:	4521                	li	a0,8
    if(flags & 0x2)
    8000511c:	8b89                	andi	a5,a5,2
    8000511e:	c399                	beqz	a5,80005124 <flags2perm+0x16>
      perm |= PTE_W;
    80005120:	00456513          	ori	a0,a0,4
    return perm;
}
    80005124:	6422                	ld	s0,8(sp)
    80005126:	0141                	addi	sp,sp,16
    80005128:	8082                	ret

000000008000512a <exec>:

int
exec(char *path, char **argv)
{
    8000512a:	df010113          	addi	sp,sp,-528
    8000512e:	20113423          	sd	ra,520(sp)
    80005132:	20813023          	sd	s0,512(sp)
    80005136:	ffa6                	sd	s1,504(sp)
    80005138:	fbca                	sd	s2,496(sp)
    8000513a:	f7ce                	sd	s3,488(sp)
    8000513c:	f3d2                	sd	s4,480(sp)
    8000513e:	efd6                	sd	s5,472(sp)
    80005140:	ebda                	sd	s6,464(sp)
    80005142:	e7de                	sd	s7,456(sp)
    80005144:	e3e2                	sd	s8,448(sp)
    80005146:	ff66                	sd	s9,440(sp)
    80005148:	fb6a                	sd	s10,432(sp)
    8000514a:	f76e                	sd	s11,424(sp)
    8000514c:	0c00                	addi	s0,sp,528
    8000514e:	84aa                	mv	s1,a0
    80005150:	dea43c23          	sd	a0,-520(s0)
    80005154:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005158:	ffffd097          	auipc	ra,0xffffd
    8000515c:	86e080e7          	jalr	-1938(ra) # 800019c6 <myproc>
    80005160:	892a                	mv	s2,a0

  begin_op();
    80005162:	fffff097          	auipc	ra,0xfffff
    80005166:	474080e7          	jalr	1140(ra) # 800045d6 <begin_op>

  if((ip = namei(path)) == 0){
    8000516a:	8526                	mv	a0,s1
    8000516c:	fffff097          	auipc	ra,0xfffff
    80005170:	24e080e7          	jalr	590(ra) # 800043ba <namei>
    80005174:	c92d                	beqz	a0,800051e6 <exec+0xbc>
    80005176:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005178:	fffff097          	auipc	ra,0xfffff
    8000517c:	a9c080e7          	jalr	-1380(ra) # 80003c14 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005180:	04000713          	li	a4,64
    80005184:	4681                	li	a3,0
    80005186:	e5040613          	addi	a2,s0,-432
    8000518a:	4581                	li	a1,0
    8000518c:	8526                	mv	a0,s1
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	d3a080e7          	jalr	-710(ra) # 80003ec8 <readi>
    80005196:	04000793          	li	a5,64
    8000519a:	00f51a63          	bne	a0,a5,800051ae <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000519e:	e5042703          	lw	a4,-432(s0)
    800051a2:	464c47b7          	lui	a5,0x464c4
    800051a6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051aa:	04f70463          	beq	a4,a5,800051f2 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051ae:	8526                	mv	a0,s1
    800051b0:	fffff097          	auipc	ra,0xfffff
    800051b4:	cc6080e7          	jalr	-826(ra) # 80003e76 <iunlockput>
    end_op();
    800051b8:	fffff097          	auipc	ra,0xfffff
    800051bc:	49e080e7          	jalr	1182(ra) # 80004656 <end_op>
  }
  return -1;
    800051c0:	557d                	li	a0,-1
}
    800051c2:	20813083          	ld	ra,520(sp)
    800051c6:	20013403          	ld	s0,512(sp)
    800051ca:	74fe                	ld	s1,504(sp)
    800051cc:	795e                	ld	s2,496(sp)
    800051ce:	79be                	ld	s3,488(sp)
    800051d0:	7a1e                	ld	s4,480(sp)
    800051d2:	6afe                	ld	s5,472(sp)
    800051d4:	6b5e                	ld	s6,464(sp)
    800051d6:	6bbe                	ld	s7,456(sp)
    800051d8:	6c1e                	ld	s8,448(sp)
    800051da:	7cfa                	ld	s9,440(sp)
    800051dc:	7d5a                	ld	s10,432(sp)
    800051de:	7dba                	ld	s11,424(sp)
    800051e0:	21010113          	addi	sp,sp,528
    800051e4:	8082                	ret
    end_op();
    800051e6:	fffff097          	auipc	ra,0xfffff
    800051ea:	470080e7          	jalr	1136(ra) # 80004656 <end_op>
    return -1;
    800051ee:	557d                	li	a0,-1
    800051f0:	bfc9                	j	800051c2 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800051f2:	854a                	mv	a0,s2
    800051f4:	ffffd097          	auipc	ra,0xffffd
    800051f8:	896080e7          	jalr	-1898(ra) # 80001a8a <proc_pagetable>
    800051fc:	8baa                	mv	s7,a0
    800051fe:	d945                	beqz	a0,800051ae <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005200:	e7042983          	lw	s3,-400(s0)
    80005204:	e8845783          	lhu	a5,-376(s0)
    80005208:	c7ad                	beqz	a5,80005272 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000520a:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000520c:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    8000520e:	6c85                	lui	s9,0x1
    80005210:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005214:	def43823          	sd	a5,-528(s0)
    80005218:	ac0d                	j	8000544a <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000521a:	00003517          	auipc	a0,0x3
    8000521e:	6c650513          	addi	a0,a0,1734 # 800088e0 <syscalls+0x2b0>
    80005222:	ffffb097          	auipc	ra,0xffffb
    80005226:	322080e7          	jalr	802(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000522a:	8756                	mv	a4,s5
    8000522c:	012d86bb          	addw	a3,s11,s2
    80005230:	4581                	li	a1,0
    80005232:	8526                	mv	a0,s1
    80005234:	fffff097          	auipc	ra,0xfffff
    80005238:	c94080e7          	jalr	-876(ra) # 80003ec8 <readi>
    8000523c:	2501                	sext.w	a0,a0
    8000523e:	1aaa9a63          	bne	s5,a0,800053f2 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005242:	6785                	lui	a5,0x1
    80005244:	0127893b          	addw	s2,a5,s2
    80005248:	77fd                	lui	a5,0xfffff
    8000524a:	01478a3b          	addw	s4,a5,s4
    8000524e:	1f897563          	bgeu	s2,s8,80005438 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005252:	02091593          	slli	a1,s2,0x20
    80005256:	9181                	srli	a1,a1,0x20
    80005258:	95ea                	add	a1,a1,s10
    8000525a:	855e                	mv	a0,s7
    8000525c:	ffffc097          	auipc	ra,0xffffc
    80005260:	e1c080e7          	jalr	-484(ra) # 80001078 <walkaddr>
    80005264:	862a                	mv	a2,a0
    if(pa == 0)
    80005266:	d955                	beqz	a0,8000521a <exec+0xf0>
      n = PGSIZE;
    80005268:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    8000526a:	fd9a70e3          	bgeu	s4,s9,8000522a <exec+0x100>
      n = sz - i;
    8000526e:	8ad2                	mv	s5,s4
    80005270:	bf6d                	j	8000522a <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005272:	4a01                	li	s4,0
  iunlockput(ip);
    80005274:	8526                	mv	a0,s1
    80005276:	fffff097          	auipc	ra,0xfffff
    8000527a:	c00080e7          	jalr	-1024(ra) # 80003e76 <iunlockput>
  end_op();
    8000527e:	fffff097          	auipc	ra,0xfffff
    80005282:	3d8080e7          	jalr	984(ra) # 80004656 <end_op>
  p = myproc();
    80005286:	ffffc097          	auipc	ra,0xffffc
    8000528a:	740080e7          	jalr	1856(ra) # 800019c6 <myproc>
    8000528e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005290:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005294:	6785                	lui	a5,0x1
    80005296:	17fd                	addi	a5,a5,-1
    80005298:	9a3e                	add	s4,s4,a5
    8000529a:	757d                	lui	a0,0xfffff
    8000529c:	00aa77b3          	and	a5,s4,a0
    800052a0:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052a4:	4691                	li	a3,4
    800052a6:	6609                	lui	a2,0x2
    800052a8:	963e                	add	a2,a2,a5
    800052aa:	85be                	mv	a1,a5
    800052ac:	855e                	mv	a0,s7
    800052ae:	ffffc097          	auipc	ra,0xffffc
    800052b2:	17e080e7          	jalr	382(ra) # 8000142c <uvmalloc>
    800052b6:	8b2a                	mv	s6,a0
  ip = 0;
    800052b8:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052ba:	12050c63          	beqz	a0,800053f2 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052be:	75f9                	lui	a1,0xffffe
    800052c0:	95aa                	add	a1,a1,a0
    800052c2:	855e                	mv	a0,s7
    800052c4:	ffffc097          	auipc	ra,0xffffc
    800052c8:	38e080e7          	jalr	910(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    800052cc:	7c7d                	lui	s8,0xfffff
    800052ce:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800052d0:	e0043783          	ld	a5,-512(s0)
    800052d4:	6388                	ld	a0,0(a5)
    800052d6:	c535                	beqz	a0,80005342 <exec+0x218>
    800052d8:	e9040993          	addi	s3,s0,-368
    800052dc:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800052e0:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800052e2:	ffffc097          	auipc	ra,0xffffc
    800052e6:	b88080e7          	jalr	-1144(ra) # 80000e6a <strlen>
    800052ea:	2505                	addiw	a0,a0,1
    800052ec:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052f0:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800052f4:	13896663          	bltu	s2,s8,80005420 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052f8:	e0043d83          	ld	s11,-512(s0)
    800052fc:	000dba03          	ld	s4,0(s11)
    80005300:	8552                	mv	a0,s4
    80005302:	ffffc097          	auipc	ra,0xffffc
    80005306:	b68080e7          	jalr	-1176(ra) # 80000e6a <strlen>
    8000530a:	0015069b          	addiw	a3,a0,1
    8000530e:	8652                	mv	a2,s4
    80005310:	85ca                	mv	a1,s2
    80005312:	855e                	mv	a0,s7
    80005314:	ffffc097          	auipc	ra,0xffffc
    80005318:	370080e7          	jalr	880(ra) # 80001684 <copyout>
    8000531c:	10054663          	bltz	a0,80005428 <exec+0x2fe>
    ustack[argc] = sp;
    80005320:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005324:	0485                	addi	s1,s1,1
    80005326:	008d8793          	addi	a5,s11,8
    8000532a:	e0f43023          	sd	a5,-512(s0)
    8000532e:	008db503          	ld	a0,8(s11)
    80005332:	c911                	beqz	a0,80005346 <exec+0x21c>
    if(argc >= MAXARG)
    80005334:	09a1                	addi	s3,s3,8
    80005336:	fb3c96e3          	bne	s9,s3,800052e2 <exec+0x1b8>
  sz = sz1;
    8000533a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000533e:	4481                	li	s1,0
    80005340:	a84d                	j	800053f2 <exec+0x2c8>
  sp = sz;
    80005342:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005344:	4481                	li	s1,0
  ustack[argc] = 0;
    80005346:	00349793          	slli	a5,s1,0x3
    8000534a:	f9040713          	addi	a4,s0,-112
    8000534e:	97ba                	add	a5,a5,a4
    80005350:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005354:	00148693          	addi	a3,s1,1
    80005358:	068e                	slli	a3,a3,0x3
    8000535a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000535e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005362:	01897663          	bgeu	s2,s8,8000536e <exec+0x244>
  sz = sz1;
    80005366:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000536a:	4481                	li	s1,0
    8000536c:	a059                	j	800053f2 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000536e:	e9040613          	addi	a2,s0,-368
    80005372:	85ca                	mv	a1,s2
    80005374:	855e                	mv	a0,s7
    80005376:	ffffc097          	auipc	ra,0xffffc
    8000537a:	30e080e7          	jalr	782(ra) # 80001684 <copyout>
    8000537e:	0a054963          	bltz	a0,80005430 <exec+0x306>
  p->trapframe->a1 = sp;
    80005382:	058ab783          	ld	a5,88(s5)
    80005386:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000538a:	df843783          	ld	a5,-520(s0)
    8000538e:	0007c703          	lbu	a4,0(a5)
    80005392:	cf11                	beqz	a4,800053ae <exec+0x284>
    80005394:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005396:	02f00693          	li	a3,47
    8000539a:	a039                	j	800053a8 <exec+0x27e>
      last = s+1;
    8000539c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800053a0:	0785                	addi	a5,a5,1
    800053a2:	fff7c703          	lbu	a4,-1(a5)
    800053a6:	c701                	beqz	a4,800053ae <exec+0x284>
    if(*s == '/')
    800053a8:	fed71ce3          	bne	a4,a3,800053a0 <exec+0x276>
    800053ac:	bfc5                	j	8000539c <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800053ae:	4641                	li	a2,16
    800053b0:	df843583          	ld	a1,-520(s0)
    800053b4:	158a8513          	addi	a0,s5,344
    800053b8:	ffffc097          	auipc	ra,0xffffc
    800053bc:	a80080e7          	jalr	-1408(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    800053c0:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800053c4:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800053c8:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053cc:	058ab783          	ld	a5,88(s5)
    800053d0:	e6843703          	ld	a4,-408(s0)
    800053d4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053d6:	058ab783          	ld	a5,88(s5)
    800053da:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053de:	85ea                	mv	a1,s10
    800053e0:	ffffc097          	auipc	ra,0xffffc
    800053e4:	746080e7          	jalr	1862(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053e8:	0004851b          	sext.w	a0,s1
    800053ec:	bbd9                	j	800051c2 <exec+0x98>
    800053ee:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800053f2:	e0843583          	ld	a1,-504(s0)
    800053f6:	855e                	mv	a0,s7
    800053f8:	ffffc097          	auipc	ra,0xffffc
    800053fc:	72e080e7          	jalr	1838(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    80005400:	da0497e3          	bnez	s1,800051ae <exec+0x84>
  return -1;
    80005404:	557d                	li	a0,-1
    80005406:	bb75                	j	800051c2 <exec+0x98>
    80005408:	e1443423          	sd	s4,-504(s0)
    8000540c:	b7dd                	j	800053f2 <exec+0x2c8>
    8000540e:	e1443423          	sd	s4,-504(s0)
    80005412:	b7c5                	j	800053f2 <exec+0x2c8>
    80005414:	e1443423          	sd	s4,-504(s0)
    80005418:	bfe9                	j	800053f2 <exec+0x2c8>
    8000541a:	e1443423          	sd	s4,-504(s0)
    8000541e:	bfd1                	j	800053f2 <exec+0x2c8>
  sz = sz1;
    80005420:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005424:	4481                	li	s1,0
    80005426:	b7f1                	j	800053f2 <exec+0x2c8>
  sz = sz1;
    80005428:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000542c:	4481                	li	s1,0
    8000542e:	b7d1                	j	800053f2 <exec+0x2c8>
  sz = sz1;
    80005430:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005434:	4481                	li	s1,0
    80005436:	bf75                	j	800053f2 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005438:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000543c:	2b05                	addiw	s6,s6,1
    8000543e:	0389899b          	addiw	s3,s3,56
    80005442:	e8845783          	lhu	a5,-376(s0)
    80005446:	e2fb57e3          	bge	s6,a5,80005274 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000544a:	2981                	sext.w	s3,s3
    8000544c:	03800713          	li	a4,56
    80005450:	86ce                	mv	a3,s3
    80005452:	e1840613          	addi	a2,s0,-488
    80005456:	4581                	li	a1,0
    80005458:	8526                	mv	a0,s1
    8000545a:	fffff097          	auipc	ra,0xfffff
    8000545e:	a6e080e7          	jalr	-1426(ra) # 80003ec8 <readi>
    80005462:	03800793          	li	a5,56
    80005466:	f8f514e3          	bne	a0,a5,800053ee <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    8000546a:	e1842783          	lw	a5,-488(s0)
    8000546e:	4705                	li	a4,1
    80005470:	fce796e3          	bne	a5,a4,8000543c <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005474:	e4043903          	ld	s2,-448(s0)
    80005478:	e3843783          	ld	a5,-456(s0)
    8000547c:	f8f966e3          	bltu	s2,a5,80005408 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005480:	e2843783          	ld	a5,-472(s0)
    80005484:	993e                	add	s2,s2,a5
    80005486:	f8f964e3          	bltu	s2,a5,8000540e <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    8000548a:	df043703          	ld	a4,-528(s0)
    8000548e:	8ff9                	and	a5,a5,a4
    80005490:	f3d1                	bnez	a5,80005414 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005492:	e1c42503          	lw	a0,-484(s0)
    80005496:	00000097          	auipc	ra,0x0
    8000549a:	c78080e7          	jalr	-904(ra) # 8000510e <flags2perm>
    8000549e:	86aa                	mv	a3,a0
    800054a0:	864a                	mv	a2,s2
    800054a2:	85d2                	mv	a1,s4
    800054a4:	855e                	mv	a0,s7
    800054a6:	ffffc097          	auipc	ra,0xffffc
    800054aa:	f86080e7          	jalr	-122(ra) # 8000142c <uvmalloc>
    800054ae:	e0a43423          	sd	a0,-504(s0)
    800054b2:	d525                	beqz	a0,8000541a <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054b4:	e2843d03          	ld	s10,-472(s0)
    800054b8:	e2042d83          	lw	s11,-480(s0)
    800054bc:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054c0:	f60c0ce3          	beqz	s8,80005438 <exec+0x30e>
    800054c4:	8a62                	mv	s4,s8
    800054c6:	4901                	li	s2,0
    800054c8:	b369                	j	80005252 <exec+0x128>

00000000800054ca <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054ca:	7179                	addi	sp,sp,-48
    800054cc:	f406                	sd	ra,40(sp)
    800054ce:	f022                	sd	s0,32(sp)
    800054d0:	ec26                	sd	s1,24(sp)
    800054d2:	e84a                	sd	s2,16(sp)
    800054d4:	1800                	addi	s0,sp,48
    800054d6:	892e                	mv	s2,a1
    800054d8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054da:	fdc40593          	addi	a1,s0,-36
    800054de:	ffffe097          	auipc	ra,0xffffe
    800054e2:	a5e080e7          	jalr	-1442(ra) # 80002f3c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054e6:	fdc42703          	lw	a4,-36(s0)
    800054ea:	47bd                	li	a5,15
    800054ec:	02e7eb63          	bltu	a5,a4,80005522 <argfd+0x58>
    800054f0:	ffffc097          	auipc	ra,0xffffc
    800054f4:	4d6080e7          	jalr	1238(ra) # 800019c6 <myproc>
    800054f8:	fdc42703          	lw	a4,-36(s0)
    800054fc:	01a70793          	addi	a5,a4,26
    80005500:	078e                	slli	a5,a5,0x3
    80005502:	953e                	add	a0,a0,a5
    80005504:	611c                	ld	a5,0(a0)
    80005506:	c385                	beqz	a5,80005526 <argfd+0x5c>
    return -1;
  if(pfd)
    80005508:	00090463          	beqz	s2,80005510 <argfd+0x46>
    *pfd = fd;
    8000550c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005510:	4501                	li	a0,0
  if(pf)
    80005512:	c091                	beqz	s1,80005516 <argfd+0x4c>
    *pf = f;
    80005514:	e09c                	sd	a5,0(s1)
}
    80005516:	70a2                	ld	ra,40(sp)
    80005518:	7402                	ld	s0,32(sp)
    8000551a:	64e2                	ld	s1,24(sp)
    8000551c:	6942                	ld	s2,16(sp)
    8000551e:	6145                	addi	sp,sp,48
    80005520:	8082                	ret
    return -1;
    80005522:	557d                	li	a0,-1
    80005524:	bfcd                	j	80005516 <argfd+0x4c>
    80005526:	557d                	li	a0,-1
    80005528:	b7fd                	j	80005516 <argfd+0x4c>

000000008000552a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000552a:	1101                	addi	sp,sp,-32
    8000552c:	ec06                	sd	ra,24(sp)
    8000552e:	e822                	sd	s0,16(sp)
    80005530:	e426                	sd	s1,8(sp)
    80005532:	1000                	addi	s0,sp,32
    80005534:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005536:	ffffc097          	auipc	ra,0xffffc
    8000553a:	490080e7          	jalr	1168(ra) # 800019c6 <myproc>
    8000553e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005540:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdc980>
    80005544:	4501                	li	a0,0
    80005546:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005548:	6398                	ld	a4,0(a5)
    8000554a:	cb19                	beqz	a4,80005560 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000554c:	2505                	addiw	a0,a0,1
    8000554e:	07a1                	addi	a5,a5,8
    80005550:	fed51ce3          	bne	a0,a3,80005548 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005554:	557d                	li	a0,-1
}
    80005556:	60e2                	ld	ra,24(sp)
    80005558:	6442                	ld	s0,16(sp)
    8000555a:	64a2                	ld	s1,8(sp)
    8000555c:	6105                	addi	sp,sp,32
    8000555e:	8082                	ret
      p->ofile[fd] = f;
    80005560:	01a50793          	addi	a5,a0,26
    80005564:	078e                	slli	a5,a5,0x3
    80005566:	963e                	add	a2,a2,a5
    80005568:	e204                	sd	s1,0(a2)
      return fd;
    8000556a:	b7f5                	j	80005556 <fdalloc+0x2c>

000000008000556c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000556c:	715d                	addi	sp,sp,-80
    8000556e:	e486                	sd	ra,72(sp)
    80005570:	e0a2                	sd	s0,64(sp)
    80005572:	fc26                	sd	s1,56(sp)
    80005574:	f84a                	sd	s2,48(sp)
    80005576:	f44e                	sd	s3,40(sp)
    80005578:	f052                	sd	s4,32(sp)
    8000557a:	ec56                	sd	s5,24(sp)
    8000557c:	e85a                	sd	s6,16(sp)
    8000557e:	0880                	addi	s0,sp,80
    80005580:	8b2e                	mv	s6,a1
    80005582:	89b2                	mv	s3,a2
    80005584:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005586:	fb040593          	addi	a1,s0,-80
    8000558a:	fffff097          	auipc	ra,0xfffff
    8000558e:	e4e080e7          	jalr	-434(ra) # 800043d8 <nameiparent>
    80005592:	84aa                	mv	s1,a0
    80005594:	16050063          	beqz	a0,800056f4 <create+0x188>
    return 0;

  ilock(dp);
    80005598:	ffffe097          	auipc	ra,0xffffe
    8000559c:	67c080e7          	jalr	1660(ra) # 80003c14 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055a0:	4601                	li	a2,0
    800055a2:	fb040593          	addi	a1,s0,-80
    800055a6:	8526                	mv	a0,s1
    800055a8:	fffff097          	auipc	ra,0xfffff
    800055ac:	b50080e7          	jalr	-1200(ra) # 800040f8 <dirlookup>
    800055b0:	8aaa                	mv	s5,a0
    800055b2:	c931                	beqz	a0,80005606 <create+0x9a>
    iunlockput(dp);
    800055b4:	8526                	mv	a0,s1
    800055b6:	fffff097          	auipc	ra,0xfffff
    800055ba:	8c0080e7          	jalr	-1856(ra) # 80003e76 <iunlockput>
    ilock(ip);
    800055be:	8556                	mv	a0,s5
    800055c0:	ffffe097          	auipc	ra,0xffffe
    800055c4:	654080e7          	jalr	1620(ra) # 80003c14 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055c8:	000b059b          	sext.w	a1,s6
    800055cc:	4789                	li	a5,2
    800055ce:	02f59563          	bne	a1,a5,800055f8 <create+0x8c>
    800055d2:	044ad783          	lhu	a5,68(s5)
    800055d6:	37f9                	addiw	a5,a5,-2
    800055d8:	17c2                	slli	a5,a5,0x30
    800055da:	93c1                	srli	a5,a5,0x30
    800055dc:	4705                	li	a4,1
    800055de:	00f76d63          	bltu	a4,a5,800055f8 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055e2:	8556                	mv	a0,s5
    800055e4:	60a6                	ld	ra,72(sp)
    800055e6:	6406                	ld	s0,64(sp)
    800055e8:	74e2                	ld	s1,56(sp)
    800055ea:	7942                	ld	s2,48(sp)
    800055ec:	79a2                	ld	s3,40(sp)
    800055ee:	7a02                	ld	s4,32(sp)
    800055f0:	6ae2                	ld	s5,24(sp)
    800055f2:	6b42                	ld	s6,16(sp)
    800055f4:	6161                	addi	sp,sp,80
    800055f6:	8082                	ret
    iunlockput(ip);
    800055f8:	8556                	mv	a0,s5
    800055fa:	fffff097          	auipc	ra,0xfffff
    800055fe:	87c080e7          	jalr	-1924(ra) # 80003e76 <iunlockput>
    return 0;
    80005602:	4a81                	li	s5,0
    80005604:	bff9                	j	800055e2 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005606:	85da                	mv	a1,s6
    80005608:	4088                	lw	a0,0(s1)
    8000560a:	ffffe097          	auipc	ra,0xffffe
    8000560e:	46e080e7          	jalr	1134(ra) # 80003a78 <ialloc>
    80005612:	8a2a                	mv	s4,a0
    80005614:	c921                	beqz	a0,80005664 <create+0xf8>
  ilock(ip);
    80005616:	ffffe097          	auipc	ra,0xffffe
    8000561a:	5fe080e7          	jalr	1534(ra) # 80003c14 <ilock>
  ip->major = major;
    8000561e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005622:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005626:	4785                	li	a5,1
    80005628:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    8000562c:	8552                	mv	a0,s4
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	51c080e7          	jalr	1308(ra) # 80003b4a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005636:	000b059b          	sext.w	a1,s6
    8000563a:	4785                	li	a5,1
    8000563c:	02f58b63          	beq	a1,a5,80005672 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005640:	004a2603          	lw	a2,4(s4)
    80005644:	fb040593          	addi	a1,s0,-80
    80005648:	8526                	mv	a0,s1
    8000564a:	fffff097          	auipc	ra,0xfffff
    8000564e:	cbe080e7          	jalr	-834(ra) # 80004308 <dirlink>
    80005652:	06054f63          	bltz	a0,800056d0 <create+0x164>
  iunlockput(dp);
    80005656:	8526                	mv	a0,s1
    80005658:	fffff097          	auipc	ra,0xfffff
    8000565c:	81e080e7          	jalr	-2018(ra) # 80003e76 <iunlockput>
  return ip;
    80005660:	8ad2                	mv	s5,s4
    80005662:	b741                	j	800055e2 <create+0x76>
    iunlockput(dp);
    80005664:	8526                	mv	a0,s1
    80005666:	fffff097          	auipc	ra,0xfffff
    8000566a:	810080e7          	jalr	-2032(ra) # 80003e76 <iunlockput>
    return 0;
    8000566e:	8ad2                	mv	s5,s4
    80005670:	bf8d                	j	800055e2 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005672:	004a2603          	lw	a2,4(s4)
    80005676:	00003597          	auipc	a1,0x3
    8000567a:	28a58593          	addi	a1,a1,650 # 80008900 <syscalls+0x2d0>
    8000567e:	8552                	mv	a0,s4
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	c88080e7          	jalr	-888(ra) # 80004308 <dirlink>
    80005688:	04054463          	bltz	a0,800056d0 <create+0x164>
    8000568c:	40d0                	lw	a2,4(s1)
    8000568e:	00003597          	auipc	a1,0x3
    80005692:	27a58593          	addi	a1,a1,634 # 80008908 <syscalls+0x2d8>
    80005696:	8552                	mv	a0,s4
    80005698:	fffff097          	auipc	ra,0xfffff
    8000569c:	c70080e7          	jalr	-912(ra) # 80004308 <dirlink>
    800056a0:	02054863          	bltz	a0,800056d0 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800056a4:	004a2603          	lw	a2,4(s4)
    800056a8:	fb040593          	addi	a1,s0,-80
    800056ac:	8526                	mv	a0,s1
    800056ae:	fffff097          	auipc	ra,0xfffff
    800056b2:	c5a080e7          	jalr	-934(ra) # 80004308 <dirlink>
    800056b6:	00054d63          	bltz	a0,800056d0 <create+0x164>
    dp->nlink++;  // for ".."
    800056ba:	04a4d783          	lhu	a5,74(s1)
    800056be:	2785                	addiw	a5,a5,1
    800056c0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056c4:	8526                	mv	a0,s1
    800056c6:	ffffe097          	auipc	ra,0xffffe
    800056ca:	484080e7          	jalr	1156(ra) # 80003b4a <iupdate>
    800056ce:	b761                	j	80005656 <create+0xea>
  ip->nlink = 0;
    800056d0:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800056d4:	8552                	mv	a0,s4
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	474080e7          	jalr	1140(ra) # 80003b4a <iupdate>
  iunlockput(ip);
    800056de:	8552                	mv	a0,s4
    800056e0:	ffffe097          	auipc	ra,0xffffe
    800056e4:	796080e7          	jalr	1942(ra) # 80003e76 <iunlockput>
  iunlockput(dp);
    800056e8:	8526                	mv	a0,s1
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	78c080e7          	jalr	1932(ra) # 80003e76 <iunlockput>
  return 0;
    800056f2:	bdc5                	j	800055e2 <create+0x76>
    return 0;
    800056f4:	8aaa                	mv	s5,a0
    800056f6:	b5f5                	j	800055e2 <create+0x76>

00000000800056f8 <sys_dup>:
{
    800056f8:	7179                	addi	sp,sp,-48
    800056fa:	f406                	sd	ra,40(sp)
    800056fc:	f022                	sd	s0,32(sp)
    800056fe:	ec26                	sd	s1,24(sp)
    80005700:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005702:	fd840613          	addi	a2,s0,-40
    80005706:	4581                	li	a1,0
    80005708:	4501                	li	a0,0
    8000570a:	00000097          	auipc	ra,0x0
    8000570e:	dc0080e7          	jalr	-576(ra) # 800054ca <argfd>
    return -1;
    80005712:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005714:	02054363          	bltz	a0,8000573a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005718:	fd843503          	ld	a0,-40(s0)
    8000571c:	00000097          	auipc	ra,0x0
    80005720:	e0e080e7          	jalr	-498(ra) # 8000552a <fdalloc>
    80005724:	84aa                	mv	s1,a0
    return -1;
    80005726:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005728:	00054963          	bltz	a0,8000573a <sys_dup+0x42>
  filedup(f);
    8000572c:	fd843503          	ld	a0,-40(s0)
    80005730:	fffff097          	auipc	ra,0xfffff
    80005734:	320080e7          	jalr	800(ra) # 80004a50 <filedup>
  return fd;
    80005738:	87a6                	mv	a5,s1
}
    8000573a:	853e                	mv	a0,a5
    8000573c:	70a2                	ld	ra,40(sp)
    8000573e:	7402                	ld	s0,32(sp)
    80005740:	64e2                	ld	s1,24(sp)
    80005742:	6145                	addi	sp,sp,48
    80005744:	8082                	ret

0000000080005746 <sys_read>:
{
    80005746:	7179                	addi	sp,sp,-48
    80005748:	f406                	sd	ra,40(sp)
    8000574a:	f022                	sd	s0,32(sp)
    8000574c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000574e:	fd840593          	addi	a1,s0,-40
    80005752:	4505                	li	a0,1
    80005754:	ffffe097          	auipc	ra,0xffffe
    80005758:	80a080e7          	jalr	-2038(ra) # 80002f5e <argaddr>
  argint(2, &n);
    8000575c:	fe440593          	addi	a1,s0,-28
    80005760:	4509                	li	a0,2
    80005762:	ffffd097          	auipc	ra,0xffffd
    80005766:	7da080e7          	jalr	2010(ra) # 80002f3c <argint>
  if(argfd(0, 0, &f) < 0)
    8000576a:	fe840613          	addi	a2,s0,-24
    8000576e:	4581                	li	a1,0
    80005770:	4501                	li	a0,0
    80005772:	00000097          	auipc	ra,0x0
    80005776:	d58080e7          	jalr	-680(ra) # 800054ca <argfd>
    8000577a:	87aa                	mv	a5,a0
    return -1;
    8000577c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000577e:	0007cc63          	bltz	a5,80005796 <sys_read+0x50>
  return fileread(f, p, n);
    80005782:	fe442603          	lw	a2,-28(s0)
    80005786:	fd843583          	ld	a1,-40(s0)
    8000578a:	fe843503          	ld	a0,-24(s0)
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	44e080e7          	jalr	1102(ra) # 80004bdc <fileread>
}
    80005796:	70a2                	ld	ra,40(sp)
    80005798:	7402                	ld	s0,32(sp)
    8000579a:	6145                	addi	sp,sp,48
    8000579c:	8082                	ret

000000008000579e <sys_write>:
{
    8000579e:	7179                	addi	sp,sp,-48
    800057a0:	f406                	sd	ra,40(sp)
    800057a2:	f022                	sd	s0,32(sp)
    800057a4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057a6:	fd840593          	addi	a1,s0,-40
    800057aa:	4505                	li	a0,1
    800057ac:	ffffd097          	auipc	ra,0xffffd
    800057b0:	7b2080e7          	jalr	1970(ra) # 80002f5e <argaddr>
  argint(2, &n);
    800057b4:	fe440593          	addi	a1,s0,-28
    800057b8:	4509                	li	a0,2
    800057ba:	ffffd097          	auipc	ra,0xffffd
    800057be:	782080e7          	jalr	1922(ra) # 80002f3c <argint>
  if(argfd(0, 0, &f) < 0)
    800057c2:	fe840613          	addi	a2,s0,-24
    800057c6:	4581                	li	a1,0
    800057c8:	4501                	li	a0,0
    800057ca:	00000097          	auipc	ra,0x0
    800057ce:	d00080e7          	jalr	-768(ra) # 800054ca <argfd>
    800057d2:	87aa                	mv	a5,a0
    return -1;
    800057d4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057d6:	0007cc63          	bltz	a5,800057ee <sys_write+0x50>
  return filewrite(f, p, n);
    800057da:	fe442603          	lw	a2,-28(s0)
    800057de:	fd843583          	ld	a1,-40(s0)
    800057e2:	fe843503          	ld	a0,-24(s0)
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	4b8080e7          	jalr	1208(ra) # 80004c9e <filewrite>
}
    800057ee:	70a2                	ld	ra,40(sp)
    800057f0:	7402                	ld	s0,32(sp)
    800057f2:	6145                	addi	sp,sp,48
    800057f4:	8082                	ret

00000000800057f6 <sys_close>:
{
    800057f6:	1101                	addi	sp,sp,-32
    800057f8:	ec06                	sd	ra,24(sp)
    800057fa:	e822                	sd	s0,16(sp)
    800057fc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057fe:	fe040613          	addi	a2,s0,-32
    80005802:	fec40593          	addi	a1,s0,-20
    80005806:	4501                	li	a0,0
    80005808:	00000097          	auipc	ra,0x0
    8000580c:	cc2080e7          	jalr	-830(ra) # 800054ca <argfd>
    return -1;
    80005810:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005812:	02054463          	bltz	a0,8000583a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005816:	ffffc097          	auipc	ra,0xffffc
    8000581a:	1b0080e7          	jalr	432(ra) # 800019c6 <myproc>
    8000581e:	fec42783          	lw	a5,-20(s0)
    80005822:	07e9                	addi	a5,a5,26
    80005824:	078e                	slli	a5,a5,0x3
    80005826:	97aa                	add	a5,a5,a0
    80005828:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000582c:	fe043503          	ld	a0,-32(s0)
    80005830:	fffff097          	auipc	ra,0xfffff
    80005834:	272080e7          	jalr	626(ra) # 80004aa2 <fileclose>
  return 0;
    80005838:	4781                	li	a5,0
}
    8000583a:	853e                	mv	a0,a5
    8000583c:	60e2                	ld	ra,24(sp)
    8000583e:	6442                	ld	s0,16(sp)
    80005840:	6105                	addi	sp,sp,32
    80005842:	8082                	ret

0000000080005844 <sys_fstat>:
{
    80005844:	1101                	addi	sp,sp,-32
    80005846:	ec06                	sd	ra,24(sp)
    80005848:	e822                	sd	s0,16(sp)
    8000584a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000584c:	fe040593          	addi	a1,s0,-32
    80005850:	4505                	li	a0,1
    80005852:	ffffd097          	auipc	ra,0xffffd
    80005856:	70c080e7          	jalr	1804(ra) # 80002f5e <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000585a:	fe840613          	addi	a2,s0,-24
    8000585e:	4581                	li	a1,0
    80005860:	4501                	li	a0,0
    80005862:	00000097          	auipc	ra,0x0
    80005866:	c68080e7          	jalr	-920(ra) # 800054ca <argfd>
    8000586a:	87aa                	mv	a5,a0
    return -1;
    8000586c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000586e:	0007ca63          	bltz	a5,80005882 <sys_fstat+0x3e>
  return filestat(f, st);
    80005872:	fe043583          	ld	a1,-32(s0)
    80005876:	fe843503          	ld	a0,-24(s0)
    8000587a:	fffff097          	auipc	ra,0xfffff
    8000587e:	2f0080e7          	jalr	752(ra) # 80004b6a <filestat>
}
    80005882:	60e2                	ld	ra,24(sp)
    80005884:	6442                	ld	s0,16(sp)
    80005886:	6105                	addi	sp,sp,32
    80005888:	8082                	ret

000000008000588a <sys_link>:
{
    8000588a:	7169                	addi	sp,sp,-304
    8000588c:	f606                	sd	ra,296(sp)
    8000588e:	f222                	sd	s0,288(sp)
    80005890:	ee26                	sd	s1,280(sp)
    80005892:	ea4a                	sd	s2,272(sp)
    80005894:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005896:	08000613          	li	a2,128
    8000589a:	ed040593          	addi	a1,s0,-304
    8000589e:	4501                	li	a0,0
    800058a0:	ffffd097          	auipc	ra,0xffffd
    800058a4:	6e0080e7          	jalr	1760(ra) # 80002f80 <argstr>
    return -1;
    800058a8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058aa:	10054e63          	bltz	a0,800059c6 <sys_link+0x13c>
    800058ae:	08000613          	li	a2,128
    800058b2:	f5040593          	addi	a1,s0,-176
    800058b6:	4505                	li	a0,1
    800058b8:	ffffd097          	auipc	ra,0xffffd
    800058bc:	6c8080e7          	jalr	1736(ra) # 80002f80 <argstr>
    return -1;
    800058c0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058c2:	10054263          	bltz	a0,800059c6 <sys_link+0x13c>
  begin_op();
    800058c6:	fffff097          	auipc	ra,0xfffff
    800058ca:	d10080e7          	jalr	-752(ra) # 800045d6 <begin_op>
  if((ip = namei(old)) == 0){
    800058ce:	ed040513          	addi	a0,s0,-304
    800058d2:	fffff097          	auipc	ra,0xfffff
    800058d6:	ae8080e7          	jalr	-1304(ra) # 800043ba <namei>
    800058da:	84aa                	mv	s1,a0
    800058dc:	c551                	beqz	a0,80005968 <sys_link+0xde>
  ilock(ip);
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	336080e7          	jalr	822(ra) # 80003c14 <ilock>
  if(ip->type == T_DIR){
    800058e6:	04449703          	lh	a4,68(s1)
    800058ea:	4785                	li	a5,1
    800058ec:	08f70463          	beq	a4,a5,80005974 <sys_link+0xea>
  ip->nlink++;
    800058f0:	04a4d783          	lhu	a5,74(s1)
    800058f4:	2785                	addiw	a5,a5,1
    800058f6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058fa:	8526                	mv	a0,s1
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	24e080e7          	jalr	590(ra) # 80003b4a <iupdate>
  iunlock(ip);
    80005904:	8526                	mv	a0,s1
    80005906:	ffffe097          	auipc	ra,0xffffe
    8000590a:	3d0080e7          	jalr	976(ra) # 80003cd6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000590e:	fd040593          	addi	a1,s0,-48
    80005912:	f5040513          	addi	a0,s0,-176
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	ac2080e7          	jalr	-1342(ra) # 800043d8 <nameiparent>
    8000591e:	892a                	mv	s2,a0
    80005920:	c935                	beqz	a0,80005994 <sys_link+0x10a>
  ilock(dp);
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	2f2080e7          	jalr	754(ra) # 80003c14 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000592a:	00092703          	lw	a4,0(s2)
    8000592e:	409c                	lw	a5,0(s1)
    80005930:	04f71d63          	bne	a4,a5,8000598a <sys_link+0x100>
    80005934:	40d0                	lw	a2,4(s1)
    80005936:	fd040593          	addi	a1,s0,-48
    8000593a:	854a                	mv	a0,s2
    8000593c:	fffff097          	auipc	ra,0xfffff
    80005940:	9cc080e7          	jalr	-1588(ra) # 80004308 <dirlink>
    80005944:	04054363          	bltz	a0,8000598a <sys_link+0x100>
  iunlockput(dp);
    80005948:	854a                	mv	a0,s2
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	52c080e7          	jalr	1324(ra) # 80003e76 <iunlockput>
  iput(ip);
    80005952:	8526                	mv	a0,s1
    80005954:	ffffe097          	auipc	ra,0xffffe
    80005958:	47a080e7          	jalr	1146(ra) # 80003dce <iput>
  end_op();
    8000595c:	fffff097          	auipc	ra,0xfffff
    80005960:	cfa080e7          	jalr	-774(ra) # 80004656 <end_op>
  return 0;
    80005964:	4781                	li	a5,0
    80005966:	a085                	j	800059c6 <sys_link+0x13c>
    end_op();
    80005968:	fffff097          	auipc	ra,0xfffff
    8000596c:	cee080e7          	jalr	-786(ra) # 80004656 <end_op>
    return -1;
    80005970:	57fd                	li	a5,-1
    80005972:	a891                	j	800059c6 <sys_link+0x13c>
    iunlockput(ip);
    80005974:	8526                	mv	a0,s1
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	500080e7          	jalr	1280(ra) # 80003e76 <iunlockput>
    end_op();
    8000597e:	fffff097          	auipc	ra,0xfffff
    80005982:	cd8080e7          	jalr	-808(ra) # 80004656 <end_op>
    return -1;
    80005986:	57fd                	li	a5,-1
    80005988:	a83d                	j	800059c6 <sys_link+0x13c>
    iunlockput(dp);
    8000598a:	854a                	mv	a0,s2
    8000598c:	ffffe097          	auipc	ra,0xffffe
    80005990:	4ea080e7          	jalr	1258(ra) # 80003e76 <iunlockput>
  ilock(ip);
    80005994:	8526                	mv	a0,s1
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	27e080e7          	jalr	638(ra) # 80003c14 <ilock>
  ip->nlink--;
    8000599e:	04a4d783          	lhu	a5,74(s1)
    800059a2:	37fd                	addiw	a5,a5,-1
    800059a4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059a8:	8526                	mv	a0,s1
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	1a0080e7          	jalr	416(ra) # 80003b4a <iupdate>
  iunlockput(ip);
    800059b2:	8526                	mv	a0,s1
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	4c2080e7          	jalr	1218(ra) # 80003e76 <iunlockput>
  end_op();
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	c9a080e7          	jalr	-870(ra) # 80004656 <end_op>
  return -1;
    800059c4:	57fd                	li	a5,-1
}
    800059c6:	853e                	mv	a0,a5
    800059c8:	70b2                	ld	ra,296(sp)
    800059ca:	7412                	ld	s0,288(sp)
    800059cc:	64f2                	ld	s1,280(sp)
    800059ce:	6952                	ld	s2,272(sp)
    800059d0:	6155                	addi	sp,sp,304
    800059d2:	8082                	ret

00000000800059d4 <sys_unlink>:
{
    800059d4:	7151                	addi	sp,sp,-240
    800059d6:	f586                	sd	ra,232(sp)
    800059d8:	f1a2                	sd	s0,224(sp)
    800059da:	eda6                	sd	s1,216(sp)
    800059dc:	e9ca                	sd	s2,208(sp)
    800059de:	e5ce                	sd	s3,200(sp)
    800059e0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059e2:	08000613          	li	a2,128
    800059e6:	f3040593          	addi	a1,s0,-208
    800059ea:	4501                	li	a0,0
    800059ec:	ffffd097          	auipc	ra,0xffffd
    800059f0:	594080e7          	jalr	1428(ra) # 80002f80 <argstr>
    800059f4:	18054163          	bltz	a0,80005b76 <sys_unlink+0x1a2>
  begin_op();
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	bde080e7          	jalr	-1058(ra) # 800045d6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a00:	fb040593          	addi	a1,s0,-80
    80005a04:	f3040513          	addi	a0,s0,-208
    80005a08:	fffff097          	auipc	ra,0xfffff
    80005a0c:	9d0080e7          	jalr	-1584(ra) # 800043d8 <nameiparent>
    80005a10:	84aa                	mv	s1,a0
    80005a12:	c979                	beqz	a0,80005ae8 <sys_unlink+0x114>
  ilock(dp);
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	200080e7          	jalr	512(ra) # 80003c14 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a1c:	00003597          	auipc	a1,0x3
    80005a20:	ee458593          	addi	a1,a1,-284 # 80008900 <syscalls+0x2d0>
    80005a24:	fb040513          	addi	a0,s0,-80
    80005a28:	ffffe097          	auipc	ra,0xffffe
    80005a2c:	6b6080e7          	jalr	1718(ra) # 800040de <namecmp>
    80005a30:	14050a63          	beqz	a0,80005b84 <sys_unlink+0x1b0>
    80005a34:	00003597          	auipc	a1,0x3
    80005a38:	ed458593          	addi	a1,a1,-300 # 80008908 <syscalls+0x2d8>
    80005a3c:	fb040513          	addi	a0,s0,-80
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	69e080e7          	jalr	1694(ra) # 800040de <namecmp>
    80005a48:	12050e63          	beqz	a0,80005b84 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a4c:	f2c40613          	addi	a2,s0,-212
    80005a50:	fb040593          	addi	a1,s0,-80
    80005a54:	8526                	mv	a0,s1
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	6a2080e7          	jalr	1698(ra) # 800040f8 <dirlookup>
    80005a5e:	892a                	mv	s2,a0
    80005a60:	12050263          	beqz	a0,80005b84 <sys_unlink+0x1b0>
  ilock(ip);
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	1b0080e7          	jalr	432(ra) # 80003c14 <ilock>
  if(ip->nlink < 1)
    80005a6c:	04a91783          	lh	a5,74(s2)
    80005a70:	08f05263          	blez	a5,80005af4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a74:	04491703          	lh	a4,68(s2)
    80005a78:	4785                	li	a5,1
    80005a7a:	08f70563          	beq	a4,a5,80005b04 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a7e:	4641                	li	a2,16
    80005a80:	4581                	li	a1,0
    80005a82:	fc040513          	addi	a0,s0,-64
    80005a86:	ffffb097          	auipc	ra,0xffffb
    80005a8a:	260080e7          	jalr	608(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a8e:	4741                	li	a4,16
    80005a90:	f2c42683          	lw	a3,-212(s0)
    80005a94:	fc040613          	addi	a2,s0,-64
    80005a98:	4581                	li	a1,0
    80005a9a:	8526                	mv	a0,s1
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	524080e7          	jalr	1316(ra) # 80003fc0 <writei>
    80005aa4:	47c1                	li	a5,16
    80005aa6:	0af51563          	bne	a0,a5,80005b50 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005aaa:	04491703          	lh	a4,68(s2)
    80005aae:	4785                	li	a5,1
    80005ab0:	0af70863          	beq	a4,a5,80005b60 <sys_unlink+0x18c>
  iunlockput(dp);
    80005ab4:	8526                	mv	a0,s1
    80005ab6:	ffffe097          	auipc	ra,0xffffe
    80005aba:	3c0080e7          	jalr	960(ra) # 80003e76 <iunlockput>
  ip->nlink--;
    80005abe:	04a95783          	lhu	a5,74(s2)
    80005ac2:	37fd                	addiw	a5,a5,-1
    80005ac4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005ac8:	854a                	mv	a0,s2
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	080080e7          	jalr	128(ra) # 80003b4a <iupdate>
  iunlockput(ip);
    80005ad2:	854a                	mv	a0,s2
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	3a2080e7          	jalr	930(ra) # 80003e76 <iunlockput>
  end_op();
    80005adc:	fffff097          	auipc	ra,0xfffff
    80005ae0:	b7a080e7          	jalr	-1158(ra) # 80004656 <end_op>
  return 0;
    80005ae4:	4501                	li	a0,0
    80005ae6:	a84d                	j	80005b98 <sys_unlink+0x1c4>
    end_op();
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	b6e080e7          	jalr	-1170(ra) # 80004656 <end_op>
    return -1;
    80005af0:	557d                	li	a0,-1
    80005af2:	a05d                	j	80005b98 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005af4:	00003517          	auipc	a0,0x3
    80005af8:	e1c50513          	addi	a0,a0,-484 # 80008910 <syscalls+0x2e0>
    80005afc:	ffffb097          	auipc	ra,0xffffb
    80005b00:	a48080e7          	jalr	-1464(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b04:	04c92703          	lw	a4,76(s2)
    80005b08:	02000793          	li	a5,32
    80005b0c:	f6e7f9e3          	bgeu	a5,a4,80005a7e <sys_unlink+0xaa>
    80005b10:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b14:	4741                	li	a4,16
    80005b16:	86ce                	mv	a3,s3
    80005b18:	f1840613          	addi	a2,s0,-232
    80005b1c:	4581                	li	a1,0
    80005b1e:	854a                	mv	a0,s2
    80005b20:	ffffe097          	auipc	ra,0xffffe
    80005b24:	3a8080e7          	jalr	936(ra) # 80003ec8 <readi>
    80005b28:	47c1                	li	a5,16
    80005b2a:	00f51b63          	bne	a0,a5,80005b40 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b2e:	f1845783          	lhu	a5,-232(s0)
    80005b32:	e7a1                	bnez	a5,80005b7a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b34:	29c1                	addiw	s3,s3,16
    80005b36:	04c92783          	lw	a5,76(s2)
    80005b3a:	fcf9ede3          	bltu	s3,a5,80005b14 <sys_unlink+0x140>
    80005b3e:	b781                	j	80005a7e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b40:	00003517          	auipc	a0,0x3
    80005b44:	de850513          	addi	a0,a0,-536 # 80008928 <syscalls+0x2f8>
    80005b48:	ffffb097          	auipc	ra,0xffffb
    80005b4c:	9fc080e7          	jalr	-1540(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005b50:	00003517          	auipc	a0,0x3
    80005b54:	df050513          	addi	a0,a0,-528 # 80008940 <syscalls+0x310>
    80005b58:	ffffb097          	auipc	ra,0xffffb
    80005b5c:	9ec080e7          	jalr	-1556(ra) # 80000544 <panic>
    dp->nlink--;
    80005b60:	04a4d783          	lhu	a5,74(s1)
    80005b64:	37fd                	addiw	a5,a5,-1
    80005b66:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b6a:	8526                	mv	a0,s1
    80005b6c:	ffffe097          	auipc	ra,0xffffe
    80005b70:	fde080e7          	jalr	-34(ra) # 80003b4a <iupdate>
    80005b74:	b781                	j	80005ab4 <sys_unlink+0xe0>
    return -1;
    80005b76:	557d                	li	a0,-1
    80005b78:	a005                	j	80005b98 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b7a:	854a                	mv	a0,s2
    80005b7c:	ffffe097          	auipc	ra,0xffffe
    80005b80:	2fa080e7          	jalr	762(ra) # 80003e76 <iunlockput>
  iunlockput(dp);
    80005b84:	8526                	mv	a0,s1
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	2f0080e7          	jalr	752(ra) # 80003e76 <iunlockput>
  end_op();
    80005b8e:	fffff097          	auipc	ra,0xfffff
    80005b92:	ac8080e7          	jalr	-1336(ra) # 80004656 <end_op>
  return -1;
    80005b96:	557d                	li	a0,-1
}
    80005b98:	70ae                	ld	ra,232(sp)
    80005b9a:	740e                	ld	s0,224(sp)
    80005b9c:	64ee                	ld	s1,216(sp)
    80005b9e:	694e                	ld	s2,208(sp)
    80005ba0:	69ae                	ld	s3,200(sp)
    80005ba2:	616d                	addi	sp,sp,240
    80005ba4:	8082                	ret

0000000080005ba6 <sys_open>:

uint64
sys_open(void)
{
    80005ba6:	7131                	addi	sp,sp,-192
    80005ba8:	fd06                	sd	ra,184(sp)
    80005baa:	f922                	sd	s0,176(sp)
    80005bac:	f526                	sd	s1,168(sp)
    80005bae:	f14a                	sd	s2,160(sp)
    80005bb0:	ed4e                	sd	s3,152(sp)
    80005bb2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005bb4:	f4c40593          	addi	a1,s0,-180
    80005bb8:	4505                	li	a0,1
    80005bba:	ffffd097          	auipc	ra,0xffffd
    80005bbe:	382080e7          	jalr	898(ra) # 80002f3c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bc2:	08000613          	li	a2,128
    80005bc6:	f5040593          	addi	a1,s0,-176
    80005bca:	4501                	li	a0,0
    80005bcc:	ffffd097          	auipc	ra,0xffffd
    80005bd0:	3b4080e7          	jalr	948(ra) # 80002f80 <argstr>
    80005bd4:	87aa                	mv	a5,a0
    return -1;
    80005bd6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bd8:	0a07c963          	bltz	a5,80005c8a <sys_open+0xe4>

  begin_op();
    80005bdc:	fffff097          	auipc	ra,0xfffff
    80005be0:	9fa080e7          	jalr	-1542(ra) # 800045d6 <begin_op>

  if(omode & O_CREATE){
    80005be4:	f4c42783          	lw	a5,-180(s0)
    80005be8:	2007f793          	andi	a5,a5,512
    80005bec:	cfc5                	beqz	a5,80005ca4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005bee:	4681                	li	a3,0
    80005bf0:	4601                	li	a2,0
    80005bf2:	4589                	li	a1,2
    80005bf4:	f5040513          	addi	a0,s0,-176
    80005bf8:	00000097          	auipc	ra,0x0
    80005bfc:	974080e7          	jalr	-1676(ra) # 8000556c <create>
    80005c00:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c02:	c959                	beqz	a0,80005c98 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c04:	04449703          	lh	a4,68(s1)
    80005c08:	478d                	li	a5,3
    80005c0a:	00f71763          	bne	a4,a5,80005c18 <sys_open+0x72>
    80005c0e:	0464d703          	lhu	a4,70(s1)
    80005c12:	47a5                	li	a5,9
    80005c14:	0ce7ed63          	bltu	a5,a4,80005cee <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	dce080e7          	jalr	-562(ra) # 800049e6 <filealloc>
    80005c20:	89aa                	mv	s3,a0
    80005c22:	10050363          	beqz	a0,80005d28 <sys_open+0x182>
    80005c26:	00000097          	auipc	ra,0x0
    80005c2a:	904080e7          	jalr	-1788(ra) # 8000552a <fdalloc>
    80005c2e:	892a                	mv	s2,a0
    80005c30:	0e054763          	bltz	a0,80005d1e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c34:	04449703          	lh	a4,68(s1)
    80005c38:	478d                	li	a5,3
    80005c3a:	0cf70563          	beq	a4,a5,80005d04 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c3e:	4789                	li	a5,2
    80005c40:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c44:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c48:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c4c:	f4c42783          	lw	a5,-180(s0)
    80005c50:	0017c713          	xori	a4,a5,1
    80005c54:	8b05                	andi	a4,a4,1
    80005c56:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c5a:	0037f713          	andi	a4,a5,3
    80005c5e:	00e03733          	snez	a4,a4
    80005c62:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c66:	4007f793          	andi	a5,a5,1024
    80005c6a:	c791                	beqz	a5,80005c76 <sys_open+0xd0>
    80005c6c:	04449703          	lh	a4,68(s1)
    80005c70:	4789                	li	a5,2
    80005c72:	0af70063          	beq	a4,a5,80005d12 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c76:	8526                	mv	a0,s1
    80005c78:	ffffe097          	auipc	ra,0xffffe
    80005c7c:	05e080e7          	jalr	94(ra) # 80003cd6 <iunlock>
  end_op();
    80005c80:	fffff097          	auipc	ra,0xfffff
    80005c84:	9d6080e7          	jalr	-1578(ra) # 80004656 <end_op>

  return fd;
    80005c88:	854a                	mv	a0,s2
}
    80005c8a:	70ea                	ld	ra,184(sp)
    80005c8c:	744a                	ld	s0,176(sp)
    80005c8e:	74aa                	ld	s1,168(sp)
    80005c90:	790a                	ld	s2,160(sp)
    80005c92:	69ea                	ld	s3,152(sp)
    80005c94:	6129                	addi	sp,sp,192
    80005c96:	8082                	ret
      end_op();
    80005c98:	fffff097          	auipc	ra,0xfffff
    80005c9c:	9be080e7          	jalr	-1602(ra) # 80004656 <end_op>
      return -1;
    80005ca0:	557d                	li	a0,-1
    80005ca2:	b7e5                	j	80005c8a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005ca4:	f5040513          	addi	a0,s0,-176
    80005ca8:	ffffe097          	auipc	ra,0xffffe
    80005cac:	712080e7          	jalr	1810(ra) # 800043ba <namei>
    80005cb0:	84aa                	mv	s1,a0
    80005cb2:	c905                	beqz	a0,80005ce2 <sys_open+0x13c>
    ilock(ip);
    80005cb4:	ffffe097          	auipc	ra,0xffffe
    80005cb8:	f60080e7          	jalr	-160(ra) # 80003c14 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cbc:	04449703          	lh	a4,68(s1)
    80005cc0:	4785                	li	a5,1
    80005cc2:	f4f711e3          	bne	a4,a5,80005c04 <sys_open+0x5e>
    80005cc6:	f4c42783          	lw	a5,-180(s0)
    80005cca:	d7b9                	beqz	a5,80005c18 <sys_open+0x72>
      iunlockput(ip);
    80005ccc:	8526                	mv	a0,s1
    80005cce:	ffffe097          	auipc	ra,0xffffe
    80005cd2:	1a8080e7          	jalr	424(ra) # 80003e76 <iunlockput>
      end_op();
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	980080e7          	jalr	-1664(ra) # 80004656 <end_op>
      return -1;
    80005cde:	557d                	li	a0,-1
    80005ce0:	b76d                	j	80005c8a <sys_open+0xe4>
      end_op();
    80005ce2:	fffff097          	auipc	ra,0xfffff
    80005ce6:	974080e7          	jalr	-1676(ra) # 80004656 <end_op>
      return -1;
    80005cea:	557d                	li	a0,-1
    80005cec:	bf79                	j	80005c8a <sys_open+0xe4>
    iunlockput(ip);
    80005cee:	8526                	mv	a0,s1
    80005cf0:	ffffe097          	auipc	ra,0xffffe
    80005cf4:	186080e7          	jalr	390(ra) # 80003e76 <iunlockput>
    end_op();
    80005cf8:	fffff097          	auipc	ra,0xfffff
    80005cfc:	95e080e7          	jalr	-1698(ra) # 80004656 <end_op>
    return -1;
    80005d00:	557d                	li	a0,-1
    80005d02:	b761                	j	80005c8a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d04:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d08:	04649783          	lh	a5,70(s1)
    80005d0c:	02f99223          	sh	a5,36(s3)
    80005d10:	bf25                	j	80005c48 <sys_open+0xa2>
    itrunc(ip);
    80005d12:	8526                	mv	a0,s1
    80005d14:	ffffe097          	auipc	ra,0xffffe
    80005d18:	00e080e7          	jalr	14(ra) # 80003d22 <itrunc>
    80005d1c:	bfa9                	j	80005c76 <sys_open+0xd0>
      fileclose(f);
    80005d1e:	854e                	mv	a0,s3
    80005d20:	fffff097          	auipc	ra,0xfffff
    80005d24:	d82080e7          	jalr	-638(ra) # 80004aa2 <fileclose>
    iunlockput(ip);
    80005d28:	8526                	mv	a0,s1
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	14c080e7          	jalr	332(ra) # 80003e76 <iunlockput>
    end_op();
    80005d32:	fffff097          	auipc	ra,0xfffff
    80005d36:	924080e7          	jalr	-1756(ra) # 80004656 <end_op>
    return -1;
    80005d3a:	557d                	li	a0,-1
    80005d3c:	b7b9                	j	80005c8a <sys_open+0xe4>

0000000080005d3e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d3e:	7175                	addi	sp,sp,-144
    80005d40:	e506                	sd	ra,136(sp)
    80005d42:	e122                	sd	s0,128(sp)
    80005d44:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d46:	fffff097          	auipc	ra,0xfffff
    80005d4a:	890080e7          	jalr	-1904(ra) # 800045d6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d4e:	08000613          	li	a2,128
    80005d52:	f7040593          	addi	a1,s0,-144
    80005d56:	4501                	li	a0,0
    80005d58:	ffffd097          	auipc	ra,0xffffd
    80005d5c:	228080e7          	jalr	552(ra) # 80002f80 <argstr>
    80005d60:	02054963          	bltz	a0,80005d92 <sys_mkdir+0x54>
    80005d64:	4681                	li	a3,0
    80005d66:	4601                	li	a2,0
    80005d68:	4585                	li	a1,1
    80005d6a:	f7040513          	addi	a0,s0,-144
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	7fe080e7          	jalr	2046(ra) # 8000556c <create>
    80005d76:	cd11                	beqz	a0,80005d92 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d78:	ffffe097          	auipc	ra,0xffffe
    80005d7c:	0fe080e7          	jalr	254(ra) # 80003e76 <iunlockput>
  end_op();
    80005d80:	fffff097          	auipc	ra,0xfffff
    80005d84:	8d6080e7          	jalr	-1834(ra) # 80004656 <end_op>
  return 0;
    80005d88:	4501                	li	a0,0
}
    80005d8a:	60aa                	ld	ra,136(sp)
    80005d8c:	640a                	ld	s0,128(sp)
    80005d8e:	6149                	addi	sp,sp,144
    80005d90:	8082                	ret
    end_op();
    80005d92:	fffff097          	auipc	ra,0xfffff
    80005d96:	8c4080e7          	jalr	-1852(ra) # 80004656 <end_op>
    return -1;
    80005d9a:	557d                	li	a0,-1
    80005d9c:	b7fd                	j	80005d8a <sys_mkdir+0x4c>

0000000080005d9e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d9e:	7135                	addi	sp,sp,-160
    80005da0:	ed06                	sd	ra,152(sp)
    80005da2:	e922                	sd	s0,144(sp)
    80005da4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005da6:	fffff097          	auipc	ra,0xfffff
    80005daa:	830080e7          	jalr	-2000(ra) # 800045d6 <begin_op>
  argint(1, &major);
    80005dae:	f6c40593          	addi	a1,s0,-148
    80005db2:	4505                	li	a0,1
    80005db4:	ffffd097          	auipc	ra,0xffffd
    80005db8:	188080e7          	jalr	392(ra) # 80002f3c <argint>
  argint(2, &minor);
    80005dbc:	f6840593          	addi	a1,s0,-152
    80005dc0:	4509                	li	a0,2
    80005dc2:	ffffd097          	auipc	ra,0xffffd
    80005dc6:	17a080e7          	jalr	378(ra) # 80002f3c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dca:	08000613          	li	a2,128
    80005dce:	f7040593          	addi	a1,s0,-144
    80005dd2:	4501                	li	a0,0
    80005dd4:	ffffd097          	auipc	ra,0xffffd
    80005dd8:	1ac080e7          	jalr	428(ra) # 80002f80 <argstr>
    80005ddc:	02054b63          	bltz	a0,80005e12 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005de0:	f6841683          	lh	a3,-152(s0)
    80005de4:	f6c41603          	lh	a2,-148(s0)
    80005de8:	458d                	li	a1,3
    80005dea:	f7040513          	addi	a0,s0,-144
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	77e080e7          	jalr	1918(ra) # 8000556c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005df6:	cd11                	beqz	a0,80005e12 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005df8:	ffffe097          	auipc	ra,0xffffe
    80005dfc:	07e080e7          	jalr	126(ra) # 80003e76 <iunlockput>
  end_op();
    80005e00:	fffff097          	auipc	ra,0xfffff
    80005e04:	856080e7          	jalr	-1962(ra) # 80004656 <end_op>
  return 0;
    80005e08:	4501                	li	a0,0
}
    80005e0a:	60ea                	ld	ra,152(sp)
    80005e0c:	644a                	ld	s0,144(sp)
    80005e0e:	610d                	addi	sp,sp,160
    80005e10:	8082                	ret
    end_op();
    80005e12:	fffff097          	auipc	ra,0xfffff
    80005e16:	844080e7          	jalr	-1980(ra) # 80004656 <end_op>
    return -1;
    80005e1a:	557d                	li	a0,-1
    80005e1c:	b7fd                	j	80005e0a <sys_mknod+0x6c>

0000000080005e1e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e1e:	7135                	addi	sp,sp,-160
    80005e20:	ed06                	sd	ra,152(sp)
    80005e22:	e922                	sd	s0,144(sp)
    80005e24:	e526                	sd	s1,136(sp)
    80005e26:	e14a                	sd	s2,128(sp)
    80005e28:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e2a:	ffffc097          	auipc	ra,0xffffc
    80005e2e:	b9c080e7          	jalr	-1124(ra) # 800019c6 <myproc>
    80005e32:	892a                	mv	s2,a0
  
  begin_op();
    80005e34:	ffffe097          	auipc	ra,0xffffe
    80005e38:	7a2080e7          	jalr	1954(ra) # 800045d6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e3c:	08000613          	li	a2,128
    80005e40:	f6040593          	addi	a1,s0,-160
    80005e44:	4501                	li	a0,0
    80005e46:	ffffd097          	auipc	ra,0xffffd
    80005e4a:	13a080e7          	jalr	314(ra) # 80002f80 <argstr>
    80005e4e:	04054b63          	bltz	a0,80005ea4 <sys_chdir+0x86>
    80005e52:	f6040513          	addi	a0,s0,-160
    80005e56:	ffffe097          	auipc	ra,0xffffe
    80005e5a:	564080e7          	jalr	1380(ra) # 800043ba <namei>
    80005e5e:	84aa                	mv	s1,a0
    80005e60:	c131                	beqz	a0,80005ea4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e62:	ffffe097          	auipc	ra,0xffffe
    80005e66:	db2080e7          	jalr	-590(ra) # 80003c14 <ilock>
  if(ip->type != T_DIR){
    80005e6a:	04449703          	lh	a4,68(s1)
    80005e6e:	4785                	li	a5,1
    80005e70:	04f71063          	bne	a4,a5,80005eb0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e74:	8526                	mv	a0,s1
    80005e76:	ffffe097          	auipc	ra,0xffffe
    80005e7a:	e60080e7          	jalr	-416(ra) # 80003cd6 <iunlock>
  iput(p->cwd);
    80005e7e:	15093503          	ld	a0,336(s2)
    80005e82:	ffffe097          	auipc	ra,0xffffe
    80005e86:	f4c080e7          	jalr	-180(ra) # 80003dce <iput>
  end_op();
    80005e8a:	ffffe097          	auipc	ra,0xffffe
    80005e8e:	7cc080e7          	jalr	1996(ra) # 80004656 <end_op>
  p->cwd = ip;
    80005e92:	14993823          	sd	s1,336(s2)
  return 0;
    80005e96:	4501                	li	a0,0
}
    80005e98:	60ea                	ld	ra,152(sp)
    80005e9a:	644a                	ld	s0,144(sp)
    80005e9c:	64aa                	ld	s1,136(sp)
    80005e9e:	690a                	ld	s2,128(sp)
    80005ea0:	610d                	addi	sp,sp,160
    80005ea2:	8082                	ret
    end_op();
    80005ea4:	ffffe097          	auipc	ra,0xffffe
    80005ea8:	7b2080e7          	jalr	1970(ra) # 80004656 <end_op>
    return -1;
    80005eac:	557d                	li	a0,-1
    80005eae:	b7ed                	j	80005e98 <sys_chdir+0x7a>
    iunlockput(ip);
    80005eb0:	8526                	mv	a0,s1
    80005eb2:	ffffe097          	auipc	ra,0xffffe
    80005eb6:	fc4080e7          	jalr	-60(ra) # 80003e76 <iunlockput>
    end_op();
    80005eba:	ffffe097          	auipc	ra,0xffffe
    80005ebe:	79c080e7          	jalr	1948(ra) # 80004656 <end_op>
    return -1;
    80005ec2:	557d                	li	a0,-1
    80005ec4:	bfd1                	j	80005e98 <sys_chdir+0x7a>

0000000080005ec6 <sys_exec>:

uint64
sys_exec(void)
{
    80005ec6:	7145                	addi	sp,sp,-464
    80005ec8:	e786                	sd	ra,456(sp)
    80005eca:	e3a2                	sd	s0,448(sp)
    80005ecc:	ff26                	sd	s1,440(sp)
    80005ece:	fb4a                	sd	s2,432(sp)
    80005ed0:	f74e                	sd	s3,424(sp)
    80005ed2:	f352                	sd	s4,416(sp)
    80005ed4:	ef56                	sd	s5,408(sp)
    80005ed6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ed8:	e3840593          	addi	a1,s0,-456
    80005edc:	4505                	li	a0,1
    80005ede:	ffffd097          	auipc	ra,0xffffd
    80005ee2:	080080e7          	jalr	128(ra) # 80002f5e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ee6:	08000613          	li	a2,128
    80005eea:	f4040593          	addi	a1,s0,-192
    80005eee:	4501                	li	a0,0
    80005ef0:	ffffd097          	auipc	ra,0xffffd
    80005ef4:	090080e7          	jalr	144(ra) # 80002f80 <argstr>
    80005ef8:	87aa                	mv	a5,a0
    return -1;
    80005efa:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005efc:	0c07c263          	bltz	a5,80005fc0 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f00:	10000613          	li	a2,256
    80005f04:	4581                	li	a1,0
    80005f06:	e4040513          	addi	a0,s0,-448
    80005f0a:	ffffb097          	auipc	ra,0xffffb
    80005f0e:	ddc080e7          	jalr	-548(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f12:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f16:	89a6                	mv	s3,s1
    80005f18:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f1a:	02000a13          	li	s4,32
    80005f1e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f22:	00391513          	slli	a0,s2,0x3
    80005f26:	e3040593          	addi	a1,s0,-464
    80005f2a:	e3843783          	ld	a5,-456(s0)
    80005f2e:	953e                	add	a0,a0,a5
    80005f30:	ffffd097          	auipc	ra,0xffffd
    80005f34:	f6e080e7          	jalr	-146(ra) # 80002e9e <fetchaddr>
    80005f38:	02054a63          	bltz	a0,80005f6c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f3c:	e3043783          	ld	a5,-464(s0)
    80005f40:	c3b9                	beqz	a5,80005f86 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f42:	ffffb097          	auipc	ra,0xffffb
    80005f46:	bb8080e7          	jalr	-1096(ra) # 80000afa <kalloc>
    80005f4a:	85aa                	mv	a1,a0
    80005f4c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f50:	cd11                	beqz	a0,80005f6c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f52:	6605                	lui	a2,0x1
    80005f54:	e3043503          	ld	a0,-464(s0)
    80005f58:	ffffd097          	auipc	ra,0xffffd
    80005f5c:	f98080e7          	jalr	-104(ra) # 80002ef0 <fetchstr>
    80005f60:	00054663          	bltz	a0,80005f6c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f64:	0905                	addi	s2,s2,1
    80005f66:	09a1                	addi	s3,s3,8
    80005f68:	fb491be3          	bne	s2,s4,80005f1e <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f6c:	10048913          	addi	s2,s1,256
    80005f70:	6088                	ld	a0,0(s1)
    80005f72:	c531                	beqz	a0,80005fbe <sys_exec+0xf8>
    kfree(argv[i]);
    80005f74:	ffffb097          	auipc	ra,0xffffb
    80005f78:	a8a080e7          	jalr	-1398(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f7c:	04a1                	addi	s1,s1,8
    80005f7e:	ff2499e3          	bne	s1,s2,80005f70 <sys_exec+0xaa>
  return -1;
    80005f82:	557d                	li	a0,-1
    80005f84:	a835                	j	80005fc0 <sys_exec+0xfa>
      argv[i] = 0;
    80005f86:	0a8e                	slli	s5,s5,0x3
    80005f88:	fc040793          	addi	a5,s0,-64
    80005f8c:	9abe                	add	s5,s5,a5
    80005f8e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f92:	e4040593          	addi	a1,s0,-448
    80005f96:	f4040513          	addi	a0,s0,-192
    80005f9a:	fffff097          	auipc	ra,0xfffff
    80005f9e:	190080e7          	jalr	400(ra) # 8000512a <exec>
    80005fa2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fa4:	10048993          	addi	s3,s1,256
    80005fa8:	6088                	ld	a0,0(s1)
    80005faa:	c901                	beqz	a0,80005fba <sys_exec+0xf4>
    kfree(argv[i]);
    80005fac:	ffffb097          	auipc	ra,0xffffb
    80005fb0:	a52080e7          	jalr	-1454(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fb4:	04a1                	addi	s1,s1,8
    80005fb6:	ff3499e3          	bne	s1,s3,80005fa8 <sys_exec+0xe2>
  return ret;
    80005fba:	854a                	mv	a0,s2
    80005fbc:	a011                	j	80005fc0 <sys_exec+0xfa>
  return -1;
    80005fbe:	557d                	li	a0,-1
}
    80005fc0:	60be                	ld	ra,456(sp)
    80005fc2:	641e                	ld	s0,448(sp)
    80005fc4:	74fa                	ld	s1,440(sp)
    80005fc6:	795a                	ld	s2,432(sp)
    80005fc8:	79ba                	ld	s3,424(sp)
    80005fca:	7a1a                	ld	s4,416(sp)
    80005fcc:	6afa                	ld	s5,408(sp)
    80005fce:	6179                	addi	sp,sp,464
    80005fd0:	8082                	ret

0000000080005fd2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005fd2:	7139                	addi	sp,sp,-64
    80005fd4:	fc06                	sd	ra,56(sp)
    80005fd6:	f822                	sd	s0,48(sp)
    80005fd8:	f426                	sd	s1,40(sp)
    80005fda:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005fdc:	ffffc097          	auipc	ra,0xffffc
    80005fe0:	9ea080e7          	jalr	-1558(ra) # 800019c6 <myproc>
    80005fe4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005fe6:	fd840593          	addi	a1,s0,-40
    80005fea:	4501                	li	a0,0
    80005fec:	ffffd097          	auipc	ra,0xffffd
    80005ff0:	f72080e7          	jalr	-142(ra) # 80002f5e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ff4:	fc840593          	addi	a1,s0,-56
    80005ff8:	fd040513          	addi	a0,s0,-48
    80005ffc:	fffff097          	auipc	ra,0xfffff
    80006000:	dd6080e7          	jalr	-554(ra) # 80004dd2 <pipealloc>
    return -1;
    80006004:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006006:	0c054463          	bltz	a0,800060ce <sys_pipe+0xfc>
  fd0 = -1;
    8000600a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000600e:	fd043503          	ld	a0,-48(s0)
    80006012:	fffff097          	auipc	ra,0xfffff
    80006016:	518080e7          	jalr	1304(ra) # 8000552a <fdalloc>
    8000601a:	fca42223          	sw	a0,-60(s0)
    8000601e:	08054b63          	bltz	a0,800060b4 <sys_pipe+0xe2>
    80006022:	fc843503          	ld	a0,-56(s0)
    80006026:	fffff097          	auipc	ra,0xfffff
    8000602a:	504080e7          	jalr	1284(ra) # 8000552a <fdalloc>
    8000602e:	fca42023          	sw	a0,-64(s0)
    80006032:	06054863          	bltz	a0,800060a2 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006036:	4691                	li	a3,4
    80006038:	fc440613          	addi	a2,s0,-60
    8000603c:	fd843583          	ld	a1,-40(s0)
    80006040:	68a8                	ld	a0,80(s1)
    80006042:	ffffb097          	auipc	ra,0xffffb
    80006046:	642080e7          	jalr	1602(ra) # 80001684 <copyout>
    8000604a:	02054063          	bltz	a0,8000606a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000604e:	4691                	li	a3,4
    80006050:	fc040613          	addi	a2,s0,-64
    80006054:	fd843583          	ld	a1,-40(s0)
    80006058:	0591                	addi	a1,a1,4
    8000605a:	68a8                	ld	a0,80(s1)
    8000605c:	ffffb097          	auipc	ra,0xffffb
    80006060:	628080e7          	jalr	1576(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006064:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006066:	06055463          	bgez	a0,800060ce <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000606a:	fc442783          	lw	a5,-60(s0)
    8000606e:	07e9                	addi	a5,a5,26
    80006070:	078e                	slli	a5,a5,0x3
    80006072:	97a6                	add	a5,a5,s1
    80006074:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006078:	fc042503          	lw	a0,-64(s0)
    8000607c:	0569                	addi	a0,a0,26
    8000607e:	050e                	slli	a0,a0,0x3
    80006080:	94aa                	add	s1,s1,a0
    80006082:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006086:	fd043503          	ld	a0,-48(s0)
    8000608a:	fffff097          	auipc	ra,0xfffff
    8000608e:	a18080e7          	jalr	-1512(ra) # 80004aa2 <fileclose>
    fileclose(wf);
    80006092:	fc843503          	ld	a0,-56(s0)
    80006096:	fffff097          	auipc	ra,0xfffff
    8000609a:	a0c080e7          	jalr	-1524(ra) # 80004aa2 <fileclose>
    return -1;
    8000609e:	57fd                	li	a5,-1
    800060a0:	a03d                	j	800060ce <sys_pipe+0xfc>
    if(fd0 >= 0)
    800060a2:	fc442783          	lw	a5,-60(s0)
    800060a6:	0007c763          	bltz	a5,800060b4 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800060aa:	07e9                	addi	a5,a5,26
    800060ac:	078e                	slli	a5,a5,0x3
    800060ae:	94be                	add	s1,s1,a5
    800060b0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800060b4:	fd043503          	ld	a0,-48(s0)
    800060b8:	fffff097          	auipc	ra,0xfffff
    800060bc:	9ea080e7          	jalr	-1558(ra) # 80004aa2 <fileclose>
    fileclose(wf);
    800060c0:	fc843503          	ld	a0,-56(s0)
    800060c4:	fffff097          	auipc	ra,0xfffff
    800060c8:	9de080e7          	jalr	-1570(ra) # 80004aa2 <fileclose>
    return -1;
    800060cc:	57fd                	li	a5,-1
}
    800060ce:	853e                	mv	a0,a5
    800060d0:	70e2                	ld	ra,56(sp)
    800060d2:	7442                	ld	s0,48(sp)
    800060d4:	74a2                	ld	s1,40(sp)
    800060d6:	6121                	addi	sp,sp,64
    800060d8:	8082                	ret
    800060da:	0000                	unimp
    800060dc:	0000                	unimp
	...

00000000800060e0 <kernelvec>:
    800060e0:	7111                	addi	sp,sp,-256
    800060e2:	e006                	sd	ra,0(sp)
    800060e4:	e40a                	sd	sp,8(sp)
    800060e6:	e80e                	sd	gp,16(sp)
    800060e8:	ec12                	sd	tp,24(sp)
    800060ea:	f016                	sd	t0,32(sp)
    800060ec:	f41a                	sd	t1,40(sp)
    800060ee:	f81e                	sd	t2,48(sp)
    800060f0:	fc22                	sd	s0,56(sp)
    800060f2:	e0a6                	sd	s1,64(sp)
    800060f4:	e4aa                	sd	a0,72(sp)
    800060f6:	e8ae                	sd	a1,80(sp)
    800060f8:	ecb2                	sd	a2,88(sp)
    800060fa:	f0b6                	sd	a3,96(sp)
    800060fc:	f4ba                	sd	a4,104(sp)
    800060fe:	f8be                	sd	a5,112(sp)
    80006100:	fcc2                	sd	a6,120(sp)
    80006102:	e146                	sd	a7,128(sp)
    80006104:	e54a                	sd	s2,136(sp)
    80006106:	e94e                	sd	s3,144(sp)
    80006108:	ed52                	sd	s4,152(sp)
    8000610a:	f156                	sd	s5,160(sp)
    8000610c:	f55a                	sd	s6,168(sp)
    8000610e:	f95e                	sd	s7,176(sp)
    80006110:	fd62                	sd	s8,184(sp)
    80006112:	e1e6                	sd	s9,192(sp)
    80006114:	e5ea                	sd	s10,200(sp)
    80006116:	e9ee                	sd	s11,208(sp)
    80006118:	edf2                	sd	t3,216(sp)
    8000611a:	f1f6                	sd	t4,224(sp)
    8000611c:	f5fa                	sd	t5,232(sp)
    8000611e:	f9fe                	sd	t6,240(sp)
    80006120:	c7dfc0ef          	jal	ra,80002d9c <kerneltrap>
    80006124:	6082                	ld	ra,0(sp)
    80006126:	6122                	ld	sp,8(sp)
    80006128:	61c2                	ld	gp,16(sp)
    8000612a:	7282                	ld	t0,32(sp)
    8000612c:	7322                	ld	t1,40(sp)
    8000612e:	73c2                	ld	t2,48(sp)
    80006130:	7462                	ld	s0,56(sp)
    80006132:	6486                	ld	s1,64(sp)
    80006134:	6526                	ld	a0,72(sp)
    80006136:	65c6                	ld	a1,80(sp)
    80006138:	6666                	ld	a2,88(sp)
    8000613a:	7686                	ld	a3,96(sp)
    8000613c:	7726                	ld	a4,104(sp)
    8000613e:	77c6                	ld	a5,112(sp)
    80006140:	7866                	ld	a6,120(sp)
    80006142:	688a                	ld	a7,128(sp)
    80006144:	692a                	ld	s2,136(sp)
    80006146:	69ca                	ld	s3,144(sp)
    80006148:	6a6a                	ld	s4,152(sp)
    8000614a:	7a8a                	ld	s5,160(sp)
    8000614c:	7b2a                	ld	s6,168(sp)
    8000614e:	7bca                	ld	s7,176(sp)
    80006150:	7c6a                	ld	s8,184(sp)
    80006152:	6c8e                	ld	s9,192(sp)
    80006154:	6d2e                	ld	s10,200(sp)
    80006156:	6dce                	ld	s11,208(sp)
    80006158:	6e6e                	ld	t3,216(sp)
    8000615a:	7e8e                	ld	t4,224(sp)
    8000615c:	7f2e                	ld	t5,232(sp)
    8000615e:	7fce                	ld	t6,240(sp)
    80006160:	6111                	addi	sp,sp,256
    80006162:	10200073          	sret
    80006166:	00000013          	nop
    8000616a:	00000013          	nop
    8000616e:	0001                	nop

0000000080006170 <timervec>:
    80006170:	34051573          	csrrw	a0,mscratch,a0
    80006174:	e10c                	sd	a1,0(a0)
    80006176:	e510                	sd	a2,8(a0)
    80006178:	e914                	sd	a3,16(a0)
    8000617a:	6d0c                	ld	a1,24(a0)
    8000617c:	7110                	ld	a2,32(a0)
    8000617e:	6194                	ld	a3,0(a1)
    80006180:	96b2                	add	a3,a3,a2
    80006182:	e194                	sd	a3,0(a1)
    80006184:	4589                	li	a1,2
    80006186:	14459073          	csrw	sip,a1
    8000618a:	6914                	ld	a3,16(a0)
    8000618c:	6510                	ld	a2,8(a0)
    8000618e:	610c                	ld	a1,0(a0)
    80006190:	34051573          	csrrw	a0,mscratch,a0
    80006194:	30200073          	mret
	...

000000008000619a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000619a:	1141                	addi	sp,sp,-16
    8000619c:	e422                	sd	s0,8(sp)
    8000619e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800061a0:	0c0007b7          	lui	a5,0xc000
    800061a4:	4705                	li	a4,1
    800061a6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800061a8:	c3d8                	sw	a4,4(a5)
}
    800061aa:	6422                	ld	s0,8(sp)
    800061ac:	0141                	addi	sp,sp,16
    800061ae:	8082                	ret

00000000800061b0 <plicinithart>:

void
plicinithart(void)
{
    800061b0:	1141                	addi	sp,sp,-16
    800061b2:	e406                	sd	ra,8(sp)
    800061b4:	e022                	sd	s0,0(sp)
    800061b6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061b8:	ffffb097          	auipc	ra,0xffffb
    800061bc:	7e2080e7          	jalr	2018(ra) # 8000199a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800061c0:	0085171b          	slliw	a4,a0,0x8
    800061c4:	0c0027b7          	lui	a5,0xc002
    800061c8:	97ba                	add	a5,a5,a4
    800061ca:	40200713          	li	a4,1026
    800061ce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800061d2:	00d5151b          	slliw	a0,a0,0xd
    800061d6:	0c2017b7          	lui	a5,0xc201
    800061da:	953e                	add	a0,a0,a5
    800061dc:	00052023          	sw	zero,0(a0)
}
    800061e0:	60a2                	ld	ra,8(sp)
    800061e2:	6402                	ld	s0,0(sp)
    800061e4:	0141                	addi	sp,sp,16
    800061e6:	8082                	ret

00000000800061e8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800061e8:	1141                	addi	sp,sp,-16
    800061ea:	e406                	sd	ra,8(sp)
    800061ec:	e022                	sd	s0,0(sp)
    800061ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061f0:	ffffb097          	auipc	ra,0xffffb
    800061f4:	7aa080e7          	jalr	1962(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800061f8:	00d5179b          	slliw	a5,a0,0xd
    800061fc:	0c201537          	lui	a0,0xc201
    80006200:	953e                	add	a0,a0,a5
  return irq;
}
    80006202:	4148                	lw	a0,4(a0)
    80006204:	60a2                	ld	ra,8(sp)
    80006206:	6402                	ld	s0,0(sp)
    80006208:	0141                	addi	sp,sp,16
    8000620a:	8082                	ret

000000008000620c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000620c:	1101                	addi	sp,sp,-32
    8000620e:	ec06                	sd	ra,24(sp)
    80006210:	e822                	sd	s0,16(sp)
    80006212:	e426                	sd	s1,8(sp)
    80006214:	1000                	addi	s0,sp,32
    80006216:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006218:	ffffb097          	auipc	ra,0xffffb
    8000621c:	782080e7          	jalr	1922(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006220:	00d5151b          	slliw	a0,a0,0xd
    80006224:	0c2017b7          	lui	a5,0xc201
    80006228:	97aa                	add	a5,a5,a0
    8000622a:	c3c4                	sw	s1,4(a5)
}
    8000622c:	60e2                	ld	ra,24(sp)
    8000622e:	6442                	ld	s0,16(sp)
    80006230:	64a2                	ld	s1,8(sp)
    80006232:	6105                	addi	sp,sp,32
    80006234:	8082                	ret

0000000080006236 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006236:	1141                	addi	sp,sp,-16
    80006238:	e406                	sd	ra,8(sp)
    8000623a:	e022                	sd	s0,0(sp)
    8000623c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000623e:	479d                	li	a5,7
    80006240:	04a7cc63          	blt	a5,a0,80006298 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006244:	0001c797          	auipc	a5,0x1c
    80006248:	3cc78793          	addi	a5,a5,972 # 80022610 <disk>
    8000624c:	97aa                	add	a5,a5,a0
    8000624e:	0187c783          	lbu	a5,24(a5)
    80006252:	ebb9                	bnez	a5,800062a8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006254:	00451613          	slli	a2,a0,0x4
    80006258:	0001c797          	auipc	a5,0x1c
    8000625c:	3b878793          	addi	a5,a5,952 # 80022610 <disk>
    80006260:	6394                	ld	a3,0(a5)
    80006262:	96b2                	add	a3,a3,a2
    80006264:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006268:	6398                	ld	a4,0(a5)
    8000626a:	9732                	add	a4,a4,a2
    8000626c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006270:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006274:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006278:	953e                	add	a0,a0,a5
    8000627a:	4785                	li	a5,1
    8000627c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006280:	0001c517          	auipc	a0,0x1c
    80006284:	3a850513          	addi	a0,a0,936 # 80022628 <disk+0x18>
    80006288:	ffffc097          	auipc	ra,0xffffc
    8000628c:	e46080e7          	jalr	-442(ra) # 800020ce <wakeup>
}
    80006290:	60a2                	ld	ra,8(sp)
    80006292:	6402                	ld	s0,0(sp)
    80006294:	0141                	addi	sp,sp,16
    80006296:	8082                	ret
    panic("free_desc 1");
    80006298:	00002517          	auipc	a0,0x2
    8000629c:	6b850513          	addi	a0,a0,1720 # 80008950 <syscalls+0x320>
    800062a0:	ffffa097          	auipc	ra,0xffffa
    800062a4:	2a4080e7          	jalr	676(ra) # 80000544 <panic>
    panic("free_desc 2");
    800062a8:	00002517          	auipc	a0,0x2
    800062ac:	6b850513          	addi	a0,a0,1720 # 80008960 <syscalls+0x330>
    800062b0:	ffffa097          	auipc	ra,0xffffa
    800062b4:	294080e7          	jalr	660(ra) # 80000544 <panic>

00000000800062b8 <virtio_disk_init>:
{
    800062b8:	1101                	addi	sp,sp,-32
    800062ba:	ec06                	sd	ra,24(sp)
    800062bc:	e822                	sd	s0,16(sp)
    800062be:	e426                	sd	s1,8(sp)
    800062c0:	e04a                	sd	s2,0(sp)
    800062c2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800062c4:	00002597          	auipc	a1,0x2
    800062c8:	6ac58593          	addi	a1,a1,1708 # 80008970 <syscalls+0x340>
    800062cc:	0001c517          	auipc	a0,0x1c
    800062d0:	46c50513          	addi	a0,a0,1132 # 80022738 <disk+0x128>
    800062d4:	ffffb097          	auipc	ra,0xffffb
    800062d8:	886080e7          	jalr	-1914(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062dc:	100017b7          	lui	a5,0x10001
    800062e0:	4398                	lw	a4,0(a5)
    800062e2:	2701                	sext.w	a4,a4
    800062e4:	747277b7          	lui	a5,0x74727
    800062e8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800062ec:	14f71e63          	bne	a4,a5,80006448 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062f0:	100017b7          	lui	a5,0x10001
    800062f4:	43dc                	lw	a5,4(a5)
    800062f6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062f8:	4709                	li	a4,2
    800062fa:	14e79763          	bne	a5,a4,80006448 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062fe:	100017b7          	lui	a5,0x10001
    80006302:	479c                	lw	a5,8(a5)
    80006304:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006306:	14e79163          	bne	a5,a4,80006448 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000630a:	100017b7          	lui	a5,0x10001
    8000630e:	47d8                	lw	a4,12(a5)
    80006310:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006312:	554d47b7          	lui	a5,0x554d4
    80006316:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000631a:	12f71763          	bne	a4,a5,80006448 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000631e:	100017b7          	lui	a5,0x10001
    80006322:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006326:	4705                	li	a4,1
    80006328:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000632a:	470d                	li	a4,3
    8000632c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000632e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006330:	c7ffe737          	lui	a4,0xc7ffe
    80006334:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc00f>
    80006338:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000633a:	2701                	sext.w	a4,a4
    8000633c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000633e:	472d                	li	a4,11
    80006340:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006342:	0707a903          	lw	s2,112(a5)
    80006346:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006348:	00897793          	andi	a5,s2,8
    8000634c:	10078663          	beqz	a5,80006458 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006350:	100017b7          	lui	a5,0x10001
    80006354:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006358:	43fc                	lw	a5,68(a5)
    8000635a:	2781                	sext.w	a5,a5
    8000635c:	10079663          	bnez	a5,80006468 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006360:	100017b7          	lui	a5,0x10001
    80006364:	5bdc                	lw	a5,52(a5)
    80006366:	2781                	sext.w	a5,a5
  if(max == 0)
    80006368:	10078863          	beqz	a5,80006478 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000636c:	471d                	li	a4,7
    8000636e:	10f77d63          	bgeu	a4,a5,80006488 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006372:	ffffa097          	auipc	ra,0xffffa
    80006376:	788080e7          	jalr	1928(ra) # 80000afa <kalloc>
    8000637a:	0001c497          	auipc	s1,0x1c
    8000637e:	29648493          	addi	s1,s1,662 # 80022610 <disk>
    80006382:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006384:	ffffa097          	auipc	ra,0xffffa
    80006388:	776080e7          	jalr	1910(ra) # 80000afa <kalloc>
    8000638c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000638e:	ffffa097          	auipc	ra,0xffffa
    80006392:	76c080e7          	jalr	1900(ra) # 80000afa <kalloc>
    80006396:	87aa                	mv	a5,a0
    80006398:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000639a:	6088                	ld	a0,0(s1)
    8000639c:	cd75                	beqz	a0,80006498 <virtio_disk_init+0x1e0>
    8000639e:	0001c717          	auipc	a4,0x1c
    800063a2:	27a73703          	ld	a4,634(a4) # 80022618 <disk+0x8>
    800063a6:	cb6d                	beqz	a4,80006498 <virtio_disk_init+0x1e0>
    800063a8:	cbe5                	beqz	a5,80006498 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    800063aa:	6605                	lui	a2,0x1
    800063ac:	4581                	li	a1,0
    800063ae:	ffffb097          	auipc	ra,0xffffb
    800063b2:	938080e7          	jalr	-1736(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    800063b6:	0001c497          	auipc	s1,0x1c
    800063ba:	25a48493          	addi	s1,s1,602 # 80022610 <disk>
    800063be:	6605                	lui	a2,0x1
    800063c0:	4581                	li	a1,0
    800063c2:	6488                	ld	a0,8(s1)
    800063c4:	ffffb097          	auipc	ra,0xffffb
    800063c8:	922080e7          	jalr	-1758(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    800063cc:	6605                	lui	a2,0x1
    800063ce:	4581                	li	a1,0
    800063d0:	6888                	ld	a0,16(s1)
    800063d2:	ffffb097          	auipc	ra,0xffffb
    800063d6:	914080e7          	jalr	-1772(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063da:	100017b7          	lui	a5,0x10001
    800063de:	4721                	li	a4,8
    800063e0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800063e2:	4098                	lw	a4,0(s1)
    800063e4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800063e8:	40d8                	lw	a4,4(s1)
    800063ea:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800063ee:	6498                	ld	a4,8(s1)
    800063f0:	0007069b          	sext.w	a3,a4
    800063f4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800063f8:	9701                	srai	a4,a4,0x20
    800063fa:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800063fe:	6898                	ld	a4,16(s1)
    80006400:	0007069b          	sext.w	a3,a4
    80006404:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006408:	9701                	srai	a4,a4,0x20
    8000640a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000640e:	4685                	li	a3,1
    80006410:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006412:	4705                	li	a4,1
    80006414:	00d48c23          	sb	a3,24(s1)
    80006418:	00e48ca3          	sb	a4,25(s1)
    8000641c:	00e48d23          	sb	a4,26(s1)
    80006420:	00e48da3          	sb	a4,27(s1)
    80006424:	00e48e23          	sb	a4,28(s1)
    80006428:	00e48ea3          	sb	a4,29(s1)
    8000642c:	00e48f23          	sb	a4,30(s1)
    80006430:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006434:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006438:	0727a823          	sw	s2,112(a5)
}
    8000643c:	60e2                	ld	ra,24(sp)
    8000643e:	6442                	ld	s0,16(sp)
    80006440:	64a2                	ld	s1,8(sp)
    80006442:	6902                	ld	s2,0(sp)
    80006444:	6105                	addi	sp,sp,32
    80006446:	8082                	ret
    panic("could not find virtio disk");
    80006448:	00002517          	auipc	a0,0x2
    8000644c:	53850513          	addi	a0,a0,1336 # 80008980 <syscalls+0x350>
    80006450:	ffffa097          	auipc	ra,0xffffa
    80006454:	0f4080e7          	jalr	244(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006458:	00002517          	auipc	a0,0x2
    8000645c:	54850513          	addi	a0,a0,1352 # 800089a0 <syscalls+0x370>
    80006460:	ffffa097          	auipc	ra,0xffffa
    80006464:	0e4080e7          	jalr	228(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006468:	00002517          	auipc	a0,0x2
    8000646c:	55850513          	addi	a0,a0,1368 # 800089c0 <syscalls+0x390>
    80006470:	ffffa097          	auipc	ra,0xffffa
    80006474:	0d4080e7          	jalr	212(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006478:	00002517          	auipc	a0,0x2
    8000647c:	56850513          	addi	a0,a0,1384 # 800089e0 <syscalls+0x3b0>
    80006480:	ffffa097          	auipc	ra,0xffffa
    80006484:	0c4080e7          	jalr	196(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006488:	00002517          	auipc	a0,0x2
    8000648c:	57850513          	addi	a0,a0,1400 # 80008a00 <syscalls+0x3d0>
    80006490:	ffffa097          	auipc	ra,0xffffa
    80006494:	0b4080e7          	jalr	180(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006498:	00002517          	auipc	a0,0x2
    8000649c:	58850513          	addi	a0,a0,1416 # 80008a20 <syscalls+0x3f0>
    800064a0:	ffffa097          	auipc	ra,0xffffa
    800064a4:	0a4080e7          	jalr	164(ra) # 80000544 <panic>

00000000800064a8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800064a8:	7159                	addi	sp,sp,-112
    800064aa:	f486                	sd	ra,104(sp)
    800064ac:	f0a2                	sd	s0,96(sp)
    800064ae:	eca6                	sd	s1,88(sp)
    800064b0:	e8ca                	sd	s2,80(sp)
    800064b2:	e4ce                	sd	s3,72(sp)
    800064b4:	e0d2                	sd	s4,64(sp)
    800064b6:	fc56                	sd	s5,56(sp)
    800064b8:	f85a                	sd	s6,48(sp)
    800064ba:	f45e                	sd	s7,40(sp)
    800064bc:	f062                	sd	s8,32(sp)
    800064be:	ec66                	sd	s9,24(sp)
    800064c0:	e86a                	sd	s10,16(sp)
    800064c2:	1880                	addi	s0,sp,112
    800064c4:	892a                	mv	s2,a0
    800064c6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064c8:	00c52c83          	lw	s9,12(a0)
    800064cc:	001c9c9b          	slliw	s9,s9,0x1
    800064d0:	1c82                	slli	s9,s9,0x20
    800064d2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800064d6:	0001c517          	auipc	a0,0x1c
    800064da:	26250513          	addi	a0,a0,610 # 80022738 <disk+0x128>
    800064de:	ffffa097          	auipc	ra,0xffffa
    800064e2:	70c080e7          	jalr	1804(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    800064e6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064e8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800064ea:	0001cb17          	auipc	s6,0x1c
    800064ee:	126b0b13          	addi	s6,s6,294 # 80022610 <disk>
  for(int i = 0; i < 3; i++){
    800064f2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800064f4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064f6:	0001cc17          	auipc	s8,0x1c
    800064fa:	242c0c13          	addi	s8,s8,578 # 80022738 <disk+0x128>
    800064fe:	a8b5                	j	8000657a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006500:	00fb06b3          	add	a3,s6,a5
    80006504:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006508:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000650a:	0207c563          	bltz	a5,80006534 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000650e:	2485                	addiw	s1,s1,1
    80006510:	0711                	addi	a4,a4,4
    80006512:	1f548a63          	beq	s1,s5,80006706 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006516:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006518:	0001c697          	auipc	a3,0x1c
    8000651c:	0f868693          	addi	a3,a3,248 # 80022610 <disk>
    80006520:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006522:	0186c583          	lbu	a1,24(a3)
    80006526:	fde9                	bnez	a1,80006500 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006528:	2785                	addiw	a5,a5,1
    8000652a:	0685                	addi	a3,a3,1
    8000652c:	ff779be3          	bne	a5,s7,80006522 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006530:	57fd                	li	a5,-1
    80006532:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006534:	02905a63          	blez	s1,80006568 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006538:	f9042503          	lw	a0,-112(s0)
    8000653c:	00000097          	auipc	ra,0x0
    80006540:	cfa080e7          	jalr	-774(ra) # 80006236 <free_desc>
      for(int j = 0; j < i; j++)
    80006544:	4785                	li	a5,1
    80006546:	0297d163          	bge	a5,s1,80006568 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000654a:	f9442503          	lw	a0,-108(s0)
    8000654e:	00000097          	auipc	ra,0x0
    80006552:	ce8080e7          	jalr	-792(ra) # 80006236 <free_desc>
      for(int j = 0; j < i; j++)
    80006556:	4789                	li	a5,2
    80006558:	0097d863          	bge	a5,s1,80006568 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000655c:	f9842503          	lw	a0,-104(s0)
    80006560:	00000097          	auipc	ra,0x0
    80006564:	cd6080e7          	jalr	-810(ra) # 80006236 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006568:	85e2                	mv	a1,s8
    8000656a:	0001c517          	auipc	a0,0x1c
    8000656e:	0be50513          	addi	a0,a0,190 # 80022628 <disk+0x18>
    80006572:	ffffc097          	auipc	ra,0xffffc
    80006576:	af8080e7          	jalr	-1288(ra) # 8000206a <sleep>
  for(int i = 0; i < 3; i++){
    8000657a:	f9040713          	addi	a4,s0,-112
    8000657e:	84ce                	mv	s1,s3
    80006580:	bf59                	j	80006516 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006582:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006586:	00479693          	slli	a3,a5,0x4
    8000658a:	0001c797          	auipc	a5,0x1c
    8000658e:	08678793          	addi	a5,a5,134 # 80022610 <disk>
    80006592:	97b6                	add	a5,a5,a3
    80006594:	4685                	li	a3,1
    80006596:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006598:	0001c597          	auipc	a1,0x1c
    8000659c:	07858593          	addi	a1,a1,120 # 80022610 <disk>
    800065a0:	00a60793          	addi	a5,a2,10
    800065a4:	0792                	slli	a5,a5,0x4
    800065a6:	97ae                	add	a5,a5,a1
    800065a8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800065ac:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800065b0:	f6070693          	addi	a3,a4,-160
    800065b4:	619c                	ld	a5,0(a1)
    800065b6:	97b6                	add	a5,a5,a3
    800065b8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800065ba:	6188                	ld	a0,0(a1)
    800065bc:	96aa                	add	a3,a3,a0
    800065be:	47c1                	li	a5,16
    800065c0:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800065c2:	4785                	li	a5,1
    800065c4:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800065c8:	f9442783          	lw	a5,-108(s0)
    800065cc:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800065d0:	0792                	slli	a5,a5,0x4
    800065d2:	953e                	add	a0,a0,a5
    800065d4:	05890693          	addi	a3,s2,88
    800065d8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800065da:	6188                	ld	a0,0(a1)
    800065dc:	97aa                	add	a5,a5,a0
    800065de:	40000693          	li	a3,1024
    800065e2:	c794                	sw	a3,8(a5)
  if(write)
    800065e4:	100d0d63          	beqz	s10,800066fe <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800065e8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065ec:	00c7d683          	lhu	a3,12(a5)
    800065f0:	0016e693          	ori	a3,a3,1
    800065f4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800065f8:	f9842583          	lw	a1,-104(s0)
    800065fc:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006600:	0001c697          	auipc	a3,0x1c
    80006604:	01068693          	addi	a3,a3,16 # 80022610 <disk>
    80006608:	00260793          	addi	a5,a2,2
    8000660c:	0792                	slli	a5,a5,0x4
    8000660e:	97b6                	add	a5,a5,a3
    80006610:	587d                	li	a6,-1
    80006612:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006616:	0592                	slli	a1,a1,0x4
    80006618:	952e                	add	a0,a0,a1
    8000661a:	f9070713          	addi	a4,a4,-112
    8000661e:	9736                	add	a4,a4,a3
    80006620:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006622:	6298                	ld	a4,0(a3)
    80006624:	972e                	add	a4,a4,a1
    80006626:	4585                	li	a1,1
    80006628:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000662a:	4509                	li	a0,2
    8000662c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006630:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006634:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006638:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000663c:	6698                	ld	a4,8(a3)
    8000663e:	00275783          	lhu	a5,2(a4)
    80006642:	8b9d                	andi	a5,a5,7
    80006644:	0786                	slli	a5,a5,0x1
    80006646:	97ba                	add	a5,a5,a4
    80006648:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000664c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006650:	6698                	ld	a4,8(a3)
    80006652:	00275783          	lhu	a5,2(a4)
    80006656:	2785                	addiw	a5,a5,1
    80006658:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000665c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006660:	100017b7          	lui	a5,0x10001
    80006664:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006668:	00492703          	lw	a4,4(s2)
    8000666c:	4785                	li	a5,1
    8000666e:	02f71163          	bne	a4,a5,80006690 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006672:	0001c997          	auipc	s3,0x1c
    80006676:	0c698993          	addi	s3,s3,198 # 80022738 <disk+0x128>
  while(b->disk == 1) {
    8000667a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000667c:	85ce                	mv	a1,s3
    8000667e:	854a                	mv	a0,s2
    80006680:	ffffc097          	auipc	ra,0xffffc
    80006684:	9ea080e7          	jalr	-1558(ra) # 8000206a <sleep>
  while(b->disk == 1) {
    80006688:	00492783          	lw	a5,4(s2)
    8000668c:	fe9788e3          	beq	a5,s1,8000667c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006690:	f9042903          	lw	s2,-112(s0)
    80006694:	00290793          	addi	a5,s2,2
    80006698:	00479713          	slli	a4,a5,0x4
    8000669c:	0001c797          	auipc	a5,0x1c
    800066a0:	f7478793          	addi	a5,a5,-140 # 80022610 <disk>
    800066a4:	97ba                	add	a5,a5,a4
    800066a6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800066aa:	0001c997          	auipc	s3,0x1c
    800066ae:	f6698993          	addi	s3,s3,-154 # 80022610 <disk>
    800066b2:	00491713          	slli	a4,s2,0x4
    800066b6:	0009b783          	ld	a5,0(s3)
    800066ba:	97ba                	add	a5,a5,a4
    800066bc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800066c0:	854a                	mv	a0,s2
    800066c2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800066c6:	00000097          	auipc	ra,0x0
    800066ca:	b70080e7          	jalr	-1168(ra) # 80006236 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800066ce:	8885                	andi	s1,s1,1
    800066d0:	f0ed                	bnez	s1,800066b2 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066d2:	0001c517          	auipc	a0,0x1c
    800066d6:	06650513          	addi	a0,a0,102 # 80022738 <disk+0x128>
    800066da:	ffffa097          	auipc	ra,0xffffa
    800066de:	5c4080e7          	jalr	1476(ra) # 80000c9e <release>
}
    800066e2:	70a6                	ld	ra,104(sp)
    800066e4:	7406                	ld	s0,96(sp)
    800066e6:	64e6                	ld	s1,88(sp)
    800066e8:	6946                	ld	s2,80(sp)
    800066ea:	69a6                	ld	s3,72(sp)
    800066ec:	6a06                	ld	s4,64(sp)
    800066ee:	7ae2                	ld	s5,56(sp)
    800066f0:	7b42                	ld	s6,48(sp)
    800066f2:	7ba2                	ld	s7,40(sp)
    800066f4:	7c02                	ld	s8,32(sp)
    800066f6:	6ce2                	ld	s9,24(sp)
    800066f8:	6d42                	ld	s10,16(sp)
    800066fa:	6165                	addi	sp,sp,112
    800066fc:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800066fe:	4689                	li	a3,2
    80006700:	00d79623          	sh	a3,12(a5)
    80006704:	b5e5                	j	800065ec <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006706:	f9042603          	lw	a2,-112(s0)
    8000670a:	00a60713          	addi	a4,a2,10
    8000670e:	0712                	slli	a4,a4,0x4
    80006710:	0001c517          	auipc	a0,0x1c
    80006714:	f0850513          	addi	a0,a0,-248 # 80022618 <disk+0x8>
    80006718:	953a                	add	a0,a0,a4
  if(write)
    8000671a:	e60d14e3          	bnez	s10,80006582 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000671e:	00a60793          	addi	a5,a2,10
    80006722:	00479693          	slli	a3,a5,0x4
    80006726:	0001c797          	auipc	a5,0x1c
    8000672a:	eea78793          	addi	a5,a5,-278 # 80022610 <disk>
    8000672e:	97b6                	add	a5,a5,a3
    80006730:	0007a423          	sw	zero,8(a5)
    80006734:	b595                	j	80006598 <virtio_disk_rw+0xf0>

0000000080006736 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006736:	1101                	addi	sp,sp,-32
    80006738:	ec06                	sd	ra,24(sp)
    8000673a:	e822                	sd	s0,16(sp)
    8000673c:	e426                	sd	s1,8(sp)
    8000673e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006740:	0001c497          	auipc	s1,0x1c
    80006744:	ed048493          	addi	s1,s1,-304 # 80022610 <disk>
    80006748:	0001c517          	auipc	a0,0x1c
    8000674c:	ff050513          	addi	a0,a0,-16 # 80022738 <disk+0x128>
    80006750:	ffffa097          	auipc	ra,0xffffa
    80006754:	49a080e7          	jalr	1178(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006758:	10001737          	lui	a4,0x10001
    8000675c:	533c                	lw	a5,96(a4)
    8000675e:	8b8d                	andi	a5,a5,3
    80006760:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006762:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006766:	689c                	ld	a5,16(s1)
    80006768:	0204d703          	lhu	a4,32(s1)
    8000676c:	0027d783          	lhu	a5,2(a5)
    80006770:	04f70863          	beq	a4,a5,800067c0 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006774:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006778:	6898                	ld	a4,16(s1)
    8000677a:	0204d783          	lhu	a5,32(s1)
    8000677e:	8b9d                	andi	a5,a5,7
    80006780:	078e                	slli	a5,a5,0x3
    80006782:	97ba                	add	a5,a5,a4
    80006784:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006786:	00278713          	addi	a4,a5,2
    8000678a:	0712                	slli	a4,a4,0x4
    8000678c:	9726                	add	a4,a4,s1
    8000678e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006792:	e721                	bnez	a4,800067da <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006794:	0789                	addi	a5,a5,2
    80006796:	0792                	slli	a5,a5,0x4
    80006798:	97a6                	add	a5,a5,s1
    8000679a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000679c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800067a0:	ffffc097          	auipc	ra,0xffffc
    800067a4:	92e080e7          	jalr	-1746(ra) # 800020ce <wakeup>

    disk.used_idx += 1;
    800067a8:	0204d783          	lhu	a5,32(s1)
    800067ac:	2785                	addiw	a5,a5,1
    800067ae:	17c2                	slli	a5,a5,0x30
    800067b0:	93c1                	srli	a5,a5,0x30
    800067b2:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800067b6:	6898                	ld	a4,16(s1)
    800067b8:	00275703          	lhu	a4,2(a4)
    800067bc:	faf71ce3          	bne	a4,a5,80006774 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800067c0:	0001c517          	auipc	a0,0x1c
    800067c4:	f7850513          	addi	a0,a0,-136 # 80022738 <disk+0x128>
    800067c8:	ffffa097          	auipc	ra,0xffffa
    800067cc:	4d6080e7          	jalr	1238(ra) # 80000c9e <release>
}
    800067d0:	60e2                	ld	ra,24(sp)
    800067d2:	6442                	ld	s0,16(sp)
    800067d4:	64a2                	ld	s1,8(sp)
    800067d6:	6105                	addi	sp,sp,32
    800067d8:	8082                	ret
      panic("virtio_disk_intr status");
    800067da:	00002517          	auipc	a0,0x2
    800067de:	25e50513          	addi	a0,a0,606 # 80008a38 <syscalls+0x408>
    800067e2:	ffffa097          	auipc	ra,0xffffa
    800067e6:	d62080e7          	jalr	-670(ra) # 80000544 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
