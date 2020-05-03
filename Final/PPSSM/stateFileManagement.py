import sys
import os
import re
import HWComponents
import simStats

def wordTokenize(rmhLine):
    noComment=re.sub(r"//.*", "", rmhLine)
    hexStr= re.sub(r" ", "", noComment)
    return int(hexStr,16)

def getBytes(rmhLine):
    noComment=re.sub(r"//.*", "", rmhLine)
    wsSplit=noComment.split(" ")
    retBytes=[]
    for token in wsSplit:
        retBytes.append(int(token,16))
    return retBytes
    
def readSparseInitFiles(dirname):
    HWComponents.initHW()
    assert os.path.isdir(dirname), "User input for simulator files is not a directory"
    assert os.path.exists(dirname+'/mem.rmh'), "Missing MEM definition file!"
    assert os.path.exists(dirname+'/reg.rmh'), "Missing REG definition file!"
    assert os.path.exists(dirname+'/pc.rmh'), "Missing PC definition file!"
    assert os.path.exists(dirname+'/hilo.rmh'), "Missing HI,LO definition file!"
    global memFile
    global regFile
    global pcFile
    global hiloFile
    memFile = open(dirname+'/mem.rmh')
    regFile = open(dirname+'/reg.rmh')
    pcFile = open(dirname+'/pc.rmh')
    hiloFile = open(dirname+'/hilo.rmh')
    HWComponents.PC=wordTokenize(pcFile.readline())
    HWComponents.HI=wordTokenize(hiloFile.readline())
    HWComponents.LO=wordTokenize(hiloFile.readline())
    for rIndex in range(0,32):
        HWComponents.REG[rIndex] = wordTokenize(regFile.readline())
    memLoc=0
    for line in memFile:
        if line[0] == '@':
            memLoc = wordTokenize(line[2:])
        else:
            for val in getBytes(line):
                HWComponents.MainMemory.setByte(memLoc,val)
                memLoc=memLoc + 1
    memFile.close()
    regFile.close()
    pcFile.close()
    hiloFile.close()
    memFile = open(dirname+'/mem.dump.rmh',"w+")
    regFile = open(dirname+'/reg.dump.rmh',"w+")
    pcFile = open(dirname+'/pc.dump.rmh',"w+")
    hiloFile = open(dirname+'/hilo.dump.rmh',"w+")

def dump(stats):
    curMemWord=0
    curByte=0
    for key in sorted (HWComponents.MainMemory.byteContents.keys()):
        if key % 4 == 0 or not key & 0xFFFFFFFC == curMemWord & 0xFFFFFFFC:
            curMemWord=key & 0xFFFFFFFC
            if not curMemWord == curByte:
                outstr="@ {:08x}\n".format(curMemWord)
                memFile.write(outstr)
            outstr="{:02x} {:02x} {:02x} {:02x}\n".format(HWComponents.MainMemory.getByte(curMemWord),HWComponents.MainMemory.getByte(curMemWord+1),HWComponents.MainMemory.getByte(curMemWord+2),HWComponents.MainMemory.getByte(curMemWord+3))
            memFile.write(outstr)
            curByte=curMemWord+4
    memFile.close()
    for rIndex in range(0,32):
        regVal=HWComponents.REG[rIndex]
        outstr="{:02x} {:02x} {:02x} {:02x}\n".format(regVal>>24 & 0xFF,regVal>>16 & 0xFF,regVal>>8 & 0xFF,regVal & 0xFF)
        regFile.write(outstr)
    regFile.close()
    regVal=HWComponents.PC
    outstr="{:02x} {:02x} {:02x} {:02x}\n".format(regVal>>24 & 0xFF,regVal>>16 & 0xFF,regVal>>8 & 0xFF,regVal & 0xFF)
    pcFile.write(outstr)
    pcFile.close()
    regVal=HWComponents.HI
    HIoutstr="{:02x} {:02x} {:02x} {:02x}\n".format(regVal>>24 & 0xFF,regVal>>16 & 0xFF,regVal>>8 & 0xFF,regVal & 0xFF)
    regVal=HWComponents.LO
    LOoutstr="{:02x} {:02x} {:02x} {:02x}\n".format(regVal>>24 & 0xFF,regVal>>16 & 0xFF,regVal>>8 & 0xFF,regVal & 0xFF)
    hiloFile.write(HIoutstr)
    hiloFile.write(LOoutstr)
    hiloFile.close()
    stats.printStats()
    sys.exit()
                
numargs = len(sys.argv)
instLimit = 0xFFFFFFFF
cycleLimit = 0xFFFFFFFF

if numargs < 2:
    print("ERROR - Simulator needs at least one argument!")
    print("First argument should be name of directory containing simulation init files!")
    sys.exit()

if numargs > 4 or numargs == 3:
    print("ERROR - extraneous or missing arguments!")
    print("Simulator takes either 1 or 3 arguments, user provided {:d}".format(numargs-1))
    print(sys.argv[1:])
    sys.exit()
    
if numargs == 4:
    instLimit = int(sys.argv[2])
    cycleLimit = int(sys.argv[3])


readSparseInitFiles(sys.argv[1])
print("Initialized memory and register contents from directory {:s}".format(sys.argv[1]))

