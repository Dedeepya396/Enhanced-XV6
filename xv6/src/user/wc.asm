
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4981                	li	s3,0
  l = w = c = 0;
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  2e:	00001d97          	auipc	s11,0x1
  32:	fe3d8d93          	addi	s11,s11,-29 # 1011 <buf+0x1>
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	928a0a13          	addi	s4,s4,-1752 # 960 <malloc+0xf2>
        inword = 0;
  40:	4b01                	li	s6,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	1fe080e7          	jalr	510(ra) # 244 <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	89da                	mv	s3,s6
    for(i=0; i<n; i++){
  52:	0485                	addi	s1,s1,1
  54:	01248d63          	beq	s1,s2,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2b85                	addiw	s7,s7,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0997e3          	bnez	s3,52 <wc+0x52>
        w++;
  68:	2c05                	addiw	s8,s8,1
        inword = 1;
  6a:	4985                	li	s3,1
  6c:	b7dd                	j	52 <wc+0x52>
      c++;
  6e:	01ac8cbb          	addw	s9,s9,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	00001597          	auipc	a1,0x1
  7a:	f9a58593          	addi	a1,a1,-102 # 1010 <buf>
  7e:	f8843503          	ld	a0,-120(s0)
  82:	00000097          	auipc	ra,0x0
  86:	3b2080e7          	jalr	946(ra) # 434 <read>
  8a:	00a05f63          	blez	a0,a8 <wc+0xa8>
    for(i=0; i<n; i++){
  8e:	00001497          	auipc	s1,0x1
  92:	f8248493          	addi	s1,s1,-126 # 1010 <buf>
  96:	00050d1b          	sext.w	s10,a0
  9a:	fff5091b          	addiw	s2,a0,-1
  9e:	1902                	slli	s2,s2,0x20
  a0:	02095913          	srli	s2,s2,0x20
  a4:	996e                	add	s2,s2,s11
  a6:	bf4d                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  a8:	02054e63          	bltz	a0,e4 <wc+0xe4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  ac:	f8043703          	ld	a4,-128(s0)
  b0:	86e6                	mv	a3,s9
  b2:	8662                	mv	a2,s8
  b4:	85de                	mv	a1,s7
  b6:	00001517          	auipc	a0,0x1
  ba:	8c250513          	addi	a0,a0,-1854 # 978 <malloc+0x10a>
  be:	00000097          	auipc	ra,0x0
  c2:	6f8080e7          	jalr	1784(ra) # 7b6 <printf>
}
  c6:	70e6                	ld	ra,120(sp)
  c8:	7446                	ld	s0,112(sp)
  ca:	74a6                	ld	s1,104(sp)
  cc:	7906                	ld	s2,96(sp)
  ce:	69e6                	ld	s3,88(sp)
  d0:	6a46                	ld	s4,80(sp)
  d2:	6aa6                	ld	s5,72(sp)
  d4:	6b06                	ld	s6,64(sp)
  d6:	7be2                	ld	s7,56(sp)
  d8:	7c42                	ld	s8,48(sp)
  da:	7ca2                	ld	s9,40(sp)
  dc:	7d02                	ld	s10,32(sp)
  de:	6de2                	ld	s11,24(sp)
  e0:	6109                	addi	sp,sp,128
  e2:	8082                	ret
    printf("wc: read error\n");
  e4:	00001517          	auipc	a0,0x1
  e8:	88450513          	addi	a0,a0,-1916 # 968 <malloc+0xfa>
  ec:	00000097          	auipc	ra,0x0
  f0:	6ca080e7          	jalr	1738(ra) # 7b6 <printf>
    exit(1);
  f4:	4505                	li	a0,1
  f6:	00000097          	auipc	ra,0x0
  fa:	326080e7          	jalr	806(ra) # 41c <exit>

00000000000000fe <main>:

int
main(int argc, char *argv[])
{
  fe:	7179                	addi	sp,sp,-48
 100:	f406                	sd	ra,40(sp)
 102:	f022                	sd	s0,32(sp)
 104:	ec26                	sd	s1,24(sp)
 106:	e84a                	sd	s2,16(sp)
 108:	e44e                	sd	s3,8(sp)
 10a:	e052                	sd	s4,0(sp)
 10c:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
 10e:	4785                	li	a5,1
 110:	04a7d763          	bge	a5,a0,15e <main+0x60>
 114:	00858493          	addi	s1,a1,8
 118:	ffe5099b          	addiw	s3,a0,-2
 11c:	02099793          	slli	a5,s3,0x20
 120:	01d7d993          	srli	s3,a5,0x1d
 124:	05c1                	addi	a1,a1,16
 126:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 128:	4581                	li	a1,0
 12a:	6088                	ld	a0,0(s1)
 12c:	00000097          	auipc	ra,0x0
 130:	330080e7          	jalr	816(ra) # 45c <open>
 134:	892a                	mv	s2,a0
 136:	04054263          	bltz	a0,17a <main+0x7c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 13a:	608c                	ld	a1,0(s1)
 13c:	00000097          	auipc	ra,0x0
 140:	ec4080e7          	jalr	-316(ra) # 0 <wc>
    close(fd);
 144:	854a                	mv	a0,s2
 146:	00000097          	auipc	ra,0x0
 14a:	2fe080e7          	jalr	766(ra) # 444 <close>
  for(i = 1; i < argc; i++){
 14e:	04a1                	addi	s1,s1,8
 150:	fd349ce3          	bne	s1,s3,128 <main+0x2a>
  }
  exit(0);
 154:	4501                	li	a0,0
 156:	00000097          	auipc	ra,0x0
 15a:	2c6080e7          	jalr	710(ra) # 41c <exit>
    wc(0, "");
 15e:	00001597          	auipc	a1,0x1
 162:	82a58593          	addi	a1,a1,-2006 # 988 <malloc+0x11a>
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	e98080e7          	jalr	-360(ra) # 0 <wc>
    exit(0);
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	2aa080e7          	jalr	682(ra) # 41c <exit>
      printf("wc: cannot open %s\n", argv[i]);
 17a:	608c                	ld	a1,0(s1)
 17c:	00001517          	auipc	a0,0x1
 180:	81450513          	addi	a0,a0,-2028 # 990 <malloc+0x122>
 184:	00000097          	auipc	ra,0x0
 188:	632080e7          	jalr	1586(ra) # 7b6 <printf>
      exit(1);
 18c:	4505                	li	a0,1
 18e:	00000097          	auipc	ra,0x0
 192:	28e080e7          	jalr	654(ra) # 41c <exit>

0000000000000196 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 196:	1141                	addi	sp,sp,-16
 198:	e406                	sd	ra,8(sp)
 19a:	e022                	sd	s0,0(sp)
 19c:	0800                	addi	s0,sp,16
  extern int main();
  main();
 19e:	00000097          	auipc	ra,0x0
 1a2:	f60080e7          	jalr	-160(ra) # fe <main>
  exit(0);
 1a6:	4501                	li	a0,0
 1a8:	00000097          	auipc	ra,0x0
 1ac:	274080e7          	jalr	628(ra) # 41c <exit>

00000000000001b0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1b6:	87aa                	mv	a5,a0
 1b8:	0585                	addi	a1,a1,1
 1ba:	0785                	addi	a5,a5,1
 1bc:	fff5c703          	lbu	a4,-1(a1)
 1c0:	fee78fa3          	sb	a4,-1(a5)
 1c4:	fb75                	bnez	a4,1b8 <strcpy+0x8>
    ;
  return os;
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret

00000000000001cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cb91                	beqz	a5,1ea <strcmp+0x1e>
 1d8:	0005c703          	lbu	a4,0(a1)
 1dc:	00f71763          	bne	a4,a5,1ea <strcmp+0x1e>
    p++, q++;
 1e0:	0505                	addi	a0,a0,1
 1e2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	fbe5                	bnez	a5,1d8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ea:	0005c503          	lbu	a0,0(a1)
}
 1ee:	40a7853b          	subw	a0,a5,a0
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret

00000000000001f8 <strlen>:

uint
strlen(const char *s)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1fe:	00054783          	lbu	a5,0(a0)
 202:	cf91                	beqz	a5,21e <strlen+0x26>
 204:	0505                	addi	a0,a0,1
 206:	87aa                	mv	a5,a0
 208:	4685                	li	a3,1
 20a:	9e89                	subw	a3,a3,a0
 20c:	00f6853b          	addw	a0,a3,a5
 210:	0785                	addi	a5,a5,1
 212:	fff7c703          	lbu	a4,-1(a5)
 216:	fb7d                	bnez	a4,20c <strlen+0x14>
    ;
  return n;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret
  for(n = 0; s[n]; n++)
 21e:	4501                	li	a0,0
 220:	bfe5                	j	218 <strlen+0x20>

0000000000000222 <memset>:

void*
memset(void *dst, int c, uint n)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 228:	ca19                	beqz	a2,23e <memset+0x1c>
 22a:	87aa                	mv	a5,a0
 22c:	1602                	slli	a2,a2,0x20
 22e:	9201                	srli	a2,a2,0x20
 230:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 234:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 238:	0785                	addi	a5,a5,1
 23a:	fee79de3          	bne	a5,a4,234 <memset+0x12>
  }
  return dst;
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret

0000000000000244 <strchr>:

char*
strchr(const char *s, char c)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  for(; *s; s++)
 24a:	00054783          	lbu	a5,0(a0)
 24e:	cb99                	beqz	a5,264 <strchr+0x20>
    if(*s == c)
 250:	00f58763          	beq	a1,a5,25e <strchr+0x1a>
  for(; *s; s++)
 254:	0505                	addi	a0,a0,1
 256:	00054783          	lbu	a5,0(a0)
 25a:	fbfd                	bnez	a5,250 <strchr+0xc>
      return (char*)s;
  return 0;
 25c:	4501                	li	a0,0
}
 25e:	6422                	ld	s0,8(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret
  return 0;
 264:	4501                	li	a0,0
 266:	bfe5                	j	25e <strchr+0x1a>

0000000000000268 <gets>:

char*
gets(char *buf, int max)
{
 268:	711d                	addi	sp,sp,-96
 26a:	ec86                	sd	ra,88(sp)
 26c:	e8a2                	sd	s0,80(sp)
 26e:	e4a6                	sd	s1,72(sp)
 270:	e0ca                	sd	s2,64(sp)
 272:	fc4e                	sd	s3,56(sp)
 274:	f852                	sd	s4,48(sp)
 276:	f456                	sd	s5,40(sp)
 278:	f05a                	sd	s6,32(sp)
 27a:	ec5e                	sd	s7,24(sp)
 27c:	1080                	addi	s0,sp,96
 27e:	8baa                	mv	s7,a0
 280:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 282:	892a                	mv	s2,a0
 284:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 286:	4aa9                	li	s5,10
 288:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 28a:	89a6                	mv	s3,s1
 28c:	2485                	addiw	s1,s1,1
 28e:	0344d863          	bge	s1,s4,2be <gets+0x56>
    cc = read(0, &c, 1);
 292:	4605                	li	a2,1
 294:	faf40593          	addi	a1,s0,-81
 298:	4501                	li	a0,0
 29a:	00000097          	auipc	ra,0x0
 29e:	19a080e7          	jalr	410(ra) # 434 <read>
    if(cc < 1)
 2a2:	00a05e63          	blez	a0,2be <gets+0x56>
    buf[i++] = c;
 2a6:	faf44783          	lbu	a5,-81(s0)
 2aa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ae:	01578763          	beq	a5,s5,2bc <gets+0x54>
 2b2:	0905                	addi	s2,s2,1
 2b4:	fd679be3          	bne	a5,s6,28a <gets+0x22>
  for(i=0; i+1 < max; ){
 2b8:	89a6                	mv	s3,s1
 2ba:	a011                	j	2be <gets+0x56>
 2bc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2be:	99de                	add	s3,s3,s7
 2c0:	00098023          	sb	zero,0(s3)
  return buf;
}
 2c4:	855e                	mv	a0,s7
 2c6:	60e6                	ld	ra,88(sp)
 2c8:	6446                	ld	s0,80(sp)
 2ca:	64a6                	ld	s1,72(sp)
 2cc:	6906                	ld	s2,64(sp)
 2ce:	79e2                	ld	s3,56(sp)
 2d0:	7a42                	ld	s4,48(sp)
 2d2:	7aa2                	ld	s5,40(sp)
 2d4:	7b02                	ld	s6,32(sp)
 2d6:	6be2                	ld	s7,24(sp)
 2d8:	6125                	addi	sp,sp,96
 2da:	8082                	ret

00000000000002dc <stat>:

int
stat(const char *n, struct stat *st)
{
 2dc:	1101                	addi	sp,sp,-32
 2de:	ec06                	sd	ra,24(sp)
 2e0:	e822                	sd	s0,16(sp)
 2e2:	e426                	sd	s1,8(sp)
 2e4:	e04a                	sd	s2,0(sp)
 2e6:	1000                	addi	s0,sp,32
 2e8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ea:	4581                	li	a1,0
 2ec:	00000097          	auipc	ra,0x0
 2f0:	170080e7          	jalr	368(ra) # 45c <open>
  if(fd < 0)
 2f4:	02054563          	bltz	a0,31e <stat+0x42>
 2f8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2fa:	85ca                	mv	a1,s2
 2fc:	00000097          	auipc	ra,0x0
 300:	178080e7          	jalr	376(ra) # 474 <fstat>
 304:	892a                	mv	s2,a0
  close(fd);
 306:	8526                	mv	a0,s1
 308:	00000097          	auipc	ra,0x0
 30c:	13c080e7          	jalr	316(ra) # 444 <close>
  return r;
}
 310:	854a                	mv	a0,s2
 312:	60e2                	ld	ra,24(sp)
 314:	6442                	ld	s0,16(sp)
 316:	64a2                	ld	s1,8(sp)
 318:	6902                	ld	s2,0(sp)
 31a:	6105                	addi	sp,sp,32
 31c:	8082                	ret
    return -1;
 31e:	597d                	li	s2,-1
 320:	bfc5                	j	310 <stat+0x34>

0000000000000322 <atoi>:

int
atoi(const char *s)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 328:	00054683          	lbu	a3,0(a0)
 32c:	fd06879b          	addiw	a5,a3,-48
 330:	0ff7f793          	zext.b	a5,a5
 334:	4625                	li	a2,9
 336:	02f66863          	bltu	a2,a5,366 <atoi+0x44>
 33a:	872a                	mv	a4,a0
  n = 0;
 33c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 33e:	0705                	addi	a4,a4,1
 340:	0025179b          	slliw	a5,a0,0x2
 344:	9fa9                	addw	a5,a5,a0
 346:	0017979b          	slliw	a5,a5,0x1
 34a:	9fb5                	addw	a5,a5,a3
 34c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 350:	00074683          	lbu	a3,0(a4)
 354:	fd06879b          	addiw	a5,a3,-48
 358:	0ff7f793          	zext.b	a5,a5
 35c:	fef671e3          	bgeu	a2,a5,33e <atoi+0x1c>
  return n;
}
 360:	6422                	ld	s0,8(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret
  n = 0;
 366:	4501                	li	a0,0
 368:	bfe5                	j	360 <atoi+0x3e>

000000000000036a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 370:	02b57463          	bgeu	a0,a1,398 <memmove+0x2e>
    while(n-- > 0)
 374:	00c05f63          	blez	a2,392 <memmove+0x28>
 378:	1602                	slli	a2,a2,0x20
 37a:	9201                	srli	a2,a2,0x20
 37c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 380:	872a                	mv	a4,a0
      *dst++ = *src++;
 382:	0585                	addi	a1,a1,1
 384:	0705                	addi	a4,a4,1
 386:	fff5c683          	lbu	a3,-1(a1)
 38a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 38e:	fee79ae3          	bne	a5,a4,382 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
    dst += n;
 398:	00c50733          	add	a4,a0,a2
    src += n;
 39c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 39e:	fec05ae3          	blez	a2,392 <memmove+0x28>
 3a2:	fff6079b          	addiw	a5,a2,-1
 3a6:	1782                	slli	a5,a5,0x20
 3a8:	9381                	srli	a5,a5,0x20
 3aa:	fff7c793          	not	a5,a5
 3ae:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3b0:	15fd                	addi	a1,a1,-1
 3b2:	177d                	addi	a4,a4,-1
 3b4:	0005c683          	lbu	a3,0(a1)
 3b8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3bc:	fee79ae3          	bne	a5,a4,3b0 <memmove+0x46>
 3c0:	bfc9                	j	392 <memmove+0x28>

00000000000003c2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3c2:	1141                	addi	sp,sp,-16
 3c4:	e422                	sd	s0,8(sp)
 3c6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3c8:	ca05                	beqz	a2,3f8 <memcmp+0x36>
 3ca:	fff6069b          	addiw	a3,a2,-1
 3ce:	1682                	slli	a3,a3,0x20
 3d0:	9281                	srli	a3,a3,0x20
 3d2:	0685                	addi	a3,a3,1
 3d4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3d6:	00054783          	lbu	a5,0(a0)
 3da:	0005c703          	lbu	a4,0(a1)
 3de:	00e79863          	bne	a5,a4,3ee <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3e2:	0505                	addi	a0,a0,1
    p2++;
 3e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3e6:	fed518e3          	bne	a0,a3,3d6 <memcmp+0x14>
  }
  return 0;
 3ea:	4501                	li	a0,0
 3ec:	a019                	j	3f2 <memcmp+0x30>
      return *p1 - *p2;
 3ee:	40e7853b          	subw	a0,a5,a4
}
 3f2:	6422                	ld	s0,8(sp)
 3f4:	0141                	addi	sp,sp,16
 3f6:	8082                	ret
  return 0;
 3f8:	4501                	li	a0,0
 3fa:	bfe5                	j	3f2 <memcmp+0x30>

00000000000003fc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3fc:	1141                	addi	sp,sp,-16
 3fe:	e406                	sd	ra,8(sp)
 400:	e022                	sd	s0,0(sp)
 402:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 404:	00000097          	auipc	ra,0x0
 408:	f66080e7          	jalr	-154(ra) # 36a <memmove>
}
 40c:	60a2                	ld	ra,8(sp)
 40e:	6402                	ld	s0,0(sp)
 410:	0141                	addi	sp,sp,16
 412:	8082                	ret

0000000000000414 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 414:	4885                	li	a7,1
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <exit>:
.global exit
exit:
 li a7, SYS_exit
 41c:	4889                	li	a7,2
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <wait>:
.global wait
wait:
 li a7, SYS_wait
 424:	488d                	li	a7,3
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 42c:	4891                	li	a7,4
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <read>:
.global read
read:
 li a7, SYS_read
 434:	4895                	li	a7,5
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <write>:
.global write
write:
 li a7, SYS_write
 43c:	48c1                	li	a7,16
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <close>:
.global close
close:
 li a7, SYS_close
 444:	48d5                	li	a7,21
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <kill>:
.global kill
kill:
 li a7, SYS_kill
 44c:	4899                	li	a7,6
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <exec>:
.global exec
exec:
 li a7, SYS_exec
 454:	489d                	li	a7,7
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <open>:
.global open
open:
 li a7, SYS_open
 45c:	48bd                	li	a7,15
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 464:	48c5                	li	a7,17
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 46c:	48c9                	li	a7,18
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 474:	48a1                	li	a7,8
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <link>:
.global link
link:
 li a7, SYS_link
 47c:	48cd                	li	a7,19
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 484:	48d1                	li	a7,20
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 48c:	48a5                	li	a7,9
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <dup>:
.global dup
dup:
 li a7, SYS_dup
 494:	48a9                	li	a7,10
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 49c:	48ad                	li	a7,11
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4a4:	48b1                	li	a7,12
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4ac:	48b5                	li	a7,13
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4b4:	48b9                	li	a7,14
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 4bc:	48d9                	li	a7,22
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <getcount>:
.global getcount
getcount:
 li a7, SYS_getcount
 4c4:	48dd                	li	a7,23
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 4cc:	48e5                	li	a7,25
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 4d4:	48e9                	li	a7,26
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4dc:	1101                	addi	sp,sp,-32
 4de:	ec06                	sd	ra,24(sp)
 4e0:	e822                	sd	s0,16(sp)
 4e2:	1000                	addi	s0,sp,32
 4e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4e8:	4605                	li	a2,1
 4ea:	fef40593          	addi	a1,s0,-17
 4ee:	00000097          	auipc	ra,0x0
 4f2:	f4e080e7          	jalr	-178(ra) # 43c <write>
}
 4f6:	60e2                	ld	ra,24(sp)
 4f8:	6442                	ld	s0,16(sp)
 4fa:	6105                	addi	sp,sp,32
 4fc:	8082                	ret

00000000000004fe <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4fe:	7139                	addi	sp,sp,-64
 500:	fc06                	sd	ra,56(sp)
 502:	f822                	sd	s0,48(sp)
 504:	f426                	sd	s1,40(sp)
 506:	f04a                	sd	s2,32(sp)
 508:	ec4e                	sd	s3,24(sp)
 50a:	0080                	addi	s0,sp,64
 50c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 50e:	c299                	beqz	a3,514 <printint+0x16>
 510:	0805c963          	bltz	a1,5a2 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 514:	2581                	sext.w	a1,a1
  neg = 0;
 516:	4881                	li	a7,0
 518:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 51c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 51e:	2601                	sext.w	a2,a2
 520:	00000517          	auipc	a0,0x0
 524:	4e850513          	addi	a0,a0,1256 # a08 <digits>
 528:	883a                	mv	a6,a4
 52a:	2705                	addiw	a4,a4,1
 52c:	02c5f7bb          	remuw	a5,a1,a2
 530:	1782                	slli	a5,a5,0x20
 532:	9381                	srli	a5,a5,0x20
 534:	97aa                	add	a5,a5,a0
 536:	0007c783          	lbu	a5,0(a5)
 53a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 53e:	0005879b          	sext.w	a5,a1
 542:	02c5d5bb          	divuw	a1,a1,a2
 546:	0685                	addi	a3,a3,1
 548:	fec7f0e3          	bgeu	a5,a2,528 <printint+0x2a>
  if(neg)
 54c:	00088c63          	beqz	a7,564 <printint+0x66>
    buf[i++] = '-';
 550:	fd070793          	addi	a5,a4,-48
 554:	00878733          	add	a4,a5,s0
 558:	02d00793          	li	a5,45
 55c:	fef70823          	sb	a5,-16(a4)
 560:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 564:	02e05863          	blez	a4,594 <printint+0x96>
 568:	fc040793          	addi	a5,s0,-64
 56c:	00e78933          	add	s2,a5,a4
 570:	fff78993          	addi	s3,a5,-1
 574:	99ba                	add	s3,s3,a4
 576:	377d                	addiw	a4,a4,-1
 578:	1702                	slli	a4,a4,0x20
 57a:	9301                	srli	a4,a4,0x20
 57c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 580:	fff94583          	lbu	a1,-1(s2)
 584:	8526                	mv	a0,s1
 586:	00000097          	auipc	ra,0x0
 58a:	f56080e7          	jalr	-170(ra) # 4dc <putc>
  while(--i >= 0)
 58e:	197d                	addi	s2,s2,-1
 590:	ff3918e3          	bne	s2,s3,580 <printint+0x82>
}
 594:	70e2                	ld	ra,56(sp)
 596:	7442                	ld	s0,48(sp)
 598:	74a2                	ld	s1,40(sp)
 59a:	7902                	ld	s2,32(sp)
 59c:	69e2                	ld	s3,24(sp)
 59e:	6121                	addi	sp,sp,64
 5a0:	8082                	ret
    x = -xx;
 5a2:	40b005bb          	negw	a1,a1
    neg = 1;
 5a6:	4885                	li	a7,1
    x = -xx;
 5a8:	bf85                	j	518 <printint+0x1a>

00000000000005aa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5aa:	7119                	addi	sp,sp,-128
 5ac:	fc86                	sd	ra,120(sp)
 5ae:	f8a2                	sd	s0,112(sp)
 5b0:	f4a6                	sd	s1,104(sp)
 5b2:	f0ca                	sd	s2,96(sp)
 5b4:	ecce                	sd	s3,88(sp)
 5b6:	e8d2                	sd	s4,80(sp)
 5b8:	e4d6                	sd	s5,72(sp)
 5ba:	e0da                	sd	s6,64(sp)
 5bc:	fc5e                	sd	s7,56(sp)
 5be:	f862                	sd	s8,48(sp)
 5c0:	f466                	sd	s9,40(sp)
 5c2:	f06a                	sd	s10,32(sp)
 5c4:	ec6e                	sd	s11,24(sp)
 5c6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5c8:	0005c903          	lbu	s2,0(a1)
 5cc:	18090f63          	beqz	s2,76a <vprintf+0x1c0>
 5d0:	8aaa                	mv	s5,a0
 5d2:	8b32                	mv	s6,a2
 5d4:	00158493          	addi	s1,a1,1
  state = 0;
 5d8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5da:	02500a13          	li	s4,37
 5de:	4c55                	li	s8,21
 5e0:	00000c97          	auipc	s9,0x0
 5e4:	3d0c8c93          	addi	s9,s9,976 # 9b0 <malloc+0x142>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5e8:	02800d93          	li	s11,40
  putc(fd, 'x');
 5ec:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ee:	00000b97          	auipc	s7,0x0
 5f2:	41ab8b93          	addi	s7,s7,1050 # a08 <digits>
 5f6:	a839                	j	614 <vprintf+0x6a>
        putc(fd, c);
 5f8:	85ca                	mv	a1,s2
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	ee0080e7          	jalr	-288(ra) # 4dc <putc>
 604:	a019                	j	60a <vprintf+0x60>
    } else if(state == '%'){
 606:	01498d63          	beq	s3,s4,620 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 60a:	0485                	addi	s1,s1,1
 60c:	fff4c903          	lbu	s2,-1(s1)
 610:	14090d63          	beqz	s2,76a <vprintf+0x1c0>
    if(state == 0){
 614:	fe0999e3          	bnez	s3,606 <vprintf+0x5c>
      if(c == '%'){
 618:	ff4910e3          	bne	s2,s4,5f8 <vprintf+0x4e>
        state = '%';
 61c:	89d2                	mv	s3,s4
 61e:	b7f5                	j	60a <vprintf+0x60>
      if(c == 'd'){
 620:	11490c63          	beq	s2,s4,738 <vprintf+0x18e>
 624:	f9d9079b          	addiw	a5,s2,-99
 628:	0ff7f793          	zext.b	a5,a5
 62c:	10fc6e63          	bltu	s8,a5,748 <vprintf+0x19e>
 630:	f9d9079b          	addiw	a5,s2,-99
 634:	0ff7f713          	zext.b	a4,a5
 638:	10ec6863          	bltu	s8,a4,748 <vprintf+0x19e>
 63c:	00271793          	slli	a5,a4,0x2
 640:	97e6                	add	a5,a5,s9
 642:	439c                	lw	a5,0(a5)
 644:	97e6                	add	a5,a5,s9
 646:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 648:	008b0913          	addi	s2,s6,8
 64c:	4685                	li	a3,1
 64e:	4629                	li	a2,10
 650:	000b2583          	lw	a1,0(s6)
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	ea8080e7          	jalr	-344(ra) # 4fe <printint>
 65e:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 660:	4981                	li	s3,0
 662:	b765                	j	60a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 664:	008b0913          	addi	s2,s6,8
 668:	4681                	li	a3,0
 66a:	4629                	li	a2,10
 66c:	000b2583          	lw	a1,0(s6)
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e8c080e7          	jalr	-372(ra) # 4fe <printint>
 67a:	8b4a                	mv	s6,s2
      state = 0;
 67c:	4981                	li	s3,0
 67e:	b771                	j	60a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 680:	008b0913          	addi	s2,s6,8
 684:	4681                	li	a3,0
 686:	866a                	mv	a2,s10
 688:	000b2583          	lw	a1,0(s6)
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	e70080e7          	jalr	-400(ra) # 4fe <printint>
 696:	8b4a                	mv	s6,s2
      state = 0;
 698:	4981                	li	s3,0
 69a:	bf85                	j	60a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 69c:	008b0793          	addi	a5,s6,8
 6a0:	f8f43423          	sd	a5,-120(s0)
 6a4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6a8:	03000593          	li	a1,48
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	e2e080e7          	jalr	-466(ra) # 4dc <putc>
  putc(fd, 'x');
 6b6:	07800593          	li	a1,120
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e20080e7          	jalr	-480(ra) # 4dc <putc>
 6c4:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c6:	03c9d793          	srli	a5,s3,0x3c
 6ca:	97de                	add	a5,a5,s7
 6cc:	0007c583          	lbu	a1,0(a5)
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	e0a080e7          	jalr	-502(ra) # 4dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6da:	0992                	slli	s3,s3,0x4
 6dc:	397d                	addiw	s2,s2,-1
 6de:	fe0914e3          	bnez	s2,6c6 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6e2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b70d                	j	60a <vprintf+0x60>
        s = va_arg(ap, char*);
 6ea:	008b0913          	addi	s2,s6,8
 6ee:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6f2:	02098163          	beqz	s3,714 <vprintf+0x16a>
        while(*s != 0){
 6f6:	0009c583          	lbu	a1,0(s3)
 6fa:	c5ad                	beqz	a1,764 <vprintf+0x1ba>
          putc(fd, *s);
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	dde080e7          	jalr	-546(ra) # 4dc <putc>
          s++;
 706:	0985                	addi	s3,s3,1
        while(*s != 0){
 708:	0009c583          	lbu	a1,0(s3)
 70c:	f9e5                	bnez	a1,6fc <vprintf+0x152>
        s = va_arg(ap, char*);
 70e:	8b4a                	mv	s6,s2
      state = 0;
 710:	4981                	li	s3,0
 712:	bde5                	j	60a <vprintf+0x60>
          s = "(null)";
 714:	00000997          	auipc	s3,0x0
 718:	29498993          	addi	s3,s3,660 # 9a8 <malloc+0x13a>
        while(*s != 0){
 71c:	85ee                	mv	a1,s11
 71e:	bff9                	j	6fc <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 720:	008b0913          	addi	s2,s6,8
 724:	000b4583          	lbu	a1,0(s6)
 728:	8556                	mv	a0,s5
 72a:	00000097          	auipc	ra,0x0
 72e:	db2080e7          	jalr	-590(ra) # 4dc <putc>
 732:	8b4a                	mv	s6,s2
      state = 0;
 734:	4981                	li	s3,0
 736:	bdd1                	j	60a <vprintf+0x60>
        putc(fd, c);
 738:	85d2                	mv	a1,s4
 73a:	8556                	mv	a0,s5
 73c:	00000097          	auipc	ra,0x0
 740:	da0080e7          	jalr	-608(ra) # 4dc <putc>
      state = 0;
 744:	4981                	li	s3,0
 746:	b5d1                	j	60a <vprintf+0x60>
        putc(fd, '%');
 748:	85d2                	mv	a1,s4
 74a:	8556                	mv	a0,s5
 74c:	00000097          	auipc	ra,0x0
 750:	d90080e7          	jalr	-624(ra) # 4dc <putc>
        putc(fd, c);
 754:	85ca                	mv	a1,s2
 756:	8556                	mv	a0,s5
 758:	00000097          	auipc	ra,0x0
 75c:	d84080e7          	jalr	-636(ra) # 4dc <putc>
      state = 0;
 760:	4981                	li	s3,0
 762:	b565                	j	60a <vprintf+0x60>
        s = va_arg(ap, char*);
 764:	8b4a                	mv	s6,s2
      state = 0;
 766:	4981                	li	s3,0
 768:	b54d                	j	60a <vprintf+0x60>
    }
  }
}
 76a:	70e6                	ld	ra,120(sp)
 76c:	7446                	ld	s0,112(sp)
 76e:	74a6                	ld	s1,104(sp)
 770:	7906                	ld	s2,96(sp)
 772:	69e6                	ld	s3,88(sp)
 774:	6a46                	ld	s4,80(sp)
 776:	6aa6                	ld	s5,72(sp)
 778:	6b06                	ld	s6,64(sp)
 77a:	7be2                	ld	s7,56(sp)
 77c:	7c42                	ld	s8,48(sp)
 77e:	7ca2                	ld	s9,40(sp)
 780:	7d02                	ld	s10,32(sp)
 782:	6de2                	ld	s11,24(sp)
 784:	6109                	addi	sp,sp,128
 786:	8082                	ret

0000000000000788 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 788:	715d                	addi	sp,sp,-80
 78a:	ec06                	sd	ra,24(sp)
 78c:	e822                	sd	s0,16(sp)
 78e:	1000                	addi	s0,sp,32
 790:	e010                	sd	a2,0(s0)
 792:	e414                	sd	a3,8(s0)
 794:	e818                	sd	a4,16(s0)
 796:	ec1c                	sd	a5,24(s0)
 798:	03043023          	sd	a6,32(s0)
 79c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a4:	8622                	mv	a2,s0
 7a6:	00000097          	auipc	ra,0x0
 7aa:	e04080e7          	jalr	-508(ra) # 5aa <vprintf>
}
 7ae:	60e2                	ld	ra,24(sp)
 7b0:	6442                	ld	s0,16(sp)
 7b2:	6161                	addi	sp,sp,80
 7b4:	8082                	ret

00000000000007b6 <printf>:

void
printf(const char *fmt, ...)
{
 7b6:	711d                	addi	sp,sp,-96
 7b8:	ec06                	sd	ra,24(sp)
 7ba:	e822                	sd	s0,16(sp)
 7bc:	1000                	addi	s0,sp,32
 7be:	e40c                	sd	a1,8(s0)
 7c0:	e810                	sd	a2,16(s0)
 7c2:	ec14                	sd	a3,24(s0)
 7c4:	f018                	sd	a4,32(s0)
 7c6:	f41c                	sd	a5,40(s0)
 7c8:	03043823          	sd	a6,48(s0)
 7cc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d0:	00840613          	addi	a2,s0,8
 7d4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d8:	85aa                	mv	a1,a0
 7da:	4505                	li	a0,1
 7dc:	00000097          	auipc	ra,0x0
 7e0:	dce080e7          	jalr	-562(ra) # 5aa <vprintf>
}
 7e4:	60e2                	ld	ra,24(sp)
 7e6:	6442                	ld	s0,16(sp)
 7e8:	6125                	addi	sp,sp,96
 7ea:	8082                	ret

00000000000007ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ec:	1141                	addi	sp,sp,-16
 7ee:	e422                	sd	s0,8(sp)
 7f0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f6:	00001797          	auipc	a5,0x1
 7fa:	80a7b783          	ld	a5,-2038(a5) # 1000 <freep>
 7fe:	a02d                	j	828 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 800:	4618                	lw	a4,8(a2)
 802:	9f2d                	addw	a4,a4,a1
 804:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	6398                	ld	a4,0(a5)
 80a:	6310                	ld	a2,0(a4)
 80c:	a83d                	j	84a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80e:	ff852703          	lw	a4,-8(a0)
 812:	9f31                	addw	a4,a4,a2
 814:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 816:	ff053683          	ld	a3,-16(a0)
 81a:	a091                	j	85e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	6398                	ld	a4,0(a5)
 81e:	00e7e463          	bltu	a5,a4,826 <free+0x3a>
 822:	00e6ea63          	bltu	a3,a4,836 <free+0x4a>
{
 826:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	fed7fae3          	bgeu	a5,a3,81c <free+0x30>
 82c:	6398                	ld	a4,0(a5)
 82e:	00e6e463          	bltu	a3,a4,836 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	fee7eae3          	bltu	a5,a4,826 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 836:	ff852583          	lw	a1,-8(a0)
 83a:	6390                	ld	a2,0(a5)
 83c:	02059813          	slli	a6,a1,0x20
 840:	01c85713          	srli	a4,a6,0x1c
 844:	9736                	add	a4,a4,a3
 846:	fae60de3          	beq	a2,a4,800 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 84a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 84e:	4790                	lw	a2,8(a5)
 850:	02061593          	slli	a1,a2,0x20
 854:	01c5d713          	srli	a4,a1,0x1c
 858:	973e                	add	a4,a4,a5
 85a:	fae68ae3          	beq	a3,a4,80e <free+0x22>
    p->s.ptr = bp->s.ptr;
 85e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 860:	00000717          	auipc	a4,0x0
 864:	7af73023          	sd	a5,1952(a4) # 1000 <freep>
}
 868:	6422                	ld	s0,8(sp)
 86a:	0141                	addi	sp,sp,16
 86c:	8082                	ret

000000000000086e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86e:	7139                	addi	sp,sp,-64
 870:	fc06                	sd	ra,56(sp)
 872:	f822                	sd	s0,48(sp)
 874:	f426                	sd	s1,40(sp)
 876:	f04a                	sd	s2,32(sp)
 878:	ec4e                	sd	s3,24(sp)
 87a:	e852                	sd	s4,16(sp)
 87c:	e456                	sd	s5,8(sp)
 87e:	e05a                	sd	s6,0(sp)
 880:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 882:	02051493          	slli	s1,a0,0x20
 886:	9081                	srli	s1,s1,0x20
 888:	04bd                	addi	s1,s1,15
 88a:	8091                	srli	s1,s1,0x4
 88c:	0014899b          	addiw	s3,s1,1
 890:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 892:	00000517          	auipc	a0,0x0
 896:	76e53503          	ld	a0,1902(a0) # 1000 <freep>
 89a:	c515                	beqz	a0,8c6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89e:	4798                	lw	a4,8(a5)
 8a0:	02977f63          	bgeu	a4,s1,8de <malloc+0x70>
 8a4:	8a4e                	mv	s4,s3
 8a6:	0009871b          	sext.w	a4,s3
 8aa:	6685                	lui	a3,0x1
 8ac:	00d77363          	bgeu	a4,a3,8b2 <malloc+0x44>
 8b0:	6a05                	lui	s4,0x1
 8b2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ba:	00000917          	auipc	s2,0x0
 8be:	74690913          	addi	s2,s2,1862 # 1000 <freep>
  if(p == (char*)-1)
 8c2:	5afd                	li	s5,-1
 8c4:	a895                	j	938 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8c6:	00001797          	auipc	a5,0x1
 8ca:	94a78793          	addi	a5,a5,-1718 # 1210 <base>
 8ce:	00000717          	auipc	a4,0x0
 8d2:	72f73923          	sd	a5,1842(a4) # 1000 <freep>
 8d6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8dc:	b7e1                	j	8a4 <malloc+0x36>
      if(p->s.size == nunits)
 8de:	02e48c63          	beq	s1,a4,916 <malloc+0xa8>
        p->s.size -= nunits;
 8e2:	4137073b          	subw	a4,a4,s3
 8e6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e8:	02071693          	slli	a3,a4,0x20
 8ec:	01c6d713          	srli	a4,a3,0x1c
 8f0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f6:	00000717          	auipc	a4,0x0
 8fa:	70a73523          	sd	a0,1802(a4) # 1000 <freep>
      return (void*)(p + 1);
 8fe:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 902:	70e2                	ld	ra,56(sp)
 904:	7442                	ld	s0,48(sp)
 906:	74a2                	ld	s1,40(sp)
 908:	7902                	ld	s2,32(sp)
 90a:	69e2                	ld	s3,24(sp)
 90c:	6a42                	ld	s4,16(sp)
 90e:	6aa2                	ld	s5,8(sp)
 910:	6b02                	ld	s6,0(sp)
 912:	6121                	addi	sp,sp,64
 914:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 916:	6398                	ld	a4,0(a5)
 918:	e118                	sd	a4,0(a0)
 91a:	bff1                	j	8f6 <malloc+0x88>
  hp->s.size = nu;
 91c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 920:	0541                	addi	a0,a0,16
 922:	00000097          	auipc	ra,0x0
 926:	eca080e7          	jalr	-310(ra) # 7ec <free>
  return freep;
 92a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92e:	d971                	beqz	a0,902 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 930:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 932:	4798                	lw	a4,8(a5)
 934:	fa9775e3          	bgeu	a4,s1,8de <malloc+0x70>
    if(p == freep)
 938:	00093703          	ld	a4,0(s2)
 93c:	853e                	mv	a0,a5
 93e:	fef719e3          	bne	a4,a5,930 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 942:	8552                	mv	a0,s4
 944:	00000097          	auipc	ra,0x0
 948:	b60080e7          	jalr	-1184(ra) # 4a4 <sbrk>
  if(p == (char*)-1)
 94c:	fd5518e3          	bne	a0,s5,91c <malloc+0xae>
        return 0;
 950:	4501                	li	a0,0
 952:	bf45                	j	902 <malloc+0x94>
