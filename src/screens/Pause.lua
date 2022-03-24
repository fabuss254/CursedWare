-- Libs
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Image = require("src/classes/Image")

local Screen = require("src/libs/Rendering/Screen")
local Renderer = require("src/libs/Rendering/Renderer")

-- Settings
local Menu = Screen.new()

-- Variables
local openTime = 0

-- Objects
local SquareOne = Image("Logo.png")
SquareOne.Position = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*.5)
SquareOne.Size = Vector2(800, 800)
SquareOne.Anchor = Vector2(.5, .5)
Menu.add(SquareOne)

-- // Runners
function Menu.open()
    openTime = love.timer.getTime()
end

function Menu.update(dt)
    if love.timer.getTime() - openTime < 2 then return end

    Renderer.changeScreen(Screen.get("GAME"))
end

return Menu