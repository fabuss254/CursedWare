-- MODULE
local module = {}

-- METHODS
function module.typeof(Value)
    if type(Value) == "table" and Value._type then
        return Value._type
    end 
    return type(Value)
end

return module