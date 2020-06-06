*-----------------------------------------------------------
* Title      :Immedaite Data Test File
* Written by :Scott Shirley
* Date       :04 June 2020
* Description:Test 68k disassemble Immediate Data instructions
*-----------------------------------------------------------
    ORG    $400
START:                  ; first instruction of program

*start: 400
*end:   42A
TEST
    ADDI.B    #$12,D1
    ADDI.B    #$12,(A0)
    ADDI.B    #$12,(A1)+
    ADDI.B    #$12,-(A2)
    ADDI.B    #$12,$1234
    ADDI.W    #$1234,D2
    ADDI.W    #$1234,(A3)
    ADDI.W    #$1234,(A4)+
    ADDI.W    #$1234,-(A5)
    ADDI.W    #$1234,$1234
    ADDI.W    #$1234,$12345678
    ADDI.L    #$12345678,D3
    ADDI.L    #$12345678,(A6)
    ADDI.L    #$12345678,(A6)+
    ADDI.L    #$12345678,-(A5)
    ADDI.L    #$12345678,$1234
    ADDI.L    #$12345678,$12345678

    ANDI.B    #$12,D1
    ANDI.B    #$12,(A0)
    ANDI.B    #$12,(A0)+
    ANDI.B    #$12,-(A0)
    ANDI.B    #$12,$1234
    ANDI.W    #$1234,D1
    ANDI.W    #$1234,(A0)
    ANDI.W    #$1234,(A0)+
    ANDI.W    #$1234,-(A0)
    ANDI.W    #$1234,$1234
    ANDI.W    #$1234,$12345678
    ANDI.L    #$12345678,D1
    ANDI.L    #$12345678,(A0)
    ANDI.L    #$12345678,(A0)+
    ANDI.L    #$12345678,-(A0
    ANDI.L    #$12345678,$1234
    ANDI.L    #$12345678,$12345678
    
    CMPI.B     $1234,D1
    CMPI.B     $12345678,D1
    CMPI.B     #$12,D1
    CMPI.W     $12,D1
    CMPI.W     $1234,D1
    CMPI.W     $12345678,D1
    CMPI.W     #$1234,D1
    CMPI.L     $12,D1
    CMPI.L     $1234,D1
    CMPI.L     $12345678,D1
    CMPI.L     #$12345678,D1
    
    SUBI.B     D1,$12
    SUBI.B     D1,$1234
    SUBI.B     D1,$12345678
    SUBI.B     $12,D2
    SUBI.B     $1234,D3
    SUBI.B     $12345678,D4
    SUBI.B     #$12,D5
    SUBI.W     D6,$12
    SUBI.W     D7,$1234
    SUBI.W     D3,$2345678
    SUBI.W     $12,D1
    SUBI.W     $1234,D1
    SUBI.W     $12345678,D1
    SUBI.W     #$1234,D1
    SUBI.L     D1,$12
    SUBI.L     D1,$1234
    SUBI.L     D1,$12345678
    SUBI.L     $12,D2
    SUBI.L     $1234,D1
    SUBI.L     $12345678,D1
    SUBI.L     #$12345678,D1


endTEST
    SIMHALT             ; halt simulator

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
