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
    ["Play"] = Image("assets/imgs/Buttons/JOUER.png"),
    ["Credits"] = Image("assets/imgs/Buttons/CREDIT.png"),
    ["Scores"] = Image("assets/imgs/Buttons/SCORE.png"),
    ["Quit"] = Image("assets/imgs/Buttons/QUITTER.png"),
}

local Order = {"Play", "Scores", "Credits", "Quit"}
local Selected = 1

local num = 0
for i,ButtonName in pairs(Order) do
    local v = Buttons[ButtonName]
    v.Position = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*(.5 + i * .1))
    v.Size = Vector2(350, 125)
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
    Button.Size = Vector2(350, 125)
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

    functions[Order[Selected]]()
end

functions["Play"] = function() 
    Renderer.changeScreen(Screen.get("Selection"))
end

functions["Scores"] = function() 
    Renderer.changeScreen(Screen.get("Scores"))
end

functions["Credits"] = function() 
    Renderer.changeScreen(Screen.get("Credits"))
end

functions["Quit"] = function() 
    love.event.quit(0)
end

-- // Runners

function Menu.open()
    Selected = 1
    MusicSource:play()

    -- Binds

    Controls.bind(Input.player1.up, function(isDown)
        if not isDown then return end
        local oldS = Selected
        Selected = (Selected + 2) % #Order + 1
        SelectionChanged(oldS)
    end)

    Controls.bind(Input.player1.down, function(isDown)
        if not isDown then return end
        local oldS = Selected
        Selected = (Selected) % #Order + 1
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
    Button.Size = Vector2(350 + math.sin(dDelta*5)*100, 125 - math.sin(dDelta*5)*10)
    Button.Color = ColorSelected

    -- LOGS

    LogManager.cleanup()
    LogManager.updateLog(love.timer.getFPS() .. " FPS", Color.Green)
end

function Menu.cleanup()
    MusicSource:stop()

    for _,v in pairs(Buttons) do
        v.Color = ColorNonSelected
    end

    Controls.unbind(Input.player1.up)
    Controls.unbind(Input.player1.down)
    Controls.unbind(Input.player1.button1)
end

return Menu