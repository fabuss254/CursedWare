-- Libs
local Object = require("src/libs/Classic")
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Square = require("src/classes/Rect")
local Image = require("src/classes/Image")
local Quad = require("src/classes/Quad")

local Screen = require("src/libs/Rendering/Screen")
local Renderer = require("src/libs/Rendering/Renderer")
local LogManager = require("src/libs/Debug/LogManager")
local Controls = require("src/libs/Controls")
local Instance = require("src/libs/Instance")
local Input = require("src/libs/Input")

-- Settings
Menu = Screen.new()

local ColorNonSelected = Color(255, 255, 255)
local ColorSelected = Color(255, 255, 0)

-- Objects
local dDelta = 0
local SquareOne = Image("Logo.png")
SquareOne.Position = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*.3)
SquareOne.Size = Vector2(800, 800)
SquareOne.Anchor = Vector2(.5, .5)
Menu.add(SquareOne)

local Buttons = {
    ["Fab"] = Image("assets/imgs/Buttons/Fab.png"),
    ["Alexi"] = Image("assets/imgs/Buttons/Alexi.png"),
    ["Mehdi"] = Image("assets/imgs/Buttons/Mehdi.png"),
    ["Guigui"] = Image("assets/imgs/Buttons/Guigui.png"),
    ["Retour"] = Image("assets/imgs/Buttons/RETOUR.png"),
}

local Order = {"Fab", "Alexi", "Mehdi", "Guigui", "Retour"}
local Selected = 1

local num = 0
for i,ButtonName in pairs(Order) do
    local v = Buttons[ButtonName]
    v.Position = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*(.4 + i * .1))
    v.Size = Vector2(300, 100)
    v.Anchor = Vector2(.5, .5)
    v.Color = ColorNonSelected
    Menu.add(v)

    num = num + 1
end

local MusicSource = love.audio.newSource("assets/musics/Stairs.mp3", "static")
MusicSource:setLooping(true)
MusicSource:setVolume(0.1)

-- Functions
local function SelectionChanged(old)
    local o = love.audio.newSource("assets/sounds/UI/back_00" .. math.random(1, 4) .. ".ogg", "static")
    o:setVolume(1)
    o:play()

    local Button = Buttons[Order[old]]
    Button.Size = Vector2(300, 100)
    Button.Color = ColorNonSelected

    Button = Buttons[Order[Selected]]
    Button.Color = ColorSelected

    dDelta = 0
end

local functions = {}
local function OnClick()
    local o = love.audio.newSource("assets/sounds/UI/confirmMenu.ogg", "static")
    o:setVolume(1)
    o:play()

    if not functions[Order[Selected]] then return end
    functions[Order[Selected]]()
end

functions["Retour"] = function() 
    Renderer.changeScreen(Screen.get("Title"))
end

-- // Runners

function Menu.open()
    Selected = 1

    -- Binds

    Controls.bind(Input.player1.up, function(isDown)
        if not isDown then return end
        local oldS = Selected
        Selected = (Selected - 2) % (#Order) + 1
        SelectionChanged(oldS)
    end)

    Controls.bind(Input.player1.down, function(isDown)
        if not isDown then return end
        local oldS = Selected
        Selected = (Selected) % (#Order) + 1
        SelectionChanged(oldS)
    end)

    Controls.bind(Input.player1.button1, function(isDown)
        if not isDown then return end
        OnClick()
    end)
end

function Menu.update(dt)
    dDelta = dDelta + dt
    local Button = Buttons[Order[Selected]]
    Button.Size = Vector2(300 + math.sin(dDelta*5)*50, 100 - math.sin(dDelta*5)*10)
    Button.Color = ColorSelected

    -- LOGS

    LogManager.cleanup()
    LogManager.updateLog(love.timer.getFPS() .. " FPS", Color.Green)
end

function Menu.cleanup()
    for _,v in pairs(Buttons) do
        v.Color = ColorNonSelected
    end

    Controls.unbind(Input.player1.down)
    Controls.unbind(Input.player1.up)
    Controls.unbind(Input.player1.button1)
end

return Menu