--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

---@class GameMgr_C : GameplayMgr
local GameMgr_C = Class()

function GameMgr_C:Initialize(Initializer)
    self.deadCnt=0
end

--function GameMgr_C:UserConstructionScript()
--end

function GameMgr_C:ReceiveBeginPlay()
    UE.UGameplayStatics.PlaySound2D(self,self.soundBg)
end

--function GameMgr_C:ReceiveEndPlay()
--end

-- function GameMgr_C:ReceiveTick(DeltaSeconds)
-- end

--function GameMgr_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function GameMgr_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function GameMgr_C:ReceiveActorEndOverlap(OtherActor)
--end
function GameMgr_C:SetLocalCharacter(act)
    self.locChar=act
end
function GameMgr_C:AddDead()
    self.deadCnt = self.deadCnt + 1
    if (self.playerCnt == nil or true) then
        local outacts=UE.TArray(UE.ATopDownMultiyCharacter)
        UE.UGameplayStatics.GetAllActorsOfClass(self,UE.ATopDownMultiyCharacter,outacts)
        self.playerCnt = outacts:Length()
    end
    if (self.deadCnt==self.playerCnt-1) then
        if (self.locChar:IsDead()==false) then 
            self.locChar:SetSuccess(true)
        end
    else
        print(self.deadCnt,self.playerCnt)
        --print(self.playerCnt)
    end
end
return GameMgr_C
