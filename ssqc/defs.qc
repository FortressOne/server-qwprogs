//================================================
// Global variables
//================================================

//
// system globals
//
entity self;
entity other;
entity world;

float time;
noref float frametime;
entity newmis;                  // if this is set, the entity that just
                        // run created a new missile that should
                        // be simulated immediately
float force_retouch;            // force all entities to touch triggers
                                // next frame.  this is needed because
                                // non-moving things don't normally scan
                                // for triggers, and when a trigger is
                                // created (like a teleport trigger), it
                                // needs to catch everything.
                                // decremented each frame, so set to 2
                                // to guarantee everything is touched
string mapname;

float serverflags;              // propagated from level to level, used to
                        // keep track of completed episodes
float total_secrets;
float total_monsters;
float found_secrets;
float killed_monsters;

// spawnparms are used to encode information about clients across server level changes
noref float parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9,
    parm10, parm11, parm12, parm13, parm14, parm15, parm16;

//
// global variables set by built in functions
//      
vector v_forward, v_up, v_right;        // set by makevectors()

// set by traceline / tracebox
noref float trace_allsolid;
noref float trace_startsolid;
float trace_fraction;
vector trace_endpos;
vector trace_plane_normal;
noref float trace_plane_dist;
entity trace_ent;
float trace_inopen;
float trace_inwater;

entity msg_entity;              // destination of single entity writes

// required prog functions
void () main;
void () StartFrame;

void () PlayerPreThink;         // Called every frame before physics are run
void () PlayerPostThink;        // Called every frame after physics are run

void () ClientKill;             // Player entered the suicide command
//void () ClientConnect;          // called when a player connects to a server
void () PutClientInServer;      // call after setting the parm1... parms
void () ClientDisconnect;       // called when a player disconnects from a server

void () SetNewParms;            // called when a client first connects to
                                // a server. sets parms so they can be
                                // saved off for restarts

void () SetChangeParms;         // call to set parms for self so they can
                                // be saved for a level transition

void end_sys_globals;

//================================================
// Entity fields
//================================================

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float modelindex;              // *** model index in the precached list
.vector absmin, absmax;         // *** origin + mins / maxs

.float ltime;                   // local time for entity
.float lastruntime;             // *** to allow entities to run out of sequence

.float movetype;
.float solid;

.vector origin;
.vector oldorigin;
.vector velocity;
.vector angles;
.vector avelocity;

.string classname;              // spawn function
.string model;
.float frame;
.float skin;
.float effects;

.vector mins, maxs;             // bounding box extents reletive to origin
.vector size;                   // maxs - mins

.void () touch;
.void () use;
.void () think;
.void () blocked;               // for doors or plats, called when can't push other

.float nextthink;
.entity groundentity;

// stats
.float health;
.float frags;
.float weapon;
.string weaponmodel;
.float weaponframe;
.float ammo_shells, ammo_nails, ammo_rockets, ammo_cells;

.float items;

.float takedamage;
.entity chain;
.float deadflag;

.vector view_ofs;               // add to origin to get eye point

.float button0;                 // fire
.float button1;                 // use 
.float button2;                 // jump

.float impulse;

.float fixangle;
.vector v_angle;                // view / targeting angle for players

.string netname;
.entity enemy;
.float flags;

.float colormap;
.float team;

.float max_health;              // players maximum health is stored here
.float teleport_time;

.float armortype;               // save this fraction of incoming damage
.float armorvalue;

.float waterlevel;              // 0 = not in, 1 = feet, 2 = wast, 3 = eyes
.float watertype;               // a contents value

.float ideal_yaw;
.float yaw_speed;

.entity aiment;
.entity goalentity;             // a movetarget or an enemy
.float spawnflags;

.string target;
.string targetname;
.string targetsequence;
.float lasttarget;

// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float dmg_take;
.float dmg_save;
.entity dmg_inflictor;

.entity owner;                  // who launched a missile
.vector movedir;                // mostly for doors, but also used for waterjump

.string message;                // trigger messages
.float sounds;                  // either a cd track number or sound number
.string noise, noise1, noise2, noise3;  // contains names of wavs to play

void end_sys_fields;

//================================================
// globals
//

string string_null;             // null string, nothing should be held here

entity activator;               // the entity that activated a trigger or brush

entity damage_attacker;         // set by T_Damage

// cvars checked each frame
float skill;
float teamplay;
float timelimit;
float fraglimit;
float deathmatch;
float rj;

//================================================
// world fields (FIXME: make globals)
//
.string wad;
.string map;
.float worldtype;               // 0=medieval 1=metal 2=base
//================================================

.string killtarget;

// quakeed fields
.float light_lev;
.float style;

// monster ai
.void () th_stand;
.void () th_walk;
.void () th_run;
.void () th_missile;
.void () th_melee;
.void (entity attacker, float damage) th_pain;
.void () th_die;

.entity oldenemy;               // mad at this player before taking damage

.float speed;
.float lefty;
.float search_time;
.float attack_state;

// player only fields
.float voided;
.float walkframe;

// Zoid Additions
.float maxspeed;                // Used to set Maxspeed on a player
.float gravity;                 // Gravity Multiplier (0 to 1.0)

.float attack_finished;
.float pain_finished;

.float invincible_finished;
.float invisible_finished;
.float super_damage_finished;
.float radsuit_finished;

.float invincible_time, invincible_sound;
.float invisible_time, invisible_sound;
.float super_time, super_sound;
.float rad_time;
.float fly_sound;

.float axhitme;

.float show_hostile;            // set to time+0.2 whenever a client fires a
                        // weapon or takes damage.  Used to alert
                        // monsters that otherwise would let the player go

.float jump_flag;               // player jump flag
.float swim_flag;               // player swimming sound flag
.float air_finished;            // when time > air_finished, start drowning
.float bubble_count;            // keeps track of the number of bubbles
.string deathtype;              // keeps track of how the player died

// object stuff
.string mdl;
.vector mangle;                 // angle at start

.float t_length, t_width;

// doors, etc
.vector dest, dest1, dest2;
.float wait;                    // time from firing to restarting
.float delay;                   // time from activation to firing
.entity trigger_field;          // door's trigger entity
.string noise4;

// monsters
.float pausetime;
.entity movetarget;

// doors
.float aflag;
.float dmg;                     // damage done by door when hit

// misc flag
.float cnt;
.float cnt2;

// subs
.void () think1;
.vector finaldest, finalangle;

// triggers
.float count;                   // for counting triggers

// plats / doors / buttons
.float lip;
.float state;
.vector pos1, pos2;
.float height;

// sounds
.float waitmin, waitmax;
.float distance;
.float volume;

//===========================================================================
// builtin functions
//

float() argc = #85; // returns number of tokens
string(float num) argv_mvdsv = #86; // returns token for the given number

//In order to make it more useful, this header includes a timeofday function which just grabs the values for you to use in your qc code straight after calling calltimeofday.
string tod_sec, tod_min, tod_hour, tod_day, tod_mon, tod_year;

//This function is to facilitate use, and need not be modified.
string zeropad(float val)
{
    return (val < 10 ? strcat("0", ftos(val)) : ftos(val));
}

void(float s, float mi, float h, float d, float mo, float y, string tmp_timeofday) timeofday =
{ tod_sec = zeropad(s); tod_min = zeropad(mi); tod_hour = zeropad(h); tod_day = zeropad(d); tod_mon = zeropad((mo + 1)); tod_year = zeropad(y); };

//============================================================================

//
// subs.qc
//
void (vector tdest, float tspeed, void ()func) SUB_CalcMove;
void (entity ent, vector tdest, float tspeed, void ()func) SUB_CalcMoveEnt;
void (vector destangle, float tspeed, void ()func) SUB_CalcAngleMove;
void () SUB_CalcMoveDone;
void () SUB_CalcAngleMoveDone;
void () SUB_Null;
void (entity et, float f) SUB_Null_pain;
void () SUB_UseTargets;
void () SUB_Remove;

//
// combat.qc
//
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
float (entity e, float healamount, float ignore) T_Heal;        // health function
float (entity targ, entity inflictor) CanDamage;

// enable qw in fteextensions
#define QUAKEWORLD
