-- LIBS
local Color = require("src/classes/Color")
local Instance = require("src/libs/Instance")

-- MODULE
local module = {}

-- PRIVATE VARIABLES
local logs = {}

-- METHODS
function module.updateLog(text, color)
    assert(not color or (Instance.typeof(color) == "Color"), "Invalid argument #2 (Expected Color, got " .. Instance.typeof(color) .. ")")

    table.insert(logs, {
        text = text or "",
        color = color or Color.White
    })
end

function module.cleanup()
    logs = {}
end

function module.getLogs()
    return logs
end

function module.draw()
    local num = 0
    for _,v in pairs(logs) do
        v.color:apply()
        love.graphics.print(v.text, 10, 10 + num*11)

        num = num + 1
    end
end

return module