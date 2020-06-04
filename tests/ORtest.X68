*-----------------------------------------------------------
* Title      :OR Test File
* Written by :Scott Shirley
* Date       :04 June 2020
* Description:Test 68k disassemble OR instructions
*-----------------------------------------------------------
    ORG    $400
START:                  ; first instruction of program

*start: 400
*end:   42A
TEST
    OR.B     D1,D2
    OR.B     D1,(A1)
    OR.B     D1,(A1)+
    OR.B     D1,-(A1)
    OR.B     (A1),D1
    OR.B     (A1)+,D1
    OR.B     -(A1),D1
    OR.W     D1,D2
    OR.W     D1,(A1)
    OR.W     D1,(A1)+
    
    OR.W     D1,-(A1)
    OR.W     (A1),D1
    OR.W     (A1)+,D1
    OR.W     -(A1),D1
    OR.L     D1,D2
    OR.L     D1,(A1)
    OR.L     D1,(A1)+
    OR.L     D1,-(A1)
    OR.L     (A1),D1
    OR.L     (A1)+,D1
    
    OR.L     -(A1),D1
    

endTEST
    SIMHALT             ; halt simulator

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
