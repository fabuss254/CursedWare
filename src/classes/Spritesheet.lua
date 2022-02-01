-- LIBS
local Vector2 = require("src/classes/Vector2")
local Rect = require("src/classes/Rect")

-- CLASS
local class = Rect:extend()

function class:new(ImagePath, SpriteSize, Duration)
    self.super.new(self)
    self.Size = Size or Vector2(0, 0)
    self.SpriteSize = SpriteSize or Size

    self.Image = love.graphics.newImage(ImagePath)
    self.Image:setFilter("nearest")

    self.Quads = {}
    for y = 0, self.Image:getHeight() - SpriteSize.Y, SpriteSize.Y do
        for x = 0, self.Image:getWidth() - SpriteSize.X, SpriteSize.X do
            table.insert(self.Quads, love.graphics.newQuad(x, y, SpriteSize.X, SpriteSize.Y, self.Image:getDimensions()))
        end
    end

    -- // Spritesheet properties
    self._Time = 0
    self._SavedFrame = 0

    self.CurrentFrame = 1
    self.IsPlaying = false
    self.Duration = Duration or 1
    self.TargetDuration = Duration or 1
    self.Speed = 1

    return self
end

function class:play()
    self._StartTime = love.timer.getTime()
    self.IsPlaying = true
end

function class:stop()
    self.IsPlaying = false
end

function class:cancel()
    self:stop()
    self._Time = 0
    self.CurrentFrame = 1
    self._SavedFrame = 0
end

function class:SkipFrame(numOfFrames)
    self._SavedFrame = self._SavedFrame + numOfFrames
end

function class:setDuration(newDuration)
    self._Time = 0
    self._SavedFrame = self.CurrentFrame
    self.Duration = newDuration
end

function class:update(dt)
    if self.IsPlaying then
        self._Time = self._Time + dt
        self.CurrentFrame = math.max(self.CurrentFrame, self._SavedFrame + math.floor(self._Time / self.Duration * #self.Quads))
    end

    self._sf = (self.CurrentFrame%#self.Quads) + 1
end

function class:draw(time)
    local PosX, PosY, ScaleX, ScaleY = self:getDrawingCoordinates()

    self.Color:apply(1-self.Opacity)

    love.graphics.translate(PosX - ScaleX, PosY - ScaleY)
    love.graphics.rotate(self.Rotation)
    love.graphics.translate(-ScaleX, -ScaleY)
    love.graphics.draw(self.Image, self.Quads[self._sf or 1], 0, 0, 0, self.Size.X/self.SpriteSize.X, self.Size.Y/self.SpriteSize.Y)
    love.graphics.origin()
end

return class