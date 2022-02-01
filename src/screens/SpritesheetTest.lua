-- Libs
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Spritesheet = require("src/classes/Spritesheet")

local Screen = require("src/libs/Rendering/Screen")
local Renderer = require("src/libs/Rendering/Renderer")
local Controls = require("src/libs/Controls")

-- Settings
local Menu = Screen.new()

-- Objects
local Animation = Spritesheet("assets/spritesheets/IntermissionSpeakers.png", Vector2(320, 256), 2)
Animation.Size = Renderer.ScreenSize
Menu.add(Animation)

-- // Runners
function Menu.open()
    Controls.bind("e", function(e)
        if not e then return end
        print("Stop")
        Animation:stop()
    end)

    Controls.bind("r", function(e)
        if not e then return end
        print("Cancel")
        Animation:cancel()
    end)

    Controls.bind("down", function(e)
        if not e then return end
        print("Duration")
        Animation:setDuration(Animation.Duration - .05)
        print(Animation.Duration)
    end)

    Controls.bind("up", function(e)
        if not e then return end
        print("Duration")
        Animation:setDuration(Animation.Duration + .05)
        print(Animation.Duration)
    end)

    Controls.bind("z", function(e)
        if not e then return end
        print("Play")
        Animation:play()
    end)

    Animation:play()
end

function Menu.update(dt)
    
end

return Menu