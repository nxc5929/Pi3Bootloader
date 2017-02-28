::Gets Starting Directory
cd build

::Make C files
::make clean
::make

::Create Hex File
objcopy -O ihex output.elf outputHex.hex

::Send file
mode COM3 115200,n,8,1
copy outputHex.hex COM3

::Open Putty
cd C:\Program Files (x86)\PuTTY
putty.exe -serial COM3 -sercfg 115200,n,8,1