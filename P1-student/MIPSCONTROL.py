import HWComponents
import stateFileManagement as sfm
import simStats
import InstructionControlDefs as ICD

class Control:
    byteSize = False # byteOperation on memory
    writeHILO = False # writes to HI and LO registers
    lbu = False # memory return value is unsigned byte
    # specifies control code for ALU={0:ADD,1:SUB,2:AND,3:OR,4:NOR,5:XOR,6:SLT,7:SLTU,8:SLL,9:SRL,10:SRA,11:LUI,12:MUL,13:DIV,14:MULU,15:DIVU
    ALUop = 0 
    isBranch = False # is any type of branch
    isJump = False # J, JAL = True -- gets PC from instruction
    isRegToPC = False # JR, JALR = True -- gets PC from reg
    isLink = False # JAL, JALR = True -- writes return address to $31 aka $ra
    branchSense = True # beq = True; bne = False
    memToReg = False # Does this instruction get its result from memory
    
    # holds decode functions, for convenience
    opDecFuncts={}
    f0DecFuncts={}
    f1DecFuncts={}
    # decorator strings
    opMnemonics={}
    regMnemonics={}
    
    def setInstDependentControl(self, fetchedInst):
        # extract instruction fields
        self.opCode = fetchedInst >> 26 & 0x3F
        self.funct = fetchedInst & 0x3F
        self.imm16z = fetchedInst & 0xFFFF
        self.imm16s = (fetchedInst & 0xFFFF) | 0xFFFF0000 if (fetchedInst >> 15 & 1) else fetchedInst & 0xFFFF
        self.imm16b = (fetchedInst & 0xFFFF) | 0xFFFF0000 if (fetchedInst >> 15 & 1) else fetchedInst & 0xFFFF
        self.imm16b = self.imm16b << 2 & 0xFFFFFFFF
        self.RS = fetchedInst >> 21 & 0x1F
        self.RT = fetchedInst >> 16 & 0x1F
        self.RD = fetchedInst >> 11 & 0x1F
        self.SHAMT = fetchedInst >> 6 & 0x1F
        self.jTypePC = (HWComponents.PC + 4 ) & 0xF0000000 | (fetchedInst << 2 & 0x0FFFFFFC)
        HWComponents.ALUPortA = HWComponents.REG[self.RS] # always pass through
        HWComponents.MemWritePort.value = HWComponents.REG[self.RT] # always pass through
        if self.printVerboseOutput:
            print("Presumptive RS read: {:#010x} from register {:#010x}".format(HWComponents.ALUPortA,self.RS))
        # for pretty-printing instructions as they are decoded - not required for simulator operation
        if self.printVerboseOutput:
            self.prettyPrintDecodedInst(fetchedInst)
        # decode based on opcode
        if self.opCode in self.opDecFuncts:
            decodeFunc=self.opDecFuncts[self.opCode]
        else:
            print("ILLEGAL INSTRUCTION: {:#010x} at PC: {:#010x}, opcode: {:#04x}".format(fetchedInst,HWComponents.PC,self.opCode))
            sfm.dump(simStats.stats)
        decodeFunc(fetchedInst) # set instruction-specific, data independent control fields
        
            
    def setDataDependentControl(self, fetchedInst):
        self.branchPCUpdate = (HWComponents.PC + 4 + self.imm16b) & 0xFFFFFFFF # currently should be in ALU        
        self.JRPC = HWComponents.REG[self.RS] #fixme - does not scale

        defaultPCUpdate = HWComponents.PC + 4

        # update control information based on control outcome
        if self.isBranch and ( not (HWComponents.DATAPATH.outEQ ^ self.branchSense )):
            HWComponents.nextPC = self.branchPCUpdate
        elif self.isJump:
            HWComponents.nextPC = self.jTypePC
        elif self.isRegToPC:
            HWComponents.nextPC = self.JRPC
        else:
            HWComponents.nextPC = defaultPCUpdate
    
    def decSpecialZero(self, instruction):
        # decode based on funct field
        if self.funct in self.f0DecFuncts:
            decodeFunc=self.f0DecFuncts[self.funct]
        else:
            print("ILLEGAL INSTRUCTION: {:#010x} at PC: {:#010x}, opcode: {:#04x}".format(fetchedInst,HWComponents.PC,self.opCode))
            sfm.dump(simStats.stats)
        decodeFunc(instruction) # set instruction-specific, data independent control fields

    def decSpecialOne(self, instruction):
        print("Decoding {:#010x} -- not supported!".format(instruction))
        sfm.dump(simStats.stats)
    
    
    def __init__(self):
        self.opDecFuncts[0]=self.decSpecialZero
        self.opDecFuncts[1]=self.decSpecialOne
        self.opDecFuncts[2]=ICD.decJ
        self.opDecFuncts[3]=ICD.decJAL
        self.opDecFuncts[4]=ICD.decBEQ
        self.opDecFuncts[5]=ICD.decBNE
        self.opDecFuncts[6]=ICD.decBLEZ
        self.opDecFuncts[7]=ICD.decBGTZ
        self.opDecFuncts[8]=ICD.decADDI
        self.opDecFuncts[9]=ICD.decADDIU
        self.opDecFuncts[10]=ICD.decSLTI
        self.opDecFuncts[11]=ICD.decSLTIU
        self.opDecFuncts[12]=ICD.decANDI
        self.opDecFuncts[13]=ICD.decORI
        self.opDecFuncts[14]=ICD.decXORI
        self.opDecFuncts[15]=ICD.decLUI
        self.opDecFuncts[32]=ICD.decLB
        self.opDecFuncts[35]=ICD.decLW
        self.opDecFuncts[36]=ICD.decLBU
        self.opDecFuncts[40]=ICD.decSB
        self.opDecFuncts[43]=ICD.decSW
        #OPCODE=0 functs
        self.f0DecFuncts[0]=ICD.decSLL
        self.f0DecFuncts[2]=ICD.decSRL
        self.f0DecFuncts[3]=ICD.decSRA
        self.f0DecFuncts[8]=ICD.decJR
        self.f0DecFuncts[9]=ICD.decJALR
        self.f0DecFuncts[12]=ICD.decSYSCALL
        self.f0DecFuncts[16]=ICD.decMFHI
        self.f0DecFuncts[18]=ICD.decMFLO
        self.f0DecFuncts[24]=ICD.decMULT
        self.f0DecFuncts[25]=ICD.decMULTU
        self.f0DecFuncts[26]=ICD.decDIV
        self.f0DecFuncts[27]=ICD.decDIVU
        self.f0DecFuncts[32]=ICD.decADD
        self.f0DecFuncts[33]=ICD.decADDU
        self.f0DecFuncts[34]=ICD.decSUB
        self.f0DecFuncts[35]=ICD.decSUBU
        self.f0DecFuncts[36]=ICD.decAND
        self.f0DecFuncts[37]=ICD.decOR
        self.f0DecFuncts[38]=ICD.decXOR
        self.f0DecFuncts[39]=ICD.decNOR
        self.f0DecFuncts[42]=ICD.decSLT
        self.f0DecFuncts[43]=ICD.decSLTU
        #Mnemonics
        self.regMnemonics[0]="$zero"
        self.regMnemonics[1]="$at"
        self.regMnemonics[2]="$v0"
        self.regMnemonics[3]="$v1"
        self.regMnemonics[4]="$a0"
        self.regMnemonics[5]="$a1"
        self.regMnemonics[6]="$a2"
        self.regMnemonics[7]="$a3"
        self.regMnemonics[8]="$t0"
        self.regMnemonics[9]="$t1"
        self.regMnemonics[10]="$t2"
        self.regMnemonics[11]="$t3"
        self.regMnemonics[12]="$t4"
        self.regMnemonics[13]="$t5"
        self.regMnemonics[14]="$t6"
        self.regMnemonics[15]="$t7"
        self.regMnemonics[16]="$s0"
        self.regMnemonics[17]="$s1"
        self.regMnemonics[18]="$s2"
        self.regMnemonics[19]="$s3"
        self.regMnemonics[20]="$s4"
        self.regMnemonics[21]="$s5"
        self.regMnemonics[22]="$s6"
        self.regMnemonics[23]="$s7"
        self.regMnemonics[24]="$t8"
        self.regMnemonics[25]="$t9"
        self.regMnemonics[26]="$k0"
        self.regMnemonics[27]="$k1"
        self.regMnemonics[28]="$gp"
        self.regMnemonics[29]="$sp"
        self.regMnemonics[30]="$fp"
        self.regMnemonics[31]="$ra"
        #opMnemonics
        self.opMnemonics[0]={}
        self.opMnemonics[1]={}
        self.opMnemonics[2]=("J  ", 0)
        self.opMnemonics[3]=("JAL", 0)
        self.opMnemonics[4]=("BEQ", 9)
        self.opMnemonics[5]=("BNE", 9)
        self.opMnemonics[6]=("BLEZ", 10)
        self.opMnemonics[7]=("BGTZ", 10)
        self.opMnemonics[8]=("ADDI", 1)
        self.opMnemonics[9]=("ADDIU", 1)
        self.opMnemonics[10]=("SLTI", 1)
        self.opMnemonics[11]=("SLTIU", 1)
        self.opMnemonics[12]=("ANDI", 1)
        self.opMnemonics[13]=("ORI", 1)
        self.opMnemonics[14]=("XORI", 1)
        self.opMnemonics[15]=("LUI", 2)
        self.opMnemonics[32]=("LB ", 3)
        self.opMnemonics[35]=("LW ", 3)
        self.opMnemonics[36]=("LBU", 3)
        self.opMnemonics[40]=("SB ", 3)
        self.opMnemonics[43]=("SW ", 3)
        #OPCODE=0 functs
        (self.opMnemonics[0])[0]=("SLL", 4)
        (self.opMnemonics[0])[2]=("SRL", 4)
        (self.opMnemonics[0])[3]=("SRA", 4)
        (self.opMnemonics[0])[8]=("JR ", 5)
        (self.opMnemonics[0])[9]=("JALR", 5)
        (self.opMnemonics[0])[12]=("SYSCALL", 6)
        (self.opMnemonics[0])[16]=("MFHI", 11)
        (self.opMnemonics[0])[18]=("MFLO", 11)
        (self.opMnemonics[0])[24]=("MULT", 7)
        (self.opMnemonics[0])[25]=("MULTU", 7)
        (self.opMnemonics[0])[26]=("DIV", 7)
        (self.opMnemonics[0])[27]=("DIVU", 7)
        (self.opMnemonics[0])[32]=("ADD", 8)
        (self.opMnemonics[0])[33]=("ADDU", 8)
        (self.opMnemonics[0])[34]=("SUB", 8)
        (self.opMnemonics[0])[35]=("SUBU", 8)
        (self.opMnemonics[0])[36]=("AND", 8)
        (self.opMnemonics[0])[37]=("OR ", 8)
        (self.opMnemonics[0])[38]=("XOR", 8)
        (self.opMnemonics[0])[39]=("NOR", 8)
        (self.opMnemonics[0])[42]=("SLT", 8)
        (self.opMnemonics[0])[43]=("SLTU", 8)

    def prettyPrintDecodedInst(self, fetchedInst):
        if self.opCode ==0:
            opStr = self.opMnemonics[0][self.funct][0]
            opFormat =self.opMnemonics[0][self.funct][1]
        else:
            opStr = self.opMnemonics[self.opCode][0]
            opFormat =self.opMnemonics[self.opCode][1]
        if 0 == opFormat: # J, JALR
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:#010x}".format(HWComponents.PC, fetchedInst, opStr, self.jTypePC))
        elif 1 == opFormat: # ANDI, ORI, etc
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:s},\t\t{:s}\t\t{:#010x}".format(HWComponents.PC, fetchedInst,opStr, self.regMnemonics[self.RT], self.regMnemonics[self.RS], self.imm16z))
        elif 2 == opFormat: #LUI
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:s},\t\t{:#010x}".format(HWComponents.PC, fetchedInst, opStr, self.regMnemonics[self.RT], self.imm16z))
        elif 3 == opFormat: # Base Offset
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:s},\t\t{:#010x}\t({:s})".format(HWComponents.PC, fetchedInst,opStr, self.regMnemonics[self.RT], self.imm16z, self.regMnemonics[self.RS]))
        elif 4 == opFormat: # SHAMT
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:s},\t\t{:s},\t\t{:#04x}".format(HWComponents.PC, fetchedInst, opStr, self.regMnemonics[self.RD], self.regMnemonics[self.RT],self.SHAMT))
        elif 5 == opFormat: #JR, JALR
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:s}".format(HWComponents.PC, fetchedInst,opStr, self.regMnemonics[self.RS]))
        elif 6 == opFormat: #SYSCALL
            print("Decoding {:#010x}| {:#010x}: {:s}".format(HWComponents.PC, fetchedInst,opStr))
        elif 7 == opFormat: # MULT, MULTU, DIV, DIVU
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:s},\t\t{:s}".format(HWComponents.PC, fetchedInst,opStr, self.regMnemonics[self.RS],self.regMnemonics[self.RT]))
        elif 8 == opFormat: # ADD, etc.
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:s},\t\t{:s},\t\t{:s}".format(HWComponents.PC, fetchedInst,opStr, self.regMnemonics[self.RD], self.regMnemonics[self.RS],self.regMnemonics[self.RT]))
        elif 9 == opFormat: #BEQ, BNE
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:s},\t\t{:s},\t\t{:#010x}".format(HWComponents.PC, fetchedInst, opStr, self.regMnemonics[self.RS], self.regMnemonics[self.RT], (HWComponents.PC + 4 + self.imm16b) & 0xFFFFFFFF))
        elif 10 == opFormat: #BLEZ, BGTZ
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:s},\t\t{:#010x}".format(HWComponents.PC, fetchedInst, opStr, self.regMnemonics[self.RS], (HWComponents.PC + 4 + self.imm16b) & 0xFFFFFFFF))
        elif 11 == opFormat: #MFHI, MFLO
            print("Decoding {:#010x}| {:#010x}: {:s}\t\t{:s}".format(HWComponents.PC, fetchedInst, opStr, self.regMnemonics[self.RS]))
        else:
            print("Decoding {:#010x}: {:s}??UNKNOWN PRETTYPRINT??{:d}".format(fetchedInst,opStr, opFormat))
