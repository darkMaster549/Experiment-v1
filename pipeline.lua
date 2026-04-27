local cfg     = require("config")
local parser  = require("ast.parser")
local emitter = require("codegen.eR")

-- load enabled passes --
local passes = {}
if cfg.passes.rename   then passes[#passes+1] = require("passes.re")   end
if cfg.passes.numbers  then passes[#passes+1] = require("passes.num")  end
if cfg.passes.strings  then passes[#passes+1] = require("passes.str")  end
if cfg.passes.flatten  then passes[#passes+1] = require("passes.CFF")  end
-- deadcode is handled inside emitter, not as an AST pass --

return function(source)
    local passes_count = math.min(cfg.max_passes, 1) -- you can change the passes here 1 to 2 I'd recommend 2 don't freaking make it 3 Obfuscated code might not work due to StackOverFlow C or something.
    local current = source

    for i = 1, passes_count do
        io.write("Pass " .. i .. "/" .. passes_count .. "... ")
        io.flush()

        -- parse to AST --
        local ast = parser.parse(current)

        -- run each AST pass --
        for _, pass in ipairs(passes) do
            ast = pass(ast)
        end

        -- emit obfuscated output
        current = emitter(ast, current, i)
        print("done")
    end

    return current
end
