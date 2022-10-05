//========================================================
// Functions for the DEMOMAN class and associated weaponry
//========================================================

void () NormalGrenadeTouch;
void () NormalGrenadeExplode;

void () MirvGrenadeTouch;
void () MirvGrenadeExplode;
void (vector org, entity shooter) MirvGrenadeLaunch;

void () TeamFortress_DetpackMenu;
void () TeamFortress_DetpackStop;
void () TeamFortress_DetpackSet;
void () TeamFortress_DetpackExplode;
void () TeamFortress_DetpackTouch;
void () TeamFortress_DetpackDisarm;
void () TeamFortress_DetpackCountDown;
void CheckStateQ3Goal(entity trig);

float (float force) TeamFortress_DetonatePipebombs = {
    if (time < self.pipecooldown && !force)
        return impulse_queue ? FALSE : TRUE;

    int count;
    entity* pipes = find_list(classname, "pipebomb", EV_STRING, count);

    float rewound = FALSE;
    if (!force && count > 0)
        rewound = AL_RewindPlayersExceptSelf(self.pipecooldown);

    for (float i = 0; i < count; i++) {
        if (pipes[i].owner == self) {
            deathmsg = pipes[i].flags & FL_ONGROUND ? pipes[i].weapon :
                                                      DMSG_GREN_PIPE_AIR;

            T_RadiusDamage_Antilag(pipes[i], pipes[i].owner, 120, world);

            // This maintains some sort of awful hack that we'll remove.
            pipes[i].voided = 1;

            RenderExplosion(pipes[i].origin);
            RemoveDeferred(pipes[i]);
        }
    }

    if (rewound)
        FOPlayer::RestoreAll();

    return TRUE;
};

void () PipebombTouch = {
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void () MirvGrenadeTouch = {
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void () MirvGrenadeExplode = {
    local float i;

    deathmsg = DMSG_GREN_MIRV;
    T_RadiusDamage(self, self.owner, 100, world);

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    self.solid = SOLID_NOT;
    i = 0;
    while (i < 4) {
        MirvGrenadeLaunch(self.origin + '0 0 -1', self.owner);
        i = i + 1;
    }
    BecomeExplosion();

};

void (vector org, entity shooter) MirvGrenadeLaunch = {
    local float xdir;
    local float ydir;
    local float zdir;

    xdir = 150 * random() - 75;
    ydir = 150 * random() - 75;
    zdir = 40 * random();

    newmis = spawn();
    newmis.owner = shooter;
    newmis.movetype = MOVETYPE_BOUNCE;
    newmis.solid = SOLID_BBOX;

    newmis.classname = "grenade";
    newmis.grenadename = "mirvsinglegrenade";
    newmis.weapon = DMSG_GREN_MIRV;
    newmis.touch = NormalGrenadeTouch;
    newmis.think = NormalGrenadeExplode;
    newmis.nextthink = time + 2 + random();

    newmis.velocity_x = xdir * 2;
    newmis.velocity_y = ydir * 2;
    newmis.velocity_z = zdir * 15;
    newmis.avelocity = '250 300 400';

    FO_SetModel(newmis, "progs/grenade2.mdl");

    setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
    setorigin(newmis, org);
};

void () TeamFortress_DetpackMenu = {
    local entity detpack;

    if (self.ammo_detpack <= 0) {
        if (time >= self.antispam_detpack) {
            sprint(self, PRINT_HIGH, "You do not have any detpacks left\n");
            self.antispam_detpack = time + 3;
        }
        return;
    }

    detpack = find(world, classname, "detpack");
    while (detpack) {
        if (detpack.owner == self) {
            if (time >= self.antispam_detpack) {
                sprint(self, PRINT_HIGH, "You can only have one detpack active at a time\n");
                self.antispam_detpack = time + 3;
            }
            return;
        }
        detpack = find(detpack, classname, "detpack");
    }

    Menu_Demoman();
};

void (float timer) TeamFortress_ToggleDetpack = {
    if (self.is_detpacking) {
        TeamFortress_DetpackStop();
    } else {
        TeamFortress_SetDetpack(timer);
    }
};

void (float timer) TeamFortress_SetDetpack = {
    local string stimer;
    local entity te;
    local entity at_spot;

    self.impulse = 0;
    self.last_impulse = 0;
    if (!(self.weapons_carried & WEAP_DETPACK)) {
        sprint(self, PRINT_HIGH, "You don't have a detpack\n");
        return;
    }

    if (self.ammo_detpack <= 0) {
        sprint(self, PRINT_HIGH, "You don't have any detpacks left\n");
        return;
    }

    if (no_fire_mode) {
        sprint(self, PRINT_HIGH, "You can't set a detpack right now\n");
        return;
    }    
    
    at_spot = findradius(self.origin, 65);
    while (at_spot != world) {

        if ((at_spot.classname == "player") && (self != at_spot)) {
            sprint(self, PRINT_HIGH,
                   "You cannot set a detpack on someone\n");
            return;
        } else if ((at_spot.mdl == "progs/turrbase.mdl") ||
                   (at_spot.mdl == "progs/turrgun.mdl")) {
            sprint(self, PRINT_HIGH,
                   "You cannot set a detpack on a sentry gun\n");
            return;
        } else if (at_spot.mdl == "progs/disp.mdl") {
            sprint(self, PRINT_HIGH,
                   "You cannot set a detpack on a dispenser\n");
            return;
        } else if (at_spot.classname == "detpack") {
            sprint(self, PRINT_HIGH, "Detpacks cannot be stacked\n");
            return;
        }
        at_spot = at_spot.chain;
    }

    if (!self.waterlevel) {
        if (!(self.flags & FL_ONGROUND)) {
            sprint(self, PRINT_HIGH, "You cannot set detpacks in the air\n");
            return;
        }
    }

    te = find(world, classname, "detpack");
    while (te) {
        if (te.owner == self) {
            sprint(self, PRINT_HIGH,
                   "You can only have one detpack active at a time\n");
            return;
        }
        te = find(te, classname, "detpack");
    }

    if (timer < 5) {
        sprint(self, PRINT_HIGH,
               "You cannot set detpacks for less than 5 seconds\n");
        return;
    }

    self.is_detpacking = 3;
    self.detpack_left = timer;
    self.ammo_detpack = self.ammo_detpack - 1;
    self.immune_to_check = time + 10;
    self.tfstate = self.tfstate | TFSTATE_CANT_MOVE;
    self.weapon = self.current_weapon;
    self.next_weapon = self.current_weapon;
    self.current_weapon = 0;
    self.weaponmodel = "";
    self.weaponframe = 0;

    Status_Refresh(self);
    TeamFortress_SetSpeed(self);

    self.pausetime = time + 3;
    stimer = ftos(timer);

    sprint(self, PRINT_HIGH, "Setting detpack for ", stimer,
           " seconds...\n");
    Menu_Demoman_Cancel();

    newmis = spawn();
    newmis.owner = self;
    newmis.classname = "timer";
    newmis.netname = "detpack_timer";
    newmis.nextthink = time + 1;
    newmis.think = TeamFortress_DetpackSet;
    newmis.health = timer;
};

void () TeamFortress_DetpackStop = {
    local entity detpack_timer;

    detpack_timer = find(world, netname, "detpack_timer");
    while ((detpack_timer.owner != self) && (detpack_timer != world))
        detpack_timer = find(detpack_timer, netname, "detpack_timer");

    if (detpack_timer == world)
        return;

    sprint(self, PRINT_HIGH, "Detpack retrieved\n");
    Menu_Close(self);
    self.ammo_detpack = self.ammo_detpack + 1;
    dremove(detpack_timer);

    self.tfstate = self.tfstate - (self.tfstate & TFSTATE_CANT_MOVE);
    self.is_detpacking = 0;
    self.detpack_left = 0;
    self.current_weapon = self.next_weapon;

    Status_Refresh(self);
    W_SetCurrentAmmo(self);
    TeamFortress_SetSpeed(self);
    self.pausetime = time;
};

void () TeamFortress_DetpackSet = {
    local entity countd;
    local entity oldself;

    if (self.owner.is_detpacking > 1) {
        self.owner.is_detpacking = self.owner.is_detpacking - 1;
        self.nextthink = time + 1.0;
        Status_Refresh(self.owner);
        return;
    }

    self.owner.is_detpacking = 0;
    Menu_Close(self.owner);
    self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_CANT_MOVE);
    TeamFortress_SetSpeed(self.owner);
    FO_Sound(self.owner, CHAN_VOICE, "doors/medtry.wav", 1, ATTN_NORM);
    oldself = self;
    self = self.owner;
    self.is_detpacking = 0;
    self.current_weapon = self.next_weapon;
    Status_Refresh(self);
    W_SetCurrentAmmo(self);
    self = oldself;

    newmis = spawn();
    newmis.owner = self.owner;
    newmis.origin = (self.owner.origin - '0 0 23');
    newmis.movetype = MOVETYPE_BOUNCE;
    if(solid_detpack) {
        newmis.solid = SOLID_BBOX;
    } else {
        newmis.solid = SOLID_TRIGGER; //so that scout can disarm
    }
    newmis.classname = "detpack";
    newmis.flags = FL_ITEM;
    newmis.angles = '90 0 0';
    newmis.angles_y = self.owner.angles_y;
    newmis.velocity = '0 0 0';
    newmis.avelocity = '0 0 0';
    newmis.weaponmode = 0;
    newmis.touch = TeamFortress_DetpackTouch;

    FO_SetModel(newmis, "progs/detpack.mdl");

    setsize(newmis, '-16 -16 0', '16 16 8');
    setorigin(newmis, self.owner.origin);

    countd = spawn();
    newmis.linked_list = countd;
    countd.think = TeamFortress_DetpackCountDown;
    countd.health = self.health - 1;
    countd.owner = self.owner;
    countd.classname = "countdown_timer";
    countd.enemy = newmis;
    newmis.oldenemy = countd;

    if (self.health <= 255) {
        countd.nextthink = time + 1;
    } else {
        countd.nextthink = time + self.health - 10;
        countd.health = 9;
    }
    newmis.nextthink = time + self.health;
    newmis.think = TeamFortress_DetpackExplode;
    sprint(self.owner, PRINT_HIGH, "Detpack set!\n");
    dremove(self);
};

void () TeamFortress_DetpackExplode = {
    local float pos;
    local float points;
    local entity head;
    local entity te;
    local vector org;

    self.owner.detpack_left = 0;
    bprint(PRINT_MEDIUM, "FIRE IN THE HOLE!\n");
    FO_Sound(self, CHAN_WEAPON, "weapons/detpack.wav", 1, ATTN_NONE);
    pos = pointcontents(self.origin);
    if ((pos != CONTENT_SOLID) && (pos != CONTENT_SKY) &&
        (self.owner.has_disconnected != 1)) {
        deathmsg = DMSG_DETPACK;
        head = findradius(self.origin, 1500);
        while (head) {
            if (head.classname == "info_tfgoal") {
                if ((head.goal_activation & TFGA_TOUCH_DETPACK) &&
                    (head.search_time == 0)) {
                    traceline(self.origin, head.origin, 1, self);
                    if (trace_fraction == 1) {
                        if (Activated(head, self.owner))
                            DoResults(head, self.owner, 1);
                        else if (head.else_goal != 0) {
                            te = Findgoal(head.else_goal);
                            if (te)
                                AttemptToActivate(te, self.owner, head);
                        }
                    }
                }
            }
            else if (head.classname == "info_notnull")
            {
                // q3 detpackable goals
                if (strstrofs(head.flagsq3, "chargeable") >= 0)
                {
                    traceline(self.origin, head.origin, 1, self);
                    if (trace_fraction == 1) 
                    {
                        CheckStateQ3Goal(head);
                    }
                }
            }
            else if (head.takedamage &&
                       (vlen((head.origin - self.origin)) <= 700)) 
            {
                org = head.origin + (head.mins + head.maxs) * 0.5;
                points = 0.5 * vlen(self.origin - org);
                if (points < 0)
                    points = 0;

                points = 700 - points;
                if (points) {
                    if (CanDamage(head, self))
                        TF_T_Damage(head, self, self.owner, points * 2,
                                    TF_TD_NOTTEAM, TF_TD_EXPLOSION);
                }
            }
            head = head.chain;
        }
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_EXPLOSION);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PHS);
    } else
        sprint(self.owner, PRINT_HIGH, "Your detpack fizzled out\n");

    if (self.weaponmode == 1) {
        TeamFortress_SetSpeed(self.enemy);
        dremove(self.oldenemy);
        dremove(self.observer_list);
    }
    BecomeExplosion();
};

void () TeamFortress_DetpackTouch = {
    local entity disarm;
    local vector source;

    CheckBelowBuilding(self);

    if (other.classname != "player")
        return;
    if (other.playerclass != PC_SCOUT)
        return;
    if (other.deadflag)
        return;
    if (self.weaponmode == 1)
        return;

    if ((other.team_no == self.owner.team_no) && (self.owner.team_no != 0))
        return;

    makevectors(other.v_angle);
    //source = other.origin + '0 0 16';
    source = other.origin + other.view_ofs;
    
    self.solid = SOLID_BBOX;
    traceline(source, source + v_forward * 64, MOVE_HITMODEL | MOVE_EVERYTHING | MOVE_TRIGGERS, other);
    if(!solid_detpack)
        self.solid = SOLID_TRIGGER;
    if ((trace_fraction == 1) || (trace_ent != self)) {
        return;
    }

    other.immune_to_check = time + 5;
    other.tfstate = other.tfstate | TFSTATE_CANT_MOVE;

    sprint(other, PRINT_HIGH, "Disarming detpack...\n");

    TeamFortress_SetSpeed(other);

    disarm = spawn();
    disarm.owner = other;
    disarm.enemy = self;
    disarm.classname = "timer";
    disarm.nextthink = time + 3;
    disarm.think = TeamFortress_DetpackDisarm;

    self.weaponmode = 1;
    self.enemy = other;
    self.observer_list = disarm;
};

void () TeamFortress_DetpackDisarm = {
    if (self.owner.deadflag != 0) {
        dremove(self);
        return;
    }
    bprint(PRINT_MEDIUM, self.enemy.owner.netname,
           "'s detpack was defused by ", self.owner.netname, "\n");
    self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_CANT_MOVE);
    TF_AddFrags(self.owner, 1);
    TeamFortress_SetSpeed(self.owner);
    self.enemy.owner.detpack_left = 0;
    Status_Refresh(self.enemy.owner);

    dremove(self.enemy.oldenemy);
    dremove(self.enemy);
    dremove(self);
};

void () TeamFortress_DetpackCountDown = {
    local string cd;

    cd = ftos(self.health);
    CheckBelowBuilding(self.enemy);
    self.nextthink = time + 1;
    self.owner.detpack_left = self.health;
    self.health = self.health - 1;
    Status_Refresh(self.owner);

    if (self.health < 10) {

        sprint(self.owner, PRINT_HIGH, cd, "...\n");

        if ((self.health < 5) && (self.has_disconnected == 0)) {
            FO_Sound(self.enemy, CHAN_VOICE, "doors/baseuse.wav", 1,
                  ATTN_NORM);
            self.has_disconnected = 1;
        }

        if ((self.health < 5) && (self.enemy.skin == 0))
            self.enemy.skin = 1;
        else
            self.enemy.skin = 0;

        if (self.health == 0)
            dremove(self);
    }

};
