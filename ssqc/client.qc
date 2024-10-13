void (entity et, float f) player_pain;
void () player_stand1;

void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;

float modelindex_eyes;
float modelindex_player;
float modelindex_null;

float (entity pe_player) Spy_CheckArea;

void (entity player) TeamFortress_CheckTeamCheats;
void () TeamFortress_CheckforCheats;
void (entity Viewer, float pc, float rpc) TeamFortress_PrintClassName;
void () TeamFortress_RemoveTimers;
void (float Suicided) TeamFortress_SetupRespawn;

float (float pc) IsLegalClass;
void () SetupTeamEqualiser;
void () CeaseFire_think;

void () RemovePrimeTimers;
void () RemoveGasTimers;
void () RemoveGrenades;

void (entity eng) Engineer_RemoveBuildings;
void (entity eng) Engineer_QuietlyRemoveBuildings;

void (string halias, float himpulse1, float himpulse2) TeamFortress_Alias;

void (entity p) CheckAutoKick;
void (entity p) KickCheater;

void (entity p) TeamFortress_ExecClassScript;
void (entity p) TeamFortress_ExecMapScript;

void () PreMatch_Think;

void () DumpClanScores;

void (entity p) SetTeamName;

void () autokick_think;
float (float pf_team_no, float pf_class) CF_ClassIsRestricted;

void (entity AD) ParseTFDetect;
entity(float ino) Finditem;

void (entity Item, entity AP, entity Goal) tfgoalitem_GiveToPlayer;

void () CTF_FlagCheck;
void (entity pl) Sniper_ZoomReset;
void () StartTimer;
void () StopTimer;
void () StartQuadRound;
void (string cl_pwd) Admin_Check;
void () Admin_Aliases;
void () PreMatch_Message;
void () UpdateReadyStatus;
float () CheckAllPlayersReady;
string(float)TeamFortress_TeamGetColorString;
void (float tno, float scoretoadd) TeamFortress_TeamIncreaseScore;
float (entity pe, float tno, float skipclasscheck) TeamFortress_TeamSet_Options;
float (float tno) TeamFortress_TeamGetLives;
void () InitReverseCap;
float () RejoinWithTfId;
void () CreateTfIdAndJoin;
entity (entity e)TeamFortress_GetPracticeSpawn;
void () NextLevel;

void StopAssCan();
void Predict_InitPlayer(entity player);
void Predict_Destroy(entity player);

void SetSkinInfoFor(entity pov, entity target);

void () info_intermission =
{
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
};

void () info_player_intermission =
{
    self.classname = "info_intermission";
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
};

void () SetChangeParms = {
    if (self.health <= 0 && !cb_keepteams) {
        SetNewParms();
        return;
    }
    self.items &= ~(IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY |
                    IT_SUIT | IT_QUAD);
    if (self.health > 100)
        self.health = 100;
    if (self.health < 50)
        self.health = 50;

    parm1 = self.items;
    parm2 = self.health;
    parm3 = self.armorvalue;

    if (self.ammo_shells < 25)
        parm4 = 25;
    else
        parm4 = self.ammo_shells;

    parm5 = self.ammo_nails;
    parm6 = self.ammo_rockets;
    parm7 = self.ammo_cells;
    parm8 = SlotIndex(self.current_slot) + 1;
    parm9 = self.armortype * 100;
    parm10 = 0;
    parm11 = 0;
    parm12 = cb_keepteams?self.playerclass:0;
    parm13 = self.team_no;
    parm14 = 0;
    parm15 = self.is_admin;
};

void () SetNewParms = {
    parm1 = 0;
    parm2 = 100;
    parm3 = 0;
    parm4 = 25;
    parm5 = 0;
    parm6 = 0;
    parm6 = 0;
    parm8 = 1;
    parm9 = 0;
    parm10 = 0;
    parm11 = 0;
    parm12 = 0;
    parm13 = 0;
    parm14 = 0;
    parm15 = 0;
};

void () autoteam_think = {
    toggleflags = toggleflags | TFLAG_AUTOTEAM;
    dremove(self);
};

void () autokick_think = {
    self.owner.teamkills = 0;
    dremove(self);
};

string (entity ent, string ps_short, string ps_setting, string ps_default) FO_GetUserSettingString = {
    local string st;

    st = infokey(ent, ps_short);
    if (st == string_null) {
        st = infokey(ent, ps_setting);
        if (st == string_null) {
            st = ps_default;
        }
    }

    return st;
};

string FO_GetUserSettingRaw(entity ent, string ps_short, string ps_setting,
                            string ps_default) {
    string st = infokey(ent, ps_short);
    if (st == string_null) {
        st = infokey(ent, ps_setting);
        if (st == string_null) {
            st = ps_default;
        }
    }
    return st;
}

//if ent is world, return serverinfo, if ent is a player, return that client's setinfo key
float FO_GetUserSetting(entity ent, string ps_short, string ps_setting,
                        string ps_default) {
    string st = FO_GetUserSettingRaw(ent, ps_short, ps_setting, ps_default);

    switch (st)
    {
        case "on":
            return TRUE;
        case "off":
            return FALSE;
        default:
            return stof(st);
    }
};

string CF_GetSettingRaw(string ps_short, string ps_setting,
                        string ps_default) {
    return FO_GetUserSettingRaw(world, ps_short, ps_setting, ps_default);
};

float CF_GetSetting(string ps_short, string ps_setting, string ps_default) {
    return FO_GetUserSetting(world, ps_short, ps_setting, ps_default);
};

float FO_GetGrenadeSetting(string ps_short, string ps_setting, string ps_default) {
    local float max_gren_setting = CF_GetSetting(ps_short, ps_setting, ps_default);

    if (max_gren_setting == -1)
        return stof(ps_default);

    return max_gren_setting;
};

void InitPrematch()
{
    localcmd ("serverinfo status Standby\n");
    
    clan_scores_dumped = 0;
    game_locked = 0;
    cb_prematch = 1;
    local entity pm_message = spawn();
    pm_message.owner = world;
    pm_message.classname = "pmmessage";
    pm_message.think = PreMatch_Message;
    pm_message.nextthink = 1;
    
    game_locked = CF_GetSetting("lg", "locked_game", "off");
    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        UpdateClientPrematch(self, !cb_prematch);
        UpdateClientMOTD(self);
    }
}

typedef struct {
    int player_class;
    string short_max_gren1;
    string setting_max_gren1;
    float default_max_gren1;
    string short_max_gren2;
    string setting_max_gren2;
    float default_max_gren2;
} GrenConfig;

GrenConfig GrenConfigs[10] = {
    {0, "", "", 0, "", "", 0},
    {1, "mg1_1", "max_gren1_scout", PC_SCOUT_GRENADE_MAX_1, "mg2_1", "max_gren2_scout", PC_SCOUT_GRENADE_MAX_2},
    {2, "mg1_2", "max_gren1_sniper", PC_SNIPER_GRENADE_MAX_1, "mg2_2", "max_gren2_sniper", PC_SNIPER_GRENADE_MAX_2},
    {3, "mg1_3", "max_gren1_soldier", PC_SOLDIER_GRENADE_MAX_1, "mg2_3", "max_gren2_soldier", PC_SOLDIER_GRENADE_MAX_2},
    {4, "mg1_4", "max_gren1_demoman", PC_DEMOMAN_GRENADE_MAX_1, "mg2_4", "max_gren2_demoman", PC_DEMOMAN_GRENADE_MAX_2},
    {5, "mg1_5", "max_gren1_medic", PC_MEDIC_GRENADE_MAX_1, "mg2_5", "max_gren2_medic", PC_MEDIC_GRENADE_MAX_2},
    {6, "mg1_6", "max_gren1_hwguy", PC_HVYWEAP_GRENADE_MAX_1, "mg2_6", "max_gren2_hwguy", PC_HVYWEAP_GRENADE_MAX_2},
    {7, "mg1_7", "max_gren1_pyro", PC_PYRO_GRENADE_MAX_1, "mg2_7", "max_gren2_pyro", PC_PYRO_GRENADE_MAX_2},
    {8, "mg1_8", "max_gren1_spy", PC_SPY_GRENADE_MAX_1, "mg2_8", "max_gren2_spy", PC_SPY_GRENADE_MAX_2},
    {9, "mg1_9", "max_gren1_engineer", PC_ENGINEER_GRENADE_MAX_1, "mg2_9", "max_gren2_engineer", PC_ENGINEER_GRENADE_MAX_2}
};

static void SetAllRoles(float pc, float gren, float limit) {
    if (pc < 1 || pc > 9) return;

    GrenConfig config = GrenConfigs[pc];

    if (gren == 1) {
        limit = FO_GetGrenadeSetting(config.short_max_gren1,
                config.setting_max_gren1, ftos(limit));

        Role_None.gren1_limits[pc] = Role_Attack.gren1_limits[pc] =
            Role_Defence.gren1_limits[pc] = limit;
    } else if (gren == 2) {
        limit = FO_GetGrenadeSetting(config.short_max_gren2,
                config.setting_max_gren2, ftos(limit));

        Role_None.gren2_limits[pc] = Role_Attack.gren2_limits[pc] =
            Role_Defence.gren2_limits[pc] = limit;
    }
}

static float NB_UseMinPing() {
    if (ServerIsOCE())
        return FALSE;

    if (ServerRegion() == kRegionUnknown)
        return FALSE;  // e.g. random server, including LAN
    return TRUE;
}

void ActivateOrgGame() {
    disable_resup_gren = 2;  // No gren2 pickups

    drop_gren1 = 0;  // No grenades in backpacks

    int i;
    for (i = 1; i <= 9; i++) // 3 gren spawn
        SetAllRoles(i, 1, 3);

    SetAllRoles(4, 2, 1); // 1 mirv for demoman
    SetAllRoles(6, 2, 1); // 1 mirv for hwguy
    SetAllRoles(9, 2, 1); // 1 emp for engineer
    SetAllRoles(9, 1, 4); // 4 gren1 for engineer
    SetAllRoles(3, 1, 4); // 4 gren1 for soldier

    PC_PYRO_AIRBLAST_COOLDOWN = 10;
    PC_ENGINEER_GRENADE_TYPE_2_RANGE = 200;

    float use_new_cap = CF_GetSetting("nbcc", "new_balance_conc_cap", "0");
    if (use_new_cap == 4)
        use_new_cap = 1;
    else
        use_new_cap = 0;

    if (use_new_cap)
        fo_config.new_balance_flags |= NBF_CONC_NEW_CAP;

    if (CF_GetSetting("nbnc", "new_balance_no_cap", "0"))
        fo_config.new_balance_flags |= NBF_NO_CAP;

    if (NB_UseMinPing()) {
        if (fo_config.min_ping_ms < 50) // 50 min-ping
            localcmd("localinfo mpm 50");
    }
}

void () DecodeLevelParms = {
    local float fl;
    local string st;
    local entity ent;

    local entity te;

    if (serverflags)
        if (world.model == "maps/start.bsp")
            SetNewParms();

    self.items = parm1;
    self.health = parm2;
    self.armorvalue = parm3;
    self.ammo_shells = parm4;
    self.ammo_nails = parm5;
    self.ammo_rockets = parm6;
    self.ammo_cells = parm7;
    self.armortype = parm9 * 0.01;

    if (!(toggleflags & TFLAG_FIRSTENTRY)) {
        toggleflags = parm10;
        flagem_checked = 0;
        invis_only = 0;

        if (coop || !deathmatch)
            toggleflags = toggleflags | TFLAG_CLASS_PERSIST;

        if(nextmap == "") {
            nextmap = strzone(mapname);
        }
        
        ent = find(world, classname, "info_tfdetect");
        if (ent != world) {

            ParseTFDetect(ent);

            if ((number_of_teams <= 0) || (number_of_teams >= 5))
                number_of_teams = 4;

        } else {

            ent = find(world, classname, "info_player_team1");
            if ((ent != world) || (CTF_Map == 1)) {

                CTF_Map = TRUE;

                ent = spawn();
                ent.nextthink = time + 30;
                ent.think = CTF_FlagCheck;

                number_of_teams = 2;

            } else
                number_of_teams = 4;

            team1lives = -1;
            team2lives = -1;
            team3lives = -1;
            team4lives = -1;

            illegalclasses1 = 0;
            illegalclasses2 = 0;
            illegalclasses3 = 0;
            illegalclasses4 = 0;

            team1maxplayers = 100;
            team2maxplayers = 100;
            team3maxplayers = 100;
            team4maxplayers = 100;
            civilianteams = 0;
        }
        bprint(PRINT_HIGH, "Mapname: ", mapname, "\n");

        SetupTeamEqualiser();

        team1frags = 0;
        team2frags = 0;
        team3frags = 0;
        team4frags = 0;

        team1score = 0;
        team2score = 0;
        team3score = 0;
        team4score = 0;

        autokick_kills = 0;
        autokick_time = 0;

        cease_fire = 0;
        cs_paused = 0;

        toggleflags = toggleflags - (toggleflags & TFLAG_TEAMFRAGS);
        toggleflags = toggleflags - (toggleflags & TFLAG_CHEATCHECK);

        st = infokey(world, "temp1");
        toggleflags = (toggleflags | TFLAG_FIRSTENTRY) | stof(st);

        local float autoteam_time;
        autoteam_time = 30;

        clanbattle = CF_GetSetting("c", "clan", "off");
        quadmode = CF_GetSetting("quadmode", "quadmode", "off");
        duelmode = CF_GetSetting("duelmode", "duelmode", "off");

        disable_voting = clanbattle || quadmode;
        org_game = clanbattle || quadmode;

        rounds = CF_GetSetting("rounds","rounds","on");
        if (!rounds)
            rounds = -1;
        else if (rounds > 0)
            rounds = rounds + 1;

        if (clanbattle) {
            InitPrematch();
        } else {
            clanbattle = FALSE;
            localcmd ("serverinfo status Normal\n");
        }
        if (rounds) {
            st = infokey (world, "round_time");
            te = spawn ();
            te.owner = world;
            te.classname = "round";
            te.cnt = stof(st);
        }

        // automatically assign team [off]
        fl = CF_GetSetting("a", "autoteam", "off");
        if (fl > 1) {
            toggleflags = toggleflags | TFLAG_AUTOTEAM;
            autoteam_time = fl;
        } else if (fl) {
            toggleflags = toggleflags | TFLAG_AUTOTEAM;
        } else {
            toggleflags = toggleflags - (toggleflags & TFLAG_AUTOTEAM);
        }

        // auto kick team killers [4 tks per 60 seconds]
        autokick_kills = CF_GetSetting("akk", "autokick_kills", "4");
        autokick_time = CF_GetSetting("akt", "autokick_time", "60");

        // show team cap frags for all team members [off]
        if (CF_GetSetting("t", "teamfrags", "off")) {
            toggleflags = toggleflags | TFLAG_TEAMFRAGS;
        } else {
            toggleflags = toggleflags - (toggleflags & TFLAG_TEAMFRAGS);
        }

        // every team member carry the total frags for the team [off]
        if (CF_GetSetting("fts", "fullteamscore", "off")) {
            toggleflags = toggleflags | TFLAG_FULLTEAMSCORE;
        } else {
            toggleflags = toggleflags - (toggleflags & TFLAG_FULLTEAMSCORE);
        }
        
        // climbing spikes
        spurs_scout	= CF_GetSetting("spscout", "spurs_scout"	, "1");		// scouts allowed to spawn spurs
        spurs_spy	= CF_GetSetting("spspy", "spurs_spy"	 	, "1");		// spy allowed to spawn spurs
        spurs_engineer	= CF_GetSetting("speng", "spurs_engineer"	, "1");		// engineer allowed to spawn spurs
        spurs_duration	= CF_GetSetting("spd", 	"spurs_duration"	 	, "2");		// how long until self destroy
        spurs_boost	= CF_GetSetting("spb", "spurs_boost"	 	, "300");	// height gained from touch
        spurs_enabled	= CF_GetSetting("spe", "spurs_enabled"	 	, "0");		// 0 = OFF , 1 = useable by owner , 2 = useable by owners team, 3 = useable by both teams
        spurs_consume	= CF_GetSetting("spc", "spurs_consume" 	 	, "0");		// destroy on touch
        spurs_flag	= CF_GetSetting("spf", "spurs_flag" 		, "0");		// can climb with flag


        // nail gren types 0 = NGR_TYPE_NAIL, 1 = NGR_TYPE_LASER, 2 = NGR_TYPE_BURST
        nailgren_type = CF_GetSetting("ngt", "nailgren_type", ftos(NGR_TYPE_LASER));
        
        // medic types 0 = MEDIC_TYPE_DEFAULT, 1 = MEDIC_TYPE_BLAST
        medic_type = CF_GetSetting("mcgt", "medic_type", ftos(MEDIC_TYPE_DEFAULT));

        // how many rotations the nailgren does [2]
        lasergren_rotationcount = CF_GetSetting("lgrc", "lasergren_rotationcount", ftos(NGR_LASER_DEFAULT_ROTATIONCOUNT));
        
        // time each rotation takes [1]
        lasergren_rotationtime = CF_GetSetting("lgrt", "lasergren_rotationtime", ftos(NGR_LASER_DEFAULT_ROTATIONTIME));
        
        // damage [20]
        lasergren_damage = CF_GetSetting("lgd", "lasergren_damage", ftos(NGR_LASER_DEFAULT_DAMAGE));
        
        // think time for lightning, lower is smoother [0.1]
        lasergren_thinktime = CF_GetSetting("lgtt", "lasergren_thinktime", "0.01"); //ftos cuts off after 1 dec place, using ftos here would result in 0 and crash?
        
        // range of shaft [150]
        lasergren_range = CF_GetSetting("lgr", "lasergren_range", ftos(NGR_LASER_DEFAULT_RANGE));
        
        // how many bursts of nails [2]
        burstgren_count = CF_GetSetting("bgc", "burstgren_count", ftos(NGR_BURST_DEFAULT_COUNT));
        
        // time between each burst [0.7]
        burstgren_interval = CF_GetSetting("bgi", "burstgren_interval", ftos(NGR_BURST_DEFAULT_INTERVAL));
        
        // time before nail projectile destroys itself [0.3]
        burstgren_range = CF_GetSetting("bgr", "burstgren_range", ftos(NGR_BURST_DEFAULT_RANGE));

        // multiplier to blast gren velocity
        blastgren_velocity_multiplier = CF_GetSetting("bvm", "blastgren_velocity_multiplier", ftos(BLASTGREN_DEFAULT_VELOCITY_MULTIPLIER));

        // use old concussion, gas and flash grenades [off]
        old_grens = CF_GetSetting("og", "old_grens", "off");

        // use fortress one flash
        fo_flash = CF_GetSetting("ff", "fo_flash", "on");

        // drop primed hand grenades to ground when dying [on]
        drop_grenades = CF_GetSetting("dg", "drop_grenades", "on");

        // drop grenades in backpack upon death [on]
        drop_grenpack = CF_GetSetting("dgp", "drop_grenpack", "on");

        // maximum grenades type 1 to drop in backpack [1]
        drop_gren1 = CF_GetSetting("dg1", "drop_gren1", "1");

        // maximum grenades type 2 to drop in backpack [0]
        drop_gren2 = CF_GetSetting("dg2", "drop_gren2", "0");

        // show sentry gun health + misc extras in id string [on]
        id_extended = CF_GetSetting("ie", "id_extended", "on");

        // remember weapon across deaths [on]
        remember_weapon = CF_GetSetting("rw", "remember_weapon", "on");

        // pick up discardable ammo in discarded backpacks [off]
        discammo_pickup = CF_GetSetting("da", "discammo_pickup", "off");

        // use old tf style dropflag (map decides on/off) [off]
        old_dropflag = CF_GetSetting("odf", "old_dropflag", "off");

        // use old tf sniper range (shorter) [off]
        old_sniperrange = CF_GetSetting("os", "old_sniperrange", "off");

        // maximum amount of pipebombs per demoman [6]
        Role_None.detpipe_limit = CF_GetSetting("dl", "detpipe_limit", "6");

        // maximum amount of pipebombs in game [unlimited]
        detpipe_limit_world = CF_GetSetting("dw", "detpipe_limit_world", "-1");

        // set pipe cooldown time [0.5]
        pipecooldown_time = CF_GetSetting("pcdt", "pipecooldown_time", "0.5");

        // cooldown applies to all pipes [on]
        allpipes_cooldown = CF_GetSetting("apcd", "allpipes_cooldown", "on");

        // allow medic aura [on]
        medicaura = CF_GetSetting("ma", "medicaura", "on");

        // use old tf style bioweapon (less damage) [off]
        old_biodamage = CF_GetSetting("ob", "old_biodamage", "off");

        // use old tf style spanner (non-automated) [off]
        old_spanner = CF_GetSetting("os", "old_spanner", "off");

        // use old tf style dispenser (non-auto stocking) [off]
        old_dispenser = CF_GetSetting("od", "old_dispenser", "off");

        // enable flamethrower knockback [on]
        flame_knockback = CF_GetSetting("fk", "flame_knockback", "on");

        // allow building in water [on]
        build_water = CF_GetSetting("bw", "build_water", "on");

        // allow assault cannon lock mechanism [on]
        cannon_lock = CF_GetSetting("cl", "cannon_lock", "on");

        // allow assault cannon fire in air [on]
        cannon_air = CF_GetSetting("ca", "cannon_air", "on");

        // allow movement while firing assault cannon [on]
        cannon_move = CF_GetSetting("cm", "cannon_move", "on");

        // make assault cannon spin while moving [off]
        cannon_movespin = CF_GetSetting("cms", "cannon_movespin", "off");
        if (cannon_movespin) {
            cannon_move = TRUE; // required for this to work
        }

        // assault cannon accuracy (0 = cf, 1 = tf 2.8, 2 = tf 2.9) [0]
        cannon_accuracy = CF_GetSetting("cac", "cannon_accuracy", "0");

        // allow feign death in air [on]
        feign_air = CF_GetSetting("fa", "feign_air", "on");

        // drop an empty backpack when feigning death [on]
        feign_pack = CF_GetSetting("fp", "feign_pack", "on");

        // print fake death message when feigning death [on]
        feign_msg = CF_GetSetting("fm", "feign_msg", "on");

        // rate limit on feign
        feign_rate_limit = CF_GetSetting("frl", "feign_rate_limit", "1");

        // turn off spy [off]
        spy_off = CF_GetSetting("spy", "spy", "off");
	
        // Scout Scanner spike on / off
        scoutscanspike = CF_GetSetting("sss", "scoutscanspike", "on");

        // HwGuy Assault Cannon Range default as 0 to disable, and die time once range hit.
        asscanrange = CF_GetSetting("acr", "asscanrange", "0");
        asscanrangedie = CF_GetSetting("acrd", "asscanrangedie", "0");

        // force reload [on]
        force_reload = CF_GetSetting("fr", "forcereload", "on");

        // enable spy invisibility [off]
        invis_only = CF_GetSetting("s", "spyinvis", "off");

        // allow scout dash [on]
        scoutdash = CF_GetSetting("sd", "scoutdash", "on");

        // spawn with full ammo/armor [off]
        spawnfull = CF_GetSetting("sf", "spawnfull", "off");

        // stock full ammo/armor [on]
        stockfull = CF_GetSetting("stf", "stockfull", "on");

        // stock on cap [on]
        stock_on_cap = CF_GetSetting("soc", "stock_on_cap", "on");

        // stock on cap [off]
        cap_strip = CF_GetSetting("cs", "cap_strip", "off");

        // stock clip to full for reloading guns [on]
        stock_reload = CF_GetSetting("srd", "stock_reload", "on");

        // display class tips [on]
        classtips = CF_GetSetting("ct", "classtips", "on");

        // concussion grenade effect time [10]
        cussgrentime = CF_GetSetting("cgt", "cussgrentime", "10");

        // concussion grenade effect time proportional to distance from explosion
        distance_based_cuss_duration = CF_GetSetting("dbcd", "distance_based_cuss_duration", "off");

        // medic immune to concussion grenade effects [on]
        medicnocuss = CF_GetSetting("mnc", "medicnocuss", "on");

        // aim based concussion grenade effect
        fo_concuss = CF_GetSetting("foc", "fo_concuss", "0");
        if (fo_concuss & FOC_ON_DEF)
            fo_concuss |= foc_defaults;

        // Tie some of these other options together for convenience / other
        if (fo_concuss & FOC_DISTANCE)
            distance_based_cuss_duration = TRUE;
        if (fo_concuss & FOC_AFF_MED)
            medicnocuss = FALSE;

        // display sniper rifle power in status bar [on]
        sniperpower = CF_GetSetting("sp", "sniperpower", "on");

        // display build status in status bar [on]
        buildstatus = CF_GetSetting("bs", "buildstatus", "on");

        // use old init/max hp/armor [off]
        old_hp_armor = CF_GetSetting("oh", "old_hp_armor", "off");

        // configure max armor of heavy weapons guy [300]
        max_armor_hwguy = CF_GetSetting("mah", "max_armor_hwguy", ftos(PC_HVYWEAP_MAXARMOR));
        
        // Scout Scanner spike on / off
        scoutscanspike = CF_GetSetting("sss", "scoutscanspike", "on");
        
        // HwGuy Assault Cannon Range default as 0 to disable, and die time once range hit.
        asscanrange = CF_GetSetting("acr", "asscanrange", "0");
        asscanrangedie = CF_GetSetting("acrd", "asscanrangedie", "0");
        
        // CSQC projectiles
        fo_projectiles = CF_GetSetting("focp", "fo_csqc_projectiles", "on");

        // delay respawning by this many seconds [0]
        Role_None.respawn_delay_time = CF_GetSetting("rd", "respawn_delay", "0");
        if (Role_None.respawn_delay_time) {
            toggleflags = toggleflags | TFLAG_RESPAWNDELAY;
        }
        if ((toggleflags & TFLAG_RESPAWNDELAY) && !Role_None.respawn_delay_time) {
            Role_None.respawn_delay_time = RESPAWN_DELAY_TIME;
        }

        if (toggleflags & TFLAG_AUTOTEAM) {
            toggleflags = toggleflags - (toggleflags & TFLAG_AUTOTEAM);
            ent = spawn();
            ent.nextthink = time + autoteam_time;
            ent.think = autoteam_think;
        }

        // fortress one
        ng_damage = CF_GetSetting("ngd", "ng_damage", "9");
        sng_damage = CF_GetSetting("sngd", "sng_damage", "13");

        // allow axe to hit on any frame of animation
        superaxe = CF_GetSetting("ss", "superaxe", "on");

        // allow medikit to hit on any frame of animation
        supermedikit = CF_GetSetting("sm", "supermedikit", "on");

        // allow spanner to hit on any frame of animation
        superspanner = CF_GetSetting("ss", "superspanner", "off");

        // allow knife to hit on any frame of animation
        superknife = CF_GetSetting("sk", "superknife", "on");

        // allow knife to hit on every frame of animation
        superknife_multihit = CF_GetSetting("skmh", "superknife_multihit", "off");

        // impulse command queueing
        // ensures detpipe impulse isn't cleared at end of function
        impulse_queue = CF_GetSetting("impulsequeue", "impulse_queue", "off");

        // whitelists detpack impulses on the list of commands that you're allowed to use while reloading [off]
        detpack_when_reloading = CF_GetSetting("detreload", "detpack_while_reloading", "off");

        // ceasefire type - 0: default; 1: pause
        ceasefire_type = CF_GetSetting("ceasefiretype", "cft", "1");

        // enable flag model following the player who has it
        flag_follow = CF_GetSetting("flagfollow", "flag_follow", "on");

        // override map-set class restrictions [off]
        override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");

        Role_None.gren1_limits[0] = 0;
        Role_None.gren1_limits[1] = FO_GetGrenadeSetting("mg1_1", "max_gren1_scout", ftos(PC_SCOUT_GRENADE_MAX_1));
        Role_None.gren1_limits[2] = FO_GetGrenadeSetting("mg1_2", "max_gren1_sniper", ftos(PC_SNIPER_GRENADE_MAX_1));
        Role_None.gren1_limits[3] = FO_GetGrenadeSetting("mg1_3", "max_gren1_soldier", ftos(PC_SOLDIER_GRENADE_MAX_1));
        Role_None.gren1_limits[4] = FO_GetGrenadeSetting("mg1_4", "max_gren1_demoman", ftos(PC_DEMOMAN_GRENADE_MAX_1));
        Role_None.gren1_limits[5] = FO_GetGrenadeSetting("mg1_5", "max_gren1_medic", ftos(PC_MEDIC_GRENADE_MAX_1));
        Role_None.gren1_limits[6] = FO_GetGrenadeSetting("mg1_6", "max_gren1_hwguy", ftos(PC_HVYWEAP_GRENADE_MAX_1));
        Role_None.gren1_limits[7] = FO_GetGrenadeSetting("mg1_7", "max_gren1_pyro", ftos(PC_PYRO_GRENADE_MAX_1));
        Role_None.gren1_limits[8] = FO_GetGrenadeSetting("mg1_8", "max_gren1_spy", ftos(PC_SPY_GRENADE_MAX_1));
        Role_None.gren1_limits[9] = FO_GetGrenadeSetting("mg1_9", "max_gren1_engineer", ftos(PC_ENGINEER_GRENADE_MAX_1));

        // Maximum number of secondary grenades per class
        Role_None.gren2_limits[1] = FO_GetGrenadeSetting("mg2_1", "max_gren2_scout", ftos(PC_SCOUT_GRENADE_MAX_2));
        Role_None.gren2_limits[2] = FO_GetGrenadeSetting("mg2_2", "max_gren2_sniper", ftos(PC_SNIPER_GRENADE_MAX_2));
        Role_None.gren2_limits[3] = FO_GetGrenadeSetting("mg2_3", "max_gren2_soldier", ftos(PC_SOLDIER_GRENADE_MAX_2));
        Role_None.gren2_limits[4] = FO_GetGrenadeSetting("mg2_4", "max_gren2_demoman", ftos(PC_DEMOMAN_GRENADE_MAX_2));
        Role_None.gren2_limits[5] = FO_GetGrenadeSetting("mg2_5", "max_gren2_medic", ftos(PC_MEDIC_GRENADE_MAX_2));
        Role_None.gren2_limits[6] = FO_GetGrenadeSetting("mg2_6", "max_gren2_hwguy", ftos(PC_HVYWEAP_GRENADE_MAX_2));
        Role_None.gren2_limits[7] = FO_GetGrenadeSetting("mg2_7", "max_gren2_pyro", ftos(PC_PYRO_GRENADE_MAX_2));
        Role_None.gren2_limits[8] = FO_GetGrenadeSetting("mg2_8", "max_gren2_spy", ftos(PC_SPY_GRENADE_MAX_2));
        Role_None.gren2_limits[9] = FO_GetGrenadeSetting("mg2_9", "max_gren2_engineer", ftos(PC_ENGINEER_GRENADE_MAX_2));

        // disable resupply giving grenades (1-bit for gren1, 2-bit for gren2)
        disable_resup_gren = CF_GetSetting("drg", "disable_resup_gren", "0");

        // solid detpack toggle [0]
        solid_detpack = CF_GetSetting("sdp", "solid_detpack", "0");
        // All Walls Block EMP [0]
        walls_block_emp = CF_GetSetting("wbp", "walls_block_emp", "0");

        // new emp range and set damage values (so no dropammo to reduce)
        new_emp = CF_GetSetting("nemp", "new_emp", "1");

        fo_sentry_targeting = CF_GetSetting("fosgt", "fo_sentry_targ", "1");

        // For duelmode, how soon to reset the winning player (allows for double KOs)
        duel_reset_delay = CF_GetSetting("drd", "duel_reset_delay", "3.9");
        // remove packs in duelmode [1]
        duel_no_packs = CF_GetSetting("dnp", "duel_no_packs", "1");
        // spawn with all possible grenades [0]
        duel_all_grens = CF_GetSetting("dag", "duel_all_grens", "0");
        // After a duel round, print the winners' health stats
        round_winner_print_health = CF_GetSetting("dph", "duel_print_health", "0");
        // After respawning in duel mode, nobody shoots until
        // 0 - immediately
        // 1 - all players have moved away from spawn
        duel_spawn_guard = CF_GetSetting("dsg", "duel_spawn_guard", "1");
        // If 0, first to reach fraglimit wins
        // If 1, a double-ko (with delay) will end the match in a draw
        duel_allow_draw = CF_GetSetting("dad", "duel_allow_draw", "1");
        // Sets the number of frags difference required to break a tie after a double-ko upon fraglimit
        duel_tie_break = CF_GetSetting("dtb", "duel_tie_break", "2");
        // If 0, in case of a double-ko, reset immediately
        // If 1, round countdown always happens, even with a double-ko
        duel_draw_countdown = CF_GetSetting("ddc", "duel_draw_countdown", "1");
        // If 1, clients that have 'setinfo dap 1' will prime a gren as soon as they leave spawn
        duel_autoprime = CF_GetSetting("dap", "duel_autoprime", "0");
        
        //Proportion required to trigger a map change
        vote_threshold = CF_GetSetting("vt", "vote_threshold", "0.5");
        if(vote_threshold <= 0 || vote_threshold > 1) {
            dprint("localinfo vote_threshold was outside of valid range, defaulting to 0.5\n");
            vote_threshold = 0.5;
        }
        
        //default round interval for quadmode (seconds)
        round_delay_time = CF_GetSetting("round_delay_time", "rdt", "30");

        map_restart_time = CF_GetSetting("map_restart_Time", "mrt", "120");

        // if 1, quad round will not finish immediately if result is determined [off]
        play_to_completion = CF_GetSetting("ptc", "play_to_completion", "0");

        // enforces login
        loginRequired = CF_GetSetting("loginrequired", "logreq", "0");

        // login request https endpoint
        loginUrl = infokey(world, "loginurl");

        // server webpage address (required for login to work)
        webpageUrl = infokey(world, "webpageurl");

        if (loginRequired && (!loginUrl || !webpageUrl)) {
            loginRequired = 0;
        }

        // specify demo filehost address e.g. https://fortressone-demos.s3.amazonaws.com/sydney/staging/
        demo_files_address = FO_GetUserSettingString(world, "demo_files_address", "demofileaddy", "");

        // specify stats filehost address e.g. http://fortressone-stats.s3-ap-southeast-2.amazonaws.com/sydney/staging/
        stats_files_address = FO_GetUserSettingString(world, "stats_files_address", "statsfileaddy", "");

        // specify discord channel [""]
        discord_channel_id = infokey(world, "discord_channel_id");

        // fortress one flash time in seconds
        fo_flashtime = CF_GetSetting("ff", "fo_flashtime", "2");

        // health repair 
        fo_repair_ratio = CF_GetSetting("forep", "fo_repair_ratio", "2");

        // keep teams on map change [off]
        cb_keepteams = CF_GetSetting("kt", "keep_teams", "0");

        // use att/def roles in quad mode [off]
        quad_roles = CF_GetSetting("qr", "quad_roles", "0");

        LoadRole(&Role_Attack);
        LoadRole(&Role_Defence);
        InitTeamRoles();


        // whether the nailgren can be jumped off of
        solid_nailgren = CF_GetSetting("sng", "solid_nailgren", "1");

        // never return the goalitems [off]
        noreturn = CF_GetSetting("nr", "noreturn", "0");

        // disable hit sounds [off]
        nohitsounds = CF_GetSetting("nhs", "nohitsounds", "0");

        //test zutmode for testing stuff [off]
        zutmode = CF_GetSetting("zm", "zutmode", "1");

        // disable hit text [off]
        nohittext = CF_GetSetting("nht", "nohittext", "0");

        // disable setinfo keepcells [off]
        nokeepcells = CF_GetSetting("nkc", "nokeepcells", "0");

        // allow clients to place a personal practice spawn [off]
        allowpracspawns = CF_GetSetting("aps", "allowpracspawns", "0");

        // split backpack.mdl into deathbag.mdl and discard.mdl [on] (visual change only)
        splitbackpackmodels = CF_GetSetting("sbm", "splitbackpackmodels", "on");
	
	// standardize contents of backpack dropped on a players death [on]
	standardizedeathammo = CF_GetSetting("sda", "standardizedeathammo", "on");
	
	// if standardizedeathbags set to 1 use these settings instead of players ammo to fill bag on death 
	deathammo_shells = CF_GetSetting("das", "deathammo_shells", "25");
	deathammo_nails = CF_GetSetting("dan", "deathammo_nails", "25");
	deathammo_cells = CF_GetSetting("dac", "deathammo_cells", "50");
	deathammo_rockets = CF_GetSetting("dar", "deathammo_rockets", "10");

        // enable server-side flaginfo on statusbar [on]
        //        server_sbflaginfo = CF_GetSetting("ssbfi", "server_sbflaginfo", "1");

        reverse_cap = CF_GetSetting("rcap","reverse_cap", "0");

        if (reverse_cap) 
        {
           InitReverseCap();
        }

        engineer_move = CF_GetSetting("em","engineer_move", "1");
        grenade_lockout = CF_GetSetting("gl","grenade_lockout", "0");

        max_active_gren2_soldier = CF_GetSetting("mg2s","max_active_gren2_soldier", "3");

        st = infokey(world, "default");
        if (st == "on") {
            impulse_queue = FALSE;
            server_default = TRUE;
            old_grens = FALSE;
            drop_grenades = TRUE;
            drop_grenpack = TRUE;
            drop_gren1 = 1;
            drop_gren2 = 0;
            id_extended = TRUE;
            remember_weapon = TRUE;
            discammo_pickup = FALSE;
            old_dropflag = FALSE;
            scoutdash = TRUE;
            old_sniperrange = FALSE;
            Role_None.detpipe_limit = 6;
            detpipe_limit_world = -1;
            pipecooldown_time = 0.5;
            medicaura = TRUE;
            old_biodamage = FALSE;
            cannon_lock = TRUE;
            cannon_air = TRUE;
            cannon_move = TRUE;
            cannon_movespin = FALSE;
            cannon_accuracy = 0;
            flame_knockback = TRUE;
            old_spanner = FALSE;
            old_dispenser = FALSE;
            build_water = TRUE;
            feign_air = TRUE;
            feign_pack = TRUE;
            feign_msg = TRUE;
            spawnfull = TRUE;
            stockfull = TRUE;
            stock_on_cap = TRUE;
            cap_strip = FALSE;
            stock_reload = TRUE;
            classtips = TRUE;
            sniperpower = TRUE;
            buildstatus = TRUE;
            old_hp_armor = FALSE;
            superaxe = TRUE;
            supermedikit = TRUE;
            superspanner = FALSE;
            superknife = TRUE;
            superknife_multihit = FALSE;
            Role_None.gren1_limits[1] = PC_SCOUT_GRENADE_MAX_1;
            Role_None.gren1_limits[2] = PC_SNIPER_GRENADE_MAX_1;
            Role_None.gren1_limits[3] = PC_SOLDIER_GRENADE_MAX_1;
            Role_None.gren1_limits[4] = PC_DEMOMAN_GRENADE_MAX_1;
            Role_None.gren1_limits[5] = PC_MEDIC_GRENADE_MAX_1;
            Role_None.gren1_limits[6] = PC_HVYWEAP_GRENADE_MAX_1;
            Role_None.gren1_limits[7] = PC_PYRO_GRENADE_MAX_1;
            Role_None.gren1_limits[8] = PC_SPY_GRENADE_MAX_1;
            Role_None.gren1_limits[9] = PC_ENGINEER_GRENADE_MAX_1;
            Role_None.gren2_limits[1] = PC_SCOUT_GRENADE_MAX_2;
            Role_None.gren2_limits[2] = PC_SNIPER_GRENADE_MAX_2;
            Role_None.gren2_limits[3] = PC_SOLDIER_GRENADE_MAX_2;
            Role_None.gren2_limits[4] = PC_DEMOMAN_GRENADE_MAX_2;
            Role_None.gren2_limits[5] = PC_MEDIC_GRENADE_MAX_2;
            Role_None.gren2_limits[6] = PC_HVYWEAP_GRENADE_MAX_2;
            Role_None.gren2_limits[7] = PC_PYRO_GRENADE_MAX_2;
            Role_None.gren2_limits[8] = PC_SPY_GRENADE_MAX_2;
            Role_None.gren2_limits[9] = PC_ENGINEER_GRENADE_MAX_2;
            solid_detpack = FALSE;
            walls_block_emp = FALSE;
            solid_nailgren = FALSE;
            scoutscanspike = TRUE;
        }

        st = infokey(world, "faithful");
        if (st == "on") {
            impulse_queue = FALSE;
            server_faithful = TRUE;
            drop_grenades = FALSE;
            drop_grenpack = FALSE;
            drop_gren1 = 0;
            drop_gren2 = 0;
            id_extended = FALSE;
            remember_weapon = FALSE;
            discammo_pickup = TRUE;
            old_dropflag = TRUE;
            scoutdash = FALSE;
            old_sniperrange = TRUE;
            Role_None.detpipe_limit = 7;
            detpipe_limit_world = 7;
            pipecooldown_time = 0.8;
            medicaura = FALSE;
            old_biodamage = TRUE;
            cannon_lock = FALSE;
            cannon_air = TRUE;
            cannon_move = TRUE;
            cannon_movespin = TRUE;
            cannon_accuracy = 1;
            flame_knockback = FALSE;
            old_spanner = TRUE;
            old_dispenser = TRUE;
            build_water = FALSE;
            feign_air = FALSE;
            feign_pack = FALSE;
            feign_msg = FALSE;
            spawnfull = FALSE;
            stockfull = FALSE;
            stock_on_cap = FALSE;
            cap_strip = FALSE;
            stock_reload = FALSE;
            classtips = FALSE;
            sniperpower = FALSE;
            buildstatus = FALSE;
            old_hp_armor = TRUE;
            superaxe = FALSE;
            supermedikit = FALSE;
            superspanner = FALSE;
            superknife = FALSE;
            superknife_multihit = FALSE;
            Role_None.gren1_limits[1] = 4;
            Role_None.gren1_limits[2] = 4;
            Role_None.gren1_limits[3] = 4;
            Role_None.gren1_limits[4] = 4;
            Role_None.gren1_limits[5] = 4;
            Role_None.gren1_limits[6] = 4;
            Role_None.gren1_limits[7] = 4;
            Role_None.gren1_limits[8] = 4;
            Role_None.gren1_limits[9] = 4;
            Role_None.gren2_limits[1] = 3;
            Role_None.gren2_limits[2] = 4;
            Role_None.gren2_limits[3] = 3;
            Role_None.gren2_limits[4] = 4;
            Role_None.gren2_limits[5] = 3;
            Role_None.gren2_limits[6] = 4;
            Role_None.gren2_limits[7] = 4;
            Role_None.gren2_limits[8] = 4;
            Role_None.gren2_limits[9] = 4;
            solid_detpack = TRUE;
            walls_block_emp = FALSE;
            solid_nailgren = TRUE;
            scoutscanspike = FALSE;
            fo_config.old_ng_rof = TRUE;
        }

        st = infokey(world, "huetf");
        if (st == "on") {
            server_huetf = TRUE;
            impulse_queue = TRUE;
            flag_follow = FALSE;
            ng_damage = 18;
            sng_damage = 26;
            superaxe = FALSE;
            supermedikit = FALSE;
            superspanner = FALSE;
            superknife = FALSE;
            superknife_multihit = FALSE;
            scoutdash = FALSE;
            fo_flash = FALSE;
            nailgren_type = NGR_TYPE_NAIL;
            medic_type = MEDIC_TYPE_DEFAULT;
            Role_None.detpipe_limit = 7;
            detpipe_limit_world = 7;
            medicaura = FALSE;
            medicnocuss = FALSE;
            distance_based_cuss_duration = FALSE;
            drop_grenades = FALSE;
            drop_grenpack = FALSE;
            drop_gren1 = 0;
            drop_gren2 = 0;
            cussgrentime = 19;
            spawnfull = FALSE;
            stockfull = FALSE;
            stock_on_cap = FALSE;
            cap_strip = FALSE;
            stock_reload = FALSE;
            classtips = FALSE;
            nohitsounds = TRUE;
            nohittext = TRUE;	//damned luddites
            zutmode = FALSE;
            detpack_when_reloading = TRUE;
            old_hp_armor = TRUE;
            //server_sbflaginfo = FALSE;
            localcmd("localinfo server_sbflaginfo 0\n");
            solid_detpack = TRUE;
            walls_block_emp = FALSE;
            Role_None.gren2_limits[1] = 3;
            Role_None.gren2_limits[3] = 2;
            Role_None.gren2_limits[4] = 4;
            Role_None.gren2_limits[5] = 3;
            Role_None.gren2_limits[8] = 3;
            max_active_gren2_soldier = 1;
            round_delay_time = 10;
            fo_config.old_ng_rof = TRUE;
        }

        // Must be after we've set up conditional options (e.g. hwguy reload).
        FO_Weapons_Init();
        InitFppProjectiles();
    }

    if (parm11)
        self.tfstate = parm11;
    if (!self.team_no && cb_keepteams && clanbattle && parm13 && parm13 > 0 && parm13 <= number_of_teams) {
        // 1 = same, 2+ = rotate
        if(cb_keepteams == 1) {
            //self.team_no = parm13;
            TeamFortress_TeamSet(parm13);
        } else {
            //self.team_no = (parm13 % number_of_teams) + 1;
            TeamFortress_TeamSet((parm13 % number_of_teams) + 1);
        }
        self.lives = TeamFortress_TeamGetLives(parm13);
        //Menu_Class(0);
    }
    if (self.playerclass == 0 && self.team_no) {
        TeamFortress_ChangeClass(parm12);
    }
    if (parm15)
        self.is_admin = parm15;

/*
    local entity p = find(world, classname, "player");
    while (p != world) {
        if (p.netname != "") {
            if(infokeyf(p, INFOKEY_P_CSQCACTIVE)) {
                UpdateClientMOTD(p);
            }
        }
        p = find(p, classname, "player");
    }
*/

    // Overrides other settings.
    new_balance = CF_GetSetting("new_balance", "new_balance", "1");
    // mirror current state into desired state bit
    new_balance |= (new_balance << 1);

    if (org_game)  // This used to depend on new balance
        ActivateOrgGame();

};

entity() FindIntermission =
{
    local entity spot;
    local float cyc;

    spot = find(world, classname, "info_intermission");
    if (spot)
        return (spot);

    spot = find(world, classname, "info_player_start");
    if (spot)
        return (spot);

    spot = find(world, classname, "info_player_deathmatch");
    if (spot) {
        cyc = random() * 6;
        while (cyc > 1) {
            spot = find(spot, classname, "info_player_deathmatch");
            if (!spot)
                spot = find(spot, classname, "info_player_deathmatch");
            cyc = cyc - 1;
        }
        return (spot);
    }

    objerror("FindIntermission: no spot");
    return (world);
};

entity(entity start_point) FindNextIntermission =
{
    local entity spot;

    if (deathmatch) {

        if ((start_point.classname == "info_intermission") ||
            (start_point == world)) {

            spot = find(start_point, classname, "info_intermission");
            if (spot)
                return (spot);
            else
                start_point = world;
        }
        if ((start_point.classname == "info_player_deathmatch") ||
            (start_point == world)) {

            spot = find(start_point, classname, "info_player_deathmatch");
            if (spot)
                return (spot);
        }
        spot = find(world, classname, "info_intermission");
        if (spot)
            return (spot);

        spot = find(world, classname, "info_player_deathmatch");
        if (spot)
            return (spot);

    } else {
        spot = find(world, classname, "info_player_start");
        if (spot)
            return (spot);
    }
    return (FindIntermission());
};

void () TF_MovePlayer = {
    local entity place;

    place = FindNextIntermission(self.observer_list);
    self.observer_list = place;
    setorigin(self, place.origin + '0 0 1');
    self.angles = place.angles;
    self.fixangle = 1;
};

void () GotoNextMap = {
    if (vote_result != string_null && (nextmap == string_null || nextmap == ""))
        nextmap = strzone(vote_result);

    if (nextmap != mapname || vote_result != string_null) {
        changelevel(nextmap);
        already_chosen_map = time;
    }

    strunzone(nextmap);

    // avoid endless intermission by restarting the current map
    if ((already_chosen_map + 10) < time) {
        changelevel(mapname);
        already_chosen_map = time;
    }

    intermission_running = 0;
};

void () ExitIntermission = {
    dprint("Exiting intermission...\n");
    if (deathmatch) {
        dprint("Exit intermission in deathmatch\n");
        GotoNextMap();
        return;
    }

    intermission_exittime = time + 1;

    dprint("Exit intermission\n");
    GotoNextMap();
};

void () IntermissionThink = {
    if (time < intermission_exittime)
        return;
    if ((!self.button0 && !self.button1) && !self.button2)
        return;
    if (logfilehandle > 0)
        fclose(logfilehandle);
    dprint("Intermission think\n");
    GotoNextMap();
};

void () PutClientInIntermission =
{
    local entity pos;

    pos = FindIntermission ();

    if (pos) {
        WriteByte (MSG_ONE, SVC_CDTRACK);
        WriteByte (MSG_ONE, 3);

        WriteByte (MSG_ONE, SVC_INTERMISSION);
        WriteCoord (MSG_ONE, pos.origin_x);
        WriteCoord (MSG_ONE, pos.origin_y);
        WriteCoord (MSG_ONE, pos.origin_z);
        WriteAngle (MSG_ONE, pos.mangle_x);
        WriteAngle (MSG_ONE, pos.mangle_y);
        WriteAngle (MSG_ONE, pos.mangle_z);
    }

    self.takedamage = DAMAGE_NO;
    self.solid = SOLID_NOT;
    self.movetype = MOVETYPE_NONE;
    self.modelindex = 0;
}

void () execute_changelevel = {
    local entity pos;

    intermission_running = 1;
    intermission_exittime = time + 5;

    pos = FindIntermission();

    WriteByte(MSG_ALL, SVC_CDTRACK);
    WriteByte(MSG_ALL, 3);

    WriteByte(MSG_ALL, SVC_INTERMISSION);
    WriteCoord(MSG_ALL, pos.origin_x);
    WriteCoord(MSG_ALL, pos.origin_y);
    WriteCoord(MSG_ALL, pos.origin_z);
    WriteAngle(MSG_ALL, pos.mangle_x);
    WriteAngle(MSG_ALL, pos.mangle_y);
    WriteAngle(MSG_ALL, pos.mangle_z);

    local string nextmapstring = nextmap;
    if((vote_result == string_null || vote_result == "") && (nextmap == string_null || nextmap == "")) {
        local string vm = FO_GetUserSettingString(world, "vote_map", "votemap", "se2");
        vote_style = CF_GetSetting("vs", "vote_style", "2");
        if (vote_style || votemode == 2){
            if(votemode == 1 && vote_result && vote_result != vm) {
                localcmd ("localinfo votemode off\n");
                //changelevel(vote_result);
            } 
            if((vote_style & 1 && (vote_result == vm || vote_result == "")) || votemode == 2) {
                vote_result = vm;
                if(!(vote_style & 4)) {
                     localcmd ("localinfo votemode on\n");
                 }
                //changelevel(FO_GetUserSettingString(world, "vote_map", "votemap", "se2"));
            } 
            if(vote_style & 2 && (vote_result == vm || vote_result == "")) {
                vote_result = mapname;
            }
        }
        //if(!votemode) {
        //    vote_result = FO_GetUserSettingString(world, "vote_map", "votemap", "se2");
        //    nextmapstring = strcat(vote_result, " \b(voting)\b");
        //}
    }
    if(vote_result != string_null && vote_result != "" && vote_result != mapname) {
        nextmapstring = vote_result;
        nextmap = vote_result;
    }


    other = find(world, classname, "player");
    while (other != world) {
        if (nextmapstring != string_null && nextmapstring != "")
            sprint(other, PRINT_HIGH, "Next up: ", nextmapstring, "\n");
        other.takedamage = DAMAGE_NO;
        other.solid = SOLID_NOT;
        other.movetype = MOVETYPE_NONE;
        other.modelindex = 0;
        other.caps = 0;
        other = find(other, classname, "player");
    }
    if (!clan_scores_dumped) {
        DumpClanScores();
        MapEndSequence();
        clan_scores_dumped = 1;
    }
};

void () changelevel_touch = {
    if (other.classname != "player")
        return;

    if ((cvar("samelevel") == 2) ||
        ((cvar("samelevel") == 3) && (mapname != "start")))
        return;

    bprint(PRINT_HIGH, other.netname, " exited the level\n");

    nextmap = strzone(self.map);
    SUB_UseTargets();

    if ((self.spawnflags & 1) && (deathmatch == 0)) {
        GotoNextMap();
        return;
    }
    self.touch = SUB_Null;
    self.think = execute_changelevel;
    self.nextthink = time + 0.1;
};

void () trigger_changelevel = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    if (!self.map)
        objerror("changelevel trigger doesn't have map");

    InitTrigger();
    self.touch = changelevel_touch;
};

void () set_suicide_frame;

void () respawn = {
    if (self.has_disconnected == 1)
        return;
    if (cease_fire)
        return;
    if (votemode && vote_anarchy_mode) {
        return;
    }

    if (coop) {
        AddToBodyQueue(self);
        setspawnparms(self);
        PutClientInServer();
    } else if (deathmatch) {
        AddToBodyQueue(self);
        SetNewParms();
        PutClientInServer();
    } else
        localcmd("restart\n");
};

float () CloseToSpawnPoint = {
    local entity spot = nil;
    local entity te = nil;
    local float i;
    string searchstr;
    searchstr = "";

    switch (self.team_no)
    {
        case 1:
            searchstr = "ts1";
            break;
        case 2:
            searchstr = "ts2";
            break;
        case 3:
            searchstr = "ts3";
            break;
        case 4:
            searchstr = "ts4";
            break;
        default:
            return 0;
    }

    spot = find(world, team_str_home, searchstr);
    for(i = 1; i < 30; i++) {
        te = findradius(spot.origin, 185);
        while (te != world) {
            if (te == self)
                return 1;
            te = te.chain;
        }
        spot = find(spot, team_str_home, searchstr);
    }

    return 0;
};

void () RemovePlayerOwnedEnts = {
    local entity te;

    te = find(world, classname, "pipebomb");
    while (te) {
        if (te.owner == self) {
            dremove(te);
        }
        te = find(te, classname, "pipebomb");
    }
    TeamFortress_RemoveTimers();
    RemoveGasTimers();
    Engineer_QuietlyRemoveBuildings(self);
    TeamFortress_RemovePracticeSpawn(self);
    te = find(world, classname, "detpack");
    while (te) {
        if (te.owner == self) {
            if (te.is_disarming == 1) {
                TeamFortress_SetSpeed(te.enemy);
                dremove(te.oldenemy);
                dremove(te.observer_list);
            }
            dremove(te);
            te = world;
        }
        te = find(te, classname, "detpack");
    }
    te = find(world, classname, "countdown_timer");
    while (te) {
        if (te.owner == self) {
            if (te.is_disarming == 1) {
                TeamFortress_SetSpeed(te.enemy);
                dremove(te.oldenemy);
                dremove(te.observer_list);
            }
            dremove(te);
            te = world;
        }
        te = find(te, classname, "countdown_timer");
    }
    RemoveGrenades();
    if (clanbattle && (self.tf_id != 0)) {
        te = spawn();
        te.classname = "ghost";
        te.tf_id = self.tf_id;
        te.team_no = self.team_no;
        te.frags = self.frags;
        te.real_frags = self.real_frags;
        te.netname = self.netname;
        te.playerclass = self.playerclass;
        if (self.tfstate & TFSTATE_RANDOMPC) {
            te.tfstate = TFSTATE_RANDOMPC;
        }
    }
    RemoveDeadBody(self);
}

void (string cn) RemoveAllEntsByClassname = {
    local entity te = find(world, classname, cn);
    while (te) {
        dremove(te);
        te = find(te, classname, cn);
    }
}

void () spawn_guard_think = {
    local entity te, oldself;
    local float no_fire = 0;
    te = find(world, classname, "player");
	while (te != world) {
		if(!te.has_disconnected) {
            if(te.duel_guarded != world) {
                if(vlen(te.duel_guarded.origin - te.origin) > 200) {
                    te.duel_guarded = world;
                    te.invincible_finished = 0;
                    te.invincible_time = 0;
                    te.effects = 0;
                    bprint(PRINT_HIGH, te.netname, " \bhas left the spawn!\b\n");
                    FO_Sound(world, CHAN_AUTO, "misc/basekey.wav", 1, ATTN_NONE);
                } else {
                    no_fire++;
                }
            }
        }
		te = find (te, classname, "player");
	}
    self.nextthink = time + 0.1;
	if(!no_fire) {
        no_fire_mode = 0;
        bprint(PRINT_HIGH, "\bFIGHT!\b\n");
        FO_Sound(world, CHAN_AUTO, "fight.wav", 1, ATTN_NONE);
        self.think = SUB_Remove;
        if(duel_autoprime) {
            te = find(world, classname, "player");
            while (te != world) {
                if(!te.has_disconnected && infokey(te, "dap") == "1") {
                    oldself = self;
                    self = te;
                    TeamFortress_PrimeGrenade(1, FALSE);
                    self = oldself;
                }
                te = find (te, classname, "player");
            }
        }
    }
};

void () StartSpawnGuard = {
    no_fire_mode = 1;
    entity reset_timer = spawn();
    reset_timer.classname = "spawn_guard_check";
    reset_timer.think = spawn_guard_think;
    reset_timer.nextthink = time + 0.1;
    bprint(PRINT_HIGH, "\bLeave the spawn to begin!\b\n");
    FO_Sound(world, CHAN_AUTO, "come_get.wav", 1, ATTN_NONE);
};

void () DuelFinish = {
    FO_Sound(world, CHAN_AUTO, "boss1/sight1.wav", 1, ATTN_NONE);
    NextLevel();
    RemovePrimeTimers();
    RemoveGrenades();
};

void (entity winner) DuelWin = {
    bprint(PRINT_HIGH, "\sDuel over!\s ", winner.netname,  " \sis victorious!\s\n");
    DuelFinish();
};


void () ResetPlayers = {
    local entity te, oldself, reset_timer, winner = world;
    local float teamsleft;
    local float maxscore = 0, nextscore = 0;
    no_fire_mode = 0;

    reset_timer = find(world, classname, "duel_reset_timer");
    while (reset_timer != world) {
        oldself = reset_timer;
        reset_timer = find (reset_timer, classname, "duel_reset_timer");
        dremove(oldself);
    }
    if(cb_prematch)
        return;

    TeamFortress_TeamShowScores(2);

    teamsleft = CountRemainingTeams();
    if(teamsleft == 1) {
        if(round_winner) {
            bprint(PRINT_HIGH, round_winner.netname, " of team ", TeamFortress_TeamGetColorString(round_winner.team_no) ,", wins the round!\n");
            if(round_winner_print_health && round_winner.health == round_winner.max_health && round_winner.armorvalue == round_winner.maxarmor ) {
                bprint(PRINT_HIGH, "\t\t\t \sFLAWLESS VICTORY\s \t\t\t\n");
            }
        } else {
            bprint(PRINT_HIGH, TeamFortress_TeamGetColorString(round_winner_team), " team wins the round!\n");
        }
        TeamFortress_TeamIncreaseScore(round_winner_team, 1);
    } else if(teamsleft == 0) {
        bprint(PRINT_HIGH, "Everybody died! It's a draw.\n");
    }
    
    RemoveAllEntsByClassname("proj_bullet");
    RemoveAllEntsByClassname("proj_rocket");
    RemoveAllEntsByClassname("grenade");
    RemoveAllEntsByClassname("pipebomb");
    RemoveAllEntsByClassname("spike");
    RemoveAllEntsByClassname("railslug");
    RemoveAllEntsByClassname("pyro_flame");
    RemoveAllEntsByClassname("fire");
    RemoveAllEntsByClassname("flamerflame");
    RemoveAllEntsByClassname("pyro_rocket");
    RemoveAllEntsByClassname("proj_tranq");
   
    te = find(world, classname, "player");
	while (te != world) {
		if(!te.has_disconnected) {
            if(te.health > 0) {
                stuffcmd(te, "f_respawn\n");
                if(round_winner_print_health) {
                    bprint(PRINT_HIGH, te.netname, ": \sHealth:\s ", ftos(te.health), " \sArmour:\s " , ftos(te.armorvalue), "\n");
                }
            }
            oldself = self;
            self = te;
            if(duelmode && duel_allow_draw && fraglimit) {
                //if(duel_tie_break > 0) {
                    if(maxscore <= te.frags) {
                        nextscore = maxscore;
                        maxscore = te.frags;
                        winner = te;
                    }
                //} else if (te.frags >= fraglimit) {
                //    DuelWin(te);
                //    return;
                //}
            }
            RemovePlayerOwnedEnts();
            setspawnparms(self);
            PutClientInServer();
            self.respawn_time = 0;
            self = oldself;
        }
		te = find (te, classname, "player");
	}
    if(duelmode && duel_allow_draw) {
        if(fraglimit) {
            if(duel_tie_break > 0) {
                if(maxscore == fraglimit && maxscore == nextscore) {
                    bprint(PRINT_HIGH, "\sFraglimit reached, but the fight's not over!\s\n\sYou must reach\s ", ftos(duel_tie_break), " \sfrag difference to win!\s\n");
                    FO_Sound(world, CHAN_AUTO, "items/suit.wav", 1, ATTN_NONE);
                }
                if((maxscore >= fraglimit && nextscore < fraglimit) || (maxscore > fraglimit && maxscore >= (nextscore + duel_tie_break) )) {
                    DuelWin(winner);
                    return;
                }
            } else {
                if(maxscore >= fraglimit) {
                    if(maxscore == nextscore) {
                        bprint(PRINT_HIGH, "\sDuel over! It is a\s DRAW\s!\s\n");
                        DuelFinish();
                    } else {
                        DuelWin(winner);
                    }
                    return;
                }
            }
        }
    }
    
    if(duelmode && duel_spawn_guard) {
        StartSpawnGuard();
        precache_sound("get_some.wav");
        precache_sound("fight.wav");
    }

}

float () CountRemainingTeams = {
    local float teamsleft, teamflags, playersleft;
    local entity te, lastplayer;

    lastplayer = world;
    teamflags = 0;
    playersleft = 0;

    te = find(world, classname, "player");
    while (te != world) {
        if(!te.has_disconnected && te.health > 0) {
            teamflags = teamflags | pow(2, te.team_no);
            lastplayer = te;
            playersleft++;
        }
        te = find (te, classname, "player");
    }
    teamsleft = 0;
    if(teamflags & 2) {
        teamsleft++;
    }
    if(teamflags & 4) {
        teamsleft++;
    }
    if(teamflags & 8) {
        teamsleft++;
    }
    if(teamflags & 16) {
        teamsleft++;
    }
    round_winner_team = 0;
    round_winner = world;
    if(teamsleft == 1) {
        if(playersleft == 1) {
            //bprint(PRINT_HIGH, lastplayer.netname, " of team ", TeamFortress_TeamGetColorString(lastplayer.team_no) ,", wins the round!\n");
            round_winner = lastplayer;
            round_winner_team = lastplayer.team_no;
        } else {
            //bprint(PRINT_HIGH, TeamFortress_TeamGetColorString(lastplayer.team_no), " team wins the round!\n");
            round_winner_team = lastplayer.team_no;
        }
    //} else if(teamsleft == 0) {
        //bprint(PRINT_HIGH, "Everybody died! It's a draw.\n");
    }
    return teamsleft;
}

void () ClientKill = {
    local entity te;
    local float timeleft;

    if (self.has_disconnected == 1)
        return;
    if (self.deadflag)
        return;
    if(!votemode) {
        if (self.playerclass == PC_UNDEFINED)
            return;

        if (self.suicide_time > time && self.clientkillforce == 0) {
            timeleft = self.suicide_time - time;
            sprint(self, PRINT_HIGH, "You have to wait ", ftos(ceil(timeleft)), " more seconds to suicide\n");
            return;
        }
    }

    Sniper_ZoomReset(self);

    set_suicide_frame();
    self.modelindex = modelindex_player;

    self.tfstate |= TFSTATE_NO_WEAPON;
    self.view_ofs = '0 0 -8';
    self.movetype = MOVETYPE_NONE;
    TeamFortress_RemoveTimers();

    // players can't suicide again for 10 seconds
    if(!allowpracspawns)
    	self.suicide_time = time + 5 + random() * 5;
    else
    	self.suicide_time = time;

    if (self.clientkillfree == 1 && !self.has_throwngren && (self.has_changedteam || self.has_changedclass)) {
        TeamFortress_SetupRespawn(FALSE);
    } else {
        bprint(PRINT_MEDIUM, self.netname, " suicides\n");

        // If infected, give the medic a frag
        if (self.tfstate & TFSTATE_INFECTED) {
            te = find(world, classname, "timer");
            while (te) {
                if ((te.owner == self) && (te.think == BioInfection_Decay)) {
                    logfrag(te, self);
                    TF_AddFrags(te.enemy, 1);
                }
                te = find(te, classname, "timer");
            }
        } else
            logfrag(self, self);

        TF_AddFrags(self, -1);
        TeamFortress_SetupRespawn(TRUE);
        self.th_die();
    }

    self.clientkillforce = 0;
    self.clientkillfree = 0;
    self.health = -1;
    self.deadflag = DEAD_RESPAWNABLE;
    self.tfstate = self.tfstate | TFSTATE_RESPAWN_READY;
    self.takedamage = 0;
    if(duelmode && !cb_prematch) {
        if(CountRemainingTeams() < 2) {
            ResetPlayersWithCountdown();
        }
    }
    if(votemode && vote_anarchy_mode) {
        CheckVoting();
    }
};

entity lastspawn_team1;
entity lastspawn_team2;
entity lastspawn_team3;
entity lastspawn_team4;

float (vector orig) CheckSpawnPoint =
{
    local entity at_spot;

    at_spot = findradius(orig, 60);
    while (at_spot != world) {
        if ((at_spot.classname == "player") && (at_spot.deadflag == 0)) {
            if (at_spot.team_no == self.team_no)
                return 0;
            else
                return 1;
        }
        at_spot = at_spot.chain;
    }

    return 1;
};

entity(float team_num) FindTeamSpawnPoint =
{
    local entity spot;
    local float spot_found;
    local float attempts;

    if (team_num == 1) {
        spot = lastspawn_team1;
        attempts = 0;
        while (1) {
            attempts = attempts + 1;

            spot = find(spot, team_str_home, "ts1");
            if (spot == world)
                spot = find(world, team_str_home, "ts1");
            if (spot == world)
                return (world);

            spot_found = CheckSpawnPoint(spot.origin);
            if (!Activated(spot, self))
                spot_found = 0;
            if (spot_found || (attempts >= 30)) {
                lastspawn_team1 = spot;
                return (spot);
            }
        }
    } else if (team_num == 2) {
        spot = lastspawn_team2;
        attempts = 0;
        while (1) {
            attempts = attempts + 1;
            spot = find(spot, team_str_home, "ts2");
            if (spot == world)
                spot = find(world, team_str_home, "ts2");
            if (spot == world)
                return (world);
            spot_found = CheckSpawnPoint(spot.origin);
            if (!Activated(spot, self))
                spot_found = 0;
            if (spot_found || (attempts >= 30)) {
                lastspawn_team2 = spot;
                return (spot);
            }
        }
    } else if (team_num == 3) {
        spot = lastspawn_team3;
        attempts = 0;
        while (1) {
            attempts = attempts + 1;
            spot = find(spot, team_str_home, "ts3");
            if (spot == world)
                spot = find(world, team_str_home, "ts3");
            if (spot == world)
                return (world);
            spot_found = CheckSpawnPoint(spot.origin);
            if (!Activated(spot, self))
                spot_found = 0;
            if (spot_found || (attempts >= 30)) {
                lastspawn_team3 = spot;
                return (spot);
            }
        }
    } else if (team_num == 4) {
        spot = lastspawn_team4;
        attempts = 0;
        while (1) {
            attempts = attempts + 1;
            spot = find(spot, team_str_home, "ts4");
            if (spot == world)
                spot = find(world, team_str_home, "ts4");
            if (spot == world)
                return (world);
            spot_found = CheckSpawnPoint(spot.origin);
            if (!Activated(spot, self))
                spot_found = 0;
            if (spot_found || (attempts >= 30)) {
                lastspawn_team4 = spot;
                return (spot);
            }
        }
    }
    return (world);
};

void (entity e) ValidateUser = {
};

entity () SelectSpawnPoint = {
    if (allowpracspawns && self != world)
    {
        local entity spot2;
        spot2 = TeamFortress_GetPracticeSpawn(self);

        if(spot2 != world)
            return spot2;
    }
    
    local entity spot;
    local float attempts;

    if (self.spawn_at_last_spawn_spot == 1) {
        self.spawn_at_last_spawn_spot = 0;
        return(self.last_spawn_spot);
    }

    if (self.team_no != 0) {
        spot = FindTeamSpawnPoint(self.team_no);
        if (spot != world) {
            self.last_spawn_spot = spot;
            return (spot);
        }
    }
    if (coop) {
        lastspawn = find(lastspawn, classname, "info_player_coop");
        if (lastspawn == world) {
            lastspawn = find(world, classname, "info_player_coop");
        }
        if (lastspawn != world) {
            self.last_spawn_spot = lastspawn;
            return (lastspawn);
        }
    } else {
        if (deathmatch) {
            spot = find(lastspawn, classname, "info_player_deathmatch");
            if (spot == world) {
                spot = find(world, classname, "info_player_deathmatch");
            }
            attempts = 0;
            while ((spot != world) && (attempts < 100)) {
                attempts = attempts + 1;
                if (CheckSpawnPoint(spot.origin) || (attempts >= 10)) {
                    lastspawn = spot;
                    self.last_spawn_spot = spot;
                    return (spot);
                }
                spot = find(spot, classname, "info_player_deathmatch");
                if (spot == world) {
                    spot =
                        find(world, classname, "info_player_deathmatch");
                }
            }
        }
    }
    if (serverflags) {
        spot = find(world, classname, "info_player_start2");
        if (spot) {
            self.last_spawn_spot = spot;
            return (spot);
        }
    }
    spot = find(world, classname, "info_player_start");
    if (!spot) {
        spot = find(world, classname, "info_player_teamspawn");
    }

    if (!spot) {
        error("PutClientInServer: no info_player_start on level\n");
    }
    self.last_spawn_spot = spot;
    return (spot);
};

void () PlayerDie;
void () TeamFortress_SetHealth;
void () TeamFortress_SetEquipment;
void () TeamFortress_StartTimers;
void () player_touch;


void (entity p) SetVoteParams = {
    if (!(toggleflags & TFLAG_FIRSTENTRY)) {
        toggleflags = parm10;
        toggleflags = (toggleflags | TFLAG_FIRSTENTRY);

        //Proportion required to trigger a map change
        vote_threshold = CF_GetSetting("vt", "vote_threshold", "0.5");
        if(vote_threshold <= 0 || vote_threshold > 1) {
            dprint("localinfo vote_threshold was outside of valid range, defaulting to 0.5\n");
            vote_threshold = 0.5;
        }
    }

    sprint(p, PRINT_HIGH, "Voting time! Use \bcmd listmaps\b to see available maps\n");
    sprint(p, PRINT_HIGH, "Use \bcmd votemap <mapname>\b to state your preference\n");
    sprint(p, PRINT_HIGH, "Use \bcmd showvotes\b to see the current voting status\n");
    p.items = 0;
    p.health = 100;
    p.armorvalue = 0;
    p.ammo_shells = 0;
    p.ammo_nails = 0;
    p.ammo_rockets = 0;
    p.ammo_cells = 0;
    p.armortype = 0;
    // why?
    p.team_no = 0;
    p.playerclass = 0;
    p.flags |= FL_ONGROUND;
    p.skin = rint(random() * 9); //self.playerclass;
    stuffcmd(p, strcat("color ", ftos(rint(random() * 12)), " ", ftos(rint(random() * 12)), "\n"));

    p.takedamage = DAMAGE_AIM; //DAMAGE_YES;
    p.attack_finished = self.client_time + 0.3;
    p.th_pain = player_pain;
    p.th_die = PlayerDie;
    p.height = 0;
    Sniper_ZoomReset(p);

    p.deadflag = 0;
    p.pausetime = 0;

    TeamFortress_StartTimers();

    local entity spot = SelectSpawnPoint();

    p.observer_list = spot;
    p.origin = spot.origin + '0 0 1';
    p.angles = spot.angles;
    p.fixangle = 1;
    
    FO_SetModel(p, "progs/player.mdl");
    p.modelindex = modelindex_player;
    setsize(p, VEC_HULL_MIN, VEC_HULL_MAX);
    
    p.view_ofs = '0 0 22';
    p.velocity = '0 0 0';
    player_stand1();

    makevectors(p.angles);
    spawn_tfog(p.origin + v_forward * 20);
}

void (entity player, string field, float fieldval) CheckSetInfoKey =
{
    float val;
    val = infokeyf(player, field);

    // TODO - this isn't needed on later versions of fte, we can spam set the value
    if (val != fieldval)
        forceinfokey(player, field, ftos(fieldval));
};

void (entity player) UpdateScoreboardInfo = {

    CheckSetInfoKey(player, "afflicted", player.afflicted);
    CheckSetInfoKey(player, "teamafflicted", player.teamafflicted);
    CheckSetInfoKey(player, "damagegiven", player.damagegiven);
    CheckSetInfoKey(player, "damagetaken", player.damagetaken);
    CheckSetInfoKey(player, "kills", player.kills);
    CheckSetInfoKey(player, "teamkills", player.sbteamkills);
    CheckSetInfoKey(player, "deaths", player.deaths);
    CheckSetInfoKey(player, "caps", player.caps);
    CheckSetInfoKey(player, "touches", player.touches);
    CheckSetInfoKey(player, "team_no", player.team_no);
    CheckSetInfoKey(player, "playerclass", player.playerclass);
    CheckSetInfoKey(player, "ready", player.stat_flags & PLAYER_READY);
};

void (float all_dimensions) SetDimensions = {
    if (all_dimensions)
    {
        self.dimension_seen = DMN_NOFLASH;
        self.tfstate &= ~TFSTATE_FLASHED;

        switch (self.team_no)
        {
            case TEAM_BLUE:
                self.dimension_see = DMN_NOFLASH | DMN_TEAMBLUE;
                break;
            case TEAM_RED:
                self.dimension_see = DMN_NOFLASH | DMN_TEAMRED;
                break;
            case TEAM_YELL:
                self.dimension_see = DMN_NOFLASH | DMN_TEAMYELL;
                break;
            case TEAM_GREN:
                self.dimension_see = DMN_NOFLASH | DMN_TEAMGREN;
                break;
            default:
                self.dimension_see = DMN_NOFLASH;
                break;
        }
    }
};

void () PutClientInServer = {
    if (fo_login_required && self.fo_login == string_null)
        UpdateClient_Login(self);

    local float oldclass;
    local entity spot;
    local entity te;

    self.spawn_gen += 1;

    self.touch = player_touch;
    self.classname = "player";
    self.health = 100;
    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_WALK;

    self.show_hostile = 0;
    self.FlashTime = 0;
    self.max_health = 100;
    self.flags = FL_CLIENT;

    self.air_finished = time + 12;
    self.dmg = 2;
    self.super_damage_finished = 0;
    self.radsuit_finished = 0;
    self.invisible_finished = 0;
    self.invincible_finished = 0;
    self.effects = 0;
    self.invincible_time = 0;
    self.spawn_time = time;
    self.vote_close = 0;
    self.has_throwngren = FALSE;
    self.saveme_time = 0;
    self.display_tip = 0;
    self.tip_type = 0;
    self.feign_next_damage = 0;
    self.conc_state.mag = 0;

    FO_InstantReloadAllWeapons(self);

    // Only need initial init here.
    // For hwguy we rotate the seed value, each seed generates many random nums.
    for (int i = 0; i < PRNG_NUM_STATES; i++)
        self.prng_base[i] = 65535 * random();
    self.primed_gren_exp = 0;

    self.immune_to_check = time + 10;
    SetDimensions(TRUE);
    self.special_next = 0;

    setmodel(self, string_null);
    modelindex_null = self.modelindex;

    setmodel(self, "progs/eyes.mdl");
    modelindex_eyes = self.modelindex;

    setmodel(self, "progs/player.mdl");
    modelindex_player = self.modelindex;

    // TODO: There's a bug here where self.team_no is set to 0 immediately after joining team
    /* if(votemode) { */
    /*     SetVoteParams(self); */
    /* } */

    if(no_fire_mode) {
        return;
    }

    // remove prime timers to avoid getting an old grenade in your face
    te = find(world, classname, "primetimer");
    while (te != world) {
        if (te.owner == self)
            dremove(te);
        te = find(te, classname, "primetimer");
    }

    DecodeLevelParms();

    Predict_InitPlayer(self);

    if (self.playerclass != PC_CIVILIAN && TeamFortress_TeamIsCivilian(self.team_no)) {
        TeamFortress_ChangeClass(11);
    }

    int prev_playerclass = self.playerclass;

    if (deathmatch == 3) {
        if(self.nextpc != self.playerclass) {
            if (self.playerclass != 0) {
                local float timeplayed = gametime - self.classtime;
                LogEventChangeClass(self, self.playerclass, self.nextpc, timeplayed);
                self.classtime = gametime; 
            }
            self.playerclass = self.nextpc;
        }
        if (self.playerclass == PC_RANDOM)
            self.tfstate = self.tfstate | TFSTATE_RANDOMPC;
        else {
            self.tfstate =
                self.tfstate - (self.tfstate & TFSTATE_RANDOMPC);
            TeamFortress_ExecClassScript(self);
        }
    }

    /*
        if ((!IsLegalClass(self.playerclass) && !override_mapclasses) || CF_ClassIsRestricted(self.team_no, self.playerclass)) {
            TeamFortress_ChangeClass(0);
            Menu_Class(0);
        }
    */

    if (self.tfstate & TFSTATE_RANDOMPC) {
        oldclass = self.playerclass;
        self.playerclass = 1 + floor(random() * (10 - 1));
        while ((!IsLegalClass(self.playerclass) && !override_mapclasses) ||
               (self.playerclass == oldclass)
               || CF_ClassIsRestricted(self.team_no, self.playerclass)) {
            self.playerclass = 1 + floor(random() * (10 - 1));
        }
        self.tfstate = TFSTATE_RANDOMPC;
        TeamFortress_ExecClassScript(self);
    } else
        self.tfstate = 0;

    if (self.playerclass != PC_ENGINEER)
        Engineer_RemoveBuildings(self);

    self.skin = self.playerclass;

    self.takedamage = 2;

    TeamFortress_PrintClassName(self, self.playerclass,
                                self.tfstate & TFSTATE_RANDOMPC);

    self.attack_finished = 0;  // Allow below to change weapon freely.
    TeamFortress_SetEquipment();
    TeamFortress_SetHealth();
    TeamFortress_SetSpeed(self);
    TeamFortress_SetSkin(self);
    TeamFortress_StartTimers();

    if(quadmode && quad_roles) {
        sprint(self, PRINT_HIGH, "\sRole:\s ", GetTeamRole(self.team_no).name, "\n");
    }

    stuffcmd(self, "v_idlescale 0\n");
    stuffcmd(self, "v_cshift; wait; bf\n");
    SetTeamName(self);

    self.attack_finished = self.client_time + 0.3;
    self.th_pain = player_pain;
    self.th_die = PlayerDie;
    self.height = 0;
    Sniper_ZoomReset(self);

    self.deadflag = 0;
    self.pausetime = 0;

    spot = SelectSpawnPoint();

    self.observer_list = spot;
    self.origin = spot.origin + '0 0 1';
    self.angles = spot.angles;
    self.fixangle = 1;

    if (self.playerclass != 0)
        spawn_tdeath(self.origin, self);

    if ((spot.classname == "info_player_teamspawn") &&
        (!cb_prematch)) {

        if (spot.items != 0) {
            te = Finditem(spot.items);
            if (te)
                tfgoalitem_GiveToPlayer(te, self, self);
            if (!(spot.goal_activation & TFGA_TOUCH))
                spot.items = 0;
        }
        if (spot.message) {
            CenterPrint(self, spot.message);
            if (!(spot.goal_activation & 2))
                spot.message = string_null;
        }
        if (spot.activate_goal_no != 0) {
            te = Findgoal(spot.activate_goal_no);
            if (te)
                AttemptToActivate(te, self, spot);
        }
        if (spot.goal_effects == 1) {
            spot.classname = "deadpoint";
            spot.team_str_home = string_null;
            spot.nextthink = time + 1;
            spot.think = SUB_Remove;
        }
    }

    setmodel(self, string_null);
    modelindex_null = self.modelindex;

    setmodel(self, "progs/eyes.mdl");
    modelindex_eyes = self.modelindex;

    setmodel(self, "progs/player.mdl");
    modelindex_player = self.modelindex;

    if (self.playerclass == 0) {
        self.modelindex = modelindex_null;
        self.menu_input = nil;
    }

    setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
    self.view_ofs = '0 0 22';
    self.velocity = '0 0 0';
    player_stand1();

    if (deathmatch || coop) {
        makevectors(self.angles);
        if (self.playerclass != 0)
            spawn_tfog(self.origin + v_forward * 20);
    }

    if (stof(infokey(world, "rj")) != 0)
        rj = stof(infokey(world, "rj"));
    else
        rj = 1;

    if (cease_fire) {
        sprint(self, PRINT_HIGH, "\n\nCease fire mode\n");
        self.immune_to_check = time + 10;
        self.tfstate |= TFSTATE_CANT_MOVE;
    }

    if (self.playerclass == 0 && self.team_no > 0) {
        Menu_Class(0);
    }

    if(duelmode && duel_spawn_guard && self.team_no && self.playerclass) {
        self.duel_guarded = spot;
        self.invincible_finished = time + 666;
    }

    local float autodisguise = FO_GetUserSetting(self, "autodisguise", "ad", "off");
    if (self.playerclass == PC_SPY) {
        switch(autodisguise) {
            case 1:
                FO_Spy_DisguiseLastSpawned(self, FALSE);
                break;
            case 2:
                FO_Spy_DisguiseLast(self, FALSE);
                break;
        }
    }

    if(self.playerclass == PC_SCOUT && self.ScannerOn == 1) {
        te = spawn();
        te.nextthink = time + 2;
        te.think = TeamFortress_Scan;
        te.owner = self;
        te.classname = "timer";
        te.netname = "scanner";
        sprint(self, PRINT_HIGH, "Scanner on\n");
        self.ScannerOn = 1;

        if (!(self.tf_items_flags & NIT_SCANNER_ENEMY))
            self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_ENEMY;
    }

    // Activate medic aura by default when changing to class and off
    if (self.playerclass == PC_MEDIC && prev_playerclass != PC_MEDIC &&
        !self.aura_active)
        CF_Medic_AuraToggle();

    UpdateReadyStatus();
};

//void () info_player_start = {
//    if (CheckExistence() == FALSE) {
//        dremove(self);
//        return;
//    }
//};

void () info_player_start2 = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
};

void () testplayerstart = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
};

void () info_player_deathmatch = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
};

void () info_player_coop = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
};

void (entity c) PrintClientScore = {
    if ((c.frags > -10) && (c.frags < 0))
        bprint(PRINT_MEDIUM, " ");
    else if (c.frags >= 0) {
        if (c.frags < 100)
            bprint(PRINT_MEDIUM, " ");
        if (c.frags < 10)
            bprint(PRINT_MEDIUM, " ");
    }
    bprint(PRINT_MEDIUM, ftos(c.frags), " ", c.netname, "\n");
};

void () DumpScore = {
    local entity e;
    local entity sort;
    local entity walk;

    if (world.chain) {
        error("DumpScore: world.chain is set");
    }
    e = find(world, classname, "player");
    sort = world;
    while (e) {
        if (!sort) {
            sort = e;
            e.chain = world;
        } else if (e.frags > sort.frags) {
            e.chain = sort;
            sort = e;
        } else {
            walk = sort;
            do {
                if (!walk.chain) {
                    e.chain = world;
                    walk.chain = e;
                } else if (walk.chain.frags < e.frags) {
                    e.chain = walk.chain;
                    walk.chain = e;
                } else
                    walk = walk.chain;
            } while (walk.chain != e);
        }
        e = find(e, classname, "player");
    }
    bprint(PRINT_MEDIUM, "\n");
    while (sort) {
        PrintClientScore(sort);
        sort = sort.chain;
    }
    bprint(PRINT_MEDIUM, "\n");
};

float already_cycled;

void () NextLevel = {
    local entity o;

    if (already_cycled)
        return;
    
    already_cycled = 1;
    vote_style = CF_GetSetting("vs", "vote_style", "1");
    local string vm = FO_GetUserSettingString(world, "vote_map", "votemap", "se2");
    if (vote_style || votemode == 2){
        if(votemode == 1 && nextmap && nextmap != vm) {
            localcmd ("localinfo votemode off\n");
            //changelevel(vote_result);
        } else if(vote_style & 1 || votemode == 2) {
            nextmap = vm;
            if(!(vote_style & 4)) {
                localcmd ("localinfo votemode on\n");
            }
            //changelevel(FO_GetUserSettingString(world, "vote_map", "votemap", "se2"));
        } else if (nextmap == "" || nextmap == string_null) {
            nextmap = mapname;
        }
    }
    o = spawn();
    o.map = nextmap;
    o.think = execute_changelevel;
    o.nextthink = time + 0.1;
};

void () CheckRules = {
    if (!clanbattle)
    {
        if ((timelimit && (time >= timelimit)))
        {
            NextLevel();
            RemovePrimeTimers();
            RemoveGrenades();
        }
    }
    if ((fraglimit && (self.frags >= fraglimit)))
    {
        NextLevel();
        RemovePrimeTimers();
        RemoveGrenades();
    }
};

void () PlayerDeathThink = {
    local float forward;

    if (self.flags & FL_ONGROUND) {
        forward = vlen(self.velocity);
        forward = forward - 20;
        if (forward <= 0)
            self.velocity = '0 0 0';
        else
            self.velocity = forward * normalize(self.velocity);
    }
    if (self.deadflag == DEAD_DEAD) {
        if (self.button2 || self.button1 || self.button0)
            return;
        self.deadflag = DEAD_RESPAWNABLE;
        self.tfstate &= ~TFSTATE_RESPAWN_READY;
        return;
    }
    if ((!self.button2 && !self.button1) && !self.button0) {
        if (self.tfstate & TFSTATE_RESPAWN_READY) {
            if (self.respawn_time <= time) {
                self.button0 = 0;
                self.button1 = 0;
                self.button2 = 0;
                respawn();
            }
        }
        return;
    } else {
        self.tfstate = self.tfstate | TFSTATE_RESPAWN_READY;
        if (self.respawn_time <= time) {
            self.button0 = 0;
            self.button1 = 0;
            self.button2 = 0;
            respawn();
        }
        return;
    }
};

void player_asscan_down1();

enum ConcMode {
    CONC_IDLESCALE,
    CONC_CLASSIC,
    CONC_AIM,
};

ConcMode GetConcMode() {
    if (old_grens)
        return CONC_IDLESCALE;
    else if (fo_concuss)
        return CONC_AIM;
    else
        return CONC_CLASSIC;
}

entity FindConcTimer(entity player);

void () PlayerJump = {
    local entity te;
    local float stumble;

    if (self.has_disconnected == 1)
        return;
    if (self.flags & FL_WATERJUMP)
        return;


    if (self.waterlevel >= 2) {
        if (self.watertype == CONTENT_WATER)
            self.velocity_z = 100;
        else if (self.watertype == CONTENT_SLIME)
            self.velocity_z = 80;
        else
            self.velocity_z = 50;

        if (self.swim_flag < time) {
            self.swim_flag = time + 1;
            if (random() < 0.5)
                FO_Sound(self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
            else
                FO_Sound(self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
        }

        if (self.tfstate & TFSTATE_AC_FIRING)
            StopAssCan();

        return;
    }

    if (!(self.flags & FL_ONGROUND))
        return;

    if (!(self.flags & FL_JUMPRELEASED))
        return;

    self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
    self.button2 = 0;

    NB_ConcCapAction(self, self.playerclass, &self.tfstate,
                     time, &self.conc_cap_time, kLand);
    FO_Sound(self, CHAN_AUTO, "player/plyrjmp8.wav", 1, ATTN_NORM);

    if (!cannon_air && self.tfstate & TFSTATE_AC_FIRING) {
        if (self.antispam_cannon_air < time) {
            sprint(self, PRINT_MEDIUM, "You cannot fire the assault cannon without your feet on the ground...\n");
            self.antispam_cannon_air = time + 3;
        }
        StopAssCan();
    }

    if (GetConcMode() == CONC_CLASSIC && (self.tfstate & TFSTATE_CONC))
        Conc_Jump(&self.conc_state, self);
};

.float dmgtime;

void () WaterMove = {
    if (self.movetype == MOVETYPE_NOCLIP)
        return;
    if (self.health < 0)
        return;

    if (self.waterlevel != 3) {
        if (self.air_finished < time) {
            FO_Sound(self, CHAN_VOICE, "player/gasp2.wav", 1, 1);
        } else if (self.air_finished < (time + 9)) {
            FO_Sound(self, CHAN_VOICE, "player/gasp1.wav", 1, 1);
        }
        self.air_finished = time + 12;
        self.dmg = 2;
    } else if (self.air_finished < time) {
        if (self.pain_finished < time) {
            self.dmg = self.dmg + 2;
            if (self.dmg > 15)
                self.dmg = 10;
            TF_T_Damage(self, world, world, self.dmg, 1, 0);
            self.pain_finished = time + 1;
        }
    }

    if (!self.waterlevel) {
        if (self.flags & FL_INWATER) {
            FO_Sound(self, CHAN_BODY, "misc/outwater.wav", 1, 1);
            self.flags = self.flags - FL_INWATER;
        }
        return;
    }
    if (self.watertype == CONTENT_LAVA) {
        if (self.dmgtime < time) {
            if(votemode && !vote_anarchy_mode) {
                respawn();
            } else {
                if (self.radsuit_finished > time)
                    self.dmgtime = time + 1;
                else
                    self.dmgtime = time + 0.2;
                TF_T_Damage(self, world, world, (10 * self.waterlevel), 0, 16);
            }
        }
    } else if (self.watertype == -4) {
        if ((self.dmgtime < time) && (self.radsuit_finished < time)) {
            if(votemode && !vote_anarchy_mode) {
                respawn();
            } else {
                self.dmgtime = time + 1;
                T_Damage(self, world, world, (4 * self.waterlevel));
            }
        }
    }
    if (!(self.flags & FL_INWATER)) {
        switch(self.watertype) {
            case CONTENT_LAVA:
                FO_Sound(self, CHAN_BODY, "player/inlava.wav", 1, 1);
                break;
            case CONTENT_WATER:
                FO_Sound(self, CHAN_BODY, "player/inh2o.wav", 1, 1);
                break;
            case CONTENT_SLIME:
                FO_Sound(self, CHAN_BODY, "player/slimbrn2.wav", 1, 1);
                break;
        }
        self.flags = self.flags + FL_INWATER;
        self.dmgtime = 0;
    }
};

void () CheckWaterJump = {
    local vector start;
    local vector end;

    makevectors(self.angles);
    start = self.origin;
    start_z = start_z + 8;
    v_forward_z = 0;
    normalize(v_forward);
    end = start + v_forward * 24;

    traceline(start, end, 1, self);
    if (trace_fraction < 1) {
        start_z = start_z + self.maxs_z - 8;
        end = start + v_forward * 24;
        self.movedir = trace_plane_normal * -50;

        traceline(start, end, 1, self);
        if (trace_fraction == 1) {
            self.flags = self.flags | FL_WATERJUMP;
            self.velocity_z = 225;
            self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
            self.teleport_time = time + 2;
            return;
        }
    }
};

void SpawnBubble(vector origin);

static void ConcUpdate() {
    if (self.tfstate & TFSTATE_CONC == 0)
        return;

    if (self.invincible_finished > time) {
        self.conc_state.mag = 0;
    } else {
        if (!Conc_Update(&self.conc_state, self, time))
            return;
    }

    if (self.conc_state.mag) {
        if (self.conc_state.mag % CONC_HZ == 0)
            SpawnBubble(self.origin);
    } else {
        RemoveConc(self, FALSE);
        sprint(self.owner, PRINT_HIGH, "Your head feels better now\n");
    }
}

// If a forceinfokey and a SVC_SETINFO are both set in the same frame, they
// will clobber each other. Thus we do skin setinfos like normal, and then
// per-player custom skin infos are immediately applied for those who need to
// update on the next frame.
void () UpdateAllSkins = {
    local entity target = find(world, classname, "player");
    local entity pov;

    while (target != world) {
        if (target.needs_skin_update) {
            pov = find(world, classname, "player");
            while (pov != world) {
                SetSkinInfoFor(pov, target);
                pov = find(pov, classname, "player");
            }
            target.needs_skin_update = 0;
        }
        target = find(target, classname, "player");
    }
}

void () PlayerPreThink = {
    FO_UpdateClientTime();
    ConcUpdate();
    UpdateAllSkins();

    if (self.impulse) {
        if (self.impulse == TF_VOTENEXT) {
            Vote_NextMap(self);
            self.impulse = 0;
        } else if (self.impulse == TF_VOTETRICK) {
            Vote_TrickMap(self);
            self.impulse = 0;
        } else if (self.impulse == TF_VOTERACE) {
            Vote_RaceMap(self);
            self.impulse = 0;
        } else if (self.impulse == TF_FORCENEXT) {
            Vote_ForceNext(self);
            self.impulse = 0;
        }
    }

    if (self.cheat_level > 0) {
        self.cheat_level = self.cheat_level - 1;
    }
    
    if (intermission_running) {
        IntermissionThink();
        return;
    }
    makevectors(self.v_angle);
    if (self.view_ofs == '0 0 0') {
        return;
    }

    // Check if timelimit/fraglimit has been met
    if(!votemode && !(duelmode && duel_allow_draw)) CheckRules();

    if (self.playerclass != 0 || votemode) {
        WaterMove();
    }

    if (self.deadflag >= DEAD_DEAD) {
        PlayerDeathThink();
        return;
    }
    if ((self.undercover_team || self.undercover_skin) ||
        self.is_undercover) {
        if (self.effects & (8 | 4)) {
            sprint(self, PRINT_MEDIUM,
                   "The glowing removes your disguise\n");
            Spy_RemoveDisguise(self);
        }
    }
    if (self.deadflag == DEAD_DYING) {
        return;
    }

    if (IsFeigned(self)) {
        if (self.flags & FL_ONGROUND) {
            // check area for entities - if found, bounce player forward
            if (!self.feign_areachecked) {
                local float check_area = Spy_CheckArea(self);
                if (check_area == 1 || check_area == 3) {
                    self.velocity = aim(self, 10000);
                    self.velocity = self.velocity * 200;
                    self.velocity_z = 200;
                } else {
                    self.feign_areachecked = 1;
                    if (!(self.tfstate & TFSTATE_CANT_MOVE)) {
                        self.movetype = MOVETYPE_NONE;
                        self.tfstate |= TFSTATE_CANT_MOVE;
                    }
                }
            }
        }
        if (self.waterlevel) {
            if (self.waterlevel == 1) {
                self.watertype = -3;
                self.waterlevel = 3;
            }
            self.velocity_z = -100;
        }
    } else {
        if (self.button2) {
            PlayerJump();
        } else {
            self.flags = self.flags | FL_JUMPRELEASED;
        }
    }

    if ((time < self.pausetime) || (cease_fire == 1)) {
        self.velocity = '0 0 0';
    }

    // Catch all.
    FO_WeapState ws;
    FO_FillCurrentWeapState(&ws);
    if ((self.client_time >= self.attack_finished) &&
        (ws.weapon > WEAP_AXE) && ((ws->wi)->ammo_type != AMMO_NONE)) {
        if (*ws->ammo_remaining == 0)
            W_ChangeToBestWeapon();
    }
};

void () CheckPowerups = {
    local float lighton;
    local entity te;

    if (self.health <= 0) {
        return;
    }
    if (self.playerclass == 0 && !votemode) {
        self.modelindex = modelindex_null;
    } else {
        if ((self.is_undercover == 1) && (invis_only == 1)) {
            self.frame = 0;
            self.modelindex = modelindex_eyes;
        } else {
            if (self.invisible_finished) {
                if (self.pstate & PSTATE_INVISIBLE) {
                    if (self.invisible_finished < (time + 10)) {
                        self.invisible_finished = time + 666;
                    }
                }
                if (self.invisible_sound < time) {
                    FO_Sound(self, CHAN_AUTO, "items/inv3.wav", 0.5, 2);
                    self.invisible_sound = time + ((random() * 3) + 1);
                }
                if (self.invisible_finished < (time + 3)) {
                    if (self.invisible_time == 1) {
                        sprint(self, PRINT_HIGH,
                               "Ring of shadows magic is fading\n");
                        stuffcmd(self, "bf\n");
                        FO_Sound(self, CHAN_AUTO, "items/inv2.wav", 1, 1);
                        self.invisible_time = time + 1;
                    }
                    if (self.invisible_time < time) {
                        self.invisible_time = time + 1;
                        stuffcmd(self, "bf\n");
                    }
                }
                if (self.invisible_finished < time) {
                    self.items &= ~IT_INVISIBILITY;
                    self.invisible_finished = 0;
                    self.invisible_time = 0;
                }
                self.frame = 0;
                self.modelindex = modelindex_eyes;
            } else {
                self.modelindex = modelindex_player;
            }
        }
    }
    if (self.invincible_finished) {
        if (self.pstate & PSTATE_INVINCIBLE) {
            if (self.invincible_finished < (time + 10)) {
                self.invincible_finished = time + 666;
            }
        }
        if (self.invincible_finished < (time + 3)) {
            if (self.invincible_time == 1) {
                sprint(self, PRINT_HIGH,
                       "Protection is almost burned out\n");
                stuffcmd(self, "bf\n");
                FO_Sound(self, CHAN_AUTO, "items/protect2.wav", 1, 1);
                self.invincible_time = time + 1;
            }
            if (self.invincible_time < time) {
                self.invincible_time = time + 1;
                stuffcmd(self, "bf\n");
            }
        }
        if (self.invincible_finished < time) {
            self.items &= ~IT_INVULNERABILITY;
            self.invincible_time = 0;
            self.invincible_finished = 0;
        }
        if (self.invincible_finished > time) {
            self.effects = self.effects | 8;
            self.effects = self.effects | 128;
        } else {
            lighton = 0;
            te = find(world, classname, "item_tfgoal");
            while (te) {
                if (te.owner == self) {
                    if (te.goal_activation & 1) {
                        lighton = 1;
                    }
                }
                te = find(te, classname, "item_tfgoal");
            }
            if (!lighton) {
                self.effects = self.effects - (self.effects & 8);
                self.effects = self.effects - (self.effects & 128);
            }
        }
    }
    if (self.super_damage_finished) {
        if (self.pstate & PSTATE_QUAD) {
            if (self.super_damage_finished == (time + 10)) {
                self.super_damage_finished = time + 666;
            }
        }
        if (self.super_damage_finished < (time + 3)) {
            if (self.super_time == 1) {
                sprint(self, PRINT_HIGH, "Quad damage is wearing off\n");
                stuffcmd(self, "bf\n");
                FO_Sound(self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
                self.super_time = time + 1;
            }
            if (self.super_time < time) {
                self.super_time = time + 1;
                stuffcmd(self, "bf\n");
            }
        }
        if (self.super_damage_finished < time) {
            self.items &= ~IT_QUAD;
            self.super_damage_finished = 0;
            self.super_time = 0;
        }
        if (self.super_damage_finished > time) {
            self.effects |= EF_DIMLIGHT | EF_BLUE;
        } else {
            lighton = 0;
            te = find(world, classname, "item_tfgoal");
            while (te) {
                if (te.owner == self) {
                    if (te.goal_activation & TFGA_TOUCH)
                        lighton = 1;
                }
                te = find(te, classname, "item_tfgoal");
            }
            if (!lighton) {
                self.effects = self.effects - (self.effects & 8);
                self.effects = self.effects - (self.effects & 64);
            }
        }
    }
    if (self.radsuit_finished) {
        self.air_finished = time + 12;
        if (self.pstate & PSTATE_RADSUIT) {
            if (self.radsuit_finished == (time + 10)) {
                self.radsuit_finished = time + 666;
            }
        }
        if (self.radsuit_finished < (time + 3)) {
            if (self.rad_time == 1) {
                sprint(self, PRINT_HIGH,
                       "Air supply in biosuit expiring\n");
                stuffcmd(self, "bf\n");
                FO_Sound(self, CHAN_AUTO, "items/suit2.wav", 1, 1);
                self.rad_time = time + 1;
            }
            if (self.rad_time < time) {
                self.rad_time = time + 1;
                stuffcmd(self, "bf\n");
            }
        }
        if (self.radsuit_finished < time) {
            self.items &= ~IT_SUIT;
            self.rad_time = 0;
            self.radsuit_finished = 0;
        }
    }
};

void FO_HandleTFStateUpdate() {
    if (self.last_tfstate == self.tfstate)
        return;

    float state_changed = self.last_tfstate ^ self.tfstate;
    if (state_changed & (TFSTATE_NO_WEAPON | TFSTATE_RELOADING))
        W_UpdateWeaponModel(self);
    if (state_changed & (TFSTATE_AIMING | TFSTATE_CANT_MOVE | TFSTATE_TRANQUILISED))
        TeamFortress_SetSpeed(self);

    self.last_tfstate = self.tfstate;
}

void TeamFortress_MOTD();

static void PlayerPostThinkAlive() {
    float fdmg;

    FO_WeapState ws;
    FO_FillCurrentWeapState(&ws);
    self.currentammo =
        (ws->wi)->ammo_type != AMMO_NONE ? *ws->ammo_remaining : 0;

    if (((self.jump_flag < -300) && (self.flags & FL_ONGROUND)) &&
        (self.health > 0)) {
        if (self.watertype == CONTENT_WATER) {
            FO_Sound(self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
        } else {
            if (self.jump_flag < -650) {
                fdmg = 5;
                fdmg = (fdmg * (self.jump_flag / 300)) * -1;
                if (self.playerclass == 1) {
                    fdmg = fdmg / 2;
                } else {
                    if (self.playerclass == 6) {
                        fdmg = fdmg * 1.5;
                    }
                }
                fdmg = rint(fdmg);
                TF_T_Damage(self, world, world, fdmg, 1, 0);
                FO_Sound(self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
                self.deathtype = "falling";
            } else {
                FO_Sound(self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
            }
        }
    }
    self.jump_flag = self.velocity_z;

    Forward_OpenDoors(self);

    if(votemode) {
        CheckPowerups();
        FO_ReloadFrame();
        W_WeaponFrame();
        //TeamFortress_CheckforCheats();
    } else {
        CheckPowerups();
        FO_ReloadFrame();
        ButtonFrame();
        W_WeaponFrame();
        if (self.motd >= 0) {
            TeamFortress_MOTD();
        } else {
            if (self.cheat_check == 0) {
                self.cheat_check = time + 5;
            }
        }
        if (self.cheat_check <= time) {
            TeamFortress_CheckTeamCheats(self);
            self.cheat_check = time + 3;
        }
    }

    FO_HandleTFStateUpdate();
    if (time >= self.StatusRefreshTime)
        RefreshStatusBar(self);
}

void () PlayerPostThink = {
    FO_CheckClientThink();
    UpdateScoreboardInfo(self);

    if (self.motd >= 0)
        TeamFortress_MOTD();

    if (self.deadflag || self.playerclass == 0) {
        DeadImpulses();
        self.impulse = 0;
    } else {
        PlayerPostThinkAlive();
    }

    FOPlayer fop = (FOPlayer)self;
    fop.RewindUpdate();
    Predict_Update(TRUE);
};

void () UpdateAllClientsTeamScores = {
    local entity e;

    e = find(world, classname, "player");
    while (e) {
        UpdateClientTeamScores(e);
        e = find(e, classname, "player");
    }

    e = find(world, classname, "observer");
    while (e) {
        UpdateClientTeamScores(e);
        e = find(e, classname, "observer");
    }
}

void (entity pov, entity target) SetBottomColorInfoFor = {
    local float target_idx = target.colormap - 1;
    local string color = TeamFortress_TeamGetColorFor(pov, target.team_no);

    msg_entity = pov;
    WriteByte(MSG_ONE, SVC_SETINFO);
    WriteByte(MSG_ONE, target_idx);
    WriteString(MSG_ONE, "bottomcolor");
    WriteString(MSG_ONE, color);
}

void (entity pov, entity target) SetTopColorInfoFor = {
    local float target_idx = target.colormap - 1;
    local string color = TeamFortress_TeamGetColorFor(pov, target.team_no);

    msg_entity = pov;
    WriteByte(MSG_ONE, SVC_SETINFO);
    WriteByte(MSG_ONE, target_idx);
    WriteString(MSG_ONE, "topcolor");
    WriteString(MSG_ONE, color);
}

void (entity pov, entity target) SetSkinInfoFor = {
    SetTopColorInfoFor(pov, target);
    SetBottomColorInfoFor(pov, target);
}

void () ClientConnect = {
    if (!infokeyf(self,INFOKEY_P_CSQCACTIVE)) {
        sprint(self, PRINT_HIGH, "FTE/CSQC is required for this server, please download the latest client package at www.fortressone.org\n");
        dropclient(self);
        return;
    }

    bprint(PRINT_HIGH, self.netname, " entered the game\n");
    sprint(self, PRINT_HIGH, "FortressOne: Weapon Prediction ", wp_version, "\n");

    spawnfunc_FOPlayer();

    self.motd = 0;

    if (self.netname == string_null)
        KickCheater(self);

    if (infokey(self,"*login"))
        self.login = infokey(self,"*login");
    if (infokey(self,"*admin"))
        self.is_admin = stof(infokey(self, "*admin"));
    if (loginRequired && self.login == string_null)
        sprint(self,2, "Login required, please use \"cmd login <login> <secret>\" \nbefore joining the game\n");

    TeamFortress_ExecMapScript(self);
    self.has_disconnected = 0;

    if (intermission_running) {
        PutClientInIntermission();
        GotoNextMap();
    }

    string st = infokey(self, "apw");
    if (st == string_null)
        st = infokey(self, "adminpwd");
    if (st) {
        Admin_Check(st);
        if (self.is_admin)
            Admin_Aliases();
        else
            self.is_admin = FALSE;
    }

    if (clanbattle && (self.has_disconnected != 1)) {
        st = infokey(self, "tf_id");
        self.tf_id = stof(st);
        if (!loginRequired) {
            if ((st != string_null) && (self.tf_id != 0))
                RejoinWithTfId();
            else
                CreateTfIdAndJoin();
        }
    }

    InitAllStatuses(self);
    UpdateClientMOTD(self);
    UpdateClientTeamScores(self);
    UpdateClientPrematch(self, !cb_prematch);
    UpdateClient_VoteMap_AddAll(self);
    TeamFortress_SetSkin(self);

    if (cb_prematch)
        sprint(self, PRINT_HIGH, "Currently in \sprematch\s time\n");
};

float () RejoinWithTfId = {
    local entity te;
    sprint(self, PRINT_HIGH, "Welcome back!\n");
    te = find(world, classname, "ghost");
    while (te) {
        if (te.tf_id == self.tf_id) {
            TeamFortress_TeamSet_Options(self, te.team_no, TRUE);
            UpdateAllClientsTeamScores();

            self.frags = te.frags;
            self.real_frags = te.real_frags;
            if (!(toggleflags & TFLAG_TEAMFRAGS) &&
                !(toggleflags & TFLAG_FULLTEAMSCORE)) {
                self.frags = self.real_frags;
            }
            self.playerclass = te.playerclass;
            self.nextpc = te.playerclass;
            self.tfstate = te.tfstate;
            dremove(te);
            te = world;
            return 1;
        } else
            te = find(te, classname, "ghost");
    }
    return 0;
}

void () CreateTfIdAndJoin = {
    local string st;
    if (game_locked && (!cb_prematch)) {
        sprint(self, PRINT_HIGH,
               "Closed server. Clan battle in progress.\n");
        KickCheater(self);
        return;
    }
    last_id = last_id + 20 + random() * 10;
    self.tf_id = rint(random() * 10 + last_id);
    st = ftos(self.tf_id);
    stuffcmd(self, "setinfo tf_id ");
    stuffcmd(self, st);
    stuffcmd(self, "\n");
    sprint(self, PRINT_HIGH, "Your battle ID is ", st, "\n");
}

void (entity pl) ResetAndRespawnPlayer = {
    if(pl.team_no && pl.playerclass) {
        pl.classname = "player";
        pl.takedamage = DAMAGE_AIM;
        pl.solid = SOLID_SLIDEBOX;
        pl.movetype = MOVETYPE_WALK;
        TeamFortress_RemoveTimers();
        setspawnparms(pl);
        PutClientInServer();
    }
    if(infokeyf(pl, INFOKEY_P_CSQCACTIVE)) {
        UpdateClientPrematch(pl, FALSE);
    }
}

void () CountMatchPlayersAndReset = {
    local float playersleft = 0;
    local entity te = find (world, classname, "player");
    while (te) {
        if (!te.has_disconnected) {
            playersleft = playersleft + 1;
        }
        te = find (te, classname, "player");
    }
    if (!playersleft) {
        bprint(PRINT_HIGH, "Match \sabandoned\s, resetting to prematch\n");
        InitPrematch();
    } else if(CountRemainingTeams() < 2) {
        ResetPlayersWithCountdown();
    }
}

void () ClientDisconnect = {
    local string st;
    local float fr;

    fr = rint(self.frags);
    st = ftos(fr);

    local float timeplayed = gametime - self.classtime;
    LogEventChangeClass(self, self.playerclass, 0, timeplayed);
    self.classtime = gametime;

    bprint(PRINT_HIGH, self.netname, " left the game with ", st,
            " frags\n");
    FO_Sound(self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
    self.has_disconnected = 1;
    RemovePlayerOwnedEnts();

    if (duelmode && clanbattle && !cb_prematch) {
        //In duelmode, reset back to prematch if everyone leaves half-way through a round
        CountMatchPlayersAndReset();
    }
    set_suicide_frame();
    self.netname = string_null;
    self.team_no = 0;
    self.solid = 0;
    setsize(self, '0 0 0', '0 0 0');
    if (self.StatusString)
        strunzone(self.StatusString);
    self.StatusString = string_null;



    if(cb_prematch) {
        //Check in case the player leaving is the last not-readied player
        if(self.stat_flags & PLAYER_READY) {
            v_ready = (v_ready - 1);
        } else if (!CheckAllPlayersReady()) {
            UpdateReadyStatus();
        }
    }

    if(votemode) {
        UnvoteForMap(self);
    }

    Predict_Destroy(self);
};

string (entity pe_target, entity pe_attacker, float pf_deathmsg) GetDeathMessage = {
    local string s_deathstring = "", s_deathstring2 = "\n";
    local float rnum;

    rnum = random();

    if (pe_target.classname == "player") {
        if (pe_attacker.classname == "teledeath2") {
            return strcat("Satan's power deflects ",
                    strcat(pe_target.netname, "'s telefrag\n"));
        }
        if (pe_attacker.classname == "teledeath") {
            return strcat(pe_target.netname,
                    strcat(" was telefragged by ",
                    strcat(pe_attacker.owner.netname, "\n")));
        }
        if (pf_deathmsg == DMSG_TEAMKILL) {
            return strcat(pe_attacker.netname, " shoots his teammate one too many times\n");
        }
        if (pe_attacker.classname == "player" || pe_attacker.classname == "bot") {
            if (pe_target == pe_attacker) {

                if (pf_deathmsg == DMSG_GREN_HAND) {

                    if (pe_target.playerclass == PC_SNIPER)
                        s_deathstring = " got splattered by his own grenade\n";
                    else if (pe_target.playerclass == PC_SOLDIER)
                        s_deathstring = " sat on his own grenade\n";
                    else if (pe_target.playerclass == PC_DEMOMAN)
                        s_deathstring = " got to know his grenade too well\n";
                    else if (pe_target.playerclass == PC_MEDIC)
                        s_deathstring = " caught the end of his own grenade\n";
                    else if (pe_target.playerclass == PC_HVYWEAP)
                        s_deathstring = " got too close to his own grenade\n";
                    else if (pe_target.playerclass == PC_PYRO)
                        s_deathstring = " let his own grenade get the best of him\n";
                    else if (pe_target.playerclass == PC_SPY)
                        s_deathstring = " tiptoed over his own grenade\n";
                    else if (pe_target.playerclass == PC_ENGINEER)
                        s_deathstring = " stared at his grenade too long\n";
                    else
                        s_deathstring = " grenades himself\n";
                    return strcat(pe_target.netname, s_deathstring);
                } else if (pf_deathmsg == DMSG_GREN_NAIL) {
                    return strcat(pe_target.netname, " hammers himself\n");
                } else if (pf_deathmsg == DMSG_GREN_SHOCK) {
                    return strcat(pe_target.netname, " electrocutes himself\n");
                } else if (pf_deathmsg == DMSG_GREN_BURST) {
                    return strcat(pe_target.netname, " peppers himself\n");
                } else if (pf_deathmsg == DMSG_GREN_MIRV) {
                    if (pe_target.playerclass == PC_DEMOMAN)
                        s_deathstring = " practiced his own Mirv dance\n";
                    else if (pe_target.playerclass == PC_HVYWEAP)
                        s_deathstring = " allowed his Mirv to turn against him\n";
                    else
                        s_deathstring = " goes to pieces\n";
                    return strcat(pe_target.netname, s_deathstring);
                } else if (pf_deathmsg == DMSG_GREN_PIPE) {
                    return strcat(pe_target.netname, " ambushes himself with his own pipebombs\n");
                }
                else if (pf_deathmsg == DMSG_GREN_PIPE_AIR)
                    s_deathstring = " tried to juggle his own pipebombs\n";
                else if (pf_deathmsg == DMSG_GREN_GAS)
                    s_deathstring = " chokes on his own gas\n";
                else if (pf_deathmsg == DMSG_GREN_EMP)
                    s_deathstring = " explodes his ammo and body\n";
                else if (pf_deathmsg == DMSG_GREN_CALTROP)
                    s_deathstring = " stepped on too many of his own caltrops\n";
                else if (pf_deathmsg == DMSG_GREN_FLASH)
                    s_deathstring = " is charred by his own flash grenade\n";
                else if (pf_deathmsg == DMSG_GREN_EMP_AMMO)
                    s_deathstring = " detonates an ammo box too close to him\n";
                else if (pf_deathmsg == DMSG_DETPACK)
                    s_deathstring = " set the detpack and forgot to run\n";
                else if (pf_deathmsg == DMSG_BIOWEAPON)
                    s_deathstring = " died impossibly!\n";
                else if (pf_deathmsg == DMSG_ROCKETL) {
                    if (rnum)
                        s_deathstring = " becomes bored with life\n";
                    else
                        s_deathstring = " checks if his weapon is loaded\n";
                } else if (pf_deathmsg == DMSG_INCENDIARY)
                    s_deathstring = " chars himself with an incendiary rocket\n";
                else if (pf_deathmsg == DMSG_GRENADEL)
                    s_deathstring = " tries to put the pin back in\n";
                else if (pf_deathmsg == DMSG_FLAME)
                    s_deathstring = " torches himself\n";
                else if (pf_deathmsg == DMSG_LIGHTNING && pe_target.waterlevel > 1)
                    s_deathstring = " discharges into the water\n";
                else if (pf_deathmsg == DMSG_SENTRYGUN_EXPLODE)
                    s_deathstring = " gets too friendly with his sentry gun\n";
                else if (pf_deathmsg == DMSG_DISPENSER_EXPLODE)
                    s_deathstring = " dispenses with himself\n";
                else if (pf_deathmsg == DMSG_IMPELLER)
                    s_deathstring = " couldn't resist their inner impelsions\n";

                return strcat(pe_target.netname, s_deathstring);

            } else if ((teamplay && (pe_attacker.team_no == pe_target.team_no)) && (pe_attacker.team_no > 0)) {

                if (rnum < 0.25)
                    s_deathstring = " mows down teammate ";
                else if (rnum < 0.5)
                    s_deathstring = " checks his glasses after killing ";
                else if (rnum < 0.75) {
                    s_deathstring = " gets a frag for the other team with ";
                    s_deathstring2 = "'s death\n";
                } else
                    s_deathstring = " killed his supposed friend ";

                if (pf_deathmsg == DMSG_MEDIKIT)
                    return strcat(pe_target.netname,
                            strcat(" didn't survive the operation by ",
                            strcat(pe_attacker.netname, "\n")));

                return strcat(pe_attacker.netname,
                        strcat(s_deathstring,
                        strcat(pe_target.netname, s_deathstring2)));

            } else {

                if (pf_deathmsg == DMSG_GREN_HAND) {
                    if (pe_attacker.playerclass == PC_SNIPER) {
                        s_deathstring = " got up-close and personal with ";
                        s_deathstring2 = "'s grenade\n";
                    } else if (pe_attacker.playerclass == PC_SOLDIER) {
                        s_deathstring = " played catch with ";
                        s_deathstring2 = "'s grenade\n";
                    } else if (pe_attacker.playerclass == PC_DEMOMAN) {
                        s_deathstring = " received a pineapple enema from ";
                        s_deathstring2 = "\n";
                    } else if (pe_attacker.playerclass == PC_MEDIC) {
                        s_deathstring = " fetched ";
                        s_deathstring2 = "'s pineapple\n";
                    } else if (pe_attacker.playerclass == PC_HVYWEAP) {
                        s_deathstring = " caught too much shrapnel from ";
                        s_deathstring2 = "'s grenade\n";
                    } else if (pe_attacker.playerclass == PC_PYRO) {
                        s_deathstring = " tried to pick up ";
                        s_deathstring2 = "'s hot potato\n";
                    } else if (pe_attacker.playerclass == PC_SPY) {
                        s_deathstring = " thought ";
                        s_deathstring2 = " was tossing him a spare grenade\n";
                    } else if (pe_attacker.playerclass == PC_ENGINEER) {
                        s_deathstring = " stops to ponder the technical details of ";
                        s_deathstring2 = "'s grenade\n";
                    } else {
                        s_deathstring = " surfs on a grenade from ";
                        s_deathstring2 = "\n";
                    }

                } else if (pf_deathmsg == DMSG_GREN_NAIL) {
                        s_deathstring = " gets flayed by ";
                        s_deathstring2 = "'s nail grenade\n";
                } else if (pf_deathmsg == DMSG_GREN_SHOCK) {
                        s_deathstring = " gets melted by ";
                        s_deathstring2 = "'s shock grenade\n";
                } else if (pf_deathmsg == DMSG_GREN_BURST) {
                        s_deathstring = " gets peppered by ";
                        s_deathstring2 = "'s burst grenade\n";
                } else if (pf_deathmsg == DMSG_GREN_MIRV) {
                    if (pe_attacker.playerclass == PC_DEMOMAN) {
                        s_deathstring = " does a dance on ";
                        s_deathstring2 = "'s Mirv grenade\n";
                    } else {
                        s_deathstring = " gets spammed by ";
                        s_deathstring2 = "'s Mirv grenade\n";
                    }
                } else if (pf_deathmsg == DMSG_GREN_PIPE) {
                    s_deathstring = " is caught by ";
                    s_deathstring2 = "'s pipebomb trap\n";
                } else if (pf_deathmsg == 40) {
                    s_deathstring = " fell victim to ";
                    s_deathstring2 = "'s fireworks\n";
                } else if (pf_deathmsg == DMSG_GREN_GAS) {
                    s_deathstring = " gags on ";
                    s_deathstring2 = "'s noxious gasses\n";
                } else if (pf_deathmsg == DMSG_GREN_EMP) {
                    s_deathstring = "'s ammo detonates him as ";
                    s_deathstring2 = "'s EMP fries it\n";
                } else if (pf_deathmsg == DMSG_GREN_CALTROP) {
                    s_deathstring = " stepped on too many of ";
                    s_deathstring2 = "'s caltrops\n";
                } else if (pf_deathmsg == DMSG_GREN_FLASH) {
                    s_deathstring = " is charred by ";
                    s_deathstring2 = "'s flash grenade\n";
                } else if (pf_deathmsg == DMSG_GREN_EMP_AMMO) {
                    s_deathstring = " stands near some ammo as ";
                    s_deathstring2 = "'s EMP nukes it\n";
                } else if (pf_deathmsg == DMSG_DETPACK) {
                    s_deathstring = " reaches orbit via ";
                    s_deathstring2 = "'s detpack\n";
                } else if (pf_deathmsg == DMSG_DETPACK_DIS) {
                    s_deathstring = " cut the red wire of ";
                    s_deathstring2 = "'s detpack\n";
                } else if (pf_deathmsg == DMSG_BIOWEAPON) {
                    s_deathstring = " dies from ";
                    s_deathstring2 = "'s mysterious tropical disease\n";
                } else if (pf_deathmsg == DMSG_BIOWEAPON_ATT) {
                    s_deathstring = " escapes infection from ";
                    s_deathstring2 = " by dying first\n";
                } else if (pf_deathmsg == DMSG_GRENADEL) {
                    s_deathstring = " eats ";
                    s_deathstring2 = "'s pineapple\n";
                    if (pe_target.health < -40) {
                        s_deathstring = " was gibbed by ";
                        s_deathstring2 = "'s grenade\n";
                    }
                } else if (pf_deathmsg == DMSG_ROCKETL) {
                    s_deathstring = " rides ";
                    s_deathstring2 = "'s rocket\n";
                    if (pe_target.health < -40) {
                        s_deathstring = " was gibbed by ";
                        s_deathstring2 = "'s rocket\n";
                    }
                } else if (pf_deathmsg == DMSG_FLAME) {
                    if (rnum < 0.2) {
                        s_deathstring = " is burnt up by ";
                        s_deathstring2 = "'s flame\n";
                    } else if (rnum < 0.4) {
                        s_deathstring = " is fried by ";
                        s_deathstring2 = "'s fire\n";
                    } else if (rnum < 0.6) {
                        s_deathstring = " feels ";
                        s_deathstring2 = "'s fire of wrath\n";
                    } else if (rnum < 0.8) {
                        s_deathstring = " is reduced to ashes by ";
                        s_deathstring2 = "\n";
                    } else {
                        s_deathstring = " is grilled by ";
                        s_deathstring2 = "'s flame\n";
                    }
                } else if (pf_deathmsg == DMSG_AXE) {
                    s_deathstring2 = "\n";
                    if (pe_attacker.playerclass == PC_SCOUT)
                        s_deathstring = "'s mellon was split by ";
                    else if (pe_attacker.playerclass == PC_SNIPER)
                        s_deathstring = " was put on the chop block by ";
                    else if (pe_attacker.playerclass == PC_SOLDIER) {
                        s_deathstring = " was sliced and diced by ";
                        s_deathstring2 = "'s blade\n";
                    } else if (pe_attacker.playerclass == PC_DEMOMAN) {
                        s_deathstring = " is split from crotch to sternum by ";
                        s_deathstring2 = "'s axe swing\n";
                    } else if (pe_attacker.playerclass == PC_HVYWEAP)
                        s_deathstring = " is split in two with a powerful axe blow from ";
                    else if (pe_attacker.playerclass == PC_PYRO) {
                        s_deathstring = "'s death put another notch on ";
                        s_deathstring2 = "'s axe\n";
                    } else
                        s_deathstring = " was ax-murdered by ";
                } else if (pf_deathmsg == DMSG_KNIFE) {
                    s_deathstring = " was knife-murdered by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_BACKSTAB) {
                    s_deathstring = " gets knifed from behind by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_SPANNER) {
                    s_deathstring = " was spanner-murdered by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_SHOTGUN) {
                    if (pe_attacker.playerclass == PC_SCOUT) {
                        s_deathstring = " got too close to ";
                        s_deathstring2 = "'s muzzleflash\n";
                    } else if (pe_attacker.playerclass == PC_SOLDIER) {
                        s_deathstring = " practices being ";
                        s_deathstring2 = "'s clay pigeon\n";
                    } else if (pe_attacker.playerclass == PC_DEMOMAN) {
                        s_deathstring = " was on the receiving end of ";
                        s_deathstring2 = "'s shotgun barrel\n";
                    } else if (pe_attacker.playerclass == PC_MEDIC) {
                        s_deathstring = " was fed a lead diet by ";
                        s_deathstring2 = "\n";
                    } else if (pe_attacker.playerclass == PC_HVYWEAP) {
                        s_deathstring = " got blasted by ";
                        s_deathstring2 = "'s last resort\n";
                    } else if (pe_attacker.playerclass == PC_PYRO) {
                        s_deathstring = " got more than a powderburn from ";
                        s_deathstring2 = "'s shotgun blast\n";
                    } else {
                        s_deathstring = " chewed on ";
                        s_deathstring2 = "'s boomstick\n";
                    }
                } else if (pf_deathmsg == DMSG_SSHOTGUN) {
                    if (pe_attacker.playerclass == PC_SOLDIER) {
                        s_deathstring = " was turned into swiss cheese by ";
                        s_deathstring2 = "'s buckshot\n";
                    } else if (pe_attacker.playerclass == PC_MEDIC) {
                        s_deathstring = " got a double-dose of ";
                        s_deathstring2 = "'s buckshot\n";
                    } else if (pe_attacker.playerclass == PC_HVYWEAP) {
                        s_deathstring = " unfortunately forgot ";
                        s_deathstring2 = " carried a super-shotgun\n";
                    } else if (pe_attacker.playerclass == PC_SPY) {
                        s_deathstring = " gets ventilated by ";
                        s_deathstring2 = "'s super-shotgun blast\n";
                    } else if (pe_attacker.playerclass == PC_ENGINEER) {
                        s_deathstring = "'s body got chuck full of ";
                        s_deathstring2 = "'s lead pellets\n";
                    } else {
                        s_deathstring = " ate 2 loads of ";
                        s_deathstring2 = "'s buckshot\n";
                    }
                } else if (pf_deathmsg == DMSG_NAILGUN) {
                    if (pe_attacker.playerclass == PC_SCOUT) {
                        s_deathstring = " caught one too many nails from ";
                        s_deathstring2 = "\n";
                    } else if (pe_attacker.playerclass == PC_SNIPER) {
                        s_deathstring = " ran into ";
                        s_deathstring2 = "'s nails\n";
                    } else if (pe_attacker.playerclass == PC_SPY) {
                        s_deathstring = " was turned into ";
                        s_deathstring2 = "'s pin-cushion\n";
                    } else {
                        s_deathstring = " was nailed by ";
                        s_deathstring2 = "\n";
                    }
                } else if (pf_deathmsg == DMSG_SNAILGUN) {
                    s_deathstring = " was punctured by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_LIGHTNING) {
                    s_deathstring = " accepts ";
                    if (pe_attacker.waterlevel > 1)
                        s_deathstring2 = "'s discharge\n";
                    else
                        s_deathstring2 = "'s shaft\n";
                } else if (pf_deathmsg == DMSG_SNIPERRIFLE) {
                    if (rnum <= 0.3) {
                        s_deathstring = " takes a bullet in the chest from ";
                        s_deathstring2 = "\n";
                    } else {
                        s_deathstring = " succumbs to sniperfire from ";
                        s_deathstring2 = "\n";
                    }
                } else if (pf_deathmsg == DMSG_SNIPERHEADSHOT) {
                    if (rnum <= 0.5) {
                        s_deathstring = " gets a third eye from ";
                        s_deathstring2 = "\n";
                    } else {
                        s_deathstring = " gets his head blown off by ";
                        s_deathstring2 = "\n";
                    }
                } else if (pf_deathmsg == DMSG_SNIPERLEGSHOT) {
                    if (rnum <= 0.5) {
                        s_deathstring = " is made legless by ";
                        s_deathstring2 = "\n";
                    } else {
                        s_deathstring = " gets his legs blown off by ";
                        s_deathstring2 = "\n";
                    }
                } else if (pf_deathmsg == DMSG_AUTORIFLE) {
                    s_deathstring = " collects ";
                    s_deathstring2 = "'s bullet spray.\n";
                } else if (pf_deathmsg == DMSG_ASSAULTCANNON) {
                    s_deathstring = " gets sawn in half by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_TRANQ) {
                    s_deathstring = " is put to sleep by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_LASERBOLT) {
                    s_deathstring = " gets a hole in his heart from ";
                    s_deathstring2 = "'s railgun\n";
                } else if (pf_deathmsg == DMSG_IMPELLER) {
                    s_deathstring = " gets pushed around by ";
                    s_deathstring2 = "\n";
                } else if (pf_deathmsg == DMSG_INCENDIARY) {
                    s_deathstring = " gets well done by ";
                    s_deathstring2 = "'s incendiary rocket\n";
                } else if (pf_deathmsg == DMSG_SENTRYGUN_EXPLODE) {
                    s_deathstring = " gets destroyed by ";
                    s_deathstring2 = "'s exploding sentrygun\n";
                } else if (pf_deathmsg == DMSG_DISPENSER_EXPLODE) {
                    s_deathstring = " didn't insert the correct change into ";
                    s_deathstring2 = "'s dispenser.\n";
                }

                if (pe_attacker.has_disconnected == 1 || pe_attacker.netname == string_null) {
                    s_deathstring = " died.";
                    s_deathstring2 = "\n";
                }

                return strcat(pe_target.netname,
                        strcat(s_deathstring,
                        strcat(pe_attacker.netname, s_deathstring2)));

            }

        } else if (pe_attacker.classname == "building_sentrygun") {

            if (pe_target == pe_attacker.real_owner) {

                if (pf_deathmsg == DMSG_SENTRYGUN_ROCKET)
                    s_deathstring = " intercepts his sentry gun's rocket\n";
                else if (pf_deathmsg == DMSG_SENTRYGUN_BULLET)
                    s_deathstring = " crossed his sentry gun's line of fire\n";

                return strcat(pe_target.netname, s_deathstring);

            } else if ((teamplay && (pe_attacker.team_no == pe_target.team_no)) && (pe_attacker.team_no > 0)) {

                return strcat(pe_target.netname, " obstructs his team's sentry gun\n");

            } else {

                if (pf_deathmsg == DMSG_SENTRYGUN_ROCKET) {
                    s_deathstring = " hates ";
                    s_deathstring2 = "'s sentry gun\n";
                } else if (pf_deathmsg == DMSG_SENTRYGUN_BULLET) {
                    s_deathstring = " is mown down by ";
                    s_deathstring2 = "'s sentry gun\n";
                }

                return strcat(pe_target.netname,
                        strcat(s_deathstring,
                        strcat(pe_attacker.real_owner.netname, s_deathstring2)));

            }
        //only do world-based deaths if not caused by a tf goal with a defined custom death (or broadcast) message
        } else if (!((
            pe_attacker.classname == "info_tfgoal" || 
            pe_attacker.classname == "info_tfgoal_timer" || 
            pe_attacker.classname == "item_tfgoal"
        ) && (pe_attacker.deathtype || pe_attacker.n_b || pe_attacker.netname_broadcast))) {
            rnum = pe_target.watertype;

            if (rnum == -3) {
                if (random() < 0.5)
                    s_deathstring = " sleeps with the fishes\n";
                else
                    s_deathstring = " sucks it down\n";
            } else if (rnum == -4) {
                if (random() < 0.5)
                    s_deathstring = " gulped a load of slime\n";
                else
                    s_deathstring = " can't exist on slime alone\n";
            } else if (rnum == CONTENT_LAVA) {
                if (pe_target.health < -15)
                    s_deathstring = " burst into flames\n";
                else if (random() < 0.5)
                    s_deathstring = " turned into hot slag\n";
                else
                    s_deathstring = " visits the Volcano God\n";
            } else if (pe_attacker.classname == "explo_box")
                s_deathstring = " blew up\n";
            else if ((pe_attacker.solid == SOLID_BSP) && (pe_attacker != world))
                s_deathstring = " was squished\n";
            else if (pe_target.deathtype == "falling") {
                s_deathstring = " fell to his death\n";
            } else if ((pe_attacker.classname == "trap_shooter")
                       || (pe_attacker.classname == "trap_spikeshooter"))
                s_deathstring = " was spiked\n";
            else if (pe_attacker.classname == "fireball")
                s_deathstring = " ate a lavaball\n";
            else if (pe_attacker.classname == "trigger_changelevel")
                s_deathstring = " tried to leave\n";
            else
                s_deathstring = " died\n";

            return strcat(pe_target.netname, s_deathstring);

        }

    } else if (pe_target.classname == "building_sentrygun") {

        if (pe_attacker.classname == "teledeath") {
            return strcat(pe_target.real_owner.netname,
                    strcat("'s sentrygun was telefragged by ",
                    strcat(pe_attacker.owner.netname, "\n")));
        }
        if (pe_attacker.classname == "player") {
            if (pe_attacker == pe_target.real_owner) {
                return strcat(pe_target.real_owner.netname, " destroys his sentrygun\n");
            }
            return strcat(pe_target.real_owner.netname,
                    strcat("'s sentrygun was destroyed by ",
                    strcat(pe_attacker.netname, "\n")));
        }

    }

    return "";
};

void (entity targ, entity attacker) ClientObituary = {
    local string deathstring;

    Sniper_ZoomReset(targ);

    if (cb_prematch)
        return;

    deathstring = GetDeathMessage(targ, attacker, deathmsg);
    bprint(PRINT_MEDIUM, deathstring);

    if (targ.classname == "player") {
        if (attacker.classname == "teledeath") {

            if (attacker.owner.team_no != targ.team_no || attacker.owner.team_no < 1)
                TF_AddFrags(attacker.owner, 1);

        }
        if (attacker.classname == "teledeath2") {

            TF_AddFrags(targ, -1);
            logfrag(targ, targ);

        }
        if (attacker.classname == "info_tfgoal" || attacker.classname == "item_tfgoal") {

            if (attacker.deathtype != "")
                bprint(PRINT_MEDIUM, targ.netname, attacker.deathtype);

            logfrag(targ, targ);

        }
        if (attacker.classname == "player" || attacker.classname == "bot") {

            if (targ == attacker) {

                // killed self
                TF_AddFrags(attacker, -1);
                return;

            } else if ((teamplay && attacker.team_no == targ.team_no) && attacker.team_no > 0) {

                // killed a team member
                TF_AddFrags(attacker, -1);

                if (targ.undercover_team == 0)
                    attacker.teamkills = attacker.teamkills + 1;

                CheckAutoKick(attacker);
                return;

            } else {

                TF_AddFrags(attacker, 1);
                logfrag(attacker, targ);

            }

        } else if (attacker.classname == "building_sentrygun") {

            if (targ != attacker.real_owner) {

                TF_AddFrags(attacker.real_owner, 1);
                logfrag(attacker.real_owner, targ);

            }

        } else {

            logfrag(targ, targ);
            TF_AddFrags(targ, -1);

        }

    } else if (targ.classname == "building_sentrygun") {

        if (attacker.team_no > 0 && attacker.team_no == targ.real_owner.team_no) {

            TF_AddFrags(attacker, -1);
            attacker.teamkills = attacker.teamkills + 1;
            CheckAutoKick(attacker);

        } else {

            TF_AddFrags(attacker, 1);

        }

    } else if (targ.classname == "building_dispenser") {

        if (attacker.team_no > 0 && attacker.team_no == targ.real_owner.team_no) {
            TF_AddFrags(attacker, -1);
            attacker.teamkills = attacker.teamkills + 1;
            CheckAutoKick(attacker);
        }

    }

};

float () IsUsingOldImpulses = {
    return ((infokey(self, "old_weapon_impulses") == "1") || (infokey(self, "owi") == "1"));
}

float () IsUsingCFImpulses = {
    return FO_GetUserSetting(self, "cf_pyro_impulses", "cfpi", "off");
}

float GetMaxWeaponInput()  {
    return IsUsingOldImpulses() ? 7 : 4;
}

void () InitReverseCap = {
    local entity te = world, tg, tfdet;
    local vector originbkp;

    te = world;
    tfdet = find(world, classname, "info_tfdetect");
    for (float t = 1; t <= number_of_teams; t++) {
        switch (t)
        {
            case 1:
                te = Finditem(tfdet.display_item_status1);
                break;
            case 2:
                te = Finditem(tfdet.display_item_status2);
                break;
            case 3:
                te = Finditem(tfdet.display_item_status3);
                break;
            case 4:
                te = Finditem(tfdet.display_item_status4);
                break;
        }

        if (te) {
            tg = find(world, classname, "info_tfgoal");
            while (tg) {
                if (tg.items_allowed == te.goal_no) {
                   originbkp = te.origin;

                   te.oldorigin = tg.origin;
                   te.origin = tg.origin;
                   setsize(te, te.goal_min, te.goal_max);

                   tg.oldorigin = originbkp;
                   tg.origin = originbkp;
                   setsize(tg, tg.mins, tg.maxs);
                }
                tg = find(tg, classname, "info_tfgoal");
            }
        }
    }

}

// this is to fix hack used to avoid fall damage, it currently breaks pm_airstep
/*
void() SV_RunClientCommand = {

    local float fdmg;

    runstandardplayerphysics(self);

    if (((self.jump_flag < -300) && (self.flags & 512)) &&
        (self.health > 0)) {
        if (self.watertype == -3) {
            FO_Sound(self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
        } else {
            if (self.jump_flag < -650) {
                fdmg = 5;
                fdmg = (fdmg * (self.jump_flag / 300)) * -1;
                if (self.playerclass == 1) {
                    fdmg = fdmg / 2;
                } else {
                    if (self.playerclass == 6) {
                        fdmg = fdmg * 1.5;
                    }
                }
                fdmg = rint(fdmg);
                TF_T_Damage(self, world, world, fdmg, 1, 0);
                FO_Sound(self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
                self.deathtype = "falling";
            } else {
                FO_Sound(self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
            }
        }
    }
    self.jump_flag = self.velocity_z;
}
*/
