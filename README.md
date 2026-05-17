# Smart Shopping Cart

> [!CAUTION]
> Clone this repo into a path without spaces, else the assembler will break.

Group 19's final project for the embedded systems lab.

Group members:

- Ammar Fattan Ramanda'i
- Carlsson Khovis
- Jonathan Matius Weni Gerimu
- Michael Christian

## Prerequisites

Required hardware:

- Arduino UNO
- Load cell with HX711 amplifier

Additionally, a Proteus 8.11 project is provided in `proteus/` for simulation.

You will also need PlatformIO to build the project. The sections below apply to the PlatformIO CLI.

## Building

Do

```bash
pio run 
```

The output will be in `.pio/build/build/`.

### Disassembly

If you want to debug the build's assembly, do

```bash
pio run -t disasm
```

The output disassembly will be saved to `.pio/build/default/firmware-disasm.txt`.

## Uploading

Do

```bash
pio run -t upload
```

to build and upload the firmware, or

```bash
pio run -t upload -t monitor
```

to also open a serial monitor.

## Report

### Introduction

Shopping carts are nice, but they would be even nicer if they could intelligently identify what products are inside them and who is using them, similar to shopping carts in ecommerce platforms. To do so, a shopping cart is extended with sensors to identify the weight and identity of products, as well as the customer.

### Hardware

The microcontroller used is the Arduino UNO R3 based on the ATmega328P microprocessor with messages displayed on an 20x4 LCD with a PCF8574 piggyback board for the user and through USART for debugging. Sensors used are:
    
- 1 kg load cell with HX711 amplifier for measuring weight.
- RFID-RC522 board for RFID cards that identify customers. It is of note that a level shifter is used to bridge the Arduino's 5V logic with the board's 3.3V logic.
- Barcode scanner (cancelled because they are too expensive).

### Software

The firmware is written in AVR assembly and assembled by the GCC toolchain with the help of the PlatformIO CLI.

Source files are organized in `src/`, with each file exporting global useful functions with `.global`. These files are:

- `main.S` which contains the main program flow.
- `usart.S` which contains functions related to USART, i.e. outputting to the serial monitor.
- `timing.S` which contains functions for delays.
- `load_cell.S` which contains functions for interfacing with the load cell through the HX711 amplifier.
- `lcd.S` which contains functions for interfacing with the LCD screen through the PCF8574 piggyback board.
- `rfid.S` which contains functions for interfacing with RFID cards through a RC522 module.

Include files containing macro and constant definitions are organized in `include/` and are included in relevant source files. These files are:

- `pins.inc` which contains pin definitions (to prevent conflicts).
- `twi_addresses.inc` which contains TWI/I2C addresses.
- `timing.inc` which contains a unified delay macro and time unit definitions.
- `usart.inc` which contains helper macros for using the USART functions.
- `lcd.inc` which contains helper macros for using the LCD functions.
- `load_cell.inc` which contains a definition for the load cell's calibration factor.

There are also two files in `scripts/`:

- `disasm.py` adds a custom `disasm` target that outputs the disassembly of the firmware for debugging purposes.
- `as_opts.py` adds a flag to the assembler that allows it to find files in `include/` during assembly. This is necessary because the include path supplied to the assembler has to be an absolute path (as the assembler process is invoked in a different working directory) and thus must be obtained dynamically. It also modifies any backslashes in the path into slashes, as the assembler only accepts UNIX-style paths.

The project configuration in `platformio.ini` is relatively standard. We did use the build flag `-Wl,--relax` which optimizes `call` into `rcall` whenever possible to save on a few bytes.

### Testing

The firmware successfully communicates with the LCD in and out of simulation. The code also works with a simulated load cell in Proteus and an RFID module in Wokwi.

The Proteus file can be found in `proteus/`, and the Wokwi project for testing the RFID module is [here](https://wokwi.com/projects/463904491144704001). For the Wokwi project, use F1 -> Upload Firmware ... to skip the long build times.

### Conclusion

We would say this project represents about 75% of our original vision. There are still some more issues to solve with coding convention consistency, and the lack of a barcode scanner and code to interface with it, which we leave for future development.
