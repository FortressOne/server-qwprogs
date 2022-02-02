//========================================================
// Functions for the SOLDIER class and associated weaponry
//========================================================

void () NailGrenadeExplode;
void () NailGrenadeNailEm;
void () NailGrenadeLaunchNail;
void () NailGrenLaser;
void () NailGrenBurst;

void () NailGrenadeTouch = {
    if (other == self.owner)
        return;

    // If the Nail Grenade hits a player, it just bounces off
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void () NailGrenadeExplode = {
    local entity te;

    self.owner.no_active_nail_grens = self.owner.no_active_nail_grens + 1;
    if (self.owner.no_active_nail_grens >= max_active_gren2_soldier) {

        te = find(world, classname, "grenade");
        while (te) {
            if ((te.owner == self.owner || te.real_owner == self.owner) && (te.no_active_nail_grens == 1)) {
                if (!te.owner)
                    te.owner = te.real_owner;
                te.weapon = 9;
                te.think = GrenadeExplode;
                te.nextthink = time + 0.1;
            }
            te = find(te, classname, "grenade");
        }
    }
    self.no_active_nail_grens = self.owner.no_active_nail_grens;
    self.movetype = MOVETYPE_FLY;
    setorigin(self, self.origin + '0 0 32');
    if(solid_nailgren) {
        setsize(self, '-1 -1 -1', '1 1 1');
    }
    self.avelocity = '0 500 0';
    self.nextthink = time + 0.7;
    if (nailgren_type == NGR_TYPE_LASER)		
    {
    self.playerclass = 0;
    self.think = NailGrenLaser;
    }
    else if (nailgren_type == NGR_TYPE_BURST)
    {	
    self.playerclass = 0;
    self.think = NailGrenBurst;
    }
    else
    {
    self.think = NailGrenadeNailEm;
    }
};

void () NailGrenadeNailEm = {
    self.velocity = '0 0 0';
    self.nextthink = time + 0.1;
    self.think = NailGrenadeLaunchNail;
    self.playerclass = 0;
};

void () NailGrenadeLaunchNail = {
    local float i, j;
    local float current_yaw;

    i = 0;
    while (i < 3) {

        j = (random() + 2) * 5;
        current_yaw = anglemod(self.angles_y + j);
        self.angles_y = current_yaw;
        self.angles_x = 0;
        self.angles_z = 0;
        makevectors(self.angles);

        deathmsg = DMSG_GREN_NAIL;
        launch_spike(self.origin, v_forward);
        newmis.velocity = v_forward * 1000;
        newmis.touch = superspike_touch;
        newmis.weapon = DMSG_GREN_NAIL;

        i = i + 1;
    }
    self.playerclass = self.playerclass + 1;
    self.nextthink = time + 0.1;

    if (self.playerclass > 50) {
        self.weapon = DMSG_GREN_NAIL;
        self.think = GrenadeExplode;
    }
};

void () NailGrenLaser = {	//using self.playerclass to count thinks
    local float current_yaw;
    local vector org;
    
    if(self.playerclass == 0){
        self.velocity = '0 0 0';
        self.real_owner = self.owner;
        self.owner = world;			//work-around because traceent wouldnt hit self or self.owner
        current_yaw = 0;
        lasergren_reqthinks = (lasergren_rotationcount * lasergren_rotationtime) / lasergren_thinktime;
        lasergren_angleperthink = (lasergren_rotationcount * 360) / lasergren_reqthinks;
        self.v_angle = self.angles;
    } else {
        current_yaw = anglemod(self.v_angle_y + lasergren_angleperthink);
    }
    self.v_angle_y = current_yaw;
    self.v_angle_x = 0;
    self.v_angle_z = 0;
    self.angles = self.v_angle;
    makevectors(self.v_angle);

    org = self.origin;
    traceline(org, org + v_forward * lasergren_range, 0, self);

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_LIGHTNING2);
    WriteEntity(MSG_MULTICAST, self);
    WriteCoord(MSG_MULTICAST, org_x);
    WriteCoord(MSG_MULTICAST, org_y);
    WriteCoord(MSG_MULTICAST, org_z);
    WriteCoord(MSG_MULTICAST, trace_endpos_x);
    WriteCoord(MSG_MULTICAST, trace_endpos_y);
    WriteCoord(MSG_MULTICAST, trace_endpos_z);
    multicast(org, MULTICAST_PHS);
    
    if (trace_ent.takedamage){
	
	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, TE_LIGHTNINGBLOOD);
	WriteCoord(MSG_MULTICAST, trace_endpos_x);
	WriteCoord(MSG_MULTICAST, trace_endpos_y);
	WriteCoord(MSG_MULTICAST, trace_endpos_z);
	multicast(trace_endpos, MULTICAST_PVS);
    
	deathmsg = DMSG_GREN_NAIL;
	TF_T_Damage(trace_ent, self, self.real_owner, lasergren_damage, TF_TD_NOTTEAM, TF_TD_ELECTRICITY);
	}
    if (self.t_width < time) {
        FO_Sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
        self.t_width = time + 0.8;
    }
    
    self.nextthink = time + lasergren_thinktime;
    self.playerclass++;
    //already did this above
    //current_yaw = anglemod(self.angles_y + lasergren_angleperthink);
	
    if (self.playerclass > lasergren_reqthinks) { 	//not >= to give an extra think so it hits start again
	self.owner = self.real_owner;
        self.weapon = DMSG_GREN_NAIL;
        self.think = GrenadeExplode;
    }
};

void () NailGrenBurst = {
    local float i;
    local float current_yaw;
    current_yaw = 0;
    i = 0;
    self.velocity = '0 0 0';
	
    while (i < 16){
	self.angles_y = current_yaw;
	self.angles_x = 0;
	self.angles_z = 0;
	makevectors(self.angles);
	
	sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	
	deathmsg = DMSG_GREN_NAIL;
	launch_spike(self.origin, v_forward);
        newmis.velocity = v_forward * 1000;
        newmis.touch = superspike_touch;
        newmis.weapon = DMSG_GREN_NAIL;
        newmis.nextthink = time + burstgren_range;
        i++;
        current_yaw = anglemod(self.angles_y + 22.5);
    }
    self.playerclass++;
    self.nextthink = time + burstgren_interval;
	
    if (self.playerclass >= burstgren_count){
	self.nextthink = time + 0.1;
	self.weapon = DMSG_GREN_NAIL;
        self.think = GrenadeExplode;
	}
};

void () TeamFortress_NailGrenInfo = {
    sprint(self,2,Q"\n\snailgren info - num in brackets are default - num shown are to one dec place - updated on map change\s\n");
    sprint(self,2,Q"\n\s----------------------------------------------------------------------------------------------\s\n");
    sprint(self,2,Q"ngt   nailgren_type           ",ftos(nailgren_type)," (",ftos(NGR_TYPE_DEFAULT),") \s// 0 default, 1 laser, 2 burst \n\n");
    sprint(self,2,Q"lgrc  lasergren_rotationcount ",ftos(lasergren_rotationcount)," (",ftos(NGR_LASER_DEFAULT_ROTATIONCOUNT),") \s// how many rotations to perform\n");
    sprint(self,2,Q"lgrt  lasergren_rotationtime  ",ftos(lasergren_rotationtime)," (",ftos(NGR_LASER_DEFAULT_ROTATIONTIME),") \s// time to complete one rotation\n");
    sprint(self,2,Q"lgr   lasergren_range         ",ftos(lasergren_range)," (",ftos(NGR_LASER_DEFAULT_RANGE),") \s// range\n");
    sprint(self,2,Q"lgd   lasergren_damage        ",ftos(lasergren_damage)," (",ftos(NGR_LASER_DEFAULT_DAMAGE),") \s// damage\n");
    sprint(self,2,Q"lgtt  lasergren_thinktime   ",ftos(lasergren_thinktime)," (0.1) \s// time between thinks, lower to smooth rotation \n\n");
    sprint(self,2,Q"bgc   burstgren_count         ",ftos(burstgren_count)," (",ftos(NGR_BURST_DEFAULT_COUNT),") \s// how many bursts of nails\n");
    sprint(self,2,Q"bgi   burstgren_interval    ",ftos(burstgren_interval)," (",ftos(NGR_BURST_DEFAULT_INTERVAL),") \s// time between bursts\n");
    sprint(self,2,Q"bgr   burstgren_range       ",ftos(burstgren_range)," (",ftos(NGR_BURST_DEFAULT_RANGE),") \s// time before nail projectiles destroyself\n");
    sprint(self,2,Q"\s----------------------------------------------------------------------------------------------\s\n");
    self.impulse = 0;
};
