;;; -*- mode: asm; compile-command: "wia wave2duane.s" -*-
	.requ	ir,r2
	lea	warm,r0
	trap	$SysOverlay
loop:	mov	wpc,r1		;---------------BEGIN LOOP-----------------
	mov	warm(r1),ir
	shr	$23,ir
	and	$0b11111,ir
	mov 	opjmp(ir),rip
	jmp	loop		; we never get here
		
halt:	
	trap 	$SysHalt
bingo:	mov 	$'!,r0
	trap 	$SysPutChar
	jmp	halt
	
opjmp:	.data	halt,bingo,halt,halt,halt,halt,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt
	.data	halt,halt,halt,halt,halt,halt,halt,halt
	
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
