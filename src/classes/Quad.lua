-- LIBS
local Vector2 = require("src/classes/Vector2")
local Rect = require("src/classes/Rect")

-- CLASS
local class = Rect:extend()

function class:new(ImagePath, Size, TextureSize)
    self.super.new(self)
    self.Size = Size or Vector2(0, 0)

    self.Texture = love.graphics.newImage(ImagePath)
    self.Texture:setFilter("nearest")

    self.TextureSize = TextureSize or self.Size
    self:updateQuad()
end

function class:updateQuad()
    self.Quad = love.graphics.newQuad(0, 0, self.Size.X, self.Size.Y, self.TextureSize.X, self.TextureSize.Y)
end

function class:setTextureSize(nSize)
    self.TextureSize = nSize
    self:updateQuad()
end

function class:setSize(nSize)
    self.Size = nSize
    self:updateQuad()
end

function class:draw()
    local PosX, PosY, ScaleX, ScaleY = self:getDrawingCoordinates()

    self.Color:apply(1-self.Opacity)

    love.graphics.translate(PosX - ScaleX, PosY - ScaleY)
    love.graphics.rotate(self.Rotation)
    love.graphics.translate(-ScaleX, -ScaleY)
    love.graphics.draw(self.Texture, self.Quad, 0, 0)
    love.graphics.origin()
end

return class