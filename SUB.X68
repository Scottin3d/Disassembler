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
*D7 - Copy of instruction in register
*
*A0 - temp address holder
*A1 - trap address
*A2 - buffer address of decoded instruction
*A3 - working address
*A4 - starting address
*A5 - ending address
*A6 -
*A7 -
*-----------------------------------------------------------
start       EQU     $1000
            ORG     start           *start
            
            SUB     D1, D3          *samle instruction to verify
            MOVE.L  #$9641, D7      *'SUB D1, D3' to instruction register
            LEA     buffer, A2      *load buffer to address
            BSR     SUB             *beging SUB subroutine
            
            *print to console
            MOVE.B  #00, (A2)
            MOVE.B  #13, D0
            LEA     buffer, A1
            TRAP    #15
            
            JMP     END             *end
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
************************************************************
SUB:
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
            JMP     endsub          *return
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
            JMP     endsub          *return
**SUB*Register>>EA******************************************            
subSubR     MOVE.B  #$44,(A2)+      *'D' to buffer
            JSR     GETREGISTER     *get the register number
            MOVE.B  #$2C,(A2)+      *',' to buffer
            JSR     GETEA           *get effective address
endsub      RTS                     *return
*===========================================================

************************************************************
*GETEA
*Description: Converts the opcode instruction EA
* 1001 0110 0100 0001
*             ^-----^
*Registers Used:
*TODO
************************************************************
GETEA:
            *MOVE.W  #$4541, (A2)+   *'EA' to buffer
            *TODO
            LEA     ea_table, A6
            CLR.L   D3
            CLR.L   D7
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
ea_table       
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
************************************************************
*Data Register
eacode000   MOVE.W      D7, D3          *move to utility
            ANDI.W      #$7, D3         *isolate
            MOVE.B      #$44,(A2)+      *'D' to buffer
            ADD.B       #$30, D3        *convert register number to ascii
            MOVE.B      D3,(A2)+        *to buffer                  
endea000    RTS                         *return

*Address Register
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

*Address with Postincrement
eacode011   MOVE.W      D7, D3          *move to utility
            ANDI.W      #$7, D3         *isolate
            MOVE.B      #$28,(A2)+      *'(' to buffer            
            MOVE.B      #$41,(A2)+      *'A' to buffer
            ADD.B       #$30, D3        *convert register number to ascii
            MOVE.B      D3,(A2)+        *to buffer  
            MOVE.B      #$29,(A2)+      *')' to buffer
            MOVE.B      #$2B, (A2)+     *'+' to buffer
endea011    RTS                         *return

*Address with Predecrement
eacode100   MOVE.W      D7, D3          *move to utility
            ANDI.W      #$7, D3         *isolate
            MOVE.B      #$2D,(A2)+      *'-' to buffer 
            MOVE.B      #$28,(A2)+      *'(' to buffer            
            MOVE.B      #$41,(A2)+      *'A' to buffer
            ADD.B       #$30, D3        *convert register number to ascii
            MOVE.B      D3,(A2)+        *to buffer  
            MOVE.B      #$29,(A2)+      *')' to buffe
endea100    RTS                         *return

*Bad Instruction
eacode101   JMP         BADINST

*Bad Instruction
eacode110   JMP         BADINST


*Immediate
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

REGISTERBIT:
            MOVE.W  D7, D3
            ANDI.W  #$07, D3
endrb       RTS

PC2BUFFER:
            JSR     WORD2BUFFER
            MOVE.B      #$28,(A2)+   *'(' to buffer            
            MOVE.B      #$50,(A2)+   *'P' to buffer
            MOVE.B      #$43,(A2)+   *'C' to buffer
            MOVE.B      #$29,(A2)+   *')' to buffer                        
endpc2b     RTS
            

IMM2BUFER:
            
endi2b      RTS

*SIZE2BUFFER
*Description: Isolates and converts the instruction size and sends it to the output buffer
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
endbi       RTS                     *return
*===========================================================

END:
            SIMHALT 
buffer      dc.b    1

            END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
