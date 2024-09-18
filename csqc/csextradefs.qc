#include "../share/defs.h"

#define DEFCVAR_FLOAT(n,d) var float autocvar_##n = d;
#define DEFCVAR_STRING(n,d) var string autocvar_##n = d;
#define CVARF(n) autocvar_##n
#define CVARS(n) autocvar_##n

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

vector SCOREB_HEADER = '0.7 0.7 0.7';
vector SCOREB_NAME  = '1 1 1';
vector SCOREB_FIELD  = '0.9 0.9 0.9';
vector SCOREB_SELF_BG  = '0.8 0.8 0.8';
vector SCOREB_SPECTATED_BG  = '0.8 0.8 0.2';

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
    MENU_TEXT_GREEN_FO,
    MENU_TEXT_SPEC_FO,
};

const float DEFAULT_VIEWHEIGHT = 22;
const vector PLAYER_MINS = [-16, -16, -24];
const vector PLAYER_MAXS = [16, 16, 32];

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

#define MAX_SLOT_HISTORY_SIZE 10

.void() removefunc;
.float owned_by;
.string netname;
.float playerid;
float fo_hud_editor;
float fo_hud_menu_active;
vector ScreenSize;
float number_of_teams;
float last_selected_skin;
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
//float game_started;
float prematch;
float round_active;
float round_over;
float round_ending;
float showingscores;
float mapvote_expiry;
float num_mapvotes;
float num_mapvotes_filtered;
entity vote_selected_item;
float vote_selected_index;
float vote_list_offset;
entity current_vote;
string vote_list_filter;
float oldbuttons;
float zoom_scale;
float pick_up_time;
float flag_team;

float slot_history[MAX_SLOT_HISTORY_SIZE];
float slot_history_top, slot_under_stack;

.string name;
.string description;
.string groupname;
.entity group;
.float team_num;
.float min_val;
.float max_val;
.float votecount;
.float localmap;

.string hittext_str;
.float hittext_hitflags;
.float hittext_expires;

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

FO_Hud_Icons HudIcons2[39] = {
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
    {ICON_GREN_SHOCK},
    {ICON_GREN_BURST},
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
    {"textures/wad/num_percent"},
    {"textures/wad/anum_percent"}
};

FO_Hud_Icons FaceIcons[] = {
    //normal
    {"textures/wad/face1"},
    {"textures/wad/face2"},
    {"textures/wad/face3"},
    {"textures/wad/face4"},
    {"textures/wad/face5"},
    //pain
    {"textures/wad/face_p1"},
    {"textures/wad/face_p2"},
    {"textures/wad/face_p3"},
    {"textures/wad/face_p4"},
    {"textures/wad/face_p5"},
};

FO_Hud_Icons FaceInvisibleIcon = {"textures/wad/face_invis"};
FO_Hud_Icons FaceInvisibleInvulnerableIcon = {"textures/wad/face_inv2"};
FO_Hud_Icons FaceInvulnerableIcon = {"textures/wad/face_invul2"};
FO_Hud_Icons FaceQuadIcon = {"textures/wad/face_quad"};

FO_Hud_Icons ArmourIcons[] = {
    {"textures/wad/disc"},
    {"textures/wad/sb_armor1"},
    {"textures/wad/sb_armor2"},
    {"textures/wad/sb_armor3"},
};
FO_Hud_Icons AmmoIcons[] = {
    {"textures/wad/sb_shells"},
    {"textures/wad/sb_nails"},
    {"textures/wad/sb_rocket"},
    {"textures/wad/sb_cells"},
};


typedef struct {
    string ClipSize;
    float FragStreak;
    float Caps;
    string Identify;
    string MOTD;
    string Hint;
    //1 = Clanmode, 2 = Quadmode, 4 = Duelmode, 8 = Prematch
    float GameMode;
    float ReadyStatus;
    float CountdownStarted;
    // scout
    float ScannerOn;
    float ScannerRange;
    float ScannerTeamNo;
    float ScannerPlayerClass;
    float ScannerTFItemsFlags;
    // sniper
    float SniperDam;
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
    float new_balance;
    float quad_rounds;
    float quad_round_time;
    float fo_login_required;
    float fo_matchrated;
    float play_to_completion;
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
} SERVER_SETTINGS;
SERVER_SETTINGS SERVER_ADMIN;

typedef struct
{
    float x;
    float y;
} MouseStruct;

MouseStruct Mouse;
MouseStruct PrevMouse;

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

enum PanelID:float {
    HUDP_INVALID = 0,  // Reserve 0 so we can recognize an uninit menu
    HUDP_FIRST = 100,
    HUDP_TEAMSCORE = HUDP_FIRST,  // We put this first so that we open to below.
    HUDP_MAP_MENU,    // We put these up front so that they are
    HUDP_SHOWSCORES,  // rendered under other elements when editing
    HUDP_MENU,
    HUDP_MENU_HINT,
    HUDP_CLIPSIZE,
    HUDP_RELOADPROGRESS,
    HUDP_FRAGSTREAK,
    HUDP_CAPS,
    HUDP_GREN1,
    HUDP_GREN2,
    HUDP_SPECIAL,
    HUDP_IDENTIFY,
    HUDP_FLAGINFO,
    HUDP_GRENTIMER,
    HUDP_MOTD,
    HUDP_GAME_MODE,
    HUDP_NOTIFICATION,
    HUDP_HEALTH,
    HUDP_FACE,
    HUDP_AMMO,
    HUDP_AMMOICON,
    HUDP_ARMOUR,
    HUDP_ARMOURICON,
    HUDP_INVSHELLS,
    HUDP_INVNAILS,
    HUDP_INVROCKETS,
    HUDP_INVCELLS,
    HUDP_GAMECLOCK,
    HUDP_QUAD,
    HUDP_PENT,
    HUDP_RING,
    HUDP_SUIT,
    HUDP_KEY1,
    HUDP_KEY2,
    HUDP_RUNE1,
    HUDP_RUNE2,
    HUDP_RUNE3,
    HUDP_RUNE4,
    HUDP_GUN2,
    HUDP_GUN3,
    HUDP_GUN4,
    HUDP_GUN5,
    HUDP_GUN6,
    HUDP_GUN7,
    HUDP_GUN8,
    HUDP_SPEED,
    HUDP_SPEEDBAR,
    HUDP_PING,
    HUDP_OPTIONS,  // Should be the last HUD element so that it's always on top.
    HUDP_LAST = HUDP_OPTIONS,

    HUDP_GAP = 500,  // Just to make ids larger than this distinguishable.

    HUDP_OPTION_LIST,
    HUDP_OPTION_PANEL,

    HUDB_FIRST,
    HUDB_MAP_VOTE,
    HUDB_MAP_CHANGE,
    HUDB_OPTION_LIST,
    HUDB_OPTION_SCROLLUP,
    HUDB_OPTION_SCROLLDOWN,
    HUDB_LAST,

    HUDE_FIRST,
    HUDE_OPTION_SCALE_SLIDER,
    HUDE_OPTION_TEXTSCALE_SLIDER,
    HUDE_OPTION_SCALE_SCROLL,
    HUDE_OPTION_TEXTALIGN_TOGGLE,
    HUDE_OPTION_SHOWHIDE_TOGGLE,
    HUDE_OPTION_HSNAP_TOGGLE,
    HUDE_OPTION_VSNAP_TOGGLE,
    HUDE_OPTION_SHOWALL_TOGGLE,
    HUDE_LAST,

    HUDL_FIRST = HUDB_LAST,
    HUDL_OPTION_BASE = 1000,
    HUDL_MAP_BASE = 2000,

    HUD_LAST = 10000,
};

// hud stuff
typedef struct {
    PanelID id;
    string SaveName;
    string Name;
    vector Position;
    vector FillSize;
    float Scale;
    float TextScale;
    float Display;
    float Orientation;
    float System;  // System panel display is not user managed (e.g. vote menu)
    void(float display, string text) drawPanel;
    string() getValue;
    float Style;
    float Snap;
    float Status;
    float SnapID;
} FO_Hud_Panel;

FO_Hud_Panel NullPanel;
FO_Hud_Panel NewPanel;
FO_Hud_Panel* MenuPanel;
float Editor_SelectedPanel_Index;

typedef struct {
    vector MousePos;
} FO_Hud_Settings;
FO_Hud_Settings HudSettings;

enumflags {
    FL_GT_SOUND,
    FL_GT_THROWN,
    FL_GT_ADJPING,
    FL_GT_LOCAL,
};

void(string identify) Hud_DrawIdentifyPanel;
void (float display, string text) Hud_DrawHudOptionsPanel;
void (float playerclass) Hud_DrawClassInfoPanel;
void () Hud_DrawFlagStatusBar;
void () Hud_DrawTeamScorePanel;
void () Hud_DrawMapMenuPanel;
float(PanelID id, vector pos, vector size, float alpha, float enabled) hud_panel;
vector(PanelID) getPosition;
vector(PanelID) getFillSize;

enum {
    D_skip,
    D_drawpic,
    D_drawstring,
    D_drawfill,
};

struct Draw_Args {
    PanelID id;
    int type;
    vector pos;
    string s_arg;
    vector size;
    vector rgb;
    float alpha;
    float drawflag;
};

struct {
    int enabled;
    PanelID active_panel;
    float last_update;
    int draw_direct;
    Draw_Args draw_cache[1000];
    int draw_count;
    float free_cache[1000];
    int free_count;
} hud_render_cache;

DEFCVAR_FLOAT(fo_hud_cache, 1)
DEFCVAR_FLOAT(fo_hud_fps, 60)

enum {
    HRC_NF_NO_UPDATE = 0,
    HRC_NF_FULL,
    HRC_NF_PARTIAL,
};

inline float HRC_fps_time() { return 1/max(min(CVARF(fo_hud_fps), 77 * 2), 30); }

void HRC_Invalidate(PanelID panel) {
    float i, j;

    for (i = 0; i < hud_render_cache.draw_count; i++) {
        if (hud_render_cache.draw_cache[i].id == panel + 1) {
            hud_render_cache.draw_cache[i].id = 0;
            hud_render_cache.draw_cache[i].type = D_skip;
            hud_render_cache.free_cache[hud_render_cache.free_count++] = i;
        }
    }

    // Ascending order sort so that we don't end up inverting rendering order
    // when pulling from the free-list.
    for (i = 0; i < hud_render_cache.free_count; i++)
        for (j = i + 1; j < hud_render_cache.free_count; j++)
            if (hud_render_cache.free_cache[i] < hud_render_cache.free_cache[j]) {
                float tmp = hud_render_cache.free_cache[i];
                hud_render_cache.free_cache[i] = hud_render_cache.free_cache[j];
                hud_render_cache.free_cache[j] = tmp;
            }
}

void HRC_InvalidateAll() {
    hud_render_cache.draw_count = 0;
    hud_render_cache.free_count = 0;
}

void HRC_SetActive(PanelID panel) {
    hud_render_cache.active_panel = panel;
}

FO_Hud_Panel* getHudPanel(PanelID panelid);

// Returns true if HUD should be re-rendered this frame.
float HRC_NewFrame() {
    // Rate limit even the more complicated enable checks.
    /* if (time < hud_render_cache.last_update + HRC_fps_time()) */
    /*     return !hud_render_cache.enabled; */
    /* hud_render_cache.last_update = time; */

    if (!CVARF(fo_hud_cache) ||
        fo_hud_menu_active || fo_hud_editor ||
        getHudPanel(HUDP_MAP_MENU)->Display) {
        // Either explicitly disabled, or rendering a more complicated scene
        // like the editor for which we'll just display in place.
        hud_render_cache.enabled = FALSE;
        return TRUE;
    }

    hud_render_cache.enabled = TRUE;
    return FALSE;
}

static Draw_Args* next_args() {
    float idx;
    if (hud_render_cache.free_count)
        idx = hud_render_cache.free_cache[--hud_render_cache.free_count];
    else
        idx = hud_render_cache.draw_count++;

    Draw_Args* result = &hud_render_cache.draw_cache[idx];
    result->id = hud_render_cache.active_panel + 1;  // 1-based, 0 => free.
    return result;
}

void HRC_drawpic(vector pos, string pic, vector size, vector rgb='1 1 1',
                float alpha=1, float drawflag=0) {
    if (pic == "")
        return;
    if (!hud_render_cache.enabled) {
        drawpic(pos, pic, size, rgb, alpha, drawflag);
    } else {
        Draw_Args* args = next_args();
        args->type = D_drawpic;
        args->pos = pos;
        args->s_arg = pic;
        args->size = size;
        args->rgb = rgb;
        args->alpha = alpha;
        args->drawflag = drawflag;
    }
}

void HRC_drawstring(vector pos, string text, vector size, vector rgb='1 1 1',
                   float alpha=1, float drawflag=0) {
    if (text == "")
        return;
    if (!hud_render_cache.enabled) {
        drawstring(pos, text, size, rgb, alpha, drawflag);
    } else {
        Draw_Args* args = next_args();
        args->type = D_drawstring;
        args->pos = pos;
        args->s_arg = text;
        args->size = size;
        args->rgb = rgb;
        args->alpha = alpha;
        args->drawflag = drawflag;
    }
}

void HRC_drawfill(vector pos, vector size, vector rgb,
                   float alpha=1, float drawflag=0) {
    if (!hud_render_cache.enabled) {
        drawfill(pos, size, rgb, alpha, drawflag);
    } else {
        Draw_Args* args = next_args();
        args->type = D_drawfill;
        args->pos = pos;
        args->size = size;
        args->rgb = rgb;
        args->alpha = alpha;
        args->drawflag = drawflag;
    }
}

void HRC_Render() {
    if (!hud_render_cache.enabled)
        return;

    for (int i = 0; i < hud_render_cache.draw_count; i++) {
        Draw_Args* args = &hud_render_cache.draw_cache[i];
        if (args->type == D_skip)
            continue;
        else if (args->type == D_drawpic)
            drawpic(args->pos, args->s_arg, args->size, args->rgb, args->alpha, args->drawflag);
        else if (args->type == D_drawstring)
            drawstring(args->pos, args->s_arg, args->size, args->rgb, args->alpha, args->drawflag);
        else if (args->type == D_drawfill)
            drawfill(args->pos, args->size, args->rgb, args->alpha, args->drawflag);
    }
}

DEFCVAR_FLOAT(fo_grentimer_ping_frac, 1);  // Fraction of ping to correct for.
DEFCVAR_FLOAT(fo_grentimer_nostack, 0);    // When set, only play soonest timer.

class CsGrenTimer;
CsGrenTimer grentimers[NUM_GREN_TIMERS];

class CsGrenTimer {
    float index_;
    float expires_at_;
    float raw_expires_at_;
    float flags_;
    float grentype_;
    float playing_;

    nonvirtual float() index { return index_; };
    nonvirtual float() active { return expires_at_ > time; };
    nonvirtual float() expiry { return expires_at_; };
    nonvirtual float() raw_expiry { return raw_expires_at_; };
    nonvirtual float() grentype { return grentype_; };

    nonvirtual float(float flag) test_flag { return flags_ & flag; };
    nonvirtual void(float flag) set_flag { flags_ |= flag; };
    nonvirtual void(float flag) clear_flag { flags_ &= ~flag; };

    nonvirtual float() sound_offset {
        float offset = max(3.8 - (expires_at_ - time), 0);
        return offset;
    };

    nonvirtual void(float expires_at, float grentype, float timer_flags) Set;
    nonvirtual void() Stop;

    nonvirtual void() PauseSound {
        playing_ = FALSE;
        if (flags_ & FL_GT_SOUND)  // -volume => stop.
            soundupdate(this, CHAN_VOICE, "", -1, 0, 0, 0, 0);
    };
    nonvirtual void() StartSound;

    nonvirtual void(float offset, float adj_sound) adj_sync {
      if (!playing_)
          return;

      raw_expires_at_ += offset;
      if (adj_sound) {  // Not yet working well
          expires_at_ += offset;
          StartSound();
      }
    };

    static float next_index_;
    static CsGrenTimer last_;

    static void() Init {
        for (float i = 0; i < grentimers.length; i++)
            grentimers[i] = spawn(CsGrenTimer, index_: i);
    };

    static void() StopAll {
        for (float i = 0; i < grentimers.length; i++)
            grentimers[i].Stop();
    };

    static CsGrenTimer() GetNext {
        next_index_ = (next_index_ + 1) % grentimers.length;
        last_ = grentimers[next_index_];
        return last_;
    };

    static CsGrenTimer(float exp, float eps) Match {
        CsGrenTimer result = world;
        float best = eps;

        for (float i = 0; i < grentimers.length; i++) {
            float d = fabs(exp - grentimers[i].raw_expiry());
            if (d < best) {
                best = d;
                result = grentimers[i];
            }
        }
        return result;
    };

    static void() SyncPause {
        // Time froze, but sound kept running, realign.
        for (float i = 0; i < grentimers.length; i++)
            if (grentimers[i].active())
                grentimers[i].PauseSound();
    };

    static void() SyncUnpause {
        // Time froze, but sound kept running, realign.
        for (float i = 0; i < grentimers.length; i++)
            if (grentimers[i].active())
                grentimers[i].StartSound();
    };

    static void() UpdateSoundStack {
        if (!CVARF(fo_grentimer_nostack))
            return;

        CsGrenTimer best = __NULL__;

        for (float i = 0; i < grentimers.length; i++) {
            CsGrenTimer c = grentimers[i];
            if (c.active() && (best == __NULL__ || c.expiry() < best.expiry()))
                best = c;
        }

        if (best != __NULL__ && !best.playing_)
            best.StartSound();
    };

    static CsGrenTimer() GetLast { return last_; };
};

// scoreboard stuff
struct FO_ScoreBoardLine{
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
};

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

struct {
    string icon_ready;
    string icon_chat;
    string icon_afk;
} FO_ScoreBoardAssets;

DEFCVAR_FLOAT(fo_fte_hud, 0);
DEFCVAR_FLOAT(fo_legacy_sbar, 0);
DEFCVAR_FLOAT(fo_csjumpsounds, 1);

struct GameState {
    float localentnum;
    float is_player;
    float is_alive;
    float is_spectator;
    float is_ceasefire;
    float spawn_gen;
};

GameState game_state, prev_game_state;

float team_no;
float crosshair_team_no;
float all_time;
float painfinished;
float jump_counter;
float last_id_time;

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
float(string key, optional float assumevalue) serverkeyfloat = #0:serverkeyfloat; /*
		Version of serverkey that returns the value as a float (which avoids tempstrings). */


vector PM_Org();
vector PM_Vel();

struct veci {
    vector v;
    float i;
};

void cvar_parse4(string s, __out veci target) {
    tokenize(s);
    target.v[0] = stof(argv(0));
    target.v[1] = stof(argv(1));
    target.v[2] = stof(argv(2));
    target.i = stof(argv(3));
}

float servertime;
