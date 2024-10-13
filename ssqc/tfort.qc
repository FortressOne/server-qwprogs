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
            self.impulse = TF_HVYWEAP_LOCK_TOGGLE;
            break;
        case PC_PYRO:
            self.impulse = TF_AIRBLAST;
            break;
        case PC_SPY:
            self.impulse = TF_SPY_DIE;
            break;
        case PC_ENGINEER:
            self.impulse = TF_ENGINEER_TOGGLEDISPENSER;
            break;
        case PC_UNDEFINED:
            if (self.enemy == world) {
                src = self.origin + v_forward * 10;
                src_z = self.absmin_z + self.size_z * 0.7;
                traceline(src, src + v_forward * 2048, 0, self);
                if ((trace_ent != world) && (trace_ent.origin != world.origin)) {
                    sprint(self, PRINT_HIGH, "Locked onto ",
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

void () UseSpecialSkill2 = {
    local vector src;

    self.impulse = 0;
    switch (self.playerclass)
    {
        case PC_SCOUT:
            self.impulse = TF_SCAN;
            break;
        case PC_SNIPER:
            break;
        case PC_SOLDIER:
            break;
        case PC_DEMOMAN:
            self.impulse = TF_DETPACK_5;
            break;
        case PC_MEDIC:
            break;
        case PC_HVYWEAP:
            break;
        case PC_PYRO:
            break;
        case PC_SPY:
            self.impulse = TF_DISGUISE_LAST_SPAWNED;
            break;
        case PC_ENGINEER:
            self.impulse = TF_ENGINEER_TOGGLESENTRY;
            break;
        case PC_UNDEFINED:
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

void RemovePrimedGrenades(entity player) {
    entity* ents;
    int count;

    ents = find_list(classname, "primetimer", EV_STRING, count);
    for (int i = 0; i < count; i++)
        if (ents[i].owner == player)
            dremove(ents[i]);

    player.tfstate &= ~(TFSTATE_GREN1_PRIMED | TFSTATE_GREN2_PRIMED);
}

void () RemovePrimeTimers = {
    if (!drop_grenades)
        RemovePrimedGrenades(self);
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
    W_ChangeToBestWeapon();
    if (cease_fire) {
        sprint(self, PRINT_HIGH, "\n\nCease fire mode\n");
        self.immune_to_check = time + 10;
        self.tfstate |= TFSTATE_CANT_MOVE;
    }
    self.spawn_time = time;

    local float autodisguise = FO_GetUserSetting(self, "autodisguise", "ad", "off");
    if (self.playerclass == PC_SPY) {
        switch(autodisguise) {
            case 1:
                FO_Spy_DisguiseLastSpawned(self, FALSE);
                break;
            case 2:
                FO_Spy_DisguiseLast(self, FALSE);
                break;
        }
    }
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
        string g1 = strcat(ftos(fl), " ", FO_GrenName(FO_ClassGren(self.playerclass, 0)->id));
        if (fl > 1)
            g1 = strcat(g1, "s");

        g1 = strcat(g1, "\n");
        sprint(self, PRINT_HIGH, g1);
    }

    fl = self.no_grenades_2;
    if (fl > 0) {
        string g2 = strcat(ftos(fl), " ", FO_GrenName(FO_ClassGren(self.playerclass, 1)->id));
        if (fl > 1)
            g2 = strcat(g2, "s");

        g2 = strcat(g2, "\n");
        sprint(self, PRINT_HIGH, g2);
    }

    if (self.tf_items & NIT_SCANNER)
        sprint(self, PRINT_HIGH, "Scanner\n");

    float current_weapons = FO_WeaponsMask(self);
    if (current_weapons & WEAP_MEDIKIT)
        sprint(self, PRINT_HIGH, "Medikit\n");

    if (self.ammo_detpack > 0) {
        st = ftos(self.ammo_detpack);
        sprint(self, PRINT_HIGH, st, " detpack");
        if (self.ammo_detpack > 1)
            sprint(self, PRINT_HIGH, "s");
        sprint(self, PRINT_HIGH, "\n");
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
    CF_PrintSetting("Strip chasers on cap", cap_strip, "", 1);
    CF_PrintSetting("Stock reloadable clip", stock_reload, "", 1);
    CF_PrintSetting("Old dropflag behaviour", old_dropflag, "", 1);
    CF_PrintSetting("Remember weapon", remember_weapon, "", 1);
    CF_PrintSetting("Pick up discarded ammo", discammo_pickup, "", 1);
    CF_PrintSetting("ID extras", id_extended, "", 1);
    CF_PrintSetting("Display class tips", classtips, "", 1);
    CF_PrintSetting("Old grenades", old_grens, "", 1);
    CF_PrintSetting("Drop grenades on ground", drop_grenades, "", 1);
    CF_PrintSetting("Drop grenades in pack", drop_grenpack, "", 1);
    if (drop_grenpack) {
        CF_PrintSetting("- Grenades type 1", drop_gren1, "", 0);
        CF_PrintSetting("- Grenades type 2", drop_gren2, "", 0);
    }

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
    CF_PrintSetting("Medic max grenades type 2 (concussion/blast)", Role_None.gren2_limits[5], "", PC_MEDIC_GRENADE_MAX_2);
    CF_PrintSetting("Heavy Weapons max grenades type 2 (mirv)", Role_None.gren2_limits[6], "", PC_HVYWEAP_GRENADE_MAX_2);
    CF_PrintSetting("Pyro max grenades type 2 (napalm)", Role_None.gren2_limits[7], "", PC_PYRO_GRENADE_MAX_2);
    CF_PrintSetting("Spy max grenades type 2 (gas)", Role_None.gren2_limits[8], "", PC_SPY_GRENADE_MAX_2);
    CF_PrintSetting("Engineer max grenades type 2 (emp)", Role_None.gren2_limits[9], "", PC_ENGINEER_GRENADE_MAX_2);
    CF_PrintSetting("Distance based cuss", distance_based_cuss_duration, "", 1);
    sprint(self, PRINT_HIGH, "Concussion effect lasts ");
    sprint(self, PRINT_HIGH, ftos(cussgrentime));
    sprint(self, PRINT_HIGH, " seconds");

    sprint(self, PRINT_HIGH, "\n== Scout ==\n");
    CF_PrintSetting("Scout dash ability", scoutdash, "", 1);

    sprint(self, PRINT_HIGH, "\n== Sniper ==\n");
    CF_PrintSetting("Old sniper rifle range", old_sniperrange, "", 1);
    CF_PrintSetting("Sniper Rifle power in status bar", sniperpower, "", 1);

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
    CF_PrintSetting("Pipebomb cooldown time", pipecooldown_time, "", 0.5);

    sprint(self, PRINT_HIGH, "\n== Combat Medic ==\n");
    CF_PrintSetting("Medic aura ability", medicaura, "", 1);
    CF_PrintSetting("Old bioweapon damage", old_sniperrange, "", 1);

    sprint(self, PRINT_HIGH, "\n== Heavy Weapons Guy ==\n");
    CF_PrintSetting("Assault Cannon lock ability", cannon_lock, "", 1);
    CF_PrintSetting("Allow Assault Cannon in air", cannon_air, "", 1);
    if (!cannon_movespin) {
        CF_PrintSetting("Allow Assault Cannon while moving", cannon_move, "", 1);
    }
    CF_PrintSetting("Spin Assault Cannon while moving", cannon_movespin, "", 1);
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

void () NormalGrenadeTouch = {
    if (other == self.owner)
        return;

    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

static struct stg_table_entry {
    int id;
    void() touch;
    void() think;
    float no_expiry;
};

stg_table_entry stg_table[] = {
    { GREN_NORMAL,  NormalGrenadeTouch,     FO_T_GrenExplode},
    { GREN_CONC,    ConcussionGrenadeTouch, FO_T_GrenExplode},
    { GREN_BLAST,   BlastGrenadeTouch,      BlastGrenadeExplode},
    { GREN_NAIL,    NailGrenadeTouch,       NailGrenadeExplode},
    { GREN_SHOCK,   ShockGrenadeTouch,      ShockGrenadeExplode, TRUE},
    { GREN_BURST,   BurstGrenadeTouch,      BurstGrenadeExplode},
    { GREN_MIRV,    MirvGrenadeTouch,       MirvGrenadeExplode},
    { GREN_NAPALM,  NapalmGrenadeTouch,     NapalmGrenadeExplode1, TRUE},
    { GREN_FLARE,   FlareGrenadeTouch,      FlareGrenadeExplode},
    { GREN_GAS,     GasGrenadeTouch,        GasGrenadeExplode1, TRUE},
    { GREN_EMP,     EMPGrenadeTouch,        EMPGrenadeExplode},
    { GREN_FLASH,   FlashGrenadeTouch,      FlashGrenadeExplode},
    { GREN_CALTROP, CanisterTouch,          ScatterCaltrops},
};

void (entity timer) FO_SpawnThrownGrenade = {
    local entity user = timer.owner;
    user.tfstate &= ~TFSTATE_GREN_MASK_ALL;
    user.last_throw = time;

    UpdateClientGrenadeThrown(user);

    KickPlayer(-1, user);
    entity proj = FOProj_Create(FPP_HANDGRENADE);
    proj.owner = user;
    proj.movetype = MOVETYPE_BOUNCE;
    proj.solid = SOLID_BBOX;
    proj.classname = "grenade";
    makevectors(user.v_angle);
    if (user.deadflag) {
        if (timer.weapon == GREN_NORMAL)
            proj.velocity = '0 0 200';
        else
            return;
    } else if (user.v_angle_x) {
        proj.velocity =
            v_forward * 600 + v_up * 200 + crandom() * v_right * 10 +
            crandom() * v_up * 10;
    } else {
        proj.velocity = aim(user, 10000);
        proj.velocity = proj.velocity * 600;
        proj.velocity_z = 200;
    }
    proj.angles = vectoangles(proj.velocity);
    proj.think = SUB_Null;
    proj.nextthink = timer.heat;

    int gtype = timer.fpp.gren_type;
    FO_GrenInfo* gdesc = FO_GrenDesc(gtype);
    stg_table_entry* ste = &stg_table[gtype - GREN_FIRST];

    proj.fpp.gren_type = gtype;
    if (!ste->no_expiry)
        proj.fpp.expires_at = timer.heat;
    proj.skin = gdesc->skin;
    proj.touch = ste->touch;
    proj.think = ste->think;

    setorigin(proj, user.origin);
    FOProj_Finalize(proj);
}

void (float inp) TeamFortress_PrimeThrowGrenade = {
    if (self.tfstate & TFSTATE_GREN_MASK_PRIMED)
        TeamFortress_ThrowGrenade();
    else
        TeamFortress_PrimeGrenade(inp, TRUE);

    if (FO_ClassGren(self.playerclass, inp - 1)->id == GREN_CALTROP)
        TeamFortress_ThrowGrenade();
}

void () FO_GrenadeThink;

// is_player defines whether this originated from the player or server.
void TeamFortress_PrimeGrenade(float inp, float is_player) {
    if (self.tfstate & TFSTATE_GREN_MASK_PRIMED)
        return;

    if (no_fire_mode)
        return;

    FO_GrenInfo* gdesc = FO_PlayerGren(self, inp - 1);

    if (gdesc->id == GREN_NONE)
        return;

    float *numg = (inp == 1) ? &self.no_grenades_1 : &self.no_grenades_2;
    string gs = FO_GrenName(gdesc->id);

    if (*numg > 0) {
        self.has_throwngren = TRUE;
        *numg -= 1;
        if (gdesc->id == GREN_FLARE) {
            newmis = spawn();
            newmis.owner = self;
            newmis.movetype = MOVETYPE_TOSS;
            newmis.solid = SOLID_BBOX;
            newmis.classname = "grenade";
            newmis.fpp.gren_type = GREN_FLARE;
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
        } if (gdesc->id == GREN_CALTROP) {
            sprint(self, PRINT_HIGH, "Opening ", gs, "...\n");
        } else {
            sprint(self, PRINT_HIGH, gs, " primed, 3 seconds...\n");
        }
    } else {
        sprint(self, PRINT_HIGH, "No ", gs, "s left\n");
        return;
    }

    self.tfstate |= (inp == 1) ? TFSTATE_GREN1_PRIMED : TFSTATE_GREN2_PRIMED;

    entity tGrenade = spawn();
    tGrenade.owner = self;
    tGrenade.weapon = gdesc->id;
    tGrenade.fpp.gren_type = gdesc->id;

    tGrenade.classname = "primetimer";
    if (inp == 1)
        tGrenade.impulse = TF_GRENADE_1;
    else if (inp == 2)
        tGrenade.impulse = TF_GRENADE_2;

    float time_base = max(remote_time(), self.last_throw);
    tGrenade.nextthink = time_base + 0.8;
    if (gdesc->id == GREN_CALTROP)
        tGrenade.heat = time_base + 0.5 + 0.5;
    else {
        tGrenade.heat = time_base + 3 + 0.8;

        self.primed_gren_type = gdesc->id;
        self.primed_gren_exp = tGrenade.heat;
        UpdateClientGrenadePrimed(self, gdesc->id, tGrenade.heat);
    }

    tGrenade.think = FO_GrenadeThink;
    self.grenade_timer = tGrenade;
    self.last_prime = global_to_client_time(time_base);
}

void () FO_GrenadeThink = {
    local entity user = self.owner;

    // Claim: These cases do not exist for FO; to be removed once proven true.
    if (user.deadflag || user.has_disconnected) {
        dprint("BUG: saw deadflag / disconnected in PreciseGrenadePrimed\n");
        dremove(self);
        return;
    }

    // This timer fires at most 2 times:
    // - Once at 0.8s, this is the first time you are allowed to throw.  We catch
    // GRENTHROWING which latches this state for throws before this point.
    // - A second time at the grenade's expiration for the case it was not thrown.
    // We remove the timer if the client throws before expiration.
    if (time < self.heat) {
        if (user.tfstate & TFSTATE_GRENTHROWING) {  // Latched throw case.
            FO_SpawnThrownGrenade(self);
            dremove(self);
        } else {
            // When REWIND_GRENADES is enabled, we slightly time-warp the
            // spawned grenade to open up the timing window on being able to
            // rewind a throw further.  Total time is the same.
            float expiry = self.heat + FO_RewindGrenWinDt(self.fpp.gren_type);

            // If this fires, we never threw.
            self.nextthink = expiry;
        }
    } else {
        if (self.weapon != GREN_CALTROP)
            TeamFortress_ExplodePerson();
        dremove(self);
    }
}

void () FO_ThrowGrenade = {
    entity timer = self.grenade_timer;

    float throwtime = time;
    if (RewindFlagEnabled(REWIND_GRENADES))
        throwtime = bounded_remote_time(FO_RewindGrenDt(timer.fpp.gren_type));

    if ((timer.nextthink < timer.heat || throwtime > timer.heat - grenade_lockout) &&
        !IsClownMode(CLOWN_SPAM_GRENADES)) {
        // We do not allow throwing within the 0.8s, or the last 0.1s.
        // The former is a priming time, the latter is so that client side
        // knockback will be able to reliably predict whether a grenade was held
        // (e.g. gren jump) or thrown up to ~200ms ping.
        //
        // In the first case, we've set THROWING so think will handle.
        // In the second, buckle up.
    } else {
        FO_SpawnThrownGrenade(timer);
        dremove(timer);
    }
}

void () TeamFortress_ThrowGrenade = {
    if ((self.tfstate & TFSTATE_GREN_MASK_PRIMED == 0) ||
        (self.tfstate & TFSTATE_GRENTHROWING))
        return;

    self.tfstate |= TFSTATE_GRENTHROWING;
    FO_ThrowGrenade();
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

float PmtBlockMaxSpeed();

static void SetMaxSpeed(entity p, float speed) {
    p.csqc_maxspeed = speed;
    if (!PmtBlockMaxSpeed())
        p.maxspeed = speed;
}

void (entity p) TeamFortress_SetSpeed = {
    string sp;
    float tf;
    entity te;

    if (p.tfstate & TFSTATE_CANT_MOVE) {
        p.velocity = '0 0 0';
        SetMaxSpeed(p, 0);
        return;
    }

    if (p.playerclass == PC_UNDEFINED) {
        // Typically this hits spectators and then spec movetype --> maxspeed
        // actually ignored.
        SetMaxSpeed(p, SPEC_MAXSPEED);
        stuffcmd(p, "cl_movespeedkey 1;cl_backspeed 500; cl_forwardspeed 500; cl_sidespeed 500;cl_upspeed 500;\n");
        return;
    }

    float new_max = Class_MaxSpeed(p.playerclass);

    tf = 0;
    te = find(world, classname, "item_tfgoal");
    while ((te != world) && (tf == 0)) {
        if (te.owner == p) {
            if (te.goal_activation & TFGI_SLOW) {
                tf = 1;
                new_max /= 2;
            }
        }
        te = find(te, classname, "item_tfgoal");
    }

    if (p.tfstate & TFSTATE_TRANQUILISED)
        new_max /= 2;

    if (p.leg_damage)
        new_max *= (10 - min(p.leg_damage, 6)) / 10;

#if 0
    // Clients cooperate to handle TFSTATE_AIMING transitions locally due to the
    // frequent edges here and negative maxspeed/pmove interaction (bounds
    // client prediction until maxspeed makes it to client, even though released
    // on unpredicted earlier frame, leading to lots of skipping).
        if (p.tfstate & TFSTATE_AIMING)
            new_max = min(new_max, 80);
#endif

    SetMaxSpeed(p, new_max);
}

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
        self.max_health = 0;
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

string(float pc) TeamFortress_GetSkin = {
    local string skin = "base";

    switch (pc) {
        case 1:
            skin = "fo_scout";
            break;
        case 2:
            skin = "fo_snipe";
            break;
        case 3:
            skin = "fo_sold";
            break;
        case 4:
            skin = "fo_demo";
            break;
        case 5:
            skin = "fo_medic";
            break;
        case 6:
            skin = "fo_hwguy";
            break;
        case 7:
            skin = "fo_pyro";
            break;
        case 8:
            skin = "fo_spy";
            break;
        case 9:
            skin = "fo_eng";
            break;
        case 11:
            skin = "fo_civ";
            break;
    }

    return skin;
};

void (entity player) TeamFortress_SetSkin = {
    player.immune_to_check = time + 10;

    if (player.playerclass == PC_SPY && player.is_undercover) {
        Spy_SetClientSkins(player);
        return;
    }

    player.skin = player.playerclass;

    if (player.skin != 0) {
        player.needs_skin_update = 1;
        local string sk = TeamFortress_GetSkin(player.playerclass);
        forceinfokey(player, "skin",  sk);
        stuffcmd(player, sprintf("skin %s\n", sk));

        local string col = TeamFortress_TeamGetColor(player.team_no);
        forceinfokey(player, "bottomcolor", col);
        stuffcmd(player, sprintf("setinfo bottomcolor %s\n", col));
        forceinfokey(player, "topcolor", col);
        stuffcmd(player, sprintf("setinfo topcolor %s\n", col));
    } else {
        forceinfokey(player, "skin", "base");
        stuffcmd(player, sprintf("skin %s\n", "base"));
        forceinfokey(player, "bottomcolor", NOTEAMCOLOR);
        stuffcmd(player, sprintf("bottomcolor %s\n", NOTEAMCOLOR));
        forceinfokey(player, "topcolor", NOTEAMCOLOR);
        stuffcmd(player, sprintf("topcolor %s\n", NOTEAMCOLOR));
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

    if (!remember_weapon || self.last_playerclass != self.playerclass ||
            (self.tfstate & TFSTATE_RANDOMPC)) {
        self.current_slot = SlotMelee;
        self.last_slot = SlotNull;
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
        st = TeamFortress_TeamGetColor(self.team_no);
        stuffcmd(self, st);
        stuffcmd(self, "\n");
    }
    self.is_building = 0;
    self.is_detpacking = 0;
    self.airblast_cooldown = 0;
    self.is_undercover = 0;
    self.next_feign_time = 0;
    self.is_unabletospy = 0;
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
    self.armor_allowed = 0;
    self.maxarmor = 0;
    self.respawn_time = 0;
    self.heat = 0;
    self.tfstate &= (TFSTATE_RELOADING | TFSTATE_FEIGNED);

    if (self.team_no == 0)
        self.lives = -1;

    if (self.playerclass == PC_SCOUT) {
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

        self.tf_items = PC_SCOUT_TF_ITEMS;

        if (self.tf_items_flags <= 0)
            self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_ENEMY;

        self.armorclass = self.armorclass | 0;
        self.armor_allowed = PC_SCOUT_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 50;
        else
            self.maxarmor = PC_SCOUT_MAXARMOR;
    } else if (self.playerclass == PC_SNIPER) {
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

        self.tf_items = PC_SNIPER_TF_ITEMS;

        self.armorclass = self.armorclass | PC_SNIPER_INITARMORCLASS;
        self.armor_allowed = PC_SNIPER_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 50;
        else
            self.maxarmor = PC_SNIPER_MAXARMOR;
    } else if (self.playerclass == PC_SOLDIER) {
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

        self.tf_items = PC_SOLDIER_TF_ITEMS;

        self.armorclass = self.armorclass | PC_SOLDIER_INITARMORCLASS;
        self.armor_allowed = PC_SOLDIER_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 200;
        else
            self.maxarmor = PC_SOLDIER_MAXARMOR;
    } else if (self.playerclass == PC_DEMOMAN) {
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

        self.tf_items = PC_DEMOMAN_TF_ITEMS;

        self.ammo_detpack = PC_DEMOMAN_INITAMMO_DETPACK;
        self.maxammo_detpack = PC_DEMOMAN_MAXAMMO_DETPACK;

        self.armorclass = self.armorclass | PC_DEMOMAN_INITARMORCLASS;
        self.armor_allowed = PC_DEMOMAN_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 120;
        else
            self.maxarmor = PC_DEMOMAN_MAXARMOR;
    } else if (self.playerclass == PC_MEDIC) {
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

        self.tf_items = PC_MEDIC_TF_ITEMS;

        self.armorclass = self.armorclass | PC_MEDIC_INITARMORCLASS;
        self.armor_allowed = PC_MEDIC_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 100;
        else
            self.maxarmor = PC_MEDIC_MAXARMOR;

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
    } else if (self.playerclass == PC_HVYWEAP) {
        if (spawnfull) {
            self.ammo_rockets = PC_HVYWEAP_MAXAMMO_ROCKET;
            self.ammo_nails = PC_HVYWEAP_MAXAMMO_NAIL;
            self.ammo_shells = PC_HVYWEAP_MAXAMMO_SHOT;
            self.ammo_cells = PC_HVYWEAP_MAXAMMO_CELL;
            self.armortype = PC_HVYWEAP_MAXARMORTYPE;
            self.no_grenades_1 = role.gren1_limits[6];
            self.no_grenades_2 = role.gren2_limits[6];

            if (old_hp_armor) {
                self.armorvalue = 300;
            } else {
                self.armorvalue = max_armor_hwguy;
            }

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

        self.armorclass = self.armorclass | PC_HVYWEAP_INITARMORCLASS;
        self.armor_allowed = PC_HVYWEAP_MAXARMORTYPE;

        if (old_hp_armor) {
            self.maxarmor = 300;
        } else {
            self.maxarmor = max_armor_hwguy;
        }

    } else if (self.playerclass == PC_PYRO) {
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

        self.armorclass = self.armorclass | PC_PYRO_INITARMORCLASS;
        self.armor_allowed = PC_PYRO_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 150;
        else
            self.maxarmor = PC_PYRO_MAXARMOR;
    } else if (self.playerclass == PC_CIVILIAN) {
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

        self.tf_items = PC_CIVILIAN_TF_ITEMS;

        self.armorclass = self.armorclass | PC_CIVILIAN_INITARMORCLASS;
        self.armor_allowed = PC_CIVILIAN_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 0;
        else
            self.maxarmor = PC_CIVILIAN_MAXARMOR;
    } else if (self.playerclass == PC_SPY) {
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

        self.tf_items = PC_SPY_TF_ITEMS;

        self.armorclass = self.armorclass | PC_SPY_INITARMORCLASS;
        self.armor_allowed = PC_SPY_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 100;
        else
            self.maxarmor = PC_SPY_MAXARMOR;

        if (invis_only == 1) {
            te = spawn();
            te.nextthink = time + PC_SPY_CELL_REGEN_TIME;
            te.think = TeamFortress_RegenerateCells;
            te.owner = self;
            te.classname = "timer";
        }
    } else if (self.playerclass == PC_ENGINEER) {
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

        self.tf_items = PC_ENGINEER_TF_ITEMS;

        self.armorclass = self.armorclass | PC_ENGINEER_INITARMORCLASS;
        self.armor_allowed = PC_ENGINEER_MAXARMORTYPE;
        if (old_hp_armor)
            self.maxarmor = 50;
        else
            self.maxarmor = PC_ENGINEER_MAXARMOR;

    } else if (self.playerclass == PC_UNDEFINED) {
        self.ammo_rockets = 0;
        self.ammo_nails = 0;
        self.ammo_shells = 0;
        self.ammo_cells = 0;

        self.no_grenades_1 = 0;
        self.no_grenades_2 = 0;
        self.max_grenades_1 = 0;
        self.max_grenades_2 = 0;

        self.armorclass = 0;
        self.armortype = 0;
        self.armorvalue = 0;
        self.weapon = 0;
        self.current_slot = SlotNull;

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

    if (self.last_playerclass != self.playerclass)
        W_ChangeToBestWeapon();

    W_UpdateCurrentWeapon(self);
    self.last_playerclass = self.playerclass;
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
    if (Retriever.items & WeaponType)
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
    self.is_undercover = 0;
    RemoveConc(self);

    if (self.is_building && engineer_move) {
        TeamFortress_EngineerBuildStop();
    }

    self.is_building = 0;
    self.building = world;
    if (self.tfstate & TFSTATE_AIMING) {
        self.tfstate &= ~TFSTATE_AIMING;
        self.heat = 0;
    }
    if (self.tfstate & TFSTATE_INFECTED)
        self.tfstate = self.tfstate - (self.tfstate & TFSTATE_INFECTED);
    if (self.tfstate & TFSTATE_HALLUCINATING)
        self.tfstate =
            self.tfstate - (self.tfstate & TFSTATE_HALLUCINATING);

    te = find(world, classname, "timer");
    while (te != world) {
        if (te.owner == self) {
            dremove(te);
            te = find(world, classname, "timer");
        } else
            te = find(te, classname, "timer");
    }

    RemoveAutoIdTimer();
    RemovePrimeTimers();
    self.StatusGrenTime = 0;
    Status_Refresh(self);

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
        if ((te.is_disarming) && (te.enemy == self))
            te.is_disarming = FALSE;
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

            if (!allowpracspawns)
                restime = restime + (new_balance ? 5 : 7);
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

void (float type, float ammo) TeamFortress_DropAmmo = {
    //local float ammo;
    //ammo = 0;

    if (type == 1) {
        if(!ammo) ammo = DROP_SHELLS;
        if (self.ammo_shells < ammo) {
            if (self.playerclass == PC_ENGINEER) {
                if ((self.ammo_cells / AMMO_COST_SHELLS) >=
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
        if(!ammo) ammo = DROP_NAILS;
        if (self.ammo_nails < ammo) {
            if (self.playerclass == PC_ENGINEER) {
                if ((self.ammo_cells / AMMO_COST_NAILS) >=
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
        if(!ammo) ammo = DROP_ROCKETS;
        if (self.ammo_rockets < ammo) {
            if (self.playerclass == PC_ENGINEER) {
                if ((self.ammo_cells / AMMO_COST_ROCKETS) >=
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
        if(!ammo) ammo = DROP_CELLS;
        if (self.ammo_cells < ammo) {
            if (self.playerclass == PC_ENGINEER) {
                if ((self.ammo_cells / AMMO_COST_CELLS) >=
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
    newmis.dropped_by = self;
    newmis.dropped_at = time;
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
    setsize(newmis, '-16 -16 0', '16 16 56');
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
    if ((other == self.dropped_by) && (time < (self.dropped_at + 2)))
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
            FO_Sound(other, CHAN_AUTO, "weapons/lock4.wav", 1, 1);
            stuffcmd(other, "bf\n");
            self = other;
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
};

void () TeamFortress_ExplodePerson = {
    entity te;
    int gtype = self.fpp.gren_type;
    FO_GrenInfo* gdesc = FO_GrenDesc(gtype);

    self.owner.tfstate &= ~TFSTATE_GREN_MASK_ALL;
    KickPlayer(-2, self.owner);

    entity proj = FOProj_Create(FPP_HANDGRENADE);
    proj.movetype = MOVETYPE_BOUNCE;
    proj.solid = SOLID_BBOX;
    proj.classname = "grenade";
    proj.team_no = self.owner.team_no;
    proj.owner = self.owner;
    proj.velocity = '0 0 0';
    proj.angles = vectoangles(proj.velocity);
    proj.think = SUB_Null;
    float expires = time + 0.1;  // Server generated, no client time here.
    proj.nextthink = expires;

    if (self.weapon == GREN_FLARE) {
        sprint(self.owner, PRINT_HIGH, "Flare lit\n");
        te = spawn();
        te.touch = SUB_Null;
        te.think = RemoveFlare;
        te.nextthink = time + 25;
        te.owner = self.owner;
        te.solid = 0;
        self.owner.effects = self.owner.effects | EF_BRIGHTLIGHT;
        dremove(self);
        dremove(proj);
        return;
    }

    stg_table_entry* ste = &stg_table[gtype - GREN_FIRST];

    proj.fpp.gren_type = gtype;
    proj.fpp.flags |= FPF_NO_REWIND;
    proj.fpp.expires_at = expires;
    proj.skin = gdesc->skin;
    proj.avelocity = gdesc->avelocity;
    proj.touch = ste->touch;
    proj.think = ste->think;
    setorigin(proj, self.owner.origin);
    FOProj_Finalize(proj);

    if ((self.owner.playerclass == PC_SCOUT) && (self.weapon != 10))
        bprint(PRINT_MEDIUM, "No ", self.owner.netname,
                ", swallowing the grenade isn't very effective!\n");
    else if (self.owner.playerclass == PC_SNIPER)
        bprint(PRINT_MEDIUM, "Well ", self.owner.netname,
                ", don't quit your day job!\n");
    else if (self.owner.playerclass == PC_SOLDIER)
        bprint(PRINT_MEDIUM, "Ummm, ", self.owner.netname,
                ", you're supposed to THROW the grenade!\n");
    else if (self.owner.playerclass == PC_DEMOMAN)
        bprint(PRINT_MEDIUM, "Ack! ", self.owner.netname,
                "! The grenade is your friend for another reason!\n");
    else if (self.owner.playerclass == PC_MEDIC) {
        if (self.weapon == GREN_BLAST) {
            if (medic_type == MEDIC_TYPE_BLAST) {
                bprint(PRINT_MEDIUM, "Nice one ", self.owner.netname,
                        ", you forgot to throw your blast grenade!\n");
            } else {
                bprint(PRINT_MEDIUM, "Yes ", self.owner.netname,
                        ", eating a concussion grenade is bad!\n");
            }
        } else {
            bprint(PRINT_MEDIUM, "No ", self.owner.netname,
                    "! Assist your own suicide some other time!\n");
        }
    }
    else if (self.owner.playerclass == PC_HVYWEAP)
        bprint(PRINT_MEDIUM, "Hey ", self.owner.netname,
                ", you're not THAT heavy!\n");
    else if (self.owner.playerclass == PC_PYRO)
        bprint(PRINT_MEDIUM, "Yes ", self.owner.netname,
                ", the grenade does explode on '3'!\n");
    else if (self.owner.playerclass == PC_SPY)
        bprint(PRINT_MEDIUM, "You do realize ", self.owner.netname,
                ", you can blow your cover in easier ways!\n");
    else if (self.owner.playerclass == PC_ENGINEER)
        bprint(PRINT_MEDIUM, "Hey ", self.owner.netname,
                ", study grenade dynamics on your own time!\n");
    else
        bprint(PRINT_MEDIUM, "No ", self.owner.netname,
                ", throw the grenade, not the pin!\n");

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
                self.owner.items &= ~IT_INVISIBILITY;
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
    pf = self.owner.maxspeed + 100;

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
        bprint(PRINT_MEDIUM, self.owner.netname,
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
    p.tfstate |= TFSTATE_CANT_MOVE;
    TeamFortress_RemoveTimers();
};

void (entity p) BanCheater = {
    stuffcmd(p, "disconnect\n");
};
