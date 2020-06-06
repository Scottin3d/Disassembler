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
### A disassembler (also called an inverse assembler) should do the following:    
* Scan a section of memory and attempt to convert the memory’s contents to a listing of valid assembly language instructions  
* Most disassemblers cannot recreate symbolic, or label information  
* Disassemblers can be easily fooled by not starting on an instruction boundary 
 
### How it works:  
* Program parses the op-code word of the instruction and then decides how many additional words of memory need to be read in order to complete the instruction  
* If necessary, reads additional instruction words  
* Prints out the complete instruction in ASCII-readable format  
* Converts binary information to readable Hex

## Specifications
### Program Design
Project Diagram: https://drive.google.com/open?id=1ZPQ33-BFiRYbSNXN15DFX_wUENFzlZGl 

### Main Program
This chart outlines the main flow of the disassembler from start to finish.  Please see the project diagram for a more detailed look at the logic of the individual subroutines.   

![Imgur](https://i.imgur.com/UyS0BTz.png)

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
There were 5 phases in our testing plan. We tested the system as we built it up. This was done because newer code relied on a framework to correctly work. Once the framework was tested and debugged. Opcode disassembly code was written and then tested.

1. I/O debugging, making sure that it correctly converted to ASCCI.
2. EA decoding, being able to correcly output the mode and register used. tested with MOVE.B command. 
3. Local Opcode testing, once each member wrote the disassembly for the specific opcodes they wrote, testing was done for that specific opcode to make sure that it worked correctly.
4. Whole System, testing was done on the complete system. All of the local opcode tests were brought together and used in a single test file.
5. Decoding disassembler, The starting address of the disassembler was used to test that it properly output the correct disassembled instruction aswell as had the correct output for commands that were not meant to dissassemble. 

How testing was conducted:
For each opcode, we created a test file that we would load the data into our main program before execution.  
We track bad instruction outputs at the top of the file and idicate the bad instruction in-line.  We also note the start and stop of the file in memory for easy use when testing.  
Each test file tests all required cases for the opcode, separated in groups or registers/address and absolute/immediate data.  

### Coding Standards
When writing code, subroutines should be left justified, followed by the instruction at three tabs.  Comments should be made at nine tabs.  
Each line does not require a comment, however an asterisk should be placed at nine tabs.  

### Register Usage
For continuity, we utilized registers as followed:

|**Register**|**Usage**|
|:-:|:-|
|D0|copy of mask|
|D1|utility register|
|D2|copy of working address|
|D3|utility register|
|D4|local counter|
|D5|flag condition|
|D6|master counter|
|D7|working address|
|**Address**|**Usage**|
|A0|temp address holder|
|A1|trap address|
|A2|buffer address of decoded instruction|
|A3||
|A4|starting address|
|A5|ending address|
|A6|jump tables|
|A7|stack|

### Subroutine Standards
When writing subroutings, clearity is important.  Coders shoudl be able to tell what the subroutines task is by reading the code as well have imformative comments.  

1. A solid line of 70 asterisks indicates the start of a subroutine  
2. The name of the subroutine should be clear and unambigous   
3. A brief description of what the subroutine accomplishes
4. The registers utilized in the subroutine, adhering to the usage chart above  
5. A solid line of 70 asterisks indicates the end of the header
6. Sub-operations should be indicated with a solid line of 70 asterisks, the the name two (\*\*) from the left  
7. a solid line of 70 equals indicates the end of a subroutine  

```
1. **********************************************************************
2. *NAME
3. *Description:
4. *Registers Used:
5. **********************************************************************
6. **NAME of operation***************************************************
7. *==============80 Solid equals indicates the end of a subrouting======
```

### Eample:  

![Imgur](https://i.imgur.com/c2JiDAH.png) 

### Jump Tables
While used seldomly, formatting is important in the use of jump tables.  When writing a jump table, the following formatting guidelines should be followed along with the general coding and subroutine guidelines already eastablished.  

1. Name and description of the jump table
2. The name of the table should be clear and unambigous and include "table" at the end
3. The jump routines have a comment idicating what the action is

```
1.*0100 SECOND LAYER OPCODE TABLE SUBROUTINES 
2.op0100table
3.          JMP     op0100_0000   *BADINST          
            JMP     op0100_0001   *BADINST           
            JMP     op0100_0010   *CLR
            JMP     op0100_0011   *BADINST
```
### Example:

![Imgur](https://i.imgur.com/ERwwPNW.png)

### SUB/A Opcode Test File  

![Imgur](https://i.imgur.com/sVak8Vn.png)  

Because of how we divided individual contributions to the project, each opcode routine was written separately from the main program.  This allowed us to work on multiple subroutines at a time without conflict in the main program.  
When we integrated each opcode subroutine into the main program, we wrote a test case for the opcode and tested it extensively to ensure it was integrated properly and functioned as written.  


## Exception Report

## Team Assignments and Report
### Scott
* I/O  
* ASCII to HEX conversion  
### Carl
* Opcode parsing  
* Opcode decoding  
### Daniel
* Testing
* Opcode decoding


# (3) Demonstration
## Video Demonstration  
**LINK**  

