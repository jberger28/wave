;;; (c) Jared Berger & Gaurnett Flowers
;;; -*- Mode: asm; compile-command: "wia wave3.s" -*-
	.requ	ir,r2
	.requ	src,r3
	.requ	dest,r4
	.requ	opcode,r5
	.requ	temp, r8
	.requ	shop, r9
	.requ	reg2, r10
	.requ	reg, r11
	.requ	reg3, r12
	.requ	shiftCount, r13
	.requ	exp, r14
	.requ	value, r15
	
	lea	warm,r0
	trap	$SysOverlay

loop:	and	$0xffffff,wpc
	mov	wpc,r1		;---------------BEGIN LOOP-----------------
	mov	warm(r1),ir

cbits:	mov	ir,temp
	shr	$29,temp
	mov	cjmp(temp),rip

wbnv:	add	$1,wpc
	jmp	loop
wbeq:	mov	wccr,ccr
	je	dop
	add	$1,wpc
	jmp	loop
wbne:	mov	wccr,ccr
	jne	dop
	add	$1,wpc
	jmp	loop
wblt:	mov	wccr,ccr
	jl	dop
	add	$1,wpc
	jmp	loop

wble:	mov	wccr,ccr
	jle	dop
	add	$1,wpc
	jmp	loop
wbge:	mov	wccr,ccr
	jge	dop
	add	$1,wpc
	jmp	loop
	
wbgt:	mov	wccr,ccr
	jg	dop
	add	$1,wpc
	jmp	loop

wbranchl:	mov	wpc,wlr
		add 	$1,wlr
wbranch:	add	ir,wpc
		jmp	loop
		
dop:	mov	ir, opcode
	shr	$23, opcode
	and	$0b111111, opcode
	mov	opdecode(opcode), rip

d0:	mov	r2, dest
	shr	$19, dest
	and	$0b1111, dest

d1:	mov	ir, src
	shr	$15, src
	and	$0b1111, src
	mov	wregs(src), src

	;; Checks Shift/Bit14
	mov	ir, temp
	shr	$12, temp
	and	$0b111, temp
	mov	shjmp(temp), rip
	
d2:	mov	r2, dest
	shr	$19, dest
	and	$0b1111, dest
	
	;; Checks Shift/Bit14
	mov	ir, temp
	shr	$12, temp
	and	$0b111, temp
	mov	shjmp(temp), rip

	
d3:	test	$0b100000000000000, ir
	jne	w2d3
;;; signed offset from base
	mov	ir, reg
	and	$0x3fff,reg
	shl	$18,reg
	sar	$18,reg
	
	mov	ir, src
	shr	$15, src
	and	$0b1111, src
	mov	src, temp
	mov	wregs(src), src
	and	$0xffffff, src

w3d3:	mov 	ir, dest
	shr	$19, dest
	and	$0b1111, dest
 	add	$1,wpc
	mov	opjmp(opcode), rip
	
;;; shifted
w2d3:
	mov 	ir, dest
	shr	$19, dest
	and	$0b1111, dest	
	
	mov	ir, src
	shr	$15, src
	and	$0b1111, src
	mov	src, temp
	mov	wregs(src), src
	and	$0xffffff, src

	mov	ir, shop
	shr	$10, shop
	and	$0b11, shop

	mov 	ir, reg
	shr	$6, reg
	and	$0b1111, reg
	mov	wregs(reg), reg

wd3:	mov	ir, value
	and	$0b111111, value
	mov	shopd3jmp(shop), rip
	
wldr:	add	reg, src
	and	$0xffffff,src
	mov	warm(src), wregs(dest)
	jmp	loop
	
wldu:	cmp	$0, reg
	jl	wldu3
	add	src, reg
	mov	reg, wregs(temp)

;;; if positive
wldu2:	and	$0xffffff,src
	mov	warm(src),wregs(dest)
	jmp	loop
	
;;; if negative
wldu3:	add	src, reg
	mov	reg, wregs(temp)
	
wldu4:
	and	$0xffffff,reg
	mov	warm(reg),wregs(dest)
	jmp	loop
	
wstr:				
	;;; doing str
	add 	reg, src
	and	$0xffffff,src
	mov	wregs(dest),warm(src)
	jmp	loop

wstu:	

	;;; doing stu
	cmp	$0, reg
	jl	wstu4
	add	src, reg
	and	$0xffffff,reg
	mov	reg,wregs(temp)

wstu2:				;this is bad but it might work
	and	$0xffffff,src
	mov	wregs(dest),warm(src)
	jmp	loop
	
;;; if negative
wstu4: 	add	src,reg
	and	$0xffffff,reg
	mov	reg,wregs(temp)

wstu5:
	mov	wregs(dest),warm(reg)
	jmp	loop



	
wldrs:	add	reg, src
	and	$0xffffff,src
	mov	warm(src), wregs(dest)
	add	$0,wregs(dest)
	mov	ccr,wccr
	jmp	loop
	
wldus:	cmp	$0, reg
	jl	wldu3s
	add	src, reg
	mov	reg, wregs(temp)

;;; if positive
wldu2s:	and	$0xffffff,src
	mov	warm(src),wregs(dest)
	add	$0,wregs(dest)
	mov	ccr,wccr
	jmp	loop
	
;;; if negative
wldu3s:	add	src, reg
	mov	reg, wregs(temp)
	
wldu4s:
	and	$0xffffff,reg
	mov	warm(reg),wregs(dest)
	add	$0,wregs(dest)
	mov	ccr,wccr
	jmp	loop
	
wstrs:				
	;;; doing str
	add 	reg, src
	and	$0xffffff,src
	mov	wregs(dest),warm(src)
	add	$0,warm(src)
	mov	ccr,wccr
	jmp	loop

wstus:	

	;;; doing stu
	cmp	$0, reg
	jl	wstu4s
	add	src, reg
	and	$0xffffff,reg
	mov	reg,wregs(temp)

wstu2s:				;this is bad but it might work
	and	$0xffffff,src
	mov	wregs(dest),warm(src)
	add	$0,warm(src)
	mov	ccr,wccr
	jmp	loop
	
;;; if negative
wstu4s: 	add	src,reg
	and	$0xffffff,reg
	mov	reg,wregs(temp)

wstu5s:
	mov	wregs(dest),warm(reg)
	add	$0,warm(reg)
	mov	ccr,wccr
	jmp	loop

	
wadr:	add	reg,src
	mov	src, wregs(dest)
	jmp	loop
	
bit14:
	mov	ir, exp
	sar	$9, exp
	and	$0b11111, exp

	mov	ir, value
	and	$0b111111111, value
	
	shl	exp, value
	;; INCREMENT PROGRAM COUNTER
	add	$1,wpc
	mov	opjmp(opcode), rip
	
shiftNum:
	mov	ir, shop
	sar	$10, shop
	and	$0b11, shop

	mov	ir, value
	sar	$6, value
	and	$0b1111, value

	mov	ir, shiftCount
	and	$0b111111, shiftCount

	mov	wregs(value), value 

shiftNum2:	mov	shopVjmp(shop), rip
shiftNum3:	
;;; INCREMENT PROGRAM COUNTER
		add	$1,wpc
		mov	opjmp(opcode), rip

shiftReg:
	mov	ir, shop
	sar	$10, shop
	and	$0b11, shop

	mov 	ir, reg
	and	$0b1111, reg
	mov	wregs(reg),reg
	
getReg2:mov	ir, value
	sar	$6, value
	and	$0b1111, value
	mov	wregs(value), value

shiftReg2:	mov	shopRjmp(shop), rip
shiftReg3:
;;; INCREMENT PROGRAM COUNTER
		add 	$1,wpc
		mov	opjmp(opcode), rip
	
fma:
	mov	ir, dest
	shr	$19,dest
	and	$0xf,dest
	
	mov	ir, reg
	sar	$15, reg
	and	$0b1111, reg
	mov	wregs(reg),reg

	mov	ir, reg2
	sar	$6, reg2
	and	$0b1111, reg2
	mov	wregs(reg2),reg2
	
	mov	ir, reg3
	and	$0b1111, reg3
	mov	wregs(reg3),reg3
	
	add 	$1,wpc
wmla:	mul	reg2, reg3
	lea	0(reg3,reg),wregs(dest)
	jmp	loop
fmas:	mov	ir, reg
	sar	$15, reg
	and	$0b1111, reg
	mov	wregs(reg),reg

	mov	ir, reg2
	sar	$6, reg2
	and	$0b1111, reg2
	mov	wregs(reg2),reg2
	
	mov	ir, reg3
	and	$0b1111, reg3
	mov	wregs(reg3),reg3
	add	$1,wpc

wmlas:	mul	reg2, reg3
	add	reg3,reg
	mov	ccr,wccr
	mov	reg,wregs(dest)
	jmp	loop
	
halt:	trap	$SysHalt

wadd:	lea	0(value,src),wregs(dest)
	jmp	loop
wadds:	add	value,src
	mov	ccr,wccr
	mov	src,wregs(dest)
	jmp	loop

wadc:	test	$0b10,wccr
 	je	wadcjmp
	lea	1(value,src),wregs(dest)
	jmp	loop
wadcjmp:lea	0(value,src),wregs(dest)
	jmp	loop
wadcs:	test	$0b10,wccr
 	je	wadcsjmp
 	lea	0(value,src),wregs(dest)
	add	$1,wregs(dest)
	mov	ccr,wccr
	jmp	loop
wadcsjmp:
	add	value,src
	mov	ccr,wccr
	mov	src,wregs(dest)
	jmp	loop
wsub:	sub	value, src
	mov	src,wregs(dest)
	jmp	loop
wsubs:	sub	value, src
	mov	ccr,wccr
	mov	src,wregs(dest)
	jmp	loop
wcmps:	sub	value, src
	mov	ccr, wccr
	jmp	loop
weor:	xor	value, src
	mov	src,wregs(dest)
	jmp	loop
weors:	xor	value, src
	mov	ccr,wccr
	mov	src,wregs(dest)
	jmp	loop
worr:	or	value, src
	mov	src,wregs(dest)
	jmp	loop
worrs:	or	value, src
	mov	ccr,wccr
	mov	src,wregs(dest)
	jmp	loop
wand:	and	value, src
	mov	src,wregs(dest)
	jmp 	loop
wands:	and	value, src
	mov	ccr,wccr
	mov	src,wregs(dest)
	jmp	loop
wtsts:	test	value, src
	mov	ccr,wccr
	jmp	loop
wmul:	mul	value, src
	mov	src,wregs(dest)
	jmp	loop
wmuls:	mul	value, src
	mov	ccr,wccr
	mov	src,wregs(dest)
	jmp	loop
wdiv:	div	value, src
	mov	src,wregs(dest)
	jmp	loop
wdivs:	div	value, src
	mov	ccr,wccr
	mov	src,wregs(dest)
	jmp	loop

wmvn:	xor	$-1,value	
wmov:	mov	value,wregs(dest)
	jmp	loop
wmovs:	add	$0,value
	mov	ccr,wccr
	mov	value,wregs(dest)
	jmp	loop
		
wmvns:	xor	$-1,value
	mov	ccr,wccr
	mov	value,wregs(dest)
	jmp	loop
	
wswi:	mov	swijmp(value), rip
wswis:	mov	swijmps(value), rip

wldm:	and	$0xffff, value
	mov	wregs(dest), temp
	and	$0xffffff,temp
	
wldm0:	test	value, $0b1
	je	wldm1
	mov	warm(temp), wr0
	add	$1, temp
wldm1:	test	value, $0b10
	je	wldm2
	mov	warm(temp), wr1
	add	$1, temp
wldm2:	test	value, $0b100
	je	wldm3
	mov	warm(temp), wr2
	add	$1, temp
wldm3:	test	value, $0b1000
	je	wldm4
	mov	warm(temp), wr3
	add	$1, temp
wldm4:	test	value, $0b10000
	je	wldm5
	mov	warm(temp), wr4
	add	$1, temp
wldm5:	test	value, $0b100000
	je	wldm6
	mov	warm(temp), wr5
	add	$1, temp
wldm6:	test	value, $0b1000000
	je	wldm7
	mov	warm(temp), wr6
	add	$1, temp
wldm7:	test	value, $0b10000000
	je	wldm8
	mov	warm(temp), wr7
	add	$1, temp
wldm8:	test	value, $0b100000000
	je	wldm9
	mov	warm(temp), wr8
	add	$1, temp
wldm9:	test	value, $0b1000000000
	je	wldm10
	mov	warm(temp), wr9
	add	$1, temp
wldm10:	test	value, $0b10000000000
	je	wldm11
	mov	warm(temp), wr10
	add	$1, temp
wldm11:	test	value, $0b100000000000
	je	wldm12
	mov	warm(temp), wr11
	add	$1, temp
wldm12:	test	value, $0b1000000000000
	je	wldm13
	mov	warm(temp), wr12
	add	$1, temp
wldm13:	test	value, $0b10000000000000
	je	wldm14
	mov	warm(temp), wr13
	add	$1, temp
wldm14:	test	value, $0b100000000000000
	je	wldm15
	mov	warm(temp), wr14
	add	$1, temp
wldm15:	test	value, $0b1000000000000000
	je	wldmf
	mov	warm(temp), wr15
	mov	wr15, exp
	shr	$28, exp
	mov	exp, wccr
	add	$1, temp
	
wldmf:	mov	temp, wregs(dest)
	jmp	loop
	
wstm:	and	$0xffff, value
	mov	wregs(dest), temp
	and	$0xffffff,temp
	
wstm15:	test	value, $0b1000000000000000
	je	wstm14
	sub	$1, temp
	mov	wccr, exp
	shl	$28, exp
	or	exp, wr15
	mov	wr15, warm(temp)
wstm14:	test	value, $0b100000000000000
	je	wstm13
	sub	$1, temp
	mov	wr14, warm(temp)
wstm13:	test	value, $0b10000000000000
	je	wstm12
	sub	$1, temp
	mov	wr13, warm(temp)
wstm12:	test	value, $0b1000000000000
	je	wstm11
	sub	$1, temp
	mov	wr12, warm(temp)
wstm11:	test	value, $0b100000000000
	je	wstm10
	sub	$1, temp
	mov	wr11, warm(temp)
wstm10:	test	value, $0b10000000000
	je	wstm9
	sub	$1, temp
	mov	wr10, warm(temp)
wstm9:	test	value, $0b1000000000
	je	wstm8
	sub	$1, temp
	mov	wr9, warm(temp)
wstm8:	test	value, $0b100000000
	je	wstm7
	sub	$1, temp
	mov	wr8, warm(temp)
wstm7:	test	value, $0b10000000
	je	wstm6
	sub	$1, temp
	mov	wr7, warm(temp)
wstm6:	test	value, $0b1000000
	je	wstm5
	sub	$1, temp
	mov	wr6, warm(temp)
wstm5:	test	value, $0b100000
	je	wstm4
	sub	$1, temp
	mov	wr5, warm(temp)
wstm4:	test	value, $0b10000
	je	wstm3
	sub	$1, temp
	mov	wr4, warm(temp)
wstm3:	test	value, $0b1000
	je	wstm2
	sub	$1, temp
	mov	wr3, warm(temp)
wstm2:	test	value, $0b100
	je	wstm1
	sub	$1, temp
	mov	wr2, warm(temp)
wstm1:	test	value, $0b10
	je	wstm0
	sub	$1, temp
	mov	wr1, warm(temp)
wstm0:	test	value, $0b1
	je	wstmf
	sub	$1, temp
	mov	wr0, warm(temp)

wstmf:	mov	temp, wregs(dest)
	jmp	loop



sVlsl:	shl	shiftCount, value
	jmp	shiftNum3
sVlsr:	shr	shiftCount, value
	jmp	shiftNum3
sVasr:	sar	shiftCount, value
	jmp	shiftNum3
sVror: 	mov	$32,shop
	sub	shiftCount,shop
	mov	value,temp
	shl	shop,temp
	shr	shiftCount,value
	xor	temp,value
	jmp	shiftNum3

sRlsl:	shl	reg, value
	jmp	shiftReg3
sRlsr:	shr	reg, value
	jmp	shiftReg3
sRasr:	sar	reg, value
	jmp	shiftReg3
sRror:	mov	$32,shop
	sub	reg,shop
	mov	value,temp
	shl	shop,temp
	shr	reg,value
	xor	temp,value
	jmp	shiftNum3

sd3lsl:	shl	value, reg
	add	$1, wpc
	mov	opjmp(opcode), rip
sd3lsr:	shr	value, reg
	add	$1, wpc 
	mov	opjmp(opcode), rip
sd3asr:	sar	value, reg
	add	$1, wpc
	mov	opjmp(opcode), rip
sd3ror:	mov	$32,shop
	sub	value,shop
	mov	reg,temp
	shl	shop,temp
	shr	value,reg
	xor	temp,reg
	add	$1, wpc
	mov	opjmp(opcode), rip

gchar:	trap	$SysGetChar
	mov	r0, wr0
	jmp	loop
gnum:	trap	$SysGetNum
	mov	r0, wr0
	jmp	loop
pchar:	mov	wr0, r0
	trap	$SysPutChar
	jmp	loop
pnum:	mov	wr0, r0
	trap	$SysPutNum
	jmp	loop
ent:	trap	$SysEntropy
	mov	r0, wr0
	jmp	loop
over:	mov	wr0, r0
	trap	$SysOverlay
	jmp	loop
pla:	mov	wr0, r0
	trap	$SysPLA
	mov	r0, wr0
	jmp	loop

gchars:	trap	$SysGetChar
	mov	r0, wr0
	add	$0,wr0
	mov	ccr,wccr
	jmp	loop
gnums:	trap	$SysGetNum
	mov	r0, wr0
	add	$0,wr0
	mov	ccr,wccr
	jmp	loop
pchars:	mov	wr0, r0
	trap	$SysPutChar
	add	$0,wr0
	mov	ccr,wccr
	jmp	loop
pnums:	mov	wr0, r0
	trap	$SysPutNum
	add	$0,wr0
	mov	ccr,wccr
	jmp	loop
ents:	trap	$SysEntropy
	mov	r0, wr0
	add	$0,wr0
	mov	ccr,wccr
	jmp	loop
overs:	mov	wr0, r0
	trap	$SysOverlay
	add	$0,wr0
	mov	ccr,wccr
	jmp	loop
plas:	mov	wr0, r0
	trap	$SysPLA
	mov	r0, wr0
	add	$0,wr0
	mov	ccr,wccr
	jmp	loop

;;; d0 add, d1 compare, d2 mov, d3 swi
opdecode:
	.data 	d0,d0,d0,d1,d0,d0,d0,d1
	.data	d0,fma,d0,d2,d2,bit14,d2,d2
	.data	d3, d3, d3, d3, d3, halt, halt, halt
	.data	wbranch, wbranch, wbranchl, wbranchl, halt, halt, halt, halt
	;; part 2 of table
	.data	d0,d0,d0,d1,d0,d0,d0,d1
	.data	d0,fmas,d0,d2,d2,bit14,d2, d2
	.data	d3, d3, d3, d3, d3, halt, halt, halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt

shjmp:	.data	bit14, bit14, bit14, bit14, shiftNum, shiftReg, fma

opjmp:	.data	wadd,wadc,wsub,wcmps,weor,worr,wand,wtsts
	.data	wmul,halt,wdiv,wmov,wmvn,wswi,wldm,wstm
	.data	wldr,wstr,wldu,wstu,wadr,halt,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt
	.data	wadds,wadcs,wsubs,wcmps,weors,worrs,wands,wtsts
	.data	wmuls,halt,wdivs,wmovs,wmvns,wswis,halt,halt
	.data	wldrs,wstrs,wldus,wstus,wadr,halt,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt


shopVjmp:	.data	sVlsl, sVlsr, sVasr, sVror
shopRjmp:	.data	sRlsl, sRlsr, sRasr, sRror
swijmp:		.data	halt, gchar, gnum, pchar, pnum, ent, over, pla
swijmps:	.data	halt, gchars, gnums, pchars, pnums, ents, overs, plas


shopd3jmp:	.data	sd3lsl, sd3lsr, sd3asr, sd3ror

cjmp:		.data	dop, wbnv, wbeq, wbne, wblt, wble, wbge, wbgt

wregs:
wr0:	.data	0
wr1:	.data	0
wr2:	.data	0
wr3:	.data	0
wr4:	.data	0
wr5:	.data	0
wr6:	.data	0
wr7:	.data	0
wr8:	.data	0
wr9:	.data	0
wr10:	.data	0
wr11:	.data	0
wr12:	.data	0
wsp:	
wr13:	.data	0x00ffffff
wlr:	
wr14:	.data	0
wpc:	
wr15:	.data	0
wccr:	.data	0


;;; ------------------write no code below this line------------------------
warm:	 			; Warm overlay is loaded here
