*-----------------------------------------------------------
* Title      :MOVE Test File
* Written by :SCott Shirley
* Date       :04 June 2020
* Description:Test 68k disassemble MOVE instructions
*-----------------------------------------------------------
    ORG    $400
START:                  ; first instruction of program

*start: 400
*end:   42C
TEST
label1  EQU $620

label2  EQU $740

label3  EQU $840
    BCC     label1
    BCC     label2
    BGT     label1
    BGT     label2
    BLE     label1
    BLE     label2
    BCC     label1
    BCC     label2
    BCC     label3
    BGT     label1
    BGT     label2
    BGT     label3
    BLE     label1
    BLE     label2
    BLE     label3
   

endTEST
    SIMHALT             ; halt simulator

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
