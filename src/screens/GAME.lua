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
local Input = require("src/libs/Input")

local TweenService = require("src/libs/Tween")
local DelayService = require("src/libs/Delay")

-- // Mandatory screen declaration
local Menu = Screen.new()

-- // Settings | DEFAULT SETTINGS
Menu.GamesBeforeSpeedup = 5 -- How much game before we spice the game up !
Menu.DifficultyIncrease = .2 -- Increase difficulty by this factor each game, Difficulty will be round to the lowest integer if it's a decimal.
Menu.SpeedFactor = .25 -- How much do we increase the speed by each stages.
Menu.MusicSpeedMult = .25 -- How much will the music's speed increase each stage

Menu.NumberOfLives = 3 -- If you fall at 0, it's the end!
Menu.NumberOfPlayers = 1 -- Number of players

Menu.ScoreEnabled = true
Menu.ScoreMultiplier = 1 -- Score multiplier (score is rounded to highest integer)
Menu.StartSpeed = 1 -- Default speed
Menu.StartDifficulty = 1 -- Default difficulty

Menu.Musics = {
    ["Stages/VHS-HeadBody.mp3"] = {Name = "Head Body", Author = "VHS", Stage = 1, BaseVolume = 1, BPM = 114},
    ["Stages/Jet Set Radio Soundtrack - Sneakman.mp3"] = {Name = "Head Body", Author = "VHS", Stage = 2, BaseVolume = 1, BPM = 114},
    ["Stages/aNewDay.mp3"] = {Name = "Head Body", Author = "VHS", Stage = 2, BaseVolume = 1, BPM = 114},
    --["Stages/Discover.mp3"] = {Name = "Head Body", Author = "VHS", Stage = 4, BaseVolume = 1, BPM = 114},
    --["Stages/Discover.mp3"] = {Name = "Head Body", Author = "VHS", Stage = 4, BaseVolume = 1, BPM = 114},
    ["Stages/goreshit-pixel-rapist.mp3"] = {Name = "Pixel Rapist", Author = "Goreshit", Stage = 5, BaseVolume = 1, BPM = 200},
    ["Stages/Genocide.ogg"] = {Name = "Genocide", Author = "Unknown", Stage = 5, BaseVolume = 1, BPM = 213},
    ["Stages/a.mp3"] = {Name = "Genocide", Author = "Unknown", Stage = 5, BaseVolume = 1, BPM = 213}
}

-- These settings below shouldn't be modified on runtime
local TextActive = Color(1, 1, 1)
local TextGood = Color(66/255, 1, 98/255)
local TextBad = Color(1, 66/255, 66/255)

local Keybinds = {
    up = {Input.player1.up, Input.player2.up},
    down = {Input.player1.down, Input.player2.down},
    right = {Input.player1.right, Input.player2.right},
    left = {Input.player1.left, Input.player2.left},

    button1 = {Input.player1.button1, Input.player2.button1},
    button2 = {Input.player1.button2, Input.player2.button2},
    button3 = {Input.player1.button3, Input.player2.button3},
    button4 = {Input.player1.button4, Input.player2.button4},
    button5 = {Input.player1.button5, Input.player2.button5},
    button6 = {Input.player1.button6, Input.player2.button6},
}

-- // Objects
Menu.GAME = {}

-- // SETUP
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

local BombExplosion = Image("assets/imgs/Explode.png")
BombExplosion.Anchor = Vector2(.5, .5)
BombExplosion.Size = Vector2(200, 200)
BombExplosion.Position = Vector2(70, Renderer.ScreenSize.Y-50)

local BombText = TextLabel(love.graphics.newFont("assets/Fonts/DagestaN.ttf", 40))
BombText.Anchor = Vector2(.5, .5)
BombText.Position = Vector2(68, Renderer.ScreenSize.Y-52)
BombText:SetText("88.8")

local Heart1 = Image("assets/imgs/Heart1.png")
Heart1.Size = Vector2(75, 75)
Heart1.Opacity = 0.75
Menu.add(Heart1, 99999997)

local Heart1Text = TextLabel(love.graphics.newFont("assets/Fonts/DagestaN.ttf", 30))
Heart1Text.Position = Vector2(30, 30)
Heart1Text.Opacity = 0.75
Heart1Text:SetText(3)
Heart1.Text = Heart1Text

local Heart2 = Image("assets/imgs/Heart2.png")
Heart2.Size = Vector2(75, 75)
Heart2.Position = Vector2(Renderer.ScreenSize.X, 0)
Heart2.Anchor = Vector2(1, 0)
Heart2.Opacity = 0.75

local Heart2Text = TextLabel(love.graphics.newFont("assets/Fonts/DagestaN.ttf", 30))
Heart2Text.Position = Vector2(Renderer.ScreenSize.X-30, 30)
Heart2Text.Anchor = Vector2(1, 0)
Heart2Text.Opacity = 0.75
Heart2Text:SetText(3)
Heart2.Text = Heart2Text

local Game_Started = false
local NextStep, Minigames, InTransition, LastGame

-- // Functions
function isMultiplayer()
    return Menu.NumberOfPlayers > 1
end

function getMinigames()
    local Minigames = {}
    for _,v in pairs(love.filesystem.getDirectoryItems("minigames/")) do
        local mod = require("minigames/" .. v .. "/game")
        local multi = isMultiplayer()
        if mod.IsActive and (not multi or (not mod.MultiplayerDisabled)) then
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

    if #o == 1 then
        return Minigames[o[1]]
    else
        local newGame = o[math.random(1, #o)]
        while LastGame and newGame == LastGame do
            newGame = o[math.random(1, #o)]
        end

        LastGame = newGame
        return Minigames[newGame]
    end
end

function getCurrentMusic(Stage)
    Stage = Stage or Menu.GAME.Stage

    local AllowedMusics = {}
    local CurMusicID = -1
    local CurIndex = 1
    for i,v in pairs(Menu.Musics) do
        if not v.Link then
            v.Link = i
        end

        if v.Stage == Stage then
            AllowedMusics[CurIndex] = v
            
            if Menu.GAME.StageMusic and v.Link == Menu.GAME.StageMusic.Link then
                CurMusicID = CurIndex
            end

            CurIndex = CurIndex + 1
        end
    end

    if #AllowedMusics == 0 then
        --if Stage == Menu.GAME.Stage then print("\x1B[31m[WARNING] No music for stage " .. Stage .. " found! Using lower stage's music.\x1B[0m") end

        return getCurrentMusic(Stage-1) 
    elseif CurMusicID > 0 and #AllowedMusics > 1 then
        table.remove(AllowedMusics, CurMusicID)
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

    --FadeMusic(1/Menu.GAME.CurrentSpeed, 1)
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
    if Menu.GAME.StageMusic.Stage ~= 1 or Menu.GAME.StageMusic.Beat > 31 then return end
    local curBeat = Menu.GAME.StageMusic.Beat

    if curBeat == 0 then
        MainText:SetText("BIENVENUE DANS CURSEDWAVE !")
    elseif curBeat == 6 then
        MainText:SetText("LE BUT DU JEU EST DE PROGRESSER\n            LE PLUS LOIN POSSIBLE")
    elseif curBeat == 12 then
        MainText:SetText("        TOUT LES " .. Menu.GamesBeforeSpeedup .. " JEUX\nLA DIFFICULTE AUGMENTERA")
    elseif curBeat == 18 then
        MainText:SetText("        VOUS POSSEDER " .. Menu.NumberOfLives .. " VIES\n      LA PARTIE PRENDRA FIN SI \nUN JOUEUR PERD TOUTE SES VIES")
    elseif curBeat == 24 then
        MainText:SetText("SUIVEZ LES INSTRUCTIONS POUR\n GAGNER LES DIFFERENTS JEUX")
        Controls.unbind("f") -- Unbind skip here, as we don't wanna skip anymore at this point.
    elseif curBeat == 30 then
        MainText:SetText("BONNE CHANCE !")
    end
end

function PreSetupMinigame(self, PlayerID)
    self._Cache = {Binds = {}, Objs = {}}
    self._Started = false
    self.PlayerID = PlayerID
    self.GameSpeed = Menu.GAME.CurrentSpeed
    self.GameDifficulty = math.floor(Menu.GAME.CurrentDifficulty)
    print("SPEED", self.GameSpeed, "DIFFICULTY", self.GameDifficulty, "(" .. Menu.GAME.CurrentDifficulty .. ")")

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

    self.GetTimeRemaining = function()
        if not Menu.GAME.CurrentMinigame._Started then return end
        return Menu.GAME.CurrentMinigame.MaxTime - (love.timer.getTime() - Menu.GAME.CurrentMinigame._Started)
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
        if self._Stopped or self._Noted then return end
        self._Noted = true
        

        local s = love.audio.newSource("assets/sounds/good.ogg", "static")
        s:setLooping(false)
        s:setVolume(.5)
        s:play()

        local obj = Image("assets/imgs/GOOD.png")
        obj.Position = self.BoundPos
        obj.Size = Vector2(self.BoundSize.Y*.8, self.BoundSize.Y*.8)
        obj.Anchor = Vector2(.5, .5)
        self.add(obj, 10000, true)

        self:_PreStop()
    end

    self.Fail = function()
        if self._Stopped or self._Noted then return end
        self._Noted = true
        
        local s = love.audio.newSource("assets/sounds/fail_" .. math.random(1, 3) .. ".ogg", "static")
        s:setLooping(false)
        s:setVolume(.5)
        s:play()

        local obj = Image("assets/imgs/WRONG.png")
        obj.Position = self.BoundPos
        obj.Size = Vector2(self.BoundSize.Y*.8, self.BoundSize.Y*.8)
        obj.Anchor = Vector2(.5, .5)
        self.add(obj, 10000, true)

        -- Bruh... Why did I start 2 Players by hard coding it, worse decision in this project probably.
        Menu.GAME["LifePlayer" .. PlayerID] = Menu.GAME["LifePlayer" .. PlayerID] - 1
        if PlayerID == 1 then
            Heart1.Text:SetText(Menu.GAME["LifePlayer" .. PlayerID])
        else
            Heart2.Text:SetText(Menu.GAME["LifePlayer" .. PlayerID])
        end

        self:_PreStop()
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

    self._PreUpdate = function(self, dt)
        if self._Stopped then return end

        self:Update(dt)
    end

    self._PreStop = function()
        if self._Stopped or self._Stopping then return end

        self._Stopping = true
        self:Stop()
        self:Fail()
        self._Stopped = true
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
    if InTransition then return end
    if Menu.GAME.StageMusic.Beat < 31 and Menu.GAME.StageMusic.Stage == 1 then return Intro() end

    if not Game_Started then
        Game_Started = true
        
    end

    if not NextStep then
        local dahGame = ChooseMinigame()
        Menu.GAME.CurrentMinigame = dahGame.new()
        PreSetupMinigame(Menu.GAME.CurrentMinigame, 1)
        Menu.GAME.CurrentMinigame:Setup()

        if Menu.NumberOfPlayers == 2 then
            Menu.GAME.OtherMinigame = dahGame.new()
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

function EndGame()
    Menu.GAME.Stage = math.ceil(Menu.GAME.Rounds/Menu.GamesBeforeSpeedup)

    local sfx = love.audio.newSource("/assets/sounds/RewindSFX.mp3", "static")
    sfx:setLooping(false)
    sfx:setVolume(1)
    sfx:play()

    Menu.GAME.StageMusic.Source:stop()
    InTransition = true
    popScreenOUT()
    MainText:SetText("...")

    Minigames = nil
    
    local sfx
    DelayService.new(3, function()
        if Menu.NumberOfPlayers == 1 then
            sfx = love.audio.newSource("/assets/sounds/dead.mp3", "static")
            sfx:setLooping(false)
            sfx:setVolume(1)
            sfx:play()

            MainText:SetText("FIN DE LA PARTIE!\n       SCORE " .. math.ceil((Menu.GAME.Rounds-1) * Menu.ScoreMultiplier))
        else
            if Menu.GAME.LifePlayer1 > 0 or Menu.GAME.LifePlayer2 > 0 then
                sfx = love.audio.newSource("/assets/sounds/Victory.mp3", "static")
            else
                sfx = love.audio.newSource("/assets/sounds/LOSE.ogg", "static")
            end
            sfx:setLooping(false)
            sfx:setVolume(1)
            sfx:play()
            

            DelayService.new(1.2, function()
                if Menu.GAME.LifePlayer1 > 0 or Menu.GAME.LifePlayer2 > 0 then
                    MainText:SetText("GAGNANT JOUEUR " .. (Menu.GAME.LifePlayer1 > 0 and "1" or "2") .. "!\n         SCORE " .. math.ceil((Menu.GAME.Rounds-1) * Menu.ScoreMultiplier))
                else
                    MainText:SetText(" EX AEQUO!\n  SCORE " .. math.ceil((Menu.GAME.Rounds-1) * Menu.ScoreMultiplier))
                end
            end)
            MainText:SetText("...")
        end
    end)

    DelayService.new(6, function()
        Controls.bind(Input.player1.button1, function(isDown)
            if not isDown then return end
            Controls.unbind(Input.player1.button1)
            sfx:stop()
            if Menu.ScoreEnabled then
                local s = Screen.get("SubmitScore")
                s.ScoreToSave = math.ceil((Menu.GAME.Rounds-1) * Menu.ScoreMultiplier)
                Renderer.changeScreen(s)
            else
                Renderer.changeScreen(Screen.get("Title"))
            end
            
        end)
    end)
end

-- // Runners

local curTime = 0
local ScreenPopped = false
local ScreenPOUT = false
function Menu.open()
    startTick = 0
    Game_Started = false
    NextStep, InTransition = nil,nil

    Menu.GAME = {
        Rounds = 1,
        Stage = 1,
        StageMusic = nil,

        CurrentSpeed = Menu.StartSpeed,
        CurrentDifficulty = Menu.StartDifficulty,
    }

    for i=1, Menu.NumberOfPlayers do
        Menu.GAME["LifePlayer" .. i] = Menu.NumberOfLives
    end

    Menu.add(Heart1, 99999997)
    Menu.add(Heart1.Text, 99999998)
    Heart1.Text:SetText(Menu.NumberOfLives)
    if Menu.NumberOfPlayers == 2 then
        Menu.add(Heart2, 99999997)
        Menu.add(Heart2.Text, 99999998)
        Heart2.Text:SetText(Menu.NumberOfLives)
    else
        Menu.rem(Heart2)
        Menu.rem(Heart2.Text)
    end

    Menu.GAME.StageMusic = getCurrentMusic(Stage)
    Menu.GAME.StageMusic.Beat = -1
    Menu.GAME.StageMusic.Source = love.audio.newSource("/assets/musics/" .. Menu.GAME.StageMusic.Link, "static")
    Menu.GAME.StageMusic.Source:setLooping(false)
    Menu.GAME.StageMusic.Source:setVolume(0)
    Menu.GAME.StageMusic.Source:setPitch(1 + (Menu.GAME.CurrentSpeed-1)*Menu.MusicSpeedMult)
    Menu.GAME.StageMusic.Source:play()

    FadeMusic(1, 1)

    Controls.bind(Input.player1.button1, function(isDown)
        if not isDown then return end
        Controls.unbind(Input.player1.button1)
        skip_intro()
    end)
end

function Menu.update(dt)
    curTime = curTime + dt

    local StepCrochet = 60 / Menu.GAME.StageMusic.BPM
    local dahBeat = math.floor(Menu.GAME.StageMusic.Source:tell("seconds")/(StepCrochet*2))
    if dahBeat ~= Menu.GAME.StageMusic.Beat then
        Menu.GAME.StageMusic.Beat = dahBeat
        --print("BEAT !", Menu.GAME.StageMusic.Beat, " | ", Menu.GAME.StageMusic.Source:tell("seconds"))

        step()
    end

    if Menu.GAME.CurrentMinigame then
        if Menu.GAME.CurrentMinigame._Started then
            -- UPDATE CYCLE
            Menu.GAME.CurrentMinigame:_PreUpdate(dt)
            if Menu.GAME.OtherMinigame then
                Menu.GAME.OtherMinigame:_PreUpdate(dt)
            end
            
            -- TIME
            local tick = love.timer.getTime()
            local Elapsed = tick - Menu.GAME.CurrentMinigame._Started
            
            BombText:SetText(math.max(math.floor((Menu.GAME.CurrentMinigame.MaxTime-Elapsed)*10)/10, 0))

            if Elapsed >= Menu.GAME.CurrentMinigame.MaxTime then
                Menu.GAME.CurrentMinigame._Started = false
                Menu.GAME.CurrentMinigame:_PreStop()
                if Menu.GAME.OtherMinigame then Menu.GAME.OtherMinigame:_PreStop() end

                Menu.rem(BombImg)
                Menu.rem(BombText)
                Menu.add(BombExplosion)

                self._Stopped = true
                DelayService.new(2/Menu.GAME.CurrentSpeed, function()
                    Menu.GAME.CurrentMinigame:_PreCleanup()
                    Menu.GAME.CurrentMinigame:Cleanup()
                    Menu.GAME.CurrentMinigame:StopMusic()
                    if Menu.GAME.OtherMinigame then 
                        Menu.GAME.OtherMinigame:_PreCleanup() 
                        Menu.GAME.OtherMinigame:Cleanup() 
                        Menu.GAME.OtherMinigame:StopMusic()
                    end

                    Menu.rem(BombExplosion)
                    Menu.add(GameScreen)
                    Menu.GAME.Rounds = Menu.GAME.Rounds + 1
                    Menu.GAME.CurrentDifficulty = Menu.GAME.CurrentDifficulty + Menu.DifficultyIncrease
                    local PassStage = Menu.GAME.Stage ~= math.ceil(Menu.GAME.Rounds/Menu.GamesBeforeSpeedup)
                    if Menu.GAME["LifePlayer1"] <= 0 or (Menu.NumberOfPlayers == 2 and Menu.GAME["LifePlayer2"] <= 0) then
                        return EndGame()
                    elseif PassStage then
                        Menu.GAME.Stage = math.ceil(Menu.GAME.Rounds/Menu.GamesBeforeSpeedup)

                        local sfx = love.audio.newSource("/assets/sounds/RewindSFX.mp3", "static")
                        sfx:setLooping(false)
                        sfx:setVolume(1)
                        sfx:play()

                        Menu.GAME.StageMusic.Source:stop()
                        InTransition = true
                    end

                    Menu.GAME.StageMusic.Source:setPitch(1 + (Menu.GAME.CurrentSpeed-1)*Menu.MusicSpeedMult)
                    DelayService.new(.5/Menu.GAME.CurrentSpeed, function()
                        if PassStage then
                            MainText:SetText("...")

                            popScreenOUT()
                            DelayService.new(2, function()
                                Menu.GAME.CurrentSpeed = Menu.GAME.CurrentSpeed + Menu.SpeedFactor
                                local sfx = love.audio.newSource("/assets/sounds/speedup.ogg", "static")
                                sfx:setLooping(false)
                                sfx:setVolume(1)
                                sfx:play()
                                MainText:SetText("VITESSE AUGMENTEE !\n              " .. Menu.GAME.CurrentSpeed .. "X !")

                                DelayService.new(2, function()
                                    Menu.GAME.StageMusic = getCurrentMusic(Menu.GAME.Stage)
                                    Menu.GAME.StageMusic.Beat = -1
                                    Menu.GAME.StageMusic.Source = love.audio.newSource("/assets/musics/" .. Menu.GAME.StageMusic.Link, "static")
                                    Menu.GAME.StageMusic.Source:setLooping(false)
                                    Menu.GAME.StageMusic.Source:setVolume(0)
                                    Menu.GAME.StageMusic.Source:setPitch(1 + (Menu.GAME.CurrentSpeed-1)*Menu.MusicSpeedMult)
                                    Menu.GAME.StageMusic.Source:play()
                                    FadeMusic(2, 1)

                                    DelayService.new(2, function()
                                        NextStep = nil
                                        InTransition = false
                                    end)
                                end)
                            end)
                        else
                            FadeMusic(1/Menu.GAME.CurrentSpeed, 1)
                            popScreenOUT()
                            NextStep = nil
                        end
                    end)
                end)
            end
        end
    end    
end

function Menu.cleanup()
    Controls.unbind(Input.player1.button1)
end

return Menu