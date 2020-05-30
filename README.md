# Disassembler
## Contributors  
Scott Shirley @scottin3d  
Carl Howing @cjhowing7  
Daniel Yakovlev @yakovdan98  

# (1) Project Links
Github repository: https://github.com/Scottin3d/Disassembler  
Project Diagram: https://drive.google.com/open?id=1ZPQ33-BFiRYbSNXN15DFX_wUENFzlZGl 

# (2) Documentation
### Program Description
This program is written in Motorola 68000 assembly language (M68k), and its purpose is to disassemble data back into human readable opcodes and effective addresses.  
A disassembler (also called an inverse assembler) should do the following:    
* Scan a section of memory and attempt to convert the memory’s contents to a listing of valid assembly language instructions  
* Most disassemblers cannot recreate symbolic, or label information  
* Disassemblers can be easily fooled by not starting on an instruction boundary  
How it works:  
* Program parses the op-code word of the instruction and then decides how many additional words of memory need to be read in order to complete the instruction  
* If necessary, reads additional instruction words  
* Prints out the complete instruction in ASCII-readable format  
* Converts binary information to readable Hex

## Specifications
### Program Design
Project Diagram: https://drive.google.com/open?id=1ZPQ33-BFiRYbSNXN15DFX_wUENFzlZGl 

### Register Usage
For continuity, we utilized registers as followed:

|**Register**|**Usage**|
|:-:|:-|
|D0||
|D1||
|D2|copy of working address|
|D3|utility register|
|D4||
|D5|flag condition|
|D6|counter|
|D7||
|**Address**|**Usage**|
|A0|temp address holder|
|A1|trap address|
|A2|buffer address of decoded instruction|
|A3||
|A4|starting address|
|A5|ending address|
|A6||
|A7||

### Main Program
This chart outlines the main flow of the disassembler from start to finish.
![Imgur](https://i.imgur.com/UyS0BTz.png)

### User Input
USER_INPUT is a subroutine that gets a string address the user for the starting and end address. The string is validated as a HEX value, if the ending address is greater than the starting address, and then stored into address registers.  
![Imgur](https://i.imgur.com/W1MZefR.png)

### Converting ASCII to HEX
ASCII2HEX is a subrouting that takes a value and converts it to a valid HEX address.
![Imgur](https://i.imgur.com/KuqKIYR.png)

### Supported Opcodes
|**O**|**P**|**C**|**O**|**D**|**E**|**S**|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|MOVE|MOVEA|MOVEM|ADD|SUB|LEA|AND|  
|OR|LSL|ASR|CMP|Bcc(BCC, BGT, BLE)|JSR|RTS|

### Supported Effective Address (EA) Modes  
* Data Register Direct  
* Address Register Direct  
* Address Register Indirect  
* Immediate Data  
* Address Register Indirect with Post incrementing  
* Address Register Indirect with Pre decrementing  
* Absolute Long Address  
* Absolute Word Addres  

## Test Plan

## Exception Report

## Team Assignments and Report
### Scott
* I/O  
* ASCII to HEX conversion  
### Carl
* Opcode parsing  
* Opcode decoding  
### Daniel
-Testing  


# (3) Demonstration
## Video Demonstration  
**LINK**  

