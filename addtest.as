mov	r0, #2
ldm	r0, r1, asr #3
swi	#SysPutNum
swi	#SysHalt
