string prepq3fstring (string s)
{
    string ret;

    ret = strireplace("%n", "", s);
    ret = strireplace("~", "", ret);
    ret = strireplace("^*", "", ret);

    ret = strireplace("^4blue", Q"\sblue\s", ret);
    ret = strireplace("^1red", Q"\sred\s", ret);

    ret = strcat(ret, "\n");
    return (ret);
}

float GetQ3State(string st)
{
    float stf = 0;
    st = strtrim(prepq3fstring(st));

    switch (st)
    {
        case "disabled":
            stf = STATE_DISABLED;
            break;
        case "inactive":
            stf = STATE_INACTIVE;
            break;
        case "active":
            stf = STATE_ACTIVE;
            break;
        case "invisible":
            stf = STATE_INVISIBLE;
            break;
    }
    return stf;
}

void ActivateQ3Goal(entity trig, float active)
{
    string msg = "";
    string targets = "";
    if (active)
    {
        msg = prepq3fstring(trig.active_all_message);
        targets = trig.activetarget;
    }
    else
    {
        //msg = prepq3fstring(trig.active_all_message);
        targets = trig.failtarget;
    }
    if (msg != "")
        bprint(PRINT_HIGH, msg, "\n");
    
    float count = tokenizebyseparator(targets, ",");
    for (float i = 0; i <= count; i++)
    {
        string s = argv(i);
        float count2 = tokenizebyseparator(s, "=");
        if (count2 >= 2)
        {
            string gname = argv(0);
            float chkstate = GetQ3State(argv(1));
            entity targ = find(world, groupname, gname);
            while (targ)
            {
                if (targ.state == STATE_INVISIBLE && targ.state != chkstate)
                {
                    FO_SetModel(targ, targ.mdl);
                }
                targ.state = chkstate;
                msg = "";
                switch(chkstate)
                {
                    case STATE_INVISIBLE:
                        targ.mdl = targ.model;                       
                        setmodel(targ, "");
                        break;
                    case STATE_DISABLED:
                        msg = prepq3fstring(targ.disabled_all_message);
                        break;
                }
                if (msg != "")
                {
                    bprint(PRINT_HIGH, msg, "\n");
                }
                targ = find(targ, groupname, gname);
            }
        }
        tokenizebyseparator(targets, ",");
    }
}

void CheckStateQ3Goal(entity trig)
{
    float count = tokenizebyseparator(trig.checkstate, ",");
    float triggered = TRUE;
    for (float i = 0; i <= count; i++)
    {
        string s = argv(i);
        float count2 = tokenizebyseparator(s, "=");
        if (count2 >= 2)
        {
            string gname = argv(0);
            float chkstate = GetQ3State(argv(1));

            entity targ = find(world, groupname, gname);
            if (!targ)
                continue;

            if (targ.state != chkstate)
            {
                triggered = FALSE;
            }
        }
    }

    ActivateQ3Goal(trig, triggered);
}

void () target_location = {
}

// backpacks, cap points etc
void () func_goalinfo = {
    self.classname = "info_tfgoal";
    self.frags = self.teamscore;
    self.count = self.teamscore;
    self.mdl = self.model;
    self.noise = self.active_all_sound;
    self.armortype = 0.8;
    self.goal_effects = 1;
    self.goal_activation = 1; // touched by player
    self.n_b = prepq3fstring(self.active_all_message);

    // probably have to tokenise this?
    if (self.allowteams == "blue") 
    {
        self.team_no = 1;
    }
    if (self.allowteams == "red") 
    {
        self.team_no = 2;
    }

    // note: need to see if this is groupname or builtin name in q3f
    if (self.holding == "blueflag") 
    {
        self.items_allowed = 1;
        self.owned_by = 1;
        self.axhitme = 1;
    }
    if (self.holding == "redflag")
    {
        self.items_allowed = 2;
        self.owned_by = 2;
        self.axhitme = 2;
    }
   
    float count = tokenizebyseparator(self.give, ",");

    for (float i = 0; i <= count; i++)
    {
        string s, gtype, gop, gamt;
        float loc, slen, val;
        
        s = argv(i);
        slen = strlen(s);
        loc = strstrofs(s, "=");

        gtype = substring(s, 0, loc);
        if (gtype == "")
            continue;
        gop = substring(s, loc, loc + 1);
        gamt = substring(s, loc + 1, slen);
        if (gop == "-") {
            val = stof(strcat("-", gamt));
        } else {
            val = stof(gamt);
        }

        switch (gtype) 
        {
            case "health":
                self.health = val;
                break;
            case "armor":
                self.armorvalue = val;
                break;
            case "ammo_shells":
                self.ammo_shells = val;
                break;
            case "ammo_nails":
                self.ammo_nails = val;
                break;
            case "ammo_rockets":
                self.ammo_rockets = val;
                break;
            case "ammo_cells":
                self.ammo_cells = val;
                break;
            case "gren1":
                self.no_grenades_1 = val;
                break;
            case "gren2":
                self.no_grenades_2 = val;
                break;
            case "ammo_medikit":
                self.ammo_medikit = val;
                break;
            default:
                dprint("gtype not found, discarding\n");
                dprint("gtype: ", gtype, "\n");
                dprint("gop: ", gop, "\n");
                dprint("gamt: ", gamt, "\n");
        }
    }

    info_tfgoal();
}

// flags
void () func_goalitem = {
    self.classname = "item_tfgoal";
    self.mdl = self.model;
    self.delay = self.wait; // is delay used anymore?
    self.pausetime = self.wait;
    self.netname = self.groupname;
    self.g_a = 4789;
    switch(self.allowteams)
    {
        case "blue":
            self.team_no = 1;
            self.owned_by = 2;
            self.skin = 1; 
            self.goal_no = 2;
            self.items = 262144; // used by hud?
            break;
        case "red":
            self.team_no = 2;
            self.owned_by = 1;
            self.skin = 2; 
            self.goal_no = 1;
            self.items = 131072; // used by hud?
            break;
        default:
    }
    string cam, iam;
    cam = prepq3fstring(self.carried_all_message);
    iam = prepq3fstring(self.inactive_all_message);

    self.team_broadcast = cam;
    self.non_team_broadcast = cam;
    self.message = prepq3fstring(self.carried_message);
    self.noise = self.carried_all_sound;
    self.noise3 = iam;
    self.noise4 = iam;
    self.n_b = cam;
    self.d_n_n = prepq3fstring(self.active_all_message);

    item_tfgoal();
}

void () target_kill = {
    self.classname = "info_tfgoal";
    self.health = -500;
    self.deathtype = " died\n";
    self.goal_effects = 1;

    info_tfgoal();
}

void () target_position = {
};