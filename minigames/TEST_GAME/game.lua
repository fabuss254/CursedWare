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
module.Name = "TEST_GAME" -- Name of the game
module.IsActive = true -- Can this game be rolled?

-- // PRIVATE VARIABLES (STATIC)
local PossibleColors = {"le Rond Rouge","le Triangle Jaune","le Carre Vert","l'Etoile Bleu"}
local ZeroVector = Vector2()

-- // PRIVATE METHODS
function getTileColor() -- This is a static method, Don't use these to modify self's objects
    return PossibleColors[math.random(1, #PossibleColors)]
end

function shuffle(tbl)
    for i = #tbl, 2, -1 do
      local j = math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
  end

function module:Update_Character(dt) -- This is a simple method, you can use to modify self
    local Character = self.PlayerCharacter
    local Input = Character.MoveDirection
    local MoveVector = Vector2(Input.D - Input.A, Input.S - Input.W)

    if MoveVector ~= ZeroVector then
        Character:play()
    else
        Character:cancel()
    end

    -- Turn character toward moving direction
    if Input.A == 1 then
        self.PlayerCharacter.Size.X = -100
    elseif Input.D == 1 then
        self.PlayerCharacter.Size.X = 100
    end
    
    Character.Velocity = (MoveVector:getUnit() * Character.Speed) -- 1.1 is the damping vector, Make the character move smootly
    Character.Position = Character.Position + Character.Velocity * dt

    -- Bound to boundaries
    Character.Position.Y = math.max(math.min(Character.Position.Y, self.BoundPos.Y + self.BoundSize.Y/2), self.BoundPos.Y - self.BoundSize.Y/2)
    Character.Position.X = math.max(math.min(Character.Position.X, self.BoundSize.X), 0)
end

function module:Check_Win()
    local Pos = self.PlayerCharacter.Position
    local TargetPos = self.ObjectiveObj.Position

    return Pos.X > TargetPos.X - self.BoundSize.X*.1 and Pos.X < TargetPos.X + self.BoundSize.X*.1
end

-- // MINIGAME METHODS

-- Should return the string that tell what to do (RUN AFTER SETUP !)
function module:GetObjective()
    return "Va sur " .. self.TileColor .. " !"
end

-- Should return the time the player is given to finish this minigame
function module:GetTime()
    return 4/self.GameSpeed
end

-- 2 player compatibility, You can retrieve the objective from the other minigame and put it into this one
function module:getObjective()
    return self.TileColor
end

function module:setObjective(Obj)
    self.TileColor = Obj
end

-- // MINIGAME RUNNERS

-- This is ran first, before it's visible on screen. You can start playing music here.
function module:Setup() 
    local GAME = self.GAME

    -- SIMPLE ATTRIBUTES
    if not self.TileColor then self.TileColor = getTileColor() end

    -- OBJECTS DECLARATION
    self.Background = Image(self.Directory .. "/assets/Background.png")
    self.Background.Anchor = Vector2(.5, .5)
    self.Background.Position = self.BoundPos
    self.Background.Size = self.BoundSize
    self.add(self.Background, 0)

    local pos = 0.2
    for _,i in pairs(shuffle(PossibleColors)) do
        local Icon = Image(self.Directory .. "/assets/" .. i .. ".png")
        Icon.Anchor = Vector2(.5, .5)
        Icon.Position = Vector2(self.BoundSize.X*pos, self.BoundPos.Y)
        Icon.Size = Vector2(self.BoundSize.Y*.3, self.BoundSize.Y*.3)
        
        if i == self.TileColor then
            self.ObjectiveObj = Icon
        end
        
        self.add(Icon, 3)

        pos = pos + .2
    end
    
    self.PlayerCharacter = Spritesheet(self.Directory .. "/assets/creature-sheet.png", Vector2(24, 24), .35/self.GameSpeed)
    self.PlayerCharacter.Size = Vector2(100, 100)
    self.PlayerCharacter.Anchor = Vector2(.5, .5)
    self.PlayerCharacter.Position = self.BoundPos
    self.PlayerCharacter.Velocity = Vector2(0, 0)
    self.PlayerCharacter.MoveDirection = {W = 0, A = 0, S = 0, D = 0}
    self.PlayerCharacter.Speed = 300
    self.add(self.PlayerCharacter, 5)

    -- BIND KEYS
    self.BindKey("Up", function(Began)
        self.PlayerCharacter.MoveDirection.W = Began and 1 or 0
    end)
    self.BindKey("Down", function(Began)
        self.PlayerCharacter.MoveDirection.S = Began and 1 or 0
    end)
    self.BindKey("Right", function(Began)
        self.PlayerCharacter.MoveDirection.D = Began and 1 or 0
    end)
    self.BindKey("Left", function(Began)
        self.PlayerCharacter.MoveDirection.A = Began and 1 or 0
    end)
end

-- This is ran once the player has control over the minigame, All your binds should work at this point
function module:Start()
    local GAME = self.GAME

    -- Play dah music
    local m = self.PlayMusic(self.Directory .. "/assets/music.mp3")
    if not m then return end

    m:setPitch(self.GameSpeed)
end

-- This is where you update stuff. That's it...
function module:Update(dt)
    local GAME = self.GAME
    dt = dt * self.GameSpeed

    self:Update_Character(dt)
end

-- This is the last frame, update will stop running, but you can show random shit here
function module:Stop()
    local GAME = self.GAME

    if self:Check_Win() then
        self:Success()
    else
        self:Fail()
    end
end

-- This is just to cleanup your game, incase you need to make sure stuff is really destroyed in case of memory leak
function module:Cleanup()
    local GAME = self.GAME

end

return module