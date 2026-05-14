#define _GNU_SOURCE
#include <stdio.h>

#include<stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <errno.h>
#include <poll.h>

/**
 * Configures the UART interface parameters.
 * Returns the file descriptor on success, or -1 on failure.
 */
int configure_uart(const char *device, speed_t baud_rate) {
    int fd = open(device, O_RDWR | O_NOCTTY | O_NDELAY);
    if (fd == -1) {
        fprintf(stderr, "Error %d opening %s: %s\n", errno, device, strerror(errno));
        return -1;
    }

    // Clear O_NDELAY so read() behaves according to termios settings later
    fcntl(fd, F_SETFL, 0);

    struct termios tty;
    if (tcgetattr(fd, &tty) != 0) {
        fprintf(stderr, "Error %d from tcgetattr: %s\n", errno, strerror(errno));
        close(fd);
        return -1;
    }

    // Set Baud Rate
    cfsetospeed(&tty, baud_rate);
    cfsetispeed(&tty, baud_rate);

    // Setting Hardware Parameters: 8N1 (8 bits, No parity, 1 stop bit)
    tty.c_cflag &= ~PARENB;        // Clear parity bit (No parity)
    tty.c_cflag &= ~CSTOPB;        // Clear stop field (1 stop bit)
    tty.c_cflag &= ~CSIZE;         // Clear current size bits
    tty.c_cflag |= CS8;            // Set 8 bits per byte
    tty.c_cflag &= ~CRTSCTS;       // Disable hardware flow control
    tty.c_cflag |= CREAD | CLOCAL; // Turn on READ & ignore ctrl lines

    // Setting Software Modes: Raw Mode
    // Disable canonical mode, echo, and signal chars
    tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
    
    // Disable input processing (XON/XOFF, mapping CR to NL, etc.)
    tty.c_iflag &= ~(IXON | IXOFF | IXANY | ICRNL);

    // Disable output processing
    tty.c_oflag &= ~OPOST;

    // Set Read Timeouts (Wait up to 1 decisecond for at least 1 byte)
    tty.c_cc[VTIME] = 0; //  No termios timeout (poll handles timeout)
    tty.c_cc[VMIN] = 0;
    tcflush(fd, TCIOFLUSH);
    if (tcsetattr(fd, TCSANOW, &tty) != 0) {
        fprintf(stderr, "Error %d from tcsetattr: %s\n", errno, strerror(errno));
        close(fd);
        return -1;
    }

    return fd;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <uart-device-path> (e.g. /dev/ttyUSB0)\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *port_name = argv[1];
    printf("--- Initializing UART on %s ---\n", port_name);

    int fd = configure_uart(port_name, B115200);
    if (fd < 0) return EXIT_FAILURE;

    // 1. Transmit Test Message
    const char *msg = "RISC-V ACT Framework: Heartbeat Test\r\n";
    ssize_t bytes_written = write(fd, msg, strlen(msg));
    if (bytes_written < 0) {
        perror("Error writing to UART");
    } else {
        printf("Successfully sent %zd bytes: %s", bytes_written, msg);
    }

    // 2. Receive Data using poll() for timeout mechanism
    printf("Waiting for response (5 second timeout)...\n");
    
    struct pollfd pfd;
    pfd.fd = fd;
    pfd.events = POLLIN; // Monitor for "Data Ready to Read"

    unsigned char buffer[256];
    // poll() returns > 0 if data available, 0 on timeout, -1 on error
    int poll_ret = poll(&pfd, 1, 5000); 

    if (poll_ret == -1) {
        perror("Error during poll()");
    } else if (poll_ret == 0) {
        printf("Timeout: No data received from hardware.\n");
    } else {
        if (pfd.revents & POLLIN) {
            ssize_t bytes_read = read(fd, buffer, sizeof(buffer) - 1);
            if (bytes_read > 0) {
                buffer[bytes_read] = '\0'; // Null terminate for printing
                printf("Received (%zd bytes): %s\n", bytes_read, buffer);
            } else if (bytes_read < 0) {
                perror("Error reading from UART");
            }
        }
    }

    printf("Closing UART interface.\n");
    close(fd);
    return EXIT_SUCCESS;
}

