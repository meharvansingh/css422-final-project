AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _bzero( void *s, int n )
; Parameters
;	s 		- pointer to the memory location to zero-initialize
;	n		- a number of bytes to zero-initialize
; Return value
;   none
		EXPORT	_bzero
_bzero
		; R0 = pointer to buffer (s)
		; R1 = number of bytes (n)
		PUSH	{R4-R5, LR}		; Save registers
		
		MOV		R4, R0			; Save original pointer
		MOV		R5, #0			; Value to write (0)
		
bzero_loop
		CBZ		R1, bzero_done	; If n == 0, we're done
		STRB	R5, [R0], #1	; Store byte 0 and increment pointer
		SUBS	R1, R1, #1		; Decrement count
		B		bzero_loop		; Continue loop
		
bzero_done
		MOV		R0, R4			; Restore original pointer
		POP		{R4-R5, PC}		; Restore and return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char* _strncpy( char* dest, char* src, int size )
; Parameters
;   	dest 	- pointer to the buffer to copy to
;	src	- pointer to the zero-terminated string to copy from
;	size	- a total of n bytes
; Return value
;   dest
		EXPORT	_strncpy
_strncpy
		; R0 = dest
		; R1 = src  
		; R2 = size
		PUSH	{R4-R7, LR}		; Save registers
		
		MOV		R4, R0			; Save dest for return value
		MOV		R5, #0			; Flag: 0 = not found null, 1 = found null
		
strncpy_loop
		CBZ		R2, strncpy_done ; If size == 0, we're done
		
		CMP		R5, #1			; Have we found null terminator?
		BEQ		strncpy_pad		; If yes, pad with zeros
		
		LDRB	R6, [R1], #1	; Load byte from src and increment
		STRB	R6, [R0], #1	; Store to dest and increment
		
		CBZ		R6, strncpy_found_null ; If byte was 0, set flag
		
		SUBS	R2, R2, #1		; Decrement size
		B		strncpy_loop	; Continue copying
		
strncpy_found_null
		MOV		R5, #1			; Set null found flag
		SUBS	R2, R2, #1		; Decrement size
		B		strncpy_loop	; Continue (will pad now)
		
strncpy_pad
		MOV		R6, #0			; Value to pad with
		STRB	R6, [R0], #1	; Store zero and increment
		SUBS	R2, R2, #1		; Decrement size
		B		strncpy_loop	; Continue padding
		
strncpy_done
		MOV		R0, R4			; Return original dest pointer
		POP		{R4-R7, PC}		; Restore and return
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _malloc( int size )
; Parameters
;	size	- #bytes to allocate
; Return value
;   	void*	a pointer to the allocated space
		EXPORT	_malloc
_malloc
		; For midpoint: just return (stub)
		MOV		PC, LR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _free( void* addr )
; Parameters
;	size	- the address of a space to deallocate
; Return value
;   	none
		EXPORT	_free
_free
		; For midpoint: just return (stub)
		MOV		PC, LR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unsigned int _alarm( unsigned int seconds )
; Parameters
;   seconds - seconds when a SIGALRM signal should be delivered to the calling program	
; Return value
;   unsigned int - the number of seconds remaining until any previously scheduled alarm
;                  was due to be delivered, or zero if there was no previously schedul-
;                  ed alarm. 
		EXPORT	_alarm
_alarm
		; For midpoint: just return (stub)
		MOV		PC, LR		
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _signal( int signum, void *handler )
; Parameters
;   signum - a signal number (assumed to be 14 = SIGALRM)
;   handler - a pointer to a user-level signal handling function
; Return value
;   void*   - a pointer to the user-level signal handling function previously handled
;             (the same as the 2nd parameter in this project)
		EXPORT	_signal
_signal
		; For midpoint: just return (stub)
		MOV		PC, LR	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		END