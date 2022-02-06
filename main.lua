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
Renderer.CurrentScreen = nil

-- Math lib overwrite
function math.clamp(Origin, Min, Max)
    return math.min(math.max(Origin, Min), Max)
end

-- Functions
function love.load()
    math.randomseed(love.timer.getTime())
    love.window.setMode(Renderer.ScreenSize.X, Renderer.ScreenSize.Y, {resizable=false, vsync=false, borderless=false})

    -- WARNING !!! There is a bug if you directly want to get on the GAME screen. If you do so, You won't be able to restart through menu.
    Renderer.changeScreen(Screen.get("GAME")) -- Here you can input a screen's name in [src/screens/...], for example "Title", "Test" or "GAME"
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