//============================================================================
//			VARS NOT REFERENCED BY C CODE
//============================================================================

#ifndef VER
#define VER "unknown"
#endif

#ifndef REV
#define REV "unk"
#endif

//
// constants
//

#define FALSE		0
#define TRUE		1

// edict.flags
#define FL_FLY		1
#define FL_SWIM		2
#define FL_CLIENT	8 	// set for all client edicts
#define FL_INWATER	16 	// for enter / leave water splash
#define FL_MONSTER	32
#define FL_GODMODE	64 	// player cheat
#define FL_NOTARGET	128 	// player cheat
#define FL_ITEM		256 	// extra wide size for bonus items
#define FL_ONGROUND	512 	// standing on something
#define FL_PARTIALGROUND	1024 	// not all corners are valid
#define FL_WATERJUMP	2048 	// player jumping out of water

#define FL_JUMPRELEASED	4096 	// for jump debouncing

// edict.movetype values
#define MOVETYPE_NONE			0 	// never moves
//#define MOVETYPE_ANGLENOCLIP	1
//#define MOVETYPE_ANGLECLIP	2
#define MOVETYPE_WALK			3 	// players only
#define MOVETYPE_STEP			4 	// discrete, not real time unless fall
#define MOVETYPE_FLY			5
#define MOVETYPE_TOSS			6 	// gravity
#define MOVETYPE_PUSH			7 	// no clip to world, push and crush
#define MOVETYPE_NOCLIP			8
#define MOVETYPE_FLYMISSILE		9 	// fly with extra size against monsters
#define MOVETYPE_BOUNCE			10
#define MOVETYPE_BOUNCEMISSILE		11 	// bounce with extra size

// edict.solid values
#define SOLID_NOT	0 	// no interaction with other objects
#define SOLID_TRIGGER	1 	// touch on edge, but not blocking
#define SOLID_BBOX	2 	// touch on edge, block
#define SOLID_SLIDEBOX	3 	// touch on edge, but not an onground
#define SOLID_BSP	4 	// bsp clip, touch on edge, block

// range values
#define RANGE_MELEE	0
#define RANGE_NEAR	1
#define RANGE_MID	2
#define RANGE_FAR	3

// deadflag values
#define DEAD_NO			0
#define DEAD_DYING		1
#define DEAD_DEAD		2
#define DEAD_RESPAWNABLE	3

// takedamage values
#define DAMAGE_NO	0
#define DAMAGE_YES	1
#define DAMAGE_AIM	2

// items
#define IT_AXE			4096
#define IT_SHOTGUN		1
#define IT_SUPER_SHOTGUN	2
#define IT_NAILGUN		4
#define IT_SUPER_NAILGUN	8
#define IT_GRENADE_LAUNCHER	16
#define IT_ROCKET_LAUNCHER	32
#define IT_LIGHTNING		64
#define IT_EXTRA_WEAPON		128

#define IT_SHELLS	256
#define IT_NAILS	512
#define IT_ROCKETS	1024
#define IT_CELLS	2048

#define IT_ARMOR1	8192
#define IT_ARMOR2	16384
#define IT_ARMOR3	32768
#define IT_SUPERHEALTH	65536

#define IT_KEY1	131072
#define IT_KEY2	262144

#define IT_INVISIBILITY		524288
#define IT_INVULNERABILITY	1048576
#define IT_SUIT			2097152
#define IT_QUAD			4194304
#define IT_HOOK			8388608

// point content values
#define CONTENT_EMPTY	-1
#define CONTENT_SOLID	-2
#define CONTENT_WATER	-3
#define CONTENT_SLIME	-4
#define CONTENT_LAVA	-5
#define CONTENT_SKY	-6

#define STATE_TOP	0
#define STATE_BOTTOM	1
#define STATE_UP	2
#define STATE_DOWN	3

// q3 states
#define STATE_NONE		0
#define STATE_DISABLED	4
#define STATE_INACTIVE	5
#define	STATE_ACTIVE	6
#define STATE_INVISIBLE	7

#define VEC_ORIGIN	'0 0 0'
#define VEC_HULL_MIN	'-16 -16 -24'
#define VEC_HULL_MAX	'16 16 32'

#define VEC_HULL2_MIN	'-32 -32 -24'
#define VEC_HULL2_MAX	'32 32 64'

// protocol bytes
#define SVC_TEMPENTITY		23
#define SVC_KILLEDMONSTER	27
#define SVC_FOUNDSECRET		28
#define SVC_INTERMISSION	30
#define SVC_FINALE		31
#define SVC_CDTRACK		32
#define SVC_SELLSCREEN		33

#define SVC_SMALLKICK		34
#define SVC_BIGKICK		35
#define SVC_UPDATEPING		36
#define SVC_UPDATETIME		37
#define SVC_MUZZLEFLASH		39
#define SVC_UPDATEUSERINFO	40
#define SVC_PLAYERINFO		42
#define SVC_PACKETENTITIES	47
#define SVC_DELTAPACKETENTITIES	48
#define SVC_SETINFO		51
#define SVC_UPDATEPL		53

#define TE_SPIKE		0
#define TE_SUPERSPIKE		1
#define TE_GUNSHOT		2
#define TE_EXPLOSION		3
#define TE_TAREXPLOSION		4
#define TE_LIGHTNING1		5
#define TE_LIGHTNING2		6
#define TE_WIZSPIKE		7
#define TE_KNIGHTSPIKE		8
#define TE_LIGHTNING3		9
#define TE_LAVASPLASH		10
#define TE_TELEPORT		11
#define TE_BLOOD        	12
#define TE_LIGHTNINGBLOOD	13

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel

#define CHAN_AUTO	0
#define CHAN_WEAPON	1
#define CHAN_VOICE	2
#define CHAN_ITEM	3
#define CHAN_BODY	4
#define CHAN_GREN_START 5
#define CHAN_GREN_END 7
#define CHAN_NO_PHS_ADD	8
#define NUM_GREN_TIMERS 5 // We overlap channels when >3 active.

#define ATTN_NONE	0
#define ATTN_NORM	1
#define ATTN_IDLE	2
#define ATTN_STATIC	3

// update types

#define UPDATE_GENERAL	0
#define UPDATE_STATIC	1
#define UPDATE_BINARY	2
#define UPDATE_TEMP	3

// entity effects
#define EF_BRIGHTFIELD	1
#define EF_MUZZLEFLASH	2
#define EF_BRIGHTLIGHT	4
#define EF_DIMLIGHT	8
#define EF_FLAG1	16
#define EF_FLAG2	32
// GLQuakeWorld Stuff
#define EF_BLUE		64	// Blue Globe effect for Quad
#define EF_RED		128	// Red Globe effect for Pentagram

// messages
#define MSG_BROADCAST	0		// unreliable to all
#define MSG_ONE		1 		// reliable to one (msg_entity)
#define MSG_ALL		2 		// reliable to all
#define MSG_INIT	3 		// write to the init string
#define MSG_MULTICAST   4

// message levels
#define	PRINT_LOW	0		// pickup messages
#define	PRINT_MEDIUM	1		// death messages
#define	PRINT_HIGH	2		// critical messages
#define PRINT_CHAT	3		// also goes to chat console

// multicast sets
#define MULTICAST_ALL	0    	// every client
#define MULTICAST_PHS	1    	// within hearing
#define MULTICAST_PVS	2    	// within sight
#define MULTICAST_ALL_R	3    	// every client, reliable
#define MULTICAST_PHS_R	4    	// within hearing, reliable
#define MULTICAST_PVS_R	5  	// within sight, reliable

// attack_state
#define AS_STRAIGHT	1
#define AS_SLIDING	2
#define AS_MELEE	3
#define AS_MISSILE	4

// stat_flags
#define PLAYER_READY     1
#define ENEMY_TEAM_READY 2
#define LAST_NOT_READY   4
#define CEASEFIRE        8

//===========================================================================
// TEAMFORTRESS Defs
//===========================================================================

// TeamFortress State Flags
#define TFSTATE_GRENPRIMED		1   // Whether the player has a primed grenade
#define TFSTATE_RELOADING		2   // Whether the player is reloading
#define TFSTATE_ALTKILL			4   // TRUE if killed with a weapon not in self.weapon: NOT USED ANYMORE
#define TFSTATE_RANDOMPC		8   // Whether Playerclass is random, new one each respawn
#define TFSTATE_INFECTED		16  // set when player is infected by the bioweapon
#define TFSTATE_INVINCIBLE		32  // Player has permanent Invincibility (Usually by GoalItem)
#define TFSTATE_INVISIBLE		64  // Player has permanent Invisibility (Usually by GoalItem)
#define TFSTATE_QUAD			128 // Player has permanent Quad Damage (Usually by GoalItem)
#define TFSTATE_RADSUIT			256 // Player has permanent Radsuit (Usually by GoalItem)
#define TFSTATE_BURNING			512 // Is on fire
#define TFSTATE_GRENTHROWING		1024  // is throwing a grenade
#define TFSTATE_AIMING			2048  // is using the laser sight
#define TFSTATE_LOCK            4096 // this state will stop hwguy from shooting assault cannon
#define TFSTATE_RESPAWN_READY		8192  // is waiting for respawn, and has pressed fire, as sentry gun, indicate it needs to die
#define TFSTATE_HALLUCINATING		16384  // set when player is hallucinating
#define TFSTATE_TRANQUILISED 		32768  // set when player is tranquilised
#define TFSTATE_CANT_MOVE		65536  // set when player is setting a detpack
// FIXME - concussion and flash states aren't set or tested...
#define TFSTATE_FLAMES_MAX		131072
#define TFSTATE_FLASHED			262144
#define TFSTATE_CONCUSSED		524288

// Defines used by TF_T_Damage (see combat.qc)
#define TF_TD_IGNOREARMOR	1  // Bypasses the armor of the target
#define TF_TD_NOTTEAM		2  // Doesn't damage a team member (indicates direct fire weapon)
#define TF_TD_NOTSELF		4  // Doesn't damage self

#define TF_TD_OTHER		0  // Ignore armorclass
#define TF_TD_SHOT		1  // Bullet damage
#define TF_TD_NAIL		2  // Nail damage
#define TF_TD_EXPLOSION		4  // Explosion damage
#define TF_TD_ELECTRICITY	8  // Electric damage
#define TF_TD_FIRE		16  // Fire damage
#define TF_TD_NOSOUND		256 // Special damage. Makes no sound/painframe, etc
#define TF_TD_NOMOMENTUM	512	// Special damage, don't change momentum

// Classic Fortress stuff
#define CF_MAPVOTE_FORCESHOW        10      // Seconds to force the mapvote menu to be open
#define CF_MAPVOTE_FINISH           5       // Seconds before timelimit to close all voting
#define CF_MAPVOTE_DURATION         180     // Seconds to show map vote menu
#define CF_MAPVOTE_DURATION_DECIDER 90      // Seconds to show map decider menu

// team play vals
#define TP_HALFDIRECT   128
#define TP_NODIRECT     256
#define TP_HALFAOE      512
#define TP_NOAOE        1024
#define TP_HALFMIRRORDIRECT 2048
#define TP_FULLMIRRORDIRECT 4096
#define TP_HALFMIRRORAOE    8192
#define TP_FULLMIRRORAOE    16384

/*======================================================*/
/* Toggleable Game Settings				*/
/*======================================================*/

// Some of the toggleflags aren't used anymore, but the bits are still
// there to provide compatability with old maps
#define TFLAG_CLASS_PERSIST	1  	// Persistent Classes Bit
#define TFLAG_CHEATCHECK	2 	// Cheatchecking Bit
#define TFLAG_RESPAWNDELAY	4 	// RespawnDelay bit
#define TFLAG_UN		8	// NOT USED ANYMORE
#define TFLAG_UN2		16	// NOT USED ANYMORE
#define TFLAG_UN3		32	// NOT USED ANYMORE
#define TFLAG_AUTOTEAM		64	// sets whether players are automatically placed in teams
#define TFLAG_TEAMFRAGS		128	// Individual Frags, or Frags = TeamScore
#define TFLAG_FIRSTENTRY	256	// Used to determine the first time toggleflags is set
					// in a map. Cannot be toggled by players.
// unused           		512
#define TFLAG_GRAPPLE		1024	// Grapple on/off
#define TFLAG_FULLTEAMSCORE	2048
#define TFLAG_FLAGEMU		4096
#define TFLAG_WARSTANDARD	8192

#define TF_RESPAWNDELAY1	5 	// seconds of waiting before player can respawn
#define TF_RESPAWNDELAY2	10 	// seconds of waiting before player can respawn
#define TF_RESPAWNDELAY3	20 	// seconds of waiting before player can respawn

#define TEAMPLAY_NORMAL		 1
#define TEAMPLAY_HALFDIRECT	 2
#define TEAMPLAY_NODIRECT	 4
#define TEAMPLAY_HALFEXPLOSIVE	 8
#define TEAMPLAY_NOEXPLOSIVE	 16
#define TEAMPLAY_LESSPLAYERSHELP 32
#define TEAMPLAY_LESSSCOREHELP	 64

// FortressMap stuff
#define TEAM1_CIVILIANS 1
#define TEAM2_CIVILIANS 2
#define TEAM3_CIVILIANS 4
#define TEAM4_CIVILIANS 8

// Defines for the playerclass
#define PC_UNDEFINED		0

#define PC_SCOUT		1
#define PC_SNIPER		2
#define PC_SOLDIER		3
#define PC_DEMOMAN		4
#define PC_MEDIC		5
#define PC_HVYWEAP		6
#define PC_PYRO			7
#define PC_SPY			8
#define PC_ENGINEER		9

// Insert new class definitions here

// PC_RANDOM _MUST_ be the third last class
#define PC_RANDOM		10 	// Random playerclass
#define PC_CIVILIAN		11	// Civilians are a special class. They cannot
					// be chosen by players, only enforced by maps
#define PC_LASTCLASS		12 	// Use this as the high-boundary for any loops
					// through the playerclass.

// admin menu page consts
#define ADMIN_MENU_TYPE_MAIN 0
#define ADMIN_MENU_TYPE_KICK 1
#define ADMIN_MENU_TYPE_BAN 2
#define ADMIN_MENU_TYPE_CAPTAINTEAMONE 3
#define ADMIN_MENU_TYPE_CAPTAINTEAMTWO 4
#define ADMIN_MENU_TYPE_CAPTAINSELECT 5
#define ADMIN_MENU_TYPE_QUADMODE 6
#define ADMIN_MENU_TYPE_QUAD_ROUNDNUM 7
#define ADMIN_MENU_TYPE_QUAD_ROUNDTL 8
#define ADMIN_MENU_TYPE_CLASSES 9
#define ADMIN_MENU_TYPE_FORCESPEC 10


/*======================================================*/
/* Impulse Defines                                      */
/*======================================================*/
#define TF_SLOT1                    1   // Changes weapon to slot 1 (primary weapon)
#define TF_SLOT2                    2   // Changes weapon to slot 2 (secondary weapon)
#define TF_SLOT3                    3   // Changes weapon to slot 3 (tertiary weapon)
#define TF_SLOT4                    4   // Changes weapon to slot 4 (melee weapon)
#define TF_CLASSMENU                5   // Brings up class menu
// unused                           6
// unused                           7
// unused                           8
// unused                           9
// unused                           10
#define TF_WEAPNEXT                 11  // Selects the next weapon slot
#define TF_WEAPPREV                 12  // Selects the previous weapon slot
#define TF_WEAPLAST                 13  // Selects the last used weapon slot
#define TF_GRENADE_1                14  // Prime grenade type 1
#define TF_GRENADE_2                15  // Prime grenade type 2
#define TF_GRENADE_T                16  // Throw primed grenade
#define TF_GRENADE_PT_1             17  // Prime and throw grenade type 1 (two clicks)
#define TF_GRENADE_PT_2             18  // Prime and throw grenade type 2 (two clicks)
#define TF_GRENADE_SWITCH           19  // Switch grenade mode 1/2
#define TF_QUICKSLOT1               20  // Fire weapon slot 1 and then switch back to current weapon
#define TF_QUICKSLOT2               21  // Fire weapon slot 2 and then switch back to current weapon
#define TF_QUICKSLOT3               22  // Fire weapon slot 3 and then switch back to current weapon
#define TF_QUICKSLOT4               23  // Fire weapon slot 4 and then switch back to current weapon
#define TF_QUICKSTOP                24  // Used to tell server that quick firing has stopped
#define TF_RELOAD_SLOT1             25  // Reload weapon slot 1
#define TF_RELOAD_SLOT2             26  // Reload weapon slot 2
#define TF_RELOAD_SLOT3             27  // Reload weapon slot 3
#define TF_RELOAD                   28  // Reload current weapon
#define TF_RELOAD_NEXT              29  // Reload next weapon with a non-full clip
#define TF_SPECIAL_SKILL            30  // Class special
#define TF_DROPFLAG                 31  // Drop flag
#define TF_DROPKEY                  32  // Drop key
#define TF_DISCARD                  33  // Discard useless ammo
#define TF_DROP_AMMO                34  // Drop an ammo box on the ground
#define TF_MEDIC_HELPME             35  // Alert players around you that you are in need of medical attention
#define TF_INVENTORY                36  // Displays current inventory
#define FLAG_INFO                   37  // Displays current flag location
#define TF_ID                       38  // Identify player/object in front of player
#define TF_ID_TEAM                  39  // Identify team player/object in front of player
#define TF_ID_ENEMY                 40  // Identify enemy player/object in front of player
#define TF_DASH                     41  // Scout: Initialize a forward bunnyhop
#define TF_SCAN                     42  // Scout: Toggle Scanner on/off
#define TF_SCAN_ENEMY               43  // Scout: Toggle scanning of enemies
#define TF_SCAN_FRIENDLY            44  // Scout: Toggle scanning of friendlies
#define TF_SCAN_SOUND               45  // Scout: Toggle scanner sound
#define TF_ZOOMTOGGLE               46  // Sniper: Toggle zoom mode on/off
#define TF_ZOOMIN                   47  // Sniper: Zoom in (while zoom mode is on)
#define TF_ZOOMOUT                  48  // Sniper: Zoom out (while zoom mode is on)
#define TF_DEMOMAN_DETPACK          49  // Demoman: Bring up detpack menu
#define TF_DETPACK                  50  // Demoman: Detpack Pre-Impulse
#define TF_DETPACK_STOP             51  // Demoman: Impulse to stop setting detpack
#define TF_DETPACK_5                52  // Demoman: Detpack set to 5 seconds
#define TF_DETPACK_20               53  // Demoman: Detpack set to 20 seconds
#define TF_DETPACK_50               54  // Demoman: Detpack set to 50 seconds
#define TF_PB_DETONATE              55  // Demoman: Detonate Pipebombs
#define TF_MEDIC_AURA_TOGGLE        56  // Medic: Toggle Healing Aura on/off
#define TF_HVYWEAP_LOCK_TOGGLE      57  // Medic: Toggle Healing Aura on/off
#define TF_LOCKON                   58  // HWGuy: Turn Assault Cannon fire on
#define TF_LOCKOFF                  59  // HWGuy: Turn Assault Cannon fire off
#define TF_AIRBLAST                 60  // Pyro: Air blast
#define TF_SPY_DIE                  61  // Spy: Feign death
#define TF_SPY_DIE_ON               62  // Spy: Feign death next damage
#define TF_SPY_DIE_OFF              63  // Spy: Unfeign
#define TF_SPY_SILENT_DIE           64  // Spy: Silent feign death
#define TF_SPY_SPY                  65  // Spy: Bring up disguise menu
#define TF_DISGUISE_ENEMY           66  // Spy: Disguise as enemy team
#define TF_DISGUISE_LAST            67  // Spy: Use last disguise
#define TF_DISGUISE_RESET           68  // Spy: Reset disguise
#define TF_DISGUISE_SCOUT           69  // Spy: Disguise as Scout
#define TF_DISGUISE_SNIPER          70  // Spy: Disguise as Sniper
#define TF_DISGUISE_SOLDIER         71  // Spy: Disguise as Soldier
#define TF_DISGUISE_DEMOMAN         72  // Spy: Disguise as Demoman
#define TF_DISGUISE_MEDIC           73  // Spy: Disguise as Medic
#define TF_DISGUISE_HWGUY           74  // Spy: Disguise as HWGuy
#define TF_DISGUISE_PYRO            75  // Spy: Disguise as Pyro
#define TF_DISGUISE_ENGINEER        76  // Spy: Disguise as Engineer
#define TF_DISGUISE_BLUE            77  // Spy: Disguise as blue team
#define TF_DISGUISE_RED             78  // Spy: Disguise as red team
#define TF_DISGUISE_YELLOW          79  // Spy: Disguise as yellow team
#define TF_DISGUISE_GREEN           80  // Spy: Disguise as green team
#define TF_ENGINEER_BUILD           81  // Engineer: Bring up build menu for Engineer
#define TF_ENGINEER_DETDISP         82  // Engineer: Detonate dispenser for Engineer
#define TF_ENGINEER_DETSENTRY       83  // Engineer: Detonate sentry gun for Engineer
#define TF_DISCARD_DROP_AMMO        84
#define TF_PRACSPAWN_PLACE          85
#define TF_PRACSPAWN_REMOVE         86
#define TF_DISGUISE_LAST_SPAWNED    87  // Spy: Disguise as last enemy to spawn
#define TF_SPECIAL_SKILL_2          88  // Class special 2
#define TF_ENGINEER_TOGGLESENTRY    89  // Engineer: Build or detonate sentry
#define TF_ENGINEER_TOGGLEDISPENSER 90  // Engineer: Build or detonate dispenser
// unused                           91
// unused                           92
// unused                           93
// unused                           94
// unused                           95
// unused                           96
// unused                           97
// unused                           98
// unused                           99
// unused                           100
#define TF_CHANGETEAM               101 // Bring up team selection menu
#define TF_TEAM_1                   102 // Join team 1
#define TF_TEAM_2                   103 // Join team 2
#define TF_TEAM_3                   104 // Join team 3
#define TF_TEAM_4                   105 // Join team 4
#define TF_DISPLAYLOCATION          106 // Displays current location and angles (for developers)
#define TF_SHOWTF                   107 // Displays server settings and mod version
#define TF_SHOWLEGALCLASSES         108 // Show what classes are allowed by current map
#define TF_SHOW_IDS                 109 // Show ids of connected players
#define TF_ALIAS_CHECK              110 // Check if client has gotten all the aliases
#define TF_CHANGECLASS              111 // Bring up class selection menu
#define TF_CHANGEPC_SCOUT           112 // Change class to Scout
#define TF_CHANGEPC_SNIPER          113 // Change class to Sniper
#define TF_CHANGEPC_SOLDIER         114 // Change class to Soldier
#define TF_CHANGEPC_DEMOMAN         115 // Change class to Demoman
#define TF_CHANGEPC_MEDIC           116 // Change class to Medic
#define TF_CHANGEPC_HVYWEAP         117 // Change class to HWGuy
#define TF_CHANGEPC_PYRO            118 // Change class to Pyro
#define TF_CHANGEPC_SPY             119 // Change class to Spy
#define TF_CHANGEPC_ENGINEER        120 // Change class to Engineer
#define TF_CHANGEPC_RANDOM          121 // Change class to RandomPC
#define TF_HELP_MAP                 122 // Displays current map objectives
#define TF_CLASSHELP                123 // Class help alias
#define TF_TEAM_CLASSES             124 // Display team classes
#define TF_TEAM_LIST                125 // Display the players in each team
#define TF_TEAM_SCORES              126 // Display team scores
#define TF_STATUS_QUERY             127 // Displays current team balance and equilization ratios
#define TF_NEXTTIP                  128 // Shows the next general/class tip
// unused                           129
// unused                           130
#define TF_TOGGLEVOTE               131 // Toggle vote menu on/off
#define TF_VOTENEXT                 132 // Vote to start voting for next map
#define TF_VOTETRICK                133 // Vote to start voting for a trick map
#define TF_VOTERACE                 134 // Vote to start voting for a race map
#define TF_FORCENEXT                135 // Vote to force a change to voted map
#define TF_PLAYER_READY             136
#define TF_PLAYER_NOT_READY         137
#define TF_ADMIN_FORCESTARTMATCH    138
#define TF_ADMIN_READYSTATUS        139
// unused                           140
#define TF_NAILGREN_INFO            141
// unused                           142
// unused                           143
// unused                           144
// unused                           145
// unused                           146
// unused                           147
// unused                           148
// unused                           149
// unused                           150
// unused                           151
// unused                           152
// unused                           153
// unused                           154
// unused                           155
// unused                           156
// unused                           157
// unused                           158
// unused                           159
// unused                           160
// unused                           161
// unused                           162
// unused                           163
// unused                           164
// unused                           165
// unused                           166
// unused                           167
// unused                           168
// unused                           169
// unused                           170
// unused                           171
// unused                           172
// unused                           173
// unused                           174
// unused                           175
// unused                           176
// unused                           177
// unused                           178
// unused                           179
// unused                           180
// unused                           181
// unused                           182
// unused                           183
// unused                           184
// unused                           185
// unused                           186
// unused                           187
// unused                           188
// unused                           189
#define TF_ADMIN_CYCLEDEAL          190
#define TF_ADMIN_KICK               191
#define TF_ADMIN_BAN                192
#define TF_ADMIN_COUNTPLAYERS       193
#define TF_ADMIN_CEASEFIRE          194
// unused                           195
#define TF_ADMIN_NEXT               196
// unused                           197
// unused                           198
#define TF_ADMIN_LISTIPS            199
// unused                           200
// unused                           201
// unused                           202
// unused                           203
// unused                           204
// unused                           205
// unused                           206
// unused                           207
#define TF_ADMIN_CLANMODE           208
#define TF_ADMIN_QUADMODE           209
#define TF_ADMIN_DUELMODE           210
// unused                           211
// unused                           212
// unused                           213
// unused                           214
// unused                           215
// unused                           216
// unused                           217
// unused                           218
// unused                           219
// unused                           220
// unused                           221
// unused                           222
// unused                           223
// unused                           224
// unused                           225
// unused                           226
// unused                           227
// unused                           228
// unused                           229
// unused                           230
// unused                           231
// unused                           232
// unused                           233
// unused                           234
// unused                           235
// unused                           236
// unused                           237
// unused                           238
// unused                           239
#define TF_ADMIN_ADMINMENU          240
// unused                           241
// unused                           242
// unused                           243
// unused                           244
// unused                           245
// unused                           246
// unused                           247
// unused                           248
// unused                           249
// unused                           250
// unused                           251
// unused                           252
// unused                           253
// unused                           254
// unused                           255

/*======================================================*/
/*	Colors						*/
/*======================================================*/
#define WHITE 		1
#define BROWN 		2
#define BLUE 		3
#define GREEN   	4
#define RED 		5
#define TAN     	6
#define PINK    	7
#define ORANGE  	8
#define PURPLE  	9
#define DARKPURPLE 	10
#define GREY    	11
#define DARKGREEN  	12
#define YELLOW 		13
#define DARKBLUE   	14

/*======================================================*/
/* Defines for the ENGINEER's Building ability		*/
/*======================================================*/
// Ammo costs
#define AMMO_COST_SHELLS		3	// Metal needed to make 1 shell
#define AMMO_COST_NAILS			2
#define AMMO_COST_ROCKETS		5
#define AMMO_COST_CELLS			5

// Building types
#define BUILD_DISPENSER			1
#define BUILD_SENTRYGUN			2

// Building metal costs
#define BUILD_COST_DISPENSER	100
#define BUILD_COST_SENTRYGUN	130

// Building times
#define BUILD_TIME_DISPENSER	2		// 2 seconds to build
#define BUILD_TIME_SENTRYGUN	5		// 5 seconds to build

// Building health levels
#define BUILD_HEALTH_DISPENSER	150
#define BUILD_HEALTH_SENTRYGUN	150

#define SPAWNFLAG_BLOCK_EMP 4096

// Dispenser's maximum carrying capability
#define BUILD_DISPENSER_MAX_SHELLS  400
#define BUILD_DISPENSER_MAX_NAILS   600
#define BUILD_DISPENSER_MAX_ROCKETS 300
#define BUILD_DISPENSER_MAX_CELLS   400
#define BUILD_DISPENSER_MAX_ARMOR   500

#define BUILD_SENTRYGUN_MAX_DISTANCE 128
#define BUILD_SENTRYGUN_MAX_DISTANCE_ENGMOVE 1024

/*======================================================*/
/* Ammo quantities for dropping				*/
/*======================================================*/
#define DROP_SHELLS	20
#define DROP_NAILS	20
#define DROP_ROCKETS	10
#define DROP_CELLS	10
#define DROP_ARMOR	40

/*======================================================*/
/* Team Defines						*/
/*======================================================*/
#define TM_MAX_NO	4	// Max number of teams. Simply changing this value isn't enough.
				// A new global to hold new team colors is needed, and more flags
				// in the spawnpoint spawnflags may need to be used.
				// Basically, don't change this unless you know what you're doing :)

/*======================================================*/
/* New Weapon Defines					*/
/*======================================================*/

#define WEAP_HOOK			1
#define WEAP_KNIFE			2
#define WEAP_MEDIKIT			4
#define WEAP_SPANNER			8
#define WEAP_AXE			16
#define WEAP_SNIPER_RIFLE		32
#define WEAP_AUTO_RIFLE			64
#define WEAP_SHOTGUN			128
#define WEAP_SUPER_SHOTGUN		256
#define WEAP_NAILGUN			512
#define WEAP_SUPER_NAILGUN		1024
#define WEAP_GRENADE_LAUNCHER		2048
#define WEAP_FLAMETHROWER		4096
#define WEAP_ROCKET_LAUNCHER		8192
#define WEAP_INCENDIARY			16384
#define WEAP_ASSAULT_CANNON		32768
#define WEAP_LIGHTNING			65536
#define WEAP_DETPACK			131072
#define WEAP_TRANQ			262144
#define WEAP_LASER			524288
// still room for 12 more weapons
// but we can remove some by giving the weapons
// a weapon mode (like the rifle)

/*======================================================*/
/* New Weapon Related Defines				*/
/*======================================================*/
// shots per reload
#define RE_SHOTGUN		8
#define RE_SUPER_SHOTGUN	16 // 8 shots
#define RE_GRENADE_LAUNCHER	6
#define RE_ROCKET_LAUNCHER	4

// reload times
#define RE_SHOTGUN_TIME			2
#define RE_SUPER_SHOTGUN_TIME		3
#define RE_GRENADE_LAUNCHER_TIME	4
#define RE_ROCKET_LAUNCHER_TIME		5

// Maximum velocity you can move and fire the Sniper Rifle
#define WEAP_SNIPER_RIFLE_MAX_MOVE	50

// Medikit
#define WEAP_MEDIKIT_HEAL	200	// Amount medikit heals per hit
#define WEAP_MEDIKIT_OVERHEAL	50	// Amount of superhealth over max_health the medikit will dispense

// Spanner
#define WEAP_SPANNER_REPAIR	10

// Detpack
#define WEAP_DETPACK_DISARMTIME	3   	// Time it takes to disarm a Detpack
#define WEAP_DETPACK_SETTIME	4   	// Time it takes to set a Detpack
#define WEAP_DETPACK_SIZE	1500
#define WEAP_DETPACK_BITS_NO	12  	// Bits that detpack explodes into

// Tranquiliser Gun
#define TRANQ_TIME		15

// Grenades
#define GR_PRIMETIME		3

#define GR_TYPE_NONE		0
#define GR_TYPE_NORMAL		1
#define GR_TYPE_CONCUSSION	2
#define GR_TYPE_NAIL		3
#define GR_TYPE_MIRV		4
#define GR_TYPE_NAPALM		5
#define GR_TYPE_FLARE		6
#define GR_TYPE_GAS		7
#define GR_TYPE_EMP		8
#define GR_TYPE_FLASH		9
#define GR_TYPE_CALTROP		10
#define GR_TYPE_BLAST	11
#define GR_TYPE_SHOCK	12
#define GR_TYPE_BURST	13

// Defines for NailGren Types
#define NGR_TYPE_NAIL	0
#define NGR_TYPE_LASER		1
#define NGR_TYPE_BURST		2

// NailGren Default Settings
#define NGR_LASER_DEFAULT_ROTATIONCOUNT		2
#define NGR_LASER_DEFAULT_ROTATIONTIME		1
#define NGR_LASER_DEFAULT_DAMAGE		20
#define NGR_LASER_DEFAULT_RANGE			150

#define NGR_BURST_DEFAULT_COUNT			2
#define NGR_BURST_DEFAULT_INTERVAL		0.7
#define NGR_BURST_DEFAULT_RANGE			0.3

// Defines for Medic type
#define MEDIC_TYPE_DEFAULT	0
#define MEDIC_TYPE_BLAST		1

// Defines for BlastGren Settings
#define BLASTGREN_DEFAULT_VELOCITY_MULTIPLIER	1

// Defines for WeaponMode
#define GL_NORMAL	0
#define GL_PIPEBOMB	1

// Defines for Concussion Grenade
#define GR_CONCUSS_TIME	5
#define GR_CONCUSS_DEC	20

// Defines for the Gas Grenade
#define GR_HALLU_TIME	0.5
#define GR_HALLU_DEC	2.5

/*======================================================*/
/* New Items						*/
/*======================================================*/
#define NIT_SCANNER				1

#define NIT_SILVER_DOOR_OPENED 	IT_KEY1	/* 131072 */
#define NIT_GOLD_DOOR_OPENED 	IT_KEY2	/* 262144 */

/*======================================================*/
/* New Item Flags					*/
/*======================================================*/
#define NIT_SCANNER_ENEMY	1	// Detect enemies
#define NIT_SCANNER_FRIENDLY	2	// Detect friendlies (team members)
//#define NIT_SCANNER_MOVEMENT	4	// Motion detection. Only report moving entities.
#define NIT_SCANNER_SOUND	    4	// Scanner makes a sound

/*======================================================*/
/* New Item Related Defines				*/
/*======================================================*/
#define NIT_SCANNER_POWER	100	// The amount of power spent on a scan with the scanner
					// is multiplied by this to get the scanrange.
#define NIT_SCANNER_MAXCELL	50 	// The maximum number of cells than can be used in one scan
#define NIT_SCANNER_MIN_MOVEMENT	50 	// The minimum velocity an entity must have to be detected
						// by scanners that only detect movement

/*======================================================*/
/* Variables used for New Weapons and Reloading		*/
/*======================================================*/

// Armor Classes : Bitfields. Use the "armorclass" of armor for the Armor Type.
#define AT_SAVESHOT		1	// Kevlar  	 : Reduces bullet damage by 15%
#define AT_SAVENAIL		2	// Wood :) 	 : Reduces nail damage by 15%
#define AT_SAVEEXPLOSION	4  	// Blast   	 : Reduces explosion damage by 15%
#define AT_SAVEELECTRICITY	8 	// Shock	 : Reduces electricity damage by 15%
#define AT_SAVEFIRE		16 	// Asbestos	 : Reduces fire damage by 15%

/*======================================================================*/
/* TEAMFORTRESS CLASS DETAILS						*/
/*======================================================================*/
// Class Details for SCOUT
#define PC_SCOUT_SKIN			4 	// Skin for this class when Classkin is on.
#define PC_SCOUT_MAXHEALTH		100	// Maximum Health Level
#define PC_SCOUT_MAXSPEED		450	// Maximum movement speed
#define PC_SCOUT_MAXSTRAFESPEED		450	// Maximum strafing movement speed
#define PC_SCOUT_MAXARMOR		25 	// Maximum Armor Level, of any armor class
#define PC_SCOUT_INITARMOR		0 	// Armor level when respawned
#define PC_SCOUT_MAXARMORTYPE		0.3	// Maximum level of Armor absorption
#define PC_SCOUT_INITARMORTYPE		0.3	// Absorption Level of armor when respawned
#define PC_SCOUT_ARMORCLASSES		3 	// #AT_SAVESHOT | #AT_SAVENAIL	<-Armor Classes allowed for this class
#define PC_SCOUT_INITARMORCLASS		0 	// Armorclass worn when respawned
#define PC_SCOUT_WEAPONS		WEAP_AXE | WEAP_SHOTGUN | WEAP_NAILGUN
#define PC_SCOUT_MAXAMMO_SHOT		50 	// Maximum amount of shot ammo this class can carry
#define PC_SCOUT_MAXAMMO_NAIL		200	// Maximum amount of nail ammo this class can carry
#define PC_SCOUT_MAXAMMO_CELL		100	// Maximum amount of cell ammo this class can carry
#define PC_SCOUT_MAXAMMO_ROCKET		25 	// Maximum amount of rocket ammo this class can carry
#define PC_SCOUT_INITAMMO_SHOT		25 	// Amount of shot ammo this class has when respawned
#define PC_SCOUT_INITAMMO_NAIL		100	// Amount of nail ammo this class has when respawned
#define PC_SCOUT_INITAMMO_CELL		50 	// Amount of cell ammo this class has when respawned
#define PC_SCOUT_INITAMMO_ROCKET	0 	// Amount of rocket ammo this class has when respawned
/* #define PC_SCOUT_GRENADE_TYPE_1	 	// Configured in TeamFortress_SetEquipment() */
#define PC_SCOUT_GRENADE_TYPE_2		GR_TYPE_CONCUSSION	//    <- 2nd Type of Grenade this class has
#define PC_SCOUT_GRENADE_INIT_1		2 	// Number of grenades of Type 1 this class has when respawned
#define PC_SCOUT_GRENADE_INIT_2		3 	// Number of grenades of Type 2 this class has when respawned
#define PC_SCOUT_GRENADE_MAX_1		3
#define PC_SCOUT_GRENADE_MAX_2		4
#define PC_SCOUT_TF_ITEMS		NIT_SCANNER  // <- TeamFortress Items this class has

#define PC_SCOUT_MOTION_MIN_I		0.5 	// < Short range
#define PC_SCOUT_MOTION_MIN_MOVE	50 	// Minimum vlen of player velocity to be picked up by motion detector

// Class Details for SNIPER
#define PC_SNIPER_SKIN			5
#define PC_SNIPER_MAXHEALTH		100
#define PC_SNIPER_MAXSPEED		300
#define PC_SNIPER_MAXSTRAFESPEED	300
#define PC_SNIPER_MAXARMOR		40
#define PC_SNIPER_INITARMOR		0
#define PC_SNIPER_MAXARMORTYPE		0.3
#define PC_SNIPER_INITARMORTYPE		0.3
#define PC_SNIPER_ARMORCLASSES		3	// #AT_SAVESHOT | #AT_SAVENAIL
#define PC_SNIPER_INITARMORCLASS	0
#define PC_SNIPER_WEAPONS		WEAP_SNIPER_RIFLE | WEAP_AUTO_RIFLE | WEAP_AXE | WEAP_NAILGUN
#define PC_SNIPER_MAXAMMO_SHOT		75
#define PC_SNIPER_MAXAMMO_NAIL		100
#define PC_SNIPER_MAXAMMO_CELL		50
#define PC_SNIPER_MAXAMMO_ROCKET	25
#define PC_SNIPER_INITAMMO_SHOT		60
#define PC_SNIPER_INITAMMO_NAIL		50
#define PC_SNIPER_INITAMMO_CELL		0
#define PC_SNIPER_INITAMMO_ROCKET	0
#define PC_SNIPER_GRENADE_TYPE_1	GR_TYPE_NORMAL
#define PC_SNIPER_GRENADE_TYPE_2	GR_TYPE_FLARE
#define PC_SNIPER_GRENADE_INIT_1	2
#define PC_SNIPER_GRENADE_INIT_2	3
#define PC_SNIPER_GRENADE_MAX_1	        4
#define PC_SNIPER_GRENADE_MAX_2	        4
#define PC_SNIPER_TF_ITEMS		0

// Class Details for SOLDIER
#define PC_SOLDIER_SKIN			6
#define PC_SOLDIER_MAXHEALTH		100
#define PC_SOLDIER_MAXSPEED		240
#define PC_SOLDIER_MAXSTRAFESPEED	240
#define PC_SOLDIER_MAXARMOR		200
#define PC_SOLDIER_INITARMOR		100
#define PC_SOLDIER_MAXARMORTYPE		0.8
#define PC_SOLDIER_INITARMORTYPE	0.8
#define PC_SOLDIER_ARMORCLASSES		31	// ALL
#define PC_SOLDIER_INITARMORCLASS	0
#define PC_SOLDIER_WEAPONS		WEAP_AXE | WEAP_SHOTGUN | WEAP_SUPER_SHOTGUN | WEAP_ROCKET_LAUNCHER
#define PC_SOLDIER_MAXAMMO_SHOT		100
#define PC_SOLDIER_MAXAMMO_NAIL		100
#define PC_SOLDIER_MAXAMMO_CELL		50
#define PC_SOLDIER_MAXAMMO_ROCKET	50
#define PC_SOLDIER_INITAMMO_SHOT	50
#define PC_SOLDIER_INITAMMO_NAIL	0
#define PC_SOLDIER_INITAMMO_CELL	0
#define PC_SOLDIER_INITAMMO_ROCKET	10
#define PC_SOLDIER_GRENADE_TYPE_1	GR_TYPE_NORMAL
/* #define PC_SOLDIER_GRENADE_TYPE_2	 	// Configured in TeamFortress_SetEquipment() */
#define PC_SOLDIER_GRENADE_INIT_1	4
#define PC_SOLDIER_GRENADE_INIT_2	1
#define PC_SOLDIER_GRENADE_MAX_1	4
#define PC_SOLDIER_GRENADE_MAX_2	1
#define PC_SOLDIER_ROCKET_SPEED 	900
#define PC_SOLDIER_TF_ITEMS		0

// Class Details for DEMOLITION MAN
#define PC_DEMOMAN_SKIN			1
#define PC_DEMOMAN_MAXHEALTH		100
#define PC_DEMOMAN_MAXSPEED		280
#define PC_DEMOMAN_MAXSTRAFESPEED	280
#define PC_DEMOMAN_MAXARMOR		110
#define PC_DEMOMAN_INITARMOR		40
#define PC_DEMOMAN_MAXARMORTYPE		0.6
#define PC_DEMOMAN_INITARMORTYPE	0.6
#define PC_DEMOMAN_ARMORCLASSES		31	// ALL
#define PC_DEMOMAN_INITARMORCLASS	0	//4	// AT_SAVEEXPLOSION
#define PC_DEMOMAN_WEAPONS		WEAP_AXE | WEAP_SHOTGUN | WEAP_GRENADE_LAUNCHER | WEAP_DETPACK
#define PC_DEMOMAN_MAXAMMO_SHOT		75
#define PC_DEMOMAN_MAXAMMO_NAIL		50
#define PC_DEMOMAN_MAXAMMO_CELL		50
#define PC_DEMOMAN_MAXAMMO_ROCKET	50
#define PC_DEMOMAN_MAXAMMO_DETPACK	1
#define PC_DEMOMAN_INITAMMO_SHOT	30
#define PC_DEMOMAN_INITAMMO_NAIL	0
#define PC_DEMOMAN_INITAMMO_CELL	0
#define PC_DEMOMAN_INITAMMO_ROCKET	20
#define PC_DEMOMAN_INITAMMO_DETPACK	1
#define PC_DEMOMAN_GRENADE_TYPE_1	GR_TYPE_NORMAL
#define PC_DEMOMAN_GRENADE_TYPE_2	GR_TYPE_MIRV
#define PC_DEMOMAN_GRENADE_INIT_1	4
#define PC_DEMOMAN_GRENADE_INIT_2	4
#define PC_DEMOMAN_GRENADE_MAX_1	4
#define PC_DEMOMAN_GRENADE_MAX_2	4
#define PC_DEMOMAN_TF_ITEMS		0

// Class Details for COMBAT MEDIC
#define PC_MEDIC_SKIN			3
#define PC_MEDIC_MAXHEALTH		100
#define PC_MEDIC_MAXSPEED		320
#define PC_MEDIC_MAXSTRAFESPEED		320
#define PC_BLASTMEDIC_MAXSPEED		280
#define PC_BLASTMEDIC_MAXSTRAFESPEED		280
#define PC_MEDIC_MAXARMOR		90
#define PC_MEDIC_INITARMOR		40
#define PC_MEDIC_MAXARMORTYPE		0.6
#define PC_MEDIC_INITARMORTYPE		0.3
#define PC_MEDIC_ARMORCLASSES		11	// ALL except EXPLOSION
#define PC_MEDIC_INITARMORCLASS		0
#define PC_MEDIC_WEAPONS		WEAP_MEDIKIT | WEAP_SHOTGUN | WEAP_SUPER_SHOTGUN | WEAP_SUPER_NAILGUN
#define PC_MEDIC_MAXAMMO_SHOT		75
#define PC_MEDIC_MAXAMMO_NAIL		150
#define PC_MEDIC_MAXAMMO_CELL		50
#define PC_MEDIC_MAXAMMO_ROCKET		25
#define PC_MEDIC_MAXAMMO_MEDIKIT	100
#define PC_MEDIC_INITAMMO_SHOT		50
#define PC_MEDIC_INITAMMO_NAIL		50
#define PC_MEDIC_INITAMMO_CELL		0
#define PC_MEDIC_INITAMMO_ROCKET	0
#define PC_MEDIC_INITAMMO_MEDIKIT	50
#define PC_MEDIC_GRENADE_TYPE_1		GR_TYPE_NORMAL
/* #define PC_MEDIC_GRENADE_TYPE_2	 	// Configured in TeamFortress_SetEquipment() */
#define PC_MEDIC_GRENADE_INIT_1		3
#define PC_MEDIC_GRENADE_INIT_2		3
#define PC_MEDIC_GRENADE_MAX_1		4
#define PC_MEDIC_GRENADE_MAX_2		3
#define PC_MEDIC_TF_ITEMS		0
#define PC_MEDIC_REGEN_TIME		3	// Number of seconds between each regen.
#define PC_MEDIC_REGEN_AMOUNT		2	// Amount of health regenerated each regen.
#define PC_MEDIC_AURA_HEAL_TIME     1   // Number of seconds between each aura heal.
#define PC_MEDIC_AURA_HEAL_AMOUNT   5   // Amount of health given per aura heal.
#define PC_MEDIC_AURA_RANGE         120 // The aura's range
#define PC_MEDIC_CELL_REGEN_TIME    1   // Number of seconds between each cell regen.
#define PC_MEDIC_CELL_REGEN_PERCENT 10  // Percentage of max cells regenerated each cell regen.
#define PC_MEDIC_CELL_REGEN_CD      5   // Seconds to cooldown cell regeneration after healing with medikit.
#define PC_MEDIC_SAVEME_GRACE       5   // Seconds after which /saveme gives grace period to medikit (no cell regeneration cooldown)
#define PC_MEDIC_AURA_ACTIVE    1
#define PC_MEDIC_AURA_RECHARGING    2
#define PC_MEDIC_AURA_OUTOFPOWER    3

// Class Details for HVYWEAP
#define PC_HVYWEAP_SKIN			2
#define PC_HVYWEAP_MAXHEALTH		100
#define PC_HVYWEAP_MAXSPEED		230
#define PC_HVYWEAP_MAXSTRAFESPEED	230
#define PC_HVYWEAP_MAXARMOR		300
#define PC_HVYWEAP_INITARMOR		150
#define PC_HVYWEAP_MAXARMORTYPE		0.8
#define PC_HVYWEAP_INITARMORTYPE	0.8
#define PC_HVYWEAP_ARMORCLASSES		31	// ALL
#define PC_HVYWEAP_INITARMORCLASS	0
#define PC_HVYWEAP_WEAPONS		WEAP_ASSAULT_CANNON | WEAP_AXE | WEAP_SHOTGUN | WEAP_SUPER_SHOTGUN
#define PC_HVYWEAP_MAXAMMO_SHOT		200
#define PC_HVYWEAP_MAXAMMO_NAIL		200
#define PC_HVYWEAP_MAXAMMO_CELL		50
#define PC_HVYWEAP_MAXAMMO_ROCKET	25
#define PC_HVYWEAP_INITAMMO_SHOT	200
#define PC_HVYWEAP_INITAMMO_NAIL	0
#define PC_HVYWEAP_INITAMMO_CELL	30
#define PC_HVYWEAP_INITAMMO_ROCKET	0
#define PC_HVYWEAP_GRENADE_TYPE_1	GR_TYPE_NORMAL
#define PC_HVYWEAP_GRENADE_TYPE_2	GR_TYPE_MIRV
#define PC_HVYWEAP_GRENADE_INIT_1	4
#define PC_HVYWEAP_GRENADE_INIT_2	1
#define PC_HVYWEAP_GRENADE_MAX_1	4
#define PC_HVYWEAP_GRENADE_MAX_2	1
#define PC_HVYWEAP_TF_ITEMS		0
#define PC_HVYWEAP_PROJSPEED	3000
#define PC_HVYWEAP_ASSCAN_CLIPSIZE		100
#define MODEL_PROJ_DIAM2 "progs/proj_diam2.mdl"


// Class Details for PYRO
#define PC_PYRO_SKIN			21
#define PC_PYRO_MAXHEALTH		100
#define PC_PYRO_MAXSPEED		300
#define PC_PYRO_MAXSTRAFESPEED		300
#define PC_PYRO_MAXARMOR		150
#define PC_PYRO_INITARMOR		50
#define PC_PYRO_MAXARMORTYPE		0.6
#define PC_PYRO_INITARMORTYPE		0.6
#define PC_PYRO_ARMORCLASSES		27	// ALL except EXPLOSION
#define PC_PYRO_INITARMORCLASS		16	// AT_SAVEFIRE
#define PC_PYRO_WEAPONS			WEAP_INCENDIARY | WEAP_FLAMETHROWER | WEAP_AXE | WEAP_SHOTGUN
#define PC_PYRO_MAXAMMO_SHOT		40
#define PC_PYRO_MAXAMMO_NAIL		50
#define PC_PYRO_MAXAMMO_CELL		200
#define PC_PYRO_MAXAMMO_ROCKET		60
#define PC_PYRO_INITAMMO_SHOT		20
#define PC_PYRO_INITAMMO_NAIL		0
#define PC_PYRO_INITAMMO_CELL		120
#define PC_PYRO_INITAMMO_ROCKET		15
#define PC_PYRO_GRENADE_TYPE_1		GR_TYPE_NORMAL
#define PC_PYRO_GRENADE_TYPE_2		GR_TYPE_NAPALM
#define PC_PYRO_GRENADE_INIT_1		1
#define PC_PYRO_GRENADE_INIT_2		4
#define PC_PYRO_GRENADE_MAX_1		4
#define PC_PYRO_GRENADE_MAX_2		4
#define PC_PYRO_TF_ITEMS		0
#define PC_PYRO_AIRBLAST_RANGE	        400
#define PC_PYRO_AIRBLAST_COOLDOWN	5
#define PC_PYRO_AIRBLAST_CELLS			55
#define PC_PYRO_AIRBLASTJUMP_CELLS		75
#define PC_PYRO_LAVA_LIFETIME	3
#define PC_PYRO_LAVA_RETICK		1.2
#define PC_PYRO_FLAMETHROWER_DAM_FO	15
#define PC_PYRO_FLAMETHROWER_DAM_ORIG	10
#define PC_PYRO_NAPALM_INIT_DAM_ORIG	20
#define PC_PYRO_NAPALM_INIT_DAM_FO		40
#define PC_PYRO_NAPALM_MAX_EXPLOSIONS_ORIG	8
#define PC_PYRO_NAPALM_MAX_EXPLOSIONS_FO	4
#define PC_PYRO_INIT_BURN_DAM_ORIG		6
#define PC_PYRO_INIT_BURN_DAM_FO		12
#define PC_PYRO_BURN_MULTIPLIER_ORIG	.3
#define PC_PYRO_BURN_MULTIPLIER_FO		1
#define PC_PYRO_BURN_DAMAGE_AMP			1.2
#define PC_PYRO_OLD_PROJSPEED			600
#define PC_PYRO_NEW_PROJSPEED			800

// pyro types
#define PYRO_ORIGINAL	0
#define PYRO_OZTF		1
#define PYRO_FO			2

// Class Details for SPY
#define PC_SPY_SKIN			22
#define PC_SPY_MAXHEALTH		100
#define PC_SPY_MAXSPEED			300
#define PC_SPY_MAXSTRAFESPEED		300
#define PC_SPY_MAXARMOR			90
#define PC_SPY_INITARMOR		15
#define PC_SPY_MAXARMORTYPE		0.6
#define PC_SPY_INITARMORTYPE		0.6
#define PC_SPY_ARMORCLASSES		27	// ALL except EXPLOSION
#define PC_SPY_INITARMORCLASS		0
#define PC_SPY_WEAPONS			WEAP_KNIFE | WEAP_TRANQ | WEAP_SUPER_SHOTGUN | WEAP_NAILGUN
#define PC_SPY_MAXAMMO_SHOT		40
#define PC_SPY_MAXAMMO_NAIL		100
#define PC_SPY_MAXAMMO_CELL		30
#define PC_SPY_MAXAMMO_ROCKET		15
#define PC_SPY_INITAMMO_SHOT		40
#define PC_SPY_INITAMMO_NAIL		50
#define PC_SPY_INITAMMO_CELL		10
#define PC_SPY_INITAMMO_ROCKET		0
#define PC_SPY_GRENADE_TYPE_1		GR_TYPE_NORMAL
#define PC_SPY_GRENADE_TYPE_2		GR_TYPE_GAS
#define PC_SPY_GRENADE_INIT_1		2
#define PC_SPY_GRENADE_INIT_2		2
#define PC_SPY_GRENADE_MAX_1		4
#define PC_SPY_GRENADE_MAX_2		2
#define PC_SPY_TF_ITEMS			0
#define PC_SPY_CELL_REGEN_TIME		5
#define PC_SPY_CELL_REGEN_AMOUNT	1
#define PC_SPY_CELL_USAGE		3	// Amount of cells spent while invisible
#define PC_SPY_GO_UNDERCOVER_TIME	4	// Time it takes to go undercover
#define PC_SPY_TRANQSPEED			1500

// Class Details for ENGINEER
#define PC_ENGINEER_SKIN		22	// Not used anymore
#define PC_ENGINEER_MAXHEALTH		100
#define PC_ENGINEER_MAXSPEED		300
#define PC_ENGINEER_MAXSTRAFESPEED	300
#define PC_ENGINEER_MAXARMOR		30
#define PC_ENGINEER_INITARMOR		5
#define PC_ENGINEER_MAXARMORTYPE	0.6
#define PC_ENGINEER_INITARMORTYPE	0.3
#define PC_ENGINEER_ARMORCLASSES	31	// ALL
#define PC_ENGINEER_INITARMORCLASS	0
#define PC_ENGINEER_WEAPONS		WEAP_SPANNER | WEAP_LASER | WEAP_SUPER_SHOTGUN
#define PC_ENGINEER_MAXAMMO_SHOT	50
#define PC_ENGINEER_MAXAMMO_NAIL	50
#define PC_ENGINEER_MAXAMMO_CELL	200	// synonymous with metal
#define PC_ENGINEER_MAXAMMO_ROCKET	30
#define PC_ENGINEER_INITAMMO_SHOT	20
#define PC_ENGINEER_INITAMMO_NAIL	25
#define PC_ENGINEER_INITAMMO_CELL	100	// synonymous with metal
#define PC_ENGINEER_INITAMMO_ROCKET	0
#define PC_ENGINEER_GRENADE_TYPE_1	GR_TYPE_NORMAL
#define PC_ENGINEER_GRENADE_TYPE_2	GR_TYPE_EMP
#define PC_ENGINEER_GRENADE_INIT_1	2
#define PC_ENGINEER_GRENADE_INIT_2	2
#define PC_ENGINEER_GRENADE_MAX_1	4
#define PC_ENGINEER_GRENADE_MAX_2	4
#define PC_ENGINEER_TF_ITEMS		0
#define PC_ENGINEER_GRENADE_TYPE_2_RANGE	240
#define PC_ENGINEER_RAILSPEED		1500

// Class Details for CIVILIAN
#define PC_CIVILIAN_SKIN		22
#define PC_CIVILIAN_MAXHEALTH		50
#define PC_CIVILIAN_MAXSPEED		240
#define PC_CIVILIAN_MAXSTRAFESPEED	240
#define PC_CIVILIAN_MAXARMOR		0
#define PC_CIVILIAN_INITARMOR		0
#define PC_CIVILIAN_MAXARMORTYPE	0
#define PC_CIVILIAN_INITARMORTYPE	0
#define PC_CIVILIAN_ARMORCLASSES	0
#define PC_CIVILIAN_INITARMORCLASS	0
#define PC_CIVILIAN_WEAPONS		WEAP_AXE
#define PC_CIVILIAN_MAXAMMO_SHOT	0
#define PC_CIVILIAN_MAXAMMO_NAIL	0
#define PC_CIVILIAN_MAXAMMO_CELL	0
#define PC_CIVILIAN_MAXAMMO_ROCKET	0
#define PC_CIVILIAN_INITAMMO_SHOT	0
#define PC_CIVILIAN_INITAMMO_NAIL	0
#define PC_CIVILIAN_INITAMMO_CELL	0
#define PC_CIVILIAN_INITAMMO_ROCKET	0
#define PC_CIVILIAN_GRENADE_TYPE_1	0
#define PC_CIVILIAN_GRENADE_TYPE_2	0
#define PC_CIVILIAN_GRENADE_INIT_1	0
#define PC_CIVILIAN_GRENADE_INIT_2	0
#define PC_CIVILIAN_GRENADE_MAX_1	0
#define PC_CIVILIAN_GRENADE_MAX_2	0
#define PC_CIVILIAN_TF_ITEMS		0


/*======================================================================*/
/* TEAMFORTRESS GOALS							*/
/*======================================================================*/
// For all these defines, see the tfortmap.txt that came with the zip
// for complete descriptions.
// Defines for Goal Activation types : goal_activation (in goals)
#define TFGA_TOUCH		1  // Activated when touched
#define TFGA_TOUCH_DETPACK	2  // Activated when touched by a detpack explosion
#define TFGA_REVERSE_AP		4  // Activated when AP details are _not_ met
#define TFGA_SPANNER		8  // Activated when hit by an engineer's spanner

// Defines for Goal Effects types : goal_effect
#define TFGE_AP			1  // AP is affected. Default.
#define TFGE_AP_TEAM		2  // All of the AP's team.
#define TFGE_NOT_AP_TEAM	4  // All except AP's team.
#define TFGE_NOT_AP		8  // All except AP.
#define TFGE_WALL		16 // If set, walls stop the Radius effects
#define TFGE_SAME_ENVIRONMENT	32 // If set, players in a different environment to the Goal are not affected
#define TFGE_TIMER_CHECK_AP	64 // If set, Timer Goals check their critera for all players fitting their effects

// Defines for Goal Result types : goal_result
#define TFGR_SINGLE		1	// Goal can only be activated once
#define TFGR_ADD_BONUSES	2	// Any Goals activated by this one give their bonuses
#define TFGR_ENDGAME		4	// Goal fires Intermission, displays scores, and ends level
#define TFGR_NO_ITEM_RESULTS	8	// GoalItems given by this Goal don't do results
#define TFGR_REMOVE_DISGUISE	16	// Prevent/Remove undercover from any Spy
#define TFGR_FORCE_RESPAWN	32

// Defines for Goal Group Result types : goal_group
// None!
// But I'm leaving this variable in there, since it's fairly likely
// that some will show up sometime.

// Defines for Goal Item types, : goal_activation (in items)
#define TFGI_GLOW		1   // Players carrying this GoalItem will glow
#define TFGI_SLOW		2   // Players carrying this GoalItem will move at half-speed
#define TFGI_DROP		4   // Players dying with this item will drop it
#define TFGI_RETURN_DROP	8   // Return if a player with it dies
#define TFGI_RETURN_GOAL	16  // Return if a player with it has it removed by a goal's activation
#define TFGI_RETURN_REMOVE	32  // Return if it is removed by TFGI_REMOVE
#define TFGI_REVERSE_AP		64  // Only pickup if the player _doesn't_ match AP Details
#define TFGI_REMOVE		128 // Remove if left untouched for 2 minutes after being dropped
#define TFGI_KEEP		256 // Players keep this item even when they die
#define TFGI_ITEMGLOWS		512	// Item glows when on the ground
#define TFGI_DONTREMOVERES	1024 // Don't remove results when the item is removed
#define TFGI_DROPTOFLOOR	2048 // If this bit is set, the GoalItem drops to the ground when it first spawns.
#define TFGI_ALLOWTHROW	    4096 // Item can be thrown with 'dropitems' command
#define TFGI_SOLID	        8192 // Item is solid

// Defines for TeamSpawnpoints : goal_activation (in team spawns)
#define TFSP_MULTIPLEITEMS	1  // Give out the GoalItem multiple times
#define TFSP_MULTIPLEMSGS	2  // Display the message multiple times

// Defines for TeamSpawnpoints : goal_effects (in teamspawns)
#define TFSP_REMOVESELF		1  // Remove itself after being spawned on

// Defines for Goal States
#define TFGS_NONE	0
#define TFGS_ACTIVE		1
#define TFGS_INACTIVE		2
#define TFGS_REMOVED		3
#define TFGS_DELAYED		4

// Legal Playerclass Handling
#define TF_ILL_SCOUT 		1
#define TF_ILL_SNIPER		2
#define TF_ILL_SOLDIER		4
#define TF_ILL_DEMOMAN		8
#define TF_ILL_MEDIC		16
#define TF_ILL_HVYWEP		32
#define TF_ILL_PYRO		64
#define TF_ILL_RANDOMPC		128
#define TF_ILL_SPY		256
#define TF_ILL_ENGINEER		512

// spawnflags
#define TFGI_NOGLOW	1 // stop the automatic glow applied in fortressone to goals with a .mdl set based on team
#define TFGI_CB_IGNORE	2 // Allow this goal to work even in clan battle/quadmode prematch

// spawnflags - fo_misc_info
#define TFGI_NOGLOW	1 // we reuse some tfgi functions, so keep this spawnflag
#define TFGI_CB_IGNORE	2 // Allow this goal to work even in clan battle/quadmode prematch
#define FO_MISC_INFO_NO_Z_TEST	4 // Draw this "through" walls - fake it in ez, csqc do it locally

/*======================================================================*/
/* Flamethrower								*/
/*======================================================================*/

#define FLAME_PLYRMAXTIME	45	// lifetime in 0.1 sec of a flame on a player
#define FLAME_MAXBURNTIME	8	// lifetime in seconds of a flame on the world (big ones)
#define NAPALM_MAXBURNTIME	20	// lifetime in seconds of flame from a napalm grenade
#define FLAME_MAXPLYRFLAMES	4	// maximum number of flames on a player
#define FLAME_NUMLIGHTS		1	// maximum number of light flame
#define FLAME_BURNRATIO		0.3	// the chance of a flame not 'sticking'
#define GR_TYPE_FLAMES_NO	15	// number of flames spawned when a grenade explode

/*======================================================*/
/* CTF Support defines 					*/
/*======================================================*/
#define CTF_FLAG1 	1
#define CTF_FLAG2 	2
#define CTF_DROPOFF1 	3
#define CTF_DROPOFF2 	4
#define CTF_SCORE1   	5
#define CTF_SCORE2   	6

/*======================================================*/
/* Death Message defines				*/
/*======================================================*/

#define DMSG_SHOTGUN			1
#define DMSG_SSHOTGUN			2
#define DMSG_NAILGUN			3
#define DMSG_SNAILGUN			4
#define DMSG_GRENADEL			5
#define DMSG_ROCKETL			6
#define DMSG_LIGHTNING			7
#define DMSG_GREN_HAND			8
#define DMSG_GREN_NAIL			9
#define DMSG_GREN_MIRV			10
#define DMSG_GREN_PIPE			11
#define DMSG_DETPACK			12
#define DMSG_BIOWEAPON          13
#define DMSG_BIOWEAPON_ATT      14
#define DMSG_FLAME			15
#define DMSG_DETPACK_DIS		16
#define DMSG_AXE			17
#define DMSG_SNIPERRIFLE		18
#define DMSG_AUTORIFLE			19
#define DMSG_ASSAULTCANNON		20
#define DMSG_HOOK			21
#define DMSG_BACKSTAB			22
#define DMSG_MEDIKIT			23
#define DMSG_GREN_GAS			24
#define DMSG_TRANQ			25
#define DMSG_LASERBOLT			26
#define DMSG_SENTRYGUN_BULLET		27
#define DMSG_SNIPERLEGSHOT		28
#define DMSG_SNIPERHEADSHOT		29
#define DMSG_GREN_EMP			30
#define DMSG_GREN_EMP_AMMO		31
#define DMSG_SPANNER			32
#define DMSG_INCENDIARY			33
#define DMSG_SENTRYGUN_ROCKET		34
#define DMSG_GREN_FLASH			35
#define DMSG_TRIGGER			36
#define DMSG_TEAMKILL			37
#define DMSG_SENTRYGUN_EXPLODE			38
#define DMSG_DISPENSER_EXPLODE			39
#define DMSG_GREN_PIPE_AIR			40
#define DMSG_GREN_CALTROP			41
#define DMSG_GREN_SHOCK			42
#define DMSG_GREN_BURST			43
#define DMSG_KNIFE			44

/*======================================================*/
/* Menus						*/
/*======================================================*/

#define MENU_DEFAULT				1
#define MENU_TEAM 				2
#define MENU_CLASS 				3
#define MENU_DROP  				4
#define MENU_INTRO 				5
#define MENU_DEMOMAN                6
#define MENU_DEMOMAN_CANCEL         7
#define MENU_REPEATHELP 			8
#define MENU_SPY_SKIN_1             9
#define MENU_SPY_SKIN_2             10
#define MENU_SPY_SKIN_3             11
#define MENU_SPY				12
#define MENU_SPY_SKIN				13
#define MENU_SPY_COLOR				14
#define MENU_ENGINEER				15
#define MENU_ENGINEER_FIX_DISPENSER		16
#define MENU_ENGINEER_FIX_SENTRYGUN		17
#define MENU_SCOUT                  18
#define MENU_DISPENSER				19

#define MENU_REFRESH_RATE 			25


/*======================================================*/
/* Misc defines						*/
/*======================================================*/

#define MAX_WORLD_FLAMES	20	// maximum number of flames in the world. DO NOT PUT BELOW 20.
#define MAX_WORLD_PIPEBOMBS	15	// This is divided between teams
					//	- this is the most you should have on a net server
#define MAX_WORLD_AMMOBOXES	20	// This is divided between teams
					//	- this is the most you should have on a net server
#define GR_TYPE_MIRV_NO		4	// Number of Mirvs a Mirv Grenade breaks into
#define GR_TYPE_NAPALM_NO	8	// Number of flames napalm grenade breaks into (unused if net server)

#define TEAM_HELP_RATE		60	// used only if teamplay bit 64 (help team with lower score) is set.
					// 60 is a mild setting, and won't make too much difference
					// increasing it _decreases_ the amount of help the losing team gets
					// Minimum setting is 1, which would really help the losing team

#define SNIPER_RIFLE_RELOAD_TIME 1.5	// seconds

#define RESPAWN_DELAY_TIME	5	// this is the respawn delay, if the RESPAWN_DELAY option is
					// turned on with temp1.  QuakeWorld servers can use
					// serverinfo respawn_delay to set their own time.


// CSQC defines
#define FO_HUD_GROW_UP		1
#define FO_HUD_GROW_DOWN	2
#define FO_HUD_GROW_LEFT	3
#define FO_HUD_GROW_RIGHT	4

#define FO_HUD_CONFIG_PATH	"fortressone_hud.cfg"
#define FO_CONFIG_PATH	"fortressone_csqc.cfg"

#define HUD_ICON_SIZE_X   24
#define HUD_ICON_SIZE_Y   24
#define FO_HUD_CLIPSIZE_PANEL_X 125
#define FO_HUD_CLIPSIZE_PANEL_Y 50
#define FO_HUD_INSERT_BEFORE	0
#define FO_HUD_INSERT_AFTER	1
#define FO_HUD_INSERT_MIDDLE	2

#define FO_HUD_CLIPSIZE_NAME "Clip Size"
#define FO_HUD_FRAGSTREAK_NAME "Frag Streak"
#define FO_HUD_CAPS_NAME "Caps"
#define FO_HUD_IDENTIFY_NAME "ID"
#define FO_HUD_GREN1_NAME "Gren 1"
#define FO_HUD_GREN2_NAME "Gren 2"
#define FO_HUD_SPECIAL_NAME "Class Special"
#define FO_HUD_GRENTIMER_NAME "Grenade Timer"
#define FO_HUD_OPTIONS_NAME "Options"
#define FO_HUD_FLAGINFO_NAME "Flag Status"
#define FO_HUD_MOTD_NAME "MOTD"
#define FO_HUD_MENU_HINT_NAME "Menu Hints"
#define FO_HUD_GAME_MODE_NAME "Game Mode"
#define FO_HUD_READY_NAME "Ready Status"
#define FO_HUD_SHOWSCORES_NAME "Show Scores"
#define FO_HUD_MAP_MENU_NAME "Map Menu"
#define FO_HUD_HEALTH_NAME "Health"
#define FO_HUD_FACE_NAME "Face"
#define FO_HUD_AMMO_NAME "Ammo"
#define FO_HUD_AMMO_ICON_NAME "Ammo Icon"
#define FO_HUD_ARMOUR_NAME "Armour"
#define FO_HUD_ARMOUR_ICON_NAME "Armour Icon"
#define FO_HUD_INV_SHELLS_NAME "Shells"
#define FO_HUD_INV_NAILS_NAME "Nails"
#define FO_HUD_INV_ROCKETS_NAME "Rockets"
#define FO_HUD_INV_CELLS_NAME "Cells"
#define FO_HUD_TEAM_SCORE_NAME "Team Score"


#define ICON_CLIPSIZE "textures/wad/clipsize.png"
#define ICON_FRAGSTREAK "textures/wad/fragstreak.png"
#define ICON_CAPS "textures/wad/caps.png"
#define ICON_IDENTIFY "textures/wad/identify.png"
#define ICON_GREN_NONE "textures/wad/gren_none.png"
#define ICON_GREN_NORMAL "textures/wad/gren_normal.png"
#define ICON_GREN_NAIL "textures/wad/gren_nail.png"
#define ICON_GREN_CONCUSSION "textures/wad/gren_concussion.png"
#define ICON_GREN_FLASH "textures/wad/gren_flash.png"
#define ICON_GREN_EMP "textures/wad/gren_emp.png"
#define ICON_GREN_MIRV "textures/wad/gren_mirv.png"
#define ICON_GREN_NAPALM "textures/wad/gren_napalm.png"
#define ICON_GREN_GAS "textures/wad/gren_gas.png"
#define ICON_GREN_FLARE "textures/wad/gren_flare.png"
#define ICON_GREN_CALTROP "textures/wad/gren_caltrop.png"
#define ICON_GREN_BLAST "textures/wad/gren_blast.png"
#define ICON_GREN_SHOCK "textures/wad/gren_nail.png"
#define ICON_GREN_BURST "textures/wad/gren_nail.png"
#define ICON_SCOUT "textures/wad/scout.png"
#define ICON_SNIPER "textures/wad/sniper.png"
#define ICON_SOLDIER "textures/wad/soldier.png"
#define ICON_DEMOMAN "textures/wad/demoman.png"
#define ICON_MEDIC "textures/wad/medic.png"
#define ICON_HWGUY "textures/wad/hwguy.png"
#define ICON_PYRO "textures/wad/pyro.png"
#define ICON_SPY "textures/wad/spy.png"
#define ICON_ENGINEER_SG "textures/wad/engineer_sg.png"
#define ICON_ENGINEER_DISP "textures/wad/engineer_disp.png"
#define ICON_SECURITY_BUTTON_ANY "textures/wad/off_icon_glow_0.png"
#define ICON_SECURITY_BUTTON_BLUE "textures/wad/off_icon_glow_1.png"
#define ICON_SECURITY_BUTTON_RED "textures/wad/off_icon_glow_2.png"
#define ICON_SECURITY_BUTTON_YELLOW "textures/wad/off_icon_glow_3.png"
#define ICON_SECURITY_BUTTON_GREEN "textures/wad/off_icon_glow_4.png"
#define ICON_FLAG_ANY "textures/wad/flag_0.png"
#define ICON_FLAG_BLUE "textures/wad/flag_1.png"
#define ICON_FLAG_RED "textures/wad/flag_2.png"
#define ICON_FLAG_YELLOW "textures/wad/flag_3.png"
#define ICON_FLAG_GREEN "textures/wad/flag_4.png"

// stats
// first 32 are reserved
#define STAT_TEAMNO             33
#define STAT_FLAGS              34
#define STAT_CLASS              35
#define STAT_VELOCITY_X         36
#define STAT_VELOCITY_Y         37
#define STAT_VELOCITY_Z         38
#define STAT_NO_GREN1           39
#define STAT_NO_GREN2           40
#define STAT_TP_GREN1           41
#define STAT_TP_GREN2           42
#define STAT_PAUSED             43

// Dimensions
#define DMN_FLASH 1 // when flashed, we set dimension see to this
// all bits between 1 and 255 are reserved for flash
#define DMN_NOFLASH	256	// see all the things
#define DMN_TEAMBLUE	512
#define DMN_TEAMRED		1024
#define DMN_TEAMYELL	2048
#define DMN_TEAMGREN	4096
#define DMN_INVISIBLE	8192	// special dimension to hide stuff in

// trigger_push
#define PUSH_ONCE	1
#define PUSH_INCLUDETFITEM	2
#define PUSH_EXCLUDEOTHER	4 // bad names, bad bits, bad coder - use in conjunction with includetfitem to exclude all but tfitem
#define PUSH_NONOISE	8
#define PUSH_MEGAJUMPER	16
#define PUSH_EXCLUDEGRENADE	32

// func_wall
#define WALL_SOLID_NOT	1
#define WALL_HIDE_ON_USE	2
#define WALL_SOLID_NOT_ON_USE 4

// teams
#define TEAM_BLUE	1
#define TEAM_RED	2
#define TEAM_YELL	3
#define TEAM_GREN	4
