-- Libs
local Object = require("src/libs/Classic")
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Square = require("src/classes/Rect")
local Image = require("src/classes/Image")
local Quad = require("src/classes/Quad")

local Renderer = require("src/libs/Rendering/Renderer")
local LogManager = require("src/libs/Debug/LogManager")
local Controls = require("src/libs/Controls")
local Instance = require("src/libs/Instance")

-- Settings
Renderer.ScreenSize = Vector2(1280, 1024)
Renderer.BackgroundColor = Color(.075, .075, .075)

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
local SquareOne = Image("Logo.png")
SquareOne.Position = Vector2(Renderer.ScreenSize.X/2, Renderer.ScreenSize.Y/2)
SquareOne.Size = Vector2(400, 400)
SquareOne.Anchor = Vector2(.5, .5)
Renderer.add(SquareOne)

local Features = {}

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


for i=1,6 do
    Controls.bind(tostring(i), function(inputBegan)
        if not inputBegan then return end
        if not Features[i] then Features[i] = true return end
        Features[i] = not Features[i]
    end)
end


-- burst shit
local Burst, BurstTick = 0, 0

local ProgressBarOutline = Square(Renderer.ScreenSize.X/2, Renderer.ScreenSize.Y*.8, Renderer.ScreenSize.X*.75, 25)
ProgressBarOutline.Anchor = Vector2(.5, .5)
ProgressBarOutline.CornerRadius = 10
ProgressBarOutline.Color = Color(0.2,0.2,0.2)
Renderer.add(ProgressBarOutline)

local ProgressBar = Square(Renderer.ScreenSize.X*.125, Renderer.ScreenSize.Y*.8, 0, 25)
ProgressBar.Anchor = Vector2(0, .5)
ProgressBar.CornerRadius = 10
ProgressBar.Color = ProgressbarColor
Renderer.add(ProgressBar, 2)

local Background = Quad("assets/imgs/Backgrounds/pattern_57.png", Vector2(Renderer.ScreenSize.X + 200, Renderer.ScreenSize.Y + 200), Vector2(100, 100))
local BackgroundSpeed = 0
local BackgroundBaseSpeed = 120
local BackgroundAcceleration = 1000
Background.Color = Renderer.BackgroundColor
Renderer.add(Background, -100)

-- Functions
local Shader3dRays
function love.load()
    love.window.setMode(Renderer.ScreenSize.X, Renderer.ScreenSize.Y, {resizable=false, vsync=false, borderless=true})
    
    --local ShaderString = love.filesystem.read("assets/shaders/Bloom.glsl")
    --Shader3dRays = love.graphics.newShader(ShaderString)
    --SquareOne.Shader = Shader3dRays

    MusicSource = love.audio.newSource(MusicPath, "static")
    MusicSource:setLooping(true)
    MusicSource:setVolume(0)
    MusicSource:play()
end

local b = 0
function love.update(dt)
    if love.keyboard.isDown("up") then GameSpeed = GameSpeed + .3*dt end
    if love.keyboard.isDown("down") then GameSpeed = GameSpeed - .3*dt end
    if love.keyboard.isDown("right") then MusicSource:setVolume(MusicSource:getVolume() + .3 * dt) end
    if love.keyboard.isDown("left") then MusicSource:setVolume(MusicSource:getVolume() - .3 * dt) end
    --if love.keyboard.isDown("p") then b = b + dt * .3 Shader3dRays:send("intensity", b) end
    --if love.keyboard.isDown("l") then b = b - dt * .3 Shader3dRays:send("intensity", b) end
    MusicSource:setPitch(GameSpeed)
    
    dt = dt * GameSpeed
    local tick = MusicSource:tell("seconds") --love.timer.getTime()
    --Shader3dRays:send("time", tick)

    local db = math.floor(tick*(MusicBPM/60)/MusicStepSkip)
    if Burst ~= db then
        Burst = db
        BurstTick = tick

        Background.Color = Color.fromHSV(math.random(), .5, 1)
    end

    local Elapsed = tick - BurstTick
    ProgressBar.Color = ProgressbarBurst:lerp(ProgressbarColor, Elapsed/(.25 / GameSpeed))

    if Features[1] then

    end
    local SizeFactor = 1 + math.max(1-Elapsed/(.25 / GameSpeed), 0)*.5
    SquareOne.Size.X = 800 * SizeFactor + math.sin(tick*2)*50
    SquareOne.Size.Y = 800 * SizeFactor + math.sin(tick*2)*50
    --Shader3dRays:send("intensity", math.max(1 - Elapsed/.25, 0)*1)
    --Shader3dRays:send("time", tick)
    --SquareOne.Size.X = 400 + math.sin(tick*2)*50
    --SquareOne.Size.Y = 400 + math.sin(tick*2)*50

    Progress = math.max(math.min(Progress + math.max((1-Elapsed)*.05*dt, 0), 1), 0.02) --math.max(math.min(Progress + dt * .1, 1), 0.02)
    if Progress == 1 then Progress = 0 end
    ProgressBar.Size.X = Renderer.ScreenSize.X*(.75 * Progress)

    BackgroundSpeed = BackgroundBaseSpeed + BackgroundAcceleration * math.max(1-Elapsed/.5, 0)
    Background.Position.X = ((Background.Position.X + math.sin(tick/3) * BackgroundSpeed * dt)) % Background.TextureSize.X - Background.TextureSize.X  --% Background.TextureSize.X*2 - Background.TextureSize.X
    Background.Position.Y = ((Background.Position.Y + math.cos(tick/3) * BackgroundSpeed * dt)) % Background.TextureSize.Y - Background.TextureSize.Y --% Background.TextureSize.Y*2 - Background.TextureSize.Y

    -- LOGS

    LogManager.cleanup()
    LogManager.updateLog(love.timer.getFPS() .. " FPS", Color.Green)
    --[[
    LogManager.updateLog("Position: " .. tostring(SquareOne.Position), Color.Green)
    LogManager.updateLog("Size: " .. tostring(SquareOne.Size), Color.Green)
    LogManager.updateLog("Rotation: " .. tostring(SquareOne.Rotation), Color.Green)
    LogManager.updateLog()
    LogManager.updateLog("Last Input: " .. Controls.LastInput, Color.Green)
    LogManager.updateLog("Game speed: " .. GameSpeed, Color.Green)
    LogManager.updateLog()
    LogManager.updateLog("Music position: " .. tick, Color.Green)
    LogManager.updateLog("Music burst time elapsed: " .. Elapsed, Color.Green)
    ]]
end