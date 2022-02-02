//========================================================
// Functions for the SNIPER class and associated weaponry
//========================================================

void (float zoom_to) Sniper_Zoom = {
    self.default_fov = stof(infokey(self, "df"));
    self.default_sensitivity = stof(infokey(self, "ds"));
    self.zoom_fov = stof(infokey(self, "zf"));

    if (self.default_fov == 0)
        return;

    if (zoom_to >= self.default_fov)
        Sniper_ZoomReset(self);
    else if (zoom_to != self.current_fov) {
        if (zoom_to < self.default_fov)
            self.zoom_last = zoom_to;
        self.current_fov = zoom_to;
        stuffcmd(self, "fov ");
        stuffcmd(self, ftos(zoom_to));
        stuffcmd(self, "\n");

        if (self.default_sensitivity > 0) {
            stuffcmd(self, "sensitivity ");
            stuffcmd(self, ftos(self.default_sensitivity * zoom_to / self.default_fov));
            stuffcmd(self, "\n");
        }
    }
};

void (entity pl) Sniper_ZoomReset = {
    pl.default_sensitivity = stof(infokey(pl, "ds"));
    pl.default_fov = stof(infokey(pl, "df"));

    pl.is_zooming = 0;

    if (pl.default_fov > 0) {
        pl.current_fov = pl.default_fov;
        stuffcmd(pl, "fov ");
        stuffcmd(pl, ftos(pl.default_fov));
        stuffcmd(pl, "\n");
    }

    if (pl.default_sensitivity > 0) {
        stuffcmd(pl, "sensitivity ");
        stuffcmd(pl, ftos(pl.default_sensitivity));
        stuffcmd(pl, "\n");
    }
};

void () Sniper_ZoomToggle = {
    local float magnification = 0;
    local float zoom_to = 0;

    if (self.playerclass != PC_SNIPER)
        return;

    self.default_fov = stof(infokey(self, "df"));
    self.default_sensitivity = stof(infokey(self, "ds"));
    self.zoom_fov = stof(infokey(self, "zf"));

    if (self.default_fov == 0) {
        sprint(self, PRINT_HIGH, "Use \"setinfo df <fov>\" to set default fov to use sniper zoom. Use \"setinfo ds <sensitivity>\" to set default sensitivity for sensitivity scaling.\n");
        return;
    }

    if (self.is_zooming) {
        self.is_zooming = 0;
        zoom_to = self.default_fov;
        sprint(self, PRINT_HIGH, "Zoomed out\n");
    } else {
        self.is_zooming = 1;
        if (self.zoom_last && self.zoom_last < self.default_fov)
            zoom_to = self.zoom_last;
        else if (self.zoom_fov)
            zoom_to = self.zoom_fov;
        else
            zoom_to = 30;

        magnification = floor(self.default_fov / zoom_to);
        sprint(self, PRINT_HIGH, ftos(magnification), "x zoom\n");
    }

    Sniper_Zoom(zoom_to);
};

void (float zoom_in) Sniper_ZoomAdjust = {
    local float zoom_to = 0;
    local float zoom_steps = 0;

    if (self.playerclass != PC_SNIPER || !self.is_zooming)
        return;

    zoom_steps = stof(infokey(self, "zs"));
    if (!zoom_steps)
        zoom_steps = 5;

    if (self.default_fov == 0) {
        sprint(self, PRINT_HIGH, "Use \"setinfo df <fov>\" to set default fov to use sniper zoom. Use \"setinfo ds <sensitivity>\" to set default sensitivity for sensitivity scaling.\n");
        return;
    }

    if (zoom_in)
        zoom_to = self.current_fov - zoom_steps;
    else
        zoom_to = self.current_fov + zoom_steps;

    if (zoom_to <= 10)
        zoom_to = 10;
    else if (zoom_to >= self.default_fov)
        zoom_to = self.default_fov;

    self.zoom_last = zoom_to;

    Sniper_Zoom(zoom_to);
};

void () SniperSight_Update = {
    local vector org;

    if (!(self.owner.tfstate & TFSTATE_AIMING) ||
        (self.owner.current_weapon != WEAP_SNIPER_RIFLE)) {

        self.owner.tfstate =
            self.owner.tfstate - (self.owner.tfstate & TFSTATE_AIMING);
        TeamFortress_SetSpeed(self.owner);
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
};
