-- // LIBS
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

local GAME = require("src/screens/GAME").GAME

-- // MANDATORY LIB DECLARATION
local module = {}

-- // MINIGAME SETTINGS
module.Name = "TEST_GAME" -- Nom du jeu?
module.IsActive = true -- Est ce que le jeu peut être jouer?

-- // PRIVATE VARIABLES
local PossibleColors = {
    ["le Rond Rouge"] = Color(1, 0, 0),
    ["le Triangle Jaune"] = Color(1, 1, 0),
    ["le Carre Vert"] = Color(0, 1, 0),
    ["l'Etoile Bleu"] = Color(0, 0, 1)
}
local TileColor

local Background = Image()

local PlayerCharacter = Spritesheet(GAME.GameDirectory .. "/assets/creature-sheet.png", Vector2(24, 24), .5)
PlayerCharacter.Size = Vector2(100, 100)
PlayerCharacter.Anchor = Vector2(.5, .5)
PlayerCharacter.Position = Vector2(Renderer.ScreenSize*.5, Renderer.ScreenSize*.5)
PlayerCharacter.Velocity = Vector2(0, 0)

-- // PRIVATE METHODS
function getTileColor()
    local v = {}
    for i,_ in pairs(PossibleColors) do
        table.insert(v, i)
    end
    return v[math.random(1, #v)]
end

-- // MINIGAME METHODS

-- Should return the string that tell what to do
function module.GetObjective()
    TileColor = getTileColor()

    return "Va sur " .. TileColor .. " !"
end

-- Should return the time the player is given to finish this minigame
function module.GetTime()
    return 10
end

-- // MINIGAME RUNNERS

-- This is ran first, before it's visible on screen. You can start playing music here.
function module.Setup() 

end

-- This is ran once the player has control over the minigame, All your binds should work at this point
function module.Start()

end

-- This is where you update stuff. That's it...
function module.Update(dt)

end

-- This is the last frame, update will stop running, but you can show random shit here
function module.Stop()

end

-- This is just to cleanup your game, incase you need to make sure stuff is really destroyed in case of memory leak
function module.Cleanup()

end

return module