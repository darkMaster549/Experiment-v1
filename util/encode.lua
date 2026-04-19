local M = {}

function M.encode(source, layerOffset)
    local o = {}
    for i = 1, #source do
        o[i] = source:byte(i) + layerOffset
    end
    return o
end

return M
