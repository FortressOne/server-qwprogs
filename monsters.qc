float (entity targ) visible = {
    local vector spot1, spot2;

    spot1 = self.origin + self.view_ofs;
    spot2 = targ.origin + targ.view_ofs;
    traceline(spot1, spot2, 1, self);
    if (trace_inopen && trace_inwater)
        return (FALSE);

    if (trace_fraction == 1)
        return (TRUE);

    return (FALSE);
};

void () monster_ogre = {
    dremove(self);
};

void () monster_knight = {
    dremove(self);
};

void () monster_shambler = {
    dremove(self);
};

void () monster_demon1 = {
    dremove(self);
};

void () monster_wizard = {
    dremove(self);
};

void () monster_zombie = {
    dremove(self);
};

void () monster_dog = {
    dremove(self);
};

void () monster_hell_knight = {
    dremove(self);
};

void () monster_tarbaby = {
    dremove(self);
};

void () monster_vomit = {
    dremove(self);
};

void () monster_enforcer = {
    dremove(self);
};

void () monster_shalrath = {
    dremove(self);
};

void () monster_dragon = {
    dremove(self);
};

void () monster_army = {
    dremove(self);
};

void () t_movetarget;

void () movetarget_f = {
    if (!self.targetname)
        objerror("monster_movetarget: no targetname");

    self.solid = SOLID_TRIGGER;
    self.touch = t_movetarget;
    setsize(self, '-8 -8 -8', '8 8 8');
};

void () path_corner = {
    if (CheckExistence() == FALSE) {
        dremove(self);
        return;
    }
    movetarget_f();
};

void () t_movetarget = {
    local entity temp;

    if (other.movetarget != self)
        return;

    if (other.enemy)
        return;

    temp = self;
    self = other;
    other = temp;
    self.movetarget = find(world, targetname, other.target);
    self.goalentity = find(world, targetname, other.target);
    self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
    if (!self.movetarget) {

        self.pausetime = (time + 999999);
        self.th_stand();
        return;
    }

};
/*
float (float v) anglemod = {
    while (v >= 360)
        v = v - 360;
    while (v < 0)
        v = v + 360;
    return (v);
};
*/
float (entity targ) range = {
    local vector spot1;
    local vector spot2;
    local float r;

    spot1 = self.origin + self.view_ofs;
    spot2 = targ.origin + targ.view_ofs;

    r = vlen(spot1 - spot2);
    if (r < 120)
        return (RANGE_MELEE);

    if (r < 500)
        return (RANGE_NEAR);

    if (r < 1000)
        return (RANGE_MID);

    return (RANGE_FAR);
};

float (entity targ) infront = {
    local vector vec;
    local float dot;

    makevectors(self.angles);
    vec = normalize(targ.origin - self.origin);
    dot = vec * v_forward;
    if (dot > 0.3)
        return (1);
    return (0);
};

void () HuntTarget = {
    self.goalentity = self.enemy;
    self.think = self.th_run;
    self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
    self.nextthink = time + 0.1;
    SUB_AttackFinished(1);
};

float () FindTarget = {
    local entity client;

    client = checkclient();
    if (!client)
        return (FALSE);

    if (client.flags & FL_NOTARGET)
        return (FALSE);

    if (client.items & IT_INVISIBILITY)
        return (FALSE);

    if (!visible(client))
        return (FALSE);

    if (client.classname != "player")
        return (FALSE);

    self.enemy = client;
    HuntTarget();
    return (TRUE);
};
