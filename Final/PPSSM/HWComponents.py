import MIPSMEM
import MIPSCONTROL
import MIPSDATAPATH

class wPort():
    address = 0
    value = 0
    writeEnable = False

class rPort():
    address = 0
    value = 0
    
def initHW():
    global MainMemory
    MainMemory = MIPSMEM.MainMem()
    global IMEM
    IMEM = MIPSMEM.MemoryInterface(MainMemory, False, False, "IMEM")
    global DMEM
    DMEM = MIPSMEM.MemoryInterface(MainMemory, True, True, "DMEM")
    global CONTROL
    CONTROL = MIPSCONTROL.Control()
    global DATAPATH
    DATAPATH = MIPSDATAPATH.DataPath()
    global PC
    global nextPC
    PC = 0x00000000
    nextPC = 0x00000000
    global HI
    HI = 0x00000000
    global nextHI
    nextHI = 0x00000000
    global LO
    LO = 0x00000000
    global nextLO
    nextLO = 0x00000000
    global REG
    REG = [0x00000000] * 32
    global REGWritePort
    REGWritePort=wPort()
    global REGReadPortA
    REGReadPortA = rPort()
    global REGReadPortB
    REGReadPortB = rPort()
    global MemWritePort
    MemWritePort = wPort()
    global ALUPortA
    ALUPortA = 0x00000000
    global ALUPortB
    ALUPortB = 0x00000000
    global globalStall
    globalStall = False
    global DMEMStall
    DMEMStall = False
    global IMEMStall
    IMEMStall = False

def clearCombinationalWires():
    global nextPC
    nextPC = "Unset Wire - wires are not stateful!"
    global nextHI
    nextHI = "Unset Wire - wires are not stateful!"
    global nextLO
    nextLO = "Unset Wire - wires are not stateful!"
    REGWritePort.address = "Unset Wire - wires are not stateful!"
    REGWritePort.value = "Unset Wire - wires are not stateful!"
    REGWritePort.writeEnable = "Unset Wire - wires are not stateful!"
    REGReadPortA.address = "Unset Wire - wires are not stateful!"
    REGReadPortA.value = "Unset Wire - wires are not stateful!"
    REGReadPortB.address = "Unset Wire - wires are not stateful!"
    REGReadPortB.value = "Unset Wire - wires are not stateful!"
    global ALUPortA
    ALUPortA = "Unset Wire - wires are not stateful!"
    global ALUPortB
    ALUPortB = "Unset Wire - wires are not stateful!"

def validateInstControlCompleteness():
    strType=type("")
    assert type(ALUPortA)!=strType, ALUPortA
    assert type(ALUPortB)!=strType, ALUPortB
    assert type(REGWritePort.address)!=strType, REGWritePort.address
    assert type(REGWritePort.writeEnable)!=strType, REGWritePort.writeEnable
    
    
def clearExternalStalls():
    global globalStall
    globalStall = False
    global DMEMStall
    DMEMStall = False
    global IMEMStall
    IMEMStall = False    
    
def updatePC():
    global PC
    if not globalStall:
        PC = nextPC
    else:
        PC = PC

def updateREG():
    global REG
    global HI
    global LO
    #value mux processed below - addr mux modeled in control as static property of instruction
    if CONTROL.isLink: 
        REGWritePort.value = PC + 4 # use signalname later
    elif CONTROL.memToReg:
        REGWritePort.value = DATAPATH.outMEM
    else:
        REGWritePort.value = DATAPATH.outALU
    if not globalStall:
        if REGWritePort.writeEnable:
            if REGWritePort.address != 0:
                REG[REGWritePort.address]=REGWritePort.value
                if printVerboseOutput:
                    print("Wrote {:#010x} to REG[{:d}]".format(REGWritePort.value, REGWritePort.address))
        if CONTROL.writeHILO:
            HI=nextHI
            LO=nextLO
    
def updateMEM():
    if MemWritePort.writeEnable and not globalStall:
        if CONTROL.byteSize:
            DMEM.storeByte(MemWritePort.address, MemWritePort.value)
            if printVerboseOutput:
                print("Wrote {:#04x} to MEM[{:#010x}]".format(MemWritePort.value, MemWritePort.address))
        else:
            DMEM.storeWord(MemWritePort.address, MemWritePort.value)
            if printVerboseOutput:
                print("Wrote {:#010x} to MEM[{:#010x}--{:#010x}]".format(MemWritePort.value, MemWritePort.address & 0xFFFFFFFC, (MemWritePort.address & 0xFFFFFFFC)+4))
