// COMBAT MEDIC FUNCTIONS
// ======================

// functions by order of appearance
void () CF_Medic_AuraToggle;

// initializes the medic healing aura
// called from weapons.qc:ImpulseCommands()
void () CF_Medic_AuraToggle = {
    if (!medicaura || self.playerclass != PC_MEDIC)
        return;

    if (self.aura_active) {
        self.aura_active = 0;
        sprint(self, PRINT_HIGH, "Healing aura turned off\n");
    }
    else {
        self.aura_active = 1;
        sprint(self, PRINT_HIGH, "Healing aura turned on\n");
    }
    Status_Refresh(self);
};

float (entity pe_target) CF_Medic_AuraHealPlayer = {
    local float f_healamount = 0;

    if (pe_target.health < pe_target.max_health) {
        f_healamount = min(PC_MEDIC_AURA_HEAL_AMOUNT, (pe_target.max_health - pe_target.health));
        pe_target.health = pe_target.health + f_healamount;
    }

    return f_healamount;
};

// heals the team players around the medic every second
// called from tfort.qc:TeamFortress_SetEquipment()
void () CF_Medic_AuraFindPlayers = {
    local float f_healamount = 0;
    local float f_healtotal = 0;
    local float f_healcount = 0;
    local entity e_find;

    self.nextthink = time + PC_MEDIC_AURA_HEAL_TIME;

    if (!self.owner.aura_active || self.owner.ammo_cells < ceil(PC_MEDIC_MAXAMMO_CELL / 2))
        return;

    e_find = findradius(self.owner.origin, PC_MEDIC_AURA_RANGE);
    while (e_find != world) {
        if (e_find != self.owner && e_find.classname == "player" && e_find.team_no == self.owner.team_no) {
            f_healamount = CF_Medic_AuraHealPlayer(e_find);
            f_healtotal = f_healtotal + f_healamount;
            if (f_healamount)
                f_healcount = f_healcount + 1;
        }
        e_find = e_find.chain;
    }

    if (f_healtotal) {
        FO_Sound(self.owner, CHAN_ITEM, "items/r_item2.wav", 1, 1);
        if (time < self.owner.aura_healtime)
            self.owner.aura_healamount = self.owner.aura_healamount + f_healtotal;
        else
            self.owner.aura_healamount = f_healtotal;
        self.owner.aura_healtime = time + 3;
        self.owner.aura_healcount = f_healcount;
        self.owner.ammo_cells = self.owner.ammo_cells - f_healtotal;
        Status_Refresh(self.owner);
    } else if (time >= self.owner.aura_healtime && self.owner.aura_healcount) {
        self.owner.aura_healcount = 0;
        self.owner.aura_healamount = 0;
        self.owner.aura_healtime = 0;
    }

    self.owner.ammo_cells = self.owner.ammo_cells - ceil(PC_MEDIC_MAXAMMO_CELL / 20);
    if (self.owner.current_weapon == WEAP_MEDIKIT && !old_medikit)
        self.owner.currentammo = self.owner.ammo_cells;
};

// increases the medic's cells two times per second
// called from tfort.qc:TeamFortress_SetEquipment()
void () CF_Medic_RegenerateCells = {
    local entity oldself;
    local float f_newcells = self.owner.ammo_cells + min(ceil(PC_MEDIC_MAXAMMO_CELL * (PC_MEDIC_CELL_REGEN_PERCENT / 100)), ceil(PC_MEDIC_MAXAMMO_CELL - self.owner.ammo_cells));

    // don't regenerate cells if not using aura or new medikit
    if (!medicaura && old_medikit)
        return;

    // skip this regen tick if on cooldown
    if (time <= self.owner.regen_cooldown) {
        self.nextthink = time + 1;
        return;
    }

    self.nextthink = time + PC_MEDIC_CELL_REGEN_TIME;

    if (self.owner.ammo_cells < PC_MEDIC_MAXAMMO_CELL) {
        self.owner.ammo_cells = f_newcells;

        // refresh status bar if cells just hit max
        if (f_newcells >= PC_MEDIC_MAXAMMO_CELL)
            Status_Refresh(self.owner);
        else if (f_newcells >= ceil(PC_MEDIC_MAXAMMO_CELL / 2) && f_newcells < ceil(PC_MEDIC_MAXAMMO_CELL / 2 + PC_MEDIC_MAXAMMO_CELL / 10))
            Status_Refresh(self.owner);

        if (self.owner.current_weapon == WEAP_MEDIKIT && !old_medikit)
            self.owner.currentammo = self.owner.ammo_cells;
    }

    // Update drop ammo menu if cells are
    if ((self.owner.menu_input == Menu_Drop_Input) && (self.owner.ammo_cells >= DROP_CELLS)) {
        oldself = self;
        self = self.owner;
        Menu_Drop();
        self = oldself;
    }
};

// regenerates the medic's health
// called from tfort.qc:TeamFortress_SetEquipment()
void () CF_Medic_Regenerate = {
    self.nextthink = time + PC_MEDIC_REGEN_TIME;

    if (self.owner.has_disconnected == 1) {
        dremove(self);
        return;
    }

    // only regen if half of max or more cells with new medikit
    if (!old_medikit) {
        if (self.owner.health >= self.owner.max_health || self.owner.ammo_cells < ceil(PC_MEDIC_MAXAMMO_CELL / 2)) {
            return;
        }
    } else if (self.owner.health >= self.owner.max_health || self.owner.ammo_medikit) {
        return;
    }

    if (self.owner.ammo_medikit < PC_MEDIC_REGEN_AMOUNT) {
        self.owner.health = self.owner.health + self.owner.ammo_medikit;
        self.owner.ammo_medikit = 0;
    } else {
        self.owner.health = self.owner.health + PC_MEDIC_REGEN_AMOUNT;
        self.owner.ammo_medikit = self.owner.ammo_medikit - PC_MEDIC_REGEN_AMOUNT;
    }
    if (self.owner.health > self.owner.max_health)
        self.owner.health = self.owner.max_health;
}

void () BioInfection_Decay = {
    local entity te;
    local entity Bio;

    if ((teamplay & TFSTATE_INFECTED) && self.owner.team_no == self.enemy.team_no && self.owner.team_no) {
        self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_INFECTED);
        dremove(self);
        return;
    } else if (self.invincible_finished > time) {
        self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_INFECTED);
        dremove(self);
        return;
    }

    // stop infection timer if no longer infected or if medic
    if (!(self.owner.tfstate & TFSTATE_INFECTED) || self.owner.playerclass == PC_MEDIC) {
        dremove(self);
        return;
    }

    // poison teammates that come too close
    te = findradius(self.owner.origin, 80);
    while (te != world && te != self.owner) {
        if (te.classname == "player" && te.deadflag == 0 && te.playerclass) {
            if (!(te.tfstate & TFSTATE_INFECTED)) {
                if (te.playerclass != PC_MEDIC) {
                    if (!((teamplay & TEAMPLAY_NOEXPLOSIVE) && self.owner.team_no == self.enemy.team_no && self.owner.team_no)) {
                        Bio = spawn();
                        Bio.nextthink = 2;
                        Bio.think = BioInfection_Decay;
                        Bio.owner = te;
                        Bio.classname = "timer";
                        Bio.enemy = self.enemy;

                        te.tfstate = te.tfstate | TFSTATE_INFECTED;
                        te.infection_team_no = self.owner.infection_team_no;
                        LogEventAffliction(self.enemy, te, TFSTATE_INFECTED);
                        LogEventAffliction(self.owner, te, TFSTATE_INFECTED);
                        sprint(te, PRINT_MEDIUM, "You have been infected by ", self.owner.netname, "\n");
                        sprint(self.owner, PRINT_MEDIUM, "You have infected ", te.netname, "\n");
                    }
                }
            }
        }
        te = te.chain;
    }
    if (old_biodamage)
        self.nextthink = time + 3;
    else
        self.nextthink = time + 1;
    deathmsg = DMSG_BIOWEAPON;
    TF_T_Damage(self.owner, self, self.enemy, 8, TF_TD_IGNOREARMOR, TF_TD_OTHER);
    SpawnBlood(self.owner.origin, 30);
};

void () BioInfection_MonsterDecay = {
    self.nextthink = time + 2;

    T_Damage(self.enemy, self, self.owner, 5);
    SpawnBlood(self.enemy.origin, 20);

    if (self.enemy.health < 1)
        dremove(self);
};
