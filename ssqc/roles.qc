#pragma target fte

float (string ps_short, string ps_setting, string ps_default) CF_GetSetting;
string(float tno) GetTeamName;
void () item_tfgoal_touch;
void CenterPrint(entity, string);


float quad_roles;

typedef struct {
    string name;
    string prefix;
    float detpipe_limit;
    float respawn_delay_time;
    float gren1_limits[10];
    float gren2_limits[10];
    float class_limits[12];
} Team_Role;

var Team_Role Role_None = {"Default", "", 6};
var Team_Role Role_Attack = {"Attack", "att_", 6};
var Team_Role Role_Defence = {"Defence", "def_", 6};
Team_Role * Team1_Role;
Team_Role * Team2_Role;
Team_Role * Team3_Role;
Team_Role * Team4_Role;

const string CLASSES [12] = {
    "observer",
    "scout",
    "sniper",
    "soldier",
    "demoman",
    "medic",
    "hwguy",
    "pyro",
    "spy",
    "engineer",
    "randompc",
    "civilian"
};

void (Team_Role * role) LoadRole = {
    role.detpipe_limit = CF_GetSetting(strcat(role.prefix,"dl"), strcat(role.prefix,"detpipe_limit"), ftos(Role_None.detpipe_limit));
    role.respawn_delay_time = CF_GetSetting(strcat(role.prefix,"rd"), strcat(role.prefix,"respawn_delay"), ftos(Role_None.respawn_delay_time));
    role.gren1_limits[0] = 0;
    role.gren2_limits[0] = 0;
    role.class_limits[0] = 0;
    for(float i = 1; i < 10; i++) {
        role.gren1_limits[i] = CF_GetSetting(strcat(role.prefix,"mg1_",ftos(i)), strcat(role.prefix,"max_gren1_",CLASSES[i]), ftos(Role_None.gren1_limits[i]));
        role.gren2_limits[i] = CF_GetSetting(strcat(role.prefix,"mg2_",ftos(i)), strcat(role.prefix,"max_gren2_",CLASSES[i]), ftos(Role_None.gren2_limits[i]));
        role.class_limits[i] = CF_GetSetting(strcat(role.prefix,"cr_",CLASSES[i]), strcat(role.prefix,"cr_",CLASSES[i]), ftos(Role_None.class_limits[i]));
    }
};

void (entity e) PrintRoleStatus = {
    float current = CF_GetSetting("qr", "quad_roles", "0");
    sprint(e, PRINT_HIGH, "Roles are ", quad_roles?"\sENABLED\s":"\sDISABLED\s");
    if(!quadmode) {
        sprint(e, PRINT_HIGH, ", however it requires \squadmode\s to work. Set it from the admin menu.");
    }
    if(current != quad_roles) {
        sprint(e, PRINT_HIGH, "\nNote that the setting will be ", current?"\sENABLED\s":"\sDISABLED\s", " after map restart.");
    }
    sprint(e, PRINT_HIGH, "\n");
};

void (entity e, Team_Role * role) PrintRole = {
    sprint(e, PRINT_HIGH, "\sRole:\s ", role.name, "\n");
    sprint(e, PRINT_HIGH, "Detpipe Limit: ", ftos(role.detpipe_limit), "\n");
    sprint(e, PRINT_HIGH, "Respawn Delay: ", ftos(role.respawn_delay_time), "\n");
    for(float i = 1; i < 10; i++) {
        sprint(e, PRINT_HIGH, CLASSES[i],": \n");
        sprint(e, PRINT_HIGH, "\tGren 1: ", ftos(role.gren1_limits[i]), "\n");
        sprint(e, PRINT_HIGH, "\tGren 2: ", ftos(role.gren2_limits[i]), "\n");
        sprint(e, PRINT_HIGH, "\tClass Limit: ", ftos(role.class_limits[i]), "\n");
    }
    sprint(e, PRINT_HIGH, CLASSES[10],": \n");
    sprint(e, PRINT_HIGH, "\tClass Limit: ", ftos(role.class_limits[10]), "\n");
}

void () InitTeamRoles = {
    Team1_Role = &Role_None;
    Team2_Role = &Role_None;
    Team3_Role = &Role_None;
    Team4_Role = &Role_None;
};

void (entity e) PrintTeamRoles = {
    sprint(e, PRINT_HIGH, "\sTeam Roles:\s\n");
    if(number_of_teams > 0) {
        sprint(e, PRINT_HIGH, GetTeamName(1), ": ", Team1_Role.name, "\n");
    }
    if(number_of_teams > 1) {
        sprint(e, PRINT_HIGH, GetTeamName(2), ": ", Team2_Role.name, "\n");
    }
    if(number_of_teams > 2) {
        sprint(e, PRINT_HIGH, GetTeamName(3), ": ", Team3_Role.name, "\n");
    }
    if(number_of_teams > 3) {
        sprint(e, PRINT_HIGH, GetTeamName(4), ": ", Team4_Role.name, "\n");
    }
};

Team_Role* (float tno) GetTeamRole = {
    switch (tno) {
        case 1:
            return Team1_Role;
        case 2:
            return Team2_Role;
        case 3:
            return Team3_Role;
        case 4:
            return Team4_Role;
    }
    return &Role_None;
};

void () item_tfgoal_hidden_touch = {

    if (other.classname != "player")
        return;
    if (other.health <= 0)
        return;
    if (cb_prematch)
        return;
    if (other.is_feigning)
        return;
    if (other == self.owner)
        return;

    // check if a wall or something is in the way of the flag
    traceline(other.origin, self.origin, TRUE, world);
    if (trace_fraction < 1)
        return;
    
    if(self.owned_by == other.team_no) {
        CenterPrint(other, "Unfortunately, your flag is in another castle\n\nYou are Attacking the other base\n");
    } else {
        CenterPrint(other, "You are defending the wrong flag!\n\nGet back to your base quickly\n");
    }
}

void Quad_HideFlag(entity flag) = {
    flag.touch = item_tfgoal_hidden_touch;
    setmodel(flag, "");
    setsize(flag, flag.goal_min, flag.goal_max);
};

void Quad_UnHideFlag(entity flag) = {
    flag.touch = item_tfgoal_touch;
    setmodel(flag, flag.mdl);
    setsize(flag, flag.goal_min, flag.goal_max);
};
