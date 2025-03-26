void (entity pe_player) FO_SpecTrackPoint;

void () UpdateAllAdmins = {
    local entity ent = find(world, classname, "player");
    while(ent) {
        if(ent.is_admin) {
            Update_ServerAdminInfo(ent);
        }
        ent = find(ent, classname, "player");
    }
    ent = find(world, classname, "observer");
    while(ent) {
        if(ent.is_admin) {
            Update_ServerAdminInfo(ent);
        }
        ent = find(ent, classname, "observer");
    }
}

void () RestartMap = {
    bprint(PRINT_HIGH, self.netname);
    bprint(PRINT_HIGH, " Has restarted the map.\n");

    localcmd ("changelevel ");
    localcmd (mapname);
    localcmd ("\n");
}

void () ForceStartMatch = {
    if (fo_login_required) {
        bprint(PRINT_HIGH, "Can't forcestart while logins enabled.\n");
        return;
    }

    if (clanbattle == 1 && cb_prematch == 1) {
        bprint(PRINT_HIGH, self.netname);
        bprint(PRINT_HIGH, " has forced the match start.\n");
        StartTimer();
    }
}

void (float inp) SetQuadRounds = {
    //No idea - for some reason quad rounds have a +1 count to the actual number
    rounds = inp + 1;
    local string cmd;
    cmd = strcat("localinfo rounds ", ftos(inp), "\n");
    localcmd(cmd);
    bprint(2, "Quad Round Number changed to ", ftos(inp), "\n");
    UpdateAllAdmins();
}


void () QuadMode =
{
    localcmd ("localinfo clan on\n");
    localcmd ("localinfo quadmode on\n");
    localcmd ("localinfo duelmode off\n");
    localcmd ("localinfo rounds 2\n");
    localcmd ("timelimit 0\n");
    localcmd ("localinfo round_time 10\n");
    localcmd ("localinfo teamfrags on\n");
    localcmd ("localinfo fullteamscore off\n");
    localcmd ("fraglimit 0\n");
    localcmd ("localinfo rd 0\n"); 
    localcmd ("localinfo votemode 0\n"); 
    localcmd ("localinfo vote_style 2\n"); 
    localcmd ("exec fo_quadmode.cfg\n");
	bprint (PRINT_HIGH, "Quad Mode set to on\n");
    bprint (PRINT_HIGH, "Map Restart needed to take effect!\n");
};

void () ClanMode =
{
    localcmd("localinfo clan on\n");
    localcmd ("localinfo rd 0\n"); 
    localcmd ("localinfo votemode 0\n"); 
    localcmd ("localinfo vote_style 2\n"); 
    localcmd ("localinfo rounds 0\n");
    localcmd ("exec fo_clanmode.cfg\n");
    bprint(PRINT_HIGH, "Clan Mode set to on\n");
	bprint(PRINT_HIGH, "Map Restart needed to take effect!\n");
};

void () PubMode = 
{
    localcmd ("localinfo clan off\n");
    localcmd ("localinfo quadmode off\n");
    localcmd ("localinfo duelmode off\n");
    localcmd ("localinfo teamfrags off\n");
    localcmd ("localinfo fullteamscore off\n");
    localcmd ("password none\n");
    localcmd ("localinfo rounds 0\n");
    localcmd ("timelimit 20\n");
    localcmd ("fraglimit 0\n");
    localcmd ("localinfo round_time 0\n");
    localcmd ("localinfo rd 0\n"); 
    localcmd ("localinfo votemode 0\n"); 
    localcmd ("localinfo vote_style 1\n"); 
    localcmd ("exec fo_pubmode.cfg\n");
    bprint(PRINT_HIGH, "Pub Mode set to on\n");
	bprint(PRINT_HIGH, "Map Restart needed to take effect!\n");
}

void () DuelMode =
{
    localcmd ("localinfo teamfrags off\n");
    localcmd ("localinfo fullteamscore off\n");
    localcmd ("localinfo clan on\n");
    localcmd ("localinfo quadmode off\n");
    localcmd ("localinfo duelmode on\n");
    localcmd ("localinfo sf on\n"); // spawnfull, ie spawn fully stocked
    localcmd ("localinfo drd 3.9\n"); // wait before resetting the winner long enough for grens to go off
    localcmd ("localinfo rd 9999\n"); // wait before respawning the loser
    localcmd ("localinfo dph 1\n"); // print health of duel survivors 
    localcmd ("localinfo stockfull on\n"); // all packs fully restock
    localcmd ("localinfo stock_reload on\n"); // all packs insta-reload
    localcmd ("timelimit 0\n");
    localcmd ("fraglimit 30\n");
    localcmd ("localinfo votemode 0\n"); 
    localcmd ("localinfo vote_style 2\n"); 
    localcmd ("exec fo_duelmode.cfg\n");
    bprint(PRINT_HIGH, "Duel Mode set to on\n");
	bprint(PRINT_HIGH, "Map Restart needed to take effect!\n");
}

void new_balance_mode() {
    new_balance ^= 2;
    if (new_balance & 2)
        localcmd("localinfo new_balance 1\n");
    else
        localcmd("localinfo new_balance 0\n");
}

void (entity pe) SetEquipmentForPlayer = {
    entity oldself = self;
    self = pe;
    TeamFortress_SetEquipment();
    //self.immune_to_check = time + 10;
    //self.undercover_team = 0;
    stuffcmd(self, "color ");
    string st = TeamFortress_TeamGetColor(self.team_no);
    stuffcmd(self, st);
    stuffcmd(self, "\n");

    self = oldself;
}

void (float cap1, float cap2) CaptainMode = {
    captainmode = 1;
    bprint(PRINT_HIGH, "\x10\sCaptain Mode\s\x11\s:\s All available players are now Observers\n");
    local string st = 0;
    local float userid = 0, csqcactive = 0;
    local entity oldself;// = self;
    local entity te = find (world, classname, "player");
    while (te != world) {
        userid = infokeyf(te, INFOKEY_P_USERID);
        csqcactive = infokeyf(te, INFOKEY_P_CSQCACTIVE);
        //te.immune_to_check = time + 10;
        if(userid == cap1 || userid == cap2) {
            te.captain = 9;
            te.playerclass = 0;
            if(userid == cap1) {
                //playerSetTeam(1);
                te.team_no = 1;
                SetTeamName(te);
                TeamFortress_TeamSet_Options(te, 1, TRUE);

                UpdateAllClientsTeamScores();

                //stuffcmd(self, "color ");
                //st = ftos(TeamFortress_TeamGetColor (1) - 1);
                //stuffcmd(self, st);
                //stuffcmd(self, "\n");
                //SetTeamName(self);
            }
            if(userid == cap2) {
                //playerSetTeam(2);
                te.team_no = 2;
                SetTeamName(te);
                TeamFortress_TeamSet_Options(te, 2, TRUE);
                UpdateAllClientsTeamScores();

                //stuffcmd(self, "color ");
                //st = ftos(TeamFortress_TeamGetColor (2) - 1);
                //stuffcmd(self, st);
                //stuffcmd(self, "\n");
                //SetTeamName(self);
            }
            bprint(PRINT_HIGH, "\x10\sCaptain Mode\s\x11\s:\s ");
            bprint(PRINT_HIGH, te.netname);
            bprint(PRINT_HIGH, " \bis the captain for team\b ");
            bprint(PRINT_HIGH, TeamToString(te.team_no));
            bprint(PRINT_HIGH, "\b.\b\n");
            if(csqcactive) {
                //fte+csqc has its own team menu
                //ask the client to activate it
                Menu_Close(te);
                UpdateClientMenu_Captain(te);
            } else {
                //self = te;
                Menu_Close(te);
                te.current_menu_type = ADMIN_MENU_TYPE_CAPTAINSELECT;
                te.current_menu_page = 1;
                //Menu_Admin();
            }
        } else {
            te.captain = 0;
            //self = te;
            //playerSetTeam(-1);
            te.team_no = 0;
            te.playerclass = 0;
            oldself = self;
            self = te;
            TeamFortress_ChangeClass(0);
            self = oldself;
            SetTeamName(te);
            //TeamFortress_TeamSet_Options(te, 0, TRUE);
            //stuffcmd(te, "color 0 0\n");
            //SetTeamName(te);

            te.current_menu = 0;
            te.impulse = 0;
        }
        if(csqcactive) {
            UpdateClient_Captains(te, cap1, cap2);
        }
        SetEquipmentForPlayer(te);
        te = find (te, classname, "player");
    }
    //self = oldself;
}

void (entity cap1, entity cap2) StopCaptainMode = {
    if(captainmode){
        local entity oldself = self;
        self = cap1;
        TeamFortress_TeamSet(cap1.team_no);
        self = cap2;
        TeamFortress_TeamSet(cap2.team_no);
        captainmode = 0;
        self = oldself;
    }
}

void (entity cap, float pick) CaptainPick = {
    if(!cap.captain) {
        sprint(self, PRINT_HIGH, "You are not a captain, sorry\n");
        return;
    }
    local float countleft = 0, userid = 0;
    local entity picked = world, othercap = world, oldself;
    local entity te = find (world, classname, "player");
    while (te != world) {
        userid = infokeyf(te, INFOKEY_P_USERID);
        if(userid == pick) {
            picked = te;
        }
        if(!te.team_no) {
            countleft++;
        }
        if(te != cap && te.captain) {
            othercap = te;
        }
        te = find (te, classname, "player");
    }
    if(picked != world) {
        if(picked == cap) {
            sprint(self, PRINT_HIGH, "You don't have to pick yourself, it's implied...\n");
            return;
        }
        if(picked.captain) {
            sprint(self, PRINT_HIGH, picked.netname ," is a captain, thus unpickable!\n");
            return;
        }
        if(picked.team_no) {
            sprint(self, PRINT_HIGH, picked.netname ," has already been picked!\n");
            return;
        }
        bprint(PRINT_HIGH, "\x10\bCaptain Mode\b\x11\b:\b ");
        bprint(PRINT_HIGH, picked.netname);
        bprint(PRINT_HIGH, " \bcalled\b ");
        bprint(PRINT_HIGH, cap.netname);
        bprint(PRINT_HIGH, " \bfor team\b ");
        bprint(PRINT_HIGH, TeamToString(cap.team_no));
        bprint(PRINT_HIGH, "\b.\b\n");
        oldself = self;
        self = picked;
        TeamFortress_TeamSet(cap.team_no);
        self = oldself;
    } else {
        sprint(self, PRINT_HIGH, "Sorry, couldn't pick ", picked.netname ,"\n");
    }
    if(!countleft) {
        bprint(PRINT_HIGH, "\x10\sCaptain Mode\s\x11\s:\s \sTeams are set,  let's start the game!\s\n");
        StopCaptainMode(cap, othercap);
    }
}

void (entity pl) PrintWho = {
    local string msg;
    msg = strzone(string_null);
    msg = strcat(msg, infokey(pl,"name"));
    msg = strcat(msg, " - ");
    if (pl.login != string_null)
        msg = strcat(msg, pl.login);
    else
        msg = strcat(msg, "NOT LOGGED IN");
    if (pl.is_admin) {
        msg = strcat(msg, " (admin)");
    }
    msg = strcat(msg, "\n");
    sprint(self, PRINT_HIGH, msg);
    strunzone(msg);
}

void (entity pov, string command, string color) UpdateTeamColor = {
    forceinfokey(pov, command, color);

    local entity target = find(world, classname, "player");
    while (target != world) {
        SetSkinInfoFor(pov, target);
        target = find(target, classname, "player");
    }
}

float (string arg1, string arg2, string arg3, string arg4) ParseCmds = {
    local float arg_num = 0, processedCmd, inp;
    local string tmp;
    local float farg2, farg3, farg4;
    local entity ent, pl;
    processedCmd = FALSE;

    if (arg1)
        arg_num = 1;
    if (arg2)
        arg_num = 2;

    switch (arg1)
    {
        case "impulse":
            if (arg_num == 2) {
                self.impulse = stof(arg2);
            }
            break;
        case "progsversion":
            // yy.mm.dd.incremented vers
            sprint(self, PRINT_HIGH, "sv progs version: 22.02.13.1\n");
            break;
        case "adminpwd":
            processedCmd = TRUE;
            if (arg_num == 2) {
                Admin_Check(arg2);
                if (self.is_admin) {
                    Admin_Aliases();
                }
            }
            if (arg_num == 1) {
                sprint(self, PRINT_HIGH, "usage: cmd adminpwd password, where password is the admin password\n");
                sprint(self, PRINT_HIGH, "\n");
            }
            break;
        case "setinfo":
            if (arg2) {
                switch(arg2) {
                    case "team1color":
                    case "team2color":
                    case "team3color":
                    case "team4color":
                        UpdateTeamColor(self, arg2, arg3);
                        processedCmd = TRUE;
                        break;
                }
            }
            break;
        case "changeteam":
            processedCmd = TRUE;
           if (self.classname == "observer") {
#if 0
                sprint(self, PRINT_HIGH, "You can't join a team while spectating! Join the game first.\n");
                break;
#else
                clientcommand(self, "join");
#endif
            }
            if(teamplay == 0) {
                sprint(self, PRINT_HIGH, "You can't join a team when teamplay is disabled!\n");
                break;
            }
            if(number_of_teams == 1) {
                if(self.team_no == 0) {
                    TeamFortress_TeamSet(1);
                } else {
                    sprint(self, PRINT_HIGH, "Only one team is available on this map.\n");
                }
                break;
            }

            if (arg2) {
                local float final_round = (rounds == 1);

                switch(arg2) {
                    case "attack":
                        self.all_time = ALL_TIME_ATTACK;
                        arg2 = final_round ? "2" : "1";
                        sprint(self, PRINT_HIGH, "Always on the attacking team\n");
                        break;
                    case "defence":
                        self.all_time = ALL_TIME_DEFENCE;
                        arg2 = final_round ? "1" : "2";
                        sprint(self, PRINT_HIGH, "Always on the defending team\n");
                        break;
                    default:
                        self.all_time = ALL_TIME_COLOUR;
                }

                if(arg2 == "auto") {
                    if(self.team_no == 0) {
                        TeamFortress_TeamPutPlayerInTeam();
                        //UpdateClientMenu_Class(self);
                        Menu_Class(0);
                        break;
                    } else {
                        sprint(self, PRINT_HIGH, "You can't auto team when you're already playing!\n");
                        break;
                    }
                }

                if(arg2 == "1" || arg2 == "2" || arg2 == "3" || arg2 == "4") {
                    float newteam = stof(arg2), oldteam = self.team_no;
                    if(number_of_teams == 0 || newteam <= number_of_teams) {
                        TeamFortress_TeamSet(newteam);
                        if(!oldteam) {
                            //UpdateClientMenu_Class(self);
                            Menu_Class(0);
                        }
                        break;
                    }
                }
                sprint(self, PRINT_HIGH, "Invalid team choice. Please use values 1-",number_of_teams?ftos(number_of_teams):"4",self.team_no?"":" or 'auto'",".\n");
            } else {
                //UpdateClientMenu_Team(self);
                Menu_Team(0);
            }

            break;
        case "changeclass":
            processedCmd = TRUE;
            if(self.classname == "observer") {
                sprint(self, PRINT_HIGH, "You can't pick a class while spectating! Join the game first.\n");
                break;
            }
            if (arg2) {
                float newclass = stof(arg2);
                               
                if (!newclass) {
                    sprint(self, PRINT_HIGH, "Invalid class choice. Please use values 1-10.\n");
                    break;
                }
                
                override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
                
                // close menu if selected class is current class
                if (newclass == self.nextpc) {
                    sprint(self, PRINT_HIGH, "You're already going to play that class!\n");
                    break;
                }
                
                // keep showing menu if class is invalid
                if (newclass < 1 || newclass > 10 || (!IsLegalClass(newclass) && !override_mapclasses) || (self.playerclass != newclass && CF_ClassIsRestricted(self.team_no, newclass))) {                    
                    sprint(self, PRINT_HIGH, "Invalid class for this team!\n");
                    Menu_Class(0);
                    break;
                }

                // don't try to change class if class is forbidden
                if ((!IsLegalClass(newclass) && !override_mapclasses) || (self.playerclass != newclass && CF_GetClassRestriction(self.team_no, newclass) == -1)) {
                    sprint(self, PRINT_HIGH, "Forbidden class for this team!\n");
                    break;
                }

                TeamFortress_ChangeClass(newclass);
            } else {
                Menu_Class(0);
            }
            break;

        //These only work when alive
        case "dropammo":
            processedCmd = TRUE;
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "You've already dropped all your ammo when you died!\n");
                break;
            }
            if (arg2) {
                if(arg2 == "1" || arg2 == "2" || arg2 == "3" || arg2 == "4") {
                    inp = stof(arg2);
                    farg3 = stof(arg3);
                    if(farg3 < 0) {
                        farg3 = 0;
                    }
                    TeamFortress_DropAmmo(inp, farg3);
                    //Menu_Drop();
                    break;
                }
                sprint(self, PRINT_HIGH, "Invalid choice. Please use values 1-4.\n");
            }
            Menu_Drop();
            break;

        case "disguise":
            processedCmd = TRUE;
            if(self.playerclass != PC_SPY) {
                sprint(self, PRINT_HIGH, "Only spies can disguise!\n");
                break;
            }
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "Can't spy while dead!\n");
                break;
            }
            if (arg2) {
                if(arg2 == "next") {
                    FO_Spy_DisguiseCycle(self, 1);
                    break;
                }
                if(arg2 == "prev") {
                    FO_Spy_DisguiseCycle(self, -1);
                    break;
                }
                if(arg2 == "last") {
                    Menu_Spy_Input(2);
                    break;
                }
                if(arg2 == "none") {
                    Menu_Spy_Input(4);
                    break;
                }
                if(arg2 == "skin") {
                    if(arg3) {
                        Menu_Spy_Skin_Input(stof(arg3));
                    } else {
                        Menu_Spy_Skin();
                    }
                    break;
                }
                if(arg2 == "team") {
                    if(arg3) {
                        //Menu_Spy_Color_Input(stof(arg3));
                        farg3 = stof(arg3);
                        if (farg3 > 0 && farg3 <= number_of_teams)
                            CF_Spy_ChangeColor(self, farg3, TRUE);
                        else
                            Menu_Spy_Input(1);
                        break;
                    } else {
                        Menu_Spy_Color();
                        break;
                    }
                }
                sprint(self, PRINT_HIGH, "Invalid choice. Please use values 'none', 'last', 'skin #' or 'team #'.\n");
            } else {
                Menu_Spy_Input(1);
            }
            break;
        case "menu":
            processedCmd = TRUE;
            if(self.health <= 0 && self.playerclass != PC_SCOUT) {
                sprint(self, PRINT_HIGH, "Menus are for the living!\n");
                break;
            }
            switch(self.playerclass) {
                case PC_SCOUT:
                    Menu_Scout();
                    break;
                case PC_DEMOMAN:
                    if(self.is_detpacking) {
                        Menu_Demoman_Cancel();
                        break;
                    }
                    Menu_Demoman();
                    break;
                case PC_SPY:
                    Menu_Spy(self);
                    break;
                case PC_ENGINEER:
                    Menu_Engineer(self);
                    break;
                default:
                    sprint(self, PRINT_HIGH, "This class doesn't have a menu.\n");
                    break;
            }
            break;
        case "autoscan":
            processedCmd = TRUE;
            if(self.playerclass == PC_SCOUT) {
                ScannerSwitch();
            }
            break;
        case "scansound":
            processedCmd = TRUE;
            if(self.playerclass == PC_SCOUT) {
                //self.impulse = TF_SCAN_SOUND;
                sprint(self, PRINT_HIGH, "Scanner sound: ");
                if (self.tf_items_flags & 4) {
                    self.tf_items_flags = self.tf_items_flags - 4;
                    sprint(self, PRINT_HIGH, "off\n");
                } else {
                    self.tf_items_flags = self.tf_items_flags | 4;
                    sprint(self, PRINT_HIGH, "on\n");
                }
            }
            break;
        case "scanf":
            processedCmd = TRUE;
            if(self.playerclass == PC_SCOUT) {
                //self.impulse = TF_SCAN_FRIENDLY;
                sprint(self, PRINT_HIGH, "Scanning for: ");
                if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
                    self.tf_items_flags = self.tf_items_flags - NIT_SCANNER_FRIENDLY;
                    if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
                        sprint(self, PRINT_HIGH, "Enemies only\n");
                    } else {
                        sprint(self, PRINT_HIGH, "Nothing\n");
                    }
                } else {
                    self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_FRIENDLY;
                    if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
                        sprint(self, PRINT_HIGH, "Friendlies and enemies\n");
                    } else {
                        sprint(self, PRINT_HIGH, "Friendlies only\n");
                    }
                }
                Status_Refresh(self);
            }
            break;
        case "scane":
            processedCmd = TRUE;
            if(self.playerclass == PC_SCOUT) {
                //self.impulse = TF_SCAN_ENEMY;
                sprint(self, PRINT_HIGH, "Scanning for: ");
                if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
                    self.tf_items_flags = self.tf_items_flags - NIT_SCANNER_ENEMY;
                    if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
                        sprint(self, PRINT_HIGH, "Friendlies only\n");
                    } else {
                        sprint(self, PRINT_HIGH, "Nothing\n");
                    }
                } else {
                    self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_ENEMY;
                    if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
                        sprint(self, PRINT_HIGH, "Friendlies and enemies\n");
                    } else {
                        sprint(self, PRINT_HIGH, "Enemies only\n");
                    }
                    Status_Refresh(self);
                }
            }
            break;
        case "detpack":
            processedCmd = TRUE;
            if(self.playerclass != PC_DEMOMAN) {
                sprint(self, PRINT_HIGH, "Only demomen are entrusted with such power!\n");
                break;
            }
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "Can't set detpacks while dead.\n");
                break;
            }
           if (arg2) {
                if(arg2 == "cancel") {
                    TeamFortress_DetpackStop();
                    break;
                }
                if(self.is_detpacking) {
                    TeamFortress_DetpackStop();
//                    Menu_Demoman_Cancel();
                    break;
                }
                local float farg2 = stof(arg2);
                if(farg2) {
                    TeamFortress_SetDetpack(farg2);
                    break;
                }
                sprint(self, PRINT_HIGH, "Invalid choice. Please use integer values 5+.\n");
            } else {
                if(self.is_detpacking) {
                    Menu_Demoman_Cancel();
                    break;
                }
                Menu_Demoman();
            }
            break;
        case "build":
            processedCmd = TRUE;
            if(self.playerclass != PC_ENGINEER) {
                sprint(self, PRINT_HIGH, "You are not qualified to build anything!\n");
                break;
            }
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "Can't build while dead.\n");
                break;
            }
            if (arg2) {
                if(arg2 == "cancel") {
                    TeamFortress_EngineerBuildStop();
                    break;
                }
                if(arg2 == "sentry") {
                    if(self.is_building && !engineer_move) {
                        TeamFortress_EngineerBuildStop();
                        break;
                    }

                    TeamFortress_BuildSentry(stof(arg3));
                    break;
                }
                if(arg2 == "dispenser") {
                    if(self.is_building && !engineer_move) {
                        TeamFortress_EngineerBuildStop();
                        break;
                    }
                    Menu_Engineer_Input(2);
                    break;
                }
                if(arg2 == "destroy" && arg3) {
                    if(arg3 == "sentry") {
                        Menu_Engineer_Input(3);
                        break;
                    }
                    if(arg3 == "dispenser") {
                        Menu_Engineer_Input(4);
                        break;
                    }
                }
                sprint(self, PRINT_HIGH, "Invalid choice.\n");
            } else {
                Menu_Engineer(self);
            }
            break;
        case "sentry":
            processedCmd = TRUE;
            if(self.playerclass != PC_ENGINEER) {
                sprint(self, PRINT_HIGH, "Only engineers can do that!\n");
                break;
            }

            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "Can't maintain while dead.\n");
                break;
            }

            //find sentry first
            ent = findradius(self.origin, ENG_BUILDING_MAINT_DISTANCE);
            while (ent) {
                if (ent.classname == "building_sentrygun") {
                    if (ent.real_owner == self)
                        break;
                }
                ent = ent.chain;
            }

            if (!ent) {
                sprint(self, PRINT_HIGH, "No sentry in range\n");
                break;
            }

            if (arg2 && arg3) {
                if(arg2 == "rotate") {
                    farg3 = stof(arg3);
                    if (!ent.real_owner.has_sentry || ent.real_owner != self
                                || self.classname != "player" || ent == world) {
                        sprint(self, PRINT_HIGH, "Sentry detection issue!\n");
                        break;
                    }
                    ent.angles_y -= farg3;
                    ent.waitmin = rint(ent.angles_y - 50);
                    ent.waitmin = anglemod(ent.waitmin);
                    ent.waitmax = rint(ent.angles_y + 50);
                    ent.waitmax = anglemod(ent.waitmax);
                    if (ent.waitmin > ent.waitmax) {
                        ent.waitmin = ent.waitmax;
                        ent.waitmax = anglemod(ent.angles_y - 50);
                    }
                    ent.nextthink = time + 0.5;
                    break;
                }
                sprint(self, PRINT_HIGH, "Invalid choice.\n");
            } else {
                Menu_EngineerFix_SentryGun_Rotate();
            }
            break;
        case "dispenser":
            processedCmd = TRUE;
            if(self.playerclass != PC_ENGINEER) {
                sprint(self, PRINT_HIGH, "Only engineers can do that!\n");
                break;
            }
            if(self.health <= 0) {
                sprint(self, PRINT_HIGH, "Can't dispense while dead.\n");
                break;
            }
            if (arg2) {
                if(arg2 == "ammo") {
                    Menu_EngineerFix_Dispenser_Input(1);
                    break;
                }
                if(arg2 == "armor") {
                    Menu_EngineerFix_Dispenser_Input(2);
                    break;
                }
                if(arg2 == "repair") {
                    Menu_EngineerFix_Dispenser_Input(3);
                    break;
                }
                if(arg2 == "withdraw" && arg3) {
                    if(arg3 == "ammo") {
                        Menu_Dispenser_Input(1);
                        break;
                    }
                    if(arg3 == "armor") {
                        Menu_Dispenser_Input(2);
                        break;
                    }
                }
            }
            sprint(self, PRINT_HIGH, "Invalid choice. Choices are [ammo|armo[u]r|repair|withdraw ammo|withdraw armo[u]r].\n");
            break;
        case "votemap":
            processedCmd = TRUE;
            if(vote_style) {
                if(arg2) {
                    VoteForMap(self, arg2);
                }
            } else {
                switch(arg2) {
                    case vote1_map:
                        Vote_Input(1);
                        break;
                    case vote2_map:
                        Vote_Input(2);
                        break;
                    case vote3_map:
                        Vote_Input(3);
                        break;
                    case vote4_map:
                        Vote_Input(4);
                        break;
                    case vote5_map:
                        Vote_Input(5);
                        break;
                    default: 
                        Vote_Menu(self);
                        break;
                }
            }
            break;
        case "showvotes":
            processedCmd = TRUE;
            PrintVoting(self);
            break;
        case "listmaps":
        case "maplist":
            processedCmd = TRUE;
            ListVoteMaps(self);
            break;
        case "break":
            processedCmd = TRUE;

            if (disable_voting) {
                // Do nothing
            } else if (self.vote_map) {
                UnvoteForMap(self);
            } else {
                if(votemode) {
                    sprint(self, PRINT_HIGH, "You haven't voted yet!\n");
                } else {
                    VoteToEndMap(self);
                }
            }
            break;
        case "voteyes":
            processedCmd = TRUE;
            VoteYes(self);
            break;
        case "captainpick":
            processedCmd = TRUE;
            if(arg2) {
                farg2 = stof(arg2);
                CaptainPick(self, farg2);
            }
            break;
        case "mapmenu":
            processedCmd = TRUE;
            self.current_menu_page = 1;
            Vote_Menu_Map(0);
            break;
        case "reportmodel":
            processedCmd = TRUE;
            sprint(self, PRINT_HIGH, "Model: ", self.model, " index: ", ftos(self.modelindex), "\n");
            break;
        case "reportloc":
            processedCmd = TRUE;
            sprint(self, PRINT_HIGH, "Origin: ", vtos(self.origin), " OldOrigin: ", vtos(self.oldorigin));
            sprint(self, PRINT_HIGH, " view_ofs: ", vtos(self.view_ofs), "\n");
            break;
        case "tracktarget":
            processedCmd = TRUE;
            FO_SpecTrackPoint(self);
            break;
        case "id":
            processedCmd = TRUE;
            CF_Identify(self, 0);
            break;
        case "showroles":
            processedCmd = TRUE;
            PrintRoleStatus(self);
            PrintRole(self, &Role_None);
            PrintRole(self, &Role_Attack);
            PrintRole(self, &Role_Defence);
            PrintTeamRoles(self);
            break;
        case "help":
        case "list":
            processedCmd = TRUE;
            sprint(self, PRINT_HIGH, "\bUser Commands list:\b\n");
            sprint(self, PRINT_HIGH, "cmd adminpwd <password>\n");
            sprint(self, PRINT_HIGH, "cmd mapmenu\b: menu for changing maps\b\n");
            if(votemode) {
                sprint(self, PRINT_HIGH, "cmd listmaps\b: list votable maps\b\n");
                sprint(self, PRINT_HIGH, "cmd votemap <map>\b: vote for the specified map\b\n");
                sprint(self, PRINT_HIGH, "cmd showvotes\b: List current voting summary\b\n");
                sprint(self, PRINT_HIGH, "cmd break\b: Cancel current vote\b\n");
            } else {
                sprint(self, PRINT_HIGH, "cmd changeteam [#|auto|attack|defence]\n");
                sprint(self, PRINT_HIGH, "cmd changeclass [#]\n");
                sprint(self, PRINT_HIGH, "cmd dropammo [1-4] [amount]\n");
                sprint(self, PRINT_HIGH, "cmd disguise [last|none|skin #|team #]\n");
                sprint(self, PRINT_HIGH, "cmd menu\n");
                sprint(self, PRINT_HIGH, "cmd autoscan\n");
                sprint(self, PRINT_HIGH, "cmd scansound\n");
                sprint(self, PRINT_HIGH, "cmd scanf\n");
                sprint(self, PRINT_HIGH, "cmd scane\n");
                sprint(self, PRINT_HIGH, "cmd detpack [#|cancel]\n");
                sprint(self, PRINT_HIGH, "cmd build [cancel|sentry|dispenser|destroy {sentry|dispenser}]\n");
                sprint(self, PRINT_HIGH, "cmd sentry [rotate #]\n");
                sprint(self, PRINT_HIGH, "cmd dispenser [ammo|armor|repair|withdraw {ammo|armor}]\n");
                sprint(self, PRINT_HIGH, "cmd captainpick #\n");
                sprint(self, PRINT_HIGH, "cmd break\b: end current map\b\n");
            }
            sprint(self, PRINT_HIGH, "cmd help || list (this command)\n");
            sprint(self, PRINT_HIGH, "\n");
            break;
        case "login":
            processedCmd = TRUE;
            if (arg_num == 2) {
                if (self.login != string_null) {
                    sprint (self, PRINT_HIGH, "You are already logged in\n");
                }
                else {
                    performLogin(self,arg2,arg3);
                }
            }
            else {
                sprint (self, PRINT_HIGH, "Missing username/password\n");
            }
            break;
        case "login-silent" :
            processedCmd = TRUE;
            if (arg3 != string_null) {
                performLogin(self,arg2,arg3);
            }
            break;
        case "fo-login":
            processedCmd = TRUE;
            if (self.fo_login != string_null) {
                sprint (self, PRINT_HIGH, "You are logged in\n");
            } else {
                performFoLogin(self, arg2);
            }
            break;
        case "fo-login-silent":
            processedCmd = TRUE;
            if (self.fo_login == string_null)
                performFoLogin(self, arg2);
            break;
        case "who":
            processedCmd = TRUE;
            pl = find (world, classname, "player");
            while (pl) {
                PrintWho(pl);
                pl = find (pl, classname, "player");
            }
            pl = find (world, classname, "observer");
            while (pl) {
                PrintWho(pl);
                pl = find (pl, classname, "observer");
            }
            break;
    }

    if (self.is_admin)
    {
        switch (arg1)
        {
            case "adminmenu":
                processedCmd = TRUE;
                Menu_Close(self);
                self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
                self.current_menu_page = 1;
                Menu_Admin();
                break;
            case "timelimit":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("timelimit ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    tmp = infokey(world, arg1);
                    sprint(self, PRINT_HIGH, "timelimit is ");
                    sprint(self, PRINT_HIGH, "\"");
                    sprint(self, PRINT_HIGH, tmp);
                    sprint(self, PRINT_HIGH, "\"\n");
                }
                break;
            case "prematch":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("prematch ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    tmp = infokey(world, arg1);
                    sprint(self, PRINT_HIGH, "prematch is ");
                    sprint(self, PRINT_HIGH, "\"");
                    sprint(self, PRINT_HIGH, tmp);
                    sprint(self, PRINT_HIGH, "\"\n");
                }
                break;
            case "fraglimit":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("fraglimit ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    tmp = infokey(world, arg1);
                    sprint(self, PRINT_HIGH, "fraglimit is ");
                    sprint(self, PRINT_HIGH, "\"");
                    sprint(self, PRINT_HIGH, tmp);
                    sprint(self, PRINT_HIGH, "\"\n");
                }
                break;
            case "teamplay":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("teamplay ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    tmp = infokey(world, arg1);
                    sprint(self, PRINT_HIGH, "teamplay is ");
                    sprint(self, PRINT_HIGH, "\"");
                    sprint(self, PRINT_HIGH, tmp);
                    sprint(self, PRINT_HIGH, "\"\n");
                }
                break;
            case "password":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("password ");
                    if (arg2 == "none") {
                        bprint(PRINT_HIGH, Q"\n\sServer Password removed!\s\n\n");
                        localcmd("\"\"");
                    } 
                    else {
                        bprint(PRINT_HIGH, Q"\n\sServer Password changed to \"", arg2, "\"\s\n\n");
                        localcmd(arg2);
                    }
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    sprint(self, PRINT_HIGH, "usage: cmd password pwd\n");
                    sprint(self, PRINT_HIGH, "\n");
                }
                break;
            case "record":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("record ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    sprint(self, PRINT_HIGH, "usage: cmd record demo, where demo is the demo name\n");
                    sprint(self, PRINT_HIGH, "\n");
                }
                break;
            case "easyrecord":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("easyrecord ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    localcmd("easyrecord\n");
                }
                break;
            case "autorecord":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    localcmd("localinfo demo_auto_left ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                if (arg_num == 1) {
                    tmp = infokey(world, "demo_auto_left");
                    if (stof(tmp) > 0) {
                        sprint (self, PRINT_HIGH, "Auto-Recording off\n");
                        localcmd ("localinfo demo_auto_left 0\n");
                    }
                    else {
                        sprint(self, PRINT_HIGH, "Auto-Recording the next match\n");
                        localcmd("localinfo demo_auto_left 1\n");
                    }
                }
                break;
            case "cancel":
                localcmd ("cancel\n");
                processedCmd = TRUE;
                break;
            case "stop":
                localcmd ("stop\n");
                processedCmd = TRUE;
                break;
            case "kick":
                processedCmd = TRUE;
                if(arg2) {
                    //make sure it's a number so there's no funny business
                    farg2 = stof(arg2);
                    if(farg2) {
                        localcmd("kick ", ftos(farg2), "\n");
                    }
                } else {
                    Admin_CycleDeal();
                } 
                break;
            case "ban":
                processedCmd = TRUE;
                if(arg2) {
                    //make sure it's a number so there's no funny business
                    farg2 = stof(arg2);
                    if(farg2) {
                        ent = find(world, classname, "player");
                        while(ent) {
                            if(infokeyf(ent, INFOKEY_P_USERID) == farg2) {
                                bprint(PRINT_HIGH, ent.netname, " was banned by ", self.netname, ".\n");
                                localcmd("addip ");
                                localcmd(infokey(ent, INFOKEY_P_IP));
                                localcmd("\n");
                                break;
                            }
                            ent = find(ent, classname, "player");
                        }
                        localcmd("kick ", ftos(farg2), "\n");
                    }
                } else {
                    sprint(self, PRINT_HIGH, "ban requires a userid parameter\n");
                } 
                break;
            case "forcespec":
                processedCmd = TRUE;
                if(arg2) {
                    //make sure it's a number so there's no funny business
                    farg2 = stof(arg2);
                    if(farg2) {
                        ent = find(world, classname, "player");
                        while(ent) {
                            if(infokeyf(ent, INFOKEY_P_USERID) == farg2) {
                                bprint(PRINT_HIGH, ent.netname, " was made spectator by ", self.netname, ". There's probably a good reason for this.\n");
                                clientcommand(ent, "observe");
                                break;
                            }
                            ent = find(ent, classname, "player");
                        }
                    }
                } else {
                    sprint(self, PRINT_HIGH, "forcespec requires a userid parameter\n");
                } 
                break;
            case "ceasefire":
                if (ceasefire_type) 
                    Admin_Pause();
                else
                    Admin_CeaseFire();
                processedCmd = TRUE;
                break;
            case "updateserver":
                Admin_UpdateServer();
                processedCmd = TRUE;
                break;
            case "map":
                processedCmd = TRUE;
                if (arg_num == 2) {
                    bprint(PRINT_HIGH, self.netname);
                    bprint(PRINT_HIGH, " has changed the map to ");
                    bprint(PRINT_HIGH, arg2);
                    bprint(PRINT_HIGH, "\n");
                    nextmap = arg2;
                    if (!clan_scores_dumped) {
                        if (quadmode) {
                            rounds = 1;
                            QuadRoundOver();
                        }
                        DumpClanScores();
                        MapEndSequence();
                        clan_scores_dumped = 1;
                    }
                    localcmd("changelevel ");
                    localcmd(arg2);
                    localcmd("\n");
                }
                else if (arg_num == 1) {
                    sprint (self, PRINT_HIGH, "usage: cmd map mapname, where mapname is the map name you wish to change to\n");
                    sprint (self, PRINT_HIGH, "\n");
                }
                break;
            case "restart":
                processedCmd = TRUE;
                RestartMap();
                break;
            case "randomise":
                processedCmd = TRUE;
                randomizeTeams();
                break;
            case "adminrefresh":
                processedCmd = TRUE;
                Update_ServerAdminInfo(self);
                break;
            case "pubmode":
                processedCmd = TRUE;
                PubMode();
                break;
            case "clanmode":
                processedCmd = TRUE;
                ClanMode();
                break;
            case "quadmode":
                processedCmd = TRUE;
                QuadMode();
                break;
            case "duelmode":
                processedCmd = TRUE;
                DuelMode();
                break;
            case "new_balance":
                processedCmd = TRUE;
                new_balance_mode();
                break;
            case "forcestart":
                processedCmd = TRUE;
                ForceStartMatch();
                break;
            case "rounds":
                processedCmd = TRUE;
                if(arg2) {
                    //make sure it's a number so there's no funny business
                    farg2 = stof(arg2);
                    if(farg2) {
                        SetQuadRounds(farg2);
                    }
                }
                break;
            case "roundtime":
                processedCmd = TRUE;
                if(arg2) {
                    //make sure it's a number so there's no funny business
                    farg2 = stof(arg2);
                    if(farg2) {
                        localcmd ("localinfo round_time ",arg2,"\n");
                        UpdateAllAdmins();
                    }
                }
                break;
            case "fologinrequired":
                processedCmd = TRUE;
                if(arg2) {
                    localcmd ("localinfo fologinrequired ",arg2,"\n");
                    if (stof(arg2)) {
                        bprint(PRINT_HIGH, "Logins will be required. Matches can be reported\n");
                    } else {
                        bprint(PRINT_HIGH, "Allow unregistered players. Matches won't be reported\n");
                    }
                    bprint(PRINT_HIGH, "Map Restart needed to take effect!\n");
                    UpdateAllAdmins();
                }
                break;
            case "fo_matchrated":
                processedCmd = TRUE;
                if(arg2) {
                    localcmd ("localinfo fo_matchrated ",arg2,"\n");

                    switch(stof(arg2)) {
                        case 0:
                            bprint(PRINT_HIGH, "Next match will not be rated\n");
                            break;
                        case 1:
                            bprint(PRINT_HIGH, "Next match will be rated\n");
                            break;
                        case 2:
                            bprint(PRINT_HIGH, "Next match will only be rated if more there are than 2 players on each team\n");
                    }
                    UpdateAllAdmins();
                }
                break;
            case "play_to_completion":
                if(arg2 != "0" && arg2 != "1")
                    break;

                processedCmd = TRUE;
                localcmd ("localinfo play_to_completion ",arg2,"\n");
                UpdateAllAdmins();
                break;
            case "captainmode":
                processedCmd = TRUE;
                if(arg2 && arg3) {
                    farg2 = stof(arg2);
                    farg3 = stof(arg3);
                    if(farg2 && farg3) {
                        CaptainMode(farg2, farg3);
                    } else {
                        sprint(self, PRINT_HIGH, "Captain mode requires 2 userids\n");
                    }
                    break;
                }
                if(arg2 == "stop") {
                    local entity cap1 = findfloat(world, captain, 1);
                    local entity cap2 = findfloat(cap1, captain, 1);
                    StopCaptainMode(cap1, cap2);
                    break;
                }
                Menu_Admin();
                break;
            case "forcebreak":
                processedCmd = TRUE;
                bprint(PRINT_HIGH, "\bMap ended by admin\b ",self.netname,".\n");
                vote_result = FO_GetUserSettingString(world, "vote_map", "votemap", "se2");
                votemode = 2;
                execute_changelevel();
                break;
            case "help":
            case "list":
                processedCmd = TRUE;
                sprint(self, PRINT_HIGH, "\bAdmin Commands list:\b\n");
                sprint(self, PRINT_HIGH, "cmd timelimit\n");
                sprint(self, PRINT_HIGH, "cmd prematch [#]\n");
                sprint(self, PRINT_HIGH, "cmd fraglimit [#]\n");
                sprint(self, PRINT_HIGH, "cmd teamplay [#]\n");
                sprint(self, PRINT_HIGH, "cmd password {<password>|none}\n");
                sprint(self, PRINT_HIGH, "cmd map <map>\n");
                sprint(self, PRINT_HIGH, "cmd record <demoname>\n");
                sprint(self, PRINT_HIGH, "cmd easyrecord [<demoname>]\n");
                sprint(self, PRINT_HIGH, "cmd autorecord [0|1]\n");
                sprint(self, PRINT_HIGH, "cmd cancel\n");
                sprint(self, PRINT_HIGH, "cmd stop\n");
                sprint(self, PRINT_HIGH, "cmd kick [userid]\n");
                sprint(self, PRINT_HIGH, "cmd ban <userid>\n");
                sprint(self, PRINT_HIGH, "cmd forcespec <userid>\n");
                sprint(self, PRINT_HIGH, "cmd ceasefire\n");
                sprint(self, PRINT_HIGH, "cmd restart\n");
                sprint(self, PRINT_HIGH, "cmd randomise\n");
                sprint(self, PRINT_HIGH, "cmd pubmode\n");
                sprint(self, PRINT_HIGH, "cmd clanmode\n");
                sprint(self, PRINT_HIGH, "cmd quaddmode\n");
                sprint(self, PRINT_HIGH, "cmd duelmode\n");
                sprint(self, PRINT_HIGH, "cmd forcestart\n");
                sprint(self, PRINT_HIGH, "cmd rounds #\b: Set number of Quad rounds\b\n");
                sprint(self, PRINT_HIGH, "cmd roundtime #\b: Set Quad round time\b\n");
                sprint(self, PRINT_HIGH, "cmd captainmode {<userid1> <userid2> | stop} \n");
                sprint(self, PRINT_HIGH, "cmd forcebreak\b: End current map\b\n");
                sprint(self, PRINT_HIGH, "\n");
                break;
        }
    }

    return processedCmd;
}

void (string cmd) SV_ParseClientCommand = {
    float isProcessed;
    tokenize(cmd);

    isProcessed = ParseCmds(argv(0), argv(1), argv(2), argv(3));

    if (!isProcessed)
    {
        clientcommand(self, cmd);
    }
}

