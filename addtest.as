mov	r0, #1
add	r0,r0, #5
swi	#SysGetChar
swi	#SysGetNum
swi	#SysPutChar
swi	#SysPutNum
swi	#SysEntropy
swi	#SysHalt
