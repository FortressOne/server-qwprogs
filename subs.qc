void (entity Goal, entity AP) DoGoalWork;
void (entity Goal, entity AP) DoGroupWork;

void FO_SetModel(entity e, string fomdl)
{
    //e.dimension_seen = e.dimension_seen - (e.dimension_seen & DMN_FLASH);
    e.dimension_seen = DMN_NOFLASH;
    setmodel(e, fomdl);
}

void FO_Sound(entity e, float chan, string samp, float vol, float atten)
{
    float olddimens = e.dimension_seen;
    // make the sound go to no flash, so it isn't heard by those that are flashed
    e.dimension_seen = DMN_NOFLASH;
    sound(e, chan, samp, vol, atten);
    e.dimension_seen = olddimens;
}

void () SUB_Null = {
};

void (entity et, float f) SUB_Null_pain = {
};

void () SUB_Remove = {
    dremove(self);
};

void () SetMovedir = {
    if (self.angles == '0 -1 0')
        self.movedir = '0 0 1';
    else if (self.angles == '0 -2 0')
        self.movedir = '0 0 -1';
    else {
        makevectors(self.angles);
        self.movedir = v_forward;
    }
    self.angles = '0 0 0';
};

void () InitTrigger = {
    if (self.angles != '0 0 0')
        SetMovedir();

    self.solid = SOLID_TRIGGER;
    setmodel(self, self.model);
    self.movetype = MOVETYPE_NONE;
    self.modelindex = 0;
    self.model = "";

};

void (vector tdest, float tspeed, void ()func) SUB_CalcMove = {
    local vector vdestdelta;
    local float len;
    local float traveltime;

    if (!tspeed)
        objerror("No speed is defined!");

    self.think1 = func;
    self.finaldest = tdest;
    self.think = SUB_CalcMoveDone;

    if (tdest == self.origin) {
        self.velocity = '0 0 0';
        self.nextthink = self.ltime + 0.1;
        return;
    }
    vdestdelta = tdest - self.origin;
    len = vlen(vdestdelta);
    traveltime = len / tspeed;

    if (traveltime < 0.03)
        traveltime = 0.03;

    self.nextthink = self.ltime + traveltime;
    self.velocity = vdestdelta * (1 / traveltime);
};

void (entity ent, vector tdest, float tspeed,
      void ()func) SUB_CalcMoveEnt = {
    local entity stemp;

    stemp = self;
    self = ent;
    SUB_CalcMove(tdest, tspeed, func);
    self = stemp;

};

void () SUB_CalcMoveDone = {
    setorigin(self, self.finaldest);
    self.velocity = '0 0 0';
    self.nextthink = -1;
    if (self.think1)
        self.think1();
};

void (vector destangle, float tspeed, void ()func) SUB_CalcAngleMove = {
    local vector destdelta;
    local float len;
    local float traveltime;

    if (!tspeed)
        objerror("No speed is defined!");

    destdelta = destangle - self.angles;
    len = vlen(destdelta);
    traveltime = len / tspeed;
    self.nextthink = self.ltime + traveltime;
    self.avelocity = destdelta * (1 / traveltime);
    self.think1 = func;
    self.finalangle = destangle;
    self.think = SUB_CalcAngleMoveDone;
};

void (entity ent, vector destangle, float tspeed,
      void ()func) SUB_CalcAngleMoveEnt = {
    local entity stemp;

    stemp = self;
    self = ent;
    SUB_CalcAngleMove(destangle, tspeed, func);
    self = stemp;
};

void () SUB_CalcAngleMoveDone = {
    self.angles = self.finalangle;
    self.avelocity = '0 0 0';
    self.nextthink = -1;
    if (self.think1)
        self.think1();
};

void () DelayThink = {
    activator = self.enemy;
    SUB_UseTargets();
    dremove(self);
};

void () SUB_UseTargets = {
    local entity t, stemp, otemp, act;

    if (self.dont_do_triggerwork) {

        self.dont_do_triggerwork = FALSE;
        return;
    }
    if (self.delay) {

        t = spawn();
        t.classname = "DelayedUse";
        t.nextthink = time + self.delay;
        t.think = DelayThink;
        t.enemy = activator;
        t.message = self.message;
        t.killtarget = self.killtarget;
        t.target = self.target;
        return;
    }
    if ((activator.classname == "player") && (self.message != "")) {

        CenterPrint(activator, self.message);
        if (!self.noise)
            FO_Sound(activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
    }

    if (activator.classname == "player") {

        DoGroupWork(self, activator);
        DoGoalWork(self, activator);
    }
    if (self.killtarget) {

        t = world;
        do {
            t = find(t, targetname, self.killtarget);
            if (!t)
                return;
            remove(t);

        } while (TRUE);
    }
    if (self.target) {

        act = activator;
        t = world;
        do {
            t = find(t, targetname, self.target);
            if (!t)
                return;
            stemp = self;
            otemp = other;
            self = t;
            other = stemp;
            if (self.use != SUB_Null) {

                if (self.use)
                    self.use();
            }
            self = stemp;
            other = otemp;
            activator = act;

        } while (TRUE);
    }
};

void (float normal) SUB_AttackFinished = {
    self.cnt = 0;
    if (skill < 3)
        self.attack_finished = time + normal;
};

float (entity targ) visible;

void (void ()thinkst) SUB_CheckRefire = {
    if (skill < 3)
        return;
    if (self.cnt == 1)
        return;
    if (!visible(self.enemy))
        return;
    self.cnt = 1;
    self.think = thinkst;
};
