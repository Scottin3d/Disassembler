*-----------------------------------------------------------
* Title      :CLR Test File
* Written by :SCott Shirley
* Date       :04 June 2020
* Description:Test 68k disassemble CLR instructions
*-----------------------------------------------------------
    ORG    $400
START:                  ; first instruction of program

TEST
*various size
    CLR.B     D0
    CLR.B     D7
    CLR.W     D0
    CLR.W     D7
    CLR.L     D0
    CLR.L     D7
    CLR.B     (A0)
    CLR.B     (A7)
    CLR.W     (A0)
    CLR.W     (A7)
    CLR.L     (A0)
    CLR.L     (A7)
*posd
    CLR.B     (A0)+
    CLR.B     (A7)+
    CLR.W     (A0)+
    CLR.W     (A7)+
    CLR.L     (A0)+
    CLR.L     (A7)+
*pre
    CLR.B     -(A0)
    CLR.B     -(A7)
    CLR.W     -(A0)
    CLR.W     -(A7)
    CLR.L     -(A0)
    CLR.L     -(A7)
*immediate data
    CLR.B     $12
    CLR.B     $1234
    CLR.B     $12345678
    CLR.W     $12
    CLR.W     $1234
    CLR.W     $12345678
    CLR.L     $12
    CLR.L     $1234
    CLR.L     $12345678
endTEST
    SIMHALT             ; halt simulator

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
