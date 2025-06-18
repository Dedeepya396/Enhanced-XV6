
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8d013103          	ld	sp,-1840(sp) # 800088d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

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
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8e070713          	addi	a4,a4,-1824 # 80008930 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	10e78793          	addi	a5,a5,270 # 80006170 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd51df>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	4e8080e7          	jalr	1256(ra) # 80002612 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
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
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8e650513          	addi	a0,a0,-1818 # 80010a70 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8d648493          	addi	s1,s1,-1834 # 80010a70 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	96690913          	addi	s2,s2,-1690 # 80010b08 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	81c080e7          	jalr	-2020(ra) # 800019dc <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	294080e7          	jalr	660(ra) # 8000245c <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	fd2080e7          	jalr	-46(ra) # 800021a8 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	3aa080e7          	jalr	938(ra) # 800025bc <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	84a50513          	addi	a0,a0,-1974 # 80010a70 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	83450513          	addi	a0,a0,-1996 # 80010a70 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	88f72b23          	sw	a5,-1898(a4) # 80010b08 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	7a450513          	addi	a0,a0,1956 # 80010a70 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	376080e7          	jalr	886(ra) # 80002668 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	77650513          	addi	a0,a0,1910 # 80010a70 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	75270713          	addi	a4,a4,1874 # 80010a70 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	72878793          	addi	a5,a5,1832 # 80010a70 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7927a783          	lw	a5,1938(a5) # 80010b08 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6e670713          	addi	a4,a4,1766 # 80010a70 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6d648493          	addi	s1,s1,1750 # 80010a70 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	69a70713          	addi	a4,a4,1690 # 80010a70 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	72f72223          	sw	a5,1828(a4) # 80010b10 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	65e78793          	addi	a5,a5,1630 # 80010a70 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6cc7ab23          	sw	a2,1750(a5) # 80010b0c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6ca50513          	addi	a0,a0,1738 # 80010b08 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	dc6080e7          	jalr	-570(ra) # 8000220c <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	61050513          	addi	a0,a0,1552 # 80010a70 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00028797          	auipc	a5,0x28
    8000047c:	01078793          	addi	a5,a5,16 # 80028488 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	5e07a223          	sw	zero,1508(a5) # 80010b30 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	36f72823          	sw	a5,880(a4) # 800088f0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	574dad83          	lw	s11,1396(s11) # 80010b30 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	51e50513          	addi	a0,a0,1310 # 80010b18 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	3c050513          	addi	a0,a0,960 # 80010b18 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	3a448493          	addi	s1,s1,932 # 80010b18 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	36450513          	addi	a0,a0,868 # 80010b38 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	0f07a783          	lw	a5,240(a5) # 800088f0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	0c07b783          	ld	a5,192(a5) # 800088f8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	0c073703          	ld	a4,192(a4) # 80008900 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	2d6a0a13          	addi	s4,s4,726 # 80010b38 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	08e48493          	addi	s1,s1,142 # 800088f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	08e98993          	addi	s3,s3,142 # 80008900 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	978080e7          	jalr	-1672(ra) # 8000220c <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	26850513          	addi	a0,a0,616 # 80010b38 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	0107a783          	lw	a5,16(a5) # 800088f0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	01673703          	ld	a4,22(a4) # 80008900 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	0067b783          	ld	a5,6(a5) # 800088f8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	23a98993          	addi	s3,s3,570 # 80010b38 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	ff248493          	addi	s1,s1,-14 # 800088f8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	ff290913          	addi	s2,s2,-14 # 80008900 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	88a080e7          	jalr	-1910(ra) # 800021a8 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	20448493          	addi	s1,s1,516 # 80010b38 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	fae7bc23          	sd	a4,-72(a5) # 80008900 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	17e48493          	addi	s1,s1,382 # 80010b38 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00029797          	auipc	a5,0x29
    80000a00:	c2478793          	addi	a5,a5,-988 # 80029620 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	15490913          	addi	s2,s2,340 # 80010b70 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	0b650513          	addi	a0,a0,182 # 80010b70 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00029517          	auipc	a0,0x29
    80000ad2:	b5250513          	addi	a0,a0,-1198 # 80029620 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	08048493          	addi	s1,s1,128 # 80010b70 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	06850513          	addi	a0,a0,104 # 80010b70 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	03c50513          	addi	a0,a0,60 # 80010b70 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e50080e7          	jalr	-432(ra) # 800019c0 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	e1e080e7          	jalr	-482(ra) # 800019c0 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	e12080e7          	jalr	-494(ra) # 800019c0 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dfa080e7          	jalr	-518(ra) # 800019c0 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	dba080e7          	jalr	-582(ra) # 800019c0 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d8e080e7          	jalr	-626(ra) # 800019c0 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd59e1>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b30080e7          	jalr	-1232(ra) # 800019b0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0);
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a8070713          	addi	a4,a4,-1408 # 80008908 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0);
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	b14080e7          	jalr	-1260(ra) # 800019b0 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	a9a080e7          	jalr	-1382(ra) # 80002958 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	2ea080e7          	jalr	746(ra) # 800061b0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	128080e7          	jalr	296(ra) # 80001ff6 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	9ce080e7          	jalr	-1586(ra) # 800018fc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	9fa080e7          	jalr	-1542(ra) # 80002930 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	a1a080e7          	jalr	-1510(ra) # 80002958 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	254080e7          	jalr	596(ra) # 8000619a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	262080e7          	jalr	610(ra) # 800061b0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	404080e7          	jalr	1028(ra) # 8000335a <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	aa4080e7          	jalr	-1372(ra) # 80003a02 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	a4a080e7          	jalr	-1462(ra) # 800049b0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	34a080e7          	jalr	842(ra) # 800062b8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	da6080e7          	jalr	-602(ra) # 80001d1c <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	98f72223          	sw	a5,-1660(a4) # 80008908 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9787b783          	ld	a5,-1672(a5) # 80008910 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd59d7>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	638080e7          	jalr	1592(ra) # 80001866 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	6aa7be23          	sd	a0,1724(a5) # 80008910 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd59e0>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <random>:
static void freeproc(struct proc *p);

extern char trampoline[];             // trampoline.S
static unsigned int seed = 123456789; // Initial seed value
unsigned int random(void)
{
    80001836:	1141                	addi	sp,sp,-16
    80001838:	e422                	sd	s0,8(sp)
    8000183a:	0800                	addi	s0,sp,16
  // Linear Congruential Generator (LCG) formula
  seed = (1103515245 * seed + 12345) % 2147483648; // Modulo 2^31
    8000183c:	00007717          	auipc	a4,0x7
    80001840:	04870713          	addi	a4,a4,72 # 80008884 <seed>
    80001844:	431c                	lw	a5,0(a4)
    80001846:	41c65537          	lui	a0,0x41c65
    8000184a:	e6d5051b          	addiw	a0,a0,-403 # 41c64e6d <_entry-0x3e39b193>
    8000184e:	02f5053b          	mulw	a0,a0,a5
    80001852:	678d                	lui	a5,0x3
    80001854:	0397879b          	addiw	a5,a5,57 # 3039 <_entry-0x7fffcfc7>
    80001858:	9d3d                	addw	a0,a0,a5
    8000185a:	1506                	slli	a0,a0,0x21
    8000185c:	9105                	srli	a0,a0,0x21
    8000185e:	c308                	sw	a0,0(a4)
  return seed;
}
    80001860:	6422                	ld	s0,8(sp)
    80001862:	0141                	addi	sp,sp,16
    80001864:	8082                	ret

0000000080001866 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001866:	7139                	addi	sp,sp,-64
    80001868:	fc06                	sd	ra,56(sp)
    8000186a:	f822                	sd	s0,48(sp)
    8000186c:	f426                	sd	s1,40(sp)
    8000186e:	f04a                	sd	s2,32(sp)
    80001870:	ec4e                	sd	s3,24(sp)
    80001872:	e852                	sd	s4,16(sp)
    80001874:	e456                	sd	s5,8(sp)
    80001876:	e05a                	sd	s6,0(sp)
    80001878:	0080                	addi	s0,sp,64
    8000187a:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000187c:	0000f497          	auipc	s1,0xf
    80001880:	74448493          	addi	s1,s1,1860 # 80010fc0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001884:	8b26                	mv	s6,s1
    80001886:	00006a97          	auipc	s5,0x6
    8000188a:	77aa8a93          	addi	s5,s5,1914 # 80008000 <etext>
    8000188e:	04000937          	lui	s2,0x4000
    80001892:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001894:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001896:	0001da17          	auipc	s4,0x1d
    8000189a:	92aa0a13          	addi	s4,s4,-1750 # 8001e1c0 <tickslock>
    char *pa = kalloc();
    8000189e:	fffff097          	auipc	ra,0xfffff
    800018a2:	248080e7          	jalr	584(ra) # 80000ae6 <kalloc>
    800018a6:	862a                	mv	a2,a0
    if (pa == 0)
    800018a8:	c131                	beqz	a0,800018ec <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    800018aa:	416485b3          	sub	a1,s1,s6
    800018ae:	858d                	srai	a1,a1,0x3
    800018b0:	000ab783          	ld	a5,0(s5)
    800018b4:	02f585b3          	mul	a1,a1,a5
    800018b8:	2585                	addiw	a1,a1,1
    800018ba:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018be:	4719                	li	a4,6
    800018c0:	6685                	lui	a3,0x1
    800018c2:	40b905b3          	sub	a1,s2,a1
    800018c6:	854e                	mv	a0,s3
    800018c8:	00000097          	auipc	ra,0x0
    800018cc:	876080e7          	jalr	-1930(ra) # 8000113e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018d0:	34848493          	addi	s1,s1,840
    800018d4:	fd4495e3          	bne	s1,s4,8000189e <proc_mapstacks+0x38>
  }
}
    800018d8:	70e2                	ld	ra,56(sp)
    800018da:	7442                	ld	s0,48(sp)
    800018dc:	74a2                	ld	s1,40(sp)
    800018de:	7902                	ld	s2,32(sp)
    800018e0:	69e2                	ld	s3,24(sp)
    800018e2:	6a42                	ld	s4,16(sp)
    800018e4:	6aa2                	ld	s5,8(sp)
    800018e6:	6b02                	ld	s6,0(sp)
    800018e8:	6121                	addi	sp,sp,64
    800018ea:	8082                	ret
      panic("kalloc");
    800018ec:	00007517          	auipc	a0,0x7
    800018f0:	8ec50513          	addi	a0,a0,-1812 # 800081d8 <digits+0x198>
    800018f4:	fffff097          	auipc	ra,0xfffff
    800018f8:	c4c080e7          	jalr	-948(ra) # 80000540 <panic>

00000000800018fc <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018fc:	7139                	addi	sp,sp,-64
    800018fe:	fc06                	sd	ra,56(sp)
    80001900:	f822                	sd	s0,48(sp)
    80001902:	f426                	sd	s1,40(sp)
    80001904:	f04a                	sd	s2,32(sp)
    80001906:	ec4e                	sd	s3,24(sp)
    80001908:	e852                	sd	s4,16(sp)
    8000190a:	e456                	sd	s5,8(sp)
    8000190c:	e05a                	sd	s6,0(sp)
    8000190e:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001910:	00007597          	auipc	a1,0x7
    80001914:	8d058593          	addi	a1,a1,-1840 # 800081e0 <digits+0x1a0>
    80001918:	0000f517          	auipc	a0,0xf
    8000191c:	27850513          	addi	a0,a0,632 # 80010b90 <pid_lock>
    80001920:	fffff097          	auipc	ra,0xfffff
    80001924:	226080e7          	jalr	550(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001928:	00007597          	auipc	a1,0x7
    8000192c:	8c058593          	addi	a1,a1,-1856 # 800081e8 <digits+0x1a8>
    80001930:	0000f517          	auipc	a0,0xf
    80001934:	27850513          	addi	a0,a0,632 # 80010ba8 <wait_lock>
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20e080e7          	jalr	526(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001940:	0000f497          	auipc	s1,0xf
    80001944:	68048493          	addi	s1,s1,1664 # 80010fc0 <proc>
  {
    initlock(&p->lock, "proc");
    80001948:	00007b17          	auipc	s6,0x7
    8000194c:	8b0b0b13          	addi	s6,s6,-1872 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001950:	8aa6                	mv	s5,s1
    80001952:	00006a17          	auipc	s4,0x6
    80001956:	6aea0a13          	addi	s4,s4,1710 # 80008000 <etext>
    8000195a:	04000937          	lui	s2,0x4000
    8000195e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001960:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001962:	0001d997          	auipc	s3,0x1d
    80001966:	85e98993          	addi	s3,s3,-1954 # 8001e1c0 <tickslock>
    initlock(&p->lock, "proc");
    8000196a:	85da                	mv	a1,s6
    8000196c:	8526                	mv	a0,s1
    8000196e:	fffff097          	auipc	ra,0xfffff
    80001972:	1d8080e7          	jalr	472(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001976:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000197a:	415487b3          	sub	a5,s1,s5
    8000197e:	878d                	srai	a5,a5,0x3
    80001980:	000a3703          	ld	a4,0(s4)
    80001984:	02e787b3          	mul	a5,a5,a4
    80001988:	2785                	addiw	a5,a5,1
    8000198a:	00d7979b          	slliw	a5,a5,0xd
    8000198e:	40f907b3          	sub	a5,s2,a5
    80001992:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001994:	34848493          	addi	s1,s1,840
    80001998:	fd3499e3          	bne	s1,s3,8000196a <procinit+0x6e>
  }
}
    8000199c:	70e2                	ld	ra,56(sp)
    8000199e:	7442                	ld	s0,48(sp)
    800019a0:	74a2                	ld	s1,40(sp)
    800019a2:	7902                	ld	s2,32(sp)
    800019a4:	69e2                	ld	s3,24(sp)
    800019a6:	6a42                	ld	s4,16(sp)
    800019a8:	6aa2                	ld	s5,8(sp)
    800019aa:	6b02                	ld	s6,0(sp)
    800019ac:	6121                	addi	sp,sp,64
    800019ae:	8082                	ret

00000000800019b0 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    800019b0:	1141                	addi	sp,sp,-16
    800019b2:	e422                	sd	s0,8(sp)
    800019b4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019b6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019b8:	2501                	sext.w	a0,a0
    800019ba:	6422                	ld	s0,8(sp)
    800019bc:	0141                	addi	sp,sp,16
    800019be:	8082                	ret

00000000800019c0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800019c0:	1141                	addi	sp,sp,-16
    800019c2:	e422                	sd	s0,8(sp)
    800019c4:	0800                	addi	s0,sp,16
    800019c6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019c8:	2781                	sext.w	a5,a5
    800019ca:	079e                	slli	a5,a5,0x7
  return c;
}
    800019cc:	0000f517          	auipc	a0,0xf
    800019d0:	1f450513          	addi	a0,a0,500 # 80010bc0 <cpus>
    800019d4:	953e                	add	a0,a0,a5
    800019d6:	6422                	ld	s0,8(sp)
    800019d8:	0141                	addi	sp,sp,16
    800019da:	8082                	ret

00000000800019dc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019dc:	1101                	addi	sp,sp,-32
    800019de:	ec06                	sd	ra,24(sp)
    800019e0:	e822                	sd	s0,16(sp)
    800019e2:	e426                	sd	s1,8(sp)
    800019e4:	1000                	addi	s0,sp,32
  push_off();
    800019e6:	fffff097          	auipc	ra,0xfffff
    800019ea:	1a4080e7          	jalr	420(ra) # 80000b8a <push_off>
    800019ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019f0:	2781                	sext.w	a5,a5
    800019f2:	079e                	slli	a5,a5,0x7
    800019f4:	0000f717          	auipc	a4,0xf
    800019f8:	19c70713          	addi	a4,a4,412 # 80010b90 <pid_lock>
    800019fc:	97ba                	add	a5,a5,a4
    800019fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a00:	fffff097          	auipc	ra,0xfffff
    80001a04:	22a080e7          	jalr	554(ra) # 80000c2a <pop_off>
  return p;
}
    80001a08:	8526                	mv	a0,s1
    80001a0a:	60e2                	ld	ra,24(sp)
    80001a0c:	6442                	ld	s0,16(sp)
    80001a0e:	64a2                	ld	s1,8(sp)
    80001a10:	6105                	addi	sp,sp,32
    80001a12:	8082                	ret

0000000080001a14 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001a14:	1141                	addi	sp,sp,-16
    80001a16:	e406                	sd	ra,8(sp)
    80001a18:	e022                	sd	s0,0(sp)
    80001a1a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a1c:	00000097          	auipc	ra,0x0
    80001a20:	fc0080e7          	jalr	-64(ra) # 800019dc <myproc>
    80001a24:	fffff097          	auipc	ra,0xfffff
    80001a28:	266080e7          	jalr	614(ra) # 80000c8a <release>

  if (first)
    80001a2c:	00007797          	auipc	a5,0x7
    80001a30:	e547a783          	lw	a5,-428(a5) # 80008880 <first.1>
    80001a34:	eb89                	bnez	a5,80001a46 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a36:	00001097          	auipc	ra,0x1
    80001a3a:	f3a080e7          	jalr	-198(ra) # 80002970 <usertrapret>
}
    80001a3e:	60a2                	ld	ra,8(sp)
    80001a40:	6402                	ld	s0,0(sp)
    80001a42:	0141                	addi	sp,sp,16
    80001a44:	8082                	ret
    first = 0;
    80001a46:	00007797          	auipc	a5,0x7
    80001a4a:	e207ad23          	sw	zero,-454(a5) # 80008880 <first.1>
    fsinit(ROOTDEV);
    80001a4e:	4505                	li	a0,1
    80001a50:	00002097          	auipc	ra,0x2
    80001a54:	f32080e7          	jalr	-206(ra) # 80003982 <fsinit>
    80001a58:	bff9                	j	80001a36 <forkret+0x22>

0000000080001a5a <allocpid>:
{
    80001a5a:	1101                	addi	sp,sp,-32
    80001a5c:	ec06                	sd	ra,24(sp)
    80001a5e:	e822                	sd	s0,16(sp)
    80001a60:	e426                	sd	s1,8(sp)
    80001a62:	e04a                	sd	s2,0(sp)
    80001a64:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a66:	0000f917          	auipc	s2,0xf
    80001a6a:	12a90913          	addi	s2,s2,298 # 80010b90 <pid_lock>
    80001a6e:	854a                	mv	a0,s2
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	166080e7          	jalr	358(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a78:	00007797          	auipc	a5,0x7
    80001a7c:	e1078793          	addi	a5,a5,-496 # 80008888 <nextpid>
    80001a80:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a82:	0014871b          	addiw	a4,s1,1
    80001a86:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a88:	854a                	mv	a0,s2
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	200080e7          	jalr	512(ra) # 80000c8a <release>
}
    80001a92:	8526                	mv	a0,s1
    80001a94:	60e2                	ld	ra,24(sp)
    80001a96:	6442                	ld	s0,16(sp)
    80001a98:	64a2                	ld	s1,8(sp)
    80001a9a:	6902                	ld	s2,0(sp)
    80001a9c:	6105                	addi	sp,sp,32
    80001a9e:	8082                	ret

0000000080001aa0 <proc_pagetable>:
{
    80001aa0:	1101                	addi	sp,sp,-32
    80001aa2:	ec06                	sd	ra,24(sp)
    80001aa4:	e822                	sd	s0,16(sp)
    80001aa6:	e426                	sd	s1,8(sp)
    80001aa8:	e04a                	sd	s2,0(sp)
    80001aaa:	1000                	addi	s0,sp,32
    80001aac:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aae:	00000097          	auipc	ra,0x0
    80001ab2:	87a080e7          	jalr	-1926(ra) # 80001328 <uvmcreate>
    80001ab6:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001ab8:	c121                	beqz	a0,80001af8 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aba:	4729                	li	a4,10
    80001abc:	00005697          	auipc	a3,0x5
    80001ac0:	54468693          	addi	a3,a3,1348 # 80007000 <_trampoline>
    80001ac4:	6605                	lui	a2,0x1
    80001ac6:	040005b7          	lui	a1,0x4000
    80001aca:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001acc:	05b2                	slli	a1,a1,0xc
    80001ace:	fffff097          	auipc	ra,0xfffff
    80001ad2:	5d0080e7          	jalr	1488(ra) # 8000109e <mappages>
    80001ad6:	02054863          	bltz	a0,80001b06 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ada:	4719                	li	a4,6
    80001adc:	05893683          	ld	a3,88(s2)
    80001ae0:	6605                	lui	a2,0x1
    80001ae2:	020005b7          	lui	a1,0x2000
    80001ae6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ae8:	05b6                	slli	a1,a1,0xd
    80001aea:	8526                	mv	a0,s1
    80001aec:	fffff097          	auipc	ra,0xfffff
    80001af0:	5b2080e7          	jalr	1458(ra) # 8000109e <mappages>
    80001af4:	02054163          	bltz	a0,80001b16 <proc_pagetable+0x76>
}
    80001af8:	8526                	mv	a0,s1
    80001afa:	60e2                	ld	ra,24(sp)
    80001afc:	6442                	ld	s0,16(sp)
    80001afe:	64a2                	ld	s1,8(sp)
    80001b00:	6902                	ld	s2,0(sp)
    80001b02:	6105                	addi	sp,sp,32
    80001b04:	8082                	ret
    uvmfree(pagetable, 0);
    80001b06:	4581                	li	a1,0
    80001b08:	8526                	mv	a0,s1
    80001b0a:	00000097          	auipc	ra,0x0
    80001b0e:	a24080e7          	jalr	-1500(ra) # 8000152e <uvmfree>
    return 0;
    80001b12:	4481                	li	s1,0
    80001b14:	b7d5                	j	80001af8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	05b2                	slli	a1,a1,0xc
    80001b22:	8526                	mv	a0,s1
    80001b24:	fffff097          	auipc	ra,0xfffff
    80001b28:	740080e7          	jalr	1856(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b2c:	4581                	li	a1,0
    80001b2e:	8526                	mv	a0,s1
    80001b30:	00000097          	auipc	ra,0x0
    80001b34:	9fe080e7          	jalr	-1538(ra) # 8000152e <uvmfree>
    return 0;
    80001b38:	4481                	li	s1,0
    80001b3a:	bf7d                	j	80001af8 <proc_pagetable+0x58>

0000000080001b3c <proc_freepagetable>:
{
    80001b3c:	1101                	addi	sp,sp,-32
    80001b3e:	ec06                	sd	ra,24(sp)
    80001b40:	e822                	sd	s0,16(sp)
    80001b42:	e426                	sd	s1,8(sp)
    80001b44:	e04a                	sd	s2,0(sp)
    80001b46:	1000                	addi	s0,sp,32
    80001b48:	84aa                	mv	s1,a0
    80001b4a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b4c:	4681                	li	a3,0
    80001b4e:	4605                	li	a2,1
    80001b50:	040005b7          	lui	a1,0x4000
    80001b54:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b56:	05b2                	slli	a1,a1,0xc
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	70c080e7          	jalr	1804(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b60:	4681                	li	a3,0
    80001b62:	4605                	li	a2,1
    80001b64:	020005b7          	lui	a1,0x2000
    80001b68:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b6a:	05b6                	slli	a1,a1,0xd
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	6f6080e7          	jalr	1782(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b76:	85ca                	mv	a1,s2
    80001b78:	8526                	mv	a0,s1
    80001b7a:	00000097          	auipc	ra,0x0
    80001b7e:	9b4080e7          	jalr	-1612(ra) # 8000152e <uvmfree>
}
    80001b82:	60e2                	ld	ra,24(sp)
    80001b84:	6442                	ld	s0,16(sp)
    80001b86:	64a2                	ld	s1,8(sp)
    80001b88:	6902                	ld	s2,0(sp)
    80001b8a:	6105                	addi	sp,sp,32
    80001b8c:	8082                	ret

0000000080001b8e <freeproc>:
{
    80001b8e:	1101                	addi	sp,sp,-32
    80001b90:	ec06                	sd	ra,24(sp)
    80001b92:	e822                	sd	s0,16(sp)
    80001b94:	e426                	sd	s1,8(sp)
    80001b96:	1000                	addi	s0,sp,32
    80001b98:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b9a:	6d28                	ld	a0,88(a0)
    80001b9c:	c509                	beqz	a0,80001ba6 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	e4a080e7          	jalr	-438(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001ba6:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001baa:	68a8                	ld	a0,80(s1)
    80001bac:	c511                	beqz	a0,80001bb8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bae:	64ac                	ld	a1,72(s1)
    80001bb0:	00000097          	auipc	ra,0x0
    80001bb4:	f8c080e7          	jalr	-116(ra) # 80001b3c <proc_freepagetable>
  p->pagetable = 0;
    80001bb8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bbc:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bc0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bc4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bc8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bcc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bd0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bd4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bd8:	0004ac23          	sw	zero,24(s1)
}
    80001bdc:	60e2                	ld	ra,24(sp)
    80001bde:	6442                	ld	s0,16(sp)
    80001be0:	64a2                	ld	s1,8(sp)
    80001be2:	6105                	addi	sp,sp,32
    80001be4:	8082                	ret

0000000080001be6 <allocproc>:
{
    80001be6:	7139                	addi	sp,sp,-64
    80001be8:	fc06                	sd	ra,56(sp)
    80001bea:	f822                	sd	s0,48(sp)
    80001bec:	f426                	sd	s1,40(sp)
    80001bee:	f04a                	sd	s2,32(sp)
    80001bf0:	ec4e                	sd	s3,24(sp)
    80001bf2:	e852                	sd	s4,16(sp)
    80001bf4:	e456                	sd	s5,8(sp)
    80001bf6:	0080                	addi	s0,sp,64
  for (p = proc; p < &proc[NPROC]; p++)
    80001bf8:	0000f497          	auipc	s1,0xf
    80001bfc:	5b848493          	addi	s1,s1,1464 # 800111b0 <proc+0x1f0>
    80001c00:	0000f917          	auipc	s2,0xf
    80001c04:	3c090913          	addi	s2,s2,960 # 80010fc0 <proc>
    p->ticket = 1;
    80001c08:	4a85                	li	s5,1
    p->arrival_time = ticks;
    80001c0a:	00007a17          	auipc	s4,0x7
    80001c0e:	d22a0a13          	addi	s4,s4,-734 # 8000892c <ticks>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c12:	0001c997          	auipc	s3,0x1c
    80001c16:	5ae98993          	addi	s3,s3,1454 # 8001e1c0 <tickslock>
    80001c1a:	a055                	j	80001cbe <allocproc+0xd8>
  p->pid = allocpid();
    80001c1c:	00000097          	auipc	ra,0x0
    80001c20:	e3e080e7          	jalr	-450(ra) # 80001a5a <allocpid>
    80001c24:	02a92823          	sw	a0,48(s2)
  p->state = USED;
    80001c28:	4785                	li	a5,1
    80001c2a:	00f92c23          	sw	a5,24(s2)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	eb8080e7          	jalr	-328(ra) # 80000ae6 <kalloc>
    80001c36:	84aa                	mv	s1,a0
    80001c38:	04a93c23          	sd	a0,88(s2)
    80001c3c:	c945                	beqz	a0,80001cec <allocproc+0x106>
  p->pagetable = proc_pagetable(p);
    80001c3e:	854a                	mv	a0,s2
    80001c40:	00000097          	auipc	ra,0x0
    80001c44:	e60080e7          	jalr	-416(ra) # 80001aa0 <proc_pagetable>
    80001c48:	84aa                	mv	s1,a0
    80001c4a:	04a93823          	sd	a0,80(s2)
  if (p->pagetable == 0)
    80001c4e:	c95d                	beqz	a0,80001d04 <allocproc+0x11e>
  memset(&p->context, 0, sizeof(p->context));
    80001c50:	07000613          	li	a2,112
    80001c54:	4581                	li	a1,0
    80001c56:	06090513          	addi	a0,s2,96
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	078080e7          	jalr	120(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c62:	00000797          	auipc	a5,0x0
    80001c66:	db278793          	addi	a5,a5,-590 # 80001a14 <forkret>
    80001c6a:	06f93023          	sd	a5,96(s2)
  p->context.sp = p->kstack + PGSIZE;
    80001c6e:	04093783          	ld	a5,64(s2)
    80001c72:	6705                	lui	a4,0x1
    80001c74:	97ba                	add	a5,a5,a4
    80001c76:	06f93423          	sd	a5,104(s2)
  p->rtime = 0;
    80001c7a:	16092423          	sw	zero,360(s2)
  p->etime = 0;
    80001c7e:	16092823          	sw	zero,368(s2)
  p->ctime = ticks;
    80001c82:	00007797          	auipc	a5,0x7
    80001c86:	caa7a783          	lw	a5,-854(a5) # 8000892c <ticks>
    80001c8a:	16f92623          	sw	a5,364(s2)
}
    80001c8e:	854a                	mv	a0,s2
    80001c90:	70e2                	ld	ra,56(sp)
    80001c92:	7442                	ld	s0,48(sp)
    80001c94:	74a2                	ld	s1,40(sp)
    80001c96:	7902                	ld	s2,32(sp)
    80001c98:	69e2                	ld	s3,24(sp)
    80001c9a:	6a42                	ld	s4,16(sp)
    80001c9c:	6aa2                	ld	s5,8(sp)
    80001c9e:	6121                	addi	sp,sp,64
    80001ca0:	8082                	ret
    p->ticket = 1;
    80001ca2:	33592823          	sw	s5,816(s2)
    p->arrival_time = ticks;
    80001ca6:	000a2783          	lw	a5,0(s4)
    80001caa:	32f92623          	sw	a5,812(s2)
    p->priority = 0;
    80001cae:	32092a23          	sw	zero,820(s2)
  for (p = proc; p < &proc[NPROC]; p++)
    80001cb2:	34890913          	addi	s2,s2,840
    80001cb6:	34848493          	addi	s1,s1,840
    80001cba:	03390763          	beq	s2,s3,80001ce8 <allocproc+0x102>
    acquire(&p->lock);
    80001cbe:	854a                	mv	a0,s2
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	f16080e7          	jalr	-234(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001cc8:	01892783          	lw	a5,24(s2)
    80001ccc:	dba1                	beqz	a5,80001c1c <allocproc+0x36>
      release(&p->lock);
    80001cce:	854a                	mv	a0,s2
    80001cd0:	fffff097          	auipc	ra,0xfffff
    80001cd4:	fba080e7          	jalr	-70(ra) # 80000c8a <release>
    for (int i = 0; i < 31; i++)
    80001cd8:	17490793          	addi	a5,s2,372
      p->syscall_count[i] = 0;
    80001cdc:	0007a023          	sw	zero,0(a5)
    for (int i = 0; i < 31; i++)
    80001ce0:	0791                	addi	a5,a5,4
    80001ce2:	fe979de3          	bne	a5,s1,80001cdc <allocproc+0xf6>
    80001ce6:	bf75                	j	80001ca2 <allocproc+0xbc>
  return 0;
    80001ce8:	4901                	li	s2,0
    80001cea:	b755                	j	80001c8e <allocproc+0xa8>
    freeproc(p);
    80001cec:	854a                	mv	a0,s2
    80001cee:	00000097          	auipc	ra,0x0
    80001cf2:	ea0080e7          	jalr	-352(ra) # 80001b8e <freeproc>
    release(&p->lock);
    80001cf6:	854a                	mv	a0,s2
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	f92080e7          	jalr	-110(ra) # 80000c8a <release>
    return 0;
    80001d00:	8926                	mv	s2,s1
    80001d02:	b771                	j	80001c8e <allocproc+0xa8>
    freeproc(p);
    80001d04:	854a                	mv	a0,s2
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	e88080e7          	jalr	-376(ra) # 80001b8e <freeproc>
    release(&p->lock);
    80001d0e:	854a                	mv	a0,s2
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	f7a080e7          	jalr	-134(ra) # 80000c8a <release>
    return 0;
    80001d18:	8926                	mv	s2,s1
    80001d1a:	bf95                	j	80001c8e <allocproc+0xa8>

0000000080001d1c <userinit>:
{
    80001d1c:	7179                	addi	sp,sp,-48
    80001d1e:	f406                	sd	ra,40(sp)
    80001d20:	f022                	sd	s0,32(sp)
    80001d22:	ec26                	sd	s1,24(sp)
    80001d24:	e84a                	sd	s2,16(sp)
    80001d26:	e44e                	sd	s3,8(sp)
    80001d28:	1800                	addi	s0,sp,48
  p = allocproc();
    80001d2a:	00000097          	auipc	ra,0x0
    80001d2e:	ebc080e7          	jalr	-324(ra) # 80001be6 <allocproc>
    80001d32:	84aa                	mv	s1,a0
  initproc = p;
    80001d34:	00007997          	auipc	s3,0x7
    80001d38:	bec98993          	addi	s3,s3,-1044 # 80008920 <initproc>
    80001d3c:	00a9b023          	sd	a0,0(s3)
  p->ticket = 1;
    80001d40:	4905                	li	s2,1
    80001d42:	33252823          	sw	s2,816(a0)
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d46:	03400613          	li	a2,52
    80001d4a:	00007597          	auipc	a1,0x7
    80001d4e:	b4658593          	addi	a1,a1,-1210 # 80008890 <initcode>
    80001d52:	6928                	ld	a0,80(a0)
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	602080e7          	jalr	1538(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d5c:	6785                	lui	a5,0x1
    80001d5e:	e4bc                	sd	a5,72(s1)
  initproc->ticket = 1;
    80001d60:	0009b703          	ld	a4,0(s3)
    80001d64:	33272823          	sw	s2,816(a4) # 1330 <_entry-0x7fffecd0>
  p->trapframe->epc = 0;     // user program counter
    80001d68:	6cb8                	ld	a4,88(s1)
    80001d6a:	00073c23          	sd	zero,24(a4)
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d6e:	6cb8                	ld	a4,88(s1)
    80001d70:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d72:	4641                	li	a2,16
    80001d74:	00006597          	auipc	a1,0x6
    80001d78:	48c58593          	addi	a1,a1,1164 # 80008200 <digits+0x1c0>
    80001d7c:	15848513          	addi	a0,s1,344
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	09c080e7          	jalr	156(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d88:	00006517          	auipc	a0,0x6
    80001d8c:	48850513          	addi	a0,a0,1160 # 80008210 <digits+0x1d0>
    80001d90:	00002097          	auipc	ra,0x2
    80001d94:	61c080e7          	jalr	1564(ra) # 800043ac <namei>
    80001d98:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d9c:	478d                	li	a5,3
    80001d9e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001da0:	8526                	mv	a0,s1
    80001da2:	fffff097          	auipc	ra,0xfffff
    80001da6:	ee8080e7          	jalr	-280(ra) # 80000c8a <release>
}
    80001daa:	70a2                	ld	ra,40(sp)
    80001dac:	7402                	ld	s0,32(sp)
    80001dae:	64e2                	ld	s1,24(sp)
    80001db0:	6942                	ld	s2,16(sp)
    80001db2:	69a2                	ld	s3,8(sp)
    80001db4:	6145                	addi	sp,sp,48
    80001db6:	8082                	ret

0000000080001db8 <growproc>:
{
    80001db8:	1101                	addi	sp,sp,-32
    80001dba:	ec06                	sd	ra,24(sp)
    80001dbc:	e822                	sd	s0,16(sp)
    80001dbe:	e426                	sd	s1,8(sp)
    80001dc0:	e04a                	sd	s2,0(sp)
    80001dc2:	1000                	addi	s0,sp,32
    80001dc4:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001dc6:	00000097          	auipc	ra,0x0
    80001dca:	c16080e7          	jalr	-1002(ra) # 800019dc <myproc>
    80001dce:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dd0:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001dd2:	01204c63          	bgtz	s2,80001dea <growproc+0x32>
  else if (n < 0)
    80001dd6:	02094663          	bltz	s2,80001e02 <growproc+0x4a>
  p->sz = sz;
    80001dda:	e4ac                	sd	a1,72(s1)
  return 0;
    80001ddc:	4501                	li	a0,0
}
    80001dde:	60e2                	ld	ra,24(sp)
    80001de0:	6442                	ld	s0,16(sp)
    80001de2:	64a2                	ld	s1,8(sp)
    80001de4:	6902                	ld	s2,0(sp)
    80001de6:	6105                	addi	sp,sp,32
    80001de8:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001dea:	4691                	li	a3,4
    80001dec:	00b90633          	add	a2,s2,a1
    80001df0:	6928                	ld	a0,80(a0)
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	61e080e7          	jalr	1566(ra) # 80001410 <uvmalloc>
    80001dfa:	85aa                	mv	a1,a0
    80001dfc:	fd79                	bnez	a0,80001dda <growproc+0x22>
      return -1;
    80001dfe:	557d                	li	a0,-1
    80001e00:	bff9                	j	80001dde <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e02:	00b90633          	add	a2,s2,a1
    80001e06:	6928                	ld	a0,80(a0)
    80001e08:	fffff097          	auipc	ra,0xfffff
    80001e0c:	5c0080e7          	jalr	1472(ra) # 800013c8 <uvmdealloc>
    80001e10:	85aa                	mv	a1,a0
    80001e12:	b7e1                	j	80001dda <growproc+0x22>

0000000080001e14 <fork>:
{
    80001e14:	7139                	addi	sp,sp,-64
    80001e16:	fc06                	sd	ra,56(sp)
    80001e18:	f822                	sd	s0,48(sp)
    80001e1a:	f426                	sd	s1,40(sp)
    80001e1c:	f04a                	sd	s2,32(sp)
    80001e1e:	ec4e                	sd	s3,24(sp)
    80001e20:	e852                	sd	s4,16(sp)
    80001e22:	e456                	sd	s5,8(sp)
    80001e24:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e26:	00000097          	auipc	ra,0x0
    80001e2a:	bb6080e7          	jalr	-1098(ra) # 800019dc <myproc>
    80001e2e:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001e30:	00000097          	auipc	ra,0x0
    80001e34:	db6080e7          	jalr	-586(ra) # 80001be6 <allocproc>
    80001e38:	12050663          	beqz	a0,80001f64 <fork+0x150>
    80001e3c:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e3e:	048ab603          	ld	a2,72(s5)
    80001e42:	692c                	ld	a1,80(a0)
    80001e44:	050ab503          	ld	a0,80(s5)
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	720080e7          	jalr	1824(ra) # 80001568 <uvmcopy>
    80001e50:	04054863          	bltz	a0,80001ea0 <fork+0x8c>
  np->sz = p->sz;
    80001e54:	048ab783          	ld	a5,72(s5)
    80001e58:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e5c:	058ab683          	ld	a3,88(s5)
    80001e60:	87b6                	mv	a5,a3
    80001e62:	0589b703          	ld	a4,88(s3)
    80001e66:	12068693          	addi	a3,a3,288
    80001e6a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e6e:	6788                	ld	a0,8(a5)
    80001e70:	6b8c                	ld	a1,16(a5)
    80001e72:	6f90                	ld	a2,24(a5)
    80001e74:	01073023          	sd	a6,0(a4)
    80001e78:	e708                	sd	a0,8(a4)
    80001e7a:	eb0c                	sd	a1,16(a4)
    80001e7c:	ef10                	sd	a2,24(a4)
    80001e7e:	02078793          	addi	a5,a5,32
    80001e82:	02070713          	addi	a4,a4,32
    80001e86:	fed792e3          	bne	a5,a3,80001e6a <fork+0x56>
  np->trapframe->a0 = 0;
    80001e8a:	0589b783          	ld	a5,88(s3)
    80001e8e:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e92:	0d0a8493          	addi	s1,s5,208
    80001e96:	0d098913          	addi	s2,s3,208
    80001e9a:	150a8a13          	addi	s4,s5,336
    80001e9e:	a00d                	j	80001ec0 <fork+0xac>
    freeproc(np);
    80001ea0:	854e                	mv	a0,s3
    80001ea2:	00000097          	auipc	ra,0x0
    80001ea6:	cec080e7          	jalr	-788(ra) # 80001b8e <freeproc>
    release(&np->lock);
    80001eaa:	854e                	mv	a0,s3
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	dde080e7          	jalr	-546(ra) # 80000c8a <release>
    return -1;
    80001eb4:	597d                	li	s2,-1
    80001eb6:	a869                	j	80001f50 <fork+0x13c>
  for (i = 0; i < NOFILE; i++)
    80001eb8:	04a1                	addi	s1,s1,8
    80001eba:	0921                	addi	s2,s2,8
    80001ebc:	01448b63          	beq	s1,s4,80001ed2 <fork+0xbe>
    if (p->ofile[i])
    80001ec0:	6088                	ld	a0,0(s1)
    80001ec2:	d97d                	beqz	a0,80001eb8 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ec4:	00003097          	auipc	ra,0x3
    80001ec8:	b7e080e7          	jalr	-1154(ra) # 80004a42 <filedup>
    80001ecc:	00a93023          	sd	a0,0(s2)
    80001ed0:	b7e5                	j	80001eb8 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ed2:	150ab503          	ld	a0,336(s5)
    80001ed6:	00002097          	auipc	ra,0x2
    80001eda:	cec080e7          	jalr	-788(ra) # 80003bc2 <idup>
    80001ede:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ee2:	4641                	li	a2,16
    80001ee4:	158a8593          	addi	a1,s5,344
    80001ee8:	15898513          	addi	a0,s3,344
    80001eec:	fffff097          	auipc	ra,0xfffff
    80001ef0:	f30080e7          	jalr	-208(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001ef4:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ef8:	854e                	mv	a0,s3
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	d90080e7          	jalr	-624(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001f02:	0000f497          	auipc	s1,0xf
    80001f06:	ca648493          	addi	s1,s1,-858 # 80010ba8 <wait_lock>
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	cca080e7          	jalr	-822(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001f14:	0359bc23          	sd	s5,56(s3)
  np->ticket = p->ticket;
    80001f18:	330aa783          	lw	a5,816(s5)
    80001f1c:	32f9a823          	sw	a5,816(s3)
  release(&wait_lock);
    80001f20:	8526                	mv	a0,s1
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	d68080e7          	jalr	-664(ra) # 80000c8a <release>
  np->arrival_time = ticks;
    80001f2a:	00007797          	auipc	a5,0x7
    80001f2e:	a027a783          	lw	a5,-1534(a5) # 8000892c <ticks>
    80001f32:	32f9a623          	sw	a5,812(s3)
  acquire(&np->lock);
    80001f36:	854e                	mv	a0,s3
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	c9e080e7          	jalr	-866(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001f40:	478d                	li	a5,3
    80001f42:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f46:	854e                	mv	a0,s3
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	d42080e7          	jalr	-702(ra) # 80000c8a <release>
}
    80001f50:	854a                	mv	a0,s2
    80001f52:	70e2                	ld	ra,56(sp)
    80001f54:	7442                	ld	s0,48(sp)
    80001f56:	74a2                	ld	s1,40(sp)
    80001f58:	7902                	ld	s2,32(sp)
    80001f5a:	69e2                	ld	s3,24(sp)
    80001f5c:	6a42                	ld	s4,16(sp)
    80001f5e:	6aa2                	ld	s5,8(sp)
    80001f60:	6121                	addi	sp,sp,64
    80001f62:	8082                	ret
    return -1;
    80001f64:	597d                	li	s2,-1
    80001f66:	b7ed                	j	80001f50 <fork+0x13c>

0000000080001f68 <priority_boost>:
  if (pb_time >= 48)
    80001f68:	00007717          	auipc	a4,0x7
    80001f6c:	9b072703          	lw	a4,-1616(a4) # 80008918 <pb_time>
    80001f70:	02f00793          	li	a5,47
    80001f74:	04e7da63          	bge	a5,a4,80001fc8 <priority_boost+0x60>
{
    80001f78:	1101                	addi	sp,sp,-32
    80001f7a:	ec06                	sd	ra,24(sp)
    80001f7c:	e822                	sd	s0,16(sp)
    80001f7e:	e426                	sd	s1,8(sp)
    80001f80:	e04a                	sd	s2,0(sp)
    80001f82:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001f84:	0000f497          	auipc	s1,0xf
    80001f88:	03c48493          	addi	s1,s1,60 # 80010fc0 <proc>
    80001f8c:	0001c917          	auipc	s2,0x1c
    80001f90:	23490913          	addi	s2,s2,564 # 8001e1c0 <tickslock>
    80001f94:	a811                	j	80001fa8 <priority_boost+0x40>
      release(&p->lock);
    80001f96:	8526                	mv	a0,s1
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	cf2080e7          	jalr	-782(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001fa0:	34848493          	addi	s1,s1,840
    80001fa4:	01248c63          	beq	s1,s2,80001fbc <priority_boost+0x54>
      acquire(&p->lock);
    80001fa8:	8526                	mv	a0,s1
    80001faa:	fffff097          	auipc	ra,0xfffff
    80001fae:	c2c080e7          	jalr	-980(ra) # 80000bd6 <acquire>
      if (p->state != UNUSED)
    80001fb2:	4c9c                	lw	a5,24(s1)
    80001fb4:	d3ed                	beqz	a5,80001f96 <priority_boost+0x2e>
        p->priority = 0;
    80001fb6:	3204aa23          	sw	zero,820(s1)
    80001fba:	bff1                	j	80001f96 <priority_boost+0x2e>
}
    80001fbc:	60e2                	ld	ra,24(sp)
    80001fbe:	6442                	ld	s0,16(sp)
    80001fc0:	64a2                	ld	s1,8(sp)
    80001fc2:	6902                	ld	s2,0(sp)
    80001fc4:	6105                	addi	sp,sp,32
    80001fc6:	8082                	ret
    80001fc8:	8082                	ret

0000000080001fca <get_time_slice>:
{
    80001fca:	1141                	addi	sp,sp,-16
    80001fcc:	e422                	sd	s0,8(sp)
    80001fce:	0800                	addi	s0,sp,16
  switch (queue)
    80001fd0:	4709                	li	a4,2
    80001fd2:	02e50063          	beq	a0,a4,80001ff2 <get_time_slice+0x28>
    80001fd6:	87aa                	mv	a5,a0
    80001fd8:	470d                	li	a4,3
    return 16; // Priority 3 time slice
    80001fda:	4541                	li	a0,16
  switch (queue)
    80001fdc:	00e78663          	beq	a5,a4,80001fe8 <get_time_slice+0x1e>
    80001fe0:	4705                	li	a4,1
    return 1; // Priority 0 time slice
    80001fe2:	4505                	li	a0,1
  switch (queue)
    80001fe4:	00e78563          	beq	a5,a4,80001fee <get_time_slice+0x24>
}
    80001fe8:	6422                	ld	s0,8(sp)
    80001fea:	0141                	addi	sp,sp,16
    80001fec:	8082                	ret
  switch (queue)
    80001fee:	4511                	li	a0,4
    80001ff0:	bfe5                	j	80001fe8 <get_time_slice+0x1e>
    return 8; // Priority 2 time slice
    80001ff2:	4521                	li	a0,8
    80001ff4:	bfd5                	j	80001fe8 <get_time_slice+0x1e>

0000000080001ff6 <scheduler>:
{
    80001ff6:	7139                	addi	sp,sp,-64
    80001ff8:	fc06                	sd	ra,56(sp)
    80001ffa:	f822                	sd	s0,48(sp)
    80001ffc:	f426                	sd	s1,40(sp)
    80001ffe:	f04a                	sd	s2,32(sp)
    80002000:	ec4e                	sd	s3,24(sp)
    80002002:	e852                	sd	s4,16(sp)
    80002004:	e456                	sd	s5,8(sp)
    80002006:	e05a                	sd	s6,0(sp)
    80002008:	0080                	addi	s0,sp,64
    8000200a:	8792                	mv	a5,tp
  int id = r_tp();
    8000200c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000200e:	00779a93          	slli	s5,a5,0x7
    80002012:	0000f717          	auipc	a4,0xf
    80002016:	b7e70713          	addi	a4,a4,-1154 # 80010b90 <pid_lock>
    8000201a:	9756                	add	a4,a4,s5
    8000201c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002020:	0000f717          	auipc	a4,0xf
    80002024:	ba870713          	addi	a4,a4,-1112 # 80010bc8 <cpus+0x8>
    80002028:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    8000202a:	498d                	li	s3,3
        p->state = RUNNING;
    8000202c:	4b11                	li	s6,4
        c->proc = p;
    8000202e:	079e                	slli	a5,a5,0x7
    80002030:	0000fa17          	auipc	s4,0xf
    80002034:	b60a0a13          	addi	s4,s4,-1184 # 80010b90 <pid_lock>
    80002038:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    8000203a:	0001c917          	auipc	s2,0x1c
    8000203e:	18690913          	addi	s2,s2,390 # 8001e1c0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002042:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002046:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000204a:	10079073          	csrw	sstatus,a5
    8000204e:	0000f497          	auipc	s1,0xf
    80002052:	f7248493          	addi	s1,s1,-142 # 80010fc0 <proc>
    80002056:	a811                	j	8000206a <scheduler+0x74>
      release(&p->lock);
    80002058:	8526                	mv	a0,s1
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	c30080e7          	jalr	-976(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002062:	34848493          	addi	s1,s1,840
    80002066:	fd248ee3          	beq	s1,s2,80002042 <scheduler+0x4c>
      acquire(&p->lock);
    8000206a:	8526                	mv	a0,s1
    8000206c:	fffff097          	auipc	ra,0xfffff
    80002070:	b6a080e7          	jalr	-1174(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80002074:	4c9c                	lw	a5,24(s1)
    80002076:	ff3791e3          	bne	a5,s3,80002058 <scheduler+0x62>
        p->state = RUNNING;
    8000207a:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000207e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002082:	06048593          	addi	a1,s1,96
    80002086:	8556                	mv	a0,s5
    80002088:	00001097          	auipc	ra,0x1
    8000208c:	83e080e7          	jalr	-1986(ra) # 800028c6 <swtch>
        c->proc = 0;
    80002090:	020a3823          	sd	zero,48(s4)
    80002094:	b7d1                	j	80002058 <scheduler+0x62>

0000000080002096 <sched>:
{
    80002096:	7179                	addi	sp,sp,-48
    80002098:	f406                	sd	ra,40(sp)
    8000209a:	f022                	sd	s0,32(sp)
    8000209c:	ec26                	sd	s1,24(sp)
    8000209e:	e84a                	sd	s2,16(sp)
    800020a0:	e44e                	sd	s3,8(sp)
    800020a2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	938080e7          	jalr	-1736(ra) # 800019dc <myproc>
    800020ac:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800020ae:	fffff097          	auipc	ra,0xfffff
    800020b2:	aae080e7          	jalr	-1362(ra) # 80000b5c <holding>
    800020b6:	c93d                	beqz	a0,8000212c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020b8:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800020ba:	2781                	sext.w	a5,a5
    800020bc:	079e                	slli	a5,a5,0x7
    800020be:	0000f717          	auipc	a4,0xf
    800020c2:	ad270713          	addi	a4,a4,-1326 # 80010b90 <pid_lock>
    800020c6:	97ba                	add	a5,a5,a4
    800020c8:	0a87a703          	lw	a4,168(a5)
    800020cc:	4785                	li	a5,1
    800020ce:	06f71763          	bne	a4,a5,8000213c <sched+0xa6>
  if (p->state == RUNNING)
    800020d2:	4c98                	lw	a4,24(s1)
    800020d4:	4791                	li	a5,4
    800020d6:	06f70b63          	beq	a4,a5,8000214c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020da:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020de:	8b89                	andi	a5,a5,2
  if (intr_get())
    800020e0:	efb5                	bnez	a5,8000215c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020e2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020e4:	0000f917          	auipc	s2,0xf
    800020e8:	aac90913          	addi	s2,s2,-1364 # 80010b90 <pid_lock>
    800020ec:	2781                	sext.w	a5,a5
    800020ee:	079e                	slli	a5,a5,0x7
    800020f0:	97ca                	add	a5,a5,s2
    800020f2:	0ac7a983          	lw	s3,172(a5)
    800020f6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020f8:	2781                	sext.w	a5,a5
    800020fa:	079e                	slli	a5,a5,0x7
    800020fc:	0000f597          	auipc	a1,0xf
    80002100:	acc58593          	addi	a1,a1,-1332 # 80010bc8 <cpus+0x8>
    80002104:	95be                	add	a1,a1,a5
    80002106:	06048513          	addi	a0,s1,96
    8000210a:	00000097          	auipc	ra,0x0
    8000210e:	7bc080e7          	jalr	1980(ra) # 800028c6 <swtch>
    80002112:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002114:	2781                	sext.w	a5,a5
    80002116:	079e                	slli	a5,a5,0x7
    80002118:	993e                	add	s2,s2,a5
    8000211a:	0b392623          	sw	s3,172(s2)
}
    8000211e:	70a2                	ld	ra,40(sp)
    80002120:	7402                	ld	s0,32(sp)
    80002122:	64e2                	ld	s1,24(sp)
    80002124:	6942                	ld	s2,16(sp)
    80002126:	69a2                	ld	s3,8(sp)
    80002128:	6145                	addi	sp,sp,48
    8000212a:	8082                	ret
    panic("sched p->lock");
    8000212c:	00006517          	auipc	a0,0x6
    80002130:	0ec50513          	addi	a0,a0,236 # 80008218 <digits+0x1d8>
    80002134:	ffffe097          	auipc	ra,0xffffe
    80002138:	40c080e7          	jalr	1036(ra) # 80000540 <panic>
    panic("sched locks");
    8000213c:	00006517          	auipc	a0,0x6
    80002140:	0ec50513          	addi	a0,a0,236 # 80008228 <digits+0x1e8>
    80002144:	ffffe097          	auipc	ra,0xffffe
    80002148:	3fc080e7          	jalr	1020(ra) # 80000540 <panic>
    panic("sched running");
    8000214c:	00006517          	auipc	a0,0x6
    80002150:	0ec50513          	addi	a0,a0,236 # 80008238 <digits+0x1f8>
    80002154:	ffffe097          	auipc	ra,0xffffe
    80002158:	3ec080e7          	jalr	1004(ra) # 80000540 <panic>
    panic("sched interruptible");
    8000215c:	00006517          	auipc	a0,0x6
    80002160:	0ec50513          	addi	a0,a0,236 # 80008248 <digits+0x208>
    80002164:	ffffe097          	auipc	ra,0xffffe
    80002168:	3dc080e7          	jalr	988(ra) # 80000540 <panic>

000000008000216c <yield>:
{
    8000216c:	1101                	addi	sp,sp,-32
    8000216e:	ec06                	sd	ra,24(sp)
    80002170:	e822                	sd	s0,16(sp)
    80002172:	e426                	sd	s1,8(sp)
    80002174:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002176:	00000097          	auipc	ra,0x0
    8000217a:	866080e7          	jalr	-1946(ra) # 800019dc <myproc>
    8000217e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	a56080e7          	jalr	-1450(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002188:	478d                	li	a5,3
    8000218a:	cc9c                	sw	a5,24(s1)
  sched();
    8000218c:	00000097          	auipc	ra,0x0
    80002190:	f0a080e7          	jalr	-246(ra) # 80002096 <sched>
  release(&p->lock);
    80002194:	8526                	mv	a0,s1
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	af4080e7          	jalr	-1292(ra) # 80000c8a <release>
}
    8000219e:	60e2                	ld	ra,24(sp)
    800021a0:	6442                	ld	s0,16(sp)
    800021a2:	64a2                	ld	s1,8(sp)
    800021a4:	6105                	addi	sp,sp,32
    800021a6:	8082                	ret

00000000800021a8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800021a8:	7179                	addi	sp,sp,-48
    800021aa:	f406                	sd	ra,40(sp)
    800021ac:	f022                	sd	s0,32(sp)
    800021ae:	ec26                	sd	s1,24(sp)
    800021b0:	e84a                	sd	s2,16(sp)
    800021b2:	e44e                	sd	s3,8(sp)
    800021b4:	1800                	addi	s0,sp,48
    800021b6:	89aa                	mv	s3,a0
    800021b8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021ba:	00000097          	auipc	ra,0x0
    800021be:	822080e7          	jalr	-2014(ra) # 800019dc <myproc>
    800021c2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	a12080e7          	jalr	-1518(ra) # 80000bd6 <acquire>
  release(lk);
    800021cc:	854a                	mv	a0,s2
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	abc080e7          	jalr	-1348(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800021d6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021da:	4789                	li	a5,2
    800021dc:	cc9c                	sw	a5,24(s1)

  sched();
    800021de:	00000097          	auipc	ra,0x0
    800021e2:	eb8080e7          	jalr	-328(ra) # 80002096 <sched>

  // Tidy up.
  p->chan = 0;
    800021e6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	a9e080e7          	jalr	-1378(ra) # 80000c8a <release>
  acquire(lk);
    800021f4:	854a                	mv	a0,s2
    800021f6:	fffff097          	auipc	ra,0xfffff
    800021fa:	9e0080e7          	jalr	-1568(ra) # 80000bd6 <acquire>
}
    800021fe:	70a2                	ld	ra,40(sp)
    80002200:	7402                	ld	s0,32(sp)
    80002202:	64e2                	ld	s1,24(sp)
    80002204:	6942                	ld	s2,16(sp)
    80002206:	69a2                	ld	s3,8(sp)
    80002208:	6145                	addi	sp,sp,48
    8000220a:	8082                	ret

000000008000220c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000220c:	7139                	addi	sp,sp,-64
    8000220e:	fc06                	sd	ra,56(sp)
    80002210:	f822                	sd	s0,48(sp)
    80002212:	f426                	sd	s1,40(sp)
    80002214:	f04a                	sd	s2,32(sp)
    80002216:	ec4e                	sd	s3,24(sp)
    80002218:	e852                	sd	s4,16(sp)
    8000221a:	e456                	sd	s5,8(sp)
    8000221c:	0080                	addi	s0,sp,64
    8000221e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002220:	0000f497          	auipc	s1,0xf
    80002224:	da048493          	addi	s1,s1,-608 # 80010fc0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002228:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    8000222a:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000222c:	0001c917          	auipc	s2,0x1c
    80002230:	f9490913          	addi	s2,s2,-108 # 8001e1c0 <tickslock>
    80002234:	a811                	j	80002248 <wakeup+0x3c>
      }
      release(&p->lock);
    80002236:	8526                	mv	a0,s1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	a52080e7          	jalr	-1454(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002240:	34848493          	addi	s1,s1,840
    80002244:	03248663          	beq	s1,s2,80002270 <wakeup+0x64>
    if (p != myproc())
    80002248:	fffff097          	auipc	ra,0xfffff
    8000224c:	794080e7          	jalr	1940(ra) # 800019dc <myproc>
    80002250:	fea488e3          	beq	s1,a0,80002240 <wakeup+0x34>
      acquire(&p->lock);
    80002254:	8526                	mv	a0,s1
    80002256:	fffff097          	auipc	ra,0xfffff
    8000225a:	980080e7          	jalr	-1664(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000225e:	4c9c                	lw	a5,24(s1)
    80002260:	fd379be3          	bne	a5,s3,80002236 <wakeup+0x2a>
    80002264:	709c                	ld	a5,32(s1)
    80002266:	fd4798e3          	bne	a5,s4,80002236 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000226a:	0154ac23          	sw	s5,24(s1)
    8000226e:	b7e1                	j	80002236 <wakeup+0x2a>
    }
  }
}
    80002270:	70e2                	ld	ra,56(sp)
    80002272:	7442                	ld	s0,48(sp)
    80002274:	74a2                	ld	s1,40(sp)
    80002276:	7902                	ld	s2,32(sp)
    80002278:	69e2                	ld	s3,24(sp)
    8000227a:	6a42                	ld	s4,16(sp)
    8000227c:	6aa2                	ld	s5,8(sp)
    8000227e:	6121                	addi	sp,sp,64
    80002280:	8082                	ret

0000000080002282 <reparent>:
{
    80002282:	7179                	addi	sp,sp,-48
    80002284:	f406                	sd	ra,40(sp)
    80002286:	f022                	sd	s0,32(sp)
    80002288:	ec26                	sd	s1,24(sp)
    8000228a:	e84a                	sd	s2,16(sp)
    8000228c:	e44e                	sd	s3,8(sp)
    8000228e:	e052                	sd	s4,0(sp)
    80002290:	1800                	addi	s0,sp,48
    80002292:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002294:	0000f497          	auipc	s1,0xf
    80002298:	d2c48493          	addi	s1,s1,-724 # 80010fc0 <proc>
      pp->parent = initproc;
    8000229c:	00006a17          	auipc	s4,0x6
    800022a0:	684a0a13          	addi	s4,s4,1668 # 80008920 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800022a4:	0001c997          	auipc	s3,0x1c
    800022a8:	f1c98993          	addi	s3,s3,-228 # 8001e1c0 <tickslock>
    800022ac:	a029                	j	800022b6 <reparent+0x34>
    800022ae:	34848493          	addi	s1,s1,840
    800022b2:	01348d63          	beq	s1,s3,800022cc <reparent+0x4a>
    if (pp->parent == p)
    800022b6:	7c9c                	ld	a5,56(s1)
    800022b8:	ff279be3          	bne	a5,s2,800022ae <reparent+0x2c>
      pp->parent = initproc;
    800022bc:	000a3503          	ld	a0,0(s4)
    800022c0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022c2:	00000097          	auipc	ra,0x0
    800022c6:	f4a080e7          	jalr	-182(ra) # 8000220c <wakeup>
    800022ca:	b7d5                	j	800022ae <reparent+0x2c>
}
    800022cc:	70a2                	ld	ra,40(sp)
    800022ce:	7402                	ld	s0,32(sp)
    800022d0:	64e2                	ld	s1,24(sp)
    800022d2:	6942                	ld	s2,16(sp)
    800022d4:	69a2                	ld	s3,8(sp)
    800022d6:	6a02                	ld	s4,0(sp)
    800022d8:	6145                	addi	sp,sp,48
    800022da:	8082                	ret

00000000800022dc <exit>:
{
    800022dc:	7179                	addi	sp,sp,-48
    800022de:	f406                	sd	ra,40(sp)
    800022e0:	f022                	sd	s0,32(sp)
    800022e2:	ec26                	sd	s1,24(sp)
    800022e4:	e84a                	sd	s2,16(sp)
    800022e6:	e44e                	sd	s3,8(sp)
    800022e8:	e052                	sd	s4,0(sp)
    800022ea:	1800                	addi	s0,sp,48
    800022ec:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	6ee080e7          	jalr	1774(ra) # 800019dc <myproc>
    800022f6:	89aa                	mv	s3,a0
  if (p == initproc)
    800022f8:	00006797          	auipc	a5,0x6
    800022fc:	6287b783          	ld	a5,1576(a5) # 80008920 <initproc>
    80002300:	0d050493          	addi	s1,a0,208
    80002304:	15050913          	addi	s2,a0,336
    80002308:	02a79363          	bne	a5,a0,8000232e <exit+0x52>
    panic("init exiting");
    8000230c:	00006517          	auipc	a0,0x6
    80002310:	f5450513          	addi	a0,a0,-172 # 80008260 <digits+0x220>
    80002314:	ffffe097          	auipc	ra,0xffffe
    80002318:	22c080e7          	jalr	556(ra) # 80000540 <panic>
      fileclose(f);
    8000231c:	00002097          	auipc	ra,0x2
    80002320:	778080e7          	jalr	1912(ra) # 80004a94 <fileclose>
      p->ofile[fd] = 0;
    80002324:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002328:	04a1                	addi	s1,s1,8
    8000232a:	01248563          	beq	s1,s2,80002334 <exit+0x58>
    if (p->ofile[fd])
    8000232e:	6088                	ld	a0,0(s1)
    80002330:	f575                	bnez	a0,8000231c <exit+0x40>
    80002332:	bfdd                	j	80002328 <exit+0x4c>
  begin_op();
    80002334:	00002097          	auipc	ra,0x2
    80002338:	298080e7          	jalr	664(ra) # 800045cc <begin_op>
  iput(p->cwd);
    8000233c:	1509b503          	ld	a0,336(s3)
    80002340:	00002097          	auipc	ra,0x2
    80002344:	a7a080e7          	jalr	-1414(ra) # 80003dba <iput>
  end_op();
    80002348:	00002097          	auipc	ra,0x2
    8000234c:	302080e7          	jalr	770(ra) # 8000464a <end_op>
  p->cwd = 0;
    80002350:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002354:	0000f497          	auipc	s1,0xf
    80002358:	85448493          	addi	s1,s1,-1964 # 80010ba8 <wait_lock>
    8000235c:	8526                	mv	a0,s1
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	878080e7          	jalr	-1928(ra) # 80000bd6 <acquire>
  reparent(p);
    80002366:	854e                	mv	a0,s3
    80002368:	00000097          	auipc	ra,0x0
    8000236c:	f1a080e7          	jalr	-230(ra) # 80002282 <reparent>
  wakeup(p->parent);
    80002370:	0389b503          	ld	a0,56(s3)
    80002374:	00000097          	auipc	ra,0x0
    80002378:	e98080e7          	jalr	-360(ra) # 8000220c <wakeup>
  acquire(&p->lock);
    8000237c:	854e                	mv	a0,s3
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	858080e7          	jalr	-1960(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002386:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000238a:	4795                	li	a5,5
    8000238c:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002390:	00006797          	auipc	a5,0x6
    80002394:	59c7a783          	lw	a5,1436(a5) # 8000892c <ticks>
    80002398:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000239c:	8526                	mv	a0,s1
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	8ec080e7          	jalr	-1812(ra) # 80000c8a <release>
  sched();
    800023a6:	00000097          	auipc	ra,0x0
    800023aa:	cf0080e7          	jalr	-784(ra) # 80002096 <sched>
  panic("zombie exit");
    800023ae:	00006517          	auipc	a0,0x6
    800023b2:	ec250513          	addi	a0,a0,-318 # 80008270 <digits+0x230>
    800023b6:	ffffe097          	auipc	ra,0xffffe
    800023ba:	18a080e7          	jalr	394(ra) # 80000540 <panic>

00000000800023be <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800023be:	7179                	addi	sp,sp,-48
    800023c0:	f406                	sd	ra,40(sp)
    800023c2:	f022                	sd	s0,32(sp)
    800023c4:	ec26                	sd	s1,24(sp)
    800023c6:	e84a                	sd	s2,16(sp)
    800023c8:	e44e                	sd	s3,8(sp)
    800023ca:	1800                	addi	s0,sp,48
    800023cc:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023ce:	0000f497          	auipc	s1,0xf
    800023d2:	bf248493          	addi	s1,s1,-1038 # 80010fc0 <proc>
    800023d6:	0001c997          	auipc	s3,0x1c
    800023da:	dea98993          	addi	s3,s3,-534 # 8001e1c0 <tickslock>
  {
    acquire(&p->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	ffffe097          	auipc	ra,0xffffe
    800023e4:	7f6080e7          	jalr	2038(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    800023e8:	589c                	lw	a5,48(s1)
    800023ea:	01278d63          	beq	a5,s2,80002404 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023ee:	8526                	mv	a0,s1
    800023f0:	fffff097          	auipc	ra,0xfffff
    800023f4:	89a080e7          	jalr	-1894(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023f8:	34848493          	addi	s1,s1,840
    800023fc:	ff3491e3          	bne	s1,s3,800023de <kill+0x20>
  }
  return -1;
    80002400:	557d                	li	a0,-1
    80002402:	a829                	j	8000241c <kill+0x5e>
      p->killed = 1;
    80002404:	4785                	li	a5,1
    80002406:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002408:	4c98                	lw	a4,24(s1)
    8000240a:	4789                	li	a5,2
    8000240c:	00f70f63          	beq	a4,a5,8000242a <kill+0x6c>
      release(&p->lock);
    80002410:	8526                	mv	a0,s1
    80002412:	fffff097          	auipc	ra,0xfffff
    80002416:	878080e7          	jalr	-1928(ra) # 80000c8a <release>
      return 0;
    8000241a:	4501                	li	a0,0
}
    8000241c:	70a2                	ld	ra,40(sp)
    8000241e:	7402                	ld	s0,32(sp)
    80002420:	64e2                	ld	s1,24(sp)
    80002422:	6942                	ld	s2,16(sp)
    80002424:	69a2                	ld	s3,8(sp)
    80002426:	6145                	addi	sp,sp,48
    80002428:	8082                	ret
        p->state = RUNNABLE;
    8000242a:	478d                	li	a5,3
    8000242c:	cc9c                	sw	a5,24(s1)
    8000242e:	b7cd                	j	80002410 <kill+0x52>

0000000080002430 <setkilled>:

void setkilled(struct proc *p)
{
    80002430:	1101                	addi	sp,sp,-32
    80002432:	ec06                	sd	ra,24(sp)
    80002434:	e822                	sd	s0,16(sp)
    80002436:	e426                	sd	s1,8(sp)
    80002438:	1000                	addi	s0,sp,32
    8000243a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000243c:	ffffe097          	auipc	ra,0xffffe
    80002440:	79a080e7          	jalr	1946(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002444:	4785                	li	a5,1
    80002446:	d49c                	sw	a5,40(s1)

  release(&p->lock);
    80002448:	8526                	mv	a0,s1
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	840080e7          	jalr	-1984(ra) # 80000c8a <release>
}
    80002452:	60e2                	ld	ra,24(sp)
    80002454:	6442                	ld	s0,16(sp)
    80002456:	64a2                	ld	s1,8(sp)
    80002458:	6105                	addi	sp,sp,32
    8000245a:	8082                	ret

000000008000245c <killed>:

int killed(struct proc *p)
{
    8000245c:	1101                	addi	sp,sp,-32
    8000245e:	ec06                	sd	ra,24(sp)
    80002460:	e822                	sd	s0,16(sp)
    80002462:	e426                	sd	s1,8(sp)
    80002464:	e04a                	sd	s2,0(sp)
    80002466:	1000                	addi	s0,sp,32
    80002468:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000246a:	ffffe097          	auipc	ra,0xffffe
    8000246e:	76c080e7          	jalr	1900(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002472:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002476:	8526                	mv	a0,s1
    80002478:	fffff097          	auipc	ra,0xfffff
    8000247c:	812080e7          	jalr	-2030(ra) # 80000c8a <release>
  return k;
}
    80002480:	854a                	mv	a0,s2
    80002482:	60e2                	ld	ra,24(sp)
    80002484:	6442                	ld	s0,16(sp)
    80002486:	64a2                	ld	s1,8(sp)
    80002488:	6902                	ld	s2,0(sp)
    8000248a:	6105                	addi	sp,sp,32
    8000248c:	8082                	ret

000000008000248e <wait>:
{
    8000248e:	715d                	addi	sp,sp,-80
    80002490:	e486                	sd	ra,72(sp)
    80002492:	e0a2                	sd	s0,64(sp)
    80002494:	fc26                	sd	s1,56(sp)
    80002496:	f84a                	sd	s2,48(sp)
    80002498:	f44e                	sd	s3,40(sp)
    8000249a:	f052                	sd	s4,32(sp)
    8000249c:	ec56                	sd	s5,24(sp)
    8000249e:	e85a                	sd	s6,16(sp)
    800024a0:	e45e                	sd	s7,8(sp)
    800024a2:	e062                	sd	s8,0(sp)
    800024a4:	0880                	addi	s0,sp,80
    800024a6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024a8:	fffff097          	auipc	ra,0xfffff
    800024ac:	534080e7          	jalr	1332(ra) # 800019dc <myproc>
    800024b0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024b2:	0000e517          	auipc	a0,0xe
    800024b6:	6f650513          	addi	a0,a0,1782 # 80010ba8 <wait_lock>
    800024ba:	ffffe097          	auipc	ra,0xffffe
    800024be:	71c080e7          	jalr	1820(ra) # 80000bd6 <acquire>
    havekids = 0;
    800024c2:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800024c4:	4a15                	li	s4,5
        havekids = 1;
    800024c6:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024c8:	0001c997          	auipc	s3,0x1c
    800024cc:	cf898993          	addi	s3,s3,-776 # 8001e1c0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024d0:	0000ec17          	auipc	s8,0xe
    800024d4:	6d8c0c13          	addi	s8,s8,1752 # 80010ba8 <wait_lock>
    havekids = 0;
    800024d8:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024da:	0000f497          	auipc	s1,0xf
    800024de:	ae648493          	addi	s1,s1,-1306 # 80010fc0 <proc>
    800024e2:	a0bd                	j	80002550 <wait+0xc2>
          pid = pp->pid;
    800024e4:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024e8:	000b0e63          	beqz	s6,80002504 <wait+0x76>
    800024ec:	4691                	li	a3,4
    800024ee:	02c48613          	addi	a2,s1,44
    800024f2:	85da                	mv	a1,s6
    800024f4:	05093503          	ld	a0,80(s2)
    800024f8:	fffff097          	auipc	ra,0xfffff
    800024fc:	174080e7          	jalr	372(ra) # 8000166c <copyout>
    80002500:	02054563          	bltz	a0,8000252a <wait+0x9c>
          freeproc(pp);
    80002504:	8526                	mv	a0,s1
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	688080e7          	jalr	1672(ra) # 80001b8e <freeproc>
          release(&pp->lock);
    8000250e:	8526                	mv	a0,s1
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	77a080e7          	jalr	1914(ra) # 80000c8a <release>
          release(&wait_lock);
    80002518:	0000e517          	auipc	a0,0xe
    8000251c:	69050513          	addi	a0,a0,1680 # 80010ba8 <wait_lock>
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	76a080e7          	jalr	1898(ra) # 80000c8a <release>
          return pid;
    80002528:	a0b5                	j	80002594 <wait+0x106>
            release(&pp->lock);
    8000252a:	8526                	mv	a0,s1
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	75e080e7          	jalr	1886(ra) # 80000c8a <release>
            release(&wait_lock);
    80002534:	0000e517          	auipc	a0,0xe
    80002538:	67450513          	addi	a0,a0,1652 # 80010ba8 <wait_lock>
    8000253c:	ffffe097          	auipc	ra,0xffffe
    80002540:	74e080e7          	jalr	1870(ra) # 80000c8a <release>
            return -1;
    80002544:	59fd                	li	s3,-1
    80002546:	a0b9                	j	80002594 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002548:	34848493          	addi	s1,s1,840
    8000254c:	03348463          	beq	s1,s3,80002574 <wait+0xe6>
      if (pp->parent == p)
    80002550:	7c9c                	ld	a5,56(s1)
    80002552:	ff279be3          	bne	a5,s2,80002548 <wait+0xba>
        acquire(&pp->lock);
    80002556:	8526                	mv	a0,s1
    80002558:	ffffe097          	auipc	ra,0xffffe
    8000255c:	67e080e7          	jalr	1662(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    80002560:	4c9c                	lw	a5,24(s1)
    80002562:	f94781e3          	beq	a5,s4,800024e4 <wait+0x56>
        release(&pp->lock);
    80002566:	8526                	mv	a0,s1
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	722080e7          	jalr	1826(ra) # 80000c8a <release>
        havekids = 1;
    80002570:	8756                	mv	a4,s5
    80002572:	bfd9                	j	80002548 <wait+0xba>
    if (!havekids || killed(p))
    80002574:	c719                	beqz	a4,80002582 <wait+0xf4>
    80002576:	854a                	mv	a0,s2
    80002578:	00000097          	auipc	ra,0x0
    8000257c:	ee4080e7          	jalr	-284(ra) # 8000245c <killed>
    80002580:	c51d                	beqz	a0,800025ae <wait+0x120>
      release(&wait_lock);
    80002582:	0000e517          	auipc	a0,0xe
    80002586:	62650513          	addi	a0,a0,1574 # 80010ba8 <wait_lock>
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	700080e7          	jalr	1792(ra) # 80000c8a <release>
      return -1;
    80002592:	59fd                	li	s3,-1
}
    80002594:	854e                	mv	a0,s3
    80002596:	60a6                	ld	ra,72(sp)
    80002598:	6406                	ld	s0,64(sp)
    8000259a:	74e2                	ld	s1,56(sp)
    8000259c:	7942                	ld	s2,48(sp)
    8000259e:	79a2                	ld	s3,40(sp)
    800025a0:	7a02                	ld	s4,32(sp)
    800025a2:	6ae2                	ld	s5,24(sp)
    800025a4:	6b42                	ld	s6,16(sp)
    800025a6:	6ba2                	ld	s7,8(sp)
    800025a8:	6c02                	ld	s8,0(sp)
    800025aa:	6161                	addi	sp,sp,80
    800025ac:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800025ae:	85e2                	mv	a1,s8
    800025b0:	854a                	mv	a0,s2
    800025b2:	00000097          	auipc	ra,0x0
    800025b6:	bf6080e7          	jalr	-1034(ra) # 800021a8 <sleep>
    havekids = 0;
    800025ba:	bf39                	j	800024d8 <wait+0x4a>

00000000800025bc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.

int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025bc:	7179                	addi	sp,sp,-48
    800025be:	f406                	sd	ra,40(sp)
    800025c0:	f022                	sd	s0,32(sp)
    800025c2:	ec26                	sd	s1,24(sp)
    800025c4:	e84a                	sd	s2,16(sp)
    800025c6:	e44e                	sd	s3,8(sp)
    800025c8:	e052                	sd	s4,0(sp)
    800025ca:	1800                	addi	s0,sp,48
    800025cc:	84aa                	mv	s1,a0
    800025ce:	892e                	mv	s2,a1
    800025d0:	89b2                	mv	s3,a2
    800025d2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025d4:	fffff097          	auipc	ra,0xfffff
    800025d8:	408080e7          	jalr	1032(ra) # 800019dc <myproc>
  if (user_dst)
    800025dc:	c08d                	beqz	s1,800025fe <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800025de:	86d2                	mv	a3,s4
    800025e0:	864e                	mv	a2,s3
    800025e2:	85ca                	mv	a1,s2
    800025e4:	6928                	ld	a0,80(a0)
    800025e6:	fffff097          	auipc	ra,0xfffff
    800025ea:	086080e7          	jalr	134(ra) # 8000166c <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025ee:	70a2                	ld	ra,40(sp)
    800025f0:	7402                	ld	s0,32(sp)
    800025f2:	64e2                	ld	s1,24(sp)
    800025f4:	6942                	ld	s2,16(sp)
    800025f6:	69a2                	ld	s3,8(sp)
    800025f8:	6a02                	ld	s4,0(sp)
    800025fa:	6145                	addi	sp,sp,48
    800025fc:	8082                	ret
    memmove((char *)dst, src, len);
    800025fe:	000a061b          	sext.w	a2,s4
    80002602:	85ce                	mv	a1,s3
    80002604:	854a                	mv	a0,s2
    80002606:	ffffe097          	auipc	ra,0xffffe
    8000260a:	728080e7          	jalr	1832(ra) # 80000d2e <memmove>
    return 0;
    8000260e:	8526                	mv	a0,s1
    80002610:	bff9                	j	800025ee <either_copyout+0x32>

0000000080002612 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.

int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002612:	7179                	addi	sp,sp,-48
    80002614:	f406                	sd	ra,40(sp)
    80002616:	f022                	sd	s0,32(sp)
    80002618:	ec26                	sd	s1,24(sp)
    8000261a:	e84a                	sd	s2,16(sp)
    8000261c:	e44e                	sd	s3,8(sp)
    8000261e:	e052                	sd	s4,0(sp)
    80002620:	1800                	addi	s0,sp,48
    80002622:	892a                	mv	s2,a0
    80002624:	84ae                	mv	s1,a1
    80002626:	89b2                	mv	s3,a2
    80002628:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000262a:	fffff097          	auipc	ra,0xfffff
    8000262e:	3b2080e7          	jalr	946(ra) # 800019dc <myproc>
  if (user_src)
    80002632:	c08d                	beqz	s1,80002654 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002634:	86d2                	mv	a3,s4
    80002636:	864e                	mv	a2,s3
    80002638:	85ca                	mv	a1,s2
    8000263a:	6928                	ld	a0,80(a0)
    8000263c:	fffff097          	auipc	ra,0xfffff
    80002640:	0bc080e7          	jalr	188(ra) # 800016f8 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002644:	70a2                	ld	ra,40(sp)
    80002646:	7402                	ld	s0,32(sp)
    80002648:	64e2                	ld	s1,24(sp)
    8000264a:	6942                	ld	s2,16(sp)
    8000264c:	69a2                	ld	s3,8(sp)
    8000264e:	6a02                	ld	s4,0(sp)
    80002650:	6145                	addi	sp,sp,48
    80002652:	8082                	ret
    memmove(dst, (char *)src, len);
    80002654:	000a061b          	sext.w	a2,s4
    80002658:	85ce                	mv	a1,s3
    8000265a:	854a                	mv	a0,s2
    8000265c:	ffffe097          	auipc	ra,0xffffe
    80002660:	6d2080e7          	jalr	1746(ra) # 80000d2e <memmove>
    return 0;
    80002664:	8526                	mv	a0,s1
    80002666:	bff9                	j	80002644 <either_copyin+0x32>

0000000080002668 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002668:	715d                	addi	sp,sp,-80
    8000266a:	e486                	sd	ra,72(sp)
    8000266c:	e0a2                	sd	s0,64(sp)
    8000266e:	fc26                	sd	s1,56(sp)
    80002670:	f84a                	sd	s2,48(sp)
    80002672:	f44e                	sd	s3,40(sp)
    80002674:	f052                	sd	s4,32(sp)
    80002676:	ec56                	sd	s5,24(sp)
    80002678:	e85a                	sd	s6,16(sp)
    8000267a:	e45e                	sd	s7,8(sp)
    8000267c:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000267e:	00006517          	auipc	a0,0x6
    80002682:	a4a50513          	addi	a0,a0,-1462 # 800080c8 <digits+0x88>
    80002686:	ffffe097          	auipc	ra,0xffffe
    8000268a:	f04080e7          	jalr	-252(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000268e:	0000f497          	auipc	s1,0xf
    80002692:	a8a48493          	addi	s1,s1,-1398 # 80011118 <proc+0x158>
    80002696:	0001c917          	auipc	s2,0x1c
    8000269a:	c8290913          	addi	s2,s2,-894 # 8001e318 <bcache+0xc0>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000269e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800026a0:	00006997          	auipc	s3,0x6
    800026a4:	be098993          	addi	s3,s3,-1056 # 80008280 <digits+0x240>
    printf("%d %s %s %d", p->pid, state, p->name, p->ticket);
    800026a8:	00006a97          	auipc	s5,0x6
    800026ac:	be0a8a93          	addi	s5,s5,-1056 # 80008288 <digits+0x248>
    printf("\n");
    800026b0:	00006a17          	auipc	s4,0x6
    800026b4:	a18a0a13          	addi	s4,s4,-1512 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b8:	00006b97          	auipc	s7,0x6
    800026bc:	c10b8b93          	addi	s7,s7,-1008 # 800082c8 <states.0>
    800026c0:	a01d                	j	800026e6 <procdump+0x7e>
    printf("%d %s %s %d", p->pid, state, p->name, p->ticket);
    800026c2:	1d86a703          	lw	a4,472(a3)
    800026c6:	ed86a583          	lw	a1,-296(a3)
    800026ca:	8556                	mv	a0,s5
    800026cc:	ffffe097          	auipc	ra,0xffffe
    800026d0:	ebe080e7          	jalr	-322(ra) # 8000058a <printf>
    printf("\n");
    800026d4:	8552                	mv	a0,s4
    800026d6:	ffffe097          	auipc	ra,0xffffe
    800026da:	eb4080e7          	jalr	-332(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026de:	34848493          	addi	s1,s1,840
    800026e2:	03248263          	beq	s1,s2,80002706 <procdump+0x9e>
    if (p->state == UNUSED)
    800026e6:	86a6                	mv	a3,s1
    800026e8:	ec04a783          	lw	a5,-320(s1)
    800026ec:	dbed                	beqz	a5,800026de <procdump+0x76>
      state = "???";
    800026ee:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026f0:	fcfb69e3          	bltu	s6,a5,800026c2 <procdump+0x5a>
    800026f4:	02079713          	slli	a4,a5,0x20
    800026f8:	01d75793          	srli	a5,a4,0x1d
    800026fc:	97de                	add	a5,a5,s7
    800026fe:	6390                	ld	a2,0(a5)
    80002700:	f269                	bnez	a2,800026c2 <procdump+0x5a>
      state = "???";
    80002702:	864e                	mv	a2,s3
    80002704:	bf7d                	j	800026c2 <procdump+0x5a>
  }
}
    80002706:	60a6                	ld	ra,72(sp)
    80002708:	6406                	ld	s0,64(sp)
    8000270a:	74e2                	ld	s1,56(sp)
    8000270c:	7942                	ld	s2,48(sp)
    8000270e:	79a2                	ld	s3,40(sp)
    80002710:	7a02                	ld	s4,32(sp)
    80002712:	6ae2                	ld	s5,24(sp)
    80002714:	6b42                	ld	s6,16(sp)
    80002716:	6ba2                	ld	s7,8(sp)
    80002718:	6161                	addi	sp,sp,80
    8000271a:	8082                	ret

000000008000271c <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    8000271c:	711d                	addi	sp,sp,-96
    8000271e:	ec86                	sd	ra,88(sp)
    80002720:	e8a2                	sd	s0,80(sp)
    80002722:	e4a6                	sd	s1,72(sp)
    80002724:	e0ca                	sd	s2,64(sp)
    80002726:	fc4e                	sd	s3,56(sp)
    80002728:	f852                	sd	s4,48(sp)
    8000272a:	f456                	sd	s5,40(sp)
    8000272c:	f05a                	sd	s6,32(sp)
    8000272e:	ec5e                	sd	s7,24(sp)
    80002730:	e862                	sd	s8,16(sp)
    80002732:	e466                	sd	s9,8(sp)
    80002734:	e06a                	sd	s10,0(sp)
    80002736:	1080                	addi	s0,sp,96
    80002738:	8b2a                	mv	s6,a0
    8000273a:	8bae                	mv	s7,a1
    8000273c:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000273e:	fffff097          	auipc	ra,0xfffff
    80002742:	29e080e7          	jalr	670(ra) # 800019dc <myproc>
    80002746:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002748:	0000e517          	auipc	a0,0xe
    8000274c:	46050513          	addi	a0,a0,1120 # 80010ba8 <wait_lock>
    80002750:	ffffe097          	auipc	ra,0xffffe
    80002754:	486080e7          	jalr	1158(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    80002758:	4c81                	li	s9,0
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;

        if (np->state == ZOMBIE)
    8000275a:	4a15                	li	s4,5
        havekids = 1;
    8000275c:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    8000275e:	0001c997          	auipc	s3,0x1c
    80002762:	a6298993          	addi	s3,s3,-1438 # 8001e1c0 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002766:	0000ed17          	auipc	s10,0xe
    8000276a:	442d0d13          	addi	s10,s10,1090 # 80010ba8 <wait_lock>
    havekids = 0;
    8000276e:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002770:	0000f497          	auipc	s1,0xf
    80002774:	85048493          	addi	s1,s1,-1968 # 80010fc0 <proc>
    80002778:	a059                	j	800027fe <waitx+0xe2>
          pid = np->pid;
    8000277a:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000277e:	1684a783          	lw	a5,360(s1)
    80002782:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002786:	16c4a703          	lw	a4,364(s1)
    8000278a:	9f3d                	addw	a4,a4,a5
    8000278c:	1704a783          	lw	a5,368(s1)
    80002790:	9f99                	subw	a5,a5,a4
    80002792:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002796:	000b0e63          	beqz	s6,800027b2 <waitx+0x96>
    8000279a:	4691                	li	a3,4
    8000279c:	02c48613          	addi	a2,s1,44
    800027a0:	85da                	mv	a1,s6
    800027a2:	05093503          	ld	a0,80(s2)
    800027a6:	fffff097          	auipc	ra,0xfffff
    800027aa:	ec6080e7          	jalr	-314(ra) # 8000166c <copyout>
    800027ae:	02054563          	bltz	a0,800027d8 <waitx+0xbc>
          freeproc(np);
    800027b2:	8526                	mv	a0,s1
    800027b4:	fffff097          	auipc	ra,0xfffff
    800027b8:	3da080e7          	jalr	986(ra) # 80001b8e <freeproc>
          release(&np->lock);
    800027bc:	8526                	mv	a0,s1
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	4cc080e7          	jalr	1228(ra) # 80000c8a <release>
          release(&wait_lock);
    800027c6:	0000e517          	auipc	a0,0xe
    800027ca:	3e250513          	addi	a0,a0,994 # 80010ba8 <wait_lock>
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	4bc080e7          	jalr	1212(ra) # 80000c8a <release>
          return pid;
    800027d6:	a09d                	j	8000283c <waitx+0x120>
            release(&np->lock);
    800027d8:	8526                	mv	a0,s1
    800027da:	ffffe097          	auipc	ra,0xffffe
    800027de:	4b0080e7          	jalr	1200(ra) # 80000c8a <release>
            release(&wait_lock);
    800027e2:	0000e517          	auipc	a0,0xe
    800027e6:	3c650513          	addi	a0,a0,966 # 80010ba8 <wait_lock>
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	4a0080e7          	jalr	1184(ra) # 80000c8a <release>
            return -1;
    800027f2:	59fd                	li	s3,-1
    800027f4:	a0a1                	j	8000283c <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    800027f6:	34848493          	addi	s1,s1,840
    800027fa:	03348463          	beq	s1,s3,80002822 <waitx+0x106>
      if (np->parent == p)
    800027fe:	7c9c                	ld	a5,56(s1)
    80002800:	ff279be3          	bne	a5,s2,800027f6 <waitx+0xda>
        acquire(&np->lock);
    80002804:	8526                	mv	a0,s1
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	3d0080e7          	jalr	976(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    8000280e:	4c9c                	lw	a5,24(s1)
    80002810:	f74785e3          	beq	a5,s4,8000277a <waitx+0x5e>
        release(&np->lock);
    80002814:	8526                	mv	a0,s1
    80002816:	ffffe097          	auipc	ra,0xffffe
    8000281a:	474080e7          	jalr	1140(ra) # 80000c8a <release>
        havekids = 1;
    8000281e:	8756                	mv	a4,s5
    80002820:	bfd9                	j	800027f6 <waitx+0xda>
    if (!havekids || p->killed)
    80002822:	c701                	beqz	a4,8000282a <waitx+0x10e>
    80002824:	02892783          	lw	a5,40(s2)
    80002828:	cb8d                	beqz	a5,8000285a <waitx+0x13e>
      release(&wait_lock);
    8000282a:	0000e517          	auipc	a0,0xe
    8000282e:	37e50513          	addi	a0,a0,894 # 80010ba8 <wait_lock>
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	458080e7          	jalr	1112(ra) # 80000c8a <release>
      return -1;
    8000283a:	59fd                	li	s3,-1
  }
}
    8000283c:	854e                	mv	a0,s3
    8000283e:	60e6                	ld	ra,88(sp)
    80002840:	6446                	ld	s0,80(sp)
    80002842:	64a6                	ld	s1,72(sp)
    80002844:	6906                	ld	s2,64(sp)
    80002846:	79e2                	ld	s3,56(sp)
    80002848:	7a42                	ld	s4,48(sp)
    8000284a:	7aa2                	ld	s5,40(sp)
    8000284c:	7b02                	ld	s6,32(sp)
    8000284e:	6be2                	ld	s7,24(sp)
    80002850:	6c42                	ld	s8,16(sp)
    80002852:	6ca2                	ld	s9,8(sp)
    80002854:	6d02                	ld	s10,0(sp)
    80002856:	6125                	addi	sp,sp,96
    80002858:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000285a:	85ea                	mv	a1,s10
    8000285c:	854a                	mv	a0,s2
    8000285e:	00000097          	auipc	ra,0x0
    80002862:	94a080e7          	jalr	-1718(ra) # 800021a8 <sleep>
    havekids = 0;
    80002866:	b721                	j	8000276e <waitx+0x52>

0000000080002868 <update_time>:

void update_time()
{
    80002868:	7179                	addi	sp,sp,-48
    8000286a:	f406                	sd	ra,40(sp)
    8000286c:	f022                	sd	s0,32(sp)
    8000286e:	ec26                	sd	s1,24(sp)
    80002870:	e84a                	sd	s2,16(sp)
    80002872:	e44e                	sd	s3,8(sp)
    80002874:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002876:	0000e497          	auipc	s1,0xe
    8000287a:	74a48493          	addi	s1,s1,1866 # 80010fc0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    8000287e:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002880:	0001c917          	auipc	s2,0x1c
    80002884:	94090913          	addi	s2,s2,-1728 # 8001e1c0 <tickslock>
    80002888:	a811                	j	8000289c <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    8000288a:	8526                	mv	a0,s1
    8000288c:	ffffe097          	auipc	ra,0xffffe
    80002890:	3fe080e7          	jalr	1022(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002894:	34848493          	addi	s1,s1,840
    80002898:	03248063          	beq	s1,s2,800028b8 <update_time+0x50>
    acquire(&p->lock);
    8000289c:	8526                	mv	a0,s1
    8000289e:	ffffe097          	auipc	ra,0xffffe
    800028a2:	338080e7          	jalr	824(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    800028a6:	4c9c                	lw	a5,24(s1)
    800028a8:	ff3791e3          	bne	a5,s3,8000288a <update_time+0x22>
      p->rtime++;
    800028ac:	1684a783          	lw	a5,360(s1)
    800028b0:	2785                	addiw	a5,a5,1
    800028b2:	16f4a423          	sw	a5,360(s1)
    800028b6:	bfd1                	j	8000288a <update_time+0x22>
  //     continue;
  //   if (p->state == RUNNING || p->state == RUNNABLE)
  //     printf("GRAPH %d %d %d %d\n", p->pid, ticks, p->priority, p->state);
  // }
#endif
    800028b8:	70a2                	ld	ra,40(sp)
    800028ba:	7402                	ld	s0,32(sp)
    800028bc:	64e2                	ld	s1,24(sp)
    800028be:	6942                	ld	s2,16(sp)
    800028c0:	69a2                	ld	s3,8(sp)
    800028c2:	6145                	addi	sp,sp,48
    800028c4:	8082                	ret

00000000800028c6 <swtch>:
    800028c6:	00153023          	sd	ra,0(a0)
    800028ca:	00253423          	sd	sp,8(a0)
    800028ce:	e900                	sd	s0,16(a0)
    800028d0:	ed04                	sd	s1,24(a0)
    800028d2:	03253023          	sd	s2,32(a0)
    800028d6:	03353423          	sd	s3,40(a0)
    800028da:	03453823          	sd	s4,48(a0)
    800028de:	03553c23          	sd	s5,56(a0)
    800028e2:	05653023          	sd	s6,64(a0)
    800028e6:	05753423          	sd	s7,72(a0)
    800028ea:	05853823          	sd	s8,80(a0)
    800028ee:	05953c23          	sd	s9,88(a0)
    800028f2:	07a53023          	sd	s10,96(a0)
    800028f6:	07b53423          	sd	s11,104(a0)
    800028fa:	0005b083          	ld	ra,0(a1)
    800028fe:	0085b103          	ld	sp,8(a1)
    80002902:	6980                	ld	s0,16(a1)
    80002904:	6d84                	ld	s1,24(a1)
    80002906:	0205b903          	ld	s2,32(a1)
    8000290a:	0285b983          	ld	s3,40(a1)
    8000290e:	0305ba03          	ld	s4,48(a1)
    80002912:	0385ba83          	ld	s5,56(a1)
    80002916:	0405bb03          	ld	s6,64(a1)
    8000291a:	0485bb83          	ld	s7,72(a1)
    8000291e:	0505bc03          	ld	s8,80(a1)
    80002922:	0585bc83          	ld	s9,88(a1)
    80002926:	0605bd03          	ld	s10,96(a1)
    8000292a:	0685bd83          	ld	s11,104(a1)
    8000292e:	8082                	ret

0000000080002930 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002930:	1141                	addi	sp,sp,-16
    80002932:	e406                	sd	ra,8(sp)
    80002934:	e022                	sd	s0,0(sp)
    80002936:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002938:	00006597          	auipc	a1,0x6
    8000293c:	9c058593          	addi	a1,a1,-1600 # 800082f8 <states.0+0x30>
    80002940:	0001c517          	auipc	a0,0x1c
    80002944:	88050513          	addi	a0,a0,-1920 # 8001e1c0 <tickslock>
    80002948:	ffffe097          	auipc	ra,0xffffe
    8000294c:	1fe080e7          	jalr	510(ra) # 80000b46 <initlock>
}
    80002950:	60a2                	ld	ra,8(sp)
    80002952:	6402                	ld	s0,0(sp)
    80002954:	0141                	addi	sp,sp,16
    80002956:	8082                	ret

0000000080002958 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002958:	1141                	addi	sp,sp,-16
    8000295a:	e422                	sd	s0,8(sp)
    8000295c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000295e:	00003797          	auipc	a5,0x3
    80002962:	78278793          	addi	a5,a5,1922 # 800060e0 <kernelvec>
    80002966:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000296a:	6422                	ld	s0,8(sp)
    8000296c:	0141                	addi	sp,sp,16
    8000296e:	8082                	ret

0000000080002970 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002970:	1141                	addi	sp,sp,-16
    80002972:	e406                	sd	ra,8(sp)
    80002974:	e022                	sd	s0,0(sp)
    80002976:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002978:	fffff097          	auipc	ra,0xfffff
    8000297c:	064080e7          	jalr	100(ra) # 800019dc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002980:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002984:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002986:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000298a:	00004697          	auipc	a3,0x4
    8000298e:	67668693          	addi	a3,a3,1654 # 80007000 <_trampoline>
    80002992:	00004717          	auipc	a4,0x4
    80002996:	66e70713          	addi	a4,a4,1646 # 80007000 <_trampoline>
    8000299a:	8f15                	sub	a4,a4,a3
    8000299c:	040007b7          	lui	a5,0x4000
    800029a0:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800029a2:	07b2                	slli	a5,a5,0xc
    800029a4:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029a6:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029aa:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029ac:	18002673          	csrr	a2,satp
    800029b0:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029b2:	6d30                	ld	a2,88(a0)
    800029b4:	6138                	ld	a4,64(a0)
    800029b6:	6585                	lui	a1,0x1
    800029b8:	972e                	add	a4,a4,a1
    800029ba:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029bc:	6d38                	ld	a4,88(a0)
    800029be:	00000617          	auipc	a2,0x0
    800029c2:	13e60613          	addi	a2,a2,318 # 80002afc <usertrap>
    800029c6:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800029c8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029ca:	8612                	mv	a2,tp
    800029cc:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ce:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029d2:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029d6:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029da:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029de:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029e0:	6f18                	ld	a4,24(a4)
    800029e2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029e6:	6928                	ld	a0,80(a0)
    800029e8:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800029ea:	00004717          	auipc	a4,0x4
    800029ee:	6b270713          	addi	a4,a4,1714 # 8000709c <userret>
    800029f2:	8f15                	sub	a4,a4,a3
    800029f4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800029f6:	577d                	li	a4,-1
    800029f8:	177e                	slli	a4,a4,0x3f
    800029fa:	8d59                	or	a0,a0,a4
    800029fc:	9782                	jalr	a5
}
    800029fe:	60a2                	ld	ra,8(sp)
    80002a00:	6402                	ld	s0,0(sp)
    80002a02:	0141                	addi	sp,sp,16
    80002a04:	8082                	ret

0000000080002a06 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002a06:	1101                	addi	sp,sp,-32
    80002a08:	ec06                	sd	ra,24(sp)
    80002a0a:	e822                	sd	s0,16(sp)
    80002a0c:	e426                	sd	s1,8(sp)
    80002a0e:	e04a                	sd	s2,0(sp)
    80002a10:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a12:	0001b917          	auipc	s2,0x1b
    80002a16:	7ae90913          	addi	s2,s2,1966 # 8001e1c0 <tickslock>
    80002a1a:	854a                	mv	a0,s2
    80002a1c:	ffffe097          	auipc	ra,0xffffe
    80002a20:	1ba080e7          	jalr	442(ra) # 80000bd6 <acquire>
  ticks++;
    80002a24:	00006497          	auipc	s1,0x6
    80002a28:	f0848493          	addi	s1,s1,-248 # 8000892c <ticks>
    80002a2c:	409c                	lw	a5,0(s1)
    80002a2e:	2785                	addiw	a5,a5,1
    80002a30:	c09c                	sw	a5,0(s1)
  update_time();
    80002a32:	00000097          	auipc	ra,0x0
    80002a36:	e36080e7          	jalr	-458(ra) # 80002868 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002a3a:	8526                	mv	a0,s1
    80002a3c:	fffff097          	auipc	ra,0xfffff
    80002a40:	7d0080e7          	jalr	2000(ra) # 8000220c <wakeup>
  release(&tickslock);
    80002a44:	854a                	mv	a0,s2
    80002a46:	ffffe097          	auipc	ra,0xffffe
    80002a4a:	244080e7          	jalr	580(ra) # 80000c8a <release>
}
    80002a4e:	60e2                	ld	ra,24(sp)
    80002a50:	6442                	ld	s0,16(sp)
    80002a52:	64a2                	ld	s1,8(sp)
    80002a54:	6902                	ld	s2,0(sp)
    80002a56:	6105                	addi	sp,sp,32
    80002a58:	8082                	ret

0000000080002a5a <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002a5a:	1101                	addi	sp,sp,-32
    80002a5c:	ec06                	sd	ra,24(sp)
    80002a5e:	e822                	sd	s0,16(sp)
    80002a60:	e426                	sd	s1,8(sp)
    80002a62:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a64:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002a68:	00074d63          	bltz	a4,80002a82 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002a6c:	57fd                	li	a5,-1
    80002a6e:	17fe                	slli	a5,a5,0x3f
    80002a70:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002a72:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002a74:	06f70363          	beq	a4,a5,80002ada <devintr+0x80>
  }
}
    80002a78:	60e2                	ld	ra,24(sp)
    80002a7a:	6442                	ld	s0,16(sp)
    80002a7c:	64a2                	ld	s1,8(sp)
    80002a7e:	6105                	addi	sp,sp,32
    80002a80:	8082                	ret
      (scause & 0xff) == 9)
    80002a82:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002a86:	46a5                	li	a3,9
    80002a88:	fed792e3          	bne	a5,a3,80002a6c <devintr+0x12>
    int irq = plic_claim();
    80002a8c:	00003097          	auipc	ra,0x3
    80002a90:	75c080e7          	jalr	1884(ra) # 800061e8 <plic_claim>
    80002a94:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002a96:	47a9                	li	a5,10
    80002a98:	02f50763          	beq	a0,a5,80002ac6 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002a9c:	4785                	li	a5,1
    80002a9e:	02f50963          	beq	a0,a5,80002ad0 <devintr+0x76>
    return 1;
    80002aa2:	4505                	li	a0,1
    else if (irq)
    80002aa4:	d8f1                	beqz	s1,80002a78 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002aa6:	85a6                	mv	a1,s1
    80002aa8:	00006517          	auipc	a0,0x6
    80002aac:	85850513          	addi	a0,a0,-1960 # 80008300 <states.0+0x38>
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	ada080e7          	jalr	-1318(ra) # 8000058a <printf>
      plic_complete(irq);
    80002ab8:	8526                	mv	a0,s1
    80002aba:	00003097          	auipc	ra,0x3
    80002abe:	752080e7          	jalr	1874(ra) # 8000620c <plic_complete>
    return 1;
    80002ac2:	4505                	li	a0,1
    80002ac4:	bf55                	j	80002a78 <devintr+0x1e>
      uartintr();
    80002ac6:	ffffe097          	auipc	ra,0xffffe
    80002aca:	ed2080e7          	jalr	-302(ra) # 80000998 <uartintr>
    80002ace:	b7ed                	j	80002ab8 <devintr+0x5e>
      virtio_disk_intr();
    80002ad0:	00004097          	auipc	ra,0x4
    80002ad4:	c04080e7          	jalr	-1020(ra) # 800066d4 <virtio_disk_intr>
    80002ad8:	b7c5                	j	80002ab8 <devintr+0x5e>
    if (cpuid() == 0)
    80002ada:	fffff097          	auipc	ra,0xfffff
    80002ade:	ed6080e7          	jalr	-298(ra) # 800019b0 <cpuid>
    80002ae2:	c901                	beqz	a0,80002af2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ae4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ae8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002aea:	14479073          	csrw	sip,a5
    return 2;
    80002aee:	4509                	li	a0,2
    80002af0:	b761                	j	80002a78 <devintr+0x1e>
      clockintr();
    80002af2:	00000097          	auipc	ra,0x0
    80002af6:	f14080e7          	jalr	-236(ra) # 80002a06 <clockintr>
    80002afa:	b7ed                	j	80002ae4 <devintr+0x8a>

0000000080002afc <usertrap>:
{
    80002afc:	1101                	addi	sp,sp,-32
    80002afe:	ec06                	sd	ra,24(sp)
    80002b00:	e822                	sd	s0,16(sp)
    80002b02:	e426                	sd	s1,8(sp)
    80002b04:	e04a                	sd	s2,0(sp)
    80002b06:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b08:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0) // implies interrupt occured while being in kernel mode
    80002b0c:	1007f793          	andi	a5,a5,256
    80002b10:	eba5                	bnez	a5,80002b80 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b12:	00003797          	auipc	a5,0x3
    80002b16:	5ce78793          	addi	a5,a5,1486 # 800060e0 <kernelvec>
    80002b1a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b1e:	fffff097          	auipc	ra,0xfffff
    80002b22:	ebe080e7          	jalr	-322(ra) # 800019dc <myproc>
    80002b26:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b28:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b2a:	14102773          	csrr	a4,sepc
    80002b2e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b30:	14202773          	csrr	a4,scause
  if (r_scause() == 8) // exception from user mode
    80002b34:	47a1                	li	a5,8
    80002b36:	04f70d63          	beq	a4,a5,80002b90 <usertrap+0x94>
  else if ((which_dev = devintr()) != 0)
    80002b3a:	00000097          	auipc	ra,0x0
    80002b3e:	f20080e7          	jalr	-224(ra) # 80002a5a <devintr>
    80002b42:	892a                	mv	s2,a0
    80002b44:	cd59                	beqz	a0,80002be2 <usertrap+0xe6>
  if (killed(p))
    80002b46:	8526                	mv	a0,s1
    80002b48:	00000097          	auipc	ra,0x0
    80002b4c:	914080e7          	jalr	-1772(ra) # 8000245c <killed>
    80002b50:	e571                	bnez	a0,80002c1c <usertrap+0x120>
  else if (which_dev == 2) // Timer interrupt
    80002b52:	4789                	li	a5,2
    80002b54:	06f91763          	bne	s2,a5,80002bc2 <usertrap+0xc6>
    if (p && p->alarmticks && !p->handling_alarm)
    80002b58:	1f44a783          	lw	a5,500(s1)
    80002b5c:	cf89                	beqz	a5,80002b76 <usertrap+0x7a>
    80002b5e:	3284a703          	lw	a4,808(s1)
    80002b62:	eb11                	bnez	a4,80002b76 <usertrap+0x7a>
      p->ticks_passed++;
    80002b64:	1f84a703          	lw	a4,504(s1)
    80002b68:	2705                	addiw	a4,a4,1
    80002b6a:	0007069b          	sext.w	a3,a4
      if (p->ticks_passed >= p->alarmticks)
    80002b6e:	0af6dd63          	bge	a3,a5,80002c28 <usertrap+0x12c>
      p->ticks_passed++;
    80002b72:	1ee4ac23          	sw	a4,504(s1)
    yield(); // Give up the CPU after handling timer interrupt
    80002b76:	fffff097          	auipc	ra,0xfffff
    80002b7a:	5f6080e7          	jalr	1526(ra) # 8000216c <yield>
    80002b7e:	a091                	j	80002bc2 <usertrap+0xc6>
    panic("usertrap: not from user mode");
    80002b80:	00005517          	auipc	a0,0x5
    80002b84:	7a050513          	addi	a0,a0,1952 # 80008320 <states.0+0x58>
    80002b88:	ffffe097          	auipc	ra,0xffffe
    80002b8c:	9b8080e7          	jalr	-1608(ra) # 80000540 <panic>
    if (killed(p))
    80002b90:	00000097          	auipc	ra,0x0
    80002b94:	8cc080e7          	jalr	-1844(ra) # 8000245c <killed>
    80002b98:	ed1d                	bnez	a0,80002bd6 <usertrap+0xda>
    p->trapframe->epc += 4;
    80002b9a:	6cb8                	ld	a4,88(s1)
    80002b9c:	6f1c                	ld	a5,24(a4)
    80002b9e:	0791                	addi	a5,a5,4
    80002ba0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ba2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ba6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002baa:	10079073          	csrw	sstatus,a5
    syscall();
    80002bae:	00000097          	auipc	ra,0x0
    80002bb2:	2ee080e7          	jalr	750(ra) # 80002e9c <syscall>
  if (killed(p))
    80002bb6:	8526                	mv	a0,s1
    80002bb8:	00000097          	auipc	ra,0x0
    80002bbc:	8a4080e7          	jalr	-1884(ra) # 8000245c <killed>
    80002bc0:	ed31                	bnez	a0,80002c1c <usertrap+0x120>
  usertrapret();
    80002bc2:	00000097          	auipc	ra,0x0
    80002bc6:	dae080e7          	jalr	-594(ra) # 80002970 <usertrapret>
}
    80002bca:	60e2                	ld	ra,24(sp)
    80002bcc:	6442                	ld	s0,16(sp)
    80002bce:	64a2                	ld	s1,8(sp)
    80002bd0:	6902                	ld	s2,0(sp)
    80002bd2:	6105                	addi	sp,sp,32
    80002bd4:	8082                	ret
      exit(-1);
    80002bd6:	557d                	li	a0,-1
    80002bd8:	fffff097          	auipc	ra,0xfffff
    80002bdc:	704080e7          	jalr	1796(ra) # 800022dc <exit>
    80002be0:	bf6d                	j	80002b9a <usertrap+0x9e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002be2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002be6:	5890                	lw	a2,48(s1)
    80002be8:	00005517          	auipc	a0,0x5
    80002bec:	75850513          	addi	a0,a0,1880 # 80008340 <states.0+0x78>
    80002bf0:	ffffe097          	auipc	ra,0xffffe
    80002bf4:	99a080e7          	jalr	-1638(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bf8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bfc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c00:	00005517          	auipc	a0,0x5
    80002c04:	77050513          	addi	a0,a0,1904 # 80008370 <states.0+0xa8>
    80002c08:	ffffe097          	auipc	ra,0xffffe
    80002c0c:	982080e7          	jalr	-1662(ra) # 8000058a <printf>
    setkilled(p);
    80002c10:	8526                	mv	a0,s1
    80002c12:	00000097          	auipc	ra,0x0
    80002c16:	81e080e7          	jalr	-2018(ra) # 80002430 <setkilled>
    80002c1a:	bf71                	j	80002bb6 <usertrap+0xba>
    exit(-1);
    80002c1c:	557d                	li	a0,-1
    80002c1e:	fffff097          	auipc	ra,0xfffff
    80002c22:	6be080e7          	jalr	1726(ra) # 800022dc <exit>
    80002c26:	bf71                	j	80002bc2 <usertrap+0xc6>
        p->ticks_passed = 0; // Reset tick counter
    80002c28:	1e04ac23          	sw	zero,504(s1)
        memmove(&p->alarm_tf, p->trapframe, sizeof(struct trapframe));
    80002c2c:	12000613          	li	a2,288
    80002c30:	6cac                	ld	a1,88(s1)
    80002c32:	20848513          	addi	a0,s1,520
    80002c36:	ffffe097          	auipc	ra,0xffffe
    80002c3a:	0f8080e7          	jalr	248(ra) # 80000d2e <memmove>
        p->trapframe->epc = (uint64)p->alarmhandler;
    80002c3e:	6cbc                	ld	a5,88(s1)
    80002c40:	2004b703          	ld	a4,512(s1)
    80002c44:	ef98                	sd	a4,24(a5)
        p->handling_alarm = 1;
    80002c46:	4785                	li	a5,1
    80002c48:	32f4a423          	sw	a5,808(s1)
    80002c4c:	b72d                	j	80002b76 <usertrap+0x7a>

0000000080002c4e <kerneltrap>:
{
    80002c4e:	7179                	addi	sp,sp,-48
    80002c50:	f406                	sd	ra,40(sp)
    80002c52:	f022                	sd	s0,32(sp)
    80002c54:	ec26                	sd	s1,24(sp)
    80002c56:	e84a                	sd	s2,16(sp)
    80002c58:	e44e                	sd	s3,8(sp)
    80002c5a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c5c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c60:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c64:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002c68:	1004f793          	andi	a5,s1,256
    80002c6c:	cb85                	beqz	a5,80002c9c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c6e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c72:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002c74:	ef85                	bnez	a5,80002cac <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002c76:	00000097          	auipc	ra,0x0
    80002c7a:	de4080e7          	jalr	-540(ra) # 80002a5a <devintr>
    80002c7e:	cd1d                	beqz	a0,80002cbc <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c80:	4789                	li	a5,2
    80002c82:	06f50a63          	beq	a0,a5,80002cf6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c86:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c8a:	10049073          	csrw	sstatus,s1
}
    80002c8e:	70a2                	ld	ra,40(sp)
    80002c90:	7402                	ld	s0,32(sp)
    80002c92:	64e2                	ld	s1,24(sp)
    80002c94:	6942                	ld	s2,16(sp)
    80002c96:	69a2                	ld	s3,8(sp)
    80002c98:	6145                	addi	sp,sp,48
    80002c9a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c9c:	00005517          	auipc	a0,0x5
    80002ca0:	6f450513          	addi	a0,a0,1780 # 80008390 <states.0+0xc8>
    80002ca4:	ffffe097          	auipc	ra,0xffffe
    80002ca8:	89c080e7          	jalr	-1892(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002cac:	00005517          	auipc	a0,0x5
    80002cb0:	70c50513          	addi	a0,a0,1804 # 800083b8 <states.0+0xf0>
    80002cb4:	ffffe097          	auipc	ra,0xffffe
    80002cb8:	88c080e7          	jalr	-1908(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002cbc:	85ce                	mv	a1,s3
    80002cbe:	00005517          	auipc	a0,0x5
    80002cc2:	71a50513          	addi	a0,a0,1818 # 800083d8 <states.0+0x110>
    80002cc6:	ffffe097          	auipc	ra,0xffffe
    80002cca:	8c4080e7          	jalr	-1852(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cce:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cd2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cd6:	00005517          	auipc	a0,0x5
    80002cda:	71250513          	addi	a0,a0,1810 # 800083e8 <states.0+0x120>
    80002cde:	ffffe097          	auipc	ra,0xffffe
    80002ce2:	8ac080e7          	jalr	-1876(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002ce6:	00005517          	auipc	a0,0x5
    80002cea:	71a50513          	addi	a0,a0,1818 # 80008400 <states.0+0x138>
    80002cee:	ffffe097          	auipc	ra,0xffffe
    80002cf2:	852080e7          	jalr	-1966(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cf6:	fffff097          	auipc	ra,0xfffff
    80002cfa:	ce6080e7          	jalr	-794(ra) # 800019dc <myproc>
    80002cfe:	d541                	beqz	a0,80002c86 <kerneltrap+0x38>
    80002d00:	fffff097          	auipc	ra,0xfffff
    80002d04:	cdc080e7          	jalr	-804(ra) # 800019dc <myproc>
    80002d08:	4d18                	lw	a4,24(a0)
    80002d0a:	4791                	li	a5,4
    80002d0c:	f6f71de3          	bne	a4,a5,80002c86 <kerneltrap+0x38>
    yield();
    80002d10:	fffff097          	auipc	ra,0xfffff
    80002d14:	45c080e7          	jalr	1116(ra) # 8000216c <yield>
    80002d18:	b7bd                	j	80002c86 <kerneltrap+0x38>

0000000080002d1a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d1a:	1101                	addi	sp,sp,-32
    80002d1c:	ec06                	sd	ra,24(sp)
    80002d1e:	e822                	sd	s0,16(sp)
    80002d20:	e426                	sd	s1,8(sp)
    80002d22:	1000                	addi	s0,sp,32
    80002d24:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	cb6080e7          	jalr	-842(ra) # 800019dc <myproc>
  switch (n)
    80002d2e:	4795                	li	a5,5
    80002d30:	0497e163          	bltu	a5,s1,80002d72 <argraw+0x58>
    80002d34:	048a                	slli	s1,s1,0x2
    80002d36:	00005717          	auipc	a4,0x5
    80002d3a:	70270713          	addi	a4,a4,1794 # 80008438 <states.0+0x170>
    80002d3e:	94ba                	add	s1,s1,a4
    80002d40:	409c                	lw	a5,0(s1)
    80002d42:	97ba                	add	a5,a5,a4
    80002d44:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002d46:	6d3c                	ld	a5,88(a0)
    80002d48:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d4a:	60e2                	ld	ra,24(sp)
    80002d4c:	6442                	ld	s0,16(sp)
    80002d4e:	64a2                	ld	s1,8(sp)
    80002d50:	6105                	addi	sp,sp,32
    80002d52:	8082                	ret
    return p->trapframe->a1;
    80002d54:	6d3c                	ld	a5,88(a0)
    80002d56:	7fa8                	ld	a0,120(a5)
    80002d58:	bfcd                	j	80002d4a <argraw+0x30>
    return p->trapframe->a2;
    80002d5a:	6d3c                	ld	a5,88(a0)
    80002d5c:	63c8                	ld	a0,128(a5)
    80002d5e:	b7f5                	j	80002d4a <argraw+0x30>
    return p->trapframe->a3;
    80002d60:	6d3c                	ld	a5,88(a0)
    80002d62:	67c8                	ld	a0,136(a5)
    80002d64:	b7dd                	j	80002d4a <argraw+0x30>
    return p->trapframe->a4;
    80002d66:	6d3c                	ld	a5,88(a0)
    80002d68:	6bc8                	ld	a0,144(a5)
    80002d6a:	b7c5                	j	80002d4a <argraw+0x30>
    return p->trapframe->a5;
    80002d6c:	6d3c                	ld	a5,88(a0)
    80002d6e:	6fc8                	ld	a0,152(a5)
    80002d70:	bfe9                	j	80002d4a <argraw+0x30>
  panic("argraw");
    80002d72:	00005517          	auipc	a0,0x5
    80002d76:	69e50513          	addi	a0,a0,1694 # 80008410 <states.0+0x148>
    80002d7a:	ffffd097          	auipc	ra,0xffffd
    80002d7e:	7c6080e7          	jalr	1990(ra) # 80000540 <panic>

0000000080002d82 <fetchaddr>:
{
    80002d82:	1101                	addi	sp,sp,-32
    80002d84:	ec06                	sd	ra,24(sp)
    80002d86:	e822                	sd	s0,16(sp)
    80002d88:	e426                	sd	s1,8(sp)
    80002d8a:	e04a                	sd	s2,0(sp)
    80002d8c:	1000                	addi	s0,sp,32
    80002d8e:	84aa                	mv	s1,a0
    80002d90:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d92:	fffff097          	auipc	ra,0xfffff
    80002d96:	c4a080e7          	jalr	-950(ra) # 800019dc <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d9a:	653c                	ld	a5,72(a0)
    80002d9c:	02f4f863          	bgeu	s1,a5,80002dcc <fetchaddr+0x4a>
    80002da0:	00848713          	addi	a4,s1,8
    80002da4:	02e7e663          	bltu	a5,a4,80002dd0 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002da8:	46a1                	li	a3,8
    80002daa:	8626                	mv	a2,s1
    80002dac:	85ca                	mv	a1,s2
    80002dae:	6928                	ld	a0,80(a0)
    80002db0:	fffff097          	auipc	ra,0xfffff
    80002db4:	948080e7          	jalr	-1720(ra) # 800016f8 <copyin>
    80002db8:	00a03533          	snez	a0,a0
    80002dbc:	40a00533          	neg	a0,a0
}
    80002dc0:	60e2                	ld	ra,24(sp)
    80002dc2:	6442                	ld	s0,16(sp)
    80002dc4:	64a2                	ld	s1,8(sp)
    80002dc6:	6902                	ld	s2,0(sp)
    80002dc8:	6105                	addi	sp,sp,32
    80002dca:	8082                	ret
    return -1;
    80002dcc:	557d                	li	a0,-1
    80002dce:	bfcd                	j	80002dc0 <fetchaddr+0x3e>
    80002dd0:	557d                	li	a0,-1
    80002dd2:	b7fd                	j	80002dc0 <fetchaddr+0x3e>

0000000080002dd4 <fetchstr>:
{
    80002dd4:	7179                	addi	sp,sp,-48
    80002dd6:	f406                	sd	ra,40(sp)
    80002dd8:	f022                	sd	s0,32(sp)
    80002dda:	ec26                	sd	s1,24(sp)
    80002ddc:	e84a                	sd	s2,16(sp)
    80002dde:	e44e                	sd	s3,8(sp)
    80002de0:	1800                	addi	s0,sp,48
    80002de2:	892a                	mv	s2,a0
    80002de4:	84ae                	mv	s1,a1
    80002de6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002de8:	fffff097          	auipc	ra,0xfffff
    80002dec:	bf4080e7          	jalr	-1036(ra) # 800019dc <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002df0:	86ce                	mv	a3,s3
    80002df2:	864a                	mv	a2,s2
    80002df4:	85a6                	mv	a1,s1
    80002df6:	6928                	ld	a0,80(a0)
    80002df8:	fffff097          	auipc	ra,0xfffff
    80002dfc:	98e080e7          	jalr	-1650(ra) # 80001786 <copyinstr>
    80002e00:	00054e63          	bltz	a0,80002e1c <fetchstr+0x48>
  return strlen(buf);
    80002e04:	8526                	mv	a0,s1
    80002e06:	ffffe097          	auipc	ra,0xffffe
    80002e0a:	048080e7          	jalr	72(ra) # 80000e4e <strlen>
}
    80002e0e:	70a2                	ld	ra,40(sp)
    80002e10:	7402                	ld	s0,32(sp)
    80002e12:	64e2                	ld	s1,24(sp)
    80002e14:	6942                	ld	s2,16(sp)
    80002e16:	69a2                	ld	s3,8(sp)
    80002e18:	6145                	addi	sp,sp,48
    80002e1a:	8082                	ret
    return -1;
    80002e1c:	557d                	li	a0,-1
    80002e1e:	bfc5                	j	80002e0e <fetchstr+0x3a>

0000000080002e20 <argint>:

// Fetch the nth 32-bit system call argument.
int argint(int n, int *ip)
{
    80002e20:	1101                	addi	sp,sp,-32
    80002e22:	ec06                	sd	ra,24(sp)
    80002e24:	e822                	sd	s0,16(sp)
    80002e26:	e426                	sd	s1,8(sp)
    80002e28:	1000                	addi	s0,sp,32
    80002e2a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e2c:	00000097          	auipc	ra,0x0
    80002e30:	eee080e7          	jalr	-274(ra) # 80002d1a <argraw>
    80002e34:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e36:	4501                	li	a0,0
    80002e38:	60e2                	ld	ra,24(sp)
    80002e3a:	6442                	ld	s0,16(sp)
    80002e3c:	64a2                	ld	s1,8(sp)
    80002e3e:	6105                	addi	sp,sp,32
    80002e40:	8082                	ret

0000000080002e42 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int argaddr(int n, uint64 *ip)
{
    80002e42:	1101                	addi	sp,sp,-32
    80002e44:	ec06                	sd	ra,24(sp)
    80002e46:	e822                	sd	s0,16(sp)
    80002e48:	e426                	sd	s1,8(sp)
    80002e4a:	1000                	addi	s0,sp,32
    80002e4c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e4e:	00000097          	auipc	ra,0x0
    80002e52:	ecc080e7          	jalr	-308(ra) # 80002d1a <argraw>
    80002e56:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e58:	4501                	li	a0,0
    80002e5a:	60e2                	ld	ra,24(sp)
    80002e5c:	6442                	ld	s0,16(sp)
    80002e5e:	64a2                	ld	s1,8(sp)
    80002e60:	6105                	addi	sp,sp,32
    80002e62:	8082                	ret

0000000080002e64 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002e64:	7179                	addi	sp,sp,-48
    80002e66:	f406                	sd	ra,40(sp)
    80002e68:	f022                	sd	s0,32(sp)
    80002e6a:	ec26                	sd	s1,24(sp)
    80002e6c:	e84a                	sd	s2,16(sp)
    80002e6e:	1800                	addi	s0,sp,48
    80002e70:	84ae                	mv	s1,a1
    80002e72:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e74:	fd840593          	addi	a1,s0,-40
    80002e78:	00000097          	auipc	ra,0x0
    80002e7c:	fca080e7          	jalr	-54(ra) # 80002e42 <argaddr>
  return fetchstr(addr, buf, max);
    80002e80:	864a                	mv	a2,s2
    80002e82:	85a6                	mv	a1,s1
    80002e84:	fd843503          	ld	a0,-40(s0)
    80002e88:	00000097          	auipc	ra,0x0
    80002e8c:	f4c080e7          	jalr	-180(ra) # 80002dd4 <fetchstr>
}
    80002e90:	70a2                	ld	ra,40(sp)
    80002e92:	7402                	ld	s0,32(sp)
    80002e94:	64e2                	ld	s1,24(sp)
    80002e96:	6942                	ld	s2,16(sp)
    80002e98:	6145                	addi	sp,sp,48
    80002e9a:	8082                	ret

0000000080002e9c <syscall>:
    [SYS_sigreturn] sys_sigreturn,
    [SYS_settickets] sys_settickets,
};

void syscall(void)
{
    80002e9c:	7179                	addi	sp,sp,-48
    80002e9e:	f406                	sd	ra,40(sp)
    80002ea0:	f022                	sd	s0,32(sp)
    80002ea2:	ec26                	sd	s1,24(sp)
    80002ea4:	e84a                	sd	s2,16(sp)
    80002ea6:	e44e                	sd	s3,8(sp)
    80002ea8:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002eaa:	fffff097          	auipc	ra,0xfffff
    80002eae:	b32080e7          	jalr	-1230(ra) # 800019dc <myproc>
    80002eb2:	84aa                	mv	s1,a0
  num = p->trapframe->a7;
    80002eb4:	05853983          	ld	s3,88(a0)
    80002eb8:	0a89b783          	ld	a5,168(s3)
    80002ebc:	0007891b          	sext.w	s2,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002ec0:	37fd                	addiw	a5,a5,-1
    80002ec2:	4769                	li	a4,26
    80002ec4:	02f76863          	bltu	a4,a5,80002ef4 <syscall+0x58>
    80002ec8:	00391713          	slli	a4,s2,0x3
    80002ecc:	00005797          	auipc	a5,0x5
    80002ed0:	58478793          	addi	a5,a5,1412 # 80008450 <syscalls>
    80002ed4:	97ba                	add	a5,a5,a4
    80002ed6:	639c                	ld	a5,0(a5)
    80002ed8:	cf91                	beqz	a5,80002ef4 <syscall+0x58>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002eda:	9782                	jalr	a5
    80002edc:	06a9b823          	sd	a0,112(s3)
    // p->syscall_count[num]++;
    syscount[num]++;
    80002ee0:	090a                	slli	s2,s2,0x2
    80002ee2:	0001b797          	auipc	a5,0x1b
    80002ee6:	2f678793          	addi	a5,a5,758 # 8001e1d8 <syscount>
    80002eea:	97ca                	add	a5,a5,s2
    80002eec:	4398                	lw	a4,0(a5)
    80002eee:	2705                	addiw	a4,a4,1
    80002ef0:	c398                	sw	a4,0(a5)
    80002ef2:	a005                	j	80002f12 <syscall+0x76>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002ef4:	86ca                	mv	a3,s2
    80002ef6:	15848613          	addi	a2,s1,344
    80002efa:	588c                	lw	a1,48(s1)
    80002efc:	00005517          	auipc	a0,0x5
    80002f00:	51c50513          	addi	a0,a0,1308 # 80008418 <states.0+0x150>
    80002f04:	ffffd097          	auipc	ra,0xffffd
    80002f08:	686080e7          	jalr	1670(ra) # 8000058a <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f0c:	6cbc                	ld	a5,88(s1)
    80002f0e:	577d                	li	a4,-1
    80002f10:	fbb8                	sd	a4,112(a5)
  }
}
    80002f12:	70a2                	ld	ra,40(sp)
    80002f14:	7402                	ld	s0,32(sp)
    80002f16:	64e2                	ld	s1,24(sp)
    80002f18:	6942                	ld	s2,16(sp)
    80002f1a:	69a2                	ld	s3,8(sp)
    80002f1c:	6145                	addi	sp,sp,48
    80002f1e:	8082                	ret

0000000080002f20 <sys_exit>:
#include "spinlock.h"
#include "proc.h"
#include "syscount_arr.h"
uint64
sys_exit(void)
{
    80002f20:	1101                	addi	sp,sp,-32
    80002f22:	ec06                	sd	ra,24(sp)
    80002f24:	e822                	sd	s0,16(sp)
    80002f26:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f28:	fec40593          	addi	a1,s0,-20
    80002f2c:	4501                	li	a0,0
    80002f2e:	00000097          	auipc	ra,0x0
    80002f32:	ef2080e7          	jalr	-270(ra) # 80002e20 <argint>
  exit(n);
    80002f36:	fec42503          	lw	a0,-20(s0)
    80002f3a:	fffff097          	auipc	ra,0xfffff
    80002f3e:	3a2080e7          	jalr	930(ra) # 800022dc <exit>
  return 0; // not reached
}
    80002f42:	4501                	li	a0,0
    80002f44:	60e2                	ld	ra,24(sp)
    80002f46:	6442                	ld	s0,16(sp)
    80002f48:	6105                	addi	sp,sp,32
    80002f4a:	8082                	ret

0000000080002f4c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f4c:	1141                	addi	sp,sp,-16
    80002f4e:	e406                	sd	ra,8(sp)
    80002f50:	e022                	sd	s0,0(sp)
    80002f52:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f54:	fffff097          	auipc	ra,0xfffff
    80002f58:	a88080e7          	jalr	-1400(ra) # 800019dc <myproc>
}
    80002f5c:	5908                	lw	a0,48(a0)
    80002f5e:	60a2                	ld	ra,8(sp)
    80002f60:	6402                	ld	s0,0(sp)
    80002f62:	0141                	addi	sp,sp,16
    80002f64:	8082                	ret

0000000080002f66 <sys_fork>:

uint64
sys_fork(void)
{
    80002f66:	1141                	addi	sp,sp,-16
    80002f68:	e406                	sd	ra,8(sp)
    80002f6a:	e022                	sd	s0,0(sp)
    80002f6c:	0800                	addi	s0,sp,16
  return fork();
    80002f6e:	fffff097          	auipc	ra,0xfffff
    80002f72:	ea6080e7          	jalr	-346(ra) # 80001e14 <fork>
}
    80002f76:	60a2                	ld	ra,8(sp)
    80002f78:	6402                	ld	s0,0(sp)
    80002f7a:	0141                	addi	sp,sp,16
    80002f7c:	8082                	ret

0000000080002f7e <sys_wait>:

uint64
sys_wait(void)
{
    80002f7e:	1101                	addi	sp,sp,-32
    80002f80:	ec06                	sd	ra,24(sp)
    80002f82:	e822                	sd	s0,16(sp)
    80002f84:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f86:	fe840593          	addi	a1,s0,-24
    80002f8a:	4501                	li	a0,0
    80002f8c:	00000097          	auipc	ra,0x0
    80002f90:	eb6080e7          	jalr	-330(ra) # 80002e42 <argaddr>
  return wait(p);
    80002f94:	fe843503          	ld	a0,-24(s0)
    80002f98:	fffff097          	auipc	ra,0xfffff
    80002f9c:	4f6080e7          	jalr	1270(ra) # 8000248e <wait>
}
    80002fa0:	60e2                	ld	ra,24(sp)
    80002fa2:	6442                	ld	s0,16(sp)
    80002fa4:	6105                	addi	sp,sp,32
    80002fa6:	8082                	ret

0000000080002fa8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fa8:	7179                	addi	sp,sp,-48
    80002faa:	f406                	sd	ra,40(sp)
    80002fac:	f022                	sd	s0,32(sp)
    80002fae:	ec26                	sd	s1,24(sp)
    80002fb0:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002fb2:	fdc40593          	addi	a1,s0,-36
    80002fb6:	4501                	li	a0,0
    80002fb8:	00000097          	auipc	ra,0x0
    80002fbc:	e68080e7          	jalr	-408(ra) # 80002e20 <argint>
  addr = myproc()->sz;
    80002fc0:	fffff097          	auipc	ra,0xfffff
    80002fc4:	a1c080e7          	jalr	-1508(ra) # 800019dc <myproc>
    80002fc8:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002fca:	fdc42503          	lw	a0,-36(s0)
    80002fce:	fffff097          	auipc	ra,0xfffff
    80002fd2:	dea080e7          	jalr	-534(ra) # 80001db8 <growproc>
    80002fd6:	00054863          	bltz	a0,80002fe6 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002fda:	8526                	mv	a0,s1
    80002fdc:	70a2                	ld	ra,40(sp)
    80002fde:	7402                	ld	s0,32(sp)
    80002fe0:	64e2                	ld	s1,24(sp)
    80002fe2:	6145                	addi	sp,sp,48
    80002fe4:	8082                	ret
    return -1;
    80002fe6:	54fd                	li	s1,-1
    80002fe8:	bfcd                	j	80002fda <sys_sbrk+0x32>

0000000080002fea <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fea:	7139                	addi	sp,sp,-64
    80002fec:	fc06                	sd	ra,56(sp)
    80002fee:	f822                	sd	s0,48(sp)
    80002ff0:	f426                	sd	s1,40(sp)
    80002ff2:	f04a                	sd	s2,32(sp)
    80002ff4:	ec4e                	sd	s3,24(sp)
    80002ff6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ff8:	fcc40593          	addi	a1,s0,-52
    80002ffc:	4501                	li	a0,0
    80002ffe:	00000097          	auipc	ra,0x0
    80003002:	e22080e7          	jalr	-478(ra) # 80002e20 <argint>
  acquire(&tickslock);
    80003006:	0001b517          	auipc	a0,0x1b
    8000300a:	1ba50513          	addi	a0,a0,442 # 8001e1c0 <tickslock>
    8000300e:	ffffe097          	auipc	ra,0xffffe
    80003012:	bc8080e7          	jalr	-1080(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80003016:	00006917          	auipc	s2,0x6
    8000301a:	91692903          	lw	s2,-1770(s2) # 8000892c <ticks>
  while (ticks - ticks0 < n)
    8000301e:	fcc42783          	lw	a5,-52(s0)
    80003022:	cf9d                	beqz	a5,80003060 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003024:	0001b997          	auipc	s3,0x1b
    80003028:	19c98993          	addi	s3,s3,412 # 8001e1c0 <tickslock>
    8000302c:	00006497          	auipc	s1,0x6
    80003030:	90048493          	addi	s1,s1,-1792 # 8000892c <ticks>
    if (killed(myproc()))
    80003034:	fffff097          	auipc	ra,0xfffff
    80003038:	9a8080e7          	jalr	-1624(ra) # 800019dc <myproc>
    8000303c:	fffff097          	auipc	ra,0xfffff
    80003040:	420080e7          	jalr	1056(ra) # 8000245c <killed>
    80003044:	ed15                	bnez	a0,80003080 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003046:	85ce                	mv	a1,s3
    80003048:	8526                	mv	a0,s1
    8000304a:	fffff097          	auipc	ra,0xfffff
    8000304e:	15e080e7          	jalr	350(ra) # 800021a8 <sleep>
  while (ticks - ticks0 < n)
    80003052:	409c                	lw	a5,0(s1)
    80003054:	412787bb          	subw	a5,a5,s2
    80003058:	fcc42703          	lw	a4,-52(s0)
    8000305c:	fce7ece3          	bltu	a5,a4,80003034 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003060:	0001b517          	auipc	a0,0x1b
    80003064:	16050513          	addi	a0,a0,352 # 8001e1c0 <tickslock>
    80003068:	ffffe097          	auipc	ra,0xffffe
    8000306c:	c22080e7          	jalr	-990(ra) # 80000c8a <release>
  return 0;
    80003070:	4501                	li	a0,0
}
    80003072:	70e2                	ld	ra,56(sp)
    80003074:	7442                	ld	s0,48(sp)
    80003076:	74a2                	ld	s1,40(sp)
    80003078:	7902                	ld	s2,32(sp)
    8000307a:	69e2                	ld	s3,24(sp)
    8000307c:	6121                	addi	sp,sp,64
    8000307e:	8082                	ret
      release(&tickslock);
    80003080:	0001b517          	auipc	a0,0x1b
    80003084:	14050513          	addi	a0,a0,320 # 8001e1c0 <tickslock>
    80003088:	ffffe097          	auipc	ra,0xffffe
    8000308c:	c02080e7          	jalr	-1022(ra) # 80000c8a <release>
      return -1;
    80003090:	557d                	li	a0,-1
    80003092:	b7c5                	j	80003072 <sys_sleep+0x88>

0000000080003094 <sys_kill>:

uint64
sys_kill(void)
{
    80003094:	1101                	addi	sp,sp,-32
    80003096:	ec06                	sd	ra,24(sp)
    80003098:	e822                	sd	s0,16(sp)
    8000309a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000309c:	fec40593          	addi	a1,s0,-20
    800030a0:	4501                	li	a0,0
    800030a2:	00000097          	auipc	ra,0x0
    800030a6:	d7e080e7          	jalr	-642(ra) # 80002e20 <argint>
  return kill(pid);
    800030aa:	fec42503          	lw	a0,-20(s0)
    800030ae:	fffff097          	auipc	ra,0xfffff
    800030b2:	310080e7          	jalr	784(ra) # 800023be <kill>
}
    800030b6:	60e2                	ld	ra,24(sp)
    800030b8:	6442                	ld	s0,16(sp)
    800030ba:	6105                	addi	sp,sp,32
    800030bc:	8082                	ret

00000000800030be <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030be:	1101                	addi	sp,sp,-32
    800030c0:	ec06                	sd	ra,24(sp)
    800030c2:	e822                	sd	s0,16(sp)
    800030c4:	e426                	sd	s1,8(sp)
    800030c6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030c8:	0001b517          	auipc	a0,0x1b
    800030cc:	0f850513          	addi	a0,a0,248 # 8001e1c0 <tickslock>
    800030d0:	ffffe097          	auipc	ra,0xffffe
    800030d4:	b06080e7          	jalr	-1274(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800030d8:	00006497          	auipc	s1,0x6
    800030dc:	8544a483          	lw	s1,-1964(s1) # 8000892c <ticks>
  release(&tickslock);
    800030e0:	0001b517          	auipc	a0,0x1b
    800030e4:	0e050513          	addi	a0,a0,224 # 8001e1c0 <tickslock>
    800030e8:	ffffe097          	auipc	ra,0xffffe
    800030ec:	ba2080e7          	jalr	-1118(ra) # 80000c8a <release>
  return xticks;
}
    800030f0:	02049513          	slli	a0,s1,0x20
    800030f4:	9101                	srli	a0,a0,0x20
    800030f6:	60e2                	ld	ra,24(sp)
    800030f8:	6442                	ld	s0,16(sp)
    800030fa:	64a2                	ld	s1,8(sp)
    800030fc:	6105                	addi	sp,sp,32
    800030fe:	8082                	ret

0000000080003100 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003100:	7139                	addi	sp,sp,-64
    80003102:	fc06                	sd	ra,56(sp)
    80003104:	f822                	sd	s0,48(sp)
    80003106:	f426                	sd	s1,40(sp)
    80003108:	f04a                	sd	s2,32(sp)
    8000310a:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000310c:	fd840593          	addi	a1,s0,-40
    80003110:	4501                	li	a0,0
    80003112:	00000097          	auipc	ra,0x0
    80003116:	d30080e7          	jalr	-720(ra) # 80002e42 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000311a:	fd040593          	addi	a1,s0,-48
    8000311e:	4505                	li	a0,1
    80003120:	00000097          	auipc	ra,0x0
    80003124:	d22080e7          	jalr	-734(ra) # 80002e42 <argaddr>
  argaddr(2, &addr2);
    80003128:	fc840593          	addi	a1,s0,-56
    8000312c:	4509                	li	a0,2
    8000312e:	00000097          	auipc	ra,0x0
    80003132:	d14080e7          	jalr	-748(ra) # 80002e42 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003136:	fc040613          	addi	a2,s0,-64
    8000313a:	fc440593          	addi	a1,s0,-60
    8000313e:	fd843503          	ld	a0,-40(s0)
    80003142:	fffff097          	auipc	ra,0xfffff
    80003146:	5da080e7          	jalr	1498(ra) # 8000271c <waitx>
    8000314a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000314c:	fffff097          	auipc	ra,0xfffff
    80003150:	890080e7          	jalr	-1904(ra) # 800019dc <myproc>
    80003154:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003156:	4691                	li	a3,4
    80003158:	fc440613          	addi	a2,s0,-60
    8000315c:	fd043583          	ld	a1,-48(s0)
    80003160:	6928                	ld	a0,80(a0)
    80003162:	ffffe097          	auipc	ra,0xffffe
    80003166:	50a080e7          	jalr	1290(ra) # 8000166c <copyout>
    return -1;
    8000316a:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000316c:	00054f63          	bltz	a0,8000318a <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003170:	4691                	li	a3,4
    80003172:	fc040613          	addi	a2,s0,-64
    80003176:	fc843583          	ld	a1,-56(s0)
    8000317a:	68a8                	ld	a0,80(s1)
    8000317c:	ffffe097          	auipc	ra,0xffffe
    80003180:	4f0080e7          	jalr	1264(ra) # 8000166c <copyout>
    80003184:	00054a63          	bltz	a0,80003198 <sys_waitx+0x98>
    return -1;
  return ret;
    80003188:	87ca                	mv	a5,s2
}
    8000318a:	853e                	mv	a0,a5
    8000318c:	70e2                	ld	ra,56(sp)
    8000318e:	7442                	ld	s0,48(sp)
    80003190:	74a2                	ld	s1,40(sp)
    80003192:	7902                	ld	s2,32(sp)
    80003194:	6121                	addi	sp,sp,64
    80003196:	8082                	ret
    return -1;
    80003198:	57fd                	li	a5,-1
    8000319a:	bfc5                	j	8000318a <sys_waitx+0x8a>

000000008000319c <sys_setmask>:

uint64
sys_setmask(void)
{
    8000319c:	1101                	addi	sp,sp,-32
    8000319e:	ec06                	sd	ra,24(sp)
    800031a0:	e822                	sd	s0,16(sp)
    800031a2:	1000                	addi	s0,sp,32
  int mask;
  if (argint(0, &mask) < 0)
    800031a4:	fec40593          	addi	a1,s0,-20
    800031a8:	4501                	li	a0,0
    800031aa:	00000097          	auipc	ra,0x0
    800031ae:	c76080e7          	jalr	-906(ra) # 80002e20 <argint>
    return -1;
    800031b2:	57fd                	li	a5,-1
  if (argint(0, &mask) < 0)
    800031b4:	00054b63          	bltz	a0,800031ca <sys_setmask+0x2e>
  struct proc *p = myproc();
    800031b8:	fffff097          	auipc	ra,0xfffff
    800031bc:	824080e7          	jalr	-2012(ra) # 800019dc <myproc>
  p->mask = mask; // Set the mask for the current process
    800031c0:	fec42783          	lw	a5,-20(s0)
    800031c4:	1ef52823          	sw	a5,496(a0)
  return 0;
    800031c8:	4781                	li	a5,0
}
    800031ca:	853e                	mv	a0,a5
    800031cc:	60e2                	ld	ra,24(sp)
    800031ce:	6442                	ld	s0,16(sp)
    800031d0:	6105                	addi	sp,sp,32
    800031d2:	8082                	ret

00000000800031d4 <sys_getcount>:

uint64
sys_getcount(void)
{
    800031d4:	1101                	addi	sp,sp,-32
    800031d6:	ec06                	sd	ra,24(sp)
    800031d8:	e822                	sd	s0,16(sp)
    800031da:	1000                	addi	s0,sp,32

  int mask;
  if (argint(0, &mask) < 0) // fetches the first argument (from user space) passed to the syscall
    800031dc:	fec40593          	addi	a1,s0,-20
    800031e0:	4501                	li	a0,0
    800031e2:	00000097          	auipc	ra,0x0
    800031e6:	c3e080e7          	jalr	-962(ra) # 80002e20 <argint>
    800031ea:	87aa                	mv	a5,a0
    return -1;
    800031ec:	557d                	li	a0,-1
  if (argint(0, &mask) < 0) // fetches the first argument (from user space) passed to the syscall
    800031ee:	0207cd63          	bltz	a5,80003228 <sys_getcount+0x54>
  // printf("%d\n", mask);
  struct proc *p = myproc(); // collects the corrent running process
    800031f2:	ffffe097          	auipc	ra,0xffffe
    800031f6:	7ea080e7          	jalr	2026(ra) # 800019dc <myproc>
  {
    if (temp == p || temp->parent == p) // if temp is current running process or child of process
    {
      for (int i = 1; i < 31; i++) // iterate over all the syscalls and see the one that matches 1 <<i as mask
      {
        if (mask == 1 << i)
    800031fa:	fec42803          	lw	a6,-20(s0)
  for (temp = proc; temp < &proc[NPROC]; temp++) // iterates over all the processes in the process table
    800031fe:	0000e617          	auipc	a2,0xe
    80003202:	dc260613          	addi	a2,a2,-574 # 80010fc0 <proc>
    80003206:	4e05                	li	t3,1
        if (mask == 1 << i)
    80003208:	4585                	li	a1,1
      for (int i = 1; i < 31; i++) // iterate over all the syscalls and see the one that matches 1 <<i as mask
    8000320a:	48fd                	li	a7,31
  for (temp = proc; temp < &proc[NPROC]; temp++) // iterates over all the processes in the process table
    8000320c:	0001b317          	auipc	t1,0x1b
    80003210:	fb430313          	addi	t1,t1,-76 # 8001e1c0 <tickslock>
    80003214:	a015                	j	80003238 <sys_getcount+0x64>
        {
          count = syscount[i]; // return count -> number of times a syscall that has been called by current running process
    80003216:	078a                	slli	a5,a5,0x2
    80003218:	0001b717          	auipc	a4,0x1b
    8000321c:	fc070713          	addi	a4,a4,-64 # 8001e1d8 <syscount>
    80003220:	97ba                	add	a5,a5,a4
    80003222:	4388                	lw	a0,0(a5)
          syscount[i] = 0; // reset syscount = 0;
    80003224:	0007a023          	sw	zero,0(a5)
        syscount[i] = 0;
      }
    }
  }
  return count;
}
    80003228:	60e2                	ld	ra,24(sp)
    8000322a:	6442                	ld	s0,16(sp)
    8000322c:	6105                	addi	sp,sp,32
    8000322e:	8082                	ret
  for (temp = proc; temp < &proc[NPROC]; temp++) // iterates over all the processes in the process table
    80003230:	34860613          	addi	a2,a2,840
    80003234:	02660763          	beq	a2,t1,80003262 <sys_getcount+0x8e>
    if (temp == p || temp->parent == p) // if temp is current running process or child of process
    80003238:	00c50563          	beq	a0,a2,80003242 <sys_getcount+0x6e>
    8000323c:	7e1c                	ld	a5,56(a2)
    8000323e:	fea799e3          	bne	a5,a0,80003230 <sys_getcount+0x5c>
      for (int i = 1; i < 31; i++) // iterate over all the syscalls and see the one that matches 1 <<i as mask
    80003242:	0001b717          	auipc	a4,0x1b
    80003246:	f9a70713          	addi	a4,a4,-102 # 8001e1dc <syscount+0x4>
  for (temp = proc; temp < &proc[NPROC]; temp++) // iterates over all the processes in the process table
    8000324a:	87f2                	mv	a5,t3
        if (mask == 1 << i)
    8000324c:	00f596bb          	sllw	a3,a1,a5
    80003250:	fd0683e3          	beq	a3,a6,80003216 <sys_getcount+0x42>
        syscount[i] = 0;
    80003254:	00072023          	sw	zero,0(a4)
      for (int i = 1; i < 31; i++) // iterate over all the syscalls and see the one that matches 1 <<i as mask
    80003258:	2785                	addiw	a5,a5,1
    8000325a:	0711                	addi	a4,a4,4
    8000325c:	ff1798e3          	bne	a5,a7,8000324c <sys_getcount+0x78>
    80003260:	bfc1                	j	80003230 <sys_getcount+0x5c>
  return count;
    80003262:	4501                	li	a0,0
    80003264:	b7d1                	j	80003228 <sys_getcount+0x54>

0000000080003266 <sys_sigalarm>:
int sys_sigalarm(void)
{
    80003266:	7179                	addi	sp,sp,-48
    80003268:	f406                	sd	ra,40(sp)
    8000326a:	f022                	sd	s0,32(sp)
    8000326c:	ec26                	sd	s1,24(sp)
    8000326e:	1800                	addi	s0,sp,48
  int ticks;
  if (argint(0, &ticks) < 0)
    80003270:	fdc40593          	addi	a1,s0,-36
    80003274:	4501                	li	a0,0
    80003276:	00000097          	auipc	ra,0x0
    8000327a:	baa080e7          	jalr	-1110(ra) # 80002e20 <argint>
    8000327e:	04054c63          	bltz	a0,800032d6 <sys_sigalarm+0x70>
    return -1;
  if (ticks < 0)
    80003282:	fdc42783          	lw	a5,-36(s0)
    80003286:	0207cf63          	bltz	a5,800032c4 <sys_sigalarm+0x5e>
    printf("Invalid number\n");
  }

  uint64 handler_address;

  if (argaddr(1, &handler_address) < 0)
    8000328a:	fd040593          	addi	a1,s0,-48
    8000328e:	4505                	li	a0,1
    80003290:	00000097          	auipc	ra,0x0
    80003294:	bb2080e7          	jalr	-1102(ra) # 80002e42 <argaddr>
    80003298:	04054163          	bltz	a0,800032da <sys_sigalarm+0x74>
    return -1;

  void (*handler)() = (void (*)())handler_address;
    8000329c:	fd043483          	ld	s1,-48(s0)

  struct proc *p = myproc();
    800032a0:	ffffe097          	auipc	ra,0xffffe
    800032a4:	73c080e7          	jalr	1852(ra) # 800019dc <myproc>
  p->alarmticks = ticks;
    800032a8:	fdc42783          	lw	a5,-36(s0)
    800032ac:	1ef52a23          	sw	a5,500(a0)
  p->alarmhandler = handler;
    800032b0:	20953023          	sd	s1,512(a0)
  p->ticks_passed = 0;
    800032b4:	1e052c23          	sw	zero,504(a0)
  return 0;
    800032b8:	4501                	li	a0,0
}
    800032ba:	70a2                	ld	ra,40(sp)
    800032bc:	7402                	ld	s0,32(sp)
    800032be:	64e2                	ld	s1,24(sp)
    800032c0:	6145                	addi	sp,sp,48
    800032c2:	8082                	ret
    printf("Invalid number\n");
    800032c4:	00005517          	auipc	a0,0x5
    800032c8:	26c50513          	addi	a0,a0,620 # 80008530 <syscalls+0xe0>
    800032cc:	ffffd097          	auipc	ra,0xffffd
    800032d0:	2be080e7          	jalr	702(ra) # 8000058a <printf>
    800032d4:	bf5d                	j	8000328a <sys_sigalarm+0x24>
    return -1;
    800032d6:	557d                	li	a0,-1
    800032d8:	b7cd                	j	800032ba <sys_sigalarm+0x54>
    return -1;
    800032da:	557d                	li	a0,-1
    800032dc:	bff9                	j	800032ba <sys_sigalarm+0x54>

00000000800032de <sys_sigreturn>:

int sys_sigreturn(void)
{
    800032de:	1101                	addi	sp,sp,-32
    800032e0:	ec06                	sd	ra,24(sp)
    800032e2:	e822                	sd	s0,16(sp)
    800032e4:	e426                	sd	s1,8(sp)
    800032e6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800032e8:	ffffe097          	auipc	ra,0xffffe
    800032ec:	6f4080e7          	jalr	1780(ra) # 800019dc <myproc>
    800032f0:	84aa                	mv	s1,a0
  memmove(p->trapframe, &p->alarm_tf, sizeof(struct trapframe));
    800032f2:	12000613          	li	a2,288
    800032f6:	20850593          	addi	a1,a0,520
    800032fa:	6d28                	ld	a0,88(a0)
    800032fc:	ffffe097          	auipc	ra,0xffffe
    80003300:	a32080e7          	jalr	-1486(ra) # 80000d2e <memmove>
  p->handling_alarm = 0;
    80003304:	3204a423          	sw	zero,808(s1)
  return p->alarm_tf.a0;
}
    80003308:	2784a503          	lw	a0,632(s1)
    8000330c:	60e2                	ld	ra,24(sp)
    8000330e:	6442                	ld	s0,16(sp)
    80003310:	64a2                	ld	s1,8(sp)
    80003312:	6105                	addi	sp,sp,32
    80003314:	8082                	ret

0000000080003316 <sys_settickets>:

// Sets the number of tickets for the calling process.
int sys_settickets(int number)
{
    80003316:	1101                	addi	sp,sp,-32
    80003318:	ec06                	sd	ra,24(sp)
    8000331a:	e822                	sd	s0,16(sp)
    8000331c:	e426                	sd	s1,8(sp)
    8000331e:	e04a                	sd	s2,0(sp)
    80003320:	1000                	addi	s0,sp,32
    80003322:	892a                	mv	s2,a0
  struct proc *p = myproc(); // get the current process
    80003324:	ffffe097          	auipc	ra,0xffffe
    80003328:	6b8080e7          	jalr	1720(ra) # 800019dc <myproc>
  if (number < 1)
    8000332c:	03205563          	blez	s2,80003356 <sys_settickets+0x40>
    80003330:	84aa                	mv	s1,a0
  {
    return -1; // invalid number of tickets
  }
  acquire(&p->lock);  // acquire lock to modify process state
    80003332:	ffffe097          	auipc	ra,0xffffe
    80003336:	8a4080e7          	jalr	-1884(ra) # 80000bd6 <acquire>
  p->ticket = number; // set the new ticket count
    8000333a:	3324a823          	sw	s2,816(s1)
  release(&p->lock);
    8000333e:	8526                	mv	a0,s1
    80003340:	ffffe097          	auipc	ra,0xffffe
    80003344:	94a080e7          	jalr	-1718(ra) # 80000c8a <release>
  return 0;
    80003348:	4501                	li	a0,0
}
    8000334a:	60e2                	ld	ra,24(sp)
    8000334c:	6442                	ld	s0,16(sp)
    8000334e:	64a2                	ld	s1,8(sp)
    80003350:	6902                	ld	s2,0(sp)
    80003352:	6105                	addi	sp,sp,32
    80003354:	8082                	ret
    return -1; // invalid number of tickets
    80003356:	557d                	li	a0,-1
    80003358:	bfcd                	j	8000334a <sys_settickets+0x34>

000000008000335a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000335a:	7179                	addi	sp,sp,-48
    8000335c:	f406                	sd	ra,40(sp)
    8000335e:	f022                	sd	s0,32(sp)
    80003360:	ec26                	sd	s1,24(sp)
    80003362:	e84a                	sd	s2,16(sp)
    80003364:	e44e                	sd	s3,8(sp)
    80003366:	e052                	sd	s4,0(sp)
    80003368:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000336a:	00005597          	auipc	a1,0x5
    8000336e:	1d658593          	addi	a1,a1,470 # 80008540 <syscalls+0xf0>
    80003372:	0001b517          	auipc	a0,0x1b
    80003376:	ee650513          	addi	a0,a0,-282 # 8001e258 <bcache>
    8000337a:	ffffd097          	auipc	ra,0xffffd
    8000337e:	7cc080e7          	jalr	1996(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003382:	00023797          	auipc	a5,0x23
    80003386:	ed678793          	addi	a5,a5,-298 # 80026258 <bcache+0x8000>
    8000338a:	00023717          	auipc	a4,0x23
    8000338e:	13670713          	addi	a4,a4,310 # 800264c0 <bcache+0x8268>
    80003392:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003396:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000339a:	0001b497          	auipc	s1,0x1b
    8000339e:	ed648493          	addi	s1,s1,-298 # 8001e270 <bcache+0x18>
    b->next = bcache.head.next;
    800033a2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800033a4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800033a6:	00005a17          	auipc	s4,0x5
    800033aa:	1a2a0a13          	addi	s4,s4,418 # 80008548 <syscalls+0xf8>
    b->next = bcache.head.next;
    800033ae:	2b893783          	ld	a5,696(s2)
    800033b2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033b4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033b8:	85d2                	mv	a1,s4
    800033ba:	01048513          	addi	a0,s1,16
    800033be:	00001097          	auipc	ra,0x1
    800033c2:	4c8080e7          	jalr	1224(ra) # 80004886 <initsleeplock>
    bcache.head.next->prev = b;
    800033c6:	2b893783          	ld	a5,696(s2)
    800033ca:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033cc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033d0:	45848493          	addi	s1,s1,1112
    800033d4:	fd349de3          	bne	s1,s3,800033ae <binit+0x54>
  }
}
    800033d8:	70a2                	ld	ra,40(sp)
    800033da:	7402                	ld	s0,32(sp)
    800033dc:	64e2                	ld	s1,24(sp)
    800033de:	6942                	ld	s2,16(sp)
    800033e0:	69a2                	ld	s3,8(sp)
    800033e2:	6a02                	ld	s4,0(sp)
    800033e4:	6145                	addi	sp,sp,48
    800033e6:	8082                	ret

00000000800033e8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033e8:	7179                	addi	sp,sp,-48
    800033ea:	f406                	sd	ra,40(sp)
    800033ec:	f022                	sd	s0,32(sp)
    800033ee:	ec26                	sd	s1,24(sp)
    800033f0:	e84a                	sd	s2,16(sp)
    800033f2:	e44e                	sd	s3,8(sp)
    800033f4:	1800                	addi	s0,sp,48
    800033f6:	892a                	mv	s2,a0
    800033f8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800033fa:	0001b517          	auipc	a0,0x1b
    800033fe:	e5e50513          	addi	a0,a0,-418 # 8001e258 <bcache>
    80003402:	ffffd097          	auipc	ra,0xffffd
    80003406:	7d4080e7          	jalr	2004(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000340a:	00023497          	auipc	s1,0x23
    8000340e:	1064b483          	ld	s1,262(s1) # 80026510 <bcache+0x82b8>
    80003412:	00023797          	auipc	a5,0x23
    80003416:	0ae78793          	addi	a5,a5,174 # 800264c0 <bcache+0x8268>
    8000341a:	02f48f63          	beq	s1,a5,80003458 <bread+0x70>
    8000341e:	873e                	mv	a4,a5
    80003420:	a021                	j	80003428 <bread+0x40>
    80003422:	68a4                	ld	s1,80(s1)
    80003424:	02e48a63          	beq	s1,a4,80003458 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003428:	449c                	lw	a5,8(s1)
    8000342a:	ff279ce3          	bne	a5,s2,80003422 <bread+0x3a>
    8000342e:	44dc                	lw	a5,12(s1)
    80003430:	ff3799e3          	bne	a5,s3,80003422 <bread+0x3a>
      b->refcnt++;
    80003434:	40bc                	lw	a5,64(s1)
    80003436:	2785                	addiw	a5,a5,1
    80003438:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000343a:	0001b517          	auipc	a0,0x1b
    8000343e:	e1e50513          	addi	a0,a0,-482 # 8001e258 <bcache>
    80003442:	ffffe097          	auipc	ra,0xffffe
    80003446:	848080e7          	jalr	-1976(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000344a:	01048513          	addi	a0,s1,16
    8000344e:	00001097          	auipc	ra,0x1
    80003452:	472080e7          	jalr	1138(ra) # 800048c0 <acquiresleep>
      return b;
    80003456:	a8b9                	j	800034b4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003458:	00023497          	auipc	s1,0x23
    8000345c:	0b04b483          	ld	s1,176(s1) # 80026508 <bcache+0x82b0>
    80003460:	00023797          	auipc	a5,0x23
    80003464:	06078793          	addi	a5,a5,96 # 800264c0 <bcache+0x8268>
    80003468:	00f48863          	beq	s1,a5,80003478 <bread+0x90>
    8000346c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000346e:	40bc                	lw	a5,64(s1)
    80003470:	cf81                	beqz	a5,80003488 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003472:	64a4                	ld	s1,72(s1)
    80003474:	fee49de3          	bne	s1,a4,8000346e <bread+0x86>
  panic("bget: no buffers");
    80003478:	00005517          	auipc	a0,0x5
    8000347c:	0d850513          	addi	a0,a0,216 # 80008550 <syscalls+0x100>
    80003480:	ffffd097          	auipc	ra,0xffffd
    80003484:	0c0080e7          	jalr	192(ra) # 80000540 <panic>
      b->dev = dev;
    80003488:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000348c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003490:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003494:	4785                	li	a5,1
    80003496:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003498:	0001b517          	auipc	a0,0x1b
    8000349c:	dc050513          	addi	a0,a0,-576 # 8001e258 <bcache>
    800034a0:	ffffd097          	auipc	ra,0xffffd
    800034a4:	7ea080e7          	jalr	2026(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800034a8:	01048513          	addi	a0,s1,16
    800034ac:	00001097          	auipc	ra,0x1
    800034b0:	414080e7          	jalr	1044(ra) # 800048c0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034b4:	409c                	lw	a5,0(s1)
    800034b6:	cb89                	beqz	a5,800034c8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034b8:	8526                	mv	a0,s1
    800034ba:	70a2                	ld	ra,40(sp)
    800034bc:	7402                	ld	s0,32(sp)
    800034be:	64e2                	ld	s1,24(sp)
    800034c0:	6942                	ld	s2,16(sp)
    800034c2:	69a2                	ld	s3,8(sp)
    800034c4:	6145                	addi	sp,sp,48
    800034c6:	8082                	ret
    virtio_disk_rw(b, 0);
    800034c8:	4581                	li	a1,0
    800034ca:	8526                	mv	a0,s1
    800034cc:	00003097          	auipc	ra,0x3
    800034d0:	fd6080e7          	jalr	-42(ra) # 800064a2 <virtio_disk_rw>
    b->valid = 1;
    800034d4:	4785                	li	a5,1
    800034d6:	c09c                	sw	a5,0(s1)
  return b;
    800034d8:	b7c5                	j	800034b8 <bread+0xd0>

00000000800034da <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034da:	1101                	addi	sp,sp,-32
    800034dc:	ec06                	sd	ra,24(sp)
    800034de:	e822                	sd	s0,16(sp)
    800034e0:	e426                	sd	s1,8(sp)
    800034e2:	1000                	addi	s0,sp,32
    800034e4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034e6:	0541                	addi	a0,a0,16
    800034e8:	00001097          	auipc	ra,0x1
    800034ec:	472080e7          	jalr	1138(ra) # 8000495a <holdingsleep>
    800034f0:	cd01                	beqz	a0,80003508 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800034f2:	4585                	li	a1,1
    800034f4:	8526                	mv	a0,s1
    800034f6:	00003097          	auipc	ra,0x3
    800034fa:	fac080e7          	jalr	-84(ra) # 800064a2 <virtio_disk_rw>
}
    800034fe:	60e2                	ld	ra,24(sp)
    80003500:	6442                	ld	s0,16(sp)
    80003502:	64a2                	ld	s1,8(sp)
    80003504:	6105                	addi	sp,sp,32
    80003506:	8082                	ret
    panic("bwrite");
    80003508:	00005517          	auipc	a0,0x5
    8000350c:	06050513          	addi	a0,a0,96 # 80008568 <syscalls+0x118>
    80003510:	ffffd097          	auipc	ra,0xffffd
    80003514:	030080e7          	jalr	48(ra) # 80000540 <panic>

0000000080003518 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003518:	1101                	addi	sp,sp,-32
    8000351a:	ec06                	sd	ra,24(sp)
    8000351c:	e822                	sd	s0,16(sp)
    8000351e:	e426                	sd	s1,8(sp)
    80003520:	e04a                	sd	s2,0(sp)
    80003522:	1000                	addi	s0,sp,32
    80003524:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003526:	01050913          	addi	s2,a0,16
    8000352a:	854a                	mv	a0,s2
    8000352c:	00001097          	auipc	ra,0x1
    80003530:	42e080e7          	jalr	1070(ra) # 8000495a <holdingsleep>
    80003534:	c92d                	beqz	a0,800035a6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003536:	854a                	mv	a0,s2
    80003538:	00001097          	auipc	ra,0x1
    8000353c:	3de080e7          	jalr	990(ra) # 80004916 <releasesleep>

  acquire(&bcache.lock);
    80003540:	0001b517          	auipc	a0,0x1b
    80003544:	d1850513          	addi	a0,a0,-744 # 8001e258 <bcache>
    80003548:	ffffd097          	auipc	ra,0xffffd
    8000354c:	68e080e7          	jalr	1678(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003550:	40bc                	lw	a5,64(s1)
    80003552:	37fd                	addiw	a5,a5,-1
    80003554:	0007871b          	sext.w	a4,a5
    80003558:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000355a:	eb05                	bnez	a4,8000358a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000355c:	68bc                	ld	a5,80(s1)
    8000355e:	64b8                	ld	a4,72(s1)
    80003560:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003562:	64bc                	ld	a5,72(s1)
    80003564:	68b8                	ld	a4,80(s1)
    80003566:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003568:	00023797          	auipc	a5,0x23
    8000356c:	cf078793          	addi	a5,a5,-784 # 80026258 <bcache+0x8000>
    80003570:	2b87b703          	ld	a4,696(a5)
    80003574:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003576:	00023717          	auipc	a4,0x23
    8000357a:	f4a70713          	addi	a4,a4,-182 # 800264c0 <bcache+0x8268>
    8000357e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003580:	2b87b703          	ld	a4,696(a5)
    80003584:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003586:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000358a:	0001b517          	auipc	a0,0x1b
    8000358e:	cce50513          	addi	a0,a0,-818 # 8001e258 <bcache>
    80003592:	ffffd097          	auipc	ra,0xffffd
    80003596:	6f8080e7          	jalr	1784(ra) # 80000c8a <release>
}
    8000359a:	60e2                	ld	ra,24(sp)
    8000359c:	6442                	ld	s0,16(sp)
    8000359e:	64a2                	ld	s1,8(sp)
    800035a0:	6902                	ld	s2,0(sp)
    800035a2:	6105                	addi	sp,sp,32
    800035a4:	8082                	ret
    panic("brelse");
    800035a6:	00005517          	auipc	a0,0x5
    800035aa:	fca50513          	addi	a0,a0,-54 # 80008570 <syscalls+0x120>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	f92080e7          	jalr	-110(ra) # 80000540 <panic>

00000000800035b6 <bpin>:

void
bpin(struct buf *b) {
    800035b6:	1101                	addi	sp,sp,-32
    800035b8:	ec06                	sd	ra,24(sp)
    800035ba:	e822                	sd	s0,16(sp)
    800035bc:	e426                	sd	s1,8(sp)
    800035be:	1000                	addi	s0,sp,32
    800035c0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035c2:	0001b517          	auipc	a0,0x1b
    800035c6:	c9650513          	addi	a0,a0,-874 # 8001e258 <bcache>
    800035ca:	ffffd097          	auipc	ra,0xffffd
    800035ce:	60c080e7          	jalr	1548(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800035d2:	40bc                	lw	a5,64(s1)
    800035d4:	2785                	addiw	a5,a5,1
    800035d6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035d8:	0001b517          	auipc	a0,0x1b
    800035dc:	c8050513          	addi	a0,a0,-896 # 8001e258 <bcache>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	6aa080e7          	jalr	1706(ra) # 80000c8a <release>
}
    800035e8:	60e2                	ld	ra,24(sp)
    800035ea:	6442                	ld	s0,16(sp)
    800035ec:	64a2                	ld	s1,8(sp)
    800035ee:	6105                	addi	sp,sp,32
    800035f0:	8082                	ret

00000000800035f2 <bunpin>:

void
bunpin(struct buf *b) {
    800035f2:	1101                	addi	sp,sp,-32
    800035f4:	ec06                	sd	ra,24(sp)
    800035f6:	e822                	sd	s0,16(sp)
    800035f8:	e426                	sd	s1,8(sp)
    800035fa:	1000                	addi	s0,sp,32
    800035fc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035fe:	0001b517          	auipc	a0,0x1b
    80003602:	c5a50513          	addi	a0,a0,-934 # 8001e258 <bcache>
    80003606:	ffffd097          	auipc	ra,0xffffd
    8000360a:	5d0080e7          	jalr	1488(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000360e:	40bc                	lw	a5,64(s1)
    80003610:	37fd                	addiw	a5,a5,-1
    80003612:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003614:	0001b517          	auipc	a0,0x1b
    80003618:	c4450513          	addi	a0,a0,-956 # 8001e258 <bcache>
    8000361c:	ffffd097          	auipc	ra,0xffffd
    80003620:	66e080e7          	jalr	1646(ra) # 80000c8a <release>
}
    80003624:	60e2                	ld	ra,24(sp)
    80003626:	6442                	ld	s0,16(sp)
    80003628:	64a2                	ld	s1,8(sp)
    8000362a:	6105                	addi	sp,sp,32
    8000362c:	8082                	ret

000000008000362e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000362e:	1101                	addi	sp,sp,-32
    80003630:	ec06                	sd	ra,24(sp)
    80003632:	e822                	sd	s0,16(sp)
    80003634:	e426                	sd	s1,8(sp)
    80003636:	e04a                	sd	s2,0(sp)
    80003638:	1000                	addi	s0,sp,32
    8000363a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000363c:	00d5d59b          	srliw	a1,a1,0xd
    80003640:	00023797          	auipc	a5,0x23
    80003644:	2f47a783          	lw	a5,756(a5) # 80026934 <sb+0x1c>
    80003648:	9dbd                	addw	a1,a1,a5
    8000364a:	00000097          	auipc	ra,0x0
    8000364e:	d9e080e7          	jalr	-610(ra) # 800033e8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003652:	0074f713          	andi	a4,s1,7
    80003656:	4785                	li	a5,1
    80003658:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000365c:	14ce                	slli	s1,s1,0x33
    8000365e:	90d9                	srli	s1,s1,0x36
    80003660:	00950733          	add	a4,a0,s1
    80003664:	05874703          	lbu	a4,88(a4)
    80003668:	00e7f6b3          	and	a3,a5,a4
    8000366c:	c69d                	beqz	a3,8000369a <bfree+0x6c>
    8000366e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003670:	94aa                	add	s1,s1,a0
    80003672:	fff7c793          	not	a5,a5
    80003676:	8f7d                	and	a4,a4,a5
    80003678:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000367c:	00001097          	auipc	ra,0x1
    80003680:	126080e7          	jalr	294(ra) # 800047a2 <log_write>
  brelse(bp);
    80003684:	854a                	mv	a0,s2
    80003686:	00000097          	auipc	ra,0x0
    8000368a:	e92080e7          	jalr	-366(ra) # 80003518 <brelse>
}
    8000368e:	60e2                	ld	ra,24(sp)
    80003690:	6442                	ld	s0,16(sp)
    80003692:	64a2                	ld	s1,8(sp)
    80003694:	6902                	ld	s2,0(sp)
    80003696:	6105                	addi	sp,sp,32
    80003698:	8082                	ret
    panic("freeing free block");
    8000369a:	00005517          	auipc	a0,0x5
    8000369e:	ede50513          	addi	a0,a0,-290 # 80008578 <syscalls+0x128>
    800036a2:	ffffd097          	auipc	ra,0xffffd
    800036a6:	e9e080e7          	jalr	-354(ra) # 80000540 <panic>

00000000800036aa <balloc>:
{
    800036aa:	711d                	addi	sp,sp,-96
    800036ac:	ec86                	sd	ra,88(sp)
    800036ae:	e8a2                	sd	s0,80(sp)
    800036b0:	e4a6                	sd	s1,72(sp)
    800036b2:	e0ca                	sd	s2,64(sp)
    800036b4:	fc4e                	sd	s3,56(sp)
    800036b6:	f852                	sd	s4,48(sp)
    800036b8:	f456                	sd	s5,40(sp)
    800036ba:	f05a                	sd	s6,32(sp)
    800036bc:	ec5e                	sd	s7,24(sp)
    800036be:	e862                	sd	s8,16(sp)
    800036c0:	e466                	sd	s9,8(sp)
    800036c2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036c4:	00023797          	auipc	a5,0x23
    800036c8:	2587a783          	lw	a5,600(a5) # 8002691c <sb+0x4>
    800036cc:	cff5                	beqz	a5,800037c8 <balloc+0x11e>
    800036ce:	8baa                	mv	s7,a0
    800036d0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036d2:	00023b17          	auipc	s6,0x23
    800036d6:	246b0b13          	addi	s6,s6,582 # 80026918 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036da:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036dc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036de:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036e0:	6c89                	lui	s9,0x2
    800036e2:	a061                	j	8000376a <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036e4:	97ca                	add	a5,a5,s2
    800036e6:	8e55                	or	a2,a2,a3
    800036e8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800036ec:	854a                	mv	a0,s2
    800036ee:	00001097          	auipc	ra,0x1
    800036f2:	0b4080e7          	jalr	180(ra) # 800047a2 <log_write>
        brelse(bp);
    800036f6:	854a                	mv	a0,s2
    800036f8:	00000097          	auipc	ra,0x0
    800036fc:	e20080e7          	jalr	-480(ra) # 80003518 <brelse>
  bp = bread(dev, bno);
    80003700:	85a6                	mv	a1,s1
    80003702:	855e                	mv	a0,s7
    80003704:	00000097          	auipc	ra,0x0
    80003708:	ce4080e7          	jalr	-796(ra) # 800033e8 <bread>
    8000370c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000370e:	40000613          	li	a2,1024
    80003712:	4581                	li	a1,0
    80003714:	05850513          	addi	a0,a0,88
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	5ba080e7          	jalr	1466(ra) # 80000cd2 <memset>
  log_write(bp);
    80003720:	854a                	mv	a0,s2
    80003722:	00001097          	auipc	ra,0x1
    80003726:	080080e7          	jalr	128(ra) # 800047a2 <log_write>
  brelse(bp);
    8000372a:	854a                	mv	a0,s2
    8000372c:	00000097          	auipc	ra,0x0
    80003730:	dec080e7          	jalr	-532(ra) # 80003518 <brelse>
}
    80003734:	8526                	mv	a0,s1
    80003736:	60e6                	ld	ra,88(sp)
    80003738:	6446                	ld	s0,80(sp)
    8000373a:	64a6                	ld	s1,72(sp)
    8000373c:	6906                	ld	s2,64(sp)
    8000373e:	79e2                	ld	s3,56(sp)
    80003740:	7a42                	ld	s4,48(sp)
    80003742:	7aa2                	ld	s5,40(sp)
    80003744:	7b02                	ld	s6,32(sp)
    80003746:	6be2                	ld	s7,24(sp)
    80003748:	6c42                	ld	s8,16(sp)
    8000374a:	6ca2                	ld	s9,8(sp)
    8000374c:	6125                	addi	sp,sp,96
    8000374e:	8082                	ret
    brelse(bp);
    80003750:	854a                	mv	a0,s2
    80003752:	00000097          	auipc	ra,0x0
    80003756:	dc6080e7          	jalr	-570(ra) # 80003518 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000375a:	015c87bb          	addw	a5,s9,s5
    8000375e:	00078a9b          	sext.w	s5,a5
    80003762:	004b2703          	lw	a4,4(s6)
    80003766:	06eaf163          	bgeu	s5,a4,800037c8 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000376a:	41fad79b          	sraiw	a5,s5,0x1f
    8000376e:	0137d79b          	srliw	a5,a5,0x13
    80003772:	015787bb          	addw	a5,a5,s5
    80003776:	40d7d79b          	sraiw	a5,a5,0xd
    8000377a:	01cb2583          	lw	a1,28(s6)
    8000377e:	9dbd                	addw	a1,a1,a5
    80003780:	855e                	mv	a0,s7
    80003782:	00000097          	auipc	ra,0x0
    80003786:	c66080e7          	jalr	-922(ra) # 800033e8 <bread>
    8000378a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000378c:	004b2503          	lw	a0,4(s6)
    80003790:	000a849b          	sext.w	s1,s5
    80003794:	8762                	mv	a4,s8
    80003796:	faa4fde3          	bgeu	s1,a0,80003750 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000379a:	00777693          	andi	a3,a4,7
    8000379e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037a2:	41f7579b          	sraiw	a5,a4,0x1f
    800037a6:	01d7d79b          	srliw	a5,a5,0x1d
    800037aa:	9fb9                	addw	a5,a5,a4
    800037ac:	4037d79b          	sraiw	a5,a5,0x3
    800037b0:	00f90633          	add	a2,s2,a5
    800037b4:	05864603          	lbu	a2,88(a2)
    800037b8:	00c6f5b3          	and	a1,a3,a2
    800037bc:	d585                	beqz	a1,800036e4 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037be:	2705                	addiw	a4,a4,1
    800037c0:	2485                	addiw	s1,s1,1
    800037c2:	fd471ae3          	bne	a4,s4,80003796 <balloc+0xec>
    800037c6:	b769                	j	80003750 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800037c8:	00005517          	auipc	a0,0x5
    800037cc:	dc850513          	addi	a0,a0,-568 # 80008590 <syscalls+0x140>
    800037d0:	ffffd097          	auipc	ra,0xffffd
    800037d4:	dba080e7          	jalr	-582(ra) # 8000058a <printf>
  return 0;
    800037d8:	4481                	li	s1,0
    800037da:	bfa9                	j	80003734 <balloc+0x8a>

00000000800037dc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037dc:	7179                	addi	sp,sp,-48
    800037de:	f406                	sd	ra,40(sp)
    800037e0:	f022                	sd	s0,32(sp)
    800037e2:	ec26                	sd	s1,24(sp)
    800037e4:	e84a                	sd	s2,16(sp)
    800037e6:	e44e                	sd	s3,8(sp)
    800037e8:	e052                	sd	s4,0(sp)
    800037ea:	1800                	addi	s0,sp,48
    800037ec:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037ee:	47ad                	li	a5,11
    800037f0:	02b7e863          	bltu	a5,a1,80003820 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800037f4:	02059793          	slli	a5,a1,0x20
    800037f8:	01e7d593          	srli	a1,a5,0x1e
    800037fc:	00b504b3          	add	s1,a0,a1
    80003800:	0504a903          	lw	s2,80(s1)
    80003804:	06091e63          	bnez	s2,80003880 <bmap+0xa4>
      addr = balloc(ip->dev);
    80003808:	4108                	lw	a0,0(a0)
    8000380a:	00000097          	auipc	ra,0x0
    8000380e:	ea0080e7          	jalr	-352(ra) # 800036aa <balloc>
    80003812:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003816:	06090563          	beqz	s2,80003880 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    8000381a:	0524a823          	sw	s2,80(s1)
    8000381e:	a08d                	j	80003880 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003820:	ff45849b          	addiw	s1,a1,-12
    80003824:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003828:	0ff00793          	li	a5,255
    8000382c:	08e7e563          	bltu	a5,a4,800038b6 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003830:	08052903          	lw	s2,128(a0)
    80003834:	00091d63          	bnez	s2,8000384e <bmap+0x72>
      addr = balloc(ip->dev);
    80003838:	4108                	lw	a0,0(a0)
    8000383a:	00000097          	auipc	ra,0x0
    8000383e:	e70080e7          	jalr	-400(ra) # 800036aa <balloc>
    80003842:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003846:	02090d63          	beqz	s2,80003880 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000384a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000384e:	85ca                	mv	a1,s2
    80003850:	0009a503          	lw	a0,0(s3)
    80003854:	00000097          	auipc	ra,0x0
    80003858:	b94080e7          	jalr	-1132(ra) # 800033e8 <bread>
    8000385c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000385e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003862:	02049713          	slli	a4,s1,0x20
    80003866:	01e75593          	srli	a1,a4,0x1e
    8000386a:	00b784b3          	add	s1,a5,a1
    8000386e:	0004a903          	lw	s2,0(s1)
    80003872:	02090063          	beqz	s2,80003892 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003876:	8552                	mv	a0,s4
    80003878:	00000097          	auipc	ra,0x0
    8000387c:	ca0080e7          	jalr	-864(ra) # 80003518 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003880:	854a                	mv	a0,s2
    80003882:	70a2                	ld	ra,40(sp)
    80003884:	7402                	ld	s0,32(sp)
    80003886:	64e2                	ld	s1,24(sp)
    80003888:	6942                	ld	s2,16(sp)
    8000388a:	69a2                	ld	s3,8(sp)
    8000388c:	6a02                	ld	s4,0(sp)
    8000388e:	6145                	addi	sp,sp,48
    80003890:	8082                	ret
      addr = balloc(ip->dev);
    80003892:	0009a503          	lw	a0,0(s3)
    80003896:	00000097          	auipc	ra,0x0
    8000389a:	e14080e7          	jalr	-492(ra) # 800036aa <balloc>
    8000389e:	0005091b          	sext.w	s2,a0
      if(addr){
    800038a2:	fc090ae3          	beqz	s2,80003876 <bmap+0x9a>
        a[bn] = addr;
    800038a6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800038aa:	8552                	mv	a0,s4
    800038ac:	00001097          	auipc	ra,0x1
    800038b0:	ef6080e7          	jalr	-266(ra) # 800047a2 <log_write>
    800038b4:	b7c9                	j	80003876 <bmap+0x9a>
  panic("bmap: out of range");
    800038b6:	00005517          	auipc	a0,0x5
    800038ba:	cf250513          	addi	a0,a0,-782 # 800085a8 <syscalls+0x158>
    800038be:	ffffd097          	auipc	ra,0xffffd
    800038c2:	c82080e7          	jalr	-894(ra) # 80000540 <panic>

00000000800038c6 <iget>:
{
    800038c6:	7179                	addi	sp,sp,-48
    800038c8:	f406                	sd	ra,40(sp)
    800038ca:	f022                	sd	s0,32(sp)
    800038cc:	ec26                	sd	s1,24(sp)
    800038ce:	e84a                	sd	s2,16(sp)
    800038d0:	e44e                	sd	s3,8(sp)
    800038d2:	e052                	sd	s4,0(sp)
    800038d4:	1800                	addi	s0,sp,48
    800038d6:	89aa                	mv	s3,a0
    800038d8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038da:	00023517          	auipc	a0,0x23
    800038de:	05e50513          	addi	a0,a0,94 # 80026938 <itable>
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	2f4080e7          	jalr	756(ra) # 80000bd6 <acquire>
  empty = 0;
    800038ea:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038ec:	00023497          	auipc	s1,0x23
    800038f0:	06448493          	addi	s1,s1,100 # 80026950 <itable+0x18>
    800038f4:	00025697          	auipc	a3,0x25
    800038f8:	aec68693          	addi	a3,a3,-1300 # 800283e0 <log>
    800038fc:	a039                	j	8000390a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038fe:	02090b63          	beqz	s2,80003934 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003902:	08848493          	addi	s1,s1,136
    80003906:	02d48a63          	beq	s1,a3,8000393a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000390a:	449c                	lw	a5,8(s1)
    8000390c:	fef059e3          	blez	a5,800038fe <iget+0x38>
    80003910:	4098                	lw	a4,0(s1)
    80003912:	ff3716e3          	bne	a4,s3,800038fe <iget+0x38>
    80003916:	40d8                	lw	a4,4(s1)
    80003918:	ff4713e3          	bne	a4,s4,800038fe <iget+0x38>
      ip->ref++;
    8000391c:	2785                	addiw	a5,a5,1
    8000391e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003920:	00023517          	auipc	a0,0x23
    80003924:	01850513          	addi	a0,a0,24 # 80026938 <itable>
    80003928:	ffffd097          	auipc	ra,0xffffd
    8000392c:	362080e7          	jalr	866(ra) # 80000c8a <release>
      return ip;
    80003930:	8926                	mv	s2,s1
    80003932:	a03d                	j	80003960 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003934:	f7f9                	bnez	a5,80003902 <iget+0x3c>
    80003936:	8926                	mv	s2,s1
    80003938:	b7e9                	j	80003902 <iget+0x3c>
  if(empty == 0)
    8000393a:	02090c63          	beqz	s2,80003972 <iget+0xac>
  ip->dev = dev;
    8000393e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003942:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003946:	4785                	li	a5,1
    80003948:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000394c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003950:	00023517          	auipc	a0,0x23
    80003954:	fe850513          	addi	a0,a0,-24 # 80026938 <itable>
    80003958:	ffffd097          	auipc	ra,0xffffd
    8000395c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80003960:	854a                	mv	a0,s2
    80003962:	70a2                	ld	ra,40(sp)
    80003964:	7402                	ld	s0,32(sp)
    80003966:	64e2                	ld	s1,24(sp)
    80003968:	6942                	ld	s2,16(sp)
    8000396a:	69a2                	ld	s3,8(sp)
    8000396c:	6a02                	ld	s4,0(sp)
    8000396e:	6145                	addi	sp,sp,48
    80003970:	8082                	ret
    panic("iget: no inodes");
    80003972:	00005517          	auipc	a0,0x5
    80003976:	c4e50513          	addi	a0,a0,-946 # 800085c0 <syscalls+0x170>
    8000397a:	ffffd097          	auipc	ra,0xffffd
    8000397e:	bc6080e7          	jalr	-1082(ra) # 80000540 <panic>

0000000080003982 <fsinit>:
fsinit(int dev) {
    80003982:	7179                	addi	sp,sp,-48
    80003984:	f406                	sd	ra,40(sp)
    80003986:	f022                	sd	s0,32(sp)
    80003988:	ec26                	sd	s1,24(sp)
    8000398a:	e84a                	sd	s2,16(sp)
    8000398c:	e44e                	sd	s3,8(sp)
    8000398e:	1800                	addi	s0,sp,48
    80003990:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003992:	4585                	li	a1,1
    80003994:	00000097          	auipc	ra,0x0
    80003998:	a54080e7          	jalr	-1452(ra) # 800033e8 <bread>
    8000399c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000399e:	00023997          	auipc	s3,0x23
    800039a2:	f7a98993          	addi	s3,s3,-134 # 80026918 <sb>
    800039a6:	02000613          	li	a2,32
    800039aa:	05850593          	addi	a1,a0,88
    800039ae:	854e                	mv	a0,s3
    800039b0:	ffffd097          	auipc	ra,0xffffd
    800039b4:	37e080e7          	jalr	894(ra) # 80000d2e <memmove>
  brelse(bp);
    800039b8:	8526                	mv	a0,s1
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	b5e080e7          	jalr	-1186(ra) # 80003518 <brelse>
  if(sb.magic != FSMAGIC)
    800039c2:	0009a703          	lw	a4,0(s3)
    800039c6:	102037b7          	lui	a5,0x10203
    800039ca:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039ce:	02f71263          	bne	a4,a5,800039f2 <fsinit+0x70>
  initlog(dev, &sb);
    800039d2:	00023597          	auipc	a1,0x23
    800039d6:	f4658593          	addi	a1,a1,-186 # 80026918 <sb>
    800039da:	854a                	mv	a0,s2
    800039dc:	00001097          	auipc	ra,0x1
    800039e0:	b4a080e7          	jalr	-1206(ra) # 80004526 <initlog>
}
    800039e4:	70a2                	ld	ra,40(sp)
    800039e6:	7402                	ld	s0,32(sp)
    800039e8:	64e2                	ld	s1,24(sp)
    800039ea:	6942                	ld	s2,16(sp)
    800039ec:	69a2                	ld	s3,8(sp)
    800039ee:	6145                	addi	sp,sp,48
    800039f0:	8082                	ret
    panic("invalid file system");
    800039f2:	00005517          	auipc	a0,0x5
    800039f6:	bde50513          	addi	a0,a0,-1058 # 800085d0 <syscalls+0x180>
    800039fa:	ffffd097          	auipc	ra,0xffffd
    800039fe:	b46080e7          	jalr	-1210(ra) # 80000540 <panic>

0000000080003a02 <iinit>:
{
    80003a02:	7179                	addi	sp,sp,-48
    80003a04:	f406                	sd	ra,40(sp)
    80003a06:	f022                	sd	s0,32(sp)
    80003a08:	ec26                	sd	s1,24(sp)
    80003a0a:	e84a                	sd	s2,16(sp)
    80003a0c:	e44e                	sd	s3,8(sp)
    80003a0e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a10:	00005597          	auipc	a1,0x5
    80003a14:	bd858593          	addi	a1,a1,-1064 # 800085e8 <syscalls+0x198>
    80003a18:	00023517          	auipc	a0,0x23
    80003a1c:	f2050513          	addi	a0,a0,-224 # 80026938 <itable>
    80003a20:	ffffd097          	auipc	ra,0xffffd
    80003a24:	126080e7          	jalr	294(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a28:	00023497          	auipc	s1,0x23
    80003a2c:	f3848493          	addi	s1,s1,-200 # 80026960 <itable+0x28>
    80003a30:	00025997          	auipc	s3,0x25
    80003a34:	9c098993          	addi	s3,s3,-1600 # 800283f0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a38:	00005917          	auipc	s2,0x5
    80003a3c:	bb890913          	addi	s2,s2,-1096 # 800085f0 <syscalls+0x1a0>
    80003a40:	85ca                	mv	a1,s2
    80003a42:	8526                	mv	a0,s1
    80003a44:	00001097          	auipc	ra,0x1
    80003a48:	e42080e7          	jalr	-446(ra) # 80004886 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a4c:	08848493          	addi	s1,s1,136
    80003a50:	ff3498e3          	bne	s1,s3,80003a40 <iinit+0x3e>
}
    80003a54:	70a2                	ld	ra,40(sp)
    80003a56:	7402                	ld	s0,32(sp)
    80003a58:	64e2                	ld	s1,24(sp)
    80003a5a:	6942                	ld	s2,16(sp)
    80003a5c:	69a2                	ld	s3,8(sp)
    80003a5e:	6145                	addi	sp,sp,48
    80003a60:	8082                	ret

0000000080003a62 <ialloc>:
{
    80003a62:	715d                	addi	sp,sp,-80
    80003a64:	e486                	sd	ra,72(sp)
    80003a66:	e0a2                	sd	s0,64(sp)
    80003a68:	fc26                	sd	s1,56(sp)
    80003a6a:	f84a                	sd	s2,48(sp)
    80003a6c:	f44e                	sd	s3,40(sp)
    80003a6e:	f052                	sd	s4,32(sp)
    80003a70:	ec56                	sd	s5,24(sp)
    80003a72:	e85a                	sd	s6,16(sp)
    80003a74:	e45e                	sd	s7,8(sp)
    80003a76:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a78:	00023717          	auipc	a4,0x23
    80003a7c:	eac72703          	lw	a4,-340(a4) # 80026924 <sb+0xc>
    80003a80:	4785                	li	a5,1
    80003a82:	04e7fa63          	bgeu	a5,a4,80003ad6 <ialloc+0x74>
    80003a86:	8aaa                	mv	s5,a0
    80003a88:	8bae                	mv	s7,a1
    80003a8a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a8c:	00023a17          	auipc	s4,0x23
    80003a90:	e8ca0a13          	addi	s4,s4,-372 # 80026918 <sb>
    80003a94:	00048b1b          	sext.w	s6,s1
    80003a98:	0044d593          	srli	a1,s1,0x4
    80003a9c:	018a2783          	lw	a5,24(s4)
    80003aa0:	9dbd                	addw	a1,a1,a5
    80003aa2:	8556                	mv	a0,s5
    80003aa4:	00000097          	auipc	ra,0x0
    80003aa8:	944080e7          	jalr	-1724(ra) # 800033e8 <bread>
    80003aac:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003aae:	05850993          	addi	s3,a0,88
    80003ab2:	00f4f793          	andi	a5,s1,15
    80003ab6:	079a                	slli	a5,a5,0x6
    80003ab8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003aba:	00099783          	lh	a5,0(s3)
    80003abe:	c3a1                	beqz	a5,80003afe <ialloc+0x9c>
    brelse(bp);
    80003ac0:	00000097          	auipc	ra,0x0
    80003ac4:	a58080e7          	jalr	-1448(ra) # 80003518 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ac8:	0485                	addi	s1,s1,1
    80003aca:	00ca2703          	lw	a4,12(s4)
    80003ace:	0004879b          	sext.w	a5,s1
    80003ad2:	fce7e1e3          	bltu	a5,a4,80003a94 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003ad6:	00005517          	auipc	a0,0x5
    80003ada:	b2250513          	addi	a0,a0,-1246 # 800085f8 <syscalls+0x1a8>
    80003ade:	ffffd097          	auipc	ra,0xffffd
    80003ae2:	aac080e7          	jalr	-1364(ra) # 8000058a <printf>
  return 0;
    80003ae6:	4501                	li	a0,0
}
    80003ae8:	60a6                	ld	ra,72(sp)
    80003aea:	6406                	ld	s0,64(sp)
    80003aec:	74e2                	ld	s1,56(sp)
    80003aee:	7942                	ld	s2,48(sp)
    80003af0:	79a2                	ld	s3,40(sp)
    80003af2:	7a02                	ld	s4,32(sp)
    80003af4:	6ae2                	ld	s5,24(sp)
    80003af6:	6b42                	ld	s6,16(sp)
    80003af8:	6ba2                	ld	s7,8(sp)
    80003afa:	6161                	addi	sp,sp,80
    80003afc:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003afe:	04000613          	li	a2,64
    80003b02:	4581                	li	a1,0
    80003b04:	854e                	mv	a0,s3
    80003b06:	ffffd097          	auipc	ra,0xffffd
    80003b0a:	1cc080e7          	jalr	460(ra) # 80000cd2 <memset>
      dip->type = type;
    80003b0e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b12:	854a                	mv	a0,s2
    80003b14:	00001097          	auipc	ra,0x1
    80003b18:	c8e080e7          	jalr	-882(ra) # 800047a2 <log_write>
      brelse(bp);
    80003b1c:	854a                	mv	a0,s2
    80003b1e:	00000097          	auipc	ra,0x0
    80003b22:	9fa080e7          	jalr	-1542(ra) # 80003518 <brelse>
      return iget(dev, inum);
    80003b26:	85da                	mv	a1,s6
    80003b28:	8556                	mv	a0,s5
    80003b2a:	00000097          	auipc	ra,0x0
    80003b2e:	d9c080e7          	jalr	-612(ra) # 800038c6 <iget>
    80003b32:	bf5d                	j	80003ae8 <ialloc+0x86>

0000000080003b34 <iupdate>:
{
    80003b34:	1101                	addi	sp,sp,-32
    80003b36:	ec06                	sd	ra,24(sp)
    80003b38:	e822                	sd	s0,16(sp)
    80003b3a:	e426                	sd	s1,8(sp)
    80003b3c:	e04a                	sd	s2,0(sp)
    80003b3e:	1000                	addi	s0,sp,32
    80003b40:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b42:	415c                	lw	a5,4(a0)
    80003b44:	0047d79b          	srliw	a5,a5,0x4
    80003b48:	00023597          	auipc	a1,0x23
    80003b4c:	de85a583          	lw	a1,-536(a1) # 80026930 <sb+0x18>
    80003b50:	9dbd                	addw	a1,a1,a5
    80003b52:	4108                	lw	a0,0(a0)
    80003b54:	00000097          	auipc	ra,0x0
    80003b58:	894080e7          	jalr	-1900(ra) # 800033e8 <bread>
    80003b5c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b5e:	05850793          	addi	a5,a0,88
    80003b62:	40d8                	lw	a4,4(s1)
    80003b64:	8b3d                	andi	a4,a4,15
    80003b66:	071a                	slli	a4,a4,0x6
    80003b68:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003b6a:	04449703          	lh	a4,68(s1)
    80003b6e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003b72:	04649703          	lh	a4,70(s1)
    80003b76:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b7a:	04849703          	lh	a4,72(s1)
    80003b7e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b82:	04a49703          	lh	a4,74(s1)
    80003b86:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003b8a:	44f8                	lw	a4,76(s1)
    80003b8c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b8e:	03400613          	li	a2,52
    80003b92:	05048593          	addi	a1,s1,80
    80003b96:	00c78513          	addi	a0,a5,12
    80003b9a:	ffffd097          	auipc	ra,0xffffd
    80003b9e:	194080e7          	jalr	404(ra) # 80000d2e <memmove>
  log_write(bp);
    80003ba2:	854a                	mv	a0,s2
    80003ba4:	00001097          	auipc	ra,0x1
    80003ba8:	bfe080e7          	jalr	-1026(ra) # 800047a2 <log_write>
  brelse(bp);
    80003bac:	854a                	mv	a0,s2
    80003bae:	00000097          	auipc	ra,0x0
    80003bb2:	96a080e7          	jalr	-1686(ra) # 80003518 <brelse>
}
    80003bb6:	60e2                	ld	ra,24(sp)
    80003bb8:	6442                	ld	s0,16(sp)
    80003bba:	64a2                	ld	s1,8(sp)
    80003bbc:	6902                	ld	s2,0(sp)
    80003bbe:	6105                	addi	sp,sp,32
    80003bc0:	8082                	ret

0000000080003bc2 <idup>:
{
    80003bc2:	1101                	addi	sp,sp,-32
    80003bc4:	ec06                	sd	ra,24(sp)
    80003bc6:	e822                	sd	s0,16(sp)
    80003bc8:	e426                	sd	s1,8(sp)
    80003bca:	1000                	addi	s0,sp,32
    80003bcc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003bce:	00023517          	auipc	a0,0x23
    80003bd2:	d6a50513          	addi	a0,a0,-662 # 80026938 <itable>
    80003bd6:	ffffd097          	auipc	ra,0xffffd
    80003bda:	000080e7          	jalr	ra # 80000bd6 <acquire>
  ip->ref++;
    80003bde:	449c                	lw	a5,8(s1)
    80003be0:	2785                	addiw	a5,a5,1
    80003be2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003be4:	00023517          	auipc	a0,0x23
    80003be8:	d5450513          	addi	a0,a0,-684 # 80026938 <itable>
    80003bec:	ffffd097          	auipc	ra,0xffffd
    80003bf0:	09e080e7          	jalr	158(ra) # 80000c8a <release>
}
    80003bf4:	8526                	mv	a0,s1
    80003bf6:	60e2                	ld	ra,24(sp)
    80003bf8:	6442                	ld	s0,16(sp)
    80003bfa:	64a2                	ld	s1,8(sp)
    80003bfc:	6105                	addi	sp,sp,32
    80003bfe:	8082                	ret

0000000080003c00 <ilock>:
{
    80003c00:	1101                	addi	sp,sp,-32
    80003c02:	ec06                	sd	ra,24(sp)
    80003c04:	e822                	sd	s0,16(sp)
    80003c06:	e426                	sd	s1,8(sp)
    80003c08:	e04a                	sd	s2,0(sp)
    80003c0a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c0c:	c115                	beqz	a0,80003c30 <ilock+0x30>
    80003c0e:	84aa                	mv	s1,a0
    80003c10:	451c                	lw	a5,8(a0)
    80003c12:	00f05f63          	blez	a5,80003c30 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c16:	0541                	addi	a0,a0,16
    80003c18:	00001097          	auipc	ra,0x1
    80003c1c:	ca8080e7          	jalr	-856(ra) # 800048c0 <acquiresleep>
  if(ip->valid == 0){
    80003c20:	40bc                	lw	a5,64(s1)
    80003c22:	cf99                	beqz	a5,80003c40 <ilock+0x40>
}
    80003c24:	60e2                	ld	ra,24(sp)
    80003c26:	6442                	ld	s0,16(sp)
    80003c28:	64a2                	ld	s1,8(sp)
    80003c2a:	6902                	ld	s2,0(sp)
    80003c2c:	6105                	addi	sp,sp,32
    80003c2e:	8082                	ret
    panic("ilock");
    80003c30:	00005517          	auipc	a0,0x5
    80003c34:	9e050513          	addi	a0,a0,-1568 # 80008610 <syscalls+0x1c0>
    80003c38:	ffffd097          	auipc	ra,0xffffd
    80003c3c:	908080e7          	jalr	-1784(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c40:	40dc                	lw	a5,4(s1)
    80003c42:	0047d79b          	srliw	a5,a5,0x4
    80003c46:	00023597          	auipc	a1,0x23
    80003c4a:	cea5a583          	lw	a1,-790(a1) # 80026930 <sb+0x18>
    80003c4e:	9dbd                	addw	a1,a1,a5
    80003c50:	4088                	lw	a0,0(s1)
    80003c52:	fffff097          	auipc	ra,0xfffff
    80003c56:	796080e7          	jalr	1942(ra) # 800033e8 <bread>
    80003c5a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c5c:	05850593          	addi	a1,a0,88
    80003c60:	40dc                	lw	a5,4(s1)
    80003c62:	8bbd                	andi	a5,a5,15
    80003c64:	079a                	slli	a5,a5,0x6
    80003c66:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c68:	00059783          	lh	a5,0(a1)
    80003c6c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c70:	00259783          	lh	a5,2(a1)
    80003c74:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c78:	00459783          	lh	a5,4(a1)
    80003c7c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c80:	00659783          	lh	a5,6(a1)
    80003c84:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c88:	459c                	lw	a5,8(a1)
    80003c8a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c8c:	03400613          	li	a2,52
    80003c90:	05b1                	addi	a1,a1,12
    80003c92:	05048513          	addi	a0,s1,80
    80003c96:	ffffd097          	auipc	ra,0xffffd
    80003c9a:	098080e7          	jalr	152(ra) # 80000d2e <memmove>
    brelse(bp);
    80003c9e:	854a                	mv	a0,s2
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	878080e7          	jalr	-1928(ra) # 80003518 <brelse>
    ip->valid = 1;
    80003ca8:	4785                	li	a5,1
    80003caa:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003cac:	04449783          	lh	a5,68(s1)
    80003cb0:	fbb5                	bnez	a5,80003c24 <ilock+0x24>
      panic("ilock: no type");
    80003cb2:	00005517          	auipc	a0,0x5
    80003cb6:	96650513          	addi	a0,a0,-1690 # 80008618 <syscalls+0x1c8>
    80003cba:	ffffd097          	auipc	ra,0xffffd
    80003cbe:	886080e7          	jalr	-1914(ra) # 80000540 <panic>

0000000080003cc2 <iunlock>:
{
    80003cc2:	1101                	addi	sp,sp,-32
    80003cc4:	ec06                	sd	ra,24(sp)
    80003cc6:	e822                	sd	s0,16(sp)
    80003cc8:	e426                	sd	s1,8(sp)
    80003cca:	e04a                	sd	s2,0(sp)
    80003ccc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003cce:	c905                	beqz	a0,80003cfe <iunlock+0x3c>
    80003cd0:	84aa                	mv	s1,a0
    80003cd2:	01050913          	addi	s2,a0,16
    80003cd6:	854a                	mv	a0,s2
    80003cd8:	00001097          	auipc	ra,0x1
    80003cdc:	c82080e7          	jalr	-894(ra) # 8000495a <holdingsleep>
    80003ce0:	cd19                	beqz	a0,80003cfe <iunlock+0x3c>
    80003ce2:	449c                	lw	a5,8(s1)
    80003ce4:	00f05d63          	blez	a5,80003cfe <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ce8:	854a                	mv	a0,s2
    80003cea:	00001097          	auipc	ra,0x1
    80003cee:	c2c080e7          	jalr	-980(ra) # 80004916 <releasesleep>
}
    80003cf2:	60e2                	ld	ra,24(sp)
    80003cf4:	6442                	ld	s0,16(sp)
    80003cf6:	64a2                	ld	s1,8(sp)
    80003cf8:	6902                	ld	s2,0(sp)
    80003cfa:	6105                	addi	sp,sp,32
    80003cfc:	8082                	ret
    panic("iunlock");
    80003cfe:	00005517          	auipc	a0,0x5
    80003d02:	92a50513          	addi	a0,a0,-1750 # 80008628 <syscalls+0x1d8>
    80003d06:	ffffd097          	auipc	ra,0xffffd
    80003d0a:	83a080e7          	jalr	-1990(ra) # 80000540 <panic>

0000000080003d0e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d0e:	7179                	addi	sp,sp,-48
    80003d10:	f406                	sd	ra,40(sp)
    80003d12:	f022                	sd	s0,32(sp)
    80003d14:	ec26                	sd	s1,24(sp)
    80003d16:	e84a                	sd	s2,16(sp)
    80003d18:	e44e                	sd	s3,8(sp)
    80003d1a:	e052                	sd	s4,0(sp)
    80003d1c:	1800                	addi	s0,sp,48
    80003d1e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d20:	05050493          	addi	s1,a0,80
    80003d24:	08050913          	addi	s2,a0,128
    80003d28:	a021                	j	80003d30 <itrunc+0x22>
    80003d2a:	0491                	addi	s1,s1,4
    80003d2c:	01248d63          	beq	s1,s2,80003d46 <itrunc+0x38>
    if(ip->addrs[i]){
    80003d30:	408c                	lw	a1,0(s1)
    80003d32:	dde5                	beqz	a1,80003d2a <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d34:	0009a503          	lw	a0,0(s3)
    80003d38:	00000097          	auipc	ra,0x0
    80003d3c:	8f6080e7          	jalr	-1802(ra) # 8000362e <bfree>
      ip->addrs[i] = 0;
    80003d40:	0004a023          	sw	zero,0(s1)
    80003d44:	b7dd                	j	80003d2a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d46:	0809a583          	lw	a1,128(s3)
    80003d4a:	e185                	bnez	a1,80003d6a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d4c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d50:	854e                	mv	a0,s3
    80003d52:	00000097          	auipc	ra,0x0
    80003d56:	de2080e7          	jalr	-542(ra) # 80003b34 <iupdate>
}
    80003d5a:	70a2                	ld	ra,40(sp)
    80003d5c:	7402                	ld	s0,32(sp)
    80003d5e:	64e2                	ld	s1,24(sp)
    80003d60:	6942                	ld	s2,16(sp)
    80003d62:	69a2                	ld	s3,8(sp)
    80003d64:	6a02                	ld	s4,0(sp)
    80003d66:	6145                	addi	sp,sp,48
    80003d68:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d6a:	0009a503          	lw	a0,0(s3)
    80003d6e:	fffff097          	auipc	ra,0xfffff
    80003d72:	67a080e7          	jalr	1658(ra) # 800033e8 <bread>
    80003d76:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d78:	05850493          	addi	s1,a0,88
    80003d7c:	45850913          	addi	s2,a0,1112
    80003d80:	a021                	j	80003d88 <itrunc+0x7a>
    80003d82:	0491                	addi	s1,s1,4
    80003d84:	01248b63          	beq	s1,s2,80003d9a <itrunc+0x8c>
      if(a[j])
    80003d88:	408c                	lw	a1,0(s1)
    80003d8a:	dde5                	beqz	a1,80003d82 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d8c:	0009a503          	lw	a0,0(s3)
    80003d90:	00000097          	auipc	ra,0x0
    80003d94:	89e080e7          	jalr	-1890(ra) # 8000362e <bfree>
    80003d98:	b7ed                	j	80003d82 <itrunc+0x74>
    brelse(bp);
    80003d9a:	8552                	mv	a0,s4
    80003d9c:	fffff097          	auipc	ra,0xfffff
    80003da0:	77c080e7          	jalr	1916(ra) # 80003518 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003da4:	0809a583          	lw	a1,128(s3)
    80003da8:	0009a503          	lw	a0,0(s3)
    80003dac:	00000097          	auipc	ra,0x0
    80003db0:	882080e7          	jalr	-1918(ra) # 8000362e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003db4:	0809a023          	sw	zero,128(s3)
    80003db8:	bf51                	j	80003d4c <itrunc+0x3e>

0000000080003dba <iput>:
{
    80003dba:	1101                	addi	sp,sp,-32
    80003dbc:	ec06                	sd	ra,24(sp)
    80003dbe:	e822                	sd	s0,16(sp)
    80003dc0:	e426                	sd	s1,8(sp)
    80003dc2:	e04a                	sd	s2,0(sp)
    80003dc4:	1000                	addi	s0,sp,32
    80003dc6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003dc8:	00023517          	auipc	a0,0x23
    80003dcc:	b7050513          	addi	a0,a0,-1168 # 80026938 <itable>
    80003dd0:	ffffd097          	auipc	ra,0xffffd
    80003dd4:	e06080e7          	jalr	-506(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dd8:	4498                	lw	a4,8(s1)
    80003dda:	4785                	li	a5,1
    80003ddc:	02f70363          	beq	a4,a5,80003e02 <iput+0x48>
  ip->ref--;
    80003de0:	449c                	lw	a5,8(s1)
    80003de2:	37fd                	addiw	a5,a5,-1
    80003de4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003de6:	00023517          	auipc	a0,0x23
    80003dea:	b5250513          	addi	a0,a0,-1198 # 80026938 <itable>
    80003dee:	ffffd097          	auipc	ra,0xffffd
    80003df2:	e9c080e7          	jalr	-356(ra) # 80000c8a <release>
}
    80003df6:	60e2                	ld	ra,24(sp)
    80003df8:	6442                	ld	s0,16(sp)
    80003dfa:	64a2                	ld	s1,8(sp)
    80003dfc:	6902                	ld	s2,0(sp)
    80003dfe:	6105                	addi	sp,sp,32
    80003e00:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e02:	40bc                	lw	a5,64(s1)
    80003e04:	dff1                	beqz	a5,80003de0 <iput+0x26>
    80003e06:	04a49783          	lh	a5,74(s1)
    80003e0a:	fbf9                	bnez	a5,80003de0 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e0c:	01048913          	addi	s2,s1,16
    80003e10:	854a                	mv	a0,s2
    80003e12:	00001097          	auipc	ra,0x1
    80003e16:	aae080e7          	jalr	-1362(ra) # 800048c0 <acquiresleep>
    release(&itable.lock);
    80003e1a:	00023517          	auipc	a0,0x23
    80003e1e:	b1e50513          	addi	a0,a0,-1250 # 80026938 <itable>
    80003e22:	ffffd097          	auipc	ra,0xffffd
    80003e26:	e68080e7          	jalr	-408(ra) # 80000c8a <release>
    itrunc(ip);
    80003e2a:	8526                	mv	a0,s1
    80003e2c:	00000097          	auipc	ra,0x0
    80003e30:	ee2080e7          	jalr	-286(ra) # 80003d0e <itrunc>
    ip->type = 0;
    80003e34:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e38:	8526                	mv	a0,s1
    80003e3a:	00000097          	auipc	ra,0x0
    80003e3e:	cfa080e7          	jalr	-774(ra) # 80003b34 <iupdate>
    ip->valid = 0;
    80003e42:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e46:	854a                	mv	a0,s2
    80003e48:	00001097          	auipc	ra,0x1
    80003e4c:	ace080e7          	jalr	-1330(ra) # 80004916 <releasesleep>
    acquire(&itable.lock);
    80003e50:	00023517          	auipc	a0,0x23
    80003e54:	ae850513          	addi	a0,a0,-1304 # 80026938 <itable>
    80003e58:	ffffd097          	auipc	ra,0xffffd
    80003e5c:	d7e080e7          	jalr	-642(ra) # 80000bd6 <acquire>
    80003e60:	b741                	j	80003de0 <iput+0x26>

0000000080003e62 <iunlockput>:
{
    80003e62:	1101                	addi	sp,sp,-32
    80003e64:	ec06                	sd	ra,24(sp)
    80003e66:	e822                	sd	s0,16(sp)
    80003e68:	e426                	sd	s1,8(sp)
    80003e6a:	1000                	addi	s0,sp,32
    80003e6c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	e54080e7          	jalr	-428(ra) # 80003cc2 <iunlock>
  iput(ip);
    80003e76:	8526                	mv	a0,s1
    80003e78:	00000097          	auipc	ra,0x0
    80003e7c:	f42080e7          	jalr	-190(ra) # 80003dba <iput>
}
    80003e80:	60e2                	ld	ra,24(sp)
    80003e82:	6442                	ld	s0,16(sp)
    80003e84:	64a2                	ld	s1,8(sp)
    80003e86:	6105                	addi	sp,sp,32
    80003e88:	8082                	ret

0000000080003e8a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e8a:	1141                	addi	sp,sp,-16
    80003e8c:	e422                	sd	s0,8(sp)
    80003e8e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e90:	411c                	lw	a5,0(a0)
    80003e92:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e94:	415c                	lw	a5,4(a0)
    80003e96:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e98:	04451783          	lh	a5,68(a0)
    80003e9c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ea0:	04a51783          	lh	a5,74(a0)
    80003ea4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ea8:	04c56783          	lwu	a5,76(a0)
    80003eac:	e99c                	sd	a5,16(a1)
}
    80003eae:	6422                	ld	s0,8(sp)
    80003eb0:	0141                	addi	sp,sp,16
    80003eb2:	8082                	ret

0000000080003eb4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003eb4:	457c                	lw	a5,76(a0)
    80003eb6:	0ed7e963          	bltu	a5,a3,80003fa8 <readi+0xf4>
{
    80003eba:	7159                	addi	sp,sp,-112
    80003ebc:	f486                	sd	ra,104(sp)
    80003ebe:	f0a2                	sd	s0,96(sp)
    80003ec0:	eca6                	sd	s1,88(sp)
    80003ec2:	e8ca                	sd	s2,80(sp)
    80003ec4:	e4ce                	sd	s3,72(sp)
    80003ec6:	e0d2                	sd	s4,64(sp)
    80003ec8:	fc56                	sd	s5,56(sp)
    80003eca:	f85a                	sd	s6,48(sp)
    80003ecc:	f45e                	sd	s7,40(sp)
    80003ece:	f062                	sd	s8,32(sp)
    80003ed0:	ec66                	sd	s9,24(sp)
    80003ed2:	e86a                	sd	s10,16(sp)
    80003ed4:	e46e                	sd	s11,8(sp)
    80003ed6:	1880                	addi	s0,sp,112
    80003ed8:	8b2a                	mv	s6,a0
    80003eda:	8bae                	mv	s7,a1
    80003edc:	8a32                	mv	s4,a2
    80003ede:	84b6                	mv	s1,a3
    80003ee0:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ee2:	9f35                	addw	a4,a4,a3
    return 0;
    80003ee4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ee6:	0ad76063          	bltu	a4,a3,80003f86 <readi+0xd2>
  if(off + n > ip->size)
    80003eea:	00e7f463          	bgeu	a5,a4,80003ef2 <readi+0x3e>
    n = ip->size - off;
    80003eee:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ef2:	0a0a8963          	beqz	s5,80003fa4 <readi+0xf0>
    80003ef6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ef8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003efc:	5c7d                	li	s8,-1
    80003efe:	a82d                	j	80003f38 <readi+0x84>
    80003f00:	020d1d93          	slli	s11,s10,0x20
    80003f04:	020ddd93          	srli	s11,s11,0x20
    80003f08:	05890613          	addi	a2,s2,88
    80003f0c:	86ee                	mv	a3,s11
    80003f0e:	963a                	add	a2,a2,a4
    80003f10:	85d2                	mv	a1,s4
    80003f12:	855e                	mv	a0,s7
    80003f14:	ffffe097          	auipc	ra,0xffffe
    80003f18:	6a8080e7          	jalr	1704(ra) # 800025bc <either_copyout>
    80003f1c:	05850d63          	beq	a0,s8,80003f76 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f20:	854a                	mv	a0,s2
    80003f22:	fffff097          	auipc	ra,0xfffff
    80003f26:	5f6080e7          	jalr	1526(ra) # 80003518 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f2a:	013d09bb          	addw	s3,s10,s3
    80003f2e:	009d04bb          	addw	s1,s10,s1
    80003f32:	9a6e                	add	s4,s4,s11
    80003f34:	0559f763          	bgeu	s3,s5,80003f82 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f38:	00a4d59b          	srliw	a1,s1,0xa
    80003f3c:	855a                	mv	a0,s6
    80003f3e:	00000097          	auipc	ra,0x0
    80003f42:	89e080e7          	jalr	-1890(ra) # 800037dc <bmap>
    80003f46:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f4a:	cd85                	beqz	a1,80003f82 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f4c:	000b2503          	lw	a0,0(s6)
    80003f50:	fffff097          	auipc	ra,0xfffff
    80003f54:	498080e7          	jalr	1176(ra) # 800033e8 <bread>
    80003f58:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f5a:	3ff4f713          	andi	a4,s1,1023
    80003f5e:	40ec87bb          	subw	a5,s9,a4
    80003f62:	413a86bb          	subw	a3,s5,s3
    80003f66:	8d3e                	mv	s10,a5
    80003f68:	2781                	sext.w	a5,a5
    80003f6a:	0006861b          	sext.w	a2,a3
    80003f6e:	f8f679e3          	bgeu	a2,a5,80003f00 <readi+0x4c>
    80003f72:	8d36                	mv	s10,a3
    80003f74:	b771                	j	80003f00 <readi+0x4c>
      brelse(bp);
    80003f76:	854a                	mv	a0,s2
    80003f78:	fffff097          	auipc	ra,0xfffff
    80003f7c:	5a0080e7          	jalr	1440(ra) # 80003518 <brelse>
      tot = -1;
    80003f80:	59fd                	li	s3,-1
  }
  return tot;
    80003f82:	0009851b          	sext.w	a0,s3
}
    80003f86:	70a6                	ld	ra,104(sp)
    80003f88:	7406                	ld	s0,96(sp)
    80003f8a:	64e6                	ld	s1,88(sp)
    80003f8c:	6946                	ld	s2,80(sp)
    80003f8e:	69a6                	ld	s3,72(sp)
    80003f90:	6a06                	ld	s4,64(sp)
    80003f92:	7ae2                	ld	s5,56(sp)
    80003f94:	7b42                	ld	s6,48(sp)
    80003f96:	7ba2                	ld	s7,40(sp)
    80003f98:	7c02                	ld	s8,32(sp)
    80003f9a:	6ce2                	ld	s9,24(sp)
    80003f9c:	6d42                	ld	s10,16(sp)
    80003f9e:	6da2                	ld	s11,8(sp)
    80003fa0:	6165                	addi	sp,sp,112
    80003fa2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fa4:	89d6                	mv	s3,s5
    80003fa6:	bff1                	j	80003f82 <readi+0xce>
    return 0;
    80003fa8:	4501                	li	a0,0
}
    80003faa:	8082                	ret

0000000080003fac <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fac:	457c                	lw	a5,76(a0)
    80003fae:	10d7e863          	bltu	a5,a3,800040be <writei+0x112>
{
    80003fb2:	7159                	addi	sp,sp,-112
    80003fb4:	f486                	sd	ra,104(sp)
    80003fb6:	f0a2                	sd	s0,96(sp)
    80003fb8:	eca6                	sd	s1,88(sp)
    80003fba:	e8ca                	sd	s2,80(sp)
    80003fbc:	e4ce                	sd	s3,72(sp)
    80003fbe:	e0d2                	sd	s4,64(sp)
    80003fc0:	fc56                	sd	s5,56(sp)
    80003fc2:	f85a                	sd	s6,48(sp)
    80003fc4:	f45e                	sd	s7,40(sp)
    80003fc6:	f062                	sd	s8,32(sp)
    80003fc8:	ec66                	sd	s9,24(sp)
    80003fca:	e86a                	sd	s10,16(sp)
    80003fcc:	e46e                	sd	s11,8(sp)
    80003fce:	1880                	addi	s0,sp,112
    80003fd0:	8aaa                	mv	s5,a0
    80003fd2:	8bae                	mv	s7,a1
    80003fd4:	8a32                	mv	s4,a2
    80003fd6:	8936                	mv	s2,a3
    80003fd8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fda:	00e687bb          	addw	a5,a3,a4
    80003fde:	0ed7e263          	bltu	a5,a3,800040c2 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003fe2:	00043737          	lui	a4,0x43
    80003fe6:	0ef76063          	bltu	a4,a5,800040c6 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fea:	0c0b0863          	beqz	s6,800040ba <writei+0x10e>
    80003fee:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ff0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ff4:	5c7d                	li	s8,-1
    80003ff6:	a091                	j	8000403a <writei+0x8e>
    80003ff8:	020d1d93          	slli	s11,s10,0x20
    80003ffc:	020ddd93          	srli	s11,s11,0x20
    80004000:	05848513          	addi	a0,s1,88
    80004004:	86ee                	mv	a3,s11
    80004006:	8652                	mv	a2,s4
    80004008:	85de                	mv	a1,s7
    8000400a:	953a                	add	a0,a0,a4
    8000400c:	ffffe097          	auipc	ra,0xffffe
    80004010:	606080e7          	jalr	1542(ra) # 80002612 <either_copyin>
    80004014:	07850263          	beq	a0,s8,80004078 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004018:	8526                	mv	a0,s1
    8000401a:	00000097          	auipc	ra,0x0
    8000401e:	788080e7          	jalr	1928(ra) # 800047a2 <log_write>
    brelse(bp);
    80004022:	8526                	mv	a0,s1
    80004024:	fffff097          	auipc	ra,0xfffff
    80004028:	4f4080e7          	jalr	1268(ra) # 80003518 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000402c:	013d09bb          	addw	s3,s10,s3
    80004030:	012d093b          	addw	s2,s10,s2
    80004034:	9a6e                	add	s4,s4,s11
    80004036:	0569f663          	bgeu	s3,s6,80004082 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000403a:	00a9559b          	srliw	a1,s2,0xa
    8000403e:	8556                	mv	a0,s5
    80004040:	fffff097          	auipc	ra,0xfffff
    80004044:	79c080e7          	jalr	1948(ra) # 800037dc <bmap>
    80004048:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000404c:	c99d                	beqz	a1,80004082 <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000404e:	000aa503          	lw	a0,0(s5)
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	396080e7          	jalr	918(ra) # 800033e8 <bread>
    8000405a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000405c:	3ff97713          	andi	a4,s2,1023
    80004060:	40ec87bb          	subw	a5,s9,a4
    80004064:	413b06bb          	subw	a3,s6,s3
    80004068:	8d3e                	mv	s10,a5
    8000406a:	2781                	sext.w	a5,a5
    8000406c:	0006861b          	sext.w	a2,a3
    80004070:	f8f674e3          	bgeu	a2,a5,80003ff8 <writei+0x4c>
    80004074:	8d36                	mv	s10,a3
    80004076:	b749                	j	80003ff8 <writei+0x4c>
      brelse(bp);
    80004078:	8526                	mv	a0,s1
    8000407a:	fffff097          	auipc	ra,0xfffff
    8000407e:	49e080e7          	jalr	1182(ra) # 80003518 <brelse>
  }

  if(off > ip->size)
    80004082:	04caa783          	lw	a5,76(s5)
    80004086:	0127f463          	bgeu	a5,s2,8000408e <writei+0xe2>
    ip->size = off;
    8000408a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000408e:	8556                	mv	a0,s5
    80004090:	00000097          	auipc	ra,0x0
    80004094:	aa4080e7          	jalr	-1372(ra) # 80003b34 <iupdate>

  return tot;
    80004098:	0009851b          	sext.w	a0,s3
}
    8000409c:	70a6                	ld	ra,104(sp)
    8000409e:	7406                	ld	s0,96(sp)
    800040a0:	64e6                	ld	s1,88(sp)
    800040a2:	6946                	ld	s2,80(sp)
    800040a4:	69a6                	ld	s3,72(sp)
    800040a6:	6a06                	ld	s4,64(sp)
    800040a8:	7ae2                	ld	s5,56(sp)
    800040aa:	7b42                	ld	s6,48(sp)
    800040ac:	7ba2                	ld	s7,40(sp)
    800040ae:	7c02                	ld	s8,32(sp)
    800040b0:	6ce2                	ld	s9,24(sp)
    800040b2:	6d42                	ld	s10,16(sp)
    800040b4:	6da2                	ld	s11,8(sp)
    800040b6:	6165                	addi	sp,sp,112
    800040b8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040ba:	89da                	mv	s3,s6
    800040bc:	bfc9                	j	8000408e <writei+0xe2>
    return -1;
    800040be:	557d                	li	a0,-1
}
    800040c0:	8082                	ret
    return -1;
    800040c2:	557d                	li	a0,-1
    800040c4:	bfe1                	j	8000409c <writei+0xf0>
    return -1;
    800040c6:	557d                	li	a0,-1
    800040c8:	bfd1                	j	8000409c <writei+0xf0>

00000000800040ca <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040ca:	1141                	addi	sp,sp,-16
    800040cc:	e406                	sd	ra,8(sp)
    800040ce:	e022                	sd	s0,0(sp)
    800040d0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040d2:	4639                	li	a2,14
    800040d4:	ffffd097          	auipc	ra,0xffffd
    800040d8:	cce080e7          	jalr	-818(ra) # 80000da2 <strncmp>
}
    800040dc:	60a2                	ld	ra,8(sp)
    800040de:	6402                	ld	s0,0(sp)
    800040e0:	0141                	addi	sp,sp,16
    800040e2:	8082                	ret

00000000800040e4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040e4:	7139                	addi	sp,sp,-64
    800040e6:	fc06                	sd	ra,56(sp)
    800040e8:	f822                	sd	s0,48(sp)
    800040ea:	f426                	sd	s1,40(sp)
    800040ec:	f04a                	sd	s2,32(sp)
    800040ee:	ec4e                	sd	s3,24(sp)
    800040f0:	e852                	sd	s4,16(sp)
    800040f2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040f4:	04451703          	lh	a4,68(a0)
    800040f8:	4785                	li	a5,1
    800040fa:	00f71a63          	bne	a4,a5,8000410e <dirlookup+0x2a>
    800040fe:	892a                	mv	s2,a0
    80004100:	89ae                	mv	s3,a1
    80004102:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004104:	457c                	lw	a5,76(a0)
    80004106:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004108:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000410a:	e79d                	bnez	a5,80004138 <dirlookup+0x54>
    8000410c:	a8a5                	j	80004184 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000410e:	00004517          	auipc	a0,0x4
    80004112:	52250513          	addi	a0,a0,1314 # 80008630 <syscalls+0x1e0>
    80004116:	ffffc097          	auipc	ra,0xffffc
    8000411a:	42a080e7          	jalr	1066(ra) # 80000540 <panic>
      panic("dirlookup read");
    8000411e:	00004517          	auipc	a0,0x4
    80004122:	52a50513          	addi	a0,a0,1322 # 80008648 <syscalls+0x1f8>
    80004126:	ffffc097          	auipc	ra,0xffffc
    8000412a:	41a080e7          	jalr	1050(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000412e:	24c1                	addiw	s1,s1,16
    80004130:	04c92783          	lw	a5,76(s2)
    80004134:	04f4f763          	bgeu	s1,a5,80004182 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004138:	4741                	li	a4,16
    8000413a:	86a6                	mv	a3,s1
    8000413c:	fc040613          	addi	a2,s0,-64
    80004140:	4581                	li	a1,0
    80004142:	854a                	mv	a0,s2
    80004144:	00000097          	auipc	ra,0x0
    80004148:	d70080e7          	jalr	-656(ra) # 80003eb4 <readi>
    8000414c:	47c1                	li	a5,16
    8000414e:	fcf518e3          	bne	a0,a5,8000411e <dirlookup+0x3a>
    if(de.inum == 0)
    80004152:	fc045783          	lhu	a5,-64(s0)
    80004156:	dfe1                	beqz	a5,8000412e <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004158:	fc240593          	addi	a1,s0,-62
    8000415c:	854e                	mv	a0,s3
    8000415e:	00000097          	auipc	ra,0x0
    80004162:	f6c080e7          	jalr	-148(ra) # 800040ca <namecmp>
    80004166:	f561                	bnez	a0,8000412e <dirlookup+0x4a>
      if(poff)
    80004168:	000a0463          	beqz	s4,80004170 <dirlookup+0x8c>
        *poff = off;
    8000416c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004170:	fc045583          	lhu	a1,-64(s0)
    80004174:	00092503          	lw	a0,0(s2)
    80004178:	fffff097          	auipc	ra,0xfffff
    8000417c:	74e080e7          	jalr	1870(ra) # 800038c6 <iget>
    80004180:	a011                	j	80004184 <dirlookup+0xa0>
  return 0;
    80004182:	4501                	li	a0,0
}
    80004184:	70e2                	ld	ra,56(sp)
    80004186:	7442                	ld	s0,48(sp)
    80004188:	74a2                	ld	s1,40(sp)
    8000418a:	7902                	ld	s2,32(sp)
    8000418c:	69e2                	ld	s3,24(sp)
    8000418e:	6a42                	ld	s4,16(sp)
    80004190:	6121                	addi	sp,sp,64
    80004192:	8082                	ret

0000000080004194 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004194:	711d                	addi	sp,sp,-96
    80004196:	ec86                	sd	ra,88(sp)
    80004198:	e8a2                	sd	s0,80(sp)
    8000419a:	e4a6                	sd	s1,72(sp)
    8000419c:	e0ca                	sd	s2,64(sp)
    8000419e:	fc4e                	sd	s3,56(sp)
    800041a0:	f852                	sd	s4,48(sp)
    800041a2:	f456                	sd	s5,40(sp)
    800041a4:	f05a                	sd	s6,32(sp)
    800041a6:	ec5e                	sd	s7,24(sp)
    800041a8:	e862                	sd	s8,16(sp)
    800041aa:	e466                	sd	s9,8(sp)
    800041ac:	e06a                	sd	s10,0(sp)
    800041ae:	1080                	addi	s0,sp,96
    800041b0:	84aa                	mv	s1,a0
    800041b2:	8b2e                	mv	s6,a1
    800041b4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041b6:	00054703          	lbu	a4,0(a0)
    800041ba:	02f00793          	li	a5,47
    800041be:	02f70363          	beq	a4,a5,800041e4 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041c2:	ffffe097          	auipc	ra,0xffffe
    800041c6:	81a080e7          	jalr	-2022(ra) # 800019dc <myproc>
    800041ca:	15053503          	ld	a0,336(a0)
    800041ce:	00000097          	auipc	ra,0x0
    800041d2:	9f4080e7          	jalr	-1548(ra) # 80003bc2 <idup>
    800041d6:	8a2a                	mv	s4,a0
  while(*path == '/')
    800041d8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800041dc:	4cb5                	li	s9,13
  len = path - s;
    800041de:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041e0:	4c05                	li	s8,1
    800041e2:	a87d                	j	800042a0 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800041e4:	4585                	li	a1,1
    800041e6:	4505                	li	a0,1
    800041e8:	fffff097          	auipc	ra,0xfffff
    800041ec:	6de080e7          	jalr	1758(ra) # 800038c6 <iget>
    800041f0:	8a2a                	mv	s4,a0
    800041f2:	b7dd                	j	800041d8 <namex+0x44>
      iunlockput(ip);
    800041f4:	8552                	mv	a0,s4
    800041f6:	00000097          	auipc	ra,0x0
    800041fa:	c6c080e7          	jalr	-916(ra) # 80003e62 <iunlockput>
      return 0;
    800041fe:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004200:	8552                	mv	a0,s4
    80004202:	60e6                	ld	ra,88(sp)
    80004204:	6446                	ld	s0,80(sp)
    80004206:	64a6                	ld	s1,72(sp)
    80004208:	6906                	ld	s2,64(sp)
    8000420a:	79e2                	ld	s3,56(sp)
    8000420c:	7a42                	ld	s4,48(sp)
    8000420e:	7aa2                	ld	s5,40(sp)
    80004210:	7b02                	ld	s6,32(sp)
    80004212:	6be2                	ld	s7,24(sp)
    80004214:	6c42                	ld	s8,16(sp)
    80004216:	6ca2                	ld	s9,8(sp)
    80004218:	6d02                	ld	s10,0(sp)
    8000421a:	6125                	addi	sp,sp,96
    8000421c:	8082                	ret
      iunlock(ip);
    8000421e:	8552                	mv	a0,s4
    80004220:	00000097          	auipc	ra,0x0
    80004224:	aa2080e7          	jalr	-1374(ra) # 80003cc2 <iunlock>
      return ip;
    80004228:	bfe1                	j	80004200 <namex+0x6c>
      iunlockput(ip);
    8000422a:	8552                	mv	a0,s4
    8000422c:	00000097          	auipc	ra,0x0
    80004230:	c36080e7          	jalr	-970(ra) # 80003e62 <iunlockput>
      return 0;
    80004234:	8a4e                	mv	s4,s3
    80004236:	b7e9                	j	80004200 <namex+0x6c>
  len = path - s;
    80004238:	40998633          	sub	a2,s3,s1
    8000423c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004240:	09acd863          	bge	s9,s10,800042d0 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004244:	4639                	li	a2,14
    80004246:	85a6                	mv	a1,s1
    80004248:	8556                	mv	a0,s5
    8000424a:	ffffd097          	auipc	ra,0xffffd
    8000424e:	ae4080e7          	jalr	-1308(ra) # 80000d2e <memmove>
    80004252:	84ce                	mv	s1,s3
  while(*path == '/')
    80004254:	0004c783          	lbu	a5,0(s1)
    80004258:	01279763          	bne	a5,s2,80004266 <namex+0xd2>
    path++;
    8000425c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000425e:	0004c783          	lbu	a5,0(s1)
    80004262:	ff278de3          	beq	a5,s2,8000425c <namex+0xc8>
    ilock(ip);
    80004266:	8552                	mv	a0,s4
    80004268:	00000097          	auipc	ra,0x0
    8000426c:	998080e7          	jalr	-1640(ra) # 80003c00 <ilock>
    if(ip->type != T_DIR){
    80004270:	044a1783          	lh	a5,68(s4)
    80004274:	f98790e3          	bne	a5,s8,800041f4 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004278:	000b0563          	beqz	s6,80004282 <namex+0xee>
    8000427c:	0004c783          	lbu	a5,0(s1)
    80004280:	dfd9                	beqz	a5,8000421e <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004282:	865e                	mv	a2,s7
    80004284:	85d6                	mv	a1,s5
    80004286:	8552                	mv	a0,s4
    80004288:	00000097          	auipc	ra,0x0
    8000428c:	e5c080e7          	jalr	-420(ra) # 800040e4 <dirlookup>
    80004290:	89aa                	mv	s3,a0
    80004292:	dd41                	beqz	a0,8000422a <namex+0x96>
    iunlockput(ip);
    80004294:	8552                	mv	a0,s4
    80004296:	00000097          	auipc	ra,0x0
    8000429a:	bcc080e7          	jalr	-1076(ra) # 80003e62 <iunlockput>
    ip = next;
    8000429e:	8a4e                	mv	s4,s3
  while(*path == '/')
    800042a0:	0004c783          	lbu	a5,0(s1)
    800042a4:	01279763          	bne	a5,s2,800042b2 <namex+0x11e>
    path++;
    800042a8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042aa:	0004c783          	lbu	a5,0(s1)
    800042ae:	ff278de3          	beq	a5,s2,800042a8 <namex+0x114>
  if(*path == 0)
    800042b2:	cb9d                	beqz	a5,800042e8 <namex+0x154>
  while(*path != '/' && *path != 0)
    800042b4:	0004c783          	lbu	a5,0(s1)
    800042b8:	89a6                	mv	s3,s1
  len = path - s;
    800042ba:	8d5e                	mv	s10,s7
    800042bc:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800042be:	01278963          	beq	a5,s2,800042d0 <namex+0x13c>
    800042c2:	dbbd                	beqz	a5,80004238 <namex+0xa4>
    path++;
    800042c4:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800042c6:	0009c783          	lbu	a5,0(s3)
    800042ca:	ff279ce3          	bne	a5,s2,800042c2 <namex+0x12e>
    800042ce:	b7ad                	j	80004238 <namex+0xa4>
    memmove(name, s, len);
    800042d0:	2601                	sext.w	a2,a2
    800042d2:	85a6                	mv	a1,s1
    800042d4:	8556                	mv	a0,s5
    800042d6:	ffffd097          	auipc	ra,0xffffd
    800042da:	a58080e7          	jalr	-1448(ra) # 80000d2e <memmove>
    name[len] = 0;
    800042de:	9d56                	add	s10,s10,s5
    800042e0:	000d0023          	sb	zero,0(s10)
    800042e4:	84ce                	mv	s1,s3
    800042e6:	b7bd                	j	80004254 <namex+0xc0>
  if(nameiparent){
    800042e8:	f00b0ce3          	beqz	s6,80004200 <namex+0x6c>
    iput(ip);
    800042ec:	8552                	mv	a0,s4
    800042ee:	00000097          	auipc	ra,0x0
    800042f2:	acc080e7          	jalr	-1332(ra) # 80003dba <iput>
    return 0;
    800042f6:	4a01                	li	s4,0
    800042f8:	b721                	j	80004200 <namex+0x6c>

00000000800042fa <dirlink>:
{
    800042fa:	7139                	addi	sp,sp,-64
    800042fc:	fc06                	sd	ra,56(sp)
    800042fe:	f822                	sd	s0,48(sp)
    80004300:	f426                	sd	s1,40(sp)
    80004302:	f04a                	sd	s2,32(sp)
    80004304:	ec4e                	sd	s3,24(sp)
    80004306:	e852                	sd	s4,16(sp)
    80004308:	0080                	addi	s0,sp,64
    8000430a:	892a                	mv	s2,a0
    8000430c:	8a2e                	mv	s4,a1
    8000430e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004310:	4601                	li	a2,0
    80004312:	00000097          	auipc	ra,0x0
    80004316:	dd2080e7          	jalr	-558(ra) # 800040e4 <dirlookup>
    8000431a:	e93d                	bnez	a0,80004390 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000431c:	04c92483          	lw	s1,76(s2)
    80004320:	c49d                	beqz	s1,8000434e <dirlink+0x54>
    80004322:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004324:	4741                	li	a4,16
    80004326:	86a6                	mv	a3,s1
    80004328:	fc040613          	addi	a2,s0,-64
    8000432c:	4581                	li	a1,0
    8000432e:	854a                	mv	a0,s2
    80004330:	00000097          	auipc	ra,0x0
    80004334:	b84080e7          	jalr	-1148(ra) # 80003eb4 <readi>
    80004338:	47c1                	li	a5,16
    8000433a:	06f51163          	bne	a0,a5,8000439c <dirlink+0xa2>
    if(de.inum == 0)
    8000433e:	fc045783          	lhu	a5,-64(s0)
    80004342:	c791                	beqz	a5,8000434e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004344:	24c1                	addiw	s1,s1,16
    80004346:	04c92783          	lw	a5,76(s2)
    8000434a:	fcf4ede3          	bltu	s1,a5,80004324 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000434e:	4639                	li	a2,14
    80004350:	85d2                	mv	a1,s4
    80004352:	fc240513          	addi	a0,s0,-62
    80004356:	ffffd097          	auipc	ra,0xffffd
    8000435a:	a88080e7          	jalr	-1400(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000435e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004362:	4741                	li	a4,16
    80004364:	86a6                	mv	a3,s1
    80004366:	fc040613          	addi	a2,s0,-64
    8000436a:	4581                	li	a1,0
    8000436c:	854a                	mv	a0,s2
    8000436e:	00000097          	auipc	ra,0x0
    80004372:	c3e080e7          	jalr	-962(ra) # 80003fac <writei>
    80004376:	1541                	addi	a0,a0,-16
    80004378:	00a03533          	snez	a0,a0
    8000437c:	40a00533          	neg	a0,a0
}
    80004380:	70e2                	ld	ra,56(sp)
    80004382:	7442                	ld	s0,48(sp)
    80004384:	74a2                	ld	s1,40(sp)
    80004386:	7902                	ld	s2,32(sp)
    80004388:	69e2                	ld	s3,24(sp)
    8000438a:	6a42                	ld	s4,16(sp)
    8000438c:	6121                	addi	sp,sp,64
    8000438e:	8082                	ret
    iput(ip);
    80004390:	00000097          	auipc	ra,0x0
    80004394:	a2a080e7          	jalr	-1494(ra) # 80003dba <iput>
    return -1;
    80004398:	557d                	li	a0,-1
    8000439a:	b7dd                	j	80004380 <dirlink+0x86>
      panic("dirlink read");
    8000439c:	00004517          	auipc	a0,0x4
    800043a0:	2bc50513          	addi	a0,a0,700 # 80008658 <syscalls+0x208>
    800043a4:	ffffc097          	auipc	ra,0xffffc
    800043a8:	19c080e7          	jalr	412(ra) # 80000540 <panic>

00000000800043ac <namei>:

struct inode*
namei(char *path)
{
    800043ac:	1101                	addi	sp,sp,-32
    800043ae:	ec06                	sd	ra,24(sp)
    800043b0:	e822                	sd	s0,16(sp)
    800043b2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043b4:	fe040613          	addi	a2,s0,-32
    800043b8:	4581                	li	a1,0
    800043ba:	00000097          	auipc	ra,0x0
    800043be:	dda080e7          	jalr	-550(ra) # 80004194 <namex>
}
    800043c2:	60e2                	ld	ra,24(sp)
    800043c4:	6442                	ld	s0,16(sp)
    800043c6:	6105                	addi	sp,sp,32
    800043c8:	8082                	ret

00000000800043ca <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043ca:	1141                	addi	sp,sp,-16
    800043cc:	e406                	sd	ra,8(sp)
    800043ce:	e022                	sd	s0,0(sp)
    800043d0:	0800                	addi	s0,sp,16
    800043d2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043d4:	4585                	li	a1,1
    800043d6:	00000097          	auipc	ra,0x0
    800043da:	dbe080e7          	jalr	-578(ra) # 80004194 <namex>
}
    800043de:	60a2                	ld	ra,8(sp)
    800043e0:	6402                	ld	s0,0(sp)
    800043e2:	0141                	addi	sp,sp,16
    800043e4:	8082                	ret

00000000800043e6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043e6:	1101                	addi	sp,sp,-32
    800043e8:	ec06                	sd	ra,24(sp)
    800043ea:	e822                	sd	s0,16(sp)
    800043ec:	e426                	sd	s1,8(sp)
    800043ee:	e04a                	sd	s2,0(sp)
    800043f0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043f2:	00024917          	auipc	s2,0x24
    800043f6:	fee90913          	addi	s2,s2,-18 # 800283e0 <log>
    800043fa:	01892583          	lw	a1,24(s2)
    800043fe:	02892503          	lw	a0,40(s2)
    80004402:	fffff097          	auipc	ra,0xfffff
    80004406:	fe6080e7          	jalr	-26(ra) # 800033e8 <bread>
    8000440a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000440c:	02c92683          	lw	a3,44(s2)
    80004410:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004412:	02d05863          	blez	a3,80004442 <write_head+0x5c>
    80004416:	00024797          	auipc	a5,0x24
    8000441a:	ffa78793          	addi	a5,a5,-6 # 80028410 <log+0x30>
    8000441e:	05c50713          	addi	a4,a0,92
    80004422:	36fd                	addiw	a3,a3,-1
    80004424:	02069613          	slli	a2,a3,0x20
    80004428:	01e65693          	srli	a3,a2,0x1e
    8000442c:	00024617          	auipc	a2,0x24
    80004430:	fe860613          	addi	a2,a2,-24 # 80028414 <log+0x34>
    80004434:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004436:	4390                	lw	a2,0(a5)
    80004438:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000443a:	0791                	addi	a5,a5,4
    8000443c:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000443e:	fed79ce3          	bne	a5,a3,80004436 <write_head+0x50>
  }
  bwrite(buf);
    80004442:	8526                	mv	a0,s1
    80004444:	fffff097          	auipc	ra,0xfffff
    80004448:	096080e7          	jalr	150(ra) # 800034da <bwrite>
  brelse(buf);
    8000444c:	8526                	mv	a0,s1
    8000444e:	fffff097          	auipc	ra,0xfffff
    80004452:	0ca080e7          	jalr	202(ra) # 80003518 <brelse>
}
    80004456:	60e2                	ld	ra,24(sp)
    80004458:	6442                	ld	s0,16(sp)
    8000445a:	64a2                	ld	s1,8(sp)
    8000445c:	6902                	ld	s2,0(sp)
    8000445e:	6105                	addi	sp,sp,32
    80004460:	8082                	ret

0000000080004462 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004462:	00024797          	auipc	a5,0x24
    80004466:	faa7a783          	lw	a5,-86(a5) # 8002840c <log+0x2c>
    8000446a:	0af05d63          	blez	a5,80004524 <install_trans+0xc2>
{
    8000446e:	7139                	addi	sp,sp,-64
    80004470:	fc06                	sd	ra,56(sp)
    80004472:	f822                	sd	s0,48(sp)
    80004474:	f426                	sd	s1,40(sp)
    80004476:	f04a                	sd	s2,32(sp)
    80004478:	ec4e                	sd	s3,24(sp)
    8000447a:	e852                	sd	s4,16(sp)
    8000447c:	e456                	sd	s5,8(sp)
    8000447e:	e05a                	sd	s6,0(sp)
    80004480:	0080                	addi	s0,sp,64
    80004482:	8b2a                	mv	s6,a0
    80004484:	00024a97          	auipc	s5,0x24
    80004488:	f8ca8a93          	addi	s5,s5,-116 # 80028410 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000448c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000448e:	00024997          	auipc	s3,0x24
    80004492:	f5298993          	addi	s3,s3,-174 # 800283e0 <log>
    80004496:	a00d                	j	800044b8 <install_trans+0x56>
    brelse(lbuf);
    80004498:	854a                	mv	a0,s2
    8000449a:	fffff097          	auipc	ra,0xfffff
    8000449e:	07e080e7          	jalr	126(ra) # 80003518 <brelse>
    brelse(dbuf);
    800044a2:	8526                	mv	a0,s1
    800044a4:	fffff097          	auipc	ra,0xfffff
    800044a8:	074080e7          	jalr	116(ra) # 80003518 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ac:	2a05                	addiw	s4,s4,1
    800044ae:	0a91                	addi	s5,s5,4
    800044b0:	02c9a783          	lw	a5,44(s3)
    800044b4:	04fa5e63          	bge	s4,a5,80004510 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044b8:	0189a583          	lw	a1,24(s3)
    800044bc:	014585bb          	addw	a1,a1,s4
    800044c0:	2585                	addiw	a1,a1,1
    800044c2:	0289a503          	lw	a0,40(s3)
    800044c6:	fffff097          	auipc	ra,0xfffff
    800044ca:	f22080e7          	jalr	-222(ra) # 800033e8 <bread>
    800044ce:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044d0:	000aa583          	lw	a1,0(s5)
    800044d4:	0289a503          	lw	a0,40(s3)
    800044d8:	fffff097          	auipc	ra,0xfffff
    800044dc:	f10080e7          	jalr	-240(ra) # 800033e8 <bread>
    800044e0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044e2:	40000613          	li	a2,1024
    800044e6:	05890593          	addi	a1,s2,88
    800044ea:	05850513          	addi	a0,a0,88
    800044ee:	ffffd097          	auipc	ra,0xffffd
    800044f2:	840080e7          	jalr	-1984(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800044f6:	8526                	mv	a0,s1
    800044f8:	fffff097          	auipc	ra,0xfffff
    800044fc:	fe2080e7          	jalr	-30(ra) # 800034da <bwrite>
    if(recovering == 0)
    80004500:	f80b1ce3          	bnez	s6,80004498 <install_trans+0x36>
      bunpin(dbuf);
    80004504:	8526                	mv	a0,s1
    80004506:	fffff097          	auipc	ra,0xfffff
    8000450a:	0ec080e7          	jalr	236(ra) # 800035f2 <bunpin>
    8000450e:	b769                	j	80004498 <install_trans+0x36>
}
    80004510:	70e2                	ld	ra,56(sp)
    80004512:	7442                	ld	s0,48(sp)
    80004514:	74a2                	ld	s1,40(sp)
    80004516:	7902                	ld	s2,32(sp)
    80004518:	69e2                	ld	s3,24(sp)
    8000451a:	6a42                	ld	s4,16(sp)
    8000451c:	6aa2                	ld	s5,8(sp)
    8000451e:	6b02                	ld	s6,0(sp)
    80004520:	6121                	addi	sp,sp,64
    80004522:	8082                	ret
    80004524:	8082                	ret

0000000080004526 <initlog>:
{
    80004526:	7179                	addi	sp,sp,-48
    80004528:	f406                	sd	ra,40(sp)
    8000452a:	f022                	sd	s0,32(sp)
    8000452c:	ec26                	sd	s1,24(sp)
    8000452e:	e84a                	sd	s2,16(sp)
    80004530:	e44e                	sd	s3,8(sp)
    80004532:	1800                	addi	s0,sp,48
    80004534:	892a                	mv	s2,a0
    80004536:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004538:	00024497          	auipc	s1,0x24
    8000453c:	ea848493          	addi	s1,s1,-344 # 800283e0 <log>
    80004540:	00004597          	auipc	a1,0x4
    80004544:	12858593          	addi	a1,a1,296 # 80008668 <syscalls+0x218>
    80004548:	8526                	mv	a0,s1
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	5fc080e7          	jalr	1532(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004552:	0149a583          	lw	a1,20(s3)
    80004556:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004558:	0109a783          	lw	a5,16(s3)
    8000455c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000455e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004562:	854a                	mv	a0,s2
    80004564:	fffff097          	auipc	ra,0xfffff
    80004568:	e84080e7          	jalr	-380(ra) # 800033e8 <bread>
  log.lh.n = lh->n;
    8000456c:	4d34                	lw	a3,88(a0)
    8000456e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004570:	02d05663          	blez	a3,8000459c <initlog+0x76>
    80004574:	05c50793          	addi	a5,a0,92
    80004578:	00024717          	auipc	a4,0x24
    8000457c:	e9870713          	addi	a4,a4,-360 # 80028410 <log+0x30>
    80004580:	36fd                	addiw	a3,a3,-1
    80004582:	02069613          	slli	a2,a3,0x20
    80004586:	01e65693          	srli	a3,a2,0x1e
    8000458a:	06050613          	addi	a2,a0,96
    8000458e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004590:	4390                	lw	a2,0(a5)
    80004592:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004594:	0791                	addi	a5,a5,4
    80004596:	0711                	addi	a4,a4,4
    80004598:	fed79ce3          	bne	a5,a3,80004590 <initlog+0x6a>
  brelse(buf);
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	f7c080e7          	jalr	-132(ra) # 80003518 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045a4:	4505                	li	a0,1
    800045a6:	00000097          	auipc	ra,0x0
    800045aa:	ebc080e7          	jalr	-324(ra) # 80004462 <install_trans>
  log.lh.n = 0;
    800045ae:	00024797          	auipc	a5,0x24
    800045b2:	e407af23          	sw	zero,-418(a5) # 8002840c <log+0x2c>
  write_head(); // clear the log
    800045b6:	00000097          	auipc	ra,0x0
    800045ba:	e30080e7          	jalr	-464(ra) # 800043e6 <write_head>
}
    800045be:	70a2                	ld	ra,40(sp)
    800045c0:	7402                	ld	s0,32(sp)
    800045c2:	64e2                	ld	s1,24(sp)
    800045c4:	6942                	ld	s2,16(sp)
    800045c6:	69a2                	ld	s3,8(sp)
    800045c8:	6145                	addi	sp,sp,48
    800045ca:	8082                	ret

00000000800045cc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045cc:	1101                	addi	sp,sp,-32
    800045ce:	ec06                	sd	ra,24(sp)
    800045d0:	e822                	sd	s0,16(sp)
    800045d2:	e426                	sd	s1,8(sp)
    800045d4:	e04a                	sd	s2,0(sp)
    800045d6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045d8:	00024517          	auipc	a0,0x24
    800045dc:	e0850513          	addi	a0,a0,-504 # 800283e0 <log>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	5f6080e7          	jalr	1526(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800045e8:	00024497          	auipc	s1,0x24
    800045ec:	df848493          	addi	s1,s1,-520 # 800283e0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045f0:	4979                	li	s2,30
    800045f2:	a039                	j	80004600 <begin_op+0x34>
      sleep(&log, &log.lock);
    800045f4:	85a6                	mv	a1,s1
    800045f6:	8526                	mv	a0,s1
    800045f8:	ffffe097          	auipc	ra,0xffffe
    800045fc:	bb0080e7          	jalr	-1104(ra) # 800021a8 <sleep>
    if(log.committing){
    80004600:	50dc                	lw	a5,36(s1)
    80004602:	fbed                	bnez	a5,800045f4 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004604:	5098                	lw	a4,32(s1)
    80004606:	2705                	addiw	a4,a4,1
    80004608:	0007069b          	sext.w	a3,a4
    8000460c:	0027179b          	slliw	a5,a4,0x2
    80004610:	9fb9                	addw	a5,a5,a4
    80004612:	0017979b          	slliw	a5,a5,0x1
    80004616:	54d8                	lw	a4,44(s1)
    80004618:	9fb9                	addw	a5,a5,a4
    8000461a:	00f95963          	bge	s2,a5,8000462c <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000461e:	85a6                	mv	a1,s1
    80004620:	8526                	mv	a0,s1
    80004622:	ffffe097          	auipc	ra,0xffffe
    80004626:	b86080e7          	jalr	-1146(ra) # 800021a8 <sleep>
    8000462a:	bfd9                	j	80004600 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000462c:	00024517          	auipc	a0,0x24
    80004630:	db450513          	addi	a0,a0,-588 # 800283e0 <log>
    80004634:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004636:	ffffc097          	auipc	ra,0xffffc
    8000463a:	654080e7          	jalr	1620(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000463e:	60e2                	ld	ra,24(sp)
    80004640:	6442                	ld	s0,16(sp)
    80004642:	64a2                	ld	s1,8(sp)
    80004644:	6902                	ld	s2,0(sp)
    80004646:	6105                	addi	sp,sp,32
    80004648:	8082                	ret

000000008000464a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000464a:	7139                	addi	sp,sp,-64
    8000464c:	fc06                	sd	ra,56(sp)
    8000464e:	f822                	sd	s0,48(sp)
    80004650:	f426                	sd	s1,40(sp)
    80004652:	f04a                	sd	s2,32(sp)
    80004654:	ec4e                	sd	s3,24(sp)
    80004656:	e852                	sd	s4,16(sp)
    80004658:	e456                	sd	s5,8(sp)
    8000465a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000465c:	00024497          	auipc	s1,0x24
    80004660:	d8448493          	addi	s1,s1,-636 # 800283e0 <log>
    80004664:	8526                	mv	a0,s1
    80004666:	ffffc097          	auipc	ra,0xffffc
    8000466a:	570080e7          	jalr	1392(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000466e:	509c                	lw	a5,32(s1)
    80004670:	37fd                	addiw	a5,a5,-1
    80004672:	0007891b          	sext.w	s2,a5
    80004676:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004678:	50dc                	lw	a5,36(s1)
    8000467a:	e7b9                	bnez	a5,800046c8 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000467c:	04091e63          	bnez	s2,800046d8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004680:	00024497          	auipc	s1,0x24
    80004684:	d6048493          	addi	s1,s1,-672 # 800283e0 <log>
    80004688:	4785                	li	a5,1
    8000468a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000468c:	8526                	mv	a0,s1
    8000468e:	ffffc097          	auipc	ra,0xffffc
    80004692:	5fc080e7          	jalr	1532(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004696:	54dc                	lw	a5,44(s1)
    80004698:	06f04763          	bgtz	a5,80004706 <end_op+0xbc>
    acquire(&log.lock);
    8000469c:	00024497          	auipc	s1,0x24
    800046a0:	d4448493          	addi	s1,s1,-700 # 800283e0 <log>
    800046a4:	8526                	mv	a0,s1
    800046a6:	ffffc097          	auipc	ra,0xffffc
    800046aa:	530080e7          	jalr	1328(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800046ae:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800046b2:	8526                	mv	a0,s1
    800046b4:	ffffe097          	auipc	ra,0xffffe
    800046b8:	b58080e7          	jalr	-1192(ra) # 8000220c <wakeup>
    release(&log.lock);
    800046bc:	8526                	mv	a0,s1
    800046be:	ffffc097          	auipc	ra,0xffffc
    800046c2:	5cc080e7          	jalr	1484(ra) # 80000c8a <release>
}
    800046c6:	a03d                	j	800046f4 <end_op+0xaa>
    panic("log.committing");
    800046c8:	00004517          	auipc	a0,0x4
    800046cc:	fa850513          	addi	a0,a0,-88 # 80008670 <syscalls+0x220>
    800046d0:	ffffc097          	auipc	ra,0xffffc
    800046d4:	e70080e7          	jalr	-400(ra) # 80000540 <panic>
    wakeup(&log);
    800046d8:	00024497          	auipc	s1,0x24
    800046dc:	d0848493          	addi	s1,s1,-760 # 800283e0 <log>
    800046e0:	8526                	mv	a0,s1
    800046e2:	ffffe097          	auipc	ra,0xffffe
    800046e6:	b2a080e7          	jalr	-1238(ra) # 8000220c <wakeup>
  release(&log.lock);
    800046ea:	8526                	mv	a0,s1
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	59e080e7          	jalr	1438(ra) # 80000c8a <release>
}
    800046f4:	70e2                	ld	ra,56(sp)
    800046f6:	7442                	ld	s0,48(sp)
    800046f8:	74a2                	ld	s1,40(sp)
    800046fa:	7902                	ld	s2,32(sp)
    800046fc:	69e2                	ld	s3,24(sp)
    800046fe:	6a42                	ld	s4,16(sp)
    80004700:	6aa2                	ld	s5,8(sp)
    80004702:	6121                	addi	sp,sp,64
    80004704:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004706:	00024a97          	auipc	s5,0x24
    8000470a:	d0aa8a93          	addi	s5,s5,-758 # 80028410 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000470e:	00024a17          	auipc	s4,0x24
    80004712:	cd2a0a13          	addi	s4,s4,-814 # 800283e0 <log>
    80004716:	018a2583          	lw	a1,24(s4)
    8000471a:	012585bb          	addw	a1,a1,s2
    8000471e:	2585                	addiw	a1,a1,1
    80004720:	028a2503          	lw	a0,40(s4)
    80004724:	fffff097          	auipc	ra,0xfffff
    80004728:	cc4080e7          	jalr	-828(ra) # 800033e8 <bread>
    8000472c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000472e:	000aa583          	lw	a1,0(s5)
    80004732:	028a2503          	lw	a0,40(s4)
    80004736:	fffff097          	auipc	ra,0xfffff
    8000473a:	cb2080e7          	jalr	-846(ra) # 800033e8 <bread>
    8000473e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004740:	40000613          	li	a2,1024
    80004744:	05850593          	addi	a1,a0,88
    80004748:	05848513          	addi	a0,s1,88
    8000474c:	ffffc097          	auipc	ra,0xffffc
    80004750:	5e2080e7          	jalr	1506(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004754:	8526                	mv	a0,s1
    80004756:	fffff097          	auipc	ra,0xfffff
    8000475a:	d84080e7          	jalr	-636(ra) # 800034da <bwrite>
    brelse(from);
    8000475e:	854e                	mv	a0,s3
    80004760:	fffff097          	auipc	ra,0xfffff
    80004764:	db8080e7          	jalr	-584(ra) # 80003518 <brelse>
    brelse(to);
    80004768:	8526                	mv	a0,s1
    8000476a:	fffff097          	auipc	ra,0xfffff
    8000476e:	dae080e7          	jalr	-594(ra) # 80003518 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004772:	2905                	addiw	s2,s2,1
    80004774:	0a91                	addi	s5,s5,4
    80004776:	02ca2783          	lw	a5,44(s4)
    8000477a:	f8f94ee3          	blt	s2,a5,80004716 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000477e:	00000097          	auipc	ra,0x0
    80004782:	c68080e7          	jalr	-920(ra) # 800043e6 <write_head>
    install_trans(0); // Now install writes to home locations
    80004786:	4501                	li	a0,0
    80004788:	00000097          	auipc	ra,0x0
    8000478c:	cda080e7          	jalr	-806(ra) # 80004462 <install_trans>
    log.lh.n = 0;
    80004790:	00024797          	auipc	a5,0x24
    80004794:	c607ae23          	sw	zero,-900(a5) # 8002840c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004798:	00000097          	auipc	ra,0x0
    8000479c:	c4e080e7          	jalr	-946(ra) # 800043e6 <write_head>
    800047a0:	bdf5                	j	8000469c <end_op+0x52>

00000000800047a2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047a2:	1101                	addi	sp,sp,-32
    800047a4:	ec06                	sd	ra,24(sp)
    800047a6:	e822                	sd	s0,16(sp)
    800047a8:	e426                	sd	s1,8(sp)
    800047aa:	e04a                	sd	s2,0(sp)
    800047ac:	1000                	addi	s0,sp,32
    800047ae:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800047b0:	00024917          	auipc	s2,0x24
    800047b4:	c3090913          	addi	s2,s2,-976 # 800283e0 <log>
    800047b8:	854a                	mv	a0,s2
    800047ba:	ffffc097          	auipc	ra,0xffffc
    800047be:	41c080e7          	jalr	1052(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047c2:	02c92603          	lw	a2,44(s2)
    800047c6:	47f5                	li	a5,29
    800047c8:	06c7c563          	blt	a5,a2,80004832 <log_write+0x90>
    800047cc:	00024797          	auipc	a5,0x24
    800047d0:	c307a783          	lw	a5,-976(a5) # 800283fc <log+0x1c>
    800047d4:	37fd                	addiw	a5,a5,-1
    800047d6:	04f65e63          	bge	a2,a5,80004832 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047da:	00024797          	auipc	a5,0x24
    800047de:	c267a783          	lw	a5,-986(a5) # 80028400 <log+0x20>
    800047e2:	06f05063          	blez	a5,80004842 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047e6:	4781                	li	a5,0
    800047e8:	06c05563          	blez	a2,80004852 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047ec:	44cc                	lw	a1,12(s1)
    800047ee:	00024717          	auipc	a4,0x24
    800047f2:	c2270713          	addi	a4,a4,-990 # 80028410 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800047f6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047f8:	4314                	lw	a3,0(a4)
    800047fa:	04b68c63          	beq	a3,a1,80004852 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800047fe:	2785                	addiw	a5,a5,1
    80004800:	0711                	addi	a4,a4,4
    80004802:	fef61be3          	bne	a2,a5,800047f8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004806:	0621                	addi	a2,a2,8
    80004808:	060a                	slli	a2,a2,0x2
    8000480a:	00024797          	auipc	a5,0x24
    8000480e:	bd678793          	addi	a5,a5,-1066 # 800283e0 <log>
    80004812:	97b2                	add	a5,a5,a2
    80004814:	44d8                	lw	a4,12(s1)
    80004816:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004818:	8526                	mv	a0,s1
    8000481a:	fffff097          	auipc	ra,0xfffff
    8000481e:	d9c080e7          	jalr	-612(ra) # 800035b6 <bpin>
    log.lh.n++;
    80004822:	00024717          	auipc	a4,0x24
    80004826:	bbe70713          	addi	a4,a4,-1090 # 800283e0 <log>
    8000482a:	575c                	lw	a5,44(a4)
    8000482c:	2785                	addiw	a5,a5,1
    8000482e:	d75c                	sw	a5,44(a4)
    80004830:	a82d                	j	8000486a <log_write+0xc8>
    panic("too big a transaction");
    80004832:	00004517          	auipc	a0,0x4
    80004836:	e4e50513          	addi	a0,a0,-434 # 80008680 <syscalls+0x230>
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	d06080e7          	jalr	-762(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004842:	00004517          	auipc	a0,0x4
    80004846:	e5650513          	addi	a0,a0,-426 # 80008698 <syscalls+0x248>
    8000484a:	ffffc097          	auipc	ra,0xffffc
    8000484e:	cf6080e7          	jalr	-778(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004852:	00878693          	addi	a3,a5,8
    80004856:	068a                	slli	a3,a3,0x2
    80004858:	00024717          	auipc	a4,0x24
    8000485c:	b8870713          	addi	a4,a4,-1144 # 800283e0 <log>
    80004860:	9736                	add	a4,a4,a3
    80004862:	44d4                	lw	a3,12(s1)
    80004864:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004866:	faf609e3          	beq	a2,a5,80004818 <log_write+0x76>
  }
  release(&log.lock);
    8000486a:	00024517          	auipc	a0,0x24
    8000486e:	b7650513          	addi	a0,a0,-1162 # 800283e0 <log>
    80004872:	ffffc097          	auipc	ra,0xffffc
    80004876:	418080e7          	jalr	1048(ra) # 80000c8a <release>
}
    8000487a:	60e2                	ld	ra,24(sp)
    8000487c:	6442                	ld	s0,16(sp)
    8000487e:	64a2                	ld	s1,8(sp)
    80004880:	6902                	ld	s2,0(sp)
    80004882:	6105                	addi	sp,sp,32
    80004884:	8082                	ret

0000000080004886 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004886:	1101                	addi	sp,sp,-32
    80004888:	ec06                	sd	ra,24(sp)
    8000488a:	e822                	sd	s0,16(sp)
    8000488c:	e426                	sd	s1,8(sp)
    8000488e:	e04a                	sd	s2,0(sp)
    80004890:	1000                	addi	s0,sp,32
    80004892:	84aa                	mv	s1,a0
    80004894:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004896:	00004597          	auipc	a1,0x4
    8000489a:	e2258593          	addi	a1,a1,-478 # 800086b8 <syscalls+0x268>
    8000489e:	0521                	addi	a0,a0,8
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	2a6080e7          	jalr	678(ra) # 80000b46 <initlock>
  lk->name = name;
    800048a8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800048ac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048b0:	0204a423          	sw	zero,40(s1)
}
    800048b4:	60e2                	ld	ra,24(sp)
    800048b6:	6442                	ld	s0,16(sp)
    800048b8:	64a2                	ld	s1,8(sp)
    800048ba:	6902                	ld	s2,0(sp)
    800048bc:	6105                	addi	sp,sp,32
    800048be:	8082                	ret

00000000800048c0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048c0:	1101                	addi	sp,sp,-32
    800048c2:	ec06                	sd	ra,24(sp)
    800048c4:	e822                	sd	s0,16(sp)
    800048c6:	e426                	sd	s1,8(sp)
    800048c8:	e04a                	sd	s2,0(sp)
    800048ca:	1000                	addi	s0,sp,32
    800048cc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048ce:	00850913          	addi	s2,a0,8
    800048d2:	854a                	mv	a0,s2
    800048d4:	ffffc097          	auipc	ra,0xffffc
    800048d8:	302080e7          	jalr	770(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800048dc:	409c                	lw	a5,0(s1)
    800048de:	cb89                	beqz	a5,800048f0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048e0:	85ca                	mv	a1,s2
    800048e2:	8526                	mv	a0,s1
    800048e4:	ffffe097          	auipc	ra,0xffffe
    800048e8:	8c4080e7          	jalr	-1852(ra) # 800021a8 <sleep>
  while (lk->locked) {
    800048ec:	409c                	lw	a5,0(s1)
    800048ee:	fbed                	bnez	a5,800048e0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048f0:	4785                	li	a5,1
    800048f2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800048f4:	ffffd097          	auipc	ra,0xffffd
    800048f8:	0e8080e7          	jalr	232(ra) # 800019dc <myproc>
    800048fc:	591c                	lw	a5,48(a0)
    800048fe:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004900:	854a                	mv	a0,s2
    80004902:	ffffc097          	auipc	ra,0xffffc
    80004906:	388080e7          	jalr	904(ra) # 80000c8a <release>
}
    8000490a:	60e2                	ld	ra,24(sp)
    8000490c:	6442                	ld	s0,16(sp)
    8000490e:	64a2                	ld	s1,8(sp)
    80004910:	6902                	ld	s2,0(sp)
    80004912:	6105                	addi	sp,sp,32
    80004914:	8082                	ret

0000000080004916 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004916:	1101                	addi	sp,sp,-32
    80004918:	ec06                	sd	ra,24(sp)
    8000491a:	e822                	sd	s0,16(sp)
    8000491c:	e426                	sd	s1,8(sp)
    8000491e:	e04a                	sd	s2,0(sp)
    80004920:	1000                	addi	s0,sp,32
    80004922:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004924:	00850913          	addi	s2,a0,8
    80004928:	854a                	mv	a0,s2
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	2ac080e7          	jalr	684(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004932:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004936:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000493a:	8526                	mv	a0,s1
    8000493c:	ffffe097          	auipc	ra,0xffffe
    80004940:	8d0080e7          	jalr	-1840(ra) # 8000220c <wakeup>
  release(&lk->lk);
    80004944:	854a                	mv	a0,s2
    80004946:	ffffc097          	auipc	ra,0xffffc
    8000494a:	344080e7          	jalr	836(ra) # 80000c8a <release>
}
    8000494e:	60e2                	ld	ra,24(sp)
    80004950:	6442                	ld	s0,16(sp)
    80004952:	64a2                	ld	s1,8(sp)
    80004954:	6902                	ld	s2,0(sp)
    80004956:	6105                	addi	sp,sp,32
    80004958:	8082                	ret

000000008000495a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000495a:	7179                	addi	sp,sp,-48
    8000495c:	f406                	sd	ra,40(sp)
    8000495e:	f022                	sd	s0,32(sp)
    80004960:	ec26                	sd	s1,24(sp)
    80004962:	e84a                	sd	s2,16(sp)
    80004964:	e44e                	sd	s3,8(sp)
    80004966:	1800                	addi	s0,sp,48
    80004968:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000496a:	00850913          	addi	s2,a0,8
    8000496e:	854a                	mv	a0,s2
    80004970:	ffffc097          	auipc	ra,0xffffc
    80004974:	266080e7          	jalr	614(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004978:	409c                	lw	a5,0(s1)
    8000497a:	ef99                	bnez	a5,80004998 <holdingsleep+0x3e>
    8000497c:	4481                	li	s1,0
  release(&lk->lk);
    8000497e:	854a                	mv	a0,s2
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	30a080e7          	jalr	778(ra) # 80000c8a <release>
  return r;
}
    80004988:	8526                	mv	a0,s1
    8000498a:	70a2                	ld	ra,40(sp)
    8000498c:	7402                	ld	s0,32(sp)
    8000498e:	64e2                	ld	s1,24(sp)
    80004990:	6942                	ld	s2,16(sp)
    80004992:	69a2                	ld	s3,8(sp)
    80004994:	6145                	addi	sp,sp,48
    80004996:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004998:	0284a983          	lw	s3,40(s1)
    8000499c:	ffffd097          	auipc	ra,0xffffd
    800049a0:	040080e7          	jalr	64(ra) # 800019dc <myproc>
    800049a4:	5904                	lw	s1,48(a0)
    800049a6:	413484b3          	sub	s1,s1,s3
    800049aa:	0014b493          	seqz	s1,s1
    800049ae:	bfc1                	j	8000497e <holdingsleep+0x24>

00000000800049b0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049b0:	1141                	addi	sp,sp,-16
    800049b2:	e406                	sd	ra,8(sp)
    800049b4:	e022                	sd	s0,0(sp)
    800049b6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049b8:	00004597          	auipc	a1,0x4
    800049bc:	d1058593          	addi	a1,a1,-752 # 800086c8 <syscalls+0x278>
    800049c0:	00024517          	auipc	a0,0x24
    800049c4:	b6850513          	addi	a0,a0,-1176 # 80028528 <ftable>
    800049c8:	ffffc097          	auipc	ra,0xffffc
    800049cc:	17e080e7          	jalr	382(ra) # 80000b46 <initlock>
}
    800049d0:	60a2                	ld	ra,8(sp)
    800049d2:	6402                	ld	s0,0(sp)
    800049d4:	0141                	addi	sp,sp,16
    800049d6:	8082                	ret

00000000800049d8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049d8:	1101                	addi	sp,sp,-32
    800049da:	ec06                	sd	ra,24(sp)
    800049dc:	e822                	sd	s0,16(sp)
    800049de:	e426                	sd	s1,8(sp)
    800049e0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049e2:	00024517          	auipc	a0,0x24
    800049e6:	b4650513          	addi	a0,a0,-1210 # 80028528 <ftable>
    800049ea:	ffffc097          	auipc	ra,0xffffc
    800049ee:	1ec080e7          	jalr	492(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049f2:	00024497          	auipc	s1,0x24
    800049f6:	b4e48493          	addi	s1,s1,-1202 # 80028540 <ftable+0x18>
    800049fa:	00025717          	auipc	a4,0x25
    800049fe:	ae670713          	addi	a4,a4,-1306 # 800294e0 <disk>
    if(f->ref == 0){
    80004a02:	40dc                	lw	a5,4(s1)
    80004a04:	cf99                	beqz	a5,80004a22 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a06:	02848493          	addi	s1,s1,40
    80004a0a:	fee49ce3          	bne	s1,a4,80004a02 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a0e:	00024517          	auipc	a0,0x24
    80004a12:	b1a50513          	addi	a0,a0,-1254 # 80028528 <ftable>
    80004a16:	ffffc097          	auipc	ra,0xffffc
    80004a1a:	274080e7          	jalr	628(ra) # 80000c8a <release>
  return 0;
    80004a1e:	4481                	li	s1,0
    80004a20:	a819                	j	80004a36 <filealloc+0x5e>
      f->ref = 1;
    80004a22:	4785                	li	a5,1
    80004a24:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a26:	00024517          	auipc	a0,0x24
    80004a2a:	b0250513          	addi	a0,a0,-1278 # 80028528 <ftable>
    80004a2e:	ffffc097          	auipc	ra,0xffffc
    80004a32:	25c080e7          	jalr	604(ra) # 80000c8a <release>
}
    80004a36:	8526                	mv	a0,s1
    80004a38:	60e2                	ld	ra,24(sp)
    80004a3a:	6442                	ld	s0,16(sp)
    80004a3c:	64a2                	ld	s1,8(sp)
    80004a3e:	6105                	addi	sp,sp,32
    80004a40:	8082                	ret

0000000080004a42 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a42:	1101                	addi	sp,sp,-32
    80004a44:	ec06                	sd	ra,24(sp)
    80004a46:	e822                	sd	s0,16(sp)
    80004a48:	e426                	sd	s1,8(sp)
    80004a4a:	1000                	addi	s0,sp,32
    80004a4c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a4e:	00024517          	auipc	a0,0x24
    80004a52:	ada50513          	addi	a0,a0,-1318 # 80028528 <ftable>
    80004a56:	ffffc097          	auipc	ra,0xffffc
    80004a5a:	180080e7          	jalr	384(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a5e:	40dc                	lw	a5,4(s1)
    80004a60:	02f05263          	blez	a5,80004a84 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a64:	2785                	addiw	a5,a5,1
    80004a66:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a68:	00024517          	auipc	a0,0x24
    80004a6c:	ac050513          	addi	a0,a0,-1344 # 80028528 <ftable>
    80004a70:	ffffc097          	auipc	ra,0xffffc
    80004a74:	21a080e7          	jalr	538(ra) # 80000c8a <release>
  return f;
}
    80004a78:	8526                	mv	a0,s1
    80004a7a:	60e2                	ld	ra,24(sp)
    80004a7c:	6442                	ld	s0,16(sp)
    80004a7e:	64a2                	ld	s1,8(sp)
    80004a80:	6105                	addi	sp,sp,32
    80004a82:	8082                	ret
    panic("filedup");
    80004a84:	00004517          	auipc	a0,0x4
    80004a88:	c4c50513          	addi	a0,a0,-948 # 800086d0 <syscalls+0x280>
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	ab4080e7          	jalr	-1356(ra) # 80000540 <panic>

0000000080004a94 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a94:	7139                	addi	sp,sp,-64
    80004a96:	fc06                	sd	ra,56(sp)
    80004a98:	f822                	sd	s0,48(sp)
    80004a9a:	f426                	sd	s1,40(sp)
    80004a9c:	f04a                	sd	s2,32(sp)
    80004a9e:	ec4e                	sd	s3,24(sp)
    80004aa0:	e852                	sd	s4,16(sp)
    80004aa2:	e456                	sd	s5,8(sp)
    80004aa4:	0080                	addi	s0,sp,64
    80004aa6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004aa8:	00024517          	auipc	a0,0x24
    80004aac:	a8050513          	addi	a0,a0,-1408 # 80028528 <ftable>
    80004ab0:	ffffc097          	auipc	ra,0xffffc
    80004ab4:	126080e7          	jalr	294(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004ab8:	40dc                	lw	a5,4(s1)
    80004aba:	06f05163          	blez	a5,80004b1c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004abe:	37fd                	addiw	a5,a5,-1
    80004ac0:	0007871b          	sext.w	a4,a5
    80004ac4:	c0dc                	sw	a5,4(s1)
    80004ac6:	06e04363          	bgtz	a4,80004b2c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004aca:	0004a903          	lw	s2,0(s1)
    80004ace:	0094ca83          	lbu	s5,9(s1)
    80004ad2:	0104ba03          	ld	s4,16(s1)
    80004ad6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004ada:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ade:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ae2:	00024517          	auipc	a0,0x24
    80004ae6:	a4650513          	addi	a0,a0,-1466 # 80028528 <ftable>
    80004aea:	ffffc097          	auipc	ra,0xffffc
    80004aee:	1a0080e7          	jalr	416(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004af2:	4785                	li	a5,1
    80004af4:	04f90d63          	beq	s2,a5,80004b4e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004af8:	3979                	addiw	s2,s2,-2
    80004afa:	4785                	li	a5,1
    80004afc:	0527e063          	bltu	a5,s2,80004b3c <fileclose+0xa8>
    begin_op();
    80004b00:	00000097          	auipc	ra,0x0
    80004b04:	acc080e7          	jalr	-1332(ra) # 800045cc <begin_op>
    iput(ff.ip);
    80004b08:	854e                	mv	a0,s3
    80004b0a:	fffff097          	auipc	ra,0xfffff
    80004b0e:	2b0080e7          	jalr	688(ra) # 80003dba <iput>
    end_op();
    80004b12:	00000097          	auipc	ra,0x0
    80004b16:	b38080e7          	jalr	-1224(ra) # 8000464a <end_op>
    80004b1a:	a00d                	j	80004b3c <fileclose+0xa8>
    panic("fileclose");
    80004b1c:	00004517          	auipc	a0,0x4
    80004b20:	bbc50513          	addi	a0,a0,-1092 # 800086d8 <syscalls+0x288>
    80004b24:	ffffc097          	auipc	ra,0xffffc
    80004b28:	a1c080e7          	jalr	-1508(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004b2c:	00024517          	auipc	a0,0x24
    80004b30:	9fc50513          	addi	a0,a0,-1540 # 80028528 <ftable>
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	156080e7          	jalr	342(ra) # 80000c8a <release>
  }
}
    80004b3c:	70e2                	ld	ra,56(sp)
    80004b3e:	7442                	ld	s0,48(sp)
    80004b40:	74a2                	ld	s1,40(sp)
    80004b42:	7902                	ld	s2,32(sp)
    80004b44:	69e2                	ld	s3,24(sp)
    80004b46:	6a42                	ld	s4,16(sp)
    80004b48:	6aa2                	ld	s5,8(sp)
    80004b4a:	6121                	addi	sp,sp,64
    80004b4c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b4e:	85d6                	mv	a1,s5
    80004b50:	8552                	mv	a0,s4
    80004b52:	00000097          	auipc	ra,0x0
    80004b56:	34c080e7          	jalr	844(ra) # 80004e9e <pipeclose>
    80004b5a:	b7cd                	j	80004b3c <fileclose+0xa8>

0000000080004b5c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b5c:	715d                	addi	sp,sp,-80
    80004b5e:	e486                	sd	ra,72(sp)
    80004b60:	e0a2                	sd	s0,64(sp)
    80004b62:	fc26                	sd	s1,56(sp)
    80004b64:	f84a                	sd	s2,48(sp)
    80004b66:	f44e                	sd	s3,40(sp)
    80004b68:	0880                	addi	s0,sp,80
    80004b6a:	84aa                	mv	s1,a0
    80004b6c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b6e:	ffffd097          	auipc	ra,0xffffd
    80004b72:	e6e080e7          	jalr	-402(ra) # 800019dc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b76:	409c                	lw	a5,0(s1)
    80004b78:	37f9                	addiw	a5,a5,-2
    80004b7a:	4705                	li	a4,1
    80004b7c:	04f76763          	bltu	a4,a5,80004bca <filestat+0x6e>
    80004b80:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b82:	6c88                	ld	a0,24(s1)
    80004b84:	fffff097          	auipc	ra,0xfffff
    80004b88:	07c080e7          	jalr	124(ra) # 80003c00 <ilock>
    stati(f->ip, &st);
    80004b8c:	fb840593          	addi	a1,s0,-72
    80004b90:	6c88                	ld	a0,24(s1)
    80004b92:	fffff097          	auipc	ra,0xfffff
    80004b96:	2f8080e7          	jalr	760(ra) # 80003e8a <stati>
    iunlock(f->ip);
    80004b9a:	6c88                	ld	a0,24(s1)
    80004b9c:	fffff097          	auipc	ra,0xfffff
    80004ba0:	126080e7          	jalr	294(ra) # 80003cc2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ba4:	46e1                	li	a3,24
    80004ba6:	fb840613          	addi	a2,s0,-72
    80004baa:	85ce                	mv	a1,s3
    80004bac:	05093503          	ld	a0,80(s2)
    80004bb0:	ffffd097          	auipc	ra,0xffffd
    80004bb4:	abc080e7          	jalr	-1348(ra) # 8000166c <copyout>
    80004bb8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004bbc:	60a6                	ld	ra,72(sp)
    80004bbe:	6406                	ld	s0,64(sp)
    80004bc0:	74e2                	ld	s1,56(sp)
    80004bc2:	7942                	ld	s2,48(sp)
    80004bc4:	79a2                	ld	s3,40(sp)
    80004bc6:	6161                	addi	sp,sp,80
    80004bc8:	8082                	ret
  return -1;
    80004bca:	557d                	li	a0,-1
    80004bcc:	bfc5                	j	80004bbc <filestat+0x60>

0000000080004bce <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004bce:	7179                	addi	sp,sp,-48
    80004bd0:	f406                	sd	ra,40(sp)
    80004bd2:	f022                	sd	s0,32(sp)
    80004bd4:	ec26                	sd	s1,24(sp)
    80004bd6:	e84a                	sd	s2,16(sp)
    80004bd8:	e44e                	sd	s3,8(sp)
    80004bda:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004bdc:	00854783          	lbu	a5,8(a0)
    80004be0:	c3d5                	beqz	a5,80004c84 <fileread+0xb6>
    80004be2:	84aa                	mv	s1,a0
    80004be4:	89ae                	mv	s3,a1
    80004be6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004be8:	411c                	lw	a5,0(a0)
    80004bea:	4705                	li	a4,1
    80004bec:	04e78963          	beq	a5,a4,80004c3e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bf0:	470d                	li	a4,3
    80004bf2:	04e78d63          	beq	a5,a4,80004c4c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bf6:	4709                	li	a4,2
    80004bf8:	06e79e63          	bne	a5,a4,80004c74 <fileread+0xa6>
    ilock(f->ip);
    80004bfc:	6d08                	ld	a0,24(a0)
    80004bfe:	fffff097          	auipc	ra,0xfffff
    80004c02:	002080e7          	jalr	2(ra) # 80003c00 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c06:	874a                	mv	a4,s2
    80004c08:	5094                	lw	a3,32(s1)
    80004c0a:	864e                	mv	a2,s3
    80004c0c:	4585                	li	a1,1
    80004c0e:	6c88                	ld	a0,24(s1)
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	2a4080e7          	jalr	676(ra) # 80003eb4 <readi>
    80004c18:	892a                	mv	s2,a0
    80004c1a:	00a05563          	blez	a0,80004c24 <fileread+0x56>
      f->off += r;
    80004c1e:	509c                	lw	a5,32(s1)
    80004c20:	9fa9                	addw	a5,a5,a0
    80004c22:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c24:	6c88                	ld	a0,24(s1)
    80004c26:	fffff097          	auipc	ra,0xfffff
    80004c2a:	09c080e7          	jalr	156(ra) # 80003cc2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c2e:	854a                	mv	a0,s2
    80004c30:	70a2                	ld	ra,40(sp)
    80004c32:	7402                	ld	s0,32(sp)
    80004c34:	64e2                	ld	s1,24(sp)
    80004c36:	6942                	ld	s2,16(sp)
    80004c38:	69a2                	ld	s3,8(sp)
    80004c3a:	6145                	addi	sp,sp,48
    80004c3c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c3e:	6908                	ld	a0,16(a0)
    80004c40:	00000097          	auipc	ra,0x0
    80004c44:	3c6080e7          	jalr	966(ra) # 80005006 <piperead>
    80004c48:	892a                	mv	s2,a0
    80004c4a:	b7d5                	j	80004c2e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c4c:	02451783          	lh	a5,36(a0)
    80004c50:	03079693          	slli	a3,a5,0x30
    80004c54:	92c1                	srli	a3,a3,0x30
    80004c56:	4725                	li	a4,9
    80004c58:	02d76863          	bltu	a4,a3,80004c88 <fileread+0xba>
    80004c5c:	0792                	slli	a5,a5,0x4
    80004c5e:	00024717          	auipc	a4,0x24
    80004c62:	82a70713          	addi	a4,a4,-2006 # 80028488 <devsw>
    80004c66:	97ba                	add	a5,a5,a4
    80004c68:	639c                	ld	a5,0(a5)
    80004c6a:	c38d                	beqz	a5,80004c8c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c6c:	4505                	li	a0,1
    80004c6e:	9782                	jalr	a5
    80004c70:	892a                	mv	s2,a0
    80004c72:	bf75                	j	80004c2e <fileread+0x60>
    panic("fileread");
    80004c74:	00004517          	auipc	a0,0x4
    80004c78:	a7450513          	addi	a0,a0,-1420 # 800086e8 <syscalls+0x298>
    80004c7c:	ffffc097          	auipc	ra,0xffffc
    80004c80:	8c4080e7          	jalr	-1852(ra) # 80000540 <panic>
    return -1;
    80004c84:	597d                	li	s2,-1
    80004c86:	b765                	j	80004c2e <fileread+0x60>
      return -1;
    80004c88:	597d                	li	s2,-1
    80004c8a:	b755                	j	80004c2e <fileread+0x60>
    80004c8c:	597d                	li	s2,-1
    80004c8e:	b745                	j	80004c2e <fileread+0x60>

0000000080004c90 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c90:	715d                	addi	sp,sp,-80
    80004c92:	e486                	sd	ra,72(sp)
    80004c94:	e0a2                	sd	s0,64(sp)
    80004c96:	fc26                	sd	s1,56(sp)
    80004c98:	f84a                	sd	s2,48(sp)
    80004c9a:	f44e                	sd	s3,40(sp)
    80004c9c:	f052                	sd	s4,32(sp)
    80004c9e:	ec56                	sd	s5,24(sp)
    80004ca0:	e85a                	sd	s6,16(sp)
    80004ca2:	e45e                	sd	s7,8(sp)
    80004ca4:	e062                	sd	s8,0(sp)
    80004ca6:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004ca8:	00954783          	lbu	a5,9(a0)
    80004cac:	10078663          	beqz	a5,80004db8 <filewrite+0x128>
    80004cb0:	892a                	mv	s2,a0
    80004cb2:	8b2e                	mv	s6,a1
    80004cb4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cb6:	411c                	lw	a5,0(a0)
    80004cb8:	4705                	li	a4,1
    80004cba:	02e78263          	beq	a5,a4,80004cde <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cbe:	470d                	li	a4,3
    80004cc0:	02e78663          	beq	a5,a4,80004cec <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cc4:	4709                	li	a4,2
    80004cc6:	0ee79163          	bne	a5,a4,80004da8 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cca:	0ac05d63          	blez	a2,80004d84 <filewrite+0xf4>
    int i = 0;
    80004cce:	4981                	li	s3,0
    80004cd0:	6b85                	lui	s7,0x1
    80004cd2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004cd6:	6c05                	lui	s8,0x1
    80004cd8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004cdc:	a861                	j	80004d74 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004cde:	6908                	ld	a0,16(a0)
    80004ce0:	00000097          	auipc	ra,0x0
    80004ce4:	22e080e7          	jalr	558(ra) # 80004f0e <pipewrite>
    80004ce8:	8a2a                	mv	s4,a0
    80004cea:	a045                	j	80004d8a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cec:	02451783          	lh	a5,36(a0)
    80004cf0:	03079693          	slli	a3,a5,0x30
    80004cf4:	92c1                	srli	a3,a3,0x30
    80004cf6:	4725                	li	a4,9
    80004cf8:	0cd76263          	bltu	a4,a3,80004dbc <filewrite+0x12c>
    80004cfc:	0792                	slli	a5,a5,0x4
    80004cfe:	00023717          	auipc	a4,0x23
    80004d02:	78a70713          	addi	a4,a4,1930 # 80028488 <devsw>
    80004d06:	97ba                	add	a5,a5,a4
    80004d08:	679c                	ld	a5,8(a5)
    80004d0a:	cbdd                	beqz	a5,80004dc0 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d0c:	4505                	li	a0,1
    80004d0e:	9782                	jalr	a5
    80004d10:	8a2a                	mv	s4,a0
    80004d12:	a8a5                	j	80004d8a <filewrite+0xfa>
    80004d14:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d18:	00000097          	auipc	ra,0x0
    80004d1c:	8b4080e7          	jalr	-1868(ra) # 800045cc <begin_op>
      ilock(f->ip);
    80004d20:	01893503          	ld	a0,24(s2)
    80004d24:	fffff097          	auipc	ra,0xfffff
    80004d28:	edc080e7          	jalr	-292(ra) # 80003c00 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d2c:	8756                	mv	a4,s5
    80004d2e:	02092683          	lw	a3,32(s2)
    80004d32:	01698633          	add	a2,s3,s6
    80004d36:	4585                	li	a1,1
    80004d38:	01893503          	ld	a0,24(s2)
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	270080e7          	jalr	624(ra) # 80003fac <writei>
    80004d44:	84aa                	mv	s1,a0
    80004d46:	00a05763          	blez	a0,80004d54 <filewrite+0xc4>
        f->off += r;
    80004d4a:	02092783          	lw	a5,32(s2)
    80004d4e:	9fa9                	addw	a5,a5,a0
    80004d50:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d54:	01893503          	ld	a0,24(s2)
    80004d58:	fffff097          	auipc	ra,0xfffff
    80004d5c:	f6a080e7          	jalr	-150(ra) # 80003cc2 <iunlock>
      end_op();
    80004d60:	00000097          	auipc	ra,0x0
    80004d64:	8ea080e7          	jalr	-1814(ra) # 8000464a <end_op>

      if(r != n1){
    80004d68:	009a9f63          	bne	s5,s1,80004d86 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d6c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d70:	0149db63          	bge	s3,s4,80004d86 <filewrite+0xf6>
      int n1 = n - i;
    80004d74:	413a04bb          	subw	s1,s4,s3
    80004d78:	0004879b          	sext.w	a5,s1
    80004d7c:	f8fbdce3          	bge	s7,a5,80004d14 <filewrite+0x84>
    80004d80:	84e2                	mv	s1,s8
    80004d82:	bf49                	j	80004d14 <filewrite+0x84>
    int i = 0;
    80004d84:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d86:	013a1f63          	bne	s4,s3,80004da4 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d8a:	8552                	mv	a0,s4
    80004d8c:	60a6                	ld	ra,72(sp)
    80004d8e:	6406                	ld	s0,64(sp)
    80004d90:	74e2                	ld	s1,56(sp)
    80004d92:	7942                	ld	s2,48(sp)
    80004d94:	79a2                	ld	s3,40(sp)
    80004d96:	7a02                	ld	s4,32(sp)
    80004d98:	6ae2                	ld	s5,24(sp)
    80004d9a:	6b42                	ld	s6,16(sp)
    80004d9c:	6ba2                	ld	s7,8(sp)
    80004d9e:	6c02                	ld	s8,0(sp)
    80004da0:	6161                	addi	sp,sp,80
    80004da2:	8082                	ret
    ret = (i == n ? n : -1);
    80004da4:	5a7d                	li	s4,-1
    80004da6:	b7d5                	j	80004d8a <filewrite+0xfa>
    panic("filewrite");
    80004da8:	00004517          	auipc	a0,0x4
    80004dac:	95050513          	addi	a0,a0,-1712 # 800086f8 <syscalls+0x2a8>
    80004db0:	ffffb097          	auipc	ra,0xffffb
    80004db4:	790080e7          	jalr	1936(ra) # 80000540 <panic>
    return -1;
    80004db8:	5a7d                	li	s4,-1
    80004dba:	bfc1                	j	80004d8a <filewrite+0xfa>
      return -1;
    80004dbc:	5a7d                	li	s4,-1
    80004dbe:	b7f1                	j	80004d8a <filewrite+0xfa>
    80004dc0:	5a7d                	li	s4,-1
    80004dc2:	b7e1                	j	80004d8a <filewrite+0xfa>

0000000080004dc4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004dc4:	7179                	addi	sp,sp,-48
    80004dc6:	f406                	sd	ra,40(sp)
    80004dc8:	f022                	sd	s0,32(sp)
    80004dca:	ec26                	sd	s1,24(sp)
    80004dcc:	e84a                	sd	s2,16(sp)
    80004dce:	e44e                	sd	s3,8(sp)
    80004dd0:	e052                	sd	s4,0(sp)
    80004dd2:	1800                	addi	s0,sp,48
    80004dd4:	84aa                	mv	s1,a0
    80004dd6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004dd8:	0005b023          	sd	zero,0(a1)
    80004ddc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004de0:	00000097          	auipc	ra,0x0
    80004de4:	bf8080e7          	jalr	-1032(ra) # 800049d8 <filealloc>
    80004de8:	e088                	sd	a0,0(s1)
    80004dea:	c551                	beqz	a0,80004e76 <pipealloc+0xb2>
    80004dec:	00000097          	auipc	ra,0x0
    80004df0:	bec080e7          	jalr	-1044(ra) # 800049d8 <filealloc>
    80004df4:	00aa3023          	sd	a0,0(s4)
    80004df8:	c92d                	beqz	a0,80004e6a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004dfa:	ffffc097          	auipc	ra,0xffffc
    80004dfe:	cec080e7          	jalr	-788(ra) # 80000ae6 <kalloc>
    80004e02:	892a                	mv	s2,a0
    80004e04:	c125                	beqz	a0,80004e64 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e06:	4985                	li	s3,1
    80004e08:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e0c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e10:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e14:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e18:	00004597          	auipc	a1,0x4
    80004e1c:	8f058593          	addi	a1,a1,-1808 # 80008708 <syscalls+0x2b8>
    80004e20:	ffffc097          	auipc	ra,0xffffc
    80004e24:	d26080e7          	jalr	-730(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004e28:	609c                	ld	a5,0(s1)
    80004e2a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e2e:	609c                	ld	a5,0(s1)
    80004e30:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e34:	609c                	ld	a5,0(s1)
    80004e36:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e3a:	609c                	ld	a5,0(s1)
    80004e3c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e40:	000a3783          	ld	a5,0(s4)
    80004e44:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e48:	000a3783          	ld	a5,0(s4)
    80004e4c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e50:	000a3783          	ld	a5,0(s4)
    80004e54:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e58:	000a3783          	ld	a5,0(s4)
    80004e5c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e60:	4501                	li	a0,0
    80004e62:	a025                	j	80004e8a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e64:	6088                	ld	a0,0(s1)
    80004e66:	e501                	bnez	a0,80004e6e <pipealloc+0xaa>
    80004e68:	a039                	j	80004e76 <pipealloc+0xb2>
    80004e6a:	6088                	ld	a0,0(s1)
    80004e6c:	c51d                	beqz	a0,80004e9a <pipealloc+0xd6>
    fileclose(*f0);
    80004e6e:	00000097          	auipc	ra,0x0
    80004e72:	c26080e7          	jalr	-986(ra) # 80004a94 <fileclose>
  if(*f1)
    80004e76:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e7a:	557d                	li	a0,-1
  if(*f1)
    80004e7c:	c799                	beqz	a5,80004e8a <pipealloc+0xc6>
    fileclose(*f1);
    80004e7e:	853e                	mv	a0,a5
    80004e80:	00000097          	auipc	ra,0x0
    80004e84:	c14080e7          	jalr	-1004(ra) # 80004a94 <fileclose>
  return -1;
    80004e88:	557d                	li	a0,-1
}
    80004e8a:	70a2                	ld	ra,40(sp)
    80004e8c:	7402                	ld	s0,32(sp)
    80004e8e:	64e2                	ld	s1,24(sp)
    80004e90:	6942                	ld	s2,16(sp)
    80004e92:	69a2                	ld	s3,8(sp)
    80004e94:	6a02                	ld	s4,0(sp)
    80004e96:	6145                	addi	sp,sp,48
    80004e98:	8082                	ret
  return -1;
    80004e9a:	557d                	li	a0,-1
    80004e9c:	b7fd                	j	80004e8a <pipealloc+0xc6>

0000000080004e9e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e9e:	1101                	addi	sp,sp,-32
    80004ea0:	ec06                	sd	ra,24(sp)
    80004ea2:	e822                	sd	s0,16(sp)
    80004ea4:	e426                	sd	s1,8(sp)
    80004ea6:	e04a                	sd	s2,0(sp)
    80004ea8:	1000                	addi	s0,sp,32
    80004eaa:	84aa                	mv	s1,a0
    80004eac:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004eae:	ffffc097          	auipc	ra,0xffffc
    80004eb2:	d28080e7          	jalr	-728(ra) # 80000bd6 <acquire>
  if(writable){
    80004eb6:	02090d63          	beqz	s2,80004ef0 <pipeclose+0x52>
    pi->writeopen = 0;
    80004eba:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ebe:	21848513          	addi	a0,s1,536
    80004ec2:	ffffd097          	auipc	ra,0xffffd
    80004ec6:	34a080e7          	jalr	842(ra) # 8000220c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004eca:	2204b783          	ld	a5,544(s1)
    80004ece:	eb95                	bnez	a5,80004f02 <pipeclose+0x64>
    release(&pi->lock);
    80004ed0:	8526                	mv	a0,s1
    80004ed2:	ffffc097          	auipc	ra,0xffffc
    80004ed6:	db8080e7          	jalr	-584(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004eda:	8526                	mv	a0,s1
    80004edc:	ffffc097          	auipc	ra,0xffffc
    80004ee0:	b0c080e7          	jalr	-1268(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004ee4:	60e2                	ld	ra,24(sp)
    80004ee6:	6442                	ld	s0,16(sp)
    80004ee8:	64a2                	ld	s1,8(sp)
    80004eea:	6902                	ld	s2,0(sp)
    80004eec:	6105                	addi	sp,sp,32
    80004eee:	8082                	ret
    pi->readopen = 0;
    80004ef0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ef4:	21c48513          	addi	a0,s1,540
    80004ef8:	ffffd097          	auipc	ra,0xffffd
    80004efc:	314080e7          	jalr	788(ra) # 8000220c <wakeup>
    80004f00:	b7e9                	j	80004eca <pipeclose+0x2c>
    release(&pi->lock);
    80004f02:	8526                	mv	a0,s1
    80004f04:	ffffc097          	auipc	ra,0xffffc
    80004f08:	d86080e7          	jalr	-634(ra) # 80000c8a <release>
}
    80004f0c:	bfe1                	j	80004ee4 <pipeclose+0x46>

0000000080004f0e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f0e:	711d                	addi	sp,sp,-96
    80004f10:	ec86                	sd	ra,88(sp)
    80004f12:	e8a2                	sd	s0,80(sp)
    80004f14:	e4a6                	sd	s1,72(sp)
    80004f16:	e0ca                	sd	s2,64(sp)
    80004f18:	fc4e                	sd	s3,56(sp)
    80004f1a:	f852                	sd	s4,48(sp)
    80004f1c:	f456                	sd	s5,40(sp)
    80004f1e:	f05a                	sd	s6,32(sp)
    80004f20:	ec5e                	sd	s7,24(sp)
    80004f22:	e862                	sd	s8,16(sp)
    80004f24:	1080                	addi	s0,sp,96
    80004f26:	84aa                	mv	s1,a0
    80004f28:	8aae                	mv	s5,a1
    80004f2a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f2c:	ffffd097          	auipc	ra,0xffffd
    80004f30:	ab0080e7          	jalr	-1360(ra) # 800019dc <myproc>
    80004f34:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f36:	8526                	mv	a0,s1
    80004f38:	ffffc097          	auipc	ra,0xffffc
    80004f3c:	c9e080e7          	jalr	-866(ra) # 80000bd6 <acquire>
  while(i < n){
    80004f40:	0b405663          	blez	s4,80004fec <pipewrite+0xde>
  int i = 0;
    80004f44:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f46:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f48:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f4c:	21c48b93          	addi	s7,s1,540
    80004f50:	a089                	j	80004f92 <pipewrite+0x84>
      release(&pi->lock);
    80004f52:	8526                	mv	a0,s1
    80004f54:	ffffc097          	auipc	ra,0xffffc
    80004f58:	d36080e7          	jalr	-714(ra) # 80000c8a <release>
      return -1;
    80004f5c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f5e:	854a                	mv	a0,s2
    80004f60:	60e6                	ld	ra,88(sp)
    80004f62:	6446                	ld	s0,80(sp)
    80004f64:	64a6                	ld	s1,72(sp)
    80004f66:	6906                	ld	s2,64(sp)
    80004f68:	79e2                	ld	s3,56(sp)
    80004f6a:	7a42                	ld	s4,48(sp)
    80004f6c:	7aa2                	ld	s5,40(sp)
    80004f6e:	7b02                	ld	s6,32(sp)
    80004f70:	6be2                	ld	s7,24(sp)
    80004f72:	6c42                	ld	s8,16(sp)
    80004f74:	6125                	addi	sp,sp,96
    80004f76:	8082                	ret
      wakeup(&pi->nread);
    80004f78:	8562                	mv	a0,s8
    80004f7a:	ffffd097          	auipc	ra,0xffffd
    80004f7e:	292080e7          	jalr	658(ra) # 8000220c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f82:	85a6                	mv	a1,s1
    80004f84:	855e                	mv	a0,s7
    80004f86:	ffffd097          	auipc	ra,0xffffd
    80004f8a:	222080e7          	jalr	546(ra) # 800021a8 <sleep>
  while(i < n){
    80004f8e:	07495063          	bge	s2,s4,80004fee <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004f92:	2204a783          	lw	a5,544(s1)
    80004f96:	dfd5                	beqz	a5,80004f52 <pipewrite+0x44>
    80004f98:	854e                	mv	a0,s3
    80004f9a:	ffffd097          	auipc	ra,0xffffd
    80004f9e:	4c2080e7          	jalr	1218(ra) # 8000245c <killed>
    80004fa2:	f945                	bnez	a0,80004f52 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004fa4:	2184a783          	lw	a5,536(s1)
    80004fa8:	21c4a703          	lw	a4,540(s1)
    80004fac:	2007879b          	addiw	a5,a5,512
    80004fb0:	fcf704e3          	beq	a4,a5,80004f78 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fb4:	4685                	li	a3,1
    80004fb6:	01590633          	add	a2,s2,s5
    80004fba:	faf40593          	addi	a1,s0,-81
    80004fbe:	0509b503          	ld	a0,80(s3)
    80004fc2:	ffffc097          	auipc	ra,0xffffc
    80004fc6:	736080e7          	jalr	1846(ra) # 800016f8 <copyin>
    80004fca:	03650263          	beq	a0,s6,80004fee <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fce:	21c4a783          	lw	a5,540(s1)
    80004fd2:	0017871b          	addiw	a4,a5,1
    80004fd6:	20e4ae23          	sw	a4,540(s1)
    80004fda:	1ff7f793          	andi	a5,a5,511
    80004fde:	97a6                	add	a5,a5,s1
    80004fe0:	faf44703          	lbu	a4,-81(s0)
    80004fe4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004fe8:	2905                	addiw	s2,s2,1
    80004fea:	b755                	j	80004f8e <pipewrite+0x80>
  int i = 0;
    80004fec:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004fee:	21848513          	addi	a0,s1,536
    80004ff2:	ffffd097          	auipc	ra,0xffffd
    80004ff6:	21a080e7          	jalr	538(ra) # 8000220c <wakeup>
  release(&pi->lock);
    80004ffa:	8526                	mv	a0,s1
    80004ffc:	ffffc097          	auipc	ra,0xffffc
    80005000:	c8e080e7          	jalr	-882(ra) # 80000c8a <release>
  return i;
    80005004:	bfa9                	j	80004f5e <pipewrite+0x50>

0000000080005006 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005006:	715d                	addi	sp,sp,-80
    80005008:	e486                	sd	ra,72(sp)
    8000500a:	e0a2                	sd	s0,64(sp)
    8000500c:	fc26                	sd	s1,56(sp)
    8000500e:	f84a                	sd	s2,48(sp)
    80005010:	f44e                	sd	s3,40(sp)
    80005012:	f052                	sd	s4,32(sp)
    80005014:	ec56                	sd	s5,24(sp)
    80005016:	e85a                	sd	s6,16(sp)
    80005018:	0880                	addi	s0,sp,80
    8000501a:	84aa                	mv	s1,a0
    8000501c:	892e                	mv	s2,a1
    8000501e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005020:	ffffd097          	auipc	ra,0xffffd
    80005024:	9bc080e7          	jalr	-1604(ra) # 800019dc <myproc>
    80005028:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000502a:	8526                	mv	a0,s1
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	baa080e7          	jalr	-1110(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005034:	2184a703          	lw	a4,536(s1)
    80005038:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000503c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005040:	02f71763          	bne	a4,a5,8000506e <piperead+0x68>
    80005044:	2244a783          	lw	a5,548(s1)
    80005048:	c39d                	beqz	a5,8000506e <piperead+0x68>
    if(killed(pr)){
    8000504a:	8552                	mv	a0,s4
    8000504c:	ffffd097          	auipc	ra,0xffffd
    80005050:	410080e7          	jalr	1040(ra) # 8000245c <killed>
    80005054:	e949                	bnez	a0,800050e6 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005056:	85a6                	mv	a1,s1
    80005058:	854e                	mv	a0,s3
    8000505a:	ffffd097          	auipc	ra,0xffffd
    8000505e:	14e080e7          	jalr	334(ra) # 800021a8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005062:	2184a703          	lw	a4,536(s1)
    80005066:	21c4a783          	lw	a5,540(s1)
    8000506a:	fcf70de3          	beq	a4,a5,80005044 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000506e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005070:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005072:	05505463          	blez	s5,800050ba <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005076:	2184a783          	lw	a5,536(s1)
    8000507a:	21c4a703          	lw	a4,540(s1)
    8000507e:	02f70e63          	beq	a4,a5,800050ba <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005082:	0017871b          	addiw	a4,a5,1
    80005086:	20e4ac23          	sw	a4,536(s1)
    8000508a:	1ff7f793          	andi	a5,a5,511
    8000508e:	97a6                	add	a5,a5,s1
    80005090:	0187c783          	lbu	a5,24(a5)
    80005094:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005098:	4685                	li	a3,1
    8000509a:	fbf40613          	addi	a2,s0,-65
    8000509e:	85ca                	mv	a1,s2
    800050a0:	050a3503          	ld	a0,80(s4)
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	5c8080e7          	jalr	1480(ra) # 8000166c <copyout>
    800050ac:	01650763          	beq	a0,s6,800050ba <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050b0:	2985                	addiw	s3,s3,1
    800050b2:	0905                	addi	s2,s2,1
    800050b4:	fd3a91e3          	bne	s5,s3,80005076 <piperead+0x70>
    800050b8:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050ba:	21c48513          	addi	a0,s1,540
    800050be:	ffffd097          	auipc	ra,0xffffd
    800050c2:	14e080e7          	jalr	334(ra) # 8000220c <wakeup>
  release(&pi->lock);
    800050c6:	8526                	mv	a0,s1
    800050c8:	ffffc097          	auipc	ra,0xffffc
    800050cc:	bc2080e7          	jalr	-1086(ra) # 80000c8a <release>
  return i;
}
    800050d0:	854e                	mv	a0,s3
    800050d2:	60a6                	ld	ra,72(sp)
    800050d4:	6406                	ld	s0,64(sp)
    800050d6:	74e2                	ld	s1,56(sp)
    800050d8:	7942                	ld	s2,48(sp)
    800050da:	79a2                	ld	s3,40(sp)
    800050dc:	7a02                	ld	s4,32(sp)
    800050de:	6ae2                	ld	s5,24(sp)
    800050e0:	6b42                	ld	s6,16(sp)
    800050e2:	6161                	addi	sp,sp,80
    800050e4:	8082                	ret
      release(&pi->lock);
    800050e6:	8526                	mv	a0,s1
    800050e8:	ffffc097          	auipc	ra,0xffffc
    800050ec:	ba2080e7          	jalr	-1118(ra) # 80000c8a <release>
      return -1;
    800050f0:	59fd                	li	s3,-1
    800050f2:	bff9                	j	800050d0 <piperead+0xca>

00000000800050f4 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800050f4:	1141                	addi	sp,sp,-16
    800050f6:	e422                	sd	s0,8(sp)
    800050f8:	0800                	addi	s0,sp,16
    800050fa:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800050fc:	8905                	andi	a0,a0,1
    800050fe:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005100:	8b89                	andi	a5,a5,2
    80005102:	c399                	beqz	a5,80005108 <flags2perm+0x14>
      perm |= PTE_W;
    80005104:	00456513          	ori	a0,a0,4
    return perm;
}
    80005108:	6422                	ld	s0,8(sp)
    8000510a:	0141                	addi	sp,sp,16
    8000510c:	8082                	ret

000000008000510e <exec>:

int
exec(char *path, char **argv)
{
    8000510e:	de010113          	addi	sp,sp,-544
    80005112:	20113c23          	sd	ra,536(sp)
    80005116:	20813823          	sd	s0,528(sp)
    8000511a:	20913423          	sd	s1,520(sp)
    8000511e:	21213023          	sd	s2,512(sp)
    80005122:	ffce                	sd	s3,504(sp)
    80005124:	fbd2                	sd	s4,496(sp)
    80005126:	f7d6                	sd	s5,488(sp)
    80005128:	f3da                	sd	s6,480(sp)
    8000512a:	efde                	sd	s7,472(sp)
    8000512c:	ebe2                	sd	s8,464(sp)
    8000512e:	e7e6                	sd	s9,456(sp)
    80005130:	e3ea                	sd	s10,448(sp)
    80005132:	ff6e                	sd	s11,440(sp)
    80005134:	1400                	addi	s0,sp,544
    80005136:	892a                	mv	s2,a0
    80005138:	dea43423          	sd	a0,-536(s0)
    8000513c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005140:	ffffd097          	auipc	ra,0xffffd
    80005144:	89c080e7          	jalr	-1892(ra) # 800019dc <myproc>
    80005148:	84aa                	mv	s1,a0

  begin_op();
    8000514a:	fffff097          	auipc	ra,0xfffff
    8000514e:	482080e7          	jalr	1154(ra) # 800045cc <begin_op>

  if((ip = namei(path)) == 0){
    80005152:	854a                	mv	a0,s2
    80005154:	fffff097          	auipc	ra,0xfffff
    80005158:	258080e7          	jalr	600(ra) # 800043ac <namei>
    8000515c:	c93d                	beqz	a0,800051d2 <exec+0xc4>
    8000515e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005160:	fffff097          	auipc	ra,0xfffff
    80005164:	aa0080e7          	jalr	-1376(ra) # 80003c00 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005168:	04000713          	li	a4,64
    8000516c:	4681                	li	a3,0
    8000516e:	e5040613          	addi	a2,s0,-432
    80005172:	4581                	li	a1,0
    80005174:	8556                	mv	a0,s5
    80005176:	fffff097          	auipc	ra,0xfffff
    8000517a:	d3e080e7          	jalr	-706(ra) # 80003eb4 <readi>
    8000517e:	04000793          	li	a5,64
    80005182:	00f51a63          	bne	a0,a5,80005196 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005186:	e5042703          	lw	a4,-432(s0)
    8000518a:	464c47b7          	lui	a5,0x464c4
    8000518e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005192:	04f70663          	beq	a4,a5,800051de <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005196:	8556                	mv	a0,s5
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	cca080e7          	jalr	-822(ra) # 80003e62 <iunlockput>
    end_op();
    800051a0:	fffff097          	auipc	ra,0xfffff
    800051a4:	4aa080e7          	jalr	1194(ra) # 8000464a <end_op>
  }
  return -1;
    800051a8:	557d                	li	a0,-1
}
    800051aa:	21813083          	ld	ra,536(sp)
    800051ae:	21013403          	ld	s0,528(sp)
    800051b2:	20813483          	ld	s1,520(sp)
    800051b6:	20013903          	ld	s2,512(sp)
    800051ba:	79fe                	ld	s3,504(sp)
    800051bc:	7a5e                	ld	s4,496(sp)
    800051be:	7abe                	ld	s5,488(sp)
    800051c0:	7b1e                	ld	s6,480(sp)
    800051c2:	6bfe                	ld	s7,472(sp)
    800051c4:	6c5e                	ld	s8,464(sp)
    800051c6:	6cbe                	ld	s9,456(sp)
    800051c8:	6d1e                	ld	s10,448(sp)
    800051ca:	7dfa                	ld	s11,440(sp)
    800051cc:	22010113          	addi	sp,sp,544
    800051d0:	8082                	ret
    end_op();
    800051d2:	fffff097          	auipc	ra,0xfffff
    800051d6:	478080e7          	jalr	1144(ra) # 8000464a <end_op>
    return -1;
    800051da:	557d                	li	a0,-1
    800051dc:	b7f9                	j	800051aa <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800051de:	8526                	mv	a0,s1
    800051e0:	ffffd097          	auipc	ra,0xffffd
    800051e4:	8c0080e7          	jalr	-1856(ra) # 80001aa0 <proc_pagetable>
    800051e8:	8b2a                	mv	s6,a0
    800051ea:	d555                	beqz	a0,80005196 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051ec:	e7042783          	lw	a5,-400(s0)
    800051f0:	e8845703          	lhu	a4,-376(s0)
    800051f4:	c735                	beqz	a4,80005260 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051f6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051f8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800051fc:	6a05                	lui	s4,0x1
    800051fe:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005202:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005206:	6d85                	lui	s11,0x1
    80005208:	7d7d                	lui	s10,0xfffff
    8000520a:	ac3d                	j	80005448 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000520c:	00003517          	auipc	a0,0x3
    80005210:	50450513          	addi	a0,a0,1284 # 80008710 <syscalls+0x2c0>
    80005214:	ffffb097          	auipc	ra,0xffffb
    80005218:	32c080e7          	jalr	812(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000521c:	874a                	mv	a4,s2
    8000521e:	009c86bb          	addw	a3,s9,s1
    80005222:	4581                	li	a1,0
    80005224:	8556                	mv	a0,s5
    80005226:	fffff097          	auipc	ra,0xfffff
    8000522a:	c8e080e7          	jalr	-882(ra) # 80003eb4 <readi>
    8000522e:	2501                	sext.w	a0,a0
    80005230:	1aa91963          	bne	s2,a0,800053e2 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005234:	009d84bb          	addw	s1,s11,s1
    80005238:	013d09bb          	addw	s3,s10,s3
    8000523c:	1f74f663          	bgeu	s1,s7,80005428 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005240:	02049593          	slli	a1,s1,0x20
    80005244:	9181                	srli	a1,a1,0x20
    80005246:	95e2                	add	a1,a1,s8
    80005248:	855a                	mv	a0,s6
    8000524a:	ffffc097          	auipc	ra,0xffffc
    8000524e:	e12080e7          	jalr	-494(ra) # 8000105c <walkaddr>
    80005252:	862a                	mv	a2,a0
    if(pa == 0)
    80005254:	dd45                	beqz	a0,8000520c <exec+0xfe>
      n = PGSIZE;
    80005256:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005258:	fd49f2e3          	bgeu	s3,s4,8000521c <exec+0x10e>
      n = sz - i;
    8000525c:	894e                	mv	s2,s3
    8000525e:	bf7d                	j	8000521c <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005260:	4901                	li	s2,0
  iunlockput(ip);
    80005262:	8556                	mv	a0,s5
    80005264:	fffff097          	auipc	ra,0xfffff
    80005268:	bfe080e7          	jalr	-1026(ra) # 80003e62 <iunlockput>
  end_op();
    8000526c:	fffff097          	auipc	ra,0xfffff
    80005270:	3de080e7          	jalr	990(ra) # 8000464a <end_op>
  p = myproc();
    80005274:	ffffc097          	auipc	ra,0xffffc
    80005278:	768080e7          	jalr	1896(ra) # 800019dc <myproc>
    8000527c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000527e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005282:	6785                	lui	a5,0x1
    80005284:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005286:	97ca                	add	a5,a5,s2
    80005288:	777d                	lui	a4,0xfffff
    8000528a:	8ff9                	and	a5,a5,a4
    8000528c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005290:	4691                	li	a3,4
    80005292:	6609                	lui	a2,0x2
    80005294:	963e                	add	a2,a2,a5
    80005296:	85be                	mv	a1,a5
    80005298:	855a                	mv	a0,s6
    8000529a:	ffffc097          	auipc	ra,0xffffc
    8000529e:	176080e7          	jalr	374(ra) # 80001410 <uvmalloc>
    800052a2:	8c2a                	mv	s8,a0
  ip = 0;
    800052a4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052a6:	12050e63          	beqz	a0,800053e2 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052aa:	75f9                	lui	a1,0xffffe
    800052ac:	95aa                	add	a1,a1,a0
    800052ae:	855a                	mv	a0,s6
    800052b0:	ffffc097          	auipc	ra,0xffffc
    800052b4:	38a080e7          	jalr	906(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    800052b8:	7afd                	lui	s5,0xfffff
    800052ba:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800052bc:	df043783          	ld	a5,-528(s0)
    800052c0:	6388                	ld	a0,0(a5)
    800052c2:	c925                	beqz	a0,80005332 <exec+0x224>
    800052c4:	e9040993          	addi	s3,s0,-368
    800052c8:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800052cc:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800052ce:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800052d0:	ffffc097          	auipc	ra,0xffffc
    800052d4:	b7e080e7          	jalr	-1154(ra) # 80000e4e <strlen>
    800052d8:	0015079b          	addiw	a5,a0,1
    800052dc:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052e0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800052e4:	13596663          	bltu	s2,s5,80005410 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052e8:	df043d83          	ld	s11,-528(s0)
    800052ec:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800052f0:	8552                	mv	a0,s4
    800052f2:	ffffc097          	auipc	ra,0xffffc
    800052f6:	b5c080e7          	jalr	-1188(ra) # 80000e4e <strlen>
    800052fa:	0015069b          	addiw	a3,a0,1
    800052fe:	8652                	mv	a2,s4
    80005300:	85ca                	mv	a1,s2
    80005302:	855a                	mv	a0,s6
    80005304:	ffffc097          	auipc	ra,0xffffc
    80005308:	368080e7          	jalr	872(ra) # 8000166c <copyout>
    8000530c:	10054663          	bltz	a0,80005418 <exec+0x30a>
    ustack[argc] = sp;
    80005310:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005314:	0485                	addi	s1,s1,1
    80005316:	008d8793          	addi	a5,s11,8
    8000531a:	def43823          	sd	a5,-528(s0)
    8000531e:	008db503          	ld	a0,8(s11)
    80005322:	c911                	beqz	a0,80005336 <exec+0x228>
    if(argc >= MAXARG)
    80005324:	09a1                	addi	s3,s3,8
    80005326:	fb3c95e3          	bne	s9,s3,800052d0 <exec+0x1c2>
  sz = sz1;
    8000532a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000532e:	4a81                	li	s5,0
    80005330:	a84d                	j	800053e2 <exec+0x2d4>
  sp = sz;
    80005332:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005334:	4481                	li	s1,0
  ustack[argc] = 0;
    80005336:	00349793          	slli	a5,s1,0x3
    8000533a:	f9078793          	addi	a5,a5,-112
    8000533e:	97a2                	add	a5,a5,s0
    80005340:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005344:	00148693          	addi	a3,s1,1
    80005348:	068e                	slli	a3,a3,0x3
    8000534a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000534e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005352:	01597663          	bgeu	s2,s5,8000535e <exec+0x250>
  sz = sz1;
    80005356:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000535a:	4a81                	li	s5,0
    8000535c:	a059                	j	800053e2 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000535e:	e9040613          	addi	a2,s0,-368
    80005362:	85ca                	mv	a1,s2
    80005364:	855a                	mv	a0,s6
    80005366:	ffffc097          	auipc	ra,0xffffc
    8000536a:	306080e7          	jalr	774(ra) # 8000166c <copyout>
    8000536e:	0a054963          	bltz	a0,80005420 <exec+0x312>
  p->trapframe->a1 = sp;
    80005372:	058bb783          	ld	a5,88(s7)
    80005376:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000537a:	de843783          	ld	a5,-536(s0)
    8000537e:	0007c703          	lbu	a4,0(a5)
    80005382:	cf11                	beqz	a4,8000539e <exec+0x290>
    80005384:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005386:	02f00693          	li	a3,47
    8000538a:	a039                	j	80005398 <exec+0x28a>
      last = s+1;
    8000538c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005390:	0785                	addi	a5,a5,1
    80005392:	fff7c703          	lbu	a4,-1(a5)
    80005396:	c701                	beqz	a4,8000539e <exec+0x290>
    if(*s == '/')
    80005398:	fed71ce3          	bne	a4,a3,80005390 <exec+0x282>
    8000539c:	bfc5                	j	8000538c <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000539e:	4641                	li	a2,16
    800053a0:	de843583          	ld	a1,-536(s0)
    800053a4:	158b8513          	addi	a0,s7,344
    800053a8:	ffffc097          	auipc	ra,0xffffc
    800053ac:	a74080e7          	jalr	-1420(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800053b0:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800053b4:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800053b8:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053bc:	058bb783          	ld	a5,88(s7)
    800053c0:	e6843703          	ld	a4,-408(s0)
    800053c4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053c6:	058bb783          	ld	a5,88(s7)
    800053ca:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053ce:	85ea                	mv	a1,s10
    800053d0:	ffffc097          	auipc	ra,0xffffc
    800053d4:	76c080e7          	jalr	1900(ra) # 80001b3c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053d8:	0004851b          	sext.w	a0,s1
    800053dc:	b3f9                	j	800051aa <exec+0x9c>
    800053de:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800053e2:	df843583          	ld	a1,-520(s0)
    800053e6:	855a                	mv	a0,s6
    800053e8:	ffffc097          	auipc	ra,0xffffc
    800053ec:	754080e7          	jalr	1876(ra) # 80001b3c <proc_freepagetable>
  if(ip){
    800053f0:	da0a93e3          	bnez	s5,80005196 <exec+0x88>
  return -1;
    800053f4:	557d                	li	a0,-1
    800053f6:	bb55                	j	800051aa <exec+0x9c>
    800053f8:	df243c23          	sd	s2,-520(s0)
    800053fc:	b7dd                	j	800053e2 <exec+0x2d4>
    800053fe:	df243c23          	sd	s2,-520(s0)
    80005402:	b7c5                	j	800053e2 <exec+0x2d4>
    80005404:	df243c23          	sd	s2,-520(s0)
    80005408:	bfe9                	j	800053e2 <exec+0x2d4>
    8000540a:	df243c23          	sd	s2,-520(s0)
    8000540e:	bfd1                	j	800053e2 <exec+0x2d4>
  sz = sz1;
    80005410:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005414:	4a81                	li	s5,0
    80005416:	b7f1                	j	800053e2 <exec+0x2d4>
  sz = sz1;
    80005418:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000541c:	4a81                	li	s5,0
    8000541e:	b7d1                	j	800053e2 <exec+0x2d4>
  sz = sz1;
    80005420:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005424:	4a81                	li	s5,0
    80005426:	bf75                	j	800053e2 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005428:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000542c:	e0843783          	ld	a5,-504(s0)
    80005430:	0017869b          	addiw	a3,a5,1
    80005434:	e0d43423          	sd	a3,-504(s0)
    80005438:	e0043783          	ld	a5,-512(s0)
    8000543c:	0387879b          	addiw	a5,a5,56
    80005440:	e8845703          	lhu	a4,-376(s0)
    80005444:	e0e6dfe3          	bge	a3,a4,80005262 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005448:	2781                	sext.w	a5,a5
    8000544a:	e0f43023          	sd	a5,-512(s0)
    8000544e:	03800713          	li	a4,56
    80005452:	86be                	mv	a3,a5
    80005454:	e1840613          	addi	a2,s0,-488
    80005458:	4581                	li	a1,0
    8000545a:	8556                	mv	a0,s5
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	a58080e7          	jalr	-1448(ra) # 80003eb4 <readi>
    80005464:	03800793          	li	a5,56
    80005468:	f6f51be3          	bne	a0,a5,800053de <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000546c:	e1842783          	lw	a5,-488(s0)
    80005470:	4705                	li	a4,1
    80005472:	fae79de3          	bne	a5,a4,8000542c <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005476:	e4043483          	ld	s1,-448(s0)
    8000547a:	e3843783          	ld	a5,-456(s0)
    8000547e:	f6f4ede3          	bltu	s1,a5,800053f8 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005482:	e2843783          	ld	a5,-472(s0)
    80005486:	94be                	add	s1,s1,a5
    80005488:	f6f4ebe3          	bltu	s1,a5,800053fe <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    8000548c:	de043703          	ld	a4,-544(s0)
    80005490:	8ff9                	and	a5,a5,a4
    80005492:	fbad                	bnez	a5,80005404 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005494:	e1c42503          	lw	a0,-484(s0)
    80005498:	00000097          	auipc	ra,0x0
    8000549c:	c5c080e7          	jalr	-932(ra) # 800050f4 <flags2perm>
    800054a0:	86aa                	mv	a3,a0
    800054a2:	8626                	mv	a2,s1
    800054a4:	85ca                	mv	a1,s2
    800054a6:	855a                	mv	a0,s6
    800054a8:	ffffc097          	auipc	ra,0xffffc
    800054ac:	f68080e7          	jalr	-152(ra) # 80001410 <uvmalloc>
    800054b0:	dea43c23          	sd	a0,-520(s0)
    800054b4:	d939                	beqz	a0,8000540a <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054b6:	e2843c03          	ld	s8,-472(s0)
    800054ba:	e2042c83          	lw	s9,-480(s0)
    800054be:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054c2:	f60b83e3          	beqz	s7,80005428 <exec+0x31a>
    800054c6:	89de                	mv	s3,s7
    800054c8:	4481                	li	s1,0
    800054ca:	bb9d                	j	80005240 <exec+0x132>

00000000800054cc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054cc:	7179                	addi	sp,sp,-48
    800054ce:	f406                	sd	ra,40(sp)
    800054d0:	f022                	sd	s0,32(sp)
    800054d2:	ec26                	sd	s1,24(sp)
    800054d4:	e84a                	sd	s2,16(sp)
    800054d6:	1800                	addi	s0,sp,48
    800054d8:	892e                	mv	s2,a1
    800054da:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054dc:	fdc40593          	addi	a1,s0,-36
    800054e0:	ffffe097          	auipc	ra,0xffffe
    800054e4:	940080e7          	jalr	-1728(ra) # 80002e20 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054e8:	fdc42703          	lw	a4,-36(s0)
    800054ec:	47bd                	li	a5,15
    800054ee:	02e7eb63          	bltu	a5,a4,80005524 <argfd+0x58>
    800054f2:	ffffc097          	auipc	ra,0xffffc
    800054f6:	4ea080e7          	jalr	1258(ra) # 800019dc <myproc>
    800054fa:	fdc42703          	lw	a4,-36(s0)
    800054fe:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd59fa>
    80005502:	078e                	slli	a5,a5,0x3
    80005504:	953e                	add	a0,a0,a5
    80005506:	611c                	ld	a5,0(a0)
    80005508:	c385                	beqz	a5,80005528 <argfd+0x5c>
    return -1;
  if(pfd)
    8000550a:	00090463          	beqz	s2,80005512 <argfd+0x46>
    *pfd = fd;
    8000550e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005512:	4501                	li	a0,0
  if(pf)
    80005514:	c091                	beqz	s1,80005518 <argfd+0x4c>
    *pf = f;
    80005516:	e09c                	sd	a5,0(s1)
}
    80005518:	70a2                	ld	ra,40(sp)
    8000551a:	7402                	ld	s0,32(sp)
    8000551c:	64e2                	ld	s1,24(sp)
    8000551e:	6942                	ld	s2,16(sp)
    80005520:	6145                	addi	sp,sp,48
    80005522:	8082                	ret
    return -1;
    80005524:	557d                	li	a0,-1
    80005526:	bfcd                	j	80005518 <argfd+0x4c>
    80005528:	557d                	li	a0,-1
    8000552a:	b7fd                	j	80005518 <argfd+0x4c>

000000008000552c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000552c:	1101                	addi	sp,sp,-32
    8000552e:	ec06                	sd	ra,24(sp)
    80005530:	e822                	sd	s0,16(sp)
    80005532:	e426                	sd	s1,8(sp)
    80005534:	1000                	addi	s0,sp,32
    80005536:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005538:	ffffc097          	auipc	ra,0xffffc
    8000553c:	4a4080e7          	jalr	1188(ra) # 800019dc <myproc>
    80005540:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005542:	0d050793          	addi	a5,a0,208
    80005546:	4501                	li	a0,0
    80005548:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000554a:	6398                	ld	a4,0(a5)
    8000554c:	cb19                	beqz	a4,80005562 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000554e:	2505                	addiw	a0,a0,1
    80005550:	07a1                	addi	a5,a5,8
    80005552:	fed51ce3          	bne	a0,a3,8000554a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005556:	557d                	li	a0,-1
}
    80005558:	60e2                	ld	ra,24(sp)
    8000555a:	6442                	ld	s0,16(sp)
    8000555c:	64a2                	ld	s1,8(sp)
    8000555e:	6105                	addi	sp,sp,32
    80005560:	8082                	ret
      p->ofile[fd] = f;
    80005562:	01a50793          	addi	a5,a0,26
    80005566:	078e                	slli	a5,a5,0x3
    80005568:	963e                	add	a2,a2,a5
    8000556a:	e204                	sd	s1,0(a2)
      return fd;
    8000556c:	b7f5                	j	80005558 <fdalloc+0x2c>

000000008000556e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000556e:	715d                	addi	sp,sp,-80
    80005570:	e486                	sd	ra,72(sp)
    80005572:	e0a2                	sd	s0,64(sp)
    80005574:	fc26                	sd	s1,56(sp)
    80005576:	f84a                	sd	s2,48(sp)
    80005578:	f44e                	sd	s3,40(sp)
    8000557a:	f052                	sd	s4,32(sp)
    8000557c:	ec56                	sd	s5,24(sp)
    8000557e:	e85a                	sd	s6,16(sp)
    80005580:	0880                	addi	s0,sp,80
    80005582:	8b2e                	mv	s6,a1
    80005584:	89b2                	mv	s3,a2
    80005586:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005588:	fb040593          	addi	a1,s0,-80
    8000558c:	fffff097          	auipc	ra,0xfffff
    80005590:	e3e080e7          	jalr	-450(ra) # 800043ca <nameiparent>
    80005594:	84aa                	mv	s1,a0
    80005596:	14050f63          	beqz	a0,800056f4 <create+0x186>
    return 0;

  ilock(dp);
    8000559a:	ffffe097          	auipc	ra,0xffffe
    8000559e:	666080e7          	jalr	1638(ra) # 80003c00 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055a2:	4601                	li	a2,0
    800055a4:	fb040593          	addi	a1,s0,-80
    800055a8:	8526                	mv	a0,s1
    800055aa:	fffff097          	auipc	ra,0xfffff
    800055ae:	b3a080e7          	jalr	-1222(ra) # 800040e4 <dirlookup>
    800055b2:	8aaa                	mv	s5,a0
    800055b4:	c931                	beqz	a0,80005608 <create+0x9a>
    iunlockput(dp);
    800055b6:	8526                	mv	a0,s1
    800055b8:	fffff097          	auipc	ra,0xfffff
    800055bc:	8aa080e7          	jalr	-1878(ra) # 80003e62 <iunlockput>
    ilock(ip);
    800055c0:	8556                	mv	a0,s5
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	63e080e7          	jalr	1598(ra) # 80003c00 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055ca:	000b059b          	sext.w	a1,s6
    800055ce:	4789                	li	a5,2
    800055d0:	02f59563          	bne	a1,a5,800055fa <create+0x8c>
    800055d4:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffd5a24>
    800055d8:	37f9                	addiw	a5,a5,-2
    800055da:	17c2                	slli	a5,a5,0x30
    800055dc:	93c1                	srli	a5,a5,0x30
    800055de:	4705                	li	a4,1
    800055e0:	00f76d63          	bltu	a4,a5,800055fa <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055e4:	8556                	mv	a0,s5
    800055e6:	60a6                	ld	ra,72(sp)
    800055e8:	6406                	ld	s0,64(sp)
    800055ea:	74e2                	ld	s1,56(sp)
    800055ec:	7942                	ld	s2,48(sp)
    800055ee:	79a2                	ld	s3,40(sp)
    800055f0:	7a02                	ld	s4,32(sp)
    800055f2:	6ae2                	ld	s5,24(sp)
    800055f4:	6b42                	ld	s6,16(sp)
    800055f6:	6161                	addi	sp,sp,80
    800055f8:	8082                	ret
    iunlockput(ip);
    800055fa:	8556                	mv	a0,s5
    800055fc:	fffff097          	auipc	ra,0xfffff
    80005600:	866080e7          	jalr	-1946(ra) # 80003e62 <iunlockput>
    return 0;
    80005604:	4a81                	li	s5,0
    80005606:	bff9                	j	800055e4 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005608:	85da                	mv	a1,s6
    8000560a:	4088                	lw	a0,0(s1)
    8000560c:	ffffe097          	auipc	ra,0xffffe
    80005610:	456080e7          	jalr	1110(ra) # 80003a62 <ialloc>
    80005614:	8a2a                	mv	s4,a0
    80005616:	c539                	beqz	a0,80005664 <create+0xf6>
  ilock(ip);
    80005618:	ffffe097          	auipc	ra,0xffffe
    8000561c:	5e8080e7          	jalr	1512(ra) # 80003c00 <ilock>
  ip->major = major;
    80005620:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005624:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005628:	4905                	li	s2,1
    8000562a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000562e:	8552                	mv	a0,s4
    80005630:	ffffe097          	auipc	ra,0xffffe
    80005634:	504080e7          	jalr	1284(ra) # 80003b34 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005638:	000b059b          	sext.w	a1,s6
    8000563c:	03258b63          	beq	a1,s2,80005672 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005640:	004a2603          	lw	a2,4(s4)
    80005644:	fb040593          	addi	a1,s0,-80
    80005648:	8526                	mv	a0,s1
    8000564a:	fffff097          	auipc	ra,0xfffff
    8000564e:	cb0080e7          	jalr	-848(ra) # 800042fa <dirlink>
    80005652:	06054f63          	bltz	a0,800056d0 <create+0x162>
  iunlockput(dp);
    80005656:	8526                	mv	a0,s1
    80005658:	fffff097          	auipc	ra,0xfffff
    8000565c:	80a080e7          	jalr	-2038(ra) # 80003e62 <iunlockput>
  return ip;
    80005660:	8ad2                	mv	s5,s4
    80005662:	b749                	j	800055e4 <create+0x76>
    iunlockput(dp);
    80005664:	8526                	mv	a0,s1
    80005666:	ffffe097          	auipc	ra,0xffffe
    8000566a:	7fc080e7          	jalr	2044(ra) # 80003e62 <iunlockput>
    return 0;
    8000566e:	8ad2                	mv	s5,s4
    80005670:	bf95                	j	800055e4 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005672:	004a2603          	lw	a2,4(s4)
    80005676:	00003597          	auipc	a1,0x3
    8000567a:	0ba58593          	addi	a1,a1,186 # 80008730 <syscalls+0x2e0>
    8000567e:	8552                	mv	a0,s4
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	c7a080e7          	jalr	-902(ra) # 800042fa <dirlink>
    80005688:	04054463          	bltz	a0,800056d0 <create+0x162>
    8000568c:	40d0                	lw	a2,4(s1)
    8000568e:	00003597          	auipc	a1,0x3
    80005692:	0aa58593          	addi	a1,a1,170 # 80008738 <syscalls+0x2e8>
    80005696:	8552                	mv	a0,s4
    80005698:	fffff097          	auipc	ra,0xfffff
    8000569c:	c62080e7          	jalr	-926(ra) # 800042fa <dirlink>
    800056a0:	02054863          	bltz	a0,800056d0 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800056a4:	004a2603          	lw	a2,4(s4)
    800056a8:	fb040593          	addi	a1,s0,-80
    800056ac:	8526                	mv	a0,s1
    800056ae:	fffff097          	auipc	ra,0xfffff
    800056b2:	c4c080e7          	jalr	-948(ra) # 800042fa <dirlink>
    800056b6:	00054d63          	bltz	a0,800056d0 <create+0x162>
    dp->nlink++;  // for ".."
    800056ba:	04a4d783          	lhu	a5,74(s1)
    800056be:	2785                	addiw	a5,a5,1
    800056c0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056c4:	8526                	mv	a0,s1
    800056c6:	ffffe097          	auipc	ra,0xffffe
    800056ca:	46e080e7          	jalr	1134(ra) # 80003b34 <iupdate>
    800056ce:	b761                	j	80005656 <create+0xe8>
  ip->nlink = 0;
    800056d0:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800056d4:	8552                	mv	a0,s4
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	45e080e7          	jalr	1118(ra) # 80003b34 <iupdate>
  iunlockput(ip);
    800056de:	8552                	mv	a0,s4
    800056e0:	ffffe097          	auipc	ra,0xffffe
    800056e4:	782080e7          	jalr	1922(ra) # 80003e62 <iunlockput>
  iunlockput(dp);
    800056e8:	8526                	mv	a0,s1
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	778080e7          	jalr	1912(ra) # 80003e62 <iunlockput>
  return 0;
    800056f2:	bdcd                	j	800055e4 <create+0x76>
    return 0;
    800056f4:	8aaa                	mv	s5,a0
    800056f6:	b5fd                	j	800055e4 <create+0x76>

00000000800056f8 <sys_dup>:
{
    800056f8:	7179                	addi	sp,sp,-48
    800056fa:	f406                	sd	ra,40(sp)
    800056fc:	f022                	sd	s0,32(sp)
    800056fe:	ec26                	sd	s1,24(sp)
    80005700:	e84a                	sd	s2,16(sp)
    80005702:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005704:	fd840613          	addi	a2,s0,-40
    80005708:	4581                	li	a1,0
    8000570a:	4501                	li	a0,0
    8000570c:	00000097          	auipc	ra,0x0
    80005710:	dc0080e7          	jalr	-576(ra) # 800054cc <argfd>
    return -1;
    80005714:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005716:	02054363          	bltz	a0,8000573c <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000571a:	fd843903          	ld	s2,-40(s0)
    8000571e:	854a                	mv	a0,s2
    80005720:	00000097          	auipc	ra,0x0
    80005724:	e0c080e7          	jalr	-500(ra) # 8000552c <fdalloc>
    80005728:	84aa                	mv	s1,a0
    return -1;
    8000572a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000572c:	00054863          	bltz	a0,8000573c <sys_dup+0x44>
  filedup(f);
    80005730:	854a                	mv	a0,s2
    80005732:	fffff097          	auipc	ra,0xfffff
    80005736:	310080e7          	jalr	784(ra) # 80004a42 <filedup>
  return fd;
    8000573a:	87a6                	mv	a5,s1
}
    8000573c:	853e                	mv	a0,a5
    8000573e:	70a2                	ld	ra,40(sp)
    80005740:	7402                	ld	s0,32(sp)
    80005742:	64e2                	ld	s1,24(sp)
    80005744:	6942                	ld	s2,16(sp)
    80005746:	6145                	addi	sp,sp,48
    80005748:	8082                	ret

000000008000574a <sys_read>:
{
    8000574a:	7179                	addi	sp,sp,-48
    8000574c:	f406                	sd	ra,40(sp)
    8000574e:	f022                	sd	s0,32(sp)
    80005750:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005752:	fd840593          	addi	a1,s0,-40
    80005756:	4505                	li	a0,1
    80005758:	ffffd097          	auipc	ra,0xffffd
    8000575c:	6ea080e7          	jalr	1770(ra) # 80002e42 <argaddr>
  argint(2, &n);
    80005760:	fe440593          	addi	a1,s0,-28
    80005764:	4509                	li	a0,2
    80005766:	ffffd097          	auipc	ra,0xffffd
    8000576a:	6ba080e7          	jalr	1722(ra) # 80002e20 <argint>
  if(argfd(0, 0, &f) < 0)
    8000576e:	fe840613          	addi	a2,s0,-24
    80005772:	4581                	li	a1,0
    80005774:	4501                	li	a0,0
    80005776:	00000097          	auipc	ra,0x0
    8000577a:	d56080e7          	jalr	-682(ra) # 800054cc <argfd>
    8000577e:	87aa                	mv	a5,a0
    return -1;
    80005780:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005782:	0007cc63          	bltz	a5,8000579a <sys_read+0x50>
  return fileread(f, p, n);
    80005786:	fe442603          	lw	a2,-28(s0)
    8000578a:	fd843583          	ld	a1,-40(s0)
    8000578e:	fe843503          	ld	a0,-24(s0)
    80005792:	fffff097          	auipc	ra,0xfffff
    80005796:	43c080e7          	jalr	1084(ra) # 80004bce <fileread>
}
    8000579a:	70a2                	ld	ra,40(sp)
    8000579c:	7402                	ld	s0,32(sp)
    8000579e:	6145                	addi	sp,sp,48
    800057a0:	8082                	ret

00000000800057a2 <sys_write>:
{
    800057a2:	7179                	addi	sp,sp,-48
    800057a4:	f406                	sd	ra,40(sp)
    800057a6:	f022                	sd	s0,32(sp)
    800057a8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057aa:	fd840593          	addi	a1,s0,-40
    800057ae:	4505                	li	a0,1
    800057b0:	ffffd097          	auipc	ra,0xffffd
    800057b4:	692080e7          	jalr	1682(ra) # 80002e42 <argaddr>
  argint(2, &n);
    800057b8:	fe440593          	addi	a1,s0,-28
    800057bc:	4509                	li	a0,2
    800057be:	ffffd097          	auipc	ra,0xffffd
    800057c2:	662080e7          	jalr	1634(ra) # 80002e20 <argint>
  if(argfd(0, 0, &f) < 0)
    800057c6:	fe840613          	addi	a2,s0,-24
    800057ca:	4581                	li	a1,0
    800057cc:	4501                	li	a0,0
    800057ce:	00000097          	auipc	ra,0x0
    800057d2:	cfe080e7          	jalr	-770(ra) # 800054cc <argfd>
    800057d6:	87aa                	mv	a5,a0
    return -1;
    800057d8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057da:	0007cc63          	bltz	a5,800057f2 <sys_write+0x50>
  return filewrite(f, p, n);
    800057de:	fe442603          	lw	a2,-28(s0)
    800057e2:	fd843583          	ld	a1,-40(s0)
    800057e6:	fe843503          	ld	a0,-24(s0)
    800057ea:	fffff097          	auipc	ra,0xfffff
    800057ee:	4a6080e7          	jalr	1190(ra) # 80004c90 <filewrite>
}
    800057f2:	70a2                	ld	ra,40(sp)
    800057f4:	7402                	ld	s0,32(sp)
    800057f6:	6145                	addi	sp,sp,48
    800057f8:	8082                	ret

00000000800057fa <sys_close>:
{
    800057fa:	1101                	addi	sp,sp,-32
    800057fc:	ec06                	sd	ra,24(sp)
    800057fe:	e822                	sd	s0,16(sp)
    80005800:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005802:	fe040613          	addi	a2,s0,-32
    80005806:	fec40593          	addi	a1,s0,-20
    8000580a:	4501                	li	a0,0
    8000580c:	00000097          	auipc	ra,0x0
    80005810:	cc0080e7          	jalr	-832(ra) # 800054cc <argfd>
    return -1;
    80005814:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005816:	02054463          	bltz	a0,8000583e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000581a:	ffffc097          	auipc	ra,0xffffc
    8000581e:	1c2080e7          	jalr	450(ra) # 800019dc <myproc>
    80005822:	fec42783          	lw	a5,-20(s0)
    80005826:	07e9                	addi	a5,a5,26
    80005828:	078e                	slli	a5,a5,0x3
    8000582a:	953e                	add	a0,a0,a5
    8000582c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005830:	fe043503          	ld	a0,-32(s0)
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	260080e7          	jalr	608(ra) # 80004a94 <fileclose>
  return 0;
    8000583c:	4781                	li	a5,0
}
    8000583e:	853e                	mv	a0,a5
    80005840:	60e2                	ld	ra,24(sp)
    80005842:	6442                	ld	s0,16(sp)
    80005844:	6105                	addi	sp,sp,32
    80005846:	8082                	ret

0000000080005848 <sys_fstat>:
{
    80005848:	1101                	addi	sp,sp,-32
    8000584a:	ec06                	sd	ra,24(sp)
    8000584c:	e822                	sd	s0,16(sp)
    8000584e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005850:	fe040593          	addi	a1,s0,-32
    80005854:	4505                	li	a0,1
    80005856:	ffffd097          	auipc	ra,0xffffd
    8000585a:	5ec080e7          	jalr	1516(ra) # 80002e42 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000585e:	fe840613          	addi	a2,s0,-24
    80005862:	4581                	li	a1,0
    80005864:	4501                	li	a0,0
    80005866:	00000097          	auipc	ra,0x0
    8000586a:	c66080e7          	jalr	-922(ra) # 800054cc <argfd>
    8000586e:	87aa                	mv	a5,a0
    return -1;
    80005870:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005872:	0007ca63          	bltz	a5,80005886 <sys_fstat+0x3e>
  return filestat(f, st);
    80005876:	fe043583          	ld	a1,-32(s0)
    8000587a:	fe843503          	ld	a0,-24(s0)
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	2de080e7          	jalr	734(ra) # 80004b5c <filestat>
}
    80005886:	60e2                	ld	ra,24(sp)
    80005888:	6442                	ld	s0,16(sp)
    8000588a:	6105                	addi	sp,sp,32
    8000588c:	8082                	ret

000000008000588e <sys_link>:
{
    8000588e:	7169                	addi	sp,sp,-304
    80005890:	f606                	sd	ra,296(sp)
    80005892:	f222                	sd	s0,288(sp)
    80005894:	ee26                	sd	s1,280(sp)
    80005896:	ea4a                	sd	s2,272(sp)
    80005898:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000589a:	08000613          	li	a2,128
    8000589e:	ed040593          	addi	a1,s0,-304
    800058a2:	4501                	li	a0,0
    800058a4:	ffffd097          	auipc	ra,0xffffd
    800058a8:	5c0080e7          	jalr	1472(ra) # 80002e64 <argstr>
    return -1;
    800058ac:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058ae:	10054e63          	bltz	a0,800059ca <sys_link+0x13c>
    800058b2:	08000613          	li	a2,128
    800058b6:	f5040593          	addi	a1,s0,-176
    800058ba:	4505                	li	a0,1
    800058bc:	ffffd097          	auipc	ra,0xffffd
    800058c0:	5a8080e7          	jalr	1448(ra) # 80002e64 <argstr>
    return -1;
    800058c4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058c6:	10054263          	bltz	a0,800059ca <sys_link+0x13c>
  begin_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	d02080e7          	jalr	-766(ra) # 800045cc <begin_op>
  if((ip = namei(old)) == 0){
    800058d2:	ed040513          	addi	a0,s0,-304
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	ad6080e7          	jalr	-1322(ra) # 800043ac <namei>
    800058de:	84aa                	mv	s1,a0
    800058e0:	c551                	beqz	a0,8000596c <sys_link+0xde>
  ilock(ip);
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	31e080e7          	jalr	798(ra) # 80003c00 <ilock>
  if(ip->type == T_DIR){
    800058ea:	04449703          	lh	a4,68(s1)
    800058ee:	4785                	li	a5,1
    800058f0:	08f70463          	beq	a4,a5,80005978 <sys_link+0xea>
  ip->nlink++;
    800058f4:	04a4d783          	lhu	a5,74(s1)
    800058f8:	2785                	addiw	a5,a5,1
    800058fa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058fe:	8526                	mv	a0,s1
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	234080e7          	jalr	564(ra) # 80003b34 <iupdate>
  iunlock(ip);
    80005908:	8526                	mv	a0,s1
    8000590a:	ffffe097          	auipc	ra,0xffffe
    8000590e:	3b8080e7          	jalr	952(ra) # 80003cc2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005912:	fd040593          	addi	a1,s0,-48
    80005916:	f5040513          	addi	a0,s0,-176
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	ab0080e7          	jalr	-1360(ra) # 800043ca <nameiparent>
    80005922:	892a                	mv	s2,a0
    80005924:	c935                	beqz	a0,80005998 <sys_link+0x10a>
  ilock(dp);
    80005926:	ffffe097          	auipc	ra,0xffffe
    8000592a:	2da080e7          	jalr	730(ra) # 80003c00 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000592e:	00092703          	lw	a4,0(s2)
    80005932:	409c                	lw	a5,0(s1)
    80005934:	04f71d63          	bne	a4,a5,8000598e <sys_link+0x100>
    80005938:	40d0                	lw	a2,4(s1)
    8000593a:	fd040593          	addi	a1,s0,-48
    8000593e:	854a                	mv	a0,s2
    80005940:	fffff097          	auipc	ra,0xfffff
    80005944:	9ba080e7          	jalr	-1606(ra) # 800042fa <dirlink>
    80005948:	04054363          	bltz	a0,8000598e <sys_link+0x100>
  iunlockput(dp);
    8000594c:	854a                	mv	a0,s2
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	514080e7          	jalr	1300(ra) # 80003e62 <iunlockput>
  iput(ip);
    80005956:	8526                	mv	a0,s1
    80005958:	ffffe097          	auipc	ra,0xffffe
    8000595c:	462080e7          	jalr	1122(ra) # 80003dba <iput>
  end_op();
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	cea080e7          	jalr	-790(ra) # 8000464a <end_op>
  return 0;
    80005968:	4781                	li	a5,0
    8000596a:	a085                	j	800059ca <sys_link+0x13c>
    end_op();
    8000596c:	fffff097          	auipc	ra,0xfffff
    80005970:	cde080e7          	jalr	-802(ra) # 8000464a <end_op>
    return -1;
    80005974:	57fd                	li	a5,-1
    80005976:	a891                	j	800059ca <sys_link+0x13c>
    iunlockput(ip);
    80005978:	8526                	mv	a0,s1
    8000597a:	ffffe097          	auipc	ra,0xffffe
    8000597e:	4e8080e7          	jalr	1256(ra) # 80003e62 <iunlockput>
    end_op();
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	cc8080e7          	jalr	-824(ra) # 8000464a <end_op>
    return -1;
    8000598a:	57fd                	li	a5,-1
    8000598c:	a83d                	j	800059ca <sys_link+0x13c>
    iunlockput(dp);
    8000598e:	854a                	mv	a0,s2
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	4d2080e7          	jalr	1234(ra) # 80003e62 <iunlockput>
  ilock(ip);
    80005998:	8526                	mv	a0,s1
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	266080e7          	jalr	614(ra) # 80003c00 <ilock>
  ip->nlink--;
    800059a2:	04a4d783          	lhu	a5,74(s1)
    800059a6:	37fd                	addiw	a5,a5,-1
    800059a8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059ac:	8526                	mv	a0,s1
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	186080e7          	jalr	390(ra) # 80003b34 <iupdate>
  iunlockput(ip);
    800059b6:	8526                	mv	a0,s1
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	4aa080e7          	jalr	1194(ra) # 80003e62 <iunlockput>
  end_op();
    800059c0:	fffff097          	auipc	ra,0xfffff
    800059c4:	c8a080e7          	jalr	-886(ra) # 8000464a <end_op>
  return -1;
    800059c8:	57fd                	li	a5,-1
}
    800059ca:	853e                	mv	a0,a5
    800059cc:	70b2                	ld	ra,296(sp)
    800059ce:	7412                	ld	s0,288(sp)
    800059d0:	64f2                	ld	s1,280(sp)
    800059d2:	6952                	ld	s2,272(sp)
    800059d4:	6155                	addi	sp,sp,304
    800059d6:	8082                	ret

00000000800059d8 <sys_unlink>:
{
    800059d8:	7151                	addi	sp,sp,-240
    800059da:	f586                	sd	ra,232(sp)
    800059dc:	f1a2                	sd	s0,224(sp)
    800059de:	eda6                	sd	s1,216(sp)
    800059e0:	e9ca                	sd	s2,208(sp)
    800059e2:	e5ce                	sd	s3,200(sp)
    800059e4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059e6:	08000613          	li	a2,128
    800059ea:	f3040593          	addi	a1,s0,-208
    800059ee:	4501                	li	a0,0
    800059f0:	ffffd097          	auipc	ra,0xffffd
    800059f4:	474080e7          	jalr	1140(ra) # 80002e64 <argstr>
    800059f8:	18054163          	bltz	a0,80005b7a <sys_unlink+0x1a2>
  begin_op();
    800059fc:	fffff097          	auipc	ra,0xfffff
    80005a00:	bd0080e7          	jalr	-1072(ra) # 800045cc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a04:	fb040593          	addi	a1,s0,-80
    80005a08:	f3040513          	addi	a0,s0,-208
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	9be080e7          	jalr	-1602(ra) # 800043ca <nameiparent>
    80005a14:	84aa                	mv	s1,a0
    80005a16:	c979                	beqz	a0,80005aec <sys_unlink+0x114>
  ilock(dp);
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	1e8080e7          	jalr	488(ra) # 80003c00 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a20:	00003597          	auipc	a1,0x3
    80005a24:	d1058593          	addi	a1,a1,-752 # 80008730 <syscalls+0x2e0>
    80005a28:	fb040513          	addi	a0,s0,-80
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	69e080e7          	jalr	1694(ra) # 800040ca <namecmp>
    80005a34:	14050a63          	beqz	a0,80005b88 <sys_unlink+0x1b0>
    80005a38:	00003597          	auipc	a1,0x3
    80005a3c:	d0058593          	addi	a1,a1,-768 # 80008738 <syscalls+0x2e8>
    80005a40:	fb040513          	addi	a0,s0,-80
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	686080e7          	jalr	1670(ra) # 800040ca <namecmp>
    80005a4c:	12050e63          	beqz	a0,80005b88 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a50:	f2c40613          	addi	a2,s0,-212
    80005a54:	fb040593          	addi	a1,s0,-80
    80005a58:	8526                	mv	a0,s1
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	68a080e7          	jalr	1674(ra) # 800040e4 <dirlookup>
    80005a62:	892a                	mv	s2,a0
    80005a64:	12050263          	beqz	a0,80005b88 <sys_unlink+0x1b0>
  ilock(ip);
    80005a68:	ffffe097          	auipc	ra,0xffffe
    80005a6c:	198080e7          	jalr	408(ra) # 80003c00 <ilock>
  if(ip->nlink < 1)
    80005a70:	04a91783          	lh	a5,74(s2)
    80005a74:	08f05263          	blez	a5,80005af8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a78:	04491703          	lh	a4,68(s2)
    80005a7c:	4785                	li	a5,1
    80005a7e:	08f70563          	beq	a4,a5,80005b08 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a82:	4641                	li	a2,16
    80005a84:	4581                	li	a1,0
    80005a86:	fc040513          	addi	a0,s0,-64
    80005a8a:	ffffb097          	auipc	ra,0xffffb
    80005a8e:	248080e7          	jalr	584(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a92:	4741                	li	a4,16
    80005a94:	f2c42683          	lw	a3,-212(s0)
    80005a98:	fc040613          	addi	a2,s0,-64
    80005a9c:	4581                	li	a1,0
    80005a9e:	8526                	mv	a0,s1
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	50c080e7          	jalr	1292(ra) # 80003fac <writei>
    80005aa8:	47c1                	li	a5,16
    80005aaa:	0af51563          	bne	a0,a5,80005b54 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005aae:	04491703          	lh	a4,68(s2)
    80005ab2:	4785                	li	a5,1
    80005ab4:	0af70863          	beq	a4,a5,80005b64 <sys_unlink+0x18c>
  iunlockput(dp);
    80005ab8:	8526                	mv	a0,s1
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	3a8080e7          	jalr	936(ra) # 80003e62 <iunlockput>
  ip->nlink--;
    80005ac2:	04a95783          	lhu	a5,74(s2)
    80005ac6:	37fd                	addiw	a5,a5,-1
    80005ac8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005acc:	854a                	mv	a0,s2
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	066080e7          	jalr	102(ra) # 80003b34 <iupdate>
  iunlockput(ip);
    80005ad6:	854a                	mv	a0,s2
    80005ad8:	ffffe097          	auipc	ra,0xffffe
    80005adc:	38a080e7          	jalr	906(ra) # 80003e62 <iunlockput>
  end_op();
    80005ae0:	fffff097          	auipc	ra,0xfffff
    80005ae4:	b6a080e7          	jalr	-1174(ra) # 8000464a <end_op>
  return 0;
    80005ae8:	4501                	li	a0,0
    80005aea:	a84d                	j	80005b9c <sys_unlink+0x1c4>
    end_op();
    80005aec:	fffff097          	auipc	ra,0xfffff
    80005af0:	b5e080e7          	jalr	-1186(ra) # 8000464a <end_op>
    return -1;
    80005af4:	557d                	li	a0,-1
    80005af6:	a05d                	j	80005b9c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005af8:	00003517          	auipc	a0,0x3
    80005afc:	c4850513          	addi	a0,a0,-952 # 80008740 <syscalls+0x2f0>
    80005b00:	ffffb097          	auipc	ra,0xffffb
    80005b04:	a40080e7          	jalr	-1472(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b08:	04c92703          	lw	a4,76(s2)
    80005b0c:	02000793          	li	a5,32
    80005b10:	f6e7f9e3          	bgeu	a5,a4,80005a82 <sys_unlink+0xaa>
    80005b14:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b18:	4741                	li	a4,16
    80005b1a:	86ce                	mv	a3,s3
    80005b1c:	f1840613          	addi	a2,s0,-232
    80005b20:	4581                	li	a1,0
    80005b22:	854a                	mv	a0,s2
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	390080e7          	jalr	912(ra) # 80003eb4 <readi>
    80005b2c:	47c1                	li	a5,16
    80005b2e:	00f51b63          	bne	a0,a5,80005b44 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b32:	f1845783          	lhu	a5,-232(s0)
    80005b36:	e7a1                	bnez	a5,80005b7e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b38:	29c1                	addiw	s3,s3,16
    80005b3a:	04c92783          	lw	a5,76(s2)
    80005b3e:	fcf9ede3          	bltu	s3,a5,80005b18 <sys_unlink+0x140>
    80005b42:	b781                	j	80005a82 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b44:	00003517          	auipc	a0,0x3
    80005b48:	c1450513          	addi	a0,a0,-1004 # 80008758 <syscalls+0x308>
    80005b4c:	ffffb097          	auipc	ra,0xffffb
    80005b50:	9f4080e7          	jalr	-1548(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005b54:	00003517          	auipc	a0,0x3
    80005b58:	c1c50513          	addi	a0,a0,-996 # 80008770 <syscalls+0x320>
    80005b5c:	ffffb097          	auipc	ra,0xffffb
    80005b60:	9e4080e7          	jalr	-1564(ra) # 80000540 <panic>
    dp->nlink--;
    80005b64:	04a4d783          	lhu	a5,74(s1)
    80005b68:	37fd                	addiw	a5,a5,-1
    80005b6a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b6e:	8526                	mv	a0,s1
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	fc4080e7          	jalr	-60(ra) # 80003b34 <iupdate>
    80005b78:	b781                	j	80005ab8 <sys_unlink+0xe0>
    return -1;
    80005b7a:	557d                	li	a0,-1
    80005b7c:	a005                	j	80005b9c <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b7e:	854a                	mv	a0,s2
    80005b80:	ffffe097          	auipc	ra,0xffffe
    80005b84:	2e2080e7          	jalr	738(ra) # 80003e62 <iunlockput>
  iunlockput(dp);
    80005b88:	8526                	mv	a0,s1
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	2d8080e7          	jalr	728(ra) # 80003e62 <iunlockput>
  end_op();
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	ab8080e7          	jalr	-1352(ra) # 8000464a <end_op>
  return -1;
    80005b9a:	557d                	li	a0,-1
}
    80005b9c:	70ae                	ld	ra,232(sp)
    80005b9e:	740e                	ld	s0,224(sp)
    80005ba0:	64ee                	ld	s1,216(sp)
    80005ba2:	694e                	ld	s2,208(sp)
    80005ba4:	69ae                	ld	s3,200(sp)
    80005ba6:	616d                	addi	sp,sp,240
    80005ba8:	8082                	ret

0000000080005baa <sys_open>:

uint64
sys_open(void)
{
    80005baa:	7131                	addi	sp,sp,-192
    80005bac:	fd06                	sd	ra,184(sp)
    80005bae:	f922                	sd	s0,176(sp)
    80005bb0:	f526                	sd	s1,168(sp)
    80005bb2:	f14a                	sd	s2,160(sp)
    80005bb4:	ed4e                	sd	s3,152(sp)
    80005bb6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005bb8:	f4c40593          	addi	a1,s0,-180
    80005bbc:	4505                	li	a0,1
    80005bbe:	ffffd097          	auipc	ra,0xffffd
    80005bc2:	262080e7          	jalr	610(ra) # 80002e20 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bc6:	08000613          	li	a2,128
    80005bca:	f5040593          	addi	a1,s0,-176
    80005bce:	4501                	li	a0,0
    80005bd0:	ffffd097          	auipc	ra,0xffffd
    80005bd4:	294080e7          	jalr	660(ra) # 80002e64 <argstr>
    80005bd8:	87aa                	mv	a5,a0
    return -1;
    80005bda:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bdc:	0a07c963          	bltz	a5,80005c8e <sys_open+0xe4>

  begin_op();
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	9ec080e7          	jalr	-1556(ra) # 800045cc <begin_op>

  if(omode & O_CREATE){
    80005be8:	f4c42783          	lw	a5,-180(s0)
    80005bec:	2007f793          	andi	a5,a5,512
    80005bf0:	cfc5                	beqz	a5,80005ca8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005bf2:	4681                	li	a3,0
    80005bf4:	4601                	li	a2,0
    80005bf6:	4589                	li	a1,2
    80005bf8:	f5040513          	addi	a0,s0,-176
    80005bfc:	00000097          	auipc	ra,0x0
    80005c00:	972080e7          	jalr	-1678(ra) # 8000556e <create>
    80005c04:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c06:	c959                	beqz	a0,80005c9c <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c08:	04449703          	lh	a4,68(s1)
    80005c0c:	478d                	li	a5,3
    80005c0e:	00f71763          	bne	a4,a5,80005c1c <sys_open+0x72>
    80005c12:	0464d703          	lhu	a4,70(s1)
    80005c16:	47a5                	li	a5,9
    80005c18:	0ce7ed63          	bltu	a5,a4,80005cf2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c1c:	fffff097          	auipc	ra,0xfffff
    80005c20:	dbc080e7          	jalr	-580(ra) # 800049d8 <filealloc>
    80005c24:	89aa                	mv	s3,a0
    80005c26:	10050363          	beqz	a0,80005d2c <sys_open+0x182>
    80005c2a:	00000097          	auipc	ra,0x0
    80005c2e:	902080e7          	jalr	-1790(ra) # 8000552c <fdalloc>
    80005c32:	892a                	mv	s2,a0
    80005c34:	0e054763          	bltz	a0,80005d22 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c38:	04449703          	lh	a4,68(s1)
    80005c3c:	478d                	li	a5,3
    80005c3e:	0cf70563          	beq	a4,a5,80005d08 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c42:	4789                	li	a5,2
    80005c44:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c48:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c4c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c50:	f4c42783          	lw	a5,-180(s0)
    80005c54:	0017c713          	xori	a4,a5,1
    80005c58:	8b05                	andi	a4,a4,1
    80005c5a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c5e:	0037f713          	andi	a4,a5,3
    80005c62:	00e03733          	snez	a4,a4
    80005c66:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c6a:	4007f793          	andi	a5,a5,1024
    80005c6e:	c791                	beqz	a5,80005c7a <sys_open+0xd0>
    80005c70:	04449703          	lh	a4,68(s1)
    80005c74:	4789                	li	a5,2
    80005c76:	0af70063          	beq	a4,a5,80005d16 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c7a:	8526                	mv	a0,s1
    80005c7c:	ffffe097          	auipc	ra,0xffffe
    80005c80:	046080e7          	jalr	70(ra) # 80003cc2 <iunlock>
  end_op();
    80005c84:	fffff097          	auipc	ra,0xfffff
    80005c88:	9c6080e7          	jalr	-1594(ra) # 8000464a <end_op>

  return fd;
    80005c8c:	854a                	mv	a0,s2
}
    80005c8e:	70ea                	ld	ra,184(sp)
    80005c90:	744a                	ld	s0,176(sp)
    80005c92:	74aa                	ld	s1,168(sp)
    80005c94:	790a                	ld	s2,160(sp)
    80005c96:	69ea                	ld	s3,152(sp)
    80005c98:	6129                	addi	sp,sp,192
    80005c9a:	8082                	ret
      end_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	9ae080e7          	jalr	-1618(ra) # 8000464a <end_op>
      return -1;
    80005ca4:	557d                	li	a0,-1
    80005ca6:	b7e5                	j	80005c8e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005ca8:	f5040513          	addi	a0,s0,-176
    80005cac:	ffffe097          	auipc	ra,0xffffe
    80005cb0:	700080e7          	jalr	1792(ra) # 800043ac <namei>
    80005cb4:	84aa                	mv	s1,a0
    80005cb6:	c905                	beqz	a0,80005ce6 <sys_open+0x13c>
    ilock(ip);
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	f48080e7          	jalr	-184(ra) # 80003c00 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cc0:	04449703          	lh	a4,68(s1)
    80005cc4:	4785                	li	a5,1
    80005cc6:	f4f711e3          	bne	a4,a5,80005c08 <sys_open+0x5e>
    80005cca:	f4c42783          	lw	a5,-180(s0)
    80005cce:	d7b9                	beqz	a5,80005c1c <sys_open+0x72>
      iunlockput(ip);
    80005cd0:	8526                	mv	a0,s1
    80005cd2:	ffffe097          	auipc	ra,0xffffe
    80005cd6:	190080e7          	jalr	400(ra) # 80003e62 <iunlockput>
      end_op();
    80005cda:	fffff097          	auipc	ra,0xfffff
    80005cde:	970080e7          	jalr	-1680(ra) # 8000464a <end_op>
      return -1;
    80005ce2:	557d                	li	a0,-1
    80005ce4:	b76d                	j	80005c8e <sys_open+0xe4>
      end_op();
    80005ce6:	fffff097          	auipc	ra,0xfffff
    80005cea:	964080e7          	jalr	-1692(ra) # 8000464a <end_op>
      return -1;
    80005cee:	557d                	li	a0,-1
    80005cf0:	bf79                	j	80005c8e <sys_open+0xe4>
    iunlockput(ip);
    80005cf2:	8526                	mv	a0,s1
    80005cf4:	ffffe097          	auipc	ra,0xffffe
    80005cf8:	16e080e7          	jalr	366(ra) # 80003e62 <iunlockput>
    end_op();
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	94e080e7          	jalr	-1714(ra) # 8000464a <end_op>
    return -1;
    80005d04:	557d                	li	a0,-1
    80005d06:	b761                	j	80005c8e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d08:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d0c:	04649783          	lh	a5,70(s1)
    80005d10:	02f99223          	sh	a5,36(s3)
    80005d14:	bf25                	j	80005c4c <sys_open+0xa2>
    itrunc(ip);
    80005d16:	8526                	mv	a0,s1
    80005d18:	ffffe097          	auipc	ra,0xffffe
    80005d1c:	ff6080e7          	jalr	-10(ra) # 80003d0e <itrunc>
    80005d20:	bfa9                	j	80005c7a <sys_open+0xd0>
      fileclose(f);
    80005d22:	854e                	mv	a0,s3
    80005d24:	fffff097          	auipc	ra,0xfffff
    80005d28:	d70080e7          	jalr	-656(ra) # 80004a94 <fileclose>
    iunlockput(ip);
    80005d2c:	8526                	mv	a0,s1
    80005d2e:	ffffe097          	auipc	ra,0xffffe
    80005d32:	134080e7          	jalr	308(ra) # 80003e62 <iunlockput>
    end_op();
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	914080e7          	jalr	-1772(ra) # 8000464a <end_op>
    return -1;
    80005d3e:	557d                	li	a0,-1
    80005d40:	b7b9                	j	80005c8e <sys_open+0xe4>

0000000080005d42 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d42:	7175                	addi	sp,sp,-144
    80005d44:	e506                	sd	ra,136(sp)
    80005d46:	e122                	sd	s0,128(sp)
    80005d48:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d4a:	fffff097          	auipc	ra,0xfffff
    80005d4e:	882080e7          	jalr	-1918(ra) # 800045cc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d52:	08000613          	li	a2,128
    80005d56:	f7040593          	addi	a1,s0,-144
    80005d5a:	4501                	li	a0,0
    80005d5c:	ffffd097          	auipc	ra,0xffffd
    80005d60:	108080e7          	jalr	264(ra) # 80002e64 <argstr>
    80005d64:	02054963          	bltz	a0,80005d96 <sys_mkdir+0x54>
    80005d68:	4681                	li	a3,0
    80005d6a:	4601                	li	a2,0
    80005d6c:	4585                	li	a1,1
    80005d6e:	f7040513          	addi	a0,s0,-144
    80005d72:	fffff097          	auipc	ra,0xfffff
    80005d76:	7fc080e7          	jalr	2044(ra) # 8000556e <create>
    80005d7a:	cd11                	beqz	a0,80005d96 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d7c:	ffffe097          	auipc	ra,0xffffe
    80005d80:	0e6080e7          	jalr	230(ra) # 80003e62 <iunlockput>
  end_op();
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	8c6080e7          	jalr	-1850(ra) # 8000464a <end_op>
  return 0;
    80005d8c:	4501                	li	a0,0
}
    80005d8e:	60aa                	ld	ra,136(sp)
    80005d90:	640a                	ld	s0,128(sp)
    80005d92:	6149                	addi	sp,sp,144
    80005d94:	8082                	ret
    end_op();
    80005d96:	fffff097          	auipc	ra,0xfffff
    80005d9a:	8b4080e7          	jalr	-1868(ra) # 8000464a <end_op>
    return -1;
    80005d9e:	557d                	li	a0,-1
    80005da0:	b7fd                	j	80005d8e <sys_mkdir+0x4c>

0000000080005da2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005da2:	7135                	addi	sp,sp,-160
    80005da4:	ed06                	sd	ra,152(sp)
    80005da6:	e922                	sd	s0,144(sp)
    80005da8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005daa:	fffff097          	auipc	ra,0xfffff
    80005dae:	822080e7          	jalr	-2014(ra) # 800045cc <begin_op>
  argint(1, &major);
    80005db2:	f6c40593          	addi	a1,s0,-148
    80005db6:	4505                	li	a0,1
    80005db8:	ffffd097          	auipc	ra,0xffffd
    80005dbc:	068080e7          	jalr	104(ra) # 80002e20 <argint>
  argint(2, &minor);
    80005dc0:	f6840593          	addi	a1,s0,-152
    80005dc4:	4509                	li	a0,2
    80005dc6:	ffffd097          	auipc	ra,0xffffd
    80005dca:	05a080e7          	jalr	90(ra) # 80002e20 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dce:	08000613          	li	a2,128
    80005dd2:	f7040593          	addi	a1,s0,-144
    80005dd6:	4501                	li	a0,0
    80005dd8:	ffffd097          	auipc	ra,0xffffd
    80005ddc:	08c080e7          	jalr	140(ra) # 80002e64 <argstr>
    80005de0:	02054b63          	bltz	a0,80005e16 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005de4:	f6841683          	lh	a3,-152(s0)
    80005de8:	f6c41603          	lh	a2,-148(s0)
    80005dec:	458d                	li	a1,3
    80005dee:	f7040513          	addi	a0,s0,-144
    80005df2:	fffff097          	auipc	ra,0xfffff
    80005df6:	77c080e7          	jalr	1916(ra) # 8000556e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dfa:	cd11                	beqz	a0,80005e16 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dfc:	ffffe097          	auipc	ra,0xffffe
    80005e00:	066080e7          	jalr	102(ra) # 80003e62 <iunlockput>
  end_op();
    80005e04:	fffff097          	auipc	ra,0xfffff
    80005e08:	846080e7          	jalr	-1978(ra) # 8000464a <end_op>
  return 0;
    80005e0c:	4501                	li	a0,0
}
    80005e0e:	60ea                	ld	ra,152(sp)
    80005e10:	644a                	ld	s0,144(sp)
    80005e12:	610d                	addi	sp,sp,160
    80005e14:	8082                	ret
    end_op();
    80005e16:	fffff097          	auipc	ra,0xfffff
    80005e1a:	834080e7          	jalr	-1996(ra) # 8000464a <end_op>
    return -1;
    80005e1e:	557d                	li	a0,-1
    80005e20:	b7fd                	j	80005e0e <sys_mknod+0x6c>

0000000080005e22 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e22:	7135                	addi	sp,sp,-160
    80005e24:	ed06                	sd	ra,152(sp)
    80005e26:	e922                	sd	s0,144(sp)
    80005e28:	e526                	sd	s1,136(sp)
    80005e2a:	e14a                	sd	s2,128(sp)
    80005e2c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e2e:	ffffc097          	auipc	ra,0xffffc
    80005e32:	bae080e7          	jalr	-1106(ra) # 800019dc <myproc>
    80005e36:	892a                	mv	s2,a0
  
  begin_op();
    80005e38:	ffffe097          	auipc	ra,0xffffe
    80005e3c:	794080e7          	jalr	1940(ra) # 800045cc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e40:	08000613          	li	a2,128
    80005e44:	f6040593          	addi	a1,s0,-160
    80005e48:	4501                	li	a0,0
    80005e4a:	ffffd097          	auipc	ra,0xffffd
    80005e4e:	01a080e7          	jalr	26(ra) # 80002e64 <argstr>
    80005e52:	04054b63          	bltz	a0,80005ea8 <sys_chdir+0x86>
    80005e56:	f6040513          	addi	a0,s0,-160
    80005e5a:	ffffe097          	auipc	ra,0xffffe
    80005e5e:	552080e7          	jalr	1362(ra) # 800043ac <namei>
    80005e62:	84aa                	mv	s1,a0
    80005e64:	c131                	beqz	a0,80005ea8 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e66:	ffffe097          	auipc	ra,0xffffe
    80005e6a:	d9a080e7          	jalr	-614(ra) # 80003c00 <ilock>
  if(ip->type != T_DIR){
    80005e6e:	04449703          	lh	a4,68(s1)
    80005e72:	4785                	li	a5,1
    80005e74:	04f71063          	bne	a4,a5,80005eb4 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e78:	8526                	mv	a0,s1
    80005e7a:	ffffe097          	auipc	ra,0xffffe
    80005e7e:	e48080e7          	jalr	-440(ra) # 80003cc2 <iunlock>
  iput(p->cwd);
    80005e82:	15093503          	ld	a0,336(s2)
    80005e86:	ffffe097          	auipc	ra,0xffffe
    80005e8a:	f34080e7          	jalr	-204(ra) # 80003dba <iput>
  end_op();
    80005e8e:	ffffe097          	auipc	ra,0xffffe
    80005e92:	7bc080e7          	jalr	1980(ra) # 8000464a <end_op>
  p->cwd = ip;
    80005e96:	14993823          	sd	s1,336(s2)
  return 0;
    80005e9a:	4501                	li	a0,0
}
    80005e9c:	60ea                	ld	ra,152(sp)
    80005e9e:	644a                	ld	s0,144(sp)
    80005ea0:	64aa                	ld	s1,136(sp)
    80005ea2:	690a                	ld	s2,128(sp)
    80005ea4:	610d                	addi	sp,sp,160
    80005ea6:	8082                	ret
    end_op();
    80005ea8:	ffffe097          	auipc	ra,0xffffe
    80005eac:	7a2080e7          	jalr	1954(ra) # 8000464a <end_op>
    return -1;
    80005eb0:	557d                	li	a0,-1
    80005eb2:	b7ed                	j	80005e9c <sys_chdir+0x7a>
    iunlockput(ip);
    80005eb4:	8526                	mv	a0,s1
    80005eb6:	ffffe097          	auipc	ra,0xffffe
    80005eba:	fac080e7          	jalr	-84(ra) # 80003e62 <iunlockput>
    end_op();
    80005ebe:	ffffe097          	auipc	ra,0xffffe
    80005ec2:	78c080e7          	jalr	1932(ra) # 8000464a <end_op>
    return -1;
    80005ec6:	557d                	li	a0,-1
    80005ec8:	bfd1                	j	80005e9c <sys_chdir+0x7a>

0000000080005eca <sys_exec>:

uint64
sys_exec(void)
{
    80005eca:	7145                	addi	sp,sp,-464
    80005ecc:	e786                	sd	ra,456(sp)
    80005ece:	e3a2                	sd	s0,448(sp)
    80005ed0:	ff26                	sd	s1,440(sp)
    80005ed2:	fb4a                	sd	s2,432(sp)
    80005ed4:	f74e                	sd	s3,424(sp)
    80005ed6:	f352                	sd	s4,416(sp)
    80005ed8:	ef56                	sd	s5,408(sp)
    80005eda:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005edc:	e3840593          	addi	a1,s0,-456
    80005ee0:	4505                	li	a0,1
    80005ee2:	ffffd097          	auipc	ra,0xffffd
    80005ee6:	f60080e7          	jalr	-160(ra) # 80002e42 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005eea:	08000613          	li	a2,128
    80005eee:	f4040593          	addi	a1,s0,-192
    80005ef2:	4501                	li	a0,0
    80005ef4:	ffffd097          	auipc	ra,0xffffd
    80005ef8:	f70080e7          	jalr	-144(ra) # 80002e64 <argstr>
    80005efc:	87aa                	mv	a5,a0
    return -1;
    80005efe:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005f00:	0c07c363          	bltz	a5,80005fc6 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005f04:	10000613          	li	a2,256
    80005f08:	4581                	li	a1,0
    80005f0a:	e4040513          	addi	a0,s0,-448
    80005f0e:	ffffb097          	auipc	ra,0xffffb
    80005f12:	dc4080e7          	jalr	-572(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f16:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f1a:	89a6                	mv	s3,s1
    80005f1c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f1e:	02000a13          	li	s4,32
    80005f22:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f26:	00391513          	slli	a0,s2,0x3
    80005f2a:	e3040593          	addi	a1,s0,-464
    80005f2e:	e3843783          	ld	a5,-456(s0)
    80005f32:	953e                	add	a0,a0,a5
    80005f34:	ffffd097          	auipc	ra,0xffffd
    80005f38:	e4e080e7          	jalr	-434(ra) # 80002d82 <fetchaddr>
    80005f3c:	02054a63          	bltz	a0,80005f70 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f40:	e3043783          	ld	a5,-464(s0)
    80005f44:	c3b9                	beqz	a5,80005f8a <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f46:	ffffb097          	auipc	ra,0xffffb
    80005f4a:	ba0080e7          	jalr	-1120(ra) # 80000ae6 <kalloc>
    80005f4e:	85aa                	mv	a1,a0
    80005f50:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f54:	cd11                	beqz	a0,80005f70 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f56:	6605                	lui	a2,0x1
    80005f58:	e3043503          	ld	a0,-464(s0)
    80005f5c:	ffffd097          	auipc	ra,0xffffd
    80005f60:	e78080e7          	jalr	-392(ra) # 80002dd4 <fetchstr>
    80005f64:	00054663          	bltz	a0,80005f70 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f68:	0905                	addi	s2,s2,1
    80005f6a:	09a1                	addi	s3,s3,8
    80005f6c:	fb491be3          	bne	s2,s4,80005f22 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f70:	f4040913          	addi	s2,s0,-192
    80005f74:	6088                	ld	a0,0(s1)
    80005f76:	c539                	beqz	a0,80005fc4 <sys_exec+0xfa>
    kfree(argv[i]);
    80005f78:	ffffb097          	auipc	ra,0xffffb
    80005f7c:	a70080e7          	jalr	-1424(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f80:	04a1                	addi	s1,s1,8
    80005f82:	ff2499e3          	bne	s1,s2,80005f74 <sys_exec+0xaa>
  return -1;
    80005f86:	557d                	li	a0,-1
    80005f88:	a83d                	j	80005fc6 <sys_exec+0xfc>
      argv[i] = 0;
    80005f8a:	0a8e                	slli	s5,s5,0x3
    80005f8c:	fc0a8793          	addi	a5,s5,-64
    80005f90:	00878ab3          	add	s5,a5,s0
    80005f94:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f98:	e4040593          	addi	a1,s0,-448
    80005f9c:	f4040513          	addi	a0,s0,-192
    80005fa0:	fffff097          	auipc	ra,0xfffff
    80005fa4:	16e080e7          	jalr	366(ra) # 8000510e <exec>
    80005fa8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005faa:	f4040993          	addi	s3,s0,-192
    80005fae:	6088                	ld	a0,0(s1)
    80005fb0:	c901                	beqz	a0,80005fc0 <sys_exec+0xf6>
    kfree(argv[i]);
    80005fb2:	ffffb097          	auipc	ra,0xffffb
    80005fb6:	a36080e7          	jalr	-1482(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fba:	04a1                	addi	s1,s1,8
    80005fbc:	ff3499e3          	bne	s1,s3,80005fae <sys_exec+0xe4>
  return ret;
    80005fc0:	854a                	mv	a0,s2
    80005fc2:	a011                	j	80005fc6 <sys_exec+0xfc>
  return -1;
    80005fc4:	557d                	li	a0,-1
}
    80005fc6:	60be                	ld	ra,456(sp)
    80005fc8:	641e                	ld	s0,448(sp)
    80005fca:	74fa                	ld	s1,440(sp)
    80005fcc:	795a                	ld	s2,432(sp)
    80005fce:	79ba                	ld	s3,424(sp)
    80005fd0:	7a1a                	ld	s4,416(sp)
    80005fd2:	6afa                	ld	s5,408(sp)
    80005fd4:	6179                	addi	sp,sp,464
    80005fd6:	8082                	ret

0000000080005fd8 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005fd8:	7139                	addi	sp,sp,-64
    80005fda:	fc06                	sd	ra,56(sp)
    80005fdc:	f822                	sd	s0,48(sp)
    80005fde:	f426                	sd	s1,40(sp)
    80005fe0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005fe2:	ffffc097          	auipc	ra,0xffffc
    80005fe6:	9fa080e7          	jalr	-1542(ra) # 800019dc <myproc>
    80005fea:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005fec:	fd840593          	addi	a1,s0,-40
    80005ff0:	4501                	li	a0,0
    80005ff2:	ffffd097          	auipc	ra,0xffffd
    80005ff6:	e50080e7          	jalr	-432(ra) # 80002e42 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ffa:	fc840593          	addi	a1,s0,-56
    80005ffe:	fd040513          	addi	a0,s0,-48
    80006002:	fffff097          	auipc	ra,0xfffff
    80006006:	dc2080e7          	jalr	-574(ra) # 80004dc4 <pipealloc>
    return -1;
    8000600a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000600c:	0c054463          	bltz	a0,800060d4 <sys_pipe+0xfc>
  fd0 = -1;
    80006010:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006014:	fd043503          	ld	a0,-48(s0)
    80006018:	fffff097          	auipc	ra,0xfffff
    8000601c:	514080e7          	jalr	1300(ra) # 8000552c <fdalloc>
    80006020:	fca42223          	sw	a0,-60(s0)
    80006024:	08054b63          	bltz	a0,800060ba <sys_pipe+0xe2>
    80006028:	fc843503          	ld	a0,-56(s0)
    8000602c:	fffff097          	auipc	ra,0xfffff
    80006030:	500080e7          	jalr	1280(ra) # 8000552c <fdalloc>
    80006034:	fca42023          	sw	a0,-64(s0)
    80006038:	06054863          	bltz	a0,800060a8 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000603c:	4691                	li	a3,4
    8000603e:	fc440613          	addi	a2,s0,-60
    80006042:	fd843583          	ld	a1,-40(s0)
    80006046:	68a8                	ld	a0,80(s1)
    80006048:	ffffb097          	auipc	ra,0xffffb
    8000604c:	624080e7          	jalr	1572(ra) # 8000166c <copyout>
    80006050:	02054063          	bltz	a0,80006070 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006054:	4691                	li	a3,4
    80006056:	fc040613          	addi	a2,s0,-64
    8000605a:	fd843583          	ld	a1,-40(s0)
    8000605e:	0591                	addi	a1,a1,4
    80006060:	68a8                	ld	a0,80(s1)
    80006062:	ffffb097          	auipc	ra,0xffffb
    80006066:	60a080e7          	jalr	1546(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000606a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000606c:	06055463          	bgez	a0,800060d4 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006070:	fc442783          	lw	a5,-60(s0)
    80006074:	07e9                	addi	a5,a5,26
    80006076:	078e                	slli	a5,a5,0x3
    80006078:	97a6                	add	a5,a5,s1
    8000607a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000607e:	fc042783          	lw	a5,-64(s0)
    80006082:	07e9                	addi	a5,a5,26
    80006084:	078e                	slli	a5,a5,0x3
    80006086:	94be                	add	s1,s1,a5
    80006088:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000608c:	fd043503          	ld	a0,-48(s0)
    80006090:	fffff097          	auipc	ra,0xfffff
    80006094:	a04080e7          	jalr	-1532(ra) # 80004a94 <fileclose>
    fileclose(wf);
    80006098:	fc843503          	ld	a0,-56(s0)
    8000609c:	fffff097          	auipc	ra,0xfffff
    800060a0:	9f8080e7          	jalr	-1544(ra) # 80004a94 <fileclose>
    return -1;
    800060a4:	57fd                	li	a5,-1
    800060a6:	a03d                	j	800060d4 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800060a8:	fc442783          	lw	a5,-60(s0)
    800060ac:	0007c763          	bltz	a5,800060ba <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800060b0:	07e9                	addi	a5,a5,26
    800060b2:	078e                	slli	a5,a5,0x3
    800060b4:	97a6                	add	a5,a5,s1
    800060b6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800060ba:	fd043503          	ld	a0,-48(s0)
    800060be:	fffff097          	auipc	ra,0xfffff
    800060c2:	9d6080e7          	jalr	-1578(ra) # 80004a94 <fileclose>
    fileclose(wf);
    800060c6:	fc843503          	ld	a0,-56(s0)
    800060ca:	fffff097          	auipc	ra,0xfffff
    800060ce:	9ca080e7          	jalr	-1590(ra) # 80004a94 <fileclose>
    return -1;
    800060d2:	57fd                	li	a5,-1
}
    800060d4:	853e                	mv	a0,a5
    800060d6:	70e2                	ld	ra,56(sp)
    800060d8:	7442                	ld	s0,48(sp)
    800060da:	74a2                	ld	s1,40(sp)
    800060dc:	6121                	addi	sp,sp,64
    800060de:	8082                	ret

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
    80006120:	b2ffc0ef          	jal	ra,80002c4e <kerneltrap>
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
    800061bc:	7f8080e7          	jalr	2040(ra) # 800019b0 <cpuid>
  
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
    800061da:	97aa                	add	a5,a5,a0
    800061dc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
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
    800061f4:	7c0080e7          	jalr	1984(ra) # 800019b0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800061f8:	00d5151b          	slliw	a0,a0,0xd
    800061fc:	0c2017b7          	lui	a5,0xc201
    80006200:	97aa                	add	a5,a5,a0
  return irq;
}
    80006202:	43c8                	lw	a0,4(a5)
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
    8000621c:	798080e7          	jalr	1944(ra) # 800019b0 <cpuid>
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
    80006244:	00023797          	auipc	a5,0x23
    80006248:	29c78793          	addi	a5,a5,668 # 800294e0 <disk>
    8000624c:	97aa                	add	a5,a5,a0
    8000624e:	0187c783          	lbu	a5,24(a5)
    80006252:	ebb9                	bnez	a5,800062a8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006254:	00451693          	slli	a3,a0,0x4
    80006258:	00023797          	auipc	a5,0x23
    8000625c:	28878793          	addi	a5,a5,648 # 800294e0 <disk>
    80006260:	6398                	ld	a4,0(a5)
    80006262:	9736                	add	a4,a4,a3
    80006264:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006268:	6398                	ld	a4,0(a5)
    8000626a:	9736                	add	a4,a4,a3
    8000626c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006270:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006274:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006278:	97aa                	add	a5,a5,a0
    8000627a:	4705                	li	a4,1
    8000627c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006280:	00023517          	auipc	a0,0x23
    80006284:	27850513          	addi	a0,a0,632 # 800294f8 <disk+0x18>
    80006288:	ffffc097          	auipc	ra,0xffffc
    8000628c:	f84080e7          	jalr	-124(ra) # 8000220c <wakeup>
}
    80006290:	60a2                	ld	ra,8(sp)
    80006292:	6402                	ld	s0,0(sp)
    80006294:	0141                	addi	sp,sp,16
    80006296:	8082                	ret
    panic("free_desc 1");
    80006298:	00002517          	auipc	a0,0x2
    8000629c:	4e850513          	addi	a0,a0,1256 # 80008780 <syscalls+0x330>
    800062a0:	ffffa097          	auipc	ra,0xffffa
    800062a4:	2a0080e7          	jalr	672(ra) # 80000540 <panic>
    panic("free_desc 2");
    800062a8:	00002517          	auipc	a0,0x2
    800062ac:	4e850513          	addi	a0,a0,1256 # 80008790 <syscalls+0x340>
    800062b0:	ffffa097          	auipc	ra,0xffffa
    800062b4:	290080e7          	jalr	656(ra) # 80000540 <panic>

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
    800062c8:	4dc58593          	addi	a1,a1,1244 # 800087a0 <syscalls+0x350>
    800062cc:	00023517          	auipc	a0,0x23
    800062d0:	33c50513          	addi	a0,a0,828 # 80029608 <disk+0x128>
    800062d4:	ffffb097          	auipc	ra,0xffffb
    800062d8:	872080e7          	jalr	-1934(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062dc:	100017b7          	lui	a5,0x10001
    800062e0:	4398                	lw	a4,0(a5)
    800062e2:	2701                	sext.w	a4,a4
    800062e4:	747277b7          	lui	a5,0x74727
    800062e8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800062ec:	14f71b63          	bne	a4,a5,80006442 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062f0:	100017b7          	lui	a5,0x10001
    800062f4:	43dc                	lw	a5,4(a5)
    800062f6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062f8:	4709                	li	a4,2
    800062fa:	14e79463          	bne	a5,a4,80006442 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062fe:	100017b7          	lui	a5,0x10001
    80006302:	479c                	lw	a5,8(a5)
    80006304:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006306:	12e79e63          	bne	a5,a4,80006442 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000630a:	100017b7          	lui	a5,0x10001
    8000630e:	47d8                	lw	a4,12(a5)
    80006310:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006312:	554d47b7          	lui	a5,0x554d4
    80006316:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000631a:	12f71463          	bne	a4,a5,80006442 <virtio_disk_init+0x18a>
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
    8000632e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006330:	c7ffe6b7          	lui	a3,0xc7ffe
    80006334:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd513f>
    80006338:	8f75                	and	a4,a4,a3
    8000633a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000633c:	472d                	li	a4,11
    8000633e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006340:	5bbc                	lw	a5,112(a5)
    80006342:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006346:	8ba1                	andi	a5,a5,8
    80006348:	10078563          	beqz	a5,80006452 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000634c:	100017b7          	lui	a5,0x10001
    80006350:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006354:	43fc                	lw	a5,68(a5)
    80006356:	2781                	sext.w	a5,a5
    80006358:	10079563          	bnez	a5,80006462 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000635c:	100017b7          	lui	a5,0x10001
    80006360:	5bdc                	lw	a5,52(a5)
    80006362:	2781                	sext.w	a5,a5
  if(max == 0)
    80006364:	10078763          	beqz	a5,80006472 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006368:	471d                	li	a4,7
    8000636a:	10f77c63          	bgeu	a4,a5,80006482 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000636e:	ffffa097          	auipc	ra,0xffffa
    80006372:	778080e7          	jalr	1912(ra) # 80000ae6 <kalloc>
    80006376:	00023497          	auipc	s1,0x23
    8000637a:	16a48493          	addi	s1,s1,362 # 800294e0 <disk>
    8000637e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006380:	ffffa097          	auipc	ra,0xffffa
    80006384:	766080e7          	jalr	1894(ra) # 80000ae6 <kalloc>
    80006388:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000638a:	ffffa097          	auipc	ra,0xffffa
    8000638e:	75c080e7          	jalr	1884(ra) # 80000ae6 <kalloc>
    80006392:	87aa                	mv	a5,a0
    80006394:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006396:	6088                	ld	a0,0(s1)
    80006398:	cd6d                	beqz	a0,80006492 <virtio_disk_init+0x1da>
    8000639a:	00023717          	auipc	a4,0x23
    8000639e:	14e73703          	ld	a4,334(a4) # 800294e8 <disk+0x8>
    800063a2:	cb65                	beqz	a4,80006492 <virtio_disk_init+0x1da>
    800063a4:	c7fd                	beqz	a5,80006492 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800063a6:	6605                	lui	a2,0x1
    800063a8:	4581                	li	a1,0
    800063aa:	ffffb097          	auipc	ra,0xffffb
    800063ae:	928080e7          	jalr	-1752(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800063b2:	00023497          	auipc	s1,0x23
    800063b6:	12e48493          	addi	s1,s1,302 # 800294e0 <disk>
    800063ba:	6605                	lui	a2,0x1
    800063bc:	4581                	li	a1,0
    800063be:	6488                	ld	a0,8(s1)
    800063c0:	ffffb097          	auipc	ra,0xffffb
    800063c4:	912080e7          	jalr	-1774(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800063c8:	6605                	lui	a2,0x1
    800063ca:	4581                	li	a1,0
    800063cc:	6888                	ld	a0,16(s1)
    800063ce:	ffffb097          	auipc	ra,0xffffb
    800063d2:	904080e7          	jalr	-1788(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063d6:	100017b7          	lui	a5,0x10001
    800063da:	4721                	li	a4,8
    800063dc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800063de:	4098                	lw	a4,0(s1)
    800063e0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800063e4:	40d8                	lw	a4,4(s1)
    800063e6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800063ea:	6498                	ld	a4,8(s1)
    800063ec:	0007069b          	sext.w	a3,a4
    800063f0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800063f4:	9701                	srai	a4,a4,0x20
    800063f6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800063fa:	6898                	ld	a4,16(s1)
    800063fc:	0007069b          	sext.w	a3,a4
    80006400:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006404:	9701                	srai	a4,a4,0x20
    80006406:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000640a:	4705                	li	a4,1
    8000640c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000640e:	00e48c23          	sb	a4,24(s1)
    80006412:	00e48ca3          	sb	a4,25(s1)
    80006416:	00e48d23          	sb	a4,26(s1)
    8000641a:	00e48da3          	sb	a4,27(s1)
    8000641e:	00e48e23          	sb	a4,28(s1)
    80006422:	00e48ea3          	sb	a4,29(s1)
    80006426:	00e48f23          	sb	a4,30(s1)
    8000642a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000642e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006432:	0727a823          	sw	s2,112(a5)
}
    80006436:	60e2                	ld	ra,24(sp)
    80006438:	6442                	ld	s0,16(sp)
    8000643a:	64a2                	ld	s1,8(sp)
    8000643c:	6902                	ld	s2,0(sp)
    8000643e:	6105                	addi	sp,sp,32
    80006440:	8082                	ret
    panic("could not find virtio disk");
    80006442:	00002517          	auipc	a0,0x2
    80006446:	36e50513          	addi	a0,a0,878 # 800087b0 <syscalls+0x360>
    8000644a:	ffffa097          	auipc	ra,0xffffa
    8000644e:	0f6080e7          	jalr	246(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006452:	00002517          	auipc	a0,0x2
    80006456:	37e50513          	addi	a0,a0,894 # 800087d0 <syscalls+0x380>
    8000645a:	ffffa097          	auipc	ra,0xffffa
    8000645e:	0e6080e7          	jalr	230(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006462:	00002517          	auipc	a0,0x2
    80006466:	38e50513          	addi	a0,a0,910 # 800087f0 <syscalls+0x3a0>
    8000646a:	ffffa097          	auipc	ra,0xffffa
    8000646e:	0d6080e7          	jalr	214(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006472:	00002517          	auipc	a0,0x2
    80006476:	39e50513          	addi	a0,a0,926 # 80008810 <syscalls+0x3c0>
    8000647a:	ffffa097          	auipc	ra,0xffffa
    8000647e:	0c6080e7          	jalr	198(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006482:	00002517          	auipc	a0,0x2
    80006486:	3ae50513          	addi	a0,a0,942 # 80008830 <syscalls+0x3e0>
    8000648a:	ffffa097          	auipc	ra,0xffffa
    8000648e:	0b6080e7          	jalr	182(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006492:	00002517          	auipc	a0,0x2
    80006496:	3be50513          	addi	a0,a0,958 # 80008850 <syscalls+0x400>
    8000649a:	ffffa097          	auipc	ra,0xffffa
    8000649e:	0a6080e7          	jalr	166(ra) # 80000540 <panic>

00000000800064a2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800064a2:	7119                	addi	sp,sp,-128
    800064a4:	fc86                	sd	ra,120(sp)
    800064a6:	f8a2                	sd	s0,112(sp)
    800064a8:	f4a6                	sd	s1,104(sp)
    800064aa:	f0ca                	sd	s2,96(sp)
    800064ac:	ecce                	sd	s3,88(sp)
    800064ae:	e8d2                	sd	s4,80(sp)
    800064b0:	e4d6                	sd	s5,72(sp)
    800064b2:	e0da                	sd	s6,64(sp)
    800064b4:	fc5e                	sd	s7,56(sp)
    800064b6:	f862                	sd	s8,48(sp)
    800064b8:	f466                	sd	s9,40(sp)
    800064ba:	f06a                	sd	s10,32(sp)
    800064bc:	ec6e                	sd	s11,24(sp)
    800064be:	0100                	addi	s0,sp,128
    800064c0:	8aaa                	mv	s5,a0
    800064c2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064c4:	00c52d03          	lw	s10,12(a0)
    800064c8:	001d1d1b          	slliw	s10,s10,0x1
    800064cc:	1d02                	slli	s10,s10,0x20
    800064ce:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800064d2:	00023517          	auipc	a0,0x23
    800064d6:	13650513          	addi	a0,a0,310 # 80029608 <disk+0x128>
    800064da:	ffffa097          	auipc	ra,0xffffa
    800064de:	6fc080e7          	jalr	1788(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800064e2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064e4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064e6:	00023b97          	auipc	s7,0x23
    800064ea:	ffab8b93          	addi	s7,s7,-6 # 800294e0 <disk>
  for(int i = 0; i < 3; i++){
    800064ee:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064f0:	00023c97          	auipc	s9,0x23
    800064f4:	118c8c93          	addi	s9,s9,280 # 80029608 <disk+0x128>
    800064f8:	a08d                	j	8000655a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800064fa:	00fb8733          	add	a4,s7,a5
    800064fe:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006502:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006504:	0207c563          	bltz	a5,8000652e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006508:	2905                	addiw	s2,s2,1
    8000650a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000650c:	05690c63          	beq	s2,s6,80006564 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006510:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006512:	00023717          	auipc	a4,0x23
    80006516:	fce70713          	addi	a4,a4,-50 # 800294e0 <disk>
    8000651a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000651c:	01874683          	lbu	a3,24(a4)
    80006520:	fee9                	bnez	a3,800064fa <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006522:	2785                	addiw	a5,a5,1
    80006524:	0705                	addi	a4,a4,1
    80006526:	fe979be3          	bne	a5,s1,8000651c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000652a:	57fd                	li	a5,-1
    8000652c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000652e:	01205d63          	blez	s2,80006548 <virtio_disk_rw+0xa6>
    80006532:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006534:	000a2503          	lw	a0,0(s4)
    80006538:	00000097          	auipc	ra,0x0
    8000653c:	cfe080e7          	jalr	-770(ra) # 80006236 <free_desc>
      for(int j = 0; j < i; j++)
    80006540:	2d85                	addiw	s11,s11,1
    80006542:	0a11                	addi	s4,s4,4
    80006544:	ff2d98e3          	bne	s11,s2,80006534 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006548:	85e6                	mv	a1,s9
    8000654a:	00023517          	auipc	a0,0x23
    8000654e:	fae50513          	addi	a0,a0,-82 # 800294f8 <disk+0x18>
    80006552:	ffffc097          	auipc	ra,0xffffc
    80006556:	c56080e7          	jalr	-938(ra) # 800021a8 <sleep>
  for(int i = 0; i < 3; i++){
    8000655a:	f8040a13          	addi	s4,s0,-128
{
    8000655e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006560:	894e                	mv	s2,s3
    80006562:	b77d                	j	80006510 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006564:	f8042503          	lw	a0,-128(s0)
    80006568:	00a50713          	addi	a4,a0,10
    8000656c:	0712                	slli	a4,a4,0x4

  if(write)
    8000656e:	00023797          	auipc	a5,0x23
    80006572:	f7278793          	addi	a5,a5,-142 # 800294e0 <disk>
    80006576:	00e786b3          	add	a3,a5,a4
    8000657a:	01803633          	snez	a2,s8
    8000657e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006580:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006584:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006588:	f6070613          	addi	a2,a4,-160
    8000658c:	6394                	ld	a3,0(a5)
    8000658e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006590:	00870593          	addi	a1,a4,8
    80006594:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006596:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006598:	0007b803          	ld	a6,0(a5)
    8000659c:	9642                	add	a2,a2,a6
    8000659e:	46c1                	li	a3,16
    800065a0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800065a2:	4585                	li	a1,1
    800065a4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800065a8:	f8442683          	lw	a3,-124(s0)
    800065ac:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800065b0:	0692                	slli	a3,a3,0x4
    800065b2:	9836                	add	a6,a6,a3
    800065b4:	058a8613          	addi	a2,s5,88
    800065b8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800065bc:	0007b803          	ld	a6,0(a5)
    800065c0:	96c2                	add	a3,a3,a6
    800065c2:	40000613          	li	a2,1024
    800065c6:	c690                	sw	a2,8(a3)
  if(write)
    800065c8:	001c3613          	seqz	a2,s8
    800065cc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065d0:	00166613          	ori	a2,a2,1
    800065d4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800065d8:	f8842603          	lw	a2,-120(s0)
    800065dc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065e0:	00250693          	addi	a3,a0,2
    800065e4:	0692                	slli	a3,a3,0x4
    800065e6:	96be                	add	a3,a3,a5
    800065e8:	58fd                	li	a7,-1
    800065ea:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065ee:	0612                	slli	a2,a2,0x4
    800065f0:	9832                	add	a6,a6,a2
    800065f2:	f9070713          	addi	a4,a4,-112
    800065f6:	973e                	add	a4,a4,a5
    800065f8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800065fc:	6398                	ld	a4,0(a5)
    800065fe:	9732                	add	a4,a4,a2
    80006600:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006602:	4609                	li	a2,2
    80006604:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006608:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000660c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006610:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006614:	6794                	ld	a3,8(a5)
    80006616:	0026d703          	lhu	a4,2(a3)
    8000661a:	8b1d                	andi	a4,a4,7
    8000661c:	0706                	slli	a4,a4,0x1
    8000661e:	96ba                	add	a3,a3,a4
    80006620:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006624:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006628:	6798                	ld	a4,8(a5)
    8000662a:	00275783          	lhu	a5,2(a4)
    8000662e:	2785                	addiw	a5,a5,1
    80006630:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006634:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006638:	100017b7          	lui	a5,0x10001
    8000663c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006640:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006644:	00023917          	auipc	s2,0x23
    80006648:	fc490913          	addi	s2,s2,-60 # 80029608 <disk+0x128>
  while(b->disk == 1) {
    8000664c:	4485                	li	s1,1
    8000664e:	00b79c63          	bne	a5,a1,80006666 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006652:	85ca                	mv	a1,s2
    80006654:	8556                	mv	a0,s5
    80006656:	ffffc097          	auipc	ra,0xffffc
    8000665a:	b52080e7          	jalr	-1198(ra) # 800021a8 <sleep>
  while(b->disk == 1) {
    8000665e:	004aa783          	lw	a5,4(s5)
    80006662:	fe9788e3          	beq	a5,s1,80006652 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006666:	f8042903          	lw	s2,-128(s0)
    8000666a:	00290713          	addi	a4,s2,2
    8000666e:	0712                	slli	a4,a4,0x4
    80006670:	00023797          	auipc	a5,0x23
    80006674:	e7078793          	addi	a5,a5,-400 # 800294e0 <disk>
    80006678:	97ba                	add	a5,a5,a4
    8000667a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000667e:	00023997          	auipc	s3,0x23
    80006682:	e6298993          	addi	s3,s3,-414 # 800294e0 <disk>
    80006686:	00491713          	slli	a4,s2,0x4
    8000668a:	0009b783          	ld	a5,0(s3)
    8000668e:	97ba                	add	a5,a5,a4
    80006690:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006694:	854a                	mv	a0,s2
    80006696:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000669a:	00000097          	auipc	ra,0x0
    8000669e:	b9c080e7          	jalr	-1124(ra) # 80006236 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800066a2:	8885                	andi	s1,s1,1
    800066a4:	f0ed                	bnez	s1,80006686 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066a6:	00023517          	auipc	a0,0x23
    800066aa:	f6250513          	addi	a0,a0,-158 # 80029608 <disk+0x128>
    800066ae:	ffffa097          	auipc	ra,0xffffa
    800066b2:	5dc080e7          	jalr	1500(ra) # 80000c8a <release>
}
    800066b6:	70e6                	ld	ra,120(sp)
    800066b8:	7446                	ld	s0,112(sp)
    800066ba:	74a6                	ld	s1,104(sp)
    800066bc:	7906                	ld	s2,96(sp)
    800066be:	69e6                	ld	s3,88(sp)
    800066c0:	6a46                	ld	s4,80(sp)
    800066c2:	6aa6                	ld	s5,72(sp)
    800066c4:	6b06                	ld	s6,64(sp)
    800066c6:	7be2                	ld	s7,56(sp)
    800066c8:	7c42                	ld	s8,48(sp)
    800066ca:	7ca2                	ld	s9,40(sp)
    800066cc:	7d02                	ld	s10,32(sp)
    800066ce:	6de2                	ld	s11,24(sp)
    800066d0:	6109                	addi	sp,sp,128
    800066d2:	8082                	ret

00000000800066d4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800066d4:	1101                	addi	sp,sp,-32
    800066d6:	ec06                	sd	ra,24(sp)
    800066d8:	e822                	sd	s0,16(sp)
    800066da:	e426                	sd	s1,8(sp)
    800066dc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066de:	00023497          	auipc	s1,0x23
    800066e2:	e0248493          	addi	s1,s1,-510 # 800294e0 <disk>
    800066e6:	00023517          	auipc	a0,0x23
    800066ea:	f2250513          	addi	a0,a0,-222 # 80029608 <disk+0x128>
    800066ee:	ffffa097          	auipc	ra,0xffffa
    800066f2:	4e8080e7          	jalr	1256(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066f6:	10001737          	lui	a4,0x10001
    800066fa:	533c                	lw	a5,96(a4)
    800066fc:	8b8d                	andi	a5,a5,3
    800066fe:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006700:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006704:	689c                	ld	a5,16(s1)
    80006706:	0204d703          	lhu	a4,32(s1)
    8000670a:	0027d783          	lhu	a5,2(a5)
    8000670e:	04f70863          	beq	a4,a5,8000675e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006712:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006716:	6898                	ld	a4,16(s1)
    80006718:	0204d783          	lhu	a5,32(s1)
    8000671c:	8b9d                	andi	a5,a5,7
    8000671e:	078e                	slli	a5,a5,0x3
    80006720:	97ba                	add	a5,a5,a4
    80006722:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006724:	00278713          	addi	a4,a5,2
    80006728:	0712                	slli	a4,a4,0x4
    8000672a:	9726                	add	a4,a4,s1
    8000672c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006730:	e721                	bnez	a4,80006778 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006732:	0789                	addi	a5,a5,2
    80006734:	0792                	slli	a5,a5,0x4
    80006736:	97a6                	add	a5,a5,s1
    80006738:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000673a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000673e:	ffffc097          	auipc	ra,0xffffc
    80006742:	ace080e7          	jalr	-1330(ra) # 8000220c <wakeup>

    disk.used_idx += 1;
    80006746:	0204d783          	lhu	a5,32(s1)
    8000674a:	2785                	addiw	a5,a5,1
    8000674c:	17c2                	slli	a5,a5,0x30
    8000674e:	93c1                	srli	a5,a5,0x30
    80006750:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006754:	6898                	ld	a4,16(s1)
    80006756:	00275703          	lhu	a4,2(a4)
    8000675a:	faf71ce3          	bne	a4,a5,80006712 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000675e:	00023517          	auipc	a0,0x23
    80006762:	eaa50513          	addi	a0,a0,-342 # 80029608 <disk+0x128>
    80006766:	ffffa097          	auipc	ra,0xffffa
    8000676a:	524080e7          	jalr	1316(ra) # 80000c8a <release>
}
    8000676e:	60e2                	ld	ra,24(sp)
    80006770:	6442                	ld	s0,16(sp)
    80006772:	64a2                	ld	s1,8(sp)
    80006774:	6105                	addi	sp,sp,32
    80006776:	8082                	ret
      panic("virtio_disk_intr status");
    80006778:	00002517          	auipc	a0,0x2
    8000677c:	0f050513          	addi	a0,a0,240 # 80008868 <syscalls+0x418>
    80006780:	ffffa097          	auipc	ra,0xffffa
    80006784:	dc0080e7          	jalr	-576(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
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
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
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
