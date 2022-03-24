-- Game made by LINEZ Guillaume
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
module.Name = "SHOT_MASTER" -- Name of the game
module.IsActive = true -- Can this game be rolled?
module.MultiplayerDisabled = true -- This game cannot be rolled in multiplayer

-- // PRIVATE VARIABLES (STATIC)

local win = true

local time = 0
local init = 0
local tour = 0

local posBouteille = 1
local tabPosX = {160, 500, 840, 1180}
local posBouteilleY = 300
local coefTailleBouteille = 7
local hauteur_verre = 650
local decalage_verre = 20

local vitesse = 1
local tpsParSpritesheet = 1.5/vitesse

local tabTouche = {false, false, false, false}--gauche droite 

local tab_verre_plein = {}
local tab_verre_vide = {}
local place_verre = {}--0 = pas de verre | 1 = vin vide | 2 = vin plein | 3 = vdk vide | 4 = vdk plein
local verre_passe = {}--vin1|vin2|vdk1|vdk2
local type_verre = {0, 0, 0, 0}--0 = pas de verre | 1 == vin1 | 2 = vin2 | 3 = vdk1 | 4 = vdk2

local tab_verre_servis = {0, 0, 0, 0}--heure a laquel les verres on été remplis


-- // PRIVATE METHODS

function module:Check_Win()
    win = true
    for i = 1,4,1 do
        if tab_verre_servis[i] == 0 then
            win = false
        end
    end
    return win
end

-- // MINIGAME METHODS

-- Should return the string that tell what to do (RUN AFTER SETUP !)
function module:GetObjective()
    return "  Remplis les shot avec de la vodka  \n     et les verre a pied avec du vin  \n"
end

-- Should return the time the player is given to finish this minigame
function module:GetTime()
    return 12/self.GameSpeed
end

-- 2 player compatibility, You can retrieve the objective from the other minigame and put it into this one
function module:getObjective()
    return self.ShotMaster
end

function module:setObjective(Obj)
    self.ShotMaster = Obj
end

function module:desaparitionVerre()
    for i = 1,4,1 do
        if time - tab_verre_servis[i] > 3 then
            tab_verre_plein[i].Position = Vector2(8000, 8000)
        end
    end
    return true
end

function module:update_verre()
    local nbr_verre_a_remplir = 4
    local tps_entre_spawn_verre = self:GetTime()/nbr_verre_a_remplir
    local random_pos = -1
    local choix_type = -1
    
    if (time > tps_entre_spawn_verre*tour) and (tour < nbr_verre_a_remplir) then
        tour = tour + 1
        random_pos = math.random(1, 4)
        while (place_verre[random_pos] == 0) == false do
            random_pos = math.random(1, 4)
        end
        choix_type = math.random(1, 4)
        while (verre_passe[choix_type] == true) do
            choix_type = math.random(1, 4)
        end
        verre_passe[choix_type] = true
        type_verre[random_pos] = choix_type
        if choix_type < 3 then
            place_verre[random_pos] = 1
        else
            place_verre[random_pos] = 3
        end
        tab_verre_vide[choix_type].Position = Vector2(tabPosX[random_pos] - decalage_verre, hauteur_verre)
        tab_verre_vide[choix_type].Size = Vector2(7 * 5 * coefTailleBouteille, 9 * 5 * coefTailleBouteille)
        TweenService.new(.5/self.GameSpeed, tab_verre_vide[choix_type].Size, {X = 7 * coefTailleBouteille, Y = 9 * coefTailleBouteille}, "outCubic"):play()
    end
end

function module:update_position(dt)
    local inputVdk = self.bouteille_vdk
    local inputVin = self.bouteille_vin

    if (inputVdk.MoveDirection.D == 1) and ((posBouteille == 4)==false) then
        if tabTouche[1] == false then
            tabTouche[1] = true
            posBouteille = posBouteille + 1
        end
    end
    if (inputVdk.MoveDirection.D == 0) then
        tabTouche[1] = false
    end
    if (inputVdk.MoveDirection.A == 1) and ((posBouteille == 1)==false) then
        if tabTouche[2] == false then
            tabTouche[2] = true
            posBouteille = posBouteille - 1
        end
    end
    if (inputVdk.MoveDirection.A == 0) then
        tabTouche[2] = false
    end
    if (inputVin.Coule.On == 1) and (tabTouche[3] == false)then
        tabTouche[3] = true
        self.vin_coule.Position = self.bouteille_vin.Position
        if place_verre[posBouteille] == 1 then
            place_verre[posBouteille] = 2
            tab_verre_vide[type_verre[posBouteille]].Position = Vector2(8000, 8000)
            tab_verre_plein[type_verre[posBouteille]].Position = Vector2(tabPosX[posBouteille] - decalage_verre, hauteur_verre)
            tab_verre_servis[type_verre[posBouteille]] = time
        end
        if place_verre[posBouteille] == 3 then
            local random_new_pos = math.random(1, 4)
            place_verre[posBouteille] = 0
            while place_verre[random_new_pos] ~= 0 do
                random_new_pos = (random_new_pos + 1)%4
            end
            if random_new_pos ~= posBouteille then
                place_verre[random_new_pos] = 3
                type_verre[random_new_pos] = type_verre[posBouteille]
                tab_verre_vide[type_verre[posBouteille]].Position = Vector2(tabPosX[random_new_pos] - decalage_verre, hauteur_verre)
                type_verre[posBouteille] = 0
            else
                place_verre[posBouteille] = 3
            end
        end
    end
    if (inputVin.Coule.On == 0) and (tabTouche[3] == true) then
        tabTouche[3] = false
        self.vin_coule.Position = Vector2(8000, 8000)
    end
    if (inputVdk.Coule.On == 1) and (tabTouche[4] == false)then
        tabTouche[4] = true
        self.vdk_coule.Position = self.bouteille_vdk.Position
        if place_verre[posBouteille] == 3 then
            place_verre[posBouteille] = 4
            tab_verre_vide[type_verre[posBouteille]].Position = Vector2(8000, 8000)
            tab_verre_plein[type_verre[posBouteille]].Position = Vector2(tabPosX[posBouteille] - decalage_verre, hauteur_verre)
            tab_verre_servis[type_verre[posBouteille]] = time
        end
        if place_verre[posBouteille] == 1 then
            local random_new_pos = math.random(1, 4)
            place_verre[posBouteille] = 0
            while place_verre[random_new_pos] ~= 0 do
                random_new_pos = (random_new_pos + 1)%4
            end
            if random_new_pos ~= posBouteille then
                place_verre[random_new_pos] = 1
                type_verre[random_new_pos] = type_verre[posBouteille]
                tab_verre_vide[type_verre[posBouteille]].Position = Vector2(tabPosX[random_new_pos] - decalage_verre, hauteur_verre)
                type_verre[posBouteille] = 0
            else
                place_verre[posBouteille] = 1
            end
        end
    end
    if (inputVdk.Coule.On == 0) and (tabTouche[4] == true) then
        tabTouche[4] = false
        self.vdk_coule.Position = Vector2(8000, 8000)
    end
end

-- // MINIGAME RUNNERS

-- This is ran first, before it's visible on screen. You can start playing music here.
function module:Setup() 
    local GAME = self.GAME

    --VAR
    time = 0
    init = 0
    tour = 0
    posBouteille = 1
    type_verre = {0, 0, 0, 0}
    tab_verre_servis = {0, 0, 0, 0}

    -- OBJECTS DECLARATION
    self.Background = Spritesheet(self.Directory .. "/assets/spritesheet_bar.png", Vector2(160, 128), tpsParSpritesheet)
    self.Background.Anchor = Vector2(.5, .5)
    self.Background.Position = self.BoundPos
    self.Background.Size = Vector2(1280, 1024)
    self.add(self.Background, 0)
    self.Background:play()

    self.bouteille_vdk = Image(self.Directory .. "/assets/img_px/bouteille_vdk_px.png")
    self.bouteille_vdk.Anchor = Vector2(.5, .5)
    self.bouteille_vdk.Position = Vector2(tabPosX[posBouteille]-5, posBouteilleY)
    self.bouteille_vdk.Size = Vector2(10 * coefTailleBouteille, 28 * coefTailleBouteille)
    self.bouteille_vdk.MoveDirection = {A = 0, D = 0}
    self.bouteille_vdk.Coule = {On = 0}
    self.add(self.bouteille_vdk, 0)

    self.bouteille_vin = Image(self.Directory .. "/assets/img_px/bouteille_vin_px.png")
    self.bouteille_vin.Anchor = Vector2(.5, .5)
    self.bouteille_vin.Position = Vector2(tabPosX[posBouteille]+5, posBouteilleY)
    self.bouteille_vin.Size = Vector2(10 * coefTailleBouteille, 28 * coefTailleBouteille)
    self.bouteille_vin.MoveDirection = {A = 0, D = 0}
    self.bouteille_vin.Coule = {On = 0}
    self.add(self.bouteille_vin, 0)

    self.vin_coule = Spritesheet(self.Directory .."/assets/img_px/vin_coule_spritesheet.png", Vector2(2, 50), 0.5)
    self.vin_coule.Anchor = Vector2(.5, -0.25)
    self.vin_coule.Position = Vector2(8000, 8000)
    self.vin_coule.Size = Vector2(2 * coefTailleBouteille, 35 * coefTailleBouteille)
    self.add(self.vin_coule, 0)
    self.vin_coule:play()

    self.vdk_coule = Spritesheet(self.Directory .."/assets/img_px/vdk_coule_spritesheet.png", Vector2(2, 50), 0.5)
    self.vdk_coule.Anchor = Vector2(.5, -0.455)
    self.vdk_coule.Position = Vector2(8000, 8000)
    self.vdk_coule.Size = Vector2(2 * coefTailleBouteille, 30 * coefTailleBouteille)
    self.add(self.vdk_coule, 0)
    self.vdk_coule:play()

    self.verre_vide_vin = Image(self.Directory .. "/assets/img_px/verre_vide_px.png")
    self.verre_vide_vin.Anchor = Vector2(.5, .5)
    self.verre_vide_vin.Position = Vector2(8000, 8000)
    self.verre_vide_vin.Size = Vector2(7 * coefTailleBouteille, 9 * coefTailleBouteille)
    self.add(self.verre_vide_vin, 0)

    self.verre_plein_vin = Image(self.Directory .. "/assets/img_px/verre_plein_px.png")
    self.verre_plein_vin.Anchor = Vector2(.5, .5)
    self.verre_plein_vin.Position = Vector2(8000, 8000)
    self.verre_plein_vin.Size = Vector2(7 * coefTailleBouteille, 9 * coefTailleBouteille)
    self.add(self.verre_plein_vin, 0)

    self.shot_vide_vdk = Image(self.Directory .. "/assets/img_px/shot_vide_px.png")
    self.shot_vide_vdk.Anchor = Vector2(.5, .5)
    self.shot_vide_vdk.Position = Vector2(8000, 8000)
    self.shot_vide_vdk.Size = Vector2(7 * coefTailleBouteille, 9 * coefTailleBouteille)
    self.add(self.shot_vide_vdk, 0)

    self.shot_plein_vdk = Image(self.Directory .. "/assets/img_px/shot_plein_px.png")
    self.shot_plein_vdk.Anchor = Vector2(.5, .5)
    self.shot_plein_vdk.Position = Vector2(8000, 8000)
    self.shot_plein_vdk.Size = Vector2(7 * coefTailleBouteille, 9 * coefTailleBouteille)
    self.add(self.shot_plein_vdk, 0)

    self.verre_vide_vin2 = Image(self.Directory .. "/assets/img_px/verre_vide_px.png")
    self.verre_vide_vin2.Anchor = Vector2(.5, .5)
    self.verre_vide_vin2.Position = Vector2(8000, 8000)
    self.verre_vide_vin2.Size = Vector2(7 * coefTailleBouteille, 9 * coefTailleBouteille)
    self.add(self.verre_vide_vin2, 0)

    self.verre_plein_vin2 = Image(self.Directory .. "/assets/img_px/verre_plein_px.png")
    self.verre_plein_vin2.Anchor = Vector2(.5, .5)
    self.verre_plein_vin2.Position = Vector2(8000, 8000)
    self.verre_plein_vin2.Size = Vector2(7 * coefTailleBouteille, 9 * coefTailleBouteille)
    self.add(self.verre_plein_vin2, 0)

    self.shot_vide_vdk2 = Image(self.Directory .. "/assets/img_px/shot_vide_px.png")
    self.shot_vide_vdk2.Anchor = Vector2(.5, .5)
    self.shot_vide_vdk2.Position = Vector2(8000, 8000)
    self.shot_vide_vdk2.Size = Vector2(7 * coefTailleBouteille, 9 * coefTailleBouteille)
    self.add(self.shot_vide_vdk2, 0)

    self.shot_plein_vdk2 = Image(self.Directory .. "/assets/img_px/shot_plein_px.png")
    self.shot_plein_vdk2.Anchor = Vector2(.5, .5)
    self.shot_plein_vdk2.Position = Vector2(8000, 8000)
    self.shot_plein_vdk2.Size = Vector2(7 * coefTailleBouteille, 9 * coefTailleBouteille)
    self.add(self.shot_plein_vdk2, 0)

    tab_verre_plein = {self.verre_plein_vin, self.verre_plein_vin2, self.shot_plein_vdk, self.shot_plein_vdk2}
    tab_verre_vide = {self.verre_vide_vin, self.verre_vide_vin2, self.shot_vide_vdk, self.shot_vide_vdk2}
    place_verre = {0, 0, 0, 0}--0 = pas de verre | 1 = vin vide | 2 = vin plein | 3 = vdk vide | 4 = vdk plein
    verre_passe = {false, false, false, false}--vin1|vin2|vdk1|vdk2
    vitesse = self.GameSpeed
    tpsParSpritesheet = 1.5/vitesse

    self.BindKey("Right", function(Began)
        self.bouteille_vdk.MoveDirection.D = Began and 1 or 0
        self.bouteille_vin.MoveDirection.D = Began and 1 or 0
    end)
    self.BindKey("Left", function(Began)
        self.bouteille_vdk.MoveDirection.A = Began and 1 or 0
        self.bouteille_vin.MoveDirection.A = Began and 1 or 0
    end)
    self.BindKey("Button3", function (Began)
        self.bouteille_vin.Coule.On = Began and 1 or 0
    end)
    self.BindKey("Button1", function (Began)
        self.bouteille_vdk.Coule.On = Began and 1 or 0
    end)
    
end

-- This is ran once the player has control over the minigame, All your binds should work at this point
function module:Start()
    local GAME = self.GAME

    -- Play dah music
    local m = self.PlayMusic(self.Directory .. "/assets/kamaz.mp3")
    if not m then return end

    m:setPitch(self.GameSpeed)
end

-- This is where you update stuff. That's it...
function module:Update(dt)
    local GAME = self.GAME
    time = time + dt
    dt = dt * self.GameSpeed
    
    self:desaparitionVerre()
    self:update_position()
    self:update_verre()

    --Update de la position des bouteilles
    self.bouteille_vdk.Position = Vector2(tabPosX[posBouteille]-50, posBouteilleY)
    self.bouteille_vin.Position = Vector2(tabPosX[posBouteille]+50, posBouteilleY)
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