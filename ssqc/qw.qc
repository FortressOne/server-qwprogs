#include "../share/defs.h"

void (entity Goal, entity AP, entity ActivatingGoal) AttemptToActivate;
typedef void (float n) f_void_float;

//===========================================================================
// TEAMFORTRESS Defs
//===========================================================================
.float playerclass;
.float last_playerclass;        // The playerclass you played as last life
.float nextpc;                  // The playerclass you'll respawn as
.float last_impulse;            // The previous impulse command from this player
.float armorclass;              // Type of armor being worn
.float tf_items;                // Another flag for player items
.float tf_items_flags;          // Flags for the player items
.float no_grenades_1;           // Number of grenades of type 1 being carried
.float no_grenades_2;           // Number of grenades of type 2 being carried
.float tp_grenades_1;           // 1st type of grenades being carried
.float tp_grenades_2;           // 2nd type of grenades being carried
.float tp_grenade_switch;       // Set to 1 if +gren1 and +gren2 switch places

.float hook_out;                // Dummy field for hook to silence error messages
.float got_aliases;             // TRUE if the player has TeamFortress aliases
.float cheat_check;             // Time when we'll next check for team cheats
.float is_removed;              // TRUE if the entity has been removed
.float is_undercover;           // TRUE for a SPY if they're undercover
.float is_building;             // TRUE for an ENGINEER if they're building something
.float is_detpacking;           // TRUE for a DEMOMAN if they're setting a detpack
.float is_feigning;             // TRUE for a SPY if they're feigning death
.float is_unabletospy;          // TRUE for a SPY if they can't go undercover
.float is_zooming;              // TRUE for a SNIPER if they're currently zoomed in
.float is_quickfiring;          // TRUE for a player if they're using the quick slots
.float is_concussed;            // TRUE for a player who is affected by concussion grenade
.float has_quickfired;          // TRUE for a player that has stopped quick firing (until weapon is ready)
.float has_throwngren;          // TRUE for a player that has thrown a grenade (won't get a free suicide)
.float has_changedteam;         // TRUE for a player that has changed team
.float has_changedclass;        // TRUE for a player that has changed class
.float has_disconnected;        // TRUE if the player has disconnected
.float has_menutimer;           // TRUE if the player has an active menu timer
.float default_sensitivity;     // Player's default (non-zoomed) sensitivity
.float default_fov;             // Player's default (non-zoomed) fov
.float current_fov;             // Player's current field of view
.float zoom_level;              // Start zooming to this fov next frame
.float zoom_fov;                // The default fov to zoom in to when pressing special button
.float zoom_last;               // The last used zoom fov by the player - zoom to this when toggling zoom
.float has_voted_map;           // Map option that player voted for
.float spawn_time;              // Time when player spawned
.float menu_time;               // Time when vote map menu was first issued
.float display_tip;             // Last class tip displayed
.float tip_type;                // Whether the tip displayed is a general tip (1) or class tip (2)
.float tip_time;                // Time when players last requested to see a tip
.float vote_next;               // TRUE if player has voted for a map vote
.float vote_trick;              // TRUE if player has voted for a trick map vote
.float vote_race;               // TRUE if player has voted for a race map vote
.float force_next;              // TRUE if player has voted to force next map
.float vote_close;              // TRUE if player has closed the map vote, resets on spawn
.float detpack_left;            // Seconds left to detpack explosion
.float pipecooldown;            // Time when detpipe command can be issued
.float disguise_skin;           // The skin the spy is changing to
.float queue_skin;              // The skin the spy will change to after team disguise is finished
.float last_skin;               // The last skin the spy disguised as
.float disguise_team;           // The team the spy is changing to
.float queue_team;              // The team the spy will change to after skin disguise is finished
.float last_team;               // The last team the spy disguised as
.float feign_areachecked;       // TRUE if area around spy has been checked for entities when feigned
.float aura_active;             // TRUE if medic aura is active
.float aura_healamount;         // Amount of health given to other players
.float aura_healcount;          // Amount of players given health
.float aura_healtime;           // Aura healing status will be shown in status bar until this time
.float regen_time;              // Time when the medic last regenerated cells
.float regen_cooldown;          // Time to cooldown cell regeneration after using medikit heal
.float saveme_time;             // Time when player issued /saveme command
.float dash_cooldown;           // Cooldown for Scout dash
.float undercover_timer;        // Seconds left until disguised
.float power_time;              // The time when sniper power in status bar was last updated
.float power_full;              // Whether sniper power has reached full power or not
.float sentry_ticks;            // Used to indicate when engineer's sentry gun is finished building
.float dispenser_ticks;         // Used to indicate when engineer's dispenser is finished building
.float building_percentage;     // The building percentage shown in status bar
.float fragstreak;              // Frag streak
.float caps;                    // Caps during this game
.entity nopickup;               // Don't pick up this backpack/ammobox because it doesn't contain any of your ammo types

.float tfstate;                 // State flags for TeamFortress
.entity linked_list;            // Used just like chain. Has to be separate so
                                // it doesn't interfere with chain. See T_RadiusScan

.entity observer_list;          // Used by undefined classes, see TF_MovePlayer

// Identify variables
.string ident_string;           // Status bar string for identify
.string last_ident_string;      // Last Status bar string for identify
.float ident_time;              // The time when last identify found a player
.float autoid_type;             // 0 = ignore noone, 1 = ignore teammates, 2 = ignore enemies
.float autoid_time;             // Time when autoid settings were last checked

// Playerclass handling variables
.float maxammo_shells;
.float maxammo_nails;
.float maxammo_cells;
.float maxammo_rockets;
.float need_shells;
.float need_nails;
.float need_rockets;
.float need_cells;
.float items_allowed;
.float armor_allowed;
.float maxarmor;
.float maxfbspeed;              // Maximum forward/back speed
.float maxstrafespeed;          // Maximum side speed

.float weaponmode;              // Used for multiple mode weapons
.float last_weaponmode;         // Last weapon's weapon mode
.float motd;                    // Used to display MOTD
.float current_menu;
.float current_menu_type;
.float current_menu_page;
.float menu_count;
.float menu_displaytime;
.f_void_float menu_input;

float toggleflags;              // toggleable flags

string nextmap;

//float respawn_delay_time;

//
// FortressMap stuff
//
float number_of_teams;
float illegalclasses;
float illegalclasses1;
float illegalclasses2;
float illegalclasses3;
float illegalclasses4;
float civilianteams;

float team1col;                 // Colours for each of the 4 teams
float team2col;                 // If there's enough demand, we'll
float team3col;                 // allow more than four teams...
float team4col;
float team1score;               // Goal Score of each team
float team2score;
float team3score;
float team4score;
float team1lives;               // Number of lives each team's players have
float team2lives;
float team3lives;
float team4lives;
float team1maxplayers;          // Max number of players allowed in each team
float team2maxplayers;
float team3maxplayers;
float team4maxplayers;
float team1advantage;           // only used if the teamplay equalisation bits are set
float team2advantage;           // stores the damage ratio players take/give
float team3advantage;
float team4advantage;

float round_winner_team;
entity round_winner;
float round_winner_print_health;

.float team_no;                 // The team you belong to
.float lives;                   // The number of lives you have left

.float infection_team_no;       // The team_no of the person who infected you

// CTF stuff
float CTF_Map;

float coop;

.entity building;               // The building the ENGINEER is using
.float building_wait;           // Used to prevent using a building again immediately
.entity real_owner;
.float has_dispenser;           // TRUE for an ENGINEER if he has a dispenser
.float has_sentry;              // TRUE for an ENGINEER if he has a sentry
.entity sentry_ent;				// Contains sentry gun entity

.float real_frags;              // Used to store the players frags when TeamFrags is On

.float respawn_time;            // players can't respawn within this time.
.float suicide_time;            // players can't suicide within this time.

/*==============================================*/
/* New Weapon variables				*/
/*==============================================*/
.float weapons_carried;         // the weapons the player is carrying
.float current_weapon;          // the weapon the player is using
.float last_weapon;             // the last weapon the player was using
.float current_weaponslot;      // the currently equipped weaponslot
.float last_weaponslot;         // the last equipped weaponslot
.float queue_weaponslot;        // the weaponslot to switch to when possible
.float queue_weaponstate;       // the weaponstate to load when possible
.float next_weapon;             // used by weapon slots to communicate which weapon to select
.float next_weaponmode;         // used by weapon slots to communicate which weapon mode to select

// weapon states
.float weaponstate_current_weaponslot;
.float weaponstate_last_weaponslot;
.float weaponstate_current_weapon;
.float weaponstate_last_weapon;
.float weaponstate_weaponmode;
.float weaponstate_last_weaponmode;

.float ammo_medikit;            // Ammo used for the medikit
.float maxammo_medikit;
.float ammo_detpack;            // Ammo used for the detpack
.float maxammo_detpack;
.float noammo;                  // used for no ammo error messages

// variables used for reloading
.float reload_shotgun;
.float reload_super_shotgun;
.float reload_sniper_rifle;
.float reload_grenade_launcher;
.float reload_rocket_launcher;
.float reload_assault_cannon;
.float reload_tick;             // how often the status bar should be refreshed during reload
.float reload_time;             // when the reload will finish
.float reload_clipsize;         // how much ammo is currently in the reloading clip
.float reload_sniper_ticks;		// used to indicate when sniper rifle (with only 1 clip) will be reloaded

// Assault Cannon
.float heat;

// Dispenser
.float deff;                    // Dispenser efficiency
.float dimmune;                 // Immune to dispenser stocking
.float duse;                    // Time of last dispenser usage

// Team Color Cheat Checking
.float immune_to_check;

// Make sure people don't do too many saveme sounds
.float last_saveme_sound;

.float no_active_nail_grens;
.float no_active_napalm_grens;
.float no_active_gas_grens;

/*======================================================================*/
/* TEAMFORTRESS GOALS							*/
/*======================================================================*/
// Variables used in the Goals
.float goal_no;                 // Goal number of this goal
.float group_no;                // Goal group this goal is in
.float goal_state;              // State of this goal
.float owned_by;                // The team this goal/item/whatever belongs to

// Goal Activation details
.float goal_activation;         // Bitfields. Determines how this goal is activated
.float goal_effects;            // Bitfields. Determines which players are affected by this goal
.float goal_result;             // Bitfields. Determines the results of activation
.float goal_group;              // Bitfields. Determines how groups are affected by activation of this goal

.float else_goal;               // A Goal that's activated if this one fails to activate

.float if_goal_is_active;
.float if_goal_is_inactive;
.float if_goal_is_removed;
.float if_group_is_active;
.float if_group_is_inactive;
.float if_group_is_removed;

// Goal Result details
.float activate_goal_no;
.float inactivate_goal_no;
.float remove_goal_no;
.float restore_goal_no;
.float activate_group_no;
.float inactivate_group_no;
.float remove_group_no;
.float restore_group_no;
.float switch_team_group_no;

.vector goal_min;
.vector goal_max;

// Item State behaviour
.float has_item_from_group;
.float hasnt_item_from_group;
.float remove_item_group;
.float return_item_no;
.float if_item_has_moved;
.float if_item_hasnt_moved;

// Spawnpoint behaviour
.float remove_spawnpoint;
.float restore_spawnpoint;
.float remove_spawngroup;
.float restore_spawngroup;

// Item Displaying details
.float display_item_status1;    // Goal displays the status of these items
.float display_item_status2;
.float display_item_status3;
.float display_item_status4;
.string team_str_home;          // Displayed when the item is at home base
.string team_str_moved;         // Displayed when the item has been moved
.string team_str_carried;       // Displayed when the item is being carried
.string non_team_str_home;      // Displayed when the item is at home base
.string non_team_str_moved;     // Displayed when the item has been moved
.string non_team_str_carried;   // Displayed when the item is being carried

// Goal/Timer/GoalItem/Trigger existence checking
.float ex_skill_min;            // Exists when the skill is >= this value
.float ex_skill_max;            // Exists when the skill is <= this value

// Score increases
.float increase_team1;          // Increase the scores of particular teams
.float increase_team2;
.float increase_team3;
.float increase_team4;

// Centerprinting
.string broadcast;              // Centerprinted to all, overridden by the next two
.string team_broadcast;         // Centerprinted to AP's team members, but not the AP
.string non_team_broadcast;     // Centerprinted to non AP's team members
.string owners_team_broadcast;  // Centerprinted to the members of the team that own the Goal/Item
.string netname_broadcast;      // same as above, prepended by AP netname and bprinted
.string netname_team_broadcast; // same as above, prepended by AP netname and bprinted
.string netname_non_team_broadcast;     // same as above, prepended by AP netname and bprinted
.string netname_owners_team_broadcast;  // same as above, prepended by AP netname and bprinted

.string team_drop;              // Centerprinted to item owners team
.string non_team_drop;          // Centerprinted to everone not on item owners team
.string netname_team_drop;      // same as above, prepended by AP netname and bprinted
.string netname_non_team_drop;  // same as above, prepended by AP netname and bprinted

.float all_active;

.float item_list;               // Used to keep track of which goalitems are
                                // affecting the player at any time.
                                // GoalItems use it to keep track of their own
                                // mask to apply to a player's item_list

float item_list_bit;            // Global, used to determine what the bit of
                                // each new GoalItem will be.

.float delay_time;              // For delayed goal results
.float dont_do_triggerwork;
.float track_goal;              // Track this info_goal in the statusbar

// Abbreviations for the above
.float g_a;                     // goal_activation
.float g_e;                     // goal_effects

.string t_s_h;                  // team_str_home
.string t_s_m;                  // team_str_moved
.string t_s_c;                  // team_str_carried
.string n_s_h;                  // non_team_str_home
.string n_s_m;                  // non_team_str_moved
.string n_s_c;                  // non_team_str_carried

.string b_b;                    // broadcast
.string b_t;                    // team_broadcast
.string b_n;                    // non_team_broadcast
.string b_o;                    // owners_team_broadcast
.string n_b;                    // netname_broadcast
.string n_t;                    // netname_team_broadcast
.string n_n;                    // netname_non_team_broadcast
.string n_o;                    // netname_owners_team_broadcast

.string d_t;                    // team_drop
.string d_n;                    // non_team_drop
.string d_n_t;                  // netname_team_drop
.string d_n_n;                  // netname_non_team_drop

.float h_i_g;
.float hn_i_g;
.float r_i_g;
.float a_s;
.float a_n;
.float a_r;
.float a_c;
.float rv_s_h;
.float rs_s_h;
.float rv_gr;
.float rs_gr;
.float rv_g;
.float rs_g;
.float has_abbreviated;

//============================================================================

// pyro
float num_world_flames;
.float numflames;               // number of flames on entity
.string flame_id;               // has to be string so that the C function find() can be used
.float icdmgtime;

// Spy variables
.float undercover_team;
.float undercover_skin;
.string undercover_name;
.entity attacked_by;            // Used by spy feign death to produce a fake death message
.float feignmsg;                // Stores the death message to be used when feigning

float live_camera;
.float camdist;
.vector camangle;
.entity camera_list;

float already_chosen_map;

.float disptimer;
.float fire_held_down;

// sniper location damage stuff
.vector head_shot_vector;
.float leg_damage;

.float cheat_level;

// flash grenade level
.float FlashTime;
.float nailpos;

// anti spam
.float antispam_detpack;        // don't spam detpack messages
.float antispam_feign;          // don't spam feign deaths
.float antispam_assault_cannon; // don't spam assault cannon messages
.float antispam_cannon_air;     // don't spam assault cannon air messages
.float antispam_incendiary_cannon; // don't spam incendiary cannon messages

// status bar stuff
.string StatusString;           // current centerprint text (strzone'd!)
.float StatusStringLines;       // how many lines the centerprint is
.float StatusStringTime;        // when text will time out
.float StatusRefreshTime;       // when sbar is next printed
.float StatusGrenTime;

.float ScannerOn;

float clanbattle;
float clan_scores_dumped;
float cb_prematch;
float v_break;
float v_ready;
.float allowvote;
float game_locked;
float team1frags;
float team2frags;
float team3frags;
float team4frags;
float last_id;
float quadmode;
float quad_winner;
float rounds;
float round_active;
float round_over;
float round_delay_time;
float map_restart_time;
float gametime;
float is_countdown;
float duelmode;
float duel_reset_delay;
float duel_reset_timer;
float no_fire_mode;
float duel_all_grens;
float duel_no_packs;
float votemode;
float voting_started;
float voting_expires;
.entity vote_map;
float vote_anarchy_mode;
float vote_total_votes;
float vote_style;
float vote_threshold;

.float tf_id;

float exec_map_cfgs;
float spy_off;

float spurs_scout;
float spurs_spy;
float spurs_engineer;
float spurs_duration;
float spurs_enabled;
float spurs_boost;
float spurs_consume;
float spurs_flag;

float nailgren_type;
float lasergren_rotationcount;
float lasergren_rotationtime;
float lasergren_thinktime;
float lasergren_range;
float lasergren_damage;
float lasergren_reqthinks;
float lasergren_angleperthink;
float burstgren_count;
float burstgren_interval;
float burstgren_range;

float medic_type;
float blastgren_velocity_multiplier;

float old_grens;
float fo_flash;
float invis_only;
float flagem_checked;
float cease_fire;
float drop_grenades;
float drop_grenpack;
float drop_gren1;
float drop_gren2;
/*
float max_gren1_scout;
float max_gren1_sniper;
float max_gren1_soldier;
float max_gren1_demoman;
float max_gren1_medic;
float max_gren1_hwguy;
float max_gren1_pyro;
float max_gren1_spy;
float max_gren1_engineer;
float max_gren2_scout;
float max_gren2_sniper;
float max_gren2_soldier;
float max_gren2_demoman;
float max_gren2_medic;
float max_gren2_hwguy;
float max_gren2_pyro;
float max_gren2_spy;
float max_gren2_engineer;
*/
float max_active_gren2_soldier;
float grentimers;
float id_extended;
float remember_weapon;
float discammo_pickup;
float old_dropflag;
float reload_cliptick;
float old_sniperrange;
//float detpipe_limit;
float detpipe_limit_world;
float old_pipecooldown;
float medicaura;
float old_medikit;
float old_biodamage;
float flame_knockback;
float build_water;
float cannon_lock;
float cannon_air;
float cannon_move;
float cannon_movespin;
float cannon_conc;
float cannon_accuracy;
float fo_hwguy;
float feign_air;
float feign_pack;
float feign_msg;
float scoutdash;
float sniperreload;
float spawnfull;
float stockfull;
float stock_on_cap;
float stock_reload;
float classtips;
float cussgrentime;
float medicnocuss;
float sniperpower;
float sniperreloadpercent;
float buildstatus;
float server_default;
float server_faithful;
float server_huetf;

float old_spanner;
float old_dispenser;
float old_hp_armor;
float max_armor_hwguy;

float ng_velocity;
float ng_damage;
float sng_damage;
float old_ng_rof;
float impulse_queue;
float detpack_when_reloading;
float pyro_type;
float flag_follow;
float ceasefire_type;
float is_paused;
string pause_actor;
float unpause_requested;
float unpause_countdown;
float unpause_lastcountnumber;
float chweap_wait_attfinished;
float override_mapclasses;
float solid_detpack;
float walls_block_emp;
float new_emp;
float fo_sentry_targeting; // new improved targeting for sentry guns
float cb_keepteams;
float fo_flashtime;
float fo_repair_ratio;
float solid_nailgren;
float noreturn;
float nohitsounds;
float nokeepcells;
//float server_sbflaginfo;
float reverse_cap;
float engineer_move;

float numlocs;
typedef struct {vector pos; string desc;} loc_t;
loc_t *locs;

.float teamkills;

float autokick_time;
float autokick_kills;

.float vote;
.float bvote;
.float is_ready;

.float is_admin;
.float admin_mode;
.entity admin_use;
.string ip;

float deathmsg;                 // Global, which is set before every T_Damage, to indicate
                        // the death message that should be used.

float intermission_running;
float intermission_exittime;

// add clientkill ent defs
.float clientkillforce;
.float clientkillfree;

// ability for doors to close instantly if they have a wait and are blocked
.float forcecloseonblock;

// used to remember last spawn
.entity last_spawn_spot;
.float spawn_at_last_spawn_spot;

.float max_grenades_1;
.float max_grenades_2;

.entity chain2; // allows for nesting of findradius (use in EMPGrenadeExplode)

.entity vote_map_send;

// global variables for voting
float vote1_cnt, vote2_cnt, vote3_cnt, vote4_cnt, vote5_cnt;
string vote1_map, vote2_map, vote3_map, vote4_map, vote5_map, vote_result;
float vote_started, vote_update, vote_winnercount, vote_decider, vote_abort;

//============================================================================

void (float psize, entity p) KickPlayer = {
    msg_entity = p;
    if (psize > -3)
        WriteByte(MSG_ONE, SVC_SMALLKICK);
    else
        WriteByte(MSG_ONE, SVC_BIGKICK);
};

void () muzzleflash = {
    WriteByte(MSG_MULTICAST, SVC_MUZZLEFLASH);
    WriteEntity(MSG_MULTICAST, self);
    multicast(self.origin, MULTICAST_PVS);
};

string (string s, float width) strpadl =
{
    local float i;

    for (i = strlen(s); i < width; i++)
        s = strcat(" ", s);

    return s;
};

string (string s, float width) strpadr =
{
    local float i;

    for (i = strlen(s); i < width; i++)
        s = strcat(s, " ");

    return s;
};

float captainmode;
.float captain;

//Player ID
float loginRequired;
string loginUrl;
string webpageUrl;
.string login;
.float login_in_progress;

//Logging fields
float gametime;
string gametimestamp;
float logfilehandle;
float canlog;
.string grenadename;
.float classtime;
.float goalrunningtime;

// csqc scoreboard fields
.float caps;
.float touches;
.float kills;
.float sbteamkills;
.float deaths;
.float afflicted;
.float teamafflicted;
.float damagegiven;
.float damagetaken;

// flash stuff
float FO_FlashDimension;

// allow for default goal state
.float default_group_no;

.string broadcast_high;

.float special_cooldown;
.float airblast_cooldown;

// lag compensation
float fte_lc_asscann;
float fte_lc_pipebombs;
float fte_lc_tranq;
float fte_lc_railgun;
float fte_lc_nailgun;
float fte_lc_nailgun_experimental_inflictor;
float fte_lc_rockets;
float fte_lc_grenades;
float fte_lc_normal_grenades;



