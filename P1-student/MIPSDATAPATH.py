import HWComponents
import simStats

class DataPath:
    outALU = 0
    outMEM = 0
    outEQ = False
    outGTZ = False
    printVerboseOutput = False
    
    def genALUOutputs(self, inA, inB):
        inASigned= -((~inA +1)&0xFFFFFFFF) if (inA & 0x80000000) else inA # signed interpretations - makes writing in python easier
        inBSigned= -((~inB +1)&0xFFFFFFFF) if (inB & 0x80000000) else inB 
        # direct outputs
        self.outEQ = inA == inB
        self.outGTZ = inASigned > 0
        # compute all of the following and then multiplex which one is outALU
        outADD = (inA + inB) & 0xFFFFFFFF
        outSUB = (inA - inB) & 0xFFFFFFFF
        outAND = inA & inB
        outOR = inA | inB
        outNOR = (~(inA | inB)) & 0xFFFFFFFF
        outXOR = inA ^ inB
        outSLT = inASigned < inBSigned
        outSLTU = inA < inB
        outSLL = (inB << HWComponents.CONTROL.SHAMT ) & 0xFFFFFFFF
        outSRL = (inB >> HWComponents.CONTROL.SHAMT ) & 0xFFFFFFFF
        outSRAupper = (0xFFFFFFFF << (32 - HWComponents.CONTROL.SHAMT)) & 0xFFFFFFFF
        if 0 == inB & 0x80000000:
            outSRAupper = 0
        outSRA =  ( outSRAupper | (inB >> HWComponents.CONTROL.SHAMT)) & 0xFFFFFFFF
        outLUI = (inB << 16) & 0xFFFF0000
        outDivHI = 0 if inB == 0 else (int(inA // inB) &  0xFFFFFFFF ) # fixme for timing - multicycle
        outDivLO = 0 if inB == 0 else ( (inA % inB ) & 0xFFFFFFFF )   # fixme for timing- multicycle
        outMulHI = ( inA * inB ) & 0xFFFFFFFF00000000 # potentially multicycle
        outMulLO = ( inA * inB ) & 0xFFFFFFFF # potentially multicycle
        outDivSignedHI = 0 if inBSigned == 0 else (int(inASigned // inBSigned) &  0xFFFFFFFF ) # fixme for timing - multicycle
        outDivSignedLO = 0 if inBSigned == 0 else ( (inASigned % inBSigned ) & 0xFFFFFFFF )   # fixme for timing- multicycle
        outMulSignedHI = ( inASigned * inBSigned ) & 0xFFFFFFFF00000000 # potentially multicycle
        outMulSignedLO = ( inASigned * inBSigned ) & 0xFFFFFFFF # potentially multicycle
        #MUX of computed values
        if HWComponents.CONTROL.ALUop == 0:
            self.outALU = outADD
        elif HWComponents.CONTROL.ALUop == 1:
            self.outALU = outSUB
        elif HWComponents.CONTROL.ALUop == 2:
            self.outALU = outAND
        elif HWComponents.CONTROL.ALUop == 3:
            self.outALU = outOR
        elif HWComponents.CONTROL.ALUop == 4:
            self.outALU = outNOR
        elif HWComponents.CONTROL.ALUop == 5:
            self.outALU = outXOR
        elif HWComponents.CONTROL.ALUop == 6:
            self.outALU = outSLT
        elif HWComponents.CONTROL.ALUop == 7:
            self.outALU = outSLTU
        elif HWComponents.CONTROL.ALUop == 8:
            self.outALU = outSLL
        elif HWComponents.CONTROL.ALUop == 9:
            self.outALU = outSRL
        elif HWComponents.CONTROL.ALUop == 10:
            self.outALU = outSRA
        elif HWComponents.CONTROL.ALUop == 11:
            self.outALU = outLUI
        elif HWComponents.CONTROL.ALUop == 12:
            self.outALU = 0
            HWComponents.nextHI=outMulHI
            HWComponents.nextLO=outMulLO
        elif HWComponents.CONTROL.ALUop == 13:
            self.outALU = 0
            HWComponents.nextHI=outDivHI
            HWComponents.nextLO=outDivLO
        elif HWComponents.CONTROL.ALUop == 14:
            self.outALU = 0
            HWComponents.nextHI=outMulSignedHI
            HWComponents.nextLO=outMulSignedLO
        elif HWComponents.CONTROL.ALUop == 15:
            self.outALU = 0
            HWComponents.nextHI=outDivSignedHI
            HWComponents.nextLO=outDivSignedLO
        else:
            print("ERRONEOUS ALU OPERATION SPECIFICATION!")
            simStats.stats.dump()
        if self.printVerboseOutput:
            print("ALU (op={:d}) computed {:#010x} from {:#010x} op {:#010x}".format(HWComponents.CONTROL.ALUop, self.outALU, inA, inB))
        HWComponents.MemWritePort.address=self.outALU
            
    def doConditionalDMEMRead(self):
        # Data Memory Read, conditional on being a LW/LB/LBU
        if HWComponents.CONTROL.memToReg:
            if HWComponents.CONTROL.byteSize and HWComponents.CONTROL.lbu:
                memRet = HWComponents.DMEM.loadByteUnsigned(self.outALU)
            elif HWComponents.CONTROL.byteSize and not HWComponents.CONTROL.lbu:
                memRet = HWComponents.DMEM.loadByte(self.outALU)
            else:
                memRet = HWComponents.DMEM.loadWord(self.outALU)
            if memRet.success:
                self.outMEM = memRet.value
            else:
                if not HWComponents.globalStall:
                    simStats.stats.DMEMstalls = simStats.stats.DMEMstalls + 1 # don't double count on other stalls
                HWComponents.globalStall = True
                HWComponents.DMEMStall = True
                simStats.stats.fetched = simStats.stats.fetched -1 # don't double count the refetch of this instruction
                simStats.stats.loads = simStats.stats.loads -1 # don't double count the refetch of this instruction
                if self.printVerboseOutput:
                    print("Read MEM[{:#010x}] Stalled in cycle {:d}".format(self.outALU, simStats.stats.cycle))
                self.outMEM = 0
            if self.printVerboseOutput:
                print("Read MEM[{:#010x}] = {:#010x}".format(self.outALU, self.outMEM))
