import HWComponents
import simStats
import EmulatedSYSCALLs as esc


#top level opcodes
def decJ(instruction):
    simStats.stats.controlOps = simStats.stats.controlOps + 1 # count as control op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 3 # OR - don't care, but have to pick something
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = True # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = False # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16z # don't care, but have to pick something
    HWComponents.MemWritePort.writeEnable = False
    
def decJAL(instruction):
    simStats.stats.controlOps = simStats.stats.controlOps + 1 # count as control op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 3 # OR - don't care, but have to pick something
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = True # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = True # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = 31 # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16z # don't care, but have to pick something
    HWComponents.MemWritePort.writeEnable = False
    
def decBEQ(instruction):
    simStats.stats.controlOps = simStats.stats.controlOps + 1 # count as control op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 1 # SUB - don't care if we have a separate branch adder, but have to pick something
    HWComponents.CONTROL.isBranch = True # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = False # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT] # need this for outEQ
    HWComponents.MemWritePort.writeEnable = False

def decBNE(instruction):
    simStats.stats.controlOps = simStats.stats.controlOps + 1 # count as control op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 1 # SUB - don't care if we have a separate branch adder, but have to pick something
    HWComponents.CONTROL.isBranch = True # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = False # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = False # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT] # Need this for outEQ
    HWComponents.MemWritePort.writeEnable = False

def decBLEZ(instruction):
    pass

def decBGTZ(instruction):
    pass

def decADDI(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 0 # ADD
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16s
    HWComponents.MemWritePort.writeEnable = False
    
def decADDIU(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 0 # ADD
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16s
    HWComponents.MemWritePort.writeEnable = False
    
def decSLTI(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 6 # SLT
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16s
    HWComponents.MemWritePort.writeEnable = False
    
def decSLTIU(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 7 # SLTU
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16s
    HWComponents.MemWritePort.writeEnable = False
    
def decANDI(instruction):
    simStats.stats.BoolOps = simStats.stats.BoolOps + 1 # count as Bool
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 2 # AND
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16z
    HWComponents.MemWritePort.writeEnable = False

def decORI(instruction):
    simStats.stats.BoolOps = simStats.stats.BoolOps + 1 # count as Bool
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 3 # OR
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16z
    HWComponents.MemWritePort.writeEnable = False
    
def decXORI(instruction):
    simStats.stats.BoolOps = simStats.stats.BoolOps + 1 # count as Bool
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 5 # XOR
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16z
    HWComponents.MemWritePort.writeEnable = False

def decLUI(instruction):
    simStats.stats.BoolOps = simStats.stats.BoolOps + 1 # count as Bool
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 11 # LUI
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16z
    
def decLB(instruction):
    simStats.stats.loads = simStats.stats.loads + 1 # count as Load op
    HWComponents.CONTROL.byteSize = True # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 0 # ADD
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = True # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16s
    HWComponents.MemWritePort.writeEnable = False
    
def decLW(instruction):
    simStats.stats.loads = simStats.stats.loads + 1 # count as Load op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 0 # ADD
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = True # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16s
    HWComponents.MemWritePort.writeEnable = False

def decLBU(instruction):
    simStats.stats.loads = simStats.stats.loads + 1 # count as Load op
    HWComponents.CONTROL.byteSize = True # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = True # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 0 # ADD
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = True # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RT # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16s
    HWComponents.MemWritePort.writeEnable = False
    
def decSB(instruction):
    simStats.stats.stores = simStats.stats.stores + 1 # count as store
    HWComponents.CONTROL.byteSize = True # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 0 # ADD
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = False # Does this instruction write to a register?
    HWComponents.REGWritePort.address = 0 # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16s
    HWComponents.MemWritePort.writeEnable = True

def decSW(instruction):
    simStats.stats.stores = simStats.stats.stores + 1 # count as store
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 0 # ADD
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = False # Does this instruction write to a register?
    HWComponents.REGWritePort.address = 0 # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.CONTROL.imm16s
    HWComponents.MemWritePort.writeEnable = True
    
#specialZero functions
def decSLL(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 8 # SLL
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False
    
def decSRL(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 9 # SRL
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False
    
def decSRA(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 10 # SRA
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False

def decJR(instruction):
    simStats.stats.controlOps = simStats.stats.controlOps + 1 # count as control
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 3 # Doesn't Matter, but have to pick one
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = True # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = False # Does this instruction write to a register?
    HWComponents.REGWritePort.address = 0 # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False
    
def decJALR(instruction):
    simStats.stats.controlOps = simStats.stats.controlOps + 1 # count as control
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 3 # Doesn't Matter, but have to pick one
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = True # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = True # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = 31 # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False

def decSYSCALL(instruction):
    esc.SYSCALL_Emulation()
        
def decMFHI(instruction):
    pass
    
def decMFLO(instruction):
    simStats.stats.controlOps = simStats.stats.ALUOps + 1 # count as control
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 3 # OR
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.LO
    HWComponents.MemWritePort.writeEnable = False
    
def decMULT(instruction):
    pass

def decMULTU(instruction):
    simStats.stats.controlOps = simStats.stats.ALUOps + 1 # count as control
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = True # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 14 # MULU
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = False # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False

def decDIV(instruction):
    pass

def decDIVU(instruction):
    pass

def decADD(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 0 # ADD
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False
    
def decADDU(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 0 # ADD
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False

def decSUB(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 1 # SUB
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False
    
def decSUBU(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 1 # SUB
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False
    
def decAND(instruction):
    simStats.stats.BoolOps = simStats.stats.BoolOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 2 # AND
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False

def decOR(instruction):
    simStats.stats.BoolOps = simStats.stats.BoolOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 3 # OR
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False

def decXOR(instruction):
    simStats.stats.BoolOps = simStats.stats.BoolOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 5 # XOR
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False

def decNOR(instruction):
    simStats.stats.BoolOps = simStats.stats.BoolOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 4 # NOR
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False

def decSLT(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 6 # SLT
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False
    
def decSLTU(instruction):
    simStats.stats.ALUOps = simStats.stats.ALUOps + 1 # count as ALU op
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 7 # SLTU
    HWComponents.CONTROL.isBranch = False # is any type of branch
    HWComponents.CONTROL.isJump = False # J, JAL = True -- gets PC from instruction
    HWComponents.CONTROL.isRegToPC = False # JR, JALR = True -- gets PC from reg
    HWComponents.CONTROL.isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    HWComponents.CONTROL.branchSense = True # beq = True; bne = False
    HWComponents.CONTROL.memToReg = False # Does this instruction get its result from memory
    HWComponents.REGWritePort.writeEnable = True # Does this instruction write to a register?
    HWComponents.REGWritePort.address = HWComponents.CONTROL.RD # RD, RT, RA
    HWComponents.ALUPortB = HWComponents.REG[HWComponents.CONTROL.RT]
    HWComponents.MemWritePort.writeEnable = False
