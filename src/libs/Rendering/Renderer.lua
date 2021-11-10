-- LIBS
local Instance = require("src/libs/Instance")
local LogManager = require("src/libs/Debug/LogManager")

local Color = require("src/classes/Color")
local Vector2 = require("src/classes/Vector2")

-- MODULE
local module = {}

local Objectpool = {}
module.BackgroundColor = Color.White
module.ScreenSize = Vector2(1280, 1024)

-- METHODS
function module.add(obj, zIndex)
    assert(obj, "Argument #1 missing (Expected object, got nil)")
    assert(obj.draw, "Object doesn't have a draw function. Only add drawable object to the renderer.")
    zIndex = zIndex or 0

    table.insert(Objectpool, {obj = obj, zIndex = zIndex})
    table.sort(Objectpool, function(a, b)
        return a.zIndex > b.zIndex
    end)
    return true
end

function module.rem(obj)
    for i,v in pairs(Objectpool) do
        if v == obj then
            return table.remove(Objectpool, i)
        end
    end
end

-- EVENTS
function love.draw()
    for _,v in pairs(Objectpool) do
        v.obj:draw()
    end

    love.graphics.setColor(1, 0, 0, .5)
    love.graphics.circle("fill", module.ScreenSize.X/2, module.ScreenSize.Y/2, 5)

    love.graphics.setColor(1, 1, 1, .1)
    love.graphics.print("ATS 2021 ©", module.ScreenSize.X - 80, module.ScreenSize.Y - 20)

    module.BackgroundColor:applyBackground()
    LogManager.draw()
end

return module