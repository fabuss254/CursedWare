-- LIBS
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local TextLabel = require("src/classes/TextLabel")

-- CLASS
local class = TextLabel:extend()

function class:new(Font, x, y)
    self.super.new(self.super, Font, x, y)

    self._Offset = Vector2(0, 0)
    self._RotOffset = 0

    return self
end

function class:getDrawingCoordinates(mult)
    local PosX = self.Position.X + self._Offset.X*mult + self.Size.X*self.Anchor.X * self.Scale
    local PosY = self.Position.Y + self._Offset.Y*-mult + self.Size.Y*self.Anchor.Y * self.Scale
    local ScaleX = self.Size.X*self.Anchor.X * self.Scale
    local ScaleY = self.Size.Y*self.Anchor.Y * self.Scale

    return PosX, PosY, ScaleX, ScaleY
end

function class:update(dt)
    local time = love.timer.getTime()

    self._Offset.X = math.cos(time*100)*1
    self._Offset.Y = math.sin(time*50)*1
    self._RotOffset = math.sin(time*5)*math.rad(1)
end

function class:draw()
    local PosX, PosY, ScaleX, ScaleY = self:getDrawingCoordinates(1)

    self.Color:apply(1-self.Opacity, true)
    
    love.graphics.translate(PosX - ScaleX, PosY - ScaleY)
    love.graphics.rotate(self.Rotation + self._RotOffset)
    love.graphics.translate(-ScaleX, -ScaleY)
    love.graphics.draw(self._TEXT, 0, 0, 0, self.Scale, self.Scale)
    love.graphics.origin()
    
    local PosX, PosY, ScaleX, ScaleY = self:getDrawingCoordinates(6)
    self.Color:apply(.5-self.Opacity*.5, true)

    love.graphics.translate(PosX - ScaleX, PosY - ScaleY)
    love.graphics.rotate(self.Rotation + self._RotOffset)
    love.graphics.translate(-ScaleX, -ScaleY)
    love.graphics.draw(self._TEXT, 0, 0, 0, self.Scale, self.Scale)
    love.graphics.origin()
    
end

return class