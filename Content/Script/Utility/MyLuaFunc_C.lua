
_G.MyLuaFunc_C = Class()

function MyLuaFunc_C:SetDefaultCtxObj(ctxObj)
    self.defCtxObj = ctxObj
end

function MyLuaFunc_C:GetMyPlayerController()
    UE.UGameplayStatics.GetPlayerController(self.defCtxObj,self:GetMyPlayerIdx())
end

function MyLuaFunc_C:GetMyPlayerIdx()
    return 0
end

function MyLuaFunc_C:GetPlayerCharacter()
    return UE.UGameplayStatics.GetPlayerCharacter(self.defCtxObj,0)
end

function MyLuaFunc_C:IsPlayer(act)
    assert(act ~= nil)
    local objact=act:Cast(UE.AActor)
    assert(objact ~= nil)
    return UE.AActor.ActorHasTag(act,"player")
end
---@return GameMg
function MyLuaFunc_C:GetGameMgr(cls)
    if (self.clsGameMgr == nil) then
        self.clsGameMgr=cls
    end
    local act=UE.UGameplayStatics.GetActorOfClass(self.defCtxObj,self.clsGameMgr)
    assert(act ~= nil)
    return act
end

---@return MyMyGameInstance
function MyLuaFunc_C:GetGameInst()
    if (self.gainst==nil) then
        self.gainst= UE.UGameplayStatics.GetGameInstance(self.defCtxObj)
    end
    return self.gainst
end