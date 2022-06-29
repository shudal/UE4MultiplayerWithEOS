--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

---@class  UWEnterLevelMenu_ : BPUWEnterLevel
---@field gainst MyGa
local UWEnterLevelMenu_C = Class()

function UWEnterLevelMenu_C:Initialize(Initializer) 
end

--function UWEnterLevelMenu_C:PreConstruct(IsDesignTime)
--end

function UWEnterLevelMenu_C:Construct()
    MyLuaFunc_C:SetDefaultCtxObj(self)
end

--function UWEnterLevelMenu_C:Tick(MyGeometry, InDeltaTime)
--end

---@return MyMyGameInstance
function UWEnterLevelMenu_C:GetGameInst()
    if (self.gainst==nil) then
        self.gainst= UE.UGameplayStatics.GetGameInstance(self)
    end
    return self.gainst
end
function UWEnterLevelMenu_C:CreateWorldForLua()
    print("is login success?",self:GetGameInst():IsLoginSuccess())
    if (self:GetGameInst():IsLoginSuccess() == false) then 
        self:GetGameInst():LoginEpic()
        self:GetGameInst().loginComp:Add(self,self.LoginCompleteFunc)
        self.funcAfterLoginSuccess=self.CreateSessionAndOpenLevel
    else
        self:CreateSessionAndOpenLevel()
    end
end
function UWEnterLevelMenu_C:LoginCompleteFunc(bsuc)

    self:GetGameInst().loginComp:Remove(self,self.LoginCompleteFunc)
    print("login success?",bsuc)
    if (bsuc==true) then
        if (self.funcAfterLoginSuccess ~= nil) then
            self.funcAfterLoginSuccess(self)
        end
    end
end
function UWEnterLevelMenu_C:CreateSessionAndOpenLevel()
    if (self:GetGameInst():IsInSession()==false) then
        self:GetGameInst():CreateSession()
        self:GetGameInst().createSessionComplete:Add(self,self.CreateSessionCompleteFunc)
    else
        print("alreay in session")
    end
end
function UWEnterLevelMenu_C:CreateSessionCompleteFunc(bsuc)
    self:GetGameInst().createSessionComplete:Remove(self,self.CreateSessionCompleteFunc)
    print("create session ok ?",bsuc)
    if (bsuc) then
        UE.UGameplayStatics.OpenLevel(self,"TopDownExampleMap",true,"listen")
    end
end

function UWEnterLevelMenu_C:SearchWorldForLua()
    print("is login success?",self:GetGameInst():IsLoginSuccess())
    if (self:GetGameInst():IsLoginSuccess() == false) then 
        self:GetGameInst():LoginEpic()
        self:GetGameInst().loginComp:Add(self,self.LoginCompleteFunc)
        self.funcAfterLoginSuccess=self.OpenSearchWidget
    else
        self:OpenSearchWidget()
    end
end
function UWEnterLevelMenu_C:OpenSearchWidget()
    local uwsearch=UE.UWidgetBlueprintLibrary.Create(self,self.clsWidgetSearchWorld,MyLuaFunc_C:GetMyPlayerController())
    UE.UUserWidget.AddToViewport(uwsearch)
end
return UWEnterLevelMenu_C
