::Gets Starting Directory
Set "var=%CD%\build"

::Make C files
::make clean
::make

::Create Hex File
cd %var%
objcopy -O ihex output.elf outputHex.hex
::ECHO g >> outputHex.hex


::Executes pLink to synk Hex file
cd C:\Program Files (x86)\PuTTY
plink.exe -serial COM3 -sercfg 115200,8,n,1,X < %var%/outputHex.hex
TIMEOUT 1
taskkill /F /IM plink.exe

::Open Putty
putty.exe -serial COM3 -sercfg 115200,8,n,1,X

::Deletes temp File
DEL %var%\outputHex.hex