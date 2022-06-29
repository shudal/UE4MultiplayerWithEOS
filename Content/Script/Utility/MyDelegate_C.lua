
_G.MyDelegate_C = {}

function MyDelegate_C:New()
    local t = {}
    setmetatable(t, self)
    self.__index = self

    -- initialize variable which type is table
    t.funcArr = {}

    return t
end

function MyDelegate_C:Add(obj, funcToCall) 
    table.insert(self.funcArr, { obj, funcToCall })
end

function MyDelegate_C:NotifyAll(...)
    for i, v in ipairs(self.funcArr) do
        v[2](v[1],...)
    end
end

return MyDelegate_C

