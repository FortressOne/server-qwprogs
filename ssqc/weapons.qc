void () player_run;

void () TeamFortress_DisplayDetectionItems;
float (vector veca, vector vecb) crossproducttf;

void (vector org, float damage) SpawnBlood;

void () SuperDamageSound;

void () ConcussionGrenadeTimer;
void () OldConcussionGrenadeTimer;

void (float inp) W_ChangeWeapon;
void () W_ChangeToBestWeapon;
void (float slot) W_WeaponSlot;
void (entity pl) W_WeaponState_Save;
void () W_PrintWeaponMessage;

void () button_fire;

void (entity pl, float fr) TF_AddFrags;

void () DropGoalItems;

void () TeamFortress_DisplayLegalClasses;

void () TeamFortress_ShowIDs;
void () TeamFortress_ShowTF;

void () TeamFortress_AssaultWeapon;
void () TeamFortress_IncendiaryCannon;
void () TeamFortress_FlameThrower;
void (float inp) TeamFortress_PrimeGrenade;
void () TeamFortress_ThrowGrenade;
void (float inp) TeamFortress_PrimeThrowGrenade;
void () TeamFortress_GrenadeSwitch;

void () PipebombTouch;

void () SniperSight_Create;

void (float zoom_to) Sniper_Zoom;

void () Help_Show;
void () TeamFortress_Inventory;
void () TeamFortress_SaveMe;
void (entity pe_player, float f_type) CF_Identify;
void () TeamFortress_ReloadCurrentWeapon;
void (float slot) TeamFortress_ReloadSlot;
void () TeamFortress_ReloadNext;
void () Sniper_ZoomToggle;
void (float zoom_in) Sniper_ZoomAdjust;
void () TeamFortress_StatusQuery;
void () CF_Scout_Dash;
void () CF_Spy_DisguiseStop;
void () TeamFortress_DetpackMenu;
void () CF_Medic_AuraToggle;
void () TeamFortress_EngineerBuild;
void () TeamFortress_EngineerBuildStop;
void () TeamFortress_Scan;
void () TeamFortress_Discard;
void () TeamFortress_Discard_DropAmmo;
float (float force) TeamFortress_DetonatePipebombs;
void (float timer) TeamFortress_SetDetpack;
void () TeamFortress_DetpackStop;

void () DropKey;
void () UseSpecialSkill;
void () RemoveFlare;
void () ScannerSwitch;

void (float all) TeamFortress_TeamShowScores;
void (entity Player) TeamFortress_TeamShowMemberClasses;

void () Admin_CountPlayers;
void () Admin_CycleDeal;
void () Admin_DoKick;
void () Admin_DoBan;
void () Admin_CeaseFire;
void () Admin_ListIPs;

void () fadetoblack;
void () fadefromblack;
void () fadetowhite;
void () fadefromwhite;

void (entity disp) Engineer_UseDispenser;
void (entity gun) Engineer_UseSentryGun;

void () TeamFortress_MOTD;
void () TeamFortress_HelpMap;
void () TeamFortress_NailGrenInfo;

void () BioInfection_Decay;
void () BioInfection_MonsterDecay;

void (entity pl, float swap) W_WeaponState_Load;
float (float weap) W_GetSlot;
float (float weap) W_OldGetSlot;
float () W_BestWeaponSlot;
void () W_FireFlame;
void () W_FireIncendiaryCannon;
void () W_FireTranq;
void () W_FireLaser;

void () HallucinationTimer;
void () TranquiliserTimer;

void () TeamFortress_CTF_FlagInfo;
void () ClanMode;
void () QuadMode;
void () EndQuadRound;
void () PlayerReady;
void () PlayerNotReady;
void () Broadcast_Players_NotReady;
void () StartTimer;

float () GetLastWeaponImpulse;
float () IsUsingOldImpulses;

void (float inp) W_OldWeaponSlot;

void (entity ent, float num) SetFlameCount;

void () W_Precache = {
    precache_sound("weapons/r_exp3.wav");
    precache_sound("weapons/rocket1i.wav");
    precache_sound("weapons/sgun1.wav");
    precache_sound("weapons/guncock.wav");
    precache_sound("weapons/ric1.wav");
    precache_sound("weapons/ric2.wav");
    precache_sound("weapons/ric3.wav");
    precache_sound("weapons/spike2.wav");
    precache_sound("weapons/tink1.wav");
    precache_sound("weapons/grenade.wav");
    precache_sound("weapons/bounce.wav");
    precache_sound("weapons/shotgn2.wav");
    precache_sound("wizard/wattack.wav");
    precache_sound("items/r_item1.wav");
    precache_sound("items/r_item2.wav");
    precache_model("progs/flame2.mdl");
    precache_sound("ambience/fire1.wav");
    precache_sound2("blob/land1.wav");
    precache_model2("progs/v_spike.mdl");
    precache_sound("hknight/hit.wav");
    precache_sound("weapons/detpack.wav");
    precache_sound("weapons/turrset.wav");
    precache_sound("weapons/turrspot.wav");
    precache_sound("weapons/turridle.wav");
    precache_sound("weapons/sniper.wav");
    precache_sound("weapons/flmfire2.wav");
    precache_sound("weapons/flmgrexp.wav");
    precache_sound("misc/vapeur2.wav");
    precache_sound("weapons/asscan1.wav");
    precache_sound("weapons/asscan2.wav");
    precache_sound("weapons/asscan3.wav");
    precache_sound("weapons/asscan4.wav");
    precache_sound("weapons/railgun.wav");
    precache_sound("weapons/dartgun.wav");
    precache_sound("misc/hitsound.wav");
    precache_sound("misc/hitsoundcrit.wav");
    precache_sound("misc/hitsoundteam.wav");
    precache_sound("weapons/flashgrenburst.wav");
    precache_sound("misc/killsound.wav");
    precache_sound("misc/killsoundteam.wav");
};

float () crandom = {
    return (2 * (random() - 0.5));
};

void (float att_delay) Attack_Finished = {
    if (self.tfstate & TFSTATE_TRANQUILISED)
        self.attack_finished = time + att_delay * 2;
    else
        self.attack_finished = time + att_delay;
};

void () W_FireAxe = {
    local vector source;
    local vector org;
    local vector def;

    makevectors(self.v_angle);
    source = self.origin + '0 0 16';
    traceline(source, source + v_forward * 64, FALSE, self);
    if (trace_fraction == 1)
        return;

    org = trace_endpos - v_forward * 4;
    if (trace_ent.takedamage) {

        trace_ent.axhitme = 1;
        SpawnBlood(org, 20);

        if ((self.playerclass != PC_SPY) ||
            (trace_ent.classname != "player")) {
            deathmsg = DMSG_AXE;
            TF_T_Damage(trace_ent, self, self, 20, TF_TD_NOTTEAM,
                        TF_TD_OTHER);
        } else {
            self.weaponmode = 1;
            self.weaponmodel = "progs/v_knife2.mdl";

            // Check direction of Attack
            makevectors(trace_ent.v_angle);
            def = v_right;
            makevectors(self.v_angle);

            // Backstab
            if (crossproducttf(def, v_forward) > 0) {
                deathmsg = DMSG_BACKSTAB;
                TF_T_Damage(trace_ent, self, self, 120,
                            TF_TD_NOTTEAM | TF_TD_IGNOREARMOR,
                            TF_TD_OTHER);
            } else {
                deathmsg = DMSG_AXE;
                TF_T_Damage(trace_ent, self, self, 40, TF_TD_NOTTEAM,
                            TF_TD_OTHER);
            }
        }
    } else {                    // hit wall
        FO_Sound(self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_GUNSHOT);
        WriteByte(MSG_MULTICAST, 3);
        WriteCoord(MSG_MULTICAST, org_x);
        WriteCoord(MSG_MULTICAST, org_y);
        WriteCoord(MSG_MULTICAST, org_z);
        multicast(org, MULTICAST_PVS);
    }
};

void () W_FireSpanner = {
    local vector source;
    local vector org;
    local float healam;
    local entity te;

    makevectors(self.v_angle);
    source = self.origin + '0 0 16';
    traceline(source, source + v_forward * 64, FALSE, self);
    if (trace_fraction == 1)
        return;

    org = trace_endpos - v_forward * 4;

    // It may be a trigger that can be activated by the engineer's spanner
    if (trace_ent.goal_activation & TFGA_SPANNER) {

        if (Activated(trace_ent, self)) {

            DoResults(trace_ent, self, TRUE);

            if (trace_ent.classname == "func_button") {
                trace_ent.enemy = self;
                other = self;
                self = trace_ent;
                self.dont_do_triggerwork = TRUE;
                button_fire();
                self = other;
            }
        } else if (trace_ent.else_goal != 0) {

            te = Findgoal(trace_ent.else_goal);
            if (te)
                AttemptToActivate(te, self, trace_ent);

        } else {
            FO_Sound(self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
            WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
            WriteByte(MSG_MULTICAST, TE_GUNSHOT);
            WriteByte(MSG_MULTICAST, 3);
            WriteCoord(MSG_MULTICAST, org_x);
            WriteCoord(MSG_MULTICAST, org_y);
            WriteCoord(MSG_MULTICAST, org_z);
            multicast(org, MULTICAST_PVS);
        }
        return;
    }
    if (trace_ent.takedamage) {

        if (trace_ent.classname == "building_dispenser") {
            Engineer_UseDispenser(trace_ent);
            return;

        } else if (trace_ent.classname == "building_sentrygun") {

            Engineer_UseSentryGun(trace_ent);
            return;

        } else if (trace_ent.classname == "building_sentrygun_base") {

            if (trace_ent.oldenemy)
                Engineer_UseSentryGun(trace_ent.oldenemy);
            return;

        } else if (trace_ent.classname == "player") {

            if ((((trace_ent.team_no == self.team_no) &&
                  (self.team_no != 0)) && teamplay) || coop) {

                healam = WEAP_SPANNER_REPAIR;
                if (self.ammo_cells < healam)
                    healam = self.ammo_cells;
                if (trace_ent.armortype == 0)
                    return;

                if ((trace_ent.maxarmor - trace_ent.armorvalue) <
                    (healam * 4))
                    healam =
                        ceil((trace_ent.maxarmor -
                              trace_ent.armorvalue) / 4);

                if (healam > 0) {

                    trace_ent.armorvalue =
                        trace_ent.armorvalue + healam * 4;
                    if (trace_ent.armorvalue > trace_ent.maxarmor)
                        trace_ent.armorvalue = trace_ent.maxarmor;

                    self.ammo_cells = self.ammo_cells - healam;

                    FO_Sound(trace_ent, CHAN_WEAPON, "items/r_item1.wav", 1,
                          ATTN_NORM);

                    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
                    WriteByte(MSG_MULTICAST, TE_GUNSHOT);
                    WriteByte(MSG_MULTICAST, 3);
                    WriteCoord(MSG_MULTICAST, org_x);
                    WriteCoord(MSG_MULTICAST, org_y);
                    WriteCoord(MSG_MULTICAST, org_z);
                    multicast(org, MULTICAST_PVS);

                    W_SetCurrentAmmo(self);
                }
                return;
            }
            trace_ent.axhitme = 1;
            SpawnBlood(org, 20);
            deathmsg = DMSG_SPANNER;
            TF_T_Damage(trace_ent, self, self, 20, TF_TD_NOTTEAM, TF_TD_OTHER);
        } else {
            TF_T_Damage(trace_ent, self, self, 20, TF_TD_NOTTEAM, TF_TD_OTHER);
        }
    } else {
        FO_Sound(self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_GUNSHOT);
        WriteByte(MSG_MULTICAST, 3);
        WriteCoord(MSG_MULTICAST, org_x);
        WriteCoord(MSG_MULTICAST, org_y);
        WriteCoord(MSG_MULTICAST, org_z);
        multicast(org, MULTICAST_PVS);
    }
};

void () W_FireMedikit = {
    local vector source;
    local vector org;
    local float healam;
    local entity te;
    local entity BioInfection;

    source = self.origin + '0 0 16';
    traceline(source, (source + (v_forward * 64)), 0, self);
    if ((trace_fraction == 1)) {

        return;

    }
    org = trace_endpos - v_forward * 4;
    if (trace_ent.takedamage) {

        if (trace_ent.classname == "player") {

            if (((trace_ent.team_no == self.team_no) &&
                 (self.team_no != 0)) || coop) {

                healam = 200;
                te = find(world, classname, "timer");
                while (((te.owner != trace_ent)
                        || ((te.think != ConcussionGrenadeTimer)
                            && (te.think != OldConcussionGrenadeTimer)))
                       && (te != world))
                    te = find(te, classname, "timer");

                if (te != world) {

                    if (old_grens == TRUE)
                        stuffcmd(trace_ent, "v_idlescale 0\nfov 90\n");

                    SpawnBlood(org, 20);

                    bprint(PRINT_MEDIUM, self.netname, " cured ",
                           trace_ent.netname, "'s concussion\n");

                    if (te.team_no != self.team_no)
                        TF_AddFrags(self, 1);

                    dremove(te);
                }
                if (trace_ent.tfstate & TFSTATE_HALLUCINATING) {

                    te = find(world, classname, "timer");
                    while (((te.owner != trace_ent) ||
                            (te.think != HallucinationTimer)) &&
                           (te != world))
                        te = find(te, classname, "timer");

                    if (te != world) {

                        trace_ent.tfstate =
                            trace_ent.tfstate -
                            (trace_ent.tfstate & TFSTATE_HALLUCINATING);
                        SpawnBlood(org, 20);

                        bprint(PRINT_MEDIUM, self.netname, " healed ",
                               trace_ent.netname,
                               " of his hallucinations\n");

                        if (old_grens == TRUE)
                            stuffcmd(trace_ent, "v_cshift; wait; bf\n");

                        if (te.team_no != self.team_no)
                            TF_AddFrags(self, 1);

                        dremove(te);
                    } else
                        dprint
                            ("Warning: Error in Hallucination Timer logic.\n");
                }
                if (trace_ent.tfstate & TFSTATE_TRANQUILISED) {

                    te = find(world, classname, "timer");
                    while (((te.owner != trace_ent) ||
                            (te.think != TranquiliserTimer)) &&
                           (te != world))
                        te = find(te, classname, "timer");

                    if (te != world) {

                        trace_ent.tfstate =
                            trace_ent.tfstate -
                            (trace_ent.tfstate & TFSTATE_TRANQUILISED);
                        TeamFortress_SetSpeed(trace_ent);
                        SpawnBlood(org, 20);

                        bprint(PRINT_MEDIUM, self.netname, " healed ",
                               trace_ent.netname, "'s tranquilisation\n");

                        if (te.team_no != self.team_no)
                            TF_AddFrags(self, 1);

                        dremove(te);
                    } else
                        dprint
                            ("Warning: Error in Tranquilisation Timer logic.\n");
                }
                if (trace_ent.FlashTime > 0) {

                    te = find(world, netname, "flashtimer");
                    while (((te.owner != trace_ent) ||
                            (te.classname != "timer")) && (te != world))
                        te = find(te, netname, "flashtimer");

                    if (te != world) {

                        trace_ent.FlashTime = 0;
                        SpawnBlood(org, 20);

                        bprint(PRINT_MEDIUM, self.netname, " cured ",
                               trace_ent.netname, "'s blindness\n");

                        if (te.team_no != self.team_no)
                            TF_AddFrags(self, 1);

                        dremove(te);
                    } else {
                        dprint("Warning: Error in Flash Timer logic.\n");
                        trace_ent.FlashTime = 0;
                    }
                }
                if (trace_ent.tfstate & TFSTATE_INFECTED) {

                    healam = rint(trace_ent.health / 2);
                    trace_ent.tfstate =
                        trace_ent.tfstate -
                        (trace_ent.tfstate & TFSTATE_INFECTED);
                    deathmsg = DMSG_MEDIKIT;
                    T_Damage(trace_ent, self, self, healam);
                    SpawnBlood(org, 30);

                    if (self.classname == "player") {

                        bprint(PRINT_MEDIUM, self.netname, " cured ",
                               trace_ent.netname, "'s infection\n");

                        if (trace_ent.infection_team_no != self.team_no)
                            TF_AddFrags(self, 1);
                    }
                    return;
                }
                if (trace_ent.numflames > 0) {

                    FO_Sound(trace_ent, CHAN_WEAPON, "items/r_item1.wav", 1,
                          ATTN_NORM);
                    SetFlameCount(trace_ent, 0);

                    if (self.classname == "player") {
                        bprint(PRINT_MEDIUM, self.netname, " put out ",
                               trace_ent.netname, "'s fire.\n");
                    }
                    return;
                }
                if (old_medikit) {

                    if (healam > 0 && trace_ent.health < trace_ent.max_health) {

                        FO_Sound(trace_ent, CHAN_WEAPON, "items/r_item1.wav", 1, ATTN_NORM);
                        trace_ent.axhitme = 1;
                        SpawnBlood(org, 20);
                        T_Heal(trace_ent, healam, 0);

                    } else if (trace_ent.health >= trace_ent.max_health && trace_ent.health < (trace_ent.max_health + 50)) {

                        healam = 5;
                        if (healam > (self.ammo_medikit * 5))
                            healam = self.ammo_medikit * 5;

                        if (healam > 0) {
                            FO_Sound(trace_ent, CHAN_ITEM, "items/r_item2.wav", 1, ATTN_NORM);
                            T_Heal(trace_ent, healam, 1);
                            self.ammo_medikit = self.ammo_medikit - rint(healam / 5);

                            if (!(trace_ent.items & IT_SUPERHEALTH)) {
                                trace_ent.items = trace_ent.items | IT_SUPERHEALTH;
                                newmis = spawn();
                                newmis.nextthink = time + 5;
                                newmis.think = item_megahealth_rot;
                                newmis.owner = trace_ent;
                            }
                        }
                    }

                } else if (trace_ent.health < (trace_ent.max_health + 50)) {

                    if (self.ammo_cells >= ceil(PC_MEDIC_MAXAMMO_CELL / 2)) {
                        healam = trace_ent.max_health - trace_ent.health + 50;
                        self.ammo_cells = 0;
                        if (trace_ent.saveme_time <= (time - PC_MEDIC_SAVEME_GRACE))
                            self.regen_cooldown = time + PC_MEDIC_CELL_REGEN_CD;
                        FO_Sound(trace_ent, CHAN_ITEM, "items/r_item2.wav", 1, ATTN_NORM);
                    }
                    else {
                        healam = min(10, ((trace_ent.max_health + 50) - trace_ent.health));
                        self.ammo_cells = self.ammo_cells - min(self.ammo_cells, ceil((PC_MEDIC_MAXAMMO_CELL / 20)));
                        FO_Sound(trace_ent, CHAN_WEAPON, "items/r_item1.wav", 1, ATTN_NORM);
                    }

                    if (self.current_weapon == WEAP_MEDIKIT)
                        self.currentammo = self.ammo_cells;

                    Status_Refresh(self);
                    T_Heal(trace_ent, healam, 1);

                    if (trace_ent.health > trace_ent.max_health) {
                        if (!(trace_ent.items & IT_SUPERHEALTH)) {
                            trace_ent.items = trace_ent.items | IT_SUPERHEALTH;
                            newmis = spawn();
                            newmis.nextthink = time + 5;
                            newmis.think = item_megahealth_rot;
                            newmis.owner = trace_ent;
                        }
                    }
                }
            } else {
                // musn't be on their team, so we infect them
                trace_ent.axhitme = 1;
                SpawnBlood(org, 20);
                deathmsg = DMSG_BIOWEAPON_ATT;
                T_Damage(trace_ent, self, self, 10);

                if (trace_ent.playerclass == PC_MEDIC)
                    return;
                if (cb_prematch)
                    return;
                if (trace_ent.tfstate & TFSTATE_INFECTED)
                    return;

                trace_ent.tfstate = trace_ent.tfstate | TFSTATE_INFECTED;
                BioInfection = spawn();
                BioInfection.classname = "timer";
                BioInfection.owner = trace_ent;
                BioInfection.nextthink = time + 1;
                BioInfection.think = BioInfection_Decay;
                BioInfection.enemy = self;
                LogEventAffliction(self, trace_ent, TFSTATE_INFECTED);
                trace_ent.infection_team_no = self.team_no;
            }
        } else {
            TF_T_Damage(trace_ent, self, self, 20, TF_TD_NOTTEAM, TF_TD_OTHER);
        }
    } else {
        // hit wall
        FO_Sound(self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_GUNSHOT);
        WriteByte(MSG_MULTICAST, 3);
        WriteCoord(MSG_MULTICAST, org_x);
        WriteCoord(MSG_MULTICAST, org_y);
        WriteCoord(MSG_MULTICAST, org_z);
        multicast(org, MULTICAST_PVS);
    }
};

vector () wall_velocity =
{
    local vector vel;

    vel = normalize(self.velocity);
    vel =
        normalize(vel + v_up * (random() - 0.5) +
                  v_right * (random() - 0.5));
    vel = vel + 2 * trace_plane_normal;
    vel = vel * 200;
    return (vel);
};

void (vector org, vector vel) SpawnMeatSpray = {
    local entity missile;

    missile = spawn();
    missile.owner = self;
    missile.movetype = MOVETYPE_BOUNCE;
    missile.solid = SOLID_NOT;
    makevectors(self.angles);
    missile.velocity = vel;
    missile.velocity_z = missile.velocity_z + 250 + 50 * random();
    missile.avelocity = '3000 1000 2000';
    missile.nextthink = time + 1;
    missile.think = SUB_Remove;
    FO_SetModel(missile, "progs/zom_gib.mdl");
    setsize(missile, '0 0 0', '0 0 0');
    setorigin(missile, org);
};

void (vector org, float damage) SpawnBlood = {
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_BLOOD);
    WriteByte(MSG_MULTICAST, 1);
    WriteCoord(MSG_MULTICAST, org_x);
    WriteCoord(MSG_MULTICAST, org_y);
    WriteCoord(MSG_MULTICAST, org_z);
    multicast(org, MULTICAST_PVS);
};

void (float damage) spawn_touchblood = {
    local vector vel;

    vel = wall_velocity() * 0.2;
    SpawnBlood(self.origin + vel * 0.01, damage);

};

void (vector org, vector vel) SpawnChunk = {
    particle(org, vel * 0.02, 0, 10);
};

entity multi_ent;
float multi_damage;
vector blood_org;
float blood_count;
vector puff_org;
float puff_count;

void () ClearMultiDamage = {
    multi_ent = world;
    multi_damage = 0;
    blood_count = 0;
    puff_count = 0;
};

void () ApplyMultiDamage = {
    if (!multi_ent)
        return;

    TF_T_Damage(multi_ent, self, self, multi_damage, TF_TD_NOTTEAM,
                TF_TD_SHOT);
};

void (entity hit, float damage) AddMultiDamage = {
    if (!hit)
        return;

    if (hit != multi_ent) {
        ApplyMultiDamage();
        multi_damage = damage;
        multi_ent = hit;
    } else
        multi_damage = multi_damage + damage;
};

void () Multi_Finish = {
    if (puff_count) {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_GUNSHOT);
        WriteByte(MSG_MULTICAST, puff_count);
        WriteCoord(MSG_MULTICAST, puff_org_x);
        WriteCoord(MSG_MULTICAST, puff_org_y);
        WriteCoord(MSG_MULTICAST, puff_org_z);
        multicast(puff_org, MULTICAST_PVS);
    }
    if (blood_count) {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_BLOOD);
        WriteByte(MSG_MULTICAST, blood_count);
        WriteCoord(MSG_MULTICAST, blood_org_x);
        WriteCoord(MSG_MULTICAST, blood_org_y);
        WriteCoord(MSG_MULTICAST, blood_org_z);
        multicast(puff_org, MULTICAST_PVS);
    }
};

void (float damage, vector dir) TraceAttack = {
    local vector vel;
    local vector org;

    vel = normalize(dir + v_up * crandom() + v_right * crandom());
    vel = vel + 2 * trace_plane_normal;
    vel = vel * 200;
    org = trace_endpos - dir * 4;
    if (trace_ent.takedamage) {

        blood_count = blood_count + 1;
        blood_org = org;
        AddMultiDamage(trace_ent, damage);

    } else
        puff_count = puff_count + 1;
};

void (float shotcount, vector dir, vector spread) FireBullets = {
    local vector direction;
    local vector src;

    makevectors(self.v_angle);

    src = self.origin + v_forward * 10;
    src_z = self.absmin_z + self.size_z * 0.7;

    ClearMultiDamage();

    traceline(src, src + dir * 2048, MOVE_LAGGED, self);
    puff_org = trace_endpos - dir * 4;

    while (shotcount > 0) {

        direction =
            dir + crandom() * spread_x * v_right +
            crandom() * spread_y * v_up;

        traceline(src, (src + (direction * 2048)), MOVE_LAGGED, self);
        if (trace_fraction != 1) {
            if (self.current_weapon != WEAP_ASSAULT_CANNON)
                TraceAttack(4, direction);
            else
                TraceAttack(8, direction);
        }
        shotcount = shotcount - 1;

        if (self.current_weapon == WEAP_ASSAULT_CANNON) {
            puff_org = trace_endpos + direction;
            Multi_Finish();
        }
    }
    ApplyMultiDamage();
    if (self.current_weapon != WEAP_ASSAULT_CANNON)
        Multi_Finish();
};

void () W_FireShotgun = {
    local vector dir;

    FO_Sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);

    KickPlayer(-2, self);
    self.ammo_shells = self.ammo_shells - 1;
    self.currentammo = self.ammo_shells;
    dir = aim(self, 100000);
    deathmsg = DMSG_SHOTGUN;
    FireBullets(6, dir, '0.04 0.04 0');
};

void () W_FireSuperShotgun = {
    local vector dir;

    if (self.currentammo == 1) {
        W_FireShotgun();
        return;
    }
    FO_Sound(self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);

    KickPlayer(-4, self);
    self.ammo_shells = self.ammo_shells - 2;
    self.currentammo = self.ammo_shells;
    dir = aim(self, 100000);
    deathmsg = DMSG_SSHOTGUN;
    FireBullets(14, dir, '0.14 0.08 0');
};

void (vector direction, float damage) FireSniperBullet = {
    local vector src;

    makevectors(self.v_angle);
    src = self.origin + v_forward * 10;
    src_z = self.absmin_z + self.size_z * 0.7;
    ClearMultiDamage();

    KickPlayer(-3, self);

    traceline(src, src + direction * 4096, MOVE_LAGGED, self);
    if (trace_fraction != 1)
        TraceAttack(damage, direction);

    FireBullets(1, direction, '0 0 0');

    ApplyMultiDamage();
};

void () W_FireSniperRifle = {
    local vector dir;
    local vector src;
    local float dam_mult;
    local float zdif;
    local float use_this;
    local float x;
    local vector f;
    local vector g;
    local vector h;
    dir = '0 0 0';

    FO_Sound(self, CHAN_WEAPON, "weapons/sniper.wav", 1, ATTN_NORM);
    KickPlayer(-2, self);
    self.ammo_shells = self.ammo_shells - 1;
    self.currentammo = self.ammo_shells;

    makevectors(self.v_angle);
    src = self.origin + v_forward * 10;
    src_z = self.absmin_z + self.size_z * 0.7;

    use_this = FALSE;

    if (old_sniperrange)
        traceline(src, src + dir * 8092, MOVE_LAGGED, self);
    else
        traceline(src, src + dir * 9192, MOVE_LAGGED, self);
    if (trace_fraction != 1)
        if (trace_ent != world)
            if (trace_ent.classname == "player")
                use_this = TRUE;

    KickPlayer(-4, self);

    if (!use_this) {
        dir = aim(self, 10000);
        if (old_sniperrange)
            traceline(src, src + dir * 3072, MOVE_LAGGED, self);
        else
            traceline(src, src + dir * 9192, MOVE_LAGGED, self);
    }
    deathmsg = DMSG_SNIPERRIFLE;
    dam_mult = 1;
    if (trace_ent) {
        if (trace_ent.classname == "player") {

            f = trace_endpos - src;

            g_x = trace_endpos_x;
            g_y = trace_endpos_y;
            g_z = 0;

            h_x = trace_ent.origin_x;
            h_y = trace_ent.origin_y;
            h_z = 0;

            x = vlen(g - h);
            f = (normalize(f) * x) + trace_endpos;

            zdif = f_z - trace_ent.origin_z;
            deathmsg = DMSG_SNIPERRIFLE;

            trace_ent.head_shot_vector = '0 0 0';
            if (zdif < 0) {

                dam_mult = 0.5;
                trace_ent.leg_damage = trace_ent.leg_damage + 1;
                TeamFortress_SetSpeed(trace_ent);
                deathmsg = DMSG_SNIPERLEGSHOT;
                TF_T_Damage(trace_ent, self, self, self.heat * dam_mult, 2,
                            1);

                if (trace_ent.health > 0) {
                    sprint(trace_ent, PRINT_LOW, "Leg injury!\n");
                    sprint(self, PRINT_MEDIUM,
                           "Leg shot - that'll slow him down!\n");
                }
                return;

            } else if (zdif > 20) {

                dam_mult = 2;
                stuffcmd(trace_ent, "bf\n");
                trace_ent.head_shot_vector =
                    trace_ent.origin - self.origin;
                deathmsg = DMSG_SNIPERHEADSHOT;
                TF_T_Damage(trace_ent, self, self, (self.heat * dam_mult),
                            2, 1);

                if (trace_ent.health > 0) {
                    sprint(trace_ent, PRINT_LOW, "Head injury!\n");
                    sprint(self, PRINT_MEDIUM,
                           "Head shot - that's gotta hurt!\n");
                }
                return;

            } else
                deathmsg = DMSG_SNIPERRIFLE;
        }
    }
    ClearMultiDamage();

    if (trace_fraction != 1)
        TraceAttack(self.heat * dam_mult, dir);

    FireBullets(1, dir, '0 0 0');

    ApplyMultiDamage();
};

void () W_FireAutoRifle = {
    local vector dir;

    FO_Sound(self, CHAN_WEAPON, "weapons/sniper.wav", 1, ATTN_NORM);

    KickPlayer(-1, self);
    self.ammo_shells = self.ammo_shells - 1;
    self.currentammo = self.ammo_shells;
    makevectors(self.v_angle);
    dir = v_forward;
    deathmsg = DMSG_AUTORIFLE;
    FireSniperBullet(dir, 8);
};

void FireAssCan (float shotcount, vector dir, vector spread);
void () W_FireAssaultCannon = {
    local vector dir;

    KickPlayer(-4, self);
    self.ammo_shells = self.ammo_shells - 1;
    self.currentammo = self.ammo_shells;
    dir = aim(self, 100000);
    deathmsg = DMSG_ASSAULTCANNON;
    
    if (fo_hwguy == FALSE)
    {
        if (cannon_accuracy == 1)
            FireBullets(5, dir, '0 0 0');
        else if (cannon_accuracy == 2)
            FireBullets(5, dir, '0.1 0.1 0');
        else if (vlen(self.velocity) < 50)
            FireBullets(5, dir, '0.075 0.075 0');
        else
            FireBullets(5, dir, '0.15 0.15 0');
    }
    else
    {
        FireAssCan(5, dir, '0.04 0.04 0');
    }
    LogEventAttack(self);
};

void (entity pe_flame) CF_ExtinguishFlame = {
    local float rn;

    rn = random();
    if (rn < 0.5) {
        FO_Sound(pe_flame, CHAN_VOICE, "misc/water1.wav", 1, ATTN_NORM);
    } else {
        FO_Sound(pe_flame, CHAN_VOICE, "misc/water2.wav", 1, ATTN_NORM);
    }
    dremove(pe_flame);
};

void () s_explode1 =[0, s_explode2] {
    if (!server_faithful && self.classname == "flamerflame") {
        if (pointcontents(self.origin) < -1) {
            CF_ExtinguishFlame(self);
        }
    }
};

void () s_explode2 =[1, s_explode3] {
    if (!server_faithful && self.classname == "flamerflame") {
        if (pointcontents(self.origin) < -1) {
            CF_ExtinguishFlame(self);
        }
    }
};

void () s_explode3 =[2, s_explode4] {
    if (!server_faithful && self.classname == "flamerflame") {
        if (pointcontents(self.origin) < -1) {
            CF_ExtinguishFlame(self);
        }
    }
};

void () s_explode4 =[3, s_explode5] {
    if (!server_faithful && self.classname == "flamerflame") {
        if (pointcontents(self.origin) < -1) {
            CF_ExtinguishFlame(self);
        }
    }
};

void () s_explode5 =[4, s_explode6] {
    if (!server_faithful && self.classname == "flamerflame") {
        if (pointcontents(self.origin) < -1) {
            CF_ExtinguishFlame(self);
        }
    }
};

void () s_explode6 =[5, SUB_Remove] {
    if (!server_faithful && self.classname == "flamerflame") {
        if (pointcontents(self.origin) < -1) {
            CF_ExtinguishFlame(self);
        }
    }
};

void () BecomeExplosion = {
    dremove(self);
};

void () T_MissileTouch = {
    local float damg;

    if (self.voided)
        return;
    self.voided = 1;

    if (pointcontents(self.origin) == CONTENT_SKY) {
        dremove(self);
        return;
    }
    damg = 92 + random() * 20;

    deathmsg = self.weapon;

    if (other.health)
        TF_T_Damage(other, self, self.owner, damg, TF_TD_NOTTEAM,
                    TF_TD_OTHER);

    if (self.owner.classname == "building_sentrygun")
        T_RadiusDamage(self, self.owner, 150, other);
    else
        T_RadiusDamage(self, self.owner, 92, other);

    self.origin = self.origin - 8 * normalize(self.velocity);

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    dremove(self);
};

void () W_FireRocket = {
    self.ammo_rockets = self.ammo_rockets - 1;
    self.currentammo = self.ammo_rockets;
    FO_Sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
    KickPlayer(-2, self);

    newmis = spawn();
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLYMISSILE;
    newmis.solid = SOLID_BBOX;

    makevectors(self.v_angle);
    newmis.velocity = v_forward;
    newmis.velocity = newmis.velocity * 900;
    newmis.angles = vectoangles(newmis.velocity);

    newmis.touch = T_MissileTouch;
    newmis.voided = 0;

    if (fte_lc_rockets) {
        newmis.flags = FL_LAGGEDMOVE;
    }

    newmis.nextthink = time + 5;
    newmis.think = SUB_Remove;

    newmis.weapon = DMSG_ROCKETL;
    newmis.classname = "proj_rocket";
    FO_SetModel(newmis, "progs/missile.mdl");
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, self.origin + v_forward * 8 + '0 0 16');
};

void (entity from, float damage) LightningHit = {
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_LIGHTNINGBLOOD);
    WriteCoord(MSG_MULTICAST, trace_endpos_x);
    WriteCoord(MSG_MULTICAST, trace_endpos_y);
    WriteCoord(MSG_MULTICAST, trace_endpos_z);
    multicast(trace_endpos, MULTICAST_PVS);

    TF_T_Damage(trace_ent, from, from, damage, TF_TD_NOTTEAM,
                TF_TD_ELECTRICITY);
};

void (vector p1, vector p2, entity from, float damage) LightningDamage = {
    local entity e1;
    local entity e2;
    local vector f;

    f = p2 - p1;
    normalize(f);
    f_x = 0 - f_y;
    f_y = f_x;
    f_z = 0;
    f = f * 16;
    e2 = world;
    e1 = world;

    traceline(p1, p2, 0, self);
    if (trace_ent.takedamage) {

        LightningHit(from, damage);
        if (self.classname == "player")
            if (other.classname == "player")
                trace_ent.velocity_z = trace_ent.velocity_z + 400;
    }
    e1 = trace_ent;
    traceline(p1 + f, p2 + f, 0, self);
    if ((trace_ent != e1) && trace_ent.takedamage)
        LightningHit(from, damage);

    e2 = trace_ent;
    traceline((p1 - f), (p2 - f), 0, self);
    if (((trace_ent != e1) && (trace_ent != e2)) && trace_ent.takedamage)
        LightningHit(from, damage);
};

void () W_FireLightning = {
    local vector org;
    local float cells;

    if (self.ammo_cells < 1) {
        W_ChangeToBestWeapon();
        return;
    }
    if (self.waterlevel > 1) {
        cells = self.ammo_cells;
        self.ammo_cells = 0;
        W_SetCurrentAmmo(self);
        deathmsg = DMSG_LIGHTNING;
        T_RadiusDamage(self, self, 35 * cells, world);
        return;
    }
    if (self.t_width < time) {
        FO_Sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
        self.t_width = time + 0.6;
    }
    KickPlayer(-2, self);

    self.ammo_cells = self.ammo_cells - 1;
    self.currentammo = self.ammo_cells;

    org = self.origin + '0 0 16';
    traceline(org, org + v_forward * 600, 1, self);

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

    LightningDamage(self.origin, trace_endpos + v_forward * 4, self, 30);
};

void () GrenadeExplode = {
    local entity te;

    if (self.voided)
        return;
    self.voided = 1;

    if (self.classname == "pipebomb") {
        if (!(self.flags & 512))
            self.weapon = 40;
    }
    if (self.owner.has_disconnected != 1) {
        deathmsg = self.weapon;
        T_RadiusDamage(self, self.owner, 120, world);
    }
    if (self.no_active_nail_grens != 0) {

        self.no_active_nail_grens = 0;
        self.owner.no_active_nail_grens =
            self.owner.no_active_nail_grens - 1;

        te = find(world, classname, "grenade");
        while (te) {
            if ((te.owner == self.owner) && (te.no_active_nail_grens > 0))
                te.no_active_nail_grens = te.no_active_nail_grens - 1;
            te = find(te, classname, "grenade");
        }
    }
    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    BecomeExplosion();
};

void () GrenadeTouch = {
    if (other == self.owner)
        return;

    if (other.takedamage == DAMAGE_AIM) {
        GrenadeExplode();
        return;
    }
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);

    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void () ExplodeOldestPipebomb = {
    local entity pipe;
    local entity oldest = world;
    local float numpipes = 0;
    local float numpipes_total = 0;
    local float detpipe_limit = rint(GetTeamRole(self.team_no)->detpipe_limit);
    Team_Role * r = GetTeamRole(self.team_no);
    
    pipe = find(world, classname, "pipebomb");
    while (pipe != world) {
        if (pipe.owner == self) {
            numpipes = numpipes + 1;
            if (oldest == world || oldest.nextthink > pipe.nextthink)
                oldest = pipe;
        }
        if (pipe.owner.team_no == self.team_no)
            numpipes_total = numpipes_total + 1;
        pipe = find(pipe, classname, "pipebomb");
    }

    if (((numpipes >= detpipe_limit && detpipe_limit >= 0)
                || (numpipes_total >= detpipe_limit_world && detpipe_limit_world >= 0))
                && oldest != world) {
        oldest.nextthink = time + 0.5;
    }
};

void () W_FireGrenade = {
    self.ammo_rockets = self.ammo_rockets - 1;
    self.currentammo = self.ammo_rockets;
    FO_Sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, 1);
    KickPlayer(-2, self);
    newmis = spawn();
    newmis.voided = 0;
    newmis.owner = self;
    newmis.movetype = 10;
    newmis.solid = 2;
    if ((self.weaponmode == 0) || (cb_prematch)) {
        newmis.weapon = 5;
        newmis.classname = "grenade";
        newmis.skin = 1;
        newmis.touch = GrenadeTouch;
        newmis.nextthink = time + 2.5;
        if (fte_lc_grenades) {
            newmis.flags = FL_LAGGEDMOVE;
        }
    } else {
        if (old_pipecooldown)
            self.pipecooldown = time + 0.8;
        else
            self.pipecooldown = time + 0.5;
        ExplodeOldestPipebomb();
        newmis.classname = "pipebomb";
        newmis.skin = 2;
        newmis.touch = PipebombTouch;
        newmis.nextthink = time + 120;
        newmis.weapon = 11;
        newmis.team_no = self.team_no;
        if (fte_lc_pipebombs) {
            newmis.flags = FL_LAGGEDMOVE;
        }
    }
    makevectors(self.v_angle);
    if (self.v_angle_x) {
        newmis.velocity =
            (((v_forward * 600) + (v_up * 200)) +
             ((crandom() * v_right) * 10)) + ((crandom() * v_up) * 10);
    } else {
        newmis.velocity = aim(self, 10000);
        newmis.velocity = newmis.velocity * 600;
        newmis.velocity_z = 200;
    }
    newmis.avelocity = '300 300 300';
    newmis.angles = vectoangles(newmis.velocity);
    newmis.think = GrenadeExplode;
    FO_SetModel(newmis, "progs/grenade2.mdl");
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, self.origin);
};

void () spike_touch;
void () superspike_touch;

void (vector org, vector dir) launch_spike = {
    newmis = spawn();
    newmis.voided = 0;
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLYMISSILE;
    newmis.solid = SOLID_BBOX;
    if (fte_lc_nailgun) {
        newmis.flags = FL_LAGGEDMOVE;
    }
    newmis.angles = vectoangles(dir);
    newmis.touch = spike_touch;
    newmis.weapon = DMSG_NAILGUN;
    newmis.classname = "spike";
    newmis.think = SUB_Remove;
    newmis.nextthink = time + 6;
    FO_SetModel(newmis, "progs/spike.mdl");
    setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
    setorigin(newmis, org);

    newmis.velocity = dir * ng_velocity;
};

void () W_FireSuperSpikes = {
    local vector dir;

    FO_Sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);

    if (old_ng_rof)
        self.ammo_nails = self.ammo_nails - 4;
    else
        self.ammo_nails = self.ammo_nails - 2;
    self.currentammo = self.ammo_nails;
    dir = aim(self, 1000);
    launch_spike(self.origin + '0 0 16', dir);
    LogEventAttack(self);
    newmis.touch = superspike_touch;
    newmis.weapon = DMSG_SNAILGUN;
    FO_SetModel(newmis, "progs/s_spike.mdl");
    setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
    KickPlayer(-3, self);
};

void (float ox) W_FireSpikes = {
    local vector dir;

    makevectors(self.v_angle);
    if (((self.ammo_nails >= 4) || ((self.ammo_nails >= 2) && !old_ng_rof)) &&
        (self.current_weapon == WEAP_SUPER_NAILGUN)) {
        W_FireSuperSpikes();
        return;
    }
    if (self.ammo_nails < 1) {
        W_ChangeToBestWeapon();
        return;
    }
    FO_Sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
    if ((self.ammo_nails == 1) || !old_ng_rof) {
        self.ammo_nails = self.ammo_nails - 1;
        self.currentammo = self.ammo_nails;
    } else {
        self.ammo_nails = self.ammo_nails - 2;
        self.currentammo = self.ammo_nails;
    }
    dir = aim(self, 1000);
    launch_spike(self.origin + '0 0 16' + v_right * ox, dir);
    LogEventAttack(self);
    KickPlayer(-3, self);
};

void () t_climb = {

	if (time < self.heat)
		return;
		
	self.heat = time + 0.1;

	if (other.classname != "player")
	return;

	if (spurs_enabled == 0)
	return;

	if (other.items & IT_KEY1 && spurs_flag == 0 )
	return;
	    
	if (other.items & IT_KEY2 && spurs_flag == 0 )
	return;

	if(other == self.owner || spurs_enabled == 3 || ((self.owner.team_no == other.team_no) && spurs_enabled == 2))
		{
			if (self.origin_z > other.origin_z){
				other.velocity_z = spurs_boost;

			}
			
		if(spurs_consume)
			dremove(self);
		}

};

void (entity e) ConvertToSpurs =
{
	e.origin = self.origin + ( normalize(self.velocity) * -5);
	e.movetype = MOVETYPE_NONE;
	e.velocity = '0 0 0';
	e.solid = SOLID_TRIGGER;
	e.touch = t_climb;
	e.think = SUB_Remove;
	e.nextthink = time + spurs_duration;
	e.heat = time;
};

.float hit_z;

void () spike_touch = {
    if (self.voided)
        return;
    self.voided = 1;

    if (other.solid == SOLID_TRIGGER)
        return;

    if (pointcontents(self.origin) == CONTENT_SKY) {
        dremove(self);
        return;
    }
    if (other.takedamage) {
        spawn_touchblood(9);
        deathmsg = self.weapon;
        if (self.owner.classname == "grenade") {
            TF_T_Damage(other, self, self.owner.owner, 9, TF_TD_NOTTEAM,
                        TF_TD_NAIL);
        } else {
            TF_T_Damage(other, self, self.owner, ng_damage, TF_TD_NOTTEAM,
                    TF_TD_NAIL);
        }
        
        dremove(self);
        
    } else {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        if (self.classname == "wizspike")
            WriteByte(MSG_MULTICAST, TE_WIZSPIKE);
        else if (self.classname == "knightspike")
            WriteByte(MSG_MULTICAST, TE_KNIGHTSPIKE);
        else
            WriteByte(MSG_MULTICAST, TE_SPIKE);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PHS);
    
    if(other.classname == "worldspawn" && spurs_enabled > 0)
    {
		if(self.owner.playerclass == PC_SCOUT && spurs_scout == 1 || self.owner.playerclass == PC_SPY && spurs_spy == 1)
		{
			ConvertToSpurs(self);
			return;
		}
    }
		
    dremove(self);
   }
};

void () superspike_touch = {
    local float ndmg;

    if (self.voided)
        return;
    self.voided = 1;

    if (other == self.owner)
        return;

    if (other.solid == SOLID_TRIGGER)
        return;

    if (pointcontents(self.origin) == CONTENT_SKY) {
        dremove(self);
        return;
    }
    if (other.takedamage) {
        spawn_touchblood(18);
        deathmsg = self.weapon;
        if (deathmsg == DMSG_GREN_NAIL) {
            ndmg = 40;
        }
        else {
            ndmg = sng_damage;
        }            

        if (self.owner.classname == "grenade")
            TF_T_Damage(other, self, self.owner.owner, ndmg, TF_TD_NOTTEAM,
                        TF_TD_NAIL);
        else {
            if (fte_lc_nailgun_experimental_inflictor && fte_lc_nailgun) {
                 TF_T_Damage(other, self.owner, self.owner, ndmg, TF_TD_NOTTEAM,
                     TF_TD_NAIL);
            } else {
                TF_T_Damage(other, self, self.owner, ndmg, TF_TD_NOTTEAM,
                            TF_TD_NAIL);
            }
        }
    } else {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_SUPERSPIKE);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PHS);
    }
    dremove(self);
};

void (entity pl) W_SetCurrentAmmo = {
    entity oldself;

    if ((pl.health <= 0) || (pl.current_weapon == 0))
        return;

    if (!(self.tfstate & TFSTATE_AIMING) && !(self.tfstate & TFSTATE_CANT_MOVE))
        player_run();

    pl.items = pl.items - (pl.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
    pl.weapon = 0;

    if (pl.current_weapon == WEAP_AXE) {
        pl.currentammo = 0;
        if (pl.playerclass == 8) {
            if (pl.weaponmode == 0)
                pl.weaponmodel = "progs/v_knife.mdl";
            else
                pl.weaponmodel = "progs/v_knife2.mdl";
        } else
            pl.weaponmodel = "progs/v_axe.mdl";
        pl.weaponframe = 0;
    } else if (pl.current_weapon == WEAP_SPANNER) {
        pl.currentammo = pl.ammo_cells;
        pl.weaponmodel = "progs/v_span.mdl";
        pl.weaponframe = 0;
    } else if (pl.current_weapon == WEAP_SHOTGUN) {
        pl.currentammo = pl.ammo_shells;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_shot.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_SHELLS;
        pl.weapon = IT_SHOTGUN;
    } else if (pl.current_weapon == WEAP_SUPER_SHOTGUN) {
        pl.currentammo = pl.ammo_shells;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_shot2.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_SHELLS;
        pl.weapon = IT_SUPER_SHOTGUN;
    } else if (pl.current_weapon == WEAP_NAILGUN) {
        pl.currentammo = pl.ammo_nails;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_nail.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_NAILS;
        pl.weapon = IT_NAILGUN;
    } else if (pl.current_weapon == WEAP_SUPER_NAILGUN) {
        pl.currentammo = pl.ammo_nails;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_nail2.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_NAILS;
        pl.weapon = IT_SUPER_NAILGUN;
    } else if (pl.current_weapon == WEAP_GRENADE_LAUNCHER) {
        pl.currentammo = pl.ammo_rockets;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            if (pl.weaponmode == 0)
                pl.weaponmodel = "progs/v_rock.mdl";
            else
                pl.weaponmodel = "progs/v_pipe.mdl";
            pl.weaponframe = 0;
        }
        pl.weapon = IT_GRENADE_LAUNCHER;
        pl.items = pl.items | IT_ROCKETS;
    } else if (pl.current_weapon == WEAP_ROCKET_LAUNCHER) {
        pl.currentammo = pl.ammo_rockets;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_rock2.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_ROCKETS;
        pl.weapon = IT_ROCKET_LAUNCHER;
    } else if (pl.current_weapon == WEAP_SNIPER_RIFLE) {
        pl.currentammo = pl.ammo_shells;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_srifle.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_SHELLS;
        pl.weapon = IT_SHOTGUN;
    } else if (pl.current_weapon == WEAP_AUTO_RIFLE) {
        pl.currentammo = pl.ammo_shells;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_srifle.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_SHELLS;
        pl.weapon = IT_SUPER_SHOTGUN;
    } else if (pl.current_weapon == WEAP_ASSAULT_CANNON) {
        pl.currentammo = pl.ammo_shells;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_asscan.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_SHELLS;
        pl.weapon = IT_ROCKET_LAUNCHER;
    } else if (pl.current_weapon == WEAP_FLAMETHROWER) {
        pl.currentammo = pl.ammo_cells;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_flame.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_CELLS;
        pl.weapon = IT_GRENADE_LAUNCHER;
    } else if (pl.current_weapon == WEAP_INCENDIARY) {
        pl.currentammo = pl.ammo_rockets;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_irock.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_ROCKETS;
        pl.weapon = IT_ROCKET_LAUNCHER;
    } else if (pl.current_weapon == WEAP_MEDIKIT) {
        if (!old_medikit) {
            pl.currentammo = pl.ammo_cells;
            pl.items = pl.items | IT_CELLS;
        } else
            pl.currentammo = 0;
        pl.weaponmodel = "progs/v_medi.mdl";
        pl.weaponframe = 0;
    } else if (pl.current_weapon == WEAP_TRANQ) {
        pl.currentammo = pl.ammo_shells;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_tranq.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_SHELLS;
        pl.weapon = IT_SHOTGUN;
    } else if (pl.current_weapon == WEAP_LASER) {
        pl.currentammo = pl.ammo_nails;
        if (!(pl.tfstate & TFSTATE_RELOADING)) {
            pl.weaponmodel = "progs/v_rail.mdl";
            pl.weaponframe = 0;
        }
        pl.items = pl.items | IT_NAILS;
        pl.weapon = IT_SHOTGUN;
    } else {
        pl.currentammo = 0;
        pl.weaponmodel = "";
        pl.weaponframe = 0;
    }

    if (pl.is_feigning) {
        pl.weaponmodel = "";
        pl.weaponframe = 0;
    }

    // refresh engineer build menu when ammo updated
    if (pl.menu_input == Menu_Engineer_Input)
        Menu_Engineer(pl);
    else if (pl.menu_input == Menu_Drop_Input) {
        oldself = self;
        self = pl;
        Menu_Drop();
        self = oldself;
    }
};

float () W_BestWeapon = {
    local float it;

    it = self.weapons_carried;
    if ((self.ammo_cells >= 1 && it & WEAP_LIGHTNING) && self.waterlevel <= 1)
        return WEAP_LIGHTNING;
    else if ((self.ammo_cells >= 7 && self.ammo_shells >= 1) && it & WEAP_ASSAULT_CANNON)
        return WEAP_ASSAULT_CANNON;
    else if (self.ammo_rockets >= 1 && it & WEAP_GRENADE_LAUNCHER)
        return WEAP_GRENADE_LAUNCHER;
    else if (self.ammo_rockets >= 1 && it & WEAP_ROCKET_LAUNCHER)
        return WEAP_ROCKET_LAUNCHER;
    else if (self.ammo_rockets >= 3 && it & WEAP_INCENDIARY)
        return WEAP_INCENDIARY;
    else if (self.ammo_cells >= 1 && it & WEAP_FLAMETHROWER)
        return WEAP_FLAMETHROWER;
    else if (self.ammo_nails >= 2 && it & WEAP_SUPER_NAILGUN)
        return WEAP_SUPER_NAILGUN;
    else if (self.ammo_nails >= 1 && it & WEAP_LASER)
        return WEAP_LASER;
    else if (self.ammo_shells >= 1 && it & WEAP_TRANQ)
        return WEAP_TRANQ;
    else if (self.ammo_shells >= 2 && it & WEAP_SUPER_SHOTGUN)
        return WEAP_SUPER_SHOTGUN;
    else if (self.ammo_shells >= 1 && it & WEAP_SNIPER_RIFLE)
        return WEAP_SNIPER_RIFLE;
    else if (self.ammo_nails >= 1 && it & WEAP_NAILGUN)
        return WEAP_NAILGUN;
    else if (self.ammo_shells >= 1 && it & WEAP_SHOTGUN)
        return WEAP_SHOTGUN;
    else if (it & WEAP_MEDIKIT)
        return WEAP_MEDIKIT;
    else if (it & WEAP_SPANNER)
        return WEAP_SPANNER;
    else if (it & WEAP_AXE)
        return WEAP_AXE;

    return 0;
};

float () W_BestWeaponSlot = {
    local float weap;

    weap = W_BestWeapon();

    if (!IsUsingOldImpulses())
        return W_GetSlot(weap);
    else 
        return W_OldGetSlot(weap);
};

void () W_ChangeToBestWeapon = {
    local float slot = W_BestWeaponSlot();    
    
    if (!IsUsingOldImpulses())
        W_WeaponSlot(slot);
    else
        W_OldWeaponSlot(slot);

    //self.last_weaponslot = self.current_weaponslot;
    //self.last_weapon = self.current_weapon;
    //self.last_weaponmode = self.weaponmode;
    self.current_weaponslot = slot;
    self.current_weapon = self.next_weapon;
    self.weaponmode = self.next_weaponmode;
    W_SetCurrentAmmo(self);
    W_WeaponState_Save(self);
    W_PrintWeaponMessage();
}

float () W_CheckNoAmmo = {
    if (self.current_weapon == WEAP_AXE || self.current_weapon == WEAP_SPANNER
                || self.current_weapon == WEAP_MEDIKIT)
        return 1;
    else if (self.current_weapon == WEAP_SUPER_NAILGUN && self.currentammo >= 4)
        return 1;
    else if (self.current_weapon == WEAP_INCENDIARY && self.currentammo >= 3)
        return 1;
    else if ((self.current_weapon == WEAP_SUPER_SHOTGUN || self.current_weapon == WEAP_NAILGUN)
                && self.currentammo >= 2)
        return 1;
    else if (self.currentammo > 0)
        return 1;

    W_ChangeToBestWeapon();
    return 0;
};

void () W_Reload_shotgun = {
    self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_RELOADING);
    self.owner.weaponmodel = "progs/v_shot.mdl";
    sprint(self.owner, PRINT_HIGH, "Finished reloading\n");
    dremove(self);
    W_WeaponState_Load(self.owner, 0);
    Status_Refresh(self.owner);
};

void () W_Reload_super_shotgun = {
    self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_RELOADING);
    self.owner.weaponmodel = "progs/v_shot2.mdl";
    sprint(self.owner, PRINT_HIGH, "Finished reloading\n");
    dremove(self);
    W_WeaponState_Load(self.owner, 0);
    Status_Refresh(self.owner);
};

void (entity pl) W_Reload_sniper_rifle = {
    pl.reload_sniper_ticks = 0;
    pl.tfstate = pl.tfstate - (pl.tfstate & TFSTATE_RELOADING);
    pl.weaponmodel = "progs/v_srifle.mdl";
    sprint(pl, PRINT_HIGH, "Finished reloading\n");
    W_WeaponState_Load(pl, 0);
    Status_Refresh(pl);
};

void () W_Reload_sniper_rifle_tick = {
    self.owner.reload_sniper_ticks = self.owner.reload_sniper_ticks + 1;

    if (self.owner.reload_sniper_ticks >= 4) {
        W_Reload_sniper_rifle(self.owner);
        dremove(self);
        return;
    }

    Status_Refresh(self.owner);
    self.nextthink = time + 1;
}

void () W_Reload_grenade_launcher = {
    self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_RELOADING);
    if (self.owner.weaponmode == 0)
        self.owner.weaponmodel = "progs/v_rock.mdl";
    else
        self.owner.weaponmodel = "progs/v_pipe.mdl";
    sprint(self.owner, PRINT_HIGH, "Finished reloading\n");
    dremove(self);
    W_WeaponState_Load(self.owner, 0);
    Status_Refresh(self.owner);
};

void () W_Reload_rocket_launcher = {
    self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_RELOADING);
    self.owner.weaponmodel = "progs/v_rock2.mdl";
    sprint(self.owner, PRINT_HIGH, "Finished reloading\n");
    dremove(self);
    W_WeaponState_Load(self.owner, 0);
    Status_Refresh(self.owner);
};

void () W_Reload_assault_cannon = {
    self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_RELOADING);
    self.owner.weaponmodel = "progs/v_asscan.mdl";
    sprint(self.owner, PRINT_HIGH, "Finished reloading\n");
    dremove(self);
    W_WeaponState_Load(self.owner, 0);
    Status_Refresh(self.owner);
};

float () CheckForReload = {
    if (self.current_weapon == WEAP_SHOTGUN) {
        if (self.reload_shotgun >= 8 && self.ammo_shells > 0) {
            TeamFortress_ReloadCurrentWeapon();
            return 1;
        }
    } else if (self.current_weapon == WEAP_SUPER_SHOTGUN) {
        if (self.reload_super_shotgun >= 16 && self.ammo_shells > 0) {
            TeamFortress_ReloadCurrentWeapon();
            return 1;
        }
    } else if (self.current_weapon == WEAP_SNIPER_RIFLE) {
        if (self.reload_sniper_rifle >= 1 && self.ammo_shells > 0 && sniperreload) {
            TeamFortress_ReloadCurrentWeapon();
            return 1;
        }
    } else if (self.current_weapon == WEAP_GRENADE_LAUNCHER) {
        if ((self.reload_grenade_launcher >= 6) && (self.ammo_rockets > 0)) {
            TeamFortress_ReloadCurrentWeapon();
            return 1;
        }
    } else if (self.current_weapon == WEAP_ROCKET_LAUNCHER) {
        if ((self.reload_rocket_launcher >= 4) && (self.ammo_rockets > 0)) {
            TeamFortress_ReloadCurrentWeapon();
            return 1;
        }
    } else if (self.current_weapon == WEAP_ASSAULT_CANNON) {
        if (fo_hwguy)
        {
            if (self.reload_assault_cannon >= PC_HVYWEAP_ASSCAN_CLIPSIZE && self.ammo_shells > 0) {
                TeamFortress_ReloadCurrentWeapon();
                return 1;
            }
        }
    }
    return 0;
};

float (float weap) CheckForAmmo = {
    if (weap == WEAP_SHOTGUN) {
        if (self.reload_shotgun >= 1 && self.ammo_shells > self.reload_shotgun)
            return 1;
    } else if (weap == WEAP_SUPER_SHOTGUN) {
        if (self.reload_super_shotgun >= 2 && self.ammo_shells > self.reload_super_shotgun)
            return 1;
    } else if (weap == WEAP_SNIPER_RIFLE) {
        if (self.reload_sniper_rifle >= 1 && self.ammo_shells > self.reload_sniper_rifle && sniperreload)
            return 1;
    } else if (weap == WEAP_GRENADE_LAUNCHER) {
        if (self.reload_grenade_launcher >= 1 && self.ammo_rockets > self.reload_grenade_launcher)
            return 1;
    } else if (weap == WEAP_ROCKET_LAUNCHER) {
        if (self.reload_rocket_launcher >= 1 && self.ammo_rockets > self.reload_rocket_launcher)
            return 1;
    } else if (weap == WEAP_ASSAULT_CANNON) {
        if (fo_hwguy)
        {
            if (self.reload_assault_cannon >= PC_HVYWEAP_ASSCAN_CLIPSIZE && self.ammo_shells > self.reload_assault_cannon)
                return 1;
        }
    }
    return 0;
};

void () player_axe1;
void () player_axeb1;
void () player_axec1;
void () player_axed1;

void () player_shot1;
void () player_nail1;
void () player_light1;
void () player_rocket1;
void () player_autorifle1;

void () player_assaultcannon1;
void () player_assaultcannonup1;
void () player_assaultcannondown1;

void () player_medikit1;
void () player_medikitb1;
void () player_medikitc1;
void () player_medikitd1;

void () W_Attack = {
    local float r;

    if (!W_CheckNoAmmo())
        return;

    if (self.has_disconnected == TRUE)
        return;

    if (self.tfstate & TFSTATE_RELOADING || self.is_detpacking)
        return;
    
    if(no_fire_mode)
        return;

    if ((self.is_undercover || (self.undercover_team != 0)) ||
        (self.undercover_skin != 0))
        Spy_RemoveDisguise(self);

    makevectors(self.v_angle);
    self.show_hostile = time + 1;

    if (self.current_weapon == WEAP_AXE) {
        Attack_Finished(0.5);
        FO_Sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
        r = random();
        if (r < 0.25)
            player_axe1();
        else if (r < 0.5)
            player_axeb1();
        else if (r < 0.75)
            player_axec1();
        else
            player_axed1();
    } else if (self.current_weapon == WEAP_SPANNER) {
        Attack_Finished(0.5);
        FO_Sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
        player_axe1();
    } else if (self.current_weapon == WEAP_SHOTGUN) {
        if (CheckForReload() == TRUE)
            return;
        player_shot1();
        W_FireShotgun();
        self.reload_shotgun = self.reload_shotgun + 1;
        Status_Refresh(self);
        CheckForReload();
        Attack_Finished(0.5);
    } else if (self.current_weapon == WEAP_SUPER_SHOTGUN) {
        if (CheckForReload() == TRUE)
            return;
        player_shot1();
        W_FireSuperShotgun();
        self.reload_super_shotgun = self.reload_super_shotgun + 2;
        Status_Refresh(self);
        CheckForReload();
        Attack_Finished(0.7);
    } else if (self.current_weapon == WEAP_NAILGUN) {
        player_nail1();
    } else if (self.current_weapon == WEAP_SUPER_NAILGUN) {
        player_nail1();
    } else if (self.current_weapon == WEAP_GRENADE_LAUNCHER) {
        if (CheckForReload() == TRUE)
            return;
        player_rocket1();
        W_FireGrenade();
        self.reload_grenade_launcher = self.reload_grenade_launcher + 1;
        Status_Refresh(self);
        CheckForReload();
        Attack_Finished(0.6);
    } else if (self.current_weapon == WEAP_ROCKET_LAUNCHER) {
        if (CheckForReload() == TRUE)
            return;
        player_rocket1();
        W_FireRocket();
        self.reload_rocket_launcher = self.reload_rocket_launcher + 1;
        Status_Refresh(self);
        CheckForReload();
        Attack_Finished(0.8);
    } else if (self.current_weapon == WEAP_LIGHTNING) {
        player_light1();
        Attack_Finished(0.1);
        FO_Sound(self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
    } else if (self.current_weapon == WEAP_SNIPER_RIFLE) {
        if (self.flags & FL_ONGROUND) {
            if (CheckForReload() == TRUE)
                return;
            player_shot1();
            W_FireSniperRifle();
            if (sniperreload) {
                self.reload_sniper_rifle = self.reload_sniper_rifle + 1;
                Status_Refresh(self);
                CheckForReload();
            }
            Attack_Finished(1.5);
        }
    } else if (self.current_weapon == WEAP_AUTO_RIFLE) {
        player_autorifle1();
        W_FireAutoRifle();
        Attack_Finished(0.1);
    } else if (self.current_weapon == WEAP_ASSAULT_CANNON) {
        if (fo_hwguy)
        {
            if (CheckForReload() == TRUE)
            return;
        }

        if (self.ammo_cells < 7) {
            if (time >= self.antispam_assault_cannon) {
                sprint(self, PRINT_MEDIUM, "Not enough cells to power up the Assault Cannon\n");
                self.antispam_assault_cannon = time + 3;
            }
            W_ChangeWeapon(W_BestWeaponSlot());
            W_SetCurrentAmmo(self);
            W_WeaponState_Save(self);
        } else {
            self.ammo_cells = self.ammo_cells - 7;
            self.heat = 1;
            self.immune_to_check = time + 5;
            self.tfstate = self.tfstate | TFSTATE_AIMING;
            TeamFortress_SetSpeed(self);
            player_assaultcannonup1();
        }
    } else if (self.current_weapon == WEAP_FLAMETHROWER) {
        player_shot1();
        W_FireFlame();
        if (self.waterlevel > 2)
            Attack_Finished(1);
        else
            Attack_Finished(0.15);
    } else if (self.current_weapon == WEAP_INCENDIARY) {
        if (self.ammo_rockets >= 3) {
            player_rocket1();
            W_FireIncendiaryCannon();
            switch (pyro_type)
            {
                case PYRO_ORIGINAL:
                    Attack_Finished(1.2);
                    break;
                case PYRO_OZTF:
                    Attack_Finished(0.9);
                    break;
                case PYRO_FO:
                    //Attack_Finished(PC_PYRO_LAVA_RETICK);
                    Attack_Finished(0.9);
                    break;
            }
        } else if (time >= self.antispam_incendiary_cannon) {
            sprint(self, PRINT_HIGH, "Not enough ammo\n");
            self.antispam_incendiary_cannon = time + 3;
        }
    } else if (self.current_weapon == WEAP_MEDIKIT) {
        FO_Sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
        r = random();
        if (r < 0.25)
            player_medikit1();
        else if (r < 0.5)
            player_medikitb1();
        else if (r < 0.75)
            player_medikitc1();
        else
            player_medikitd1();
        Attack_Finished(0.5);
    } else if (self.current_weapon == WEAP_TRANQ) {
        FO_Sound(self, CHAN_WEAPON, "weapons/dartgun.wav", 1, ATTN_NORM);
        player_shot1();
        W_FireTranq();
        Attack_Finished(1.5);
    } else if (self.current_weapon == WEAP_LASER) {
        FO_Sound(self, CHAN_WEAPON, "weapons/railgun.wav", 1, ATTN_NORM);
        player_shot1();
        W_FireLaser();
        Attack_Finished(0.4);
    }

    //These weapons have to log each projectile launched/bullet fired
    if (self.current_weapon != WEAP_ASSAULT_CANNON ||
        self.current_weapon != WEAP_NAILGUN ||
        self.current_weapon != WEAP_SUPER_NAILGUN)
        LogEventAttack(self);
};

float (entity pl) WeaponReady = {
    if (time >= pl.attack_finished && !(pl.tfstate & TFSTATE_RELOADING)) {
        return 1;
    }
              
    return 0;
}

void () W_PrintWeaponMessage = {
    switch (self.current_weapon)
    {
        case WEAP_GRENADE_LAUNCHER:
            if (self.weaponmode == GL_NORMAL)
                sprint(self, PRINT_MEDIUM, "Normal grenade mode\n");
            else if (cb_prematch)
                sprint(self, PRINT_MEDIUM,
                    "Pipebomb mode not available in prematch\n");
            else if (self.weaponmode == GL_PIPEBOMB)
                sprint(self, PRINT_MEDIUM, "Pipebomb mode\n");
            break;
        case WEAP_SNIPER_RIFLE:
            sprint(self, PRINT_MEDIUM, "Sniper rifle ready\n");
            break;
        case WEAP_AUTO_RIFLE:
            sprint(self, PRINT_MEDIUM, "Sniper rifle on fully automatic mode\n");
            break;
    }
};

float (float weap) W_GetSlot = {
    if (weap == WEAP_ROCKET_LAUNCHER
                || weap == WEAP_SUPER_NAILGUN
                || weap == WEAP_SNIPER_RIFLE
                || weap == WEAP_FLAMETHROWER
                || weap == WEAP_TRANQ
                || weap == WEAP_LASER
                || weap == WEAP_ASSAULT_CANNON) {
        return 1;
    } else if (weap == WEAP_SUPER_SHOTGUN
                || weap == WEAP_AUTO_RIFLE
                || weap == WEAP_INCENDIARY) {
        return 2;
    } else if (weap == WEAP_SHOTGUN) {
        if (self.playerclass == PC_SCOUT)
            return 2;
        else
            return 3;
    } else if (weap == WEAP_NAILGUN) {
        if (self.playerclass == PC_SCOUT)
            return 1;
        else
            return 3;
    } else if (weap == WEAP_GRENADE_LAUNCHER) {
        if (self.weaponmode == 0)
            return 1;
        else
            return 2;
    }
    return 0;
};

float (float weap) W_OldGetSlot = {
    if (weap == WEAP_AXE
            || weap == WEAP_MEDIKIT
            || weap == WEAP_SPANNER)
        return 1;
    else if (weap == WEAP_SHOTGUN
                || weap == WEAP_SNIPER_RIFLE
                || weap == WEAP_TRANQ
                || weap == WEAP_LASER)
        return 2;
    else if (weap == WEAP_SUPER_SHOTGUN
                || weap == WEAP_AUTO_RIFLE)
        return 3;
    else if (weap == WEAP_NAILGUN)
        return 4;
    else if (weap == WEAP_SUPER_NAILGUN
                || weap == WEAP_FLAMETHROWER)
        return 5;
    else if (weap == WEAP_FLAMETHROWER)
        return 6;
    else if (weap == WEAP_ROCKET_LAUNCHER                
                || weap == WEAP_ASSAULT_CANNON
                || weap == WEAP_INCENDIARY)
        return 7;
    else if (weap == WEAP_GRENADE_LAUNCHER) {
        if (self.weaponmode == 0)
            return 6;
        else
            return 7;
    }
    return 0;
};

float (float inp) W_AmmoSlot = {
    self.noammo = 0;

    if (inp == 1) {
        if (self.playerclass == PC_SCOUT && self.ammo_nails < 2)
            self.noammo = 1;
        else if (self.playerclass == PC_SNIPER && self.ammo_shells < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_SOLDIER && self.ammo_rockets < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_DEMOMAN && self.ammo_rockets < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_MEDIC && self.ammo_nails < 4)
            self.noammo = 1;
        else if (self.playerclass == PC_HVYWEAP) {
            if (self.ammo_shells < 1)
                self.noammo = 1;
            else if (self.ammo_cells < 7)
                self.noammo = 2;
        } else if (self.playerclass == PC_PYRO && self.ammo_cells < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_SPY && self.ammo_shells < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_ENGINEER && self.ammo_nails < 1)
            self.noammo = 1;
    } else if (inp == 2) {
        if (self.playerclass == PC_SCOUT && self.ammo_shells < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_SNIPER && self.ammo_shells < 1)
            self.noammo = 1;
        else if ((self.playerclass == PC_SOLDIER
                    || self.playerclass == PC_MEDIC
                    || self.playerclass == PC_HVYWEAP
                    || self.playerclass == PC_SPY
                    || self.playerclass == PC_ENGINEER)
                    && self.ammo_shells < 2)
            self.noammo = 1;
        else if (self.playerclass == PC_DEMOMAN && self.ammo_rockets < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_PYRO && self.ammo_rockets < 3)
            self.noammo = 1;
    } else if (inp == 3) {
        if (self.playerclass == PC_SCOUT
                    || self.playerclass == PC_ENGINEER)
            return 0;
        if ((self.playerclass == PC_SNIPER
                    || self.playerclass == PC_SPY)
                    && self.ammo_nails < 2)
            self.noammo = 1;
        else if ((self.playerclass == PC_SOLDIER
                    || self.playerclass == PC_DEMOMAN
                    || self.playerclass == PC_MEDIC
                    || self.playerclass == PC_HVYWEAP
                    || self.playerclass == PC_PYRO)
                    && self.ammo_shells < 1)
            self.noammo = 1;
    } else if (inp == 4)
        return 1;

    if (self.noammo > 0)
        return 0;
    else
        return 1;
};

float (float inp) W_OldAmmoSlot = {
    self.noammo = 0;
    if (inp == 1) {
        return 1;
    }
    else if (inp == 2) {
        if ((self.playerclass == PC_SCOUT 
                || self.playerclass == PC_SNIPER
                || self.playerclass == PC_SOLDIER
                || self.playerclass == PC_DEMOMAN
                || self.playerclass == PC_MEDIC
                || self.playerclass == PC_HVYWEAP
                || self.playerclass == PC_PYRO
                || self.playerclass == PC_SPY)
                && self.ammo_shells < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_ENGINEER && self.ammo_nails < 1)
            self.noammo = 1;

    }
    else if (inp == 3) {
        if (self.playerclass == PC_SNIPER && self.ammo_shells < 1)
            self.noammo = 1;
        else if ((self.playerclass == PC_SOLDIER
                    || self.playerclass == PC_MEDIC
                    || self.playerclass == PC_HVYWEAP
                    || self.playerclass == PC_SPY
                    || self.playerclass == PC_ENGINEER)
                    && self.ammo_shells < 2)
            self.noammo = 1;
    }
    else if (inp == 4) {
        if ((self.playerclass == PC_SCOUT
                || self.playerclass == PC_SNIPER
                || self.playerclass == PC_SPY)
                && self.ammo_nails < 2)
            self.noammo = 1;
    }
    else if (inp == 5) {
        if (self.playerclass == PC_MEDIC && self.ammo_nails < 4)
            self.noammo = 1;
        else if (self.playerclass == PC_PYRO && self.ammo_cells < 1)
            self.noammo = 1;
    }
    else if (inp == 6) {
        if (self.playerclass == PC_DEMOMAN && self.ammo_rockets < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_PYRO && self.ammo_cells < 1)
            self.noammo = 1;

    }
    else if (inp == 7) {
        if (self.playerclass == PC_SOLDIER && self.ammo_rockets < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_DEMOMAN && self.ammo_rockets < 1)
            self.noammo = 1;
        else if (self.playerclass == PC_HVYWEAP) {
            if (self.ammo_shells < 1)
                self.noammo = 1;
            else if (self.ammo_cells < 7)
                self.noammo = 2;
        }
        else if (self.playerclass == PC_PYRO && self.ammo_rockets < 3)
            self.noammo = 1;

    }
    if (self.noammo > 0)
        return 0;
    else
        return 1;
};

float () W_OldWeaponSlot1 = {
    if (self.weapons_carried & WEAP_MEDIKIT)
        return WEAP_MEDIKIT;
    else if (self.weapons_carried & WEAP_SPANNER)
        return WEAP_SPANNER;
    else
        return WEAP_AXE;
};

float () W_OldWeaponSlot2 = {
    if (self.playerclass == PC_SCOUT    
            ||self.playerclass == PC_SOLDIER
            || self.playerclass == PC_DEMOMAN
            || self.playerclass == PC_MEDIC
            || self.playerclass == PC_HVYWEAP
            || self.playerclass == PC_PYRO)
        return WEAP_SHOTGUN;
    else if (self.playerclass == PC_SNIPER) 
        return WEAP_SNIPER_RIFLE;
    else if (self.playerclass == PC_SPY)
        return WEAP_TRANQ;
    else if (self.playerclass == PC_ENGINEER)
        return WEAP_LASER;
    return 0;
};

float () W_OldWeaponSlot3 = {
    if (self.playerclass == PC_SOLDIER
            || self.playerclass == PC_MEDIC
            || self.playerclass == PC_HVYWEAP
            || self.playerclass == PC_SPY
            || self.playerclass == PC_ENGINEER)
        return WEAP_SUPER_SHOTGUN;
    else if (self.playerclass == PC_SNIPER) 
        return WEAP_AUTO_RIFLE;
    return 0;
};

float () W_OldWeaponSlot4 = {
    if (self.playerclass == PC_SCOUT
        || self.playerclass == PC_SNIPER
        || self.playerclass == PC_SPY)
        return WEAP_NAILGUN;
    return 0;
};

float () W_OldWeaponSlot5 = {
    if (self.playerclass == PC_MEDIC)
        return WEAP_SUPER_NAILGUN;
    else if (self.playerclass == PC_PYRO)
        return WEAP_FLAMETHROWER;
    return 0;
};

float () W_OldWeaponSlot6 = {
    if (self.playerclass == PC_DEMOMAN) {
        self.next_weaponmode = 0;
        return WEAP_GRENADE_LAUNCHER;
    }
    else if (self.playerclass == PC_PYRO)
        return WEAP_FLAMETHROWER;
    return 0;  
};

float () W_OldWeaponSlot7 = {
    if (self.playerclass == PC_SOLDIER)
        return WEAP_ROCKET_LAUNCHER;
    if (self.playerclass == PC_DEMOMAN)
        return WEAP_GRENADE_LAUNCHER;
    else if (self.playerclass == PC_HVYWEAP)
        return WEAP_ASSAULT_CANNON;
    else if (self.playerclass == PC_PYRO)
        return WEAP_INCENDIARY;
    return 0;
};

float () W_WeaponSlot1 = {
    if (self.playerclass == PC_SCOUT)
        return WEAP_NAILGUN;
    else if (self.playerclass == PC_SNIPER)
        return WEAP_SNIPER_RIFLE;
    else if (self.playerclass == PC_SOLDIER)
        return WEAP_ROCKET_LAUNCHER;
    else if (self.playerclass == PC_DEMOMAN)
        return WEAP_GRENADE_LAUNCHER;
    else if (self.playerclass == PC_MEDIC)
        return WEAP_SUPER_NAILGUN;
    else if (self.playerclass == PC_HVYWEAP)
        return WEAP_ASSAULT_CANNON;
    else if (self.playerclass == PC_PYRO)
        return WEAP_FLAMETHROWER;
    else if (self.playerclass == PC_SPY)
        return WEAP_TRANQ;
    else if (self.playerclass == PC_ENGINEER)
        return WEAP_LASER;
    return 0;
};

float () W_WeaponSlot2 = {
    if (self.playerclass == PC_SCOUT)
        return WEAP_SHOTGUN;
    else if (self.playerclass == PC_SNIPER)
        return WEAP_AUTO_RIFLE;
    else if (self.playerclass == PC_SOLDIER
                || self.playerclass == PC_MEDIC
                || self.playerclass == PC_HVYWEAP
                || self.playerclass == PC_SPY
                || self.playerclass == PC_ENGINEER)
        return WEAP_SUPER_SHOTGUN;
    else if (self.playerclass == PC_DEMOMAN) {
        return WEAP_GRENADE_LAUNCHER; // weaponmode = 1 (pipebomb launcher)
    } else if (self.playerclass == PC_PYRO)
        return WEAP_INCENDIARY;
    return 0;
};

float () W_WeaponSlot3 = {
    if (self.playerclass == PC_SCOUT
                || self.playerclass == PC_ENGINEER) {
        sprint(self, PRINT_HIGH, "No weapon\n");
        return 0;
    }

    if (self.playerclass == PC_SNIPER
                || self.playerclass == PC_SPY)
        return WEAP_NAILGUN;
    else if (self.playerclass == PC_SOLDIER
                || self.playerclass == PC_DEMOMAN
                || self.playerclass == PC_MEDIC
                || self.playerclass == PC_HVYWEAP
                || self.playerclass == PC_PYRO)
        return WEAP_SHOTGUN;
    return 0;
};

float () W_WeaponSlot4 = {
    if (self.weapons_carried & WEAP_MEDIKIT)
        return WEAP_MEDIKIT;
    else if (self.weapons_carried & WEAP_SPANNER)
        return WEAP_SPANNER;
    else
        return WEAP_AXE;
};

void (float slot) W_WeaponSlot = {
    self.next_weaponmode = 0;
    if (slot == 1)
        self.next_weapon = W_WeaponSlot1();
    else if (slot == 2) {
        self.next_weapon = W_WeaponSlot2();
        if (self.next_weapon == WEAP_GRENADE_LAUNCHER)
            self.next_weaponmode = 1;
    }
    else if (slot == 3)
        self.next_weapon = W_WeaponSlot3();
    else if (slot == 4)
        self.next_weapon = W_WeaponSlot4();
};

void (float inp) W_OldWeaponSlot = {
    self.next_weaponmode = 0;
    if (inp == 1) {
        self.next_weapon = W_OldWeaponSlot1();
    }
    else if (inp == 2) {
        self.next_weapon = W_OldWeaponSlot2();
    }
    else if (inp == 3) {
        self.next_weapon = W_OldWeaponSlot3();
    }
    else if (inp == 4) {
        self.next_weapon = W_OldWeaponSlot4();
    }
    else if (inp == 5) {
        self.next_weapon = W_OldWeaponSlot5();
    }
    else if (inp == 6) {
        self.next_weapon = W_OldWeaponSlot6();
    }
    else if (inp == 7) {
        self.next_weapon = W_OldWeaponSlot7();
        if (self.next_weapon == WEAP_GRENADE_LAUNCHER)
            self.next_weaponmode = 1;
    }
    if (self.next_weapon == 0) {
        self.next_weapon = self.current_weapon;
        sprint(self, PRINT_HIGH, "No weapon\n"); 
    }
}

float (float newSlot) W_OldImpulseFromNewSlot = {
    if (newSlot == 1) {
        if (self.playerclass == PC_SCOUT) {
            return W_OldGetSlot(WEAP_NAILGUN);
        }
        else if (self.playerclass == PC_SNIPER) {
            return W_OldGetSlot(WEAP_SNIPER_RIFLE);
        }
        else if (self.playerclass == PC_SOLDIER) {
            return W_OldGetSlot(WEAP_ROCKET_LAUNCHER);
        }
        else if (self.playerclass == PC_DEMOMAN) {
            return 6;
        }
        else if (self.playerclass == PC_MEDIC) {
            return W_OldGetSlot(WEAP_SUPER_NAILGUN);
        }
        else if (self.playerclass == PC_HVYWEAP) {
            return W_OldGetSlot(WEAP_ASSAULT_CANNON);
        }
        else if (self.playerclass == PC_PYRO) {
            return W_OldGetSlot(WEAP_INCENDIARY);
        }
        else if (self.playerclass == PC_SPY) {
            return W_OldGetSlot(WEAP_TRANQ);
        }
        else if (self.playerclass == PC_ENGINEER) {
            return W_OldGetSlot(WEAP_LASER);
        }
    }
    else if (newSlot == 2) {
        if (self.playerclass == PC_SCOUT) {
            return W_OldGetSlot(WEAP_SHOTGUN);
        }
        else if (self.playerclass == PC_SNIPER) {
            return W_OldGetSlot(WEAP_AUTO_RIFLE);
        }
        else if (self.playerclass == PC_SOLDIER) {
            return W_OldGetSlot(WEAP_SUPER_SHOTGUN);
        }
        else if (self.playerclass == PC_DEMOMAN) {
            return 7;
        }
        else if (self.playerclass == PC_MEDIC) {
            return W_OldGetSlot(WEAP_SUPER_SHOTGUN);
        }
        else if (self.playerclass == PC_HVYWEAP) {
            return W_OldGetSlot(WEAP_SUPER_SHOTGUN);
        }
        else if (self.playerclass == PC_PYRO) {
            return W_OldGetSlot(WEAP_FLAMETHROWER);
        }
        else if (self.playerclass == PC_SPY) {
            return W_OldGetSlot(WEAP_SUPER_SHOTGUN);
        }
        else if (self.playerclass == PC_ENGINEER) {
            return W_OldGetSlot(WEAP_SUPER_SHOTGUN);
        }
    }
    else if (newSlot == 3) {
        if (self.playerclass == PC_SCOUT) {
            return W_OldGetSlot(WEAP_NAILGUN);
        }
        else if (self.playerclass == PC_SNIPER) {
            return W_OldGetSlot(WEAP_NAILGUN);
        }
        else if (self.playerclass == PC_SOLDIER) {
            return W_OldGetSlot(WEAP_SHOTGUN);
        }
        else if (self.playerclass == PC_DEMOMAN) {
            return W_OldGetSlot(WEAP_SHOTGUN);
        }
        else if (self.playerclass == PC_MEDIC) {
            return W_OldGetSlot(WEAP_SHOTGUN);
        }
        else if (self.playerclass == PC_HVYWEAP) {
            return W_OldGetSlot(WEAP_SHOTGUN);
        }
        else if (self.playerclass == PC_PYRO) {
            return W_OldGetSlot(WEAP_SHOTGUN);
        }
        else if (self.playerclass == PC_SPY) {
            return W_OldGetSlot(WEAP_NAILGUN);
        }
        else if (self.playerclass == PC_ENGINEER) {
            return W_OldGetSlot(WEAP_LASER);
        }
    }
    else if (newSlot == 4) {
        if (self.playerclass == PC_SCOUT) {
            return W_OldGetSlot(WEAP_AXE);
        }
        else if (self.playerclass == PC_SNIPER) {
            return W_OldGetSlot(WEAP_AXE);
        }
        else if (self.playerclass == PC_SOLDIER) {
            return W_OldGetSlot(WEAP_AXE);
        }
        else if (self.playerclass == PC_DEMOMAN) {
            return W_OldGetSlot(WEAP_AXE);
        }
        else if (self.playerclass == PC_MEDIC) {
            return W_OldGetSlot(WEAP_MEDIKIT);
        }
        else if (self.playerclass == PC_HVYWEAP) {
            return W_OldGetSlot(WEAP_AXE);
        }
        else if (self.playerclass == PC_PYRO) {
            return W_OldGetSlot(WEAP_AXE);
        }
        else if (self.playerclass == PC_SPY) {
            return W_OldGetSlot(WEAP_AXE);
        }
        else if (self.playerclass == PC_ENGINEER) {
            return W_OldGetSlot(WEAP_SPANNER);
        }
    }
    return 0;
}

void () W_AmmoError = {
    if (self.noammo == 1)
        sprint(self, PRINT_HIGH, "Not enough ammo\n");
    else if (self.noammo == 2 && time >= self.antispam_assault_cannon) {
        sprint(self, PRINT_HIGH, "Not enough cells to power the assault cannon\n");
        self.antispam_assault_cannon = time + 3;
    }
};

void (entity pl) W_WeaponState_Save = {
    if (!WeaponReady(pl))
        return;

    pl.weaponstate_current_weaponslot = pl.current_weaponslot;
    pl.weaponstate_last_weaponslot = pl.last_weaponslot;
    pl.weaponstate_current_weapon = pl.current_weapon;
    pl.weaponstate_last_weapon = pl.last_weapon;
    pl.weaponstate_weaponmode = pl.weaponmode;
    pl.weaponstate_last_weaponmode = pl.last_weaponmode;
}

void (entity pl, float swap) W_WeaponState_Load = {
    if (!swap) {
        pl.current_weaponslot = pl.weaponstate_current_weaponslot;
        pl.last_weaponslot    = pl.weaponstate_last_weaponslot;
        pl.current_weapon     = pl.weaponstate_current_weapon;
        pl.last_weapon        = pl.weaponstate_last_weapon;
        pl.weaponmode         = pl.weaponstate_weaponmode;
        pl.last_weaponmode    = pl.weaponstate_last_weaponmode;
    } else {
        pl.current_weaponslot = pl.weaponstate_last_weaponslot;
        pl.last_weaponslot    = pl.weaponstate_current_weaponslot;
        pl.current_weapon     = pl.weaponstate_last_weapon;
        pl.last_weapon        = pl.weaponstate_current_weapon;
        pl.weaponmode         = pl.weaponstate_last_weaponmode;
        pl.last_weaponmode    = pl.weaponstate_weaponmode;
    }
    pl.queue_weaponstate = 0;

    W_WeaponState_Save(pl);
    W_SetCurrentAmmo(pl);
    Status_Refresh(pl);
}

float (entity pl) W_WeaponState_Check = {
                                           //  bprint(2,ftos(pl.current_weaponslot == pl.weaponstate_current_weaponslot));
    //bprint(2,"\n");
    if (pl.current_weaponslot == pl.weaponstate_current_weaponslot
                && pl.last_weaponslot == pl.weaponstate_last_weaponslot)
        return 1;
    else
        return 0;
}

void (float inp) W_ChangeWeapon = {
    if(self.playerclass == PC_CIVILIAN) {
        inp = 4;
    }
    if (inp < 1 || inp > GetLastWeaponImpulse())
        return;

    if (self.playerclass == 0)
        return;

    // queue next weapon if queue is not empty or has changed
    if (!self.queue_weaponslot || inp != self.queue_weaponslot)
        self.queue_weaponslot = inp;

    // halt if weapon is not ready to be fired
    if (!WeaponReady(self) && chweap_wait_attfinished)
        return;
    
    if (IsUsingOldImpulses()) {
        if(self.playerclass == PC_CIVILIAN) {
            inp = 1;
        }
        // check for ammo
        if (! W_OldAmmoSlot(inp)) {
            W_AmmoError();
            self.queue_weaponslot = 0;
            return;
        }
        W_OldWeaponSlot(inp);
    }
    else {
        // check for ammo
        if (! W_AmmoSlot(inp)) {
            W_AmmoError();
            self.queue_weaponslot = 0;
            return;
        }

        W_WeaponSlot(inp);
    }

    // don't update current/last weapon information if next weapon is the same as current
    if (self.current_weapon != self.next_weapon || self.weaponmode != self.next_weaponmode) {
        self.last_weaponslot = self.current_weaponslot;
        self.current_weaponslot = self.queue_weaponslot;
        self.last_weapon = self.current_weapon;
        self.current_weapon = self.next_weapon;
        self.last_weaponmode = self.weaponmode;
        self.weaponmode = self.next_weaponmode;

        if (!self.is_quickfiring)
            W_PrintWeaponMessage();
    }

    if (!self.is_quickfiring && !self.has_quickfired)
        W_WeaponState_Save(self);

    W_SetCurrentAmmo(self);
    Status_Refresh(self);
    self.queue_weaponslot = 0;
};

void () CycleWeaponLast = {
    if (!self.last_weaponslot)
        return;

    if (!self.is_quickfiring)
        W_ChangeWeapon(self.last_weaponslot);
    else
        W_WeaponState_Load(self, 1);
};

void () CycleWeaponNext = {
    local float slot, next;

    if (self.weaponmodel == string_null || self.current_weapon == 0)
        return;

    next = 0;
    if (!IsUsingOldImpulses()) {
        for (slot = 1; slot <= 4; slot++) {
            next = (slot == 4) ? 1 : (slot + 1);
            if (self.current_weaponslot == slot) {
                while (! W_AmmoSlot(next))
                    next = (next == 4) ? 1 : (next + 1);
                break;
            }
        }
    }
    else if (IsUsingOldImpulses()) {
        for (slot = self.current_weaponslot; slot <= GetLastWeaponImpulse(); slot++) {
            next = (slot == GetLastWeaponImpulse()) ? 1 : (slot + 1);
            if (next == 1) {
                if (W_OldWeaponSlot1() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 2) {
                if (W_OldWeaponSlot2() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 3) {
                if (W_OldWeaponSlot3() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 4) {
                if (W_OldWeaponSlot4() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 5) {
                if (W_OldWeaponSlot5() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 6) {
                if (W_OldWeaponSlot6() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 7) {
                if (W_OldWeaponSlot7() && W_OldAmmoSlot(next))
                    break;
            }
        }
    }
    W_ChangeWeapon(next);
};

void () CycleWeaponPrev = {
    local float slot, next;

    if (self.weaponmodel == string_null || self.current_weapon == 0)
        return;

    next = 0;
    if (!IsUsingOldImpulses()) {
        for (slot = 1; slot <= 4; slot++) {
            next = (slot == 1) ? 4 : (slot - 1);
            if (self.current_weaponslot == slot) {
                while (! W_AmmoSlot(next))
                    next = (next == 1) ? 4 : (next - 1);
                break;
            }
        }
    }
    else {
        for (slot = self.current_weaponslot; slot >= 1; slot--) {
            next = (slot == 1) ? GetLastWeaponImpulse() : (slot - 1);
            if (next == 1) {
                if (W_OldWeaponSlot1() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 2) {
                if (W_OldWeaponSlot2() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 3) {
                if (W_OldWeaponSlot3() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 4) {
                if (W_OldWeaponSlot4() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 5) {
                if (W_OldWeaponSlot5() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 6) {
                if (W_OldWeaponSlot6() && W_OldAmmoSlot(next))
                    break;
            }
            else if (next == 7) {
                if (W_OldWeaponSlot7() && W_OldAmmoSlot(next))
                    break;
            }
        }
    }
     

    W_ChangeWeapon(next);
};

void () PreMatchImpulses;
void () DeadImpulses;

void () ImpulseCommands = {
    float clearImpulse; // related to impulse_queue
    clearImpulse = TRUE;

    if ((self.last_impulse == TF_DETPACK) && self.impulse)
        TeamFortress_SetDetpack(self.impulse);

    if (cb_prematch || cease_fire) {
        PreMatchImpulses();
        DeadImpulses();
        self.impulse = 0;
        return;
    }
    if (self.impulse == TF_SPECIAL_SKILL)
        UseSpecialSkill();

    if (self.impulse == TF_NEXTTIP) {
        self.display_tip = 0;
        self.tip_type = 0;
        self.tip_time = time;
        Status_Refresh(self);
    }

    if (self.impulse == TF_WEAPLAST) {
        if (self.playerclass == PC_SPY && self.is_undercover == 2)
            CF_Spy_DisguiseStop();
        else if (self.playerclass == PC_ENGINEER && self.is_building) {
            TeamFortress_EngineerBuildStop();
            CycleWeaponLast();
        } else if (self.playerclass == PC_DEMOMAN && self.is_detpacking) {
            TeamFortress_DetpackStop();
            CycleWeaponLast();
        }
    } else if (self.impulse == TF_TOGGLEVOTE)
        Vote_ToggleMenu(self);

    if (!self.is_feigning) {
        if (self.impulse == TF_GRENADE_1)
            TeamFortress_PrimeGrenade(1);
        else if (self.impulse == TF_GRENADE_2)
            TeamFortress_PrimeGrenade(2);
        else if (self.impulse == TF_GRENADE_PT_1)
            TeamFortress_PrimeThrowGrenade(1);
        else if (self.impulse == TF_GRENADE_PT_2)
            TeamFortress_PrimeThrowGrenade(2);
    }

    if ((!self.is_building && !self.is_detpacking) && !self.is_feigning) {
        if (self.impulse == TF_WEAPNEXT)
            CycleWeaponNext();
        else if (self.impulse == TF_WEAPPREV)
            CycleWeaponPrev();
        else if (self.impulse == TF_RELOAD)
            TeamFortress_ReloadCurrentWeapon();
        else if (self.impulse == TF_RELOAD_SLOT1)
            TeamFortress_ReloadSlot(1);
        else if (self.impulse == TF_RELOAD_SLOT2)
            TeamFortress_ReloadSlot(2);
        else if (self.impulse == TF_RELOAD_SLOT3)
            TeamFortress_ReloadSlot(3);
        else if (self.impulse == TF_RELOAD_NEXT)
            TeamFortress_ReloadNext();
        else if (self.impulse == TF_DETPACK_5)
            TeamFortress_SetDetpack(5);
        else if (self.impulse == TF_DETPACK_20)
            TeamFortress_SetDetpack(20);
        else if (self.impulse == TF_DETPACK_50)
            TeamFortress_SetDetpack(50);
        else if (self.impulse == TF_DROP_AMMO) {
            Menu_Drop();
        }
    }

    if (self.impulse == TF_INVENTORY)
        TeamFortress_Inventory();
    else if ((self.playerclass != 0) && (self.impulse == TF_MEDIC_HELPME))
        TeamFortress_SaveMe();
    else if (self.impulse == TF_GRENADE_T)
        TeamFortress_ThrowGrenade();
    else if (self.impulse == TF_GRENADE_SWITCH)
        TeamFortress_GrenadeSwitch();
    else if (self.impulse == TF_ID)
        CF_Identify(self, 1);
    else if (self.impulse == TF_ID_TEAM)
        CF_Identify(self, 2);
    else if (self.impulse == TF_ID_ENEMY)
        CF_Identify(self, 3);
    else if (self.impulse == TF_SHOW_IDS)
        TeamFortress_ShowIDs();
    else if ((self.playerclass != 0) && (self.impulse == TF_DROPFLAG))
        DropGoalItems();
    else if (self.impulse == TF_DISCARD)
        TeamFortress_Discard();
    else if (self.impulse == TF_DISCARD_DROP_AMMO)
        TeamFortress_Discard_DropAmmo();
    else if (self.impulse == TF_DASH)
        CF_Scout_Dash();
    else if (self.impulse == TF_PB_DETONATE)       
        clearImpulse = TeamFortress_DetonatePipebombs(0);
    else if (self.impulse == TF_DETPACK_STOP)
        TeamFortress_DetpackStop();
    else if (self.impulse == TF_MEDIC_AURA_TOGGLE)
        CF_Medic_AuraToggle();
    else if ((self.impulse == TF_ENGINEER_DETSENTRY) &&
             (self.playerclass == PC_ENGINEER))
        DestroyBuilding(self, "building_sentrygun");
    else if ((self.impulse == TF_ENGINEER_DETDISP) &&
             (self.playerclass == PC_ENGINEER))
        DestroyBuilding(self, "building_dispenser");
    else if ((self.impulse == 196) && (self.playerclass == PC_ENGINEER))
        DestroyBuilding(self, "building_teleporter_exit");
    else if ((self.impulse == 197) && (self.playerclass == PC_ENGINEER))
        DestroyBuilding(self, "building_teleporter_entrance");
    else if ((self.impulse == TF_SPY_SPY) && (self.playerclass == PC_SPY)) {
        if (invis_only)
            CF_Spy_Invisible();
        else
            Menu_Spy_Skin();
    } else if ((self.impulse == TF_SPY_DIE) && (self.playerclass == PC_SPY))
        CF_Spy_FeignDeath(0);
    else if ((self.impulse == TF_SPY_SILENT_DIE) &&
             (self.playerclass == PC_SPY))
        CF_Spy_FeignDeath(1);
    else if (self.impulse == TF_DISGUISE_RESET && self.playerclass == PC_SPY) {
        CF_Spy_ChangeSkin(self, 8);
        CF_Spy_ChangeColor(self, self.team_no);
    } else if (self.impulse == TF_DISGUISE_SCOUT && self.playerclass == PC_SPY)
        CF_Spy_ChangeSkin(self, 1);
    else if (self.impulse == TF_DISGUISE_SNIPER && self.playerclass == PC_SPY)
        CF_Spy_ChangeSkin(self, 2);
    else if (self.impulse == TF_DISGUISE_SOLDIER && self.playerclass == PC_SPY)
        CF_Spy_ChangeSkin(self, 3);
    else if (self.impulse == TF_DISGUISE_DEMOMAN && self.playerclass == PC_SPY)
        CF_Spy_ChangeSkin(self, 4);
    else if (self.impulse == TF_DISGUISE_MEDIC && self.playerclass == PC_SPY)
        CF_Spy_ChangeSkin(self, 5);
    else if (self.impulse == TF_DISGUISE_HWGUY && self.playerclass == PC_SPY)
        CF_Spy_ChangeSkin(self, 6);
    else if (self.impulse == TF_DISGUISE_PYRO && self.playerclass == PC_SPY)
        CF_Spy_ChangeSkin(self, 7);
    else if (self.impulse == TF_DISGUISE_ENGINEER && self.playerclass == PC_SPY)
        CF_Spy_ChangeSkin(self, 9);
    else if (self.impulse == TF_DISGUISE_BLUE && self.playerclass == PC_SPY)
        CF_Spy_ChangeColor(self, 1);
    else if (self.impulse == TF_DISGUISE_RED && self.playerclass == PC_SPY)
        CF_Spy_ChangeColor(self, 2);
    else if (self.impulse == TF_DISGUISE_YELLOW && self.playerclass == PC_SPY)
        CF_Spy_ChangeColor(self, 3);
    else if (self.impulse == TF_DISGUISE_GREEN && self.playerclass == PC_SPY)
        CF_Spy_ChangeColor(self, 4);
    else if (self.impulse == TF_DISGUISE_ENEMY && self.playerclass == PC_SPY) {
        if (number_of_teams > 2)
            Menu_Spy_Color();
        else if (self.team_no == 1)
            CF_Spy_ChangeColor(self, 2);
        else
            CF_Spy_ChangeColor(self, 1);
    } else if (self.impulse == TF_DISGUISE_LAST && self.playerclass == PC_SPY)
        CF_Spy_DisguiseLast();
    else if ((self.impulse == TF_DEMOMAN_DETPACK) &&
             (self.playerclass == PC_DEMOMAN))
        TeamFortress_DetpackMenu();
    else if ((self.impulse == TF_ENGINEER_BUILD) &&
             (self.playerclass == PC_ENGINEER))
        TeamFortress_EngineerBuild();
    else if (self.impulse == FLAG_INFO) {
        if (CTF_Map == 1)
            TeamFortress_CTF_FlagInfo();
        else
            TeamFortress_DisplayDetectionItems();
    } else if (self.impulse == TF_DISPLAYLOCATION)
        display_location();
    else
        DeadImpulses();

    if (self.impulse == TF_DETPACK)
        self.last_impulse = self.impulse;

    if (clearImpulse)
    {
        self.impulse = 0;
    }
    
};

void () PreMatchImpulses = {
    if (self.impulse == TF_WEAPNEXT)
        CycleWeaponNext();
    else if (self.impulse == TF_WEAPPREV)
        CycleWeaponPrev();

    if (self.impulse == TF_INVENTORY)
        TeamFortress_Inventory();
    else if (self.impulse == TF_ID)
        CF_Identify(self, 0);
    else if (self.impulse == FLAG_INFO) {
        if (CTF_Map == TRUE)
            TeamFortress_CTF_FlagInfo();
        else
            TeamFortress_DisplayDetectionItems();
    } else if (self.impulse == TF_DISPLAYLOCATION)
        display_location();

    if (self.impulse == TF_SPECIAL_SKILL) {
        if(self.tfstate & TFSTATE_INVINCIBLE) {
            self.items = self.items - (self.items & IT_INVULNERABILITY);
            self.invincible_time = 0;
            self.invincible_finished = 0;
            self.tfstate = self.tfstate - (self.tfstate & TFSTATE_INVINCIBLE);
            self.effects = self.effects - (self.effects & (EF_RED + EF_DIMLIGHT + EF_BRIGHTLIGHT));
        } else {
            self.items = self.items | IT_INVULNERABILITY;
            self.invincible_time = 1;
            self.tfstate = self.tfstate | TFSTATE_INVINCIBLE;
            self.invincible_finished = time + 666;
        }
    }
};

void () DeadImpulses = {
    if (self.impulse == TF_SHOWTF)
        TeamFortress_ShowTF();
    else if (self.impulse == TF_CLASSHELP)
        Help_Show();
    else if (self.impulse == TF_SHOWLEGALCLASSES)
        TeamFortress_DisplayLegalClasses();
    else if ((self.impulse >= TF_CHANGEPC_SCOUT) && (self.impulse <= TF_CHANGEPC_RANDOM)) {
        TeamFortress_ChangeClass(self.impulse - TF_CHANGEPC_SCOUT + 1);
    } else if ((self.playerclass != 0) && (self.impulse == TF_CHANGETEAM)
               && (deathmatch == 3) && (!cb_prematch)) {
        if (loginRequired && !self.login) {
            sprint (self, 2, "Login required, please use \"cmd login <login> <secret>\" before joining the game\n");
            return;
        }
        Menu_Team(0);
    } else if ((self.playerclass != 0) && (self.impulse == TF_CHANGECLASS)
               && (deathmatch == 3) && (!cb_prematch)) {
        Menu_Class(0);
    } else if (self.is_admin) {
        if (self.impulse == TF_ADMIN_CEASEFIRE)
            Admin_CeaseFire();
        else if (self.impulse == TF_ADMIN_COUNTPLAYERS)
            Admin_CountPlayers();
        else if (self.impulse == TF_ADMIN_CYCLEDEAL)
            Admin_CycleDeal();
        else if ((self.impulse == TF_ADMIN_KICK) && (self.admin_mode == 1))
            Admin_DoKick();
        else if ((self.impulse == TF_ADMIN_BAN) && (self.admin_mode == 1))
            Admin_DoBan();
        else if ((self.impulse == TF_ADMIN_NEXT) && (self.admin_mode == 1))
            Admin_CycleDeal();
        else if (self.impulse == TF_ADMIN_LISTIPS)
            Admin_ListIPs();
        else if (self.impulse == TF_ADMIN_CLANMODE)
            ClanMode();
        else if (self.impulse == TF_ADMIN_QUADMODE)
            QuadMode();
        else if (self.impulse == TF_ADMIN_DUELMODE)
            DuelMode();
        else if (self.impulse == TF_ADMIN_ADMINMENU) {
            self.current_menu_page = 1;
            Menu_Admin();
        }
        else if (self.impulse == TF_ADMIN_FORCESTARTMATCH) {
            StartTimer();
        }
        else if (self.impulse == TF_ADMIN_READYSTATUS)
            Broadcast_Players_NotReady();
    }
    if (self.impulse == TF_HELP_MAP)
        TeamFortress_HelpMap();
    else if (self.impulse == TF_NAILGREN_INFO)
	TeamFortress_NailGrenInfo(); 
    else if (self.impulse == TF_STATUS_QUERY)
        TeamFortress_StatusQuery();
    else if (self.impulse == TF_TEAM_1 && number_of_teams > 0)
        TeamFortress_TeamSet(1);
    else if (self.impulse == TF_TEAM_2 && number_of_teams > 1)
        TeamFortress_TeamSet(2);
    else if (self.impulse == TF_TEAM_3 && number_of_teams > 2)
        TeamFortress_TeamSet(3);
    else if (self.impulse == TF_TEAM_4 && number_of_teams > 3)
        TeamFortress_TeamSet(4);
    else if (self.impulse == TF_TEAM_SCORES)
        TeamFortress_TeamShowScores(0);
    else if (self.impulse == TF_TEAM_CLASSES)
        TeamFortress_TeamShowMemberClasses(self);
    else if ((self.playerclass == PC_SCOUT) && (self.impulse == TF_SCAN))
        ScannerSwitch();
    else if ((self.playerclass == PC_SCOUT) &&
             (self.impulse == TF_SCAN_SOUND)) {
        sprint(self, PRINT_HIGH, "Scanner sound: ");
        if (self.tf_items_flags & 4) {
            self.tf_items_flags = self.tf_items_flags - 4;
            sprint(self, PRINT_HIGH, "off\n");
        } else {
            self.tf_items_flags = self.tf_items_flags | 4;
            sprint(self, PRINT_HIGH, "on\n");
        }
    } else if ((self.playerclass == PC_SCOUT) && (self.impulse == TF_SCAN_ENEMY)) {
        sprint(self, PRINT_HIGH, "Scanning for: ");
        if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
            self.tf_items_flags = self.tf_items_flags - NIT_SCANNER_ENEMY;
            if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
                sprint(self, PRINT_HIGH, "Friendlies only\n");
            } else {
                sprint(self, PRINT_HIGH, "Nothing\n");
            }
        } else {
            self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_ENEMY;
            if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
                sprint(self, PRINT_HIGH, "Friendlies and enemies\n");
            } else {
                sprint(self, PRINT_HIGH, "Enemies only\n");
            }
            Status_Refresh(self);
        }
    } else if ((self.playerclass == PC_SCOUT) && (self.impulse == TF_SCAN_FRIENDLY)) {
        sprint(self, PRINT_HIGH, "Scanning for: ");
        if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
            self.tf_items_flags = self.tf_items_flags - NIT_SCANNER_FRIENDLY;
            if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
                sprint(self, PRINT_HIGH, "Enemies only\n");
            } else {
                sprint(self, PRINT_HIGH, "Nothing\n");
            }
        } else {
            self.tf_items_flags = self.tf_items_flags | NIT_SCANNER_FRIENDLY;
            if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
                sprint(self, PRINT_HIGH, "Friendlies and enemies\n");
            } else {
                sprint(self, PRINT_HIGH, "Friendlies only\n");
            }
        }
        Status_Refresh(self);
    } else if (self.impulse == TF_ALIAS_CHECK) {
        sprint(self, PRINT_HIGH, "Aliases checked\n");
        self.got_aliases = 1;
        self.impulse = 0;
    }
    if (self.impulse == TF_PLAYER_READY) {
        if (clanbattle == 1) {
            if (!cb_prematch) {
                sprint (self, 2, "Match already in progress...\n");
                self.impulse = 0;
                return;
            }
            PlayerReady();
            self.impulse = 0;
            return;
        }
    }
    else if (self.impulse == TF_PLAYER_NOT_READY) {
        if (clanbattle == 1) {
            if (!cb_prematch) {
                sprint (self, 2, "Match already in progress...\n");
                self.impulse = 0;
                return;
            }
            PlayerNotReady();
            self.impulse = 0;
            return;
        }
    }
};


void () W_WeaponFrame = {

    if (self.login_in_progress) {
        CenterPrint(self, "Trying to log in...");
    }
    
    if (loginRequired && !self.login) {
        PrintLoginMessage();
        self.impulse = 0;
        return;
    }

    if (self.menu_input) {
        if (self.impulse > 0 && self.impulse <= 10) {
            Menu_Input(self.impulse);
            return;
        }
    }

    if (self.impulse == TF_CLASSMENU && self.playerclass != PC_MEDIC) {
        if (self.playerclass == PC_ENGINEER)
            Menu_Engineer(self);
        else if (self.playerclass == PC_SCOUT)
            Menu_Scout();
        else if (self.playerclass == PC_SPY)
            Menu_Spy(self);
        else if (self.playerclass == PC_DEMOMAN)
            TeamFortress_DetpackMenu();

        self.impulse = 0;
        return;
    }

    if (self.is_feigning && self.impulse != TF_SPECIAL_SKILL && self.impulse != TF_MEDIC_HELPME && self.impulse != TF_SPY_DIE && self.impulse != TF_SPY_SILENT_DIE)
        return;

    if (self.impulse == TF_WEAPLAST && self.is_undercover != 2) {

        // change to last weapon now
        if (WeaponReady(self))
            CycleWeaponLast();
        // change to weaponstate (prior to quick fire) when weapon is ready
        else if (self.is_quickfiring)
            self.queue_weaponstate = 2;
        // change to last weapon when weapon is ready
        else
            self.queue_weaponslot = self.last_weaponslot;
    }

    // when +slotX bind is released, this gets issued
    if (self.impulse == TF_QUICKSTOP && self.is_quickfiring) {

        self.has_quickfired = 1;
        self.impulse = 0;

    }

    // unset quick firing variables when quick weapon has finished firing
    if (self.is_quickfiring && self.has_quickfired && WeaponReady(self)) {

        self.is_quickfiring = 0;
        self.has_quickfired = 0;

    }

    // slot 1-4 (or 1-7) binds
    if (self.impulse >= 1 && self.impulse <= GetLastWeaponImpulse() && (WeaponReady(self) || !chweap_wait_attfinished)
                && !(self.is_building && !engineer_move) && !self.is_detpacking) {

        if (!(self.tfstate & TFSTATE_RELOADING)) {
            // load weapon state if current state doesn't match stored state
            if (!W_WeaponState_Check(self))
                W_WeaponState_Load(self, 0);

            // obviously not quickfiring if we're changing weapon
            self.is_quickfiring = 0;
            self.has_quickfired = 0;
            W_ChangeWeapon(self.impulse);
        } 
        else if (!chweap_wait_attfinished) {
            //clears impulse so it doesn't switch weapons just after reloading   
            self.impulse = 0;
        }

    // regular attack (both +attack and -attack)
    } else if (!self.impulse && !self.is_quickfiring) {

        // load weapon state if current state doesn't match
        // stored state, if weapon is ready
        if (!W_WeaponState_Check(self) && WeaponReady(self) && !(self.tfstate & TFSTATE_AIMING)) {
            W_WeaponState_Load(self, 0);
        }

    // +slot1-4 quick fire
    } else if (self.impulse >= TF_QUICKSLOT1 && self.impulse <= TF_QUICKSLOT4 && !self.is_detpacking) {

        self.is_quickfiring = 1;
        self.has_quickfired = 0;

        if (WeaponReady(self)) {
            if (!IsUsingOldImpulses()) {
                if (self.impulse == TF_QUICKSLOT1)
                    W_ChangeWeapon(1);
                else if (self.impulse == TF_QUICKSLOT2)
                    W_ChangeWeapon(2);
                else if (self.impulse == TF_QUICKSLOT3)
                    W_ChangeWeapon(3);
                else if (self.impulse == TF_QUICKSLOT4)
                    W_ChangeWeapon(4);
            }
            else {
                if (self.impulse == TF_QUICKSLOT1)
                    W_ChangeWeapon(W_OldImpulseFromNewSlot(1));
                else if (self.impulse == TF_QUICKSLOT2)
                    W_ChangeWeapon(W_OldImpulseFromNewSlot(2));
                else if (self.impulse == TF_QUICKSLOT3)
                    W_ChangeWeapon(W_OldImpulseFromNewSlot(3));
                else if (self.impulse == TF_QUICKSLOT4)
                    W_ChangeWeapon(W_OldImpulseFromNewSlot(4));
            }
        }

    // change weapon if queue_weaponslot has been set
    } else if (self.queue_weaponslot > 0) {
        W_ChangeWeapon(self.queue_weaponslot);
    // load weapon state
    } else if (self.queue_weaponstate && WeaponReady(self)) {
        // load weaponstate saved from before quick fire started
        if (self.queue_weaponstate == 1)
            W_WeaponState_Load(self, 0);
        // load swapped weaponstate
        else
            W_WeaponState_Load(self, 1);
    }

    if (self.impulse == TF_CHANGETEAM) {
        Menu_Team(0);
        self.impulse = 0;
        return;
    } else if (self.impulse == TF_CHANGECLASS) {
        Menu_Class(0);
        self.impulse = 0;
        return;
    }    
    if (intermission_running)
        return;

    // hwguy assault cannon special
    if (self.playerclass == PC_HVYWEAP) {
        if (cannon_lock && (self.impulse == TF_LOCKON || self.impulse == TF_LOCKOFF)) {
            if (self.impulse == TF_LOCKON)
                self.tfstate = self.tfstate | TFSTATE_LOCK;
            else if (self.impulse == TF_LOCKOFF)
                self.tfstate = self.tfstate - (self.tfstate & TFSTATE_LOCK);
            Status_Refresh(self);
            self.impulse = 0;
            return;
        }
    }

    if (self.playerclass == PC_SNIPER) {
        if (self.impulse == TF_SPECIAL_SKILL || self.impulse == TF_ZOOMTOGGLE) {
            Sniper_ZoomToggle();
            self.impulse = 0;
            return;
        } else if (self.impulse == TF_ZOOMIN || (self.is_zooming && self.impulse == TF_WEAPPREV)) {
            Sniper_ZoomAdjust(1);
            self.impulse = 0;
            return;
        } else if (self.impulse == TF_ZOOMOUT || (self.is_zooming && self.impulse == TF_WEAPNEXT)) {
            Sniper_ZoomAdjust(0);
            self.impulse = 0;
            return;
        }
    }

    // whitelist of commands that can be used even when reloading
    switch (self.impulse)
    {
        case TF_SPECIAL_SKILL:
        case TF_PB_DETONATE:
        case TF_MEDIC_HELPME:
        case TF_DASH:
        case TF_DISCARD:
        case TF_DROPFLAG:
        case TF_CHANGEPC_SCOUT:
        case TF_CHANGEPC_SNIPER:
        case TF_CHANGEPC_SOLDIER:
        case TF_CHANGEPC_DEMOMAN:
        case TF_CHANGEPC_MEDIC:
        case TF_CHANGEPC_HVYWEAP:
        case TF_CHANGEPC_PYRO:
        case TF_CHANGEPC_SPY:
        case TF_CHANGEPC_ENGINEER:
        case TF_CHANGEPC_RANDOM:
        case TF_INVENTORY:
        case FLAG_INFO:
            ImpulseCommands();
            return;
        // allows setting detpack while reloading on toggle, defaults to off        
        case TF_DEMOMAN_DETPACK:
        case TF_DETPACK:
        case TF_DETPACK_STOP:
        case TF_DETPACK_5:
        case TF_DETPACK_20:
        case TF_DETPACK_50:
            if (detpack_when_reloading) {
                ImpulseCommands();
                return;
            }
    }

    //  grenade impulses always possible
    if ((self.impulse >= TF_GRENADE_1 && self.impulse <= TF_GRENADE_SWITCH)) {
        ImpulseCommands();
        return;
    }

    if (!WeaponReady(self))
        return;

    if (self.impulse != 0 && self.has_disconnected == 0)
        ImpulseCommands();
    if (cease_fire)
        return;

    if (self.button0 
        && (!self.fire_held_down 
            || 
            (self.fire_held_down && self.heat == 0 && self.playerclass == PC_HVYWEAP))) {
        if (self.current_weapon == WEAP_SNIPER_RIFLE) {
            if (self.tfstate & TFSTATE_AIMING) {
                if (self.heat < 400) {
                    self.heat = self.heat + 3;
                    if ((sniperpower) && (self.power_time < (time - 0.3))) {
                        self.power_time = time;
                        Status_Refresh(self);
                    }
                } else if ((sniperpower) && (!self.power_full)) {
                    self.power_full = 1;
                    Status_Refresh(self);
                }
            } else {
                local vector tv = self.velocity;
                tv_z = 0;
                if (vlen(tv) <= 50) {
                    SniperSight_Create();
                    self.heat = 50;
                    self.tfstate = self.tfstate | 2048;
                    self.power_full = 0;
                    TeamFortress_SetSpeed(self);
                }
            }
        } else if (self.current_weapon == WEAP_ASSAULT_CANNON) {
            if (self.flags & FL_ONGROUND || cannon_air) {
                SuperDamageSound();
                W_Attack();
            } else if (self.antispam_cannon_air < time) {
                sprint(self, PRINT_MEDIUM, "You cannot fire the assault cannon without your feet on the ground...\n");
                self.antispam_cannon_air = time + 3;
            }
        } else {
            SuperDamageSound();
            W_Attack();
        }
    } else if (self.playerclass == 0) {
        self.weaponmode = 0;
    } else if (self.tfstate & TFSTATE_AIMING) {
        W_Attack();
        self.tfstate = self.tfstate - TFSTATE_AIMING;
        TeamFortress_SetSpeed(self);
        self.heat = 0;
    } else if (self.tfstate & TFSTATE_CANT_MOVE && !self.is_feigning) {
        self.tfstate = self.tfstate - TFSTATE_CANT_MOVE;
        TeamFortress_SetSpeed(self);
        self.heat = 0;
    }
};

void () SuperDamageSound = {
    if (self.super_damage_finished > time) {
        if (self.super_sound < time) {
            self.super_sound = time + 1;
            FO_Sound(self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
        }
    }
    return;
};

void () RemoveGrenade = {
    local entity te;

    if (self.no_active_napalm_grens > 0) {

        self.no_active_napalm_grens = 0;
        self.owner.no_active_napalm_grens =
            self.owner.no_active_napalm_grens - 1;
        if (self.owner.no_active_napalm_grens < 0)
            self.owner.no_active_napalm_grens = 0;

        te = find(world, classname, "grentimer");
        while (te) {
            if ((te.owner == self.owner) &&
                (te.no_active_napalm_grens > 0))
                te.no_active_napalm_grens = te.no_active_napalm_grens - 1;
            te = find(te, classname, "grentimer");
        }
        dremove(self.enemy);
        dremove(self);
    }
    if (self.no_active_gas_grens > 0) {

        self.no_active_gas_grens = 0;
        self.owner.no_active_gas_grens =
            self.owner.no_active_gas_grens - 1;
        if (self.owner.no_active_gas_grens < 0)
            self.owner.no_active_gas_grens = 0;

        te = find(world, classname, "grentimer");
        while (te) {
            if ((te.owner == self.owner) && (te.no_active_gas_grens > 0))
                te.no_active_gas_grens = te.no_active_gas_grens - 1;
            te = find(te, classname, "grentimer");
        }
        dremove(self);
    }
};
