//========================================================
// Functions handling TeamFortress Map Entities
//========================================================

void () TF_PlaceItem;
void () TF_StartItem;
void () TF_PlaceGoal;
void () TF_StartGoal;

void () info_tfdetect;
void () info_player_teamspawn;
void () info_tfgoal;
void () info_tfgoal_timer;
void () info_tfgoal_use;
void () item_tfgoal;
void () item_tfgoal_touch;

entity(float gno) Findteamspawn;
void (entity Goal) InactivateGoal;
void (entity Goal) RestoreGoal;
void (entity Goal) RemoveGoal;

float (entity Goal, entity Player, entity AP) IsAffectedBy;
void (entity Goal, entity Player, entity AP, float addb) Apply_Results;
float (entity Goal, entity AP) APMeetsCriteria;

void (entity Goal) SetupRespawn;
void () DoRespawn;

void (entity Item, entity AP) DoItemGroupWork;
void (entity Goal, entity AP) DoTriggerWork;
void (entity Goal, entity Player) RemoveResults;

void () tfgoal_timer_tick;
void () tfgoalitem_remove;
void (entity Item, entity AP) tfgoalitem_RemoveEffectsFromPlayer;
void (entity Item, float PAlive, entity P) tfgoalitem_drop;
void (entity Item) tfgoalitem_checkgoalreturn;

void () ReturnItem;

void (entity P) ForceRespawn;

void (entity Goal) UpdateAbbreviations = {
    local string st;

    if (Goal.has_abbreviated == 0) {
        if ((Goal.g_a != 0) && (Goal.goal_activation == 0)) {
            Goal.goal_activation = Goal.g_a;
        }
        if ((Goal.g_e != 0) && (Goal.goal_effects == 0)) {
            Goal.goal_effects = Goal.g_e;
        }
        if ((Goal.g_e != 0) && (Goal.goal_effects == 0)) {
            Goal.goal_effects = Goal.g_e;
        }
        if ((Goal.h_i_g != 0) && (Goal.has_item_from_group == 0)) {
            Goal.has_item_from_group = Goal.h_i_g;
        }
        if ((Goal.hn_i_g != 0) && (Goal.hasnt_item_from_group == 0)) {
            Goal.hasnt_item_from_group = Goal.hn_i_g;
        }
        if ((Goal.r_i_g != 0) && (Goal.remove_item_group == 0)) {
            Goal.remove_item_group = Goal.r_i_g;
        }
        if ((Goal.a_s != 0) && (Goal.ammo_shells == 0)) {
            Goal.ammo_shells = Goal.a_s;
        }
        if ((Goal.a_n != 0) && (Goal.ammo_nails == 0)) {
            Goal.ammo_nails = Goal.a_n;
        }
        if ((Goal.a_r != 0) && (Goal.ammo_rockets == 0)) {
            Goal.ammo_rockets = Goal.a_r;
        }
        if ((Goal.a_c != 0) && (Goal.ammo_cells == 0)) {
            Goal.ammo_cells = Goal.a_c;
        }
        if ((Goal.rv_s_h != 0) && (Goal.remove_spawngroup == 0)) {
            Goal.remove_spawngroup = Goal.rv_s_h;
        }
        if ((Goal.rs_s_h != 0) && (Goal.restore_spawngroup == 0)) {
            Goal.restore_spawngroup = Goal.rs_s_h;
        }
        if ((Goal.rv_gr != 0) && (Goal.remove_group_no == 0)) {
            Goal.remove_group_no = Goal.rv_gr;
        }
        if ((Goal.rs_gr != 0) && (Goal.restore_group_no == 0)) {
            Goal.restore_group_no = Goal.rs_gr;
        }
        if ((Goal.rv_g != 0) && (Goal.remove_goal_no == 0)) {
            Goal.remove_goal_no = Goal.rv_g;
        }
        if ((Goal.rs_g != 0) && (Goal.restore_goal_no == 0)) {
            Goal.restore_goal_no = Goal.rs_g;
        }
        if (Goal.t_s_h != string_null) {
            Goal.team_str_home = Goal.t_s_h;
        }
        if (Goal.t_s_m != string_null) {
            Goal.team_str_moved = Goal.t_s_m;
        }
        if (Goal.t_s_c != string_null) {
            Goal.team_str_carried = Goal.t_s_c;
        }
        if (Goal.n_s_h != string_null) {
            Goal.non_team_str_home = Goal.n_s_h;
        }
        if (Goal.n_s_m != string_null) {
            Goal.non_team_str_moved = Goal.n_s_m;
        }
        if (Goal.n_s_c != string_null) {
            Goal.non_team_str_carried = Goal.n_s_c;
        }
        if (Goal.b_b != string_null) {
            Goal.broadcast = Goal.b_b;
        }
        if (Goal.b_t != string_null) {
            Goal.team_broadcast = Goal.b_t;
        }
        if (Goal.b_n != string_null) {
            Goal.non_team_broadcast = Goal.b_n;
        }
        if (Goal.b_o != string_null) {
            Goal.owners_team_broadcast = Goal.b_o;
        }
        if (Goal.n_b != string_null) {
            Goal.netname_broadcast = Goal.n_b;
        }
        if (Goal.n_t != string_null) {
            Goal.netname_team_broadcast = Goal.n_t;
        }
        if (Goal.n_n != string_null) {
            Goal.netname_non_team_broadcast = Goal.n_n;
        }
        if (Goal.n_o != string_null) {
            Goal.netname_owners_team_broadcast = Goal.n_o;
        }
        if (Goal.d_t != string_null) {
            Goal.team_drop = Goal.d_t;
        }
        if (Goal.d_n != string_null) {
            Goal.non_team_drop = Goal.d_n;
        }
        if (Goal.d_n_t != string_null) {
            Goal.netname_team_drop = Goal.d_n_t;
        }
        if (Goal.d_n_n != string_null) {
            Goal.netname_non_team_drop = Goal.d_n_n;
        }
        if (flagem_checked == 0) {
            st = infokey(world, "fe");
            if (st == string_null) {
                st = infokey(world, "flag_emu");
            }
            if (st == "on") {
                toggleflags = toggleflags | TFLAG_FLAGEMU;
            }
            st = infokey(world, "ws");
            if (st == string_null) {
                st = infokey(world, "use_standard");
            }
            if (st == "on") {
                toggleflags = toggleflags | TFLAG_WARSTANDARD;
            }
            flagem_checked = 1;
        }
        if ((toggleflags & TFLAG_FLAGEMU) &&
                !(toggleflags & TFLAG_WARSTANDARD)) {
            if ((Goal.mdl == "progs/b_s_key.mdl")
                    || (Goal.mdl == "progs/m_s_key.mdl")
                    || (Goal.mdl == "progs/w_s_key.mdl")) {

                Goal.mdl = "progs/tf_flag.mdl";
                Goal.origin_z = Goal.origin_z + 6;
                Goal.skin = 1;
            } else if ((Goal.mdl == "progs/b_g_key.mdl")
                    || (Goal.mdl == "progs/m_g_key.mdl")
                    || (Goal.mdl == "progs/w_g_key.mdl")) {

                Goal.mdl = "progs/tf_flag.mdl";
                Goal.origin_z = Goal.origin_z + 6;
                Goal.skin = 2;
            }
        }
        if (toggleflags & TFLAG_WARSTANDARD) {
            if ((Goal.mdl == "progs/b_s_key.mdl")
                    || (Goal.mdl == "progs/m_s_key.mdl")
                    || (Goal.mdl == "progs/w_s_key.mdl")) {

                Goal.mdl = "progs/tf_stan.mdl";
                Goal.skin = 1;
            } else if ((Goal.mdl == "progs/b_g_key.mdl")
                    || (Goal.mdl == "progs/m_g_key.mdl")
                    || (Goal.mdl == "progs/w_g_key.mdl")) {

                Goal.mdl = "progs/tf_stan.mdl";
                Goal.skin = 2;
            } else if (Goal.mdl == "progs/tf_flag.mdl")
                Goal.mdl = "progs/tf_stan.mdl";
        }
        Goal.has_abbreviated = 1;
    }
};

void () TF_PlaceItem = {
    local float oldz;

    self.flags = FL_ITEM;
    self.velocity = '0 0 0';
    if (self.goal_activation & 2048) {
        self.movetype = MOVETYPE_TOSS;
        self.origin_z = self.origin_z + 6;
        oldz = self.origin_z;
        if (!droptofloor()) {
            dprint("GoalItem fell out of level at ");
            dprint(vtos(self.origin));
            dprint("\n");
            dremove(self);
            return;
        }
    }
    self.movetype = 0;
    self.oldorigin = self.origin;

    if (item_list_bit == 0)
        item_list_bit = 1;

    self.item_list = item_list_bit;
    item_list_bit = item_list_bit * 2;
};

float TF_Item_GetGlow(float team)
{
    float ret = 0;
    switch (team)
    {
        case 1:
            ret = EF_BLUE;
            break;
        case 2: 
            ret = EF_RED;
            break;
        case 3:
            ret = EF_RED + EF_MUZZLEFLASH;
            break;
        case 4:
            ret = EF_MUZZLEFLASH;
            break;
        default:
            ret = EF_DIMLIGHT;
    }

    return ret;
}

void TF_Item_ApplyGlow()
{
    if (self.spawnflags & TFGI_NOGLOW)
        return;
        
    local entity tfdet;  //info_tfdetect entity
    tfdet = find(world, classname, "info_tfdetect");

    if (tfdet && (tfdet.display_item_status1 == self.goal_no || tfdet.display_item_status2 == self.goal_no || tfdet.display_item_status3 == self.goal_no || tfdet.display_item_status4 == self.goal_no)) {
        self.effects = self.effects | TF_Item_GetGlow(self.owned_by);
    } else {
        if (self.model)
        {
            switch (self.model)
            {
                case "progs/basrkey.bsp":
                    self.effects = self.effects | EF_DIMLIGHT;
                    self.effects = self.effects | EF_RED;
                    break;
                case "progs/basbkey.bsp":
                    self.effects = self.effects | EF_DIMLIGHT;
                    self.effects = self.effects | EF_BLUE;
                    break;
                default:
                    self.effects = self.effects | TF_Item_GetGlow(self.owned_by);
            }
        }       
    }
}

void () TF_StartItem = {
    TF_Item_ApplyGlow();
    UpdateAbbreviations(self);
    self.nextthink = time + 0.2;
    self.think = TF_PlaceItem;
    if (self.goal_state == TFGS_REMOVED)
        RemoveGoal(self);
};

void () TF_PlaceGoal = {
    local float oldz;

    if (self.classname != "info_tfgoal_timer") {
        if (self.goal_activation & TFGA_TOUCH) {
            self.touch = tfgoal_touch;
        }
    } else {
        self.think = tfgoal_timer_tick;
        self.nextthink = time + self.search_time;
        self.classname = "info_tfgoal";
    }
    if (self.goal_activation & 2048) {

        self.movetype = MOVETYPE_TOSS;
        self.origin_z = self.origin_z + 6;
        oldz = self.origin_z;
        if (!droptofloor()) {
            dprint("Goal fell out of level at ");
            dprint(vtos(self.origin));
            dprint("\n");
            dremove(self);
            return;
        }
    }
    self.flags = FL_ITEM;
    self.movetype = 0;
    self.velocity = '0 0 0';
    self.oldorigin = self.origin;
};

void () TF_StartGoal = {
    UpdateAbbreviations(self);
    self.nextthink = time + 0.2;
    self.think = TF_PlaceGoal;
    self.use = info_tfgoal_use;
    if (self.goal_state == TFGS_REMOVED)
        RemoveGoal(self);
};

float () CheckExistence = {
    UpdateAbbreviations(self);
    skill = cvar("skill");
    if ((self.ex_skill_min == -1) && (skill < 0)) {
        return (FALSE);
    } else if ((self.ex_skill_max == -1) && (skill > 0)) {
        return (FALSE);
    }
    if ((self.ex_skill_min && (self.ex_skill_min != -1)) &&
            (skill < self.ex_skill_min)) {
        return (FALSE);
    } else if ((self.ex_skill_max && (self.ex_skill_max != -1)) &&
            (skill > self.ex_skill_max)) {
        return (FALSE);
    }
    return (TRUE);
};

void () info_tfdetect = {
    UpdateAbbreviations(self);
};

void () info_player_teamspawn = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if ((self.team_no <= 0) || (self.team_no >= 5)) {
        objerror
            ("error: bad team_no associated with info_player_teamspawn\n");
        dremove(self);
        return;
    }
    if (number_of_teams < self.team_no) {
        number_of_teams = self.team_no;
    }
    if (self.team_no == 1) {
        self.team_str_home = "ts1";
    } else {
        if (self.team_no == 2) {
            self.team_str_home = "ts2";
        } else {
            if (self.team_no == 3) {
                self.team_str_home = "ts3";
            } else {
                if (self.team_no == 4) {
                    self.team_str_home = "ts4";
                }
            }
        }
    }
};

void () info_player_start = {
    if (self.allowteams == "blue") {
        self.classname = "info_player_teamspawn";
        self.team_no = 1;
        info_player_teamspawn();
    }
    if (self.allowteams == "red") {
        self.classname = "info_player_teamspawn";
        self.team_no = 2;
        info_player_teamspawn();
    }
};

void () i_p_t = {
    self.classname = "info_player_teamspawn";
    info_player_teamspawn();
};

void () info_tfgoal = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if (self.mdl) {
        precache_model(self.mdl);
        precache_model2(self.mdl);
        FO_SetModel(self, self.mdl);
    }
    if (self.noise) {
        precache_sound(self.noise);
        precache_sound2(self.noise);
    }
    precache_sound("items/protect.wav");
    precache_sound("items/protect2.wav");
    precache_sound("items/protect3.wav");
    precache_sound("items/suit.wav");
    precache_sound("items/suit2.wav");
    precache_sound("items/inv1.wav");
    precache_sound("items/inv2.wav");
    precache_sound("items/inv3.wav");
    precache_sound("items/damage.wav");
    precache_sound("items/damage2.wav");
    precache_sound("items/damage3.wav");

    self.solid = 1;

    if (self.goal_state == 0)
        self.goal_state = 2;

    if (self.goal_min == '0 0 0')
        self.goal_min = VEC_HULL_MIN;

    if (self.goal_max == '0 0 0')
        self.goal_max = VEC_HULL_MAX;

    setsize(self, self.goal_min, self.goal_max);
    TF_StartGoal();
};

void () i_t_g = {
    self.classname = "info_tfgoal";
    info_tfgoal();
};

void () info_tfgoal_timer = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if (self.mdl) {
        precache_model(self.mdl);
        precache_model2(self.mdl);
        FO_SetModel(self, self.mdl);
    }
    if (self.noise) {
        precache_sound(self.noise);
        precache_sound2(self.noise);
    }
    if (self.search_time <= 0) {
        dprint("Timer Goal created with no specified time.\n");
        dremove(self);
    }
    self.solid = 0;
    if (self.goal_state == 0) {
        self.goal_state = 2;
    }
    if (self.goal_min == '0 0 0') {
        self.goal_min = VEC_HULL_MIN;
    }
    if (self.goal_max == '0 0 0') {
        self.goal_max = VEC_HULL_MAX;
    }
    setsize(self, self.goal_min, self.goal_max);
    TF_StartGoal();
};

void () i_t_t = {
    self.classname = "info_tfgoal_timer";
    info_tfgoal_timer();
};

void () item_tfgoal = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if (self.mdl) {
        precache_model(self.mdl);
        precache_model2(self.mdl);
        FO_SetModel(self, self.mdl);
    } else {
        self.mdl = "";
        setmodel(self, "");
    }
    precache_sound2("items/itembk2.wav");
    if (self.noise) {
        precache_sound(self.noise);
        precache_sound2(self.noise);
    }
    self.touch = item_tfgoal_touch;
    if (self.goal_state == 0)
        self.goal_state = TFGS_INACTIVE;

    if (self.goal_activation & 8192)
        self.solid = SOLID_BBOX;
    else
        self.solid = SOLID_TRIGGER;

    setorigin(self, self.origin);
    if (!self.netname)
        self.netname = "goalitem";

    if (self.pausetime <= 0)
        self.pausetime = 60;

    if ((self.delay != 0) && (self.pausetime == 0))
        self.pausetime = self.delay;

    if (self.goal_min == '0 0 0')
        self.goal_min = VEC_HULL_MIN;

    if (self.goal_max == '0 0 0')
        self.goal_max = VEC_HULL_MAX;

    setsize(self, self.goal_min, self.goal_max);
    TF_StartItem();
};

void (entity AD) ParseTFDetect = {
    localcmd(AD.message);
    cvar_set("sv_maxspeed", "500");
    team1lives = AD.ammo_shells;
    team2lives = AD.ammo_nails;
    team3lives = AD.ammo_rockets;
    team4lives = AD.ammo_cells;
    if (team1lives == 0) {
        team1lives = -1;
    }
    if (team2lives == 0) {
        team2lives = -1;
    }
    if (team3lives == 0) {
        team3lives = -1;
    }
    if (team4lives == 0) {
        team4lives = -1;
    }
    team1maxplayers = AD.ammo_medikit;
    team2maxplayers = AD.ammo_detpack;
    team3maxplayers = AD.maxammo_medikit;
    team4maxplayers = AD.maxammo_detpack;
    if (team1maxplayers == 0) {
        team1maxplayers = 100;
    }
    if (team2maxplayers == 0) {
        team2maxplayers = 100;
    }
    if (team3maxplayers == 0) {
        team3maxplayers = 100;
    }
    if (team4maxplayers == 0) {
        team4maxplayers = 100;
    }
    illegalclasses = AD.playerclass;
    illegalclasses1 = AD.maxammo_shells;
    illegalclasses2 = AD.maxammo_nails;
    illegalclasses3 = AD.maxammo_rockets;
    illegalclasses4 = AD.maxammo_cells;
    civilianteams = 0;
    if (illegalclasses1 == -1) {
        illegalclasses1 = 0;
        civilianteams = civilianteams | 1;
    }
    if (illegalclasses2 == -1) {
        illegalclasses2 = 0;
        civilianteams = civilianteams | 2;
    }
    if (illegalclasses3 == -1) {
        illegalclasses3 = 0;
        civilianteams = civilianteams | 4;
    }
    if (illegalclasses4 == -1) {
        illegalclasses4 = 0;
        civilianteams = civilianteams | 8;
    }
};

entity(float ino) Finditem =
{
    local entity tg;
    //local string st;

    tg = find(world, classname, "item_tfgoal");
    while (tg) {
        if (tg.goal_no == ino)
            return (tg);
        tg = find(tg, classname, "item_tfgoal");
    }
    //dprint("Could not find an item with a goal_no of ");
    //st = ftos(ino);
    //dprint(st);
    //dprint(".\n");
    return world;
};

entity(float gno) Findgoal =
{
    for (float i = 0; i < goal_class_names.length; i++)
    {
        string goal_type = goal_class_names[i];
        entity tg = find(world, classname, goal_type);
        while (tg) 
        {
            if (tg.goal_no == gno)
            {
                return tg;
            }
            tg = find(tg, classname, goal_type);
        }
    }

    dprint("Could not find a goal with a goal_no of ");
    string st = ftos(gno);
    dprint(st);
    dprint(".\n");
    return world;
};

entity(float gno) Findteamspawn =
{
    local entity tg;
    local string st;

    tg = find(world, classname, "info_player_teamspawn");
    while (tg) {
        if (tg.goal_no == gno)
            return (tg);
        tg = find(tg, classname, "info_player_teamspawn");
    }
    dprint("Could not find a Teamspawn with a goal_no of ");
    st = ftos(gno);
    dprint(st);
    dprint(".\n");
    return world;
};

void (entity Goal) InactivateGoal = {
    if (Goal.goal_state == TFGS_ACTIVE) {
        if (Goal.search_time == 0) {
            if ((Goal.goal_activation & 8192) &&
                    (Goal.classname == "item_tfgoal"))
                Goal.solid = SOLID_BBOX;
            else
                Goal.solid = SOLID_TRIGGER;
        }
        Goal.goal_state = TFGS_INACTIVE;
        if (Goal.mdl != string_null && !(duelmode && duel_no_packs)) {
            FO_SetModel(Goal, Goal.mdl);
        }
    }
};

void DefaultGoalState (entity Goal)
{
    if ((Goal.goal_activation & 8192) &&
            (Goal.classname == "item_tfgoal")) {
        Goal.solid = SOLID_BBOX;
    } else {
        Goal.solid = SOLID_TRIGGER;
    }
    Goal.goal_state = TFGS_NONE;
}

void (entity Goal) RestoreGoal = {

    if (Goal.goal_state == TFGS_REMOVED) {
        Goal.dimension_seen = DMN_NOFLASH;

        if (Goal.search_time == 0) {
            if (
                ((Goal.goal_activation & 8192) && (Goal.classname == "item_tfgoal"))
                || Goal.classname == "door"
                ) 
            {
                Goal.solid = SOLID_BBOX;
            } 
            else 
            {
                Goal.solid = SOLID_TRIGGER;
            }
        } else {
            Goal.nextthink = time + Goal.search_time;
        }
        Goal.goal_state = TFGS_INACTIVE;
        if (Goal.mdl) {
            FO_SetModel(Goal, Goal.mdl);
            setsize(Goal, Goal.goal_min, Goal.goal_max);
            entity oldself;
            oldself = self;
            self = Goal;
            TF_Item_ApplyGlow();
            self = oldself;
        }
    }
};

void (entity Goal) RemoveGoal = {
    Goal.old_dimension_seen = Goal.dimension_seen;
    Goal.dimension_seen = DMN_INVISIBLE;
    
    Goal.solid = 0;
    Goal.goal_state = TFGS_REMOVED;
    if (Goal.mdl != string_null)
        FO_SetModel(Goal, string_null);
};

float (entity Goal, entity Player, entity AP) IsAffectedBy = {
    local float genv;

    if (Player.playerclass == 0) {
        return (0);
    }
    if (Goal.goal_effects & 32) {
        genv = pointcontents(Goal.origin);
        if (pointcontents(Player.origin) != genv) {
            return (0);
        }
    }
    if (Goal.t_length != 0) {
        if (vlen((Goal.origin - Player.origin)) <= Goal.t_length) {
            if (Goal.goal_effects & 16) {
                traceline(Goal.origin, Player.origin, 1, Goal);
                if (trace_fraction == 1) {
                    return (1);
                }
            } else {
                return (1);
            }
        }
    }
    if (Goal.classname != "info_tfgoal_timer") {
        if ((Goal.goal_effects & 1) && (Player == AP)) {
            return (1);
        }
        if ((Goal.goal_effects & 2) && (AP.team_no == Player.team_no)) {
            return (1);
        }
        if ((Goal.goal_effects & 4) && (AP.team_no != Player.team_no)) {
            return (1);
        }
        if ((Goal.goal_effects & 8) && (Player != AP)) {
            return (1);
        }
    }
    if ((Goal.maxammo_shells != 0) &&
            (Player.team_no == Goal.maxammo_shells)) {
        return (1);
    }
    if ((Goal.maxammo_nails != 0) &&
            (Player.team_no != Goal.maxammo_shells)) {
        return (1);
    }
    return (0);
};

void (entity Goal, entity Player, entity AP, float addb) Apply_Results = {
    local entity oldself;
    local entity te;
    local entity oldte;

    stuffcmd(Player, "bf\n");
    if (Goal.classname == "item_tfgoal") {
        Player.item_list = Player.item_list | Goal.item_list;
    }
    if (Player == AP) {
        if (Goal.count > 0) {
            if (Player.team_no > 0) {
                LogEventGoal(Player);
                TeamFortress_TeamIncreaseScore(Player.team_no, Goal.count);
                TeamFortress_TeamShowScores(2);
            }
        }
    }
    if (addb) {
        if (Player.health > 0) {
            if (Goal.health > 0 && !(duelmode && duel_no_packs)) {
                if (stockfull)
                    T_Heal(Player, Player.max_health, 0);
                else
                    T_Heal(Player, Goal.health, 0);
            }
            if (Goal.health < 0) {
                if ((0 - Player.health) > Goal.health) {
                    TF_T_Damage(Player, Goal, Goal, (Player.health + 1), 1,
                            0);
                } else {
                    TF_T_Damage(Player, Goal, Goal, (0 - Goal.health), 1,
                            0);
                }
            }
            if(!(duelmode && duel_no_packs)) {
                if (stockfull) {
                    if (Goal.armortype > 0) {
                        Player.armortype = Player.armor_allowed;
                        Player.armorvalue = Player.maxarmor;
                    } else if (Goal.armorvalue > 0) {
                        Player.armortype = Player.armor_allowed;
                        Player.armorvalue = Player.maxarmor;
                    }
                } else {
                    if (Goal.armortype > 0)
                        Player.armortype = Goal.armortype;
                    else if (Goal.armorvalue > 0)
                        Player.armortype = Player.armor_allowed;
                    Player.armorvalue = Player.armorvalue + Goal.armorvalue;
                }
                if (Goal.armorclass > 0)
                    Player.armorclass = Goal.armorclass;

                Player.ammo_shells = Player.ammo_shells + Goal.ammo_shells;
                Player.ammo_nails = Player.ammo_nails + Goal.ammo_nails;
                Player.ammo_rockets = Player.ammo_rockets + Goal.ammo_rockets;
                Player.ammo_cells = Player.ammo_cells + Goal.ammo_cells;
                Player.ammo_medikit = Player.ammo_medikit + Goal.ammo_medikit;
                Player.ammo_detpack = Player.ammo_detpack + Goal.ammo_detpack;
                //refill the clip if stock_reload is 2
                if (stock_reload == 2) {
                    if(Goal.ammo_shells) {
                        if(Player.current_weapon == WEAP_SHOTGUN) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_shotgun = max(Player.reload_shotgun - Goal.ammo_shells, 0);
                        if(Player.current_weapon == WEAP_SUPER_SHOTGUN) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_super_shotgun = max(Player.reload_super_shotgun - Goal.ammo_shells, 0);
                        if(Player.current_weapon == WEAP_SNIPER_RIFLE) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_sniper_rifle = max(Player.reload_sniper_rifle - Goal.ammo_shells, 0);

                        if(Player.current_weapon == WEAP_ASSAULT_CANNON) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_assault_cannon = max(Player.reload_assault_cannon - Goal.ammo_shells, 0);
                    }
                    if(Goal.ammo_rockets) {
                        if(Player.current_weapon == WEAP_GRENADE_LAUNCHER) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_grenade_launcher = max(Player.reload_grenade_launcher - Goal.ammo_rockets, 0);
                        if(Player.current_weapon == WEAP_ROCKET_LAUNCHER) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_rocket_launcher = max(Player.reload_rocket_launcher - Goal.ammo_rockets, 0);
                    }
                } else {
                    //for use in map entities without specifically enabling the general override
                    if(Goal.reload_shotgun) {
                        if(Player.current_weapon == WEAP_SHOTGUN) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_shotgun = max(Player.reload_shotgun - Goal.ammo_shells, 0);
                    }
                    if(Goal.reload_super_shotgun) {
                        if(Player.current_weapon == WEAP_SUPER_SHOTGUN) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_super_shotgun = max(Player.reload_super_shotgun - Goal.ammo_shells, 0);
                    }
                    if(Goal.reload_sniper_rifle) {
                        if(Player.current_weapon == WEAP_SNIPER_RIFLE) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_sniper_rifle = max(Player.reload_sniper_rifle - Goal.ammo_shells, 0);
                    }
                    if(Goal.reload_grenade_launcher) {
                        if(Player.current_weapon == WEAP_GRENADE_LAUNCHER) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_grenade_launcher = max(Player.reload_grenade_launcher - Goal.ammo_rockets, 0);
                    }
                    if(Goal.reload_rocket_launcher) {
                        if(Player.current_weapon == WEAP_ROCKET_LAUNCHER) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_rocket_launcher = max(Player.reload_rocket_launcher - Goal.ammo_rockets, 0);
                    }
                    if (Goal.reload_assault_cannon)
                    {
                        if(Player.current_weapon == WEAP_ASSAULT_CANNON) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                        }
                        Player.reload_assault_cannon = max(Player.reload_assault_cannon - Goal.ammo_shells, 0);
                    }  
                }
                Player.no_grenades_1 =
                    Player.no_grenades_1 + Goal.no_grenades_1;
                Player.no_grenades_2 =
                    Player.no_grenades_2 + Goal.no_grenades_2;
                
                if (Player.no_grenades_1 > Player.max_grenades_1) {
                    Player.no_grenades_1 = Player.max_grenades_1;
                }
                if (Player.no_grenades_2 > Player.max_grenades_2) {
                    Player.no_grenades_2 = Player.max_grenades_2;
                }

                if (Player.ammo_detpack > Player.maxammo_detpack) {
                    Player.ammo_detpack = Player.maxammo_detpack;
                }
                if (Player.tfstate & TFSTATE_GRENPRIMED) {
                    te = find(world, classname, "primer");
                    while (te) {
                        if (te.owner == Player) {
                            if ((te.impulse == TF_GRENADE_2) &&
                                    (Player.no_grenades_2 <= 0)) {
                                Player.tfstate =
                                    Player.tfstate -
                                    (Player.tfstate & TFSTATE_GRENPRIMED);
                                Player.tfstate =
                                    Player.tfstate -
                                    (Player.tfstate & TFSTATE_GRENTHROWING);
                                dremove(te);
                            } else if ((te.impulse == TF_GRENADE_1) &&
                                    (Player.no_grenades_1 <= 0)) {
                                Player.tfstate =
                                    Player.tfstate -
                                    (Player.tfstate & TFSTATE_GRENPRIMED);
                                Player.tfstate =
                                    Player.tfstate -
                                    (Player.tfstate & TFSTATE_GRENTHROWING);
                                dremove(te);
                            }
                            te = world;
                        } else {
                            te = find(te, classname, "primer");
                        }
                    }
                }
                if (Goal.invincible_finished > 0) {
                    Player.items = Player.items | IT_INVULNERABILITY;
                    Player.invincible_time = 1;
                    Player.invincible_finished =
                        time + Goal.invincible_finished;
                    if (Goal.classname == "item_tfgoal") {
                        Player.tfstate = Player.tfstate | TFSTATE_INVINCIBLE;
                        Player.invincible_finished = time + 666;
                    }
                }
                if (Goal.invisible_finished > 0) {
                    Player.items = Player.items | IT_INVISIBILITY;
                    Player.invisible_time = 1;
                    Player.invisible_finished = time + Goal.invisible_finished;
                    if (Goal.classname == "item_tfgoal") {
                        Player.tfstate = Player.tfstate | TFSTATE_INVISIBLE;
                        Player.invisible_finished = time + 666;
                    }
                }
                if (Goal.super_damage_finished > 0) {
                    Player.items = Player.items | IT_QUAD;
                    Player.super_time = 1;
                    Player.super_damage_finished =
                        time + Goal.super_damage_finished;
                    if (Goal.classname == "item_tfgoal") {
                        Player.tfstate = Player.tfstate | TFSTATE_QUAD;
                        Player.super_damage_finished = time + 666;
                    }
                }
                if (Goal.radsuit_finished > 0) {
                    Player.items = Player.items | IT_SUIT;
                    Player.rad_time = 1;
                    Player.radsuit_finished = time + Goal.radsuit_finished;
                    if (Goal.classname == "item_tfgoal") {
                        Player.tfstate = Player.tfstate | TFSTATE_RADSUIT;
                        Player.radsuit_finished = time + 666;
                    }
                }
            }
        }
            Player.lives = Player.lives + Goal.lives;

        if (Goal.frags) {
            if ((Goal.goal_effects == TFGE_AP) || !(toggleflags & TFLAG_FULLTEAMSCORE)) {
                TF_AddFrags(Player, Goal.frags);
            }

            if (stock_on_cap) {
                if (Player == AP) {
                    if (Player.health > 0) {
                        T_Heal(Player, Player.max_health, 0);
                        Player.armortype = Player.armor_allowed;
                        Player.armorvalue = Player.maxarmor;

                        Player.ammo_shells = Player.maxammo_shells;
                        Player.ammo_nails = Player.maxammo_nails;
                        Player.ammo_rockets = Player.maxammo_rockets;
                        Player.ammo_cells = Player.maxammo_cells;
                        Player.ammo_medikit = Player.maxammo_medikit;
                        Player.ammo_detpack = Player.maxammo_detpack;

                        Player.no_grenades_1 = Player.max_grenades_1;
                        Player.no_grenades_2 = Player.max_grenades_2;

                        te = find(Player, classname, "timer");

                        if (te.think == ConcussionGrenadeTimer || te.think == OldConcussionGrenadeTimer) {
                            if (old_grens == TRUE) {
                                stuffcmd(Player, "v_idlescale 0\nfov 90\n");
                            }
                            dremove(te);
                        }

                        if (Player.tfstate & TFSTATE_HALLUCINATING) {
                            if (te.think == HallucinationTimer) {
                                if (old_grens == TRUE) {
                                    stuffcmd(trace_ent, "v_cshift; wait; bf\n");
                                }
                                dremove(te);
                            }
                        }

                        if (Player.tfstate & TFSTATE_TRANQUILISED) {
                            if (te.think == TranquiliserTimer) {
                                Player.tfstate =
                                    Player.tfstate -
                                    (Player.tfstate & TFSTATE_TRANQUILISED);
                                TeamFortress_SetSpeed(Player);
                                dremove(te);
                            }
                        }

                        if (Player.tfstate & TFSTATE_INFECTED) {
                            Player.tfstate =
                                trace_ent.tfstate -
                                (trace_ent.tfstate & TFSTATE_INFECTED);
                        }

                        if (Player.numflames > 0) {
                            FO_Sound(Player, CHAN_WEAPON, "items/r_item1.wav", 1, ATTN_NORM);
                            SetFlameCount(Player, 0);
                        }

                        if (Player.FlashTime > 0) {
                            Player.FlashTime = 0;
                            stuffcmd(Player, "v_cshift; wait; bf\n");
                            te = find(Player, netname, "flashtimer");
                            dremove(te);
                        }
                        //Refill the clip while restocking
                        if (stock_reload) {
                            Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_RELOADING);
                            Player.reload_shotgun = 0;
                            Player.reload_super_shotgun = 0;
                            Player.reload_grenade_launcher = 0;
                            Player.reload_rocket_launcher = 0;
                            Player.reload_sniper_rifle = 0;
                            Player.reload_assault_cannon = 0;
                        }
                    }
                }
            }
        }

        oldself = self;
        self = Player;
        TeamFortress_CheckClassStats();
        W_SetCurrentAmmo(self);
        self = oldself;
    }
    if ((Player.playerclass == PC_SPY) &&
            (Goal.goal_result & TFGR_REMOVE_DISGUISE)) {
        self.immune_to_check = time + 10;
        Spy_RemoveDisguise(Player);
    }
    if ((Goal.items != 0) && (Goal.classname != "item_tfgoal")) {
        te = Finditem(Goal.items);
        if ((te != world) && (te != Goal))
            tfgoalitem_GiveToPlayer(te, Player, Goal);
    }
    if (Goal.axhitme != 0) {
        te = Finditem(Goal.axhitme);
        if (te.owner == Player)
            tfgoalitem_RemoveFromPlayer(te, Player, 1);
    }
    if (Goal.remove_item_group != 0) {
        te = find(world, classname, "item_tfgoal");
        while (te) {
            if ((te.group_no == Goal.remove_item_group) &&
                    (te.owner == AP)) {
                oldte = te;
                te = find(te, classname, "item_tfgoal");
                tfgoalitem_RemoveFromPlayer(oldte, Player, 1);
            } else
                te = find(te, classname, "item_tfgoal");
        }
    }
    if (Goal.display_item_status1 != 0) {
        te = Finditem(Goal.display_item_status1);
        if (te)
            DisplayItemStatus(Goal, Player, te);
        else
            sprint(Player, PRINT_HIGH, "Item is missing\n");
    }
    if (Goal.display_item_status2 != 0) {
        te = Finditem(Goal.display_item_status2);
        if (te)
            DisplayItemStatus(Goal, Player, te);
        else
            sprint(Player, PRINT_HIGH, "Item is missing\n");
    }
    if (Goal.display_item_status3 != 0) {
        te = Finditem(Goal.display_item_status3);
        if (te)
            DisplayItemStatus(Goal, Player, te);
        else
            sprint(Player, PRINT_HIGH, "Item is missing\n");
    }
    if (Goal.display_item_status4 != 0) {
        te = Finditem(Goal.display_item_status4);
        if (te)
            DisplayItemStatus(Goal, Player, te);
        else
            sprint(Player, PRINT_HIGH, "Item is missing\n");
    }
    if (Goal.goal_result & TFGR_FORCE_RESPAWN)
        ForceRespawn(Player);
};

void (entity Goal, entity Player) RemoveResults = {
    local entity oldself;
    local entity te;
    local float puinvin;
    local float puinvis;
    local float puquad;
    local float purad;

    if (Goal.classname == "item_tfgoal") {
        if (!(Player.item_list & Goal.item_list))
            return;
        if (Goal.goal_activation & TFGI_DONTREMOVERES)
            return;

        Player.item_list =
            Player.item_list - (Player.item_list & Goal.item_list);
    }
    if (Goal.health > 0)
        TF_T_Damage(Player, Goal, Goal, Goal.health, 1, 0);

    if (Goal.health < 0)
        T_Heal(Player, (0 - Goal.health), 0);

    Player.lives = Player.lives - Goal.lives;
    Player.armortype = Player.armortype - Goal.armortype;
    Player.armorvalue = Player.armorvalue - Goal.armorvalue;
    Player.armorclass =
        Player.armorclass - (Player.armorclass & Goal.armorclass);
    if (Goal.frags) {
        if ((Goal.goal_effects == TFGE_AP) ||
                !(toggleflags & TFLAG_FULLTEAMSCORE))
            TF_AddFrags(Player, Goal.frags);
    }
    Player.ammo_shells = Player.ammo_shells - Goal.ammo_shells;
    Player.ammo_nails = Player.ammo_nails - Goal.ammo_nails;
    Player.ammo_rockets = Player.ammo_rockets - Goal.ammo_rockets;
    Player.ammo_cells = Player.ammo_cells - Goal.ammo_cells;
    Player.ammo_medikit = Player.ammo_medikit - Goal.ammo_medikit;
    Player.ammo_detpack = Player.ammo_detpack - Goal.ammo_detpack;
    Player.no_grenades_1 = Player.no_grenades_1 - Goal.no_grenades_1;
    Player.no_grenades_2 = Player.no_grenades_2 - Goal.no_grenades_2;

    if (Player.no_grenades_1 > Player.max_grenades_1)
        Player.no_grenades_1 = Player.max_grenades_1;

    if (Player.no_grenades_2 > Player.max_grenades_2)
        Player.no_grenades_2 = Player.max_grenades_2;

    if (Player.ammo_detpack > Player.maxammo_detpack)
        Player.ammo_detpack = Player.maxammo_detpack;

    if (Player.tfstate & TFSTATE_GRENPRIMED) {
        te = find(world, classname, "primer");
        while (te) {
            if (te.owner == Player) {
                if ((te.impulse == TF_GRENADE_2) &&
                        (Player.no_grenades_2 <= 0)) {
                    Player.tfstate =
                        Player.tfstate -
                        (Player.tfstate & TFSTATE_GRENPRIMED);
                    Player.tfstate =
                        Player.tfstate -
                        (Player.tfstate & TFSTATE_GRENTHROWING);
                    dremove(te);
                } else if ((te.impulse == TF_GRENADE_1) &&
                        (Player.no_grenades_1 <= 0)) {
                    Player.tfstate =
                        Player.tfstate -
                        (Player.tfstate & TFSTATE_GRENPRIMED);
                    Player.tfstate =
                        Player.tfstate -
                        (Player.tfstate & TFSTATE_GRENTHROWING);
                    dremove(te);
                }
                te = world;
            } else
                te = find(te, classname, "primer");
        }
    }
    puinvin = 0;
    puinvis = 0;
    puquad = 0;
    purad = 0;
    te = find(world, classname, "item_tfgoal");
    while (te) {
        if ((te.owner == Player) && (te != Goal)) {
            if (te.invincible_finished > 0)
                puinvin = 1;
            if (te.invisible_finished > 0)
                puinvis = 1;
            if (te.super_damage_finished > 0)
                puquad = 1;
            if (te.radsuit_finished > 0)
                purad = 1;
        }
        te = find(te, classname, "item_tfgoal");
    }
    if ((Goal.invincible_finished > 0) && !puinvin) {
        Player.tfstate =
            Player.tfstate - (Player.tfstate & TFSTATE_INVINCIBLE);
        Player.items = Player.items | IT_INVULNERABILITY;
        Player.invincible_time = 1;
        Player.invincible_finished = time + Goal.invincible_finished;
    }
    if ((Goal.invisible_finished > 0) && !puinvis) {
        Player.tfstate =
            Player.tfstate - (Player.tfstate & TFSTATE_INVISIBLE);
        Player.items = Player.items | IT_INVISIBILITY;
        Player.invisible_time = 1;
        Player.invisible_finished = time + Goal.invisible_finished;
    }
    if ((Goal.super_damage_finished > 0) && !puquad) {
        Player.tfstate = Player.tfstate - (Player.tfstate & TFSTATE_QUAD);
        Player.items = Player.items | IT_QUAD;
        Player.super_time = 1;
        Player.super_damage_finished = time + Goal.super_damage_finished;
    }
    if ((Goal.radsuit_finished > 0) && !purad) {
        Player.tfstate =
            Player.tfstate - (Player.tfstate & TFSTATE_RADSUIT);
        Player.items = Player.items | IT_SUIT;
        Player.rad_time = 1;
        Player.radsuit_finished = time + Goal.radsuit_finished;
    }
    oldself = self;
    self = Player;
    TeamFortress_CheckClassStats();
    W_SetCurrentAmmo(self);
    self = oldself;
};

float (entity Goal, entity AP) APMeetsCriteria = {
    local float gotone;
    local entity te;

    if (AP != world) {
        if (Goal.team_no) {
            if (Goal.team_no != AP.team_no)
                return (0);
        }
        if (Goal.playerclass) {
            if (Goal.playerclass != AP.playerclass)
                return (0);
        }
        if (Goal.items_allowed) {
            te = Finditem(Goal.items_allowed);
            if (te.owner != AP)
                return (0);
        }
    }
    if (Goal.if_goal_is_active) {
        te = Findgoal(Goal.if_goal_is_active);
        if (te.goal_state != TFGS_ACTIVE)
            return (0);
    }
    if (Goal.if_goal_is_inactive) {
        te = Findgoal(Goal.if_goal_is_inactive);
        if (te.goal_state != TFGS_INACTIVE)
            return (0);
    }
    if (Goal.if_goal_is_removed) {
        te = Findgoal(Goal.if_goal_is_removed);
        if (te.goal_state != TFGS_REMOVED)
            return (0);
    }
    if (Goal.if_group_is_active) {
        te = find(world, classname, "info_tfgoal");
        while (te) {
            if (te.group_no == Goal.if_group_is_active) {
                if (te.goal_state != TFGS_ACTIVE)
                    return (0);
            }
            te = find(te, classname, "info_tfgoal");
        }
    }
    if (Goal.if_group_is_inactive) {
        te = find(world, classname, "info_tfgoal");
        while (te) {
            if (te.group_no == Goal.if_group_is_inactive) {
                if (te.goal_state != TFGS_INACTIVE)
                    return (0);
            }
            te = find(te, classname, "info_tfgoal");
        }
    }
    if (Goal.if_group_is_removed) {
        te = find(world, classname, "info_tfgoal");
        while (te) {
            if (te.group_no == Goal.if_group_is_removed) {
                if (te.goal_state != TFGS_REMOVED)
                    return (0);
            }
            te = find(te, classname, "info_tfgoal");
        }
    }
    if (Goal.if_item_has_moved) {
        te = Finditem(Goal.if_item_has_moved);
        if (te) {
            if ((te.goal_state != TFGS_ACTIVE) &&
                    (te.origin == te.oldorigin))
                return (0);
        }
    }
    if (Goal.if_item_hasnt_moved) {
        te = Finditem(Goal.if_item_hasnt_moved);
        if (te) {
            if ((te.goal_state == TFGS_ACTIVE) ||
                    (te.origin != te.oldorigin))
                return (0);
        }
    }
    if (AP != world) {
        gotone = 0;
        if (Goal.has_item_from_group) {
            te = find(world, classname, "item_tfgoal");
            while ((te != world) && !gotone) {
                if ((te.group_no == Goal.has_item_from_group) &&
                        (te.owner == AP))
                    gotone = 1;
                te = find(te, classname, "item_tfgoal");
            }
            if (!gotone)
                return (0);
        }
        if (Goal.hasnt_item_from_group) {
            te = find(world, classname, "item_tfgoal");
            while ((te != world) && !gotone) {
                if ((te.group_no == Goal.hasnt_item_from_group) &&
                        (te.owner == AP))
                    return (0);
                te = find(te, classname, "item_tfgoal");
            }
        }
    }
    return (1);
};

void (entity Goal) SetupRespawn = {
    if (Goal.search_time != 0) {
        InactivateGoal(Goal);
        Goal.think = tfgoal_timer_tick;
        Goal.nextthink = time + Goal.search_time;
        return;
    }
    if (Goal.goal_result & TFGR_SINGLE) {
        RemoveGoal(Goal);
        return;
    }
    if (Goal.wait > 0) {
        Goal.nextthink = time + Goal.wait;
        Goal.think = DoRespawn;
        return;
    } else if (Goal.wait == -1)
        return;

    InactivateGoal(Goal);
};

void () DoRespawn = {
    RestoreGoal(self);
    InactivateGoal(self);
};

float (entity Goal, entity AP) Activated = {
    local float APMet;
    local float RevAct;
    local float Act;

    if (Goal.goal_state == TFGS_ACTIVE)
        return (0);
    if (Goal.goal_state == TFGS_REMOVED)
        return (0);
    if (Goal.goal_state == TFGS_DELAYED)
        return (0);

    APMet = APMeetsCriteria(Goal, AP);
    if (Goal.classname == "item_tfgoal")
        RevAct = Goal.goal_activation & TFGI_REVERSE_AP;
    else
        RevAct = Goal.goal_activation & TFGI_DROP;

    Act = 0;
    if (APMet) {
        if (!RevAct)
            Act = 1;
    } else if (RevAct)
        Act = 1;

    return (Act);
};

void (entity Goal, entity AP, entity ActivatingGoal) AttemptToActivate = {
    local entity te;

    if (cb_prematch)
        return;

    // q3f support
    if (Goal.checkstate != "") {
        string cname, cstate;
        float slen, idx;
        entity targ;
        targ = world;
       
        idx = strstrofs(Goal.checkstate, "=");
        slen = strlen(Goal.checkstate);
        cname = substring(Goal.checkstate, 0, idx);
        targ = find(targ, targetname, cname);
        cstate = substring(Goal.checkstate, idx + 1, slen);
        switch (cstate)
        {
            case "inactive":
                if (targ.active == TFGS_ACTIVE) {
                    return;
                }
            break;
            case "active":
                if (targ.active == TFGS_INACTIVE) {
                    return;
                }
        }
    }

    if (Activated(Goal, AP)) {
        if (ActivatingGoal == Goal)
            DoResults(Goal, AP, 1);
        else if (ActivatingGoal != world)
            DoResults(Goal, AP, ActivatingGoal.goal_result & 2);
        else
            DoResults(Goal, AP, 0);
    } else if (Goal.else_goal != 0) {
        te = Findgoal(Goal.else_goal);
        if (te) {
            AttemptToActivate(te, AP, Goal);
        }
    }
};

void (entity Goal, entity AP) DoGoalWork = {
    local entity te;
    local entity RI;

    if (Goal.activate_goal_no != 0) {
        te = Findgoal(Goal.activate_goal_no);
        if (te)
            AttemptToActivate(te, AP, Goal);
    }
    if (Goal.inactivate_goal_no != 0) {
        te = Findgoal(Goal.inactivate_goal_no);
        if (te)
            InactivateGoal(te);
    }
    if (Goal.restore_goal_no != 0) {
        te = Findgoal(Goal.restore_goal_no);
        if (te)
            RestoreGoal(te);
    }
    if (Goal.remove_goal_no != 0) {
        te = Findgoal(Goal.remove_goal_no);
        if (te)
            RemoveGoal(te);
    }
    if (Goal.return_item_no != 0) {
        te = Finditem(Goal.return_item_no);
        if (te) {
            if (te.goal_state == 1)
                tfgoalitem_RemoveFromPlayer(te, te.owner, 1);
            RI = spawn();
            RI.enemy = te;
            RI.weapon = 2;
            RI.think = ReturnItem;
            RI.nextthink = time + 0.1;
            te.solid = 0;
        }
    }
    if (Goal.remove_spawnpoint != 0) {
        te = Findteamspawn(Goal.remove_spawnpoint);
        if (te) {
            te.goal_state = 3;
            te.team_str_home = string_null;
        }
    }
    if (Goal.restore_spawnpoint != 0) {
        te = Findteamspawn(Goal.restore_spawnpoint);
        if (te) {
            if (te.goal_state == 3) {
                te.goal_state = 2;
                if (te.team_no == 1) {
                    te.team_str_home = "ts1";
                } else if (te.team_no == 2) {
                    te.team_str_home = "ts2";
                } else if (te.team_no == 3) {
                    te.team_str_home = "ts3";
                } else if (te.team_no == 4) {
                    te.team_str_home = "ts4";
                }
            }
        }
    }
};

void (entity Goal, entity AP, string cname) DoGroupWorkByClass = {
    local string st;
    local entity tg;
    local float allset;

    if (Goal.all_active != 0) {
        if (Goal.last_impulse == 0) {
            dprint("Goal ");
            st = ftos(Goal.goal_no);
            dprint(st);
            dprint(" has a .all_active specified, but no .last_impulse\n");
        } else {
            allset = 1;
            tg = find(world, classname, cname);
            while (tg) {
                if (tg.group_no == Goal.all_active) {
                    if (tg.goal_state != 1) {
                        allset = 0;
                    }
                }
                tg = find(tg, classname, cname);
            }
            if (allset) {
                tg = Findgoal(Goal.last_impulse);
                if (tg) {
                    DoResults(tg, AP, (Goal.goal_result & 2));
                }
            }
        }
    }    

    if (Goal.activate_group_no != 0) {
        tg = find(world, classname, cname);
        while (tg) {
            if (tg.group_no == Goal.activate_group_no) {
                DoResults(tg, AP, 0);
            }
            tg = find(tg, classname, cname);
        }
    }
    if (Goal.inactivate_group_no != 0) {
        tg = find(world, classname, cname);
        while (tg) {
            if (tg.group_no == Goal.inactivate_group_no) {
                InactivateGoal(tg);
            }
            tg = find(tg, classname, cname);
        }
    }
    if (Goal.remove_group_no != 0) {
        tg = find(world, classname, cname);
        while (tg) {
            if (tg.group_no == Goal.remove_group_no) {
                RemoveGoal(tg);
            }
            tg = find(tg, classname, cname);
        }
    }
    if (Goal.restore_group_no != 0) {
        tg = find(world, classname, cname);
        while (tg) {
            if (tg.group_no == Goal.restore_group_no) {
                RestoreGoal(tg);
            }
            tg = find(tg, classname, cname);
        }
    }
    if (Goal.default_group_no != 0)
    {
        tg = find(world, classname, cname);
        while (tg) {
            if (tg.group_no == Goal.default_group_no) {
                DefaultGoalState(tg);
            }
            tg = find(tg, classname, cname);
        }
    }

    if (Goal.remove_spawngroup != 0) {
        tg = find(world, classname, "info_player_teamspawn");
        while (tg) {
            if (tg.group_no == Goal.remove_spawngroup) {
                tg.goal_state = 3;
                tg.team_str_home = string_null;
            }
            tg = find(tg, classname, "info_player_teamspawn");
        }
    }
    if (Goal.restore_spawngroup != 0) {
        tg = find(world, classname, "info_player_teamspawn");
        while (tg) {
            if (tg.group_no == Goal.restore_spawngroup) {
                tg.goal_state = 2;
                if (tg.team_no == 1) {
                    tg.team_str_home = "ts1";
                } else {
                    if (tg.team_no == 2) {
                        tg.team_str_home = "ts2";
                    } else {
                        if (tg.team_no == 3) {
                            tg.team_str_home = "ts3";
                        } else {
                            if (tg.team_no == 4) {
                                tg.team_str_home = "ts4";
                            }
                        }
                    }
                }
            }
            tg = find(tg, classname, "info_player_teamspawn");
        }
    }
};

void (entity Item, entity AP) DoItemGroupWork = {
    local entity tg;
    local entity carrier;
    local float allcarried;
    local string st;

    allcarried = 1;
    if (Item.distance != 0) {
        if (Item.pain_finished == 0) {
            dprint("GoalItem ");
            st = ftos(Item.goal_no);
            dprint(st);
            dprint(" has a .distance specified, but no .pain_finished\n");
        }
        tg = find(world, classname, "item_tfgoal");
        while (tg) {
            if (tg.group_no == Item.distance) {
                if (tg.goal_state != 1) {
                    allcarried = 0;
                }
            }
            tg = find(tg, classname, "item_tfgoal");
        }
        if (allcarried == 1) {
            tg = Findgoal(Item.pain_finished);
            if (tg) {
                DoResults(tg, AP, (Item.goal_result & 2));
            }
        }
    }
    allcarried = 1;
    if (Item.speed != 0) {
        if (Item.attack_finished == 0) {
            dprint("GoalItem ");
            st = ftos(Item.goal_no);
            dprint(st);
            dprint(" has a .speed specified, but no .attack_finished\n");
        }
        carrier = world;
        tg = find(world, classname, "item_tfgoal");
        while (tg) {
            if (tg.group_no == Item.speed) {
                if (tg.goal_state != 1) {
                    allcarried = 0;
                } else {
                    if (carrier == world) {
                        carrier = tg.owner;
                    } else {
                        if (carrier != tg.owner) {
                            allcarried = 0;
                        }
                    }
                }
            }
            tg = find(tg, classname, "item_tfgoal");
        }
        if (allcarried == 1) {
            tg = Findgoal(Item.attack_finished);
            if (tg) {
                DoResults(tg, AP, (Item.goal_result & 2));
            }
        }
    }
};



void (entity Goal, entity AP) DoGroupWork = 
{
    for (float i = 0; i < goal_class_names.length; i++)
    {
        DoGroupWorkByClass(Goal, AP, goal_class_names[i]);
    }
};

void (entity Goal, entity AP) DoTriggerWork = {
    local entity t;

    if (Goal.killtarget) {
        t = world;
        do {
            t = find(t, targetname, Goal.killtarget);
            if (t != world)
                remove(t);
        } while (t != world);
    }
    if (Goal.target) {
        t = world;
        activator = AP;
        do {
            t = find(t, targetname, Goal.target);
            if (t == world)
                return;
            stemp = self;
            otemp = other;
            self = t;
            other = stemp;
            if (self.use != SUB_Null) {
                if (self.use)
                    self.use();
            }
            self = stemp;
            other = otemp;
            activator = AP;
        } while (t != world);
    }
};

void () DelayedResult = {
    entity oself = self;
    if (self.enemy.goal_state == TFGS_DELAYED)
        DoResults(self.enemy, self.owner, self.weapon);

    dremove(oself);
};

void (entity Goal, entity AP, float addb) DoResults = {   
    local entity te;
    local float winners;
    local float gotone;

    if (cb_prematch && !(Goal.spawnflags & TFGI_CB_IGNORE)) {
        return;
    }
    if (Goal.goal_state == TFGS_ACTIVE) {
        return;
    }
    if ((Goal.delay_time > 0) && (Goal.goal_state != TFGS_DELAYED)) {
        Goal.goal_state = TFGS_DELAYED;
        te = spawn();
        te.think = DelayedResult;
        te.nextthink = time + Goal.delay_time;
        te.owner = AP;
        te.enemy = Goal;
        te.weapon = addb;
        Goal.bubble_count = time + Goal.delay_time;
        return;
    }

    UpdateAbbreviations(Goal);
    Goal.goal_state = TFGS_INACTIVE;
    if ((Goal.classname == "info_tfgoal") && (Goal.mdl != string_null)) {
        setmodel(Goal, string_null);
    }

    if (Goal.noise) {
        if (other == world) {
            FO_Sound(Goal, CHAN_ITEM, Goal.noise, 1, 1);
        } else {
            FO_Sound(other, CHAN_ITEM, Goal.noise, 1, 1);
        }
    }
    winners = 0;
    if (Goal.increase_team1 != 0) {
        TeamFortress_TeamIncreaseScore(1, Goal.increase_team1);
        winners = 1;
    }
    if (Goal.increase_team2 != 0) {
        TeamFortress_TeamIncreaseScore(2, Goal.increase_team2);
        winners = 1;
    }
    if (Goal.increase_team3 != 0) {
        TeamFortress_TeamIncreaseScore(3, Goal.increase_team3);
        winners = 1;
    }
    if (Goal.increase_team4 != 0) {
        TeamFortress_TeamIncreaseScore(4, Goal.increase_team4);
        winners = 1;
    }
    if (winners == 1) {
        TeamFortress_TeamShowScores(2);
        LogEventGoal(AP);
    }
    if (CTF_Map == 1) {
        if (AP != world) {
            if (Goal.goal_no == 1) {
                te = find(world, classname, "player");
                while (te != world) {
                    if (te.team_no == 2) {
                        if (te == AP) {
                            winners = random();
                            if (winners < 0.1) {
                                CenterPrint2(te, "\n\n\n",
                                        "You got the enemy flag!\n\nFlee!");
                            } else {
                                if (winners < 0.2) {
                                    CenterPrint2(te, "\n\n\n",
                                            "You got the enemy flag!\n\nHead for home!");
                                } else {
                                    if (winners < 0.6) {
                                        CenterPrint2(te, "\n\n\n",
                                                "You got the enemy flag!\n\nReturn to base!");
                                    } else {
                                        if (winners < 0.7) {
                                            CenterPrint2(te, "\n\n\n",
                                                    "You got the enemy flag!\n\n<Insert witty comment here>");
                                        } else {
                                            if (winners < 0.8) {
                                                CenterPrint2(te, "\n\n\n",
                                                        "You got the enemy flag!\n\n");
                                            } else {
                                                if (winners < 0.95) {
                                                    CenterPrint2(te,
                                                            "\n\n\n",
                                                            "You got the enemy flag!\n\n");
                                                } else {
                                                    CenterPrint2(te,
                                                            "\n\n\n",
                                                            "Is that a flag in your pocket\nor are you just happy to see me?");
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            CenterPrint2(te, "\n\n\n",
                                    Q"Your team \sgot\s the \senemy\s flag!!");
                        }
                    } else {
                        CenterPrint2(te, "\n\n\n",
                                Q"Your flag has been \staken\s!!");
                    }
                    te = find(te, classname, "player");
                }
                bprint(PRINT_HIGH, AP.netname, Q" \sgot\s the \sblue\s flag!\n");
                AP.items = AP.items | IT_KEY1;
            } else {
                if (Goal.goal_no == 2) {
                    te = find(world, classname, "player");
                    while (te != world) {
                        if (te.team_no == 1) {
                            if (te == AP) {
                                winners = random();
                                if (winners < 0.1) {
                                    CenterPrint2(te, "\n\n\n",
                                            "You got the enemy flag!\n\nFlee!");
                                } else {
                                    if (winners < 0.2) {
                                        CenterPrint2(te, "\n\n\n",
                                                "You got the enemy flag!\n\nHead for home!");
                                    } else {
                                        if (winners < 0.6) {
                                            CenterPrint2(te, "\n\n\n",
                                                    "You got the enemy flag!\n\nReturn to base!");
                                        } else {
                                            if (winners < 0.7) {
                                                CenterPrint2(te, "\n\n\n",
                                                        "You got the enemy flag!\n\n<Insert witty comment here>");
                                            } else {
                                                if (winners < 0.8) {
                                                    CenterPrint2(te,
                                                            "\n\n\n",
                                                            "You got the enemy flag!\n\nRed's dead baby, Red's dead...");
                                                } else {
                                                    if (winners < 0.95) {
                                                        CenterPrint2(te,
                                                                "\n\n\n",
                                                                "You got the enemy flag!\n\n");
                                                    } else {
                                                        CenterPrint2(te,
                                                                "\n\n\n",
                                                                "Is that a flag in your pocket\nor are you just happy to see me?");
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                CenterPrint2(te, "\n\n\n",
                                        Q"Your team \sgot\s the \senemy\s flag!!");
                            }
                        } else {
                            CenterPrint2(te, "\n\n\n",
                                    Q"Your flag has been \staken\s!!");
                        }
                        te = find(te, classname, "player");
                    }
                    bprint(PRINT_HIGH, AP.netname, Q" \sgot\s the \sred\s flag!\n");
                    AP.items = AP.items | IT_KEY2;
                } else {
                    if (Goal.goal_no == 3) {
                        te = find(world, classname, "player");
                        while (te != world) {
                            if (te.team_no == 2) {
                                if (te == AP) {
                                    CenterPrint2(te, "\n\n\n",
                                            Q"You \scaptured\s the flag!!");
                                } else {
                                    CenterPrint2(te, "\n\n\n",
                                            Q"Your flag was \scaptured\s!!");
                                }
                            } else {
                                CenterPrint2(te, "\n\n\n",
                                        Q"Your team \scaptured\s the flag!!");
                            }
                            te = find(te, classname, "player");
                        }
                        bprint(PRINT_HIGH, AP.netname,
                                Q" \scaptured\s the \sred\s flag!\n");
                        AP.items = AP.items - (AP.items & IT_KEY2);
                    } else {
                        if (Goal.goal_no == 4) {
                            te = find(world, classname, "player");
                            while (te != world) {
                                if (te.team_no == 1) {
                                    if (te == AP) {
                                        CenterPrint2(te, "\n\n\n",
                                                Q"You \scaptured\s the flag!!");
                                    } else {
                                        CenterPrint2(te, "\n\n\n",
                                                Q"Your flag was \scaptured\s!!");
                                    }
                                } else {
                                    CenterPrint2(te, "\n\n\n",
                                            Q"Your team \scaptured\s the flag!!");
                                }
                                te = find(te, classname, "player");
                            }
                            bprint(PRINT_HIGH, AP.netname,
                                    Q" \scaptured\s the \sblue\s flag!\n");
                            AP.items = AP.items - (AP.items & IT_KEY1);
                        }
                    }
                }
            }
        }
    }
    gotone = 0;
    if ((strtrim(Goal.broadcast_high) != "") && (CTF_Map == 0)) {
        bprint(PRINT_HIGH, Goal.broadcast_high);
    }
    te = find(world, classname, "player");
    while (te != world) {
        if ((Goal.broadcast != string_null) && (CTF_Map == 0)) {
            CenterPrint2(te, "\n\n\n", Goal.broadcast);
        }
        
        if ((strtrim(Goal.netname_broadcast) != "") && (CTF_Map == 0)) {
            sprint(te, PRINT_HIGH, AP.netname, Goal.netname_broadcast);
        }
        if (AP == te) {
            if (Goal.message != string_null) {
                CenterPrint2(te, "\n\n\n", Goal.message);
            }
        } else {
            if (AP.team_no == te.team_no) {
                if ((Goal.owners_team_broadcast != string_null) &&
                        (te.team_no == Goal.owned_by)) {
                    CenterPrint2(te, "\n\n\n", Goal.owners_team_broadcast);
                } else {
                    if (Goal.team_broadcast != string_null) {
                        CenterPrint2(te, "\n\n\n", Goal.team_broadcast);
                    }
                }
                if ((Goal.netname_owners_team_broadcast != string_null) &&
                        (te.team_no == Goal.owned_by)) {
                    sprint(te, PRINT_HIGH, AP.netname,
                            Goal.netname_owners_team_broadcast);
                } else {
                    if (Goal.netname_team_broadcast != string_null) {
                        sprint(te, PRINT_HIGH, AP.netname,
                                Goal.netname_team_broadcast);
                    }
                }
            } else {
                if ((Goal.owners_team_broadcast != string_null) &&
                        (te.team_no == Goal.owned_by)) {
                    CenterPrint2(te, "\n\n\n", Goal.owners_team_broadcast);
                } else {
                    if (Goal.non_team_broadcast != string_null) {
                        CenterPrint2(te, "\n\n\n",
                                Goal.non_team_broadcast);
                    }
                }
                if ((Goal.netname_owners_team_broadcast != string_null) &&
                        (te.team_no == Goal.owned_by)) {
                    sprint(te, PRINT_HIGH, AP.netname,
                            Goal.netname_owners_team_broadcast);
                } else {
                    if (Goal.netname_non_team_broadcast != string_null) {
                        sprint(te, PRINT_HIGH, AP.netname,
                                Goal.netname_non_team_broadcast);
                    }
                }
            }
        }
        if (IsAffectedBy(Goal, te, AP)) {
            if ((Goal.search_time != 0) && (Goal.goal_effects & 64)) {
                if (APMeetsCriteria(Goal, te)) {
                    Apply_Results(Goal, te, AP, addb);
                    gotone = 1;
                }
            } else {
                Apply_Results(Goal, te, AP, addb);
                gotone = 1;
            }
        }
        te = find(te, classname, "player");
    }
    if (Goal.classname != "item_tfgoal") {
        Goal.goal_state = TFGS_ACTIVE;
    }
    if (Goal.goal_result & 4) {
        TeamFortress_TeamShowScores(1);
        winners = TeamFortress_TeamGetWinner();
        te = find(world, classname, "player");
        while (te) {
            te.takedamage = 0;
            te.movetype = 0;
            te.velocity = '0 0 0';
            te.avelocity = '0 0 0';
            te = find(te, classname, "player");
        }
        te = spawn();
        te.nextthink = time + 5;
        te.think = execute_changelevel;
        dremove(Goal);
        return;
    }
    DoGroupWork(Goal, AP);
    DoGoalWork(Goal, AP);
    DoTriggerWork(Goal, AP);
    if (Goal.classname == "info_tfgoal") {
        SetupRespawn(Goal);
    }
};

void () tfgoal_touch = {
    local entity te;

    if (!(self.goal_activation & TFGA_TOUCH))
        return;
    if (other.classname != "player")
        return;
    if (cb_prematch)
        return;
    if (self.goal_state == TFGS_ACTIVE)
        return;

    if (CTF_Map == 1) {
        if ((self.goal_no == 3) && (other.team_no == 1)) {
            te = Finditem(1);
            if ((te.goal_state == 1) || (te.origin != te.oldorigin))
                return;
        }
        if ((self.goal_no == 4) && (other.team_no == 2)) {
            te = Finditem(2);
            if ((te.goal_state == 1) || (te.origin != te.oldorigin))
                return;
        }
    }
    AttemptToActivate(self, other, self);
};

void () info_tfgoal_use = {
    AttemptToActivate(self, activator, self);
};

void () tfgoal_timer_tick = {
    if (self.goal_state != 3) {
        if (APMeetsCriteria(self, world))
        {
            //bprint(PRINT_HIGH, "meets criteria, doing results\n");
            DoResults(self, world, 1);

            // redo think here too, as quadmode breaks proper timers 
            // in DoResults due to return after cb_prematch test
            self.think = tfgoal_timer_tick;
            self.nextthink = time + self.search_time;
        }
        else {
            //bprint(PRINT_HIGH, "inactivating timer\n");
            InactivateGoal(self);
            self.think = tfgoal_timer_tick;
            self.nextthink = time + self.search_time;
        }
    }
};

void () item_tfgoal_touch = {
    local entity te;

    if (other.classname != "player")
        return;
    if (other.health <= 0)
        return;
    if (cb_prematch)
        return;
    if (other.is_feigning)
        return;
    if (other == self.owner)
        return;

    // check if a wall or something is in the way of the flag
    traceline(other.origin, self.origin, TRUE, world);
    if (trace_fraction < 1)
        return;

    if (CTF_Map == 1) {
        if (self.goal_no == 1) {
            if (self.origin != self.oldorigin) {
                if (other.team_no == 1) {
                    bprint(2, other.netname);
                    bprint(2, Q" \scaptured\s the \sblue\s flag!\n");
                    te = find(world, classname, "player");
                    while (te != world) {
                        if (te.team_no == 1) {
                            CenterPrint2(te, "\n\n\n",
                                    Q"Your flag was \scaptured\s!!");
                        } else {
                            CenterPrint2(te, "\n\n\n",
                                    Q"The \senemy\s flag was \scaptured\s!!");
                        }
                        te = find(te, classname, "player");
                    }
                    self.goal_state = 2;
                    self.solid = 1;
                    self.touch = item_tfgoal_touch;
                    self.origin = self.oldorigin;
                    FO_SetModel(self, self.mdl);
                    setorigin(self, self.origin);
                   FO_Sound(self, CHAN_VOICE, "items/itembk2.wav", 1, 1);
                    return;
                }
            } else {
                if (other.team_no == 1) {
                    return;
                }
            }
        } else {
            if (self.goal_no == 2) {
                if (self.origin != self.oldorigin) {
                    if (other.team_no == 2) {
                        bprint(2, other.netname);
                        bprint(2, Q" \scaptured\s the \sred\s flag!\n");
                        te = find(world, classname, "player");
                        while (te != world) {
                            if (te.team_no == 2) {
                                CenterPrint(te,
                                        Q"\n\n\n Your flag was \scaptured\s!!");
                            } else {
                                CenterPrint(te,
                                        Q"\n\n\n The \senemy\s flag was \scaptured\s!!");
                            }
                            te = find(te, classname, "player");
                        }
                        self.goal_state = 2;
                        self.solid = 1;
                        self.touch = item_tfgoal_touch;
                        self.origin = self.oldorigin;
                        FO_SetModel(self, self.mdl);
                        setorigin(self, self.origin);
                        FO_Sound(self, CHAN_VOICE, "items/itembk2.wav", 1, 1);
                        return;
                    }
                } else {
                    if (other.team_no == 2) {
                        return;
                    }
                }
            }
        }
    }
    if (Activated(self, other)) {
        tfgoalitem_GiveToPlayer(self, other, self);
        if (other.health > 0) {
            self.goal_state = 1;
        }
    } else {
        if (self.else_goal != 0) {
            te = Findgoal(self.else_goal);
            if (te) {
                AttemptToActivate(te, other, self);
            }
        } else {
            //Make sure we don't try to follow someone who fails the criteria
            return;
        }
    }
    
    if (flag_follow) {
        newmis = spawn();
        newmis.owner = other;
        newmis.classname = "flagfollow";
        newmis.solid = SOLID_NOT;
        newmis.mdl = self.mdl;
        FO_SetModel(newmis, self.mdl);
        setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
        vector org;
        org = other.origin + '-25 0 10';
        setorigin (newmis, org);
        newmis.skin = self.skin;
        newmis.movetype = MOVETYPE_FOLLOW;
        newmis.aiment = other;
        newmis.view_ofs = newmis.origin - other.origin;
    }
};

void RemoveFlagFollow(entity player)
{
    if (flag_follow)
    {
        entity ff = find(world, classname, "flagfollow");
        while (ff)
        {
            if (ff.owner == player)
            {
                dremove(ff);
            }
            ff = find(ff, classname, "flagfollow");
        }
    }
}

void (entity Item, entity AP, entity Goal) tfgoalitem_GiveToPlayer = {
    Item.effects = 0;

    Item.owner = AP;
    if (Item.mdl != string_null) {
        setmodel(Item, string_null);
    }
    Item.solid = 0;
    if (Item.goal_activation & TFGI_GLOW) {
        AP.effects = EF_DIMLIGHT;
    }

    if (Item.goal_activation & TFGI_SLOW)
        TeamFortress_SetSpeed(AP);

    /* if (Item.goal_activation & TFGI_ITEMGLOWS) */
    /*     Item.effects = EF_DIMLIGHT; */

    if (Item.items & IT_KEY1) {
        AP.items = AP.items | IT_KEY1;
        if (Item.message == string_null) {
            Status_Print(AP, "\n\n\n", "You got the enemy flag!");
        }
        // else is taken care of in DoResults()
    }

    if (Item.items & IT_KEY2) {
        AP.items = AP.items | IT_KEY2;
        if (Item.message == string_null) {
            Status_Print(AP, "\n\n\n", "You got the enemy flag!");
        }
        // else is taken care of in DoResults()
    }

    if (Goal != Item) {
        if (Goal.goal_result & TFGR_NO_ITEM_RESULTS) {
            Item.goal_state = TFGS_ACTIVE;
            return;
        }
    }
    if ((AP.playerclass == PC_SPY) && (Item.goal_result & TFGR_REMOVE_DISGUISE)) {
        AP.is_unabletospy = 1;
        AP.disguise_skin = 0;
        AP.disguise_team = 0;
    }

    // disable spy menu
    if (AP.menu_input == Menu_Spy_Input || AP.menu_input == Menu_Spy_Skin_Input || AP.menu_input == Menu_Spy_Color_Input)
        AP.menu_input = nil;

    Status_Refresh(AP);
    DoResults(Item, AP, 1);
    DoItemGroupWork(Item, AP);
    AP.goalrunningtime = gametime;
    LogEventPickupGoal(AP);
};

void () ReturnItem = {
    local entity te;

    if (self.enemy.touch == item_tfgoal_hidden_touch)
        return;

    self.enemy.goal_state = 2;
    if ((self.enemy.goal_activation & 8192) &&
            (self.enemy.classname == "item_tfgoal"))
        self.enemy.solid = 2;
    else
        self.enemy.solid = 1;

    self.enemy.movetype = 0;
    self.enemy.touch = item_tfgoal_touch;
    self.enemy.origin = self.enemy.oldorigin;

    if (self.enemy.model)
    {
        entity oldself;
        oldself = self;
        self = self.enemy;
        TF_Item_ApplyGlow();
        self = oldself;
        FO_SetModel(self.enemy, self.enemy.mdl);
    }

	setsize(self.enemy, VEC_HULL_MIN, VEC_HULL_MAX);
    setorigin(self.enemy, self.enemy.origin);
    tfgoalitem_checkgoalreturn(self.enemy);

    FO_Sound(self.enemy, CHAN_VOICE, "items/itembk2.wav", 1, 1);

    if (self.weapon != 2) {
        if ((self.enemy.noise3) || (self.enemy.noise4)) {
            te = find(world, classname, "player");
            while (te) {
                if (te.team_no == self.enemy.owned_by)
                    CenterPrint2(te, "\n\n\n", self.enemy.noise3);
                else
                    CenterPrint2(te, "\n\n\n", self.enemy.noise4);
                te = find(te, classname, "player");
            }
        }
    }
    dremove(self);
};

void (entity Item, entity AP, float method) tfgoalitem_RemoveFromPlayer = {
    local entity te;
    local entity DelayReturn;

    if (Item == world) {
        objerror("error: tfgoalitem_RemoveFromPlayer(): Item == world");
        return;
    }

    tfgoalitem_RemoveEffectsFromPlayer(Item, AP);
    Item.angles = '0 0 0';

    te = find(world, classname, "player");
    while (te != world) {
        if (IsAffectedBy(Item, te, AP))
            RemoveResults(Item, te);
        te = find(te, classname, "player");
    }
    //Flag
    if ((Item.goal_activation & 1)) {
        local float timecarried = gametime - AP.goalrunningtime;
        RemoveFlagFollow(AP);
        LogEventFumble(AP, timecarried);
    }

    if ((method == 0) || (method == 2)) {
        te = find(world, classname, "player");
        while (te != world) {
            if (te.team_no == Item.owned_by) {
                if (Item.team_drop != string_null)
                    CenterPrint2(te, "\n\n\n", Item.team_drop);

                if (Item.netname_team_drop != string_null) {
                    sprint(te, PRINT_HIGH, AP.netname,
                            Item.netname_team_drop);
                }
            } else {
                if (Item.non_team_drop != string_null)
                    CenterPrint2(te, "\n\n\n", Item.non_team_drop);

                if (Item.netname_non_team_drop != string_null) {
                    sprint(te, PRINT_HIGH, AP.netname,
                            Item.netname_non_team_drop);
                }
            }
            te = find(te, classname, "player");
        }
        if (Item.goal_activation & 8) {
            DelayReturn = spawn();
            DelayReturn.enemy = Item;
            if (method == 0) {
                DelayReturn.weapon = 0;
            } else {
                DelayReturn.weapon = 1;
            }
            DelayReturn.think = ReturnItem;
            DelayReturn.nextthink = time + 0.5;
        } else {
            if (Item.goal_activation & 4) {
                if ((method == 2) && (Item.goal_activation & 4096)) {
                    tfgoalitem_drop(Item, 1, AP);
                } else {
                    tfgoalitem_drop(Item, 0, AP);
                }
            } else {
                Item.owner = world;
                dremove(Item);
                TeamFortress_SetSpeed(AP);
                return;
            }
        }
        Item.owner = world;
        Item.flags = Item.flags - (Item.flags & 512);
        setsize(Item, Item.goal_min, Item.goal_max);
        TeamFortress_SetSpeed(AP);
        return;
    } else {
        if (method == 1) {
            if (Item.goal_activation & 16) {
                DelayReturn = spawn();
                DelayReturn.enemy = Item;
                DelayReturn.weapon = 2;
                DelayReturn.think = ReturnItem;
                DelayReturn.nextthink = time + 0.5;
                Item.owner = world;
                TeamFortress_SetSpeed(AP);
                return;
            }
            Item.solid = 0;
            Item.owner = world;
            TeamFortress_SetSpeed(AP);
            return;
        }
    }
    objerror("Invalid method passed into tfgoalitem_RemoveFromPlayer\n");
};

void (entity Item, entity AP) tfgoalitem_RemoveEffectsFromPlayer = {
    local entity te;
    local float lighton = 0;
    local float slowon = 0;
    local float key1on = 0;
    local float key2on = 0;
    local float spyoff = 0;

    te = find(world, classname, "item_tfgoal");
    while (te) {
        if ((te.owner == AP) && (te != Item)) {
            if (te.goal_activation & 1)
                lighton = 1;

            if (te.goal_activation & 2)
                slowon = 1;

            if (te.items & 131072)
                key1on = 1;

            if (te.items & 262144)
                key2on = 1;

            if (te.goal_result & 16)
                spyoff = 1;
        }
        te = find(te, classname, "item_tfgoal");
    }
    if (!lighton) {
        if (AP.invincible_finished > (time + 3)) {
            lighton = 1;
        } else if (AP.super_damage_finished > (time + 3)) {
            lighton = 1;
        }
    }
    if (!lighton) {
        AP.effects = AP.effects - (AP.effects & 8);
        AP.effects = AP.effects - (AP.effects & 64);
        AP.effects = AP.effects - (AP.effects & 128);
    }
    /* if (Item.goal_activation & 512) */
    /*     Item.effects = Item.effects | 8; */

    if (!spyoff)
        AP.is_unabletospy = 0;

    if (!key1on)
        AP.items = AP.items - (AP.items & 131072);

    if (!key2on)
        AP.items = AP.items - (AP.items & 262144);

    Status_Refresh(AP);
};

void () tfgoalitem_dropthink = {
    local float pos;

    self.movetype = 6;
    if (self.pausetime != 0) {
        pos = pointcontents(self.origin);
        if (pos == CONTENT_SLIME) { 
            self.nextthink = time + (self.pausetime / 4);
        } else {
            if (pos == CONTENT_LAVA) { 
                self.nextthink = time + 5;
                self.think = tfgoalitem_remove;
                return;
            } else {
                if ((pos == CONTENT_SOLID) || (pos == CONTENT_SKY)) { 
                    if (self.camdist < 3) {
                        self.origin = self.camangle;
                        setorigin(self, self.origin);
                        self.velocity_z = 400;
                        self.velocity_x = -50 + (random() * 100);
                        self.velocity_y = -50 + (random() * 100);
                        self.goal_state = 2;
                        self.movetype = 6;
                        if (self.goal_activation & 8192) {
                            self.solid = 2;
                        } else {
                            self.solid = 1;
                        }
                        if (self.mdl != string_null) {
                            FO_SetModel(self, self.mdl);
                        }
                        setsize(self, self.goal_min, self.goal_max);
                        self.camdist = self.camdist + 1;
                        self.nextthink = time + 5;
                        self.think = tfgoalitem_dropthink;
                        return;
                    } else {
                        self.nextthink = time + 2;
                    }
                } else {
                    self.nextthink = time + self.pausetime;
                }
            }
        }
        if(!noreturn) {
            self.think = tfgoalitem_remove;
        }
    }
};

void () tfgoalitem_droptouch = {
    self.touch = item_tfgoal_touch;
    self.nextthink = time + 4.25;
    self.think = tfgoalitem_dropthink;
};

void (entity Item, float PAlive, entity P) tfgoalitem_drop = {
    entity oldself;
    oldself = self;
    self = Item;
    TF_Item_ApplyGlow();
    self = oldself;

    Item.origin = Item.owner.origin;
    setorigin(Item, Item.origin);
    Item.camangle = Item.owner.origin - '0 0 8';
    Item.camdist = 0;
    Item.velocity_z = 400;
    Item.velocity_x = -50 + (random() * 100);
    Item.velocity_y = -50 + (random() * 100);
    Item.goal_state = 2;
    Item.movetype = 6;
    if (Item.goal_activation & 8192) {
        Item.solid = 2;
    } else {
        Item.solid = 1;
    }
    if (Item.mdl != string_null) {
        FO_SetModel(Item, Item.mdl);
    }
    setsize(Item, Item.goal_min, Item.goal_max);
    if (PAlive == 1) {
        makevectors(P.v_angle);
        if (P.v_angle_x < 25) {
            Item.velocity = (v_forward * 400) + (v_up * 200);
        } else {
            Item.velocity = aim(P, 10000);
            Item.velocity = Item.velocity * 400;
            Item.velocity_z = 200;
        }
        Item.touch = SUB_Null;
        Item.nextthink = time + 0.75;
        Item.bubble_count = time + Item.pausetime + 0.75 + 4.25; //used by the return timer
        Item.think = tfgoalitem_droptouch;
    } else {
        Item.touch = item_tfgoal_touch;
        Item.nextthink = time + 5;
        Item.think = tfgoalitem_dropthink;
        Item.bubble_count = time + Item.pausetime + 5; //used by the return timer
    }
    if (Item.goal_activation & TFGI_RETURN_DROP) {
        Item.think = tfgoalitem_remove;
    }
    Item.owner = world;
};

void () tfgoalitem_remove = {
    local entity te;

    if (self.goal_state == 1) {
        return;
    }
    if (self.goal_activation & 32 || self.goal_activation & TFGI_RETURN_DROP) {
        te = spawn();
        te.enemy = self;
        te.weapon = 3;
        te.nextthink = time + 0.1;
        te.think = ReturnItem;
        te.bubble_count = 0; //reset return time counter
        return;
    }
    dremove(self);
};

void (entity Item) tfgoalitem_checkgoalreturn = {
    local entity te;

    if (Item.impulse != 0) {
        te = Findgoal(Item.impulse);
        if (te) {
            te = Findgoal(Item.impulse);
            if (te)
                AttemptToActivate(te, world, Item);
        }
    }
};

void (entity Goal, entity Player, entity Item) DisplayItemStatus = {
    if (Item.goal_state == 1 && Item.owner != world) {
        if ((Goal.team_str_carried != string_null) ||
                (Goal.non_team_str_carried != string_null)) {
            if (Player.team_no == Item.owned_by) {
                sprint(Player, PRINT_HIGH, Goal.team_str_carried);
            } else {
                sprint(Player, PRINT_HIGH, Goal.non_team_str_carried);
            }
            sprint(Player, PRINT_HIGH, " ");
            if (Player == Item.owner) {
                sprint(Player, PRINT_HIGH, "you");
            } else {
                sprint(Player, PRINT_HIGH, Item.owner.netname);
            }
            sprint(Player, PRINT_HIGH, "\n");
        }
    } else {
        if (Item.origin != Item.oldorigin) {
            if ((Goal.team_str_moved != string_null) ||
                    (Goal.non_team_str_moved != string_null)) {
                if (Player.team_no == Item.owned_by) {
                    sprint(Player, PRINT_HIGH, Goal.team_str_moved);
                } else {
                    sprint(Player, PRINT_HIGH, Goal.non_team_str_moved);
                }
                sprint(Player, PRINT_HIGH, "\n");
            }
        } else {
            if ((Goal.team_str_home != string_null) ||
                    (Goal.non_team_str_home != string_null)) {
                if (Player.team_no == Item.owned_by) {
                    sprint(Player, PRINT_HIGH, Goal.team_str_home);
                } else {
                    sprint(Player, PRINT_HIGH, Goal.non_team_str_home);
                }
                sprint(Player, PRINT_HIGH, "\n");
            }
        }
    }
};

void () info_player_team1 = {
    CTF_Map = 1;
    self.classname = "info_player_teamspawn";
    self.team_no = 2;
    self.goal_effects = 1;
    self.team_str_home = "ts2";
};

void () info_player_team2 = {
    CTF_Map = 1;
    self.classname = "info_player_teamspawn";
    self.team_no = 1;
    self.goal_effects = 1;
    self.team_str_home = "ts1";
};

void () item_flag_team2 = {
    local entity dp;

    CTF_Map = 1;
    UpdateAbbreviations(self);
    precache_sound("ogre/ogwake.wav");
    precache_sound("boss1/out1.wav");
    self.classname = "item_tfgoal";
    self.netname = "Blue Flag";
    self.broadcast = Q" \sgot\s the enemy team's flag!\n";
    self.deathtype = "You've got the enemy flag!\n";
    self.noise = "ogre/ogwake.wav";

    if (toggleflags & TFLAG_WARSTANDARD)
        self.mdl = "progs/tf_stan.mdl";
    else {
        self.mdl = "progs/tf_flag.mdl";
        self.origin_z = self.origin_z + 6;
    }

    self.skin = 0;
    FO_SetModel(self, self.mdl);
    self.goal_no = 1;
    self.goal_activation =
        TFGI_GLOW | TFGI_DROP | TFGI_REMOVE | TFGI_RETURN_REMOVE |
        TFGI_RETURN_GOAL | TFGI_ITEMGLOWS;
    self.goal_effects = 1;
    self.pausetime = 128;
    self.goal_min = VEC_HULL_MIN;
    self.goal_max = VEC_HULL_MAX;
    setsize(self, self.goal_min, self.goal_max);
    self.touch = item_tfgoal_touch;
    self.goal_state = 2;
    self.solid = 1;
    setorigin(self, self.origin);
    self.nextthink = time + 0.2;
    self.think = TF_PlaceItem;

    dp = spawn();
    dp.origin = self.origin;
    dp.classname = "info_tfgoal";
    dp.goal_activation = 1;
    dp.team_no = 1;
    dp.items_allowed = 2;
    dp.goal_no = 3;
    dp.goal_effects = 3;
    dp.broadcast = Q" \scaptured\s the enemy flag!\n";
    dp.message = Q"You \scaptured\s the enemy flag!\n";
    dp.noise = "boss1/out1.wav";
    dp.goal_result = 2;
    dp.activate_goal_no = 5;
    dp.axhitme = 2;
    dp.count = 10;
    dp.frags = 10;
    dp.solid = 1;
    dp.goal_state = 2;
    dp.goal_min = VEC_HULL_MIN;
    dp.goal_max = VEC_HULL_MAX;
    setsize(dp, dp.goal_min, dp.goal_max);
    dp.nextthink = time + 0.2;
    dp.think = TF_PlaceGoal;
    dp = spawn();
    dp.origin = dp.origin;
    dp.classname = "info_tfgoal";
    dp.goal_effects = 1;
    dp.frags = 5;
    dp.goal_activation = 0;
    dp.goal_no = 5;
    dp.solid = 0;
    dp.goal_state = 2;
    dp.goal_min = VEC_HULL_MIN;
    dp.goal_max = VEC_HULL_MAX;
    setsize(dp, dp.goal_min, dp.goal_max);
    dp.nextthink = time + 0.2;
    dp.think = TF_PlaceGoal;
};

void () item_flag_team1 = {
    local entity dp;

    CTF_Map = 1;
    UpdateAbbreviations(self);
    precache_sound("ogre/ogwake.wav");
    precache_sound("boss1/out1.wav");
    self.classname = "item_tfgoal";
    self.netname = "Red Flag";
    self.broadcast = Q" \sgot\s the enemy team's flag!\n";
    self.deathtype = "You've got the enemy flag!\n";
    self.noise = "ogre/ogwake.wav";

    if (toggleflags & TFLAG_WARSTANDARD)
        self.mdl = "progs/tf_stan.mdl";
    else {
        self.mdl = "progs/tf_flag.mdl";
        self.origin_z = self.origin_z + 6;
    }

    FO_SetModel(self, self.mdl);
    self.skin = 1;
    self.goal_no = 2;
    self.goal_activation = 1 | 4 | 128 | 32 | 16 | 512;
    self.goal_effects = 1;
    self.pausetime = 128;
    self.goal_min = VEC_HULL_MIN;
    self.goal_max = VEC_HULL_MAX;
    setsize(self, self.goal_min, self.goal_max);
    self.touch = item_tfgoal_touch;
    self.goal_state = 2;
    self.solid = 1;
    setorigin(self, self.origin);
    self.nextthink = time + 0.2;
    self.think = TF_PlaceItem;

    dp = spawn();
    dp.origin = self.origin;
    dp.classname = "info_tfgoal";
    dp.goal_activation = 1;
    dp.team_no = 2;
    dp.items_allowed = 1;
    dp.goal_no = 4;
    dp.goal_effects = 3;
    dp.broadcast = Q" \scaptured\s the enemy flag!\n";
    dp.message = Q"You \scaptured\s the enemy flag!\n";
    dp.noise = "boss1/out1.wav";
    dp.goal_result = 2;
    dp.activate_goal_no = 6;
    dp.axhitme = 1;
    dp.count = 10;
    dp.frags = 10;
    dp.solid = 1;
    dp.goal_state = 2;
    dp.goal_min = VEC_HULL_MIN;
    dp.goal_max = VEC_HULL_MAX;
    setsize(dp, dp.goal_min, dp.goal_max);
    dp.nextthink = time + 0.2;
    dp.think = TF_PlaceGoal;

    dp = spawn();
    dp.origin = dp.origin;
    dp.classname = "info_tfgoal";
    dp.goal_effects = TFSP_REMOVESELF;
    dp.frags = 5;
    dp.goal_activation = 0;
    dp.goal_no = 6;
    dp.solid = 0;
    dp.goal_state = TFGS_INACTIVE;
    dp.goal_min = VEC_HULL_MIN;
    dp.goal_max = VEC_HULL_MAX;
    setsize(dp, dp.goal_min, dp.goal_max);
    dp.nextthink = time + 0.2;
    dp.think = TF_PlaceGoal;
};

void () CTF_FlagCheck = {
    local entity te;
    local float flagcount;
    local float pos;

    flagcount = 0;
    te = find(world, classname, "item_tfgoal");
    while (te != world) {
        if (te.goal_no == 1) {
            pos = pointcontents(te.origin);
            if ((pos == -2) || (pos == -6)) {
                dprint
                    ("*****BUG*****\nFlag(s) outside world.\nPlease report this.\n");
                te.nextthink = time + 0.2;
                te.think = tfgoalitem_remove;
            }
            flagcount = flagcount + 1;
        } else {
            if (te.goal_no == 2) {
                pos = pointcontents(te.origin);
                if ((pos == -2) || (pos == -6)) {
                    dprint
                        ("*****BUG*****\nFlag(s) outside world.\nPlease report this.\n");
                    te.nextthink = time + 0.2;
                    te.think = tfgoalitem_remove;
                }
                flagcount = flagcount + 1;
            }
        }
        te = find(te, classname, "item_tfgoal");
    }
    if (flagcount != 2) {
        dprint("*****BUG*****\nFlag(s) missing.\nPlease report this.\n");
    }
    self.nextthink = time + 30;
};

void (entity P) ForceRespawn = {
    local entity spot;
    local entity te;
    local entity oldself;

    oldself = self;
    self = P;
    spot = SelectSpawnPoint();
    self.observer_list = spot;
    self.origin = spot.origin + '0 0 1';
    self.angles = spot.angles;
    self.fixangle = 1;
    if (self.playerclass != 0)
        spawn_tdeath(self.origin, self);
    if ((spot.classname == "info_player_teamspawn") &&
            (!cb_prematch)) {
        if (spot.items != 0) {
            te = Finditem(spot.items);
            if (te) {
                tfgoalitem_GiveToPlayer(te, self, self);
            }
            if (!(spot.goal_activation & 1)) {
                spot.items = 0;
            }
        }
        if (spot.message) {
            CenterPrint(self, spot.message);
            if (!(spot.goal_activation & 2)) {
                spot.message = string_null;
            }
        }
        if (spot.activate_goal_no != 0) {
            te = Findgoal(spot.activate_goal_no);
            if (te) {
                AttemptToActivate(te, self, spot);
            }
        }
        if (spot.goal_effects == 1) {
            spot.classname = "deadpoint";
            spot.team_str_home = string_null;
            spot.nextthink = time + 1;
            spot.think = SUB_Remove;
        }
    }
    if (deathmatch || coop) {
        makevectors(self.angles);
        if (self.playerclass != 0) {
            spawn_tfog((self.origin + (v_forward * 20)));
        }
    }
    self = oldself;
};

void () DropGoalItems = {
    local entity te, search;
    local float timecarried;
    
    newmis = spawn();
    makevectors(self.v_angle);
    v_forward = normalize(v_forward) * 64;
    newmis.origin = self.origin + v_forward;
    te = find(world, classname, "item_tfgoal");
    while (te) {
        if (te.owner == self) {
            if (old_dropflag) {
                if (te.goal_activation & TFGI_ALLOWTHROW) {
                    tfgoalitem_RemoveFromPlayer(te, self, 2);
                }
            }
            else if(te.goal_activation & TFGI_RETURN_DROP) {
                tfgoalitem_RemoveFromPlayer(te, self, 0);
            }
            //Always allow dropping 4096
            else if (self.effects & EF_DIMLIGHT || te.goal_activation & TFGI_ALLOWTHROW) {
                timecarried = gametime - self.goalrunningtime;
                RemoveFlagFollow(self);
                LogEventFumble(self, timecarried);
                te.angles = '0 0 0';
                tfgoalitem_RemoveEffectsFromPlayer(te, self);
                tfgoalitem_drop(te, 1, self);
                if (!te.netname_team_drop || !te.netname_non_team_drop) {
                    if (te.netname) {
                        bprint(PRINT_HIGH, self.netname, Q" \sdropped ", te.netname ,"!\s\n");
                    } else if (te.owned_by > 0) {
                        if (te.owned_by == 1)
                            bprint(PRINT_HIGH, self.netname, Q" \sdropped blue's flag!\s\n");
                        else if (te.owned_by == 2)
                            bprint(PRINT_HIGH, self.netname, Q" \sdropped red's flag!\s\n");
                        else if (te.owned_by == 3)
                            bprint(PRINT_HIGH, self.netname, Q" \sdropped yellow's flag!\s\n");
                        else if (te.owned_by == 4)
                            bprint(PRINT_HIGH, self.netname, Q" \sdropped green's flag!\s\n");
                    } else {
                        if (self.team_no == 1)
                            bprint(PRINT_HIGH, self.netname, Q" \sdropped red's flag!\s\n");
                        else if (self.team_no == 2)
                            bprint(PRINT_HIGH, self.netname, Q" \sdropped blue's flag!\s\n");
                        else
                            bprint(PRINT_HIGH, self.netname, Q" \sdropped the enemy's flag!\s\n");
                    }
                }
                
                Status_Print(self, "\n\n\n", "You dropped the flag!");
                search = find(world, classname, "player");
                while (search) {
                    if ((search.team_no == self.team_no) && (self.team_no != 0)) {
                        if (search != self)
                            Status_Print(search, "\n\n\n", self.netname, " dropped the enemy flag!");
                    } else {
                        Status_Print(search, "\n\n\n", "The enemy dropped your flag!");
                    }
                    if (te.owned_by) {
                        if (te.netname_team_drop && te.netname_non_team_drop && search.team_no == te.owned_by) {
                            sprint(search, PRINT_HIGH, self.netname, te.netname_team_drop);
                        } 
                        if (te.netname_team_drop && te.netname_non_team_drop && search.team_no != te.owned_by) {
                            sprint(search, PRINT_HIGH, self.netname, te.netname_non_team_drop);
                        } 
                    }
                    search = find(search, classname, "player");
                }
            }
        }
        te = find(te, classname, "item_tfgoal");
    }
    dremove(newmis);
    TeamFortress_SetSpeed(self);
};
