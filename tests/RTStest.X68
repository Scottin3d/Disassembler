*-----------------------------------------------------------
* Title      :RTS and JMP Test File
* Written by :SCott Shirley
* Date       :04 June 2020
* Description:Test 68k disassemble RTS and JMP instructions
*-----------------------------------------------------------
    ORG    $400
START:                  ; first instruction of program

*start: 400
*end:   418
TEST
    JMP label2
    JMP label2
    JMP label3

label1
     RTS
label2
     RTS
label3
     RTS
endTEST
    SIMHALT             ; halt simulator

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
