float () UserCmd =
{
    float isProcessed;
    string arg1, arg2, arg3, arg4;
    arg1 = argv_mvdsv(0);
    arg2 = argv_mvdsv(1);
    arg3 = argv_mvdsv(2);
    arg4 = argv_mvdsv(3);

    isProcessed = ParseCmds(arg1, arg2, arg3, arg4);
    return (isProcessed);
};

float (string cmd) ConsoleCmd {
    local float arg_num;
    local string arg_val0, arg_val1, arg_val2;
    local string tmp;

    if(cmd) {
        //FTESV implementation
        arg_num = tokenize(cmd);
        arg_val0 = argv(0);
        arg_val1 = argv(1);
        arg_val2 = argv(2);
        switch(argv(0)) {
            case "vote_addmap":
                AddVoteMap(argv(1),argv(2),argv(3),stof(argv(4)),stof(argv(5)),stof(argv(6)));
                return TRUE;
            case "vote_removemap":
                RemoveVoteMap(argv(1));
                return TRUE;
            case "nextmap":
                if(FO_GetUserSetting (world, "nomapcycle", "nmc", "0")) {
                    bprint(PRINT_HIGH, "Tried setting next map to ", argv(1), ", but nomapcycle is set.\n");
                } else {
                    nextmap = argv(1);
                    bprint(PRINT_HIGH, "Next map set to ", nextmap, ". Enable nomapcycle to skip.\n");
                }
                return TRUE;
        }
    } else {
        //MVDSV implementation
        arg_val0 = argv_mvdsv(0);
        arg_val1 = argv_mvdsv(1);
        arg_val2 = argv_mvdsv(2);
        arg_num = argc();
    }
    if (arg_num == 0) {
        return (0);
    }
    if (arg_val0 == "prematch") {
        if (arg_num == 2) {
            localcmd("localinfo prematch ");
            localcmd(arg_val1);
            localcmd("\n");
            return (1);
        }
        if (arg_num == 1) {
            tmp = infokey (world, arg_val0);
            dprint("prematch is ");
            dprint("\"");
            dprint(tmp);
            dprint("\"\n");
            return (1);
        }
    }
    else if (arg_val0 == "autorecord")
    {
        if (arg_num == 2) {
            localcmd("localinfo demo_auto_left ");
            localcmd(arg_val1);
            localcmd("\n");
            return (1);
        }
        if (arg_num == 1) {
            tmp = infokey (world, "demo_auto_left");
            if ((stof(tmp) > 0)) {
                dprint("Auto-Recording off\n");
                localcmd("localinfo demo_auto_left 0\n");
                return (1);
            }
            else {
                dprint("Auto-Recording the next match\n");
                localcmd("localinfo demo_auto_left 1\n");
                return (1);
            }
        }
    } 
    else if (arg_val0 == "clan")
    {
        ClanMode();
        return (1);
    }
    else if (arg_val0 == "quadmode")
    {
        QuadMode();
        return (1);
    }
    else if (arg_val0 == "duelmode")
    {
        DuelMode();
        return (1);
    }
    return 0;
}

void (float duration) GE_PausedTic = {
    local entity p;
    if (unpause_requested && (unpause_countdown == 0)) {
        unpause_countdown = duration + 5;
        unpause_lastcountnumber = 5;
    }
    if (unpause_requested) {
        if ((duration >= unpause_countdown)) {
            is_paused = 0;
            cs_paused = 0;
            unpause_countdown = 0;
            unpause_requested = 0;
            unpause_lastcountnumber = 0;
            setpause(0);
            NotifyPauseUnpause(FALSE);
        } else if (duration >= unpause_countdown - (unpause_lastcountnumber)) {
            unpause_lastcountnumber--;
            p = find (world, classname, "player");
            while (p) {
                if (p.netname != "")
                    stuffcmd(p, "play buttons/switch04.wav\n");
                p = find(p, classname, "player");
            }
            bprint(PRINT_HIGH,
                   sprintf("Unpausing in %d seconds\n", unpause_lastcountnumber));
        }
    }
}

void(float pauseduration) SV_PausedTic = {
    GE_PausedTic(pauseduration);
}
