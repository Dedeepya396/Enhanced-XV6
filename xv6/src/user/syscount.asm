
user/_syscount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <is_valid_integer>:
#include "../kernel/stat.h"
#include "user.h"
#define MY_SYSCOUNT_IMPLEMENTATION
#include "../kernel/syscount_arr.h"
int is_valid_integer(const char *str)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
      if (str == 0 || *str == '\0')
   6:	c51d                	beqz	a0,34 <is_valid_integer+0x34>
   8:	872a                	mv	a4,a0
   a:	00054783          	lbu	a5,0(a0)
      {
            return 0;
   e:	4501                	li	a0,0
      if (str == 0 || *str == '\0')
  10:	c78d                	beqz	a5,3a <is_valid_integer+0x3a>
      }
      if (*str == '-')
  12:	02d00693          	li	a3,45
  16:	02d78263          	beq	a5,a3,3a <is_valid_integer+0x3a>
      {
            return 0;
      }
      while (*str != '\0')
      {
            if (*str < '0' || *str > '9')
  1a:	46a5                	li	a3,9
  1c:	fd07879b          	addiw	a5,a5,-48
  20:	0ff7f793          	zext.b	a5,a5
  24:	00f6ea63          	bltu	a3,a5,38 <is_valid_integer+0x38>
            {
                  return 0;
            }
            str++;
  28:	0705                	addi	a4,a4,1
      while (*str != '\0')
  2a:	00074783          	lbu	a5,0(a4)
  2e:	f7fd                	bnez	a5,1c <is_valid_integer+0x1c>
      }
      return 1;
  30:	4505                	li	a0,1
  32:	a021                	j	3a <is_valid_integer+0x3a>
            return 0;
  34:	4501                	li	a0,0
  36:	a011                	j	3a <is_valid_integer+0x3a>
                  return 0;
  38:	4501                	li	a0,0
}
  3a:	6422                	ld	s0,8(sp)
  3c:	0141                	addi	sp,sp,16
  3e:	8082                	ret

0000000000000040 <is_power_of_2>:
int is_power_of_2(int n) {
  40:	1141                	addi	sp,sp,-16
  42:	e422                	sd	s0,8(sp)
  44:	0800                	addi	s0,sp,16
    return n > 0 && (n & (n - 1)) == 0;
  46:	00a05b63          	blez	a0,5c <is_power_of_2+0x1c>
  4a:	fff5079b          	addiw	a5,a0,-1
  4e:	8d7d                	and	a0,a0,a5
  50:	2501                	sext.w	a0,a0
  52:	00153513          	seqz	a0,a0
}
  56:	6422                	ld	s0,8(sp)
  58:	0141                	addi	sp,sp,16
  5a:	8082                	ret
    return n > 0 && (n & (n - 1)) == 0;
  5c:	4501                	li	a0,0
  5e:	bfe5                	j	56 <is_power_of_2+0x16>

0000000000000060 <main>:
int main(int argc, char *argv[])
{
  60:	7169                	addi	sp,sp,-304
  62:	f606                	sd	ra,296(sp)
  64:	f222                	sd	s0,288(sp)
  66:	ee26                	sd	s1,280(sp)
  68:	ea4a                	sd	s2,272(sp)
  6a:	e64e                	sd	s3,264(sp)
  6c:	1a00                	addi	s0,sp,304
      if (argc < 3)
  6e:	4789                	li	a5,2
  70:	04a7d663          	bge	a5,a0,bc <main+0x5c>
  74:	892e                	mv	s2,a1
      {
            printf("Usage: syscount <mask> command [args]\n");
            exit(0);
      }
      int mask = atoi(argv[1]);
  76:	6588                	ld	a0,8(a1)
  78:	00000097          	auipc	ra,0x0
  7c:	3d8080e7          	jalr	984(ra) # 450 <atoi>
  80:	84aa                	mv	s1,a0
      if (!is_valid_integer(argv[1])|| (!is_power_of_2(mask)))
  82:	00893503          	ld	a0,8(s2)
  86:	00000097          	auipc	ra,0x0
  8a:	f7a080e7          	jalr	-134(ra) # 0 <is_valid_integer>
  8e:	c519                	beqz	a0,9c <main+0x3c>
  90:	8526                	mv	a0,s1
  92:	00000097          	auipc	ra,0x0
  96:	fae080e7          	jalr	-82(ra) # 40 <is_power_of_2>
  9a:	ed15                	bnez	a0,d6 <main+0x76>
      {
            printf("Enter a valid mask\n");
  9c:	00001517          	auipc	a0,0x1
  a0:	a1c50513          	addi	a0,a0,-1508 # ab8 <malloc+0x11c>
  a4:	00001097          	auipc	ra,0x1
  a8:	840080e7          	jalr	-1984(ra) # 8e4 <printf>
            {
                  syscount[i] = 0;
            }
      }
      return 0;
}
  ac:	4501                	li	a0,0
  ae:	70b2                	ld	ra,296(sp)
  b0:	7412                	ld	s0,288(sp)
  b2:	64f2                	ld	s1,280(sp)
  b4:	6952                	ld	s2,272(sp)
  b6:	69b2                	ld	s3,264(sp)
  b8:	6155                	addi	sp,sp,304
  ba:	8082                	ret
            printf("Usage: syscount <mask> command [args]\n");
  bc:	00001517          	auipc	a0,0x1
  c0:	9d450513          	addi	a0,a0,-1580 # a90 <malloc+0xf4>
  c4:	00001097          	auipc	ra,0x1
  c8:	820080e7          	jalr	-2016(ra) # 8e4 <printf>
            exit(0);
  cc:	4501                	li	a0,0
  ce:	00000097          	auipc	ra,0x0
  d2:	47c080e7          	jalr	1148(ra) # 54a <exit>
      getcount(mask);
  d6:	8526                	mv	a0,s1
  d8:	00000097          	auipc	ra,0x0
  dc:	51a080e7          	jalr	1306(ra) # 5f2 <getcount>
      int pid = fork();
  e0:	00000097          	auipc	ra,0x0
  e4:	462080e7          	jalr	1122(ra) # 542 <fork>
  e8:	89aa                	mv	s3,a0
      if (pid < 0)
  ea:	18054963          	bltz	a0,27c <main+0x21c>
      if (pid == 0)
  ee:	1a050463          	beqz	a0,296 <main+0x236>
            wait(&status);
  f2:	ed440513          	addi	a0,s0,-300
  f6:	00000097          	auipc	ra,0x0
  fa:	45c080e7          	jalr	1116(ra) # 552 <wait>
            int count = getcount(mask);
  fe:	8526                	mv	a0,s1
 100:	00000097          	auipc	ra,0x0
 104:	4f2080e7          	jalr	1266(ra) # 5f2 <getcount>
 108:	892a                	mv	s2,a0
            char *arr[31] = {
 10a:	04800613          	li	a2,72
 10e:	4581                	li	a1,0
 110:	f8840513          	addi	a0,s0,-120
 114:	00000097          	auipc	ra,0x0
 118:	23c080e7          	jalr	572(ra) # 350 <memset>
 11c:	00001797          	auipc	a5,0x1
 120:	9e478793          	addi	a5,a5,-1564 # b00 <malloc+0x164>
 124:	ecf43c23          	sd	a5,-296(s0)
 128:	00001797          	auipc	a5,0x1
 12c:	9e078793          	addi	a5,a5,-1568 # b08 <malloc+0x16c>
 130:	eef43023          	sd	a5,-288(s0)
 134:	00001797          	auipc	a5,0x1
 138:	9dc78793          	addi	a5,a5,-1572 # b10 <malloc+0x174>
 13c:	eef43423          	sd	a5,-280(s0)
 140:	00001797          	auipc	a5,0x1
 144:	9d878793          	addi	a5,a5,-1576 # b18 <malloc+0x17c>
 148:	eef43823          	sd	a5,-272(s0)
 14c:	00001797          	auipc	a5,0x1
 150:	9d478793          	addi	a5,a5,-1580 # b20 <malloc+0x184>
 154:	eef43c23          	sd	a5,-264(s0)
 158:	00001797          	auipc	a5,0x1
 15c:	9d078793          	addi	a5,a5,-1584 # b28 <malloc+0x18c>
 160:	f0f43023          	sd	a5,-256(s0)
 164:	00001797          	auipc	a5,0x1
 168:	9cc78793          	addi	a5,a5,-1588 # b30 <malloc+0x194>
 16c:	f0f43423          	sd	a5,-248(s0)
 170:	00001797          	auipc	a5,0x1
 174:	9c878793          	addi	a5,a5,-1592 # b38 <malloc+0x19c>
 178:	f0f43823          	sd	a5,-240(s0)
 17c:	00001797          	auipc	a5,0x1
 180:	9c478793          	addi	a5,a5,-1596 # b40 <malloc+0x1a4>
 184:	f0f43c23          	sd	a5,-232(s0)
 188:	00001797          	auipc	a5,0x1
 18c:	9c078793          	addi	a5,a5,-1600 # b48 <malloc+0x1ac>
 190:	f2f43023          	sd	a5,-224(s0)
 194:	00001797          	auipc	a5,0x1
 198:	9bc78793          	addi	a5,a5,-1604 # b50 <malloc+0x1b4>
 19c:	f2f43423          	sd	a5,-216(s0)
 1a0:	00001797          	auipc	a5,0x1
 1a4:	9b878793          	addi	a5,a5,-1608 # b58 <malloc+0x1bc>
 1a8:	f2f43823          	sd	a5,-208(s0)
 1ac:	00001797          	auipc	a5,0x1
 1b0:	9b478793          	addi	a5,a5,-1612 # b60 <malloc+0x1c4>
 1b4:	f2f43c23          	sd	a5,-200(s0)
 1b8:	00001797          	auipc	a5,0x1
 1bc:	9b078793          	addi	a5,a5,-1616 # b68 <malloc+0x1cc>
 1c0:	f4f43023          	sd	a5,-192(s0)
 1c4:	00001797          	auipc	a5,0x1
 1c8:	9ac78793          	addi	a5,a5,-1620 # b70 <malloc+0x1d4>
 1cc:	f4f43423          	sd	a5,-184(s0)
 1d0:	00001797          	auipc	a5,0x1
 1d4:	9a878793          	addi	a5,a5,-1624 # b78 <malloc+0x1dc>
 1d8:	f4f43823          	sd	a5,-176(s0)
 1dc:	00001797          	auipc	a5,0x1
 1e0:	9a478793          	addi	a5,a5,-1628 # b80 <malloc+0x1e4>
 1e4:	f4f43c23          	sd	a5,-168(s0)
 1e8:	00001797          	auipc	a5,0x1
 1ec:	9a078793          	addi	a5,a5,-1632 # b88 <malloc+0x1ec>
 1f0:	f6f43023          	sd	a5,-160(s0)
 1f4:	00001797          	auipc	a5,0x1
 1f8:	99c78793          	addi	a5,a5,-1636 # b90 <malloc+0x1f4>
 1fc:	f6f43423          	sd	a5,-152(s0)
 200:	00001797          	auipc	a5,0x1
 204:	99878793          	addi	a5,a5,-1640 # b98 <malloc+0x1fc>
 208:	f6f43823          	sd	a5,-144(s0)
 20c:	00001797          	auipc	a5,0x1
 210:	99478793          	addi	a5,a5,-1644 # ba0 <malloc+0x204>
 214:	f6f43c23          	sd	a5,-136(s0)
 218:	00001797          	auipc	a5,0x1
 21c:	99078793          	addi	a5,a5,-1648 # ba8 <malloc+0x20c>
 220:	f8f43023          	sd	a5,-128(s0)
                  if (1 << i == mask)
 224:	4785                	li	a5,1
 226:	08f48d63          	beq	s1,a5,2c0 <main+0x260>
 22a:	4605                	li	a2,1
            for (int i = 0; i < 31; i++)
 22c:	487d                	li	a6,31
                  if (1 << i == mask)
 22e:	00f6173b          	sllw	a4,a2,a5
 232:	00970663          	beq	a4,s1,23e <main+0x1de>
            for (int i = 0; i < 31; i++)
 236:	2785                	addiw	a5,a5,1
 238:	ff079be3          	bne	a5,a6,22e <main+0x1ce>
            int a = 0;
 23c:	4781                	li	a5,0
            printf("PID %d called the %s %d times.\n", pid, arr[a - 1], count);
 23e:	37fd                	addiw	a5,a5,-1
 240:	078e                	slli	a5,a5,0x3
 242:	fd078793          	addi	a5,a5,-48
 246:	97a2                	add	a5,a5,s0
 248:	86ca                	mv	a3,s2
 24a:	f087b603          	ld	a2,-248(a5)
 24e:	85ce                	mv	a1,s3
 250:	00001517          	auipc	a0,0x1
 254:	96050513          	addi	a0,a0,-1696 # bb0 <malloc+0x214>
 258:	00000097          	auipc	ra,0x0
 25c:	68c080e7          	jalr	1676(ra) # 8e4 <printf>
            for (int i = 0; i < 31; i++)
 260:	00001797          	auipc	a5,0x1
 264:	db078793          	addi	a5,a5,-592 # 1010 <syscount>
 268:	00001717          	auipc	a4,0x1
 26c:	e2470713          	addi	a4,a4,-476 # 108c <syscount+0x7c>
                  syscount[i] = 0;
 270:	0007a023          	sw	zero,0(a5)
            for (int i = 0; i < 31; i++)
 274:	0791                	addi	a5,a5,4
 276:	fee79de3          	bne	a5,a4,270 <main+0x210>
 27a:	bd0d                	j	ac <main+0x4c>
            printf("Error in creating child\n");
 27c:	00001517          	auipc	a0,0x1
 280:	85450513          	addi	a0,a0,-1964 # ad0 <malloc+0x134>
 284:	00000097          	auipc	ra,0x0
 288:	660080e7          	jalr	1632(ra) # 8e4 <printf>
            exit(0);
 28c:	4501                	li	a0,0
 28e:	00000097          	auipc	ra,0x0
 292:	2bc080e7          	jalr	700(ra) # 54a <exit>
            exec(argv[2], &argv[2]);
 296:	01090593          	addi	a1,s2,16
 29a:	01093503          	ld	a0,16(s2)
 29e:	00000097          	auipc	ra,0x0
 2a2:	2e4080e7          	jalr	740(ra) # 582 <exec>
            printf("exec failed\n");
 2a6:	00001517          	auipc	a0,0x1
 2aa:	84a50513          	addi	a0,a0,-1974 # af0 <malloc+0x154>
 2ae:	00000097          	auipc	ra,0x0
 2b2:	636080e7          	jalr	1590(ra) # 8e4 <printf>
            exit(0);
 2b6:	4501                	li	a0,0
 2b8:	00000097          	auipc	ra,0x0
 2bc:	292080e7          	jalr	658(ra) # 54a <exit>
            for (int i = 0; i < 31; i++)
 2c0:	4781                	li	a5,0
 2c2:	bfb5                	j	23e <main+0x1de>

00000000000002c4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2cc:	00000097          	auipc	ra,0x0
 2d0:	d94080e7          	jalr	-620(ra) # 60 <main>
  exit(0);
 2d4:	4501                	li	a0,0
 2d6:	00000097          	auipc	ra,0x0
 2da:	274080e7          	jalr	628(ra) # 54a <exit>

00000000000002de <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2e4:	87aa                	mv	a5,a0
 2e6:	0585                	addi	a1,a1,1
 2e8:	0785                	addi	a5,a5,1
 2ea:	fff5c703          	lbu	a4,-1(a1)
 2ee:	fee78fa3          	sb	a4,-1(a5)
 2f2:	fb75                	bnez	a4,2e6 <strcpy+0x8>
    ;
  return os;
}
 2f4:	6422                	ld	s0,8(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret

00000000000002fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e422                	sd	s0,8(sp)
 2fe:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 300:	00054783          	lbu	a5,0(a0)
 304:	cb91                	beqz	a5,318 <strcmp+0x1e>
 306:	0005c703          	lbu	a4,0(a1)
 30a:	00f71763          	bne	a4,a5,318 <strcmp+0x1e>
    p++, q++;
 30e:	0505                	addi	a0,a0,1
 310:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 312:	00054783          	lbu	a5,0(a0)
 316:	fbe5                	bnez	a5,306 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 318:	0005c503          	lbu	a0,0(a1)
}
 31c:	40a7853b          	subw	a0,a5,a0
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <strlen>:

uint
strlen(const char *s)
{
 326:	1141                	addi	sp,sp,-16
 328:	e422                	sd	s0,8(sp)
 32a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 32c:	00054783          	lbu	a5,0(a0)
 330:	cf91                	beqz	a5,34c <strlen+0x26>
 332:	0505                	addi	a0,a0,1
 334:	87aa                	mv	a5,a0
 336:	4685                	li	a3,1
 338:	9e89                	subw	a3,a3,a0
 33a:	00f6853b          	addw	a0,a3,a5
 33e:	0785                	addi	a5,a5,1
 340:	fff7c703          	lbu	a4,-1(a5)
 344:	fb7d                	bnez	a4,33a <strlen+0x14>
    ;
  return n;
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret
  for(n = 0; s[n]; n++)
 34c:	4501                	li	a0,0
 34e:	bfe5                	j	346 <strlen+0x20>

0000000000000350 <memset>:

void*
memset(void *dst, int c, uint n)
{
 350:	1141                	addi	sp,sp,-16
 352:	e422                	sd	s0,8(sp)
 354:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 356:	ca19                	beqz	a2,36c <memset+0x1c>
 358:	87aa                	mv	a5,a0
 35a:	1602                	slli	a2,a2,0x20
 35c:	9201                	srli	a2,a2,0x20
 35e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 362:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 366:	0785                	addi	a5,a5,1
 368:	fee79de3          	bne	a5,a4,362 <memset+0x12>
  }
  return dst;
}
 36c:	6422                	ld	s0,8(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret

0000000000000372 <strchr>:

char*
strchr(const char *s, char c)
{
 372:	1141                	addi	sp,sp,-16
 374:	e422                	sd	s0,8(sp)
 376:	0800                	addi	s0,sp,16
  for(; *s; s++)
 378:	00054783          	lbu	a5,0(a0)
 37c:	cb99                	beqz	a5,392 <strchr+0x20>
    if(*s == c)
 37e:	00f58763          	beq	a1,a5,38c <strchr+0x1a>
  for(; *s; s++)
 382:	0505                	addi	a0,a0,1
 384:	00054783          	lbu	a5,0(a0)
 388:	fbfd                	bnez	a5,37e <strchr+0xc>
      return (char*)s;
  return 0;
 38a:	4501                	li	a0,0
}
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret
  return 0;
 392:	4501                	li	a0,0
 394:	bfe5                	j	38c <strchr+0x1a>

0000000000000396 <gets>:

char*
gets(char *buf, int max)
{
 396:	711d                	addi	sp,sp,-96
 398:	ec86                	sd	ra,88(sp)
 39a:	e8a2                	sd	s0,80(sp)
 39c:	e4a6                	sd	s1,72(sp)
 39e:	e0ca                	sd	s2,64(sp)
 3a0:	fc4e                	sd	s3,56(sp)
 3a2:	f852                	sd	s4,48(sp)
 3a4:	f456                	sd	s5,40(sp)
 3a6:	f05a                	sd	s6,32(sp)
 3a8:	ec5e                	sd	s7,24(sp)
 3aa:	1080                	addi	s0,sp,96
 3ac:	8baa                	mv	s7,a0
 3ae:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3b0:	892a                	mv	s2,a0
 3b2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3b4:	4aa9                	li	s5,10
 3b6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3b8:	89a6                	mv	s3,s1
 3ba:	2485                	addiw	s1,s1,1
 3bc:	0344d863          	bge	s1,s4,3ec <gets+0x56>
    cc = read(0, &c, 1);
 3c0:	4605                	li	a2,1
 3c2:	faf40593          	addi	a1,s0,-81
 3c6:	4501                	li	a0,0
 3c8:	00000097          	auipc	ra,0x0
 3cc:	19a080e7          	jalr	410(ra) # 562 <read>
    if(cc < 1)
 3d0:	00a05e63          	blez	a0,3ec <gets+0x56>
    buf[i++] = c;
 3d4:	faf44783          	lbu	a5,-81(s0)
 3d8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3dc:	01578763          	beq	a5,s5,3ea <gets+0x54>
 3e0:	0905                	addi	s2,s2,1
 3e2:	fd679be3          	bne	a5,s6,3b8 <gets+0x22>
  for(i=0; i+1 < max; ){
 3e6:	89a6                	mv	s3,s1
 3e8:	a011                	j	3ec <gets+0x56>
 3ea:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3ec:	99de                	add	s3,s3,s7
 3ee:	00098023          	sb	zero,0(s3)
  return buf;
}
 3f2:	855e                	mv	a0,s7
 3f4:	60e6                	ld	ra,88(sp)
 3f6:	6446                	ld	s0,80(sp)
 3f8:	64a6                	ld	s1,72(sp)
 3fa:	6906                	ld	s2,64(sp)
 3fc:	79e2                	ld	s3,56(sp)
 3fe:	7a42                	ld	s4,48(sp)
 400:	7aa2                	ld	s5,40(sp)
 402:	7b02                	ld	s6,32(sp)
 404:	6be2                	ld	s7,24(sp)
 406:	6125                	addi	sp,sp,96
 408:	8082                	ret

000000000000040a <stat>:

int
stat(const char *n, struct stat *st)
{
 40a:	1101                	addi	sp,sp,-32
 40c:	ec06                	sd	ra,24(sp)
 40e:	e822                	sd	s0,16(sp)
 410:	e426                	sd	s1,8(sp)
 412:	e04a                	sd	s2,0(sp)
 414:	1000                	addi	s0,sp,32
 416:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 418:	4581                	li	a1,0
 41a:	00000097          	auipc	ra,0x0
 41e:	170080e7          	jalr	368(ra) # 58a <open>
  if(fd < 0)
 422:	02054563          	bltz	a0,44c <stat+0x42>
 426:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 428:	85ca                	mv	a1,s2
 42a:	00000097          	auipc	ra,0x0
 42e:	178080e7          	jalr	376(ra) # 5a2 <fstat>
 432:	892a                	mv	s2,a0
  close(fd);
 434:	8526                	mv	a0,s1
 436:	00000097          	auipc	ra,0x0
 43a:	13c080e7          	jalr	316(ra) # 572 <close>
  return r;
}
 43e:	854a                	mv	a0,s2
 440:	60e2                	ld	ra,24(sp)
 442:	6442                	ld	s0,16(sp)
 444:	64a2                	ld	s1,8(sp)
 446:	6902                	ld	s2,0(sp)
 448:	6105                	addi	sp,sp,32
 44a:	8082                	ret
    return -1;
 44c:	597d                	li	s2,-1
 44e:	bfc5                	j	43e <stat+0x34>

0000000000000450 <atoi>:

int
atoi(const char *s)
{
 450:	1141                	addi	sp,sp,-16
 452:	e422                	sd	s0,8(sp)
 454:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 456:	00054683          	lbu	a3,0(a0)
 45a:	fd06879b          	addiw	a5,a3,-48
 45e:	0ff7f793          	zext.b	a5,a5
 462:	4625                	li	a2,9
 464:	02f66863          	bltu	a2,a5,494 <atoi+0x44>
 468:	872a                	mv	a4,a0
  n = 0;
 46a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 46c:	0705                	addi	a4,a4,1
 46e:	0025179b          	slliw	a5,a0,0x2
 472:	9fa9                	addw	a5,a5,a0
 474:	0017979b          	slliw	a5,a5,0x1
 478:	9fb5                	addw	a5,a5,a3
 47a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 47e:	00074683          	lbu	a3,0(a4)
 482:	fd06879b          	addiw	a5,a3,-48
 486:	0ff7f793          	zext.b	a5,a5
 48a:	fef671e3          	bgeu	a2,a5,46c <atoi+0x1c>
  return n;
}
 48e:	6422                	ld	s0,8(sp)
 490:	0141                	addi	sp,sp,16
 492:	8082                	ret
  n = 0;
 494:	4501                	li	a0,0
 496:	bfe5                	j	48e <atoi+0x3e>

0000000000000498 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 498:	1141                	addi	sp,sp,-16
 49a:	e422                	sd	s0,8(sp)
 49c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 49e:	02b57463          	bgeu	a0,a1,4c6 <memmove+0x2e>
    while(n-- > 0)
 4a2:	00c05f63          	blez	a2,4c0 <memmove+0x28>
 4a6:	1602                	slli	a2,a2,0x20
 4a8:	9201                	srli	a2,a2,0x20
 4aa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4ae:	872a                	mv	a4,a0
      *dst++ = *src++;
 4b0:	0585                	addi	a1,a1,1
 4b2:	0705                	addi	a4,a4,1
 4b4:	fff5c683          	lbu	a3,-1(a1)
 4b8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4bc:	fee79ae3          	bne	a5,a4,4b0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4c0:	6422                	ld	s0,8(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret
    dst += n;
 4c6:	00c50733          	add	a4,a0,a2
    src += n;
 4ca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4cc:	fec05ae3          	blez	a2,4c0 <memmove+0x28>
 4d0:	fff6079b          	addiw	a5,a2,-1
 4d4:	1782                	slli	a5,a5,0x20
 4d6:	9381                	srli	a5,a5,0x20
 4d8:	fff7c793          	not	a5,a5
 4dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4de:	15fd                	addi	a1,a1,-1
 4e0:	177d                	addi	a4,a4,-1
 4e2:	0005c683          	lbu	a3,0(a1)
 4e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4ea:	fee79ae3          	bne	a5,a4,4de <memmove+0x46>
 4ee:	bfc9                	j	4c0 <memmove+0x28>

00000000000004f0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4f0:	1141                	addi	sp,sp,-16
 4f2:	e422                	sd	s0,8(sp)
 4f4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4f6:	ca05                	beqz	a2,526 <memcmp+0x36>
 4f8:	fff6069b          	addiw	a3,a2,-1
 4fc:	1682                	slli	a3,a3,0x20
 4fe:	9281                	srli	a3,a3,0x20
 500:	0685                	addi	a3,a3,1
 502:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 504:	00054783          	lbu	a5,0(a0)
 508:	0005c703          	lbu	a4,0(a1)
 50c:	00e79863          	bne	a5,a4,51c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 510:	0505                	addi	a0,a0,1
    p2++;
 512:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 514:	fed518e3          	bne	a0,a3,504 <memcmp+0x14>
  }
  return 0;
 518:	4501                	li	a0,0
 51a:	a019                	j	520 <memcmp+0x30>
      return *p1 - *p2;
 51c:	40e7853b          	subw	a0,a5,a4
}
 520:	6422                	ld	s0,8(sp)
 522:	0141                	addi	sp,sp,16
 524:	8082                	ret
  return 0;
 526:	4501                	li	a0,0
 528:	bfe5                	j	520 <memcmp+0x30>

000000000000052a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 52a:	1141                	addi	sp,sp,-16
 52c:	e406                	sd	ra,8(sp)
 52e:	e022                	sd	s0,0(sp)
 530:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 532:	00000097          	auipc	ra,0x0
 536:	f66080e7          	jalr	-154(ra) # 498 <memmove>
}
 53a:	60a2                	ld	ra,8(sp)
 53c:	6402                	ld	s0,0(sp)
 53e:	0141                	addi	sp,sp,16
 540:	8082                	ret

0000000000000542 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 542:	4885                	li	a7,1
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <exit>:
.global exit
exit:
 li a7, SYS_exit
 54a:	4889                	li	a7,2
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <wait>:
.global wait
wait:
 li a7, SYS_wait
 552:	488d                	li	a7,3
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 55a:	4891                	li	a7,4
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <read>:
.global read
read:
 li a7, SYS_read
 562:	4895                	li	a7,5
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <write>:
.global write
write:
 li a7, SYS_write
 56a:	48c1                	li	a7,16
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <close>:
.global close
close:
 li a7, SYS_close
 572:	48d5                	li	a7,21
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <kill>:
.global kill
kill:
 li a7, SYS_kill
 57a:	4899                	li	a7,6
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <exec>:
.global exec
exec:
 li a7, SYS_exec
 582:	489d                	li	a7,7
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <open>:
.global open
open:
 li a7, SYS_open
 58a:	48bd                	li	a7,15
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 592:	48c5                	li	a7,17
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 59a:	48c9                	li	a7,18
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5a2:	48a1                	li	a7,8
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <link>:
.global link
link:
 li a7, SYS_link
 5aa:	48cd                	li	a7,19
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5b2:	48d1                	li	a7,20
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5ba:	48a5                	li	a7,9
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5c2:	48a9                	li	a7,10
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5ca:	48ad                	li	a7,11
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5d2:	48b1                	li	a7,12
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5da:	48b5                	li	a7,13
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5e2:	48b9                	li	a7,14
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 5ea:	48d9                	li	a7,22
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <getcount>:
.global getcount
getcount:
 li a7, SYS_getcount
 5f2:	48dd                	li	a7,23
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 5fa:	48e5                	li	a7,25
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 602:	48e9                	li	a7,26
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 60a:	1101                	addi	sp,sp,-32
 60c:	ec06                	sd	ra,24(sp)
 60e:	e822                	sd	s0,16(sp)
 610:	1000                	addi	s0,sp,32
 612:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 616:	4605                	li	a2,1
 618:	fef40593          	addi	a1,s0,-17
 61c:	00000097          	auipc	ra,0x0
 620:	f4e080e7          	jalr	-178(ra) # 56a <write>
}
 624:	60e2                	ld	ra,24(sp)
 626:	6442                	ld	s0,16(sp)
 628:	6105                	addi	sp,sp,32
 62a:	8082                	ret

000000000000062c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 62c:	7139                	addi	sp,sp,-64
 62e:	fc06                	sd	ra,56(sp)
 630:	f822                	sd	s0,48(sp)
 632:	f426                	sd	s1,40(sp)
 634:	f04a                	sd	s2,32(sp)
 636:	ec4e                	sd	s3,24(sp)
 638:	0080                	addi	s0,sp,64
 63a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 63c:	c299                	beqz	a3,642 <printint+0x16>
 63e:	0805c963          	bltz	a1,6d0 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 642:	2581                	sext.w	a1,a1
  neg = 0;
 644:	4881                	li	a7,0
 646:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 64a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 64c:	2601                	sext.w	a2,a2
 64e:	00000517          	auipc	a0,0x0
 652:	5e250513          	addi	a0,a0,1506 # c30 <digits>
 656:	883a                	mv	a6,a4
 658:	2705                	addiw	a4,a4,1
 65a:	02c5f7bb          	remuw	a5,a1,a2
 65e:	1782                	slli	a5,a5,0x20
 660:	9381                	srli	a5,a5,0x20
 662:	97aa                	add	a5,a5,a0
 664:	0007c783          	lbu	a5,0(a5)
 668:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 66c:	0005879b          	sext.w	a5,a1
 670:	02c5d5bb          	divuw	a1,a1,a2
 674:	0685                	addi	a3,a3,1
 676:	fec7f0e3          	bgeu	a5,a2,656 <printint+0x2a>
  if(neg)
 67a:	00088c63          	beqz	a7,692 <printint+0x66>
    buf[i++] = '-';
 67e:	fd070793          	addi	a5,a4,-48
 682:	00878733          	add	a4,a5,s0
 686:	02d00793          	li	a5,45
 68a:	fef70823          	sb	a5,-16(a4)
 68e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 692:	02e05863          	blez	a4,6c2 <printint+0x96>
 696:	fc040793          	addi	a5,s0,-64
 69a:	00e78933          	add	s2,a5,a4
 69e:	fff78993          	addi	s3,a5,-1
 6a2:	99ba                	add	s3,s3,a4
 6a4:	377d                	addiw	a4,a4,-1
 6a6:	1702                	slli	a4,a4,0x20
 6a8:	9301                	srli	a4,a4,0x20
 6aa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6ae:	fff94583          	lbu	a1,-1(s2)
 6b2:	8526                	mv	a0,s1
 6b4:	00000097          	auipc	ra,0x0
 6b8:	f56080e7          	jalr	-170(ra) # 60a <putc>
  while(--i >= 0)
 6bc:	197d                	addi	s2,s2,-1
 6be:	ff3918e3          	bne	s2,s3,6ae <printint+0x82>
}
 6c2:	70e2                	ld	ra,56(sp)
 6c4:	7442                	ld	s0,48(sp)
 6c6:	74a2                	ld	s1,40(sp)
 6c8:	7902                	ld	s2,32(sp)
 6ca:	69e2                	ld	s3,24(sp)
 6cc:	6121                	addi	sp,sp,64
 6ce:	8082                	ret
    x = -xx;
 6d0:	40b005bb          	negw	a1,a1
    neg = 1;
 6d4:	4885                	li	a7,1
    x = -xx;
 6d6:	bf85                	j	646 <printint+0x1a>

00000000000006d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6d8:	7119                	addi	sp,sp,-128
 6da:	fc86                	sd	ra,120(sp)
 6dc:	f8a2                	sd	s0,112(sp)
 6de:	f4a6                	sd	s1,104(sp)
 6e0:	f0ca                	sd	s2,96(sp)
 6e2:	ecce                	sd	s3,88(sp)
 6e4:	e8d2                	sd	s4,80(sp)
 6e6:	e4d6                	sd	s5,72(sp)
 6e8:	e0da                	sd	s6,64(sp)
 6ea:	fc5e                	sd	s7,56(sp)
 6ec:	f862                	sd	s8,48(sp)
 6ee:	f466                	sd	s9,40(sp)
 6f0:	f06a                	sd	s10,32(sp)
 6f2:	ec6e                	sd	s11,24(sp)
 6f4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6f6:	0005c903          	lbu	s2,0(a1)
 6fa:	18090f63          	beqz	s2,898 <vprintf+0x1c0>
 6fe:	8aaa                	mv	s5,a0
 700:	8b32                	mv	s6,a2
 702:	00158493          	addi	s1,a1,1
  state = 0;
 706:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 708:	02500a13          	li	s4,37
 70c:	4c55                	li	s8,21
 70e:	00000c97          	auipc	s9,0x0
 712:	4cac8c93          	addi	s9,s9,1226 # bd8 <malloc+0x23c>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 716:	02800d93          	li	s11,40
  putc(fd, 'x');
 71a:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 71c:	00000b97          	auipc	s7,0x0
 720:	514b8b93          	addi	s7,s7,1300 # c30 <digits>
 724:	a839                	j	742 <vprintf+0x6a>
        putc(fd, c);
 726:	85ca                	mv	a1,s2
 728:	8556                	mv	a0,s5
 72a:	00000097          	auipc	ra,0x0
 72e:	ee0080e7          	jalr	-288(ra) # 60a <putc>
 732:	a019                	j	738 <vprintf+0x60>
    } else if(state == '%'){
 734:	01498d63          	beq	s3,s4,74e <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 738:	0485                	addi	s1,s1,1
 73a:	fff4c903          	lbu	s2,-1(s1)
 73e:	14090d63          	beqz	s2,898 <vprintf+0x1c0>
    if(state == 0){
 742:	fe0999e3          	bnez	s3,734 <vprintf+0x5c>
      if(c == '%'){
 746:	ff4910e3          	bne	s2,s4,726 <vprintf+0x4e>
        state = '%';
 74a:	89d2                	mv	s3,s4
 74c:	b7f5                	j	738 <vprintf+0x60>
      if(c == 'd'){
 74e:	11490c63          	beq	s2,s4,866 <vprintf+0x18e>
 752:	f9d9079b          	addiw	a5,s2,-99
 756:	0ff7f793          	zext.b	a5,a5
 75a:	10fc6e63          	bltu	s8,a5,876 <vprintf+0x19e>
 75e:	f9d9079b          	addiw	a5,s2,-99
 762:	0ff7f713          	zext.b	a4,a5
 766:	10ec6863          	bltu	s8,a4,876 <vprintf+0x19e>
 76a:	00271793          	slli	a5,a4,0x2
 76e:	97e6                	add	a5,a5,s9
 770:	439c                	lw	a5,0(a5)
 772:	97e6                	add	a5,a5,s9
 774:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 776:	008b0913          	addi	s2,s6,8
 77a:	4685                	li	a3,1
 77c:	4629                	li	a2,10
 77e:	000b2583          	lw	a1,0(s6)
 782:	8556                	mv	a0,s5
 784:	00000097          	auipc	ra,0x0
 788:	ea8080e7          	jalr	-344(ra) # 62c <printint>
 78c:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 78e:	4981                	li	s3,0
 790:	b765                	j	738 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 792:	008b0913          	addi	s2,s6,8
 796:	4681                	li	a3,0
 798:	4629                	li	a2,10
 79a:	000b2583          	lw	a1,0(s6)
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	e8c080e7          	jalr	-372(ra) # 62c <printint>
 7a8:	8b4a                	mv	s6,s2
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b771                	j	738 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7ae:	008b0913          	addi	s2,s6,8
 7b2:	4681                	li	a3,0
 7b4:	866a                	mv	a2,s10
 7b6:	000b2583          	lw	a1,0(s6)
 7ba:	8556                	mv	a0,s5
 7bc:	00000097          	auipc	ra,0x0
 7c0:	e70080e7          	jalr	-400(ra) # 62c <printint>
 7c4:	8b4a                	mv	s6,s2
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	bf85                	j	738 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7ca:	008b0793          	addi	a5,s6,8
 7ce:	f8f43423          	sd	a5,-120(s0)
 7d2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7d6:	03000593          	li	a1,48
 7da:	8556                	mv	a0,s5
 7dc:	00000097          	auipc	ra,0x0
 7e0:	e2e080e7          	jalr	-466(ra) # 60a <putc>
  putc(fd, 'x');
 7e4:	07800593          	li	a1,120
 7e8:	8556                	mv	a0,s5
 7ea:	00000097          	auipc	ra,0x0
 7ee:	e20080e7          	jalr	-480(ra) # 60a <putc>
 7f2:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f4:	03c9d793          	srli	a5,s3,0x3c
 7f8:	97de                	add	a5,a5,s7
 7fa:	0007c583          	lbu	a1,0(a5)
 7fe:	8556                	mv	a0,s5
 800:	00000097          	auipc	ra,0x0
 804:	e0a080e7          	jalr	-502(ra) # 60a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 808:	0992                	slli	s3,s3,0x4
 80a:	397d                	addiw	s2,s2,-1
 80c:	fe0914e3          	bnez	s2,7f4 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 810:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 814:	4981                	li	s3,0
 816:	b70d                	j	738 <vprintf+0x60>
        s = va_arg(ap, char*);
 818:	008b0913          	addi	s2,s6,8
 81c:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 820:	02098163          	beqz	s3,842 <vprintf+0x16a>
        while(*s != 0){
 824:	0009c583          	lbu	a1,0(s3)
 828:	c5ad                	beqz	a1,892 <vprintf+0x1ba>
          putc(fd, *s);
 82a:	8556                	mv	a0,s5
 82c:	00000097          	auipc	ra,0x0
 830:	dde080e7          	jalr	-546(ra) # 60a <putc>
          s++;
 834:	0985                	addi	s3,s3,1
        while(*s != 0){
 836:	0009c583          	lbu	a1,0(s3)
 83a:	f9e5                	bnez	a1,82a <vprintf+0x152>
        s = va_arg(ap, char*);
 83c:	8b4a                	mv	s6,s2
      state = 0;
 83e:	4981                	li	s3,0
 840:	bde5                	j	738 <vprintf+0x60>
          s = "(null)";
 842:	00000997          	auipc	s3,0x0
 846:	38e98993          	addi	s3,s3,910 # bd0 <malloc+0x234>
        while(*s != 0){
 84a:	85ee                	mv	a1,s11
 84c:	bff9                	j	82a <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 84e:	008b0913          	addi	s2,s6,8
 852:	000b4583          	lbu	a1,0(s6)
 856:	8556                	mv	a0,s5
 858:	00000097          	auipc	ra,0x0
 85c:	db2080e7          	jalr	-590(ra) # 60a <putc>
 860:	8b4a                	mv	s6,s2
      state = 0;
 862:	4981                	li	s3,0
 864:	bdd1                	j	738 <vprintf+0x60>
        putc(fd, c);
 866:	85d2                	mv	a1,s4
 868:	8556                	mv	a0,s5
 86a:	00000097          	auipc	ra,0x0
 86e:	da0080e7          	jalr	-608(ra) # 60a <putc>
      state = 0;
 872:	4981                	li	s3,0
 874:	b5d1                	j	738 <vprintf+0x60>
        putc(fd, '%');
 876:	85d2                	mv	a1,s4
 878:	8556                	mv	a0,s5
 87a:	00000097          	auipc	ra,0x0
 87e:	d90080e7          	jalr	-624(ra) # 60a <putc>
        putc(fd, c);
 882:	85ca                	mv	a1,s2
 884:	8556                	mv	a0,s5
 886:	00000097          	auipc	ra,0x0
 88a:	d84080e7          	jalr	-636(ra) # 60a <putc>
      state = 0;
 88e:	4981                	li	s3,0
 890:	b565                	j	738 <vprintf+0x60>
        s = va_arg(ap, char*);
 892:	8b4a                	mv	s6,s2
      state = 0;
 894:	4981                	li	s3,0
 896:	b54d                	j	738 <vprintf+0x60>
    }
  }
}
 898:	70e6                	ld	ra,120(sp)
 89a:	7446                	ld	s0,112(sp)
 89c:	74a6                	ld	s1,104(sp)
 89e:	7906                	ld	s2,96(sp)
 8a0:	69e6                	ld	s3,88(sp)
 8a2:	6a46                	ld	s4,80(sp)
 8a4:	6aa6                	ld	s5,72(sp)
 8a6:	6b06                	ld	s6,64(sp)
 8a8:	7be2                	ld	s7,56(sp)
 8aa:	7c42                	ld	s8,48(sp)
 8ac:	7ca2                	ld	s9,40(sp)
 8ae:	7d02                	ld	s10,32(sp)
 8b0:	6de2                	ld	s11,24(sp)
 8b2:	6109                	addi	sp,sp,128
 8b4:	8082                	ret

00000000000008b6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8b6:	715d                	addi	sp,sp,-80
 8b8:	ec06                	sd	ra,24(sp)
 8ba:	e822                	sd	s0,16(sp)
 8bc:	1000                	addi	s0,sp,32
 8be:	e010                	sd	a2,0(s0)
 8c0:	e414                	sd	a3,8(s0)
 8c2:	e818                	sd	a4,16(s0)
 8c4:	ec1c                	sd	a5,24(s0)
 8c6:	03043023          	sd	a6,32(s0)
 8ca:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8ce:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8d2:	8622                	mv	a2,s0
 8d4:	00000097          	auipc	ra,0x0
 8d8:	e04080e7          	jalr	-508(ra) # 6d8 <vprintf>
}
 8dc:	60e2                	ld	ra,24(sp)
 8de:	6442                	ld	s0,16(sp)
 8e0:	6161                	addi	sp,sp,80
 8e2:	8082                	ret

00000000000008e4 <printf>:

void
printf(const char *fmt, ...)
{
 8e4:	711d                	addi	sp,sp,-96
 8e6:	ec06                	sd	ra,24(sp)
 8e8:	e822                	sd	s0,16(sp)
 8ea:	1000                	addi	s0,sp,32
 8ec:	e40c                	sd	a1,8(s0)
 8ee:	e810                	sd	a2,16(s0)
 8f0:	ec14                	sd	a3,24(s0)
 8f2:	f018                	sd	a4,32(s0)
 8f4:	f41c                	sd	a5,40(s0)
 8f6:	03043823          	sd	a6,48(s0)
 8fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8fe:	00840613          	addi	a2,s0,8
 902:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 906:	85aa                	mv	a1,a0
 908:	4505                	li	a0,1
 90a:	00000097          	auipc	ra,0x0
 90e:	dce080e7          	jalr	-562(ra) # 6d8 <vprintf>
}
 912:	60e2                	ld	ra,24(sp)
 914:	6442                	ld	s0,16(sp)
 916:	6125                	addi	sp,sp,96
 918:	8082                	ret

000000000000091a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 91a:	1141                	addi	sp,sp,-16
 91c:	e422                	sd	s0,8(sp)
 91e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 920:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 924:	00000797          	auipc	a5,0x0
 928:	6dc7b783          	ld	a5,1756(a5) # 1000 <freep>
 92c:	a02d                	j	956 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 92e:	4618                	lw	a4,8(a2)
 930:	9f2d                	addw	a4,a4,a1
 932:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 936:	6398                	ld	a4,0(a5)
 938:	6310                	ld	a2,0(a4)
 93a:	a83d                	j	978 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 93c:	ff852703          	lw	a4,-8(a0)
 940:	9f31                	addw	a4,a4,a2
 942:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 944:	ff053683          	ld	a3,-16(a0)
 948:	a091                	j	98c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 94a:	6398                	ld	a4,0(a5)
 94c:	00e7e463          	bltu	a5,a4,954 <free+0x3a>
 950:	00e6ea63          	bltu	a3,a4,964 <free+0x4a>
{
 954:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 956:	fed7fae3          	bgeu	a5,a3,94a <free+0x30>
 95a:	6398                	ld	a4,0(a5)
 95c:	00e6e463          	bltu	a3,a4,964 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 960:	fee7eae3          	bltu	a5,a4,954 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 964:	ff852583          	lw	a1,-8(a0)
 968:	6390                	ld	a2,0(a5)
 96a:	02059813          	slli	a6,a1,0x20
 96e:	01c85713          	srli	a4,a6,0x1c
 972:	9736                	add	a4,a4,a3
 974:	fae60de3          	beq	a2,a4,92e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 978:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 97c:	4790                	lw	a2,8(a5)
 97e:	02061593          	slli	a1,a2,0x20
 982:	01c5d713          	srli	a4,a1,0x1c
 986:	973e                	add	a4,a4,a5
 988:	fae68ae3          	beq	a3,a4,93c <free+0x22>
    p->s.ptr = bp->s.ptr;
 98c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 98e:	00000717          	auipc	a4,0x0
 992:	66f73923          	sd	a5,1650(a4) # 1000 <freep>
}
 996:	6422                	ld	s0,8(sp)
 998:	0141                	addi	sp,sp,16
 99a:	8082                	ret

000000000000099c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 99c:	7139                	addi	sp,sp,-64
 99e:	fc06                	sd	ra,56(sp)
 9a0:	f822                	sd	s0,48(sp)
 9a2:	f426                	sd	s1,40(sp)
 9a4:	f04a                	sd	s2,32(sp)
 9a6:	ec4e                	sd	s3,24(sp)
 9a8:	e852                	sd	s4,16(sp)
 9aa:	e456                	sd	s5,8(sp)
 9ac:	e05a                	sd	s6,0(sp)
 9ae:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9b0:	02051493          	slli	s1,a0,0x20
 9b4:	9081                	srli	s1,s1,0x20
 9b6:	04bd                	addi	s1,s1,15
 9b8:	8091                	srli	s1,s1,0x4
 9ba:	0014899b          	addiw	s3,s1,1
 9be:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9c0:	00000517          	auipc	a0,0x0
 9c4:	64053503          	ld	a0,1600(a0) # 1000 <freep>
 9c8:	c515                	beqz	a0,9f4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9cc:	4798                	lw	a4,8(a5)
 9ce:	02977f63          	bgeu	a4,s1,a0c <malloc+0x70>
 9d2:	8a4e                	mv	s4,s3
 9d4:	0009871b          	sext.w	a4,s3
 9d8:	6685                	lui	a3,0x1
 9da:	00d77363          	bgeu	a4,a3,9e0 <malloc+0x44>
 9de:	6a05                	lui	s4,0x1
 9e0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9e4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9e8:	00000917          	auipc	s2,0x0
 9ec:	61890913          	addi	s2,s2,1560 # 1000 <freep>
  if(p == (char*)-1)
 9f0:	5afd                	li	s5,-1
 9f2:	a895                	j	a66 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 9f4:	00000797          	auipc	a5,0x0
 9f8:	69c78793          	addi	a5,a5,1692 # 1090 <base>
 9fc:	00000717          	auipc	a4,0x0
 a00:	60f73223          	sd	a5,1540(a4) # 1000 <freep>
 a04:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a06:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a0a:	b7e1                	j	9d2 <malloc+0x36>
      if(p->s.size == nunits)
 a0c:	02e48c63          	beq	s1,a4,a44 <malloc+0xa8>
        p->s.size -= nunits;
 a10:	4137073b          	subw	a4,a4,s3
 a14:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a16:	02071693          	slli	a3,a4,0x20
 a1a:	01c6d713          	srli	a4,a3,0x1c
 a1e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a20:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a24:	00000717          	auipc	a4,0x0
 a28:	5ca73e23          	sd	a0,1500(a4) # 1000 <freep>
      return (void*)(p + 1);
 a2c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a30:	70e2                	ld	ra,56(sp)
 a32:	7442                	ld	s0,48(sp)
 a34:	74a2                	ld	s1,40(sp)
 a36:	7902                	ld	s2,32(sp)
 a38:	69e2                	ld	s3,24(sp)
 a3a:	6a42                	ld	s4,16(sp)
 a3c:	6aa2                	ld	s5,8(sp)
 a3e:	6b02                	ld	s6,0(sp)
 a40:	6121                	addi	sp,sp,64
 a42:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a44:	6398                	ld	a4,0(a5)
 a46:	e118                	sd	a4,0(a0)
 a48:	bff1                	j	a24 <malloc+0x88>
  hp->s.size = nu;
 a4a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a4e:	0541                	addi	a0,a0,16
 a50:	00000097          	auipc	ra,0x0
 a54:	eca080e7          	jalr	-310(ra) # 91a <free>
  return freep;
 a58:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a5c:	d971                	beqz	a0,a30 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a5e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a60:	4798                	lw	a4,8(a5)
 a62:	fa9775e3          	bgeu	a4,s1,a0c <malloc+0x70>
    if(p == freep)
 a66:	00093703          	ld	a4,0(s2)
 a6a:	853e                	mv	a0,a5
 a6c:	fef719e3          	bne	a4,a5,a5e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a70:	8552                	mv	a0,s4
 a72:	00000097          	auipc	ra,0x0
 a76:	b60080e7          	jalr	-1184(ra) # 5d2 <sbrk>
  if(p == (char*)-1)
 a7a:	fd5518e3          	bne	a0,s5,a4a <malloc+0xae>
        return 0;
 a7e:	4501                	li	a0,0
 a80:	bf45                	j	a30 <malloc+0x94>
