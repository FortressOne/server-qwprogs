float GetTextAlignOffset(float pos, float width, float iconsize, string text, float textsize, float align);
float fo_to_sui_aligntment(float fo_align);
vector (FO_Hud_Panel* panel) getPanelPosition;
vector (FO_Hud_Panel* panel) getPanelFillSize;
void Hud_DrawPanelLMP(FO_Hud_Panel*, string, string, float);
void Hud_DrawLMPThreshold(FO_Hud_Panel*, string, float);
FO_Hud_Panel* getHudPanel(PanelID);
void FO_Hud_HidePanel(PanelID id);
void FO_Hud_ShowPanel(PanelID id);

DEFCVAR_FLOAT(fo_hud_noclipicon, 0);

void(PanelID ignored, string text) drawClipSize = {
    string icon = CVARF(fo_hud_noclipicon) ? "" : ICON_CLIPSIZE;
    if (game_state.is_alive || fo_hud_editor)
        Hud_DrawPanelLMP(getHudPanel(HUDP_CLIPSIZE), text, icon, 1);
};

void(PanelID ignored, string text) drawIdentify = {
    if (time > last_id_time + 5)
        return;

    if (strlen(text) > 0 || fo_hud_editor)
        Hud_DrawIdentifyPanel(text);
};

void(PanelID ignored, string text) drawTeamScorePanel = {
    Hud_DrawTeamScorePanel();
};

void(PanelID ignored, string text) drawMapMenuPanel = {
    Hud_DrawMapMenuPanel();
};

void(PanelID ignored, string text) drawFlagInfo = {
    Hud_DrawFlagStatusBar();
};

void(PanelID panelid, string text, string icon) drawIconPanel = {
    Hud_DrawPanelLMP(getHudPanel(panelid), text, icon, 1);
};

void(PanelID panelid, string text) drawFragStreakPanel = {
    drawIconPanel(HUDP_FRAGSTREAK, text, ICON_FRAGSTREAK);
};

void(PanelID ignored, string text) drawCapsPanel = {
    drawIconPanel(HUDP_CAPS, text, ICON_CAPS);
};

void(PanelID panelid, string text) drawGren1Panel = {
    float playerclass = WP_PlayerClass();

    if (playerclass < PC_SCOUT || playerclass > PC_ENGINEER)
        return;

    string icon = FO_ClassGren(playerclass, 0)->icon;
    drawIconPanel(HUDP_GREN1, text, icon);
};

void(PanelID ignored, string text) drawGren2Panel = {
    float playerclass = WP_PlayerClass();

    if (playerclass < PC_SCOUT || playerclass > PC_ENGINEER)
        return;

    string icon = FO_ClassGren(playerclass, 1)->icon;
    drawIconPanel(HUDP_GREN2, text, icon);
};

void(PanelID ignored, string text) drawSpecial = {
    if (WP_PlayerClass() || fo_hud_editor)
        Hud_DrawClassInfoPanel(WP_PlayerClass());
};

void(PanelID panelid, string text) drawGrenTimerPanel = {
    float timeleft;
    float timercount = 0;

    FO_Hud_Panel* panel = getHudPanel(panelid);
    float Scale = panel.Scale;
    float TextScale = panel.TextScale;
    FO_Hud_Panel panel2;
    panel2.Position = panel.Position;
    panel2.Scale = panel.Scale;
    panel2.TextScale = panel.TextScale;
    panel2.Display = panel.Display;
    panel2.FillSize = panel.FillSize;

    CsGrenTimer lt = CsGrenTimer::GetLast();
    // We want to render in reverse mod order from the last primed grenade
    // here, that way we'll properly stack timers relative to expiry.
    for (float i = grentimers.length; i > 0; i--) {
        CsGrenTimer gt = grentimers[(lt.index() + i) % grentimers.length];

        if (!gt.active())
            continue;

        timeleft = floor(gt.expiry() - time) + 1;
        if (timeleft < 1)
            continue;

        if (timercount) {
            panel2.Scale = Scale * 0.8;
            panel2.TextScale = TextScale * 0.8;
        }

        // It's technically possible to get a primed message before thrown
        // if things get reordered, but since we can only ever have one
        // grenade primed, we can obscure this by always considering
        // grenades after the first as primed.
        float alpha = (gt.test_flag(FL_GT_THROWN) || timercount) ? 0.3 : 1.0;
        string icon = FO_GrenDesc(gt.grentype())->icon;
        Hud_DrawPanelLMP(&panel2, ftos(timeleft), icon, alpha);
        panel2.Position = panel2.Position +
            [0, panel2.FillSize.y * panel2.Scale];
        timercount++;
    }

    if(fo_hud_editor && !timercount)
        Hud_DrawPanelLMP(getHudPanel(panelid), text, ICON_GREN_NORMAL, 1);
};

void(PanelID panelid, string text) drawFacePanel = {
    if (!CVARF(fo_fte_hud))
        return;

    local float playerclass = WP_PlayerClass(); //we could add different faces per class?

    local string icon = FaceInvisibleInvulnerableIcon.icon;
    
    if(playerclass) {
        local float health = getstatf(STAT_HEALTH);
        if(health > 0) {
            local float items = getstatf(STAT_ITEMS);
            //we should add all the combos :)
            if(items & IT_INVULNERABILITY && items & IT_INVISIBILITY) icon = FaceInvisibleInvulnerableIcon.icon;
            else if(items & IT_INVULNERABILITY) icon = FaceInvulnerableIcon.icon;
            else if(items & IT_INVISIBILITY) icon = FaceInvisibleIcon.icon;
            else if(items & IT_QUAD) icon = FaceQuadIcon.icon;
            else {
                local float index = 0;
                if(health >= 80) index = 0;
                else if(health >= 60) index = 1;
                else if(health >= 40) index = 2;
                else if(health >= 20) index = 3;
                else index = 4;
                
                if(time < painfinished) {
                    index += 5;
                }
                
                icon = FaceIcons[index].icon;
            }
        } else {
            icon = FaceIcons[4].icon;
        }
    }

    drawIconPanel(panelid, text, icon);
};

void(PanelID panelid, string text) drawArmourPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    local float playerclass = WP_PlayerClass();

    local string icon = fo_hud_editor?ArmourIcons[1].icon:"";
    
    if(playerclass) {
        local float items = getstatf(STAT_ITEMS);
        if(items & IT_INVULNERABILITY) icon = ArmourIcons[0].icon;
        else if(items & IT_ARMOR1) icon = ArmourIcons[1].icon;
        else if(items & IT_ARMOR2) icon = ArmourIcons[2].icon;
        else if(items & IT_ARMOR3) icon = ArmourIcons[3].icon;
    }

    if(icon != "") drawIconPanel(panelid, text, icon);
};

void(PanelID panelid, string text) drawAmmoPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    local string icon = fo_hud_editor?AmmoIcons[0].icon:"";
    
    local float items = getstatf(STAT_ITEMS);
    if(items & IT_SHELLS) icon = AmmoIcons[0].icon;
    else if(items & IT_NAILS) icon = AmmoIcons[1].icon;
    else if(items & IT_ROCKETS) icon = AmmoIcons[2].icon;
    else if(items & IT_CELLS) icon = AmmoIcons[3].icon;

    if(icon != "") drawIconPanel(panelid, text, icon);
};

void(PanelID panelid, string text) drawInvIconPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    if(text && text != "") {
        drawIconPanel(panelid, "", text);
    } else if(fo_hud_editor) {
        drawIconPanel(panelid, "", FaceIcons[0].icon);
    }
};
void(PanelID panelid, string text) drawInvShellsPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawIconPanel(panelid, text, AmmoIcons[0].icon);
};
void(PanelID panelid, string text) drawInvNailsPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawIconPanel(panelid, text, AmmoIcons[1].icon);
};
void(PanelID panelid, string text) drawInvRocketsPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawIconPanel(panelid, text, AmmoIcons[2].icon);
};
void(PanelID panelid, string text) drawInvCellsPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawIconPanel(panelid, text, AmmoIcons[3].icon);
};

string(float gunnum) getGunIcon = {
    string retval = "";
    if(getstatf(STAT_ITEMS) & gunnum) {
        switch(gunnum) {
            case IT_SHOTGUN:
               retval = "shotgun";
               break;
            case IT_SUPER_SHOTGUN:
               retval = "sshotgun";
               break;
            case IT_NAILGUN:
               retval = "nailgun";
               break;
            case IT_SUPER_NAILGUN:
               retval = "snailgun";
               break;
            case IT_GRENADE_LAUNCHER:
               retval = "rlaunch";
               break;
            case IT_ROCKET_LAUNCHER:
               retval = "srlaunch";
               break;
            case IT_LIGHTNING:
               retval = "lightng";
               break;
        }
        if(retval != "") {
            retval = strcat((getstatf(STAT_ACTIVEWEAPON) == gunnum)?"inv2_":"inv_", retval);
        }
    }
    return retval;
};

void(PanelID panelid, string text, float threshold) drawBigNumberPanel = {
    Hud_DrawLMPThreshold(getHudPanel(panelid), text, threshold);
};

void(PanelID panelid, string text) drawHealthArmourTextPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawBigNumberPanel(panelid, text, 26);
};

void(PanelID panelid, string text) drawAmmoTextPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawBigNumberPanel(HUDP_AMMO, text, 11);
};

void(PanelID panelid, string text) drawClockPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawBigNumberPanel(HUDP_GAMECLOCK, text, 0);
};

string clockString() {
    float minutes = time/60;
    float seconds = (float)time - (minutes*60);

    //return strcat(ftos(minutes),":", ftos(seconds));  
    //return "00:00";
    return ftos(rint(time));
};

string gameClockString() {
    float minutes = 0;
    float seconds = 0;
    float timelimit = stof(serverkey("timelimit"));

    float end = getstatf(STAT_ROUND_END);
    if (!end)
        end = timelimit * 60;

    if (end && end > servertime) {
        minutes = (end - servertime)/60;
        seconds = (end - servertime)%60;
    } else {
        minutes = time/60;
        seconds = time%60;
    }

    string sm = strcat((minutes<10?"0":""),ftos(floor(minutes)));
    string ss = strcat((seconds<10?"0":""),ftos(floor(seconds)));

    return strcat(sm,":",ss);
};

static void(PanelID panelid, string text) doNothing = {};

void(PanelID panelid, string text) drawSimplePanel = {
    if (fo_hud_editor) {
        FO_Hud_Panel* panel = getHudPanel(panelid);
        if(panel && &panel != &NullPanel) {
            if (hud_panel(panelid, getPanelPosition(panel), getPanelFillSize(panel), 0.3, 1)) {
                // click event
            }
        }
    }
}

void(PanelID panelid, string text) drawTextPanel = {
    FO_Hud_Panel* panel = getHudPanel(panelid);

    vector position = getPanelPosition(panel);
    vector size = getPanelFillSize(panel);
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale;
    local float padding = 4 * panel.Scale;
    local float transparency = 0.3;
    local float lines;
    if (fo_hud_editor) {
        string name = getHudPanel(panelid)->Name;
        HRC_drawstring(
                [GetTextAlignOffset(position.x, size.x, padding, name,
                    mediumtext.x, panel.Orientation),
                padding*2 + position.y],
                name, mediumtext, MENU_TEXT_1, 1, 0
                );
        if (hud_panel(panelid, position, size, transparency, panel.Display)) {
            // click event
        }
    } else {
        if (showingscores || !panel.Display || text == "")
            return;

        lines = tokenizebyseparator(text, "\n");
        string line;
        for (float i = 0; i <= lines; i++) {
            line = argv(i);
            // tokenize doesn't handle newlines very well
            line = strtrim(strreplace("\n", "", line));
            if (strlen(line) > 0) {
                HRC_drawstring(
                        [GetTextAlignOffset(position.x, size.x, padding, line,
                            mediumtext.x, panel.Orientation),
                        position.y + padding + mediumtext.y*i],
                        line, mediumtext, MENU_TEXT_1, 1, 0
                        );
            }
        }
    }
}

void(PanelID panelid, string text) drawMOTDPanel = {
    FO_Hud_Panel* panel = getHudPanel(panelid);
    
    // No need to render MOTD once expired.
    if (time > motd_expiry && panel->Display)
        FO_Hud_HidePanel(panel->id);

    //vector position = getPosition(id);
    //vector size = getFillSize(id);
    vector position = getPanelPosition(panel); //panel.Position;
    vector size = panel.FillSize * panel.Scale;
    
    float textscale = panel.TextScale;
    if(!textscale) {
        textscale = panel.Scale;
    }
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale;
    local float padding = 4 * panel.Scale;
    local float transparency = 0.3;
    local float lines;
    local string tempstr;
    if (fo_hud_editor) {
        if (hud_panel(panelid, position, size, transparency, panel.Display)) {
            // click event
        }
    }


    if ((showingscores || !panel.Display || text == "") && !fo_hud_editor)
        return;

    //if(text && text != "") {
        if((!intermission && time < motd_expiry && !team_no) || fo_hud_editor) {
            sui_push_frame(position, size);
            sui_set_align([fo_to_sui_aligntment(panel.Orientation), SUI_ALIGN_CENTER]);
            local string motd = serverkey("hostname");
            sui_text([0,0], mediumtext*textscale*1.5, motd, MENU_TEXT_4, 1, 0);
            /*
            HRC_drawstring(
                position + [size.x / 2 - stringwidth(motd,1,mediumtext*1.5)/2,padding*2], 
                motd, 
                mediumtext*1.5, 
                MENU_TEXT_4, 
                1, tokenizebyseparator
                0
            );
            */
            if(strlen(SBAR.MOTD) <= 1) {
                motd = "Welcome to FortressOne\nwww.fortressone.org";
            } else {
                motd = SBAR.MOTD;
            }
            lines = tokenizebyseparator(motd, "\n");
            for (float i = 0; i <= lines; i++) {
                tempstr = argv(i);
                // tokenize doesn't handle newlines very well
                tempstr = strreplace("\n", "", tempstr);
                tempstr = strtrim(tempstr);
                if (strlen(tempstr) > 0) {
                    sui_text([0,mediumtext.y*textscale * (i+2)], mediumtext*textscale, tempstr, MENU_TEXT_1, 1, 0);
                    /*
                    HRC_drawstring(
                        position + [size.x / 2 - stringwidth(motd,1,mediumtext)/2,padding*2 + mediumtext.y*(i+2)], 
                        motd, 
                        mediumtext, 
                        MENU_TEXT_1, 
                        1, 
                        0
                    );
                    */
                }
            }
            sui_pop_frame();
        }
    //}
}

void(PanelID panelid, string text) drawGameModePanel = {
    FO_Hud_Panel* panel = getHudPanel(panelid);
    
    vector position = getPanelPosition(panel);
    vector size = getPanelFillSize(panel);
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale;
    local float padding = 4 * panel.Scale;
    local float transparency = 0.3;
    local float lines;
    local string message = "";
    if (fo_hud_editor) {
        message = "Game Mode";
        if (hud_panel(panelid, position, size, transparency, panel.Display)) {
            // click event
        }
    } else {
        if(showingscores || !panel.Display) {
            return;
        }
        if(SBAR.GameMode & GAMEMODE_VOTE) {
            message = "Vote Mode";
        } else {
            if(SBAR.GameMode & GAMEMODE_DUEL) {
                message = "Duel Mode";
            } else if(SBAR.GameMode & GAMEMODE_QUAD) {
                message = "Quad Mode";
            } else if(SBAR.GameMode & GAMEMODE_CLAN) {
                message = "Clan Battle";
            }
            if(prematch && !round_over) {
                message = strcat(message, ": prematch");
            } else {
                //Quad mode only
                if(SBAR.GameMode & 2) {
                    if(round_over) {
                        if(prematch) {
                            message = strcat(message, ": match over");
                        } else {
                            message = strcat(message, ": intermission");
                        }
                    } else if(quad_round > 0) {
                        message = strcat(message, ": round ", ftos(quad_rounds_total + 1 - quad_round), "/", ftos(quad_rounds_total));
                    }
                }
            }
        }
    }
    if(message) {
        HRC_drawstring(
            [GetTextAlignOffset(
                position.x, size.x, padding, message, mediumtext.x,
                panel.Orientation), position.y],
            message, mediumtext, MENU_TEXT_1, 1, 0
        );
    }
}

void(PanelID panelid, string text) drawNotificationPanel = {
    FO_Hud_Panel* panel = getHudPanel(panelid);

    vector position = getPanelPosition(panel);
    vector size = getPanelFillSize(panel);
    vector textsize = MENU_TEXT_SMALL * panel.Scale;
    vector textcolour = MENU_TEXT_4;
    local float padding = 4 * panel.Scale;
    local float lines;
    local float pos_aligned;
    local string message = "";
    if (fo_hud_editor) {
        message = "Notification panel";
        if (hud_panel(panelid, position, size, 0.3, panel.Display)) {
            // click event
        }
    } else {
        if(showingscores || !panel.Display) {
            return;
        }
        if (prematch && team_no && WP_PlayerClass() && !SBAR.CountdownStarted &&
              game_state.is_player) {
            if(SBAR.ReadyStatus & PLAYER_READY) {
                message = "Ready";
                textcolour = MENU_TEXT_GREEN;
            } else if(round_over) {
                message = "Change map to continue playing";
            } else {
                textcolour = MENU_TEXT_WARNING;
                tokenize(findkeysforcommand("ready"));
                string keynum = argv(0);

                if(SBAR.ReadyStatus & LAST_NOT_READY) {
                    local vector alert_text_size = MENU_TEXT_LARGE * panel.Scale;
                    local vector alert_text_position;
                    alert_text_position.y = ScreenSize.y / 3;
                    alert_text_position.x = (ScreenSize.x / 2) - (size.x / 2);
                    local string alert_text_message = "You're last";

                    pos_aligned = GetTextAlignOffset(
                        alert_text_position.x,
                        size.x,
                        padding,
                        alert_text_message,
                        alert_text_size.x,
                        panel.Orientation
                    );

                    HRC_drawstring(
                        [pos_aligned, alert_text_position.y],
                        alert_text_message, alert_text_size, textcolour, 1, 0
                    );

                    position.y = alert_text_position.y + alert_text_size.y + textsize.y;
                    position.x = (ScreenSize.x / 2) - (size.x / 2);

                    if(keynum != "-1") {
                        message = strcat("Press ", keynumtostring(stof(keynum)), " to start");
                    } else {
                        message = "Type 'ready' in the console to start";
                    }
                } else if (SBAR.ReadyStatus & ENEMY_TEAM_READY) {
                    local vector alert_text_size = MENU_TEXT_MEDIUM * panel.Scale;
                    local vector alert_text_position;
                    alert_text_position.y = ScreenSize.y / 3;
                    alert_text_position.x = (ScreenSize.x / 2) - (size.x / 2);
                    local string alert_text_message = "Enemy team is ready!";

                    pos_aligned = GetTextAlignOffset(
                        alert_text_position.x,
                        size.x,
                        padding,
                        alert_text_message,
                        alert_text_size.x,
                        panel.Orientation
                    );

                    HRC_drawstring(
                        [pos_aligned, alert_text_position.y],
                        alert_text_message, alert_text_size, textcolour, 1, 0
                    );

                    position.y = alert_text_position.y + alert_text_size.y + textsize.y;
                    position.x = (ScreenSize.x / 2) - (size.x / 2);

                    if(keynum != "-1") {
                        message = strcat("Press ", keynumtostring(stof(keynum)), " to ready up");
                    } else {
                        message = "Type 'ready' in the console to ready up";
                    }
                } else {
                    if(keynum != "-1") {
                        message = strcat("Press ", keynumtostring(stof(keynum)), " to ready up");
                    } else {
                        message = "Type 'ready' in the console to ready up";
                    }
                }
            }
        } else if (pick_up_time && time < pick_up_time + 1.5) {
            local vector alert_text_size = MENU_TEXT_SMALL * panel.Scale;
            local vector alert_text_position;
            alert_text_position.y = ScreenSize.y / 3;
            alert_text_position.x = (ScreenSize.x / 2) - (size.x / 2);

            local string flag_team_str = "the";
            local vector menu_text_color = MENU_TEXT_4;

            switch(flag_team) {
                case 1:
                    flag_team_str = "blue's";
                    menu_text_color = MENU_TEXT_BLUE_FO;
                    break;
                case 2:
                    flag_team_str = "red's";
                    menu_text_color = MENU_TEXT_RED_FO;
                    break;
                case 3:
                    flag_team_str = "yellow's";
                    menu_text_color = MENU_TEXT_YELLOW_FO;
                    break;
                case 4:
                    flag_team_str = "green's";
                    menu_text_color = MENU_TEXT_GREEN_FO;
                    break;
            }

            local string alert_text_message = sprintf("You got %s flag!", flag_team_str);

            pos_aligned = GetTextAlignOffset(
                    alert_text_position.x,
                    size.x,
                    padding,
                    alert_text_message,
                    alert_text_size.x,
                    panel.Orientation
                    );

            HRC_drawstring(
                    [pos_aligned, alert_text_position.y],
                    alert_text_message, alert_text_size, menu_text_color, 1, 0
                    );
        }
    }
    if(message) {
        pos_aligned = GetTextAlignOffset(position.x,size.x,padding,message,textsize.x,panel.Orientation);
        HRC_drawstring(
            [pos_aligned, position.y], message, textsize, textcolour, 1, 0
        );
    }
}

string (float val) AbbreviateNumberToString = {
    val = rint(val);
    if (val < 10000)
        return ftos(rint(val));

    float count = 0;
    while (val >= 1000) {
        val /= 1000;
        count++;
    }

    // Try to (with max density) use up to 4 characters.
    const string abbr = "kmb";
    if (count == 0)
        return ftos(val);
    else if (val < 100)
        return sprintf("%0.1f%c", val, abbr[min(count - 1, 2)]);
    else
        return sprintf("%d%c", val, abbr[min(count - 1, 2)]);
};

void (vector position, vector size, string val, vector textcolour, float alpha
    , float flags, string colname) drawShowScoresColumnVal = {
    if (strlen(val) < strlen(colname))
        val = strpad(strlen(colname) * -1, val);
    sui_text(position, size, val, textcolour, 1, 0);
};

enum {
    SCT_BLUE,
    SCT_RED,
    SCT_YELLOW,
    SCT_GREEN,
    SCT_SPECS,
    NUM_SCT,
};

struct FO_ScoreBoardTeam {
    FO_ScoreBoardLine lines[FO_SCOREBOARDLINES_LENGTH];
    int count;
};

struct FO_ScoreBoard {
    FO_ScoreBoardTeam team[NUM_SCT];
};

static FO_ScoreBoard score_board;

DEFCVAR_FLOAT(fo_simple_names, 0);

vector drawShowScoresTeamPanel (FO_Hud_Panel *panel, FO_ScoreBoardTeam* team,
                                float padding, vector team_colour) {
    vector smalltext = MENU_TEXT_SMALL * panel.Scale;
    vector yspacer = [0, 20];
    vector position = [0, 0];
    vector size = getPanelFillSize(panel);

    position = [0,0];
    sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
    size = [size_x, smalltext_y];
    sui_fill(position, size, MENU_BG, 1, 0);

    // FIXME - hardcoded 4 length on all column names... (pl has 2, name and score have 5)
    // of just never have any other columns with more than 4 chars
    float txtlength = strlen("name") * smalltext.x;
    float namespace = size_x - ((txtlength + padding) * (FO_ScoreBoardColumns.length - 1) - padding);

    float classspace = strlen("class") * smalltext.x;

    FO_ScoreBoardLine* lines = &team->lines;
    for (float i = 0; i < FO_ScoreBoardColumns.length; i++) {
        string colname = FO_ScoreBoardColumns[i];
        if (lines[i].team_no == TEAM_SPECTATOR || lines[i].team_no == TEAM_OBSERVER) {
            switch (colname) {
                case "class":
                    colname = "type";
                case "ping":
                case "pl":
                case "name":
                    sui_text(position, smalltext, colname, SCOREB_HEADER, .7, 0);
                    break;
            }
        } else {
            sui_text(position, smalltext, colname, SCOREB_HEADER, .7, 0);
        }

        txtlength = strlen(colname) * smalltext.x;
        if (colname == "name")
            position_x += namespace;
        else
            position_x += txtlength + padding;
    }

    position = [0, smalltext.y];
    float lineCount = 1;
    for (float i = 0; i < team->count; i++) {
        string name = lines[i].name;
        if (!name)
            continue;

        lineCount++;
        float alpha = 1;
        if (lineCount % 2 == 0)
            alpha = .7;
        else
            alpha = .3;

        vector fill_colour = team_colour;
        if (lines[i].name == getplayerkeyvalue(player_localnum, "name")) {
            alpha = 0.5;
            fill_colour = SCOREB_SELF_BG;
        } else if (lines[i].name == getplayerkeyvalue(player_localentnum - 1, "name")) {
            alpha = 0.5;
            fill_colour = SCOREB_SPECTATED_BG;
        }

        sui_fill(position, size, fill_colour, alpha, 0);

        float col = 0, alpha = 1, flags = 0;
        string val = AbbreviateNumberToString(lines[i].ping);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].pl);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        if (team_no == lines[i].team_no || lines[i].team_no == TEAM_SPECTATOR || lines[i].team_no == TEAM_OBSERVER
            || game_state.is_spectator) {
            string c = lines[i].classtext;
            if (lines[i].team_no != TEAM_SPECTATOR && lines[i].team_no != TEAM_OBSERVER) {
                float cspace = strlen(c) * smalltext.x;
                if (cspace > classspace) {
                    float max = classspace / smalltext.x;
                    // TODO - maybe make this ok with non fixed width fonts one day... we're 90% of the way there
                    c = substring(c, 0, max);
                }
            }

            sui_text(position, smalltext, c, SCOREB_FIELD, 1, 0);
        }

        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        if (lines[i].team_no != TEAM_SPECTATOR && lines[i].team_no != TEAM_OBSERVER) {
            val = AbbreviateNumberToString(lines[i].score);
            drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        }
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        string n = lines[i].name;
        if (CVARF(fo_simple_names))
            n = strdecolorize(n);

        if (stringwidth(n, TRUE, smalltext) >= namespace - padding) {
            n = strdecolorize(n);
            n = substring(n, 0, floor(namespace - padding) / smalltext.x);
        }
        sui_text(position, smalltext, n, SCOREB_NAME, 1, 0);
        position_x += namespace;

        vector iconpos = [size_x, position_y];
        //check for icon files existing, otherwise use fallbacks
        float filehandle;
        if(lines[i].ready) {
            if (FO_ScoreBoardAssets.icon_ready != "")
                sui_pic(iconpos, smalltext, FO_ScoreBoardAssets.icon_ready, '1 1 1', alpha, flags);
            else
                sui_text(iconpos, smalltext, "R", MENU_TEXT_GREEN_FO, 1, 0);
            iconpos_x += smalltext.x;
        }

        if(lines[i].chat & 1) {
            if (FO_ScoreBoardAssets.icon_chat != "") {
                sui_pic(iconpos, smalltext, FO_ScoreBoardAssets.icon_chat, '1 1 1', alpha, flags);
            } else {
                //use ezquake chaticons image. Couldn't get drawsubpic to work, so now we get this instead
                drawsetcliparea(iconpos_x + panel.Position.x, iconpos_y + panel.Position.y + 20, smalltext.x, smalltext.y);
                sui_pic(iconpos, [smalltext_x * 4,smalltext_y * 256 / 56 ], "textures/chaticons.png", '1 1 1', alpha, flags);
                drawresetcliparea();
            }
            iconpos_x += smalltext.x;
        }

        if(lines[i].chat & 2) {
            if (FO_ScoreBoardAssets.icon_afk != "") {
                sui_pic(iconpos, smalltext, FO_ScoreBoardAssets.icon_afk, '1 1 1', alpha, flags);
            } else {
                drawsetcliparea(iconpos_x + panel.Position.x, iconpos_y + panel.Position.y + 20, smalltext.x, smalltext.y);
                sui_pic(iconpos - [smalltext_x,0], [smalltext_x * 4,smalltext_y * 256 / 56 ], "textures/chaticons.png", '1 1 1', alpha, flags);
                drawresetcliparea();
            }
            iconpos_x += smalltext.x;
        }

        if (lines[i].team_no == TEAM_SPECTATOR || lines[i].team_no == TEAM_OBSERVER) {
            position_y += smalltext_y;
            position_x = 0;
            continue;
        }

        val = AbbreviateNumberToString(lines[i].caps);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].touches);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].kills);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].teamkills);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].deaths);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].afflicted);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].teamafflicted);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].damagegiven);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].damagetaken);
        drawShowScoresColumnVal(position, smalltext, val, SCOREB_FIELD, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        position_x = 0;
        position_y += smalltext_y;
    }

    size_y = smalltext.y * lineCount;
    sui_border_box([0, 0], size, 1, MENU_BORDER, FO_MENU_TRANSPARENCY, 0);
    return position;
};


void drawShowScoresPanel(PanelID panelid, string text) {
    FO_Hud_Panel* panel = getHudPanel(panelid);

    if (!panel.Display && !fo_hud_editor)
        return;

    vector position = getPanelPosition(panel);
    vector size = getPanelFillSize(panel);
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale * 2;
    vector textcolour = MENU_TEXT_1;
    float padding = 4 * panel.Scale;

    if (fo_hud_editor) {
        if (hud_panel(panelid, position, size, 0.3, panel.Display)) {
            // click event
        }
        return;
    }

    float i;

    for (i = 0; i < NUM_SCT; i++)
        score_board.team[i].count = 0;

    sui_push_frame(position, [size.x, 1]);
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
    position = [0,0];
    sui_text(position, mediumtext, "Scoreboard", textcolour, 1, 0);

    for (i = 0; i < FO_SCOREBOARDLINES_LENGTH; i++) {
        float ping = getplayerkeyfloat(i, INFOKEY_P_PING);
        if (!ping)
            continue;

        int sbl_team_no = getplayerkeyfloat(i, "team_no");
        switch (sbl_team_no) {
            case 1: case 2: case 3: case 4:
                sbl_team_no -= 1;  // Maps to SC enum
                break;
            default:
                sbl_team_no = SCT_SPECS;
                break;
        }

        FO_ScoreBoardTeam* team = &score_board.team[sbl_team_no];
        FO_ScoreBoardLine* sbl = &team->lines[team->count++];

        sbl->ping = ping;
        sbl->pl = getplayerkeyfloat(i, INFOKEY_P_PACKETLOSS);
        float class = getplayerkeyfloat(i, "playerclass");
        sbl->classtext = ClassToString(class);
        sbl->name = getplayerkeyvalue(i, INFOKEY_P_NAME);
        sbl->score = getplayerkeyfloat(i, INFOKEY_P_FRAGS);
        sbl->caps = getplayerkeyfloat(i, "caps");
        sbl->touches = getplayerkeyfloat(i, "touches");
        sbl->kills = getplayerkeyfloat(i, "kills");
        sbl->teamkills = getplayerkeyfloat(i, "teamkills");
        sbl->deaths = getplayerkeyfloat(i, "deaths");
        sbl->afflicted = getplayerkeyfloat(i, "afflicted");
        sbl->teamafflicted = getplayerkeyfloat(i, "teamafflicted");
        sbl->damagegiven = getplayerkeyfloat(i, "damagegiven");
        sbl->damagetaken = getplayerkeyfloat(i, "damagetaken");
        sbl->team_no = getplayerkeyfloat(i, "team_no");
        sbl->ready = getplayerkeyfloat(i, "ready");
        sbl->chat = getplayerkeyfloat(i, "chat");

        if (sbl_team_no == SCT_SPECS) {
            float spec = getplayerkeyfloat(i, "*spectator");
            sbl->team_no = (spec == 1) ? TEAM_SPECTATOR : TEAM_OBSERVER;
            sbl->classtext = (spec == 1) ? "Spectator" : "Observer";
        }
    }

    float sbCount = 0;

    vector smalltext = MENU_TEXT_SMALL * panel.Scale;
    vector yspacer = [0, 20];
    size_y = smalltext_y;

    for (i = 0; i < NUM_SCT; i++) {
        FO_ScoreBoardTeam* team = &score_board.team[i];
        if (!team->count)
            continue;

        position += yspacer;
        sui_push_frame(position, size);
        position = drawShowScoresTeamPanel(panel, team, padding,
                                           TEXT_TEAM_COLOUR[i]);
        sbCount++;
    }

    /*
    // FIXME
    maybe some colours on some columns to help differentiate them
    If possible, have AFK/msg indicators
    Reset between rounds
    Make a summary one for end of game too
    show who you are on scoreboard
    show who you are speccing
    when player comes in after caps occur, they aren't getting team score

*/

    for (float i = 0; i < sbCount; i++)
        sui_pop_frame();
    sui_pop_frame();
}

void (float show) FO_Show_Scores = {
    showingscores = show;
    getHudPanel(HUDP_SHOWSCORES)->Display = show;
};

struct SpeedBarColors {
    float max_speed;
    float frac;
    vector color;
};

const float SPEEDBAR_MAX = 3000;
static SpeedBarColors speedbar_colors[] = {
    { 300, 0.40,       '0.6 0.2 0.2'},
    { 400, 0.10,       '0.7 0.2 0.2'},
    { 500, 0.25,       '0.7 0.4 0.2'},
    { 750, 0.1225,     '0.7 0.7 0.3'},
    {1000, 0.1225,     '0.1 0.5 0.1'},
    {SPEEDBAR_MAX, 1,  '0.1 0.7 0.1'},
};

static float PlanarSpeed() {
    vector pvel = PM_Vel();
    pvel.z = 0;  // compiler bug: pvel becomes [1 0 0] if this is inlined
    return vlen(pvel);
}

void drawSpeedBar(PanelID panelid, string text) {
    FO_Hud_Panel* panel = getHudPanel(HUDP_SPEEDBAR);
    vector fillsize = panel.FillSize * panel.Scale;
    float alpha = fo_hud_editor ? 0.2:0.9;
    vector position = getPanelPosition(panel);

    if (hud_panel(panel->id, position, fillsize, alpha, panel.Display)) {
        // click event
    }

    if (fo_hud_editor)
        return;

    HRC_drawfill(position, fillsize, '0.5 0.5 0.5');

    position += '1 1 0';
    fillsize -= '1 2 0';
    float frac_start, frac_end = 1;

    float tspeed = PlanarSpeed();
    float rspeed = min(tspeed, SPEEDBAR_MAX);

    float last_max = 0;
    for (int i = 0; i < speedbar_colors.length; i++) {
        SpeedBarColors* cur = &speedbar_colors[i];

        if (frac_end > 0.99) {
            frac_start = 0;
            frac_end = cur.frac;
        } else {
            frac_start = frac_end;
            frac_end = min(frac_start + cur.frac, 1);
        }

        float pos;
        if (rspeed > cur.max_speed) {
            pos = frac_end;
            // When we know we're going to wrap, fill the prior color.
            if (frac_end > 0.99)
                frac_start = 0;
        } else {
            pos = (rspeed - last_max) / (cur.max_speed - last_max) *
                  (frac_end - frac_start) + frac_start;
        }

        vector start = position, fill = fillsize;
        start.x += frac_start * fill.x;
        fill.x *= pos - frac_start;
        HRC_drawfill(start, fill, cur.color);

        last_max = cur.max_speed;
        if (rspeed < last_max)
            break;
    }

    HRC_drawstring(position + '3 0 0', ftos((int)tspeed), '9 9 0', '1 1 1');
}

void drawReloadProgress(PanelID panelid, string text) {
    FO_Hud_Panel* panel = getHudPanel(HUDP_RELOADPROGRESS);
    vector fillsize = panel.FillSize * panel.Scale;
    vector position = getPanelPosition(panel);

    if (fo_hud_editor &&
        hud_panel(panel->id, position, fillsize, 0.2, panel.Display)) {
        // click event
    }

    if (!game_state.is_alive)
        return;

    float per = WP_ReloadPercent();
    if (per == 1)
        return;

    HRC_drawfill(position, fillsize, '0.5 0.5 0.5');
    vector progress = fillsize;
    progress.x *= per;

    position += '1 1 0';
    HRC_drawfill(position, progress - '1 2 0', '0.9 0.9 0.9');
    const string text = "Reloading";
    const vector fontsize = '8 8 0';
    position.x += (fillsize.x - stringwidth(text, 0, fontsize)) / 2;
    HRC_drawstring(position, text, fontsize, '1 0.4 0.4');
}

string getPingPanelText();

var FO_Hud_Panel Hud_Panels[] = {
//  id, Name, Position, FillSize, Scale, TextScale, Display, Orientation,
//  void drawPanel(PanelID panelid, string text, string icon),
//  string getValue(),
//  Style, Snap, Status

    {HUDP_TEAMSCORE, "teamscore", FO_HUD_TEAM_SCORE_NAME,  '0 0',     '72 12',  2,0,1,FO_HUD_INSERT_AFTER, 0, drawTeamScorePanel, {return "";}},
    {HUDP_MAP_MENU, "mapmenu", FO_HUD_MAP_MENU_NAME,      '10 30',   '800 400',1,0,1,FO_HUD_INSERT_MIDDLE, 1, drawMapMenuPanel, {return "";}},
    {HUDP_SHOWSCORES, "showscores", FO_HUD_SHOWSCORES_NAME, '10 100',  '600 200',1,0,1,FO_HUD_INSERT_MIDDLE, 1, drawShowScoresPanel, {return "";}},
    {HUDP_MENU, "menu", "Menu",                       '10 110',  '300 200',1,0,1,0,1, drawSimplePanel, {return "";}},
    {HUDP_MENU_HINT, "menuhint", FO_HUD_MENU_HINT_NAME,    '100 300', '300 24', 1,0,1,0,1, drawTextPanel, {return SBAR.Hint;}},
    {HUDP_CLIPSIZE, "clipsize", FO_HUD_CLIPSIZE_NAME,     '464 455', '26 26',  0.75,0,1,0,0, drawClipSize, { return WP_GetClip(); }},
    {HUDP_RELOADPROGRESS, "reload_progress", "Reload Progress",  '0 0',  '100 10', 1,1,1,0,0, drawReloadProgress, {return "";}, 0, HUD_SNAP_CENTER},
    {HUDP_FRAGSTREAK, "fragstreak", FO_HUD_FRAGSTREAK_NAME, '10 50',   '26 26',  1,0,1,0,0, drawFragStreakPanel, {return ftos(SBAR.FragStreak);}},
    {HUDP_CAPS, "caps", FO_HUD_CAPS_NAME,             '10 80',   '26 26',  1,0,1,0,0, drawCapsPanel, {return ftos(SBAR.Caps);}},
    {HUDP_GREN1, "gren1", FO_HUD_GREN1_NAME,           '10 110',  '26 26',  1,0,1,0,0, drawGren1Panel, {return ftos(WP_GrenCount(1));}},
    {HUDP_GREN2, "gren2", FO_HUD_GREN2_NAME,           '10 140',  '26 26',  1,0,1,0,0, drawGren2Panel, {return ftos(WP_GrenCount(2));}},
    {HUDP_SPECIAL, "playerclass", FO_HUD_SPECIAL_NAME,   '10 170',  '50 26',  1,0,1,0,0, drawSpecial, {return ftos(WP_PlayerClass());}},
    {HUDP_IDENTIFY, "identify", FO_HUD_IDENTIFY_NAME,     '10 200',  '50 26',  1,0,1,FO_HUD_INSERT_MIDDLE, 0, drawIdentify, {return SBAR.Identify;}},
    {HUDP_FLAGINFO, "flaginfo", FO_HUD_FLAGINFO_NAME,     '10 230',  '26 260', 1,0,1,0,0, drawFlagInfo, {return "";}},
    {HUDP_GRENTIMER, "grentimer", FO_HUD_GRENTIMER_NAME,   '100 110', '26 26',  1,0,1,0,0, drawGrenTimerPanel, {return "";}},
    {HUDP_MOTD, "motd", FO_HUD_MOTD_NAME,             '150 100', '100 24', 1,0,1,0,0, drawMOTDPanel, {return SBAR.MOTD;}},
    {HUDP_GAME_MODE, "gamemode", FO_HUD_GAME_MODE_NAME,    '100 140', '100 10', 1,0,1,0,0, drawGameModePanel, {return "";}},
    {HUDP_NOTIFICATION, "notification", FO_HUD_NOTIFICATION_NAME,           '10 100',  '100 10', 2,0,1,FO_HUD_INSERT_MIDDLE, 1, drawNotificationPanel, {return SBAR.Hint;}},
    {HUDP_HEALTH, "health", FO_HUD_HEALTH_NAME,         '-22 -2',  '72 24',  1,0,1,0,0, drawHealthArmourTextPanel, {return ftos(getstatf(STAT_HEALTH));}, 0, 34},
    {HUDP_FACE, "face", FO_HUD_FACE_NAME,             '-70 -2',  '24 24',  1,0,1,0,0, drawFacePanel, {return "";}, 0, 34},
    {HUDP_AMMO, "ammo", FO_HUD_AMMO_NAME,             '90 -2',   '72 24',  1,0,1,0,0, drawAmmoTextPanel, {return ftos(WP_CurrentAmmo());}, 0, 34},
    {HUDP_AMMOICON, "ammoicon", FO_HUD_AMMO_ICON_NAME ,   '42 -2',   '24 24',  1,0,1,0,0, drawAmmoPanel, {return "";}, 0, 34},
    {HUDP_ARMOUR, "armour", FO_HUD_ARMOUR_NAME,         '-134 -2', '72 24',  1,0,1,0,0, drawHealthArmourTextPanel, {return ftos(getstatf(STAT_ARMOR));}, 0, 34},
    {HUDP_ARMOURICON, "armouricon", FO_HUD_ARMOUR_ICON_NAME,'-182 -2', '24 24',  1,0,1,0,0, drawArmourPanel, {return "";}, 0, 34},
    {HUDP_INVSHELLS, "invshells", FO_HUD_INV_SHELLS_NAME,  '-2 -244', '24 24',  1,1.4,1,0,0, drawInvShellsPanel, {return ftos(WP_GetAmmo(AMMO_SHELLS));}, 1, 33},
    {HUDP_INVNAILS, "invnails", FO_HUD_INV_NAILS_NAME,    '-2 -220', '24 24',  1,1.4,1,0,0, drawInvNailsPanel, {return ftos(WP_GetAmmo(AMMO_NAILS));}, 1, 33},
    {HUDP_INVROCKETS, "invrockets", FO_HUD_INV_ROCKETS_NAME,'-2 -196', '24 24',  1,1.4,1,0,0, drawInvRocketsPanel, {return ftos(WP_GetAmmo(AMMO_ROCKETS));}, 1, 33},
    {HUDP_INVCELLS, "invcells", FO_HUD_INV_CELLS_NAME,    '-2 -172', '24 24',  1,1.4,1,0,0, drawInvCellsPanel, {return ftos(WP_GetAmmo(AMMO_CELLS));}, 1, 33},
    {HUDP_GAMECLOCK, "gameclock", "Game Clock",            '0 0'   ,  '108 24', 1,0.8,1,0,0, drawClockPanel, {return gameClockString();}, 0, 10},
    {HUDP_QUAD, "quad", "Quad Icon",                  '-200 -30','26 26',  1,1.4,1,0,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_QUAD)?"textures/wad/sb_quad":"";}, 0, 36},
    {HUDP_PENT, "pent", "Pentagram Icon",             '-170 -30','26 26',  1,1.4,1,0,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_INVULNERABILITY)?"textures/wad/sb_invuln":"";}, 0, 36},
    {HUDP_RING, "ring", "Ring Icon",                  '-140 -30','26 26',  1,1.4,1,0,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_INVISIBILITY)?"textures/wad/sb_invis":"";}, 0, 36},
    {HUDP_SUIT, "suit", "Biosuit Icon",               '-110 -30','26 26',  1,1.4,1,0,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_SUIT)?"textures/wad/sb_suit":"";}, 0, 36},
    {HUDP_KEY1, "key1", "Silver Key",                 '140 -30', '26 26',  0.6,1.4,1,0,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_KEY1)?"textures/wad/sb_key1":"";}, 0, 34},
    {HUDP_KEY2, "key2", "Gold Key",                   '160 -30', '26 26',  0.6,1.4,1,0,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_KEY2)?"textures/wad/sb_key2":"";}, 0, 34},
    {HUDP_RUNE1, "rune1", "Earth Rune",                '-200 0',  '26 26',  1,1.4,1,0,0, drawInvIconPanel, {return (getstatbits(STAT_ITEMS,28,4) & 1)?"textures/wad/sb_sigi1":"";}, 0, 34},
    {HUDP_RUNE2, "rune2", "Black Rune",                '-170 0',  '26 26',  1,1.4,1,0,0, drawInvIconPanel, {return (getstatbits(STAT_ITEMS,28,4) & 2)?"textures/wad/sb_sigil2":"";}, 0, 34},
    {HUDP_RUNE3, "rune3", "Hell Rune",                 '-140 0',  '26 26',  1,1.4,1,0,0, drawInvIconPanel, {return (getstatbits(STAT_ITEMS,28,4) & 4)?"textures/wad/sb_sigil3":"";}, 0, 34},
    {HUDP_RUNE4, "rune4", "Elder Rune",                '-110 0',  '26 26',  1,1.4,1,0,0, drawInvIconPanel, {return (getstatbits(STAT_ITEMS,28,4) & 8)?"textures/wad/sb_sigil4":"";}, 0, 34},
    {HUDP_GUN2, "gun2", "Shotgun",                    '-4 -170', '36 24',  0.8,1.4,1,0,0, drawInvIconPanel, {return getGunIcon(IT_SHOTGUN);}, 0, 36},
    {HUDP_GUN3, "gun3", "Super Shotgun",              '-4 -150', '36 24',  0.8,1.4,1,0,0, drawInvIconPanel, {return getGunIcon(IT_SUPER_SHOTGUN);}, 0, 36},
    {HUDP_GUN4, "gun4", "Nailgun",                    '-4 -130', '36 24',  0.8,1.4,1,0,0, drawInvIconPanel, {return getGunIcon(IT_NAILGUN);}, 0, 36},
    {HUDP_GUN5, "gun5", "Super Nailgun",              '-4 -110', '36 24',  0.8,1.4,1,0,0, drawInvIconPanel, {return getGunIcon(IT_SUPER_NAILGUN);}, 0, 36},
    {HUDP_GUN6, "gun6", "Grenade Launcher",           '-4 -90',  '36 24',  0.8,1.4,1,0,0, drawInvIconPanel, {return getGunIcon(IT_GRENADE_LAUNCHER);}, 0, 36},
    {HUDP_GUN7, "gun7", "Rocket Launcher",            '-4 -70',  '36 24',  0.8,1.4,1,0,0, drawInvIconPanel, {return getGunIcon(IT_ROCKET_LAUNCHER);}, 0, 36},
    {HUDP_GUN8, "gun8", "Lighning Gun",               '-4 -50',  '36 24',  0.8,1.4,1,0,0, drawInvIconPanel, {return getGunIcon(IT_LIGHTNING);}, 0, 36},
    {HUDP_SPEED, "speed", "Speed",                     '4 15',    '26 26',  1,1.4,0,0,0, drawTextPanel, {return CVARF(fo_fte_hud) ? ftos((int)PlanarSpeed()) : "";}, 0, 4},
    {HUDP_SPEEDBAR, "speedbar", "Speed Bar",           '4 30',    '150 10',  1,1.4,0,0,0, drawSpeedBar, {return "";}, 0, 4},
    {HUDP_PING, "ping", "Ping",           '4 15',    '120 12',  1,1.4,0,0,0, drawTextPanel, getPingPanelText, 0, HUD_SNAP_TOP_RIGHT},
    {HUDP_OPTIONS, "hudoptions", FO_HUD_OPTIONS_NAME,    '10 10',   '150 182',1,   0,1,0,1, doNothing, {return "";}, 1},
};

inline FO_Hud_Panel* (PanelID panelid) getHudPanel = {
    ASSERTD_NE(panelid, HUDP_INVALID);
    return &Hud_Panels[panelid - HUDP_FIRST];
};

FO_Hud_Panel* (string save_name) getHudPanelBySaveName = {
    for(float i = HUDP_FIRST; i <= HUDP_LAST; i++) {
        FO_Hud_Panel* panel = getHudPanel(i);
        if (panel->SaveName == save_name)
            return panel;
    }
    return &NullPanel;
};

vector (FO_Hud_Panel* panel, float scale) getScaledPanelPosition = {
    if(panel.Snap == HUD_SNAP_NONE) {
        return panel.Position;
    }
    vector v = panel.Position;
    //if(panel.Snap & HUD_SNAP_LEFT) v.x;
    if(panel.Snap & HUD_SNAP_CENTER) v.x += (ScreenSize.x / 2) - ((panel.FillSize.x * scale) / 2);
    if(panel.Snap & HUD_SNAP_RIGHT) v.x += ScreenSize.x - (panel.FillSize.x * scale);
    //if(panel.Snap & HUD_SNAP_TOP) v.y;
    if(panel.Snap & HUD_SNAP_VCENTER) v.y += (ScreenSize.y / 2) - ((panel.FillSize.y * scale) / 2);
    if(panel.Snap & HUD_SNAP_BOTTOM) v.y += ScreenSize.y - (panel.FillSize.y * scale);
    return v;
}

vector (FO_Hud_Panel* panel) getPanelPosition = {
    return getScaledPanelPosition(panel, panel.Scale);
}

vector(PanelID panelid) getPosition = {
    FO_Hud_Panel* panel = getHudPanel(panelid);
    return getPanelPosition(panel);
}
vector(PanelID panelid) getFillSize = {
    return getHudPanel(panelid)->FillSize;
}

vector (FO_Hud_Panel* panel) getPanelFillSize = {
    return panel.FillSize;
}

vector (FO_Hud_Panel* panel) getScaledPanelFillSize = {
    return panel.FillSize * panel.Scale;
}
