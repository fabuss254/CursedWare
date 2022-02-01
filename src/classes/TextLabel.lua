-- LIBS
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Rect = require("src/classes/Rect")

-- CLASS
local class = Rect:extend()

function class:new(Font, x, y)
    self.super.new(self, x, y, 0, 0, 0)
    self._type = "TextLabel"
    self.Scale = 1

    self._TEXT = love.graphics.newText(Font, "TextLabel")
    self:SetText("TextLabel")

    return self
end

function class:SetText(newText)
    self._TEXT:set(newText)

    local width, height = self._TEXT:getDimensions()
    self.Size = Vector2(width, height)
end

function class:draw()
    local PosX, PosY, ScaleX, ScaleY = self:getDrawingCoordinates()

    self.Color:apply(1-self.Opacity)
    
    love.graphics.translate(PosX - ScaleX, PosY - ScaleY)
    love.graphics.rotate(self.Rotation)
    love.graphics.translate(-ScaleX, -ScaleY)
    love.graphics.draw(self._TEXT, 0, 0, 0, self.Scale, self.Scale)
    love.graphics.origin()
end

return class