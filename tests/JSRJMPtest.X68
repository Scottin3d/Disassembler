*-----------------------------------------------------------
* Title      :JSR Test File
* Written by :Scott Shirley
* Date       :04 June 2020
* Description:Test 68k disassemble JSR instructions
*-----------------------------------------------------------
    ORG    $400
START:                  ; first instruction of program

*start: 400
*end:   424
TEST
label1
    JSR       (A0)
    JSR       $1234
    JSR       $12345678
label2
    JSR       label1
    JSR       label2
label3
    JSR       label3
    JSR       label1
    JSR       label2
    JSR       label3

endTEST
    SIMHALT             ; halt simulator

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
