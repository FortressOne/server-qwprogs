void UpdateClientMenu_Team(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_TEAM);
    WriteFloat(MSG_MULTICAST, number_of_teams);
    for(float i = 0; i < number_of_teams; i++) {
        WriteByte(MSG_MULTICAST, TeamFortress_TeamGetNoPlayers(i+1));
    }
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientClasses(entity pl, float team) = {
    local float civilian_team = TeamFortress_TeamIsCivilian(pl.team_no);
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLASSES_UPDATE);
    WriteByte(MSG_MULTICAST, civilian_team);
    override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
    if(!civilian_team) {
        for(float i = 0; i < 10; i++) {
            local float f_max = CF_GetClassRestriction(team, i+1);
            local float f_players = CF_GetClassPlayers(team, i+1);

            if ((IsLegalClass(i+1) || override_mapclasses) && f_max >= 0) {
                WriteFloat(MSG_MULTICAST, f_max);
                WriteByte(MSG_MULTICAST, f_players);
            } else {
                WriteFloat(MSG_MULTICAST, -1);
            }
        }
    }
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Class(entity pl) = {
    if(!pl.playerclass) {
        return;
    }
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_CLASS);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_DropAmmo(entity pl, float ammotypes, float ammomakes) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_DROPAMMO);
    WriteFloat(MSG_MULTICAST, ammotypes);
    WriteFloat(MSG_MULTICAST, ammomakes);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Scout(entity pl, float noupdate) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SCOUT);
    WriteByte(MSG_MULTICAST, pl.ScannerOn);
    WriteFloat(MSG_MULTICAST, pl.tf_items_flags);
    WriteByte(MSG_MULTICAST, noupdate);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Spy(entity pl, float noupdate) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SPY);
    WriteFloat(MSG_MULTICAST, invis_only);
    WriteFloat(MSG_MULTICAST, pl.last_skin);
    WriteFloat(MSG_MULTICAST, pl.last_team);
    WriteByte(MSG_MULTICAST, noupdate);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Spy_Skin(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SPY_SKIN);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Spy_Team(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SPY_TEAM);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_Detpack(entity pl, float cancel_detpack, float noupdate) = {
    bprint(PRINT_HIGH, "MEHT: UpdateClientMenu_Detpack: ", ftos(cancel_detpack),", ", ftos(noupdate),"\n");
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_DETPACK);
    WriteByte(MSG_MULTICAST, cancel_detpack);
    WriteByte(MSG_MULTICAST, noupdate);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Build(entity pl, float noupdate) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_BUILD);
    WriteByte(MSG_MULTICAST, noupdate);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_FixSentry(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_ROTATE_SENTRY);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_FixDispenser(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_FIX_DISPENSER);
    WriteByte(MSG_MULTICAST, old_spanner);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_UseDispenser(entity pl, entity disp) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_USE_DISPENSER);
    WriteFloat(MSG_MULTICAST, disp.origin.x);
    WriteFloat(MSG_MULTICAST, disp.origin.y);
    WriteFloat(MSG_MULTICAST, disp.origin.z);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_Admin(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_ADMIN);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void Update_ServerAdminInfo(entity pl) = {
    msg_entity = pl;
    local float cm = CF_GetSetting("c", "clan", "off"), 
                qm = CF_GetSetting("quadmode", "quadmode", "off"), 
                dm = CF_GetSetting("duelmode", "duelmode", "off");
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_SERVER_ADMIN_INFO);
    WriteByte(MSG_MULTICAST, is_paused || cease_fire);
    WriteFloat(MSG_MULTICAST, infokeyf(world, "rounds"));
    WriteFloat(MSG_MULTICAST, infokeyf(world, "round_time"));
    WriteFloat(MSG_MULTICAST, infokeyf(world, "timelimit"));
    WriteFloat(MSG_MULTICAST, infokeyf(world, "fraglimit"));
    WriteFloat(MSG_MULTICAST, (clanbattle?1:0) + (cm?2:0));
    WriteFloat(MSG_MULTICAST, (quadmode?1:0) + (qm?2:0));
    WriteFloat(MSG_MULTICAST, (duelmode?1:0) + (dm?2:0));
    WriteFloat(MSG_MULTICAST, captainmode);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Admin_Kick(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_ADMIN_KICK);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_Vote(entity pl, float timeleft) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_VOTE);
    WriteFloat(MSG_MULTICAST, timeleft);
    WriteString(MSG_MULTICAST, vote1_map);
    WriteFloat(MSG_MULTICAST, vote1_cnt);
    WriteString(MSG_MULTICAST, vote2_map);
    WriteFloat(MSG_MULTICAST, vote2_cnt);
    WriteString(MSG_MULTICAST, vote3_map);
    WriteFloat(MSG_MULTICAST, vote3_cnt);
    WriteString(MSG_MULTICAST, vote4_map);
    WriteFloat(MSG_MULTICAST, vote4_cnt);
    WriteString(MSG_MULTICAST, vote5_map);
    WriteFloat(MSG_MULTICAST, vote5_cnt);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Captain(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_CAPTAIN_PICK);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClient_Captains(entity pl, float cap1, float cap2) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CAPTAINS);
    WriteFloat(MSG_MULTICAST, cap1);
    WriteFloat(MSG_MULTICAST, cap2);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMOTD(entity pl) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_MOTD);
    WriteString(MSG_MULTICAST, infokey(world, "motd1"));
    WriteString(MSG_MULTICAST, infokey(world, "motd2"));
    WriteFloat(MSG_MULTICAST, ((clanbattle?1:0) + (quadmode?2:0) + (duelmode?4:0) + (cb_prematch?8:0) + (round_active?16:0) + (round_over?32:0)));
    WriteFloat(MSG_MULTICAST, infokeyf(world, "rounds"));
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientPrematch(entity pl, float countdownstarted) = {
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_PREMATCH);
    WriteByte(MSG_MULTICAST, ((cb_prematch?1:0 + (round_active?2:0) + (round_over?4:0))));
    WriteByte(MSG_MULTICAST, countdownstarted);
    WriteFloat(MSG_MULTICAST, rounds);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
