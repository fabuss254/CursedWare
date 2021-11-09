-- Libs
local Object = require("src/libs/Classic")
local Vector2 = require("src/classes/Vector2")
local Square = require("src/classes/Rect")

local Controls = require("src/libs/Controls")
local Instance = require("src/libs/Instance")

-- Settings
local ScreenSize = Vector2(1280, 1024)

-- Debug shit
local offx, offy = 0, 0
local SquareOne = Square(ScreenSize.X/2, ScreenSize.Y/2, 100, 100)
SquareOne.Anchor = Vector2(.5, .5)

-- Functions
function love.load()
    love.window.setMode(ScreenSize.X, ScreenSize.Y, {resizable=false, vsync=false})
end

function love.draw()
    SquareOne:draw()

    love.graphics.setColor(1, 0, 0, .5)
    love.graphics.circle("fill", ScreenSize.X/2, ScreenSize.Y/2, 5)

    love.graphics.setColor(0, 1, 0, .5)
    love.graphics.print(love.timer.getFPS() .. " FPS", 10, 10)
end

function love.update(dt)
    if love.keyboard.isDown("up") then SquareOne.Size = SquareOne.Size + Vector2(100,100)*dt end
    if love.keyboard.isDown("down") then SquareOne.Size = SquareOne.Size - Vector2(100,100)*dt end
    if love.keyboard.isDown("right") then SquareOne.Size = SquareOne.Size - Vector2(100,100)*"Salut" end
    
    local tick = love.timer.getTime()

    offx = math.sin(tick*1)*10
    offy = math.sin(tick*2)*10

    SquareOne.Position.X = ScreenSize.X/2 + offx
    SquareOne.Position.Y = ScreenSize.Y/2 + offy
    SquareOne.Rotation = math.sin(tick)*math.rad(20)
end