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

-- STATICS
class.Red = class(1, 0, 0)
class.Green = class(0, 1, 0)
class.Blue = class(0, 0, 1)
class.White = class(1, 1, 1)
class.Black = class(0, 0, 0)

-- METHODS
function class.fromRGB(R,G,B)
    return class(R/255, G/255, B/255)
end

function class.fromHSV(H, S, V, A)
    H = H * 360

    local R,G,B = 0,0,0
    local C = V * S
    local X = C * (1 - math.abs((H/60)%2-1))
    local m = V - C

    if H < 60 then R = C; G = X; B = 0
    elseif H < 120 then R = X; G = C; B = 0
    elseif H < 180 then R = 0; G = C; B = X
    elseif H < 240 then R = 0; G = X; B = C
    elseif H < 300 then R = X; G = 0; B = C
    else R = C; G = 0; B = X
    end

    return class(R,G,B,A)
end

function class:apply(Trans, isText)
    love.graphics.setColor(self.R, self.G, self.B, self.A*(Trans or 1))
end

function class:applyBackground()
    love.graphics.setBackgroundColor(self.R, self.G, self.B)
end

function class:lerp(Color, Alpha)
    Alpha = math.min(math.max(Alpha, 0), 1)
    if Alpha == 0 then return self end
    if Alpha == 1 then return Color end
    return class(
        (1-Alpha) * self.R + Color.R*Alpha,
        (1-Alpha) * self.G + Color.G*Alpha,
        (1-Alpha) * self.B + Color.B*Alpha,
        (1-Alpha) * self.A + Color.A*Alpha
    )
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