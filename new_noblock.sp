#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

public Plugin myinfo = 
{
	name = "new_noblock",
	author = "sslice,babka68",
	description = "Плагин позволяет игрокам проходить друг друга на сквозь",
	version = "1.1",
	url = "https://hlmod.ru/"
};

int g_offsCollisionGroup;
bool g_isHooked;
Handle sm_noblock;

public void OnPluginStart()
{
	g_offsCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	if (g_offsCollisionGroup == -1)
	{
		g_isHooked = false;
		PrintToServer("* FATAL ERROR: Failed to get offset for CBaseEntity::m_CollisionGroup");
	}
	else
	{
		g_isHooked = true;
		HookEvent("player_spawn", OnSpawn, EventHookMode_Post);

		sm_noblock = CreateConVar("sm_noblock", "1", "1 включает,0 отключает столкновение с игроками", FCVAR_NOTIFY|FCVAR_REPLICATED);
		HookConVarChange(sm_noblock, OnConVarChange);
	}
}

public void OnConVarChange(Handle hCvar, const char[] Value, const char[] intValue)
{
	int value = !!StringToInt(intValue);
	if (value == 0)
	{
		if (g_isHooked == true)
		{
			g_isHooked = false;
			
			UnhookEvent("player_spawn", OnSpawn, EventHookMode_Post);
		}
	}
	else
	{
		g_isHooked = true;
		
		HookEvent("player_spawn", OnSpawn, EventHookMode_Post);
	}
}

public void OnSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int entity = GetClientOfUserId(userid);
	
	SetEntData(entity, g_offsCollisionGroup, 2, 4, true);
}
