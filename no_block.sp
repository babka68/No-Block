#pragma semicolon 1
#pragma newdecls required

#define	COLLISION_GROUP_DEBRIS_TRIGGER  2	// То же, что и мусор, но попадает в триггеры
#define	COLLISION_GROUP_INTERACTIVE 	4	// Сталкивается со всем, кроме взаимодействие мусора или мусора

public Plugin myinfo =  {
	name = "No Block", 
	author = "babka68", 
	description = "Плагин позволяет игрокам проходить друг друга на сквозь", 
	version = "1.0.1", 
	url = "https://vk.com/zakazserver68", 
};

bool g_bEnable_No_Block, g_bEnable_No_Block_Grenades;
int g_iOffsCollisionGroup;

public void OnPluginStart() {
	g_iOffsCollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	
	if (g_iOffsCollisionGroup == -1) {
		SetFailState("[No Block] Не удалось получить смещение для группы CBaseEntity::m_CollisionGroup.");
	}
	
	ConVar cvar;
	cvar = CreateConVar("sm_enable_no_block", "1", "Удалить столкновение игроков друг с другом? [1 - да, 0 - Нет]", _, true, 0.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Enable_No_Block);
	g_bEnable_No_Block = cvar.BoolValue;
	
	cvar = CreateConVar("sm_enable_no_block_grenades", "1", "Удалить столкновение игроков с гранатами? [1 - да, 0 - Нет]", _, true, 0.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Enable_Grenades);
	g_bEnable_No_Block_Grenades = cvar.BoolValue;
	
	AutoExecConfig(true, "no_block_babka68");
	
	HookEvent("player_spawn", Event_Callback_Spawn, EventHookMode_Post);
}

public void CVarChanged_Enable_No_Block(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_bEnable_No_Block = cvar.BoolValue;
}

public void CVarChanged_Enable_Grenades(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_bEnable_No_Block_Grenades = cvar.BoolValue;
}

// Игроки возродились
public void Event_Callback_Spawn(Event event, const char[] name, bool dontBroadcast) {
	if (g_bEnable_No_Block) {
		int entity = GetClientOfUserId(event.GetInt("userid"));
		// Перед использованием или убийством сущности убедитесь, что она действительна с помощью IsValidEntity();
		// - Обязательно проверяйте на ноль if(entity != 0) или просто if(entity), потому что 0 (на выделенном сервере) - это сущность worldspawn и является действительной, таким образом вы можете мгновенно обвалить сервер.
		if (entity != 0 && IsValidEntity(entity)) {
			No_Block(entity);
		}
	}
}

// OnEntityCreated - Когда создается точечная сущность(в нашем случае штурмовая, слеповая, дымовая гранаты)
public void OnEntityCreated(int entity, const char[] classname) {
	if (g_bEnable_No_Block_Grenades) {
		// Перед использованием или убийством сущности убедитесь, что она действительна с помощью IsValidEntity();
		// - Обязательно проверяйте на ноль if(entity != 0) или просто if(entity), потому что 0 (на выделенном сервере) - это сущность worldspawn и является действительной, таким образом вы можете мгновенно обвалить сервер.
		if (entity != 0 && IsValidEntity(entity)) {
			if (StrEqual(classname, "hegrenade_projectile") || StrEqual(classname, "flashbang_projectile") || StrEqual(classname, "smokegrenade_projectile")) {
				No_Block(entity);
			}
		}
	}
}

// Нет столкновение игроков друг с другом и с гранатами.
void No_Block(int client) {
	SetEntData(client, g_iOffsCollisionGroup, COLLISION_GROUP_DEBRIS_TRIGGER, COLLISION_GROUP_INTERACTIVE, true);
} 
