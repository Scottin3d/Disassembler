*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
*Register Use
*For consistency, please utilize registers in the following way.
*
*D0 - utility registe
*D1 - utility registe
*D2 - utility registe
*D3 - utility register
*D4 - local counter
*D5 - flag condition
*D6 - master counter
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
    ORG    $1000
START:                  ; first instruction of program
            
            LEA     $400, A0
            MOVE.W  #$4CDF, (A0)+
            MOVE.W  #$001f, (A0)+
            LEA     $400, A0
            LEA     $410, A2
            MOVE.W  (A0)+, D7
            
            MOVE.L  D7, D3
            AND.W   #%0000000111000000, D3    *isolate bits 8 - 6
            ASR.W     #$6, D3
            *ASR.W     #$4, D3
            CMPI.W  #%011, D3
            BEQ     MOVEmem

            
print_b        MOVE.B  #00,(A2)
            LEA     $410,A1
            MOVE.B  #13,D0
            TRAP    #15
            
            JMP     END
MOVEmem     
            CLR D2
            CLR D3
            MOVE.W D7, D3
            MOVE.W D3, D3
            MOVE.B  #$4D, (A2)+     *'M' to buffer
            MOVE.B  #$4F, (A2)+     *'O' to buffer
            MOVE.B  #$56, (A2)+     *'V' to buffer
            MOVE.B  #$45, (A2)+     *'E' to buffer
            MOVE.B  #$4D, (A2)+     *'M' to buffer
            MOVE.B  #$2E, (A2)+     *'.' to buffer
            
            
            AND.W #%0000000001000000, D3    *isolate 6 bit
            ASR.W #$6, D3
            JSR    SIZE2BUFFER
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE.B  #$20, (A2)+     *' ' to buffer
            MOVE D7, D3
            AND.W #%0000010000000000, D3 **Checks the direction **
            ASR.W #$8, D3
            ASR.W #$2, D3
            MULU #$6, D3
            LEA MOVEmem_table, A6
            JSR 0(A6, D3)               *memory direction jump table
            JMP     print_b

MOVEmem_table  
                JMP Reg2Mem
                JMP Mem2Reg
                RTS
Reg2Mem
               MOVE.W D1, D0             
               JSR GETMWORD             *loads next word (A0) to D1
               JSR Get_PRE_DReg_List    *get bits 7 - 0
               JSR Get_PRE_AReg_List    *get bits 15 - 8
               
               MOVE.B #$FF, -(A2)
               MOVE.B #$2C, (A2)+
               MOVE.B #$20, (A2)+
               MOVE.W D0, D1
               
               JSR      GETEA
               RTS
               
Mem2Reg
               JSR      GETEA
               MOVE.B #$2C, (A2)+ *',' to buffer
               MOVE.B #$20, (A2)+   *' ' to buffer
               
               JSR GETMWORD
               MOVE.W D1, D0
      
               JSR Get_POST_AReg_List
               MOVE.W D0, D1
               JSR Get_POST_DReg_List
               MOVE.B #$FF, -(A2)
               RTS    

*Predec Register
Get_PRE_DReg_List
               MOVE.W D1, D4
               LSR #$8, D4 ** Data Register mask **
               MOVE.B #$00, D5 ** Preps D5
               MOVE.B #$09, D6 ** Sets the counter **
               
loopPRE_Dlist     
               SUB.B #$1, D6
               CMP.B #$00, D6
               BEQ end_loop
               LSL.B #1, D4
               BCS printPRE_DReg_List
               BRA loopPRE_Dlist
               RTS

printPRE_DReg_List
               MOVE.B #$38, D5
               SUB.B D6, D5
               MOVE.B #$44, (A2)+
               MOVE.B D5, (A2)+
               MOVE.B #$2F, (A2)+
               BRA loopPRE_Dlist
               
*Predec Address               
Get_PRE_AReg_List
               MOVE.B D1, D4     ***Moves the address list mask to d4 ***
               MOVE.B #$00, D5  ** Preps D5
               MOVE.B #9, D6    ** Sets the counter to 8 
               **ASR #8, D4      ** Shifts the mask for Address Registers **
loopPRE_Alist
               SUB.B #$01, D6  ** Decrements the counter **
               CMP.B #$00, D4
               BEQ end_loop
               CMP.B #$00, D6  ** Checks the counter **
               BEQ end_loop   ** Ends the loop when counter is = 0 **
               LSL.B #1, D4  ** Shifts mask to the left by one **
               BCS printPRE_AReg_List ** Checks the carry Set bit **
               BRA loopPRE_Alist
               RTS

printPRE_AReg_List
               MOVE.B #$38, D5
               SUB.B D6, D5
               MOVE.B #$41, (A2)+
               MOVE.B D5, (A2)+
               MOVE.B #$2F, (A2)+
               BRA loopPRE_Alist

*Post Address
Get_POST_AReg_List
               MOVE.W D1, D4
               ASR #8, D4
               MOVE.B #$00, D5  ** Preps D5
               MOVE.B #9, D6    ** Sets the counter to 8 
loopPOST_Alist
               SUB.B #$01, D6  ** Decrements the counter **
               CMP.B #$00, D4
               BEQ end_loop
               CMP.B #$00, D6  ** Checks the counter **
               BEQ end_loop   ** Ends the loop when counter is = 0 **
               LSL.B #1, D4  ** Shifts mask to the left by one **
               BCS printPOST_AReg_List ** Checks the carry Set bit **
               BRA loopPOST_Alist
               RTS
               
               
printPOST_AReg_List
               MOVE.B #$30, D5
               ADD.B D6, D5
               SUB.B #$1, D5
               MOVE.B #$41, (A2)+
               MOVE.B D5, (A2)+
               MOVE.B #$2F, (A2)+
               BRA loopPOST_Alist

*Post Register
Get_POST_DReg_List
               MOVE.B D1, D4
               MOVE.B #$00, D5 ** Preps D5
               MOVE.B #$09, D6 ** Sets the counter **
               
loopPOST_Dlist     
               SUB.B #$1, D6
               CMP.B #$00, D6
               BEQ end_loop
               LSL.B #1, D4
               BCS printPOST_DReg_List
               BRA loopPOST_Dlist
               RTS

               
printPOST_DReg_List
               MOVE.B #$30, D5
               ADD.B D6, D5
               SUB.B #$1, D5
               MOVE.B #$44, (A2)+
               MOVE.B D5, (A2)+
               MOVE.B #$2F, (A2)+
               BRA loopPOST_Dlist

end_loop        RTS               
               
*GETMWORD********************************************************              
GETMWORD
            MOVE.W (A0)+, D1
endGETMWORD RTS

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
*=========================================================

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
            
BADINST     RTS
GETSIZE         RTS
GETREGISTER     RTS
WORD2BUFFER     RTS
LONG2BUFFER     RTS
IMM2BUFER       RTS
    SIMHALT             ; halt simulator

* Put variables and constants here
END
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
