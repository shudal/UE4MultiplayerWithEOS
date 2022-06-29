// Copyright Epic Games, Inc. All Rights Reserved.

#include "TopDownMultiyGameMode.h"
#include "TopDownMultiyPlayerController.h"
#include "TopDownMultiyCharacter.h"
#include "UObject/ConstructorHelpers.h"

ATopDownMultiyGameMode::ATopDownMultiyGameMode()
{
	// use our custom PlayerController class
	PlayerControllerClass = ATopDownMultiyPlayerController::StaticClass();

	// set default pawn class to our Blueprinted character
	/*
	static ConstructorHelpers::FClassFinder<APawn> PlayerPawnBPClass(TEXT("/Game/TopDownCPP/Blueprints/TopDownCharacter"));
	if (PlayerPawnBPClass.Class != nullptr)
	{
		DefaultPawnClass = PlayerPawnBPClass.Class;
	}*/
}