.entity outline;
.float grentimer_expires;  // TODO: integrate this
.float teamno;
static entity local_player;
static float shader_team[2], shader_flag, shader_over_outline;

enum {
    TeamNone = 0,
    TeamBlue = 1,
    TeamRed = 2,
};


static float FlagCarried() {  // Just awful.
    for (int i = 0; i < FlagInfoLines.length; i++)
        if (FlagInfoLines[i].state == FLAGINFO_CARRIED)
            return TRUE;
    return FALSE;
}

// Until we network player entities we need somewhere to stash things.
struct EntHash {
    int entnum;
    float grentimer_expires;
};
static EntHash ent_hash[43];

static EntHash* EntGet(int ent_num) {
    EntHash* he = __NULL__;

    for (int i = 0; i < ent_hash.length; i++) {
        he = &ent_hash[(i + ent_num) % ent_hash.length];
        if (he->entnum == ent_num)
            return he;
        else if (!he->entnum)
            break;
    }

    he->entnum = ent_num;
    return he;
}

static float TeamNo(entity player) {
    // This is horrific, but the most immediately accessible thing we seem to
    // have.  getentity() is just unreliable.
    float pc = stof(infokey(player, INFOKEY_P_BOTTOMCOLOR));
    switch (pc) {
        case 13: return TeamBlue;
        case 4: return TeamRed;
    }
    return TeamNone;
}

static inline float AttackingTeamNo() { return getstatf(STAT_TEAMNO_ATTACK); }

static float IsAttacking(entity player) {
    /* return TeamNo(player) == getstatf(STAT_TEAMNO_ATTACK); */
    return player.teamno == AttackingTeamNo();
}

static float ShowPlayerOutline(entity player) {
    if (player.entnum == player_localentnum || player.teamno == TeamNone)
        return FALSE;

    if (prematch && TFxEnabled(TFX_PREMATCH_EVERYTHING))
        return TRUE;

    if (!game_state.is_player)
        return TFxEnabled(TFX_SPEC_OUTLINE);

    if ((TFxEnabled(TFX_DEFENSE_OUTLINE) && !IsAttacking(player)) ||
        (TFxEnabled(TFX_OFFENSE_OUTLINE) && IsAttacking(player)))
        return player.teamno == local_player.teamno;

    return FALSE;
}

static void RemoveOutline() {
    if (self.outline != __NULL__)
        remove(self.outline);
}

static void AddOutline(entity ent) {
    entity o = spawn();
    setmodelindex(o, ent.modelindex);
    o.classname = "outline";
    o.fatness = 1;
    setsize(o, PLAYER_MINS, PLAYER_MAXS);

    ent.outline = o;
    ent.removefunc = RemoveOutline;
}

static void UpdateOutline(entity player) {
    entity o = player.outline;
    if (!ShowPlayerOutline(player)) {
        o.drawmask = 0;
        self.forceshader = 0;
        return;
    }

    self.forceshader = shader_over_outline;
    o.forceshader = shader_team[TeamNo(player) - TeamBlue];
    o.drawmask = MASK_ENGINE;
    o.frame = player.frame;
    o.angles = player.angles;
    if (player == local_player)
        o.renderflags |= RF_EXTERNALMODEL;
    setorigin(o, player.origin);

}

float UpdatePlayer(float isnew) {
    if (isnew) {
        if (self.entnum == player_localentnum && game_state.is_player)
            local_player = self;

        AddOutline(self);
    }

    if (self.entnum == player_localentnum)
        self.renderflags |= RF_EXTERNALMODEL;
    else
        self.renderflags &= ~RF_EXTERNALMODEL;

    self.teamno = TeamNo(self);

    UpdateOutline(self);
    return TRUE;
}

static float ShowTeamGrenTimer(float team, float my_team) {
    if (!game_state.is_player && TFxEnabled(TFX_SPEC_GRENTIMER))
        return TRUE;

    if (prematch && TFxEnabled(TFX_PREMATCH_EVERYTHING))
        return TRUE;

    if (team == AttackingTeamNo()) {
        if (TFxEnabled(TFX_OFFENSE_GRENTIMER) && team == my_team)
            return TRUE;
    } else {
        if (TFxEnabled(TFX_DEFENSE_GRENTIMER) && team == my_team)
            return TRUE;
    }

    return FALSE;
}

static entity gren_list[20];
static int num_gren_list;
static float next_grenlist_update;

static float RenderGrenTimer(entity p, float test_only) {
    const float maxd = 1000, mind = 200;
    vector po = p.origin + '0 0 40';
    vector o = PM_Org();

    if (p == local_player)
        return FALSE;

    float diff = vlen(po - o);
    if (diff > maxd)
        return FALSE;

    traceline(o, po, 3, p);
    if (trace_fraction < 1)
        return FALSE;

    EntHash* he = EntGet(p.entnum);
    float rem = he->grentimer_expires - time;
    if (rem < 0)
        return FALSE;

    if (test_only)
        return TRUE;

    vector colors[] = { '1 0 0', '0.8 0.8 0.4', '0.8 0.5 0.5', '1 1 1'};
    vector c = project(po);
    vector size = '8 8 8' * (maxd - max(diff, mind)) / (maxd - mind);
    string str = ftos(ceil(rem));
    c.x -= stringwidth(str, FALSE, size) / 2;
    drawstring(c, str, size, colors[floor(rem)], 1, 0);

    return TRUE;
}

entity*(.__variant fld, __variant match, int type=EV_STRING, __out int count) find_list = #0:find_list;

static void UpdateGrenList() {
    if (time < next_grenlist_update)
        return;
    next_grenlist_update = time + 0.1;
    num_gren_list = 0;

    float teams[] = {TeamRed, TeamBlue};

    for (int i = 0; i < teams.length; i++) {
        float team = teams[i];
        if (!ShowTeamGrenTimer(team, local_player.teamno))
                continue;

        int count;
        entity* players = find_list(teamno, team, EV_FLOAT, count);
        for (int j = 0; j < count; j++) {
            entity p = players[j];

            if (RenderGrenTimer(p, TRUE))
                gren_list[num_gren_list++] = p;
        }
    }
}

void TFxRenderGrenadeTimers() {
    UpdateGrenList();

    for (int i = 0; i < num_gren_list; i++) {
        entity p = gren_list[i];
        RenderGrenTimer(p, FALSE);
    }
}

static float ShowFlagOutline() {
    if (!game_state.is_player && TFxEnabled(TFX_SPEC_SEEFLAG))
        return TRUE;

    if (prematch && TFxEnabled(TFX_PREMATCH_EVERYTHING))
        return TRUE;

    if (TFxEnabled(TFX_OFFENSE_SEEFLAG) && IsAttacking(local_player))
        return TRUE;

    if (TFxEnabled(TFX_DEFENSE_SEEFLAG) && !IsAttacking(local_player) &&
        !FlagCarried())
        return TRUE;

    return FALSE;
}

static void UpdateFlagOutline(entity flag) {
    entity o = flag.outline;
    if (!ShowFlagOutline()) {
        o.drawmask = 0;
        return;
    }

    o.forceshader = shader_flag;
    o.drawmask = MASK_ENGINE;
    o.angles = flag.angles;
    o.frame = flag.frame;
    setorigin(o, flag.origin);
}

float UpdateFlag(float isnew) {
    /* if (isnew) { */
    /*     float mindex = self.modelindex; */
    /*     AddOutline(self); */
    /*     // Flags have their own shader already, just make them shiny for now. */
    /* } */

    /* UpdateFlagOutline(self); */

    LocalEffects(self.effects, self.origin);

    if (self.skin == team_no) {
        local float distance = vlen(self.origin - PM_Org());
        self.alpha = min(0.25 + (distance / 200), 1);
    }

    return TRUE;
}

void TFxGrenTimerUpdate(float ent_num, float expiry) {
    EntHash* he = EntGet(ent_num);
    he->grentimer_expires = expiry;
}

static string OutlineShader(string texture) {
    return sprintf(
"{\
  sort 6\
  {\
     map %s\
     rgbGen lightingDiffuse\
     blendfunc GL_ONE GL_ONE_MINUS_SRC_COLOR\
     tcgen environment\
     tcmod rotate 30\
     nodepthtest\
     depthfunc greater\
  }\
}", texture);
}

static string rnds(string prefix) {
#if 0
    // Debugging convenience, concatenates a random string when enabled so that
    // shaders don't get cached on-client between builds.
    for (int i = 0; i < 5; i++)
            prefix = strcat(prefix, chr2str('a' + floor(random() * 26)));
#endif
    return prefix;
}

void TF_Init() {
#if 0
    Deltalisten breaks some default shaders even without a forceoverride.  Quick
    fix to unblock.

    deltalisten("progs/player.mdl", UpdatePlayer, 0);
    deltalisten("progs/ff_flag.mdl", UpdateFlag, 0);
    deltalisten("progs/tf_flag.mdl", UpdateFlag, 0);

    shader_team[0] = shaderforname(rnds("blue_team_outline"), OutlineShader("textures/sfx/quad.tga"));
    shader_team[1] = shaderforname(rnds("red_team_outline"), OutlineShader("textures/sfx/pent.tga"));
    shader_flag = shaderforname(rnds("flag_outline"), OutlineShader("textures/sfx/specular.tga"));

    shader_over_outline = shaderforname(rnds("over_outline"), "{ sort 7 }");
#endif

    deltalisten("progs/ff_flag.mdl", UpdateFlag, 0);
    deltalisten("progs/tf_flag.mdl", UpdateFlag, 0);
    deltalisten("progs/tf_stan.mdl", UpdateFlag, 0);
}
