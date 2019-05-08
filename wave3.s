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

	;; 	.equ	wmem, -67108864
;;; prolog ??mov	rsp,rbp sub	$16777216,rsp

loop:	and	$0xffffff,wpc
	mov	wpc,r1		;---------------BEGIN LOOP-----------------
	mov	warm(r1),ir
loopb:	

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

	
wbranch:add	ir,wpc
	;; 	and	$0xffffff,wpc
	;; 	mov	wpc, r0
	;; 	mov	warm(r0), ir
	jmp	loop
	
wbranchl:
	mov	wpc,wlr
	add	$1,wlr
	add	ir,wpc
	;; 	and	$0xffffff,wpc	
	;; 	mov	wpc, r0
	;; 	mov	warm(r0), ir	
	jmp	loop
		
dop:	mov	ir, opcode
	shr	$23, opcode
	and	$0b111111, opcode
	mov	opdecode(opcode), rip
	
d0:	mov	r2, dest
	sar	$19, dest
	and	$0b1111, dest

d1:	mov	ir, src
	sar	$15, src
	and	$0b1111, src
	mov	wregs(src), src


	;; Checks Shift/Bit14
	mov	ir, temp
	shr	$12, temp
	and	$0b111, temp
	mov	shjmp(temp), rip

	
d2:
	mov	r2, dest
	sar	$19, dest
	and	$0b1111, dest
	
	;; Checks Shift/Bit14
	mov	ir, temp
	shr	$12, temp
	and	$0b111, temp
	mov	shjmp(temp), rip

	
d3:	test	$0b100000000000000, ir
	jne	w2d3

	mov	ir, reg
	and	$0b11111111111111, reg
	shl	$18,reg
	sar	$18,reg
	
	mov	ir, src
	sar	$15, src
	and	$0b1111, src
	mov	src, temp
	mov	wregs(src), src

	;; next line saves value of displacement
	mov	reg,exp
	
w3d3:	mov 	ir, dest
	sar	$19, dest
	and	$0b1111, dest
	;; and 	$0b111, opcode
 	add	$1,wpc
	mov	opjmp(opcode), rip

w2d3:	mov	ir, shop
	sar	$10, shop
	and	$0b11, shop

	mov 	ir, reg
	and	$0b1111, reg
	mov	wregs(reg), reg

wd3:	mov	ir, value
	and	$0b111111, value
	mov	shopd3jmp(shop), rip
	
wldr:	add	reg, src
	and	$0xffffff,src
	mov	warm(src), wregs(dest)
	;; 	lea	warm,r0
	;; 	add	r0,src
	;; 	mov	0(src), src
	;; 	mov	src, wregs(dest)
	jmp	loop
	
wldu:	cmp	$0, reg
	jl	wldu3
	add	src, reg
	mov	reg, wregs(temp)

;;; if positive
wldu2:  			;lea	warm,r0
	;; 	add	r0,src
	;; 	mov	0(src), src
	;; 	mov	src, wregs(dest)
	and	$0xffffff,src
	mov	warm(src),wregs(dest)
	jmp	loop
	
;;; if negative
wldu3:	add	src, reg
	mov	reg, wregs(temp)
	
wldu4:	add 	reg,src
	;; 	lea	warm,r0
	;; 	add	r0,src
	;; 	mov	0(src), src
	and	$0xffffff,src
	;; 	mov	regjmp(dest), rip
	mov	warm(src),wregs(dest)
	jmp	loop
	
wstr:	mov	wregs(dest), dest
	;;; doing str
	add 	reg, src
	;; 	lea	warm,r0
	;; 	add	r0,src
	;; 	mov	dest, 0(src)
	;; 	add	$1, wpc
	and	$0xffffff,src
	mov	warm(src),wregs(dest)
	jmp	loop

wstu:	mov	wregs(dest), dest
	;;; doing stu
	cmp	$0, reg
	jl	wstu4
	add	src, reg
	mov	reg,wregs(temp)
	;; 	mov	stubase(temp), rip

wstu2:				;this is bad but it might work
	;; 	cmp	$0,exp
	;; 	jl	wstu5
	;; 	lea	warm,r0
	;; 	add	r0,src
	;; 	mov	dest, 0(src)
	;; 	add	$1, wpc
	and	$0xffffff,src
	mov	dest,wregs(src)
	jmp	loop
	
;;; if negative
wstu4: 	add	src,reg
	mov	reg,wregs(temp)
	;; mov	stubase(temp),rip

wstu5:	add	exp,src
	;; 	lea	warm,r0
	;; 	add	r0,src
	;; 	mov	dest,0(src)
	;; 	add	$1,wpc
	and	$0xffffff,src
	mov	dest,wregs(src)
	jmp	loop
	
wadr:	add	reg,src
	mov	src, wregs(dest)
	jmp	loop
	
bit14:
	mov	ir, exp
	sar	$9, exp
	and	$0b11111, exp

	mov	ir, value
	and	$0b11111111, value

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
	mov	getreg(reg), rip
	
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
	mov	ir, reg
	sar	$15, reg
	and	$0b1111, reg
	mov	getfma1(reg), rip

fma1:	mov	ir, reg2
	sar	$6, reg2
	and	$0b1111, reg2
	mov	getfma2(reg2), rip
	
getReg3:mov	ir, reg3
	and	$0b1111, reg3
	mov	getfma3(reg3), rip
	
fma2:
	;; INCREMENT PROGRAM COUNTER (and maybe don't jump again)
	;; should already know we are in fmla
	add 	$1,wpc
	mov	opjmp(opcode), rip

	
halt:	trap	$SysHalt

wadd:	lea	0(value,src),wregs(dest)
	jmp	loop

wadc:	test	$0b10,wccr
 	je	wadcjmp
	lea	1(value,src),wregs(dest)
	jmp	loop
wadcjmp:lea	0(value,src),wregs(dest)
	jmp	loop
wsub:	sub	value, src
	mov	src,wregs(dest)
	jmp	loop
wcmp:	sub	value, src
	mov	ccr, wccr
	;; 	add	$1, wpc
	jmp	loop
weor:	xor	value, src
	mov	src,wregs(dest)
	jmp	loop
worr:	or	value, src
	mov	src,wregs(dest)
	jmp	loop
wand:	and	value, src
	mov	src,wregs(dest)
	jmp	loop
wtst:	test	value, src
	jmp	loop
wmul:	mul	value, src
	mov	src,wregs(dest)
	jmp	loop
wmla:	mul	reg2, reg3
	lea	0(reg3,reg),wregs(dest)
	;; 	add	reg3, reg
	;; 	mov	reg,wregs(dest)
	jmp	loop
wdiv:	div	value, src
	mov	src,wregs(dest)
	jmp	loop
wmov:	mov	value,wregs(dest)
	jmp	loop
		
wmvn:	xor	$0b11111111111111111111111111111111,value
	mov	value,wregs(dest)
	jmp	loop
	
wswi:	mov	swijmp(value), rip

wldm:	and	$0xffff, value
	mov	wregs(dest), temp
	
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

;;; r2 for shift count
gnrr0:	mov	wr0, reg2
	jmp	shiftNum2
gnrr1:	mov	wr1, reg2
	jmp	shiftNum2
gnrr2:	mov	wr2, reg2
	jmp	shiftNum2
gnrr3:	mov	wr3, reg2
	jmp	shiftNum2
gnrr4:	mov	wr4, reg2
	jmp	shiftNum2
gnrr5:	mov	wr5, reg2
	jmp	shiftNum2
gnrr6:	mov	wr6, reg2
	jmp	shiftNum2
gnrr7:	mov	wr7, reg2
	jmp	shiftNum2
gnrr8:	mov	wr8, reg2
	jmp	shiftNum2
gnrr9:	mov	wr9, reg2
	jmp	shiftNum2
gnrr10:	mov	wr10, reg2
	jmp	shiftNum2
gnrr11:	mov	wr11, reg2
	jmp	shiftNum2
gnrr12:	mov	wr12, reg2
	jmp	shiftNum2
gnrr13:	mov	wr13, reg2
	jmp	shiftNum2
gnrr14:	mov	wr14, reg2
	jmp	shiftNum2
gnrr15:	mov	wr15, reg2
	jmp	shiftNum2
	
;;; sh reg
gr0:	mov	wr0, reg
	jmp	getReg2
gr1:	mov	wr1, reg
	jmp	getReg2
gr2:	mov	wr2, reg
	jmp	getReg2
gr3:	mov	wr3, reg
	jmp	getReg2
gr4:	mov	wr4, reg
	jmp	getReg2
gr5:	mov	wr5, reg
	jmp	getReg2
gr6:	mov	wr6, reg
	jmp	getReg2
gr7:	mov	wr7, reg
	jmp	getReg2
gr8:	mov	wr8, reg
	jmp	getReg2
gr9:	mov	wr9, reg
	jmp	getReg2
gr10:	mov	wr10, reg
	jmp	getReg2
gr11:	mov	wr11, reg
	jmp	getReg2
gr12:	mov	wr12, reg
	jmp	getReg2
gr13:	mov	wr13, reg
	jmp	getReg2
gr14:	mov	wr14, reg
	jmp	getReg2
gr15:	mov	wr15, reg
	jmp	getReg2

grerr0:	mov	wr0, reg2
	jmp	shiftReg2
grerr1:	mov	wr1, reg2
	jmp	shiftReg2
grerr2:	mov	wr2, reg2
	jmp	shiftReg2
grerr3:	mov	wr3, reg2
	jmp	shiftReg2
grerr4:	mov	wr4, reg2
	jmp	shiftReg2
grerr5:	mov	wr5, reg2
	jmp	shiftReg2
grerr6:	mov	wr6, reg2
	jmp	shiftReg2
grerr7:	mov	wr7, reg2
	jmp	shiftReg2
grerr8:	mov	wr8, reg2
	jmp	shiftReg2
grerr9:	mov	wr9, reg2
	jmp	shiftReg2
grerr10:mov	wr10, reg2
	jmp	shiftReg2
grerr11:mov	wr11, reg2
	jmp	shiftReg2
grerr12:mov	wr12, reg2
	jmp	shiftReg2
grerr13:mov	wr13, reg2
	jmp	shiftReg2
grerr14:mov	wr14, reg2
	jmp	shiftReg2
grerr15:mov	wr15, reg2
	jmp	shiftReg2

;;; src reg 2 for reg 3
gf0:	mov	wr0, reg
	jmp	fma1
gf1:	mov	wr1, reg
	jmp	fma1
gf2:	mov	wr2, reg
	jmp	fma1
gf3:	mov	wr3, reg
	jmp	fma1
gf4:	mov	wr4, reg
	jmp	fma1
gf5:	mov	wr5, reg
	jmp	fma1
gf6:	mov	wr6, reg
	jmp	fma1
gf7:	mov	wr7, reg
	jmp	fma1
gf8:	mov	wr8, reg
	jmp	fma1
gf9:	mov	wr9, reg
	jmp	fma1
gf10:	mov	wr10, reg
	jmp	fma1
gf11:	mov	wr11, reg
	jmp	fma1
gf12:	mov	wr12, reg
	jmp	fma1
gf13:	mov	wr13, reg
	jmp	fma1
gf14:	mov	wr14, reg
	jmp	fma1
gf15:	mov	wr15, reg
	jmp	fma1

	
grr0:	mov 	wr0, reg2
	jmp	getReg3
grr1:	mov 	wr1, reg2
	jmp	getReg3
grr2:	mov 	wr2, reg2
	jmp	getReg3
grr3:	mov 	wr3, reg2
	jmp	getReg3
grr4:	mov 	wr4, reg2
	jmp	getReg3
grr5:	mov 	wr5, reg2
	jmp	getReg3
grr6:	mov 	wr6, reg2
	jmp	getReg3
grr7:	mov 	wr7, reg2
	jmp	getReg3
grr8:	mov 	wr8, reg2
	jmp	getReg3
grr9:	mov 	wr9, reg2
	jmp	getReg3
grr10:	mov 	wr10, reg2
	jmp	getReg3
grr11:	mov 	wr11, reg2
	jmp	getReg3
grr12:	mov 	wr12, reg2
	jmp	getReg3
grr13:	mov 	wr13, reg2
	jmp	getReg3
grr14:	mov 	wr14, reg2
	jmp	getReg3
grr15:	mov 	wr15, reg2
	jmp	getReg3

grrr0:	mov	wr0, reg3
	jmp	fma2
grrr1:	mov	wr1, reg3
	jmp	fma2
grrr2:	mov	wr2, reg3
	jmp	fma2
grrr3:	mov	wr3, reg3
	jmp	fma2
grrr4:	mov	wr4, reg3
	jmp	fma2
grrr5:	mov	wr5, reg3
	jmp	fma2
grrr6:	mov	wr6, reg3
	jmp	fma2
grrr7:	mov	wr7, reg3
	jmp	fma2
grrr8:	mov	wr8, reg3
	jmp	fma2
grrr9:	mov	wr9, reg3
	jmp	fma2
grrr10:	mov	wr10, reg3
	jmp	fma2
grrr11:	mov	wr11, reg3
	jmp	fma2
grrr12:	mov	wr12, reg3
	jmp	fma2
grrr13:	mov	wr13, reg3
	jmp	fma2
grrr14:	mov	wr14, reg3
	jmp	fma2
grrr15:	mov	wr15, reg3
	jmp	fma2
	
rr0:	mov	src, wr0
	jmp	loop
rr1:	mov	src, wr1
	jmp	loop
rr2:	mov	src, wr2
	jmp	loop
rr3:	mov	src, wr3
	jmp	loop
rr4:	mov	src, wr4
	jmp	loop
rr5:	mov	src, wr5
	jmp	loop
rr6:	mov	src, wr6
	jmp	loop
rr7:	mov	src, wr7
	jmp	loop
rr8:	mov	src, wr8
	jmp	loop
rr9:	mov	src, wr9
	jmp	loop
rr10:	mov	src, wr10
	jmp	loop
rr11:	mov	src, wr11
	jmp	loop
rr12:	mov	src, wr12
	jmp	loop
rr13:	mov	src, wr13
	jmp	loop
rr14:	mov	src, wr14
	jmp	loop
rr15:	mov	src, wr15
	jmp	loop

;;; load/multiple
gd0:	mov	wr0, reg
	jmp	wd3
gd1:	mov	wr1, reg
	jmp	wd3
gd2:	mov	wr2, reg
	jmp	wd3
gd3:	mov	wr3, reg
	jmp	wd3
gd4:	mov	wr4, reg
	jmp	wd3
gd5:	mov	wr5, reg
	jmp	wd3
gd6:	mov	wr6, reg
	jmp	wd3
gd7:	mov	wr7, reg
	jmp	wd3
gd8:	mov	wr8, reg
	jmp	wd3
gd9:	mov	wr9, reg
	jmp	wd3
gd10:	mov	wr10, reg
	jmp	wd3
gd11:	mov	wr11, reg
	jmp	wd3
gd12:	mov	wr12, reg
	jmp	wd3
gd13:	mov	wr13, reg
	jmp	wd3
gd14:	mov	wr14, reg
	jmp	wd3
gd15:	mov	wr15, reg
	jmp	wd3

wgd0:	mov	wr0, src
	jmp	w3d3
wgd1:	mov	wr1, src
	jmp	w3d3
wgd2:	mov	wr2, src
	jmp	w3d3
wgd3:	mov	wr3, src
	jmp	w3d3
wgd4:	mov	wr4, src
	jmp	w3d3
wgd5:	mov	wr5, src
	jmp	w3d3
wgd6:	mov	wr6, src
	jmp	w3d3
wgd7:	mov	wr7, src
	jmp	w3d3
wgd8:	mov	wr8, src
	jmp	w3d3
wgd9:	mov	wr9, src
	jmp	w3d3
wgd10:	mov	wr10, src
	jmp	w3d3
wgd11:	mov	wr11, src
	jmp	w3d3
wgd12:	mov	wr12, src
	jmp	w3d3
wgd13:	mov	wr13, src
	jmp	w3d3
wgd14:	mov	wr14, src
	jmp	w3d3
wgd15:	mov	wr15, src
	jmp	w3d3

b0:	mov	reg, wr0
	jmp	wldu2
b1:	mov	reg, wr1
	jmp	wldu2
b2:	mov	reg, wr2
	jmp	wldu2
b3:	mov	reg, wr3
	jmp	wldu2
b4:	mov	reg, wr4
	jmp	wldu2
b5:	mov	reg, wr5
	jmp	wldu2
b6:	mov	reg, wr6
	jmp	wldu2
b7:	mov	reg, wr7
	jmp	wldu2
b8:	mov	reg, wr8
	jmp	wldu2
b9:	mov	reg, wr9
	jmp	wldu2
b10:	mov	reg, wr10
	jmp	wldu2
b11:	mov	reg, wr11
	jmp	wldu2
b12:	mov	reg, wr12
	jmp	wldu2
b13:	mov	reg, wr13
	jmp	wldu2
b14:	mov	reg, wr14
	jmp	wldu2
b15:	mov	reg, wr15
	jmp	wldu2
	
s0:	mov	reg, wr0
	jmp	wstu2
s1:	mov	reg, wr1
	jmp	wstu2
s2:	mov	reg, wr2
	jmp	wstu2
s3:	mov	reg, wr3
	jmp	wstu2
s4:	mov	reg, wr4
	jmp	wstu2
s5:	mov	reg, wr5
	jmp	wstu2
s6:	mov	reg, wr6
	jmp	wstu2
s7:	mov	reg, wr7
	jmp	wstu2
s8:	mov	reg, wr8
	jmp	wstu2
s9:	mov	reg, wr9
	jmp	wstu2
s10:	mov	reg, wr10
	jmp	wstu2
s11:	mov	reg, wr11
	jmp	wstu2
s12:	mov	reg, wr12
	jmp	wstu2
s13:	mov	reg, wr13
	jmp	wstu2
s14:	mov	reg, wr14
	jmp	wstu2
s15:	mov	reg, wr15
	jmp	wstu2

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
	cmp	$0,wr0
	mov	ccr,wccr
	jmp	loop
gnums:	trap	$SysGetNum
	mov	r0, wr0
	cmp	$0,wr0
	mov	ccr,wccr
	jmp	loop
pchars:	mov	wr0, r0
	trap	$SysPutChar
	cmp	$0,wr0
	mov	ccr,wccr
	jmp	loop
pnums:	mov	wr0, r0
	trap	$SysPutNum
	cmp	$0,wr0
	mov	ccr,wccr
	jmp	loop
ents:	trap	$SysEntropy
	mov	r0, wr0
	cmp	$0,wr0
	mov	ccr,wccr
	jmp	loop
overs:	mov	wr0, r0
	trap	$SysOverlay
	cmp	$0,wr0
	mov	ccr,wccr
	jmp	loop
plas:	mov	wr0, r0
	trap	$SysPLA
	mov	r0, wr0
	cmp	$0,wr0
	mov	ccr,wccr
	jmp	loop

;;; ---------------------------- S ---------------------------------------

d3s:	mov	ir, reg
	and	$0b11111111111111, reg
	shl	$18,reg
	sar	$18,reg
	;; next line saves value of displacement
	mov	reg,exp	
	mov	ir, temp
	sar	$14, temp
	and	$0b1, temp
	cmp	$0, temp
	je	w2d3s
	
	mov	ir, shop
	sar	$10, shop
	and	$0b11, shop

	mov 	ir, reg
	and	$0b1111, reg
	mov	getd3reg(reg), rip
	
wd3s:	mov	ir, value
	and	$0b111111, value
	mov	shopd3jmps(shop), rip

w2d3s:	mov	ir, src
	sar	$15, src
	and	$0b1111, src
	mov	src, temp
	mov	getd3srcs(src), rip	

w3d3s:	mov 	ir, dest
	sar	$19, dest
	and	$0b1111, dest
	and 	$0b111, opcode
	mov	oploads(opcode), rip
	
wldrs:	add	$1,wpc
	add	reg, src
	lea	warm,r0
	add	r0,src
	mov	0(src), src
	mov	regjmp(dest), rip

wldus:	add	$1,wpc
	cmp	$0, reg
	jl	wldu3s
	add	src, reg
	mov	ldubases(temp), rip

;;; if positive
wldu2s:	cmp	$0,exp
	jl	wldu4s
	lea	warm,r0
	add	r0,src
	mov	0(src), src
	cmp	$0,src
	mov	ccr,wccr
	and	$0b1100,wccr
	mov	regjmp(dest), rip
;;; if negative
wldu3s:	add	src, reg
	mov	ldubases(temp),rip
wldu4s:	add 	reg,src
	lea	warm,r0
	add	r0,src
	mov	0(src), src
	cmp	$0,src
	mov	ccr,wccr
	and	$0b1100,wccr
	mov	regjmp(dest), rip
	
wstrs:	add	$1,wpc
	mov	getd3dests(dest), rip
	
wstus:	add	$1,wpc
	mov	getd3dests(dest), rip

w4d3s:	cmp	$3, opcode
	je	wstu3s

;;; doing str
	add 	reg, src
	lea	warm,r0
	add	r0,src
	mov	dest, 0(src)
	add	$1, wpc
	jmp	loop

;;; doing stu
wstu3s:	cmp	$0, reg
	jl	wstu4s
	add	src, reg
	mov	stubases(temp), rip

wstu2s: jl	wstu5s
	lea	warm,r0
	add	r0,src
	mov	dest, 0(src)
	add	$1, wpc
	jmp	loop
	
;;; if negative
wstu4s: add	src,reg
	mov	stubases(temp),rip

wstu5s:	add	reg,src
	lea	warm,r0
	add	r0,src
	mov	dest,0(src)
	add	$1,wpc
	jmp	loop

wadrs:	
	
wadds:	add	value, src
	mov	ccr, wccr
	mov	regjmp(dest), rip

wadcs:	add	value, src
	mov 	wccr, temp
	mov	ccr, wccr
	and	0b10, temp
	cmp	$0, temp
	je	wadcjmp
	add	$1, src
	mov	ccr, wccr
	mov	regjmp(dest), rip
wsubs:	sub	value, src
	mov	ccr, wccr
	mov	regjmp(dest), rip
wcmps:	sub	value, src
	mov	ccr, wccr
	;; 	add	$1, wpc		
	jmp	loop
weors:	xor	value, src
	mov	ccr, wccr
	mov	regjmp(dest), rip
worrs:	or	value, src
	mov	ccr, wccr
	mov	regjmp(dest), rip
wands:	and	value, src
	mov	ccr, wccr
	mov	regjmp(dest), rip
wtsts:	test	value, src
	;; 	add	$1, wpc
	jmp 	loop
wmuls:	mul	value, src
	mov	ccr, wccr
	mov	regjmp(dest), rip
wmlas:	mul	reg2, reg3
	add	reg3, reg
	mov	ccr, wccr
	mov	reg, src
	mov	regjmp(dest), rip
wdivs:	div	value, src
	mov	ccr, wccr
	mov	regjmp(dest), rip
wmovs:	mov	ir, temp
	shr	$14,temp
	and	$1,temp
	mov	temp, r0
	cmp	$0,temp

	je	wmovVs
	mov	reg2, src
	cmp	$0,src
	mov	ccr, wccr
	mov	regjmp(dest), rip
	
wmovVs:	mov	value, src
	cmp	$0,src
	mov	ccr,wccr
	mov	regjmp(dest), rip

wmvns:	mov	ir, temp
	shr	$14,temp
	and	$1,temp
	mov	temp, r0
	cmp	$0,temp

	je	wmvnVs
	xor	$0b11111111111111111111111111111111,reg2
	mov	ccr,wccr
	mov	reg2, src
	mov	regjmp(dest), rip
	
wmvnVs:	xor	$0b11111111111111111111111111111111,value
	mov	ccr,wccr
	mov	value, src
	mov	regjmp(dest), rip
	
wswis:	mov	swijmps(value), rip

wstms:
	
wldms:	
;;; load/multiple
sd3lsls:	shl	value, reg
	jmp	w2d3s
sd3lsrs:	shr	value, reg
	jmp	w2d3s
sd3asrs:	sar	value, reg
	jmp	w2d3s
sd3rors:	mov	$32,shop
	sub	value,shop
	mov	reg,temp
	shl	shop,temp
	shr	value,reg
	xor	temp,reg
	jmp	w2d3s


gd0s:	mov	wr0, reg
	jmp	wd3s
gd1s:	mov	wr1, reg
	jmp	wd3s
gd2s:	mov	wr2, reg
	jmp	wd3s
gd3s:	mov	wr3, reg
	jmp	wd3s
gd4s:	mov	wr4, reg
	jmp	wd3s
gd5s:	mov	wr5, reg
	jmp	wd3s
gd6s:	mov	wr6, reg
	jmp	wd3s
gd7s:	mov	wr7, reg
	jmp	wd3s
gd8s:	mov	wr8, reg
	jmp	wd3s
gd9s:	mov	wr9, reg
	jmp	wd3s
gd10s:	mov	wr10, reg
	jmp	wd3s
gd11s:	mov	wr11, reg
	jmp	wd3s
gd12s:	mov	wr12, reg
	jmp	wd3s
gd13s:	mov	wr13, reg
	jmp	wd3s
gd14s:	mov	wr14, reg
	jmp	wd3s
gd15s:	mov	wr15, reg
	jmp	wd3s

wgd0s:	mov	wr0, src
	jmp	w3d3s
wgd1s:	mov	wr1, src
	jmp	w3d3s
wgd2s:	mov	wr2, src
	jmp	w3d3s
wgd3s:	mov	wr3, src
	jmp	w3d3s
wgd4s:	mov	wr4, src
	jmp	w3d3s
wgd5s:	mov	wr5, src
	jmp	w3d3s
wgd6s:	mov	wr6, src
	jmp	w3d3s
wgd7s:	mov	wr7, src
	jmp	w3d3s
wgd8s:	mov	wr8, src
	jmp	w3d3s
wgd9s:	mov	wr9, src
	jmp	w3d3s
wgd10s:	mov	wr10, src
	jmp	w3d3s
wgd11s:	mov	wr11, src
	jmp	w3d3s
wgd12s:	mov	wr12, src
	jmp	w3d3s
wgd13s:	mov	wr13, src
	jmp	w3d3s
wgd14s:	mov	wr14, src
	jmp	w3d3s
wgd15s:	mov	wr15, src
	jmp	w3d3s

wgdest0s:	mov	wr0, dest
	jmp	w4d3s
wgdest1s:	mov	wr1, dest
	jmp	w4d3s
wgdest2s:	mov	wr2, dest
	jmp	w4d3s
wgdest3s:	mov	wr3, dest
	jmp	w4d3s
wgdest4s:	mov	wr4, dest
	jmp	w4d3s
wgdest5s:	mov	wr5, dest
	jmp	w4d3s
wgdest6s:	mov	wr6, dest
	jmp	w4d3s
wgdest7s:	mov	wr7, dest
	jmp	w4d3s
wgdest8s:	mov	wr8, dest
	jmp	w4d3s
wgdest9s:	mov	wr9, dest
	jmp	w4d3s
wgdest10s:	mov	wr10, dest
	jmp	w4d3s
wgdest11s:	mov	wr11, dest
	jmp	w4d3s
wgdest12s:	mov	wr12, dest
	jmp	w4d3s
wgdest13s:	mov	wr13, dest
	jmp	w4d3s
wgdest14s:	mov	wr14, dest
	jmp	w4d3s
wgdest15s:	mov	wr15, dest
	jmp	w4d3s

b0s:	mov	reg, wr0
	jmp	wldu2s
b1s:	mov	reg, wr1
	jmp	wldu2s
b2s:	mov	reg, wr2
	jmp	wldu2s
b3s:	mov	reg, wr3
	jmp	wldu2s
b4s:	mov	reg, wr4
	jmp	wldu2s
b5s:	mov	reg, wr5
	jmp	wldu2s
b6s:	mov	reg, wr6
	jmp	wldu2s
b7s:	mov	reg, wr7
	jmp	wldu2s
b8s:	mov	reg, wr8
	jmp	wldu2s
b9s:	mov	reg, wr9
	jmp	wldu2s
b10s:	mov	reg, wr10
	jmp	wldu2s
b11s:	mov	reg, wr11
	jmp	wldu2s
b12s:	mov	reg, wr12
	jmp	wldu2s
b13s:	mov	reg, wr13
	jmp	wldu2s
b14s:	mov	reg, wr14
	jmp	wldu2s
b15s:	mov	reg, wr15
	jmp	wldu2s
	
s0s:	mov	reg, wr0
	jmp	wstu2s
s1s:	mov	reg, wr1
	jmp	wstu2s
s2s:	mov	reg, wr2
	jmp	wstu2s
s3s:	mov	reg, wr3
	jmp	wstu2s
s4s:	mov	reg, wr4
	jmp	wstu2s
s5s:	mov	reg, wr5
	jmp	wstu2s
s6s:	mov	reg, wr6
	jmp	wstu2s
s7s:	mov	reg, wr7
	jmp	wstu2s
s8s:	mov	reg, wr8
	jmp	wstu2s
s9s:	mov	reg, wr9
	jmp	wstu2s
s10s:	mov	reg, wr10
	jmp	wstu2s
s11s:	mov	reg, wr11
	jmp	wstu2s
s12s:	mov	reg, wr12
	jmp	wstu2s
s13s:	mov	reg, wr13
	jmp	wstu2s
s14s:	mov	reg, wr14
	jmp	wstu2s
s15s:	mov	reg, wr15
	jmp	wstu2s

;;; ---------------------------- S COMPLETE ----------------------------------
;;; d0 add, d1 compare, d2 mov, d3 swi
opdecode:
	.data 	d0,d0,d0,d1,d0,d0,d0,d1
	.data	d0,d0,d0,d2,d2,bit14,d2,d2
	.data	d3, d3, d3, d3, d3, halt, halt, halt
	.data	wbranch, wbranch, wbranchl, wbranchl,
	.data	halt,halt,halt,halt
	;; part 2 of table
	.data	d0,d0,d0,d1,d0,d0,d0,d1
	.data	d0,d0,d0,d2,d2,bit14,halt, halt
	.data	d3s, d3s, d3s, d3s, d3s, halt, halt, halt

shjmp:	.data	bit14, bit14, bit14, bit14, shiftNum, shiftReg, fma

opjmp:	.data	wadd,wadc,wsub,wcmp,weor,worr,wand,wtst
	.data	wmul,wmla,wdiv,wmov,wmvn,wswi,wldm,wstm
	.data	wldr,wstr,wldu,wstu,wadr,halt,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt
	.data	wadds,wadcs,wsubs,wcmps,weors,worrs,wands,wtsts
	.data	wmuls,wmlas,wdivs,wmovs,wmvns,wswis,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt

;;; Get reg2 for reg
getR2: 	.data	grerr0, grerr1, grerr2, grerr3, grerr4, grerr5, grerr6, grerr7
		.data	grerr8, grerr9, grerr10, grerr11, grerr12, grerr13, grerr14, grerr15

getreg: .data	gr0, gr1, gr2, gr3, gr4, gr5, gr6, gr7
	.data	gr8, gr9, gr10, gr11, gr12, gr13, gr14, gr15

;;; Get reg2 for shift count
getreg2: 	.data	gnrr0, gnrr1, gnrr2, gnrr3, gnrr4, gnrr5, gnrr6, gnrr7
		.data	gnrr8, gnrr9, gnrr10, gnrr11, gnrr12, gnrr13, gnrr14, gnrr15

;;; Get reg2 for reg3
getfma1: .data	gf0, gf1, gf2, gf3, gf4, gf5, gf6, gf7, gf8
	.data	gf9, gf10, gf11, gf12, gf13, gf14, gf15
	
getfma2: .data	grr0, grr1, grr2, grr3, grr4, grr5, grr6, grr7
	.data	grr8, grr9, grr10, grr11, grr12, grr13, grr14, grr15

getfma3: .data	grrr0, grrr1, grrr2, grrr3, grrr4, grrr5, grrr6, grrr7
	.data	grrr8, grrr9, grrr10, grrr11, grrr12, grrr13, grrr14, grrr15

regjmp:	.data	rr0, rr1, rr2, rr3, rr4, rr5, rr6, rr7
	.data	rr8, rr9, rr10, rr11, rr12, rr13, rr14, rr15

shopVjmp:	.data	sVlsl, sVlsr, sVasr, sVror
shopRjmp:	.data	sRlsl, sRlsr, sRasr, sRror
swijmp:		.data	halt, gchar, gnum, pchar, pnum, ent, over, pla
swijmps:	.data	halt, gchars, gnums, pchars, pnums, ents, overs, plas

getd3reg: .data	gd0, gd1, gd2, gd3, gd4, gd5, gd6, gd7
	.data	gd8, gd9, gd10, gd11, gd12, gd13, gd14, gd15
ldubase: .data	b0, b1, b2, b3, b4, b5, b6, b7
	.data	b8, b9, b10, b11, b12, b13, b14, b15
stubase: .data	s0, s1, s2, s3, s4, s5, s6, s7
	.data	s8, s9, s10, s11, s12, s13, s14, s15
shopd3jmp:	.data	sd3lsl, sd3lsr, sd3asr, sd3ror
getd3src: .data	wgd0, wgd1, wgd2, wgd3, wgd4, wgd5, wgd6, wgd7
	.data	wgd8, wgd9, wgd10, wgd11, wgd12, wgd13, wgd14, wgd15
cjmp:		.data	dop, wbnv, wbeq, wbne, wblt, wble, wbge, wbgt

;;; ---------------------------------- S ------------------------------------
oploads:	.data 	wldrs, wstrs, wldus, wstus, wadrs
getd3regs:
	.data	gd0s, gd1s, gd2s, gd3s, gd4s, gd5s, gd6s, gd7s
	.data	gd8s, gd9s, gd10s, gd11s, gd12s, gd13s, gd14s, gd15s
ldubases:
	.data	b0s, b1s, b2s, b3s, b4s, b5s, b6s, b7s
	.data	b8s, b9s, b10s, b11s, b12s, b13s, b14s, b15s
stubases:
	.data	s0s, s1s, s2s, s3s, s4s, s5s, s6s, s7s
	.data	s8s, s9s, s10s, s11s, s12s, s13s, s14s, s15s
shopd3jmps:
	.data	sd3lsls, sd3lsrs, sd3asrs, sd3rors
getd3srcs:
	.data	wgd0s, wgd1s, wgd2s, wgd3s, wgd4s, wgd5s, wgd6s, wgd7s
	.data	wgd8s, wgd9s, wgd10s, wgd11s, wgd12s, wgd13s, wgd14s, wgd15s
getd3dests:
	.data	wgdest0s, wgdest1s, wgdest2s, wgdest3s, wgdest4s, wgdest5s,
	.data	wgdest6s, wgdest7s, wgdest8s, wgdest9s, wgdest10s, wgdest11s,
	.data	wgdest12s, wgdest13s, wgdest14s, wgdest15s

;;; assume left hand source in r2, right hand source in r3
	
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
