; SMART RETAIL BILLING SYSTEM
; CS-252 Computer Architecture & Organization


.MODEL SMALL
.STACK 100H

.DATA
; ********* CUSTOMER DATA *********
CUST_NAME   DB 30 DUP('$')           ; Customer name 
NAME_INPUT  DB 31, 32 DUP('$')       ; Input for name

; ********* ITEM ARRAYS *********
; Each item has a fixed position arrays:
; [0] = Headphones
; [2] = Backpack
; [4] = Keyboard
; [6] = Water Bottle
; [8] = PowerBank

PRICES    DW 120, 250, 180, 90, 300        ; 5 items
QTY       DW 5 DUP(0)                      ; quantities bought
TOTALS    DW 5 DUP(0)                      ; item totals
GRAND     DW 0                             ; grand total before discount/tax
DISCOUNT  DW 0                             ; discount amount
TAX       DW 0                             ; tax amount
FINAL     DW 0                             ; final amount after discount+tax
POINTS    DW 0                             ; loyalty points

; ********* MESSAGES *********
ASK_NAME  DB 10,13,'Enter Customer Name: $'
WELCOME   DB 10,13,'Welcome, $'
MENU      DB 10,13,10,13,'         SMART SHOP MENU  $'
ITEM1     DB 10,13,'1. Headphones    Rs.120$'
ITEM2     DB 10,13,'2. Backpack      Rs.250$'
ITEM3     DB 10,13,'3. Keyboard      Rs.180$'
ITEM4     DB 10,13,'4. Water Bottle  Rs.90$'
ITEM5     DB 10,13,'5. Power Bank    Rs.300$'
ASK       DB 10,13,10,13,'Enter item number (1-5): $'
ASKQ      DB 10,13,'Enter quantity: $'
CONFIRM   DB 10,13,'Confirm? (1=Yes, 0=Change): $'
CONTINUE_MSG DB 10,13,10,13,'Add more items? (1=Yes, 0=No): $'
ZERO_CONFIRM DB 10,13,'You entered quantity 0. Cancel this item? (1=Yes, 0=No): $'
INV       DB 10,13,10,13,'========== FINAL INVOICE ==========$'
HEAD      DB 10,13,'Item              Qty   Price   Total$'
LINE      DB 10,13,'-------------------------------------$'
LINE2     DB 10,13,'=====================================$'
GMSG      DB 10,13,'Subtotal:                    Rs.$'
DISCMSG   DB 10,13,'Category Discount:            Rs.$'
TAXMSG    DB 10,13,'Tax (progressive):            Rs.$'
FINALMSG  DB 10,13,'FINAL AMOUNT:                 Rs.$'
POINTMSG  DB 10,13,'Loyalty Points Earned:        $'
THANKMSG  DB 10,13,10,13,'Thank you for shopping with us, $'
NEW_LINE  DB 10,13,'$'
SPACE     DB '   $'
INVALID_MSG DB 10,13,'Invalid option! Please enter 1-5 only.$'
INVALID_QTY_MSG DB 10,13,'Invalid quantity! Please enter 0-9 only.$'

; ********* ITEM NAMES *********
NAME1     DB 'Headphones$'
NAME2     DB 'Backpack  $'
NAME3     DB 'Keyboard  $'
NAME4     DB 'Bottle    $'
NAME5     DB 'PowerBank $'

; ********* TEMP STORAGE *********
TEMP_ITEM   DB 0
TEMP_QTY    DW 0

.CODE

; ********* MACROS *********
PRINT MACRO MSG
    MOV AH, 9
    LEA DX, MSG
    INT 21H
ENDM

NEWLINE MACRO
    MOV AH, 9
    LEA DX, NEW_LINE
    INT 21H
ENDM

; ********* GET CUSTOMER NAME *********
GET_NAME PROC
    PRINT ASK_NAME
    
    ; Get customer name using string input
    MOV AH, 0AH
    LEA DX, NAME_INPUT
    INT 21H
    
    ; Copy name to CUST_NAME
    LEA SI, NAME_INPUT + 2      ; Start of actual input
    LEA DI, CUST_NAME
    MOV CL, NAME_INPUT + 1       ; Length of input
    MOV CH, 0
    REP MOVSB
    
    PRINT WELCOME
    PRINT CUST_NAME
    NEWLINE
    RET
GET_NAME ENDP

; ********* DISPLAY MENU *********
DISPLAY PROC
    PRINT MENU
    PRINT ITEM1
    PRINT ITEM2
    PRINT ITEM3
    PRINT ITEM4
    PRINT ITEM5
    RET
DISPLAY ENDP

; ********* PRINT NUMBER *********
PRINTNUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    CMP AX, 0
    JNE NUM_NONZERO
    MOV DL, 48
    MOV AH, 2
    INT 21H
    JMP NUM_DONE
    
NUM_NONZERO:
    MOV CX, 0
    MOV BX, 10
    
NUM_DIVIDE:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE NUM_DIVIDE
    
NUM_PRINT:
    POP DX
    ADD DL, 48
    MOV AH, 2
    INT 21H
    LOOP NUM_PRINT
    
NUM_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINTNUM ENDP

; ********* GET INPUT WITH CONFIRMATION *********
GETINPUT PROC
GET_ITEM:
    PRINT ASK
    MOV AH, 1
    INT 21H
    SUB AL, 48
    
    CMP AL, 1
    JB  INVALID_INPUT
    CMP AL, 5
    JA  INVALID_INPUT
    
    MOV TEMP_ITEM, AL
    MOV BL, AL
    
GET_QTY:
    NEWLINE
    PRINT ASKQ
    MOV AH, 1
    INT 21H
    SUB AL, 48
    
    ; Quantity validation (allow 0-9)
    CMP AL, 0
    JB  INVALID_QTY
    CMP AL, 9
    JA  INVALID_QTY
    
    MOV AH, 0
    MOV TEMP_QTY, AX
    MOV CX, AX
    
    ;********* ZERO QUANTITY CONFIRMATION *********
    CMP CX, 0
    JNE SHOW_CONFIRMATION
    
    ; If quantity = 0, ask for confirmation
    PRINT ZERO_CONFIRM
    MOV AH, 1
    INT 21H
    SUB AL, 48
    CMP AL, 1
    JE  CANCEL_ITEM      ; User confirms to cancel
    JMP GET_QTY          ; User wants to change quantity
    
CANCEL_ITEM:
    MOV AL, 0
    RET                  ; Return without adding item
    
SHOW_CONFIRMATION:
    ;********* SHOW PURCHASE CONFIRMATION *********
    NEWLINE
    
    ; Show what user selected
    MOV AL, TEMP_ITEM
    CMP AL, 1
    JE  SHOW1
    CMP AL, 2
    JE  SHOW2
    CMP AL, 3
    JE  SHOW3
    CMP AL, 4
    JE  SHOW4
    JMP SHOW5
    
SHOW1: PRINT NAME1
      JMP SHOW_QTY
SHOW2: PRINT NAME2
      JMP SHOW_QTY
SHOW3: PRINT NAME3
      JMP SHOW_QTY
SHOW4: PRINT NAME4
      JMP SHOW_QTY
SHOW5: PRINT NAME5

SHOW_QTY:
    PRINT SPACE
    MOV AX, TEMP_QTY
    CALL PRINTNUM
    PRINT SPACE
    PRINT CONFIRM        ; Print confirmation message once
    
    MOV AH, 1
    INT 21H
    SUB AL, 48
    CMP AL, 1
    JNE GET_ITEM         ; If not confirmed, go back
    
    ; Store quantity
    DEC BL
    MOV BH, 0
    SHL BX, 1
    MOV AX, QTY[BX]
    ADD AX, TEMP_QTY
    MOV QTY[BX], AX
    
    MOV AL, 1
    RET
    
INVALID_INPUT:
    PRINT INVALID_MSG
    NEWLINE
    JMP GET_ITEM
    
INVALID_QTY:
    PRINT INVALID_QTY_MSG
    NEWLINE
    JMP GET_QTY

GETINPUT ENDP

; ********* CALCULATE ITEM TOTALS *********
CALCULATE PROC
    MOV GRAND, 0
    MOV CX, 5
    XOR SI, SI
    
CALC_LOOP:
    MOV AX, PRICES[SI]
    MOV BX, QTY[SI]
    MUL BX
    MOV TOTALS[SI], AX
    ADD GRAND, AX
    ADD SI, 2
    LOOP CALC_LOOP
    RET
CALCULATE ENDP

; ********* APPLY CATEGORY DISCOUNT *********
; Minimum purchase of Rs 200 required for discount
APPLY_DISCOUNT PROC
    MOV DISCOUNT, 0
    
    ; Check minimum purchase requirement
    CMP GRAND, 200
    JL  NO_DISCOUNT
    
    ; Electronics: Headphones + PowerBank (5% discount)
    MOV AX, TOTALS[0]      ; Headphones total
    ADD AX, TOTALS[8]      ; PowerBank total
    MOV BX, 5
    MUL BX
    MOV BX, 100
    DIV BX
    ADD DISCOUNT, AX
    
    ; Keyboard (Stationery - 2% discount)
    MOV AX, TOTALS[4]      ; Keyboard total (index 4)
    MOV BX, 2
    MUL BX
    MOV BX, 100
    DIV BX
    ADD DISCOUNT, AX
    
NO_DISCOUNT:
    RET
APPLY_DISCOUNT ENDP

; ********* APPLY PROGRESSIVE TAX *********
APPLY_TAX PROC
    MOV AX, GRAND
    SUB AX, DISCOUNT        ; Taxable amount
    MOV BX, AX
    
    CMP BX, 500
    JLE TAX_2
    CMP BX, 1000
    JLE TAX_5
    MOV CX, 8               ; >1000 ? 8% tax
    JMP TAX_CALC
    
TAX_2: 
    MOV CX, 2               ; <=500 ? 2% tax
    JMP TAX_CALC
    
TAX_5: 
    MOV CX, 5               ; <=1000 ? 5% tax
    
TAX_CALC:
    MOV AX, BX
    MUL CX
    MOV CX, 100
    DIV CX
    MOV TAX, AX
    RET
APPLY_TAX ENDP

; ********* CALCULATE FINAL & LOYALTY POINTS *********
CALC_FINAL PROC
    MOV AX, GRAND
    SUB AX, DISCOUNT
    ADD AX, TAX
    MOV FINAL, AX
    
    ; Loyalty points = FINAL / 100
    MOV BX, 100
    XOR DX, DX
    DIV BX
    MOV POINTS, AX
    RET
CALC_FINAL ENDP

; ********* PRINT INVOICE *********
INVOICE PROC
    PRINT INV
    PRINT HEAD
    PRINT LINE
    
    MOV CX, 5
    XOR SI, SI
    
INV_LOOP:
    NEWLINE
    MOV AX, QTY[SI]
    CMP AX, 0
    JE  INV_SKIP
    
    ; Print item name
    CMP SI, 0
    JE  PNAME1
    CMP SI, 2
    JE  PNAME2
    CMP SI, 4
    JE  PNAME3
    CMP SI, 6
    JE  PNAME4
    CMP SI, 8
    JE  PNAME5
    
PNAME1: PRINT NAME1
        JMP INV_QTY
PNAME2: PRINT NAME2
        JMP INV_QTY
PNAME3: PRINT NAME3
        JMP INV_QTY
PNAME4: PRINT NAME4
        JMP INV_QTY
PNAME5: PRINT NAME5

INV_QTY:
    PRINT SPACE
    PRINT SPACE
    MOV AX, QTY[SI]
    CALL PRINTNUM
    
    PRINT SPACE
    PRINT SPACE
    MOV AX, PRICES[SI]
    CALL PRINTNUM
    
    PRINT SPACE
    PRINT SPACE
    MOV AX, TOTALS[SI]
    CALL PRINTNUM
    
INV_SKIP:
    ADD SI, 2
    LOOP INV_LOOP
    
    PRINT LINE
    PRINT GMSG
    MOV AX, GRAND
    CALL PRINTNUM
    
    PRINT DISCMSG
    MOV AX, DISCOUNT
    CALL PRINTNUM
    
    PRINT TAXMSG
    MOV AX, TAX
    CALL PRINTNUM
    
    PRINT LINE2
    PRINT FINALMSG
    MOV AX, FINAL
    CALL PRINTNUM
    
    PRINT LINE2
    PRINT POINTMSG
    MOV AX, POINTS
    CALL PRINTNUM
    
    NEWLINE
    PRINT THANKMSG
    PRINT CUST_NAME
    NEWLINE
    NEWLINE
    
    RET
INVOICE ENDP

; ********* MAIN PROGRAM *********
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Get customer name first
    CALL GET_NAME
    
    ; Display menu
    CALL DISPLAY
    
INPUT_LOOP:
    CALL GETINPUT
    CMP AL, 0          ; If zero quantity cancellation
    JE  SKIP_ADD
    
CONTINUE_CHECK:
    ; Ask if user wants to continue shopping
    PRINT CONTINUE_MSG
    MOV AH, 1
    INT 21H
    SUB AL, 48
    CMP AL, 1
    JE  INPUT_LOOP
    
DO_INVOICE:
    CALL CALCULATE
    CALL APPLY_DISCOUNT
    CALL APPLY_TAX
    CALL CALC_FINAL
    CALL INVOICE
    
    MOV AH, 4CH
    INT 21H

SKIP_ADD:
    JMP CONTINUE_CHECK

MAIN ENDP

END MAIN




