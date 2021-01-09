void (entity Goal, entity Player, entity Item) DisplayItemStatus;
void () TeamFortress_CheckClassStats;
void (entity Player, float Armorclass) TeamFortress_DescribeArmor;
void () TeamFortress_AmmoboxTouch;

void () TeamFortress_ExplodePerson;
void () CF_Medic_Regenerate;
void () TeamFortress_CheckforCheats;
void () TeamFortress_RegenerateCells;
void (entity pe_player, float f_type) CF_Identify;

float () CloseToSpawnPoint;

void () AutoId = {

    // read autoid settings every 5 seconds
    if (time > self.owner.autoid_time) {
        self.owner.autoid_type = stof(infokey(self.owner, "ai"));
        self.owner.autoid_time = time + 5;
    }

    // try autoid again in 5 seconds if currently turned off
    if (!self.owner.autoid_type) {
        self.nextthink = time + 5;
        return;
    }

    if (time > self.ident_time || !self.ident_time) {

        // remove ident string from memory
        if (self.ident_string != string_null) {
            strunzone(self.ident_string);
            self.ident_string = string_null;
        }

        CF_Identify(self.owner, self.owner.autoid_type);
    }

    self.nextthink = time + 0.03;
};

void () UseSpecialSkill = {
    local vector src;

    self.impulse = 0;
    switch (self.playerclass)
    {
        case PC_SCOUT:
            self.impulse = TF_DASH;
            break;
        case PC_SNIPER:
            self.impulse = TF_ZOOMTOGGLE;
            break;
        case PC_DEMOMAN:
            self.impulse = TF_PB_DETONATE;
            break;
        case PC_MEDIC:
            self.impulse = TF_MEDIC_AURA_TOGGLE;
            break;
        case PC_HVYWEAP:
            if (self.tfstate & TFSTATE_LOCK)
                self.tfstate = self.tfstate - (self.tfstate & TFSTATE_LOCK);
            else
                self.tfstate = self.tfstate | TFSTATE_LOCK;
            Status_Refresh(self);
            self.impulse = 0;
            return;
        case PC_PYRO:
            if (pyro_type == PYRO_FO)
                UseAirBlast();
            break;
        case PC_SPY:
            self.impulse = TF_SPY_DIE;
            break;
        case PC_ENGINEER:
            self.impulse = TF_ENGINEER_DETDISP;
            break;
        case PC_UNDEFINED:
            if (self.enemy == world) {
                src = self.origin + v_forward * 10;
                src_z = self.absmin_z + self.size_z * 0.7;
                traceline(src, src + v_forward * 2048, 0, self);
                if ((trace_ent != world) && (trace_ent.origin != world.origin)) {
                    sprint3(self, PRINT_HIGH, "Locked onto ",
                            trace_ent.classname, "\n");
                    self.enemy = trace_ent;
                    self.camdist = vlen(self.enemy.origin - self.origin);
                    self.camangle = self.origin - self.enemy.origin;
                    self.camangle_z = 0 - self.camangle_z;
                    self.camangle = vectoangles(self.camangle);
                }
            } else {
                sprint(self, PRINT_HIGH, "Removed lock\n");
                self.enemy = world;
            }
            break;
    }
};

void () RemoveAutoIdTimer = {
    local entity te = find(world, classname, "aitimer");
    while (te != world) {
        if (te.owner == self)
            dremove(te);
        te = find(te, classname, "aitimer");
    }
};

void () RemoveGrenadeTimers = {
    local entity te = find(world, classname, "gtimer");
    while (te != world) {
        if (te.owner == self)
            dremove(te);
        te = find(te, classname, "gtimer");
    }
};

void () RemovePrimeTimers = {
    if (!drop_grenades) {
        local entity te = find(world, classname, "primetimer");
        while (te != world) {
            if (te.owner == self)
                dremove(te);
            te = find(te, classname, "primetimer");
        }
    }
};

void () RemoveGasTimers = {
    local entity te;

    te = find(world, classname, "gastimer");
    while (te != world) {
        if (te.owner == self)
            dremove(te);
        te = find(te, classname, "gastimer");
    }
};

void () RemoveGrenades = {
    local entity te = find(world, classname, "grenade");
    while (te) {
        if (te.owner == self)
            dremove(te);
        te = find(te, classname, "grenade");
    }
};

void (float inp) TeamFortress_ChangeClass = {
    local entity spot;
    local entity te;

    if ((intermission_running != 0) || (intermission_exittime > time))
        return;

    override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
    if (self.playerclass != 0) {
        if ((deathmatch != 3) && (!cb_prematch))
            return;

        if (self.playerclass == inp && !(self.tfstate & TFSTATE_RANDOMPC) && self.nextpc == inp) {
            sprint(self, PRINT_HIGH, "You are already playing as a ");
            TeamFortress_PrintClassName(self, inp, 0);
            return;
        } else if (inp == 10 && (self.tfstate & TFSTATE_RANDOMPC)) {
            sprint(self, PRINT_HIGH, "You are already playing as random player class\n");
            return;
        }

        
        if(inp > 0) {
            if (TeamFortress_TeamIsCivilian(self.team_no) && self.playerclass == PC_CIVILIAN) {
                sprint(self, PRINT_HIGH, "You cannot change class\n");
                return;
            }
            if (!IsLegalClass(inp) && !override_mapclasses) {
                sprint(self, PRINT_HIGH,
                       "Your team cannot play that class\n");
                TeamFortress_DisplayLegalClasses();
                return;
            }
            if ((spy_off == 1) && (inp == 8)) {
                sprint(self, PRINT_HIGH,
                       "The spy class has been disabled on the server by the administrator\n");
                return;
            }
            if (self.playerclass != inp && CF_ClassIsRestricted(self.team_no, inp)) {
                sprint(self, PRINT_HIGH,
                       "Your team already has enough of that class\n");
                return;
            }
        }

        self.nextpc = inp;
        if (self.health == self.max_health && (self.spawn_time + 10) > time && CloseToSpawnPoint()) {
            self.has_changedclass = 1;
            self.clientkillforce = 0;
            self.clientkillfree = 1;
            self.spawn_at_last_spawn_spot = 1;
            ClientKill();
            self.has_changedclass = 0;
            self.suicide_time = time;
        } else {
            sprint(self, PRINT_HIGH, "After dying, you will return as a ");
            TeamFortress_PrintClassName(self, self.nextpc, 0);
        }
        self.immune_to_check = time + 10;
        return;
    }
    if (teamplay && (self.team_no == 0)) {
        if (toggleflags & TFLAG_AUTOTEAM) {
            if (TeamFortress_TeamPutPlayerInTeam() == 0)
                return;
        } else {
            sprint(self, PRINT_HIGH, "You must join a team first\n");
            return;
        }
    }
    if (self.lives == 0) {
        sprint(self, PRINT_HIGH, "You have no lives left\n");
        return;
    }
    if (!IsLegalClass(inp) && !override_mapclasses && (inp != 11)) {
        sprint(self, PRINT_HIGH,
               "You cannot play that class on this map\n");
        TeamFortress_DisplayLegalClasses();
        return;
    }
    if ((spy_off == 1) && (inp == 8)) {
        sprint(self, PRINT_HIGH,
               "The spy class has been disabled on the server by the administrator\n");
        return;
    }
    if (CF_ClassIsRestricted(self.team_no, inp)) {
        sprint(self, PRINT_HIGH, "Your team has enough of that class\n");
        return;
    }
    TeamFortress_ExecClassScript(self);

    // FIXME - should this be using putclientinserver instead?
    self.playerclass = inp;

    //self.nextpc = 0;
    self.nextpc = inp;
    self.takedamage = 2;
    self.movetype = 3;
    self.flags = FL_CLIENT | FL_ONGROUND;
    self.waterlevel = 0;
    self.air_finished = time + 12;
    self.solid = 3;
    self.pausetime = 0;
    spot = SelectSpawnPoint();
    self.origin = spot.origin + '0 0 1';
    self.angles = spot.angles;
    self.fixangle = 1;

    setmodel(self, string_null);
    modelindex_null = self.modelindex;
    setmodel(self, "progs/eyes.mdl");
    modelindex_eyes = self.modelindex;
    FO_SetModel(self, "progs/player.mdl");
    modelindex_player = self.modelindex;
    setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
    self.view_ofs = '0 0 22';
    player_stand1();
    if (deathmatch || coop) {
        makevectors(self.angles);
        spawn_tfog(self.origin + v_forward * 20);
    }
    if (self.playerclass == PC_RANDOM) {
        sprint(self, PRINT_HIGH, "Random playerclass\n");
        self.tfstate = self.tfstate | TFSTATE_RANDOMPC;
        self.playerclass = 1 + floor(random() * 9);
    }
    if ((spot.classname == "info_player_teamspawn") &&
        (!cb_prematch)) {
        if (spot.items != 0) {
            te = Finditem(spot.items);
            if (te)
                tfgoalitem_GiveToPlayer(te, self, self);
            if (!(spot.goal_activation & TFSP_MULTIPLEITEMS))
                spot.items = 0;
        }
        if (spot.message) {
            CenterPrint(self, spot.message);
            if (!(spot.goal_activation & TFSP_MULTIPLEMSGS))
                spot.message = string_null;
        }
        if (spot.activate_goal_no != 0) {
            te = Findgoal(spot.activate_goal_no);
            if (te)
                AttemptToActivate(te, self, spot);
        }
        if (spot.goal_effects == 1) {
            spot.classname = "deadpoint";
            spot.team_str_home = string_null;
            spot.nextthink = time + 1;
            spot.think = SUB_Remove;
        }
    }
    spot = find(world, classname, "player");
    while (spot) {
        if ((spot.team_no == self.team_no) && (spot != self)) {
            sprint(spot, PRINT_HIGH, self.netname, " is playing as a ");
            TeamFortress_PrintClassName(spot, self.playerclass,
                                        self.tfstate & 8);
        }
        spot = find(spot, classname, "player");
    }
    TeamFortress_PrintClassName(self, self.playerclass,
                                (self.tfstate & 8));
    TeamFortress_SetEquipment();
    TeamFortress_SetHealth();
    TeamFortress_SetSpeed(self);
    TeamFortress_SetSkin(self);
    TeamFortress_ExecClassScript(self);
    W_ChangeWeapon(W_BestWeaponSlot());
    if (cease_fire) {
        sprint(self, PRINT_HIGH, "\n\nCease fire mode\n");
        self.immune_to_check = time + 10;
        self.tfstate = self.tfstate | TFSTATE_CANT_MOVE;
        TeamFortress_SetSpeed(self);
    }
    self.spawn_time = time;
};

void () TeamFortress_DisplayLegalClasses = {
    local float gotone;
    local float ill;

    override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
    sprint(self, PRINT_HIGH, "Legal classes for your team are:\n");
    gotone = 0;
    if(override_mapclasses) {
        ill = -1; //Nothing is illegal unless restricted on server
    } else {
        ill = TeamFortress_TeamGetIllegalClasses(self.team_no);
    }
    if (!(illegalclasses & 1) && !(ill & 1)) {
        if (gotone) {
            sprint(self, PRINT_HIGH, ", ");
        }
        gotone = 1;
        sprint(self, PRINT_HIGH, "Scout");
    }
    if (!(illegalclasses & 2) && !(ill & 2)) {
        if (gotone) {
            sprint(self, PRINT_HIGH, ", ");
        }
        gotone = 1;
        sprint(self, PRINT_HIGH, "Sniper");
    }
    if (!(illegalclasses & 4) && !(ill & 4)) {
        if (gotone) {
            sprint(self, PRINT_HIGH, ", ");
        }
        gotone = 1;
        sprint(self, PRINT_HIGH, "Soldier");
    }
    if (!(illegalclasses & 8) && !(ill & 8)) {
        if (gotone) {
            sprint(self, PRINT_HIGH, ", ");
        }
        gotone = 1;
        sprint(self, PRINT_HIGH, "Demolitions Man");
    }
    if (!(illegalclasses & 16) && !(ill & 16)) {
        if (gotone) {
            sprint(self, PRINT_HIGH, ", ");
        }
        gotone = 1;
        sprint(self, PRINT_HIGH, "Combat Medic");
    }
    if (!(illegalclasses & 32) && !(ill & 32)) {
        if (gotone) {
            sprint(self, PRINT_HIGH, ", ");
        }
        gotone = 1;
        sprint(self, PRINT_HIGH, "Heavy Weapons Guy");
    }
    if (!(illegalclasses & 64) && !(ill & 64)) {
        if (gotone) {
            sprint(self, PRINT_HIGH, ", ");
        }
        gotone = 1;
        sprint(self, PRINT_HIGH, "Pyro");
    }
    if (!(illegalclasses & 256) && !(ill & 256)) {
        if (gotone) {
            sprint(self, PRINT_HIGH, ", ");
        }
        gotone = 1;
        sprint(self, PRINT_HIGH, "Spy");
    }
    if (!(illegalclasses & 512) && !(ill & 512)) {
        if (gotone) {
            sprint(self, PRINT_HIGH, ", ");
        }
        gotone = 1;
        sprint(self, PRINT_HIGH, "Engineer");
    }
    if (!(illegalclasses & 128) && !(ill & 128)) {
        if (gotone) {
            sprint(self, PRINT_HIGH, ", ");
        }
        gotone = 1;
        sprint(self, PRINT_HIGH, "RandomPC");
    }
    sprint(self, PRINT_HIGH, "\n");
};

string GetGrenName(float type)
{
    string s = "";
    switch (type)
    {
        case GR_TYPE_NORMAL:
            s = "normal grenade";
            break;
        case GR_TYPE_NAIL:
            s = (nailgren_type == NGR_TYPE_LASER) ? "shock grenade" : "nail grenade";
            break;
        case GR_TYPE_MIRV:
            s = "mirv grenade";
            break;
        case GR_TYPE_NAPALM:
            s = "napalm grenade";
            break;
        case GR_TYPE_FLARE:
            s = "flare";
            break;
        case GR_TYPE_GAS:
            s = "hallucinogenic grenade";
            break;
        case GR_TYPE_EMP:
            s = "EMP grenade";
            break;
        case GR_TYPE_CALTROP:
            s = "caltrop canister";
            break;
        case GR_TYPE_FLASH:
            s = "flash grenade";
            break;
        case GR_TYPE_CONCUSSION:
            s = "concussion grenade";
            break;
        case GR_TYPE_NONE:
            s = "no grenade";
            break;
    }

    return s;
}

void () TeamFortress_Inventory = {
    local entity en;
    local string st;
    local float fl;

    st = TeamFortress_TeamGetColorString(self.team_no);
    sprint(self, PRINT_HIGH, st, " team\n");

    if (self.playerclass == PC_SPY) {
        if (self.undercover_team || self.undercover_skin) {
            sprint(self, PRINT_HIGH, "Disguised as ");
            if (self.undercover_team != 0)
                st = TeamFortress_TeamGetColorString(self.undercover_team);
            sprint(self, PRINT_HIGH, st);
            if (self.undercover_skin != 0)
                st = TeamFortress_GetClassName(self.undercover_skin);
            else
                st = "Spy";
            sprint(self, PRINT_HIGH, " ", st, "\n");
        }
    }

    fl = self.no_grenades_1;
    if (fl > 0) {
        string g1 = strcat(ftos(fl), " ", GetGrenName(self.tp_grenades_1));
        if (fl > 1)
            g1 = strcat(g1, "s");

        g1 = strcat(g1, "\n");
        sprint(self, PRINT_HIGH, g1);
    }

    fl = self.no_grenades_2;
    if (fl > 0) {
        string g2 = strcat(ftos(fl), " ", GetGrenName(self.tp_grenades_2));
        if (fl > 1)
            g2 = strcat(g2, "s");

        g2 = strcat(g2, "\n");
        sprint(self, PRINT_HIGH, g2);
    }

    if (self.tf_items & NIT_SCANNER)
        sprint(self, PRINT_HIGH, "Scanner\n");

    if (self.weapons_carried & WEAP_MEDIKIT)
        sprint(self, PRINT_HIGH, "Medikit\n");

    if (self.weapons_carried & WEAP_DETPACK) {
        if (self.ammo_detpack > 0) {
            st = ftos(self.ammo_detpack);
            sprint(self, PRINT_HIGH, st, " detpack");
            if (self.ammo_detpack > 1)
                sprint(self, PRINT_HIGH, "s");
            sprint(self, PRINT_HIGH, "\n");
        }
    }

    if (self.playerclass == PC_SPY && invis_only) {
        sprint(self, PRINT_HIGH, "Invisibility device\n");
    }

    if (self.armorvalue > 0)
        TeamFortress_DescribeArmor(self, self.armorclass);

    en = find(world, classname, "item_tfgoal");
    while (en) {
        if (en.owner == self) {
            sprint(self, PRINT_HIGH, en.netname, "\n");
        }
        en = find(en, classname, "item_tfgoal");
    }
};

void (string ps_description, float pf_setting, string ps_last, float pf_bool) CF_PrintSetting = {
    local string st;

    st = strpadr(ps_description, 40);

    if (!pf_bool) {
        st = strcat(st, ftos(pf_setting));
    } else if (pf_setting) {
        st = strcat(st, "on");
    } else {
        st = strcat(st, "off");
    }

    if (strlen(ps_last) > 0) {
        st = strcat(st, " ");
        st = strcat(st, ps_last);
    }

    st = strcat(st, "\n");

    sprint(self, PRINT_HIGH, st);
};

void () TeamFortress_ShowTF = {
    local string st;

    sprint(self, PRINT_HIGH, "\nThis server is running FortressOne ");
    sprint(self, PRINT_HIGH, VER);
    sprint(self, PRINT_HIGH, "\n\n");

    sprint(self, PRINT_HIGH, "== Team Fortress ==\n");
    if (autokick_kills) {
        sprint(self, PRINT_HIGH, "Kick teamkillers                        ");
        sprint(self, PRINT_HIGH, ftos(autokick_kills));
        sprint(self, PRINT_HIGH, " kills / ");
        sprint(self, PRINT_HIGH, ftos(autokick_time));
        sprint(self, PRINT_HIGH, " secs\n");
    } else {
        sprint(self, PRINT_HIGH, "Kick teamkillers                        off\n");
    }

    if (toggleflags & TFLAG_CLASS_PERSIST) {
        sprint(self, PRINT_HIGH, "Class persistence                       on\n");
    } else {
        sprint(self, PRINT_HIGH, "Class persistence                       off\n");
    }

    if (toggleflags & TFLAG_CHEATCHECK) {
        sprint(self, PRINT_HIGH, "Cheat checking                          on\n");
    } else {
        sprint(self, PRINT_HIGH, "Cheat checking                          off\n");
    }

    if (toggleflags & TFLAG_AUTOTEAM) {
        sprint(self, PRINT_HIGH, "Autoteam                                on\n");
    } else {
        sprint(self, PRINT_HIGH, "Autoteam                                off\n");
    }

    sprint(self, PRINT_HIGH, "Respawn delay                           ");
    if (toggleflags & TFLAG_RESPAWNDELAY) {
        st = ftos(Role_None.respawn_delay_time);
    } else {
        st = "off";
    }
    sprint(self, PRINT_HIGH, st);
    if (st != "off") {
        sprint(self, PRINT_HIGH, " seconds");
    }
    sprint(self, PRINT_HIGH, "\n");

    if (toggleflags & TFLAG_TEAMFRAGS) {
        sprint(self, PRINT_HIGH, "Teamfrags                               on\n");
    } else {
        sprint(self, PRINT_HIGH, "Teamfrags                               off\n");
    }

    if (toggleflags & TFLAG_FULLTEAMSCORE) {
        sprint(self, PRINT_HIGH, "Full teamscore                          on\n");
    } else {
        sprint(self, PRINT_HIGH, "Full teamscore                          off\n");
    }

    sprint(self, PRINT_HIGH, "\n== FortressOne Server ==\n");
    CF_PrintSetting("Spawn with full health/armor", spawnfull, "", 1);
    CF_PrintSetting("Stock players with full health/armor", stockfull, "", 1);
    CF_PrintSetting("Stock player on cap", stock_on_cap, "", 1);
    CF_PrintSetting("Stock reloadable clip", stock_reload, "", 1);
    CF_PrintSetting("Old dropflag behaviour", old_dropflag, "", 1);
    CF_PrintSetting("Remember weapon", remember_weapon, "", 1);
    CF_PrintSetting("Pick up discarded ammo", discammo_pickup, "", 1);
    CF_PrintSetting("Reload clip tick", reload_cliptick, "", 1);
    CF_PrintSetting("ID extras", id_extended, "", 1);
    CF_PrintSetting("Display class tips", classtips, "", 1);
    CF_PrintSetting("Old grenades", old_grens, "", 1);
    CF_PrintSetting("Drop grenades on ground", drop_grenades, "", 1);
    CF_PrintSetting("Drop grenades in pack", drop_grenpack, "", 1);
    if (drop_grenpack) {
        CF_PrintSetting("- Grenades type 1", drop_gren1, "", 0);
        CF_PrintSetting("- Grenades type 2", drop_gren2, "", 0);
    }
    CF_PrintSetting("Grenade timers", grentimers, "", 1);

    CF_PrintSetting("Scout max grenades type 1 (caltrops)", Role_None.gren1_limits[1], "", PC_SCOUT_GRENADE_MAX_1);
    CF_PrintSetting("Sniper max grenades type 1 (normal)", Role_None.gren1_limits[2], "", PC_SNIPER_GRENADE_MAX_1);
    CF_PrintSetting("Soldier max grenades type 1 (normal)", Role_None.gren1_limits[3], "", PC_SOLDIER_GRENADE_MAX_1);
    CF_PrintSetting("Demoman max grenades type 1 (normal)", Role_None.gren1_limits[4], "", PC_DEMOMAN_GRENADE_MAX_1);
    CF_PrintSetting("Medic max grenades type 1 (normal)", Role_None.gren1_limits[5], "", PC_MEDIC_GRENADE_MAX_1);
    CF_PrintSetting("Heavy Weapons max grenades type 1 (normal)", Role_None.gren1_limits[6], "", PC_HVYWEAP_GRENADE_MAX_1);
    CF_PrintSetting("Pyro max grenades type 1 (normal)", Role_None.gren1_limits[7], "", PC_PYRO_GRENADE_MAX_1);
    CF_PrintSetting("Spy max grenades type 1 (normal)", Role_None.gren1_limits[8], "", PC_SPY_GRENADE_MAX_1);
    CF_PrintSetting("Engineer max grenades type 1 (normal)", Role_None.gren1_limits[9], "", PC_ENGINEER_GRENADE_MAX_1);

    CF_PrintSetting("Scout max grenades type 2 (concussion)", Role_None.gren2_limits[1], "", PC_SCOUT_GRENADE_MAX_2);
    CF_PrintSetting("Sniper max grenades type 2 (flare)", Role_None.gren2_limits[2], "", PC_SNIPER_GRENADE_MAX_2);
    CF_PrintSetting("Soldier max grenades type 2 (nail/shock)", Role_None.gren2_limits[3], "", PC_SOLDIER_GRENADE_MAX_2);
    CF_PrintSetting("Demoman max grenades type 2 (mirv)", Role_None.gren2_limits[4], "", PC_DEMOMAN_GRENADE_MAX_2);
    CF_PrintSetting("Medic max grenades type 2 (concussion)", Role_None.gren2_limits[5], "", PC_MEDIC_GRENADE_MAX_2);
    CF_PrintSetting("Heavy Weapons max grenades type 2 (mirv)", Role_None.gren2_limits[6], "", PC_HVYWEAP_GRENADE_MAX_2);
    CF_PrintSetting("Pyro max grenades type 2 (napalm)", Role_None.gren2_limits[7], "", PC_PYRO_GRENADE_MAX_2);
    CF_PrintSetting("Spy max grenades type 2 (gas)", Role_None.gren2_limits[8], "", PC_SPY_GRENADE_MAX_2);
    CF_PrintSetting("Engineer max grenades type 2 (emp)", Role_None.gren2_limits[9], "", PC_ENGINEER_GRENADE_MAX_2);
    
    sprint(self, PRINT_HIGH, "Concussion effect lasts ");
    sprint(self, PRINT_HIGH, ftos(cussgrentime));
    sprint(self, PRINT_HIGH, " seconds");

    sprint(self, PRINT_HIGH, "\n== Scout ==\n");
    CF_PrintSetting("Scout dash ability", scoutdash, "", 1);

    sprint(self, PRINT_HIGH, "\n== Sniper ==\n");
    CF_PrintSetting("Sniper reload", sniperreload, "", 1);
    CF_PrintSetting("Old sniper rifle range", old_sniperrange, "", 1);
    CF_PrintSetting("Sniper Rifle power in status bar", sniperpower, "", 1);
    CF_PrintSetting("Reload percentage in status bar", sniperreloadpercent, "", 1);

    sprint(self, PRINT_HIGH, "\n== Medic ==\n");
    CF_PrintSetting("Medic immune to concussion grenade", medicnocuss, "", 1);

    sprint(self, PRINT_HIGH, "\n== Demolitions Man ==\n");
    if (Role_None.detpipe_limit > 0) {
        CF_PrintSetting("Pipebomb limit (per demoman)", Role_None.detpipe_limit, "", 0);
    } else if (Role_None.detpipe_limit == 0) {
        sprint(self, PRINT_HIGH, "Pipebomb limit (per demoman):           0 (disallow)\n");
    } else {
        sprint(self, PRINT_HIGH, "Pipebomb limit (per demoman):           unlimited\n");
    }
    if (detpipe_limit_world > 0) {
        CF_PrintSetting("Pipebomb limit (team)", detpipe_limit_world, "", 0);
    } else if (detpipe_limit_world == 0) {
        sprint(self, PRINT_HIGH, "Pipebomb limit (team):                  0 (disallow)\n");
    } else {
        sprint(self, PRINT_HIGH, "Pipebomb limit (team):                  unlimited\n");
    }
    CF_PrintSetting("Old pipebomb cooldown", old_pipecooldown, "", 1);

    sprint(self, PRINT_HIGH, "\n== Combat Medic ==\n");
    CF_PrintSetting("Medic aura ability", medicaura, "", 1);
    CF_PrintSetting("Old medikit behaviour", old_medikit, "", 1);
    CF_PrintSetting("Old bioweapon damage", old_sniperrange, "", 1);

    sprint(self, PRINT_HIGH, "\n== Heavy Weapons Guy ==\n");
    CF_PrintSetting("Assault Cannon lock ability", cannon_lock, "", 1);
    CF_PrintSetting("Allow Assault Cannon in air", cannon_air, "", 1);
    if (!cannon_movespin) {
        CF_PrintSetting("Allow Assault Cannon while moving", cannon_move, "", 1);
    }
    CF_PrintSetting("Spin Assault Cannon while moving", cannon_movespin, "", 1);
    CF_PrintSetting("Allow Assault Cannon concussion", cannon_conc, "", 1);
    if (cannon_movespin == 0) {
        sprint(self, PRINT_HIGH, "Assault Cannon accuracy:                CF style\n");
    } else if (cannon_movespin == 1) {
        sprint(self, PRINT_HIGH, "Assault Cannon accuracy:                TF 2.8 style\n");
    } else {
        sprint(self, PRINT_HIGH, "Assault Cannon accuracy:                TF 2.9 style\n");
    }

    sprint(self, PRINT_HIGH, "\n== Pyro ==\n");
    CF_PrintSetting("Flamethrower knockback", flame_knockback, "", 1);

    sprint(self, PRINT_HIGH, "\n== Engineer ==\n");
    CF_PrintSetting("Old spanner behaviour", old_spanner, "", 1);
    CF_PrintSetting("Old dispenser behaviour", old_dispenser, "", 1);
    CF_PrintSetting("Build status in status bar", buildstatus, "", 1);

    sprint(self, PRINT_HIGH, "\n== Spy ==\n");
    CF_PrintSetting("Allow feign death while airborne", feign_air, "", 1);
    CF_PrintSetting("Drop feign backpack", feign_pack, "", 1);
    CF_PrintSetting("Print feign death message", feign_msg, "", 1);
    CF_PrintSetting("Override Map Class Limits", override_mapclasses, "", 0);
    CF_PrintSetting("Solid Detpack", solid_detpack, "", 0);
    CF_PrintSetting("EMP Blocked By Walls", walls_block_emp, "", 0);

    if (server_faithful) {
        sprint(self, PRINT_HIGH, "\nThis server is running faithful Team Fortress settings.\n");
    } else if (server_default) {
        sprint(self, PRINT_HIGH, "\nThis server is running default FortressOne Server settings.\n");
    }
    else if (server_huetf) {
        sprint(self, PRINT_HIGH, "\nThis server is running HueTF FortressOne Server settings.\n");
    }
};

void () TeamFortress_GrenadePrimed;

void () GrenadeTimer = {
    self.heat = self.heat - 1;
    self.nextthink = time + 1;
    self.owner.StatusGrenTime = self.heat;
    Status_Refresh(self.owner);

    if (!self.heat) {
        dremove(self);
    }
};

void (float inp) TeamFortress_PrimeThrowGrenade = {
    if ((self.tfstate & TFSTATE_GRENPRIMED) ||
        (self.tfstate & TFSTATE_GRENTHROWING))
        TeamFortress_ThrowGrenade();
    else {
        TeamFortress_PrimeGrenade(inp);

    if ( ((inp == 1 && self.tp_grenade_switch != 1) || (inp == 2 && self.tp_grenade_switch == 1))
                && self.tp_grenades_1 == GR_TYPE_CALTROP)
        TeamFortress_ThrowGrenade();
    }
};

void (float inp) TeamFortress_PrimeGrenade = {
    local float gtype;
    local string gs;
    local string ptime;
    local entity tGrenade;
    local entity timer;
    gtype = 0;

    if ((self.tfstate & TFSTATE_GRENPRIMED) ||
        (self.tfstate & TFSTATE_GRENTHROWING))
        return;
    
    if (no_fire_mode)
        return;

    if (    (inp == 1 && self.tp_grenade_switch != 1)
         || (inp == 2 && self.tp_grenade_switch == 1)) {
        gtype = self.tp_grenades_1;

        if (self.tp_grenades_1 == 2)
            gs = "Concussion grenade";
        else if (self.tp_grenades_1 == 3) {
            if (nailgren_type == NGR_TYPE_LASER) {
                gs = "Shock grenade";
            } else {
                gs = "Nail grenade";
            }
        } else if (self.tp_grenades_1 == 4)
            gs = "Mirv grenade";
        else if (self.tp_grenades_1 == 5)
            gs = "Napalm grenade";
        else if (self.tp_grenades_1 == 6)
            gs = "Flare";
        else if (self.tp_grenades_1 == 7)
            gs = "Gas grenade";
        else if (self.tp_grenades_1 == 8)
            gs = "EMP grenade";
        else if (self.tp_grenades_1 == 9)
            gs = "Flash grenade";
        else if (self.tp_grenades_1 == 10)
            gs = "Caltrop canister";
        else
            gs = "Grenade";

        if (self.no_grenades_1 > 0) {
            self.has_throwngren = TRUE;
            self.no_grenades_1 = self.no_grenades_1 - 1;
            if (gtype == GR_TYPE_FLARE) {
                newmis = spawn();
                newmis.owner = self;
                newmis.movetype = 6;
                newmis.solid = 2;
                newmis.classname = "grenade";
                makevectors(self.v_angle);
                newmis.velocity = (v_forward * 600) + (v_up * 25);
                newmis.velocity = newmis.velocity * 700;
                newmis.angles = vectoangles(newmis.velocity);
                newmis.weapon = self.team_no;
                newmis.think = FlareGrenadeExplode;
                newmis.nextthink = time + 0.8;
                newmis.touch = FlareGrenadeTouch;
                newmis.skin = 1;
                newmis.mdl = "flare";
                FO_SetModel(newmis, "progs/flare.mdl");
                setsize(newmis, '0 0 0', '0 0 0');
                setorigin(newmis, self.origin);
                return;
            }
            if (gtype == GR_TYPE_CALTROP) {
                ptime = ftos(0.5);
                sprint(self, PRINT_HIGH, "Opening ", gs, "...\n");
            } else {
                ptime = ftos(3);
                sprint(self, PRINT_HIGH, gs, " primed, ", ptime,
                       " seconds...\n");
            }
        } else {
            sprint(self, PRINT_HIGH, "No ", gs, "s left\n");
            return;
        }
    }
    if (    (inp == 2 && self.tp_grenade_switch != 1)
         || (inp == 1 && self.tp_grenade_switch == 1)) {
        gtype = self.tp_grenades_2;

        if (self.tp_grenades_2 == 2)
            gs = "Concussion grenade";
        else if (self.tp_grenades_2 == 3) {
            if (nailgren_type == NGR_TYPE_LASER) {
                gs = "Shock grenade";
            } else {
                gs = "Nail grenade";
            }
        } else if (self.tp_grenades_2 == 4)
            gs = "Mirv grenade";
        else if (self.tp_grenades_2 == 5)
            gs = "Napalm grenade";
        else if (self.tp_grenades_2 == 6)
            gs = "Flare";
        else if (self.tp_grenades_2 == 7)
            gs = "Gas grenade";
        else if (self.tp_grenades_2 == 8)
            gs = "EMP grenade";
        else if (self.tp_grenades_2 == 9)
            gs = "Flash grenade";
        else
            gs = "Grenade";

        if (self.no_grenades_2 > 0) {
            self.has_throwngren = TRUE;
            self.no_grenades_2 = self.no_grenades_2 - 1;
            if (gtype == GR_TYPE_FLARE) {
                newmis = spawn();
                newmis.owner = self;
                newmis.movetype = 6;
                newmis.solid = 2;
                newmis.classname = "grenade";
                makevectors(self.v_angle);
                if (self.v_angle_x) {
                    newmis.velocity = v_forward * 1200 + v_up * 200;
                } else {
                    newmis.velocity = aim(self, 10000);
                    newmis.velocity = newmis.velocity * 1200;
                    newmis.velocity_z = 75;
                }
                newmis.angles = vectoangles(newmis.velocity);
                newmis.weapon = self.team_no;
                newmis.think = FlareGrenadeExplode;
                newmis.nextthink = time + 0.8;
                newmis.touch = FlareGrenadeTouch;
                newmis.skin = 1;
                newmis.mdl = "flare";
                FO_SetModel(newmis, "progs/flare.mdl");
                setsize(newmis, '0 0 0', '0 0 0');
                setorigin(newmis, self.origin);
                return;
            }
            if (gtype == GR_TYPE_CALTROP) {
                ptime = ftos(0.5);
                sprint(self, PRINT_HIGH, "Opening ", gs, "...\n");
            } else {
                ptime = ftos(3);
                sprint(self, PRINT_HIGH, gs, " primed, ", ptime,
                       " seconds...\n");
            }
        } else {
            sprint(self, PRINT_HIGH, "No ", gs, "s left\n");
            return;
        }
    }
    self.tfstate = self.tfstate | 1;
    tGrenade = spawn();
    tGrenade.owner = self;
    tGrenade.weapon = gtype;
    tGrenade.classname = "primetimer";
    if (inp == 1)
        tGrenade.impulse = TF_GRENADE_1;
    else if (inp == 2)
        tGrenade.impulse = TF_GRENADE_2;
    tGrenade.nextthink = time + 0.8;

    if (gtype == GR_TYPE_CALTROP)
        tGrenade.heat = time + 0.5 + 0.5;
    else {
        tGrenade.heat = time + 3 + 0.8;

        RemoveGrenadeTimers();

        local float csqcactive = infokeyf(self, INFOKEY_P_CSQCACTIVE);
        local float notimers = stof(infokey(self, "nt"));
        if (grentimers && notimers != 1) {
            timer = spawn();
            timer.nextthink = time + 0.8;
            timer.think = GrenadeTimer;
            timer.heat = 4;
            timer.owner = self;
            timer.classname = "gtimer";
            if (!notimers && !csqcactive) {
                stuffcmd(self, "play grentimer\n");
            }
        }
        if (grentimers && csqcactive) {
            UpdateClientGrenadePrimed(self, gtype);
        }
    }

    tGrenade.think = TeamFortress_GrenadePrimed;
};

void () TeamFortress_GrenadePrimed = {
    local entity user;

    user = self.owner;
    if (!(user.tfstate & TFSTATE_GRENTHROWING) && !user.deadflag && !user.has_disconnected) {
        self.nextthink = time + 0.1;
        if (!self.think)
            dremove(self);

        if (time > self.heat && self.weapon != GR_TYPE_CALTROP)
            TeamFortress_ExplodePerson();

        return;
    }
    if (!(user.tfstate & TFSTATE_GRENPRIMED))
        dprint("GrenadePrimed logic error\n");

    user.tfstate = user.tfstate - (user.tfstate & TFSTATE_GRENPRIMED);
    user.tfstate = user.tfstate - (user.tfstate & TFSTATE_GRENTHROWING);
    if (grentimers && infokeyf(user, INFOKEY_P_CSQCACTIVE)) {
        UpdateClientGrenadeThrown(user);
    }

    FO_Sound(user, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
    KickPlayer(-1, user);
    newmis = spawn();
    newmis.owner = user;
    newmis.movetype = 10;
    newmis.solid = 2;
    newmis.classname = "grenade";
    makevectors(user.v_angle);
    if (user.deadflag) {
        if (self.weapon == GR_TYPE_NORMAL)
            newmis.velocity = '0 0 200';
        else
            return;
    } else if (user.v_angle_x) {
        newmis.velocity =
            v_forward * 600 + v_up * 200 + crandom() * v_right * 10 +
            crandom() * v_up * 10;
    } else {
        newmis.velocity = aim(user, 10000);
        newmis.velocity = newmis.velocity * 600;
        newmis.velocity_z = 200;
    }
    newmis.angles = vectoangles(newmis.velocity);
    newmis.think = SUB_Null;
    newmis.nextthink = self.heat;
    if (self.weapon == GR_TYPE_NORMAL) {
        newmis.touch = NormalGrenadeTouch;
        newmis.think = NormalGrenadeExplode;
        newmis.grenadename = "normalgrenade";
        newmis.skin = 0;
        newmis.avelocity = '300 300 300';
        FO_SetModel(newmis, "progs/hgren2.mdl");
    } else if (self.weapon == GR_TYPE_CONCUSSION) {
        newmis.touch = ConcussionGrenadeTouch;
        newmis.think = ConcussionGrenadeExplode;
        newmis.grenadename = "concussiongrenade";
        newmis.skin = 1;
        newmis.avelocity = '300 300 300';
        FO_SetModel(newmis, "progs/hgren2.mdl");
    } else if (self.weapon == GR_TYPE_NAIL) {
        newmis.touch = NailGrenadeTouch;
        newmis.think = NailGrenadeExplode;
        if (nailgren_type == NGR_TYPE_LASER)
            newmis.grenadename = "shockgrenade";
        else
            newmis.grenadename = "nailgrenade";            
        newmis.skin = 1;
        newmis.avelocity = '0 300 0';
        FO_SetModel(newmis, "progs/biggren.mdl");
    } else if (self.weapon == GR_TYPE_MIRV) {
        newmis.touch = MirvGrenadeTouch;
        newmis.think = MirvGrenadeExplode;
        newmis.grenadename = "mirvgrenade";
        newmis.skin = 0;
        newmis.avelocity = '0 300 0';
        FO_SetModel(newmis, "progs/biggren.mdl");
    } else if (self.weapon == GR_TYPE_NAPALM) {
        newmis.touch = NapalmGrenadeTouch;
        newmis.think = NapalmGrenadeExplode;
        newmis.grenadename = "napalmgrenade";
        newmis.skin = 2;
        newmis.avelocity = '0 300 0';
        FO_SetModel(newmis, "progs/biggren.mdl");
    } else if (self.weapon == GR_TYPE_FLARE) {
        newmis.touch = FlareGrenadeTouch;
        newmis.weapon = self.team_no;
        newmis.think = FlareGrenadeExplode;
        newmis.grenadename = "flaregrenade";
        newmis.skin = 1;
        newmis.avelocity = '300 300 300';
        newmis.mdl = "flare";
        FO_SetModel(newmis, "progs/flare.mdl");
    } else if (self.weapon == GR_TYPE_GAS) {
        newmis.touch = GasGrenadeTouch;
        newmis.think = GasGrenadeExplode;
        newmis.grenadename = "gasgrenade";
        newmis.skin = 3;
        newmis.avelocity = '300 300 300';
        FO_SetModel(newmis, "progs/grenade2.mdl");
    } else if (self.weapon == GR_TYPE_EMP) {
        newmis.touch = EMPGrenadeTouch;
        newmis.think = EMPGrenadeExplode;
        newmis.grenadename = "empgrenade";
        newmis.skin = 4;
        newmis.avelocity = '300 300 300';
        FO_SetModel(newmis, "progs/grenade2.mdl");
    } else if (self.weapon == GR_TYPE_CALTROP) {
        newmis.touch = CanisterTouch;
        newmis.think = ScatterCaltrops;
        newmis.grenadename = "caltropgrenade";
        newmis.skin = 0;
        newmis.avelocity = '0 0 0';
    } else if (self.weapon == GR_TYPE_FLASH) {
        newmis.touch = FlashGrenadeTouch;
        newmis.think = FlashGrenadeExplode;
        newmis.grenadename = "flashgrenade";
        newmis.skin = 0;
        newmis.avelocity = '300 300 300';
        FO_SetModel(newmis, "progs/flashgren.mdl");
    }
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, user.origin);
    dremove(self);
};

void () TeamFortress_ThrowGrenade = {
    if (!(self.tfstate & TFSTATE_GRENPRIMED))
        return;

    self.tfstate = self.tfstate | TFSTATE_GRENTHROWING;
};

void () TeamFortress_GrenadeSwitch = {
    local string gs;

    if (self.tp_grenade_switch == 1) {
        self.tp_grenade_switch = 0;
        if (self.tp_grenades_1 == 2)
            gs = "Concussion grenade";
        else if (self.tp_grenades_1 == 3) {
            if (nailgren_type == NGR_TYPE_LASER) {
                gs = "Shock grenade";
            } else {
                gs = "Nail grenade";
            }
        } else if (self.tp_grenades_1 == 4)
            gs = "Mirv grenade";
        else if (self.tp_grenades_1 == 5)
            gs = "Napalm grenade";
        else if (self.tp_grenades_1 == 6)
            gs = "Flare";
        else if (self.tp_grenades_1 == 7)
            gs = "Gas grenade";
        else if (self.tp_grenades_1 == 8)
            gs = "EMP grenade";
        else
            gs = "Grenade";
    } else {
        self.tp_grenade_switch = 1;
        if (self.tp_grenades_2 == 2)
            gs = "Concussion grenade";
        else if (self.tp_grenades_2 == 3) {
            if (nailgren_type == NGR_TYPE_LASER) {
                gs = "Shock grenade";
            } else {
                gs = "Nail grenade";
            }
        } else if (self.tp_grenades_2 == 4)
            gs = "Mirv grenade";
        else if (self.tp_grenades_2 == 5)
            gs = "Napalm grenade";
        else if (self.tp_grenades_2 == 6)
            gs = "Flare";
        else if (self.tp_grenades_2 == 7)
            gs = "Gas grenade";
        else if (self.tp_grenades_2 == 8)
            gs = "EMP grenade";
        else if (self.tp_grenades_2 == 9)
            gs = "Flash grenade";
        else if (self.tp_grenades_2 == 10)
            gs = "Caltrop canister";
        else
            gs = "Grenade";
    }
    if (gs == "Caltrop canister" || gs == "Flare")
        sprint(self, PRINT_HIGH, gs, " is now the primary throwable item\n");
    else
        sprint(self, PRINT_HIGH, gs, " is now the primary grenade\n");
};

float (float pc) IsLegalClass = {
    local float bit;
    bit = 0;

    if ((spy_off == TRUE) && (pc == PC_SPY))
        return (FALSE);

    if (pc == PC_SCOUT)
        bit = TF_ILL_SCOUT;
    else if (pc == PC_SNIPER)
        bit = TF_ILL_SNIPER;
    else if (pc == PC_SOLDIER)
        bit = TF_ILL_SOLDIER;
    else if (pc == PC_DEMOMAN)
        bit = TF_ILL_DEMOMAN;
    else if (pc == PC_MEDIC)
        bit = TF_ILL_MEDIC;
    else if (pc == PC_HVYWEAP)
        bit = TF_ILL_HVYWEP;
    else if (pc == PC_PYRO)
        bit = TF_ILL_PYRO;
    else if (pc == PC_SPY)
        bit = TF_ILL_SPY;
    else if (pc == PC_ENGINEER)
        bit = TF_ILL_ENGINEER;
    else if (pc == PC_RANDOM)
        bit = TF_ILL_RANDOMPC;

    override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
    if ((illegalclasses & bit) ||
        (TeamFortress_TeamGetIllegalClasses(self.team_no) & bit && !override_mapclasses))
        return (FALSE);

    return (TRUE);
};

void (entity p) TeamFortress_SetSpeed = {
    local string sp;
    local float tf;
    local entity te;

    stuffcmd(p, "cl_movespeedkey 1\n");
    if (p.tfstate & TFSTATE_CANT_MOVE || (p.is_building == 1 && !engineer_move) || p.is_detpacking > 0) {
#ifdef STOP_MOUSE_MOVEMENT
        stuffcmd(p, "m_forward 0\n");
        stuffcmd(p, "m_side 0\n");
#endif
        p.velocity = '0 0 0';
        stuffcmd(p, "cl_backspeed 0\n");
        stuffcmd(p, "cl_forwardspeed 0\n");
        stuffcmd(p, "cl_sidespeed 0\n");
        p.maxspeed = 0;
        return;
    }
#ifdef STOP_MOUSE_MOVEMENT
    else {
        stuffcmd(p, "m_forward 1\n");
        stuffcmd(p, "m_side 0.8\n");
    }
#endif
    if (p.playerclass == PC_SCOUT) {
        p.maxfbspeed = PC_SCOUT_MAXSPEED;
        p.maxstrafespeed = PC_SCOUT_MAXSTRAFESPEED;
    } else if (p.playerclass == PC_SNIPER) {
        p.maxfbspeed = PC_SNIPER_MAXSPEED;
        p.maxstrafespeed = PC_SNIPER_MAXSTRAFESPEED;
    } else if (p.playerclass == PC_SOLDIER) {
        p.maxfbspeed = PC_SOLDIER_MAXSPEED;
        p.maxstrafespeed = PC_SOLDIER_MAXSTRAFESPEED;
    } else if (p.playerclass == PC_DEMOMAN) {
        p.maxfbspeed = PC_DEMOMAN_MAXSPEED;
        p.maxstrafespeed = PC_DEMOMAN_MAXSTRAFESPEED;
    } else if (p.playerclass == PC_MEDIC) {
        p.maxfbspeed = PC_MEDIC_MAXSPEED;
        p.maxstrafespeed = PC_MEDIC_MAXSTRAFESPEED;
    } else if (p.playerclass == PC_HVYWEAP) {
        p.maxfbspeed = PC_HVYWEAP_MAXSPEED;
        p.maxstrafespeed = PC_HVYWEAP_MAXSTRAFESPEED;
    } else if (p.playerclass == PC_PYRO) {
        p.maxfbspeed = PC_PYRO_MAXSPEED;
        p.maxstrafespeed = PC_PYRO_MAXSTRAFESPEED;
    } else if (p.playerclass == PC_CIVILIAN || votemode) {
        p.maxfbspeed = PC_CIVILIAN_MAXSPEED;
        p.maxstrafespeed = PC_CIVILIAN_MAXSTRAFESPEED;
    } else if (p.playerclass == PC_SPY) {
        p.maxfbspeed = PC_SPY_MAXSPEED;
        p.maxstrafespeed = PC_SPY_MAXSTRAFESPEED;
    } else if (p.playerclass == PC_ENGINEER) {
        p.maxfbspeed = PC_ENGINEER_MAXSPEED;
        p.maxstrafespeed = PC_ENGINEER_MAXSTRAFESPEED;
    } else if (p.playerclass == PC_UNDEFINED) {
//      p.maxfbspeed = 320;
//      p.maxstrafespeed = 320;
        p.maxfbspeed = 0;
        p.maxstrafespeed = 0;
        p.maxspeed = 0;
        return;
    }
    tf = 0;
    te = find(world, classname, "item_tfgoal");
    while ((te != world) && (tf == 0)) {
        if (te.owner == p) {
            if (te.goal_activation & TFGI_SLOW) {
                tf = 1;
                p.maxfbspeed = p.maxfbspeed / 2;
                p.maxstrafespeed = p.maxstrafespeed / 2;
            }
        }
        te = find(te, classname, "item_tfgoal");
    }
    if (p.tfstate & TFSTATE_TRANQUILISED) {
        p.maxfbspeed = p.maxfbspeed / 2;
        p.maxstrafespeed = p.maxstrafespeed / 2;
    }
    if (p.leg_damage) {
        if (p.leg_damage > 6) {
            p.leg_damage = 6;
        }
        p.maxfbspeed = p.maxfbspeed * (10 - p.leg_damage) / 10;
        p.maxstrafespeed = p.maxstrafespeed * (10 - p.leg_damage) / 10;
    }
    if (p.tfstate & TFSTATE_AIMING) {
        if (p.maxfbspeed > 80) {
            p.maxfbspeed = 80;
        }
        if (p.maxstrafespeed > 80) {
            p.maxstrafespeed = 80;
        }
    }
    sp = ftos(p.maxfbspeed);
    stuffcmd(p, "cl_backspeed ");
    stuffcmd(p, sp);
    stuffcmd(p, "\n");
    stuffcmd(p, "cl_forwardspeed ");
    stuffcmd(p, sp);
    stuffcmd(p, "\n");
    sp = ftos(p.maxstrafespeed);
    stuffcmd(p, "cl_sidespeed ");
    stuffcmd(p, sp);
    stuffcmd(p, "\n");
    p.maxspeed = p.maxfbspeed;
};

void () TeamFortress_SetHealth = {
    if (self.playerclass == PC_SCOUT) {
        if (old_hp_armor)
            self.max_health = 75;
        else
            self.max_health = PC_SCOUT_MAXHEALTH;
    } else if (self.playerclass == PC_SNIPER) {
        if (old_hp_armor)
            self.max_health = 90;
        else
            self.max_health = PC_SNIPER_MAXHEALTH;
    } else if (self.playerclass == PC_SOLDIER) {
        if (old_hp_armor)
            self.max_health = 100;
        else
            self.max_health = PC_SOLDIER_MAXHEALTH;
    } else if (self.playerclass == PC_DEMOMAN) {
        if (old_hp_armor)
            self.max_health = 90;
        else
            self.max_health = PC_DEMOMAN_MAXHEALTH;
    } else if (self.playerclass == PC_MEDIC) {
        if (old_hp_armor)
            self.max_health = 90;
        else
            self.max_health = PC_MEDIC_MAXHEALTH;
    } else if (self.playerclass == PC_HVYWEAP) {
        if (old_hp_armor)
            self.max_health = 100;
        else
            self.max_health = PC_HVYWEAP_MAXHEALTH;
    } else if (self.playerclass == PC_PYRO) {
        if (old_hp_armor)
            self.max_health = 100;
        else
            self.max_health = PC_PYRO_MAXHEALTH;
    } else if (self.playerclass == PC_CIVILIAN) {
        if (old_hp_armor)
            self.max_health = 50;
        else
            self.max_health = PC_CIVILIAN_MAXHEALTH;
    } else if (self.playerclass == PC_SPY) {
        if (old_hp_armor)
            self.max_health = 90;
        else
            self.max_health = PC_SPY_MAXHEALTH;
    } else if (self.playerclass == PC_ENGINEER) {
        if (old_hp_armor)
            self.max_health = 80;
        else
            self.max_health = PC_ENGINEER_MAXHEALTH;
    } else {
        self.max_health = 1;
        self.takedamage = DAMAGE_NO;
    }
    self.health = self.max_health;
};

string (float tn) TeamFortress_GetColorSkin = {
    string s;
    s = "";
    switch (tn)
    {
        case 1:
            s = "blue";
            break;
        case 2:
            s = "red";
            break;
        case 3:
            s = "yell";
            break;
        case 4:
            s = "gren";
            break;
    }

    return s;
}

string(float tn, float pc) TeamFortress_GetSkin =
{
    local string skin = "base";

    string col;
    col = TeamFortress_GetColorSkin(tn);

    switch (pc)
    {
        case 1:
            skin = strcat(col, "_sco");
            break;
        case 2:
            skin = strcat(col, "_sni");
            break;
        case 3:
            skin = strcat(col, "_sol");
            break;
        case 4:
            skin = strcat(col, "_dem");
            break;
        case 5:
            skin = strcat(col, "_med");
            break;
        case 6:
            skin = strcat(col, "_hwg");
            break;
        case 7:
            skin = strcat(col, "_pyr");
            break;
        case 8:
            skin = strcat(col, "_spy");
            break;
        case 9:
            skin = strcat(col, "_eng");
            break;
        case 11:
            skin = strcat(col, "_civ");
            break;

    }
    return skin;
};

void (entity p) TeamFortress_SetSkin = {
    local string st;

    p.immune_to_check = time + 10;
    
    if (p.playerclass == PC_SPY || p.last_playerclass == PC_SPY)
    {
        if (!p.is_undercover)
        {
            stuffcmd(p, "skin ");
            st = TeamFortress_GetSkin(p.team_no, p.playerclass);
            stuffcmd(p, st);
            stuffcmd(p, "\n");
            // please fix mvd recording
            forceinfokey(p, "skin", st);
        }
        Spy_SetClientSkins(p);
    }
    else
    {
        p.skin = p.playerclass;
    
        if (p.skin != 0) {
            stuffcmd(p, "skin ");
            st = TeamFortress_GetSkin(p.team_no, p.playerclass);
            stuffcmd(p, st);
            stuffcmd(p, "\n");

            // please fix mvd recording
            forceinfokey(p, "skin", st);
        } 
        else
        {
            stuffcmd(p, "skin base\n");
        }
    }
};

void () TeamFortress_SetEquipment = {
    local entity te;
    local string st;
    local float kept_items;

    if (self.classname != "player")
        return;

    Team_Role * role = GetTeamRole(self.team_no);
    
    kept_items = self.tf_items & (IT_KEY1 | IT_KEY2);

    self.items = 0;
    self.weapons_carried = 0;
    if (!remember_weapon || self.last_playerclass != self.playerclass || (self.tfstate & TFSTATE_RANDOMPC)) {
        self.current_weapon = 0;
        self.last_weapon = 0;
        self.weaponmode = 0;
        self.last_weaponmode = 0;
        self.current_weaponslot = W_BestWeaponSlot();
        self.last_weaponslot = 2;
        W_WeaponState_Save(self);
    }

    self.tf_items = 0;
    if (self.playerclass != PC_SCOUT) {
        self.tf_items_flags = 0;
        self.ScannerOn = 0;
    }

    self.armorclass = 0;
    self.impulse = 0;

    self.undercover_skin = 0;
    if (self.undercover_team != 0) {
        self.immune_to_check = time + 10;
        self.undercover_team = 0;
        stuffcmd(self, "color ");
        st = ftos(TeamFortress_TeamGetColor(self.team_no) - 1);
        stuffcmd(self, st);
        stuffcmd(self, "\n");
    }
    self.is_building = 0;
    self.is_detpacking = 0;
    self.is_undercover = 0;
    self.is_feigning = 0;
    self.is_unabletospy = 0;
    self.is_concussed = 0;
    self.disguise_skin = 0;
    self.disguise_team = 0;
    self.detpack_left = 0;
    self.fragstreak = 0;
    self.menu_time = 0;
    self.nopickup = world;

    self.ammo_medikit = 0;
    self.maxammo_medikit = 0;
    self.ammo_detpack = 0;
    self.maxammo_detpack = 0;
    self.items_allowed = 0;
    self.armor_allowed = 0;
    self.maxarmor = 0;
    self.respawn_time = 0;
    self.heat = 0;
    self.tfstate = self.tfstate - (self.tfstate & TFSTATE_RELOADING);

    if (self.team_no == 0)
        self.lives = -1;

    self.items = self.items | kept_items;

    if (self.playerclass == PC_SCOUT) {
        self.weapons_carried = self.weapons_carried | PC_SCOUT_WEAPONS;

        if (spawnfull) {
            self.ammo_rockets = PC_SCOUT_MAXAMMO_ROCKET;
            self.ammo_nails = PC_SCOUT_MAXAMMO_NAIL;
            self.ammo_shells = PC_SCOUT_MAXAMMO_SHOT;
            self.ammo_cells = PC_SCOUT_MAXAMMO_CELL;
            self.armortype = PC_SCOUT_MAXARMORTYPE;
            self.no_grenades_1 = role.gren1_limits[1];
            self.no_grenades_2 = role.gren2_limits[1];
            if (old_hp_armor)
                self.armorvalue = 50;
            else
                self.armorvalue = PC_SCOUT_MAXARMOR;
        } else {
            self.ammo_rockets = PC_SCOUT_INITAMMO_ROCKET;
            self.ammo_nails = PC_SCOUT_INITAMMO_NAIL;
            self.ammo_shells = PC_SCOUT_INITAMMO_SHOT;
            self.ammo_cells = PC_SCOUT_INITAMMO_CELL;
            self.armortype = PC_SCOUT_INITARMORTYPE;
            self.no_grenades_1 = min(PC_SCOUT_GRENADE_INIT_1,role.gren1_limits[1]);
            self.no_grenades_2 = min(PC_SCOUT_GRENADE_INIT_2,role.gren2_limits[1]);

            if (old_hp_armor)
                self.armorvalue = 25;
            else
                self.armorvalue = PC_SCOUT_INITARMOR;
        }

        // dispenser needs
        self.need_shells = 1;
        self.need_nails = 1;
        self.need_rockets = 0;
        self.need_cells = 0;

        self.maxammo_rockets = PC_SCOUT_MAXAMMO_ROCKET;
        self.maxammo_nails = PC_SCOUT_MAXAMMO_NAIL;
        self.maxammo_shells = PC_SCOUT_MAXAMMO_SHOT;
        self.maxammo_cells = PC_SCOUT_MAXAMMO_CELL;
        self.max_grenades_1 = role.gren1_limits[1];
        self.max_grenades_2 = role.gren2_limits[1];

        if (old_grens == 1 || fo_flash == TRUE)
            self.tp_grenades_1 = GR_TYPE_FLASH;
        else
            self.tp_grenades_1 = GR_TYPE_CALTROP;

        self.tp_grenades_2 = GR_TYPE_CONCUSSION;

        self.tf_items = PC_SCOUT_TF_ITEMS;

        if (self.tf_items_flags <= 0)
            self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_ENEMY;

        self.armorclass = self.armorclass | 0;
        self.armor_allowed = PC_SCOUT_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 50;
        else
            self.maxarmor = PC_SCOUT_MAXARMOR;
        if (self.last_playerclass != self.playerclass)  
            self.current_weapon = WEAP_NAILGUN;

        self.items_allowed = PC_SCOUT_WEAPONS;

        self.items = self.items | IT_SHOTGUN | IT_NAILGUN;
    } else if (self.playerclass == PC_SNIPER) {
        self.weapons_carried = self.weapons_carried | PC_SNIPER_WEAPONS;

        if (spawnfull) {
            self.ammo_rockets = PC_SNIPER_MAXAMMO_ROCKET;
            self.ammo_nails = PC_SNIPER_MAXAMMO_NAIL;
            self.ammo_shells = PC_SNIPER_MAXAMMO_SHOT;
            self.ammo_cells = PC_SNIPER_MAXAMMO_CELL;
            self.armortype = PC_SNIPER_MAXARMORTYPE;
            self.no_grenades_1 = role.gren1_limits[2];
            self.no_grenades_2 = role.gren2_limits[2];
            if (old_hp_armor)
                self.armorvalue = 50;
            else
                self.armorvalue = PC_SNIPER_MAXARMOR;
        } else {
            self.ammo_rockets = PC_SNIPER_INITAMMO_ROCKET;
            self.ammo_nails = PC_SNIPER_INITAMMO_NAIL;
            self.ammo_shells = PC_SNIPER_INITAMMO_SHOT;
            self.ammo_cells = PC_SNIPER_INITAMMO_CELL;
            self.armortype = PC_SNIPER_INITARMORTYPE;
            self.no_grenades_1 = min(PC_SNIPER_GRENADE_INIT_1,role.gren1_limits[2]);
            self.no_grenades_2 = min(PC_SNIPER_GRENADE_INIT_2,role.gren2_limits[2]);
            if (old_hp_armor)
                self.armorvalue = 0;
            else
                self.armorvalue = PC_SNIPER_INITARMOR;
        }

        // dispenser needs
        self.need_shells = 1;
        self.need_nails = 1;
        self.need_rockets = 0;
        self.need_cells = 0;

        self.maxammo_rockets = PC_SNIPER_MAXAMMO_ROCKET;
        self.maxammo_nails = PC_SNIPER_MAXAMMO_NAIL;
        self.maxammo_shells = PC_SNIPER_MAXAMMO_SHOT;
        self.maxammo_cells = PC_SNIPER_MAXAMMO_CELL;
        self.max_grenades_1 = role.gren1_limits[2];
        self.max_grenades_2 = role.gren2_limits[2];
        
        self.tp_grenades_1 = PC_SNIPER_GRENADE_TYPE_1;
        self.tp_grenades_2 = PC_SNIPER_GRENADE_TYPE_2;
        self.tf_items = PC_SNIPER_TF_ITEMS;

        self.armorclass = self.armorclass | PC_SNIPER_INITARMORCLASS;
        self.armor_allowed = PC_SNIPER_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 50;
        else
            self.maxarmor = PC_SNIPER_MAXARMOR;
        if (self.last_playerclass != self.playerclass)
            self.current_weapon = WEAP_SNIPER_RIFLE;

        self.items_allowed = PC_SNIPER_WEAPONS;
        self.items =
            self.items | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN;
    } else if (self.playerclass == PC_SOLDIER) {
        self.weapons_carried = self.weapons_carried | PC_SOLDIER_WEAPONS;

        if (spawnfull) {
            self.ammo_rockets = PC_SOLDIER_MAXAMMO_ROCKET;
            self.ammo_nails = PC_SOLDIER_MAXAMMO_NAIL;
            self.ammo_shells = PC_SOLDIER_MAXAMMO_SHOT;
            self.ammo_cells = PC_SOLDIER_MAXAMMO_CELL;
            self.armortype = PC_SOLDIER_MAXARMORTYPE;
            self.no_grenades_1 = role.gren1_limits[3];
            self.no_grenades_2 = role.gren2_limits[3];
            if (old_hp_armor)
                self.armorvalue = 200;
            else
                self.armorvalue = PC_SOLDIER_MAXARMOR;
        } else {
            self.ammo_rockets = PC_SOLDIER_INITAMMO_ROCKET;
            self.ammo_nails = PC_SOLDIER_INITAMMO_NAIL;
            self.ammo_shells = PC_SOLDIER_INITAMMO_SHOT;
            self.ammo_cells = PC_SOLDIER_INITAMMO_CELL;
            self.armortype = PC_SOLDIER_INITARMORTYPE;
            self.no_grenades_1 = min(PC_SOLDIER_GRENADE_INIT_1,role.gren1_limits[3]);
            self.no_grenades_2 = min(PC_SOLDIER_GRENADE_INIT_2,role.gren2_limits[3]);
            if (old_hp_armor)
                self.armorvalue = 100;
            else
                self.armorvalue = PC_SOLDIER_INITARMOR;
        }

        // dispenser needs
        self.need_shells = 1;
        self.need_nails = 0;
        self.need_rockets = 1;
        self.need_cells = 0;

        self.maxammo_rockets = PC_SOLDIER_MAXAMMO_ROCKET;
        self.maxammo_nails = PC_SOLDIER_MAXAMMO_NAIL;
        self.maxammo_shells = PC_SOLDIER_MAXAMMO_SHOT;
        self.maxammo_cells = PC_SOLDIER_MAXAMMO_CELL;
        self.max_grenades_1 = role.gren1_limits[3];
        self.max_grenades_2 = role.gren2_limits[3];

        self.tp_grenades_1 = PC_SOLDIER_GRENADE_TYPE_1;
        self.tp_grenades_2 = PC_SOLDIER_GRENADE_TYPE_2;
        self.tf_items = PC_SOLDIER_TF_ITEMS;

        self.armorclass = self.armorclass | PC_SOLDIER_INITARMORCLASS;
        self.armor_allowed = PC_SOLDIER_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 200;
        else
            self.maxarmor = PC_SOLDIER_MAXARMOR;
        if (self.last_playerclass != self.playerclass)
            self.current_weapon = WEAP_ROCKET_LAUNCHER;

        self.items_allowed = PC_SOLDIER_WEAPONS;
        self.items =
            self.
            items | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_ROCKET_LAUNCHER;
    } else if (self.playerclass == PC_DEMOMAN) {
        self.weapons_carried = self.weapons_carried | PC_DEMOMAN_WEAPONS;

        if (spawnfull) {
            self.ammo_rockets = PC_DEMOMAN_MAXAMMO_ROCKET;
            self.ammo_nails = PC_DEMOMAN_MAXAMMO_NAIL;
            self.ammo_shells = PC_DEMOMAN_MAXAMMO_SHOT;
            self.ammo_cells = PC_DEMOMAN_MAXAMMO_CELL;
            self.armortype = PC_DEMOMAN_MAXARMORTYPE;
            self.no_grenades_1 = role.gren1_limits[4];
            self.no_grenades_2 = role.gren2_limits[4];
            if (old_hp_armor)
                self.armorvalue = 120;
            else
                self.armorvalue = PC_DEMOMAN_MAXARMOR;
        } else {
            self.ammo_rockets = PC_DEMOMAN_INITAMMO_ROCKET;
            self.ammo_nails = PC_DEMOMAN_INITAMMO_NAIL;
            self.ammo_shells = PC_DEMOMAN_INITAMMO_SHOT;
            self.ammo_cells = PC_DEMOMAN_INITAMMO_CELL;
            self.armortype = PC_DEMOMAN_INITARMORTYPE;
            self.no_grenades_1 = min(PC_DEMOMAN_GRENADE_INIT_1,role.gren1_limits[4]);
            self.no_grenades_2 = min(PC_DEMOMAN_GRENADE_INIT_2,role.gren2_limits[4]);
            if (old_hp_armor)
                self.armorvalue = 50;
            else
                self.armorvalue = PC_DEMOMAN_INITARMOR;
        }

        // dispenser needs
        self.need_shells = 1;
        self.need_nails = 0;
        self.need_rockets = 1;
        self.need_cells = 0;

        self.maxammo_rockets = PC_DEMOMAN_MAXAMMO_ROCKET;
        self.maxammo_nails = PC_DEMOMAN_MAXAMMO_NAIL;
        self.maxammo_shells = PC_DEMOMAN_MAXAMMO_SHOT;
        self.maxammo_cells = PC_DEMOMAN_MAXAMMO_CELL;
        self.max_grenades_1 = role.gren1_limits[4];
        self.max_grenades_2 = role.gren2_limits[4];

        self.tp_grenades_1 = PC_DEMOMAN_GRENADE_TYPE_1;
        self.tp_grenades_2 = PC_DEMOMAN_GRENADE_TYPE_2;
        self.tf_items = PC_DEMOMAN_TF_ITEMS;

        self.ammo_detpack = PC_DEMOMAN_INITAMMO_DETPACK;
        self.maxammo_detpack = PC_DEMOMAN_MAXAMMO_DETPACK;

        self.armorclass = self.armorclass | PC_DEMOMAN_INITARMORCLASS;
        self.armor_allowed = PC_DEMOMAN_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 120;
        else
            self.maxarmor = PC_DEMOMAN_MAXARMOR;
        if (self.last_playerclass != self.playerclass)
            self.current_weapon = WEAP_GRENADE_LAUNCHER;

        self.items_allowed = PC_DEMOMAN_WEAPONS;
        self.items = self.items | IT_SHOTGUN | IT_GRENADE_LAUNCHER;
    } else if (self.playerclass == PC_MEDIC) {
        self.weapons_carried = self.weapons_carried | PC_MEDIC_WEAPONS;

        if (spawnfull) {
            self.ammo_rockets = PC_MEDIC_MAXAMMO_ROCKET;
            self.ammo_nails = PC_MEDIC_MAXAMMO_NAIL;
            self.ammo_shells = PC_MEDIC_MAXAMMO_SHOT;
            self.ammo_cells = PC_MEDIC_MAXAMMO_CELL;
            self.armortype = PC_MEDIC_MAXARMORTYPE;
            self.no_grenades_1 = role.gren1_limits[5];
            self.no_grenades_2 = role.gren2_limits[5];
            if (old_hp_armor)
                self.armorvalue = 100;
            else
                self.armorvalue = PC_MEDIC_MAXARMOR;
        } else {
            self.ammo_rockets = PC_MEDIC_INITAMMO_ROCKET;
            self.ammo_nails = PC_MEDIC_INITAMMO_NAIL;
            self.ammo_shells = PC_MEDIC_INITAMMO_SHOT;
            self.ammo_cells = PC_MEDIC_INITAMMO_CELL;
            self.armortype = PC_MEDIC_INITARMORTYPE;
            self.no_grenades_1 = min(PC_MEDIC_GRENADE_INIT_1,role.gren1_limits[5]);
            self.no_grenades_2 = min(PC_MEDIC_GRENADE_INIT_2,role.gren2_limits[5]);
            if (old_hp_armor)
                self.armorvalue = 50;
            else
                self.armorvalue = PC_MEDIC_INITARMOR;
        }

        // dispenser needs
        self.need_shells = 1;
        self.need_nails = 1;
        self.need_rockets = 0;
        self.need_cells = 0;

        self.maxammo_rockets = PC_MEDIC_MAXAMMO_ROCKET;
        self.maxammo_nails = PC_MEDIC_MAXAMMO_NAIL;
        self.maxammo_shells = PC_MEDIC_MAXAMMO_SHOT;
        self.maxammo_cells = PC_MEDIC_MAXAMMO_CELL;
        self.max_grenades_1 = role.gren1_limits[5];
        self.max_grenades_2 = role.gren2_limits[5];

        self.tp_grenades_1 = PC_MEDIC_GRENADE_TYPE_1;
        self.tp_grenades_2 = PC_MEDIC_GRENADE_TYPE_2;
        self.tf_items = PC_MEDIC_TF_ITEMS;

        self.armorclass = self.armorclass | PC_MEDIC_INITARMORCLASS;
        self.armor_allowed = PC_MEDIC_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 100;
        else
            self.maxarmor = PC_MEDIC_MAXARMOR;
        if (self.last_playerclass != self.playerclass)
            self.current_weapon = WEAP_SUPER_NAILGUN;

        self.ammo_medikit = PC_MEDIC_INITAMMO_MEDIKIT;
        self.maxammo_medikit = PC_MEDIC_MAXAMMO_MEDIKIT;

        te = spawn();
        te.nextthink = time + PC_MEDIC_REGEN_TIME;
        te.think = CF_Medic_Regenerate;
        te.owner = self;
        te.classname = "timer";

        te = spawn();
        te.nextthink = time + PC_MEDIC_CELL_REGEN_TIME;
        te.think = CF_Medic_RegenerateCells;
        te.owner = self;
        te.classname = "timer";

        te = spawn();
        te.nextthink = time + PC_MEDIC_AURA_HEAL_TIME;
        te.think = CF_Medic_AuraFindPlayers;
        te.owner = self;
        te.classname = "timer";

        self.items_allowed = PC_MEDIC_WEAPONS;
        self.items =
            self.items | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_SUPER_NAILGUN;
    } else if (self.playerclass == PC_HVYWEAP) {
        self.weapons_carried = self.weapons_carried | PC_HVYWEAP_WEAPONS;

        if (spawnfull) {
            self.ammo_rockets = PC_HVYWEAP_MAXAMMO_ROCKET;
            self.ammo_nails = PC_HVYWEAP_MAXAMMO_NAIL;
            self.ammo_shells = PC_HVYWEAP_MAXAMMO_SHOT;
            self.ammo_cells = PC_HVYWEAP_MAXAMMO_CELL;
            self.armortype = PC_HVYWEAP_MAXARMORTYPE;
            self.no_grenades_1 = role.gren1_limits[6];
            self.no_grenades_2 = role.gren2_limits[6];

            if (old_hp_armor)
                self.armorvalue = 300;
            else
                self.armorvalue = PC_HVYWEAP_MAXARMOR;
        } else {
            self.ammo_rockets = PC_HVYWEAP_INITAMMO_ROCKET;
            self.ammo_nails = PC_HVYWEAP_INITAMMO_NAIL;
            self.ammo_shells = PC_HVYWEAP_INITAMMO_SHOT;
            self.ammo_cells = PC_HVYWEAP_INITAMMO_CELL;
            self.armortype = PC_HVYWEAP_INITARMORTYPE;
            self.no_grenades_1 = min(PC_HVYWEAP_GRENADE_INIT_1,role.gren1_limits[6]);
            self.no_grenades_2 = min(PC_HVYWEAP_GRENADE_INIT_2,role.gren2_limits[6]);

            if (old_hp_armor)
                self.armorvalue = 150;
            else
                self.armorvalue = PC_HVYWEAP_INITARMOR;
        }

        // dispenser needs
        self.need_shells = 1;
        self.need_nails = 0;
        self.need_rockets = 0;
        self.need_cells = 1;

        self.maxammo_rockets = PC_HVYWEAP_MAXAMMO_ROCKET;
        self.maxammo_nails = PC_HVYWEAP_MAXAMMO_NAIL;
        self.maxammo_shells = PC_HVYWEAP_MAXAMMO_SHOT;
        self.maxammo_cells = PC_HVYWEAP_MAXAMMO_CELL;
        self.max_grenades_1 = role.gren1_limits[6];
        self.max_grenades_2 = role.gren2_limits[6];

        self.tp_grenades_1 = PC_HVYWEAP_GRENADE_TYPE_1;
        self.tp_grenades_2 = PC_HVYWEAP_GRENADE_TYPE_2;
        self.tf_items = PC_HVYWEAP_TF_ITEMS;

        self.armorclass = self.armorclass | PC_HVYWEAP_INITARMORCLASS;
        self.armor_allowed = PC_HVYWEAP_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 300;
        else
            self.maxarmor = PC_HVYWEAP_MAXARMOR;
        if (self.last_playerclass != self.playerclass)
            self.current_weapon = WEAP_SUPER_SHOTGUN;

        self.items_allowed = PC_HVYWEAP_WEAPONS;
        self.items =
            self.
            items | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_ROCKET_LAUNCHER;
    } else if (self.playerclass == PC_PYRO) {
        self.weapons_carried = self.weapons_carried | PC_PYRO_WEAPONS;

        if (spawnfull) {
            self.ammo_rockets = PC_PYRO_MAXAMMO_ROCKET;
            self.ammo_nails = PC_PYRO_MAXAMMO_NAIL;
            self.ammo_shells = PC_PYRO_MAXAMMO_SHOT;
            self.ammo_cells = PC_PYRO_MAXAMMO_CELL;
            self.armortype = PC_PYRO_MAXARMORTYPE;
            self.no_grenades_1 = role.gren1_limits[7];
            self.no_grenades_2 = role.gren2_limits[7];
            if (old_hp_armor)
                self.armorvalue = 150;
            else
                self.armorvalue = PC_PYRO_MAXARMOR;
        } else {
            self.ammo_rockets = PC_PYRO_INITAMMO_ROCKET;
            self.ammo_nails = PC_PYRO_INITAMMO_NAIL;
            self.ammo_shells = PC_PYRO_INITAMMO_SHOT;
            self.ammo_cells = PC_PYRO_INITAMMO_CELL;
            self.armortype = PC_PYRO_INITARMORTYPE;
            self.no_grenades_1 = min(PC_PYRO_GRENADE_INIT_1,role.gren1_limits[7]);
            self.no_grenades_2 = min(PC_PYRO_GRENADE_INIT_2,role.gren2_limits[7]);
            if (old_hp_armor)
                self.armorvalue = 50;
            else
                self.armorvalue = PC_PYRO_INITARMOR;
        }

        // dispenser needs
        self.need_shells = 1;
        self.need_nails = 0;
        self.need_rockets = 1;
        self.need_cells = 1;

        self.maxammo_rockets = PC_PYRO_MAXAMMO_ROCKET;
        self.maxammo_nails = PC_PYRO_MAXAMMO_NAIL;
        self.maxammo_shells = PC_PYRO_MAXAMMO_SHOT;
        self.maxammo_cells = PC_PYRO_MAXAMMO_CELL;
        self.max_grenades_1 = role.gren1_limits[7];
        self.max_grenades_2 = role.gren2_limits[7];

        self.tp_grenades_1 = PC_PYRO_GRENADE_TYPE_1;
        self.tp_grenades_2 = PC_PYRO_GRENADE_TYPE_2;
        self.tf_items = PC_PYRO_TF_ITEMS;

        self.armorclass = self.armorclass | PC_PYRO_INITARMORCLASS;
        self.armor_allowed = PC_PYRO_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 150;
        else
            self.maxarmor = PC_PYRO_MAXARMOR;
        if (self.last_playerclass != self.playerclass)
            self.current_weapon = WEAP_FLAMETHROWER;

        self.items_allowed = PC_PYRO_WEAPONS;
        self.items =
            self.
            items | IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER;
    } else if (self.playerclass == PC_CIVILIAN) {
        self.weapons_carried = self.weapons_carried | PC_CIVILIAN_WEAPONS;

        if (spawnfull) {
            self.ammo_rockets = PC_CIVILIAN_MAXAMMO_ROCKET;
            self.ammo_nails = PC_CIVILIAN_MAXAMMO_NAIL;
            self.ammo_shells = PC_CIVILIAN_MAXAMMO_SHOT;
            self.ammo_cells = PC_CIVILIAN_MAXAMMO_CELL;
            self.armortype = PC_CIVILIAN_MAXARMORTYPE;
            self.no_grenades_1 = PC_CIVILIAN_GRENADE_MAX_1;
            self.no_grenades_2 = PC_CIVILIAN_GRENADE_MAX_2;
            if (old_hp_armor)
                self.armorvalue = 0;
            else
                self.armorvalue = PC_CIVILIAN_MAXARMOR;
        } else {
            self.ammo_rockets = PC_CIVILIAN_INITAMMO_ROCKET;
            self.ammo_nails = PC_CIVILIAN_INITAMMO_NAIL;
            self.ammo_shells = PC_CIVILIAN_INITAMMO_SHOT;
            self.ammo_cells = PC_CIVILIAN_INITAMMO_CELL;
            self.armortype = PC_CIVILIAN_INITARMORTYPE;
            self.no_grenades_1 = PC_CIVILIAN_GRENADE_INIT_1;
            self.no_grenades_2 = PC_CIVILIAN_GRENADE_INIT_2;
            if (old_hp_armor)
                self.armorvalue = 0;
            else
                self.armorvalue = PC_CIVILIAN_INITARMOR;
        }

        // dispenser needs
        self.need_shells = 0;
        self.need_nails = 0;
        self.need_rockets = 0;
        self.need_cells = 0;

        self.maxammo_rockets = PC_CIVILIAN_MAXAMMO_ROCKET;
        self.maxammo_nails = PC_CIVILIAN_MAXAMMO_NAIL;
        self.maxammo_shells = PC_CIVILIAN_MAXAMMO_SHOT;
        self.maxammo_cells = PC_CIVILIAN_MAXAMMO_CELL;
        self.max_grenades_1 = PC_CIVILIAN_GRENADE_MAX_1;
        self.max_grenades_2 = PC_CIVILIAN_GRENADE_MAX_2;

        self.tp_grenades_1 = PC_CIVILIAN_GRENADE_TYPE_1;
        self.tp_grenades_2 = PC_CIVILIAN_GRENADE_TYPE_2;
        self.tf_items = PC_CIVILIAN_TF_ITEMS;

        self.armorclass = self.armorclass | PC_CIVILIAN_INITARMORCLASS;
        self.armor_allowed = PC_CIVILIAN_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 0;
        else
            self.maxarmor = PC_CIVILIAN_MAXARMOR;
        if (self.last_playerclass != self.playerclass)
            self.current_weapon = WEAP_AXE;

        self.items_allowed = PC_CIVILIAN_WEAPONS;
        self.items = 0;
    } else if (self.playerclass == PC_SPY) {
        self.weapons_carried = self.weapons_carried | PC_SPY_WEAPONS;

        if (spawnfull) {
            self.ammo_rockets = PC_SPY_MAXAMMO_ROCKET;
            self.ammo_nails = PC_SPY_MAXAMMO_NAIL;
            self.ammo_shells = PC_SPY_MAXAMMO_SHOT;
            self.ammo_cells = PC_SPY_MAXAMMO_CELL;
            self.armortype = PC_SPY_MAXARMORTYPE;
            self.no_grenades_1 = role.gren1_limits[8];
            self.no_grenades_2 = role.gren2_limits[8];

            if (old_hp_armor)
                self.armorvalue = 100;
            else
                self.armorvalue = PC_SPY_MAXARMOR;
        } else {
            self.ammo_rockets = PC_SPY_INITAMMO_ROCKET;
            self.ammo_nails = PC_SPY_INITAMMO_NAIL;
            self.ammo_shells = PC_SPY_INITAMMO_SHOT;
            self.ammo_cells = PC_SPY_INITAMMO_CELL;
            self.armortype = PC_SPY_INITARMORTYPE;
            self.no_grenades_1 = min(PC_SPY_GRENADE_INIT_1,role.gren1_limits[8]);
            self.no_grenades_2 = min(PC_SPY_GRENADE_INIT_2,role.gren2_limits[8]);

            if (old_hp_armor)
                self.armorvalue = 25;
            else
                self.armorvalue = PC_SPY_INITARMOR;
        }

        // dispenser needs
        self.need_shells = 1;
        self.need_nails = 1;
        self.need_rockets = 0;
        self.need_cells = 0;

        self.maxammo_rockets = PC_SPY_MAXAMMO_ROCKET;
        self.maxammo_nails = PC_SPY_MAXAMMO_NAIL;
        self.maxammo_shells = PC_SPY_MAXAMMO_SHOT;
        self.maxammo_cells = PC_SPY_MAXAMMO_CELL;
        self.max_grenades_1 = role.gren1_limits[8];
        self.max_grenades_2 = role.gren2_limits[8];
        
        self.tp_grenades_1 = PC_SPY_GRENADE_TYPE_1;
        self.tp_grenades_2 = PC_SPY_GRENADE_TYPE_2;
        self.tf_items = PC_SPY_TF_ITEMS;

        self.armorclass = self.armorclass | PC_SPY_INITARMORCLASS;
        self.armor_allowed = PC_SPY_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 100;
        else
            self.maxarmor = PC_SPY_MAXARMOR;
        if (self.last_playerclass != self.playerclass)
            self.current_weapon = WEAP_TRANQ;

        self.items_allowed = PC_SPY_WEAPONS;
        self.items =
            self.items | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN;

        if (invis_only == 1) {
            te = spawn();
            te.nextthink = time + PC_SPY_CELL_REGEN_TIME;
            te.think = TeamFortress_RegenerateCells;
            te.owner = self;
            te.classname = "timer";
        }
    } else if (self.playerclass == PC_ENGINEER) {
        self.weapons_carried = self.weapons_carried | PC_ENGINEER_WEAPONS;

        if (spawnfull) {
            self.ammo_rockets = PC_ENGINEER_MAXAMMO_ROCKET;
            self.ammo_nails = PC_ENGINEER_MAXAMMO_NAIL;
            self.ammo_shells = PC_ENGINEER_MAXAMMO_SHOT;
            self.ammo_cells = PC_ENGINEER_MAXAMMO_CELL;
            self.armortype = PC_ENGINEER_MAXARMORTYPE;
            self.no_grenades_1 = role.gren1_limits[9];
            self.no_grenades_2 = role.gren2_limits[9];

            if (old_hp_armor)
                self.armorvalue = 50;
            else
                self.armorvalue = PC_ENGINEER_MAXARMOR;
        } else {
            self.ammo_rockets = PC_ENGINEER_INITAMMO_ROCKET;
            self.ammo_nails = PC_ENGINEER_INITAMMO_NAIL;
            self.ammo_shells = PC_ENGINEER_INITAMMO_SHOT;
            self.ammo_cells = PC_ENGINEER_INITAMMO_CELL;
            self.armortype = PC_ENGINEER_INITARMORTYPE;
            self.no_grenades_1 = min(PC_ENGINEER_GRENADE_INIT_1,role.gren1_limits[9]);
            self.no_grenades_2 = min(PC_ENGINEER_GRENADE_INIT_2,role.gren2_limits[9]);
            if (old_hp_armor)
                self.armorvalue = 25;
            else
                self.armorvalue = PC_ENGINEER_INITARMOR;
        }

        // dispenser needs
        self.need_shells = 1;
        self.need_nails = 1;
        self.need_rockets = 1;
        self.need_cells = 1;

        self.maxammo_rockets = PC_ENGINEER_MAXAMMO_ROCKET;
        self.maxammo_nails = PC_ENGINEER_MAXAMMO_NAIL;
        self.maxammo_shells = PC_ENGINEER_MAXAMMO_SHOT;
        self.maxammo_cells = PC_ENGINEER_MAXAMMO_CELL;
        self.max_grenades_1 = role.gren1_limits[9];
        self.max_grenades_2 = role.gren2_limits[9];

        self.tp_grenades_1 = PC_ENGINEER_GRENADE_TYPE_1;
        self.tp_grenades_2 = PC_ENGINEER_GRENADE_TYPE_2;
        self.tf_items = PC_ENGINEER_TF_ITEMS;

        self.armorclass = self.armorclass | PC_ENGINEER_INITARMORCLASS;
        self.armor_allowed = PC_ENGINEER_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 50;
        else
            self.maxarmor = PC_ENGINEER_MAXARMOR;
        if (self.last_playerclass != self.playerclass)
            self.current_weapon = WEAP_LASER;

        self.items_allowed = PC_ENGINEER_WEAPONS;
        self.items = self.items | IT_SHOTGUN | IT_SUPER_SHOTGUN;
    } else if (self.playerclass == PC_UNDEFINED) {
        self.items = 0;
        self.ammo_rockets = 0;
        self.ammo_nails = 0;
        self.ammo_shells = 0;
        self.ammo_cells = 0;

        self.no_grenades_1 = 0;
        self.no_grenades_2 = 0;
        self.tp_grenades_1 = 0;
        self.tp_grenades_2 = 0;
        self.max_grenades_1 = 0;
        self.max_grenades_2 = 0;

        self.armorclass = 0;
        self.armortype = 0;
        self.armorvalue = 0;
        self.weapon = 0;
        self.current_weapon = 0;
        self.weapons_carried = 0;

        self.flags = FL_CLIENT | FL_NOTARGET;
        self.waterlevel = 3;
        self.takedamage = DAMAGE_NO;
        self.solid = SOLID_NOT;
        self.movetype = MOVETYPE_NOCLIP;

        self.model = string_null;
        self.mdl = string_null;
        self.modelindex = 0;
        self.weaponmodel = string_null;
        modelindex_player = 0;
        self.tfstate = self.tfstate | TFSTATE_RELOADING;

        setmodel(self, string_null);
    }
    if(duelmode && !duel_all_grens) {
        //unless duel_all_grens is set, remove all secondary grens except emps
        if(self.playerclass != PC_ENGINEER) {
            self.no_grenades_2 = 0;
        }
    }

    if (self.armortype >= 0.8)
        self.items = self.items | IT_ARMOR3;
    else if (self.armortype >= 0.6)
        self.items = self.items | IT_ARMOR2;
    else if (self.armortype >= 0.3)
        self.items = self.items | IT_ARMOR1;

    W_SetCurrentAmmo(self);
    if (self.last_playerclass != self.playerclass)
        self.current_weaponslot = W_BestWeaponSlot();  
};

float (entity Retriever, float AmmoType) TeamFortress_GetMaxAmmo = {
    if (AmmoType == IT_SHELLS)
        return Retriever.maxammo_shells;
    else if (AmmoType == IT_NAILS)
        return Retriever.maxammo_nails;
    else if (AmmoType == IT_CELLS)
        return Retriever.maxammo_cells;
    else if (AmmoType == IT_ROCKETS)
        return Retriever.maxammo_rockets;
    else if (AmmoType == WEAP_MEDIKIT)
        return Retriever.maxammo_medikit;
    else if (AmmoType == WEAP_DETPACK)
        return Retriever.maxammo_detpack;

    dprint("Error in TeamFortress_GetMaxAmmo()\n");
    dprint("Invalid ammo type passed.\n");
    return (0);
};

float (entity Retriever, float WeaponType) TeamFortress_CanGetWeapon = {
    if (Retriever.items_allowed & WeaponType)
        return TRUE;

    return FALSE;
};

void (entity Player, float Armorclass) TeamFortress_DescribeArmor = {
    if (Armorclass == 0)
        return;

    if (Armorclass & AT_SAVEFIRE)
        sprint(Player, PRINT_HIGH, "Asbestos ");
    if (Armorclass & AT_SAVENAIL)
        sprint(Player, PRINT_HIGH, "Wooden ");
    if (Armorclass & AT_SAVEEXPLOSION)
        sprint(Player, PRINT_HIGH, "Blast ");
    if (Armorclass & AT_SAVEELECTRICITY)
        sprint(Player, PRINT_HIGH, "Shockproof ");
    if (Armorclass & AT_SAVESHOT)
        sprint(Player, PRINT_HIGH, "Kevlar ");

    sprint(Player, PRINT_HIGH, "armor\n");
};

void (entity Retriever, entity Items) TeamFortress_AddBackpackItems = {
    return;
};

string(float pc) TeamFortress_GetClassName =
{
    if (pc == PC_SCOUT)
        return "Scout";
    else if (pc == PC_SNIPER)
        return "Sniper";
    else if (pc == PC_SOLDIER)
        return "Soldier";
    else if (pc == PC_DEMOMAN)
        return "Demolitions Man";
    else if (pc == PC_MEDIC)
        return "Combat Medic";
    else if (pc == PC_HVYWEAP)
        return "Heavy Weapons Guy";
    else if (pc == PC_PYRO)
        return "Pyro";
    else if (pc == PC_SPY)
        return "Spy";
    else if (pc == PC_ENGINEER)
        return "Engineer";
    else if (pc == PC_CIVILIAN)
        return "Civilian";
    else if (pc == PC_UNDEFINED)
        return "Observer";
    else if (pc == PC_RANDOM)
        return "Random Playerclass";

    return "Unknown";
};

void (entity Viewer, float pc, float rpc) TeamFortress_PrintClassName = {
    local string st;

    st = TeamFortress_GetClassName(pc);
    sprint(Viewer, PRINT_HIGH, st);

    if (rpc != 0)
        sprint(Viewer, PRINT_HIGH, " (random)");

    sprint(Viewer, PRINT_HIGH, "\n");
};

void () TeamFortress_StartTimers = {
    local entity timer;

    // start autoid timer
    timer = spawn();
    timer.nextthink = time + 0.3;
    timer.think = AutoId;
    timer.owner = self;
    timer.classname = "aitimer";
}

void () TeamFortress_RemoveTimers = {
    local entity te;

    self.leg_damage = 0;
    self.is_concussed = 0;
    self.is_undercover = 0;

    if (self.is_building && engineer_move) {
        TeamFortress_EngineerBuildStop();
    }

    self.is_building = 0;
    self.building = world;
    if (self.tfstate & TFSTATE_AIMING) {
        self.tfstate = self.tfstate - TFSTATE_AIMING;
        TeamFortress_SetSpeed(self);
        self.heat = 0;
    }
    if (self.tfstate & TFSTATE_INFECTED)
        self.tfstate = self.tfstate - (self.tfstate & TFSTATE_INFECTED);
    if (self.tfstate & TFSTATE_HALLUCINATING)
        self.tfstate =
            self.tfstate - (self.tfstate & TFSTATE_HALLUCINATING);

    te = find(world, classname, "timer");
    while (te != world) {
        if ((te.owner == self) && (te.no_active_gas_grens <= 0)) {
            dremove(te);
            te = find(world, classname, "timer");
        } else
            te = find(te, classname, "timer");
    }

    RemoveAutoIdTimer();
    RemoveGrenadeTimers();
    RemovePrimeTimers();
    self.StatusGrenTime = 0;
    Status_Refresh(self);

    te = find(world, classname, "grentimer");
    while (te != world) {
        if ((te.owner == self) && (te.no_active_napalm_grens <= 0)) {
            dremove(te);
            te = find(world, classname, "grentimer");
        } else
            te = find(te, classname, "grentimer");
    }

    te = find(world, classname, "item_tfgoal");
    while (te) {
        if (te.owner == self) {
            if (!(te.goal_activation & TFGI_KEEP) ||
                (self.has_disconnected == 1)) {
                tfgoalitem_RemoveFromPlayer(te, self, 0);
            }
            if (CTF_Map == 1) {
                if (te.goal_no == 1) {
                    bprint(PRINT_HIGH, self.netname,
                           Q" \stook\s the \sblue\s flag!\n");
                } else if (te.goal_no == 2) {
                    bprint(PRINT_HIGH, self.netname,
                           Q" \stook\s the \sred\s flag!\n");
                }
            }
        }
        te = find(te, classname, "item_tfgoal");
    }

    te = find(world, classname, "detpack");
    while (te) {
        if ((te.weaponmode == 1) && (te.enemy == self))
            te.weaponmode = 0;
        te = find(te, classname, "detpack");
    }

    TeamFortress_DetonatePipebombs(1);
    if (self.has_disconnected == 1) {
        te = find(world, classname, "grenade");
        while (te) {
            if ((te.owner == self) && (te.model == "progs/caltrop.mdl")) {
                dremove(te);
                te = find(world, classname, "grenade");
            } else
                te = find(te, classname, "grenade");
        }
    }
    if (old_grens == 1) {
        stuffcmd(self, "v_idlescale 0\n");
        stuffcmd(self, "v_cshift; wait; bf\n");
        self.FlashTime = 0;
    }
    self.item_list = 0;
    Menu_Close(self);
    self.impulse = 0;
};

void (float Suicided) TeamFortress_SetupRespawn = {
    local float restime;
    local string db;

    if (self.respawn_time > time)
        return;

    if (toggleflags & TFLAG_RESPAWNDELAY)
        restime = GetTeamRole(self.team_no).respawn_delay_time;
    else
        restime = 0;

    if (!cb_prematch && !votemode) {
        if (Suicided) {
            if (self.lives > 0)
                self.lives = self.lives - 1;
            restime = restime + 7;
        }
    }
    if (cb_prematch) {
        if (self.lives > 0)
            self.lives = self.lives - 1;

        if (self.lives != -1) {
            if (self.lives == 0) {
                sprint(self, PRINT_HIGH,
                       "No lives left, returning to observer mode\n");
                self.playerclass = PC_UNDEFINED;
                self.tfstate =
                    self.tfstate - (self.tfstate & TFSTATE_RANDOMPC);
                self.movetype = MOVETYPE_NOCLIP;
                self.solid = SOLID_NOT;

                self.model = "";
                self.mdl = "";
                self.velocity = '0 0 0';
                self.avelocity = '0 0 0';

                self.enemy = world;
                setmodel(self, "");
                return;
            }
            if (self.lives == 1)
                sprint(self, PRINT_HIGH, "Last life\n");
            else {
                db = ftos(self.lives);
                sprint(self, PRINT_HIGH, db, " lives left\n");
            }
        }
    }
    self.respawn_time = time + restime;
    if (restime > 3 && !duelmode) {
        db = ftos(restime);
        sprint(self, PRINT_HIGH, db, " seconds till respawn\n");
    }
};

void () TeamFortress_CheckClassStats = {
    // Check armor
    if (self.armortype > self.armor_allowed)
        self.armortype = self.armor_allowed;
    if (self.armorvalue > self.maxarmor)
        self.armorvalue = self.maxarmor;
    if (self.armortype < 0)
        self.armortype = 0;
    if (self.armorvalue < 0)
        self.armorvalue = 0;

    // Check ammo
    if (self.ammo_shells > TeamFortress_GetMaxAmmo(self, IT_SHELLS))
        self.ammo_shells = TeamFortress_GetMaxAmmo(self, IT_SHELLS);
    if (self.ammo_shells < 0)
        self.ammo_shells = 0;
    if (self.ammo_nails > TeamFortress_GetMaxAmmo(self, IT_NAILS))
        self.ammo_nails = TeamFortress_GetMaxAmmo(self, IT_NAILS);
    if (self.ammo_nails < 0)
        self.ammo_nails = 0;
    if (self.ammo_rockets > TeamFortress_GetMaxAmmo(self, IT_ROCKETS))
        self.ammo_rockets = TeamFortress_GetMaxAmmo(self, IT_ROCKETS);
    if (self.ammo_rockets < 0)
        self.ammo_rockets = 0;
    if (self.ammo_cells > TeamFortress_GetMaxAmmo(self, IT_CELLS))
        self.ammo_cells = TeamFortress_GetMaxAmmo(self, IT_CELLS);
    if (self.ammo_cells < 0)
        self.ammo_cells = 0;
    if (self.ammo_medikit > TeamFortress_GetMaxAmmo(self, WEAP_MEDIKIT))
        self.ammo_medikit = TeamFortress_GetMaxAmmo(self, WEAP_MEDIKIT);
    if (self.ammo_medikit < 0)
        self.ammo_medikit = 0;
    if (self.ammo_detpack > TeamFortress_GetMaxAmmo(self, WEAP_DETPACK))
        self.ammo_detpack = TeamFortress_GetMaxAmmo(self, WEAP_DETPACK);
    if (self.ammo_detpack < 0)
        self.ammo_detpack = 0;

    // Check Grenades
    if (self.no_grenades_1 < 0)
        self.no_grenades_1 = 0;
    if (self.no_grenades_2 < 0)
        self.no_grenades_2 = 0;

    // Check health
    if ((self.health > self.max_health) && !(self.items & IT_SUPERHEALTH))
        TF_T_Damage(self, world, world, self.max_health - self.health, 0,
                    TF_TD_NOSOUND);
    if (self.health < 0)
        T_Heal(self, self.health - self.health, 0);

    // Update armor picture
    self.items =
        self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
    if (self.armortype >= 0.8)
        self.items = self.items | IT_ARMOR3;
    else if (self.armortype >= 0.6)
        self.items = self.items | IT_ARMOR2;
    else if (self.armortype >= 0.3)
        self.items = self.items | IT_ARMOR1;
};

void (float type) TeamFortress_DropAmmo = {
    local float ammo;
    ammo = 0;

    if (type == 1) {
        ammo = DROP_SHELLS;
        if (self.ammo_shells < ammo) {
            if (self.playerclass == PC_ENGINEER) {
                if ((self.ammo_cells / AMMO_COST_SHELLS) >
                    (ammo - self.ammo_shells)) {
                    sprint(self, PRINT_HIGH, "You make some shells\n");
                    self.ammo_cells =
                        self.ammo_cells - (ammo -
                                           self.ammo_shells) *
                        AMMO_COST_SHELLS;
                    self.ammo_shells = ammo;
                }
            }
            if (self.ammo_shells < ammo)
                return;
        }
        self.ammo_shells = self.ammo_shells - ammo;
    } else if (type == 2) {
        ammo = DROP_NAILS;
        if (self.ammo_nails < ammo) {
            if (self.playerclass == PC_ENGINEER) {
                if ((self.ammo_cells / AMMO_COST_NAILS) >
                    (ammo - self.ammo_nails)) {
                    sprint(self, PRINT_HIGH, "You make some nails\n");
                    self.ammo_cells =
                        self.ammo_cells - (ammo -
                                           self.ammo_nails) *
                        AMMO_COST_NAILS;
                    self.ammo_nails = ammo;
                }
            }
            if (self.ammo_nails < ammo)
                return;
        }
        self.ammo_nails = self.ammo_nails - ammo;
    } else if (type == 3) {
        ammo = DROP_ROCKETS;
        if (self.ammo_rockets < ammo) {
            if (self.playerclass == PC_ENGINEER) {
                if ((self.ammo_cells / AMMO_COST_ROCKETS) >
                    (ammo - self.ammo_rockets)) {
                    sprint(self, PRINT_HIGH, "You make some rockets\n");
                    self.ammo_cells =
                        self.ammo_cells - (ammo -
                                           self.ammo_rockets) *
                        AMMO_COST_ROCKETS;
                    self.ammo_rockets = ammo;
                }
            }
            if (self.ammo_rockets < ammo)
                return;
        }
        self.ammo_rockets = self.ammo_rockets - ammo;
    } else if (type == 4) {
        ammo = DROP_CELLS;
        if (self.ammo_cells < ammo) {
            if (self.playerclass == PC_ENGINEER) {
                if ((self.ammo_cells / AMMO_COST_CELLS) >
                    (ammo - self.ammo_cells)) {
                    sprint(self, PRINT_HIGH, "You make some cells\n");
                    self.ammo_cells =
                        self.ammo_cells - (ammo -
                                           self.ammo_cells) *
                        AMMO_COST_CELLS;
                    self.ammo_cells = ammo;
                }
            }
            if (self.ammo_cells < ammo)
                return;
        }
        self.ammo_cells = self.ammo_cells - ammo;
    }
    W_SetCurrentAmmo(self);
    newmis = spawn();
    newmis.aflag = ammo;
    newmis.weapon = type;
    if (newmis.weapon == 1)
        newmis.ammo_shells = ammo;
    else if (newmis.weapon == 2)
        newmis.ammo_nails = ammo;
    else if (newmis.weapon == 3)
        newmis.ammo_rockets = ammo;
    else if (newmis.weapon == 4)
        newmis.ammo_cells = ammo;
    newmis.enemy = self;
    newmis.health = time;
    newmis.movetype = 6;
    newmis.solid = 1;
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
    newmis.skin = type - 1;

    FO_SetModel(newmis, "progs/ammobox.mdl");
};

void () TeamFortress_AmmoboxTouch = {
    local float took;
    local string quantity;

    took = 0;
    if ((other == self.enemy) && (time < (self.health + 2)))
        return;
    if ((other.tfstate & TFSTATE_CANT_MOVE) || (other.tfstate & TFSTATE_AIMING))
        return;
    if (other.classname != "player")
        return;
    if (other.health <= 0)
        return;
    if (other.nopickup == self)
        return;

    if (self.weapon == 0) {
        if (discammo_pickup) {
            other.ammo_shells = other.ammo_shells + self.ammo_shells;
            other.ammo_nails = other.ammo_nails + self.ammo_nails;
            other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
            other.ammo_cells = other.ammo_cells + self.ammo_cells;
            dremove(self);
            bound_other_ammo(other);
            FO_Sound(other, CHAN_ITEM, "weapons/lock4.wav", 1, 1);
            stuffcmd(other, "bf\n");
            self = other;
            W_SetCurrentAmmo(self);
            return;
        } else if ((other.playerclass == PC_SCOUT)
                    || (other.playerclass == PC_ENGINEER)) {
            if (!(self.ammo_shells + self.ammo_nails + self.ammo_cells)) {
                other.nopickup = self;
                return;
            }
            other.ammo_shells = other.ammo_shells + self.ammo_shells;
            self.ammo_shells = 0;
            other.ammo_nails = other.ammo_nails + self.ammo_nails;
            self.ammo_nails = 0;
            other.ammo_cells = other.ammo_cells + self.ammo_cells;
            self.ammo_cells = 0;
        } else if ((other.playerclass == PC_SNIPER)
                    || (other.playerclass == PC_SPY)
                    || (other.playerclass == PC_MEDIC)) {
            if (!(self.ammo_shells + self.ammo_nails)) {
                other.nopickup = self;
                return;
            }
            other.ammo_shells = other.ammo_shells + self.ammo_shells;
            self.ammo_shells = 0;
            other.ammo_nails = other.ammo_nails + self.ammo_nails;
            self.ammo_nails = 0;
        } else if ((other.playerclass == PC_SOLDIER)
                    || (other.playerclass == PC_DEMOMAN)) {
            if (!(self.ammo_shells + self.ammo_rockets)) {
                other.nopickup = self;
                return;
            }
            other.ammo_shells = other.ammo_shells + self.ammo_shells;
            self.ammo_shells = 0;
            other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
            self.ammo_rockets = 0;
        } else if (other.playerclass == PC_HVYWEAP) {
            if (!(self.ammo_shells + self.ammo_cells)) {
                other.nopickup = self;
                return;
            }
            other.ammo_shells = other.ammo_shells + self.ammo_shells;
            self.ammo_shells = 0;
            other.ammo_cells = other.ammo_cells + self.ammo_cells;
            self.ammo_cells = 0;
        } else if (other.playerclass == PC_PYRO) {
            if (!(self.ammo_shells + self.ammo_rockets + self.ammo_cells)) {
                other.nopickup = self;
                return;
            }
            other.ammo_shells = other.ammo_shells + self.ammo_shells;
            self.ammo_shells = 0;
            other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
            self.ammo_rockets = 0;
            other.ammo_cells = other.ammo_cells + self.ammo_cells;
            self.ammo_cells = 0;
        }
        other.nopickup = self;
        if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
            dremove(self);
    } else {
        if (self.weapon == 1) {
            if (other.ammo_shells >= TeamFortress_GetMaxAmmo(other, 256))
                return;
            other.ammo_shells = other.ammo_shells + self.aflag;
            self.netname = "shells";
        } else if (self.weapon == 2) {
            if (other.ammo_nails >= TeamFortress_GetMaxAmmo(other, 512))
                return;
            other.ammo_nails = other.ammo_nails + self.aflag;
            self.netname = "nails";
        } else if (self.weapon == 3) {
            if (other.ammo_rockets >= TeamFortress_GetMaxAmmo(other, 1024))
                return;
            other.ammo_rockets = other.ammo_rockets + self.aflag;
            self.netname = "rockets";
        } else if (self.weapon == 4) {
            if (other.ammo_cells >= TeamFortress_GetMaxAmmo(other, 2048))
                return;
            other.ammo_cells = other.ammo_cells + self.aflag;
            self.netname = "cells";
        }
        quantity = ftos(self.aflag);
        sprint(other, PRINT_LOW, "You picked up ", quantity, " ", self.netname, "\n");
        dremove(self);
    }
    bound_other_ammo(other);
    FO_Sound(other, CHAN_ITEM, "weapons/lock4.wav", 1, 1);
    stuffcmd(other, "bf\n");
    self = other;
    W_SetCurrentAmmo(self);
};

void () TeamFortress_AssaultWeapon = {
    self.impulse = 0;
    if (self.tfstate & TFSTATE_RELOADING)
        return;

    if (!(self.weapons_carried & WEAP_ASSAULT_CANNON))
        return;

    if (self.heat > 0) {
        sprint(self, PRINT_HIGH, "The Assault Cannon is still overheated\n");
        return;
    }

    if (self.ammo_shells < 1) {
        sprint(self, PRINT_HIGH, "Not enough ammo\n");
        return;
    }

    if (self.ammo_cells < 7 && time >= self.antispam_assault_cannon) {
        sprint(self, PRINT_HIGH, "Not enough cells to power the Assault Cannon\n");
        self.antispam_assault_cannon = time + 3;
        return;
    }
    self.current_weapon = WEAP_ASSAULT_CANNON;
    W_SetCurrentAmmo(self);
};

void () TeamFortress_ExplodePerson = {
    local entity te;

    self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & 1);
    KickPlayer(-2, self.owner);

    newmis = spawn();
    newmis.movetype = 10;
    newmis.solid = 2;
    newmis.classname = "grenade";
    newmis.team_no = self.owner.team_no;
    newmis.owner = self.owner;
    newmis.velocity = '0 0 0';
    newmis.angles = vectoangles(newmis.velocity);
    newmis.think = SUB_Null;
    newmis.nextthink = time + 0.1;

    if (self.weapon == GR_TYPE_NORMAL) {
        newmis.touch = NormalGrenadeTouch;
        newmis.think = NormalGrenadeExplode;
        newmis.grenadename = "normalgrenade";
        newmis.skin = 0;
        newmis.avelocity = '300 300 300';
        FO_SetModel(newmis, "progs/hgren2.mdl");
    } else if (self.weapon == GR_TYPE_CONCUSSION) {
        newmis.touch = ConcussionGrenadeTouch;
        newmis.think = ConcussionGrenadeExplode;
        newmis.grenadename = "concussiongrenade";
        newmis.skin = 1;
        newmis.avelocity = '300 300 300';
        FO_SetModel(newmis, "progs/hgren2.mdl");
    } else if (self.weapon == GR_TYPE_NAIL) {
        newmis.touch = NailGrenadeTouch;
        newmis.think = NailGrenadeExplode;
        if (nailgren_type == NGR_TYPE_LASER)
            newmis.grenadename = "shockgrenade";
        else
            newmis.grenadename = "nailgrenade";            
        newmis.skin = 1;
        newmis.avelocity = '0 300 0';
        FO_SetModel(newmis, "progs/biggren.mdl");
    } else if (self.weapon == GR_TYPE_MIRV) {
        newmis.touch = MirvGrenadeTouch;
        newmis.think = MirvGrenadeExplode;
        newmis.grenadename = "mirvgrenade";
        newmis.skin = 0;
        newmis.avelocity = '0 300 0';
        FO_SetModel(newmis, "progs/biggren.mdl");
    } else if (self.weapon == GR_TYPE_NAPALM) {
        newmis.touch = NapalmGrenadeTouch;
        newmis.think = NapalmGrenadeExplode;
        newmis.grenadename = "napalmgrenade";
        newmis.skin = 2;
        newmis.avelocity = '0 300 0';
        FO_SetModel(newmis, "progs/biggren.mdl");
    } else if (self.weapon == GR_TYPE_FLARE) {
        sprint(self.owner, PRINT_HIGH, "Flare lit\n");
        newmis.grenadename = "flaregrenade";
        te = spawn();
        te.touch = SUB_Null;
        te.think = RemoveFlare;
        te.nextthink = time + 25;
        te.owner = self.owner;
        te.solid = 0;
        self.owner.effects = self.owner.effects | EF_BRIGHTLIGHT;
        dremove(self);
        dremove(newmis);
        return;
    } else if (self.weapon == GR_TYPE_GAS) {
        newmis.touch = GasGrenadeTouch;
        newmis.think = GasGrenadeExplode;
        newmis.grenadename = "gasgrenade";
        newmis.skin = 2;
        newmis.avelocity = '300 300 300';
        FO_SetModel(newmis, "progs/grenade2.mdl");
    } else if (self.weapon == GR_TYPE_EMP) {
        newmis.touch = EMPGrenadeTouch;
        newmis.think = EMPGrenadeExplode;
        newmis.grenadename = "empgrenade";
        newmis.skin = 4;
        newmis.avelocity = '300 300 300';
        FO_SetModel(newmis, "progs/grenade2.mdl");
    } else if (self.weapon == GR_TYPE_CALTROP) {
        newmis.touch = CaltropTouch;
        newmis.think = ScatterCaltrops;
        newmis.grenadename = "caltropgrenade";
    } else if (self.weapon == GR_TYPE_FLASH) {
        newmis.touch = FlashGrenadeTouch;
        newmis.think = FlashGrenadeExplode;
        newmis.grenadename = "flashgrenade";
        newmis.skin = 0;
        newmis.avelocity = '300 300 300';
        FO_SetModel(newmis, "progs/flashgren.mdl");
    }
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, self.owner.origin);
    if ((self.owner.playerclass == PC_SCOUT) && (self.weapon != 10))
        bprint3(PRINT_MEDIUM, "No ", self.owner.netname,
                ", swallowing the grenade isn't very effective!\n");
    else if (self.owner.playerclass == PC_SNIPER)
        bprint3(PRINT_MEDIUM, "Well ", self.owner.netname,
                ", don't quit your day job!\n");
    else if (self.owner.playerclass == PC_SOLDIER)
        bprint3(PRINT_MEDIUM, "Ummm, ", self.owner.netname,
                ", you're supposed to THROW the grenade!\n");
    else if (self.owner.playerclass == PC_DEMOMAN)
        bprint3(PRINT_MEDIUM, "Ack! ", self.owner.netname,
                "! The grenade is your friend for another reason!\n");
    else if (self.owner.playerclass == PC_MEDIC) {
        if (self.weapon == GR_TYPE_CONCUSSION)
            bprint3(PRINT_MEDIUM, "Yes ", self.owner.netname,
                    ", eating a concussion grenade is bad!\n");
        else
            bprint3(PRINT_MEDIUM, "No ", self.owner.netname,
                    "! Assist your own suicide some other time!\n");
    }
    else if (self.owner.playerclass == PC_HVYWEAP)
        bprint3(PRINT_MEDIUM, "Hey ", self.owner.netname,
                ", you're not THAT heavy!\n");
    else if (self.owner.playerclass == PC_PYRO)
        bprint3(PRINT_MEDIUM, "Yes ", self.owner.netname,
                ", the grenade does explode on '3'!\n");
    else if (self.owner.playerclass == PC_SPY)
        bprint3(PRINT_MEDIUM, "You do realize ", self.owner.netname,
                ", you can blow your cover in easier ways!\n");
    else if (self.owner.playerclass == PC_ENGINEER)
        bprint3(PRINT_MEDIUM, "Hey ", self.owner.netname,
                ", study grenade dynamics on your own time!\n");
    else
        bprint3(PRINT_MEDIUM, "No ", self.owner.netname,
                ", throw the grenade, not the pin!\n");

    dremove(self);
};

void () NormalGrenadeTouch = {
    if (other == self.owner)
        return;

    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void () NormalGrenadeExplode = {
    deathmsg = DMSG_GREN_HAND;
    T_RadiusDamage(self, self.owner, 180, world);

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);

    multicast(self.origin, MULTICAST_PHS);
    dremove(self);
};

void () TeamFortress_DisplayDetectionItems = {
    local entity tfdet;
    local entity te;
    te = world;

    tfdet = find(world, classname, "info_tfdetect");
    if (!tfdet)
        return;

    for (float t = 1; t <= number_of_teams; t++) {
        switch (t)
        {
            case 1:
                te = Finditem(tfdet.display_item_status1);
                break;
            case 2:
                te = Finditem(tfdet.display_item_status2);
                break;
            case 3:
                te = Finditem(tfdet.display_item_status3);
                break;
            case 4:
                te = Finditem(tfdet.display_item_status4);
                break;
        }

        if (te)
        {
            sprint(self, PRINT_HIGH, strcat(GetItemStatus(self, te, t), "\n"));
        }
        else
        {
            sprint(self, PRINT_HIGH, "Item is missing\n");
        }
    }
};

void (string halias, float himpulse1, float himpulse2) TeamFortress_Alias = {
    local string imp;

    stuffcmd(self, "alias ");
    stuffcmd(self, halias);
    stuffcmd(self, " \"impulse ");
    imp = ftos(himpulse1);
    stuffcmd(self, imp);

    if (himpulse2 != 0) {
        stuffcmd(self, ";wait; impulse ");
        imp = ftos(himpulse2);
        stuffcmd(self, imp);
    }
    stuffcmd(self, "\"\n");
};

void (string halias, string commands) TeamFortress_AliasString = {
    stuffcmd(self, "alias ");
    stuffcmd(self, halias);
    stuffcmd(self, " \"");
    stuffcmd(self, commands);
    stuffcmd(self, "\"\n");
};

void () TeamFortress_RegenerateCells = {
    if (self.owner.playerclass == PC_SPY) {
        self.nextthink = time + PC_SPY_CELL_REGEN_TIME;

        if (self.owner.is_undercover == 1) {
            if (self.owner.ammo_cells == 0) {
                self.owner.is_undercover = 0;
                self.owner.modelindex = modelindex_player;
                self.owner.items =
                    self.owner.items -
                    (self.owner.items & IT_INVISIBILITY);
            } else {
                self.owner.ammo_cells =
                    self.owner.ammo_cells - PC_SPY_CELL_USAGE;
                if (self.owner.ammo_cells < 0)
                    self.owner.ammo_cells = 0;
            }
        } else {
            if (self.owner.ammo_cells >= self.owner.maxammo_cells)
                return;

            self.owner.ammo_cells =
                self.owner.ammo_cells + PC_SPY_CELL_REGEN_AMOUNT;

            if (self.owner.ammo_cells > self.owner.maxammo_cells)
                self.owner.ammo_cells = self.owner.maxammo_cells;
        }
        return;
    }
};

void () TeamFortress_CheckforCheats = {
    local float tf;
    local float pf;
    local vector vplf;
    local vector vf;

    self.nextthink = time + 2;
    if (self.owner.immune_to_check > time)
        return;
    if (self.owner.deadflag)
        return;
    if (!(self.owner.flags & 512) || (self.velocity_z != 0))
        return;

    vplf = self.owner.velocity;
    makevectors(self.owner.angles);
    vf = v_forward;
    vf_z = 0;
    vf = normalize(vf);
    tf = vplf_x * vf_x + vplf_y * vf_y;
    pf = self.owner.maxfbspeed + 100;

    if ((self.owner.tfstate & TFSTATE_CANT_MOVE) && (tf > 20)) {
        self.nextthink = time + 0.5;
        self.owner.cheat_level = self.owner.cheat_level + 600;
    }
    if (tf > pf) {
        pf = pf + 100;
        if (tf > pf) {
            self.nextthink = time + 2;
            self.owner.cheat_level = self.owner.cheat_level + 300;
        } else {
            self.nextthink = time + 3;
            self.owner.cheat_level = self.owner.cheat_level + 150;
        }
        TeamFortress_SetSpeed(self.owner);
    }
    if (self.owner.cheat_level > 1200) {
        self.owner.cheat_level = 0;
        bprint2(PRINT_MEDIUM, self.owner.netname,
                " has been kicked for cheating\n");
        sprint(self.owner, PRINT_HIGH,
               "You have been kicked for cheating, because of your speed\n");
        KickCheater(self.owner);
    }
};

void () PlayerObserverMode = {
    Menu_Close(self);
    self.impulse = 0;
    self.playerclass = PC_UNDEFINED;
    self.lives = 0;
    self.team_no = -1;

    self.flags = FL_CLIENT | FL_NOTARGET | FL_ONGROUND;
    self.waterlevel = 3;
    self.takedamage = DAMAGE_NO;
    self.solid = SOLID_NOT;
    self.movetype = MOVETYPE_NOCLIP;

    sprint(self, PRINT_HIGH, "Observer mode\n");
    CenterPrint(self, "\n");
    stuffcmd(self, "cl_rollangle 0\n");
};

float (vector veca, vector vecb) crossproducttf = {
    local float result;

    result = veca_x * vecb_y - vecb_x * veca_y;
    return (result);
};

void (entity pl, float fr) TF_AddFrags = {
    local entity e;

    if ((intermission_running != 0) || (intermission_exittime > time))
        return;

    pl.real_frags = pl.real_frags + fr;
    if (fr == 1) {
        pl.fragstreak = pl.fragstreak + 1;
        Status_Refresh(pl);
    }

    if (!pl.team_no)
        return;

    if (toggleflags & TFLAG_FULLTEAMSCORE) {
        if (pl.team_no == 1)
            team1score = team1score + fr;
        else if (pl.team_no == 2)
            team2score = team2score + fr;
        else if (pl.team_no == 3)
            team3score = team3score + fr;
        else if (pl.team_no == 4)
            team4score = team4score + fr;
        UpdateAllClientsTeamScores(); //Update scoreboard for indi frags
    }

    if (pl.team_no == 1)
        team1frags = team1frags + fr;
    else if (pl.team_no == 2)
        team2frags = team2frags + fr;
    else if (pl.team_no == 3)
        team3frags = team3frags + fr;
    else if (pl.team_no == 4)
        team4frags = team4frags + fr;

    if (toggleflags & TFLAG_FULLTEAMSCORE) {
        e = find(world, classname, "player");
        while (e) {
            if (e.team_no == pl.team_no)
                e.frags = TeamFortress_TeamGetScore(e.team_no);
            e = find(e, classname, "player");
        }
    } else if (!(toggleflags & TFLAG_TEAMFRAGS))
        pl.frags = pl.real_frags;
};

void (entity p) TeamFortress_ExecClassScript = {
    local float st = FO_GetUserSetting(p, "ec", "exec_class", "off");

    if (st) {
        if (p.playerclass == PC_SCOUT)
            stuffcmd(p, "exec scout.cfg\n");
        else if (p.playerclass == PC_SNIPER)
            stuffcmd(p, "exec sniper.cfg\n");
        else if (p.playerclass == PC_SOLDIER)
            stuffcmd(p, "exec soldier.cfg\n");
        else if (p.playerclass == PC_DEMOMAN)
            stuffcmd(p, "exec demoman.cfg\n");
        else if (p.playerclass == PC_MEDIC)
            stuffcmd(p, "exec medic.cfg\n");
        else if (p.playerclass == PC_HVYWEAP)
            stuffcmd(p, "exec hwguy.cfg\n");
        else if (p.playerclass == PC_PYRO)
            stuffcmd(p, "exec pyro.cfg\n");
        else if (p.playerclass == PC_SPY)
            stuffcmd(p, "exec spy.cfg\n");
        else if (p.playerclass == PC_ENGINEER)
            stuffcmd(p, "exec engineer.cfg\n");
    }
};

void (entity p) TeamFortress_ExecMapScript = {
    local float st = FO_GetUserSetting(p, "em", "exec_map", "off");

    if (st) {
        stuffcmd(p, "exec maps/default.cfg\n");
        stuffcmd(p, "exec maps/");
        stuffcmd(p, mapname);
        stuffcmd(p, ".cfg\n");
    }
};

void (entity p) KickCheater = {
    stuffcmd(p, "disconnect\n");
    p.has_disconnected = 1;
    p.touch = SUB_Null;
    p.health = 0;
    p.solid = SOLID_NOT;
    p.tfstate = p.tfstate | TFSTATE_CANT_MOVE;
    TeamFortress_SetSpeed(p);
    TeamFortress_RemoveTimers();
};

void (entity p) BanCheater = {
    stuffcmd(p, "disconnect\n");
};
