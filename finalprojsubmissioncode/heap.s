		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Layout Constants
HEAP_TOP	EQU	0x20001000
HEAP_BOT	EQU	0x20004FE0
MAX_SIZE	EQU	0x00004000		; 16KB = 2^14
MIN_SIZE	EQU	0x00000020		; 32B  = 2^5

MCB_TOP		EQU	0x20006800		; 2^10B = 1K Space
MCB_BOT		EQU	0x20006BFE
MCB_ENT_SZ	EQU	0x00000002		; 2B per entry
MCB_TOTAL	EQU	512			; 2^9 = 512 entries

INVALID		EQU	-1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Control Block Initialization
	EXPORT	_heap_init
_heap_init
	LDR	R0, =MCB_TOP
	LDR	R1, =MAX_SIZE
	STR	R1, [R0]
	
	LDR	R0, =MCB_TOP+0x4
	LDR	R1, =0x20006C00
	MOV	R2, #0x0
		
_heap_mcb_init
	CMP	R0, R1
	BGE	_heap_init_done
	
	STR	R2, [R0]
	ADD	R0, R0, #1
	STR	R2, [R0]
	ADD	R0, R0, #2
	B	_heap_mcb_init

_heap_init_done
	MOV	pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
	EXPORT	_kalloc
_kalloc
	PUSH	{lr}
	CMP	R0, #32
	BGE	_ralloc_init
	MOV	R0, #32

_ralloc_init
	LDR	R1, =MCB_TOP
	LDR	R2, =MCB_BOT
	LDR	R3, =MCB_ENT_SZ
	BL	_ralloc
	
	POP	{lr}
	MOV	R0, R12
	MOV	pc, lr

_ralloc		
	PUSH	{lr}
	
	SUB	R4, R2, R1
	ADD	R4, R4, R3
	ASR	R5, R4, #1
	ADD	R6, R1, R5
	LSL	R7, R4, #4
	LSL	R8, R5, #4
	MOV	R12, #0x0
	
	CMP	R0, R8
	BGT	_no_alloc
	
	PUSH	{r0-r8}
	SUB	R2, R6, R3
	BL	_ralloc
	POP	{r0-r8}
	
	CMP	R12, #0x0
	BEQ	_ralloc_right
	
	LDR	R9, [R6]
	AND	R9, R9, #0x01
	CMP	R9, #0
	BEQ	_return_heap_addr
	B	_ralloc_done

_ralloc_right
	PUSH	{r0-r8}
	MOV	R1, R6
	BL	_ralloc
	POP	{r0-r8}
	B	_ralloc_done

_return_heap_addr
	STR	R8, [R6]
	B	_ralloc_done

_no_alloc
	LDR	R9, [R1]
	AND	R9, R9, #0x01
	CMP	R9, #0
	BNE	_return_invalid
	
	LDR	R9, [R1]
	CMP	R9, R7
	BLT	_return_invalid
	
	ORR	R9, R7, #0x01
	STR	R9, [R1]
	
	LDR	R9, =MCB_TOP
	LDR	R10, =HEAP_TOP
	SUB	R1, R1, R9
	LSL	R1, R1, #4
	ADD	R10, R10, R1
	MOV	R12, R10
	B	_ralloc_done

_return_invalid
	MOV	R12, #0
	B	_ralloc_done

_ralloc_done
	POP	{lr}
	BX	LR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
	EXPORT	_kfree
_kfree
	PUSH	{lr}
	
	MOV	R1, R0
	LDR	R2, =HEAP_TOP
	LDR	R3, =HEAP_BOT

	CMP	R1, R2
	BLT	_invalid_address
	CMP	R1, R3
	BGT	_invalid_address

	; Calculate MCB address
	LDR	R4, =MCB_TOP
	SUB	R5, R1, R2
	ASR	R5, R5, #4
	ADD	R5, R4, R5

	MOV	R0, R5
	PUSH	{R1-R12}
	BL	_rfree
	POP	{R1-R12}
	CMP	R0, #0
	BEQ	_invalid_address
	
	POP	{LR}
	MOV	pc, lr

_invalid_address
	MOV	R0, #0
	POP	{LR}
	MOV	pc, lr

_rfree
	PUSH	{lr}
	
	LDR	R1, [R0]
	LDR	R2, =MCB_TOP
	SUB	R3, R0, R2
	
	ASR	R1, R1, #4
	MOV	R4, R1
	LSL	R1, R1, #4
	MOV	R5, R1
	
	STR	R1, [R0]

	SDIV	R6, R3, R4
	AND	R6, R6, #1
	CMP	R6, #0
	BNE	_odd_case

	; Even case - check right buddy
	ADD	R6, R0, R4
	LDR	R7, =MCB_BOT
	CMP	R6, R7
	BGE	return_zero
	
	LDR	R7, [R6]
	
	AND	R8, R7, #1
	CMP	R8, #0
	BNE	_free_done

	ASR	R7, R7, #5
	LSL	R7, R7, #5
	CMP	R7, R5
	BNE	_free_done

	STR	R8, [R6]
	LSL	R5, #1
	STR	R5, [R0]
	
	BL	_rfree
	B	_free_done

_odd_case
	; Odd case - check left buddy
	SUB	R6, R0, R4
	CMP	R2, R6
	BGT	return_zero
	
	LDR	R7, [R6]
	
	AND	R8, R7, #1
	CMP	R8, #0
	BNE	_free_done

	ASR	R7, R7, #5
	LSL	R7, R7, #5
	CMP	R7, R5
	BNE	_free_done
	
	STR	R8, [R0]
	LSL	R5, #1
	STR	R5, [R6]

	MOV	R0, R6
	BL	_rfree
	B	_free_done

return_zero
	MOV	R0, #0

_free_done
	POP	{lr}
	BX	lr

	END