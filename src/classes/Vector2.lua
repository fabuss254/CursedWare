-- LIBS
local Instance = require("src/libs/Instance")
local Object = require("src/libs/Classic") 

-- CLASS
local class = Object:extend()

function class:new(X, Y)
    self._type = "Vector2"

    self.X = X or 0
    self.Y = Y or 0

    return self
end

-- METHODS
function class:getMagnitude()
    return math.sqrt((self.X^2) + (self.Y^2))
end

function class:getUnit()
    local Length = self:getMagnitude()

    local x = self.X/Length
    local y = self.Y/Length

    return class((x == x and x) or 0, (y == y and y) or 0)
end

function class:Clone()
    return class(self.X, self.Y)
end

-- METATABLES
function class:__tostring()
    return string.format("Vector2(%i, %i)", self.X, self.Y)
end

function class.__eq(a, b)
    assert(Instance.typeof(b) == "Vector2", "Attempt to compare " .. Instance.typeof(a) .. " and " .. Instance.typeof(b))
    return a.X == b.X and a.Y == b.Y
end

function class.__add(a, b)
    local err = "unable to perform arithmetic (add) on " .. Instance.typeof(a) .. " and " .. Instance.typeof(b)
    assert(Instance.typeof(b) == "Vector2" or Instance.typeof(b) == "number", err)

    if Instance.typeof(a) == "number" then
        return class(a + b.X, a + b.Y)
    else
        if Instance.typeof(b) == "Vector2" then
            return class(a.X + b.X, a.Y + b.Y)
        else
            return class(a.X + b, a.Y + b)
        end
    end
end

function class.__sub(a, b)
    local err = "unable to perform arithmetic (sub) on " .. Instance.typeof(a) .. " and " .. Instance.typeof(b)
    assert(Instance.typeof(b) == "Vector2" or Instance.typeof(b) == "number", err)

    if Instance.typeof(a) == "number" then
        return class(a - b.X, a - b.Y)
    else
        if Instance.typeof(b) == "Vector2" then
            return class(a.X - b.X, a.Y - b.Y)
        else
            return class(a.X - b, a.Y - b)
        end
    end
end

function class.__mul(a, b)
    local err = "unable to perform arithmetic (mul) on " .. Instance.typeof(a) .. " and " .. Instance.typeof(b)
    assert(Instance.typeof(b) == "Vector2" or Instance.typeof(b) == "number", err)

    if Instance.typeof(a) == "number" then
        return class(a * b.X, a * b.Y)
    else
        if Instance.typeof(b) == "Vector2" then
            return class(a.X * b.X, a.Y * b.Y)
        else
            return class(a.X * b, a.Y * b)
        end
    end
end

function class.__div(a, b)
    local err = "unable to perform arithmetic (div) on " .. Instance.typeof(a) .. " and " .. Instance.typeof(b)
    assert(Instance.typeof(b) == "Vector2" or Instance.typeof(b) == "number", err)

    if Instance.typeof(a) == "number" then
        return class(a / b.X, a / b.Y)
    else
        if Instance.typeof(b) == "Vector2" then
            return class(a.X / b.X, a.Y / b.Y)
        else
            return class(a.X / b, a.Y / b)
        end
    end
end

return class