local module = {}
local screenPool = {}

function module.new(Name)
    local self = {}
    self.Name = "SCREEN"
    self.Objectpool = {}
    self.drawId = 0

    function self.add(obj, zIndex)
        assert(obj, "Argument #1 missing (Expected object, got nil)")
        assert(obj.draw, "Object doesn't have a draw function. Only add drawable object to the group.")
        zIndex = zIndex or 0
        obj.drawId = self.drawId
        self.drawId = self.drawId + 1

        table.insert(self.Objectpool, {obj = obj, zIndex = zIndex})
        table.sort(self.Objectpool, function(a, b)
            return a.zIndex < b.zIndex
        end)
        return true
    end

    function self.rem(obj)
        if not obj.drawId then return end
        for i,v in pairs(self.Objectpool) do
            if v.obj.drawId == obj.drawId then
                return table.remove(self.Objectpool, i)
            end
        end
    end

    function self.update2(dt)
        for _,v in pairs(self.Objectpool) do
            if v.obj.update then
                v.obj:update(dt)
            end
        end
    end

    function self:draw(time)
        for _,v in pairs(self.Objectpool) do
            v.obj:draw(time)
        end
    end

    -- // Modifiables
    function self.open() end
    function self.cleanup() end

    screenPool[Name] = self
    return self
end

function module.get(Name)
    if not screenPool[Name] then
        require("src/screens/" .. Name)
    end

    return screenPool[Name]
end

return module