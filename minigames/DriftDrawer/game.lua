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
module.Name = "Drift Drawer" -- Name of the game
module.IsActive = true -- Can this game be rolled?

-- // PRIVATE VARIABLES (STATIC)
local ZeroVector = Vector2()
local Rad360 = math.pi * 2
local Rad180 = math.pi

local Red = Color(1, 0.333333333, 0.309803922)
local Green = Color(0.321568627, 1, 0.329411765)

local Stages = {
    {
        Difficulty = 1,
        Flags = {{{0.5, 0.5}, 0.4}, {{0.85, 0.75}, 0.4}} -- Each flag is position relative to BoundPos and BoundSize (for example here, This will be Position: BoundPos * .5 | Size: BoundSize.Y * .4)
    },
    {
        Difficulty = 1,
        Flags = {{{0.25, 0.5}, 0.4}, {{0.75, 0.5}, 0.4}}
    },
    {
        Difficulty = 1,
        Flags = {{{0.5, 0.5}, 0.4}, {{0.85, 0.5}, 0.4}}
    },


    {
        Difficulty = 2,
        Flags = {{{0.5, 0.25}, 0.3}, {{0.85, 0.5}, 0.4}}
    },
    {
        Difficulty = 2,
        Flags = {{{0.25, 0.25}, 0.3}, {{0.75, 0.25}, 0.4}}
    },
    {
        Difficulty = 2,
        Flags = {{{0.25, 0.75}, 0.3}, {{0.75, 0.75}, 0.4}}
    },

    {
        Difficulty = 3,
        Flags = {{{0.5, 0.25}, 0.3}, {{0.85, 0.5}, 0.3}}
    },
    {
        Difficulty = 3,
        Flags = {{{0.25, 0.25}, 0.3}, {{0.75, 0.25}, 0.3}}
    },
    {
        Difficulty = 3,
        Flags = {{{0.25, 0.75}, 0.3}, {{0.75, 0.75}, 0.3}}
    },
    {
        Difficulty = 3,
        Flags = {{{0.25, 0.5}, 0.4}, {{0.35, 0.25}, 0.4}, {{0.5, 0.5}, 0.4}, {{0.75, 0.75}, 0.4}, {{0.9, 0.5}, 0.4}}
    },


    {
        Difficulty = 4,
        Flags = {{{0.5, 0.75}, 0.25}, {{0.5, 0.25}, 0.25}}
    },
    {
        Difficulty = 4,
        Flags = {{{0.25, 0.5}, 0.3}, {{0.5, 0.25}, 0.3}, {{0.75, 0.75}, 0.3}, {{0.9, 0.25}, 0.3}}
    },


    {
        Difficulty = 5,
        Flags = {{{0.25, 0.75}, 0.25}, {{0.25, 0.25}, 0.25}, {{0.75, 0.75}, 0.25}, {{0.75, 0.25}, 0.25}}
    },
    {
        Difficulty = 5,
        Flags = {{{0.25, 0.5}, 0.3}, {{0.5, 0.25}, 0.3}, {{0.75, 0.75}, 0.3}, {{0.9, 0.5}, 0.3}}
    },
}
local MaxDifficulty = 5

-- // PRIVATE METHODS
function MoveTowards(current, target, maxDistanceDelta) -- Wonked from Unity's Vector3 lib: https://github.com/Unity-Technologies/UnityCsReference/blob/master/Runtime/Export/Math/Vector3.cs
    local toVector_x = target.X - current.X
    local toVector_y = target.Y - current.Y

    local sqdist = toVector_x * toVector_x + toVector_y * toVector_y

    if (sqdist == 0 or (maxDistanceDelta >= 0 and sqdist <= maxDistanceDelta * maxDistanceDelta)) then
        return target
    end

    local dist = math.sqrt(sqdist)
    return Vector2(
        current.X + toVector_x / dist * maxDistanceDelta,
        current.Y + toVector_y / dist * maxDistanceDelta
    )
end

function c_mod(a, n) -- Custom modulo function to prevent modulo from giving the same sign as the dividend
    return a - math.floor(a/n) * n
end

function module:UpdateCar(dt)
    local Character = self.Car
    local Input = Character.MoveDirection
    local MoveVector = Vector2(Input.D - Input.A, Input.S - Input.W)
    local LastPos = Character.Position:Clone()
    
    -- Compute rotation of the vehicle
    local TargetRotation = (MoveVector ~= ZeroVector and math.atan2(MoveVector.Y, MoveVector.X)) or Character.Rotation
    local Theta = (TargetRotation - Character.Rotation)
    Theta = c_mod(Theta + Rad180, Rad360) - Rad180 -- Prevent from looping around, see this post for explanation: https://stackoverflow.com/questions/1878907/how-can-i-find-the-difference-between-two-angles

    -- 2D Vehicle physic
    Character.Velocity = MoveTowards(Character.Velocity, MoveVector:getUnit(), dt/.75) -- Turn velocity in under 0.2s
    Character.Position = Character.Position + Character.Velocity * dt * Character.Speed
    Character.Rotation = (Character.Rotation + Theta*dt/.3)

    -- Bound to boundaries
    Character.Position.Y = math.max(math.min(Character.Position.Y, self.BoundPos.Y + self.BoundSize.Y/2), self.BoundPos.Y - self.BoundSize.Y/2)
    Character.Position.X = math.max(math.min(Character.Position.X, self.BoundSize.X), 0)

    -- Check if they got through some flags
    local Pos = Character.Position
    local AvgY = (LastPos.Y + Pos.Y) / 2
    for i,v in pairs(self.Flags) do
        if v then
            local PassedX = (LastPos.X < v.Pos.X and Pos.X > v.Pos.X) or (LastPos.X > v.Pos.X and Pos.X < v.Pos.X)
            local InBoundY = AvgY < v.Pos.Y + v.Size and AvgY > v.Pos.Y - v.Size

            if PassedX and InBoundY then
                v.FlagTop.Color = Green
                v.FlagBottom.Color = Green
                self.Flags[i] = nil
                self.NumOfFlags = self.NumOfFlags - 1
                if self.NumOfFlags <= 0 then
                    self:Success()
                end
            end
        end
    end
end

function module:AddFlag(Pos, Size)
    local Flag = {}
    local YSize = Vector2(0, Size/2)

    Flag.Pos = Pos
    Flag.Size = Size/2

    Flag.FlagTop = Image(self.Directory .. "/assets/Flag.png")
    Flag.FlagTop.Size = Vector2(30, 30)
    Flag.FlagTop.Anchor = Vector2(.5, .5)
    Flag.FlagTop.Position = Pos + YSize
    Flag.FlagTop.Color = Red

    Flag.FlagBottom = Image(self.Directory .. "/assets/Flag.png")
    Flag.FlagBottom.Size = Vector2(30, 30)
    Flag.FlagBottom.Anchor = Vector2(.5, .5)
    Flag.FlagBottom.Position = Pos - YSize
    Flag.FlagBottom.Color = Red

    self.add(Flag.FlagBottom, 2)
    self.add(Flag.FlagTop, 2)
    return Flag
end

function module:GetStageTemplate()
    local Dif = math.min(self.GameDifficulty, MaxDifficulty)

    local AvailableStages = {}
    for _,v in pairs(Stages) do
        if v.Difficulty == Dif then
            table.insert(AvailableStages, v)
        end
    end

    if self.StageNum then return (AvailableStages or Stages)[self.StageNum] end

    if not AvailableStages then
        print("NO STAGE AVAILABLE FOR DIFFICULTY " .. Dif)
        self.StageNum = 1
        return Stages[1]
    end

    self.StageNum = math.random(1, #AvailableStages)
    return AvailableStages[self.StageNum]
end

function module:CreateStage()
    self.Flags = {}
    local Stage = self:GetStageTemplate()

    for _,v in pairs(Stage.Flags) do
        table.insert(self.Flags, self:AddFlag(Vector2(self.BoundPos.X + self.BoundSize.X * (v[1][1] - .5), self.BoundPos.Y + self.BoundSize.Y * (v[1][2] - .5)), self.BoundSize.Y * v[2]))
    end

    self.NumOfFlags = #self.Flags
end

-- // MINIGAME METHODS

-- Should return the string that tell what to do (RUN AFTER SETUP !)
function module:GetObjective()
    return "Passe entre les drapeaux !"
end

-- Should return the time the player is given to finish this minigame
function module:GetTime()
    return 7/self.GameSpeed -- Divide by game speed to shrink the time remaining to complete the game at high speed
end

-- 2 player compatibility, You can retrieve the objective from the other minigame and put it into this one
function module:getObjective()
    return self.StageNum
end

function module:setObjective(Obj)
    self.StageNum = Obj
end

-- // MINIGAME RUNNERS

-- This is ran first, before it's visible on screen. You can start playing music here.
function module:Setup() 
    local GAME = self.GAME

    self.Car = Image(self.Directory .. "/assets/Car.png")
    self.Car.Anchor = Vector2(.5, .5)
    self.Car.Position = self.BoundPos - Vector2(self.BoundSize.X - 50, 0)
    self.Car.Size = Vector2(112, 75)
    self.Car.Rotation = 0
    self.Car.MoveDirection = {W=0, S=0, D=0, A=0}
    self.Car.Velocity = Vector2()
    self.Car.Speed = 500
    self.add(self.Car, 5)

    self.Background = Image(self.Directory .. "/assets/Background.png")
    self.Background.Anchor = Vector2(.5, .5)
    self.Background.Position = self.BoundPos
    self.Background.Size = self.BoundSize
    self.add(self.Background, 0)

    self:CreateStage()

    self.BindKey("Up", function(Began)
        self.Car.MoveDirection.W = Began and 1 or 0
    end)
    self.BindKey("Down", function(Began)
        self.Car.MoveDirection.S = Began and 1 or 0
    end)
    self.BindKey("Right", function(Began)
        self.Car.MoveDirection.D = Began and 1 or 0
    end)
    self.BindKey("Left", function(Began)
        self.Car.MoveDirection.A = Began and 1 or 0
    end)
end

-- This is ran once the player has control over the minigame, All your binds should work at this point
function module:Start()
    local GAME = self.GAME

    local m = self.PlayMusic(self.Directory .. "/assets/Music.ogg")
    if not m then return end

    m:setPitch(self.GameSpeed)
end

-- This is where you update stuff. That's it...
function module:Update(dt)
    local GAME = self.GAME
    dt = dt * self.GameSpeed -- Quick way to speed up the game if you're managing character velocity for example

    self:UpdateCar(dt)
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