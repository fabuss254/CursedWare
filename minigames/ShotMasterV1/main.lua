----Linez Guillaume 2021

    --Variables locales
    local shotPix = 0
    local glouglouPix = 0
    local glouglouPos = 1
    local glouglouKeyPressed = {false, false}--Est sur true si -> ou <- active
    local rotation = math.pi
    --local SourceAudio = love.audio.newSource("assets/glougloutheme.mp3", "static")
    local ScreenSize = {1280, 1024}
    local placeOccupe = {false, false, false, false}
    local placeShot = {false, false, false, false}
    local tpsShot = {0, 0, 0, 0}
    local placeOrange = {false, false, false, false}
    local placeTime = {0, 0, 0, 0}
    local ramdomPosShot = 1
    local time1 = 0
    local time2 = -1
    local ratio_temps = 1
    local temps_spawn_verre = 3
    local temps_depop_verre = 15
    local shotPix = 0
    local clearIndex = 1

    --Chargement des images et de la fenetre
    function love.load()
        love.graphics.setDefaultFilter( "nearest" )
        love.window.setMode(ScreenSize[1], ScreenSize[2], {resizable=false, vsync=false})
        --Font = love.graphics.newImage("assets/img_px/spritesheet.png")
        Glouglou = love.graphics.newImage("assets/img_px/bouteille_vdk_px.png")
        Shot = love.graphics.newImage("assets/img_px/shot_vide_px.png")
        GlouglouWidth = Glouglou:getWidth()
        ShotWidth = Shot:getWidth()
    end

    --Affichages des elements
    function love.draw()
        love.graphics.draw(Glouglou, glouglouPix, 300, rotation, 10, 10)
        love.graphics.draw(Shot, shotPix, 600, 0, 20, 20)
        love.graphics.print(love.timer.getTime(), 900, 900)
        love.graphics.print(ShotWidth, 900, 870)
        love.graphics.print(shotPix, 900, 840)
    end

    --Updates en temps réel
    function love.update(dt)
        --SourceAudio:play()

        --Position des elements

        glouglouPix=((GlouglouWidth/2)*10)+(256*glouglouPos)
        shotPix=(256*ramdomPosShot)-50

        ---Analyse des touches
        --Right
        if love.keyboard.isDown("right") and glouglouKeyPressed[1] == false then
            glouglouKeyPressed[1] = true
            if (glouglouPos == 4) == false then
                glouglouPos = glouglouPos+1
            end
        end
        if love.keyboard.isDown("right") == false then
            glouglouKeyPressed[1] = false
        end
        --Left
        if love.keyboard.isDown("left") and glouglouKeyPressed[2] == false then
            glouglouKeyPressed[2] = true
            if (glouglouPos == 1) == false then
                glouglouPos = glouglouPos-1
            end
        end
        if love.keyboard.isDown("left") == false then
            glouglouKeyPressed[2] = false
        end
        time2 = love.timer.getTime()
        if (time2-time1) > temps_spawn_verre then
            --Placement des verre aléatoirement
            ramdomPosShot = math.random(1, 4)
            while placeShot[ramdomPosShot] == true do
                ramdomPosShot = math.random(1, 4)
            end
            placeShot[ramdomPosShot] = true
            tpsShot[ramdomPosShot] = love.timer.getTime()
            time1 = love.timer.getTime()
            while clearIndex < 5 do
                print(tpsShot[clearIndex], clearIndex, temps_spawn_verre)
                if tpsShot[clearIndex] < temps_spawn_verre then --pb ici
                    tpsShot[clearIndex] = 0
                    placeShot[clearIndex] = false
                end
                clearIndex = clearIndex +1
            end
            clearIndex = 1
        end
    end
