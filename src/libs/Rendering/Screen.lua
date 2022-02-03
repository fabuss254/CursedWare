local module = {}
local screenPool = {}

function module.new()
    local tbl = {}
    --self.Name = "SCREEN"
    tbl.Objectpool = {}
    local drawCount = 0

    function tbl.add(obj, zIndex)
        assert(obj, "Argument #1 missing (Expected object, got nil)")
        assert(obj.draw, "Object doesn't have a draw function. Only add drawable object to the group.")
        zIndex = zIndex or 0
        obj.drawId = drawCount
        drawCount = drawCount + 1

        table.insert(tbl.Objectpool, {obj = obj, zIndex = zIndex})
        table.sort(tbl.Objectpool, function(a, b)
            return a.zIndex < b.zIndex
        end)
        return true
    end

    function tbl.rem(obj)
        if not obj.drawId then return end
        for i,v in pairs(tbl.Objectpool) do
            if v.obj.drawId == obj.drawId then
                return table.remove(tbl.Objectpool, i)
            end
        end
    end

    function tbl.update2(dt)
        for _,v in pairs(tbl.Objectpool) do
            if v.obj.update then
                v.obj:update(dt)
            end
        end
    end

    function tbl:draw(time)
        for _,v in pairs(tbl.Objectpool) do
            v.obj:draw(time)
        end
    end

    -- // Modifiables
    function tbl.open() end
    function tbl.cleanup() end

    --screenPool[Name] = self
    return tbl
end

function module.get(Name)
    if not screenPool[Name] then
        screenPool[Name] = require("src/screens/" .. Name)
    end

    return screenPool[Name]
end

return module