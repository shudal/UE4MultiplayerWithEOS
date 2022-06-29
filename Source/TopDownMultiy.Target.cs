// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;
using System.Collections.Generic;

public class TopDownMultiyTarget : TargetRules
{
	public TopDownMultiyTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Game;
		DefaultBuildSettings = BuildSettingsVersion.V2;
		//bUsesSteam = true;
		ExtraModuleNames.Add("TopDownMultiy");
	}
}
