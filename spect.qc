// Spectator functions
// Added Aug11'97 by Zoid <zoid@idsoftware.com>
//
// These functions are called from the server if they exist.
// Note that Spectators only have one think since they movement code doesn't
// track them much.  Impulse commands work as usual, but don't call
// the regular ImpulseCommand handler in weapons.qc since Spectators don't
// have any weapons and things can explode.
//
//   --- Zoid.

void () SpectatorDisconnect;
void () SpectatorImpulseCommand;
void () SpectatorThink;
void () Quick_Aliases;
void () Admin_Aliases;

void () SpectatorConnect = {
    SetDimensions(TRUE);

    local string st;

    self.playerclass = PC_UNDEFINED;
    self.classname = "observer";
    self.flags = 8;

    if (infokey(self,"*login"))
        self.login = infokey(self,"*login");
    if (infokey(self,"*admin"))
        self.is_admin = stof(infokey(self, "*admin"));

    Quick_Aliases();

    st = infokey(self, "apw");
    if (st == string_null)
        st = infokey(self, "adminpwd");
    if (st) {
        Admin_Check(st);
        if (self.is_admin) 
            Admin_Aliases();
        else
            self.is_admin = FALSE;
    }

    st = infokey(self, "em");
    if (st == string_null)
        st = infokey(self, "exec_map");

    if (st == "on") {
        stuffcmd(self, "exec mapdefault.cfg\n");
        stuffcmd(self, "exec spectator.cfg\n");
        stuffcmd(self, "exec ");
        stuffcmd(self, mapname);
        stuffcmd(self, ".cfg\n");
    }
    self.motd = 0;
    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        InitAllStatuses(self);
        UpdateClientMOTD(self);
        UpdateClientTeamScores(self);
        UpdateClientPrematch(self, !cb_prematch);
        UpdateClient_VoteMap_AddAll(self);
    }

    TeamFortress_StartTimers();
    TeamFortress_RemovePracticeSpawn(self);
};

void () SpectatorDisconnect = {
    RemoveAutoIdTimer();
};

void () SpectatorImpulseCommand = {
    if (self.impulse == 1) {
        self.goalentity =
            find(self.goalentity, classname, "info_player_deathmatch");
        if (self.goalentity == world) {
            self.goalentity =
                find(self.goalentity, classname, "info_player_deathmatch");
        } else {
            setorigin(self, self.goalentity.origin);
            self.angles = self.goalentity.angles;
            self.fixangle = TRUE;
        }
    } else if (self.impulse == TF_ID)

        CF_Identify(self, self.autoid_type);

    else if (self.impulse == TF_HELP_MAP)

        TeamFortress_HelpMap();

    else if (self.impulse == TF_STATUS_QUERY)

        TeamFortress_StatusQuery();

    else if (self.impulse == TF_TEAM_SCORES)

        TeamFortress_TeamShowScores(0);

    if(self.menu_input == Vote_Menu_Map_Input && self.impulse >= 1 && self.impulse <= 10) {
        Menu_Input(self.impulse);
    }
    
    if (!self.is_admin) {
        self.impulse = 0;
        return;
    }

    if (self.impulse == TF_ADMIN_CEASEFIRE)
        Admin_CeaseFire();
    else if (self.impulse == TF_ADMIN_COUNTPLAYERS)
        Admin_CountPlayers();
    else if (self.impulse == TF_ADMIN_CYCLEDEAL)
        Admin_CycleDeal();
    else if ((self.impulse == TF_ADMIN_KICK) && (self.admin_mode == 1))
        Admin_DoKick();
    else if ((self.impulse == TF_ADMIN_BAN) && (self.admin_mode == 1))
        Admin_DoBan();
    else if ((self.impulse == TF_ADMIN_NEXT) && (self.admin_mode == 1))
        Admin_CycleDeal();
    else if (self.impulse == TF_ADMIN_LISTIPS)
        Admin_ListIPs();
    else if (self.impulse == TF_ADMIN_CLANMODE)
        ClanMode();
    else if (self.impulse == TF_ADMIN_QUADMODE)
        QuadMode();
    else if (self.impulse == TF_ADMIN_DUELMODE)
        DuelMode();
    else if (self.impulse == TF_ADMIN_ADMINMENU) {
        self.current_menu_page = 1;
        Menu_Admin();
    }
    else if (self.impulse == TF_ADMIN_FORCESTARTMATCH)
        StartTimer();
    else if (self.impulse == TF_ADMIN_READYSTATUS)
        Broadcast_Players_NotReady();
    
    else if (self.impulse > 0 && self.impulse <= 10) {
        Menu_Input(self.impulse);
    }
    
    self.impulse = 0;
};

void () SpectatorThink = {
    
    self.playerclass = 0;
    self.afflicted = 0;
    self.teamafflicted = 0;
    self.damagegiven = 0;
    self.damagetaken = 0;
    self.kills = 0;
    self.deaths = 0;
    self.caps = 0;
    self.touches = 0;
    self.team_no = 0;
    UpdateScoreboardInfo(self);

    if (self.impulse)
        SpectatorImpulseCommand();

    //if (self.motd <= 400)
    //    TeamFortress_MOTD();
    if (time >= self.StatusRefreshTime) {
        RefreshStatusBar(self);
    }
};
