*-----------------------------------------------------------
* Title      :SUB Test File
* Written by :SCott Shirley
* Date       :04 June 2020
* Description:Test 68k disassemble SUB instructions
*-----------------------------------------------------------
*ERROR REPORT
*Memory Address*  *Word Output* 
*45A                0012
*45C                9378
*47A                1234
*47C                93B8


    ORG    $400
START:                  ; first instruction of program

*start: 400
*end:   498
TEST
*registers/ address
    SUB.B     D1,D2
    SUB.B     D1,(A1)
    SUB.B     D1,(A1)+
    SUB.B     D1,-(A1)
    SUB.B     (A1),D1
    SUB.B     (A1)+,D1
    SUB.B     -(A1),D1
    SUB.W     D1,D2
    SUB.W     D1,A1     *error
    SUB.W     D1,(A1)
    *break
    SUB.W     D1,(A1)+
    SUB.W     D1,-(A1)
    SUB.W     A1,D1
    SUB.W     (A1),D1
    SUB.W     (A1)+,D1
    SUB.W     -(A1),D1
    SUB.L     D1,D2
    SUB.L     D1,A1
    SUB.L     D1,(A1)
    SUB.L     D1,(A1)+
    *break
    SUB.L     D1,-(A1)
    SUB.L     A1,D1
    SUB.L     (A1),D1
    SUB.L     (A1)+,D2
    SUB.L     -(A1),D3
    SUB.W     (A1),D4
    SUB.W     (A1)+,D5
    SUB.W     -(A1),D6
    SUB.L     D1,D7
    SUB.L     D1,A5  
*absolute/ immediate
    SUB.B     D1,$12
    SUB.B     D1,$1234
    SUB.B     D1,$12345678
    SUB.B     $12,D1
    SUB.B     $1234,D1
    SUB.B     $12345678,D1
    SUB.B     #$12,D1       *error
    SUB.W     D1,$12        *error
    SUB.W     D1,$1234
    SUB.W     D1,$12345678
    *break
    SUB.W     $12,D1
    SUB.W     $1234,D1
    SUB.W     $12345678,D1
    SUB.W     #$1234,D1
    SUB.L     D1,$12        *error
    SUB.L     D1,$1234      *error
    SUB.L     D1,$12345678
    SUB.L     $12,D1
    SUB.L     $1234,D1
    SUB.L     $12345678,D1
endTEST
    SIMHALT             ; halt simulator
    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
