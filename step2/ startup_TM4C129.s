; Only show the Reset_Handler modifications needed for midpoint
; Add these changes to your existing startup_TM4C129.s file

Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]
                IMPORT  SystemInit
                IMPORT  __main
                
                ; Hardware has already loaded MSP with __initial_sp
                
                ISB     ; Instruction Synchronization Barrier
                LDR     R0, =SystemInit
                BLX     R0      ; Call SystemInit
                
                ; === MIDPOINT MODIFICATIONS START HERE ===
                
                ; Store __initial_user_sp into PSP
                LDR     R0, =__initial_user_sp
                MSR     PSP, R0
                
                ; Change CPU mode to unprivileged thread mode using PSP
                MRS     R0, CONTROL
                ORR     R0, R0, #2      ; Set SPSEL bit to use PSP
                MSR     CONTROL, R0
                ISB                     ; Ensure the mode change takes effect
                
                ; === MIDPOINT MODIFICATIONS END HERE ===
                
                ; Call main
                LDR     R0, =__main
                BX      R0
                ENDP