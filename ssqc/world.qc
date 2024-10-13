void () TerminateStaleServer;

string (entity ent, string ps_short, string ps_setting, string ps_default) FO_GetUserSettingString;

void InitFppProjectiles();

void () main = {
    dprint("main function\n");
    precache_file("progs.dat");
    precache_file("gfx.wad");
    precache_file("quake.rc");
    precache_file("default.cfg");
    precache_file("gfx/palette.lmp");
    precache_file("gfx/colormap.lmp");
    precache_file2("gfx/pop.lmp");
    precache_file("gfx/complete.lmp");
    precache_file("gfx/inter.lmp");
    precache_file("gfx/ranking.lmp");
    precache_file("gfx/vidmodes.lmp");
    precache_file("gfx/finale.lmp");
    precache_file("gfx/conback.lmp");
    precache_file("gfx/qplaque.lmp");
    precache_file("gfx/menudot1.lmp");
    precache_file("gfx/menudot2.lmp");
    precache_file("gfx/menudot3.lmp");
    precache_file("gfx/menudot4.lmp");
    precache_file("gfx/menudot5.lmp");
    precache_file("gfx/menudot6.lmp");
    precache_file("gfx/menuplyr.lmp");
    precache_file("gfx/bigbox.lmp");
    precache_file("gfx/dim_modm.lmp");
    precache_file("gfx/dim_drct.lmp");
    precache_file("gfx/dim_ipx.lmp");
    precache_file("gfx/dim_tcp.lmp");
    precache_file("gfx/dim_mult.lmp");
    precache_file("gfx/mainmenu.lmp");
    precache_file("gfx/box_tl.lmp");
    precache_file("gfx/box_tm.lmp");
    precache_file("gfx/box_tr.lmp");
    precache_file("gfx/box_ml.lmp");
    precache_file("gfx/box_mm.lmp");
    precache_file("gfx/box_mm2.lmp");
    precache_file("gfx/box_mr.lmp");
    precache_file("gfx/box_bl.lmp");
    precache_file("gfx/box_bm.lmp");
    precache_file("gfx/box_br.lmp");
    precache_file("gfx/sp_menu.lmp");
    precache_file("gfx/ttl_sgl.lmp");
    precache_file("gfx/ttl_main.lmp");
    precache_file("gfx/ttl_cstm.lmp");
    precache_file("gfx/mp_menu.lmp");
    precache_file("gfx/netmen1.lmp");
    precache_file("gfx/netmen2.lmp");
    precache_file("gfx/netmen3.lmp");
    precache_file("gfx/netmen4.lmp");
    precache_file("gfx/netmen5.lmp");
    precache_file("gfx/sell.lmp");
    precache_file("gfx/help0.lmp");
    precache_file("gfx/help1.lmp");
    precache_file("gfx/help2.lmp");
    precache_file("gfx/help3.lmp");
    precache_file("gfx/help4.lmp");
    precache_file("gfx/help5.lmp");
    precache_file("gfx/pause.lmp");
    precache_file("gfx/loading.lmp");
    precache_file("gfx/p_option.lmp");
    precache_file("gfx/p_load.lmp");
    precache_file("gfx/p_save.lmp");
    precache_file("gfx/p_multi.lmp");
    precache_sound("misc/menu1.wav");
    precache_sound("misc/menu2.wav");
    precache_sound("misc/menu3.wav");
    precache_sound("ambience/water1.wav");
    precache_sound("ambience/wind2.wav");
};

entity lastspawn;

// use this for post world being setup (and entities loaded)
void WorldSpawnPost() 
{
    loadloc();
    FO_FlashDimension = -1;

    dremove(self);
}

void () worldspawn = {
    whichpack("textures/skins/fo_scout.png", 1); // ensures that fo_skins.pk3 is sent

    // Set this variable on connect so the client knows it has access to
    // FortressOne aliases.
    WriteByte(MSG_INIT, 9/*svc_stufftext*/);
    WriteString(MSG_INIT, "set fo_serverscripts 1\n");

    round_end_time = 0;

    vote_started = -1;
    local string st;

    lastspawn = world;
    number_of_teams = 0;

    if (self.model == "maps/e1m8.bsp")
        cvar_set("sv_gravity", "100");
    else
        cvar_set("sv_gravity", "800");

    cvar_set("pausable", "0");
    cvar_set("sv_friction", "6");
    cvar_set("sv_waterfriction", "1");
    if (teamplay == 0)
        cvar_set("teamplay", "1");

    if (infokey(world, "starttime") == string_null) {
        string timestamp = strftime(FALSE, "%Y%m%d%H%M%S");
        localcmd(strcat("serverinfo starttime \"", timestamp, "\"\n"));
    }

    localcmd("serverinfo fo_rev \"");
    localcmd(REV);
    localcmd("\"\n");
    localcmd("serverinfo gametype \"fortressone\"\n");

    st = infokey(world, "*sv_gamedir");
    if ((st != string_null) && (st != "fortress"))
        objerror("QW TF must be run with a sv_gamedir of \"fortress\".\n");
    else if (st == string_null) {
        if (infokey(world, "*gamedir") != "fortress")
            objerror
                ("QW TF must be run with a gamedir or sv_gamedir of \"fortress\".\n");
    }

    // get map config execution settings
    st = infokey(world, "exec_map_cfgs");
    if (st == "off")
        exec_map_cfgs = FALSE;
    else
        exec_map_cfgs = TRUE;

    if (exec_map_cfgs) {
        localcmd("exec cfg/default.cfg\n");
        localcmd("exec cfg/maps/");
        localcmd(mapname);
        localcmd(".cfg\n");
    }

    Vote_Reset();

    W_Precache();
	mcp_Precache();			   
    precache_sound("edge/backpack.wav");
    precache_sound("demon/dland2.wav");
    precache_sound("misc/h2ohit1.wav");
    precache_sound("items/itembk2.wav");
    precache_sound("player/plyrjmp8.wav");
    precache_sound("dash.wav");
    precache_sound("player/land.wav");
    precache_sound("player/land2.wav");
    precache_sound("player/drown1.wav");
    precache_sound("player/drown2.wav");
    precache_sound("player/gasp1.wav");
    precache_sound("player/gasp2.wav");
    precache_sound("player/h2odeath.wav");
    precache_sound("misc/talk.wav");
    precache_sound("player/teledth1.wav");
    precache_sound("misc/r_tele1.wav");
    precache_sound("misc/r_tele2.wav");
    precache_sound("misc/r_tele3.wav");
    precache_sound("misc/r_tele4.wav");
    precache_sound("misc/r_tele5.wav");
    precache_sound("weapons/lock4.wav");
    precache_sound("weapons/pkup.wav");
    precache_sound("items/armor1.wav");
    precache_sound("weapons/lhit.wav");
    precache_sound("weapons/lstart.wav");
    precache_sound("items/damage3.wav");
    precache_sound("misc/power.wav");
    precache_sound("player/gib.wav");
    precache_sound("player/udeath.wav");
    precache_sound("player/tornoff2.wav");
    precache_sound("player/pain1.wav");
    precache_sound("player/pain2.wav");
    precache_sound("player/pain3.wav");
    precache_sound("player/pain4.wav");
    precache_sound("player/pain5.wav");
    precache_sound("player/pain6.wav");
    precache_sound("player/death1.wav");
    precache_sound("player/death2.wav");
    precache_sound("player/death3.wav");
    precache_sound("player/death4.wav");
    precache_sound("player/death5.wav");
    precache_sound("boss1/sight1.wav");
    precache_sound("weapons/ax1.wav");
    precache_sound("player/axhit1.wav");
    precache_sound("player/axhit2.wav");
    precache_sound("player/h2ojump.wav");
    precache_sound("player/slimbrn2.wav");
    precache_sound("player/inh2o.wav");
    precache_sound("player/inlava.wav");
    precache_sound("misc/outwater.wav");
    precache_sound("player/lburn1.wav");
    precache_sound("player/lburn2.wav");
    precache_sound("misc/water1.wav");
    precache_sound("misc/water2.wav");
    precache_sound("items/protect.wav");
    precache_sound("items/protect2.wav");
    precache_sound("items/protect3.wav");
    precache_model("progs/player.mdl");
    precache_model("progs/eyes.mdl");
    precache_model("progs/h_player.mdl");
    precache_model("progs/gib1.mdl");
    precache_model("progs/gib2.mdl");
    precache_model("progs/gib3.mdl");
    precache_model("progs/s_bubble.spr");
    precache_model("progs/s_explod.spr");
    precache_model("progs/s_light.spr");
    precache_model("progs/v_axe.mdl");
    precache_model("progs/v_tranq.mdl");
    precache_model("progs/v_shot.mdl");
    precache_model("progs/v_nail.mdl");
    precache_model("progs/v_rock.mdl");
    precache_model("progs/v_pipe.mdl");
    precache_model("progs/v_flame.mdl");
    precache_model("progs/v_irock.mdl");
    precache_model("progs/v_shot2.mdl");
    precache_model("progs/v_nail2.mdl");
    precache_model("progs/v_rock2.mdl");
    precache_model("progs/grenade.mdl");
    precache_model("progs/bolt.mdl");
    precache_model("progs/bolt2.mdl");
    precache_model("progs/bolt3.mdl");
    precache_model("progs/lavaball.mdl");
    precache_model("progs/missile.mdl");
    precache_model("progs/spike.mdl");
    precache_model("progs/s_spike.mdl");
    precache_model("progs/backpack.mdl");
    precache_model("progs/zom_gib.mdl");
    precache_model("progs/v_light.mdl");
    precache_model2("progs/laser.mdl");
    precache_sound2("enforcer/enfire.wav");
    precache_sound2("enforcer/enfstop.wav");
    precache_model2("progs/sight.spr");
    precache_model2("progs/caltrop.mdl");
    precache_model2("progs/cross1.mdl");
    precache_model2("progs/tf_flag.mdl");
    precache_model2("progs/tf_stan.mdl");
    precache_model2("progs/v_medi.mdl");
    precache_model2("progs/hgren2.mdl");
    precache_model2("progs/blastgren.mdl");
    precache_model2("progs/flashgren.mdl");
    precache_model2("progs/biggren.mdl");
    precache_model2("progs/flare.mdl");
    precache_model2("progs/v_srifle.mdl");
    precache_model2("progs/v_asscan.mdl");
    precache_model2("progs/detpack.mdl");
    precache_model2("progs/ammobox.mdl");
    precache_model2("progs/v_knife.mdl");
    precache_model2("progs/v_knife2.mdl");
    precache_model2("progs/v_span.mdl");
    precache_model2("progs/e_spike1.mdl");
    precache_model2("progs/e_spike2.mdl");
    precache_model2("progs/v_rail.mdl");
    precache_model2("progs/turrgun.mdl");
    precache_model2("progs/turrbase.mdl");
    precache_model2("progs/tgib1.mdl");
    precache_model2("progs/tgib2.mdl");
    precache_model2("progs/tgib3.mdl");
    precache_model2("progs/disp.mdl");
    precache_model2("progs/dgib1.mdl");
    precache_model2("progs/dgib2.mdl");
    precache_model2("progs/dgib3.mdl");
    precache_model2("progs/grenade2.mdl");
    precache_model2("progs/v_grap.mdl");
    precache_model2("progs/caltrop.mdl");
    precache_model2("progs/deathbag.mdl");
    precache_model2("progs/discard.mdl");
    precache_sound("doors/baseuse.wav");
    precache_sound("doors/medtry.wav");
    precache_sound2("speech/saveme1.wav");
    precache_sound2("speech/saveme2.wav");
    precache_model2("progs/detpack2.mdl");
    precache_model2("progs/grenade3.mdl");
    precache_sound("grentimer.wav");
    precache_sound("mcp_grentimer1.wav");
    precache_sound("mcp_grentimer2.wav");
    precache_sound("mcp_grentimer3.wav");
    precache_sound("mcp_grentimer4.wav");
    precache_sound("mcp_grentimer5.wav");
    precache_sound("mcp_grentimer6.wav");
    precache_sound("mcp_grentimer7.wav");
    precache_sound("mcp_grentimer8.wav");
    precache_sound("mcp_grentimer9.wav");
    precache_sound("mcp_grentimer10.wav");
    precache_sound("mcp_grentimer11.wav");
    precache_sound("mcp_grentimer12.wav");
    precache_sound("mcp_grentimer13.wav");
    precache_sound("mcp_grentimer14.wav");
    precache_sound("mcp_grentimer15.wav");
    precache_sound("mcp_grentimer16.wav");
    precache_sound("mcp_grentimer17.wav");
    precache_sound("mcp_grentimer18.wav");
    precache_sound("mcp_grentimer19.wav");
    precache_sound("mcp_grentimer20.wav");
    precache_sound("mcp_grentimer21.wav");
    precache_sound("mcp_grentimer22.wav");
    precache_sound("mcp_grentimer23.wav");
    precache_sound("mcp_grentimer24.wav");
    precache_sound("mcp_grentimer25.wav");
    precache_sound("mcp_grentimer26.wav");
    precache_sound("buttons/switch04.wav");
    precache_sound("boss1/out1.wav");
    precache_sound("items/qpi2.wav");
    precache_sound("shalrath/death.wav");
    precache_sound("shalrath/attack2.wav");
    precache_sound("boss1/sight1.wav");
    precache_sound("misc/secret.wav");
    precache_sound("weapons/airblast.wav");
    precache_sound("weapons/airblastshoot.wav");
    lightstyle(0, "m");
    lightstyle(1, "mmnmmommommnonmmonqnmmo");
    lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
    lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
    lightstyle(4, "mamamamamama");
    lightstyle(5, "jklmnopqrstuvwxyzyxwvutsrqponmlkj");
    lightstyle(6, "nmonqnmomnmomomno");
    lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
    lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
    lightstyle(9, "aaaaaaaazzzzzzzz");
    lightstyle(10, "mmamammmmammamamaaamammma");
    lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
    lightstyle(63, "a");

    clientstat(STAT_TEAMNO, EV_FLOAT, team_no);
    clientstat(STAT_ALL_TIME, EV_FLOAT, all_time);
    clientstat(STAT_FLAGS, EV_FLOAT, stat_flags);
    clientstat(STAT_SPAWN_GEN, EV_FLOAT, spawn_gen);

    globalstat(STAT_ROUND_END, EV_FLOAT, "round_end_time");
    globalstat(STAT_PAUSED, EV_FLOAT, "cs_paused");
    globalstat(STAT_NOFIRE, EV_FLOAT, "no_fire_mode");
    globalstat(STAT_TEAMNO_ATTACK, EV_FLOAT, "team_no_attack");

    // login required cache
    local float flr = CF_GetSetting("flr", "fologinrequired", "1");
    backend_address = CF_GetSettingRaw("ba", "backend_address", "");
    fo_login_required = (flr && (backend_address != ""));

    entity worldspawnent;
    worldspawnent = spawn();
    worldspawnent.think = WorldSpawnPost;
    worldspawnent.nextthink = time + .01;
    votemode = CF_GetSetting("vm", "votemode", "off");
    vote_total_votes = 0;
    vote_style = CF_GetSetting("vs", "vote_style", "1"); 
    string votemap = FO_GetUserSettingString(world, "vote_map", "votemap", "se2");
    
    //No map candidates in map! Add some defaults...
    if(!find(world, classname, "map_candidate")) {
        InitVoteMaps();
    }
    if(votemode) {
        if(world.model != strcat("maps/",votemap,".bsp")) {
            bprint(PRINT_HIGH, "\bDisabling vote mode as map is not\b ",votemap,"\n");
            //changelevel(votemap);
            localcmd ("localinfo votemode 0\n"); 
            votemode = FALSE;
        } else {
        }
    } else if(!(vote_style & 4)) {
        if(world.model == strcat("maps/",votemap,".bsp")) {
            bprint(PRINT_HIGH, "\bEnabling vote mode as map is\b ",votemap,"\n");
            localcmd ("localinfo votemode on\n"); 
            votemode = TRUE;
            //changelevel(votemap);
        } else {
        }

    }

    dimension_send = DMN_NOFLASH;
    Predict_Init();
};

#if 0
// Alternate implementation, drop if simple version is sufficient.
static const float BODYQUEUE_MAX = 32;

static struct {
    entity queue[BODYQUEUE_MAX];
    float num;
} bodies;


void ClearBodyQueue() {
    for (float i = 0; i < bodies.nun; i++)
        remove(bodies.queue[i]);
    bodies.num = 0;
}


void FilterBodyQueue(entity filter) {
    float i = 0, j = 0, num = 0;

    while (j < bodies.num) {
        while (j < bodies.num && (bodies[j].heat > time || bodies[j].owner == filter))
            j++;
        if (j >= bodies.num)
            break;

        if (i != j) {
            remove(bodies[i]);
            bodies[i] = bodies[j];
        }
        num++;
        i++;
        j++;
    }

    bodies.num = num;
}
#endif

static const float BODYQUEUE_TIMEOUT = 15;
.entity bodyqueue;

void RemoveDeadBody(entity ent) {
    if (ent.bodyqueue == __NULL__)
        return;

    remove(ent.bodyqueue);
    ent.bodyqueue = __NULL__;
}

void FilterBodyQueue(float clear) {
    int count, i;
    entity* bodies = find_list(classname, "bodyqueue", EV_STRING, count);
    for (i = 0; i < count; i++)
        if (time > bodies[i].heat || clear)
            RemoveDeadBody(bodies[i].owner);
}

void AddToBodyQueue(entity ent) {
    if (cb_prematch)
        return;

    if (ent.model != "progs/player.mdl")
        return;  // in particular, filters out suicides

    if (ent.bodyqueue)
        RemoveDeadBody(ent);

    entity nb = spawn();
    nb.owner = ent;
    nb.heat = time + BODYQUEUE_TIMEOUT;
    nb.classname = "bodyqueue";

    nb.angles = ent.angles;
    nb.model = ent.model;
    nb.skin = ent.skin;
    nb.modelindex = ent.modelindex;
    nb.frame = ent.frame;
    nb.colormap = ent.colormap;
    nb.movetype = ent.movetype;
    nb.velocity = ent.velocity;
    nb.flags = 0;
    setorigin(nb, ent.origin);
    setsize(nb, ent.mins, ent.maxs);

    nb.dimension_seen = DMN_NOFLASH;

    ent.bodyqueue = nb;
};

void () StartFrame = {
    teamplay = cvar("teamplay");
    timelimit = cvar("timelimit") * 60;
    fraglimit = cvar("fraglimit");
    deathmatch = cvar("deathmatch");

    static float next_stale_check;
    if (time > next_stale_check) {
        TerminateStaleServer();
        next_stale_check = time + 60;
    }

    static float next_filter_bodyqueue;
    if (time > next_filter_bodyqueue) {
        FilterBodyQueue(FALSE);
        next_filter_bodyqueue = time + 0.5;
    }
};

// this is used for spawning world objects on map load.. not player, projectiles etc - also disables the engine's conditional spawning based on spawnflags, you're expected to do that part yourself
void(void() fnc)CheckSpawn = {
    if(fnc)
    {
        if (self.dimension_seen != DMN_INVISIBLE)
            self.dimension_seen = self.dimension_seen | DMN_NOFLASH | DMN_FLASH;
        //bprint(PRINT_HIGH, strcat("spawning: ", self.classname, "\n"));
        fnc();
    }
    else 
    {
        remove(self);
    }
};

static const float STALE_TIME_HOURS = 6;
void () TerminateStaleServer = {
    if (gettime() < STALE_TIME_HOURS * 3600)
        return;

    for (entity e = world; (e = find(e, classname, "player")); ) {
        if (!e.has_disconnected)
            return; //someone is around
    }

    Admin_UpdateServer();

    dprint(sprintf("Terminating empty server with more than %d hours uptime\n",
                   STALE_TIME_HOURS));
    localcmd("quit\n");
}
