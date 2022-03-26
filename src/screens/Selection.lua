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

local Definition = {
    {
        Color = Color.fromRGB(255, 195, 92),
        Title = "Type",
        Default = 1,
        Items = {
            {"Solo", "Jouer tout seul.", function(v) v.NumberOfPlayers = 1 end},
            {"Versus", "Jouer contre quelqu'un. (désactive le tableau des scores)", function(v) v.NumberOfPlayers = 2 v.ScoreEnabled = false end}
        }
    },
    {
        Color = Color.fromRGB(255, 125, 92),
        Title = "Vitesse",
        Default = 2,
        Items = {
            {"Tutoriel", "Vitesse lente. (+10% par niveau, Multiplicateur de score: -0.5)", function(v) v.ScoreMultiplier = v.ScoreMultiplier - .5 v.SpeedFactor = 0.1 v.DifficultyIncrease = 0.1 end},
            {"Normale", "Vitesse normale. (+25% par niveau, Multiplicateur de score: +0)", function(v) end},
            {"Express", "Vitesse accrue. (+50% par niveau, Multiplicateur de score: +0.3)", function(v) v.ScoreMultiplier = v.ScoreMultiplier + .3 v.SpeedFactor = 0.5 v.DifficultyIncrease = 0.4 end},
            {"Extreme", "Vitesse extreme. (+100% par niveau, Multiplicateur de score: +0.4)", function(v) v.ScoreMultiplier = v.ScoreMultiplier + .4 v.SpeedFactor = 1 v.DifficultyIncrease = 0.8 end}
        }
    },
    {
        Color = Color.fromRGB(255, 92, 92),
        Title = "Extra",
        Default = 1,
        Items = {
            {"Aucun", "L'expérience CursedWare de base.", function(v) end},
            {"Hardcore", "Ce mode apporte plusieurs modifications au jeu:\n - Vous commencez à la vitesse x2.\n - La difficulté des mini-jeux est au maximum.\n - Multiplicateur de score: +0.5.", function(v) v.StartDifficulty = 10 v.StartSpeed = 2 v.ScoreMultiplier = v.ScoreMultiplier + 0.5 end},
            {"Sonic", "La vitesse augmentera A CHAQUE MINI-JEU.\nATTENTION: désactive le tableau des scores.", function(v) v.ScoreEnabled = false v.GamesBeforeSpeedup = 1 end},
            {"Mort instantanée", "A la moindre erreur, c'est la mort. (Multiplicateur de score: +0.3)", function(v) v.ScoreMultiplier = v.ScoreMultiplier + .3 v.NumberOfLives = 1 end},
        }
    }
}
local Selections = {}

-- Scene constructor
local Font = love.graphics.newFont("assets/Fonts/Comic.ttf", 40)
local FontBig = love.graphics.newFont("assets/Fonts/Comic.ttf", 80)

local DescriptionText = TextLabel(Font)
DescriptionText.Anchor = Vector2(0, 0)
DescriptionText.Position = Vector2(10, Renderer.ScreenSize.Y*.75)
DescriptionText.Scale = 0.8
DescriptionText:SetText("Description: XXXXX")
Menu.add(DescriptionText, -5)

-- Construct background
local Count = #Definition
local Elements = {}
local curItem = 0
local curColumn = 0

local size = Renderer.ScreenSize.X*1/Count
for i=1, Count do
    local pos = size * i

    local b = Square()
    b.Anchor = Vector2(1, 0)
    b.Size = Vector2(size, Renderer.ScreenSize.Y*.75)
    b.Position = Vector2(pos, 0)
    b.Color = Definition[i].Color:lerp(Color.Black, .4)
    Menu.add(b, 0)
    
    local t = TextLabel(FontBig)
    t.Anchor = Vector2(0.5, 0)
    t.Position = Vector2(pos - size/2, Renderer.ScreenSize.Y*.05)
    t.Opacity = 0.5
    t:SetText(Definition[i].Title)
    Menu.add(t, 5)

    local items = {}
    for item=1, #Definition[i].Items do
        local d = item - Definition[i].Default
        local t = TextLabel(Font)
        t.Anchor = Vector2(0.5, 0)
        t.Position = Vector2(pos - size/2, Renderer.ScreenSize.Y*(.5 + (d-1)/20))
        t.Opacity = item == Definition[i].Default and 0 or 0.5
        t:SetText(Definition[i].Items[item][1])
        Menu.add(t, 5)

        items[item] = t
    end

    Elements[i] = {
        title = t,
        background = b,
        items = items
    }
end

local arrows = {}
arrows.up = Image("/assets/imgs/UpArrow.png")
arrows.up.Size = Vector2(50, 50)
arrows.up.Anchor = Vector2(.5, 1)
arrows.upPosition = Renderer.ScreenSize/2

arrows.down = Image("/assets/imgs/DownArrow.png")
arrows.down.Size = Vector2(50, 50)
arrows.down.Anchor = Vector2(.5, 0)
arrows.downPosition = Renderer.ScreenSize/2

Menu.add(arrows.up, 50)
Menu.add(arrows.down, 50)

for i,v in pairs(Definition) do
    Selections[i] = v.Default
end

-- // Functions
local function resetGAME(v)
    v.GamesBeforeSpeedup = 5 -- How much game before we spice the game up !
    v.DifficultyIncrease = .2 -- Increase difficulty by this factor each game, Difficulty will be round to the lowest integer if it's a decimal.
    v.SpeedFactor = .25 -- How much do we increase the speed by each stages.
    v.MusicSpeedMult = .25 -- How much will the music's speed increase each stage
    
    v.NumberOfLives = 3 -- If you fall at 0, it's the end!
    v.NumberOfPlayers = 1 -- Number of players
    
    v.ScoreEnabled = true
    v.ScoreMultiplier = 1 -- Score multiplier (score is rounded to highest integer)
    v.StartSpeed = 1 -- Default speed
    v.StartDifficulty = 1 -- Default difficulty
end

local function updateArrowsALLO()
    local posX = Elements[curColumn].title.Position.X

    arrows.upPosition = Vector2(posX, Renderer.ScreenSize.Y*(.5 + (-#Elements[curColumn].items)/20))
    arrows.downPosition = Vector2(posX, Renderer.ScreenSize.Y*(.5 + (#Elements[curColumn].items-1)/20))
end

local function updateDescription()
    DescriptionText:SetText("Description: " .. Definition[curColumn].Items[curItem][2])
end

local function changeColumn(num)
    if curColumn ~= 0 and curColumn <= Count then
        local e = Elements[curColumn]
        local finalColor = Definition[curColumn].Color:lerp(Color.Black, 0.2)
        Tween.new(.2, e.background.Color, {R = finalColor.R, G = finalColor.G, B = finalColor.B}, "linear"):play()
        Tween.new(.2, e.title, {Opacity = 0.5}, "linear"):play()
    end

    if num > Count then
        curColumn = num

        local screen = Screen.get("GAME")
        --screen.NumberOfPlayers = 
        resetGAME(screen)
        for i,v in pairs(Selections) do
            Definition[i].Items[v][3](screen)
        end

        Renderer.changeScreen(Screen.get("Pause"))
        return
    end

    local e = Elements[num]
    local finalColor = Definition[num].Color
    Tween.new(.2, e.background.Color, {R = finalColor.R, G = finalColor.G, B = finalColor.B}, "linear"):play()
    Tween.new(.2, e.title, {Opacity = 0}, "linear"):play()

    curItem = Selections[num]
    curColumn = num
    updateArrowsALLO()
    updateDescription()

    return true
end

local function selectItem(ItemId)
    if curColumn > Count then return end
    local e = Elements[curColumn]
    ItemId = math.min(math.max(ItemId, 1), #e.items)
    if ItemId == curItem then return end

    for i, v in pairs(e.items) do
        local d = i - ItemId

        local endPos = Vector2(v.Position.X, Renderer.ScreenSize.Y*(.5 + (d-1)/20))
        Tween.new(.2, v.Position, {X = endPos.X, Y = endPos.Y}, "outBack"):play()
        --v.Position = Vector2(v.Position.X, Renderer.ScreenSize.Y*(.5 + (d-1)/20))
        v.Opacity = i == ItemId and 0 or 0.5
    end

    local o = love.audio.newSource("assets/sounds/UI/back_00" .. math.random(1, 4) .. ".ogg", "static")
    o:setVolume(1)
    o:play()

    curItem = ItemId
    updateDescription()
end

local function validateItem()
    Selections[curColumn] = curItem
    if changeColumn(curColumn+1) then
        local o = love.audio.newSource("assets/sounds/UI/select_003.ogg", "static")
        o:setVolume(1)
        o:play()
    else
        local o = love.audio.newSource("assets/sounds/UI/confirmMenu.ogg", "static")
        o:setVolume(1)
        o:play()
    end
end

local function back()
    if curColumn == 1 then return end
    local o = love.audio.newSource("assets/sounds/UI/drop_003.ogg", "static")
    o:setVolume(1)
    o:play()

    Selections[curColumn] = curItem
    changeColumn(curColumn-1)
end

-- // Runners

function Menu.open()
    changeColumn(1)

    Controls.bind(Input.player1.up, function(isDown)
        if not isDown then return end
        selectItem(curItem - 1)
    end)

    Controls.bind(Input.player1.down, function(isDown)
        if not isDown then return end
        selectItem(curItem + 1)
    end)

    Controls.bind(Input.player1.button1, function(isDown)
        if not isDown then return end
        validateItem()
    end)

    Controls.bind(Input.player1.right, function(isDown)
        if not isDown then return end
        validateItem()
    end)

    Controls.bind(Input.player1.left, function(isDown)
        if not isDown then return end
        back()
    end)

    Controls.bind(Input.player1.button3, function(isDown)
        if not isDown then return end
        back()
    end)
end

function Menu.update(dt)
    local time = love.timer.getTime()
    local arrowOffset = Vector2(0, math.sin(time*6)*5)
    arrows.up.Position = arrows.upPosition + arrowOffset
    arrows.down.Position = arrows.downPosition - arrowOffset

    -- LOGS

    LogManager.cleanup()
    LogManager.updateLog(love.timer.getFPS() .. " FPS", Color.Green)
end

function Menu.cleanup()
    --MusicSource:stop()
    Controls.unbind(Input.player1.up)
    Controls.unbind(Input.player1.down)
    Controls.unbind(Input.player1.left)
    Controls.unbind(Input.player1.right)
    Controls.unbind(Input.player1.button1)
    Controls.unbind(Input.player1.button3)
end

return Menu