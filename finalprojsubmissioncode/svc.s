		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

SYSTEMCALLTBL	EQU	0x20007B00

	IMPORT	_timer_start
	IMPORT	_signal_handler
	IMPORT	_kalloc
	IMPORT	_kfree

	EXPORT	_syscall_table_init
_syscall_table_init
	LDR	R0, =SYSTEMCALLTBL
	
	; #0: Reserved - set to 0
	MOV	R1, #0
	STR	R1, [R0, #0]
	
	; #1: alarm() -> _timer_start
	LDR	R1, =_timer_start
	STR	R1, [R0, #4]
	
	; #2: signal() -> _signal_handler
	LDR	R1, =_signal_handler
	STR	R1, [R0, #8]
	
	; #3: malloc() -> _kalloc
	LDR	R1, =_kalloc
	STR	R1, [R0, #12]
	
	; #4: free() -> _kfree
	LDR	R1, =_kfree
	STR	R1, [R0, #16]
	
	BX	LR

	EXPORT	_syscall_table_jump
_syscall_table_jump
	; Check valid range
	CMP	R7, #0
	BLE	_syscall_invalid
	CMP	R7, #4
	BGT	_syscall_invalid
	
	; Use jump table
	LDR	R12, =SYSTEMCALLTBL
	LDR	R12, [R12, R7, LSL #2]
	CMP	R12, #0
	BEQ	_syscall_invalid
	BX	R12

_syscall_invalid
	BX	LR
	
	END