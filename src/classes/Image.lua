-- LIBS
local Vector2 = require("src/classes/Vector2")
local Rect = require("src/classes/Rect")

-- CLASS
local class = Rect:extend()

function class:new(ImagePath)
    self.super.new(self)

    self.Texture = love.graphics.newImage(ImagePath)
end

function class:draw()
    local PosX, PosY, ScaleX, ScaleY = self:getDrawingCoordinates()
    local TextureWidth, TextureHeight = self.Texture:getDimensions()

    self.Color:apply()
    if self.Shader then love.graphics.setShader(self.Shader) end

    love.graphics.translate(PosX - ScaleX, PosY - ScaleY)
    love.graphics.rotate(self.Rotation)
    love.graphics.translate(-ScaleX, -ScaleY)
    love.graphics.draw(self.Texture, 0, 0, 0, self.Size.X/TextureWidth, self.Size.Y/TextureHeight)
    love.graphics.origin()
    if self.Shader then love.graphics.setShader() end
end

return class