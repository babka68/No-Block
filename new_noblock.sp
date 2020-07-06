#include <sourcemod>

public Plugin:myinfo = 
{
	name = "No Block",
	author = "sslice,babka68",
	description = "Плагин позволяет игрокам проходить друг друга на сквозь",
	version = "1.1",
	url = "https://hlmod.ru/"
};

new g_offsCollisionGroup;
new bool:g_isHooked;
new Handle:sm_noblock;

public OnPluginStart()
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
		AutoExecConfig(true, "noblock"); // AutoExecConfig Создает конфиг по пути /cfg/sourcemod с название noblock.
	}
}

public OnConVarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	new value = !!StringToInt(newValue);
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

public OnSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new userid = GetEventInt(event, "userid");
	new entity = GetClientOfUserId(userid);
	
	SetEntData(entity, g_offsCollisionGroup, 2, 4, true);
}
