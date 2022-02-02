
void () plat_center_touch;
void () plat_outside_touch;
void () plat_trigger_use;
void () plat_go_up;
void () plat_go_down;
void () plat_crush;
void (entity pe_player, float dontstopdead) Spy_CheckForFuncTouch;

void () plat_spawn_inside_trigger = {
    local entity trigger;
    local vector tmin, tmax;

    trigger = spawn();
    trigger.touch = plat_center_touch;
    trigger.movetype = MOVETYPE_NONE;
    trigger.solid = SOLID_TRIGGER;
    trigger.enemy = self;
    self.enemy = trigger;
    trigger.team_no = self.team_no;
    trigger.playerclass = self.playerclass;
    trigger.items_allowed = self.items_allowed;
    trigger.activate_goal_no = self.activate_goal_no;
    trigger.inactivate_goal_no = self.inactivate_goal_no;
    trigger.remove_goal_no = self.remove_goal_no;
    trigger.restore_goal_no = self.restore_goal_no;
    trigger.activate_group_no = self.activate_group_no;
    trigger.inactivate_group_no = self.inactivate_group_no;
    trigger.remove_group_no = self.remove_group_no;
    trigger.restore_group_no = self.restore_group_no;

    trigger.goal_activation = self.goal_activation;
    trigger.goal_effects = self.goal_effects;
    trigger.goal_result = self.goal_result;
    trigger.goal_group = self.goal_group;

    tmin = self.mins + '25 25 0';
    tmax = self.maxs - '25 25 -8';
    tmin_z = tmax_z - (self.pos1_z - self.pos2_z + 8);

    if (self.spawnflags & 1)
        tmax_z = tmin_z + 8;

    if (self.size_x <= 50) {
        tmin_x = (self.mins_x + self.maxs_x) / 2;
        tmax_x = tmin_x + 1;
    }
    if (self.size_y <= 50) {
        tmin_y = (self.mins_y + self.maxs_y) / 2;
        tmax_y = tmin_y + 1;
    }
    setsize(trigger, tmin, tmax);
};

void () plat_hit_top = {
    FO_Sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
    self.state = STATE_TOP;
    self.think = plat_go_down;
    self.nextthink = self.ltime + 3;
};

void () plat_hit_bottom = {
    FO_Sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
    self.state = STATE_BOTTOM;
};

void () plat_go_down = {
    FO_Sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
    self.state = STATE_DOWN;
    SUB_CalcMove(self.pos2, self.speed, plat_hit_bottom);
};

void () plat_go_up = {
    FO_Sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
    self.state = STATE_UP;
    SUB_CalcMove(self.pos1, self.speed, plat_hit_top);
};

void () plat_center_touch = {
    local entity te;

    if (other.classname != "player")
        return;

    if (self.team_no != 0)
    {
        if (other.team_no != self.team_no)
        {
            return;
        }
    }

    if (other.playerclass == 0)
        return;

    Spy_CheckForFuncTouch(other, 1);

    if (!Activated(self, other)) {
        if (self.else_goal != 0) {
            te = Findgoal(self.else_goal);
            if (te)
                AttemptToActivate(te, other, self);
        }
        return;
    }

    if (other.health <= 0)
        return;

    self = self.enemy;
    if (self.state == STATE_BOTTOM)
        plat_go_up();
    else if (self.state == STATE_TOP)
        self.nextthink = self.ltime + 1;
};

void () plat_outside_touch = {
    local entity te;

    if (other.classname != "player")
        return;

    Spy_CheckForFuncTouch(other, 0);

    if (!Activated(self, other)) {
        if (self.else_goal != 0) {
            te = Findgoal(self.else_goal);
            if (te)
                AttemptToActivate(te, other, self);
        }
        return;
    }
    if (other.health <= 0)
        return;

    self = self.enemy;
    if (self.state == STATE_TOP)
        plat_go_down();
};

void () plat_trigger_use = {
    if (self.think)
        return;
    plat_go_down();
};

void () plat_crush = {
    if (other.classname == "detpack") {
        sprint(other.owner, PRINT_HIGH, "Your detpack was squashed\n");
        if (other.weaponmode == 1) {
            TeamFortress_SetSpeed(other.enemy);
            dremove(other.observer_list);
        }
        dremove(other.oldenemy);
        dremove(other);
        return;
    }
    T_Damage(other, self, self, 1);

    if (self.state == STATE_UP) {
        plat_go_down();
    } else if (self.state == STATE_DOWN) {
        plat_go_up();
    } else
        objerror("plat_crush: bad self.state\n");
};

void () plat_use = {
    self.use = SUB_Null;
    if (self.state != STATE_UP)
        objerror("plat_use: not in up state");
    plat_go_down();
};

void () func_plat = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if (!self.t_length)
        self.t_length = 80;

    if (!self.t_width)
        self.t_width = 10;

    if (self.sounds == 0)
        self.sounds = 2;

    if (self.sounds == 1) {
        precache_sound("plats/plat1.wav");
        precache_sound("plats/plat2.wav");
        self.noise = "plats/plat1.wav";
        self.noise1 = "plats/plat2.wav";
    } else if (self.sounds == 2) {
        precache_sound("plats/medplat1.wav");
        precache_sound("plats/medplat2.wav");
        self.noise = "plats/medplat1.wav";
        self.noise1 = "plats/medplat2.wav";
    }
    self.mangle = self.angles;
    self.angles = '0 0 0';
    self.classname = "plat";
    self.solid = SOLID_BSP;
    self.movetype = MOVETYPE_PUSH;

    setorigin(self, self.origin);
    setmodel(self, self.model);
    setsize(self, self.mins, self.maxs);

    switch(self.allowteams)
    {
        case "blue":
            self.team_no = 1;
            break;
        case "red":
            self.team_no = 2;
            break;
        default:
    }

    self.blocked = plat_crush;

    if (!self.speed)
        self.speed = 150;

    self.pos1 = self.origin;
    self.pos2 = self.origin;

    if (self.height)
        self.pos2_z = self.origin_z - self.height;
    else
        self.pos2_z = self.origin_z - self.size_z + 8;

    self.use = plat_trigger_use;
    plat_spawn_inside_trigger();

    if (self.targetname) {
        self.state = 2;
        self.use = plat_use;
    } else {
        setorigin(self, self.pos2);
        self.state = 1;
    }
};

void () train_next;
void () func_train_find;

void () train_blocked = {
    if (time < self.attack_finished)
        return;
    self.attack_finished = time + 0.5;
    T_Damage(other, self, self, self.dmg);
};

void () train_use = {
    if (self.think != func_train_find)
        return;
    train_next();
};

void () train_wait = {
    if (self.wait) {
        self.nextthink = self.ltime + self.wait;
        FO_Sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
    } else
        self.nextthink = self.ltime + 0.1;

    self.think = train_next;
};

void () train_next = {
    local entity targ;

    targ = find(world, targetname, self.target);
    self.target = targ.target;
    if (!self.target)
        objerror("train_next: no next target");

    if (targ.wait)
        self.wait = targ.wait;
    else
        self.wait = 0;

    FO_Sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
    SUB_CalcMove(targ.origin - self.mins, self.speed, train_wait);
};

void () func_train_find = {
    local entity targ;

    targ = find(world, targetname, self.target);
    self.target = targ.target;
    setorigin(self, targ.origin - self.mins);

    if (!self.targetname) {
        self.nextthink = self.ltime + 0.1;
        self.think = train_next;
    }
};

void () func_train = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if (!self.speed)
        self.speed = 100;

    if (!self.target)
        objerror("func_train without a target");

    if (!self.dmg)
        self.dmg = 2;

    if (self.sounds == 0) {
        self.noise = "misc/null.wav";
        precache_sound("misc/null.wav");
        self.noise1 = "misc/null.wav";
        precache_sound("misc/null.wav");
    } else if (self.sounds == 1) {
        self.noise = "plats/train2.wav";
        precache_sound("plats/train2.wav");
        self.noise1 = "plats/train1.wav";
        precache_sound("plats/train1.wav");
    }
    self.cnt = 1;
    self.solid = SOLID_BSP;
    self.movetype = MOVETYPE_PUSH;

    self.blocked = train_blocked;
    self.use = train_use;
    self.classname = "train";

    setmodel(self, self.model);
    setsize(self, self.mins, self.maxs);
    setorigin(self, self.origin);

    self.nextthink = self.ltime + 0.1;
    self.think = func_train_find;
};

void () misc_teleporttrain = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if (!self.speed)
        self.speed = 100;

    if (!self.target)
        objerror("func_train without a target");

    self.cnt = 1;
    self.solid = SOLID_NOT;
    self.movetype = MOVETYPE_PUSH;

    self.blocked = train_blocked;
    self.use = train_use;
    self.avelocity = '100 200 300';

    self.noise = "misc/null.wav";
    precache_sound("misc/null.wav");
    self.noise1 = "misc/null.wav";
    precache_sound("misc/null.wav");

    precache_model2("progs/teleport.mdl");
    setmodel(self, "progs/teleport.mdl");
    setsize(self, self.mins, self.maxs);
    setorigin(self, self.origin);

    self.nextthink = self.ltime + 0.1;
    self.think = func_train_find;
};
