-- Libs
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Spritesheet = require("src/classes/Spritesheet")

local Screen = require("src/libs/Rendering/Screen")
local Renderer = require("src/libs/Rendering/Renderer")

-- Settings
local Menu = Screen.new("TestIntermission")

-- Objects
local Animation = Spritesheet("assets/spritesheets/IntermissionSpeakers.png", Vector2(320, 256), 1)
Animation.Size = Renderer.ScreenSize
Menu.add(Animation)

-- // Runners
function Menu.open()
    openTime = love.timer.getTime()
end

local LastFrame = love.timer.getTime()
function Menu.update(dt)
    if love.timer.getTime() - LastFrame < 1/45 then return end
    LastFrame = love.timer.getTime()
    Animation.CurrentFrame = ((Animation.CurrentFrame + 1)%#Animation.Quads) + 1
end

return Menu