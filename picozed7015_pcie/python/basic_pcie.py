import mmap
import os

# open entire host memory
f = os.open('/dev/mem', os.O_RDWR)

# map memory section according pci assignment. 0x17fff is corresponding with AXI GPIO + BRAM address.
m = mmap.mmap(f,0x17FFF, flags=mmap.MAP_SHARED, prot=(mmap.PROT_READ|mmap.PROT_WRITE), offset=0xb1000000)

# Point to first address of the region
m.seek(0)

# write first address of the region. AXI GPIO
m.write(b'\x05')

# Pointer has been increased. Return the the first address.
m.seek(0)

# blink leds
m.write(b'\x0a')
