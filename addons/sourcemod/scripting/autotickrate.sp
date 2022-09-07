#include <sourcemod>
#include <autoexecconfig>

#pragma newdecls required

public Plugin myinfo =
{
    name = "autotickrate",
    author = "tmick0",
    description = "Reduces tick rate when under high load",
    version = "0.1",
    url = "github.com/tmick0/sm_autotickrate"
};

#define FLAG_FILENAME "autotickrate_triggered"
#define CVAR_ENABLE "sm_autotickrate_enable"
#define CVAR_THRESHOLD "sm_autotickrate_numclients"
#define CVAR_HITICK "sm_autotickrate_hightick"
#define CVAR_LOTICK "sm_autotickrate_lowtick"

int Enabled;
int HiTick;
int LoTick;
int Threshold;

ConVar CvarEnable;
ConVar CvarThreshold;
ConVar CvarHiTick;
ConVar CvarLoTick;

public void OnPluginStart() {
    AutoExecConfig_SetCreateDirectory(true);
    AutoExecConfig_SetCreateFile(true);
    AutoExecConfig_SetFile("plugin_autotickrate");
    CvarEnable = AutoExecConfig_CreateConVar(CVAR_ENABLE, "0", "1 = enable autotickrate, 0 = disable");
    CvarThreshold = AutoExecConfig_CreateConVar(CVAR_THRESHOLD, "30", "number of players at which to enable lowtick");
    CvarHiTick = AutoExecConfig_CreateConVar(CVAR_HITICK, "128", "default tick rate");
    CvarLoTick = AutoExecConfig_CreateConVar(CVAR_LOTICK, "64", "reduced tick rate");
    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();

    // init hooks
    HookConVarChange(CvarEnable, CvarsUpdated);
    HookConVarChange(CvarThreshold, CvarsUpdated);
    HookConVarChange(CvarHiTick, CvarsUpdated);
    HookConVarChange(CvarLoTick, CvarsUpdated);

    // load config
    SetCvars();

}

void CvarsUpdated(ConVar cvar, const char[] oldval, const char[] newval) {
    SetCvars();
}

void SetCvars() {
    Enabled = CvarEnable.IntValue;
    Threshold = CvarThreshold.IntValue;
    HiTick = CvarHiTick.IntValue;
    LoTick = CvarLoTick.IntValue;
}

public void OnAutoConfigsBuffered() {
    bool flagFileExists = FileExists(FLAG_FILENAME, false, NULL_STRING);

    int tickRate = HiTick;
    if (flagFileExists) {
        tickRate = LoTick;
        DeleteFile(FLAG_FILENAME, false, NULL_STRING);
    }

    if (Enabled) {
        ServerCommand("tickrate_value %d", tickRate);
        ServerCommand("sv_minupdaterate %d", tickRate);
        ServerCommand("sv_mincmdrate %d", tickRate);
    }
}

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen) {
    if (GetClientCount() >= Threshold) {
        File flagFile = OpenFile(FLAG_FILENAME, "w", false, NULL_STRING);
        WriteFileLine(flagFile, "");
    }
    return true;
}