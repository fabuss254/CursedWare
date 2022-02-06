-- LIBS
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Object = require("src/libs/Classic")

-- CLASS
local class = Object:extend()

function class:new(x, y, w, h, r)
    self._type = "Rect"

    self.Position = Vector2(x, y)
    self.Size = Vector2(w or 100, h or 100)
    self.Anchor = Vector2(0, 0)
    self.Opacity = 0

    self.Color = Color(1, 1, 1)
    self.Rotation = r or 0
    self.Shader = nil
    self.CornerRadius = 0

    return self
end

function class:getDrawingCoordinates()
    local PosX = self.Position.X + self.Size.X*self.Anchor.X
    local PosY = self.Position.Y + self.Size.Y*self.Anchor.Y
    local ScaleX = self.Size.X*self.Anchor.X
    local ScaleY = self.Size.Y*self.Anchor.Y

    return PosX, PosY, ScaleX, ScaleY
end

function class:draw()
    local PosX, PosY, ScaleX, ScaleY = self:getDrawingCoordinates()

    self.Color:apply(1-self.Opacity)
    
    love.graphics.translate(PosX - ScaleX, PosY - ScaleY)
    love.graphics.rotate(self.Rotation)
    love.graphics.translate(-ScaleX, -ScaleY)
    love.graphics.rectangle("fill", 0, 0, self.Size.X, self.Size.Y, self.CornerRadius)
    love.graphics.origin()
end

return class