float GetTextAlignOffset(float pos, float width, float iconsize, string text, float textsize, float align);
float fo_to_sui_aligntment(float fo_align);
vector (FO_Hud_Panel* panel) getPanelPosition;
vector (FO_Hud_Panel* panel) getPanelFillSize;
void Hud_DrawPanelLMP(FO_Hud_Panel*, string, string, float);
void Hud_DrawLMPThreshold(FO_Hud_Panel*, string, float);
FO_Hud_Panel* getHudPanelPointer(float);
FO_Hud_Panel* getAnyHudPanelByNamePointer(string);

void(string panelid, float display, string text) drawClipSize = {
    if (SBAR.ClipSize != "" || fo_hud_editor)
    {
        Hud_DrawPanelLMP(getAnyHudPanelByNamePointer(panelid), text, ICON_CLIPSIZE, 1);
    }
};

void(string panelid, float display, string text) drawIdentify = {
    if (strlen(SBAR.Identify) > 0 || fo_hud_editor)
    {
        GetDrawPanel(panelid);
        Hud_DrawIdentifyPanel(panelid, text);
    }
};

void(string panelid, float display, string text) drawTeamScorePanel = {
    if (display || fo_hud_editor)
    {
        GetDrawPanel(panelid);
        Hud_DrawTeamScorePanel(panelid);
    }
};

void(string panelid, float display, string text) drawMapMenuPanel = {
    if (display || fo_hud_editor)
    {
        GetDrawPanel(panelid);
        Hud_DrawMapMenuPanel(panelid);
    }
};

void(string panelid, float display, string text) drawFlagInfo = {
    if (display || fo_hud_editor)
    {
        GetDrawPanel(panelid);
        Hud_DrawFlagStatusBar(panelid);
    }
};

void(string panelid, float display, string text, string icon) drawIconPanel = {
    if (display || fo_hud_editor)
    {
        Hud_DrawPanelLMP(getAnyHudPanelByNamePointer(panelid), text, icon, 1);
    }
};

void(string panelid, float display, string text) drawFragStreakPanel = {
    drawIconPanel(panelid, display, text, ICON_FRAGSTREAK);
};

void(string panelid, float display, string text) drawCapsPanel = {
    drawIconPanel(panelid, display, text, ICON_CAPS);
};

void(string panelid, float display, string text) drawGren1Panel = {
    local float playerclass = SBAR.PlayerClass;

    if (playerclass < PC_SCOUT || playerclass > PC_ENGINEER) {
        return;
    }

    local float gren_type = getstatf(STAT_TP_GREN1);
    local string icon = GrenadeIcons[gren_type].icon;

    drawIconPanel(panelid, display, text, icon);
};

void(string panelid, float display, string text) drawGren2Panel = {
    local float playerclass = SBAR.PlayerClass;

    if (playerclass < PC_SCOUT || playerclass > PC_ENGINEER) {
        return;
    }

    local float gren_type = getstatf(STAT_TP_GREN2);
    local string icon = GrenadeIcons[gren_type].icon;

    drawIconPanel(panelid, display, text, icon);
};

void(string panelid, float display, string text) drawSpecial = {
    if (SBAR.PlayerClass || fo_hud_editor)
    {
        GetDrawPanel(panelid);
        Hud_DrawClassInfoPanel(panelid, SBAR.PlayerClass);
    }
};

void(string panelid, float display, string text) drawGrenTimerPanel = {
    float timeleft;
    float timercount = 0;

    if (display) {
        FO_Hud_Panel* panel = getAnyHudPanelByNamePointer(panelid);
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
            float alpha = (gt.is_thrown() || timercount) ? 0.3 : 1.0;
            Hud_DrawPanelLMP(&panel2, ftos(timeleft),
                GrenadeIcons[gt.grentype()].icon, alpha);
            panel2.Position = panel2.Position +
                [0, panel2.FillSize.y * panel2.Scale];
            timercount++;
        }
    }
    if(fo_hud_editor && (!display || !timercount)) {
        Hud_DrawPanelLMP(getAnyHudPanelByNamePointer(panelid), text, ICON_GREN_NORMAL, 1);
    }
};

void(string panelid, float display, string text) drawFacePanel = {
    if (!CVARF(fo_fte_hud))
        return;

    local float playerclass = SBAR.PlayerClass; //we could add different faces per class?

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

    drawIconPanel(panelid, display, text, icon);
};

void(string panelid, float display, string text) drawArmourPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    local float playerclass = SBAR.PlayerClass;

    local string icon = fo_hud_editor?ArmourIcons[1].icon:"";
    
    if(playerclass) {
        local float items = getstatf(STAT_ITEMS);
        if(items & IT_INVULNERABILITY) icon = ArmourIcons[0].icon;
        else if(items & IT_ARMOR1) icon = ArmourIcons[1].icon;
        else if(items & IT_ARMOR2) icon = ArmourIcons[2].icon;
        else if(items & IT_ARMOR3) icon = ArmourIcons[3].icon;
    }

    if(icon != "") drawIconPanel(panelid, display, text, icon);
};

void(string panelid, float display, string text) drawAmmoPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    local string icon = fo_hud_editor?AmmoIcons[0].icon:"";
    
    local float items = getstatf(STAT_ITEMS);
    if(items & IT_SHELLS) icon = AmmoIcons[0].icon;
    else if(items & IT_NAILS) icon = AmmoIcons[1].icon;
    else if(items & IT_ROCKETS) icon = AmmoIcons[2].icon;
    else if(items & IT_CELLS) icon = AmmoIcons[3].icon;

    if(icon != "") drawIconPanel(panelid, display, text, icon);
};

void(string panelid, float display, string text) drawInvIconPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    if(text && text != "") {
        drawIconPanel(panelid, display, "", text);
    } else if(fo_hud_editor) {
        drawIconPanel(panelid, display, "", FaceIcons[0].icon);
    }
};
void(string panelid, float display, string text) drawInvShellsPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawIconPanel(panelid, display, text, AmmoIcons[0].icon);
};
void(string panelid, float display, string text) drawInvNailsPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawIconPanel(panelid, display, text, AmmoIcons[1].icon);
};
void(string panelid, float display, string text) drawInvRocketsPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawIconPanel(panelid, display, text, AmmoIcons[2].icon);
};
void(string panelid, float display, string text) drawInvCellsPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawIconPanel(panelid, display, text, AmmoIcons[3].icon);
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

void(string panelid, float display, string text, float threshold) drawBigNumberPanel = {
    if (display || fo_hud_editor)
    {
        Hud_DrawLMPThreshold(getAnyHudPanelByNamePointer(panelid), text, threshold);
    }
};

void(string panelid, float display, string text) drawHealthTextPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawBigNumberPanel(panelid, display, text, 26);
};

void(string panelid, float display, string text) drawAmmoTextPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawBigNumberPanel(panelid, display, text, 11);
};

void(string panelid, float display, string text) drawClockPanel = {
    if(!CVARF(fo_fte_hud))
        return;

    drawBigNumberPanel(panelid, display, text, 0);
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
    
    if(round_time_remaining) {
        float t = round_time_remaining - time; 
        if(t < 0) t = t * -1;
        minutes = floor(t/60);
        seconds = floor(t - (minutes*60));
    } else if(timelimit) {
        minutes = floor(time/60);
        seconds = 60 - floor(time - (minutes*60));
        minutes = timelimit - ceil(time/60);
        if(minutes < 0) minutes = minutes * -1;
        if(seconds < 0) seconds = seconds * -1;
    } else {
        minutes = floor(time/60);
        seconds = floor(time - (minutes*60));
    }
    
    string sm = strcat((minutes<10?"0":""),ftos(minutes));
    string ss = strcat((seconds<10?"0":""),ftos(seconds));
    
    string tmp = strcat(sm,":",ss);
    //if(round_time_remaining) tmp = ftos(floor(round_time_remaining - time));
    
    return tmp;  
};

void(string panelid, float display, string text) doNothing = {};

void(string panelid, float display, string text) drawSimplePanel = {
    if (fo_hud_editor) {
        FO_Hud_Panel* panel = getAnyHudPanelByNamePointer(panelid);
        if(panel && &panel != &NullPanel) {
            if (hud_panel(panelid, getPanelPosition(panel), getPanelFillSize(panel), 0.3, 1)) {
                // click event
            }
        }
    }
}

void(string panelid, float display, string text) drawTextPanel = {
    FO_Hud_Panel* panel = getAnyHudPanelByNamePointer(panelid);
    
    vector position = getPanelPosition(panel);
    vector size = getPanelFillSize(panel);
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale;
    local float padding = 4 * panel.Scale;
    local float transparency = 0.3;
    local float lines;
    if (fo_hud_editor) {
        drawstring(
            [GetTextAlignOffset(position.x,size.x,padding,panelid,mediumtext.x,panel.Orientation), padding*2 + position.y],
            panelid, 
            mediumtext, 
            MENU_TEXT_1, 
            1, 
            0
        );
        if (hud_panel(panelid, position, size, transparency, panel.Display)) {
            // click event
        }
    } else {
        if(showingscores || !panel.Display) {
            return;
        }
        if(text && text != "") {
            //sui_border_box(position, size, 1, MENU_BORDER, transparency, 0);
            //sui_push_frame(position, size);

            //sui_fill([0, 0], size, MENU_BG, transparency, 0);

            //sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
            //sui_action_element([0, 0], size, panelid, sui_noop);
            //sui_pop_frame();
            lines = tokenizebyseparator(text, "\n");
            local string line;
            for (float i = 0; i <= lines; i++) {
                line = argv(i);
                // tokenize doesn't handle newlines very well
                line = strreplace("\n", "", line);
                line = strtrim(line);
                if (strlen(line) > 0) {
                    drawstring(
                        [GetTextAlignOffset(position.x,size.x,padding,line,mediumtext.x,panel.Orientation), position.y + padding + mediumtext.y*i],
                        line, 
                        mediumtext, 
                        MENU_TEXT_1, 
                        1, 
                        0
                    );
                }
            }
        }
    }
}

void(string panelid, float display, string text) drawMOTDPanel = {
    FO_Hud_Panel* panel = getAnyHudPanelByNamePointer(panelid);
    
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
    if((showingscores || !panel.Display) && !fo_hud_editor) {
        return;
    }
    //if(text && text != "") {
        if((!intermission && time < motd_expiry && !team_no) || fo_hud_editor) {
            sui_push_frame(position, size);
            sui_set_align([fo_to_sui_aligntment(panel.Orientation), SUI_ALIGN_CENTER]);
            local string motd = serverkey("hostname");
            sui_text([0,0], mediumtext*textscale*1.5, motd, MENU_TEXT_4, 1, 0);
            /*
            drawstring(
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
                    drawstring(
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

void(string panelid, float display, string text) drawGameModePanel = {
    FO_Hud_Panel* panel = getAnyHudPanelByNamePointer(panelid);
    
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
        drawstring(
            [GetTextAlignOffset(position.x,size.x,padding,message,mediumtext.x,panel.Orientation), position.y],
            message, 
            mediumtext, 
            MENU_TEXT_1, 
            1, 
            0
        );
    }
}

void(string panelid, float display, string text) drawReadyPanel = {
    FO_Hud_Panel* panel = getAnyHudPanelByNamePointer(panelid);

    vector position = getPanelPosition(panel);
    vector size = getPanelFillSize(panel);
    vector textsize = MENU_TEXT_SMALL * panel.Scale;
    vector textcolour = MENU_TEXT_4;
    local float padding = 4 * panel.Scale;
    local float lines;
    local float pos_aligned;
    local string message = "";
    if (fo_hud_editor) {
        message = "Ready Status";
        if (hud_panel(panelid, position, size, 0.3, panel.Display)) {
            // click event
        }
    } else {
        if(showingscores || !panel.Display) {
            return;
        }
        if(prematch && team_no && player_class && !SBAR.CountdownStarted && !is_spectator) {
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

                    drawstring(
                        [pos_aligned, alert_text_position.y],
                        alert_text_message,
                        alert_text_size,
                        textcolour,
                        1,
                        0
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

                    drawstring(
                        [pos_aligned, alert_text_position.y],
                        alert_text_message,
                        alert_text_size,
                        textcolour,
                        1,
                        0
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
        }
    }
    if(message) {
        pos_aligned = GetTextAlignOffset(position.x,size.x,padding,message,textsize.x,panel.Orientation);
        drawstring(
            [pos_aligned, position.y],
            message,
            textsize,
            textcolour,
            1,
            0
        );
    }
}

float (float val) AbbreviateNumber = {
    val = val / 1000;
    val = rint(val);
    return val;
};

string (float val) AbbreviateNumberToString = {
    string abbr = "";

    int count = 0;
    while (val >= 1000)
    {
        val = AbbreviateNumber(val);
        count++;
    }

    switch (count)
    {
        case 1:
            abbr = "k";
            break;
        case 2:
            abbr = "m";
            break;
        case 3:
            abbr = "b";
            break;
    }
    
    string s = strcat(ftos(val), abbr);
    return s;
};

void (vector position, vector size, string val, vector textcolour, float alpha
    , float flags, string colname, optional float padright = FALSE) drawShowScoresColumnVal = {
    float valwidth, colwidth;
    
    colwidth = strlen(colname);
    if (padright == TRUE)
    {
        val = strpad(colwidth, val);
    }
    else
    {
        val = strpad(colwidth * -1, val);
    }
    
    sui_text(position, size, val, textcolour, 1, 0);
};

vector (FO_ScoreBoardLine *lines, FO_Hud_Panel *panel
    , float padding, vector columnColour) drawShowScoresTeamPanel = {
    vector textcolour = MENU_TEXT_1;
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

    for (float i = 0; i < FO_ScoreBoardColumns.length; i++)
    {
        string colname = FO_ScoreBoardColumns[i];
        if (lines[i].team_no == TEAM_SPECTATOR || lines[i].team_no == TEAM_OBSERVER)
        {
            switch (colname)
            {
                case "class":
                    colname = "type";
                case "ping":
                case "pl":
                case "name":
                    sui_text(position, smalltext, colname, columnColour, .7, 0);
                    break;
            }
        }
        else
        {
            sui_text(position, smalltext, colname, columnColour, .7, 0);
        }
        
        txtlength = strlen(colname) * smalltext.x;
        if (colname == "name")
        {
            position_x += namespace;
        }
        else
        {
            position_x += txtlength + padding;
        }
    }

    position = [0, smalltext.y];
    float lineCount = 1;
    for (float i = 0; i < FO_SCOREBOARDLINES_LENGTH; i++)
    {
        string name = lines[i].name;
        if (!name)
            continue;

        lineCount++;
        float trans = 1;
        if (lineCount % 2 == 0)
        {
            trans = .7;
        }
        else
        {
            trans = .3;
        }
        
        sui_fill(position, size, columnColour, trans, 0);

        textcolour = MENU_TEXT_1;
        if(lines[i].name == getplayerkeyvalue(player_localnum, "name")) {
            textcolour = MENU_TEXT_4;
        } else if(lines[i].name == getplayerkeyvalue(player_localentnum - 1, "name")) {
            textcolour = '0.8 0 0.8';
        } else {
            if (prematch && lines[i].team_no && !SBAR.CountdownStarted 
                && lines[i].team_no != TEAM_SPECTATOR && lines[i].team_no != TEAM_OBSERVER)
            {
                float ready = lines[i].ready;
                if (ready)
                {
                    textcolour = MENU_TEXT_GREEN_FO;
                }
                else
                {
                    textcolour = MENU_TEXT_RED_FO;
                }
            }
        }

        float col = 0, alpha = 1, flags = 0;
        string val = AbbreviateNumberToString(lines[i].ping);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].pl);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        if (team_no == lines[i].team_no || lines[i].team_no == TEAM_SPECTATOR || lines[i].team_no == TEAM_OBSERVER
            || is_spectator || is_observer)
        {
            string c = lines[i].classtext;
            if (lines[i].team_no != TEAM_SPECTATOR && lines[i].team_no != TEAM_OBSERVER)
            {
                float cspace = strlen(c) * smalltext.x;
                if (cspace > classspace)
                {
                    float max = classspace / smalltext.x;
                    // TODO - maybe make this ok with non fixed width fonts one day... we're 90% of the way there
                    c = substring(c, 0, max);
                }
            }
            
            sui_text(position, smalltext, c, textcolour, 1, 0);
        }
        
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        if (lines[i].team_no != TEAM_SPECTATOR && lines[i].team_no != TEAM_OBSERVER)
        {
            val = AbbreviateNumberToString(lines[i].score);
            drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        }
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        string n = lines[i].name;
        if (strlen(n) * smalltext.x >= (namespace - padding))
        {
            float diff = (namespace - padding) / smalltext.x;
            n = substring(n, 0, diff);
        }
        sui_text(position, smalltext, n, textcolour, 1, 0);
        position_x += namespace;

        vector iconpos = [size_x, position_y]; 
        //check for icon files existing, otherwise use fallbacks
        float filehandle;
        if(lines[i].ready) {
            filehandle = fopen(strcat("textures/wad/icon_ready.png"), FILE_READ);
            if (filehandle >= 0) {
                fclose(filehandle);
                sui_pic(iconpos, smalltext, "textures/wad/icon_ready.png", '1 1 1', alpha, flags);
            } else {
                sui_text(iconpos, smalltext, "R", MENU_TEXT_GREEN_FO, 1, 0);
            }
            iconpos_x += smalltext.x;
        }
        if(lines[i].chat & 1) {
            filehandle = fopen(strcat("textures/wad/icon_chat.png"), FILE_READ);
            if (filehandle >= 0) {
                fclose(filehandle);
                sui_pic(iconpos, smalltext, "textures/wad/icon_chat.png", '1 1 1', alpha, flags);
            } else {
                //use ezquake chaticons image. Couldn't get drawsubpic to work, so now we get this instead
                drawsetcliparea(iconpos_x + panel.Position.x, iconpos_y + panel.Position.y + 20, smalltext.x, smalltext.y);
                sui_pic(iconpos, [smalltext_x * 4,smalltext_y * 256 / 56 ], "textures/chaticons.png", '1 1 1', alpha, flags);
                drawresetcliparea();
            }
            iconpos_x += smalltext.x;
        }
        if(lines[i].chat & 2) {
            filehandle = fopen(strcat("textures/wad/icon_afk.png"), FILE_READ);
            if (filehandle >= 0) {
                fclose(filehandle);
                sui_pic(iconpos, smalltext, "textures/wad/icon_afk.png", '1 1 1', alpha, flags);
            } else {
                drawsetcliparea(iconpos_x + panel.Position.x, iconpos_y + panel.Position.y + 20, smalltext.x, smalltext.y);
                sui_pic(iconpos - [smalltext_x,0], [smalltext_x * 4,smalltext_y * 256 / 56 ], "textures/chaticons.png", '1 1 1', alpha, flags);
                drawresetcliparea();
            }
            iconpos_x += smalltext.x;
        }

        if (lines[i].team_no == TEAM_SPECTATOR || lines[i].team_no == TEAM_OBSERVER)
        {
            position_y += smalltext_y;
            position_x = 0;
            continue;
        }

        val = AbbreviateNumberToString(lines[i].caps);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].touches);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].kills);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].teamkills);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].deaths);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].afflicted);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].teamafflicted);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].damagegiven);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        val = AbbreviateNumberToString(lines[i].damagetaken);
        drawShowScoresColumnVal(position, smalltext, val, textcolour, alpha, flags, FO_ScoreBoardColumns[col]);
        position_x += strlen(FO_ScoreBoardColumns[col++]) * smalltext.x + padding;

        position_x = 0;
        position_y += smalltext_y;
    }
    
    size_y = smalltext.y * lineCount;
    sui_border_box([0, 0], size, 1, MENU_BORDER, FO_MENU_TRANSPARENCY, 0);
    return position;
};

void(string panelid, float display, string text) drawShowScoresPanel = {
    FO_Hud_Panel* panel = getAnyHudPanelByNamePointer(panelid);
    
    vector position = getPanelPosition(panel);
    vector size = getPanelFillSize(panel);
    vector mediumtext = MENU_TEXT_SMALL * panel.Scale * 2;
    vector textcolour = MENU_TEXT_1;
    float padding = 4 * panel.Scale;

    if (fo_hud_editor) {
        if (hud_panel(panelid, position, size, 0.3, panel.Display)) {
            // click event
        }
    } else {
        if(!panel.Display) {
            return;
        }       

        FO_ScoreBoardLine FO_ScoreBoardLines_Blue[FO_SCOREBOARDLINES_LENGTH];
        FO_ScoreBoardLine FO_ScoreBoardLines_Red[FO_SCOREBOARDLINES_LENGTH];
        FO_ScoreBoardLine FO_ScoreBoardLines_Yellow[FO_SCOREBOARDLINES_LENGTH];
        FO_ScoreBoardLine FO_ScoreBoardLines_Green[FO_SCOREBOARDLINES_LENGTH];
        FO_ScoreBoardLine FO_ScoreBoardLines_Specs[FO_SCOREBOARDLINES_LENGTH];

        sui_push_frame(position, [size.x, 1]);     
        sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
        position = [0,0];
        sui_text(position, mediumtext, "Scoreboard", textcolour, 1, 0);

        float bluecount = 0, redcount = 0, yellowcount = 0, greencount = 0, speccount = 0;
        for (float i = 0; i < FO_SCOREBOARDLINES_LENGTH; i++)
        {            
            FO_ScoreBoardLine sbl;
            sbl.ping = getplayerkeyfloat(i, INFOKEY_P_PING);
            if (!sbl.ping)
            {
                continue;
            }
            sbl.pl = getplayerkeyfloat(i, INFOKEY_P_PACKETLOSS);
            float class = getplayerkeyfloat(i, "playerclass");
            sbl.classtext = ClassToString(class);
            sbl.name = getplayerkeyvalue(i, INFOKEY_P_NAME);
            sbl.score = getplayerkeyfloat(i, INFOKEY_P_FRAGS);
            sbl.caps = getplayerkeyfloat(i, "caps");
            sbl.touches = getplayerkeyfloat(i, "touches");
            sbl.kills = getplayerkeyfloat(i, "kills");
            sbl.teamkills = getplayerkeyfloat(i, "teamkills");
            sbl.deaths = getplayerkeyfloat(i, "deaths");
            sbl.afflicted = getplayerkeyfloat(i, "afflicted");
            sbl.teamafflicted = getplayerkeyfloat(i, "teamafflicted");
            sbl.damagegiven = getplayerkeyfloat(i, "damagegiven");
            sbl.damagetaken = getplayerkeyfloat(i, "damagetaken");
            sbl.team_no = getplayerkeyfloat(i, "team_no");
            sbl.ready = getplayerkeyfloat(i, "ready");
            sbl.chat = getplayerkeyfloat(i, "chat");

            switch (sbl.team_no)
            {
                case 1:
                    FO_ScoreBoardLines_Blue[bluecount++] = sbl;
                    break;
                case 2:
                    FO_ScoreBoardLines_Red[redcount++] = sbl;
                    break;
                case 3:
                    FO_ScoreBoardLines_Yellow[yellowcount++] = sbl;
                    break;
                case 4:
                    FO_ScoreBoardLines_Green[greencount++] = sbl;
                    break;
                default:
                    float spec = getplayerkeyfloat(i, "*spectator");
                    sbl.team_no = (spec == 1) ? TEAM_SPECTATOR : TEAM_OBSERVER;
                    sbl.classtext = (spec == 1) ? "Spectator" : "Observer";
                    FO_ScoreBoardLines_Specs[speccount++] = sbl;
                    break;
            }
        }

        float sbCount = 0;

        vector smalltext = MENU_TEXT_SMALL * panel.Scale;
        vector yspacer = [0, 20];
        size_y = smalltext_y;
        
        if (FO_ScoreBoardLines_Blue[0].name)
        {
            position += yspacer;
            sui_push_frame(position, size);
            position = drawShowScoresTeamPanel(FO_ScoreBoardLines_Blue, panel, padding, MENU_TEXT_BLUE_FO);
            sbCount++;
        }
            
        if (FO_ScoreBoardLines_Red[0].name)
        {
            position += yspacer;
            sui_push_frame(position, size);
            position = drawShowScoresTeamPanel(FO_ScoreBoardLines_Red, panel, padding, MENU_TEXT_RED_FO);
            sbCount++;
        }
            
        if (FO_ScoreBoardLines_Yellow[0].name)
        {
            position += yspacer;
            sui_push_frame(position, size);
            position = drawShowScoresTeamPanel(FO_ScoreBoardLines_Yellow, panel, padding, MENU_TEXT_YELLOW_FO);
            sbCount++;
        }
            
        if (FO_ScoreBoardLines_Green[0].name)
        {
            position += yspacer;
            sui_push_frame(position, size);
            position = drawShowScoresTeamPanel(FO_ScoreBoardLines_Green, panel, padding, MENU_TEXT_GREEN_FO);
            sbCount++;
        }

        if (FO_ScoreBoardLines_Specs[0].name)
        {
            position += yspacer;
            sui_push_frame(position, size);
            position = drawShowScoresTeamPanel(FO_ScoreBoardLines_Specs, panel, padding, MENU_TEXT_SPEC_FO);
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
        {
            sui_pop_frame();
        }
        
        sui_pop_frame();
    }
}

void (float show) FO_Show_Scores = {
    showingscores = show;
    FO_Hud_Panel* panel = getAnyHudPanelByNamePointer("showscores");
    if(panel && &panel != &NullPanel) panel.Display = show;
};

var FO_Hud_Panel Hud_Panels[] = {
//  id, Name, Position, FillSize, Scale, TextScale, Display, Orientation,
//  void drawPanel(string panelid, float display, string text, string icon),
//  string getValue(),
//  Style, Snap, Status

    {"hudoptions",FO_HUD_OPTIONS_NAME,    '10 10',   '150 182',1,   0,1,0, doNothing, {return DrawPanel.id;}, 1},
    {"clipsize",FO_HUD_CLIPSIZE_NAME,     '464 455', '26 26',  0.75,0,1,0, drawClipSize, { return SBAR.ClipSize; }},
    {"fragstreak",FO_HUD_FRAGSTREAK_NAME, '10 50',   '26 26',  1,0,1,0, drawFragStreakPanel, {return ftos(SBAR.FragStreak);}},
    {"caps",FO_HUD_CAPS_NAME,             '10 80',   '26 26',  1,0,1,0, drawCapsPanel, {return ftos(SBAR.Caps);}},
    {"gren1",FO_HUD_GREN1_NAME,           '10 110',  '26 26',  1,0,1,0, drawGren1Panel, {return ftos(getstatf(STAT_NO_GREN1));}},
    {"gren2",FO_HUD_GREN2_NAME,           '10 140',  '26 26',  1,0,1,0, drawGren2Panel, {return ftos(getstatf(STAT_NO_GREN2));}},
    {"playerclass",FO_HUD_SPECIAL_NAME,   '10 170',  '50 26',  1,0,1,0, drawSpecial, {return ftos(SBAR.PlayerClass);}},
    {"identify",FO_HUD_IDENTIFY_NAME,     '10 200',  '50 26',  1,0,1,FO_HUD_INSERT_MIDDLE, drawTextPanel, {return SBAR.Identify;}},
    {"flaginfo",FO_HUD_FLAGINFO_NAME,     '10 230',  '26 260', 1,0,1,0, drawFlagInfo, {return "";}},
    {"grentimer",FO_HUD_GRENTIMER_NAME,   '100 110', '26 26',  1,0,1,0, drawGrenTimerPanel, {return "";}},
    {"menu","Menu",                       '10 110',  '300 200',1,0,1,0, drawSimplePanel, {return "";}},
    {"motd",FO_HUD_MOTD_NAME,             '150 100', '100 24', 1,0,1,0, drawMOTDPanel, {return SBAR.MOTD;}},
    {"menuhint",FO_HUD_MENU_HINT_NAME,    '100 300', '300 24', 1,0,1,0, drawTextPanel, {return SBAR.Hint;}},
    {"gamemode",FO_HUD_GAME_MODE_NAME,    '100 140', '100 10', 1,0,1,0, drawGameModePanel, {return "";}},
    {"ready",FO_HUD_READY_NAME,           '10 100',  '100 10', 2,0,1,FO_HUD_INSERT_MIDDLE, drawReadyPanel, {return SBAR.Hint;}},
    {"showscores",FO_HUD_SHOWSCORES_NAME, '10 100',  '600 200',1,0,0,FO_HUD_INSERT_MIDDLE, drawShowScoresPanel, {return "";}},
    {"teamscore",FO_HUD_TEAM_SCORE_NAME,  '0 0',     '72 12',  2,0,1,FO_HUD_INSERT_AFTER, drawTeamScorePanel, {return "";}},
    {"mapmenu",FO_HUD_MAP_MENU_NAME,      '10 30',   '800 400',1,0,1,FO_HUD_INSERT_MIDDLE, drawMapMenuPanel, {return "";}},
    {"health",FO_HUD_HEALTH_NAME,         '-22 -2',  '72 24',  1,0,1,0, drawHealthTextPanel, {return ftos(getstatf(STAT_HEALTH));}, 0, 34},
    {"face",FO_HUD_FACE_NAME,             '-70 -2',  '24 24',  1,0,1,0, drawFacePanel, {return "";}, 0, 34},
    {"ammo",FO_HUD_AMMO_NAME,             '90 -2',   '72 24',  1,0,1,0, drawAmmoTextPanel, {return ftos(getstatf(STAT_AMMO));}, 0, 34},
    {"ammoicon",FO_HUD_AMMO_ICON_NAME ,   '42 -2',   '24 24',  1,0,1,0, drawAmmoPanel, {return "";}, 0, 34},
    {"armour",FO_HUD_ARMOUR_NAME,         '-134 -2', '72 24',  1,0,1,0, drawHealthTextPanel, {return ftos(getstatf(STAT_ARMOR));}, 0, 34},
    {"armouricon",FO_HUD_ARMOUR_ICON_NAME,'-182 -2', '24 24',  1,0,1,0, drawArmourPanel, {return "";}, 0, 34},
    {"invshells",FO_HUD_INV_SHELLS_NAME,  '-2 -244', '24 24',  1,1.4,1,0, drawInvShellsPanel, {return ftos(getstatf(STAT_SHELLS));}, 1, 33},
    {"invnails",FO_HUD_INV_NAILS_NAME,    '-2 -220', '24 24',  1,1.4,1,0, drawInvNailsPanel, {return ftos(getstatf(STAT_NAILS));}, 1, 33},
    {"invrockets",FO_HUD_INV_ROCKETS_NAME,'-2 -196', '24 24',  1,1.4,1,0, drawInvRocketsPanel, {return ftos(getstatf(STAT_ROCKETS));}, 1, 33},
    {"invcells",FO_HUD_INV_CELLS_NAME,    '-2 -172', '24 24',  1,1.4,1,0, drawInvCellsPanel, {return ftos(getstatf(STAT_CELLS));}, 1, 33},
    {"gameclock","Game Clock",            '0 0'   ,  '108 24', 1,0.8,1,0, drawClockPanel, {return gameClockString();}, 0, 10},
    {"quad","Quad Icon",                  '-200 -30','26 26',  1,1.4,1,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_QUAD)?"textures/wad/sb_quad":"";}, 0, 36},
    {"pent","Pentagram Icon",             '-170 -30','26 26',  1,1.4,1,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_INVULNERABILITY)?"textures/wad/sb_invuln":"";}, 0, 36},
    {"ring","Ring Icon",                  '-140 -30','26 26',  1,1.4,1,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_INVISIBILITY)?"textures/wad/sb_invis":"";}, 0, 36},
    {"suit","Biosuit Icon",               '-110 -30','26 26',  1,1.4,1,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_SUIT)?"textures/wad/sb_suit":"";}, 0, 36},
    {"key1","Silver Key",                 '140 -30', '26 26',  0.6,1.4,1,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_KEY1)?"textures/wad/sb_key1":"";}, 0, 34},
    {"key2","Gold Key",                   '160 -30', '26 26',  0.6,1.4,1,0, drawInvIconPanel, {return (getstatf(STAT_ITEMS) & IT_KEY2)?"textures/wad/sb_key2":"";}, 0, 34},
    {"rune1","Earth Rune",                '-200 0',  '26 26',  1,1.4,1,0, drawInvIconPanel, {return (getstatbits(STAT_ITEMS,28,4) & 1)?"textures/wad/sb_sigi1":"";}, 0, 34},
    {"rune2","Black Rune",                '-170 0',  '26 26',  1,1.4,1,0, drawInvIconPanel, {return (getstatbits(STAT_ITEMS,28,4) & 2)?"textures/wad/sb_sigil2":"";}, 0, 34},
    {"rune3","Hell Rune",                 '-140 0',  '26 26',  1,1.4,1,0, drawInvIconPanel, {return (getstatbits(STAT_ITEMS,28,4) & 4)?"textures/wad/sb_sigil3":"";}, 0, 34},
    {"rune4","Elder Rune",                '-110 0',  '26 26',  1,1.4,1,0, drawInvIconPanel, {return (getstatbits(STAT_ITEMS,28,4) & 8)?"textures/wad/sb_sigil4":"";}, 0, 34},
    {"gun2","Shotgun",                    '-4 -170', '36 24',  0.8,1.4,1,0, drawInvIconPanel, {return getGunIcon(IT_SHOTGUN);}, 0, 36},
    {"gun3","Super Shotgun",              '-4 -150', '36 24',  0.8,1.4,1,0, drawInvIconPanel, {return getGunIcon(IT_SUPER_SHOTGUN);}, 0, 36},
    {"gun4","Nailgun",                    '-4 -130', '36 24',  0.8,1.4,1,0, drawInvIconPanel, {return getGunIcon(IT_NAILGUN);}, 0, 36},
    {"gun5","Super Nailgun",              '-4 -110', '36 24',  0.8,1.4,1,0, drawInvIconPanel, {return getGunIcon(IT_SUPER_NAILGUN);}, 0, 36},
    {"gun6","Grenade Launcher",           '-4 -90',  '36 24',  0.8,1.4,1,0, drawInvIconPanel, {return getGunIcon(IT_GRENADE_LAUNCHER);}, 0, 36},
    {"gun7","Rocket Launcher",            '-4 -70',  '36 24',  0.8,1.4,1,0, drawInvIconPanel, {return getGunIcon(IT_ROCKET_LAUNCHER);}, 0, 36},
    {"gun8","Lighning Gun",               '-4 -50',  '36 24',  0.8,1.4,1,0, drawInvIconPanel, {return getGunIcon(IT_LIGHTNING);}, 0, 36},
    {"speed","Speed",                     '4 15',    '26 26',  1,1.4,0,0, drawTextPanel, {return CVARF(fo_fte_hud) ? sprintf("%3.1f UPS", speed) : "";}, 0, 4},
};

//var FO_Hud_Panel Hud_ExtraPanels[] = {
//};

FO_Hud_Panel* (float panelid) getHudPanelPointer = {
    return &(Hud_Panels[panelid]);
};

FO_Hud_Panel* (string panelid) getAnyHudPanelByNamePointer = {
    for(float i = 0; i < Hud_Panels.length; i++) {
        if(Hud_Panels[i].id == panelid) {
            return &(Hud_Panels[i]);
        }
    }    
//    for(float i = 0; i < Hud_ExtraPanels.length; i++) {
//        if(Hud_ExtraPanels[i].id == panelid) {
//            return &(Hud_ExtraPanels[i]);
//        }
//    }    
    return &NullPanel;
};

vector (FO_Hud_Panel* panel, float scale) getScaledPanelPosition = {
    if(panel.Snap == HUD_SNAP_NONE) {
        return panel.Position; //Hud_Panels[panelid].Position;
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

vector(float panelid) getPosition = {
    FO_Hud_Panel* panel = getHudPanelPointer(panelid);
    return getPanelPosition(panel);
}
vector(float panelid) getFillSize = {
    return Hud_Panels[panelid].FillSize;
}

vector (FO_Hud_Panel* panel) getPanelFillSize = {
    return panel.FillSize;
}

vector (FO_Hud_Panel* panel) getScaledPanelFillSize = {
    return panel.FillSize * panel.Scale;
}
