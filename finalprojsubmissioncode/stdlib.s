        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB

        EXPORT  _bzero
_bzero
        PUSH    {R1-R3,LR}
        MOV     R2, #0
ZERO_LOOP
        CMP     R1, #0
        BEQ     ZERO_DONE
        STRB    R2, [R0], #1
        SUBS    R1, R1, #1
        B       ZERO_LOOP
ZERO_DONE
        MOV     R0, R3
        POP     {R1-R3,LR}
        BX      LR

        EXPORT  _strncpy
_strncpy
        PUSH    {R1-R4,LR}
        MOV     R3, R0
COPY_LOOP
        CMP     R2, #0
        BEQ     COPY_DONE
        LDRB    R4, [R1], #1
        STRB    R4, [R0], #1
        SUBS    R2, R2, #1
        CMP     R4, #0
        BNE     COPY_LOOP
COPY_DONE
        MOV     R0, R3
        POP     {R1-R4,LR}
        BX      LR

        EXPORT  _memcpy
_memcpy
        PUSH    {R1-R4,LR}
        MOV     R3, R0
MEMCPY_LOOP
        CMP     R2, #0
        BEQ     MEMCPY_DONE
        LDRB    R4, [R1], #1
        STRB    R4, [R0], #1
        SUBS    R2, R2, #1
        B       MEMCPY_LOOP
MEMCPY_DONE
        MOV     R0, R3
        POP     {R1-R4,LR}
        BX      LR

        EXPORT  _malloc
_malloc
        PUSH    {R1-R3,LR}
        MOV     R7, #3
        SVC     #0
        POP     {R1-R3,LR}
        BX      LR

        EXPORT  _free
_free
        PUSH    {R1-R3,LR}
        MOV     R7, #4
        SVC     #0
        POP     {R1-R3,LR}
        BX      LR

        EXPORT  _alarm
_alarm
        PUSH    {R1-R3,LR}
        MOV     R7, #1
        SVC     #0
        POP     {R1-R3,LR}
        BX      LR

        EXPORT  _signal
_signal
        PUSH    {R1-R3,LR}
        MOV     R7, #2
        SVC     #0
        POP     {R1-R3,LR}
        BX      LR

        END
