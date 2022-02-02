// MAP VOTING FOR FORTRESSONE
// ==========================
// Displays a vote menu during the last few minutes of gameplay on a map.

// functions by order of appearance
float () TeamFortress_GetNoActivePlayers;
void (entity pe_player) Vote_NextMap;
void (entity pe_player) Vote_TrickMap;
void (entity pe_player) Vote_RaceMap;
float () Vote_GetNextVotes;
float () Vote_GetTrickVotes;
float () Vote_GetRaceVotes;
void (entity pe_player) Vote_ForceNext;
void () GotoNextMap;
void () execute_changelevel;
float () Vote_GetForceNextVotes;
void () Vote_Check;
void (float pf_decider) Vote_SetupVote;
void (float pf_input) Vote_Input;
void (float force) Vote_MenuOpen;
void () Vote_MenuClose;
void (entity pe_player) Vote_Menu;
void (float pf_input) Vote_RemoveVote;
void (float pf_type) Vote_PopulateVoteList;
string (string ps_map, string ps_maplist) Vote_StripMap;
void () Vote_Reset;
void () Vote_ResetVotes;
void () Vote_ResetMapNames;
float () Vote_GetVoteCount;
float () Vote_GetWinnerCount;
float () Vote_GetWinnerVoteCount;
string () Vote_GetWinner;
string () Vote_GetWinnerList;
string (string ps_maplist) Vote_RandomWinner;
float (float pf_from, float pf_to) RandomRange;
void () Vote_DropLosers;
float (string ps_list) List_Count;
string (string ps_list, float pf_idx) List_Index;
string (entity ent, string ps_short, string ps_setting, string ps_default) FO_GetUserSettingString;
void (entity ent) TeamFortress_SetSpeed;
void FO_Sound(entity e, float chan, string samp, float vol, float atten);
void (entity p, string vote) VoteForMap;

// opens the map voting early
// called from weapons.qc:ImpulseCommands()
void (entity pe_player) Vote_NextMap = {
    local float f_votes, f_votes_needed, f_votes_left;

    if (clanbattle || vote_style)
        return;

    if (!pe_player.team_no || !pe_player.playerclass || pe_player.vote_next)
        return;

    if (vote_started > 0) {
        sprint(pe_player, PRINT_HIGH, "There is already a vote in progress.\n");
        return;
    }

    if (vote_result != string_null) {
        sprint(pe_player, PRINT_HIGH, "Next map has already been voted to ", vote_result, ". Use /forcenext to force next map.\n");
        return;
    }
    pe_player.vote_next = 1;
    pe_player.vote_trick = 0;
    pe_player.vote_race = 0;

    bprint(PRINT_HIGH, pe_player.netname, " wants to start voting for next map\n");

    f_votes = Vote_GetNextVotes();
    f_votes_needed = ceil(TeamFortress_GetNoActivePlayers() / 2);
    f_votes_left = f_votes_needed - f_votes;
    if (f_votes >= f_votes_needed) {
        Vote_SetupVote(0);
        //dprint("[", ftos(time), "/cf/mapvote/votenext]: forcing map vote.\n");
        bprint(PRINT_HIGH, "Commencing vote for next map\n");
    } else {
        if (f_votes_left == 1)
            bprint(PRINT_HIGH, ftos(f_votes_left), " more vote needed (/votenext)\n");
        else
            bprint(PRINT_HIGH, ftos(f_votes_left), " more votes needed (/votenext)\n");
    }
};

// opens the map voting for trick maps
// called from weapons.qc:ImpulseCommands()
void (entity pe_player) Vote_TrickMap = {
    local float f_votes, f_votes_needed, f_votes_left;

    if (clanbattle || vote_style)
        return;

    if (!pe_player.team_no || !pe_player.playerclass || pe_player.vote_trick)
        return;

    if (vote_started > 0) {
        sprint(pe_player, PRINT_HIGH, "There is already a vote in progress.\n");
        return;
    }

    if (vote_result != string_null) {
        sprint(pe_player, PRINT_HIGH, "Next map has already been voted to ", vote_result, ". Use /forcenext to force next map.\n");
        return;
    }
    pe_player.vote_trick = 1;
    pe_player.vote_race = 0;
    pe_player.vote_next = 0;

    bprint(PRINT_HIGH, pe_player.netname, " wants to vote for a trick map\n");

    f_votes = Vote_GetTrickVotes();
    f_votes_needed = ceil(TeamFortress_GetNoActivePlayers() / 2);
    f_votes_left = f_votes_needed - f_votes;
    if (f_votes >= f_votes_needed) {
        Vote_SetupVote(2);
        //dprint("[", ftos(time), "/cf/mapvote/votetrick]: forcing trick map vote.\n");
        bprint(PRINT_HIGH, "Commencing vote for trick map\n");
    } else {
        if (f_votes_left == 1)
            bprint(PRINT_HIGH, ftos(f_votes_left), " more vote needed (/votetrick)\n");
        else
            bprint(PRINT_HIGH, ftos(f_votes_left), " more votes needed (/votetrick)\n");
    }
};

// opens the map voting for race maps
// called from weapons.qc:ImpulseCommands()
void (entity pe_player) Vote_RaceMap = {
    local float f_votes, f_votes_needed, f_votes_left;

    if (clanbattle || vote_style)
        return;

    if (!pe_player.team_no || !pe_player.playerclass || pe_player.vote_race)
        return;

    if (vote_started > 0) {
        sprint(pe_player, PRINT_HIGH, "There is already a vote in progress.\n");
        return;
    }

    if (vote_result != string_null) {
        sprint(pe_player, PRINT_HIGH, "Next map has already been voted to ", vote_result, ". Use /forcenext to force next map.\n");
        return;
    }
    pe_player.vote_race = 1;
    pe_player.vote_trick = 0;
    pe_player.vote_next = 0;

    bprint(PRINT_HIGH, pe_player.netname, " wants to vote for a race map\n");

    f_votes = Vote_GetRaceVotes();
    f_votes_needed = ceil(TeamFortress_GetNoActivePlayers() / 2);
    f_votes_left = f_votes_needed - f_votes;
    if (f_votes >= f_votes_needed) {
        Vote_SetupVote(3);
        //dprint("[", ftos(time), "/cf/mapvote/voterace]: forcing race map vote.\n");
        bprint(PRINT_HIGH, "Commencing vote for race map\n");
    } else {
        if (f_votes_left == 1)
            bprint(PRINT_HIGH, ftos(f_votes_left), " more vote needed (/voterace)\n");
        else
            bprint(PRINT_HIGH, ftos(f_votes_left), " more votes needed (/voterace)\n");
    }
};

// opens/closes the currently active vote menu
// called from weapons.qc:ImpulseCommands()
void (entity pe_player) Vote_ToggleMenu = {

    if (clanbattle || vote_style)
        return;

    if (vote_started > 0 && !vote_abort) {
        if (pe_player.menu_input != Vote_Input) {
            //dprint("[", ftos(time), "/cf/mapvote/togglemenu]: toggling map vote on for ", pe_player.netname, ".\n");
            pe_player.menu_time = time;
            pe_player.vote_close = 0;
            Vote_Menu(pe_player);
        } else {
            //dprint("[", ftos(time), "/cf/mapvote/togglemenu]: toggling map vote off for ", pe_player.netname, ".\n");
            pe_player.vote_close = 1;
            Menu_Close(pe_player);
        }
    } else {
        sprint(pe_player, PRINT_HIGH, "There is no active map vote\n");
    }
}

// returns the total amount of vote_next votes
// called from Vote_NextMap()
float () Vote_GetNextVotes = {
    local entity e_player;
    local float f_count = 0;

    e_player = find(world, classname, "player");
    while (e_player != world) {
        if (e_player.vote_next == 1 && e_player.team_no && e_player.playerclass)
            f_count = f_count + 1;
        e_player = find(e_player, classname, "player");
    }

    return f_count;
};

// returns the total amount of vote_trick votes
// called from Vote_TrickMap()
float () Vote_GetTrickVotes = {
    local entity e_player;
    local float f_count = 0;

    e_player = find(world, classname, "player");
    while (e_player != world) {
        if (e_player.vote_trick == 1 && e_player.team_no && e_player.playerclass)
            f_count = f_count + 1;
        e_player = find(e_player, classname, "player");
    }

    return f_count;
};

// returns the total amount of vote_race votes
// called from Vote_RaceMap()
float () Vote_GetRaceVotes = {
    local entity e_player;
    local float f_count = 0;

    e_player = find(world, classname, "player");
    while (e_player != world) {
        if (e_player.vote_race == 1 && e_player.team_no && e_player.playerclass)
            f_count = f_count + 1;
        e_player = find(e_player, classname, "player");
    }

    return f_count;
};

// forces server to change map to next map
// called from weapons.qc:ImpulseCommands()
void (entity pe_player) Vote_ForceNext = {
    local float f_votes, f_votes_needed, f_votes_left;

    if (clanbattle || vote_style)
        return;

    if (!pe_player.team_no || !pe_player.playerclass)
        return;

    if (vote_result == string_null) {
        sprint(pe_player, PRINT_HIGH, "You can't force next map before voting for a new map. Use /votenext to issue a map vote.\n");
        return;
    }

    pe_player.force_next = 1;

    bprint(PRINT_HIGH, pe_player.netname, " wants to start playing ", vote_result, " now\n");

    f_votes = Vote_GetForceNextVotes();
    f_votes_needed = ceil(TeamFortress_GetNoActivePlayers() / 2);
    f_votes_left = f_votes_needed - f_votes;
    if (f_votes >= f_votes_needed) {
        Vote_SetupVote(0);
        //dprint("[", ftos(time), "/cf/mapvote/forcenext]: forcing next map: ", vote_result, "\n");
        bprint(PRINT_HIGH, "Changing level to ", vote_result, "\n");
        GotoNextMap();
    } else {
        if (f_votes_left == 1)
            bprint(PRINT_HIGH, ftos(f_votes_left), " more vote needed (/forcenext)\n");
        else
            bprint(PRINT_HIGH, ftos(f_votes_left), " more votes needed (/forcenext)\n");
    }
};

// returns the total amount of force_next votes
// called from Vote_ForceNext()
float () Vote_GetForceNextVotes = {
    local entity e_player;
    local float f_count = 0;

    e_player = find(world, classname, "player");
    while (e_player != world) {
        if (e_player.force_next == 1)
            f_count = f_count + 1;
        e_player = find(e_player, classname, "player");
    }

    return f_count;
};

// check if voting should start each frame
// called from world.qc:StartFrame()
void () Vote_Check = {

    if (clanbattle || vote_style)
        return;

    local float closetime = timelimit - CF_MAPVOTE_FINISH;
    local float decidertime_force = closetime - CF_MAPVOTE_FORCESHOW;
    local float decidertime = closetime - CF_MAPVOTE_DURATION_DECIDER;
    local float votetime_force = decidertime - CF_MAPVOTE_FORCESHOW;
    local float votetime = decidertime - CF_MAPVOTE_DURATION;

    // only run these checks once a second
    if (vote_started >= 0 && (time - vote_update) >= 1 && !vote_abort) {
        vote_update = time;

        if (time >= votetime && vote_started == 0) {
            //dprint("[", ftos(time), "/cf/mapvote/check]: setting up map vote.\n");
            Vote_SetupVote(0);
            bprint(PRINT_HIGH, "Time to vote for what map comes next\n");
            //dprint("[", ftos(time), "/cf/mapvote/check]: opening map vote.\n");
            Vote_MenuOpen(0);
            return;
        }

        // only try to force show vote menu if player is not newly spawned
        if (vote_started > 0 && (time - self.spawn_time) > CF_MAPVOTE_FORCESHOW) {
            if (time >= votetime_force && time < decidertime)
                Vote_MenuOpen(1);
            else if (time >= decidertime_force && time < closetime)
                Vote_MenuOpen(2);
        }

        if (vote_started > 0) {

            // open/close menus for those eligible
            Vote_MenuOpen(0);
            Vote_MenuClose();

            // when voting has been going on for CF_MAPVOTE_DURATION(_DECIDER) seconds or
            // if everyone's voted, decide winner or create decider vote
            if ((((!vote_decider && time >= decidertime) || (vote_decider && time >= closetime))
                        || Vote_GetVoteCount() == TeamFortress_GetNoActivePlayers())
                        && vote_result == string_null) {

                //dprint("[", ftos(time), "/cf/mapvote/check]: dropping losers.\n");
                Vote_DropLosers();

                // get winners/tied winners count
                if (!vote_winnercount)
                    vote_winnercount = Vote_GetWinnerCount();

                // create decider vote if there are more 2 or more winners
                if (!vote_decider && vote_winnercount >= 2 && Vote_GetWinnerVoteCount() < TeamFortress_GetNoActivePlayers()) {
                    //dprint("[", ftos(time), "/cf/mapvote/check]: setting up decider map vote.\n");
                    Vote_SetupVote(1); // 1 = decider vote
                    if (!vote_abort) {
                        bprint(PRINT_HIGH, "A winner could not be decided. Vote options have been updated.\n");
                        //dprint("[", ftos(time), "/cf/mapvote/check]: opening decider map vote.\n");
                        Vote_MenuOpen(0);
                    }
                    return;
                }

                vote_started = -1;
                Vote_MenuClose(); // close all open map votes

                // get the winner of the vote
                vote_result = Vote_GetWinner(); // returns a strzoned string
                //dprint("[", ftos(time), "/cf/mapvote/check]: next map will be ", vote_result, "\n");

                // release map names from memory
                Vote_ResetMapNames();

                bprint(PRINT_HIGH, "Voting has ended. The next map will be ", vote_result, "\n");
            }
        }
    }
};

// decides maps should be included in map voting
// pf_type: 0 = normal vote, 1 = decider vote, 2 = trick vote, 3 = race vote
// called from Vote_Check()
void (float pf_type) Vote_SetupVote = {
    vote_decider = 0;

    // set vote*_map variables to randomly selected maps from appropriate map list
    Vote_PopulateVoteList(pf_type);

    if (pf_type == 1) {
        vote_decider = 1;
    }
    Vote_ResetVotes();
    vote_started = time;

    if (vote1_map == string_null) {
        //dprint("[", ftos(time), "/cf/mapvote/setupvote]: no maps found. aborting.\n");
        vote_result = mapname;
        vote_abort = 1;
        return;
    }
};

// processes user input from Vote_Menu()
void (float pf_input) Vote_Input = {
    local string s_votedfor = "";

    // don't do anything if user votes on same map twice
    if (self.has_voted_map == pf_input)
        return;

    // remove vote if user changed his mind
    if (self.has_voted_map && pf_input >= 1 && pf_input <= 5)
        Vote_RemoveVote(self.has_voted_map);

    if (pf_input == 1) {
        if (vote1_map == string_null) {
            Vote_Menu(self);
            return;
        }
        s_votedfor = vote1_map;
        vote1_cnt = vote1_cnt + 1;
    } else if (pf_input == 2) {
        if (vote2_map == string_null) {
            Vote_Menu(self);
            return;
        }
        s_votedfor = vote2_map;
        vote2_cnt = vote2_cnt + 1;
    } else if (pf_input == 3) {
        if (vote3_map == string_null) {
            Vote_Menu(self);
            return;
        }
        s_votedfor = vote3_map;
        vote3_cnt = vote3_cnt + 1;
    } else if (pf_input == 4) {
        if (vote4_map == string_null) {
            Vote_Menu(self);
            return;
        }
        s_votedfor = vote4_map;
        vote4_cnt = vote4_cnt + 1;
    } else if (pf_input == 5) {
        s_votedfor = vote5_map;
        vote5_cnt = vote5_cnt + 1;
    }

    // update menu for all players (with active menus) on input
    if (pf_input >= 1 && pf_input <= 5) {
        //dprint("[", ftos(time), "/cf/mapvote/voteinput]: ", self.netname, " voted for ", s_votedfor, ".\n");
        sprint(self, PRINT_HIGH, "You voted for ", s_votedfor, "\n");
        self.has_voted_map = pf_input;
        if ((time - self.menu_time) <= CF_MAPVOTE_FORCESHOW)
            Vote_Menu(self);
        Vote_MenuOpen(0); // update
    } else
        Vote_Menu(self);
};

// opens map vote menu for newly spawned players who haven't voted yet
// called from Vote_Input(), Vote_Check()
void (float force) Vote_MenuOpen = {
    local float closetime = timelimit - CF_MAPVOTE_FINISH;
    local float decidertime_force = closetime - CF_MAPVOTE_FORCESHOW;
    local float decidertime = closetime - CF_MAPVOTE_DURATION_DECIDER;
    local float votetime_force = decidertime - CF_MAPVOTE_FORCESHOW;
    local entity e_player = find(world, classname, "player");

    while (e_player != world) {
        if (e_player.team_no && e_player.playerclass) {
            if (!e_player.has_voted_map && e_player.health && !e_player.vote_close) {
                if (((time - e_player.spawn_time) <= CF_MAPVOTE_FORCESHOW || (time - e_player.menu_time) <= CF_MAPVOTE_FORCESHOW)
                            && !force) {
                    //dprint("[", ftos(time), "/cf/mapvote/menuopen]: open vote menu for newly spawned ", e_player.netname, ".\n");
                    if (!e_player.menu_time || e_player.menu_time < (time - CF_MAPVOTE_FORCESHOW))
                        e_player.menu_time = time;
                    Vote_Menu(e_player);
                } else if (force == 1) {
                    if (e_player.menu_input != Vote_Input) {
                        //dprint("[", ftos(time), "/cf/mapvote/menuopen]: forcing vote menu on ", e_player.netname, ".\n");
                        sprint(e_player, PRINT_HIGH, "You haven't voted yet, please vote\n");
                    }
                    if (e_player.menu_time < (time - CF_MAPVOTE_FORCESHOW) && e_player.menu_time < votetime_force)
                        e_player.menu_time = time;
                    Vote_Menu(e_player);
                } else if (force == 2) {
                    if (e_player.menu_input != Vote_Input) {
                        //dprint("[", ftos(time), "/cf/mapvote/menuopen]: forcing decider vote menu on ", e_player.netname, ".\n");
                        sprint(e_player, PRINT_HIGH, "You haven't voted yet, please vote\n");
                    }
                    if (e_player.menu_time < (time - CF_MAPVOTE_FORCESHOW) && e_player.menu_time < decidertime_force)
                        e_player.menu_time = time;
                    Vote_Menu(e_player);
                }
            } else if (e_player.menu_input == Vote_Input && (time - e_player.menu_time) <= CF_MAPVOTE_FORCESHOW)
                Vote_Menu(e_player);
        }
        e_player = find(e_player, classname, "player");
    }
};

// closes map vote menu when vote is over or for anyone who's been alive >CF_MAPVOTE_FORCESHOW seconds
// called from Vote_Check()
void () Vote_MenuClose = {
    local entity e_player = find(world, classname, "player");

    while (e_player != world) {
        if (vote_started == -1 && e_player.menu_input == Vote_Input) {
            //dprint("[", ftos(time), "/cf/mapvote/menuclose]: vote over, closing vote menu for ", e_player.netname, ".\n");
            Menu_Close(e_player);
        } else if (e_player.menu_input == Vote_Input && (time - e_player.menu_time) > CF_MAPVOTE_FORCESHOW) {
            if ((time - e_player.menu_time) > CF_MAPVOTE_FORCESHOW) {
                //dprint("[", ftos(time), "/cf/mapvote/menuclose]: closing vote menu for ", e_player.netname, ".\n");
                e_player.menu_time = 0;
                Menu_Close(e_player);
            }
        }
        e_player = find(e_player, classname, "player");
    }
};

// shows the map vote menu
// called from Vote_Input(), Menu_Open()
void (entity pe_player) Vote_Menu = {
    local string s_choose, s_vote1, s_vote2, s_vote3, s_vote4, s_vote5;
    local string s_tmp1, s_tmp2, s_tmp3, s_tmp4, s_tmp5;
    local float f_width = 0, f_timeleft = 0;
    local float closetime = timelimit - CF_MAPVOTE_FINISH;
    local float decidertime_force = closetime - CF_MAPVOTE_FORCESHOW;
    local float decidertime = closetime - CF_MAPVOTE_DURATION_DECIDER;
    local float votetime_force = decidertime - CF_MAPVOTE_FORCESHOW;
    local float votetime = decidertime - CF_MAPVOTE_DURATION;

    if ((time < closetime && (pe_player.menu_time + CF_MAPVOTE_FORCESHOW) >= decidertime_force)
                || (time < decidertime_force && (pe_player.menu_time + CF_MAPVOTE_FORCESHOW) >= decidertime_force))
        f_timeleft = closetime - time;
    else if ((time < decidertime && (pe_player.menu_time + CF_MAPVOTE_FORCESHOW) >= decidertime)
                || (time < votetime_force && (pe_player.menu_time + CF_MAPVOTE_FORCESHOW) >= votetime_force))
        f_timeleft = decidertime - time;
    else if ((time >= decidertime && time < closetime) || (time >= votetime && time < decidertime))
        f_timeleft = CF_MAPVOTE_FORCESHOW - (time - pe_player.menu_time);
    else if (time - pe_player.menu_time < CF_MAPVOTE_FORCESHOW)
        f_timeleft = CF_MAPVOTE_FORCESHOW - (time - pe_player.menu_time);

    if(infokeyf(pe_player, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(pe_player);
        pe_player.vote_close = 1;
        UpdateClientMenu_Vote(pe_player, floor(f_timeleft - 0.1));
        return;
    }

    s_choose = strzone(strcat("Vote for next map (closes in ", strcat(ftos(floor(f_timeleft - 0.1)), "s):\n\n")));
    s_tmp1 = strzone("");
    s_tmp2 = strzone("");
    s_tmp3 = strzone("");
    s_tmp4 = strzone("");
    s_tmp5 = strzone("");

    if (vote1_map != string_null) {
        strunzone(s_tmp1);
        s_tmp1 = strcat(Q"\s[1]\s ", vote1_map);
        if (vote1_cnt)
            s_tmp1 = strzone(strcat(s_tmp1, strcat(" (", strcat(ftos(vote1_cnt), " votes)"))));
        else
            s_tmp1 = strzone(strcat(s_tmp1, "          "));

        if (strlen(s_tmp1) > f_width) f_width = strlen(s_tmp1);
    }
    if (vote2_map != string_null) {
        strunzone(s_tmp2);
        s_tmp2 = strcat(Q"\s[2]\s ", vote2_map);
        if (vote2_cnt)
            s_tmp2 = strzone(strcat(s_tmp2, strcat(" (", strcat(ftos(vote2_cnt), " votes)"))));
        else
            s_tmp2 = strzone(strcat(s_tmp2, "          "));

        if (strlen(s_tmp2) > f_width) f_width = strlen(s_tmp2);
    }
    if (vote3_map != string_null) {
        strunzone(s_tmp3);
        if (!vote_decider || vote3_cnt)
            s_tmp3 = strcat(Q"\s[3]\s ", vote3_map);
        if (vote3_cnt)
            s_tmp3 = strzone(strcat(s_tmp3, strcat(" (", strcat(ftos(vote3_cnt), " votes)"))));
        else
            s_tmp3 = strzone(strcat(s_tmp3, "          "));

        if (strlen(s_tmp3) > f_width) f_width = strlen(s_tmp3);
    }
    if (vote4_map != string_null) {
        strunzone(s_tmp4);
        if (!vote_decider || vote4_cnt)
            s_tmp4 = strcat(Q"\s[4]\s ", vote4_map);
        if (vote4_cnt)
            s_tmp4 = strzone(strcat(s_tmp4, strcat(" (", strcat(ftos(vote4_cnt), " votes)"))));
        else
            s_tmp4 = strzone(strcat(s_tmp4, "          "));

        if (strlen(s_tmp4) > f_width) f_width = strlen(s_tmp4);
    }
    if (vote5_map != string_null) {
        strunzone(s_tmp5);
        if (!vote_decider || vote5_cnt)
            s_tmp5 = strcat(Q"\s[5]\s ", vote5_map);
        if (vote5_cnt)
            s_tmp5 = strzone(strcat(s_tmp5, strcat(" (", strcat(ftos(vote5_cnt), " votes)"))));
        else
            s_tmp5 = strzone(strcat(s_tmp5, "          "));

        if (strlen(s_tmp5) > f_width) f_width = strlen(s_tmp5);
    }

    s_vote1 = strzone(strpadr(s_tmp1, f_width));
    s_vote2 = strzone(strpadr(s_tmp2, f_width));
    s_vote3 = strzone(strpadr(s_tmp3, f_width));
    s_vote4 = strzone(strpadr(s_tmp4, f_width));
    s_vote5 = strzone(strpadr(s_tmp5, f_width));

    Status_Menu(pe_player, Vote_Input, s_choose, s_vote1, "\n", s_vote2, "\n", s_vote3, "\n", s_vote4, "\n\n", s_vote5, "\n");
    strunzone(s_choose); strunzone(s_vote1); strunzone(s_vote2); strunzone(s_vote3); strunzone(s_vote4); strunzone(s_vote5);
    strunzone(s_tmp1); strunzone(s_tmp2); strunzone(s_tmp3); strunzone(s_tmp4); strunzone(s_tmp5);
};

// removes a vote (if a user changes his mind)
// called from Vote_Input()
void (float pf_input) Vote_RemoveVote = {
    local string s_map = "";

    if (pf_input == 1) {
        vote1_cnt = vote1_cnt - 1;
        s_map = vote1_map;
    } else if (pf_input == 2) {
        vote2_cnt = vote2_cnt - 1;
        s_map = vote2_map;
    } else if (pf_input == 3) {
        vote3_cnt = vote3_cnt - 1;
        s_map = vote3_map;
    } else if (pf_input == 4) {
        vote4_cnt = vote4_cnt - 1;
        s_map = vote4_map;
    } else if (pf_input == 5) {
        vote5_cnt = vote5_cnt - 1;
        s_map = vote5_map;
    }

    //dprint("[", ftos(time), "/cf/mapvote/removevote]: removing vote from ", s_map, ".\n");
};

// populates vote*_map variables
// called from Vote_SetupVote()
void (float pf_type) Vote_PopulateVoteList = {
    local float f_count, f_count1, f_count2, f_count3, f_count4, f_count5, f_count6, f_count7, f_count8, f_next, rand, i;
    local float f_range1, f_range2, f_range3, f_range4, f_range5, f_range6, f_range7, f_range8;
    local string s_maplist1 = "", s_maplist2 = "", s_maplist3 = "", s_maplist4 = "", s_maplist5 = "", s_maplist6 = "", s_maplist7 = "", s_maplist8 = "", s_map;
    local string s_tmp, s_tmp1, s_tmp2, s_tmp3, s_tmp4, s_tmp5, s_tmp6, s_tmp7, s_tmp8;

    // initialize trick map variables
    s_tmp5 = strzone("");
    s_tmp6 = strzone("");
    s_tmp7 = strzone("");
    s_tmp8 = strzone("");

    // regular map vote
    if (pf_type <= 1) {

        local float f_players = TeamFortress_GetNoPlayers();

        if (f_players <= 2) {
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: using tiny votelist.\n");
            s_tmp1 = strzone(infokey(world, "votelist_tiny1"));
            s_tmp2 = strzone(infokey(world, "votelist_tiny2"));
            s_tmp3 = strzone(infokey(world, "votelist_tiny3"));
            s_tmp4 = strzone(infokey(world, "votelist_tiny4"));
        } else if (f_players <= 4) {
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: using small votelist.\n");
            s_tmp1 = strzone(infokey(world, "votelist_small1"));
            s_tmp2 = strzone(infokey(world, "votelist_small2"));
            s_tmp3 = strzone(infokey(world, "votelist_small3"));
            s_tmp4 = strzone(infokey(world, "votelist_small4"));
        } else if (f_players <= 6) {
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: using medium votelist.\n");
            s_tmp1 = strzone(infokey(world, "votelist_medium1"));
            s_tmp2 = strzone(infokey(world, "votelist_medium2"));
            s_tmp3 = strzone(infokey(world, "votelist_medium3"));
            s_tmp4 = strzone(infokey(world, "votelist_medium4"));
        } else if (f_players <= 8) {
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: using large votelist.\n");
            s_tmp1 = strzone(infokey(world, "votelist_large1"));
            s_tmp2 = strzone(infokey(world, "votelist_large2"));
            s_tmp3 = strzone(infokey(world, "votelist_large3"));
            s_tmp4 = strzone(infokey(world, "votelist_large4"));
        } else if (f_players <= 12) {
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: using xlarge votelist.\n");
            s_tmp1 = strzone(infokey(world, "votelist_xlarge1"));
            s_tmp2 = strzone(infokey(world, "votelist_xlarge2"));
            s_tmp3 = strzone(infokey(world, "votelist_xlarge3"));
            s_tmp4 = strzone(infokey(world, "votelist_xlarge4"));
        } else if (f_players <= 14) {
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: using xxl votelist.\n");
            s_tmp1 = strzone(infokey(world, "votelist_xxl1"));
            s_tmp2 = strzone(infokey(world, "votelist_xxl2"));
            s_tmp3 = strzone(infokey(world, "votelist_xxl3"));
            s_tmp4 = strzone(infokey(world, "votelist_xxl4"));
        } else if (f_players <= 16) {
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: using xxxl votelist.\n");
            s_tmp1 = strzone(infokey(world, "votelist_xxxl1"));
            s_tmp2 = strzone(infokey(world, "votelist_xxxl2"));
            s_tmp3 = strzone(infokey(world, "votelist_xxxl3"));
            s_tmp4 = strzone(infokey(world, "votelist_xxxl4"));
        } else {
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: using xxxxl votelist.\n");
            s_tmp1 = strzone(infokey(world, "votelist_xxxxl1"));
            s_tmp2 = strzone(infokey(world, "votelist_xxxxl2"));
            s_tmp3 = strzone(infokey(world, "votelist_xxxxl3"));
            s_tmp4 = strzone(infokey(world, "votelist_xxxxl4"));
        }

    // trick vote
    } else if (pf_type == 2) {
        //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: using trick votelist.\n");
        strunzone(s_tmp5); strunzone(s_tmp6); strunzone(s_tmp7); strunzone(s_tmp8);
        s_tmp1 = strzone(infokey(world, "votelist_trick1"));
        s_tmp2 = strzone(infokey(world, "votelist_trick2"));
        s_tmp3 = strzone(infokey(world, "votelist_trick3"));
        s_tmp4 = strzone(infokey(world, "votelist_trick4"));
        s_tmp5 = strzone(infokey(world, "votelist_trick5"));
        s_tmp6 = strzone(infokey(world, "votelist_trick6"));
        s_tmp7 = strzone(infokey(world, "votelist_trick7"));
        s_tmp8 = strzone(infokey(world, "votelist_trick8"));

    // race vote
    } else {
        //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: using race votelist.\n");
        s_tmp1 = strzone(infokey(world, "votelist_race1"));
        s_tmp2 = strzone(infokey(world, "votelist_race2"));
        s_tmp3 = strzone(infokey(world, "votelist_race3"));
        s_tmp4 = strzone(infokey(world, "votelist_race4"));
    }
    vote_started = time;

    // filter out current map from map lists
    s_maplist1 = Vote_StripMap(mapname, s_tmp1);
    s_maplist2 = Vote_StripMap(mapname, s_tmp2);
    s_maplist3 = Vote_StripMap(mapname, s_tmp3);
    s_maplist4 = Vote_StripMap(mapname, s_tmp4);
    s_maplist5 = Vote_StripMap(mapname, s_tmp5);
    s_maplist6 = Vote_StripMap(mapname, s_tmp6);
    s_maplist7 = Vote_StripMap(mapname, s_tmp7);
    s_maplist8 = Vote_StripMap(mapname, s_tmp8);

    // calculate odds for each maplist
    f_count1 = List_Count(s_maplist1);
    f_count2 = List_Count(s_maplist2);
    f_count3 = List_Count(s_maplist3);
    f_count4 = List_Count(s_maplist4);
    f_count5 = List_Count(s_maplist5);
    f_count6 = List_Count(s_maplist6);
    f_count7 = List_Count(s_maplist7);
    f_count8 = List_Count(s_maplist8);
    f_count = f_count1 + f_count2 + f_count3 + f_count4 + f_count5 + f_count6 + f_count7 + f_count8;
    f_range1 = f_count1 / f_count * 100;
    f_range2 = f_range1 + (f_count2 / f_count * 100);
    f_range3 = f_range2 + (f_count3 / f_count * 100);
    f_range4 = f_range3 + (f_count4 / f_count * 100);
    f_range5 = f_range4 + (f_count5 / f_count * 100);
    f_range6 = f_range5 + (f_count6 / f_count * 100);
    f_range7 = f_range6 + (f_count7 / f_count * 100);
    f_range8 = f_range7 + (f_count8 / f_count * 100);

    for (i = 0; i < 4; i++) {

        rand = random() * 100;
        if (rand <= f_range1) {
            f_count1 = f_count1 - 1;
            f_next = RandomRange(0, f_count1);
            s_map = List_Index(s_maplist1, f_next); // returns a strzoned string
            s_tmp = s_maplist1;
            s_maplist1 = Vote_StripMap(s_map, s_maplist1);
        } else if (rand <= f_range2) {
            f_count2 = f_count2 - 1;
            f_next = RandomRange(0, f_count2);
            s_map = List_Index(s_maplist2, f_next); // returns a strzoned string
            s_tmp = s_maplist2;
            s_maplist2 = Vote_StripMap(s_map, s_maplist2);
        } else if (rand <= f_range3) {
            f_count3 = f_count3 - 1;
            f_next = RandomRange(0, f_count3);
            s_map = List_Index(s_maplist3, f_next); // returns a strzoned string
            s_tmp = s_maplist3;
            s_maplist3 = Vote_StripMap(s_map, s_maplist3);
        } else if (rand <= f_range4) {
            f_count4 = f_count4 - 1;
            f_next = RandomRange(0, f_count4);
            s_map = List_Index(s_maplist4, f_next); // returns a strzoned string
            s_tmp = s_maplist4;
            s_maplist4 = Vote_StripMap(s_map, s_maplist4);
        } else if (rand <= f_range5) {
            f_count5 = f_count5 - 1;
            f_next = RandomRange(0, f_count5);
            s_map = List_Index(s_maplist5, f_next); // returns a strzoned string
            s_tmp = s_maplist5;
            s_maplist5 = Vote_StripMap(s_map, s_maplist5);
        } else if (rand <= f_range6) {
            f_count6 = f_count6 - 1;
            f_next = RandomRange(0, f_count6);
            s_map = List_Index(s_maplist6, f_next); // returns a strzoned string
            s_tmp = s_maplist6;
            s_maplist6 = Vote_StripMap(s_map, s_maplist6);
        } else if (rand <= f_range7) {
            f_count7 = f_count7 - 1;
            f_next = RandomRange(0, f_count7);
            s_map = List_Index(s_maplist7, f_next); // returns a strzoned string
            s_tmp = s_maplist7;
            s_maplist7 = Vote_StripMap(s_map, s_maplist7);
        } else {
            f_count8 = f_count8 - 1;
            f_next = RandomRange(0, f_count8);
            s_map = List_Index(s_maplist8, f_next); // returns a strzoned string
            s_tmp = s_maplist8;
            s_maplist8 = Vote_StripMap(s_map, s_maplist8);
        }

        if (i == 0) {
            vote1_map = s_map;
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: adding map1: ", vote1_map, "\n");
        } else if (i == 1) {
            vote2_map = s_map;
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: adding map2: ", vote2_map, "\n");
        } else if (i == 2) {
            vote3_map = s_map;
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: adding map3: ", vote3_map, "\n");
        } else if (i == 3) {
            vote4_map = s_map;
            //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: adding map4: ", vote4_map, "\n");
        }

        // recalculate odds
        f_count = f_count1 + f_count2 + f_count3 + f_count4 + f_count5 + f_count6 + f_count7 + f_count8;
        f_range1 = f_count1 / f_count * 100;
        f_range2 = f_range1 + (f_count2 / f_count * 100);
        f_range3 = f_range2 + (f_count3 / f_count * 100);
        f_range4 = f_range3 + (f_count4 / f_count * 100);
        f_range5 = f_range4 + (f_count5 / f_count * 100);
        f_range6 = f_range5 + (f_count6 / f_count * 100);
        f_range7 = f_range6 + (f_count7 / f_count * 100);
        f_range8 = f_range7 + (f_count8 / f_count * 100);

        strunzone(s_tmp);
    }
    vote5_map = strzone(mapname);
    //dprint("[", ftos(time), "/cf/mapvote/populatevotelist]: adding map5: ", vote5_map, "\n");
    strunzone(s_maplist1); strunzone(s_maplist2); strunzone(s_maplist3); strunzone(s_maplist4);
    strunzone(s_maplist5); strunzone(s_maplist6); strunzone(s_maplist7); strunzone(s_maplist8);
    strunzone(s_tmp1); strunzone(s_tmp2); strunzone(s_tmp3); strunzone(s_tmp4);
    strunzone(s_tmp5); strunzone(s_tmp6); strunzone(s_tmp7); strunzone(s_tmp8);
};

// strips a map from a given list of maps
// called from Vote_PopulateVoteList()
string (string ps_map, string ps_maplist) Vote_StripMap = {
    local float f_count, i;
    local string s_tmp;

    f_count = List_Count(ps_maplist);

    // remove current map from list, strzone hack needed because limited string buffer
    s_tmp = strzone("");
    for (i = 0; i < f_count; i++) {
        local string map = List_Index(ps_maplist, i); // returns a strzoned string
        if (map != ps_map) {
            local string tmp_old = s_tmp;
            s_tmp = strzone(strcat(s_tmp, strcat(map, " ")));
            strunzone(tmp_old);
        }
        strunzone(map);
    }

    return s_tmp;
};

// resets map voting
// called from world.qc:worldspawn()
void () Vote_Reset = {
    vote_started = 0;
    vote_update = 0;
    vote_winnercount = 0;
    vote_abort = 0;
    vote_result = string_null;

    Vote_ResetMapNames();
    Vote_ResetVotes();
};

// resets players' vote status & map vote count
// called from Vote_SetupVote(), Vote_Reset()
void () Vote_ResetVotes = {
    local entity e_player;

    e_player = find(world, classname, "player");
    while (e_player != world) {
        e_player.has_voted_map = 0;
        e_player = find(e_player, classname, "player");
    }

    vote1_cnt = vote2_cnt = vote3_cnt = vote4_cnt = vote5_cnt = 0;
};

// resets map names
// called from Vote_Check(), Vote_Reset()
void () Vote_ResetMapNames = {
    //dprint("[", ftos(time), "/cf/mapvote/resetmapnames]: resetting map names.\n");

    if (vote1_map != string_null) { strunzone(vote1_map); vote1_map = string_null; }
    if (vote2_map != string_null) { strunzone(vote2_map); vote2_map = string_null; }
    if (vote3_map != string_null) { strunzone(vote3_map); vote3_map = string_null; }
    if (vote4_map != string_null) { strunzone(vote4_map); vote4_map = string_null; }
    if (vote5_map != string_null) { strunzone(vote5_map); vote5_map = string_null; }
}

// returns the total amount of votes
// called from Vote_Check()
float () Vote_GetVoteCount = {
    return (vote1_cnt + vote2_cnt + vote3_cnt + vote4_cnt + vote5_cnt);
};

// returns the winner count (>1 if there's a tie)
// called from Vote_Check()
float () Vote_GetWinnerCount = {
    local float f_count;

    f_count = 0;
    if (vote1_cnt) f_count = f_count + 1;
    if (vote2_cnt) f_count = f_count + 1;
    if (vote3_cnt) f_count = f_count + 1;
    if (vote4_cnt) f_count = f_count + 1;
    if (vote5_cnt) f_count = f_count + 1;

    return f_count;
};

// returns the amount of votes on the winning maps
// called from Vote_Check()
float () Vote_GetWinnerVoteCount = {
    local float f_count;

    f_count = 0;
    if (vote1_cnt) f_count = f_count + vote1_cnt;
    if (vote2_cnt) f_count = f_count + vote2_cnt;
    if (vote3_cnt) f_count = f_count + vote3_cnt;
    if (vote4_cnt) f_count = f_count + vote4_cnt;
    if (vote5_cnt) f_count = f_count + vote5_cnt;

    return f_count;
};

// returns the winner based on votes
// called from Vote_Check()
string () Vote_GetWinner = {
    local string s_maplist, s_result;

    s_maplist = Vote_GetWinnerList();

    if (s_maplist != string_null)
        s_result = Vote_RandomWinner(s_maplist); // returns a strzoned string
    else
        s_result = mapname; // returns a strzoned string

    return s_result;
};

// returns a list of winners
// called from Vote_SetupVote(), Vote_GetWinner()
string () Vote_GetWinnerList = {
    local string s_maplist;
    local string s_tmp;

    s_maplist = strzone("");
    if (vote1_cnt) {
        s_tmp = s_maplist;
        s_maplist = strzone(strcat(s_maplist, strcat(vote1_map, " ")));
        strunzone(s_tmp);
    }
    if (vote2_cnt) {
        s_tmp = s_maplist;
        s_maplist = strzone(strcat(s_maplist, strcat(vote2_map, " ")));
        strunzone(s_tmp);
    }
    if (vote3_cnt) {
        s_tmp = s_maplist;
        s_maplist = strzone(strcat(s_maplist, strcat(vote3_map, " ")));
        strunzone(s_tmp);
    }
    if (vote4_cnt) {
        s_tmp = s_maplist;
        s_maplist = strzone(strcat(s_maplist, strcat(vote4_map, " ")));
        strunzone(s_tmp);
    }
    if (vote5_cnt) {
        s_tmp = s_maplist;
        s_maplist = strzone(strcat(s_maplist, vote5_map));
        strunzone(s_tmp);
    }

    //dprint("[", ftos(time), "/cf/mapvote/getwinnerlist]: winner list: ", s_maplist, "\n");
    return s_maplist;
};

// returns a random winner from a list of maps
// called from Vote_GetWinner()
string (string ps_maplist) Vote_RandomWinner = {
    local float f_idx, f_count;
    local string s_winner;

    f_count = List_Count(ps_maplist) - 1;
    f_idx = RandomRange(0, f_count);
    s_winner = List_Index(ps_maplist, f_idx); // returns a strzoned string

    //dprint("[", ftos(time), "/cf/mapvote/randomwinner]: random winner: ", s_winner, "\n");
    return s_winner;
};

// returns a random number between from and to
// called from Vote_GetWinner(), Vote_PopulateVoteList()
float (float from, float to) RandomRange = {
    return from + floor(random() * ((to - from) + 1));
};

// sets vote count for all losers to 0
// called from Vote_GetWinnerCount(), Vote_GetWinnerVoteCount(), Vote_GetWinner(), Vote_GetWinnerList()
void () Vote_DropLosers = {
    if (vote2_cnt > vote1_cnt || vote3_cnt > vote1_cnt || vote4_cnt > vote1_cnt || vote5_cnt > vote1_cnt)
        vote1_cnt = 0;
    if (vote1_cnt > vote2_cnt || vote3_cnt > vote2_cnt || vote4_cnt > vote2_cnt || vote5_cnt > vote2_cnt)
        vote2_cnt = 0;
    if (vote1_cnt > vote3_cnt || vote2_cnt > vote3_cnt || vote4_cnt > vote3_cnt || vote5_cnt > vote3_cnt)
        vote3_cnt = 0;
    if (vote1_cnt > vote4_cnt || vote2_cnt > vote4_cnt || vote3_cnt > vote4_cnt || vote5_cnt > vote4_cnt)
        vote4_cnt = 0;
    if (vote1_cnt > vote5_cnt || vote2_cnt > vote5_cnt || vote3_cnt > vote5_cnt || vote4_cnt > vote5_cnt)
        vote5_cnt = 0;
};

// returns list item count in list
// called from Vote_PopulateVoteList(), Vote_RandomWinner()
float (string ps_list) List_Count = {
    local float i;
    local float f_count = 0;
    local float f_length = strlen(ps_list);
    local string s_previous = " ";

    for (i = 0; i < f_length; i++) {
        // set current character
        local string s_current = substr(ps_list, i, 1);

        // non-empty space => word
        if (s_current != " " && s_previous == " ")
            f_count = f_count + 1;

        s_previous = s_current;
    }

    return f_count;
};

// returns the nth list item in a given list
// called from Vote_PopulateVoteList(), Vote_RandomWinner()
string (string ps_list, float pf_idx) List_Index = {
    local float i;
    local float f_count = 0;
    local float f_start = -1;
    local float f_length = strlen(ps_list);
    local string s_previous = " ";

    for (i = 0; i < f_length; i++) {
        // set current character
        local string s_current = substr(ps_list, i, 1);

        // non-empty space => start of word
        if (s_current != " " && s_previous == " ") {
            if (f_count == pf_idx)
                f_start = i;
            f_count = f_count + 1;
        }

        // empty space => end of word
        if (s_current == " " && f_start > -1)
            return strzone(substr(ps_list, f_start, i - f_start));

        s_previous = s_current;
    }

    // if f_start is set it means a list item was found
    if (f_start > -1)
        return strzone(substr(ps_list, f_start, i - f_start));

    return strzone(string_null);
};


/* ====== New Vote System ======= */

/*
"netname" "amth1" //map name
"broadcast" "Duel arena, ctf and Sniper War" //description
"team_broadcast" "Duel/Arena" //group
"ex_skill_min" "2" //min players
"ex_skill_max" "8" //max players
"team_no" "4" //supported teams
 
.cnt = number of current votes
*/

entity (string name) AddVoteMapGroup = {
    if(!name) {
        return world;
    }
    local entity mg = find(world, classname, "map_group");
    while(mg) {
        if(mg.netname == name) {
            return mg;
        }
        mg = find(mg, classname, "map_group");
    }
    
    mg = spawn();
    mg.classname = "map_group";
    mg.netname = name;
    return mg;
};

entity (string name, string desc, string mapgroup, float num_teams, float min_players, float max_players) AddVoteMap = {
    if(!name) {
        return world;
    }
    local entity mc = find(world, classname, "map_candidate");
    while(mc) {
        if(mc.netname == name) {
            return mc;
        }
        mc = find(mc, classname, "map_candidate");
    }

    mc = spawn();
    mc.classname = "map_candidate";
    mc.netname = name;
    mc.broadcast = desc;
    mc.team_broadcast = mapgroup;
    mc.owner = AddVoteMapGroup(mapgroup);
    mc.team_no = num_teams?num_teams:2;
    mc.ex_skill_min = min_players?min_players:6;
    mc.ex_skill_max = max_players?max_players:16;
    UpdateClient_VoteMap_Add_Broadcast(mc);
    return mc;
};

float (string name) RemoveVoteMap = {
    if(!name) {
        return FALSE;
    }
    local entity mc = find(world, classname, "map_candidate");
    while(mc) {
        if(mc.netname == name) {
            UpdateClient_VoteMap_Delete_Broadcast(mc);
            dremove(mc);
            return TRUE;
        }
        mc = find(mc, classname, "map_candidate");
    }
    return FALSE;
}

void() map_candidate_use = {
    if(activator && activator.classname == "player") {
        VoteForMap(activator, self.netname);
    }
}

void() map_candidate = {
    if(self.team_broadcast && self.team_broadcast != "") {
        self.owner = AddVoteMapGroup(self.team_broadcast);
    }
    self.use = map_candidate_use;
};

void () InitVoteMaps = {
    string votemap = FO_GetUserSettingString(world, "vote_map", "votemap", "se2");
    //No point adding the vote map if it is the current one, and thus known to be missing the ents
    if(votemap != mapname) {
        //Otherwise, assume we somehow ended up on the wrong map and offer to vote for the correct one
        local entity mc = spawn();
        mc.classname = "map_candidate";
        mc.netname = votemap;
        mc.broadcast = "Currently configured vote map";
    }
    AddVoteMap("2fort5r", "Basic CTF", "CTF", 2, 8, 20);
    AddVoteMap("1on1r", "Basic Duel", "Duel", 2, 2, 2);
    AddVoteMap("sq1", "Basic Arena", "Arena", 2, 2, 8);
    AddVoteMap("mbasesr", "Futuristic CTF", "CTF", 2, 6, 16);
    AddVoteMap("amth1", "Basic Everything", "Duel", 4, 2, 8);
    AddVoteMap("well6", "The Well (6)", "CTF", 2, 6, 20);
    AddVoteMap("genders2", "Small CTF", "CTF", 2, 6, 20);
    AddVoteMap("frozen1", "CTF with buttons", "CTF", 2, 6, 16);
};

void (entity p) ListVoteMaps = {
    sprint(p, PRINT_HIGH, "Maps eligible for voting:\n");
    local entity mc = find(world, classname, "map_candidate");
    while(mc) {
        sprint(p, PRINT_HIGH, "\b", mc.netname, "\b: ", mc.broadcast, "\n");
        mc = find(mc, classname, "map_candidate");
    }
    sprint(p, PRINT_HIGH, "Use \bcmd votemap <mapname>\b to cast your vote.\n");
};

void () anarchy_timer_think = {
    local entity e = find(world, classname, "player");
    while(e) {
        if(e.vote_map) {
            e.items |= IT_QUAD;
            e.tfstate &= 128;
            e.super_damage_finished = time + 666;
            //e.effects = e.effects | EF_BLUE;
        }
        TeamFortress_SetSpeed(e);
        e = find(e, classname, "player");
    }
};

void () AnarchyMode = {
    if(vote_anarchy_mode || !voting_started || vote_total_votes <= 0)
        return;
    vote_anarchy_mode = TRUE;
    local entity e = find(world, classname, "player");
    while(e) {
        e.items_allowed = IT_AXE | IT_QUAD;
        e.items = IT_AXE;
        e.weapons_carried = IT_AXE;
        e.current_weapon = WEAP_AXE;
        if(e.vote_map) {
            e.items |= IT_QUAD;
            e.tfstate &= 128;
            e.super_damage_finished = time + 666;
            //e.effects = e.effects | EF_BLUE;
        }
        W_SetCurrentAmmo(e);
        TeamFortress_SetSpeed(e);
        e = find(e, classname, "player");
    }
    bprint(PRINT_HIGH, "\bDemocracy has failed!\b Let the result be decided in \bBATTLE\b\n");
    FO_Sound(self, CHAN_AUTO, "boss1/out1.wav", 1, ATTN_NONE);
    //e = spawn();
    //e.classname = "anarchy_timer";
    //e.think = anarchy_timer_think;
    //e.nextthink = time + 1;
};

void () EndVoting = {
    voting_started = FALSE;
    vote_anarchy_mode = FALSE;
    vote_total_votes = 0;
    local entity e = find(world, classname, "vote_timer");
    if(e) {
        dremove(e);
    }
    e = find(world, classname, "anarchy_timer");
    if(e) {
        dremove(e);
    }
    e = find(world, classname, "player");
    while(e) {
        e.vote_map = world;
        e.items = 0;
        e.weapons_carried = 0;
        e.current_weapon = 0;
        e.super_damage_finished = 0;
        //if(e.effects & EF_BLUE) e.effects = e.effects - EF_BLUE;
        W_SetCurrentAmmo(e);
        TeamFortress_SetSpeed(e);
        e.health = 100;
        e = find(e, classname, "player");
    }
    e = find(world, classname, "map_candidate");
    while(e) {
        e.cnt = 0;
        UpdateAllClientMapVotes(e);
        e = find(e, classname, "map_candidate");
    }
};

void (string map_name) ChangeToVotedMap = {
    vote_result = map_name;
    nextmap = map_name;
//    if(!votemode) {
//        votemode = 2;
//    }
    EndVoting();
    //GotoNextMap();
    execute_changelevel();
};

float () CheckVoting = {
    if(intermission_running || vote_result) {
        return FALSE;
    }
    local float totalplayers = 0, numplayers = 0, votedplayers = 0, prettythreshold = 0;
    local entity e = find(world, classname, "player");
    while(e) {
        if(!e.has_disconnected) {
            totalplayers++;
            if(e.health > 0 || !vote_anarchy_mode) {
                numplayers++;
                if(e.vote_map) {
                    votedplayers++;
                }
            }
        }
        e = find(e, classname, "player");
    }
    
    if(numplayers <= 0 || votedplayers <= 0) {
        bprint(PRINT_HIGH, "\bVoting reset...\b\n");
        FO_Sound(self, CHAN_AUTO, "items/qpi2.wav", 1, ATTN_NONE);
        EndVoting();
        return FALSE;
    }
    
    prettythreshold = ceil(numplayers * vote_threshold);
    if(prettythreshold == (numplayers * vote_threshold)) {
        //divides evenly, but need a strict excess, but written in integers
        prettythreshold++;
    }
    
    if(!votemode) bprint(PRINT_HIGH, "\bCurrent votes (total of \b",ftos(prettythreshold),"\b needed to change):\b\n");
    e = find(world, classname, "map_candidate");
    while(e) {
        if(e.cnt > 0 && !votemode) {
            bprint(PRINT_HIGH, "", e.netname, ": ", ftos(e.cnt), "\n");
        }
        //unanimous - change immediately
        if(e.cnt >= totalplayers) {
            bprint(PRINT_HIGH, "\bUnanimous choice:\b ", e.netname, "\n");
            FO_Sound(self, CHAN_AUTO, "shalrath/death.wav", 1, ATTN_NONE);
            ChangeToVotedMap(e.netname);
            return FALSE;
        } else if(vote_anarchy_mode) {
            if(e.cnt >= numplayers) {
                bprint(PRINT_HIGH, "\bAnarchy succeeded!\b Winner by combat: ", e.netname, "\n");
                FO_Sound(self, CHAN_AUTO, "shalrath/attack2.wav", 1, ATTN_NONE);
                ChangeToVotedMap(e.netname);
                return FALSE;
            }
        } else if(voting_expires < time || (vote_style && !votemode)) {
            // do we want this to trigger during anarchy too when hitting majority?
            if(e.cnt > (numplayers * vote_threshold)) {
                bprint(PRINT_HIGH, "\bTime's up!\b Majority choice: ", e.netname, "\n");
                FO_Sound(self, CHAN_AUTO, "boss1/sight1.wav", 1, ATTN_NONE);
                ChangeToVotedMap(e.netname);
                return FALSE;
            } else if(votemode) {
                AnarchyMode();
            }
            if(votemode) break;
        }
        e = find(e, classname, "map_candidate");
    }
    return TRUE;
};

void (entity p) PrintVoting = {
    if(!voting_started) {
        sprint(p, PRINT_HIGH, "No votes.\n");
        return;
    }
    local float expires = rint(voting_expires - time);
    if(expires > 0) {
        sprint(p, PRINT_HIGH, ftos(expires), " seconds remain. ");
    }
    if(vote_anarchy_mode) {
        sprint(p, PRINT_HIGH, "\bANRACHY MODE!\b ");
    }
    sprint(p, PRINT_HIGH, "\bCurrent votes:\b\n");
    local entity mc = find(world, classname, "map_candidate");
    while(mc) {
        if(mc.cnt > 0) {
            if(p.vote_map == mc) {
                sprint(p, PRINT_HIGH, "", mc.netname, ": ", ftos(mc.cnt), " \b(Your vote)\b\n");
            } else {
                sprint(p, PRINT_HIGH, "", mc.netname, ": ", ftos(mc.cnt), "\n");
            }
        }
        mc = find(mc, classname, "map_candidate");
    }
};

void() vote_think = {
    if(CheckVoting()) {
        if(vote_anarchy_mode) {
            bprint(PRINT_HIGH, "\bANARCHY MODE!\b\n");
            FO_Sound(self, CHAN_AUTO, "items/damage.wav", 1, ATTN_NONE);
            self.nextthink = time + 5;
        } else {
            local float expires = ceil(voting_expires - time);
            if(expires < 10 || expires % 30 == 0) {
                bprint(PRINT_HIGH, "\x10",ftos(expires),"\x11 seconds left\n");
                FO_Sound(self, CHAN_AUTO, "buttons/switch04.wav", 1, ATTN_NONE);
            }
            self.nextthink = time + 1;
        }
    } else {
        dremove(self);
    }
};

void () StartVoting = {
    if(voting_started)
        return;
    local float expires = CF_GetSetting("votetime", "vote_time", "60");
    local entity te;
    voting_started = TRUE;
    vote_anarchy_mode = FALSE;
    vote_total_votes = 0;
    bprint(PRINT_HIGH, "Voting has started!\n");
    if(!votemode) {
        return;
    }
    FO_Sound(self, CHAN_AUTO, "items/protect.wav", 1, ATTN_NONE);
    if(expires) {
        bprint(PRINT_HIGH, "Voting closes in ", ftos(expires), " seconds. \bBe quick!\b\n");
        voting_expires = time + expires;
        te = spawn();
        te.think = vote_think;
        te.classname = "vote_timer";
        te.nextthink = time + 1;
    } else {
        bprint(PRINT_HIGH, "No voting timelimit configured, so will require unanimous decision\n");
    }
};


void (entity p, string vote) VoteForMap = {
    float filehandle;
    filehandle = fopen(strcat("maps/",vote,".bsp"), FILE_READ);
    if (filehandle >= 0) {
        AddVoteMap(vote,"Custom vote","Custom Vote",0,0,0);
        fclose(filehandle);
    } else {
        sprint(p, PRINT_HIGH, "\bUnfortunately, \b", vote, "\b doesn't appear to be a valid map.\nUse \bcmd listmaps\b to for a list of valid maps.\b\n");
    }
    local entity mc = find(world, classname, "map_candidate");
    while(mc) {
        if(mc.netname == vote) {
            if(!voting_started) {
                StartVoting();
                bprint(PRINT_HIGH, p.netname, " suggests \b", vote, "\b\n");
                vote_total_votes++;
            } else {
                if(p.vote_map) {
                    bprint(PRINT_HIGH, p.netname, " changes vote to \b", vote, "\b\n");
                    p.vote_map.cnt--;
                    UpdateAllClientMapVotes(p.vote_map);
                } else {
                    FO_Sound(self, CHAN_AUTO, "items/protect.wav", 1, ATTN_NONE);
                    bprint(PRINT_HIGH, p.netname, " has voted for \b", vote, "\b\n");
                    vote_total_votes++;
                }
            }
            p.vote_map = mc;
            mc.cnt++;
            UpdateAllClientMapVotes(mc);
            CheckVoting();
            return;
        }
        mc = find(mc, classname, "map_candidate");
    }
};

void (entity p) UnvoteForMap = {
    if(p.vote_map) {
        if(vote_anarchy_mode) {
            bprint(PRINT_HIGH, p.netname, " \brecinds vote for\b ", p.vote_map.netname, " \bin battle\b\n");
        } else {
            bprint(PRINT_HIGH, p.netname, " \babandons vote for\b ", p.vote_map.netname, "\n");
        }
        p.vote_map.cnt--;
        UpdateAllClientMapVotes(p.vote_map);
        p.vote_map = world;
        vote_total_votes--;
    }
    CheckVoting();
};

void (entity p) VoteToEndMap = {
    if(CF_GetSetting("vs", "vote_style", "1")) {
        if(p.vote_next) {
            bprint(PRINT_HIGH, p.netname, " desides to keep playing.\n");
        } else {
            bprint(PRINT_HIGH, p.netname, " \bvotes to end the current map.\b.\n");
        }
        p.vote_next = !p.vote_next;
        local float numplayers = 0, numvoted = 0;
        local entity te = find (world, classname, "player");
        while (te) {
            if (!te.has_disconnected) {
                numplayers = numplayers + 1;
                if(te.vote_next) {
                    numvoted++;
                }
            }          
            te = find (te, classname, "player");
        }
        if(numvoted > (numplayers * vote_threshold)) {
            sound(self, CHAN_AUTO, "boss1/out1.wav", 1, ATTN_NONE);
            bprint(PRINT_HIGH, "\bMap ended by majority vote.\b.\n");
            if(nextmap == "") {
                vote_result = FO_GetUserSettingString(world, "vote_map", "votemap", "se2");
                votemode = 2;
            }
            execute_changelevel();
        } else {
            sound(self, CHAN_AUTO, "misc/secret.wav", 1, ATTN_NONE);
            bprint(PRINT_HIGH, "\x10",ftos((floor(numplayers * vote_threshold) + 1) - numvoted),"\x11 more votes required to end the current map.\n");
            bprint(PRINT_HIGH, "Type \bbreak\b to toggle your vote.\n");
        }
    }
};

void (entity p) VoteYes = {
    if(!voting_started) {
        sprint(p, PRINT_HIGH, "No suggestions so far.\n");
        return;
    }
    if(p.vote_map) {
        sprint(p, PRINT_HIGH, "You've already voted for (", p.vote_map.netname, ")!\n");
        return;
    }

    local entity mc = find(world, classname, "map_candidate");
    local entity mc2 = world;
    local float count = 0;
    while(mc) {
        if(mc.cnt > 0) {
            count++;
            mc2 = mc;
        }
        mc = find(mc, classname, "map_candidate");
    }
    if(count > 1) {
        sprint(p, PRINT_HIGH, "There are multiple suggestions. Use 'cmd votemap' to vote!\n");
        return;
    }
    if(count == 1) {
        VoteForMap(p, mc2.netname);
    }
}

entity (float index) Vote_Menu_Map_GetMapCandidate = {
    local float count = 1;
    local entity mc = find(world, classname, "map_candidate");
    while(mc) {
        if(count == index) {
            return mc;
        }
        count++;
        mc = find(mc, classname, "map_candidate");
    }
    return world;
};

void (float update) Vote_Menu_Map;
void (float update) Vote_Menu_Map_Action;
void (float inp) Vote_Menu_Map_Action_Input = {
    switch (inp) {
        case 1:
            Menu_Close(self);
            VoteForMap(self, self.admin_use.netname);
            return;
        case 2:
            Menu_Close(self);
            bprint(PRINT_HIGH, self.netname, " is changing the map to ", self.admin_use.netname, "\n");
            if(self.is_admin) {
                ChangeToVotedMap(self.admin_use.netname);
            } else {
                //rcon, but only from clientside to make sure it's allowed
                stuffcmd(self, strcat("rcon map ", self.admin_use.netname,"\n"));
            }
            return;
        case 10:
            Vote_Menu_Map(0);
            return;
    }
};
void (float update) Vote_Menu_Map_Action = {    
    // allow toggling team menu using any method to show it
    if (!update && self.menu_input == Vote_Menu_Map_Action_Input) {
        Menu_Input(0);
        return;
    }
    
    //self.admin_use is a map_candidate
    if(self.admin_use) {
        // prepare menu strings
        local string s_title = strcat("\sActions for map\s\n", self.admin_use.netname ,"\n\n");
        local string s_1   = Q"\s[1]\s Vote          \n";
        local string s_2   = Q"\s[2]\s Change (Admin)\n";
        local string s_0   = Q"\s[0]\s Back          \n";

        Status_Menu(self, Vote_Menu_Map_Action_Input, s_title, s_1, s_2, "\n", s_0);

        strunzone(s_title);
    } else {
        sprint(self, PRINT_HIGH, "Something went wrong in the map menu\n");
        Vote_Menu_Map(0);
    }


};

void (float inp) Vote_Menu_Map_Input = {
    if(inp < 0 || inp > 10) {
        Vote_Menu_Map(1);
        return;
    }
    switch (inp) {
        case 8:
            self.current_menu_page--;
            if(self.current_menu_page < 1) {
                self.current_menu_page = 1;
            }
            Vote_Menu_Map(0);
            return;
        case 9:
            self.current_menu_page++;
            Vote_Menu_Map(0);
            return;
        case 0:
        case 10:
            Menu_Close(self);
            return;
    }
    local entity mc = Vote_Menu_Map_GetMapCandidate((self.current_menu_page - 1) * 7 + inp);
    if(mc) {
        self.admin_use = mc;
        if(self.classname == "observer") {
            Vote_Menu_Map_Action_Input(2);
        } else {
            Vote_Menu_Map_Action(0);
        }
    }
};
void (float update) Vote_Menu_Map = {    
    // allow toggling team menu using any method to show it
    if (!update && self.menu_input == Vote_Menu_Map_Input) {
        Menu_Input(0);
        return;
    }

    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)){
        UpdateClientMenu_Maps(self);
        return;
    }

    // prepare menu strings
    local string s_title = strcat("\sEquations\s\nPage ",ftos(self.current_menu_page),"\n\n");
    local string s_8   = Q"\s[8]\s Previous            \n";
    local string s_9   = Q"\s[9]\s Next                \n";
    local string s_0   = Q"\s[0]\s Exit                \n";
    local string s_choices = "";
    local float count = 0, remainder = 0, page = 0;
    local entity mc = find(world, classname, "map_candidate");
    while(mc) {
        page = floor(count / 7);
        if(page == (self.current_menu_page - 1)) {
            remainder = count % 7;
            s_choices = strcat(s_choices, "\s[\s", ftos(remainder + 1), "\s]\s ", strpadr(mc.netname, 20), "\n");
        } else if(page >= self.current_menu_page) {
            break;
        }
        count++;
        mc = find(mc, classname, "map_candidate");
    }

    Status_Menu(self, Vote_Menu_Map_Input, s_title, s_choices, "\n", s_8, s_9, s_0);
    //self.current_menu_type = ADMIN_MENU_TYPE_MAIN;

    strunzone(s_choices); strunzone(s_title);
};
