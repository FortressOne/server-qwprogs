//========================================================
// Non Class-Specific Impulse Commands
//========================================================

void () TeamFortress_ClipTick;

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
            if (!medicaura && old_medikit) {
                newmis.ammo_cells = self.ammo_cells;
            }
            else
            {
		if(c > 0)
			newmis.ammo_cells = c;
	     }
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
    W_SetCurrentAmmo(self);
    FO_Sound(self, CHAN_AUTO, "weapons/lock4.wav", 1, ATTN_NORM);
    newmis.enemy = self;
    newmis.health = time;
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
            if (!medicaura && old_medikit) {
                disc += self.ammo_cells;
            }
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

    if (self.last_saveme_sound < time) {
        if (random() < 0.8)
            FO_Sound(self, CHAN_WEAPON, "speech/saveme1.wav", 1, ATTN_NORM);
        else
            FO_Sound(self, CHAN_WEAPON, "speech/saveme2.wav", 1, ATTN_NORM);

        self.last_saveme_sound = time + 4;
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
            //if(infokeyf(pe_player, INFOKEY_P_CSQCACTIVE)) {
                UpdateClientIDString(pe_player);
            //} else {
            //    Status_Refresh(pe_player);
            //}
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
                    if (trace_ent.is_feigning)
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

void TeamFortress_ReloadWeapon(float weap)
{
    local float reloadtime = 0;
    local float reloadamount = 0;
    local entity tWeapon, tClip;

    if (self.tfstate & TFSTATE_RELOADING) {
        return;
    }
    if (weap == WEAP_SHOTGUN) {
        if (self.ammo_shells == 0) {
            sprint(self, PRINT_HIGH, "Out of shells\n");
            return;
        }
        if (self.reload_shotgun == 0) {
            sprint(self, PRINT_HIGH, "Clip full\n");
            return;
        }
        if ((8 - self.reload_shotgun) == self.ammo_shells) {
            sprint(self, PRINT_HIGH, "All shells are in the clip\n");
            return;
        }
        if (self.ammo_shells >= 1) {
            self.current_weapon = weap;
            if (self.reload_shotgun >= self.ammo_shells)
                reloadamount = self.ammo_shells;
            else
                reloadamount = self.reload_shotgun;
            Attack_Finished(0.4);
            self.reload_clipsize = (8 - reloadamount);
            reloadtime = (8 - reloadamount) / 8;
            reloadtime = 2 - 2 * reloadtime;
            self.reload_shotgun = 0;
            if (self.ammo_shells < 8) {
                self.reload_shotgun = 8 - self.ammo_shells;
            }
            sprint(self, PRINT_HIGH, "Reloading Shotgun...\n");
            self.tfstate = self.tfstate | TFSTATE_RELOADING;
            Status_Refresh(self);
            tWeapon = spawn();
            tWeapon.owner = self;
            tWeapon.classname = "timer";
            tWeapon.nextthink = time + reloadtime;
            tWeapon.think = W_Reload_shotgun;
            self.weaponmodel = "";
            self.weaponframe = 0;
        } else {
            sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
        }
    } else if (weap == WEAP_SUPER_SHOTGUN) {
        if (self.ammo_shells == 0) {
            sprint(self, PRINT_HIGH, "Out of shells\n");
            return;
        }
        if (self.reload_super_shotgun == 0) {
            sprint(self, PRINT_HIGH, "Clip full\n");
            return;
        }
        if ((16 - self.reload_super_shotgun) == self.ammo_shells) {
            sprint(self, PRINT_HIGH, "All shells are in the clip\n");
            return;
        }
        if (self.ammo_shells >= 2) {
            self.current_weapon = weap;
            if (self.reload_super_shotgun >= self.ammo_shells)
                reloadamount = self.ammo_shells;
            else
                reloadamount = self.reload_super_shotgun;
            Attack_Finished(0.7);
            self.reload_clipsize = (16 - reloadamount);
            reloadtime = (16 - reloadamount) / 16;
            reloadtime = 3 - (3 * reloadtime);
            self.reload_super_shotgun = 0;
            if (self.ammo_shells < 16) {
                self.reload_super_shotgun = 16 - self.ammo_shells;
            }
            sprint(self, PRINT_HIGH, "Reloading Super Shotgun...\n");
            self.tfstate = self.tfstate | TFSTATE_RELOADING;
            Status_Refresh(self);
            tWeapon = spawn();
            tWeapon.owner = self;
            tWeapon.classname = "timer";
            tWeapon.nextthink = time + reloadtime;
            tWeapon.think = W_Reload_super_shotgun;
            self.weaponmodel = "";
            self.weaponframe = 0;
        } else {
            sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
        }
    } else if (weap == WEAP_SNIPER_RIFLE) {
        if (self.ammo_shells == 0) {
            sprint(self, PRINT_HIGH, "Out of shells\n");
            return;
        }
        if (self.reload_sniper_rifle == 0) {
            sprint(self, PRINT_HIGH, "Clip full\n");
            return;
        }
        if ((16 - self.reload_sniper_rifle) == self.ammo_shells) {
            sprint(self, PRINT_HIGH, "All shells are in the clip\n");
            return;
        }
        if (self.ammo_shells >= 1) {
            self.current_weapon = weap;
            if (self.reload_super_shotgun >= self.ammo_shells)
                reloadamount = self.ammo_shells;
            else
                reloadamount = self.reload_sniper_rifle;
            Attack_Finished(1.5);
            self.reload_clipsize = (1 - reloadamount);
            self.reload_sniper_rifle = 0;
            self.reload_sniper_ticks = 0;
            if (self.ammo_shells < 1) {
                self.reload_sniper_rifle = 1 - self.ammo_shells;
            }
            sprint(self, PRINT_HIGH, "Reloading Sniper Rifle...\n");
            self.tfstate = self.tfstate | TFSTATE_RELOADING;
            Status_Refresh(self);
            tWeapon = spawn();
            tWeapon.owner = self;
            tWeapon.classname = "timer";
            tWeapon.nextthink = time + 1; // this will tick four times before finishing reload
            tWeapon.think = W_Reload_sniper_rifle_tick;
            self.weaponmodel = "";
            self.weaponframe = 0;
        } else {
            sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
        }
    } else if (weap == WEAP_GRENADE_LAUNCHER) {
        if (self.ammo_rockets == 0) {
            sprint(self, PRINT_HIGH, "Out of grenades\n");
            return;
        }
        if (self.reload_grenade_launcher == 0) {
            sprint(self, PRINT_HIGH, "Clip full\n");
            return;
        }
        if ((6 - self.reload_grenade_launcher) ==
            self.ammo_rockets) {
            sprint(self, PRINT_HIGH, "All grenades are in the clip\n");
            return;
        }
        if (self.ammo_rockets >= 1) {
            self.current_weapon = weap;
            if (self.reload_grenade_launcher >= self.ammo_rockets)
                reloadamount = self.ammo_rockets;
            else
                reloadamount = self.reload_grenade_launcher;
            Attack_Finished(0.6);
            self.reload_clipsize = (6 - reloadamount);
            reloadtime = (6 - reloadamount) / 6;
            reloadtime = 4 - 4 * reloadtime;
            self.reload_grenade_launcher = 0;
            if (self.ammo_rockets < 6) {
                self.reload_grenade_launcher =
                    6 - self.ammo_rockets;
            }
            sprint(self, PRINT_HIGH, "Reloading Grenade Launcher...\n");
            self.tfstate = self.tfstate | TFSTATE_RELOADING;
            Status_Refresh(self);
            tWeapon = spawn();
            tWeapon.owner = self;
            tWeapon.classname = "timer";
            tWeapon.nextthink = time + reloadtime;
            tWeapon.think = W_Reload_grenade_launcher;
            self.weaponmodel = "";
            self.weaponframe = 0;
        } else {
            sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
        }
    } else if (weap == WEAP_ROCKET_LAUNCHER) {
        if (self.ammo_rockets == 0) {
            sprint(self, PRINT_HIGH, "Out of rockets\n");
            return;
        }
        if (self.reload_rocket_launcher == 0) {
            sprint(self, PRINT_HIGH, "Clip full\n");
            return;
        }
        if ((4 - self.reload_rocket_launcher) ==
            self.ammo_rockets) {
            sprint(self, PRINT_HIGH, "All rockets are in the clip\n");
            return;
        }
        if (self.ammo_rockets >= 1) {
            self.current_weapon = weap;
            if (self.reload_rocket_launcher >= self.ammo_rockets)
                reloadamount = self.ammo_rockets;
            else
                reloadamount = self.reload_rocket_launcher;
            Attack_Finished(0.8);
            self.reload_clipsize = (4 - reloadamount);
            reloadtime = (4 - reloadamount) / 4;
            reloadtime = 5 - (5 * reloadtime);
            self.reload_rocket_launcher = 0;
            if (self.ammo_rockets < 4) {
                self.reload_rocket_launcher =
                    4 - self.ammo_rockets;
            }
            sprint(self, PRINT_HIGH, "Reloading Rocket Launcher...\n");
            self.tfstate = self.tfstate | TFSTATE_RELOADING;
            Status_Refresh(self);
            tWeapon = spawn();
            tWeapon.owner = self;
            tWeapon.classname = "timer";
            tWeapon.nextthink = time + reloadtime;
            tWeapon.think = W_Reload_rocket_launcher;
            self.weaponmodel = "";
            self.weaponframe = 0;
        } else {
            sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
        }
    } else if (weap == WEAP_ASSAULT_CANNON) {
        if (fo_hwguy)
        {
            if (self.ammo_shells == 0) {
                sprint(self, PRINT_HIGH, "Out of shells\n");
                return;
            }

            if (self.reload_assault_cannon == 0) {
                sprint(self, PRINT_HIGH, "Clip full\n");
                return;
            }

            if ((PC_HVYWEAP_ASSCAN_CLIPSIZE - self.reload_assault_cannon) == self.ammo_shells) {
                sprint(self, PRINT_HIGH, "All shells are in the clip\n");
                return;
            }

            if (self.ammo_shells >= 1) {
                self.current_weapon = weap;
                if (self.reload_assault_cannon >= self.ammo_shells)
                    reloadamount = self.ammo_shells;
                else
                    reloadamount = self.reload_assault_cannon;
                Attack_Finished(0.8);
                self.reload_clipsize = (PC_HVYWEAP_ASSCAN_CLIPSIZE - reloadamount);
                reloadtime = (PC_HVYWEAP_ASSCAN_CLIPSIZE - reloadamount) / PC_HVYWEAP_ASSCAN_CLIPSIZE;
                reloadtime = 4 - (4 * reloadtime);
                self.reload_assault_cannon = 0;
                if (self.ammo_shells < PC_HVYWEAP_ASSCAN_CLIPSIZE) {
                    self.reload_assault_cannon = PC_HVYWEAP_ASSCAN_CLIPSIZE - self.ammo_shells;
                }
                sprint(self, PRINT_HIGH, "Reloading Assault Cannon...\n");
                self.tfstate = self.tfstate | TFSTATE_RELOADING;
                Status_Refresh(self);
                tWeapon = spawn();
                tWeapon.owner = self;
                tWeapon.classname = "timer";
                tWeapon.nextthink = time + reloadtime;
                tWeapon.think = W_Reload_assault_cannon;
                self.weaponmodel = "";
                self.weaponframe = 0;
            } else {
                sprint(self, PRINT_HIGH, "Not enough ammo to reload\n");
            }
        }        
    }

    if (reloadamount && reloadtime) {
        self.reload_time = time + reloadtime;
        self.reload_tick = reloadtime / reloadamount;
        tClip = spawn();
        tClip.owner = self;
        tClip.classname = "timer";
        tClip.nextthink = time + self.reload_tick;
        tClip.think = TeamFortress_ClipTick;
    }
}

void () TeamFortress_ReloadCurrentWeapon = {
    TeamFortress_ReloadWeapon(self.current_weapon);
};

void (float slot) TeamFortress_ReloadSlot = {
    local float weap = 0;

    if (!IsUsingOldImpulses()) {
        if (slot < 1 || slot > 3)
            return;

        if (slot == 1)
            weap = W_WeaponSlot1();
        else if (slot == 2)
            weap = W_WeaponSlot2();
        else if (slot == 3) {
            if (self.playerclass == PC_SCOUT || self.playerclass == PC_ENGINEER)
                return;
            weap = W_WeaponSlot3();
        }
        TeamFortress_ReloadWeapon(weap);
    }
    else {
        if (slot < 1 || slot > 7)
            return;
        if (slot == 1)
            weap = W_OldWeaponSlot1();
        else if (slot == 2)
            weap = W_OldWeaponSlot2();
        else if (slot == 3)
            weap = W_OldWeaponSlot3();
        else if (slot == 4)
            weap = W_OldWeaponSlot4();
        else if (slot == 5)
            weap = W_OldWeaponSlot5();
        else if (slot == 6)
            weap = W_OldWeaponSlot6();
        else if (slot == 7)
            weap = W_OldWeaponSlot7();
        if (weap != 0)
            TeamFortress_ReloadWeapon(weap);
    }
};

void () TeamFortress_ReloadNext = {
    local float slot, reload = 0, weap = 0;

    if (!IsUsingOldImpulses()) {
        // reload current slot first
        slot = W_GetSlot(self.current_weapon);
        if (CheckForAmmo(self.current_weapon)) {
            TeamFortress_ReloadWeapon(self.current_weapon);
            reload = 1;
            return;
        }

        // then go through each slot
        for (slot = 1; slot < 4; slot++) {
            if (slot == 1)
                weap = W_WeaponSlot1();
            else if (slot == 2)
                weap = W_WeaponSlot2();
            else if (slot == 3) {
                if (self.playerclass == PC_SCOUT || self.playerclass == PC_ENGINEER)
                    break;
                weap = W_WeaponSlot3();
            }

            if (CheckForAmmo(weap)) {
                self.current_weapon = weap;
                TeamFortress_ReloadWeapon(weap);
                reload = 1;
                break;
            }
        }
    }
    else {
        slot = W_OldGetSlot(self.current_weapon);
        if (CheckForAmmo(self.current_weapon)) {
            TeamFortress_ReloadWeapon(self.current_weapon);
            reload = 1;
            return;
        }
        // then go through each slot
        for (slot = 1; slot < GetLastWeaponImpulse(); slot++) {
            if (slot == 1)
                weap = W_OldWeaponSlot1();
            else if (slot == 2)
                weap = W_OldWeaponSlot2();
            else if (slot == 3)
                weap = W_OldWeaponSlot3();
            else if (slot == 4)
                weap = W_OldWeaponSlot4();
            else if (slot == 5)
                weap = W_OldWeaponSlot5();
            else if (slot == 6)
                weap = W_OldWeaponSlot6();
            else if (slot == 7)
                weap = W_OldWeaponSlot7();

            if (CheckForAmmo(weap)) {
                self.current_weapon = weap;
                TeamFortress_ReloadWeapon(weap);
                reload = 1;
                break;
            }
        }
    }

    if (!reload)
        sprint(self, PRINT_HIGH, "All clips full\n");
};

void () TeamFortress_ClipTick = {
    if (time < self.owner.reload_time) {
        self.owner.reload_clipsize = self.owner.reload_clipsize + 1;
        Status_Refresh(self.owner);
        self.nextthink = time + self.owner.reload_tick;
    } else {
        dremove(self);
    }
};

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
	setsize(ps, '0 0 0', '0 0 0');
	setorigin(ps, e.origin + '0 0 8');
	FO_SetModel(ps, "progs/s_light.spr");
	sprint(e, PRINT_HIGH, "your practice spawn has been placed @ ", vtos(e.origin),".\n");
	spawn_tfog(ps.origin);
		
	
};


