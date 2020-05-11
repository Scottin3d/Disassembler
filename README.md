# Disassembler
## Contributors  
Scott Shirley @scottin3d  
Carl Howing @cjhowing7  
Daniel Yakovlev @yakovdan98  

## Overview
Disassembler (also called an inverse assembler):  
– Scans a section of memory and attempts to convert the memory’s contents to a listing of valid assembly language instructions  
- Most disassemblers cannot recreate symbolic, or label information  
- Disassemblers can be easily fooled by not starting on an instruction boundary  
- How it works:  
– Program parses the op-code word of the instruction and then decides how many additional words of memory need to be read in order to complete the instruction  
- If necessary, reads additional instruction words  
- Prints out the complete instruction in ASCII-readable format  
- Converts binary information to readable Hex

## Project Links
Github repository: https://github.com/Scottin3d/Disassembler