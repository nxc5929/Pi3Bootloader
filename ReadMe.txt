RPi3 Bootloader

This program allow for compiled HEX Files to be executed on the RPi3 using a UART connection between a windows based computer and the RPi3. The program sends a HEX file to the RPi3 where is is deconstructed, stored to RAM memory, and executed.

SETUP:
*Plugin the RPi3 microSD card into the computer.
*Delete or Rename and Disk Image Files current on the microDS card.
*Copy the kernel7 Disc Image located in the /bin/ folder to the microSD card.
*Unplug the microSD card from the computer and plug it back into the RPi3.
*Connect the UART according to the following:
	* Ground (Pin 6)
	* TX (Pin 8)
	* RX (Pin 10)  
*Power up the Pi



SENDING A HEX FILE: (Send your code to run)
Automatic:
	*Copy the exportToPie.bat file to your CMPE240 lab.
		*The .bat file should be at the same layer as the Makefile.
	*Double click the .bat file.
		*The file will first make a .hex file from the .elf file supplied during compile.
		*The COM3 port will be configured for the RPi3.
		*The HEX file will be send to the COM3 port.
		*Putty will open
		****PRESS G TO START EXECUING THE PROGRAM

Manual:
	*Send a HEX file in the RPi3
	*Send an ASCII char 'G' to start the porgram 