Makefile: GNU Make Makefile that contains test and cleaning targets
-------------------------------------------------------------------------------
A makefile has been provided with the following targets:

1: test
2: clean

The default target is test.

'make test' will run PPSSM on the input image ex1 with execution
duration boundaries of <=75 instructions and <=150 cycles. The ex1
input requires 72 instructions and 100 cycles, so it will run to
completion within these bounds.

'make clean' will remove the __pycache__ directory and its contents,
if present. While not generally necessary, it will avoid any timestamp
mismatches between edits to your python files and the PYC bytecode
caches.
===============================================================================

PPSSM.py: Top level python file. Manages simulation execution for an
(almost) single-cycle processor.
-------------------------------------------------------------------------------
You will not submit this file, so any modifications will be
discarded. However, it may be useful for you to A) set the debugging
flags present in this file (*printVerboseOutput) to True and B)
examine the top level cycle emulation loop.
===============================================================================

InstructionControlDefs.py: Contains functions that set control signals
for each instruction
-------------------------------------------------------------------------------
***YOU WILL MODIFY AND SUBMIT THIS FILE AND ONLY THIS FILE***

This file contains the definitions of the functions responsible for
setting the control signals/mux outputs specific to each
instruction. A subset of the instructions have been implemented. Your
task will be to replace all instances of 'pass #YOUR CODE HERE' with
the correct logic for the specified instruction.

For ease of debugging, combinational wires are reset to an invalid
value (a warning string) after each cycle, so if you forget to set
something, it will likely crash your program rather than be silently
incorrect. A validation function with associated assertions has been
added on your behalf to cause your program to crash with a more
meaningful error message.
===============================================================================

HWComponents.py: Defines available HW resources. Some MUXs collapsed
to reduce verbosity
===============================================================================

EmulatedSYSCALLs.py: Provides minimal syscall emulation
===============================================================================

MIPSDATAPATH.py: Implements ALU and DataMemory lookup operations
===============================================================================

MIPSCONTROL.py: Performs decode and invokes your code in InstructionControlDefs
===============================================================================

MIPSMEM.py: MIPS memory and memory interface modeling
===============================================================================

stateFileManagement.py: Reads input file formats and writes output snapshot
===============================================================================

simStats.py: Tracks various execution statistics
===============================================================================
