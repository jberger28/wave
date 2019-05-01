;;; -*- Mode: asm; compile-command: "wia wave2.s" -*-
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

loop:	mov	wpc,r1		;---------------BEGIN LOOP-----------------
	mov	warm(r1),ir
	cmp	$0x06800000, ir
	je	halt
	mov	ir, src
	sar	$15, src
	and	$0b1111, src
	
	mov	r2, dest
	sar	$19, dest
	and	$0b1111, dest

	mov	r2, opcode
	sar	$23, opcode
	and	$0b11111, opcode

	mov	getsrc(src), rip
	
loopd:	mov	ir, temp
	shr	$14,temp
	and	$1,temp
	mov	temp, r0
	cmp	$0,temp
	je	bit14
	jne	shifts

bit14:
	mov	ir, exp
	sar	$9, exp
	and	$0b11111, exp

	mov	ir, value
	and	$0b11111111, value

	shl	exp, value
	
	mov	opjmp(opcode), rip
	
shifts:
	mov	ir, temp
	sar	$12, temp
	and	$0b11, temp
	mov	shjmp(temp), rip

shiftNum:
	mov	ir, shop
	sar	$10, shop
	and	$0b11, shop

	mov	ir, reg2
	sar	$6, reg2
	and	$0b1111, reg2

	mov	ir, shiftCount
	and	$0b111111, shiftCount

getNumReg2:	mov	getreg2(reg2), rip

shiftNum2:	mov	shopVjmp(shop), rip
shiftNum3:	mov	reg2, value
		mov	opjmp(opcode), rip

shiftReg:
	mov	ir, shop
	sar	$10, shop
	and	$0b11, shop

	mov 	ir, reg
	and	$0b1111, reg
	mov	getreg(reg), rip
	
getReg2:mov	ir, reg2
	sar	$6, reg2
	and	$0b1111, reg2
	mov	getR2(reg2), rip

shiftReg2:	mov	shopRjmp(shop), rip
shiftReg3:	mov	reg2, value
		mov	opjmp(opcode), rip
	
fma:
	mov	ir, reg2
	sar	$6, reg2
	and	$0b1111, reg2
	mov	getfma2(reg2), rip
	
getReg3:mov	ir, reg3
	and	$0b1111, reg3
	mov	getfma3(reg3), rip
	
fma2:


	
halt:	trap	$SysHalt

wadd:
	add	value, src
	mov	regjmp(dest), rip

wadc:
wsub:
	sub	value, src
	mov	regjmp(dest), rip
wcmp:
weor:
worr:
wand:
wtst:
wmul:
wmla:
wdiv:
wmov:
	mov	ir, temp
	shr	$14,temp
	and	$1,temp
	mov	temp, r0
	cmp	$0,temp

	je	wmovV
	mov	reg2, src
	mov	regjmp(dest), rip
	
wmovV:	mov	value, src
	mov	regjmp(dest), rip
wmvn:
	
wswi:	mov	swijmp(value), rip

gs0:	mov	wr0, src
	jmp	loopd
gs1:	mov	wr1, src
	jmp	loopd
gs2:	mov	wr2, src
	jmp	loopd
gs3:	mov	wr3, src
	jmp	loopd
gs4:	mov	wr4, src
	jmp	loopd
gs5:	mov	wr5, src
	jmp	loopd
gs6:	mov	wr6, src
	jmp	loopd
gs7:	mov	wr7, src
	jmp	loopd
gs8:	mov	wr8, src
	jmp	loopd
gs9:	mov	wr9, src
	jmp	loopd
gs10:	mov	wr10, src
	jmp	loopd
gs11:	mov	wr11, src
	jmp	loopd
gs12:	mov	wr12, src
	jmp	loopd
gs13:	mov	wr13, src
	jmp	loopd
gs14:	mov	wr14, src
	jmp	loopd
gs15:	mov	wr15, src
	jmp	loopd

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
	add	$1, wpc
	jmp	loop
rr1:	mov	src, wr1
	add	$1, wpc
	jmp	loop
rr2:	mov	src, wr2
	add	$1, wpc
	jmp	loop
rr3:	mov	src, wr3
	add	$1, wpc
	jmp	loop
rr4:	mov	src, wr4
	add	$1, wpc
	jmp	loop
rr5:	mov	src, wr5
	add	$1, wpc
	jmp	loop
rr6:	mov	src, wr6
	add	$1, wpc
	jmp	loop
rr7:	mov	src, wr7
	add	$1, wpc
	jmp	loop
rr8:	mov	src, wr8
	add	$1, wpc
	jmp	loop
rr9:	mov	src, wr9
	add	$1, wpc
	jmp	loop
rr10:	mov	src, wr10
	add	$1, wpc
	jmp	loop
rr11:	mov	src, wr11
	add	$1, wpc
	jmp	loop
rr12:	mov	src, wr12
	add	$1, wpc
	jmp	loop
rr13:	mov	src, wr13
	add	$1, wpc
	jmp	loop
rr14:	mov	src, wr14
	add	$1, wpc
	jmp	loop
rr15:	mov	src, wr15
	add	$1, wpc
	jmp	loop

sVlsl:	shl	shiftCount, reg2
	jmp	shiftNum3
sVlsr:	shr	shiftCount, reg2
	jmp	shiftNum3
sVasr:	sar	shiftCount, reg2
	jmp	shiftNum3
sVror: 	mov	$32,shop
	sub	shiftCount,shop
	mov	reg2,temp
	shl	shop,temp
	shr	shiftCount,reg2
	xor	temp,reg2
	jmp	shiftNum3

sRlsl:	shl	reg, reg2
	jmp	shiftReg3
sRlsr:	shr	reg, reg2
	jmp	shiftReg3
sRasr:	sar	reg, reg2
	jmp	shiftReg3
sRror:	mov	$32,shop
	sub	reg,shop
	mov	reg2,temp
	shl	shop,temp
	shr	reg,reg2
	xor	temp,reg2
	jmp	shiftNum3

gchar:	trap	$SysGetChar
	mov	r0, wr0
	add	$1, wpc
	jmp	loop
gnum:	trap	$SysGetNum
	mov	r0, wr0
	add	$1, wpc
	jmp	loop
pchar:	mov	wr0, r0
	trap	$SysPutChar
	add	$1, wpc
	jmp	loop
pnum:	mov	wr0, r0
	trap	$SysPutNum
	add	$1, wpc
	jmp	loop
ent:	trap	$SysEntropy
	mov	r0, wr0
	add	$1, wpc
	jmp	loop
over:	mov	wr0, r0
	trap	$SysOverlay
	add	$1, wpc
	jmp	loop
pla:	mov	wr0, r0
	trap	$SysPLA
	mov	r0, wr0
	add	$1, wpc
	jmp	loop
	
shjmp:	.data	shiftNum, shiftReg, fma
opjmp:	.data	wadd,wadc,wsub,wcmp,weor,worr,wand
	.data	wtst,wmul,wmla,wdiv,wmov,wmvn,wswi,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt

getsrc: .data	gs0, gs1, gs2, gs3, gs4, gs5, gs6, gs7
	.data	gs8, gs9, gs10, gs11, gs12, gs13, gs14, gs15

;;; Get reg2 for reg
getR2: 	.data	grerr0, grerr1, grerr2, grerr3, grerr4, grerr5, grerr6, grerr7
		.data	grerr8, grerr9, grerr10, grerr11, grerr12, grerr13, grerr14, grerr15

getreg: .data	gr0, gr1, gr2, gr3, gr4, gr5, gr6, gr7
	.data	gr8, gr9, gr10, gr11, gr12, gr13, gr14, gr15

;;; Get reg2 for shift count
getreg2: 	.data	gnrr0, gnrr1, gnrr2, gnrr3, gnrr4, gnrr5, gnrr6, gnrr7
		.data	gnrr8, gnrr9, gnrr10, gnrr11, gnrr12, gnrr13, gnrr14, gnrr15

;;; Get reg2 for reg3
getfma2: .data	grr0, grr1, grr2, grr3, grr4, grr5, grr6, grr7
	.data	grr8, grr9, grr10, grr11, grr12, grr13, grr14, grr15

getfma3: .data	grrr0, grrr1, grrr2, grrr3, grrr4, grrr5, grrr6, grrr7
	.data	grrr8, grrr9, grrr10, grrr11, grrr12, grrr13, grrr14, grrr15

regjmp:	.data	rr0, rr1, rr2, rr3, rr4, rr5, rr6, rr7
	.data	rr8, rr9, rr10, rr11, rr12, rr13, rr14, rr15

shopVjmp:	.data	sVlsl, sVlsr, sVasr, sVror
shopRjmp:	.data	sRlsl, sRlsr, sRasr, sRror
swijmp:		.data	halt, gchar, gnum, pchar, pnum, ent, over, pla

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
		
;;; ------------------write no code below this line------------------------
warm:	 			; Warm overlay is loaded here
