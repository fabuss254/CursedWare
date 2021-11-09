-- LIBS
local Color = require("src/classes/Color")
local Instance = require("src/libs/Instance")

-- MODULE
local module = {}

-- PRIVATE VARIABLES
local logs = {}

-- METHODS
function module.addLog(name, text, color)
    assert(Instance.typeof(color) == "Color", "Invalid argument #3 (Expected Color, got " .. Instance.typeof(color) .. ")")

    logs[name] = {
        text = text or "",
        color = color
    }
end

function module.remLog(name)
    logs[name] = nil
end

function module.updateLog(name, text, color)
    assert(not color or (Instance.typeof(color) == "Color"), "Invalid argument #3 (Expected Color, got " .. Instance.typeof(color) .. ")")

    logs[name].text = text
    logs[name].color = color or logs[name].color
end

function module.getLogs()
    return logs
end

function module.draw()
    local num = 0
    for _,v in pairs(logs) do
        v.color:Apply()
        love.graphics.print(v.text, 10, 10 + num*11)

        num = num + 1
    end
end

return module