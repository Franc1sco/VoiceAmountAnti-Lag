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

#pragma newdecls required

ConVar cvar_amount = null;
ConVar cvar_mute = null;
ConVar cvar_version = null;

int Max_Amount;

ConVar g_CVarAdmFlag;
int g_AdmFlag;
float muted;

public Plugin myinfo =
{
	name = "SM Voice Amount",
	author = "Franc1sco steam: franug",
	description = "Prevents lag when everyone talks at once",
	version = "v1.4.2",
	url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	LoadTranslations("voiceamount.phrases");


	g_CVarAdmFlag = CreateConVar("sm_voiceamount_adminflag", "0", "Admin flag required to have inmunity. 0 = feature disable. Can use a b c ....");

	cvar_amount = CreateConVar("sm_voiceamount_number", "7", "Number of people who can talk at the same time");

	cvar_mute = CreateConVar("sm_voiceamount_mutetime", "1.0", "Time for the temporal mute (1.0 = 1 second)");

	cvar_version = CreateConVar("sm_voiceamount_version", "v1.4.1", _, FCVAR_NOTIFY|FCVAR_DONTRECORD);

	// Hooking cvar change
	cvar_amount.AddChangeHook(OnCVarChange);
	cvar_version.AddChangeHook(OnCVarChange);
	g_CVarAdmFlag.AddChangeHook(OnCVarChange2);
	cvar_mute.AddChangeHook(OnCVarChange);
}

public void OnCVarChange2(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_AdmFlag = ReadFlagString(newValue);
}

public void OnCVarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCVars();
}

public void OnConfigsExecuted()
{
	GetCVars();
}

public void OnClientSpeakingEx(int client)
{	
		if(BaseComm_IsClientMuted(client)) return;

		if (g_AdmFlag > 0 && CheckCommandAccess(client, "sm_voiceamount_override", g_AdmFlag, true)) return;

		int speaking = 0;
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && !IsFakeClient(i) && IsClientSpeaking(i) && !BaseComm_IsClientMuted(i))
				++speaking;

		if(speaking > Max_Amount)
		{
			BaseComm_SetClientMute(client, true);
			CreateTimer(muted, desmute, client);
			PrintHintText(client, "%t", "voice blocked");
		}
}

public Action desmute(Handle timer, any client)
{
	if (IsClientInGame(client) && !IsFakeClient(client) &&	BaseComm_IsClientMuted(client))
		BaseComm_SetClientMute(client, false);
}

// Get new values of cvars if they has being changed
public void GetCVars()
{
	Max_Amount = cvar_amount.IntValue;
	ResetConVar(cvar_version);
	muted = cvar_mute.FloatValue;
}
