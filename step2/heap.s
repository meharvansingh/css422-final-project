    AREA    |.text|, CODE, READONLY
    THUMB

    EXPORT  malloc
    EXPORT  free
    EXPORT  init_heap

    ALIGN

; Constants
HEAP_SIZE       EQU     0x100     ; 256 bytes
BLOCK_HEADER    EQU     8         ; 4 bytes for size, 4 for free flag

    AREA    |.bss|, NOINIT, ALIGN=3
heap_space
    SPACE   HEAP_SIZE

heap_end

;--------------------------------------------------
init_heap
; Initializes one big free block
    PUSH    {LR}

    LDR     R0, =heap_space
    LDR     R1, =HEAP_SIZE

    ; store block size
    STR     R1, [R0]

    ; mark as free
    MOVS    R2, #1
    STR     R2, [R0, #4]

    POP     {PC}
;--------------------------------------------------
malloc
; Input: R0 = requested size
; Output: R0 = pointer to usable memory, or 0 if fail
    PUSH    {R4-R7, LR}

    LDR     R4, =heap_space        ; current block ptr
malloc_loop
    LDR     R5, [R4]               ; R5 = block size
    LDR     R6, [R4, #4]           ; R6 = free flag

    CMP     R6, #1                 ; is it free?
    BNE     malloc_next
    CMP     R5, R0                 ; is it big enough?
    BLO     malloc_next

    ; mark as used
    MOVS    R7, #0
    STR     R7, [R4, #4]

    ; return usable mem (after header)
    ADD     R0, R4, #BLOCK_HEADER
    B       malloc_done

malloc_next
    ADD     R4, R4, R5             ; move to next block
    LDR     R7, =heap_end
    CMP     R4, R7
    BLO     malloc_loop

    ; fail
    MOVS    R0, #0

malloc_done
    POP     {R4-R7, PC}
;--------------------------------------------------
free
; Input: R0 = pointer to allocated mem (after header)
    PUSH    {LR}

    ; move back to header
    SUB     R0, R0, #BLOCK_HEADER
    MOVS    R1, #1
    STR     R1, [R0, #4]

    POP     {PC}
