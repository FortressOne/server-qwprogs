//=============================================================
// Functions handling all the help displaying for TeamFortress.
//=============================================================

void (float tno) TeamFortress_TeamSetColor;

void (float tno, float scoretoadd) TeamFortress_TeamIncreaseScore;
float (float tno) TeamFortress_TeamGetLives;
float (float tno) TeamFortress_TeamGetMaxPlayers;
string(float tno) TeamFortress_TeamGetColorString;
float (float tno) TeamFortress_TeamGetIllegalClasses;
string(float pc) TeamFortress_GetSkin;

float () TeamFortress_TeamPutPlayerInTeam =
{
    local float i, j;
    local float lowest;
    local float likely_team;

    likely_team = random() * number_of_teams;
    likely_team = ceil(likely_team);
    if (likely_team == 0)
        likely_team = number_of_teams;

    lowest = 33;

    i = 1;
    while (i < (number_of_teams + 1)) {

        j = TeamFortress_TeamGetNoPlayers(i);
        if (j < lowest) {
            if (TeamFortress_TeamGetMaxPlayers(i) > j) {
                lowest = j;
                likely_team = i;
            }
        }
        i = i + 1;
    }
    return (TeamFortress_TeamSet(likely_team));
};

string (float tno) TeamFortress_TeamGetColor = {
    local string color = NOTEAMCOLOR;

    switch (tno) {
        case 1:
            color = BLUETEAMCOLOR;
            break;
        case 2:
            color = REDTEAMCOLOR;
            break;
        case 3:
            color = YELLOWTEAMCOLOR;
            break;
        case 4:
            color = GREENTEAMCOLOR;
            break;
    }

    return color;
};

string TeamFortress_TeamGetColorFor(entity pov, float tno) {
    local string color = NOTEAMCOLOR;

    if (pov.team_no == tno && cvar("teamcolor")) {
        color = cvar_string("teamcolor");
    } else if (pov.team_no != tno && cvar("enemycolor")) {
        color = cvar_string("enemycolor");
    } else {
        switch (tno) {
            case 1:
                color = infokey(pov, "team1color");
                if (color == "" || color == "off")
                    color = BLUETEAMCOLOR;
                break;
            case 2:
                color = infokey(pov, "team2color");
                if (color == "" || color == "off")
                    color = REDTEAMCOLOR;
                break;
            case 3:
                color = infokey(pov, "team3color");
                if (color == "" || color == "off")
                    color = YELLOWTEAMCOLOR;
                break;
            case 4:
                color = infokey(pov, "team4color");
                if (color == "" || color == "off")
                    color = GREENTEAMCOLOR;
                break;
        }
    }

    return color;
}


void (float tno) TeamFortress_TeamSetColor = {
    if (tno == 1) {
        team1col = DARKBLUE;
        return;
    }
    if (tno == 2) {
        team2col = RED;
        return;
    }
    if (tno == 3) {
        team3col = YELLOW;
        return;
    }
    if (tno == 4) {
        team4col = DARKGREEN;
        return;
    }
};

string(float tno) GetTeamName =
{
    local string st;

    if (tno == 1) {
        st = infokey(world, "team1");
        if (st == string_null)
            st = infokey(world, "t1");
        if ((st == string_null) || (st == ""))
            return ("blue");
    } else if (tno == 2) {
        st = infokey(world, "team2");
        if (st == string_null)
            st = infokey(world, "t2");
        if ((st == string_null) || (st == ""))
            return ("red");
    } else if (tno == 3) {
        st = infokey(world, "team3");
        if (st == string_null)
            st = infokey(world, "t3");
        if ((st == string_null) || (st == ""))
            return ("yell");
    } else if (tno == 4) {
        st = infokey(world, "team4");
        if (st == string_null)
            st = infokey(world, "t4");
        if ((st == string_null) || (st == ""))
            return ("gren");
    } else {
        st = "\"\"";
    }
    return (st);
};

void (entity p) SetTeamName = {
    local string st;

    stuffcmd(p, "team ");
    st = GetTeamName(p.team_no);
    stuffcmd(p, st);
    stuffcmd(p, "\n");
};

float (float tno) CF_TeamIsValid = {
    local float tc;
    local string team, st;

    if (tno == 1)
        team = "blue team";
    else if (tno == 2)
        team = "red team";
    else if (tno == 3)
        team = "yellow team";
    else
        team = "green team";

    if (teamplay < 1) {
        sprint(self, PRINT_HIGH,
               "Teamplay is not on, so teams are inactive\n");
        return 0;
    }

    if ((tno > number_of_teams) && (number_of_teams != 0)) {
        sprint(self, PRINT_HIGH, "There can be only ");
        st = ftos(number_of_teams);
        sprint(self, PRINT_HIGH, st, " teams on this map\n");
        return 0;
    }

    if (self.team_no == tno) {
        sprint(self, PRINT_HIGH, "You're already in the ");
        sprint(self, PRINT_HIGH, team, "\n");
        return 0;
    }

    tc = TeamFortress_TeamGetNoPlayers(tno);
    if (tc >= TeamFortress_TeamGetMaxPlayers(tno)) {
        sprint(self, PRINT_HIGH, "That team is full, pick another\n");
        return 0;
    }

    return 1;
}

float (entity pe, float tno, float skipclasscheck) TeamFortress_TeamSet_Options = {
    local string st;
    local string team;

    if ((intermission_running != 0) || (intermission_exittime > time))
        return (0);

    if (!CF_TeamIsValid) {
        return 0;
    }

    if (tno == 1)
        team = "blue team";
    else if (tno == 2)
        team = "red team";
    else if (tno == 3)
        team = "yellow team";
    else
        team = "green team";

    if (tno > 0 && tno == pe.team_no) {
        sprint(pe, PRINT_HIGH, "You are already on the ", team, "!\n");
        return 0;
    }

    if (!pe.deadflag) {
        if (pe.health == pe.max_health && (pe.spawn_time + 10) > time && CloseToSpawnPoint() && pe.suicide_time <= time) {
            pe.has_changedteam = 1;
            pe.clientkillforce = 1;
            pe.clientkillfree = 1;
            ClientKill();
            pe.has_changedteam = 0;
        } else
        {
            pe.clientkillforce = 1;
            pe.clientkillfree = 0; 
            ClientKill();  
        }
    }
    // remove engineer buildings
    if (pe.playerclass == PC_ENGINEER)
        Engineer_RemoveBuildings(pe);
    // swap colors for spy last disguise
    if (pe.playerclass == PC_SPY && pe.undercover_team == tno)
        pe.last_team = pe.team_no;
    // remove existing gas grenades
    RemoveGasTimers();
    bprint(PRINT_HIGH, pe.netname, " has joined the ");
    bprint(PRINT_HIGH, team, "\n");
    stuffcmd(pe, "color ");
    st = TeamFortress_TeamGetColor(tno);
    stuffcmd(pe, st);
    stuffcmd(pe, "\n");

    if(!skipclasscheck) {
        if(pe.playerclass == PC_CIVILIAN) {
            if (TeamFortress_TeamIsCivilian(tno)) {
                pe.team_no = tno;
                TeamFortress_ChangeClass(11);
            } else {
                TeamFortress_ChangeClass(0);
                Menu_Class(0);
            }
        } else {
            if (pe.playerclass == 0) {
            } else {
                //Make sure the current class is still legal on the new team
                override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
                if (CF_GetClassRestriction(tno, self.playerclass) == -1 || CF_ClassIsRestricted(tno, self.playerclass)) {
                    TeamFortress_ChangeClass(0);
                    Menu_Class(0);
                }

            }
        }
    }
    pe.team_no = tno;
    pe.immune_to_check = time + 10;
    pe.lives = TeamFortress_TeamGetLives(tno);
    if ((toggleflags & TFLAG_TEAMFRAGS) ||
        (toggleflags & TFLAG_FULLTEAMSCORE)) {
        pe.frags = TeamFortress_TeamGetScore(tno);
    }
    TeamFortress_TeamShowMemberClasses(pe);
    SetTeamName(pe);

    if(!skipclasscheck) {
        if (pe.playerclass == 0) {
            if (TeamFortress_TeamIsCivilian(tno)) {
                pe.team_no = tno;
                TeamFortress_ChangeClass(11);
            }
        } else {
            // force to change class if class is forbidden on the new team
            if (!IsLegalClass(pe.playerclass) && !override_mapclasses) {
                TeamFortress_ChangeClass(0);
                Menu_Class(0);
            }
        }
    }

    forceinfokey(pe, "team_no", ftos(tno));
    UpdateReadyStatus();
    return (1);
};

float (float tno) TeamFortress_TeamSet = {
    if (quadmode && tno >= 1 && tno <= 4 && !self.fo_login && fo_login_required) {
        sprint(self, PRINT_HIGH, "You need to sign in first. Get your login token at www.fortressone.org\n");
        return 0;
    }

    local float tftso = TeamFortress_TeamSet_Options(self, tno, FALSE);

    SetDimensions(TRUE);
    UpdateAllClientsTeamScores();
    UpdateReadyStatus();
    return (tftso);
}

void (entity player) TeamFortress_CheckTeamCheats = {
    local string st;
    local string sk;

    if (player.immune_to_check > time)
        return;
    if (player.deadflag)
        return;

    if (player.netname == string_null) {
        KickCheater(player);
    } else {
        if (((player.playerclass != 0) && (player.team_no == 0)) &&
            (teamplay > 0)) {
            KickCheater(player);
        }
    }
    if ((player.team_no > 0) && (teamplay > 0)) {
        st = infokey(player, "bottomcolor");
        if (st != TeamFortress_TeamGetColor(player.team_no)) {
            bprint(PRINT_HIGH, sprintf("%s's bottomcolor is wrong\n", player.netname));
            bprint(PRINT_HIGH, sprintf("setinfo: %s\n", st));
            bprint(PRINT_HIGH, sprintf("TF_TGC: %s\n", TeamFortress_TeamGetColor(player.team_no)));
            TeamFortress_SetSkin(player);
        }
        if (player.playerclass != 0) {
            st = infokey(player, "skin");
            sk = TeamFortress_GetSkin(player.playerclass);
            if (st != sk) {
                TeamFortress_SetSkin(player);
                bprint(PRINT_MEDIUM, player.netname,
                        " has been kicked for changing skin\n");
                sprint(player, PRINT_HIGH,
                       "You have been kicked for changing your skin\n");
                KickCheater(player);
            }
        }
        st = GetTeamName(player.team_no);
        if (st != infokey(player, "team")) {
            SetTeamName(player);
            bprint(PRINT_MEDIUM, player.netname,
                    " has been kicked for changing team\n");
            sprint(player, PRINT_HIGH,
                   "You have been kicked for changing your team\n");
            KickCheater(player);
            return;
        }
    }
};

void (float tno, float scoretoadd) TeamFortress_TeamIncreaseScore = {
    local entity e;

    if ((tno == 0) || (scoretoadd == 0))
        return;

    if (tno == 1)
        team1score = team1score + scoretoadd;

    if (tno == 2)
        team2score = team2score + scoretoadd;

    if (tno == 3)
        team3score = team3score + scoretoadd;

    if (tno == 4)
        team4score = team4score + scoretoadd;

    if ((tno == 1) || (tno == 2) || (tno == 3) || (tno == 4)) {
        UpdateAllClientsTeamScores();
    }

    if ((toggleflags & TFLAG_TEAMFRAGS) || (toggleflags & TFLAG_FULLTEAMSCORE)) {
        e = find(world, classname, "player");
        while (e) {
            if (e.team_no == tno)
                e.frags = TeamFortress_TeamGetScore(tno);

            e = find(e, classname, "player");
        }
    }
};

float (float tno) TeamFortress_TeamGetScore = {
    if (tno == 1)
        return (team1score);
    if (tno == 2)
        return (team2score);
    if (tno == 3)
        return (team3score);
    if (tno == 4)
        return (team4score);
    return (0);
};

float (float tno) TeamFortress_TeamGetScoreFrags = {
    if ((toggleflags & TFLAG_TEAMFRAGS) ||
        (toggleflags & TFLAG_FULLTEAMSCORE)) {
        if (tno == 1) {
            return (team1score);
        }
        if (tno == 2) {
            return (team2score);
        }
        if (tno == 3) {
            return (team3score);
        }
        if (tno == 4) {
            return (team4score);
        }
    } else {
        if (tno == 1) {
            return (team1frags);
        }
        if (tno == 2) {
            return (team2frags);
        }
        if (tno == 3) {
            return (team3frags);
        }
        if (tno == 4) {
            return (team4frags);
        }
    }
    return (0);
};

float (float tno) TeamFortress_TeamGetLives = {
    if (tno == 1)
        return (team1lives);
    if (tno == 2)
        return (team2lives);
    if (tno == 3)
        return (team3lives);
    if (tno == 4)
        return (team4lives);
    return (0);
};

float (float tno) TeamFortress_TeamGetNoPlayers = {
    local entity search;
    local string cn = tno == 0 ? "observer" : "player";
    local float size_team = 0;

    search = find(world, classname, cn);
    while (search != world) {
        if (search.team_no == tno)
            size_team = size_team + 1;
        search = find(search, classname, cn);
    }

    return (size_team);
};

float (float tno) TeamFortress_TeamGetNoPlayersExcludingAllTime = {
    local entity search;
    local string cn = tno == 0 ? "observer" : "player";
    local float size_team = 0;

    search = find(world, classname, cn);
    while (search != world) {
        if (search.team_no == tno && search.all_time == ALL_TIME_COLOUR)
            size_team = size_team + 1;
        search = find(search, classname, cn);
    }

    return (size_team);
};

float (float pc, float tno) TeamFortress_ClassGetNoPlayers = {
    local float class_count;
    local entity search;
    class_count = 0;

    search = find(world, classname, "player");
    while (search != world) {
        if (search.playerclass == pc && search.team_no == tno)
            class_count = class_count + 1;
        search = find(search, classname, "player");
    }
    return (class_count);
};

string (float pc, float tno) TeamFortress_ClassGetNoPlayersString = {
    local float class_count;

    class_count = TeamFortress_ClassGetNoPlayers(pc, tno);
    if (class_count == 1)
        return "1 player ";

    return strcat(ftos(class_count), " players");
};

float () TeamFortress_GetNoPlayers = {
    local float nump;
    local entity search;
    nump = 0;

    search = find(world, classname, "player");
    while (search != world) {
        if (search.netname != string_null)
            nump = nump + 1;
        search = find(search, classname, "player");
    }
    return (nump);
};

float () TeamFortress_GetNoActivePlayers = {
    local float nump;
    local entity search;
    nump = 0;

    search = find(world, classname, "player");
    while (search != world) {
        if (search.netname != string_null
                && search.team_no
                && search.playerclass
                && !search.has_disconnected) {
            nump = nump + 1;
        }

        search = find(search, classname, "player");
    }
    return (nump);
};

float (float tno) TeamFortress_TeamGetMaxPlayers = {
    if (tno == 1)
        return (team1maxplayers);
    if (tno == 2)
        return (team2maxplayers);
    if (tno == 3)
        return (team3maxplayers);
    if (tno == 4)
        return (team4maxplayers);
    return (0);
};

float () TeamFortress_TeamGetWinner = {
    local float i;
    local float j;
    local float highest;
    local float highestteam;

    highest = 0;
    highestteam = 0;

    i = 1;
    while (i < (number_of_teams + 1)) {
        j = TeamFortress_TeamGetScoreFrags(i);
        if (j > highest) {
            highest = j;
            highestteam = i;
        }
        i = i + 1;
    }
    return (highestteam);
};

float () TeamFortress_TeamGetSecond = {
    local float i, j;
    local float highest;
    local float highestteam;
    local float secondteam;
    local float second;

    highestteam = TeamFortress_TeamGetWinner();
    highest = TeamFortress_TeamGetScoreFrags(highestteam);
    secondteam = 0;
    second = 0;

    i = 1;
    while (i < (number_of_teams + 1)) {
        j = TeamFortress_TeamGetScoreFrags(i);
        if ((j < highest) && (j > second)) {
            second = j;
            secondteam = i;
        }
        i = i + 1;
    }
    return (secondteam);
};

void (float all) TeamFortress_TeamShowScores = {
    local string st;
    local float i;
    local float j;

    i = 1;
    if (all == 2) {
        while (i <= number_of_teams) {
            if (TeamFortress_TeamGetColor(i) != NOTEAMCOLOR) {
                j = TeamFortress_TeamGetScore(i);
                st = TeamFortress_TeamGetColorString(i);
                bprint(PRINT_HIGH, st, ": ");
                st = ftos(j);
                bprint(PRINT_HIGH, st, " ");
            }
            i = i + 1;
        }
        bprint(PRINT_HIGH, "\n");
        return;
    }
    while (i <= number_of_teams) {
        if (TeamFortress_TeamGetColor(i) != NOTEAMCOLOR) {
            if (all) {
                bprint(PRINT_HIGH, "Team ");
            } else {
                sprint(self, PRINT_HIGH, "Team ");
            }
            st = ftos(i);
            if (all) {
                bprint(PRINT_HIGH, st);
            } else {
                sprint(self, PRINT_HIGH, st);
            }
            if (all) {
                bprint(PRINT_HIGH, " (");
            } else {
                sprint(self, PRINT_HIGH, " (");
            }
            st = TeamFortress_TeamGetColorString(i);
            if (all) {
                bprint(PRINT_HIGH, st);
            } else {
                sprint(self, PRINT_HIGH, st);
            }
            if (all) {
                bprint(PRINT_HIGH, ") : ");
            } else {
                sprint(self, PRINT_HIGH, ") : ");
            }
            j = TeamFortress_TeamGetScore(i);
            st = ftos(j);
            if (all) {
                bprint(PRINT_HIGH, st);
            } else {
                sprint(self, PRINT_HIGH, st);
            }
            if (all) {
                bprint(PRINT_HIGH, "\n");
            } else {
                sprint(self, PRINT_HIGH, "\n");
            }
        }
        i = i + 1;
    }
};

string(float tno) TeamFortress_TeamGetColorString = {
    local string colour = "White";

    switch(tno) {
        case 1:
            colour = "Blue";
            break;
        case 2:
            colour = "Red";
            break;
        case 3:
            colour = "Yellow";
            break;
        case 4:
            colour = "Green";
            break;
    }

    return colour;
};

void (entity Player) TeamFortress_TeamShowMemberClasses = {
    local entity e;
    local float found;

    found = FALSE;
    e = find(world, classname, "player");
    while (e) {
        if (((e.team_no == Player.team_no) || (e.team_no == 0)) &&
            (e != Player)) {
            if (e.model != string_null) {
                if (!found) {
                    found = TRUE;
                    sprint(self, PRINT_HIGH,
                           "The other members of your team are:\n");
                }
                sprint(Player, PRINT_HIGH, e.netname, " : ");
                TeamFortress_PrintClassName(Player, e.playerclass,
                                            e.tfstate & 8);
            }
        }
        e = find(e, classname, "player");
    }
    if (!found)
        sprint(Player, PRINT_HIGH,
               "There are no other players on your team\n");
};

void () CalculateTeamEqualiser = {
    local float t1;
    local float t2;
    local float t3;
    local float t4;
    local float t_ave;
    local float calc;

    team1advantage = 1;
    team2advantage = 1;
    team3advantage = 1;
    team4advantage = 1;
    if (number_of_teams < 2) {
        self.nextthink = time + 60;
        return;
    }
    if (teamplay & 32) {
        t1 = TeamFortress_TeamGetNoPlayers(1);
        t2 = TeamFortress_TeamGetNoPlayers(2);
        t3 = TeamFortress_TeamGetNoPlayers(3);
        t4 = TeamFortress_TeamGetNoPlayers(4);
        if ((((t1 + t2) + t3) + t4) < 1) {
            self.nextthink = time + 30;
            return;
        }
        t_ave = (((t1 + t2) + t3) + t4) / number_of_teams;
        if (t1 > 0) {
            calc = (t_ave / t1) - 1;
            if (calc != 0) {
                calc = (calc / 3) + 1;
            } else {
                calc = calc + 1;
            }
            team1advantage = calc;
        }
        if ((t2 > 0) && (number_of_teams >= 2)) {
            calc = (t_ave / t2) - 1;
            if (calc != 0) {
                calc = (calc / 3) + 1;
            } else {
                calc = calc + 1;
            }
            team2advantage = calc;
        }
        if ((t3 > 0) && (number_of_teams >= 3)) {
            calc = (t_ave / t3) - 1;
            if (calc != 0) {
                calc = (calc / 3) + 1;
            } else {
                calc = calc + 1;
            }
            team3advantage = calc;
        }
        if ((t4 > 0) && (number_of_teams >= 4)) {
            calc = (t_ave / t4) - 1;
            if (calc != 0) {
                calc = (calc / 3) + 1;
            } else {
                calc = calc + 1;
            }
            team4advantage = calc;
        }
    }
    if (teamplay & 64) {
        t1 = team1score + 60;
        if (number_of_teams >= 2) {
            t2 = team2score + 60;
        } else {
            t2 = 0;
        }
        if (number_of_teams >= 3) {
            t3 = team3score + 60;
        } else {
            t3 = 0;
        }
        if (number_of_teams >= 4) {
            t4 = team4score + 60;
        } else {
            t4 = 0;
        }
        t_ave = ((t2 + t3) + t4) / (number_of_teams - 1);
        calc = (t_ave / t1) - 1;
        if (calc != 0) {
            calc = (calc / 3) + 1;
        } else {
            calc = calc + 1;
        }
        team1advantage = calc * team1advantage;
        if (number_of_teams >= 2) {
            t_ave = ((t1 + t3) + t4) / (number_of_teams - 1);
            calc = (t_ave / t2) - 1;
            if (calc != 0) {
                calc = (calc / 3) + 1;
            } else {
                calc = calc + 1;
            }
            team2advantage = calc * team2advantage;
        }
        if (number_of_teams >= 3) {
            t_ave = ((t2 + t1) + t4) / (number_of_teams - 1);
            calc = (t_ave / t3) - 1;
            if (calc != 0) {
                calc = (calc / 3) + 1;
            } else {
                calc = calc + 1;
            }
            team3advantage = calc * team3advantage;
        }
        if (number_of_teams >= 4) {
            t_ave = ((t2 + t3) + t1) / (number_of_teams - 1);
            calc = (t_ave / t4) - 1;
            if (calc != 0) {
                calc = (calc / 3) + 1;
            } else {
                calc = calc + 1;
            }
            team4advantage = calc * team4advantage;
        }
    }
    self.nextthink = time + 10;
};

void () SetupTeamEqualiser = {
    local entity TE;

    team1advantage = 1;
    team2advantage = 1;
    team3advantage = 1;
    team4advantage = 1;

    if (!(teamplay & (32 | 64)))
        return;

    TE = spawn();
    TE.classname = "Team Equaliser";
    TE.think = CalculateTeamEqualiser;
    TE.nextthink = time + 30;
};

float (entity targ, entity attacker, float damage) TeamEqualiseDamage = {
    local float adv;
    local float newdam;
    adv = 0;

    if ((targ.classname != "player") || (attacker.classname != "player")) {
        return (damage);
    }
    if (((targ.team_no == 0) || (attacker.team_no == 0)) ||
        (attacker.team_no == targ.team_no)) {
        return (damage);
    }
    if (attacker.team_no == 1) {
        adv = team1advantage;
    } else {
        if (attacker.team_no == 2) {
            adv = team2advantage;
        } else {
            if (attacker.team_no == 3) {
                adv = team3advantage;
            } else {
                if (attacker.team_no == 4) {
                    adv = team4advantage;
                }
            }
        }
    }
    if (adv == 0) {
        dprint("There is a team with an advantage of 0\n");
        adv = 0.100;
    }
    newdam = damage * adv;
    if (targ.team_no == 1) {
        adv = team1advantage;
    } else {
        if (targ.team_no == 2) {
            adv = team2advantage;
        } else {
            if (targ.team_no == 3) {
                adv = team3advantage;
            } else {
                if (targ.team_no == 4) {
                    adv = team4advantage;
                }
            }
        }
    }
    if (adv == 0) {
        dprint("There is a team with an advantage of 0\n");
        adv = 0.100;
    }
    newdam = newdam * (1 / adv);
    return (newdam);
};

void () TeamFortress_StatusQuery = {
    local float ft;
    local string st;

    sprint(self, PRINT_HIGH, "players per team: ");
    ft = TeamFortress_TeamGetNoPlayers(1);
    st = ftos(ft);
    sprint(self, PRINT_HIGH, st, "  ");
    ft = TeamFortress_TeamGetNoPlayers(2);
    st = ftos(ft);
    sprint(self, PRINT_HIGH, st, "  ");
    ft = TeamFortress_TeamGetNoPlayers(3);
    st = ftos(ft);
    sprint(self, PRINT_HIGH, st, "  ");
    ft = TeamFortress_TeamGetNoPlayers(4);
    st = ftos(ft);
    sprint(self, PRINT_HIGH, st, "\n    equalisation: ");
    st = ftos(team1advantage);
    sprint(self, PRINT_HIGH, st, "  ");
    st = ftos(team2advantage);
    sprint(self, PRINT_HIGH, st, "  ");
    st = ftos(team3advantage);
    sprint(self, PRINT_HIGH, st, "  ");
    st = ftos(team4advantage);
    sprint(self, PRINT_HIGH, st, "\n");
    st = ftos(teamplay);
    sprint(self, PRINT_HIGH, "Teamplay is ", st, "\n");
};

float (float tno) TeamFortress_TeamGetIllegalClasses = {
    if (tno == 1)
        return (illegalclasses1);
    if (tno == 2)
        return (illegalclasses2);
    if (tno == 3)
        return (illegalclasses3);
    if (tno == 4)
        return (illegalclasses4);
    return (0);
};

float (float tno) TeamFortress_TeamIsCivilian = {
    if (tno == 1) {
        if (civilianteams & 1)
            return (1);
    } else if (tno == 2) {
        if (civilianteams & 2)
            return (1);
    } else if (tno == 3) {
        if (civilianteams & 4)
            return (1);
    } else if (civilianteams & 8)
        return (1);

    return (0);
};

float (float pf_team_no, float pf_class) CF_GetClassRestriction = {
    local float f_max = 0, f_players = TeamFortress_TeamGetNoPlayers(pf_team_no);
    //local string s_string;
    Team_Role * role = GetTeamRole(pf_team_no);

    // set maximum number based on settings
/*
    if (pf_class == PC_SCOUT) {
        s_string = infokey(world, "cr_scout");
        f_max = stof(s_string);
    } else if (pf_class == PC_SNIPER) {
        s_string = infokey(world, "cr_sniper");
        f_max = stof(s_string);
    } else if (pf_class == PC_SOLDIER) {
        s_string = infokey(world, "cr_soldier");
        f_max = stof(s_string);
    } else if (pf_class == PC_DEMOMAN) {
        s_string = infokey(world, "cr_demoman");
        f_max = stof(s_string);
    } else if (pf_class == PC_MEDIC) {
        s_string = infokey(world, "cr_medic");
        f_max = stof(s_string);
    } else if (pf_class == PC_HVYWEAP) {
        s_string = infokey(world, "cr_hwguy");
        f_max = stof(s_string);
    } else if (pf_class == PC_PYRO) {
        s_string = infokey(world, "cr_pyro");
        f_max = stof(s_string);
    } else if (pf_class == PC_SPY) {
        if (spy_off)
            return -1;
        s_string = infokey(world, "cr_spy");
        f_max = stof(s_string);
    } else if (pf_class == PC_ENGINEER) {
        s_string = infokey(world, "cr_engineer");
        f_max = stof(s_string);
    } else if (pf_class == PC_RANDOM) {
        s_string = infokey(world, "cr_randompc");
        f_max = stof(s_string);
    }
*/
    if (pf_class == PC_SPY && spy_off) return -1;
        
    f_max = rint(role.class_limits[pf_class]);
    if (f_max == 0 || f_players < f_max)
        return f_players;

    return f_max;
};

float (float pf_team_no, float pf_class) CF_GetClassPlayers = {
    local float f_playing = 0;
    local entity e_find;

    if (!pf_team_no)
        return 0;

    // get amount of players currently playing
    e_find = find(world, classname, "player");
    while (e_find) {
        if (e_find.team_no == pf_team_no) {
            if (pf_class == PC_RANDOM) {
                if (e_find.tfstate & TFSTATE_RANDOMPC)
                    f_playing = f_playing + 1;
            } else if (e_find.playerclass == pf_class || e_find.nextpc == pf_class) {
                if (!(e_find.tfstate & TFSTATE_RANDOMPC))
                    f_playing = f_playing + 1;
            }
        }
        e_find = find(e_find, classname, "player");
    }

    return f_playing;

};

float (float pf_team_no, float pf_class) CF_ClassIsRestricted = {
    local float f_playing, f_max;

    if (!pf_team_no)
        return 0;

    f_max = CF_GetClassRestriction(pf_team_no, pf_class);
    f_playing = CF_GetClassPlayers(pf_team_no, pf_class);

    if ((f_max > 0 && f_playing >= f_max) || f_max == -1)
        return 1;

    return 0;
};

void (float tno, entity ignore, string st) teamsprint = {
    local entity te;

    if (tno == 0)
        return;

    te = find(world, classname, "player");
    while (te) {
        if ((te.team_no == tno) && (te != ignore))
            sprint(te, PRINT_HIGH, st);

        te = find(te, classname, "player");
    }
};
