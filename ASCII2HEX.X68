*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Scott Shirley
* Date       :
* Description:
*-----------------------------------------------------------
 
* Variables and EQUs
start       EQU     $1000               *start address
stack       EQU     $A000               *stack address   
CR          EQU     $0D                 *carriage return
LF          EQU     $0A                 *line feed
goodflag    EQU     1
badflag     EQU     0
length      EQU     0
task1       EQU     01                  *
task2       EQU     02                  *

*-----------------------------------------------------------
*beging program
*-----------------------------------------------------------
            ORG     start
            BSR     intro_msg           *print intro message
main        BSR     CLEAR               *clear all registers
            LEA     stack, SP           *load stack pointer
            LEA     buffer, A2          *set buffer for input
            MOVEA.L A2,A6 
            
            BSR     U_INPUT
            
            BSR     END

*-----------------------------------------------------------
*subroutines
*-----------------------------------------------------------
intro_msg
            MOVE.B  #13,D0
            LEA     intro,A1
            MOVE.W  i_length,D1
            TRAP    #15
endIntro    RTS
            
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

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
