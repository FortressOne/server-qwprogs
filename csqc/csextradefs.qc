#include "../share/defs.h"

vector MENU_BG = '0.2 0.3 0.4';
vector MENU_BG_DARK = '0.1 0.15 0.2';
vector MENU_BORDER = '0.3 0.4 0.5';
vector MENU_BG_WARNING = '0.4 0.3 0.2';
vector MENU_BORDER_WARNING = '0.5 0.4 0.3';
vector MENU_SELECTED = '0 1 0';
vector MENU_UNSELECTED = '1 0 0';
vector MENU_BUTTON = '0.3 0.4 0.5';
//vector MENU_BUTTON_BORDER = '0.35 0.45 0.55';
vector MENU_TEXT_1 = '1 1 1';
vector MENU_TEXT_2 = '0.7 0.75 0.75';
vector MENU_TEXT_3 = '1 1 0';
vector MENU_TEXT_4 = '0.8 0.5 0';
vector MENU_HIGHLIGHT = '1 1 1';
vector MENU_TEXT_WARNING = '0.8 0 0';
vector MENU_TEXT_GREEN = '0 0.8 0';
vector MENU_DARKEN = '1 1 1';

vector MENU_TEXT_SMALL = '8 8 0';
vector MENU_TEXT_MEDIUM = '16 16 0';
vector MENU_TEXT_LARGE = '24 24 0';
float MENU_START_CONTENT = 32;

vector MENU_TEXT_BLUE_FO = '0.3 0.4 0.7';
vector MENU_TEXT_RED_FO = '0.7 0.4 0.3';
vector MENU_TEXT_YELLOW_FO = '0.7 0.7 0.3';
vector MENU_TEXT_GREEN_FO = '0.4 0.7 0.3';
vector MENU_TEXT_SPEC_FO = '0.1 0.1 0.1';

vector TEXT_TEAM_COLOUR[] = {
    MENU_TEXT_BLUE_FO,
    MENU_TEXT_RED_FO,
    MENU_TEXT_YELLOW_FO,
    MENU_TEXT_GREEN_FO
};

#define FO_MENU_FLAG_USE_MOUSE 1
#define FO_MENU_FLAG_CENTER 2
#define FO_MENU_FLAG_SHOW_SHORTCUTS 4
#define FO_MENU_FLAG_SHOW_VALUES 8
#define FO_MENU_FLAG_WARNING 16
#define FO_MENU_FLAG_ALLOW_INTERMISSION 32

#define FO_MENU_STATE_HIDDEN 0
#define FO_MENU_STATE_NORMAL 1
#define FO_MENU_STATE_DISABLED 2
#define FO_MENU_STATE_SPACER 3

#define FO_MENU_MAX_OPTIONS 20

#define FO_MENU_TRANSPARENCY 0.2

#define MOTD_TIME 30

#define TEAM_SPECTATOR 9
#define TEAM_OBSERVER 99

#define MAP_MAX_CHARS 20

.float owned_by;
.string netname;
.float playerid;
float fo_hud_editor;
float fo_hud_menu_active;
vector ScreenSize;
float number_of_teams;
float last_skin;
float last_team;
vector sentry_pos;
vector dispenser_pos;
vector touched_dispenser_pos;
//entity player_list_head;
float player_menu_type;
float admin_menu_next_update;
float captain1;
float captain2;
float captain1_temp;
float captain2_temp;
float is_admin;
float motd_expiry;
float quad_round;
float quad_rounds_total;
float fo_flash;
float medic_type;
float nailgren_type;
//float game_started;
float prematch;
float round_active;
float round_over;
float showingscores;
float mapvote_expiry;
float grentimer_waiting; //grenade primed, but not thrown
float jump_counter;
float frames_since_onground;
float num_mapvotes;
float num_mapvotes_filtered;
entity vote_selected_item;
float vote_selected_index;
float vote_list_offset;
entity current_vote;
string vote_list_filter;

.string name;
.string description;
.string groupname;
.entity group;
.float team_num;
.float min_val;
.float max_val;
.float votecount;
.float localmap;

float(string) GetDrawPanel;
void(string id, string identify) Hud_DrawIdentifyPanel;
void (string panelid, float display, string text, string icon) Hud_DrawHudOptionsPanel;
void (string id, float playerclass) Hud_DrawClassInfoPanel;
void (string panelid) Hud_DrawFlagStatusBar;
void (string panelid) Hud_DrawTeamScorePanel;
void (string panelid) Hud_DrawMapMenuPanel;
float(string id, vector pos, vector size, float alpha, float enabled) hud_panel;
vector(float panelid) getPosition;
vector(float panelid) getFillSize;

void () SUB_Null = {
};

enum {
    HUD_ALIGN_RIGHT,
    HUD_ALIGN_LEFT,
    HUD_ALIGN_CENTER
};

string HUD_ALIGN[] = {
    "Right",
    "Left",
    "Center"
};

string HUD_HORIZONTAL_ALIGN[] = {
    "Left",
    "Center",
    "Right"
};

string HUD_VERTICAL_ALIGN[] = {
    "Top",
    "Middle",
    "Bottom"
};

string MENU_OPTION[] = {
    "1","2","3","4","5","6","7","8","9","0","-","+"
};

const float HUD_SNAP_NONE = 0;
const float HUD_SNAP_LEFT = 1;
const float HUD_SNAP_CENTER = 2;
const float HUD_SNAP_RIGHT = 4;
const float HUD_SNAP_TOP = 8;
const float HUD_SNAP_VCENTER = 16;
const float HUD_SNAP_BOTTOM = 32;

const float HUD_SNAP_TOP_LEFT = 9;
const float HUD_SNAP_TOP_CENTER = 10;
const float HUD_SNAP_TOP_RIGHT = 12;
const float HUD_SNAP_VCENTER_LEFT = 17;
const float HUD_SNAP_VCENTER_CENTER = 18;
const float HUD_SNAP_VCENTER_RIGHT = 20;
const float HUD_SNAP_BOTTOM_LEFT = 33;
const float HUD_SNAP_BOTTOM_CENTER = 34;
const float HUD_SNAP_BOTTOM_RIGHT = 36;

const float HUD_SNAP_NORTH = 64;
const float HUD_SNAP_EAST = 128;
const float HUD_SNAP_SOUTH = 256;
const float HUD_SNAP_WEST = 512;

typedef struct 
{
    string icon;
} FO_Hud_Icons;

FO_Hud_Icons HudIcons[37] = {
    {ICON_CLIPSIZE},
    {ICON_FRAGSTREAK},
    {ICON_CAPS},
    {ICON_GREN_NONE},
    {ICON_GREN_NORMAL},
    {ICON_GREN_NAIL},
    {ICON_GREN_EMP},
    {ICON_GREN_GAS},
    {ICON_GREN_CONCUSSION},
    {ICON_GREN_FLASH},
    {ICON_GREN_FLARE},
    {ICON_GREN_NAPALM},
    {ICON_GREN_CALTROP},
    {ICON_GREN_BLAST},
    {ICON_IDENTIFY},
    {ICON_SCOUT},
    {ICON_SNIPER},
    {ICON_SOLDIER},
    {ICON_DEMOMAN},
    {ICON_MEDIC},
    {ICON_HWGUY},
    {ICON_PYRO},
    {ICON_SPY},
    {ICON_ENGINEER_SG},
    {ICON_ENGINEER_DISP},
    {ICON_SECURITY_BUTTON_GREEN},
    {ICON_SECURITY_BUTTON_YELLOW},
    {ICON_SECURITY_BUTTON_RED},
    {ICON_SECURITY_BUTTON_BLUE},
    {ICON_SECURITY_BUTTON_ANY},
    {ICON_FLAG_ANY},
    {ICON_FLAG_BLUE},
    {ICON_FLAG_RED},
    {ICON_FLAG_YELLOW},
    {ICON_FLAG_GREEN},
    {"textures/wad/num_percent.png"},
    {"textures/wad/anum_percent.png"}
};

FO_Hud_Icons GrenadeIcons[12] = {
    {ICON_GREN_NONE},
    {ICON_GREN_NORMAL},
    {ICON_GREN_CONCUSSION},
    {ICON_GREN_NAIL},
    {ICON_GREN_MIRV},
    {ICON_GREN_NAPALM},
    {ICON_GREN_FLARE},
    {ICON_GREN_GAS},
    {ICON_GREN_EMP},
    {ICON_GREN_FLASH},
    {ICON_GREN_CALTROP},
    {ICON_GREN_BLAST},
};

typedef struct {
    string ClipSize;
    float FragStreak;
    float Caps;
    string Identify;
    float PlayerClass;
    float Gren1;
    float Gren2;
    string MOTD;
    string Hint;
    //1 = Clanmode, 2 = Quadmode, 4 = Duelmode, 8 = Prematch
    float GameMode;
    float Ready;
    float CountdownStarted;
    // scout
    float ScannerOn;
    float ScannerRange;
    float ScannerTeamNo;
    float ScannerPlayerClass;
    float ScannerTFItemsFlags;
    // sniper
    float SniperDam;
    float SniperMax;
    // demoman
    float IsDetpacking;
    float DetpackLeft;
    // medic
    float AuraActive;
    float HealCount;
    float HealAmount;
    float AuraStatus;
    // hwguy
    float LockedCannon;
    // pyro
    float AirBlast;
    // spy
    float IsUndercover;
    float InvisOnly;
    float UndercoverTeam;
    float UndercoverSkin;
    float UndercoverTimer;
    float DisguiseTeam;
    float QueueTeam;
    float DisguiseSkin;
    float QueueSkin;
    // engineer
    float IsBuilding;
    float BuildingPercentage;
    float HasSentry;
    float SentryLevel;
    float SentryHealth;
    float SentryAmmoShells;
    float SentryAmmoRockets;
    float HasDispenser;
    float DispenserHealth;
} FO_SBAR;
FO_SBAR SBAR;

typedef struct {
    float ceasefire;
    float pubmode;
    float clanmode;
    float quadmode;
    float duelmode;
    float quad_rounds;
    float quad_round_time;
    float captainmode;
    float timelimit;
    float fraglimit;
    float class_override;
    float class_limit_scout;
    float class_limit_sniper;
    float class_limit_soldier;
    float class_limit_demoman;
    float class_limit_medic;
    float class_limit_hwguy;
    float class_limit_pyro;
    float class_limit_spy;
    float class_limit_engineer;
    float spurs_on;
    float spurs_scout;
    float spurs_spy;
    float spurs_engineer;
    float spurs_duration;
    float spurs_boost;
    float spurs_consume;
    float spurs_flag;
} SERVER_SETTINGS;
SERVER_SETTINGS SERVER_ADMIN;

typedef struct
{
    float x;
    float y;
} MouseStruct;

MouseStruct Mouse;
MouseStruct PrevMouse;
float MouseDown;

typedef struct {
    string filename;
    vector colour;
} HUDIcon;

typedef struct {
    float id;
    string message;
    //string model;
    entity model;
    float timeleft;
    float state;
    vector loc;
    string carrier;
    string locname;
    HUDIcon icon;
} FlagInfoLine;

FlagInfoLine FlagInfoLines[10];

/*
typedef struct {
    float team1score;
    float team2score;
    float team3score;
    float team4score;
} FO_TeamScores;

FO_TeamScores TS;
*/

float TeamScore[4];

// hud stuff
typedef struct {
    string id;
    string Name;
    vector Position;
    vector FillSize;
    float Scale;
    float TextScale;
    float Display;
    float Orientation;
    void(string panelid, float display, string text, string icon) drawPanel;
    string() getValue;
    float Style;
    FO_Hud_Icons * Icon;
    float Snap;
    float Status;
    float SnapID;
} FO_Hud_Panel;

FO_Hud_Panel DrawPanel;
FO_Hud_Panel NewPanel;
float Editor_SelectedPanel_Index;

typedef struct {
    vector MousePos;
} FO_Hud_Settings;
FO_Hud_Settings HudSettings;

typedef struct {
    float grentype;
    float expires;
    float icon_index;
} FO_Hud_Grentimer;

FO_Hud_Grentimer FO_Hud_Grentimers[5];

// scoreboard stuff
typedef struct {
    float ping;
    float pl;
    string classtext;
    string name;
    float team_no;
    float score;
    float caps;
    float touches;
    float kills;
    float teamkills;
    float deaths;
    float afflicted;
    float teamafflicted;
    float damagegiven;
    float damagetaken;
    float ready;
    float chat;
} FO_ScoreBoardLine;

// fte maxclients is 255, right?
#define FO_SCOREBOARDLINES_LENGTH 32

string FO_ScoreBoardColumns[] = {
    "ping",
    "pl",
    "class",
    "score",
    "name",
    "caps",
    "tchs",
    "kils",
    "tkil",
    "dths",
    "affl",
    "tafl",
    "dmgg",
    "dmgt"
};

enum {
    HUD_PANEL_CLIPSIZE,
    HUD_PANEL_FRAGSTREAK,
    HUD_PANEL_CAPS,
    HUD_PANEL_GREN1,
    HUD_PANEL_GREN2,
    HUD_PANEL_PLAYERCLASS,
    HUD_PANEL_IDENTIFY,
    HUD_PANEL_FLAGINFO,
    HUD_PANEL_GRENTIMER,
    HUD_PANEL_MENU,
    HUD_PANEL_MOTD,
    HUD_PANEL_MENU_HINT,
    HUD_PANEL_GAME_MODE,
    HUD_PANEL_READY,
    HUD_PANEL_SHOWSCORES,
    HUD_PANEL_TEAM_SCORE,
    HUD_PANEL_MAP_MENU,
    HUD_PANEL_HUDOPTIONS,
};

#define FOCMD_OLDSCOREBOARD "fo_oldscoreboard"
#define FOCMD_AUTOHOP "fo_autohop"
#define FOCMD_GRENTIMER "fo_grentimer"
#define FOCMD_ADMIN_MENU_UPDATE_TIME "fo_adminrefresh"

float team_no;
float is_spectator;
float player_class;
float is_observer;

vector FO_Hud_Icon_Size = [24, 24, 0];
vector FO_Hud_Icon_Font_Size = [8, 8, 0];

#pragma noref 1
#pragma warning error Q101 /*too many parms*/
#pragma warning error Q105 /*too few parms*/
#pragma warning enable F301 /*non-utf-8 strings*/
#pragma warning enable F302 /*uninitialised locals*/
#pragma target FTE
#ifndef CSQC
#define CSQC
#endif

string(string s) strtrim = #0:strtrim; /*
		Trims the whitespace from the start+end of the string. */
float(float playernum, string keyname, optional float assumevalue) getplayerkeyfloat = #0:getplayerkeyfloat; /*
		Cheaper version of getplayerkeyvalue that avoids the need for so many tempstrings. */
