--== This file was written by my friend ==--
local Obfuscator = require("Obfuscator")

local function readFile(path)
    local f = io.open(path, "rb")
    if not f then error("Cannot open file: " .. path) end
    local data = f:read("*a")
    f:close()
    return data
end

local function writeFile(path, data)
    local f = io.open(path, "wb")
    if not f then error("Cannot write file: " .. path) end
    f:write(data)
    f:close()
end

local function main(args)
    if #args < 2 then
        print("Usage: lua Main.lua <input.luac> <output.lua> [seed]")
        print("  input.luac  = compiled Lua 5.1 bytecode (luac -o out.luac src.lua)")
        print("  output.lua  = obfuscated output file")
        print("  seed        = optional integer seed (default: 0xDEADBEEF)")
        return
    end

    local inputPath  = args[1]
    local outputPath = args[2]
    local seed       = args[3] and tonumber(args[3]) or 0xDEADBEEF

    print("Reading: " .. inputPath)
    local bytecode = readFile(inputPath)

    print("Obfuscating with seed: " .. string.format("0x%X", seed))
    local result = Obfuscator.obfuscate(bytecode, { seed = seed })

    print("Writing: " .. outputPath)
    writeFile(outputPath, result)

    print("Done! Output size: " .. #result .. " bytes")
end

main(arg or {})
-- AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH!!!!!!!!
