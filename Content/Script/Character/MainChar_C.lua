--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"
local Screen=require "Utility.Screen"
require "Utility.MyLuaFunc_C"

---@class MainChar_C : TopDownCharacter
local MainChar_C = Class()

function MainChar_C:Initialize(Initializer)
    self.arrVels = {}
    self.tickRecordX = 5
    self.velRecordNum = 3 * (30 / 5) --记录3s的
    self.nowVelIdx = 1
    self.tickCnt = 0
    self.velSum = 0
    self.matNum = 6
    self.velSumOfTotallyHide = 600 * self.velRecordNum / 3

    self.bShotingShadow = false
    self.shadowLen = 0
    self.shadowLenAddPerTick = 100 / 30
    self.shadowDir = UE.FVector(0,0,0)

    self.iniShadowWidth=1000
    self.lastShadowDir =UE.FVector()
    self.lastAddShadowLenTime=0
    self.lastPrintX=0

    self.LIFE_STATUS_ALIVE=0
    self.LIFE_STATUS_TOUCHED=1
    self.lifeStatus=self.LIFE_STATUS_ALIVE
end


function MainChar_C:SetShadowWidth(len)
    local scale=len/100
    local v=UE.FVector(scale,scale,scale)
    self.SMShadow:SetWorldScale3D(v)
    self.MIShadow:SetScalarParameterValue("swid",len)
    self.nowShadowWid=len
end
--function MainChar_C:UserConstructionScript()
--end

function MainChar_C:ReceiveBeginPlay()
    self.MIShadow=self.SMShadow:CreateDynamicMaterialInstance(0,self.SMShadow:GetMaterial(0))
    self.SMShadow:SetMaterial(0,self.MIShadow)
    self:SetShadowWidth(self.iniShadowWidth)

    MyLuaFunc_C:SetDefaultCtxObj(self)
    --UE.UKismetSystemLibrary.PrintString(self,UE.UKismetSystemLibrary.GetObjectName(self))  
    --UE.UKismetSystemLibrary.PrintString(self,self:GetLocalRole() .. "")  
    --print(UE.UKismetSystemLibrary.GetObjectName(self))
    
    print(UE.UKismetSystemLibrary.GetObjectName(self))
    self.gameMgr=MyLuaFunc_C:GetGameMgr(self.clsGameMgr)
    if (self:IsLocallyControlled()) then 
        self.gameMgr:SetLocalCharacter(self)
    end

    self:BeginPlayInBP()
end
 
function MainChar_C:ActionTest_Pressed()
    if (self:GetLocalRole()==UE.ENetRole.ROLE_AutonomousProxy) then 
        Screen.Print("i am client")
        print("i am client in print")
    else 
        Screen.Print("i am server")
    end
    self:testOnServer()
end
function MainChar_C:testOnServer_RPC2() 
    --Screen.Print("testonserver func")
    print("server func on server")
    --self:testMulticast()
end
function MainChar_C:testOnServerForLua()
    Screen.Print("testonserver func")
    self:testMulticast()
end
function MainChar_C:testMulticast_RPC() 
    Screen.Print("func multicast")
end
--function MainChar_C:ReceiveEndPlay()
--end

function MainChar_C:ReceiveTick(DeltaSeconds)
    self.tickCnt = self.tickCnt + 1
    if (self.tickCnt % self.tickRecordX == 0) then
        local velnow=self:GetVelocity()
        velnow = UE.UKismetMathLibrary.VSize(velnow)
        if(#self.arrVels < self.velRecordNum) then
            self.velSum = self.velSum + velnow

            table.insert(self.arrVels,velnow)
        else
            self.velSum = self.velSum - self.arrVels[self.nowVelIdx] + velnow

            self.arrVels[self.nowVelIdx] = velnow
            self.nowVelIdx = self.nowVelIdx + 1
            if (self.nowVelIdx == self.velRecordNum + 1) then
                self.nowVelIdx = 1
            end
        end
    end

    if (self.velSum >= self.velSumOfTotallyHide or self.lifeStatus ~= self.LIFE_STATUS_ALIVE) then
        self:ShowMesh(true)
    else
        local perc=self.velSum / self.velSumOfTotallyHide
        assert(perc >= 0 and perc < 1)
        perc = perc *  self.matNum
        local maxx=math.floor(perc)  --[0,5]
        for i=maxx-1,0,-1 do 
            self.Mesh:ShowMaterialSection(i,0,true,0)
        end
        for i=self.matNum-1,maxx,-1 do 
            self.Mesh:ShowMaterialSection(i,0,false,0)
        end
    end

    self:tickShadow()
end

--function MainChar_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function MainChar_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function MainChar_C:ReceiveActorEndOverlap(OtherActor)
--end

function MainChar_C:MoveForward(v)
    self.shadowDir.X = v
    if (math.abs(v) > 0.001 and self.bShotingShadow==false) then 
        self:AddMovementInput(UE.FVector(1,0,0),v,false)
    end
 
    self:MoveForwardAndRight()
end

function MainChar_C:MoveRight(v) 
    self.shadowDir.Y = v
    if (math.abs(v) > 0.001 and self.bShotingShadow==false) then 
        self:AddMovementInput(UE.FVector(0,1,0),v,false)
    end
    
    self:MoveForwardAndRight()
end

function MainChar_C:MoveForwardAndRight() 
    
    self.shadowDir = UE.UKismetMathLibrary.Normal(self.shadowDir,0.001)
    self:OnRep_shadowDir()
    --print(" shaodw dir for server:")
    --print(self.shadowDir)
    self:SetShadowDirInServer(self.shadowDir) 
end 

function MainChar_C:ShowMesh(bshow)
    self.Mesh:ShowMaterialSection(0,0,bshow,0)
end

function MainChar_C:ShotShadow_Pressed() 
    --self:SetShotingShadow(true)
    --self:SetShadowLen(0) 
    --print("1s")
    self:RPCShotShadow(true) 
end

function MainChar_C:ShotShadow_Released()
    --self:SetShotingShadow(false) 
    self:RPCShotShadow(false)
end

function MainChar_C:RPCShotShadowForLua(bshow)
    --UE.UKismetSystemLibrary.PrintString(self,"rpc shot shadow func")
    self:SetShotingShadow(bshow)
    self:SetShadowLen(0) 
end

function MainChar_C:tickShadow()
    --print("tick")
    self.SMShadow:K2_SetWorldRotation(UE.FRotator(0,0,0),false,UE.FHitResult(),true)
    if (self:GetLocalRole()==UE.ENetRole.ROLE_Authority) then
        if (self.bShotingShadow) then 
            if (UE.UKismetMathLibrary.VSize(self.shadowDir) > 0) then   
                local degreeGap=UE.UKismetMathLibrary.Dot_VectorVector(self.shadowDir,self.lastShadowDir)
                degreeGap = math.acos(degreeGap)
                local scalex=-(1/math.pi) * degreeGap + 1
                scalex = scalex * scalex
                if (scalex > 1) then scalex=1 end
                if (degreeGap < 0.965) then
                    --scalex=0
                end
                self.shadowLen = self.shadowLen * scalex
    
                if (scalex ~= self.lastPrintX) then 
                    self.lastPrintX=scalex 
                    --print(scalex)
                end
                self.shadowLen = self.shadowLen + self.shadowLenAddPerTick
                local maxShadowLen=(self.nowShadowWid/2)*(7/8)
                if (self.shadowLen>maxShadowLen) then
                    self.shadowLen = maxShadowLen
                end

                --print(self.lastShadowDir)
                --print(self.shadowDir)
                --print(degreeGap)
                --print(self.shadowLen)
                self:SetShadowLen(self.shadowLen) 
                --self:OnRep_shadowLen() 
    
                self.lastShadowDir =  UE.UKismetMathLibrary.Normal(self.shadowDir,0.001)
                self.lastAddShadowLenTime = UE.UGameplayStatics.GetTimeSeconds(self)

                -- detect player
                local boxloc = self:K2_GetActorLocation() 
                local boxloc_forward = self.shadowDir
                UE.UKismetMathLibrary.Vector_Normalize(boxloc_forward)
                boxloc_forward = boxloc_forward * self.shadowLen

                boxloc = boxloc + boxloc_forward
                local obj_types = UE.TArray(UE.EObjectTypeQuery)
                obj_types:Add(UE.EObjectTypeQuery.Pawn)
                local box_ext = UE.FVector(50, 50, 50)

                local act_ign = UE.TArray(UE.AActor)
                act_ign:Add(self)
                local bever_found,acts= UE.UKismetSystemLibrary.BoxOverlapActors(self, boxloc, box_ext, obj_types, UE.ACharacter, act_ign)
                --print(bever_found)
                --UE.UKismetSystemLibrary.DrawDebugBox(self,boxloc,box_ext,UE.FLinearColor(1,0,0),UE.FRotator(),1,1)
 
                for i = 1, acts:Length() do 
                    local tact = acts:Get(i)
                    if (MyLuaFunc_C:IsPlayer(tact)) then
                        tact:touchedByShadow()
                    end
                end
            else
                if (UE.UGameplayStatics.GetTimeSeconds(self) - self.lastAddShadowLenTime > 0.5) then 
                    if (self.shadowLen > 0) then  
                        self:SetShadowLen(0)
                        --print("reset to 0")
                    end
                end
            end
        end
    end
    
end

function MainChar_C:SetShotingShadow(x) 
    if(self:GetLocalRole()==UE.ENetRole.ROLE_Authority) then
        self.bShotingShadow = x
        --UE.UKismetSystemLibrary.PrintString(self,"set bshoting shadow in authority")
        self:OnRep_bShotingShadow()
        --else 
        --    self:RPCShotShadow(true) -- not work,thus use follow code
        --    self.bShotingShadow = x
    end
end
function MainChar_C:OnRep_bShotingShadow()
    if (self.bShotingShadow == true) then
        if (self.compSoundShadow == nil) then
            self.compSoundShadow = UE.UGameplayStatics.SpawnSoundAtLocation(self,self.soundShadow,self:K2_GetActorLocation())
        end
        --self.compSoundShadow:SetActive(true)
       -- self.compSoundShadow:Play()
       self.compSoundShadow:SetPaused(false)
        --print("set active")
    else 
        --self.compSoundShadow:SetActive(false,true)
        --self.compSoundShadow:Stop()
       self.compSoundShadow:SetPaused(true)
    end
end
function MainChar_C:SetShadowLen(x)
    if(self:GetLocalRole()==UE.ENetRole.ROLE_Authority) then
        self.shadowLen = x
        self:OnRep_shadowLen() 
    end
end
function MainChar_C:OnRep_shadowLen() 
    self.MIShadow:SetScalarParameterValue("slen",self.shadowLen) 
end
function MainChar_C:SetShadowDir(x) 
    if(self:GetLocalRole()==UE.ENetRole.ROLE_Authority) then
        self.shadowDir = x
        self:OnRep_shadowDir() 
    end
end
function MainChar_C:SetShadowDirInServerForLua(dir)
    --print(1)
    self:SetShadowDir(dir)
end
function MainChar_C:OnRep_shadowDir() 
    
    --UE.UKismetSystemLibrary.PrintString(self,"on rep shadowdir") 
    --UE.UKismetSystemLibrary.PrintString(self,UE.UKismetSystemLibrary.GetObjectName(self)) 
   

    local c = UE.FLinearColor()
    c.R = self.shadowDir.X
    c.G = self.shadowDir.Y
    c.B = self.shadowDir.Z
    c.A = 0 
    self.MIShadow:SetVectorParameterValue("vecDir",c)
    --print("replicated shaodw dir:")
    --print(self.shadowDir)
end
function MainChar_C:OnRep_lifeStatus()
    if (self.lifeStatus==self.LIFE_STATUS_TOUCHED and self.bDeadActioned==nil) then
        UE.UGameplayStatics.PlaySoundAtLocation(self,self.soundBeFound,self:K2_GetActorLocation(),UE.FRotator())
        --local b1=self:GetLocalRole() == UE.ENetRole.ROLE_AutonomousProxy
        local b2=self:IsLocallyControlled()
        --print("b1,b2")
        --print(b1,b2)
        --print("local role:")
        --print(self:GetLocalRole())
        --print(self:GetRemoteRole())
        
        --print(UE.UKismetSystemLibrary.GetObjectName(self))
        
        self.gameMgr:AddDead()
        if (b2) then
            self:SetSuccess(false)
            --print("set success in lua")
            self:GetController():UnPossess()
        else 
            --print("not local controll")
        end

        self.bDeadActioned=true
    end
end
function MainChar_C:IsDead()
    return self.lifeStatus == self.LIFE_STATUS_TOUCHED
end
function MainChar_C:touchedByShadow()
    if (not(self.lifeStatus==self.LIFE_STATUS_TOUCHED)) then 
        self.lifeStatus = self.LIFE_STATUS_TOUCHED 
        self:OnRep_lifeStatus()
    end
end
return MainChar_C
