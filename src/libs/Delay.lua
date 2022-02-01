local Delay = {}
local Pool = {}

function Delay.new(Time, fn)
    table.insert(Pool, {End = Time, Time = 0, fn = fn})
end

function Delay.StaticUpdate(dt)
    for i,v in pairs(Pool) do
        v.Time = v.Time + dt
        if v.Time >= v.End then
            Pool[i] = nil
            v.fn()
        end
    end
end

return Delay