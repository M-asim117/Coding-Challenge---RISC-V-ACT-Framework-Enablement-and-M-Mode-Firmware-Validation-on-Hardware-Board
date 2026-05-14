# Makefile for UART Communication Program
# RISC-V ACT Framework 
# Compiler and flags
# Default UART device (can be overridden)
UART_DEVICE ?= /dev/ttyUSB0
CC      := gcc
CFLAGS  := -Wall -Wextra -Wpedantic -std=c99 -O2
LDFLAGS := 

# Target executable name
TARGET  := uart_comm

# Source files
SOURCES := uart_comm.c
OBJECTS := $(SOURCES:.c=.o)
# Color codes for output
GREEN   := \033[0;32m
YELLOW  := \033[0;33m
BLUE    := \033[0;34m
RED     := \033[0;31m
NC      := \033[0m # No Color

# ============================================================================
# DEFAULT TARGET
# ============================================================================
.PHONY: all
all: $(TARGET)

# ============================================================================
# BUILD TARGET
# ============================================================================
$(TARGET): $(OBJECTS)
	@echo "$(BLUE)[Linking]$(NC) $@"
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@echo "$(GREEN)[  Build Complete]$(NC) Executable: $(TARGET)"

%.o: %.c
	@echo "$(BLUE)[Compiling]$(NC) $<"
	@$(CC) $(CFLAGS) -c $< -o $@

# ============================================================================
# RUN TARGET
# ============================================================================
.PHONY: run
run: $(TARGET)
	@echo "$(YELLOW)[Running]$(NC) $(TARGET) on $(UART_DEVICE)"
	@echo "$(YELLOW)Note:$(NC) Make sure your UART device is connected!"
	@sudo ./$(TARGET) $(UART_DEVICE)

# Alternative run without sudo (if permissions allow)
.PHONY: run-noroot
run-noroot: $(TARGET)
	@echo "$(YELLOW)[Running]$(NC) $(TARGET) on $(UART_DEVICE)"
	@./$(TARGET) $(UART_DEVICE)

# ============================================================================
# CLEAN TARGET
# ============================================================================
.PHONY: clean
clean:
	@echo "$(RED)[Cleaning]$(NC) object files and executable"
	@rm -f $(OBJECTS) $(TARGET)
	@echo "$(GREEN)[ Clean Complete]$(NC)"

# ============================================================================
# HELP TARGET
# ============================================================================
.PHONY: help
help:
	@echo ""
	@echo "$(BLUE)==== UART Communication Program - Makefile Help ====$(NC)"
	@echo ""
	@echo "$(YELLOW)Available Targets:$(NC)"
	@echo "  $(GREEN)make$(NC) or $(GREEN)make all$(NC)          - Build the UART communication program"
	@echo "  $(GREEN)make run$(NC)                - Build and run the program (with sudo)"
	@echo "  $(GREEN)make run-noroot$(NC)         - Build and run without sudo"
	@echo "  $(GREEN)make clean$(NC)              - Remove object files and executable"
	@echo "  $(GREEN)make help$(NC)               - Display this help message"
	@echo ""
	@echo "$(YELLOW)Build Options:$(NC)"
	@echo "  Override UART device: $(GREEN)make run UART_DEVICE=/dev/ttyUSB1$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage Examples:$(NC)"
	@echo "  1. Build the project:"
	@echo "     $$ make"
	@echo ""
	@echo "  2. Run on default device (/dev/ttyUSB0):"
	@echo "     $$ make run"
	@echo ""
	@echo "  3. Run on different device:"
	@echo "     $$ make run UART_DEVICE=/dev/ttyUSB1"
	@echo ""
	@echo "  4. Run on COM port (if using socat/similar):"
	@echo "     $$ make run UART_DEVICE=/dev/pts/1"
	@echo ""
	@echo "  5. Clean build files:"
	@echo "     $$ make clean"
	@echo ""
	@echo "$(YELLOW)Prerequisites:$(NC)"
	@echo "  GCC compiler installed"
	@echo "  Standard C library (libc) with termios support"
	@echo "  UART device connected and recognized by the system"
	@echo "  Proper permissions for /dev/ttyUSB* (usually requires sudo)"
	@echo ""
	@echo "$(YELLOW)Compiler Flags:$(NC)"
	@echo "  $(CFLAGS)"
	@echo ""
	@echo "$(YELLOW)Troubleshooting:$(NC)"
	@echo "  If UART device not found: lsusb or dmesg | tail"
	@echo "  If permission denied: sudo make run"
	@echo "  To list available UART devices: ls -la /dev/tty*"
	@echo ""

# ============================================================================
# INFO TARGET
# ============================================================================
.PHONY: info
info:
	@echo "$(BLUE)Project Information:$(NC)"
	@echo "  Target:        $(TARGET)"
	@echo "  Source:        $(SOURCES)"
	@echo "  Compiler:      $(CC)"
	@echo "  C Standard:    C99"
	@echo "  CFLAGS:        $(CFLAGS)"
	@echo "  UART Device:   $(UART_DEVICE)"
	@echo "  Baud Rate:     115200"

# ============================================================================
# INSTALL TARGET (optional - for advanced use)
# ============================================================================
.PHONY: install
install: $(TARGET)
	@echo "$(YELLOW)[Installing]$(NC) $(TARGET) to /usr/local/bin"
	@sudo cp $(TARGET) /usr/local/bin/
	@echo "$(GREEN)[Installation Complete]$(NC)"
	@echo "You can now run: $(TARGET) /dev/ttyUSB0"

# ============================================================================
# UNINSTALL TARGET
# ============================================================================
.PHONY: uninstall
uninstall:
	@echo "$(YELLOW)[Uninstalling]$(NC) $(TARGET)"
	@sudo rm -f /usr/local/bin/$(TARGET)
	@echo "$(GREEN)[Uninstall Complete]$(NC)"

# ============================================================================
# REBUILD TARGET
# ============================================================================
.PHONY: rebuild
rebuild: clean all
	@echo "$(GREEN)[Rebuild Complete]$(NC)"

# ============================================================================
# PHONY TARGETS DECLARATION
# ============================================================================
.PHONY: all build run clean help info install uninstall rebuild run-noroot

