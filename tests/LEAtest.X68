*-----------------------------------------------------------
* Title      :LEA Test File
* Written by :Scott Shirley
* Date       :04 June 2020
* Description:Test 68k disassemble LEA instructions
*-----------------------------------------------------------
    ORG    $400
START:                  ; first instruction of program

*start: 400
*end:   41A
TEST
*registers
    LEA     (A0),A0
    LEA     (A5),A0
    LEA     (A7),A0
    LEA     (A0),A7
    LEA     (A5),A7
    LEA     (A7),A7
*immediate/ absolute
    LEA       $12,A0
    LEA       $1234,A0
    LEA       $12345678,A0

endTEST
    SIMHALT             ; halt simulator

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
