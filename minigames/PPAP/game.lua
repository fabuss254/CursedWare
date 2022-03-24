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
module.Name = "PPAP" -- Name of the game
module.IsActive = true -- Can this game be rolled?
module.MultiplayerDisabled = true -- game doesn't support multiplayer

-- // PRIVATE VARIABLES (STATIC)

local inverseur_vecteur=1
local vitesse_deplacement=1 -- 1 is easy 5 is hard
local InputCooldown = 3
local LastInput = 0
local is_pressed = false
local is_testable_1=false
local is_testable_2=false
local is_testable_3=false
local current_fruit=1
local TabObjet={}
local has_lost=false

local errorMarging = 100

-- // PRIVATE METHODS


-- // MINIGAME METHODS

-- Should return the string that tell what to do (RUN AFTER SETUP !)
function module:GetObjective()
    return "    Aligne les elements\nEnvoie le stick a gauche"
end

-- Should return the time the player is given to finish this minigame
function module:GetTime()
    return 10/self.GameSpeed -- Divide by game speed to shrink the time remaining to complete the game at high speed
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

    current_fruit=1
    TabObjet={}
    local inverseur_vecteur=1
    local vitesse_deplacement=2*self.GameSpeed -- 1 is easy 5 is hard
    local InputCooldown = 3
    local LastInput = 0
    local is_pressed = false
    local is_testable_1=false
    local is_testable_2=false
    local is_testable_3=false
    local has_lost=false


    local GAME = self.GAME
    --images load

    -- BACKGROUND --
    self.background = Square()
    self.background.Anchor = Vector2(0, 0)
    self.background.Size = Vector2(1280,1024)
    self.add(self.background,-5)
    -- ANANAS
    self.Ananas = Image(self.Directory .. "/assets/Ananas.png")
    self.Ananas.Anchor=Vector2(.5,.5)
    self.Ananas.Position=Vector2(1000,math.random(200, 800))
    self.Ananas.Size=Vector2(360,180)
    TabObjet[4]=self.Ananas
    -- APPLE --
    self.Apple = Image(self.Directory .. "/assets/Apple.png")
    self.Apple.Anchor = Vector2(.5, .5)
    self.Apple.Position = Vector2(1000,math.random(200, 800))
    self.Apple.Size = Vector2(240, 200)
    TabObjet[2]=self.Apple
    -- PEN1 --
    self.Pen1 = Image(self.Directory .. "/assets/Pen.png")
    self.Pen1.Anchor=Vector2(.5,.5)
    self.Pen1.Position = Vector2(1000,math.random(200, 800))
    self.Pen1.Size= Vector2(580,40)
    TabObjet[1]=self.Pen1
    self.add(self.Pen1, 0)
    -- PEN2 --    
    self.Pen2 = Image(self.Directory .. "/assets/Pen.png")
    self.Pen2.Anchor=Vector2(.5,.5)
    self.Pen2.Position = Vector2(1000,math.random(200, 800))
    self.Pen2.Size= Vector2(580,40)
    TabObjet[3]=self.Pen2

    -- BUTTON BIND
    for i=1, 2 do
        self.BindKey(i == 1 and "Left" or "Button1", function(began) -- mouvement joystick sur la gauche
            if not began then return end
            if not has_lost and current_fruit <= 4 then
                local EndPos = 200*current_fruit
                local dFruit = current_fruit

                local hasFailedShot = dFruit ~= 1 and (TabObjet[dFruit].Position.Y>=TabObjet[dFruit-1].Position.Y+errorMarging or TabObjet[dFruit].Position.Y<=TabObjet[dFruit-1].Position.Y-errorMarging)
                TweenService.new(0.4/self.GameSpeed, TabObjet[current_fruit].Position, {X = EndPos}, "outBack"):play()
                DelayService.new(0.4/self.GameSpeed, function()
                    if hasFailedShot then
                        self:Fail()
                        has_lost=true
                    elseif dFruit == 4 then
                        Win()
                    end
                end)
                
                current_fruit = current_fruit + 1 -- increment the value of the fruit to display
                if TabObjet[current_fruit] then
                    self.add(TabObjet[current_fruit],current_fruit)
                end
            end
        end)
    end
end

-- This is ran once the player has control over the minigame, All your binds should work at this point
function module:Start()
    local GAME = self.GAME

    -- Play the music here | WARNING, The second player's minigame won't get the music object, so check if it exist before continuing.
    
    local m = self.PlayMusic(self.Directory .. "/assets/music.mp3")
    if not m then return end

    m:setPitch(self.GameSpeed)
end


-- This is where you update stuff. That's it...
function module:Update(dt)
    local GAME = self.GAME
    dt = dt * self.GameSpeed -- Quick way to speed up the game if you're managing character velocity for example
    if current_fruit > 4 then return end

    if TabObjet[current_fruit].Position.Y>=900 then
        inverseur_vecteur=-1
    end
    if TabObjet[current_fruit].Position.Y<=100 then
        inverseur_vecteur=1
    end
    TabObjet[current_fruit].Position = TabObjet[current_fruit].Position + Vector2(0, inverseur_vecteur*vitesse_deplacement * dt * 500) -- Modification position item

    --[[
    if self.PlayerID == 1 and self:GetTimeRemaining() < 1 then
        self:Fail()
        has_lost=true
    end
    ]]
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

function Win()
    TabObjet[1].Position= Vector2(640-290-40,512)
    TabObjet[2].Position= Vector2(640-40,512)
    TabObjet[3].Position= Vector2(640+290-40,512)
    TabObjet[4].Position= Vector2(640+290+180-40,512)
    self:Success()
end

return module
