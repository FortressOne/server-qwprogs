void (float force) FO_Menu_Build;
void (float force) FO_Menu_Admin_Main;
void (float force) FO_Menu_Admin_Modes;
void (float force) FO_Menu_Admin_Settings;
void (float force) FO_Menu_Admin_Rounds;
void (float force) FO_Menu_Admin_Timelimit;
void (float force) FO_Menu_Admin_Fraglimit;
void (float force) FO_Menu_Admin_QuadTimelimit;
void (float force) FO_Menu_Admin_FoMatchRated;
void (float force) FO_Menu_Admin_PlayToCompletion;
void (float force) FO_Menu_Admin_NewBalance;
void (float force) FO_Menu_Spy;
void (float force) FO_Menu_Spy_Skin;
void (float force) FO_Menu_Spy_Team;
void (float force) FO_Menu_Class;
void (float force) showVoteMenu;
void FO_Menu_Admin_Players(float force, float type, float page);
void FO_Hud_SetDisplay(PanelID id, float display);

typedef struct {
    string shortcut;    //key to press. if omitted - mouse only
    string name;        //what to display
    string value;       //optional - displays current value/state
    string description; //optional
    float state;        //active/disabled
    void() action;
    vector colour;

    PanelID id;  // Must be last member, automatically initialized.
} fo_menu_option;

typedef struct {
    vector position;
    vector size;
    string title;
    float flags;
    fo_menu_option options[FO_MENU_MAX_OPTIONS];
    float num_opts;
    float active;
    void() update;
    float page;
    string description;

    PanelID id;  // Must be after statically initialized members.
} fo_menu;

class fo_menu_option_2 {
    string shortcut;    //key to press. if omitted - mouse only
    string name;        //what to display
    string value;       //optional - displays current value/state
    string description; //optional
    float state;        //active/disabled
    virtual void() action = {};
    vector colour;
    fo_menu_option_2 next;
};

class fo_menu_2 {
    vector position;
    vector size;
    string title;
    float flags;
    fo_menu_option_2 options;
    float num_opts;
    float active;
    virtual void() update = {};
};

void FO_Menu_Team(float);
void Menu_Cancel() ;

fo_menu* InProgressMenu;
fo_menu* CurrentMenu;

fo_menu_option MenuSpacer = {"","","","",FO_MENU_STATE_SPACER};

var fo_menu FO_MENU_GAME = {
    [0,0], [300,200], "Fortress One", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","Select Team", "","Join a team",FO_MENU_STATE_NORMAL,{FO_Menu_Team(TRUE); },MENU_BUTTON},
        {"2","Select Class","","Each class has unique strenghts and weaknesses.",FO_MENU_STATE_NORMAL,{localcmd("changeclass\n"); Menu_Cancel(); },MENU_BUTTON},
        {"3","Ready","","Only applies to organised games",FO_MENU_STATE_NORMAL,{localcmd("ready\n"); Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"4","Spectate", "","Do not participate in the game, but observe as a ghost",FO_MENU_STATE_NORMAL,{localcmd("observe\n"); Menu_Cancel();},MENU_BUTTON},
        {"5","Server Admin", "","Admin options for the server",FO_MENU_STATE_DISABLED,{FO_Menu_Admin_Main(TRUE);},MENU_BUTTON},
        {"6","Captain's Menu", "","",FO_MENU_STATE_DISABLED,{FO_Menu_Admin_Players(TRUE, CLIENT_MENU_CAPTAIN_PICK, 0);},MENU_BUTTON},
        {"7","Map Menu", "","",FO_MENU_STATE_NORMAL,{showVoteMenu(TRUE);},MENU_BUTTON},
        MenuSpacer,
        {"0","Main Menu","","",FO_MENU_STATE_NORMAL,{localcmd("fo_main_menu\n"); Menu_Cancel();},MENU_BUTTON},
    }, 10, TRUE
};
var fo_menu FO_MENU_GAME_SPECTATOR = {
    [0,0], [300,200], "Fortress One", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","Join Game", "","",FO_MENU_STATE_NORMAL,{localcmd("join\n"); Menu_Cancel(); },MENU_BUTTON},
        MenuSpacer,
        {"3","Server Admin", "","",FO_MENU_STATE_DISABLED,{FO_Menu_Admin_Main(TRUE);},MENU_BUTTON},
        {"4","Map Menu", "","",FO_MENU_STATE_NORMAL,{showVoteMenu(TRUE);},MENU_BUTTON},
        MenuSpacer,
        {"0","Main Menu","","",FO_MENU_STATE_NORMAL,{localcmd("fo_main_menu\n"); Menu_Cancel();},MENU_BUTTON},
    }, 6, TRUE
};
var fo_menu FO_MENU_SPECTATOR_TRACK = {
    [0,0], [300,200], "Track", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Join Game", "","",FO_MENU_STATE_NORMAL,{localcmd("track 1\n"); },MENU_BUTTON},
    }, 0, TRUE
};

void teamChosen(string team) = {
    localcmd("cmd changeteam ", team, "\n");

    if(WP_PlayerClass()) {
        Menu_Cancel();
    } else {
        FO_Menu_Class(TRUE);
    }
};

var fo_menu FO_MENU_TEAM = {
    [0,0], [300,200], "Select Team", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Blue team","","Known for cunning and strategy, Blues like to attack first",FO_MENU_STATE_NORMAL,{teamChosen("1");},MENU_TEXT_BLUE_FO},
        {"2","Red team","","Excellent at standing their ground, Reds won't stand for being attacked",FO_MENU_STATE_NORMAL,{teamChosen("2");},MENU_TEXT_RED_FO},
        {"3","Yellow team","","The best team",FO_MENU_STATE_NORMAL,{teamChosen("3");},MENU_TEXT_YELLOW_FO},
        {"4","Green team","","Also okay",FO_MENU_STATE_NORMAL,{teamChosen("4");},MENU_TEXT_GREEN_FO},
        MenuSpacer,
        {"5","Auto-assign team","","",FO_MENU_STATE_NORMAL,{teamChosen("auto");},MENU_BUTTON},
        {"6","All time attack","","Always on the attacking team",FO_MENU_STATE_NORMAL,{teamChosen("attack");},MENU_BUTTON},
        {"7","All time defence","","Always on the defending team",FO_MENU_STATE_NORMAL,{teamChosen("defence");},MENU_BUTTON},
        MenuSpacer,
        {"0","Spectate","","",FO_MENU_STATE_NORMAL,{localcmd("observe\n");Menu_Cancel();},MENU_BUTTON},
    }, 10, TRUE, {
        if(intermission) {
            Menu_Cancel();
        }
    }
};
var fo_menu FO_MENU_CLASS = {
    [0,0], [300,200], "Select Class", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
        {"1","Scout","","Fastest but weakest. Has a scanner (menu) and a `dash` (special)",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 1\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Sniper","","Long charge times but powerful hits.",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 2\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Soldier","","All-rounder. Has a rocket launcher.",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 3\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Demoman","","Area-denial expert. 'special' to detonate pipebombs. 'menu' for detpack.",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 4\n");Menu_Cancel();},MENU_BUTTON},
        {"5","Medic","","Fast and immune to concussions and disease. \nBioweapon can heal/supercharge teammates and infect enemies\n'special' allows to automatically heal nearby teammates",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 5\n");Menu_Cancel();},MENU_BUTTON},
        {"6","Heavy Weapons","","Toughest of the classes. 'special' allows spinning the cannon without firing.",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 6\n");Menu_Cancel();},MENU_BUTTON},
        {"7","Pyro","","Can still pull off smaller rjs. ",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 7\n");Menu_Cancel();},MENU_BUTTON},
        {"8","Spy","","Can disguise as the enemy and feign death",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 8\n");Menu_Cancel();},MENU_BUTTON},
        {"9","Engineer","","Can build sentry guns and ammo dispensers. Also has powerful EMP grenades as secondaries",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 9\n");Menu_Cancel();},MENU_BUTTON},
        {"0","Random Playerclass","","Class will be randomly chosen upon each spawn.",FO_MENU_STATE_NORMAL,{localcmd("cmd changeclass 10\n");Menu_Cancel();},MENU_BUTTON},
    }, 10, TRUE, {
        if(intermission) {
            Menu_Cancel();
        }
    }
};
var fo_menu FO_MENU_DROPAMMO = {
    [0,0], [300,150], "Drop Ammo", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
        {"1","Shells","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dropammo 1\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Nails","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dropammo 2\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Rockets","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dropammo 3\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Cells","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dropammo 4\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 6, TRUE
};
var fo_menu FO_MENU_SCOUT = {
    [0,0], [300,150], "Scanner", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
        {"1","Scanner","","",FO_MENU_STATE_NORMAL,{localcmd("cmd autoscan\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Scan for enemies","","",FO_MENU_STATE_NORMAL,{localcmd("cmd scane\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Scan for friendlies","","",FO_MENU_STATE_NORMAL,{localcmd("cmd scanf\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Scan sound","","",FO_MENU_STATE_NORMAL,{localcmd("cmd scansound\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 6, TRUE
};
//var fo_menu_option FO_MENU_SPY;
var fo_menu FO_MENU_SPY = {
    [0,0], [300,150], "Spy", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
        {"1","Disguise","","",FO_MENU_STATE_NORMAL,{ FO_Menu_Spy_Skin(TRUE); localcmd("cmd disguise\n");},MENU_BUTTON},
        {"2","Last Disguise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise last\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Feign","","",FO_MENU_STATE_NORMAL,{localcmd("feign\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Reset Disguise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise none\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"0","Manual Colour Changes","","",FO_MENU_STATE_NORMAL,{
            local float smt = !stof(getplayerkeyvalue(player_localnum, "smt"));
            localcmd("setinfo smt ", ftos(smt), "\n");
        },MENU_BUTTON},
    }, 8, TRUE, {
        if(SBAR.InvisOnly) {
            FO_MENU_SPY.options[0].name = "Invisibility";
            FO_MENU_SPY.options[0].value = (SBAR.IsUndercover?"on":"off");
            FO_MENU_SPY.options[1].state = FO_MENU_STATE_DISABLED;
        } else {
            FO_MENU_SPY.options[0].name = "Disguise";
            FO_MENU_SPY.options[0].value = (SBAR.IsUndercover?"on":"off");
            if(last_selected_skin || last_team) {
                FO_MENU_SPY.options[1].state = FO_MENU_STATE_NORMAL;
                FO_MENU_SPY.options[1].value = strcat(TeamToString(last_team)," ",ClassToString(last_selected_skin));
            } else {
                FO_MENU_SPY.options[1].state = FO_MENU_STATE_DISABLED;
            }
            FO_MENU_SPY.options[3].state = (SBAR.IsUndercover?FO_MENU_STATE_NORMAL:FO_MENU_STATE_DISABLED);
        }
        FO_MENU_SPY.options[7].value = (stof(getplayerkeyvalue(player_localnum, "smt"))?"on":"off");
    }
};

void sendDisguiseCommand(float skinno) = {
    localcmd("cmd disguise skin ",ftos(skinno),"\n");
    local float smt = stof(getplayerkeyvalue(player_localnum, "smt"));
    if (smt) {
        FO_Menu_Spy_Team(TRUE);
    } else {
        Menu_Cancel();
    }
};

var fo_menu FO_MENU_SPY_SKIN = {
    [0,0], [300,200], "Disguise as enemy", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
        {"1","Scout","","",FO_MENU_STATE_NORMAL,{sendDisguiseCommand(1);},MENU_BUTTON},
        {"2","Sniper","","",FO_MENU_STATE_NORMAL,{sendDisguiseCommand(2);},MENU_BUTTON},
        {"3","Soldier","","",FO_MENU_STATE_NORMAL,{sendDisguiseCommand(3);},MENU_BUTTON},
        {"4","Demoman","","",FO_MENU_STATE_NORMAL,{sendDisguiseCommand(4);},MENU_BUTTON},
        {"5","Medic","","",FO_MENU_STATE_NORMAL,{sendDisguiseCommand(5);},MENU_BUTTON},
        {"6","Heavy Weapons","","",FO_MENU_STATE_NORMAL,{sendDisguiseCommand(6);},MENU_BUTTON},
        {"7","Pyro","","",FO_MENU_STATE_NORMAL,{sendDisguiseCommand(7);},MENU_BUTTON},
        {"8","Spy","","",FO_MENU_STATE_NORMAL,{sendDisguiseCommand(8);},MENU_BUTTON},
        {"9","Engineer","","",FO_MENU_STATE_NORMAL,{sendDisguiseCommand(9);},MENU_BUTTON},
        {"0","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
        {"-","Civilian","","",FO_MENU_STATE_NORMAL,{sendDisguiseCommand(11);},MENU_BUTTON},
    }, 11, TRUE
};
var fo_menu FO_MENU_SPY_TEAM = {
    [0,0], [300,200], "Disguise as", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Blue team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise team 1\n");Menu_Cancel();},'0.3 0.4 0.7'},
        {"2","Red team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise team 2\n");Menu_Cancel();},'0.7 0.4 0.3'},
        {"3","Yellow team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise team 3\n");Menu_Cancel();},'0.7 0.7 0.3'},
        {"4","Green team","","",FO_MENU_STATE_NORMAL,{localcmd("cmd disguise team 4\n");Menu_Cancel();},'0.4 0.7 0.3'},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 6, TRUE
};
var fo_menu FO_MENU_DETPACK = {
    [0,0], [300,200], "Set detpack for", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","5 Seconds","","",FO_MENU_STATE_NORMAL,{localcmd("cmd detpack 5\n");Menu_Cancel();},MENU_BUTTON},
        {"2","20 Seconds","","",FO_MENU_STATE_NORMAL,{localcmd("cmd detpack 20\n");Menu_Cancel();},MENU_BUTTON},
        {"3","50 Seconds","","",FO_MENU_STATE_NORMAL,{localcmd("cmd detpack 50\n");Menu_Cancel();},MENU_BUTTON},
        {"4","255 Seconds","","",FO_MENU_STATE_NORMAL,{localcmd("cmd detpack 255\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 6, TRUE
};
var fo_menu FO_MENU_DETPACK_CANCEL = {
    [0,0], [300,200], "Setting detpack...", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Cancel","","",FO_MENU_STATE_NORMAL,{localcmd("cmd detpack cancel\n");Menu_Cancel();},MENU_BUTTON},
    }, 1, TRUE, {
        if(!SBAR.IsDetpacking) {
            Menu_Cancel();
        }
    }
};
var fo_menu FO_MENU_BUILD_CANCEL = {
    [0,0], [300,200], "Building...", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Cancel","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build cancel\n");Menu_Cancel();},MENU_BUTTON},
    }, 1, TRUE, {
        if(!SBAR.IsBuilding) {
            Menu_Cancel();
        }
    }
};
var fo_menu FO_MENU_BUILD = {
    [0,0], [300,200], "Engineering", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Build Sentry Gun","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build sentry\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Build Dispenser","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build dispenser\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Destroy Sentry Gun","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build destroy sentry\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Dismantle Sentry Gun","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build destroy sentry\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Destroy Dispenser","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build destroy dispenser\n");Menu_Cancel();},MENU_BUTTON},
        {"4","Dismantle Dispenser","","",FO_MENU_STATE_NORMAL,{localcmd("cmd build destroy dispenser\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 8, TRUE, {
        if(SBAR.IsBuilding) {
            Menu_Cancel();
            //CurrentMenu = &FO_MENU_BUILD_CANCEL;
            FO_Menu_Build(FALSE);
            return;
        }
        if(SBAR.HasSentry) {
            FO_MENU_BUILD.options[0].state = FO_MENU_STATE_HIDDEN;  //Build
            if(vlen(PM_Org() - sentry_pos) <= ENG_BUILDING_DISMANTLE_DISTANCE) {
                FO_MENU_BUILD.options[2].state = FO_MENU_STATE_HIDDEN;  //Destroy
                FO_MENU_BUILD.options[3].state = FO_MENU_STATE_NORMAL;  //Dismantle
            } else {
                FO_MENU_BUILD.options[2].state = FO_MENU_STATE_NORMAL;  //Destroy
                FO_MENU_BUILD.options[3].state = FO_MENU_STATE_HIDDEN;  //Dismantle
            }
        } else {
            if(getstatf(STAT_CELLS) >= ENG_SENTRY_COST) {
                FO_MENU_BUILD.options[0].state = FO_MENU_STATE_NORMAL;
            } else {
                FO_MENU_BUILD.options[0].state = FO_MENU_STATE_DISABLED;
            }
            FO_MENU_BUILD.options[2].state = FO_MENU_STATE_HIDDEN;
            FO_MENU_BUILD.options[3].state = FO_MENU_STATE_HIDDEN;
        }
        if(SBAR.HasDispenser) {
            FO_MENU_BUILD.options[1].state = FO_MENU_STATE_HIDDEN;
            if(vlen(PM_Org() - dispenser_pos) <= ENG_BUILDING_DISMANTLE_DISTANCE) {
                FO_MENU_BUILD.options[4].state = FO_MENU_STATE_HIDDEN;
                FO_MENU_BUILD.options[5].state = FO_MENU_STATE_NORMAL;
            } else {
                FO_MENU_BUILD.options[4].state = FO_MENU_STATE_NORMAL;
                FO_MENU_BUILD.options[5].state = FO_MENU_STATE_HIDDEN;
            }
        } else {
            if(getstatf(STAT_CELLS) >= ENG_DISPENSER_COST) {
                FO_MENU_BUILD.options[1].state = FO_MENU_STATE_NORMAL;
            } else {
                FO_MENU_BUILD.options[1].state = FO_MENU_STATE_DISABLED;
            }
            FO_MENU_BUILD.options[4].state = FO_MENU_STATE_HIDDEN;
            FO_MENU_BUILD.options[5].state = FO_MENU_STATE_HIDDEN;
        }
    }
};
var fo_menu FO_MENU_SENTRY_MAINTAIN = {
    [0,0], [300,200], "Sentry Gun", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Anticlockwise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate 45\n");Menu_Cancel();},MENU_BUTTON},
        {"2","180 Degrees","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate 180\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Clockwise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate -45\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        /* {"4","With Mouse","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate mouse\n");Menu_Cancel();},MENU_BUTTON}, */
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 5, TRUE, {
        if(vlen(PM_Org() - sentry_pos) > ENG_BUILDING_MAINT_DISTANCE) {
            Menu_Cancel();
            return;
        }
    }
};

var fo_menu FO_MENU_SENTRY_ROTATE = {
    [0,0], [300,200], "Rotate Sentry Gun", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Anticlockwise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate 45\n");Menu_Cancel();},MENU_BUTTON},
        {"2","180 Degrees","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate 180\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Clockwise","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate -45\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        /* {"4","With Mouse","","",FO_MENU_STATE_NORMAL,{localcmd("cmd sentry rotate mouse\n");Menu_Cancel();},MENU_BUTTON}, */
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 5, TRUE, {
        if(vlen(PM_Org() - sentry_pos) > ENG_BUILDING_MAINT_DISTANCE) {
            Menu_Cancel();
            return;
        }
    }
};
var fo_menu FO_MENU_DISPENSER_MAINTAIN = {
    [0,0], [300,200], "Dispenser", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Insert Ammo","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dispenser ammo\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Insert Armor","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dispenser armor\n");Menu_Cancel();},MENU_BUTTON},
        {"3","Repair","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dispenser repair\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 5, TRUE, {
        if(vlen(PM_Org() - dispenser_pos) > ENG_BUILDING_MAINT_DISTANCE) {
            Menu_Cancel();
            return;
        }
    }
};
var fo_menu FO_MENU_DISPENSER_USE = {
    [0,0], [300,200], "Use Dispenser", FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS, {
        {"1","Withdraw Ammo","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dispenser withdraw ammo\n");Menu_Cancel();},MENU_BUTTON},
        {"2","Withdraw Armor","","",FO_MENU_STATE_NORMAL,{localcmd("cmd dispenser withdraw armor\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        {"5","Nothing","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 4, TRUE, {
        if(vlen(PM_Org() - touched_dispenser_pos) > ENG_BUILDING_MAINT_DISTANCE) {
            Menu_Cancel();
            return;
        }
    }
};

void updateAdminMenuInfo() = {
    if(admin_menu_next_update < time) {
        localcmd("cmd adminrefresh\n");
        admin_menu_next_update = time + CVARF(fo_adminrefresh);
    }
}

var fo_menu FO_MENU_ADMIN_MAIN = {
    [0,0], [300,300], "Server Admin [1/3]", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES | FO_MENU_FLAG_WARNING | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","Ceasefire","","Pause the game",FO_MENU_STATE_NORMAL,{localcmd("cmd ceasefire\n");},MENU_BORDER_WARNING},
        {"2","Kick...","","",FO_MENU_STATE_NORMAL,{FO_Menu_Admin_Players(TRUE, CLIENT_MENU_ADMIN_KICK, 0);},MENU_BORDER_WARNING},
        {"3","Ban...","","",FO_MENU_STATE_NORMAL,{FO_Menu_Admin_Players(TRUE, CLIENT_MENU_ADMIN_BAN, 0);},MENU_BORDER_WARNING},
        {"4","Force Spectate...","","Force someone to be a spectator",FO_MENU_STATE_NORMAL,{FO_Menu_Admin_Players(TRUE, CLIENT_MENU_ADMIN_FORCE_SPEC, 0);},MENU_BORDER_WARNING},
        {"5","Randomize Teams","","",FO_MENU_STATE_NORMAL,{localcmd("cmd randomise\n");},MENU_BORDER_WARNING},
        {"6","Restart Current Map","","",FO_MENU_STATE_NORMAL,{localcmd("cmd restart\n"); Menu_Cancel();},MENU_BORDER_WARNING},
        {"7","End Current Map","","",FO_MENU_STATE_NORMAL,{localcmd("cmd forcebreak\n"); Menu_Cancel();},MENU_BORDER_WARNING},
        {"8","Update Server","","",FO_MENU_STATE_NORMAL,{localcmd("cmd updateserver\n"); Menu_Cancel();},MENU_BORDER_WARNING},
        MenuSpacer,
        {"0","Close Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
        {"+","Next - Modes","","",FO_MENU_STATE_NORMAL,{Menu_Cancel(); FO_Menu_Admin_Modes(TRUE);},MENU_BUTTON},
        {"-","Prev - Settings","","",FO_MENU_STATE_NORMAL,{Menu_Cancel(); FO_Menu_Admin_Settings(TRUE);},MENU_BUTTON},
    }, 12, TRUE, {
        updateAdminMenuInfo();
        FO_MENU_ADMIN_MAIN.options[0].value = SERVER_ADMIN.ceasefire?"on":"off";
        FO_MENU_ADMIN_MAIN.options[5].value = mapname;
    }
};

//Basically bitfields - bit 1 is what the server is currently at, bit 2 what is requested
string (float m) modeStatus = {
    switch(m) {
        case 0:
            return "off";
        case 1:
            return "pending off";
        case 2:
            return "pending on";
        case 3:
            return "on";
    }
    return "";
}

string (float m) ratedStatus = {
    switch(m) {
        case 0:
            return "unrated";
        case 1:
            return "rated";
        case 2:
            return "default";
    }
    return "";
}

var fo_menu FO_MENU_ADMIN_MODES = {
    [0,0], [300,300], "Server Modes [2/3]", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES | FO_MENU_FLAG_WARNING | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","Pub Mode","","Public play, anything goes",FO_MENU_STATE_NORMAL,{localcmd("cmd pubmode\n");},MENU_BORDER_WARNING},
        {"2","Clan Mode","","Game has a prematch",FO_MENU_STATE_NORMAL,{localcmd("cmd clanmode\n");},MENU_BORDER_WARNING},
        {"3","Quad Mode","","Play for a set number of rounds, designed for attack vs defence",FO_MENU_STATE_NORMAL,{localcmd("cmd quadmode\n");},MENU_BORDER_WARNING},
        {"4","Duel Mode","","Simplifies 1 on 1 action",FO_MENU_STATE_NORMAL,{localcmd("cmd duelmode\n");},MENU_BORDER_WARNING},
        {"5","Captains Mode","","Select captains who can then pick their teams",FO_MENU_STATE_NORMAL,{FO_Menu_Admin_Players(TRUE, CLIENT_MENU_CAPTAIN_1, 0);},MENU_BORDER_WARNING},
        {"7","Rated/Unrated","","Will player ratings be affected?",FO_MENU_STATE_NORMAL,{FO_Menu_Admin_FoMatchRated(TRUE);},MENU_BORDER_WARNING},
        {"8","New Balance","","New Balance Test",FO_MENU_STATE_NORMAL,{localcmd("cmd new_balance");},MENU_BORDER_WARNING},
        {"9","Force Start","","Skip prematch and start the game\nPlease use sparingly",FO_MENU_STATE_NORMAL,{localcmd("cmd forcestart\n");},MENU_BORDER_WARNING},
        MenuSpacer,
        {"0","Close Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
        {"+","Next - Settings","","",FO_MENU_STATE_NORMAL,{Menu_Cancel(); FO_Menu_Admin_Settings(TRUE);},MENU_BUTTON},
        {"-","Prev - Main","","",FO_MENU_STATE_NORMAL,{Menu_Cancel(); FO_Menu_Admin_Main(TRUE);},MENU_BUTTON},
    }, 12, TRUE, {
        updateAdminMenuInfo();
        FO_MENU_ADMIN_MODES.options[0].value = modeStatus(SERVER_ADMIN.pubmode);
        FO_MENU_ADMIN_MODES.options[1].value = modeStatus(SERVER_ADMIN.clanmode);
        FO_MENU_ADMIN_MODES.options[2].value = modeStatus(SERVER_ADMIN.quadmode);
        FO_MENU_ADMIN_MODES.options[3].value = modeStatus(SERVER_ADMIN.duelmode);
        FO_MENU_ADMIN_MODES.options[4].value = SERVER_ADMIN.captainmode?"on":"off";
        FO_MENU_ADMIN_MODES.options[6].value = ratedStatus(SERVER_ADMIN.fo_matchrated);
        FO_MENU_ADMIN_MODES.options[6].value = modeStatus(SERVER_ADMIN.new_balance);
    }
};
var fo_menu FO_MENU_ADMIN_SETTINGS = {
    [0,0], [300,300], "Settings [3/3]", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES | FO_MENU_FLAG_WARNING | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","Timelimit","","",FO_MENU_STATE_NORMAL,{FO_Menu_Admin_Timelimit(TRUE);},MENU_BORDER_WARNING},
        {"2","Fraglimit","","",FO_MENU_STATE_NORMAL,{FO_Menu_Admin_Fraglimit(TRUE);},MENU_BORDER_WARNING},
        {"3","Quad Rounds...","","Number of rounds in Quad mode. Usually 2",FO_MENU_STATE_NORMAL,{FO_Menu_Admin_Rounds(TRUE);},MENU_BORDER_WARNING},
        {"4","Quad Round Time...","","Round time for each quad round",FO_MENU_STATE_NORMAL,{FO_Menu_Admin_QuadTimelimit(TRUE);},MENU_BORDER_WARNING},
        {"5","Play To Completion","","Play match to end of round even if result decided",FO_MENU_STATE_NORMAL,{FO_Menu_Admin_PlayToCompletion(TRUE);},MENU_BORDER_WARNING},
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        {"0","Close Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
        {"+","Next - Main","","",FO_MENU_STATE_NORMAL,{Menu_Cancel(); FO_Menu_Admin_Main(TRUE);},MENU_BUTTON},
        {"-","Prev - Modes","","",FO_MENU_STATE_NORMAL,{Menu_Cancel(); FO_Menu_Admin_Modes(TRUE);},MENU_BUTTON},
    }, 12, TRUE, {
        updateAdminMenuInfo();
        FO_MENU_ADMIN_SETTINGS.options[0].value = ftos(SERVER_ADMIN.timelimit);
        FO_MENU_ADMIN_SETTINGS.options[1].value = ftos(SERVER_ADMIN.fraglimit);
        FO_MENU_ADMIN_SETTINGS.options[2].value = ftos(SERVER_ADMIN.quad_rounds);
        FO_MENU_ADMIN_SETTINGS.options[3].value = ftos(SERVER_ADMIN.quad_round_time);
        FO_MENU_ADMIN_SETTINGS.options[4].value = modeStatus(SERVER_ADMIN.play_to_completion);
    }
};
var void execute_admin_players(float choice, float page) {
    print("not implemented ", ftos(choice + (page * 9)),"\n");
}
void execute_admin_players_unknown(float choice, float page) {
    print("not implemented ", ftos(choice + (page * 9)),"\n");
}
void execute_admin_players_kick(float choice, float page) {
    string userid = getplayerkeyvalue(choice + (page * 9), "userid");
    localcmd("cmd kick ", userid, "\n");
    Menu_Cancel();
    FO_Menu_Admin_Main(TRUE);
}
void execute_admin_players_ban(float choice, float page) {
    string userid = getplayerkeyvalue(choice + (page * 9), "userid");
    localcmd("cmd ban ", userid, "\n");
    Menu_Cancel();
    FO_Menu_Admin_Main(TRUE);
}
void execute_admin_players_force_spec(float choice, float page) {
    string userid = getplayerkeyvalue(choice + (page * 9), "userid");
    localcmd("cmd forcespec ", userid, "\n");
    Menu_Cancel();
    FO_Menu_Admin_Main(TRUE);
}
void execute_admin_players_captain1(float choice, float page) {
    string userid = getplayerkeyvalue(choice + (page * 9), "userid");
    captain1_temp = stof(userid);
    FO_Menu_Admin_Players(TRUE, CLIENT_MENU_CAPTAIN_2, 0);
}
void execute_admin_players_captain2(float choice, float page) {
    string userid = getplayerkeyvalue(choice + (page * 9), "userid");
    captain2_temp = stof(userid);
    //Send server cmd setting captains; reset everyone to observer; spam out captains set message
    localcmd("cmd captainmode ", ftos(captain1_temp), " ", userid, "\n");
    FO_Menu_Admin_Main(TRUE);
}
void execute_admin_players_captain_pick(float choice, float page) {
    string userid = getplayerkeyvalue(choice + (page * 9), "userid");
    localcmd("cmd captainpick ", userid, "\n");
}

var fo_menu FO_MENU_ADMIN_PLAYERS = {
    [0,0], [300,300], "Players", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES | FO_MENU_FLAG_WARNING | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","","","",FO_MENU_STATE_NORMAL,{execute_admin_players(0, FO_MENU_ADMIN_PLAYERS.page);},MENU_BG_DARK},
        {"2","","","",FO_MENU_STATE_NORMAL,{execute_admin_players(1, FO_MENU_ADMIN_PLAYERS.page);},MENU_BG_DARK},
        {"3","","","",FO_MENU_STATE_NORMAL,{execute_admin_players(2, FO_MENU_ADMIN_PLAYERS.page);},MENU_BG_DARK},
        {"4","","","",FO_MENU_STATE_NORMAL,{execute_admin_players(3, FO_MENU_ADMIN_PLAYERS.page);},MENU_BG_DARK},
        {"5","","","",FO_MENU_STATE_NORMAL,{execute_admin_players(4, FO_MENU_ADMIN_PLAYERS.page);},MENU_BG_DARK},
        {"6","","","",FO_MENU_STATE_NORMAL,{execute_admin_players(5, FO_MENU_ADMIN_PLAYERS.page);},MENU_BG_DARK},
        {"7","","","",FO_MENU_STATE_NORMAL,{execute_admin_players(6, FO_MENU_ADMIN_PLAYERS.page);},MENU_BG_DARK},
        {"8","","","",FO_MENU_STATE_NORMAL,{execute_admin_players(7, FO_MENU_ADMIN_PLAYERS.page);},MENU_BG_DARK},
        {"9","","","",FO_MENU_STATE_NORMAL,{execute_admin_players(8, FO_MENU_ADMIN_PLAYERS.page);},MENU_BG_DARK},
        {"0","Back to Main Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();FO_Menu_Admin_Main(TRUE);},MENU_BUTTON},
        {"+","Next","","",FO_MENU_STATE_NORMAL,{Menu_Cancel(); FO_Menu_Admin_Players(TRUE, player_menu_type, FO_MENU_ADMIN_PLAYERS.page + 1);},MENU_BUTTON},
        {"-","Prev","","",FO_MENU_STATE_NORMAL,{Menu_Cancel(); FO_Menu_Admin_Players(TRUE, player_menu_type, FO_MENU_ADMIN_PLAYERS.page - 1);},MENU_BUTTON},
    }, 12, TRUE
};
void action_admin_players(float type) = {
    string n, team;
    float c = 0, p = 0, spec = 0, userid = 0, enable;
    float page = FO_MENU_ADMIN_PLAYERS.page;
    for(float i = 0; i < 9; i++) {
        n = getplayerkeyvalue(i + (page * 9),"name");
        spec = stof(getplayerkeyvalue(i + (page * 9), "*spectator"));
        team = getplayerkeyvalue(i + (page * 9), "team");
        userid = stof(getplayerkeyvalue(i + (page * 9), "userid"));
        enable = TRUE;
        if(!n){
            enable = FALSE;
        }
        if(type == CLIENT_MENU_ADMIN_FORCE_SPEC && spec){
            enable = FALSE;
        }
        if(type == CLIENT_MENU_CAPTAIN_PICK) {
            if(spec) {
                enable = FALSE;
            }
            if(team) {
                enable = FALSE;
            }
            if(i + (page * 9) == player_localnum) {
                enable = FALSE;
            }
        }
        if(type == CLIENT_MENU_CAPTAIN_1 || type == CLIENT_MENU_CAPTAIN_2) {
            if(spec) {
                enable = FALSE;
            }
            if(userid == captain1_temp) {
                enable = FALSE;
            }
        }
        if(enable) {
            FO_MENU_ADMIN_PLAYERS.options[i].state = FO_MENU_STATE_NORMAL;
            FO_MENU_ADMIN_PLAYERS.options[i].name = n;
            FO_MENU_ADMIN_PLAYERS.options[i].value = spec?"Spectator":"";
            FO_MENU_ADMIN_PLAYERS.options[i].colour = MENU_BG_WARNING;
            c++;
        } else {
            FO_MENU_ADMIN_PLAYERS.options[i].state = FO_MENU_STATE_DISABLED;
            FO_MENU_ADMIN_PLAYERS.options[i].name = n;
            FO_MENU_ADMIN_PLAYERS.options[i].value = "";
            FO_MENU_ADMIN_PLAYERS.options[i].colour = MENU_BG_DARK;
        }
    }
}
void action_admin_players_captain_pick() = {
    action_admin_players(CLIENT_MENU_CAPTAIN_PICK);
}
var fo_menu FO_MENU_ADMIN_ROUNDS = {
    [0,0], [300,300], "Quad Rounds", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES | FO_MENU_FLAG_WARNING | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","1","","",FO_MENU_STATE_NORMAL,{localcmd("cmd rounds 1\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"2","2","","",FO_MENU_STATE_NORMAL,{localcmd("cmd rounds 2\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"3","3","","",FO_MENU_STATE_NORMAL,{localcmd("cmd rounds 3\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"4","4","","",FO_MENU_STATE_NORMAL,{localcmd("cmd rounds 4\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"5","5","","",FO_MENU_STATE_NORMAL,{localcmd("cmd rounds 5\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"6","6","","",FO_MENU_STATE_NORMAL,{localcmd("cmd rounds 6\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"7","7","","",FO_MENU_STATE_NORMAL,{localcmd("cmd rounds 7\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"8","8","","",FO_MENU_STATE_NORMAL,{localcmd("cmd rounds 8\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"9","9","","",FO_MENU_STATE_NORMAL,{localcmd("cmd rounds 9\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        MenuSpacer,
        {"0","Back to Main Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();FO_Menu_Admin_Modes(TRUE);},MENU_BUTTON},
    }, 11, TRUE
};
var fo_menu FO_MENU_ADMIN_QUAD_TIMELIMIT = {
    [0,0], [300,200], "Quad Timelimit", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES | FO_MENU_FLAG_WARNING | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","1","","",FO_MENU_STATE_NORMAL,{localcmd("cmd roundtime 1\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"2","5","","",FO_MENU_STATE_NORMAL,{localcmd("cmd roundtime 5\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"3","10","","",FO_MENU_STATE_NORMAL,{localcmd("cmd roundtime 10\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"4","15","","",FO_MENU_STATE_NORMAL,{localcmd("cmd roundtime 15\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"5","20","","",FO_MENU_STATE_NORMAL,{localcmd("cmd roundtime 20\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"6","25","","",FO_MENU_STATE_NORMAL,{localcmd("cmd roundtime 25\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"7","30","","",FO_MENU_STATE_NORMAL,{localcmd("cmd roundtime 30\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"8","45","","",FO_MENU_STATE_NORMAL,{localcmd("cmd roundtime 45\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"9","60","","",FO_MENU_STATE_NORMAL,{localcmd("cmd roundtime 60\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        MenuSpacer,
        {"0","Back to Main Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();FO_Menu_Admin_Modes(TRUE);},MENU_BUTTON},
    }, 11, TRUE
};
var fo_menu FO_MENU_ADMIN_PLAY_TO_COMPLETION = {
    [0,0], [300,200], "Play to completion?", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES | FO_MENU_FLAG_WARNING | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","No","","Match will end as soon as the winner is known",FO_MENU_STATE_NORMAL,{localcmd("cmd play_to_completion 0\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"2","Yes","","Match will end at the end of the final round",FO_MENU_STATE_NORMAL,{localcmd("cmd play_to_completion 1\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        {"0","Back to Main Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();FO_Menu_Admin_Modes(TRUE);},MENU_BUTTON},
    }, 10, TRUE
};
var fo_menu FO_MENU_ADMIN_MATCH_RATED = {
    [0,0], [300,200], "Match Rated?", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES | FO_MENU_FLAG_WARNING | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","Rated","","Match result will affect player ratings",FO_MENU_STATE_NORMAL,{localcmd("cmd fo_matchrated 1\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"2","Unrated","","Match result will not affect player ratings",FO_MENU_STATE_NORMAL,{localcmd("cmd fo_matchrated 0\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        {"3","Default","","Only matches with a teams of three or more players will be rated",FO_MENU_STATE_NORMAL,{localcmd("cmd fo_matchrated 2\n");FO_Menu_Admin_Modes(TRUE);},MENU_BORDER_WARNING},
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        {"0","Back to Main Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();FO_Menu_Admin_Modes(TRUE);},MENU_BUTTON},
    }, 10, TRUE
};
var fo_menu FO_MENU_ADMIN_TIMELIMIT = {
    [0,0], [300,200], "Set Timelimit", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES | FO_MENU_FLAG_WARNING | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","0 (infinite)","","",FO_MENU_STATE_NORMAL,{localcmd("cmd timelimit 0\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"2","5","","",FO_MENU_STATE_NORMAL,{localcmd("cmd timelimit 5\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"3","10","","",FO_MENU_STATE_NORMAL,{localcmd("cmd timelimit 10\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"4","15","","",FO_MENU_STATE_NORMAL,{localcmd("cmd timelimit 15\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"5","20","","",FO_MENU_STATE_NORMAL,{localcmd("cmd timelimit 20\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"6","30","","",FO_MENU_STATE_NORMAL,{localcmd("cmd timelimit 30\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"7","45","","",FO_MENU_STATE_NORMAL,{localcmd("cmd timelimit 45\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"8","60","","",FO_MENU_STATE_NORMAL,{localcmd("cmd timelimit 60\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"9","120","","",FO_MENU_STATE_NORMAL,{localcmd("cmd timelimit 120\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"0","Back to Main Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();FO_Menu_Admin_Settings(TRUE);},MENU_BUTTON},
    }, 10, TRUE
};
var fo_menu FO_MENU_ADMIN_FRAGLIMIT = {
    [0,0], [300,200], "Set Fraglimit", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES | FO_MENU_FLAG_WARNING | FO_MENU_FLAG_ALLOW_INTERMISSION, {
        {"1","0 (infinite)","","",FO_MENU_STATE_NORMAL,{localcmd("cmd fraglimit 0\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"2","5","","",FO_MENU_STATE_NORMAL,{localcmd("cmd fraglimit 5\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"3","10","","",FO_MENU_STATE_NORMAL,{localcmd("cmd fraglimit 10\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"4","15","","",FO_MENU_STATE_NORMAL,{localcmd("cmd fraglimit 15\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"5","20","","",FO_MENU_STATE_NORMAL,{localcmd("cmd fraglimit 20\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"6","30","","",FO_MENU_STATE_NORMAL,{localcmd("cmd fraglimit 30\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"7","50","","",FO_MENU_STATE_NORMAL,{localcmd("cmd fraglimit 50\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"8","100","","",FO_MENU_STATE_NORMAL,{localcmd("cmd fraglimit 100\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"9","200","","",FO_MENU_STATE_NORMAL,{localcmd("cmd fraglimit 200\n");FO_Menu_Admin_Settings(TRUE);},MENU_BORDER_WARNING},
        {"0","Back to Main Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();FO_Menu_Admin_Settings(TRUE);},MENU_BUTTON},
    }, 10, TRUE
};
var fo_menu FO_MENU_VOTE = {
    [0,0], [300,200], "Map Vote", FO_MENU_FLAG_USE_MOUSE | FO_MENU_FLAG_CENTER | FO_MENU_FLAG_SHOW_SHORTCUTS | FO_MENU_FLAG_SHOW_VALUES, {
        {"1","","","",FO_MENU_STATE_NORMAL,{localcmd("cmd votemap ",FO_MENU_VOTE.options[0].name,"\n");Menu_Cancel();},MENU_BUTTON},
        {"2","","","",FO_MENU_STATE_NORMAL,{localcmd("cmd votemap ",FO_MENU_VOTE.options[1].name,"\n");Menu_Cancel();},MENU_BUTTON},
        {"3","","","",FO_MENU_STATE_NORMAL,{localcmd("cmd votemap ",FO_MENU_VOTE.options[2].name,"\n");Menu_Cancel();},MENU_BUTTON},
        {"4","","","",FO_MENU_STATE_NORMAL,{localcmd("cmd votemap ",FO_MENU_VOTE.options[3].name,"\n");Menu_Cancel();},MENU_BUTTON},
        {"5","","","",FO_MENU_STATE_NORMAL,{localcmd("cmd votemap ",FO_MENU_VOTE.options[5].name,"\n");Menu_Cancel();},MENU_BUTTON},
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        MenuSpacer,
        {"0","Back to Main Menu","","",FO_MENU_STATE_NORMAL,{Menu_Cancel();},MENU_BUTTON},
    }, 10, TRUE, {
        FO_MENU_VOTE.title = strcat("Map Vote (", ftos(ceil(mapvote_expiry - time)), "s left)");
        if((mapvote_expiry - time) < 0) {
            Menu_Cancel();
        }
    }
};

vector fo_menu_draw(fo_menu * menu) = {
    vector position;
    if(menu.flags & FO_MENU_FLAG_CENTER) {
        position = getPanelPosition(MenuPanel);
    } else {
        position = menu.position;
    }
    
    if(fo_hud_editor) return position;
    if(!menu.active || showingscores || (intermission && !(menu.flags & FO_MENU_FLAG_ALLOW_INTERMISSION))) {
        setcursormode(FALSE);
        return position;
    }

    FO_Hud_ShowPanel(HUDP_MENU_HINT);
    SBAR.Hint = "";

    setcursormode(menu.flags & FO_MENU_FLAG_USE_MOUSE);
    
    if(menu.update) {
        menu.update();
    }
    
    local float scale = MenuPanel.Scale, textscale = MenuPanel.TextScale;
    if(!textscale) {
        textscale = scale;
    }

    local float padding = 4 * scale, titleoffset = 36 * scale;
    local vector menusize = menu.size * scale;
    local vector buttonsize = [menusize.x - padding * 2, 24];
    local vector buttonpos = position;
    local float buttonhover = FALSE;
    local vector smalltext = MENU_TEXT_SMALL * textscale, mediumtext = MENU_TEXT_MEDIUM * textscale;
    local vector tempcolour;
    local float alignment = SUI_ALIGN_START;
    local vector bgcolour = (menu.flags & FO_MENU_FLAG_WARNING)?MENU_BG_WARNING:MENU_BG;
    local vector bordercolour = (menu.flags & FO_MENU_FLAG_WARNING)?MENU_BORDER_WARNING:MENU_BORDER;
    
    menusize.y = titleoffset + menu.num_opts * (buttonsize.y + padding);
    
    if (sui_is_held(menu->id)) {
        position = position + [Mouse.x, Mouse.y] - HudSettings.MousePos;
        MenuPanel.Position = MenuPanel.Position + [Mouse.x, Mouse.y] - HudSettings.MousePos;
    }
    
    sui_border_box(position, menusize, 1, bordercolour, FO_MENU_TRANSPARENCY, 0);
    sui_push_frame(position, menusize);

    sui_fill([0, 0], menusize, bgcolour, FO_MENU_TRANSPARENCY, 0);

    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_action_element([0, 0], menusize, menu.id, sui_noop);
    sui_pop_frame();
    
    HRC_drawstring(
        position + [menusize.x / 2 - stringwidth(menu.title,1,mediumtext)/2,padding*2], 
        menu.title, 
        mediumtext, 
        (menu.flags & FO_MENU_FLAG_WARNING)?MENU_TEXT_WARNING:MENU_TEXT_2, 
        1, 
        0
    );
    float row = 0;
    SBAR.Hint = menu.description;
    for(float i = 0; i < FO_MENU_MAX_OPTIONS; i++) {
        vector shortcutoffset = [0,0], valueoffset = [0,0];
        
        if(menu.options[i].state == FO_MENU_STATE_HIDDEN) {
            //continue;
        } else if(menu.options[i].state == FO_MENU_STATE_SPACER) {
            row++;
            //continue;
        } else {
            if(menu.flags & FO_MENU_FLAG_SHOW_SHORTCUTS) {
                shortcutoffset = [padding * 4 + smalltext.x, 0];
            }
            if(menu.flags & FO_MENU_FLAG_SHOW_VALUES) {
                valueoffset = [padding * 4 + smalltext.x * 1, 0];
            }
            
            if(menu.options[i].name) {
                buttonpos = position + [padding, titleoffset + row * (buttonsize.y + padding)];
                buttonhover = (Mouse.x > buttonpos.x && Mouse.y > buttonpos.y && Mouse.x < (buttonpos.x + buttonsize.x) && Mouse.y < (buttonpos.y + buttonsize.y));
                if(buttonhover) {
                    SBAR.Hint = menu.options[i].description;
                }

                if(menu.options[i].state == FO_MENU_STATE_NORMAL) {
                    //if(hud_colour_button(strcat("fo_menu_",menu.title,"_",menu.options[i].name), position + [padding, titleoffset + row * (buttonsize.y + padding)] + shortcutoffset, buttonsize - shortcutoffset - valueoffset, menu.options[i].name, menu.options[i].colour, smalltext, SUI_ALIGN_START, padding * 3 + smalltext.x)) {
                    if(hud_colour_button(menu.options[i].id, buttonpos, buttonsize, menu.options[i].name, menu.options[i].colour, smalltext, MENU_TEXT_1, alignment, shortcutoffset.x, 0.6, 1, 0)) {
                        menu.options[i].action();
                    }
                } else if(menu.options[i].state == FO_MENU_STATE_DISABLED) {
                    if(menu.options[i].name) {
                        //sui_border_box(position + [padding, titleoffset + row * (buttonsize.y + padding)] + shortcutoffset, buttonsize - shortcutoffset - valueoffset, 1, bgcolour, 0.4, 0);
                        sui_border_box(buttonpos, buttonsize, 1, bgcolour, 0.4, 0);
                        float disabledtextoffset = 0;
                        if(alignment == SUI_ALIGN_START) {
                            disabledtextoffset = padding + shortcutoffset.x;
                        } else {
                            padding + (buttonsize.x / 2) - stringwidth(menu.options[i].name,1,smalltext) / 2; //Centered
                        }
                        HRC_drawstring(
                            position + [disabledtextoffset, titleoffset + row * (buttonsize.y + padding) + (buttonsize.y / 2) - (MENU_TEXT_SMALL.y / 2)], 
                            menu.options[i].name, 
                            smalltext, 
                            MENU_TEXT_2, 
                            1, 
                            0
                        );
                    }
                    
                }
                if(menu.options[i].shortcut) {
                    HRC_drawstring(
                        position + [padding*3, titleoffset + row * (buttonsize.y + padding) + (buttonsize.y / 2) - (smalltext.y / 2)], 
                        menu.options[i].shortcut, 
                        smalltext, 
                        MENU_TEXT_3, 
                        1, 
                        0
                    );
                }
                if(menu.options[i].value) {
                    HRC_drawstring(
                        position + [menusize.x - padding*4 - stringwidth(menu.options[i].value,1,smalltext) , titleoffset + row * (buttonsize.y + padding) + (buttonsize.y / 2) - (smalltext.y / 2)], 
                        menu.options[i].value, 
                        //strcat(ftos(row),"/",ftos(i)),
                        smalltext, 
                        MENU_TEXT_4, 
                        1, 
                        0
                    );
                }
            }
            row++;
        }
    }
    return position;
}

float fo_menu_process_input(fo_menu * menu, float scan) = {
    local string button = "";
    local float found = FALSE;
    /*
    if(scan > 47 && scan < 58) {
        button = ftos(scan - 48);
    } else {
        switch(scan) {
            case 45:
                button = "-";
                break;
            case 61:
                button = "+";
                break;
        }
    }
    */
    string prefix = "fo_menu_option_";
    for(float i = 0; i < MENU_OPTION.length; i++) {
        if(str2chr(cvar_string(strcat("fo_menu_option_",MENU_OPTION[i])),0) == scan) {
            button = MENU_OPTION[i];
            break;
        }
    }
    if(button != "") {
        for(float i = 0; i < menu.num_opts; i++) {
            if(menu.options[i].shortcut == button) {
                if(menu.options[i].state == FO_MENU_STATE_NORMAL) {
                    menu.options[i].action();
                }
                //If a shortcut matches, always absorb it, even if disabled
                //To avoid weird things like accidentally switching weapons
                //While trying to pick a disabled option
                found = TRUE;
            }
        }
    }
    //Trigger all of them
    return found;
}

void Menu_Cancel() = {
    if (fo_hud_menu_active) {
        setcursormode(FALSE);
        fo_hud_menu_active = FALSE;
    }
    FO_Hud_HidePanel(HUDP_MENU_HINT);
}

void Menu_Draw(float width, float height, float menushown) = {
    if(fo_hud_menu_active) {
        CurrentMenu.position = fo_menu_draw(CurrentMenu);
        //MenuPanel.Position = CurrentMenu.position;
    } else {
        Menu_Cancel();
    }
}

void FO_Menu_Game(float force) = {
    if(fo_hud_menu_active && (CurrentMenu == &FO_MENU_GAME || CurrentMenu == &FO_MENU_GAME_SPECTATOR)) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;

    // Here we care about distinguishing connecting as spectator vs observer, so
    // query it rather than using game_state which mixes.
    float true_spec = stof(getplayerkeyvalue(player_localnum, "*spectator"));
    if (true_spec) {
        //print(getplayerkeyvalue(player_localnum, "name"), " is a spectator!\n");
        //FO_MENU_GAME_SPECTATOR.num_opts = 3;
        FO_MENU_GAME_SPECTATOR.options[2].state = is_admin?FO_MENU_STATE_NORMAL:FO_MENU_STATE_DISABLED;
        //if(is_admin) FO_MENU_GAME_SPECTATOR.num_opts++;
       CurrentMenu = &FO_MENU_GAME_SPECTATOR;
    } else {
        float userid = stof(getplayerkeyvalue(player_localnum, "userid"));
        
        //FO_MENU_GAME.num_opts = 7;
        FO_MENU_GAME.options[5].state = is_admin?FO_MENU_STATE_NORMAL:FO_MENU_STATE_DISABLED;
        //if(is_admin) FO_MENU_GAME.num_opts++;
        FO_MENU_GAME.options[6].state = (userid == captain1 || userid == captain2)?FO_MENU_STATE_NORMAL:FO_MENU_STATE_DISABLED;
        //if(is_admin) FO_MENU_GAME.num_opts++;
        CurrentMenu = &FO_MENU_GAME;
    }
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Track() = {
    if (!game_state.is_spectator)
        return;

    local float i = 0;
    local entity e = find(world, classname, "player");
    while(e) {
        if(i > 19) break;
        FO_MENU_SPECTATOR_TRACK.options[i].name = e.netname;
        FO_MENU_SPECTATOR_TRACK.options[i].shortcut = ftos(i+1);
        //FO_MENU_SPECTATOR_TRACK.options[i].action = void(){};
        i++;
        e = find(e, classname, "player");
    }
    FO_MENU_SPECTATOR_TRACK.num_opts = i;
    //FO_MENU_SPECTATOR_TRACK.position = fo_menu_draw(FO_MENU_SPECTATOR_TRACK);
}

void FO_Menu_Team(float force) = {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_TEAM && force != 2) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && force != 1) {
        return;
    }
    if(team_no) {
        if(number_of_teams < 2) {
            return;
        }
        FO_MENU_TEAM.options[5].state = FO_MENU_STATE_DISABLED;
    } else {
        FO_MENU_TEAM.options[5].state = FO_MENU_STATE_NORMAL;
    }
    for(float i = 0; i < 4; i++) {
        if(i < number_of_teams) {
            //FO_MENU_TEAM.options[i].value = ftos(readbyte());
            if((i + 1) != team_no) {
                FO_MENU_TEAM.options[i].state = FO_MENU_STATE_NORMAL;
            } else {
                FO_MENU_TEAM.options[i].state = FO_MENU_STATE_DISABLED;
            } 
        } else {
            FO_MENU_TEAM.options[i].state = FO_MENU_STATE_DISABLED;
        }
    }
    localcmd("cmd changeteam\n");
    CurrentMenu = &FO_MENU_TEAM;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Class(float force) = {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_CLASS && force != 2) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && force != 1)
        return;
    CurrentMenu = &FO_MENU_CLASS;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_DropAmmo(float force) {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_DROPAMMO) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;

    float available = 0;
    FO_MENU_DROPAMMO.options[0].value = "";
    if(getstatf(STAT_SHELLS) < DROP_SHELLS) {
        FO_MENU_DROPAMMO.options[0].state = FO_MENU_STATE_DISABLED;
    } else {
        FO_MENU_DROPAMMO.options[0].state = FO_MENU_STATE_NORMAL;
        available++;
    }        
    FO_MENU_DROPAMMO.options[1].value = "";
    if(getstatf(STAT_NAILS) < DROP_NAILS) {
        FO_MENU_DROPAMMO.options[1].state = FO_MENU_STATE_DISABLED;
    } else {
        FO_MENU_DROPAMMO.options[1].state = FO_MENU_STATE_NORMAL;
        available++;
    }        
    FO_MENU_DROPAMMO.options[2].value = "";
    if(getstatf(STAT_ROCKETS) < DROP_ROCKETS) {
        FO_MENU_DROPAMMO.options[2].state = FO_MENU_STATE_DISABLED;
    } else {
        FO_MENU_DROPAMMO.options[2].state = FO_MENU_STATE_NORMAL;
        available++;
    }        
    FO_MENU_DROPAMMO.options[3].value = "";
    if(getstatf(STAT_CELLS) < DROP_CELLS) {
        FO_MENU_DROPAMMO.options[3].state = FO_MENU_STATE_DISABLED;
    } else {
        FO_MENU_DROPAMMO.options[3].state = FO_MENU_STATE_NORMAL;
        available++;
    }        
    if(!available) {
        if(fo_hud_menu_active && CurrentMenu == &FO_MENU_DROPAMMO) {
            Menu_Cancel();
        } else {
            print("Not enough ammo\n");
        }
        return;
    }
    if (WP_PlayerClass() == PC_ENGINEER) {
        FO_MENU_DROPAMMO.title = "Drop or Make Ammo";
        if ((getstatf(STAT_SHELLS) < DROP_SHELLS) && ((getstatf(STAT_CELLS) / AMMO_COST_SHELLS) > (DROP_SHELLS - getstatf(STAT_SHELLS)))) {
            FO_MENU_DROPAMMO.options[0].value = "(make)";
            FO_MENU_DROPAMMO.options[0].state = FO_MENU_STATE_NORMAL;
        }
        if ((getstatf(STAT_NAILS) < DROP_NAILS) && ((getstatf(STAT_CELLS) / AMMO_COST_NAILS) > (DROP_NAILS - getstatf(STAT_NAILS)))) {
            FO_MENU_DROPAMMO.options[1].value = "(make)";
            FO_MENU_DROPAMMO.options[1].state = FO_MENU_STATE_NORMAL;
        }
        if ((getstatf(STAT_ROCKETS) < DROP_ROCKETS) && ((getstatf(STAT_CELLS) / AMMO_COST_ROCKETS) > (DROP_ROCKETS - getstatf(STAT_ROCKETS)))) {
            FO_MENU_DROPAMMO.options[2].value = "(make)";
            FO_MENU_DROPAMMO.options[2].state = FO_MENU_STATE_NORMAL;
        }
    } else {
        FO_MENU_DROPAMMO.title = "Drop Ammo";
    }

    CurrentMenu = &FO_MENU_DROPAMMO;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Scout(float force, float scanner_on, float scanner_flags) = {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_SCOUT && force != 2) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && force != 1)
        return;
    FO_MENU_SCOUT.options[0].value = (scanner_on?"on":"off");
    FO_MENU_SCOUT.options[1].value = ((scanner_flags & 1)?"on":"off");
    FO_MENU_SCOUT.options[2].value = ((scanner_flags & 2)?"on":"off");
    FO_MENU_SCOUT.options[3].value = ((scanner_flags & 4)?"on":"off");
    CurrentMenu = &FO_MENU_SCOUT;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Spy(float force) = {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_SPY && force != 2) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && force != 1)
        return;
    if(SBAR.InvisOnly) {
        //FO_MENU_SPY.options[0].state = FO_MENU_STATE_HIDDEN;
        //FO_MENU_SPY.options[1].state = FO_MENU_STATE_NORMAL;
        FO_MENU_SPY.options[0].name = "Invisibility";
        FO_MENU_SPY.options[0].value = (SBAR.IsUndercover?"on":"off");
        FO_MENU_SPY.options[1].state = FO_MENU_STATE_DISABLED;
    } else {
        //FO_MENU_SPY.options[0].state = FO_MENU_STATE_NORMAL;
        //FO_MENU_SPY.options[1].state = FO_MENU_STATE_HIDDEN;
        FO_MENU_SPY.options[0].name = "Disguise";
        FO_MENU_SPY.options[0].value = (SBAR.IsUndercover?"on":"off");
        if(last_selected_skin || last_team) {
            FO_MENU_SPY.options[1].state = FO_MENU_STATE_NORMAL;
            FO_MENU_SPY.options[1].value = strcat(TeamToString(last_team)," ",ClassToString(last_selected_skin));
        } else {
            FO_MENU_SPY.options[1].state = FO_MENU_STATE_DISABLED;
        }
        FO_MENU_SPY.options[3].state = (SBAR.IsUndercover?FO_MENU_STATE_NORMAL:FO_MENU_STATE_DISABLED);
    }
    local float smt = stof(getplayerkeyvalue(player_localnum, "smt"));
    FO_MENU_SPY.options[7].value = (smt?"on":"off");
    CurrentMenu = &FO_MENU_SPY;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Spy_Team(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    if(team_no) {
        if(number_of_teams < 2 || team_no > number_of_teams) {
            return;
        }
        for(float i = 0; i < 4; i++) {
            //if((i + 1) == SBAR.DisguiseTeam || i >= number_of_teams) {
            if(i >= number_of_teams) {
                FO_MENU_SPY_TEAM.options[i].state = FO_MENU_STATE_DISABLED;
            } else {
                FO_MENU_SPY_TEAM.options[i].state = FO_MENU_STATE_NORMAL;
            }
            
        }
    }
    CurrentMenu = &FO_MENU_SPY_TEAM;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Spy_Skin(float force) = {
    if(fo_hud_menu_active && CurrentMenu == &FO_MENU_SPY_SKIN && force != 2) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && force != 1) {
        return;
    }
    if(!fo_hud_menu_active && CurrentMenu == &FO_MENU_SPY_SKIN && force == 2) {
        return;
    }
    CurrentMenu = &FO_MENU_SPY_SKIN;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Detpack(float force, float cancel_detpack) = {
    if(fo_hud_menu_active && (CurrentMenu == &FO_MENU_DETPACK_CANCEL || CurrentMenu == &FO_MENU_DETPACK) && force != 2) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && force != 1)
        return;
    if(cancel_detpack) {
        CurrentMenu = &FO_MENU_DETPACK_CANCEL;
    } else {
        CurrentMenu = &FO_MENU_DETPACK;
    }
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Build(float force) = {
    if(fo_hud_menu_active && (CurrentMenu == &FO_MENU_BUILD_CANCEL || CurrentMenu == &FO_MENU_BUILD) && force != 2) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && force != 1)
        return;
    if(SBAR.IsBuilding) {
        CurrentMenu = &FO_MENU_BUILD_CANCEL;
    } else {
        CurrentMenu = &FO_MENU_BUILD;
    }
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Rotate_Sentry(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    if(SBAR.IsBuilding) {
        return;
    } else {
        CurrentMenu = &FO_MENU_SENTRY_ROTATE;
    }
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Dispenser_Fix(float force, float old_spanner) = {
    if(fo_hud_menu_active && !force)
        return;
    FO_MENU_DISPENSER_MAINTAIN.options[2].state = (old_spanner?FO_MENU_STATE_NORMAL:FO_MENU_STATE_HIDDEN);
    CurrentMenu = &FO_MENU_DISPENSER_MAINTAIN;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Dispenser_Use(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    if(SBAR.IsBuilding) {
        return;
    } else {
        CurrentMenu = &FO_MENU_DISPENSER_USE;
    }
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Admin_Main(float force) = {
    if(fo_hud_menu_active && (CurrentMenu == &FO_MENU_ADMIN_MAIN || CurrentMenu == &FO_MENU_ADMIN_MODES || CurrentMenu == &FO_MENU_ADMIN_SETTINGS)) {
        Menu_Cancel();
        return;
    }
    if(fo_hud_menu_active && !force)
        return;
    localcmd("cmd adminrefresh\n");
    CurrentMenu = &FO_MENU_ADMIN_MAIN;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Admin_Modes(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    localcmd("cmd adminrefresh\n");
    CurrentMenu = &FO_MENU_ADMIN_MODES;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Admin_Settings(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    localcmd("cmd adminrefresh\n");
    CurrentMenu = &FO_MENU_ADMIN_SETTINGS;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Admin_Rounds(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    CurrentMenu = &FO_MENU_ADMIN_ROUNDS;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Admin_QuadTimelimit(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    CurrentMenu = &FO_MENU_ADMIN_QUAD_TIMELIMIT;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Admin_PlayToCompletion(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    CurrentMenu = &FO_MENU_ADMIN_PLAY_TO_COMPLETION;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Admin_FoMatchRated(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    CurrentMenu = &FO_MENU_ADMIN_MATCH_RATED;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Admin_Timelimit(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    CurrentMenu = &FO_MENU_ADMIN_TIMELIMIT;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Admin_Fraglimit(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    CurrentMenu = &FO_MENU_ADMIN_FRAGLIMIT;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Admin_Players(float force, float type, float page) = {
    if(fo_hud_menu_active && !force)
        return;
    if(page < 0) {
        //or(float i = 0; i < 100; i++) {
        //    if(!getplayerkeyvalue(i,"name")) {
        //        page = floor(i / 9);
        //        break;
        //    }
        //}
        page = 0;
    }
    //if(!(getplayerkeyvalue(page * 9,"name"))) page = 0;
    if(page < 0) page = 4;
    if(page > 4) page = 0;
    FO_MENU_ADMIN_PLAYERS.page = page;
    player_menu_type = type;
    FO_MENU_ADMIN_PLAYERS.update = SUB_Null;
    if(type == CLIENT_MENU_ADMIN_KICK) {
        FO_MENU_ADMIN_PLAYERS.title = strcat("Kick ", ftos(page + 1), "/5");
        execute_admin_players = execute_admin_players_kick;
    } else if(type == CLIENT_MENU_ADMIN_BAN) {
        FO_MENU_ADMIN_PLAYERS.title = strcat("Ban ", ftos(page + 1), "/5");
        execute_admin_players = execute_admin_players_ban;
    } else if(type == CLIENT_MENU_ADMIN_FORCE_SPEC) {
        FO_MENU_ADMIN_PLAYERS.title = strcat("Force Spec ", ftos(page + 1), "/5");
        execute_admin_players = execute_admin_players_force_spec;
    } else if(type == CLIENT_MENU_CAPTAIN_1) {
        captain1_temp = 0;
        captain2_temp = 0;
        FO_MENU_ADMIN_PLAYERS.title = strcat("Captain 1 ", ftos(page + 1), "/5");
        execute_admin_players = execute_admin_players_captain1;
    } else if(type == CLIENT_MENU_CAPTAIN_2) {
        FO_MENU_ADMIN_PLAYERS.title = strcat("Captain 2 ", ftos(page + 1), "/5");
        execute_admin_players = execute_admin_players_captain2;
    } else if(type == CLIENT_MENU_CAPTAIN_PICK) {
        FO_MENU_ADMIN_PLAYERS.title = strcat("Pick teammate ", ftos(page + 1), "/5");
        execute_admin_players = execute_admin_players_captain_pick;
        FO_MENU_ADMIN_PLAYERS.update = action_admin_players_captain_pick;
    } else {
        FO_MENU_ADMIN_PLAYERS.title = strcat("Page ", ftos(page + 1), "/5");
        execute_admin_players = execute_admin_players_unknown;
    }
    action_admin_players(type);
    CurrentMenu = &FO_MENU_ADMIN_PLAYERS;
    fo_hud_menu_active = TRUE;
}
void FO_Menu_Vote(float force) = {
    if(fo_hud_menu_active && !force)
        return;
    CurrentMenu = &FO_MENU_VOTE;
    fo_hud_menu_active = TRUE;
}

void FO_Menu_Special(float force) = {
    if(fo_hud_menu_active && force != 1)
        return;
    
    fo_menu* NewMenu = __NULL__;
    switch (WP_PlayerClass()) {
        case PC_SCOUT:
            NewMenu = &FO_MENU_SCOUT;
            //nm = FO_Menu_Scout;
            break;
        case PC_DEMOMAN:
            NewMenu = &FO_MENU_DETPACK;
            //nm = FO_Menu_Detpack;
            break;
        case PC_SPY:
            NewMenu = &FO_MENU_SPY;
            //nm = FO_Menu_Spy;
            break;
        case PC_ENGINEER:
            NewMenu = &FO_MENU_BUILD;
            //nm = FO_Menu_Build;
            break;
        default:
            //no class menu
            return;
    }
    
    if(fo_hud_menu_active && CurrentMenu == NewMenu && force != 2) {
        Menu_Cancel();
        return;
    }
    switch (WP_PlayerClass()) {
        case PC_SCOUT:
            FO_Menu_Scout(force, FALSE, FALSE); //TODO: fix scanner settings
            break;
        case PC_DEMOMAN:
            FO_Menu_Detpack(force, FALSE); //TODO: fix cancel
            break;
        case PC_SPY:
            FO_Menu_Spy(force);
            break;
        case PC_ENGINEER:
            FO_Menu_Build(force);
            break;
        default:
            //no class menu
            return;
    }
    localcmd("cmd menu\n");
    //fo_hud_menu_active = TRUE;
};

void (float show) showVoteMenu = {
    if(fo_hud_menu_active) {
        Menu_Cancel();
    }
    setcursormode(show);
    FO_Hud_SetDisplay(HUDP_MAP_MENU, show);
    if(show) {
        CurrentMenu = &FO_MENU_VOTE;
    }
};

#define INIT_MENU_IDS(_target) \
    do { \
        _target.id = ++next_id; \
        for (i = 0; i < _target.options.length; i++) \
            _target.options[i].id = ++next_id; \
    } while (0)


// Returns path if it exists, empty string otherwise.
static string InitIfFileExists(string path) {
    float filehandle = fopen(path, FILE_READ);
    if (filehandle >= 0) {
        fclose(filehandle);
        return path;
    }
    return "";
}

void FO_Hud_Init() {
    float i;
    ASSERTD_EQ(Hud_Panels.length, HUDP_LAST - HUDP_FIRST + 1);

    for (i = 0; i < Hud_Panels.length; i++)
        ASSERTD_EQ(i + HUDP_FIRST, Hud_Panels[i].id);
    float next_id = HUD_LAST + 1;

    /* DrawPanel = *getHudPanel(HUDP_OPTIONS);  // XXX */
    INIT_MENU_IDS(FO_MENU_GAME);
    INIT_MENU_IDS(FO_MENU_GAME_SPECTATOR);
    INIT_MENU_IDS(FO_MENU_SPECTATOR_TRACK);
    INIT_MENU_IDS(FO_MENU_TEAM);
    INIT_MENU_IDS(FO_MENU_CLASS);
    INIT_MENU_IDS(FO_MENU_DROPAMMO);
    INIT_MENU_IDS(FO_MENU_SCOUT);
    INIT_MENU_IDS(FO_MENU_SPY);
    INIT_MENU_IDS(FO_MENU_SPY_TEAM);
    INIT_MENU_IDS(FO_MENU_SPY_SKIN);
    INIT_MENU_IDS(FO_MENU_DETPACK);
    INIT_MENU_IDS(FO_MENU_DETPACK_CANCEL);
    INIT_MENU_IDS(FO_MENU_BUILD);
    INIT_MENU_IDS(FO_MENU_BUILD_CANCEL);
    INIT_MENU_IDS(FO_MENU_SENTRY_MAINTAIN);
    INIT_MENU_IDS(FO_MENU_SENTRY_ROTATE);
    INIT_MENU_IDS(FO_MENU_ADMIN_MAIN);
    INIT_MENU_IDS(FO_MENU_ADMIN_MODES);
    INIT_MENU_IDS(FO_MENU_ADMIN_SETTINGS);
    INIT_MENU_IDS(FO_MENU_ADMIN_PLAYERS);
    INIT_MENU_IDS(FO_MENU_ADMIN_ROUNDS);
    INIT_MENU_IDS(FO_MENU_ADMIN_QUAD_TIMELIMIT);
    INIT_MENU_IDS(FO_MENU_ADMIN_MATCH_RATED);
    INIT_MENU_IDS(FO_MENU_ADMIN_PLAY_TO_COMPLETION);
    INIT_MENU_IDS(FO_MENU_ADMIN_TIMELIMIT);
    INIT_MENU_IDS(FO_MENU_ADMIN_FRAGLIMIT);
    INIT_MENU_IDS(FO_MENU_VOTE);

    FO_ScoreBoardAssets.icon_ready = InitIfFileExists("textures/wad/icon_ready.png");
    FO_ScoreBoardAssets.icon_chat = InitIfFileExists("textures/wad/icon_chat.png");
    FO_ScoreBoardAssets.icon_afk = InitIfFileExists("textures/wad/icon_afk.png");
}
#undef INIT_MENU_IDS
