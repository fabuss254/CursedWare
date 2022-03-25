-- Game made by VERBRUGGHE Alexi
-- // LIBS
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Square = require("src/classes/Rect")
local Image = require("src/classes/Image")
local Quad = require("src/classes/Quad")
local Spritesheet = require("src/classes/Spritesheet")
local TextLabel = require("src/classes/TextLabel")
local ShakingText = require("src/classes/advanced/ShakingText")

local Renderer = require("src/libs/Rendering/Renderer")
local LogManager = require("src/libs/Debug/LogManager")

local TweenService = require("src/libs/Tween")
local DelayService = require("src/libs/Delay")

-- // MANDATORY LIB DECLARATION
local module = {}
module.__index = module

function module.new()
    self = setmetatable({}, module)

    return self
end

-- // MINIGAME SETTINGS (STATIC PUBLIC)
module.Name = "Show Your Bro !" -- Name of the game
module.IsActive = true -- Can this game be rolled?

-- // PRIVATE VARIABLES (STATIC)

local OriginalSize = Vector2(100, 100)
local PossibleMovement = {bas="Down",haut="Up",droite="Right",gauche="Left"}

-- // PRIVATE METHODS
function GetMovement()
    if self.Movement then
        return self.Movement
    end
    local list = {}
    for key, value in pairs(PossibleMovement) do
        table.insert(list,key)
    end
    return list[math.random(1,#list)]
end

function Linear(p0, p1, t)
    return p0*(1-t) + p1*t
end

-- // MINIGAME METHODS

-- Should return the string that tell what to do (RUN AFTER SETUP !)
function module:GetObjective()
    return "Fais 7 mouvements\n    vers " ..self.Movement
end

-- Should return the time the player is given to finish this minigame
function module:GetTime()
    return 4.5/self.GameSpeed -- Divide by game speed to shrink the time remaining to complete the game at high speed
end

-- 2 player compatibility, You can retrieve the objective from the other minigame and put it into this one
function module:getObjective()
    return self.Movement
end

function module:setObjective(Obj)
    self.Movement = Obj
end

-- // MINIGAME RUNNERS

-- This is ran first, before it's visible on screen. You can start playing music here.
function module:Setup() 
    local GAME = self.GAME
    self.point=0
    self.SSize = 1
    if not self.Movement then self.Movement = GetMovement() end

    self.Background = Image(self.Directory .. "/assets/Background.png")
    self.Background.Anchor = Vector2(.5,.5)
    self.Background.Position = self.BoundPos
    self.Background.Size = self.BoundSize
    
    self.add(self.Background,0)


    self.Sprite = Spritesheet(self.Directory .. "/assets/bro.png",Vector2(900/28,35),900)

    self.Sprite.Anchor = Vector2(.5,.5)
    self.Sprite.Position = self.BoundPos + Vector2(0,-20)
    self.Sprite.Size = Vector2(100,100)

    self.add(self.Sprite,5)

    self.audio = love.audio.newSource(self.Directory .. "/assets/coin.mp3", "static")
    self.audio:setLooping(false)
    self.audio:setVolume(0.5)

    self.BindKey(PossibleMovement[self.Movement], function (Began)
        if Began == true then
            self.Sprite:SkipFrame(1)
            self.point = self.point+1
            self.SSize = 1 + (self.point/7)*5
            
            if self.point <= 7 then
                self.audio:setPitch(1+(self.point/7)*2)
                self.audio:play()

                self.Sprite.Size = OriginalSize * (self.SSize+1)
            end
        end
    end)
    
end

-- This is ran once the player has control over the minigame, All your binds should work at this point
function module:Start()
    local GAME = self.GAME
    self.Sprite:play()
    -- Play dah music
    local m = self.PlayMusic(self.Directory .. "/assets/music.mp3")
    if not m then return end

    m:setPitch(self.GameSpeed)
end

-- This is where you update stuff. That's it...
function module:Update(dt)
    local GAME = self.GAME
    dt = dt * self.GameSpeed -- Quick way to speed up the game if you're managing character velocity for example

    self.Sprite.Size = Linear(self.Sprite.Size, OriginalSize * self.SSize, dt/0.25)

    -- This is an example, If we have 1s left and he's the player1, we say he succeeded
    if self.point >= 7 then
        self:Success()
    end
end

-- This is the last frame, update will stop running, but you can show random shit here
function module:Stop()
    local GAME = self.GAME
    self.Sprite:stop()

    --self:Success() -- We can tell if he failed or win (Fail would be: self:Fail())
    -- The fail/success functions doesn't NEED to be called in Stop. Calling it during the game's time will result in it instantly stopping (freeze until time up)

    -- If no win condition is called, Engine assume it's a Fail by default
end

-- This is just to cleanup your game, incase you need to make sure stuff is really destroyed in case of memory leak
function module:Cleanup()
    local GAME = self.GAME


end

return module