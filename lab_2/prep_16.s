.data
.align 4
LIST: 
	.word 0x0F0F0F0F
	.word 0x10203040
	.word 0x3F098212

.text
.global _start
_start:
	la s0, LIST
	lw s1, 6(s0)

end:
	j end