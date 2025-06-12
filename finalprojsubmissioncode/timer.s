		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Timer Register Definitions
STCTRL		EQU	0xE000E010		; SysTick Control and Status Register
STRELOAD	EQU	0xE000E014		; SysTick Reload Value Register
STCURRENT	EQU	0xE000E018		; SysTick Current Value Register

STCTRL_STOP	EQU	0x00000004		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 0, Bit 0 (ENABLE) = 0
STCTRL_GO	EQU	0x00000007		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 1, Bit 0 (ENABLE) = 1
STRELOAD_MX	EQU	0x00FFFFFF		; MAX Value = 1/16MHz * 16M = 1 second
SIGALRM		EQU	14

; System Variables
SECOND_LEFT	EQU	0x20007B80		; Seconds left for alarm()
USR_HANDLER	EQU	0x20007B84		; Address of user-given signal handler function

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer initialization
	EXPORT	_timer_init
_timer_init
	; Stop SysTick
	LDR	R0, =STCTRL_STOP
	LDR	R1, =STCTRL
	STR	R0, [R1]
	
	; Load maximum reload value (1 second)
	LDR	R0, =STRELOAD_MX
	LDR	R1, =STRELOAD
	STR	R0, [R1]

	; Clear current value register
	LDR	R0, =STCURRENT
	MOV	R1, #0
	STR	R1, [R0]

	MOV	pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer start
	EXPORT	_timer_start
_timer_start
	; Get previous seconds value and store new one
	LDR	R1, =SECOND_LEFT
	LDR	R2, [R1]
	STR	R0, [R1]
	
	; Enable SysTick
	LDR	R3, =STCTRL
	LDR	R4, =STCTRL_GO
	STR	R4, [R3]
	
	; Clear current value register
	LDR	R5, =STCURRENT
	MOV	R6, #0
	STR	R6, [R5]
	
	; Return previous seconds value
	MOV	R0, R2
	MOV	pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update (called from SysTick interrupt)
	EXPORT	_timer_update
_timer_update
	; Decrement seconds counter
	LDR	R1, =SECOND_LEFT
	LDR	R2, [R1]
	SUB	R2, R2, #1
	STR	R2, [R1]
	
	; Check if timer expired
	CMP	R2, #0
	BNE	_timer_update_done
	
	; Stop the timer
	LDR	R3, =STCTRL
	LDR	R4, =STCTRL_STOP
	STR	R4, [R3]
	
	; Call user handler function
	LDR	R5, =USR_HANDLER
	LDR	R6, [R5]
	
	STMFD	sp!, {r1-r12,lr}
	BLX	R6
	LDMFD	sp!, {r1-r12,lr}

_timer_update_done
	MOV	pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Signal handler registration
	EXPORT	_signal_handler
_signal_handler
	; Check if signal is SIGALRM
	CMP	R0, #SIGALRM
	BNE	return_Res
	
	; Store new handler and return previous
	LDR	R2, =USR_HANDLER
	LDR	R3, [R2]
	STR	R1, [R2]
	MOV	R0, R3

return_Res
	MOV	pc, lr
	
	END