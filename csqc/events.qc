void ParseSBAR();
void AddGrenTimer(float grentype);

void() CSQC_Parse_Event = {
    float msgtype = readbyte();
    local float goalno;
    entity te;
    switch (msgtype) {
        case MSG_FLAGINFOINIT:
            float index = readfloat();
            goalno = readfloat();
            string mdl = readstring();
            float skinindex = readfloat();
            float ownerteam = readfloat();
            float iconindex = readfloat();

            //use next available
            if(index < 0) {
                for(float i = 0; i < FlagInfoLines.length; i++) {
                    if(FlagInfoLines[i].id == 0) {
                        index = i;
                        break;
                    }
                }
            }
            if(index >= 0 && index < MAX_FLAGINFO_LINES) {
                FlagInfoLines[index].id = goalno;
                FlagInfoLines[index].message = "";
                if(mdl)
                    precache_model(mdl);
                te = spawn();
                te.renderflags = RF_VIEWMODEL | RF_DEPTHHACK | RF_NOSHADOW;
                te.origin = [5, 0, 0];
                te.angles = '-60 0 0';
                te.skin = skinindex;
                te.owned_by = ownerteam;

                string iconname = "sb_key1";
                vector iconcolour = '1 1 1';
                if(iconindex == FLAGINFO_ICON_FLAG) {
                    iconname = strcat("flag_", ftos(ownerteam));
                    iconcolour = '1 1 1';
                } else if(iconindex == FLAGINFO_ICON_BUTTON) {
                    iconname = strcat("off_icon_glow_", ftos(ownerteam));
                    iconcolour = '1 1 1';
                }
                FlagInfoLines[index].icon.filename = iconname;
                FlagInfoLines[index].icon.colour = iconcolour;
                FlagInfoLines[index].model = te;
            }
            break;
        case MSG_FLAGINFO:
            string message = "";
            goalno = readfloat();
            float state = readfloat();
            float timeleft = -1;
            vector droploc = '0 0 0';
            string carrier = "";
            string locname = "";
            switch (state) {
                case FLAGINFO_HOME:
                    message = "^2HOME";
                    break;
                case FLAGINFO_CARRIED:
                    carrier = readstring();
                    message = strcat("^1CARRIED^7 by ",carrier);
                    break;
                case FLAGINFO_DROPPED:
                    message = "^3DROPPED^7";
                    timeleft = readfloat();
                    float showloc = readfloat();
                    if(showloc == FLAGINFO_LOCATION) {
                        droploc_x = readcoord();
                        droploc_y = readcoord();
                        droploc_z = readcoord();
                        locname = readstring();
                        message = strcat(message," at ", locname);
                    }
                    break;
                case FLAGINFO_RETURNING:
                    message = "^4RETURNING";
                    break;
            }
            for(float i = 0; i < FlagInfoLines.length; i++) {
                if(FlagInfoLines[i].id == goalno) {
                    FlagInfoLines[i].message = message;
                    FlagInfoLines[i].timeleft = timeleft;
                    FlagInfoLines[i].state = state;
                    FlagInfoLines[i].loc = droploc;
                    FlagInfoLines[i].carrier = carrier;
                    FlagInfoLines[i].locname = locname;
                }
            }
            break;
        case MSG_SBAR:
            ParseSBAR();
            break;
        case MSG_ID:
            SBAR.Identify = readstring();
            break;
        case MSG_GRENPRIMED:
            float grentype = readfloat();
            float timertype = cvar(FOCMD_GRENTIMER);
            if(timertype != 2) {
                AddGrenTimer(grentype);
            }
            if(timertype == 1) {
                localcmd("play grentimer.wav\n");
            } 
            break;
        case MSG_CLIENT_MENU:
            float menutype = readfloat();
            switch (menutype) {
                case CLIENT_MENU_TEAM:
                    number_of_teams = readfloat();
                    for(float i = 0; i < 4; i++) {
                        if(i < number_of_teams) {
                            FO_MENU_TEAM.options[i].value = ftos(readbyte());
                            if((i + 1) != team_no) {
                                FO_MENU_TEAM.options[i].state = FO_MENU_STATE_NORMAL;
                            } else {
                                FO_MENU_TEAM.options[i].state = FO_MENU_STATE_DISABLED;
                            } 
                        } else {
                            FO_MENU_TEAM.options[i].state = FO_MENU_STATE_DISABLED;
                        }
                    }
                    FO_Menu_Team(2);
                    break;
                case CLIENT_MENU_CLASS:
                    FO_Menu_Class(2);
                    break;
                case CLIENT_MENU_DROPAMMO:
                    FO_Menu_DropAmmo(FALSE);
                    break;
                case CLIENT_MENU_SCOUT:
                    float scanner_on = readbyte();
                    float scanner_flags = readfloat();
                    
                    FO_Menu_Scout(2, scanner_on, scanner_flags);
                    break;
                case CLIENT_MENU_SPY:
                    SBAR.InvisOnly = readfloat();
                    last_skin = readfloat();
                    last_team = readfloat();
                    FO_Menu_Spy(2);
                    break;
                case CLIENT_MENU_SPY_SKIN:
                    FO_Menu_Spy_Skin(2);
                    break;
                case CLIENT_MENU_SPY_TEAM:
                    FO_Menu_Spy_Team(FALSE);
                    break;
                case CLIENT_MENU_DETPACK:
                    FO_Menu_Detpack(2, readbyte());
                    break;
                case CLIENT_MENU_BUILD:
                    FO_Menu_Build(2);
                    break;
                case CLIENT_MENU_ROTATE_SENTRY:
                    FO_Menu_Rotate_Sentry(FALSE);
                    break;
                case CLIENT_MENU_FIX_DISPENSER:
                    FO_Menu_Dispenser_Fix(FALSE, readbyte());
                    break;
                case CLIENT_MENU_USE_DISPENSER:
                    touched_dispenser_pos = [readfloat(),readfloat(),readfloat()];
                    FO_Menu_Dispenser_Use(FALSE);
                    break;
                case CLIENT_MENU_ADMIN:
                    FO_Menu_Admin_Main(TRUE);
                    break;
                case CLIENT_MENU_ADMIN_KICK:
                    FO_Menu_Admin_Players(TRUE, CLIENT_MENU_ADMIN_KICK, 0);
                    break;
                case CLIENT_MENU_VOTE:
                    mapvote_expiry = time + readfloat();
                    FO_MENU_VOTE.options[0].name = readstring();
                    FO_MENU_VOTE.options[0].value = ftos(readfloat());
                    FO_MENU_VOTE.options[1].name = readstring();
                    FO_MENU_VOTE.options[1].value = ftos(readfloat());
                    FO_MENU_VOTE.options[2].name = readstring();
                    FO_MENU_VOTE.options[2].value = ftos(readfloat());
                    FO_MENU_VOTE.options[3].name = readstring();
                    FO_MENU_VOTE.options[3].value = ftos(readfloat());
                    FO_MENU_VOTE.options[5].name = readstring();
                    FO_MENU_VOTE.options[5].value = ftos(readfloat());
                    FO_Menu_Vote(FALSE);
                    break;
                case CLIENT_MENU_CAPTAIN_PICK:
                    FO_Menu_Admin_Players(TRUE, CLIENT_MENU_CAPTAIN_PICK, 0);
                    break;
                case CLIENT_MENU_MAPS:
                    showVoteMenu(!Hud_Panels[HUD_PANEL_MAP_MENU].Display);
                    break;
            }
            break;
        case MSG_CLASSES_UPDATE:
            float civonly = readbyte();
            for(float i = 0; i < 10; i++) {
                if(civonly) {
                    FO_MENU_CLASS.options[i].value = "-";
                    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_CLASS) {
                        Menu_Cancel();
                    }
                } else {
                    float class_max = readfloat();
                    if(class_max < 0) {
                        FO_MENU_CLASS.options[i].value = "-";
                        FO_MENU_CLASS.options[i].state = FO_MENU_STATE_DISABLED;
                    } else {
                        FO_MENU_CLASS.options[i].value = strcat(ftos(readbyte()),"/",ftos(class_max));
                        FO_MENU_CLASS.options[i].state = FO_MENU_STATE_NORMAL;
                    }
                }
            }

            break;
        case MSG_SENTRY_POS:
            sentry_pos = [readfloat(),readfloat(),readfloat()];
            break;
        case MSG_DISPENSER_POS:
            dispenser_pos = [readfloat(),readfloat(),readfloat()];
            break;
        case MSG_SERVER_ADMIN_INFO:
            is_admin = TRUE;
            SERVER_ADMIN.ceasefire = readbyte();
            SERVER_ADMIN.quad_rounds = readfloat();
            SERVER_ADMIN.quad_round_time = readfloat();
            SERVER_ADMIN.timelimit = readfloat();
            SERVER_ADMIN.fraglimit = readfloat();
            SERVER_ADMIN.clanmode = readfloat();
            SERVER_ADMIN.quadmode = readfloat();
            SERVER_ADMIN.duelmode = readfloat();
            SERVER_ADMIN.pubmode =  (((SERVER_ADMIN.clanmode & 1) || (SERVER_ADMIN.quadmode & 1) || (SERVER_ADMIN.duelmode & 1))?1:0) + 
                                    (((SERVER_ADMIN.clanmode & 2) || (SERVER_ADMIN.quadmode & 2) || (SERVER_ADMIN.duelmode & 2))?2:0);
            SERVER_ADMIN.pubmode = 3 - SERVER_ADMIN.pubmode; //Invert
            SERVER_ADMIN.captainmode = readfloat();
            break;
        case MSG_CAPTAINS:
            captain1 = readfloat();
            captain2 = readfloat();
            break;
        case MSG_MOTD:
            SBAR.MOTD = strcat(readstring(), "\n", readstring());
            SBAR.GameMode = readfloat();
            SBAR.CountdownStarted = FALSE;
            motd_expiry = time + MOTD_TIME;
            quad_rounds_total = readfloat();
            number_of_teams = readfloat();
            break;
        case MSG_PREMATCH:
            prematch = readbyte();
            round_active = readbyte();
            round_over = readbyte();
            SBAR.CountdownStarted = readbyte();
            //SBAR.GameMode = SBAR.GameMode - (SBAR.GameMode & 8) + ((prematch & 1)?8:0);
            //SBAR.GameMode = SBAR.GameMode - (SBAR.GameMode & 16) + ((prematch & 2)?16:0);
            //SBAR.GameMode = SBAR.GameMode - (SBAR.GameMode & 32) + ((prematch & 4)?32:0);
            //motd_expiry = time + MOTD_TIME;
            quad_round = readfloat();
            //game_started = readbyte();
            break;
        case MSG_GRENADESETTINGS:
            fo_flash = readfloat();
            medic_type = readfloat();
            nailgren_type = readfloat();
            break;
        case MSG_GRENTHROWN:
            grentimer_waiting = FALSE;
            break;
        case MSG_TEAM_SCORES:
            TeamScore[0] = readfloat();
            TeamScore[1] = readfloat();
            TeamScore[2] = readfloat();
            TeamScore[3] = readfloat();
            break;
        case MSG_VOTE_UPDATE:
            te = AddVoteMap(readstring(), "","",0,0,0,FALSE);
            te.votecount = readfloat();
            if(readbyte()) {
                current_vote = te;
            } else {
                if(current_vote == te) {
                    current_vote = world;
                }
            }
            break;
        case MSG_VOTE_MAP_ADD:
            te = AddVoteMap(readstring(), readstring(), readstring(), readfloat(), readfloat(), readfloat(), FALSE);
            te.votecount = readfloat();
            if(readbyte()) {
                current_vote = te;
            } else {
                if(current_vote == te) {
                    current_vote = world;
                }
            }
            break;
        case MSG_VOTE_MAP_DELETE:
            RemoveVoteMap(readstring(), FALSE);
            break;
    }
}

void ParseSBAR()
{
    SBAR.ClipSize = readstring();
    SBAR.FragStreak = readfloat();
    SBAR.Caps = readfloat();
    SBAR.PlayerClass = readfloat();

    if (SBAR.PlayerClass)
    {
        SBAR.Gren1 = readfloat();
        SBAR.Gren2 = readfloat();
    }
    
    switch (SBAR.PlayerClass)
    {
        case PC_SCOUT:
            SBAR.ScannerOn = readfloat();
            if (SBAR.ScannerOn)
            {
                SBAR.ScannerRange = readfloat();

                if (SBAR.ScannerRange)
                {
                    SBAR.ScannerTeamNo = readfloat();
                    SBAR.ScannerPlayerClass = readfloat();
                    SBAR.ScannerTFItemsFlags = readfloat();
                }
            }
            break;
        case PC_SNIPER:
            SBAR.SniperDam = readfloat();
            SBAR.SniperMax = readfloat();
            break;
        case PC_DEMOMAN:
            SBAR.IsDetpacking = readfloat();
            SBAR.DetpackLeft = readfloat();
            break;
        case PC_MEDIC:
            float medicaura = readfloat();
            if (medicaura)
            {
                SBAR.AuraActive = readfloat();
                if (SBAR.AuraActive)
                {
                    SBAR.HealCount = readfloat();
                    SBAR.HealAmount = readfloat();
                    SBAR.AuraStatus = readfloat();
                }
            }
            break;
        case PC_HVYWEAP:
            SBAR.LockedCannon = readfloat();
            break;
        case PC_PYRO:
            SBAR.AirBlast = readfloat();
            break;
        case PC_SPY:
            SBAR.IsUndercover = readfloat();

            if (SBAR.IsUndercover == 1)
            {
                SBAR.InvisOnly = readfloat();
                SBAR.UndercoverTeam = readfloat();
                SBAR.UndercoverSkin = readfloat();
            }
            else if (SBAR.IsUndercover == 2)
            {
                SBAR.InvisOnly = readfloat();
                SBAR.UndercoverTimer = readfloat();
                SBAR.UndercoverTeam = readfloat();
                SBAR.DisguiseTeam = readfloat();
                SBAR.QueueTeam = readfloat();
                SBAR.UndercoverSkin = readfloat();
                SBAR.DisguiseSkin = readfloat();
                SBAR.QueueSkin = readfloat();
            }
            break;
        case PC_ENGINEER:
            SBAR.IsBuilding = readfloat();
            if (SBAR.IsBuilding)
            {
                SBAR.BuildingPercentage = readfloat();
            }
            
            SBAR.HasSentry = readfloat();
            if (SBAR.HasSentry)
            {
                SBAR.SentryLevel = readfloat();
                SBAR.SentryHealth = readfloat();
                SBAR.SentryAmmoShells = readfloat();
                SBAR.SentryAmmoRockets = readfloat();
            }
            
            SBAR.HasDispenser = readfloat();
            if (SBAR.HasDispenser)
            {
                SBAR.DispenserHealth = readfloat();
            }
            break;
    }
    if(!readfloat()) {
        grentimer_waiting = FALSE;
    }
}
