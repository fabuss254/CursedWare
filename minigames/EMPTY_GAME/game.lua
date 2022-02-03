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
module.Name = "EMPTY_GAME" -- Name of the game
module.IsActive = false -- Can this game be rolled?

-- // PRIVATE VARIABLES (STATIC)


-- // PRIVATE METHODS


-- // MINIGAME METHODS

-- Should return the string that tell what to do (RUN AFTER SETUP !)
function module:GetObjective()
    return "Sample text\nSample text"
end

-- Should return the time the player is given to finish this minigame
function module:GetTime()
    return 5/self.GameSpeed -- Divide by game speed to shrink the time remaining to complete the game at high speed
end

-- 2 player compatibility, You can retrieve the objective from the other minigame and put it into this one
function module:getObjective()
    return self.myObjective
end

function module:setObjective(Obj)
    self.myObjective = Obj
end

-- // MINIGAME RUNNERS

-- This is ran first, before it's visible on screen. You can start playing music here.
function module:Setup() 
    local GAME = self.GAME

    
end

-- This is ran once the player has control over the minigame, All your binds should work at this point
function module:Start()
    local GAME = self.GAME

    -- Play the music here | WARNING, The second player's minigame won't get the music object, so check if it exist before continuing.
    --[[
    local m = self.PlayMusic(self.Directory .. "/assets/music.mp3")
    if not m then return end

    m:setPitch(self.GameSpeed)
    ]]
end

-- This is where you update stuff. That's it...
function module:Update(dt)
    local GAME = self.GAME
    dt = dt * self.GameSpeed -- Quick way to speed up the game if you're managing character velocity for example

    -- This is an example, If we have 1s left and he's the player1, we say he succeeded
    if self.PlayerID == 1 and self:GetTimeRemaining() < 1 then
        self:Success()
    end
end

-- This is the last frame, update will stop running, but you can show random shit here
function module:Stop()
    local GAME = self.GAME

    --self:Success() -- We can tell if he failed or win (Fail would be: self:Fail())
    -- The fail/success functions doesn't NEED to be called in Stop. Calling it during the game's time will result in it instantly stopping (freeze until time up)

    -- If no win condition is called, Engine assume it's a Fail by default
end

-- This is just to cleanup your game, incase you need to make sure stuff is really destroyed in case of memory leak
function module:Cleanup()
    local GAME = self.GAME


end

return module