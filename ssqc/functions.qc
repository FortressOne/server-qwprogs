float (float tno) TeamFortress_TeamSet;
string (float tno) TeamFortress_TeamGetColor;
string (entity pov, float tno) TeamFortress_TeamGetColorFor;
void (entity p) SetTeamName;
void (entity pl) Menu_Close;

void (float tno) playerSetTeam = {
	local string st;
	TeamFortress_TeamSet(tno);
	self.team_no = tno;
	stuffcmd(self, "color ");
	st = TeamFortress_TeamGetColor(tno);
	stuffcmd(self, st);
	stuffcmd(self, "\n");
	SetTeamName(self);
};

float () PlayerCount = {
	local entity te;
	local float tmp = 0;

	te = find(world, classname, "player");
	while (te != world) {
		tmp = tmp + 1;
		te = find(te, classname, "player");
	}
	return tmp;
};

float () SpectatorCount = {
	local entity te;
	local float tmp = 0;

	te = find(world, classname, "observer");
	while (te != world) {
		tmp = tmp + 1;
		te = find(te, classname, "observer");
	}
	return tmp;
};

void () nextCaptain = {
	local entity te;

	te = find(world, classname, "player");
	while (te != world) {
		if (te.captain == 4)
			te.captain = 3;
		else if (te.captain == 3)
			te.captain = 2;
		else if (te.captain == 2) {
			te.captain = 1;
			stuffcmd(te,"reload\n"); // Required to send one impulse in order to show menu
		} else if (te.captain == 1)
			te.captain = number_of_teams;
		te = find(te, classname, "player");
	}
};

void () disableCaptain = {
	captainmode = 0;
	bprint(2, "\x10\sCaptain Mode\s\x11\s:\s Captain Mode Disabled!\n");	
};

void () randomizeCaptains = {
	local entity te;
	local float tmp = 0;
	local float teamno = 0;
	local float capteam[4] = {0, 0, 0, 0};

	te = find(world, classname, "player");
	while (te != world) {
		if (te.captain == 9 && tmp < number_of_teams) {
			do {
				teamno = floor((random() * number_of_teams));
			} while (capteam[teamno] == 1);
			capteam[teamno] = 1;
			te.captain = teamno + 1;
			if (te.captain == 1)
				stuffcmd(te, "reload\n");
			tmp = tmp + 1;
		}
		te = find(te, classname, "player");
	}
};

void () randomizeTeams = {
	local entity te, temp;
	local float tmp = 0;
	local float teamno = 0;
	local float randteam[4] = {0, 0, 0, 0};

	te = find(world, classname, "player");
	while (te != world) {
		if (tmp >= number_of_teams) {
			tmp = 0;
			randteam[0] = 0;
			randteam[1] = 0;
			randteam[2] = 0;
			randteam[3] = 0;
		}
		if (tmp < number_of_teams) {
			do {
				teamno = floor((random() * number_of_teams));
			} while (randteam[teamno] == 1);

			randteam[teamno] = 1;
			temp = self;
			self = te;
			playerSetTeam(teamno + 1);
			self = temp;
			tmp = tmp + 1;
		}                
		te = find(te, classname, "player");
	}
};

string (string text) clearString = {
	local float i;
	string specialChars[60] = {"�", "", "","","","","","","","	","","","","","","","","","",""," ","?","","‚","ƒ","„","…","†","‡","ˆ","‰","Š","‹","Œ","","Ž","","","‘","œ","Å","Å“","","ž","Ÿ", "<", ">", "|", ":", "*", "?", "\\", "/", "\"", "&", "~", "`", ",", " ", "."};
	text = strconv(1,1,1,text);
	text = strireplace("__", "_", text);
	for (i = 0; i < 58; i++) {
		text = strireplace(specialChars[i], "", text);
	}

	return text;
}

void () PrintLoginMessage =  {
	CenterPrint6(self, "\n\n\n\n\n\nžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n", "Login required, please use\n\s\"cmd login <login> <secret>\"\s \nbefore joining the game\n", "žžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n", "If you don't have an account, visit\n\s", webpageUrl,"\s\n");																
	return;	
}

void () EndGameThink = {
	local string m = mapname;
	if(vote_result != string_null && vote_result != "") {
		m = vote_result;
	} else if(nextmap != string_null && nextmap != "") {
		m = nextmap;
	}
	localcmd("changelevel ");
	localcmd(m);
	localcmd("\n");
	dremove(self);
}

void () MapEndSequence = {
	local entity player;
	local entity maprestarttimer;
	player = find (world, classname, "player");	
	while (player) 
	{
		if (player.playerclass != 0 && self.has_disconnected != 1) {
			local float timeplayed = gametime - player.classtime;
			LogEventChangeClass(player, player.playerclass, 0, timeplayed);
			player.classtime = gametime;
		}
		player = find (player, classname, "player");
	}	
	LogEventTeamScores();
	LogEventGameEnd();
	if (logfilehandle > 0)
		fclose(logfilehandle);
	canlog = 0;

	maprestarttimer = spawn();
	maprestarttimer.classname = "timer";
	maprestarttimer.netname = "maprestarttimer";
	maprestarttimer.think = EndGameThink;
	maprestarttimer.nextthink = time + map_restart_time;
}
