-- Libs
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Image = require("src/classes/Image")
local TextLabel = require("src/classes/TextLabel")

local Screen = require("src/libs/Rendering/Screen")
local Renderer = require("src/libs/Rendering/Renderer")
local Controls = require("src/libs/Controls")
local Input = require("src/libs/Input")

-- Settings
local Menu = Screen.new()
local Font = love.graphics.newFont("assets/Fonts/Comic.ttf", 120)
local curLetter, letterIndex= 0,0
local letters = "ABCDEFGHIJKLMNOPQSTUVWXYZ0123456789"
local Yellow = Color(1, 1, 0)

local Spacing = 80

Menu.ScoreToSave = 0

-- Objects
local DescriptionText = TextLabel(love.graphics.newFont("assets/Fonts/Comic.ttf", 40))
DescriptionText.Anchor = Vector2(0.5, 0.5)
DescriptionText.Position = Renderer.ScreenSize/2 + Vector2(0, -200)
DescriptionText:SetText("Entrez votre nom d'utilisateur !")
Menu.add(DescriptionText, -5)

local obj = {}
for i=1,3 do
    local x = i-2
    local DescriptionText = TextLabel(Font)
    DescriptionText.Anchor = Vector2(0.5, 0.5)
    DescriptionText.Position = Renderer.ScreenSize/2 + Vector2(x*Spacing, 0)
    DescriptionText:SetText("A")
    Menu.add(DescriptionText, -5)

    obj[i] = {obj = DescriptionText, val = 1}
end

local arrows = {}
arrows.up = Image("/assets/imgs/UpArrow.png")
arrows.up.Size = Vector2(75, 75)
arrows.up.Anchor = Vector2(.5, 1)
arrows.upPosition = Renderer.ScreenSize/2

arrows.down = Image("/assets/imgs/DownArrow.png")
arrows.down.Size = Vector2(75, 75)
arrows.down.Anchor = Vector2(.5, 0)
arrows.downPosition = Renderer.ScreenSize/2

Menu.add(arrows.up, 50)
Menu.add(arrows.down, 50)

-- Functions
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

function getHighscore()
    local r = {}
    local file = io.open("highscore", "r")
    local Data = file:read("*all") --love.filesystem.read("highscore")
    local DataTbl = split(Data, "\n")
    file:close()

    for i,v in pairs(DataTbl) do
        r[i] = {}
        r[i][1] = string.sub(v, 1, 3)
        r[i][2] = string.sub(v, 5)
    end
    return r
end

function postHighscore(t)
    table.sort(t, function(a,b) return tonumber(a[2]) > tonumber(b[2]) end)

    local str = ""
    local i = 0
    for _,v in pairs(t) do
        str = str .. ("\n%s-%s"):format(v[1], v[2])

        i = i + 1
        if i == 20 then break end
    end

    local txt = string.sub(str, 2)
    local file = io.open("highscore", "w+")
    file:write(txt)
    file:close()
end

function updateArrows()
    local posX = (curLetter-2) * Spacing

    arrows.upPosition = Renderer.ScreenSize/2 + Vector2(posX, -40)
    arrows.downPosition = Renderer.ScreenSize/2 + Vector2(posX, 60)
end

function changeletter(num)
    if curLetter and obj[curLetter] then
        obj[curLetter].obj.Color = Color.White
    end

    curLetter = math.min(math.max(num, 1), #obj)
    obj[curLetter].obj.Color = Yellow
    updateArrows()

    return curLetter == num
end

function modifyLetter(newindex)
    newindex = (newindex-1) % #letters + 1

    local chr = string.sub(letters, newindex, newindex)
    obj[curLetter].obj:SetText(chr)
    obj[curLetter].val = newindex

    local o = love.audio.newSource("assets/sounds/UI/back_00" .. math.random(1, 4) .. ".ogg", "static")
    o:setVolume(1)
    o:play()
end

function nextLetter()
    if changeletter(curLetter + 1) then
        local o = love.audio.newSource("assets/sounds/UI/select_003.ogg", "static")
        o:setVolume(1)
        o:play()
    else
        local o = love.audio.newSource("assets/sounds/UI/confirmMenu.ogg", "static")
        o:setVolume(1)
        o:play()

        local name = ""
        for _,v in pairs(obj) do
            name = name .. string.sub(letters, v.val, v.val) 
        end

        local t = getHighscore()
        table.insert(t, {name, Menu.ScoreToSave or 0})
        Menu.ScoreToSave = 0
        postHighscore(t)

        Renderer.changeScreen(Screen.get("Scores"))
    end
end

function lastLetter()
    if changeletter(curLetter - 1) then
        local o = love.audio.newSource("assets/sounds/UI/drop_003.ogg", "static")
        o:setVolume(1)
        o:play()
    end
end

function Validate()
    nextLetter()
end

-- // Runners
function Menu.open()
    changeletter(1)

    Controls.bind(Input.player1.up, function(isDown)
        if not isDown then return end
        
        modifyLetter(obj[curLetter].val+1)
    end)

    Controls.bind(Input.player1.down, function(isDown)
        if not isDown then return end
        modifyLetter(obj[curLetter].val-1)
    end)

    Controls.bind(Input.player1.button1, function(isDown)
        if not isDown then return end
        Validate()
    end)

    Controls.bind(Input.player1.right, function(isDown)
        if not isDown then return end
        Validate()
    end)

    Controls.bind(Input.player1.button3, function(isDown)
        if not isDown then return end
        lastLetter()
    end)

    Controls.bind(Input.player1.left, function(isDown)
        if not isDown then return end
        lastLetter()
    end)
end

function Menu.update(dt)
    local time = love.timer.getTime()
    local arrowOffset = Vector2(0, math.sin(time*6)*5)
    arrows.up.Position = arrows.upPosition + arrowOffset
    arrows.down.Position = arrows.downPosition - arrowOffset
end

function Menu.cleanup()
    Controls.unbind(Input.player1.up)
    Controls.unbind(Input.player1.down)
    Controls.unbind(Input.player1.right)
    Controls.unbind(Input.player1.left)
    Controls.unbind(Input.player1.button1)
    Controls.unbind(Input.player1.button3)
end

return Menu