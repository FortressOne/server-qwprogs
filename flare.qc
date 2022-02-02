//====================================
// This file handles all the functions
// to deal with the flare 'grenade'.
//====================================

void () FlareGrenadeTouch = {
    FO_Sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (pointcontents(self.origin) == CONTENT_SKY) {
        dremove(self);
        return;
    }
    if (other == world) {
        self.movetype = MOVETYPE_NONE;
        self.velocity = '0 0 0';
    }
    if (self.velocity == '0 0 0') {
        self.avelocity = '0 0 0';
        self.touch = SUB_Null;
    }
};

void () FlareGrenadeThink = {
    local float rnum;
    local float time_left;

    time_left = self.health - time;
    if (time_left > 33) {

        rnum = random();
        if (rnum < 0.5)
            self.effects = EF_DIMLIGHT;
        else
            self.effects = 0;

        self.nextthink = time + 0.05 + random() * 0.1;

    } else if (time_left > 31) {

        rnum = random();
        if (rnum < 0.5)
            self.effects = EF_BRIGHTLIGHT;
        else
            self.effects = EF_DIMLIGHT;

        self.nextthink = time + 0.05 + random() * 0.1;

    } else if (time_left > 15) {

        self.effects = EF_BRIGHTLIGHT;
        self.nextthink = time + 10;

    } else if (time_left < 1) {

        RemoveFlare();

    } else {
        self.effects = 8;
        self.nextthink = time + time_left;
    }
};

void () FlareGrenadeExplode = {
    self.skin = 1;
    self.health = time + 40;
    self.nextthink = time + 0.05 + random() * 0.1;
    self.think = FlareGrenadeThink;
};

void () RemoveFlare = {
    self.effects = self.effects - (self.effects & EF_BRIGHTLIGHT);
    dremove(self);
};
