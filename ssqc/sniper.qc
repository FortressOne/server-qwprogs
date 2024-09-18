//========================================================
// Functions for the SNIPER class and associated weaponry
//========================================================

void () SniperSight_Update = {
    local vector org;

    if (!(self.owner.tfstate & TFSTATE_AIMING) ||
        (FO_PlayerCurrentWeapon(self.owner) != WEAP_SNIPER_RIFLE)) {

        self.owner.tfstate &= ~TFSTATE_AIMING;
        self.owner.heat = 0;
        dremove(self);
        return;
    }

    makevectors(self.owner.v_angle);
    org = self.owner.origin + v_forward * 10;
    org_z = self.owner.absmin_z + self.owner.size_z * 0.7;

    traceline(org, org + v_forward * 9192, FALSE, self);

    if (trace_fraction == 1) {
        setorigin(self, self.owner.origin);
        return;
    }
    self.angles = vectoangles(v_forward);
    setorigin(self, trace_endpos);
    self.nextthink = time + 0.1;
};

static float sight_send_filter() {
    if (other == self.owner)
        return FALSE;

    return TRUE;
}

void () SniperSight_Create = {
    local entity sight;

    if (self.has_disconnected == TRUE || (self.tfstate & TFSTATE_RELOADING))
        return;

    self.tfstate = self.tfstate | TFSTATE_AIMING;

    sight = spawn();
    sight.owner = self;
    sight.movetype = MOVETYPE_NOCLIP;
    sight.solid = SOLID_NOT;

    FO_SetModel(sight, "progs/sight.spr");

    sight.classname = "timer";

    setorigin(sight, self.origin);

    sight.think = SniperSight_Update;
    sight.nextthink = time + 0.05;
#pragma warning disable F326
    if (ClientPred_Enabled(self, CSQC_SNIPER_SIGHT))
        sight.customizeentityforclient = sight_send_filter;
#pragma warning enable F326
};
