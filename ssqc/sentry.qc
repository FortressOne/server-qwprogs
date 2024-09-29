//========================================================
// Weapons and functions for the Sentry Guns
//========================================================

void (entity bld) CheckBelowBuilding;
void (entity gunhead) CheckSentry;

void () Sentry_Rotate;
void () Sentry_FoundTarget;
void () Sentry_HuntTarget;
void (entity e, float f) Sentry_Pain;
void () Sentry_Die;
float () Sentry_Fire;
void () Sentry_MuzzleFlash;

void () ai_face = {
    self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
    self.ideal_yaw = anglemod(self.ideal_yaw);
    ChangeYaw();
};

//===========================
// Level 1 Sentry Gun Frames
void () lvl1_sentry_atk3;
void () lvl1_sentry_stand =[0, lvl1_sentry_stand] {
    Sentry_Rotate();
};

void () lvl1_sentry_atk1 =[1, lvl1_sentry_atk3] {
    ai_face();
    if ((self.enemy == world) || IsFeigned(self.enemy) ||
        (self.enemy.health <= 0)
        || !visible(self.enemy) || (self.enemy.has_disconnected == 1))

        lvl1_sentry_stand();
    else if (self.ammo_shells <= 0)
        lvl1_sentry_stand();
    else if (Sentry_Fire() == 0)
        lvl1_sentry_atk3();
};

void () lvl1_sentry_atk2 =[2, lvl1_sentry_atk3] {
    ai_face();
    Sentry_Fire();
};

void () lvl1_sentry_atk3 =[0, lvl1_sentry_atk1] {
    ai_face();
};

//===========================
// Level 2 Sentry Gun Frames
void () lvl2_sentry_atk3;
void () lvl2_sentry_stand =[3, lvl2_sentry_stand] {
    Sentry_Rotate();
};

void () lvl2_sentry_atk1 =[4, lvl2_sentry_atk2] {
    ai_face();
    if (((((self.enemy == world) || IsFeigned(self.enemy)) ||
          (self.enemy.health <= 0)) || !visible(self.enemy)) ||
            (self.enemy.has_disconnected == 1))
        lvl2_sentry_stand();
else if (self.ammo_shells <= 0)
        lvl2_sentry_stand();
    else if (Sentry_Fire() == 0)
        lvl2_sentry_atk3();
};

void () lvl2_sentry_atk2 =[5, lvl2_sentry_atk3] {
    ai_face();
    Sentry_Fire();
};

void () lvl2_sentry_atk3 =[3, lvl2_sentry_atk1] {
    ai_face();
    Sentry_Fire();
};

//===========================
// Level 3 Sentry Gun Frames
void () lvl3_sentry_atk3;
void () lvl3_sentry_stand =[6, lvl3_sentry_stand] {
    Sentry_Rotate();
};

void () lvl3_sentry_atk1 =[7, lvl3_sentry_atk2] {
    ai_face();
    if (((((self.enemy == world) || IsFeigned(self.enemy)) ||
          (self.enemy.health <= 0)) || !visible(self.enemy)) ||
        (self.enemy.has_disconnected == 1))

        lvl3_sentry_stand();

    else if ((self.ammo_shells <= 0) && (self.ammo_rockets <= 0))
        lvl3_sentry_stand();
    else if (Sentry_Fire() == 0)
        lvl3_sentry_atk3();
};

void () lvl3_sentry_atk2 =[8, lvl3_sentry_atk3] {
    ai_face();
    Sentry_Fire();
};

void () lvl3_sentry_atk3 =[6, lvl3_sentry_atk1] {
    ai_face();
    Sentry_Fire();
};

//===========================
float () Sentry_FindTarget = {
    local entity client;
    local float r;
    local float gotone;
    local float loopc;
    client = world;

    r = 0;
    loopc = 0;
    gotone = 0;
    while ((loopc < 12) && (gotone == 0)) {
        client = checkclient();
        gotone = 1;
        if (!client)
            gotone = 0;
        if ((client == self.real_owner) || !client.takedamage)
            gotone = 0;
        if (client.has_disconnected == 1)
            gotone = 0;

        if (teamplay) {
            if ((client.team_no == self.team_no) && (self.team_no != 0))
                gotone = 0;
            if ((client.undercover_team == self.team_no) &&
                (self.team_no != 0))
                gotone = 0;
        }
        if (IsFeigned(client))
            gotone = 0;
        if ((client.flags & FL_NOTARGET) ||
            (client.items & IT_INVISIBILITY))
            gotone = 0;
        if (!visible(client))
            gotone = 0;

        r = range(client);
        if (r == RANGE_FAR)
            gotone = 0;
        else if ((r == RANGE_MID) && !infront(client))
            gotone = 0;

        loopc = loopc + 1;
    }
    if (!gotone)
        return (0);

    self.enemy = client;
    if (self.enemy.classname != "player") {
        self.enemy = self.enemy.enemy;
        if (self.enemy.classname != "player") {
            self.enemy = world;
            return (0);
        }
    }
    Sentry_FoundTarget();
    return (1);
};

float (entity p) FO_Sentry_ValidTarget = {
    float valid = TRUE;

    if (!p)
        return FALSE;

    if ((p == self.real_owner) || !p.takedamage)
        valid = FALSE;
    if (p.has_disconnected == 1)
        valid = FALSE;

    if (teamplay) {
        if ((p.team_no == self.team_no) && (self.team_no != 0))
            valid = FALSE;
        if ((p.undercover_team == self.team_no) &&
            (self.team_no != 0))
            valid = FALSE;
    }
    if (IsFeigned(p))
        valid = FALSE;
    if ((p.flags & FL_NOTARGET) ||
        (p.items & IT_INVISIBILITY))
        valid = FALSE;
    if (!visible(p))
        valid = FALSE;

    float r = range(p);
    if (r == RANGE_FAR)
        valid = FALSE;
    else if ((r == RANGE_MID) && !infront(p))
        valid = FALSE;

    return valid;
};


float () FO_Sentry_FindTarget = {

    // check for current valid target
    if (FO_Sentry_ValidTarget(self.enemy))
    {
        if (self.cnt <= time)
        {
            Sentry_FoundTarget();
            return TRUE;
        }
        return FALSE;
    }

    entity p = find(world, classname, "player");
    float foundTarg = FALSE;
    float dist = -1;
    entity targ = world;

    while (p)
    {
        // do checks
        if (FO_Sentry_ValidTarget(p))
        {
            // do vlen check
            if (dist == -1)
            {
                dist = vlen(self.origin - p.origin);
                targ = p;
            }
            else if (dist > vlen(self.origin - p.origin))
            {
                dist = vlen(self.origin - p.origin);
                targ = p;
            }
        }        

        p = find(p, classname, "player");
    }

    if (!targ)
    {
        self.enemy = world;
        return FALSE;
    }
        
    self.enemy = targ;
    if (self.enemy.classname != "player") {
        self.enemy = self.enemy.enemy;
        if (self.enemy.classname != "player") {
            self.enemy = world;
            return FALSE;
        }
    }

    vector spot1 = self.origin + self.view_ofs;
    vector spot2 = self.enemy.origin + self.enemy.view_ofs;

    float r = vlen(spot1 - spot2);
    float delay = 0.25;
    if (r >= 500) // RANGE_MID, 500 is halfway of sentry targeting distance
    {
        delay = 0.45;
    }
    self.cnt = time + delay; // delay

    return TRUE;
};

void () Sentry_Rotate = {
    local float ay;

    self.effects = self.effects - (self.effects & EF_DIMLIGHT);
    CheckSentry(self);

    if (fo_sentry_targeting)
    {
        if (FO_Sentry_FindTarget())
            return;
    }
    else
    {
        if (Sentry_FindTarget())
            return;
    }

    if (self.heat == 0) {
        self.ideal_yaw = self.waitmin;
        ChangeYaw();
        ay = anglemod(self.angles_y);
        ay = rint(ay);
        if (ay == rint(self.waitmin)) {
            CheckBelowBuilding(self.trigger_field);
            self.heat = 1;
            if (random() < 0.1)
                FO_Sound(self, CHAN_ITEM, "weapons/turridle.wav", 1,
                      ATTN_NORM);
        }
    } else {
        self.ideal_yaw = self.waitmax;
        ChangeYaw();
        ay = anglemod(self.angles_y);
        ay = rint(ay);
        if (ay == rint(self.waitmax)) {
            CheckBelowBuilding(self.trigger_field);
            self.heat = 0;
        }
    }
};

void () Sentry_FoundTarget = {
    if ((self.ammo_shells > 0) ||
        ((self.ammo_rockets > 0) && (self.weapon == 3)))
        FO_Sound(self, CHAN_VOICE, "weapons/turrspot.wav", 1, ATTN_NORM);

    Sentry_HuntTarget();

    if (self.super_damage_finished < time)
        self.super_damage_finished = time + 0.5;
};

void () Sentry_HuntTarget = {
    if (self.tfstate & TFSTATE_RESPAWN_READY)
        return;

    self.goalentity = self.enemy;

    if (self.weapon == 1)
        self.think = lvl1_sentry_atk1;
    else if (self.weapon == 2)
        self.think = lvl2_sentry_atk1;
    else
        self.think = lvl3_sentry_atk1;

    self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
    self.nextthink = time + 0.1;
    SUB_AttackFinished(1);
};

void (entity e, float f) Sentry_Pain = {
    Status_Refresh(self.real_owner);
};

void () Sentry_Explode = {
    ThrowGib("progs/tgib1.mdl", -70);
    ThrowGib("progs/tgib2.mdl", -70);
    ThrowGib("progs/tgib3.mdl", -70);

    if (self.real_owner.has_disconnected != 1) {
        deathmsg = DMSG_SENTRYGUN_EXPLODE;
        T_RadiusDamage(self, self.real_owner, 75 + self.ammo_rockets * 8,
                       self);
    }
    if (self.classname == "building_sentrygun_base") {
        if (self.oldenemy)
            dremove(self.oldenemy);
    } else if (self.trigger_field != world)
        dremove(self.trigger_field);

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    BecomeExplosion();
};

void () Sentry_Die = {
    sprint(self.real_owner, PRINT_HIGH, "Your sentry gun was destroyed\n");
    stuffcmd(self.real_owner, "play misc/chink.wav\n");
    local entity ro = self.real_owner;
    ro.has_sentry = 0;

    self.tfstate = self.tfstate | TFSTATE_RESPAWN_READY;
    self.think = Sentry_Explode;
    self.nextthink = time + 0.1;
    if (ro.is_building) {
        self = ro;
        TeamFortress_EngineerBuildStop();
    }
};

float () Sentry_Fire = {
    local vector dir, org;

    self.effects = self.effects - (self.effects & EF_DIMLIGHT);
    org = self.origin;
    org_z = org_z + 20;
    dir = self.enemy.origin - org;

    if (((self.ideal_yaw - anglemod(self.angles_y)) < -10)
        || ((self.ideal_yaw - anglemod(self.angles_y)) > 10))
        return 0;

    if (IsFeigned(self.enemy))
        return 0;

    if ((self.weapon == 3) && (self.ammo_rockets > 0) &&
        (self.super_damage_finished < time)) {
        Sentry_MuzzleFlash();
        FO_Sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

        newmis = spawn();
        newmis.owner = self;
        newmis.movetype = MOVETYPE_FLYMISSILE;
        newmis.solid = SOLID_BBOX;

        newmis.velocity = normalize(self.enemy.origin - self.origin) * 800;
        newmis.angles = vectoangles(newmis.velocity);
        newmis.weapon = DMSG_SENTRYGUN_ROCKET;
        newmis.touch = T_MissileTouch;

        newmis.nextthink = time + 5;
        newmis.think = SUB_Remove;

        FO_SetModel(newmis, "progs/missile.mdl");
        setsize(newmis, '0 0 0', '0 0 0');
        setorigin(newmis, self.origin + v_forward * 8 + '0 0 16');

        self.super_damage_finished = time + 3;
        self.ammo_rockets = self.ammo_rockets - 1;

        if (self.ammo_rockets == 10)
            sprint(self.real_owner, PRINT_HIGH,
                   "Sentry gun is low on rockets\n");
    }
    self.ammo_shells = self.ammo_shells - 1;
    if (self.ammo_shells < 0) {
        self.ammo_shells = 0;
        return (0);
    }
    Sentry_MuzzleFlash();
    FO_Sound(self, CHAN_WEAPON, "weapons/sniper.wav", 1, ATTN_NORM);

    deathmsg = DMSG_SENTRYGUN_BULLET;

    self.v_angle = self.angles;
    FireBullets(4, dir, '0.1 0.1 0');

    if ((self.ammo_shells == 0) && (random() < 0.1))
        sprint(self.real_owner, PRINT_HIGH,
               "Sentry gun is out of shells\n");
    else if (self.ammo_shells == 20)
        sprint(self.real_owner, PRINT_HIGH,
               "Sentry gun is low on shells\n");

    if ((self.ammo_rockets == 0) && (self.weapon == 3) && (random() < 0.1))
        sprint(self.real_owner, PRINT_HIGH,
               "Sentry gun is out of rockets\n");

    return (1);
};

void () Sentry_MuzzleFlash = {
    self.effects = self.effects | EF_DIMLIGHT;
};
