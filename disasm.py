Import("env")

env.AddCustomTarget(
    name="disasm",
    dependencies="$BUILD_DIR/firmware.elf",
    actions=[
        "avr-objdump.exe -d $SOURCE > $BUILD_DIR/disasm.txt",
    ],
    title="Disassembly",
    description="Build and disassemble"
)
