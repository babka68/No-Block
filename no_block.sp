#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =  {
	name = "No Block", 
	author = "babka68", 
	description = "Плагин позволяет игрокам проходить друг друга на сквозь", 
	version = "1.0", 
	url = "https://vk.com/zakazserver68", 
};

bool g_bEnable;
int g_ioffsCollisionGroup;

public void OnPluginStart() {
	g_ioffsCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	
	if (g_ioffsCollisionGroup == -1) {
		SetFailState("[NoBlock] Failed to get offset for CBaseEntity::m_CollisionGroup.");
	}
	
	ConVar cvar;
	cvar = CreateConVar("sm_enable_no_block", "1", "1 - Включить, 0 - Выключить плагин.", _, true, 0.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Enable_No_Block);
	g_bEnable = cvar.BoolValue;
	
	HookEvent("player_spawn", OnSpawn, EventHookMode_Post);
}

public void CVarChanged_Enable_No_Block(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_bEnable = cvar.BoolValue;
}

public void OnSpawn(Event event, const char[] name, bool dontBroadcast) {
	if (g_bEnable) {
		int userid = event.GetInt("userid");
		int entity = GetClientOfUserId(userid);
		SetEntData(entity, g_ioffsCollisionGroup, 2, 4, true);
	}
} 
