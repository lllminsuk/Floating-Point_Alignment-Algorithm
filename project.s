	AREA project, CODE, READONLY	; Name this block of code
		ENTRY	; Mark first instruction to execute

main
	ADR r0, dataset		; dataset address
	LDR r6, Address1	; r6 = 0x00040000
	MOV r7, r6			; r7 = r7 = 0x0004000
	
Loop
	LDR r1, [r0], #4	; Load data
	CMP r1, #0		; compare with 0: check end of data
	; if data is finish, start sorting	
	BEQ InsertionSortmain		; Insertion Sorting
	;BEQ BubbleSortmain			; Bubble Sorting
	;BEQ SelectionSortmain		; Selection Sorting
	
Sign	; get sign bit
	MOV r2, r1, LSR #31	; get sign bit
	CMP r2, #1		; check data is negative number
	RSBEQ r1, r1, #0	; change negative to positive
	MOV r3, #127	; exponent bit start 127
	MOV r4, r1	; copy data
Exponent	; get exponent bit
	CMP r4, #1		; compare data with 1
	MOVNE r4, r4, LSR #1	; shift right
	ADDNE r3, r3, #1		; add 1 to exponent 
	BNE Exponent	; loop
Mantissa	; get mantissa bit
	CMP r3, #150	; compare exponent with 150
	; if expoinent is greater than 150
	SUBGE r5, r3, #150	; r5 = exponent - 150
	MOVGE r4, r1, LSR r5	; shift right r5 -> mantissa
	; if expoinent is less than 150
	RSBLT r5, r3, #150	; r5 = 150 - exponent
	MOVLT r4, r1, LSL r5	; shift left r5 -> mantissa
	SUB r4, r4, #0x800000	; remove '1.' from mantissa
	ADD r4, r4, r2, LSL #31	; add sign bit
	ADD r4, r4, r3, LSL #23	; add exponent bit
	STR r4, [r6], #4	; store floating point data to memory
	B Loop	; loop

; Insertion Sort
InsertionSortmain
	MOV r0, r7			; r0 = r7 = 0x0004000
InsertionSort
	ADD r0, r0, #4		; r0 = r0 + 4
	LDR r11, [r0]		; load r1 from mem[r0]
	CMP r11, #0			; compare with 0
	BEQ Done		; if r11 == 0, go to 'Done' branch
	MOV r1, r7		; r1 = 0x0004000
InsertionSortCompare
	LDR r10, [r1]	; load r10 from mem[r1]
	MOV r12, #0		; r12 = 0
	BL Compare		; Compare Function
	CMP r12, #1		; compare
	BEQ Insert		; if r12 == 1, go to 'Insert' branch
	ADD r1, r1, #4		; r1 = r1 + 4
	CMP r0, r1			; compare
	BEQ InsertionSort	; if r0 == r1, go to 'InsertionSort' branch
	BNE InsertionSortCompare	; else go to 'InsertionSortCompare' branch
Insert
	SWP r10, r11, [r1]	; load r10 from mem[r1] and store r11 to mem[r1]
	MOV r11, r10	; r11 = r10
	ADD r1, r1, #4		; r1 = r1 + 4
	CMP r0, r1			; compare
	BNE Insert	; go to 'Insert' branch
	STREQ r11, [r1]	; if r0 == r1, store r11 to mem[r1]
	BEQ InsertionSort	; and go to 'InsertionSort'branch


; Bubble Sort
BubbleSortmain
	MOV r0, r7		; r0 = r7 = 0x0004000
	SUB r6, r6, #4	; r6 = r6 - 4 : end of floation point address
	CMP r0, r6		; compare
	BEQ Done	; if r9 == 4, go to 'Done' branch
	LDR r10, [r0]	; load r10 from mem[r0]
BubbleSort
	LDR r11, [r0, #4]	; load r11 from mem[r0+4]
	MOV r12, #0			; r12 = 0
	BL Compare		; Compare function
	CMP r12, #1		; compare
	STREQ r11, [r0]		; if r12 == 1, store r11 to mem[r0]
	STREQ r10, [r0, #4]	; and store r10 to mem[r0+4]
	MOVNE r10, r11		; else r10 = r11
	ADD r0, r0, #4		; r0 = r0 + 4
	CMP r0, r6		; compare r0 with r6
	BNE BubbleSort	; if r0 != r6 go to 'BubbleSort' branch
	BEQ BubbleSortmain	; else go to 'BubbleSortmain' branch

; Selection Sort
SelectionSortmain
	MOV r0, r7		; r0 = r7 = 0x0004000
	SUB r5, r6, #4	; r5 = r6 - 4
SelectionSort
	LDR r10, [r0]	; load r10 from mem[r0]
	ADD r1, r0, #4	; r1 = r0 + 4
	LDR r11, [r1], #4	; load r11 from mem[r1] and r1 = r1 + 4
	MOV r12, #0		; r12 = 0
	BL Compare		; Compare function
	CMP r12, #1		; compare
	SUBEQ r2, r1, #4		; if r12 == 1, r2 = r1 - 4
	MOVEQ r10, r11			; and r10 = r11
	MOVNE r2, r0			; else r2 = r0
SelectionSortCompare
	CMP r1, r6			; compare r1 with r6
	BEQ SelectionSwap		; r1 == r6, go to 'SelectionSwap' branch
	LDR r11, [r1], #4		; load r11 from mem[r1] and r1 = r1 + 4
	MOV r12, #0			; r12 = 0
	BL Compare		; Compare function
	CMP r12, #1		; compare r12 with 1
	SUBEQ r2, r1, #4	; if r12 == 1, r2 = r1 - 4
	MOVEQ r10, r11		; and r10 = r11
	B SelectionSortCompare	; go to 'SelectionSortCompare' branch
SelectionSwap
	LDR r11, [r0]	; load r11 from mem[r0]
	STR r10, [r0], #4	; store r10 to mem[r0] and r0 = r0 + 4
	STR r11, [r2]	; store r11 to mem[r2]
	CMP r0, r5		; compare r0 with r5
	BNE SelectionSort	; if r0 != r5, go to 'SelectionSort' branch
	
Done
	MOV pc,#0	; pc = 0
	
; Compare function
Compare	
	; get sign bit
	MOV r8, r10, LSR #31	; r8 : sign bit of r8
	MOV r9, r11, LSR #31	; r9 : sign bit of r9
	CMP r8, r9	; compare
	MOVLT r12, #1	; if r8 > r9, r12 = 1
	MOVNE pc, lr	; if r8 != r9 , pc = lr
	CMP r8, #1	; compare sign bit with 1
	BEQ Negative	; sign bit == 1, go to 'Negative' branch
Positive
	CMP r10, r11	; compare r10 with r11
	MOVGT r12, #1	; if r10 > r11, r12 = 1
	MOV pc, lr	; pc = lr
Negative	
	CMP r10, r11	; compare r10 with r11
	MOVLT r12, #1	; if r10 < r11, r12 = 1
	MOV pc, lr	; pc = lr

; dataset
dataset dcd 0x80000000, 0x7fffffff, 0xcd673e3b, 0xb362cba6, 0x8fe19e57, 0x22e18fb1, 0xf5b96847, 0xbf80d69d, 0x55d32a7f, 0x10437074, 0x6d4fada7, 0x1c9843d9, 0x3a1bf32e, 0x419f0dfa, 0x44bc2b18, 0x61fd6527, 0xc4ea9f92, 0xe353198d, 0x24df1a8e, 0xd8e33020, 0x97e74f5b, 0xe3386941, 0x94664b52, 0x53ba154, 0x16f0ed45, 0xe2eaff07, 0xd7e52a41, 0x786f1e1f, 0x7d26fcbb, 0x6f50bc67, 0x20608c4a, 0xe49ddb52, 0x2e891632, 0x6dff3d3e, 0xd60b3c7, 0x4ff4416d, 0xc4d40344, 0x9ea55b38, 0xdf8ded46, 0x4d5ec942, 0xb911d0ca, 0x7463103c, 0xafbab3c7, 0xb8e81f0f, 0xe4018378, 0xd066e80, 0xb1731768, 0xb836fb33, 0x1c64a8ba, 0xb7836282, 0x61ffbc10, 0x8d267963, 0x1f5198ed, 0x8be76673, 0xc0cc6724, 0x1ada78ab, 0xae0fe980, 0x77a711be, 0x50ffe226, 0x8a8afe35, 0xb9b1f44e, 0x6219001c, 0x450bff7, 0x882bd4f5, 0x4bc245c, 0x51f03ae5, 0x19b22bf8, 0x5014c8dd, 0x859d0e1, 0x9596a914, 0x83684997, 0x1f43748a, 0x62b3ce4, 0x510aa77a, 0x6558b34a, 0x66f80604, 0x45184050, 0x4400d69, 0x9f733564, 0x9433075, 0xcbbe5010, 0x47144155, 0x1cad93d8, 0xcae00d8f, 0x39e43000, 0x770d27be, 0xf6a7c535, 0x1ff06b7, 0x44e46ad9, 0x91e2afb6, 0xb10ebb2e, 0x191736bd, 0xed05a74, 0x70f88b77, 0xcffcc11, 0x60ce6508, 0xf8e3c509, 0x11e37c6c, 0x4ab8f910, 0xc0bf0055, 0x9d8100be, 0x77309a5f, 0x2e69eeb6, 0xcd71fc22, 0xdcc1e55f, 0x89bc64c3, 0xd81e12eb, 0x2d01a47d, 0xf313a93a, 0xce9da625, 0x86e5b017, 0x7d64abd8, 0xea4dac2c, 0xfbc8b85b, 0x6c17606d, 0x6e4b9b8e, 0x97593f84, 0xfea593d7, 0xd0abd23e, 0xd70b3817, 0x72c7729, 0x70cdb01e, 0xd3fbdf83, 0xe7bd7cc7, 0xf2ec2107, 0xe03c6f80, 0x842e7e1f, 0x98f94c63, 0x98d6c153, 0xebdd2156, 0x314d7c14, 0x46b23743, 0x56006327, 0xaa448950, 0xeca05dbf, 0xeadf0124, 0x594945c8, 0x25afa67d, 0xbfa8247, 0x8425ad7f, 0xdaa68631, 0x27c88377, 0x3a2d0908, 0x86d07ab5, 0x9806a9ef, 0x890a5b57, 0x649264fb, 0x84404aa4, 0xd61505c5, 0x4368fcb7, 0x644f2577, 0x7d530014, 0xcbfe4bc3, 0x8b4ebe7e, 0xcd38d28e, 0xa3b275c3, 0x4e65c8c6, 0x2f2640e3, 0x566d9b5b, 0x4f94d2ba, 0x226042c3, 0x52fc1526, 0xcfb32576, 0x47818b, 0x8789f12a, 0xe7c2c68e, 0xe657ce68, 0x9706e0ab, 0x4a703e6, 0x5856625c, 0x81e435b8, 0x96a0ca2a, 0x4662fa26, 0x62eab29d, 0x5abe9fc2, 0x3d9fecd, 0xa1ac2271, 0x55a5adcb, 0xc9a4facb, 0x683f52a2, 0xd39b5303, 0x1519bf20, 0x6814497f, 0x5c26d381, 0x7fe32253, 0x65ed8726, 0x4558ac4a, 0xc8e2c85e, 0x8af80e0e, 0xeffdfec3, 0x771ab240, 0xca6090f4, 0x79a78602, 0xfcd18f45, 0xb3d82428, 0xb0b3f240, 0x2e0ad995, 0x8e95f4fe, 0xf720dab4, 0xadaa577c
        dcd 0x6b8643ff, 0x5fcf610a, 0x3a6bcbfa, 0xf19a6b96, 0xbef0741f, 0xf3cf918e, 0x85009223, 0x332d6871, 0x34bbaed3, 0xe207be9, 0x46448270, 0xbf19242, 0xf914dd03, 0x11865c1b, 0x4d2cf712, 0x3f7161ef, 0xace6e0dc, 0xff139866, 0x385d04bd, 0x9ba2e0b6, 0xde2d1d7d, 0x3d84714, 0x8373e52, 0x79c8a1b5, 0xcc14e773, 0x28db562b, 0xdfd19164, 0xeb8d6db3, 0x3a64c53f, 0x418ab40b, 0xe6049c25, 0xa474f10, 0x9b17a469, 0x1a3b7795, 0xe6098324, 0x66f12950, 0x59f6dce, 0x5a556981, 0x9b23a2a3, 0xb95a7b08, 0x5a7e7a2d, 0xb84f2a35, 0x4b5b08b, 0x5135780b, 0x1c6ed2d6, 0xfddd14d8, 0x54433537, 0xe886b2db, 0x84530d8d, 0x64f8ad2b, 0x45328318, 0x1751a550, 0x4ef8335a, 0x70f98054, 0x4d9529d8, 0xe6940d6f, 0x9d611ac5, 0xe631d981, 0x6359db44, 0x2b2db279, 0x9b4f1ce6, 0x81ce9b45, 0xbd6432cb, 0x15e3bd57, 0x4ebe7b8e, 0x8e93dee1, 0x9a1bef7a, 0x65f425cf, 0x940a8252, 0xbac51373, 0xd86e846c, 0xf2b798cb, 0x5603139f, 0x715dfd, 0x90c768da, 0x4e86b969, 0x22d43647, 0x7b6ffc25, 0x2b967d44, 0x99f8e62a, 0x4b68994a, 0x78578970, 0xcca9e38d, 0x4cf4cb87, 0x42146a72, 0x3cfda9c, 0x55e5e2b4, 0x7d0abe5e, 0xdfb6a3d1, 0x2671bec9, 0xea79b5ef, 0xfdf10aab, 0x3c017960, 0x17cb7d89, 0x34e027fe, 0x91ee460f, 0x3c564584, 0x372c8fe0, 0x12ae5a82, 0x41f8b98f, 0x71fcf84a, 0x19517fdc, 0xc92d5e63, 0x28a593fd, 0x272677c2, 0x322d8fa0, 0x4fa05a57, 0xb23fe9f5, 0xe7ca0810, 0x646de316, 0x37e7b43, 0x2742b973, 0xa3e0cee8, 0x12f11141, 0xa83f88f8, 0x7fb939b, 0x8910e9bf, 0xfc47dab7, 0xfde6ff9e, 0x72f13d4c, 0x2f134277, 0x2a397502, 0xad1bbb14, 0xffea63, 0x49585d7d, 0x13d8270e, 0xa1c0a80d, 0xf75e871e, 0x19d1fc46, 0xab292895, 0x4af5010, 0x2730fbd2, 0x810ff15d, 0xb01624b5, 0x96816762, 0xed9ee9a4, 0x5ce57d3, 0xe04be979, 0x812c6654, 0x4f715c8c, 0x85d81e4c, 0xed1dfd54, 0x6e3bea53, 0x6b95f3e0, 0x90f220e3, 0x89f906b0, 0x9fcacb55, 0x2307b673, 0x5413c0d0, 0xd251a821, 0xde3d9cc9, 0xd2c3a43, 0x8c34eb68, 0x452c1a4a, 0x1a3b8fae, 0x763856a, 0xdefde547, 0xc8db65c4, 0x2fbf3ac1, 0x69f52d49, 0xc0c81204, 0xed851758, 0x4ba03fc, 0x75f0a0f2, 0x144d580a, 0x24fecbe5, 0x31e9861c, 0x7c28d935, 0x11695d8b, 0xf4de9083, 0x1379e3a9, 0xe1a8427e, 0x78d25ce9, 0xf1ebb09a, 0x989d7446, 0xe8b103a6, 0xa68b9679, 0x1b65feb6, 0xb809fca0, 0xaab08ab8, 0xaf30911d, 0xd235599d, 0xac9e59b4, 0x9c4cd2d7, 0x6ada7666, 0x33d099f8, 0x9675ff78, 0x18ad50bc, 0x4cb956e8, 0x16ad71b7, 0x54da4527, 0x6ac01345, 0xc7a9baa9, 0x4a785d2a, 0xf226edb3, 0xd2c27d7b, 0x44af3250, 0xaa7a403, 0xa9b31df9, 0x64c8f49e
        dcd 0x45c5be03, 0xbc8dbdaa, 0x8e7794e, 0x23b79b64, 0xa82c8d9a, 0x57a6c389, 0xf924a451, 0x490741cf, 0x34387ac2, 0x69f5df70, 0xda00edc2, 0xdadfeafa, 0x92c95578, 0xd8cf86bf, 0xfcd6ef1a, 0xc301672c, 0xb4318242, 0xfe8e4744, 0x48bacc7c, 0x692fb6ca, 0xa7a89a72, 0x82a9f501, 0xca9fb8f0, 0xda15fc5e, 0xe7046a3a, 0x19c563dc, 0x92a02eae, 0x85bda9ba, 0xe12c38a9, 0xcf4be876, 0x412097b, 0xd20f90be, 0x375f01d2, 0xc46ce9b7, 0x25cd36fa, 0xb3e3d013, 0x52aa2cd5, 0x7fee1977, 0x455f83cc, 0x7089c1, 0xbaa00b9f, 0x9b66b50e, 0x28fe4138, 0x20f79ab, 0xdf8ee874, 0x28640729, 0xd44c9db, 0xae294d9a, 0x94965f72, 0x9fc5c904, 0xb603c802, 0xaee54020, 0x26f49efa, 0x791d83a6, 0x857632af, 0xb50257da, 0xad02fa08, 0xe1900635, 0xb24ccdc5, 0x883ce528, 0x575f3298, 0xa2de66c2, 0xeb0fa3aa, 0x4f019d41, 0xd03e5b25, 0x994f05e, 0x2fe1115c, 0x37ce8b3, 0x6528f2c0, 0x4b756769, 0xdea958ee, 0xed61b554, 0x683629, 0x95826ff3, 0x9ad6ae6b, 0x5007e84c, 0x38421339, 0xe561e728, 0x226d5b12, 0x7600394a, 0x4ece7d91, 0xea9f6c50, 0xc4a1bf1, 0xdc2a0bbd, 0x859e58ad, 0xf7ac1deb, 0x4d97371, 0x65f77e62, 0x99567aee, 0x312895ca, 0xef63b96e, 0x9e1f0137, 0x59f52b68, 0x69457a63, 0xf0f14285, 0xf90953fe, 0x655e1ec3, 0xe2c33d07, 0x9ee7ef14, 0x144aacac, 0x00000000

; Adress1
Address1 & &40000

	END ; end