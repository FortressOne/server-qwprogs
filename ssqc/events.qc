string (string text) clearString;
string (float tno) GetTeamName;

float (entity player) isPlayerValid = {
	if (player.has_disconnected == 1 
		|| !infokey(player, INFOKEY_P_USERID)
        || infokey(player, INFOKEY_P_USERID) == ""
        || !infokey(player, INFOKEY_P_NAME) 
        || infokey(player, INFOKEY_P_NAME) == "") {
		return 0;
	}
    return 1;
}

string () ISOTimemillis = {
	local string padding = string_null;
    local string timeuse = strftime(0,"%Y-%m-%dT%H:%M:%S.");
    local float randmillis = rint((random()*1000*random()));
    if (randmillis < 10)
        padding = "00";
    else if (randmillis < 100)
        padding = "0";
    local string padded = strcat(padding, ftos(randmillis));
    timeuse = strcat(timeuse, padded);
    timeuse = strcat(timeuse, "Z");
   	return timeuse;
}

string (entity pl) getEntityNameOrLogin = {
	if (loginRequired)
		return pl.login;
	else
		return clearString(pl.netname);
}

void (string evt) logevent = {
	local string st = infokey (world, "event_debug");
	if (stof(st) > 0) {
		bprint(PRINT_HIGH, evt, "\n");
	}
	fputs(logfilehandle, evt);
}

void (entity player) LogEventPlayerStart = {
 	if (canlog == 0)
		return;
	if (isPlayerValid(player) == FALSE)
		return;

	local string event;
	event = sprintf(",\n{\"type\": \"playerStart\", \"player\": \"%s\", \"classtime\": %s, \"time\": %s, \"gameTimeStamp\": \"%s\"}", getEntityNameOrLogin(player), ftos(player.classtime), ftos(gametime), gametimestamp);
	logevent(event);
}

void () LogEventGameStart = {
	gametimestamp = ISOTimemillis();
 	if (canlog == 0)
		return;
	local string event;
	local entity player;
	local float numplayers = 0;
	player = find (world, classname, "player");	

	while (player) 
	{
		if (isPlayerValid(player) == TRUE)
			numplayers++;
		player = find (player, classname, "player");
	}

	event = sprintf("{\"type\": \"gameStart\", \"map\": \"%s\", \"numPlayers\": %s, \"numTeams\": %s, \"time\": %s, \"demo\": \"%s\", \"gameTimeStamp\": \"%s\"}", mapname, ftos(numplayers), ftos(number_of_teams), ftos(gametime), cvar_string("serverdemo"), gametimestamp);
	logevent(event);
}

void (entity player, float previous, float next, float timeplayed) LogEventChangeClass = {
	if (canlog == 0)
		return;
	if (isPlayerValid(player) == FALSE)
		return;
	if (previous == 0) {
		return;
	}

	local string event;
	event = sprintf(",\n{\"type\": \"changeClass\", \"player\": \"%s\", \"playerClass\": %s, \"nextClass\": %s, \"team\": %s, \"timePlayed\": %s, \"time\": %s, \"gameTimeStamp\": \"%s\"}",
							getEntityNameOrLogin(player),
							ftos(previous),
							ftos(next),
							ftos(player.team_no),
							ftos(timeplayed),
							ftos(gametime),
							gametimestamp
							);
	logevent(event);
}

string (float code, float mode) GetWeaponName = {
	if (code == 1) {
		return "hook";
	}
	else if (code == 4) {
		return "medikit";
	}
	else if (code == 8) {
		return "spanner";
	}
	else if (code == 16) {
		return "axe";
	}
	else if (code == 32) {
		return "sniperrifle";
	}
	else if (code == 64) {
		return "autorifle";
	}
	else if (code == 128) {
		return "shotgun";
	}
	else if (code == 256) {
		return "supershotgun";
	}
	else if (code == 512) {
		return "nailgun";
	}
	else if (code == 1024) {
		return "supernailgun";
	}
	else if (code == 2048) {
		if (mode == 0)
			return "grenadelauncher";
		else if (mode == 1)
			return "pipebomblauncher";
	}
	else if (code == 4096) {
		return "flamethrower";
	}
	else if (code == 8192) {
		return "rocketlauncher";
	}
	else if (code == 16384) {
		return "incendiary";
	}
	else if (code == 32768) {
		return "assaultcannon";
	}
	else if (code == 65536) {
		return "lightning";
	}
	else if (code == 131072) {
		return "plasmagun";
	}
	else if (code == 262144) {
		return "tranquilizer";
	}
	else if (code == 524288) {
		return "railgun";
	}
	else if (code == 1048576) {
		return "tribolt";
	}
	else if (code == 2097152) {
		return "sniperrail";
	}
	else
		return "undefined";
}

void (entity attacker, entity target, string afflictionType) LogAffliction = {
	if (attacker.classname == "player" && target.classname == "player")
	{
		if (attacker.team_no == target.team_no)
		{
			attacker.afflicted = attacker.afflicted + 1;
		}
		else
		{
			attacker.teamafflicted = attacker.teamafflicted + 1;
		}
	}
}

void (entity attacker, entity target, entity inflictor, float damage, float truedam) LogEventDamage = {
	if (!cb_prematch)
	{
		entity realattacker = attacker;
		if (attacker.classname == "building_sentrygun" || attacker.classname == "building_dispenser")
		{
			realattacker = attacker.real_owner;
		}

		if (realattacker.team_no != target.team_no)
		{
			if (realattacker != target && realattacker != target.real_owner)
			{
				if (realattacker.classname == "player" && (target.classname == "player" || target.classname == "building_sentrygun"))
				{
					realattacker.damagegiven = realattacker.damagegiven + truedam;
				}
				
				if (target.classname == "player")
				{
					target.damagetaken = target.damagetaken + truedam;
				}
			}
		}
	}
	
	if (canlog == 0)
		return;

	local string event;
	local string attackEvent;
	local string targetEvent;
	local string part1attack;
	local string part1target;
	local string part2;
	local string damageKind;
	local string attackername;
	local string targetname;
	local string inflictorId;

	attackername = getEntityNameOrLogin(attacker);
	targetname = getEntityNameOrLogin(target);
	if (attacker == target)
		damageKind = "self";
	else if (attacker.team_no == target.team_no)
		damageKind = "team";
	else
		damageKind = "enemy";

	
	if (inflictor.classname == "player") 
		inflictorId = GetWeaponName(attacker.current_weapon, attacker.weaponmode);
	else {
		inflictorId = inflictor.classname;
		if ((inflictor.classname == "spike") && (attacker.playerclass == 3)) {
			inflictorId = "nailgrenspike";
		}
		else if ((inflictor.classname == "spike") && (attacker.playerclass == 5)) {
			inflictorId = "superspike";
		}
		if (inflictorId == "worldspawn")
			attackername = "world";
		else if (inflictorId == "building_sentrygun") {
			attackername = getEntityNameOrLogin(attacker.real_owner);
			if (damageKind == "damageTeam")
				return;
		}
		else if ((inflictorId == "grenade") && (inflictor.grenadename != ""))
			inflictorId = inflictor.grenadename;
	}


	if (getEntityNameOrLogin(target) != "") {
		part1attack = sprintf(",\n{\"type\": \"damageDone\", \"kind\": \"%s\", \"player\": \"%s\", \"playerClass\": %s, \"playerTeam\": %s, \"target\": \"%s\", \"targetClass\": %s, \"targetTeam\": %s, ",
						damageKind, 
						attackername, 
					   	ftos(attacker.playerclass), 
					   	ftos(attacker.team_no), 
					   	getEntityNameOrLogin(target), 
					   	ftos(target.playerclass), 
					   	ftos(target.team_no));
		part1target = sprintf(",\n{\"type\": \"damageTaken\", \"kind\": \"%s\", \"attacker\": \"%s\", \"attackerClass\": %s, \"attackerTeam\": %s, \"player\": \"%s\", \"playerClass\": %s, \"playerTeam\": %s, ",
						damageKind, 
						attackername, 
					   	ftos(attacker.playerclass), 
					   	ftos(attacker.team_no), 
					   	getEntityNameOrLogin(target), 
					   	ftos(target.playerclass), 
					   	ftos(target.team_no));


		part2 = sprintf("\"inflictor\": \"%s\", \"damage\": %s, \"time\": %s, \"gameTimeStamp\": \"%s\"}", 
						inflictorId,
						ftos(damage),
						ftos(gametime),
						gametimestamp
						);

		attackEvent = strcat(part1attack, part2);
		targetEvent = strcat(part1target, part2);
		event = strcat(attackEvent, targetEvent);
		logevent(event);
	}
}

void (entity attacker, entity target, entity inflictor) LogEventKill = {
	if (!cb_prematch)
	{
		entity realattacker = attacker;
		if (attacker.classname == "building_sentrygun" || attacker.classname == "building_dispenser")
		{
			realattacker = attacker.real_owner;
		}

		if (realattacker.classname == "player" && (target.classname == "player" || target.classname == "building_sentrygun"))
		{
			if (realattacker != target && realattacker != target.real_owner)
			{
				if (realattacker.team_no == target.team_no)
				{
					realattacker.sbteamkills = realattacker.sbteamkills + 1;
				}
				else
				{
					realattacker.kills = realattacker.kills + 1;
				}
			}

			target.deaths = target.deaths + 1;
		}
	}

	if (canlog == 0)
		return;

	if ((target.classname != "player") && (target.classname != "building_sentrygun"))
		return;

	local string killKind;
	local string attackername;
	local string targetname;
	local string inflictorId;

	attackername = getEntityNameOrLogin(attacker);
	targetname = getEntityNameOrLogin(target);
	if (attacker == target)
		killKind = "self";
	else if (attacker.team_no == target.team_no)
		killKind = "team";
	else
		killKind = "enemy";

	if (inflictor.classname == "player") 
		inflictorId = GetWeaponName(attacker.current_weapon, attacker.weaponmode);
	else {
		inflictorId = inflictor.classname;
		if ((inflictor.classname == "spike") && (attacker.playerclass == 3)) {
			inflictorId = "nailgrenspike";
		}
		else if ((inflictor.classname == "spike") && (attacker.playerclass == 5)) {
			inflictorId = "superspike";
		}
		if (inflictorId == "worldspawn")
			attackername = "world";
		else if (inflictorId == "building_sentrygun")
			attackername = getEntityNameOrLogin(attacker.real_owner);
		else if ((inflictorId == "grenade") && (inflictor.grenadename != ""))
			inflictorId = inflictor.grenadename;
	}

	local string event;
	local string attackEvent;
	local string targetEvent;
	local string part1attack;
	local string part1target;
	local string part2;

	part1attack = sprintf(",\n{\"type\": \"kill\", \"kind\": \"%s\", \"player\": \"%s\", \"playerClass\": %s, \"playerTeam\": %s, \"target\": \"%s\", \"targetClass\": %s, \"targetTeam\": %s, ",
					killKind,
					attackername, 
				   	ftos(attacker.playerclass), 
				   	ftos(attacker.team_no), 
				   	targetname, 
				   	ftos(target.playerclass), 
				   	ftos(target.team_no));
	part1target = sprintf(",\n{\"type\": \"death\", \"kind\": \"%s\", \"attacker\": \"%s\", \"attackerClass\": %s, \"attackerTeam\": %s, \"player\": \"%s\", \"playerClass\": %s, \"playerTeam\": %s, ",
					killKind,
					attackername, 
				   	ftos(attacker.playerclass), 
				   	ftos(attacker.team_no), 
				   	targetname, 
				   	ftos(target.playerclass), 
				   	ftos(target.team_no));
	part2 = sprintf("\"inflictor\": \"%s\", \"time\": %s, \"gameTimeStamp\": \"%s\"}", 
					inflictorId,					
					ftos(gametime),
					gametimestamp
					);
	attackEvent = strcat(part1attack, part2);
	targetEvent = strcat(part1target, part2);
	event = strcat(attackEvent, targetEvent);
	logevent(event);
}

void (entity attacker, entity target, float tfstate) LogEventAffliction = {
	if (attacker != target)
	{
		if (attacker.team_no == target.team_no)
		{
			attacker.teamafflicted = attacker.teamafflicted + 1;
		}
		else
		{
			attacker.afflicted = attacker.afflicted + 1;
		}
	}
};

void (entity player) LogEventGoal = {
	if(player == world)
		return;
	player.caps = player.caps + 1;
	if (canlog == 0)
		return;
	local string event;
	event = sprintf(",\n{\"type\": \"goal\", \"team\": %s, \"player\": \"%s\", \"playerClass\": \"%s\", \"time\": %s, \"gameTimeStamp\": \"%s\"}", 
		ftos(player.team_no),
		getEntityNameOrLogin(player), 
		ftos(player.playerclass), 
		ftos(gametime), 
		gametimestamp);
	logevent(event);
}


void (entity player) LogEventPickupGoal = {
	player.touches = player.touches + 1;
	if (canlog == 0)
		return;
	local string event;
	event = sprintf(",\n{\"type\": \"pickup\", \"team\": %s, \"player\": \"%s\", \"playerClass\": \"%s\", \"time\": %s, \"gameTimeStamp\": \"%s\"}", 
		ftos(player.team_no),
		getEntityNameOrLogin(player),
		ftos(player.playerclass), 
		ftos(gametime), 
		gametimestamp);
	logevent(event);
}

void (entity player, float timecarried) LogEventFumble = {
	if (canlog == 0)
		return;
	local string event;
	event = sprintf(",\n{\"type\": \"fumble\", \"team\": %s, \"player\": \"%s\", \"playerClass\": \"%s\", \"timeCarried\": %s, \"time\": %s, \"gameTimeStamp\": \"%s\"}", 
		ftos(player.team_no),
		getEntityNameOrLogin(player),
		ftos(player.playerclass), 
		ftos(timecarried), 
		ftos(gametime), 
		gametimestamp);
	logevent(event);
}

void (entity attacker) LogEventAttack = {
	if (canlog == 0)
		return;
	local string event;
	event = sprintf(",\n{\"type\": \"attack\", \"player\": \"%s\", \"playerClass\": \"%s\", \"inflictor\": \"%s\", \"time\": %s, \"gameTimeStamp\": \"%s\"}", getEntityNameOrLogin(attacker), ftos(attacker.playerclass), GetWeaponName(attacker.current_weapon, attacker.weaponmode), ftos(gametime), gametimestamp);
	logevent(event);
}

void () LogEventGameEnd = {
	if (canlog == 0)
		return;
	local string event;
	event = sprintf(",\n{\"type\": \"gameEnd\", \"time\": %s, \"gameTimeStamp\": \"%s\"}", ftos(gametime), gametimestamp);
	logevent(event);
}

void () LogEventTeamScores = {
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

	local string teamscores;
	teamscores = sprintf("\"team1Score\": %s", ftos(team1score));
	if (number_of_teams > 1)
		teamscores = strcat(teamscores, sprintf(", \"team2Score\": %s", ftos(team2score)));
	if (number_of_teams > 2)
		teamscores = strcat(teamscores, sprintf(", \"team3Score\": %s", ftos(team3score)));
	if (number_of_teams > 3)
		teamscores = strcat(teamscores, sprintf(", \"team4Score\": %s", ftos(team4score)));

	local string teamnames;
	teamnames = sprintf("\"team1Name\": \"%s\"", GetTeamName(1));
	if (number_of_teams > 1)
		teamnames = strcat(teamnames, sprintf(", \"team2Name\": \"%s\"", GetTeamName(2)));
	if (number_of_teams > 2)
		teamnames = strcat(teamnames, sprintf(", \"team3Name\": \"%s\"", GetTeamName(3)));
	if (number_of_teams > 3)
		teamnames = strcat(teamnames, sprintf(", \"team4Name\": \"%s\"", GetTeamName(4)));

	local string event;
	event = sprintf(",\n{\"type\": \"teamScores\", %s, %s, \"winningTeam\": %s, \"time\": %s, \"gameTimeStamp\": \"%s\"}", teamscores, teamnames, ftos(winning_team), ftos(gametime), gametimestamp);
	logevent(event);
}
