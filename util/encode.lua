-- We use Table Concat to avoid Stack Overflow C error --
local M = {}

function M.encode(source, layerOffset, marker, sep)
    local o = {}
    for i = 1, #source do
        o[i] = tostring(source:byte(i) + layerOffset)
    end
    return marker .. table.concat(o, sep)
end

function M.splitPayload(s)
    local tbl = {}
    local i = 1
    while i <= #s do
        local chunk = math.random(30, 70)
        local piece = s:sub(i, i + chunk - 1)
        table.insert(tbl, '"' .. piece .. '"')
        i = i + chunk
    end
    return "{" .. table.concat(tbl, ",") .. "}"
end

return M
