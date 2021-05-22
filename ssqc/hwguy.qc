void AssCanBulletTouch()
{
	if (self.voided) 
        return;				// Marked for removal
    
    self.voided = TRUE;

	if (pointcontents(self.origin) == CONTENT_SKY) {
        dremove(self);
        return;
    }

	if (other == self.owner) 
        return;			// Touching self, do nothing

    deathmsg = self.weapon;
    if (other.health)
    {
        if (fte_lc_asscann) 
            TF_T_Damage(other, self.owner, self.owner, 8, TF_TD_NOTTEAM,
                    TF_TD_OTHER);
        else 
            TF_T_Damage(other, self, self.owner, 8, TF_TD_NOTTEAM,
                TF_TD_OTHER);
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_BLOOD);
        WriteByte(MSG_MULTICAST, 1);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PVS);
    }
    else
    {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_GUNSHOT);
        WriteByte(MSG_MULTICAST, 1);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PVS);
    }

    dremove(self);
};

//======================================================================
// Vector randomizer, used mostly for avelocity setups

vector(float base, float rndmix, float plusminus) vecrand =
{
	local vector vecmix;
	if (plusminus) {
		vecmix_x = base + crandom() * rndmix; 
		vecmix_y = base + crandom() * rndmix; 
		vecmix_z = base + crandom() * rndmix; 
	}
	else {
		vecmix_x = base + random() * rndmix; 
		vecmix_y = base + random() * rndmix; 
		vecmix_z = base + random() * rndmix; 
	}
	return vecmix;
};

void LaunchAssCan(vector org, vector dir, float proj_speed)
{
    newmis = spawn();
	newmis.owner = self;
	newmis.classname = "proj_bullet";

    newmis.movetype = MOVETYPE_FLY;		// Small collision

	newmis.solid = SOLID_BBOX;
	newmis.touch = AssCanBulletTouch;

	newmis.think = SUB_Remove;
	newmis.nextthink = time + 5;	            // Stop projectile going forever

	newmis.mdl = MODEL_PROJ_DIAM2;
	FO_SetModel(newmis, newmis.mdl);				// Diamond model
	newmis.frame = random()*15;					// Full range of sizes
	newmis.skin = 16 + random()*7;				// Bright colours
    newmis.weapon = DMSG_ASSAULTCANNON;

    if (fte_lc_asscann) {
        newmis.flags = FL_LAGGEDMOVE;
    }
    
	newmis.velocity = dir * proj_speed;			// Constant speed multiplier
	newmis.angles = vectoangles(dir);			// Create direction angle
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);	// Zero size
	setorigin (newmis, org);					// Move to starting position

	newmis.avelocity = vecrand(100, 200, FALSE);
}

void FireAssCan (float shotcount, vector dir, vector spread)
{
    self.reload_assault_cannon = self.reload_assault_cannon + 1;
    Status_Refresh(self);
    CheckForReload();
    
    vector bullet_dir, spread_dir, rand_dir, org;
	float bullet_speed, var_speed;

    makevectors(self.v_angle);

    // Infront of player model and down towards gun
    bullet_speed = PC_HVYWEAP_PROJSPEED;
    bullet_dir = normalize(v_forward * bullet_speed);
    
    while (shotcount > 0) {       
		var_speed = crandom()*10 + bullet_speed;		// Slight speed variance
        rand_dir = (crandom()*spread_x) * v_right + (crandom()*spread_y) * v_up;
		spread_dir = bullet_dir + rand_dir;
        org = self.origin + '0 0 10' + rand_dir;

		LaunchAssCan(org, spread_dir, var_speed);

		shotcount = shotcount - 1;
	}
}
