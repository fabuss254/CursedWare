-- Libs
local Object = require("src/libs/Classic")
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Square = require("src/classes/Rect")
local Image = require("src/classes/Image")

local LogManager = require("src/libs/Debug/LogManager")
local Controls = require("src/libs/Controls")
local Instance = require("src/libs/Instance")

-- Settings
local ScreenSize = Vector2(1280, 1024)
local BackgroundColor = Color(.05, .05, .05)

local ProgressbarColor = Color(0.2,0.8,0.2)
local ProgressbarBurst = Color(0.8,0.8,0.8)

local MusicPath = "assets/sounds/lol.mp3" --"assets/musics/Genocide.ogg"
local MusicBPM = 151 -- 213
local MusicStepSkip = 1

local GameSpeed = 1

-- Debug shit
local offx, offy = 0, 0
local Progress = 0
local MusicSource
local SquareOne = Image("assets/imgs/studiologoNoBG.png")
SquareOne.Position = Vector2(ScreenSize.X/2, ScreenSize.Y/2)
SquareOne.Size = Vector2(400, 400)
SquareOne.Anchor = Vector2(.5, .5)

-- Sound test
local passSound = "assets/sounds/good.ogg"
Controls.bind("e", function(inputBegan)
    if not inputBegan then return end
    love.audio.newSource(passSound, "static"):play()
end)

local wrongSound = {"assets/sounds/bad_voice_1.ogg", "assets/sounds/bad_voice_2.ogg", "assets/sounds/bad_voice_3.ogg"}
Controls.bind("r", function(inputBegan)
    if not inputBegan then return end
    love.audio.newSource(wrongSound[math.random(1, #wrongSound)], "static"):play()
end)

-- burst shit
local Burst, BurstTick = 0, 0

local ProgressBarOutline = Square(ScreenSize.X/2, ScreenSize.Y*.8, ScreenSize.X*.75, 25)
ProgressBarOutline.Anchor = Vector2(.5, .5)
ProgressBarOutline.CornerRadius = 10
ProgressBarOutline.Color = Color(0.2,0.2,0.2)

local ProgressBar = Square(ScreenSize.X*.125, ScreenSize.Y*.8, 0--[[ScreenSize.X*.25]], 25)
ProgressBar.Anchor = Vector2(0, .5)
ProgressBar.CornerRadius = 10
ProgressBar.Color = ProgressbarColor

-- Functions
local Shader3dRays
function love.load()
    love.window.setMode(ScreenSize.X, ScreenSize.Y, {resizable=false, vsync=false, borderless=true})
    Shader3dRays = love.graphics.newShader([[
        extern number time;
        number t;
        vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
        {
            t = time * 1.5; //may want to vary this for cycle speed?
            color = Texel(tex, tc);
            return vec4(vec3(sin(t + 5)+0.3, -sin(t+5)+0.3, sin(t + 10)) * (max(color.r, max(color.g, color.b))), 1.0); //cycles colors and pulses brightness slightly
        }
    ]])

    MusicSource = love.audio.newSource(MusicPath, "static")
    MusicSource:setLooping(true)
    MusicSource:setVolume(0.1)
    MusicSource:play()
end

function love.draw()
    love.graphics.setShader(Shader3dRays)
    SquareOne:draw()
    ProgressBarOutline:draw()
    ProgressBar:draw()

    love.graphics.setColor(1, 0, 0, .5)
    love.graphics.circle("fill", ScreenSize.X/2, ScreenSize.Y/2, 5)

    love.graphics.setColor(1, 1, 1, .1)
    love.graphics.print("ATS 2021 ©", ScreenSize.X - 80, ScreenSize.Y - 20)

    BackgroundColor:applyBackground()
    LogManager.draw()
end

function love.update(dt)
    if love.keyboard.isDown("up") then GameSpeed = GameSpeed + .3*dt end
    if love.keyboard.isDown("down") then GameSpeed = GameSpeed - .3*dt end
    if love.keyboard.isDown("right") then MusicSource:setVolume(MusicSource:getVolume() + .3 * dt) end
    if love.keyboard.isDown("left") then MusicSource:setVolume(MusicSource:getVolume() - .3 * dt) end
    MusicSource:setPitch(GameSpeed)
    
    local tick = MusicSource:tell("seconds") --love.timer.getTime()
    Shader3dRays:send("time", tick)

    local db = math.floor(tick*(MusicBPM/60)/MusicStepSkip)
    if Burst ~= db then
        Burst = db
        BurstTick = tick
    end

    local Elapsed = tick - BurstTick
    ProgressBar.Color = ProgressbarBurst:lerp(ProgressbarColor, Elapsed/(.25 / GameSpeed))

    local SizeFactor = 1 + math.max(1-Elapsed/(.25 / GameSpeed), 0)*.25
    SquareOne.Size.X = 400 * SizeFactor + math.sin(tick*2)*50
    SquareOne.Size.Y = 400 * SizeFactor + math.sin(tick*2)*50
    --SquareOne.Size.X = 400 + math.sin(tick*2)*50
    --SquareOne.Size.Y = 400 + math.sin(tick*2)*50

    Progress = math.max(math.min(Progress + math.max((1-Elapsed)*.05*dt, 0), 1), 0.02) --math.max(math.min(Progress + dt * .1, 1), 0.02)
    if Progress == 1 then Progress = 0 end
    ProgressBar.Size.X = ScreenSize.X*(.75 * Progress)

    -- LOGS

    LogManager.cleanup()
    LogManager.updateLog(love.timer.getFPS() .. " FPS", Color.Green)
    LogManager.updateLog("Position: " .. tostring(SquareOne.Position), Color.Green)
    LogManager.updateLog("Size: " .. tostring(SquareOne.Size), Color.Green)
    LogManager.updateLog("Rotation: " .. tostring(SquareOne.Rotation), Color.Green)
    LogManager.updateLog()
    LogManager.updateLog("Last Input: " .. Controls.LastInput, Color.Green)
    LogManager.updateLog("Game speed: " .. GameSpeed, Color.Green)
    LogManager.updateLog()
    LogManager.updateLog("Music position: " .. tick, Color.Green)
    LogManager.updateLog("Music burst time elapsed: " .. Elapsed, Color.Green)
end