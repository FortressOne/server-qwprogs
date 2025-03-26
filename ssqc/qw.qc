#include "../share/defs.h"

void (entity Goal, entity AP, entity ActivatingGoal) AttemptToActivate;
typedef void (float n) f_void_float;

enum {
    CT_NOEXTERNALEFFECT,  // No external effects (e.g. reload, build, prime, etc)
    CT_SLOW_PROJECTILE,   // Slow proj => more judder (e.g. rocket)
    CT_FAST_PROJECTILE,   // Fast proj => less judder (e.g. heavy bullet)
};

.float last_death_ctime;
.float last_attack_ctime;

.float client_time;              // A stable/predictable client clock
.float client_ping;              // ping used for prediction
.float last_remote_client_time;  // For monoticity
.float client_lastupdate;

.void() client_think;            // client-time relative think
.float client_thinkindex;
.float client_nextthink;

.int prng_base[PRNG_NUM_STATES];

// A monotonically non-decreasing, latency corrected notion of remote
// client-time.  Monotonicity guarantees that for some offset `o`:
//     at t1: remote_client_time() + o < at t2: lag_time() + o  FOR t2 > t1
// E.g. That you never have to worry about the correction reordering events
// that `time + o` would not.
float remote_client_time();

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
.float primed_gren_type;        // Type of (last) primed grenate
.float primed_gren_exp;         // Expiry of (last) primed grenade
.float no_grenades_1;           // Number of grenades of type 1 being carried
.float no_grenades_2;           // Number of grenades of type 2 being carried
.float hook_out;                // Dummy field for hook to silence error messages
.float cheat_check;             // Time when we'll next check for team cheats
.float is_removed;              // TRUE if the entity has been removed
.float is_undercover;           // TRUE for a SPY if they're undercover
.float is_building;             // BUILD_DISPENSER, BUILD_SENTRYGUN or FALSE for an ENGINEER
.float is_detpacking;           // TRUE for a DEMOMAN if they're setting a detpack
.float is_button_feigning;      // TRUE for a SPY if they're feigning death with +feign or +special
.float feign_next_damage;       // TRUE for a SPY if they're going to feign death on next damage
.float is_unabletospy;          // TRUE for a SPY if they can't go undercover
.float has_throwngren;          // TRUE for a player that has thrown a grenade (won't get a free suicide)
.float has_changedteam;         // TRUE for a player that has changed team
.float has_changedclass;        // TRUE for a player that has changed class
.float has_disconnected;        // TRUE if the player has disconnected
.float has_menutimer;           // TRUE if the player has an active menu timer
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
.float detpipe_nesting;         // Used to avoid recursive detpipes when detting self
.float disguise_skin;           // The skin the spy is changing to
.float queue_skin;              // The skin the spy will change to after team disguise is finished
.float last_selected_skin;      // The last skin the spy selected to disguise as
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
.float undercover_timer;        // Seconds left until disguised
.float power_time;              // The time when sniper power in status bar was last updated
.float sentry_ticks;            // Used to indicate when engineer's sentry gun is finished building
.float dispenser_ticks;         // Used to indicate when engineer's dispenser is finished building
.float building_percentage;     // The building percentage shown in status bar
.float fragstreak;              // Frag streak
.float caps;                    // Caps during this game
.float needs_skin_update;       // Set true when per-player skins need updating

.entity nopickup;               // Don't pick up this backpack/ammobox because it doesn't contain any of your ammo types
.entity disguised_as;           // Used when cycling through disguises

.float pstate;                  // Player state flags
.float tfstate;                 // State flags for TeamFortress
.float last_tfstate;             // Internal cache of tfstate for detecting updates
.entity linked_list;            // Used just like chain. Has to be separate so
                                // it doesn't interfere with chain. See T_RadiusScan

.entity observer_list;          // Used by undefined classes, see TF_MovePlayer

// Identify variables
.string ident_string;           // Status bar string for identify
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
.float csqc_maxspeed;

.float is_disarming;
.float motd;                    // Used to display MOTD
.float current_menu;
.float current_menu_type;
.float current_menu_page;
.float menu_count;
.float menu_displaytime;
.f_void_float menu_input;

.float has_flag;

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

float team_no_attack;
.float team_no;                 // The team you belong to
.float all_time;                // Automatically join attacking/defending team during quads
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
.entity sentry_ent;		// Contains sentry gun entity

.float real_frags;              // Used to store the players frags when TeamFrags is On

.float respawn_time;            // players can't respawn within this time.
.float suicide_time;            // players can't suicide within this time.

/*==============================================*/
/* New Weapon variables				*/
/*==============================================*/
.Slot current_slot;            // the currently equipped (weapon) slot
.Slot last_slot;               // the last slot the player was using
.Slot queue_slot;              // the slot to switch to when possible

.float ammo_medikit;            // Ammo used for the medikit
.float maxammo_medikit;
.float ammo_detpack;            // Ammo used for the detpack
.float maxammo_detpack;
.float noammo;                  // used for no ammo error messages

// variables used for reloading
.float reload_started;          // when the reload started
.float reload_finished;         // when the reload will finish

// Only use below for map ent compatibility.
.float reload_shotgun;
.float reload_super_shotgun;
.float reload_sniper_rifle;
.float reload_grenade_launcher;
.float reload_rocket_launcher;
.float reload_assault_cannon;
// Only use above for map ent compatibility.

.float clip_fired[TF_NUM_SLOTS];

// Assault Cannon
.float heat;

// Dispenser
.float deff;                    // Dispenser efficiency
.float dimmune;                 // Immune to dispenser stocking
.float duse;                    // Time of last dispenser usage

// Team Color Cheat Checking
.float immune_to_check;

// Make sure people don't do too many saveme sounds
.float next_saveme_sound;

.float no_active_nail_grens;

/*======================================================================*/
/* TEAMFORTRESS GOALS							*/
/*======================================================================*/
// Variables used in the Goals
.float goal_no;                 // Goal number of this goal
.float group_no;                // Goal group this goal is in
.float goal_state;              // State of this goal
.float owned_by;                // The team this goal/item/whatever belongs to
.float dropped_at;              // Time when item was dropped
.entity dropped_by;             // Entity that last held item

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
.float next_feign_time;         // timestamp for when feign is next allowed

float live_camera;
.float camdist;
.vector camangle;
.entity camera_list;

float already_chosen_map;

.float disptimer;
.float hit_in_current_animation; // Set on knife attack if a hit is recorded to prevent combo hits

// sniper location damage stuff
.vector head_shot_vector;
.float leg_damage;

.float cheat_level;

// flash grenade level
.float FlashTime;

// anti spam
.float antispam_detpack;        // don't spam detpack messages
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
float disable_voting;
float org_game;
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
float round_start_time;
float round_end_time;
float map_restart_time;
float play_to_completion;
float gametime;
float is_countdown;
float duelmode;
float duel_reset_delay;
float duel_reset_timer;
float no_fire_mode;
float duel_all_grens;
float duel_no_packs;
float duel_spawn_guard;
.entity duel_guarded;
float duel_allow_draw;
float duel_tie_break;
float duel_draw_countdown;
float duel_autoprime;
float votemode;
float voting_started;
float voting_expires;
.entity vote_map;
float vote_anarchy_mode;
float vote_total_votes;
float vote_style;
float vote_threshold;
string game_filename;

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
float max_active_gren2_soldier;
float id_extended;
float remember_weapon;
float discammo_pickup;
float old_dropflag;
float old_sniperrange;
//float detpipe_limit;
float detpipe_limit_world;
float pipecooldown_time;
float allpipes_cooldown;
float medicaura;
float old_biodamage;
float flame_knockback;
float build_water;
float cannon_lock;
float cannon_air;
float cannon_move;
float cannon_movespin;
float cannon_accuracy;
float feign_air;
float feign_pack;
float feign_msg;
float feign_rate_limit;
float scoutdash;
float spawnfull;
float stockfull;
float stock_on_cap;
float cap_strip;
float stock_reload;
float classtips;
float cussgrentime;
float medicnocuss;
float distance_based_cuss_duration;
float sniperpower;
float buildstatus;
float server_default;
float server_faithful;
float server_huetf;
float scoutscanspike;
float asscanrange;
float asscanrangedie;
float force_reload;

float old_spanner;
float old_dispenser;
float old_hp_armor;
float max_armor_hwguy;

float ng_damage;
float sng_damage;
float superaxe;
float supermedikit;
float superspanner;
float superknife;
float superknife_multihit;
float impulse_queue;
float detpack_when_reloading;
float flag_follow;
float ceasefire_type;
float cs_paused;
float is_paused;
string pause_actor;
float unpause_requested;
float unpause_countdown;
float unpause_lastcountnumber;
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
float nohittext;
float zutmode;						  
float nokeepcells;
float allowpracspawns;
string discord_channel_id;
string demo_files_address;
string stats_files_address;
float splitbackpackmodels;
float standardizedeathammo;
float deathammo_shells;
float deathammo_nails;
float deathammo_rockets;
float deathammo_cells;
//float server_sbflaginfo;
float reverse_cap;
float engineer_move;
float grenade_lockout;

float fo_projectiles;

float fo_concuss;

float numlocs;
typedef struct {vector pos; string desc;} loc_t;
loc_t *locs;

.float teamkills;

float autokick_time;
float autokick_kills;

.float vote;
.float bvote;
.float stat_flags;

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

.float spawn_gen;

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

// fortressone.org API
.string fo_login;

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
.float old_dimension_seen;

// precise grenades
.entity grenade_timer;
.float last_throw;
.float last_prime;
.float conc_amp;
.float conc_finished;

// allow for default goal state
.float default_group_no;
// classes to search for in goal remove, restore etc
string goal_class_names[7] = {
    "info_tfgoal",
    "trigger_teleport",
    "door",
    "func_wall",
    "fo_misc_info",
    "fo_logic",
    "fo_math",
};

.string broadcast_high;

.float special_next;
.float airblast_cooldown;
float disable_resup_gren;

// backend
string match_id;
string backend_address;
float fo_login_required;
.entity filter_ent;

var float PC_PYRO_AIRBLAST_COOLDOWN = 5;
var float PC_ENGINEER_GRENADE_TYPE_2_RANGE = 240;
.float detpack_last;
