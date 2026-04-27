 
-- Passes --
 
local walker = require("ast.walker")
 
 
local reserved = {
 
    v0=1,v1=1,v2=1,v3=1,v4=1,v5=1,v6=1,v7=1,v8=1,v9=1,
 
    v10=1,v11=1,v12=1,v13=1,v14=1,v15=1,v16=1,v17=1,v18=1,v19=1,v20=1,
 
    _v=1,_x=1,_s=1,_f=1,_e=1,_ok=1,_er=1,
 
}
 
 
local function genName(n)
 
    local chars = "lIiIlliIlI"
 
    local name = ""
 
    local idx = n
 
    repeat
 
        local r = (idx % #chars) + 1
 
        name = chars:sub(r,r) .. name
 
        idx = math.floor(idx / #chars)
 
    until idx == 0
 
    return "_" .. name
 
end
 
 
return function(ast)
 
    local map = {}
 
    local counter = 0
 
 
    -- first pass: collect all ident definitions (after local keyword)
 
    local tokens = ast.tokens
 
    for i, tok in ipairs(tokens) do
 
        if tok.type == "keyword" and tok.value == "local" then
 
            -- find next ident
 
            for j = i+1, math.min(i+3, #tokens) do
 
                if tokens[j].type == "ident" and not reserved[tokens[j].value] then
 
                    if not map[tokens[j].value] then
 
                        map[tokens[j].value] = genName(counter)
 
                        counter = counter + 1
 
                    end
 
                    break
 
                end
 
            end
 
        end
 
    end
 
 
    -- second pass: replace all mapped idents
 
    walker.walk(ast, {
 
        ident = function(tok)
 
            if map[tok.value] then
 
                return {type="ident", value=map[tok.value]}
 
            end
 
        end
 
    })
 
 
    return ast
 
end
 
