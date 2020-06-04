*-----------------------------------------------------------
* Title      :ADD Test File
* Written by :Scott Shirley
* Date       :04 June 2020
* Description:Test 68k disassemble ADD instructions
*-----------------------------------------------------------
    ORG    $400
START:                  ; first instruction of program

*start: 400
*end:   4C2
TEST
*registers/ address
    ADD.B     D1,D2
    ADD.B     D1,(A1)
    ADD.B     D1,(A1)+
    ADD.B     D1,-(A1)
    ADD.B     (A1),D1
    ADD.B     (A1)+,D1
    ADD.B     -(A1),D1
    ADD.W     D1,D2
    ADD.W     D1,(A1)
    ADD.W     D1,(A1)+
    ADD.W     D1,-(A1)
    ADD.W     (A1),D1
    ADD.W     (A1)+,D1
    ADD.W     -(A1),D1
    ADD.L     D1,D2
    ADD.L     D1,(A1)
    ADD.L     D1,(A1)+
    ADD.L     D1,-(A1)
    ADD.L     (A1),D1
    ADD.L     (A1)+,D1
    ADD.L     -(A1),D1
    ADDA.W        D1,A2
    ADDA.W        (A1),A2
    ADDA.W        (A1)+,A2
    ADDA.W        -(A1),A2
    ADDA.L        D1,A2
    ADDA.L        (A1),A2
    ADDA.L        (A1)+,A2
    ADDA.L        -(A1),A2
*immediate/ absolute
    ADD.B     D1,$12
    ADD.B     D1,$1234
    ADD.B     D1,$12345678
    ADD.B     $12,D1
    ADD.B     $1234,D1
    ADD.B     $12345678,D1
    ADD.B     #$12,D1
    ADD.W     D1,$12
    ADD.W     D1,$1234
    ADD.W     D1,$12345678
    ADD.W     $12,D1
    ADD.W     $1234,D1
    ADD.W     $12345678,D1
    ADD.W     #$1234,D1
    ADD.L     D1,$12
    ADD.L     D1,$1234
    ADD.L     D1,$12345678
    ADD.L     $12,D1
    ADD.L     $1234,D1
    ADD.L     $12345678,D1
    ADD.L     #$12345678,D1
    ADDA.W    $12,A2
    ADDA.W    $1234,A2
    ADDA.W    $12345678,A2
    ADDA.W    #$1234,A2
    ADDA.L    $12,A2
    ADDA.L    $1234,A2
    ADDA.L    $12345678,A2
    ADDA.L    #$12345678,A2

endTEST
    SIMHALT             ; halt simulator

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
