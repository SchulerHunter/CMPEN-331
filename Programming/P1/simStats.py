class simStats:
    cycle=0
    fetched=0
    squashed=0
    completed=0
    IMEMstalls=0
    DMEMstalls=0
    loads=0
    stores=0
    ALUOps=0
    BoolOps=0
    controlOps=0
    sysCalls=0

    def printStats(self):
        print("\nTotal Cycles: {:d}".format(self.cycle))
        print("IMEM stall cycles: {:d}".format(self.IMEMstalls))
        print("DMEM stall cycles: {:d}\n".format(self.DMEMstalls))
        print("Insts.Fetched: {:d}".format(self.fetched))
        print("Insts.Squashed: {:d}".format(self.squashed))
        print("Insts.Completed: {:d}".format(self.completed))
        print("Operation Mix:")
        print("\tInsts.Loads: {:d}".format(self.loads))
        print("\tInsts.Stores: {:d}".format(self.stores))
        print("\tInsts.ALU Ops: {:d}".format(self.ALUOps))
        print("\tInsts.Boolean Ops: {:d}".format(self.BoolOps))
        print("\tInsts.Control Ops: {:d}".format(self.controlOps))
        print("\tInsts.SYSCALLs: {:d}".format(self.sysCalls))

stats=simStats()
