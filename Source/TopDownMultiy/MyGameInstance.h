// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h" 
#include "FindSessionsCallbackProxy.h"
#include "Engine/GameInstance.h"
#include "Interfaces/OnlineIdentityInterface.h"
#include "Interfaces/OnlineSessionInterface.h"
#include "MyGameInstance.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnLoginCompleteInGameInst, bool, bsuc);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnCreateSessionCompleteInGameInst, bool, bsuc);

/**
 * 
 */
UCLASS()
class TOPDOWNMULTIY_API UMyGameInstance : public UGameInstance
{
	GENERATED_BODY()

private:
	FDelegateHandle handleLoginComplete,handleCreateSessComp,handleFindSessComp;
	IOnlineIdentityPtr id;
	IOnlineSessionPtr sess;

	
	TSharedPtr<FOnlineSessionSearch> SearchObject;
protected:

	UPROPERTY(BlueprintReadWrite,VisibleAnywhere)
	bool bLoginSuccess=false;
	UPROPERTY(BlueprintReadWrite,VisibleAnywhere)
	bool bInSession=false;
public:
	 

	UFUNCTION(BlueprintCallable)
	bool IsLoginSuccess() { return bLoginSuccess;}
	UFUNCTION(BlueprintCallable)
	bool IsInSession() { return bInSession;}
	
	UFUNCTION(BlueprintCallable)
	void LoginEpic();


	UPROPERTY(BlueprintAssignable)
	FOnLoginCompleteInGameInst loginComp;

	UPROPERTY(BlueprintAssignable,BlueprintReadWrite,VisibleAnywhere)
	FOnCreateSessionCompleteInGameInst createSessionComplete;
	// find session delegate
	UPROPERTY(BlueprintAssignable)
	FBlueprintFindSessionsResultDelegate OnSuccess;
	// find session delegate
	UPROPERTY(BlueprintAssignable)
	FEmptyOnlineDelegate onJoinSessionSuccess;

	UFUNCTION(BlueprintCallable)
	void CreateSession();

	UFUNCTION(BlueprintCallable)
	void FindSession();

	
	UFUNCTION(BlueprintCallable)
	void JoinEpicSession( const FBlueprintSessionResult& SearchResult);



	void OnLoginEpicComplete(int32 localusernum,bool bsuccess,const FUniqueNetId& UserId, const  FString& error);
	void OnCreateSessionComplete(FName sessname,bool ok);
	void OnFindSessionComplete(bool bSuccess);
	void OnJoinSessionComplete(FName SessionName, EOnJoinSessionCompleteResult::Type Result);

	UFUNCTION(Exec)
	void GM(FString s);
	
	const bool bDebug=true;
	bool debugbIsPlayer2=false;
};

 
