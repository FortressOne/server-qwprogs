FortressOne Server
==================

New commands
------------

* `fo_reloadvolume 0` 0 - 1 volume for reloading sounds
* `fo_reloadalpha x` alpha of viewmodel when reloading, 0 for invisible
* `fo_team_color_crosshair` change crosshair to team colour
* `cmd updateserver` tell server to pull latest progs and maps
* `+slot n` bind. fires nth weapon
* `fo_default_weapon 0` default weapon when using `+slot` binds
* `fo_hud_cache 1` less resource intensive hud
* `fo_hud_fps 60` set hud refresh rate
* `fo_grentimer_ping_frac 1` fraction of ping to correct for
* `fo_grentimer_nostack 0` when set, only play the oldest timer
* `fo_fte_hud 0` completely replace Quake engine hud with FO hud
* `fo_legacy_sbar 0` use oldschool Team Fortress status bar
* `fo_oldscoreboard 0` use oldschool Quake scoreboard
* `fo_adminrefresh 2` time in seconds for admin menu to refresh
* `fo_predict_weapons 1` client-side weapon prediction
* `fo_predict_projectiles 1` client-side projectile prediction
* `wpp_min_ping -1` minimum ping before `fo_wpp_beta` is enabled.
* `fo_client_sniper_sight 1` client side sniper dot
* `cl_p2r` use rocket model for incendiary launcher
* `cl_r2g` use grenade model for rockets
* `r_pyrotrail 0` ezquake-compatible trail selection for incendiary launcher
* `r_rockettrail 0` ezquake-compatible trail selection for rocket launcher
* `r_grenadetrail 0` ezquake-compatible trail selection for grenade launcher
* `wpp_phys_adv_ms 0`
* `wpp_phys_local_adv_ms 0`
* `wpp_setspeed 1`
* `wpp_debug 1` bitfield 0,1,2,4,8 for debugging
* `fo_phys_debug 1` bitfield 0,1 for debugging

* Added in `fo_hittext_friendly 0` - setting to 1 shows text when damaging friendlys
* Added in `fo_hittext_colour3 "1 0 0"` - colour of friendly hittext if fo_hittext_friendly is set to 1 (rgb 0-1)

* Added in csqc hitaudio and hittext for testing `localinfo zutmode 1` on server to enable.
  
Client commands, default shown:
  
=== Audio ===
* `fo_hitaudio_enabled 1`      - toggle on/off
* `fo_hitaudio_hurtself 1`     - play a sound when you hurt yourself
* `fo_hitaudio_hurtteam 1`     - play a sound when you hurt a teammate   
* `fo_hitaudio_hurtenemy 1`    - play a sound when you hurt an enemy
* `fo_hitaudio_killself 1`     - play a sound when you kill yourself
* `fo_hitaudio_killteam 1`     - play a sound when you kill a teammate
* `fo_hitaudio_killenemy 1`    - play a sound when you kill an enemy
* `fo_hitaudio_noarmour 1`     - play an extra sound if you hurt an enemy with no armour
  
also added a headshot sound for snipers, only plays for the client  
sound files are found in `fortress/sound/hitaudio/` and  `fortress/sound/announcer/`
  
=== Text ===
* `fo_hittext_enabled 1`       - toggle on/off
* `fo_hittext_size 32`         - size of text
* `fo_hittext_speed 96`        - how fast text scrolls up
* `fo_hittext_alpha 1`         - alpha
* `fo_hittext_duration 2`      - how long before text disappears
* `fo_hittext_rawdamage 1`     - setting to 0 shows damage AFTER armour mitigation
* `fo_hittext_noarmour 1`      - changes colour of text if enemy has no armour, see `fo_hittext_colour2` to set
* `fo_hittext_offset 32`       - how high text appears above target
* `fo_hittext_friendly 0`      - toggles text above friendlys if you damage them
* `fo_hittext_colour "1 1 1"`  - default colour of enemy text (rgb 0-1)
* `fo_hittext_colour2 "1 0 1"` - overrides default colour of enemy text if `fo_hittext_noarmour 1` is set and target has no armour (rgb 0-1)
* `fo_hittext_colour3 "1 0 0"` - colour of friendly hittext if fo_hittext_friendly is set to 1 (rgb 0-1)
-------------------------------

* Website backend for match results, stats. Get a token at fortressone.org, connect to a FortressOne server, and `login <token>`.


* `localinfo play_to_completion 0` set to 1 to allow quad to continue to round end even after required score exceeded.
* `localinfo pipecooldown_time <number>` time in seconds for demo pipe cooldown
* `localinfo allpipes_cooldown on/off` whether cooldown is applied to individual pipes or all pipes. i.e. with this on the demo can not det any of his pipes immediately after firing. (default off)
* `localinfo discord_channel_id <number>` to specify discord_channel. Required for autoreporting.
* `localinfo fo_matchrated 2` whether match is rated / affects trueskill. 2 is false for 1v1 and 2v2 only.
* `localinfo backend_address <uri>` to specify backend API endpoint. Default: https://www.fortressone.org/
* All-time attack and all-time defence team options.
* `setinfo team<n>color <color>` sets player skins colours for team <n>, where <color> is quake palette 0-15 or hex code beginning with 0x. E.g. `setinfo team1colour 0` makes all team 1 players white, `setinfo team2color 0xFF8800` makes all team 2 players orange. `setinfo team<n>color ""` to restore defaults. Note that `teamcolor` and `enemycolor` cvars will take priority.
* `setinfo precise_grenades on/off` to enable precise timing when throwing grenades.  This removes a random, up to, 100ms input delay.  (default on)
* `localinfo forcereload 0/1` Option to prevent forced reloads.
* `+grenade1` and `+grenade2` grenade buttons (more reliable than impulses), push to prime, again to throw.
* `+dropflag` Allows player to hold button and flag will be thrown on contact.
* `+rj` Switches to rocket/incendiary weapon, jumps and shoots. `+aux_jump` is no longer required.
* `dlastspawn` Tells spy to disguise as enemy who last spawned.
* `setinfo cf_pyro_impulses 1` to swap Pyro's primary and secondary weapons.
* `setinfo autodisguise 1` Causes spy to `dlastspawn` after spawning or cover blown.
* `setinfo autodisguise 2` Causes spy to `dlast` after spawning or cover blown.
* `special2` Scout: `autoscan`, Demoman: `+det5`, Pyro: `+rj`, Spy: `dlastspawn`, Engineer: `togglesentry`
* New buttons (not impulses):
* `+special` Scout: `dash`, Demoman: `detpipe`, Medic: `aura`, Hwguy: `lock`, Pyro: `airblast`, Spy: `+feign`, Engineer: `toggledispenser`.
* `+special2` Same as `special2`, but also has `+rj` for Soldier and Pyro.
* `setinfo hold_grens` for press and hold `+grenade1` and `+grenade2`
* `setinfo hold_fiegn` for press and hold feigning
* `setinfo hold_detpack` for press and hold detpack
* `localinfo standardizedeathammo 1` server setting to make all backpack's dropped on death contain same ammo, regardless of victims ammo. If enabled defaults to 25 shells, 25 nails, 10 rockets, 50 cells. `localinfo deathammo_shells <number>` , `localinfo deathammo_nails <number>` , `localinfo deathammo_rockets <number>`, `localinfo deathammo_cells <number>` to modify these values 
* `localinfo splitbackpackmodels 1` server setting to have different visual models for backpack dropped on death ``progs/deathbag.mdl`` and discards ``progs/discard.mdl`` 
* `localinfo allowpracspawns 1` option for players to set a personal spawnpoint for practice. Players can then use commands `placepracspawn` and `removepracspawn`. Suicide  time  penalties are removed while allowpracspawns is enabled.
* Added ``localinfo nomapcycle 1`` to stop all the confusion.
* Option to configure hwguy armor `localinfo max_armor_hwguy 250`.
* ``setinfo keepcells <number>`` allows scout/med/pyro/eng/hwguy to include cells above ``<number>`` into discards. eg. an eng with 200 cells that has ``setinfo keepcells 50`` will discard 150 cells and keep 50. sold/spy/sniper/demo will throw all cells regardless of ``<number>`` (current behaviour). suggest players using this setinfo use scout/med/pyro/eng/hwguy class configs to set values for each class. ``localinfo nokeepcells 1`` - disables keepcells server-wide
* option to let engineer move while building `localinfo em on`.
* new brush ent ``trigger_jumper`` - an alias for ``trigger_push`` with spawnflags 16 - retains your x/y velocity, only boosting your z by the .speed value.
* new csqc command ``fo_menu_vote`` shows the list of maps available to vote. 
* ``vote_addmap``\``vote_removemap`` now work client-side
* new cvar for zut ``fo_hud_idle_alpha`` - sets the minimum transparency for flaginfo inactive items
* optional solid nail/shock grenades - localinfo solid_nailgren on (default on)
* localinfo nohitsounds 1 - disables hitsounds server-wide
* localinfo noreturn 1 - prevents goalitems from returning (will still return from lava)
* localinfo superaxe on/off - causes the axe to hit on all four attack frames (instead of only on 3rd frame)
* localinfo supermedikit on/off - causes the medikit to hit on all four attack frames (instead of only on 3rd frame)
* localinfo superspanner on/off - causes the spanner to hit on all four attack frames (instead of only on 3rd frame)
* localinfo superknife on/off - causes the knife to hit on all four attack frames (instead of only on 3rd frame)
* localinfo superknife_multihit on/off - controls whether multiple hits are allowed in a single attack
* scout has "new" flash grenades - localinfo fo_flash on (default on)
* ability to set client side min and max flash amounts - localinfo minflash x/localinfo maxflash x (number as a percentage - 1.5 = 150%)
* `cmd votemap`/`cmd showvotes`/`cmd listmaps` can now be used at any time and are part of the same system
* new server command `vote_removemap <name>` removes them
* new server command `vote_addmap <name> <desc> [mapgroup] [num_teams] [min_players] [max_players]` can be used to add maps to the below menu
* `cmd mapmenu` brings up a map selection menu, which can then either be voted for or changed immediately, provided you have adminpwd/rcon set up
* localinfo vote_threshold 0.5 will set the portion of players required to win a vote
* scout has "new" flash grenades - localinfo fo_flash on (default off)
* ability to set client side min and max flash amounts - setinfo minflash x/localinfo maxflash x (number as a percentage - 1.5 = 150%)
* localinfo quad_roles 1 enables the use of quad roles. Only works in quad mode: Blue gets the "attack" role first and Red gets the "defence" role.
    These roles can be configured by adding the "att_" and "def_" prefix to localinfo settings. Only detpipe_limit, respawn_time, gren limits and class limits are currently supported.
    Use `cmd showroles` to see the current configuration.
    The team with the "attack" role also has its flag hidden to avoid confusion.
* localinfo keep_teams 1/2 - keeps teams upon map change. 1 = same team. 2 = rotate teams
* hud commands: `fo_hud [element] [setting] [value]` lets you manually configure the extra hud elements' settings and `fo_hud_save` saves them.
* new spectator command `tracktarget` lets you track whoever you're pointing at
* `setinfo killsound 1/2/3` 1 enemies, 2 enemies and teammates, 3 enemies teammates and self
* `cmd forcebreak` - new admin command to end the map (and go to vote)
* `break` will vote to end the current map or recind your vote in a vote map
* localinfo vote_time 60 - seconds since the first vote is cast until voting is decided. 0 means majority vote only.
* localinfo vote_map <map> - map to designate for voting
* localinfo vote_style 1 - got to voting map after round is over instead of asking using menus, 2 - maps restart upon time/frag limit, but a `break` concensus will exit them to the votemap.
* CSQC - fo_main_menu main menu - either from menu.dat or engine
* CSQC - fo_menu_game in-game menu
* CSQC - fo_grentimer 0 - none, 1 - starts on server prime message, 2 - starts on prime button press
* CSQC - fo_grentimersound grentimer.wav
* CSQC - fo_grentimervolume 1
* CSQC - fo_specgrentimervolume -1 [ignored when -1]
* CSQC - fo_jumpvolume 1
* CSQC - fo_hud_reset resets HUD to defaults
* CSQC - fo_hud_reload reloads last-saved hud configuration
* CSQC - fo_hud_editor to move panels and save to config
* CSQC - fo_csjumpsounds 1 for client side jump sounds (not delayed by ping)
* `info_empblock` has a new field `goal_effects`. Setting it to 16 will prevent it from blocking emps if there is a wall between it and the explosion.
* New map point entity `info_empblock` with `t_length` field that specifies its radius of effect. An EMP explosion within a range of one will not go through walls.
* Server option for duelmode to allow draws on a double-ko `localinfo duel_allow_draw 1`/`localinfo dad 1` (default 1)
* Server option for duelmode to force a tie-break based on difference `localinfo duel_tie_break X`/`localinfo dtb X` (default 2)
* Server option for duelmode to force a countdown even if there is a double-kill `localinfo duel_draw_countdown 1`/`localinfo ddc 1` (default 1). If 0, both will respawn immediately upon the second player's death.
* Server option for duelmode to allow players to autoprime as soon as they are able `localinfo duel_autoprime 1`/`localinfo dap `. (default 0). Will only autoprime for players who have set `setinfo dap 1`
* Server option for duelmode to allow spawn protection `localinfo duel_spawn_guard 1`/`localinfo dsg 1` - it will not allow any fighting until both players have left the spawn.
* Server option for duelmode to print winner's health `localinfo duel_print_health 1`/`localinfo dph 1`
* Server option for duelmode to respawn with all grens `localinfo duel_all_grens 1`/`localinfo dag 1`
* Server option to remove packs in duel mode `localinfo duel_no_packs 1`/`localinfo dnp 1`
* Server setting for duelmode reset delay `localinfo drd 0.5` (`localinfo duel_reset_delay 0.5`)
* Admin option to enable duel mode. Will auto-reset/resup the not dead player. Main option - `localinfo duelmode on`
* Server option for making all walls block EMP. Off by default. `localinfo walls_block_emp 1` or `localinfo wbe 1`. (SPAWNFLAG_BLOCK_EMP 4096 will work regardless)
* Server option for setting detpack to solid (blocking). Off by default. `localinfo solid_detpack 1` or `localinfo sdp 1`.
* Server option for overriding map class restrictions (except civilian). `serverinfo override_mapclasses 1` or `serverinfo omc 1`.
* Option for maximum grenades for all classes. `localinfo max_gren1_<class> <number>`, short `localinfo mg1_<classnum> <number>`. Works for gren1s and gren2s. Eg `localinfo max_gren1_scout 0` to remove caltrops or `localinfo mg2_9 2` to reduce max EMPs to 2. Set to -1 for default.
* Option to fully restock player's clip and finish reload immediately if in progress. `localinfo stock_reload 1` (`localinfo srd 1`) will trigger only on flag capture (with stock_on_cap enabled). `2` will trigger whenever any tfgoal gives you the appropriate ammo.
* Option for statusbar flaginfo. `setinfo sbflaginfo 1` (default). Setting it to `2` will skip the tf tips on respawn and show flag info all the time.
* Admin system created to allow for easy setup of pub/clan/quad/duel games, kick players etc `localinfo adminpwd <password>` and `cmd adminpwd <password>; wait; adminmenu`
* Loc support added to server, show locations for dropped flag.
* Nailgrenades changed to "Shock/Laser Grenades" to lower spam/not stop bunnyhopping on hit (0 original, 1 laser, 2 burst). `localinfo nailgren_type 1` and `nginfo` in game for all configurable settings.
* Option for "blast medic". Secondary grenade is repaced with blast gren. It behaves like a concussion grenade, but doesn't apply a concussion effect. The blast medic moves at 280 units (instead of 320), but is not speed capped. `localinfo medic_type 1` (0 for normal, 1 for blast).
* Blast grenade velocity multiplier `localinfo blastgren_velocity_multiplier`. (default 1 is same as concussion grenade).
* Option for hitsounds (1 - enemies only, 2 - enemies and teammates). `setinfo hitsound 2`
* Option for medic to be immune from concussion effects. `localinfo medicnocuss on`.
* Option to adjust concussion grenade effect time in seconds. `localinfo cussgrentime n`.
* Increased nail velocity. Disable with `localinfo old_ng_velocity on`.
* Nailgun and Super-nailgun damage configurable with `localinfo ng_damage` and `localinfo sng_damage`.
* Keys and flags glow their colour.
* Option to adjust conussion grenade effect time in seconds. `localinfo cussgrentime`.
* Option to fully restock player on cap. `localinfo stock_on_cap on`.
* Option to strip ammo and grens from defenders within 1500 units of cap point when flag is capped. `localinfo cap_strip 1`.
* Option for packs to fully restock health and armor of player. `localinfo stockfull on`.
* Automatic server-side mvd recording of clan matches. Requires `localinfo serverdemo on`.
* Map vote (4 random maps + current map) during last few minutes of game (shown for newly spawned or toggled with /togglevote).
* Force early map vote using /votenext, /votetrick (trick maps) and /voterace (race maps).
* Force map switch to the voted map early using /forcenext.
* Auto ID feature (cf\_autoid 1 = on, 2 = teammates only, 3 = enemies only).
* Show friendly Sentry Gun health in /id for Engineers.
* Show max health and max armor in /id for Medics and Engineers.
* Grenade timers (disable with `setinfo nt 1` for no timers, or `setinfo nt 2` for no timer sound).
* Grenade slot switching (/grenswitch).
* Prime/throw grenades with one button (/gren1 and /gren2).
* Weapon slots (1-4) where 1 is always primary and 4 is always melee.
* Quick attack aliases (+quick1-4 will switch weapon and fire).
* Next/previous weapon (/weapprev and /weapnext).
* Last weapon (/weaplast).
* Remember current weapon and last weapon after dying.
* Reload all weapon slots using /reloadnext (one at a time).
* Drop hand grenade to ground if primed when dying.
* Drop grenades in backpack.
* Don't pick up unusable ammo from discarded backpacks (note: this only applies to /discarded backpacks).
* Don't telefrag teammates when spawning.
* Free class switch during first 10 seconds after spawning.
* Updated class help (bindings, aliases and settings) reachable with /classhelp.
* Dropping flag now possible on all maps using /dropflag.
* Allow team changing.
* Any non-valid impulse now closes the active menu.
* Option to allow a demoman to place a detpack while reloading his weapon `localinfo detreload on`
* localinfo server_sbflaginfo : 0 - disables sbar flaginfo, 1 enables it [default: 1]
* localinfo reverse_cap : 0 - normal gameplay, 1: you have to take your flag and capture in the enemy base [default: 0]
* localinfo engineer_move / em : 0 - normal gameplay, 1: engineers can move while building [default: 1]
* localinfo grenade_lockout / gl : Time in seconds grenade throw is locked out [default: 0.1]
* localinfo round_delay_time : interval time between rounds in quadmode - seconds [default: 30]
* localinfo max_gren2_soldier : maximum number of active nail/shock grenades (TF 2.8 = 3, OzTF = 1) [default: 3]
* localinfo distance_based_cuss_duration : on/off - enables cuss duration to be proportional to the distance from the explosion [default: off]
* lag compensation: see antilag.md for more information

== Removed ===
* Removed weapon messages for weapons without weapon modes.
* Removed bioweapon (merged into medikit).
* Removed grapple hook.
* Removed birthday mode.
* Removed engineer mortar (not used anymore).
* Removed bindings menu.
* Removed class help.

=== Fixed ===
* Don't allow building in prematch.
* Gas no longer goes through walls.
* Fixed the spamming weapon messages (e.g. Tranquiliser gun selected).
* Fixed the sentry gun menu to not close prematurely.
* Fixed broken ammo display.
* Fixed endless intermission bug.
* Fixed bug where players got stuck in intermission mode upon map change and hence could not respawn.
* Major code cleanup and rewrites.
* Team player count in team selection menu.
* Class player count (and class restrictions) in class selection menu.
* Changing teams is now allowed.
* Responsive menus and status bar thanks to rewritten menu/sbar code.
* Clip ammo in status bar ticks up during reload.
* Kill streak and personal cap count in status bar.
* Option to spawn with full ammo and armor.
* Map specific configurations (/fortress/cfg/maps/<mapname>.cfg).
* Major code cleanup and rewrites.

Scout
------
* New special ability "dash" will initiate a bunny hop at 540 speed.
* New Scanner menu where Scanner settings can be changed.
* Caltrop Canisters no longer "explode" in your hands.
* Remember Scanner status across deaths.
* `+special2` to toggle scanner.

Sniper
------
* Sniper Rifle range increased.
* Automatic sensitivity scaling while zoomed in.  Use the special button as a zoom button.  Use mouse wheel to adjust zoom while zoomed in.  Sniper Rifle now needs to be reloaded between shots.  

Soldier
------
* New command `+rj` (or `+special2`) to rocket jump.

Demolitions Man
------
* New detpack menu containing 5, 20, 50 and 255 second detpacks.
* Changed maximum detpipes allowed per team to 6 per demoman instead of 7 total.
* Decrease /detpipe cooldown to 0.5 seconds instead of 0.8.
* Stop detpacking by pressing last weapon bind.
* `+special2` to set 5 second detpack.

Combat Medic
------
* Healing aura that heals 5 hp every second to friendly players within range (120 units), only active when cells >= 50.
* Medikit now heals friendly targets to max health + 50, consuming all cells.
* Cells automatically regenerate at 10 cells per second.
* Bioweapon now does 7 damage per second to enemies, up from 7 damage per 3 seconds.

Heavy Weapons Guy
------
* Assault Cannon can now be fired while moving and while jumping.
* Accuracy of Assault Cannon decreased while moving.
* HWGuy can now be affected by concussion grenades while firing Assault Cannon.
* New class special that stops the Assault Cannon from firing and just keeps it spinning.
* Lowered volume for spinning Assault Cannon.

Pyro
------
* Add air-blast special.
* Rebalance weapons.
* New command +rj (or +special2) to rocket jump.

Spy
------
* Improved disguise menu.
* Auto-disguise (setinfo autodisguise 0/1/2).
* Change color and skin in one sequence.
* Last disguise (reachable through disguise menu or using /dlast alias).
* Stop disguising by pressing last weapon bind.
* New aliases for changing team color (`denemy` (if 2 teams), `dblue,` `dred,` `dyellow,` `dgreen,` `dlastspawn`).
* New aliases for changing skin (`dscout`, `dsniper`, `dsoldier`, etc).
* Build your own disguise aliases (e.g. `alias bsniper "dblue; wait; dsniper"` for blue sniper).
* Spy can now feign death in air.
* Spy now drops an empty backpack when feigning death.
* A fake death message (but relevant to current situation) is now shown when feigning death.
* `+special2` to disguise as last spawned enemy.

Engineer
------
* Sentry Gun status (health, ammo and level) shown in status bar.
* New Sentry Gun maintenance menu containing simply rotation.
* Upgrade/repair/restock Sentry Gun on spanner hit.
* Dispenser automatically stocks nearby team members.
* Dispenser restock rate increases with more players on team.
* Repair Dispenser on spanner hit.
* Dismantle Sentry Gun/Dispenser using build menu when standing close.
* Stop building by pressing last weapon key.
* Added message when Dispenser is destroyed.
* Added dismantle message to show how many cells were returned to Engineer.
* New command toggledispenser (or `+special`) to build or detonate dispenser.
* New command togglesentry (or `+special2`) to build or detonate sentry.
* Engineers can now only dismantle own buildings and rotate own Sentry Gun.
* `+special` to build or destroy dispenser.
* `+special2` to build or destroy sentry.


Development
------

Compile
------
Compile with [FTEQCC](http://fte.triptohell.info/downloads)

Ensure that `fteqcc64` is available in `$PATH` and:

```
make
```

Generate ctags
------
```
./generate_ctags.sh
```

Note: I got an error in vim:
```
E431: Format error in tags file "tags"
Before byte 364464
```
I just removed the one line at that byte address and it works fine now.

Note: Fixed in fteqcc 6010


List assets
-----

Only works in ssqc

```
fteqcc64 ./ssqc/progs.src -fdumpfilenames
```
