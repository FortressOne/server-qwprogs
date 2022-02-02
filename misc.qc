float GetQ3State(string st);

void () info_null = {
    dremove(self);
};

void () info_notnull = {
    self.state = GetQ3State(self.initialstate);
    
    for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
    switch (argv(i)) {
            case "flags":
                string s = argv(i + 1);
                if (s == "chargeable")
                {
                    self.flagsq3 = s;
                    self.flags = FL_FINDABLE_NONSOLID;
                }
                break;
            default:
                break;
        }
    }
};

void () light_use = {
    if (self.spawnflags & 1) {
        lightstyle(self.style, "m");
        self.spawnflags = self.spawnflags - 1;
    } else {
        lightstyle(self.style, "a");
        self.spawnflags = self.spawnflags + 1;
    }
};

void () light = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    if (!self.targetname) {
        dremove(self);
        return;
    }
    if (self.style >= 32) {

        self.use = light_use;
        if (self.spawnflags & 1)
            lightstyle(self.style, "a");
        else
            lightstyle(self.style, "m");
    }
};

void () light_fluoro = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    if (self.style >= 32) {

        self.use = light_use;
        if (self.spawnflags & 1)
            lightstyle(self.style, "a");
        else
            lightstyle(self.style, "m");
    }
    precache_sound("ambience/fl_hum1.wav");
    ambientsound(self.origin, "ambience/fl_hum1.wav", 0.5, 3);
};

void () light_fluorospark = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    if (!self.style)
        self.style = 10;

    precache_sound("ambience/buzz1.wav");
    ambientsound(self.origin, "ambience/buzz1.wav", 0.5, 3);
};

void () light_globe = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    precache_model("progs/s_light.spr");
    setmodel(self, "progs/s_light.spr");
    makestatic(self);
};

void () FireAmbient = {
    precache_sound("ambience/fire1.wav");
    ambientsound(self.origin, "ambience/fire1.wav", 0.5, 3);
};

void () light_torch_small_walltorch = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    precache_model("progs/flame.mdl");
    setmodel(self, "progs/flame.mdl");
    FireAmbient();
    makestatic(self);
};

void () light_flame_large_yellow = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    precache_model("progs/flame2.mdl");
    setmodel(self, "progs/flame2.mdl");
    self.frame = 1;
    FireAmbient();
    makestatic(self);
};

void () light_flame_small_yellow = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    precache_model("progs/flame2.mdl");
    setmodel(self, "progs/flame2.mdl");
    FireAmbient();
    makestatic(self);
};

void () light_flame_small_white = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    precache_model("progs/flame2.mdl");
    setmodel(self, "progs/flame2.mdl");
    FireAmbient();
    makestatic(self);
};

void () fire_fly;
void () fire_touch;

void () misc_fireball = {
    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    precache_model("progs/lavaball.mdl");
    self.classname = "fireball";
    self.nextthink = time + random() * 5;
    self.think = fire_fly;
    if (!self.speed)
        self.speed = 1000;
};

void () fire_fly = {
    newmis = spawn();
    newmis.solid = 1;
    newmis.movetype = 6;
    newmis.velocity = '0 0 1000';
    newmis.velocity_x = random() * 100 - 50;
    newmis.velocity_y = random() * 100 - 50;
    newmis.velocity_z = self.speed + random() * 200;
    newmis.classname = "fireball";
    FO_SetModel(newmis, "progs/lavaball.mdl");
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, self.origin);
    newmis.nextthink = time + 5;
    newmis.think = SUB_Remove;
    newmis.touch = fire_touch;
    self.nextthink = time + random() * 5 + 3;
    self.think = fire_fly;
};

void () fire_touch = {
    if (other.takedamage)
        TF_T_Damage(other, self, self, 20, 0, 16);

    dremove(self);
};

void () barrel_explode = {
    self.takedamage = 0;
    self.classname = "explo_box";
    T_RadiusDamage(self, self, 160, world);
    WriteByte(4, 23);
    WriteByte(4, 3);
    WriteCoord(4, self.origin_x);
    WriteCoord(4, self.origin_y);
    WriteCoord(4, (self.origin_z + 32));
    multicast(self.origin, 1);
    remove(self);
};

void () misc_explobox = {
    local float oldz;

    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    self.solid = 2;
    self.movetype = 0;
    precache_model("maps/b_explob.bsp");
    FO_SetModel(self, "maps/b_explob.bsp");
    setsize(self, '0 0 0', '32 32 64');
    precache_sound("weapons/r_exp3.wav");
    self.health = 20;
    self.th_die = barrel_explode;
    self.takedamage = 2;
    self.origin_z = (self.origin_z + 2);
    oldz = self.origin_z;
    droptofloor();
    if ((oldz - self.origin_z) > 250) {

        dprint("item fell out of level at ");
        dprint(vtos(self.origin));
        dprint("\n");
        dremove(self);
    }
};

void () misc_explobox2 = {
    local float oldz;

    if (CheckExistence() == 0) {
        dremove(self);
        return;
    }
    self.solid = 2;
    self.movetype = 0;
    precache_model2("maps/b_exbox2.bsp");
    FO_SetModel(self, "maps/b_exbox2.bsp");
    setsize(self, '0 0 0', '32 32 32');
    precache_sound("weapons/r_exp3.wav");
    self.health = 20;
    self.th_die = barrel_explode;
    self.takedamage = 2;
    self.origin_z = (self.origin_z + 2);
    oldz = self.origin_z;
    droptofloor();
    if ((oldz - self.origin_z) > 250) {

        dprint("item fell out of level at ");
        dprint(vtos(self.origin));
        dprint("\n");
        dremove(self);
    }
};

void (vector org, vector vec) LaunchLaser;

void () Laser_Touch = {
    local vector org;

    if (other == self.owner)
        return;

    if (pointcontents(self.origin) == -6) {
        dremove(self);
        return;
    }
    FO_Sound(self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
    org = self.origin - 8 * normalize(self.velocity);
    if (other.health) {
        SpawnBlood(org, 15);
        TF_T_Damage(other, self, self.owner, 15, 0, TF_TD_ELECTRICITY);
    } else {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_GUNSHOT);
        WriteByte(MSG_MULTICAST, 5);
        WriteCoord(MSG_MULTICAST, org_x);
        WriteCoord(MSG_MULTICAST, org_y);
        WriteCoord(MSG_MULTICAST, org_z);
        multicast(org, 2);
    }
    dremove(self);
};

void (vector org, vector vec) LaunchLaser = {
    if (self.classname == "monster_enforcer")
        FO_Sound(self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

    vec = normalize(vec);
    newmis = spawn();
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLY;
    newmis.solid = SOLID_BBOX;
    newmis.effects = EF_DIMLIGHT;
    FO_SetModel(newmis, "progs/laser.mdl");
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, org);
    newmis.velocity = vec * 600;
    newmis.angles = vectoangles(newmis.velocity);
    newmis.nextthink = time + 5;
    newmis.think = SUB_Remove;
    newmis.touch = Laser_Touch;
};

void () spikeshooter_use = {
    if (self.spawnflags & 2) {
        FO_Sound(self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
        LaunchLaser(self.origin, self.movedir);
    } else {
        FO_Sound(self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);

        launch_spike(self.origin, self.movedir);
        newmis.velocity = self.movedir * 500;

        if (self.spawnflags & 1)
            newmis.touch = superspike_touch;
    }
};

void () shooter_think = {
    spikeshooter_use();
    self.nextthink = time + self.wait;
    newmis.velocity = self.movedir * 500;
};

void () trap_spikeshooter = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    SetMovedir();
    self.use = spikeshooter_use;

    if (self.spawnflags & 2) {
        precache_model2("progs/laser.mdl");
        precache_sound2("enforcer/enfire.wav");
        precache_sound2("enforcer/enfstop.wav");
    } else
        precache_sound("weapons/spike2.wav");
};

void () trap_shooter = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    trap_spikeshooter();

    if (self.wait == 0)
        self.wait = 1;

    self.nextthink = self.nextthink + self.wait + self.ltime;
    self.think = shooter_think;
};

void () make_bubbles;
void () bubble_remove;

void () air_bubbles = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    dremove(self);
};

void () make_bubbles = {
    newmis = spawn();
    FO_SetModel(newmis, "progs/s_bubble.spr");
    setorigin(newmis, self.origin);
    newmis.movetype = MOVETYPE_NOCLIP;
    newmis.solid = SOLID_NOT;
    newmis.velocity = '0 0 15';
    newmis.nextthink = time + 0.5;
    newmis.think = bubble_bob;
    newmis.touch = bubble_remove;
    newmis.classname = "bubble";
    newmis.frame = 0;
    newmis.cnt = 0;
    setsize(newmis, '-8 -8 -8', '8 8 8');
    self.nextthink = time + random() + 0.5;
    self.think = make_bubbles;
};

void () bubble_split = {
    newmis = spawn();
    FO_SetModel(newmis, "progs/s_bubble.spr");
    setorigin(newmis, self.origin);
    newmis.movetype = MOVETYPE_NOCLIP;
    newmis.solid = SOLID_NOT;
    newmis.velocity = self.velocity;
    newmis.nextthink = time + 0.5;
    newmis.think = bubble_bob;
    newmis.touch = bubble_remove;
    newmis.classname = "bubble";
    newmis.frame = 1;
    newmis.cnt = 10;
    setsize(newmis, '-8 -8 -8', '8 8 8');
    self.frame = 1;
    self.cnt = 10;

    if (self.waterlevel != 3)
        remove(self);
};

void () bubble_remove = {
    if (other.classname == self.classname)
        return;
    dremove(self);
};

void () bubble_bob = {
    local float rnd1, rnd2, rnd3;

    self.cnt = self.cnt + 1;
    if (self.cnt == 4)
        bubble_split();

    if (self.cnt == 20)
        dremove(self);

    rnd1 = self.velocity_x + (-10 + random() * 20);
    rnd2 = self.velocity_y + (-10 + random() * 20);
    rnd3 = self.velocity_z + 10 + random() * 10;

    if (rnd1 > 10)
        rnd1 = 5;
    else if (rnd1 < -10)
        rnd1 = -5;

    if (rnd2 > 10)
        rnd2 = 5;
    else if (rnd2 < -10)
        rnd2 = -5;

    if (rnd3 < 10)
        rnd3 = 15;
    else if (rnd3 > 30)
        rnd3 = 25;

    self.velocity_x = rnd1;
    self.velocity_y = rnd2;
    self.velocity_z = rnd3;

    self.nextthink = time + 0.5;
    self.think = bubble_bob;
};

void () viewthing = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_NOT;
    precache_model("progs/player.mdl");
    FO_SetModel(self, "progs/player.mdl");
};

void () func_wall_use = {
    if (self.spawnflags & WALL_SOLID_NOT_ON_USE)
    {
        self.solid = self.solid ? SOLID_NOT : SOLID_BSP;   
    }
    
    if (self.spawnflags & WALL_HIDE_ON_USE)
    {
        if (self.dimension_seen != DMN_INVISIBLE)
        {
            self.old_dimension_seen = self.dimension_seen;
            self.dimension_seen = DMN_INVISIBLE;
        }
        else
        {
            float val = self.dimension_seen;
            self.dimension_seen = self.old_dimension_seen;
            self.old_dimension_seen = val;
        }
    }
    else
    {
        self.frame = (1 - self.frame);
    }
};

void () func_wall = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    self.angles = '0 0 0';
    self.movetype = MOVETYPE_PUSH;
    self.use = func_wall_use;    

    if (self.spawnflags & WALL_SOLID_NOT)
    {
        self.solid = SOLID_NOT;
    }
    else
    {
        self.solid = SOLID_BSP;
    }
    float team_bit = 0;
    switch (self.team_no)
    {
        case TEAM_BLUE:
            team_bit = DMN_TEAMBLUE;
            break;
        case TEAM_RED:
            team_bit = DMN_TEAMRED;
            break;
        case TEAM_YELL:
            team_bit = DMN_TEAMYELL;
            break;
        case TEAM_GREN:
            team_bit = DMN_TEAMGREN;
            break;
        default:
            break;
    }
    self.dimension_seen = self.dimension_seen | team_bit;

    if (self.dimension_seen & DMN_INVISIBLE)
        self.old_dimension_seen = DMN_NOFLASH | DMN_FLASH | team_bit;
    else
        self.old_dimension_seen = self.dimension_seen | DMN_NOFLASH | DMN_FLASH;
    

    setmodel(self, self.model);
    //self.mdl = self.model;
};

void () func_illusionary = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    self.angles = '0 0 0';
    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_NOT;
    setmodel(self, self.model);
    makestatic(self);
};

void () func_episodegate = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    if (!(serverflags & self.spawnflags))
        return;

    self.angles = '0 0 0';
    self.movetype = MOVETYPE_PUSH;
    self.solid = SOLID_BSP;
    self.use = func_wall_use;
    setmodel(self, self.model);
};

void () func_bossgate = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }

    if ((serverflags & 15) == 15)
        return;

    self.angles = '0 0 0';
    self.movetype = MOVETYPE_PUSH;
    self.solid = SOLID_BSP;
    self.use = func_wall_use;
    setmodel(self, self.model);
};

void () ambient_suck_wind = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound("ambience/suck1.wav");
    ambientsound(self.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
};

void () ambient_drone = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound("ambience/drone6.wav");
    ambientsound(self.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
};

void () ambient_flouro_buzz = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound("ambience/buzz1.wav");
    ambientsound(self.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
};

void () ambient_drip = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound("ambience/drip1.wav");
    ambientsound(self.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
};

void () ambient_comp_hum = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound("ambience/comp1.wav");
    ambientsound(self.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
};

void () ambient_thunder = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound("ambience/thunder1.wav");
    ambientsound(self.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
};

void () ambient_light_buzz = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound("ambience/fl_hum1.wav");
    ambientsound(self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

void () ambient_swamp1 = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound("ambience/swamp1.wav");
    ambientsound(self.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
};

void () ambient_swamp2 = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound("ambience/swamp2.wav");
    ambientsound(self.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
};

void () noise_think = {
    self.nextthink = time + 0.5;
    FO_Sound(self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);
    FO_Sound(self, CHAN_VOICE, "enforcer/enfstop.wav", 1, ATTN_NORM);
    FO_Sound(self, CHAN_ITEM, "enforcer/sight1.wav", 1, ATTN_NORM);
    FO_Sound(self, CHAN_BODY, "enforcer/sight2.wav", 1, ATTN_NORM);
    FO_Sound(self, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
    FO_Sound(self, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
    FO_Sound(self, 7, "enforcer/pain1.wav", 1, ATTN_NORM);

};

void () misc_noisemaker = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    precache_sound2("enforcer/enfire.wav");
    precache_sound2("enforcer/enfstop.wav");
    precache_sound2("enforcer/sight1.wav");
    precache_sound2("enforcer/sight2.wav");
    precache_sound2("enforcer/sight3.wav");
    precache_sound2("enforcer/sight4.wav");
    precache_sound2("enforcer/pain1.wav");
    precache_sound2("enforcer/pain2.wav");
    precache_sound2("enforcer/death1.wav");
    precache_sound2("enforcer/idle1.wav");
    self.nextthink = time + 0.1 + random();
    self.think = noise_think;
};

void() blocker_use = 
{
	if (!(self.state))
	{
		self.state = 1;
		setorigin(self, self.origin - '8000 8000 8000');
		sound(self, CHAN_VOICE, self.noise1, 1, 1);
	}
	else
	{
		self.state = 0;
		setorigin(self, self.origin + '8000 8000 8000');
		sound(self, CHAN_VOICE, self.noise, 1, 1);
	}
};

void(entity attacker, float damage) glass_pain = 
{
	if (self.spawnflags & 8)
	{
		self.health = self.max_health;
	}
};

void() glass_die = 
{
	local entity new;
	local vector tmpvec;
	while (self.cnt2 > 0)
	{
		new = spawn();
		new.origin = self.origin;
		if (random() < 0.5)
		{
			FO_SetModel(new, "progs/glass2.mdl");
		}
		else
		{
			FO_SetModel(new, "progs/glass1.mdl");
		}
		setsize(new, '0 0 0', '0 0 0');
		if (self.height != 100)
		{
			new.velocity_x = 70 * crandom();
			new.velocity_y = 70 * crandom();
			new.velocity_z = 140 + 70 * random();
		}
		else
		{
			new.velocity_x = 400 * crandom();
			new.velocity_y = 400 * crandom();
			new.velocity_z = 140 + 70 * random();
		}
		new.movetype = 10;
		new.solid = 2;
		new.avelocity_x = random() * 600;
		new.avelocity_y = random() * 600;
		new.avelocity_z = random() * 600;
		new.nextthink = time + 2 + random() * 3;
		new.think = SUB_Remove;
		self.absmin = self.origin + self.mins;
		self.absmax = self.origin + self.maxs;
		tmpvec_x = self.absmin_x + random() * (self.absmax_x - self.absmin_x);
		tmpvec_y = self.absmin_y + random() * (self.absmax_y - self.absmin_y);
		tmpvec_z = self.absmin_z + random() * (self.absmax_z - self.absmin_z);
		setorigin(new, tmpvec);
		self.cnt2 = self.cnt2 - 1;
	}
	if (self.noise2)
	{
		if (pointcontents(self.origin) == -3)
		{
			sound(self, CHAN_VOICE, "effects/rcksplsh.wav", 1, 1);
		}
		else
		{
			sound(self, CHAN_VOICE, self.noise2, 1, 1);
		}
	}
	remove(self);
};

void() func_glass = 
{
	local vector tmpvec;
	self.movetype = 7;
	self.solid = 4;
	self.mdl = self.model;
	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);
	self.model = string_null;
	precache_sound("misc/null.wav");
    precache_sound("effects/rcksplsh.wav");
    precache_sound("effects/shatter.wav");
    precache_model("progs/glass2.mdl");
    precache_model("progs/glass1.mdl");
    
	if (self.health > 0)
	{
		if (!(self.cnt2))
		{
			tmpvec = self.maxs - self.mins;
			tmpvec = tmpvec * 0.031;
			if (tmpvec_x < 1)
			{
				tmpvec_x = 1;
			}
			if (tmpvec_y < 1)
			{
				tmpvec_y = 1;
			}
			if (tmpvec_z < 1)
			{
				tmpvec_z = 1;
			}
			self.cnt2 = tmpvec_x * tmpvec_y * tmpvec_z;
		}
		else
		{
			if (self.cnt2 == -1)
			{
				self.cnt2 = 0;
			}
		}
		if (self.cnt2 > 16)
		{
			self.cnt2 = 16;
		}
		self.takedamage = 1;
		self.max_health = self.health;
		self.th_die = glass_die;
		self.th_pain = glass_pain;
		precache_model("progs/glass1.mdl");
		precache_model("progs/glass2.mdl");
	}
	if (self.target)
	{
		if (!(self.speed))
		{
			self.speed = 100;
		}
		if (!(self.dmg))
		{
			self.dmg = 2;
		}
		if (self.sounds == 1)
		{
			if (!(self.noise))
			{
				self.noise = "plats/train2.wav";
			}
			if (!(self.noise1))
			{
				self.noise1 = "plats/train1.wav";
			}
			precache_sound(self.noise);
			precache_sound(self.noise1);
		}
		self.cnt = 1;
		self.blocked = train_blocked;
		self.use = train_use;
		self.classname = "train";
		self.think = func_train_find;
		self.nextthink = self.ltime + 0.6;
	}
	else
	{
		self.use = blocker_use;
		if (self.spawnflags & 4)
		{
			self.state = 0;
			setorigin(self, self.origin + '8000 8000 8000');
		}
		else
		{
			self.state = 1;
			if (self.noise1)
			{
				sound(self, CHAN_VOICE, self.noise1, 1, 1);
			}
		}
	}
	if (!(self.noise))
	{
		self.noise = "misc/null.wav";
	}
	if (!(self.noise1))
	{
		self.noise1 = "misc/null.wav";
	}
	if (!(self.noise2))
	{
		self.noise2 = "effects/shatter.wav";
	}
	precache_sound(self.noise);
	precache_sound(self.noise1);
	precache_sound(self.noise2);
};
