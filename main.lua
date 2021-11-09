-- Libs
local Object = require("src/libs/Classic")
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Square = require("src/classes/Rect")

local LogManager = require("src/libs/Debug/LogManager")
local Controls = require("src/libs/Controls")
local Instance = require("src/libs/Instance")

-- Settings
local ScreenSize = Vector2(1280, 1024)
local BackgroundColor = Color(.05, .05, .05)

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

    BackgroundColor:applyBackground()
    LogManager.draw()
end

function love.update(dt)
    LogManager.cleanup()
    LogManager.updateLog(love.timer.getFPS() .. " FPS", Color.Green)
    LogManager.updateLog("Position: " .. tostring(SquareOne.Position), Color.Green)
    LogManager.updateLog("Size: " .. tostring(SquareOne.Size), Color.Green)
    LogManager.updateLog("Rotation: " .. tostring(SquareOne.Rotation), Color.Green)
    LogManager.updateLog()
    LogManager.updateLog("Hi! :)", Color.White)

    if love.keyboard.isDown("up") then SquareOne.Size = SquareOne.Size + Vector2(100,100)*dt end
    if love.keyboard.isDown("down") then SquareOne.Size = SquareOne.Size - Vector2(100,100)*dt end
    
    local tick = love.timer.getTime()

    offx = math.sin(tick*1)*10
    offy = math.sin(tick*2)*10

    SquareOne.Position.X = ScreenSize.X/2 + offx
    SquareOne.Position.Y = ScreenSize.Y/2 + offy
    SquareOne.Rotation = math.sin(tick)*math.rad(20)
end