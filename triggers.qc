entity stemp, otemp, s;

void () TeamFortress_DetpackExplode;

void () trigger_reactivate = {
    self.solid = SOLID_TRIGGER;
};

#define SPAWNFLAG_NOMESSAGE	1
#define SPAWNFLAG_NOTOUCH	1

void () multi_wait = {
    if (self.max_health) {
        self.health = self.max_health;
        self.takedamage = DAMAGE_YES;
        self.solid = SOLID_BBOX;
    }
};

void () multi_trigger = {
    if (self.nextthink > time) {
        return;
    }
    if (self.classname == "trigger_secret") {
        if (self.enemy.classname != "player") {
            return;
        }
        found_secrets = (found_secrets + 1);
        WriteByte(MSG_ALL, SVC_FOUNDSECRET);
    }
    if (self.noise) {
        FO_Sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
    }
    self.takedamage = DAMAGE_NO;
    activator = self.enemy;
    SUB_UseTargets();

    if (self.wait > 0) {
        self.think = multi_wait;
        self.nextthink = time + self.wait;
    } else {
        self.touch = SUB_Null;
        self.nextthink = time + 0.1;
        self.think = SUB_Remove;
    }
};

void () multi_killed = {
    self.enemy = damage_attacker;
    multi_trigger();
};

void () multi_use = {
    self.enemy = activator;
    multi_trigger();
};

void () multi_touch = {
    local entity te;

    if (other.classname != "player") {
        return;
    }
    if (!Activated(self, other)) {
        if (self.else_goal != 0) {
            te = Findgoal(self.else_goal);
            if (te) {
                AttemptToActivate(te, other, self);
            }
        }
        return;
    }
    if (self.movedir != '0 0 0') {
        makevectors(other.angles);
        if ((v_forward * self.movedir) < 0) {
            return;
        }
    }
    self.enemy = other;
    multi_trigger();
};

void () trigger_multiple = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if (self.sounds == 1) {
        precache_sound("misc/secret.wav");
        self.noise = "misc/secret.wav";
    } else if (self.sounds == 2) {
        precache_sound("misc/talk.wav");
        self.noise = "misc/talk.wav";
    } else if (self.sounds == 3) {
        precache_sound("misc/trigger1.wav");
        self.noise = "misc/trigger1.wav";
    }
    if (!self.wait) {
        self.wait = 0.2;
    }
    self.use = multi_use;

    // q3 fields
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

    InitTrigger();

    if (self.health) {
        if (self.spawnflags & SPAWNFLAG_NOTOUCH) {
            objerror("health and notouch don't make sense\n");
        }
        self.max_health = self.health;
        self.th_die = multi_killed;
        self.takedamage = DAMAGE_YES;
        self.solid = SOLID_BBOX;
        setorigin(self, self.origin);
    } else if (!(self.spawnflags & SPAWNFLAG_NOTOUCH)) {
        self.touch = multi_touch;
    }
};

void () trigger_once = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    self.wait = -1;
    trigger_multiple();
};

void () trigger_relay = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    self.use = SUB_UseTargets;
};

void () trigger_secret = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    total_secrets = total_secrets + 1;
    self.wait = -1;
    if (!self.message)
        self.message = "You found a secret area!";
    if (!self.sounds)
        self.sounds = 1;

    if (self.sounds == 1) {
        precache_sound("misc/secret.wav");
        self.noise = "misc/secret.wav";
    } else if (self.sounds == 2) {
        precache_sound("misc/talk.wav");
        self.noise = "misc/talk.wav";
    }
    trigger_multiple();
};

void () counter_use = {
    self.count = self.count - 1;
    if (self.count < 0)
        return;

    if (self.count != 0) {
        if ((activator.classname == "player") &&
            ((self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)) {
            if (self.count >= 4)
                CenterPrint(activator, "There are more to go...");
            else if (self.count == 3)
                CenterPrint(activator, "Only 3 more to go...");
            else if (self.count == 2)
                CenterPrint(activator, "Only 2 more to go...");
            else
                CenterPrint(activator, "Only 1 more to go...");
        }
        return;
    }
    if ((activator.classname == "player") &&
        ((self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0))
        CenterPrint(activator, "Sequence completed!");

    self.enemy = activator;
    multi_trigger();
};

void () trigger_counter = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    self.wait = -1;
    if (!self.count)
        self.count = 2;

    self.use = counter_use;
};

//============================================================================
// TELEPORT TRIGGERS
//============================================================================

#define PLAYER_ONLY	1
#define SILENT		2

void () play_teleport = {
    local float v;
    local string tmpstr;

    v = random() * 5;
    if (v < 1)
        tmpstr = "misc/r_tele1.wav";
    else if (v < 2)
        tmpstr = "misc/r_tele2.wav";
    else if (v < 3)
        tmpstr = "misc/r_tele3.wav";
    else if (v < 4)
        tmpstr = "misc/r_tele4.wav";
    else
        tmpstr = "misc/r_tele5.wav";

    FO_Sound(self, CHAN_VOICE, tmpstr, 1, ATTN_NORM);
    remove(self);
};

void (vector org) spawn_tfog = {
    s = spawn();
    s.origin = org;
    s.nextthink = time + 0.2;
    s.think = play_teleport;

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_TELEPORT);
    WriteCoord(MSG_MULTICAST, org_x);
    WriteCoord(MSG_MULTICAST, org_y);
    WriteCoord(MSG_MULTICAST, org_z);
    multicast(org, MULTICAST_PHS);
};

void () tdeath_touch = {
    if (other == self.owner)
        return;

    if (other.classname == "player") {
        if (other.invincible_finished > time)
            self.classname = "teledeath2";

        if (self.owner.classname != "player") {
            T_Damage(self.owner, self, self, 5000);
            return;
        }
    }

    if (other.health)
        T_Damage(other, self, self, 5000);

    if (other.think == TeamFortress_DetpackExplode) {
        other.solid = SOLID_NOT;
        other.nextthink = time + 1 + random() * 2;
        dremove(other.oldenemy);
        bprint(PRINT_MEDIUM, other.owner.netname,
               "'s detpack was telefragged by ", self.owner.netname, "\n");
    }
};

void (vector org, entity death_owner) spawn_tdeath = {
    local entity death;

    death = spawn();
    death.classname = "teledeath";
    death.movetype = MOVETYPE_NONE;
    death.solid = SOLID_TRIGGER;
    death.angles = '0 0 0';
    setsize(death, death_owner.mins - '4 4 4', death_owner.maxs + '4 4 4');
    setorigin(death, org);
    death.touch = tdeath_touch;
    death.nextthink = time + 0.2;
    death.think = SUB_Remove;
    death.owner = death_owner;
    force_retouch = 2;
};

void () teleport_touch = {
    local entity t = world, te;
    local vector org;
    local float targetcount;

    if (self.targetname) {
        if (self.nextthink < time) {
            return;
        }
    }
    if (self.spawnflags & 1) {
        if (other.classname != "player")
            return;
    }
    if (!Activated(self, other)) {
        if (self.else_goal != 0) {
            te = Findgoal(self.else_goal);
            if (te)
                AttemptToActivate(te, other, self);
        }
        return;
    }

    
    if (self.goal_state == TFGS_REMOVED)
        return;

    // only teleport living creatures
    if ((other.health <= 0) || (other.solid != 3))
        return;

    SUB_UseTargets();

    // put a tfog where the player was
    spawn_tfog(other.origin);

    if(self.targetsequence && self.targetsequence != "") {
        targetcount = tokenizebyseparator(self.targetsequence, ",");
        self.lasttarget = (self.lasttarget + 1) % targetcount;
        t = find(world, targetname, argv(self.lasttarget));
    }
    if(!t) {
        t = find(world, targetname, self.target);
    }
    if (!t)
        objerror("couldn't find target");
    
    // spawn a tfog flash in front of the destination
    makevectors(t.mangle);
    org = t.origin + 32 * v_forward;

    spawn_tfog(org);
    spawn_tdeath(t.origin, other);

    // move the player and lock him down for a little while
    if (!other.health) {
        other.origin = t.origin;
        other.velocity =
            (v_forward * other.velocity_x) +
            (v_forward * other.velocity_y);
        return;
    }
    setorigin(other, t.origin);
    other.angles = t.mangle;

    if (other.classname == "player") {
        other.fixangle = 1;
        other.teleport_time = time + 0.7;
        if (other.flags & FL_ONGROUND)
            other.flags = other.flags - FL_ONGROUND;
        other.velocity = v_forward * 300;
    }
    other.flags = other.flags - (other.flags & FL_ONGROUND);
};

void () info_teleport_destination = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    self.mangle = self.angles;
    self.angles = '0 0 0';
    self.model = "";
    self.origin = self.origin + '0 0 27';
    if (!self.targetname)
        objerror("no targetname");
};

void () teleport_use = {
    self.nextthink = time + 0.2;
    force_retouch = 2;
    self.think = SUB_Null;
};

void () trigger_teleport = {
    local vector o;

    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    InitTrigger();
    self.touch = teleport_touch;
    if (!self.target)
        objerror("no target");

    self.use = teleport_use;
    if (!(self.spawnflags & SILENT)) {
        precache_sound("ambience/hum1.wav");
        o = (self.mins + self.maxs) * 0.5;
        ambientsound(o, "ambience/hum1.wav", 0.5, ATTN_STATIC);
    }
    self.lasttarget = -1;
};

void () trigger_skill_touch = {
    local entity te;

    if (other.classname != "player")
        return;

    if (!Activated(self, other)) {
        if (self.else_goal != 0) {
            te = Findgoal(self.else_goal);
            if (te)
                AttemptToActivate(te, other, self);
        }
        return;
    }
    cvar_set("skill", self.message);
};

void () trigger_setskill = {
    dremove(self);
    return;
};

void () trigger_onlyregistered_touch = {
    local entity te;

    if (other.classname != "player")
        return;

    if (!Activated(self, other)) {
        if (self.else_goal != 0) {
            te = Findgoal(self.else_goal);
            if (te)
                AttemptToActivate(te, other, self);
        }
        return;
    }
    if (self.attack_finished > time)
        return;

    self.attack_finished = time + 2;
    if (cvar("registered")) {
        self.message = "";
        SUB_UseTargets();
        remove(self);
    } else if (self.message != "") {
        CenterPrint(other, self.message);
        FO_Sound(other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
    }
};

void () trigger_onlyregistered = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound("misc/talk.wav");
    InitTrigger();
    self.touch = trigger_onlyregistered_touch;
};

void () hurt_on = {
    self.solid = SOLID_TRIGGER;
    self.nextthink = -1;
};

void () hurt_touch = {
    local entity te;

    if (other.takedamage) {
        if (!Activated(self, other)) {
            if (self.else_goal != 0) {
                te = Findgoal(self.else_goal);
                if (te)
                    AttemptToActivate(te, other, self);
            }
            return;
        }
        self.solid = SOLID_NOT;
        deathmsg = DMSG_TRIGGER;
        TF_T_Damage(other, self, self, self.dmg, TF_TD_IGNOREARMOR,
                    TF_TD_OTHER);
        self.think = hurt_on;
        self.nextthink = time + 1;
    }
};

void () trigger_hurt = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    InitTrigger();
    self.touch = hurt_touch;
    if (!self.dmg)
        self.dmg = 5;
};

void () trigger_jumper_touch = {
    local entity te;

    if(!Activated(self, other)) {
        if((self.else_goal != 0)) {
            te = Findgoal(self.else_goal);
            if(te) {
                DoResults(te, other, (self.goal_result & TFGR_ADD_BONUSES));
            }
        }
        return;
    }
    if(((other.classname == "grenade") || (other.classname != "player"))) {
        return;
    } else {
        if(((other.health > 0) && !self.armorclass)) {
            other.velocity_z = (self.speed * 7);
            if((other.classname == "player")) {
                if((other.fly_sound < time)) {
                    other.fly_sound = (time + 1.5);
                    if(!(self.spawnflags & 2)) {
                        FO_Sound(other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
                    }
                }
            }
        }
    }
    if((self.spawnflags & 1)) {
        dremove (self);
    }
};

void () trigger_push_touch = {
    local entity te;

    if (!Activated(self, other)) {
        if (self.else_goal != 0) {
            te = Findgoal(self.else_goal);
            if (te)
                AttemptToActivate(te, other, self);
        }
        return;
    }

    float push = FALSE;
    if (other.classname == "item_tfgoal" || other.classname == "info_tfgoal")
    {
        if (self.spawnflags & PUSH_INCLUDETFITEM)
        {
            push = TRUE;
        }
    }
    else if (self.spawnflags & PUSH_EXCLUDEOTHER)
    {
        return;
    }
    else if ((self.spawnflags & PUSH_EXCLUDEGRENADE) && other.classname == "grenade")
    {
        return;
    }
    else
    {
        if (other.classname == "grenade" || other.health > 0)
        {
            push = TRUE;
        }
    }
    
    if (push)
    {
        if (self.target) // this could test for movedir but i want to be explicit, it's a bounce pad
        {
            if (!(self.spawnflags & PUSH_NONOISE))
                FO_Sound(other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
            other.velocity = self.movedir;
        }
        else
        {
            other.velocity = self.speed * self.movedir * 10;
            if (other.classname == "player") {
                if (other.fly_sound < time) {
                    other.fly_sound = time + 1.5;
                    if (!(self.spawnflags & PUSH_NONOISE))
                        FO_Sound(other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
                }
            }
        }
    }
    
    if (self.spawnflags & PUSH_ONCE)
        dremove(self);
};

void trigger_push_setup()
{
    /*
    this is based off of ioq3 gpl code
    https://github.com/ioquake/ioq3
    void AimAtTarget( gentity_t *self )
    */
    float height, gravity, airtime, dist, forward;
    vector org, targorg, origin2;

    org = (self.absmin + self.absmax) * .5;

    entity ent = find(world, targetname, self.target);
    if (!ent)
    {
        return;
    }

    targorg = ent.origin;
    height = targorg_z - org_z;        
    gravity = cvar("sv_gravity");
    airtime = sqrt(height / (.5 * gravity));

    if (!airtime)
    {
        return;
    }

    origin2 = ent.origin - org;
    origin2_z = 0;
    dist = vlen(origin2);
    origin2 = normalize(origin2);

    forward = dist / airtime;       
    origin2 = origin2 * forward;
    origin2_z = airtime * gravity;
    self.movedir = origin2;
}

void () trigger_push = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    InitTrigger();

    self.touch = trigger_push_touch;    
    if (self.target)
    {
        // the target ent might not be processed yet, so we do setup after map starts
        self.think = trigger_push_setup;
        self.nextthink = time + 1;
    }
    else
    {
        if (!self.speed) {
            self.speed = 1000;
        }
        if(self.spawnflags & PUSH_MEGAJUMPER) {
            self.touch = trigger_jumper_touch;
        }
    }
    
    if (!(self.spawnflags & PUSH_NONOISE))
    {
        if (!self.noise)
        {
            if (self.target)
            {
                // bound pads
                self.noise = "world/bouncepad.wav";
            }
            else
            {
                self.noise = "ambience/windfly.wav";
            }
        }

        precache_sound(self.noise); 
    }   

};

void () trigger_jumppad = {
    self.classname = "trigger_push";
    trigger_push();
};

void () trigger_monsterjump_touch = {
    if ((other.flags & (FL_MONSTER | FL_FLY | FL_SWIM)) != FL_MONSTER)
        return;

    other.velocity_x = self.movedir_x * self.speed;
    other.velocity_y = self.movedir_y * self.speed;

    if (!(other.flags & FL_ONGROUND))
        return;

    other.flags = other.flags - FL_ONGROUND;
    other.velocity_z = self.height;
};

void () trigger_monsterjump = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }

    if (!self.speed)
        self.speed = 200;

    if (!self.height)
        self.height = 200;

    if (self.angles == '0 0 0')
        self.angles = '0 360 0';

    InitTrigger();
    self.touch = trigger_monsterjump_touch;
};

void () trigger_jumper = {
    if(!self.noise) {
        self.noise = "world/bounce.wav"; //"misc/boing.wav"; //"world/bouncepad.wav";
    }
    self.spawnflags = self.spawnflags | PUSH_MEGAJUMPER;
    trigger_push();
}
