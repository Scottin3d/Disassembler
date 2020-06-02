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
*A3 -
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
            LEA     buffer, A2          *set buffer for input
            MOVEA.L A2,A6 
            
            
main_input  BSR     U_INPUT             *branch to input
            CMP.B   #$0, D5             *check if bad input
            BEQ     dis_badInput        *bad flag, reinput 
                        
main_loop   JSR     BUFFER_PREP         *prep buffer

*loop checking      
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

*bad input error message display
************************************************************
dis_badInput
            MOVE.B  #task0,D0           *load task
            LEA     str_error, A1       *load string
            MOVE.W  err_len, D1         *load string length
            TRAP    #15                 *display
            MOVE.B  #badFlag,D5         *set flag condition to bad
endBI       JSR     main_input          *return to main_input

*dsiplay carriage return
************************************************************
dis_cr
            MOVE.B  #task13, D0         *load task
            LEA     str_cr, A1          *load string
            MOVE.W  cr_len, D1          *load string length
            TRAP    #15                 *display
end_cr      RTS                         *return

*enter2return
************************************************************
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
*BUFFER_PREP
************************************************************
BUFFER_PREP:
            MOVE.L  #$9641, D7      *'SUB D1, D3' to instruction register
            LEA     buffer, A2      *load buffer to address
            BSR     GETOPCODE       *beging SUB subroutine


printBP     JSR         printinst  
            ADDQ.W      #2, A0      *advancing memory pointer by word  
endBP       RTS


printinst   
            *print to console
            MOVE.B  #00, (A2)
            MOVE.B  #13, D0
            LEA     buffer, A1
            TRAP    #15

            
end_pi      RTS
*===========================================================                       

************************************************************
*BUFFER_FILL
*Description: Fills the buffer with the current address
************************************************************
BUFFER_FILL:
           MOVEA.L  A2,A1              *load trap address with A2            
           *JSR      getLong
           MOVE.B   #$09,(A2)+                                  
endbf      RTS
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
endgop      RTS                         *return
*===========================================================

************************************************************
*OPCODE Table
*Description: Table of OPCODES
************************************************************ 
OP_TABLE
            JMP         code0000
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
code0000:   JMP     BADINST
*===========================================================

************************************************************  
* Case for: 0001
* --(MOVE.B)
code0001:
*===========================================================

************************************************************  
* Case for: 0010
* --(MOVE.L, MOVEA.L)
code0010:
*===========================================================

************************************************************  
* Case for: 0011
* --(MOVE.W, MOVEA.W)
code0011:
*===========================================================

************************************************************  
* Case for: 0100
* --(CLR,MOVEM,JMP,JSR,RTS,LEA) 
code0100:

************************************************************  
* Case for: 0101
* --BAD INSTRUCTION
code0101:
*===========================================================

************************************************************  
* Case for: 0110
* --(Bcc)
code0110:
*===========================================================

************************************************************  
* Case for: 0111
* --BAD INSTRUCTION
code0111:
*===========================================================

************************************************************  
* Case for: 1000
* --(OR) 
code1000:
*===========================================================

************************************************************  
* Case for: 1001
* --(SUB, SUBA)
code1001:
            MOVE.B  #$53, (A2)+     *'S' to buffer
            MOVE.B  #$55, (A2)+     *'U' to buffer
            MOVE.B  #$42, (A2)+     *'B' to buffer
            JSR     GETSIZE         *get the instruction size (OPMODE)
            CMP.B   #%11, D3        *11 = SUBA  
            BNE     subSub
            MOVE.B  #$41, (A2)+     *'A' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            MOVE.W  D7, D3          *move to utility
            LSR.L   #8, D3          *shift for opmode
            ANDI.W  #$0001, D3      *isolate 8 to determine size
            CMP.B   #%1, D3         *long?
            BEQ     subLong         *it's a longword
            JMP     subSuba
**SUBA******************************************************            
subLong     MOVE.B  #$4C, (A2)+     *'L' to buffer
subSuba     MOVE.B  #$20, (A2)+     *' ' to buffer    
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            JSR     GETEA           *get effective address
            MOVE.B  #$2C,(A2)+      *'B' to buffer
            MOVE.B  #$41,(A2)+      *'B' to buffer
            JSR     GETREGISTER     *get the register number
            JMP     end1001         *return
**SUB*EA>>Register****************************************** 
subSub      MOVE.B  #$2E, (A2)+     *'B' to buffer
            JSR     SIZE2BUFFER     *send size to buffer
            MOVE.B  #$09, (A2)+     *tab
            JSR     GETDIRECTION    *isolate bit for direction
            CMP.B   #%0, D3         *direction bit 0 = EA; 1 = regs
            BNE     subSubR         
            JSR     GETEA           *get effective address
            MOVE.B  #$2C,(A2)+      *',' to buffer   
            MOVE.B  #$44,(A2)+      *'D' to buffer
            JSR     GETREGISTER     *get the register number
            JMP     end1001         *return
**SUB*Register>>EA******************************************            
subSubR     MOVE.B  #$44,(A2)+      *'D' to buffer
            JSR     GETREGISTER     *get the register number
            MOVE.B  #$2C,(A2)+      *',' to buffer
            JSR     GETEA           *get effective address
end1001     RTS                     *return
*===========================================================
                                                       
************************************************************  
* Case for: 1010
* --BAD INSTRUCTION
code1010:
*===========================================================

************************************************************  
* Case for: 1011
* --(CMP,CMPA)
code1011:
*===========================================================

************************************************************  
* Case for: 1100
* --(ADD, AND)
code1100:
*===========================================================

************************************************************  
* Case for: 1101
* --BAD INSTRUCTION
code1101:
*===========================================================

************************************************************  
* Case for: 1110
* --(ASR, LSL)
code1110:
*===========================================================

************************************************************  
* Case for: 1111
* --BAD INSTRUCTION
code1111:
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
            *MOVE.W  #$4541, (A2)+   *'EA' to buffer
            *TODO
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
*000,001,010,011,100,101,110,111
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
            MOVE.B      #$41, D3        *'A' to buffer
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

*Immediate**************************************************
eacode111   JSR         REGISTERBIT     *isolate register bits
            CMPI.B      #$0, D3         *word?
            BEQ         WORD2BUFFER
            CMPI.B      #$1, D3         *long?
            BEQ         LONG2BUFFER
            CMPI.B      #$2, D3         *PC?
            BEQ         PC2BUFFER
            CMPI.B      #$4, D3         *Immediate Data?
            BEQ         IMM2BUFER
endea111    RTS                         *return
*===========================================================

************************************************************
*GETSIZE
*Description: Returns the size of the bit in the utility register
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
*GETREGISTER
*Description: Finds the register size and sends it to the output buffer
* 1001 0110 0100 0001
*      ^-^--------->|
*Registers Used:
*D3 - size bit
*D7 - copy of instruction
*A2 - buffer address of decoded instruction          
************************************************************
GETREGISTER:
            MOVE.W  D7,D3            *move to utility
            LSR.L   #8,D3            *shift 8
            LSR.L   #1,D3            *shift 1
            ANDI.B  #$7,D3           *isolate last 7 bits for register number
            ADD.B   #$30,D3          *convert register number to ascii
            MOVE.B  D3,(A2)+         *to buffer
endGR       RTS                      *return
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
*  ____  _   _ _____ _____ _____ ____     ____ ___  _   ___     _______ ____ _____ 
* | __ )| | | |  ___|  ___| ____|  _ \   / ___/ _ \| \ | \ \   / / ____|  _ \_   _|
* |  _ \| | | | |_  | |_  |  _| | |_) | | |  | | | |  \| |\ \ / /|  _| | |_) || |  
* | |_) | |_| |  _| |  _| | |___|  _ <  | |__| |_| | |\  | \ V / | |___|  _ < | |  
* |____/ \___/|_|   |_|   |_____|_| \_\  \____\___/|_| \_|  \_/  |_____|_| \_\|_|  
*
*BUFFER SUBROUTINES                                                                                 
*Description: Puts word to print buffer
*D3 - Utility register
*D6 - Counter
*A0 - Utility address
*A2 - Address buffer
*----------------------------------------------------------- 

************************************************************
*SIZE2BUFFER
*Description: Isolates and converts the instruction size and sends it to the output buffer
*              Byte, word, long read word in memory for instructions that utilize immediate
*              data.  At the end of the instruction, the working memory address is advanced.
*Registers Used:
*D3 - size bit
*A2 - buffer address of decoded instruction
************************************************************
SIZE2BUFFER:
            JSR     GETSIZE         *get the size of bit
            CMP.B   #%00, D3        *byte
            BEQ     s2bB        
            CMP.B   #%01, D3        *word
            BEQ     s2bW        
            CMP.B   #%10, D3        *long
            BEQ     s2bL        
            JSR     BADINST         *bad instruction
            JMP     ends2b      
            
s2bB        MOVE.B  #$42,(A2)+      *'B' to buffer
            JMP     ends2b      
s2bW        MOVE.B  #$57,(A2)+      *'W' to buffer
            JMP     ends2b    
s2bL        MOVE.B  #$4C,(A2)+      *'L' to buffer
ends2b      RTS                     *return
*===========================================================

************************************************************
*BYTE2BUFFER
*Description: Converts byte and sends it to the output buffer
*Buffer: $XX
************************************************************
BYTE2BUFFER:
            MOVEM.L     D0-D6,-(SP)         *save data registers to the stack
            MOVE.B      #'$', (A2)+  
            CLR.L       D4                  *clear counter
            MOVE.L      A0, (A7)
            MOVE.L      (A7), D7
            MOVE.L      (A7), D2            *move current word into D2 for rolling purposes
            MOVE.B      #2, D4              *load counter

b2bLoop                 
            CMP.B       #$00, D4            *compare counter with 0
            BEQ         endb2b              *if zero, return
            ROL.W       #4, D2              *roll the bits in D2 to the left
            MOVE.W      D2, D3              *move rolled bits into temp storage
            ANDI.W      #$000F, D3          *and the bits to isolate ascii char   
            JSR         HEX2ASCII           *load ascii char into buffer            
            SUBQ.B      #$1, D4             *subtract from counter
            JMP         b2bLoop             *keep looping until counter hits zero
            
endb2b      MOVE.W      D7, D3              *re-load current word for temp storage            
            ADDQ.W      #2, A0              *advancing memory pointer by word  
            MOVEM.L     (SP)+,D0-D6         *load data registers from stack   
            RTS                             *return
*===========================================================

************************************************************
*WORD2BUFFER
*Buffer: $XXXX
************************************************************
WORD2BUFFER:
            MOVEM.L     D0-D6,-(SP)         *save data registers to the stack
            MOVE.B      #'$', (A2)+  
            CLR.L       D4                  *clear counter
            MOVE.L      A0, (A7)
            MOVE.L      (A7), D7
            MOVE.L      (A7), D2            *move current word into D2 for rolling purposes
            MOVE.B      #4, D4              *load counter

w2bLoop                 
            CMP.B       #$00, D4            *compare counter with 0
            BEQ         endw2b              *if zero, return
            ROL.W       #4, D2              *roll the bits in D2 to the left
            MOVE.W      D2, D3              *move rolled bits into temp storage
            ANDI.W      #$000F, D3          *and the bits to isolate ascii char   
            JSR         HEX2ASCII           *load ascii char into buffer            
            SUBQ.B      #$1, D4             *subtract from counter
            JMP         w2bLoop             *keep looping until counter hits zero
            
endw2b      MOVE.W      D7, D3              *re-load current word for temp storage            
            ADDQ.W      #2, A0              *advancing memory pointer by word  
            MOVEM.L     (SP)+,D0-D6         *load data registers from stack   
            RTS                             *return
*===========================================================
 
************************************************************
*LONG2BUFFER
*Buffer: $XXXXXXXX
************************************************************           
LONG2BUFFER:
            MOVEM.L     D0-D6,-(SP)         *save data registers to the stack
            MOVE.B      #'$', (A2)+  
            CLR.L       D4                  *clear counter
            MOVE.L      A0, (A7)
            MOVE.L      (A7), D7
            MOVE.L      (A7), D2            *move current word into D2 for rolling purposes
            MOVE.B      #8, D4              *load counter

l2bLoop                 
            CMP.B       #$00, D4            *compare counter with 0
            BEQ         endl2b              *if 0, return
            ROL.W       #4, D2              *
            MOVE.W      D2, D3              *
            ANDI.W      #$000F, D3          *isolate
            JSR         HEX2ASCII           *to buffer           
            SUBQ.B      #$1, D4             *subtract from counter
            JMP         l2bLoop             *loop
            
endl2b      MOVE.W      D7, D3              *load from utility           
            ADDQ.W      #4, A0              *advancing memory pointer by word  
            MOVEM.L     (SP)+,D0-D6         *load data registers from stack   
            RTS  
*===========================================================
 
************************************************************
*HEX2ASCII
*Description: Converts bit to ASCII and send to buffer
************************************************************            
HEX2ASCII:  
            CMP.B       #$A, D3             * Confirm hex character?
            BGE         letter              * Is it a letter or number?
number      ADDI.B      #$30,D3             * Convert decimal to ASCII
            BRA         write2Buff          * save to good buffer
letter      ADDI.B      #$37,D3
write2buff  MOVE.B      D3,(A2)+
endh2a      RTS
*===========================================================   

************************************************************
*REGISTERBIT
*Description: Converts register bit and sends to buffer
************************************************************ 
REGISTERBIT:
            MOVE.W  D7, D3
            ANDI.W  #$07, D3
endrb       RTS
*===========================================================

************************************************************
*PC2BUFFER - NO NEED?
*Description: 
************************************************************ 
PC2BUFFER:
            JSR     WORD2BUFFER
            MOVE.B      #$28,(A2)+   *'(' to buffer            
            MOVE.B      #$50,(A2)+   *'P' to buffer
            MOVE.B      #$43,(A2)+   *'C' to buffer
            MOVE.B      #$29,(A2)+   *')' to buffer                        
endpc2b     RTS
*===========================================================
           
************************************************************
*IMM2BUFER
*Description: Converts immediate data and sends to buffer
************************************************************ 
IMM2BUFER:
            
endi2b      RTS
*===========================================================        

************************************************************
*BADINST
*Description: A bad instruction has been called, print to console
*Registers Used:
*D5 - flag condition
*A2 - buffer address of decoded instruction
*A2 - working address    
************************************************************
BADINST:
            MOVE.B  #1,D5           *set bad flag
            MOVEA.L A3, A2          *reset the buffer pointer 
            MOVE.B  #$44,(A2)+      *'D' to buffer
            MOVE.B  #$41,(A2)+      *'A' to buffer
            MOVE.B  #$54,(A2)+      *'T' to buffer
            MOVE.B  #$41,(A2)+      *'A' to buffer
            MOVE.B  #$09,(A2)+      *tab
            MOVE.B  #$24,(A2)+      *'$' to buffer     
            *JSR     getBadWord     *add bad word to buffer TODO
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
            SIMHALT              
*===========================================================
         
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
cr_len      dc.w    cr_len-str_cr

buffer      dc.b    1
print_stack ds.b    8

v_srt_add   ds.l    1               *store start address
v_end_add   ds.l    1               *store end address
v_test      ds.l    1               *start a temp value


    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
