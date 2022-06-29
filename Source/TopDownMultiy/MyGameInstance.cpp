// Fill out your copyright notice in the Description page of Project Settings.


#include "MyGameInstance.h"

#include "FindSessionsCallbackProxy.h"
#include "GameConstants.h"
#include "OnlineSessionSettings.h"
#include "OnlineSubsystem.h"
#include "Interfaces/OnlineIdentityInterface.h"
#include "Interfaces/OnlineSessionInterface.h"
#include "Kismet/GameplayStatics.h"

void UMyGameInstance::LoginEpic()
{
	auto onlinesys=IOnlineSubsystem::Get();
	if (onlinesys)
	{
		if (id=onlinesys->GetIdentityInterface())
		{
			FOnlineAccountCredentials credent;

			
			credent.Id=FString();
			credent.Token=FString();
			credent.Type=FString("accountportal");

			if (bDebug)
			{
				credent.Id="localhost:9888";
				credent.Type="developer";
				credent.Token="heing";
				if (debugbIsPlayer2)
				{
					credent.Token="junhao";
				}
			}
			handleLoginComplete=id->OnLoginCompleteDelegates->AddUObject(this,&UMyGameInstance::OnLoginEpicComplete);
			/*
			handleLoginComplete= id->OnLoginCompleteDelegates->AddLambda([this](int32 localusernum,bool bsuccess,const FUniqueNetId& UserId, const  FString& error)->void
			{
				bLoginSuccess = bsuccess;
				id->ClearOnLoginCompleteDelegate_Handle(0,handleLoginComplete);
				UE_LOG(LogTemp,Log,TEXT("login ok?%d"),bsuccess?1:0);
				this->loginComp.Broadcast(bsuccess);
			});
			*/
			id->Login(0,credent);
		}
	}
}

void UMyGameInstance::CreateSession()
{
	auto onlinesys=IOnlineSubsystem::Get();
	if (onlinesys)
	{
		if (sess=onlinesys->GetSessionInterface())
		{
			FOnlineSessionSettings sts;
			sts.bIsDedicated=false;
			sts.bShouldAdvertise=true;
			sts.bIsLANMatch=false;
			sts.NumPublicConnections=10;
			sts.bAllowJoinInProgress=true;
			sts.bAllowJoinViaPresence=true;
			sts.bUsesPresence=true;
			sts.bUseLobbiesIfAvailable=true;
			//sts.Set(SEARCH_KEYWORDS,FName(TEXT("search_key")),EOnlineDataAdvertisementType::ViaOnlineService);
			 
			handleCreateSessComp=sess->OnCreateSessionCompleteDelegates.AddUObject(this,&UMyGameInstance::OnCreateSessionComplete);

			sess->CreateSession(0,GameConstants::Get().GAME_SESSION_NAME,sts);
		}
	}
}

void UMyGameInstance::FindSession()
{
	
	auto onlinesys=IOnlineSubsystem::Get();
	if (onlinesys)
	{
		if (sess=onlinesys->GetSessionInterface())
		{
			handleFindSessComp=sess->OnFindSessionsCompleteDelegates.AddUObject(this,&UMyGameInstance::OnFindSessionComplete);

			SearchObject = MakeShareable(
				new FOnlineSessionSearch);
			SearchObject->MaxSearchResults = 15;
			SearchObject->bIsLanQuery = false;  
			//SearchObject->QuerySettings.Set(SEARCH_PRESENCE, true, EOnlineComparisonOp::Equals);
			SearchObject->QuerySettings.Set(SEARCH_LOBBIES,true,EOnlineComparisonOp::Equals);
			sess->FindSessions(0,SearchObject.ToSharedRef());
		}
	}
}

void UMyGameInstance::JoinEpicSession(const FBlueprintSessionResult& SearchResult)
{
	auto onlinesys=IOnlineSubsystem::Get();
	if (onlinesys)
	{
		if (sess=onlinesys->GetSessionInterface())
		{
			sess->OnJoinSessionCompleteDelegates.AddUObject(this,&UMyGameInstance::OnJoinSessionComplete);
			sess->JoinSession(0,GameConstants::Get().GAME_SESSION_NAME,SearchResult.OnlineResult);
		}
	}
}
 
void UMyGameInstance::OnLoginEpicComplete(int32 localusernum, bool bsuccess, const FUniqueNetId& UserId,
                                          const FString& error)
{
	bLoginSuccess = bsuccess;
	id->ClearOnLoginCompleteDelegate_Handle(0,handleLoginComplete);
	UE_LOG(LogTemp,Log,TEXT("login ok?%d"),bsuccess?1:0);
	this->loginComp.Broadcast(bsuccess);

	UE_LOG(LogTemp,Log,TEXT("login user id :%s"),*UserId.ToString());
}

void UMyGameInstance::OnCreateSessionComplete(FName sessname, bool ok)
{
	UE_LOG(LogTemp,Log,TEXT("create session %s,ok?%d"),*sessname.ToString(),ok?1:0);
	if (ok)
	{
		bInSession = true;
	}
	sess->ClearOnCreateSessionCompleteDelegate_Handle(handleCreateSessComp);
	createSessionComplete.Broadcast(ok);
}

void UMyGameInstance::OnFindSessionComplete(bool bSuccess)
{
	sess->ClearOnFindSessionsCompleteDelegate_Handle(handleFindSessComp);

	TArray<FBlueprintSessionResult> Results;
	UE_LOG(LogTemp,Log,TEXT("search complete，ok?%d"),bSuccess?1:0);
	if (bSuccess && SearchObject.IsValid())
	{
		for (auto& Result : SearchObject->SearchResults)
		{
			FBlueprintSessionResult BPResult;
			BPResult.OnlineResult = Result;
			Results.Add(BPResult);
		}

		UE_LOG(LogTemp,Log,TEXT("on success，result number:%d"),Results.Num());
		OnSuccess.Broadcast(Results);
	}
}

void UMyGameInstance::GM(FString s)
{
	if (s=="setlogin2")
	{
		debugbIsPlayer2=true;
	}
}

void UMyGameInstance::OnJoinSessionComplete(FName SessionName, EOnJoinSessionCompleteResult::Type Result)
{
	sess->ClearOnJoinSessionCompleteDelegates(this); 
	if (Result == EOnJoinSessionCompleteResult::Success)
	{
		// Client travel to the server
		FString ConnectString;
		if (sess->GetResolvedConnectString(GameConstants::Get().GAME_SESSION_NAME, ConnectString))
		{
			UE_LOG_ONLINE_SESSION(Log, TEXT("Join session: traveling to %s"), *ConnectString);
			verify(GetWorld()!=nullptr);
			UGameplayStatics::GetPlayerController(this,0)->ClientTravel(ConnectString, TRAVEL_Absolute);

			onJoinSessionSuccess.Broadcast();
		}
	}
}