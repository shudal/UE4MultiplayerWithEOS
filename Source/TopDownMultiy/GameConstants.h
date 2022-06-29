#pragma once

class GameConstants
{
public:
	static GameConstants Get()
	{
		static GameConstants gc;
		return gc;
	}
	const FName GAME_SESSION_NAME="game session name";
};
