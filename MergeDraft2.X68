*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Scott Shirley, Carl Howing
* Date       : June 6, 2020
* Description: 
************************************************************

************************************************************
*  ____            _     _                
* |  _ \ ___  __ _(_)___| |_ ___ _ __ ___ 
* | |_) / _ \/ _` | / __| __/ _ \ '__/ __|
* |  _ <  __/ (_| | \__ \ ||  __/ |  \__ \
* |_| \_\___|\__, |_|___/\__\___|_|  |___/
*            |___/                        
*Register Use
*For consistency, please utilize registers in the following way.
*
*D0 -
*D1 -
*D2 - 
*D3 - utility register
*D4 - 
*D5 - flag condition
*D6 - counter
*D7 - copy of working address
*
*A0 - temp address holder
*A1 - trap address
*A2 - buffer address of decoded instruction
*A3 -.
*A4 - starting address
*A5 - ending address
*A6 -
*A7 -
************************************************************

************************************************************
* __     __         _       _     _                               _     _____ ___  _   _ 
* \ \   / /_ _ _ __(_) __ _| |__ | | ___  ___      __ _ _ __   __| |   | ____/ _ \| | | |
*  \ \ / / _` | '__| |/ _` | '_ \| |/ _ \/ __|    / _` | '_ \ / _` |   |  _|| | | | | | |
*   \ V / (_| | |  | | (_| | |_) | |  __/\__ \   | (_| | | | | (_| |   | |__| |_| | |_| |
*    \_/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/    \__,_|_| |_|\__,_|   |_____\__\_\\___/ 
*                                                                                        
* Variables and EQUs
************************************************************
start       EQU     $1000               *start address
stack       EQU     $A000               *stack address  
buf         EQU     $9000

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
************************************************************

************************************************************
*  __  __       _       
* |  \/  | __ _(_)_ __  
* | |\/| |/ _` | | '_ \ 
* | |  | | (_| | | | | |
* |_|  |_|\__,_|_|_| |_|
*                      
************************************************************
            ORG     start
            BSR     dis_intro_msg       *print intro message
            
main        BSR     CLEAR               *clear all registers
            LEA     stack, SP           *load stack pointer
            LEA     buf, A2          *set buffer for input
            MOVEA.L A2,A6    
            
main_input  BSR     U_INPUT             *branch to input
            CMP.B   #$0, D5             *check if bad input
            BEQ     dis_badInput        *bad flag, reinput 
                        
main_loop   JSR     DECODE         *prep buffer
*loop checking **********************************************    
            CMPA.L  A0, A5              * have we reached the end of our address range?
            BLE     main_end  
            
            ADDI    #1, D6              *add counter
            CMP     #printcount, D6     *check loop progress
            BNE     main_loop

main_cont   JSR     dis_cont
            JMP     main_loop

main_end    BSR     END
*===========================================================

*-----------------------------------------------------------
*display subroutines
*intro message, bad inputs, carriage return, enter2return, input test
*-----------------------------------------------------------
*intro message display
************************************************************
dis_intro_msg
            MOVE.B  #13,D0              *load task
            LEA     intro,A1            *load string
            MOVE.W  i_length,D1         *load string length 
            TRAP    #15                 *display
endIntro    RTS                         *return
*bad input error message display****************************
dis_badInput
            MOVE.B  #task0,D0           *load task
            LEA     str_error, A1       *load string
            MOVE.W  err_len, D1         *load string length
            TRAP    #15                 *display
            MOVE.B  #badFlag,D5         *set flag condition to bad
endBI       JSR     main_input          *return to main_input
*dsiplay carriage return************************************
dis_cr
            MOVE.B  #task13, D0         *load task
            LEA     str_cr, A1          *load string
            MOVE.W  cr_len, D1          *load string length
            TRAP    #15                 *display
end_cr      RTS                         *return
*enter2return***********************************************
dis_cont   
            MOVE.B  #task14, D0         *load task
            LEA     str_cont, A1        *load string
            MOVE.W  cont_len, D1        *load string length
            TRAP    #15                 *display
            
            MOVE.B  #task2,D0           *load task
            TRAP    #15                 *get input
            
            MOVE.B  #$50,(A1)           *reset A1
            
            CLR     D6                  *clear counter, reset loop
endDC       RTS                         *return
*===========================================================

************************************************************ 
*  _   _ _____ _     ____  _____ ____  
* | | | | ____| |   |  _ \| ____|  _ \ 
* | |_| |  _| | |   | |_) |  _| | |_) |
* |  _  | |___| |___|  __/| |___|  _ < 
* |_| |_|_____|_____|_|   |_____|_| \_\
*                                      
*HELPER SUBROUTINES
*Description: These subroutines are called during teh opcode translation
************************************************************

************************************************************   
*CLEAR
*Description: Clears registers of values
************************************************************        
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
*===========================================================

************************************************************
*U_INPUT
*Description: Gets input address from user for program
*D5 - Return Status
*D7 - Temparary register to store address value
*A0 - Working Address
*A4 - Start Address
*A5 - End Address
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
            *MOVE.L  D7, v_srt_add       *store to varable
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
            *MOVE.L  D7, v_end_add        *store to varable
            CLR     D7


            MOVEA.L A0,A5               *store ending to A5
            MOVEA.L A4,A0               *store starting in A0  
                  
endInput    RTS
*===========================================================

************************************************************
*ASCII2HEX 
*Description: Converts an ASCII character to HEX - see flowchart for logic
*D3 - Placeholder for current ascii byte
*D4 - Translated address
*D5 - Return status
*D6 - Counter (6)
*D7 - Temparary register to store address value
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
*===========================================================

************************************************************
*DECODE
************************************************************
DECODE:
            LEA     buf, A2             *load buffer
            MOVEA.L A2,A1               *load trap address with buffer 
            JSR     ADDRESS             *current address to buffer
            MOVE.W  (A0)+, D7            *move A0 value to test

            JSR     GETOPCODE           *decode instruction
print_b     MOVE.B  #00,(A2)            *null terminator
            MOVE.B  #task13,D0
            TRAP    #15 
            
            *CMPI.B  #%0, D5
            *BNE     decodeCont 
            *ADDI    #1, badInstCount
decodeCont  MOVE.B  #0, D5
            *ADDQ.W      #2, A0
            
endDECODE   RTS
*===========================================================                       

************************************************************
*ADDRESS
*Description: Fills the buffer with the current address
************************************************************
ADDRESS:    
            CLR.L   D3
            CLR.L   D4
            CLR.L   D7
            MOVE.B  #$24, (A2)+     *'$' to buffer
            MOVE.B  #$30, (A2)+     *'0' to buffer
            MOVE.B  #$78, (A2)+     *'x' to buffer       
            MOVE.L  #$00000000, D3
            MOVE.L  A0, D7
            ADD.W   D7, D3
            JSR     addrFill   
            MOVE.B  #$09,(A2)+   *tab
            JMP     endaddr
            
addrFill    MOVE.L      D3, D2            *move current word into D2 for rolling purposes
            MOVE.B      #8, D4              *load counter

addrLoop                 
            CMP.B       #$00, D4            *compare counter with 0
            BEQ         endaddr      *if 0, return
            ROL.L       #4, D2              *
            MOVE.L      D2, D3              *
            ANDI.L      #$000F, D3          *isolate
            JSR         HEX2ASCII           *to buffer           
            SUBQ.B      #$1, D4             *subtract from counter
            JMP         addrLoop                 *loop
            
endaddr     MOVE.L      D7, D3              *load from utility                             
endbf       RTS
*===========================================================

************************************************************ 
*   ___  ____   ____ ___  ____  _____ ____  
*  / _ \|  _ \ / ___/ _ \|  _ \| ____/ ___| 
* | | | | |_) | |  | | | | | | |  _| \___ \ 
* | |_| |  __/| |__| |_| | |_| | |___ ___) |
*  \___/|_|    \____\___/|____/|_____|____/ 
* 
*GETOPCODE:
*Description: Gets the first four bits of instruction to decode 
*  
*Naming conventions for opcode subroutines
*opcode####
*op[opmode][operation]
*endop####
*                              
*Registers Used:
*For consistency, please utilize registers in the following way.
*
*D1 - utility register
*D3 - utility register
*D7 - copy of working address
*
*A2 - buffer address of decoded instruction
*A6 - jump table               
************************************************************
GETOPCODE:   
            MOVE.W  D7, D3              *move to utility
            MOVE.B  #12, D1             *
            LSR.W   D1, D3              *shift
            MULU    #6, D3              *offset          
            LEA     OP_TABLE, A6        *                                                                                  
            JSR     00(A6,D3)           *jump indirect with index (00 indicates word movement)
            MOVE.L  A2, D3
            *MOVE.L  D3, bufferend   
endgop      RTS                         *return
*===========================================================

************************************************************
*OPCODE Table
*Description: Table of OPCODES
************************************************************ 
OP_TABLE
            JMP         opcode0000      *BADINST
            JMP         opcode0001      *MOVE.B *testing*
            JMP         opcode0010      *MOVE/A.L *incomplete*
            JMP         opcode0011      *MOVE/A.W *incomplete*
            JMP         opcode0100      *CLR,LEA,JMP,JSR,MOVEM,NEG*,NOP*,NOT*,RTS *testing*
            JMP         opcode0101      *BADINST
            JMP         opcode0110      *BADINST
            JMP         opcode0111      *BADINST
            JMP         opcode1000      *OR
            JMP         opcode1001      *SUB,SUBA
            JMP         opcode1010      *BADINST
            JMP         opcode1011      *CMP,CMPA
            JMP         opcode1100      *AND
            JMP         opcode1101      *ADD,ADDA
            JMP         opcode1110      *ASR/LSL
            JMP         opcode1111      *BADINST
            
************************************************************
*OPCODES
*Description: OPCODE subroutines used to decode instructions
************************************************************          

*SUB
*Cases for first four bits: 1001
*Description: Converts opcode instruction that start with 1001
*SUB, SUBA
* 1001 0110 0100 0001
* ^--^
*Registers Used:
*D3 - size bit
*D7 - copy of instruction
*A2 - buffer address of decoded instruction
*
************************************************************  
* Case for: 0000
* --(ORI,ANDI,SUBI,ADDI,EORI,CMPI) 
opcode0000: JMP     BADINST
endop0000   RTS
*===========================================================

************************************************************  
*OPCODE: 0001
*MOVE.B
opcode0001:
            MOVE.B  #$4D, (A2)+     *'M' to buffer
            MOVE.B  #$4F, (A2)+     *'O' to buffer
            MOVE.B  #$56, (A2)+     *'V' to buffer
            MOVE.B  #$45, (A2)+     *'E' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            MOVE.B  #$42, (A2)+     *'B' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA
            CMPI.B  #%0, D5
            BEQ     endop0001   
            MOVE.B  #$2C, (A2)+     *',' to buffer
            JSR     SWAPREG         *swap destination and source regs
            JSR     GETEA  
endop0001   RTS                     *return

*===========================================================

************************************************************  
*OPCODE: 0010
*MOVE.L, MOVEA.L
opcode0010: JMP          BADINST
endop0010   RTS
*===========================================================

************************************************************  
*OPCODE: 0011
*MOVE.W,MOVEA.W
opcode0011:
            MOVE.B  #$4D, (A2)+     *'M' to buffer
            MOVE.B  #$4F, (A2)+     *'O' to buffer
            MOVE.B  #$56, (A2)+     *'V' to buffer
            MOVE.B  #$45, (A2)+     *'E' to buffer

            MOVE.W   D7, D3    *Check the destination mode to see if addressing*
            AND.L    #$01C0, D3 
            CMPI.L   #$0040, D3 ** compares to see if addressing mode
            BNE.S    code0011_cont **branches if destination mode is not addressing register
            *MOVE.W   #$412E, (A2)+ **Loads "A." into the print_buffer
            *MOVE.W   #$5720, (A2)+ **Loads "W   " into the print_buffer
            MOVE.B  #$41, (A2)+     *'A' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            MOVE.B  #$57, (A2)+     *'W' to buffer
            BRA      code0011_cont2 **branches back to code

code0011_cont  
            *MOVE.L   #$2E572020, (A2)+ **Loads ".W" into the print_buffer 
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            MOVE.B  #$57, (A2)+     *'W' to buffer
            
code0011_cont2 
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR      GETEA
            MOVE.B   #$2C, (A2)+     *',' to buffer
            JSR      SWAPREG         *swap destination and source regs
            JSR      GETEA 
            RTS
*===========================================================

************************************************************  
*OPCODE: 0100
*CLR,LEA,JMP,JSR,MOVEM,NEG*,NOP*,NOT*,RTS
* '*' - instructions, not required but included 
opcode0100: 

            *MOVEM
            MOVE.L  D7, D3
            AND.W #%0000111000000000, D3    *isolate bits 11 - 9
            ASR #$6, D3
            CMPI.W #%011, D3
            *BEQ     op0100MOVEM

            MOVE.L  D7, D3
            ANDI.W  #$0100,D3           * Test isolate 8th bit for LEA
            CMP.W   #$0100,D3           * Test if LEA
            BEQ     opLEA               * Yes finish testing for LEA
            MOVE.W  D7,D3               * Copy fresh copy of instruction to shift
            MOVE.B  #8,D4          * Load 8 bit shifter
            LSR.W   D4,D3               * Shift current instruction
            ANDI.W  #$000F,D3           * Isolate last 4 bits (LSB)
            MULU    #6,D3               * Form offset for next JMP table
            LEA     op0100table,A6         * Load next JMP table 
            JSR     00(A6,D3)           * Jump to next instruction per next 4 bits
            JMP     endop0100            * Once returned from jump table, skip to end
endop0100   RTS         
**LEA******************************************************* 
opLEA       MOVE.B  #$4C, (A2)+     *'L' to buffer
            MOVE.B  #$45, (A2)+     *'E' to buffer
            MOVE.B  #$41, (A2)+     *'A' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA
            MOVE.B  #$2C,(A2)+      *',' to buffer
            MOVE.B  #$41,(A2)+      *'A' to buffer
            JSR     REG2BUFFER
endopLEA    RTS                     *return   
                      
*==========================================================
*  ___ _____ _   ___ _____   _____ _   ___ _    ___ 
* / __|_   _/_\ | _ \_   _| |_   _/_\ | _ ) |  | __|
* \__ \ | |/ _ \|   / | |     | |/ _ \| _ \ |__| _| 
* |___/ |_/_/ \_\_|_\ |_|     |_/_/ \_\___/____|___|
*                                                  
*0100 SECOND LAYER OPCODE TABLE SUBROUTINES 
op0100table
            JMP     op0100_0000   *BADINST          
            JMP     op0100_0001   *BADINST           
            JMP     op0100_0010   *CLR
            JMP     op0100_0011   *BADINST
            JMP     op0100_0100   *NEG*
            JMP     op0100_0101   *BADINST
            JMP     op0100_0110   *NOT*
            JMP     op0100_0111   *BADINST
            JMP     op0100_1000   *SWAP*
            JMP     op0100_1001   *BADINST
            JMP     op0100_1010   *BADINST
            JMP     op0100_1011   *BADINST
            JMP     op0100_1100   *BADINST
            JMP     op0100_1101   *BADINST
            JMP     op0100_1110   *NOP*,JMP,JSR,RTS
            JMP     op0100_1111   *BADINST
endop0100table   
            RTS                   *return
**0000 BADINST**********************************************
op0100_0000 JSR     BADINST
endop0100_0000
            RTS
**0001 BADINST**********************************************          
op0100_0001 JSR     BADINST          
endop0100_0001
            RTS            
**0010 CLR************************************************** 
op0100_0010 MOVE.B  #$43, (A2)+     *'C' to buffer
            MOVE.B  #$4C, (A2)+     *'L' to buffer
            MOVE.B  #$52, (A2)+     *'R' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            JSR     SIZE2BUFFER
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA
endop0100_0010    
            RTS                     *return
**0011 BADINST**********************************************          
op0100_0011 JSR     BADINST          
endop0100_0011
            RTS  
**0100 NEG************************************************** 
op0100_0100 MOVE.B  #$4E, (A2)+     *'N' to buffer
            MOVE.B  #$45, (A2)+     *'E' to buffer
            MOVE.B  #$47, (A2)+     *'G' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            JSR     SIZE2BUFFER
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA
endop0100_0100   
            RTS                     *return
**0101 BADINST**********************************************          
op0100_0101 JSR     BADINST          
endop0100_0101
            RTS  
**0110 NOT************************************************** 
op0100_0110 
            MOVE.B  #$4E, (A2)+     *'N' to buffer
            MOVE.B  #$4F, (A2)+     *'O' to buffer
            MOVE.B  #$54, (A2)+     *'T' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            JSR     SIZE2BUFFER
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA
endop0100_0110
            RTS                     *return
**0111 BADINST**********************************************          
op0100_0111 JSR     BADINST          
endop0100_0111
            RTS 
**1000 SWAP*************************************************          
op0100_1000 JSR     BADINST     *SWAP not supported     
endop0100_1000
            RTS  
**1001 BADINST**********************************************           
op0100_1001 JSR     BADINST          
endop0100_1001
            RTS 
**1010 BADINST**********************************************           
op0100_1010 JSR     BADINST          
endop0100_1010
            RTS 
**1011 BADINST**********************************************           
op0100_1011 JSR     BADINST          
endop0100_1011
            RTS 
**1100 BADINST**********************************************           
op0100_1100 JSR     BADINST          
endop0100_1100
            RTS 
**1101 BADINST**********************************************           
op0100_1101 JSR     BADINST          
endop0100_1101
            RTS 
***1110 NOP*,RTS,JSR,JMP************************************
op0100_1110:                       
            JSR     GETSIZE
            CMPI.B  #%10, D3
            BEQ     opJSR
            CMPI.B  #%11, D3
            BEQ     opJMP
            CMP.W   #$4E75, D7      *absolute binary value
            BEQ     opRTS           * 0100 1110 0111 0101
            CMP.W   #$4E71, D7      *absolute binary value
            BNE     BADINST         * 0100 1110 0111 0001
**NOP*******************************************************            
opNOP       MOVE.B  #$4E, (A2)+     *'N' to buffer
            MOVE.B  #$4F, (A2)+     *'O' to buffer
            MOVE.B  #$50, (A2)+     *'P' to buffer
endopNOP    RTS                     *return
**RTS*******************************************************
opRTS       MOVE.B  #$52, (A2)+     *'R' to buffer
            MOVE.B  #$54, (A2)+     *'T' to buffer
            MOVE.B  #$53, (A2)+     *'S' to buffer
endopRTS    RTS                     *return
**JSR*******************************************************           
opJSR       MOVE.B  #$4A, (A2)+     *'J' to buffer
            MOVE.B  #$53, (A2)+     *'S' to buffer
            MOVE.B  #$52, (A2)+     *'R' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA
endopJSR    RTS                     *return
**JMP*******************************************************
opJMP       MOVE.B  #$4A, (A2)+     *'J' to buffer
            MOVE.B  #$4D, (A2)+     *'M' to buffer
            MOVE.B  #$50, (A2)+     *'P' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA
endopJMP    RTS                     *return                                 
endop0100_1110          
            RTS                     *return           
**1111 BADINST***************************************************           
op0100_1111 JSR     BADINST          
endop0100_1111
            RTS 
***********************************************************
*  ___ _  _ ___    _____ _   ___ _    ___ 
* | __| \| |   \  |_   _/_\ | _ ) |  | __|
* | _|| .` | |) |   | |/ _ \| _ \ |__| _| 
* |___|_|\_|___/    |_/_/ \_\___/____|___|
*                                                 
************************************************************  
*OPCODE: 0101
*BAD INSTRUCTION
opcode0101: JMP     BADINST
endop0101   RTS
*===========================================================

************************************************************  
*OPCODE: 0110
*Bcc
opcode0110: JMP     BADINST
endop0110   RTS
*===========================================================

************************************************************  
*OPCODE: 0111
*BAD INSTRUCTION
opcode0111: JMP     BADINST
endop0111   RTS
*===========================================================

************************************************************  
*OPCODE: 1000
*OR 
opcode1000: 
            MOVE.L  D7, D3
            LSR.L   #6, D3
            ANDI.W  #$03, D3
            CMP.B   #$3, D3
            BNE     opOR
            JMP     BADINST
opOR        MOVE.B  #$4F, (A2)+     *'O' to buffer
            MOVE.B  #$52, (A2)+     *'R' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            JSR     SIZE2BUFFER     *size to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETDIRECTION    *direction bit 0 = EA; 1 = regs
            CMPI.B  #%0, D3         *EA first?
            BNE     opOR01          
            JSR     GETEA
            MOVE.B  #$2C,(A2)+      *',' to buffer
            MOVE.B  #$44,(A2)+      *'D' to buffer
            JSR     REG2BUFFER
            JMP     endop1000
 
opOR01      MOVE.B  #$44,(A2)+      *'D' to buffer
            JSR     REG2BUFFER            
            MOVE.B  #$2C,(A2)+      *',' to buffer
            JSR     GETEA
endop1000   RTS
*===========================================================

************************************************************  
*OPCODE: 1001
*SUB, SUBA
opcode1001:
            MOVE.B  #$53, (A2)+     *'S' to buffer
            MOVE.B  #$55, (A2)+     *'U' to buffer
            MOVE.B  #$42, (A2)+     *'B' to buffer
            JSR     GETSIZE         *get the instruction size (OPMODE)
            CMP.B   #%11, D3        *11 = SUBA  
            BNE     opsubSub
            MOVE.B  #$41, (A2)+     *'A' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            MOVE.W  D7, D3          *move to utility
            LSR.L   #8, D3          *shift for opmode
            ANDI.W  #$0001, D3      *isolate 8 to determine size
            CMP.B   #%1, D3         *long?
            BEQ     opsubL          *it's a longword
            JMP     opsubSuba
**SUBA******************************************************            
opsubL      MOVE.B  #$4C, (A2)+     *'L' to buffer
opsubSuba   MOVE.B  #$20, (A2)+     *' ' to buffer    
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA           *get effective address
            MOVE.B  #$2C,(A2)+      *',' to buffer
            MOVE.B  #$41,(A2)+      *'A' to buffer
            JSR     REG2BUFFER      *get the register number
            JMP     endop1001       *return
**SUB*EA>>Register****************************************** 
opsubSub    MOVE.B  #$2E, (A2)+     *'.' to buffer
            JSR     SIZE2BUFFER     *send size to buffer
            MOVE.B  #$09, (A2)+     *tab
            JSR     GETDIRECTION    *isolate
            CMP.B   #%0, D3         *direction bit 0 = EA; 1 = regs
            BNE     opsubSubR         
            JSR     GETEA           *get effective address
            MOVE.B  #$2C,(A2)+      *',' to buffer   
            MOVE.B  #$44,(A2)+      *'D' to buffer
            JSR     REG2BUFFER      *get the register number
            JMP     endop1001       *return
**SUB*Register>>EA******************************************            
opsubSubR   MOVE.B  #$44,(A2)+      *'D' to buffer
            JSR     REG2BUFFER      *get the register number
            MOVE.B  #$2C,(A2)+      *',' to buffer
            JSR     GETEA           *get effective address
endop1001   RTS                     *return
*===========================================================
                                                       
************************************************************  
*OPCODE: 1010
*BAD INSTRUCTION
opcode1010: JMP     BADINST
endop1010   RTS
*===========================================================

************************************************************  
*OPCODE: 1011
*CMP,CMPA
*EOR is not applicable to this assignment and will be 
*regarded as a bad instruction
opcode1011: 
            JSR     GETSIZE
            CMPI.B   #%11, D3
            BNE     opcmp
**CMPA******************************************************             
opCMPA      MOVE.B  #$43, (A2)+     *'C' to buffer
            MOVE.B  #$4D, (A2)+     *'M' to buffer
            MOVE.B  #$50, (A2)+     *'P' to buffer
            MOVE.B  #$41, (A2)+     *'A' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            MOVE.L  D7, D3
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            
            JSR     SIZE2BUFFER
            JSR     GETEA
            MOVE.B  #$2C, (A2)+     *',' to buffer
            MOVE.B  #$41, (A2)+     *'A' to buffer
            JSR     REG2BUFFER
            JMP     endop1011
**CMP*******************************************************             
opCMP       MOVE.L  D7, D3
            JSR     GETDIRECTION
            CMPI.B   #%0, D3
            BNE     opeor

            MOVE.B  #$43, (A2)+     *'C' to buffer
            MOVE.B  #$4D, (A2)+     *'M' to buffer
            MOVE.B  #$50, (A2)+     *'P' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            JSR     SIZE2BUFFER
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA
            MOVE.B  #$2C, (A2)+     *',' to buffer
            MOVE.B  #$44, (A2)+     *'D' to buffer
            JSR     REG2BUFFER
            JMP     endop1011
**EOR*******************************************************            
opEOR       JMP     BADINST              
endop1011   RTS
*===========================================================

************************************************************  
*OPCODE: 1100
*AND
*MULU, EXG are not applicable to this assignment and will be 
*regarded as a bad instruction
opcode1100:
            MOVE.W  D7, D3          *move to utility
            LSR.L   #6, D3          *shift
            ANDI.W  #$3, D3         *isolate
            CMP.B   #$3, D3         *MULU/MULS?
            BEQ     BADINST         *instruction not supported
            MOVE.W  D7, D3          *move to utility
            LSR.L   #3, D3          *shift
            ANDI.B  #$1F, D3        *isolate
            CMP.B   #$08, D3        *EXG?
            BEQ     BADINST         *instruction not supported
            CMP.B   #$09, D3        *EXG?
            BEQ     BADINST         *instruction not supported
            CMP.B   #$11, D3        *EXG?
            BEQ     BADINST         *ok, phew made it to AND
            
            MOVE.B  #$41, (A2)+     *'A' to buffer
            MOVE.B  #$4E, (A2)+     *'N' to buffer
            MOVE.B  #$44, (A2)+     *'D' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            JSR     SIZE2BUFFER     *send size to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETDIRECTION    *isolate bit for direction
            CMPI.B  #%0, D3         *direction bit 0 = EA; 1 = regs
            BNE     opAND01         *
            JSR     GETEA           *get effective address
            MOVE.B  #$2C, (A2)+     *',' to buffer
            MOVE.B  #$44, (A2)+     *'D' to buffer
            JSR     REG2BUFFER      *get the register number
            JMP     endop1100     
         
opAND01     MOVE.B  #$44, (A2)+     *'D' to buffer
            JSR     REG2BUFFER      *get the register number
            MOVE.B  #$2C, (A2)+     *',' to buffer
            JSR     GETEA           *get effective address 
endop1100   RTS                     *return
*===========================================================

************************************************************  
*OPCODE: 1101
*ADD,ADDA
opcode1101: 
            MOVE.B  #$41, (A2)+     *'A' to buffer
            MOVE.B  #$44, (A2)+     *'D' to buffer
            MOVE.B  #$44, (A2)+     *'D' to buffer
            JSR     GETSIZE         *
            CMPI.B  #%11, D3        *11?
            BNE     opadd           *
            MOVE.B  #$41, (A2)+     *'A' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            MOVE.W  D7, D3          *move to utility
            LSR.L   #8, D3          *shift
            ANDI.W  #$0001, D3      *isolate
            CMPI.B  #%1, D3         *long?
            BEQ     opaddL          *
            MOVE.B  #$57,(A2)+      *'W' to buffer
            JMP     opadda  
**ADD.L*****************************************************
opADDL      MOVE.B  #$4C,(A2)+      *'L' to buffer
*ADDA*******************************************************
opADDA      MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA           *get effective address 
            MOVE.B  #$2C, (A2)+     *',' to buffer
            MOVE.B  #$41, (A2)+     *'A' to buffer
            JSR     REG2BUFFER      *get the register number
            JMP     endop1101
**ADD*******************************************************
opADD       MOVE.B  #$2E, (A2)+     *'.' to buffer  
            JSR     SIZE2BUFFER     *send size to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETDIRECTION    *isolate bit for direction
            CMPI.B   #%0, D3        *direction bit 0 = EA; 1 = regs
            BNE     opADD01         *
            JSR     GETEA           *get effective address
            MOVE.B  #$2C, (A2)+     *',' to buffer
            MOVE.B  #$44, (A2)+     *'D' to buffer
            JSR     REG2BUFFER      *get the register number
            JMP     endop1101   
**EA first************************************************** 
opADD01    MOVE.B  #$44, (A2)+     *'D' to buffer
            JSR     REG2BUFFER      *get the register number
            MOVE.B  #$2C, (A2)+     *',' to buffer
            JSR     GETEA           *get effective address
endop1101   RTS                     *return           
*===========================================================

************************************************************  
*OPCODE: 1110
*ASR, LSL
opcode1110: JMP     BADINST
endop1110   RTS
*===========================================================

************************************************************  
*OPCODE: 1111
*BAD INSTRUCTION
opcode1111: JMP     BADINST
endop111    RTS
 *===========================================================             

************************************************************
*  _____ _____ _____ _____ ____ _____ _____     _______      _    ____  ____  ____  _____ ____ ____  
* | ____|  ___|  ___| ____/ ___|_   _|_ _\ \   / / ____|    / \  |  _ \|  _ \|  _ \| ____/ ___/ ___| 
* |  _| | |_  | |_  |  _|| |     | |  | | \ \ / /|  _|     / _ \ | | | | | | | |_) |  _| \___ \___ \ 
* | |___|  _| |  _| | |__| |___  | |  | |  \ V / | |___   / ___ \| |_| | |_| |  _ <| |___ ___) |__) |
* |_____|_|   |_|   |_____\____| |_| |___|  \_/  |_____| /_/   \_\____/|____/|_| \_\_____|____/____/ 
*                                                                                                   
*GETEA
*Description: Converts the opcode instruction EA
* 1001 0110 0100 0001
*             ^-----^
*Registers Used:
*For consistency, please utilize registers in the following way.
*
*D1 - utility register
*D3 - utility register
*D7 - copy of working address
*
*A2 - buffer address of decoded instruction
*A6 - jump table
************************************************************
GETEA:
            LEA     EA_TABLE, A6
            CLR.L   D3
            MOVE.W  D7, D3
            ANDI.W  #$003F, D3
            MOVE.B  #3, D1
            LSR.W   D1, D3
            MULU    #6, D3
            JSR     0(A6, D3)
            RTS                     *return
*===========================================================

************************************************************
*GET_TABLE
*Description: Jump table of Effective Address Modes
************************************************************
EA_TABLE:       
            JMP     eacode000
            JMP     eacode001
            JMP     eacode010
            JMP     eacode011
            JMP     eacode100
            JMP     eacode101
            JMP     eacode110
            JMP     eacode111
*===========================================================

************************************************************
*EA CODES
*Description: Lsit of Effective Address Subrotines
*000,001,010,011,100,[101],[110],111
*Registers Used:
*TODO
*
*Data Register**********************************************
eacode000   MOVE.W      D7, D3          *move to utility
            ANDI.W      #$7, D3         *isolate
            MOVE.B      #$44,(A2)+      *'D' to buffer
            ADD.B       #$30, D3        *convert register number to ascii
            MOVE.B      D3,(A2)+        *to buffer                  
endea000    RTS                         *return
*Address Register*******************************************
eacode001   MOVE.W      D7, D3          *move to utility
            ANDI.W      #$7, D3         *isolate
            MOVE.B      #$41, (A2)+     *'A' to buffer
            ADD.B       #$30, D3        *convert register number to ascii
            MOVE.B      D3,(A2)+        *to buffer  
endea001    RTS                         *return
*Address
eacode010   MOVE.W      D7, D3          *move to utility
            ANDI.W      #$7, D3         *isolate
            MOVE.B      #$28,(A2)+      *'(' to buffer            
            MOVE.B      #$41,(A2)+      *'A' to buffer
            ADD.B       #$30, D3        *convert register number to ascii
            MOVE.B      D3,(A2)+        *to buffer  
            MOVE.B      #$29,(A2)+      *')' to buffe
endea010    RTS                         *return
*Address with Postincrement*********************************
eacode011   MOVE.W      D7, D3          *move to utility
            ANDI.W      #$7, D3         *isolate
            MOVE.B      #$28,(A2)+      *'(' to buffer            
            MOVE.B      #$41,(A2)+      *'A' to buffer
            ADD.B       #$30, D3        *convert register number to ascii
            MOVE.B      D3,(A2)+        *to buffer  
            MOVE.B      #$29,(A2)+      *')' to buffer
            MOVE.B      #$2B, (A2)+     *'+' to buffer
endea011    RTS                         *return
*Address with Predecrement**********************************
eacode100   MOVE.W      D7, D3          *move to utility
            ANDI.W      #$7, D3         *isolate
            MOVE.B      #$2D,(A2)+      *'-' to buffer 
            MOVE.B      #$28,(A2)+      *'(' to buffer            
            MOVE.B      #$41,(A2)+      *'A' to buffer
            ADD.B       #$30, D3        *convert register number to ascii
            MOVE.B      D3,(A2)+        *to buffer  
            MOVE.B      #$29,(A2)+      *')' to buffe
endea100    RTS                         *return
*Bad Instruction********************************************
eacode101   JMP         BADINST
*Bad Instruction********************************************
eacode110   JMP         BADINST
*Immediate*Absolute*****************************************
eacode111   JSR         GETREGISTER     *isolate register bit
            CMPI.B      #$0, D3         *word?
            BEQ         WORD2BUFFER
            CMPI.B      #$1, D3         *long?
            BEQ         LONG2BUFFER
            CMPI.B      #$4, D3         *Immediate Data?
            BEQ         IMM2BUFER
            CMPI.B      #$2, D3         *PC?
            BEQ         BADINST
endea111    RTS                         *return
*===========================================================

************************************************************
*GETREGISTER
*Description: Converts register bit and stores in D3
************************************************************ 
GETREGISTER:
            MOVE.W  D7, D3
            ANDI.W  #$07, D3
endrb       RTS
*===========================================================

************************************************************
*GETSIZE
*Description: Returns the size of the bit in 6-7 (.B, .W, .L)
* 1001 0110 0100 0001
*       ^^--------->|
*Registers Used:
*D3 - size bit
*D7 - copy of instruction
************************************************************
GETSIZE:
            MOVE.W  D7, D3          *move to utility
            LSR.W   #6, D3          *shift
            ANDI.W  #$0003, D3      *isolate
endGS       RTS                     *return
*===========================================================

************************************************************
*GETDIRECTION
*Description: Finds direction of the instruction and sets it to the utility register
* 1001 0110 0100 0001
*         ^-------->|
*Registers Used:
*D3 - size bit
*D7 - copy of instruction 
************************************************************
GETDIRECTION:
            MOVE.W  D7, D3          *move to utility
            LSR.L   #8, D3          *shift 8
            ANDI.B  #01, D3         *isolate 8th bit
endgd       RTS                     *return
*===========================================================

************************************************************
*SWAPREG         
*Description: For double EA move instructions, swaps registers to use EA jump table
*Registers Used:
*D3 - size bit
*D4 - hold register for swap bits
*D7 - swapped EA mode 
SWAPREG:
            CLR.L   D3              *
            MOVE.W  D7,D3           *move to utility
            LSR.W   #8,D3           *shift
            LSR.W   #1,D3           *shift
            ANDI.W  #$0007,D3       *
            OR.W    D3,D4           *store bits for swap
            MOVE.W  D7,D3           *move to utility
            LSR.W   #3,D3           *shift bits 6-8 to normal ea position
            ANDI.W  #$0038, D3
            OR.W    D3,D4           *
            JSR     srSize          *get mode size
            MOVE.W  D4,D7           *load swap register
endswap     RTS                     *return

srSize      MOVE.W  D7,D3           *move to utility
            LSR.W   #8,D3           *shift
            LSR.W   #4,D3           *
            ANDI.W  #$0003,D3       *isolate
            CMP.B   #$1,D3          *byte?
            BEQ     endsr           *yes
            CMP.B   #$2,D3          *long?
            BEQ     srL             *yes
            CMP.B   #$3,D3          *word?
            BNE     BADINST         *No? bad instrustion        
srW         ORI.W   #$0040,D4       *add size
            JMP     endsr           *
srL         ORI.W   #$0080,D4       *add size
endsr       RTS                     *return
*===========================================================

SHIFT:       
            LSR.L   D4,D3               
            ANDI.W  #$000F,D3
endSHFIT    RTS

************************************************************
*  ____  _   _ _____ _____ _____ ____ 
* | __ )| | | |  ___|  ___| ____|  _ \ 
* |  _ \| | | | |_  | |_  |  _| | |_) | 
* | |_) | |_| |  _| |  _| | |___|  _ <  
* |____/ \___/|_|   |_|   |_____|_| \_\ 
*
*BUFFER SUBROUTINES                                                                                 
*Description: Puts word to print buffer
*D3 - Utility register
*D6 - Counter
*A0 - Utility address
*A2 - Address buffer
*NOTES:
*Adding chars to the buffer a byte at a time seems to work the best
*Adding words or longwords can sometimes land on odd memory address
*which do no allow memory to be written to.  To combat this, move
*chars as bytes.  Tideous, but effective.
*EXAMPLE:   MOVE.B  #$20, (A2)+     *' ' to buffer
*----------------------------------------------------------- 

************************************************************
*HEX2ASCII
*Description: Converts bit to ASCII and send to buffer
************************************************************            
HEX2ASCII:  
            CMP.B       #$A, D3     *hex char?
            BGE         letter      *letter?
number      ADDI.B      #$30,D3     *convert to ASCII
            BRA         W2B         *
letter      ADDI.B      #$37,D3     *
W2B         MOVE.B      D3,(A2)+    *to buffer
endH2A      RTS                     *return
*===========================================================   

************************************************************
*REG2BUFFER
*Description: Finds the register size and sends it to the output buffer
* 1001 0110 0100 0001
*      ^-^--------->|
*Registers Used:
*D3 - size bit
*D7 - copy of instruction
*A2 - buffer address of decoded instruction          
************************************************************
REG2BUFFER:
            MOVE.W  D7,D3            *move to utility
            LSR.L   #8,D3            *shift
            LSR.L   #1,D3            *shift
            ANDI.B  #$7,D3           *isolate last 7 bits for register number
            ADD.B   #$30,D3          *convert register number to ascii
            MOVE.B  D3,(A2)+         *to buffer
endR2B      RTS                      *return
*===========================================================

************************************************************
*SIZE2BUFFER
*Description: Isolates and converts the instruction size and sends it to the output buffer
*             Byte, word, long read word in memory for instructions that utilize immediate
*             data.  At the end of the instruction, the working memory address is advanced.
*Registers Used:
*D3 - size bit
*A2 - buffer address of decoded instruction
************************************************************
SIZE2BUFFER:
            JSR     GETSIZE         *get the size of bit
            CMP.B   #%00, D3        *byte
            BEQ     s2bB            *
            CMP.B   #%01, D3        *word
            BEQ     s2bW            *
            CMP.B   #%10, D3        *long
            BEQ     s2bL            *
            JMP     BADINST         *bad instruction
            JMP     ends2b          *
            
s2bB        MOVE.B  #$42,(A2)+      *'B' to buffer
            JMP     ends2b          *
s2bW        MOVE.B  #$57,(A2)+      *'W' to buffer
            JMP     ends2b          *
s2bL        MOVE.B  #$4C,(A2)+      *'L' to buffer
ends2b      RTS                     *return
*===========================================================

************************************************************
*BYTE2BUFFER
*Description: Converts a byte in memory to ASCII and sends it
*            to the buffer.
*Buffer: $XX
*Registers Used:
*D2 - utility register
*D3 - utility register
*D4 - counter
*A0 - working address
*A2 - buffer address of decoded instruction
************************************************************
BYTE2BUFFER:  
            MOVE.B  #$24, (A2)+     *'$' to buffer
            CLR.L       D4                  *clear counter
            *ADDQ.W      #2, A0
            MOVE.W      (A0), D2
            MOVE.B      #2, D4              *load counter
**LOOP******************************************************
B2BLoop                 
            CMP.B      #$0, D4            *end?
            BEQ         endB2B             *
            ROL.B       #4, D2             *roll bits
            MOVE.W      D2, D3             *move to utility
            ANDI.W      #$000F, D3          *isolate  
            JSR         HEX2ASCII           *load ascii char into buffer            
            SUBQ.B      #$1, D4             *subtract from counter
            JMP         B2BLoop             *keep looping until counter hits zero
            
endB2B      MOVE.W      D7, D3              *load from utility            
            ADDQ.W      #2, A0              *advancing memory pointer by word  
            RTS                             *return
*===========================================================

************************************************************
*WORD2BUFFER
*Description: Converts a word in memory to ASCII and sends it
*            to the buffer.
*Buffer: $XXXX
*Registers Used:
*D2 - utility register
*D3 - utility register
*D4 - counter
*A0 - working address
*A2 - buffer address of decoded instruction
************************************************************
WORD2BUFFER: 
            MOVE.B  #$24, (A2)+     *'$' to buffer
            CLR.L   D4
            *ADDQ.W  #2, A0                  *clear counter
            MOVE.W  (A0), D2            
            MOVE.B  #4, D4              *load counter
**LOOP******************************************************
W2BLoop                 
            CMP.B       #$00, D4            *end?
            BEQ         endW2B              *
            ROL.W       #4, D2              *roll the bits in D2 to the left
            MOVE.W      D2, D3              *move rolled bits into temp storage
            ANDI.W      #$000F, D3          *and the bits to isolate ascii char   
            JSR         HEX2ASCII           *load ascii char into buffer            
            SUBQ.B      #$1, D4             *subtract from counter
            JMP         W2BLoop             *keep looping until counter hits zero
       
endW2B      MOVE.W      D7, D3              *load from utility            
            ADDQ.W      #2, A0              *advancing memory pointer by word   
            RTS                             *return
*===========================================================
 
************************************************************
*LONG2BUFFER
*Description: Converts a long word in memory to ASCII and sends
*            it to the buffer.
*Buffer: $XXXXXXXX
*Registers Used:
*D2 - utility register
*D3 - utility register
*D4 - counter
*A0 - working address
*A2 - buffer address of decoded instruction
************************************************************           
LONG2BUFFER:
            MOVE.B  #$24, (A2)+     *'$' to buffer
            CLR.L       D4          *clear counter
            *ADDQ.W      #2, A0     *clear counter
            MOVE.L      (A0), D2 
            MOVE.B      #8, D4      *load counter
**LOOP******************************************************
L2BLoop                 
            CMP.B       #$00, D4    *end?
            BEQ         endL2B      *
            ROL.L       #4, D2      *
            MOVE.W      D2, D3      *
            ANDI.W      #$000F, D3  *isolate
            JSR         HEX2ASCII   *to buffer           
            SUBQ.B      #$1, D4     *subtract from counter
            JMP         L2BLoop     *loop
            
endL2B      MOVE.W      D7, D3      *load from utility           
            ADDQ.W      #4, A0      *advancing memory pointer by word  
            RTS  
*===========================================================
           
************************************************************
*IMM2BUFER
*Description: Converts immediate data and sends to buffer
*Registers Used:
*D3 - utility register
*A2 - buffer address of decoded instruction
************************************************************ 
IMM2BUFER:
            MOVE.B  #$23, (A2)+     *'#' to buffer
            JSR     srSize          *get bit size
            CMPI.B  #%01, D3        *byte?
            BEQ     BYTE2BUFFER     *
            CMPI.B  #%11, D3        *word?
            BEQ     WORD2BUFFER     *
            CMPI.B  #%10, D3        *long?
            BEQ     LONG2BUFFER     *
endI2B      RTS                     *return
*===========================================================        

************************************************************
*BADINST
*Description: A bad instruction has been called, print to console
*Buffer: '$0x00000000   DATA    BadWord'
*Registers Used:
*D3 - utility register
*D5 - flag condition
*A2 - buffer address of decoded instruction
*A2 - working address
************************************************************
BADINST:
**ADDRESS***************************************************
            MOVE.B  #0, D5          *set flag to bad for double EA check
            LEA     buf, A2         *reload buffer
            JSR     ADDRESS         *address to buffer
**DATA******************************************************        
            MOVE.B  #$44,(A2)+      *'D' to buffer
            MOVE.B  #$41,(A2)+      *'A' to buffer
            MOVE.B  #$54,(A2)+      *'T' to buffer
            MOVE.B  #$41,(A2)+      *'A' to buffer
            MOVE.B  #$9, (A2)+      *tab buffer
            MOVE.B  #$24,(A2)+      *'$' to buffer
**BAD WORD**************************************************            
            MOVE.W  (A0), D3        *
            MOVE.B  #12, D4         *$1254
            JSR     SHIFT           * ^
            JSR     Hex2ASCII       *to ASCII
            MOVE.W  (A0), D3        *
            MOVE.B  #8, D4          *$1254
            JSR     SHIFT           *  ^
            JSR     Hex2ASCII       *to ASCII
            MOVE.W  (A0), D3        *
            MOVE.B  #4, D4          *$1254
            JSR     SHIFT           *   ^
            JSR     Hex2ASCII       *to ASCII
            MOVE.W  (A0), D3        *$1254
            ANDI.W  #$000F, D3      *    ^
            JSR     Hex2ASCII       *to ASCII
endbadinst  RTS                     *return
*===========================================================    

************************************************************
*  _____ _   _ ____      ____ ___ __  __ 
* | ____| \ | |  _ \    / ___|_ _|  \/  |
* |  _| |  \| | | | |   \___ \| || |\/| |
* | |___| |\  | |_| |    ___) | || |  | |
* |_____|_| \_|____/    |____/___|_|  |_|
*                                       
*END
*Description: Ends program
************************************************************          
END:        
            MOVE.B  #14, D0
            LEA     strBadInst, A1
            TRAP    #15

            MOVE.B  badInstCount, D1
            MOVE.B  #3, D0
            TRAP    #15
            
            JSR     dis_cr
            
            MOVE.B  #13,D0              *load task
            LEA     str_end,A1            *load string
            TRAP    #15                 *display

           
            SIMHALT              
*===========================================================
         
*-----------------------------------------------------------
*variables
*-----------------------------------------------------------
intro       dc.b '          66666666        888888888     KKKKKKKKK    KKKKKKK',CR,LF 
            dc.b '         6::::::6       88:::::::::88   K:::::::K    K:::::K',CR,LF
            dc.b '        6::::::6      88:::::::::::::88 K:::::::K    K:::::K',CR,LF
            dc.b '       6::::::6      8::::::88888::::::8K:::::::K   K::::::K',CR,LF
            dc.b '      6::::::6       8:::::8     8:::::8KK::::::K  K:::::KKK',CR,LF
            dc.b '     6::::::6        8:::::8     8:::::8  K:::::K K:::::K   ',CR,LF
            dc.b '    6::::::6          8:::::88888:::::8   K::::::K:::::K    ',CR,LF
            dc.b '   6::::::::66666      8:::::::::::::8    K:::::::::::K     ',CR,LF
            dc.b '  6::::::::::::::66   8:::::88888:::::8   K:::::::::::K     ',CR,LF
            dc.b '  6::::::66666:::::6 8:::::8     8:::::8  K::::::K:::::K    ',CR,LF
            dc.b '  6:::::6     6:::::68:::::8     8:::::8  K:::::K K:::::K   ',CR,LF    
            dc.b '  6:::::6     6:::::68:::::8     8:::::8KK::::::K  K:::::KKK',CR,LF     
            dc.b '  6::::::66666::::::68::::::88888::::::8K:::::::K   K::::::K',CR,LF     
            dc.b '   66:::::::::::::66  88:::::::::::::88 K:::::::K    K:::::K',CR,LF
            dc.b '     66:::::::::66      88:::::::::88   K:::::::K    K:::::K',CR,LF
            dc.b '       666666666          888888888     KKKKKKKKK    KKKKKKK',CR,LF
            dc.b '                                                            ',CR,LF  
            dc.b '                                                            ',CR,LF  
            dc.b '    ____  _                                __    __         ',CR,LF
            dc.b '   / __ \(_)________ _________  ____ ___  / /_  / /__  _____',CR,LF
            dc.b '  / / / / / ___/ __ `/ ___/ _ \/ __ `__ \/ __ \/ / _ \/ ___/',CR,LF
            dc.b ' / /_/ / (__  ) /_/ (__  )  __/ / / / / / /_/ / /  __/ /    ',CR,LF
            dc.b '/_____/_/____/\__,_/____/\___/_/ /_/ /_/_.___/_/\___/_/     ',CR,LF
            dc.b '                                                            ',CR,LF  
            dc.b '                                                            ',0,CR,LF 
            
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
cr_len      dc.w    cr_len-str_cr


bufferend   dc.b    1
print_stack ds.b    8

str_end     dc.b '                                                                                   ',CR,LF  
            dc.b '                                                                                   ',CR,LF 
            dc.b '                                                                                   ',CR,LF 
            dc.b '                                                                                   ',CR,LF 
            dc.b '  /$$$$$$   /$$$$$$  /$$      /$$ /$$$$$$$  /$$       /$$$$$$$$ /$$$$$$$$ /$$$$$$$$',CR,LF
            dc.b ' /$$__  $$ /$$__  $$| $$$    /$$$| $$__  $$| $$      | $$_____/|__  $$__/| $$_____/',CR,LF
            dc.b '| $$  \__/| $$  \ $$| $$$$  /$$$$| $$  \ $$| $$      | $$         | $$   | $$      ',CR,LF
            dc.b '| $$      | $$  | $$| $$ $$/$$ $$| $$$$$$$/| $$      | $$$$$      | $$   | $$$$$   ',CR,LF
            dc.b '| $$      | $$  | $$| $$  $$$| $$| $$____/ | $$      | $$__/      | $$   | $$__/   ',CR,LF
            dc.b '| $$    $$| $$  | $$| $$\  $ | $$| $$      | $$      | $$         | $$   | $$      ',CR,LF
            dc.b '|  $$$$$$/|  $$$$$$/| $$ \/  | $$| $$      | $$$$$$$$| $$$$$$$$   | $$   | $$$$$$$$',CR,LF
            dc.b ' \______/  \______/ |__/     |__/|__/      |________/|________/   |__/   |________/',0,CR,LF

strBadInst      dc.b    '                            ',CR,LF
                dc.b    '                            ',CR,LF
                dc.b    '                            ',CR,LF
                dc.b    'Number of bad instructions: ',0
badInstCount    dc.b    0
*v_srt_add   ds.l    1               *store start address
*v_end_add   ds.l    1               *store end address
*v_test      ds.l    1               *start a temp value


    END    START        ; last line of source












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
