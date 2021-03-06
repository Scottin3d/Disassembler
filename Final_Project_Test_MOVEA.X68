*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Scott Shirley
* Date       :
* Description:
*-----------------------------------------------------------
 
* Variables and EQUs
start           EQU     $1000               *start address
stack           EQU     $A000               *stack address   
CR              EQU     $0D                 *carriage return
LF              EQU     $0A                 *line feed
goodflag        EQU     1
badflag         EQU     0
length          EQU     0
task1           EQU     01                  *
task2           EQU     02                  *
print_buffer    EQU $8000
**op_table        EQU     $A100               *OPCODE JUMP TABLE
**ea_table        EQU     $A200               *EA JUMP TABLE
**adr_table       EQU     $A300               *ADDRESS JUMP TABLE

*-----------------------------------------------------------
*beging program
*-----------------------------------------------------------
            ORG     start
            BSR     intro_msg           *print intro message
main        BSR     CLEAR               *clear all registers
            LEA     stack, SP           *load stack pointer
            LEA     buffer, A2          *set buffer for input
            LEA     print_buffer, A4
            MOVEA.L A2,A6 
            
            BSR     U_INPUT
            
            BSR     CLEAR
            
            BRA     MAIN_LOOP
            

*-----------------------------------------------------------
*subroutines
*-----------------------------------------------------------
intro_msg
            MOVE.B  #13,D0
            LEA     intro,A1
            MOVE.W  i_length,D1
            TRAP    #15
endIntro    RTS

GET_WORD
            MOVE.W (A0), D1
ENDGET_WORD RTS

MAIN_LOOP
            BSR     GET_WORD *** GETS THE NEXT WORD ****
            ADDI #1, D7
            CMP #10, D7
            ** PRINT THE BUFFER BEQ PRINT **
            LEA op_table, A3
            MOVE.L A0, D0 *** LOADS THE FIRST INSTRUCTION INTO D0 ****
            **MOVE.L D0, (A4)+ ***LOADS INSRUCTION ADDRESS INTO PRINT BUFFER ***
            CLR.L D0  *** CLEARS D0 ***
            **MOVE.W #$0909, (A4)+ *** ADDS "\T" TO THE PRINT BUFFER ***
            
            
            
            MOVE.W D1, D2 *** LOADS THE INSTRUCTION INTO D2 ***
            ASR #$8, D2 *** SHIFTS THE WORD DATA TO GET MOST SIG BYTE ***
            ASR #$4, D2 *** SHIFTS BY 4 TO GET THE MOST SIG HEXA BIT ***
            MULU #6, D2 *** MULTIPLIES THE INDEX BY 6 TO GET INDEX ***
            
            JSR 0(A3, D2)
            
            
            
            
            
            BSR     END *** ENDS THE PROGRAM ***
            


op_table        JMP         code0000
                JMP         code0001
                JMP         code0010
                JMP         code0011
                JMP         code0100
                JMP         code0101
                JMP         code0110
                JMP         code0111
                JMP         code1000
                JMP         code1001
                JMP         code1010
                JMP         code1011
                JMP         code1100
                JMP         code1101
                JMP         code1110
                JMP         code1111
                
                
                
code0000       STOP        #$2700


**********************************************************************
**              code0001 handles MOVE.B Instructions                **
**********************************************************************
** - stores "MOVE" into the print buffer                            **
** - stores ".B\t\t" into the print buffer                          **
** - checks bits 11-9 (register number)  D2  [destination]          **
** - checks bits 8 - 6 (Ea mode)  D3   [destination]                **
** - jumps to ea table                                              **
** - stores ", " into the print buffer                              **
** - checks bits 5 - 3 (Ea mode) D3 [source]                        **
** - checks bits 2 - 0 (register number) D2 [source]                **
** - jumps to ea table                                              **
**********************************************************************

code0001       MOVE.L #$4D4F5645, (A4)+ ** Loads "MOVE" INTO PRINT_BUFFER
               MOVE.L #$2E420909, (A4)+ **Loads ".B" into the print_buffer 
               
               CLR.L D2
               
               MOVE.W D1, D2
               AND.L #%0000000000000111, D2 ** checks the source reg number **

               
               MOVE.W D1, D3
               AND.L #%0000000000111000, D3 ** checks the source mode type **
               ASR.W #$3, D3 ** shifts the bits to the right **
               
               LEA ea_table, A3 ** loads ea_table for jmp **
               MULU #6,D3 ** gets the index of the jmp table **
               
               JSR 0(A3, D3) ** jumps to the Jump Table **
               
               MOVE.W #$2C20, (A4)+
               
               CLR D2   ** clears registers for source reg and mode 
               CLR D3
               
               MOVE.W D1, D2
               AND.L #%0000111000000000, D2 ** checks the register number ***
               LSR.W #$8, D2 **shifts the bits to the right
               LSR.B #$1, D2
               
               MOVE.W D1, D3
               AND.L #%0000000111000000, D3 ** checks the addressing mode **
               LSR.W #$6, D3 ** shifts the bits to the right 
              
               
               LEA ea_table, A3 ** loads the ea_table **
               MULU #6, D3 ** gets the index of the jump table **
               
               JSR 0(A3, D3) **jumps to the ea_table for source dissassembly **
               MOVE.W #$2000, (A4)+
               JSR PRINT
               RTS ** Returns to sender **
               
code0010       MOVE.L #$4D4F5645, (A4)+ ** Loads "MOVE" INTO PRINT_BUFFER

               MOVE.W D1, D3    *Check the destination mode to see if addressing*
               AND.L #%0000000111000000, D3 
               CMPI.L #$0040, D3 ** compares to see if addressing mode
               BNE.S code0010_cont **branches if destination mode is not addressing register
               MOVE.W #$412E, (A4)+ **Loads "A." into the print_buffer
               MOVE.W #$4C09, (A4)+ **Loads "L   " into the print_buffer
               BRA code0010_cont2 **branches back to code
               
               
code0010_cont  MOVE.L #$2E4C0909, (A4)+ **Loads ".L" into the print_buffer 
               
code0010_cont2 CLR.L D2
               
               MOVE.W D1, D2
               AND.L #%0000000000000111, D2 ** checks the source reg number **

               
               MOVE.W D1, D3
               AND.L #%0000000000111000, D3 ** checks the source mode type **
               ASR.W #$3, D3 ** shifts the bits to the right **
               
               LEA ea_table, A3 ** loads ea_table for jmp **
               MULU #6,D3 ** gets the index of the jmp table **
               
               JSR 0(A3, D3) ** jumps to the Jump Table **
               
               MOVE.W #$2C20, (A4)+
               
               CLR D2   ** clears registers for source reg and mode 
               CLR D3
               
               MOVE.W D1, D2
               AND.L #%0000111000000000, D2 ** checks the register number ***
               LSR.W #$8, D2 **shifts the bits to the right
               LSR.B #$1, D2
               
               MOVE.W D1, D3
               AND.L #%0000000111000000, D3 ** checks the addressing mode **
               LSR.W #$6, D3 ** shifts the bits to the right 
              
               
               LEA ea_table, A3 ** loads the ea_table **
               MULU #6, D3 ** gets the index of the jump table **
               
               JSR 0(A3, D3) **jumps to the ea_table for source dissassembly **
               MOVE.W #$2000, (A4)+
               JSR PRINT
               RTS ** Returns to sender **

code0011       MOVE.L #$4D4F5645, (A4)+ ** Loads "MOVE" INTO PRINT_BUFFER

               MOVE.W D1, D3    *Check the destination mode to see if addressing*
               AND.L #%0000000111000000, D3 
               CMPI.L #$0040, D3 ** compares to see if addressing mode
               BNE.S code0010_cont **branches if destination mode is not addressing register
               MOVE.W #$412E, (A4)+ **Loads "A." into the print_buffer
               MOVE.W #$5709, (A4)+ **Loads "W   " into the print_buffer
               BRA code0011_cont2 **branches back to code
               
code0011_cont  MOVE.L #$2E570909, (A4)+ **Loads ".W" into the print_buffer 
               
code0011_cont2 CLR.L D2
               
               MOVE.W D1, D2
               AND.L #%0000000000000111, D2 ** checks the source reg number **

               
               MOVE.W D1, D3
               AND.L #%0000000000111000, D3 ** checks the source mode type **
               ASR.W #$3, D3 ** shifts the bits to the right **
               
               LEA ea_table, A3 ** loads ea_table for jmp **
               MULU #6,D3 ** gets the index of the jmp table **
               
               JSR 0(A3, D3) ** jumps to the Jump Table **
               
               MOVE.W #$2C20, (A4)+
               
               CLR D2   ** clears registers for source reg and mode 
               CLR D3
               
               MOVE.W D1, D2
               AND.L #%0000111000000000, D2 ** checks the register number ***
               LSR.W #$8, D2 **shifts the bits to the right
               LSR.B #$1, D2
               
               MOVE.W D1, D3
               AND.L #%0000000111000000, D3 ** checks the addressing mode **
               LSR.W #$6, D3 ** shifts the bits to the right 
              
               
               LEA ea_table, A3 ** loads the ea_table **
               MULU #6, D3 ** gets the index of the jump table **
               
               JSR 0(A3, D3) **jumps to the ea_table for source dissassembly **
               MOVE.W #$2000, (A4)+
               JSR PRINT
               RTS ** Returns to sender **



code0100       STOP        #$2700
code0101       STOP        #$2700
code0110       STOP        #$2700
code0111       STOP        #$2700
code1000       STOP        #$2700
code1001       STOP        #$2700
code1010       STOP        #$2700

code1011       MOVE.L #$434D502E, (A4)+ **Loads "CMP." into the print buffer**
               MOVE.W D1, D3
               AND.L #%0000000111000000, D3
               LSR.L #$6, D3
               
               CMPI.W #$0000, D3
               BEQ.S code1011_000
               
               CMPI.W #$0001, D3
               BEQ.S code1011_001
               
               CMPI.W #$0002, D3
               BEQ.S code1011_010
               
               BRA BADINST
               
code1011_000   MOVE.W #$4209, (A4)+
               BRA code1011_cont
               
code1011_001   MOVE.W #$5709, (A4)+
               BRA code1011_cont
               
code1011_010   MOVE.W #$4C09, (A4)+
               BRA code1011_cont
               
code1011_cont  CLR.L D2
               CLR.L D3
               
               MOVE.W D1, D2
               AND.L #%0000000000000111, D2 ** checks the source reg number **

               
               MOVE.W D1, D3
               AND.L #%0000000000111000, D3 ** checks the source mode type **
               ASR.W #$3, D3 ** shifts the bits to the right **
               
               LEA ea_table, A3 ** loads ea_table for jmp **
               MULU #6,D3 ** gets the index of the jmp table **
               
               JSR 0(A3, D3) ** jumps to the Jump Table **
               
               MOVE.W #$2C20, (A4)+
               
               CLR D2   ** clears registers for source reg and mode 
               CLR D3
               
               MOVE.W D1, D2
               AND.L #%0000111000000000, D2 ** checks the register number ***
               LSR.W #$8, D2 **shifts the bits to the right
               LSR.B #$1, D2
               
               MOVE.W D1, D3
               AND.L #%0000000111000000, D3 ** checks the addressing mode **
               LSR.W #$6, D3 ** shifts the bits to the right 
              
               
               LEA ea_table, A3 ** loads the ea_table **
               MULU #6, D3 ** gets the index of the jump table **
               
               JSR 0(A3, D3) **jumps to the ea_table for source dissassembly **
               MOVE.W #$2000, (A4)+
               JSR PRINT
               RTS ** Returns to sender **
             
                    


code1100       STOP        #$2700
code1101       STOP        #$2700

*******************************************ASR***LSL****************************************
code1110       MOVE.L D1, D3
               AND.L #%1111111111000000, D3
               CMPI.L #$E3C0, D3
               BEQ.S code1110_lsl1
               CMPI.L #$E0C0, D3
               BEQ code1110_asr1
               MOVE.L D1, D3
               AND.L #%1111000100011000, D3
               CMPI.L #$E108, D3
               BEQ code1110_lsl2
               CMPI.L #$E000, D3
               BEQ code1110_asr2
               
               

code1110_lsl1 MOVE.L #$4C534C09, (A4)+
              CLR.L D2
              CLR.L D3
               
              MOVE.W D1, D2
              AND.L #%0000000000000111, D2 ** checks the source reg number **

               
              MOVE.W D1, D3
              AND.L #%0000000000111000, D3 ** checks the source mode type **
              ASR.W #$3, D3 ** shifts the bits to the right **
              
              CMP.W #$0001,D3 
              BLE BADINST
              
              CMP.W #$0007, D2
              BNE lsl1_cont
              CMP.W #$0001, D3
              BLE lsl1_cont
              BRA BADINST
               
lsl1_cont     LEA ea_table, A3 ** loads ea_table for jmp **
              MULU #6,D3 ** gets the index of the jmp table **
               
              JSR 0(A3, D3) ** jumps to the Jump Table **
              JSR PRINT
              RTS ** Returns to sender **
              
              

code1110_lsl2 MOVE.L #$4C534C2E, (A4)+
              CLR.L D2
              CLR.L D3
              MOVE.L D1, D3
              AND.W #$00C0, D3
              LSR.W #$6, D3
              JSR SIZE2BUFFER
              
              CLR.W D3
              MOVE.L D1, D3
              AND.W #$0020, D3
              LSR.W #$5, D3
              CMP.W #$0, D3
              BEQ shift_i
              BRA shift_r
              
shift_i       MOVE.B #$09, (A4)+
              MOVE.B #$23, (A4)+
              MOVE.L D1, D3
              AND.W #$0E00, D3
              LSR.L #$8, D3
              LSR.L #$1, D3
              ADD.B #$1E, D3
              MOVE.B D3, (A4)+
              MOVE.B #$2C, (A4)+
              MOVE.L D1, D2
              AND.W #$0007, D2
              CLR.L D3
              LEA ea_table, A3 ** loads ea_table for jmp **
              JSR 0(A3, D3) ** jumps to the Jump Table **
              
              JSR PRINT
              RTS ** Returns to sender **



shift_r        MOVE.B #$09, (A4)+
              MOVE.L D1, D2
              AND.W #$0E00, D2
              LSR.L #$8, D2
              LSR.L #$1, D2
              CLR.L D3
              LEA ea_table, A3 ** loads ea_table for jmp **
              JSR 0(A3, D3) ** jumps to the Jump Table **

              MOVE.B #$2C, (A4)+
              MOVE.L D1, D2
              AND.W #$0007, D2
              CLR.L D3
              
              JSR 0(A3, D3) ** jumps to the Jump Table **
              
              JSR PRINT
              RTS ** Returns to sender **

code1110_asr1 MOVE.L #$41535209, (A4)+
              CLR.L D2
              CLR.L D3
               
              MOVE.W D1, D2
              AND.L #%0000000000000111, D2 ** checks the source reg number **

               
              MOVE.W D1, D3
              AND.L #%0000000000111000, D3 ** checks the source mode type **
              ASR.W #$3, D3 ** shifts the bits to the right **
              
              CMP.W #$0001,D3 
              BLE BADINST
              
              CMP.W #$0007, D2
              BNE lsl1_cont
              CMP.W #$0001, D3
              BLE lsl1_cont
              BRA BADINST
               
asr1_cont     LEA ea_table, A3 ** loads ea_table for jmp **
              MULU #6,D3 ** gets the index of the jmp table **
               
              JSR 0(A3, D3) ** jumps to the Jump Table **
              JSR PRINT
              RTS ** Returns to sender **
              
              

code1110_asr2 MOVE.L #$4153522E, (A4)+
              CLR.L D2
              CLR.L D3
              MOVE.L D1, D3
              AND.W #$00C0, D3
              LSR.W #$6, D3
              JSR SIZE2BUFFER
              
              CLR.W D3
              MOVE.L D1, D3
              AND.W #$0020, D3
              LSR.W #$5, D3
              CMP.W #$0, D3
              BEQ shift_i
              BRA shift_r



**********************************************************************************************************
code1111       STOP        #$2700

BADINST        STOP        #$2700

ea_table       JMP         eacode000
               JMP         eacode001
               JMP         eacode010
               JMP         eacode011
               JMP         eacode100
               JMP         eacode101
               JMP         eacode110
               JMP         eacode111
               

               
               
**********************************************************************
**      eacode000 handles addressing mode Data Register (Dn)        **
**********************************************************************
** - Stores the value hexa value of the register in D2              **
** - Stores the hexa value of "D" in D3                             **
** - Appends the data to the print buffer                           **
**********************************************************************

eacode000       ADD.B #$30, D2              ** Adds the hexa value "0" to the register number 
                CLR D3                      ** Clears the Register in D3
                MOVE.B #$44, D3             ** Adds the hexa value "D" to D3
                ASL.L #$8, D3               ** Shifts the hexa bits to the left 
                ADD.B D2, D3                ** Adds the hexavalue of the the register number
                MOVE.W D3, (A4)+            ** Appends the ea mode and register number to the print buffer
                RTS                         ** Returns to Sender 
                                    
eacode001
               ADD.B #$30, D2
               CLR D3
               MOVE.B #$41, D3
               ASL.L #$8, D3
               ADD.B D2, D3
               MOVE.W D3, (A4)+
               RTS       
eacode010
               ADD.B #$30, D2
               CLR D3
               MOVE.B #$28, D3
               ASL.L #$8, D3
               MOVE.B #$41, D3
               ASL.L #$8, D3
               MOVE.B D2, D3
               ASL.L #$8, D3
               MOVE.B #$29, D3
               MOVE.L D3, (A4)+
               RTS   

eacode011
               ADD.B #$30, D2
               CLR D3
               MOVE.B #$28, D3
               ASL.L #$8, D3
               MOVE.B #$41, D3
               ASL.L #$8, D3
               MOVE.B D2, D3
               ASL.L #$8, D3
               MOVE.B #$29, D3
               MOVE.L D3, (A4)+              
               MOVE.W #$2B20, (A4)+

               RTS 
eacode100
               ADD.B #$30, D2
               CLR D3
               MOVE.B #$2D, D3
               ASL.L #$8, D3
               MOVE.B #$28, D3
               ASL.L #$8, D3
               MOVE.B #$41, D3
               ASL.L #$8, D3
               MOVE.B D2, D3
               MOVE.L D3, (A4)+              
               MOVE.W #$2920, (A4)+
               RTS
eacode101
               ADD.B #$30, D2
               CLR D3
               MOVE.B #$28, D3
               ASL.L #$8, D3
               MOVE.B #$41, D3
               ASL.L #$8, D3
               MOVE.B D2, D3
               ASL.L #$8, D3
               MOVE.B #$29, D3
               MOVE.L D3, (A4)+
               RTS 
eacode110
               ADD.B #$30, D2
               CLR D3
               MOVE.B #$28, D3
               ASL.L #$8, D3
               MOVE.B #$41, D3
               ASL.L #$8, D3
               MOVE.B D2, D3
               ASL.L #$8, D3
               MOVE.B #$29, D3
               MOVE.L D3, (A4)+
               RTS 
eacode111 
       
             
PRINT:

            LEA print_buffer, A1
            MOVE.B #13, D0
            TRAP #15
            

            
CLEAR:
            CLR     D0
            CLR     D1
            CLR     D2
            CLR     D3
            CLR     D4
            CLR     D5
            CLR     D6
            CLR     D7
endClear    RTS

************************************************************
*address input
************************************************************
U_INPUT:
            MOVE.B  #task1,D0           *
            LEA     srt_addr,A1         *
            MOVE.W  s_len,D1            *
            TRAP    #15                 *
            ADDA.L  #s_len,A1           *
            MOVE.B  #task2,D0           *
            TRAP    #15                 *
            JSR     ASCII2HEX
            CMP.B   #$00,D5             *bad input?
            BEQ     endInput
            
            MOVEA.L A0,A4         
            MOVE.B  #task1,D0
            LEA     end_addr,A1
            MOVE.W  e_len,D1         
            TRAP    #15         
            ADDA.L  #e_len,A1
            MOVE.B  #task2,D0
            TRAP    #15
            JSR     ASCII2HEX
            CMP.B   #$00,D5             *bad input?
            BEQ     endInput
            
           
           **********swap************
            MOVEA.L A4,A3               *store starting into register
            MOVEA.L A0,A4               *copy ending to A4
            MOVEA.L A3,A0               *store starting in A0                    
endInput    RTS

************************************************************
*ascii2hex - see flowchart for logic
*D3 - Placeholder for current ascii byte
*D4 - Translated address
*D5 - Return status
*D6 - Counter (6)
*A0 - Stored address at end of subroutine

************************************************************
ASCII2HEX:
            MOVEM.L D0-D4,-(SP)         * save data registers to the stack
            JSR     CLEAR
            MOVE    #length,D6

loop
            MOVE.B  (A1)+,D3            *
            CMP.B   #$30,D3             *byte < 30??
            BLT     error               *
            
            CMP.B   #$3A,D3             *byte < 3A??
            BLT     num2hex             *
            
            CMP.B   #$41,D3             *byte < 41??
            BLT     error               *
            
            CMP.B   #$47,D3             *byte < 47?
            BLT     upper2hex           *
            
            CMP.B   #$61,D3             *byte < 61??
            BLT     error               *
            
            CMP.B   #$67,D3             *byte < 67??
            BLT     lower2hex           *
            
            CMP.B   #$66,D3             *byte > 66??
            BGT     error               *

num2hex
            SUBI.B  #$30,D3             *subracthex value of 0 to get correct value of input
            ADD.B   D3,D4               *
            JMP     resume              *return to top
            
upper2hex
            SUBI.B  #$37,D3             *subracthex value of A to get correct value of input
            ADD.B   D3,D4               *
            JMP     resume              *return to top
            
lower2hex
            SUBI.B  #$57,D3             *subracthex value of a to get correct value of input
            ADD.B   D3,D4               *
            JMP     resume              *return to top
error
            MOVE.B  #$00,D5             *flag as bad input and return
            JMP     endA2H              *return to top
resume
            ADD     #1,D6               *increment length counter
            CMP     #6,D6               *check if done
            BEQ     endA2H              *
            CMP.B   #$00,(A1)           *end of string??
            BEQ     endA2H              *
            ASL.L   #4,D4               *shiftleft by 4 bits to get next value            
            JMP     loop                *return to top

endA2H
            MOVE.L  D4,A0               *
            CLR     D6                  *clear counter
            MOVEM.L (SP)+,D0-D4         *load data registers from stack      
            RTS                         *

END:
            SIMHALT             ; halt simulator


*-----------------------------------------------------------
*variables
*-----------------------------------------------------------
intro       dc.b    'Easy68k Disassembler',0,CR,LF
i_length    dc.w    i_length-intro

srt_addr    dc.b    'Enter starting address: $',0
s_len       dc.w    s_len-srt_addr

end_addr    dc.b    'Enter ending address: $',0
e_len       dc.w    e_len-end_addr

buffer      dc.b    1

move_message dc.b 'MOVE.', 0

size_message dc.b 'W ', 0

data_register_message dc.b 'D', 0

comma dc.b ', ', 0


    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
