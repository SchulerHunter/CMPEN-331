.data 
divisor: .word 7 # Keep this as 7 when you turn it in; you are, however, encouraged to experiment with other values during testing to make sure your code works
###########################
dividend: .word 910350550 # REPLACE THIS WITH YOUR 9-DIGIT PSU ID
###########################
spacestring: .asciiz " "
endl: .asciiz "\n"

.text
########################
# Execution begins here
la $s0, dividend # get address of dividend
lw $s0, 0($s0) # load dividend - keep in s0 to preserve across print calls
la $s1, divisor # get address of divisor
lw $s1, 0($s1) # load divisor - keep in s1 to preserve across print calls
divu $s0, $s1 # do integer division 
mfhi $a1 # remainder
mflo $a0 # quotient
jal printDivuResults # print the results to console so that you know what your code is intended to produce
addu $a0, $0, $s0 # restore dividend in $a0 after function call
addu $a1, $0, $s1 # restore divisor in %a1 after function call
###
jal softwareEmulatedDIVU # YOUR CODE INVOKED HERE
### 
addu $a0, $0, $v0 # quotient in $a0
addu $a1, $0, $v1 # remainder in $a1
jal printDivuResults # print results of your software emulation of DIVU
addi $v0, $0, 10 # code for exit syscall 
syscall # EXIT
# Execution ends here
########################

###
# Prints quotient and remainder to MARS console
###
printDivuResults: # Expects quotient in $a0, remainder in $a1
addi $v0, $0, 1 # printInt
syscall # print quotient
la $a0, spacestring
addi $v0, $0, 4 # printStr
syscall # print space
addi $v0, $0, 1 # printInt
add $a0, $0, $a1
syscall # print remainder
la $a0, endl
addi $v0, $0, 4 # printStr
syscall # print space
jr $ra

###
# Emulation of DIVU in software without the use of dedicated division hardware
###
softwareEmulatedDIVU: # Expects dividend in $a0, divisor in $a1 - produces quotient in $v0, remainder in $v1
beq $a1, $0, sedEXIT # if divide by zero, immediately return (garbage) contents of $v0, $v1 else...
####################################################
# 0. A) You cannot use the DIV/DIVU instruction, FP instructions, or the HI|LO register pair
#    B) You cannot change any assembly outside of i) this code region, ii) replacing the dividend with your 9-digit PSU ID, iii) during testing, replacing the divsor with other values 
#    C) This is an individual assignment
#    D) You must provide a comment for every line of your assembly code
# 1. Your solution must work for all (divisor, dividend) pairs where the divisor is not zero. Your output must match the DIVU output. 
#    Fortunately, A) grammar-school long division satisfies this property
#    Furthermore, B) the slides provide a flow-chart at an appropriate, bitwise, level
#    However, the slides use a 64bit shift-register, so you'll have to figure out how to achieve the same effect with 32-bit MIPS registers
# 2. Total dynamic instruction count must be upper-bounded by a constant, i.e. cannot grow as a function of dividend/divisor value
#    To be clear: dynamic instruction count may vary, as a function of input, but must be worst-case bounded proportional to the number 
#    of bits of output generated, not input values
#    If the instruction count tool says that you're executing more than 1000 dynamic instructions, you're probably not on the right track
# 3. A sufficient solution can be achieved in less than 16-20 static instructions - if you're using more than 25 instructions, 
#    your're probably making it MUCH more complex than it needs to be
####################################################
# subtract until less than or equal to zero, if zero, return n, else return n - 1
# t0 = dividend t1 = divisor t2 = remainder t3 = quotient t4 = counter
addi $t0, $a0, 0 # store dividend in t0
addi $t1, $a1, 0 # store divisor in t1
andi $t2, $t2, 0 # set remainder to 0
andi $t3, $t3, 0 # set quotient to 0
andi $t4, $t4, 0 # set counter to 0
andi $v0, 0 # Reset v0 because somehow 4 gets added before entering the loop

loop:
addi $t4, $t4, 1 # Add 1 to counter
sub $t2, $t2, $t1 # Subtract divisor from remainder
bgez $t2, calcRemainPos # If >= 0, run calcRemainPos algo
# Else < 0, run calcRemainNeg algo

calcRemainNeg:
add $t2, $t2, $t1 # Add divisor back to remainder to restore original value
sll $t3, $t3, 1 # Shift quotient register left
srl $t1, $t1, 1 # Shift divisor right 1 bit
bne $t4, 33, loop # Jump to loop if counter != 33
j sedEXIT # Else exit

calcRemainPos:
sll $t3, $t3, 1 # Shift quotient register left
addi $t3, $t3, 1 # Set the rightmost bit to 1
srl $t1, $t1, 1 # Shift divisor right 1 bit
bne $t4, 33, loop # Jump to loop if counter != 33
# Else exit

sedEXIT: # softwareEmulatedDIVU exit
# v0 = quotient v1 = remainder
addi $v0, $t3, 0 # Move result to v0
addi $v1, $t2, 0 # Move remainder to v1
jr $ra
