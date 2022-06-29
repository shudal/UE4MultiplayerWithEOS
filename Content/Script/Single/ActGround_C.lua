--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

---@class ActGround_C : BPActGround
local ActGround_C = Class()

--function ActGround_C:Initialize(Initializer)
--end

--function ActGround_C:UserConstructionScript()
--end

--function ActGround_C:ReceiveBeginPlay()

--end

--function ActGround_C:ReceiveEndPlay()
--end

-- function ActGround_C:ReceiveTick(DeltaSeconds)
-- end

--function ActGround_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function ActGround_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function ActGround_C:ReceiveActorEndOverlap(OtherActor)
--end
---@param cansize FVector2D
---@param act AActor
function ActGround_C:GetScreenPos(cansize,act) 
    local selfpos=self:K2_GetActorLocation()
    local ori2d=UE.FVector2D(selfpos.X,selfpos.Y)
    ori2d = UE.UKismetMathLibrary.Subtract_Vector2DVector2D(ori2d,UE.FVector2D(self.meshwidth/2,self.meshwidth/2))

    local actpos2d=UE.FVector2D(act:K2_GetActorLocation().X,act:K2_GetActorLocation().Y)
    local screenpos= UE.UKismetMathLibrary.Subtract_Vector2DVector2D(actpos2d,ori2d)
    screenpos=UE.UKismetMathLibrary.Multiply_Vector2DFloat(screenpos,cansize.X/self.meshwidth)

    local screensize=20
    --print(screenpos,screensize)
    return screenpos,screensize
end
return ActGround_C
