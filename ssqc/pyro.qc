//==============================================
// Weapons and functions for the PYRO class and
// associated weaponry
//==============================================

void () NapalmGrenadeTouch;
void (vector org, entity shooter) NapalmGrenadeLaunch;
void () Napalm_touch;
float (string id_flame) RemoveFlameFromQueue;

void (entity ent, float num) SetFlameCount = {
    ent.numflames = num;

    if (num == 0)
    {
        ent.tfstate = ent.tfstate - (ent.tfstate & TFSTATE_BURNING);
    }
    else
    {
        ent.tfstate = ent.tfstate | TFSTATE_BURNING;
    }
    
};

entity(string type, entity p_owner) FlameSpawn =
{
    if (cb_prematch) {
        return (world);
    }
    if (type != "1") {
        return (world);
    }
    num_world_flames = num_world_flames + 1;
    while (num_world_flames > MAX_WORLD_FLAMES) {
        if (!RemoveFlameFromQueue(type)) {
            return (world);
        }
    }
    newmis = spawn();
    if (type == "1") {
        newmis.movetype = MOVETYPE_FLYMISSILE;
        newmis.solid = SOLID_BBOX;
        newmis.effects = EF_DIMLIGHT;
        newmis.flame_id = "1";
        FO_SetModel(newmis, "progs/flame2.mdl");
        setsize(newmis, '0 0 0', '0 0 0');
    } else if (type == "2") {
        newmis.movetype = MOVETYPE_BOUNCE;
        newmis.solid = SOLID_BBOX;
        newmis.flame_id = "2";
        FO_SetModel(newmis, "progs/flame2.mdl");
        newmis.frame = 1;
        setsize(newmis, '0 0 0', '0 0 0');
    } else if (type == "3") {
        newmis.movetype = MOVETYPE_FLYMISSILE;
        newmis.solid = SOLID_BBOX;
        newmis.flame_id = "3";
        FO_SetModel(newmis, "progs/flame2.mdl");
        setsize(newmis, '0 0 0', '0 0 0');
    } else if (type == "4") {
        newmis.movetype = MOVETYPE_FLYMISSILE;
        newmis.flame_id = "4";
        newmis.frame = 1;
        newmis.solid = SOLID_BBOX;
        FO_SetModel(newmis, "progs/flame2.mdl");
        setsize(newmis, '0 0 0', '0 0 0');
    }
    newmis.owner = p_owner;
    newmis.classname = "pyro_flame";
    return (newmis);
};

void (entity this) FlameDestroy = {
    num_world_flames = num_world_flames - 1;
    dremove(this);
};

float (string id_flame) RemoveFlameFromQueue = {
    local entity tmp;

    if (num_world_flames < MAX_WORLD_FLAMES) {
        dprint("ERROR in RemoveFlameFromQueue\n");
        return (0);
    }
    num_world_flames = num_world_flames - 1;
    tmp = find(world, flame_id, "4");
    if (!tmp) {
        if (id_flame == "4") {
            return (0);
        }
        tmp = find(world, flame_id, "3");
        if (!tmp) {
            if (id_flame == "3") {
                return (0);
            }
            tmp = find(world, flame_id, "2");
            if (!tmp) {
                if (id_flame == "2") {
                    return (0);
                }
                tmp = find(world, flame_id, "1");
                if (!tmp) {
                    dprint("\n\nRemoveFlameFromQueue():BOOM!\n");
                    return (0);
                }
            }
        }
    }
    remove(tmp);
    return (1);
};



void () Remove = {
    FlameDestroy(self);
};

void () NapalmGrenadeFollow = {
    traceline(self.origin, self.origin, TRUE, self);
    if (trace_inwater == 1) {
        FO_Sound(self, CHAN_VOICE, "misc/vapeur2.wav", 1, ATTN_NORM);
        FlameDestroy(self);
    }
    if (self.velocity == '0 0 0') {
        FlameDestroy(self);
    }
    self.nextthink = time + 0.1;
};

void () NapalmGrenadeTouch = {
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void () NapalmGrenadeNetThink = {
    local entity head;
    local entity te;

    // TODO - make a settings struct and put these in on world spawn
    float explodeDam = 0;
    float maxExplosions = 0;
    switch (pyro_type)
    {
        case PYRO_FO:
            explodeDam = PC_PYRO_NAPALM_INIT_DAM_FO;
            maxExplosions = PC_PYRO_NAPALM_MAX_EXPLOSIONS_FO;
            break;
        default:
            explodeDam = PC_PYRO_NAPALM_INIT_DAM_ORIG;
            maxExplosions = PC_PYRO_NAPALM_MAX_EXPLOSIONS_ORIG;
            break;
    }

    if (self.heat == 0) {
        self.owner.no_active_napalm_grens =
            self.owner.no_active_napalm_grens + 1;
        if (self.owner.no_active_napalm_grens > 2) {
            te = find(world, classname, "grentimer");
            while (te) {
                if ((te.owner == self.owner) &&
                    (te.no_active_napalm_grens == 1)) {
                    te.weapon = DMSG_FLAME;
                    te.think = RemoveGrenade;
                    te.nextthink = time + 0.1;
                }
                te = find(te, classname, "grentimer");
            }
        }
        self.no_active_napalm_grens = self.owner.no_active_napalm_grens;
    }
    self.nextthink = time + 1;
    self.origin = self.enemy.origin;
    makevectors(self.v_angle);
    traceline(self.origin, self.origin, 1, self);
    if (trace_inwater == 1) {
        FO_Sound(self, CHAN_VOICE, "misc/vapeur2.wav", 1, ATTN_NORM);
        RemoveGrenade();
        return;
    }
    head = findradius(self.origin, 180);
    while (head) {
        if (head.takedamage) {
            deathmsg = DMSG_FLAME;
            
            TF_T_Damage(head, self, self.owner, explodeDam, TF_TD_NOTTEAM,
                        TF_TD_FIRE);
            other = head;
            Napalm_touch();
            if (other.classname == "player") {
                stuffcmd(other, "bf\nbf\n");
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

    self.heat = self.heat + 1;
    
    if (self.heat >= maxExplosions)
        RemoveGrenade();
};

void () NapalmGrenadeExplode = {
    local entity head;

    FO_Sound(self, CHAN_AUTO, "weapons/flmgrexp.wav", 1, ATTN_NORM);
    traceline(self.origin, self.origin, 1, self);
    if (trace_inwater == 1) {
        dremove(self);
        return;
    }
    self.effects = self.effects | EF_DIMLIGHT;
    head = spawn();
    head.think = NapalmGrenadeNetThink;
    head.classname = "grentimer";
    head.grenadename = "napalmfire";
    head.nextthink = time + 0.1;
    head.heat = 0;
    head.origin = self.origin;
    head.owner = self.owner;
    head.team_no = self.owner.team_no;
    head.enemy = self;
};

void (vector org, entity shooter) NapalmGrenadeLaunch = {
    local float xdir;
    local float ydir;
    local float zdir;
    local float spin;

    xdir = 150 * random() - 75;
    ydir = 150 * random() - 75;
    zdir = 40 * random();
    newmis = FlameSpawn("2", shooter);
    if (newmis == world) {
        return;
    }
    self.touch = SUB_Null;
    newmis.classname = "fire";
    newmis.touch = Napalm_touch;
    newmis.think = NapalmGrenadeFollow;
    newmis.nextthink = time + 0.1;
    newmis.enemy = shooter.owner;
    newmis.velocity_x = xdir * 2;
    newmis.velocity_y = ydir * 2;
    newmis.velocity_z = zdir * 15;
    spin = random() * 10 / 2;

    if (spin <= 0) {
        newmis.avelocity = '250 300 400';
    } else if (spin == 1) {
        newmis.avelocity = '400 250 300';
    } else if (spin == 2) {
        newmis.avelocity = '300 400 250';
    } else if (spin == 3) {
        newmis.avelocity = '300 300 300';
    } else {
        newmis.avelocity = '400 250 400';
    }
    setorigin(newmis, org);
    setsize(newmis, '0 0 0', '0 0 0');
};

void () OnPlayerFlame_touch;

void () FlameFollow = {
    local vector dir;
    local vector vtemp;
    local vector boundsize;
    local float damage;

    vtemp = self.enemy.absmin;
    boundsize = self.enemy.size;
    self.solid = SOLID_NOT;
    self.movetype = MOVETYPE_NONE;
    if (self.enemy.numflames == 0) {
        FlameDestroy(self);
        return;
    }
    if (self.enemy.health < 1) {
        deathmsg = 15;
        T_RadiusDamage(self, self, 10, self);
        SetFlameCount(self.enemy, 0);
        FlameDestroy(self);
        return;
    }
    if ((self.enemy.armorclass & AT_SAVEFIRE) && (self.enemy.armorvalue > 0)) {
        self.health = 0;
    }
    if (self.enemy.tfstate & TFSTATE_FLAMES_MAX) {
        self.health = 45;
        self.enemy.tfstate =
            self.enemy.tfstate - (self.enemy.tfstate & TFSTATE_FLAMES_MAX);
    }
    if (self.health < 1) {
        if ((self.effects != 8) || (self.enemy.numflames <= 1)) {
            SetFlameCount(self.enemy, (self.enemy.numflames - 1));
            FlameDestroy(self);
            return;
        }
    }
    self.health = self.health - 1;
    if (vlen(self.enemy.velocity) < 50) {
        dir_x = random() * boundsize_x / 2 + boundsize_x / 4;
        dir_y = random() * boundsize_y / 2 + boundsize_y / 4;
        dir_z = random() * boundsize_z / 3 + boundsize_z / 2;
        vtemp = vtemp + dir;
        setorigin(self, vtemp);
        if (self.model != "progs/flame2.mdl") {
            self.model = "progs/flame2.mdl";
            FO_SetModel(self, self.model);
        }
    } else {
        if (self.model == "progs/flame2.mdl") {
            self.model = string_null;
            setmodel(self, self.model);
        }
    }
    if ((self.enemy.waterlevel > 1) || (self.enemy.classname != "player" && self.enemy.waterlevel > 0)) {
        FO_Sound(self, CHAN_VOICE, "misc/vapeur2.wav", 1, 1);
        SetFlameCount(self.enemy, self.enemy.numflames - 1);
        FlameDestroy(self);
        return;
    }
    self.nextthink = time + 0.1;
    if ((self.effects == 8) && (self.heat >= 3)) {
        damage = 0;
        switch (pyro_type)
        {
            case PYRO_FO:
                damage = self.enemy.numflames * PC_PYRO_BURN_MULTIPLIER_FO * 3;
                break;
            default:
                damage = self.enemy.numflames * PC_PYRO_BURN_MULTIPLIER_ORIG * 3;
                break;
        }
        
        if (damage < 1) {
            damage = 1;
        }
        self.heat = 1;
        deathmsg = 15;
        TF_T_Damage(self.enemy, self, self.owner, damage, TF_TD_NOTTEAM,
                    TF_TD_FIRE);
    } else {
        if (self.effects == 8) {
            self.heat = self.heat + 1;
        }
    }
};

void (entity player, entity fireowner, vector org
        , float flamehealth) SetOnFire = {    
    entity flame;

    if (cb_prematch) 
    {
        return;
    }

    if (player.numflames >= 4) 
    {
        player.tfstate = player.tfstate | TFSTATE_FLAMES_MAX;
        return;
    }

    if ((player.armorclass & AT_SAVEFIRE) && (player.armorvalue > 0)) 
    {
        return;
    }

    if (player.classname == "player") 
    {
        if (((teamplay & 16) && (player.team_no > 0)) &&
            (player.team_no == fireowner.team_no)) {
            return;
        }
        CenterPrint(player, "You are on fire!\n");
        stuffcmd(player, "bf\n");
    }
    
    if (player.numflames < 1) 
    {
        flame = FlameSpawn("1", player);
        //FO_Sound(flame, CHAN_VOICE, "ambience/fire1.wav", 1, 1); // original tf code, but super annoying and it doesn't stop
    } 
    else
    {
        flame = FlameSpawn("3", player);
        if (flame == world) {
            return;
        }
    }
    
    flame.classname = "fire";
    flame.health = flamehealth;
    SetFlameCount(player, (player.numflames + 1));
    flame.velocity = player.velocity;
    flame.enemy = player;
    flame.touch = OnPlayerFlame_touch;
    flame.owner = fireowner;
    setorigin(flame, org);
    flame.nextthink = time + 0.1;
    flame.think = FlameFollow;
};

void () OnPlayerFlame_touch = {
    if (((other != world) && (other.health > 0)) && (other != self.enemy)) {
        float flamehealth = 45;
        SetOnFire(other, self.owner, self.origin, flamehealth);
    }
};

void () WorldFlame_touch;

void () QW_Flame_ResetTouch = {
    self.touch = WorldFlame_touch;
    self.think = Remove;
    self.nextthink = self.heat;
};

void () WorldFlame_touch = {
    deathmsg = DMSG_FLAME;
    TF_T_Damage(other, self, self.enemy, 10, TF_TD_NOTTEAM, TF_TD_FIRE);
    self.touch = SUB_Null;
    if (self.heat > (time + 1)) {
        self.think = QW_Flame_ResetTouch;
        self.nextthink = time + 1;
    }
    if (((other != world) && (other.solid != 1)) && (other.health > 0)) {
        vector org = self.origin + '0 0 10';
        float flamehealth = 0;
        SetOnFire(other, self.owner, org, flamehealth);
    }
};

void () Flamer_stream_touch = {
    if (other.classname == "fire") {
        return;
    }
    if (other != world) {
        if ((other.takedamage == 2) && (other.health > 0)) {
            deathmsg = DMSG_FLAME;

            if (flame_knockback) {
                // knockback target
                if (other.classname != "building_sentrygun" && other.classname != "building_dispenser") {
                    other.velocity = other.velocity + self.velocity / 20;
                }
            }

            if (pyro_type == PYRO_FO)
            {
                TF_T_Damage(other, self, self.owner, PC_PYRO_FLAMETHROWER_DAM_FO, TF_TD_NOTTEAM, TF_TD_FIRE);
            }
            else
            {
                TF_T_Damage(other, self, self.owner, PC_PYRO_FLAMETHROWER_DAM_ORIG, TF_TD_NOTTEAM, TF_TD_FIRE);
            }

            float flamehealth = 45;
            SetOnFire(other, self.owner, self.origin, flamehealth);
            dremove(self);
        }
    } else {
        if ((random() < 0.3) ||
            (pointcontents((self.origin + '0 0 1')) != -1)) {
            remove(self);
            return;
        }
        entity flame;
        flame = FlameSpawn("4", other);
        if (flame != world) {
            flame.touch = WorldFlame_touch;
            flame.classname = "fire";
            vector vtemp = self.origin + '0 0 10';
            setorigin(flame, vtemp);
            flame.nextthink = time + 8;
            flame.heat = flame.nextthink;
            flame.think = Remove;
            flame.enemy = self.owner;
        }
        remove(self);
    }
};

void () Napalm_touch = {
    if (other.classname == "fire") {
        return;
    }
    if (other != world) {
        if ((other.takedamage == 2) && (other.health > 0)) {
            float dam = 0;
            switch (pyro_type)
            {
                case PYRO_FO:
                    dam = PC_PYRO_INIT_BURN_DAM_FO;
                    break;
                default:
                    dam = PC_PYRO_INIT_BURN_DAM_ORIG;
                    break;
            }
            deathmsg = DMSG_FLAME;
            TF_T_Damage(other, self, self.owner, dam, TF_TD_NOTTEAM,
                        TF_TD_FIRE);

            float flamehealth = 45;
            SetOnFire(other, self.owner, self.origin, flamehealth);
        }
    } else {
        if (pointcontents((self.origin + '0 0 1')) != -1) {
            FlameDestroy(self);
            return;
        }
        entity flame;
        flame = FlameSpawn("4", other);
        if (flame != world) {
            flame.touch = WorldFlame_touch;
            flame.classname = "fire";
            vector vtemp = self.origin + '0 0 10';
            setorigin(flame, vtemp);
            flame.nextthink = time + 20;
            flame.heat = flame.nextthink;
            flame.think = Remove;
            flame.enemy = self.owner;
        }
        FlameDestroy(self);
    }
};

void (float num_bubbles, vector bub_origin) NewBubbles = {
    local entity bubble_spawner;

    bubble_spawner = spawn();
    setorigin(bubble_spawner, bub_origin);
    bubble_spawner.movetype = 0;
    bubble_spawner.solid = 0;
    bubble_spawner.nextthink = time + 0.1;
    if (self.classname == "player") {
        bubble_spawner.owner = self;
    } else {
        bubble_spawner.owner = self.enemy;
    }
    bubble_spawner.think = DeathBubblesSpawn;
    bubble_spawner.bubble_count = num_bubbles;
    return;
};

void () W_FireFlame = {
    local entity flame;
    local float rn;

    if (self.waterlevel > 2) {
        makevectors(self.v_angle);
        NewBubbles(2, self.origin + v_forward * 64);
        rn = random();
        if (rn < 0.5) {
            FO_Sound(self, CHAN_WEAPON, "misc/water1.wav", 1, ATTN_NORM);
        } else {
            FO_Sound(self, CHAN_WEAPON, "misc/water2.wav", 1, ATTN_NORM);
        }
        return;
    }
    self.ammo_cells = self.ammo_cells - 1;
    self.currentammo = self.ammo_cells;
    FO_Sound(self, CHAN_AUTO, "weapons/flmfire2.wav", 1, ATTN_NORM);
    flame = spawn();
    flame.owner = self;
    flame.movetype = MOVETYPE_FLYMISSILE;
    flame.solid = SOLID_BBOX;
    flame.classname = "flamerflame";
    makevectors(self.v_angle);
    flame.velocity = aim(self, 10000);
    if (pyro_type == PYRO_FO)
    {
        flame.velocity = flame.velocity * 600;
        flame.nextthink = time + 0.15;
    }
    else
    {
        flame.velocity = flame.velocity * 600;
        flame.nextthink = time + 0.15;
    }
    
    flame.touch = Flamer_stream_touch;
    flame.think = s_explode1;
    
    FO_SetModel(flame, "progs/s_explod.spr");
    setsize(flame, '0 0 0', '0 0 0');
    setorigin(flame, self.origin + v_forward * 16 + '0 0 16');
};

void () IncendiaryRadius = {
    entity head;
    head = findradius(self.origin, 180);
    while (head) {
        if (head.takedamage) {
            traceline(self.origin, head.origin, 1, self);
            if ((trace_fraction == 1)
                || ((trace_fraction != 1)
                    && (vlen(self.origin - head.origin) <= 64))) {
                deathmsg = DMSG_FLAME;
                TF_T_Damage(head, self, self.owner, 10, TF_TD_NOTTEAM,
                            TF_TD_FIRE);
                other = head;
                Napalm_touch();
                if (other.classname == "player") {
                    stuffcmd(other, "bf\nbf\n");
                }
            }
        }
        head = head.chain;
    }
    self.origin = self.origin - 8 * normalize(self.velocity);
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);
    dremove(self);
};

void () IncendiaryRadius_OZTF = {
    local float damg;
    if (pyro_type == 1)
        damg = 68;
    else
        damg = 92;
    deathmsg = 15;
    T_RadiusDamage(self, self.owner, damg, other);
    self.origin = (self.origin - (8 * normalize (self.velocity)));
    WriteByte(4, 23);
    WriteByte(4, 3);
    WriteCoord(4, self.origin_x);
    WriteCoord(4, self.origin_y);
    WriteCoord(4, self.origin_z);
    multicast(self.origin, 1);
    dremove(self);
};

void () T_IncendiaryTouch = {
    local float damg;

    if (other == self.owner) {
        return;
    }
    if (pointcontents(self.origin) == CONTENT_SKY) {
        remove(self);
        return;
    }
    self.effects = self.effects | 4;
    if (pyro_type == PYRO_ORIGINAL)
    {
        damg = 30 + random() * 20;
    }
    else
    {
        if (pyro_type == 1)
            damg = 68 + random() * 20;
        else
            damg = 42 + random() * 20;
    }
    
    if (other.health) {
        deathmsg = DMSG_FLAME;
        TF_T_Damage(other, self, self.owner, damg, TF_TD_NOTTEAM,
                    TF_TD_FIRE);
    }

    switch (pyro_type)
    {
        case PYRO_ORIGINAL:
            IncendiaryRadius();
            break;
        case PYRO_OZTF:
            IncendiaryRadius_OZTF();
            break;
        case PYRO_FO:
            IncendiaryRadius_OZTF();
            break;
    }
};

void () W_FireIncendiaryCannon = {
    if (self.ammo_rockets < 3) {
        return;
    }
    self.ammo_rockets = self.ammo_rockets - 3;
    self.currentammo = self.ammo_rockets;
    FO_Sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
    KickPlayer(-3, self);
    newmis = spawn();
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLYMISSILE;
    newmis.solid = SOLID_BBOX;
    makevectors(self.v_angle);
    newmis.velocity = aim(self, 1000);
    string rktmdl = "progs/missile.mdl";
    if (pyro_type == PYRO_ORIGINAL)
    {
        newmis.velocity = newmis.velocity * 600;
        newmis.think = SUB_Remove;
    }
    else
    {
        newmis.velocity = newmis.velocity * 800;
        newmis.think = IncendiaryRadius_OZTF;

        if (pyro_type == PYRO_FO)
        {
            rktmdl = "progs/lavaball.mdl";
        }
    }
    
    if (fte_lc_rockets) {
        newmis.flags = FL_LAGGEDMOVE;
    }
    
    newmis.angles = vectoangles(newmis.velocity);
    newmis.touch = T_IncendiaryTouch;
    newmis.nextthink = time + 5;
    newmis.weapon = DMSG_INCENDIARY;
    newmis.classname = "pyro_rocket";
    FO_SetModel(newmis, rktmdl);
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, self.origin + v_forward * 8 + '0 0 16');
};

void () TeamFortress_IncendiaryCannon = {
    if (!(self.weapons_carried & WEAP_INCENDIARY)) {
        return;
    }
    if (self.ammo_rockets < 3) {
        sprint(self, PRINT_HIGH, "Not enough ammo\n");
        return;
    }
    self.current_weapon = WEAP_INCENDIARY;
    W_SetCurrentAmmo(self);
};

void () TeamFortress_FlameThrower = {
    if (!(self.weapons_carried & WEAP_FLAMETHROWER)) {
        return;
    }
    if (self.ammo_cells < 1) {
        sprint(self, PRINT_HIGH, "Not enough ammo\n");
        return;
    }
    self.current_weapon = WEAP_FLAMETHROWER;
    W_SetCurrentAmmo(self);
};

void () AirBlastReloadFinished = {
    self.owner.airblast_cooldown = 0;
    sprint(self.owner, PRINT_HIGH, "Airblast ready\n");
    stuffcmd(self.owner, "play weapons/airblast.wav\n");
    dremove(self);
};

void () UseAirBlast = {
    if (self.special_cooldown < time)
    {
        self.airblast_cooldown = 1;
        self.special_cooldown = time + PC_PYRO_AIRBLAST_COOLDOWN;
        entity timer = spawn();
        timer.owner = self;
        timer.classname = "timer";
        timer.nextthink = time + PC_PYRO_AIRBLAST_COOLDOWN;
        timer.think = AirBlastReloadFinished;

        FO_Sound(self, CHAN_WEAPON, "weapons/airblastshoot.wav", 1, ATTN_NORM);
        makevectors(self.v_angle);
        entity ent;

        ent = findradius(self.origin, PC_PYRO_AIRBLAST_RANGE);
        while (ent)
        {
            if (ent.movetype != MOVETYPE_NONE && ent != self)
            {                
                if (infront(ent))
                {
                    switch (ent.classname)
                    {
                        case "player":
                        case "pyro_rocket":
                        case "flamerflame":
                        case "proj_tranq":
                        case "proj_bullet":
                        case "proj_rocket":
                        case "grenade":
                        case "spike":
                        case "pipebomb":
                            vector targorg;
                            targorg = ent.origin;
                            float pushval = 1000;
                            if (ent == self)
                            {
                                pushval = 500;
                                traceline(self.origin, self.origin + v_forward * 200, MOVE_NOMONSTERS, self);
                                if (trace_fraction < 1)
                                {
                                    targorg = self.origin - (v_forward * 200 * trace_fraction);
                                }
                            }
                            
                            vector delta = targorg - self.origin;
                            float dist = vlen(delta);
                            float percent = (PC_PYRO_AIRBLAST_RANGE - dist) / PC_PYRO_AIRBLAST_RANGE;

                            if (ent.flags & FL_ONGROUND)
                            {
                                if (ent.classname != "pipebomb" && ent != self) // leave them on ground, we don't want them blasted
                                {
                                    setorigin(ent, ent.origin + '0 0 1');
                                }
                            }
                            
                            delta = normalize(delta);
                            delta = delta * percent * pushval;

                            if (ent.movetype == MOVETYPE_FLYMISSILE)
                            {
                                float speed = vlen(ent.velocity);
                                ent.velocity = normalize(delta) * speed;
                            }
                            else
                            {
                                ent.velocity = ent.velocity + delta;
                            }
                            
                            break;
                    }
                }     
            }  
            
            ent = ent.chain;
        }
    }
    else
    {
        sprint(self, PRINT_HIGH, "Airblast is on cooldown\n");
    }
};