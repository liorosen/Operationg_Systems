
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a9010113          	addi	sp,sp,-1392 # 80008a90 <stack0>
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
    80000056:	8fe70713          	addi	a4,a4,-1794 # 80008950 <timer_scratch>
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
    80000068:	05c78793          	addi	a5,a5,92 # 800060c0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc23f>
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
    80000190:	90450513          	addi	a0,a0,-1788 # 80010a90 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	8f448493          	addi	s1,s1,-1804 # 80010a90 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	98290913          	addi	s2,s2,-1662 # 80010b28 <cons+0x98>
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
    8000022e:	86650513          	addi	a0,a0,-1946 # 80010a90 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	85050513          	addi	a0,a0,-1968 # 80010a90 <cons>
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
    8000027c:	8af72823          	sw	a5,-1872(a4) # 80010b28 <cons+0x98>
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
    800002d2:	00010517          	auipc	a0,0x10
    800002d6:	7be50513          	addi	a0,a0,1982 # 80010a90 <cons>
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
    80000300:	00010517          	auipc	a0,0x10
    80000304:	79050513          	addi	a0,a0,1936 # 80010a90 <cons>
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
    80000324:	00010717          	auipc	a4,0x10
    80000328:	76c70713          	addi	a4,a4,1900 # 80010a90 <cons>
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
    8000034e:	00010797          	auipc	a5,0x10
    80000352:	74278793          	addi	a5,a5,1858 # 80010a90 <cons>
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
    8000037c:	00010797          	auipc	a5,0x10
    80000380:	7ac7a783          	lw	a5,1964(a5) # 80010b28 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00010717          	auipc	a4,0x10
    80000394:	70070713          	addi	a4,a4,1792 # 80010a90 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00010497          	auipc	s1,0x10
    800003a4:	6f048493          	addi	s1,s1,1776 # 80010a90 <cons>
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
    800003dc:	00010717          	auipc	a4,0x10
    800003e0:	6b470713          	addi	a4,a4,1716 # 80010a90 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00010717          	auipc	a4,0x10
    800003f6:	72f72f23          	sw	a5,1854(a4) # 80010b30 <cons+0xa0>
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
    80000418:	00010797          	auipc	a5,0x10
    8000041c:	67878793          	addi	a5,a5,1656 # 80010a90 <cons>
    80000420:	0a07a703          	lw	a4,160(a5)
    80000424:	0017069b          	addiw	a3,a4,1
    80000428:	0006861b          	sext.w	a2,a3
    8000042c:	0ad7a023          	sw	a3,160(a5)
    80000430:	07f77713          	andi	a4,a4,127
    80000434:	97ba                	add	a5,a5,a4
    80000436:	4729                	li	a4,10
    80000438:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043c:	00010797          	auipc	a5,0x10
    80000440:	6ec7a823          	sw	a2,1776(a5) # 80010b2c <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00010517          	auipc	a0,0x10
    80000448:	6e450513          	addi	a0,a0,1764 # 80010b28 <cons+0x98>
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
    8000046a:	62a50513          	addi	a0,a0,1578 # 80010a90 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00021797          	auipc	a5,0x21
    80000482:	faa78793          	addi	a5,a5,-86 # 80021428 <devsw>
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
    80000554:	6007a023          	sw	zero,1536(a5) # 80010b50 <pr+0x18>
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
    80000588:	38f72623          	sw	a5,908(a4) # 80008910 <panicked>
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
    800005c4:	590dad83          	lw	s11,1424(s11) # 80010b50 <pr+0x18>
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
    80000602:	53a50513          	addi	a0,a0,1338 # 80010b38 <pr>
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
    80000766:	3d650513          	addi	a0,a0,982 # 80010b38 <pr>
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
    80000782:	3ba48493          	addi	s1,s1,954 # 80010b38 <pr>
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
    800007e2:	37a50513          	addi	a0,a0,890 # 80010b58 <uart_tx_lock>
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
    8000080e:	1067a783          	lw	a5,262(a5) # 80008910 <panicked>
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
    8000084a:	0d273703          	ld	a4,210(a4) # 80008918 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	0d27b783          	ld	a5,210(a5) # 80008920 <uart_tx_w>
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
    80000874:	2e8a0a13          	addi	s4,s4,744 # 80010b58 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	0a048493          	addi	s1,s1,160 # 80008918 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	0a098993          	addi	s3,s3,160 # 80008920 <uart_tx_w>
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
    800008e6:	27650513          	addi	a0,a0,630 # 80010b58 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	01e7a783          	lw	a5,30(a5) # 80008910 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	0247b783          	ld	a5,36(a5) # 80008920 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	01473703          	ld	a4,20(a4) # 80008918 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	248a0a13          	addi	s4,s4,584 # 80010b58 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	00048493          	mv	s1,s1
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	00090913          	mv	s2,s2
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00001097          	auipc	ra,0x1
    80000934:	73a080e7          	jalr	1850(ra) # 8000206a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2) # 80008920 <uart_tx_w>
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	21248493          	addi	s1,s1,530 # 80010b58 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	fcf73323          	sd	a5,-58(a4) # 80008920 <uart_tx_w>
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
    800009d4:	18848493          	addi	s1,s1,392 # 80010b58 <uart_tx_lock>
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
    80000a16:	bae78793          	addi	a5,a5,-1106 # 800225c0 <end>
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
    80000a36:	15e90913          	addi	s2,s2,350 # 80010b90 <kmem>
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
    80000ad2:	0c250513          	addi	a0,a0,194 # 80010b90 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00022517          	auipc	a0,0x22
    80000ae6:	ade50513          	addi	a0,a0,-1314 # 800225c0 <end>
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
    80000b08:	08c48493          	addi	s1,s1,140 # 80010b90 <kmem>
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
    80000b20:	07450513          	addi	a0,a0,116 # 80010b90 <kmem>
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
    80000b4c:	04850513          	addi	a0,a0,72 # 80010b90 <kmem>
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
    80000ea8:	a8470713          	addi	a4,a4,-1404 # 80008928 <started>
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
    80000ede:	b5e080e7          	jalr	-1186(ra) # 80002a38 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	21e080e7          	jalr	542(ra) # 80006100 <plicinithart>
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
    80000f56:	abe080e7          	jalr	-1346(ra) # 80002a10 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	ade080e7          	jalr	-1314(ra) # 80002a38 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	188080e7          	jalr	392(ra) # 800060ea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	196080e7          	jalr	406(ra) # 80006100 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	348080e7          	jalr	840(ra) # 800032ba <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	9ec080e7          	jalr	-1556(ra) # 80003966 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	98a080e7          	jalr	-1654(ra) # 8000490c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	27e080e7          	jalr	638(ra) # 80006208 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	d0c080e7          	jalr	-756(ra) # 80001c9e <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	98f72423          	sw	a5,-1656(a4) # 80008928 <started>
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
    80000fb8:	97c7b783          	ld	a5,-1668(a5) # 80008930 <kernel_pagetable>
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
    80001270:	00007797          	auipc	a5,0x7
    80001274:	6ca7b023          	sd	a0,1728(a5) # 80008930 <kernel_pagetable>
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
    80001866:	0000f497          	auipc	s1,0xf
    8000186a:	77a48493          	addi	s1,s1,1914 # 80010fe0 <proc>
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
    80001884:	960a0a13          	addi	s4,s4,-1696 # 800171e0 <tickslock>
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
    80001906:	2ae50513          	addi	a0,a0,686 # 80010bb0 <pid_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	250080e7          	jalr	592(ra) # 80000b5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001912:	00007597          	auipc	a1,0x7
    80001916:	8d658593          	addi	a1,a1,-1834 # 800081e8 <digits+0x1a8>
    8000191a:	0000f517          	auipc	a0,0xf
    8000191e:	2ae50513          	addi	a0,a0,686 # 80010bc8 <wait_lock>
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	238080e7          	jalr	568(ra) # 80000b5a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192a:	0000f497          	auipc	s1,0xf
    8000192e:	6b648493          	addi	s1,s1,1718 # 80010fe0 <proc>
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
    80001950:	89498993          	addi	s3,s3,-1900 # 800171e0 <tickslock>
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
    800019ba:	22a50513          	addi	a0,a0,554 # 80010be0 <cpus>
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
    800019e2:	1d270713          	addi	a4,a4,466 # 80010bb0 <pid_lock>
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
    80001a1a:	eaa7a783          	lw	a5,-342(a5) # 800088c0 <first.1713>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	030080e7          	jalr	48(ra) # 80002a50 <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	e807a823          	sw	zero,-368(a5) # 800088c0 <first.1713>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	eac080e7          	jalr	-340(ra) # 800038e6 <fsinit>
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
    80001a54:	16090913          	addi	s2,s2,352 # 80010bb0 <pid_lock>
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	190080e7          	jalr	400(ra) # 80000bea <acquire>
  pid = nextpid;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	e6278793          	addi	a5,a5,-414 # 800088c4 <nextpid>
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
    80001be0:	40448493          	addi	s1,s1,1028 # 80010fe0 <proc>
    80001be4:	00015917          	auipc	s2,0x15
    80001be8:	5fc90913          	addi	s2,s2,1532 # 800171e0 <tickslock>
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
    80001cb6:	c8a7b323          	sd	a0,-890(a5) # 80008938 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cba:	03400613          	li	a2,52
    80001cbe:	00007597          	auipc	a1,0x7
    80001cc2:	c1258593          	addi	a1,a1,-1006 # 800088d0 <initcode>
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
    80001d00:	60c080e7          	jalr	1548(ra) # 80004308 <namei>
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
    80001e1e:	b84080e7          	jalr	-1148(ra) # 8000499e <filedup>
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
    80001e40:	ce8080e7          	jalr	-792(ra) # 80003b24 <idup>
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
    80001e6c:	d6048493          	addi	s1,s1,-672 # 80010bc8 <wait_lock>
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
    80001ed8:	cdc70713          	addi	a4,a4,-804 # 80010bb0 <pid_lock>
    80001edc:	9756                	add	a4,a4,s5
    80001ede:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ee2:	0000f717          	auipc	a4,0xf
    80001ee6:	d0670713          	addi	a4,a4,-762 # 80010be8 <cpus+0x8>
    80001eea:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001eec:	498d                	li	s3,3
        p->state = RUNNING;
    80001eee:	4b11                	li	s6,4
        c->proc = p;
    80001ef0:	079e                	slli	a5,a5,0x7
    80001ef2:	0000fa17          	auipc	s4,0xf
    80001ef6:	cbea0a13          	addi	s4,s4,-834 # 80010bb0 <pid_lock>
    80001efa:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001efc:	00015917          	auipc	s2,0x15
    80001f00:	2e490913          	addi	s2,s2,740 # 800171e0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f04:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f08:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f0c:	10079073          	csrw	sstatus,a5
    80001f10:	0000f497          	auipc	s1,0xf
    80001f14:	0d048493          	addi	s1,s1,208 # 80010fe0 <proc>
    80001f18:	a03d                	j	80001f46 <scheduler+0x8e>
        p->state = RUNNING;
    80001f1a:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f1e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f22:	06048593          	addi	a1,s1,96
    80001f26:	8556                	mv	a0,s5
    80001f28:	00001097          	auipc	ra,0x1
    80001f2c:	a7e080e7          	jalr	-1410(ra) # 800029a6 <swtch>
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
    80001f84:	c3070713          	addi	a4,a4,-976 # 80010bb0 <pid_lock>
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
    80001faa:	c0a90913          	addi	s2,s2,-1014 # 80010bb0 <pid_lock>
    80001fae:	2781                	sext.w	a5,a5
    80001fb0:	079e                	slli	a5,a5,0x7
    80001fb2:	97ca                	add	a5,a5,s2
    80001fb4:	0ac7a983          	lw	s3,172(a5)
    80001fb8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fba:	2781                	sext.w	a5,a5
    80001fbc:	079e                	slli	a5,a5,0x7
    80001fbe:	0000f597          	auipc	a1,0xf
    80001fc2:	c2a58593          	addi	a1,a1,-982 # 80010be8 <cpus+0x8>
    80001fc6:	95be                	add	a1,a1,a5
    80001fc8:	06048513          	addi	a0,s1,96
    80001fcc:	00001097          	auipc	ra,0x1
    80001fd0:	9da080e7          	jalr	-1574(ra) # 800029a6 <swtch>
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
    800020e6:	efe48493          	addi	s1,s1,-258 # 80010fe0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020ea:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020ec:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020ee:	00015917          	auipc	s2,0x15
    800020f2:	0f290913          	addi	s2,s2,242 # 800171e0 <tickslock>
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
    8000215a:	e8a48493          	addi	s1,s1,-374 # 80010fe0 <proc>
      pp->parent = initproc;
    8000215e:	00006a17          	auipc	s4,0x6
    80002162:	7daa0a13          	addi	s4,s4,2010 # 80008938 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002166:	00015997          	auipc	s3,0x15
    8000216a:	07a98993          	addi	s3,s3,122 # 800171e0 <tickslock>
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
    800021b6:	00006797          	auipc	a5,0x6
    800021ba:	7827b783          	ld	a5,1922(a5) # 80008938 <initproc>
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
    800021f4:	00002097          	auipc	ra,0x2
    800021f8:	7fc080e7          	jalr	2044(ra) # 800049f0 <fileclose>
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
    80002210:	318080e7          	jalr	792(ra) # 80004524 <begin_op>
  iput(p->cwd);
    80002214:	1509b503          	ld	a0,336(s3)
    80002218:	00002097          	auipc	ra,0x2
    8000221c:	b04080e7          	jalr	-1276(ra) # 80003d1c <iput>
  end_op();
    80002220:	00002097          	auipc	ra,0x2
    80002224:	384080e7          	jalr	900(ra) # 800045a4 <end_op>
  p->cwd = 0;
    80002228:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000222c:	0000f497          	auipc	s1,0xf
    80002230:	99c48493          	addi	s1,s1,-1636 # 80010bc8 <wait_lock>
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
    80002302:	ce248493          	addi	s1,s1,-798 # 80010fe0 <proc>
    80002306:	00015997          	auipc	s3,0x15
    8000230a:	eda98993          	addi	s3,s3,-294 # 800171e0 <tickslock>
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
    800023e6:	0000e517          	auipc	a0,0xe
    800023ea:	7e250513          	addi	a0,a0,2018 # 80010bc8 <wait_lock>
    800023ee:	ffffe097          	auipc	ra,0xffffe
    800023f2:	7fc080e7          	jalr	2044(ra) # 80000bea <acquire>
    havekids = 0;
    800023f6:	4c01                	li	s8,0
        if(pp->state == ZOMBIE){
    800023f8:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023fa:	00015997          	auipc	s3,0x15
    800023fe:	de698993          	addi	s3,s3,-538 # 800171e0 <tickslock>
        havekids = 1;
    80002402:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002404:	0000ec97          	auipc	s9,0xe
    80002408:	7c4c8c93          	addi	s9,s9,1988 # 80010bc8 <wait_lock>
    havekids = 0;
    8000240c:	8762                	mv	a4,s8
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000240e:	0000f497          	auipc	s1,0xf
    80002412:	bd248493          	addi	s1,s1,-1070 # 80010fe0 <proc>
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
    80002478:	0000e517          	auipc	a0,0xe
    8000247c:	75050513          	addi	a0,a0,1872 # 80010bc8 <wait_lock>
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	81e080e7          	jalr	-2018(ra) # 80000c9e <release>
          return pid;
    80002488:	a045                	j	80002528 <wait+0x16a>
            release(&pp->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	812080e7          	jalr	-2030(ra) # 80000c9e <release>
            release(&wait_lock);
    80002494:	0000e517          	auipc	a0,0xe
    80002498:	73450513          	addi	a0,a0,1844 # 80010bc8 <wait_lock>
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
    800024b2:	0000e517          	auipc	a0,0xe
    800024b6:	71650513          	addi	a0,a0,1814 # 80010bc8 <wait_lock>
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
    80002516:	0000e517          	auipc	a0,0xe
    8000251a:	6b250513          	addi	a0,a0,1714 # 80010bc8 <wait_lock>
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
    80002628:	b1448493          	addi	s1,s1,-1260 # 80011138 <proc+0x158>
    8000262c:	00015917          	auipc	s2,0x15
    80002630:	d0c90913          	addi	s2,s2,-756 # 80017338 <bcache+0x140>
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
    80002652:	cdab8b93          	addi	s7,s7,-806 # 80008328 <states.1757>
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
    800026ca:	8d2a                	mv	s10,a0
    800026cc:	8b2e                	mv	s6,a1
    800026ce:	f8b43023          	sd	a1,-128(s0)
  struct proc *p = myproc();
    800026d2:	fffff097          	auipc	ra,0xfffff
    800026d6:	2f4080e7          	jalr	756(ra) # 800019c6 <myproc>
  struct proc *np;
  int i;

  if (n < 1 || n > 16)
    800026da:	3d7d                	addiw	s10,s10,-1
    800026dc:	000d071b          	sext.w	a4,s10
    800026e0:	47bd                	li	a5,15
    800026e2:	18e7e063          	bltu	a5,a4,80002862 <forkn+0x1b6>
    800026e6:	89aa                	mv	s3,a0
    800026e8:	8dda                	mv	s11,s6
    800026ea:	1d02                	slli	s10,s10,0x20
    800026ec:	020d5d13          	srli	s10,s10,0x20
    800026f0:	4a81                	li	s5,0
    }

    *(np->trapframe) = *(p->trapframe);
    np->trapframe->a0 = i + 1;  // child id

    for (int fd = 0; fd < NOFILE; fd++)
    800026f2:	15000a13          	li	s4,336
      if (p->ofile[fd])
        np->ofile[fd] = filedup(p->ofile[fd]);

    np->cwd = idup(p->cwd);
    safestrcpy(np->name, p->name, sizeof(p->name));
    800026f6:	15850793          	addi	a5,a0,344
    800026fa:	f8f43423          	sd	a5,-120(s0)

    acquire(&wait_lock);
    800026fe:	0000ec97          	auipc	s9,0xe
    80002702:	4cac8c93          	addi	s9,s9,1226 # 80010bc8 <wait_lock>
    80002706:	a8c5                	j	800027f6 <forkn+0x14a>
      for(int j=0; j<i; j++)
    80002708:	15805f63          	blez	s8,80002866 <forkn+0x1ba>
    8000270c:	fffa849b          	addiw	s1,s5,-1
    80002710:	1482                	slli	s1,s1,0x20
    80002712:	9081                	srli	s1,s1,0x20
    80002714:	048a                	slli	s1,s1,0x2
    80002716:	f8043783          	ld	a5,-128(s0)
    8000271a:	0791                	addi	a5,a5,4
    8000271c:	94be                	add	s1,s1,a5
        kill(pids[j]);
    8000271e:	000da503          	lw	a0,0(s11)
    80002722:	00000097          	auipc	ra,0x0
    80002726:	bcc080e7          	jalr	-1076(ra) # 800022ee <kill>
      for(int j=0; j<i; j++)
    8000272a:	0d91                	addi	s11,s11,4
    8000272c:	fe9d99e3          	bne	s11,s1,8000271e <forkn+0x72>
      return -1;
    80002730:	557d                	li	a0,-1
    80002732:	a821                	j	8000274a <forkn+0x9e>
      freeproc(np);
    80002734:	854a                	mv	a0,s2
    80002736:	fffff097          	auipc	ra,0xfffff
    8000273a:	442080e7          	jalr	1090(ra) # 80001b78 <freeproc>
      release(&np->lock);
    8000273e:	854a                	mv	a0,s2
    80002740:	ffffe097          	auipc	ra,0xffffe
    80002744:	55e080e7          	jalr	1374(ra) # 80000c9e <release>
      return -1;
    80002748:	557d                	li	a0,-1
    printf("Successfully created child process %d with PID %d\n", i, np->pid);
  }

  return 0; // Parent process will receive 0

} 
    8000274a:	70e6                	ld	ra,120(sp)
    8000274c:	7446                	ld	s0,112(sp)
    8000274e:	74a6                	ld	s1,104(sp)
    80002750:	7906                	ld	s2,96(sp)
    80002752:	69e6                	ld	s3,88(sp)
    80002754:	6a46                	ld	s4,80(sp)
    80002756:	6aa6                	ld	s5,72(sp)
    80002758:	6b06                	ld	s6,64(sp)
    8000275a:	7be2                	ld	s7,56(sp)
    8000275c:	7c42                	ld	s8,48(sp)
    8000275e:	7ca2                	ld	s9,40(sp)
    80002760:	7d02                	ld	s10,32(sp)
    80002762:	6de2                	ld	s11,24(sp)
    80002764:	6109                	addi	sp,sp,128
    80002766:	8082                	ret
        np->ofile[fd] = filedup(p->ofile[fd]);
    80002768:	00002097          	auipc	ra,0x2
    8000276c:	236080e7          	jalr	566(ra) # 8000499e <filedup>
    80002770:	009907b3          	add	a5,s2,s1
    80002774:	e388                	sd	a0,0(a5)
    for (int fd = 0; fd < NOFILE; fd++)
    80002776:	04a1                	addi	s1,s1,8
    80002778:	01448763          	beq	s1,s4,80002786 <forkn+0xda>
      if (p->ofile[fd])
    8000277c:	009987b3          	add	a5,s3,s1
    80002780:	6388                	ld	a0,0(a5)
    80002782:	f17d                	bnez	a0,80002768 <forkn+0xbc>
    80002784:	bfcd                	j	80002776 <forkn+0xca>
    np->cwd = idup(p->cwd);
    80002786:	1509b503          	ld	a0,336(s3)
    8000278a:	00001097          	auipc	ra,0x1
    8000278e:	39a080e7          	jalr	922(ra) # 80003b24 <idup>
    80002792:	14a93823          	sd	a0,336(s2)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80002796:	4641                	li	a2,16
    80002798:	f8843583          	ld	a1,-120(s0)
    8000279c:	15890513          	addi	a0,s2,344
    800027a0:	ffffe097          	auipc	ra,0xffffe
    800027a4:	698080e7          	jalr	1688(ra) # 80000e38 <safestrcpy>
    acquire(&wait_lock);
    800027a8:	8566                	mv	a0,s9
    800027aa:	ffffe097          	auipc	ra,0xffffe
    800027ae:	440080e7          	jalr	1088(ra) # 80000bea <acquire>
    np->parent = p;
    800027b2:	03393c23          	sd	s3,56(s2)
    release(&wait_lock);
    800027b6:	8566                	mv	a0,s9
    800027b8:	ffffe097          	auipc	ra,0xffffe
    800027bc:	4e6080e7          	jalr	1254(ra) # 80000c9e <release>
    pids[i] = np->pid;
    800027c0:	03092783          	lw	a5,48(s2)
    800027c4:	00fb2023          	sw	a5,0(s6)
    np->state = RUNNABLE;
    800027c8:	478d                	li	a5,3
    800027ca:	00f92c23          	sw	a5,24(s2)
    release(&np->lock);
    800027ce:	854a                	mv	a0,s2
    800027d0:	ffffe097          	auipc	ra,0xffffe
    800027d4:	4ce080e7          	jalr	1230(ra) # 80000c9e <release>
    printf("Successfully created child process %d with PID %d\n", i, np->pid);
    800027d8:	03092603          	lw	a2,48(s2)
    800027dc:	85e2                	mv	a1,s8
    800027de:	00006517          	auipc	a0,0x6
    800027e2:	ae250513          	addi	a0,a0,-1310 # 800082c0 <digits+0x280>
    800027e6:	ffffe097          	auipc	ra,0xffffe
    800027ea:	da8080e7          	jalr	-600(ra) # 8000058e <printf>
  for (i = 0; i < n; i++) {
    800027ee:	0b11                	addi	s6,s6,4
    800027f0:	07aa8763          	beq	s5,s10,8000285e <forkn+0x1b2>
    800027f4:	8ade                	mv	s5,s7
    800027f6:	000a8c1b          	sext.w	s8,s5
    if ((np = allocproc()) == 0) {
    800027fa:	fffff097          	auipc	ra,0xfffff
    800027fe:	3d6080e7          	jalr	982(ra) # 80001bd0 <allocproc>
    80002802:	892a                	mv	s2,a0
    80002804:	d111                	beqz	a0,80002708 <forkn+0x5c>
    np->sz = p->sz;
    80002806:	0489b603          	ld	a2,72(s3)
    8000280a:	e530                	sd	a2,72(a0)
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    8000280c:	692c                	ld	a1,80(a0)
    8000280e:	0509b503          	ld	a0,80(s3)
    80002812:	fffff097          	auipc	ra,0xfffff
    80002816:	d6e080e7          	jalr	-658(ra) # 80001580 <uvmcopy>
    8000281a:	f0054de3          	bltz	a0,80002734 <forkn+0x88>
    *(np->trapframe) = *(p->trapframe);
    8000281e:	0589b683          	ld	a3,88(s3)
    80002822:	87b6                	mv	a5,a3
    80002824:	05893703          	ld	a4,88(s2)
    80002828:	12068693          	addi	a3,a3,288
    8000282c:	0007b803          	ld	a6,0(a5)
    80002830:	6788                	ld	a0,8(a5)
    80002832:	6b8c                	ld	a1,16(a5)
    80002834:	6f90                	ld	a2,24(a5)
    80002836:	01073023          	sd	a6,0(a4)
    8000283a:	e708                	sd	a0,8(a4)
    8000283c:	eb0c                	sd	a1,16(a4)
    8000283e:	ef10                	sd	a2,24(a4)
    80002840:	02078793          	addi	a5,a5,32
    80002844:	02070713          	addi	a4,a4,32
    80002848:	fed792e3          	bne	a5,a3,8000282c <forkn+0x180>
    np->trapframe->a0 = i + 1;  // child id
    8000284c:	05893783          	ld	a5,88(s2)
    80002850:	001a8b93          	addi	s7,s5,1
    80002854:	0777b823          	sd	s7,112(a5)
    80002858:	0d000493          	li	s1,208
    8000285c:	b705                	j	8000277c <forkn+0xd0>
  return 0; // Parent process will receive 0
    8000285e:	4501                	li	a0,0
    80002860:	b5ed                	j	8000274a <forkn+0x9e>
    return -1;
    80002862:	557d                	li	a0,-1
    80002864:	b5dd                	j	8000274a <forkn+0x9e>
      return -1;
    80002866:	557d                	li	a0,-1
    80002868:	b5cd                	j	8000274a <forkn+0x9e>

000000008000286a <waitall>:


int waitall(int *n, int *statuses) {
    8000286a:	7149                	addi	sp,sp,-368
    8000286c:	f686                	sd	ra,360(sp)
    8000286e:	f2a2                	sd	s0,352(sp)
    80002870:	eea6                	sd	s1,344(sp)
    80002872:	eaca                	sd	s2,336(sp)
    80002874:	e6ce                	sd	s3,328(sp)
    80002876:	e2d2                	sd	s4,320(sp)
    80002878:	fe56                	sd	s5,312(sp)
    8000287a:	fa5a                	sd	s6,304(sp)
    8000287c:	f65e                	sd	s7,296(sp)
    8000287e:	f262                	sd	s8,288(sp)
    80002880:	ee66                	sd	s9,280(sp)
    80002882:	ea6a                	sd	s10,272(sp)
    80002884:	1a80                	addi	s0,sp,368
    80002886:	8baa                	mv	s7,a0
    80002888:	8c2e                	mv	s8,a1
  struct proc *p = myproc();
    8000288a:	fffff097          	auipc	ra,0xfffff
    8000288e:	13c080e7          	jalr	316(ra) # 800019c6 <myproc>
    80002892:	892a                	mv	s2,a0
  int count = 0;
    80002894:	f8042e23          	sw	zero,-100(s0)
  int local_statuses[NPROC];

  acquire(&wait_lock);
    80002898:	0000e517          	auipc	a0,0xe
    8000289c:	33050513          	addi	a0,a0,816 # 80010bc8 <wait_lock>
    800028a0:	ffffe097          	auipc	ra,0xffffe
    800028a4:	34a080e7          	jalr	842(ra) # 80000bea <acquire>

  while(1) {
    int found = 0;
    800028a8:	4c81                	li	s9,0

    for(struct proc *pp = proc; pp < &proc[NPROC]; pp++) {
      acquire(&pp->lock);
      if(pp->parent == p && pp->state == ZOMBIE) {
    800028aa:	4a15                	li	s4,5
    for(struct proc *pp = proc; pp < &proc[NPROC]; pp++) {
    800028ac:	00015997          	auipc	s3,0x15
    800028b0:	93498993          	addi	s3,s3,-1740 # 800171e0 <tickslock>
        found = 1;
    800028b4:	4b05                	li	s6,1
    }

    if(count == *n || !found)
      break;

    sleep(p, &wait_lock);
    800028b6:	0000ed17          	auipc	s10,0xe
    800028ba:	312d0d13          	addi	s10,s10,786 # 80010bc8 <wait_lock>
    for(struct proc *pp = proc; pp < &proc[NPROC]; pp++) {
    800028be:	0000e497          	auipc	s1,0xe
    800028c2:	72248493          	addi	s1,s1,1826 # 80010fe0 <proc>
    int found = 0;
    800028c6:	8ae6                	mv	s5,s9
    800028c8:	a811                	j	800028dc <waitall+0x72>
      release(&pp->lock);
    800028ca:	8526                	mv	a0,s1
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	3d2080e7          	jalr	978(ra) # 80000c9e <release>
    for(struct proc *pp = proc; pp < &proc[NPROC]; pp++) {
    800028d4:	18848493          	addi	s1,s1,392
    800028d8:	05348663          	beq	s1,s3,80002924 <waitall+0xba>
      acquire(&pp->lock);
    800028dc:	8526                	mv	a0,s1
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	30c080e7          	jalr	780(ra) # 80000bea <acquire>
      if(pp->parent == p && pp->state == ZOMBIE) {
    800028e6:	7c9c                	ld	a5,56(s1)
    800028e8:	ff2791e3          	bne	a5,s2,800028ca <waitall+0x60>
    800028ec:	4c9c                	lw	a5,24(s1)
    800028ee:	fd479ee3          	bne	a5,s4,800028ca <waitall+0x60>
        local_statuses[count++] = pp->xstate;
    800028f2:	f9c42783          	lw	a5,-100(s0)
    800028f6:	0017871b          	addiw	a4,a5,1
    800028fa:	f8e42e23          	sw	a4,-100(s0)
    800028fe:	078a                	slli	a5,a5,0x2
    80002900:	fa040713          	addi	a4,s0,-96
    80002904:	97ba                	add	a5,a5,a4
    80002906:	54d8                	lw	a4,44(s1)
    80002908:	eee7ac23          	sw	a4,-264(a5)
        release(&pp->lock);
    8000290c:	8526                	mv	a0,s1
    8000290e:	ffffe097          	auipc	ra,0xffffe
    80002912:	390080e7          	jalr	912(ra) # 80000c9e <release>
        freeproc(pp);
    80002916:	8526                	mv	a0,s1
    80002918:	fffff097          	auipc	ra,0xfffff
    8000291c:	260080e7          	jalr	608(ra) # 80001b78 <freeproc>
        found = 1;
    80002920:	8ada                	mv	s5,s6
        continue;
    80002922:	bf4d                	j	800028d4 <waitall+0x6a>
    if(count == *n || !found)
    80002924:	000ba703          	lw	a4,0(s7)
    80002928:	f9c42783          	lw	a5,-100(s0)
    8000292c:	00f70463          	beq	a4,a5,80002934 <waitall+0xca>
    80002930:	060a9263          	bnez	s5,80002994 <waitall+0x12a>
  }

  release(&wait_lock);
    80002934:	0000e517          	auipc	a0,0xe
    80002938:	29450513          	addi	a0,a0,660 # 80010bc8 <wait_lock>
    8000293c:	ffffe097          	auipc	ra,0xffffe
    80002940:	362080e7          	jalr	866(ra) # 80000c9e <release>

  if(copyout(p->pagetable, (uint64)n, (char*)&count, sizeof(int)) < 0)
    80002944:	4691                	li	a3,4
    80002946:	f9c40613          	addi	a2,s0,-100
    8000294a:	85de                	mv	a1,s7
    8000294c:	05093503          	ld	a0,80(s2)
    80002950:	fffff097          	auipc	ra,0xfffff
    80002954:	d34080e7          	jalr	-716(ra) # 80001684 <copyout>
    80002958:	04054563          	bltz	a0,800029a2 <waitall+0x138>
    return -1;
  if(copyout(p->pagetable, (uint64)statuses, (char*)local_statuses, sizeof(int) * count) < 0)
    8000295c:	f9c42683          	lw	a3,-100(s0)
    80002960:	068a                	slli	a3,a3,0x2
    80002962:	e9840613          	addi	a2,s0,-360
    80002966:	85e2                	mv	a1,s8
    80002968:	05093503          	ld	a0,80(s2)
    8000296c:	fffff097          	auipc	ra,0xfffff
    80002970:	d18080e7          	jalr	-744(ra) # 80001684 <copyout>
    80002974:	41f5551b          	sraiw	a0,a0,0x1f
    return -1;

  return 0;
}
    80002978:	70b6                	ld	ra,360(sp)
    8000297a:	7416                	ld	s0,352(sp)
    8000297c:	64f6                	ld	s1,344(sp)
    8000297e:	6956                	ld	s2,336(sp)
    80002980:	69b6                	ld	s3,328(sp)
    80002982:	6a16                	ld	s4,320(sp)
    80002984:	7af2                	ld	s5,312(sp)
    80002986:	7b52                	ld	s6,304(sp)
    80002988:	7bb2                	ld	s7,296(sp)
    8000298a:	7c12                	ld	s8,288(sp)
    8000298c:	6cf2                	ld	s9,280(sp)
    8000298e:	6d52                	ld	s10,272(sp)
    80002990:	6175                	addi	sp,sp,368
    80002992:	8082                	ret
    sleep(p, &wait_lock);
    80002994:	85ea                	mv	a1,s10
    80002996:	854a                	mv	a0,s2
    80002998:	fffff097          	auipc	ra,0xfffff
    8000299c:	6d2080e7          	jalr	1746(ra) # 8000206a <sleep>
  while(1) {
    800029a0:	bf39                	j	800028be <waitall+0x54>
    return -1;
    800029a2:	557d                	li	a0,-1
    800029a4:	bfd1                	j	80002978 <waitall+0x10e>

00000000800029a6 <swtch>:
    800029a6:	00153023          	sd	ra,0(a0)
    800029aa:	00253423          	sd	sp,8(a0)
    800029ae:	e900                	sd	s0,16(a0)
    800029b0:	ed04                	sd	s1,24(a0)
    800029b2:	03253023          	sd	s2,32(a0)
    800029b6:	03353423          	sd	s3,40(a0)
    800029ba:	03453823          	sd	s4,48(a0)
    800029be:	03553c23          	sd	s5,56(a0)
    800029c2:	05653023          	sd	s6,64(a0)
    800029c6:	05753423          	sd	s7,72(a0)
    800029ca:	05853823          	sd	s8,80(a0)
    800029ce:	05953c23          	sd	s9,88(a0)
    800029d2:	07a53023          	sd	s10,96(a0)
    800029d6:	07b53423          	sd	s11,104(a0)
    800029da:	0005b083          	ld	ra,0(a1)
    800029de:	0085b103          	ld	sp,8(a1)
    800029e2:	6980                	ld	s0,16(a1)
    800029e4:	6d84                	ld	s1,24(a1)
    800029e6:	0205b903          	ld	s2,32(a1)
    800029ea:	0285b983          	ld	s3,40(a1)
    800029ee:	0305ba03          	ld	s4,48(a1)
    800029f2:	0385ba83          	ld	s5,56(a1)
    800029f6:	0405bb03          	ld	s6,64(a1)
    800029fa:	0485bb83          	ld	s7,72(a1)
    800029fe:	0505bc03          	ld	s8,80(a1)
    80002a02:	0585bc83          	ld	s9,88(a1)
    80002a06:	0605bd03          	ld	s10,96(a1)
    80002a0a:	0685bd83          	ld	s11,104(a1)
    80002a0e:	8082                	ret

0000000080002a10 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a10:	1141                	addi	sp,sp,-16
    80002a12:	e406                	sd	ra,8(sp)
    80002a14:	e022                	sd	s0,0(sp)
    80002a16:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a18:	00006597          	auipc	a1,0x6
    80002a1c:	94058593          	addi	a1,a1,-1728 # 80008358 <states.1757+0x30>
    80002a20:	00014517          	auipc	a0,0x14
    80002a24:	7c050513          	addi	a0,a0,1984 # 800171e0 <tickslock>
    80002a28:	ffffe097          	auipc	ra,0xffffe
    80002a2c:	132080e7          	jalr	306(ra) # 80000b5a <initlock>
}
    80002a30:	60a2                	ld	ra,8(sp)
    80002a32:	6402                	ld	s0,0(sp)
    80002a34:	0141                	addi	sp,sp,16
    80002a36:	8082                	ret

0000000080002a38 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a38:	1141                	addi	sp,sp,-16
    80002a3a:	e422                	sd	s0,8(sp)
    80002a3c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a3e:	00003797          	auipc	a5,0x3
    80002a42:	5f278793          	addi	a5,a5,1522 # 80006030 <kernelvec>
    80002a46:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a4a:	6422                	ld	s0,8(sp)
    80002a4c:	0141                	addi	sp,sp,16
    80002a4e:	8082                	ret

0000000080002a50 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a50:	1141                	addi	sp,sp,-16
    80002a52:	e406                	sd	ra,8(sp)
    80002a54:	e022                	sd	s0,0(sp)
    80002a56:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a58:	fffff097          	auipc	ra,0xfffff
    80002a5c:	f6e080e7          	jalr	-146(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a64:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a66:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a6a:	00004617          	auipc	a2,0x4
    80002a6e:	59660613          	addi	a2,a2,1430 # 80007000 <_trampoline>
    80002a72:	00004697          	auipc	a3,0x4
    80002a76:	58e68693          	addi	a3,a3,1422 # 80007000 <_trampoline>
    80002a7a:	8e91                	sub	a3,a3,a2
    80002a7c:	040007b7          	lui	a5,0x4000
    80002a80:	17fd                	addi	a5,a5,-1
    80002a82:	07b2                	slli	a5,a5,0xc
    80002a84:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a86:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a8a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a8c:	180026f3          	csrr	a3,satp
    80002a90:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a92:	6d38                	ld	a4,88(a0)
    80002a94:	6134                	ld	a3,64(a0)
    80002a96:	6585                	lui	a1,0x1
    80002a98:	96ae                	add	a3,a3,a1
    80002a9a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a9c:	6d38                	ld	a4,88(a0)
    80002a9e:	00000697          	auipc	a3,0x0
    80002aa2:	13068693          	addi	a3,a3,304 # 80002bce <usertrap>
    80002aa6:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002aa8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002aaa:	8692                	mv	a3,tp
    80002aac:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aae:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002ab2:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002ab6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aba:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002abe:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ac0:	6f18                	ld	a4,24(a4)
    80002ac2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ac6:	6928                	ld	a0,80(a0)
    80002ac8:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002aca:	00004717          	auipc	a4,0x4
    80002ace:	5d270713          	addi	a4,a4,1490 # 8000709c <userret>
    80002ad2:	8f11                	sub	a4,a4,a2
    80002ad4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002ad6:	577d                	li	a4,-1
    80002ad8:	177e                	slli	a4,a4,0x3f
    80002ada:	8d59                	or	a0,a0,a4
    80002adc:	9782                	jalr	a5
}
    80002ade:	60a2                	ld	ra,8(sp)
    80002ae0:	6402                	ld	s0,0(sp)
    80002ae2:	0141                	addi	sp,sp,16
    80002ae4:	8082                	ret

0000000080002ae6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002ae6:	1101                	addi	sp,sp,-32
    80002ae8:	ec06                	sd	ra,24(sp)
    80002aea:	e822                	sd	s0,16(sp)
    80002aec:	e426                	sd	s1,8(sp)
    80002aee:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002af0:	00014497          	auipc	s1,0x14
    80002af4:	6f048493          	addi	s1,s1,1776 # 800171e0 <tickslock>
    80002af8:	8526                	mv	a0,s1
    80002afa:	ffffe097          	auipc	ra,0xffffe
    80002afe:	0f0080e7          	jalr	240(ra) # 80000bea <acquire>
  ticks++;
    80002b02:	00006517          	auipc	a0,0x6
    80002b06:	e3e50513          	addi	a0,a0,-450 # 80008940 <ticks>
    80002b0a:	411c                	lw	a5,0(a0)
    80002b0c:	2785                	addiw	a5,a5,1
    80002b0e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b10:	fffff097          	auipc	ra,0xfffff
    80002b14:	5be080e7          	jalr	1470(ra) # 800020ce <wakeup>
  release(&tickslock);
    80002b18:	8526                	mv	a0,s1
    80002b1a:	ffffe097          	auipc	ra,0xffffe
    80002b1e:	184080e7          	jalr	388(ra) # 80000c9e <release>
}
    80002b22:	60e2                	ld	ra,24(sp)
    80002b24:	6442                	ld	s0,16(sp)
    80002b26:	64a2                	ld	s1,8(sp)
    80002b28:	6105                	addi	sp,sp,32
    80002b2a:	8082                	ret

0000000080002b2c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b2c:	1101                	addi	sp,sp,-32
    80002b2e:	ec06                	sd	ra,24(sp)
    80002b30:	e822                	sd	s0,16(sp)
    80002b32:	e426                	sd	s1,8(sp)
    80002b34:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b36:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b3a:	00074d63          	bltz	a4,80002b54 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b3e:	57fd                	li	a5,-1
    80002b40:	17fe                	slli	a5,a5,0x3f
    80002b42:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b44:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b46:	06f70363          	beq	a4,a5,80002bac <devintr+0x80>
  }
}
    80002b4a:	60e2                	ld	ra,24(sp)
    80002b4c:	6442                	ld	s0,16(sp)
    80002b4e:	64a2                	ld	s1,8(sp)
    80002b50:	6105                	addi	sp,sp,32
    80002b52:	8082                	ret
     (scause & 0xff) == 9){
    80002b54:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b58:	46a5                	li	a3,9
    80002b5a:	fed792e3          	bne	a5,a3,80002b3e <devintr+0x12>
    int irq = plic_claim();
    80002b5e:	00003097          	auipc	ra,0x3
    80002b62:	5da080e7          	jalr	1498(ra) # 80006138 <plic_claim>
    80002b66:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b68:	47a9                	li	a5,10
    80002b6a:	02f50763          	beq	a0,a5,80002b98 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b6e:	4785                	li	a5,1
    80002b70:	02f50963          	beq	a0,a5,80002ba2 <devintr+0x76>
    return 1;
    80002b74:	4505                	li	a0,1
    } else if(irq){
    80002b76:	d8f1                	beqz	s1,80002b4a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b78:	85a6                	mv	a1,s1
    80002b7a:	00005517          	auipc	a0,0x5
    80002b7e:	7e650513          	addi	a0,a0,2022 # 80008360 <states.1757+0x38>
    80002b82:	ffffe097          	auipc	ra,0xffffe
    80002b86:	a0c080e7          	jalr	-1524(ra) # 8000058e <printf>
      plic_complete(irq);
    80002b8a:	8526                	mv	a0,s1
    80002b8c:	00003097          	auipc	ra,0x3
    80002b90:	5d0080e7          	jalr	1488(ra) # 8000615c <plic_complete>
    return 1;
    80002b94:	4505                	li	a0,1
    80002b96:	bf55                	j	80002b4a <devintr+0x1e>
      uartintr();
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	e16080e7          	jalr	-490(ra) # 800009ae <uartintr>
    80002ba0:	b7ed                	j	80002b8a <devintr+0x5e>
      virtio_disk_intr();
    80002ba2:	00004097          	auipc	ra,0x4
    80002ba6:	ae4080e7          	jalr	-1308(ra) # 80006686 <virtio_disk_intr>
    80002baa:	b7c5                	j	80002b8a <devintr+0x5e>
    if(cpuid() == 0){
    80002bac:	fffff097          	auipc	ra,0xfffff
    80002bb0:	dee080e7          	jalr	-530(ra) # 8000199a <cpuid>
    80002bb4:	c901                	beqz	a0,80002bc4 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002bb6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002bba:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002bbc:	14479073          	csrw	sip,a5
    return 2;
    80002bc0:	4509                	li	a0,2
    80002bc2:	b761                	j	80002b4a <devintr+0x1e>
      clockintr();
    80002bc4:	00000097          	auipc	ra,0x0
    80002bc8:	f22080e7          	jalr	-222(ra) # 80002ae6 <clockintr>
    80002bcc:	b7ed                	j	80002bb6 <devintr+0x8a>

0000000080002bce <usertrap>:
{
    80002bce:	1101                	addi	sp,sp,-32
    80002bd0:	ec06                	sd	ra,24(sp)
    80002bd2:	e822                	sd	s0,16(sp)
    80002bd4:	e426                	sd	s1,8(sp)
    80002bd6:	e04a                	sd	s2,0(sp)
    80002bd8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bda:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bde:	1007f793          	andi	a5,a5,256
    80002be2:	e3b1                	bnez	a5,80002c26 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002be4:	00003797          	auipc	a5,0x3
    80002be8:	44c78793          	addi	a5,a5,1100 # 80006030 <kernelvec>
    80002bec:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bf0:	fffff097          	auipc	ra,0xfffff
    80002bf4:	dd6080e7          	jalr	-554(ra) # 800019c6 <myproc>
    80002bf8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002bfa:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bfc:	14102773          	csrr	a4,sepc
    80002c00:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c02:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c06:	47a1                	li	a5,8
    80002c08:	02f70763          	beq	a4,a5,80002c36 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002c0c:	00000097          	auipc	ra,0x0
    80002c10:	f20080e7          	jalr	-224(ra) # 80002b2c <devintr>
    80002c14:	892a                	mv	s2,a0
    80002c16:	c941                	beqz	a0,80002ca6 <usertrap+0xd8>
  if(killed(p))
    80002c18:	8526                	mv	a0,s1
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	772080e7          	jalr	1906(ra) # 8000238c <killed>
    80002c22:	cd21                	beqz	a0,80002c7a <usertrap+0xac>
    80002c24:	a099                	j	80002c6a <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002c26:	00005517          	auipc	a0,0x5
    80002c2a:	75a50513          	addi	a0,a0,1882 # 80008380 <states.1757+0x58>
    80002c2e:	ffffe097          	auipc	ra,0xffffe
    80002c32:	916080e7          	jalr	-1770(ra) # 80000544 <panic>
    if(killed(p))
    80002c36:	fffff097          	auipc	ra,0xfffff
    80002c3a:	756080e7          	jalr	1878(ra) # 8000238c <killed>
    80002c3e:	e939                	bnez	a0,80002c94 <usertrap+0xc6>
    p->trapframe->epc += 4;
    80002c40:	6cb8                	ld	a4,88(s1)
    80002c42:	6f1c                	ld	a5,24(a4)
    80002c44:	0791                	addi	a5,a5,4
    80002c46:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c48:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c4c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c50:	10079073          	csrw	sstatus,a5
    syscall();
    80002c54:	00000097          	auipc	ra,0x0
    80002c58:	2b2080e7          	jalr	690(ra) # 80002f06 <syscall>
  if(killed(p))
    80002c5c:	8526                	mv	a0,s1
    80002c5e:	fffff097          	auipc	ra,0xfffff
    80002c62:	72e080e7          	jalr	1838(ra) # 8000238c <killed>
    80002c66:	cd09                	beqz	a0,80002c80 <usertrap+0xb2>
    80002c68:	4901                	li	s2,0
    exit("killed");
    80002c6a:	00005517          	auipc	a0,0x5
    80002c6e:	79650513          	addi	a0,a0,1942 # 80008400 <states.1757+0xd8>
    80002c72:	fffff097          	auipc	ra,0xfffff
    80002c76:	52c080e7          	jalr	1324(ra) # 8000219e <exit>
  if(which_dev == 2)
    80002c7a:	4789                	li	a5,2
    80002c7c:	06f90263          	beq	s2,a5,80002ce0 <usertrap+0x112>
  usertrapret();
    80002c80:	00000097          	auipc	ra,0x0
    80002c84:	dd0080e7          	jalr	-560(ra) # 80002a50 <usertrapret>
}
    80002c88:	60e2                	ld	ra,24(sp)
    80002c8a:	6442                	ld	s0,16(sp)
    80002c8c:	64a2                	ld	s1,8(sp)
    80002c8e:	6902                	ld	s2,0(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret
      exit("syscall error");
    80002c94:	00005517          	auipc	a0,0x5
    80002c98:	70c50513          	addi	a0,a0,1804 # 800083a0 <states.1757+0x78>
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	502080e7          	jalr	1282(ra) # 8000219e <exit>
    80002ca4:	bf71                	j	80002c40 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ca6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002caa:	5890                	lw	a2,48(s1)
    80002cac:	00005517          	auipc	a0,0x5
    80002cb0:	70450513          	addi	a0,a0,1796 # 800083b0 <states.1757+0x88>
    80002cb4:	ffffe097          	auipc	ra,0xffffe
    80002cb8:	8da080e7          	jalr	-1830(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cbc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cc0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cc4:	00005517          	auipc	a0,0x5
    80002cc8:	71c50513          	addi	a0,a0,1820 # 800083e0 <states.1757+0xb8>
    80002ccc:	ffffe097          	auipc	ra,0xffffe
    80002cd0:	8c2080e7          	jalr	-1854(ra) # 8000058e <printf>
    setkilled(p);
    80002cd4:	8526                	mv	a0,s1
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	68a080e7          	jalr	1674(ra) # 80002360 <setkilled>
    80002cde:	bfbd                	j	80002c5c <usertrap+0x8e>
    yield();
    80002ce0:	fffff097          	auipc	ra,0xfffff
    80002ce4:	34e080e7          	jalr	846(ra) # 8000202e <yield>
    80002ce8:	bf61                	j	80002c80 <usertrap+0xb2>

0000000080002cea <kerneltrap>:
{
    80002cea:	1101                	addi	sp,sp,-32
    80002cec:	ec06                	sd	ra,24(sp)
    80002cee:	e822                	sd	s0,16(sp)
    80002cf0:	e426                	sd	s1,8(sp)
    80002cf2:	e04a                	sd	s2,0(sp)
    80002cf4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cf6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cfa:	100024f3          	csrr	s1,sstatus
  if((sstatus & SSTATUS_SPP) == 0)
    80002cfe:	1004f793          	andi	a5,s1,256
    80002d02:	c79d                	beqz	a5,80002d30 <kerneltrap+0x46>
    80002d04:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d08:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d0a:	eb9d                	bnez	a5,80002d40 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002d0c:	00000097          	auipc	ra,0x0
    80002d10:	e20080e7          	jalr	-480(ra) # 80002b2c <devintr>
    80002d14:	cd15                	beqz	a0,80002d50 <kerneltrap+0x66>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d16:	4789                	li	a5,2
    80002d18:	04f50463          	beq	a0,a5,80002d60 <kerneltrap+0x76>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d1c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d20:	10049073          	csrw	sstatus,s1
}
    80002d24:	60e2                	ld	ra,24(sp)
    80002d26:	6442                	ld	s0,16(sp)
    80002d28:	64a2                	ld	s1,8(sp)
    80002d2a:	6902                	ld	s2,0(sp)
    80002d2c:	6105                	addi	sp,sp,32
    80002d2e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d30:	00005517          	auipc	a0,0x5
    80002d34:	6d850513          	addi	a0,a0,1752 # 80008408 <states.1757+0xe0>
    80002d38:	ffffe097          	auipc	ra,0xffffe
    80002d3c:	80c080e7          	jalr	-2036(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d40:	00005517          	auipc	a0,0x5
    80002d44:	6f050513          	addi	a0,a0,1776 # 80008430 <states.1757+0x108>
    80002d48:	ffffd097          	auipc	ra,0xffffd
    80002d4c:	7fc080e7          	jalr	2044(ra) # 80000544 <panic>
    panic("kerneltrap");
    80002d50:	00005517          	auipc	a0,0x5
    80002d54:	70050513          	addi	a0,a0,1792 # 80008450 <states.1757+0x128>
    80002d58:	ffffd097          	auipc	ra,0xffffd
    80002d5c:	7ec080e7          	jalr	2028(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d60:	fffff097          	auipc	ra,0xfffff
    80002d64:	c66080e7          	jalr	-922(ra) # 800019c6 <myproc>
    80002d68:	d955                	beqz	a0,80002d1c <kerneltrap+0x32>
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	c5c080e7          	jalr	-932(ra) # 800019c6 <myproc>
    80002d72:	4d18                	lw	a4,24(a0)
    80002d74:	4791                	li	a5,4
    80002d76:	faf713e3          	bne	a4,a5,80002d1c <kerneltrap+0x32>
    yield();
    80002d7a:	fffff097          	auipc	ra,0xfffff
    80002d7e:	2b4080e7          	jalr	692(ra) # 8000202e <yield>
    80002d82:	bf69                	j	80002d1c <kerneltrap+0x32>

0000000080002d84 <argraw>:
    return -1;
  return strlen(buf);
}

static uint64 argraw(int n)
{
    80002d84:	1101                	addi	sp,sp,-32
    80002d86:	ec06                	sd	ra,24(sp)
    80002d88:	e822                	sd	s0,16(sp)
    80002d8a:	e426                	sd	s1,8(sp)
    80002d8c:	1000                	addi	s0,sp,32
    80002d8e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	c36080e7          	jalr	-970(ra) # 800019c6 <myproc>
  switch (n) {
    80002d98:	4795                	li	a5,5
    80002d9a:	0497e163          	bltu	a5,s1,80002ddc <argraw+0x58>
    80002d9e:	048a                	slli	s1,s1,0x2
    80002da0:	00005717          	auipc	a4,0x5
    80002da4:	6e870713          	addi	a4,a4,1768 # 80008488 <states.1757+0x160>
    80002da8:	94ba                	add	s1,s1,a4
    80002daa:	409c                	lw	a5,0(s1)
    80002dac:	97ba                	add	a5,a5,a4
    80002dae:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002db0:	6d3c                	ld	a5,88(a0)
    80002db2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002db4:	60e2                	ld	ra,24(sp)
    80002db6:	6442                	ld	s0,16(sp)
    80002db8:	64a2                	ld	s1,8(sp)
    80002dba:	6105                	addi	sp,sp,32
    80002dbc:	8082                	ret
    return p->trapframe->a1;
    80002dbe:	6d3c                	ld	a5,88(a0)
    80002dc0:	7fa8                	ld	a0,120(a5)
    80002dc2:	bfcd                	j	80002db4 <argraw+0x30>
    return p->trapframe->a2;
    80002dc4:	6d3c                	ld	a5,88(a0)
    80002dc6:	63c8                	ld	a0,128(a5)
    80002dc8:	b7f5                	j	80002db4 <argraw+0x30>
    return p->trapframe->a3;
    80002dca:	6d3c                	ld	a5,88(a0)
    80002dcc:	67c8                	ld	a0,136(a5)
    80002dce:	b7dd                	j	80002db4 <argraw+0x30>
    return p->trapframe->a4;
    80002dd0:	6d3c                	ld	a5,88(a0)
    80002dd2:	6bc8                	ld	a0,144(a5)
    80002dd4:	b7c5                	j	80002db4 <argraw+0x30>
    return p->trapframe->a5;
    80002dd6:	6d3c                	ld	a5,88(a0)
    80002dd8:	6fc8                	ld	a0,152(a5)
    80002dda:	bfe9                	j	80002db4 <argraw+0x30>
  panic("argraw");
    80002ddc:	00005517          	auipc	a0,0x5
    80002de0:	68450513          	addi	a0,a0,1668 # 80008460 <states.1757+0x138>
    80002de4:	ffffd097          	auipc	ra,0xffffd
    80002de8:	760080e7          	jalr	1888(ra) # 80000544 <panic>

0000000080002dec <fetchaddr>:
{
    80002dec:	1101                	addi	sp,sp,-32
    80002dee:	ec06                	sd	ra,24(sp)
    80002df0:	e822                	sd	s0,16(sp)
    80002df2:	e426                	sd	s1,8(sp)
    80002df4:	e04a                	sd	s2,0(sp)
    80002df6:	1000                	addi	s0,sp,32
    80002df8:	84aa                	mv	s1,a0
    80002dfa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dfc:	fffff097          	auipc	ra,0xfffff
    80002e00:	bca080e7          	jalr	-1078(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e04:	653c                	ld	a5,72(a0)
    80002e06:	02f4f863          	bgeu	s1,a5,80002e36 <fetchaddr+0x4a>
    80002e0a:	00848713          	addi	a4,s1,8
    80002e0e:	02e7e663          	bltu	a5,a4,80002e3a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e12:	46a1                	li	a3,8
    80002e14:	8626                	mv	a2,s1
    80002e16:	85ca                	mv	a1,s2
    80002e18:	6928                	ld	a0,80(a0)
    80002e1a:	fffff097          	auipc	ra,0xfffff
    80002e1e:	8f6080e7          	jalr	-1802(ra) # 80001710 <copyin>
    80002e22:	00a03533          	snez	a0,a0
    80002e26:	40a00533          	neg	a0,a0
}
    80002e2a:	60e2                	ld	ra,24(sp)
    80002e2c:	6442                	ld	s0,16(sp)
    80002e2e:	64a2                	ld	s1,8(sp)
    80002e30:	6902                	ld	s2,0(sp)
    80002e32:	6105                	addi	sp,sp,32
    80002e34:	8082                	ret
    return -1;
    80002e36:	557d                	li	a0,-1
    80002e38:	bfcd                	j	80002e2a <fetchaddr+0x3e>
    80002e3a:	557d                	li	a0,-1
    80002e3c:	b7fd                	j	80002e2a <fetchaddr+0x3e>

0000000080002e3e <fetchstr>:
{
    80002e3e:	7179                	addi	sp,sp,-48
    80002e40:	f406                	sd	ra,40(sp)
    80002e42:	f022                	sd	s0,32(sp)
    80002e44:	ec26                	sd	s1,24(sp)
    80002e46:	e84a                	sd	s2,16(sp)
    80002e48:	e44e                	sd	s3,8(sp)
    80002e4a:	1800                	addi	s0,sp,48
    80002e4c:	892a                	mv	s2,a0
    80002e4e:	84ae                	mv	s1,a1
    80002e50:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e52:	fffff097          	auipc	ra,0xfffff
    80002e56:	b74080e7          	jalr	-1164(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e5a:	86ce                	mv	a3,s3
    80002e5c:	864a                	mv	a2,s2
    80002e5e:	85a6                	mv	a1,s1
    80002e60:	6928                	ld	a0,80(a0)
    80002e62:	fffff097          	auipc	ra,0xfffff
    80002e66:	93a080e7          	jalr	-1734(ra) # 8000179c <copyinstr>
    80002e6a:	00054e63          	bltz	a0,80002e86 <fetchstr+0x48>
  return strlen(buf);
    80002e6e:	8526                	mv	a0,s1
    80002e70:	ffffe097          	auipc	ra,0xffffe
    80002e74:	ffa080e7          	jalr	-6(ra) # 80000e6a <strlen>
}
    80002e78:	70a2                	ld	ra,40(sp)
    80002e7a:	7402                	ld	s0,32(sp)
    80002e7c:	64e2                	ld	s1,24(sp)
    80002e7e:	6942                	ld	s2,16(sp)
    80002e80:	69a2                	ld	s3,8(sp)
    80002e82:	6145                	addi	sp,sp,48
    80002e84:	8082                	ret
    return -1;
    80002e86:	557d                	li	a0,-1
    80002e88:	bfc5                	j	80002e78 <fetchstr+0x3a>

0000000080002e8a <argint>:

// Fetch the nth 32-bit system call argument.
int argint(int n, int *ip)
{
    80002e8a:	1101                	addi	sp,sp,-32
    80002e8c:	ec06                	sd	ra,24(sp)
    80002e8e:	e822                	sd	s0,16(sp)
    80002e90:	e426                	sd	s1,8(sp)
    80002e92:	1000                	addi	s0,sp,32
    80002e94:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e96:	00000097          	auipc	ra,0x0
    80002e9a:	eee080e7          	jalr	-274(ra) # 80002d84 <argraw>
    80002e9e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002ea0:	4501                	li	a0,0
    80002ea2:	60e2                	ld	ra,24(sp)
    80002ea4:	6442                	ld	s0,16(sp)
    80002ea6:	64a2                	ld	s1,8(sp)
    80002ea8:	6105                	addi	sp,sp,32
    80002eaa:	8082                	ret

0000000080002eac <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int argaddr(int n, uint64 *ip)
{
    80002eac:	1101                	addi	sp,sp,-32
    80002eae:	ec06                	sd	ra,24(sp)
    80002eb0:	e822                	sd	s0,16(sp)
    80002eb2:	e426                	sd	s1,8(sp)
    80002eb4:	1000                	addi	s0,sp,32
    80002eb6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	ecc080e7          	jalr	-308(ra) # 80002d84 <argraw>
    80002ec0:	e088                	sd	a0,0(s1)
  return 0;
}
    80002ec2:	4501                	li	a0,0
    80002ec4:	60e2                	ld	ra,24(sp)
    80002ec6:	6442                	ld	s0,16(sp)
    80002ec8:	64a2                	ld	s1,8(sp)
    80002eca:	6105                	addi	sp,sp,32
    80002ecc:	8082                	ret

0000000080002ece <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002ece:	7179                	addi	sp,sp,-48
    80002ed0:	f406                	sd	ra,40(sp)
    80002ed2:	f022                	sd	s0,32(sp)
    80002ed4:	ec26                	sd	s1,24(sp)
    80002ed6:	e84a                	sd	s2,16(sp)
    80002ed8:	1800                	addi	s0,sp,48
    80002eda:	84ae                	mv	s1,a1
    80002edc:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ede:	fd840593          	addi	a1,s0,-40
    80002ee2:	00000097          	auipc	ra,0x0
    80002ee6:	fca080e7          	jalr	-54(ra) # 80002eac <argaddr>
  return fetchstr(addr, buf, max);
    80002eea:	864a                	mv	a2,s2
    80002eec:	85a6                	mv	a1,s1
    80002eee:	fd843503          	ld	a0,-40(s0)
    80002ef2:	00000097          	auipc	ra,0x0
    80002ef6:	f4c080e7          	jalr	-180(ra) # 80002e3e <fetchstr>
}
    80002efa:	70a2                	ld	ra,40(sp)
    80002efc:	7402                	ld	s0,32(sp)
    80002efe:	64e2                	ld	s1,24(sp)
    80002f00:	6942                	ld	s2,16(sp)
    80002f02:	6145                	addi	sp,sp,48
    80002f04:	8082                	ret

0000000080002f06 <syscall>:
[SYS_waitall] sys_waitall,
[SYS_exit_num] sys_exit_num,
};

void syscall(void)
{
    80002f06:	1101                	addi	sp,sp,-32
    80002f08:	ec06                	sd	ra,24(sp)
    80002f0a:	e822                	sd	s0,16(sp)
    80002f0c:	e426                	sd	s1,8(sp)
    80002f0e:	e04a                	sd	s2,0(sp)
    80002f10:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	ab4080e7          	jalr	-1356(ra) # 800019c6 <myproc>
    80002f1a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002f1c:	05853903          	ld	s2,88(a0)
    80002f20:	0a893783          	ld	a5,168(s2)
    80002f24:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f28:	37fd                	addiw	a5,a5,-1
    80002f2a:	4769                	li	a4,26
    80002f2c:	00f76f63          	bltu	a4,a5,80002f4a <syscall+0x44>
    80002f30:	00369713          	slli	a4,a3,0x3
    80002f34:	00005797          	auipc	a5,0x5
    80002f38:	56c78793          	addi	a5,a5,1388 # 800084a0 <syscalls>
    80002f3c:	97ba                	add	a5,a5,a4
    80002f3e:	639c                	ld	a5,0(a5)
    80002f40:	c789                	beqz	a5,80002f4a <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002f42:	9782                	jalr	a5
    80002f44:	06a93823          	sd	a0,112(s2)
    80002f48:	a839                	j	80002f66 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f4a:	15848613          	addi	a2,s1,344
    80002f4e:	588c                	lw	a1,48(s1)
    80002f50:	00005517          	auipc	a0,0x5
    80002f54:	51850513          	addi	a0,a0,1304 # 80008468 <states.1757+0x140>
    80002f58:	ffffd097          	auipc	ra,0xffffd
    80002f5c:	636080e7          	jalr	1590(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f60:	6cbc                	ld	a5,88(s1)
    80002f62:	577d                	li	a4,-1
    80002f64:	fbb8                	sd	a4,112(a5)
  }
}
    80002f66:	60e2                	ld	ra,24(sp)
    80002f68:	6442                	ld	s0,16(sp)
    80002f6a:	64a2                	ld	s1,8(sp)
    80002f6c:	6902                	ld	s2,0(sp)
    80002f6e:	6105                	addi	sp,sp,32
    80002f70:	8082                	ret

0000000080002f72 <sys_exit>:
// Add function declarations
extern struct proc* allocproc(void);
extern void freeproc(struct proc *p);

uint64 sys_exit(void)
{
    80002f72:	1101                	addi	sp,sp,-32
    80002f74:	ec06                	sd	ra,24(sp)
    80002f76:	e822                	sd	s0,16(sp)
    80002f78:	1000                	addi	s0,sp,32
  int status;
  argint(0, &status);
    80002f7a:	fec40593          	addi	a1,s0,-20
    80002f7e:	4501                	li	a0,0
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	f0a080e7          	jalr	-246(ra) # 80002e8a <argint>
  exit_num(status);  
    80002f88:	fec42503          	lw	a0,-20(s0)
    80002f8c:	fffff097          	auipc	ra,0xfffff
    80002f90:	2fe080e7          	jalr	766(ra) # 8000228a <exit_num>
  return 0; // never returns
}
    80002f94:	4501                	li	a0,0
    80002f96:	60e2                	ld	ra,24(sp)
    80002f98:	6442                	ld	s0,16(sp)
    80002f9a:	6105                	addi	sp,sp,32
    80002f9c:	8082                	ret

0000000080002f9e <sys_exitmsg>:

uint64 sys_exitmsg(void)
{
    80002f9e:	7179                	addi	sp,sp,-48
    80002fa0:	f406                	sd	ra,40(sp)
    80002fa2:	f022                	sd	s0,32(sp)
    80002fa4:	1800                	addi	s0,sp,48
  exit_msg(msg);
  return 0; // never returns
  */

  char msg[32];
  if (argstr(0, msg, sizeof(msg)) < 0)
    80002fa6:	02000613          	li	a2,32
    80002faa:	fd040593          	addi	a1,s0,-48
    80002fae:	4501                	li	a0,0
    80002fb0:	00000097          	auipc	ra,0x0
    80002fb4:	f1e080e7          	jalr	-226(ra) # 80002ece <argstr>
    return -1;
    80002fb8:	57fd                	li	a5,-1
  if (argstr(0, msg, sizeof(msg)) < 0)
    80002fba:	00054963          	bltz	a0,80002fcc <sys_exitmsg+0x2e>

  exit_msg(msg);
    80002fbe:	fd040513          	addi	a0,s0,-48
    80002fc2:	fffff097          	auipc	ra,0xfffff
    80002fc6:	2ee080e7          	jalr	750(ra) # 800022b0 <exit_msg>
  return 0;
    80002fca:	4781                	li	a5,0

  
}
    80002fcc:	853e                	mv	a0,a5
    80002fce:	70a2                	ld	ra,40(sp)
    80002fd0:	7402                	ld	s0,32(sp)
    80002fd2:	6145                	addi	sp,sp,48
    80002fd4:	8082                	ret

0000000080002fd6 <sys_getpid>:

uint64 sys_getpid(void)
{
    80002fd6:	1141                	addi	sp,sp,-16
    80002fd8:	e406                	sd	ra,8(sp)
    80002fda:	e022                	sd	s0,0(sp)
    80002fdc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002fde:	fffff097          	auipc	ra,0xfffff
    80002fe2:	9e8080e7          	jalr	-1560(ra) # 800019c6 <myproc>
}
    80002fe6:	5908                	lw	a0,48(a0)
    80002fe8:	60a2                	ld	ra,8(sp)
    80002fea:	6402                	ld	s0,0(sp)
    80002fec:	0141                	addi	sp,sp,16
    80002fee:	8082                	ret

0000000080002ff0 <sys_fork>:

uint64 sys_fork(void)
{
    80002ff0:	1141                	addi	sp,sp,-16
    80002ff2:	e406                	sd	ra,8(sp)
    80002ff4:	e022                	sd	s0,0(sp)
    80002ff6:	0800                	addi	s0,sp,16
  return fork();
    80002ff8:	fffff097          	auipc	ra,0xfffff
    80002ffc:	d84080e7          	jalr	-636(ra) # 80001d7c <fork>
}
    80003000:	60a2                	ld	ra,8(sp)
    80003002:	6402                	ld	s0,0(sp)
    80003004:	0141                	addi	sp,sp,16
    80003006:	8082                	ret

0000000080003008 <sys_wait>:

uint64 sys_wait(void){
    80003008:	1101                	addi	sp,sp,-32
    8000300a:	ec06                	sd	ra,24(sp)
    8000300c:	e822                	sd	s0,16(sp)
    8000300e:	1000                	addi	s0,sp,32
  uint64 status_addr;
  uint64 msg_addr;

  argaddr(0, &status_addr);
    80003010:	fe840593          	addi	a1,s0,-24
    80003014:	4501                	li	a0,0
    80003016:	00000097          	auipc	ra,0x0
    8000301a:	e96080e7          	jalr	-362(ra) # 80002eac <argaddr>
  argaddr(1, &msg_addr);
    8000301e:	fe040593          	addi	a1,s0,-32
    80003022:	4505                	li	a0,1
    80003024:	00000097          	auipc	ra,0x0
    80003028:	e88080e7          	jalr	-376(ra) # 80002eac <argaddr>

  return wait(status_addr, msg_addr);
    8000302c:	fe043583          	ld	a1,-32(s0)
    80003030:	fe843503          	ld	a0,-24(s0)
    80003034:	fffff097          	auipc	ra,0xfffff
    80003038:	38a080e7          	jalr	906(ra) # 800023be <wait>
} 
    8000303c:	60e2                	ld	ra,24(sp)
    8000303e:	6442                	ld	s0,16(sp)
    80003040:	6105                	addi	sp,sp,32
    80003042:	8082                	ret

0000000080003044 <sys_sbrk>:

uint64 sys_sbrk(void)
{
    80003044:	7179                	addi	sp,sp,-48
    80003046:	f406                	sd	ra,40(sp)
    80003048:	f022                	sd	s0,32(sp)
    8000304a:	ec26                	sd	s1,24(sp)
    8000304c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000304e:	fdc40593          	addi	a1,s0,-36
    80003052:	4501                	li	a0,0
    80003054:	00000097          	auipc	ra,0x0
    80003058:	e36080e7          	jalr	-458(ra) # 80002e8a <argint>
  addr = myproc()->sz;
    8000305c:	fffff097          	auipc	ra,0xfffff
    80003060:	96a080e7          	jalr	-1686(ra) # 800019c6 <myproc>
    80003064:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80003066:	fdc42503          	lw	a0,-36(s0)
    8000306a:	fffff097          	auipc	ra,0xfffff
    8000306e:	cb6080e7          	jalr	-842(ra) # 80001d20 <growproc>
    80003072:	00054863          	bltz	a0,80003082 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003076:	8526                	mv	a0,s1
    80003078:	70a2                	ld	ra,40(sp)
    8000307a:	7402                	ld	s0,32(sp)
    8000307c:	64e2                	ld	s1,24(sp)
    8000307e:	6145                	addi	sp,sp,48
    80003080:	8082                	ret
    return -1;
    80003082:	54fd                	li	s1,-1
    80003084:	bfcd                	j	80003076 <sys_sbrk+0x32>

0000000080003086 <sys_sleep>:

uint64 sys_sleep(void)
{
    80003086:	7139                	addi	sp,sp,-64
    80003088:	fc06                	sd	ra,56(sp)
    8000308a:	f822                	sd	s0,48(sp)
    8000308c:	f426                	sd	s1,40(sp)
    8000308e:	f04a                	sd	s2,32(sp)
    80003090:	ec4e                	sd	s3,24(sp)
    80003092:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003094:	fcc40593          	addi	a1,s0,-52
    80003098:	4501                	li	a0,0
    8000309a:	00000097          	auipc	ra,0x0
    8000309e:	df0080e7          	jalr	-528(ra) # 80002e8a <argint>
  acquire(&tickslock);
    800030a2:	00014517          	auipc	a0,0x14
    800030a6:	13e50513          	addi	a0,a0,318 # 800171e0 <tickslock>
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	b40080e7          	jalr	-1216(ra) # 80000bea <acquire>
  ticks0 = ticks;
    800030b2:	00006917          	auipc	s2,0x6
    800030b6:	88e92903          	lw	s2,-1906(s2) # 80008940 <ticks>
  while(ticks - ticks0 < n){
    800030ba:	fcc42783          	lw	a5,-52(s0)
    800030be:	cf9d                	beqz	a5,800030fc <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800030c0:	00014997          	auipc	s3,0x14
    800030c4:	12098993          	addi	s3,s3,288 # 800171e0 <tickslock>
    800030c8:	00006497          	auipc	s1,0x6
    800030cc:	87848493          	addi	s1,s1,-1928 # 80008940 <ticks>
    if(killed(myproc())){
    800030d0:	fffff097          	auipc	ra,0xfffff
    800030d4:	8f6080e7          	jalr	-1802(ra) # 800019c6 <myproc>
    800030d8:	fffff097          	auipc	ra,0xfffff
    800030dc:	2b4080e7          	jalr	692(ra) # 8000238c <killed>
    800030e0:	ed15                	bnez	a0,8000311c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800030e2:	85ce                	mv	a1,s3
    800030e4:	8526                	mv	a0,s1
    800030e6:	fffff097          	auipc	ra,0xfffff
    800030ea:	f84080e7          	jalr	-124(ra) # 8000206a <sleep>
  while(ticks - ticks0 < n){
    800030ee:	409c                	lw	a5,0(s1)
    800030f0:	412787bb          	subw	a5,a5,s2
    800030f4:	fcc42703          	lw	a4,-52(s0)
    800030f8:	fce7ece3          	bltu	a5,a4,800030d0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800030fc:	00014517          	auipc	a0,0x14
    80003100:	0e450513          	addi	a0,a0,228 # 800171e0 <tickslock>
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	b9a080e7          	jalr	-1126(ra) # 80000c9e <release>
  return 0;
    8000310c:	4501                	li	a0,0
}
    8000310e:	70e2                	ld	ra,56(sp)
    80003110:	7442                	ld	s0,48(sp)
    80003112:	74a2                	ld	s1,40(sp)
    80003114:	7902                	ld	s2,32(sp)
    80003116:	69e2                	ld	s3,24(sp)
    80003118:	6121                	addi	sp,sp,64
    8000311a:	8082                	ret
      release(&tickslock);
    8000311c:	00014517          	auipc	a0,0x14
    80003120:	0c450513          	addi	a0,a0,196 # 800171e0 <tickslock>
    80003124:	ffffe097          	auipc	ra,0xffffe
    80003128:	b7a080e7          	jalr	-1158(ra) # 80000c9e <release>
      return -1;
    8000312c:	557d                	li	a0,-1
    8000312e:	b7c5                	j	8000310e <sys_sleep+0x88>

0000000080003130 <sys_kill>:

uint64 sys_kill(void)
{
    80003130:	1101                	addi	sp,sp,-32
    80003132:	ec06                	sd	ra,24(sp)
    80003134:	e822                	sd	s0,16(sp)
    80003136:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003138:	fec40593          	addi	a1,s0,-20
    8000313c:	4501                	li	a0,0
    8000313e:	00000097          	auipc	ra,0x0
    80003142:	d4c080e7          	jalr	-692(ra) # 80002e8a <argint>
  return kill(pid);
    80003146:	fec42503          	lw	a0,-20(s0)
    8000314a:	fffff097          	auipc	ra,0xfffff
    8000314e:	1a4080e7          	jalr	420(ra) # 800022ee <kill>
}
    80003152:	60e2                	ld	ra,24(sp)
    80003154:	6442                	ld	s0,16(sp)
    80003156:	6105                	addi	sp,sp,32
    80003158:	8082                	ret

000000008000315a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64 sys_uptime(void)
{
    8000315a:	1101                	addi	sp,sp,-32
    8000315c:	ec06                	sd	ra,24(sp)
    8000315e:	e822                	sd	s0,16(sp)
    80003160:	e426                	sd	s1,8(sp)
    80003162:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003164:	00014517          	auipc	a0,0x14
    80003168:	07c50513          	addi	a0,a0,124 # 800171e0 <tickslock>
    8000316c:	ffffe097          	auipc	ra,0xffffe
    80003170:	a7e080e7          	jalr	-1410(ra) # 80000bea <acquire>
  xticks = ticks;
    80003174:	00005497          	auipc	s1,0x5
    80003178:	7cc4a483          	lw	s1,1996(s1) # 80008940 <ticks>
  release(&tickslock);
    8000317c:	00014517          	auipc	a0,0x14
    80003180:	06450513          	addi	a0,a0,100 # 800171e0 <tickslock>
    80003184:	ffffe097          	auipc	ra,0xffffe
    80003188:	b1a080e7          	jalr	-1254(ra) # 80000c9e <release>
  return xticks;
}
    8000318c:	02049513          	slli	a0,s1,0x20
    80003190:	9101                	srli	a0,a0,0x20
    80003192:	60e2                	ld	ra,24(sp)
    80003194:	6442                	ld	s0,16(sp)
    80003196:	64a2                	ld	s1,8(sp)
    80003198:	6105                	addi	sp,sp,32
    8000319a:	8082                	ret

000000008000319c <sys_memsize>:


//I Added
uint64 sys_memsize(void)
{
    8000319c:	1141                	addi	sp,sp,-16
    8000319e:	e406                	sd	ra,8(sp)
    800031a0:	e022                	sd	s0,0(sp)
    800031a2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800031a4:	fffff097          	auipc	ra,0xfffff
    800031a8:	822080e7          	jalr	-2014(ra) # 800019c6 <myproc>
  return p->sz;
}
    800031ac:	6528                	ld	a0,72(a0)
    800031ae:	60a2                	ld	ra,8(sp)
    800031b0:	6402                	ld	s0,0(sp)
    800031b2:	0141                	addi	sp,sp,16
    800031b4:	8082                	ret

00000000800031b6 <sys_forkn>:

uint64 sys_forkn(void)
{
    800031b6:	7159                	addi	sp,sp,-112
    800031b8:	f486                	sd	ra,104(sp)
    800031ba:	f0a2                	sd	s0,96(sp)
    800031bc:	eca6                	sd	s1,88(sp)
    800031be:	1880                	addi	s0,sp,112
  int n;
  uint64 pids_addr;

  // Get args from userspace
  if (argint(0, &n) < 0 || argaddr(1, &pids_addr) < 0)
    800031c0:	fdc40593          	addi	a1,s0,-36
    800031c4:	4501                	li	a0,0
    800031c6:	00000097          	auipc	ra,0x0
    800031ca:	cc4080e7          	jalr	-828(ra) # 80002e8a <argint>
    return -1;
    800031ce:	54fd                	li	s1,-1
  if (argint(0, &n) < 0 || argaddr(1, &pids_addr) < 0)
    800031d0:	02054d63          	bltz	a0,8000320a <sys_forkn+0x54>
    800031d4:	fd040593          	addi	a1,s0,-48
    800031d8:	4505                	li	a0,1
    800031da:	00000097          	auipc	ra,0x0
    800031de:	cd2080e7          	jalr	-814(ra) # 80002eac <argaddr>
    800031e2:	04054e63          	bltz	a0,8000323e <sys_forkn+0x88>

  // Check for invalid input
  if (n < 1 || n > 16 || pids_addr == 0)
    800031e6:	fdc42503          	lw	a0,-36(s0)
    800031ea:	fff5069b          	addiw	a3,a0,-1
    800031ee:	473d                	li	a4,15
    800031f0:	00d76d63          	bltu	a4,a3,8000320a <sys_forkn+0x54>
    800031f4:	fd043703          	ld	a4,-48(s0)
    800031f8:	cb09                	beqz	a4,8000320a <sys_forkn+0x54>
    return -1;

  int pids[16]; // Temporary kernel buffer

  int result = forkn(n, pids);  
    800031fa:	f9040593          	addi	a1,s0,-112
    800031fe:	fffff097          	auipc	ra,0xfffff
    80003202:	4ae080e7          	jalr	1198(ra) # 800026ac <forkn>
    80003206:	84aa                	mv	s1,a0
  if (result == 0) {
    80003208:	c519                	beqz	a0,80003216 <sys_forkn+0x60>
    if (copyout(p->pagetable, pids_addr, (char *)pids, n * sizeof(int)) < 0)
      return -1;
  }

  return result;
}
    8000320a:	8526                	mv	a0,s1
    8000320c:	70a6                	ld	ra,104(sp)
    8000320e:	7406                	ld	s0,96(sp)
    80003210:	64e6                	ld	s1,88(sp)
    80003212:	6165                	addi	sp,sp,112
    80003214:	8082                	ret
    struct proc *p = myproc();
    80003216:	ffffe097          	auipc	ra,0xffffe
    8000321a:	7b0080e7          	jalr	1968(ra) # 800019c6 <myproc>
    if (copyout(p->pagetable, pids_addr, (char *)pids, n * sizeof(int)) < 0)
    8000321e:	fdc42683          	lw	a3,-36(s0)
    80003222:	068a                	slli	a3,a3,0x2
    80003224:	f9040613          	addi	a2,s0,-112
    80003228:	fd043583          	ld	a1,-48(s0)
    8000322c:	6928                	ld	a0,80(a0)
    8000322e:	ffffe097          	auipc	ra,0xffffe
    80003232:	456080e7          	jalr	1110(ra) # 80001684 <copyout>
    80003236:	fc055ae3          	bgez	a0,8000320a <sys_forkn+0x54>
      return -1;
    8000323a:	54fd                	li	s1,-1
    8000323c:	b7f9                	j	8000320a <sys_forkn+0x54>
    return -1;
    8000323e:	54fd                	li	s1,-1
    80003240:	b7e9                	j	8000320a <sys_forkn+0x54>

0000000080003242 <sys_waitall>:

uint64 sys_waitall(void)
{
    80003242:	1101                	addi	sp,sp,-32
    80003244:	ec06                	sd	ra,24(sp)
    80003246:	e822                	sd	s0,16(sp)
    80003248:	1000                	addi	s0,sp,32
  uint64 n_addr, statuses_addr;

  argaddr(0, &n_addr);
    8000324a:	fe840593          	addi	a1,s0,-24
    8000324e:	4501                	li	a0,0
    80003250:	00000097          	auipc	ra,0x0
    80003254:	c5c080e7          	jalr	-932(ra) # 80002eac <argaddr>
  argaddr(1, &statuses_addr);
    80003258:	fe040593          	addi	a1,s0,-32
    8000325c:	4505                	li	a0,1
    8000325e:	00000097          	auipc	ra,0x0
    80003262:	c4e080e7          	jalr	-946(ra) # 80002eac <argaddr>

  if (n_addr == 0 || statuses_addr == 0)
    80003266:	fe843783          	ld	a5,-24(s0)
    return -1;
    8000326a:	557d                	li	a0,-1
  if (n_addr == 0 || statuses_addr == 0)
    8000326c:	cb89                	beqz	a5,8000327e <sys_waitall+0x3c>
    8000326e:	fe043583          	ld	a1,-32(s0)
    80003272:	c591                	beqz	a1,8000327e <sys_waitall+0x3c>

  return waitall((int *)n_addr, (int *)statuses_addr);
    80003274:	853e                	mv	a0,a5
    80003276:	fffff097          	auipc	ra,0xfffff
    8000327a:	5f4080e7          	jalr	1524(ra) # 8000286a <waitall>
}
    8000327e:	60e2                	ld	ra,24(sp)
    80003280:	6442                	ld	s0,16(sp)
    80003282:	6105                	addi	sp,sp,32
    80003284:	8082                	ret

0000000080003286 <sys_exit_num>:

uint64 sys_exit_num(void) {
    80003286:	1101                	addi	sp,sp,-32
    80003288:	ec06                	sd	ra,24(sp)
    8000328a:	e822                	sd	s0,16(sp)
    8000328c:	1000                	addi	s0,sp,32
  int status;
  if(argint(0, &status) < 0)
    8000328e:	fec40593          	addi	a1,s0,-20
    80003292:	4501                	li	a0,0
    80003294:	00000097          	auipc	ra,0x0
    80003298:	bf6080e7          	jalr	-1034(ra) # 80002e8a <argint>
    return -1;
    8000329c:	57fd                	li	a5,-1
  if(argint(0, &status) < 0)
    8000329e:	00054963          	bltz	a0,800032b0 <sys_exit_num+0x2a>
  exit_num(status);
    800032a2:	fec42503          	lw	a0,-20(s0)
    800032a6:	fffff097          	auipc	ra,0xfffff
    800032aa:	fe4080e7          	jalr	-28(ra) # 8000228a <exit_num>
  return 0; 
    800032ae:	4781                	li	a5,0
}
    800032b0:	853e                	mv	a0,a5
    800032b2:	60e2                	ld	ra,24(sp)
    800032b4:	6442                	ld	s0,16(sp)
    800032b6:	6105                	addi	sp,sp,32
    800032b8:	8082                	ret

00000000800032ba <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800032ba:	7179                	addi	sp,sp,-48
    800032bc:	f406                	sd	ra,40(sp)
    800032be:	f022                	sd	s0,32(sp)
    800032c0:	ec26                	sd	s1,24(sp)
    800032c2:	e84a                	sd	s2,16(sp)
    800032c4:	e44e                	sd	s3,8(sp)
    800032c6:	e052                	sd	s4,0(sp)
    800032c8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800032ca:	00005597          	auipc	a1,0x5
    800032ce:	2b658593          	addi	a1,a1,694 # 80008580 <syscalls+0xe0>
    800032d2:	00014517          	auipc	a0,0x14
    800032d6:	f2650513          	addi	a0,a0,-218 # 800171f8 <bcache>
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	880080e7          	jalr	-1920(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800032e2:	0001c797          	auipc	a5,0x1c
    800032e6:	f1678793          	addi	a5,a5,-234 # 8001f1f8 <bcache+0x8000>
    800032ea:	0001c717          	auipc	a4,0x1c
    800032ee:	17670713          	addi	a4,a4,374 # 8001f460 <bcache+0x8268>
    800032f2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800032f6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032fa:	00014497          	auipc	s1,0x14
    800032fe:	f1648493          	addi	s1,s1,-234 # 80017210 <bcache+0x18>
    b->next = bcache.head.next;
    80003302:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003304:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003306:	00005a17          	auipc	s4,0x5
    8000330a:	282a0a13          	addi	s4,s4,642 # 80008588 <syscalls+0xe8>
    b->next = bcache.head.next;
    8000330e:	2b893783          	ld	a5,696(s2)
    80003312:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003314:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003318:	85d2                	mv	a1,s4
    8000331a:	01048513          	addi	a0,s1,16
    8000331e:	00001097          	auipc	ra,0x1
    80003322:	4c4080e7          	jalr	1220(ra) # 800047e2 <initsleeplock>
    bcache.head.next->prev = b;
    80003326:	2b893783          	ld	a5,696(s2)
    8000332a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000332c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003330:	45848493          	addi	s1,s1,1112
    80003334:	fd349de3          	bne	s1,s3,8000330e <binit+0x54>
  }
}
    80003338:	70a2                	ld	ra,40(sp)
    8000333a:	7402                	ld	s0,32(sp)
    8000333c:	64e2                	ld	s1,24(sp)
    8000333e:	6942                	ld	s2,16(sp)
    80003340:	69a2                	ld	s3,8(sp)
    80003342:	6a02                	ld	s4,0(sp)
    80003344:	6145                	addi	sp,sp,48
    80003346:	8082                	ret

0000000080003348 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003348:	7179                	addi	sp,sp,-48
    8000334a:	f406                	sd	ra,40(sp)
    8000334c:	f022                	sd	s0,32(sp)
    8000334e:	ec26                	sd	s1,24(sp)
    80003350:	e84a                	sd	s2,16(sp)
    80003352:	e44e                	sd	s3,8(sp)
    80003354:	1800                	addi	s0,sp,48
    80003356:	89aa                	mv	s3,a0
    80003358:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000335a:	00014517          	auipc	a0,0x14
    8000335e:	e9e50513          	addi	a0,a0,-354 # 800171f8 <bcache>
    80003362:	ffffe097          	auipc	ra,0xffffe
    80003366:	888080e7          	jalr	-1912(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000336a:	0001c497          	auipc	s1,0x1c
    8000336e:	1464b483          	ld	s1,326(s1) # 8001f4b0 <bcache+0x82b8>
    80003372:	0001c797          	auipc	a5,0x1c
    80003376:	0ee78793          	addi	a5,a5,238 # 8001f460 <bcache+0x8268>
    8000337a:	02f48f63          	beq	s1,a5,800033b8 <bread+0x70>
    8000337e:	873e                	mv	a4,a5
    80003380:	a021                	j	80003388 <bread+0x40>
    80003382:	68a4                	ld	s1,80(s1)
    80003384:	02e48a63          	beq	s1,a4,800033b8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003388:	449c                	lw	a5,8(s1)
    8000338a:	ff379ce3          	bne	a5,s3,80003382 <bread+0x3a>
    8000338e:	44dc                	lw	a5,12(s1)
    80003390:	ff2799e3          	bne	a5,s2,80003382 <bread+0x3a>
      b->refcnt++;
    80003394:	40bc                	lw	a5,64(s1)
    80003396:	2785                	addiw	a5,a5,1
    80003398:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000339a:	00014517          	auipc	a0,0x14
    8000339e:	e5e50513          	addi	a0,a0,-418 # 800171f8 <bcache>
    800033a2:	ffffe097          	auipc	ra,0xffffe
    800033a6:	8fc080e7          	jalr	-1796(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800033aa:	01048513          	addi	a0,s1,16
    800033ae:	00001097          	auipc	ra,0x1
    800033b2:	46e080e7          	jalr	1134(ra) # 8000481c <acquiresleep>
      return b;
    800033b6:	a8b9                	j	80003414 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033b8:	0001c497          	auipc	s1,0x1c
    800033bc:	0f04b483          	ld	s1,240(s1) # 8001f4a8 <bcache+0x82b0>
    800033c0:	0001c797          	auipc	a5,0x1c
    800033c4:	0a078793          	addi	a5,a5,160 # 8001f460 <bcache+0x8268>
    800033c8:	00f48863          	beq	s1,a5,800033d8 <bread+0x90>
    800033cc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800033ce:	40bc                	lw	a5,64(s1)
    800033d0:	cf81                	beqz	a5,800033e8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033d2:	64a4                	ld	s1,72(s1)
    800033d4:	fee49de3          	bne	s1,a4,800033ce <bread+0x86>
  panic("bget: no buffers");
    800033d8:	00005517          	auipc	a0,0x5
    800033dc:	1b850513          	addi	a0,a0,440 # 80008590 <syscalls+0xf0>
    800033e0:	ffffd097          	auipc	ra,0xffffd
    800033e4:	164080e7          	jalr	356(ra) # 80000544 <panic>
      b->dev = dev;
    800033e8:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800033ec:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800033f0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800033f4:	4785                	li	a5,1
    800033f6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033f8:	00014517          	auipc	a0,0x14
    800033fc:	e0050513          	addi	a0,a0,-512 # 800171f8 <bcache>
    80003400:	ffffe097          	auipc	ra,0xffffe
    80003404:	89e080e7          	jalr	-1890(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003408:	01048513          	addi	a0,s1,16
    8000340c:	00001097          	auipc	ra,0x1
    80003410:	410080e7          	jalr	1040(ra) # 8000481c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003414:	409c                	lw	a5,0(s1)
    80003416:	cb89                	beqz	a5,80003428 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003418:	8526                	mv	a0,s1
    8000341a:	70a2                	ld	ra,40(sp)
    8000341c:	7402                	ld	s0,32(sp)
    8000341e:	64e2                	ld	s1,24(sp)
    80003420:	6942                	ld	s2,16(sp)
    80003422:	69a2                	ld	s3,8(sp)
    80003424:	6145                	addi	sp,sp,48
    80003426:	8082                	ret
    virtio_disk_rw(b, 0);
    80003428:	4581                	li	a1,0
    8000342a:	8526                	mv	a0,s1
    8000342c:	00003097          	auipc	ra,0x3
    80003430:	fcc080e7          	jalr	-52(ra) # 800063f8 <virtio_disk_rw>
    b->valid = 1;
    80003434:	4785                	li	a5,1
    80003436:	c09c                	sw	a5,0(s1)
  return b;
    80003438:	b7c5                	j	80003418 <bread+0xd0>

000000008000343a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000343a:	1101                	addi	sp,sp,-32
    8000343c:	ec06                	sd	ra,24(sp)
    8000343e:	e822                	sd	s0,16(sp)
    80003440:	e426                	sd	s1,8(sp)
    80003442:	1000                	addi	s0,sp,32
    80003444:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003446:	0541                	addi	a0,a0,16
    80003448:	00001097          	auipc	ra,0x1
    8000344c:	46e080e7          	jalr	1134(ra) # 800048b6 <holdingsleep>
    80003450:	cd01                	beqz	a0,80003468 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003452:	4585                	li	a1,1
    80003454:	8526                	mv	a0,s1
    80003456:	00003097          	auipc	ra,0x3
    8000345a:	fa2080e7          	jalr	-94(ra) # 800063f8 <virtio_disk_rw>
}
    8000345e:	60e2                	ld	ra,24(sp)
    80003460:	6442                	ld	s0,16(sp)
    80003462:	64a2                	ld	s1,8(sp)
    80003464:	6105                	addi	sp,sp,32
    80003466:	8082                	ret
    panic("bwrite");
    80003468:	00005517          	auipc	a0,0x5
    8000346c:	14050513          	addi	a0,a0,320 # 800085a8 <syscalls+0x108>
    80003470:	ffffd097          	auipc	ra,0xffffd
    80003474:	0d4080e7          	jalr	212(ra) # 80000544 <panic>

0000000080003478 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003478:	1101                	addi	sp,sp,-32
    8000347a:	ec06                	sd	ra,24(sp)
    8000347c:	e822                	sd	s0,16(sp)
    8000347e:	e426                	sd	s1,8(sp)
    80003480:	e04a                	sd	s2,0(sp)
    80003482:	1000                	addi	s0,sp,32
    80003484:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003486:	01050913          	addi	s2,a0,16
    8000348a:	854a                	mv	a0,s2
    8000348c:	00001097          	auipc	ra,0x1
    80003490:	42a080e7          	jalr	1066(ra) # 800048b6 <holdingsleep>
    80003494:	c92d                	beqz	a0,80003506 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003496:	854a                	mv	a0,s2
    80003498:	00001097          	auipc	ra,0x1
    8000349c:	3da080e7          	jalr	986(ra) # 80004872 <releasesleep>

  acquire(&bcache.lock);
    800034a0:	00014517          	auipc	a0,0x14
    800034a4:	d5850513          	addi	a0,a0,-680 # 800171f8 <bcache>
    800034a8:	ffffd097          	auipc	ra,0xffffd
    800034ac:	742080e7          	jalr	1858(ra) # 80000bea <acquire>
  b->refcnt--;
    800034b0:	40bc                	lw	a5,64(s1)
    800034b2:	37fd                	addiw	a5,a5,-1
    800034b4:	0007871b          	sext.w	a4,a5
    800034b8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800034ba:	eb05                	bnez	a4,800034ea <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800034bc:	68bc                	ld	a5,80(s1)
    800034be:	64b8                	ld	a4,72(s1)
    800034c0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800034c2:	64bc                	ld	a5,72(s1)
    800034c4:	68b8                	ld	a4,80(s1)
    800034c6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800034c8:	0001c797          	auipc	a5,0x1c
    800034cc:	d3078793          	addi	a5,a5,-720 # 8001f1f8 <bcache+0x8000>
    800034d0:	2b87b703          	ld	a4,696(a5)
    800034d4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800034d6:	0001c717          	auipc	a4,0x1c
    800034da:	f8a70713          	addi	a4,a4,-118 # 8001f460 <bcache+0x8268>
    800034de:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800034e0:	2b87b703          	ld	a4,696(a5)
    800034e4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800034e6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800034ea:	00014517          	auipc	a0,0x14
    800034ee:	d0e50513          	addi	a0,a0,-754 # 800171f8 <bcache>
    800034f2:	ffffd097          	auipc	ra,0xffffd
    800034f6:	7ac080e7          	jalr	1964(ra) # 80000c9e <release>
}
    800034fa:	60e2                	ld	ra,24(sp)
    800034fc:	6442                	ld	s0,16(sp)
    800034fe:	64a2                	ld	s1,8(sp)
    80003500:	6902                	ld	s2,0(sp)
    80003502:	6105                	addi	sp,sp,32
    80003504:	8082                	ret
    panic("brelse");
    80003506:	00005517          	auipc	a0,0x5
    8000350a:	0aa50513          	addi	a0,a0,170 # 800085b0 <syscalls+0x110>
    8000350e:	ffffd097          	auipc	ra,0xffffd
    80003512:	036080e7          	jalr	54(ra) # 80000544 <panic>

0000000080003516 <bpin>:

void
bpin(struct buf *b) {
    80003516:	1101                	addi	sp,sp,-32
    80003518:	ec06                	sd	ra,24(sp)
    8000351a:	e822                	sd	s0,16(sp)
    8000351c:	e426                	sd	s1,8(sp)
    8000351e:	1000                	addi	s0,sp,32
    80003520:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003522:	00014517          	auipc	a0,0x14
    80003526:	cd650513          	addi	a0,a0,-810 # 800171f8 <bcache>
    8000352a:	ffffd097          	auipc	ra,0xffffd
    8000352e:	6c0080e7          	jalr	1728(ra) # 80000bea <acquire>
  b->refcnt++;
    80003532:	40bc                	lw	a5,64(s1)
    80003534:	2785                	addiw	a5,a5,1
    80003536:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003538:	00014517          	auipc	a0,0x14
    8000353c:	cc050513          	addi	a0,a0,-832 # 800171f8 <bcache>
    80003540:	ffffd097          	auipc	ra,0xffffd
    80003544:	75e080e7          	jalr	1886(ra) # 80000c9e <release>
}
    80003548:	60e2                	ld	ra,24(sp)
    8000354a:	6442                	ld	s0,16(sp)
    8000354c:	64a2                	ld	s1,8(sp)
    8000354e:	6105                	addi	sp,sp,32
    80003550:	8082                	ret

0000000080003552 <bunpin>:

void
bunpin(struct buf *b) {
    80003552:	1101                	addi	sp,sp,-32
    80003554:	ec06                	sd	ra,24(sp)
    80003556:	e822                	sd	s0,16(sp)
    80003558:	e426                	sd	s1,8(sp)
    8000355a:	1000                	addi	s0,sp,32
    8000355c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000355e:	00014517          	auipc	a0,0x14
    80003562:	c9a50513          	addi	a0,a0,-870 # 800171f8 <bcache>
    80003566:	ffffd097          	auipc	ra,0xffffd
    8000356a:	684080e7          	jalr	1668(ra) # 80000bea <acquire>
  b->refcnt--;
    8000356e:	40bc                	lw	a5,64(s1)
    80003570:	37fd                	addiw	a5,a5,-1
    80003572:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003574:	00014517          	auipc	a0,0x14
    80003578:	c8450513          	addi	a0,a0,-892 # 800171f8 <bcache>
    8000357c:	ffffd097          	auipc	ra,0xffffd
    80003580:	722080e7          	jalr	1826(ra) # 80000c9e <release>
}
    80003584:	60e2                	ld	ra,24(sp)
    80003586:	6442                	ld	s0,16(sp)
    80003588:	64a2                	ld	s1,8(sp)
    8000358a:	6105                	addi	sp,sp,32
    8000358c:	8082                	ret

000000008000358e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000358e:	1101                	addi	sp,sp,-32
    80003590:	ec06                	sd	ra,24(sp)
    80003592:	e822                	sd	s0,16(sp)
    80003594:	e426                	sd	s1,8(sp)
    80003596:	e04a                	sd	s2,0(sp)
    80003598:	1000                	addi	s0,sp,32
    8000359a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000359c:	00d5d59b          	srliw	a1,a1,0xd
    800035a0:	0001c797          	auipc	a5,0x1c
    800035a4:	3347a783          	lw	a5,820(a5) # 8001f8d4 <sb+0x1c>
    800035a8:	9dbd                	addw	a1,a1,a5
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	d9e080e7          	jalr	-610(ra) # 80003348 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800035b2:	0074f713          	andi	a4,s1,7
    800035b6:	4785                	li	a5,1
    800035b8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800035bc:	14ce                	slli	s1,s1,0x33
    800035be:	90d9                	srli	s1,s1,0x36
    800035c0:	00950733          	add	a4,a0,s1
    800035c4:	05874703          	lbu	a4,88(a4)
    800035c8:	00e7f6b3          	and	a3,a5,a4
    800035cc:	c69d                	beqz	a3,800035fa <bfree+0x6c>
    800035ce:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800035d0:	94aa                	add	s1,s1,a0
    800035d2:	fff7c793          	not	a5,a5
    800035d6:	8ff9                	and	a5,a5,a4
    800035d8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800035dc:	00001097          	auipc	ra,0x1
    800035e0:	120080e7          	jalr	288(ra) # 800046fc <log_write>
  brelse(bp);
    800035e4:	854a                	mv	a0,s2
    800035e6:	00000097          	auipc	ra,0x0
    800035ea:	e92080e7          	jalr	-366(ra) # 80003478 <brelse>
}
    800035ee:	60e2                	ld	ra,24(sp)
    800035f0:	6442                	ld	s0,16(sp)
    800035f2:	64a2                	ld	s1,8(sp)
    800035f4:	6902                	ld	s2,0(sp)
    800035f6:	6105                	addi	sp,sp,32
    800035f8:	8082                	ret
    panic("freeing free block");
    800035fa:	00005517          	auipc	a0,0x5
    800035fe:	fbe50513          	addi	a0,a0,-66 # 800085b8 <syscalls+0x118>
    80003602:	ffffd097          	auipc	ra,0xffffd
    80003606:	f42080e7          	jalr	-190(ra) # 80000544 <panic>

000000008000360a <balloc>:
{
    8000360a:	711d                	addi	sp,sp,-96
    8000360c:	ec86                	sd	ra,88(sp)
    8000360e:	e8a2                	sd	s0,80(sp)
    80003610:	e4a6                	sd	s1,72(sp)
    80003612:	e0ca                	sd	s2,64(sp)
    80003614:	fc4e                	sd	s3,56(sp)
    80003616:	f852                	sd	s4,48(sp)
    80003618:	f456                	sd	s5,40(sp)
    8000361a:	f05a                	sd	s6,32(sp)
    8000361c:	ec5e                	sd	s7,24(sp)
    8000361e:	e862                	sd	s8,16(sp)
    80003620:	e466                	sd	s9,8(sp)
    80003622:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003624:	0001c797          	auipc	a5,0x1c
    80003628:	2987a783          	lw	a5,664(a5) # 8001f8bc <sb+0x4>
    8000362c:	10078163          	beqz	a5,8000372e <balloc+0x124>
    80003630:	8baa                	mv	s7,a0
    80003632:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003634:	0001cb17          	auipc	s6,0x1c
    80003638:	284b0b13          	addi	s6,s6,644 # 8001f8b8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000363c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000363e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003640:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003642:	6c89                	lui	s9,0x2
    80003644:	a061                	j	800036cc <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003646:	974a                	add	a4,a4,s2
    80003648:	8fd5                	or	a5,a5,a3
    8000364a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000364e:	854a                	mv	a0,s2
    80003650:	00001097          	auipc	ra,0x1
    80003654:	0ac080e7          	jalr	172(ra) # 800046fc <log_write>
        brelse(bp);
    80003658:	854a                	mv	a0,s2
    8000365a:	00000097          	auipc	ra,0x0
    8000365e:	e1e080e7          	jalr	-482(ra) # 80003478 <brelse>
  bp = bread(dev, bno);
    80003662:	85a6                	mv	a1,s1
    80003664:	855e                	mv	a0,s7
    80003666:	00000097          	auipc	ra,0x0
    8000366a:	ce2080e7          	jalr	-798(ra) # 80003348 <bread>
    8000366e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003670:	40000613          	li	a2,1024
    80003674:	4581                	li	a1,0
    80003676:	05850513          	addi	a0,a0,88
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	66c080e7          	jalr	1644(ra) # 80000ce6 <memset>
  log_write(bp);
    80003682:	854a                	mv	a0,s2
    80003684:	00001097          	auipc	ra,0x1
    80003688:	078080e7          	jalr	120(ra) # 800046fc <log_write>
  brelse(bp);
    8000368c:	854a                	mv	a0,s2
    8000368e:	00000097          	auipc	ra,0x0
    80003692:	dea080e7          	jalr	-534(ra) # 80003478 <brelse>
}
    80003696:	8526                	mv	a0,s1
    80003698:	60e6                	ld	ra,88(sp)
    8000369a:	6446                	ld	s0,80(sp)
    8000369c:	64a6                	ld	s1,72(sp)
    8000369e:	6906                	ld	s2,64(sp)
    800036a0:	79e2                	ld	s3,56(sp)
    800036a2:	7a42                	ld	s4,48(sp)
    800036a4:	7aa2                	ld	s5,40(sp)
    800036a6:	7b02                	ld	s6,32(sp)
    800036a8:	6be2                	ld	s7,24(sp)
    800036aa:	6c42                	ld	s8,16(sp)
    800036ac:	6ca2                	ld	s9,8(sp)
    800036ae:	6125                	addi	sp,sp,96
    800036b0:	8082                	ret
    brelse(bp);
    800036b2:	854a                	mv	a0,s2
    800036b4:	00000097          	auipc	ra,0x0
    800036b8:	dc4080e7          	jalr	-572(ra) # 80003478 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800036bc:	015c87bb          	addw	a5,s9,s5
    800036c0:	00078a9b          	sext.w	s5,a5
    800036c4:	004b2703          	lw	a4,4(s6)
    800036c8:	06eaf363          	bgeu	s5,a4,8000372e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800036cc:	41fad79b          	sraiw	a5,s5,0x1f
    800036d0:	0137d79b          	srliw	a5,a5,0x13
    800036d4:	015787bb          	addw	a5,a5,s5
    800036d8:	40d7d79b          	sraiw	a5,a5,0xd
    800036dc:	01cb2583          	lw	a1,28(s6)
    800036e0:	9dbd                	addw	a1,a1,a5
    800036e2:	855e                	mv	a0,s7
    800036e4:	00000097          	auipc	ra,0x0
    800036e8:	c64080e7          	jalr	-924(ra) # 80003348 <bread>
    800036ec:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036ee:	004b2503          	lw	a0,4(s6)
    800036f2:	000a849b          	sext.w	s1,s5
    800036f6:	8662                	mv	a2,s8
    800036f8:	faa4fde3          	bgeu	s1,a0,800036b2 <balloc+0xa8>
      m = 1 << (bi % 8);
    800036fc:	41f6579b          	sraiw	a5,a2,0x1f
    80003700:	01d7d69b          	srliw	a3,a5,0x1d
    80003704:	00c6873b          	addw	a4,a3,a2
    80003708:	00777793          	andi	a5,a4,7
    8000370c:	9f95                	subw	a5,a5,a3
    8000370e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003712:	4037571b          	sraiw	a4,a4,0x3
    80003716:	00e906b3          	add	a3,s2,a4
    8000371a:	0586c683          	lbu	a3,88(a3)
    8000371e:	00d7f5b3          	and	a1,a5,a3
    80003722:	d195                	beqz	a1,80003646 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003724:	2605                	addiw	a2,a2,1
    80003726:	2485                	addiw	s1,s1,1
    80003728:	fd4618e3          	bne	a2,s4,800036f8 <balloc+0xee>
    8000372c:	b759                	j	800036b2 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000372e:	00005517          	auipc	a0,0x5
    80003732:	ea250513          	addi	a0,a0,-350 # 800085d0 <syscalls+0x130>
    80003736:	ffffd097          	auipc	ra,0xffffd
    8000373a:	e58080e7          	jalr	-424(ra) # 8000058e <printf>
  return 0;
    8000373e:	4481                	li	s1,0
    80003740:	bf99                	j	80003696 <balloc+0x8c>

0000000080003742 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003742:	7179                	addi	sp,sp,-48
    80003744:	f406                	sd	ra,40(sp)
    80003746:	f022                	sd	s0,32(sp)
    80003748:	ec26                	sd	s1,24(sp)
    8000374a:	e84a                	sd	s2,16(sp)
    8000374c:	e44e                	sd	s3,8(sp)
    8000374e:	e052                	sd	s4,0(sp)
    80003750:	1800                	addi	s0,sp,48
    80003752:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003754:	47ad                	li	a5,11
    80003756:	02b7e763          	bltu	a5,a1,80003784 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000375a:	02059493          	slli	s1,a1,0x20
    8000375e:	9081                	srli	s1,s1,0x20
    80003760:	048a                	slli	s1,s1,0x2
    80003762:	94aa                	add	s1,s1,a0
    80003764:	0504a903          	lw	s2,80(s1)
    80003768:	06091e63          	bnez	s2,800037e4 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000376c:	4108                	lw	a0,0(a0)
    8000376e:	00000097          	auipc	ra,0x0
    80003772:	e9c080e7          	jalr	-356(ra) # 8000360a <balloc>
    80003776:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000377a:	06090563          	beqz	s2,800037e4 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    8000377e:	0524a823          	sw	s2,80(s1)
    80003782:	a08d                	j	800037e4 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003784:	ff45849b          	addiw	s1,a1,-12
    80003788:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000378c:	0ff00793          	li	a5,255
    80003790:	08e7e563          	bltu	a5,a4,8000381a <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003794:	08052903          	lw	s2,128(a0)
    80003798:	00091d63          	bnez	s2,800037b2 <bmap+0x70>
      addr = balloc(ip->dev);
    8000379c:	4108                	lw	a0,0(a0)
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	e6c080e7          	jalr	-404(ra) # 8000360a <balloc>
    800037a6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037aa:	02090d63          	beqz	s2,800037e4 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800037ae:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800037b2:	85ca                	mv	a1,s2
    800037b4:	0009a503          	lw	a0,0(s3)
    800037b8:	00000097          	auipc	ra,0x0
    800037bc:	b90080e7          	jalr	-1136(ra) # 80003348 <bread>
    800037c0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800037c2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800037c6:	02049593          	slli	a1,s1,0x20
    800037ca:	9181                	srli	a1,a1,0x20
    800037cc:	058a                	slli	a1,a1,0x2
    800037ce:	00b784b3          	add	s1,a5,a1
    800037d2:	0004a903          	lw	s2,0(s1)
    800037d6:	02090063          	beqz	s2,800037f6 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800037da:	8552                	mv	a0,s4
    800037dc:	00000097          	auipc	ra,0x0
    800037e0:	c9c080e7          	jalr	-868(ra) # 80003478 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800037e4:	854a                	mv	a0,s2
    800037e6:	70a2                	ld	ra,40(sp)
    800037e8:	7402                	ld	s0,32(sp)
    800037ea:	64e2                	ld	s1,24(sp)
    800037ec:	6942                	ld	s2,16(sp)
    800037ee:	69a2                	ld	s3,8(sp)
    800037f0:	6a02                	ld	s4,0(sp)
    800037f2:	6145                	addi	sp,sp,48
    800037f4:	8082                	ret
      addr = balloc(ip->dev);
    800037f6:	0009a503          	lw	a0,0(s3)
    800037fa:	00000097          	auipc	ra,0x0
    800037fe:	e10080e7          	jalr	-496(ra) # 8000360a <balloc>
    80003802:	0005091b          	sext.w	s2,a0
      if(addr){
    80003806:	fc090ae3          	beqz	s2,800037da <bmap+0x98>
        a[bn] = addr;
    8000380a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000380e:	8552                	mv	a0,s4
    80003810:	00001097          	auipc	ra,0x1
    80003814:	eec080e7          	jalr	-276(ra) # 800046fc <log_write>
    80003818:	b7c9                	j	800037da <bmap+0x98>
  panic("bmap: out of range");
    8000381a:	00005517          	auipc	a0,0x5
    8000381e:	dce50513          	addi	a0,a0,-562 # 800085e8 <syscalls+0x148>
    80003822:	ffffd097          	auipc	ra,0xffffd
    80003826:	d22080e7          	jalr	-734(ra) # 80000544 <panic>

000000008000382a <iget>:
{
    8000382a:	7179                	addi	sp,sp,-48
    8000382c:	f406                	sd	ra,40(sp)
    8000382e:	f022                	sd	s0,32(sp)
    80003830:	ec26                	sd	s1,24(sp)
    80003832:	e84a                	sd	s2,16(sp)
    80003834:	e44e                	sd	s3,8(sp)
    80003836:	e052                	sd	s4,0(sp)
    80003838:	1800                	addi	s0,sp,48
    8000383a:	89aa                	mv	s3,a0
    8000383c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000383e:	0001c517          	auipc	a0,0x1c
    80003842:	09a50513          	addi	a0,a0,154 # 8001f8d8 <itable>
    80003846:	ffffd097          	auipc	ra,0xffffd
    8000384a:	3a4080e7          	jalr	932(ra) # 80000bea <acquire>
  empty = 0;
    8000384e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003850:	0001c497          	auipc	s1,0x1c
    80003854:	0a048493          	addi	s1,s1,160 # 8001f8f0 <itable+0x18>
    80003858:	0001e697          	auipc	a3,0x1e
    8000385c:	b2868693          	addi	a3,a3,-1240 # 80021380 <log>
    80003860:	a039                	j	8000386e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003862:	02090b63          	beqz	s2,80003898 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003866:	08848493          	addi	s1,s1,136
    8000386a:	02d48a63          	beq	s1,a3,8000389e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000386e:	449c                	lw	a5,8(s1)
    80003870:	fef059e3          	blez	a5,80003862 <iget+0x38>
    80003874:	4098                	lw	a4,0(s1)
    80003876:	ff3716e3          	bne	a4,s3,80003862 <iget+0x38>
    8000387a:	40d8                	lw	a4,4(s1)
    8000387c:	ff4713e3          	bne	a4,s4,80003862 <iget+0x38>
      ip->ref++;
    80003880:	2785                	addiw	a5,a5,1
    80003882:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003884:	0001c517          	auipc	a0,0x1c
    80003888:	05450513          	addi	a0,a0,84 # 8001f8d8 <itable>
    8000388c:	ffffd097          	auipc	ra,0xffffd
    80003890:	412080e7          	jalr	1042(ra) # 80000c9e <release>
      return ip;
    80003894:	8926                	mv	s2,s1
    80003896:	a03d                	j	800038c4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003898:	f7f9                	bnez	a5,80003866 <iget+0x3c>
    8000389a:	8926                	mv	s2,s1
    8000389c:	b7e9                	j	80003866 <iget+0x3c>
  if(empty == 0)
    8000389e:	02090c63          	beqz	s2,800038d6 <iget+0xac>
  ip->dev = dev;
    800038a2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800038a6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800038aa:	4785                	li	a5,1
    800038ac:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800038b0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800038b4:	0001c517          	auipc	a0,0x1c
    800038b8:	02450513          	addi	a0,a0,36 # 8001f8d8 <itable>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	3e2080e7          	jalr	994(ra) # 80000c9e <release>
}
    800038c4:	854a                	mv	a0,s2
    800038c6:	70a2                	ld	ra,40(sp)
    800038c8:	7402                	ld	s0,32(sp)
    800038ca:	64e2                	ld	s1,24(sp)
    800038cc:	6942                	ld	s2,16(sp)
    800038ce:	69a2                	ld	s3,8(sp)
    800038d0:	6a02                	ld	s4,0(sp)
    800038d2:	6145                	addi	sp,sp,48
    800038d4:	8082                	ret
    panic("iget: no inodes");
    800038d6:	00005517          	auipc	a0,0x5
    800038da:	d2a50513          	addi	a0,a0,-726 # 80008600 <syscalls+0x160>
    800038de:	ffffd097          	auipc	ra,0xffffd
    800038e2:	c66080e7          	jalr	-922(ra) # 80000544 <panic>

00000000800038e6 <fsinit>:
fsinit(int dev) {
    800038e6:	7179                	addi	sp,sp,-48
    800038e8:	f406                	sd	ra,40(sp)
    800038ea:	f022                	sd	s0,32(sp)
    800038ec:	ec26                	sd	s1,24(sp)
    800038ee:	e84a                	sd	s2,16(sp)
    800038f0:	e44e                	sd	s3,8(sp)
    800038f2:	1800                	addi	s0,sp,48
    800038f4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800038f6:	4585                	li	a1,1
    800038f8:	00000097          	auipc	ra,0x0
    800038fc:	a50080e7          	jalr	-1456(ra) # 80003348 <bread>
    80003900:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003902:	0001c997          	auipc	s3,0x1c
    80003906:	fb698993          	addi	s3,s3,-74 # 8001f8b8 <sb>
    8000390a:	02000613          	li	a2,32
    8000390e:	05850593          	addi	a1,a0,88
    80003912:	854e                	mv	a0,s3
    80003914:	ffffd097          	auipc	ra,0xffffd
    80003918:	432080e7          	jalr	1074(ra) # 80000d46 <memmove>
  brelse(bp);
    8000391c:	8526                	mv	a0,s1
    8000391e:	00000097          	auipc	ra,0x0
    80003922:	b5a080e7          	jalr	-1190(ra) # 80003478 <brelse>
  if(sb.magic != FSMAGIC)
    80003926:	0009a703          	lw	a4,0(s3)
    8000392a:	102037b7          	lui	a5,0x10203
    8000392e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003932:	02f71263          	bne	a4,a5,80003956 <fsinit+0x70>
  initlog(dev, &sb);
    80003936:	0001c597          	auipc	a1,0x1c
    8000393a:	f8258593          	addi	a1,a1,-126 # 8001f8b8 <sb>
    8000393e:	854a                	mv	a0,s2
    80003940:	00001097          	auipc	ra,0x1
    80003944:	b40080e7          	jalr	-1216(ra) # 80004480 <initlog>
}
    80003948:	70a2                	ld	ra,40(sp)
    8000394a:	7402                	ld	s0,32(sp)
    8000394c:	64e2                	ld	s1,24(sp)
    8000394e:	6942                	ld	s2,16(sp)
    80003950:	69a2                	ld	s3,8(sp)
    80003952:	6145                	addi	sp,sp,48
    80003954:	8082                	ret
    panic("invalid file system");
    80003956:	00005517          	auipc	a0,0x5
    8000395a:	cba50513          	addi	a0,a0,-838 # 80008610 <syscalls+0x170>
    8000395e:	ffffd097          	auipc	ra,0xffffd
    80003962:	be6080e7          	jalr	-1050(ra) # 80000544 <panic>

0000000080003966 <iinit>:
{
    80003966:	7179                	addi	sp,sp,-48
    80003968:	f406                	sd	ra,40(sp)
    8000396a:	f022                	sd	s0,32(sp)
    8000396c:	ec26                	sd	s1,24(sp)
    8000396e:	e84a                	sd	s2,16(sp)
    80003970:	e44e                	sd	s3,8(sp)
    80003972:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003974:	00005597          	auipc	a1,0x5
    80003978:	cb458593          	addi	a1,a1,-844 # 80008628 <syscalls+0x188>
    8000397c:	0001c517          	auipc	a0,0x1c
    80003980:	f5c50513          	addi	a0,a0,-164 # 8001f8d8 <itable>
    80003984:	ffffd097          	auipc	ra,0xffffd
    80003988:	1d6080e7          	jalr	470(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    8000398c:	0001c497          	auipc	s1,0x1c
    80003990:	f7448493          	addi	s1,s1,-140 # 8001f900 <itable+0x28>
    80003994:	0001e997          	auipc	s3,0x1e
    80003998:	9fc98993          	addi	s3,s3,-1540 # 80021390 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000399c:	00005917          	auipc	s2,0x5
    800039a0:	c9490913          	addi	s2,s2,-876 # 80008630 <syscalls+0x190>
    800039a4:	85ca                	mv	a1,s2
    800039a6:	8526                	mv	a0,s1
    800039a8:	00001097          	auipc	ra,0x1
    800039ac:	e3a080e7          	jalr	-454(ra) # 800047e2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800039b0:	08848493          	addi	s1,s1,136
    800039b4:	ff3498e3          	bne	s1,s3,800039a4 <iinit+0x3e>
}
    800039b8:	70a2                	ld	ra,40(sp)
    800039ba:	7402                	ld	s0,32(sp)
    800039bc:	64e2                	ld	s1,24(sp)
    800039be:	6942                	ld	s2,16(sp)
    800039c0:	69a2                	ld	s3,8(sp)
    800039c2:	6145                	addi	sp,sp,48
    800039c4:	8082                	ret

00000000800039c6 <ialloc>:
{
    800039c6:	715d                	addi	sp,sp,-80
    800039c8:	e486                	sd	ra,72(sp)
    800039ca:	e0a2                	sd	s0,64(sp)
    800039cc:	fc26                	sd	s1,56(sp)
    800039ce:	f84a                	sd	s2,48(sp)
    800039d0:	f44e                	sd	s3,40(sp)
    800039d2:	f052                	sd	s4,32(sp)
    800039d4:	ec56                	sd	s5,24(sp)
    800039d6:	e85a                	sd	s6,16(sp)
    800039d8:	e45e                	sd	s7,8(sp)
    800039da:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800039dc:	0001c717          	auipc	a4,0x1c
    800039e0:	ee872703          	lw	a4,-280(a4) # 8001f8c4 <sb+0xc>
    800039e4:	4785                	li	a5,1
    800039e6:	04e7fa63          	bgeu	a5,a4,80003a3a <ialloc+0x74>
    800039ea:	8aaa                	mv	s5,a0
    800039ec:	8bae                	mv	s7,a1
    800039ee:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800039f0:	0001ca17          	auipc	s4,0x1c
    800039f4:	ec8a0a13          	addi	s4,s4,-312 # 8001f8b8 <sb>
    800039f8:	00048b1b          	sext.w	s6,s1
    800039fc:	0044d593          	srli	a1,s1,0x4
    80003a00:	018a2783          	lw	a5,24(s4)
    80003a04:	9dbd                	addw	a1,a1,a5
    80003a06:	8556                	mv	a0,s5
    80003a08:	00000097          	auipc	ra,0x0
    80003a0c:	940080e7          	jalr	-1728(ra) # 80003348 <bread>
    80003a10:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a12:	05850993          	addi	s3,a0,88
    80003a16:	00f4f793          	andi	a5,s1,15
    80003a1a:	079a                	slli	a5,a5,0x6
    80003a1c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a1e:	00099783          	lh	a5,0(s3)
    80003a22:	c3a1                	beqz	a5,80003a62 <ialloc+0x9c>
    brelse(bp);
    80003a24:	00000097          	auipc	ra,0x0
    80003a28:	a54080e7          	jalr	-1452(ra) # 80003478 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a2c:	0485                	addi	s1,s1,1
    80003a2e:	00ca2703          	lw	a4,12(s4)
    80003a32:	0004879b          	sext.w	a5,s1
    80003a36:	fce7e1e3          	bltu	a5,a4,800039f8 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003a3a:	00005517          	auipc	a0,0x5
    80003a3e:	bfe50513          	addi	a0,a0,-1026 # 80008638 <syscalls+0x198>
    80003a42:	ffffd097          	auipc	ra,0xffffd
    80003a46:	b4c080e7          	jalr	-1204(ra) # 8000058e <printf>
  return 0;
    80003a4a:	4501                	li	a0,0
}
    80003a4c:	60a6                	ld	ra,72(sp)
    80003a4e:	6406                	ld	s0,64(sp)
    80003a50:	74e2                	ld	s1,56(sp)
    80003a52:	7942                	ld	s2,48(sp)
    80003a54:	79a2                	ld	s3,40(sp)
    80003a56:	7a02                	ld	s4,32(sp)
    80003a58:	6ae2                	ld	s5,24(sp)
    80003a5a:	6b42                	ld	s6,16(sp)
    80003a5c:	6ba2                	ld	s7,8(sp)
    80003a5e:	6161                	addi	sp,sp,80
    80003a60:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a62:	04000613          	li	a2,64
    80003a66:	4581                	li	a1,0
    80003a68:	854e                	mv	a0,s3
    80003a6a:	ffffd097          	auipc	ra,0xffffd
    80003a6e:	27c080e7          	jalr	636(ra) # 80000ce6 <memset>
      dip->type = type;
    80003a72:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a76:	854a                	mv	a0,s2
    80003a78:	00001097          	auipc	ra,0x1
    80003a7c:	c84080e7          	jalr	-892(ra) # 800046fc <log_write>
      brelse(bp);
    80003a80:	854a                	mv	a0,s2
    80003a82:	00000097          	auipc	ra,0x0
    80003a86:	9f6080e7          	jalr	-1546(ra) # 80003478 <brelse>
      return iget(dev, inum);
    80003a8a:	85da                	mv	a1,s6
    80003a8c:	8556                	mv	a0,s5
    80003a8e:	00000097          	auipc	ra,0x0
    80003a92:	d9c080e7          	jalr	-612(ra) # 8000382a <iget>
    80003a96:	bf5d                	j	80003a4c <ialloc+0x86>

0000000080003a98 <iupdate>:
{
    80003a98:	1101                	addi	sp,sp,-32
    80003a9a:	ec06                	sd	ra,24(sp)
    80003a9c:	e822                	sd	s0,16(sp)
    80003a9e:	e426                	sd	s1,8(sp)
    80003aa0:	e04a                	sd	s2,0(sp)
    80003aa2:	1000                	addi	s0,sp,32
    80003aa4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003aa6:	415c                	lw	a5,4(a0)
    80003aa8:	0047d79b          	srliw	a5,a5,0x4
    80003aac:	0001c597          	auipc	a1,0x1c
    80003ab0:	e245a583          	lw	a1,-476(a1) # 8001f8d0 <sb+0x18>
    80003ab4:	9dbd                	addw	a1,a1,a5
    80003ab6:	4108                	lw	a0,0(a0)
    80003ab8:	00000097          	auipc	ra,0x0
    80003abc:	890080e7          	jalr	-1904(ra) # 80003348 <bread>
    80003ac0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ac2:	05850793          	addi	a5,a0,88
    80003ac6:	40c8                	lw	a0,4(s1)
    80003ac8:	893d                	andi	a0,a0,15
    80003aca:	051a                	slli	a0,a0,0x6
    80003acc:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ace:	04449703          	lh	a4,68(s1)
    80003ad2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003ad6:	04649703          	lh	a4,70(s1)
    80003ada:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003ade:	04849703          	lh	a4,72(s1)
    80003ae2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003ae6:	04a49703          	lh	a4,74(s1)
    80003aea:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003aee:	44f8                	lw	a4,76(s1)
    80003af0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003af2:	03400613          	li	a2,52
    80003af6:	05048593          	addi	a1,s1,80
    80003afa:	0531                	addi	a0,a0,12
    80003afc:	ffffd097          	auipc	ra,0xffffd
    80003b00:	24a080e7          	jalr	586(ra) # 80000d46 <memmove>
  log_write(bp);
    80003b04:	854a                	mv	a0,s2
    80003b06:	00001097          	auipc	ra,0x1
    80003b0a:	bf6080e7          	jalr	-1034(ra) # 800046fc <log_write>
  brelse(bp);
    80003b0e:	854a                	mv	a0,s2
    80003b10:	00000097          	auipc	ra,0x0
    80003b14:	968080e7          	jalr	-1688(ra) # 80003478 <brelse>
}
    80003b18:	60e2                	ld	ra,24(sp)
    80003b1a:	6442                	ld	s0,16(sp)
    80003b1c:	64a2                	ld	s1,8(sp)
    80003b1e:	6902                	ld	s2,0(sp)
    80003b20:	6105                	addi	sp,sp,32
    80003b22:	8082                	ret

0000000080003b24 <idup>:
{
    80003b24:	1101                	addi	sp,sp,-32
    80003b26:	ec06                	sd	ra,24(sp)
    80003b28:	e822                	sd	s0,16(sp)
    80003b2a:	e426                	sd	s1,8(sp)
    80003b2c:	1000                	addi	s0,sp,32
    80003b2e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b30:	0001c517          	auipc	a0,0x1c
    80003b34:	da850513          	addi	a0,a0,-600 # 8001f8d8 <itable>
    80003b38:	ffffd097          	auipc	ra,0xffffd
    80003b3c:	0b2080e7          	jalr	178(ra) # 80000bea <acquire>
  ip->ref++;
    80003b40:	449c                	lw	a5,8(s1)
    80003b42:	2785                	addiw	a5,a5,1
    80003b44:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b46:	0001c517          	auipc	a0,0x1c
    80003b4a:	d9250513          	addi	a0,a0,-622 # 8001f8d8 <itable>
    80003b4e:	ffffd097          	auipc	ra,0xffffd
    80003b52:	150080e7          	jalr	336(ra) # 80000c9e <release>
}
    80003b56:	8526                	mv	a0,s1
    80003b58:	60e2                	ld	ra,24(sp)
    80003b5a:	6442                	ld	s0,16(sp)
    80003b5c:	64a2                	ld	s1,8(sp)
    80003b5e:	6105                	addi	sp,sp,32
    80003b60:	8082                	ret

0000000080003b62 <ilock>:
{
    80003b62:	1101                	addi	sp,sp,-32
    80003b64:	ec06                	sd	ra,24(sp)
    80003b66:	e822                	sd	s0,16(sp)
    80003b68:	e426                	sd	s1,8(sp)
    80003b6a:	e04a                	sd	s2,0(sp)
    80003b6c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b6e:	c115                	beqz	a0,80003b92 <ilock+0x30>
    80003b70:	84aa                	mv	s1,a0
    80003b72:	451c                	lw	a5,8(a0)
    80003b74:	00f05f63          	blez	a5,80003b92 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b78:	0541                	addi	a0,a0,16
    80003b7a:	00001097          	auipc	ra,0x1
    80003b7e:	ca2080e7          	jalr	-862(ra) # 8000481c <acquiresleep>
  if(ip->valid == 0){
    80003b82:	40bc                	lw	a5,64(s1)
    80003b84:	cf99                	beqz	a5,80003ba2 <ilock+0x40>
}
    80003b86:	60e2                	ld	ra,24(sp)
    80003b88:	6442                	ld	s0,16(sp)
    80003b8a:	64a2                	ld	s1,8(sp)
    80003b8c:	6902                	ld	s2,0(sp)
    80003b8e:	6105                	addi	sp,sp,32
    80003b90:	8082                	ret
    panic("ilock");
    80003b92:	00005517          	auipc	a0,0x5
    80003b96:	abe50513          	addi	a0,a0,-1346 # 80008650 <syscalls+0x1b0>
    80003b9a:	ffffd097          	auipc	ra,0xffffd
    80003b9e:	9aa080e7          	jalr	-1622(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ba2:	40dc                	lw	a5,4(s1)
    80003ba4:	0047d79b          	srliw	a5,a5,0x4
    80003ba8:	0001c597          	auipc	a1,0x1c
    80003bac:	d285a583          	lw	a1,-728(a1) # 8001f8d0 <sb+0x18>
    80003bb0:	9dbd                	addw	a1,a1,a5
    80003bb2:	4088                	lw	a0,0(s1)
    80003bb4:	fffff097          	auipc	ra,0xfffff
    80003bb8:	794080e7          	jalr	1940(ra) # 80003348 <bread>
    80003bbc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bbe:	05850593          	addi	a1,a0,88
    80003bc2:	40dc                	lw	a5,4(s1)
    80003bc4:	8bbd                	andi	a5,a5,15
    80003bc6:	079a                	slli	a5,a5,0x6
    80003bc8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003bca:	00059783          	lh	a5,0(a1)
    80003bce:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003bd2:	00259783          	lh	a5,2(a1)
    80003bd6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003bda:	00459783          	lh	a5,4(a1)
    80003bde:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003be2:	00659783          	lh	a5,6(a1)
    80003be6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003bea:	459c                	lw	a5,8(a1)
    80003bec:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003bee:	03400613          	li	a2,52
    80003bf2:	05b1                	addi	a1,a1,12
    80003bf4:	05048513          	addi	a0,s1,80
    80003bf8:	ffffd097          	auipc	ra,0xffffd
    80003bfc:	14e080e7          	jalr	334(ra) # 80000d46 <memmove>
    brelse(bp);
    80003c00:	854a                	mv	a0,s2
    80003c02:	00000097          	auipc	ra,0x0
    80003c06:	876080e7          	jalr	-1930(ra) # 80003478 <brelse>
    ip->valid = 1;
    80003c0a:	4785                	li	a5,1
    80003c0c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c0e:	04449783          	lh	a5,68(s1)
    80003c12:	fbb5                	bnez	a5,80003b86 <ilock+0x24>
      panic("ilock: no type");
    80003c14:	00005517          	auipc	a0,0x5
    80003c18:	a4450513          	addi	a0,a0,-1468 # 80008658 <syscalls+0x1b8>
    80003c1c:	ffffd097          	auipc	ra,0xffffd
    80003c20:	928080e7          	jalr	-1752(ra) # 80000544 <panic>

0000000080003c24 <iunlock>:
{
    80003c24:	1101                	addi	sp,sp,-32
    80003c26:	ec06                	sd	ra,24(sp)
    80003c28:	e822                	sd	s0,16(sp)
    80003c2a:	e426                	sd	s1,8(sp)
    80003c2c:	e04a                	sd	s2,0(sp)
    80003c2e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c30:	c905                	beqz	a0,80003c60 <iunlock+0x3c>
    80003c32:	84aa                	mv	s1,a0
    80003c34:	01050913          	addi	s2,a0,16
    80003c38:	854a                	mv	a0,s2
    80003c3a:	00001097          	auipc	ra,0x1
    80003c3e:	c7c080e7          	jalr	-900(ra) # 800048b6 <holdingsleep>
    80003c42:	cd19                	beqz	a0,80003c60 <iunlock+0x3c>
    80003c44:	449c                	lw	a5,8(s1)
    80003c46:	00f05d63          	blez	a5,80003c60 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c4a:	854a                	mv	a0,s2
    80003c4c:	00001097          	auipc	ra,0x1
    80003c50:	c26080e7          	jalr	-986(ra) # 80004872 <releasesleep>
}
    80003c54:	60e2                	ld	ra,24(sp)
    80003c56:	6442                	ld	s0,16(sp)
    80003c58:	64a2                	ld	s1,8(sp)
    80003c5a:	6902                	ld	s2,0(sp)
    80003c5c:	6105                	addi	sp,sp,32
    80003c5e:	8082                	ret
    panic("iunlock");
    80003c60:	00005517          	auipc	a0,0x5
    80003c64:	a0850513          	addi	a0,a0,-1528 # 80008668 <syscalls+0x1c8>
    80003c68:	ffffd097          	auipc	ra,0xffffd
    80003c6c:	8dc080e7          	jalr	-1828(ra) # 80000544 <panic>

0000000080003c70 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c70:	7179                	addi	sp,sp,-48
    80003c72:	f406                	sd	ra,40(sp)
    80003c74:	f022                	sd	s0,32(sp)
    80003c76:	ec26                	sd	s1,24(sp)
    80003c78:	e84a                	sd	s2,16(sp)
    80003c7a:	e44e                	sd	s3,8(sp)
    80003c7c:	e052                	sd	s4,0(sp)
    80003c7e:	1800                	addi	s0,sp,48
    80003c80:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c82:	05050493          	addi	s1,a0,80
    80003c86:	08050913          	addi	s2,a0,128
    80003c8a:	a021                	j	80003c92 <itrunc+0x22>
    80003c8c:	0491                	addi	s1,s1,4
    80003c8e:	01248d63          	beq	s1,s2,80003ca8 <itrunc+0x38>
    if(ip->addrs[i]){
    80003c92:	408c                	lw	a1,0(s1)
    80003c94:	dde5                	beqz	a1,80003c8c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c96:	0009a503          	lw	a0,0(s3)
    80003c9a:	00000097          	auipc	ra,0x0
    80003c9e:	8f4080e7          	jalr	-1804(ra) # 8000358e <bfree>
      ip->addrs[i] = 0;
    80003ca2:	0004a023          	sw	zero,0(s1)
    80003ca6:	b7dd                	j	80003c8c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ca8:	0809a583          	lw	a1,128(s3)
    80003cac:	e185                	bnez	a1,80003ccc <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003cae:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003cb2:	854e                	mv	a0,s3
    80003cb4:	00000097          	auipc	ra,0x0
    80003cb8:	de4080e7          	jalr	-540(ra) # 80003a98 <iupdate>
}
    80003cbc:	70a2                	ld	ra,40(sp)
    80003cbe:	7402                	ld	s0,32(sp)
    80003cc0:	64e2                	ld	s1,24(sp)
    80003cc2:	6942                	ld	s2,16(sp)
    80003cc4:	69a2                	ld	s3,8(sp)
    80003cc6:	6a02                	ld	s4,0(sp)
    80003cc8:	6145                	addi	sp,sp,48
    80003cca:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ccc:	0009a503          	lw	a0,0(s3)
    80003cd0:	fffff097          	auipc	ra,0xfffff
    80003cd4:	678080e7          	jalr	1656(ra) # 80003348 <bread>
    80003cd8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003cda:	05850493          	addi	s1,a0,88
    80003cde:	45850913          	addi	s2,a0,1112
    80003ce2:	a811                	j	80003cf6 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003ce4:	0009a503          	lw	a0,0(s3)
    80003ce8:	00000097          	auipc	ra,0x0
    80003cec:	8a6080e7          	jalr	-1882(ra) # 8000358e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003cf0:	0491                	addi	s1,s1,4
    80003cf2:	01248563          	beq	s1,s2,80003cfc <itrunc+0x8c>
      if(a[j])
    80003cf6:	408c                	lw	a1,0(s1)
    80003cf8:	dde5                	beqz	a1,80003cf0 <itrunc+0x80>
    80003cfa:	b7ed                	j	80003ce4 <itrunc+0x74>
    brelse(bp);
    80003cfc:	8552                	mv	a0,s4
    80003cfe:	fffff097          	auipc	ra,0xfffff
    80003d02:	77a080e7          	jalr	1914(ra) # 80003478 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d06:	0809a583          	lw	a1,128(s3)
    80003d0a:	0009a503          	lw	a0,0(s3)
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	880080e7          	jalr	-1920(ra) # 8000358e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d16:	0809a023          	sw	zero,128(s3)
    80003d1a:	bf51                	j	80003cae <itrunc+0x3e>

0000000080003d1c <iput>:
{
    80003d1c:	1101                	addi	sp,sp,-32
    80003d1e:	ec06                	sd	ra,24(sp)
    80003d20:	e822                	sd	s0,16(sp)
    80003d22:	e426                	sd	s1,8(sp)
    80003d24:	e04a                	sd	s2,0(sp)
    80003d26:	1000                	addi	s0,sp,32
    80003d28:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d2a:	0001c517          	auipc	a0,0x1c
    80003d2e:	bae50513          	addi	a0,a0,-1106 # 8001f8d8 <itable>
    80003d32:	ffffd097          	auipc	ra,0xffffd
    80003d36:	eb8080e7          	jalr	-328(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d3a:	4498                	lw	a4,8(s1)
    80003d3c:	4785                	li	a5,1
    80003d3e:	02f70363          	beq	a4,a5,80003d64 <iput+0x48>
  ip->ref--;
    80003d42:	449c                	lw	a5,8(s1)
    80003d44:	37fd                	addiw	a5,a5,-1
    80003d46:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d48:	0001c517          	auipc	a0,0x1c
    80003d4c:	b9050513          	addi	a0,a0,-1136 # 8001f8d8 <itable>
    80003d50:	ffffd097          	auipc	ra,0xffffd
    80003d54:	f4e080e7          	jalr	-178(ra) # 80000c9e <release>
}
    80003d58:	60e2                	ld	ra,24(sp)
    80003d5a:	6442                	ld	s0,16(sp)
    80003d5c:	64a2                	ld	s1,8(sp)
    80003d5e:	6902                	ld	s2,0(sp)
    80003d60:	6105                	addi	sp,sp,32
    80003d62:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d64:	40bc                	lw	a5,64(s1)
    80003d66:	dff1                	beqz	a5,80003d42 <iput+0x26>
    80003d68:	04a49783          	lh	a5,74(s1)
    80003d6c:	fbf9                	bnez	a5,80003d42 <iput+0x26>
    acquiresleep(&ip->lock);
    80003d6e:	01048913          	addi	s2,s1,16
    80003d72:	854a                	mv	a0,s2
    80003d74:	00001097          	auipc	ra,0x1
    80003d78:	aa8080e7          	jalr	-1368(ra) # 8000481c <acquiresleep>
    release(&itable.lock);
    80003d7c:	0001c517          	auipc	a0,0x1c
    80003d80:	b5c50513          	addi	a0,a0,-1188 # 8001f8d8 <itable>
    80003d84:	ffffd097          	auipc	ra,0xffffd
    80003d88:	f1a080e7          	jalr	-230(ra) # 80000c9e <release>
    itrunc(ip);
    80003d8c:	8526                	mv	a0,s1
    80003d8e:	00000097          	auipc	ra,0x0
    80003d92:	ee2080e7          	jalr	-286(ra) # 80003c70 <itrunc>
    ip->type = 0;
    80003d96:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d9a:	8526                	mv	a0,s1
    80003d9c:	00000097          	auipc	ra,0x0
    80003da0:	cfc080e7          	jalr	-772(ra) # 80003a98 <iupdate>
    ip->valid = 0;
    80003da4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003da8:	854a                	mv	a0,s2
    80003daa:	00001097          	auipc	ra,0x1
    80003dae:	ac8080e7          	jalr	-1336(ra) # 80004872 <releasesleep>
    acquire(&itable.lock);
    80003db2:	0001c517          	auipc	a0,0x1c
    80003db6:	b2650513          	addi	a0,a0,-1242 # 8001f8d8 <itable>
    80003dba:	ffffd097          	auipc	ra,0xffffd
    80003dbe:	e30080e7          	jalr	-464(ra) # 80000bea <acquire>
    80003dc2:	b741                	j	80003d42 <iput+0x26>

0000000080003dc4 <iunlockput>:
{
    80003dc4:	1101                	addi	sp,sp,-32
    80003dc6:	ec06                	sd	ra,24(sp)
    80003dc8:	e822                	sd	s0,16(sp)
    80003dca:	e426                	sd	s1,8(sp)
    80003dcc:	1000                	addi	s0,sp,32
    80003dce:	84aa                	mv	s1,a0
  iunlock(ip);
    80003dd0:	00000097          	auipc	ra,0x0
    80003dd4:	e54080e7          	jalr	-428(ra) # 80003c24 <iunlock>
  iput(ip);
    80003dd8:	8526                	mv	a0,s1
    80003dda:	00000097          	auipc	ra,0x0
    80003dde:	f42080e7          	jalr	-190(ra) # 80003d1c <iput>
}
    80003de2:	60e2                	ld	ra,24(sp)
    80003de4:	6442                	ld	s0,16(sp)
    80003de6:	64a2                	ld	s1,8(sp)
    80003de8:	6105                	addi	sp,sp,32
    80003dea:	8082                	ret

0000000080003dec <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003dec:	1141                	addi	sp,sp,-16
    80003dee:	e422                	sd	s0,8(sp)
    80003df0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003df2:	411c                	lw	a5,0(a0)
    80003df4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003df6:	415c                	lw	a5,4(a0)
    80003df8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003dfa:	04451783          	lh	a5,68(a0)
    80003dfe:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e02:	04a51783          	lh	a5,74(a0)
    80003e06:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e0a:	04c56783          	lwu	a5,76(a0)
    80003e0e:	e99c                	sd	a5,16(a1)
}
    80003e10:	6422                	ld	s0,8(sp)
    80003e12:	0141                	addi	sp,sp,16
    80003e14:	8082                	ret

0000000080003e16 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e16:	457c                	lw	a5,76(a0)
    80003e18:	0ed7e963          	bltu	a5,a3,80003f0a <readi+0xf4>
{
    80003e1c:	7159                	addi	sp,sp,-112
    80003e1e:	f486                	sd	ra,104(sp)
    80003e20:	f0a2                	sd	s0,96(sp)
    80003e22:	eca6                	sd	s1,88(sp)
    80003e24:	e8ca                	sd	s2,80(sp)
    80003e26:	e4ce                	sd	s3,72(sp)
    80003e28:	e0d2                	sd	s4,64(sp)
    80003e2a:	fc56                	sd	s5,56(sp)
    80003e2c:	f85a                	sd	s6,48(sp)
    80003e2e:	f45e                	sd	s7,40(sp)
    80003e30:	f062                	sd	s8,32(sp)
    80003e32:	ec66                	sd	s9,24(sp)
    80003e34:	e86a                	sd	s10,16(sp)
    80003e36:	e46e                	sd	s11,8(sp)
    80003e38:	1880                	addi	s0,sp,112
    80003e3a:	8b2a                	mv	s6,a0
    80003e3c:	8bae                	mv	s7,a1
    80003e3e:	8a32                	mv	s4,a2
    80003e40:	84b6                	mv	s1,a3
    80003e42:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e44:	9f35                	addw	a4,a4,a3
    return 0;
    80003e46:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e48:	0ad76063          	bltu	a4,a3,80003ee8 <readi+0xd2>
  if(off + n > ip->size)
    80003e4c:	00e7f463          	bgeu	a5,a4,80003e54 <readi+0x3e>
    n = ip->size - off;
    80003e50:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e54:	0a0a8963          	beqz	s5,80003f06 <readi+0xf0>
    80003e58:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e5a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e5e:	5c7d                	li	s8,-1
    80003e60:	a82d                	j	80003e9a <readi+0x84>
    80003e62:	020d1d93          	slli	s11,s10,0x20
    80003e66:	020ddd93          	srli	s11,s11,0x20
    80003e6a:	05890613          	addi	a2,s2,88
    80003e6e:	86ee                	mv	a3,s11
    80003e70:	963a                	add	a2,a2,a4
    80003e72:	85d2                	mv	a1,s4
    80003e74:	855e                	mv	a0,s7
    80003e76:	ffffe097          	auipc	ra,0xffffe
    80003e7a:	6dc080e7          	jalr	1756(ra) # 80002552 <either_copyout>
    80003e7e:	05850d63          	beq	a0,s8,80003ed8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e82:	854a                	mv	a0,s2
    80003e84:	fffff097          	auipc	ra,0xfffff
    80003e88:	5f4080e7          	jalr	1524(ra) # 80003478 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e8c:	013d09bb          	addw	s3,s10,s3
    80003e90:	009d04bb          	addw	s1,s10,s1
    80003e94:	9a6e                	add	s4,s4,s11
    80003e96:	0559f763          	bgeu	s3,s5,80003ee4 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003e9a:	00a4d59b          	srliw	a1,s1,0xa
    80003e9e:	855a                	mv	a0,s6
    80003ea0:	00000097          	auipc	ra,0x0
    80003ea4:	8a2080e7          	jalr	-1886(ra) # 80003742 <bmap>
    80003ea8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003eac:	cd85                	beqz	a1,80003ee4 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003eae:	000b2503          	lw	a0,0(s6)
    80003eb2:	fffff097          	auipc	ra,0xfffff
    80003eb6:	496080e7          	jalr	1174(ra) # 80003348 <bread>
    80003eba:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ebc:	3ff4f713          	andi	a4,s1,1023
    80003ec0:	40ec87bb          	subw	a5,s9,a4
    80003ec4:	413a86bb          	subw	a3,s5,s3
    80003ec8:	8d3e                	mv	s10,a5
    80003eca:	2781                	sext.w	a5,a5
    80003ecc:	0006861b          	sext.w	a2,a3
    80003ed0:	f8f679e3          	bgeu	a2,a5,80003e62 <readi+0x4c>
    80003ed4:	8d36                	mv	s10,a3
    80003ed6:	b771                	j	80003e62 <readi+0x4c>
      brelse(bp);
    80003ed8:	854a                	mv	a0,s2
    80003eda:	fffff097          	auipc	ra,0xfffff
    80003ede:	59e080e7          	jalr	1438(ra) # 80003478 <brelse>
      tot = -1;
    80003ee2:	59fd                	li	s3,-1
  }
  return tot;
    80003ee4:	0009851b          	sext.w	a0,s3
}
    80003ee8:	70a6                	ld	ra,104(sp)
    80003eea:	7406                	ld	s0,96(sp)
    80003eec:	64e6                	ld	s1,88(sp)
    80003eee:	6946                	ld	s2,80(sp)
    80003ef0:	69a6                	ld	s3,72(sp)
    80003ef2:	6a06                	ld	s4,64(sp)
    80003ef4:	7ae2                	ld	s5,56(sp)
    80003ef6:	7b42                	ld	s6,48(sp)
    80003ef8:	7ba2                	ld	s7,40(sp)
    80003efa:	7c02                	ld	s8,32(sp)
    80003efc:	6ce2                	ld	s9,24(sp)
    80003efe:	6d42                	ld	s10,16(sp)
    80003f00:	6da2                	ld	s11,8(sp)
    80003f02:	6165                	addi	sp,sp,112
    80003f04:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f06:	89d6                	mv	s3,s5
    80003f08:	bff1                	j	80003ee4 <readi+0xce>
    return 0;
    80003f0a:	4501                	li	a0,0
}
    80003f0c:	8082                	ret

0000000080003f0e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f0e:	457c                	lw	a5,76(a0)
    80003f10:	10d7e863          	bltu	a5,a3,80004020 <writei+0x112>
{
    80003f14:	7159                	addi	sp,sp,-112
    80003f16:	f486                	sd	ra,104(sp)
    80003f18:	f0a2                	sd	s0,96(sp)
    80003f1a:	eca6                	sd	s1,88(sp)
    80003f1c:	e8ca                	sd	s2,80(sp)
    80003f1e:	e4ce                	sd	s3,72(sp)
    80003f20:	e0d2                	sd	s4,64(sp)
    80003f22:	fc56                	sd	s5,56(sp)
    80003f24:	f85a                	sd	s6,48(sp)
    80003f26:	f45e                	sd	s7,40(sp)
    80003f28:	f062                	sd	s8,32(sp)
    80003f2a:	ec66                	sd	s9,24(sp)
    80003f2c:	e86a                	sd	s10,16(sp)
    80003f2e:	e46e                	sd	s11,8(sp)
    80003f30:	1880                	addi	s0,sp,112
    80003f32:	8aaa                	mv	s5,a0
    80003f34:	8bae                	mv	s7,a1
    80003f36:	8a32                	mv	s4,a2
    80003f38:	8936                	mv	s2,a3
    80003f3a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f3c:	00e687bb          	addw	a5,a3,a4
    80003f40:	0ed7e263          	bltu	a5,a3,80004024 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f44:	00043737          	lui	a4,0x43
    80003f48:	0ef76063          	bltu	a4,a5,80004028 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f4c:	0c0b0863          	beqz	s6,8000401c <writei+0x10e>
    80003f50:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f52:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f56:	5c7d                	li	s8,-1
    80003f58:	a091                	j	80003f9c <writei+0x8e>
    80003f5a:	020d1d93          	slli	s11,s10,0x20
    80003f5e:	020ddd93          	srli	s11,s11,0x20
    80003f62:	05848513          	addi	a0,s1,88
    80003f66:	86ee                	mv	a3,s11
    80003f68:	8652                	mv	a2,s4
    80003f6a:	85de                	mv	a1,s7
    80003f6c:	953a                	add	a0,a0,a4
    80003f6e:	ffffe097          	auipc	ra,0xffffe
    80003f72:	63a080e7          	jalr	1594(ra) # 800025a8 <either_copyin>
    80003f76:	07850263          	beq	a0,s8,80003fda <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	00000097          	auipc	ra,0x0
    80003f80:	780080e7          	jalr	1920(ra) # 800046fc <log_write>
    brelse(bp);
    80003f84:	8526                	mv	a0,s1
    80003f86:	fffff097          	auipc	ra,0xfffff
    80003f8a:	4f2080e7          	jalr	1266(ra) # 80003478 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f8e:	013d09bb          	addw	s3,s10,s3
    80003f92:	012d093b          	addw	s2,s10,s2
    80003f96:	9a6e                	add	s4,s4,s11
    80003f98:	0569f663          	bgeu	s3,s6,80003fe4 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003f9c:	00a9559b          	srliw	a1,s2,0xa
    80003fa0:	8556                	mv	a0,s5
    80003fa2:	fffff097          	auipc	ra,0xfffff
    80003fa6:	7a0080e7          	jalr	1952(ra) # 80003742 <bmap>
    80003faa:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fae:	c99d                	beqz	a1,80003fe4 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003fb0:	000aa503          	lw	a0,0(s5)
    80003fb4:	fffff097          	auipc	ra,0xfffff
    80003fb8:	394080e7          	jalr	916(ra) # 80003348 <bread>
    80003fbc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fbe:	3ff97713          	andi	a4,s2,1023
    80003fc2:	40ec87bb          	subw	a5,s9,a4
    80003fc6:	413b06bb          	subw	a3,s6,s3
    80003fca:	8d3e                	mv	s10,a5
    80003fcc:	2781                	sext.w	a5,a5
    80003fce:	0006861b          	sext.w	a2,a3
    80003fd2:	f8f674e3          	bgeu	a2,a5,80003f5a <writei+0x4c>
    80003fd6:	8d36                	mv	s10,a3
    80003fd8:	b749                	j	80003f5a <writei+0x4c>
      brelse(bp);
    80003fda:	8526                	mv	a0,s1
    80003fdc:	fffff097          	auipc	ra,0xfffff
    80003fe0:	49c080e7          	jalr	1180(ra) # 80003478 <brelse>
  }

  if(off > ip->size)
    80003fe4:	04caa783          	lw	a5,76(s5)
    80003fe8:	0127f463          	bgeu	a5,s2,80003ff0 <writei+0xe2>
    ip->size = off;
    80003fec:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ff0:	8556                	mv	a0,s5
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	aa6080e7          	jalr	-1370(ra) # 80003a98 <iupdate>

  return tot;
    80003ffa:	0009851b          	sext.w	a0,s3
}
    80003ffe:	70a6                	ld	ra,104(sp)
    80004000:	7406                	ld	s0,96(sp)
    80004002:	64e6                	ld	s1,88(sp)
    80004004:	6946                	ld	s2,80(sp)
    80004006:	69a6                	ld	s3,72(sp)
    80004008:	6a06                	ld	s4,64(sp)
    8000400a:	7ae2                	ld	s5,56(sp)
    8000400c:	7b42                	ld	s6,48(sp)
    8000400e:	7ba2                	ld	s7,40(sp)
    80004010:	7c02                	ld	s8,32(sp)
    80004012:	6ce2                	ld	s9,24(sp)
    80004014:	6d42                	ld	s10,16(sp)
    80004016:	6da2                	ld	s11,8(sp)
    80004018:	6165                	addi	sp,sp,112
    8000401a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000401c:	89da                	mv	s3,s6
    8000401e:	bfc9                	j	80003ff0 <writei+0xe2>
    return -1;
    80004020:	557d                	li	a0,-1
}
    80004022:	8082                	ret
    return -1;
    80004024:	557d                	li	a0,-1
    80004026:	bfe1                	j	80003ffe <writei+0xf0>
    return -1;
    80004028:	557d                	li	a0,-1
    8000402a:	bfd1                	j	80003ffe <writei+0xf0>

000000008000402c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000402c:	1141                	addi	sp,sp,-16
    8000402e:	e406                	sd	ra,8(sp)
    80004030:	e022                	sd	s0,0(sp)
    80004032:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004034:	4639                	li	a2,14
    80004036:	ffffd097          	auipc	ra,0xffffd
    8000403a:	d88080e7          	jalr	-632(ra) # 80000dbe <strncmp>
}
    8000403e:	60a2                	ld	ra,8(sp)
    80004040:	6402                	ld	s0,0(sp)
    80004042:	0141                	addi	sp,sp,16
    80004044:	8082                	ret

0000000080004046 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004046:	7139                	addi	sp,sp,-64
    80004048:	fc06                	sd	ra,56(sp)
    8000404a:	f822                	sd	s0,48(sp)
    8000404c:	f426                	sd	s1,40(sp)
    8000404e:	f04a                	sd	s2,32(sp)
    80004050:	ec4e                	sd	s3,24(sp)
    80004052:	e852                	sd	s4,16(sp)
    80004054:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004056:	04451703          	lh	a4,68(a0)
    8000405a:	4785                	li	a5,1
    8000405c:	00f71a63          	bne	a4,a5,80004070 <dirlookup+0x2a>
    80004060:	892a                	mv	s2,a0
    80004062:	89ae                	mv	s3,a1
    80004064:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004066:	457c                	lw	a5,76(a0)
    80004068:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000406a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000406c:	e79d                	bnez	a5,8000409a <dirlookup+0x54>
    8000406e:	a8a5                	j	800040e6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004070:	00004517          	auipc	a0,0x4
    80004074:	60050513          	addi	a0,a0,1536 # 80008670 <syscalls+0x1d0>
    80004078:	ffffc097          	auipc	ra,0xffffc
    8000407c:	4cc080e7          	jalr	1228(ra) # 80000544 <panic>
      panic("dirlookup read");
    80004080:	00004517          	auipc	a0,0x4
    80004084:	60850513          	addi	a0,a0,1544 # 80008688 <syscalls+0x1e8>
    80004088:	ffffc097          	auipc	ra,0xffffc
    8000408c:	4bc080e7          	jalr	1212(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004090:	24c1                	addiw	s1,s1,16
    80004092:	04c92783          	lw	a5,76(s2)
    80004096:	04f4f763          	bgeu	s1,a5,800040e4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000409a:	4741                	li	a4,16
    8000409c:	86a6                	mv	a3,s1
    8000409e:	fc040613          	addi	a2,s0,-64
    800040a2:	4581                	li	a1,0
    800040a4:	854a                	mv	a0,s2
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	d70080e7          	jalr	-656(ra) # 80003e16 <readi>
    800040ae:	47c1                	li	a5,16
    800040b0:	fcf518e3          	bne	a0,a5,80004080 <dirlookup+0x3a>
    if(de.inum == 0)
    800040b4:	fc045783          	lhu	a5,-64(s0)
    800040b8:	dfe1                	beqz	a5,80004090 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800040ba:	fc240593          	addi	a1,s0,-62
    800040be:	854e                	mv	a0,s3
    800040c0:	00000097          	auipc	ra,0x0
    800040c4:	f6c080e7          	jalr	-148(ra) # 8000402c <namecmp>
    800040c8:	f561                	bnez	a0,80004090 <dirlookup+0x4a>
      if(poff)
    800040ca:	000a0463          	beqz	s4,800040d2 <dirlookup+0x8c>
        *poff = off;
    800040ce:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800040d2:	fc045583          	lhu	a1,-64(s0)
    800040d6:	00092503          	lw	a0,0(s2)
    800040da:	fffff097          	auipc	ra,0xfffff
    800040de:	750080e7          	jalr	1872(ra) # 8000382a <iget>
    800040e2:	a011                	j	800040e6 <dirlookup+0xa0>
  return 0;
    800040e4:	4501                	li	a0,0
}
    800040e6:	70e2                	ld	ra,56(sp)
    800040e8:	7442                	ld	s0,48(sp)
    800040ea:	74a2                	ld	s1,40(sp)
    800040ec:	7902                	ld	s2,32(sp)
    800040ee:	69e2                	ld	s3,24(sp)
    800040f0:	6a42                	ld	s4,16(sp)
    800040f2:	6121                	addi	sp,sp,64
    800040f4:	8082                	ret

00000000800040f6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040f6:	711d                	addi	sp,sp,-96
    800040f8:	ec86                	sd	ra,88(sp)
    800040fa:	e8a2                	sd	s0,80(sp)
    800040fc:	e4a6                	sd	s1,72(sp)
    800040fe:	e0ca                	sd	s2,64(sp)
    80004100:	fc4e                	sd	s3,56(sp)
    80004102:	f852                	sd	s4,48(sp)
    80004104:	f456                	sd	s5,40(sp)
    80004106:	f05a                	sd	s6,32(sp)
    80004108:	ec5e                	sd	s7,24(sp)
    8000410a:	e862                	sd	s8,16(sp)
    8000410c:	e466                	sd	s9,8(sp)
    8000410e:	1080                	addi	s0,sp,96
    80004110:	84aa                	mv	s1,a0
    80004112:	8b2e                	mv	s6,a1
    80004114:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004116:	00054703          	lbu	a4,0(a0)
    8000411a:	02f00793          	li	a5,47
    8000411e:	02f70363          	beq	a4,a5,80004144 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004122:	ffffe097          	auipc	ra,0xffffe
    80004126:	8a4080e7          	jalr	-1884(ra) # 800019c6 <myproc>
    8000412a:	15053503          	ld	a0,336(a0)
    8000412e:	00000097          	auipc	ra,0x0
    80004132:	9f6080e7          	jalr	-1546(ra) # 80003b24 <idup>
    80004136:	89aa                	mv	s3,a0
  while(*path == '/')
    80004138:	02f00913          	li	s2,47
  len = path - s;
    8000413c:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000413e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004140:	4c05                	li	s8,1
    80004142:	a865                	j	800041fa <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004144:	4585                	li	a1,1
    80004146:	4505                	li	a0,1
    80004148:	fffff097          	auipc	ra,0xfffff
    8000414c:	6e2080e7          	jalr	1762(ra) # 8000382a <iget>
    80004150:	89aa                	mv	s3,a0
    80004152:	b7dd                	j	80004138 <namex+0x42>
      iunlockput(ip);
    80004154:	854e                	mv	a0,s3
    80004156:	00000097          	auipc	ra,0x0
    8000415a:	c6e080e7          	jalr	-914(ra) # 80003dc4 <iunlockput>
      return 0;
    8000415e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004160:	854e                	mv	a0,s3
    80004162:	60e6                	ld	ra,88(sp)
    80004164:	6446                	ld	s0,80(sp)
    80004166:	64a6                	ld	s1,72(sp)
    80004168:	6906                	ld	s2,64(sp)
    8000416a:	79e2                	ld	s3,56(sp)
    8000416c:	7a42                	ld	s4,48(sp)
    8000416e:	7aa2                	ld	s5,40(sp)
    80004170:	7b02                	ld	s6,32(sp)
    80004172:	6be2                	ld	s7,24(sp)
    80004174:	6c42                	ld	s8,16(sp)
    80004176:	6ca2                	ld	s9,8(sp)
    80004178:	6125                	addi	sp,sp,96
    8000417a:	8082                	ret
      iunlock(ip);
    8000417c:	854e                	mv	a0,s3
    8000417e:	00000097          	auipc	ra,0x0
    80004182:	aa6080e7          	jalr	-1370(ra) # 80003c24 <iunlock>
      return ip;
    80004186:	bfe9                	j	80004160 <namex+0x6a>
      iunlockput(ip);
    80004188:	854e                	mv	a0,s3
    8000418a:	00000097          	auipc	ra,0x0
    8000418e:	c3a080e7          	jalr	-966(ra) # 80003dc4 <iunlockput>
      return 0;
    80004192:	89d2                	mv	s3,s4
    80004194:	b7f1                	j	80004160 <namex+0x6a>
  len = path - s;
    80004196:	40b48633          	sub	a2,s1,a1
    8000419a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    8000419e:	094cd463          	bge	s9,s4,80004226 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800041a2:	4639                	li	a2,14
    800041a4:	8556                	mv	a0,s5
    800041a6:	ffffd097          	auipc	ra,0xffffd
    800041aa:	ba0080e7          	jalr	-1120(ra) # 80000d46 <memmove>
  while(*path == '/')
    800041ae:	0004c783          	lbu	a5,0(s1)
    800041b2:	01279763          	bne	a5,s2,800041c0 <namex+0xca>
    path++;
    800041b6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041b8:	0004c783          	lbu	a5,0(s1)
    800041bc:	ff278de3          	beq	a5,s2,800041b6 <namex+0xc0>
    ilock(ip);
    800041c0:	854e                	mv	a0,s3
    800041c2:	00000097          	auipc	ra,0x0
    800041c6:	9a0080e7          	jalr	-1632(ra) # 80003b62 <ilock>
    if(ip->type != T_DIR){
    800041ca:	04499783          	lh	a5,68(s3)
    800041ce:	f98793e3          	bne	a5,s8,80004154 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800041d2:	000b0563          	beqz	s6,800041dc <namex+0xe6>
    800041d6:	0004c783          	lbu	a5,0(s1)
    800041da:	d3cd                	beqz	a5,8000417c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800041dc:	865e                	mv	a2,s7
    800041de:	85d6                	mv	a1,s5
    800041e0:	854e                	mv	a0,s3
    800041e2:	00000097          	auipc	ra,0x0
    800041e6:	e64080e7          	jalr	-412(ra) # 80004046 <dirlookup>
    800041ea:	8a2a                	mv	s4,a0
    800041ec:	dd51                	beqz	a0,80004188 <namex+0x92>
    iunlockput(ip);
    800041ee:	854e                	mv	a0,s3
    800041f0:	00000097          	auipc	ra,0x0
    800041f4:	bd4080e7          	jalr	-1068(ra) # 80003dc4 <iunlockput>
    ip = next;
    800041f8:	89d2                	mv	s3,s4
  while(*path == '/')
    800041fa:	0004c783          	lbu	a5,0(s1)
    800041fe:	05279763          	bne	a5,s2,8000424c <namex+0x156>
    path++;
    80004202:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004204:	0004c783          	lbu	a5,0(s1)
    80004208:	ff278de3          	beq	a5,s2,80004202 <namex+0x10c>
  if(*path == 0)
    8000420c:	c79d                	beqz	a5,8000423a <namex+0x144>
    path++;
    8000420e:	85a6                	mv	a1,s1
  len = path - s;
    80004210:	8a5e                	mv	s4,s7
    80004212:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004214:	01278963          	beq	a5,s2,80004226 <namex+0x130>
    80004218:	dfbd                	beqz	a5,80004196 <namex+0xa0>
    path++;
    8000421a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000421c:	0004c783          	lbu	a5,0(s1)
    80004220:	ff279ce3          	bne	a5,s2,80004218 <namex+0x122>
    80004224:	bf8d                	j	80004196 <namex+0xa0>
    memmove(name, s, len);
    80004226:	2601                	sext.w	a2,a2
    80004228:	8556                	mv	a0,s5
    8000422a:	ffffd097          	auipc	ra,0xffffd
    8000422e:	b1c080e7          	jalr	-1252(ra) # 80000d46 <memmove>
    name[len] = 0;
    80004232:	9a56                	add	s4,s4,s5
    80004234:	000a0023          	sb	zero,0(s4)
    80004238:	bf9d                	j	800041ae <namex+0xb8>
  if(nameiparent){
    8000423a:	f20b03e3          	beqz	s6,80004160 <namex+0x6a>
    iput(ip);
    8000423e:	854e                	mv	a0,s3
    80004240:	00000097          	auipc	ra,0x0
    80004244:	adc080e7          	jalr	-1316(ra) # 80003d1c <iput>
    return 0;
    80004248:	4981                	li	s3,0
    8000424a:	bf19                	j	80004160 <namex+0x6a>
  if(*path == 0)
    8000424c:	d7fd                	beqz	a5,8000423a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000424e:	0004c783          	lbu	a5,0(s1)
    80004252:	85a6                	mv	a1,s1
    80004254:	b7d1                	j	80004218 <namex+0x122>

0000000080004256 <dirlink>:
{
    80004256:	7139                	addi	sp,sp,-64
    80004258:	fc06                	sd	ra,56(sp)
    8000425a:	f822                	sd	s0,48(sp)
    8000425c:	f426                	sd	s1,40(sp)
    8000425e:	f04a                	sd	s2,32(sp)
    80004260:	ec4e                	sd	s3,24(sp)
    80004262:	e852                	sd	s4,16(sp)
    80004264:	0080                	addi	s0,sp,64
    80004266:	892a                	mv	s2,a0
    80004268:	8a2e                	mv	s4,a1
    8000426a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000426c:	4601                	li	a2,0
    8000426e:	00000097          	auipc	ra,0x0
    80004272:	dd8080e7          	jalr	-552(ra) # 80004046 <dirlookup>
    80004276:	e93d                	bnez	a0,800042ec <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004278:	04c92483          	lw	s1,76(s2)
    8000427c:	c49d                	beqz	s1,800042aa <dirlink+0x54>
    8000427e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004280:	4741                	li	a4,16
    80004282:	86a6                	mv	a3,s1
    80004284:	fc040613          	addi	a2,s0,-64
    80004288:	4581                	li	a1,0
    8000428a:	854a                	mv	a0,s2
    8000428c:	00000097          	auipc	ra,0x0
    80004290:	b8a080e7          	jalr	-1142(ra) # 80003e16 <readi>
    80004294:	47c1                	li	a5,16
    80004296:	06f51163          	bne	a0,a5,800042f8 <dirlink+0xa2>
    if(de.inum == 0)
    8000429a:	fc045783          	lhu	a5,-64(s0)
    8000429e:	c791                	beqz	a5,800042aa <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042a0:	24c1                	addiw	s1,s1,16
    800042a2:	04c92783          	lw	a5,76(s2)
    800042a6:	fcf4ede3          	bltu	s1,a5,80004280 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042aa:	4639                	li	a2,14
    800042ac:	85d2                	mv	a1,s4
    800042ae:	fc240513          	addi	a0,s0,-62
    800042b2:	ffffd097          	auipc	ra,0xffffd
    800042b6:	b48080e7          	jalr	-1208(ra) # 80000dfa <strncpy>
  de.inum = inum;
    800042ba:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042be:	4741                	li	a4,16
    800042c0:	86a6                	mv	a3,s1
    800042c2:	fc040613          	addi	a2,s0,-64
    800042c6:	4581                	li	a1,0
    800042c8:	854a                	mv	a0,s2
    800042ca:	00000097          	auipc	ra,0x0
    800042ce:	c44080e7          	jalr	-956(ra) # 80003f0e <writei>
    800042d2:	1541                	addi	a0,a0,-16
    800042d4:	00a03533          	snez	a0,a0
    800042d8:	40a00533          	neg	a0,a0
}
    800042dc:	70e2                	ld	ra,56(sp)
    800042de:	7442                	ld	s0,48(sp)
    800042e0:	74a2                	ld	s1,40(sp)
    800042e2:	7902                	ld	s2,32(sp)
    800042e4:	69e2                	ld	s3,24(sp)
    800042e6:	6a42                	ld	s4,16(sp)
    800042e8:	6121                	addi	sp,sp,64
    800042ea:	8082                	ret
    iput(ip);
    800042ec:	00000097          	auipc	ra,0x0
    800042f0:	a30080e7          	jalr	-1488(ra) # 80003d1c <iput>
    return -1;
    800042f4:	557d                	li	a0,-1
    800042f6:	b7dd                	j	800042dc <dirlink+0x86>
      panic("dirlink read");
    800042f8:	00004517          	auipc	a0,0x4
    800042fc:	3a050513          	addi	a0,a0,928 # 80008698 <syscalls+0x1f8>
    80004300:	ffffc097          	auipc	ra,0xffffc
    80004304:	244080e7          	jalr	580(ra) # 80000544 <panic>

0000000080004308 <namei>:

struct inode*
namei(char *path)
{
    80004308:	1101                	addi	sp,sp,-32
    8000430a:	ec06                	sd	ra,24(sp)
    8000430c:	e822                	sd	s0,16(sp)
    8000430e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004310:	fe040613          	addi	a2,s0,-32
    80004314:	4581                	li	a1,0
    80004316:	00000097          	auipc	ra,0x0
    8000431a:	de0080e7          	jalr	-544(ra) # 800040f6 <namex>
}
    8000431e:	60e2                	ld	ra,24(sp)
    80004320:	6442                	ld	s0,16(sp)
    80004322:	6105                	addi	sp,sp,32
    80004324:	8082                	ret

0000000080004326 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004326:	1141                	addi	sp,sp,-16
    80004328:	e406                	sd	ra,8(sp)
    8000432a:	e022                	sd	s0,0(sp)
    8000432c:	0800                	addi	s0,sp,16
    8000432e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004330:	4585                	li	a1,1
    80004332:	00000097          	auipc	ra,0x0
    80004336:	dc4080e7          	jalr	-572(ra) # 800040f6 <namex>
}
    8000433a:	60a2                	ld	ra,8(sp)
    8000433c:	6402                	ld	s0,0(sp)
    8000433e:	0141                	addi	sp,sp,16
    80004340:	8082                	ret

0000000080004342 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004342:	1101                	addi	sp,sp,-32
    80004344:	ec06                	sd	ra,24(sp)
    80004346:	e822                	sd	s0,16(sp)
    80004348:	e426                	sd	s1,8(sp)
    8000434a:	e04a                	sd	s2,0(sp)
    8000434c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000434e:	0001d917          	auipc	s2,0x1d
    80004352:	03290913          	addi	s2,s2,50 # 80021380 <log>
    80004356:	01892583          	lw	a1,24(s2)
    8000435a:	02892503          	lw	a0,40(s2)
    8000435e:	fffff097          	auipc	ra,0xfffff
    80004362:	fea080e7          	jalr	-22(ra) # 80003348 <bread>
    80004366:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004368:	02c92683          	lw	a3,44(s2)
    8000436c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000436e:	02d05763          	blez	a3,8000439c <write_head+0x5a>
    80004372:	0001d797          	auipc	a5,0x1d
    80004376:	03e78793          	addi	a5,a5,62 # 800213b0 <log+0x30>
    8000437a:	05c50713          	addi	a4,a0,92
    8000437e:	36fd                	addiw	a3,a3,-1
    80004380:	1682                	slli	a3,a3,0x20
    80004382:	9281                	srli	a3,a3,0x20
    80004384:	068a                	slli	a3,a3,0x2
    80004386:	0001d617          	auipc	a2,0x1d
    8000438a:	02e60613          	addi	a2,a2,46 # 800213b4 <log+0x34>
    8000438e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004390:	4390                	lw	a2,0(a5)
    80004392:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004394:	0791                	addi	a5,a5,4
    80004396:	0711                	addi	a4,a4,4
    80004398:	fed79ce3          	bne	a5,a3,80004390 <write_head+0x4e>
  }
  bwrite(buf);
    8000439c:	8526                	mv	a0,s1
    8000439e:	fffff097          	auipc	ra,0xfffff
    800043a2:	09c080e7          	jalr	156(ra) # 8000343a <bwrite>
  brelse(buf);
    800043a6:	8526                	mv	a0,s1
    800043a8:	fffff097          	auipc	ra,0xfffff
    800043ac:	0d0080e7          	jalr	208(ra) # 80003478 <brelse>
}
    800043b0:	60e2                	ld	ra,24(sp)
    800043b2:	6442                	ld	s0,16(sp)
    800043b4:	64a2                	ld	s1,8(sp)
    800043b6:	6902                	ld	s2,0(sp)
    800043b8:	6105                	addi	sp,sp,32
    800043ba:	8082                	ret

00000000800043bc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043bc:	0001d797          	auipc	a5,0x1d
    800043c0:	ff07a783          	lw	a5,-16(a5) # 800213ac <log+0x2c>
    800043c4:	0af05d63          	blez	a5,8000447e <install_trans+0xc2>
{
    800043c8:	7139                	addi	sp,sp,-64
    800043ca:	fc06                	sd	ra,56(sp)
    800043cc:	f822                	sd	s0,48(sp)
    800043ce:	f426                	sd	s1,40(sp)
    800043d0:	f04a                	sd	s2,32(sp)
    800043d2:	ec4e                	sd	s3,24(sp)
    800043d4:	e852                	sd	s4,16(sp)
    800043d6:	e456                	sd	s5,8(sp)
    800043d8:	e05a                	sd	s6,0(sp)
    800043da:	0080                	addi	s0,sp,64
    800043dc:	8b2a                	mv	s6,a0
    800043de:	0001da97          	auipc	s5,0x1d
    800043e2:	fd2a8a93          	addi	s5,s5,-46 # 800213b0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043e8:	0001d997          	auipc	s3,0x1d
    800043ec:	f9898993          	addi	s3,s3,-104 # 80021380 <log>
    800043f0:	a035                	j	8000441c <install_trans+0x60>
      bunpin(dbuf);
    800043f2:	8526                	mv	a0,s1
    800043f4:	fffff097          	auipc	ra,0xfffff
    800043f8:	15e080e7          	jalr	350(ra) # 80003552 <bunpin>
    brelse(lbuf);
    800043fc:	854a                	mv	a0,s2
    800043fe:	fffff097          	auipc	ra,0xfffff
    80004402:	07a080e7          	jalr	122(ra) # 80003478 <brelse>
    brelse(dbuf);
    80004406:	8526                	mv	a0,s1
    80004408:	fffff097          	auipc	ra,0xfffff
    8000440c:	070080e7          	jalr	112(ra) # 80003478 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004410:	2a05                	addiw	s4,s4,1
    80004412:	0a91                	addi	s5,s5,4
    80004414:	02c9a783          	lw	a5,44(s3)
    80004418:	04fa5963          	bge	s4,a5,8000446a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000441c:	0189a583          	lw	a1,24(s3)
    80004420:	014585bb          	addw	a1,a1,s4
    80004424:	2585                	addiw	a1,a1,1
    80004426:	0289a503          	lw	a0,40(s3)
    8000442a:	fffff097          	auipc	ra,0xfffff
    8000442e:	f1e080e7          	jalr	-226(ra) # 80003348 <bread>
    80004432:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004434:	000aa583          	lw	a1,0(s5)
    80004438:	0289a503          	lw	a0,40(s3)
    8000443c:	fffff097          	auipc	ra,0xfffff
    80004440:	f0c080e7          	jalr	-244(ra) # 80003348 <bread>
    80004444:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004446:	40000613          	li	a2,1024
    8000444a:	05890593          	addi	a1,s2,88
    8000444e:	05850513          	addi	a0,a0,88
    80004452:	ffffd097          	auipc	ra,0xffffd
    80004456:	8f4080e7          	jalr	-1804(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000445a:	8526                	mv	a0,s1
    8000445c:	fffff097          	auipc	ra,0xfffff
    80004460:	fde080e7          	jalr	-34(ra) # 8000343a <bwrite>
    if(recovering == 0)
    80004464:	f80b1ce3          	bnez	s6,800043fc <install_trans+0x40>
    80004468:	b769                	j	800043f2 <install_trans+0x36>
}
    8000446a:	70e2                	ld	ra,56(sp)
    8000446c:	7442                	ld	s0,48(sp)
    8000446e:	74a2                	ld	s1,40(sp)
    80004470:	7902                	ld	s2,32(sp)
    80004472:	69e2                	ld	s3,24(sp)
    80004474:	6a42                	ld	s4,16(sp)
    80004476:	6aa2                	ld	s5,8(sp)
    80004478:	6b02                	ld	s6,0(sp)
    8000447a:	6121                	addi	sp,sp,64
    8000447c:	8082                	ret
    8000447e:	8082                	ret

0000000080004480 <initlog>:
{
    80004480:	7179                	addi	sp,sp,-48
    80004482:	f406                	sd	ra,40(sp)
    80004484:	f022                	sd	s0,32(sp)
    80004486:	ec26                	sd	s1,24(sp)
    80004488:	e84a                	sd	s2,16(sp)
    8000448a:	e44e                	sd	s3,8(sp)
    8000448c:	1800                	addi	s0,sp,48
    8000448e:	892a                	mv	s2,a0
    80004490:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004492:	0001d497          	auipc	s1,0x1d
    80004496:	eee48493          	addi	s1,s1,-274 # 80021380 <log>
    8000449a:	00004597          	auipc	a1,0x4
    8000449e:	20e58593          	addi	a1,a1,526 # 800086a8 <syscalls+0x208>
    800044a2:	8526                	mv	a0,s1
    800044a4:	ffffc097          	auipc	ra,0xffffc
    800044a8:	6b6080e7          	jalr	1718(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    800044ac:	0149a583          	lw	a1,20(s3)
    800044b0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800044b2:	0109a783          	lw	a5,16(s3)
    800044b6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800044b8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044bc:	854a                	mv	a0,s2
    800044be:	fffff097          	auipc	ra,0xfffff
    800044c2:	e8a080e7          	jalr	-374(ra) # 80003348 <bread>
  log.lh.n = lh->n;
    800044c6:	4d3c                	lw	a5,88(a0)
    800044c8:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044ca:	02f05563          	blez	a5,800044f4 <initlog+0x74>
    800044ce:	05c50713          	addi	a4,a0,92
    800044d2:	0001d697          	auipc	a3,0x1d
    800044d6:	ede68693          	addi	a3,a3,-290 # 800213b0 <log+0x30>
    800044da:	37fd                	addiw	a5,a5,-1
    800044dc:	1782                	slli	a5,a5,0x20
    800044de:	9381                	srli	a5,a5,0x20
    800044e0:	078a                	slli	a5,a5,0x2
    800044e2:	06050613          	addi	a2,a0,96
    800044e6:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800044e8:	4310                	lw	a2,0(a4)
    800044ea:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800044ec:	0711                	addi	a4,a4,4
    800044ee:	0691                	addi	a3,a3,4
    800044f0:	fef71ce3          	bne	a4,a5,800044e8 <initlog+0x68>
  brelse(buf);
    800044f4:	fffff097          	auipc	ra,0xfffff
    800044f8:	f84080e7          	jalr	-124(ra) # 80003478 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800044fc:	4505                	li	a0,1
    800044fe:	00000097          	auipc	ra,0x0
    80004502:	ebe080e7          	jalr	-322(ra) # 800043bc <install_trans>
  log.lh.n = 0;
    80004506:	0001d797          	auipc	a5,0x1d
    8000450a:	ea07a323          	sw	zero,-346(a5) # 800213ac <log+0x2c>
  write_head(); // clear the log
    8000450e:	00000097          	auipc	ra,0x0
    80004512:	e34080e7          	jalr	-460(ra) # 80004342 <write_head>
}
    80004516:	70a2                	ld	ra,40(sp)
    80004518:	7402                	ld	s0,32(sp)
    8000451a:	64e2                	ld	s1,24(sp)
    8000451c:	6942                	ld	s2,16(sp)
    8000451e:	69a2                	ld	s3,8(sp)
    80004520:	6145                	addi	sp,sp,48
    80004522:	8082                	ret

0000000080004524 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004524:	1101                	addi	sp,sp,-32
    80004526:	ec06                	sd	ra,24(sp)
    80004528:	e822                	sd	s0,16(sp)
    8000452a:	e426                	sd	s1,8(sp)
    8000452c:	e04a                	sd	s2,0(sp)
    8000452e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004530:	0001d517          	auipc	a0,0x1d
    80004534:	e5050513          	addi	a0,a0,-432 # 80021380 <log>
    80004538:	ffffc097          	auipc	ra,0xffffc
    8000453c:	6b2080e7          	jalr	1714(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    80004540:	0001d497          	auipc	s1,0x1d
    80004544:	e4048493          	addi	s1,s1,-448 # 80021380 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004548:	4979                	li	s2,30
    8000454a:	a039                	j	80004558 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000454c:	85a6                	mv	a1,s1
    8000454e:	8526                	mv	a0,s1
    80004550:	ffffe097          	auipc	ra,0xffffe
    80004554:	b1a080e7          	jalr	-1254(ra) # 8000206a <sleep>
    if(log.committing){
    80004558:	50dc                	lw	a5,36(s1)
    8000455a:	fbed                	bnez	a5,8000454c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000455c:	509c                	lw	a5,32(s1)
    8000455e:	0017871b          	addiw	a4,a5,1
    80004562:	0007069b          	sext.w	a3,a4
    80004566:	0027179b          	slliw	a5,a4,0x2
    8000456a:	9fb9                	addw	a5,a5,a4
    8000456c:	0017979b          	slliw	a5,a5,0x1
    80004570:	54d8                	lw	a4,44(s1)
    80004572:	9fb9                	addw	a5,a5,a4
    80004574:	00f95963          	bge	s2,a5,80004586 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004578:	85a6                	mv	a1,s1
    8000457a:	8526                	mv	a0,s1
    8000457c:	ffffe097          	auipc	ra,0xffffe
    80004580:	aee080e7          	jalr	-1298(ra) # 8000206a <sleep>
    80004584:	bfd1                	j	80004558 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004586:	0001d517          	auipc	a0,0x1d
    8000458a:	dfa50513          	addi	a0,a0,-518 # 80021380 <log>
    8000458e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004590:	ffffc097          	auipc	ra,0xffffc
    80004594:	70e080e7          	jalr	1806(ra) # 80000c9e <release>
      break;
    }
  }
}
    80004598:	60e2                	ld	ra,24(sp)
    8000459a:	6442                	ld	s0,16(sp)
    8000459c:	64a2                	ld	s1,8(sp)
    8000459e:	6902                	ld	s2,0(sp)
    800045a0:	6105                	addi	sp,sp,32
    800045a2:	8082                	ret

00000000800045a4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800045a4:	7139                	addi	sp,sp,-64
    800045a6:	fc06                	sd	ra,56(sp)
    800045a8:	f822                	sd	s0,48(sp)
    800045aa:	f426                	sd	s1,40(sp)
    800045ac:	f04a                	sd	s2,32(sp)
    800045ae:	ec4e                	sd	s3,24(sp)
    800045b0:	e852                	sd	s4,16(sp)
    800045b2:	e456                	sd	s5,8(sp)
    800045b4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800045b6:	0001d497          	auipc	s1,0x1d
    800045ba:	dca48493          	addi	s1,s1,-566 # 80021380 <log>
    800045be:	8526                	mv	a0,s1
    800045c0:	ffffc097          	auipc	ra,0xffffc
    800045c4:	62a080e7          	jalr	1578(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    800045c8:	509c                	lw	a5,32(s1)
    800045ca:	37fd                	addiw	a5,a5,-1
    800045cc:	0007891b          	sext.w	s2,a5
    800045d0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800045d2:	50dc                	lw	a5,36(s1)
    800045d4:	efb9                	bnez	a5,80004632 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800045d6:	06091663          	bnez	s2,80004642 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800045da:	0001d497          	auipc	s1,0x1d
    800045de:	da648493          	addi	s1,s1,-602 # 80021380 <log>
    800045e2:	4785                	li	a5,1
    800045e4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800045e6:	8526                	mv	a0,s1
    800045e8:	ffffc097          	auipc	ra,0xffffc
    800045ec:	6b6080e7          	jalr	1718(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800045f0:	54dc                	lw	a5,44(s1)
    800045f2:	06f04763          	bgtz	a5,80004660 <end_op+0xbc>
    acquire(&log.lock);
    800045f6:	0001d497          	auipc	s1,0x1d
    800045fa:	d8a48493          	addi	s1,s1,-630 # 80021380 <log>
    800045fe:	8526                	mv	a0,s1
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	5ea080e7          	jalr	1514(ra) # 80000bea <acquire>
    log.committing = 0;
    80004608:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000460c:	8526                	mv	a0,s1
    8000460e:	ffffe097          	auipc	ra,0xffffe
    80004612:	ac0080e7          	jalr	-1344(ra) # 800020ce <wakeup>
    release(&log.lock);
    80004616:	8526                	mv	a0,s1
    80004618:	ffffc097          	auipc	ra,0xffffc
    8000461c:	686080e7          	jalr	1670(ra) # 80000c9e <release>
}
    80004620:	70e2                	ld	ra,56(sp)
    80004622:	7442                	ld	s0,48(sp)
    80004624:	74a2                	ld	s1,40(sp)
    80004626:	7902                	ld	s2,32(sp)
    80004628:	69e2                	ld	s3,24(sp)
    8000462a:	6a42                	ld	s4,16(sp)
    8000462c:	6aa2                	ld	s5,8(sp)
    8000462e:	6121                	addi	sp,sp,64
    80004630:	8082                	ret
    panic("log.committing");
    80004632:	00004517          	auipc	a0,0x4
    80004636:	07e50513          	addi	a0,a0,126 # 800086b0 <syscalls+0x210>
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	f0a080e7          	jalr	-246(ra) # 80000544 <panic>
    wakeup(&log);
    80004642:	0001d497          	auipc	s1,0x1d
    80004646:	d3e48493          	addi	s1,s1,-706 # 80021380 <log>
    8000464a:	8526                	mv	a0,s1
    8000464c:	ffffe097          	auipc	ra,0xffffe
    80004650:	a82080e7          	jalr	-1406(ra) # 800020ce <wakeup>
  release(&log.lock);
    80004654:	8526                	mv	a0,s1
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	648080e7          	jalr	1608(ra) # 80000c9e <release>
  if(do_commit){
    8000465e:	b7c9                	j	80004620 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004660:	0001da97          	auipc	s5,0x1d
    80004664:	d50a8a93          	addi	s5,s5,-688 # 800213b0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004668:	0001da17          	auipc	s4,0x1d
    8000466c:	d18a0a13          	addi	s4,s4,-744 # 80021380 <log>
    80004670:	018a2583          	lw	a1,24(s4)
    80004674:	012585bb          	addw	a1,a1,s2
    80004678:	2585                	addiw	a1,a1,1
    8000467a:	028a2503          	lw	a0,40(s4)
    8000467e:	fffff097          	auipc	ra,0xfffff
    80004682:	cca080e7          	jalr	-822(ra) # 80003348 <bread>
    80004686:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004688:	000aa583          	lw	a1,0(s5)
    8000468c:	028a2503          	lw	a0,40(s4)
    80004690:	fffff097          	auipc	ra,0xfffff
    80004694:	cb8080e7          	jalr	-840(ra) # 80003348 <bread>
    80004698:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000469a:	40000613          	li	a2,1024
    8000469e:	05850593          	addi	a1,a0,88
    800046a2:	05848513          	addi	a0,s1,88
    800046a6:	ffffc097          	auipc	ra,0xffffc
    800046aa:	6a0080e7          	jalr	1696(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    800046ae:	8526                	mv	a0,s1
    800046b0:	fffff097          	auipc	ra,0xfffff
    800046b4:	d8a080e7          	jalr	-630(ra) # 8000343a <bwrite>
    brelse(from);
    800046b8:	854e                	mv	a0,s3
    800046ba:	fffff097          	auipc	ra,0xfffff
    800046be:	dbe080e7          	jalr	-578(ra) # 80003478 <brelse>
    brelse(to);
    800046c2:	8526                	mv	a0,s1
    800046c4:	fffff097          	auipc	ra,0xfffff
    800046c8:	db4080e7          	jalr	-588(ra) # 80003478 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046cc:	2905                	addiw	s2,s2,1
    800046ce:	0a91                	addi	s5,s5,4
    800046d0:	02ca2783          	lw	a5,44(s4)
    800046d4:	f8f94ee3          	blt	s2,a5,80004670 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800046d8:	00000097          	auipc	ra,0x0
    800046dc:	c6a080e7          	jalr	-918(ra) # 80004342 <write_head>
    install_trans(0); // Now install writes to home locations
    800046e0:	4501                	li	a0,0
    800046e2:	00000097          	auipc	ra,0x0
    800046e6:	cda080e7          	jalr	-806(ra) # 800043bc <install_trans>
    log.lh.n = 0;
    800046ea:	0001d797          	auipc	a5,0x1d
    800046ee:	cc07a123          	sw	zero,-830(a5) # 800213ac <log+0x2c>
    write_head();    // Erase the transaction from the log
    800046f2:	00000097          	auipc	ra,0x0
    800046f6:	c50080e7          	jalr	-944(ra) # 80004342 <write_head>
    800046fa:	bdf5                	j	800045f6 <end_op+0x52>

00000000800046fc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800046fc:	1101                	addi	sp,sp,-32
    800046fe:	ec06                	sd	ra,24(sp)
    80004700:	e822                	sd	s0,16(sp)
    80004702:	e426                	sd	s1,8(sp)
    80004704:	e04a                	sd	s2,0(sp)
    80004706:	1000                	addi	s0,sp,32
    80004708:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000470a:	0001d917          	auipc	s2,0x1d
    8000470e:	c7690913          	addi	s2,s2,-906 # 80021380 <log>
    80004712:	854a                	mv	a0,s2
    80004714:	ffffc097          	auipc	ra,0xffffc
    80004718:	4d6080e7          	jalr	1238(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000471c:	02c92603          	lw	a2,44(s2)
    80004720:	47f5                	li	a5,29
    80004722:	06c7c563          	blt	a5,a2,8000478c <log_write+0x90>
    80004726:	0001d797          	auipc	a5,0x1d
    8000472a:	c767a783          	lw	a5,-906(a5) # 8002139c <log+0x1c>
    8000472e:	37fd                	addiw	a5,a5,-1
    80004730:	04f65e63          	bge	a2,a5,8000478c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004734:	0001d797          	auipc	a5,0x1d
    80004738:	c6c7a783          	lw	a5,-916(a5) # 800213a0 <log+0x20>
    8000473c:	06f05063          	blez	a5,8000479c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004740:	4781                	li	a5,0
    80004742:	06c05563          	blez	a2,800047ac <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004746:	44cc                	lw	a1,12(s1)
    80004748:	0001d717          	auipc	a4,0x1d
    8000474c:	c6870713          	addi	a4,a4,-920 # 800213b0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004750:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004752:	4314                	lw	a3,0(a4)
    80004754:	04b68c63          	beq	a3,a1,800047ac <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004758:	2785                	addiw	a5,a5,1
    8000475a:	0711                	addi	a4,a4,4
    8000475c:	fef61be3          	bne	a2,a5,80004752 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004760:	0621                	addi	a2,a2,8
    80004762:	060a                	slli	a2,a2,0x2
    80004764:	0001d797          	auipc	a5,0x1d
    80004768:	c1c78793          	addi	a5,a5,-996 # 80021380 <log>
    8000476c:	963e                	add	a2,a2,a5
    8000476e:	44dc                	lw	a5,12(s1)
    80004770:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004772:	8526                	mv	a0,s1
    80004774:	fffff097          	auipc	ra,0xfffff
    80004778:	da2080e7          	jalr	-606(ra) # 80003516 <bpin>
    log.lh.n++;
    8000477c:	0001d717          	auipc	a4,0x1d
    80004780:	c0470713          	addi	a4,a4,-1020 # 80021380 <log>
    80004784:	575c                	lw	a5,44(a4)
    80004786:	2785                	addiw	a5,a5,1
    80004788:	d75c                	sw	a5,44(a4)
    8000478a:	a835                	j	800047c6 <log_write+0xca>
    panic("too big a transaction");
    8000478c:	00004517          	auipc	a0,0x4
    80004790:	f3450513          	addi	a0,a0,-204 # 800086c0 <syscalls+0x220>
    80004794:	ffffc097          	auipc	ra,0xffffc
    80004798:	db0080e7          	jalr	-592(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    8000479c:	00004517          	auipc	a0,0x4
    800047a0:	f3c50513          	addi	a0,a0,-196 # 800086d8 <syscalls+0x238>
    800047a4:	ffffc097          	auipc	ra,0xffffc
    800047a8:	da0080e7          	jalr	-608(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    800047ac:	00878713          	addi	a4,a5,8
    800047b0:	00271693          	slli	a3,a4,0x2
    800047b4:	0001d717          	auipc	a4,0x1d
    800047b8:	bcc70713          	addi	a4,a4,-1076 # 80021380 <log>
    800047bc:	9736                	add	a4,a4,a3
    800047be:	44d4                	lw	a3,12(s1)
    800047c0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047c2:	faf608e3          	beq	a2,a5,80004772 <log_write+0x76>
  }
  release(&log.lock);
    800047c6:	0001d517          	auipc	a0,0x1d
    800047ca:	bba50513          	addi	a0,a0,-1094 # 80021380 <log>
    800047ce:	ffffc097          	auipc	ra,0xffffc
    800047d2:	4d0080e7          	jalr	1232(ra) # 80000c9e <release>
}
    800047d6:	60e2                	ld	ra,24(sp)
    800047d8:	6442                	ld	s0,16(sp)
    800047da:	64a2                	ld	s1,8(sp)
    800047dc:	6902                	ld	s2,0(sp)
    800047de:	6105                	addi	sp,sp,32
    800047e0:	8082                	ret

00000000800047e2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800047e2:	1101                	addi	sp,sp,-32
    800047e4:	ec06                	sd	ra,24(sp)
    800047e6:	e822                	sd	s0,16(sp)
    800047e8:	e426                	sd	s1,8(sp)
    800047ea:	e04a                	sd	s2,0(sp)
    800047ec:	1000                	addi	s0,sp,32
    800047ee:	84aa                	mv	s1,a0
    800047f0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800047f2:	00004597          	auipc	a1,0x4
    800047f6:	f0658593          	addi	a1,a1,-250 # 800086f8 <syscalls+0x258>
    800047fa:	0521                	addi	a0,a0,8
    800047fc:	ffffc097          	auipc	ra,0xffffc
    80004800:	35e080e7          	jalr	862(ra) # 80000b5a <initlock>
  lk->name = name;
    80004804:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004808:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000480c:	0204a423          	sw	zero,40(s1)
}
    80004810:	60e2                	ld	ra,24(sp)
    80004812:	6442                	ld	s0,16(sp)
    80004814:	64a2                	ld	s1,8(sp)
    80004816:	6902                	ld	s2,0(sp)
    80004818:	6105                	addi	sp,sp,32
    8000481a:	8082                	ret

000000008000481c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000481c:	1101                	addi	sp,sp,-32
    8000481e:	ec06                	sd	ra,24(sp)
    80004820:	e822                	sd	s0,16(sp)
    80004822:	e426                	sd	s1,8(sp)
    80004824:	e04a                	sd	s2,0(sp)
    80004826:	1000                	addi	s0,sp,32
    80004828:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000482a:	00850913          	addi	s2,a0,8
    8000482e:	854a                	mv	a0,s2
    80004830:	ffffc097          	auipc	ra,0xffffc
    80004834:	3ba080e7          	jalr	954(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004838:	409c                	lw	a5,0(s1)
    8000483a:	cb89                	beqz	a5,8000484c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000483c:	85ca                	mv	a1,s2
    8000483e:	8526                	mv	a0,s1
    80004840:	ffffe097          	auipc	ra,0xffffe
    80004844:	82a080e7          	jalr	-2006(ra) # 8000206a <sleep>
  while (lk->locked) {
    80004848:	409c                	lw	a5,0(s1)
    8000484a:	fbed                	bnez	a5,8000483c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000484c:	4785                	li	a5,1
    8000484e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004850:	ffffd097          	auipc	ra,0xffffd
    80004854:	176080e7          	jalr	374(ra) # 800019c6 <myproc>
    80004858:	591c                	lw	a5,48(a0)
    8000485a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000485c:	854a                	mv	a0,s2
    8000485e:	ffffc097          	auipc	ra,0xffffc
    80004862:	440080e7          	jalr	1088(ra) # 80000c9e <release>
}
    80004866:	60e2                	ld	ra,24(sp)
    80004868:	6442                	ld	s0,16(sp)
    8000486a:	64a2                	ld	s1,8(sp)
    8000486c:	6902                	ld	s2,0(sp)
    8000486e:	6105                	addi	sp,sp,32
    80004870:	8082                	ret

0000000080004872 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004872:	1101                	addi	sp,sp,-32
    80004874:	ec06                	sd	ra,24(sp)
    80004876:	e822                	sd	s0,16(sp)
    80004878:	e426                	sd	s1,8(sp)
    8000487a:	e04a                	sd	s2,0(sp)
    8000487c:	1000                	addi	s0,sp,32
    8000487e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004880:	00850913          	addi	s2,a0,8
    80004884:	854a                	mv	a0,s2
    80004886:	ffffc097          	auipc	ra,0xffffc
    8000488a:	364080e7          	jalr	868(ra) # 80000bea <acquire>
  lk->locked = 0;
    8000488e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004892:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004896:	8526                	mv	a0,s1
    80004898:	ffffe097          	auipc	ra,0xffffe
    8000489c:	836080e7          	jalr	-1994(ra) # 800020ce <wakeup>
  release(&lk->lk);
    800048a0:	854a                	mv	a0,s2
    800048a2:	ffffc097          	auipc	ra,0xffffc
    800048a6:	3fc080e7          	jalr	1020(ra) # 80000c9e <release>
}
    800048aa:	60e2                	ld	ra,24(sp)
    800048ac:	6442                	ld	s0,16(sp)
    800048ae:	64a2                	ld	s1,8(sp)
    800048b0:	6902                	ld	s2,0(sp)
    800048b2:	6105                	addi	sp,sp,32
    800048b4:	8082                	ret

00000000800048b6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048b6:	7179                	addi	sp,sp,-48
    800048b8:	f406                	sd	ra,40(sp)
    800048ba:	f022                	sd	s0,32(sp)
    800048bc:	ec26                	sd	s1,24(sp)
    800048be:	e84a                	sd	s2,16(sp)
    800048c0:	e44e                	sd	s3,8(sp)
    800048c2:	1800                	addi	s0,sp,48
    800048c4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048c6:	00850913          	addi	s2,a0,8
    800048ca:	854a                	mv	a0,s2
    800048cc:	ffffc097          	auipc	ra,0xffffc
    800048d0:	31e080e7          	jalr	798(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800048d4:	409c                	lw	a5,0(s1)
    800048d6:	ef99                	bnez	a5,800048f4 <holdingsleep+0x3e>
    800048d8:	4481                	li	s1,0
  release(&lk->lk);
    800048da:	854a                	mv	a0,s2
    800048dc:	ffffc097          	auipc	ra,0xffffc
    800048e0:	3c2080e7          	jalr	962(ra) # 80000c9e <release>
  return r;
}
    800048e4:	8526                	mv	a0,s1
    800048e6:	70a2                	ld	ra,40(sp)
    800048e8:	7402                	ld	s0,32(sp)
    800048ea:	64e2                	ld	s1,24(sp)
    800048ec:	6942                	ld	s2,16(sp)
    800048ee:	69a2                	ld	s3,8(sp)
    800048f0:	6145                	addi	sp,sp,48
    800048f2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800048f4:	0284a983          	lw	s3,40(s1)
    800048f8:	ffffd097          	auipc	ra,0xffffd
    800048fc:	0ce080e7          	jalr	206(ra) # 800019c6 <myproc>
    80004900:	5904                	lw	s1,48(a0)
    80004902:	413484b3          	sub	s1,s1,s3
    80004906:	0014b493          	seqz	s1,s1
    8000490a:	bfc1                	j	800048da <holdingsleep+0x24>

000000008000490c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000490c:	1141                	addi	sp,sp,-16
    8000490e:	e406                	sd	ra,8(sp)
    80004910:	e022                	sd	s0,0(sp)
    80004912:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004914:	00004597          	auipc	a1,0x4
    80004918:	df458593          	addi	a1,a1,-524 # 80008708 <syscalls+0x268>
    8000491c:	0001d517          	auipc	a0,0x1d
    80004920:	bac50513          	addi	a0,a0,-1108 # 800214c8 <ftable>
    80004924:	ffffc097          	auipc	ra,0xffffc
    80004928:	236080e7          	jalr	566(ra) # 80000b5a <initlock>
}
    8000492c:	60a2                	ld	ra,8(sp)
    8000492e:	6402                	ld	s0,0(sp)
    80004930:	0141                	addi	sp,sp,16
    80004932:	8082                	ret

0000000080004934 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004934:	1101                	addi	sp,sp,-32
    80004936:	ec06                	sd	ra,24(sp)
    80004938:	e822                	sd	s0,16(sp)
    8000493a:	e426                	sd	s1,8(sp)
    8000493c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000493e:	0001d517          	auipc	a0,0x1d
    80004942:	b8a50513          	addi	a0,a0,-1142 # 800214c8 <ftable>
    80004946:	ffffc097          	auipc	ra,0xffffc
    8000494a:	2a4080e7          	jalr	676(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000494e:	0001d497          	auipc	s1,0x1d
    80004952:	b9248493          	addi	s1,s1,-1134 # 800214e0 <ftable+0x18>
    80004956:	0001e717          	auipc	a4,0x1e
    8000495a:	b2a70713          	addi	a4,a4,-1238 # 80022480 <disk>
    if(f->ref == 0){
    8000495e:	40dc                	lw	a5,4(s1)
    80004960:	cf99                	beqz	a5,8000497e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004962:	02848493          	addi	s1,s1,40
    80004966:	fee49ce3          	bne	s1,a4,8000495e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000496a:	0001d517          	auipc	a0,0x1d
    8000496e:	b5e50513          	addi	a0,a0,-1186 # 800214c8 <ftable>
    80004972:	ffffc097          	auipc	ra,0xffffc
    80004976:	32c080e7          	jalr	812(ra) # 80000c9e <release>
  return 0;
    8000497a:	4481                	li	s1,0
    8000497c:	a819                	j	80004992 <filealloc+0x5e>
      f->ref = 1;
    8000497e:	4785                	li	a5,1
    80004980:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004982:	0001d517          	auipc	a0,0x1d
    80004986:	b4650513          	addi	a0,a0,-1210 # 800214c8 <ftable>
    8000498a:	ffffc097          	auipc	ra,0xffffc
    8000498e:	314080e7          	jalr	788(ra) # 80000c9e <release>
}
    80004992:	8526                	mv	a0,s1
    80004994:	60e2                	ld	ra,24(sp)
    80004996:	6442                	ld	s0,16(sp)
    80004998:	64a2                	ld	s1,8(sp)
    8000499a:	6105                	addi	sp,sp,32
    8000499c:	8082                	ret

000000008000499e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000499e:	1101                	addi	sp,sp,-32
    800049a0:	ec06                	sd	ra,24(sp)
    800049a2:	e822                	sd	s0,16(sp)
    800049a4:	e426                	sd	s1,8(sp)
    800049a6:	1000                	addi	s0,sp,32
    800049a8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049aa:	0001d517          	auipc	a0,0x1d
    800049ae:	b1e50513          	addi	a0,a0,-1250 # 800214c8 <ftable>
    800049b2:	ffffc097          	auipc	ra,0xffffc
    800049b6:	238080e7          	jalr	568(ra) # 80000bea <acquire>
  if(f->ref < 1)
    800049ba:	40dc                	lw	a5,4(s1)
    800049bc:	02f05263          	blez	a5,800049e0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049c0:	2785                	addiw	a5,a5,1
    800049c2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049c4:	0001d517          	auipc	a0,0x1d
    800049c8:	b0450513          	addi	a0,a0,-1276 # 800214c8 <ftable>
    800049cc:	ffffc097          	auipc	ra,0xffffc
    800049d0:	2d2080e7          	jalr	722(ra) # 80000c9e <release>
  return f;
}
    800049d4:	8526                	mv	a0,s1
    800049d6:	60e2                	ld	ra,24(sp)
    800049d8:	6442                	ld	s0,16(sp)
    800049da:	64a2                	ld	s1,8(sp)
    800049dc:	6105                	addi	sp,sp,32
    800049de:	8082                	ret
    panic("filedup");
    800049e0:	00004517          	auipc	a0,0x4
    800049e4:	d3050513          	addi	a0,a0,-720 # 80008710 <syscalls+0x270>
    800049e8:	ffffc097          	auipc	ra,0xffffc
    800049ec:	b5c080e7          	jalr	-1188(ra) # 80000544 <panic>

00000000800049f0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800049f0:	7139                	addi	sp,sp,-64
    800049f2:	fc06                	sd	ra,56(sp)
    800049f4:	f822                	sd	s0,48(sp)
    800049f6:	f426                	sd	s1,40(sp)
    800049f8:	f04a                	sd	s2,32(sp)
    800049fa:	ec4e                	sd	s3,24(sp)
    800049fc:	e852                	sd	s4,16(sp)
    800049fe:	e456                	sd	s5,8(sp)
    80004a00:	0080                	addi	s0,sp,64
    80004a02:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a04:	0001d517          	auipc	a0,0x1d
    80004a08:	ac450513          	addi	a0,a0,-1340 # 800214c8 <ftable>
    80004a0c:	ffffc097          	auipc	ra,0xffffc
    80004a10:	1de080e7          	jalr	478(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004a14:	40dc                	lw	a5,4(s1)
    80004a16:	06f05163          	blez	a5,80004a78 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a1a:	37fd                	addiw	a5,a5,-1
    80004a1c:	0007871b          	sext.w	a4,a5
    80004a20:	c0dc                	sw	a5,4(s1)
    80004a22:	06e04363          	bgtz	a4,80004a88 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a26:	0004a903          	lw	s2,0(s1)
    80004a2a:	0094ca83          	lbu	s5,9(s1)
    80004a2e:	0104ba03          	ld	s4,16(s1)
    80004a32:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a36:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a3a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a3e:	0001d517          	auipc	a0,0x1d
    80004a42:	a8a50513          	addi	a0,a0,-1398 # 800214c8 <ftable>
    80004a46:	ffffc097          	auipc	ra,0xffffc
    80004a4a:	258080e7          	jalr	600(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004a4e:	4785                	li	a5,1
    80004a50:	04f90d63          	beq	s2,a5,80004aaa <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a54:	3979                	addiw	s2,s2,-2
    80004a56:	4785                	li	a5,1
    80004a58:	0527e063          	bltu	a5,s2,80004a98 <fileclose+0xa8>
    begin_op();
    80004a5c:	00000097          	auipc	ra,0x0
    80004a60:	ac8080e7          	jalr	-1336(ra) # 80004524 <begin_op>
    iput(ff.ip);
    80004a64:	854e                	mv	a0,s3
    80004a66:	fffff097          	auipc	ra,0xfffff
    80004a6a:	2b6080e7          	jalr	694(ra) # 80003d1c <iput>
    end_op();
    80004a6e:	00000097          	auipc	ra,0x0
    80004a72:	b36080e7          	jalr	-1226(ra) # 800045a4 <end_op>
    80004a76:	a00d                	j	80004a98 <fileclose+0xa8>
    panic("fileclose");
    80004a78:	00004517          	auipc	a0,0x4
    80004a7c:	ca050513          	addi	a0,a0,-864 # 80008718 <syscalls+0x278>
    80004a80:	ffffc097          	auipc	ra,0xffffc
    80004a84:	ac4080e7          	jalr	-1340(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004a88:	0001d517          	auipc	a0,0x1d
    80004a8c:	a4050513          	addi	a0,a0,-1472 # 800214c8 <ftable>
    80004a90:	ffffc097          	auipc	ra,0xffffc
    80004a94:	20e080e7          	jalr	526(ra) # 80000c9e <release>
  }
}
    80004a98:	70e2                	ld	ra,56(sp)
    80004a9a:	7442                	ld	s0,48(sp)
    80004a9c:	74a2                	ld	s1,40(sp)
    80004a9e:	7902                	ld	s2,32(sp)
    80004aa0:	69e2                	ld	s3,24(sp)
    80004aa2:	6a42                	ld	s4,16(sp)
    80004aa4:	6aa2                	ld	s5,8(sp)
    80004aa6:	6121                	addi	sp,sp,64
    80004aa8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004aaa:	85d6                	mv	a1,s5
    80004aac:	8552                	mv	a0,s4
    80004aae:	00000097          	auipc	ra,0x0
    80004ab2:	34c080e7          	jalr	844(ra) # 80004dfa <pipeclose>
    80004ab6:	b7cd                	j	80004a98 <fileclose+0xa8>

0000000080004ab8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ab8:	715d                	addi	sp,sp,-80
    80004aba:	e486                	sd	ra,72(sp)
    80004abc:	e0a2                	sd	s0,64(sp)
    80004abe:	fc26                	sd	s1,56(sp)
    80004ac0:	f84a                	sd	s2,48(sp)
    80004ac2:	f44e                	sd	s3,40(sp)
    80004ac4:	0880                	addi	s0,sp,80
    80004ac6:	84aa                	mv	s1,a0
    80004ac8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004aca:	ffffd097          	auipc	ra,0xffffd
    80004ace:	efc080e7          	jalr	-260(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ad2:	409c                	lw	a5,0(s1)
    80004ad4:	37f9                	addiw	a5,a5,-2
    80004ad6:	4705                	li	a4,1
    80004ad8:	04f76763          	bltu	a4,a5,80004b26 <filestat+0x6e>
    80004adc:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ade:	6c88                	ld	a0,24(s1)
    80004ae0:	fffff097          	auipc	ra,0xfffff
    80004ae4:	082080e7          	jalr	130(ra) # 80003b62 <ilock>
    stati(f->ip, &st);
    80004ae8:	fb840593          	addi	a1,s0,-72
    80004aec:	6c88                	ld	a0,24(s1)
    80004aee:	fffff097          	auipc	ra,0xfffff
    80004af2:	2fe080e7          	jalr	766(ra) # 80003dec <stati>
    iunlock(f->ip);
    80004af6:	6c88                	ld	a0,24(s1)
    80004af8:	fffff097          	auipc	ra,0xfffff
    80004afc:	12c080e7          	jalr	300(ra) # 80003c24 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b00:	46e1                	li	a3,24
    80004b02:	fb840613          	addi	a2,s0,-72
    80004b06:	85ce                	mv	a1,s3
    80004b08:	05093503          	ld	a0,80(s2)
    80004b0c:	ffffd097          	auipc	ra,0xffffd
    80004b10:	b78080e7          	jalr	-1160(ra) # 80001684 <copyout>
    80004b14:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b18:	60a6                	ld	ra,72(sp)
    80004b1a:	6406                	ld	s0,64(sp)
    80004b1c:	74e2                	ld	s1,56(sp)
    80004b1e:	7942                	ld	s2,48(sp)
    80004b20:	79a2                	ld	s3,40(sp)
    80004b22:	6161                	addi	sp,sp,80
    80004b24:	8082                	ret
  return -1;
    80004b26:	557d                	li	a0,-1
    80004b28:	bfc5                	j	80004b18 <filestat+0x60>

0000000080004b2a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b2a:	7179                	addi	sp,sp,-48
    80004b2c:	f406                	sd	ra,40(sp)
    80004b2e:	f022                	sd	s0,32(sp)
    80004b30:	ec26                	sd	s1,24(sp)
    80004b32:	e84a                	sd	s2,16(sp)
    80004b34:	e44e                	sd	s3,8(sp)
    80004b36:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b38:	00854783          	lbu	a5,8(a0)
    80004b3c:	c3d5                	beqz	a5,80004be0 <fileread+0xb6>
    80004b3e:	84aa                	mv	s1,a0
    80004b40:	89ae                	mv	s3,a1
    80004b42:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b44:	411c                	lw	a5,0(a0)
    80004b46:	4705                	li	a4,1
    80004b48:	04e78963          	beq	a5,a4,80004b9a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b4c:	470d                	li	a4,3
    80004b4e:	04e78d63          	beq	a5,a4,80004ba8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b52:	4709                	li	a4,2
    80004b54:	06e79e63          	bne	a5,a4,80004bd0 <fileread+0xa6>
    ilock(f->ip);
    80004b58:	6d08                	ld	a0,24(a0)
    80004b5a:	fffff097          	auipc	ra,0xfffff
    80004b5e:	008080e7          	jalr	8(ra) # 80003b62 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b62:	874a                	mv	a4,s2
    80004b64:	5094                	lw	a3,32(s1)
    80004b66:	864e                	mv	a2,s3
    80004b68:	4585                	li	a1,1
    80004b6a:	6c88                	ld	a0,24(s1)
    80004b6c:	fffff097          	auipc	ra,0xfffff
    80004b70:	2aa080e7          	jalr	682(ra) # 80003e16 <readi>
    80004b74:	892a                	mv	s2,a0
    80004b76:	00a05563          	blez	a0,80004b80 <fileread+0x56>
      f->off += r;
    80004b7a:	509c                	lw	a5,32(s1)
    80004b7c:	9fa9                	addw	a5,a5,a0
    80004b7e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b80:	6c88                	ld	a0,24(s1)
    80004b82:	fffff097          	auipc	ra,0xfffff
    80004b86:	0a2080e7          	jalr	162(ra) # 80003c24 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b8a:	854a                	mv	a0,s2
    80004b8c:	70a2                	ld	ra,40(sp)
    80004b8e:	7402                	ld	s0,32(sp)
    80004b90:	64e2                	ld	s1,24(sp)
    80004b92:	6942                	ld	s2,16(sp)
    80004b94:	69a2                	ld	s3,8(sp)
    80004b96:	6145                	addi	sp,sp,48
    80004b98:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b9a:	6908                	ld	a0,16(a0)
    80004b9c:	00000097          	auipc	ra,0x0
    80004ba0:	3ce080e7          	jalr	974(ra) # 80004f6a <piperead>
    80004ba4:	892a                	mv	s2,a0
    80004ba6:	b7d5                	j	80004b8a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004ba8:	02451783          	lh	a5,36(a0)
    80004bac:	03079693          	slli	a3,a5,0x30
    80004bb0:	92c1                	srli	a3,a3,0x30
    80004bb2:	4725                	li	a4,9
    80004bb4:	02d76863          	bltu	a4,a3,80004be4 <fileread+0xba>
    80004bb8:	0792                	slli	a5,a5,0x4
    80004bba:	0001d717          	auipc	a4,0x1d
    80004bbe:	86e70713          	addi	a4,a4,-1938 # 80021428 <devsw>
    80004bc2:	97ba                	add	a5,a5,a4
    80004bc4:	639c                	ld	a5,0(a5)
    80004bc6:	c38d                	beqz	a5,80004be8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004bc8:	4505                	li	a0,1
    80004bca:	9782                	jalr	a5
    80004bcc:	892a                	mv	s2,a0
    80004bce:	bf75                	j	80004b8a <fileread+0x60>
    panic("fileread");
    80004bd0:	00004517          	auipc	a0,0x4
    80004bd4:	b5850513          	addi	a0,a0,-1192 # 80008728 <syscalls+0x288>
    80004bd8:	ffffc097          	auipc	ra,0xffffc
    80004bdc:	96c080e7          	jalr	-1684(ra) # 80000544 <panic>
    return -1;
    80004be0:	597d                	li	s2,-1
    80004be2:	b765                	j	80004b8a <fileread+0x60>
      return -1;
    80004be4:	597d                	li	s2,-1
    80004be6:	b755                	j	80004b8a <fileread+0x60>
    80004be8:	597d                	li	s2,-1
    80004bea:	b745                	j	80004b8a <fileread+0x60>

0000000080004bec <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004bec:	715d                	addi	sp,sp,-80
    80004bee:	e486                	sd	ra,72(sp)
    80004bf0:	e0a2                	sd	s0,64(sp)
    80004bf2:	fc26                	sd	s1,56(sp)
    80004bf4:	f84a                	sd	s2,48(sp)
    80004bf6:	f44e                	sd	s3,40(sp)
    80004bf8:	f052                	sd	s4,32(sp)
    80004bfa:	ec56                	sd	s5,24(sp)
    80004bfc:	e85a                	sd	s6,16(sp)
    80004bfe:	e45e                	sd	s7,8(sp)
    80004c00:	e062                	sd	s8,0(sp)
    80004c02:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c04:	00954783          	lbu	a5,9(a0)
    80004c08:	10078663          	beqz	a5,80004d14 <filewrite+0x128>
    80004c0c:	892a                	mv	s2,a0
    80004c0e:	8aae                	mv	s5,a1
    80004c10:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c12:	411c                	lw	a5,0(a0)
    80004c14:	4705                	li	a4,1
    80004c16:	02e78263          	beq	a5,a4,80004c3a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c1a:	470d                	li	a4,3
    80004c1c:	02e78663          	beq	a5,a4,80004c48 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c20:	4709                	li	a4,2
    80004c22:	0ee79163          	bne	a5,a4,80004d04 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c26:	0ac05d63          	blez	a2,80004ce0 <filewrite+0xf4>
    int i = 0;
    80004c2a:	4981                	li	s3,0
    80004c2c:	6b05                	lui	s6,0x1
    80004c2e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004c32:	6b85                	lui	s7,0x1
    80004c34:	c00b8b9b          	addiw	s7,s7,-1024
    80004c38:	a861                	j	80004cd0 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004c3a:	6908                	ld	a0,16(a0)
    80004c3c:	00000097          	auipc	ra,0x0
    80004c40:	22e080e7          	jalr	558(ra) # 80004e6a <pipewrite>
    80004c44:	8a2a                	mv	s4,a0
    80004c46:	a045                	j	80004ce6 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c48:	02451783          	lh	a5,36(a0)
    80004c4c:	03079693          	slli	a3,a5,0x30
    80004c50:	92c1                	srli	a3,a3,0x30
    80004c52:	4725                	li	a4,9
    80004c54:	0cd76263          	bltu	a4,a3,80004d18 <filewrite+0x12c>
    80004c58:	0792                	slli	a5,a5,0x4
    80004c5a:	0001c717          	auipc	a4,0x1c
    80004c5e:	7ce70713          	addi	a4,a4,1998 # 80021428 <devsw>
    80004c62:	97ba                	add	a5,a5,a4
    80004c64:	679c                	ld	a5,8(a5)
    80004c66:	cbdd                	beqz	a5,80004d1c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c68:	4505                	li	a0,1
    80004c6a:	9782                	jalr	a5
    80004c6c:	8a2a                	mv	s4,a0
    80004c6e:	a8a5                	j	80004ce6 <filewrite+0xfa>
    80004c70:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c74:	00000097          	auipc	ra,0x0
    80004c78:	8b0080e7          	jalr	-1872(ra) # 80004524 <begin_op>
      ilock(f->ip);
    80004c7c:	01893503          	ld	a0,24(s2)
    80004c80:	fffff097          	auipc	ra,0xfffff
    80004c84:	ee2080e7          	jalr	-286(ra) # 80003b62 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c88:	8762                	mv	a4,s8
    80004c8a:	02092683          	lw	a3,32(s2)
    80004c8e:	01598633          	add	a2,s3,s5
    80004c92:	4585                	li	a1,1
    80004c94:	01893503          	ld	a0,24(s2)
    80004c98:	fffff097          	auipc	ra,0xfffff
    80004c9c:	276080e7          	jalr	630(ra) # 80003f0e <writei>
    80004ca0:	84aa                	mv	s1,a0
    80004ca2:	00a05763          	blez	a0,80004cb0 <filewrite+0xc4>
        f->off += r;
    80004ca6:	02092783          	lw	a5,32(s2)
    80004caa:	9fa9                	addw	a5,a5,a0
    80004cac:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004cb0:	01893503          	ld	a0,24(s2)
    80004cb4:	fffff097          	auipc	ra,0xfffff
    80004cb8:	f70080e7          	jalr	-144(ra) # 80003c24 <iunlock>
      end_op();
    80004cbc:	00000097          	auipc	ra,0x0
    80004cc0:	8e8080e7          	jalr	-1816(ra) # 800045a4 <end_op>

      if(r != n1){
    80004cc4:	009c1f63          	bne	s8,s1,80004ce2 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004cc8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ccc:	0149db63          	bge	s3,s4,80004ce2 <filewrite+0xf6>
      int n1 = n - i;
    80004cd0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004cd4:	84be                	mv	s1,a5
    80004cd6:	2781                	sext.w	a5,a5
    80004cd8:	f8fb5ce3          	bge	s6,a5,80004c70 <filewrite+0x84>
    80004cdc:	84de                	mv	s1,s7
    80004cde:	bf49                	j	80004c70 <filewrite+0x84>
    int i = 0;
    80004ce0:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004ce2:	013a1f63          	bne	s4,s3,80004d00 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ce6:	8552                	mv	a0,s4
    80004ce8:	60a6                	ld	ra,72(sp)
    80004cea:	6406                	ld	s0,64(sp)
    80004cec:	74e2                	ld	s1,56(sp)
    80004cee:	7942                	ld	s2,48(sp)
    80004cf0:	79a2                	ld	s3,40(sp)
    80004cf2:	7a02                	ld	s4,32(sp)
    80004cf4:	6ae2                	ld	s5,24(sp)
    80004cf6:	6b42                	ld	s6,16(sp)
    80004cf8:	6ba2                	ld	s7,8(sp)
    80004cfa:	6c02                	ld	s8,0(sp)
    80004cfc:	6161                	addi	sp,sp,80
    80004cfe:	8082                	ret
    ret = (i == n ? n : -1);
    80004d00:	5a7d                	li	s4,-1
    80004d02:	b7d5                	j	80004ce6 <filewrite+0xfa>
    panic("filewrite");
    80004d04:	00004517          	auipc	a0,0x4
    80004d08:	a3450513          	addi	a0,a0,-1484 # 80008738 <syscalls+0x298>
    80004d0c:	ffffc097          	auipc	ra,0xffffc
    80004d10:	838080e7          	jalr	-1992(ra) # 80000544 <panic>
    return -1;
    80004d14:	5a7d                	li	s4,-1
    80004d16:	bfc1                	j	80004ce6 <filewrite+0xfa>
      return -1;
    80004d18:	5a7d                	li	s4,-1
    80004d1a:	b7f1                	j	80004ce6 <filewrite+0xfa>
    80004d1c:	5a7d                	li	s4,-1
    80004d1e:	b7e1                	j	80004ce6 <filewrite+0xfa>

0000000080004d20 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d20:	7179                	addi	sp,sp,-48
    80004d22:	f406                	sd	ra,40(sp)
    80004d24:	f022                	sd	s0,32(sp)
    80004d26:	ec26                	sd	s1,24(sp)
    80004d28:	e84a                	sd	s2,16(sp)
    80004d2a:	e44e                	sd	s3,8(sp)
    80004d2c:	e052                	sd	s4,0(sp)
    80004d2e:	1800                	addi	s0,sp,48
    80004d30:	84aa                	mv	s1,a0
    80004d32:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d34:	0005b023          	sd	zero,0(a1)
    80004d38:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d3c:	00000097          	auipc	ra,0x0
    80004d40:	bf8080e7          	jalr	-1032(ra) # 80004934 <filealloc>
    80004d44:	e088                	sd	a0,0(s1)
    80004d46:	c551                	beqz	a0,80004dd2 <pipealloc+0xb2>
    80004d48:	00000097          	auipc	ra,0x0
    80004d4c:	bec080e7          	jalr	-1044(ra) # 80004934 <filealloc>
    80004d50:	00aa3023          	sd	a0,0(s4)
    80004d54:	c92d                	beqz	a0,80004dc6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d56:	ffffc097          	auipc	ra,0xffffc
    80004d5a:	da4080e7          	jalr	-604(ra) # 80000afa <kalloc>
    80004d5e:	892a                	mv	s2,a0
    80004d60:	c125                	beqz	a0,80004dc0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d62:	4985                	li	s3,1
    80004d64:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d68:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d6c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d70:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d74:	00004597          	auipc	a1,0x4
    80004d78:	9d458593          	addi	a1,a1,-1580 # 80008748 <syscalls+0x2a8>
    80004d7c:	ffffc097          	auipc	ra,0xffffc
    80004d80:	dde080e7          	jalr	-546(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004d84:	609c                	ld	a5,0(s1)
    80004d86:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d8a:	609c                	ld	a5,0(s1)
    80004d8c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d90:	609c                	ld	a5,0(s1)
    80004d92:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d96:	609c                	ld	a5,0(s1)
    80004d98:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d9c:	000a3783          	ld	a5,0(s4)
    80004da0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004da4:	000a3783          	ld	a5,0(s4)
    80004da8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004dac:	000a3783          	ld	a5,0(s4)
    80004db0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004db4:	000a3783          	ld	a5,0(s4)
    80004db8:	0127b823          	sd	s2,16(a5)
  return 0;
    80004dbc:	4501                	li	a0,0
    80004dbe:	a025                	j	80004de6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004dc0:	6088                	ld	a0,0(s1)
    80004dc2:	e501                	bnez	a0,80004dca <pipealloc+0xaa>
    80004dc4:	a039                	j	80004dd2 <pipealloc+0xb2>
    80004dc6:	6088                	ld	a0,0(s1)
    80004dc8:	c51d                	beqz	a0,80004df6 <pipealloc+0xd6>
    fileclose(*f0);
    80004dca:	00000097          	auipc	ra,0x0
    80004dce:	c26080e7          	jalr	-986(ra) # 800049f0 <fileclose>
  if(*f1)
    80004dd2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004dd6:	557d                	li	a0,-1
  if(*f1)
    80004dd8:	c799                	beqz	a5,80004de6 <pipealloc+0xc6>
    fileclose(*f1);
    80004dda:	853e                	mv	a0,a5
    80004ddc:	00000097          	auipc	ra,0x0
    80004de0:	c14080e7          	jalr	-1004(ra) # 800049f0 <fileclose>
  return -1;
    80004de4:	557d                	li	a0,-1
}
    80004de6:	70a2                	ld	ra,40(sp)
    80004de8:	7402                	ld	s0,32(sp)
    80004dea:	64e2                	ld	s1,24(sp)
    80004dec:	6942                	ld	s2,16(sp)
    80004dee:	69a2                	ld	s3,8(sp)
    80004df0:	6a02                	ld	s4,0(sp)
    80004df2:	6145                	addi	sp,sp,48
    80004df4:	8082                	ret
  return -1;
    80004df6:	557d                	li	a0,-1
    80004df8:	b7fd                	j	80004de6 <pipealloc+0xc6>

0000000080004dfa <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004dfa:	1101                	addi	sp,sp,-32
    80004dfc:	ec06                	sd	ra,24(sp)
    80004dfe:	e822                	sd	s0,16(sp)
    80004e00:	e426                	sd	s1,8(sp)
    80004e02:	e04a                	sd	s2,0(sp)
    80004e04:	1000                	addi	s0,sp,32
    80004e06:	84aa                	mv	s1,a0
    80004e08:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e0a:	ffffc097          	auipc	ra,0xffffc
    80004e0e:	de0080e7          	jalr	-544(ra) # 80000bea <acquire>
  if(writable){
    80004e12:	02090d63          	beqz	s2,80004e4c <pipeclose+0x52>
    pi->writeopen = 0;
    80004e16:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e1a:	21848513          	addi	a0,s1,536
    80004e1e:	ffffd097          	auipc	ra,0xffffd
    80004e22:	2b0080e7          	jalr	688(ra) # 800020ce <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e26:	2204b783          	ld	a5,544(s1)
    80004e2a:	eb95                	bnez	a5,80004e5e <pipeclose+0x64>
    release(&pi->lock);
    80004e2c:	8526                	mv	a0,s1
    80004e2e:	ffffc097          	auipc	ra,0xffffc
    80004e32:	e70080e7          	jalr	-400(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004e36:	8526                	mv	a0,s1
    80004e38:	ffffc097          	auipc	ra,0xffffc
    80004e3c:	bc6080e7          	jalr	-1082(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004e40:	60e2                	ld	ra,24(sp)
    80004e42:	6442                	ld	s0,16(sp)
    80004e44:	64a2                	ld	s1,8(sp)
    80004e46:	6902                	ld	s2,0(sp)
    80004e48:	6105                	addi	sp,sp,32
    80004e4a:	8082                	ret
    pi->readopen = 0;
    80004e4c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e50:	21c48513          	addi	a0,s1,540
    80004e54:	ffffd097          	auipc	ra,0xffffd
    80004e58:	27a080e7          	jalr	634(ra) # 800020ce <wakeup>
    80004e5c:	b7e9                	j	80004e26 <pipeclose+0x2c>
    release(&pi->lock);
    80004e5e:	8526                	mv	a0,s1
    80004e60:	ffffc097          	auipc	ra,0xffffc
    80004e64:	e3e080e7          	jalr	-450(ra) # 80000c9e <release>
}
    80004e68:	bfe1                	j	80004e40 <pipeclose+0x46>

0000000080004e6a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e6a:	7159                	addi	sp,sp,-112
    80004e6c:	f486                	sd	ra,104(sp)
    80004e6e:	f0a2                	sd	s0,96(sp)
    80004e70:	eca6                	sd	s1,88(sp)
    80004e72:	e8ca                	sd	s2,80(sp)
    80004e74:	e4ce                	sd	s3,72(sp)
    80004e76:	e0d2                	sd	s4,64(sp)
    80004e78:	fc56                	sd	s5,56(sp)
    80004e7a:	f85a                	sd	s6,48(sp)
    80004e7c:	f45e                	sd	s7,40(sp)
    80004e7e:	f062                	sd	s8,32(sp)
    80004e80:	ec66                	sd	s9,24(sp)
    80004e82:	1880                	addi	s0,sp,112
    80004e84:	84aa                	mv	s1,a0
    80004e86:	8aae                	mv	s5,a1
    80004e88:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e8a:	ffffd097          	auipc	ra,0xffffd
    80004e8e:	b3c080e7          	jalr	-1220(ra) # 800019c6 <myproc>
    80004e92:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e94:	8526                	mv	a0,s1
    80004e96:	ffffc097          	auipc	ra,0xffffc
    80004e9a:	d54080e7          	jalr	-684(ra) # 80000bea <acquire>
  while(i < n){
    80004e9e:	0d405463          	blez	s4,80004f66 <pipewrite+0xfc>
    80004ea2:	8ba6                	mv	s7,s1
  int i = 0;
    80004ea4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ea6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ea8:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004eac:	21c48c13          	addi	s8,s1,540
    80004eb0:	a08d                	j	80004f12 <pipewrite+0xa8>
      release(&pi->lock);
    80004eb2:	8526                	mv	a0,s1
    80004eb4:	ffffc097          	auipc	ra,0xffffc
    80004eb8:	dea080e7          	jalr	-534(ra) # 80000c9e <release>
      return -1;
    80004ebc:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ebe:	854a                	mv	a0,s2
    80004ec0:	70a6                	ld	ra,104(sp)
    80004ec2:	7406                	ld	s0,96(sp)
    80004ec4:	64e6                	ld	s1,88(sp)
    80004ec6:	6946                	ld	s2,80(sp)
    80004ec8:	69a6                	ld	s3,72(sp)
    80004eca:	6a06                	ld	s4,64(sp)
    80004ecc:	7ae2                	ld	s5,56(sp)
    80004ece:	7b42                	ld	s6,48(sp)
    80004ed0:	7ba2                	ld	s7,40(sp)
    80004ed2:	7c02                	ld	s8,32(sp)
    80004ed4:	6ce2                	ld	s9,24(sp)
    80004ed6:	6165                	addi	sp,sp,112
    80004ed8:	8082                	ret
      wakeup(&pi->nread);
    80004eda:	8566                	mv	a0,s9
    80004edc:	ffffd097          	auipc	ra,0xffffd
    80004ee0:	1f2080e7          	jalr	498(ra) # 800020ce <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ee4:	85de                	mv	a1,s7
    80004ee6:	8562                	mv	a0,s8
    80004ee8:	ffffd097          	auipc	ra,0xffffd
    80004eec:	182080e7          	jalr	386(ra) # 8000206a <sleep>
    80004ef0:	a839                	j	80004f0e <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ef2:	21c4a783          	lw	a5,540(s1)
    80004ef6:	0017871b          	addiw	a4,a5,1
    80004efa:	20e4ae23          	sw	a4,540(s1)
    80004efe:	1ff7f793          	andi	a5,a5,511
    80004f02:	97a6                	add	a5,a5,s1
    80004f04:	f9f44703          	lbu	a4,-97(s0)
    80004f08:	00e78c23          	sb	a4,24(a5)
      i++;
    80004f0c:	2905                	addiw	s2,s2,1
  while(i < n){
    80004f0e:	05495063          	bge	s2,s4,80004f4e <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004f12:	2204a783          	lw	a5,544(s1)
    80004f16:	dfd1                	beqz	a5,80004eb2 <pipewrite+0x48>
    80004f18:	854e                	mv	a0,s3
    80004f1a:	ffffd097          	auipc	ra,0xffffd
    80004f1e:	472080e7          	jalr	1138(ra) # 8000238c <killed>
    80004f22:	f941                	bnez	a0,80004eb2 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f24:	2184a783          	lw	a5,536(s1)
    80004f28:	21c4a703          	lw	a4,540(s1)
    80004f2c:	2007879b          	addiw	a5,a5,512
    80004f30:	faf705e3          	beq	a4,a5,80004eda <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f34:	4685                	li	a3,1
    80004f36:	01590633          	add	a2,s2,s5
    80004f3a:	f9f40593          	addi	a1,s0,-97
    80004f3e:	0509b503          	ld	a0,80(s3)
    80004f42:	ffffc097          	auipc	ra,0xffffc
    80004f46:	7ce080e7          	jalr	1998(ra) # 80001710 <copyin>
    80004f4a:	fb6514e3          	bne	a0,s6,80004ef2 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004f4e:	21848513          	addi	a0,s1,536
    80004f52:	ffffd097          	auipc	ra,0xffffd
    80004f56:	17c080e7          	jalr	380(ra) # 800020ce <wakeup>
  release(&pi->lock);
    80004f5a:	8526                	mv	a0,s1
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	d42080e7          	jalr	-702(ra) # 80000c9e <release>
  return i;
    80004f64:	bfa9                	j	80004ebe <pipewrite+0x54>
  int i = 0;
    80004f66:	4901                	li	s2,0
    80004f68:	b7dd                	j	80004f4e <pipewrite+0xe4>

0000000080004f6a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f6a:	715d                	addi	sp,sp,-80
    80004f6c:	e486                	sd	ra,72(sp)
    80004f6e:	e0a2                	sd	s0,64(sp)
    80004f70:	fc26                	sd	s1,56(sp)
    80004f72:	f84a                	sd	s2,48(sp)
    80004f74:	f44e                	sd	s3,40(sp)
    80004f76:	f052                	sd	s4,32(sp)
    80004f78:	ec56                	sd	s5,24(sp)
    80004f7a:	e85a                	sd	s6,16(sp)
    80004f7c:	0880                	addi	s0,sp,80
    80004f7e:	84aa                	mv	s1,a0
    80004f80:	892e                	mv	s2,a1
    80004f82:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f84:	ffffd097          	auipc	ra,0xffffd
    80004f88:	a42080e7          	jalr	-1470(ra) # 800019c6 <myproc>
    80004f8c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f8e:	8b26                	mv	s6,s1
    80004f90:	8526                	mv	a0,s1
    80004f92:	ffffc097          	auipc	ra,0xffffc
    80004f96:	c58080e7          	jalr	-936(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f9a:	2184a703          	lw	a4,536(s1)
    80004f9e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fa2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fa6:	02f71763          	bne	a4,a5,80004fd4 <piperead+0x6a>
    80004faa:	2244a783          	lw	a5,548(s1)
    80004fae:	c39d                	beqz	a5,80004fd4 <piperead+0x6a>
    if(killed(pr)){
    80004fb0:	8552                	mv	a0,s4
    80004fb2:	ffffd097          	auipc	ra,0xffffd
    80004fb6:	3da080e7          	jalr	986(ra) # 8000238c <killed>
    80004fba:	e941                	bnez	a0,8000504a <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fbc:	85da                	mv	a1,s6
    80004fbe:	854e                	mv	a0,s3
    80004fc0:	ffffd097          	auipc	ra,0xffffd
    80004fc4:	0aa080e7          	jalr	170(ra) # 8000206a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fc8:	2184a703          	lw	a4,536(s1)
    80004fcc:	21c4a783          	lw	a5,540(s1)
    80004fd0:	fcf70de3          	beq	a4,a5,80004faa <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fd4:	09505263          	blez	s5,80005058 <piperead+0xee>
    80004fd8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fda:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004fdc:	2184a783          	lw	a5,536(s1)
    80004fe0:	21c4a703          	lw	a4,540(s1)
    80004fe4:	02f70d63          	beq	a4,a5,8000501e <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004fe8:	0017871b          	addiw	a4,a5,1
    80004fec:	20e4ac23          	sw	a4,536(s1)
    80004ff0:	1ff7f793          	andi	a5,a5,511
    80004ff4:	97a6                	add	a5,a5,s1
    80004ff6:	0187c783          	lbu	a5,24(a5)
    80004ffa:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ffe:	4685                	li	a3,1
    80005000:	fbf40613          	addi	a2,s0,-65
    80005004:	85ca                	mv	a1,s2
    80005006:	050a3503          	ld	a0,80(s4)
    8000500a:	ffffc097          	auipc	ra,0xffffc
    8000500e:	67a080e7          	jalr	1658(ra) # 80001684 <copyout>
    80005012:	01650663          	beq	a0,s6,8000501e <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005016:	2985                	addiw	s3,s3,1
    80005018:	0905                	addi	s2,s2,1
    8000501a:	fd3a91e3          	bne	s5,s3,80004fdc <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000501e:	21c48513          	addi	a0,s1,540
    80005022:	ffffd097          	auipc	ra,0xffffd
    80005026:	0ac080e7          	jalr	172(ra) # 800020ce <wakeup>
  release(&pi->lock);
    8000502a:	8526                	mv	a0,s1
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	c72080e7          	jalr	-910(ra) # 80000c9e <release>
  return i;
}
    80005034:	854e                	mv	a0,s3
    80005036:	60a6                	ld	ra,72(sp)
    80005038:	6406                	ld	s0,64(sp)
    8000503a:	74e2                	ld	s1,56(sp)
    8000503c:	7942                	ld	s2,48(sp)
    8000503e:	79a2                	ld	s3,40(sp)
    80005040:	7a02                	ld	s4,32(sp)
    80005042:	6ae2                	ld	s5,24(sp)
    80005044:	6b42                	ld	s6,16(sp)
    80005046:	6161                	addi	sp,sp,80
    80005048:	8082                	ret
      release(&pi->lock);
    8000504a:	8526                	mv	a0,s1
    8000504c:	ffffc097          	auipc	ra,0xffffc
    80005050:	c52080e7          	jalr	-942(ra) # 80000c9e <release>
      return -1;
    80005054:	59fd                	li	s3,-1
    80005056:	bff9                	j	80005034 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005058:	4981                	li	s3,0
    8000505a:	b7d1                	j	8000501e <piperead+0xb4>

000000008000505c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000505c:	1141                	addi	sp,sp,-16
    8000505e:	e422                	sd	s0,8(sp)
    80005060:	0800                	addi	s0,sp,16
    80005062:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005064:	8905                	andi	a0,a0,1
    80005066:	c111                	beqz	a0,8000506a <flags2perm+0xe>
      perm = PTE_X;
    80005068:	4521                	li	a0,8
    if(flags & 0x2)
    8000506a:	8b89                	andi	a5,a5,2
    8000506c:	c399                	beqz	a5,80005072 <flags2perm+0x16>
      perm |= PTE_W;
    8000506e:	00456513          	ori	a0,a0,4
    return perm;
}
    80005072:	6422                	ld	s0,8(sp)
    80005074:	0141                	addi	sp,sp,16
    80005076:	8082                	ret

0000000080005078 <exec>:

int
exec(char *path, char **argv)
{
    80005078:	df010113          	addi	sp,sp,-528
    8000507c:	20113423          	sd	ra,520(sp)
    80005080:	20813023          	sd	s0,512(sp)
    80005084:	ffa6                	sd	s1,504(sp)
    80005086:	fbca                	sd	s2,496(sp)
    80005088:	f7ce                	sd	s3,488(sp)
    8000508a:	f3d2                	sd	s4,480(sp)
    8000508c:	efd6                	sd	s5,472(sp)
    8000508e:	ebda                	sd	s6,464(sp)
    80005090:	e7de                	sd	s7,456(sp)
    80005092:	e3e2                	sd	s8,448(sp)
    80005094:	ff66                	sd	s9,440(sp)
    80005096:	fb6a                	sd	s10,432(sp)
    80005098:	f76e                	sd	s11,424(sp)
    8000509a:	0c00                	addi	s0,sp,528
    8000509c:	84aa                	mv	s1,a0
    8000509e:	dea43c23          	sd	a0,-520(s0)
    800050a2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800050a6:	ffffd097          	auipc	ra,0xffffd
    800050aa:	920080e7          	jalr	-1760(ra) # 800019c6 <myproc>
    800050ae:	892a                	mv	s2,a0

  begin_op();
    800050b0:	fffff097          	auipc	ra,0xfffff
    800050b4:	474080e7          	jalr	1140(ra) # 80004524 <begin_op>

  if((ip = namei(path)) == 0){
    800050b8:	8526                	mv	a0,s1
    800050ba:	fffff097          	auipc	ra,0xfffff
    800050be:	24e080e7          	jalr	590(ra) # 80004308 <namei>
    800050c2:	c92d                	beqz	a0,80005134 <exec+0xbc>
    800050c4:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800050c6:	fffff097          	auipc	ra,0xfffff
    800050ca:	a9c080e7          	jalr	-1380(ra) # 80003b62 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800050ce:	04000713          	li	a4,64
    800050d2:	4681                	li	a3,0
    800050d4:	e5040613          	addi	a2,s0,-432
    800050d8:	4581                	li	a1,0
    800050da:	8526                	mv	a0,s1
    800050dc:	fffff097          	auipc	ra,0xfffff
    800050e0:	d3a080e7          	jalr	-710(ra) # 80003e16 <readi>
    800050e4:	04000793          	li	a5,64
    800050e8:	00f51a63          	bne	a0,a5,800050fc <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800050ec:	e5042703          	lw	a4,-432(s0)
    800050f0:	464c47b7          	lui	a5,0x464c4
    800050f4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800050f8:	04f70463          	beq	a4,a5,80005140 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800050fc:	8526                	mv	a0,s1
    800050fe:	fffff097          	auipc	ra,0xfffff
    80005102:	cc6080e7          	jalr	-826(ra) # 80003dc4 <iunlockput>
    end_op();
    80005106:	fffff097          	auipc	ra,0xfffff
    8000510a:	49e080e7          	jalr	1182(ra) # 800045a4 <end_op>
  }
  return -1;
    8000510e:	557d                	li	a0,-1
}
    80005110:	20813083          	ld	ra,520(sp)
    80005114:	20013403          	ld	s0,512(sp)
    80005118:	74fe                	ld	s1,504(sp)
    8000511a:	795e                	ld	s2,496(sp)
    8000511c:	79be                	ld	s3,488(sp)
    8000511e:	7a1e                	ld	s4,480(sp)
    80005120:	6afe                	ld	s5,472(sp)
    80005122:	6b5e                	ld	s6,464(sp)
    80005124:	6bbe                	ld	s7,456(sp)
    80005126:	6c1e                	ld	s8,448(sp)
    80005128:	7cfa                	ld	s9,440(sp)
    8000512a:	7d5a                	ld	s10,432(sp)
    8000512c:	7dba                	ld	s11,424(sp)
    8000512e:	21010113          	addi	sp,sp,528
    80005132:	8082                	ret
    end_op();
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	470080e7          	jalr	1136(ra) # 800045a4 <end_op>
    return -1;
    8000513c:	557d                	li	a0,-1
    8000513e:	bfc9                	j	80005110 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005140:	854a                	mv	a0,s2
    80005142:	ffffd097          	auipc	ra,0xffffd
    80005146:	948080e7          	jalr	-1720(ra) # 80001a8a <proc_pagetable>
    8000514a:	8baa                	mv	s7,a0
    8000514c:	d945                	beqz	a0,800050fc <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000514e:	e7042983          	lw	s3,-400(s0)
    80005152:	e8845783          	lhu	a5,-376(s0)
    80005156:	c7ad                	beqz	a5,800051c0 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005158:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000515a:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    8000515c:	6c85                	lui	s9,0x1
    8000515e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005162:	def43823          	sd	a5,-528(s0)
    80005166:	ac0d                	j	80005398 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005168:	00003517          	auipc	a0,0x3
    8000516c:	5e850513          	addi	a0,a0,1512 # 80008750 <syscalls+0x2b0>
    80005170:	ffffb097          	auipc	ra,0xffffb
    80005174:	3d4080e7          	jalr	980(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005178:	8756                	mv	a4,s5
    8000517a:	012d86bb          	addw	a3,s11,s2
    8000517e:	4581                	li	a1,0
    80005180:	8526                	mv	a0,s1
    80005182:	fffff097          	auipc	ra,0xfffff
    80005186:	c94080e7          	jalr	-876(ra) # 80003e16 <readi>
    8000518a:	2501                	sext.w	a0,a0
    8000518c:	1aaa9a63          	bne	s5,a0,80005340 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005190:	6785                	lui	a5,0x1
    80005192:	0127893b          	addw	s2,a5,s2
    80005196:	77fd                	lui	a5,0xfffff
    80005198:	01478a3b          	addw	s4,a5,s4
    8000519c:	1f897563          	bgeu	s2,s8,80005386 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    800051a0:	02091593          	slli	a1,s2,0x20
    800051a4:	9181                	srli	a1,a1,0x20
    800051a6:	95ea                	add	a1,a1,s10
    800051a8:	855e                	mv	a0,s7
    800051aa:	ffffc097          	auipc	ra,0xffffc
    800051ae:	ece080e7          	jalr	-306(ra) # 80001078 <walkaddr>
    800051b2:	862a                	mv	a2,a0
    if(pa == 0)
    800051b4:	d955                	beqz	a0,80005168 <exec+0xf0>
      n = PGSIZE;
    800051b6:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800051b8:	fd9a70e3          	bgeu	s4,s9,80005178 <exec+0x100>
      n = sz - i;
    800051bc:	8ad2                	mv	s5,s4
    800051be:	bf6d                	j	80005178 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051c0:	4a01                	li	s4,0
  iunlockput(ip);
    800051c2:	8526                	mv	a0,s1
    800051c4:	fffff097          	auipc	ra,0xfffff
    800051c8:	c00080e7          	jalr	-1024(ra) # 80003dc4 <iunlockput>
  end_op();
    800051cc:	fffff097          	auipc	ra,0xfffff
    800051d0:	3d8080e7          	jalr	984(ra) # 800045a4 <end_op>
  p = myproc();
    800051d4:	ffffc097          	auipc	ra,0xffffc
    800051d8:	7f2080e7          	jalr	2034(ra) # 800019c6 <myproc>
    800051dc:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800051de:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800051e2:	6785                	lui	a5,0x1
    800051e4:	17fd                	addi	a5,a5,-1
    800051e6:	9a3e                	add	s4,s4,a5
    800051e8:	757d                	lui	a0,0xfffff
    800051ea:	00aa77b3          	and	a5,s4,a0
    800051ee:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800051f2:	4691                	li	a3,4
    800051f4:	6609                	lui	a2,0x2
    800051f6:	963e                	add	a2,a2,a5
    800051f8:	85be                	mv	a1,a5
    800051fa:	855e                	mv	a0,s7
    800051fc:	ffffc097          	auipc	ra,0xffffc
    80005200:	230080e7          	jalr	560(ra) # 8000142c <uvmalloc>
    80005204:	8b2a                	mv	s6,a0
  ip = 0;
    80005206:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005208:	12050c63          	beqz	a0,80005340 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000520c:	75f9                	lui	a1,0xffffe
    8000520e:	95aa                	add	a1,a1,a0
    80005210:	855e                	mv	a0,s7
    80005212:	ffffc097          	auipc	ra,0xffffc
    80005216:	440080e7          	jalr	1088(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    8000521a:	7c7d                	lui	s8,0xfffff
    8000521c:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000521e:	e0043783          	ld	a5,-512(s0)
    80005222:	6388                	ld	a0,0(a5)
    80005224:	c535                	beqz	a0,80005290 <exec+0x218>
    80005226:	e9040993          	addi	s3,s0,-368
    8000522a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000522e:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005230:	ffffc097          	auipc	ra,0xffffc
    80005234:	c3a080e7          	jalr	-966(ra) # 80000e6a <strlen>
    80005238:	2505                	addiw	a0,a0,1
    8000523a:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000523e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005242:	13896663          	bltu	s2,s8,8000536e <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005246:	e0043d83          	ld	s11,-512(s0)
    8000524a:	000dba03          	ld	s4,0(s11)
    8000524e:	8552                	mv	a0,s4
    80005250:	ffffc097          	auipc	ra,0xffffc
    80005254:	c1a080e7          	jalr	-998(ra) # 80000e6a <strlen>
    80005258:	0015069b          	addiw	a3,a0,1
    8000525c:	8652                	mv	a2,s4
    8000525e:	85ca                	mv	a1,s2
    80005260:	855e                	mv	a0,s7
    80005262:	ffffc097          	auipc	ra,0xffffc
    80005266:	422080e7          	jalr	1058(ra) # 80001684 <copyout>
    8000526a:	10054663          	bltz	a0,80005376 <exec+0x2fe>
    ustack[argc] = sp;
    8000526e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005272:	0485                	addi	s1,s1,1
    80005274:	008d8793          	addi	a5,s11,8
    80005278:	e0f43023          	sd	a5,-512(s0)
    8000527c:	008db503          	ld	a0,8(s11)
    80005280:	c911                	beqz	a0,80005294 <exec+0x21c>
    if(argc >= MAXARG)
    80005282:	09a1                	addi	s3,s3,8
    80005284:	fb3c96e3          	bne	s9,s3,80005230 <exec+0x1b8>
  sz = sz1;
    80005288:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000528c:	4481                	li	s1,0
    8000528e:	a84d                	j	80005340 <exec+0x2c8>
  sp = sz;
    80005290:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005292:	4481                	li	s1,0
  ustack[argc] = 0;
    80005294:	00349793          	slli	a5,s1,0x3
    80005298:	f9040713          	addi	a4,s0,-112
    8000529c:	97ba                	add	a5,a5,a4
    8000529e:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800052a2:	00148693          	addi	a3,s1,1
    800052a6:	068e                	slli	a3,a3,0x3
    800052a8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800052ac:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800052b0:	01897663          	bgeu	s2,s8,800052bc <exec+0x244>
  sz = sz1;
    800052b4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052b8:	4481                	li	s1,0
    800052ba:	a059                	j	80005340 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800052bc:	e9040613          	addi	a2,s0,-368
    800052c0:	85ca                	mv	a1,s2
    800052c2:	855e                	mv	a0,s7
    800052c4:	ffffc097          	auipc	ra,0xffffc
    800052c8:	3c0080e7          	jalr	960(ra) # 80001684 <copyout>
    800052cc:	0a054963          	bltz	a0,8000537e <exec+0x306>
  p->trapframe->a1 = sp;
    800052d0:	058ab783          	ld	a5,88(s5)
    800052d4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800052d8:	df843783          	ld	a5,-520(s0)
    800052dc:	0007c703          	lbu	a4,0(a5)
    800052e0:	cf11                	beqz	a4,800052fc <exec+0x284>
    800052e2:	0785                	addi	a5,a5,1
    if(*s == '/')
    800052e4:	02f00693          	li	a3,47
    800052e8:	a039                	j	800052f6 <exec+0x27e>
      last = s+1;
    800052ea:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800052ee:	0785                	addi	a5,a5,1
    800052f0:	fff7c703          	lbu	a4,-1(a5)
    800052f4:	c701                	beqz	a4,800052fc <exec+0x284>
    if(*s == '/')
    800052f6:	fed71ce3          	bne	a4,a3,800052ee <exec+0x276>
    800052fa:	bfc5                	j	800052ea <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800052fc:	4641                	li	a2,16
    800052fe:	df843583          	ld	a1,-520(s0)
    80005302:	158a8513          	addi	a0,s5,344
    80005306:	ffffc097          	auipc	ra,0xffffc
    8000530a:	b32080e7          	jalr	-1230(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    8000530e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005312:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005316:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000531a:	058ab783          	ld	a5,88(s5)
    8000531e:	e6843703          	ld	a4,-408(s0)
    80005322:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005324:	058ab783          	ld	a5,88(s5)
    80005328:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000532c:	85ea                	mv	a1,s10
    8000532e:	ffffc097          	auipc	ra,0xffffc
    80005332:	7f8080e7          	jalr	2040(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005336:	0004851b          	sext.w	a0,s1
    8000533a:	bbd9                	j	80005110 <exec+0x98>
    8000533c:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005340:	e0843583          	ld	a1,-504(s0)
    80005344:	855e                	mv	a0,s7
    80005346:	ffffc097          	auipc	ra,0xffffc
    8000534a:	7e0080e7          	jalr	2016(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    8000534e:	da0497e3          	bnez	s1,800050fc <exec+0x84>
  return -1;
    80005352:	557d                	li	a0,-1
    80005354:	bb75                	j	80005110 <exec+0x98>
    80005356:	e1443423          	sd	s4,-504(s0)
    8000535a:	b7dd                	j	80005340 <exec+0x2c8>
    8000535c:	e1443423          	sd	s4,-504(s0)
    80005360:	b7c5                	j	80005340 <exec+0x2c8>
    80005362:	e1443423          	sd	s4,-504(s0)
    80005366:	bfe9                	j	80005340 <exec+0x2c8>
    80005368:	e1443423          	sd	s4,-504(s0)
    8000536c:	bfd1                	j	80005340 <exec+0x2c8>
  sz = sz1;
    8000536e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005372:	4481                	li	s1,0
    80005374:	b7f1                	j	80005340 <exec+0x2c8>
  sz = sz1;
    80005376:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000537a:	4481                	li	s1,0
    8000537c:	b7d1                	j	80005340 <exec+0x2c8>
  sz = sz1;
    8000537e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005382:	4481                	li	s1,0
    80005384:	bf75                	j	80005340 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005386:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000538a:	2b05                	addiw	s6,s6,1
    8000538c:	0389899b          	addiw	s3,s3,56
    80005390:	e8845783          	lhu	a5,-376(s0)
    80005394:	e2fb57e3          	bge	s6,a5,800051c2 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005398:	2981                	sext.w	s3,s3
    8000539a:	03800713          	li	a4,56
    8000539e:	86ce                	mv	a3,s3
    800053a0:	e1840613          	addi	a2,s0,-488
    800053a4:	4581                	li	a1,0
    800053a6:	8526                	mv	a0,s1
    800053a8:	fffff097          	auipc	ra,0xfffff
    800053ac:	a6e080e7          	jalr	-1426(ra) # 80003e16 <readi>
    800053b0:	03800793          	li	a5,56
    800053b4:	f8f514e3          	bne	a0,a5,8000533c <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    800053b8:	e1842783          	lw	a5,-488(s0)
    800053bc:	4705                	li	a4,1
    800053be:	fce796e3          	bne	a5,a4,8000538a <exec+0x312>
    if(ph.memsz < ph.filesz)
    800053c2:	e4043903          	ld	s2,-448(s0)
    800053c6:	e3843783          	ld	a5,-456(s0)
    800053ca:	f8f966e3          	bltu	s2,a5,80005356 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053ce:	e2843783          	ld	a5,-472(s0)
    800053d2:	993e                	add	s2,s2,a5
    800053d4:	f8f964e3          	bltu	s2,a5,8000535c <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    800053d8:	df043703          	ld	a4,-528(s0)
    800053dc:	8ff9                	and	a5,a5,a4
    800053de:	f3d1                	bnez	a5,80005362 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053e0:	e1c42503          	lw	a0,-484(s0)
    800053e4:	00000097          	auipc	ra,0x0
    800053e8:	c78080e7          	jalr	-904(ra) # 8000505c <flags2perm>
    800053ec:	86aa                	mv	a3,a0
    800053ee:	864a                	mv	a2,s2
    800053f0:	85d2                	mv	a1,s4
    800053f2:	855e                	mv	a0,s7
    800053f4:	ffffc097          	auipc	ra,0xffffc
    800053f8:	038080e7          	jalr	56(ra) # 8000142c <uvmalloc>
    800053fc:	e0a43423          	sd	a0,-504(s0)
    80005400:	d525                	beqz	a0,80005368 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005402:	e2843d03          	ld	s10,-472(s0)
    80005406:	e2042d83          	lw	s11,-480(s0)
    8000540a:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000540e:	f60c0ce3          	beqz	s8,80005386 <exec+0x30e>
    80005412:	8a62                	mv	s4,s8
    80005414:	4901                	li	s2,0
    80005416:	b369                	j	800051a0 <exec+0x128>

0000000080005418 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005418:	7179                	addi	sp,sp,-48
    8000541a:	f406                	sd	ra,40(sp)
    8000541c:	f022                	sd	s0,32(sp)
    8000541e:	ec26                	sd	s1,24(sp)
    80005420:	e84a                	sd	s2,16(sp)
    80005422:	1800                	addi	s0,sp,48
    80005424:	892e                	mv	s2,a1
    80005426:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005428:	fdc40593          	addi	a1,s0,-36
    8000542c:	ffffe097          	auipc	ra,0xffffe
    80005430:	a5e080e7          	jalr	-1442(ra) # 80002e8a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005434:	fdc42703          	lw	a4,-36(s0)
    80005438:	47bd                	li	a5,15
    8000543a:	02e7eb63          	bltu	a5,a4,80005470 <argfd+0x58>
    8000543e:	ffffc097          	auipc	ra,0xffffc
    80005442:	588080e7          	jalr	1416(ra) # 800019c6 <myproc>
    80005446:	fdc42703          	lw	a4,-36(s0)
    8000544a:	01a70793          	addi	a5,a4,26
    8000544e:	078e                	slli	a5,a5,0x3
    80005450:	953e                	add	a0,a0,a5
    80005452:	611c                	ld	a5,0(a0)
    80005454:	c385                	beqz	a5,80005474 <argfd+0x5c>
    return -1;
  if(pfd)
    80005456:	00090463          	beqz	s2,8000545e <argfd+0x46>
    *pfd = fd;
    8000545a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000545e:	4501                	li	a0,0
  if(pf)
    80005460:	c091                	beqz	s1,80005464 <argfd+0x4c>
    *pf = f;
    80005462:	e09c                	sd	a5,0(s1)
}
    80005464:	70a2                	ld	ra,40(sp)
    80005466:	7402                	ld	s0,32(sp)
    80005468:	64e2                	ld	s1,24(sp)
    8000546a:	6942                	ld	s2,16(sp)
    8000546c:	6145                	addi	sp,sp,48
    8000546e:	8082                	ret
    return -1;
    80005470:	557d                	li	a0,-1
    80005472:	bfcd                	j	80005464 <argfd+0x4c>
    80005474:	557d                	li	a0,-1
    80005476:	b7fd                	j	80005464 <argfd+0x4c>

0000000080005478 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005478:	1101                	addi	sp,sp,-32
    8000547a:	ec06                	sd	ra,24(sp)
    8000547c:	e822                	sd	s0,16(sp)
    8000547e:	e426                	sd	s1,8(sp)
    80005480:	1000                	addi	s0,sp,32
    80005482:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005484:	ffffc097          	auipc	ra,0xffffc
    80005488:	542080e7          	jalr	1346(ra) # 800019c6 <myproc>
    8000548c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000548e:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdcb10>
    80005492:	4501                	li	a0,0
    80005494:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005496:	6398                	ld	a4,0(a5)
    80005498:	cb19                	beqz	a4,800054ae <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000549a:	2505                	addiw	a0,a0,1
    8000549c:	07a1                	addi	a5,a5,8
    8000549e:	fed51ce3          	bne	a0,a3,80005496 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800054a2:	557d                	li	a0,-1
}
    800054a4:	60e2                	ld	ra,24(sp)
    800054a6:	6442                	ld	s0,16(sp)
    800054a8:	64a2                	ld	s1,8(sp)
    800054aa:	6105                	addi	sp,sp,32
    800054ac:	8082                	ret
      p->ofile[fd] = f;
    800054ae:	01a50793          	addi	a5,a0,26
    800054b2:	078e                	slli	a5,a5,0x3
    800054b4:	963e                	add	a2,a2,a5
    800054b6:	e204                	sd	s1,0(a2)
      return fd;
    800054b8:	b7f5                	j	800054a4 <fdalloc+0x2c>

00000000800054ba <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800054ba:	715d                	addi	sp,sp,-80
    800054bc:	e486                	sd	ra,72(sp)
    800054be:	e0a2                	sd	s0,64(sp)
    800054c0:	fc26                	sd	s1,56(sp)
    800054c2:	f84a                	sd	s2,48(sp)
    800054c4:	f44e                	sd	s3,40(sp)
    800054c6:	f052                	sd	s4,32(sp)
    800054c8:	ec56                	sd	s5,24(sp)
    800054ca:	e85a                	sd	s6,16(sp)
    800054cc:	0880                	addi	s0,sp,80
    800054ce:	8b2e                	mv	s6,a1
    800054d0:	89b2                	mv	s3,a2
    800054d2:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800054d4:	fb040593          	addi	a1,s0,-80
    800054d8:	fffff097          	auipc	ra,0xfffff
    800054dc:	e4e080e7          	jalr	-434(ra) # 80004326 <nameiparent>
    800054e0:	84aa                	mv	s1,a0
    800054e2:	16050063          	beqz	a0,80005642 <create+0x188>
    return 0;

  ilock(dp);
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	67c080e7          	jalr	1660(ra) # 80003b62 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800054ee:	4601                	li	a2,0
    800054f0:	fb040593          	addi	a1,s0,-80
    800054f4:	8526                	mv	a0,s1
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	b50080e7          	jalr	-1200(ra) # 80004046 <dirlookup>
    800054fe:	8aaa                	mv	s5,a0
    80005500:	c931                	beqz	a0,80005554 <create+0x9a>
    iunlockput(dp);
    80005502:	8526                	mv	a0,s1
    80005504:	fffff097          	auipc	ra,0xfffff
    80005508:	8c0080e7          	jalr	-1856(ra) # 80003dc4 <iunlockput>
    ilock(ip);
    8000550c:	8556                	mv	a0,s5
    8000550e:	ffffe097          	auipc	ra,0xffffe
    80005512:	654080e7          	jalr	1620(ra) # 80003b62 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005516:	000b059b          	sext.w	a1,s6
    8000551a:	4789                	li	a5,2
    8000551c:	02f59563          	bne	a1,a5,80005546 <create+0x8c>
    80005520:	044ad783          	lhu	a5,68(s5)
    80005524:	37f9                	addiw	a5,a5,-2
    80005526:	17c2                	slli	a5,a5,0x30
    80005528:	93c1                	srli	a5,a5,0x30
    8000552a:	4705                	li	a4,1
    8000552c:	00f76d63          	bltu	a4,a5,80005546 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005530:	8556                	mv	a0,s5
    80005532:	60a6                	ld	ra,72(sp)
    80005534:	6406                	ld	s0,64(sp)
    80005536:	74e2                	ld	s1,56(sp)
    80005538:	7942                	ld	s2,48(sp)
    8000553a:	79a2                	ld	s3,40(sp)
    8000553c:	7a02                	ld	s4,32(sp)
    8000553e:	6ae2                	ld	s5,24(sp)
    80005540:	6b42                	ld	s6,16(sp)
    80005542:	6161                	addi	sp,sp,80
    80005544:	8082                	ret
    iunlockput(ip);
    80005546:	8556                	mv	a0,s5
    80005548:	fffff097          	auipc	ra,0xfffff
    8000554c:	87c080e7          	jalr	-1924(ra) # 80003dc4 <iunlockput>
    return 0;
    80005550:	4a81                	li	s5,0
    80005552:	bff9                	j	80005530 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005554:	85da                	mv	a1,s6
    80005556:	4088                	lw	a0,0(s1)
    80005558:	ffffe097          	auipc	ra,0xffffe
    8000555c:	46e080e7          	jalr	1134(ra) # 800039c6 <ialloc>
    80005560:	8a2a                	mv	s4,a0
    80005562:	c921                	beqz	a0,800055b2 <create+0xf8>
  ilock(ip);
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	5fe080e7          	jalr	1534(ra) # 80003b62 <ilock>
  ip->major = major;
    8000556c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005570:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005574:	4785                	li	a5,1
    80005576:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    8000557a:	8552                	mv	a0,s4
    8000557c:	ffffe097          	auipc	ra,0xffffe
    80005580:	51c080e7          	jalr	1308(ra) # 80003a98 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005584:	000b059b          	sext.w	a1,s6
    80005588:	4785                	li	a5,1
    8000558a:	02f58b63          	beq	a1,a5,800055c0 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    8000558e:	004a2603          	lw	a2,4(s4)
    80005592:	fb040593          	addi	a1,s0,-80
    80005596:	8526                	mv	a0,s1
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	cbe080e7          	jalr	-834(ra) # 80004256 <dirlink>
    800055a0:	06054f63          	bltz	a0,8000561e <create+0x164>
  iunlockput(dp);
    800055a4:	8526                	mv	a0,s1
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	81e080e7          	jalr	-2018(ra) # 80003dc4 <iunlockput>
  return ip;
    800055ae:	8ad2                	mv	s5,s4
    800055b0:	b741                	j	80005530 <create+0x76>
    iunlockput(dp);
    800055b2:	8526                	mv	a0,s1
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	810080e7          	jalr	-2032(ra) # 80003dc4 <iunlockput>
    return 0;
    800055bc:	8ad2                	mv	s5,s4
    800055be:	bf8d                	j	80005530 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800055c0:	004a2603          	lw	a2,4(s4)
    800055c4:	00003597          	auipc	a1,0x3
    800055c8:	1ac58593          	addi	a1,a1,428 # 80008770 <syscalls+0x2d0>
    800055cc:	8552                	mv	a0,s4
    800055ce:	fffff097          	auipc	ra,0xfffff
    800055d2:	c88080e7          	jalr	-888(ra) # 80004256 <dirlink>
    800055d6:	04054463          	bltz	a0,8000561e <create+0x164>
    800055da:	40d0                	lw	a2,4(s1)
    800055dc:	00003597          	auipc	a1,0x3
    800055e0:	19c58593          	addi	a1,a1,412 # 80008778 <syscalls+0x2d8>
    800055e4:	8552                	mv	a0,s4
    800055e6:	fffff097          	auipc	ra,0xfffff
    800055ea:	c70080e7          	jalr	-912(ra) # 80004256 <dirlink>
    800055ee:	02054863          	bltz	a0,8000561e <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800055f2:	004a2603          	lw	a2,4(s4)
    800055f6:	fb040593          	addi	a1,s0,-80
    800055fa:	8526                	mv	a0,s1
    800055fc:	fffff097          	auipc	ra,0xfffff
    80005600:	c5a080e7          	jalr	-934(ra) # 80004256 <dirlink>
    80005604:	00054d63          	bltz	a0,8000561e <create+0x164>
    dp->nlink++;  // for ".."
    80005608:	04a4d783          	lhu	a5,74(s1)
    8000560c:	2785                	addiw	a5,a5,1
    8000560e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005612:	8526                	mv	a0,s1
    80005614:	ffffe097          	auipc	ra,0xffffe
    80005618:	484080e7          	jalr	1156(ra) # 80003a98 <iupdate>
    8000561c:	b761                	j	800055a4 <create+0xea>
  ip->nlink = 0;
    8000561e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005622:	8552                	mv	a0,s4
    80005624:	ffffe097          	auipc	ra,0xffffe
    80005628:	474080e7          	jalr	1140(ra) # 80003a98 <iupdate>
  iunlockput(ip);
    8000562c:	8552                	mv	a0,s4
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	796080e7          	jalr	1942(ra) # 80003dc4 <iunlockput>
  iunlockput(dp);
    80005636:	8526                	mv	a0,s1
    80005638:	ffffe097          	auipc	ra,0xffffe
    8000563c:	78c080e7          	jalr	1932(ra) # 80003dc4 <iunlockput>
  return 0;
    80005640:	bdc5                	j	80005530 <create+0x76>
    return 0;
    80005642:	8aaa                	mv	s5,a0
    80005644:	b5f5                	j	80005530 <create+0x76>

0000000080005646 <sys_dup>:
{
    80005646:	7179                	addi	sp,sp,-48
    80005648:	f406                	sd	ra,40(sp)
    8000564a:	f022                	sd	s0,32(sp)
    8000564c:	ec26                	sd	s1,24(sp)
    8000564e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005650:	fd840613          	addi	a2,s0,-40
    80005654:	4581                	li	a1,0
    80005656:	4501                	li	a0,0
    80005658:	00000097          	auipc	ra,0x0
    8000565c:	dc0080e7          	jalr	-576(ra) # 80005418 <argfd>
    return -1;
    80005660:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005662:	02054363          	bltz	a0,80005688 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005666:	fd843503          	ld	a0,-40(s0)
    8000566a:	00000097          	auipc	ra,0x0
    8000566e:	e0e080e7          	jalr	-498(ra) # 80005478 <fdalloc>
    80005672:	84aa                	mv	s1,a0
    return -1;
    80005674:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005676:	00054963          	bltz	a0,80005688 <sys_dup+0x42>
  filedup(f);
    8000567a:	fd843503          	ld	a0,-40(s0)
    8000567e:	fffff097          	auipc	ra,0xfffff
    80005682:	320080e7          	jalr	800(ra) # 8000499e <filedup>
  return fd;
    80005686:	87a6                	mv	a5,s1
}
    80005688:	853e                	mv	a0,a5
    8000568a:	70a2                	ld	ra,40(sp)
    8000568c:	7402                	ld	s0,32(sp)
    8000568e:	64e2                	ld	s1,24(sp)
    80005690:	6145                	addi	sp,sp,48
    80005692:	8082                	ret

0000000080005694 <sys_read>:
{
    80005694:	7179                	addi	sp,sp,-48
    80005696:	f406                	sd	ra,40(sp)
    80005698:	f022                	sd	s0,32(sp)
    8000569a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000569c:	fd840593          	addi	a1,s0,-40
    800056a0:	4505                	li	a0,1
    800056a2:	ffffe097          	auipc	ra,0xffffe
    800056a6:	80a080e7          	jalr	-2038(ra) # 80002eac <argaddr>
  argint(2, &n);
    800056aa:	fe440593          	addi	a1,s0,-28
    800056ae:	4509                	li	a0,2
    800056b0:	ffffd097          	auipc	ra,0xffffd
    800056b4:	7da080e7          	jalr	2010(ra) # 80002e8a <argint>
  if(argfd(0, 0, &f) < 0)
    800056b8:	fe840613          	addi	a2,s0,-24
    800056bc:	4581                	li	a1,0
    800056be:	4501                	li	a0,0
    800056c0:	00000097          	auipc	ra,0x0
    800056c4:	d58080e7          	jalr	-680(ra) # 80005418 <argfd>
    800056c8:	87aa                	mv	a5,a0
    return -1;
    800056ca:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056cc:	0007cc63          	bltz	a5,800056e4 <sys_read+0x50>
  return fileread(f, p, n);
    800056d0:	fe442603          	lw	a2,-28(s0)
    800056d4:	fd843583          	ld	a1,-40(s0)
    800056d8:	fe843503          	ld	a0,-24(s0)
    800056dc:	fffff097          	auipc	ra,0xfffff
    800056e0:	44e080e7          	jalr	1102(ra) # 80004b2a <fileread>
}
    800056e4:	70a2                	ld	ra,40(sp)
    800056e6:	7402                	ld	s0,32(sp)
    800056e8:	6145                	addi	sp,sp,48
    800056ea:	8082                	ret

00000000800056ec <sys_write>:
{
    800056ec:	7179                	addi	sp,sp,-48
    800056ee:	f406                	sd	ra,40(sp)
    800056f0:	f022                	sd	s0,32(sp)
    800056f2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056f4:	fd840593          	addi	a1,s0,-40
    800056f8:	4505                	li	a0,1
    800056fa:	ffffd097          	auipc	ra,0xffffd
    800056fe:	7b2080e7          	jalr	1970(ra) # 80002eac <argaddr>
  argint(2, &n);
    80005702:	fe440593          	addi	a1,s0,-28
    80005706:	4509                	li	a0,2
    80005708:	ffffd097          	auipc	ra,0xffffd
    8000570c:	782080e7          	jalr	1922(ra) # 80002e8a <argint>
  if(argfd(0, 0, &f) < 0)
    80005710:	fe840613          	addi	a2,s0,-24
    80005714:	4581                	li	a1,0
    80005716:	4501                	li	a0,0
    80005718:	00000097          	auipc	ra,0x0
    8000571c:	d00080e7          	jalr	-768(ra) # 80005418 <argfd>
    80005720:	87aa                	mv	a5,a0
    return -1;
    80005722:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005724:	0007cc63          	bltz	a5,8000573c <sys_write+0x50>
  return filewrite(f, p, n);
    80005728:	fe442603          	lw	a2,-28(s0)
    8000572c:	fd843583          	ld	a1,-40(s0)
    80005730:	fe843503          	ld	a0,-24(s0)
    80005734:	fffff097          	auipc	ra,0xfffff
    80005738:	4b8080e7          	jalr	1208(ra) # 80004bec <filewrite>
}
    8000573c:	70a2                	ld	ra,40(sp)
    8000573e:	7402                	ld	s0,32(sp)
    80005740:	6145                	addi	sp,sp,48
    80005742:	8082                	ret

0000000080005744 <sys_close>:
{
    80005744:	1101                	addi	sp,sp,-32
    80005746:	ec06                	sd	ra,24(sp)
    80005748:	e822                	sd	s0,16(sp)
    8000574a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000574c:	fe040613          	addi	a2,s0,-32
    80005750:	fec40593          	addi	a1,s0,-20
    80005754:	4501                	li	a0,0
    80005756:	00000097          	auipc	ra,0x0
    8000575a:	cc2080e7          	jalr	-830(ra) # 80005418 <argfd>
    return -1;
    8000575e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005760:	02054463          	bltz	a0,80005788 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005764:	ffffc097          	auipc	ra,0xffffc
    80005768:	262080e7          	jalr	610(ra) # 800019c6 <myproc>
    8000576c:	fec42783          	lw	a5,-20(s0)
    80005770:	07e9                	addi	a5,a5,26
    80005772:	078e                	slli	a5,a5,0x3
    80005774:	97aa                	add	a5,a5,a0
    80005776:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000577a:	fe043503          	ld	a0,-32(s0)
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	272080e7          	jalr	626(ra) # 800049f0 <fileclose>
  return 0;
    80005786:	4781                	li	a5,0
}
    80005788:	853e                	mv	a0,a5
    8000578a:	60e2                	ld	ra,24(sp)
    8000578c:	6442                	ld	s0,16(sp)
    8000578e:	6105                	addi	sp,sp,32
    80005790:	8082                	ret

0000000080005792 <sys_fstat>:
{
    80005792:	1101                	addi	sp,sp,-32
    80005794:	ec06                	sd	ra,24(sp)
    80005796:	e822                	sd	s0,16(sp)
    80005798:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000579a:	fe040593          	addi	a1,s0,-32
    8000579e:	4505                	li	a0,1
    800057a0:	ffffd097          	auipc	ra,0xffffd
    800057a4:	70c080e7          	jalr	1804(ra) # 80002eac <argaddr>
  if(argfd(0, 0, &f) < 0)
    800057a8:	fe840613          	addi	a2,s0,-24
    800057ac:	4581                	li	a1,0
    800057ae:	4501                	li	a0,0
    800057b0:	00000097          	auipc	ra,0x0
    800057b4:	c68080e7          	jalr	-920(ra) # 80005418 <argfd>
    800057b8:	87aa                	mv	a5,a0
    return -1;
    800057ba:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057bc:	0007ca63          	bltz	a5,800057d0 <sys_fstat+0x3e>
  return filestat(f, st);
    800057c0:	fe043583          	ld	a1,-32(s0)
    800057c4:	fe843503          	ld	a0,-24(s0)
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	2f0080e7          	jalr	752(ra) # 80004ab8 <filestat>
}
    800057d0:	60e2                	ld	ra,24(sp)
    800057d2:	6442                	ld	s0,16(sp)
    800057d4:	6105                	addi	sp,sp,32
    800057d6:	8082                	ret

00000000800057d8 <sys_link>:
{
    800057d8:	7169                	addi	sp,sp,-304
    800057da:	f606                	sd	ra,296(sp)
    800057dc:	f222                	sd	s0,288(sp)
    800057de:	ee26                	sd	s1,280(sp)
    800057e0:	ea4a                	sd	s2,272(sp)
    800057e2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057e4:	08000613          	li	a2,128
    800057e8:	ed040593          	addi	a1,s0,-304
    800057ec:	4501                	li	a0,0
    800057ee:	ffffd097          	auipc	ra,0xffffd
    800057f2:	6e0080e7          	jalr	1760(ra) # 80002ece <argstr>
    return -1;
    800057f6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057f8:	10054e63          	bltz	a0,80005914 <sys_link+0x13c>
    800057fc:	08000613          	li	a2,128
    80005800:	f5040593          	addi	a1,s0,-176
    80005804:	4505                	li	a0,1
    80005806:	ffffd097          	auipc	ra,0xffffd
    8000580a:	6c8080e7          	jalr	1736(ra) # 80002ece <argstr>
    return -1;
    8000580e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005810:	10054263          	bltz	a0,80005914 <sys_link+0x13c>
  begin_op();
    80005814:	fffff097          	auipc	ra,0xfffff
    80005818:	d10080e7          	jalr	-752(ra) # 80004524 <begin_op>
  if((ip = namei(old)) == 0){
    8000581c:	ed040513          	addi	a0,s0,-304
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	ae8080e7          	jalr	-1304(ra) # 80004308 <namei>
    80005828:	84aa                	mv	s1,a0
    8000582a:	c551                	beqz	a0,800058b6 <sys_link+0xde>
  ilock(ip);
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	336080e7          	jalr	822(ra) # 80003b62 <ilock>
  if(ip->type == T_DIR){
    80005834:	04449703          	lh	a4,68(s1)
    80005838:	4785                	li	a5,1
    8000583a:	08f70463          	beq	a4,a5,800058c2 <sys_link+0xea>
  ip->nlink++;
    8000583e:	04a4d783          	lhu	a5,74(s1)
    80005842:	2785                	addiw	a5,a5,1
    80005844:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005848:	8526                	mv	a0,s1
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	24e080e7          	jalr	590(ra) # 80003a98 <iupdate>
  iunlock(ip);
    80005852:	8526                	mv	a0,s1
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	3d0080e7          	jalr	976(ra) # 80003c24 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000585c:	fd040593          	addi	a1,s0,-48
    80005860:	f5040513          	addi	a0,s0,-176
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	ac2080e7          	jalr	-1342(ra) # 80004326 <nameiparent>
    8000586c:	892a                	mv	s2,a0
    8000586e:	c935                	beqz	a0,800058e2 <sys_link+0x10a>
  ilock(dp);
    80005870:	ffffe097          	auipc	ra,0xffffe
    80005874:	2f2080e7          	jalr	754(ra) # 80003b62 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005878:	00092703          	lw	a4,0(s2)
    8000587c:	409c                	lw	a5,0(s1)
    8000587e:	04f71d63          	bne	a4,a5,800058d8 <sys_link+0x100>
    80005882:	40d0                	lw	a2,4(s1)
    80005884:	fd040593          	addi	a1,s0,-48
    80005888:	854a                	mv	a0,s2
    8000588a:	fffff097          	auipc	ra,0xfffff
    8000588e:	9cc080e7          	jalr	-1588(ra) # 80004256 <dirlink>
    80005892:	04054363          	bltz	a0,800058d8 <sys_link+0x100>
  iunlockput(dp);
    80005896:	854a                	mv	a0,s2
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	52c080e7          	jalr	1324(ra) # 80003dc4 <iunlockput>
  iput(ip);
    800058a0:	8526                	mv	a0,s1
    800058a2:	ffffe097          	auipc	ra,0xffffe
    800058a6:	47a080e7          	jalr	1146(ra) # 80003d1c <iput>
  end_op();
    800058aa:	fffff097          	auipc	ra,0xfffff
    800058ae:	cfa080e7          	jalr	-774(ra) # 800045a4 <end_op>
  return 0;
    800058b2:	4781                	li	a5,0
    800058b4:	a085                	j	80005914 <sys_link+0x13c>
    end_op();
    800058b6:	fffff097          	auipc	ra,0xfffff
    800058ba:	cee080e7          	jalr	-786(ra) # 800045a4 <end_op>
    return -1;
    800058be:	57fd                	li	a5,-1
    800058c0:	a891                	j	80005914 <sys_link+0x13c>
    iunlockput(ip);
    800058c2:	8526                	mv	a0,s1
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	500080e7          	jalr	1280(ra) # 80003dc4 <iunlockput>
    end_op();
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	cd8080e7          	jalr	-808(ra) # 800045a4 <end_op>
    return -1;
    800058d4:	57fd                	li	a5,-1
    800058d6:	a83d                	j	80005914 <sys_link+0x13c>
    iunlockput(dp);
    800058d8:	854a                	mv	a0,s2
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	4ea080e7          	jalr	1258(ra) # 80003dc4 <iunlockput>
  ilock(ip);
    800058e2:	8526                	mv	a0,s1
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	27e080e7          	jalr	638(ra) # 80003b62 <ilock>
  ip->nlink--;
    800058ec:	04a4d783          	lhu	a5,74(s1)
    800058f0:	37fd                	addiw	a5,a5,-1
    800058f2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058f6:	8526                	mv	a0,s1
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	1a0080e7          	jalr	416(ra) # 80003a98 <iupdate>
  iunlockput(ip);
    80005900:	8526                	mv	a0,s1
    80005902:	ffffe097          	auipc	ra,0xffffe
    80005906:	4c2080e7          	jalr	1218(ra) # 80003dc4 <iunlockput>
  end_op();
    8000590a:	fffff097          	auipc	ra,0xfffff
    8000590e:	c9a080e7          	jalr	-870(ra) # 800045a4 <end_op>
  return -1;
    80005912:	57fd                	li	a5,-1
}
    80005914:	853e                	mv	a0,a5
    80005916:	70b2                	ld	ra,296(sp)
    80005918:	7412                	ld	s0,288(sp)
    8000591a:	64f2                	ld	s1,280(sp)
    8000591c:	6952                	ld	s2,272(sp)
    8000591e:	6155                	addi	sp,sp,304
    80005920:	8082                	ret

0000000080005922 <sys_unlink>:
{
    80005922:	7151                	addi	sp,sp,-240
    80005924:	f586                	sd	ra,232(sp)
    80005926:	f1a2                	sd	s0,224(sp)
    80005928:	eda6                	sd	s1,216(sp)
    8000592a:	e9ca                	sd	s2,208(sp)
    8000592c:	e5ce                	sd	s3,200(sp)
    8000592e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005930:	08000613          	li	a2,128
    80005934:	f3040593          	addi	a1,s0,-208
    80005938:	4501                	li	a0,0
    8000593a:	ffffd097          	auipc	ra,0xffffd
    8000593e:	594080e7          	jalr	1428(ra) # 80002ece <argstr>
    80005942:	18054163          	bltz	a0,80005ac4 <sys_unlink+0x1a2>
  begin_op();
    80005946:	fffff097          	auipc	ra,0xfffff
    8000594a:	bde080e7          	jalr	-1058(ra) # 80004524 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000594e:	fb040593          	addi	a1,s0,-80
    80005952:	f3040513          	addi	a0,s0,-208
    80005956:	fffff097          	auipc	ra,0xfffff
    8000595a:	9d0080e7          	jalr	-1584(ra) # 80004326 <nameiparent>
    8000595e:	84aa                	mv	s1,a0
    80005960:	c979                	beqz	a0,80005a36 <sys_unlink+0x114>
  ilock(dp);
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	200080e7          	jalr	512(ra) # 80003b62 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000596a:	00003597          	auipc	a1,0x3
    8000596e:	e0658593          	addi	a1,a1,-506 # 80008770 <syscalls+0x2d0>
    80005972:	fb040513          	addi	a0,s0,-80
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	6b6080e7          	jalr	1718(ra) # 8000402c <namecmp>
    8000597e:	14050a63          	beqz	a0,80005ad2 <sys_unlink+0x1b0>
    80005982:	00003597          	auipc	a1,0x3
    80005986:	df658593          	addi	a1,a1,-522 # 80008778 <syscalls+0x2d8>
    8000598a:	fb040513          	addi	a0,s0,-80
    8000598e:	ffffe097          	auipc	ra,0xffffe
    80005992:	69e080e7          	jalr	1694(ra) # 8000402c <namecmp>
    80005996:	12050e63          	beqz	a0,80005ad2 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000599a:	f2c40613          	addi	a2,s0,-212
    8000599e:	fb040593          	addi	a1,s0,-80
    800059a2:	8526                	mv	a0,s1
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	6a2080e7          	jalr	1698(ra) # 80004046 <dirlookup>
    800059ac:	892a                	mv	s2,a0
    800059ae:	12050263          	beqz	a0,80005ad2 <sys_unlink+0x1b0>
  ilock(ip);
    800059b2:	ffffe097          	auipc	ra,0xffffe
    800059b6:	1b0080e7          	jalr	432(ra) # 80003b62 <ilock>
  if(ip->nlink < 1)
    800059ba:	04a91783          	lh	a5,74(s2)
    800059be:	08f05263          	blez	a5,80005a42 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800059c2:	04491703          	lh	a4,68(s2)
    800059c6:	4785                	li	a5,1
    800059c8:	08f70563          	beq	a4,a5,80005a52 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800059cc:	4641                	li	a2,16
    800059ce:	4581                	li	a1,0
    800059d0:	fc040513          	addi	a0,s0,-64
    800059d4:	ffffb097          	auipc	ra,0xffffb
    800059d8:	312080e7          	jalr	786(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059dc:	4741                	li	a4,16
    800059de:	f2c42683          	lw	a3,-212(s0)
    800059e2:	fc040613          	addi	a2,s0,-64
    800059e6:	4581                	li	a1,0
    800059e8:	8526                	mv	a0,s1
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	524080e7          	jalr	1316(ra) # 80003f0e <writei>
    800059f2:	47c1                	li	a5,16
    800059f4:	0af51563          	bne	a0,a5,80005a9e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800059f8:	04491703          	lh	a4,68(s2)
    800059fc:	4785                	li	a5,1
    800059fe:	0af70863          	beq	a4,a5,80005aae <sys_unlink+0x18c>
  iunlockput(dp);
    80005a02:	8526                	mv	a0,s1
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	3c0080e7          	jalr	960(ra) # 80003dc4 <iunlockput>
  ip->nlink--;
    80005a0c:	04a95783          	lhu	a5,74(s2)
    80005a10:	37fd                	addiw	a5,a5,-1
    80005a12:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a16:	854a                	mv	a0,s2
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	080080e7          	jalr	128(ra) # 80003a98 <iupdate>
  iunlockput(ip);
    80005a20:	854a                	mv	a0,s2
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	3a2080e7          	jalr	930(ra) # 80003dc4 <iunlockput>
  end_op();
    80005a2a:	fffff097          	auipc	ra,0xfffff
    80005a2e:	b7a080e7          	jalr	-1158(ra) # 800045a4 <end_op>
  return 0;
    80005a32:	4501                	li	a0,0
    80005a34:	a84d                	j	80005ae6 <sys_unlink+0x1c4>
    end_op();
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	b6e080e7          	jalr	-1170(ra) # 800045a4 <end_op>
    return -1;
    80005a3e:	557d                	li	a0,-1
    80005a40:	a05d                	j	80005ae6 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a42:	00003517          	auipc	a0,0x3
    80005a46:	d3e50513          	addi	a0,a0,-706 # 80008780 <syscalls+0x2e0>
    80005a4a:	ffffb097          	auipc	ra,0xffffb
    80005a4e:	afa080e7          	jalr	-1286(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a52:	04c92703          	lw	a4,76(s2)
    80005a56:	02000793          	li	a5,32
    80005a5a:	f6e7f9e3          	bgeu	a5,a4,800059cc <sys_unlink+0xaa>
    80005a5e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a62:	4741                	li	a4,16
    80005a64:	86ce                	mv	a3,s3
    80005a66:	f1840613          	addi	a2,s0,-232
    80005a6a:	4581                	li	a1,0
    80005a6c:	854a                	mv	a0,s2
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	3a8080e7          	jalr	936(ra) # 80003e16 <readi>
    80005a76:	47c1                	li	a5,16
    80005a78:	00f51b63          	bne	a0,a5,80005a8e <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a7c:	f1845783          	lhu	a5,-232(s0)
    80005a80:	e7a1                	bnez	a5,80005ac8 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a82:	29c1                	addiw	s3,s3,16
    80005a84:	04c92783          	lw	a5,76(s2)
    80005a88:	fcf9ede3          	bltu	s3,a5,80005a62 <sys_unlink+0x140>
    80005a8c:	b781                	j	800059cc <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a8e:	00003517          	auipc	a0,0x3
    80005a92:	d0a50513          	addi	a0,a0,-758 # 80008798 <syscalls+0x2f8>
    80005a96:	ffffb097          	auipc	ra,0xffffb
    80005a9a:	aae080e7          	jalr	-1362(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005a9e:	00003517          	auipc	a0,0x3
    80005aa2:	d1250513          	addi	a0,a0,-750 # 800087b0 <syscalls+0x310>
    80005aa6:	ffffb097          	auipc	ra,0xffffb
    80005aaa:	a9e080e7          	jalr	-1378(ra) # 80000544 <panic>
    dp->nlink--;
    80005aae:	04a4d783          	lhu	a5,74(s1)
    80005ab2:	37fd                	addiw	a5,a5,-1
    80005ab4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ab8:	8526                	mv	a0,s1
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	fde080e7          	jalr	-34(ra) # 80003a98 <iupdate>
    80005ac2:	b781                	j	80005a02 <sys_unlink+0xe0>
    return -1;
    80005ac4:	557d                	li	a0,-1
    80005ac6:	a005                	j	80005ae6 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005ac8:	854a                	mv	a0,s2
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	2fa080e7          	jalr	762(ra) # 80003dc4 <iunlockput>
  iunlockput(dp);
    80005ad2:	8526                	mv	a0,s1
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	2f0080e7          	jalr	752(ra) # 80003dc4 <iunlockput>
  end_op();
    80005adc:	fffff097          	auipc	ra,0xfffff
    80005ae0:	ac8080e7          	jalr	-1336(ra) # 800045a4 <end_op>
  return -1;
    80005ae4:	557d                	li	a0,-1
}
    80005ae6:	70ae                	ld	ra,232(sp)
    80005ae8:	740e                	ld	s0,224(sp)
    80005aea:	64ee                	ld	s1,216(sp)
    80005aec:	694e                	ld	s2,208(sp)
    80005aee:	69ae                	ld	s3,200(sp)
    80005af0:	616d                	addi	sp,sp,240
    80005af2:	8082                	ret

0000000080005af4 <sys_open>:

uint64
sys_open(void)
{
    80005af4:	7131                	addi	sp,sp,-192
    80005af6:	fd06                	sd	ra,184(sp)
    80005af8:	f922                	sd	s0,176(sp)
    80005afa:	f526                	sd	s1,168(sp)
    80005afc:	f14a                	sd	s2,160(sp)
    80005afe:	ed4e                	sd	s3,152(sp)
    80005b00:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b02:	f4c40593          	addi	a1,s0,-180
    80005b06:	4505                	li	a0,1
    80005b08:	ffffd097          	auipc	ra,0xffffd
    80005b0c:	382080e7          	jalr	898(ra) # 80002e8a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b10:	08000613          	li	a2,128
    80005b14:	f5040593          	addi	a1,s0,-176
    80005b18:	4501                	li	a0,0
    80005b1a:	ffffd097          	auipc	ra,0xffffd
    80005b1e:	3b4080e7          	jalr	948(ra) # 80002ece <argstr>
    80005b22:	87aa                	mv	a5,a0
    return -1;
    80005b24:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b26:	0a07c963          	bltz	a5,80005bd8 <sys_open+0xe4>

  begin_op();
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	9fa080e7          	jalr	-1542(ra) # 80004524 <begin_op>

  if(omode & O_CREATE){
    80005b32:	f4c42783          	lw	a5,-180(s0)
    80005b36:	2007f793          	andi	a5,a5,512
    80005b3a:	cfc5                	beqz	a5,80005bf2 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005b3c:	4681                	li	a3,0
    80005b3e:	4601                	li	a2,0
    80005b40:	4589                	li	a1,2
    80005b42:	f5040513          	addi	a0,s0,-176
    80005b46:	00000097          	auipc	ra,0x0
    80005b4a:	974080e7          	jalr	-1676(ra) # 800054ba <create>
    80005b4e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b50:	c959                	beqz	a0,80005be6 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b52:	04449703          	lh	a4,68(s1)
    80005b56:	478d                	li	a5,3
    80005b58:	00f71763          	bne	a4,a5,80005b66 <sys_open+0x72>
    80005b5c:	0464d703          	lhu	a4,70(s1)
    80005b60:	47a5                	li	a5,9
    80005b62:	0ce7ed63          	bltu	a5,a4,80005c3c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b66:	fffff097          	auipc	ra,0xfffff
    80005b6a:	dce080e7          	jalr	-562(ra) # 80004934 <filealloc>
    80005b6e:	89aa                	mv	s3,a0
    80005b70:	10050363          	beqz	a0,80005c76 <sys_open+0x182>
    80005b74:	00000097          	auipc	ra,0x0
    80005b78:	904080e7          	jalr	-1788(ra) # 80005478 <fdalloc>
    80005b7c:	892a                	mv	s2,a0
    80005b7e:	0e054763          	bltz	a0,80005c6c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b82:	04449703          	lh	a4,68(s1)
    80005b86:	478d                	li	a5,3
    80005b88:	0cf70563          	beq	a4,a5,80005c52 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b8c:	4789                	li	a5,2
    80005b8e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b92:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b96:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b9a:	f4c42783          	lw	a5,-180(s0)
    80005b9e:	0017c713          	xori	a4,a5,1
    80005ba2:	8b05                	andi	a4,a4,1
    80005ba4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ba8:	0037f713          	andi	a4,a5,3
    80005bac:	00e03733          	snez	a4,a4
    80005bb0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005bb4:	4007f793          	andi	a5,a5,1024
    80005bb8:	c791                	beqz	a5,80005bc4 <sys_open+0xd0>
    80005bba:	04449703          	lh	a4,68(s1)
    80005bbe:	4789                	li	a5,2
    80005bc0:	0af70063          	beq	a4,a5,80005c60 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005bc4:	8526                	mv	a0,s1
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	05e080e7          	jalr	94(ra) # 80003c24 <iunlock>
  end_op();
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	9d6080e7          	jalr	-1578(ra) # 800045a4 <end_op>

  return fd;
    80005bd6:	854a                	mv	a0,s2
}
    80005bd8:	70ea                	ld	ra,184(sp)
    80005bda:	744a                	ld	s0,176(sp)
    80005bdc:	74aa                	ld	s1,168(sp)
    80005bde:	790a                	ld	s2,160(sp)
    80005be0:	69ea                	ld	s3,152(sp)
    80005be2:	6129                	addi	sp,sp,192
    80005be4:	8082                	ret
      end_op();
    80005be6:	fffff097          	auipc	ra,0xfffff
    80005bea:	9be080e7          	jalr	-1602(ra) # 800045a4 <end_op>
      return -1;
    80005bee:	557d                	li	a0,-1
    80005bf0:	b7e5                	j	80005bd8 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005bf2:	f5040513          	addi	a0,s0,-176
    80005bf6:	ffffe097          	auipc	ra,0xffffe
    80005bfa:	712080e7          	jalr	1810(ra) # 80004308 <namei>
    80005bfe:	84aa                	mv	s1,a0
    80005c00:	c905                	beqz	a0,80005c30 <sys_open+0x13c>
    ilock(ip);
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	f60080e7          	jalr	-160(ra) # 80003b62 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c0a:	04449703          	lh	a4,68(s1)
    80005c0e:	4785                	li	a5,1
    80005c10:	f4f711e3          	bne	a4,a5,80005b52 <sys_open+0x5e>
    80005c14:	f4c42783          	lw	a5,-180(s0)
    80005c18:	d7b9                	beqz	a5,80005b66 <sys_open+0x72>
      iunlockput(ip);
    80005c1a:	8526                	mv	a0,s1
    80005c1c:	ffffe097          	auipc	ra,0xffffe
    80005c20:	1a8080e7          	jalr	424(ra) # 80003dc4 <iunlockput>
      end_op();
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	980080e7          	jalr	-1664(ra) # 800045a4 <end_op>
      return -1;
    80005c2c:	557d                	li	a0,-1
    80005c2e:	b76d                	j	80005bd8 <sys_open+0xe4>
      end_op();
    80005c30:	fffff097          	auipc	ra,0xfffff
    80005c34:	974080e7          	jalr	-1676(ra) # 800045a4 <end_op>
      return -1;
    80005c38:	557d                	li	a0,-1
    80005c3a:	bf79                	j	80005bd8 <sys_open+0xe4>
    iunlockput(ip);
    80005c3c:	8526                	mv	a0,s1
    80005c3e:	ffffe097          	auipc	ra,0xffffe
    80005c42:	186080e7          	jalr	390(ra) # 80003dc4 <iunlockput>
    end_op();
    80005c46:	fffff097          	auipc	ra,0xfffff
    80005c4a:	95e080e7          	jalr	-1698(ra) # 800045a4 <end_op>
    return -1;
    80005c4e:	557d                	li	a0,-1
    80005c50:	b761                	j	80005bd8 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c52:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c56:	04649783          	lh	a5,70(s1)
    80005c5a:	02f99223          	sh	a5,36(s3)
    80005c5e:	bf25                	j	80005b96 <sys_open+0xa2>
    itrunc(ip);
    80005c60:	8526                	mv	a0,s1
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	00e080e7          	jalr	14(ra) # 80003c70 <itrunc>
    80005c6a:	bfa9                	j	80005bc4 <sys_open+0xd0>
      fileclose(f);
    80005c6c:	854e                	mv	a0,s3
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	d82080e7          	jalr	-638(ra) # 800049f0 <fileclose>
    iunlockput(ip);
    80005c76:	8526                	mv	a0,s1
    80005c78:	ffffe097          	auipc	ra,0xffffe
    80005c7c:	14c080e7          	jalr	332(ra) # 80003dc4 <iunlockput>
    end_op();
    80005c80:	fffff097          	auipc	ra,0xfffff
    80005c84:	924080e7          	jalr	-1756(ra) # 800045a4 <end_op>
    return -1;
    80005c88:	557d                	li	a0,-1
    80005c8a:	b7b9                	j	80005bd8 <sys_open+0xe4>

0000000080005c8c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c8c:	7175                	addi	sp,sp,-144
    80005c8e:	e506                	sd	ra,136(sp)
    80005c90:	e122                	sd	s0,128(sp)
    80005c92:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c94:	fffff097          	auipc	ra,0xfffff
    80005c98:	890080e7          	jalr	-1904(ra) # 80004524 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c9c:	08000613          	li	a2,128
    80005ca0:	f7040593          	addi	a1,s0,-144
    80005ca4:	4501                	li	a0,0
    80005ca6:	ffffd097          	auipc	ra,0xffffd
    80005caa:	228080e7          	jalr	552(ra) # 80002ece <argstr>
    80005cae:	02054963          	bltz	a0,80005ce0 <sys_mkdir+0x54>
    80005cb2:	4681                	li	a3,0
    80005cb4:	4601                	li	a2,0
    80005cb6:	4585                	li	a1,1
    80005cb8:	f7040513          	addi	a0,s0,-144
    80005cbc:	fffff097          	auipc	ra,0xfffff
    80005cc0:	7fe080e7          	jalr	2046(ra) # 800054ba <create>
    80005cc4:	cd11                	beqz	a0,80005ce0 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005cc6:	ffffe097          	auipc	ra,0xffffe
    80005cca:	0fe080e7          	jalr	254(ra) # 80003dc4 <iunlockput>
  end_op();
    80005cce:	fffff097          	auipc	ra,0xfffff
    80005cd2:	8d6080e7          	jalr	-1834(ra) # 800045a4 <end_op>
  return 0;
    80005cd6:	4501                	li	a0,0
}
    80005cd8:	60aa                	ld	ra,136(sp)
    80005cda:	640a                	ld	s0,128(sp)
    80005cdc:	6149                	addi	sp,sp,144
    80005cde:	8082                	ret
    end_op();
    80005ce0:	fffff097          	auipc	ra,0xfffff
    80005ce4:	8c4080e7          	jalr	-1852(ra) # 800045a4 <end_op>
    return -1;
    80005ce8:	557d                	li	a0,-1
    80005cea:	b7fd                	j	80005cd8 <sys_mkdir+0x4c>

0000000080005cec <sys_mknod>:

uint64
sys_mknod(void)
{
    80005cec:	7135                	addi	sp,sp,-160
    80005cee:	ed06                	sd	ra,152(sp)
    80005cf0:	e922                	sd	s0,144(sp)
    80005cf2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005cf4:	fffff097          	auipc	ra,0xfffff
    80005cf8:	830080e7          	jalr	-2000(ra) # 80004524 <begin_op>
  argint(1, &major);
    80005cfc:	f6c40593          	addi	a1,s0,-148
    80005d00:	4505                	li	a0,1
    80005d02:	ffffd097          	auipc	ra,0xffffd
    80005d06:	188080e7          	jalr	392(ra) # 80002e8a <argint>
  argint(2, &minor);
    80005d0a:	f6840593          	addi	a1,s0,-152
    80005d0e:	4509                	li	a0,2
    80005d10:	ffffd097          	auipc	ra,0xffffd
    80005d14:	17a080e7          	jalr	378(ra) # 80002e8a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d18:	08000613          	li	a2,128
    80005d1c:	f7040593          	addi	a1,s0,-144
    80005d20:	4501                	li	a0,0
    80005d22:	ffffd097          	auipc	ra,0xffffd
    80005d26:	1ac080e7          	jalr	428(ra) # 80002ece <argstr>
    80005d2a:	02054b63          	bltz	a0,80005d60 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d2e:	f6841683          	lh	a3,-152(s0)
    80005d32:	f6c41603          	lh	a2,-148(s0)
    80005d36:	458d                	li	a1,3
    80005d38:	f7040513          	addi	a0,s0,-144
    80005d3c:	fffff097          	auipc	ra,0xfffff
    80005d40:	77e080e7          	jalr	1918(ra) # 800054ba <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d44:	cd11                	beqz	a0,80005d60 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	07e080e7          	jalr	126(ra) # 80003dc4 <iunlockput>
  end_op();
    80005d4e:	fffff097          	auipc	ra,0xfffff
    80005d52:	856080e7          	jalr	-1962(ra) # 800045a4 <end_op>
  return 0;
    80005d56:	4501                	li	a0,0
}
    80005d58:	60ea                	ld	ra,152(sp)
    80005d5a:	644a                	ld	s0,144(sp)
    80005d5c:	610d                	addi	sp,sp,160
    80005d5e:	8082                	ret
    end_op();
    80005d60:	fffff097          	auipc	ra,0xfffff
    80005d64:	844080e7          	jalr	-1980(ra) # 800045a4 <end_op>
    return -1;
    80005d68:	557d                	li	a0,-1
    80005d6a:	b7fd                	j	80005d58 <sys_mknod+0x6c>

0000000080005d6c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d6c:	7135                	addi	sp,sp,-160
    80005d6e:	ed06                	sd	ra,152(sp)
    80005d70:	e922                	sd	s0,144(sp)
    80005d72:	e526                	sd	s1,136(sp)
    80005d74:	e14a                	sd	s2,128(sp)
    80005d76:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d78:	ffffc097          	auipc	ra,0xffffc
    80005d7c:	c4e080e7          	jalr	-946(ra) # 800019c6 <myproc>
    80005d80:	892a                	mv	s2,a0
  
  begin_op();
    80005d82:	ffffe097          	auipc	ra,0xffffe
    80005d86:	7a2080e7          	jalr	1954(ra) # 80004524 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d8a:	08000613          	li	a2,128
    80005d8e:	f6040593          	addi	a1,s0,-160
    80005d92:	4501                	li	a0,0
    80005d94:	ffffd097          	auipc	ra,0xffffd
    80005d98:	13a080e7          	jalr	314(ra) # 80002ece <argstr>
    80005d9c:	04054b63          	bltz	a0,80005df2 <sys_chdir+0x86>
    80005da0:	f6040513          	addi	a0,s0,-160
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	564080e7          	jalr	1380(ra) # 80004308 <namei>
    80005dac:	84aa                	mv	s1,a0
    80005dae:	c131                	beqz	a0,80005df2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005db0:	ffffe097          	auipc	ra,0xffffe
    80005db4:	db2080e7          	jalr	-590(ra) # 80003b62 <ilock>
  if(ip->type != T_DIR){
    80005db8:	04449703          	lh	a4,68(s1)
    80005dbc:	4785                	li	a5,1
    80005dbe:	04f71063          	bne	a4,a5,80005dfe <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005dc2:	8526                	mv	a0,s1
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	e60080e7          	jalr	-416(ra) # 80003c24 <iunlock>
  iput(p->cwd);
    80005dcc:	15093503          	ld	a0,336(s2)
    80005dd0:	ffffe097          	auipc	ra,0xffffe
    80005dd4:	f4c080e7          	jalr	-180(ra) # 80003d1c <iput>
  end_op();
    80005dd8:	ffffe097          	auipc	ra,0xffffe
    80005ddc:	7cc080e7          	jalr	1996(ra) # 800045a4 <end_op>
  p->cwd = ip;
    80005de0:	14993823          	sd	s1,336(s2)
  return 0;
    80005de4:	4501                	li	a0,0
}
    80005de6:	60ea                	ld	ra,152(sp)
    80005de8:	644a                	ld	s0,144(sp)
    80005dea:	64aa                	ld	s1,136(sp)
    80005dec:	690a                	ld	s2,128(sp)
    80005dee:	610d                	addi	sp,sp,160
    80005df0:	8082                	ret
    end_op();
    80005df2:	ffffe097          	auipc	ra,0xffffe
    80005df6:	7b2080e7          	jalr	1970(ra) # 800045a4 <end_op>
    return -1;
    80005dfa:	557d                	li	a0,-1
    80005dfc:	b7ed                	j	80005de6 <sys_chdir+0x7a>
    iunlockput(ip);
    80005dfe:	8526                	mv	a0,s1
    80005e00:	ffffe097          	auipc	ra,0xffffe
    80005e04:	fc4080e7          	jalr	-60(ra) # 80003dc4 <iunlockput>
    end_op();
    80005e08:	ffffe097          	auipc	ra,0xffffe
    80005e0c:	79c080e7          	jalr	1948(ra) # 800045a4 <end_op>
    return -1;
    80005e10:	557d                	li	a0,-1
    80005e12:	bfd1                	j	80005de6 <sys_chdir+0x7a>

0000000080005e14 <sys_exec>:

uint64
sys_exec(void)
{
    80005e14:	7145                	addi	sp,sp,-464
    80005e16:	e786                	sd	ra,456(sp)
    80005e18:	e3a2                	sd	s0,448(sp)
    80005e1a:	ff26                	sd	s1,440(sp)
    80005e1c:	fb4a                	sd	s2,432(sp)
    80005e1e:	f74e                	sd	s3,424(sp)
    80005e20:	f352                	sd	s4,416(sp)
    80005e22:	ef56                	sd	s5,408(sp)
    80005e24:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e26:	e3840593          	addi	a1,s0,-456
    80005e2a:	4505                	li	a0,1
    80005e2c:	ffffd097          	auipc	ra,0xffffd
    80005e30:	080080e7          	jalr	128(ra) # 80002eac <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e34:	08000613          	li	a2,128
    80005e38:	f4040593          	addi	a1,s0,-192
    80005e3c:	4501                	li	a0,0
    80005e3e:	ffffd097          	auipc	ra,0xffffd
    80005e42:	090080e7          	jalr	144(ra) # 80002ece <argstr>
    80005e46:	87aa                	mv	a5,a0
    return -1;
    80005e48:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e4a:	0c07c263          	bltz	a5,80005f0e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005e4e:	10000613          	li	a2,256
    80005e52:	4581                	li	a1,0
    80005e54:	e4040513          	addi	a0,s0,-448
    80005e58:	ffffb097          	auipc	ra,0xffffb
    80005e5c:	e8e080e7          	jalr	-370(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e60:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e64:	89a6                	mv	s3,s1
    80005e66:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e68:	02000a13          	li	s4,32
    80005e6c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e70:	00391513          	slli	a0,s2,0x3
    80005e74:	e3040593          	addi	a1,s0,-464
    80005e78:	e3843783          	ld	a5,-456(s0)
    80005e7c:	953e                	add	a0,a0,a5
    80005e7e:	ffffd097          	auipc	ra,0xffffd
    80005e82:	f6e080e7          	jalr	-146(ra) # 80002dec <fetchaddr>
    80005e86:	02054a63          	bltz	a0,80005eba <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005e8a:	e3043783          	ld	a5,-464(s0)
    80005e8e:	c3b9                	beqz	a5,80005ed4 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e90:	ffffb097          	auipc	ra,0xffffb
    80005e94:	c6a080e7          	jalr	-918(ra) # 80000afa <kalloc>
    80005e98:	85aa                	mv	a1,a0
    80005e9a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e9e:	cd11                	beqz	a0,80005eba <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ea0:	6605                	lui	a2,0x1
    80005ea2:	e3043503          	ld	a0,-464(s0)
    80005ea6:	ffffd097          	auipc	ra,0xffffd
    80005eaa:	f98080e7          	jalr	-104(ra) # 80002e3e <fetchstr>
    80005eae:	00054663          	bltz	a0,80005eba <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005eb2:	0905                	addi	s2,s2,1
    80005eb4:	09a1                	addi	s3,s3,8
    80005eb6:	fb491be3          	bne	s2,s4,80005e6c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eba:	10048913          	addi	s2,s1,256
    80005ebe:	6088                	ld	a0,0(s1)
    80005ec0:	c531                	beqz	a0,80005f0c <sys_exec+0xf8>
    kfree(argv[i]);
    80005ec2:	ffffb097          	auipc	ra,0xffffb
    80005ec6:	b3c080e7          	jalr	-1220(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eca:	04a1                	addi	s1,s1,8
    80005ecc:	ff2499e3          	bne	s1,s2,80005ebe <sys_exec+0xaa>
  return -1;
    80005ed0:	557d                	li	a0,-1
    80005ed2:	a835                	j	80005f0e <sys_exec+0xfa>
      argv[i] = 0;
    80005ed4:	0a8e                	slli	s5,s5,0x3
    80005ed6:	fc040793          	addi	a5,s0,-64
    80005eda:	9abe                	add	s5,s5,a5
    80005edc:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ee0:	e4040593          	addi	a1,s0,-448
    80005ee4:	f4040513          	addi	a0,s0,-192
    80005ee8:	fffff097          	auipc	ra,0xfffff
    80005eec:	190080e7          	jalr	400(ra) # 80005078 <exec>
    80005ef0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ef2:	10048993          	addi	s3,s1,256
    80005ef6:	6088                	ld	a0,0(s1)
    80005ef8:	c901                	beqz	a0,80005f08 <sys_exec+0xf4>
    kfree(argv[i]);
    80005efa:	ffffb097          	auipc	ra,0xffffb
    80005efe:	b04080e7          	jalr	-1276(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f02:	04a1                	addi	s1,s1,8
    80005f04:	ff3499e3          	bne	s1,s3,80005ef6 <sys_exec+0xe2>
  return ret;
    80005f08:	854a                	mv	a0,s2
    80005f0a:	a011                	j	80005f0e <sys_exec+0xfa>
  return -1;
    80005f0c:	557d                	li	a0,-1
}
    80005f0e:	60be                	ld	ra,456(sp)
    80005f10:	641e                	ld	s0,448(sp)
    80005f12:	74fa                	ld	s1,440(sp)
    80005f14:	795a                	ld	s2,432(sp)
    80005f16:	79ba                	ld	s3,424(sp)
    80005f18:	7a1a                	ld	s4,416(sp)
    80005f1a:	6afa                	ld	s5,408(sp)
    80005f1c:	6179                	addi	sp,sp,464
    80005f1e:	8082                	ret

0000000080005f20 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f20:	7139                	addi	sp,sp,-64
    80005f22:	fc06                	sd	ra,56(sp)
    80005f24:	f822                	sd	s0,48(sp)
    80005f26:	f426                	sd	s1,40(sp)
    80005f28:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f2a:	ffffc097          	auipc	ra,0xffffc
    80005f2e:	a9c080e7          	jalr	-1380(ra) # 800019c6 <myproc>
    80005f32:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f34:	fd840593          	addi	a1,s0,-40
    80005f38:	4501                	li	a0,0
    80005f3a:	ffffd097          	auipc	ra,0xffffd
    80005f3e:	f72080e7          	jalr	-142(ra) # 80002eac <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f42:	fc840593          	addi	a1,s0,-56
    80005f46:	fd040513          	addi	a0,s0,-48
    80005f4a:	fffff097          	auipc	ra,0xfffff
    80005f4e:	dd6080e7          	jalr	-554(ra) # 80004d20 <pipealloc>
    return -1;
    80005f52:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f54:	0c054463          	bltz	a0,8000601c <sys_pipe+0xfc>
  fd0 = -1;
    80005f58:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f5c:	fd043503          	ld	a0,-48(s0)
    80005f60:	fffff097          	auipc	ra,0xfffff
    80005f64:	518080e7          	jalr	1304(ra) # 80005478 <fdalloc>
    80005f68:	fca42223          	sw	a0,-60(s0)
    80005f6c:	08054b63          	bltz	a0,80006002 <sys_pipe+0xe2>
    80005f70:	fc843503          	ld	a0,-56(s0)
    80005f74:	fffff097          	auipc	ra,0xfffff
    80005f78:	504080e7          	jalr	1284(ra) # 80005478 <fdalloc>
    80005f7c:	fca42023          	sw	a0,-64(s0)
    80005f80:	06054863          	bltz	a0,80005ff0 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f84:	4691                	li	a3,4
    80005f86:	fc440613          	addi	a2,s0,-60
    80005f8a:	fd843583          	ld	a1,-40(s0)
    80005f8e:	68a8                	ld	a0,80(s1)
    80005f90:	ffffb097          	auipc	ra,0xffffb
    80005f94:	6f4080e7          	jalr	1780(ra) # 80001684 <copyout>
    80005f98:	02054063          	bltz	a0,80005fb8 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f9c:	4691                	li	a3,4
    80005f9e:	fc040613          	addi	a2,s0,-64
    80005fa2:	fd843583          	ld	a1,-40(s0)
    80005fa6:	0591                	addi	a1,a1,4
    80005fa8:	68a8                	ld	a0,80(s1)
    80005faa:	ffffb097          	auipc	ra,0xffffb
    80005fae:	6da080e7          	jalr	1754(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005fb2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fb4:	06055463          	bgez	a0,8000601c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005fb8:	fc442783          	lw	a5,-60(s0)
    80005fbc:	07e9                	addi	a5,a5,26
    80005fbe:	078e                	slli	a5,a5,0x3
    80005fc0:	97a6                	add	a5,a5,s1
    80005fc2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005fc6:	fc042503          	lw	a0,-64(s0)
    80005fca:	0569                	addi	a0,a0,26
    80005fcc:	050e                	slli	a0,a0,0x3
    80005fce:	94aa                	add	s1,s1,a0
    80005fd0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005fd4:	fd043503          	ld	a0,-48(s0)
    80005fd8:	fffff097          	auipc	ra,0xfffff
    80005fdc:	a18080e7          	jalr	-1512(ra) # 800049f0 <fileclose>
    fileclose(wf);
    80005fe0:	fc843503          	ld	a0,-56(s0)
    80005fe4:	fffff097          	auipc	ra,0xfffff
    80005fe8:	a0c080e7          	jalr	-1524(ra) # 800049f0 <fileclose>
    return -1;
    80005fec:	57fd                	li	a5,-1
    80005fee:	a03d                	j	8000601c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005ff0:	fc442783          	lw	a5,-60(s0)
    80005ff4:	0007c763          	bltz	a5,80006002 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005ff8:	07e9                	addi	a5,a5,26
    80005ffa:	078e                	slli	a5,a5,0x3
    80005ffc:	94be                	add	s1,s1,a5
    80005ffe:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006002:	fd043503          	ld	a0,-48(s0)
    80006006:	fffff097          	auipc	ra,0xfffff
    8000600a:	9ea080e7          	jalr	-1558(ra) # 800049f0 <fileclose>
    fileclose(wf);
    8000600e:	fc843503          	ld	a0,-56(s0)
    80006012:	fffff097          	auipc	ra,0xfffff
    80006016:	9de080e7          	jalr	-1570(ra) # 800049f0 <fileclose>
    return -1;
    8000601a:	57fd                	li	a5,-1
}
    8000601c:	853e                	mv	a0,a5
    8000601e:	70e2                	ld	ra,56(sp)
    80006020:	7442                	ld	s0,48(sp)
    80006022:	74a2                	ld	s1,40(sp)
    80006024:	6121                	addi	sp,sp,64
    80006026:	8082                	ret
	...

0000000080006030 <kernelvec>:
    80006030:	7111                	addi	sp,sp,-256
    80006032:	e006                	sd	ra,0(sp)
    80006034:	e40a                	sd	sp,8(sp)
    80006036:	e80e                	sd	gp,16(sp)
    80006038:	ec12                	sd	tp,24(sp)
    8000603a:	f016                	sd	t0,32(sp)
    8000603c:	f41a                	sd	t1,40(sp)
    8000603e:	f81e                	sd	t2,48(sp)
    80006040:	fc22                	sd	s0,56(sp)
    80006042:	e0a6                	sd	s1,64(sp)
    80006044:	e4aa                	sd	a0,72(sp)
    80006046:	e8ae                	sd	a1,80(sp)
    80006048:	ecb2                	sd	a2,88(sp)
    8000604a:	f0b6                	sd	a3,96(sp)
    8000604c:	f4ba                	sd	a4,104(sp)
    8000604e:	f8be                	sd	a5,112(sp)
    80006050:	fcc2                	sd	a6,120(sp)
    80006052:	e146                	sd	a7,128(sp)
    80006054:	e54a                	sd	s2,136(sp)
    80006056:	e94e                	sd	s3,144(sp)
    80006058:	ed52                	sd	s4,152(sp)
    8000605a:	f156                	sd	s5,160(sp)
    8000605c:	f55a                	sd	s6,168(sp)
    8000605e:	f95e                	sd	s7,176(sp)
    80006060:	fd62                	sd	s8,184(sp)
    80006062:	e1e6                	sd	s9,192(sp)
    80006064:	e5ea                	sd	s10,200(sp)
    80006066:	e9ee                	sd	s11,208(sp)
    80006068:	edf2                	sd	t3,216(sp)
    8000606a:	f1f6                	sd	t4,224(sp)
    8000606c:	f5fa                	sd	t5,232(sp)
    8000606e:	f9fe                	sd	t6,240(sp)
    80006070:	c7bfc0ef          	jal	ra,80002cea <kerneltrap>
    80006074:	6082                	ld	ra,0(sp)
    80006076:	6122                	ld	sp,8(sp)
    80006078:	61c2                	ld	gp,16(sp)
    8000607a:	7282                	ld	t0,32(sp)
    8000607c:	7322                	ld	t1,40(sp)
    8000607e:	73c2                	ld	t2,48(sp)
    80006080:	7462                	ld	s0,56(sp)
    80006082:	6486                	ld	s1,64(sp)
    80006084:	6526                	ld	a0,72(sp)
    80006086:	65c6                	ld	a1,80(sp)
    80006088:	6666                	ld	a2,88(sp)
    8000608a:	7686                	ld	a3,96(sp)
    8000608c:	7726                	ld	a4,104(sp)
    8000608e:	77c6                	ld	a5,112(sp)
    80006090:	7866                	ld	a6,120(sp)
    80006092:	688a                	ld	a7,128(sp)
    80006094:	692a                	ld	s2,136(sp)
    80006096:	69ca                	ld	s3,144(sp)
    80006098:	6a6a                	ld	s4,152(sp)
    8000609a:	7a8a                	ld	s5,160(sp)
    8000609c:	7b2a                	ld	s6,168(sp)
    8000609e:	7bca                	ld	s7,176(sp)
    800060a0:	7c6a                	ld	s8,184(sp)
    800060a2:	6c8e                	ld	s9,192(sp)
    800060a4:	6d2e                	ld	s10,200(sp)
    800060a6:	6dce                	ld	s11,208(sp)
    800060a8:	6e6e                	ld	t3,216(sp)
    800060aa:	7e8e                	ld	t4,224(sp)
    800060ac:	7f2e                	ld	t5,232(sp)
    800060ae:	7fce                	ld	t6,240(sp)
    800060b0:	6111                	addi	sp,sp,256
    800060b2:	10200073          	sret
    800060b6:	00000013          	nop
    800060ba:	00000013          	nop
    800060be:	0001                	nop

00000000800060c0 <timervec>:
    800060c0:	34051573          	csrrw	a0,mscratch,a0
    800060c4:	e10c                	sd	a1,0(a0)
    800060c6:	e510                	sd	a2,8(a0)
    800060c8:	e914                	sd	a3,16(a0)
    800060ca:	6d0c                	ld	a1,24(a0)
    800060cc:	7110                	ld	a2,32(a0)
    800060ce:	6194                	ld	a3,0(a1)
    800060d0:	96b2                	add	a3,a3,a2
    800060d2:	e194                	sd	a3,0(a1)
    800060d4:	4589                	li	a1,2
    800060d6:	14459073          	csrw	sip,a1
    800060da:	6914                	ld	a3,16(a0)
    800060dc:	6510                	ld	a2,8(a0)
    800060de:	610c                	ld	a1,0(a0)
    800060e0:	34051573          	csrrw	a0,mscratch,a0
    800060e4:	30200073          	mret
	...

00000000800060ea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060ea:	1141                	addi	sp,sp,-16
    800060ec:	e422                	sd	s0,8(sp)
    800060ee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060f0:	0c0007b7          	lui	a5,0xc000
    800060f4:	4705                	li	a4,1
    800060f6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060f8:	c3d8                	sw	a4,4(a5)
}
    800060fa:	6422                	ld	s0,8(sp)
    800060fc:	0141                	addi	sp,sp,16
    800060fe:	8082                	ret

0000000080006100 <plicinithart>:

void
plicinithart(void)
{
    80006100:	1141                	addi	sp,sp,-16
    80006102:	e406                	sd	ra,8(sp)
    80006104:	e022                	sd	s0,0(sp)
    80006106:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006108:	ffffc097          	auipc	ra,0xffffc
    8000610c:	892080e7          	jalr	-1902(ra) # 8000199a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006110:	0085171b          	slliw	a4,a0,0x8
    80006114:	0c0027b7          	lui	a5,0xc002
    80006118:	97ba                	add	a5,a5,a4
    8000611a:	40200713          	li	a4,1026
    8000611e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006122:	00d5151b          	slliw	a0,a0,0xd
    80006126:	0c2017b7          	lui	a5,0xc201
    8000612a:	953e                	add	a0,a0,a5
    8000612c:	00052023          	sw	zero,0(a0)
}
    80006130:	60a2                	ld	ra,8(sp)
    80006132:	6402                	ld	s0,0(sp)
    80006134:	0141                	addi	sp,sp,16
    80006136:	8082                	ret

0000000080006138 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006138:	1141                	addi	sp,sp,-16
    8000613a:	e406                	sd	ra,8(sp)
    8000613c:	e022                	sd	s0,0(sp)
    8000613e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006140:	ffffc097          	auipc	ra,0xffffc
    80006144:	85a080e7          	jalr	-1958(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006148:	00d5179b          	slliw	a5,a0,0xd
    8000614c:	0c201537          	lui	a0,0xc201
    80006150:	953e                	add	a0,a0,a5
  return irq;
}
    80006152:	4148                	lw	a0,4(a0)
    80006154:	60a2                	ld	ra,8(sp)
    80006156:	6402                	ld	s0,0(sp)
    80006158:	0141                	addi	sp,sp,16
    8000615a:	8082                	ret

000000008000615c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000615c:	1101                	addi	sp,sp,-32
    8000615e:	ec06                	sd	ra,24(sp)
    80006160:	e822                	sd	s0,16(sp)
    80006162:	e426                	sd	s1,8(sp)
    80006164:	1000                	addi	s0,sp,32
    80006166:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006168:	ffffc097          	auipc	ra,0xffffc
    8000616c:	832080e7          	jalr	-1998(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006170:	00d5151b          	slliw	a0,a0,0xd
    80006174:	0c2017b7          	lui	a5,0xc201
    80006178:	97aa                	add	a5,a5,a0
    8000617a:	c3c4                	sw	s1,4(a5)
}
    8000617c:	60e2                	ld	ra,24(sp)
    8000617e:	6442                	ld	s0,16(sp)
    80006180:	64a2                	ld	s1,8(sp)
    80006182:	6105                	addi	sp,sp,32
    80006184:	8082                	ret

0000000080006186 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006186:	1141                	addi	sp,sp,-16
    80006188:	e406                	sd	ra,8(sp)
    8000618a:	e022                	sd	s0,0(sp)
    8000618c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000618e:	479d                	li	a5,7
    80006190:	04a7cc63          	blt	a5,a0,800061e8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006194:	0001c797          	auipc	a5,0x1c
    80006198:	2ec78793          	addi	a5,a5,748 # 80022480 <disk>
    8000619c:	97aa                	add	a5,a5,a0
    8000619e:	0187c783          	lbu	a5,24(a5)
    800061a2:	ebb9                	bnez	a5,800061f8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800061a4:	00451613          	slli	a2,a0,0x4
    800061a8:	0001c797          	auipc	a5,0x1c
    800061ac:	2d878793          	addi	a5,a5,728 # 80022480 <disk>
    800061b0:	6394                	ld	a3,0(a5)
    800061b2:	96b2                	add	a3,a3,a2
    800061b4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800061b8:	6398                	ld	a4,0(a5)
    800061ba:	9732                	add	a4,a4,a2
    800061bc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800061c0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800061c4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800061c8:	953e                	add	a0,a0,a5
    800061ca:	4785                	li	a5,1
    800061cc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800061d0:	0001c517          	auipc	a0,0x1c
    800061d4:	2c850513          	addi	a0,a0,712 # 80022498 <disk+0x18>
    800061d8:	ffffc097          	auipc	ra,0xffffc
    800061dc:	ef6080e7          	jalr	-266(ra) # 800020ce <wakeup>
}
    800061e0:	60a2                	ld	ra,8(sp)
    800061e2:	6402                	ld	s0,0(sp)
    800061e4:	0141                	addi	sp,sp,16
    800061e6:	8082                	ret
    panic("free_desc 1");
    800061e8:	00002517          	auipc	a0,0x2
    800061ec:	5d850513          	addi	a0,a0,1496 # 800087c0 <syscalls+0x320>
    800061f0:	ffffa097          	auipc	ra,0xffffa
    800061f4:	354080e7          	jalr	852(ra) # 80000544 <panic>
    panic("free_desc 2");
    800061f8:	00002517          	auipc	a0,0x2
    800061fc:	5d850513          	addi	a0,a0,1496 # 800087d0 <syscalls+0x330>
    80006200:	ffffa097          	auipc	ra,0xffffa
    80006204:	344080e7          	jalr	836(ra) # 80000544 <panic>

0000000080006208 <virtio_disk_init>:
{
    80006208:	1101                	addi	sp,sp,-32
    8000620a:	ec06                	sd	ra,24(sp)
    8000620c:	e822                	sd	s0,16(sp)
    8000620e:	e426                	sd	s1,8(sp)
    80006210:	e04a                	sd	s2,0(sp)
    80006212:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006214:	00002597          	auipc	a1,0x2
    80006218:	5cc58593          	addi	a1,a1,1484 # 800087e0 <syscalls+0x340>
    8000621c:	0001c517          	auipc	a0,0x1c
    80006220:	38c50513          	addi	a0,a0,908 # 800225a8 <disk+0x128>
    80006224:	ffffb097          	auipc	ra,0xffffb
    80006228:	936080e7          	jalr	-1738(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000622c:	100017b7          	lui	a5,0x10001
    80006230:	4398                	lw	a4,0(a5)
    80006232:	2701                	sext.w	a4,a4
    80006234:	747277b7          	lui	a5,0x74727
    80006238:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000623c:	14f71e63          	bne	a4,a5,80006398 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006240:	100017b7          	lui	a5,0x10001
    80006244:	43dc                	lw	a5,4(a5)
    80006246:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006248:	4709                	li	a4,2
    8000624a:	14e79763          	bne	a5,a4,80006398 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000624e:	100017b7          	lui	a5,0x10001
    80006252:	479c                	lw	a5,8(a5)
    80006254:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006256:	14e79163          	bne	a5,a4,80006398 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000625a:	100017b7          	lui	a5,0x10001
    8000625e:	47d8                	lw	a4,12(a5)
    80006260:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006262:	554d47b7          	lui	a5,0x554d4
    80006266:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000626a:	12f71763          	bne	a4,a5,80006398 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000626e:	100017b7          	lui	a5,0x10001
    80006272:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006276:	4705                	li	a4,1
    80006278:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000627a:	470d                	li	a4,3
    8000627c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000627e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006280:	c7ffe737          	lui	a4,0xc7ffe
    80006284:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc19f>
    80006288:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000628a:	2701                	sext.w	a4,a4
    8000628c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000628e:	472d                	li	a4,11
    80006290:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006292:	0707a903          	lw	s2,112(a5)
    80006296:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006298:	00897793          	andi	a5,s2,8
    8000629c:	10078663          	beqz	a5,800063a8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800062a0:	100017b7          	lui	a5,0x10001
    800062a4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800062a8:	43fc                	lw	a5,68(a5)
    800062aa:	2781                	sext.w	a5,a5
    800062ac:	10079663          	bnez	a5,800063b8 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800062b0:	100017b7          	lui	a5,0x10001
    800062b4:	5bdc                	lw	a5,52(a5)
    800062b6:	2781                	sext.w	a5,a5
  if(max == 0)
    800062b8:	10078863          	beqz	a5,800063c8 <virtio_disk_init+0x1c0>
  if(max < NUM)
    800062bc:	471d                	li	a4,7
    800062be:	10f77d63          	bgeu	a4,a5,800063d8 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    800062c2:	ffffb097          	auipc	ra,0xffffb
    800062c6:	838080e7          	jalr	-1992(ra) # 80000afa <kalloc>
    800062ca:	0001c497          	auipc	s1,0x1c
    800062ce:	1b648493          	addi	s1,s1,438 # 80022480 <disk>
    800062d2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800062d4:	ffffb097          	auipc	ra,0xffffb
    800062d8:	826080e7          	jalr	-2010(ra) # 80000afa <kalloc>
    800062dc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800062de:	ffffb097          	auipc	ra,0xffffb
    800062e2:	81c080e7          	jalr	-2020(ra) # 80000afa <kalloc>
    800062e6:	87aa                	mv	a5,a0
    800062e8:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800062ea:	6088                	ld	a0,0(s1)
    800062ec:	cd75                	beqz	a0,800063e8 <virtio_disk_init+0x1e0>
    800062ee:	0001c717          	auipc	a4,0x1c
    800062f2:	19a73703          	ld	a4,410(a4) # 80022488 <disk+0x8>
    800062f6:	cb6d                	beqz	a4,800063e8 <virtio_disk_init+0x1e0>
    800062f8:	cbe5                	beqz	a5,800063e8 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    800062fa:	6605                	lui	a2,0x1
    800062fc:	4581                	li	a1,0
    800062fe:	ffffb097          	auipc	ra,0xffffb
    80006302:	9e8080e7          	jalr	-1560(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006306:	0001c497          	auipc	s1,0x1c
    8000630a:	17a48493          	addi	s1,s1,378 # 80022480 <disk>
    8000630e:	6605                	lui	a2,0x1
    80006310:	4581                	li	a1,0
    80006312:	6488                	ld	a0,8(s1)
    80006314:	ffffb097          	auipc	ra,0xffffb
    80006318:	9d2080e7          	jalr	-1582(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000631c:	6605                	lui	a2,0x1
    8000631e:	4581                	li	a1,0
    80006320:	6888                	ld	a0,16(s1)
    80006322:	ffffb097          	auipc	ra,0xffffb
    80006326:	9c4080e7          	jalr	-1596(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000632a:	100017b7          	lui	a5,0x10001
    8000632e:	4721                	li	a4,8
    80006330:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006332:	4098                	lw	a4,0(s1)
    80006334:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006338:	40d8                	lw	a4,4(s1)
    8000633a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000633e:	6498                	ld	a4,8(s1)
    80006340:	0007069b          	sext.w	a3,a4
    80006344:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006348:	9701                	srai	a4,a4,0x20
    8000634a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000634e:	6898                	ld	a4,16(s1)
    80006350:	0007069b          	sext.w	a3,a4
    80006354:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006358:	9701                	srai	a4,a4,0x20
    8000635a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000635e:	4685                	li	a3,1
    80006360:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006362:	4705                	li	a4,1
    80006364:	00d48c23          	sb	a3,24(s1)
    80006368:	00e48ca3          	sb	a4,25(s1)
    8000636c:	00e48d23          	sb	a4,26(s1)
    80006370:	00e48da3          	sb	a4,27(s1)
    80006374:	00e48e23          	sb	a4,28(s1)
    80006378:	00e48ea3          	sb	a4,29(s1)
    8000637c:	00e48f23          	sb	a4,30(s1)
    80006380:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006384:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006388:	0727a823          	sw	s2,112(a5)
}
    8000638c:	60e2                	ld	ra,24(sp)
    8000638e:	6442                	ld	s0,16(sp)
    80006390:	64a2                	ld	s1,8(sp)
    80006392:	6902                	ld	s2,0(sp)
    80006394:	6105                	addi	sp,sp,32
    80006396:	8082                	ret
    panic("could not find virtio disk");
    80006398:	00002517          	auipc	a0,0x2
    8000639c:	45850513          	addi	a0,a0,1112 # 800087f0 <syscalls+0x350>
    800063a0:	ffffa097          	auipc	ra,0xffffa
    800063a4:	1a4080e7          	jalr	420(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    800063a8:	00002517          	auipc	a0,0x2
    800063ac:	46850513          	addi	a0,a0,1128 # 80008810 <syscalls+0x370>
    800063b0:	ffffa097          	auipc	ra,0xffffa
    800063b4:	194080e7          	jalr	404(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    800063b8:	00002517          	auipc	a0,0x2
    800063bc:	47850513          	addi	a0,a0,1144 # 80008830 <syscalls+0x390>
    800063c0:	ffffa097          	auipc	ra,0xffffa
    800063c4:	184080e7          	jalr	388(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    800063c8:	00002517          	auipc	a0,0x2
    800063cc:	48850513          	addi	a0,a0,1160 # 80008850 <syscalls+0x3b0>
    800063d0:	ffffa097          	auipc	ra,0xffffa
    800063d4:	174080e7          	jalr	372(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    800063d8:	00002517          	auipc	a0,0x2
    800063dc:	49850513          	addi	a0,a0,1176 # 80008870 <syscalls+0x3d0>
    800063e0:	ffffa097          	auipc	ra,0xffffa
    800063e4:	164080e7          	jalr	356(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    800063e8:	00002517          	auipc	a0,0x2
    800063ec:	4a850513          	addi	a0,a0,1192 # 80008890 <syscalls+0x3f0>
    800063f0:	ffffa097          	auipc	ra,0xffffa
    800063f4:	154080e7          	jalr	340(ra) # 80000544 <panic>

00000000800063f8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800063f8:	7159                	addi	sp,sp,-112
    800063fa:	f486                	sd	ra,104(sp)
    800063fc:	f0a2                	sd	s0,96(sp)
    800063fe:	eca6                	sd	s1,88(sp)
    80006400:	e8ca                	sd	s2,80(sp)
    80006402:	e4ce                	sd	s3,72(sp)
    80006404:	e0d2                	sd	s4,64(sp)
    80006406:	fc56                	sd	s5,56(sp)
    80006408:	f85a                	sd	s6,48(sp)
    8000640a:	f45e                	sd	s7,40(sp)
    8000640c:	f062                	sd	s8,32(sp)
    8000640e:	ec66                	sd	s9,24(sp)
    80006410:	e86a                	sd	s10,16(sp)
    80006412:	1880                	addi	s0,sp,112
    80006414:	892a                	mv	s2,a0
    80006416:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006418:	00c52c83          	lw	s9,12(a0)
    8000641c:	001c9c9b          	slliw	s9,s9,0x1
    80006420:	1c82                	slli	s9,s9,0x20
    80006422:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006426:	0001c517          	auipc	a0,0x1c
    8000642a:	18250513          	addi	a0,a0,386 # 800225a8 <disk+0x128>
    8000642e:	ffffa097          	auipc	ra,0xffffa
    80006432:	7bc080e7          	jalr	1980(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006436:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006438:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000643a:	0001cb17          	auipc	s6,0x1c
    8000643e:	046b0b13          	addi	s6,s6,70 # 80022480 <disk>
  for(int i = 0; i < 3; i++){
    80006442:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006444:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006446:	0001cc17          	auipc	s8,0x1c
    8000644a:	162c0c13          	addi	s8,s8,354 # 800225a8 <disk+0x128>
    8000644e:	a8b5                	j	800064ca <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006450:	00fb06b3          	add	a3,s6,a5
    80006454:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006458:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000645a:	0207c563          	bltz	a5,80006484 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000645e:	2485                	addiw	s1,s1,1
    80006460:	0711                	addi	a4,a4,4
    80006462:	1f548a63          	beq	s1,s5,80006656 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006466:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006468:	0001c697          	auipc	a3,0x1c
    8000646c:	01868693          	addi	a3,a3,24 # 80022480 <disk>
    80006470:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006472:	0186c583          	lbu	a1,24(a3)
    80006476:	fde9                	bnez	a1,80006450 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006478:	2785                	addiw	a5,a5,1
    8000647a:	0685                	addi	a3,a3,1
    8000647c:	ff779be3          	bne	a5,s7,80006472 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006480:	57fd                	li	a5,-1
    80006482:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006484:	02905a63          	blez	s1,800064b8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006488:	f9042503          	lw	a0,-112(s0)
    8000648c:	00000097          	auipc	ra,0x0
    80006490:	cfa080e7          	jalr	-774(ra) # 80006186 <free_desc>
      for(int j = 0; j < i; j++)
    80006494:	4785                	li	a5,1
    80006496:	0297d163          	bge	a5,s1,800064b8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000649a:	f9442503          	lw	a0,-108(s0)
    8000649e:	00000097          	auipc	ra,0x0
    800064a2:	ce8080e7          	jalr	-792(ra) # 80006186 <free_desc>
      for(int j = 0; j < i; j++)
    800064a6:	4789                	li	a5,2
    800064a8:	0097d863          	bge	a5,s1,800064b8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800064ac:	f9842503          	lw	a0,-104(s0)
    800064b0:	00000097          	auipc	ra,0x0
    800064b4:	cd6080e7          	jalr	-810(ra) # 80006186 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064b8:	85e2                	mv	a1,s8
    800064ba:	0001c517          	auipc	a0,0x1c
    800064be:	fde50513          	addi	a0,a0,-34 # 80022498 <disk+0x18>
    800064c2:	ffffc097          	auipc	ra,0xffffc
    800064c6:	ba8080e7          	jalr	-1112(ra) # 8000206a <sleep>
  for(int i = 0; i < 3; i++){
    800064ca:	f9040713          	addi	a4,s0,-112
    800064ce:	84ce                	mv	s1,s3
    800064d0:	bf59                	j	80006466 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800064d2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800064d6:	00479693          	slli	a3,a5,0x4
    800064da:	0001c797          	auipc	a5,0x1c
    800064de:	fa678793          	addi	a5,a5,-90 # 80022480 <disk>
    800064e2:	97b6                	add	a5,a5,a3
    800064e4:	4685                	li	a3,1
    800064e6:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800064e8:	0001c597          	auipc	a1,0x1c
    800064ec:	f9858593          	addi	a1,a1,-104 # 80022480 <disk>
    800064f0:	00a60793          	addi	a5,a2,10
    800064f4:	0792                	slli	a5,a5,0x4
    800064f6:	97ae                	add	a5,a5,a1
    800064f8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800064fc:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006500:	f6070693          	addi	a3,a4,-160
    80006504:	619c                	ld	a5,0(a1)
    80006506:	97b6                	add	a5,a5,a3
    80006508:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000650a:	6188                	ld	a0,0(a1)
    8000650c:	96aa                	add	a3,a3,a0
    8000650e:	47c1                	li	a5,16
    80006510:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006512:	4785                	li	a5,1
    80006514:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006518:	f9442783          	lw	a5,-108(s0)
    8000651c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006520:	0792                	slli	a5,a5,0x4
    80006522:	953e                	add	a0,a0,a5
    80006524:	05890693          	addi	a3,s2,88
    80006528:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000652a:	6188                	ld	a0,0(a1)
    8000652c:	97aa                	add	a5,a5,a0
    8000652e:	40000693          	li	a3,1024
    80006532:	c794                	sw	a3,8(a5)
  if(write)
    80006534:	100d0d63          	beqz	s10,8000664e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006538:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000653c:	00c7d683          	lhu	a3,12(a5)
    80006540:	0016e693          	ori	a3,a3,1
    80006544:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006548:	f9842583          	lw	a1,-104(s0)
    8000654c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006550:	0001c697          	auipc	a3,0x1c
    80006554:	f3068693          	addi	a3,a3,-208 # 80022480 <disk>
    80006558:	00260793          	addi	a5,a2,2
    8000655c:	0792                	slli	a5,a5,0x4
    8000655e:	97b6                	add	a5,a5,a3
    80006560:	587d                	li	a6,-1
    80006562:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006566:	0592                	slli	a1,a1,0x4
    80006568:	952e                	add	a0,a0,a1
    8000656a:	f9070713          	addi	a4,a4,-112
    8000656e:	9736                	add	a4,a4,a3
    80006570:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006572:	6298                	ld	a4,0(a3)
    80006574:	972e                	add	a4,a4,a1
    80006576:	4585                	li	a1,1
    80006578:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000657a:	4509                	li	a0,2
    8000657c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006580:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006584:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006588:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000658c:	6698                	ld	a4,8(a3)
    8000658e:	00275783          	lhu	a5,2(a4)
    80006592:	8b9d                	andi	a5,a5,7
    80006594:	0786                	slli	a5,a5,0x1
    80006596:	97ba                	add	a5,a5,a4
    80006598:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000659c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065a0:	6698                	ld	a4,8(a3)
    800065a2:	00275783          	lhu	a5,2(a4)
    800065a6:	2785                	addiw	a5,a5,1
    800065a8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065ac:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065b0:	100017b7          	lui	a5,0x10001
    800065b4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800065b8:	00492703          	lw	a4,4(s2)
    800065bc:	4785                	li	a5,1
    800065be:	02f71163          	bne	a4,a5,800065e0 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    800065c2:	0001c997          	auipc	s3,0x1c
    800065c6:	fe698993          	addi	s3,s3,-26 # 800225a8 <disk+0x128>
  while(b->disk == 1) {
    800065ca:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800065cc:	85ce                	mv	a1,s3
    800065ce:	854a                	mv	a0,s2
    800065d0:	ffffc097          	auipc	ra,0xffffc
    800065d4:	a9a080e7          	jalr	-1382(ra) # 8000206a <sleep>
  while(b->disk == 1) {
    800065d8:	00492783          	lw	a5,4(s2)
    800065dc:	fe9788e3          	beq	a5,s1,800065cc <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    800065e0:	f9042903          	lw	s2,-112(s0)
    800065e4:	00290793          	addi	a5,s2,2
    800065e8:	00479713          	slli	a4,a5,0x4
    800065ec:	0001c797          	auipc	a5,0x1c
    800065f0:	e9478793          	addi	a5,a5,-364 # 80022480 <disk>
    800065f4:	97ba                	add	a5,a5,a4
    800065f6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800065fa:	0001c997          	auipc	s3,0x1c
    800065fe:	e8698993          	addi	s3,s3,-378 # 80022480 <disk>
    80006602:	00491713          	slli	a4,s2,0x4
    80006606:	0009b783          	ld	a5,0(s3)
    8000660a:	97ba                	add	a5,a5,a4
    8000660c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006610:	854a                	mv	a0,s2
    80006612:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006616:	00000097          	auipc	ra,0x0
    8000661a:	b70080e7          	jalr	-1168(ra) # 80006186 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000661e:	8885                	andi	s1,s1,1
    80006620:	f0ed                	bnez	s1,80006602 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006622:	0001c517          	auipc	a0,0x1c
    80006626:	f8650513          	addi	a0,a0,-122 # 800225a8 <disk+0x128>
    8000662a:	ffffa097          	auipc	ra,0xffffa
    8000662e:	674080e7          	jalr	1652(ra) # 80000c9e <release>
}
    80006632:	70a6                	ld	ra,104(sp)
    80006634:	7406                	ld	s0,96(sp)
    80006636:	64e6                	ld	s1,88(sp)
    80006638:	6946                	ld	s2,80(sp)
    8000663a:	69a6                	ld	s3,72(sp)
    8000663c:	6a06                	ld	s4,64(sp)
    8000663e:	7ae2                	ld	s5,56(sp)
    80006640:	7b42                	ld	s6,48(sp)
    80006642:	7ba2                	ld	s7,40(sp)
    80006644:	7c02                	ld	s8,32(sp)
    80006646:	6ce2                	ld	s9,24(sp)
    80006648:	6d42                	ld	s10,16(sp)
    8000664a:	6165                	addi	sp,sp,112
    8000664c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000664e:	4689                	li	a3,2
    80006650:	00d79623          	sh	a3,12(a5)
    80006654:	b5e5                	j	8000653c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006656:	f9042603          	lw	a2,-112(s0)
    8000665a:	00a60713          	addi	a4,a2,10
    8000665e:	0712                	slli	a4,a4,0x4
    80006660:	0001c517          	auipc	a0,0x1c
    80006664:	e2850513          	addi	a0,a0,-472 # 80022488 <disk+0x8>
    80006668:	953a                	add	a0,a0,a4
  if(write)
    8000666a:	e60d14e3          	bnez	s10,800064d2 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000666e:	00a60793          	addi	a5,a2,10
    80006672:	00479693          	slli	a3,a5,0x4
    80006676:	0001c797          	auipc	a5,0x1c
    8000667a:	e0a78793          	addi	a5,a5,-502 # 80022480 <disk>
    8000667e:	97b6                	add	a5,a5,a3
    80006680:	0007a423          	sw	zero,8(a5)
    80006684:	b595                	j	800064e8 <virtio_disk_rw+0xf0>

0000000080006686 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006686:	1101                	addi	sp,sp,-32
    80006688:	ec06                	sd	ra,24(sp)
    8000668a:	e822                	sd	s0,16(sp)
    8000668c:	e426                	sd	s1,8(sp)
    8000668e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006690:	0001c497          	auipc	s1,0x1c
    80006694:	df048493          	addi	s1,s1,-528 # 80022480 <disk>
    80006698:	0001c517          	auipc	a0,0x1c
    8000669c:	f1050513          	addi	a0,a0,-240 # 800225a8 <disk+0x128>
    800066a0:	ffffa097          	auipc	ra,0xffffa
    800066a4:	54a080e7          	jalr	1354(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066a8:	10001737          	lui	a4,0x10001
    800066ac:	533c                	lw	a5,96(a4)
    800066ae:	8b8d                	andi	a5,a5,3
    800066b0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066b2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066b6:	689c                	ld	a5,16(s1)
    800066b8:	0204d703          	lhu	a4,32(s1)
    800066bc:	0027d783          	lhu	a5,2(a5)
    800066c0:	04f70863          	beq	a4,a5,80006710 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800066c4:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066c8:	6898                	ld	a4,16(s1)
    800066ca:	0204d783          	lhu	a5,32(s1)
    800066ce:	8b9d                	andi	a5,a5,7
    800066d0:	078e                	slli	a5,a5,0x3
    800066d2:	97ba                	add	a5,a5,a4
    800066d4:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800066d6:	00278713          	addi	a4,a5,2
    800066da:	0712                	slli	a4,a4,0x4
    800066dc:	9726                	add	a4,a4,s1
    800066de:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800066e2:	e721                	bnez	a4,8000672a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800066e4:	0789                	addi	a5,a5,2
    800066e6:	0792                	slli	a5,a5,0x4
    800066e8:	97a6                	add	a5,a5,s1
    800066ea:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800066ec:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800066f0:	ffffc097          	auipc	ra,0xffffc
    800066f4:	9de080e7          	jalr	-1570(ra) # 800020ce <wakeup>

    disk.used_idx += 1;
    800066f8:	0204d783          	lhu	a5,32(s1)
    800066fc:	2785                	addiw	a5,a5,1
    800066fe:	17c2                	slli	a5,a5,0x30
    80006700:	93c1                	srli	a5,a5,0x30
    80006702:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006706:	6898                	ld	a4,16(s1)
    80006708:	00275703          	lhu	a4,2(a4)
    8000670c:	faf71ce3          	bne	a4,a5,800066c4 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006710:	0001c517          	auipc	a0,0x1c
    80006714:	e9850513          	addi	a0,a0,-360 # 800225a8 <disk+0x128>
    80006718:	ffffa097          	auipc	ra,0xffffa
    8000671c:	586080e7          	jalr	1414(ra) # 80000c9e <release>
}
    80006720:	60e2                	ld	ra,24(sp)
    80006722:	6442                	ld	s0,16(sp)
    80006724:	64a2                	ld	s1,8(sp)
    80006726:	6105                	addi	sp,sp,32
    80006728:	8082                	ret
      panic("virtio_disk_intr status");
    8000672a:	00002517          	auipc	a0,0x2
    8000672e:	17e50513          	addi	a0,a0,382 # 800088a8 <syscalls+0x408>
    80006732:	ffffa097          	auipc	ra,0xffffa
    80006736:	e12080e7          	jalr	-494(ra) # 80000544 <panic>
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
