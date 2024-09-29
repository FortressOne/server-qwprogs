//========================================================
// Weapons and functions for the ENGINEER class and associated weaponry
//========================================================

void () LaserBolt_Touch;
void () EMPExplode;
void () EMPGrenadeTouch;
void () EMPGrenadeExplode;
void () TeamFortress_FinishedBuilding;
void () Dispenser_Die;
void () CheckDistance;
void (entity disp) Engineer_Dispenser_InsertAmmo;
void (entity disp) Engineer_Dispenser_InsertArmor;
void (entity disp) Engineer_Dispenser_Repair;
void (entity disp) Engineer_SentryGun_ShowMenu;
void (entity disp) Engineer_SentryGun_InsertAmmo;
void (entity disp) Engineer_SentryGun_Upgrade;
void (entity disp) Engineer_SentryGun_Repair;
void () Menu_Engineer_Cancel;
void () CF_CheckBuilding;

void () LaserBolt_Think = {
    self.solid = SOLID_TRIGGER;
    self.movetype = MOVETYPE_FLYMISSILE;
    self.velocity = self.oldorigin;
    self.touch = LaserBolt_Touch;
    FO_SetModel(self, "progs/e_spike2.mdl");
    self.nextthink = time + 1;
    self.think = SUB_Remove;
};

//=========================================================================
// Laserbolt touch function.
void () LaserBolt_Touch = {
    local vector org;

    if (other == self.owner) {
        return;
    }
    if ((other == self.enemy) && (self.enemy != world)) {
        return;
    }
    if (pointcontents(self.origin) == CONTENT_SKY) {
        dremove(self);
        return;
    }
    org = self.origin - 8 * normalize(self.velocity);
    if (other.health) {
        SpawnBlood(org, 15);
        deathmsg = DMSG_LASERBOLT;
        TF_T_Damage(other, self, self.enemy, 25, 2, TF_TD_ELECTRICITY);

        // create a new projectile on other side of target
        self.velocity = self.oldorigin;
        self.owner = other;
        setmodel(self, string_null);
        self.touch = SUB_Null;
        self.nextthink = time + 0.1;
        self.think = LaserBolt_Think;
    } else {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_SPIKE);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PHS);
      
        if(other.classname == "worldspawn" && spurs_enabled > 0)
        {
            if(self.owner.playerclass == PC_ENGINEER && spurs_engineer == 1)
            {
                ConvertToSpurs(self);
                return;
            }
        }
    }
    dremove(self);
};

static const float kImpellerTargetRange = 1500;

static float ValidImpellerTarget(entity t) {
    if (t.classname != "player")
        return FALSE;

    if (vlen(t.origin - self.origin) > kImpellerTargetRange)
        return FALSE;

    if (cb_prematch)  // Shoot anyone in prematch
        return TRUE;

    return (t.team_no != self.team_no && t.has_flag);
}


static entity FindImpellerTarget(vector org, float min_a, float* direct) {

    traceline(org, org + 1500 * v_forward, MOVE_NORMAL, world);
    if (trace_fraction != 1 && ValidImpellerTarget(trace_ent))
        return trace_ent;

    int count;
    entity* players;
    float best_a = min_a;
    entity best_p = world;

    players = find_list(classname, "player", EV_STRING, count);
    for (int i = 0; i < count; i++) {
        entity p = players[i];

        if (!ValidImpellerTarget(p))
            continue;

        vector dir = normalize(p.origin - org);
        float a = v_forward * dir;

        traceline(org, p.origin, MOVE_NORMAL, world);
        if (trace_fraction < 1) {
            if (trace_ent != p) {
                continue; // Something in the way
            } else {
                *direct = TRUE;
                return p;
            }
        }

        if (a < best_a)
            continue;  // Not in AA cone

        best_a = a;
        best_p = p;
    }

    return best_p;
}

static vector find_closest(vector a, vector b, vector p) {
    vector v = b - a, u = a - p;
    float t = -(v * u) / (v * v);

    if (t >= 0 && t <= 1)
        return (1 - t) * a + t * b;
    return b;
}

static void draw_beam(vector a, vector b, int effect) {
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, effect);
    WriteEntity(MSG_MULTICAST, world);
    WriteCoord(MSG_MULTICAST, a_x);
    WriteCoord(MSG_MULTICAST, a_y);
    WriteCoord(MSG_MULTICAST, a_z);
    WriteCoord(MSG_MULTICAST, b_x);
    WriteCoord(MSG_MULTICAST, b_y);
    WriteCoord(MSG_MULTICAST, b_z);
    multicast(a, MULTICAST_PHS);
}

void W_FireImpeller() {
    FO_Sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);

    float rewound = RewindPlayersExceptSelf(0);

    if (!cb_prematch)
        self.special_next = time + 3;

    vector org = self.origin + '0 0 16';
    float direct = FALSE;
    entity hit = FindImpellerTarget(org, 0.985, &direct);

    if (rewound)
        FOPlayer::RestoreAll();

    float mag = 250;
    vector end;

    if (hit == world) {
        traceline(org, org + 350 * v_forward, MOVE_WORLDONLY, world);
        if (trace_fraction == 1)
            return;

        end = trace_endpos;
        hit = self;
        draw_beam(org, end, TE_LIGHTNING2);
    } else {
        if (direct) {
            end = hit.origin;
            draw_beam(org, end, TE_LIGHTNING2);
        } else {
            vector a = org, b = org + kImpellerTargetRange * v_forward;
            traceline(a, b, MOVE_WORLDONLY, world);
            end = trace_endpos;
            vector x = find_closest(a, end, hit.origin);

            draw_beam(a, x, TE_LIGHTNING2);
            draw_beam(x, hit.origin, TE_LIGHTNING2);

            // Discount knockback by help given
            mag -= max(10, vlen(hit.origin - x));
        }

        end = hit.origin;
    }

    deathmsg = DMSG_IMPELLER;
    TF_T_Damage(hit, self, self, 5, TF_TD_NOTTEAM, TF_TD_ELECTRICITY | TF_TD_NOMOMENTUM);
    hit.flags &= ~FL_ONGROUND;
    if (hit.has_flag)
        mag *= 2;
    hit.velocity -= mag * normalize(end - org);
}

void () W_FireRailgun = {
    local vector vec, org;

    self.ammo_nails = self.ammo_nails - 1;

    makevectors(self.v_angle);
    org = self.origin + v_forward * 8;
    vec = aim(self, 10000);
    vec = normalize(vec);

    entity proj = FOProj_Create(FPP_RAILGUN);
    proj.owner = self;
    proj.enemy = self;
    proj.movetype = MOVETYPE_FLYMISSILE;
    proj.solid = SOLID_TRIGGER;


    proj.velocity = vec * FPP_Get(FPP_RAILGUN)->speed;
    proj.angles = vectoangles(proj.velocity);

    proj.nextthink = time + 5;
    proj.think = SUB_Remove;
    proj.touch = LaserBolt_Touch;
    proj.classname = "railslug";
    setorigin(proj, org + '0 0 16');

    FOProj_Finalize(proj);
};

void () EMPExplode = {
    local float expsize;

    expsize = 10;
    if (self.touch == weapon_touch) {
        expsize = 60;
    } else if (self.classname == "item_shells") {
        expsize = 50 + self.aflag;
    } else if (self.classname == "item_spikes") {
        expsize = 40;
    } else if (self.classname == "item_rockets") {
        expsize = 100 + self.aflag * 4;
    } else if (self.classname == "item_cells") {
        expsize = 100 + self.aflag * 3;
    } else if (self.classname == "item_weapon") {
        expsize = 60;
    } else {
        dprint("EMPExplode: Attempting to explode a ");
        dprint(self.classname);
        dprint("\n");
        return;
    }
    deathmsg = DMSG_GREN_EMP_AMMO;
    T_RadiusDamage(self, self.enemy, expsize, world);

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    Respawn_Item(self, self.enemy);
};

void () EMPGrenadeTouch = {
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0') {
        self.avelocity = '0 0 0';
    }
};

void () EMPGrenadeExplode = {
    local float expsize;
    local entity te, te2;
    local entity oldself;
    local float candamage, empblockinrange;
    empblockinrange = FALSE;

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_TAREXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    te2 = find(world, classname, "info_empblock");
    while(te2) {
        //bprint(PRINT_HIGH, "Found EMP Block at ", vtos(te2.origin), " with radius ", ftos(te2.t_length), "\n");
        //bprint(PRINT_HIGH, "Block is ", ftos(vlen(te2.origin - self.origin)), " units away\n");
        if(vlen(te2.origin - self.origin) <= te2.t_length) {
            if(te2.goal_effects & 16) {
                traceline(self.origin, te2.origin, 0, self);
                //bprint(PRINT_HIGH, "Block wall check is ", ftos(trace_fraction), "\n");
                if (trace_fraction == 1) {
                    empblockinrange = TRUE;
                    break;
                }
           } else {
                empblockinrange = TRUE;
                break;
            }
        }
        te2 = find(te2, classname, "info_empblock");
    }
   
    te = findradius(self.origin, PC_ENGINEER_GRENADE_TYPE_2_RANGE);
    while (te) {
        te.chain2 = te.chain;
        candamage = TRUE;
        if(walls_block_emp || empblockinrange)
            candamage = CanDamage(te, self);
        traceline(self.origin, te.origin, MOVE_NOMONSTERS, self);
        if(trace_ent && trace_ent.spawnflags & SPAWNFLAG_BLOCK_EMP) {
            candamage = FALSE;
        }
        if(candamage) {
            if ((te.touch == ammo_touch) || (te.touch == weapon_touch)) {
                if (te.classname != "item_spikes") {
                    te.solid = SOLID_NOT;
                    te.enemy = self.owner;
                    te.nextthink = time + 1 + random() * 2;
                    te.think = EMPExplode;
                }
            } else if (te.think == TeamFortress_DetpackExplode) {
                te.solid = SOLID_NOT;
                te.nextthink = time + 1 + random() * 2;
                dremove(te.oldenemy);
            } else if (te.classname == "pipebomb") {
                te.nextthink = time + 0.1;
            } else if ((te.classname == "building_dispenser") ||
                       (te.classname == "building_sentrygun")) {
                if (!
                    (((teamplay & 16) && (te.team_no > 0)) &&
                     (te.team_no == self.owner.team_no))) {
                    TF_T_Damage(te, self, self.owner, 200, 0, TF_TD_EXPLOSION);
                }
            } else if (te.classname == "ammobox") {
                expsize = 0;
                expsize = expsize + te.ammo_shells * 0.75;
                expsize = expsize + te.ammo_rockets * 0.75 * 2;
                expsize = expsize + te.ammo_cells * 0.75 * 2;
                if (expsize > 0) {
                    te.solid = 0;
                    deathmsg = 30;
                    T_RadiusDamage(te, self.owner, expsize, te);
                    te.think = SUB_Remove;
                    te.nextthink = time + 0.1;
                    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
                    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
                    WriteCoord(MSG_MULTICAST, te.origin_x);
                    WriteCoord(MSG_MULTICAST, te.origin_y);
                    WriteCoord(MSG_MULTICAST, te.origin_z);
                    multicast(te.origin, MULTICAST_PHS);
                }
            } else if ((te.classname == "player") ||
                       (te.touch == BackpackTouch)) {
                if (!
                    ((teamplay & 16) && (te.team_no > 0) &&
                     (te.team_no == self.owner.team_no))) {
                    expsize = 0;

                    if (new_emp)
                    {
                        // we assume player has discarded non-needed ammo for damage calcs
                        expsize = expsize + te.maxammo_shells * .75;
                        expsize = expsize + te.maxammo_rockets * .75 * 2;
                        expsize = expsize + te.maxammo_cells * 0.75;

                        // remove discard ammo amount
                        switch (te.playerclass)
                        {
                            case PC_SCOUT:
                                expsize = expsize - te.maxammo_rockets * .75 * 2;
                                break;
                            case PC_MEDIC:
                                expsize = expsize - te.maxammo_rockets * .75 * 2;
                                break;
                            case PC_SNIPER:
                            case PC_SPY:
                            case PC_ENGINEER:
                                expsize = expsize - te.maxammo_rockets * .75 * 2;
                                expsize = expsize - te.maxammo_cells * .75;
                                break;
                            case PC_SOLDIER:
                            case PC_DEMOMAN:
                                expsize = expsize - te.maxammo_cells * .75;
                                break;
                            case PC_HVYWEAP:
                                expsize = expsize - te.maxammo_rockets * .75 * 2;
                                break;
                            default:
                        }
                    }
                    else
                    {
                        expsize = expsize + te.ammo_shells * 0.75;
                        expsize = expsize + te.ammo_rockets * 0.75 * 2;
                        if (te.playerclass != PC_ENGINEER) {
                            expsize = expsize + te.ammo_cells * 0.75;
                        }    
                    }
                    
                    
                    if (expsize > 0) {
                        deathmsg = DMSG_GREN_EMP;
                        T_RadiusDamage(te, self.owner, expsize, te);
                        if (te.touch != BackpackTouch) {
                            TF_T_Damage(te, self, self.owner, expsize, 2, 4);
                            te.ammo_shells = ceil(te.ammo_shells * 0.25);
                            te.ammo_rockets = ceil(te.ammo_rockets * 0.25);
                            if (te.playerclass != PC_ENGINEER) {
                                te.ammo_cells = ceil(te.ammo_cells * 0.25);
                            }
                            oldself = self;
                            self = te;
                            self = oldself;
                        } else {
                            te.think = SUB_Remove;
                            te.nextthink = time + 0.1;
                        }
                        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
                        WriteByte(MSG_MULTICAST, TE_EXPLOSION);
                        WriteCoord(MSG_MULTICAST, te.origin_x);
                        WriteCoord(MSG_MULTICAST, te.origin_y);
                        WriteCoord(MSG_MULTICAST, te.origin_z);
                        multicast(te.origin, MULTICAST_PHS);
                    }
                }
            }
        }
        te = te.chain2;
    }
    dremove(self);
};

entity () FO_FindCurrentBuildingObject = {
    local entity te;
    te = find(world, netname, "build_timer");
    while (te) {
        if (te.owner == self || (engineer_move && te.real_owner == self)) {
            return te;
        } else {
            te = find(te, netname, "build_timer");
        }
    }
    return world;
}

void () FO_Engineer_ToggleDispenser = {
    if (self.has_dispenser) {
        DestroyBuilding(self, "building_dispenser");
    } else {
        if (self.health <= 0) {
            sprint(self, PRINT_HIGH, "Can't build while dead.\n");
        } else {
            Menu_Engineer_Input(2);
        }
    }
}

void () FO_Engineer_ToggleSentry = {
    if (self.has_sentry) {
        Menu_Engineer_Input(3);
    } else {
        if (self.health <= 0) {
            sprint(self, PRINT_HIGH, "Can't build while dead.\n");
        } else {
            Menu_Engineer_Input(1);
        }
    }
}

void () TeamFortress_EngineerBuild = {
    if (!self.is_building) {
        if (((self.ammo_cells < 100) && !self.has_dispenser) &&
            !self.has_sentry) {
            Status_Print(self, "\n\n\n\n\n\n\n", "Not enough metal to build anything");
            return;
        }
        Menu_Engineer(self);
    } else if (self.is_building) {
        TeamFortress_EngineerBuildStop();
    }
};

void () TeamFortress_EngineerBuildStop = {
    local entity te;
    local vector dist;

    te = FO_FindCurrentBuildingObject();
    if (te != world) {
        dist = self.origin - te.origin;
        if (vlen(dist) > 128) {
            sprint(self, PRINT_HIGH, "Your building disappeared\n");
            WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
            WriteByte(MSG_MULTICAST, TE_EXPLOSION);
            WriteCoord(MSG_MULTICAST, te.origin_x);
            WriteCoord(MSG_MULTICAST, te.origin_y);
            WriteCoord(MSG_MULTICAST, te.origin_z);
            multicast(te.origin, MULTICAST_PHS);
        } else {
            sprint(self, PRINT_HIGH, "You stop building\n");
        }
        if (engineer_move) {
            if (te.classname == "building_sentrygun")
                self.has_sentry = 0;
            else if (te.classname == "building_dispenser")
                self.has_dispenser = 0;
        }
        dremove(te);
        te = world;

    }

    Menu_Close(self);
    self.is_building = FALSE;
    self.building_percentage = 0;
    if (!engineer_move) {
        self.tfstate &= ~(TFSTATE_CANT_MOVE | TFSTATE_NO_WEAPON);
        self.movetype = MOVETYPE_WALK;
    }
}

void (float objtobuild, float offset) TeamFortress_Build = {
    if (cb_prematch) {
        sprint(self, PRINT_MEDIUM, "You cannot build during prematch\n");
        return;
    }

    if(no_fire_mode) {
        sprint(self, PRINT_MEDIUM, "You cannot build right now\n");
        return;
    }

    local float btime;
    local vector tmp1;
    local vector tmp2;
    local entity oldmis;
    btime = 0;
    tmp1 = '0 0 0';
    tmp2 = '0 0 0';

    newmis = spawn();

    makevectors(self.v_angle);
    /* v_forward_z = 0; */
    /* v_forward = normalize(v_forward) * 64; */
    /* newmis.origin = self.origin + v_forward; */

    local vector v_forward_sentry;
    v_forward_sentry.z = (normalize(v_forward) * 64).z;
    v_forward_z = 0;
    local vector xy_pos = normalize(v_forward) * 64;
    v_forward_sentry.x = xy_pos.x;
    v_forward_sentry.y = xy_pos.y;

    newmis.origin = self.origin + v_forward_sentry;

    tmp1 = newmis.origin;
    tmp2 = newmis.origin - normalize(v_up) * 128;
    traceline(tmp1, tmp2, 1, world);
    if (trace_ent != world) {
        sprint(self, PRINT_HIGH, "You can't build here\n");
        dremove(newmis);
        return;
    }

    tmp1 = self.origin;
    tmp2 = self.origin - normalize(v_up) * 128;
    traceline(tmp1, tmp2, 1, world);
    if (trace_ent != world) {
        sprint(self, PRINT_HIGH, "You can only build while standing on solid ground\n");
        dremove(newmis);
        return;
    }

    if (objtobuild == BUILD_DISPENSER) {
        if (self.has_dispenser) {
            sprint(self, PRINT_HIGH, "You can only have one dispenser\n");
            dremove(newmis);
            return;
        }
        tmp1 = '-16 -16 0';
        tmp2 = '16 16 48';
        newmis.mdl = "progs/disp.mdl";
        newmis.netname = "dispenser";
        btime = time + 2;
        self.dispenser_ticks = 0;
    } else if (objtobuild == BUILD_SENTRYGUN) {
        if (self.has_sentry) {
            sprint(self, PRINT_HIGH, "You can only have one sentry gun\n");
            dremove(newmis);
            return;
        }
        tmp1 = '-16 -16 0';
        tmp2 = '16 16 48';
        newmis.mdl = "progs/turrbase.mdl";
        newmis.netname = "sentrygun";
        btime = time + 5;
        self.sentry_ticks = 0;
    }

    if (!CheckArea(newmis, 0)) {
        sprint(self, PRINT_HIGH, "You can't build here\n");
        dremove(newmis);
        return;
    }
    if (!(self.flags & FL_ONGROUND)) {
        if (!build_water && self.waterlevel) {
            sprint(self, PRINT_HIGH, "You cannot build in the water\n");
            dremove(newmis);
            return;
        }
    }

    UpdateClientBuilding(self);
    self.is_building = objtobuild;
    if (!engineer_move) {
        self.immune_to_check = time + 5;
        self.tfstate |= TFSTATE_CANT_MOVE | TFSTATE_NO_WEAPON;
        self.movetype = MOVETYPE_NONE;

        Menu_Engineer_Cancel();
    }

    newmis.owner = self;
    newmis.classname = "timer";
    newmis.netname = "build_timer";
    newmis.nextthink = btime;
    newmis.think = TeamFortress_FinishedBuilding;
    newmis.colormap = self.colormap;
    newmis.weapon = objtobuild;
    newmis.angles_y = anglemod(self.angles_y + 180 + offset);
    newmis.velocity = '0 0 8';
    newmis.movetype = 6;
    newmis.solid = 2;
    FO_SetModel(newmis, newmis.mdl);
    setsize(newmis, tmp1, tmp2);
    setorigin(newmis, newmis.origin);
    newmis.flags = newmis.flags - (newmis.flags & 512);

    if (engineer_move) {
        newmis.owner = world;
        newmis.real_owner = self;
        newmis.health = 50;
        newmis.team_no = self.team_no;
        newmis.max_health = newmis.health;
        newmis.takedamage = DAMAGE_AIM;
        if (objtobuild == BUILD_DISPENSER) {
            self.has_dispenser = TRUE;
            newmis.th_die = Dispenser_Die;
            self.ammo_cells = self.ammo_cells - ENG_DISPENSER_COST;
            newmis.classname = "building_dispenser";
        }
        if (objtobuild == BUILD_SENTRYGUN) {
            self.sentry_ent = newmis;
            self.has_sentry = TRUE;
            newmis.th_die = Sentry_Die;
            newmis.th_pain = Sentry_Pain;
            newmis.takedamage = DAMAGE_AIM;
            self.ammo_cells = self.ammo_cells - ENG_SENTRY_COST;
            newmis.classname = "building_sentrygun";
            newmis.weapon = 0;
        }
    }

    oldmis = newmis;
    newmis = spawn();
    newmis.owner = self;
    newmis.enemy = oldmis;
    newmis.classname = "timer";
    newmis.netname = "buildcheck_timer";
    newmis.nextthink = time + 0.3;
    newmis.think = CF_CheckBuilding;
    Status_Refresh(self);
};

void () CF_CheckBuilding = {
    local float max_dist = BUILD_SENTRYGUN_MAX_DISTANCE;
    local vector dist;
    local entity timer = self;
    local entity building = self.enemy;
    self = self.owner;

    if (!self.is_building) {
        dremove(timer);
        return;
    }

    if (!engineer_move) {
        dist = self.origin - building.origin;
        if (vlen(dist) > max_dist) {
            TeamFortress_EngineerBuildStop();
            dremove(timer);
            return;
        }
    }

    if (building.weapon == 2 || building.weapon == 0) {
        self.sentry_ticks = self.sentry_ticks + 0.3;
        self.building_percentage = ceil((self.sentry_ticks / 5) * 100);
    } else if (building.weapon == 1) {
        self.dispenser_ticks = self.dispenser_ticks + 0.3;
        self.building_percentage = ceil((self.dispenser_ticks / 2) * 100);
    }

    Status_Refresh(self);

    timer.nextthink = time + 0.3;
};

void (entity bld) CheckBelowBuilding = {
    local vector below;

    below = bld.origin;
    if (bld.classname == "detpack") {
        below_z = below_z - 8;
    } else {
        below_z = below_z - 24;
    }
    traceline(bld.origin, below, 1, bld);
    if (trace_fraction == 1) {
        bld.movetype = 6;
        bld.flags = bld.flags - (bld.flags & 512);
    }
};

void (entity disp) Dispenser_AmmoTick = {
    local float rate;

    // set restock rate (scales with players on team)
    rate = 1 + 0.5 * (TeamFortress_TeamGetNoPlayers(disp.team_no) - 1);

    if ((old_dispenser && self.disptimer > 23) || (!old_dispenser && self.disptimer > 3)) {
        if (old_dispenser) {
            self.ammo_shells = self.ammo_shells + rint(BUILD_DISPENSER_MAX_SHELLS / 20);
            self.ammo_cells = self.ammo_cells + rint(BUILD_DISPENSER_MAX_CELLS / 20);
            self.ammo_nails = self.ammo_nails + rint(BUILD_DISPENSER_MAX_NAILS / 20);
            self.ammo_rockets = self.ammo_rockets + rint(BUILD_DISPENSER_MAX_ROCKETS / 20);
            self.armorvalue = self.armorvalue + rint(BUILD_DISPENSER_MAX_ARMOR / 20);
        } else {
            self.ammo_shells = self.ammo_shells + rint(BUILD_DISPENSER_MAX_SHELLS * rate / 225);
            self.ammo_cells = self.ammo_cells + rint(BUILD_DISPENSER_MAX_CELLS * rate / 225);
            self.ammo_nails = self.ammo_nails + rint(BUILD_DISPENSER_MAX_NAILS * rate / 225);
            self.ammo_rockets = self.ammo_rockets + rint(BUILD_DISPENSER_MAX_ROCKETS * rate / 225);
            self.armorvalue = self.armorvalue + rint(BUILD_DISPENSER_MAX_ARMOR * rate / 225);
        }

        if (self.ammo_shells > BUILD_DISPENSER_MAX_SHELLS)
            self.ammo_shells = BUILD_DISPENSER_MAX_SHELLS;
        if (self.ammo_nails > BUILD_DISPENSER_MAX_NAILS)
            self.ammo_nails = BUILD_DISPENSER_MAX_NAILS;
        if (self.ammo_rockets > BUILD_DISPENSER_MAX_ROCKETS)
            self.ammo_rockets = BUILD_DISPENSER_MAX_ROCKETS;
        if (self.ammo_cells > BUILD_DISPENSER_MAX_CELLS)
            self.ammo_cells = BUILD_DISPENSER_MAX_CELLS;
        if (self.armorvalue > BUILD_DISPENSER_MAX_ARMOR)
            self.armorvalue = BUILD_DISPENSER_MAX_ARMOR;

        self.disptimer = 0;
    }

    self.disptimer = self.disptimer + 1;
}

float (entity disp, entity pl) Dispenser_GiveShells = {
    local float ammo;

    if (!pl.need_shells)
        return 0;

    ammo = (pl.maxammo_shells * pl.deff) / 7;

    if (ammo > disp.ammo_shells)
        ammo = disp.ammo_shells;

    if ((ammo + pl.ammo_shells) > pl.maxammo_shells)
        ammo = pl.maxammo_shells - pl.ammo_shells;

    disp.ammo_shells = disp.ammo_shells - ammo;
    pl.ammo_shells = pl.ammo_shells + ammo;

    return ammo;
}

float (entity disp, entity pl) Dispenser_GiveNails = {
    local float ammo;

    if (!pl.need_nails)
        return 0;

    ammo = (pl.maxammo_nails * pl.deff) / 7;

    if (ammo > disp.ammo_nails)
        ammo = disp.ammo_nails;

    if ((ammo + pl.ammo_nails) > pl.maxammo_nails)
        ammo = pl.maxammo_nails - pl.ammo_nails;

    disp.ammo_nails = disp.ammo_nails - ammo;
    pl.ammo_nails = pl.ammo_nails + ammo;

    return ammo;
}

float (entity disp, entity pl) Dispenser_GiveRockets = {
    local float ammo;

    if (!pl.need_rockets)
        return 0;

    ammo = (pl.maxammo_rockets * pl.deff) / 7;

    if (ammo > disp.ammo_rockets)
        ammo = disp.ammo_rockets;

    if ((ammo + pl.ammo_rockets) > pl.maxammo_rockets)
        ammo = pl.maxammo_rockets - pl.ammo_rockets;

    disp.ammo_rockets = disp.ammo_rockets - ammo;
    pl.ammo_rockets = pl.ammo_rockets + ammo;

    return ammo;
}

float (entity disp, entity pl) Dispenser_GiveCells = {
    local float ammo;

    if (!pl.need_cells)
        return 0;

    ammo = (pl.maxammo_cells * pl.deff) / 7;

    if (ammo > disp.ammo_cells)
        ammo = disp.ammo_cells;

    if ((ammo + pl.ammo_cells) > pl.maxammo_cells)
        ammo = pl.maxammo_cells - pl.ammo_cells;

    disp.ammo_cells = disp.ammo_cells - ammo;
    pl.ammo_cells = pl.ammo_cells + ammo;

    return ammo;
}

float (entity disp, entity pl) Dispenser_GiveArmor = {
    local float armor;

    armor = (pl.maxarmor * pl.deff) / 7;

    pl.armortype = pl.armor_allowed;

    if (armor > disp.armorvalue)
        armor = disp.armorvalue;

    if ((armor + pl.armorvalue) > pl.maxarmor)
        armor = pl.maxarmor - pl.armorvalue;

    disp.armorvalue = disp.armorvalue - armor;
    pl.armorvalue = pl.armorvalue + armor;

    return armor;
}

void (entity disp, entity pl) Dispenser_StockPlayer = {
    local float shells, nails, rockets, cells, armor;

    // 10 second cooldown for engineers who recently used the dispenser
    if ((time - pl.dimmune) < 10)
        return;

    // reset dispenser efficiency if >1.2 second has passed since last dispenser use
    if ((time - pl.duse) > 1.2)
        pl.deff = 0;

    // set dispenser efficiency (increase with time => just passing by gives less ammo/armor)
    if (!pl.deff || pl.deff >= 4)
        pl.deff = 0.5;
    else
        pl.deff = pl.deff * 2;

    // give engineers full armor/ammo instantly
    if (pl.playerclass == PC_ENGINEER) {
        pl.dimmune = time;
        pl.deff = 7;
    }

    shells = Dispenser_GiveShells(disp, pl);
    nails = Dispenser_GiveNails(disp, pl);
    rockets = Dispenser_GiveRockets(disp, pl);
    cells = Dispenser_GiveCells(disp, pl);
    armor = Dispenser_GiveArmor(disp, pl);

    // only play dispenser restock sound if something was given
    if ((shells + nails + rockets + cells + armor) > 0)
        FO_Sound(pl, CHAN_ITEM, "items/r_item1.wav", 0.7, 1);

    pl.duse = time;
};

void (entity disp) Dispenser_FindPlayers = {
    local entity te = findradius(disp.origin, 60);
    while (te != world) {
        if (te.classname == "player" && te.team_no == disp.team_no)
            Dispenser_StockPlayer(disp, te);
        te = te.chain;
    }
}

void () DispenserThink = {
    CheckBelowBuilding(self);
    Dispenser_AmmoTick(self);

    if (!old_dispenser)
        Dispenser_FindPlayers(self);

    self.nextthink = time + 0.3;
};

void UpdateClient_Sentry(entity pl, entity sent) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_SENTRY_POS);
    WriteFloat(MSG_MULTICAST, sent.origin.x);
    WriteFloat(MSG_MULTICAST, sent.origin.y);
    WriteFloat(MSG_MULTICAST, sent.origin.z);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void UpdateClient_Dispenser(entity pl, entity disp) = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_DISPENSER_POS);
    WriteFloat(MSG_MULTICAST, disp.origin.x);
    WriteFloat(MSG_MULTICAST, disp.origin.y);
    WriteFloat(MSG_MULTICAST, disp.origin.z);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void () TeamFortress_FinishedBuilding = {
    local entity oldself;    
    if (engineer_move) {
        if (!self.real_owner.is_building) {
            return;
        }
    }
    else {
        if (!self.owner.is_building) {
            return;
        }
    }
    if (engineer_move)
        self.owner = self.real_owner;
    
    local float csqcactive = infokeyf(self.owner, INFOKEY_P_CSQCACTIVE);
    
    oldself = self;
    self = self.owner;
    oldself.owner = world;
    oldself.real_owner = self;
    self.is_building = FALSE;
    self.building_percentage = 0;
    if (!engineer_move) {
        self.tfstate &= ~(TFSTATE_CANT_MOVE | TFSTATE_NO_WEAPON);
        self.movetype = MOVETYPE_WALK;
    }
    Status_Refresh(self);

    Menu_Close(self);
    if (oldself.weapon == 1) {
        self.has_dispenser = TRUE;
        sprint(self, PRINT_HIGH, "You finish building the dispenser\n");
        teamsprint(self.team_no, self, self.netname);
        teamsprint(self.team_no, self, " has built a dispenser\n");
        if (!engineer_move)
            self.ammo_cells = self.ammo_cells - ENG_DISPENSER_COST;
        oldself.classname = "building_dispenser";
        oldself.netname = "dispenser";
        oldself.blocked = T_Dispenser;
        oldself.touch = T_Dispenser;
        oldself.max_health = 150;
        oldself.health = 150;
        oldself.disptimer = 1;
        oldself.think = DispenserThink;
        oldself.nextthink = time + 0.3;
        oldself.th_die = Dispenser_Die;
        oldself.mdl = "progs/disp.mdl";
        oldself.team_no = self.team_no;
        oldself.real_owner = self;
        oldself.colormap = self.colormap;
        oldself.takedamage = DAMAGE_AIM;
        oldself.owner = world;
        oldself.movetype = MOVETYPE_TOSS;
        oldself.velocity = '0 0 8';
        oldself.flags = oldself.flags - (oldself.flags & 512);
        oldself.ammo_shells = ceil(self.ammo_shells * 0.25);
        oldself.ammo_nails = ceil(self.ammo_nails * 0.25);
        oldself.ammo_rockets = ceil(self.ammo_rockets * 0.25);
        oldself.ammo_cells = ceil(self.ammo_cells * 0.25);
        oldself.armorvalue = ceil(self.armorvalue * 0.25);
        self.ammo_shells = ceil(self.ammo_shells * 0.75);
        self.ammo_nails = ceil(self.ammo_nails * 0.75);
        self.ammo_rockets = ceil(self.ammo_rockets * 0.75);
        self.ammo_cells = ceil(self.ammo_cells * 0.75);
        self.armorvalue = ceil(self.armorvalue * 0.75);
        oldself.solid = SOLID_BBOX;
        FO_SetModel(oldself, oldself.mdl);
        setsize(oldself, '-8 -8 0', '8 8 24');
        setorigin(oldself, (oldself.origin + '0 0 8'));
        if(csqcactive) {
            UpdateClient_Dispenser(self, oldself);
        }
    } else if (oldself.weapon == 2 || (engineer_move && oldself.weapon == 0)) {
        self.has_sentry = TRUE;
        sprint(self, PRINT_HIGH, "You finish building the sentry gun\n");
        teamsprint(self.team_no, self, self.netname);
        teamsprint(self.team_no, self, " has built a sentry gun\n");
        oldself.classname = "building_sentrygun_base";
        oldself.netname = "sentry gun";
        oldself.takedamage = DAMAGE_NO;
        oldself.th_die = Sentry_Die;
        oldself.team_no = self.team_no;        
        oldself.nextthink = time + .1;
        if (!engineer_move)
            self.ammo_cells = self.ammo_cells - ENG_SENTRY_COST;
        setsize(oldself, '-16 -16 0', '16 16 4');
        newmis = spawn();
        newmis.classname = "building_sentrygun";
        newmis.health = 150;
        newmis.max_health = newmis.health;
        newmis.weapon = 1;
        newmis.th_die = Sentry_Die;
        newmis.th_pain = Sentry_Pain;
        newmis.mdl = "progs/turrgun.mdl";
        newmis.dimension_ghost = DMN_GHOST;
        newmis.dimension_ghost_alpha = 0.25;
        self.sentry_ent = newmis;
        FO_Sound(oldself, CHAN_ITEM, "weapons/turrset.wav", 1, 1);
        newmis.solid = SOLID_BBOX;
        FO_SetModel(newmis, newmis.mdl);
        setsize(newmis, '-16 -16 0', '16 16 48');
        setorigin(newmis, oldself.origin + '0 0 8');
        newmis.view_ofs = '0 0 22';
        newmis.real_owner = oldself.real_owner;
        newmis.trigger_field = oldself;
        oldself.oldenemy = newmis;
        newmis.movetype = MOVETYPE_STEP;
        oldself.colormap = self.colormap;
        newmis.colormap = self.colormap;
        newmis.takedamage = DAMAGE_AIM;
        newmis.velocity = '0 0 -8';
        newmis.flags = newmis.flags - (newmis.flags & 512);
        oldself.flags = oldself.flags - (oldself.flags & 512);
        newmis.team_no = self.team_no;
        newmis.think = lvl1_sentry_stand;
        newmis.nextthink = time + 0.5;
        newmis.yaw_speed = 10;
        newmis.heat = 0;
        newmis.angles_x = 0;
        newmis.angles_y = rint(oldself.angles_y);
        newmis.angles_z = 0;
        newmis.waitmin = rint(newmis.angles_y - 50);
        newmis.waitmin = anglemod(newmis.waitmin);
        newmis.waitmax = rint(newmis.angles_y + 50);
        newmis.waitmax = anglemod(newmis.waitmax);
        if (newmis.waitmin > newmis.waitmax) {
            newmis.waitmin = newmis.waitmax;
            newmis.waitmax = anglemod(newmis.angles_y - 50);
        }
        newmis.ammo_shells = 25;
        newmis.maxammo_shells = 100;
        newmis.maxammo_rockets = 20;
        if(csqcactive) {
            UpdateClient_Sentry(self, oldself);
        }
    }
    self = oldself;
};

void () T_Dispenser = {
    local entity oldself;
    local entity dist_checker;

    if (other == world)
        return;

    // don't show menu to players of same team (if new dispenser behaviour)
    if (!old_dispenser && (other.classname != "player" || other.team_no == self.team_no || !other.team_no))
        return;

    if (other.team_no && other.team_no != self.team_no)
        Status_Print(self.real_owner, "\n\n\n", "Enemies are using your dispenser!");

    if ((other.building == world) && (other.building_wait < time)) {
        other.building = self;
        if(!infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
            dist_checker = spawn();
            dist_checker.classname = "timer";
            dist_checker.owner = other;
            dist_checker.enemy = self;
            dist_checker.think = CheckDistance;
            dist_checker.nextthink = time + 0.3;
        }
        oldself = self;
        self = other;
        Menu_Dispenser();
        self = oldself;
    }
};

void () Dispenser_Explode = {
    local float sdmg;

    if (self.real_owner.has_disconnected != 1) {
        deathmsg = DMSG_DISPENSER_EXPLODE;
        sdmg = 25 + self.ammo_rockets * 3 + self.ammo_cells;
        if (sdmg > 250) {
            sdmg = 250;
        }
        T_RadiusDamage(self, self.real_owner, sdmg, self);
    }
    ThrowGib("progs/dgib1.mdl", -30);
    ThrowGib("progs/dgib2.mdl", -50);
    ThrowGib("progs/dgib3.mdl", -50);
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);
    BecomeExplosion();
};

void () Dispenser_Die = {
    sprint(self.real_owner, PRINT_HIGH, "Your dispenser was destroyed\n");
    self.real_owner.has_dispenser = 0;
    self.think = Dispenser_Explode;
    self.nextthink = time + 0.1;
    if (self.real_owner.is_building == BUILD_DISPENSER) {
        self = self.real_owner;
        TeamFortress_EngineerBuildStop();
    }
};

void (entity disp) Engineer_UseDispenser = {
    local entity dist_checker;
    // engineer hits enemy dispenser - dismantle
    if(!(disp.team_no > 0 && disp.team_no == self.team_no)) {
        self.ammo_cells = self.ammo_cells + 50;
        disp.real_owner.has_dispenser = 0;
        bprint(PRINT_HIGH, self.netname, " dismantled ", disp.real_owner.netname, "'s dispenser\n");
        TF_AddFrags(self, 1);
        sprint(disp.real_owner, PRINT_HIGH, "Your dispenser was dismantled by ",self.netname,"\n");
        dremove (disp);
        ThrowGib("progs/dgib1.mdl", -30);
        ThrowGib("progs/dgib2.mdl", -50);
        ThrowGib("progs/dgib3.mdl", -50);
        return;
    }

    if (self.team_no == disp.team_no) {
        if (disp.real_owner.is_building) {
            sprint (self, PRINT_HIGH, strcat("You stopped building a dispenser and got ", ftos(ENG_DISPENSER_COST), " cells back\n"));
            self.ammo_cells = self.ammo_cells + ENG_DISPENSER_COST;
            if (self.ammo_cells > self.maxammo_cells)
                self.ammo_cells = self.maxammo_cells;
            self = disp.real_owner;
            TeamFortress_EngineerBuildStop();
            return;
        }
    }

    if (disp.health < disp.max_health && !old_spanner) {
        Engineer_Dispenser_Repair(disp);
        return;
    }

    sprint(self, PRINT_HIGH, "Dispenser has ", ftos(disp.health), " health and current stock:\n");
    sprint(self, PRINT_HIGH, ftos(disp.ammo_shells),      " shells, ");
    sprint(self, PRINT_HIGH, ftos(disp.ammo_nails),       " nails, ");
    sprint(self, PRINT_HIGH, ftos(disp.ammo_rockets),     " rockets, ");
    sprint(self, PRINT_HIGH, ftos(disp.ammo_cells),       " cells and ");
    sprint(self, PRINT_HIGH, ftos(floor(disp.armorvalue)), " armor\n");

    if ((!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells)
                || (disp.ammo_shells == BUILD_DISPENSER_MAX_SHELLS && disp.ammo_nails == BUILD_DISPENSER_MAX_NAILS
                &&  disp.ammo_rockets == BUILD_DISPENSER_MAX_ROCKETS && disp.ammo_cells == BUILD_DISPENSER_MAX_CELLS))
                && (!self.armorvalue || disp.armorvalue == BUILD_DISPENSER_MAX_ARMOR)) {
        Status_Print(self, "\n\n\n\n\n\n\n", "There's nothing to do");
        return;
    }

    self.building = disp;
    Menu_EngineerFix_Dispenser();
    if(!infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        dist_checker = spawn();
        dist_checker.classname = "timer";
        dist_checker.owner = self;
        dist_checker.enemy = disp;
        dist_checker.think = CheckDistance;
        dist_checker.nextthink = time + 0.3;
    }
};

void (entity disp) Engineer_Dispenser_InsertAmmo = {
    local float shells, nails, rockets, cells;

    shells = 40;
    if (shells > self.ammo_shells)
        shells = self.ammo_shells;
    if (shells > (BUILD_DISPENSER_MAX_SHELLS - disp.ammo_shells))
        shells = (BUILD_DISPENSER_MAX_SHELLS - disp.ammo_shells);
    self.ammo_shells = (self.ammo_shells - shells);
    disp.ammo_shells = (disp.ammo_shells + shells);

    nails = 40;
    if (nails > self.ammo_nails)
        nails = self.ammo_nails;
    if (nails > (BUILD_DISPENSER_MAX_NAILS - disp.ammo_nails))
        nails = (BUILD_DISPENSER_MAX_NAILS - disp.ammo_nails);
    self.ammo_nails = (self.ammo_nails - nails);
    disp.ammo_nails = (disp.ammo_nails + nails);

    rockets = 20;
    if (rockets > self.ammo_rockets)
        rockets = self.ammo_rockets;
    if (rockets > (BUILD_DISPENSER_MAX_ROCKETS - disp.ammo_rockets))
        rockets = (BUILD_DISPENSER_MAX_ROCKETS - disp.ammo_rockets);
    self.ammo_rockets = (self.ammo_rockets - rockets);
    disp.ammo_rockets = (disp.ammo_rockets + rockets);

    cells = 20;
    if (cells > self.ammo_cells)
        cells = self.ammo_cells;
    if (cells > (BUILD_DISPENSER_MAX_CELLS - disp.ammo_cells))
        cells = (BUILD_DISPENSER_MAX_CELLS - disp.ammo_cells);
    self.ammo_cells = (self.ammo_cells - cells);
    disp.ammo_cells = (disp.ammo_cells + cells);

    if ((shells + nails + rockets + cells) > 0) {
        sprint(self, PRINT_HIGH, "You insert ");
        if (shells > 0)
            sprint(self, PRINT_HIGH, ftos(shells), " shells");
        if (nails > 0) {
            if (shells > 0 && (rockets > 0 || cells > 0))
                sprint(self, PRINT_HIGH, ", ");
            else if (shells > 0)
                sprint(self, PRINT_HIGH, " and ");
            sprint(self, PRINT_HIGH, ftos(nails), " nails");
        }
        if (rockets > 0) {
            if ((shells > 0 || nails > 0) && cells > 0)
                sprint(self, PRINT_HIGH, ", ");
            else if (shells > 0 || nails > 0)
                sprint(self, PRINT_HIGH, " and ");
            sprint(self, PRINT_HIGH, ftos(rockets), " rockets");
        }
        if (cells > 0) {
            if (shells > 0 || nails > 0 || rockets > 0)
                sprint(self, PRINT_HIGH, " and ");
            sprint(self, PRINT_HIGH, ftos(cells), " cells");
        }
        sprint(self, PRINT_HIGH, " into dispenser\n");
    }
};

void (entity disp) Engineer_Dispenser_InsertArmor = {
    local float armor;

    armor = 80;
    if (armor > self.armorvalue) {
        armor = self.armorvalue;
    }
    if (armor > (BUILD_DISPENSER_MAX_ARMOR - disp.armorvalue)) {
        armor = (BUILD_DISPENSER_MAX_ARMOR - disp.armorvalue);
    }
    self.armorvalue = (self.armorvalue - armor);
    disp.armorvalue = (disp.armorvalue + armor);

    if (self.armorvalue == 0) {
        self.armortype = 0;
        self.armorclass = 0;
        self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
    }

    if (armor > 0)
        sprint(self, PRINT_HIGH, "You insert ", ftos(floor(armor)), " armor into dispenser\n");
    else if (disp.armorvalue == BUILD_DISPENSER_MAX_ARMOR)
        sprint(self, PRINT_HIGH, "Dispenser cannot carry more armor\n");
};

void (entity disp) Engineer_Dispenser_Repair = {
    local float metalcost, healamount, ratio;

    if (disp.health == disp.max_health)
        return;

    ratio = (fo_repair_ratio == 0 ? 5 : fo_repair_ratio);

    metalcost = ceil((disp.max_health - disp.health) / ratio);
    if (metalcost > self.ammo_cells)
        metalcost = self.ammo_cells;
    self.ammo_cells = self.ammo_cells - metalcost;

    healamount = floor(metalcost * ratio);
    disp.health = disp.health + healamount;

    if (metalcost > 0) {
        Status_Print(self, "\n\n\n\n\n\n\n", ftos(healamount), " hp repaired");
        FO_Sound(self, CHAN_ITEM, "items/r_item2.wav", 1, 1);
    }
};

void (entity gun) Engineer_UseSentryGun = {

    self.building = gun;
    // automate tasks if old_spanner setting is disabled
    if (!old_spanner) {
        if(gun.team_no > 0 && gun.team_no == self.team_no) {
            if (gun.weapon > 0) {
                //Menu_EngineerFix_SentryGun_Rotate();
                Engineer_SentryGun_ShowMenu(self.building);
                if (gun.weapon < 3 && self.ammo_cells >= ENG_SENTRY_COST) {
                    Engineer_SentryGun_Upgrade(gun);
                    return;
                } else if (gun.health < gun.max_health && self.ammo_cells > 0) {
                    Engineer_SentryGun_Repair(gun);
                    return;
                } else if ((gun.ammo_shells < gun.maxammo_shells && self.ammo_shells > 0)
                            || (gun.weapon == 3 && gun.ammo_rockets < gun.maxammo_rockets
                            && self.ammo_rockets > 0)) {
                    Engineer_SentryGun_InsertAmmo(gun);
                    return;
                }
            } else {
                sprint (self, PRINT_HIGH, strcat("You stopped building a sentry gun and got ", ftos(ENG_SENTRY_COST), " cells back\n"));
                self.ammo_cells = self.ammo_cells + ENG_SENTRY_COST;
                if (self.ammo_cells > self.maxammo_cells)
                    self.ammo_cells = self.maxammo_cells;
                if (gun.trigger_field != world)
                    dremove (gun.trigger_field);
                self = gun.real_owner;
                TeamFortress_EngineerBuildStop();
                return;
            }
        } else { // hit enemy sentry
            self.ammo_cells = self.ammo_cells + 65;
            if (self.ammo_cells > self.maxammo_cells)
                    self.ammo_cells = self.maxammo_cells;
            gun.real_owner.has_sentry = 0;
            bprint(PRINT_HIGH, self.netname, " dismantled ", gun.real_owner.netname, "'s sentry gun\n");
            TF_AddFrags(self, 1);
            sprint(gun.real_owner, PRINT_HIGH, "Your sentry gun was dismantled by ",self.netname,"\n");
            if (gun.trigger_field != world)
                dremove (gun.trigger_field);
            dremove (gun);
            ThrowGib("progs/tgib1.mdl", -30);
            ThrowGib("progs/tgib2.mdl", -50);
            ThrowGib("progs/tgib3.mdl", -50);
            return;
        }
    }

    sprint(self, PRINT_HIGH, "Level ");
    sprint(self, PRINT_HIGH, ftos(gun.weapon), " sentry gun has ");

    if (gun.health == gun.max_health)
        sprint(self, PRINT_HIGH, "max health");
    else
        sprint(self, PRINT_HIGH, ftos(floor(gun.health)), " health");

    if (gun.weapon < 3)
        sprint(self, PRINT_HIGH, " and ");
    else
        sprint(self, PRINT_HIGH, ", ");

    if (gun.ammo_shells == gun.maxammo_shells)
        sprint(self, PRINT_HIGH, "max shells");
    else
        sprint(self, PRINT_HIGH, ftos(floor(gun.ammo_shells)), " shells");

    if (gun.weapon == 3) {
        if (gun.ammo_rockets == gun.maxammo_rockets)
            sprint(self, PRINT_HIGH, " and max rockets");
        else
            sprint(self, PRINT_HIGH, " and ", ftos(floor(gun.ammo_rockets)), " rockets");
    }
    sprint(self, PRINT_HIGH, "\n");

    Engineer_SentryGun_ShowMenu(self.building);
};

void (entity gun) Engineer_SentryGun_ShowMenu = {
    local entity dist_checker;

    if(!infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        dist_checker = spawn();
        dist_checker.classname = "timer";
        dist_checker.owner = self;
        dist_checker.enemy = gun;
        dist_checker.think = CheckDistance;
        dist_checker.nextthink = time + 0.3;
    }
    Menu_EngineerFix_SentryGun();
};

void (entity gun) Engineer_SentryGun_InsertAmmo = {
    local float shells = 0, rockets = 0;
    local string ammo = "";

    shells = 40;
    if (shells > self.ammo_shells)
        shells = self.ammo_shells;
    if (shells > (gun.maxammo_shells - gun.ammo_shells))
        shells = gun.maxammo_shells - gun.ammo_shells;
    self.ammo_shells = self.ammo_shells - shells;
    gun.ammo_shells = gun.ammo_shells + shells;

    if (gun.weapon == 3) {
        rockets = 20;
        if (rockets > self.ammo_rockets)
            rockets = self.ammo_rockets;
        if (rockets > (gun.maxammo_rockets - gun.ammo_rockets))
            rockets = gun.maxammo_rockets - gun.ammo_rockets;
        self.ammo_rockets = self.ammo_rockets - rockets;
        gun.ammo_rockets = gun.ammo_rockets + rockets;
    }

    if ((shells + rockets) > 0) {
        ammo = "You insert ";
        if (shells > 0)
            ammo = strcat(ammo, strcat(ftos(floor(shells)), " shells"));
        if (rockets > 0) {
            if (shells > 0)
                ammo = strcat(ammo, " and ");
            ammo = strcat(ammo, strcat(ftos(floor(rockets)), " rockets"));
        }
        ammo = strcat(ammo, " into sentry gun");
        Status_Print(self, "\n\n\n\n\n\n\n", ammo);
        FO_Sound(self, CHAN_ITEM, "edge/backpack.wav", 1, 1);
    }
};

void (entity gun) Engineer_SentryGun_Upgrade = {
    if (self.ammo_cells < 130)
        return;

    self.ammo_cells = self.ammo_cells - 130;
    gun.weapon = gun.weapon + 1;
    gun.max_health = gun.max_health * 1.2;
    gun.health = gun.max_health;
    gun.maxammo_shells = gun.maxammo_shells * 1.2;
    if (gun.weapon == 2) {
        FO_Sound(gun, CHAN_ITEM, "weapons/turrset.wav", 1, 1);
        gun.think = lvl2_sentry_stand;
        gun.skin = 1;
    } else {
        FO_Sound(gun, CHAN_ITEM, "weapons/turrset.wav", 1, 1);
        gun.think = lvl3_sentry_stand;
        gun.skin = 2;
    }
    Status_Print(self, "\n\n\n\n\n\n\n", "Upgraded to level ", ftos(gun.weapon));
};

void (entity gun) Engineer_SentryGun_Repair = {
    local float metalcost, healamount, ratio;

    ratio = (fo_repair_ratio == 0 ? 5 : fo_repair_ratio);

    metalcost = ceil((gun.max_health - gun.health) / ratio);
    if (metalcost > self.ammo_cells)
        metalcost = self.ammo_cells;
    self.ammo_cells = self.ammo_cells - metalcost;

    healamount = floor(metalcost * ratio);
    gun.health = gun.health + healamount;

    if (gun.health > gun.max_health)
        gun.health = gun.max_health;

    if (metalcost > 0) {
        Status_Print(self, "\n\n\n\n\n\n\n", ftos(healamount), " hp repaired");
        FO_Sound(self, CHAN_ITEM, "items/r_item2.wav", 1, 1);
    }
};

void (entity gunhead) CheckSentry = {
    local vector dist;
    local entity gunbase;

    gunbase = gunhead.trigger_field;
    dist = gunbase.origin - gunhead.origin;
    if (vlen(dist) > 15) {
        bprint(PRINT_MEDIUM, self.real_owner.netname, "'s sentry gun malfunctioned\n");
        Sentry_Die();
    }
};

void () CheckDistance = {
    local vector dist;

    if (self.owner.building != self.enemy) {
        dremove(self);
        return;
    }
    dist = self.enemy.origin - self.owner.origin;
    if (vlen(dist) > ENG_BUILDING_MAINT_DISTANCE) {
        Menu_Close(self.owner);
        self.owner.building = world;
        dremove(self);
        return;
    }
    self.nextthink = time + 0.3;
};

float IsEngEnt(entity ent) {
    return ent.classname == "building_dispenser" ||
           ent.classname == "building_sentrygun";

}

void RemoveEngEnt(entity bld, float explode) {
    entity owner = bld.real_owner;
    if (owner.building == bld) {
        Menu_Close(owner);
        owner.building = world;
    }

    if (explode) {
        TF_T_Damage(bld, world, world, 500, 0, 0);
    } else {
        if(bld.classname == "building_dispenser")
            owner.has_dispenser = 0;
        if(bld.classname == "building_sentrygun") {
            owner.has_sentry = 0;
            if (bld.trigger_field != world)
                dremove (bld.trigger_field);
        }
        dremove (bld);
    }
}

void (entity eng, string bld, float explode) DestroyBuildingWithOptions = {
    local entity te;
    local entity oldself;
    local float pos;

    te = find(world, classname, bld);
    while (te) {
        if (te.real_owner == eng) {
            pos = pointcontents(te.origin);
            if ((pos == -2) || (pos == -6)) {
                oldself = self;
                self = eng;
                self.ammo_cells = self.ammo_cells + 100;
                bound_other_ammo(self);
                self = oldself;
            }

            spawn_tfog(te.origin);
            RemoveEngEnt(te, explode);

        }
        te = find(te, classname, bld);
    }
};

void (entity eng, string bld) DestroyBuilding = {
    DestroyBuildingWithOptions(eng, bld, TRUE);
}

void (entity eng) Engineer_QuietlyRemoveBuildings = {
    DestroyBuildingWithOptions(eng, "building_dispenser", FALSE);
    DestroyBuildingWithOptions(eng, "building_sentrygun", FALSE);
};

void (entity eng) Engineer_RemoveBuildings = {
    DestroyBuilding(eng, "building_dispenser");
    DestroyBuilding(eng, "building_sentrygun");
};

void () info_empblock = {
    self.weapon = 512;
    self.netname = "EMP Block";
};
