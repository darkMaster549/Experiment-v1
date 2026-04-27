 
local walker = require("ast.walker")
 
 
local function encodeStr(s)
 
    local parts = {}
 
    for i = 1, #s do
 
        parts[i] = string.format("string.char(%d)", s:byte(i))
 
    end
 
    if #parts == 0 then return '""' end
 
    return "(" .. table.concat(parts, "..") .. ")"
 
end
 
 
return function(ast)
 
    walker.walk(ast, {
 
        string = function(tok)
 
            if tok.raw then return end
 
            if #tok.value <= 1 then return end
 
            local encoded = encodeStr(tok.value)
 
            return {type="raw", value=encoded}
 
        end
 
    })
 
    return ast
 
end
 
