void () T_MissileTouch;
void () info_player_start;
void (entity targ, entity attacker) ClientObituary;
void () ResetPlayers;
void (entity targ, entity attacker) KillSound;
void (entity Goal, entity AP, float addb) DoResults;
float (entity Goal, entity AP) Activated;
float (entity targ, entity attacker, float damage) TeamEqualiseDamage;
float () CountRemainingTeams;
void () CheckRules;

void () monster_death_use = {
    if (self.flags & FL_FLY)
        self.flags = self.flags - FL_FLY;

    if (self.flags & FL_SWIM)
        self.flags = self.flags - FL_SWIM;

    if (!self.target)
        return;

    activator = self.enemy;
    SUB_UseTargets();
};

float (entity targ, entity inflictor) CanDamage = {
    if (targ.movetype == MOVETYPE_PUSH) {

        traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax),
                  TRUE, self);
        if (trace_fraction == 1)
            return (TRUE);
        if (trace_ent == targ)
            return (TRUE);
        return (FALSE);
    }

    traceline(inflictor.origin, targ.origin, TRUE, self);
    if (trace_fraction == 1)
        return (TRUE);
    traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
    if (trace_fraction == 1)
        return (TRUE);
    traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
    if (trace_fraction == 1)
        return (TRUE);
    traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
    if (trace_fraction == 1)
        return (TRUE);
    traceline(inflictor.origin, targ.origin + '15 -15 0', 1, self);
    if (trace_fraction == 1)
        return (TRUE);
    return (FALSE);
};

void () ResetPlayersDelayed = {
    if(duel_reset_timer < 1 && duel_reset_timer > 0) {
        self.nextthink = time + duel_reset_timer;
        duel_reset_timer = 0;
    } else if(duel_reset_timer <= 0) {
        ResetPlayers();
        dremove(self);
    } else {
        bprint(PRINT_HIGH, Q"\sReset in \x10", ftos(duel_reset_timer), "\x11\s\n");
        FO_Sound(self, CHAN_AUTO, "buttons/switch04.wav", 1, ATTN_NONE);
        //stuffcmd (p, "play buttons/switch04.wav\n");
        duel_reset_timer--;
        self.nextthink = time + 1;
    }
};

void () ResetPlayersWithCountdown = {
    local entity reset_timer;
    local float remainder;
    no_fire_mode = 1;
    if(duel_reset_delay) {
        reset_timer = find(world, classname, "duel_reset_timer");
        if(!reset_timer) {
            remainder = duel_reset_delay % 1;
            duel_reset_timer = duel_reset_delay - remainder;
            reset_timer = spawn();
            reset_timer.classname = "duel_reset_timer";
            reset_timer.nextthink = time + remainder;
            reset_timer.think = ResetPlayersDelayed;
        }
    } else {
        ResetPlayers();
    }

}

void (entity targ, entity attacker) Killed = {
    local entity oself;
	KillSound(targ, attacker);
    if (attacker == world && (targ.classname == "building_dispenser" || targ.classname == "building_sentrygun"))
        attacker = targ;

    oself = self;
    self = targ;
    if (self.health < -99)
        self.health = -99;

    if ((self.movetype == MOVETYPE_PUSH) ||
        //make sure unmovable players like those feigning/building are still given an obituary
        //(self.movetype == MOVETYPE_NONE && !self.is_building && !self.is_detpacking && !self.is_feigning)) {
        (self.movetype == MOVETYPE_NONE && self.classname != "player")) {

        self.th_die();
        self = oself;
        return;
    }

    self.enemy = attacker;

    if (self.flags & FL_MONSTER) {

        killed_monsters = killed_monsters + 1;
        WriteByte(MSG_ALL, SVC_KILLEDMONSTER);
    }

    ClientObituary(self, attacker);
    self.takedamage = DAMAGE_NO;
    self.touch = SUB_Null;
    monster_death_use();

    self.th_die();

    self = oself;
    if(duelmode && targ.classname == "player" && !cb_prematch) {
        //Already in no fire mode - implies you're not the first to die
        if(no_fire_mode) {
            if(CountRemainingTeams() == 0) {
                if(!duel_draw_countdown) {
                    ResetPlayers();
                }
            }
        } else {
            if(CountRemainingTeams() < 2) {
                ResetPlayersWithCountdown();
            }
        }
    }
    if(vote_anarchy_mode) {
        UnvoteForMap(targ);
    }
};

void (entity targ, entity inflictor, entity attacker, float damage) HitSound = {
    if(nohitsounds)
        return;
															 	 															   						  	
    if ((attacker.classname == "player") || (attacker.classname == "building_sentrygun") || (attacker.classname == "building_dispenser"))
    {
        if ((targ.classname == "player") || (targ.classname == "building_sentrygun") || (targ.classname == "building_dispenser"))
        {
            local entity trueattacker;

            if (attacker.classname == "building_sentrygun")
            {	// work out correct attacker
                trueattacker = attacker.real_owner;
            }
            else 
            {
                trueattacker = attacker;
            }

            local float csqcactive = infokeyf(trueattacker, INFOKEY_P_CSQCACTIVE);

            if(zutmode && csqcactive)
                return;	
                
            if (trueattacker == targ)
                return;

            local string hitsound;
            hitsound = infokey(trueattacker, "hitsound");

            if (hitsound == "1" || hitsound == "2")
            {
                local float crit = 0;

                if((inflictor.weapon == DMSG_ROCKETL) && (damage >= 80)) {
                    crit = 1;
                }
                if ((inflictor.weapon == DMSG_SSHOTGUN) && (damage >= 40)) {
                    crit = 1;
                }
                if ((inflictor.weapon == DMSG_GRENADEL) && (damage >= 85)) {
                    crit = 1;
                }
                if ((inflictor.weapon == DMSG_INCENDIARY) && (damage >= 40)) {
                    crit = 1;
                }

                if (targ.playerclass == PC_SPY && IsFeigned(targ))
                        return;

                float targteam;
                targteam = (targ.undercover_team == 0) ? targ.team_no : targ.undercover_team;

                if (targteam != attacker.team_no) {
                    if (crit == 1){
                        stuffcmd(trueattacker, "play misc/hitsoundcrit.wav\n");		//sounds precached in weapons.qc
                    }
                    else { 
                        stuffcmd(trueattacker, "play misc/hitsound.wav\n");		//sounds precached in weapons.qc
                    }
                }
                else {
                    if (hitsound == "2"){
                        stuffcmd(trueattacker, "play misc/hitsoundteam.wav\n");		//sounds precached in weapons.qc
                    }
                }	
            }
        }
    }
};

void (entity targ, entity attacker) KillSound = {


    if ((attacker.classname == "player") || (attacker.classname == "building_sentrygun") || (attacker.classname == "building_dispenser")) {
        if ((targ.classname == "player") || (targ.classname == "building_sentrygun") || (targ.classname == "building_dispenser")) {

            local entity trueattacker;
            if (attacker.classname == "building_sentrygun") {
                trueattacker = attacker.real_owner;
            }
            else {
                trueattacker = attacker;
            }
            
            local float csqcactive = infokeyf(trueattacker, INFOKEY_P_CSQCACTIVE);
            if(csqcactive && zutmode)
                 return;
                 
            local string killsound = infokey(trueattacker, "killsound");

            if (killsound == "1" || killsound == "2" || killsound == "3"){

                if (targ.team_no != trueattacker.team_no) {
                    stuffcmd(trueattacker, "play misc/killsound.wav\n");
                    return;
                }
                else {

                    if (trueattacker == targ) {
                        if(killsound == "3") {
                            stuffcmd(trueattacker, "play misc/killsoundteam.wav\n");	
                        }
                        return;
                    }

                    if (killsound == "2" || killsound == "3") {
                        stuffcmd(trueattacker, "play misc/killsoundteam.wav\n");
                    }

                }
            }
        }
    }
    else {
        if (targ.classname == "player") {
            local string targkillsound = infokey(targ, "killsound");
            if (targkillsound == "3") {
                stuffcmd(targ, "play misc/killsoundteam.wav\n");
            }
        }
    }
};

static inline float valid_hitflag_target(string name) {
    return (name == "player" || name == "building_sentrygun" ||
            name == "building_dispenser");
}

void BroadcastHitFlag(entity targ, entity inflictor, entity attacker,
        float original_damage, float actual_damage) {
    float hitflag = 0;

    if (!valid_hitflag_target(attacker.classname) ||
        !valid_hitflag_target(targ.classname))
        return;

    if (attacker.classname != "player")
        attacker = attacker.real_owner;

    if (!infokeyf(attacker, INFOKEY_P_CSQCACTIVE) || (attacker.tfstate & TFSTATE_FLASHED))
        return;

    // Feigned spies act as corpses unless they're a teammate
    if (targ.playerclass == PC_SPY && IsFeigned(targ) && targ.health > 0 &&
        targ.team_no != attacker.team_no)
        return;

    // server allowances -- just baking in hitflag coz im a lazy as
    if(nohitsounds)
        hitflag |= HITFLAG_NOAUDIO;
    if(nohittext)
        hitflag |= HITFLAG_NOTEXT;

    // no armour left on target -- other games call it "screaming" "cracked" "one shot" etc
    if(targ.armorvalue <= 0 && targ.classname == "player")
        hitflag |= HITFLAG_NOARMOUR;

    // friendly
    if ((targ.team_no == attacker.team_no) ||
        (targ.playerclass == PC_SPY && targ.undercover_team == attacker.team_no))
        hitflag |= HITFLAG_FRIENDLY;

    // kill
    if(targ.health <= 0) {
        hitflag |= HITFLAG_KILLINGBLOW;

        if (targ.playerclass == PC_SPY) {
           if (targ.undercover_team != 0 && targ.team_no != attacker.team_no) {
               hitflag |= HITFLAG_KILLEDUNDERCOVERSPY;
               hitflag &= ~HITFLAG_FRIENDLY;
           }
           if (IsFeigned(targ))
               hitflag |= HITFLAG_FEIGNEDENEMY;
        }
    }

    // meatshot -- this is very lazy, should do t_missile etc
    if (((inflictor.weapon == DMSG_ROCKETL) && (original_damage >= 80)) ||
        ((inflictor.weapon == DMSG_SSHOTGUN) && (original_damage >= 40)) ||
        ((inflictor.weapon == DMSG_GRENADEL) && (original_damage >= 85)) ||
        ((inflictor.weapon == DMSG_INCENDIARY) && (original_damage >= 40)))
            hitflag |= HITFLAG_MEATSHOT;

    // headshot
    if (deathmsg == DMSG_SNIPERHEADSHOT)
        hitflag |= HITFLAG_HEADSHOT;

    // self
    if (attacker == targ)
        hitflag |= HITFLAG_SELF;

    // TODO: cuss - done elsewhere

    msg_entity = attacker;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, MSG_HITFLAG);
    WriteCoord(MSG_MULTICAST, targ.origin.x);
    WriteCoord(MSG_MULTICAST, targ.origin.y);
    WriteCoord(MSG_MULTICAST, targ.origin.z);
    WriteShort(MSG_MULTICAST, actual_damage);
    WriteShort(MSG_MULTICAST, original_damage);
    WriteShort(MSG_MULTICAST, hitflag);

    // TODO: Supporting spectators (requires no ezquake)
    multicast('0 0 0', MULTICAST_ONE_R_NOSPECS);
};

void (entity targ, entity inflictor, entity attacker, float damage) T_Damage = {
    local vector dir;
    local entity oldself, te;
    local float save;
    local float take;

    if (!targ.takedamage)
        return;

    if (attacker.classname == "player")
        damage = damage * 0.9;

    if (attacker.classname == "player") {

        if (attacker.super_damage_finished > time)
            damage = damage * 4;

        if ((targ.classname != "player") && (targ.classname != "bot")) {

            if (!Activated(targ, attacker)) {

                if (targ.else_goal != 0) {

                    te = Findgoal(targ.else_goal);
                    if (te)
                        AttemptToActivate(te, attacker, targ);
                }
                return;
            }
        }
    }
    damage_attacker = attacker;
    if (teamplay & (TEAMPLAY_LESSSCOREHELP | TEAMPLAY_LESSPLAYERSHELP))
        damage = TeamEqualiseDamage(targ, attacker, damage);

    save = ceil(targ.armortype * damage);
    if (save >= targ.armorvalue) {

        save = targ.armorvalue;
        targ.armortype = 0;
        targ.armorclass = 0;
        targ.items =
            targ.items -
            (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
    }
    targ.armorvalue = targ.armorvalue - save;
    take = ceil(damage - save);

    if (targ.flags & FL_CLIENT) {
        targ.dmg_take = targ.dmg_take + take;
        targ.dmg_save = targ.dmg_save + save;
        targ.dmg_inflictor = inflictor;
    }
    if ((inflictor != world) && (targ.movetype == MOVETYPE_WALK)) {

        targ.immune_to_check = time + (damage / 20);
        dir = targ.origin - ((inflictor.absmin + inflictor.absmax) * 0.5);
        dir = normalize(dir);
        if (((damage < 60) &&
             ((attacker.classname == "player") &&
              (targ.classname == "player")))
            && (attacker.netname != targ.netname))
            targ.velocity = targ.velocity + dir * damage * 11;
        else
            targ.velocity = targ.velocity + dir * damage * 8;

        if (((rj > 1) &&
             ((attacker.classname == "player") &&
              (targ.classname == "player")))
            && (attacker.netname == targ.netname))
            targ.velocity = (targ.velocity + ((dir * damage) * rj));
    }
    if (targ.flags & FL_GODMODE)
        return;

    if (targ.invincible_finished >= time) {
        if (self.invincible_sound < time) {

            FO_Sound(targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
            self.invincible_sound = time + 2;
        }
        return;
    }
    if ((attacker.classname == "player")
        && ((targ.classname == "player") ||
            (targ.classname == "building_sentrygun"))) {

        if (((targ.team_no > 0) && (targ.team_no == attacker.team_no)) &&
            (targ != attacker)) {

            if (teamplay & TEAMPLAY_NOEXPLOSIVE)
                return;
            else if (teamplay & TEAMPLAY_HALFEXPLOSIVE)
                take = take / 2;
        }
    }
    if ((take < 1) && (take != 0))
        take = 1;

    float damh = (take > targ.health) ? targ.health : take;
    targ.health = targ.health - take;

    if (targ.armorvalue < 1) {
        targ.armorclass = 0;
        targ.armorvalue = 0;
    }
    if ((attacker.classname == "player" || targ.classname == "player") && (take + save > 0)) {
        LogEventDamage(attacker, targ, inflictor, take + save, damh + save);
    }
    if (targ.health <= 0) {
        LogEventKill(attacker, targ, inflictor);
        Killed(targ, attacker);
        return;
    }

    oldself = self;
    self = targ;

    if (self.th_pain) {
        self.th_pain(attacker, take);
        if (skill >= 3)
            self.pain_finished = time + 5;
    }
    self = oldself;
};

void TF_T_Damage(entity targ, entity inflictor, entity attacker,
      float damage, float T_flags, float T_AttackType) {
    local vector dir;
    local entity oldself;
    local entity te;
    local float save;
    local float take;
    local float olddmsg;
    local float no_damage;
    local float original_damage = damage;


    if (targ.takedamage == 0)
        return;

    if (T_AttackType & TF_TD_NOSOUND) {
        targ.health = damage;
        return;
    }
    if (cease_fire)
        return;

    float fl = 0;
    if (attacker.classname == "player")
        fl |= KF_SRC_PLAYER;
    if (targ.classname == "player")
        fl |= KF_TARG_PLAYER;
    if (targ == attacker)
        fl |= KF_SELF;

    no_damage = 0;

    if (targ.tfstate & TFSTATE_BURNING)
        damage *= PC_PYRO_BURN_DAMAGE_AMP;

    if (fl & KF_SRC_PLAYER) {
        damage = damage * 0.9;

        if (attacker.super_damage_finished > time)
            damage = damage * 4;

        if ((fl & KF_TARG_PLAYER == 0)
            && (targ.classname != "bot")
            && (targ.classname != "building_sentrygun")
            && (targ.classname != "building_dispenser")
            && (targ.classname != "building_teleporter_entrance")
            && (targ.classname != "building_teleporter_exit")) {

            if (!Activated(targ, attacker)) {
                if (targ.else_goal != 0) {
                    te = Findgoal(targ.else_goal);
                    if (te)
                        AttemptToActivate(te, attacker, targ);
                }
                return;
            }
        }
    }

    HitSound(targ, inflictor, attacker, damage);

    damage_attacker = attacker;

    if (teamplay & (TEAMPLAY_LESSSCOREHELP | TEAMPLAY_LESSPLAYERSHELP))
        damage = TeamEqualiseDamage(targ, attacker, damage);

    if ((targ.armorclass != 0) && (T_AttackType != 0)) {
        if ((targ.armorclass & AT_SAVESHOT) && (T_AttackType & TF_TD_SHOT))
            damage = floor(damage * 0.5);
        if ((targ.armorclass & AT_SAVENAIL) && (T_AttackType & TF_TD_NAIL))
            damage = floor(damage * 0.5);
        if ((targ.armorclass & AT_SAVEEXPLOSION) && (T_AttackType & TF_TD_EXPLOSION))
            damage = floor(damage * 0.5);
        if ((targ.armorclass & AT_SAVEELECTRICITY) && (T_AttackType & TF_TD_ELECTRICITY))
            damage = floor(damage * 0.5);
        if ((targ.armorclass & AT_SAVEFIRE) && (T_AttackType & TF_TD_FIRE))
            damage = floor(damage * 0.5);
    }

    if (T_flags & TF_TD_IGNOREARMOR) {
        take = damage;
        save = 0;
    } else {
        save = ceil(targ.armortype * damage);
        if ((fl & KF_SRC_PLAYER)
            && (targ.team_no > 0)
            && (targ.team_no == attacker.team_no)
            && (targ != attacker)
            && (T_flags & 2)) {

            if (T_AttackType & TF_TD_EXPLOSION) {

                if (teamplay & 1024) {
                    save = 0;
                } else if (teamplay & 512) {
                    save = save / 2;
                }

            } else if (teamplay & 256)
                save = 0;
            else if (teamplay & 128)
                save = save / 2;

        }
        if (save >= targ.armorvalue) {

            save = targ.armorvalue;
            targ.armortype = 0;
            targ.armorclass = 0;
            targ.items =
                targ.items -
                (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));

        }
        targ.armorvalue = targ.armorvalue - save;
        take = ceil(damage - save);

    }
    if (targ.flags & FL_CLIENT) {

        targ.dmg_take = targ.dmg_take + take;
        targ.dmg_save = targ.dmg_save + save;
        targ.dmg_inflictor = inflictor;

    }

    if (!(T_AttackType & TF_TD_NOMOMENTUM) && damage) {
        if ((inflictor != world) && (targ.movetype == MOVETYPE_WALK) && !(targ.tfstate & TFSTATE_CANT_MOVE)) {
            if (deathmsg != DMSG_GREN_NAIL && deathmsg != DMSG_GREN_SHOCK && deathmsg != DMSG_GREN_BURST) {
                targ.immune_to_check = time + damage / 20;

                float moment = Class_ScaleMoment(targ.playerclass, damage);
                targ.velocity += CalcKnock(inflictor.origin, targ, fl, moment);
                Predict_AddFilterEnt(targ, inflictor.filter_ent ?: inflictor);
            }
        }
    }
    
    if (targ.flags & FL_GODMODE)
        return;

    if (targ.invincible_finished >= time) {
        if (self.invincible_sound < time) {
            FO_Sound(targ, CHAN_ITEM, "items/protect3.wav", 1, 1);
            self.invincible_sound = time + 2;
        }
        return;
    }
    if ((attacker.classname == "player")
        && ((targ.classname == "player")
            || (targ.classname == "building_sentrygun")
            || (targ.classname == "building_dispenser")
            || (targ.classname == "building_teleporter_entrance")
            || (targ.classname == "building_teleporter_exit"))) {

        if ((targ.team_no > 0) && (targ.team_no == attacker.team_no)
            && (targ != attacker) && (T_flags & TF_TD_NOTTEAM)) {

            if (T_AttackType & TF_TD_EXPLOSION) {

                if (teamplay & TEAMPLAY_NOEXPLOSIVE)
                    no_damage = TRUE;
                else if (teamplay & TEAMPLAY_HALFEXPLOSIVE)
                    take = take / 2;

            } else if (teamplay & TEAMPLAY_NODIRECT)
                no_damage = TRUE;
            else if (teamplay & TEAMPLAY_HALFDIRECT)
                take = take / 2;
        }
    }

    if (targ.playerclass == PC_SPY) {
        targ.attacked_by = attacker;
        targ.feignmsg = deathmsg;
    }

    if (T_flags & TF_TD_NOTSELF)
        if (targ == attacker)
            return;

    if (take < 1)
        take = 1;

    take = rint(take);

    float damh = (take > targ.health) ? targ.health : take;

    if (no_damage == 0)
        targ.health = (targ.health - take);

    if ((attacker.classname == "player")
        && ((targ.classname == "player")
            || (targ.classname == "building_sentrygun")
            || (targ.classname == "building_dispenser")
            || (targ.classname == "building_teleporter_entrance")
            || (targ.classname == "building_teleporter_exit"))) {

        if ((targ.team_no > 0) && (targ.team_no == attacker.team_no)
            && (targ != attacker) && (T_flags & 2)) {

            olddmsg = deathmsg;

            if (T_AttackType & TF_TD_EXPLOSION) {

                deathmsg = DMSG_TEAMKILL;
                if (teamplay & TP_FULLMIRRORAOE)
                    TF_T_Damage(attacker, world, world, take, 1, 0);
                else if (teamplay & TP_HALFMIRRORAOE)
                    TF_T_Damage(attacker, world, world, take / 2, 1, 0);

            } else {

                deathmsg = DMSG_TEAMKILL;
                if (teamplay & TP_FULLMIRRORDIRECT)
                    TF_T_Damage(attacker, world, world, take, 1, 0);
                else if (teamplay & TP_HALFMIRRORDIRECT)
                    TF_T_Damage(attacker, world, world, take / 2, 1, 0);
            }
            deathmsg = olddmsg;
        }
    }

    if (no_damage == TRUE)
        return;
    
    if ((attacker.classname == "player" || targ.classname == "player") && (take + save > 0)) {
        LogEventDamage(attacker, targ, inflictor, take + save, damh + save);
    }
    if (targ.armorvalue < 1) {
        targ.armorclass = 0;
        targ.armorvalue = 0;
    }

    if (zutmode)
        BroadcastHitFlag(targ, inflictor, attacker, original_damage, damh);

    if (targ.health <= 0) {
        if ((inflictor.classname == "detpack")
            && (inflictor.is_disarming) && (inflictor.enemy == targ))
            deathmsg = DMSG_DETPACK_DIS;
        LogEventKill(attacker, targ, inflictor);
        Killed(targ, attacker);
        return;
    }

    oldself = self;
    self = targ;

    if (self.th_pain) {
        self.th_pain(attacker, take);
        if (skill >= 3) {
            self.pain_finished = time + 5;
        }
    }

    if (self.feign_next_damage && !IsFeigned(self))
        FO_Spy_Feign(0, /* ignore rate-limit */ 1);

    self = oldself;
};

void (entity inflictor, entity attacker, float damage,
      entity ignore1, entity ignore2 = __NULL__, entity only = __NULL__)
        T_RadiusDamage = {
    local float points;
    local entity head;
    local vector org;

    int count, i;
    entity* rlist = findradius_list(inflictor.origin, damage + 40, count);

    for (i = 0; i < count; i ++) {
        entity e = rlist[i];
        if ((only && e != only) || e == ignore1 || e == ignore2)
            continue;

        if (!e.takedamage)
            continue;

        float fl = e == attacker ? KF_SELF : 0;
        points = CalcRadiusDamage(inflictor.origin, e, fl, damage);
        if (points > 0) {
            if (CanDamage(e, inflictor)) {
                // shambler takes half damage from all explosions
                if (e.classname == "monster_shambler")
                    T_Damage(e, inflictor, attacker,
                            points * 0.5);
                else
                    TF_T_Damage(e, inflictor, attacker, points,
                            TF_TD_NOTTEAM, TF_TD_EXPLOSION);
            }
        }
    }
};


void (entity attacker, float damage) T_BeamDamage = {
    local float points;
    local entity head;

    head = findradius(attacker.origin, damage + 40);
    while (head) {
        if (head.takedamage) {

            points = 0.5 * vlen(attacker.origin - head.origin);
            if (points < 0)
                points = 0;
            points = damage - points;
            if (head == attacker)
                points = points * 0.5;
            if (points > 0)
                if (CanDamage(head, attacker))
                    T_Damage(head, attacker, attacker, points);
        }
        head = head.chain;
    }
};
