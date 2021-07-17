void FO_Hud_Editor();
void Hud_Draw(float width, float height);
void FO_Hud_Editor_LoadSettings();
void FO_Hud_Editor_LoadDefaultSettings();
void FO_Hud_Editor_List_Panels();
void FO_Hud_Editor_Show_Panel(string panelid);
void FO_Hud_Editor_Print_Panel_Setting(string panelid, string setting);
void FO_Hud_Editor_Set_Panel_Setting(string panelid, string setting, string value);
void Hud_WriteCfg(string path);
void FO_LoadSettings();
void FO_WriteSettings();
void AddGrenTimer(float grentype);

void GetSelf() = {
    self = findfloat(world, entnum, player_localentnum);
}

noref void(float apiver, string enginename, float enginever) CSQC_Init = {
    print("CSQC Started\n");

    //    precache_model("progs/weapons/v_rock.mdl");

    for (float i = 0; i < HudIcons.length; i++) {
        precache_pic(HudIcons[i].icon);
    }

    registercommand("fo_hud_editor");
    registercommand("fo_hud_reload");
    registercommand("fo_hud_reset");
    registercommand("fo_hud");
    registercommand("fo_hud_save");

    registercvar(FOCMD_AUTOHOP, "0");
    registercvar(FOCMD_GRENTIMER, "1");
    registercvar(FOCMD_OLDSCOREBOARD, "0");

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

    registercommand("primeone");
    registercommand("primetwo");
    registercommand("gren1");
    registercommand("gren2");
    registercommand("+aux_jump");
    registercommand("-aux_jump");
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

    FO_Hud_Editor_LoadSettings();
    FO_LoadSettings();

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

noref void(float width, float height, float menushown) CSQC_UpdateView = {
    ScreenSize = [width, height, menushown];
    team_no = getstatf(STAT_TEAMNO);
    is_observer = FALSE;
    if (team_no == 0)
        is_observer = TRUE;
    player_class = getstatf(STAT_CLASS);
    SBAR.Ready = getstatf(STAT_READY);
    is_spectator = stof(getplayerkeyvalue(player_localnum, "*spectator"));
    if (is_spectator)
        is_observer = FALSE;
    SBAR.Hint = "";
    //stop grentimer on death

    if(getstatf(STAT_HEALTH) <= 0) {
        //localcmd("stopsound\n");
        for(float i = 0; i < FO_Hud_Grentimers.length; i++) {
            FO_Hud_Grentimers[i].grentype = 0;
            FO_Hud_Grentimers[i].expires = 0;
            FO_Hud_Grentimers[i].icon_index = 0;
        }
    }
    clearscene();
    setproperty(VF_DRAWWORLD, 1); 		// we want to draw our world!
    setproperty(VF_DRAWCROSSHAIR, 1);		 // we want to draw our crosshair!
    setproperty(VF_DRAWENGINESBAR, 1);		/* boolean. If set to 1, the sbar will be drawn, and viewsize will be honoured automatically. */
    //setviewprop(VF_ORIGIN, '0 0 0');        //view position of the scene (after view_ofs effects).
    //setviewprop(VF_ANGLES, '0 0 0');        //override the view angles. input will work as normal. other players will see your player as normal. your screen will just be pointing a different direction.
    //setviewprop(VF_DRAWWORLD, 1);            //whether the world entity should be drawn. set to 0 if you want a completely empty scene.
    //setviewprop(VF_MIN, '0 0 0');            //top-left coord (x,y) of the scene viewport in virtual pixels (or annoying physical pixels in dp).
    //setviewprop(VF_SIZE, [width, height, 0]);    //virtual size (width,height) of the scene viewport in virtual pixels (or annoying physical pixels in dp).
    //setviewprop(VF_AFOV, cvar("fov”));        //note: fov_x and fov_y control individual axis. afov is general
    //setviewprop(VF_PERSPECTIVE, 1);        //1 means like quake and other 3d games. 0 means isometric.
    addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE); 		// add entities with these rendermask field var's to our view

    renderscene();

    sui_begin(width, height);
    Menu_Draw(width, height, menushown);
    Hud_Draw(width, height);
    sui_end();

    //reset grentimer status if all there are no more active grentimers
    if(grentimer_waiting) {
        if(FO_Hud_Grentimers[0].grentype == 0) {
            grentimer_waiting = FALSE;
        }
    }
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
            Hud_WriteCfg(FO_HUD_CONFIG_PATH);
            break;
        case "fo_hud_reload":
            FO_Hud_Editor_LoadSettings();
            break;
        case "fo_hud_reset":
            FO_Hud_Editor_LoadDefaultSettings();
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
        case "primeone":
            if(getstatf(STAT_HEALTH) > 0 && (!SBAR.GameMode || ((SBAR.GameMode & GAMEMODE_QUAD) && round_active) || (((SBAR.GameMode & GAMEMODE_DUEL) || (SBAR.GameMode & GAMEMODE_CLAN)) && !prematch && !round_over))) {
                if(!grentimer_waiting) {
                    if(cvar(FOCMD_GRENTIMER) == 2 && SBAR.Gren1) {
                        localcmd("play grentimer.wav\n");
                        grentype = GetGrenOneTypeForClass(SBAR.PlayerClass);
                        AddGrenTimer(grentype);
                    }

                    grentimer_waiting = TRUE;
                }
                localcmd("primeone_server");
            }
            break;
        case "primetwo":
            if(getstatf(STAT_HEALTH) > 0 && (!SBAR.GameMode || ((SBAR.GameMode & GAMEMODE_QUAD) && round_active) || (((SBAR.GameMode & GAMEMODE_DUEL) || (SBAR.GameMode & GAMEMODE_CLAN)) && !prematch && !round_over))) {
                if(!grentimer_waiting) {
                    if(cvar(FOCMD_GRENTIMER) == 2 && SBAR.Gren2) {
                        localcmd("play grentimer.wav\n");
                        grentype = GetGrenTwoTypeForClass(SBAR.PlayerClass);
                        AddGrenTimer(grentype);
                    }
                    grentimer_waiting = TRUE;
                }
                localcmd("primetwo_server");
            }
            break;
        case "gren1":
            if(getstatf(STAT_HEALTH) > 0 && (!SBAR.GameMode || ((SBAR.GameMode & GAMEMODE_QUAD) && round_active) || (((SBAR.GameMode & GAMEMODE_DUEL) || (SBAR.GameMode & GAMEMODE_CLAN)) && !prematch && !round_over))) {
                if(!grentimer_waiting) {
                    if(cvar(FOCMD_GRENTIMER) == 2 && SBAR.Gren1) {
                        localcmd("play grentimer.wav\n");
                        grentype = GetGrenOneTypeForClass(SBAR.PlayerClass);
                        AddGrenTimer(grentype);
                    }
                    grentimer_waiting = TRUE;
                }
                localcmd("gren1_server");
            }
            break;
        case "gren2":
            if(getstatf(STAT_HEALTH) > 0 && (!SBAR.GameMode || ((SBAR.GameMode & GAMEMODE_QUAD) && round_active) || (((SBAR.GameMode & GAMEMODE_DUEL) || (SBAR.GameMode & GAMEMODE_CLAN)) && !prematch && !round_over))) {
                if(!grentimer_waiting) {
                    if(cvar(FOCMD_GRENTIMER) == 2 && SBAR.Gren2) {
                        localcmd("play grentimer.wav\n");
                        grentype = GetGrenTwoTypeForClass(SBAR.PlayerClass);
                        AddGrenTimer(grentype);
                    }
                    grentimer_waiting = TRUE;
                }
                localcmd("gren2_server");
            }
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
            break;
        case "-showscores":
        case "-showteamscores":
            showingscores = FALSE;
            break;
        case "tracktarget":
            localcmd("cmd tracktarget\n");
            break;
        case "+aux_jump":
            jump_counter = jump_counter + 1;
            localcmd("+jump");
            break;
        case "-aux_jump":
            jump_counter = jump_counter - 1;
            if (jump_counter <= 0) {
                jump_counter = 0;
                localcmd("-jump");
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
    if (cvar(FOCMD_AUTOHOP) == 1 && input_buttons&2 && getstatf(STAT_HEALTH) > 0) {
        if (pmove_onground) {
            frames_since_onground = 0;
        } else {

            // next two frames after leaving ground
            if (frames_since_onground <= 2) {
                frames_since_onground = frames_since_onground + 1;

            // third frame after leaving ground
            } else if (frames_since_onground == 3) {
                input_buttons &= ~2;
                frames_since_onground = frames_since_onground + 1;
            }
        }
    }
}

void CSQC_Shutdown() = {
    FO_WriteSettings();
}
