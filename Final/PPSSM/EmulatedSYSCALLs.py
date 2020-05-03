import HWComponents
import stateFileManagement as sfm
import simStats

global printVerboseOutput
printVerboseOutput = False # default to quiet

def SYSCALL_Emulation():
    simStats.stats.sysCalls = simStats.stats.sysCalls + 1 # count as control
    HWComponents.CONTROL.byteSize = False # byteOperation on memory
    HWComponents.CONTROL.writeHILO = False # writes to HI and LO registers
    HWComponents.CONTROL.lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    HWComponents.CONTROL.ALUop = 0 # ADD - pick anything 
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

    # dispatch based on $v0
    callCode=HWComponents.REG[2]
    if printVerboseOutput:
        print("Emulating SYSCALL functionality for SYSCALL code {:d}\n".format(callCode))
    if 1 == callCode: # print integer service
        ival = HWComponents.REG[4] # get $a0
        #convert to signed from unsigned
        if ival & 0x80000000:
            ival = -((~ival +1) & 0xFFFFFFFF)
        print("{:d}".format(ival),end='')
    elif 4 == callCode: # print string service
        strAddr = HWComponents.REG[4] # get $a0
        success = False
        curChar = '1'
        while not curChar == 0:
            while False == success:
                MRval = HWComponents.DMEM.loadByteUnsigned(strAddr)
                curChar = MRval.value
                success = MRval.success
            if not curChar ==0:
                print("{:c}".format(curChar),end='')
            success = False
            strAddr = strAddr + 1
    elif 10 == callCode:
        print("Emulating EXIT syscall, terminating simulation")
        simStats.stats.cycle = simStats.stats.cycle + 1 # treat this inst/cycle as completed before we exit
        simStats.stats.completed = simStats.stats.completed + 1
        sfm.dump(simStats.stats)
    elif 34 == callCode: # print hex service
        ival = HWComponents.REG[4] # get $a0
        print("{:#010x}".format(ival),end='')

    else:
        print("UNIMPLIMENTED SYSCALL! TERMINATING SIMULATION")
        sfm.dump(simStats.stats)
