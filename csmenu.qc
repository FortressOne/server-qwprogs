void UpdateClientMenu_Team(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
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
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
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
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    if(!pl.playerclass) {
        return;
    }
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_CLASS);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_DropAmmo(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_DROPAMMO);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Scout(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SCOUT);
    WriteByte(MSG_MULTICAST, pl.ScannerOn);
    WriteFloat(MSG_MULTICAST, pl.tf_items_flags);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Spy(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SPY);
    WriteFloat(MSG_MULTICAST, invis_only);
    WriteFloat(MSG_MULTICAST, pl.last_skin);
    WriteFloat(MSG_MULTICAST, pl.last_team);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Spy_Skin(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SPY_SKIN);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Spy_Team(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_SPY_TEAM);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_Detpack(entity pl, float cancel_detpack) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_DETPACK);
    WriteByte(MSG_MULTICAST, cancel_detpack);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMenu_Build(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_BUILD);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_FixSentry(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_ROTATE_SENTRY);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_FixDispenser(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_FIX_DISPENSER);
    WriteByte(MSG_MULTICAST, old_spanner);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_UseDispenser(entity pl, entity disp) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
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
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_ADMIN);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void Update_ServerAdminInfo(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
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
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_ADMIN_KICK);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}
void UpdateClientMenu_Vote(entity pl, float timeleft) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
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
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_CAPTAIN_PICK);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClient_Captains(entity pl, float cap1, float cap2) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CAPTAINS);
    WriteFloat(MSG_MULTICAST, cap1);
    WriteFloat(MSG_MULTICAST, cap2);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientMOTD(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_MOTD);
    WriteString(MSG_MULTICAST, infokey(world, "motd1"));
    WriteString(MSG_MULTICAST, infokey(world, "motd2"));
    WriteFloat(MSG_MULTICAST, (
        (clanbattle?GAMEMODE_CLAN:0) + 
        (quadmode?GAMEMODE_QUAD:0) + 
        (duelmode?GAMEMODE_DUEL:0) + 
        (votemode?GAMEMODE_VOTE:0)
    ));
    WriteFloat(MSG_MULTICAST, infokeyf(world, "rounds"));
    WriteFloat(MSG_MULTICAST, number_of_teams);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS);
}

void UpdateClientTeamScores(entity e) = {
    if(!infokeyf(e, INFOKEY_P_CSQCACTIVE))
        return;

    msg_entity = e;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, MSG_TEAM_SCORES);
    WriteFloat(MSG_MULTICAST, team1score);
    WriteFloat(MSG_MULTICAST, team2score);
    WriteFloat(MSG_MULTICAST, team3score);
    WriteFloat(MSG_MULTICAST, team4score);
    multicast('0 0 0', MULTICAST_ONE_R_NOSPECS);
}

void UpdateClientPrematch(entity pl, float countdownstarted) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_PREMATCH);
    WriteByte(MSG_MULTICAST, cb_prematch);
    WriteByte(MSG_MULTICAST, round_active);
    WriteByte(MSG_MULTICAST, round_over);
    WriteByte(MSG_MULTICAST, countdownstarted);
    WriteFloat(MSG_MULTICAST, rounds);
    float timeleft = 0;
//    if(!cb_prematch && round_active && !round_over) {
        local entity t = find(world, classname, "match");
        if (t != world) {
            timeleft = t.cnt2;
            
        }
        t = find(world, classname, "prematch");
        if (t != world) {
            timeleft = t.cnt2;
            
        }
        t = find(world, classname, "round");
        if (t != world) {
            timeleft = t.cnt * 60 + t.cnt2;
        }
//    }
    WriteFloat(MSG_MULTICAST, timeleft);
    //WriteByte(MSG_MULTICAST, countdownstarted);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClientGrenadeSettings(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, MSG_GRENADESETTINGS);
    WriteFloat(MSG_MULTICAST, fo_flash);
    WriteFloat(MSG_MULTICAST, medic_type);
    WriteFloat(MSG_MULTICAST, nailgren_type);
    multicast('0 0 0', MULTICAST_ONE_R_NOSPECS);
}

void UpdateClientMapVote(entity pl, entity candidate) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE) || !candidate)
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_VOTE_UPDATE);
    WriteString(MSG_MULTICAST, candidate.netname);
    WriteFloat(MSG_MULTICAST, candidate.cnt);
    WriteByte(MSG_MULTICAST, (candidate.cnt > 0 && pl.vote_map == candidate));
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateAllClientMapVotes(entity candidate) {
    if(!candidate) {
        return;
    }
    entity pl = find(world, classname, "player");
    while(pl) {
        if(!pl.has_disconnected) {
            UpdateClientMapVote(pl, candidate);
        }
        pl = find(pl, classname, "player");
    }
}

void UpdateClientMenu_Maps(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_CLIENT_MENU);
    WriteFloat(MSG_MULTICAST, CLIENT_MENU_MAPS);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClient_VoteMap_Add(entity pl, entity map_candidate) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_VOTE_MAP_ADD);
    WriteString(MSG_MULTICAST, substring(map_candidate.netname,0,20));
    WriteString(MSG_MULTICAST, map_candidate.broadcast);
    WriteString(MSG_MULTICAST, substring(map_candidate.team_broadcast,0,10));
    WriteFloat(MSG_MULTICAST, map_candidate.team_no);
    WriteFloat(MSG_MULTICAST, map_candidate.ex_skill_min);
    WriteFloat(MSG_MULTICAST, map_candidate.ex_skill_max);
    WriteFloat(MSG_MULTICAST, map_candidate.cnt);
    WriteByte(MSG_MULTICAST, (pl.vote_map == map_candidate));
    multicast('0 0 0', MULTICAST_ONE_NOSPECS);
}

void() votemap_sender_think = {
    if (self.owner.vote_map_send) {
        UpdateClient_VoteMap_Add(self.owner, self.owner.vote_map_send);
        self.owner.vote_map_send = find(self.owner.vote_map_send, classname, "map_candidate");
        self.nextthink = time + 0.1;
    } else {
        dremove(self);
    }
}

void UpdateClient_VoteMap_AddAll(entity pl) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;

    //PlayerPreThink was too fast. Use a timer to slow down the send rate
    //Soas to not overflow the message buffers
    pl.vote_map_send = find(world, classname, "map_candidate");
    local entity sender_timer = spawn();
    sender_timer.owner = pl;
    sender_timer.classname = "votemap_sender_timer";
    sender_timer.nextthink = time + 0.1;
    sender_timer.think = votemap_sender_think;
}

void UpdateClient_VoteMap_Add_Broadcast(entity map_candidate) = {
    local entity pl = find(world, classname, "player");
    while(pl) {
        if(infokeyf(pl, INFOKEY_P_CSQCACTIVE) && !pl.has_disconnected) {
            UpdateClient_VoteMap_Add(pl, map_candidate);
        }
        pl = find(pl, classname, "player");
    }
}

void UpdateClient_VoteMap_Delete(entity pl, string map) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_VOTE_MAP_DELETE);
    WriteString(MSG_MULTICAST, map);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClient_VoteMap_Delete_Broadcast(entity map_candidate) = {
    local entity pl = find(world, classname, "player");
    while(pl) {
        if(infokeyf(pl, INFOKEY_P_CSQCACTIVE) && !pl.has_disconnected) {
            UpdateClient_VoteMap_Delete(pl, map_candidate.netname);
        }
        pl = find(pl, classname, "player");
    }
}
