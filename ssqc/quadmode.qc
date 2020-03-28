//=-=-=-=-=

float () CheckWinningTeam = {
	local float win_score = 0;
	local float winning_team = 0;

	if (team1score > win_score) {
		win_score = team1score;
		winning_team = 1;
	}

	if (team2score > win_score) {
		win_score = team2score;
		winning_team = 2;
	}
	else if (team2score == win_score) {
		winning_team = 0;
	}

	if (team3score > win_score) {
		win_score = team3score;
		winning_team = 3;
	}
	else if (team3score == win_score) {
		winning_team = 0;
	}

	if (team4score > win_score) {
		win_score = team4score;
		winning_team = 4;
	}
	else if (team4score == win_score) {
		winning_team = 0;
	}
	return winning_team;
};

void () QuadRoundOver = {
	round_over = 2;
	self.think = StartQuadRound;
	self.nextthink = (time + 0.5);
};

void () QuadRoundThink = {
	local string tmp;
	local float fl;

	if (rounds < 2) {
		if (CheckWinningTeam() != 0) {
			if (quad_winner != CheckWinningTeam()) {
				quad_winner = CheckWinningTeam();
				self.think = QuadRoundOver;
				self.nextthink = (time + 0.1);
				return;
			}
		}
	}

	if (self.cnt == -1)
		return;

	if ( self.cnt == stof(infokey(world, "round_time")) - 1 && self.cnt2 == 59 ) {
		localcmd("serverinfo status \"");
		tmp = ftos (self.cnt + 1);
		localcmd(tmp);
		localcmd(" min left\"\n");
	}

	if (self.cnt2 == 1) {
		localcmd("serverinfo status \"");
		tmp = ftos (self.cnt);
		localcmd(tmp);
		localcmd(" min left\"\n");
	}

	if (self.cnt2 == -1) {
		self.cnt2 = 59;
		self.cnt = (self.cnt - 1);
	}

	if (!cease_fire)
		self.cnt2 = (self.cnt2 - 1);

	if (!self.cnt2)	{
		if ((self.cnt == 1) || (self.cnt == 5)) {
			tmp = ftos (self.cnt);
			bprint3(2, "\s[\s", tmp, "\s]\s minute");
			if (self.cnt != 1)
				bprint(2, "s");
			bprint(2, " remaining\n");
		}
		if (!self.cnt) {
			if (rounds > 1)
            {
                local string st;
                st = infokey(world, "round_delay_time");
                bprint(2, "ROUND TIME OVER\nNext round begins in ", st, " seconds\n");
            }


//			lightstyle (0, "e");

			self.think = QuadRoundOver;
			self.nextthink = (time + 0.1);
			return;
		}
	}
	if (!self.cnt && (((self.cnt2 == 30) || (self.cnt2 == 15)) || (self.cnt2 <= 10))) {
		fl = ceil (self.cnt2);
		if (!(fl - self.cnt2)) {
			tmp = ftos(self.cnt2);
			bprint3(2, "\s[\s", tmp, "\s]\s second");
			if ((self.cnt2 != 1))
				bprint(2, "s");
			bprint(2, " remaining\n");
		}
	}
	gametime++;
	self.nextthink = (time + 1);
};

void () QuadRoundBegin = {

	local entity te;
	local entity oldself;
	local float counter;
	localcmd(strcat(strcat("timelimit ", ftos(stof(infokey(world, "round_time")))), "\n"));
	te = find(world, classname, "func_breakable");
	while (te) {
		setmodel(te, te.mdl);
		te.solid = SOLID_BSP;
		te = find(te, classname, "func_breakable");
	}
	cb_prematch = 0;
 	round_active = 1;
	round_over = 0;

	te = find(world, classname, "player");
	while (te != world) {
		oldself = self;
		self = te;
        if(self.team_no && self.playerclass) {
            self.takedamage = DAMAGE_AIM;
            self.solid = SOLID_SLIDEBOX;
            self.movetype = MOVETYPE_WALK;
            TeamFortress_RemoveTimers();
            setspawnparms(self);
            PutClientInServer();
        }
        if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
            UpdateClientPrematch(self, FALSE);
        }
		self = oldself;
		te = find (te, classname, "player");
	}
//	lightstyle (0, "m");

	bprint(2, "QUAD ROUND BEGINS NOW\n");
	if (!self.cnt) {
		self.cnt = stof(infokey (world, "round_time")) - 1;
		self.cnt2 = 60;
	}
	else {
		counter = floor(self.cnt);
		if (counter < self.cnt)
			self.cnt2 = ((self.cnt - counter) * 60);
		else
			self.cnt2 = 60;
		if (self.cnt2 == 60)
			self.cnt = (self.cnt - 1);
		else
			self.cnt = counter;
	}
	self.cnt2 = self.cnt2 + 1;
	localcmd("serverinfo status \"");
	local string tmp = ftos (self.cnt + 1);
	localcmd(tmp);
	localcmd(" min left\"\n");
	self.think = QuadRoundThink;
	self.nextthink = (time + 0.001);
};

void () QuadRoundInit = {
	local string num;
	local entity p;

	if ((number_of_teams < 1) || cease_fire)	{
		self.nextthink = (time + 2);
		if (self.cnt2 <= 5)
			self.cnt2 = 10;
		return;
	}
	self.cnt2 = (self.cnt2 - 1);
	if (self.cnt2 == 2)
		round_over = 2;
	else {
		if (!self.cnt2)	{
			localcmd("serverinfo status \"0 min left\"\n");
			self.nextthink = (time + 0.1);
			self.think = QuadRoundBegin;
			p = find(world, classname, "player");
			while (p != world) {
				if (p.netname != "" && p.team_no && p.playerclass) {
					p.takedamage = DAMAGE_AIM;
					p.solid = SOLID_SLIDEBOX;
					p.movetype = MOVETYPE_WALK;
				}
				p = find(p, classname, "player");
			}
			return;
		}
	}

    num = ftos(self.cnt2);
    p = find (world, classname, "player");
    while (p) {
        if (p.netname != "") {
            CenterPrint3(p, "Round begins in: ", num, " second(s).\nEnsure correct class is chosen!\n");

            if (self.cnt2 <= 5)
            {
                cease_fire = 0;
                stuffcmd(p, "play buttons/switch04.wav\n");
            }
        }
        p = find(p, classname, "player");
    }
	self.nextthink = (time + 1);
};

void () StartQuadRound =
{
	local string st;
	local float fl;
	local entity te;
	local entity te2;
	local entity oldself;
	local entity gren;
	local entity p;

	lightstyle(0, "m");
    cease_fire = 0;

	p = find(world, classname, "player");
	while (p != world) {
		if (p.netname != "" && p.team_no && p.playerclass) {
			p.takedamage = DAMAGE_NO;
			p.solid = SOLID_NOT;
			p.movetype = MOVETYPE_NONE;
			p.modelindex = 0;
			p.model = string_null;
		}
        if(infokeyf(p, INFOKEY_P_CSQCACTIVE)) {
            UpdateClientPrematch(p, TRUE);
        }
		p = find(p, classname, "player");
	}

	cb_prematch = 1;
	round_over = 1;

	if (rounds == 1) {
		quad_winner = CheckWinningTeam();
		if (quad_winner == 0)
			bprint (2, "Round Drawn!\n");
		else if (quad_winner == 1)
			bprint(2, "Blue Team Wins!\n");
		else if (quad_winner == 2)
			bprint(2, "Red Team Wins!\n");
		else if (quad_winner == 3)
			bprint(2, "Yellow Team Wins!\n");
		else if (quad_winner == 4)
			bprint(2, "Green Team Wins!\n");
		p = find (world, classname, "player");
		while (p != world) {
			if (p.netname != "" && p.team_no && p.playerclass) {
				p.takedamage = DAMAGE_NO;
				p.solid = SOLID_NOT;
				p.movetype = MOVETYPE_NONE;
				p.modelindex = 0;
				p.model = string_null;
			}
            if(infokeyf(p, INFOKEY_P_CSQCACTIVE)) {
                UpdateClientPrematch(p, TRUE);
            }
			p = find(p, classname, "player");
		}
		bprint(2, "Rounds Over! Use \"cmd map <mapname>\" to go to the nextmap\n");
		if (!clan_scores_dumped) {
            DumpClanScores();
            MapEndSequence();
            clan_scores_dumped = 1;
 		}
		localcmd("stop\n");
		return;
	}
	if (rounds > 1)
		rounds = (rounds - 1);
	if (intermission_running)
		return;

	te = find(world, classname, "door");
	while (te != world) {
		te2 = self;
		self = te;
		//door_go_down();
		door_go_down_silent();
		self.think = LinkDoors;
		self = te2;
		te = find(te, classname, "door");
	}

	te = find(world, classname, "item_tfgoal");
	while (te) {
		if (te.origin != te.oldorigin) {
			if (te.owner != world)
					tfgoalitem_RemoveFromPlayer(te, te.owner, 1);
			oldself = spawn();
			oldself.enemy = te;
			oldself.weapon = 3;
			oldself.nextthink = (time + 0.2);
			oldself.think = ReturnItem;
		}
		te = find(te, classname, "item_tfgoal");
	}

	if (round_active) {
		te = find(world, classname, "player");
		while (te != world)	{
			oldself = self;
			self = te;
			self.menu_count = 30;
			self.current_menu = 1;
			TeamFortress_ThrowGrenade();
			TeamFortress_RemoveTimers();
			if (self.playerclass == 9) {
				Engineer_RemoveBuildings(self);
			}
			self = oldself;
			te = find (te, classname, "player");
		}
		round_active = 0;
	}
	gren = find(world, classname, "grenade");
	while (gren) {
		gren.think = SUB_Remove;
		gren.nextthink = (time + 0.1);
		gren = find(gren, classname, "grenade");
	}
	gren = find(world, classname, "grentimer");
	while (gren) {
		gren.think = SUB_Remove;
		gren.nextthink = (time + 0.1);
		gren = find(gren, classname, "grentimer");
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
	te = find(world, classname, "backpack");
	while (te) {
		te.think = SUB_Remove;
		te.nextthink = (time + 0.1);
		te = find(te, classname, "backpack");
	}
	te = find(world, classname, "ammobox");
	while (te) {
		te.think = SUB_Remove;
		te.nextthink = (time + 0.1);
		te = find(te, classname, "ammobox");
	}

	te = find(world, classname, "round");
	st = infokey(world, "count");
	fl = stof(st);
	if ((fl < 3) || (fl > 20)) {
		fl = 10;
	}

    local float rdt;
    st = infokey(world, "round_delay_time");
    rdt = stof(st);
	te.cnt2 = rdt;
	st = infokey (world, "round_time");
	te.cnt = stof (st);
	quad_winner = CheckWinningTeam();
	localcmd("serverinfo status Standby\n");
	if (rounds > 1) {
		te.think = QuadRoundBegin;
		te.nextthink = (time + 0.01);
	}
	else {
		te.think = QuadRoundInit;
		te.nextthink = (time + 1);
	}
};

void () EndQuadRound = {
	if (infokey(world, "quadmode") == "on") {
		if (infokey(world,"status") != "Countdown" && infokey(world,"status") != "Standby") {
			if (rounds > 1) {
                local string st;
                st = infokey(world, "round_delay_time");
                bprint(2, "ROUND TIME OVER\nNext round begins in ", st, " seconds\n");
				lightstyle (0, "e");
				self.think = QuadRoundOver;
				self.nextthink = (time + 0.1);
			}
			else if (rounds == 1) {
				StartQuadRound();
			}
		}
	}
};
