void FO_Hud_Editor();
void Hud_Draw(float width, float height);
void FO_Hud_Editor_LoadSettings(string);
void FO_Hud_Editor_LoadDefaultSettings();
void FO_Hud_Editor_List_Panels();
void FO_Hud_Editor_Print_Panel_Setting(string, string setting);
void FO_Hud_Editor_Set_Panel_Setting(string, string setting, string value);
void Hud_WriteCfg(string path);
void AddGrenTimer(float grentype, float offset);
void StopGrenTimers();
float IsValidToUseGrenades();
void Sync_GameState();
float FoLogin(string token, float print_error);
void Perf_Status();
void FO_Hud_Init();
float InFluid(vector point);
float CalculateWaterLevel();
void RenderHitTexts();
entity sentry_preview;
entity sentry_preview_range_sphere;
float sentry_preview_offset;
float previewing_sentry;
float prevent_firing;
float sentry_fits;

void GetSelf() = {
    self = findfloat(world, entnum, player_localentnum);
}

void PushToSlotHistory(float value) {
    if (slot_history_top >= MAX_SLOT_HISTORY_SIZE) {
        // Stack is full
        return;
    }
    slot_history[slot_history_top] = value;
    if (slot_history_top == 0) {
        Slot slot = !IsSlotNull(pstate_pred.queue_slot) ?
            pstate_pred.queue_slot : pstate_pred.current_slot;
        slot_under_stack = SlotIndex(slot) + 1;
    }
    slot_history_top += 1;
}

float RemoveFromSlotHistory(float slot) {
    for (float i = slot_history_top - 1; i >= 0; i--) {
        if (slot_history[i] == slot) {
            for (float j = i+1; j < MAX_SLOT_HISTORY_SIZE; j++) {
                slot_history[j-1] = slot_history[j];
            }

            slot_history[MAX_SLOT_HISTORY_SIZE-1] = 0;
            slot_history_top--;
            break;
        }
    }

    if (slot_history_top > 0) {
        return slot_history[slot_history_top - 1];
    } else {
        if (CVARF(fo_default_weapon))
            return CVARF(fo_default_weapon);
        else
            return slot_under_stack;
    }
}

static void BindAlias(TFAlias* tfa) {
    if (tfa->impulse == 0 && tfa->cmd == "")  // Some aliases are !csqc-only
        return;

    if (tfa->impulse)
        localcmd(sprintf("alias %s impulse %d\n", tfa->alias, tfa->impulse));
    else
        localcmd(strcat("alias ", tfa->alias, " \"", tfa->cmd, "\"\n"));
}

static void SetupAliases() {
    float i;

    for (i = 0; i < client_aliases.length; i++)
        BindAlias(&client_aliases[i]);

    for (i = 0; i < csqc_aliases.length; i++)
        BindAlias(&csqc_aliases[i]);

    print("Aliases set\n");
}

DECLARE_PERF_SAMPLER(frame_timing, 60, 0.1);
DECLARE_PERF_SAMPLER(hud_timing, 60, 0.1);
DECLARE_PERF_SAMPLER(hud_partial_timing, 60, 0.1);

void ClientSettings_Check();

noref void(float apiver, string enginename, float enginever) CSQC_Init = {
    print("CSQC Started\n");


    //     for (float i = 0; i < HudIcons.length; i++) {
    //         precache_pic(HudIcons[i].icon);
    //     }

    INIT_PERF_SAMPLER(frame_timing);
    INIT_PERF_SAMPLER(hud_timing);
    INIT_PERF_SAMPLER(hud_partial_timing);

    FO_Hud_Init();
    FO_Weapons_Init();
    Predict_InitDefaultConfig();
    FO_Predict_Init();
    CsGrenTimer::Init();

    registercommand("specialup");
    registercommand("specialdown");

    registercommand("zoomin");
    registercommand("zoomout");

    registercommand("+slot");
    registercommand("-slot");

    registercommand("fo_beta_pmove");
    registercommand("fopm_cmd");

    registercommand("login");
    registercommand("fo_hud_editor");
    registercommand("fo_hud_reload");
    registercommand("fo_hud_reset");
    registercommand("fo_hud");
    registercommand("fo_hud_save");
    registercommand("fo_hud_load");

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

    registercommand("fo_min_ping");

    registercommand("+aux_jump");
    registercommand("-aux_jump");
    registercommand("+rj");
    registercommand("-rj");

    registercommand("slot_a");

    registercommand("+fo_showscores");
    registercommand("-fo_showscores");
    registercommand("fo_settings_check");

    registercommand("vote_addmap");
    registercommand("vote_removemap");

    registercommand("wpp_status");
    registercommand("perf_status");
    for(float i = 0; i < MENU_OPTION.length - 1; i++) {
        registercvar(strcat("fo_menu_option_",MENU_OPTION[i]), MENU_OPTION[i]);
    }
    registercvar("fo_menu_option_+", "=");

    FO_Hud_Editor_LoadSettings(FO_HUD_CONFIG_PATH);

    MenuPanel = getHudPanel(HUDP_MENU);

    is_admin = FALSE;
    jump_counter = 0;

    num_mapvotes = 0;
    vote_selected_item = world;
    vote_selected_index = -1;
    vote_list_offset = 0;
    current_vote = world;
    vote_list_filter = "";

    PM_Init();
    TF_Init();

    ClientSettings_Check();
    SetupAliases();

    CurrentMenu = &FO_MENU_TEAM;
    player_menu_type = 0;
    FO_Menu_Game(TRUE);

    pengine.view_mask = MASK_VIEWMODEL;  // Start with engine models.

    precache_model("progs/turrpreview.mdl");
    sentry_preview = spawn();
    setmodel(sentry_preview, "progs/turrpreview.mdl");
    sentry_preview.alpha = 0.25;

    precache_model("progs/sphere.mdl");
    sentry_preview_range_sphere = spawn();
    setmodel(sentry_preview_range_sphere, "progs/sphere.mdl");
    sentry_preview_range_sphere.scale = 1000;
    sentry_preview_range_sphere.alpha = 0.02;

    zoom_scale = 1;

    print("CSQC initialization finished\n");
};

noref void() CSQC_WorldLoaded = {
    localcmd("menu_restart\n");
    // Resolve race condition where models packed into map package sometimes do
    // not resolve correctly.
    localcmd("flush\n");
    localcmd("cl_smartjump 0\n");  // replaced by fo_smartjump
}

void FO_CussView();
void FO_CussCrosshair(float width, float height);
void Hud_UpdateView(float width, float height, float menushown, float perf_sample);
void UpdateTeamColorCrosshair();
void PMD_DrawGraphs(float width);

DEFCVAR_FLOAT(fov, 90);

noref void(float width, float height, float menushown) CSQC_UpdateView = {
    float fts = perf_start_sample(&frame_timing);
    clearscene();
    setproperty(VF_DRAWWORLD, 1); 		// we want to draw our world!

    FO_CussView();

    setviewprop(VF_AFOV, CVARF(fov)/zoom_scale);
    setsensitivityscaler(1/zoom_scale);

    // Draw original sbar, viewsize honoured automatically.
    if (!CVARF(fo_fte_hud) || CVARF(fo_legacy_sbar))
        setproperty(VF_DRAWENGINESBAR, 1);

    float mask = MASK_ENGINE;
    if (!intermission)
        mask |= WPP_ViewModelMask();
    addentities(mask);

    if (PM_Enabled())
        PM_UpdateView();

    if (previewing_sentry) {
        makevectors(view_angles);
        local vector v_forward_sentry;
        v_forward_sentry.z = (normalize(v_forward) * 64).z;
        v_forward_z = 0;
        local vector xy_pos = normalize(v_forward) * 64;
        v_forward_sentry.x = xy_pos.x;
        v_forward_sentry.y = xy_pos.y;

        sentry_preview.origin = PM_Org() + v_forward_sentry;
        sentry_preview_range_sphere.origin = sentry_preview.origin;
        sentry_preview.angles_y = anglemod(view_angles_y + sentry_preview_offset);
    } else {
        setproperty(VF_DRAWCROSSHAIR, 1);       // we want to draw our crosshair!
    }

    renderscene();

    FO_CussCrosshair(width, height);

    TFxRenderGrenadeTimers();
    RenderHitTexts();
    Hud_UpdateView(width, height, menushown, fts);
    PMD_DrawGraphs(width);

    perf_finish_sample(&frame_timing, fts);

    // Work around bug in some versions of FTE.  See pmove.qc
    recent_pmove_vel_z = pmove_vel_z;
}

void Slot_Keydown(float slot) {
    PushToSlotHistory(slot);

    localcmd(sprintf("impulse %d\n+attack\n", TF_SLOT1 + slot - 1));
}

void Slot_Keyup(float slot) {
    float prev = RemoveFromSlotHistory(slot);
    float still_attack = slot_history_top > 0;  // Empty stack check

    if (prev)
        localcmd(sprintf("impulse %d\n", TF_SLOT1 + prev - 1));
    if (!still_attack)
        localcmd("-attack\n");
}

void ZoomIn() {
    zoom_scale = min(zoom_scale + 1, 5);
}

void ZoomOut() {
    zoom_scale = max(zoom_scale - 1, 1);
}

void W_ChangeToSlotAlternate(string opt1, string opt2, string opt3, string opt4);

noref float(string cmd) CSQC_ConsoleCommand = {
    tokenize_console(cmd);
    float val;
    string key1, key2;
    local float grentype;

    switch(argv(0)) {
        case "specialup":
            switch (WP_PlayerClass()) {
                case PC_SNIPER:
                    ZoomIn();
                    break;
                case PC_SPY:
                    localcmd("cmd disguise prev\n");
                    break;
                case PC_ENGINEER:
                    if (previewing_sentry) {
                        sentry_preview_offset = anglemod(sentry_preview_offset - 15);
                    } else {
                        localcmd("cmd sentry rotate 15\n");
                    }
                    break;
            }
            break;
        case "specialdown":
            switch (WP_PlayerClass()) {
                case PC_SNIPER:
                    ZoomOut();
                    break;
                case PC_SPY:
                    localcmd("cmd disguise next\n");
                    break;
                case PC_ENGINEER:
                    if (previewing_sentry) {
                        sentry_preview_offset = anglemod(sentry_preview_offset + 15);
                    } else {
                        localcmd("cmd sentry rotate -15\n");
                    }
                    break;
            }
            break;
        case "zoomin":
            ZoomIn();
            break;
        case "zoomout":
            ZoomOut();
            break;
        case "+slot":
            Slot_Keydown(stof(argv(1)));
            break;
        case "-slot":
            Slot_Keyup(stof(argv(1)));
            break;

        case "fo_beta_pmove":
            printf("Please set `fo_pmove 1` instead.\n");
            break;

        case "login":
            FoLogin(argv(1), TRUE);
            break;
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
            showVoteMenu(!getHudPanel(HUDP_MAP_MENU)->Display);
            break;
        case "fo_menu_special":
            FO_Menu_Special(TRUE);
            break;
        case "fo_menu_disguise":
            if (WP_PlayerClass() == PC_SPY)
                FO_Menu_Spy_Skin(TRUE);
            break;
        case "fo_menu_build":
            if (WP_PlayerClass() == PC_ENGINEER)
                FO_Menu_Build(TRUE);
            break;
        case "fo_menu_dropammo":
            FO_Menu_DropAmmo(TRUE);
            break;
        case "fo_menu_cancel":
            Menu_Cancel();
            break;
        case "fo_min_ping":
            UpdateFoMinPing(argv(1));
            break;
        case "fo_settings_check":
            ClientSettings_Check();
            break;
        case "+fo_showscores":
            if (CVARF(fo_oldscoreboard) == 1)
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
            if (CVARF(fo_oldscoreboard) != 1)
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
        case "+rj":
            if (WP_PlayerClass() == PC_SOLDIER || WP_PlayerClass() == PC_PYRO)
                localcmd("+button4\n");
            break;
        case "-rj":
            if (WP_PlayerClass() == PC_SOLDIER || WP_PlayerClass() == PC_PYRO)
                localcmd("-button4\n");
            break;
        case "wpp_status":
            WPP_Status();
            break;
        case "perf_status":
            Perf_Status();
            break;
        case "vote_addmap":
            AddVoteMap(argv(1),argv(2),argv(3),stof(argv(4)),stof(argv(5)),stof(argv(6)),TRUE);
            break;
        case "vote_removemap":
            RemoveVoteMap(argv(1), TRUE);
            break;
        case "slot_a":  // Alternate between passed options
            W_ChangeToSlotAlternate(argv(1), argv(2), argv(3), argv(4));
            break;
    }

    return FALSE;
};

void(float isnew) CSQC_Ent_Update = {
    float etype = readbyte();
    switch (etype) {
        case ENT_CONFIG:
            EntUpdate_Config();
            break;
        case ENT_WEAPONPRED:
            EntUpdate_WeaponPred(isnew);
            break;
        case ENT_PROJECTILE:
            EntUpdate_Projectile(isnew);
            break;
        default:
            error("Unhandled CSQC entity\n");
            return;
    }
};

void() CSQC_Ent_Remove = {   //the entity in question left the player's pvs, and will no longer be tracked...
    if (self.removefunc)
        self.removefunc();
    remove(self);
};

static float IsFoConced() {
    if (IsClownMode(CLOWN_CONC))
        return TRUE;

    if (!fo_config.fo_concuss)
        return FALSE;

    return pstate_pred.tfstate & TFSTATE_CONC;
}

struct ConcCurve {
    float duration;
    float cycles;
    float amp_end;
    float offset;
};

ConcCurve conc_curve[] = {
    {1, 0.5, 0.0, 0.5},
    {6, 4, 0.2, 0.5},
    {2, 1.5, 0.75},
    {1, 1, 1},
    {0, 0, 1},  // Terminator
};

ConcCurve clown_curve[] = {
    {10, 4, 0.75},
    {0, 0, 0.75},  // Terminator
};

float ClownConcPeriod() { return clown_curve[0].duration; }

static float Blend(float start, float end, float rem, float D) {
    return rem/D * start + (D-rem)/D * end;
}

static vector FO_Conc_Offset() {
    static float last_rem;
    float rem = cuss_state.end_time - time;
    if (rem < 0)
        return '0 0 0';

    ConcCurve* table;
    float len;
    ConcCurve* cur = __NULL__;
    float i, rot = 0;

    if (!IsClownMode(CLOWN_CONC)) {
        table = conc_curve;
        len = conc_curve.length;
    } else {
        table = clown_curve;
        len = clown_curve.length;
    }

    for (i = 0; i < len - 1; i++) {
        cur = &table[i];
        if (rem <= cur->duration)
            break;
        rem -= cur->duration;
    }

    float amp = Blend(table[i+1].amp_end, cur->amp_end, rem, cur->duration);
    float a = (cur->duration - rem) / cur->duration * cur->cycles * 2 * M_PI;
    a += cur->offset * 2 * M_PI;

    return [sin(a), sin(a) * cos(a), amp * pstate_pred.conc_amp];
}

static void FO_UpdateConcAim() {
    makevectors(input_angles);
    vector o = FO_Conc_Offset();

    cuss_state.c_forward = normalize(v_forward * 200 + o.x * o.z * v_right + o.y * o.z * v_up);

    vector vv = o * min(o.z / 4, 20);
    cuss_state.c_view = vectoangles(v_forward * 200 + vv.x * v_right + vv.y * v_up);
    cuss_state.c_view[0] *= -1;
}

DEFCVAR_FLOAT(fo_crossy, 0);  // For people who want to use crossy
DEFCVAR_FLOAT(cl_crossx, 0);
DEFCVAR_FLOAT(cl_crossy, 0);

static void FO_CussView() {
    if (cuss_state.cussed) {
        FO_UpdateConcAim();
        setproperty(VF_ANGLES, cuss_state.c_view);
    }
};

static void FO_CussCrosshair(float width, float height) {
    const float crosshair_hz = 200;
    static float next_update;
    if (time < next_update)
        return;
    next_update = time + 1.0/crosshair_hz;

    if (!IsFoConced()) {
        if (cuss_state.cussed || CVARF(cl_crossx) != 0 ||
                CVARF(cl_crossy) != CVARF(fo_crossy)) {
            // Make sure we restore crosshairs
            localcmd(sprintf("cl_crossx %d; cl_crossy %d;\n", 0, CVARF(fo_crossy)));
            CVARF(cl_crossx) = 0;
            CVARF(cl_crossy) = CVARF(fo_crossy);
            cuss_state.cussed = FALSE;
        }
        return;
    }

    cuss_state.cussed = TRUE;
    makevectors(input_angles);  // updated by input_frame
    vector p = project(PM_Org() + 8000 * cuss_state.c_forward);

    localcmd(sprintf("cl_crossx %d; cl_crossy %d;\n",
                p_x - width / 2, CVARF(fo_crossy) + p_y - height / 2));
}

static void UpdateTeamColorCrosshair() {
    if (!CVARF(fo_team_color_crosshair))
        return;

    if (crosshair_team_no == team_no)
        return;

    string crosshair_color = "0xffffff";
    switch (team_no) {
        case 1:
            crosshair_color = "0x0066ff";
            break;
        case 2:
            crosshair_color = "0xff0000";
            break;
        case 3:
            crosshair_color = "0xffff00";
            break;
        case 4:
            crosshair_color = "0x00ff00";
            break;
    }
    localcmd("crosshaircolor ", crosshair_color, "\n");
    crosshair_team_no = team_no;
}

void FO_ApplyCussInput() {
    if (!IsFoConced())
        return;

    float modify_forward = TRUE;

    if ((!pmove_onground && (fo_config.fo_concuss & FOC_EASY_AIR)) ||
            (pmove_onground && (fo_config.fo_concuss & FOC_EASY_GROUND)))
        modify_forward = input_buttons & BUTTON0;

    if (modify_forward) {
        input_angles = vectoangles(cuss_state.c_forward);
        makevectors(input_angles);
        input_angles_x *= -1;
    }
}

void PM_InputFrame();

void SentryPreviewStart() {
    sentry_preview_offset = 0;
    sentry_preview.angles_y = input_angles_y;
    sentry_preview.drawmask = MASK_ENGINE;

    local vector sphere_colormod = '1 1 1';
    switch (team_no) {
        case 1:
            sphere_colormod = '0 0.4 1';
            break;
        case 2:
            sphere_colormod = '1 0 0';
            break;
        case 3:
            sphere_colormod = '1 1 0';
            break;
        case 4:
            sphere_colormod = '0 1 0';
            break;
    }

    sentry_preview_range_sphere.colormod = sphere_colormod * 4;
    sentry_preview_range_sphere.drawmask = MASK_ENGINE;

    previewing_sentry = TRUE;
    prevent_firing = TRUE;
}

void SentryPreviewStop() {
    previewing_sentry = FALSE;
    sentry_preview.drawmask = 0;
    sentry_preview_range_sphere.drawmask = 0;
}

noref void CSQC_Input_Frame() {
    local float changed_buttons = input_buttons ^ oldbuttons;
    oldbuttons = input_buttons;

    local float keydowns = changed_buttons & input_buttons;
    local float keyups = changed_buttons & ~input_buttons;

    Sync_GameState();

    switch (WP_PlayerClass()) {
        case PC_SNIPER:
            if (keydowns & BUTTON3) {
                if (zoom_scale == 1) {
                    zoom_scale = 3;
                } else {
                    zoom_scale = 1;
                }
            }
            break;
        case PC_SOLDIER:
        case PC_PYRO:
            // Intercept rocket jump
            if (input_buttons & BUTTON4) {
                input_buttons |= BUTTON0 | BUTTON2;
            }
            break;
        case PC_ENGINEER:
            // Intercept sentry build
            if (!getstatf(STAT_HAS_SENTRY) && getstatf(STAT_CELLS) >= 130 && game_state.is_alive && !prematch) {
                if (input_buttons & BUTTON4) {
                    if (keydowns & BUTTON4) {
                        if (!previewing_sentry) {
                            SentryPreviewStart();
                        } else {
                            SentryPreviewStop();
                        }
                    }

                    input_buttons = input_buttons - BUTTON4;
                }

                if (previewing_sentry) {
                    if (keydowns & BUTTON0) {
                        if (sentry_fits) {
                            localcmd(sprintf("cmd build sentry %f\n", anglemod(180 + sentry_preview_offset)));
                            SentryPreviewStop();
                        } else {
                            print("Can't build here\n");
                        }
                    }

                    if (input_buttons & BUTTON0) {
                        input_buttons = input_buttons - BUTTON0;
                    }
                }
            }
            break;
    }

    if (prevent_firing && !previewing_sentry && (keyups & BUTTON0)) {
        prevent_firing = FALSE;
    }

    if (prevent_firing) {
        input_buttons &= ~BUTTON0;
    }

    PM_InputFrame();
    FO_ApplyCussInput();
}

float(float save, float take, vector inflictororg) CSQC_Parse_Damage = {
    if (take > 0)
        painfinished = time + 0.2;

    return 0;
}

void CSQC_Shutdown() {
}

// We can query, but not set via an autocvar.
DEFCVAR_FLOAT(cl_delay_packets, 0);
DEFCVAR_FLOAT(fov, 90);

void WP_UpdatePings();

float last_servercommandframe;
void _Sync_ServerCommandFrame() {
    // Server command frames are monotonically unique, we can skip processing
    // unless there is new state.
    if (last_servercommandframe == servercommandframe)
        return;
    last_servercommandframe = servercommandframe;

    prev_game_state = game_state;

    team_no = getstatf(STAT_TEAMNO);
    all_time = getstatf(STAT_ALL_TIME);
    SBAR.ReadyStatus = getstatf(STAT_FLAGS);

    game_state.localentnum = player_localentnum;

    if (team_no == 0 ||stof(getplayerkeyvalue(player_localnum, "*spectator"))) {
        game_state.is_spectator = 1;
        game_state.is_player = 0;
    } else {
        game_state.is_spectator = 0;
        game_state.is_player = 1;
    }

    // Note: When spectating someone, refers to them.
    game_state.is_alive = getstatf(STAT_HEALTH) > 0;
    game_state.spawn_gen = getstatf(STAT_SPAWN_GEN);

    game_state.is_ceasefire = serverkeyfloat("pausestate");
    WP_ServerFrame();

    // Use an undocumented ezquake compat feature to figure out whether we
    // have focus or not, skip updates in this case due to lowered network fps.
    float is_unfocused = getplayerkeyfloat(player_localnum, "chat") & 2;
    if (!is_unfocused)
        WP_UpdatePings();

    CsGrenTimer::UpdateSoundStack();
    UpdateTeamColorCrosshair();

    if (previewing_sentry) {
        if (game_state.is_alive) {
            sentry_fits = CheckArea(sentry_preview);
            sentry_preview.colormod = sentry_fits ? '1 1 1' : '0.5 0.2 0.2';
        } else {
            SentryPreviewStop();
        }
    }
}


// Called for each {client, server} command frame, ensures globals are
// synchronized with server and predicted state.
void Sync_GameState() {
    _Sync_ServerCommandFrame();
    PM_PredictJump_Engine();
}

static string FoLogin_GetToken() {
    float filehandle = fopen(FO_TOKEN_PATH, FILE_READ);
    if (filehandle == -1)
        return "";

    string token = fgets(filehandle);
    fclose(filehandle);
    return token;
}

// Doesn't actually return success, just whether it sent a token.
float FoLogin(string token, float print_error) {
    if (token != "") {
        float filehandle = fopen(FO_TOKEN_PATH, FILE_WRITE);
        fputs(filehandle, token);
        fclose(filehandle);
    } else {
        token = FoLogin_GetToken();
    }

    if (token == "") {
        if (print_error)
            print("Token required: Please sign-up at fortressone.org and follow the instructions to generate your login token.\n");
        return FALSE;
    }

    localcmd("setinfo _fo_token \"\"\n");
    localcmd(sprintf("cmd fo-login-silent %s\n", token));
    return TRUE;
}

static string to_precision(float f, float p) {
    string fmt = strcat("%0.", ftos(p), "f");
    return sprintf(fmt, f);
}

static float get_precision() {
    float t = gettime(1);

    // For (debug) clients which have modified gettime to report with more
    // precision.
    return (t*1000 == ceil(t*1000)) ? 3 : 5;
}

static float gettime_lat() {
    const float trials = 1000;
    float s = gettime(1), f, i;
    for (i = 0; i < trials; i++)
        gettime(1);
    return (gettime(1) - s)/trials;
}

// Note while this works with ms
void Perf_Status() {
    printf("Performance Stats:\n");
    float avg, variance, minv, maxv;

    float prec = get_precision();
    if (prec > 3)
        printf("gettime() timing = %0.5f\n", gettime_lat());


    printf("HUD cache used=%d freelist=%d\n",
            (float)hud_render_cache.draw_count,
            (float)hud_render_cache.free_count);

    compute_avg(&frame_timing.samples, &avg, &variance);
    compute_maxmin(&frame_timing.samples, &minv, &maxv);
    printf(" Frame render (%d) avg=%s var=%0.3f min=%s max=%s\n",
            (float)min(frame_timing.samples.count, frame_timing.samples.max_count),
            to_precision(avg, prec), variance,
            to_precision(minv, prec), to_precision(maxv, prec));

    compute_avg(&hud_timing.samples, &avg, &variance);
    compute_maxmin(&hud_timing.samples, &minv, &maxv);
    printf(" HUD render (%d) avg=%s var=%0.3f min=%s max=%s\n",
            (float)min(hud_timing.samples.count, hud_timing.samples.max_count),
            to_precision(avg, prec), variance,
            to_precision(minv, prec), to_precision(maxv, prec));

    compute_avg(&hud_partial_timing.samples, &avg, &variance);
    compute_maxmin(&hud_partial_timing.samples, &minv, &maxv);
    printf(" HUD partial (%d) avg=%s var=%0.3f min=%s max=%s\n",
            (float)min(hud_partial_timing.samples.count, hud_partial_timing.samples.max_count),
            to_precision(avg, prec), variance,
            to_precision(minv, prec), to_precision(maxv, prec));
}

void ClientSettings_Check() {
    localcmd("cl_movespeedkey 1\n");
    if (cvar("worker_count") == 0)
        printf("ERROR: Please set `worker_count 4` to reduce stuttering!\n");
    if (cvar("r_temporalscenecache") == 0)
        printf("RECOMMENDED: Please set `r_temporalscenecache 1` to reduce stuttering!\n");
    if (cvar("fo_grentimer") != 2)
        printf("RECOMMEND: Setting `fo_grentimer 2` for ping correction.\n");
    if (cvar("fo_hud_cache") != 1)
        printf("ERROR: Please set `fo_hud_cache 1` to improve fps.\n");
    if (cvar("fo_predict_weapons") != 1)
        printf("WARNING: client-side weapon prediction disabled [fo_predict_weapons 0]\n");
    if (cvar("fo_predict_projectiles") != 1)
        printf("WARNING: client-side projectile prediction disabled [fo_predict_projectiles 0]\n");
    printf("Finished checking settings...\n");
}
