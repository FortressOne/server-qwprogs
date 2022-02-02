void () ReturnItem;

void () MatchThink =
{
    local string tmp;

    if (self.cnt == -1) {
        return;
    }
    if (cease_fire) {
        self.nextthink = (time + 1);
        return;
    }
    self.cnt2 = (self.cnt2 - 1);
    if (!TeamFortress_GetNoPlayers()) {
        NextLevel();
        return;
    }

    if (self.cnt2 == 1) {
        localcmd("serverinfo status \"");
        tmp = ftos(self.cnt);
        localcmd(tmp);
        localcmd(" min left\"\n");
    }

    if (self.cnt2 == -1) {
        self.cnt2 = 59;
        self.cnt = (self.cnt - 1);
    }
    if (!self.cnt2) {
        if (self.cnt == 1 || self.cnt == 5)         {
            tmp = ftos (self.cnt);
            bprint3(2, Q"\s[\s", tmp, "\s]\s minute");
            if (self.cnt != 1) {
                bprint(2, "s");
            }
            bprint(2, " remaining\n");
        }
        if (!self.cnt) {
            self.think = SUB_Remove;
            self.nextthink = (time + 0.1);
            NextLevel();
            return;
        }
    }
    if (!self.cnt && (((self.cnt2 == 30) || (self.cnt2 == 15)) || (self.cnt2 <= 10))) {
        tmp = ftos(self.cnt2);
        bprint3(2, Q"\s[\s", tmp, "\s]\s second");
        if (self.cnt2 != 1) {
            bprint(2, "s");
        }
        bprint(2, " remaining\n");
    }
    gametime++;
    self.nextthink = (time + 1);
};

void () StartMatch =
{
    local string st;
    local entity te;
    local entity oldself;
    local entity gren;

    lightstyle(0, "m");
    bprint(2, "MATCH BEGINS NOW\n");

    team4score = 0;
    team3score = 0;
    team2score = 0;
    team1score = 0;
    team4frags = 0;
    team3frags = 0;
    team2frags = 0;
    team1frags = 0;
    gren = find(world, classname, "grenade");
    while (gren)
    {
        gren.think = GrenadeExplode;
        gren.nextthink = (time + 0.1);
        gren = find(gren, classname, "grenade");
    }
	te = find(world, classname, "detpack");
	while (te){
		if (te.weaponmode == 1) {
			TeamFortress_SetSpeed (te.enemy);
			dremove(te.oldenemy);
			dremove(te.observer_list);
		}
		dremove(te.linked_list);
		dremove(te);
		te = find (te, classname, "detpack");
	}
	if(duelmode && duel_no_packs) {
        //Hide all packs
        te = find(world, classname, "info_tfgoal");
        while (te){
            if (te.mdl) {
                setmodel(te, string_null);
            }
            te = find (te, classname, "info_tfgoal");
        }
    }
    cb_prematch = 0;
    cease_fire = 0;

    te = find(world, classname, "player");
    while (te) {
        oldself = self;
        self = te;

        TeamFortress_RemoveTimers();
        self.frags = 0;
        self.real_frags = 0;
        setspawnparms(self);
        if (!quadmode)
            PutClientInServer();
        if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
            UpdateClientPrematch(self, TRUE);
        }
        self = oldself;
        te = find(te, classname, "player");
    }
    te = find(world, classname, "observer");
    while (te) {
        if(infokeyf(te, INFOKEY_P_CSQCACTIVE)) {
            UpdateClientPrematch(te, TRUE);
        }
        te = find(te, classname, "observer");
    }

    te = find(world, classname, "prematch");
    te.classname = "match";
    te.cnt = (timelimit / 60);
    te.cnt2 = 60;
    if (te.cnt == 0)
    {
        bprint(2, "Warning no timelimit set!\n");
        localcmd("\nserverinfo status \"0 min left\"\n");
        te.cnt = -1;
        te.cnt2 = -1;
    }
    else
    {
        te.cnt = (te.cnt - 1);
        localcmd("\nserverinfo status \"");
        st = ftos(te.cnt);
        localcmd(st);
        localcmd(" min left\"\n");
        if (!quadmode) {
            te.think = MatchThink;
            te.nextthink = (time + 1);
        }
    }

    if (quadmode) {
        if (rounds) {
            StartQuadRound();
        }
    }
    if (duelmode) {
        //ResetPlayers();
        CountMatchPlayersAndReset();
    }
};

float () GetPlayerCount
{
    local entity te;
    local float tmp = 0;
    te = find (world, classname, "player");
    while (te != world) {
        if (te.playerclass) {
            tmp = tmp + 1;
        }
        te = find (te, classname, "player");
    }
    return tmp;
}

string () GetPlayersName
{
    local entity te;
    local float tmp = 0;
    local float tmp2 = 0;
    local string st = "";
    local string plname;

    while (tmp < number_of_teams) {
        tmp = tmp + 1;
        tmp2 = 0;
        te = find (world, classname, "player");
        while (te != world) {
            if (te.team_no == tmp && te.playerclass) {
                tmp2 = 1;
                if (loginRequired)
                    plname = te.login;
                else
                    plname = te.netname;
                st = strcat (st, "_");
                if (strlen(plname) <= 13) {
                    st = strcat( st, plname );
                } else {
                    st = strcat( st, substr(plname,0,12));
                }
            }
            te = find (te, classname, "player");
        }
        if (tmp2 == 1 && tmp != number_of_teams) {
            st = strcat ( st, "_VS");
        }
    }
        return (st);
};

string () GetGameFileName = {
    local float i;
    local string tmp;
    local entity t;
    local string str;

    str = "";
    i = 0;
    t = find (world, classname, "prematch");
    if (t != world)
    {       
        calltimeofday ();
        str = strcat(str, tod_year); // year
        str = strcat(str, "-");
        str = strcat(str, tod_mon); // month
        str = strcat(str, "-");          
        str = strcat(str, tod_day); // day        
        str = strcat(str, "_");        
        str = strcat(str, tod_hour); // hour
        str = strcat(str, "-");
        str = strcat(str, tod_min); // minute
        str = strcat(str, "-");
        str = strcat(str, tod_sec); // second
    }
    str = strcat(str, "_[");
    str = strcat(str, mapname);
    str = strcat(str, "]_");

    while ((i < number_of_teams))
    {
        i = (i + 1);
        tmp = GetTeamName (i);
        str = strcat(str,"_");
        str = strcat(str,tmp);
        if ((i < number_of_teams))
        {
            str = strcat(str, "_vs");
        }
    }
    str = clearString(str);
    return str;
}

void () PreMatch_Think = {
    local entity p;
    local string num, tmp, str;
    local float fl;

    self.cnt2 = (self.cnt2 - 1);
    if (self.cnt2 == 1) {
        p = find(world, classname, "player");
        while (p != world) {
            if (p.netname != "" && p.team_no && p.playerclass) {
                p.respawn_time = (time + 2);
                p.takedamage = 0;
                p.solid = 0;
                p.movetype = 0;
                p.modelindex = 0;
                p.model = string_null;
            }
            p = find(p, classname, "player");
        }
    }
    else {
        if (!self.cnt2) {
            is_countdown = 0;
            self.nextthink = (time + 0.1);
            self.think = SUB_Remove;
            gametime = 0;
            canlog = 1;
            LogEventGameStart();
            p = find(world, classname, "player");
            while (p != world) {
                if (p.netname != "" && p.team_no && p.playerclass) {
                    p.takedamage = 2;
                    p.solid = 3;
                    p.movetype = 3;
                }
                p.classtime = gametime;
                LogEventPlayerStart(p);
                p = find(p, classname, "player");
            }
            if (!quadmode)
                StartMatch();
            else {
                StartQuadRound();
            }
            return;
        }
    }
    fl = (self.cnt2 / 60);
    if (fl == 1 || fl == 2 || fl == 3 || fl == 4 || fl == 5 || fl == 6 || fl == 7 || fl == 8 || fl == 9 || fl == 10) {
        num = ftos(fl);
        bprint3(2, "Match will begin in ", num, " minute(s).\n");
    }
    if (self.cnt2 == 30)    {
        num = ftos(self.cnt2 / 60);
        bprint(2, "Match will begin in 30 seconds.\n");
    }
    if (self.cnt2 <= 10) {
        if (self.cnt2 == 10) {
            is_countdown = 1;
            lightstyle(0, "e");
            //preventing double demo recording
            localcmd("cancel\n");
            if (stof(infokey(world, "demo_auto_left")) > 0) {
                if (infokey(world, "serverdemo") == "on") {
                    calltimeofday();

                    localcmd("record \"");
                    str = strzone(GetGameFileName());
                    localcmd(strzone(str));
                    localcmd("\"\n");

                    str = strcat(str,".json");
                    str = strcat(str);
                    fclose(logfilehandle);
                    logfilehandle = fopen(str,FILE_WRITE);
                    strunzone(str);
                }
            }
        }
        num = strzone(ftos(self.cnt2));
        p = find(world, classname, "player");
        tmp = strcat(num ,"\n\n\b:[\b");
        tmp = strcat(tmp, mapname);
        tmp = strcat(tmp, "\b]:\b");
        strcat(tmp, "\n");

        while (p != world) {
            if (p.netname != "") {
                CenterPrint3 (p, "Countdown ", tmp, "\n");
                if (self.cnt2 < 6) {
                    cease_fire = 0;
                    stuffcmd (p, "play buttons/switch04.wav\n");
                }
            }
            p = find(p, classname, "player");
        }
        if (self.cnt2 > 1) {
            bprint2(2, num, " seconds \n");
        }
        else {
            bprint(2, "1 second \n");
        }
        strunzone(num);
    }

    self.nextthink = (time + 1);
};

void () ResetBreakAndReady = {
    local entity te;
    te = find (world, classname, "player");
    while (te != world) {
        te.bvote = 0;
        te.is_ready = 0;
        v_break = 0;
        v_ready = 0;
        if(infokeyf(te, INFOKEY_P_CSQCACTIVE)) {
            UpdateClientPrematch(te, TRUE);
        }
        te = find (te, classname, "player");
    }
    te = find(world, classname, "observer");
    while (te) {
        if(infokeyf(te, INFOKEY_P_CSQCACTIVE)) {
            UpdateClientPrematch(te, TRUE);
        }
        te = find(te, classname, "observer");
    }
}

void () StartTimer =
{
    local entity timer;
    local entity p;
    local entity te;

    if (clanbattle == 0) {
        if (self != world) {
            sprint(self, 2, "Clan mode off....\n");
            sprint(self, 2, "Match cannot be started.\n");
        }
        else {
            dprint("Clan mode off....\n");
            dprint("Match cannot be started.\n");
        }
        return;
    }
    if (clanbattle == 1 && cb_prematch == 0) {
        if (self != world) {
            sprint(self, 2, "Clan Battle in progress....\n");
            sprint(self, 2, "Type break to stop the current battle.\n");
        }
        else {
            dprint("Clan Battle in progress....\n");
            dprint("Type break to stop the current battle.\n");
        }
        return;
    }
    timer = find(world, classname, "prematch");
    while (timer != world) {
        dremove(timer);
        timer = find(timer, classname, "prematch");
    }
    te = find(world,classname,"pmmessage");
    if (te != world) {
        te.think = SUB_Remove;
        te.nextthink = 0.01;
    }

    ResetBreakAndReady();
    timer = spawn();
    timer.owner = world;
    timer.classname = "prematch";
    timer.cnt = 0;
    timer.cnt2 = rint(stof(infokey(world, "count")));
    if (timer.cnt2 < 1) {
        //By default, 10 seconds of countdown
        timer.cnt2 = 10;
    }
    timer.cnt2 = (timer.cnt2 + 1);
    timer.nextthink = (time + 0.1);
    timer.think = PreMatch_Think;

    p = find(world, classname, "player");
    while (p != world) {
        if (p.netname != "") {
            stuffcmd(p, "play items/protect2.wav\n");
        }
        p = find(timer, classname, "player");
    }
};

void () StopTimer =
{
    local entity t;

    if (infokey(world, "serverdemo") != string_null) {
        localcmd("cancel\n");
        if (logfilehandle > 0)
            fclose(logfilehandle);
    }
    if (cb_prematch) {
        t = find(world, classname, "prematch");
        while (t != world) {
            t.nextthink = (time + 0.1);
            t.think = SUB_Remove;
            t = find (t, classname, "prematch");
        }
        localcmd("serverinfo status Standby\n");
        lightstyle(0, "m");
        return;
    }
    t = find(world, classname, "match");
    if (t != world) {
        remove(t);
    }
    localcmd("serverinfo status Normal\n");
};

void () DumpClanScores = {
    local float winners;
    local float no_teams;
    local float printed;
    local float ti;
    local float tno;
    local float teamfrags;
    local string st;
    local entity te;
    local float t1_pl;
    local float t1_unacc;
    local float t2_pl;
    local float t2_unacc;
    local float t3_pl;
    local float t3_unacc;
    local float t4_pl;
    local float t4_unacc;

    t1_pl = TeamFortress_TeamGetNoPlayers(1);
    t2_pl = TeamFortress_TeamGetNoPlayers(2);
    t3_pl = TeamFortress_TeamGetNoPlayers(3);
    t4_pl = TeamFortress_TeamGetNoPlayers(4);

    printed = 0;
    no_teams = 0;
    if (t1_pl) {
        no_teams = no_teams + 1;
    }
    if (t2_pl) {
        no_teams = no_teams + 1;
    }
    if (t3_pl) {
        no_teams = no_teams + 1;
    }
    if (t4_pl) {
        no_teams = no_teams + 1;
    }
    if (no_teams < 2) {
        return;
    }
    t4_unacc = 0;
    t3_unacc = 0;
    t2_unacc = 0;
    t1_unacc = 0;

    ti = 0;

    teamfrags = toggleflags & (TFLAG_TEAMFRAGS | TFLAG_FULLTEAMSCORE);

    te = find(world, classname, "player");
    while (te) {
        if (te.team_no == 1) {
            t1_unacc = t1_unacc + te.real_frags;
        } else if (te.team_no == 2) {
            t2_unacc = t2_unacc + te.real_frags;
        } else if (te.team_no == 3) {
            t3_unacc = t3_unacc + te.real_frags;
        } else if (te.team_no == 4) {
            t4_unacc = t4_unacc + te.real_frags;
        }
        te = find(te, classname, "player");
    }
    t1_unacc = team1frags - t1_unacc;
    t2_unacc = team2frags - t2_unacc;
    t3_unacc = team3frags - t3_unacc;
    t4_unacc = team4frags - t4_unacc;

    winners = TeamFortress_TeamGetWinner();

    bprint(PRINT_HIGH, "\n\n=------= Match results =------=\n");
    if ((no_teams == 2) && (((team1score == team2score) && teamfrags)
                            || ((team1frags == team2frags) && !teamfrags))) {
        bprint(PRINT_HIGH, " draw ");
    }
    else if ((no_teams == 3) &&
               ((((team1score == team2score) == team3score) && teamfrags)
                || (((team1frags == team2frags) == team3frags) &&
                    !teamfrags))) {
        bprint(PRINT_HIGH, " draw ");
    }
    else if ((no_teams == 3)
               &&
               (((((team1score == team2score) == team3score) == team4score)
                 && teamfrags)
                ||
                ((((team1frags == team2frags) == team3frags) == team4frags)
                 && !teamfrags))) {
        bprint(PRINT_HIGH, " draw ");
    }
    else {
        st = GetTeamName(winners);
        bprint(PRINT_HIGH, st, " defeated ");
        if ((winners != 1) && (t1_pl != 0)) {
            st = GetTeamName(1);
            bprint(PRINT_HIGH, st);
            printed = printed + 1;
        }
        if ((winners != 2) && (t2_pl != 0)) {
            st = GetTeamName(2);
            if (printed == no_teams) {
                bprint2(PRINT_HIGH, " and ", st);
            } else if (printed) {
                bprint2(PRINT_HIGH, ", ", st);
            } else {
                bprint(PRINT_HIGH, st);
            }
            printed = printed + 1;
        }
        if ((winners != 3) && (t3_pl != 0)) {
            st = GetTeamName(3);
            if (printed == no_teams) {
                bprint2(PRINT_HIGH, " and ", st);
            } else if (printed) {
                bprint2(PRINT_HIGH, ", ", st);
            } else {
                bprint(PRINT_HIGH, st);
            }
            printed = printed + 1;
        }
        if ((winners != 4) && (t4_pl != 0)) {
            st = GetTeamName(4);
            if (printed == no_teams) {
                bprint2(PRINT_HIGH, " and ", st);
            } else if (printed) {
                bprint2(PRINT_HIGH, ", ", st);
            } else {
                bprint(PRINT_HIGH, st);
            }
        }
    }
    bprint(PRINT_HIGH, "\n\n");

    st = infokey(world, "dtf");
    if (st == string_null)
        st = infokey(world, "dont_tweak_frags");

    if (st != "on") {
        if (teamfrags != 0) {
            if (t1_pl > 0) {
                printed = floor(team1score / t1_pl);
                ti = 0;
                if ((printed * t1_pl) != team1score) {
                    ti = team1score - (printed * t1_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 1) {
                        te.frags = printed;
                    }
                    if (ti) {
                        te.frags = te.frags + 1;
                        ti = ti - 1;
                    }
                    te = find(te, classname, "player");
                }
            }
            if (t2_pl > 0) {
                printed = floor((team2score / t2_pl));
                ti = 0;
                if ((printed * t2_pl) != team2score) {
                    ti = team2score - (printed * t2_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 2) {
                        te.frags = printed;
                    }
                    if (ti) {
                        te.frags = te.frags + 1;
                        ti = ti - 1;
                    }
                    te = find(te, classname, "player");
                }
            }
            if (t3_pl > 0) {
                printed = floor((team3score / t3_pl));
                ti = 0;
                if ((printed * t3_pl) != team3score) {
                    ti = team3score - (printed * t3_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 3) {
                        te.frags = printed;
                    }
                    if (ti) {
                        te.frags = te.frags + 1;
                        ti = ti - 1;
                    }
                    te = find(te, classname, "player");
                }
            }
            if (t4_pl > 0) {
                printed = floor((team4score / t4_pl));
                ti = 0;
                if ((printed * t4_pl) != team4score) {
                    ti = team4score - (printed * t4_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 4) {
                        te.frags = printed;
                    }
                    if (ti) {
                        te.frags = te.frags + 1;
                        ti = ti - 1;
                    }
                    te = find(te, classname, "player");
                }
            }
        } else {
            if ((t1_pl > 0) && (t1_unacc > 0)) {
                printed = floor(t1_unacc / t1_pl);
                ti = 0;
                if ((printed * t1_pl) != t1_unacc) {
                    ti = t1_unacc - (printed * t1_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 1) {
                        te.frags = te.real_frags + printed;
                        if (ti) {
                            te.frags = te.frags + 1;
                            ti = ti - 1;
                        }
                    }
                    te = find(te, classname, "player");
                }
            }
            if ((t2_pl > 0) && (t2_unacc > 0)) {
                printed = floor((t2_unacc / t2_pl));
                ti = 0;
                if ((printed * t2_pl) != t2_unacc) {
                    ti = t2_unacc - (printed * t2_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 2) {
                        te.frags = te.real_frags + printed;
                        if (ti) {
                            te.frags = te.frags + 1;
                            ti = ti - 1;
                        }
                    }
                    te = find(te, classname, "player");
                }
            }
            if ((t3_pl > 0) && (t3_unacc > 0)) {
                printed = floor((t3_unacc / t3_pl));
                ti = 0;
                if ((printed * t3_pl) != t3_unacc) {
                    ti = t3_unacc - (printed * t3_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 3) {
                        te.frags = te.real_frags + printed;
                        if (ti) {
                            te.frags = te.frags + 1;
                            ti = ti - 1;
                        }
                    }
                    te = find(te, classname, "player");
                }
            }
            if ((t4_pl > 0) && (t4_unacc > 0)) {
                printed = floor((t4_unacc / t4_pl));
                ti = 0;
                if ((printed * t4_pl) != t4_unacc) {
                    ti = t4_unacc - (printed * t4_pl);
                }
                te = find(world, classname, "player");
                while (te) {
                    if (te.team_no == 4) {
                        te.frags = te.real_frags + printed;
                        if (ti) {
                            te.frags = te.frags + 1;
                            ti = ti - 1;
                        }
                    }
                    te = find(te, classname, "player");
                }
            }
        }
    }
    if (t1_pl > 0) {
        bprint(PRINT_HIGH, "\n=------= Blue team results =------=\n");
        tno = TeamFortress_TeamGetNoPlayers(1);
        st = ftos(tno);
        bprint2(PRINT_HIGH, st, " players\n");
        st = ftos(team1frags);
        bprint2(PRINT_HIGH, st, " frags, ");
        st = ftos(t1_unacc);
        bprint2(PRINT_HIGH, st, " unaccounted for\n");
        st = ftos(team1score);
        bprint2(PRINT_HIGH, st, " team score\n");
    }
    if (t2_pl > 0) {
        bprint(PRINT_HIGH, "\n=------= Red team results =------=\n");
        tno = TeamFortress_TeamGetNoPlayers(2);
        st = ftos(tno);
        bprint2(PRINT_HIGH, st, " players\n");
        st = ftos(team2frags);
        bprint2(PRINT_HIGH, st, " frags, ");
        st = ftos(t2_unacc);
        bprint2(PRINT_HIGH, st, " unaccounted for\n");
        st = ftos(team2score);
        bprint2(PRINT_HIGH, st, " team score\n");
    }
    if (t3_pl > 0) {
        bprint(PRINT_HIGH, "\n=------= Yellow team results =------=\n");
        tno = TeamFortress_TeamGetNoPlayers(3);
        st = ftos(tno);
        bprint2(PRINT_HIGH, st, " players\n");
        st = ftos(team3frags);
        bprint2(PRINT_HIGH, st, " frags, ");
        st = ftos(t3_unacc);
        bprint2(PRINT_HIGH, st, " unaccounted for\n");
        st = ftos(team3score);
        bprint2(PRINT_HIGH, st, " team score\n");
    }
    if (t4_pl > 0) {
        bprint(PRINT_HIGH, "\n=------= Green team results =------=\n");
        tno = TeamFortress_TeamGetNoPlayers(4);
        st = ftos(tno);
        bprint2(PRINT_HIGH, st, " players\n");
        st = ftos(team4frags);
        bprint2(PRINT_HIGH, st, " frags, ");
        st = ftos(t4_unacc);
        bprint2(PRINT_HIGH, st, " unaccounted for\n");
        st = ftos(team4score);
        bprint2(PRINT_HIGH, st, " team score\n");
    }
    te = find(world, classname, "player");
    while (te) {
        st = infokey(te, "take_sshot");
        if (st != string_null) {
            stuffcmd(te, "screenshot\n");
        }

        if (te.playerclass != 0) {
            local float timeplayed = gametime - te.classtime;
            LogEventChangeClass(te, te.playerclass, 0, timeplayed);
            te.classtime = gametime;
        }

        te = find(te, classname, "player");
    }
};

void () TeamFortress_ShowIDs = {
    local entity te;
    local float got_one;
    local string st;

    if (self.team_no == 0) {
        sprint(self, PRINT_HIGH, "You are not in a team\n");
        return;
    }
    got_one = 0;
    sprint(self, PRINT_HIGH, "Existing team member IDs:\n");

    te = find(world, classname, "player");
    while (te) {
        if (te.team_no == self.team_no) {
            got_one = 1;
            st = ftos(te.tf_id);
            sprint(self, PRINT_HIGH, te.netname, " : ", st, "\n");
        }
        te = find(te, classname, "player");
    }

    if (!got_one)
        sprint(self, PRINT_HIGH, "None\n");
    got_one = 0;
    sprint(self, PRINT_HIGH, "Disconnected team member IDs:\n");

    te = find(world, classname, "ghost");
    while (te) {
        if (te.team_no == self.team_no) {
            got_one = 1;
            st = ftos(te.tf_id);
            sprint2(self, 2, st, "\n");
        }
        te = find(te, classname, "ghost");
    }

    if (!got_one)
        sprint(self, PRINT_HIGH, "None\n");
};

void () CenterPrint_Players_NotReady = {
    string players_not_ready;
    entity te;
    players_not_ready = "Not ready: ";

    local float first = 0;
    te = find (world, classname, "player");
    while (te) {
        if (te.is_ready == 0 && !te.has_disconnected)
        {
            first = first + 1;
            if (first == 1)
            {
                players_not_ready = strcat(players_not_ready, te.netname);
            }
            else if (first > 1 && first < 5)
            {
                players_not_ready = strcat(players_not_ready, ", ", te.netname);
            }
            else if (first >= 5)
            {
                players_not_ready = strcat(players_not_ready, " and others...");
                break;
            }
        }
        te = find (te, classname, "player");
    }
    players_not_ready = strcat(players_not_ready, "\n", "Type \s/ready\s in the console to toggle your ready status\n");

    te = find(world, classname, "player");
    while (te)
    {
        if(!infokeyf(te, INFOKEY_P_CSQCACTIVE)) {
            CenterPrint(te, players_not_ready);
        }

        te = find(te, classname, "player");
    }
}

void () Broadcast_Players_NotReady = {
    local entity te;
    if (v_ready != 0) {
        local string players_not_ready = "Not ready: ";
        local float first = 1;
        te = find (world, classname, "player");
        while (te != world) {
            if (te.is_ready == 0 && !te.has_disconnected) {
                if (!first)
                    players_not_ready = strcat(players_not_ready, ", ");
                else
                    first = 0;
                players_not_ready = strcat(players_not_ready, te.netname);
            }
            te = find (te, classname, "player");
        }
        players_not_ready = strcat(players_not_ready, "\n");
        bprint(1, players_not_ready);
        te = find (world, classname, "player");
        while (te != world) {
            if (te.is_ready == 0 && !te.has_disconnected)
                sprint(te, 2, "If you are ready, type \s/ready\s in the console\n");
            te = find(te, classname, "player");
        }
        return;
    }
    else {
        bprint(1, "No player is ready\n");
    }

}

void () PlayerNotReady = {
    if (self.is_ready) {
        bprint2 (2, self.netname, " is NOT ready anymore\n ");
        self.is_ready = 0;
        v_ready = (v_ready - 1);
        Broadcast_Players_NotReady();
    }
}

float () CheckAllPlayersReady = {
    local float f1;
    if (is_countdown) {
        return 0;
    }
    if (infokey (world, "status") != "Standby") {
        return 0;
    }
    if (intermission_running)
        return 0;
        
    f1 = TeamFortress_GetNoPlayers ();
    bprint (PRINT_HIGH, "Total players ready - ",ftos(v_ready),"/",ftos(f1),".\n");
    if (v_ready == f1 && v_ready > 0) {
        if(cease_fire) {
            bprint (2, "All players ready, match will start after ceasefire ends.\n");
        } else {
            bprint (2, "All players ready, starting match\n");
            StartTimer ();
        }
        return 1;
    }
    return 0;
}

void () PlayerReady =
{
    if (is_countdown) {
        sprint(self, 2, "You cannot do this after countdown has started.\n");
        return;
    }
    if (infokey (world, "status") != "Standby") {
        sprint(self, 2, "You cannot do this after the match has started.\n");
        return;
    }
    if (self.team_no == 0) {
        sprint(self, 2, "You must join a team first.\n");
        return;
    }
    if (self.playerclass == 0) {
        sprint(self, 2, "You must choose a class first.\n");
        return;
    }
    if (intermission_running)
        return;
    if (self.classname != "player")
        return;
    if (self.is_ready) {
        PlayerNotReady();
        return;
    }
    self.is_ready = 1;
    v_ready = v_ready + 1;
    bprint2 (3, self.netname, " is ready to start the match\n");
    if(!CheckAllPlayersReady())
        Broadcast_Players_NotReady();
};

void () RemoveVotes = {
    if (self.bvote) {
        bprint2(2, self.netname, " \swithdraws\s his/her vote\n");
        self.bvote = 0;
        v_break = (v_break - 1);
    }
    if (self.is_ready) {
        bprint2(2, self.netname, " is NOT ready anymore\n ");
        self.is_ready = 0;
        v_ready = (v_ready - 1);
    }
};

void () PreMatch_Message = {
    self.cnt2 = self.cnt2 + 1;
    if (self.cnt2 % 30 == 0)
    {
        local entity p = find (world, classname, "player");
        while (p != world) {
            if (p.netname != "") {
                sprint(p, PRINT_HIGH, "Currently in \sprematch\s time\n");
                if (p.is_ready)
                    sprint(p, PRINT_HIGH, "You are \sready\s to start the match.\n Type \s/notready\s in the console if you are not ready\n");
                else
                    sprint(p, PRINT_HIGH, "Type \s/ready\s in the console if you are ready to start the match\n");
                stuffcmd(p, "play buttons/switch04.wav\n");
                if(infokeyf(p, INFOKEY_P_CSQCACTIVE)) {
                    UpdateClientPrematch(p, FALSE);
                }
            }
            p = find(p, classname, "player");
        }
    }
    CenterPrint_Players_NotReady();
    self.nextthink = time + 1;
}
