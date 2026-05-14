# Adds targets to produce a disassembled version of the build.

import os
Import("env")

env.AddCustomTarget(
    name="disasm",
    dependencies="$BUILD_DIR/firmware.elf",
    actions=[
        "@avr-objdump.exe -D -g $SOURCE > $BUILD_DIR/firmware_disasm.txt",
        "@echo Saved disassembly file in build folder."
    ],
    title="Disassembly",
    description="Disassemble firmware"
)
