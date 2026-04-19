local walker   = require("ast.walker")
local aliases  = require("util.aliases")
local vmGen    = require("codegen.vm")
local encode   = require("util.encode")
local deadcode = require("passes.deadcode")
local cfg      = require("config")

return function(ast, source, layerNum)
    -- emit the ast back to source string --
    local emitted = walker.emit(ast)

    local layerOffset = cfg.offset + (layerNum * 111)
    local layerMarker = cfg.marker .. tostring(layerNum) .. "!"

    local encoded    = encode.encode(emitted, layerOffset, layerMarker, cfg.sep)
    local payloadTbl = encode.splitPayload(encoded)

    local chars  = #emitted
    local total  = math.max(cfg.noise.min, math.floor(chars * cfg.noise.multiplier))
    local before = math.floor(total * 0.6)
    local after  = total - before

    -- for variable names for decode scaffolding --
    local vIdx = 21
    local function nextV()
        local n = "v" .. tostring(vIdx); vIdx = vIdx + 1; return n
    end

    local decV   = nextV()
    local argV   = nextV()
    local keyA   = math.random(1000, 9999)
    local keyB   = math.random(1000, 9999)
    local storeV = nextV()
    local metaV  = nextV()
    local keyV   = nextV()
    local chunkV = nextV()
    local stripV = nextV()
    local tblV   = nextV()

    local isLuau = emitted:find("loadstring") or emitted:find("game%.") or emitted:find("workspace") or emitted:find("script%.")

    local metaCode = ""
    metaCode = metaCode .. string.format("local %s=v0(%d)..v0(%d);", keyV, keyA, keyB)
    metaCode = metaCode .. string.format("local %s=%s;", tblV, payloadTbl)
    metaCode = metaCode .. string.format("local %s={};", storeV)
    metaCode = metaCode .. string.format("local %s=v17(%s,{__index=function(_,k)if k==%s then return v8(%s);end end});", metaV, storeV, keyV, tblV)
    metaCode = metaCode .. string.format("local %s=%s[%s];", chunkV, metaV, keyV)
    metaCode = metaCode .. string.format("local %s=v4(%s,%d);", stripV, chunkV, #layerMarker + 1)
    metaCode = metaCode .. string.format(
        "local %s=function(%s)local o={};local i=1;while i<=#%s do local j=i;while j<=#%s and v2(%s,j)~=v2(\"Y\",1) do j=j+1 end;local n=v1(v4(%s,i,j-1));if n then v9(o,v3(n-%d))end;i=j+1;end;return v8(o);end;",
        decV, argV, argV, argV, argV, argV, layerOffset, argV
    )

    return aliases()
        .. vmGen()
        .. deadcode(before)
        .. metaCode
        .. deadcode(after)
        .. string.format("_x(%s(%s))", decV, stripV)
end
