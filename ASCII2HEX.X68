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
 

minAdd      EQU     $00000000           *start of address space
maxAdd      EQU     $00FFFFFF           *end of address space

CR          EQU     $0D                 *carriage return
LF          EQU     $0A                 *line feed

goodflag    EQU     1                   *good flag condition
badflag     EQU     0                   *bad flag condition
length      EQU     0                   *

printCount  EQU     10                  *number of lines printed to console before user input

*TRAP tasks for preload
task0       EQU     00                  *Display string at (A1), D1.W bytes long (max 255) with carriage return and line feed (CR, LF)
task1       EQU     01                  *Display string at (A1), D1.W bytes long (max 255) without CR, LF
task2       EQU     02                  *Read string from keyboard and store at (A1), NULL terminated, length retuned in D1.W (max 80)
task3       EQU     03                  *Display signed number in D1.L in decimal in smallest field
task13      EQU     13                  *Display the NULL terminated string at (A1) with CR, LF
task14      EQU     14                  *Display the NULL terminated string at (A1) without CR, LF
*-----------------------------------------------------------
*beging program
*-----------------------------------------------------------
            ORG     start
            BSR     intro_msg           *print intro message
main        BSR     CLEAR               *clear all registers
            LEA     stack, SP           *load stack pointer
            LEA     buffer, A2          *set buffer for input
            MOVEA.L A2,A6 
            
            
main_input  BSR     U_INPUT             *
            CMP.B   #$0, D5             *
            BEQ     badInput            *bad flag, reinput 
            
            
main_loop   JSR     bufferPrep          *prep buffer
    
            MOVE.B  #task14, D0         *
            LEA     t_str_start, A1     *print start add test message     
            TRAP    #15                 *
            
            MOVE.L  v_srt_add, D1       *
            MOVE.B  #task3, D0          *print start add test value
            TRAP    #15                 *
            
            MOVE.B  #task13, D0         *print carriage rturn
            LEA     str_cr, A1          *
            TRAP    #15                 *
       
            MOVE.B  #task14, D0         *print end add test message
            LEA     t_str_end, A1         *    
            TRAP    #15                 *
  
            MOVE.L  v_end_add, D1       *
            MOVE.B  #task3, D0          *print end add test value
            TRAP    #15                 *
                 

*loop checking      
            CMPA.L  A0, A5              * have we reached the end of our address range?
            BLE     main_end  
 
            ADDI    #1, D6              *add counter
            CMP     #printcount, D6     *check loop progress
            BNE     main_loop
              
            

main_cont   MOVE.B  #task1, D0
            LEA     str_cont, A1
            MOVE.W  cont_len, D1
            TRAP    #15
            
            MOVE.B  #task2,D0
            TRAP    #15
            CLR     D6                  *clear counter, reset loop
            JMP     main_loop



main_end    BSR     END

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
            MOVE.L  D7, v_srt_add       *store to varable
            CLR     D7
            
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
            MOVE.L  D7, v_end_add        *store to varable
            CLR     D7
           
           **********swap************

            MOVEA.L A0,A5               *store ending to 
A5
            *MOVEA.L A0,A4               *copy ending to A4
            MOVEA.L A4,A0               *store starting in A0                    
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
            MOVE.L  D4,D7               *move address to temp register
            CLR     D6                  *clear counter
            MOVEM.L (SP)+,D0-D4         *load data registers from stack      
            RTS                         *




************************************************************
*printbuffer
************************************************************
bufferPrep  MOVEA.L (A0)+, A2

endBP       RTS


printinst   
            MOVE.B  #14, D0
            *MOVE.W  #12,D1
            TRAP    #15
            RTS
            
************************************************************
*Hex2ASCII 
************************************************************
Hex2ASCII   CMP.B   #$A,D6              * Confirm hex character?
            BGE     letter              * Is it a letter or number?
            ADDI.B  #$30,D6             * Convert decimal to ASCII
            BRA     write2Buff          * save to good buffer
letter      ADDI.B  #$37,D6
write2Buff  MOVE.B  D6,(A2)+
            RTS           
            
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

t_str_start dc.b    'The start address is: $',0
t_start     dc.w    t_start-t_str_start

t_str_end   dc.b    'The end address is: $',0
t_end       dc.w    t_end-t_str_end

str_error   dc.b    'Error: starting or ending address has error',0
err_len     dc.w    err_len-str_error 

str_cont    dc.b    'Press enter to continue.',0
cont_len    dc.w    cont_len-str_cont

str_cr      dc.b    '',0

buffer      dc.b    1

v_srt_add   ds.l    1               *store start address
V_end_add   ds.l    1               *store end address


    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
