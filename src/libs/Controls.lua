-- LIB
local EventConnection = require("src/classes/EventConnection")

-- MODULE
local module = {}
module.LastInput = ""

-- PRIVATE VARIABLES
local binds = {}

-- METHODS
function module.isHolding(key)
    return love.keyboard.isDown(key)
end

function module.bind(key, callback)
    if type(key) == "table" then
        for _,v in pairs(key) do
            module.bind(v, callback)
        end
        return
    end
    if not binds[key] then binds[key] = {} end

    -- Set the key's connection and a disconnection function so we can disconnect it anytime.
    local con = EventConnection(callback, function()
        for i,v in pairs(binds[key]) do
            binds[key][i] = nil
        end
    end)

    -- Insert it inside the bind
    table.insert(binds[key], con)
    return con
end

function module.unbind(key)
    if type(key) == "table" then
        for _,v in pairs(key) do
            module.unbind(v)
        end
        return
    end
    if not binds[key] then return end
    
    binds[key] = {}
end

-- EVENTS
function love.keypressed(key, scancode, isRepeat)
    module.LastInput = key
    for _,con in pairs(binds[key] or {}) do
        con:fire(true)
    end
end

function love.keyreleased(key, scancode)
    for _,con in pairs(binds[key] or {}) do
        con:fire(false)
    end
end

return module