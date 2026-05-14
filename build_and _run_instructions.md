# Coding-Challenge---RISC-V-ACT-Framework-Enablement-and-M-Mode-Firmware-Validation-on-Hardware-Board
# Place Both uart_comm.c File and Makefile in one directory and then run program with the follwoing commands. 
1. Running with Physical Hardware
•	By default, the tool targets /dev/ttyUSB0.
Bash
make run
•	To specify a different port (e.g., a specific USB-to-Serial adapter):
Bash
make run UART_DEVICE=/dev/ttyUSB1

Command	Description
make      ----->Compiles and links the source code.
make run	----->Executes the tool using sudo (required for hardware access).
make clean----->	Removes object files and the executable.
make info	----->Displays current build configuration and target device.
make help	----->Shows the full list of available targets and examples.
