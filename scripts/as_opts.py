# Sets the flags for the assembler to see include files.

Import("env")

if env.IsIntegrationDump():
    Return()

includePath = env["PROJECT_DIR"].replace("\\", "/")
includePath = f"{includePath}/include"

env.Append(ASFLAGS=[
    f"-Wa,-I\"{includePath}\"",
])
