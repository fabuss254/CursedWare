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
Menu.SpeedFactor = .1 -- How much do we increase the speed by each stages.

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

    CurrentSpeed = 1.5,
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

local BombImg = Image("assets/imgs/bomb.png")
BombImg.Anchor = Vector2(0, 1)
BombImg.Size = Vector2(125, 125)
BombImg.Position = Vector2(-10, Renderer.ScreenSize.Y-10)

local BombText = TextLabel(love.graphics.newFont("assets/Fonts/DagestaN.ttf", 40))
BombText.Anchor = Vector2(.5, .5)
BombText.Position = Vector2(68, Renderer.ScreenSize.Y-52)
BombText:SetText("88.8")

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
    TweenService.new(1/Menu.GAME.CurrentSpeed, GameScreen.Position, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y*.5}, 'outSine'):play()
    TweenService.new(1.5/Menu.GAME.CurrentSpeed, MainText.Position, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y}, 'inOutSine'):play()
    TweenService.new(1.5/Menu.GAME.CurrentSpeed, MainText.Anchor, {X = .5, Y = 1}, 'outSine'):play()
    TweenService.new(1.5/Menu.GAME.CurrentSpeed, MainText, {Scale = .8}, 'outSine'):play()
    TweenService.new(1/Menu.GAME.CurrentSpeed, MainText, {Opacity = .5}, 'linear'):play()

    DelayService.new(0.7/Menu.GAME.CurrentSpeed, function()
        TweenService.new(1/Menu.GAME.CurrentSpeed, GameScreen.Size, {X = Renderer.ScreenSize.X+80, Y = Renderer.ScreenSize.Y+64}, 'inOutSine'):play()

        FadeMusic(1/Menu.GAME.CurrentSpeed, 0)
        DelayService.new(1.1/Menu.GAME.CurrentSpeed, function()
            Menu.rem(Animation)
            Menu.rem(GameScreen)

            Menu.GAME.CurrentMinigame:_PreStart()
            Menu.GAME.CurrentMinigame:Start()

            if Menu.GAME.OtherMinigame then
                Menu.GAME.OtherMinigame:_PreStart()
                Menu.GAME.OtherMinigame:Start()
            end

            Menu.GAME.CurrentMinigame.MaxTime = Menu.GAME.CurrentMinigame:GetTime()
            Menu.GAME.CurrentMinigame._Started = love.timer.getTime()

            Menu.add(BombImg, 99999999)
            Menu.add(BombText, 100000000)
        end)
    end)
end

function popScreenOUT()
    TweenService.new(1/Menu.GAME.CurrentSpeed, GameScreen.Size, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y*.5}, 'inOutSine'):play()
    TweenService.new(1.5/Menu.GAME.CurrentSpeed, MainText.Position, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y*.5}, 'inOutSine'):play()
    TweenService.new(1.5/Menu.GAME.CurrentSpeed, MainText.Anchor, {X = .5, Y = .5}, 'outSine'):play()
    TweenService.new(1.5/Menu.GAME.CurrentSpeed, MainText, {Scale = 1}, 'outSine'):play()
    TweenService.new(1/Menu.GAME.CurrentSpeed, MainText, {Opacity = 0}, 'linear'):play()

    FadeMusic(1/Menu.GAME.CurrentSpeed, 1)
    DelayService.new(0.7/Menu.GAME.CurrentSpeed, function()
        TweenService.new(1/Menu.GAME.CurrentSpeed, GameScreen.Position, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y*-1.5}, 'inOutSine'):play()
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
    self.GameSpeed = Menu.GAME.CurrentSpeed

    -- Boundaries
    self.BoundPos = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y* ((Menu.NumberOfPlayers == 1 and .5) or (Menu.NumberOfPlayers == 2 and (PlayerID == 1 and .25 or .75))))
    self.BoundSize = Vector2(Renderer.ScreenSize.X, Renderer.ScreenSize.Y*.5)

    -- Custom functions
    self.PlayMusic = function(MusicFolder)
        if PlayerID == 2 then return end
        self._MusicSource = love.audio.newSource(MusicFolder, "static")
        self._MusicSource:setLooping(true)
        self._MusicSource:setVolume(1)
        self._MusicSource:play()
        return self._MusicSource
    end

    self.StopMusic = function(MusicFolder)
        if not self._MusicSource then return end
        self._MusicSource:stop()
    end

    self.BindKey = function(Key, FN)
        Key = Key:lower()
        if not Keybinds[Key] then error("No keybind named '" .. Key .. "' found !") end

        self._Cache.Binds[Keybinds[Key][PlayerID]] = FN
        if self._Started then Controls.bind(Keybinds[Key][PlayerID], FN) end
    end

    self.Success = function()
        local s = love.audio.newSource("assets/sounds/good.ogg", "static")
        s:setLooping(false)
        s:setVolume(.5)
        s:play()

        local obj = Image("assets/imgs/GOOD.png")
        obj.Position = self.BoundPos
        obj.Size = Vector2(self.BoundSize.Y*.8, self.BoundSize.Y*.8)
        obj.Anchor = Vector2(.5, .5)
        self.add(obj, 10000, true)

        print("WE GOT A SUCCESS ! " .. PlayerID)
    end

    self.Fail = function()
        local s = love.audio.newSource("assets/sounds/fail_" .. math.random(1, 3) .. ".ogg", "static")
        s:setLooping(false)
        s:setVolume(.5)
        s:play()

        local obj = Image("assets/imgs/WRONG.png")
        obj.Position = self.BoundPos
        obj.Size = Vector2(self.BoundSize.Y*.8, self.BoundSize.Y*.8)
        obj.Anchor = Vector2(.5, .5)
        self.add(obj, 10000, true)

        print("WE GOT A FAIL ! " .. PlayerID)
    end

    self.add = function(Obj, ZIndex, Force)
        table.insert(self._Cache.Objs, {Obj, ZIndex})
        if self._Started or Force then Menu.add(Obj, ZIndex) end
    end

    -- Pre functions
    self._PreStart = function()
        for i,Obj in pairs(self._Cache.Objs) do
            Menu.add(Obj[1], Obj[2])
        end
        for i,FN in pairs(self._Cache.Binds) do
            Controls.bind(i, FN)
        end
    end

    self._PreCleanup = function()
        for i,Obj in pairs(self._Cache.Objs) do
            Menu.rem(Obj[1])
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

        if Menu.NumberOfPlayers == 2 then
            Menu.GAME.OtherMinigame = ChooseMinigame().new()
            Menu.GAME.OtherMinigame:setObjective(Menu.GAME.CurrentMinigame:getObjective())
            PreSetupMinigame(Menu.GAME.OtherMinigame, 2)
            Menu.GAME.OtherMinigame:Setup()
        end
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

    for i=1, Menu.NumberOfPlayers do
        Menu.GAME["LifePlayer" .. i] = 3
    end

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

    if Menu.GAME.CurrentMinigame then
        if Menu.GAME.CurrentMinigame._Started then
            -- UPDATE CYCLE
            Menu.GAME.CurrentMinigame:Update(dt)
            if Menu.GAME.OtherMinigame then
                Menu.GAME.OtherMinigame:Update(dt)
            end
            

            -- TIME
            local tick = love.timer.getTime()
            local Elapsed = tick - Menu.GAME.CurrentMinigame._Started

            BombText:SetText(math.max(math.floor((Menu.GAME.CurrentMinigame.MaxTime-Elapsed)*10)/10, 0))
            if Elapsed >= Menu.GAME.CurrentMinigame.MaxTime then
                Menu.GAME.CurrentMinigame._Started = false
                Menu.GAME.CurrentMinigame:Stop()
                if Menu.GAME.OtherMinigame then Menu.GAME.OtherMinigame:Stop() end

                DelayService.new(2/Menu.GAME.CurrentSpeed, function()
                    Menu.GAME.CurrentMinigame:_PreCleanup()
                    Menu.GAME.CurrentMinigame:Cleanup()
                    Menu.GAME.CurrentMinigame:StopMusic()
                    if Menu.GAME.OtherMinigame then 
                        Menu.GAME.OtherMinigame:_PreCleanup() 
                        Menu.GAME.OtherMinigame:Cleanup() 
                        Menu.GAME.OtherMinigame:StopMusic()
                    end

                    Menu.rem(BombImg)
                    Menu.rem(BombText)

                    Menu.add(Animation)
                    Menu.add(GameScreen)
                    Menu.GAME.CurrentSpeed = Menu.GAME.CurrentSpeed + Menu.SpeedFactor
                    Menu.GAME.StageMusic.Source:setPitch(Menu.GAME.CurrentSpeed)
                    DelayService.new(.5/Menu.GAME.CurrentSpeed, function()
                        
                        FadeMusic(1/Menu.GAME.CurrentSpeed, 1)
                        popScreenOUT()
                        NextStep = nil
                    end)
                end)
            end
        end
    end    
end

function Menu.cleanup()

end

return Menu