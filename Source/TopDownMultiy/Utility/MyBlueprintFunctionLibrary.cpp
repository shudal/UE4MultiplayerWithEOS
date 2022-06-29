// Fill out your copyright notice in the Description page of Project Settings.


#include "Utility/MyBlueprintFunctionLibrary.h"

#include "OnlineSubsystem.h"
#include "Interfaces/OnlineSessionInterface.h"


bool UMyBlueprintFunctionLibrary::IsPlayerInEpicSesion()
{ 

	auto onlinesys=IOnlineSubsystem::Get();
	if (auto sess=onlinesys->GetSessionInterface())
	{
		return true;
	} else
	{
		return false;
	}
}
