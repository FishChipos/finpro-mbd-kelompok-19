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
