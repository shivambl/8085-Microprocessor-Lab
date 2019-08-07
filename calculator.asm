cpu "8085.tbl"
hof "int8"
org 9000h
MAIN:
; SET VALUE OF A TO ONE OF THE 
; FOLLOWING TO REPRESENT OPERATION
CPI 00H
JZ ADD_8_BY_8
CPI 01H
JZ ADD_16_BY_16
CPI 02H
JZ SUB_8_BY_8
CPI 03H
JZ SUB_16_BY_16
CPI 04H
JZ MUL_8_BY_8
CPI 05H
JZ MUL_16_BY_16
CPI 06H
JZ DIV_8_BY_8
CPI 07H
JZ DIV_16_BY_16
JMP END

;;;;;;;;;;;;;;;;;;;;;;;
ADD_8_BY_8:
; HL = L + E
MVI D, 00H
MVI H, 00H
JMP ADD_16_BY_16

ADD_16_BY_16:
; HL = DE + HL
DAD D   ; HL = HL+DE, CY=CARRY
JMP END
;;;;;;;;;;;;;;;;;;;;;;;

SUB_8_BY_8:
;L = L-E
MVI D, 00H
MVI H, 00H
JMP SUB_16_BY_16

SUB_16_BY_16:
;HL = HL-DE
MOV A, L    ; A = L
SUB E       ; A = A-E, CY=BORROW
MOV L, A    ; L = A
MOV A, H    ; A = H
SBB D       ; A = A-D-CY
MOV H, A    ; H = A
JMP END
;;;;;;;;;;;;;;;;;;;;;;;

MUL_8_BY_8:
;HL = D*E
MOV C, D			; C = D
MVI D, 00H			; D = 0
MVI H, 00H			; H = 0
MVI L, 00H			; L = 0
TEMP_MUL_8_BY_8:	; Temp label
DAD D				; HL = HL+E
DCR C				; C--
JNZ TEMP_MUL_8_BY_8	; LOOP
JMP END

MUL_16_BY_16:
; [8500H-8503H] = DE*HL
SPHL            ; HL=EMPTY DE=1NO; SP=2ND NO
LXI H, 0000H    ;HL = 0
LXI B, 0000H    ;BC = 0
ADD_HL:
DAD SP          ;HL = HL + 2ND NO
JNC CHECK_D     ;JUMP IF NO CARRY
INX B           ; BC++
CHECK_D:
DCX D           ;DE--
MOV A, E        ;A = E
ORA D           ;CHECK IF DE = 0
JNZ ADD_HL      ; JUMP IF NOT ZERO
SHLD 8500H      ; STORE AT 8500-01H
MOV L, C        ; MOVE C TO L FOR WRITING TO MEM
MOV H, B        ; MOVE B TO H FOR WRITING TO MEM
SHLD 8502H      ; WRITE AGAIN ( AT 8502-03H )
JMP END
;;;;;;;;;;;;;;;;;;;;;;;


DIV_8_BY_8:
;C = L/E
;L = L%E
MVI D, 00H
MVI H, 00H
JMP DIV_16_BY_16

DIV_16_BY_16:
;BC = HL/DE
;HL = HL%DE
LXI B, 0000H
TEMP_DIV:
MOV A, L		; A = L
SUB E			; A = A-E, CY=BORROW
MOV L, A		; L = A
MOV A, H		; A = H
SBB D			; A = H-D-CY, CY=BORROW
MOV H, A		; H = A
JC TEMP2_DIV	; CAN NOT SUBTRACT ANYMORE, FINISH SUBROUTINE
INX B			; BC++
JMP TEMP_DIV	; SUBTRACT AGAIN
TEMP2_DIV:
DAD D			; HL WAS SUBTRACTED 1 EXTRA TIME(THAT IS WHY BORROW = 1, AND YOU JUMPED HERE). SO, ADD DE ONCE TO GET HL=REMAINDER
JMP END
;;;;;;;;;;;;;;;;;;;;;;;

END:
RST 5