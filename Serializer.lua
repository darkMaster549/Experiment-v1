--==This file Encodes a proto table into a hex string the VM can decode==--

local Serializer = {}

local function newWriter()
    local w = { buf = {} }

    function w:byte(v)
        self.buf[#self.buf + 1] = string.format("%02X", v % 256)
    end

    function w:int32(v)
        v = math.floor(v) % 4294967296
        self:byte(v % 256)
        self:byte(math.floor(v / 256)       % 256)
        self:byte(math.floor(v / 65536)     % 256)
        self:byte(math.floor(v / 16777216)  % 256)
    end

    function w:double(n)
        -- IEEE 754 double to 8 bytes little-endian
        if n ~= n then
            -- NaN
            for i = 1, 8 do self:byte(0xFF) end
            return
        end
        if n == math.huge then
            for i = 1, 7 do self:byte(0x00) end
            self:byte(0x7F)
            self:byte(0xF0)
            return
        end
        if n == -math.huge then
            for i = 1, 7 do self:byte(0x00) end
            self:byte(0xFF)
            self:byte(0xF0)
            return
        end

        local sign = 0
        if n < 0 then sign = 1; n = -n end
        if n == 0 then
            for i = 1, 8 do self:byte(0) end
            return
        end

        local exp = 0
        local mant = n
        if mant >= 1 then
            while mant >= 2 do mant = mant / 2; exp = exp + 1 end
        else
            while mant < 1 do mant = mant * 2; exp = exp - 1 end
        end
        mant = mant - 1 -- remove implicit leading 1
        exp = exp + 1023

        local bytes = {}
        for i = 1, 6 do
            mant = mant * 256
            bytes[i] = math.floor(mant)
            mant = mant - bytes[i]
        end
        mant = mant * 16
        local mantHigh = math.floor(mant)
        bytes[7] = mantHigh + (exp % 16) * 16
        bytes[8] = math.floor(exp / 16) + sign * 128

        for i = 1, 8 do self:byte(bytes[i]) end
    end

    function w:string(s)
        if s == nil then
            self:int32(0)
        else
            self:int32(#s + 1)
            for i = 1, #s do
                self:byte(s:byte(i))
            end
            self:byte(0) -- null terminator
        end
    end

    function w:raw()
        return table.concat(self.buf)
    end

    return w
end

local function writeProto(w, proto)
    w:string(proto.source)
    w:int32(proto.lineDefined)
    w:int32(proto.lastLineDefined)
    w:byte(proto.numUpvalues)
    w:byte(proto.numParams)
    w:byte(proto.isVararg)
    w:byte(proto.maxStack)

    w:int32(#proto.instructions)
    for _, inst in ipairs(proto.instructions) do
        w:int32(inst)
    end

    w:int32(#proto.constants)
    for _, c in ipairs(proto.constants) do
        if c.type == "nil" then
            w:byte(0)
        elseif c.type == "boolean" then
            w:byte(1)
            w:byte(c.value and 1 or 0)
        elseif c.type == "number" then
            w:byte(3)
            w:double(c.value)
        elseif c.type == "string" then
            w:byte(4)
            w:string(c.value)
        end
    end

    w:int32(#proto.protos)
    for _, p in ipairs(proto.protos) do
        writeProto(w, p)
    end

    -- Strip debug info for obfuscation
    w:int32(0) -- no line info
    w:int32(0) -- no locals
    w:int32(0) -- no upvalue names
end

function Serializer.encode(proto)
    local w = newWriter()
    writeProto(w, proto)
    return w:raw()
end

return Serializer
