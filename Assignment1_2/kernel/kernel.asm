
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
    80000ede:	c0e080e7          	jalr	-1010(ra) # 80002ae8 <trapinithart>
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
    80000f56:	b6e080e7          	jalr	-1170(ra) # 80002ac0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	b8e080e7          	jalr	-1138(ra) # 80002ae8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	238080e7          	jalr	568(ra) # 8000619a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	246080e7          	jalr	582(ra) # 800061b0 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	3f8080e7          	jalr	1016(ra) # 8000336a <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	a9c080e7          	jalr	-1380(ra) # 80003a16 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	a3a080e7          	jalr	-1478(ra) # 800049bc <fileinit>
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
    80001a24:	0e0080e7          	jalr	224(ra) # 80002b00 <usertrapret>
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
    80001a3e:	f5c080e7          	jalr	-164(ra) # 80003996 <fsinit>
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
    80001d00:	6bc080e7          	jalr	1724(ra) # 800043b8 <namei>
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
    80001e1e:	c34080e7          	jalr	-972(ra) # 80004a4e <filedup>
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
    80001e40:	d98080e7          	jalr	-616(ra) # 80003bd4 <idup>
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
    80001f2c:	b2e080e7          	jalr	-1234(ra) # 80002a56 <swtch>
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
    80001fd0:	a8a080e7          	jalr	-1398(ra) # 80002a56 <swtch>
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
    800021f8:	8ac080e7          	jalr	-1876(ra) # 80004aa0 <fileclose>
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
    80002210:	3c8080e7          	jalr	968(ra) # 800045d4 <begin_op>
  iput(p->cwd);
    80002214:	1509b503          	ld	a0,336(s3)
    80002218:	00002097          	auipc	ra,0x2
    8000221c:	bb4080e7          	jalr	-1100(ra) # 80003dcc <iput>
  end_op();
    80002220:	00002097          	auipc	ra,0x2
    80002224:	434080e7          	jalr	1076(ra) # 80004654 <end_op>
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
    80002754:	2fe080e7          	jalr	766(ra) # 80004a4e <filedup>
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
    80002776:	462080e7          	jalr	1122(ra) # 80003bd4 <idup>
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
    80002942:	05348c63          	beq	s1,s3,8000299a <waitall+0x12e>
      acquire(&pp->lock);
    80002946:	8526                	mv	a0,s1
    80002948:	ffffe097          	auipc	ra,0xffffe
    8000294c:	2a2080e7          	jalr	674(ra) # 80000bea <acquire>
      if (pp->parent == p && pp->state == ZOMBIE) {
    80002950:	7c9c                	ld	a5,56(s1)
    80002952:	ff2791e3          	bne	a5,s2,80002934 <waitall+0xc8>
    80002956:	4c9c                	lw	a5,24(s1)
    80002958:	fd479ee3          	bne	a5,s4,80002934 <waitall+0xc8>
        local_statuses[count++] = pp->xstate;
    8000295c:	f8c42783          	lw	a5,-116(s0)
    80002960:	0017871b          	addiw	a4,a5,1
    80002964:	f8e42623          	sw	a4,-116(s0)
    80002968:	54d0                	lw	a2,44(s1)
    8000296a:	078a                	slli	a5,a5,0x2
    8000296c:	f9040713          	addi	a4,s0,-112
    80002970:	97ba                	add	a5,a5,a4
    80002972:	eec7ac23          	sw	a2,-264(a5)
        printf("[waitall] Found zombie child PID %d with xstate = %d\n", pp->pid, pp->xstate);
    80002976:	588c                	lw	a1,48(s1)
    80002978:	8566                	mv	a0,s9
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	c14080e7          	jalr	-1004(ra) # 8000058e <printf>
        release(&pp->lock);
    80002982:	8526                	mv	a0,s1
    80002984:	ffffe097          	auipc	ra,0xffffe
    80002988:	31a080e7          	jalr	794(ra) # 80000c9e <release>
        freeproc(pp);
    8000298c:	8526                	mv	a0,s1
    8000298e:	fffff097          	auipc	ra,0xfffff
    80002992:	1ea080e7          	jalr	490(ra) # 80001b78 <freeproc>
        found = 1;
    80002996:	8be2                	mv	s7,s8
        continue;
    80002998:	b75d                	j	8000293e <waitall+0xd2>
    if (count >= expected_n || !found)
    8000299a:	f8c42583          	lw	a1,-116(s0)
    8000299e:	e8442783          	lw	a5,-380(s0)
    800029a2:	00f5d463          	bge	a1,a5,800029aa <waitall+0x13e>
    800029a6:	060b9863          	bnez	s7,80002a16 <waitall+0x1aa>
  release(&wait_lock);
    800029aa:	0000e517          	auipc	a0,0xe
    800029ae:	3ae50513          	addi	a0,a0,942 # 80010d58 <wait_lock>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	2ec080e7          	jalr	748(ra) # 80000c9e <release>
  printf("[waitall] All children handled, total statuses = %d\n", count);
    800029ba:	f8c42583          	lw	a1,-116(s0)
    800029be:	00006517          	auipc	a0,0x6
    800029c2:	9f250513          	addi	a0,a0,-1550 # 800083b0 <digits+0x370>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	bc8080e7          	jalr	-1080(ra) # 8000058e <printf>
  if (copyout(p->pagetable, (uint64)n, (char *)&count, sizeof(int)) < 0) {
    800029ce:	4691                	li	a3,4
    800029d0:	f8c40613          	addi	a2,s0,-116
    800029d4:	85d6                	mv	a1,s5
    800029d6:	05093503          	ld	a0,80(s2)
    800029da:	fffff097          	auipc	ra,0xfffff
    800029de:	caa080e7          	jalr	-854(ra) # 80001684 <copyout>
    800029e2:	04054663          	bltz	a0,80002a2e <waitall+0x1c2>
  if (copyout(p->pagetable, (uint64)statuses, (char *)local_statuses, sizeof(int) * count) < 0) {
    800029e6:	f8c42683          	lw	a3,-116(s0)
    800029ea:	068a                	slli	a3,a3,0x2
    800029ec:	e8840613          	addi	a2,s0,-376
    800029f0:	85da                	mv	a1,s6
    800029f2:	05093503          	ld	a0,80(s2)
    800029f6:	fffff097          	auipc	ra,0xfffff
    800029fa:	c8e080e7          	jalr	-882(ra) # 80001684 <copyout>
    800029fe:	04054263          	bltz	a0,80002a42 <waitall+0x1d6>
  printf("[waitall] Successfully copied statuses and count\n");
    80002a02:	00006517          	auipc	a0,0x6
    80002a06:	a4e50513          	addi	a0,a0,-1458 # 80008450 <digits+0x410>
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	b84080e7          	jalr	-1148(ra) # 8000058e <printf>
  return 0;
    80002a12:	4501                	li	a0,0
    80002a14:	b5c9                	j	800028d6 <waitall+0x6a>
    printf("[waitall] Sleeping... %d statuses collected so far\n", count);
    80002a16:	856e                	mv	a0,s11
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	b76080e7          	jalr	-1162(ra) # 8000058e <printf>
    sleep(p, &wait_lock);
    80002a20:	85ea                	mv	a1,s10
    80002a22:	854a                	mv	a0,s2
    80002a24:	fffff097          	auipc	ra,0xfffff
    80002a28:	646080e7          	jalr	1606(ra) # 8000206a <sleep>
  while (1) {
    80002a2c:	bdf5                	j	80002928 <waitall+0xbc>
    printf("[waitall] Failed to copy 'n' to user space\n");
    80002a2e:	00006517          	auipc	a0,0x6
    80002a32:	9ba50513          	addi	a0,a0,-1606 # 800083e8 <digits+0x3a8>
    80002a36:	ffffe097          	auipc	ra,0xffffe
    80002a3a:	b58080e7          	jalr	-1192(ra) # 8000058e <printf>
    return -1;
    80002a3e:	557d                	li	a0,-1
    80002a40:	bd59                	j	800028d6 <waitall+0x6a>
    printf("[waitall] Failed to copy statuses to user space\n");
    80002a42:	00006517          	auipc	a0,0x6
    80002a46:	9d650513          	addi	a0,a0,-1578 # 80008418 <digits+0x3d8>
    80002a4a:	ffffe097          	auipc	ra,0xffffe
    80002a4e:	b44080e7          	jalr	-1212(ra) # 8000058e <printf>
    return -1;
    80002a52:	557d                	li	a0,-1
    80002a54:	b549                	j	800028d6 <waitall+0x6a>

0000000080002a56 <swtch>:
    80002a56:	00153023          	sd	ra,0(a0)
    80002a5a:	00253423          	sd	sp,8(a0)
    80002a5e:	e900                	sd	s0,16(a0)
    80002a60:	ed04                	sd	s1,24(a0)
    80002a62:	03253023          	sd	s2,32(a0)
    80002a66:	03353423          	sd	s3,40(a0)
    80002a6a:	03453823          	sd	s4,48(a0)
    80002a6e:	03553c23          	sd	s5,56(a0)
    80002a72:	05653023          	sd	s6,64(a0)
    80002a76:	05753423          	sd	s7,72(a0)
    80002a7a:	05853823          	sd	s8,80(a0)
    80002a7e:	05953c23          	sd	s9,88(a0)
    80002a82:	07a53023          	sd	s10,96(a0)
    80002a86:	07b53423          	sd	s11,104(a0)
    80002a8a:	0005b083          	ld	ra,0(a1)
    80002a8e:	0085b103          	ld	sp,8(a1)
    80002a92:	6980                	ld	s0,16(a1)
    80002a94:	6d84                	ld	s1,24(a1)
    80002a96:	0205b903          	ld	s2,32(a1)
    80002a9a:	0285b983          	ld	s3,40(a1)
    80002a9e:	0305ba03          	ld	s4,48(a1)
    80002aa2:	0385ba83          	ld	s5,56(a1)
    80002aa6:	0405bb03          	ld	s6,64(a1)
    80002aaa:	0485bb83          	ld	s7,72(a1)
    80002aae:	0505bc03          	ld	s8,80(a1)
    80002ab2:	0585bc83          	ld	s9,88(a1)
    80002ab6:	0605bd03          	ld	s10,96(a1)
    80002aba:	0685bd83          	ld	s11,104(a1)
    80002abe:	8082                	ret

0000000080002ac0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002ac0:	1141                	addi	sp,sp,-16
    80002ac2:	e406                	sd	ra,8(sp)
    80002ac4:	e022                	sd	s0,0(sp)
    80002ac6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ac8:	00006597          	auipc	a1,0x6
    80002acc:	a2058593          	addi	a1,a1,-1504 # 800084e8 <states.1757+0x30>
    80002ad0:	00015517          	auipc	a0,0x15
    80002ad4:	8a050513          	addi	a0,a0,-1888 # 80017370 <tickslock>
    80002ad8:	ffffe097          	auipc	ra,0xffffe
    80002adc:	082080e7          	jalr	130(ra) # 80000b5a <initlock>
}
    80002ae0:	60a2                	ld	ra,8(sp)
    80002ae2:	6402                	ld	s0,0(sp)
    80002ae4:	0141                	addi	sp,sp,16
    80002ae6:	8082                	ret

0000000080002ae8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002ae8:	1141                	addi	sp,sp,-16
    80002aea:	e422                	sd	s0,8(sp)
    80002aec:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002aee:	00003797          	auipc	a5,0x3
    80002af2:	5f278793          	addi	a5,a5,1522 # 800060e0 <kernelvec>
    80002af6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002afa:	6422                	ld	s0,8(sp)
    80002afc:	0141                	addi	sp,sp,16
    80002afe:	8082                	ret

0000000080002b00 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b00:	1141                	addi	sp,sp,-16
    80002b02:	e406                	sd	ra,8(sp)
    80002b04:	e022                	sd	s0,0(sp)
    80002b06:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	ebe080e7          	jalr	-322(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b10:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b14:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b16:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b1a:	00004617          	auipc	a2,0x4
    80002b1e:	4e660613          	addi	a2,a2,1254 # 80007000 <_trampoline>
    80002b22:	00004697          	auipc	a3,0x4
    80002b26:	4de68693          	addi	a3,a3,1246 # 80007000 <_trampoline>
    80002b2a:	8e91                	sub	a3,a3,a2
    80002b2c:	040007b7          	lui	a5,0x4000
    80002b30:	17fd                	addi	a5,a5,-1
    80002b32:	07b2                	slli	a5,a5,0xc
    80002b34:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b36:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b3a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b3c:	180026f3          	csrr	a3,satp
    80002b40:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b42:	6d38                	ld	a4,88(a0)
    80002b44:	6134                	ld	a3,64(a0)
    80002b46:	6585                	lui	a1,0x1
    80002b48:	96ae                	add	a3,a3,a1
    80002b4a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b4c:	6d38                	ld	a4,88(a0)
    80002b4e:	00000697          	auipc	a3,0x0
    80002b52:	13068693          	addi	a3,a3,304 # 80002c7e <usertrap>
    80002b56:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b58:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b5a:	8692                	mv	a3,tp
    80002b5c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b5e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b62:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b66:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b6a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b6e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b70:	6f18                	ld	a4,24(a4)
    80002b72:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b76:	6928                	ld	a0,80(a0)
    80002b78:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b7a:	00004717          	auipc	a4,0x4
    80002b7e:	52270713          	addi	a4,a4,1314 # 8000709c <userret>
    80002b82:	8f11                	sub	a4,a4,a2
    80002b84:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b86:	577d                	li	a4,-1
    80002b88:	177e                	slli	a4,a4,0x3f
    80002b8a:	8d59                	or	a0,a0,a4
    80002b8c:	9782                	jalr	a5
}
    80002b8e:	60a2                	ld	ra,8(sp)
    80002b90:	6402                	ld	s0,0(sp)
    80002b92:	0141                	addi	sp,sp,16
    80002b94:	8082                	ret

0000000080002b96 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b96:	1101                	addi	sp,sp,-32
    80002b98:	ec06                	sd	ra,24(sp)
    80002b9a:	e822                	sd	s0,16(sp)
    80002b9c:	e426                	sd	s1,8(sp)
    80002b9e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ba0:	00014497          	auipc	s1,0x14
    80002ba4:	7d048493          	addi	s1,s1,2000 # 80017370 <tickslock>
    80002ba8:	8526                	mv	a0,s1
    80002baa:	ffffe097          	auipc	ra,0xffffe
    80002bae:	040080e7          	jalr	64(ra) # 80000bea <acquire>
  ticks++;
    80002bb2:	00006517          	auipc	a0,0x6
    80002bb6:	f1e50513          	addi	a0,a0,-226 # 80008ad0 <ticks>
    80002bba:	411c                	lw	a5,0(a0)
    80002bbc:	2785                	addiw	a5,a5,1
    80002bbe:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002bc0:	fffff097          	auipc	ra,0xfffff
    80002bc4:	50e080e7          	jalr	1294(ra) # 800020ce <wakeup>
  release(&tickslock);
    80002bc8:	8526                	mv	a0,s1
    80002bca:	ffffe097          	auipc	ra,0xffffe
    80002bce:	0d4080e7          	jalr	212(ra) # 80000c9e <release>
}
    80002bd2:	60e2                	ld	ra,24(sp)
    80002bd4:	6442                	ld	s0,16(sp)
    80002bd6:	64a2                	ld	s1,8(sp)
    80002bd8:	6105                	addi	sp,sp,32
    80002bda:	8082                	ret

0000000080002bdc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002bdc:	1101                	addi	sp,sp,-32
    80002bde:	ec06                	sd	ra,24(sp)
    80002be0:	e822                	sd	s0,16(sp)
    80002be2:	e426                	sd	s1,8(sp)
    80002be4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002be6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002bea:	00074d63          	bltz	a4,80002c04 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002bee:	57fd                	li	a5,-1
    80002bf0:	17fe                	slli	a5,a5,0x3f
    80002bf2:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002bf4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002bf6:	06f70363          	beq	a4,a5,80002c5c <devintr+0x80>
  }
}
    80002bfa:	60e2                	ld	ra,24(sp)
    80002bfc:	6442                	ld	s0,16(sp)
    80002bfe:	64a2                	ld	s1,8(sp)
    80002c00:	6105                	addi	sp,sp,32
    80002c02:	8082                	ret
     (scause & 0xff) == 9){
    80002c04:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002c08:	46a5                	li	a3,9
    80002c0a:	fed792e3          	bne	a5,a3,80002bee <devintr+0x12>
    int irq = plic_claim();
    80002c0e:	00003097          	auipc	ra,0x3
    80002c12:	5da080e7          	jalr	1498(ra) # 800061e8 <plic_claim>
    80002c16:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c18:	47a9                	li	a5,10
    80002c1a:	02f50763          	beq	a0,a5,80002c48 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c1e:	4785                	li	a5,1
    80002c20:	02f50963          	beq	a0,a5,80002c52 <devintr+0x76>
    return 1;
    80002c24:	4505                	li	a0,1
    } else if(irq){
    80002c26:	d8f1                	beqz	s1,80002bfa <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c28:	85a6                	mv	a1,s1
    80002c2a:	00006517          	auipc	a0,0x6
    80002c2e:	8c650513          	addi	a0,a0,-1850 # 800084f0 <states.1757+0x38>
    80002c32:	ffffe097          	auipc	ra,0xffffe
    80002c36:	95c080e7          	jalr	-1700(ra) # 8000058e <printf>
      plic_complete(irq);
    80002c3a:	8526                	mv	a0,s1
    80002c3c:	00003097          	auipc	ra,0x3
    80002c40:	5d0080e7          	jalr	1488(ra) # 8000620c <plic_complete>
    return 1;
    80002c44:	4505                	li	a0,1
    80002c46:	bf55                	j	80002bfa <devintr+0x1e>
      uartintr();
    80002c48:	ffffe097          	auipc	ra,0xffffe
    80002c4c:	d66080e7          	jalr	-666(ra) # 800009ae <uartintr>
    80002c50:	b7ed                	j	80002c3a <devintr+0x5e>
      virtio_disk_intr();
    80002c52:	00004097          	auipc	ra,0x4
    80002c56:	ae4080e7          	jalr	-1308(ra) # 80006736 <virtio_disk_intr>
    80002c5a:	b7c5                	j	80002c3a <devintr+0x5e>
    if(cpuid() == 0){
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	d3e080e7          	jalr	-706(ra) # 8000199a <cpuid>
    80002c64:	c901                	beqz	a0,80002c74 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c66:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c6a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c6c:	14479073          	csrw	sip,a5
    return 2;
    80002c70:	4509                	li	a0,2
    80002c72:	b761                	j	80002bfa <devintr+0x1e>
      clockintr();
    80002c74:	00000097          	auipc	ra,0x0
    80002c78:	f22080e7          	jalr	-222(ra) # 80002b96 <clockintr>
    80002c7c:	b7ed                	j	80002c66 <devintr+0x8a>

0000000080002c7e <usertrap>:
{
    80002c7e:	1101                	addi	sp,sp,-32
    80002c80:	ec06                	sd	ra,24(sp)
    80002c82:	e822                	sd	s0,16(sp)
    80002c84:	e426                	sd	s1,8(sp)
    80002c86:	e04a                	sd	s2,0(sp)
    80002c88:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c8a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c8e:	1007f793          	andi	a5,a5,256
    80002c92:	e3b1                	bnez	a5,80002cd6 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c94:	00003797          	auipc	a5,0x3
    80002c98:	44c78793          	addi	a5,a5,1100 # 800060e0 <kernelvec>
    80002c9c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ca0:	fffff097          	auipc	ra,0xfffff
    80002ca4:	d26080e7          	jalr	-730(ra) # 800019c6 <myproc>
    80002ca8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002caa:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cac:	14102773          	csrr	a4,sepc
    80002cb0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cb2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cb6:	47a1                	li	a5,8
    80002cb8:	02f70763          	beq	a4,a5,80002ce6 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002cbc:	00000097          	auipc	ra,0x0
    80002cc0:	f20080e7          	jalr	-224(ra) # 80002bdc <devintr>
    80002cc4:	892a                	mv	s2,a0
    80002cc6:	c941                	beqz	a0,80002d56 <usertrap+0xd8>
  if(killed(p))
    80002cc8:	8526                	mv	a0,s1
    80002cca:	fffff097          	auipc	ra,0xfffff
    80002cce:	6c2080e7          	jalr	1730(ra) # 8000238c <killed>
    80002cd2:	cd21                	beqz	a0,80002d2a <usertrap+0xac>
    80002cd4:	a099                	j	80002d1a <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002cd6:	00006517          	auipc	a0,0x6
    80002cda:	83a50513          	addi	a0,a0,-1990 # 80008510 <states.1757+0x58>
    80002cde:	ffffe097          	auipc	ra,0xffffe
    80002ce2:	866080e7          	jalr	-1946(ra) # 80000544 <panic>
    if(killed(p))
    80002ce6:	fffff097          	auipc	ra,0xfffff
    80002cea:	6a6080e7          	jalr	1702(ra) # 8000238c <killed>
    80002cee:	e939                	bnez	a0,80002d44 <usertrap+0xc6>
    p->trapframe->epc += 4;
    80002cf0:	6cb8                	ld	a4,88(s1)
    80002cf2:	6f1c                	ld	a5,24(a4)
    80002cf4:	0791                	addi	a5,a5,4
    80002cf6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cf8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002cfc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d00:	10079073          	csrw	sstatus,a5
    syscall();
    80002d04:	00000097          	auipc	ra,0x0
    80002d08:	2b2080e7          	jalr	690(ra) # 80002fb6 <syscall>
  if(killed(p))
    80002d0c:	8526                	mv	a0,s1
    80002d0e:	fffff097          	auipc	ra,0xfffff
    80002d12:	67e080e7          	jalr	1662(ra) # 8000238c <killed>
    80002d16:	cd09                	beqz	a0,80002d30 <usertrap+0xb2>
    80002d18:	4901                	li	s2,0
    exit("killed");
    80002d1a:	00006517          	auipc	a0,0x6
    80002d1e:	87650513          	addi	a0,a0,-1930 # 80008590 <states.1757+0xd8>
    80002d22:	fffff097          	auipc	ra,0xfffff
    80002d26:	47c080e7          	jalr	1148(ra) # 8000219e <exit>
  if(which_dev == 2)
    80002d2a:	4789                	li	a5,2
    80002d2c:	06f90263          	beq	s2,a5,80002d90 <usertrap+0x112>
  usertrapret();
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	dd0080e7          	jalr	-560(ra) # 80002b00 <usertrapret>
}
    80002d38:	60e2                	ld	ra,24(sp)
    80002d3a:	6442                	ld	s0,16(sp)
    80002d3c:	64a2                	ld	s1,8(sp)
    80002d3e:	6902                	ld	s2,0(sp)
    80002d40:	6105                	addi	sp,sp,32
    80002d42:	8082                	ret
      exit("syscall error");
    80002d44:	00005517          	auipc	a0,0x5
    80002d48:	7ec50513          	addi	a0,a0,2028 # 80008530 <states.1757+0x78>
    80002d4c:	fffff097          	auipc	ra,0xfffff
    80002d50:	452080e7          	jalr	1106(ra) # 8000219e <exit>
    80002d54:	bf71                	j	80002cf0 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d56:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d5a:	5890                	lw	a2,48(s1)
    80002d5c:	00005517          	auipc	a0,0x5
    80002d60:	7e450513          	addi	a0,a0,2020 # 80008540 <states.1757+0x88>
    80002d64:	ffffe097          	auipc	ra,0xffffe
    80002d68:	82a080e7          	jalr	-2006(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d6c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d70:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d74:	00005517          	auipc	a0,0x5
    80002d78:	7fc50513          	addi	a0,a0,2044 # 80008570 <states.1757+0xb8>
    80002d7c:	ffffe097          	auipc	ra,0xffffe
    80002d80:	812080e7          	jalr	-2030(ra) # 8000058e <printf>
    setkilled(p);
    80002d84:	8526                	mv	a0,s1
    80002d86:	fffff097          	auipc	ra,0xfffff
    80002d8a:	5da080e7          	jalr	1498(ra) # 80002360 <setkilled>
    80002d8e:	bfbd                	j	80002d0c <usertrap+0x8e>
    yield();
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	29e080e7          	jalr	670(ra) # 8000202e <yield>
    80002d98:	bf61                	j	80002d30 <usertrap+0xb2>

0000000080002d9a <kerneltrap>:
{
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	e426                	sd	s1,8(sp)
    80002da2:	e04a                	sd	s2,0(sp)
    80002da4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002da6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002daa:	100024f3          	csrr	s1,sstatus
  if((sstatus & SSTATUS_SPP) == 0)
    80002dae:	1004f793          	andi	a5,s1,256
    80002db2:	c79d                	beqz	a5,80002de0 <kerneltrap+0x46>
    80002db4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002db8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002dba:	eb9d                	bnez	a5,80002df0 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002dbc:	00000097          	auipc	ra,0x0
    80002dc0:	e20080e7          	jalr	-480(ra) # 80002bdc <devintr>
    80002dc4:	cd15                	beqz	a0,80002e00 <kerneltrap+0x66>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dc6:	4789                	li	a5,2
    80002dc8:	04f50463          	beq	a0,a5,80002e10 <kerneltrap+0x76>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002dcc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dd0:	10049073          	csrw	sstatus,s1
}
    80002dd4:	60e2                	ld	ra,24(sp)
    80002dd6:	6442                	ld	s0,16(sp)
    80002dd8:	64a2                	ld	s1,8(sp)
    80002dda:	6902                	ld	s2,0(sp)
    80002ddc:	6105                	addi	sp,sp,32
    80002dde:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002de0:	00005517          	auipc	a0,0x5
    80002de4:	7b850513          	addi	a0,a0,1976 # 80008598 <states.1757+0xe0>
    80002de8:	ffffd097          	auipc	ra,0xffffd
    80002dec:	75c080e7          	jalr	1884(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002df0:	00005517          	auipc	a0,0x5
    80002df4:	7d050513          	addi	a0,a0,2000 # 800085c0 <states.1757+0x108>
    80002df8:	ffffd097          	auipc	ra,0xffffd
    80002dfc:	74c080e7          	jalr	1868(ra) # 80000544 <panic>
    panic("kerneltrap");
    80002e00:	00005517          	auipc	a0,0x5
    80002e04:	7e050513          	addi	a0,a0,2016 # 800085e0 <states.1757+0x128>
    80002e08:	ffffd097          	auipc	ra,0xffffd
    80002e0c:	73c080e7          	jalr	1852(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e10:	fffff097          	auipc	ra,0xfffff
    80002e14:	bb6080e7          	jalr	-1098(ra) # 800019c6 <myproc>
    80002e18:	d955                	beqz	a0,80002dcc <kerneltrap+0x32>
    80002e1a:	fffff097          	auipc	ra,0xfffff
    80002e1e:	bac080e7          	jalr	-1108(ra) # 800019c6 <myproc>
    80002e22:	4d18                	lw	a4,24(a0)
    80002e24:	4791                	li	a5,4
    80002e26:	faf713e3          	bne	a4,a5,80002dcc <kerneltrap+0x32>
    yield();
    80002e2a:	fffff097          	auipc	ra,0xfffff
    80002e2e:	204080e7          	jalr	516(ra) # 8000202e <yield>
    80002e32:	bf69                	j	80002dcc <kerneltrap+0x32>

0000000080002e34 <argraw>:
    return -1;
  return strlen(buf);
}

static uint64 argraw(int n)
{
    80002e34:	1101                	addi	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	e426                	sd	s1,8(sp)
    80002e3c:	1000                	addi	s0,sp,32
    80002e3e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e40:	fffff097          	auipc	ra,0xfffff
    80002e44:	b86080e7          	jalr	-1146(ra) # 800019c6 <myproc>
  switch (n) {
    80002e48:	4795                	li	a5,5
    80002e4a:	0497e163          	bltu	a5,s1,80002e8c <argraw+0x58>
    80002e4e:	048a                	slli	s1,s1,0x2
    80002e50:	00005717          	auipc	a4,0x5
    80002e54:	7c870713          	addi	a4,a4,1992 # 80008618 <states.1757+0x160>
    80002e58:	94ba                	add	s1,s1,a4
    80002e5a:	409c                	lw	a5,0(s1)
    80002e5c:	97ba                	add	a5,a5,a4
    80002e5e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e60:	6d3c                	ld	a5,88(a0)
    80002e62:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e64:	60e2                	ld	ra,24(sp)
    80002e66:	6442                	ld	s0,16(sp)
    80002e68:	64a2                	ld	s1,8(sp)
    80002e6a:	6105                	addi	sp,sp,32
    80002e6c:	8082                	ret
    return p->trapframe->a1;
    80002e6e:	6d3c                	ld	a5,88(a0)
    80002e70:	7fa8                	ld	a0,120(a5)
    80002e72:	bfcd                	j	80002e64 <argraw+0x30>
    return p->trapframe->a2;
    80002e74:	6d3c                	ld	a5,88(a0)
    80002e76:	63c8                	ld	a0,128(a5)
    80002e78:	b7f5                	j	80002e64 <argraw+0x30>
    return p->trapframe->a3;
    80002e7a:	6d3c                	ld	a5,88(a0)
    80002e7c:	67c8                	ld	a0,136(a5)
    80002e7e:	b7dd                	j	80002e64 <argraw+0x30>
    return p->trapframe->a4;
    80002e80:	6d3c                	ld	a5,88(a0)
    80002e82:	6bc8                	ld	a0,144(a5)
    80002e84:	b7c5                	j	80002e64 <argraw+0x30>
    return p->trapframe->a5;
    80002e86:	6d3c                	ld	a5,88(a0)
    80002e88:	6fc8                	ld	a0,152(a5)
    80002e8a:	bfe9                	j	80002e64 <argraw+0x30>
  panic("argraw");
    80002e8c:	00005517          	auipc	a0,0x5
    80002e90:	76450513          	addi	a0,a0,1892 # 800085f0 <states.1757+0x138>
    80002e94:	ffffd097          	auipc	ra,0xffffd
    80002e98:	6b0080e7          	jalr	1712(ra) # 80000544 <panic>

0000000080002e9c <fetchaddr>:
{
    80002e9c:	1101                	addi	sp,sp,-32
    80002e9e:	ec06                	sd	ra,24(sp)
    80002ea0:	e822                	sd	s0,16(sp)
    80002ea2:	e426                	sd	s1,8(sp)
    80002ea4:	e04a                	sd	s2,0(sp)
    80002ea6:	1000                	addi	s0,sp,32
    80002ea8:	84aa                	mv	s1,a0
    80002eaa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002eac:	fffff097          	auipc	ra,0xfffff
    80002eb0:	b1a080e7          	jalr	-1254(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002eb4:	653c                	ld	a5,72(a0)
    80002eb6:	02f4f863          	bgeu	s1,a5,80002ee6 <fetchaddr+0x4a>
    80002eba:	00848713          	addi	a4,s1,8
    80002ebe:	02e7e663          	bltu	a5,a4,80002eea <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ec2:	46a1                	li	a3,8
    80002ec4:	8626                	mv	a2,s1
    80002ec6:	85ca                	mv	a1,s2
    80002ec8:	6928                	ld	a0,80(a0)
    80002eca:	fffff097          	auipc	ra,0xfffff
    80002ece:	846080e7          	jalr	-1978(ra) # 80001710 <copyin>
    80002ed2:	00a03533          	snez	a0,a0
    80002ed6:	40a00533          	neg	a0,a0
}
    80002eda:	60e2                	ld	ra,24(sp)
    80002edc:	6442                	ld	s0,16(sp)
    80002ede:	64a2                	ld	s1,8(sp)
    80002ee0:	6902                	ld	s2,0(sp)
    80002ee2:	6105                	addi	sp,sp,32
    80002ee4:	8082                	ret
    return -1;
    80002ee6:	557d                	li	a0,-1
    80002ee8:	bfcd                	j	80002eda <fetchaddr+0x3e>
    80002eea:	557d                	li	a0,-1
    80002eec:	b7fd                	j	80002eda <fetchaddr+0x3e>

0000000080002eee <fetchstr>:
{
    80002eee:	7179                	addi	sp,sp,-48
    80002ef0:	f406                	sd	ra,40(sp)
    80002ef2:	f022                	sd	s0,32(sp)
    80002ef4:	ec26                	sd	s1,24(sp)
    80002ef6:	e84a                	sd	s2,16(sp)
    80002ef8:	e44e                	sd	s3,8(sp)
    80002efa:	1800                	addi	s0,sp,48
    80002efc:	892a                	mv	s2,a0
    80002efe:	84ae                	mv	s1,a1
    80002f00:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f02:	fffff097          	auipc	ra,0xfffff
    80002f06:	ac4080e7          	jalr	-1340(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002f0a:	86ce                	mv	a3,s3
    80002f0c:	864a                	mv	a2,s2
    80002f0e:	85a6                	mv	a1,s1
    80002f10:	6928                	ld	a0,80(a0)
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	88a080e7          	jalr	-1910(ra) # 8000179c <copyinstr>
    80002f1a:	00054e63          	bltz	a0,80002f36 <fetchstr+0x48>
  return strlen(buf);
    80002f1e:	8526                	mv	a0,s1
    80002f20:	ffffe097          	auipc	ra,0xffffe
    80002f24:	f4a080e7          	jalr	-182(ra) # 80000e6a <strlen>
}
    80002f28:	70a2                	ld	ra,40(sp)
    80002f2a:	7402                	ld	s0,32(sp)
    80002f2c:	64e2                	ld	s1,24(sp)
    80002f2e:	6942                	ld	s2,16(sp)
    80002f30:	69a2                	ld	s3,8(sp)
    80002f32:	6145                	addi	sp,sp,48
    80002f34:	8082                	ret
    return -1;
    80002f36:	557d                	li	a0,-1
    80002f38:	bfc5                	j	80002f28 <fetchstr+0x3a>

0000000080002f3a <argint>:

// Fetch the nth 32-bit system call argument.
int argint(int n, int *ip)
{
    80002f3a:	1101                	addi	sp,sp,-32
    80002f3c:	ec06                	sd	ra,24(sp)
    80002f3e:	e822                	sd	s0,16(sp)
    80002f40:	e426                	sd	s1,8(sp)
    80002f42:	1000                	addi	s0,sp,32
    80002f44:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f46:	00000097          	auipc	ra,0x0
    80002f4a:	eee080e7          	jalr	-274(ra) # 80002e34 <argraw>
    80002f4e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002f50:	4501                	li	a0,0
    80002f52:	60e2                	ld	ra,24(sp)
    80002f54:	6442                	ld	s0,16(sp)
    80002f56:	64a2                	ld	s1,8(sp)
    80002f58:	6105                	addi	sp,sp,32
    80002f5a:	8082                	ret

0000000080002f5c <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int argaddr(int n, uint64 *ip)
{
    80002f5c:	1101                	addi	sp,sp,-32
    80002f5e:	ec06                	sd	ra,24(sp)
    80002f60:	e822                	sd	s0,16(sp)
    80002f62:	e426                	sd	s1,8(sp)
    80002f64:	1000                	addi	s0,sp,32
    80002f66:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f68:	00000097          	auipc	ra,0x0
    80002f6c:	ecc080e7          	jalr	-308(ra) # 80002e34 <argraw>
    80002f70:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f72:	4501                	li	a0,0
    80002f74:	60e2                	ld	ra,24(sp)
    80002f76:	6442                	ld	s0,16(sp)
    80002f78:	64a2                	ld	s1,8(sp)
    80002f7a:	6105                	addi	sp,sp,32
    80002f7c:	8082                	ret

0000000080002f7e <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002f7e:	7179                	addi	sp,sp,-48
    80002f80:	f406                	sd	ra,40(sp)
    80002f82:	f022                	sd	s0,32(sp)
    80002f84:	ec26                	sd	s1,24(sp)
    80002f86:	e84a                	sd	s2,16(sp)
    80002f88:	1800                	addi	s0,sp,48
    80002f8a:	84ae                	mv	s1,a1
    80002f8c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002f8e:	fd840593          	addi	a1,s0,-40
    80002f92:	00000097          	auipc	ra,0x0
    80002f96:	fca080e7          	jalr	-54(ra) # 80002f5c <argaddr>
  return fetchstr(addr, buf, max);
    80002f9a:	864a                	mv	a2,s2
    80002f9c:	85a6                	mv	a1,s1
    80002f9e:	fd843503          	ld	a0,-40(s0)
    80002fa2:	00000097          	auipc	ra,0x0
    80002fa6:	f4c080e7          	jalr	-180(ra) # 80002eee <fetchstr>
}
    80002faa:	70a2                	ld	ra,40(sp)
    80002fac:	7402                	ld	s0,32(sp)
    80002fae:	64e2                	ld	s1,24(sp)
    80002fb0:	6942                	ld	s2,16(sp)
    80002fb2:	6145                	addi	sp,sp,48
    80002fb4:	8082                	ret

0000000080002fb6 <syscall>:
[SYS_waitall] sys_waitall,
[SYS_exit_num] sys_exit_num,
};

void syscall(void)
{
    80002fb6:	1101                	addi	sp,sp,-32
    80002fb8:	ec06                	sd	ra,24(sp)
    80002fba:	e822                	sd	s0,16(sp)
    80002fbc:	e426                	sd	s1,8(sp)
    80002fbe:	e04a                	sd	s2,0(sp)
    80002fc0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002fc2:	fffff097          	auipc	ra,0xfffff
    80002fc6:	a04080e7          	jalr	-1532(ra) # 800019c6 <myproc>
    80002fca:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002fcc:	05853903          	ld	s2,88(a0)
    80002fd0:	0a893783          	ld	a5,168(s2)
    80002fd4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002fd8:	37fd                	addiw	a5,a5,-1
    80002fda:	4769                	li	a4,26
    80002fdc:	00f76f63          	bltu	a4,a5,80002ffa <syscall+0x44>
    80002fe0:	00369713          	slli	a4,a3,0x3
    80002fe4:	00005797          	auipc	a5,0x5
    80002fe8:	64c78793          	addi	a5,a5,1612 # 80008630 <syscalls>
    80002fec:	97ba                	add	a5,a5,a4
    80002fee:	639c                	ld	a5,0(a5)
    80002ff0:	c789                	beqz	a5,80002ffa <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ff2:	9782                	jalr	a5
    80002ff4:	06a93823          	sd	a0,112(s2)
    80002ff8:	a839                	j	80003016 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ffa:	15848613          	addi	a2,s1,344
    80002ffe:	588c                	lw	a1,48(s1)
    80003000:	00005517          	auipc	a0,0x5
    80003004:	5f850513          	addi	a0,a0,1528 # 800085f8 <states.1757+0x140>
    80003008:	ffffd097          	auipc	ra,0xffffd
    8000300c:	586080e7          	jalr	1414(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003010:	6cbc                	ld	a5,88(s1)
    80003012:	577d                	li	a4,-1
    80003014:	fbb8                	sd	a4,112(a5)
  }
}
    80003016:	60e2                	ld	ra,24(sp)
    80003018:	6442                	ld	s0,16(sp)
    8000301a:	64a2                	ld	s1,8(sp)
    8000301c:	6902                	ld	s2,0(sp)
    8000301e:	6105                	addi	sp,sp,32
    80003020:	8082                	ret

0000000080003022 <sys_exit>:
// Add function declarations
extern struct proc* allocproc(void);
extern void freeproc(struct proc *p);

uint64 sys_exit(void)
{
    80003022:	1101                	addi	sp,sp,-32
    80003024:	ec06                	sd	ra,24(sp)
    80003026:	e822                	sd	s0,16(sp)
    80003028:	1000                	addi	s0,sp,32
  int status;
  argint(0, &status);
    8000302a:	fec40593          	addi	a1,s0,-20
    8000302e:	4501                	li	a0,0
    80003030:	00000097          	auipc	ra,0x0
    80003034:	f0a080e7          	jalr	-246(ra) # 80002f3a <argint>
  exit_num(status);  
    80003038:	fec42503          	lw	a0,-20(s0)
    8000303c:	fffff097          	auipc	ra,0xfffff
    80003040:	24e080e7          	jalr	590(ra) # 8000228a <exit_num>
  return 0; // never returns
}
    80003044:	4501                	li	a0,0
    80003046:	60e2                	ld	ra,24(sp)
    80003048:	6442                	ld	s0,16(sp)
    8000304a:	6105                	addi	sp,sp,32
    8000304c:	8082                	ret

000000008000304e <sys_exitmsg>:

uint64 sys_exitmsg(void)
{
    8000304e:	7179                	addi	sp,sp,-48
    80003050:	f406                	sd	ra,40(sp)
    80003052:	f022                	sd	s0,32(sp)
    80003054:	1800                	addi	s0,sp,48
  exit_msg(msg);
  return 0; // never returns
  */

  char msg[32];
  if (argstr(0, msg, sizeof(msg)) < 0)
    80003056:	02000613          	li	a2,32
    8000305a:	fd040593          	addi	a1,s0,-48
    8000305e:	4501                	li	a0,0
    80003060:	00000097          	auipc	ra,0x0
    80003064:	f1e080e7          	jalr	-226(ra) # 80002f7e <argstr>
    return -1;
    80003068:	57fd                	li	a5,-1
  if (argstr(0, msg, sizeof(msg)) < 0)
    8000306a:	00054963          	bltz	a0,8000307c <sys_exitmsg+0x2e>

  exit_msg(msg);
    8000306e:	fd040513          	addi	a0,s0,-48
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	23e080e7          	jalr	574(ra) # 800022b0 <exit_msg>
  return 0;
    8000307a:	4781                	li	a5,0

  
}
    8000307c:	853e                	mv	a0,a5
    8000307e:	70a2                	ld	ra,40(sp)
    80003080:	7402                	ld	s0,32(sp)
    80003082:	6145                	addi	sp,sp,48
    80003084:	8082                	ret

0000000080003086 <sys_getpid>:

uint64 sys_getpid(void)
{
    80003086:	1141                	addi	sp,sp,-16
    80003088:	e406                	sd	ra,8(sp)
    8000308a:	e022                	sd	s0,0(sp)
    8000308c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000308e:	fffff097          	auipc	ra,0xfffff
    80003092:	938080e7          	jalr	-1736(ra) # 800019c6 <myproc>
}
    80003096:	5908                	lw	a0,48(a0)
    80003098:	60a2                	ld	ra,8(sp)
    8000309a:	6402                	ld	s0,0(sp)
    8000309c:	0141                	addi	sp,sp,16
    8000309e:	8082                	ret

00000000800030a0 <sys_fork>:

uint64 sys_fork(void)
{
    800030a0:	1141                	addi	sp,sp,-16
    800030a2:	e406                	sd	ra,8(sp)
    800030a4:	e022                	sd	s0,0(sp)
    800030a6:	0800                	addi	s0,sp,16
  return fork();
    800030a8:	fffff097          	auipc	ra,0xfffff
    800030ac:	cd4080e7          	jalr	-812(ra) # 80001d7c <fork>
}
    800030b0:	60a2                	ld	ra,8(sp)
    800030b2:	6402                	ld	s0,0(sp)
    800030b4:	0141                	addi	sp,sp,16
    800030b6:	8082                	ret

00000000800030b8 <sys_wait>:

uint64 sys_wait(void){
    800030b8:	1101                	addi	sp,sp,-32
    800030ba:	ec06                	sd	ra,24(sp)
    800030bc:	e822                	sd	s0,16(sp)
    800030be:	1000                	addi	s0,sp,32
  uint64 status_addr;
  uint64 msg_addr;

  argaddr(0, &status_addr);
    800030c0:	fe840593          	addi	a1,s0,-24
    800030c4:	4501                	li	a0,0
    800030c6:	00000097          	auipc	ra,0x0
    800030ca:	e96080e7          	jalr	-362(ra) # 80002f5c <argaddr>
  argaddr(1, &msg_addr);
    800030ce:	fe040593          	addi	a1,s0,-32
    800030d2:	4505                	li	a0,1
    800030d4:	00000097          	auipc	ra,0x0
    800030d8:	e88080e7          	jalr	-376(ra) # 80002f5c <argaddr>

  return wait(status_addr, msg_addr);
    800030dc:	fe043583          	ld	a1,-32(s0)
    800030e0:	fe843503          	ld	a0,-24(s0)
    800030e4:	fffff097          	auipc	ra,0xfffff
    800030e8:	2da080e7          	jalr	730(ra) # 800023be <wait>
} 
    800030ec:	60e2                	ld	ra,24(sp)
    800030ee:	6442                	ld	s0,16(sp)
    800030f0:	6105                	addi	sp,sp,32
    800030f2:	8082                	ret

00000000800030f4 <sys_sbrk>:

uint64 sys_sbrk(void)
{
    800030f4:	7179                	addi	sp,sp,-48
    800030f6:	f406                	sd	ra,40(sp)
    800030f8:	f022                	sd	s0,32(sp)
    800030fa:	ec26                	sd	s1,24(sp)
    800030fc:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800030fe:	fdc40593          	addi	a1,s0,-36
    80003102:	4501                	li	a0,0
    80003104:	00000097          	auipc	ra,0x0
    80003108:	e36080e7          	jalr	-458(ra) # 80002f3a <argint>
  addr = myproc()->sz;
    8000310c:	fffff097          	auipc	ra,0xfffff
    80003110:	8ba080e7          	jalr	-1862(ra) # 800019c6 <myproc>
    80003114:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80003116:	fdc42503          	lw	a0,-36(s0)
    8000311a:	fffff097          	auipc	ra,0xfffff
    8000311e:	c06080e7          	jalr	-1018(ra) # 80001d20 <growproc>
    80003122:	00054863          	bltz	a0,80003132 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003126:	8526                	mv	a0,s1
    80003128:	70a2                	ld	ra,40(sp)
    8000312a:	7402                	ld	s0,32(sp)
    8000312c:	64e2                	ld	s1,24(sp)
    8000312e:	6145                	addi	sp,sp,48
    80003130:	8082                	ret
    return -1;
    80003132:	54fd                	li	s1,-1
    80003134:	bfcd                	j	80003126 <sys_sbrk+0x32>

0000000080003136 <sys_sleep>:

uint64 sys_sleep(void)
{
    80003136:	7139                	addi	sp,sp,-64
    80003138:	fc06                	sd	ra,56(sp)
    8000313a:	f822                	sd	s0,48(sp)
    8000313c:	f426                	sd	s1,40(sp)
    8000313e:	f04a                	sd	s2,32(sp)
    80003140:	ec4e                	sd	s3,24(sp)
    80003142:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003144:	fcc40593          	addi	a1,s0,-52
    80003148:	4501                	li	a0,0
    8000314a:	00000097          	auipc	ra,0x0
    8000314e:	df0080e7          	jalr	-528(ra) # 80002f3a <argint>
  acquire(&tickslock);
    80003152:	00014517          	auipc	a0,0x14
    80003156:	21e50513          	addi	a0,a0,542 # 80017370 <tickslock>
    8000315a:	ffffe097          	auipc	ra,0xffffe
    8000315e:	a90080e7          	jalr	-1392(ra) # 80000bea <acquire>
  ticks0 = ticks;
    80003162:	00006917          	auipc	s2,0x6
    80003166:	96e92903          	lw	s2,-1682(s2) # 80008ad0 <ticks>
  while(ticks - ticks0 < n){
    8000316a:	fcc42783          	lw	a5,-52(s0)
    8000316e:	cf9d                	beqz	a5,800031ac <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003170:	00014997          	auipc	s3,0x14
    80003174:	20098993          	addi	s3,s3,512 # 80017370 <tickslock>
    80003178:	00006497          	auipc	s1,0x6
    8000317c:	95848493          	addi	s1,s1,-1704 # 80008ad0 <ticks>
    if(killed(myproc())){
    80003180:	fffff097          	auipc	ra,0xfffff
    80003184:	846080e7          	jalr	-1978(ra) # 800019c6 <myproc>
    80003188:	fffff097          	auipc	ra,0xfffff
    8000318c:	204080e7          	jalr	516(ra) # 8000238c <killed>
    80003190:	ed15                	bnez	a0,800031cc <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003192:	85ce                	mv	a1,s3
    80003194:	8526                	mv	a0,s1
    80003196:	fffff097          	auipc	ra,0xfffff
    8000319a:	ed4080e7          	jalr	-300(ra) # 8000206a <sleep>
  while(ticks - ticks0 < n){
    8000319e:	409c                	lw	a5,0(s1)
    800031a0:	412787bb          	subw	a5,a5,s2
    800031a4:	fcc42703          	lw	a4,-52(s0)
    800031a8:	fce7ece3          	bltu	a5,a4,80003180 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800031ac:	00014517          	auipc	a0,0x14
    800031b0:	1c450513          	addi	a0,a0,452 # 80017370 <tickslock>
    800031b4:	ffffe097          	auipc	ra,0xffffe
    800031b8:	aea080e7          	jalr	-1302(ra) # 80000c9e <release>
  return 0;
    800031bc:	4501                	li	a0,0
}
    800031be:	70e2                	ld	ra,56(sp)
    800031c0:	7442                	ld	s0,48(sp)
    800031c2:	74a2                	ld	s1,40(sp)
    800031c4:	7902                	ld	s2,32(sp)
    800031c6:	69e2                	ld	s3,24(sp)
    800031c8:	6121                	addi	sp,sp,64
    800031ca:	8082                	ret
      release(&tickslock);
    800031cc:	00014517          	auipc	a0,0x14
    800031d0:	1a450513          	addi	a0,a0,420 # 80017370 <tickslock>
    800031d4:	ffffe097          	auipc	ra,0xffffe
    800031d8:	aca080e7          	jalr	-1334(ra) # 80000c9e <release>
      return -1;
    800031dc:	557d                	li	a0,-1
    800031de:	b7c5                	j	800031be <sys_sleep+0x88>

00000000800031e0 <sys_kill>:

uint64 sys_kill(void)
{
    800031e0:	1101                	addi	sp,sp,-32
    800031e2:	ec06                	sd	ra,24(sp)
    800031e4:	e822                	sd	s0,16(sp)
    800031e6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800031e8:	fec40593          	addi	a1,s0,-20
    800031ec:	4501                	li	a0,0
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	d4c080e7          	jalr	-692(ra) # 80002f3a <argint>
  return kill(pid);
    800031f6:	fec42503          	lw	a0,-20(s0)
    800031fa:	fffff097          	auipc	ra,0xfffff
    800031fe:	0f4080e7          	jalr	244(ra) # 800022ee <kill>
}
    80003202:	60e2                	ld	ra,24(sp)
    80003204:	6442                	ld	s0,16(sp)
    80003206:	6105                	addi	sp,sp,32
    80003208:	8082                	ret

000000008000320a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64 sys_uptime(void)
{
    8000320a:	1101                	addi	sp,sp,-32
    8000320c:	ec06                	sd	ra,24(sp)
    8000320e:	e822                	sd	s0,16(sp)
    80003210:	e426                	sd	s1,8(sp)
    80003212:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003214:	00014517          	auipc	a0,0x14
    80003218:	15c50513          	addi	a0,a0,348 # 80017370 <tickslock>
    8000321c:	ffffe097          	auipc	ra,0xffffe
    80003220:	9ce080e7          	jalr	-1586(ra) # 80000bea <acquire>
  xticks = ticks;
    80003224:	00006497          	auipc	s1,0x6
    80003228:	8ac4a483          	lw	s1,-1876(s1) # 80008ad0 <ticks>
  release(&tickslock);
    8000322c:	00014517          	auipc	a0,0x14
    80003230:	14450513          	addi	a0,a0,324 # 80017370 <tickslock>
    80003234:	ffffe097          	auipc	ra,0xffffe
    80003238:	a6a080e7          	jalr	-1430(ra) # 80000c9e <release>
  return xticks;
}
    8000323c:	02049513          	slli	a0,s1,0x20
    80003240:	9101                	srli	a0,a0,0x20
    80003242:	60e2                	ld	ra,24(sp)
    80003244:	6442                	ld	s0,16(sp)
    80003246:	64a2                	ld	s1,8(sp)
    80003248:	6105                	addi	sp,sp,32
    8000324a:	8082                	ret

000000008000324c <sys_memsize>:


//I Added
uint64 sys_memsize(void)
{
    8000324c:	1141                	addi	sp,sp,-16
    8000324e:	e406                	sd	ra,8(sp)
    80003250:	e022                	sd	s0,0(sp)
    80003252:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003254:	ffffe097          	auipc	ra,0xffffe
    80003258:	772080e7          	jalr	1906(ra) # 800019c6 <myproc>
  return p->sz;
}
    8000325c:	6528                	ld	a0,72(a0)
    8000325e:	60a2                	ld	ra,8(sp)
    80003260:	6402                	ld	s0,0(sp)
    80003262:	0141                	addi	sp,sp,16
    80003264:	8082                	ret

0000000080003266 <sys_forkn>:

uint64 sys_forkn(void)
{
    80003266:	7159                	addi	sp,sp,-112
    80003268:	f486                	sd	ra,104(sp)
    8000326a:	f0a2                	sd	s0,96(sp)
    8000326c:	eca6                	sd	s1,88(sp)
    8000326e:	1880                	addi	s0,sp,112
  int n;
  uint64 pids_addr;

  // Get args from userspace
  if (argint(0, &n) < 0 || argaddr(1, &pids_addr) < 0)
    80003270:	fdc40593          	addi	a1,s0,-36
    80003274:	4501                	li	a0,0
    80003276:	00000097          	auipc	ra,0x0
    8000327a:	cc4080e7          	jalr	-828(ra) # 80002f3a <argint>
    return -1;
    8000327e:	54fd                	li	s1,-1
  if (argint(0, &n) < 0 || argaddr(1, &pids_addr) < 0)
    80003280:	02054d63          	bltz	a0,800032ba <sys_forkn+0x54>
    80003284:	fd040593          	addi	a1,s0,-48
    80003288:	4505                	li	a0,1
    8000328a:	00000097          	auipc	ra,0x0
    8000328e:	cd2080e7          	jalr	-814(ra) # 80002f5c <argaddr>
    80003292:	04054e63          	bltz	a0,800032ee <sys_forkn+0x88>

  // Check for invalid input
  if (n < 1 || n > 16 || pids_addr == 0)
    80003296:	fdc42503          	lw	a0,-36(s0)
    8000329a:	fff5069b          	addiw	a3,a0,-1
    8000329e:	473d                	li	a4,15
    800032a0:	00d76d63          	bltu	a4,a3,800032ba <sys_forkn+0x54>
    800032a4:	fd043703          	ld	a4,-48(s0)
    800032a8:	cb09                	beqz	a4,800032ba <sys_forkn+0x54>
    return -1;

  int pids[16]; // Temporary kernel buffer

  int result = forkn(n, pids);  
    800032aa:	f9040593          	addi	a1,s0,-112
    800032ae:	fffff097          	auipc	ra,0xfffff
    800032b2:	3fe080e7          	jalr	1022(ra) # 800026ac <forkn>
    800032b6:	84aa                	mv	s1,a0
  if (result == 0) {
    800032b8:	c519                	beqz	a0,800032c6 <sys_forkn+0x60>
    if (copyout(p->pagetable, pids_addr, (char *)pids, n * sizeof(int)) < 0)
      return -1;
  }

  return result;
}
    800032ba:	8526                	mv	a0,s1
    800032bc:	70a6                	ld	ra,104(sp)
    800032be:	7406                	ld	s0,96(sp)
    800032c0:	64e6                	ld	s1,88(sp)
    800032c2:	6165                	addi	sp,sp,112
    800032c4:	8082                	ret
    struct proc *p = myproc();
    800032c6:	ffffe097          	auipc	ra,0xffffe
    800032ca:	700080e7          	jalr	1792(ra) # 800019c6 <myproc>
    if (copyout(p->pagetable, pids_addr, (char *)pids, n * sizeof(int)) < 0)
    800032ce:	fdc42683          	lw	a3,-36(s0)
    800032d2:	068a                	slli	a3,a3,0x2
    800032d4:	f9040613          	addi	a2,s0,-112
    800032d8:	fd043583          	ld	a1,-48(s0)
    800032dc:	6928                	ld	a0,80(a0)
    800032de:	ffffe097          	auipc	ra,0xffffe
    800032e2:	3a6080e7          	jalr	934(ra) # 80001684 <copyout>
    800032e6:	fc055ae3          	bgez	a0,800032ba <sys_forkn+0x54>
      return -1;
    800032ea:	54fd                	li	s1,-1
    800032ec:	b7f9                	j	800032ba <sys_forkn+0x54>
    return -1;
    800032ee:	54fd                	li	s1,-1
    800032f0:	b7e9                	j	800032ba <sys_forkn+0x54>

00000000800032f2 <sys_waitall>:

uint64 sys_waitall(void)
{
    800032f2:	1101                	addi	sp,sp,-32
    800032f4:	ec06                	sd	ra,24(sp)
    800032f6:	e822                	sd	s0,16(sp)
    800032f8:	1000                	addi	s0,sp,32
  uint64 n_addr, statuses_addr;

  argaddr(0, &n_addr);
    800032fa:	fe840593          	addi	a1,s0,-24
    800032fe:	4501                	li	a0,0
    80003300:	00000097          	auipc	ra,0x0
    80003304:	c5c080e7          	jalr	-932(ra) # 80002f5c <argaddr>
  argaddr(1, &statuses_addr);
    80003308:	fe040593          	addi	a1,s0,-32
    8000330c:	4505                	li	a0,1
    8000330e:	00000097          	auipc	ra,0x0
    80003312:	c4e080e7          	jalr	-946(ra) # 80002f5c <argaddr>

  if (n_addr == 0 || statuses_addr == 0)
    80003316:	fe843783          	ld	a5,-24(s0)
    return -1;
    8000331a:	557d                	li	a0,-1
  if (n_addr == 0 || statuses_addr == 0)
    8000331c:	cb89                	beqz	a5,8000332e <sys_waitall+0x3c>
    8000331e:	fe043583          	ld	a1,-32(s0)
    80003322:	c591                	beqz	a1,8000332e <sys_waitall+0x3c>

  return waitall((int *)n_addr, (int *)statuses_addr);
    80003324:	853e                	mv	a0,a5
    80003326:	fffff097          	auipc	ra,0xfffff
    8000332a:	546080e7          	jalr	1350(ra) # 8000286c <waitall>
}
    8000332e:	60e2                	ld	ra,24(sp)
    80003330:	6442                	ld	s0,16(sp)
    80003332:	6105                	addi	sp,sp,32
    80003334:	8082                	ret

0000000080003336 <sys_exit_num>:

uint64 sys_exit_num(void) {
    80003336:	1101                	addi	sp,sp,-32
    80003338:	ec06                	sd	ra,24(sp)
    8000333a:	e822                	sd	s0,16(sp)
    8000333c:	1000                	addi	s0,sp,32
  int status;
  if(argint(0, &status) < 0)
    8000333e:	fec40593          	addi	a1,s0,-20
    80003342:	4501                	li	a0,0
    80003344:	00000097          	auipc	ra,0x0
    80003348:	bf6080e7          	jalr	-1034(ra) # 80002f3a <argint>
    return -1;
    8000334c:	57fd                	li	a5,-1
  if(argint(0, &status) < 0)
    8000334e:	00054963          	bltz	a0,80003360 <sys_exit_num+0x2a>
  exit_num(status);
    80003352:	fec42503          	lw	a0,-20(s0)
    80003356:	fffff097          	auipc	ra,0xfffff
    8000335a:	f34080e7          	jalr	-204(ra) # 8000228a <exit_num>
  return 0; 
    8000335e:	4781                	li	a5,0
}
    80003360:	853e                	mv	a0,a5
    80003362:	60e2                	ld	ra,24(sp)
    80003364:	6442                	ld	s0,16(sp)
    80003366:	6105                	addi	sp,sp,32
    80003368:	8082                	ret

000000008000336a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000336a:	7179                	addi	sp,sp,-48
    8000336c:	f406                	sd	ra,40(sp)
    8000336e:	f022                	sd	s0,32(sp)
    80003370:	ec26                	sd	s1,24(sp)
    80003372:	e84a                	sd	s2,16(sp)
    80003374:	e44e                	sd	s3,8(sp)
    80003376:	e052                	sd	s4,0(sp)
    80003378:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000337a:	00005597          	auipc	a1,0x5
    8000337e:	39658593          	addi	a1,a1,918 # 80008710 <syscalls+0xe0>
    80003382:	00014517          	auipc	a0,0x14
    80003386:	00650513          	addi	a0,a0,6 # 80017388 <bcache>
    8000338a:	ffffd097          	auipc	ra,0xffffd
    8000338e:	7d0080e7          	jalr	2000(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003392:	0001c797          	auipc	a5,0x1c
    80003396:	ff678793          	addi	a5,a5,-10 # 8001f388 <bcache+0x8000>
    8000339a:	0001c717          	auipc	a4,0x1c
    8000339e:	25670713          	addi	a4,a4,598 # 8001f5f0 <bcache+0x8268>
    800033a2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033a6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033aa:	00014497          	auipc	s1,0x14
    800033ae:	ff648493          	addi	s1,s1,-10 # 800173a0 <bcache+0x18>
    b->next = bcache.head.next;
    800033b2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800033b4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800033b6:	00005a17          	auipc	s4,0x5
    800033ba:	362a0a13          	addi	s4,s4,866 # 80008718 <syscalls+0xe8>
    b->next = bcache.head.next;
    800033be:	2b893783          	ld	a5,696(s2)
    800033c2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033c4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033c8:	85d2                	mv	a1,s4
    800033ca:	01048513          	addi	a0,s1,16
    800033ce:	00001097          	auipc	ra,0x1
    800033d2:	4c4080e7          	jalr	1220(ra) # 80004892 <initsleeplock>
    bcache.head.next->prev = b;
    800033d6:	2b893783          	ld	a5,696(s2)
    800033da:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033dc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033e0:	45848493          	addi	s1,s1,1112
    800033e4:	fd349de3          	bne	s1,s3,800033be <binit+0x54>
  }
}
    800033e8:	70a2                	ld	ra,40(sp)
    800033ea:	7402                	ld	s0,32(sp)
    800033ec:	64e2                	ld	s1,24(sp)
    800033ee:	6942                	ld	s2,16(sp)
    800033f0:	69a2                	ld	s3,8(sp)
    800033f2:	6a02                	ld	s4,0(sp)
    800033f4:	6145                	addi	sp,sp,48
    800033f6:	8082                	ret

00000000800033f8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033f8:	7179                	addi	sp,sp,-48
    800033fa:	f406                	sd	ra,40(sp)
    800033fc:	f022                	sd	s0,32(sp)
    800033fe:	ec26                	sd	s1,24(sp)
    80003400:	e84a                	sd	s2,16(sp)
    80003402:	e44e                	sd	s3,8(sp)
    80003404:	1800                	addi	s0,sp,48
    80003406:	89aa                	mv	s3,a0
    80003408:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000340a:	00014517          	auipc	a0,0x14
    8000340e:	f7e50513          	addi	a0,a0,-130 # 80017388 <bcache>
    80003412:	ffffd097          	auipc	ra,0xffffd
    80003416:	7d8080e7          	jalr	2008(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000341a:	0001c497          	auipc	s1,0x1c
    8000341e:	2264b483          	ld	s1,550(s1) # 8001f640 <bcache+0x82b8>
    80003422:	0001c797          	auipc	a5,0x1c
    80003426:	1ce78793          	addi	a5,a5,462 # 8001f5f0 <bcache+0x8268>
    8000342a:	02f48f63          	beq	s1,a5,80003468 <bread+0x70>
    8000342e:	873e                	mv	a4,a5
    80003430:	a021                	j	80003438 <bread+0x40>
    80003432:	68a4                	ld	s1,80(s1)
    80003434:	02e48a63          	beq	s1,a4,80003468 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003438:	449c                	lw	a5,8(s1)
    8000343a:	ff379ce3          	bne	a5,s3,80003432 <bread+0x3a>
    8000343e:	44dc                	lw	a5,12(s1)
    80003440:	ff2799e3          	bne	a5,s2,80003432 <bread+0x3a>
      b->refcnt++;
    80003444:	40bc                	lw	a5,64(s1)
    80003446:	2785                	addiw	a5,a5,1
    80003448:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000344a:	00014517          	auipc	a0,0x14
    8000344e:	f3e50513          	addi	a0,a0,-194 # 80017388 <bcache>
    80003452:	ffffe097          	auipc	ra,0xffffe
    80003456:	84c080e7          	jalr	-1972(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    8000345a:	01048513          	addi	a0,s1,16
    8000345e:	00001097          	auipc	ra,0x1
    80003462:	46e080e7          	jalr	1134(ra) # 800048cc <acquiresleep>
      return b;
    80003466:	a8b9                	j	800034c4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003468:	0001c497          	auipc	s1,0x1c
    8000346c:	1d04b483          	ld	s1,464(s1) # 8001f638 <bcache+0x82b0>
    80003470:	0001c797          	auipc	a5,0x1c
    80003474:	18078793          	addi	a5,a5,384 # 8001f5f0 <bcache+0x8268>
    80003478:	00f48863          	beq	s1,a5,80003488 <bread+0x90>
    8000347c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000347e:	40bc                	lw	a5,64(s1)
    80003480:	cf81                	beqz	a5,80003498 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003482:	64a4                	ld	s1,72(s1)
    80003484:	fee49de3          	bne	s1,a4,8000347e <bread+0x86>
  panic("bget: no buffers");
    80003488:	00005517          	auipc	a0,0x5
    8000348c:	29850513          	addi	a0,a0,664 # 80008720 <syscalls+0xf0>
    80003490:	ffffd097          	auipc	ra,0xffffd
    80003494:	0b4080e7          	jalr	180(ra) # 80000544 <panic>
      b->dev = dev;
    80003498:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000349c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800034a0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034a4:	4785                	li	a5,1
    800034a6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034a8:	00014517          	auipc	a0,0x14
    800034ac:	ee050513          	addi	a0,a0,-288 # 80017388 <bcache>
    800034b0:	ffffd097          	auipc	ra,0xffffd
    800034b4:	7ee080e7          	jalr	2030(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800034b8:	01048513          	addi	a0,s1,16
    800034bc:	00001097          	auipc	ra,0x1
    800034c0:	410080e7          	jalr	1040(ra) # 800048cc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034c4:	409c                	lw	a5,0(s1)
    800034c6:	cb89                	beqz	a5,800034d8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034c8:	8526                	mv	a0,s1
    800034ca:	70a2                	ld	ra,40(sp)
    800034cc:	7402                	ld	s0,32(sp)
    800034ce:	64e2                	ld	s1,24(sp)
    800034d0:	6942                	ld	s2,16(sp)
    800034d2:	69a2                	ld	s3,8(sp)
    800034d4:	6145                	addi	sp,sp,48
    800034d6:	8082                	ret
    virtio_disk_rw(b, 0);
    800034d8:	4581                	li	a1,0
    800034da:	8526                	mv	a0,s1
    800034dc:	00003097          	auipc	ra,0x3
    800034e0:	fcc080e7          	jalr	-52(ra) # 800064a8 <virtio_disk_rw>
    b->valid = 1;
    800034e4:	4785                	li	a5,1
    800034e6:	c09c                	sw	a5,0(s1)
  return b;
    800034e8:	b7c5                	j	800034c8 <bread+0xd0>

00000000800034ea <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034ea:	1101                	addi	sp,sp,-32
    800034ec:	ec06                	sd	ra,24(sp)
    800034ee:	e822                	sd	s0,16(sp)
    800034f0:	e426                	sd	s1,8(sp)
    800034f2:	1000                	addi	s0,sp,32
    800034f4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034f6:	0541                	addi	a0,a0,16
    800034f8:	00001097          	auipc	ra,0x1
    800034fc:	46e080e7          	jalr	1134(ra) # 80004966 <holdingsleep>
    80003500:	cd01                	beqz	a0,80003518 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003502:	4585                	li	a1,1
    80003504:	8526                	mv	a0,s1
    80003506:	00003097          	auipc	ra,0x3
    8000350a:	fa2080e7          	jalr	-94(ra) # 800064a8 <virtio_disk_rw>
}
    8000350e:	60e2                	ld	ra,24(sp)
    80003510:	6442                	ld	s0,16(sp)
    80003512:	64a2                	ld	s1,8(sp)
    80003514:	6105                	addi	sp,sp,32
    80003516:	8082                	ret
    panic("bwrite");
    80003518:	00005517          	auipc	a0,0x5
    8000351c:	22050513          	addi	a0,a0,544 # 80008738 <syscalls+0x108>
    80003520:	ffffd097          	auipc	ra,0xffffd
    80003524:	024080e7          	jalr	36(ra) # 80000544 <panic>

0000000080003528 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003528:	1101                	addi	sp,sp,-32
    8000352a:	ec06                	sd	ra,24(sp)
    8000352c:	e822                	sd	s0,16(sp)
    8000352e:	e426                	sd	s1,8(sp)
    80003530:	e04a                	sd	s2,0(sp)
    80003532:	1000                	addi	s0,sp,32
    80003534:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003536:	01050913          	addi	s2,a0,16
    8000353a:	854a                	mv	a0,s2
    8000353c:	00001097          	auipc	ra,0x1
    80003540:	42a080e7          	jalr	1066(ra) # 80004966 <holdingsleep>
    80003544:	c92d                	beqz	a0,800035b6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003546:	854a                	mv	a0,s2
    80003548:	00001097          	auipc	ra,0x1
    8000354c:	3da080e7          	jalr	986(ra) # 80004922 <releasesleep>

  acquire(&bcache.lock);
    80003550:	00014517          	auipc	a0,0x14
    80003554:	e3850513          	addi	a0,a0,-456 # 80017388 <bcache>
    80003558:	ffffd097          	auipc	ra,0xffffd
    8000355c:	692080e7          	jalr	1682(ra) # 80000bea <acquire>
  b->refcnt--;
    80003560:	40bc                	lw	a5,64(s1)
    80003562:	37fd                	addiw	a5,a5,-1
    80003564:	0007871b          	sext.w	a4,a5
    80003568:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000356a:	eb05                	bnez	a4,8000359a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000356c:	68bc                	ld	a5,80(s1)
    8000356e:	64b8                	ld	a4,72(s1)
    80003570:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003572:	64bc                	ld	a5,72(s1)
    80003574:	68b8                	ld	a4,80(s1)
    80003576:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003578:	0001c797          	auipc	a5,0x1c
    8000357c:	e1078793          	addi	a5,a5,-496 # 8001f388 <bcache+0x8000>
    80003580:	2b87b703          	ld	a4,696(a5)
    80003584:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003586:	0001c717          	auipc	a4,0x1c
    8000358a:	06a70713          	addi	a4,a4,106 # 8001f5f0 <bcache+0x8268>
    8000358e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003590:	2b87b703          	ld	a4,696(a5)
    80003594:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003596:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000359a:	00014517          	auipc	a0,0x14
    8000359e:	dee50513          	addi	a0,a0,-530 # 80017388 <bcache>
    800035a2:	ffffd097          	auipc	ra,0xffffd
    800035a6:	6fc080e7          	jalr	1788(ra) # 80000c9e <release>
}
    800035aa:	60e2                	ld	ra,24(sp)
    800035ac:	6442                	ld	s0,16(sp)
    800035ae:	64a2                	ld	s1,8(sp)
    800035b0:	6902                	ld	s2,0(sp)
    800035b2:	6105                	addi	sp,sp,32
    800035b4:	8082                	ret
    panic("brelse");
    800035b6:	00005517          	auipc	a0,0x5
    800035ba:	18a50513          	addi	a0,a0,394 # 80008740 <syscalls+0x110>
    800035be:	ffffd097          	auipc	ra,0xffffd
    800035c2:	f86080e7          	jalr	-122(ra) # 80000544 <panic>

00000000800035c6 <bpin>:

void
bpin(struct buf *b) {
    800035c6:	1101                	addi	sp,sp,-32
    800035c8:	ec06                	sd	ra,24(sp)
    800035ca:	e822                	sd	s0,16(sp)
    800035cc:	e426                	sd	s1,8(sp)
    800035ce:	1000                	addi	s0,sp,32
    800035d0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035d2:	00014517          	auipc	a0,0x14
    800035d6:	db650513          	addi	a0,a0,-586 # 80017388 <bcache>
    800035da:	ffffd097          	auipc	ra,0xffffd
    800035de:	610080e7          	jalr	1552(ra) # 80000bea <acquire>
  b->refcnt++;
    800035e2:	40bc                	lw	a5,64(s1)
    800035e4:	2785                	addiw	a5,a5,1
    800035e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035e8:	00014517          	auipc	a0,0x14
    800035ec:	da050513          	addi	a0,a0,-608 # 80017388 <bcache>
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	6ae080e7          	jalr	1710(ra) # 80000c9e <release>
}
    800035f8:	60e2                	ld	ra,24(sp)
    800035fa:	6442                	ld	s0,16(sp)
    800035fc:	64a2                	ld	s1,8(sp)
    800035fe:	6105                	addi	sp,sp,32
    80003600:	8082                	ret

0000000080003602 <bunpin>:

void
bunpin(struct buf *b) {
    80003602:	1101                	addi	sp,sp,-32
    80003604:	ec06                	sd	ra,24(sp)
    80003606:	e822                	sd	s0,16(sp)
    80003608:	e426                	sd	s1,8(sp)
    8000360a:	1000                	addi	s0,sp,32
    8000360c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000360e:	00014517          	auipc	a0,0x14
    80003612:	d7a50513          	addi	a0,a0,-646 # 80017388 <bcache>
    80003616:	ffffd097          	auipc	ra,0xffffd
    8000361a:	5d4080e7          	jalr	1492(ra) # 80000bea <acquire>
  b->refcnt--;
    8000361e:	40bc                	lw	a5,64(s1)
    80003620:	37fd                	addiw	a5,a5,-1
    80003622:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003624:	00014517          	auipc	a0,0x14
    80003628:	d6450513          	addi	a0,a0,-668 # 80017388 <bcache>
    8000362c:	ffffd097          	auipc	ra,0xffffd
    80003630:	672080e7          	jalr	1650(ra) # 80000c9e <release>
}
    80003634:	60e2                	ld	ra,24(sp)
    80003636:	6442                	ld	s0,16(sp)
    80003638:	64a2                	ld	s1,8(sp)
    8000363a:	6105                	addi	sp,sp,32
    8000363c:	8082                	ret

000000008000363e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000363e:	1101                	addi	sp,sp,-32
    80003640:	ec06                	sd	ra,24(sp)
    80003642:	e822                	sd	s0,16(sp)
    80003644:	e426                	sd	s1,8(sp)
    80003646:	e04a                	sd	s2,0(sp)
    80003648:	1000                	addi	s0,sp,32
    8000364a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000364c:	00d5d59b          	srliw	a1,a1,0xd
    80003650:	0001c797          	auipc	a5,0x1c
    80003654:	4147a783          	lw	a5,1044(a5) # 8001fa64 <sb+0x1c>
    80003658:	9dbd                	addw	a1,a1,a5
    8000365a:	00000097          	auipc	ra,0x0
    8000365e:	d9e080e7          	jalr	-610(ra) # 800033f8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003662:	0074f713          	andi	a4,s1,7
    80003666:	4785                	li	a5,1
    80003668:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000366c:	14ce                	slli	s1,s1,0x33
    8000366e:	90d9                	srli	s1,s1,0x36
    80003670:	00950733          	add	a4,a0,s1
    80003674:	05874703          	lbu	a4,88(a4)
    80003678:	00e7f6b3          	and	a3,a5,a4
    8000367c:	c69d                	beqz	a3,800036aa <bfree+0x6c>
    8000367e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003680:	94aa                	add	s1,s1,a0
    80003682:	fff7c793          	not	a5,a5
    80003686:	8ff9                	and	a5,a5,a4
    80003688:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000368c:	00001097          	auipc	ra,0x1
    80003690:	120080e7          	jalr	288(ra) # 800047ac <log_write>
  brelse(bp);
    80003694:	854a                	mv	a0,s2
    80003696:	00000097          	auipc	ra,0x0
    8000369a:	e92080e7          	jalr	-366(ra) # 80003528 <brelse>
}
    8000369e:	60e2                	ld	ra,24(sp)
    800036a0:	6442                	ld	s0,16(sp)
    800036a2:	64a2                	ld	s1,8(sp)
    800036a4:	6902                	ld	s2,0(sp)
    800036a6:	6105                	addi	sp,sp,32
    800036a8:	8082                	ret
    panic("freeing free block");
    800036aa:	00005517          	auipc	a0,0x5
    800036ae:	09e50513          	addi	a0,a0,158 # 80008748 <syscalls+0x118>
    800036b2:	ffffd097          	auipc	ra,0xffffd
    800036b6:	e92080e7          	jalr	-366(ra) # 80000544 <panic>

00000000800036ba <balloc>:
{
    800036ba:	711d                	addi	sp,sp,-96
    800036bc:	ec86                	sd	ra,88(sp)
    800036be:	e8a2                	sd	s0,80(sp)
    800036c0:	e4a6                	sd	s1,72(sp)
    800036c2:	e0ca                	sd	s2,64(sp)
    800036c4:	fc4e                	sd	s3,56(sp)
    800036c6:	f852                	sd	s4,48(sp)
    800036c8:	f456                	sd	s5,40(sp)
    800036ca:	f05a                	sd	s6,32(sp)
    800036cc:	ec5e                	sd	s7,24(sp)
    800036ce:	e862                	sd	s8,16(sp)
    800036d0:	e466                	sd	s9,8(sp)
    800036d2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036d4:	0001c797          	auipc	a5,0x1c
    800036d8:	3787a783          	lw	a5,888(a5) # 8001fa4c <sb+0x4>
    800036dc:	10078163          	beqz	a5,800037de <balloc+0x124>
    800036e0:	8baa                	mv	s7,a0
    800036e2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036e4:	0001cb17          	auipc	s6,0x1c
    800036e8:	364b0b13          	addi	s6,s6,868 # 8001fa48 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036ec:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036ee:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036f0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036f2:	6c89                	lui	s9,0x2
    800036f4:	a061                	j	8000377c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036f6:	974a                	add	a4,a4,s2
    800036f8:	8fd5                	or	a5,a5,a3
    800036fa:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800036fe:	854a                	mv	a0,s2
    80003700:	00001097          	auipc	ra,0x1
    80003704:	0ac080e7          	jalr	172(ra) # 800047ac <log_write>
        brelse(bp);
    80003708:	854a                	mv	a0,s2
    8000370a:	00000097          	auipc	ra,0x0
    8000370e:	e1e080e7          	jalr	-482(ra) # 80003528 <brelse>
  bp = bread(dev, bno);
    80003712:	85a6                	mv	a1,s1
    80003714:	855e                	mv	a0,s7
    80003716:	00000097          	auipc	ra,0x0
    8000371a:	ce2080e7          	jalr	-798(ra) # 800033f8 <bread>
    8000371e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003720:	40000613          	li	a2,1024
    80003724:	4581                	li	a1,0
    80003726:	05850513          	addi	a0,a0,88
    8000372a:	ffffd097          	auipc	ra,0xffffd
    8000372e:	5bc080e7          	jalr	1468(ra) # 80000ce6 <memset>
  log_write(bp);
    80003732:	854a                	mv	a0,s2
    80003734:	00001097          	auipc	ra,0x1
    80003738:	078080e7          	jalr	120(ra) # 800047ac <log_write>
  brelse(bp);
    8000373c:	854a                	mv	a0,s2
    8000373e:	00000097          	auipc	ra,0x0
    80003742:	dea080e7          	jalr	-534(ra) # 80003528 <brelse>
}
    80003746:	8526                	mv	a0,s1
    80003748:	60e6                	ld	ra,88(sp)
    8000374a:	6446                	ld	s0,80(sp)
    8000374c:	64a6                	ld	s1,72(sp)
    8000374e:	6906                	ld	s2,64(sp)
    80003750:	79e2                	ld	s3,56(sp)
    80003752:	7a42                	ld	s4,48(sp)
    80003754:	7aa2                	ld	s5,40(sp)
    80003756:	7b02                	ld	s6,32(sp)
    80003758:	6be2                	ld	s7,24(sp)
    8000375a:	6c42                	ld	s8,16(sp)
    8000375c:	6ca2                	ld	s9,8(sp)
    8000375e:	6125                	addi	sp,sp,96
    80003760:	8082                	ret
    brelse(bp);
    80003762:	854a                	mv	a0,s2
    80003764:	00000097          	auipc	ra,0x0
    80003768:	dc4080e7          	jalr	-572(ra) # 80003528 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000376c:	015c87bb          	addw	a5,s9,s5
    80003770:	00078a9b          	sext.w	s5,a5
    80003774:	004b2703          	lw	a4,4(s6)
    80003778:	06eaf363          	bgeu	s5,a4,800037de <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000377c:	41fad79b          	sraiw	a5,s5,0x1f
    80003780:	0137d79b          	srliw	a5,a5,0x13
    80003784:	015787bb          	addw	a5,a5,s5
    80003788:	40d7d79b          	sraiw	a5,a5,0xd
    8000378c:	01cb2583          	lw	a1,28(s6)
    80003790:	9dbd                	addw	a1,a1,a5
    80003792:	855e                	mv	a0,s7
    80003794:	00000097          	auipc	ra,0x0
    80003798:	c64080e7          	jalr	-924(ra) # 800033f8 <bread>
    8000379c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000379e:	004b2503          	lw	a0,4(s6)
    800037a2:	000a849b          	sext.w	s1,s5
    800037a6:	8662                	mv	a2,s8
    800037a8:	faa4fde3          	bgeu	s1,a0,80003762 <balloc+0xa8>
      m = 1 << (bi % 8);
    800037ac:	41f6579b          	sraiw	a5,a2,0x1f
    800037b0:	01d7d69b          	srliw	a3,a5,0x1d
    800037b4:	00c6873b          	addw	a4,a3,a2
    800037b8:	00777793          	andi	a5,a4,7
    800037bc:	9f95                	subw	a5,a5,a3
    800037be:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037c2:	4037571b          	sraiw	a4,a4,0x3
    800037c6:	00e906b3          	add	a3,s2,a4
    800037ca:	0586c683          	lbu	a3,88(a3)
    800037ce:	00d7f5b3          	and	a1,a5,a3
    800037d2:	d195                	beqz	a1,800036f6 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037d4:	2605                	addiw	a2,a2,1
    800037d6:	2485                	addiw	s1,s1,1
    800037d8:	fd4618e3          	bne	a2,s4,800037a8 <balloc+0xee>
    800037dc:	b759                	j	80003762 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800037de:	00005517          	auipc	a0,0x5
    800037e2:	f8250513          	addi	a0,a0,-126 # 80008760 <syscalls+0x130>
    800037e6:	ffffd097          	auipc	ra,0xffffd
    800037ea:	da8080e7          	jalr	-600(ra) # 8000058e <printf>
  return 0;
    800037ee:	4481                	li	s1,0
    800037f0:	bf99                	j	80003746 <balloc+0x8c>

00000000800037f2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037f2:	7179                	addi	sp,sp,-48
    800037f4:	f406                	sd	ra,40(sp)
    800037f6:	f022                	sd	s0,32(sp)
    800037f8:	ec26                	sd	s1,24(sp)
    800037fa:	e84a                	sd	s2,16(sp)
    800037fc:	e44e                	sd	s3,8(sp)
    800037fe:	e052                	sd	s4,0(sp)
    80003800:	1800                	addi	s0,sp,48
    80003802:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003804:	47ad                	li	a5,11
    80003806:	02b7e763          	bltu	a5,a1,80003834 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000380a:	02059493          	slli	s1,a1,0x20
    8000380e:	9081                	srli	s1,s1,0x20
    80003810:	048a                	slli	s1,s1,0x2
    80003812:	94aa                	add	s1,s1,a0
    80003814:	0504a903          	lw	s2,80(s1)
    80003818:	06091e63          	bnez	s2,80003894 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000381c:	4108                	lw	a0,0(a0)
    8000381e:	00000097          	auipc	ra,0x0
    80003822:	e9c080e7          	jalr	-356(ra) # 800036ba <balloc>
    80003826:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000382a:	06090563          	beqz	s2,80003894 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    8000382e:	0524a823          	sw	s2,80(s1)
    80003832:	a08d                	j	80003894 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003834:	ff45849b          	addiw	s1,a1,-12
    80003838:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000383c:	0ff00793          	li	a5,255
    80003840:	08e7e563          	bltu	a5,a4,800038ca <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003844:	08052903          	lw	s2,128(a0)
    80003848:	00091d63          	bnez	s2,80003862 <bmap+0x70>
      addr = balloc(ip->dev);
    8000384c:	4108                	lw	a0,0(a0)
    8000384e:	00000097          	auipc	ra,0x0
    80003852:	e6c080e7          	jalr	-404(ra) # 800036ba <balloc>
    80003856:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000385a:	02090d63          	beqz	s2,80003894 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000385e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003862:	85ca                	mv	a1,s2
    80003864:	0009a503          	lw	a0,0(s3)
    80003868:	00000097          	auipc	ra,0x0
    8000386c:	b90080e7          	jalr	-1136(ra) # 800033f8 <bread>
    80003870:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003872:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003876:	02049593          	slli	a1,s1,0x20
    8000387a:	9181                	srli	a1,a1,0x20
    8000387c:	058a                	slli	a1,a1,0x2
    8000387e:	00b784b3          	add	s1,a5,a1
    80003882:	0004a903          	lw	s2,0(s1)
    80003886:	02090063          	beqz	s2,800038a6 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000388a:	8552                	mv	a0,s4
    8000388c:	00000097          	auipc	ra,0x0
    80003890:	c9c080e7          	jalr	-868(ra) # 80003528 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003894:	854a                	mv	a0,s2
    80003896:	70a2                	ld	ra,40(sp)
    80003898:	7402                	ld	s0,32(sp)
    8000389a:	64e2                	ld	s1,24(sp)
    8000389c:	6942                	ld	s2,16(sp)
    8000389e:	69a2                	ld	s3,8(sp)
    800038a0:	6a02                	ld	s4,0(sp)
    800038a2:	6145                	addi	sp,sp,48
    800038a4:	8082                	ret
      addr = balloc(ip->dev);
    800038a6:	0009a503          	lw	a0,0(s3)
    800038aa:	00000097          	auipc	ra,0x0
    800038ae:	e10080e7          	jalr	-496(ra) # 800036ba <balloc>
    800038b2:	0005091b          	sext.w	s2,a0
      if(addr){
    800038b6:	fc090ae3          	beqz	s2,8000388a <bmap+0x98>
        a[bn] = addr;
    800038ba:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800038be:	8552                	mv	a0,s4
    800038c0:	00001097          	auipc	ra,0x1
    800038c4:	eec080e7          	jalr	-276(ra) # 800047ac <log_write>
    800038c8:	b7c9                	j	8000388a <bmap+0x98>
  panic("bmap: out of range");
    800038ca:	00005517          	auipc	a0,0x5
    800038ce:	eae50513          	addi	a0,a0,-338 # 80008778 <syscalls+0x148>
    800038d2:	ffffd097          	auipc	ra,0xffffd
    800038d6:	c72080e7          	jalr	-910(ra) # 80000544 <panic>

00000000800038da <iget>:
{
    800038da:	7179                	addi	sp,sp,-48
    800038dc:	f406                	sd	ra,40(sp)
    800038de:	f022                	sd	s0,32(sp)
    800038e0:	ec26                	sd	s1,24(sp)
    800038e2:	e84a                	sd	s2,16(sp)
    800038e4:	e44e                	sd	s3,8(sp)
    800038e6:	e052                	sd	s4,0(sp)
    800038e8:	1800                	addi	s0,sp,48
    800038ea:	89aa                	mv	s3,a0
    800038ec:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038ee:	0001c517          	auipc	a0,0x1c
    800038f2:	17a50513          	addi	a0,a0,378 # 8001fa68 <itable>
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	2f4080e7          	jalr	756(ra) # 80000bea <acquire>
  empty = 0;
    800038fe:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003900:	0001c497          	auipc	s1,0x1c
    80003904:	18048493          	addi	s1,s1,384 # 8001fa80 <itable+0x18>
    80003908:	0001e697          	auipc	a3,0x1e
    8000390c:	c0868693          	addi	a3,a3,-1016 # 80021510 <log>
    80003910:	a039                	j	8000391e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003912:	02090b63          	beqz	s2,80003948 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003916:	08848493          	addi	s1,s1,136
    8000391a:	02d48a63          	beq	s1,a3,8000394e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000391e:	449c                	lw	a5,8(s1)
    80003920:	fef059e3          	blez	a5,80003912 <iget+0x38>
    80003924:	4098                	lw	a4,0(s1)
    80003926:	ff3716e3          	bne	a4,s3,80003912 <iget+0x38>
    8000392a:	40d8                	lw	a4,4(s1)
    8000392c:	ff4713e3          	bne	a4,s4,80003912 <iget+0x38>
      ip->ref++;
    80003930:	2785                	addiw	a5,a5,1
    80003932:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003934:	0001c517          	auipc	a0,0x1c
    80003938:	13450513          	addi	a0,a0,308 # 8001fa68 <itable>
    8000393c:	ffffd097          	auipc	ra,0xffffd
    80003940:	362080e7          	jalr	866(ra) # 80000c9e <release>
      return ip;
    80003944:	8926                	mv	s2,s1
    80003946:	a03d                	j	80003974 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003948:	f7f9                	bnez	a5,80003916 <iget+0x3c>
    8000394a:	8926                	mv	s2,s1
    8000394c:	b7e9                	j	80003916 <iget+0x3c>
  if(empty == 0)
    8000394e:	02090c63          	beqz	s2,80003986 <iget+0xac>
  ip->dev = dev;
    80003952:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003956:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000395a:	4785                	li	a5,1
    8000395c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003960:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003964:	0001c517          	auipc	a0,0x1c
    80003968:	10450513          	addi	a0,a0,260 # 8001fa68 <itable>
    8000396c:	ffffd097          	auipc	ra,0xffffd
    80003970:	332080e7          	jalr	818(ra) # 80000c9e <release>
}
    80003974:	854a                	mv	a0,s2
    80003976:	70a2                	ld	ra,40(sp)
    80003978:	7402                	ld	s0,32(sp)
    8000397a:	64e2                	ld	s1,24(sp)
    8000397c:	6942                	ld	s2,16(sp)
    8000397e:	69a2                	ld	s3,8(sp)
    80003980:	6a02                	ld	s4,0(sp)
    80003982:	6145                	addi	sp,sp,48
    80003984:	8082                	ret
    panic("iget: no inodes");
    80003986:	00005517          	auipc	a0,0x5
    8000398a:	e0a50513          	addi	a0,a0,-502 # 80008790 <syscalls+0x160>
    8000398e:	ffffd097          	auipc	ra,0xffffd
    80003992:	bb6080e7          	jalr	-1098(ra) # 80000544 <panic>

0000000080003996 <fsinit>:
fsinit(int dev) {
    80003996:	7179                	addi	sp,sp,-48
    80003998:	f406                	sd	ra,40(sp)
    8000399a:	f022                	sd	s0,32(sp)
    8000399c:	ec26                	sd	s1,24(sp)
    8000399e:	e84a                	sd	s2,16(sp)
    800039a0:	e44e                	sd	s3,8(sp)
    800039a2:	1800                	addi	s0,sp,48
    800039a4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039a6:	4585                	li	a1,1
    800039a8:	00000097          	auipc	ra,0x0
    800039ac:	a50080e7          	jalr	-1456(ra) # 800033f8 <bread>
    800039b0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039b2:	0001c997          	auipc	s3,0x1c
    800039b6:	09698993          	addi	s3,s3,150 # 8001fa48 <sb>
    800039ba:	02000613          	li	a2,32
    800039be:	05850593          	addi	a1,a0,88
    800039c2:	854e                	mv	a0,s3
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	382080e7          	jalr	898(ra) # 80000d46 <memmove>
  brelse(bp);
    800039cc:	8526                	mv	a0,s1
    800039ce:	00000097          	auipc	ra,0x0
    800039d2:	b5a080e7          	jalr	-1190(ra) # 80003528 <brelse>
  if(sb.magic != FSMAGIC)
    800039d6:	0009a703          	lw	a4,0(s3)
    800039da:	102037b7          	lui	a5,0x10203
    800039de:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039e2:	02f71263          	bne	a4,a5,80003a06 <fsinit+0x70>
  initlog(dev, &sb);
    800039e6:	0001c597          	auipc	a1,0x1c
    800039ea:	06258593          	addi	a1,a1,98 # 8001fa48 <sb>
    800039ee:	854a                	mv	a0,s2
    800039f0:	00001097          	auipc	ra,0x1
    800039f4:	b40080e7          	jalr	-1216(ra) # 80004530 <initlog>
}
    800039f8:	70a2                	ld	ra,40(sp)
    800039fa:	7402                	ld	s0,32(sp)
    800039fc:	64e2                	ld	s1,24(sp)
    800039fe:	6942                	ld	s2,16(sp)
    80003a00:	69a2                	ld	s3,8(sp)
    80003a02:	6145                	addi	sp,sp,48
    80003a04:	8082                	ret
    panic("invalid file system");
    80003a06:	00005517          	auipc	a0,0x5
    80003a0a:	d9a50513          	addi	a0,a0,-614 # 800087a0 <syscalls+0x170>
    80003a0e:	ffffd097          	auipc	ra,0xffffd
    80003a12:	b36080e7          	jalr	-1226(ra) # 80000544 <panic>

0000000080003a16 <iinit>:
{
    80003a16:	7179                	addi	sp,sp,-48
    80003a18:	f406                	sd	ra,40(sp)
    80003a1a:	f022                	sd	s0,32(sp)
    80003a1c:	ec26                	sd	s1,24(sp)
    80003a1e:	e84a                	sd	s2,16(sp)
    80003a20:	e44e                	sd	s3,8(sp)
    80003a22:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a24:	00005597          	auipc	a1,0x5
    80003a28:	d9458593          	addi	a1,a1,-620 # 800087b8 <syscalls+0x188>
    80003a2c:	0001c517          	auipc	a0,0x1c
    80003a30:	03c50513          	addi	a0,a0,60 # 8001fa68 <itable>
    80003a34:	ffffd097          	auipc	ra,0xffffd
    80003a38:	126080e7          	jalr	294(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a3c:	0001c497          	auipc	s1,0x1c
    80003a40:	05448493          	addi	s1,s1,84 # 8001fa90 <itable+0x28>
    80003a44:	0001e997          	auipc	s3,0x1e
    80003a48:	adc98993          	addi	s3,s3,-1316 # 80021520 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a4c:	00005917          	auipc	s2,0x5
    80003a50:	d7490913          	addi	s2,s2,-652 # 800087c0 <syscalls+0x190>
    80003a54:	85ca                	mv	a1,s2
    80003a56:	8526                	mv	a0,s1
    80003a58:	00001097          	auipc	ra,0x1
    80003a5c:	e3a080e7          	jalr	-454(ra) # 80004892 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a60:	08848493          	addi	s1,s1,136
    80003a64:	ff3498e3          	bne	s1,s3,80003a54 <iinit+0x3e>
}
    80003a68:	70a2                	ld	ra,40(sp)
    80003a6a:	7402                	ld	s0,32(sp)
    80003a6c:	64e2                	ld	s1,24(sp)
    80003a6e:	6942                	ld	s2,16(sp)
    80003a70:	69a2                	ld	s3,8(sp)
    80003a72:	6145                	addi	sp,sp,48
    80003a74:	8082                	ret

0000000080003a76 <ialloc>:
{
    80003a76:	715d                	addi	sp,sp,-80
    80003a78:	e486                	sd	ra,72(sp)
    80003a7a:	e0a2                	sd	s0,64(sp)
    80003a7c:	fc26                	sd	s1,56(sp)
    80003a7e:	f84a                	sd	s2,48(sp)
    80003a80:	f44e                	sd	s3,40(sp)
    80003a82:	f052                	sd	s4,32(sp)
    80003a84:	ec56                	sd	s5,24(sp)
    80003a86:	e85a                	sd	s6,16(sp)
    80003a88:	e45e                	sd	s7,8(sp)
    80003a8a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a8c:	0001c717          	auipc	a4,0x1c
    80003a90:	fc872703          	lw	a4,-56(a4) # 8001fa54 <sb+0xc>
    80003a94:	4785                	li	a5,1
    80003a96:	04e7fa63          	bgeu	a5,a4,80003aea <ialloc+0x74>
    80003a9a:	8aaa                	mv	s5,a0
    80003a9c:	8bae                	mv	s7,a1
    80003a9e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003aa0:	0001ca17          	auipc	s4,0x1c
    80003aa4:	fa8a0a13          	addi	s4,s4,-88 # 8001fa48 <sb>
    80003aa8:	00048b1b          	sext.w	s6,s1
    80003aac:	0044d593          	srli	a1,s1,0x4
    80003ab0:	018a2783          	lw	a5,24(s4)
    80003ab4:	9dbd                	addw	a1,a1,a5
    80003ab6:	8556                	mv	a0,s5
    80003ab8:	00000097          	auipc	ra,0x0
    80003abc:	940080e7          	jalr	-1728(ra) # 800033f8 <bread>
    80003ac0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ac2:	05850993          	addi	s3,a0,88
    80003ac6:	00f4f793          	andi	a5,s1,15
    80003aca:	079a                	slli	a5,a5,0x6
    80003acc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003ace:	00099783          	lh	a5,0(s3)
    80003ad2:	c3a1                	beqz	a5,80003b12 <ialloc+0x9c>
    brelse(bp);
    80003ad4:	00000097          	auipc	ra,0x0
    80003ad8:	a54080e7          	jalr	-1452(ra) # 80003528 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003adc:	0485                	addi	s1,s1,1
    80003ade:	00ca2703          	lw	a4,12(s4)
    80003ae2:	0004879b          	sext.w	a5,s1
    80003ae6:	fce7e1e3          	bltu	a5,a4,80003aa8 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003aea:	00005517          	auipc	a0,0x5
    80003aee:	cde50513          	addi	a0,a0,-802 # 800087c8 <syscalls+0x198>
    80003af2:	ffffd097          	auipc	ra,0xffffd
    80003af6:	a9c080e7          	jalr	-1380(ra) # 8000058e <printf>
  return 0;
    80003afa:	4501                	li	a0,0
}
    80003afc:	60a6                	ld	ra,72(sp)
    80003afe:	6406                	ld	s0,64(sp)
    80003b00:	74e2                	ld	s1,56(sp)
    80003b02:	7942                	ld	s2,48(sp)
    80003b04:	79a2                	ld	s3,40(sp)
    80003b06:	7a02                	ld	s4,32(sp)
    80003b08:	6ae2                	ld	s5,24(sp)
    80003b0a:	6b42                	ld	s6,16(sp)
    80003b0c:	6ba2                	ld	s7,8(sp)
    80003b0e:	6161                	addi	sp,sp,80
    80003b10:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b12:	04000613          	li	a2,64
    80003b16:	4581                	li	a1,0
    80003b18:	854e                	mv	a0,s3
    80003b1a:	ffffd097          	auipc	ra,0xffffd
    80003b1e:	1cc080e7          	jalr	460(ra) # 80000ce6 <memset>
      dip->type = type;
    80003b22:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b26:	854a                	mv	a0,s2
    80003b28:	00001097          	auipc	ra,0x1
    80003b2c:	c84080e7          	jalr	-892(ra) # 800047ac <log_write>
      brelse(bp);
    80003b30:	854a                	mv	a0,s2
    80003b32:	00000097          	auipc	ra,0x0
    80003b36:	9f6080e7          	jalr	-1546(ra) # 80003528 <brelse>
      return iget(dev, inum);
    80003b3a:	85da                	mv	a1,s6
    80003b3c:	8556                	mv	a0,s5
    80003b3e:	00000097          	auipc	ra,0x0
    80003b42:	d9c080e7          	jalr	-612(ra) # 800038da <iget>
    80003b46:	bf5d                	j	80003afc <ialloc+0x86>

0000000080003b48 <iupdate>:
{
    80003b48:	1101                	addi	sp,sp,-32
    80003b4a:	ec06                	sd	ra,24(sp)
    80003b4c:	e822                	sd	s0,16(sp)
    80003b4e:	e426                	sd	s1,8(sp)
    80003b50:	e04a                	sd	s2,0(sp)
    80003b52:	1000                	addi	s0,sp,32
    80003b54:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b56:	415c                	lw	a5,4(a0)
    80003b58:	0047d79b          	srliw	a5,a5,0x4
    80003b5c:	0001c597          	auipc	a1,0x1c
    80003b60:	f045a583          	lw	a1,-252(a1) # 8001fa60 <sb+0x18>
    80003b64:	9dbd                	addw	a1,a1,a5
    80003b66:	4108                	lw	a0,0(a0)
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	890080e7          	jalr	-1904(ra) # 800033f8 <bread>
    80003b70:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b72:	05850793          	addi	a5,a0,88
    80003b76:	40c8                	lw	a0,4(s1)
    80003b78:	893d                	andi	a0,a0,15
    80003b7a:	051a                	slli	a0,a0,0x6
    80003b7c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003b7e:	04449703          	lh	a4,68(s1)
    80003b82:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003b86:	04649703          	lh	a4,70(s1)
    80003b8a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003b8e:	04849703          	lh	a4,72(s1)
    80003b92:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003b96:	04a49703          	lh	a4,74(s1)
    80003b9a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003b9e:	44f8                	lw	a4,76(s1)
    80003ba0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ba2:	03400613          	li	a2,52
    80003ba6:	05048593          	addi	a1,s1,80
    80003baa:	0531                	addi	a0,a0,12
    80003bac:	ffffd097          	auipc	ra,0xffffd
    80003bb0:	19a080e7          	jalr	410(ra) # 80000d46 <memmove>
  log_write(bp);
    80003bb4:	854a                	mv	a0,s2
    80003bb6:	00001097          	auipc	ra,0x1
    80003bba:	bf6080e7          	jalr	-1034(ra) # 800047ac <log_write>
  brelse(bp);
    80003bbe:	854a                	mv	a0,s2
    80003bc0:	00000097          	auipc	ra,0x0
    80003bc4:	968080e7          	jalr	-1688(ra) # 80003528 <brelse>
}
    80003bc8:	60e2                	ld	ra,24(sp)
    80003bca:	6442                	ld	s0,16(sp)
    80003bcc:	64a2                	ld	s1,8(sp)
    80003bce:	6902                	ld	s2,0(sp)
    80003bd0:	6105                	addi	sp,sp,32
    80003bd2:	8082                	ret

0000000080003bd4 <idup>:
{
    80003bd4:	1101                	addi	sp,sp,-32
    80003bd6:	ec06                	sd	ra,24(sp)
    80003bd8:	e822                	sd	s0,16(sp)
    80003bda:	e426                	sd	s1,8(sp)
    80003bdc:	1000                	addi	s0,sp,32
    80003bde:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003be0:	0001c517          	auipc	a0,0x1c
    80003be4:	e8850513          	addi	a0,a0,-376 # 8001fa68 <itable>
    80003be8:	ffffd097          	auipc	ra,0xffffd
    80003bec:	002080e7          	jalr	2(ra) # 80000bea <acquire>
  ip->ref++;
    80003bf0:	449c                	lw	a5,8(s1)
    80003bf2:	2785                	addiw	a5,a5,1
    80003bf4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bf6:	0001c517          	auipc	a0,0x1c
    80003bfa:	e7250513          	addi	a0,a0,-398 # 8001fa68 <itable>
    80003bfe:	ffffd097          	auipc	ra,0xffffd
    80003c02:	0a0080e7          	jalr	160(ra) # 80000c9e <release>
}
    80003c06:	8526                	mv	a0,s1
    80003c08:	60e2                	ld	ra,24(sp)
    80003c0a:	6442                	ld	s0,16(sp)
    80003c0c:	64a2                	ld	s1,8(sp)
    80003c0e:	6105                	addi	sp,sp,32
    80003c10:	8082                	ret

0000000080003c12 <ilock>:
{
    80003c12:	1101                	addi	sp,sp,-32
    80003c14:	ec06                	sd	ra,24(sp)
    80003c16:	e822                	sd	s0,16(sp)
    80003c18:	e426                	sd	s1,8(sp)
    80003c1a:	e04a                	sd	s2,0(sp)
    80003c1c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c1e:	c115                	beqz	a0,80003c42 <ilock+0x30>
    80003c20:	84aa                	mv	s1,a0
    80003c22:	451c                	lw	a5,8(a0)
    80003c24:	00f05f63          	blez	a5,80003c42 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c28:	0541                	addi	a0,a0,16
    80003c2a:	00001097          	auipc	ra,0x1
    80003c2e:	ca2080e7          	jalr	-862(ra) # 800048cc <acquiresleep>
  if(ip->valid == 0){
    80003c32:	40bc                	lw	a5,64(s1)
    80003c34:	cf99                	beqz	a5,80003c52 <ilock+0x40>
}
    80003c36:	60e2                	ld	ra,24(sp)
    80003c38:	6442                	ld	s0,16(sp)
    80003c3a:	64a2                	ld	s1,8(sp)
    80003c3c:	6902                	ld	s2,0(sp)
    80003c3e:	6105                	addi	sp,sp,32
    80003c40:	8082                	ret
    panic("ilock");
    80003c42:	00005517          	auipc	a0,0x5
    80003c46:	b9e50513          	addi	a0,a0,-1122 # 800087e0 <syscalls+0x1b0>
    80003c4a:	ffffd097          	auipc	ra,0xffffd
    80003c4e:	8fa080e7          	jalr	-1798(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c52:	40dc                	lw	a5,4(s1)
    80003c54:	0047d79b          	srliw	a5,a5,0x4
    80003c58:	0001c597          	auipc	a1,0x1c
    80003c5c:	e085a583          	lw	a1,-504(a1) # 8001fa60 <sb+0x18>
    80003c60:	9dbd                	addw	a1,a1,a5
    80003c62:	4088                	lw	a0,0(s1)
    80003c64:	fffff097          	auipc	ra,0xfffff
    80003c68:	794080e7          	jalr	1940(ra) # 800033f8 <bread>
    80003c6c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c6e:	05850593          	addi	a1,a0,88
    80003c72:	40dc                	lw	a5,4(s1)
    80003c74:	8bbd                	andi	a5,a5,15
    80003c76:	079a                	slli	a5,a5,0x6
    80003c78:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c7a:	00059783          	lh	a5,0(a1)
    80003c7e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c82:	00259783          	lh	a5,2(a1)
    80003c86:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c8a:	00459783          	lh	a5,4(a1)
    80003c8e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c92:	00659783          	lh	a5,6(a1)
    80003c96:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c9a:	459c                	lw	a5,8(a1)
    80003c9c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c9e:	03400613          	li	a2,52
    80003ca2:	05b1                	addi	a1,a1,12
    80003ca4:	05048513          	addi	a0,s1,80
    80003ca8:	ffffd097          	auipc	ra,0xffffd
    80003cac:	09e080e7          	jalr	158(ra) # 80000d46 <memmove>
    brelse(bp);
    80003cb0:	854a                	mv	a0,s2
    80003cb2:	00000097          	auipc	ra,0x0
    80003cb6:	876080e7          	jalr	-1930(ra) # 80003528 <brelse>
    ip->valid = 1;
    80003cba:	4785                	li	a5,1
    80003cbc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003cbe:	04449783          	lh	a5,68(s1)
    80003cc2:	fbb5                	bnez	a5,80003c36 <ilock+0x24>
      panic("ilock: no type");
    80003cc4:	00005517          	auipc	a0,0x5
    80003cc8:	b2450513          	addi	a0,a0,-1244 # 800087e8 <syscalls+0x1b8>
    80003ccc:	ffffd097          	auipc	ra,0xffffd
    80003cd0:	878080e7          	jalr	-1928(ra) # 80000544 <panic>

0000000080003cd4 <iunlock>:
{
    80003cd4:	1101                	addi	sp,sp,-32
    80003cd6:	ec06                	sd	ra,24(sp)
    80003cd8:	e822                	sd	s0,16(sp)
    80003cda:	e426                	sd	s1,8(sp)
    80003cdc:	e04a                	sd	s2,0(sp)
    80003cde:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ce0:	c905                	beqz	a0,80003d10 <iunlock+0x3c>
    80003ce2:	84aa                	mv	s1,a0
    80003ce4:	01050913          	addi	s2,a0,16
    80003ce8:	854a                	mv	a0,s2
    80003cea:	00001097          	auipc	ra,0x1
    80003cee:	c7c080e7          	jalr	-900(ra) # 80004966 <holdingsleep>
    80003cf2:	cd19                	beqz	a0,80003d10 <iunlock+0x3c>
    80003cf4:	449c                	lw	a5,8(s1)
    80003cf6:	00f05d63          	blez	a5,80003d10 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003cfa:	854a                	mv	a0,s2
    80003cfc:	00001097          	auipc	ra,0x1
    80003d00:	c26080e7          	jalr	-986(ra) # 80004922 <releasesleep>
}
    80003d04:	60e2                	ld	ra,24(sp)
    80003d06:	6442                	ld	s0,16(sp)
    80003d08:	64a2                	ld	s1,8(sp)
    80003d0a:	6902                	ld	s2,0(sp)
    80003d0c:	6105                	addi	sp,sp,32
    80003d0e:	8082                	ret
    panic("iunlock");
    80003d10:	00005517          	auipc	a0,0x5
    80003d14:	ae850513          	addi	a0,a0,-1304 # 800087f8 <syscalls+0x1c8>
    80003d18:	ffffd097          	auipc	ra,0xffffd
    80003d1c:	82c080e7          	jalr	-2004(ra) # 80000544 <panic>

0000000080003d20 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d20:	7179                	addi	sp,sp,-48
    80003d22:	f406                	sd	ra,40(sp)
    80003d24:	f022                	sd	s0,32(sp)
    80003d26:	ec26                	sd	s1,24(sp)
    80003d28:	e84a                	sd	s2,16(sp)
    80003d2a:	e44e                	sd	s3,8(sp)
    80003d2c:	e052                	sd	s4,0(sp)
    80003d2e:	1800                	addi	s0,sp,48
    80003d30:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d32:	05050493          	addi	s1,a0,80
    80003d36:	08050913          	addi	s2,a0,128
    80003d3a:	a021                	j	80003d42 <itrunc+0x22>
    80003d3c:	0491                	addi	s1,s1,4
    80003d3e:	01248d63          	beq	s1,s2,80003d58 <itrunc+0x38>
    if(ip->addrs[i]){
    80003d42:	408c                	lw	a1,0(s1)
    80003d44:	dde5                	beqz	a1,80003d3c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d46:	0009a503          	lw	a0,0(s3)
    80003d4a:	00000097          	auipc	ra,0x0
    80003d4e:	8f4080e7          	jalr	-1804(ra) # 8000363e <bfree>
      ip->addrs[i] = 0;
    80003d52:	0004a023          	sw	zero,0(s1)
    80003d56:	b7dd                	j	80003d3c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d58:	0809a583          	lw	a1,128(s3)
    80003d5c:	e185                	bnez	a1,80003d7c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d5e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d62:	854e                	mv	a0,s3
    80003d64:	00000097          	auipc	ra,0x0
    80003d68:	de4080e7          	jalr	-540(ra) # 80003b48 <iupdate>
}
    80003d6c:	70a2                	ld	ra,40(sp)
    80003d6e:	7402                	ld	s0,32(sp)
    80003d70:	64e2                	ld	s1,24(sp)
    80003d72:	6942                	ld	s2,16(sp)
    80003d74:	69a2                	ld	s3,8(sp)
    80003d76:	6a02                	ld	s4,0(sp)
    80003d78:	6145                	addi	sp,sp,48
    80003d7a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d7c:	0009a503          	lw	a0,0(s3)
    80003d80:	fffff097          	auipc	ra,0xfffff
    80003d84:	678080e7          	jalr	1656(ra) # 800033f8 <bread>
    80003d88:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d8a:	05850493          	addi	s1,a0,88
    80003d8e:	45850913          	addi	s2,a0,1112
    80003d92:	a811                	j	80003da6 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003d94:	0009a503          	lw	a0,0(s3)
    80003d98:	00000097          	auipc	ra,0x0
    80003d9c:	8a6080e7          	jalr	-1882(ra) # 8000363e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003da0:	0491                	addi	s1,s1,4
    80003da2:	01248563          	beq	s1,s2,80003dac <itrunc+0x8c>
      if(a[j])
    80003da6:	408c                	lw	a1,0(s1)
    80003da8:	dde5                	beqz	a1,80003da0 <itrunc+0x80>
    80003daa:	b7ed                	j	80003d94 <itrunc+0x74>
    brelse(bp);
    80003dac:	8552                	mv	a0,s4
    80003dae:	fffff097          	auipc	ra,0xfffff
    80003db2:	77a080e7          	jalr	1914(ra) # 80003528 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003db6:	0809a583          	lw	a1,128(s3)
    80003dba:	0009a503          	lw	a0,0(s3)
    80003dbe:	00000097          	auipc	ra,0x0
    80003dc2:	880080e7          	jalr	-1920(ra) # 8000363e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003dc6:	0809a023          	sw	zero,128(s3)
    80003dca:	bf51                	j	80003d5e <itrunc+0x3e>

0000000080003dcc <iput>:
{
    80003dcc:	1101                	addi	sp,sp,-32
    80003dce:	ec06                	sd	ra,24(sp)
    80003dd0:	e822                	sd	s0,16(sp)
    80003dd2:	e426                	sd	s1,8(sp)
    80003dd4:	e04a                	sd	s2,0(sp)
    80003dd6:	1000                	addi	s0,sp,32
    80003dd8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003dda:	0001c517          	auipc	a0,0x1c
    80003dde:	c8e50513          	addi	a0,a0,-882 # 8001fa68 <itable>
    80003de2:	ffffd097          	auipc	ra,0xffffd
    80003de6:	e08080e7          	jalr	-504(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dea:	4498                	lw	a4,8(s1)
    80003dec:	4785                	li	a5,1
    80003dee:	02f70363          	beq	a4,a5,80003e14 <iput+0x48>
  ip->ref--;
    80003df2:	449c                	lw	a5,8(s1)
    80003df4:	37fd                	addiw	a5,a5,-1
    80003df6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003df8:	0001c517          	auipc	a0,0x1c
    80003dfc:	c7050513          	addi	a0,a0,-912 # 8001fa68 <itable>
    80003e00:	ffffd097          	auipc	ra,0xffffd
    80003e04:	e9e080e7          	jalr	-354(ra) # 80000c9e <release>
}
    80003e08:	60e2                	ld	ra,24(sp)
    80003e0a:	6442                	ld	s0,16(sp)
    80003e0c:	64a2                	ld	s1,8(sp)
    80003e0e:	6902                	ld	s2,0(sp)
    80003e10:	6105                	addi	sp,sp,32
    80003e12:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e14:	40bc                	lw	a5,64(s1)
    80003e16:	dff1                	beqz	a5,80003df2 <iput+0x26>
    80003e18:	04a49783          	lh	a5,74(s1)
    80003e1c:	fbf9                	bnez	a5,80003df2 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e1e:	01048913          	addi	s2,s1,16
    80003e22:	854a                	mv	a0,s2
    80003e24:	00001097          	auipc	ra,0x1
    80003e28:	aa8080e7          	jalr	-1368(ra) # 800048cc <acquiresleep>
    release(&itable.lock);
    80003e2c:	0001c517          	auipc	a0,0x1c
    80003e30:	c3c50513          	addi	a0,a0,-964 # 8001fa68 <itable>
    80003e34:	ffffd097          	auipc	ra,0xffffd
    80003e38:	e6a080e7          	jalr	-406(ra) # 80000c9e <release>
    itrunc(ip);
    80003e3c:	8526                	mv	a0,s1
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	ee2080e7          	jalr	-286(ra) # 80003d20 <itrunc>
    ip->type = 0;
    80003e46:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e4a:	8526                	mv	a0,s1
    80003e4c:	00000097          	auipc	ra,0x0
    80003e50:	cfc080e7          	jalr	-772(ra) # 80003b48 <iupdate>
    ip->valid = 0;
    80003e54:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e58:	854a                	mv	a0,s2
    80003e5a:	00001097          	auipc	ra,0x1
    80003e5e:	ac8080e7          	jalr	-1336(ra) # 80004922 <releasesleep>
    acquire(&itable.lock);
    80003e62:	0001c517          	auipc	a0,0x1c
    80003e66:	c0650513          	addi	a0,a0,-1018 # 8001fa68 <itable>
    80003e6a:	ffffd097          	auipc	ra,0xffffd
    80003e6e:	d80080e7          	jalr	-640(ra) # 80000bea <acquire>
    80003e72:	b741                	j	80003df2 <iput+0x26>

0000000080003e74 <iunlockput>:
{
    80003e74:	1101                	addi	sp,sp,-32
    80003e76:	ec06                	sd	ra,24(sp)
    80003e78:	e822                	sd	s0,16(sp)
    80003e7a:	e426                	sd	s1,8(sp)
    80003e7c:	1000                	addi	s0,sp,32
    80003e7e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	e54080e7          	jalr	-428(ra) # 80003cd4 <iunlock>
  iput(ip);
    80003e88:	8526                	mv	a0,s1
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	f42080e7          	jalr	-190(ra) # 80003dcc <iput>
}
    80003e92:	60e2                	ld	ra,24(sp)
    80003e94:	6442                	ld	s0,16(sp)
    80003e96:	64a2                	ld	s1,8(sp)
    80003e98:	6105                	addi	sp,sp,32
    80003e9a:	8082                	ret

0000000080003e9c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e9c:	1141                	addi	sp,sp,-16
    80003e9e:	e422                	sd	s0,8(sp)
    80003ea0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ea2:	411c                	lw	a5,0(a0)
    80003ea4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ea6:	415c                	lw	a5,4(a0)
    80003ea8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003eaa:	04451783          	lh	a5,68(a0)
    80003eae:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003eb2:	04a51783          	lh	a5,74(a0)
    80003eb6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003eba:	04c56783          	lwu	a5,76(a0)
    80003ebe:	e99c                	sd	a5,16(a1)
}
    80003ec0:	6422                	ld	s0,8(sp)
    80003ec2:	0141                	addi	sp,sp,16
    80003ec4:	8082                	ret

0000000080003ec6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ec6:	457c                	lw	a5,76(a0)
    80003ec8:	0ed7e963          	bltu	a5,a3,80003fba <readi+0xf4>
{
    80003ecc:	7159                	addi	sp,sp,-112
    80003ece:	f486                	sd	ra,104(sp)
    80003ed0:	f0a2                	sd	s0,96(sp)
    80003ed2:	eca6                	sd	s1,88(sp)
    80003ed4:	e8ca                	sd	s2,80(sp)
    80003ed6:	e4ce                	sd	s3,72(sp)
    80003ed8:	e0d2                	sd	s4,64(sp)
    80003eda:	fc56                	sd	s5,56(sp)
    80003edc:	f85a                	sd	s6,48(sp)
    80003ede:	f45e                	sd	s7,40(sp)
    80003ee0:	f062                	sd	s8,32(sp)
    80003ee2:	ec66                	sd	s9,24(sp)
    80003ee4:	e86a                	sd	s10,16(sp)
    80003ee6:	e46e                	sd	s11,8(sp)
    80003ee8:	1880                	addi	s0,sp,112
    80003eea:	8b2a                	mv	s6,a0
    80003eec:	8bae                	mv	s7,a1
    80003eee:	8a32                	mv	s4,a2
    80003ef0:	84b6                	mv	s1,a3
    80003ef2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ef4:	9f35                	addw	a4,a4,a3
    return 0;
    80003ef6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ef8:	0ad76063          	bltu	a4,a3,80003f98 <readi+0xd2>
  if(off + n > ip->size)
    80003efc:	00e7f463          	bgeu	a5,a4,80003f04 <readi+0x3e>
    n = ip->size - off;
    80003f00:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f04:	0a0a8963          	beqz	s5,80003fb6 <readi+0xf0>
    80003f08:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f0a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f0e:	5c7d                	li	s8,-1
    80003f10:	a82d                	j	80003f4a <readi+0x84>
    80003f12:	020d1d93          	slli	s11,s10,0x20
    80003f16:	020ddd93          	srli	s11,s11,0x20
    80003f1a:	05890613          	addi	a2,s2,88
    80003f1e:	86ee                	mv	a3,s11
    80003f20:	963a                	add	a2,a2,a4
    80003f22:	85d2                	mv	a1,s4
    80003f24:	855e                	mv	a0,s7
    80003f26:	ffffe097          	auipc	ra,0xffffe
    80003f2a:	62c080e7          	jalr	1580(ra) # 80002552 <either_copyout>
    80003f2e:	05850d63          	beq	a0,s8,80003f88 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f32:	854a                	mv	a0,s2
    80003f34:	fffff097          	auipc	ra,0xfffff
    80003f38:	5f4080e7          	jalr	1524(ra) # 80003528 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f3c:	013d09bb          	addw	s3,s10,s3
    80003f40:	009d04bb          	addw	s1,s10,s1
    80003f44:	9a6e                	add	s4,s4,s11
    80003f46:	0559f763          	bgeu	s3,s5,80003f94 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f4a:	00a4d59b          	srliw	a1,s1,0xa
    80003f4e:	855a                	mv	a0,s6
    80003f50:	00000097          	auipc	ra,0x0
    80003f54:	8a2080e7          	jalr	-1886(ra) # 800037f2 <bmap>
    80003f58:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f5c:	cd85                	beqz	a1,80003f94 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f5e:	000b2503          	lw	a0,0(s6)
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	496080e7          	jalr	1174(ra) # 800033f8 <bread>
    80003f6a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f6c:	3ff4f713          	andi	a4,s1,1023
    80003f70:	40ec87bb          	subw	a5,s9,a4
    80003f74:	413a86bb          	subw	a3,s5,s3
    80003f78:	8d3e                	mv	s10,a5
    80003f7a:	2781                	sext.w	a5,a5
    80003f7c:	0006861b          	sext.w	a2,a3
    80003f80:	f8f679e3          	bgeu	a2,a5,80003f12 <readi+0x4c>
    80003f84:	8d36                	mv	s10,a3
    80003f86:	b771                	j	80003f12 <readi+0x4c>
      brelse(bp);
    80003f88:	854a                	mv	a0,s2
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	59e080e7          	jalr	1438(ra) # 80003528 <brelse>
      tot = -1;
    80003f92:	59fd                	li	s3,-1
  }
  return tot;
    80003f94:	0009851b          	sext.w	a0,s3
}
    80003f98:	70a6                	ld	ra,104(sp)
    80003f9a:	7406                	ld	s0,96(sp)
    80003f9c:	64e6                	ld	s1,88(sp)
    80003f9e:	6946                	ld	s2,80(sp)
    80003fa0:	69a6                	ld	s3,72(sp)
    80003fa2:	6a06                	ld	s4,64(sp)
    80003fa4:	7ae2                	ld	s5,56(sp)
    80003fa6:	7b42                	ld	s6,48(sp)
    80003fa8:	7ba2                	ld	s7,40(sp)
    80003faa:	7c02                	ld	s8,32(sp)
    80003fac:	6ce2                	ld	s9,24(sp)
    80003fae:	6d42                	ld	s10,16(sp)
    80003fb0:	6da2                	ld	s11,8(sp)
    80003fb2:	6165                	addi	sp,sp,112
    80003fb4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fb6:	89d6                	mv	s3,s5
    80003fb8:	bff1                	j	80003f94 <readi+0xce>
    return 0;
    80003fba:	4501                	li	a0,0
}
    80003fbc:	8082                	ret

0000000080003fbe <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fbe:	457c                	lw	a5,76(a0)
    80003fc0:	10d7e863          	bltu	a5,a3,800040d0 <writei+0x112>
{
    80003fc4:	7159                	addi	sp,sp,-112
    80003fc6:	f486                	sd	ra,104(sp)
    80003fc8:	f0a2                	sd	s0,96(sp)
    80003fca:	eca6                	sd	s1,88(sp)
    80003fcc:	e8ca                	sd	s2,80(sp)
    80003fce:	e4ce                	sd	s3,72(sp)
    80003fd0:	e0d2                	sd	s4,64(sp)
    80003fd2:	fc56                	sd	s5,56(sp)
    80003fd4:	f85a                	sd	s6,48(sp)
    80003fd6:	f45e                	sd	s7,40(sp)
    80003fd8:	f062                	sd	s8,32(sp)
    80003fda:	ec66                	sd	s9,24(sp)
    80003fdc:	e86a                	sd	s10,16(sp)
    80003fde:	e46e                	sd	s11,8(sp)
    80003fe0:	1880                	addi	s0,sp,112
    80003fe2:	8aaa                	mv	s5,a0
    80003fe4:	8bae                	mv	s7,a1
    80003fe6:	8a32                	mv	s4,a2
    80003fe8:	8936                	mv	s2,a3
    80003fea:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fec:	00e687bb          	addw	a5,a3,a4
    80003ff0:	0ed7e263          	bltu	a5,a3,800040d4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ff4:	00043737          	lui	a4,0x43
    80003ff8:	0ef76063          	bltu	a4,a5,800040d8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ffc:	0c0b0863          	beqz	s6,800040cc <writei+0x10e>
    80004000:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004002:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004006:	5c7d                	li	s8,-1
    80004008:	a091                	j	8000404c <writei+0x8e>
    8000400a:	020d1d93          	slli	s11,s10,0x20
    8000400e:	020ddd93          	srli	s11,s11,0x20
    80004012:	05848513          	addi	a0,s1,88
    80004016:	86ee                	mv	a3,s11
    80004018:	8652                	mv	a2,s4
    8000401a:	85de                	mv	a1,s7
    8000401c:	953a                	add	a0,a0,a4
    8000401e:	ffffe097          	auipc	ra,0xffffe
    80004022:	58a080e7          	jalr	1418(ra) # 800025a8 <either_copyin>
    80004026:	07850263          	beq	a0,s8,8000408a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000402a:	8526                	mv	a0,s1
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	780080e7          	jalr	1920(ra) # 800047ac <log_write>
    brelse(bp);
    80004034:	8526                	mv	a0,s1
    80004036:	fffff097          	auipc	ra,0xfffff
    8000403a:	4f2080e7          	jalr	1266(ra) # 80003528 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000403e:	013d09bb          	addw	s3,s10,s3
    80004042:	012d093b          	addw	s2,s10,s2
    80004046:	9a6e                	add	s4,s4,s11
    80004048:	0569f663          	bgeu	s3,s6,80004094 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000404c:	00a9559b          	srliw	a1,s2,0xa
    80004050:	8556                	mv	a0,s5
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	7a0080e7          	jalr	1952(ra) # 800037f2 <bmap>
    8000405a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000405e:	c99d                	beqz	a1,80004094 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004060:	000aa503          	lw	a0,0(s5)
    80004064:	fffff097          	auipc	ra,0xfffff
    80004068:	394080e7          	jalr	916(ra) # 800033f8 <bread>
    8000406c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000406e:	3ff97713          	andi	a4,s2,1023
    80004072:	40ec87bb          	subw	a5,s9,a4
    80004076:	413b06bb          	subw	a3,s6,s3
    8000407a:	8d3e                	mv	s10,a5
    8000407c:	2781                	sext.w	a5,a5
    8000407e:	0006861b          	sext.w	a2,a3
    80004082:	f8f674e3          	bgeu	a2,a5,8000400a <writei+0x4c>
    80004086:	8d36                	mv	s10,a3
    80004088:	b749                	j	8000400a <writei+0x4c>
      brelse(bp);
    8000408a:	8526                	mv	a0,s1
    8000408c:	fffff097          	auipc	ra,0xfffff
    80004090:	49c080e7          	jalr	1180(ra) # 80003528 <brelse>
  }

  if(off > ip->size)
    80004094:	04caa783          	lw	a5,76(s5)
    80004098:	0127f463          	bgeu	a5,s2,800040a0 <writei+0xe2>
    ip->size = off;
    8000409c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800040a0:	8556                	mv	a0,s5
    800040a2:	00000097          	auipc	ra,0x0
    800040a6:	aa6080e7          	jalr	-1370(ra) # 80003b48 <iupdate>

  return tot;
    800040aa:	0009851b          	sext.w	a0,s3
}
    800040ae:	70a6                	ld	ra,104(sp)
    800040b0:	7406                	ld	s0,96(sp)
    800040b2:	64e6                	ld	s1,88(sp)
    800040b4:	6946                	ld	s2,80(sp)
    800040b6:	69a6                	ld	s3,72(sp)
    800040b8:	6a06                	ld	s4,64(sp)
    800040ba:	7ae2                	ld	s5,56(sp)
    800040bc:	7b42                	ld	s6,48(sp)
    800040be:	7ba2                	ld	s7,40(sp)
    800040c0:	7c02                	ld	s8,32(sp)
    800040c2:	6ce2                	ld	s9,24(sp)
    800040c4:	6d42                	ld	s10,16(sp)
    800040c6:	6da2                	ld	s11,8(sp)
    800040c8:	6165                	addi	sp,sp,112
    800040ca:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040cc:	89da                	mv	s3,s6
    800040ce:	bfc9                	j	800040a0 <writei+0xe2>
    return -1;
    800040d0:	557d                	li	a0,-1
}
    800040d2:	8082                	ret
    return -1;
    800040d4:	557d                	li	a0,-1
    800040d6:	bfe1                	j	800040ae <writei+0xf0>
    return -1;
    800040d8:	557d                	li	a0,-1
    800040da:	bfd1                	j	800040ae <writei+0xf0>

00000000800040dc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040dc:	1141                	addi	sp,sp,-16
    800040de:	e406                	sd	ra,8(sp)
    800040e0:	e022                	sd	s0,0(sp)
    800040e2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040e4:	4639                	li	a2,14
    800040e6:	ffffd097          	auipc	ra,0xffffd
    800040ea:	cd8080e7          	jalr	-808(ra) # 80000dbe <strncmp>
}
    800040ee:	60a2                	ld	ra,8(sp)
    800040f0:	6402                	ld	s0,0(sp)
    800040f2:	0141                	addi	sp,sp,16
    800040f4:	8082                	ret

00000000800040f6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040f6:	7139                	addi	sp,sp,-64
    800040f8:	fc06                	sd	ra,56(sp)
    800040fa:	f822                	sd	s0,48(sp)
    800040fc:	f426                	sd	s1,40(sp)
    800040fe:	f04a                	sd	s2,32(sp)
    80004100:	ec4e                	sd	s3,24(sp)
    80004102:	e852                	sd	s4,16(sp)
    80004104:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004106:	04451703          	lh	a4,68(a0)
    8000410a:	4785                	li	a5,1
    8000410c:	00f71a63          	bne	a4,a5,80004120 <dirlookup+0x2a>
    80004110:	892a                	mv	s2,a0
    80004112:	89ae                	mv	s3,a1
    80004114:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004116:	457c                	lw	a5,76(a0)
    80004118:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000411a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000411c:	e79d                	bnez	a5,8000414a <dirlookup+0x54>
    8000411e:	a8a5                	j	80004196 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004120:	00004517          	auipc	a0,0x4
    80004124:	6e050513          	addi	a0,a0,1760 # 80008800 <syscalls+0x1d0>
    80004128:	ffffc097          	auipc	ra,0xffffc
    8000412c:	41c080e7          	jalr	1052(ra) # 80000544 <panic>
      panic("dirlookup read");
    80004130:	00004517          	auipc	a0,0x4
    80004134:	6e850513          	addi	a0,a0,1768 # 80008818 <syscalls+0x1e8>
    80004138:	ffffc097          	auipc	ra,0xffffc
    8000413c:	40c080e7          	jalr	1036(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004140:	24c1                	addiw	s1,s1,16
    80004142:	04c92783          	lw	a5,76(s2)
    80004146:	04f4f763          	bgeu	s1,a5,80004194 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000414a:	4741                	li	a4,16
    8000414c:	86a6                	mv	a3,s1
    8000414e:	fc040613          	addi	a2,s0,-64
    80004152:	4581                	li	a1,0
    80004154:	854a                	mv	a0,s2
    80004156:	00000097          	auipc	ra,0x0
    8000415a:	d70080e7          	jalr	-656(ra) # 80003ec6 <readi>
    8000415e:	47c1                	li	a5,16
    80004160:	fcf518e3          	bne	a0,a5,80004130 <dirlookup+0x3a>
    if(de.inum == 0)
    80004164:	fc045783          	lhu	a5,-64(s0)
    80004168:	dfe1                	beqz	a5,80004140 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000416a:	fc240593          	addi	a1,s0,-62
    8000416e:	854e                	mv	a0,s3
    80004170:	00000097          	auipc	ra,0x0
    80004174:	f6c080e7          	jalr	-148(ra) # 800040dc <namecmp>
    80004178:	f561                	bnez	a0,80004140 <dirlookup+0x4a>
      if(poff)
    8000417a:	000a0463          	beqz	s4,80004182 <dirlookup+0x8c>
        *poff = off;
    8000417e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004182:	fc045583          	lhu	a1,-64(s0)
    80004186:	00092503          	lw	a0,0(s2)
    8000418a:	fffff097          	auipc	ra,0xfffff
    8000418e:	750080e7          	jalr	1872(ra) # 800038da <iget>
    80004192:	a011                	j	80004196 <dirlookup+0xa0>
  return 0;
    80004194:	4501                	li	a0,0
}
    80004196:	70e2                	ld	ra,56(sp)
    80004198:	7442                	ld	s0,48(sp)
    8000419a:	74a2                	ld	s1,40(sp)
    8000419c:	7902                	ld	s2,32(sp)
    8000419e:	69e2                	ld	s3,24(sp)
    800041a0:	6a42                	ld	s4,16(sp)
    800041a2:	6121                	addi	sp,sp,64
    800041a4:	8082                	ret

00000000800041a6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041a6:	711d                	addi	sp,sp,-96
    800041a8:	ec86                	sd	ra,88(sp)
    800041aa:	e8a2                	sd	s0,80(sp)
    800041ac:	e4a6                	sd	s1,72(sp)
    800041ae:	e0ca                	sd	s2,64(sp)
    800041b0:	fc4e                	sd	s3,56(sp)
    800041b2:	f852                	sd	s4,48(sp)
    800041b4:	f456                	sd	s5,40(sp)
    800041b6:	f05a                	sd	s6,32(sp)
    800041b8:	ec5e                	sd	s7,24(sp)
    800041ba:	e862                	sd	s8,16(sp)
    800041bc:	e466                	sd	s9,8(sp)
    800041be:	1080                	addi	s0,sp,96
    800041c0:	84aa                	mv	s1,a0
    800041c2:	8b2e                	mv	s6,a1
    800041c4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041c6:	00054703          	lbu	a4,0(a0)
    800041ca:	02f00793          	li	a5,47
    800041ce:	02f70363          	beq	a4,a5,800041f4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041d2:	ffffd097          	auipc	ra,0xffffd
    800041d6:	7f4080e7          	jalr	2036(ra) # 800019c6 <myproc>
    800041da:	15053503          	ld	a0,336(a0)
    800041de:	00000097          	auipc	ra,0x0
    800041e2:	9f6080e7          	jalr	-1546(ra) # 80003bd4 <idup>
    800041e6:	89aa                	mv	s3,a0
  while(*path == '/')
    800041e8:	02f00913          	li	s2,47
  len = path - s;
    800041ec:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800041ee:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041f0:	4c05                	li	s8,1
    800041f2:	a865                	j	800042aa <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800041f4:	4585                	li	a1,1
    800041f6:	4505                	li	a0,1
    800041f8:	fffff097          	auipc	ra,0xfffff
    800041fc:	6e2080e7          	jalr	1762(ra) # 800038da <iget>
    80004200:	89aa                	mv	s3,a0
    80004202:	b7dd                	j	800041e8 <namex+0x42>
      iunlockput(ip);
    80004204:	854e                	mv	a0,s3
    80004206:	00000097          	auipc	ra,0x0
    8000420a:	c6e080e7          	jalr	-914(ra) # 80003e74 <iunlockput>
      return 0;
    8000420e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004210:	854e                	mv	a0,s3
    80004212:	60e6                	ld	ra,88(sp)
    80004214:	6446                	ld	s0,80(sp)
    80004216:	64a6                	ld	s1,72(sp)
    80004218:	6906                	ld	s2,64(sp)
    8000421a:	79e2                	ld	s3,56(sp)
    8000421c:	7a42                	ld	s4,48(sp)
    8000421e:	7aa2                	ld	s5,40(sp)
    80004220:	7b02                	ld	s6,32(sp)
    80004222:	6be2                	ld	s7,24(sp)
    80004224:	6c42                	ld	s8,16(sp)
    80004226:	6ca2                	ld	s9,8(sp)
    80004228:	6125                	addi	sp,sp,96
    8000422a:	8082                	ret
      iunlock(ip);
    8000422c:	854e                	mv	a0,s3
    8000422e:	00000097          	auipc	ra,0x0
    80004232:	aa6080e7          	jalr	-1370(ra) # 80003cd4 <iunlock>
      return ip;
    80004236:	bfe9                	j	80004210 <namex+0x6a>
      iunlockput(ip);
    80004238:	854e                	mv	a0,s3
    8000423a:	00000097          	auipc	ra,0x0
    8000423e:	c3a080e7          	jalr	-966(ra) # 80003e74 <iunlockput>
      return 0;
    80004242:	89d2                	mv	s3,s4
    80004244:	b7f1                	j	80004210 <namex+0x6a>
  len = path - s;
    80004246:	40b48633          	sub	a2,s1,a1
    8000424a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    8000424e:	094cd463          	bge	s9,s4,800042d6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004252:	4639                	li	a2,14
    80004254:	8556                	mv	a0,s5
    80004256:	ffffd097          	auipc	ra,0xffffd
    8000425a:	af0080e7          	jalr	-1296(ra) # 80000d46 <memmove>
  while(*path == '/')
    8000425e:	0004c783          	lbu	a5,0(s1)
    80004262:	01279763          	bne	a5,s2,80004270 <namex+0xca>
    path++;
    80004266:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004268:	0004c783          	lbu	a5,0(s1)
    8000426c:	ff278de3          	beq	a5,s2,80004266 <namex+0xc0>
    ilock(ip);
    80004270:	854e                	mv	a0,s3
    80004272:	00000097          	auipc	ra,0x0
    80004276:	9a0080e7          	jalr	-1632(ra) # 80003c12 <ilock>
    if(ip->type != T_DIR){
    8000427a:	04499783          	lh	a5,68(s3)
    8000427e:	f98793e3          	bne	a5,s8,80004204 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004282:	000b0563          	beqz	s6,8000428c <namex+0xe6>
    80004286:	0004c783          	lbu	a5,0(s1)
    8000428a:	d3cd                	beqz	a5,8000422c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000428c:	865e                	mv	a2,s7
    8000428e:	85d6                	mv	a1,s5
    80004290:	854e                	mv	a0,s3
    80004292:	00000097          	auipc	ra,0x0
    80004296:	e64080e7          	jalr	-412(ra) # 800040f6 <dirlookup>
    8000429a:	8a2a                	mv	s4,a0
    8000429c:	dd51                	beqz	a0,80004238 <namex+0x92>
    iunlockput(ip);
    8000429e:	854e                	mv	a0,s3
    800042a0:	00000097          	auipc	ra,0x0
    800042a4:	bd4080e7          	jalr	-1068(ra) # 80003e74 <iunlockput>
    ip = next;
    800042a8:	89d2                	mv	s3,s4
  while(*path == '/')
    800042aa:	0004c783          	lbu	a5,0(s1)
    800042ae:	05279763          	bne	a5,s2,800042fc <namex+0x156>
    path++;
    800042b2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042b4:	0004c783          	lbu	a5,0(s1)
    800042b8:	ff278de3          	beq	a5,s2,800042b2 <namex+0x10c>
  if(*path == 0)
    800042bc:	c79d                	beqz	a5,800042ea <namex+0x144>
    path++;
    800042be:	85a6                	mv	a1,s1
  len = path - s;
    800042c0:	8a5e                	mv	s4,s7
    800042c2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800042c4:	01278963          	beq	a5,s2,800042d6 <namex+0x130>
    800042c8:	dfbd                	beqz	a5,80004246 <namex+0xa0>
    path++;
    800042ca:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800042cc:	0004c783          	lbu	a5,0(s1)
    800042d0:	ff279ce3          	bne	a5,s2,800042c8 <namex+0x122>
    800042d4:	bf8d                	j	80004246 <namex+0xa0>
    memmove(name, s, len);
    800042d6:	2601                	sext.w	a2,a2
    800042d8:	8556                	mv	a0,s5
    800042da:	ffffd097          	auipc	ra,0xffffd
    800042de:	a6c080e7          	jalr	-1428(ra) # 80000d46 <memmove>
    name[len] = 0;
    800042e2:	9a56                	add	s4,s4,s5
    800042e4:	000a0023          	sb	zero,0(s4)
    800042e8:	bf9d                	j	8000425e <namex+0xb8>
  if(nameiparent){
    800042ea:	f20b03e3          	beqz	s6,80004210 <namex+0x6a>
    iput(ip);
    800042ee:	854e                	mv	a0,s3
    800042f0:	00000097          	auipc	ra,0x0
    800042f4:	adc080e7          	jalr	-1316(ra) # 80003dcc <iput>
    return 0;
    800042f8:	4981                	li	s3,0
    800042fa:	bf19                	j	80004210 <namex+0x6a>
  if(*path == 0)
    800042fc:	d7fd                	beqz	a5,800042ea <namex+0x144>
  while(*path != '/' && *path != 0)
    800042fe:	0004c783          	lbu	a5,0(s1)
    80004302:	85a6                	mv	a1,s1
    80004304:	b7d1                	j	800042c8 <namex+0x122>

0000000080004306 <dirlink>:
{
    80004306:	7139                	addi	sp,sp,-64
    80004308:	fc06                	sd	ra,56(sp)
    8000430a:	f822                	sd	s0,48(sp)
    8000430c:	f426                	sd	s1,40(sp)
    8000430e:	f04a                	sd	s2,32(sp)
    80004310:	ec4e                	sd	s3,24(sp)
    80004312:	e852                	sd	s4,16(sp)
    80004314:	0080                	addi	s0,sp,64
    80004316:	892a                	mv	s2,a0
    80004318:	8a2e                	mv	s4,a1
    8000431a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000431c:	4601                	li	a2,0
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	dd8080e7          	jalr	-552(ra) # 800040f6 <dirlookup>
    80004326:	e93d                	bnez	a0,8000439c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004328:	04c92483          	lw	s1,76(s2)
    8000432c:	c49d                	beqz	s1,8000435a <dirlink+0x54>
    8000432e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004330:	4741                	li	a4,16
    80004332:	86a6                	mv	a3,s1
    80004334:	fc040613          	addi	a2,s0,-64
    80004338:	4581                	li	a1,0
    8000433a:	854a                	mv	a0,s2
    8000433c:	00000097          	auipc	ra,0x0
    80004340:	b8a080e7          	jalr	-1142(ra) # 80003ec6 <readi>
    80004344:	47c1                	li	a5,16
    80004346:	06f51163          	bne	a0,a5,800043a8 <dirlink+0xa2>
    if(de.inum == 0)
    8000434a:	fc045783          	lhu	a5,-64(s0)
    8000434e:	c791                	beqz	a5,8000435a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004350:	24c1                	addiw	s1,s1,16
    80004352:	04c92783          	lw	a5,76(s2)
    80004356:	fcf4ede3          	bltu	s1,a5,80004330 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000435a:	4639                	li	a2,14
    8000435c:	85d2                	mv	a1,s4
    8000435e:	fc240513          	addi	a0,s0,-62
    80004362:	ffffd097          	auipc	ra,0xffffd
    80004366:	a98080e7          	jalr	-1384(ra) # 80000dfa <strncpy>
  de.inum = inum;
    8000436a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000436e:	4741                	li	a4,16
    80004370:	86a6                	mv	a3,s1
    80004372:	fc040613          	addi	a2,s0,-64
    80004376:	4581                	li	a1,0
    80004378:	854a                	mv	a0,s2
    8000437a:	00000097          	auipc	ra,0x0
    8000437e:	c44080e7          	jalr	-956(ra) # 80003fbe <writei>
    80004382:	1541                	addi	a0,a0,-16
    80004384:	00a03533          	snez	a0,a0
    80004388:	40a00533          	neg	a0,a0
}
    8000438c:	70e2                	ld	ra,56(sp)
    8000438e:	7442                	ld	s0,48(sp)
    80004390:	74a2                	ld	s1,40(sp)
    80004392:	7902                	ld	s2,32(sp)
    80004394:	69e2                	ld	s3,24(sp)
    80004396:	6a42                	ld	s4,16(sp)
    80004398:	6121                	addi	sp,sp,64
    8000439a:	8082                	ret
    iput(ip);
    8000439c:	00000097          	auipc	ra,0x0
    800043a0:	a30080e7          	jalr	-1488(ra) # 80003dcc <iput>
    return -1;
    800043a4:	557d                	li	a0,-1
    800043a6:	b7dd                	j	8000438c <dirlink+0x86>
      panic("dirlink read");
    800043a8:	00004517          	auipc	a0,0x4
    800043ac:	48050513          	addi	a0,a0,1152 # 80008828 <syscalls+0x1f8>
    800043b0:	ffffc097          	auipc	ra,0xffffc
    800043b4:	194080e7          	jalr	404(ra) # 80000544 <panic>

00000000800043b8 <namei>:

struct inode*
namei(char *path)
{
    800043b8:	1101                	addi	sp,sp,-32
    800043ba:	ec06                	sd	ra,24(sp)
    800043bc:	e822                	sd	s0,16(sp)
    800043be:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043c0:	fe040613          	addi	a2,s0,-32
    800043c4:	4581                	li	a1,0
    800043c6:	00000097          	auipc	ra,0x0
    800043ca:	de0080e7          	jalr	-544(ra) # 800041a6 <namex>
}
    800043ce:	60e2                	ld	ra,24(sp)
    800043d0:	6442                	ld	s0,16(sp)
    800043d2:	6105                	addi	sp,sp,32
    800043d4:	8082                	ret

00000000800043d6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043d6:	1141                	addi	sp,sp,-16
    800043d8:	e406                	sd	ra,8(sp)
    800043da:	e022                	sd	s0,0(sp)
    800043dc:	0800                	addi	s0,sp,16
    800043de:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043e0:	4585                	li	a1,1
    800043e2:	00000097          	auipc	ra,0x0
    800043e6:	dc4080e7          	jalr	-572(ra) # 800041a6 <namex>
}
    800043ea:	60a2                	ld	ra,8(sp)
    800043ec:	6402                	ld	s0,0(sp)
    800043ee:	0141                	addi	sp,sp,16
    800043f0:	8082                	ret

00000000800043f2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043f2:	1101                	addi	sp,sp,-32
    800043f4:	ec06                	sd	ra,24(sp)
    800043f6:	e822                	sd	s0,16(sp)
    800043f8:	e426                	sd	s1,8(sp)
    800043fa:	e04a                	sd	s2,0(sp)
    800043fc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043fe:	0001d917          	auipc	s2,0x1d
    80004402:	11290913          	addi	s2,s2,274 # 80021510 <log>
    80004406:	01892583          	lw	a1,24(s2)
    8000440a:	02892503          	lw	a0,40(s2)
    8000440e:	fffff097          	auipc	ra,0xfffff
    80004412:	fea080e7          	jalr	-22(ra) # 800033f8 <bread>
    80004416:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004418:	02c92683          	lw	a3,44(s2)
    8000441c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000441e:	02d05763          	blez	a3,8000444c <write_head+0x5a>
    80004422:	0001d797          	auipc	a5,0x1d
    80004426:	11e78793          	addi	a5,a5,286 # 80021540 <log+0x30>
    8000442a:	05c50713          	addi	a4,a0,92
    8000442e:	36fd                	addiw	a3,a3,-1
    80004430:	1682                	slli	a3,a3,0x20
    80004432:	9281                	srli	a3,a3,0x20
    80004434:	068a                	slli	a3,a3,0x2
    80004436:	0001d617          	auipc	a2,0x1d
    8000443a:	10e60613          	addi	a2,a2,270 # 80021544 <log+0x34>
    8000443e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004440:	4390                	lw	a2,0(a5)
    80004442:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004444:	0791                	addi	a5,a5,4
    80004446:	0711                	addi	a4,a4,4
    80004448:	fed79ce3          	bne	a5,a3,80004440 <write_head+0x4e>
  }
  bwrite(buf);
    8000444c:	8526                	mv	a0,s1
    8000444e:	fffff097          	auipc	ra,0xfffff
    80004452:	09c080e7          	jalr	156(ra) # 800034ea <bwrite>
  brelse(buf);
    80004456:	8526                	mv	a0,s1
    80004458:	fffff097          	auipc	ra,0xfffff
    8000445c:	0d0080e7          	jalr	208(ra) # 80003528 <brelse>
}
    80004460:	60e2                	ld	ra,24(sp)
    80004462:	6442                	ld	s0,16(sp)
    80004464:	64a2                	ld	s1,8(sp)
    80004466:	6902                	ld	s2,0(sp)
    80004468:	6105                	addi	sp,sp,32
    8000446a:	8082                	ret

000000008000446c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000446c:	0001d797          	auipc	a5,0x1d
    80004470:	0d07a783          	lw	a5,208(a5) # 8002153c <log+0x2c>
    80004474:	0af05d63          	blez	a5,8000452e <install_trans+0xc2>
{
    80004478:	7139                	addi	sp,sp,-64
    8000447a:	fc06                	sd	ra,56(sp)
    8000447c:	f822                	sd	s0,48(sp)
    8000447e:	f426                	sd	s1,40(sp)
    80004480:	f04a                	sd	s2,32(sp)
    80004482:	ec4e                	sd	s3,24(sp)
    80004484:	e852                	sd	s4,16(sp)
    80004486:	e456                	sd	s5,8(sp)
    80004488:	e05a                	sd	s6,0(sp)
    8000448a:	0080                	addi	s0,sp,64
    8000448c:	8b2a                	mv	s6,a0
    8000448e:	0001da97          	auipc	s5,0x1d
    80004492:	0b2a8a93          	addi	s5,s5,178 # 80021540 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004496:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004498:	0001d997          	auipc	s3,0x1d
    8000449c:	07898993          	addi	s3,s3,120 # 80021510 <log>
    800044a0:	a035                	j	800044cc <install_trans+0x60>
      bunpin(dbuf);
    800044a2:	8526                	mv	a0,s1
    800044a4:	fffff097          	auipc	ra,0xfffff
    800044a8:	15e080e7          	jalr	350(ra) # 80003602 <bunpin>
    brelse(lbuf);
    800044ac:	854a                	mv	a0,s2
    800044ae:	fffff097          	auipc	ra,0xfffff
    800044b2:	07a080e7          	jalr	122(ra) # 80003528 <brelse>
    brelse(dbuf);
    800044b6:	8526                	mv	a0,s1
    800044b8:	fffff097          	auipc	ra,0xfffff
    800044bc:	070080e7          	jalr	112(ra) # 80003528 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044c0:	2a05                	addiw	s4,s4,1
    800044c2:	0a91                	addi	s5,s5,4
    800044c4:	02c9a783          	lw	a5,44(s3)
    800044c8:	04fa5963          	bge	s4,a5,8000451a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044cc:	0189a583          	lw	a1,24(s3)
    800044d0:	014585bb          	addw	a1,a1,s4
    800044d4:	2585                	addiw	a1,a1,1
    800044d6:	0289a503          	lw	a0,40(s3)
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	f1e080e7          	jalr	-226(ra) # 800033f8 <bread>
    800044e2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044e4:	000aa583          	lw	a1,0(s5)
    800044e8:	0289a503          	lw	a0,40(s3)
    800044ec:	fffff097          	auipc	ra,0xfffff
    800044f0:	f0c080e7          	jalr	-244(ra) # 800033f8 <bread>
    800044f4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044f6:	40000613          	li	a2,1024
    800044fa:	05890593          	addi	a1,s2,88
    800044fe:	05850513          	addi	a0,a0,88
    80004502:	ffffd097          	auipc	ra,0xffffd
    80004506:	844080e7          	jalr	-1980(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000450a:	8526                	mv	a0,s1
    8000450c:	fffff097          	auipc	ra,0xfffff
    80004510:	fde080e7          	jalr	-34(ra) # 800034ea <bwrite>
    if(recovering == 0)
    80004514:	f80b1ce3          	bnez	s6,800044ac <install_trans+0x40>
    80004518:	b769                	j	800044a2 <install_trans+0x36>
}
    8000451a:	70e2                	ld	ra,56(sp)
    8000451c:	7442                	ld	s0,48(sp)
    8000451e:	74a2                	ld	s1,40(sp)
    80004520:	7902                	ld	s2,32(sp)
    80004522:	69e2                	ld	s3,24(sp)
    80004524:	6a42                	ld	s4,16(sp)
    80004526:	6aa2                	ld	s5,8(sp)
    80004528:	6b02                	ld	s6,0(sp)
    8000452a:	6121                	addi	sp,sp,64
    8000452c:	8082                	ret
    8000452e:	8082                	ret

0000000080004530 <initlog>:
{
    80004530:	7179                	addi	sp,sp,-48
    80004532:	f406                	sd	ra,40(sp)
    80004534:	f022                	sd	s0,32(sp)
    80004536:	ec26                	sd	s1,24(sp)
    80004538:	e84a                	sd	s2,16(sp)
    8000453a:	e44e                	sd	s3,8(sp)
    8000453c:	1800                	addi	s0,sp,48
    8000453e:	892a                	mv	s2,a0
    80004540:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004542:	0001d497          	auipc	s1,0x1d
    80004546:	fce48493          	addi	s1,s1,-50 # 80021510 <log>
    8000454a:	00004597          	auipc	a1,0x4
    8000454e:	2ee58593          	addi	a1,a1,750 # 80008838 <syscalls+0x208>
    80004552:	8526                	mv	a0,s1
    80004554:	ffffc097          	auipc	ra,0xffffc
    80004558:	606080e7          	jalr	1542(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    8000455c:	0149a583          	lw	a1,20(s3)
    80004560:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004562:	0109a783          	lw	a5,16(s3)
    80004566:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004568:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000456c:	854a                	mv	a0,s2
    8000456e:	fffff097          	auipc	ra,0xfffff
    80004572:	e8a080e7          	jalr	-374(ra) # 800033f8 <bread>
  log.lh.n = lh->n;
    80004576:	4d3c                	lw	a5,88(a0)
    80004578:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000457a:	02f05563          	blez	a5,800045a4 <initlog+0x74>
    8000457e:	05c50713          	addi	a4,a0,92
    80004582:	0001d697          	auipc	a3,0x1d
    80004586:	fbe68693          	addi	a3,a3,-66 # 80021540 <log+0x30>
    8000458a:	37fd                	addiw	a5,a5,-1
    8000458c:	1782                	slli	a5,a5,0x20
    8000458e:	9381                	srli	a5,a5,0x20
    80004590:	078a                	slli	a5,a5,0x2
    80004592:	06050613          	addi	a2,a0,96
    80004596:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004598:	4310                	lw	a2,0(a4)
    8000459a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000459c:	0711                	addi	a4,a4,4
    8000459e:	0691                	addi	a3,a3,4
    800045a0:	fef71ce3          	bne	a4,a5,80004598 <initlog+0x68>
  brelse(buf);
    800045a4:	fffff097          	auipc	ra,0xfffff
    800045a8:	f84080e7          	jalr	-124(ra) # 80003528 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045ac:	4505                	li	a0,1
    800045ae:	00000097          	auipc	ra,0x0
    800045b2:	ebe080e7          	jalr	-322(ra) # 8000446c <install_trans>
  log.lh.n = 0;
    800045b6:	0001d797          	auipc	a5,0x1d
    800045ba:	f807a323          	sw	zero,-122(a5) # 8002153c <log+0x2c>
  write_head(); // clear the log
    800045be:	00000097          	auipc	ra,0x0
    800045c2:	e34080e7          	jalr	-460(ra) # 800043f2 <write_head>
}
    800045c6:	70a2                	ld	ra,40(sp)
    800045c8:	7402                	ld	s0,32(sp)
    800045ca:	64e2                	ld	s1,24(sp)
    800045cc:	6942                	ld	s2,16(sp)
    800045ce:	69a2                	ld	s3,8(sp)
    800045d0:	6145                	addi	sp,sp,48
    800045d2:	8082                	ret

00000000800045d4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045d4:	1101                	addi	sp,sp,-32
    800045d6:	ec06                	sd	ra,24(sp)
    800045d8:	e822                	sd	s0,16(sp)
    800045da:	e426                	sd	s1,8(sp)
    800045dc:	e04a                	sd	s2,0(sp)
    800045de:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045e0:	0001d517          	auipc	a0,0x1d
    800045e4:	f3050513          	addi	a0,a0,-208 # 80021510 <log>
    800045e8:	ffffc097          	auipc	ra,0xffffc
    800045ec:	602080e7          	jalr	1538(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    800045f0:	0001d497          	auipc	s1,0x1d
    800045f4:	f2048493          	addi	s1,s1,-224 # 80021510 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045f8:	4979                	li	s2,30
    800045fa:	a039                	j	80004608 <begin_op+0x34>
      sleep(&log, &log.lock);
    800045fc:	85a6                	mv	a1,s1
    800045fe:	8526                	mv	a0,s1
    80004600:	ffffe097          	auipc	ra,0xffffe
    80004604:	a6a080e7          	jalr	-1430(ra) # 8000206a <sleep>
    if(log.committing){
    80004608:	50dc                	lw	a5,36(s1)
    8000460a:	fbed                	bnez	a5,800045fc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000460c:	509c                	lw	a5,32(s1)
    8000460e:	0017871b          	addiw	a4,a5,1
    80004612:	0007069b          	sext.w	a3,a4
    80004616:	0027179b          	slliw	a5,a4,0x2
    8000461a:	9fb9                	addw	a5,a5,a4
    8000461c:	0017979b          	slliw	a5,a5,0x1
    80004620:	54d8                	lw	a4,44(s1)
    80004622:	9fb9                	addw	a5,a5,a4
    80004624:	00f95963          	bge	s2,a5,80004636 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004628:	85a6                	mv	a1,s1
    8000462a:	8526                	mv	a0,s1
    8000462c:	ffffe097          	auipc	ra,0xffffe
    80004630:	a3e080e7          	jalr	-1474(ra) # 8000206a <sleep>
    80004634:	bfd1                	j	80004608 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004636:	0001d517          	auipc	a0,0x1d
    8000463a:	eda50513          	addi	a0,a0,-294 # 80021510 <log>
    8000463e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	65e080e7          	jalr	1630(ra) # 80000c9e <release>
      break;
    }
  }
}
    80004648:	60e2                	ld	ra,24(sp)
    8000464a:	6442                	ld	s0,16(sp)
    8000464c:	64a2                	ld	s1,8(sp)
    8000464e:	6902                	ld	s2,0(sp)
    80004650:	6105                	addi	sp,sp,32
    80004652:	8082                	ret

0000000080004654 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004654:	7139                	addi	sp,sp,-64
    80004656:	fc06                	sd	ra,56(sp)
    80004658:	f822                	sd	s0,48(sp)
    8000465a:	f426                	sd	s1,40(sp)
    8000465c:	f04a                	sd	s2,32(sp)
    8000465e:	ec4e                	sd	s3,24(sp)
    80004660:	e852                	sd	s4,16(sp)
    80004662:	e456                	sd	s5,8(sp)
    80004664:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004666:	0001d497          	auipc	s1,0x1d
    8000466a:	eaa48493          	addi	s1,s1,-342 # 80021510 <log>
    8000466e:	8526                	mv	a0,s1
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	57a080e7          	jalr	1402(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    80004678:	509c                	lw	a5,32(s1)
    8000467a:	37fd                	addiw	a5,a5,-1
    8000467c:	0007891b          	sext.w	s2,a5
    80004680:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004682:	50dc                	lw	a5,36(s1)
    80004684:	efb9                	bnez	a5,800046e2 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004686:	06091663          	bnez	s2,800046f2 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000468a:	0001d497          	auipc	s1,0x1d
    8000468e:	e8648493          	addi	s1,s1,-378 # 80021510 <log>
    80004692:	4785                	li	a5,1
    80004694:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004696:	8526                	mv	a0,s1
    80004698:	ffffc097          	auipc	ra,0xffffc
    8000469c:	606080e7          	jalr	1542(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046a0:	54dc                	lw	a5,44(s1)
    800046a2:	06f04763          	bgtz	a5,80004710 <end_op+0xbc>
    acquire(&log.lock);
    800046a6:	0001d497          	auipc	s1,0x1d
    800046aa:	e6a48493          	addi	s1,s1,-406 # 80021510 <log>
    800046ae:	8526                	mv	a0,s1
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	53a080e7          	jalr	1338(ra) # 80000bea <acquire>
    log.committing = 0;
    800046b8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800046bc:	8526                	mv	a0,s1
    800046be:	ffffe097          	auipc	ra,0xffffe
    800046c2:	a10080e7          	jalr	-1520(ra) # 800020ce <wakeup>
    release(&log.lock);
    800046c6:	8526                	mv	a0,s1
    800046c8:	ffffc097          	auipc	ra,0xffffc
    800046cc:	5d6080e7          	jalr	1494(ra) # 80000c9e <release>
}
    800046d0:	70e2                	ld	ra,56(sp)
    800046d2:	7442                	ld	s0,48(sp)
    800046d4:	74a2                	ld	s1,40(sp)
    800046d6:	7902                	ld	s2,32(sp)
    800046d8:	69e2                	ld	s3,24(sp)
    800046da:	6a42                	ld	s4,16(sp)
    800046dc:	6aa2                	ld	s5,8(sp)
    800046de:	6121                	addi	sp,sp,64
    800046e0:	8082                	ret
    panic("log.committing");
    800046e2:	00004517          	auipc	a0,0x4
    800046e6:	15e50513          	addi	a0,a0,350 # 80008840 <syscalls+0x210>
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	e5a080e7          	jalr	-422(ra) # 80000544 <panic>
    wakeup(&log);
    800046f2:	0001d497          	auipc	s1,0x1d
    800046f6:	e1e48493          	addi	s1,s1,-482 # 80021510 <log>
    800046fa:	8526                	mv	a0,s1
    800046fc:	ffffe097          	auipc	ra,0xffffe
    80004700:	9d2080e7          	jalr	-1582(ra) # 800020ce <wakeup>
  release(&log.lock);
    80004704:	8526                	mv	a0,s1
    80004706:	ffffc097          	auipc	ra,0xffffc
    8000470a:	598080e7          	jalr	1432(ra) # 80000c9e <release>
  if(do_commit){
    8000470e:	b7c9                	j	800046d0 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004710:	0001da97          	auipc	s5,0x1d
    80004714:	e30a8a93          	addi	s5,s5,-464 # 80021540 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004718:	0001da17          	auipc	s4,0x1d
    8000471c:	df8a0a13          	addi	s4,s4,-520 # 80021510 <log>
    80004720:	018a2583          	lw	a1,24(s4)
    80004724:	012585bb          	addw	a1,a1,s2
    80004728:	2585                	addiw	a1,a1,1
    8000472a:	028a2503          	lw	a0,40(s4)
    8000472e:	fffff097          	auipc	ra,0xfffff
    80004732:	cca080e7          	jalr	-822(ra) # 800033f8 <bread>
    80004736:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004738:	000aa583          	lw	a1,0(s5)
    8000473c:	028a2503          	lw	a0,40(s4)
    80004740:	fffff097          	auipc	ra,0xfffff
    80004744:	cb8080e7          	jalr	-840(ra) # 800033f8 <bread>
    80004748:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000474a:	40000613          	li	a2,1024
    8000474e:	05850593          	addi	a1,a0,88
    80004752:	05848513          	addi	a0,s1,88
    80004756:	ffffc097          	auipc	ra,0xffffc
    8000475a:	5f0080e7          	jalr	1520(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    8000475e:	8526                	mv	a0,s1
    80004760:	fffff097          	auipc	ra,0xfffff
    80004764:	d8a080e7          	jalr	-630(ra) # 800034ea <bwrite>
    brelse(from);
    80004768:	854e                	mv	a0,s3
    8000476a:	fffff097          	auipc	ra,0xfffff
    8000476e:	dbe080e7          	jalr	-578(ra) # 80003528 <brelse>
    brelse(to);
    80004772:	8526                	mv	a0,s1
    80004774:	fffff097          	auipc	ra,0xfffff
    80004778:	db4080e7          	jalr	-588(ra) # 80003528 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000477c:	2905                	addiw	s2,s2,1
    8000477e:	0a91                	addi	s5,s5,4
    80004780:	02ca2783          	lw	a5,44(s4)
    80004784:	f8f94ee3          	blt	s2,a5,80004720 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004788:	00000097          	auipc	ra,0x0
    8000478c:	c6a080e7          	jalr	-918(ra) # 800043f2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004790:	4501                	li	a0,0
    80004792:	00000097          	auipc	ra,0x0
    80004796:	cda080e7          	jalr	-806(ra) # 8000446c <install_trans>
    log.lh.n = 0;
    8000479a:	0001d797          	auipc	a5,0x1d
    8000479e:	da07a123          	sw	zero,-606(a5) # 8002153c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800047a2:	00000097          	auipc	ra,0x0
    800047a6:	c50080e7          	jalr	-944(ra) # 800043f2 <write_head>
    800047aa:	bdf5                	j	800046a6 <end_op+0x52>

00000000800047ac <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047ac:	1101                	addi	sp,sp,-32
    800047ae:	ec06                	sd	ra,24(sp)
    800047b0:	e822                	sd	s0,16(sp)
    800047b2:	e426                	sd	s1,8(sp)
    800047b4:	e04a                	sd	s2,0(sp)
    800047b6:	1000                	addi	s0,sp,32
    800047b8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800047ba:	0001d917          	auipc	s2,0x1d
    800047be:	d5690913          	addi	s2,s2,-682 # 80021510 <log>
    800047c2:	854a                	mv	a0,s2
    800047c4:	ffffc097          	auipc	ra,0xffffc
    800047c8:	426080e7          	jalr	1062(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047cc:	02c92603          	lw	a2,44(s2)
    800047d0:	47f5                	li	a5,29
    800047d2:	06c7c563          	blt	a5,a2,8000483c <log_write+0x90>
    800047d6:	0001d797          	auipc	a5,0x1d
    800047da:	d567a783          	lw	a5,-682(a5) # 8002152c <log+0x1c>
    800047de:	37fd                	addiw	a5,a5,-1
    800047e0:	04f65e63          	bge	a2,a5,8000483c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047e4:	0001d797          	auipc	a5,0x1d
    800047e8:	d4c7a783          	lw	a5,-692(a5) # 80021530 <log+0x20>
    800047ec:	06f05063          	blez	a5,8000484c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047f0:	4781                	li	a5,0
    800047f2:	06c05563          	blez	a2,8000485c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047f6:	44cc                	lw	a1,12(s1)
    800047f8:	0001d717          	auipc	a4,0x1d
    800047fc:	d4870713          	addi	a4,a4,-696 # 80021540 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004800:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004802:	4314                	lw	a3,0(a4)
    80004804:	04b68c63          	beq	a3,a1,8000485c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004808:	2785                	addiw	a5,a5,1
    8000480a:	0711                	addi	a4,a4,4
    8000480c:	fef61be3          	bne	a2,a5,80004802 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004810:	0621                	addi	a2,a2,8
    80004812:	060a                	slli	a2,a2,0x2
    80004814:	0001d797          	auipc	a5,0x1d
    80004818:	cfc78793          	addi	a5,a5,-772 # 80021510 <log>
    8000481c:	963e                	add	a2,a2,a5
    8000481e:	44dc                	lw	a5,12(s1)
    80004820:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004822:	8526                	mv	a0,s1
    80004824:	fffff097          	auipc	ra,0xfffff
    80004828:	da2080e7          	jalr	-606(ra) # 800035c6 <bpin>
    log.lh.n++;
    8000482c:	0001d717          	auipc	a4,0x1d
    80004830:	ce470713          	addi	a4,a4,-796 # 80021510 <log>
    80004834:	575c                	lw	a5,44(a4)
    80004836:	2785                	addiw	a5,a5,1
    80004838:	d75c                	sw	a5,44(a4)
    8000483a:	a835                	j	80004876 <log_write+0xca>
    panic("too big a transaction");
    8000483c:	00004517          	auipc	a0,0x4
    80004840:	01450513          	addi	a0,a0,20 # 80008850 <syscalls+0x220>
    80004844:	ffffc097          	auipc	ra,0xffffc
    80004848:	d00080e7          	jalr	-768(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    8000484c:	00004517          	auipc	a0,0x4
    80004850:	01c50513          	addi	a0,a0,28 # 80008868 <syscalls+0x238>
    80004854:	ffffc097          	auipc	ra,0xffffc
    80004858:	cf0080e7          	jalr	-784(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    8000485c:	00878713          	addi	a4,a5,8
    80004860:	00271693          	slli	a3,a4,0x2
    80004864:	0001d717          	auipc	a4,0x1d
    80004868:	cac70713          	addi	a4,a4,-852 # 80021510 <log>
    8000486c:	9736                	add	a4,a4,a3
    8000486e:	44d4                	lw	a3,12(s1)
    80004870:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004872:	faf608e3          	beq	a2,a5,80004822 <log_write+0x76>
  }
  release(&log.lock);
    80004876:	0001d517          	auipc	a0,0x1d
    8000487a:	c9a50513          	addi	a0,a0,-870 # 80021510 <log>
    8000487e:	ffffc097          	auipc	ra,0xffffc
    80004882:	420080e7          	jalr	1056(ra) # 80000c9e <release>
}
    80004886:	60e2                	ld	ra,24(sp)
    80004888:	6442                	ld	s0,16(sp)
    8000488a:	64a2                	ld	s1,8(sp)
    8000488c:	6902                	ld	s2,0(sp)
    8000488e:	6105                	addi	sp,sp,32
    80004890:	8082                	ret

0000000080004892 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004892:	1101                	addi	sp,sp,-32
    80004894:	ec06                	sd	ra,24(sp)
    80004896:	e822                	sd	s0,16(sp)
    80004898:	e426                	sd	s1,8(sp)
    8000489a:	e04a                	sd	s2,0(sp)
    8000489c:	1000                	addi	s0,sp,32
    8000489e:	84aa                	mv	s1,a0
    800048a0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048a2:	00004597          	auipc	a1,0x4
    800048a6:	fe658593          	addi	a1,a1,-26 # 80008888 <syscalls+0x258>
    800048aa:	0521                	addi	a0,a0,8
    800048ac:	ffffc097          	auipc	ra,0xffffc
    800048b0:	2ae080e7          	jalr	686(ra) # 80000b5a <initlock>
  lk->name = name;
    800048b4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800048b8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048bc:	0204a423          	sw	zero,40(s1)
}
    800048c0:	60e2                	ld	ra,24(sp)
    800048c2:	6442                	ld	s0,16(sp)
    800048c4:	64a2                	ld	s1,8(sp)
    800048c6:	6902                	ld	s2,0(sp)
    800048c8:	6105                	addi	sp,sp,32
    800048ca:	8082                	ret

00000000800048cc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048cc:	1101                	addi	sp,sp,-32
    800048ce:	ec06                	sd	ra,24(sp)
    800048d0:	e822                	sd	s0,16(sp)
    800048d2:	e426                	sd	s1,8(sp)
    800048d4:	e04a                	sd	s2,0(sp)
    800048d6:	1000                	addi	s0,sp,32
    800048d8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048da:	00850913          	addi	s2,a0,8
    800048de:	854a                	mv	a0,s2
    800048e0:	ffffc097          	auipc	ra,0xffffc
    800048e4:	30a080e7          	jalr	778(ra) # 80000bea <acquire>
  while (lk->locked) {
    800048e8:	409c                	lw	a5,0(s1)
    800048ea:	cb89                	beqz	a5,800048fc <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048ec:	85ca                	mv	a1,s2
    800048ee:	8526                	mv	a0,s1
    800048f0:	ffffd097          	auipc	ra,0xffffd
    800048f4:	77a080e7          	jalr	1914(ra) # 8000206a <sleep>
  while (lk->locked) {
    800048f8:	409c                	lw	a5,0(s1)
    800048fa:	fbed                	bnez	a5,800048ec <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048fc:	4785                	li	a5,1
    800048fe:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004900:	ffffd097          	auipc	ra,0xffffd
    80004904:	0c6080e7          	jalr	198(ra) # 800019c6 <myproc>
    80004908:	591c                	lw	a5,48(a0)
    8000490a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000490c:	854a                	mv	a0,s2
    8000490e:	ffffc097          	auipc	ra,0xffffc
    80004912:	390080e7          	jalr	912(ra) # 80000c9e <release>
}
    80004916:	60e2                	ld	ra,24(sp)
    80004918:	6442                	ld	s0,16(sp)
    8000491a:	64a2                	ld	s1,8(sp)
    8000491c:	6902                	ld	s2,0(sp)
    8000491e:	6105                	addi	sp,sp,32
    80004920:	8082                	ret

0000000080004922 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004922:	1101                	addi	sp,sp,-32
    80004924:	ec06                	sd	ra,24(sp)
    80004926:	e822                	sd	s0,16(sp)
    80004928:	e426                	sd	s1,8(sp)
    8000492a:	e04a                	sd	s2,0(sp)
    8000492c:	1000                	addi	s0,sp,32
    8000492e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004930:	00850913          	addi	s2,a0,8
    80004934:	854a                	mv	a0,s2
    80004936:	ffffc097          	auipc	ra,0xffffc
    8000493a:	2b4080e7          	jalr	692(ra) # 80000bea <acquire>
  lk->locked = 0;
    8000493e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004942:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004946:	8526                	mv	a0,s1
    80004948:	ffffd097          	auipc	ra,0xffffd
    8000494c:	786080e7          	jalr	1926(ra) # 800020ce <wakeup>
  release(&lk->lk);
    80004950:	854a                	mv	a0,s2
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	34c080e7          	jalr	844(ra) # 80000c9e <release>
}
    8000495a:	60e2                	ld	ra,24(sp)
    8000495c:	6442                	ld	s0,16(sp)
    8000495e:	64a2                	ld	s1,8(sp)
    80004960:	6902                	ld	s2,0(sp)
    80004962:	6105                	addi	sp,sp,32
    80004964:	8082                	ret

0000000080004966 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004966:	7179                	addi	sp,sp,-48
    80004968:	f406                	sd	ra,40(sp)
    8000496a:	f022                	sd	s0,32(sp)
    8000496c:	ec26                	sd	s1,24(sp)
    8000496e:	e84a                	sd	s2,16(sp)
    80004970:	e44e                	sd	s3,8(sp)
    80004972:	1800                	addi	s0,sp,48
    80004974:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004976:	00850913          	addi	s2,a0,8
    8000497a:	854a                	mv	a0,s2
    8000497c:	ffffc097          	auipc	ra,0xffffc
    80004980:	26e080e7          	jalr	622(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004984:	409c                	lw	a5,0(s1)
    80004986:	ef99                	bnez	a5,800049a4 <holdingsleep+0x3e>
    80004988:	4481                	li	s1,0
  release(&lk->lk);
    8000498a:	854a                	mv	a0,s2
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	312080e7          	jalr	786(ra) # 80000c9e <release>
  return r;
}
    80004994:	8526                	mv	a0,s1
    80004996:	70a2                	ld	ra,40(sp)
    80004998:	7402                	ld	s0,32(sp)
    8000499a:	64e2                	ld	s1,24(sp)
    8000499c:	6942                	ld	s2,16(sp)
    8000499e:	69a2                	ld	s3,8(sp)
    800049a0:	6145                	addi	sp,sp,48
    800049a2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800049a4:	0284a983          	lw	s3,40(s1)
    800049a8:	ffffd097          	auipc	ra,0xffffd
    800049ac:	01e080e7          	jalr	30(ra) # 800019c6 <myproc>
    800049b0:	5904                	lw	s1,48(a0)
    800049b2:	413484b3          	sub	s1,s1,s3
    800049b6:	0014b493          	seqz	s1,s1
    800049ba:	bfc1                	j	8000498a <holdingsleep+0x24>

00000000800049bc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049bc:	1141                	addi	sp,sp,-16
    800049be:	e406                	sd	ra,8(sp)
    800049c0:	e022                	sd	s0,0(sp)
    800049c2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049c4:	00004597          	auipc	a1,0x4
    800049c8:	ed458593          	addi	a1,a1,-300 # 80008898 <syscalls+0x268>
    800049cc:	0001d517          	auipc	a0,0x1d
    800049d0:	c8c50513          	addi	a0,a0,-884 # 80021658 <ftable>
    800049d4:	ffffc097          	auipc	ra,0xffffc
    800049d8:	186080e7          	jalr	390(ra) # 80000b5a <initlock>
}
    800049dc:	60a2                	ld	ra,8(sp)
    800049de:	6402                	ld	s0,0(sp)
    800049e0:	0141                	addi	sp,sp,16
    800049e2:	8082                	ret

00000000800049e4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049e4:	1101                	addi	sp,sp,-32
    800049e6:	ec06                	sd	ra,24(sp)
    800049e8:	e822                	sd	s0,16(sp)
    800049ea:	e426                	sd	s1,8(sp)
    800049ec:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049ee:	0001d517          	auipc	a0,0x1d
    800049f2:	c6a50513          	addi	a0,a0,-918 # 80021658 <ftable>
    800049f6:	ffffc097          	auipc	ra,0xffffc
    800049fa:	1f4080e7          	jalr	500(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049fe:	0001d497          	auipc	s1,0x1d
    80004a02:	c7248493          	addi	s1,s1,-910 # 80021670 <ftable+0x18>
    80004a06:	0001e717          	auipc	a4,0x1e
    80004a0a:	c0a70713          	addi	a4,a4,-1014 # 80022610 <disk>
    if(f->ref == 0){
    80004a0e:	40dc                	lw	a5,4(s1)
    80004a10:	cf99                	beqz	a5,80004a2e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a12:	02848493          	addi	s1,s1,40
    80004a16:	fee49ce3          	bne	s1,a4,80004a0e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a1a:	0001d517          	auipc	a0,0x1d
    80004a1e:	c3e50513          	addi	a0,a0,-962 # 80021658 <ftable>
    80004a22:	ffffc097          	auipc	ra,0xffffc
    80004a26:	27c080e7          	jalr	636(ra) # 80000c9e <release>
  return 0;
    80004a2a:	4481                	li	s1,0
    80004a2c:	a819                	j	80004a42 <filealloc+0x5e>
      f->ref = 1;
    80004a2e:	4785                	li	a5,1
    80004a30:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a32:	0001d517          	auipc	a0,0x1d
    80004a36:	c2650513          	addi	a0,a0,-986 # 80021658 <ftable>
    80004a3a:	ffffc097          	auipc	ra,0xffffc
    80004a3e:	264080e7          	jalr	612(ra) # 80000c9e <release>
}
    80004a42:	8526                	mv	a0,s1
    80004a44:	60e2                	ld	ra,24(sp)
    80004a46:	6442                	ld	s0,16(sp)
    80004a48:	64a2                	ld	s1,8(sp)
    80004a4a:	6105                	addi	sp,sp,32
    80004a4c:	8082                	ret

0000000080004a4e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a4e:	1101                	addi	sp,sp,-32
    80004a50:	ec06                	sd	ra,24(sp)
    80004a52:	e822                	sd	s0,16(sp)
    80004a54:	e426                	sd	s1,8(sp)
    80004a56:	1000                	addi	s0,sp,32
    80004a58:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a5a:	0001d517          	auipc	a0,0x1d
    80004a5e:	bfe50513          	addi	a0,a0,-1026 # 80021658 <ftable>
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	188080e7          	jalr	392(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004a6a:	40dc                	lw	a5,4(s1)
    80004a6c:	02f05263          	blez	a5,80004a90 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a70:	2785                	addiw	a5,a5,1
    80004a72:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a74:	0001d517          	auipc	a0,0x1d
    80004a78:	be450513          	addi	a0,a0,-1052 # 80021658 <ftable>
    80004a7c:	ffffc097          	auipc	ra,0xffffc
    80004a80:	222080e7          	jalr	546(ra) # 80000c9e <release>
  return f;
}
    80004a84:	8526                	mv	a0,s1
    80004a86:	60e2                	ld	ra,24(sp)
    80004a88:	6442                	ld	s0,16(sp)
    80004a8a:	64a2                	ld	s1,8(sp)
    80004a8c:	6105                	addi	sp,sp,32
    80004a8e:	8082                	ret
    panic("filedup");
    80004a90:	00004517          	auipc	a0,0x4
    80004a94:	e1050513          	addi	a0,a0,-496 # 800088a0 <syscalls+0x270>
    80004a98:	ffffc097          	auipc	ra,0xffffc
    80004a9c:	aac080e7          	jalr	-1364(ra) # 80000544 <panic>

0000000080004aa0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004aa0:	7139                	addi	sp,sp,-64
    80004aa2:	fc06                	sd	ra,56(sp)
    80004aa4:	f822                	sd	s0,48(sp)
    80004aa6:	f426                	sd	s1,40(sp)
    80004aa8:	f04a                	sd	s2,32(sp)
    80004aaa:	ec4e                	sd	s3,24(sp)
    80004aac:	e852                	sd	s4,16(sp)
    80004aae:	e456                	sd	s5,8(sp)
    80004ab0:	0080                	addi	s0,sp,64
    80004ab2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ab4:	0001d517          	auipc	a0,0x1d
    80004ab8:	ba450513          	addi	a0,a0,-1116 # 80021658 <ftable>
    80004abc:	ffffc097          	auipc	ra,0xffffc
    80004ac0:	12e080e7          	jalr	302(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004ac4:	40dc                	lw	a5,4(s1)
    80004ac6:	06f05163          	blez	a5,80004b28 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004aca:	37fd                	addiw	a5,a5,-1
    80004acc:	0007871b          	sext.w	a4,a5
    80004ad0:	c0dc                	sw	a5,4(s1)
    80004ad2:	06e04363          	bgtz	a4,80004b38 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004ad6:	0004a903          	lw	s2,0(s1)
    80004ada:	0094ca83          	lbu	s5,9(s1)
    80004ade:	0104ba03          	ld	s4,16(s1)
    80004ae2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004ae6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004aea:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004aee:	0001d517          	auipc	a0,0x1d
    80004af2:	b6a50513          	addi	a0,a0,-1174 # 80021658 <ftable>
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	1a8080e7          	jalr	424(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004afe:	4785                	li	a5,1
    80004b00:	04f90d63          	beq	s2,a5,80004b5a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b04:	3979                	addiw	s2,s2,-2
    80004b06:	4785                	li	a5,1
    80004b08:	0527e063          	bltu	a5,s2,80004b48 <fileclose+0xa8>
    begin_op();
    80004b0c:	00000097          	auipc	ra,0x0
    80004b10:	ac8080e7          	jalr	-1336(ra) # 800045d4 <begin_op>
    iput(ff.ip);
    80004b14:	854e                	mv	a0,s3
    80004b16:	fffff097          	auipc	ra,0xfffff
    80004b1a:	2b6080e7          	jalr	694(ra) # 80003dcc <iput>
    end_op();
    80004b1e:	00000097          	auipc	ra,0x0
    80004b22:	b36080e7          	jalr	-1226(ra) # 80004654 <end_op>
    80004b26:	a00d                	j	80004b48 <fileclose+0xa8>
    panic("fileclose");
    80004b28:	00004517          	auipc	a0,0x4
    80004b2c:	d8050513          	addi	a0,a0,-640 # 800088a8 <syscalls+0x278>
    80004b30:	ffffc097          	auipc	ra,0xffffc
    80004b34:	a14080e7          	jalr	-1516(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004b38:	0001d517          	auipc	a0,0x1d
    80004b3c:	b2050513          	addi	a0,a0,-1248 # 80021658 <ftable>
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	15e080e7          	jalr	350(ra) # 80000c9e <release>
  }
}
    80004b48:	70e2                	ld	ra,56(sp)
    80004b4a:	7442                	ld	s0,48(sp)
    80004b4c:	74a2                	ld	s1,40(sp)
    80004b4e:	7902                	ld	s2,32(sp)
    80004b50:	69e2                	ld	s3,24(sp)
    80004b52:	6a42                	ld	s4,16(sp)
    80004b54:	6aa2                	ld	s5,8(sp)
    80004b56:	6121                	addi	sp,sp,64
    80004b58:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b5a:	85d6                	mv	a1,s5
    80004b5c:	8552                	mv	a0,s4
    80004b5e:	00000097          	auipc	ra,0x0
    80004b62:	34c080e7          	jalr	844(ra) # 80004eaa <pipeclose>
    80004b66:	b7cd                	j	80004b48 <fileclose+0xa8>

0000000080004b68 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b68:	715d                	addi	sp,sp,-80
    80004b6a:	e486                	sd	ra,72(sp)
    80004b6c:	e0a2                	sd	s0,64(sp)
    80004b6e:	fc26                	sd	s1,56(sp)
    80004b70:	f84a                	sd	s2,48(sp)
    80004b72:	f44e                	sd	s3,40(sp)
    80004b74:	0880                	addi	s0,sp,80
    80004b76:	84aa                	mv	s1,a0
    80004b78:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b7a:	ffffd097          	auipc	ra,0xffffd
    80004b7e:	e4c080e7          	jalr	-436(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b82:	409c                	lw	a5,0(s1)
    80004b84:	37f9                	addiw	a5,a5,-2
    80004b86:	4705                	li	a4,1
    80004b88:	04f76763          	bltu	a4,a5,80004bd6 <filestat+0x6e>
    80004b8c:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b8e:	6c88                	ld	a0,24(s1)
    80004b90:	fffff097          	auipc	ra,0xfffff
    80004b94:	082080e7          	jalr	130(ra) # 80003c12 <ilock>
    stati(f->ip, &st);
    80004b98:	fb840593          	addi	a1,s0,-72
    80004b9c:	6c88                	ld	a0,24(s1)
    80004b9e:	fffff097          	auipc	ra,0xfffff
    80004ba2:	2fe080e7          	jalr	766(ra) # 80003e9c <stati>
    iunlock(f->ip);
    80004ba6:	6c88                	ld	a0,24(s1)
    80004ba8:	fffff097          	auipc	ra,0xfffff
    80004bac:	12c080e7          	jalr	300(ra) # 80003cd4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004bb0:	46e1                	li	a3,24
    80004bb2:	fb840613          	addi	a2,s0,-72
    80004bb6:	85ce                	mv	a1,s3
    80004bb8:	05093503          	ld	a0,80(s2)
    80004bbc:	ffffd097          	auipc	ra,0xffffd
    80004bc0:	ac8080e7          	jalr	-1336(ra) # 80001684 <copyout>
    80004bc4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004bc8:	60a6                	ld	ra,72(sp)
    80004bca:	6406                	ld	s0,64(sp)
    80004bcc:	74e2                	ld	s1,56(sp)
    80004bce:	7942                	ld	s2,48(sp)
    80004bd0:	79a2                	ld	s3,40(sp)
    80004bd2:	6161                	addi	sp,sp,80
    80004bd4:	8082                	ret
  return -1;
    80004bd6:	557d                	li	a0,-1
    80004bd8:	bfc5                	j	80004bc8 <filestat+0x60>

0000000080004bda <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004bda:	7179                	addi	sp,sp,-48
    80004bdc:	f406                	sd	ra,40(sp)
    80004bde:	f022                	sd	s0,32(sp)
    80004be0:	ec26                	sd	s1,24(sp)
    80004be2:	e84a                	sd	s2,16(sp)
    80004be4:	e44e                	sd	s3,8(sp)
    80004be6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004be8:	00854783          	lbu	a5,8(a0)
    80004bec:	c3d5                	beqz	a5,80004c90 <fileread+0xb6>
    80004bee:	84aa                	mv	s1,a0
    80004bf0:	89ae                	mv	s3,a1
    80004bf2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bf4:	411c                	lw	a5,0(a0)
    80004bf6:	4705                	li	a4,1
    80004bf8:	04e78963          	beq	a5,a4,80004c4a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bfc:	470d                	li	a4,3
    80004bfe:	04e78d63          	beq	a5,a4,80004c58 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c02:	4709                	li	a4,2
    80004c04:	06e79e63          	bne	a5,a4,80004c80 <fileread+0xa6>
    ilock(f->ip);
    80004c08:	6d08                	ld	a0,24(a0)
    80004c0a:	fffff097          	auipc	ra,0xfffff
    80004c0e:	008080e7          	jalr	8(ra) # 80003c12 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c12:	874a                	mv	a4,s2
    80004c14:	5094                	lw	a3,32(s1)
    80004c16:	864e                	mv	a2,s3
    80004c18:	4585                	li	a1,1
    80004c1a:	6c88                	ld	a0,24(s1)
    80004c1c:	fffff097          	auipc	ra,0xfffff
    80004c20:	2aa080e7          	jalr	682(ra) # 80003ec6 <readi>
    80004c24:	892a                	mv	s2,a0
    80004c26:	00a05563          	blez	a0,80004c30 <fileread+0x56>
      f->off += r;
    80004c2a:	509c                	lw	a5,32(s1)
    80004c2c:	9fa9                	addw	a5,a5,a0
    80004c2e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c30:	6c88                	ld	a0,24(s1)
    80004c32:	fffff097          	auipc	ra,0xfffff
    80004c36:	0a2080e7          	jalr	162(ra) # 80003cd4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c3a:	854a                	mv	a0,s2
    80004c3c:	70a2                	ld	ra,40(sp)
    80004c3e:	7402                	ld	s0,32(sp)
    80004c40:	64e2                	ld	s1,24(sp)
    80004c42:	6942                	ld	s2,16(sp)
    80004c44:	69a2                	ld	s3,8(sp)
    80004c46:	6145                	addi	sp,sp,48
    80004c48:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c4a:	6908                	ld	a0,16(a0)
    80004c4c:	00000097          	auipc	ra,0x0
    80004c50:	3ce080e7          	jalr	974(ra) # 8000501a <piperead>
    80004c54:	892a                	mv	s2,a0
    80004c56:	b7d5                	j	80004c3a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c58:	02451783          	lh	a5,36(a0)
    80004c5c:	03079693          	slli	a3,a5,0x30
    80004c60:	92c1                	srli	a3,a3,0x30
    80004c62:	4725                	li	a4,9
    80004c64:	02d76863          	bltu	a4,a3,80004c94 <fileread+0xba>
    80004c68:	0792                	slli	a5,a5,0x4
    80004c6a:	0001d717          	auipc	a4,0x1d
    80004c6e:	94e70713          	addi	a4,a4,-1714 # 800215b8 <devsw>
    80004c72:	97ba                	add	a5,a5,a4
    80004c74:	639c                	ld	a5,0(a5)
    80004c76:	c38d                	beqz	a5,80004c98 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c78:	4505                	li	a0,1
    80004c7a:	9782                	jalr	a5
    80004c7c:	892a                	mv	s2,a0
    80004c7e:	bf75                	j	80004c3a <fileread+0x60>
    panic("fileread");
    80004c80:	00004517          	auipc	a0,0x4
    80004c84:	c3850513          	addi	a0,a0,-968 # 800088b8 <syscalls+0x288>
    80004c88:	ffffc097          	auipc	ra,0xffffc
    80004c8c:	8bc080e7          	jalr	-1860(ra) # 80000544 <panic>
    return -1;
    80004c90:	597d                	li	s2,-1
    80004c92:	b765                	j	80004c3a <fileread+0x60>
      return -1;
    80004c94:	597d                	li	s2,-1
    80004c96:	b755                	j	80004c3a <fileread+0x60>
    80004c98:	597d                	li	s2,-1
    80004c9a:	b745                	j	80004c3a <fileread+0x60>

0000000080004c9c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c9c:	715d                	addi	sp,sp,-80
    80004c9e:	e486                	sd	ra,72(sp)
    80004ca0:	e0a2                	sd	s0,64(sp)
    80004ca2:	fc26                	sd	s1,56(sp)
    80004ca4:	f84a                	sd	s2,48(sp)
    80004ca6:	f44e                	sd	s3,40(sp)
    80004ca8:	f052                	sd	s4,32(sp)
    80004caa:	ec56                	sd	s5,24(sp)
    80004cac:	e85a                	sd	s6,16(sp)
    80004cae:	e45e                	sd	s7,8(sp)
    80004cb0:	e062                	sd	s8,0(sp)
    80004cb2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004cb4:	00954783          	lbu	a5,9(a0)
    80004cb8:	10078663          	beqz	a5,80004dc4 <filewrite+0x128>
    80004cbc:	892a                	mv	s2,a0
    80004cbe:	8aae                	mv	s5,a1
    80004cc0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cc2:	411c                	lw	a5,0(a0)
    80004cc4:	4705                	li	a4,1
    80004cc6:	02e78263          	beq	a5,a4,80004cea <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cca:	470d                	li	a4,3
    80004ccc:	02e78663          	beq	a5,a4,80004cf8 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cd0:	4709                	li	a4,2
    80004cd2:	0ee79163          	bne	a5,a4,80004db4 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cd6:	0ac05d63          	blez	a2,80004d90 <filewrite+0xf4>
    int i = 0;
    80004cda:	4981                	li	s3,0
    80004cdc:	6b05                	lui	s6,0x1
    80004cde:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004ce2:	6b85                	lui	s7,0x1
    80004ce4:	c00b8b9b          	addiw	s7,s7,-1024
    80004ce8:	a861                	j	80004d80 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004cea:	6908                	ld	a0,16(a0)
    80004cec:	00000097          	auipc	ra,0x0
    80004cf0:	22e080e7          	jalr	558(ra) # 80004f1a <pipewrite>
    80004cf4:	8a2a                	mv	s4,a0
    80004cf6:	a045                	j	80004d96 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cf8:	02451783          	lh	a5,36(a0)
    80004cfc:	03079693          	slli	a3,a5,0x30
    80004d00:	92c1                	srli	a3,a3,0x30
    80004d02:	4725                	li	a4,9
    80004d04:	0cd76263          	bltu	a4,a3,80004dc8 <filewrite+0x12c>
    80004d08:	0792                	slli	a5,a5,0x4
    80004d0a:	0001d717          	auipc	a4,0x1d
    80004d0e:	8ae70713          	addi	a4,a4,-1874 # 800215b8 <devsw>
    80004d12:	97ba                	add	a5,a5,a4
    80004d14:	679c                	ld	a5,8(a5)
    80004d16:	cbdd                	beqz	a5,80004dcc <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d18:	4505                	li	a0,1
    80004d1a:	9782                	jalr	a5
    80004d1c:	8a2a                	mv	s4,a0
    80004d1e:	a8a5                	j	80004d96 <filewrite+0xfa>
    80004d20:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d24:	00000097          	auipc	ra,0x0
    80004d28:	8b0080e7          	jalr	-1872(ra) # 800045d4 <begin_op>
      ilock(f->ip);
    80004d2c:	01893503          	ld	a0,24(s2)
    80004d30:	fffff097          	auipc	ra,0xfffff
    80004d34:	ee2080e7          	jalr	-286(ra) # 80003c12 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d38:	8762                	mv	a4,s8
    80004d3a:	02092683          	lw	a3,32(s2)
    80004d3e:	01598633          	add	a2,s3,s5
    80004d42:	4585                	li	a1,1
    80004d44:	01893503          	ld	a0,24(s2)
    80004d48:	fffff097          	auipc	ra,0xfffff
    80004d4c:	276080e7          	jalr	630(ra) # 80003fbe <writei>
    80004d50:	84aa                	mv	s1,a0
    80004d52:	00a05763          	blez	a0,80004d60 <filewrite+0xc4>
        f->off += r;
    80004d56:	02092783          	lw	a5,32(s2)
    80004d5a:	9fa9                	addw	a5,a5,a0
    80004d5c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d60:	01893503          	ld	a0,24(s2)
    80004d64:	fffff097          	auipc	ra,0xfffff
    80004d68:	f70080e7          	jalr	-144(ra) # 80003cd4 <iunlock>
      end_op();
    80004d6c:	00000097          	auipc	ra,0x0
    80004d70:	8e8080e7          	jalr	-1816(ra) # 80004654 <end_op>

      if(r != n1){
    80004d74:	009c1f63          	bne	s8,s1,80004d92 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d78:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d7c:	0149db63          	bge	s3,s4,80004d92 <filewrite+0xf6>
      int n1 = n - i;
    80004d80:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004d84:	84be                	mv	s1,a5
    80004d86:	2781                	sext.w	a5,a5
    80004d88:	f8fb5ce3          	bge	s6,a5,80004d20 <filewrite+0x84>
    80004d8c:	84de                	mv	s1,s7
    80004d8e:	bf49                	j	80004d20 <filewrite+0x84>
    int i = 0;
    80004d90:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d92:	013a1f63          	bne	s4,s3,80004db0 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d96:	8552                	mv	a0,s4
    80004d98:	60a6                	ld	ra,72(sp)
    80004d9a:	6406                	ld	s0,64(sp)
    80004d9c:	74e2                	ld	s1,56(sp)
    80004d9e:	7942                	ld	s2,48(sp)
    80004da0:	79a2                	ld	s3,40(sp)
    80004da2:	7a02                	ld	s4,32(sp)
    80004da4:	6ae2                	ld	s5,24(sp)
    80004da6:	6b42                	ld	s6,16(sp)
    80004da8:	6ba2                	ld	s7,8(sp)
    80004daa:	6c02                	ld	s8,0(sp)
    80004dac:	6161                	addi	sp,sp,80
    80004dae:	8082                	ret
    ret = (i == n ? n : -1);
    80004db0:	5a7d                	li	s4,-1
    80004db2:	b7d5                	j	80004d96 <filewrite+0xfa>
    panic("filewrite");
    80004db4:	00004517          	auipc	a0,0x4
    80004db8:	b1450513          	addi	a0,a0,-1260 # 800088c8 <syscalls+0x298>
    80004dbc:	ffffb097          	auipc	ra,0xffffb
    80004dc0:	788080e7          	jalr	1928(ra) # 80000544 <panic>
    return -1;
    80004dc4:	5a7d                	li	s4,-1
    80004dc6:	bfc1                	j	80004d96 <filewrite+0xfa>
      return -1;
    80004dc8:	5a7d                	li	s4,-1
    80004dca:	b7f1                	j	80004d96 <filewrite+0xfa>
    80004dcc:	5a7d                	li	s4,-1
    80004dce:	b7e1                	j	80004d96 <filewrite+0xfa>

0000000080004dd0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004dd0:	7179                	addi	sp,sp,-48
    80004dd2:	f406                	sd	ra,40(sp)
    80004dd4:	f022                	sd	s0,32(sp)
    80004dd6:	ec26                	sd	s1,24(sp)
    80004dd8:	e84a                	sd	s2,16(sp)
    80004dda:	e44e                	sd	s3,8(sp)
    80004ddc:	e052                	sd	s4,0(sp)
    80004dde:	1800                	addi	s0,sp,48
    80004de0:	84aa                	mv	s1,a0
    80004de2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004de4:	0005b023          	sd	zero,0(a1)
    80004de8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004dec:	00000097          	auipc	ra,0x0
    80004df0:	bf8080e7          	jalr	-1032(ra) # 800049e4 <filealloc>
    80004df4:	e088                	sd	a0,0(s1)
    80004df6:	c551                	beqz	a0,80004e82 <pipealloc+0xb2>
    80004df8:	00000097          	auipc	ra,0x0
    80004dfc:	bec080e7          	jalr	-1044(ra) # 800049e4 <filealloc>
    80004e00:	00aa3023          	sd	a0,0(s4)
    80004e04:	c92d                	beqz	a0,80004e76 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e06:	ffffc097          	auipc	ra,0xffffc
    80004e0a:	cf4080e7          	jalr	-780(ra) # 80000afa <kalloc>
    80004e0e:	892a                	mv	s2,a0
    80004e10:	c125                	beqz	a0,80004e70 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e12:	4985                	li	s3,1
    80004e14:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e18:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e1c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e20:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e24:	00004597          	auipc	a1,0x4
    80004e28:	ab458593          	addi	a1,a1,-1356 # 800088d8 <syscalls+0x2a8>
    80004e2c:	ffffc097          	auipc	ra,0xffffc
    80004e30:	d2e080e7          	jalr	-722(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004e34:	609c                	ld	a5,0(s1)
    80004e36:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e3a:	609c                	ld	a5,0(s1)
    80004e3c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e40:	609c                	ld	a5,0(s1)
    80004e42:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e46:	609c                	ld	a5,0(s1)
    80004e48:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e4c:	000a3783          	ld	a5,0(s4)
    80004e50:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e54:	000a3783          	ld	a5,0(s4)
    80004e58:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e5c:	000a3783          	ld	a5,0(s4)
    80004e60:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e64:	000a3783          	ld	a5,0(s4)
    80004e68:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e6c:	4501                	li	a0,0
    80004e6e:	a025                	j	80004e96 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e70:	6088                	ld	a0,0(s1)
    80004e72:	e501                	bnez	a0,80004e7a <pipealloc+0xaa>
    80004e74:	a039                	j	80004e82 <pipealloc+0xb2>
    80004e76:	6088                	ld	a0,0(s1)
    80004e78:	c51d                	beqz	a0,80004ea6 <pipealloc+0xd6>
    fileclose(*f0);
    80004e7a:	00000097          	auipc	ra,0x0
    80004e7e:	c26080e7          	jalr	-986(ra) # 80004aa0 <fileclose>
  if(*f1)
    80004e82:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e86:	557d                	li	a0,-1
  if(*f1)
    80004e88:	c799                	beqz	a5,80004e96 <pipealloc+0xc6>
    fileclose(*f1);
    80004e8a:	853e                	mv	a0,a5
    80004e8c:	00000097          	auipc	ra,0x0
    80004e90:	c14080e7          	jalr	-1004(ra) # 80004aa0 <fileclose>
  return -1;
    80004e94:	557d                	li	a0,-1
}
    80004e96:	70a2                	ld	ra,40(sp)
    80004e98:	7402                	ld	s0,32(sp)
    80004e9a:	64e2                	ld	s1,24(sp)
    80004e9c:	6942                	ld	s2,16(sp)
    80004e9e:	69a2                	ld	s3,8(sp)
    80004ea0:	6a02                	ld	s4,0(sp)
    80004ea2:	6145                	addi	sp,sp,48
    80004ea4:	8082                	ret
  return -1;
    80004ea6:	557d                	li	a0,-1
    80004ea8:	b7fd                	j	80004e96 <pipealloc+0xc6>

0000000080004eaa <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004eaa:	1101                	addi	sp,sp,-32
    80004eac:	ec06                	sd	ra,24(sp)
    80004eae:	e822                	sd	s0,16(sp)
    80004eb0:	e426                	sd	s1,8(sp)
    80004eb2:	e04a                	sd	s2,0(sp)
    80004eb4:	1000                	addi	s0,sp,32
    80004eb6:	84aa                	mv	s1,a0
    80004eb8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004eba:	ffffc097          	auipc	ra,0xffffc
    80004ebe:	d30080e7          	jalr	-720(ra) # 80000bea <acquire>
  if(writable){
    80004ec2:	02090d63          	beqz	s2,80004efc <pipeclose+0x52>
    pi->writeopen = 0;
    80004ec6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004eca:	21848513          	addi	a0,s1,536
    80004ece:	ffffd097          	auipc	ra,0xffffd
    80004ed2:	200080e7          	jalr	512(ra) # 800020ce <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ed6:	2204b783          	ld	a5,544(s1)
    80004eda:	eb95                	bnez	a5,80004f0e <pipeclose+0x64>
    release(&pi->lock);
    80004edc:	8526                	mv	a0,s1
    80004ede:	ffffc097          	auipc	ra,0xffffc
    80004ee2:	dc0080e7          	jalr	-576(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004ee6:	8526                	mv	a0,s1
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	b16080e7          	jalr	-1258(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004ef0:	60e2                	ld	ra,24(sp)
    80004ef2:	6442                	ld	s0,16(sp)
    80004ef4:	64a2                	ld	s1,8(sp)
    80004ef6:	6902                	ld	s2,0(sp)
    80004ef8:	6105                	addi	sp,sp,32
    80004efa:	8082                	ret
    pi->readopen = 0;
    80004efc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f00:	21c48513          	addi	a0,s1,540
    80004f04:	ffffd097          	auipc	ra,0xffffd
    80004f08:	1ca080e7          	jalr	458(ra) # 800020ce <wakeup>
    80004f0c:	b7e9                	j	80004ed6 <pipeclose+0x2c>
    release(&pi->lock);
    80004f0e:	8526                	mv	a0,s1
    80004f10:	ffffc097          	auipc	ra,0xffffc
    80004f14:	d8e080e7          	jalr	-626(ra) # 80000c9e <release>
}
    80004f18:	bfe1                	j	80004ef0 <pipeclose+0x46>

0000000080004f1a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f1a:	7159                	addi	sp,sp,-112
    80004f1c:	f486                	sd	ra,104(sp)
    80004f1e:	f0a2                	sd	s0,96(sp)
    80004f20:	eca6                	sd	s1,88(sp)
    80004f22:	e8ca                	sd	s2,80(sp)
    80004f24:	e4ce                	sd	s3,72(sp)
    80004f26:	e0d2                	sd	s4,64(sp)
    80004f28:	fc56                	sd	s5,56(sp)
    80004f2a:	f85a                	sd	s6,48(sp)
    80004f2c:	f45e                	sd	s7,40(sp)
    80004f2e:	f062                	sd	s8,32(sp)
    80004f30:	ec66                	sd	s9,24(sp)
    80004f32:	1880                	addi	s0,sp,112
    80004f34:	84aa                	mv	s1,a0
    80004f36:	8aae                	mv	s5,a1
    80004f38:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f3a:	ffffd097          	auipc	ra,0xffffd
    80004f3e:	a8c080e7          	jalr	-1396(ra) # 800019c6 <myproc>
    80004f42:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f44:	8526                	mv	a0,s1
    80004f46:	ffffc097          	auipc	ra,0xffffc
    80004f4a:	ca4080e7          	jalr	-860(ra) # 80000bea <acquire>
  while(i < n){
    80004f4e:	0d405463          	blez	s4,80005016 <pipewrite+0xfc>
    80004f52:	8ba6                	mv	s7,s1
  int i = 0;
    80004f54:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f56:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f58:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f5c:	21c48c13          	addi	s8,s1,540
    80004f60:	a08d                	j	80004fc2 <pipewrite+0xa8>
      release(&pi->lock);
    80004f62:	8526                	mv	a0,s1
    80004f64:	ffffc097          	auipc	ra,0xffffc
    80004f68:	d3a080e7          	jalr	-710(ra) # 80000c9e <release>
      return -1;
    80004f6c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f6e:	854a                	mv	a0,s2
    80004f70:	70a6                	ld	ra,104(sp)
    80004f72:	7406                	ld	s0,96(sp)
    80004f74:	64e6                	ld	s1,88(sp)
    80004f76:	6946                	ld	s2,80(sp)
    80004f78:	69a6                	ld	s3,72(sp)
    80004f7a:	6a06                	ld	s4,64(sp)
    80004f7c:	7ae2                	ld	s5,56(sp)
    80004f7e:	7b42                	ld	s6,48(sp)
    80004f80:	7ba2                	ld	s7,40(sp)
    80004f82:	7c02                	ld	s8,32(sp)
    80004f84:	6ce2                	ld	s9,24(sp)
    80004f86:	6165                	addi	sp,sp,112
    80004f88:	8082                	ret
      wakeup(&pi->nread);
    80004f8a:	8566                	mv	a0,s9
    80004f8c:	ffffd097          	auipc	ra,0xffffd
    80004f90:	142080e7          	jalr	322(ra) # 800020ce <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f94:	85de                	mv	a1,s7
    80004f96:	8562                	mv	a0,s8
    80004f98:	ffffd097          	auipc	ra,0xffffd
    80004f9c:	0d2080e7          	jalr	210(ra) # 8000206a <sleep>
    80004fa0:	a839                	j	80004fbe <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fa2:	21c4a783          	lw	a5,540(s1)
    80004fa6:	0017871b          	addiw	a4,a5,1
    80004faa:	20e4ae23          	sw	a4,540(s1)
    80004fae:	1ff7f793          	andi	a5,a5,511
    80004fb2:	97a6                	add	a5,a5,s1
    80004fb4:	f9f44703          	lbu	a4,-97(s0)
    80004fb8:	00e78c23          	sb	a4,24(a5)
      i++;
    80004fbc:	2905                	addiw	s2,s2,1
  while(i < n){
    80004fbe:	05495063          	bge	s2,s4,80004ffe <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004fc2:	2204a783          	lw	a5,544(s1)
    80004fc6:	dfd1                	beqz	a5,80004f62 <pipewrite+0x48>
    80004fc8:	854e                	mv	a0,s3
    80004fca:	ffffd097          	auipc	ra,0xffffd
    80004fce:	3c2080e7          	jalr	962(ra) # 8000238c <killed>
    80004fd2:	f941                	bnez	a0,80004f62 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004fd4:	2184a783          	lw	a5,536(s1)
    80004fd8:	21c4a703          	lw	a4,540(s1)
    80004fdc:	2007879b          	addiw	a5,a5,512
    80004fe0:	faf705e3          	beq	a4,a5,80004f8a <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fe4:	4685                	li	a3,1
    80004fe6:	01590633          	add	a2,s2,s5
    80004fea:	f9f40593          	addi	a1,s0,-97
    80004fee:	0509b503          	ld	a0,80(s3)
    80004ff2:	ffffc097          	auipc	ra,0xffffc
    80004ff6:	71e080e7          	jalr	1822(ra) # 80001710 <copyin>
    80004ffa:	fb6514e3          	bne	a0,s6,80004fa2 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004ffe:	21848513          	addi	a0,s1,536
    80005002:	ffffd097          	auipc	ra,0xffffd
    80005006:	0cc080e7          	jalr	204(ra) # 800020ce <wakeup>
  release(&pi->lock);
    8000500a:	8526                	mv	a0,s1
    8000500c:	ffffc097          	auipc	ra,0xffffc
    80005010:	c92080e7          	jalr	-878(ra) # 80000c9e <release>
  return i;
    80005014:	bfa9                	j	80004f6e <pipewrite+0x54>
  int i = 0;
    80005016:	4901                	li	s2,0
    80005018:	b7dd                	j	80004ffe <pipewrite+0xe4>

000000008000501a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000501a:	715d                	addi	sp,sp,-80
    8000501c:	e486                	sd	ra,72(sp)
    8000501e:	e0a2                	sd	s0,64(sp)
    80005020:	fc26                	sd	s1,56(sp)
    80005022:	f84a                	sd	s2,48(sp)
    80005024:	f44e                	sd	s3,40(sp)
    80005026:	f052                	sd	s4,32(sp)
    80005028:	ec56                	sd	s5,24(sp)
    8000502a:	e85a                	sd	s6,16(sp)
    8000502c:	0880                	addi	s0,sp,80
    8000502e:	84aa                	mv	s1,a0
    80005030:	892e                	mv	s2,a1
    80005032:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005034:	ffffd097          	auipc	ra,0xffffd
    80005038:	992080e7          	jalr	-1646(ra) # 800019c6 <myproc>
    8000503c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000503e:	8b26                	mv	s6,s1
    80005040:	8526                	mv	a0,s1
    80005042:	ffffc097          	auipc	ra,0xffffc
    80005046:	ba8080e7          	jalr	-1112(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000504a:	2184a703          	lw	a4,536(s1)
    8000504e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005052:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005056:	02f71763          	bne	a4,a5,80005084 <piperead+0x6a>
    8000505a:	2244a783          	lw	a5,548(s1)
    8000505e:	c39d                	beqz	a5,80005084 <piperead+0x6a>
    if(killed(pr)){
    80005060:	8552                	mv	a0,s4
    80005062:	ffffd097          	auipc	ra,0xffffd
    80005066:	32a080e7          	jalr	810(ra) # 8000238c <killed>
    8000506a:	e941                	bnez	a0,800050fa <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000506c:	85da                	mv	a1,s6
    8000506e:	854e                	mv	a0,s3
    80005070:	ffffd097          	auipc	ra,0xffffd
    80005074:	ffa080e7          	jalr	-6(ra) # 8000206a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005078:	2184a703          	lw	a4,536(s1)
    8000507c:	21c4a783          	lw	a5,540(s1)
    80005080:	fcf70de3          	beq	a4,a5,8000505a <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005084:	09505263          	blez	s5,80005108 <piperead+0xee>
    80005088:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000508a:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000508c:	2184a783          	lw	a5,536(s1)
    80005090:	21c4a703          	lw	a4,540(s1)
    80005094:	02f70d63          	beq	a4,a5,800050ce <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005098:	0017871b          	addiw	a4,a5,1
    8000509c:	20e4ac23          	sw	a4,536(s1)
    800050a0:	1ff7f793          	andi	a5,a5,511
    800050a4:	97a6                	add	a5,a5,s1
    800050a6:	0187c783          	lbu	a5,24(a5)
    800050aa:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050ae:	4685                	li	a3,1
    800050b0:	fbf40613          	addi	a2,s0,-65
    800050b4:	85ca                	mv	a1,s2
    800050b6:	050a3503          	ld	a0,80(s4)
    800050ba:	ffffc097          	auipc	ra,0xffffc
    800050be:	5ca080e7          	jalr	1482(ra) # 80001684 <copyout>
    800050c2:	01650663          	beq	a0,s6,800050ce <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050c6:	2985                	addiw	s3,s3,1
    800050c8:	0905                	addi	s2,s2,1
    800050ca:	fd3a91e3          	bne	s5,s3,8000508c <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050ce:	21c48513          	addi	a0,s1,540
    800050d2:	ffffd097          	auipc	ra,0xffffd
    800050d6:	ffc080e7          	jalr	-4(ra) # 800020ce <wakeup>
  release(&pi->lock);
    800050da:	8526                	mv	a0,s1
    800050dc:	ffffc097          	auipc	ra,0xffffc
    800050e0:	bc2080e7          	jalr	-1086(ra) # 80000c9e <release>
  return i;
}
    800050e4:	854e                	mv	a0,s3
    800050e6:	60a6                	ld	ra,72(sp)
    800050e8:	6406                	ld	s0,64(sp)
    800050ea:	74e2                	ld	s1,56(sp)
    800050ec:	7942                	ld	s2,48(sp)
    800050ee:	79a2                	ld	s3,40(sp)
    800050f0:	7a02                	ld	s4,32(sp)
    800050f2:	6ae2                	ld	s5,24(sp)
    800050f4:	6b42                	ld	s6,16(sp)
    800050f6:	6161                	addi	sp,sp,80
    800050f8:	8082                	ret
      release(&pi->lock);
    800050fa:	8526                	mv	a0,s1
    800050fc:	ffffc097          	auipc	ra,0xffffc
    80005100:	ba2080e7          	jalr	-1118(ra) # 80000c9e <release>
      return -1;
    80005104:	59fd                	li	s3,-1
    80005106:	bff9                	j	800050e4 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005108:	4981                	li	s3,0
    8000510a:	b7d1                	j	800050ce <piperead+0xb4>

000000008000510c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000510c:	1141                	addi	sp,sp,-16
    8000510e:	e422                	sd	s0,8(sp)
    80005110:	0800                	addi	s0,sp,16
    80005112:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005114:	8905                	andi	a0,a0,1
    80005116:	c111                	beqz	a0,8000511a <flags2perm+0xe>
      perm = PTE_X;
    80005118:	4521                	li	a0,8
    if(flags & 0x2)
    8000511a:	8b89                	andi	a5,a5,2
    8000511c:	c399                	beqz	a5,80005122 <flags2perm+0x16>
      perm |= PTE_W;
    8000511e:	00456513          	ori	a0,a0,4
    return perm;
}
    80005122:	6422                	ld	s0,8(sp)
    80005124:	0141                	addi	sp,sp,16
    80005126:	8082                	ret

0000000080005128 <exec>:

int
exec(char *path, char **argv)
{
    80005128:	df010113          	addi	sp,sp,-528
    8000512c:	20113423          	sd	ra,520(sp)
    80005130:	20813023          	sd	s0,512(sp)
    80005134:	ffa6                	sd	s1,504(sp)
    80005136:	fbca                	sd	s2,496(sp)
    80005138:	f7ce                	sd	s3,488(sp)
    8000513a:	f3d2                	sd	s4,480(sp)
    8000513c:	efd6                	sd	s5,472(sp)
    8000513e:	ebda                	sd	s6,464(sp)
    80005140:	e7de                	sd	s7,456(sp)
    80005142:	e3e2                	sd	s8,448(sp)
    80005144:	ff66                	sd	s9,440(sp)
    80005146:	fb6a                	sd	s10,432(sp)
    80005148:	f76e                	sd	s11,424(sp)
    8000514a:	0c00                	addi	s0,sp,528
    8000514c:	84aa                	mv	s1,a0
    8000514e:	dea43c23          	sd	a0,-520(s0)
    80005152:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005156:	ffffd097          	auipc	ra,0xffffd
    8000515a:	870080e7          	jalr	-1936(ra) # 800019c6 <myproc>
    8000515e:	892a                	mv	s2,a0

  begin_op();
    80005160:	fffff097          	auipc	ra,0xfffff
    80005164:	474080e7          	jalr	1140(ra) # 800045d4 <begin_op>

  if((ip = namei(path)) == 0){
    80005168:	8526                	mv	a0,s1
    8000516a:	fffff097          	auipc	ra,0xfffff
    8000516e:	24e080e7          	jalr	590(ra) # 800043b8 <namei>
    80005172:	c92d                	beqz	a0,800051e4 <exec+0xbc>
    80005174:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005176:	fffff097          	auipc	ra,0xfffff
    8000517a:	a9c080e7          	jalr	-1380(ra) # 80003c12 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000517e:	04000713          	li	a4,64
    80005182:	4681                	li	a3,0
    80005184:	e5040613          	addi	a2,s0,-432
    80005188:	4581                	li	a1,0
    8000518a:	8526                	mv	a0,s1
    8000518c:	fffff097          	auipc	ra,0xfffff
    80005190:	d3a080e7          	jalr	-710(ra) # 80003ec6 <readi>
    80005194:	04000793          	li	a5,64
    80005198:	00f51a63          	bne	a0,a5,800051ac <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000519c:	e5042703          	lw	a4,-432(s0)
    800051a0:	464c47b7          	lui	a5,0x464c4
    800051a4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051a8:	04f70463          	beq	a4,a5,800051f0 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051ac:	8526                	mv	a0,s1
    800051ae:	fffff097          	auipc	ra,0xfffff
    800051b2:	cc6080e7          	jalr	-826(ra) # 80003e74 <iunlockput>
    end_op();
    800051b6:	fffff097          	auipc	ra,0xfffff
    800051ba:	49e080e7          	jalr	1182(ra) # 80004654 <end_op>
  }
  return -1;
    800051be:	557d                	li	a0,-1
}
    800051c0:	20813083          	ld	ra,520(sp)
    800051c4:	20013403          	ld	s0,512(sp)
    800051c8:	74fe                	ld	s1,504(sp)
    800051ca:	795e                	ld	s2,496(sp)
    800051cc:	79be                	ld	s3,488(sp)
    800051ce:	7a1e                	ld	s4,480(sp)
    800051d0:	6afe                	ld	s5,472(sp)
    800051d2:	6b5e                	ld	s6,464(sp)
    800051d4:	6bbe                	ld	s7,456(sp)
    800051d6:	6c1e                	ld	s8,448(sp)
    800051d8:	7cfa                	ld	s9,440(sp)
    800051da:	7d5a                	ld	s10,432(sp)
    800051dc:	7dba                	ld	s11,424(sp)
    800051de:	21010113          	addi	sp,sp,528
    800051e2:	8082                	ret
    end_op();
    800051e4:	fffff097          	auipc	ra,0xfffff
    800051e8:	470080e7          	jalr	1136(ra) # 80004654 <end_op>
    return -1;
    800051ec:	557d                	li	a0,-1
    800051ee:	bfc9                	j	800051c0 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800051f0:	854a                	mv	a0,s2
    800051f2:	ffffd097          	auipc	ra,0xffffd
    800051f6:	898080e7          	jalr	-1896(ra) # 80001a8a <proc_pagetable>
    800051fa:	8baa                	mv	s7,a0
    800051fc:	d945                	beqz	a0,800051ac <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051fe:	e7042983          	lw	s3,-400(s0)
    80005202:	e8845783          	lhu	a5,-376(s0)
    80005206:	c7ad                	beqz	a5,80005270 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005208:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000520a:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    8000520c:	6c85                	lui	s9,0x1
    8000520e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005212:	def43823          	sd	a5,-528(s0)
    80005216:	ac0d                	j	80005448 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005218:	00003517          	auipc	a0,0x3
    8000521c:	6c850513          	addi	a0,a0,1736 # 800088e0 <syscalls+0x2b0>
    80005220:	ffffb097          	auipc	ra,0xffffb
    80005224:	324080e7          	jalr	804(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005228:	8756                	mv	a4,s5
    8000522a:	012d86bb          	addw	a3,s11,s2
    8000522e:	4581                	li	a1,0
    80005230:	8526                	mv	a0,s1
    80005232:	fffff097          	auipc	ra,0xfffff
    80005236:	c94080e7          	jalr	-876(ra) # 80003ec6 <readi>
    8000523a:	2501                	sext.w	a0,a0
    8000523c:	1aaa9a63          	bne	s5,a0,800053f0 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005240:	6785                	lui	a5,0x1
    80005242:	0127893b          	addw	s2,a5,s2
    80005246:	77fd                	lui	a5,0xfffff
    80005248:	01478a3b          	addw	s4,a5,s4
    8000524c:	1f897563          	bgeu	s2,s8,80005436 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005250:	02091593          	slli	a1,s2,0x20
    80005254:	9181                	srli	a1,a1,0x20
    80005256:	95ea                	add	a1,a1,s10
    80005258:	855e                	mv	a0,s7
    8000525a:	ffffc097          	auipc	ra,0xffffc
    8000525e:	e1e080e7          	jalr	-482(ra) # 80001078 <walkaddr>
    80005262:	862a                	mv	a2,a0
    if(pa == 0)
    80005264:	d955                	beqz	a0,80005218 <exec+0xf0>
      n = PGSIZE;
    80005266:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005268:	fd9a70e3          	bgeu	s4,s9,80005228 <exec+0x100>
      n = sz - i;
    8000526c:	8ad2                	mv	s5,s4
    8000526e:	bf6d                	j	80005228 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005270:	4a01                	li	s4,0
  iunlockput(ip);
    80005272:	8526                	mv	a0,s1
    80005274:	fffff097          	auipc	ra,0xfffff
    80005278:	c00080e7          	jalr	-1024(ra) # 80003e74 <iunlockput>
  end_op();
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	3d8080e7          	jalr	984(ra) # 80004654 <end_op>
  p = myproc();
    80005284:	ffffc097          	auipc	ra,0xffffc
    80005288:	742080e7          	jalr	1858(ra) # 800019c6 <myproc>
    8000528c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000528e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005292:	6785                	lui	a5,0x1
    80005294:	17fd                	addi	a5,a5,-1
    80005296:	9a3e                	add	s4,s4,a5
    80005298:	757d                	lui	a0,0xfffff
    8000529a:	00aa77b3          	and	a5,s4,a0
    8000529e:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052a2:	4691                	li	a3,4
    800052a4:	6609                	lui	a2,0x2
    800052a6:	963e                	add	a2,a2,a5
    800052a8:	85be                	mv	a1,a5
    800052aa:	855e                	mv	a0,s7
    800052ac:	ffffc097          	auipc	ra,0xffffc
    800052b0:	180080e7          	jalr	384(ra) # 8000142c <uvmalloc>
    800052b4:	8b2a                	mv	s6,a0
  ip = 0;
    800052b6:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052b8:	12050c63          	beqz	a0,800053f0 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052bc:	75f9                	lui	a1,0xffffe
    800052be:	95aa                	add	a1,a1,a0
    800052c0:	855e                	mv	a0,s7
    800052c2:	ffffc097          	auipc	ra,0xffffc
    800052c6:	390080e7          	jalr	912(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    800052ca:	7c7d                	lui	s8,0xfffff
    800052cc:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800052ce:	e0043783          	ld	a5,-512(s0)
    800052d2:	6388                	ld	a0,0(a5)
    800052d4:	c535                	beqz	a0,80005340 <exec+0x218>
    800052d6:	e9040993          	addi	s3,s0,-368
    800052da:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800052de:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800052e0:	ffffc097          	auipc	ra,0xffffc
    800052e4:	b8a080e7          	jalr	-1142(ra) # 80000e6a <strlen>
    800052e8:	2505                	addiw	a0,a0,1
    800052ea:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052ee:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800052f2:	13896663          	bltu	s2,s8,8000541e <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052f6:	e0043d83          	ld	s11,-512(s0)
    800052fa:	000dba03          	ld	s4,0(s11)
    800052fe:	8552                	mv	a0,s4
    80005300:	ffffc097          	auipc	ra,0xffffc
    80005304:	b6a080e7          	jalr	-1174(ra) # 80000e6a <strlen>
    80005308:	0015069b          	addiw	a3,a0,1
    8000530c:	8652                	mv	a2,s4
    8000530e:	85ca                	mv	a1,s2
    80005310:	855e                	mv	a0,s7
    80005312:	ffffc097          	auipc	ra,0xffffc
    80005316:	372080e7          	jalr	882(ra) # 80001684 <copyout>
    8000531a:	10054663          	bltz	a0,80005426 <exec+0x2fe>
    ustack[argc] = sp;
    8000531e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005322:	0485                	addi	s1,s1,1
    80005324:	008d8793          	addi	a5,s11,8
    80005328:	e0f43023          	sd	a5,-512(s0)
    8000532c:	008db503          	ld	a0,8(s11)
    80005330:	c911                	beqz	a0,80005344 <exec+0x21c>
    if(argc >= MAXARG)
    80005332:	09a1                	addi	s3,s3,8
    80005334:	fb3c96e3          	bne	s9,s3,800052e0 <exec+0x1b8>
  sz = sz1;
    80005338:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000533c:	4481                	li	s1,0
    8000533e:	a84d                	j	800053f0 <exec+0x2c8>
  sp = sz;
    80005340:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005342:	4481                	li	s1,0
  ustack[argc] = 0;
    80005344:	00349793          	slli	a5,s1,0x3
    80005348:	f9040713          	addi	a4,s0,-112
    8000534c:	97ba                	add	a5,a5,a4
    8000534e:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005352:	00148693          	addi	a3,s1,1
    80005356:	068e                	slli	a3,a3,0x3
    80005358:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000535c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005360:	01897663          	bgeu	s2,s8,8000536c <exec+0x244>
  sz = sz1;
    80005364:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005368:	4481                	li	s1,0
    8000536a:	a059                	j	800053f0 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000536c:	e9040613          	addi	a2,s0,-368
    80005370:	85ca                	mv	a1,s2
    80005372:	855e                	mv	a0,s7
    80005374:	ffffc097          	auipc	ra,0xffffc
    80005378:	310080e7          	jalr	784(ra) # 80001684 <copyout>
    8000537c:	0a054963          	bltz	a0,8000542e <exec+0x306>
  p->trapframe->a1 = sp;
    80005380:	058ab783          	ld	a5,88(s5)
    80005384:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005388:	df843783          	ld	a5,-520(s0)
    8000538c:	0007c703          	lbu	a4,0(a5)
    80005390:	cf11                	beqz	a4,800053ac <exec+0x284>
    80005392:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005394:	02f00693          	li	a3,47
    80005398:	a039                	j	800053a6 <exec+0x27e>
      last = s+1;
    8000539a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000539e:	0785                	addi	a5,a5,1
    800053a0:	fff7c703          	lbu	a4,-1(a5)
    800053a4:	c701                	beqz	a4,800053ac <exec+0x284>
    if(*s == '/')
    800053a6:	fed71ce3          	bne	a4,a3,8000539e <exec+0x276>
    800053aa:	bfc5                	j	8000539a <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800053ac:	4641                	li	a2,16
    800053ae:	df843583          	ld	a1,-520(s0)
    800053b2:	158a8513          	addi	a0,s5,344
    800053b6:	ffffc097          	auipc	ra,0xffffc
    800053ba:	a82080e7          	jalr	-1406(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    800053be:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800053c2:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800053c6:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053ca:	058ab783          	ld	a5,88(s5)
    800053ce:	e6843703          	ld	a4,-408(s0)
    800053d2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053d4:	058ab783          	ld	a5,88(s5)
    800053d8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053dc:	85ea                	mv	a1,s10
    800053de:	ffffc097          	auipc	ra,0xffffc
    800053e2:	748080e7          	jalr	1864(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053e6:	0004851b          	sext.w	a0,s1
    800053ea:	bbd9                	j	800051c0 <exec+0x98>
    800053ec:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800053f0:	e0843583          	ld	a1,-504(s0)
    800053f4:	855e                	mv	a0,s7
    800053f6:	ffffc097          	auipc	ra,0xffffc
    800053fa:	730080e7          	jalr	1840(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    800053fe:	da0497e3          	bnez	s1,800051ac <exec+0x84>
  return -1;
    80005402:	557d                	li	a0,-1
    80005404:	bb75                	j	800051c0 <exec+0x98>
    80005406:	e1443423          	sd	s4,-504(s0)
    8000540a:	b7dd                	j	800053f0 <exec+0x2c8>
    8000540c:	e1443423          	sd	s4,-504(s0)
    80005410:	b7c5                	j	800053f0 <exec+0x2c8>
    80005412:	e1443423          	sd	s4,-504(s0)
    80005416:	bfe9                	j	800053f0 <exec+0x2c8>
    80005418:	e1443423          	sd	s4,-504(s0)
    8000541c:	bfd1                	j	800053f0 <exec+0x2c8>
  sz = sz1;
    8000541e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005422:	4481                	li	s1,0
    80005424:	b7f1                	j	800053f0 <exec+0x2c8>
  sz = sz1;
    80005426:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000542a:	4481                	li	s1,0
    8000542c:	b7d1                	j	800053f0 <exec+0x2c8>
  sz = sz1;
    8000542e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005432:	4481                	li	s1,0
    80005434:	bf75                	j	800053f0 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005436:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000543a:	2b05                	addiw	s6,s6,1
    8000543c:	0389899b          	addiw	s3,s3,56
    80005440:	e8845783          	lhu	a5,-376(s0)
    80005444:	e2fb57e3          	bge	s6,a5,80005272 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005448:	2981                	sext.w	s3,s3
    8000544a:	03800713          	li	a4,56
    8000544e:	86ce                	mv	a3,s3
    80005450:	e1840613          	addi	a2,s0,-488
    80005454:	4581                	li	a1,0
    80005456:	8526                	mv	a0,s1
    80005458:	fffff097          	auipc	ra,0xfffff
    8000545c:	a6e080e7          	jalr	-1426(ra) # 80003ec6 <readi>
    80005460:	03800793          	li	a5,56
    80005464:	f8f514e3          	bne	a0,a5,800053ec <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    80005468:	e1842783          	lw	a5,-488(s0)
    8000546c:	4705                	li	a4,1
    8000546e:	fce796e3          	bne	a5,a4,8000543a <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005472:	e4043903          	ld	s2,-448(s0)
    80005476:	e3843783          	ld	a5,-456(s0)
    8000547a:	f8f966e3          	bltu	s2,a5,80005406 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000547e:	e2843783          	ld	a5,-472(s0)
    80005482:	993e                	add	s2,s2,a5
    80005484:	f8f964e3          	bltu	s2,a5,8000540c <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005488:	df043703          	ld	a4,-528(s0)
    8000548c:	8ff9                	and	a5,a5,a4
    8000548e:	f3d1                	bnez	a5,80005412 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005490:	e1c42503          	lw	a0,-484(s0)
    80005494:	00000097          	auipc	ra,0x0
    80005498:	c78080e7          	jalr	-904(ra) # 8000510c <flags2perm>
    8000549c:	86aa                	mv	a3,a0
    8000549e:	864a                	mv	a2,s2
    800054a0:	85d2                	mv	a1,s4
    800054a2:	855e                	mv	a0,s7
    800054a4:	ffffc097          	auipc	ra,0xffffc
    800054a8:	f88080e7          	jalr	-120(ra) # 8000142c <uvmalloc>
    800054ac:	e0a43423          	sd	a0,-504(s0)
    800054b0:	d525                	beqz	a0,80005418 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054b2:	e2843d03          	ld	s10,-472(s0)
    800054b6:	e2042d83          	lw	s11,-480(s0)
    800054ba:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054be:	f60c0ce3          	beqz	s8,80005436 <exec+0x30e>
    800054c2:	8a62                	mv	s4,s8
    800054c4:	4901                	li	s2,0
    800054c6:	b369                	j	80005250 <exec+0x128>

00000000800054c8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054c8:	7179                	addi	sp,sp,-48
    800054ca:	f406                	sd	ra,40(sp)
    800054cc:	f022                	sd	s0,32(sp)
    800054ce:	ec26                	sd	s1,24(sp)
    800054d0:	e84a                	sd	s2,16(sp)
    800054d2:	1800                	addi	s0,sp,48
    800054d4:	892e                	mv	s2,a1
    800054d6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054d8:	fdc40593          	addi	a1,s0,-36
    800054dc:	ffffe097          	auipc	ra,0xffffe
    800054e0:	a5e080e7          	jalr	-1442(ra) # 80002f3a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054e4:	fdc42703          	lw	a4,-36(s0)
    800054e8:	47bd                	li	a5,15
    800054ea:	02e7eb63          	bltu	a5,a4,80005520 <argfd+0x58>
    800054ee:	ffffc097          	auipc	ra,0xffffc
    800054f2:	4d8080e7          	jalr	1240(ra) # 800019c6 <myproc>
    800054f6:	fdc42703          	lw	a4,-36(s0)
    800054fa:	01a70793          	addi	a5,a4,26
    800054fe:	078e                	slli	a5,a5,0x3
    80005500:	953e                	add	a0,a0,a5
    80005502:	611c                	ld	a5,0(a0)
    80005504:	c385                	beqz	a5,80005524 <argfd+0x5c>
    return -1;
  if(pfd)
    80005506:	00090463          	beqz	s2,8000550e <argfd+0x46>
    *pfd = fd;
    8000550a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000550e:	4501                	li	a0,0
  if(pf)
    80005510:	c091                	beqz	s1,80005514 <argfd+0x4c>
    *pf = f;
    80005512:	e09c                	sd	a5,0(s1)
}
    80005514:	70a2                	ld	ra,40(sp)
    80005516:	7402                	ld	s0,32(sp)
    80005518:	64e2                	ld	s1,24(sp)
    8000551a:	6942                	ld	s2,16(sp)
    8000551c:	6145                	addi	sp,sp,48
    8000551e:	8082                	ret
    return -1;
    80005520:	557d                	li	a0,-1
    80005522:	bfcd                	j	80005514 <argfd+0x4c>
    80005524:	557d                	li	a0,-1
    80005526:	b7fd                	j	80005514 <argfd+0x4c>

0000000080005528 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005528:	1101                	addi	sp,sp,-32
    8000552a:	ec06                	sd	ra,24(sp)
    8000552c:	e822                	sd	s0,16(sp)
    8000552e:	e426                	sd	s1,8(sp)
    80005530:	1000                	addi	s0,sp,32
    80005532:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005534:	ffffc097          	auipc	ra,0xffffc
    80005538:	492080e7          	jalr	1170(ra) # 800019c6 <myproc>
    8000553c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000553e:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdc980>
    80005542:	4501                	li	a0,0
    80005544:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005546:	6398                	ld	a4,0(a5)
    80005548:	cb19                	beqz	a4,8000555e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000554a:	2505                	addiw	a0,a0,1
    8000554c:	07a1                	addi	a5,a5,8
    8000554e:	fed51ce3          	bne	a0,a3,80005546 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005552:	557d                	li	a0,-1
}
    80005554:	60e2                	ld	ra,24(sp)
    80005556:	6442                	ld	s0,16(sp)
    80005558:	64a2                	ld	s1,8(sp)
    8000555a:	6105                	addi	sp,sp,32
    8000555c:	8082                	ret
      p->ofile[fd] = f;
    8000555e:	01a50793          	addi	a5,a0,26
    80005562:	078e                	slli	a5,a5,0x3
    80005564:	963e                	add	a2,a2,a5
    80005566:	e204                	sd	s1,0(a2)
      return fd;
    80005568:	b7f5                	j	80005554 <fdalloc+0x2c>

000000008000556a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000556a:	715d                	addi	sp,sp,-80
    8000556c:	e486                	sd	ra,72(sp)
    8000556e:	e0a2                	sd	s0,64(sp)
    80005570:	fc26                	sd	s1,56(sp)
    80005572:	f84a                	sd	s2,48(sp)
    80005574:	f44e                	sd	s3,40(sp)
    80005576:	f052                	sd	s4,32(sp)
    80005578:	ec56                	sd	s5,24(sp)
    8000557a:	e85a                	sd	s6,16(sp)
    8000557c:	0880                	addi	s0,sp,80
    8000557e:	8b2e                	mv	s6,a1
    80005580:	89b2                	mv	s3,a2
    80005582:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005584:	fb040593          	addi	a1,s0,-80
    80005588:	fffff097          	auipc	ra,0xfffff
    8000558c:	e4e080e7          	jalr	-434(ra) # 800043d6 <nameiparent>
    80005590:	84aa                	mv	s1,a0
    80005592:	16050063          	beqz	a0,800056f2 <create+0x188>
    return 0;

  ilock(dp);
    80005596:	ffffe097          	auipc	ra,0xffffe
    8000559a:	67c080e7          	jalr	1660(ra) # 80003c12 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000559e:	4601                	li	a2,0
    800055a0:	fb040593          	addi	a1,s0,-80
    800055a4:	8526                	mv	a0,s1
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	b50080e7          	jalr	-1200(ra) # 800040f6 <dirlookup>
    800055ae:	8aaa                	mv	s5,a0
    800055b0:	c931                	beqz	a0,80005604 <create+0x9a>
    iunlockput(dp);
    800055b2:	8526                	mv	a0,s1
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	8c0080e7          	jalr	-1856(ra) # 80003e74 <iunlockput>
    ilock(ip);
    800055bc:	8556                	mv	a0,s5
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	654080e7          	jalr	1620(ra) # 80003c12 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055c6:	000b059b          	sext.w	a1,s6
    800055ca:	4789                	li	a5,2
    800055cc:	02f59563          	bne	a1,a5,800055f6 <create+0x8c>
    800055d0:	044ad783          	lhu	a5,68(s5)
    800055d4:	37f9                	addiw	a5,a5,-2
    800055d6:	17c2                	slli	a5,a5,0x30
    800055d8:	93c1                	srli	a5,a5,0x30
    800055da:	4705                	li	a4,1
    800055dc:	00f76d63          	bltu	a4,a5,800055f6 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055e0:	8556                	mv	a0,s5
    800055e2:	60a6                	ld	ra,72(sp)
    800055e4:	6406                	ld	s0,64(sp)
    800055e6:	74e2                	ld	s1,56(sp)
    800055e8:	7942                	ld	s2,48(sp)
    800055ea:	79a2                	ld	s3,40(sp)
    800055ec:	7a02                	ld	s4,32(sp)
    800055ee:	6ae2                	ld	s5,24(sp)
    800055f0:	6b42                	ld	s6,16(sp)
    800055f2:	6161                	addi	sp,sp,80
    800055f4:	8082                	ret
    iunlockput(ip);
    800055f6:	8556                	mv	a0,s5
    800055f8:	fffff097          	auipc	ra,0xfffff
    800055fc:	87c080e7          	jalr	-1924(ra) # 80003e74 <iunlockput>
    return 0;
    80005600:	4a81                	li	s5,0
    80005602:	bff9                	j	800055e0 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005604:	85da                	mv	a1,s6
    80005606:	4088                	lw	a0,0(s1)
    80005608:	ffffe097          	auipc	ra,0xffffe
    8000560c:	46e080e7          	jalr	1134(ra) # 80003a76 <ialloc>
    80005610:	8a2a                	mv	s4,a0
    80005612:	c921                	beqz	a0,80005662 <create+0xf8>
  ilock(ip);
    80005614:	ffffe097          	auipc	ra,0xffffe
    80005618:	5fe080e7          	jalr	1534(ra) # 80003c12 <ilock>
  ip->major = major;
    8000561c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005620:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005624:	4785                	li	a5,1
    80005626:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    8000562a:	8552                	mv	a0,s4
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	51c080e7          	jalr	1308(ra) # 80003b48 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005634:	000b059b          	sext.w	a1,s6
    80005638:	4785                	li	a5,1
    8000563a:	02f58b63          	beq	a1,a5,80005670 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    8000563e:	004a2603          	lw	a2,4(s4)
    80005642:	fb040593          	addi	a1,s0,-80
    80005646:	8526                	mv	a0,s1
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	cbe080e7          	jalr	-834(ra) # 80004306 <dirlink>
    80005650:	06054f63          	bltz	a0,800056ce <create+0x164>
  iunlockput(dp);
    80005654:	8526                	mv	a0,s1
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	81e080e7          	jalr	-2018(ra) # 80003e74 <iunlockput>
  return ip;
    8000565e:	8ad2                	mv	s5,s4
    80005660:	b741                	j	800055e0 <create+0x76>
    iunlockput(dp);
    80005662:	8526                	mv	a0,s1
    80005664:	fffff097          	auipc	ra,0xfffff
    80005668:	810080e7          	jalr	-2032(ra) # 80003e74 <iunlockput>
    return 0;
    8000566c:	8ad2                	mv	s5,s4
    8000566e:	bf8d                	j	800055e0 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005670:	004a2603          	lw	a2,4(s4)
    80005674:	00003597          	auipc	a1,0x3
    80005678:	28c58593          	addi	a1,a1,652 # 80008900 <syscalls+0x2d0>
    8000567c:	8552                	mv	a0,s4
    8000567e:	fffff097          	auipc	ra,0xfffff
    80005682:	c88080e7          	jalr	-888(ra) # 80004306 <dirlink>
    80005686:	04054463          	bltz	a0,800056ce <create+0x164>
    8000568a:	40d0                	lw	a2,4(s1)
    8000568c:	00003597          	auipc	a1,0x3
    80005690:	27c58593          	addi	a1,a1,636 # 80008908 <syscalls+0x2d8>
    80005694:	8552                	mv	a0,s4
    80005696:	fffff097          	auipc	ra,0xfffff
    8000569a:	c70080e7          	jalr	-912(ra) # 80004306 <dirlink>
    8000569e:	02054863          	bltz	a0,800056ce <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800056a2:	004a2603          	lw	a2,4(s4)
    800056a6:	fb040593          	addi	a1,s0,-80
    800056aa:	8526                	mv	a0,s1
    800056ac:	fffff097          	auipc	ra,0xfffff
    800056b0:	c5a080e7          	jalr	-934(ra) # 80004306 <dirlink>
    800056b4:	00054d63          	bltz	a0,800056ce <create+0x164>
    dp->nlink++;  // for ".."
    800056b8:	04a4d783          	lhu	a5,74(s1)
    800056bc:	2785                	addiw	a5,a5,1
    800056be:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056c2:	8526                	mv	a0,s1
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	484080e7          	jalr	1156(ra) # 80003b48 <iupdate>
    800056cc:	b761                	j	80005654 <create+0xea>
  ip->nlink = 0;
    800056ce:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800056d2:	8552                	mv	a0,s4
    800056d4:	ffffe097          	auipc	ra,0xffffe
    800056d8:	474080e7          	jalr	1140(ra) # 80003b48 <iupdate>
  iunlockput(ip);
    800056dc:	8552                	mv	a0,s4
    800056de:	ffffe097          	auipc	ra,0xffffe
    800056e2:	796080e7          	jalr	1942(ra) # 80003e74 <iunlockput>
  iunlockput(dp);
    800056e6:	8526                	mv	a0,s1
    800056e8:	ffffe097          	auipc	ra,0xffffe
    800056ec:	78c080e7          	jalr	1932(ra) # 80003e74 <iunlockput>
  return 0;
    800056f0:	bdc5                	j	800055e0 <create+0x76>
    return 0;
    800056f2:	8aaa                	mv	s5,a0
    800056f4:	b5f5                	j	800055e0 <create+0x76>

00000000800056f6 <sys_dup>:
{
    800056f6:	7179                	addi	sp,sp,-48
    800056f8:	f406                	sd	ra,40(sp)
    800056fa:	f022                	sd	s0,32(sp)
    800056fc:	ec26                	sd	s1,24(sp)
    800056fe:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005700:	fd840613          	addi	a2,s0,-40
    80005704:	4581                	li	a1,0
    80005706:	4501                	li	a0,0
    80005708:	00000097          	auipc	ra,0x0
    8000570c:	dc0080e7          	jalr	-576(ra) # 800054c8 <argfd>
    return -1;
    80005710:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005712:	02054363          	bltz	a0,80005738 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005716:	fd843503          	ld	a0,-40(s0)
    8000571a:	00000097          	auipc	ra,0x0
    8000571e:	e0e080e7          	jalr	-498(ra) # 80005528 <fdalloc>
    80005722:	84aa                	mv	s1,a0
    return -1;
    80005724:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005726:	00054963          	bltz	a0,80005738 <sys_dup+0x42>
  filedup(f);
    8000572a:	fd843503          	ld	a0,-40(s0)
    8000572e:	fffff097          	auipc	ra,0xfffff
    80005732:	320080e7          	jalr	800(ra) # 80004a4e <filedup>
  return fd;
    80005736:	87a6                	mv	a5,s1
}
    80005738:	853e                	mv	a0,a5
    8000573a:	70a2                	ld	ra,40(sp)
    8000573c:	7402                	ld	s0,32(sp)
    8000573e:	64e2                	ld	s1,24(sp)
    80005740:	6145                	addi	sp,sp,48
    80005742:	8082                	ret

0000000080005744 <sys_read>:
{
    80005744:	7179                	addi	sp,sp,-48
    80005746:	f406                	sd	ra,40(sp)
    80005748:	f022                	sd	s0,32(sp)
    8000574a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000574c:	fd840593          	addi	a1,s0,-40
    80005750:	4505                	li	a0,1
    80005752:	ffffe097          	auipc	ra,0xffffe
    80005756:	80a080e7          	jalr	-2038(ra) # 80002f5c <argaddr>
  argint(2, &n);
    8000575a:	fe440593          	addi	a1,s0,-28
    8000575e:	4509                	li	a0,2
    80005760:	ffffd097          	auipc	ra,0xffffd
    80005764:	7da080e7          	jalr	2010(ra) # 80002f3a <argint>
  if(argfd(0, 0, &f) < 0)
    80005768:	fe840613          	addi	a2,s0,-24
    8000576c:	4581                	li	a1,0
    8000576e:	4501                	li	a0,0
    80005770:	00000097          	auipc	ra,0x0
    80005774:	d58080e7          	jalr	-680(ra) # 800054c8 <argfd>
    80005778:	87aa                	mv	a5,a0
    return -1;
    8000577a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000577c:	0007cc63          	bltz	a5,80005794 <sys_read+0x50>
  return fileread(f, p, n);
    80005780:	fe442603          	lw	a2,-28(s0)
    80005784:	fd843583          	ld	a1,-40(s0)
    80005788:	fe843503          	ld	a0,-24(s0)
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	44e080e7          	jalr	1102(ra) # 80004bda <fileread>
}
    80005794:	70a2                	ld	ra,40(sp)
    80005796:	7402                	ld	s0,32(sp)
    80005798:	6145                	addi	sp,sp,48
    8000579a:	8082                	ret

000000008000579c <sys_write>:
{
    8000579c:	7179                	addi	sp,sp,-48
    8000579e:	f406                	sd	ra,40(sp)
    800057a0:	f022                	sd	s0,32(sp)
    800057a2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057a4:	fd840593          	addi	a1,s0,-40
    800057a8:	4505                	li	a0,1
    800057aa:	ffffd097          	auipc	ra,0xffffd
    800057ae:	7b2080e7          	jalr	1970(ra) # 80002f5c <argaddr>
  argint(2, &n);
    800057b2:	fe440593          	addi	a1,s0,-28
    800057b6:	4509                	li	a0,2
    800057b8:	ffffd097          	auipc	ra,0xffffd
    800057bc:	782080e7          	jalr	1922(ra) # 80002f3a <argint>
  if(argfd(0, 0, &f) < 0)
    800057c0:	fe840613          	addi	a2,s0,-24
    800057c4:	4581                	li	a1,0
    800057c6:	4501                	li	a0,0
    800057c8:	00000097          	auipc	ra,0x0
    800057cc:	d00080e7          	jalr	-768(ra) # 800054c8 <argfd>
    800057d0:	87aa                	mv	a5,a0
    return -1;
    800057d2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057d4:	0007cc63          	bltz	a5,800057ec <sys_write+0x50>
  return filewrite(f, p, n);
    800057d8:	fe442603          	lw	a2,-28(s0)
    800057dc:	fd843583          	ld	a1,-40(s0)
    800057e0:	fe843503          	ld	a0,-24(s0)
    800057e4:	fffff097          	auipc	ra,0xfffff
    800057e8:	4b8080e7          	jalr	1208(ra) # 80004c9c <filewrite>
}
    800057ec:	70a2                	ld	ra,40(sp)
    800057ee:	7402                	ld	s0,32(sp)
    800057f0:	6145                	addi	sp,sp,48
    800057f2:	8082                	ret

00000000800057f4 <sys_close>:
{
    800057f4:	1101                	addi	sp,sp,-32
    800057f6:	ec06                	sd	ra,24(sp)
    800057f8:	e822                	sd	s0,16(sp)
    800057fa:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057fc:	fe040613          	addi	a2,s0,-32
    80005800:	fec40593          	addi	a1,s0,-20
    80005804:	4501                	li	a0,0
    80005806:	00000097          	auipc	ra,0x0
    8000580a:	cc2080e7          	jalr	-830(ra) # 800054c8 <argfd>
    return -1;
    8000580e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005810:	02054463          	bltz	a0,80005838 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005814:	ffffc097          	auipc	ra,0xffffc
    80005818:	1b2080e7          	jalr	434(ra) # 800019c6 <myproc>
    8000581c:	fec42783          	lw	a5,-20(s0)
    80005820:	07e9                	addi	a5,a5,26
    80005822:	078e                	slli	a5,a5,0x3
    80005824:	97aa                	add	a5,a5,a0
    80005826:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000582a:	fe043503          	ld	a0,-32(s0)
    8000582e:	fffff097          	auipc	ra,0xfffff
    80005832:	272080e7          	jalr	626(ra) # 80004aa0 <fileclose>
  return 0;
    80005836:	4781                	li	a5,0
}
    80005838:	853e                	mv	a0,a5
    8000583a:	60e2                	ld	ra,24(sp)
    8000583c:	6442                	ld	s0,16(sp)
    8000583e:	6105                	addi	sp,sp,32
    80005840:	8082                	ret

0000000080005842 <sys_fstat>:
{
    80005842:	1101                	addi	sp,sp,-32
    80005844:	ec06                	sd	ra,24(sp)
    80005846:	e822                	sd	s0,16(sp)
    80005848:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000584a:	fe040593          	addi	a1,s0,-32
    8000584e:	4505                	li	a0,1
    80005850:	ffffd097          	auipc	ra,0xffffd
    80005854:	70c080e7          	jalr	1804(ra) # 80002f5c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005858:	fe840613          	addi	a2,s0,-24
    8000585c:	4581                	li	a1,0
    8000585e:	4501                	li	a0,0
    80005860:	00000097          	auipc	ra,0x0
    80005864:	c68080e7          	jalr	-920(ra) # 800054c8 <argfd>
    80005868:	87aa                	mv	a5,a0
    return -1;
    8000586a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000586c:	0007ca63          	bltz	a5,80005880 <sys_fstat+0x3e>
  return filestat(f, st);
    80005870:	fe043583          	ld	a1,-32(s0)
    80005874:	fe843503          	ld	a0,-24(s0)
    80005878:	fffff097          	auipc	ra,0xfffff
    8000587c:	2f0080e7          	jalr	752(ra) # 80004b68 <filestat>
}
    80005880:	60e2                	ld	ra,24(sp)
    80005882:	6442                	ld	s0,16(sp)
    80005884:	6105                	addi	sp,sp,32
    80005886:	8082                	ret

0000000080005888 <sys_link>:
{
    80005888:	7169                	addi	sp,sp,-304
    8000588a:	f606                	sd	ra,296(sp)
    8000588c:	f222                	sd	s0,288(sp)
    8000588e:	ee26                	sd	s1,280(sp)
    80005890:	ea4a                	sd	s2,272(sp)
    80005892:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005894:	08000613          	li	a2,128
    80005898:	ed040593          	addi	a1,s0,-304
    8000589c:	4501                	li	a0,0
    8000589e:	ffffd097          	auipc	ra,0xffffd
    800058a2:	6e0080e7          	jalr	1760(ra) # 80002f7e <argstr>
    return -1;
    800058a6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058a8:	10054e63          	bltz	a0,800059c4 <sys_link+0x13c>
    800058ac:	08000613          	li	a2,128
    800058b0:	f5040593          	addi	a1,s0,-176
    800058b4:	4505                	li	a0,1
    800058b6:	ffffd097          	auipc	ra,0xffffd
    800058ba:	6c8080e7          	jalr	1736(ra) # 80002f7e <argstr>
    return -1;
    800058be:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058c0:	10054263          	bltz	a0,800059c4 <sys_link+0x13c>
  begin_op();
    800058c4:	fffff097          	auipc	ra,0xfffff
    800058c8:	d10080e7          	jalr	-752(ra) # 800045d4 <begin_op>
  if((ip = namei(old)) == 0){
    800058cc:	ed040513          	addi	a0,s0,-304
    800058d0:	fffff097          	auipc	ra,0xfffff
    800058d4:	ae8080e7          	jalr	-1304(ra) # 800043b8 <namei>
    800058d8:	84aa                	mv	s1,a0
    800058da:	c551                	beqz	a0,80005966 <sys_link+0xde>
  ilock(ip);
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	336080e7          	jalr	822(ra) # 80003c12 <ilock>
  if(ip->type == T_DIR){
    800058e4:	04449703          	lh	a4,68(s1)
    800058e8:	4785                	li	a5,1
    800058ea:	08f70463          	beq	a4,a5,80005972 <sys_link+0xea>
  ip->nlink++;
    800058ee:	04a4d783          	lhu	a5,74(s1)
    800058f2:	2785                	addiw	a5,a5,1
    800058f4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058f8:	8526                	mv	a0,s1
    800058fa:	ffffe097          	auipc	ra,0xffffe
    800058fe:	24e080e7          	jalr	590(ra) # 80003b48 <iupdate>
  iunlock(ip);
    80005902:	8526                	mv	a0,s1
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	3d0080e7          	jalr	976(ra) # 80003cd4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000590c:	fd040593          	addi	a1,s0,-48
    80005910:	f5040513          	addi	a0,s0,-176
    80005914:	fffff097          	auipc	ra,0xfffff
    80005918:	ac2080e7          	jalr	-1342(ra) # 800043d6 <nameiparent>
    8000591c:	892a                	mv	s2,a0
    8000591e:	c935                	beqz	a0,80005992 <sys_link+0x10a>
  ilock(dp);
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	2f2080e7          	jalr	754(ra) # 80003c12 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005928:	00092703          	lw	a4,0(s2)
    8000592c:	409c                	lw	a5,0(s1)
    8000592e:	04f71d63          	bne	a4,a5,80005988 <sys_link+0x100>
    80005932:	40d0                	lw	a2,4(s1)
    80005934:	fd040593          	addi	a1,s0,-48
    80005938:	854a                	mv	a0,s2
    8000593a:	fffff097          	auipc	ra,0xfffff
    8000593e:	9cc080e7          	jalr	-1588(ra) # 80004306 <dirlink>
    80005942:	04054363          	bltz	a0,80005988 <sys_link+0x100>
  iunlockput(dp);
    80005946:	854a                	mv	a0,s2
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	52c080e7          	jalr	1324(ra) # 80003e74 <iunlockput>
  iput(ip);
    80005950:	8526                	mv	a0,s1
    80005952:	ffffe097          	auipc	ra,0xffffe
    80005956:	47a080e7          	jalr	1146(ra) # 80003dcc <iput>
  end_op();
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	cfa080e7          	jalr	-774(ra) # 80004654 <end_op>
  return 0;
    80005962:	4781                	li	a5,0
    80005964:	a085                	j	800059c4 <sys_link+0x13c>
    end_op();
    80005966:	fffff097          	auipc	ra,0xfffff
    8000596a:	cee080e7          	jalr	-786(ra) # 80004654 <end_op>
    return -1;
    8000596e:	57fd                	li	a5,-1
    80005970:	a891                	j	800059c4 <sys_link+0x13c>
    iunlockput(ip);
    80005972:	8526                	mv	a0,s1
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	500080e7          	jalr	1280(ra) # 80003e74 <iunlockput>
    end_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	cd8080e7          	jalr	-808(ra) # 80004654 <end_op>
    return -1;
    80005984:	57fd                	li	a5,-1
    80005986:	a83d                	j	800059c4 <sys_link+0x13c>
    iunlockput(dp);
    80005988:	854a                	mv	a0,s2
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	4ea080e7          	jalr	1258(ra) # 80003e74 <iunlockput>
  ilock(ip);
    80005992:	8526                	mv	a0,s1
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	27e080e7          	jalr	638(ra) # 80003c12 <ilock>
  ip->nlink--;
    8000599c:	04a4d783          	lhu	a5,74(s1)
    800059a0:	37fd                	addiw	a5,a5,-1
    800059a2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059a6:	8526                	mv	a0,s1
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	1a0080e7          	jalr	416(ra) # 80003b48 <iupdate>
  iunlockput(ip);
    800059b0:	8526                	mv	a0,s1
    800059b2:	ffffe097          	auipc	ra,0xffffe
    800059b6:	4c2080e7          	jalr	1218(ra) # 80003e74 <iunlockput>
  end_op();
    800059ba:	fffff097          	auipc	ra,0xfffff
    800059be:	c9a080e7          	jalr	-870(ra) # 80004654 <end_op>
  return -1;
    800059c2:	57fd                	li	a5,-1
}
    800059c4:	853e                	mv	a0,a5
    800059c6:	70b2                	ld	ra,296(sp)
    800059c8:	7412                	ld	s0,288(sp)
    800059ca:	64f2                	ld	s1,280(sp)
    800059cc:	6952                	ld	s2,272(sp)
    800059ce:	6155                	addi	sp,sp,304
    800059d0:	8082                	ret

00000000800059d2 <sys_unlink>:
{
    800059d2:	7151                	addi	sp,sp,-240
    800059d4:	f586                	sd	ra,232(sp)
    800059d6:	f1a2                	sd	s0,224(sp)
    800059d8:	eda6                	sd	s1,216(sp)
    800059da:	e9ca                	sd	s2,208(sp)
    800059dc:	e5ce                	sd	s3,200(sp)
    800059de:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059e0:	08000613          	li	a2,128
    800059e4:	f3040593          	addi	a1,s0,-208
    800059e8:	4501                	li	a0,0
    800059ea:	ffffd097          	auipc	ra,0xffffd
    800059ee:	594080e7          	jalr	1428(ra) # 80002f7e <argstr>
    800059f2:	18054163          	bltz	a0,80005b74 <sys_unlink+0x1a2>
  begin_op();
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	bde080e7          	jalr	-1058(ra) # 800045d4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800059fe:	fb040593          	addi	a1,s0,-80
    80005a02:	f3040513          	addi	a0,s0,-208
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	9d0080e7          	jalr	-1584(ra) # 800043d6 <nameiparent>
    80005a0e:	84aa                	mv	s1,a0
    80005a10:	c979                	beqz	a0,80005ae6 <sys_unlink+0x114>
  ilock(dp);
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	200080e7          	jalr	512(ra) # 80003c12 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a1a:	00003597          	auipc	a1,0x3
    80005a1e:	ee658593          	addi	a1,a1,-282 # 80008900 <syscalls+0x2d0>
    80005a22:	fb040513          	addi	a0,s0,-80
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	6b6080e7          	jalr	1718(ra) # 800040dc <namecmp>
    80005a2e:	14050a63          	beqz	a0,80005b82 <sys_unlink+0x1b0>
    80005a32:	00003597          	auipc	a1,0x3
    80005a36:	ed658593          	addi	a1,a1,-298 # 80008908 <syscalls+0x2d8>
    80005a3a:	fb040513          	addi	a0,s0,-80
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	69e080e7          	jalr	1694(ra) # 800040dc <namecmp>
    80005a46:	12050e63          	beqz	a0,80005b82 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a4a:	f2c40613          	addi	a2,s0,-212
    80005a4e:	fb040593          	addi	a1,s0,-80
    80005a52:	8526                	mv	a0,s1
    80005a54:	ffffe097          	auipc	ra,0xffffe
    80005a58:	6a2080e7          	jalr	1698(ra) # 800040f6 <dirlookup>
    80005a5c:	892a                	mv	s2,a0
    80005a5e:	12050263          	beqz	a0,80005b82 <sys_unlink+0x1b0>
  ilock(ip);
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	1b0080e7          	jalr	432(ra) # 80003c12 <ilock>
  if(ip->nlink < 1)
    80005a6a:	04a91783          	lh	a5,74(s2)
    80005a6e:	08f05263          	blez	a5,80005af2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a72:	04491703          	lh	a4,68(s2)
    80005a76:	4785                	li	a5,1
    80005a78:	08f70563          	beq	a4,a5,80005b02 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a7c:	4641                	li	a2,16
    80005a7e:	4581                	li	a1,0
    80005a80:	fc040513          	addi	a0,s0,-64
    80005a84:	ffffb097          	auipc	ra,0xffffb
    80005a88:	262080e7          	jalr	610(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a8c:	4741                	li	a4,16
    80005a8e:	f2c42683          	lw	a3,-212(s0)
    80005a92:	fc040613          	addi	a2,s0,-64
    80005a96:	4581                	li	a1,0
    80005a98:	8526                	mv	a0,s1
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	524080e7          	jalr	1316(ra) # 80003fbe <writei>
    80005aa2:	47c1                	li	a5,16
    80005aa4:	0af51563          	bne	a0,a5,80005b4e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005aa8:	04491703          	lh	a4,68(s2)
    80005aac:	4785                	li	a5,1
    80005aae:	0af70863          	beq	a4,a5,80005b5e <sys_unlink+0x18c>
  iunlockput(dp);
    80005ab2:	8526                	mv	a0,s1
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	3c0080e7          	jalr	960(ra) # 80003e74 <iunlockput>
  ip->nlink--;
    80005abc:	04a95783          	lhu	a5,74(s2)
    80005ac0:	37fd                	addiw	a5,a5,-1
    80005ac2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005ac6:	854a                	mv	a0,s2
    80005ac8:	ffffe097          	auipc	ra,0xffffe
    80005acc:	080080e7          	jalr	128(ra) # 80003b48 <iupdate>
  iunlockput(ip);
    80005ad0:	854a                	mv	a0,s2
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	3a2080e7          	jalr	930(ra) # 80003e74 <iunlockput>
  end_op();
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	b7a080e7          	jalr	-1158(ra) # 80004654 <end_op>
  return 0;
    80005ae2:	4501                	li	a0,0
    80005ae4:	a84d                	j	80005b96 <sys_unlink+0x1c4>
    end_op();
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	b6e080e7          	jalr	-1170(ra) # 80004654 <end_op>
    return -1;
    80005aee:	557d                	li	a0,-1
    80005af0:	a05d                	j	80005b96 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005af2:	00003517          	auipc	a0,0x3
    80005af6:	e1e50513          	addi	a0,a0,-482 # 80008910 <syscalls+0x2e0>
    80005afa:	ffffb097          	auipc	ra,0xffffb
    80005afe:	a4a080e7          	jalr	-1462(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b02:	04c92703          	lw	a4,76(s2)
    80005b06:	02000793          	li	a5,32
    80005b0a:	f6e7f9e3          	bgeu	a5,a4,80005a7c <sys_unlink+0xaa>
    80005b0e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b12:	4741                	li	a4,16
    80005b14:	86ce                	mv	a3,s3
    80005b16:	f1840613          	addi	a2,s0,-232
    80005b1a:	4581                	li	a1,0
    80005b1c:	854a                	mv	a0,s2
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	3a8080e7          	jalr	936(ra) # 80003ec6 <readi>
    80005b26:	47c1                	li	a5,16
    80005b28:	00f51b63          	bne	a0,a5,80005b3e <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b2c:	f1845783          	lhu	a5,-232(s0)
    80005b30:	e7a1                	bnez	a5,80005b78 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b32:	29c1                	addiw	s3,s3,16
    80005b34:	04c92783          	lw	a5,76(s2)
    80005b38:	fcf9ede3          	bltu	s3,a5,80005b12 <sys_unlink+0x140>
    80005b3c:	b781                	j	80005a7c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b3e:	00003517          	auipc	a0,0x3
    80005b42:	dea50513          	addi	a0,a0,-534 # 80008928 <syscalls+0x2f8>
    80005b46:	ffffb097          	auipc	ra,0xffffb
    80005b4a:	9fe080e7          	jalr	-1538(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005b4e:	00003517          	auipc	a0,0x3
    80005b52:	df250513          	addi	a0,a0,-526 # 80008940 <syscalls+0x310>
    80005b56:	ffffb097          	auipc	ra,0xffffb
    80005b5a:	9ee080e7          	jalr	-1554(ra) # 80000544 <panic>
    dp->nlink--;
    80005b5e:	04a4d783          	lhu	a5,74(s1)
    80005b62:	37fd                	addiw	a5,a5,-1
    80005b64:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b68:	8526                	mv	a0,s1
    80005b6a:	ffffe097          	auipc	ra,0xffffe
    80005b6e:	fde080e7          	jalr	-34(ra) # 80003b48 <iupdate>
    80005b72:	b781                	j	80005ab2 <sys_unlink+0xe0>
    return -1;
    80005b74:	557d                	li	a0,-1
    80005b76:	a005                	j	80005b96 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b78:	854a                	mv	a0,s2
    80005b7a:	ffffe097          	auipc	ra,0xffffe
    80005b7e:	2fa080e7          	jalr	762(ra) # 80003e74 <iunlockput>
  iunlockput(dp);
    80005b82:	8526                	mv	a0,s1
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	2f0080e7          	jalr	752(ra) # 80003e74 <iunlockput>
  end_op();
    80005b8c:	fffff097          	auipc	ra,0xfffff
    80005b90:	ac8080e7          	jalr	-1336(ra) # 80004654 <end_op>
  return -1;
    80005b94:	557d                	li	a0,-1
}
    80005b96:	70ae                	ld	ra,232(sp)
    80005b98:	740e                	ld	s0,224(sp)
    80005b9a:	64ee                	ld	s1,216(sp)
    80005b9c:	694e                	ld	s2,208(sp)
    80005b9e:	69ae                	ld	s3,200(sp)
    80005ba0:	616d                	addi	sp,sp,240
    80005ba2:	8082                	ret

0000000080005ba4 <sys_open>:

uint64
sys_open(void)
{
    80005ba4:	7131                	addi	sp,sp,-192
    80005ba6:	fd06                	sd	ra,184(sp)
    80005ba8:	f922                	sd	s0,176(sp)
    80005baa:	f526                	sd	s1,168(sp)
    80005bac:	f14a                	sd	s2,160(sp)
    80005bae:	ed4e                	sd	s3,152(sp)
    80005bb0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005bb2:	f4c40593          	addi	a1,s0,-180
    80005bb6:	4505                	li	a0,1
    80005bb8:	ffffd097          	auipc	ra,0xffffd
    80005bbc:	382080e7          	jalr	898(ra) # 80002f3a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bc0:	08000613          	li	a2,128
    80005bc4:	f5040593          	addi	a1,s0,-176
    80005bc8:	4501                	li	a0,0
    80005bca:	ffffd097          	auipc	ra,0xffffd
    80005bce:	3b4080e7          	jalr	948(ra) # 80002f7e <argstr>
    80005bd2:	87aa                	mv	a5,a0
    return -1;
    80005bd4:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bd6:	0a07c963          	bltz	a5,80005c88 <sys_open+0xe4>

  begin_op();
    80005bda:	fffff097          	auipc	ra,0xfffff
    80005bde:	9fa080e7          	jalr	-1542(ra) # 800045d4 <begin_op>

  if(omode & O_CREATE){
    80005be2:	f4c42783          	lw	a5,-180(s0)
    80005be6:	2007f793          	andi	a5,a5,512
    80005bea:	cfc5                	beqz	a5,80005ca2 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005bec:	4681                	li	a3,0
    80005bee:	4601                	li	a2,0
    80005bf0:	4589                	li	a1,2
    80005bf2:	f5040513          	addi	a0,s0,-176
    80005bf6:	00000097          	auipc	ra,0x0
    80005bfa:	974080e7          	jalr	-1676(ra) # 8000556a <create>
    80005bfe:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c00:	c959                	beqz	a0,80005c96 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c02:	04449703          	lh	a4,68(s1)
    80005c06:	478d                	li	a5,3
    80005c08:	00f71763          	bne	a4,a5,80005c16 <sys_open+0x72>
    80005c0c:	0464d703          	lhu	a4,70(s1)
    80005c10:	47a5                	li	a5,9
    80005c12:	0ce7ed63          	bltu	a5,a4,80005cec <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c16:	fffff097          	auipc	ra,0xfffff
    80005c1a:	dce080e7          	jalr	-562(ra) # 800049e4 <filealloc>
    80005c1e:	89aa                	mv	s3,a0
    80005c20:	10050363          	beqz	a0,80005d26 <sys_open+0x182>
    80005c24:	00000097          	auipc	ra,0x0
    80005c28:	904080e7          	jalr	-1788(ra) # 80005528 <fdalloc>
    80005c2c:	892a                	mv	s2,a0
    80005c2e:	0e054763          	bltz	a0,80005d1c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c32:	04449703          	lh	a4,68(s1)
    80005c36:	478d                	li	a5,3
    80005c38:	0cf70563          	beq	a4,a5,80005d02 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c3c:	4789                	li	a5,2
    80005c3e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c42:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c46:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c4a:	f4c42783          	lw	a5,-180(s0)
    80005c4e:	0017c713          	xori	a4,a5,1
    80005c52:	8b05                	andi	a4,a4,1
    80005c54:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c58:	0037f713          	andi	a4,a5,3
    80005c5c:	00e03733          	snez	a4,a4
    80005c60:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c64:	4007f793          	andi	a5,a5,1024
    80005c68:	c791                	beqz	a5,80005c74 <sys_open+0xd0>
    80005c6a:	04449703          	lh	a4,68(s1)
    80005c6e:	4789                	li	a5,2
    80005c70:	0af70063          	beq	a4,a5,80005d10 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c74:	8526                	mv	a0,s1
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	05e080e7          	jalr	94(ra) # 80003cd4 <iunlock>
  end_op();
    80005c7e:	fffff097          	auipc	ra,0xfffff
    80005c82:	9d6080e7          	jalr	-1578(ra) # 80004654 <end_op>

  return fd;
    80005c86:	854a                	mv	a0,s2
}
    80005c88:	70ea                	ld	ra,184(sp)
    80005c8a:	744a                	ld	s0,176(sp)
    80005c8c:	74aa                	ld	s1,168(sp)
    80005c8e:	790a                	ld	s2,160(sp)
    80005c90:	69ea                	ld	s3,152(sp)
    80005c92:	6129                	addi	sp,sp,192
    80005c94:	8082                	ret
      end_op();
    80005c96:	fffff097          	auipc	ra,0xfffff
    80005c9a:	9be080e7          	jalr	-1602(ra) # 80004654 <end_op>
      return -1;
    80005c9e:	557d                	li	a0,-1
    80005ca0:	b7e5                	j	80005c88 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005ca2:	f5040513          	addi	a0,s0,-176
    80005ca6:	ffffe097          	auipc	ra,0xffffe
    80005caa:	712080e7          	jalr	1810(ra) # 800043b8 <namei>
    80005cae:	84aa                	mv	s1,a0
    80005cb0:	c905                	beqz	a0,80005ce0 <sys_open+0x13c>
    ilock(ip);
    80005cb2:	ffffe097          	auipc	ra,0xffffe
    80005cb6:	f60080e7          	jalr	-160(ra) # 80003c12 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cba:	04449703          	lh	a4,68(s1)
    80005cbe:	4785                	li	a5,1
    80005cc0:	f4f711e3          	bne	a4,a5,80005c02 <sys_open+0x5e>
    80005cc4:	f4c42783          	lw	a5,-180(s0)
    80005cc8:	d7b9                	beqz	a5,80005c16 <sys_open+0x72>
      iunlockput(ip);
    80005cca:	8526                	mv	a0,s1
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	1a8080e7          	jalr	424(ra) # 80003e74 <iunlockput>
      end_op();
    80005cd4:	fffff097          	auipc	ra,0xfffff
    80005cd8:	980080e7          	jalr	-1664(ra) # 80004654 <end_op>
      return -1;
    80005cdc:	557d                	li	a0,-1
    80005cde:	b76d                	j	80005c88 <sys_open+0xe4>
      end_op();
    80005ce0:	fffff097          	auipc	ra,0xfffff
    80005ce4:	974080e7          	jalr	-1676(ra) # 80004654 <end_op>
      return -1;
    80005ce8:	557d                	li	a0,-1
    80005cea:	bf79                	j	80005c88 <sys_open+0xe4>
    iunlockput(ip);
    80005cec:	8526                	mv	a0,s1
    80005cee:	ffffe097          	auipc	ra,0xffffe
    80005cf2:	186080e7          	jalr	390(ra) # 80003e74 <iunlockput>
    end_op();
    80005cf6:	fffff097          	auipc	ra,0xfffff
    80005cfa:	95e080e7          	jalr	-1698(ra) # 80004654 <end_op>
    return -1;
    80005cfe:	557d                	li	a0,-1
    80005d00:	b761                	j	80005c88 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d02:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d06:	04649783          	lh	a5,70(s1)
    80005d0a:	02f99223          	sh	a5,36(s3)
    80005d0e:	bf25                	j	80005c46 <sys_open+0xa2>
    itrunc(ip);
    80005d10:	8526                	mv	a0,s1
    80005d12:	ffffe097          	auipc	ra,0xffffe
    80005d16:	00e080e7          	jalr	14(ra) # 80003d20 <itrunc>
    80005d1a:	bfa9                	j	80005c74 <sys_open+0xd0>
      fileclose(f);
    80005d1c:	854e                	mv	a0,s3
    80005d1e:	fffff097          	auipc	ra,0xfffff
    80005d22:	d82080e7          	jalr	-638(ra) # 80004aa0 <fileclose>
    iunlockput(ip);
    80005d26:	8526                	mv	a0,s1
    80005d28:	ffffe097          	auipc	ra,0xffffe
    80005d2c:	14c080e7          	jalr	332(ra) # 80003e74 <iunlockput>
    end_op();
    80005d30:	fffff097          	auipc	ra,0xfffff
    80005d34:	924080e7          	jalr	-1756(ra) # 80004654 <end_op>
    return -1;
    80005d38:	557d                	li	a0,-1
    80005d3a:	b7b9                	j	80005c88 <sys_open+0xe4>

0000000080005d3c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d3c:	7175                	addi	sp,sp,-144
    80005d3e:	e506                	sd	ra,136(sp)
    80005d40:	e122                	sd	s0,128(sp)
    80005d42:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	890080e7          	jalr	-1904(ra) # 800045d4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d4c:	08000613          	li	a2,128
    80005d50:	f7040593          	addi	a1,s0,-144
    80005d54:	4501                	li	a0,0
    80005d56:	ffffd097          	auipc	ra,0xffffd
    80005d5a:	228080e7          	jalr	552(ra) # 80002f7e <argstr>
    80005d5e:	02054963          	bltz	a0,80005d90 <sys_mkdir+0x54>
    80005d62:	4681                	li	a3,0
    80005d64:	4601                	li	a2,0
    80005d66:	4585                	li	a1,1
    80005d68:	f7040513          	addi	a0,s0,-144
    80005d6c:	fffff097          	auipc	ra,0xfffff
    80005d70:	7fe080e7          	jalr	2046(ra) # 8000556a <create>
    80005d74:	cd11                	beqz	a0,80005d90 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d76:	ffffe097          	auipc	ra,0xffffe
    80005d7a:	0fe080e7          	jalr	254(ra) # 80003e74 <iunlockput>
  end_op();
    80005d7e:	fffff097          	auipc	ra,0xfffff
    80005d82:	8d6080e7          	jalr	-1834(ra) # 80004654 <end_op>
  return 0;
    80005d86:	4501                	li	a0,0
}
    80005d88:	60aa                	ld	ra,136(sp)
    80005d8a:	640a                	ld	s0,128(sp)
    80005d8c:	6149                	addi	sp,sp,144
    80005d8e:	8082                	ret
    end_op();
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	8c4080e7          	jalr	-1852(ra) # 80004654 <end_op>
    return -1;
    80005d98:	557d                	li	a0,-1
    80005d9a:	b7fd                	j	80005d88 <sys_mkdir+0x4c>

0000000080005d9c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d9c:	7135                	addi	sp,sp,-160
    80005d9e:	ed06                	sd	ra,152(sp)
    80005da0:	e922                	sd	s0,144(sp)
    80005da2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005da4:	fffff097          	auipc	ra,0xfffff
    80005da8:	830080e7          	jalr	-2000(ra) # 800045d4 <begin_op>
  argint(1, &major);
    80005dac:	f6c40593          	addi	a1,s0,-148
    80005db0:	4505                	li	a0,1
    80005db2:	ffffd097          	auipc	ra,0xffffd
    80005db6:	188080e7          	jalr	392(ra) # 80002f3a <argint>
  argint(2, &minor);
    80005dba:	f6840593          	addi	a1,s0,-152
    80005dbe:	4509                	li	a0,2
    80005dc0:	ffffd097          	auipc	ra,0xffffd
    80005dc4:	17a080e7          	jalr	378(ra) # 80002f3a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dc8:	08000613          	li	a2,128
    80005dcc:	f7040593          	addi	a1,s0,-144
    80005dd0:	4501                	li	a0,0
    80005dd2:	ffffd097          	auipc	ra,0xffffd
    80005dd6:	1ac080e7          	jalr	428(ra) # 80002f7e <argstr>
    80005dda:	02054b63          	bltz	a0,80005e10 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005dde:	f6841683          	lh	a3,-152(s0)
    80005de2:	f6c41603          	lh	a2,-148(s0)
    80005de6:	458d                	li	a1,3
    80005de8:	f7040513          	addi	a0,s0,-144
    80005dec:	fffff097          	auipc	ra,0xfffff
    80005df0:	77e080e7          	jalr	1918(ra) # 8000556a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005df4:	cd11                	beqz	a0,80005e10 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005df6:	ffffe097          	auipc	ra,0xffffe
    80005dfa:	07e080e7          	jalr	126(ra) # 80003e74 <iunlockput>
  end_op();
    80005dfe:	fffff097          	auipc	ra,0xfffff
    80005e02:	856080e7          	jalr	-1962(ra) # 80004654 <end_op>
  return 0;
    80005e06:	4501                	li	a0,0
}
    80005e08:	60ea                	ld	ra,152(sp)
    80005e0a:	644a                	ld	s0,144(sp)
    80005e0c:	610d                	addi	sp,sp,160
    80005e0e:	8082                	ret
    end_op();
    80005e10:	fffff097          	auipc	ra,0xfffff
    80005e14:	844080e7          	jalr	-1980(ra) # 80004654 <end_op>
    return -1;
    80005e18:	557d                	li	a0,-1
    80005e1a:	b7fd                	j	80005e08 <sys_mknod+0x6c>

0000000080005e1c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e1c:	7135                	addi	sp,sp,-160
    80005e1e:	ed06                	sd	ra,152(sp)
    80005e20:	e922                	sd	s0,144(sp)
    80005e22:	e526                	sd	s1,136(sp)
    80005e24:	e14a                	sd	s2,128(sp)
    80005e26:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e28:	ffffc097          	auipc	ra,0xffffc
    80005e2c:	b9e080e7          	jalr	-1122(ra) # 800019c6 <myproc>
    80005e30:	892a                	mv	s2,a0
  
  begin_op();
    80005e32:	ffffe097          	auipc	ra,0xffffe
    80005e36:	7a2080e7          	jalr	1954(ra) # 800045d4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e3a:	08000613          	li	a2,128
    80005e3e:	f6040593          	addi	a1,s0,-160
    80005e42:	4501                	li	a0,0
    80005e44:	ffffd097          	auipc	ra,0xffffd
    80005e48:	13a080e7          	jalr	314(ra) # 80002f7e <argstr>
    80005e4c:	04054b63          	bltz	a0,80005ea2 <sys_chdir+0x86>
    80005e50:	f6040513          	addi	a0,s0,-160
    80005e54:	ffffe097          	auipc	ra,0xffffe
    80005e58:	564080e7          	jalr	1380(ra) # 800043b8 <namei>
    80005e5c:	84aa                	mv	s1,a0
    80005e5e:	c131                	beqz	a0,80005ea2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e60:	ffffe097          	auipc	ra,0xffffe
    80005e64:	db2080e7          	jalr	-590(ra) # 80003c12 <ilock>
  if(ip->type != T_DIR){
    80005e68:	04449703          	lh	a4,68(s1)
    80005e6c:	4785                	li	a5,1
    80005e6e:	04f71063          	bne	a4,a5,80005eae <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e72:	8526                	mv	a0,s1
    80005e74:	ffffe097          	auipc	ra,0xffffe
    80005e78:	e60080e7          	jalr	-416(ra) # 80003cd4 <iunlock>
  iput(p->cwd);
    80005e7c:	15093503          	ld	a0,336(s2)
    80005e80:	ffffe097          	auipc	ra,0xffffe
    80005e84:	f4c080e7          	jalr	-180(ra) # 80003dcc <iput>
  end_op();
    80005e88:	ffffe097          	auipc	ra,0xffffe
    80005e8c:	7cc080e7          	jalr	1996(ra) # 80004654 <end_op>
  p->cwd = ip;
    80005e90:	14993823          	sd	s1,336(s2)
  return 0;
    80005e94:	4501                	li	a0,0
}
    80005e96:	60ea                	ld	ra,152(sp)
    80005e98:	644a                	ld	s0,144(sp)
    80005e9a:	64aa                	ld	s1,136(sp)
    80005e9c:	690a                	ld	s2,128(sp)
    80005e9e:	610d                	addi	sp,sp,160
    80005ea0:	8082                	ret
    end_op();
    80005ea2:	ffffe097          	auipc	ra,0xffffe
    80005ea6:	7b2080e7          	jalr	1970(ra) # 80004654 <end_op>
    return -1;
    80005eaa:	557d                	li	a0,-1
    80005eac:	b7ed                	j	80005e96 <sys_chdir+0x7a>
    iunlockput(ip);
    80005eae:	8526                	mv	a0,s1
    80005eb0:	ffffe097          	auipc	ra,0xffffe
    80005eb4:	fc4080e7          	jalr	-60(ra) # 80003e74 <iunlockput>
    end_op();
    80005eb8:	ffffe097          	auipc	ra,0xffffe
    80005ebc:	79c080e7          	jalr	1948(ra) # 80004654 <end_op>
    return -1;
    80005ec0:	557d                	li	a0,-1
    80005ec2:	bfd1                	j	80005e96 <sys_chdir+0x7a>

0000000080005ec4 <sys_exec>:

uint64
sys_exec(void)
{
    80005ec4:	7145                	addi	sp,sp,-464
    80005ec6:	e786                	sd	ra,456(sp)
    80005ec8:	e3a2                	sd	s0,448(sp)
    80005eca:	ff26                	sd	s1,440(sp)
    80005ecc:	fb4a                	sd	s2,432(sp)
    80005ece:	f74e                	sd	s3,424(sp)
    80005ed0:	f352                	sd	s4,416(sp)
    80005ed2:	ef56                	sd	s5,408(sp)
    80005ed4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ed6:	e3840593          	addi	a1,s0,-456
    80005eda:	4505                	li	a0,1
    80005edc:	ffffd097          	auipc	ra,0xffffd
    80005ee0:	080080e7          	jalr	128(ra) # 80002f5c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ee4:	08000613          	li	a2,128
    80005ee8:	f4040593          	addi	a1,s0,-192
    80005eec:	4501                	li	a0,0
    80005eee:	ffffd097          	auipc	ra,0xffffd
    80005ef2:	090080e7          	jalr	144(ra) # 80002f7e <argstr>
    80005ef6:	87aa                	mv	a5,a0
    return -1;
    80005ef8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005efa:	0c07c263          	bltz	a5,80005fbe <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005efe:	10000613          	li	a2,256
    80005f02:	4581                	li	a1,0
    80005f04:	e4040513          	addi	a0,s0,-448
    80005f08:	ffffb097          	auipc	ra,0xffffb
    80005f0c:	dde080e7          	jalr	-546(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f10:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f14:	89a6                	mv	s3,s1
    80005f16:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f18:	02000a13          	li	s4,32
    80005f1c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f20:	00391513          	slli	a0,s2,0x3
    80005f24:	e3040593          	addi	a1,s0,-464
    80005f28:	e3843783          	ld	a5,-456(s0)
    80005f2c:	953e                	add	a0,a0,a5
    80005f2e:	ffffd097          	auipc	ra,0xffffd
    80005f32:	f6e080e7          	jalr	-146(ra) # 80002e9c <fetchaddr>
    80005f36:	02054a63          	bltz	a0,80005f6a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f3a:	e3043783          	ld	a5,-464(s0)
    80005f3e:	c3b9                	beqz	a5,80005f84 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f40:	ffffb097          	auipc	ra,0xffffb
    80005f44:	bba080e7          	jalr	-1094(ra) # 80000afa <kalloc>
    80005f48:	85aa                	mv	a1,a0
    80005f4a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f4e:	cd11                	beqz	a0,80005f6a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f50:	6605                	lui	a2,0x1
    80005f52:	e3043503          	ld	a0,-464(s0)
    80005f56:	ffffd097          	auipc	ra,0xffffd
    80005f5a:	f98080e7          	jalr	-104(ra) # 80002eee <fetchstr>
    80005f5e:	00054663          	bltz	a0,80005f6a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f62:	0905                	addi	s2,s2,1
    80005f64:	09a1                	addi	s3,s3,8
    80005f66:	fb491be3          	bne	s2,s4,80005f1c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f6a:	10048913          	addi	s2,s1,256
    80005f6e:	6088                	ld	a0,0(s1)
    80005f70:	c531                	beqz	a0,80005fbc <sys_exec+0xf8>
    kfree(argv[i]);
    80005f72:	ffffb097          	auipc	ra,0xffffb
    80005f76:	a8c080e7          	jalr	-1396(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f7a:	04a1                	addi	s1,s1,8
    80005f7c:	ff2499e3          	bne	s1,s2,80005f6e <sys_exec+0xaa>
  return -1;
    80005f80:	557d                	li	a0,-1
    80005f82:	a835                	j	80005fbe <sys_exec+0xfa>
      argv[i] = 0;
    80005f84:	0a8e                	slli	s5,s5,0x3
    80005f86:	fc040793          	addi	a5,s0,-64
    80005f8a:	9abe                	add	s5,s5,a5
    80005f8c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f90:	e4040593          	addi	a1,s0,-448
    80005f94:	f4040513          	addi	a0,s0,-192
    80005f98:	fffff097          	auipc	ra,0xfffff
    80005f9c:	190080e7          	jalr	400(ra) # 80005128 <exec>
    80005fa0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fa2:	10048993          	addi	s3,s1,256
    80005fa6:	6088                	ld	a0,0(s1)
    80005fa8:	c901                	beqz	a0,80005fb8 <sys_exec+0xf4>
    kfree(argv[i]);
    80005faa:	ffffb097          	auipc	ra,0xffffb
    80005fae:	a54080e7          	jalr	-1452(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fb2:	04a1                	addi	s1,s1,8
    80005fb4:	ff3499e3          	bne	s1,s3,80005fa6 <sys_exec+0xe2>
  return ret;
    80005fb8:	854a                	mv	a0,s2
    80005fba:	a011                	j	80005fbe <sys_exec+0xfa>
  return -1;
    80005fbc:	557d                	li	a0,-1
}
    80005fbe:	60be                	ld	ra,456(sp)
    80005fc0:	641e                	ld	s0,448(sp)
    80005fc2:	74fa                	ld	s1,440(sp)
    80005fc4:	795a                	ld	s2,432(sp)
    80005fc6:	79ba                	ld	s3,424(sp)
    80005fc8:	7a1a                	ld	s4,416(sp)
    80005fca:	6afa                	ld	s5,408(sp)
    80005fcc:	6179                	addi	sp,sp,464
    80005fce:	8082                	ret

0000000080005fd0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005fd0:	7139                	addi	sp,sp,-64
    80005fd2:	fc06                	sd	ra,56(sp)
    80005fd4:	f822                	sd	s0,48(sp)
    80005fd6:	f426                	sd	s1,40(sp)
    80005fd8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005fda:	ffffc097          	auipc	ra,0xffffc
    80005fde:	9ec080e7          	jalr	-1556(ra) # 800019c6 <myproc>
    80005fe2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005fe4:	fd840593          	addi	a1,s0,-40
    80005fe8:	4501                	li	a0,0
    80005fea:	ffffd097          	auipc	ra,0xffffd
    80005fee:	f72080e7          	jalr	-142(ra) # 80002f5c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ff2:	fc840593          	addi	a1,s0,-56
    80005ff6:	fd040513          	addi	a0,s0,-48
    80005ffa:	fffff097          	auipc	ra,0xfffff
    80005ffe:	dd6080e7          	jalr	-554(ra) # 80004dd0 <pipealloc>
    return -1;
    80006002:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006004:	0c054463          	bltz	a0,800060cc <sys_pipe+0xfc>
  fd0 = -1;
    80006008:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000600c:	fd043503          	ld	a0,-48(s0)
    80006010:	fffff097          	auipc	ra,0xfffff
    80006014:	518080e7          	jalr	1304(ra) # 80005528 <fdalloc>
    80006018:	fca42223          	sw	a0,-60(s0)
    8000601c:	08054b63          	bltz	a0,800060b2 <sys_pipe+0xe2>
    80006020:	fc843503          	ld	a0,-56(s0)
    80006024:	fffff097          	auipc	ra,0xfffff
    80006028:	504080e7          	jalr	1284(ra) # 80005528 <fdalloc>
    8000602c:	fca42023          	sw	a0,-64(s0)
    80006030:	06054863          	bltz	a0,800060a0 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006034:	4691                	li	a3,4
    80006036:	fc440613          	addi	a2,s0,-60
    8000603a:	fd843583          	ld	a1,-40(s0)
    8000603e:	68a8                	ld	a0,80(s1)
    80006040:	ffffb097          	auipc	ra,0xffffb
    80006044:	644080e7          	jalr	1604(ra) # 80001684 <copyout>
    80006048:	02054063          	bltz	a0,80006068 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000604c:	4691                	li	a3,4
    8000604e:	fc040613          	addi	a2,s0,-64
    80006052:	fd843583          	ld	a1,-40(s0)
    80006056:	0591                	addi	a1,a1,4
    80006058:	68a8                	ld	a0,80(s1)
    8000605a:	ffffb097          	auipc	ra,0xffffb
    8000605e:	62a080e7          	jalr	1578(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006062:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006064:	06055463          	bgez	a0,800060cc <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006068:	fc442783          	lw	a5,-60(s0)
    8000606c:	07e9                	addi	a5,a5,26
    8000606e:	078e                	slli	a5,a5,0x3
    80006070:	97a6                	add	a5,a5,s1
    80006072:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006076:	fc042503          	lw	a0,-64(s0)
    8000607a:	0569                	addi	a0,a0,26
    8000607c:	050e                	slli	a0,a0,0x3
    8000607e:	94aa                	add	s1,s1,a0
    80006080:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006084:	fd043503          	ld	a0,-48(s0)
    80006088:	fffff097          	auipc	ra,0xfffff
    8000608c:	a18080e7          	jalr	-1512(ra) # 80004aa0 <fileclose>
    fileclose(wf);
    80006090:	fc843503          	ld	a0,-56(s0)
    80006094:	fffff097          	auipc	ra,0xfffff
    80006098:	a0c080e7          	jalr	-1524(ra) # 80004aa0 <fileclose>
    return -1;
    8000609c:	57fd                	li	a5,-1
    8000609e:	a03d                	j	800060cc <sys_pipe+0xfc>
    if(fd0 >= 0)
    800060a0:	fc442783          	lw	a5,-60(s0)
    800060a4:	0007c763          	bltz	a5,800060b2 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800060a8:	07e9                	addi	a5,a5,26
    800060aa:	078e                	slli	a5,a5,0x3
    800060ac:	94be                	add	s1,s1,a5
    800060ae:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800060b2:	fd043503          	ld	a0,-48(s0)
    800060b6:	fffff097          	auipc	ra,0xfffff
    800060ba:	9ea080e7          	jalr	-1558(ra) # 80004aa0 <fileclose>
    fileclose(wf);
    800060be:	fc843503          	ld	a0,-56(s0)
    800060c2:	fffff097          	auipc	ra,0xfffff
    800060c6:	9de080e7          	jalr	-1570(ra) # 80004aa0 <fileclose>
    return -1;
    800060ca:	57fd                	li	a5,-1
}
    800060cc:	853e                	mv	a0,a5
    800060ce:	70e2                	ld	ra,56(sp)
    800060d0:	7442                	ld	s0,48(sp)
    800060d2:	74a2                	ld	s1,40(sp)
    800060d4:	6121                	addi	sp,sp,64
    800060d6:	8082                	ret
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
    80006120:	c7bfc0ef          	jal	ra,80002d9a <kerneltrap>
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
