-- Libs
local Object = require("src/libs/Classic")
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Square = require("src/classes/Rect")
local Image = require("src/classes/Image")
local Quad = require("src/classes/Quad")

local Renderer = require("src/libs/Rendering/Renderer")
local LogManager = require("src/libs/Debug/LogManager")
local Controls = require("src/libs/Controls")
local Instance = require("src/libs/Instance")

-- Settings
Renderer.ScreenSize = Vector2(1280, 1024)
Renderer.BackgroundColor = Color(.075, .075, .075)

-- Objects
local SquareOne = Image("Logo.png")
SquareOne.Position = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*.3)
SquareOne.Size = Vector2(800, 800)
SquareOne.Anchor = Vector2(.5, .5)
Renderer.add(SquareOne)

local buttons = {
    ["Play"] = Image("assets/imgs/Buttons/JOUER.png"),
    ["Credits"] = Image("assets/imgs/Buttons/CREDIT.png"),
    ["Quit"] = Image("assets/imgs/Buttons/QUITTER.png"),
}

local Order = {"Play", "Credits", "Quit"}
local Selected = 1

local num = 0
for i,ButtonName in pairs(Order) do
    local v = buttons[ButtonName]
    v.Position = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*(.5 + i * .125))
    v.Size = Vector2(400, 150)
    v.Anchor = Vector2(.5, .5)
    Renderer.add(v)

    num = num + 1
end

Controls.bind("up", function(isDown)
    if not isDown then return end
    Selected = (Selected + 1) % 3 + 1
    SelectionChanged()
end)

Controls.bind("down", function(isDown)
    if not isDown then return end
    Selected = (Selected - 2) % 3 + 1
    SelectionChanged()
end)

-- Functions
function SelectionChanged()
    local Button = 
end

local Shader3dRays
function love.load()
    love.window.setMode(Renderer.ScreenSize.X, Renderer.ScreenSize.Y, {resizable=false, vsync=false, borderless=true})
end

local b = 0
function love.update(dt)

    -- LOGS

    LogManager.cleanup()
    LogManager.updateLog(love.timer.getFPS() .. " FPS", Color.Green)
end