void (entity Item, entity AP, float method) tfgoalitem_RemoveFromPlayer;
void (entity spy) TeamFortress_SpyCalcName;
void () CF_Spy_UndercoverThink;
void () T_TranqDartTouch;
void () Spy_DropBackpack;
void (entity targ, entity attacker) KillSound;

float IsFeigned(entity ent) {
    return ent.tfstate & TFSTATE_FEIGNED;
}

anim_t anim_spy_diea1 = { 11, 1, {50}, {0}, FALSE, FALSE, TRUE };
void spy_dieaN() { client_anim_frames(spy_dieaN, think_nop, &anim_spy_diea1); }
void spy_diea1() { *thinkindex() = 1; spy_dieaN(); }

anim_t anim_spy_dieb1 = { 9, 1, {61}, {0}, FALSE, FALSE, TRUE };
void spy_diebN() { client_anim_frames(spy_diebN, think_nop, &anim_spy_dieb1); }
void spy_dieb1() { *thinkindex() = 1; spy_diebN(); }

anim_t anim_spy_diec1 = { 15, 1, {70}, {0}, FALSE, FALSE, TRUE };
void spy_diecN() { client_anim_frames(spy_diecN, think_nop, &anim_spy_diec1); }
void spy_diec1() { *thinkindex() = 1; spy_diecN(); }

anim_t anim_spy_died1 = { 9, 1, {85}, {0}, FALSE, FALSE, TRUE };
void spy_diedN() { client_anim_frames(spy_diedN, think_nop, &anim_spy_died1); }
void spy_died1() { *thinkindex() = 1; spy_diedN(); }

anim_t anim_spy_diee1 = { 9, 1, {94}, {0}, FALSE, FALSE, TRUE };
void spy_dieeN() { client_anim_frames(spy_dieeN, think_nop, &anim_spy_diee1); }
void spy_diee1() { *thinkindex() = 1; spy_dieeN(); }

anim_t anim_spy_die_ax1 = { 9, 1, {41}, {0}, FALSE, FALSE, TRUE };
void spy_die_axN() { client_anim_frames(spy_die_axN, think_nop, &anim_spy_die_ax1); }
void spy_die_ax1() { *thinkindex() = 1; spy_die_axN(); }

void spy_up_extra() {
    // Death animations are variable length, this always picks up last frame.
    // Animation transition to stand would take an extra 100ms.
    if (self.client_think == player_run)
        player_stand1();
}

anim_t anim_spy_upb1 = { 9, 1, {69, 68, 67, 66, 65, 64, 63, 62, 61}, {0}, FALSE, FALSE };
void spy_upbN() { client_anim_frames(spy_upbN, spy_up_extra, &anim_spy_upb1); }
void spy_upb1() { *thinkindex() = 1; spy_upbN(); }

anim_t anim_spy_upc1 =
    { 15, 1, {84,83,82,81,80,79,78,77,76,75,74,73,72,71,70}, {0}, FALSE, FALSE };
void spy_upcN() { client_anim_frames(spy_upcN, spy_up_extra, &anim_spy_upc1); }
void spy_upc1() { *thinkindex() = 1; spy_upcN(); }

anim_t anim_spy_upd1 = { 9, 1, {93, 92, 91, 90, 89, 88, 87, 86, 85}, {0}, FALSE, FALSE };
void spy_updN() { client_anim_frames(spy_updN, spy_up_extra, &anim_spy_upd1); }
void spy_upd1() { *thinkindex() = 1; spy_updN(); }

anim_t anim_spy_upe1 = { 9, 1, {102, 101, 100, 99, 98, 97, 96, 95, 94}, {0}, FALSE, FALSE };
void spy_upeN() { client_anim_frames(spy_upeN, spy_up_extra, &anim_spy_upe1); }
void spy_upe1() { *thinkindex() = 1; spy_upeN(); }

anim_t anim_spy_upaxe1 = { 9, 1, {49, 48, 47, 46, 45, 44, 43, 32, 41}, {0}, FALSE, FALSE };
void spy_upaxeN() { client_anim_frames(spy_upaxeN, spy_up_extra, &anim_spy_upaxe1); }
void spy_upaxe1() { *thinkindex() = 1; spy_upaxeN(); }

float (entity pe_player) Spy_CheckArea = {
    local entity at_spot = findradius(pe_player.origin, 64);
    while (at_spot != world) {
        if (at_spot.mdl == "progs/detpack.mdl"
                    || at_spot.mdl == "progs/turrbase.mdl"
                    || at_spot.mdl == "progs/turrgun.mdl"
                    || at_spot.mdl == "progs/disp.mdl")
            return 1;
        else if (at_spot.classname == "player" && pe_player != at_spot) {
            if (!IsFeigned(at_spot) && at_spot.deadflag == 0)
                return 2;
            else if (IsFeigned(at_spot))
                return 3;
        }
        at_spot = at_spot.chain;
    }
    return 0;
};

void (entity pe_player, float dontstopdead) Spy_CheckForFuncTouch = {
    if (pe_player.classname == "player" && pe_player.playerclass == PC_SPY) {
        if (IsFeigned(pe_player)) {
            pe_player.velocity_x = 0;
            pe_player.velocity_y = 0;
            pe_player.movetype = MOVETYPE_TOSS;
            //This is needed for plats that have a virtual presence and this causes you to fall slowly when inside it
            if(!dontstopdead)
                pe_player.tfstate |= TFSTATE_CANT_MOVE;
        }
    }
};

void () CF_Spy_AirThink = {
    local float area_check = 0;

    if(self.owner.deadflag >= DEAD_DEAD) {
        // reset the movetype just in case you die while in the TOSS or the WALK states (eg mbasesr lift squish)
        self.owner.movetype = MOVETYPE_NONE;
        self.owner.tfstate |= TFSTATE_CANT_MOVE;
        dremove(self);
        return;
    }

    if ((self.owner.playerclass != PC_SPY) || (!IsFeigned(self.owner))) {
        dremove(self);
        return;
    }

    // only do stuff when spy is no longer moving
    if (!self.owner.velocity) {
        // if spy is on ground and an entity is not nearby, set movetype to none (so he can't move)
        if (self.owner.flags & FL_ONGROUND) {
            area_check = Spy_CheckArea(self.owner);
            if (area_check == 0) {
                //This checks if something is trying to squish you, fixing some situations where the door or whatever would just go through you.
                traceline(self.owner.origin, self.owner.origin, 0, self.owner);
                if(trace_ent) {
                    if(trace_ent.classname == "door" || trace_ent.classname == "plat" || trace_ent.classname == "train") {
                        self.owner.movetype = MOVETYPE_TOSS;
                    }
                } else {
                    self.owner.movetype = MOVETYPE_NONE;
                }
                self.owner.tfstate |= TFSTATE_CANT_MOVE;
            }
        }

        // if spy is in the air, set movetype to walk^H^H^H^H toss (so he falls to ground)
        else {
            self.owner.movetype = MOVETYPE_TOSS;
        }
    }

    self.nextthink = time + 0.1;
};

void (float issilent) FO_Spy_ToggleFeign = {
    if (IsFeigned(self) || self.feign_next_damage) {
        FO_Spy_Unfeign();
    } else {
        FO_Spy_FeignOnNextDamage();
    }
}

void (float issilent, float force) FO_Spy_Feign = {
    if (IsFeigned(self))
        return;

    if (!force && time <= self.next_feign_time) {
        sprint(self, PRINT_HIGH, sprintf(
            "%0.1f seconds until you can feign again!\n",
            self.next_feign_time - time));
        return;
    }

    // don't allow feign if spy is in air and air feigning is disallowed
    if (!feign_air && !(self.flags & FL_ONGROUND)) {
        return;
    }

    // check area for feigned spy on the ground
    local float area_check;
    area_check = Spy_CheckArea(self);
    if (area_check == 3) {
        return;
    }

    // Success.  We will feign.
    if (feign_rate_limit)
        self.next_feign_time = time + feign_rate_limit;
    else
        self.next_feign_time = 0;

    // don't check for team color cheat for 5 seconds
    self.immune_to_check = time + 5;

    // set movetype to toss
    self.movetype = MOVETYPE_TOSS;

    // this timer will make sure the spy falls
    // to the ground when possible
    local entity spy;
    spy = spawn();
    spy.classname = "airtimer";
    spy.owner = self;
    spy.think = CF_Spy_AirThink;
    spy.nextthink = time + 0.1;

    // set spy feign variables
    self.tfstate |= TFSTATE_FEIGNED;
    self.is_button_feigning = 1;

    Attack_Finished(0.8);
    self.invisible_finished = 0;

    // set precached model index
    self.modelindex = modelindex_player;

    // set size of player model
    setsize(self, '-16 -16 -24', '16 16 -16');

    // set weapon state and remove weapon viewmodel
    self.tfstate |= TFSTATE_NO_WEAPON;

    // set view height to ground
    self.view_ofs = '0 0 4';

    // do extra stuff if feign is not silent feign
    if (issilent == 0) {
        // make a death sound
        DeathSound();

        // drop an empty backpack (if this is not disabled in settings)
        if (feign_pack)
            Spy_DropBackpack();

        // print feign message (if this is not disabled in settings)
        if (feign_msg) {
            local string deathstring;
            deathstring = GetDeathMessage(self, self.attacked_by, self.feignmsg);
            bprint(PRINT_MEDIUM, deathstring);
            KillSound(self, self.attacked_by);
        }

        // set movement speed to 0 if currently in the air to disable manipulation of trajectory
        if (!(self.flags & FL_ONGROUND))
            self.maxspeed = 0;
    }

    // drop flag if spy is carrying it
    local entity te;
    te = find(world, classname, "item_tfgoal");
    while (te) {
        if (te.owner == self) {
            if (!(te.goal_activation & TFGI_KEEP) || self.has_disconnected == 1)
                tfgoalitem_RemoveFromPlayer(te, self, 0);
            if (CTF_Map == 1) {
                if (te.goal_no == 1)
                    bprint(PRINT_HIGH, self.netname, Q" \slost\s the \sblue\s flag!\n");
                else if (te.goal_no == 2)
                    bprint(PRINT_HIGH, self.netname, Q" \slost\s the \sred\s flag!\n");
            }
        }
        te = find(te, classname, "item_tfgoal");
    }

    // die with axe equipped if carrying axe, medikit, knife or spanner
    if (IsSlotMelee(self.current_slot)) {
        spy_die_ax1();
        return;
    }

    // randomize death animation
    local float i;
    i = 1 + floor((random() * 6));
    if (i == 1)
        spy_diea1();
    else if (i == 2)
        spy_dieb1();
    else if (i == 3)
        spy_diec1();
    else if (i == 4)
        spy_died1();
    else
        spy_diee1();
}

void () FO_Spy_FeignOnNextDamage = {
        self.feign_next_damage = 1;
        sprint(self, PRINT_HIGH, "Feigning on next damage...\n");
}

void () FO_Spy_Unfeign = {
    if (self.feign_next_damage) {
        self.feign_next_damage = 0;
        sprint(self, PRINT_HIGH, "Feign cancelled\n");
    }

    if (!IsFeigned(self))
        return;

    if (!self.is_button_feigning) {
        return;
    }

    // check area for obstructing entities
    local float area_check;
    area_check = Spy_CheckArea(self);

    // nothing on top => unfeign
    if (!area_check) {

        // set size of player model
        setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

        // set view height
        self.view_ofs = '0 0 22';

        // unset feign variables
        self.tfstate &= ~TFSTATE_FEIGNED;
        self.is_button_feigning = 0;
        self.feign_areachecked = 0;

        // load saved weapon state and set current ammo
        W_UpdateCurrentWeapon(self);

        // allow spy to move again
        self.movetype = MOVETYPE_WALK;
        self.tfstate &= ~(TFSTATE_CANT_MOVE | TFSTATE_NO_WEAPON);

        // set revive animation
        local float i;
        i = 1 + floor(random() * 5);
        if (i == 1) {
            spy_upb1();
        } else if (i == 2) {
            spy_upc1();
        } else if (i == 3) {
            spy_upd1();
        } else {
            spy_upe1();
        }
    }
}

void (float issilent) FO_Spy_FeignCmd = {
    if (IsFeigned(self))
        FO_Spy_Unfeign();
    else
        FO_Spy_Feign(issilent, 0);
}

void () CF_Spy_Invisible = {
    local entity e_timer;

    if (self.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT)) {
        sprint(self, PRINT_MEDIUM, "You cannot become invisible while glowing\n");
        return;
    }

    if (self.is_unabletospy) {
        sprint(self, PRINT_HIGH, "You cannot become invisible right now\n");
        return;
    }

    if (self.is_undercover == 1 || self.items & IT_INVISIBILITY) {

        self.items = self.items - IT_INVISIBILITY;
        self.invisible_finished = 0;
        self.invisible_time = 0;
        self.is_undercover = 0;
        self.modelindex = modelindex_player;

    } else if (self.is_undercover == 2) {

        sprint(self, PRINT_HIGH, "You become visible again\n");

        self.is_undercover = 0;

    } else if (self.ammo_cells > 1) {

        sprint(self, PRINT_HIGH, "Going invisible...\n");

        self.is_undercover = 2;
        self.undercover_timer = PC_SPY_GO_UNDERCOVER_TIME;

        // create a timer for 4 seconds
        e_timer = spawn();
        e_timer.classname = "spytimer";
        e_timer.owner = self;
        e_timer.think = CF_Spy_UndercoverThink;
        e_timer.nextthink = time + 1;
    }

    Status_Refresh(self);

};

void () CF_Spy_DisguiseStop = {
    local entity e_timer;
    local string s_class, s_team;

    if (!self.is_undercover)
        return;

    // set undercover class if spy had the time to change class
    if (self.undercover_skin)
        s_class = TeamFortress_GetClassName(self.undercover_skin);
    else
        s_class = "Spy";

    // set undercover team if spy had the time to change team
    if (self.undercover_team)
        s_team = TeamFortress_TeamGetColorString(self.undercover_team);
    else
        s_team = TeamFortress_TeamGetColorString(self.team_no);

    // show what's left of the disguise
    if (self.undercover_skin || self.undercover_team) {
        sprint(self, PRINT_HIGH, "Disguised as ", s_team, " ", s_class, "\n");
        self.is_undercover = 1;
        self.last_team = self.undercover_team;
    } else {
        sprint(self, PRINT_HIGH, "You stop going undercover\n");
        self.is_undercover = 0;
    }

    self.disguise_skin = 0;
    self.disguise_team = 0;
    self.queue_skin = 0;
    self.queue_team = 0;

    // remove disguise timers belonging to self
    e_timer = find(world, classname, "spytimer");
    while (e_timer != world) {
        if (e_timer.owner == self) {
            dremove(e_timer);
            e_timer = find(world, classname, "spytimer");
        } else {
            e_timer = find(e_timer, classname, "spytimer");
        }
    }

    Status_Refresh(self);
};

void (entity player, float is_user) FO_Spy_DisguiseLast = {
    if (!player.last_selected_skin) {
        FO_Spy_DisguiseLastSpawned(player, is_user);
        return;
    }

    if (self.is_undercover == 2 && player.last_selected_skin != player.disguise_skin) {
        CF_Spy_DisguiseStop();
    }

    local float undercover_team;
    if (player.last_team) {
        undercover_team = player.last_team;
    } else {
        if (player.team_no == 1) {
            undercover_team = 2;
        } else {
            undercover_team = 1;
        }
    }

    CF_Spy_ChangeColor(player, undercover_team, is_user);
    CF_Spy_ChangeSkin(player, player.last_selected_skin, is_user);
};

void (entity player, float is_user) FO_Spy_DisguiseLastSpawned = {
    local entity te = find(world, classname, "player");
    local float latest_spawn_time = 0;
    local entity enemy_to_disguise_as = world;

    while (te != world) {
        if (te.team_no != player.team_no) {
            if (te.spawn_time > latest_spawn_time) {
                latest_spawn_time = te.spawn_time;
                enemy_to_disguise_as = te;
            }
        }

        te = find(te, classname, "player");
    }

    if (enemy_to_disguise_as == world) {
        sprint(self.owner, PRINT_HIGH, "No enemies to disguise as!\n");
        return;
    }

    if (self.is_undercover == 2 && enemy_to_disguise_as.skin != player.disguise_skin) {
        CF_Spy_DisguiseStop();
    }

    if (enemy_to_disguise_as.team_no) {
        CF_Spy_ChangeColor(player, enemy_to_disguise_as.team_no, is_user);

        if (enemy_to_disguise_as.skin) {
            CF_Spy_ChangeSkin(player, enemy_to_disguise_as.skin, is_user);
        }
    } else {
        local float undercover_team;
        if (player.team_no == 1) {
            undercover_team = 2;
        } else {
            undercover_team = 1;
        }

        CF_Spy_ChangeColor(player, undercover_team, is_user);
    }
};

void (entity own) Spy_SetClientSkins = {
    entity te;
    string skin, dskin, sendcolor, sendskin, pteam, dsteam, sendteam;
    float dteam, dpc;

    dteam = own.undercover_team == 0 ? own.team_no : own.undercover_team;
    dpc = own.undercover_skin == 0 ? own.playerclass : own.undercover_skin;

    skin = TeamFortress_GetSkin(own.playerclass);
    dskin = TeamFortress_GetSkin(dpc);

    pteam = GetTeamName(own.team_no);
    dsteam = GetTeamName(dteam);

    te = find(world, classname, "player");
    while (te)
    {
        if (te.team_no)
        {
            if (te.team_no == own.team_no)
            {
                // on same team, send them spy/team (initial spawn etc)
                sendcolor = TeamFortress_TeamGetColorFor(te, own.team_no);
                sendskin = skin;
                sendteam = pteam;
            }
            else // not on same team, send them disguise
            {
                sendcolor = TeamFortress_TeamGetColorFor(te, dteam);
                sendskin = dskin;
                sendteam = dsteam;
            }

            msg_entity = te;

            // set skin
            WriteByte(MSG_ONE, SVC_SETINFO);
            WriteByte(MSG_ONE, own.colormap-1); // ???? 0 based player index
            WriteString(MSG_ONE, "skin");
            WriteString(MSG_ONE, sendskin);

            // set top colour / color
            WriteByte(MSG_ONE, SVC_SETINFO);
            WriteByte(MSG_ONE, own.colormap-1);
            WriteString(MSG_ONE, "topcolor");
            WriteString(MSG_ONE, sendcolor);

            // set bottom colour / color
            WriteByte(MSG_ONE, SVC_SETINFO);
            WriteByte(MSG_ONE, own.colormap-1);
            WriteString(MSG_ONE, "bottomcolor");
            WriteString(MSG_ONE, sendcolor);

            // set team to fix r_enemyskincolor cheat in clients
            WriteByte(MSG_ONE, SVC_SETINFO);
            WriteByte(MSG_ONE, own.colormap-1);
            WriteString(MSG_ONE, "team");
            WriteString(MSG_ONE, sendteam);
        }

        te = find(te, classname, "player");
    }
}

void () CF_Spy_UndercoverThink = {
    local string s_team, s_class;

    // keep track of seconds left to
    if (self.owner.undercover_timer > 1) {
        self.owner.undercover_timer = self.owner.undercover_timer - 1;
        self.nextthink = time + 1;
        Status_Refresh(self.owner);
        return;
    }

    // stop if player is not a spy
    if (self.owner.playerclass != PC_SPY)
        return;

    // stop if spy is not going undercover
    if (self.owner.is_undercover != 2)
        return;

    // make spy invisible if invis_only is turned on
    if (invis_only) {
        self.owner.items = self.owner.items | IT_INVISIBILITY;
        self.owner.frame = 0;
        self.owner.modelindex = modelindex_eyes;
        self.owner.is_undercover = 1;
    } else {

        // don't check for color cheating for next 10 seconds
        self.owner.immune_to_check = time + 10;

        if (self.skin) {
            self.owner.undercover_skin = self.skin;
            self.owner.disguise_skin = 0;
            self.owner.queue_skin = 0;
            self.owner.is_undercover = 1;
            TeamFortress_SetSkin(self.owner);

            if (self.owner.queue_team) {
                CF_Spy_ChangeColor(self.owner, self.owner.queue_team, FALSE);
            } else {
                if (self.owner.undercover_team)
                    s_team = TeamFortress_TeamGetColorString(self.owner.undercover_team);
                else
                    s_team = TeamFortress_TeamGetColorString(self.owner.team_no);
                if (self.owner.undercover_skin)
                    s_class = TeamFortress_GetClassName(self.owner.undercover_skin);
                else
                    s_class = "Spy";
                sprint(self.owner, PRINT_HIGH, "Disguised as ", s_team, " ", s_class, "\n");
            }

        } else if (self.team) {
            self.owner.undercover_team = self.team;
            self.owner.last_team = self.team;
            self.owner.queue_team = 0;
            self.owner.is_undercover = 1;
            TeamFortress_SetSkin(self.owner);

            if (self.owner.queue_skin) {
                CF_Spy_ChangeSkin(self.owner, self.owner.queue_skin, FALSE);
            } else {
                s_team = TeamFortress_TeamGetColorString(self.owner.undercover_team);
                if (self.owner.undercover_skin)
                    s_class = TeamFortress_GetClassName(self.owner.undercover_skin);
                else
                    s_class = "Spy";
                sprint(self.owner, PRINT_HIGH, "Disguised as ", s_team, " ", s_class, "\n");
            }
        }

        TeamFortress_SpyCalcName(self.owner);

    }

    Status_Refresh(self.owner);
    if (self.owner.menu_input == Menu_Spy_Input)
        Menu_Spy(self.owner);

    dremove(self);
};

void (entity pe_player, float pf_class, float is_user) CF_Spy_ChangeSkin = {
    pe_player.last_selected_skin = pf_class;

    // stop if you're already disguised as the requested skin
    if (pe_player.undercover_skin == pf_class)
        return;

    // stop if you're glowing
    if (pe_player.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT))
        return;

    // stop if you're unable to spy
    if (pe_player.is_unabletospy)
        return;

    // reset skin if skin is set to spy
    if (pf_class == PC_SPY) {
        sprint(pe_player, PRINT_HIGH, "Skin reset\n");
        pe_player.undercover_skin = 0;
        pe_player.disguise_skin = 0;
        pe_player.queue_skin = 0;
        TeamFortress_SetSkin(pe_player);
        if (!pe_player.undercover_team)
            pe_player.is_undercover = 0;
        return;
    }

    // queue skin change if currently going undercover
    if (pe_player.is_undercover == 2) {
        pe_player.queue_skin = pf_class;
        return;
    }

    // prepare disguise
    if (!pe_player.undercover_team)
        sprint(pe_player, PRINT_HIGH, "Going undercover...\n");
    else if(pe_player.undercover_skin != pf_class)
        sprint(pe_player, PRINT_HIGH, "Changing costumes...\n");

    pe_player.is_undercover = 2;
    pe_player.disguise_skin = pf_class;
    pe_player.disguise_team = 0;

    // disguise timer, finishes in 4 seconds
    pe_player.undercover_timer = PC_SPY_GO_UNDERCOVER_TIME;
    local entity e_timer;
    e_timer = spawn();
    e_timer.classname = "spytimer";
    e_timer.owner = pe_player;
    e_timer.think = CF_Spy_UndercoverThink;
    e_timer.nextthink = (is_user ? time : time) + 1;
    e_timer.skin = pf_class;

    Status_Refresh(pe_player);
};

void (entity pe_player, float pf_team_no, float is_user) CF_Spy_ChangeColor = {
    local entity e_timer;

    // stop if you're already disguised as the requested skin
    if (pe_player.undercover_team == pf_team_no)
        return;

    // stop if you're glowing
    if (pe_player.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT))
        return;

    // stop if you're unable to spy
    if (pe_player.is_unabletospy)
        return;

    // reset team if team is set to home team
    if (pf_team_no == pe_player.team_no) {
        sprint(pe_player, PRINT_HIGH, "Colors reset\n");
        pe_player.immune_to_check = time + 10;
        pe_player.undercover_team = 0;
        pe_player.disguise_team = 0;
        pe_player.queue_team = 0;
        if (!pe_player.undercover_skin)
            pe_player.is_undercover = 0;
        TeamFortress_SetSkin(pe_player);
        return;
    }

    // queue team change if currently going undercover
    if (pe_player.is_undercover == 2) {
        pe_player.queue_team = pf_team_no;
        return;
    }

    // prepare disguise
    if (!pe_player.undercover_skin)
        sprint(pe_player, PRINT_HIGH, "Going undercover...\n");
    pe_player.is_undercover = 2;
    pe_player.disguise_skin = 0;
    pe_player.disguise_team = pf_team_no;

    // disguise timer, finishes in 4 seconds
    pe_player.undercover_timer = PC_SPY_GO_UNDERCOVER_TIME;
    e_timer = spawn();
    e_timer.classname = "spytimer";
    e_timer.owner = pe_player;
    e_timer.think = CF_Spy_UndercoverThink;
    e_timer.nextthink = (is_user ? time : time) + 1;
    e_timer.team = pf_team_no;

    Status_Refresh(pe_player);
};

void (entity spy) TeamFortress_SpyCalcName = {
    local entity te;

    spy.undercover_name = string_null;
    if (spy.undercover_team != 0) {
        te = find(world, classname, "player");
        while (te) {
            if ((te.team_no == spy.undercover_team) &&
                    (te.skin == spy.undercover_skin)) {
                spy.undercover_name = te.netname;
                te = world;
            } else {
                te = find(te, classname, "player");
            }
        }
        if (spy.undercover_name == string_null) {
            te = find(world, classname, "player");
            while (te) {
                if (te.team_no == spy.undercover_team) {
                    spy.undercover_name = te.netname;
                    te = world;
                } else {
                    te = find(te, classname, "player");
                }
            }
        }
    }
};

void () GasGrenadeTouch = {
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, 1);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

void () GasGrenadeExplode2;

// GasGrenadeExplode1 handles the initial "pre-explosion".
// GasGrenadeExplode2 handles aoe emission.
void () GasGrenadeExplode1 = {
    local float pos;

    pos = pointcontents(self.origin);
    if (pos == -1) {
        self.think = GasGrenadeExplode2;
        self.nextthink = time + 0.1;
        self.heat = 0;
        self.dimension_seen = DMN_INVISIBLE;
        self.movetype = MOVETYPE_NONE;
    } else {
        pos = 0;
        while (pos < 10) {
            newmis = spawn();
            FO_SetModel(newmis, "progs/s_bubble.spr");
            setorigin(newmis, self.origin);
            newmis.movetype = 8;
            newmis.solid = 0;
            newmis.velocity = '0 0 15';
            newmis.velocity_z = 10 + (random() * 20);
            newmis.nextthink = time + 0.5;
            newmis.think = bubble_bob;
            newmis.classname = "bubble";
            newmis.frame = 0;
            newmis.cnt = 0;
            setsize(newmis, '-8 -8 -8', '8 8 8');
            pos = pos + 1;
        }
        dremove(self);
    }
};

void () GasGrenadeExplode2 = {
    local entity te;
    local entity timer;

    self.nextthink = time + 0.75;
    te = findradius(self.origin, 200);
    while (te != world) {
        if (CanDamage(te, self)) {
            if (((te.classname == "player") && (te.deadflag == 0)) &&
                    (te.has_disconnected != 1)) {
                deathmsg = 24;
                TF_T_Damage(te, world, self.owner, 10, (1 | 2), 0);
                if (te.tfstate & TFSTATE_HALLUCINATING) {
                    timer = find(world, classname, "timer");
                    while (((timer.owner != te) ||
                                (timer.think != HallucinationTimer)) &&
                            (timer != world)) {
                        timer = find(timer, classname, "timer");
                    }
                    if (timer != world) {
                        timer.health = timer.health + 25;
                        if (old_grens == 1) {
                            if (timer.health < 100) {
                                timer.health = 100;
                            }
                            timer.nextthink = time + 0.5;
                        } else {
                            if (timer.health < 150) {
                                timer.health = 150;
                            }
                            timer.nextthink = time + 0.3;
                        }
                    }
                } else {
                    LogEventAffliction(self.owner, te, TFSTATE_HALLUCINATING);
                    if (old_grens == 1) {
                        stuffcmd(te, "v_cshift 50 25 50 -50\n");
                        sprint(te, PRINT_HIGH, "Far out man!\n");
                    } else {
                        sprint(te, PRINT_HIGH,
                                "Run for cover! They are everywhere!\n");
                    }
                    te.tfstate = te.tfstate | TFSTATE_HALLUCINATING;
                    timer = spawn();
                    if (old_grens == 1)
                        timer.nextthink = time + 0.5;
                    else
                        timer.nextthink = time + 0.3;
                    timer.think = HallucinationTimer;
                    timer.classname = "timer";
                    timer.owner = te;
                    if (old_grens == 1)
                        timer.health = 100;
                    else
                        timer.health = 150;
                    timer.team_no = self.team_no;
                }
            }
        }
        te = te.chain;
    }
    self.heat = self.heat + 1;
    if (self.heat == 1) {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_TAREXPLOSION);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PVS);
        return;
    }
    if (self.heat <= 20) {
        self.weapon = self.weapon + 1;
        if (self.weapon == 1) {
            WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
            WriteByte(MSG_MULTICAST, TE_LAVASPLASH);
            WriteCoord(MSG_MULTICAST, self.origin_x);
            WriteCoord(MSG_MULTICAST, self.origin_y);
            WriteCoord(MSG_MULTICAST, self.origin_z - 24);
            multicast(self.origin, MULTICAST_PVS);
        } else if (self.weapon == 2)
            self.weapon = 0;
        return;
    }
    dremove(self);
};

void () HallucinationTimer = {
    local entity te;
    local float tmpx;
    local float tmpy;
    local float halltype;
    local float halltype2;
    local string st;

    self.health = self.health - 2.5;
    if (self.owner.playerclass == PC_MEDIC) {
        self.health = self.health - 2.5;
    }
    if (((self.health <= 0) || (self.owner.deadflag != 0)) ||
            (self.owner.has_disconnected == 1)) {
        self.owner.tfstate =
            self.owner.tfstate - (self.owner.tfstate & TFSTATE_HALLUCINATING);
    }
    if ((self.owner.deadflag != 0) || (self.owner.has_disconnected == 1)) {
        dremove(self);
        return;
    }
    if (!(self.owner.tfstate & TFSTATE_HALLUCINATING)) {
        if (old_grens == 1)
            stuffcmd(self.owner, "v_cshift; wait; bf\n");
        sprint(self.owner, 2, "You feel a little better now\n");
        dremove(self);
        return;
    }
    if (old_grens == 1)
        self.nextthink = time + 0.5;
    else
        self.nextthink = time + 0.3;

    if (random() < 0.5)
        KickPlayer(-10, self.owner);

    if (old_grens == 1) {
        stuffcmd(self.owner, "v_cshift ");
        halltype = random() * 100;
        st = ftos(halltype);
        stuffcmd(self.owner, st);
        stuffcmd(self.owner, " ");
        halltype = random() * 100;
        st = ftos(halltype);
        stuffcmd(self.owner, st);
        stuffcmd(self.owner, " ");
        halltype = random() * 100;
        st = ftos(halltype);
        stuffcmd(self.owner, st);
        stuffcmd(self.owner, " -75\n");
    }
    tmpx = random() * 800 - 400;
    tmpy = random() * 800 - 400;
    halltype = random();
    halltype2 = random();
    msg_entity = self.owner;
    if (halltype < 0.4) {
        WriteByte(MSG_ONE, SVC_TEMPENTITY);
        if (halltype < 0.25) {
            WriteByte(MSG_ONE, TE_EXPLOSION);
        } else if (halltype < 0.35) {
            WriteByte(MSG_ONE, TE_TAREXPLOSION);
        } else {
            WriteByte(MSG_ONE, TE_LAVASPLASH);
        }
        WriteCoord(MSG_ONE, msg_entity.origin_x + tmpx);
        WriteCoord(MSG_ONE, msg_entity.origin_y + tmpy);
        WriteCoord(MSG_ONE, msg_entity.origin_z);

        if (old_grens != 1)
            T_Damage(self.owner, self.owner, self.owner, 0);

    } else if (halltype < 0.7) {
        WriteByte(MSG_ONE, SVC_TEMPENTITY);
        WriteByte(MSG_ONE, TE_TELEPORT);
        WriteCoord(MSG_ONE, msg_entity.origin_x + tmpx);
        WriteCoord(MSG_ONE, msg_entity.origin_y + tmpy);
        WriteCoord(MSG_ONE, msg_entity.origin_z);

        if (old_grens != 1) {
            if (halltype2 < 0.1) {
                stuffcmd(self.owner, "play weapons/r_exp3.wav\n");
            } else if (halltype2 < 0.15) {
                stuffcmd(self.owner, "play weapons/rocket1i.wav\n");
            } else if (halltype2 < 0.2) {
                stuffcmd(self.owner, "play weapons/sgun1.wav\n");
            } else if (halltype2 < 0.25) {
                stuffcmd(self.owner, "play weapons/guncock.wav\n");
            } else if (halltype2 < 0.3) {
                stuffcmd(self.owner, "play weapons/ric1.wav\n");
            } else if (halltype2 < 0.35) {
                stuffcmd(self.owner, "play weapons/ric2.wav\n");
            } else if (halltype2 < 0.4) {
                stuffcmd(self.owner, "play weapons/ric3.wav\n");
            } else if (halltype2 < 0.45) {
                stuffcmd(self.owner, "play weapons/spike2.wav\n");
            } else if (halltype2 < 0.5) {
                stuffcmd(self.owner, "play weapons/tink1.wav\n");
            } else if (halltype2 < 0.55) {
                CenterPrint2(self.owner, "\n\n\n",
                        Q"Your team \scaptured\s the flag!!");
                stuffcmd(self.owner, "play weapons/grenade.wav\n");
            } else if (halltype2 < 0.6) {
                stuffcmd(self.owner, "play weapons/bounce.wav\n");
            } else if (halltype2 < 0.65) {
                stuffcmd(self.owner, "play weapons/shotgn2.wav\n");
            } else if (halltype2 < 0.7) {
                stuffcmd(self.owner, "play wizard/wattack.wav\n");
            } else if (halltype2 < 0.75) {
                stuffcmd(self.owner, "play items/r_item1.wav\n");
            } else if (halltype2 < 0.8) {
                stuffcmd(self.owner, "play items/r_item2.wav\n");
            } else if (halltype2 < 0.85) {
                CenterPrint(self.owner, "You are on fire!\n");
                stuffcmd(self.owner, "play weapons/lhit.wav\n");
            } else if (halltype2 < 0.9) {
                stuffcmd(self.owner, "play misc/r_tele1.wav\n");
            } else {
                stuffcmd(self.owner, "play weapons/railgun.wav\n");
            }
        }
    } else {
        te = spawn();
        te.origin_x = msg_entity.origin_x + tmpx;
        te.origin_y = msg_entity.origin_y + tmpy;
        te.origin_z = msg_entity.origin_z;

        WriteByte(MSG_ONE, SVC_TEMPENTITY);
        WriteByte(MSG_ONE, TE_LIGHTNING2);
        WriteEntity(MSG_ONE, te);
        WriteCoord(MSG_ONE, te.origin_x);
        WriteCoord(MSG_ONE, te.origin_y);
        WriteCoord(MSG_ONE, te.origin_z);
        tmpx = random() * 800 - 400;
        tmpy = random() * 800 - 400;
        WriteCoord(MSG_ONE, msg_entity.origin_x + tmpx);
        WriteCoord(MSG_ONE, msg_entity.origin_y + tmpy);
        WriteCoord(MSG_ONE, msg_entity.origin_z);

        if (old_grens != 1) {
            if (halltype2 < 0.1) {
                stuffcmd(self.owner, "play weapons/detpack.wav\n");
            } else if (halltype2 < 0.2) {
                stuffcmd(self.owner, "play weapons/turrset.wav\n");
            } else if (halltype2 < 0.3) {
                stuffcmd(self.owner, "play weapons/turrspot.wav\n");
            } else if (halltype2 < 0.4) {
                stuffcmd(self.owner, "play weapons/turridle.wav\n");
            } else if (halltype2 < 0.5) {
                stuffcmd(self.owner, "play weapons/sniper.wav\n");
            } else if (halltype2 < 0.6) {
                CenterPrint2(self.owner, "\n\n\n",
                        Q"Your flag has been \staken\s!!");
                stuffcmd(self.owner, "play weapons/flmfire2.wav\n");
            } else if (halltype2 < 0.7) {
                stuffcmd(self.owner, "play weapons/flmgrexp.wav\n");
            } else if (halltype2 < 0.8) {
                stuffcmd(self.owner, "play misc/vapeur2.wav\n");
            } else if (halltype2 < 0.9) {
                stuffcmd(self.owner, "play weapons/asscan1.wav\n");
            } else {
                stuffcmd(self.owner, "play weapons/asscan2.wav\n");
            }
        }
        dremove(te);
    }
};

void () W_FireTranq = {
    self.ammo_shells = self.ammo_shells - 1;
    KickPlayer(-2, self);
    entity proj = FOProj_Create(FPP_TRANQ);
    proj.owner = self;
    proj.movetype = 9;
    proj.solid = 2;
    makevectors(self.v_angle);
    proj.velocity = v_forward;
    proj.velocity = proj.velocity * FPP_Get(FPP_TRANQ)->speed;
    proj.angles = vectoangles(proj.velocity);
    proj.touch = T_TranqDartTouch;
    proj.think = SUB_Remove;
    proj.nextthink = time + 6;
    proj.classname = "proj_tranq";
    setorigin(proj, self.origin + v_forward * 8 + '0 0 16');

    FOProj_Finalize(proj);
};

void () T_TranqDartTouch = {
    local entity timer;

    if (other.solid == SOLID_TRIGGER)
        return;

    if (self.voided)
        return;
    self.voided = 1;

    if (other.takedamage) {
        if ((other.classname == "player") &&
                !((other.team_no == self.owner.team_no) &&
                    (teamplay & (2 | 4)))) {

            LogEventAffliction(self.owner, other, TFSTATE_TRANQUILISED);

            if (other.tfstate & TFSTATE_TRANQUILISED) {
                timer = find(world, classname, "timer");
                while (((timer.owner != other) ||
                            (timer.think != TranquiliserTimer)) &&
                        (timer != world)) {
                    timer = find(timer, classname, "timer");
                }
                if (timer != world) {
                    timer.nextthink = time + 15;
                }
            } else {
                sprint(other, 2, "You feel tired...\n");
                other.tfstate |= TFSTATE_TRANQUILISED;
                timer = spawn();
                timer.nextthink = time + 15;
                timer.think = TranquiliserTimer;
                timer.classname = "timer";
                timer.owner = other;
                timer.team_no = self.owner.team_no;
            }
        }
        spawn_touchblood(9);
        deathmsg = 25;

        float dmg = IsClownMode(CLOWN_LETHAL_TRANQ) ? 999 : 20;
        TF_T_Damage(other, self, self.owner, dmg, 2, 2);
    } else {
        WriteByte(4, 23);
        if (self.classname == "wizspike") {
            WriteByte(4, 7);
        } else {
            if (self.classname == "knightspike") {
                WriteByte(4, 8);
            } else {
                WriteByte(4, 0);
            }
        }
        WriteCoord(4, self.origin_x);
        WriteCoord(4, self.origin_y);
        WriteCoord(4, self.origin_z);
        multicast(self.origin, 2);
    }
    dremove_sent(self);
};

void () TranquiliserTimer = {
    self.owner.tfstate &= ~TFSTATE_TRANQUILISED;
    sprint(self.owner, PRINT_HIGH, "You feel more alert now\n");
    dremove(self);
};

void (entity spy) Spy_RemoveDisguise = {
    local float coverblown = 0;

    if (invis_only != 1) {
        if (spy.playerclass == 8) {
            if (spy.undercover_team != 0) {
                spy.immune_to_check = time + 10;
                spy.undercover_team = 0;
                spy.disguise_team = 0;
                coverblown = 1;
            }
            if (spy.undercover_skin != 0) {
                spy.immune_to_check = time + 10;
                spy.undercover_skin = 0;
                spy.disguise_skin = 0;
                spy.skin = 0;
                coverblown = 1;
            }
            spy.is_undercover = 0;
            Status_Refresh(self);
            TeamFortress_SetSkin(spy);
            TeamFortress_SpyCalcName(spy);
        }
    } else if (spy.is_undercover) {
        coverblown = 1;
        spy.is_undercover = 0;
        spy.modelindex = modelindex_player;
        if (spy.items & IT_INVISIBILITY) {
            spy.invisible_finished = 0;
            spy.invisible_time = 0;
            spy.items = spy.items - IT_INVISIBILITY;
        }
        Status_Refresh(self);
    }

    local entity timer = find(world, classname, "spytimer");
    while (timer) {
        if (timer.owner == self) {
            dremove(timer);
        }

        timer = find(timer, classname, "spytimer");
    }

    if (coverblown) {
        Status_Print(self, "\n\n\n\n\n\n\n", "You blew your cover!");
    }

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

void () Spy_DropBackpack = {
    if (cb_prematch)
        return;

    newmis = spawn();
    newmis.origin = self.origin - '0 0 24';

    newmis.ammo_shells = 0;
    newmis.ammo_nails = 0;
    newmis.ammo_rockets = 0;
    newmis.ammo_cells = 0;

    newmis.armorvalue = 0;

    newmis.velocity_z = 300;
    newmis.velocity_x = -100 + random() * 200;
    newmis.velocity_y = -100 + random() * 200;

    newmis.flags = FL_ITEM;
    newmis.solid = SOLID_TRIGGER;
    newmis.movetype = MOVETYPE_TOSS;

    if(splitbackpackmodels)
        FO_SetModel(newmis, "progs/deathbag.mdl");
    else
        FO_SetModel(newmis, "progs/backpack.mdl");

    setsize(newmis, '-16 -16 0', '16 16 56');
    newmis.touch = BackpackTouch;
    newmis.classname = "backpack";

    newmis.nextthink = time + 120;
    newmis.think = SUB_Remove;
};
