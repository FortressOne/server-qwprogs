//======================================================
// This file handles all menu functions and displays.
//======================================================

void (entity pe_player, float pf_class, float is_user) CF_Spy_ChangeSkin;
void (entity pe_player, float pf_team_no, float is_user) CF_Spy_ChangeColor;
void (float issilent, float force) FO_Spy_Feign;
void () FO_Spy_FeignOnNextDamage;
void () FO_Spy_Unfeign;
void () CF_Spy_Invisible;
void () CF_Spy_DisguiseStop;

float (float pf_team_no, float pf_class) CF_GetClassRestriction;
float (float pf_team_no, float pf_class) CF_GetClassPlayers;
float (float pf_team_no, float pf_class) CF_ClassIsRestricted;

void (entity spy) Spy_RemoveDisguise;

void (entity eng, string bld) DestroyBuilding;

void (float objtobuild, float offset) TeamFortress_Build;

void () lvl1_sentry_stand;
void () lvl2_sentry_stand;
void () lvl3_sentry_stand;

float (float tno) TeamFortress_TeamSet;
float (float tno) TeamFortress_TeamGetColor;
float () TeamFortress_TeamPutPlayerInTeam;
float (float tno) TeamFortress_TeamIsCivilian;
float (float tno) TeamFortress_TeamGetNoPlayers;
float () TeamFortress_GetNoPlayers;

float (float pc) IsLegalClass;
void (float inp) TeamFortress_ChangeClass;
void (entity p) TeamFortress_SetSkin;

void (float timer) TeamFortress_SetDetpack;
void (float timer) TeamFortress_ToggleDetpack;
void () TeamFortress_DetpackStop;

void (float type, float amount) TeamFortress_DropAmmo;
void (entity disp) Engineer_Dispenser_InsertAmmo;
void (entity disp) Engineer_Dispenser_InsertArmor;
void (entity disp) Engineer_Dispenser_Repair;
void (entity disp) Engineer_SentryGun_InsertAmmo;
void (entity disp) Engineer_SentryGun_Upgrade;
void (entity disp) Engineer_SentryGun_Repair;
void () Menu_Engineer_Cancel;
void () TeamFortress_EngineerBuildStop;

void (entity targ, entity inflictor, entity attacker, float damage,
      float T_flags, float T_AttackType) TF_T_Damage;

void (entity p) bound_other_ammo;
float (float v) anglemod;

void (float tno, entity ignore, string st) teamsprint;

void (float update) Menu_Team;
void (float update) Menu_Class;
string (float pc, float tno) TeamFortress_ClassGetNoPlayersString;
void () Menu_Drop;
void () PlayerObserverMode;
void () Menu_Scout;
void (entity pe_player) Menu_Spy;
void () Menu_Spy_Skin;
void () Menu_Spy_Color;

void (float inp) Menu_Scout_Input;
void (float inp) Menu_Spy_Input;
void (float inp) Menu_Spy_Skin_Input;
void (float inp) Menu_Spy_Color_Input;
void (entity player, float is_user) FO_Spy_DisguiseLast;
void (entity player, float is_user) FO_Spy_DisguiseLastSpawned;

void () Menu_Demoman;
void () Menu_Demoman_Cancel;

void (float inp) Menu_Demoman_Input;
void (float inp) Menu_Demoman_Cancel_Input;

void (entity player) Menu_Engineer;
void () Menu_Engineer_Update;
void () Menu_EngineerFix_Dispenser;
void () Menu_EngineerFix_SentryGun;

void (float inp) Menu_Engineer_Input;
void (float inp) Menu_EngineerFix_Dispenser_Input;
void (float inp) Menu_EngineerFix_SentryGun_Input;

void () Menu_Dispenser;
void (float inp) Menu_Dispenser_Input;

void () Menu_Admin;
void (float inp) Menu_Admin_Input;
void () Admin_DoKick;
void () Admin_ForceSpectator;

void () Admin_Pause;
void () Admin_CeaseFire;
void () Broadcast_Players_NotReady;
void () StartTimer;
void () ForceStartMatch;
void (float inp) SetQuadRounds;

float (string ps_short, string ps_setting, string ps_default) CF_GetSetting;

void (entity pl) UpdateClientMenu_Team;
void (entity pl, float team) UpdateClientClasses;
void (entity pl) UpdateClientMenu_Class;
void (entity pl) UpdateClientMenu_DropAmmo;
void (entity pl) UpdateClientMenu_Scout;
void (entity pl) UpdateClientMenu_Spy;
void (entity pl) UpdateClientMenu_Spy_Skin;
void (entity pl) UpdateClientMenu_Spy_Team;
void (entity pl, float cancel_detpack) UpdateClientMenu_Detpack;
void (entity pl) UpdateClientMenu_Build;
void (entity pl) UpdateClientMenu_FixSentry;
void (entity pl) UpdateClientMenu_FixDispenser;
void (entity pl, entity disp) UpdateClientMenu_UseDispenser;
void (entity pl) UpdateClientMenu_Admin;

void (entity pl) Menu_Close =
{
    pl.menu_input = nil;
    Status_Print(pl, "");    
};

string (string text, float maxlength) Menu_Indent_line = 
{
    local float spaces; 
    local float i;
    
    spaces = maxlength - (strlen(text));
    for (i = 0; i < spaces; i = i + 1)
    {
      text = strcat(text," ");
    }
    text = strcat(text,"\n");
    return text;
}

void (float inp) Menu_Input =
{
    var f_void_float tmp; tmp = self.menu_input;
    self.menu_input = nil;
    self.impulse = 0;
    if(tmp)
        tmp(inp);
    Status_Print(self, "");
};

void (float inp) Menu_Team_Input = {
    if (self.classname == "observer")
        return;

    if (inp == 0) {
        return;
    }

    if (inp == 5) {
        TeamFortress_TeamPutPlayerInTeam();
    } else if ((inp <= number_of_teams) && (inp > 0)) {
        TeamFortress_TeamSet(inp);
    } else if ((number_of_teams == 0) && (inp <= 4)) {
        TeamFortress_TeamSet(inp);
    } else {
        Menu_Team(0);
        return;
    }

    if ((self.playerclass == 0) && (self.lives != 0)) {
        Menu_Class(0);
    }
};

void () Menu_Team_Update = {
    if (self.owner.menu_input == Menu_Team_Input) {
        self.nextthink = time + 0.5;
        self = self.owner;
        Menu_Team(1);
    } else {
        self.owner.has_menutimer = 0;
        dremove(self);
    }
};

string (float pf_team_no, string ps_team) Menu_Team_TeamString = {
    local string s_string = "";
    local float f_gap = 2;
    local float f_players = TeamFortress_TeamGetNoPlayers(pf_team_no);

    if (number_of_teams >= pf_team_no) {
        s_string = strpadl(ftos(f_players), f_gap);
        if (f_players < 10) {
            s_string = strpadl(s_string, (1 + f_gap));
            if (f_players == 1)
                s_string = strcat(s_string, " player \n");
            else
                s_string = strcat(s_string, " players\n");
        } else
            s_string = strcat(s_string, " players\n");
        s_string = strcat(ps_team, s_string);
    }

    return strzone(s_string);
};

void (float inp) Menu_No_Input = {
    return;
}

void () Menu_Login = {
    local string st1, st2, st3;

    sprint (self, 2, "Login required, please use \"cmd login <login> <secret>\" before joining the game\n");
    st1 = "Login required, please use\n\s\"cmd login <login> <secret>\"\s \nbefore joining the game\n";
    st2 =  "If you don't have an account, visit\n\s";
    st3 = webpageUrl;
    st3 = strcat(st3, "\s\n");
    st2 = strcat(st2, st3);
    st1 = strcat(st1, st2);
    Status_Menu(self, Menu_No_Input, st1);
    return;
}

void (float update) Menu_Team = {
    local entity timer;

    if (self.classname == "observer")
        /* Status_Menu(self, Menu_Team_Input, ""); */
        return;

    //If there's only one team, just join it
    if (number_of_teams == 1 && self.team_no == 0) {
        Menu_Close(self);
        TeamFortress_TeamSet(1);
        if ((self.playerclass == 0) && (self.lives != 0)) {
            Menu_Class(0);
        }
        return;
    }
    
    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_Team(self);
        return;
    }
    
    // allow toggling team menu using any method to show it
    if (!update && self.menu_input == Menu_Team_Input) {
        Menu_Input(0);
        return;
    }

    if ((toggleflags & TFLAG_AUTOTEAM) && teamplay) {
        if (TeamFortress_TeamPutPlayerInTeam())
            return;
    }

    // prepare team strings
    local string s_select = "Select team:\n\n";
    local string s_blue   = Q"\s[1]\s Blue team  ";
    local string s_red    = Q"\s[2]\s Red team   ";
    local string s_yellow = Q"\s[3]\s Yellow team";
    local string s_green  = Q"\s[4]\s Green team ";
    local string s_auto   = Q"\s[5]\s Auto-assign team";

    // put together team strings
    s_blue = Menu_Team_TeamString(1, s_blue);
    s_red = Menu_Team_TeamString(2, s_red);
    s_yellow = Menu_Team_TeamString(3, s_yellow);
    s_green = Menu_Team_TeamString(4, s_green);
    s_auto = strpadr(s_auto, (strlen(s_blue) - 1));

    // don't show auto team if already assigned a team
    if (self.team_no)
        s_auto = "";

    // update menu every 0.5 seconds
    if (!self.has_menutimer) {
        self.has_menutimer = 1;
        timer = spawn();
        timer.classname = "menu_timer";
        timer.owner = self;
        timer.think = Menu_Team_Update;
        timer.nextthink = time + 0.5;
    }

    Status_Menu(self, Menu_Team_Input, s_select, s_blue, s_red, s_yellow, s_green, "\n", s_auto);

    strunzone(s_blue); strunzone(s_red); strunzone(s_yellow); strunzone(s_green);
};

void (float inp) Menu_Class_Input = {
    if (!inp)
        return;
    override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
    // keep showing menu if class is invalid
    if (inp > 10 || (!IsLegalClass(inp) && !override_mapclasses) || CF_ClassIsRestricted(self.team_no, inp))
        Menu_Class(0);

    // don't try to change class if class is forbidden
    if ((!IsLegalClass(inp) && !override_mapclasses) || CF_GetClassRestriction(self.team_no, inp) == -1)
        return;

    // close menu if selected class is current class
    if (self.playerclass == inp || (inp == 10 && (self.tfstate & TFSTATE_RANDOMPC)))
        Menu_Close(self);

    TeamFortress_ChangeClass(inp);
};

void () Menu_Class_Update = {
    if (self.owner.menu_input == Menu_Class_Input) {
        self.nextthink = time + 0.5;
        self = self.owner;
        Menu_Class(1);
    } else {
        self.owner.has_menutimer = 0;
        dremove(self);
    }
};

string (float pf_class, string ps_class) Menu_Class_ClassString = {
    local string s_string;
    local float f_gap = 5;
    local float f_max = CF_GetClassRestriction(self.team_no, pf_class);
    local float f_players = CF_GetClassPlayers(self.team_no, pf_class);

    override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
    if ((IsLegalClass(pf_class) || override_mapclasses) && f_max >= 0) {
        if (f_players < 10)
            s_string = strpadl(ftos(f_players), (1 + f_gap));
        else
            s_string = strpadl(ftos(f_players), f_gap);
        s_string = strcat(s_string, " / ");
        if (f_max < 10 && TeamFortress_TeamGetNoPlayers(self.team_no) >= 10)
            s_string = strpadr(s_string, (5 + f_gap));
        s_string = strcat(s_string, ftos(f_max));
        s_string = strcat(s_string, "\n");
        s_string = strcat(ps_class, s_string);
    } else {
        if (TeamFortress_TeamGetNoPlayers(self.team_no) >= 10)
            s_string = strpadr(ps_class, (12 + f_gap - 3));
        else
            s_string = strpadr(ps_class, (12 + f_gap - 3));
        s_string = strcat(s_string, "disabled\n");
    }

    return strzone(s_string);
};

void (float update) Menu_Class = {
    local entity timer;
    if (TeamFortress_TeamIsCivilian(self.team_no)) {
        sprint(self, PRINT_HIGH, "Your team can only be civilians\n");
        UpdateClientClasses(self, self.team_no);
        Menu_Close(self);
        return;
    }

    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own class menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientClasses(self, self.team_no);
        UpdateClientMenu_Class(self);
        return;
    }
    // allow toggling team menu using any method to show it
    if (!update && self.menu_input == Menu_Class_Input) {
        Menu_Input(0);
        return;
    }

    // print map specific class menu
    local entity e_info = find(world, classname, "info_tfdetect");
    if (e_info) {
        if (self.team_no == 1) {
            if (e_info.noise1 != string_null) {
                Status_Menu(self, Menu_Class_Input, e_info.noise1);
                return;
            }
        } else if (self.team_no == 2) {
            if (e_info.noise2 != string_null) {
                Status_Menu(self, Menu_Class_Input, e_info.noise2);
                return;
            }
        } else if (self.team_no == 3) {
            if (e_info.noise3 != string_null) {
                Status_Menu(self, Menu_Class_Input, e_info.noise3);
                return;
            }
        } else if (self.team_no == 4) {
            if (e_info.noise4 != string_null) {
                Status_Menu(self, Menu_Class_Input, e_info.noise4);
                return;
            }
        }
    }

    // prepare class strings
    local string s_select   = "Select class:\n\n";
    local string s_scout    = Q"\s[1]\s Scout   ";
    local string s_sniper   = Q"\s[2]\s Sniper  ";
    local string s_soldier  = Q"\s[3]\s Soldier ";
    local string s_demoman  = Q"\s[4]\s Demoman ";
    local string s_medic    = Q"\s[5]\s Medic   ";
    local string s_hwguy    = Q"\s[6]\s HWGuy   ";
    local string s_pyro     = Q"\s[7]\s Pyro    ";
    local string s_spy      = Q"\s[8]\s Spy     ";
    local string s_engineer = Q"\s[9]\s Engineer";
    local string s_randompc = Q"\s[0]\s RandomPC";

    // put together class strings - all strings are strzoned
    s_scout = Menu_Class_ClassString(PC_SCOUT, s_scout);
    s_sniper = Menu_Class_ClassString(PC_SNIPER, s_sniper);
    s_soldier = Menu_Class_ClassString(PC_SOLDIER, s_soldier);
    s_demoman = Menu_Class_ClassString(PC_DEMOMAN, s_demoman);
    s_medic = Menu_Class_ClassString(PC_MEDIC, s_medic);
    s_hwguy = Menu_Class_ClassString(PC_HVYWEAP, s_hwguy);
    s_pyro = Menu_Class_ClassString(PC_PYRO, s_pyro);
    s_spy = Menu_Class_ClassString(PC_SPY, s_spy);
    s_engineer = Menu_Class_ClassString(PC_ENGINEER, s_engineer);
    s_randompc = Menu_Class_ClassString(PC_RANDOM, s_randompc);

    // update menu every 0.5 seconds
    if (!self.has_menutimer) {
        self.has_menutimer = 1;
        timer = spawn();
        timer.classname = "menu_timer";
        timer.owner = self;
        timer.think = Menu_Class_Update;
        timer.nextthink = time + 0.5;
    }

    // print out class menu
    self.menu_input = nil;
//    if (TeamFortress_TeamIsCivilian(self.team_no))
//        Status_Print(self, "Your team can only be civilians\n");
//    else
        Status_Menu(self, Menu_Class_Input, s_select, s_scout, s_sniper, s_soldier, s_demoman, s_medic, s_hwguy, s_pyro, s_spy, s_engineer, s_randompc);

    strunzone(s_scout); strunzone(s_sniper); strunzone(s_soldier); strunzone(s_demoman); strunzone(s_medic);
    strunzone(s_hwguy); strunzone(s_pyro); strunzone(s_spy); strunzone(s_engineer); strunzone(s_randompc);
};

void (float inp) Menu_Drop_Input = {
    if ((inp > 0) && (inp < 5)) {
        TeamFortress_DropAmmo(inp, 0);
        Menu_Drop();
    }
};

void () Menu_Drop = {
    local string s_drop;
    local string s_shells  = Q"\s[1]\s Shells        \n";
    local string s_nails   = Q"\s[2]\s Nails         \n";
    local string s_rockets = Q"\s[3]\s Rockets       \n";
    local string s_cells   = Q"\s[4]\s Cells         \n";
    local string s_nothing = Q"\n\s[5]\s Nothing       ";

    if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells)) {
        sprint(self, PRINT_HIGH, "Not enough ammo\n");
        return;
    }

    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it

        Menu_Close(self);
        UpdateClientMenu_DropAmmo(self);
        return;
    }
    
    if (self.ammo_shells < DROP_SHELLS)
        s_shells  = "\n";
    if (self.ammo_nails < DROP_NAILS)
        s_nails   = "\n";
    if (self.ammo_rockets < DROP_ROCKETS)
        s_rockets = "\n";
    if (self.ammo_cells < DROP_CELLS)
        s_cells   = "\n";

    if (self.playerclass == PC_ENGINEER) {
        if ((self.ammo_shells < DROP_SHELLS) && ((self.ammo_cells / AMMO_COST_SHELLS) > (DROP_SHELLS - self.ammo_shells)))
            s_shells  = Q"\s[1]\s Shells (make) \n";
        if ((self.ammo_nails < DROP_NAILS) && ((self.ammo_cells / AMMO_COST_NAILS) > (DROP_NAILS - self.ammo_nails)))
            s_nails  = Q"\s[2]\s Nails (make)  \n";
        if ((self.ammo_rockets < DROP_ROCKETS) && ((self.ammo_cells / AMMO_COST_ROCKETS) > (DROP_ROCKETS - self.ammo_rockets)))
            s_rockets  = Q"\s[3]\s Rockets (make)\n";
        if (self.ammo_cells < DROP_CELLS)
            s_cells   = "\n";
    }

    if (s_shells == "\n" && s_nails == "\n" && s_rockets == "\n" && s_cells == "\n")
        return;



    self.menu_input = nil;
    if (self.playerclass == PC_ENGINEER)
        s_drop = "Drop or make:\n\n";
    else
        s_drop = "Drop:\n\n";
    Status_Menu(self, Menu_Drop_Input, s_drop, s_shells, s_nails, s_rockets, s_cells, s_nothing);
};

void (float inp) Menu_Scout_Input = {
    if (inp == 1)
        self.impulse = TF_SCAN;
    else if (inp == 2)
        self.impulse = TF_SCAN_ENEMY;
    else if (inp == 3)
        self.impulse = TF_SCAN_FRIENDLY;
    else if (inp == 4)
        self.impulse = TF_SCAN_SOUND;
    else
        self.impulse = 0;
};

void () Menu_Scout = {
    local string s_action  = "Scanner settings:\n\n";
    local string s_scan, s_scane, s_scanf, s_scansound;
    local string s_nothing = Q"\n\s[5]\s Nothing                   \n\n";

    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_Scout(self);
        return;
    }
    
    if (!self.ScannerOn)
        s_scan = Q"\s[1]\s Turn Scanner on           \n";
    else
        s_scan = Q"\s[1]\s Turn Scanner off          \n";

    if (self.tf_items_flags & NIT_SCANNER_ENEMY)
        s_scane = Q"\s[2]\s Do not scan for enemies   \n";
    else
        s_scane = Q"\s[2]\s Scan for enemies          \n";


    if (self.tf_items_flags & NIT_SCANNER_FRIENDLY)
        s_scanf = Q"\s[3]\s Do not scan for friendlies\n";
    else
        s_scanf = Q"\s[3]\s Scan for friendlies       \n";

    if (self.tf_items_flags & 4)
        s_scansound = Q"\s[4]\s Turn off scan sound       \n";
    else
        s_scansound = Q"\s[4]\s Turn on scan sound        \n";

    Status_Menu(self, Menu_Scout_Input, s_action, s_scan, s_scane, s_scanf, s_scansound, s_nothing);
};

void (float inp) Menu_Spy_Input = {
    if ((inp == 1) || (inp == 2)) {
        if (self.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT)) {
            sprint(self, PRINT_HIGH, "You cannot go undercover while glowing\n");
            return;
        }
        if (self.is_unabletospy) {
            sprint(self, PRINT_HIGH, "You cannot go undercover right now\n");
            return;
        }
    }
    if (inp == 1) {
        if (invis_only)
            CF_Spy_Invisible();
        else if (self.is_undercover == 2)
            CF_Spy_DisguiseStop();
        else
            Menu_Spy_Skin();
    } else if (inp == 2 && !invis_only) {
        FO_Spy_DisguiseLast(self, TRUE);
    } else if (inp == 3) {
        FO_Spy_Feign(1, 0);
        if (IsFeigned(self)) {
            Menu_Spy(self);
        }
    } else if (inp == 4) {
        Spy_RemoveDisguise(self);
    }
};

void (entity pe_player) Menu_Spy = {
    local string s_action  = "Action:\n\n";
    local string s_skin    = Q"\s[1]\s Disguise               \n";
    local string s_last    = Q"\s[2]\s Last disguise          \n";
    local string s_feign, s_reset;
    local string s_nothing = Q"\n\s[5]\s Nothing                ";

    if (pe_player.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT) || pe_player.is_unabletospy == 1) {
        return;
    }
    if(infokeyf(pe_player, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(pe_player);
        UpdateClientMenu_Spy(pe_player);
        return;
    }

    if (invis_only) {
        if (pe_player.is_undercover == 1)
            s_skin    = Q"\s[1]\s Become visible         \n";
        else if (pe_player.is_undercover == 2)
            s_skin    = Q"\s[1]\s Stop going invisible   \n";
        else
            s_skin    = Q"\s[1]\s Go invisible           \n";
    } else if (pe_player.is_undercover == 2)
        s_skin    = Q"\s[1]\s Stop disguising        \n";

    if ((!pe_player.last_selected_skin && !pe_player.last_team) || invis_only)
        s_last = "\n";

    if (IsFeigned(pe_player))
        s_feign = Q"\s[3]\s Stop feigning          \n";
    else
        s_feign = Q"\s[3]\s Start feigning (silent)\n";

    if (pe_player.undercover_team && pe_player.undercover_skin)
        s_reset = Q"\s[4]\s Reset disguise         \n";
    else if (pe_player.undercover_team)
        s_reset = Q"\s[4]\s Reset color            \n";
    else if (pe_player.undercover_skin)
        s_reset = Q"\s[4]\s Reset skin             \n";
    else
        s_reset = "\n";

    Status_Menu(pe_player, Menu_Spy_Input, s_action, s_skin, s_last, s_feign, s_reset, s_nothing);
};

void (float inp) Menu_Spy_Skin_Input = {
    if (inp == 10)
        return;

    if (self.effects & (EF_DIMLIGHT | EF_BRIGHTLIGHT)) {
        sprint(self, PRINT_MEDIUM, "You cannot disguise while glowing\n");
        return;
    }

    if (self.is_unabletospy) {
        sprint(self, PRINT_HIGH, "You cannot go undercover right now\n");
        return;
    }

    if(infokeyf(self, "smt")) {
        Menu_Spy_Color();
    } else {
        if (number_of_teams == 1)
            sprint(self, PRINT_HIGH, "There is no other team\n");
        else if (number_of_teams > 2)
            Menu_Spy_Color();
        else if (self.team_no == 1)
            CF_Spy_ChangeColor(self, 2, TRUE);
        else
            CF_Spy_ChangeColor(self, 1, TRUE);
    }

    if (self.skin != inp)
        CF_Spy_ChangeSkin(self, inp, TRUE);
};

void () Menu_Spy_Skin = {
    if (self.is_unabletospy == 1)
        return;

    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_Spy_Skin(self);
        return;
    }

    local string s_disguise = "Disguise as enemy:\n\n";
    local string s_scout    = Q"\s[1]\s Scout      \n";
    local string s_sniper   = Q"\s[2]\s Sniper     \n";
    local string s_soldier  = Q"\s[3]\s Soldier    \n";
    local string s_demoman  = Q"\s[4]\s Demoman    \n";
    local string s_medic    = Q"\s[5]\s Medic      \n";
    local string s_hwguy    = Q"\s[6]\s HWGuy      \n";
    local string s_pyro     = Q"\s[7]\s Pyro       \n";
    local string s_spy      = Q"\s[8]\s Spy        \n";
    local string s_engineer = Q"\s[9]\s Engineer   \n";
    local string s_nothing  = Q"\n\s[0]\s Nothing    \n";

    Status_Menu(self, Menu_Spy_Skin_Input, s_disguise, s_scout, s_sniper, s_soldier, s_demoman, s_medic, s_hwguy, s_pyro, s_spy, s_engineer, s_nothing);
};

void (float inp) Menu_Spy_Color_Input = {
    local float color = stof(infokey(self, "bottomcolor"));

    if (inp == 1 && color == 13)
        Menu_Spy_Color();
    else if (inp == 2 && color == 4)
        Menu_Spy_Color();
    else if (inp == 3 && color == 12)
        Menu_Spy_Color();
    else if (inp == 4 && color == 11)
        Menu_Spy_Color();
    else if (inp > 0 && inp <= number_of_teams)
        CF_Spy_ChangeColor(self, inp, TRUE);
};

void () Menu_Spy_Color = {
    local float color       = stof(infokey(self, "bottomcolor"));
    local string s_disguise = "Disguise as:\n\n";
    local string s_blue     = Q"\s[1]\s Blue team  \n";
    local string s_red      = Q"\s[2]\s Red team   \n";
    local string s_yellow   = Q"\s[3]\s Yellow team\n";
    local string s_green    = Q"\s[4]\s Green team \n";
    local string s_nothing  = Q"\n\s[5]\s Nothing    ";

    if (number_of_teams == 0) {
        sprint(self, PRINT_HIGH, "No color changing allowed in deathmatch\n");
        return;
    }
    
    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_Spy_Team(self);
        return;
    }

    // don't display your own team
    if (color == 13)
        s_blue = "\n";
    else if (color == 4)
        s_red = "\n";
    else if (color == 12)
        s_yellow = "\n";
    else if (color == 11)
        s_green = "\n";

    self.menu_input = nil;
    if (number_of_teams == 1)
        sprint(self, PRINT_HIGH, "There is no other team\n");
    else if (number_of_teams == 2)
        Status_Menu(self, Menu_Spy_Color_Input, s_disguise, s_blue, s_red, s_nothing, "\n\n");
    else if (number_of_teams == 3)
        Status_Menu(self, Menu_Spy_Color_Input, s_disguise, s_blue, s_red, s_yellow, s_nothing, "\n");
    else
        Status_Menu(self, Menu_Spy_Color_Input, s_disguise, s_blue, s_red, s_yellow, s_green, s_nothing);
};

void (float inp) Menu_Demoman_Input = {
    if (inp == 1)
        TeamFortress_SetDetpack(5);
    else if (inp == 2)
        TeamFortress_SetDetpack(20);
    else if (inp == 3)
        TeamFortress_SetDetpack(50);
    else if (inp == 4)
        TeamFortress_SetDetpack(255);
};

void () Menu_Demoman = {
    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_Detpack(self, FALSE);
        return;
    }
    
    local string s_detpack = "Set detpack for:\n\n";
    local string s_5       = Q"\s[1]\s 5 seconds  \n";
    local string s_20      = Q"\s[2]\s 20 seconds \n";
    local string s_50      = Q"\s[3]\s 50 seconds \n";
    local string s_255     = Q"\s[4]\s 255 seconds\n";
    local string s_nothing = Q"\n\s[5]\s Nothing    ";

    Status_Menu(self, Menu_Demoman_Input, s_detpack, s_5, s_20, s_50, s_255, s_nothing);
}

void (float inp) Menu_Demoman_Cancel_Input = {
    if (inp == 1)
        TeamFortress_DetpackStop();
    else
        Menu_Demoman_Cancel();
}

void () Menu_Demoman_Cancel = {
    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_Detpack(self, TRUE);
        return;
    }
    local string s_detpack = "Setting detpack...\n\n";
    local string s_cancel  = Q"\s[1]\s Cancel!\n\n\n\n\n";

    Status_Menu(self, Menu_Demoman_Cancel_Input, s_detpack, s_cancel);
}

void (float offset) TeamFortress_BuildSentry = {
    if (self.has_sentry) return;

    if (self.ammo_cells >= ENG_SENTRY_COST)
        TeamFortress_Build(BUILD_SENTRYGUN, offset);
    else
        Status_Print(self, "\n\n\n\n\n\n\n", strcat("You need ", ftos(ENG_SENTRY_COST - self.ammo_cells), " more cells to build a sentry gun"));
}

void (float inp) Menu_Engineer_Input = {
    switch (inp) {
        case 5:
            break;

        // build sentry
        case 1:
            TeamFortress_BuildSentry(0);
            break;

        // build dispenser
        case 2:
            if (!self.has_dispenser) {
                if (self.ammo_cells >= ENG_DISPENSER_COST)
                    TeamFortress_Build(BUILD_DISPENSER, 0);
                else
                    Status_Print(self, "\n\n\n\n\n\n\n", strcat("You need ", ftos(ENG_DISPENSER_COST), " cells to build a dispenser"));
            }
            break;

        // dismantle or destroy sentry
        case 3:
            if (self.has_sentry) {
                local float dismantle_sentrygun = 0;
                local entity te = findradius(self.origin, ENG_BUILDING_DISMANTLE_DISTANCE);
                while (te) {
                    if (te.classname == "building_sentrygun" && te.real_owner == self) {
                        if (te.weapon == 0) {
                            sprint(self, PRINT_HIGH, strcat("You stopped building a sentry gun and got ", ftos(ENG_SENTRY_COST), " cells back\n"));
                            self.ammo_cells += ENG_SENTRY_COST;
                            if (self.ammo_cells > self.maxammo_cells)
                                self.ammo_cells = self.maxammo_cells;
                            if (te.trigger_field != world)
                                dremove(te.trigger_field);
                            self = te.real_owner;
                            TeamFortress_EngineerBuildStop();
                        } else {
                            sprint(self, PRINT_HIGH, "You dismantled the sentry gun and got 65 cells\n");
                            self.ammo_cells += 65;
                            dremove(te.trigger_field);
                            dremove(te);
                            self.has_sentry = 0;
                            dismantle_sentrygun = 1;
                        }
                    }
                    te = te.chain;
                }
                if (dismantle_sentrygun == 0)
                    DestroyBuilding(self, "building_sentrygun");
            }
            break;

        // dismantle or destroy dispenser
        case 4:
            if (self.has_dispenser) {
                local float dismantle_dispenser = 0;
                local entity te = findradius(self.origin, ENG_BUILDING_DISMANTLE_DISTANCE);
                while (te) {
                    if (te.classname == "building_dispenser" && te.real_owner == self) {
                        sprint(self, PRINT_HIGH, "You dismantled the dispenser and got 50 cells\n");
                        self.ammo_cells += 50;
                        dremove(te);
                        self.has_dispenser = 0;
                        dismantle_dispenser = 1;
                    }
                    te = te.chain;
                }
                if (dismantle_dispenser == 0)
                    DestroyBuilding(self, "building_dispenser");
            }
            break;
    }
};

void (entity player) Menu_Engineer = {
    local entity te, dist_checker;
    local string s_action  = "Action:\n\n";
    local string s_sentry  = "\n";
    local string s_disp    = "\n";
    local string s_dsentry = "\n";
    local string s_ddisp   = "\n";
    local string s_nothing = Q"\n\s[5]\s Nothing             ";

    if(infokeyf(player, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(player);
        UpdateClientMenu_Build(player);
        return;
    }

    if (player.has_sentry) {
        s_sentry = "\n";
        s_dsentry = Q"\s[3]\s Destroy sentry gun  \n";
        te = findradius(player.origin, 100);
        while (te) {
            if (te.classname == "building_sentrygun") {
                if (te.real_owner == player)
                    s_dsentry = Q"\s[3]\s Dismantle sentry gun\n";
            }
            te = te.chain;
        }
    } else if (player.ammo_cells >= 130) {
        s_sentry = Q"\s[1]\s Build sentry gun    \n";
    }

    if (player.has_dispenser) {
        s_ddisp = Q"\s[4]\s Destroy dispenser   \n";
        te = findradius(player.origin, 100);
        while (te) {
            if (te.classname == "building_dispenser") {
                if (te.real_owner == player)
                    s_ddisp = Q"\s[4]\s Dismantle dispenser \n";
            }
            te = te.chain;
        }
    } else if (player.ammo_cells >= 100) {
        s_disp = Q"\s[2]\s Build dispenser     \n";
    }

    if ((player.has_dispenser || player.has_sentry) && !player.has_menutimer) {
        player.has_menutimer = 1;
        dist_checker = spawn();
        dist_checker.classname = "menu_timer";
        dist_checker.owner = player;
        dist_checker.think = Menu_Engineer_Update;
        dist_checker.nextthink = time + 0.3;
    }

    Status_Menu(player, Menu_Engineer_Input, s_action, s_sentry, s_disp, s_dsentry, s_ddisp, s_nothing);
};

void () Menu_Engineer_Update = {
    if (self.owner.menu_input == Menu_Engineer_Input) {
        Menu_Engineer(self.owner);
        self.nextthink = time + 0.3;
    } else {
        self.owner.has_menutimer = 0;
        dremove(self);
    }
};

void (float inp) Menu_EngineerFix_Dispenser_Input = {
    if (self.classname != "player" || self.building == world)
        return;

    if (inp == 1) {
        Engineer_Dispenser_InsertAmmo(self.building);
    } else if (inp == 2) {
        Engineer_Dispenser_InsertArmor(self.building);
    } else if (inp == 3 && old_spanner) {
        Engineer_Dispenser_Repair(self.building);
    }

    self.building = world;
};

void () Menu_EngineerFix_Dispenser = {
    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_FixDispenser(self);
        return;
    }

    local string s_action = "Dispenser maintenance:\n\n";
    local string s_ammo, s_armor, s_repair;
    local string s_nothing = Q"\n\s[5]\s Nothing     \n\n";

    if ((self.ammo_shells > 0 && self.building.ammo_shells < 400)
            || (self.ammo_nails > 0 && self.building.ammo_nails < 600)
            || (self.ammo_rockets > 0 && self.building.ammo_rockets < 300)
            || (self.ammo_cells > 0 && self.building.ammo_cells < 400))
        s_ammo = Q"\s[1]\s Insert ammo \n";
    else
        s_ammo = "\n";

    if (self.armorvalue > 0 && self.building.armorvalue < 500)
        s_armor = Q"\s[2]\s Insert armor\n";
    else
        s_armor = "\n";

    if (old_spanner && self.building.health < self.building.max_health)
        s_repair = Q"\s[3]\s Repair      \n";
    else
        s_repair = "\n";

    Status_Menu(self, Menu_EngineerFix_Dispenser_Input, s_action, s_ammo, s_armor, s_repair, s_nothing);
};

void (float inp) Menu_EngineerFix_SentryGun_Rotate_Input = {
    if (inp == 1) {
        sprint(self, PRINT_HIGH, "Rotating 45 degrees anticlockwise...\n");
        self.building.waitmin = anglemod(self.building.waitmin + 45);
        self.building.waitmax = anglemod(self.building.waitmax + 45);
    } else if (inp == 2) {
        sprint(self, PRINT_HIGH, "Rotating 180 degrees...\n");
        self.building.waitmin = anglemod(self.building.waitmin + 180);
        self.building.waitmax = anglemod(self.building.waitmax + 180);
    } else if (inp == 3) {
        sprint(self, PRINT_HIGH, "Rotating 45 degrees clockwise...\n");
        self.building.waitmin = anglemod(self.building.waitmin - 45);
        self.building.waitmax = anglemod(self.building.waitmax - 45);
    }
};

void () Menu_EngineerFix_SentryGun_Rotate = {
    local string action  = "Rotate sentry gun:\n\n";
    local string rotl    = Q"\s[1]\s anticlockwise\n";
    local string rot180  = Q"\s[2]\s 180 degrees  \n";
    local string rotr    = Q"\s[3]\s clockwise    \n";
    local string nothing = Q"\n\s[5]\s Nothing      \n";


    if (!self.building.real_owner.has_sentry || self.building.real_owner != self
            || self.classname != "player" || self.building == world) {
        return;
    }

    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_FixSentry(self);
        return;
    }

    Status_Menu(self, Menu_EngineerFix_SentryGun_Rotate_Input, action, rotl, rot180, rotr, nothing);
};

void (float inp) Menu_EngineerFix_SentryGun_Input = {
    if (!self.building.real_owner.has_sentry || self.building.real_owner != self
            || self.classname != "player" || self.building == world)
        return;

    if (inp == 1) {
        Engineer_SentryGun_InsertAmmo(self.building);
    } else if (inp == 2 && self.building.weapon < 3 && self.ammo_cells >= 130) {
        Engineer_SentryGun_Upgrade(self.building);
    } else if (inp == 3) {
        Engineer_SentryGun_Repair(self.building);
    } else if (inp == 4) {
        Menu_EngineerFix_SentryGun_Rotate();
    }
};

void () Menu_EngineerFix_SentryGun = {

    // only show this menu if old_spanner setting is enabled, otherwise show rotate menu
    if (!old_spanner) {
        Menu_EngineerFix_SentryGun_Rotate();
        return;
    }

    local string action  = "Sentry gun maintenance:\n\n";
    local string putammo, upgrade, repair, rotate;
    local string nothing = Q"\n\s[5]\s Nothing    ";

    if ((self.ammo_shells > 0 && self.building.ammo_shells < self.building.maxammo_shells)
            || (self.ammo_rockets > 0 && self.building.weapon == 3 && self.building.ammo_rockets < self.building.maxammo_rockets))
        putammo = Q"\s[1]\s Insert ammo\n";
    else
        putammo = "\n";

    if (self.building.weapon < 3 && self.ammo_cells >= 130)
        upgrade = Q"\s[2]\s Upgrade    \n";
    else
        upgrade = "\n";

    if (self.building.health < self.building.max_health)
        repair = Q"\s[3]\s Repair     \n";
    else
        repair = "\n";

    if (self.building.real_owner == self)
        rotate  = Q"\s[4]\s Rotate     \n";
    else
        rotate = "\n";

    Status_Menu(self, Menu_EngineerFix_SentryGun_Input, action, putammo, upgrade, repair, rotate, nothing);
};

void (float inp) Menu_Dispenser_Input = {
    local float am;
    local float empty;

    empty = FALSE;
    if (inp == 1) {
        if ((self.building.ammo_shells == 0)
                && (self.building.ammo_nails == 0)
                && (self.building.ammo_rockets == 0)
                && (self.building.ammo_cells == 0)) {
            empty = TRUE;
        } else {
            am = self.maxammo_shells - self.ammo_shells;
            if (am > self.building.ammo_shells)
                am = self.building.ammo_shells;
            self.building.ammo_shells = self.building.ammo_shells - am;
            self.ammo_shells = self.ammo_shells + am;

            am = self.maxammo_nails - self.ammo_nails;
            if (am > self.building.ammo_nails)
                am = self.building.ammo_nails;
            self.building.ammo_nails = self.building.ammo_nails - am;
            self.ammo_nails = self.ammo_nails + am;

            am = self.maxammo_rockets - self.ammo_rockets;
            if (am > self.building.ammo_rockets)
                am = self.building.ammo_rockets;
            self.building.ammo_rockets = self.building.ammo_rockets - am;
            self.ammo_rockets = self.ammo_rockets + am;

            am = self.maxammo_cells - self.ammo_cells;
            if (am > self.building.ammo_cells)
                am = self.building.ammo_cells;
            self.building.ammo_cells = self.building.ammo_cells - am;
            self.ammo_cells = self.ammo_cells + am;
        }
    } else if (inp == 2) {
        if (self.building.armorvalue == 0) {
            empty = TRUE;
        } else {
            am = self.maxarmor - self.armorvalue;
            if (am > self.building.armorvalue)
                am = self.building.armorvalue;

            if (self.armortype == 0) {
                self.armortype = 0.3;
                self.items = self.items | IT_ARMOR1;
            }
            self.building.armorvalue = self.building.armorvalue - am;
            self.armorvalue = self.armorvalue + am;
        }
    }
    if ((inp >= 1) && (inp <= 3)) {
        if (empty)
            sprint(self, PRINT_HIGH, "The dispenser is empty\n");

        self.building = world;
        self.building_wait = time + 0.5;

        bound_other_ammo(self);
        if (self.armorvalue == 0) {
            self.armortype = 0;
            self.armorclass = 0;
            self.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
        }
    }
};

void () Menu_Dispenser = {
    local string s_action  = "Use dispenser:\n\n";
    local string s_ammo, s_armor;
    local string s_nothing = Q"\n\s[5]\s Nothing            \n\n";

    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_UseDispenser(self, self.building);
        return;
    }

    if ((self.building.ammo_shells > 0 && self.ammo_shells < self.maxammo_shells)
            || (self.building.ammo_nails > 0 && self.ammo_nails < self.maxammo_nails)
            || (self.building.ammo_rockets > 0 && self.ammo_rockets < self.maxammo_rockets)
            || (self.building.ammo_cells > 0 && self.ammo_cells < self.maxammo_cells))
        s_ammo = Q"\s[1]\s Withdraw some ammo \n";
    else
        s_ammo = "\n";

    if (self.building.armorvalue > 0 && self.armorvalue < self.maxarmor)
        s_armor = Q"\s[2]\s Withdraw some armor\n";
    else
        s_armor = "\n";

    Status_Menu(self, Menu_Dispenser_Input, s_action, s_ammo, s_armor, s_nothing);
};

void (float inp) Menu_Engineer_Cancel_Input = {
    if (inp == 1)
        TeamFortress_EngineerBuildStop();
    else
        Menu_Engineer_Cancel();
}

void () Menu_Engineer_Cancel = {
    if(infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_Build(self);
        return;
    }
    local string s_build = "Building...\n\n";
    local string s_cancel  = Q"\s[1]\s Cancel!\n\n\n\n\n";

    Status_Menu(self, Menu_Engineer_Cancel_Input, s_build, s_cancel);
}

void () ClanMode;
void () QuadMode;
void () PubMode;
void () DuelMode;
void () RestartMap;
void () Admin_UpdateServer;
void () Menu_Admin =
{
    if(self.is_admin && infokeyf(self, INFOKEY_P_CSQCACTIVE)) {
        //fte+csqc has its own team menu
        //ask the client to activate it
        Menu_Close(self);
        UpdateClientMenu_Admin(self);
        return;
    }
    local string s_menu1;
    local string s_menu2;
    local string override;
    local string blanks = "                   ";

    /* More menu lines, commented for the sake of unecessary warnings
     * local string s_menu3;
     * local string s_menu4;
     * local string s_menu5;
     * local string s_menu6;
     */ 
    local string s_menu7;
    local string s_menu8;
    local string s_menu9;  

    local entity te;
    local entity temp;

    local float f_tmp;
    local float f_tmp2;

    self.impulse = 0;
    s_menu1 = "";
    s_menu2 = "";

    switch (self.current_menu_type)
    {
        case ADMIN_MENU_TYPE_MAIN:
            s_menu1 =         "FortressOne Admin Menu:                \n\n";
            if (self.current_menu_page == 1) {
                s_menu1 = strcat(s_menu1, Q"\s[1]\s Ceasefire                    \n");
                override = strcat("\x10",ftos(timelimit/60),"\x11");
                override = strcat(substring(blanks, 0, 19 - strlen(override)), override);
                s_menu1 = strcat(s_menu1, Q"\s[2]\s Timelimit ", override,      "\n");
                s_menu1 = strcat(s_menu1, Q"\s[3]\s Kick                         \n");
                s_menu1 = strcat(s_menu1, Q"\s[4]\s Ban                          \n");
                if(captainmode) {
                    override = " \x10on\x11";
                } else {
                    override = "\x10off\x11";
                }
                s_menu1 = strcat(s_menu1, Q"\s[5]\s Captain                 ",override,"\n");
                s_menu1 = strcat(s_menu1, Q"\s[6]\s Randomize Teams              \n");
                s_menu1 = strcat(s_menu1, Q"\s[7]\s Restart current map          \n");
            } else if (self.current_menu_page == 2) {
                if(clanbattle) {
                    override = " \x10on\x11";
                } else {
                    override = "\x10off\x11";
                }
                s_menu1 = strcat(s_menu1, Q"\s[1]\s Clan Mode               ",override,"\n");
                if(quadmode) {
                    override = " \x10on\x11";
                } else {
                    override = "\x10off\x11";
                }
                s_menu1 = strcat(s_menu1, Q"\s[2]\s Quad Mode               ",override,"\n");
                if(!clanbattle && !quadmode && !duelmode) {
                    override = " \x10on\x11";
                } else {
                    override = "\x10off\x11";
                }
                s_menu1 = strcat(s_menu1, Q"\s[3]\s Pub Mode                ",override,"\n");
                if(duelmode) {
                    override = " \x10on\x11";
                } else {
                    override = "\x10off\x11";
                }
                s_menu1 = strcat(s_menu1, Q"\s[4]\s Duel Mode               ",override,"\n");
                s_menu1 = strcat(s_menu1, Q"\s[5]\s Force Spectate               \n");
                s_menu1 = strcat(s_menu1, Q"\s[6]\s Ready Status                 \n");
                s_menu1 = strcat(s_menu1, Q"\s[7]\s Force Match Start (Be Nice)  \n");
            } else if (self.current_menu_page == 3) {
                s_menu1 = strcat(s_menu1, Q"\s[1]\s Class Settings               \n");
            }
            s_menu1 = strcat(s_menu1, "\n\n");
            s_menu1 = strcat(s_menu1, Q"\s[8]\s Previous Page                \n");
            s_menu1 = strcat(s_menu1, Q"\s[9]\s Next Page                    \n");
            s_menu1 = strcat(s_menu1, Q"\s[0]\s Exit Menu                    \n");

            Status_Menu(self, Menu_Admin_Input, s_menu1);
            break;
        case ADMIN_MENU_TYPE_QUADMODE:
            s_menu1 =                  "Quad Mode Admin Menu:                \n\n";

            s_menu1 = strcat(s_menu1, Q"\s[1]\s Rounds                   \n");
            s_menu1 = strcat(s_menu1, Q"\s[2]\s Round Timelimit          \n");
            s_menu1 = strcat(s_menu1, "\n\n");
            s_menu1 = strcat(s_menu1, Q"\s[0]\s Exit Menu                \n");

            Status_Menu(self, Menu_Admin_Input, s_menu1);
            break;
        case ADMIN_MENU_TYPE_QUAD_ROUNDNUM:
            s_menu1 = "Number of Rounds Input Menu:             \n\n";
            s_menu1 = strcat(s_menu1, "Enter a number between 1 and 10          \n");
            s_menu1 = strcat(s_menu1, "\n\n");

            Status_Menu(self, Menu_Admin_Input, s_menu1);
            break;
        case ADMIN_MENU_TYPE_QUAD_ROUNDTL:
            s_menu1 = "Round Time Input Menu:               \n\n";
            //s_menu1 = strcat(s_menu1, "Enter a number between 1 and 10      \n");
            //s_menu1 = strcat(s_menu1, "\n\n");

            s_menu1 = strcat(s_menu1, Q"\s[1]\s 1 minute                     \n");
            s_menu1 = strcat(s_menu1, Q"\s[2]\s 5 minutes                    \n");
            s_menu1 = strcat(s_menu1, Q"\s[3]\s 10 minutes                   \n");
            s_menu1 = strcat(s_menu1, Q"\s[4]\s 15 minutes                   \n");
            s_menu1 = strcat(s_menu1, Q"\s[5]\s 20 minutes                   \n");
            s_menu1 = strcat(s_menu1, Q"\s[6]\s 25 minutes                   \n");
            s_menu1 = strcat(s_menu1, Q"\s[7]\s 30 minutes                   \n");
            s_menu1 = strcat(s_menu1, Q"\s[8]\s 35 minutes                   \n");
            s_menu1 = strcat(s_menu1, Q"\s[9]\s 45 minutes                   \n");
            s_menu1 = strcat(s_menu1, Q"\s[0]\s 60 minutes                   \n");

            Status_Menu(self, Menu_Admin_Input, s_menu1);
            break;
        case ADMIN_MENU_TYPE_KICK:
            s_menu1 = "Admin Kick Menu:              \n\n";
            break;
        case ADMIN_MENU_TYPE_BAN:
            s_menu1 = "Admin Ban Menu:              \n\n";
            break;
        case ADMIN_MENU_TYPE_CAPTAINTEAMONE:
            s_menu1 = "Captain Team 1 Select Menu:              \n\n";
            break;
        case ADMIN_MENU_TYPE_CAPTAINTEAMTWO:
            s_menu1 = "Captain Team 2 Select Menu:              \n\n";
            break;
        case ADMIN_MENU_TYPE_CAPTAINSELECT:
            s_menu1 = strcat(Q"\x10\sCaptain\s\x11 Team ", ftos(self.team_no));
            s_menu1 = strcat(s_menu1, " :              \n\n");
            break;
        case ADMIN_MENU_TYPE_CLASSES:
            s_menu1 = "Class Management Menu:        \n\n";
            //override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
            if(override_mapclasses) {
                override = " \x10on\x11";
            } else {
                override = "\x10off\x11";
            }
            if (self.current_menu_page == 1) {
                s_menu1 = strcat(s_menu1, Q"\s[1]\s Override Map Settings   ", override, "\n");
                //s_menu1 = strcat(s_menu1, Q"\s[1]\s Override Map Settings        \n");
                //s_menu1 = strcat(s_menu1, Q"\s[2]\s Scout                        \n");
                //s_menu1 = strcat(s_menu1, Q"\s[3]\s Sniper                       \n");
                //s_menu1 = strcat(s_menu1, Q"\s[4]\s Soldier                      \n");
                //s_menu1 = strcat(s_menu1, Q"\s[5]\s Demoman                      \n");
                //s_menu1 = strcat(s_menu1, Q"\s[6]\s Medic                        \n");
                //s_menu1 = strcat(s_menu1, Q"\s[7]\s Heavy                        \n");
            } else if (self.current_menu_page == 2) {
                //s_menu1 = strcat(s_menu1, Q"\s[1]\s Pyro                         \n");
                //s_menu1 = strcat(s_menu1, Q"\s[2]\s Spy                          \n");
                //s_menu1 = strcat(s_menu1, Q"\s[3]\s Engineer                     \n");
                //s_menu1 = strcat(s_menu1, Q"\s[4]\s RandomPC                     \n");
                //s_menu1 = strcat(s_menu1, Q"\s[5]\s                              \n");
                //s_menu1 = strcat(s_menu1, Q"\s[6]\s                              \n");
                //s_menu1 = strcat(s_menu1, Q"\s[7]\s                              \n");
            }
            s_menu1 = strcat(s_menu1, "\n\n");
            s_menu1 = strcat(s_menu1, Q"\s[8]\s Previous Page                \n");
            s_menu1 = strcat(s_menu1, Q"\s[9]\s Next Page                    \n");
            s_menu1 = strcat(s_menu1, Q"\s[0]\s Exit Menu                    \n");

            Status_Menu(self, Menu_Admin_Input, s_menu1);
            break;
    }

    // jesus christ what is this, this should be separated out for the good of the people
    // or maybe made understandable
    if (self.current_menu_type == ADMIN_MENU_TYPE_KICK || self.current_menu_type == ADMIN_MENU_TYPE_BAN 
            || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMONE || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMTWO 
            || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINSELECT || self.current_menu_type == ADMIN_MENU_TYPE_FORCESPEC) 
    {
        f_tmp = 0;
        f_tmp2 = 0;
        s_menu2 = strcat (s_menu2, "\bPlayers:\b                      \n");
        s_menu2 = "\sPage\s ";
        s_menu2 = strcat (s_menu2, ftos(self.current_menu_page));
        s_menu2 = strcat (s_menu2, "\n");
        s_menu2 = Menu_Indent_line(s_menu2, 30);

        te = find (world, classname, "player");
        while (te != world) {
            if ( (f_tmp < (self.current_menu_page * 7) ) && ( f_tmp >= ((self.current_menu_page - 1) * 7) ) && ( ( ( self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINSELECT || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMTWO )  && !te.captain) || (self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINSELECT && self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINTEAMTWO) ) )  {
                f_tmp2 = f_tmp2 + 1;
                f_tmp = f_tmp + 1;
                s_menu2 = strcat( s_menu2, Q"\s[\s" );
                s_menu2 = strcat( s_menu2, ftos(f_tmp2));
                s_menu2 = strcat( s_menu2, Q"\s]\s " );              
                if (strlen(te.netname) <= 26) {
                    s_menu2 = strcat( s_menu2, te.netname );                    
                } 
                else {
                    s_menu2 = strcat( s_menu2, substring(te.netname,0,25));
                }
                s_menu2 = Menu_Indent_line(s_menu2, 30);
            }

            if (( f_tmp < (self.current_menu_page - 1) * 7) &&  ( ( ( self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINSELECT || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMTWO )  && !te.captain) || ( self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINSELECT && self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINTEAMTWO ) ) ) {
                f_tmp = f_tmp + 1;
            }

            te = find (te, classname, "player");
        }

        if (self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINTEAMONE && self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINTEAMTWO && self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINSELECT && self.current_menu_type != ADMIN_MENU_TYPE_FORCESPEC ) {
            te = find (world, classname, "observer");
            while (te != world) {
                if ( (f_tmp <= (self.current_menu_page * 7) ) && (f_tmp > (self.current_menu_page - 1) * 7) && te.netname != "")  {
                    f_tmp2 = f_tmp2 + 1;
                    s_menu2 = strcat( s_menu2, Q"\s[\s" );
                    s_menu2 = strcat( s_menu2, ftos(f_tmp2));
                    s_menu2 = strcat( s_menu2, Q"\s]\s " );
                    s_menu2 = strcat( s_menu2, te.netname );
                    if (strlen(te.netname) <= 26) {
                        s_menu2 = strcat( s_menu2, te.netname );                    
                    } 
                    else {
                        s_menu2 = strcat( s_menu2, substring(te.netname,0,25));
                    }
                    s_menu2 = Menu_Indent_line(s_menu2, 30);
                }
                f_tmp = f_tmp + 1;
                te = find (te, classname, "observer");
            }
        }

        if (f_tmp == 0 &&  ( self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINSELECT || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMTWO ) ) {
            bprint(2, "\x10\sCaptain Mode\s\x11\s:\s \sTeams are set,  let's start the game!\s\n");
            temp = self;
            te = find (world, classname, "player");
            while (te != world) {
                te.captain = 0;
                self = te;
                Menu_Close(self);
                self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
                self.current_menu_page = 1;
                te = find (te, classname, "player");
            }
            self = temp;
            captainmode = 0;
            return;
        }
        s_menu2 = strcat( s_menu2, "\n");
        s_menu7 = "\b[\b8\b]\b \bPrevious Page\b         ";
        s_menu7 = Menu_Indent_line(s_menu7, 30);
        s_menu8 = "\b[\b9\b]\b \bNext Page\b             ";
        s_menu8 = Menu_Indent_line(s_menu8, 30);
        if (self.is_admin || self.captain == 1) {
            s_menu9 = "\b[\b0\b]\b \bBack to Main Menu\b     ";
            s_menu9 = Menu_Indent_line(s_menu9, 30);
        } else {
            s_menu9 = "\n";
        }
        if ((self.is_admin || self.captain == 1) && captainmode) {
            s_menu9 = strcat(s_menu9, "Option 0 results in canceling captain mode.\n");
        }

        s_menu1 = strcat(s_menu1, s_menu2);
        s_menu1 = strcat(s_menu1, s_menu7);
        s_menu1 = strcat(s_menu1, s_menu8);
        s_menu1 = strcat(s_menu1, s_menu9);

        Status_Menu(self, Menu_Admin_Input, s_menu1);
    }
};

void (float inp) Menu_Admin_Input =
{
    local entity temp;
    local entity te;
    local string s_temp;
    local float f_tmp;

    // Actions for AdminMenu Page 0
    if (self.current_menu_type == ADMIN_MENU_TYPE_MAIN) {
        if (self.current_menu_page == 1)
        {
            switch (inp)
            {
                case 1: // Ceasefire
                    if (ceasefire_type) 
                        Admin_Pause();
                    else
                        Admin_CeaseFire();
                    return;
                case 2: // Change Timelimit
                    if (stof(infokey (world, "timelimit")) > 35) {
                        s_temp = "5";
                    } else {
                        s_temp = ftos(timelimit/60 + 5);
                    }

                    localcmd ("timelimit ");
                    localcmd(s_temp);
                    localcmd("\n");

                    bprint ( 2, self.netname);
                    bprint ( 2, " sets ");
                    bprint ( 2, "\stimelimit\s to: ");
                    bprint ( 2, s_temp);
                    bprint ( 2, "\n");
                    break;
                case 3: // Kick Player Menu
                    self.current_menu_type = ADMIN_MENU_TYPE_KICK;
                    self.current_menu_page = 1;
                    Menu_Admin();
                    break;
                case 4: // Ban Player Menu
                    self.current_menu_type = ADMIN_MENU_TYPE_BAN;
                    self.current_menu_page = 1;
                    Menu_Admin();
                    break;
                case 5: // Toggle Captain (pickup) Mode
                    if (!captainmode) {
                        captainmode = 1;
                        self.current_menu_type = ADMIN_MENU_TYPE_CAPTAINTEAMONE;
                        self.current_menu_page = 1;

                        bprint(2, "\x10\sCaptain Mode\s\x11\s:\s is now \sON\s.\n");
                        bprint(2, "\x10\sCaptain Mode\s\x11\s:\s ONLY CAPTAINS CAN TALK! YOU ARE ALL \sMUTED\s.\n");
                        bprint(2, "\x10\sCaptain Mode\s\x11\s:\s ONLY CAPTAINS CAN TALK! YOU ARE ALL \sMUTED\s.\n");
                        bprint(2, "\x10\sCaptain Mode\s\x11\s:\s ONLY CAPTAINS CAN TALK! YOU ARE ALL \sMUTED\s.\n");

                        temp = find (world, classname, "player");
                        while (temp != world) {
                            temp.captain = 0;
                            temp = find (temp, classname, "player");
                        }

                    } else {  // end captainmode1
                        disableCaptain();
                        local entity pl;
                        local entity temppl;
                        pl = self;
                        temppl = find (world, classname, "player");
                        while (temppl != world) {
                            self = temppl;
                            temppl.captain = 0;
                            Menu_Close(self);
                            self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
                            self.current_menu_page = 1;
                            temppl = find (temppl, classname, "player");
                        }
                        self = pl;
                    }
                    Menu_Admin();
                    break;
                case 6: // Randomize Teams Option
                    randomizeTeams();
                    break;

                case 7: // Restart Current Map Option
                    RestartMap();
                    break;
                case 9:
                    Admin_UpdateServer();
                    break;
            }
        } 
        else if (self.current_menu_page == 2) 
        {
            switch (inp)
            {
                case 1: // Toggle Clanmode Option
                    ClanMode();
                    Menu_Close(self);
                    self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
                    self.current_menu_page = 1;
                    break;
                case 2: // quad mode
                    QuadMode();
                    self.current_menu_type = ADMIN_MENU_TYPE_QUADMODE;
                    self.current_menu_page = 1;
                    Menu_Admin();
                    break;
                case 3: // pub mode
                    PubMode();
                    Menu_Close(self);
                    self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
                    self.current_menu_page = 1;
                    break;
                case 4: // duel mode
                    DuelMode();
                    Menu_Close(self);
                    self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
                    self.current_menu_page = 1;
                    break;
                case 5: // force spectator
                    self.current_menu_type = ADMIN_MENU_TYPE_FORCESPEC;
                    self.current_menu_page = 1;
                    Menu_Admin();
                    break;
                case 6: // ready status
                    Broadcast_Players_NotReady();
                    Menu_Close(self);
                    return;
                case 7: // force match start
                    ForceStartMatch();
                    Menu_Close(self);
                    return;
            }
        }
        else if (self.current_menu_page == 3) 
        {
            switch (inp)
            {
                case 1:
                    self.current_menu_type = ADMIN_MENU_TYPE_CLASSES;
                    self.current_menu_page = 1;
                    Menu_Admin();
                    return;
            }
        }
    } 
    else if ((self.current_menu_type == ADMIN_MENU_TYPE_KICK || self.current_menu_type == ADMIN_MENU_TYPE_BAN || self.current_menu_type == ADMIN_MENU_TYPE_FORCESPEC) 
            && inp >= 1 && inp <= 7) 
    { // Kick / Ban Actions
        //bprint(PRINT_HIGH, "Getting player ", ftos(inp), "\n");
        f_tmp = 1;    
        self.admin_use = find (world, classname, "player");
        while (self.admin_use != world)  {
            if (f_tmp < ((self.current_menu_page - 1) * 7) + inp ) {            
                f_tmp = f_tmp + 1;
                self.admin_use = find (self.admin_use, classname, "player");
            } else {
                break;
            }
        }
        if (f_tmp < ((self.current_menu_page - 1) * 7) + inp) {
            self.admin_use = find (world, classname, "observer");
            while (self.admin_use != world)  {
                if (f_tmp < ((self.current_menu_page - 1) * 7) + inp && self.admin_use.netname != "") {
                    f_tmp = f_tmp + 1;
                } else {
                    break;
                }
                self.admin_use = find (self.admin_use, classname, "observer");
            }
        }
        if (self.admin_use) {
            //bprint(PRINT_HIGH, "Player found: ", ftos(f_tmp), ", ", ftos(((self.current_menu_page - 1) * 7) + inp),", ", self.admin_use.classname , "\n");
            if (f_tmp == ((self.current_menu_page - 1) * 7) + inp) {
                if(self.current_menu_type == ADMIN_MENU_TYPE_FORCESPEC) {
                    Admin_ForceSpectator();
                    Menu_Close(self);
                } else {
                    self.admin_use.ip = infokey (self.admin_use, "ip");
                    if (self.current_menu_type == ADMIN_MENU_TYPE_BAN) {
                        localcmd("addip ");
                        localcmd(self.admin_use.ip);
                        localcmd("\n");
                    }
                    Admin_DoKick();
                }
            }
        }
    } 
    else if ((self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMONE 
                || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMTWO 
                || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINSELECT) && inp >= 1 && inp <= 7) 
    { // Captain Actions
        f_tmp = 1;
        self.admin_use = find (world, classname, "player");
        while (self.admin_use != world)  {
            if ( (f_tmp < ((self.current_menu_page - 1) * 7) + inp ) && ( ( (self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINSELECT || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMTWO) && !self.admin_use.captain) || (self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINSELECT && self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINTEAMTWO) ) ) {
                f_tmp = f_tmp + 1;
            } else if ( (f_tmp == ((self.current_menu_page - 1) * 7) + inp) && ( ( (self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINSELECT || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMTWO) && !self.admin_use.captain) || (self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINSELECT && self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINTEAMTWO) ) ) {
                break;
            }
            self.admin_use = find (self.admin_use, classname, "player");

        }

        if (self.current_menu_type != ADMIN_MENU_TYPE_CAPTAINSELECT) {
            if (self.admin_use != world) {
                if (f_tmp == ((self.current_menu_page - 1) * 7) + inp) {
                    temp = self;
                    self = self.admin_use;
                    self.captain = 9;
                    if (temp.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMONE) {
                        // Captain for Team 1
                        self.team_no = 1;
                        temp.current_menu_type = ADMIN_MENU_TYPE_CAPTAINTEAMTWO;
                        Menu_Admin();
                    } else if (temp.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMTWO) {
                        // Captain for Team 2
                        self.team_no = 2;

                        randomizeCaptains();

                        te = find (world, classname, "player");
                        while (te != world)
                        {
                            self = te;
                            if (!self.captain)
                            {
                                self.playerclass = 0;
                                playerSetTeam (-1);
                                self.current_menu = 0;
                                self.impulse = 0;
                            } else if (self.captain > 0 && self.captain < 5) {
                                //TeamFortress_TeamSet(self.team_no);
                                self.playerclass = 0;
                                playerSetTeam(self.team_no);
                                bprint(2, "\x10\sCaptain Mode\s\x11\s:\s ");
                                bprint(2, self.netname);
                                bprint(2, " \bIs the captain for team\b ");
                                bprint(2, TeamToString(self.team_no));
                                bprint(2, "\b.\b\n");
                            }
                            te = find (te, classname, "player");
                        }
                        self = temp;
                        bprint(2, "\x10\sCaptain Mode\s\x11\s:\s All available players are now Observers\n");
                        Menu_Close(self);
                        self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
                        self.current_menu_page = 1;
                    }
                    self = temp;
                }
            }
        } else {
            if (self.admin_use && f_tmp == ((self.current_menu_page - 1) * 7) + inp && self.captain == 1) {
                temp = self;
                self = self.admin_use;
                self.captain = 10;

                playerSetTeam (temp.team_no);

                bprint(2, "\x10\bCaptain Mode\b\x11\b:\b ");
                bprint(2, temp.netname);
                bprint(2, " \bcalled\b ");
                bprint(2, self.netname);
                bprint(2, " \bfor team\b ");
                bprint(2, TeamToString(self.team_no));
                bprint(2, "\b.\b\n");
                self = temp;

                nextCaptain();
                Menu_Close(self);
                self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
                self.current_menu_page = 1;
            }
        }
    } 
    else if (self.current_menu_type == ADMIN_MENU_TYPE_QUADMODE)
    {
        switch (inp)
        {
            case 1:
                // rounds
                self.current_menu_type = ADMIN_MENU_TYPE_QUAD_ROUNDNUM;
                self.current_menu_page = 1;
                Menu_Admin();
                break;
            case 2:
                // round time limit
                self.current_menu_type = ADMIN_MENU_TYPE_QUAD_ROUNDTL;
                self.current_menu_page = 1;
                Menu_Admin();
                break;
        }
    }
    else if (self.current_menu_type == ADMIN_MENU_TYPE_QUAD_ROUNDNUM)
    {
        SetQuadRounds(inp);
        self.current_menu_type = ADMIN_MENU_TYPE_QUADMODE;
        self.current_menu_page = 1;
        Menu_Admin();
    }
    else if (self.current_menu_type == ADMIN_MENU_TYPE_QUAD_ROUNDTL)
    {
        local string d;
        local float rt = (inp - 1) * 5;
        switch(inp) {
            case 1:
                rt = 1;
                break;
            case 9:
                rt = 45;
                break;
            case 10:
                rt = 60;
                break;
        }
        d = strcat("localinfo round_time ", ftos(rt), "\n");
        localcmd(d);
        bprint(2, "Quad Round Timelimit changed to ", ftos(rt), "\n");
        self.current_menu_type = ADMIN_MENU_TYPE_QUADMODE;
        self.current_menu_page = 1;
        Menu_Admin();
    }
    else if (self.current_menu_type == ADMIN_MENU_TYPE_CLASSES)
    {
        if (self.current_menu_page == 1)
        {
            override_mapclasses = CF_GetSetting("omc", "override_mapclasses", "off");
            switch (inp)
            {
                case 1: 
                    override_mapclasses = !override_mapclasses;
                    localcmd("serverinfo omc ");
                    localcmd(ftos(override_mapclasses));
                    localcmd("\n");
                    bprint(PRINT_HIGH, self.netname, " has set server class overrides to ", ftos(override_mapclasses), "\n");
                    Menu_Admin();
                    return;
            }
        }
    }

    //Previous page
    if (inp == 8) {
        if (self.current_menu_page > 1) {
            self.current_menu_page = self.current_menu_page - 1;
            Menu_Admin();
        }
    }
    //Next page
    if (inp == 9) {
        if (self.current_menu_page < 5) {
            self.current_menu_page = self.current_menu_page + 1;
            Menu_Admin();
        }
    }

    //Closes menus, disables captain mode
    if (inp == 10) {
        if (self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMTWO || self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINSELECT ||  self.current_menu_type == ADMIN_MENU_TYPE_CAPTAINTEAMONE) {
            captainmode = 0;
            bprint(2, "\x10\sCaptain Mode\s\x11\s:\s \scanceled by request of\s ");
            bprint(2, self.netname);
            bprint(2, ".\n");
            te = self;
            temp = find (world, classname, "player");
            while (temp != world) {
                self = temp;
                temp.captain = 0;
                Menu_Close(self);
                self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
                self.current_menu_page = 1;
                temp = find (temp, classname, "player");
            }
            self = te;
        }
        if (self.current_menu_type == ADMIN_MENU_TYPE_MAIN) {
            Menu_Close(self);
            self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
            self.current_menu_page = 1;
        }
        else if (self.is_admin) {
            self.current_menu_type = ADMIN_MENU_TYPE_MAIN;
            self.current_menu_page = 1;
            Menu_Admin();
        }
    }
    self.impulse = 0;
};
