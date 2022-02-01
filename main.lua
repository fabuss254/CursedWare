-- Libs
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Renderer = require("src/libs/Rendering/Renderer")
local LogManager = require("src/libs/Debug/LogManager")
local Screen = require("src/libs/Rendering/Screen")

local TweenService = require("src/libs/Tween")
local DelayService = require("src/libs/Delay")

-- Settings
Renderer.ScreenSize = Vector2(1280, 1024)
Renderer.BackgroundColor = Color(.075, .075, .075)
Renderer.CurrentScreen = Screen.get("GAME")

-- Functions
function love.load()
    math.randomseed(love.timer.getTime())
    love.window.setMode(Renderer.ScreenSize.X, Renderer.ScreenSize.Y, {resizable=false, vsync=false, borderless=true})

    Renderer.CurrentScreen.open()
    Renderer.add(Renderer.CurrentScreen)
end

function love.update(dt)
    Renderer.update(dt)
    Renderer.CurrentScreen.update(dt)
    TweenService.StaticUpdate(dt)
    DelayService.StaticUpdate(dt)

    -- LOGS

    LogManager.cleanup()
    LogManager.updateLog(love.timer.getFPS() .. " FPS", Color.Green)
end