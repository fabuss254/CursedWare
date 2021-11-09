-- LIBS
local Instance = require("src/libs/Instance")
local Object = require("src/libs/Classic") 

-- CLASS
local class = Object:extend()

function class:new(R, G, B, A)
    self._type = "Color"

    self.R = R or 0
    self.G = G or 0
    self.B = B or 0
    self.A = A or 1

    return self
end

-- METHODS
function class:Apply()
    love.graphics.setColor(self.R, self.G, self.B, self.A)
end

-- METATABLES
function class:__tostring()
    return string.format("Color(%i, %i, %i, %i)", self.R, self.G, self.B, self.A)
end

function class.__eq(a, b)
    assert(Instance.typeof(b) == "Color", "Attempt to compare " .. Instance.typeof(a) .. " and " .. Instance.typeof(b))
    return a.R == b.R and a.G == b.G and a.B == b.B and a.A == b.A
end

return class