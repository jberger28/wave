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

	mov	ir, temp
	shr	$14,temp
	and	$1,temp
	mov	temp, r0
	cmp	$0,temp
	jne	bit14
	je	shifts

getSrc:	mov	getsrc(src), rip	
getReg:	mov	getreg(reg), rip
getReg2:mov	getreg2(reg2), rip
getReg3:mov	getreg3(reg3), rip
	
loopd:	mov 	opjmp(ir),rip
	jmp	loop		; we never get here

bit14:
	mov	ir, exp
	sar	$9, exp
	and	$0b11111, exp

	mov	ir, value
	and	$0b11111111, value

	mov	opjmp(opcode), rip
	
shifts:
	mov	ir, temp
	sar	$12, temp
	and	$0b111, temp

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
	
shiftReg:
	mov	ir, shop
	sar	$10, shop
	and	$0b11, shop

	mov	ir, reg2
	sar	$6, reg2
	and	$0b1111, reg2

	mov	ir, reg
	and	$0b1111, reg
	
fma:
	mov	ir, reg2
	sar	$6, reg2
	and	$0b1111, reg2

	mov	ir, reg3
	and	$0b1111, reg3
	
	
halt:	

wadd:
	add	value, src
	mov	src, r0
	trap	$SysPutNum
	trap	$SysHalt

wadc:
wsub:
wcmp:
weor:
worr:
wand:
wtst:
wmul:
wmla:
wdiv:
wmov:
	mov	regjmp(dest), rip		
wmvn:
wswi:	

gs0:
	mov	wr0, src
	jmp	getReg
gr0:
	mov	wr0, reg2
	jmp	loopd
gr1:
gr2:
gr3:
gr4:
gr5:
gr6:
gr7:
gr8:
gr9:
gr10:
gr11:
gr12:
gr13:
gr14:
gr15:

rr0:
	mov	src, wr0
	add	$1, wpc
	jmp	loop
	
shjmp:	.data	shiftNum, shiftReg, fma
opjmp:	.data	wadd,wadc,wsub,wcmp,weor,worr,wand
	.data	wtst,wmul,wmla,wdiv,wmov,halt,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt

getsrc: .data	gs0
	;; , gs1, gs2, gs3, gr4, gr5, gr6, gr7
	;; 	.data	gr8, gr9, gr10, gr11, gr12, gr13, gr14, gr15

getreg: .data	gr0, gr1, gr2, gr3, gr4, gr5, gr6, gr7
	.data	gr8, gr9, gr10, gr11, gr12, gr13, gr14, gr15

getreg2: .data	gr0, gr1, gr2, gr3, gr4, gr5, gr6, gr7
	.data	gr8, gr9, gr10, gr11, gr12, gr13, gr14, gr15

getreg3: .data	gr0, gr1, gr2, gr3, gr4, gr5, gr6, gr7
	.data	gr8, gr9, gr10, gr11, gr12, gr13, gr14, gr15

regjmp:	.data	rr0
	;; , rr1, rr2, rr3, rr4, rr5, rr6, rr7
	;; .data	rr8, rr9, rr10, rr11, rr12, rr13, rr14, rr15
	
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
