# FPGA-UART-Communicator
Coding a UART communication system on the NEXYS A7 100T board. Will have the ability to transmit bits and read bits from the system it is communicating with.

# Background
I wanted to create a project that would help me learn more about VHDL programming and also provide a challenge. This project provides a great detail of utilization since future classes cover UART communication (such as EECS 388 Embedded Systems). So this projecet provided a lot of learning opportunities.

# UART Communication
UART communication is the process of sending a stream of data in sequence (serial) between two pieces of hardware. This is used in embedded programming and FPGAs due to their need to transfer data to other systems. Both systems will have a UART system with a Transmitter (Tx) and Receiver(Rx). The transmitter is in charge of sending data to the other system, while the receiver is in charge of receiving data from the other system.

### Baud Rate
When connecting between two pieces of hardware, they need to decide the rate at which they communicate, this is what's known as the baud rate. It can cause major problems if the two systems aren't communicating at the same rate. For this project I used a baud rate of 115200.

### Sending/Reading
The transmitter signal of a system constantly sends out '1' when there is no input for the other system to read. Whenever the transmitter of some system A wants the receiver of some system B to actually pay attention to what it's sending, then system A will send a 0. This follows with a byte of information before sending another 1 to signify that it is stopping.

For this specific project, system B (my computer) is taking my inputs from the FPGA board, interpreting them as ASCII characters, and then printing them out through a terminal created using PuTTY.

It is important to mention that there is more to UART communication than just a signal that tells the system to start reading. In more advanced versions of UART communication, there is a parity bit that will tell the system B that is receiving the transmitted data if the data is corrupted.

# Implementation
Using the NEXYS A7 FPGA board, Vivado, and VHDL I created a project that creates the UART communication system. This allows the user to control the input of the board and when to send the data. Using switches 0-7 and button C on the board, the user can control the input byte of data and then presses button C when they want to send the data.

### The Finite State Machine
This system uses a finite state machine that has the following states:
- IDLE
  - It is in this state when there is no data for the system to transmit, so it is just sending 1 to system and waiting for a start signal.
- START
  - The state where it sends the start button signal of 0, where it then transitions to the next state once that sends
- DATA
  - This is where the FPGA sends in the byte of data, going through 8 states of sending the data sequentially before moving onto the last state
- STOP
  - The FPGA sends the final 1 that the state needs to transition understand that it doesn't need to read any more data. This finally transitions back into the idle state.

### Shift Register
Since the UART communication system is based on sequential pieces of data, the 8 bits of data need to be sent in series. This is done using a shift register that shifts the register to the right and replaces the MSB with a 1.

### Debouncer
When using mechanical components such as buttons in projects, you need to account for small erros in mechanical movement. The button used for the start signal needs to account for debouncing so that it doesn't send a bunch of accidental signals to the system that it's trying to communicate with.

# Further Plans
Currently this board is only able to send data to the computer, but I want to allow two way communication that allows the FPGA board to read from the terminal. So the next time I focus on this project I'm going to try and focus creating the receiver for the FPGA board and allowing it to display it using the Seven-Segment Display.
