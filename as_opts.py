Import("env")

if env.IsIntegrationDump():
    # stop the current script execution
    Return()

includePath = env["PROJECT_DIR"].replace("\\", "/")
includePath = f"{includePath}/include"

env.Append(ASFLAGS=[
    f"-Wa,-I{includePath}",
])

