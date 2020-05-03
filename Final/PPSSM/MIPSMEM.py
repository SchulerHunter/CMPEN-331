class MemRetVal:
    def __init__(self, value,success):
        self.value=value
        self.success=success

def isAddr(byteAddress):
    assert(byteAddress >=0 and byteAddress < 1<<32)

def isByte(byteValue):
    assert(byteValue >= 0 and byteValue < 256)
        
class MainMem:
    byteContents={}
    defaultWordContents=[0xDE,0xAD,0xBE,0xA7]
    def access(self, address):
        return True

    def getByte(self, byteAddress):
        isAddr(byteAddress)
        if byteAddress in self.byteContents:
            return self.byteContents[byteAddress]
        else:
            return self.defaultWordContents[byteAddress%4]

    def setByte(self, byteAddress, byteValue):
        isAddr(byteAddress)
        isByte(byteValue)
        self.byteContents[byteAddress]=byteValue

class MemoryInterface:
    def __init__(self, memory, permission, writeThrough, name):
        self.name = name
        self.writable = permission
        self.writeThrough = writeThrough
        self.memory = memory
        #local memory block size is independent of memory interface size
        self.localMem = LocalMemory(4, writeThrough, memory)
        
    def loadWord(self, address):
        if address % 4 != 0:
            print(self.name,"UNALIGNED ACCESS ERROR on LW: Address = ", hex(address))
            return MemRetVal(0, False)
        else:
            hit = self.localMem.access(address)
            B0=self.localMem.getByte(address)
            B1=self.localMem.getByte(address+1)
            B2=self.localMem.getByte(address+2)
            B3=self.localMem.getByte(address+3)
            return MemRetVal(B0<<24 | B1<<16 | B2<<8 | B3, hit)

    def loadByteUnsigned(self, address):
        hit = self.localMem.access(address)
        return MemRetVal(self.localMem.getByte(address), hit)

    def loadByte(self, address):
        hit = self.localMem.access(address)
        B0=self.localMem.getByte(address)
        if B0 > 127:
            return MemRetVal(0xFFFFFF00 | B0, hit)
        else:
            return MemRetVal(B0, hit)

    def storeWord(self, address, value):
        if not self.writable:
            print(self.name,"ATTEMPT TO WRITE TO READ-ONLY MEMORY! - IGNORING")
            return
        if address % 4 != 0:
            print(self.name,"UNALIGNED ACCESS ERROR on SW: Address = ", hex(address))
            return
        else:
            B0=(value>>24) & 255
            B1=(value>>16) & 255
            B2=(value>>8) & 255
            B3=(value) & 255
            self.localMem.setByte(address,B0)
            self.localMem.setByte(address+1,B1)
            self.localMem.setByte(address+2,B2)
            self.localMem.setByte(address+3,B3)
            return

    def storeByte(self, address, value):
        if not self.writable:
            print(self.name,"ATTEMPT TO WRITE TO READ-ONLY MEMORY! - IGNORING")
            return
        B = (value) & 255
        self.localMem.setByte(address,B)
        return
        
class LocalMemRecord:
    def __init__(self, tag, data, writeFill):
        self.valid = True
        self.tag = tag
        self.dirty = writeFill
        self.data=data

class LocalMemory:
    def __init__(self, blockSize, writeThrough, memory):
        self.memory=memory
        self.blockSize = blockSize
        self.mask = (~(blockSize - 1)) & 0xFFFFFFFF
        self.writeThrough = writeThrough
        self.localData = {}

    def access(self, address):
        return (address & self.mask) in self.localData

    def getByte(self, address):
        if not self.access(address):
            newData=[]
            for i in range(address & self.mask, (address & self.mask)+self.blockSize):
                newData.append(self.memory.getByte(i))
            self.localData[address & self.mask] = LocalMemRecord(address & self.mask, newData, False)
        return self.localData[address & self.mask].data[address % self.blockSize]

    def setByte(self, address, value):
        if not self.access(address):
            newData=[]
            for i in range(address & self.mask, (address & self.mask)+self.blockSize):
                newData.append(self.memory.getByte(i))
            self.localData[address & self.mask] = LocalMemRecord(address & self.mask, newData, True)
        self.localData[address & self.mask].data[address % self.blockSize] = value
        if self.writeThrough:
            self.memory.setByte(address,value)
        else:
            self.localData[address & self.mask].dirty=True
