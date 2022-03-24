-- Libs
local Object = require("src/libs/Classic")
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Square = require("src/classes/Rect")
local Image = require("src/classes/Image")
local Quad = require("src/classes/Quad")
local TextLabel = require("src/classes/TextLabel")

local Screen = require("src/libs/Rendering/Screen")
local Renderer = require("src/libs/Rendering/Renderer")
local LogManager = require("src/libs/Debug/LogManager")
local Controls = require("src/libs/Controls")
local Instance = require("src/libs/Instance")
local Input = require("src/libs/Input")
local Tween = require("src/libs/Tween")

-- Settings
Menu = Screen.new()

function split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

-- Scene constructor
local Font = love.graphics.newFont("assets/Fonts/Comic.ttf", 60)

local DescriptionText = TextLabel(love.graphics.newFont("assets/Fonts/Comic.ttf", 80))
DescriptionText.Anchor = Vector2(0.5, 0)
DescriptionText.Position = Vector2(Renderer.ScreenSize.X*.5, 20)
DescriptionText:SetText("Tableau des scores")
Menu.add(DescriptionText, 5)

local t = Square()
t.Anchor = Vector2(0.5, 0)
t.Color = Color.fromRGB(19, 19, 19)
t.Position = Vector2(Renderer.ScreenSize.X / 2, 0)
t.Size = Vector2(40, Renderer.ScreenSize.Y*1)
Menu.add(t, 2)

local Objs = {}
for i=1, 20 do
    local Y = i < 11 and (.2 + (i*0.07)) or (.2 + ((i-10)*0.07))
    local X = i < 11 and 0 or Renderer.ScreenSize.X*0.52
    local C = Color.fromRGB(255, 251, 140):lerp(Color.White, i/5):lerp(Color.Black, (i-5)/30)

    Objs[i] = {}
    --local Username = DataTbl[i] and DataTbl[i][1] or "???"
    --local Score = DataTbl[i] and DataTbl[i][2] .. " pts" or ("0 pts")

    if i%2 == 1 and i < 11 then
        local t = Square()
        t.Opacity = 0.95
        t.Anchor = Vector2(0, 0.5)
        t.Position = Vector2(0, Renderer.ScreenSize.Y*Y - 5)
        t.Size = Vector2(Renderer.ScreenSize.X, Renderer.ScreenSize.Y*0.07)
        Menu.add(t, -10)
    end

    local t = TextLabel(Font)
    t.Anchor = Vector2(0, 0.5)
    t.Position = Vector2(X + 10, Renderer.ScreenSize.Y*Y)
    t.Scale = 0.8
    t.Color = C
    t:SetText(i .. ".")
    Menu.add(t, -5)

    local t = TextLabel(Font)
    t.Anchor = Vector2(0.5, 0.5)
    t.Position = Vector2(X + Renderer.ScreenSize.X*.2, Renderer.ScreenSize.Y*Y)
    t.Scale = 0.8
    t.Color = C
    t:SetText("???")
    Objs[i][1] = t
    Menu.add(t, -5)

    local t = TextLabel(Font)
    t.Anchor = Vector2(1, .5)
    t.Position = Vector2(X + Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*Y)
    t.Scale = 0.8
    t.Color = C
    Objs[i][2] = t
    t:SetText("x pts")
    Menu.add(t, -5)
end

-- // Runners

function Menu.open()
    for i=1,6 do
        Controls.bind(Input.player1["button" .. i], function(isDown)
            if not isDown then return end
            Renderer.changeScreen(Screen.get("Title"))
        end)
    end
    
    local file = io.open("highscore", "r")
    local Data = file:read("*all")
    local DataTbl = split(Data, "\n")
    file:close()
    
    for i,v in pairs(DataTbl) do
        Objs[i][1]:SetText(string.sub(v, 1, 3))
        Objs[i][2]:SetText(string.sub(v, 5) .. " pts")
    end
end

function Menu.update(dt)

    -- LOGS

    LogManager.cleanup()
    LogManager.updateLog(love.timer.getFPS() .. " FPS", Color.Green)
end

function Menu.cleanup()
    for i=1,6 do
        Controls.unbind(Input.player1["button" .. i])
    end
    
end

return Menu