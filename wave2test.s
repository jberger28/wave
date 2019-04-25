;;; intel program:
;;; read in a warm program, search for halt
	lea	warm,r0
	trap	$SysOverlay
	mov	$0,r1
loop:
	cmp	$0x06800000,warm(r1)
	mov	warm(r1), r2

	mov	r2, r3
	and	$1023, r3
	
	mov	r2, r4
	sar	$9, r4
	and	$63, r4

	mov	r2, r5
	sar	$0xE, r5
	and	$1, r5

	mov	r2, r8
	sar	$0xF, r8
	and	$4, r8

	mov	r2, r9
	sar	$19, r9
	and	$4, r9
	
	mov	r2, r10
	sar 	$23, r10

	mov	r10, r11
	cmp	$11, r11

	jne	test
	mov	$1, r0
	trap	$SysPutNum
	trap	$SysHalt
	
	
	mov	warm(r1),r0
	trap	$SysPutNum
	mov	$'\n,r0
	trap	$SysPutChar
	je	overloop
	add	$1,r1
   	jmp	loop

test:
	mov	$0, r0
overloop:
	trap	$SysPutNum
	trap	$SysHalt
	


;;; Warm Overlay loading area
	.origin 1000
warm:
