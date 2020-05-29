*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Scott Shirley
* Date       :
* Description:
*-----------------------------------------------------------
*Register Use
*For consistency, please utilize registers in the following way.
*
*D0 -
*D1 -
*D2 - copy of working address
*D3 - utility register
*D4 -
*D5 - flag condition
*D6 - counter
*D7 -
*
*A0 - temp address holder
*A1 - trap address
*A2 - buffer address of decoded instruction
*A3 -
*A4 - starting address
*A5 - ending address
*A6 -
*A7 -
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
printCount  EQU     10                  *number of lines printed to console before user input

*trap outputs
task0       EQU     00                  * output command
task1       EQU     01                  * output command
task2       EQU     02                  * output command
task13      EQU     13                  * output command

*-----------------------------------------------------------
*beging program
*-----------------------------------------------------------
            ORG     start
            BSR     intro_msg           *print intro message
main        BSR     CLEAR               *clear all registers
            LEA     stack, SP           *load stack pointer
            LEA     buffer, A2          *set buffer for input
            MOVEA.L A2,A6 
            
main_input  BSR     U_INPUT
            CMP.B   #$0, D5
            BEQ     badInput             *bad flag, reinput 
            
            
main_prep   JSR     bufferPrep

            MOVEA.L A4, A1              *print start
            JSR     printinst                         

            MOVEA.L A5, A1              *print end
            JSR     printinst           
            
           
            BSR     END

*-----------------------------------------------------------
*subroutines
*-----------------------------------------------------------
*intro message display
intro_msg
            MOVE.B  #13,D0
            LEA     intro,A1
            MOVE.W  i_length,D1
            TRAP    #15
endIntro    RTS

*bad input error message display
badInput
            MOVE.B  #task0,D0
            LEA     str_error, A1
            MOVE.W  err_len, D1
            TRAP    #15
            MOVE.B  #badFlag,D5
endBI       JSR     main
          
*clear all registers         
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
            
            MOVEM.L D0-D4,-(SP)         *save data registers to the stack
            JSR     CLEAR
            MOVE.B  #$01,D5             *preset flag condition to good
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

************************************************************
*printbuffer
************************************************************
bufferPrep  MOVEA.L A0, A2

endBP       RTS


printinst   
            MOVE.B  #task13, D0
            MOVE.W  #12,D1
            TRAP    #15
            RTS
            
*-----------------------------------------------------------
*variables
*-----------------------------------------------------------
intro       dc.b    'Easy68k Disassembler',0,CR,LF
i_length    dc.w    i_length-intro

srt_addr    dc.b    'Enter starting address: $',0
s_len       dc.w    s_len-srt_addr

end_addr    dc.b    'Enter ending address: $',0
e_len       dc.w    e_len-end_addr

str_error   DC.B    'Error: starting or ending address has error',0
err_len     DC.W    err_len-str_error 

buffer      dc.b    1

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
