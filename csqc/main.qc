void FO_Hud_Editor();
void Hud_Draw(float width, float height);
void FO_Hud_Editor_LoadSettings(string);
void FO_Hud_Editor_LoadDefaultSettings();
void FO_Hud_Editor_List_Panels();
void FO_Hud_Editor_Show_Panel(string panelid);
void FO_Hud_Editor_Print_Panel_Setting(string panelid, string setting);
void FO_Hud_Editor_Set_Panel_Setting(string panelid, string setting, string value);
void Hud_WriteCfg(string path);
void FO_LoadSettings();
void FO_WriteSettings();
void AddGrenTimer(float grentype, float offset);
void ApplyTransparencyToGrenTimer();
void StopGrenTimers();
float IsValidToUseGrenades();
void Sync_GameState();

void GetSelf() = {
    self = findfloat(world, entnum, player_localentnum);
}

noref void(float apiver, string enginename, float enginever) CSQC_Init = {
    print("CSQC Started\n");

    //    precache_model("progs/weapons/v_rock.mdl");

//     for (float i = 0; i < HudIcons.length; i++) {
//         precache_pic(HudIcons[i].icon);
//     }

    registercommand("fo_hud_editor");
    registercommand("fo_hud_reload");
    registercommand("fo_hud_reset");
    registercommand("fo_hud");
    registercommand("fo_hud_save");
    registercommand("fo_hud_load");

    registercvar(FOCMD_GRENTIMER, "1");
    registercvar(FOCMD_GRENTIMERSOUND, "grentimer.wav");
    registercvar(FOCMD_GRENTIMERVOLUME, "1");
    registercvar(FOCMD_JUMPVOLUME, "1");

    registercommand("fo_menu_game");
    registercommand("fo_main_menu");
    registercommand("fo_menu_team");
    registercommand("fo_menu_class");
    registercommand("fo_menu_admin");
    registercommand("fo_menu_vote");
    registercommand("fo_menu_special");
    registercommand("fo_menu_disguise");
    registercommand("fo_menu_build");
    registercommand("fo_menu_dropammo");
    registercommand("fo_menu_cancel");
    registercvar(FOCMD_ADMIN_MENU_UPDATE_TIME, "2");

    registercommand("+aux_jump");
    registercommand("-aux_jump");
    registercommand("+special");
    registercommand("-special");
    registercommand("+special2");
    registercommand("-special2");
    registercommand("+grenade1");
    registercommand("-grenade1");
    registercommand("+grenade2");
    registercommand("-grenade2");
    registercommand("+dropflag");
    registercommand("-dropflag");
    registercommand("+rj");
    registercommand("-rj");
    // registercommand("+quick1");
    // registercommand("-quick1");
    // registercommand("+quick2");
    // registercommand("-quick2");
    // registercommand("+quick3");
    // registercommand("-quick3");
    // registercommand("+quick4");
    // registercommand("-quick4");
    registercommand("tracktarget");
    registercommand("+fo_showscores");
    registercommand("-fo_showscores");

    registercommand("vote_addmap");
    registercommand("vote_removemap");
    registercvar("fo_hud_idle_alpha", "0.3");
    for(float i = 0; i < MENU_OPTION.length - 1; i++) {
        registercvar(strcat("fo_menu_option_",MENU_OPTION[i]), MENU_OPTION[i]);
    }
    registercvar("fo_menu_option_+", "=");

    FO_Hud_Editor_LoadSettings(FO_HUD_CONFIG_PATH);
    FO_LoadSettings();
    
    MenuPanel = getAnyHudPanelByNamePointer("menu");
    
    CurrentMenu = &FO_MENU_TEAM;
    player_menu_type = 0;
    is_admin = FALSE;
    grentimer_waiting = FALSE;
    jump_counter = 0;

    num_mapvotes = 0;
    vote_selected_item = world;
    vote_selected_index = -1;
    vote_list_offset = 0;
    current_vote = world;
    vote_list_filter = "";
    MouseDown = 0;
};

noref void() CSQC_WorldLoaded = {
    print("CSQC World Loaded\n");
    localcmd("menu_restart\n");
}

float current_pmove_onground;
float current_pmove_vel_z;

noref void(float width, float height, float menushown) CSQC_UpdateView = {

    clearscene();
    setproperty(VF_DRAWWORLD, 1); 		// we want to draw our world!
    setproperty(VF_DRAWCROSSHAIR, 1);		 // we want to draw our crosshair!

    // Draw original sbar, viewsize honoured automatically.
    if (!CVARF(fo_fte_hud) || CVARF(fo_legacy_sbar))
        setproperty(VF_DRAWENGINESBAR, 1);

    addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE); 		// add entities with these rendermask field var's to our view

    renderscene();

    ScreenSize = [width, height, menushown];
    SBAR.Hint = "";
    sui_begin(width, height);
    Menu_Draw(width, height, menushown);
    Hud_Draw(width, height);
    sui_end();

    // We cache these here because until we're running physics it's the only
    // place to snoop them.
    current_pmove_onground = pmove_onground;
    current_pmove_vel_z = pmove_vel_z;
}

noref float(string cmd) CSQC_ConsoleCommand = {
    tokenize_console(cmd);
    float val;
    string key1, key2;
    local float grentype;

    switch(argv(0)) {
        case "fo_hud_editor":
            FO_Hud_Editor();
            break;
        case "fo_hud":
            if(argv(1) == "") {
                FO_Hud_Editor_List_Panels();
            } else if(argv(3) == "") {
                FO_Hud_Editor_Print_Panel_Setting(argv(1), argv(2));
            } else {
                FO_Hud_Editor_Set_Panel_Setting(argv(1), argv(2), argv(3));
            }
            break;
        case "fo_hud_save":
            if(argv(1) != "") {
                Hud_WriteCfg(argv(1));
            } else {
                Hud_WriteCfg(FO_HUD_CONFIG_PATH);
            }
            break;
        case "fo_hud_reload":
            FO_Hud_Editor_LoadSettings(FO_HUD_CONFIG_PATH);
            break;
        case "fo_hud_reset":
            FO_Hud_Editor_LoadDefaultSettings();
            break;
        case "fo_hud_load":
            if(argv(1) != "") {
                FO_Hud_Editor_LoadSettings(argv(1));
            }
            break;
        case "fo_menu_game":
            FO_Menu_Game(TRUE);
            break;
        case "fo_menu_team":
            FO_Menu_Team(TRUE);
            break;
        case "fo_menu_class":
            FO_Menu_Class(TRUE);
            break;
        case "fo_main_menu":
            if(checkcommand("m_main")) {
                //Use menuqc main menu
                localcmd("m_main\n");
            } else {
                //If menu.dat is missing, fall back to engine menus
                localcmd("menu_main\n");
            }
            break;
        case "fo_menu_admin":
            FO_Menu_Admin_Main(TRUE);
            break;
        case "fo_menu_vote":
            //FO_Menu_Vote(TRUE);
            showVoteMenu(!Hud_Panels[HUD_PANEL_MAP_MENU].Display);
            break;
        case "fo_menu_special":
            FO_Menu_Special(TRUE);
            break;
        case "fo_menu_disguise":
            FO_Menu_Spy_Skin(TRUE);
            break;
        case "fo_menu_build":
            FO_Menu_Build(TRUE);
            break;
        case "fo_menu_dropammo":
            FO_Menu_DropAmmo(TRUE, 1, (player_class == PC_ENGINEER));
            break;
        case "fo_menu_cancel":
            Menu_Cancel();
            break;
        case "+fo_showscores":
            if (cvar(FOCMD_OLDSCOREBOARD) == 1)
            {
                tokenize(findkeysforcommand(argv(0)));

                key1 = argv(0);
                key2 = argv(1);
                if (key1 != "") key1 = (key1=="-1")?"":keynumtostring(stof(key1));
                if (key2 != "") key2 = (key2=="-1")?"":keynumtostring(stof(key2));

                if (key1 != "")
                {
                    localcmd(sprintf("unbind %s\n", key1));
                    localcmd(sprintf("bind %s +showscores\n", key1));
                }

                if (key2 != "")
                {
                    localcmd(sprintf("unbind %s\n", key2));
                    localcmd(sprintf("bind %s +showscores\n", key2));
                }
            }
            FO_Show_Scores(TRUE);
            break;
        case "-fo_showscores":
            FO_Show_Scores(FALSE);
            break;
        case "+showscores":
        case "+showteamscores":
            showingscores = TRUE;
            if (cvar(FOCMD_OLDSCOREBOARD) != 1)
            {
                tokenize(findkeysforcommand(argv(0)));

                key1 = argv(0);
                key2 = argv(1);
                if (key1 != "") key1 = (key1=="-1")?"":keynumtostring(stof(key1));
                if (key2 != "") key2 = (key2=="-1")?"":keynumtostring(stof(key2));

                if (key1 != "")
                {
                    localcmd(sprintf("unbind %s\n", key1));
                    localcmd(sprintf("bind %s +fo_showscores\n", key1));
                }

                if (key2 != "")
                {
                    localcmd(sprintf("unbind %s\n", key2));
                    localcmd(sprintf("bind %s +fo_showscores\n", key2));
                }
            }
            if(CVARF(fo_fte_hud)) {
                FO_Show_Scores(TRUE);
            }
            break;
        case "-showscores":
        case "-showteamscores":
            showingscores = FALSE;
            if(CVARF(fo_fte_hud)) {
                FO_Show_Scores(FALSE);
            }
            break;
        case "tracktarget":
            localcmd("cmd tracktarget\n");
            break;
        case "+aux_jump":
            jump_counter++;
            localcmd("+jump\n");
            break;
        case "-aux_jump":
            jump_counter--;

            if (jump_counter < 0) {
                jump_counter = 0;
            }

            if (!jump_counter) {
                localcmd("-jump\n");
            }

            break;
        case "+special":
            localcmd("+button3\n");
            break;
        case "-special":
            localcmd("-button3\n");
            break;
        case "+special2":
            localcmd("+button4\n");
            break;
        case "-special2":
            localcmd("-button4\n");
            break;
        case "+grenade1":
            localcmd("+button5\n");
            break;
        case "-grenade1":
            localcmd("-button5\n");
            break;
        case "+grenade2":
            localcmd("+button6\n");
            break;
        case "-grenade2":
            localcmd("-button6\n");
            break;
        case "+dropflag":
            localcmd("+button7\n");
            break;
        case "-dropflag":
            localcmd("-button7\n");
            break;
        // case "+quick1":
        //     localcmd("+button8\n");
        //     break;
        // case "-quick1":
        //     localcmd("-button8\n");
        //     break;
        // case "+quick2":
        //     localcmd("+button9\n");
        //     break;
        // case "-quick2":
        //     localcmd("-button9\n");
        //     break;
        // case "+quick3":
        //     localcmd("+button10\n");
        //     break;
        // case "-quick3":
        //     localcmd("-button10\n");
        //     break;
        // case "+quick4":
        //     localcmd("+button11\n");
        //     break;
        // case "-quick4":
        //     localcmd("-button11\n");
        //     break;
        case "+rj":
            if (player_class == PC_SOLDIER || player_class == PC_PYRO) {
                localcmd("+button4\n");
            }
            break;
        case "-rj":
            if (player_class == PC_SOLDIER || player_class == PC_PYRO) {
                localcmd("-button4\n");
            }
            break;
        case "vote_addmap":
            AddVoteMap(argv(1),argv(2),argv(3),stof(argv(4)),stof(argv(5)),stof(argv(6)),TRUE);
            break;
        case "vote_removemap":
            RemoveVoteMap(argv(1), TRUE);
            break;
    }

    return FALSE;
};

void(float isnew) CSQC_Ent_Update = {
    print("CSQC_Ent_Update, new: ", ftos(isnew), "\n");
    float etype = readbyte();
    string s;
    switch (etype) {
        case MSG_FLAGINFO:
            s = readstring();
            print("CSQC_Ent_Update, Flag info: ", s, "\n");
            break;
        default:
            error("Unhandled CSQC entity\n"); //you can change it to a print, but if you're not using sv_csqcdebug 1 doing so would just confuse people over the real cause.
            return;
    }
};
void() CSQC_Ent_Remove = {   //the entity in question left the player's pvs, and will no longer be tracked...
    print("CSQC_Ent_Remove\n");
    remove(self);
};

noref void CSQC_Input_Frame() {
    local float changed_buttons = input_buttons ^ oldbuttons;
    oldbuttons = input_buttons;

    local float keydowns = changed_buttons & input_buttons;
    local float keyups = changed_buttons & ~input_buttons;

    // Intercept rocket jump;
    if ((player_class == PC_SOLDIER || player_class == PC_PYRO) && input_buttons & BUTTON4) {
        input_buttons |= BUTTON0 + BUTTON2;
    }

    // Intercept zoom
    if (player_class == PC_SNIPER && keydowns & BUTTON3) {
        zoomed_in = !zoomed_in;
    }

    Sync_GameState();
}

float(float save, float take, vector inflictororg) CSQC_Parse_Damage = {
    local float health = getstatf(STAT_HEALTH);
    //pain face is 0.2 long
    if(oldhealth > health) {
        painfinished = time + 0.2;
    }
    return 0;
}

void CSQC_Shutdown() = {
    FO_WriteSettings();
}

void ApplyTransparencyToGrenTimer() {
    for(float i = 0; i < FO_Hud_Grentimers.length; i++) {
        if (FO_Hud_Grentimers[i].grentype != 0 && FO_Hud_Grentimers[i].alpha != 0.3) {
            FO_Hud_Grentimers[i].alpha = 0.3;
            break;
        }
    }
}

void StopGrenTimers() {
    soundupdate(self, CHAN_GREN1, "", 0, 0, 0, 0, 0);
    soundupdate(self, CHAN_GREN2, "", 0, 0, 0, 0, 0);
    soundupdate(self, CHAN_GREN3, "", 0, 0, 0, 0, 0);
    soundupdate(self, CHAN_GREN4, "", 0, 0, 0, 0, 0);
    soundupdate(self, CHAN_GREN5, "", 0, 0, 0, 0, 0);

    for(float i = 0; i < FO_Hud_Grentimers.length; i++) {
        FO_Hud_Grentimers[i].grentype = 0;
        FO_Hud_Grentimers[i].expires = 0;
        FO_Hud_Grentimers[i].icon_index = 0;
    }
}

float last_servercommandframe;
void _Sync_ServerCommandFrame() {
    // Server command frames are monotonically unique, we can skip processing
    // unless there is new state.
    if (last_servercommandframe == servercommandframe)
        return;
    last_servercommandframe = servercommandframe;

    team_no = getstatf(STAT_TEAMNO);
    is_observer = FALSE;
    if (team_no == 0)
        is_observer = TRUE;
    player_class = getstatf(STAT_CLASS);
    SBAR.ReadyStatus = getstatf(STAT_FLAGS);
    oldhealth = getstatf(STAT_HEALTH);
    is_spectator = stof(getplayerkeyvalue(player_localnum, "*spectator"));
    if (is_spectator)
        is_observer = FALSE;

    vector vel = [getstatf(STAT_VELOCITY_X), getstatf(STAT_VELOCITY_Y),
                  getstatf(STAT_VELOCITY_Z)];
    speed = sqrt(vel.x * vel.x + vel.y * vel.y);

    local float health = getstatf(STAT_HEALTH);
    if (health <= 0 || player_class != PC_SNIPER) {
        zoomed_in = 0;
    }

    if (zoomed_in) {
        setviewprop(VF_AFOV, cvar("fov")/3);
        setsensitivityscaler(1/3);
    } else {
        setviewprop(VF_AFOV, cvar("fov"));
        setsensitivityscaler(1);
    }
}

float last_pmove_onground;
float last_vel_z;
float last_clientcommandframe;

// REQUIRES: Must be called after _Sync_ServerCommandFrame.
void _Sync_ClientCommandFrame() {
    // Client command frames are regenerated beyond the server frame, so we
    // cannot check that we have not seen this client command frame alone.
    if (last_servercommandframe == servercommandframe &&
        last_clientcommandframe == clientcommandframe)
        return;
    last_clientcommandframe = clientcommandframe;

    local float paused = getstatf(STAT_PAUSED);
    local float health = getstatf(STAT_HEALTH);

    if (current_pmove_onground && health > 0 && !paused) {
        // The pmove_vel_z < 180 check makes sure you're not sliding
        if (input_buttons & BUTTON2 && pmove_vel_z < 180) {
            localsound("player/plyrjmp8.wav", CHAN_BODY, cvar(FOCMD_JUMPVOLUME));
        }

        if (!last_pmove_onground) {
            if (last_vel_z < -650) {
                localsound("player/land2.wav", CHAN_AUTO, 1);
            } else if (last_vel_z < -300) {
                localsound("player/land.wav", CHAN_AUTO, 1);
            }
        }
    }

    last_vel_z = current_pmove_vel_z;
    last_pmove_onground = current_pmove_onground;
}

// Called for each {client, server} command frame, ensures globals are
// synchronized with server and predicted state.
void Sync_GameState() {
    _Sync_ServerCommandFrame();
    _Sync_ClientCommandFrame();
}
