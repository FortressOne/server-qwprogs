//========================================================
// Non Class-Specific Impulse Commands
//========================================================

void () TeamFortress_Discard = {
	local string s = infokey(self,"keepcells");
	local float c = stof(s);
	if(nokeepcells)			//check if disabled serverside
		c = -1; 
	else if (c == 0 && s != "0")
		c = -1;			//using this to track if player doesnt want to use keepcells setinfo
	else if (c < 0)
		c = -1;
	else 
	{
		if(self.ammo_cells > c)			//changing c to track how many cells to include in discard
			c = self.ammo_cells - c;
		else
			c = 0;
	}

	
    newmis = spawn();
    switch (self.playerclass) {
        case PC_SCOUT:
		newmis.ammo_rockets = self.ammo_rockets;
		if(c > 0)
			newmis.ammo_cells = c;
		break;
        case PC_ENGINEER:
		newmis.ammo_rockets = self.ammo_rockets;
            	if(c > 0)
			newmis.ammo_cells = c;
            break;
        case PC_MEDIC:
            newmis.ammo_rockets = self.ammo_rockets;
            if(c > 0)
                newmis.ammo_cells = c;
            break;
        case PC_SNIPER:
            newmis.ammo_rockets = self.ammo_rockets;
            newmis.ammo_cells = self.ammo_cells;
            break;
        case PC_SPY:
            newmis.ammo_rockets = self.ammo_rockets;
            newmis.ammo_cells = self.ammo_cells;
            break;
        case PC_SOLDIER:
            newmis.ammo_nails = self.ammo_nails;
            newmis.ammo_cells = self.ammo_cells;
            break;
        case PC_DEMOMAN:
            newmis.ammo_cells = self.ammo_cells;
            newmis.ammo_nails = self.ammo_nails;
            break;
        case PC_HVYWEAP:
            newmis.ammo_rockets = self.ammo_rockets;
            newmis.ammo_nails = self.ammo_nails;
            if(c > 0)
		newmis.ammo_cells = c;
            break;
        case PC_PYRO:
            newmis.ammo_nails = self.ammo_nails;
            if(c > 0)
		newmis.ammo_cells = c;
            break;
        default:
    }
    if ((newmis.ammo_rockets + newmis.ammo_cells + newmis.ammo_nails + newmis.ammo_shells) == 0) {
        remove(newmis);
        return;
    }

    if (newmis.ammo_shells) {
        self.ammo_shells = 0;
    }
    if (newmis.ammo_nails) {
        self.ammo_nails = 0;
    }
    if (newmis.ammo_rockets) {
        self.ammo_rockets = 0;
    }
    if (newmis.ammo_cells) {
	if(self.playerclass == PC_SCOUT || self.playerclass == PC_MEDIC || self.playerclass == PC_PYRO || self.playerclass == PC_HVYWEAP || self.playerclass == PC_ENGINEER && c > 0)
		self.ammo_cells = self.ammo_cells - c;
	else
		self.ammo_cells = 0;
    }
    FO_Sound(self, CHAN_AUTO, "weapons/lock4.wav", 1, ATTN_NORM);
    newmis.dropped_by = self;
    newmis.dropped_at = time;
    newmis.weapon = 0;
    newmis.movetype = MOVETYPE_TOSS;
    newmis.solid = SOLID_TRIGGER;
    newmis.classname = "ammobox";
    newmis.team_no = self.team_no;
    makevectors(self.v_angle);
    if (self.v_angle_x) {
        newmis.velocity = v_forward * 400 + v_up * 200;
    } else {
        newmis.velocity = aim(self, 10000);
        newmis.velocity = newmis.velocity * 400;
        newmis.velocity_z = 200;
    }
    newmis.avelocity = '0 300 0';
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, self.origin);
    newmis.nextthink = time + 30;
    newmis.think = SUB_Remove;
    newmis.touch = TeamFortress_AmmoboxTouch;
    
	if(splitbackpackmodels)
		FO_SetModel(newmis, "progs/discard.mdl");
	else
		FO_SetModel(newmis, "progs/backpack.mdl");

};

void () TeamFortress_Discard_DropAmmo = {
    // if nothing to discard, do dropammo instead
    float disc;
    disc = 0;

    switch (self.playerclass) {
        case PC_SCOUT:
        case PC_ENGINEER:
            disc = self.ammo_rockets;
            break;
        case PC_MEDIC:
            disc = self.ammo_rockets;
            break;
        case PC_SNIPER:
        case PC_SPY:
            disc = self.ammo_rockets + self.ammo_cells;
            break;
        case PC_SOLDIER:
        case PC_DEMOMAN:
            disc = self.ammo_cells + self.ammo_nails;
            break;
        case PC_HVYWEAP:
            disc = self.ammo_rockets + self.ammo_nails;
            break;
        case PC_PYRO:
            disc = self.ammo_nails;
            break;
        default:
    }

    if (disc == 0) {
        if (self.menu_input != Menu_Drop_Input)
        	Menu_Drop();
        else
        	Menu_Close(self);
        return;
    } else {
        TeamFortress_Discard();
    }
};

void () TeamFortress_SaveMe = {
    local entity te, tl;

    if (time > self.next_saveme_sound) {
        if (random() < 0.8)
            FO_Sound(self, CHAN_WEAPON, "speech/saveme1.wav", 1, ATTN_NORM);
        else
            FO_Sound(self, CHAN_WEAPON, "speech/saveme2.wav", 1, ATTN_NORM);

        self.next_saveme_sound = time + 4;
    }
    te = find(world, classname, "player");
    while (te) {
        if ((self == te)
            || (te.playerclass == PC_MEDIC)
            || (te.playerclass == PC_ENGINEER)
            || (te.playerclass == PC_SPY)) {
            if (((te.team_no == self.team_no) && (self.team_no != 0)) ||
                (te.playerclass == PC_SPY)) {
                if (visible(te)) {
                    msg_entity = te;
                    tl = spawn();
                    tl.origin = self.origin;
                    tl.origin_z = tl.origin_z + 32;
                    WriteByte(MSG_ONE, SVC_TEMPENTITY);
                    WriteByte(MSG_ONE, TE_LIGHTNING3);
                    WriteEntity(MSG_ONE, tl);
                    WriteCoord(MSG_ONE, tl.origin_x);
                    WriteCoord(MSG_ONE, tl.origin_y);
                    WriteCoord(MSG_ONE, tl.origin_z + 24);
                    WriteCoord(MSG_ONE, self.origin_x);
                    WriteCoord(MSG_ONE, self.origin_y);
                    WriteCoord(MSG_ONE, self.origin_z);
                    dremove(tl);
                }
            }
        }
        te = find(te, classname, "player");
    }
    self.saveme_time = time;
};

void (entity pe_player) FO_SpecTrackPoint = {
    if(pe_player.classname != "observer") {
        return;
    }
    
    makevectors(pe_player.v_angle);
    traceline(pe_player.origin, pe_player.origin + v_forward * 4096, 0, pe_player);
    
    if (trace_ent != world) {
        if(trace_ent.classname == "player") {
            stuffcmd(pe_player, strcat("track \"", trace_ent.netname, "\"\n"));
        }
    }
}

void (entity pe_player) FO_Spectator_Identify = {
    //ezquake draws player ids over their heads
    if(pe_player.classname != "observer" || !infokeyf(pe_player, INFOKEY_P_CSQCACTIVE)) {
        return;
    }
    
    makevectors(pe_player.v_angle);
    //start just forward of the player in case you're speccing someone
    traceline(pe_player.origin + v_forward * 96, pe_player.origin + v_forward * 4096, MOVE_EVERYTHING, pe_player);
    
    if (trace_ent != world) {
        local string s_id_string = "";
        if(trace_ent.classname == "player") {
            //s_id_string = strcat(trace_ent.netname, "\n", TeamFortress_TeamGetColorString(trace_ent.team_no), " ", TeamFortress_GetClassName(trace_ent.playerclass), "\n");
            s_id_string = strcat(trace_ent.netname, "\n");
            if(trace_ent.playerclass == PC_SPY) {
                if (trace_ent.undercover_team || trace_ent.undercover_skin) {
                    s_id_string = strcat(s_id_string, "\sDisguised as: \s ");
                    if (trace_ent.undercover_team != 0)
                        s_id_string = strcat(s_id_string, TeamFortress_TeamGetColorString(trace_ent.undercover_team));
                    if (trace_ent.undercover_skin != 0)
                        s_id_string = strcat(s_id_string, " ", TeamFortress_GetClassName(trace_ent.undercover_skin));
                    s_id_string = strcat(s_id_string, "\n");
                }
            }
            s_id_string = strcat(s_id_string, "\sH:\s ", ftos(trace_ent.health));
            s_id_string = strcat(s_id_string, " \sA:\s ", ftos(trace_ent.armorvalue), "\n");
        } else if(trace_ent.classname == "building_sentrygun") {
            s_id_string = strcat(trace_ent.real_owner.netname, "'s Sentry Gun (", TeamFortress_TeamGetColorString(trace_ent.team_no), ")\n");
            s_id_string = strcat(s_id_string, "\sLevel:\s ", ftos(trace_ent.weapon), "\n");
            s_id_string = strcat(s_id_string, "\sH:\s ", ftos(rint(trace_ent.health)), "\n");
        } else if(trace_ent.classname == "building_sentrygun_base") {
            s_id_string = strcat(trace_ent.real_owner.netname, "'s Sentry Gun (", TeamFortress_TeamGetColorString(trace_ent.team_no), ")\n");
            s_id_string = strcat(s_id_string, "\sLevel:\s ", ftos(trace_ent.oldenemy.weapon), "\n");
            s_id_string = strcat(s_id_string, "\sH:\s ", ftos(rint(trace_ent.oldenemy.health)), "\n");
        } else if(trace_ent.classname == "building_dispenser") {
            s_id_string = strcat(trace_ent.real_owner.netname, "'s Dispenser (", TeamFortress_TeamGetColorString(trace_ent.team_no), ")\n");
            s_id_string = strcat(s_id_string, "\sH:\s ", ftos(rint(trace_ent.health)), "\n");
        } else if(trace_ent.classname == "detpack") {
            s_id_string = strcat(trace_ent.owner.netname, "'s Detpack (", TeamFortress_TeamGetColorString(trace_ent.team_no), ")\n");
            s_id_string = strcat(s_id_string, "\sTime Left:\s ", ftos(trace_ent.detpack_left), " seconds\n");
        }

       // refresh status bar
        pe_player.ident_time = time + 0.5;
        if(pe_player.ident_string != s_id_string) {
            pe_player.ident_string = s_id_string;
            UpdateClientIDString(pe_player);
        }
    }
}

void (entity pe_player, float f_type) CF_Identify = {
    if(pe_player.classname == "observer") {
        FO_Spectator_Identify(pe_player);
        return;
    }
    
    local vector v_source;
    
    makevectors(pe_player.v_angle);
    v_source = pe_player.origin + v_forward * 10;
    v_source_z = pe_player.absmin_z + pe_player.size_z * 0.7;

    traceline(v_source, v_source + v_forward * 2048, MOVE_LAGGED, pe_player);
    if (trace_ent != world) {
        local string s_id_string = "", s_class = "", s_name = "";
        local float f_health = 0, f_maxhealth = 0, f_armor = 0, f_maxarmor = 0, f_friendly = 0, f_fakefriendly = 0, f_sentryhealth = 0, f_maxsentryhealth = 0;

        // don't identify targets above water if player is under water
        if (pe_player.waterlevel == 3 && !trace_ent.waterlevel)
            return;

        // don't identify targets under water if player is above water
        if (pe_player.waterlevel < 3 && trace_ent.waterlevel == 3)
            return;

        // show as friendly if target is on your team or disguised as your team
        if (pe_player.team_no) {

            if (pe_player.team_no == trace_ent.team_no) {

                // ignore teammates if type is set to enemies only
                if (f_type == 3)
                    return;

                f_friendly = 1;

            } else if (pe_player.team_no == trace_ent.undercover_team) {

                // ignore teammates if type is set to enemies only
                if (f_type == 3)
                    return;

                f_fakefriendly = 1;

            // ignore enemies if type is set to team only
            } else if (f_type == 2)
                return;

        }

        // alive player is found
        if (trace_ent.classname == "player" && trace_ent.health) {
            
            s_name = trace_ent.netname;
            if(votemode) {
                if(trace_ent.vote_map) {
                    s_class = trace_ent.vote_map.netname;
                } else {
                    s_class = "Has not voted";
                }
            } else {
                // set class and name
                s_class = TeamFortress_GetClassName(trace_ent.playerclass);

                // set health if you're a medic
                if (pe_player.playerclass == PC_MEDIC) {
                    f_health = trace_ent.health;
                    f_maxhealth = trace_ent.max_health;
                }

                // set armor if you're an engineer
                else if (pe_player.playerclass == PC_ENGINEER) {
                    f_armor = trace_ent.armorvalue;
                    f_maxarmor = trace_ent.maxarmor;
                }

                // target is an enemy spy
                if (trace_ent.playerclass == PC_SPY && !f_friendly) {

                    // don't identify feigning enemy spies
                    if (IsFeigned(trace_ent))
                        return;

                    // use undercover name if available
                    if (trace_ent.undercover_name != string_null)
                        s_name = trace_ent.undercover_name;

                    // set class to undercover skin
                    if (trace_ent.undercover_skin)
                        s_class = TeamFortress_GetClassName(trace_ent.undercover_skin);

                }
            }

        // dispenser is found
        } else if (trace_ent.classname == "building_dispenser") {

            if (pe_player == trace_ent.real_owner)
                s_name = "Your dispenser";
            else
                s_name = strcat(trace_ent.real_owner.netname, "'s dispenser");

            s_class = "";

        // sentry gun is found
        } else if (trace_ent.classname == "building_sentrygun" || trace_ent.classname == "building_sentrygun_base") {
            if (pe_player == trace_ent.real_owner)
                s_name = "Your sentry gun";
            else {
                s_name = strcat(trace_ent.real_owner.netname, "'s sentry gun");

                if (pe_player.team_no == trace_ent.team_no) {
                    f_sentryhealth = trace_ent.health;
                    f_maxsentryhealth = trace_ent.max_health;
                }
            }

            s_class = "";
        } else {
            return;
        }

        s_name = strdecolorize(s_name);

        // set name + health (if medic)
        if (f_maxhealth && (f_friendly || f_fakefriendly)) {
            s_id_string = strcat(s_name, "\n");
            s_id_string = strcat(s_id_string, ftos(f_health));
            if (id_extended) {
                s_id_string = strcat(s_id_string, "/");
                s_id_string = strcat(s_id_string, ftos(f_maxhealth));
            }
            s_id_string = strcat(s_id_string, " hp\n");

        // set name + armor (if engineer)
        } else if (f_maxarmor && (f_friendly || f_fakefriendly)) {
            s_id_string = strcat(s_name, "\n");
            s_id_string = strcat(s_id_string, ftos(f_armor));
            if (id_extended) {
                s_id_string = strcat(s_id_string, "/");
                s_id_string = strcat(s_id_string, ftos(f_maxarmor));
            }
            s_id_string = strcat(s_id_string, " armor\n");

        // set name + health (if sentry + engineer)
        } else if (f_maxsentryhealth) {
            s_id_string = strcat(s_name, "\n");
            if (id_extended) {
                s_id_string = strcat(s_id_string, ftos(floor(f_sentryhealth)));
                s_id_string = strcat(s_id_string, "/");
                s_id_string = strcat(s_id_string, ftos(floor(f_maxsentryhealth)));
                s_id_string = strcat(s_id_string, " health");
            }
            s_id_string = strcat(s_id_string, "\n");

        // just set name (if other class)
        } else {
            s_id_string = strcat("\n", s_name);
            s_id_string = strcat(s_id_string, "\n");
        }

        if (votemode) {
            // in a voting scenario, set same vs different vote indicator
            if(pe_player.vote_map && trace_ent.vote_map) {
                if(pe_player.vote_map == trace_ent.vote_map) {
                    s_id_string = strcat(s_id_string, "\bComrade\b\n");
                } else {
                    s_id_string = strcat(s_id_string, "\bOpposition\b\n");
                }
            }
        } else {
            // set friendly/enemy
            if (f_friendly || f_fakefriendly)
                s_id_string = strcat(s_id_string, "Friendly");
            else
                s_id_string = strcat(s_id_string, "Hostile");
        }
        
        // set class
        if (s_class != "") {
            s_id_string = strcat(s_id_string, " ");
            s_id_string = strcat(s_id_string, s_class);
        }

        pe_player.ident_time = time + 0.5;

        // don't update memory when the id string is the same
        if (pe_player.ident_string == s_id_string) {
            Status_Refresh(pe_player);
            return;
        }

        // refresh status bar
        pe_player.ident_string = strzone(s_id_string);
        Status_Refresh(pe_player);
    }
};

void () TeamFortress_ReloadNext = {
    if (self.playerclass < 1 || self.playerclass > 9)
        return;

    Slot slot = self.current_slot;

    do {
        slot = FO_FindPrevNextWeaponSlot(self.playerclass, slot, FALSE);

        if (FO_CanReload(slot)) {
            FO_ReloadSlot(slot, FALSE);
            return;
        }
    } while (!IsSameSlot(slot, self.current_slot));

    sprint_pred(self, PRINT_HIGH, "All clips full\n");
}

entity TeamFortress_GetPracticeSpawn(entity e)  =
{
	local entity spt = find(world, classname, "practicespawn");
	while (spt != world) 
	{
		if (spt.owner == e)
		{
			return spt;
		}
		spt = find(spt, classname, "practicespawn");
	}
        
        return world;
};

void TeamFortress_RemovePracticeSpawn(entity e) =
{
	if(e == world)
		return;
	if(!allowpracspawns)
		return;
	
	local entity spt = TeamFortress_GetPracticeSpawn(e);
	
	if(spt != world)
	{
		spawn_tfog(spt.origin);
		dremove(spt);
	}
};


void TeamFortress_PlacePracticeSpawn(entity e) =
{
	if(e == world)
		return;
	if(!allowpracspawns)
		return;
	
	TeamFortress_RemovePracticeSpawn(e);

	local entity ps = spawn();
	ps.owner = e;
	ps.movetype = MOVETYPE_NONE;
	ps.solid = SOLID_NOT;
	ps.classname = "practicespawn";
	ps.angles = e.angles;
	setsize(ps, '0 0 0', '0 0 0');
	setorigin(ps, e.origin + '0 0 8');
	FO_SetModel(ps, "progs/s_light.spr");
	sprint(e, PRINT_HIGH, "your practice spawn has been placed @ ", vtos(e.origin),".\n");
	spawn_tfog(ps.origin);
};


