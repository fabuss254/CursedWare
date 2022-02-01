-- // Libs
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Square = require("src/classes/Rect")
local Image = require("src/classes/Image")
local Quad = require("src/classes/Quad")
local Spritesheet = require("src/classes/Spritesheet")
local TextLabel = require("src/classes/TextLabel")
local ShakingText = require("src/classes/advanced/ShakingText")

local Screen = require("src/libs/Rendering/Screen")
local Renderer = require("src/libs/Rendering/Renderer")
local LogManager = require("src/libs/Debug/LogManager")
local Controls = require("src/libs/Controls")
local Instance = require("src/libs/Instance")

local TweenService = require("src/libs/Tween")
local DelayService = require("src/libs/Delay")

-- // Mandatory screen declaration
Menu = Screen.new()

-- // Settings | DEFAULT SETTINGS
Menu.GamesBeforeSpeedup = 5 -- How much game before we spice the game up !
Menu.DifficultyIncrease = .1 -- Increase difficulty by this factor each game, Difficulty will be round to the lowest integer if it's a decimal.
Menu.SpeedFactor = 1.1 -- How much do we increase the speed by each stages.

Menu.NumberOfLives = 3 -- If you fall at 0, it's the end!
Menu.NumberOfPlayers = 1 -- Number of players

Menu.Musics = {
    ["Stages/VHS-HeadBody.mp3"] = {Name = "Head Body", Author = "VHS", Stage = 1, BaseVolume = 1, BPM = 114}
}

-- These settings below shouldn't be modified on runtime
local FadeInDuration = 5
local FadeOutDuration = 2

local TextActive = Color(1, 1, 1)
local TextGood = Color(66/255, 1, 98/255)
local TextBad = Color(1, 66/255, 66/255)

local Keybinds = {
    up = {"up", "o"},
    down = {"down", "l"},
    right = {"right", "m"},
    left = {"left", "k"},
}

-- // Objects
Menu.GAME = { -- MAIN GAME OBJECT
    Stage = 1,
    StageMusic = nil,

    CurrentSpeed = 1,
    CurrentDifficulty = 1,
}

-- // SETUP
local Animation = Spritesheet("assets/spritesheets/IntermissionSpeakers.png", Vector2(320, 256), 2)
Animation.Anchor = Vector2(.5, 1)
Menu.add(Animation, -5)

local Font = love.graphics.newFont("assets/Fonts/Platinum Sign Over.ttf", 50)
local MainText = ShakingText(Font)
MainText.Position = Renderer.ScreenSize/2
MainText.Anchor = Vector2(.5, .5)
MainText:SetText("")
MainText.Color = TextActive
Menu.add(MainText, 99999999)

local GameScreen = Image("assets/imgs/GameScreen.png")
GameScreen.Position = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*1.5)
GameScreen.Size = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*.5)
GameScreen.Anchor = Vector2(.5, .5)
Menu.add(GameScreen, 10)

local TEST_Texts = {
    "SAMPLE TEXT",
    "YOU GOT BIG BONES",
    "SOUKA BLYAT",
    "THIS IS A VERY \nVERY\nVERY\nVERY\nVERY\nUSELESS SENTENCE",
    "AMERICA \nFUCK YEAH !",
    "COPY THE MOVES OF THIS IDIOT!"
}

local Game_Started = false
local NextStep, Minigames

-- // Functions
function getMinigames()
    local Minigames = {}
    for _,v in pairs(love.filesystem.getDirectoryItems("minigames/")) do
        local mod = require("minigames/" .. v .. "/game")
        if mod.IsActive then
            mod.Directory = "minigames/" .. v
            Minigames[v] = mod
        end
    end

    return Minigames
end

function ChooseMinigame()
    if not Minigames then Minigames = getMinigames() end

    local o = {}
    for i,_ in pairs(Minigames) do
        table.insert(o, i)
    end
    return Minigames[o[math.random(1, #o)]]
end

function getCurrentMusic(Stage)
    Stage = Stage or Menu.GAME.Stage

    local AllowedMusics = {}
    for i,v in pairs(Menu.Musics) do
        if not v.Link then
            v.Link = i
        end

        if v.Stage == Stage then
            table.insert(AllowedMusics, v)
        end
    end

    if #AllowedMusics == 0 then
        if Stage == Menu.GAME.Stage then print("\x1B[31m[WARNING] No music for stage " .. Stage .. " found! Using lower stage's music.\x1B[0m") end

        return getCurrentMusic(Stage-1) 
    end

    return AllowedMusics[math.random(1, #AllowedMusics)]
end

function FadeMusic(Duration, End)
    local t = TweenService.new(Duration, {a=Menu.GAME.StageMusic.Source:getVolume()}, {a=End}, 'inOutSine')
    t.onUpdate = function(s)
        Menu.GAME.StageMusic.Source:setVolume(s.a)
        if s.a <= 0.01 then return Menu.GAME.StageMusic.Source:pause() 
        else Menu.GAME.StageMusic.Source:play() end
    end
    t:play()
end

function popScreenIN()
    GameScreen.Position = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*1.5)
    TweenService.new(1, GameScreen.Position, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y*.5}, 'outSine'):play()
    TweenService.new(1.5, MainText.Position, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y}, 'outSine'):play()
    TweenService.new(1.5, MainText.Anchor, {X = .5, Y = 1}, 'outSine'):play()
    TweenService.new(1.5, MainText, {Scale = .8}, 'outSine'):play()
    TweenService.new(1, MainText, {Opacity = .5}, 'linear'):play()

    DelayService.new(0.7, function()
        TweenService.new(1, GameScreen.Size, {X = Renderer.ScreenSize.X+80, Y = Renderer.ScreenSize.Y+64}, 'inOutSine'):play()

        FadeMusic(1, 0)
        DelayService.new(1.1, function()
            Menu.rem(Animation)
            Menu.rem(GameScreen)

            Menu.GAME.CurrentMinigame:_PreStart()
            Menu.GAME.CurrentMinigame:Start()

            Menu.GAME.CurrentMinigame._Started = true
            
        end)
    end)
end

function popScreenOUT()
    TweenService.new(1, GameScreen.Size, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y*.5}, 'inOutSine'):play()
    TweenService.new(1.5, MainText.Position, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y*.5}, 'outSine'):play()
    TweenService.new(1.5, MainText.Anchor, {X = .5, Y = .5}, 'outSine'):play()
    TweenService.new(1.5, MainText, {Scale = 1}, 'outSine'):play()
    TweenService.new(1, MainText, {Opacity = 0}, 'linear'):play()

    FadeMusic(1, 1)
    DelayService.new(0.7, function()
        TweenService.new(1, GameScreen.Position, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y*-1.5}, 'inOutSine'):play()
    end)
end

function skip_intro()
    Menu.GAME.StageMusic.Source:seek(30, "seconds")
    MainText:SetText("BONNE CHANCE !")

    local Original = {R = Renderer.BackgroundColor.R, G=Renderer.BackgroundColor.G, B=Renderer.BackgroundColor.B}
    Renderer.BackgroundColor = Color(.5, .5, .5)
    TweenService.new(.3, Renderer.BackgroundColor, {R=Original.R, G=Original.G, B=Original.B}, 'linear'):play()
end

function Intro()
    local curBeat = Menu.GAME.StageMusic.Beat

    if curBeat == 0 then
        MainText:SetText("BIENVENUE DANS CURSEDWAVE !")
    elseif curBeat == 6 then
        MainText:SetText("LE BUT DU JEU EST DE SURVIVRE\n LE PLUS LONGTEMP POSSIBLE")
    elseif curBeat == 12 then
        MainText:SetText("TOUT LES " .. Menu.GamesBeforeSpeedup .. " JEUX\nLA DIFFICULTE AUGMENTERA")
    elseif curBeat == 18 then
        MainText:SetText("VOUS POSSEDER " .. Menu.NumberOfLives .. " VIES\n0 VIE ET C'EST LE GAME OVER")
    elseif curBeat == 24 then
        MainText:SetText("SUIVEZ LES INSTRUCTIONS POUR\nGAGNER LES DIFFERENTS JEUX")
    elseif curBeat == 30 then
        MainText:SetText("BONNE CHANCE !")
    end
end

function PreSetupMinigame(self, PlayerID)
    self._Cache = {Binds = {}, Objs = {}}
    self._Started = false
    self.PlayerID = PlayerID

    -- Boundaries
    self.BoundPos = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y* ((Menu.NumberOfPlayers == 1 and .5) or (Menu.NumberOfPlayers == 2 and (PlayerID == 1 and .25 or .75))))
    self.BoundSize = Vector2(Renderer.ScreenSize.X, Renderer.ScreenSize.Y*.5)

    self.PlayMusic = function(MusicFolder)
        self._MusicSource = love.audio.newSource(MusicFolder, "static")
        self._MusicSource:setLooping(true)
        self._MusicSource:setVolume(1)
        self._MusicSource:play()
    end

    self.BindKey = function(Key, FN)
        Key = Key:lower()
        if not Keybinds[Key] then error("No keybind named '" .. Key .. "' found !") end

        self._Cache.Binds[Keybinds[Key][PlayerID]] = FN
    end

    self.add = function(Obj, ZIndex)
        table.insert(self._Cache.Objs, Obj)
    end

    self._PreStart = function()
        for i,Obj in pairs(self._Cache.Objs) do
            Menu.add(Obj, ZIndex)
        end
        for i,FN in pairs(self._Cache.Binds) do
            print("BIND", i)
            Controls.bind(i, FN)
        end
    end

    self._PreCleanup = function()
        for i,_ in pairs(self._Cache.Objs) do
            Menu.rem(Obj)
        end
        for i,_ in pairs(self._Cache.Binds) do
            Controls.unbind(i)
        end
    end
end

function step()
    if Menu.GAME.StageMusic.Beat < 31 and Menu.GAME.StageMusic.Stage == 1 then return Intro() end

    if not Game_Started then
        Game_Started = true
        TweenService.new(1, Animation.Position, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y}, 'inOutSine'):play()
        DelayService.new(0.5, function()
            TweenService.new(1, Animation.Size, {X = Renderer.ScreenSize.X, Y = Renderer.ScreenSize.Y}, 'inOutSine'):play()
        end)
        
    end

    if not NextStep then
        Menu.GAME.CurrentMinigame = ChooseMinigame().new()
        PreSetupMinigame(Menu.GAME.CurrentMinigame, 1)
        Menu.GAME.CurrentMinigame:Setup()
    end

    MainText:SetText(Menu.GAME.CurrentMinigame:GetObjective():upper())
    NextStep = NextStep or Menu.GAME.StageMusic.Beat + 7
    if Menu.GAME.StageMusic.Beat == NextStep and not Menu.GAME.CurrentMinigame._ScreenOn then
        Menu.GAME.CurrentMinigame._ScreenOn = true
        popScreenIN()
    end
end

-- // Runners

local curTime = 0
local ScreenPopped = false
local ScreenPOUT = false
function Menu.open()
    startTick = 0
    game_started = false
    NextStep = nil

    Animation.Position = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*1.5)
    Animation.Size = Renderer.ScreenSize*.8

    Menu.GAME.StageMusic = getCurrentMusic(Stage)
    Menu.GAME.StageMusic.Beat = -1
    Menu.GAME.StageMusic.Source = love.audio.newSource("/assets/musics/" .. Menu.GAME.StageMusic.Link, "static")
    Menu.GAME.StageMusic.Source:setLooping(false)
    Menu.GAME.StageMusic.Source:setVolume(0)
    Menu.GAME.StageMusic.Source:play()

    FadeMusic(1, 1)
    DelayService.new(3, function()
        skip_intro()
    end)

    Animation:play()
    Animation:setDuration((Menu.GAME.StageMusic.BPM/60)*0.55)
end

function Menu.update(dt)
    curTime = curTime + dt

    local dahBeat = math.floor(Menu.GAME.StageMusic.Source:tell("seconds")/(Menu.GAME.StageMusic.BPM/60/1.8))
    if dahBeat ~= Menu.GAME.StageMusic.Beat then
        Menu.GAME.StageMusic.Beat = dahBeat
        print("BEAT !", Menu.GAME.StageMusic.Beat, " | ", Menu.GAME.StageMusic.Source:tell("seconds"))

        step()
    end

    if Menu.GAME.CurrentMinigame and Menu.GAME.CurrentMinigame._Started then
        Menu.GAME.CurrentMinigame:Update(dt)
    end
end

function Menu.cleanup()

end

return Menu