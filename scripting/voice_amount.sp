/*  SM Voice Amount
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <voiceannounce_ex>
#include <basecomm>



new Handle:cvar_amount = INVALID_HANDLE;
new Handle:cvar_mute = INVALID_HANDLE;
new Handle:cvar_version = INVALID_HANDLE;

new Max_Amount;

new Handle:g_CVarAdmFlag;
new g_AdmFlag;
new Float:muteado;

public Plugin:myinfo =
{
	name = "SM Voice Amount",
	author = "Franc1sco steam: franug",
	description = "Prevents lag when everyone talks at once",
	version = "v1.4.1",
	url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
	LoadTranslations("voiceamount.phrases");


	g_CVarAdmFlag = CreateConVar("sm_voiceamount_adminflag", "0", "Admin flag required to have inmunity. 0 = feature disable. Can use a b c ....");

	cvar_amount = CreateConVar("sm_voiceamount_number", "7", "Number of people who can talk at the same time");

	cvar_mute = CreateConVar("sm_voiceamount_mutetime", "1.0", "Time for the temporal mute (1.0 = 1 second)");

	cvar_version = CreateConVar("sm_voiceamount_version", "v1.4.1", _, FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	// Hooking cvar change
	HookConVarChange(cvar_amount, OnCVarChange);
	HookConVarChange(cvar_version, OnCVarChange);
	HookConVarChange(g_CVarAdmFlag, OnCVarChange2);
	HookConVarChange(cvar_mute, OnCVarChange);
}

public OnCVarChange2(Handle:convar_hndl, const String:oldValue[], const String:newValue[])
{
	g_AdmFlag = ReadFlagString(newValue);
}

public OnCVarChange(Handle:convar_hndl, const String:oldValue[], const String:newValue[])
{
	GetCVars();
}

public OnConfigsExecuted()
{
	GetCVars();
}

public bool:OnClientSpeakingEx(client)
{	
		if(BaseComm_IsClientMuted(client))
			return false;

		if (g_AdmFlag > 0 && CheckCommandAccess(client, "sm_voiceamount_override", g_AdmFlag, true)) 
			return true;

		new speaking = 0;
		for (new i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && !IsFakeClient(i) && IsClientSpeaking(i) && !BaseComm_IsClientMuted(i))
				++speaking;

		if(speaking > Max_Amount)
		{
			BaseComm_SetClientMute(client, true);
			CreateTimer(muteado, desmute, client);
			PrintHintText(client, "%t", "voice blocked");
			return false;
		}
		else 
			return true;
}

public Action:desmute(Handle:timer, any:client)
{
	if (IsClientInGame(client) && !IsFakeClient(client) &&	BaseComm_IsClientMuted(client))
		BaseComm_SetClientMute(client, false);
}

// Get new values of cvars if they has being changed
public GetCVars()
{
	Max_Amount = GetConVarInt(cvar_amount);
	ResetConVar(cvar_version);
	muteado = GetConVarFloat(cvar_mute);

}

