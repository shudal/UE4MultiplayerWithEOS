--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

---@class UWSearchWorld_C : BPUWSearchWorld
local UWSearchWorld_C = Class()

--function UWSearchWorld_C:Initialize(Initializer)
--end

--function UWSearchWorld_C:PreConstruct(IsDesignTime)
--end

-- function UWSearchWorld_C:Construct()
-- end

--function UWSearchWorld_C:Tick(MyGeometry, InDeltaTime)
--end
function UWSearchWorld_C:ProcessSessions(arr)
    local ans=""
    for i = 1, arr:Length() do 
        ---@type FBlueprintSessionResult
        local r = arr:Get(i) 
        ans=ans .. "\n" .. "ID: "  .. tostring(i-1) .. ", "
        ans=ans .. UE.UFindSessionsCallbackProxy.GetServerName(r) .. " ,当前人数: "
        ans=ans  .. tostring(UE.UFindSessionsCallbackProxy.GetCurrentPlayers(r)) .. " ,最大人数："
        ans=ans .. tostring(UE.UFindSessionsCallbackProxy.GetMaxPlayers(r))
    end
    self.TextBlock_rooms:SetText(ans)
end
function UWSearchWorld_C:SearchSessionForLua()
    MyLuaFunc_C:GetGameInst().OnSuccess:Add(self,self.FindSessionSuccessFunc)
    MyLuaFunc_C:GetGameInst():FindSession()
end
function UWSearchWorld_C:FindSessionSuccessFunc(rets)
    MyLuaFunc_C:GetGameInst().OnSuccess:Remove(self,self.FindSessionSuccessFunc)
    self.roomResults=rets
    self:ProcessSessions(rets)
end
function UWSearchWorld_C:JoinEpicSessionForLua(sessres)
     MyLuaFunc_C:GetGameInst():JoinEpicSession(sessres)
end
return UWSearchWorld_C
