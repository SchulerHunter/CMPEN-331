#!/usr/bin/env python3

import stateFileManagement as sfm
import HWComponents
import simStats

HWComponents.printVerboseOutput=False
HWComponents.CONTROL.printVerboseOutput=False
HWComponents.DATAPATH.printVerboseOutput=False

def doSimCycle(stats):
    HWComponents.clearExternalStalls()
    HWComponents.clearCombinationalWires()
    fetchedInst=HWComponents.IMEM.loadWord(HWComponents.PC)
    if not fetchedInst.success:
        HWComponents.IMEMStall = True
        HWComponents.globalStall = True
        stats.IMEMstalls = stats.IMEMstalls + 1
    else:
        stats.fetched = stats.fetched + 1
        HWComponents.CONTROL.setInstDependentControl(fetchedInst.value) # decode the instruction
        HWComponents.validateInstControlCompleteness() # -- for debugging assistance only --
        HWComponents.DATAPATH.genALUOutputs(HWComponents.ALUPortA, HWComponents.ALUPortB) # perform ALU combinational logic
        HWComponents.DATAPATH.doConditionalDMEMRead() # perform Memory access, if control warrants
        HWComponents.CONTROL.setDataDependentControl(fetchedInst.value) # set mux results for data dependent (e.g. branch) decisions

def doSimTick(stats):
    HWComponents.updateREG()
    HWComponents.updateMEM()
    HWComponents.updatePC()
    stats.cycle = stats.cycle + 1
    if not HWComponents.globalStall:
        stats.completed = stats.completed + 1
    else:
        assert(HWComponents.DMEMStall or HWComponents.IMEMStall), "Unknown stall reason! - bug in global stall logic!"
        if HWComponents.printVerboseOutput:
            if HWComponents.DMEMStall:
                print("Global stall initiated by datapath in cycle {:d}, cause = DMEM_STALL - re-executing".format(stats.cycle))
            elif HWComponents.IMEMStall:
                print("Global stall initiated by datapath in cycle {:d}, cause = IMEM_STALL - re-initiating fetch".format(stats.cycle))

def main():
    print("Running P(SU) P(ython) S(imulator for a) S(ubset of) M(IPS)")
    while simStats.stats.cycle < sfm.cycleLimit and simStats.stats.completed < sfm.instLimit:
        doSimCycle(simStats.stats)
        doSimTick(simStats.stats)
    sfm.dump(simStats.stats)
    
if __name__ == "__main__":
        main()
