//========================================================
// This file handles all the cooperative mode functions
//========================================================

void () DroppedKeyThink = {
    self.think = SUB_Null;
    self.touch = key_touch;
    self.owner = world;
};

void () DropKey = {
    if ((self.items & IT_KEY1) || (self.items & IT_KEY2)) {
        newmis = spawn();
        if (self.items & IT_KEY1) {
            self.items = self.items - (self.items & IT_KEY1);
            newmis.items = IT_KEY1;
            if (world.worldtype == 0) {
                FO_SetModel(newmis, "progs/w_s_key.mdl");
                newmis.netname = "silver key";
                newmis.noise = "misc/medkey.wav";
            } else if (world.worldtype == 1) {
                FO_SetModel(newmis, "progs/m_s_key.mdl");
                newmis.netname = "silver runekey";
                newmis.noise = "misc/runekey.wav";
            } else if (world.worldtype == 2) {
                FO_SetModel(newmis, "progs/b_s_key.mdl");
                newmis.netname = "silver keycard";
                newmis.noise = "misc/basekey.wav";
            }
        } else if (self.items & IT_KEY2) {
            self.items = self.items - (self.items & IT_KEY2);
            newmis.items = IT_KEY2;
            if (world.worldtype == 0) {
                FO_SetModel(newmis, "progs/w_g_key.mdl");
                newmis.netname = "gold key";
                newmis.noise = "misc/medkey.wav";
            } else if (world.worldtype == 1) {
                FO_SetModel(newmis, "progs/m_g_key.mdl");
                newmis.netname = "gold runekey";
                newmis.noise = "misc/runekey.wav";
            } else if (world.worldtype == 2) {
                FO_SetModel(newmis, "progs/b_g_key.mdl");
                newmis.netname = "gold keycard";
                newmis.noise = "misc/basekey.wav";
            }
        }
        newmis.owner = self;
        newmis.touch = SUB_Null;
        setorigin(newmis, self.origin + '0 0 16');
        makevectors(self.v_angle);
        newmis.velocity = normalize(v_forward) * 300 + '0 0 200';
        newmis.movetype = MOVETYPE_TOSS;
        newmis.solid = SOLID_TRIGGER;
        newmis.deadflag = DEAD_DYING;
        setsize(newmis, VEC_HULL_MIN, VEC_HULL_MAX);
        newmis.think = DroppedKeyThink;
        newmis.nextthink = time + 1.5;
    } else
        sprint(self, PRINT_HIGH, "You do not have a key\n");
};

float () DoorShouldOpen = {
    local entity ptr;
    local float plyrcount;
    local entity plyr1;
    local entity plyr2;

    if (coop != 2)
        return (1);

    plyr1 = world;
    plyr2 = world;

    plyrcount = 0;
    ptr = find(world, classname, "player");
    while (ptr != world) {
        if (!(ptr.tf_items & self.items) && (ptr.playerclass != 0.000)
            && (ptr.solid != 0.000) && (ptr.model != string_null)) {

            plyrcount = plyrcount + 1;
            if (plyrcount == 1)
                plyr1 = ptr;
            else if (plyrcount == 2)
                plyr2 = ptr;
        }
        ptr = find(ptr, classname, "player");
    }
    if (plyrcount != 0) {
        if (plyrcount == 1) {
            bprint(PRINT_HIGH, plyr1.netname, " needs");
        } else if (plyrcount == 2) {
            bprint(PRINT_HIGH, plyr1.netname, " and ", plyr2.netname,
                   " need");
        } else {
            bprint(PRINT_HIGH, "More players need");
        }
        bprint(PRINT_HIGH, " to unlock the ");
        if (self.items & IT_KEY1)
            bprint(PRINT_HIGH, "silver");
        else
            bprint(PRINT_HIGH, "gold");

        bprint(PRINT_HIGH, " door\n");
        return (0);
    }
    bprint(PRINT_HIGH, "The ");
    if (self.items & IT_KEY1)
        bprint(PRINT_HIGH, "silver");
    else
        bprint(PRINT_HIGH, "gold");

    bprint(PRINT_HIGH, " door has been unlocked\n");
    return (1);
};
