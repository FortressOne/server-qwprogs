// name = [framenum, nexttime, nextthink] {code}
// expands to:
// name ()
// {
//      self.frame=framenum;
//      self.nextthink = time + nexttime;
//      self.think = nextthink;
//      <code>
// };

void () bubble_bob;
void () T_Dispenser;
void () Headless_Think;

void () player_touch = {
    local entity Bio;
    local entity te;
    local float found;
    te = world;

    if ((invis_only == 0) &&
        ((self.playerclass == 8) || (other.playerclass == 8))) {
        if (other.classname == "player") {
            if ((self.undercover_team != 0) || (self.undercover_skin != 0)) {
                if (((other.playerclass == PC_SPY) ||
                     (other.playerclass == PC_SCOUT))
                    && (other.team_no != self.team_no)) {
                    TF_AddFrags(other, 1);
                    bprint(PRINT_MEDIUM, other.netname,
                           " uncovered an enemy spy!\n");
                    Spy_RemoveDisguise(self);
                }
            }
            if ((other.undercover_team != 0) ||
                (other.undercover_skin != 0)) {
                if (((self.playerclass == PC_SPY) ||
                     (self.playerclass == PC_SCOUT))
                    && (self.team_no != other.team_no)) {
                    TF_AddFrags(self, 1);
                    bprint(PRINT_MEDIUM, self.netname,
                           " uncovered an enemy spy!\n");
                    Spy_RemoveDisguise(other);
                }
            }
        }
    }
    if ((self.tfstate & TFSTATE_INFECTED) && (!cb_prematch)) {
        if ((other.classname == "player") && (te.playerclass != 0)) {
            if (!(other.tfstate & TFSTATE_INFECTED)) {
                if (other.playerclass != 5) {
                    if (!((teamplay & 16)
                          && (self.owner.team_no == self.enemy.team_no)
                          && (self.owner.team_no != 0))) {
                        found = 0;
                        te = find(world, classname, "timer");
                        while ((te != world) && (found == 0)) {
                            if ((te.owner == self) &&
                                (te.think == BioInfection_Decay)) {
                                found = 1;
                            } else {
                                te = find(te, classname, "timer");
                            }
                        }
                        Bio = spawn();
                        Bio.nextthink = 2;
                        Bio.think = BioInfection_Decay;
                        Bio.owner = other;
                        Bio.classname = "timer";
                        Bio.enemy = te.enemy;
                        other.tfstate = other.tfstate | TFSTATE_INFECTED;
                        other.infection_team_no = self.infection_team_no;
                        LogEventAffliction(te.enemy, other, TFSTATE_INFECTED);
                        LogEventAffliction(self, other, TFSTATE_INFECTED);
                        sprint(other, PRINT_MEDIUM,
                               "You have been infected by ", self.netname,
                               "\n");
                        sprint(self, PRINT_MEDIUM, "You have infected ",
                               other.netname, "\n");
                    }
                }
            }
        }
    }
};

void () player_light1 =[105, player_light2] {
    muzzleflash();
    if (!self.button0 || intermission_running) {
        player_run();
        return;
    }
    self.weaponframe = self.weaponframe + 1;
    if (self.weaponframe == 5) {
        self.weaponframe = 1;
    }
    SuperDamageSound();
    W_FireLightning();
    Attack_Finished(0.2);
};

void () player_light2 =[106, player_light1] {
    if (!self.button0 || intermission_running) {
        player_run();
        return;
    }
    self.weaponframe = self.weaponframe + 1;
    if (self.weaponframe == 5) {
        self.weaponframe = 1;
    }
    SuperDamageSound();
    W_FireLightning();
    Attack_Finished(0.2);
};

void (float num_bubbles) DeathBubbles;

void () PainSound = {
    local float rs;

    if (self.health < 0) {
        return;
    }
    if (damage_attacker.classname == "teledeath") {
        FO_Sound(self, CHAN_VOICE, "player/teledth1.wav", 1, 0);
        return;
    }
    if ((self.watertype == -3) && (self.waterlevel == 3)) {
        DeathBubbles(1);
        if (random() > 0.5) {
            FO_Sound(self, CHAN_VOICE, "player/drown1.wav", 1, 1);
        } else {
            FO_Sound(self, CHAN_VOICE, "player/drown2.wav", 1, 1);
        }
        return;
    }
    if (self.watertype == -4) {
        if (random() > 0.5) {
            FO_Sound(self, CHAN_VOICE, "player/lburn1.wav", 1, 1);
        } else {
            FO_Sound(self, CHAN_VOICE, "player/lburn2.wav", 1, 1);
        }
        return;
    }
    if (self.watertype == CONTENT_LAVA) {
        if (random() > 0.5) {
            FO_Sound(self, CHAN_VOICE, "player/lburn1.wav", 1, 1);
        } else {
            FO_Sound(self, CHAN_VOICE, "player/lburn2.wav", 1, 1);
        }
        return;
    }
    if (self.pain_finished > time) {
        self.axhitme = 0;
        return;
    }
    self.pain_finished = time + 0.5;
    if (self.axhitme == 1) {
        self.axhitme = 0;
        FO_Sound(self, CHAN_VOICE, "player/axhit1.wav", 1, 1);
        return;
    }
    rs = rint(((random() * 5) + 1));
    self.noise = "";
    if (rs == 1) {
        self.noise = "player/pain1.wav";
    } else {
        if (rs == 2) {
            self.noise = "player/pain2.wav";
        } else {
            if (rs == 3) {
                self.noise = "player/pain3.wav";
            } else {
                if (rs == 4) {
                    self.noise = "player/pain4.wav";
                } else {
                    if (rs == 5) {
                        self.noise = "player/pain5.wav";
                    } else {
                        self.noise = "player/pain6.wav";
                    }
                }
            }
        }
    }
    FO_Sound(self, CHAN_VOICE, self.noise, 1, 1);
    return;
};

void () player_pain1 =[35, player_pain2] {
    PainSound();
    self.weaponframe = 0;
};

void () player_pain2 =[36, player_pain3] {
};

void () player_pain3 =[37, player_pain4] {
};

void () player_pain4 =[38, player_pain5] {
};

void () player_pain5 =[39, player_pain6] {
};

void () player_pain6 =[40, player_run] {
};

void () player_axpain1 =[29, player_axpain2] {
    PainSound();
    self.weaponframe = 0;
};

void () player_axpain2 =[30, player_axpain3] {
};

void () player_axpain3 =[31, player_axpain4] {
};

void () player_axpain4 =[32, player_axpain5] {
};

void () player_axpain5 =[33, player_axpain6] {
};

void () player_axpain6 =[34, player_run] {
};

void (entity et, float f) player_pain = {
    if (self.weaponframe) {
        if (deathmsg == DMSG_TEAMKILL)
            PainSound();
        return;
    }
    if (self.invisible_finished > time)
        return;

    if (IsFeigned(self)) {
        PainSound();
        return;
    }
    if (self.button0 && (FO_CurrentWeapon() == WEAP_INCENDIARY))
        return;

    if (FO_CurrentWeapon() <= WEAP_AXE)
        player_axpain1();
    else
        player_pain1();
};

void () player_diea1;
void () player_dieb1;
void () player_diec1;
void () player_died1;
void () player_diee1;
void () player_die_ax1;

void () DeathBubblesSpawn = {
    if (self.owner.waterlevel != 3)
        return;

    newmis = spawn();
    FO_SetModel(newmis, "progs/s_bubble.spr");
    setorigin(newmis, (self.owner.origin + '0 0 24'));
    newmis.movetype = 8;
    newmis.solid = 0;
    newmis.velocity = '0 0 15';
    newmis.nextthink = time + 0.5;
    newmis.think = bubble_bob;
    newmis.classname = "bubble";
    newmis.frame = 0;
    newmis.cnt = 0;
    setsize(newmis, '-8 -8 -8', '8 8 8');
    self.nextthink = time + 0.1;
    self.think = DeathBubblesSpawn;
    self.air_finished = self.air_finished + 1;
    if (self.air_finished >= self.bubble_count)
        dremove(self);
};

void (float num_bubbles) DeathBubbles = {
    local entity bubble_spawner;

    bubble_spawner = spawn();
    setorigin(bubble_spawner, self.origin);
    bubble_spawner.movetype = MOVETYPE_NONE;
    bubble_spawner.solid = SOLID_NOT;
    bubble_spawner.nextthink = time + 0.1;
    bubble_spawner.think = DeathBubblesSpawn;
    bubble_spawner.air_finished = 0;
    bubble_spawner.owner = self;
    bubble_spawner.bubble_count = num_bubbles;
    return;
};

void () DeathSound = {
    local float rs;

    if (self.waterlevel == 3) {
        if (IsFeigned(self))
            DeathBubbles(2);
        else
            DeathBubbles(10);

        FO_Sound(self, CHAN_VOICE, "player/h2odeath.wav", 1, 0);
        return;
    }
    rs = rint(random() * 4 + 1);
    if (rs == 1)
        self.noise = "player/death1.wav";
    else if (rs == 2)
        self.noise = "player/death2.wav";
    else if (rs == 3)
        self.noise = "player/death3.wav";
    else if (rs == 4)
        self.noise = "player/death4.wav";
    else
        self.noise = "player/death5.wav";

    FO_Sound(self, CHAN_VOICE, self.noise, 1, 0);
    return;
};

void () PlayerDead = {
    self.client_nextthink = -1;
    self.nextthink = -1;
    self.deadflag = DEAD_DEAD;
};

vector(float dm) VelocityForDamage =
{
    local vector v;

    v_x = 100 * crandom();
    v_y = 100 * crandom();
    v_z = 200 + 100 * random();
    if (dm > -50)
        v = v * 0.7;
    else if (dm > -200)
        v = v * 2;
    else
        v = v * 10;
    return (v);
};

void (string gibname, float dm) ThrowGib = {
    newmis = spawn();
    newmis.origin = self.origin;

    FO_SetModel(newmis, gibname);

    setsize(newmis, '0 0 0', '0 0 0');
    newmis.velocity = VelocityForDamage(dm);

    newmis.movetype = MOVETYPE_BOUNCE;
    newmis.solid = SOLID_NOT;

    newmis.avelocity_x = random() * 600;
    newmis.avelocity_y = random() * 600;
    newmis.avelocity_z = random() * 600;

    newmis.think = SUB_Remove;
    newmis.ltime = time;
    newmis.nextthink = time + 10 + random() * 10;
    newmis.frame = 0;
    newmis.flags = 0;
};

void (string gibname, float dm) ThrowHead = {
    FO_SetModel(self, gibname);
    self.skin = 0;
    self.frame = 0;
    self.nextthink = -1;

    self.movetype = MOVETYPE_BOUNCE;
    self.takedamage = DAMAGE_NO;
    self.solid = SOLID_NOT;

    self.view_ofs = '0 0 8';
    setsize(self, '-16 -16 0', '16 16 56');
    self.velocity = VelocityForDamage(dm);
    self.origin_z = self.origin_z - 24;
    self.flags = self.flags - (self.flags & 512);
    self.avelocity = crandom() * '0 600 0';
};

void (string gibname) HeadShotThrowHead = {
    FO_SetModel(self, gibname);
    self.frame = 0;
    self.nextthink = -1;

    self.movetype = MOVETYPE_BOUNCE;
    self.takedamage = DAMAGE_NO;
    self.solid = SOLID_NOT;

    self.view_ofs = '0 0 8';
    setsize(self, '-16 -16 0', '16 16 56');
    self.velocity = normalize(self.head_shot_vector) * 600;
    self.origin_z = self.origin_z + 24;
    self.flags = self.flags - self.flags & 512;
    self.avelocity = '0 0 0';
};

void () KillPlayer = {
    self.owner.deadflag = DEAD_DEAD;
    dremove(self);
};

void () GibPlayer = {
    ThrowHead("progs/h_player.mdl", self.health);
    ThrowGib("progs/gib1.mdl", self.health);
    ThrowGib("progs/gib2.mdl", self.health);
    ThrowGib("progs/gib3.mdl", self.health);
    if (deathmsg == DMSG_TRIGGER) {
        newmis = spawn();
        newmis.owner = self;
        newmis.think = KillPlayer;
        newmis.nextthink = time + 1;
    } else {
        self.deadflag = DEAD_DEAD;
    }
    TeamFortress_SetupRespawn(0);
    if (damage_attacker.classname == "teledeath") {
        FO_Sound(self, CHAN_VOICE, "player/teledth1.wav", 1, 0);
        self.respawn_time = (self.respawn_time + 2) + (random() * 2);
        return;
    } else if (damage_attacker.classname == "teledeath2") {
        FO_Sound(self, CHAN_VOICE, "player/teledth1.wav", 1, 0);
        self.respawn_time = (self.respawn_time + 2) + (random() * 2);
        return;
    }
    if (random() < 0.5) {
        FO_Sound(self, CHAN_VOICE, "player/gib.wav", 1, 0);
    } else {
        FO_Sound(self, CHAN_VOICE, "player/udeath.wav", 1, 0);
    }

    FO_SetClientThink(think_nop, 0);
};

void () PlayerDie = {
    UpdateClientPlayerDie(self);

    self.spawn_gen += 1;
    self.last_death_ctime = self.client_time;

    local float i;
    local entity te;

    self.items = self.items - (self.items & 524288);
    self.invisible_finished = 0;
    self.invincible_finished = 0;
    self.super_damage_finished = 0;
    self.radsuit_finished = 0;
    self.modelindex = modelindex_player;

    if ((self.tfstate & 16) && (self == self.enemy)) {
        te = find(world, classname, "timer");
        while (te) {
            if ((te.owner == self) && (te.think == BioInfection_Decay)) {
                logfrag(te.enemy, self);
                TF_AddFrags(te.enemy, 1);
            }
            te = find(te, classname, "timer");
        }
    }
    TeamFortress_RemoveTimers();

    if (deathmatch || coop)
        DropBackpack();

    self.tfstate |= TFSTATE_NO_WEAPON;
    self.view_ofs = '0 0 -8';
    self.deadflag = DEAD_DYING;
    self.solid = SOLID_NOT;
    self.flags = self.flags - (self.flags & 512);
    self.movetype = MOVETYPE_TOSS;

    if (self.velocity_z < 10)
        self.velocity_z = self.velocity_z + random() * 300;

    if (self.health < -40) {
        GibPlayer();
        return;
    }

    DeathSound();
    self.angles_x = 0;
    self.angles_z = 0;
    if (FO_CurrentWeapon() <= WEAP_AXE) {
        player_die_ax1();
        TeamFortress_SetupRespawn(0);
        return;
    }
    i = 1 + floor(random() * 6);
    if (i == 1)
        player_diea1();
    else if (i == 2)
        player_dieb1();
    else if (i == 3)
        player_diec1();
    else if (i == 4)
        player_died1();
    else
        player_diee1();

    TeamFortress_SetupRespawn(0);
};

void () set_suicide_frame = {
    if (self.model != "progs/player.mdl")
        return;

    setmodel(self, string_null);
    setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
};


void player_die_extra() {
    // Death animations are variable length, this always picks up last frame.
    if (self.client_think == player_run)
        PlayerDead();
}

anim_t anim_player_diea1 = { 11, 1, {50}, {0}, FALSE, FALSE };
void player_dieaN() { client_anim_frames(player_dieaN, player_die_extra, &anim_player_diea1); }
void player_diea1() { *thinkindex() = 1; player_dieaN(); }

anim_t anim_player_dieb1 = { 9, 1, {61}, {0}, FALSE, FALSE };
void player_diebN() { client_anim_frames(player_diebN, player_die_extra, &anim_player_dieb1); }
void player_dieb1() { *thinkindex() = 1; player_diebN(); }

anim_t anim_player_diec1 = { 15, 1, {70}, {0}, FALSE, FALSE };
void player_diecN() { client_anim_frames(player_diecN, player_die_extra, &anim_player_diec1); }
void player_diec1() { *thinkindex() = 1; player_diecN(); }

anim_t anim_player_died1 = { 9, 1, {85}, {0}, FALSE, FALSE };
void player_diedN() { client_anim_frames(player_diedN, player_die_extra, &anim_player_died1); }
void player_died1() { *thinkindex() = 1; player_diedN(); }

anim_t anim_player_diee1 = { 9, 1, {94}, {0}, FALSE, FALSE };
void player_dieeN() { client_anim_frames(player_dieeN, player_die_extra, &anim_player_diee1); }
void player_diee1() { *thinkindex() = 1; player_dieeN(); }

anim_t anim_player_die_ax = { 9, 1, {41}, {0}, FALSE, FALSE };
void player_die_axN() { client_anim_frames(player_die_axN, player_die_extra, &anim_player_die_ax); }
void player_die_ax1() { *thinkindex() = 1; player_die_axN(); }

void () Headless_Think = {
    self.frame = self.frame + 1;
    if ((self.frame == 7) || (self.frame == 18)) {
        self.nextthink = time + 10 + random() * 10;
        self.think = SUB_Remove;
        return;
    }
    self.nextthink = time + 0.1;
};
