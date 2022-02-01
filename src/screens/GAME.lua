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

local TextActive = Color(255, 255, 255)
local TextGood = Color(66, 255, 98)
local TextBad = Color(255, 66, 66)

-- // Objects
Menu.GAME = { -- MAIN GAME OBJECT
    Stage = 1,
    StageMusic = nil,

    CurrentSpeed = 1,
    CurrentDifficulty = 1,
}

-- // SETUP
local Animation = Spritesheet("assets/spritesheets/IntermissionSpeakers.png", Vector2(320, 256), 2)
Animation.Anchor = Vector2(.5, .5)
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

-- // Functions
function getMinigames()
    
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

function step()
    if Menu.GAME.StageMusic.Beat < 31 and Menu.GAME.StageMusic.Stage == 1 then return Intro() end

    if not Game_Started then
        Game_Started = true
        TweenService.new(1, Animation.Position, {X = Renderer.ScreenSize.X*.5, Y = Renderer.ScreenSize.Y*.5}, 'outSine'):play()
        TweenService.new(.5, Animation.Size, {X = Renderer.ScreenSize.X, Y = Renderer.ScreenSize.Y}, 'outSine'):play()
    end

    MainText:SetText("CHOOSING MINIGAME")
end

-- // Runners

local curTime = 0
local ScreenPopped = false
local ScreenPOUT = false
function Menu.open()
    startTick = 0
    Animation.Position = Vector2(Renderer.ScreenSize.X*.5, Renderer.ScreenSize.Y*1.5)
    Animation.Size = Renderer.ScreenSize*.8

    Menu.GAME.StageMusic = getCurrentMusic(Stage)
    Menu.GAME.StageMusic.Beat = -1
    Menu.GAME.StageMusic.Source = love.audio.newSource("/assets/musics/" .. Menu.GAME.StageMusic.Link, "static")
    Menu.GAME.StageMusic.Source:setLooping(false)
    Menu.GAME.StageMusic.Source:setVolume(0)
    Menu.GAME.StageMusic.Source:play()
    Menu.GAME.StageMusic.Source:seek(30, "seconds")

    FadeMusic(1, 1)

    Animation:play()
    Animation:setDuration((Menu.GAME.StageMusic.BPM/60)*0.55)
end

function Menu.update(dt)
    curTime = curTime + dt

    --MainText.Color = Color.fromHSV((love.timer.getTime()) %1, 255, 1)

    --[[
    if curTime > 2 and not ScreenPopped then
        ScreenPopped = true
        popScreenIN()
    elseif curTime > 6 and not ScreenPOUT then
        ScreenPOUT = true
        popScreenOUT()
    elseif curTime > 10 then
        curTime = 0
        ScreenPopped = false
        ScreenPOUT = false

        MainText:SetText(TEST_Texts[math.random(1, #TEST_Texts)])
    end
    ]]

    local dahBeat = math.floor(Menu.GAME.StageMusic.Source:tell("seconds")/(Menu.GAME.StageMusic.BPM/60/1.8))
    if dahBeat ~= Menu.GAME.StageMusic.Beat then
        Menu.GAME.StageMusic.Beat = dahBeat
        print("BEAT !", Menu.GAME.StageMusic.Beat, " | ", Menu.GAME.StageMusic.Source:tell("seconds"))

        step()
    end
end

function Menu.cleanup()

end

return Menu