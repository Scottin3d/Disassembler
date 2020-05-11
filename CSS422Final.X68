*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A    

    ORG    $1000
START:                  ; first instruction of program

* Put program code here


START_MSG:
        LEA             DISPLAY_START_MESSAGE,A1
        MOVE.B          #14,D0  
        TRAP            #15
    
        LEA             DISPLAY_START_ADDRESS,A1
        MOVE.B          #14,D0  
        TRAP            #15

        MOVE.B          #4,D0          
        TRAP            #15             
        CMP.L           #0769484,D1

    SIMHALT ; halt simulator

READ_BIT:
    *Read first btye of word
    
HEX_DECODE:
    *Sets each hexbit to register

* Put variables and constants here

DISPLAY_START_MESSAGE   DC.B    'CSS 422 Final Project',CR,LF,0
DISPLAY_START_ADDRESS   DC.B    'Starting Memory Location: ',0
DISPLAY_END_ADDRESS     DC.B    'Ending Memory Location: ',0

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
