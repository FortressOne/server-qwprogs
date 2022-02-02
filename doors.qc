
void () door_go_down;
void () door_go_up;
void (entity pe_player, float dontstopdead) Spy_CheckForFuncTouch;

void () door_blocked = {
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
    T_Damage(other, self, self, self.dmg);

    if (self.wait >= 0 && self.forcecloseonblock == 0) {
        if (self.state == STATE_DOWN)
            door_go_up();
        else
            door_go_down();
    }
};

void () door_hit_top = {
    FO_Sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
    self.state = STATE_TOP;
    if (self.spawnflags & 32)
        return;

    self.think = door_go_down;
    self.nextthink = self.ltime + self.wait;
};

void () door_hit_bottom = {
    self.goal_state = 2;
    FO_Sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
    self.state = STATE_BOTTOM;
};

void () door_go_down_silent = {
    if (self.max_health) {
        self.takedamage = 1;
        self.health = self.max_health;
    }
    self.state = STATE_DOWN;
    SUB_CalcMove(self.pos1, self.speed, door_hit_bottom);
}

void () door_go_down = {
    FO_Sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
    door_go_down_silent();
};

void () door_go_up = {
    if (self.state == STATE_UP)
        return;

    if (self.state == STATE_TOP) {
        self.nextthink = self.ltime + self.wait;
        return;
    }
    FO_Sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
    self.state = STATE_UP;
    SUB_CalcMove(self.pos2, self.speed, door_hit_top);
    SUB_UseTargets();
};

void () door_fire = {
    local entity oself;
    local entity starte;

    if (self.owner != self) {
        objerror("door_fire: self.owner != self");
    }
    if (self.items) {
        FO_Sound(self, CHAN_VOICE, self.noise4, 1, ATTN_NORM);
    }
    self.message = string_null;
    oself = self;
    if (self.spawnflags & 32) {
        if ((self.state == STATE_UP) || (self.state == STATE_TOP)) {
            starte = self;
            do {
                door_go_down();
                self = self.enemy;
            } while (((self != starte) && (self != world)));
            self = oself;
            return;
        }
    }
    starte = self;
    do {
        door_go_up();
        self = self.enemy;
    } while ((self != starte) && (self != world));
    self = oself;
};

void () door_use = {
    local entity oself;

    self.message = "";
    self.owner.message = "";
    self.enemy.message = "";
    oself = self;
    self = self.owner;
    door_fire();
    self = oself;
};

void () door_trigger_touch = {
    local entity te;

    if (other.health <= 0)
        return;
    if (other.playerclass == 0)
        return;

    if (!Activated(self, other)) {
        if (self.else_goal != 0) {
            te = Findgoal(self.else_goal);
            if (te)
                AttemptToActivate(te, other, self);
        }
        return;
    }
    if (time < self.attack_finished)
        return;

    self.attack_finished = time + 1;
    activator = other;
    self = self.owner;
    door_use();
};

void () door_killed = {
    local entity oself;

    oself = self;
    self = self.owner;
    self.health = self.max_health;
    self.takedamage = 0;
    door_use();
    self = oself;
};

float () DoorShouldOpen;

void () door_touch = {
    local entity te;

    if (other.classname != "player")
        return;

    Spy_CheckForFuncTouch(other, 0);

    if (self.owner.attack_finished > time)
        return;

    if (!Activated(self, other)) {
        if (self.else_goal != 0) {
            te = Findgoal(self.else_goal);
            if (te)
                AttemptToActivate(te, other, self);
        }
        return;
    }
    self.owner.attack_finished = time + 2;
    if (self.owner.message != "") {
        CenterPrint(other, self.owner.message);
        FO_Sound(other, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
    }
    if (!self.items)
        return;

    if ((self.items & other.items) != self.items) {
        if (self.owner.items == IT_KEY1) {
            if (world.worldtype == 2) {
                CenterPrint(other, "You need the silver keycard");
                FO_Sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
            } else if (world.worldtype == 1) {
                CenterPrint(other, "You need the silver runekey");
                FO_Sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
            } else if (world.worldtype == 0) {
                CenterPrint(other, "You need the silver key");
                FO_Sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
            }
        } else if (world.worldtype == 2) {
            CenterPrint(other, "You need the gold keycard\n");
            FO_Sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
        } else if (world.worldtype == 1) {
            CenterPrint(other, "You need the gold runekey");
            FO_Sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
        } else if (world.worldtype == 0) {
            CenterPrint(other, "You need the gold key");
            FO_Sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
        }
        return;
    }
    other.items = other.items - self.items;
    other.tf_items = other.tf_items | self.items;

    if (DoorShouldOpen()) {
        self.touch = SUB_Null;
        if (self.enemy)
            self.enemy.touch = SUB_Null;
        door_use();
    }
};

entity(vector fmins, vector fmaxs) spawn_field =
{
    local entity trigger;
    local vector t1;
    local vector t2;

    trigger = spawn();
    trigger.movetype = MOVETYPE_NONE;
    trigger.solid = SOLID_TRIGGER;
    trigger.owner = self;
    trigger.touch = door_trigger_touch;
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
    trigger.all_active = self.all_active;
    trigger.last_impulse = self.last_impulse;
    trigger.else_goal = self.else_goal;
    trigger.group_no = self.group_no;
    t1 = fmins;
    t2 = fmaxs;
    setsize(trigger, t1 - '60 60 8', t2 + '60 60 8');
    return (trigger);
};

float (entity e1, entity e2) EntitiesTouching = {
    if (e1.mins_x > e2.maxs_x)
        return (0);
    if (e1.mins_y > e2.maxs_y)
        return (0);
    if (e1.mins_z > e2.maxs_z)
        return (0);
    if (e1.maxs_x < e2.mins_x)
        return (0);
    if (e1.maxs_y < e2.mins_y)
        return (0);
    if (e1.maxs_z < e2.mins_z)
        return (0);
    return (1);
};

void () LinkDoors = {
    local entity t;
    local entity starte;
    local vector cmins;
    local vector cmaxs;

    if (self.enemy)
        return;

    if (self.spawnflags & 4) {
        self.enemy = self;
        self.owner = self;
        return;
    }
    cmins = self.mins;
    cmaxs = self.maxs;
    starte = self;
    t = self;
    do {
        self.owner = starte;
        if (self.health)
            starte.health = self.health;

        if (self.targetname)
            starte.targetname = self.targetname;

        if (self.message != "")
            starte.message = self.message;

        t = find(t, classname, self.classname);
        if (!t) {
            self.enemy = starte;
            self = self.owner;
            if (self.health)
                return;
            if (self.targetname)
                return;
            if (self.items)
                return;
            self.owner.trigger_field = spawn_field(cmins, cmaxs);
            return;
        }
        if (EntitiesTouching(self, t)) {
            if (t.enemy)
                objerror("cross connected doors");

            self.enemy = t;
            self = t;
            if (t.mins_x < cmins_x) {
                cmins_x = t.mins_x;
            }
            if (t.mins_y < cmins_y) {
                cmins_y = t.mins_y;
            }
            if (t.mins_z < cmins_z) {
                cmins_z = t.mins_z;
            }
            if (t.maxs_x > cmaxs_x) {
                cmaxs_x = t.maxs_x;
            }
            if (t.maxs_y > cmaxs_y) {
                cmaxs_y = t.maxs_y;
            }
            if (t.maxs_z > cmaxs_z) {
                cmaxs_z = t.maxs_z;
            }
        }
    } while (TRUE);
};

void () func_door = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if (world.worldtype == 0) {
        precache_sound("doors/medtry.wav");
        precache_sound("doors/meduse.wav");
        self.noise3 = "doors/medtry.wav";
        self.noise4 = "doors/meduse.wav";
    } else if (world.worldtype == 1) {
        precache_sound("doors/runetry.wav");
        precache_sound("doors/runeuse.wav");
        self.noise3 = "doors/runetry.wav";
        self.noise4 = "doors/runeuse.wav";
    } else if (world.worldtype == 2) {
        precache_sound("doors/basetry.wav");
        precache_sound("doors/baseuse.wav");
        self.noise3 = "doors/basetry.wav";
        self.noise4 = "doors/baseuse.wav";
    } else {
        dprint("no worldtype set!\n");
    }
    if (self.sounds == 0) {
        precache_sound("misc/null.wav");
        precache_sound("misc/null.wav");
        self.noise1 = "misc/null.wav";
        self.noise2 = "misc/null.wav";
    } else if (self.sounds == 1) {
        precache_sound("doors/drclos4.wav");
        precache_sound("doors/doormv1.wav");
        self.noise1 = "doors/drclos4.wav";
        self.noise2 = "doors/doormv1.wav";
    } else if (self.sounds == 2) {
        precache_sound("doors/hydro1.wav");
        precache_sound("doors/hydro2.wav");
        self.noise2 = "doors/hydro1.wav";
        self.noise1 = "doors/hydro2.wav";
    } else if (self.sounds == 3) {
        precache_sound("doors/stndr1.wav");
        precache_sound("doors/stndr2.wav");
        self.noise2 = "doors/stndr1.wav";
        self.noise1 = "doors/stndr2.wav";
    } else if (self.sounds == 4) {
        precache_sound("doors/ddoor1.wav");
        precache_sound("doors/ddoor2.wav");
        self.noise1 = "doors/ddoor2.wav";
        self.noise2 = "doors/ddoor1.wav";
    }
    // q3 fields
    if (self.allowteams == "blue") {
        self.team_no = 1;
    }
    if (self.allowteams == "red") {
        self.team_no = 2;
    }
    SetMovedir();
    self.max_health = self.health;
    self.solid = SOLID_BSP;
    self.movetype = MOVETYPE_PUSH;
    setorigin(self, self.origin);
    setmodel(self, self.model);
    self.classname = "door";
    self.blocked = door_blocked;
    self.use = door_use;
    if (self.spawnflags & 16) {
        self.items = IT_KEY1;
    }
    if (self.spawnflags & 8) {
        self.items = IT_KEY2;
    }
    if (!self.speed) {
        self.speed = 100;
    }
    if (!self.wait) {
        self.wait = 3;
    }
    if (!self.lip) {
        self.lip = 8;
    }
    if (!self.dmg) {
        self.dmg = 2;
    }
    self.pos1 = self.origin;
    self.pos2 =
        self.pos1 +
        (self.movedir * (fabs((self.movedir * self.size)) - self.lip));
    if (self.spawnflags & 1) {
        setorigin(self, self.pos2);
        self.pos2 = self.pos1;
        self.pos1 = self.origin;
    }
    self.state = STATE_BOTTOM;
    if (self.health) {
        self.takedamage = 1;
        self.th_die = door_killed;
    }
    if (self.items) {
        self.wait = -1;
    }
    self.touch = door_touch;
    self.think = LinkDoors;
    self.nextthink = self.ltime + 0.1;
};

void () fd_secret_move1;
void () fd_secret_move2;
void () fd_secret_move3;
void () fd_secret_move4;
void () fd_secret_move5;
void () fd_secret_move6;
void () fd_secret_done;

void () fd_secret_use = {
    local float temp;

    self.health = 10000;
    if (self.origin != self.oldorigin) {
        return;
    }
    if (self.spawnflags & 32) {
        return;
    }
    self.message = string_null;
    SUB_UseTargets();
    if (!(self.spawnflags & 8)) {
        self.th_pain = SUB_Null_pain;
        self.takedamage = 0;
    }
    self.velocity = '0 0 0';
    FO_Sound(self, CHAN_VOICE, self.noise1, 1, 1);
    self.nextthink = self.ltime + 0.1;
    temp = 1 - (self.spawnflags & 2);
    makevectors(self.mangle);
    if (!self.t_width) {
        if (self.spawnflags & 4) {
            self.t_width = fabs((v_up * self.size));
        } else {
            self.t_width = fabs((v_right * self.size));
        }
    }
    if (!self.t_length) {
        self.t_length = fabs((v_forward * self.size));
    }
    if (self.spawnflags & 4) {
        self.dest1 = self.origin - (v_up * self.t_width);
    } else {
        self.dest1 = self.origin + (v_right * (self.t_width * temp));
    }
    self.dest2 = self.dest1 + (v_forward * self.t_length);
    SUB_CalcMove(self.dest1, self.speed, fd_secret_move1);
    FO_Sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
};

void (entity e, float f) fd_secret_pain = {
    fd_secret_use();
};

void () fd_secret_move1 = {
    self.nextthink = self.ltime + 1;
    self.think = fd_secret_move2;
    FO_Sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () fd_secret_move2 = {
    FO_Sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
    SUB_CalcMove(self.dest2, self.speed, fd_secret_move3);
};

void () fd_secret_move3 = {
    FO_Sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
    if (!(self.spawnflags & 1)) {
        self.nextthink = self.ltime + self.wait;
        self.think = fd_secret_move4;
    }
};

void () fd_secret_move4 = {
    FO_Sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
    SUB_CalcMove(self.dest1, self.speed, fd_secret_move5);
};

void () fd_secret_move5 = {
    self.nextthink = self.ltime + 1;
    self.think = fd_secret_move6;
    FO_Sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () fd_secret_move6 = {
    FO_Sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
    SUB_CalcMove(self.oldorigin, self.speed, fd_secret_done);
};

void () fd_secret_done = {
    if (!self.targetname || (self.spawnflags & 16)) {
        self.health = 10000;
        self.takedamage = 1;
        self.th_pain = fd_secret_pain;
        self.th_die = fd_secret_use;
    }
    FO_Sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () secret_blocked = {
    if (time < self.attack_finished)
        return;

    self.attack_finished = time + 0.5;
    T_Damage(other, self, self, self.dmg);
};

void () secret_touch = {
    if (other.classname != "player")
        return;

    Spy_CheckForFuncTouch(other, 0);

    if (self.attack_finished > time)
        return;

    if (self.spawnflags & 32)
        return;

    self.attack_finished = time + 2;
    if (self.message) {
        CenterPrint(other, self.message);
        FO_Sound(other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
    }
};

void () func_door_secret = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if (self.sounds == 0)
        self.sounds = 3;

    if (self.sounds == 1) {
        precache_sound("doors/latch2.wav");
        precache_sound("doors/winch2.wav");
        precache_sound("doors/drclos4.wav");
        self.noise1 = "doors/latch2.wav";
        self.noise2 = "doors/winch2.wav";
        self.noise3 = "doors/drclos4.wav";
    } else if (self.sounds == 2) {
        precache_sound("doors/airdoor1.wav");
        precache_sound("doors/airdoor2.wav");
        self.noise2 = "doors/airdoor1.wav";
        self.noise1 = "doors/airdoor2.wav";
        self.noise3 = "doors/airdoor2.wav";
    } else if (self.sounds == 3) {
        precache_sound("doors/basesec1.wav");
        precache_sound("doors/basesec2.wav");
        self.noise2 = "doors/basesec1.wav";
        self.noise1 = "doors/basesec2.wav";
        self.noise3 = "doors/basesec2.wav";
    }
    if (!self.dmg) {
        self.dmg = 2;
    }
    self.mangle = self.angles;
    self.angles = '0 0 0';
    self.solid = 4;
    self.movetype = 7;
    self.classname = "door";

    setmodel(self, self.model);
    setorigin(self, self.origin);

    self.touch = secret_touch;
    self.blocked = secret_blocked;
    self.speed = 50;
    self.use = fd_secret_use;

    if (!self.targetname || (self.spawnflags & 16)) {
        self.health = 10000;
        self.takedamage = 1;
        self.th_pain = fd_secret_pain;
    }
    self.oldorigin = self.origin;
    if (!self.wait)
        self.wait = 5;
};
