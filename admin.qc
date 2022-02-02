
void (entity p) BanCheater;
void (string halias, string commands) TeamFortress_AliasString;

void () Admin_CountPlayers = {
    local string st;
    local float nump;

    nump = TeamFortress_GetNoPlayers();
    st = ftos(nump);
    sprint3(self, PRINT_HIGH, "Players in game: ", st, "\n");
    if (number_of_teams > 0) {
        nump = TeamFortress_TeamGetNoPlayers(1);
        st = ftos(nump);
        sprint3(self, PRINT_HIGH, "Players in blue team: ", st, "\n");
    }
    if (number_of_teams > 1) {
        nump = TeamFortress_TeamGetNoPlayers(2);
        st = ftos(nump);
        sprint3(self, PRINT_HIGH, "Players in red team: ", st, "\n");
    }
    if (number_of_teams > 2) {
        nump = TeamFortress_TeamGetNoPlayers(3);
        st = ftos(nump);
        sprint3(self, PRINT_HIGH, "Players in yellow team: ", st, "\n");
    }
    if (number_of_teams > 3) {
        nump = TeamFortress_TeamGetNoPlayers(4);
        st = ftos(nump);
        sprint3(self, PRINT_HIGH, "Players in green team: ", st, "\n");
    }
};

void () Admin_ListIPs = {
    if (TeamFortress_GetNoPlayers() <= 1) {
        sprint(self, PRINT_HIGH, "No other players in the game\n");
        self.admin_use = world;
        return;
    }
    self.admin_use = find(self.admin_use, classname, "player");
    while (self.admin_use != world) {
        if ((self.admin_use.netname != string_null) &&
            (self.admin_use != self)) {
            self.admin_use.ip = infokey(self.admin_use, "ip");
            sprint(self, PRINT_HIGH, self.admin_use.netname, " (",
                   self.admin_use.ip, ")\n");
        }
        self.admin_use = find(self.admin_use, classname, "player");
    }
    self.admin_use = find(self.admin_use, classname, "observer");
    while (self.admin_use != world) {
        if ((self.admin_use.netname != string_null) &&
            (self.admin_use != self)) {
            self.admin_use.ip = infokey(self.admin_use, "ip");
            sprint(self, PRINT_HIGH, self.admin_use.netname, " (",
                   self.admin_use.ip, ") (SPECTATOR)\n");
        }
        self.admin_use = find(self.admin_use, classname, "observer");
    }
    sprint(self, PRINT_HIGH, "End of player list\n");
    self.admin_use = world;
};

void () Admin_CycleDeal = {
    if (TeamFortress_GetNoPlayers() <= 1) {
        sprint(self, PRINT_HIGH, "No other players in the game\n");
        self.admin_use = world;
        self.admin_mode = 0;
        return;
    }
    if (self.admin_use.classname != "observer") {
        self.admin_use = find(self.admin_use, classname, "player");
        while ((self.admin_use != world) &&
               ((self.admin_use.netname == string_null)
                || (self.admin_use == self))) {
            self.admin_use = find(self.admin_use, classname, "player");
        }
        if (self.admin_use == world) {
            self.admin_use = find(self.admin_use, classname, "observer");
            while ((self.admin_use != world) && ((self.admin_use.netname == string_null) || (self.admin_use == self))) {
                self.admin_use = find(self.admin_use, classname, "observer");
            }
        }
    } 
    else {
        self.admin_use = find(self.admin_use, classname, "observer");
        while ((self.admin_use != world) && ((self.admin_use.netname == string_null) || (self.admin_use == self))) {
            self.admin_use = find(self.admin_use, classname, "observer");
        }
    }
    if (self.admin_use) {
        self.admin_use.ip = infokey(self.admin_use, "ip");
        self.admin_mode = 1;
        sprint(self, PRINT_HIGH, self.admin_use.netname, " (", self.admin_use.ip, ")");
        if (self.admin_use.classname == "observer")
            sprint(self, PRINT_HIGH, " (spectator)");
        sprint(self, PRINT_HIGH, "\n   kick/ban/next?\n");
    } 
    else {
        self.admin_mode = 0;
        sprint(self, PRINT_HIGH, "End of player list\n");
    }
};

void () Admin_DoKick = {
    bprint4(PRINT_HIGH, self.admin_use.netname, " was kicked by ", self.netname, "\n");
    KickCheater(self.admin_use);
    self.admin_mode = 0;
    self.admin_use = world;
};

void () Admin_DoBan = {
    bprint4(PRINT_HIGH, self.admin_use.netname, " was banned by ", self.netname, "\n");
    BanCheater(self.admin_use);
    self.admin_mode = 0;
    self.admin_use = world;
};

void () Admin_ForceSpectator = {
    bprint4(PRINT_HIGH, self.admin_use.netname, " was made spectator by ", self.netname, ". There's probably a good reason for this.\n");
    clientcommand(self.admin_use, "observe");
    self.admin_mode = 0;
    self.admin_use = world;
};

void () CeaseFire_think =
{
    local entity te;
    if (cease_fire == 0) {
        dremove(self);
        return;
    }
    te = find(world, classname, "player");
    while (te) {
        CenterPrint3(te, "CEASE FIRE\nCalled by: ", self.owner.netname, "\n");
        te = find(te, classname, "player");
    }
    self.nextthink = (time + 5);
};

void () Admin_CeaseFire = {
    local entity te;

    if (!cease_fire) {
        if (cb_prematch) {
            StopTimer();
        }
        cease_fire = 1;
        bprint(2, "CEASE FIRE\n");
        te = find(world, classname, "player");
        while (te) {
            CenterPrint3(te, "CEASE FIRE\nCalled by: ", self.netname, "\n");
            te.immune_to_check = (time + 5);
            te.tfstate = (te.tfstate | TFSTATE_CANT_MOVE);
            TeamFortress_SetSpeed(te);
            te = find(te, classname, "player");
        }
        te = spawn();
        te.owner = self;
        te.classname = "ceasefire";
        te.think = CeaseFire_think;
        te.nextthink = (time + 5);
    }
    else {
        te = find(world, classname, "ceasefire");
        if (te) {
            dremove(te);
        }
        cease_fire = 0;
        bprint(2, "RESUME FIRE\n");
        if (cb_prematch) {
            //Make sure you don't just start the countdown on resume when not everyone's readied up
            if (is_countdown || v_ready == TeamFortress_GetNoPlayers () ) {
                StartTimer();
            }
        }
        te = find(world, classname, "player");
        while (te) {
            CenterPrint3(te, "RESUME FIRE\nCalled by: ", self.netname, "\n");
            te.immune_to_check = (time + 5);
            te.tfstate = (te.tfstate - (te.tfstate & TFSTATE_CANT_MOVE));
            TeamFortress_SetSpeed (te);
            te = find (te, classname, "player");
        }
    }
};

void () Admin_Pause = {
    if (!is_paused) {
        setpause(1);
        is_paused = 1;
        pause_actor = self.netname;
        if (cb_prematch && is_countdown) {
            StopTimer();
            bprint2(2, pause_actor, " stops the countdown\n");
            return;
        }
        bprint2(2, pause_actor, " paused the game\n");
    }
    else {
        if (cb_prematch) {
            //Make sure you don't just start the countdown on resume when not everyone's readied up
            if (is_countdown || v_ready == TeamFortress_GetNoPlayers () ) {
                StartTimer();
            }
            setpause(0);
            is_paused = 0;
            return;
        }
        pause_actor = self.netname;
        if (!unpause_requested) {                        
            bprint2(2, pause_actor, " has requested to unpause the game in 5 seconds\n");     
            unpause_requested = 1;
        }
        else {
            bprint2(2, pause_actor, " cancels unpause request\n"); 
            unpause_requested = 0;
            unpause_countdown = 0;
            unpause_lastcountnumber = 0;
        }
    }
}

void (entity p) CheckAutoKick = {
    local float rnum;
    local entity te;

    if ((p.teamkills >= autokick_kills) && (autokick_kills != 0)) {
        bprint2(PRINT_HIGH, p.netname,
                " was kicked for killing teammates\n");
        sprint(p, PRINT_HIGH, "You were kicked for killing teammates\n");
        KickCheater(p);
    } 
    else if (autokick_kills != 0) {
        if (p.teamkills == (autokick_kills - 1)) {
            sprint(p, PRINT_HIGH,
                   "Kill one more teammate, and you will get kicked out\n");
        }
        rnum = 0;
        te = find(world, classname, "ak_timer");
        while (te) {
            if (te.owner == p) {
                rnum = 1;
                te = world;
            } else
                te = find(te, classname, "ak_timer");
        }
        if (rnum == 0) {
            te = spawn();
            te.classname = "ak_timer";
            te.owner = p;
            te.think = autokick_think;
            te.nextthink = time + autokick_time;
        }
    }
};

void (string cl_pwd) Admin_Check =
{
    if (self.is_admin) {
        sprint(self, PRINT_HIGH, "You are already an admin\n");
        return;
    }
    local string st2;

    st2 = infokey(world, "adminpwd");
    if (cl_pwd != string_null) {
        stuffcmd(self, "setinfo adminpwd \"");
        stuffcmd(self, "\"\n");
        if (st2 != string_null && cl_pwd == st2) {
            self.is_admin = TRUE;
            forceinfokey(self,"*admin", ftos(self.is_admin));
            bprint2(2, self.netname, "\s gains full admin status!\s\n");
            sprint(self, 2, "Type \scmd list\s for admin commands.\n");
            sprint(self, 2, "You can also use the \sadminmenu\s command for adjusting some settings.\n");  
        }
    }
};

void () Admin_Aliases =
{
    TeamFortress_Alias("countplayers", TF_ADMIN_COUNTPLAYERS, 0);
    TeamFortress_Alias("deal", TF_ADMIN_CYCLEDEAL, 0);
    TeamFortress_Alias("kick", TF_ADMIN_KICK, 0);
    TeamFortress_Alias("ban", TF_ADMIN_BAN, 0);
    TeamFortress_Alias("next", TF_ADMIN_NEXT, 0);
    TeamFortress_Alias("ceasefire", TF_ADMIN_CEASEFIRE, 0);
    TeamFortress_Alias("listips", TF_ADMIN_LISTIPS, 0);
    TeamFortress_Alias("clan", TF_ADMIN_CLANMODE, 0);
    TeamFortress_Alias("quadmode", TF_ADMIN_QUADMODE, 0);
    //TeamFortress_Alias("adminmenu", TF_ADMIN_ADMINMENU, 0);
    TeamFortress_AliasString("adminmenu", "cmd adminmenu");
    TeamFortress_Alias("startmatch", TF_ADMIN_FORCESTARTMATCH, 0);
    TeamFortress_Alias("readystatus", TF_ADMIN_READYSTATUS, 0);
    stuffcmd(self,"alias ceasefire \"cmd ceasefire\"\n");
};
