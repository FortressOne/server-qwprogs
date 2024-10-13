DEFCVAR_FLOAT(fo_jumpvolume, 1);

#define STEPTIME 0.125

enumflags {
    PMF_JUMP_HELD,
};

// `seq` is the start of the first frame after which all input_*s are handled.
// Running to `seq` will result in being on frame `seq + 1` in the resultant
// state.  In the case that `seq == commandclientframe` this could only be
// partially true since the input_*s (in particular, timelength) are not
// constant for this frame.
static struct PMS_Data {
    vector org, vel;
    float seq, server_seq;
    float interp_t;
} pm_s, pm_so, pm_c;

static struct {
    entity ent;
    float last_vel_z;
    PMS_Data* active_pmsd;

    float seq, server_seq;
    float interp_t;
    float last_nudge;

    vector error;
    float errortime;

    float step, steptime, step_oldz;

    vector vieworg;
} pm;

vector PM_Org() { return PM_Enabled() ? pm.ent.origin : pmove_org; }
vector PM_Vel() { return PM_Enabled() ? pm.ent.velocity : pmove_vel; }
inline entity PM_Ent() { return pm.ent; }

float CSQC_JumpSounds_Active() {
    if (PM_Enabled())
            return TRUE;  // PM sounds are accurate.
    return CVARF(fo_csjumpsounds);
}

// Sets *type to whatever is at the feet of `point`.
static float PM_GetWaterLevel(vector point, float* type) {
    float waterlevel = 0;
    float offsets[] = { PLAYER_MINS.z + 1, (PLAYER_MINS.z + PLAYER_MAXS.z) / 2,
                        DEFAULT_VIEWHEIGHT };
    for (int i = 0; i < 3; i++) {
        float cont = pointcontents(point + offsets[i] * '0 0 1');
        if (i == 0)
            *type = cont;
        if (cont == CONTENT_WATER || cont == CONTENT_SLIME || cont == CONTENT_LAVA)
            waterlevel++;
        else
            break;
    }
    return waterlevel;
}

static void PM_Sounds(float is_jumping, float is_jumpframe,
                      float is_landing,
                      float last_vel_z) {
    float fluidtype;
    static float last_waterlevel;  // Hacky ...
    float waterlevel = PM_GetWaterLevel(PM_Org(), &fluidtype);

    if (is_landing && last_vel_z < -300) {  // Hard or water land.
        if (fluidtype == CONTENT_WATER)
            localsound("player/h2ojump.wav", CHAN_BODY, 1);
        else if (last_vel_z < -650)  // Will take damage.
            localsound("player/land2.wav", CHAN_VOICE, 1);
        else
            localsound("player/land.wav", CHAN_VOICE, 1);
    }

    // TODO: Model health above and not play jump when landing into death.
    if (is_jumping) {
        static float swimsound_next;
        if (waterlevel >= 2) {
           if (time > swimsound_next) {
               swimsound_next = time + 1;
               localsound(random() < 0.5 ? "player/water1.wav" : "player/water2.wav",
                          CHAN_BODY, 1);
           }
        } else if (is_jumpframe) {
            // The default pmove implementation and server behave slightly
            // differently here in two important ways here:
            // 1) Jump calculations run _prior_ to movement rather than post,
            //    meaning you can test for jumping and onground directly.  We
            //    get around this by just using prior frame's onground.
            // 2) Something (probably airstep) masks on-grounds that get
            //    skipped, which otherwise results in false jumps moving up
            //    stairs when combined with (1).  We can test for this by
            //    watching to see whether we actually got a sufficiently large
            //    velocity increase.
            localsound("player/plyrjmp8.wav", CHAN_AUTO, CVARF(fo_jumpvolume));
        }
    }

    if (waterlevel > 0 && last_waterlevel == 0) {  // Water entry.
        string sound = "";
        switch(fluidtype) {
            case CONTENT_LAVA: sound = "player/inlava.wav"; break;
            case CONTENT_WATER: sound = "player/inh2o.wav"; break;
            case CONTENT_SLIME: sound = "player/slimbrn2.wav"; break;
        }
        localsound(sound, CHAN_BODY, 1);
    } else if (waterlevel == 0 && last_waterlevel > 0) {  // Water exit.
        localsound("misc/outwater.wav", CHAN_BODY, 1);
    }

    last_waterlevel = waterlevel;
}

// Some versions of FTE do not correctly update pmove_vel (although other state,
// e.g. PM_Org() is).  Until we're directly tied to pmove, we snoop on recent
// values when we think this is happening.
float recent_pmove_vel_z;

void PM_PredictJump_Engine() {
    if (!CSQC_JumpSounds_Active() || getstatf(STAT_PAUSED))
        return;

    if (PM_Enabled())  // Handled by PredictJump_Pmove
        return;

    static float last_onground, last_vel_z;

    float jumping = input_buttons & BUTTON2;
    float onground = pmove_onground; //pmove_onground;
    float landing = (onground && !last_onground);
    float vel_z = pmove_vel_z ?: recent_pmove_vel_z;

    if (!game_state.is_alive) {
        last_onground = 1;
        last_vel_z = 0;
        return;
    }

    float is_jump = last_onground && !onground && vel_z > last_vel_z + 200;

    PM_Sounds(jumping, is_jump, landing, last_vel_z);

    last_vel_z = vel_z;
    last_onground = onground;
};

////////////////////////////////////////////////////////////////////////////////
// Pmove
////////////////////////////////////////////////////////////////////////////////

enum {
    SERVER,
    PMOVE,
    ERROR_POS,
    ERROR_VEL,
    ERROR_VIEW,
    NUM_DBG_GRAPH_TYPES,
};

DEFCVAR_FLOAT(fo_smartjump, 1);

DEFCVAR_FLOAT(fopm_noerror, 0);
DEFCVAR_FLOAT(fopm_nocache, 0);
DEFCVAR_FLOAT(fopm_nostep, 0);
DEFCVAR_FLOAT(fopm_nonudge, 0);
DEFCVAR_FLOAT(fopm_errortime, 0);
DEFCVAR_FLOAT(fopm_debug, 0);

DEFCVAR_FLOAT(fopmd_graph_x, -10);
DEFCVAR_FLOAT(fopmd_graph_y, 100);
DEFCVAR_FLOAT(fopmd_graph_w, 200);
DEFCVAR_FLOAT(fopmd_graph_h, 100);

DEFCVAR_FLOAT(v_viewheight, 0);

enumflags {
    PMDG_ON,              //  1 for laziness..
    PMDG_NO_ALIGN_INTERP, //  2
    PMDG_ERROR_VEL,       //  4
    PMDG_ERROR_POS,       //  8
    PMDG_ERROR_VIEW,      // 16
};
DEFCVAR_FLOAT(fopmd_graph, 0);

static const float NHIST = 21;
struct PM_History {
    vector org, vel;
    float seq;
};
static PM_History hist[NHIST];

void PMH_Log(float seq) {
    PM_History* pmh = &hist[seq % NHIST];
    pmh->org = PM_Org();
    pmh->vel = PM_Vel();
    pmh->seq = seq;
}

PM_History* PMH_Get(float seq) {
    PM_History* pmh = &hist[seq % NHIST];
    return pmh->seq == seq ? pmh : 0;
}

void PM_Init() {
    pm.ent = spawn();
    pm.ent.solid = SOLID_NOT;
    setsize(pm.ent, '-16 -16 -24', '16 16 32');
}

// Should be invoked immediately after RunMovement() to ensure correctness of
// `seq` versus state.  On server packets we manually set `seq` to sf + 1.
static void PM_SavePMS(PMS_Data *pmsd) {
    entity ent = pm.ent;
    pmsd->org = ent.origin;
    pmsd->vel = ent.velocity;

    pmsd->seq = pm.seq;
    pmsd->server_seq = pm.server_seq;
    pmsd->interp_t = pm.interp_t;
}

static void PM_ActivatePMS(PMS_Data *pmsd) {
    entity ent = pm.ent;
    ent.origin = pmsd->org;
    ent.velocity = pmsd->vel;

    pm.seq = pmsd->seq;
    pm.server_seq = pmsd->server_seq;
    pm.interp_t = pmsd->interp_t;
    pm.active_pmsd = pmsd;

    pm.ent.pmove_flags = 0;  // With auto-bunny we only care about clearing
};

static float cache_invalidated;
static PMS_Data* SimPMSD() {
    return (cache_invalidated || CVARF(fopm_nocache)) ? &pm_s : &pm_c;
}

void PM_InputFrame();

enum {
    NT_EMPTY,
    NT_CONC,
    NT_DASH,
    NT_EXPLOSION,
    NT_BOUNCE,
};

enum {
    NA_NONE,
    NA_SEQ,
    NA_SEQTIME,
    NA_ITIME,
    NA_ITIME_EXPLICIT_EXPIRE,
};

struct PM_Nudge {
    float type;

    entity src;
    float src_no;

    float nat, seq, itime;
    float expire_frame, expire_time, expire_spawnseq;

    vector org;
    float aux;
};

const static float NUDGE_SEQ = 3;
const static float NUDGE_EPS = NUDGE_SEQ * SERVER_FRAME_DT;
static PM_Nudge nudges[8];
static float num_nudges;

static float nudge_expired(PM_Nudge* n) {
    if (n->expire_frame && n->expire_frame <= pstate_server.seq)
        return TRUE;

    if (n->expire_time && n->expire_time <= pstate_server.server_time)
        return TRUE;

    if (n->expire_spawnseq && n->expire_spawnseq != game_state.spawn_gen)
        return TRUE;

    switch (n->nat) {
        case NA_NONE: return TRUE;
        case NA_SEQ: return n->seq + NUDGE_SEQ <= pstate_server.seq;
        case NA_SEQTIME:
            return n->seq + ceil(n->itime / SERVER_FRAME_DT) + NUDGE_SEQ <= pstate_server.seq;
        case NA_ITIME: return n->itime + NUDGE_EPS <= pstate_server.server_time;  // Slack
        case NA_ITIME_EXPLICIT_EXPIRE: return FALSE;  // TRUE handled above
    }

    return TRUE;
}

static PM_Nudge* find_nudge_slot() {
    for (float i = 0; i < nudges.length; i++) {
        PM_Nudge* n = &nudges[(num_nudges++) % nudges.length];

        if (!nudge_expired(n))
            continue;

        cache_invalidated = TRUE;
        n->nat = NA_NONE;
        n->src_no = 0;
        n->src = 0;
        n->expire_frame = 0;
        n->expire_time = 0;
        n->expire_spawnseq = 0;
        return n;
    }

    if (CVARF(fopm_debug))
        printf("ERROR: no nudge slots!\n");
    return 0;
}

.PM_Nudge* nudge;

static void PM_RemoveSelfNudges() {
    if (!self.nudge)
        return;

    PM_Nudge* n = self.nudge;
    n->expire_frame = servercommandframe;
}

void PM_AddNudgeConc(float itime, float mag, float flip) {
    // This is kind of painful but not much easier..
    static float filter_itime;
    if (itime <= filter_itime)
        return;
    filter_itime = itime;

    PM_Nudge* n = find_nudge_slot();
    if (!n)
        return;

    n->type = NT_CONC;
    n->nat = NA_ITIME_EXPLICIT_EXPIRE;
    n->expire_time = itime;
    n->expire_spawnseq = game_state.spawn_gen;

    n->itime = itime;
    n->org.x = mag;
    n->org.y = flip;
}

static void PM_NudgeConc(PM_Nudge* nudge, entity ent) {
    if (pointcontents(ent.origin) == CONTENT_WATER)
        ent.flags |= FL_INWATER;  // pmove doesn't usually maintain this.
    Conc_Stumble(ent, nudge->org.x, nudge->org.y);
}

static void PM_NudgeDash(PM_Nudge* nudge, entity ent) {
    ent.velocity = nudge->org;
}

void PM_AddNudgeDash(float cseq) {
    PM_Nudge* n = find_nudge_slot();
    if (!n)
        return;
    n->type = NT_DASH;
    n->nat = NA_SEQ;
    n->seq = cseq;

    n->org = v_forward * 540;
    n->org.z = 181;
}

float nudge_i(PM_Nudge* n) {
    for (float i = 0; i < nudges.length; i++)
        if (&nudges[i] == n)
            return i;
    return -1;
}

static void PM_NudgeExplosion(PM_Nudge* nudge, entity ent) {
    float dmg = nudge->aux;
    if (vlen(ent.origin - nudge->org) > dmg + 40)
        return;

    const float MOVE_WORLDONLY = 3;
    traceline(ent.origin, nudge->org, MOVE_WORLDONLY, pm.ent);
    if (trace_fraction < 1)  // No knock from occluded explosions
        return;

    float flg = KF_BOTH_PLAYER;  // Assumes everything is from a player for now
    if (nudge->src.owner == pengine.player_ent)
       flg |= KF_SELF;

    dmg = CalcRadiusDamage(nudge->org, ent, flg, dmg);
    if (flg & KF_SRC_PLAYER)
        dmg *= 0.9;
    dmg = Class_ScaleMoment(WP_PlayerClass(), dmg);
    vector knock = CalcKnock(nudge->org, ent, flg, dmg);

    pm.ent.velocity += knock;
}

// Can be either by {seq + itime} for predicted projectiles, or by {itime} for
// server projectiles.
static PM_Nudge* PM_AddNudgeExplosion(float nat, float seq, float itime, entity ent, float dmg) {
    if (vlen(PM_Org() - ent.origin) > dmg * 3)  // Fine tune this..
        return 0;

    PM_Nudge* n = find_nudge_slot();
    if (!n)
        return 0;

    n->type = NT_EXPLOSION;
    n->nat = nat;
    n->seq = seq;
    n->itime = itime;

    // This is slightly imprecise, since you could throw a grenade then spawn
    // and jump on it, but it's more right than wrong; and the wrong cases lead
    // to false lerps.
    if (ent.owner == pengine.player_ent)
        n->expire_spawnseq = game_state.spawn_gen;

    n->org = ent.origin;  // We end up mostly using the ent here
    n->aux = dmg;

    n->src = ent;
    n->src_no = ent.entnum;

    ent.nudge = n;
    ent.removefunc = PM_RemoveSelfNudges;

    return n;
}

static void PM_AddNudgeBounce(float itime, entity ent, float dmg) {
    if (vlen(PM_Org() - ent.origin) > dmg * 3)  // Fine tune this..
        return;

    PM_Nudge* n = find_nudge_slot();
    if (!n)
        return;

    n->type = NT_BOUNCE;
    n->nat = NA_ITIME;
    n->itime = itime;

    n->org = ent.origin;
    n->aux = dmg;

    n->src = ent;
    n->src_no = ent.entnum;

    ent.nudge = n;
    ent.removefunc = PM_RemoveSelfNudges;
}

static void PM_NudgeBounce(PM_Nudge* nudge, entity ent) {
    float dmg = nudge->aux;

    if (vlen(ent.origin - nudge->org) > dmg + 40)
        return;

    vector targ_org = ent.origin + (ent.mins + ent.maxs) * 0.5;
    float points = dmg - vlen(targ_org - nudge->org) / 2;

    ent.velocity = (targ_org - nudge->org) * points/20;

    NB_ConcCapAction(ent, pstate_pred.playerclass, &pstate_pred.tfstate,
                     pm.interp_t, &pstate_pred.conc_cap_time, kLaunch);
}


void PM_AddGrenadeExplosion(float itime, entity ent) {
    if (!PM_Enabled())
        return;

    FO_GrenExp exp;
    if (!FO_GrenGetExp(ent.fpp.gren_type, exp))
        return;

    float dmg = exp.dmg;

    PM_Nudge* n;
    if (exp.type == kRadiusDamage)
        PM_AddNudgeExplosion(NA_ITIME, 0, itime, ent, dmg);
    else
        PM_AddNudgeBounce(itime, ent, dmg);
}

void PM_AddSimExplosion(float itime, entity ent) {
    if (!PM_Enabled())
        return;

    if ((CVARF(fo_beta_nudge_explosion) & 2 == 0) &&
            ent.owner != pengine.player_ent)
        return;

    float dmg = 0;
    switch (ent.fpp.index) {
        case FPP_ROCKET:
        case FPP_INCENDIARY:
            dmg = 92;
            break;
        default:
            return;  // Not recognized
    }

    float seq = 0, nat = NA_ITIME;
    if (ent.forward_knock && ent.owner == pengine.player_ent) {
        if (ent.forward_knock == -1)
            return;
        nat = NA_ITIME_EXPLICIT_EXPIRE;  // Knock forwards are synchronized
        itime = ent.forward_knock;
    } else if (ent.created_seq && ent.entnum == 0) {
        float dtime = 0;
        if (ent.s_time)
            dtime = max(itime - ent.s_time, 0);
        seq = ent.created_seq;
        itime = dtime;
        nat = NA_SEQTIME;  // Same as NA_SEQ when itime == 0
    }

    PM_AddNudgeExplosion(nat, seq, itime, ent, dmg);
}

float MatchNudge(PM_Nudge* n, float seq, float sitime, float eitime, float slack = 0) {
    if (nudge_expired(n))
        return FALSE;

    switch (n->nat) {
        case NA_SEQ: return seq == n->seq;
        case NA_SEQTIME: return seq == n->seq + floor(n->itime / SERVER_FRAME_DT);
        case NA_ITIME_EXPLICIT_EXPIRE: return n->itime > sitime && n->itime <= eitime;
        case NA_ITIME: return (n->itime > sitime - slack) && (n->itime <= eitime);
        default:
            return FALSE;
    }
}

// TODO: This obviously wants to be smarter
static void PM_ApplyNudges(entity ent, float seq, float sitime, float eitime, float slack = 0) {
    for (float i = 0; i < nudges.length; i++) {
        PM_Nudge* n = &nudges[i];

        if (!MatchNudge(n, seq, sitime, eitime, slack))
            continue;

        pm.last_nudge = seq;
        switch (n->type) {
            case NT_CONC:
                PM_NudgeConc(n, ent);
                break;
            case NT_DASH:
                PM_NudgeDash(n, ent);
                break;
            case NT_EXPLOSION:
                PM_NudgeExplosion(n, ent);
                break;
            case NT_BOUNCE:
                PM_NudgeBounce(n, ent);
                break;
        }
    }
}

static void RunPlayerPhysics() {
    entity ent = pm.ent;

    pm.last_vel_z = ent.velocity_z;
    runstandardplayerphysics(ent);
}

static void RunDeadMovement(float endframe) {
    entity ent = pm.ent;
    float held_movetype = ent.movetype;
    float held_solid = ent.solid;
    float held_buttons = input_buttons;
    vector held_movevalues = input_movevalues;

    ent.movetype = MOVETYPE_TOSS;
    ent.solid = SOLID_NOT;
    input_buttons = 0;
    input_movevalues = '0 0 0';
    while (pm.seq <= endframe) {
        runstandardplayerphysics(ent);
        pm.seq++;
    }

    ent.movetype = held_movetype;
    ent.solid = held_solid;
    input_buttons = held_buttons;
    input_movevalues = held_movevalues;
}

// End state:
//   pmsd.seq --> endframe + 1
static void PM_RunMovement(PMS_Data* pmsd, float endframe) {
    entity ent = pm.ent;

    if (pm.active_pmsd != pmsd || pm.seq > endframe) {
        ASSERTF_GT(endframe, pm.server_seq);
        PM_ActivatePMS(pmsd);
    }

    if (!game_state.is_spectator && !game_state.is_alive) {
        RunDeadMovement(endframe);
        return;
    }

    ASSERTF_GT(pm.seq, 0);

    pm.ent.pmove_flags = 0;  // With auto-bunny we only care about clearing
    while (pm.seq <= endframe) {
        if (!getinputstate(pm.seq))
            break;

        // We have to apply this on the leading edge since INPUT_FRAME
        // modifications do not occur until the frame is finalized.
        if (pm.seq == clientcommandframe)
            PM_InputFrame();

        RunPlayerPhysics();

        if (!CVARF(fopm_nonudge)) {
            float slack = (pm.seq == pm.server_seq + 1) ? NUDGE_EPS : 0;
            PM_ApplyNudges(ent, pm.seq, pm.interp_t, pm.interp_t + input_timelength, slack);

            if ((ent.pmove_flags & PMF_JUMP_HELD) && (pstate_pred.tfstate & TFSTATE_CONC))
                Conc_Jump(&pstate_pred.conc_state, ent);

            if ((ent.pmove_flags & PMF_JUMP_HELD) && (pstate_pred.tfstate & TFSTATE_CONC_CAP)) {
                NB_ConcCapAction(ent, pstate_pred.playerclass, &pstate_pred.tfstate,
                                 pm.interp_t, &pstate_pred.conc_cap_time,
                                 kLand);
            }
        }

        pm.seq++;
        pm.interp_t += input_timelength;
    }

    // Add in anything that was applied after (for low packet rate protocols)
    input_angles = view_angles;
}

static void PM_SetEnabled(float enabled) {
    pengine.pm_enabled = enabled;

    PM_Refresh();

    if (!enabled)
        return;

    pm.errortime = pm.steptime  = 0;
    pm.step_oldz = pm.ent.origin_z;
}

static float ErrorTime() {
    static float kDefault = 25 * MSEC;
    static float kMax = 50 * MSEC;

    if (!CVARF(fopm_errortime))
        return kDefault;

    return min(CVARF(fopm_errortime), kMax);
}

static void PM_UpdateError() {
    entity ent = pm.ent;

    ent.owner = edict_num(player_localentnum);
    if (CVARF(fopm_noerror) || !game_state.is_alive ||
        (clientcommandframe == servercommandframe + 1)) {
        pm.error = '0 0 0';
        pm.errortime = 0;
        return;
    }

    static PMS_Data last;
    if (last.server_seq != pm_s.server_seq - 1)
        last = pm_so;

    // Run prior prediction to present.
    PM_RunMovement(&last, clientcommandframe);
    vector err = ent.origin;

    // Repeat with updated state.
    PM_RunMovement(SimPMSD(), clientcommandframe - 2);
    PM_SavePMS(&last);  // Save at -2 to replay nudges going into -1
    PM_RunMovement(SimPMSD(), clientcommandframe);

    // New nudges can result in small errors on replay due to timeshift, we
    // could backdate all the nudges and recompute the world but as a first
    // simpler pass let's just filter them out.
    if (pm.last_nudge == clientcommandframe - 1)
        err = '0 0 0';
    else
        err -= ent.origin;

    float nerr = vlen(err);
    if (nerr > 64) {  // teleport
        pm.error = '0 0 0';
        pm.errortime = 0;
    } else { // figure out the error amount, and add it to accumulated lerp
        pm.error *= max(pm.errortime - time, 0) / ErrorTime();
        pm.error += err;

        if (vlen(pm.error) > 1) {
            pm.errortime = time + ErrorTime();
        } else {
            pm.error = '0 0 0';
            pm.errortime = 0;
        }
    }
}

DEFCVAR_FLOAT(v_deathtilt, 1);

static void PM_UpdateLocalMovement() {
    entity ent = pm.ent;

    if (game_state.is_ceasefire || clientcommandframe > servercommandframe + 63) {
        PM_ActivatePMS(&pm_s);
    } else {
        PM_RunMovement(SimPMSD(), clientcommandframe);
    }

    vector org = pm.ent.origin;

    // Smooth stair stepping
    if (org_z > pm.step_oldz + 8 && org_z < pm.step_oldz + 24 &&
        ent.velocity_z == 0) { // Evaluate out the remaining old step
        if (pm.steptime - time > 0)
            pm.step = (pm.steptime - time) * (1 / STEPTIME) * pm.step;
        else
            pm.step = 0;

        // Work out the new step
        pm.step += (pm.step_oldz - org_z);
        pm.steptime = time + STEPTIME;
    }
    pm.step_oldz = org_z;

    float viewheight = CVARF(v_viewheight);
    if (viewheight < -7)
        viewheight = -7;
    else if (viewheight > 7)
        viewheight = 7;

    pm.vieworg = org;
    pm.vieworg.z += getstatf(STAT_VIEWHEIGHT) + viewheight;

    if (!game_state.is_alive && WP_PlayerClass())
        view_angles.z = CVARF(v_deathtilt) * 80;

    // Correct view position over ErrorTime()
    if (pm.errortime - time > 0)
        pm.vieworg += (pm.errortime - time) * (1 / ErrorTime()) * pm.error;

    if (!CVARF(fopm_nostep))
        if (pm.steptime - time > 0)
            pm.vieworg.z += (pm.steptime - time) * (1 / STEPTIME) * pm.step;
}

void PMD_UpdateImpulse(int seq);

void PM_SyncTo(float seq) {
    if (!PM_Enabled())
        return;

    if (!game_state.is_alive)
        return;

    entity ent = pm.ent;
    PM_RunMovement(SimPMSD(), seq);

    // Note: ~FL_ONGROUND and jump occur in same frame, produces JUMP_HELD
    float jumping = input_buttons & BUTTON2;
    float landing = pm.last_vel_z < 0 && (ent.flags & FL_ONGROUND);
    float jump_frame = ent.pmove_flags & PMF_JUMP_HELD;

    PM_Sounds(jumping, jump_frame, landing, pm.last_vel_z);
}

static void PM_HandleRemovedNudges() {
    if (!pstate_server.num_filter_ents)
        return;

    float c = 0;
    for (float i = 0; i < nudges.length; i++) {
        PM_Nudge* n = &nudges[i];
        if (nudge_expired(n))
            continue;

        if (n->type == NT_CONC && n->itime < pstate_server.conc_state.next) {
            n->expire_frame = -1;
            continue;
        }

        for (float j = 0; j < pstate_server.num_filter_ents; j++) {
            if (n->src_no == pstate_server.filter_ents[j]) {
                n->nat = NA_SEQ;
                n->seq = n->expire_frame = pstate_server.seq;
            }
        }
    }
}

void PM_Update(float sendflags) {
    float was_enabled = PM_Enabled();
    float enabled = (pstate_server.predict_flags & PF_PMOVE) &&
                    game_state.is_player;

    if (isdemo())
        enabled = 0;

    if (enabled != was_enabled ||
        game_state.is_player != prev_game_state.is_player)
        PM_SetEnabled(enabled);

    if (sendflags & FOWP_PMOVE == 0)
        return;

    PM_HandleRemovedNudges();

    pm_so = pm_s;
    pm.server_seq = servercommandframe;
    pm.seq = servercommandframe + 1;  // server state includes move
    pm.interp_t = pstate_server.server_time;
    PM_SavePMS(&pm_s);

    if (!CVARF(fopm_nocache)) {
        // clientcommandframe) so that we can accelerate the common case of
        // computation at clientcommandframe (which does require constant
        // re-evaluation).  In the case there's no separation (e.g. lan pings)
        // then the server frame is directly used as the cache frame.
        if (clientcommandframe > servercommandframe + 1)
            PM_RunMovement(&pm_s, clientcommandframe - 1);
        PM_SavePMS(&pm_c);
        cache_invalidated = FALSE;
    }

    if (enabled && was_enabled)
        PM_UpdateError();
    PMD_UpdateImpulse(servercommandframe);
}

void PM_Refresh() {
    if (!PM_Enabled())
        return;

    entity ent = pm.ent;
    if (game_state.is_player) {
        ent.owner = edict_num(player_localentnum);
        ent.movetype = MOVETYPE_WALK;
        ent.solid = SOLID_SLIDEBOX;
    } else {
        ent.owner = world;  // Needs more than this for spec..
        ent.movetype = MOVETYPE_NOCLIP;
        ent.solid = SOLID_NOT;
    }
}

DEFCVAR_FLOAT(cl_upspeed, 400);
void PM_InputFrame() {
    float iz = input_movevalues.z;
    input_movevalues.z = 0;

    float max_speed = isdemo() ? SPEC_MAXSPEED : pstate_pred.csqc_maxspeed;

#if 0  // Quick fix
    // cl_smartjump replacement
    float type;
    if (input_buttons & BUTTON2) {
        if ((game_state.is_player && CVARF(fo_smartjump) &&
            (PM_GetWaterLevel(PM_Org(), &type) >= 2))
              || game_state.is_spectator) {
            input_buttons &= ~BUTTON2;
            iz = min(CVARF(cl_upspeed), Class_MaxSpeed(WP_PlayerClass()));
        }
    }
#endif
    if (input_buttons & BUTTON2) {
        if (game_state.is_spectator) {
            input_buttons &= ~BUTTON2;
            iz = CVARF(cl_upspeed);
        }
    }

    // Technically the sync with pstate_pred being on the right frame is loose..
    if (pstate_pred.tfstate & TFSTATE_AIMING)
        max_speed = 80;

    if (vlen(input_movevalues) > max_speed)
        input_movevalues = normalize(input_movevalues) * max_speed;
    if (iz)
        input_movevalues.z = min(max_speed, input_movevalues.z + iz);
}

////////////////////////////////////////////////////////////////////////////////
// View/Render
////////////////////////////////////////////////////////////////////////////////

DEFCVAR_STRING(r_brightlight_colour, "2.0 1.0 0.5 400");
DEFCVAR_STRING(r_dimlight_colour, "2.0 1.0 0.5 200");
DEFCVAR_STRING(r_redlight_colour, "3.0 0.5 0.5 200");
DEFCVAR_STRING(r_bluelight_colour, "0.5 0.5 3.0 200");
veci brightlight_l, dimlight_l, redlight_l, bluelight_l;

static void ParseCvars() {
    static float next_refresh;

    if (time < next_refresh)
        return;
    next_refresh = time + 0.5;

    cvar_parse4(CVARS(r_brightlight_colour), brightlight_l);
    cvar_parse4(CVARS(r_dimlight_colour), dimlight_l);
    cvar_parse4(CVARS(r_redlight_colour), redlight_l);
    cvar_parse4(CVARS(r_bluelight_colour), bluelight_l);
}

#define MUX_IN(ef, bit, src) \
    do { if ((ef) & (bit)) { rad = max(rad, src.i); col += src.v; } } while (0)

void LocalEffects(float effects, vector org) {
    float rad = 0;
    vector col = '0 0 0';

    const float MASK_ALL = EF_BRIGHTLIGHT | EF_DIMLIGHT | EF_RED | EF_BLUE;

    if (effects & MASK_ALL == 0)
        return;

    ParseCvars();

    MUX_IN(effects, EF_BRIGHTLIGHT, brightlight_l);
    MUX_IN(effects, EF_DIMLIGHT, dimlight_l);
    MUX_IN(effects, EF_RED, redlight_l);
    MUX_IN(effects, EF_BLUE, bluelight_l);

    rad = min(rad, 400);
    dynamiclight_add(org, rad, col, 0, "", 0);
}
#undef MUX_IN

void PM_UpdateView() {
    PM_UpdateLocalMovement();
    setviewprop(VF_ORIGIN, pm.vieworg);
    setviewprop(VF_ANGLES, view_angles);

    makevectors(view_angles);
    SetListener(pm.vieworg, v_forward, v_right, v_up);

    LocalEffects(pstate_server.effects, pm.vieworg);
}

////////////////////////////////////////////////////////////////////////////////
// Debug
////////////////////////////////////////////////////////////////////////////////

static const float NIMP = 300;
struct PmoveDebug {
    float points[NIMP];
    int nimp;
};

static PmoveDebug pmd[NUM_DBG_GRAPH_TYPES];

static void PMD_AddPoint(int ptype, float val) {
    PmoveDebug* pd = &pmd[ptype];

    pd->points[pd->nimp++ % NIMP] = val;
}

static void PMD_UpdateImpulse(int seq) {
    if (!CVARF(fopmd_graph))
        return;

    static int old_seq;
    if (old_seq == seq)
        return;
    old_seq = seq;

    float cseq = clientcommandframe;
    if (PM_Enabled())
        PM_RunMovement(SimPMSD(), cseq);

    PMH_Log(cseq);

    vector sv = pm_s.vel;
    vector pv = PM_Vel();

    if (!vlen(pv) && !vlen(sv))
        return;

    PMD_AddPoint(SERVER, vlen(sv));
    PMD_AddPoint(PMOVE,  vlen(pv));

    PMD_AddPoint(ERROR_VIEW, vlen(pm.error) / 128 * 1200);

    PM_History* hist = PMH_Get(servercommandframe);
    if (!hist)
        return;

    PMD_AddPoint(ERROR_POS, hist ? vlen(pm_s.org - hist.org) : 0);
    PMD_AddPoint(ERROR_VEL, hist ? vlen(pm_s.vel - hist.vel) : 0);
}

static void PMD_Graph(int type, int offset, vector c1, vector c2, vector rgb) {
    PmoveDebug* pd = &pmd[type];
    float wx = c2.x - c1.x, wy = c2.y - c1.y;

    float maxv = pd->points[0], minv = pd->points[0];
    for (int i = 1; i < NIMP; i++) {
        maxv = max(maxv, pd->points[i]);
        minv = min(minv, pd->points[i]);
    }

    float h = max(maxv - minv, 1200);

    float px = wx / NIMP, py = (wy - 2) / h;
    vector lend = c1 + [0, wy, 0];

    vector m1 = [0, wy - maxv * py, 0];
    drawline(1, c1 + m1, c1 + m1 + [wx, 0, 0], '50 150 150', 1);

    for (int i = offset; i < NIMP; i++) {
        int idx = (pd->nimp + i) % NIMP;
        vector sx =
            [c1.x + (i - offset) * px, c2.y - (pd->points[idx]) * py + 1, 0];
        vector sy = [sx.x + px, sx.y, 0];

        drawline(1, sx, sy, rgb, 1);
        drawline(1, lend, sx, rgb, 1);
        lend = sy;
    }
}

void PMD_DrawGraphs(float width) {
    float pmove_on = pstate_server.predict_flags & PF_PMOVE;
    if (pmove_on)
        drawstring([width - 100, 20, 0], sprintf("PM err: %0.1f", vlen(pm.error)),
                   '8 8 0', '1 1 1', 1, 0);

    if (!CVARF(fopmd_graph))
        return;

    vector c1 = [CVARF(fopmd_graph_x), CVARF(fopmd_graph_y), 0];
    if (c1.x < 0)
        c1.x += width - CVARF(fopmd_graph_w);
    vector w =  [CVARF(fopmd_graph_w), CVARF(fopmd_graph_h), 0];
    vector c2 = c1 + w;

    drawfill(c1, w, '0.2 0.2 0.2', 1);
    drawfill(c2, '5 5 5', '1 0 0', 1);

    float offset = (CVARF(fopmd_graph) & PMDG_NO_ALIGN_INTERP) ? 0 :
        clientcommandframe - servercommandframe - 1;

    offset = max(0, offset);
    PMD_Graph(PMOVE, 0, c1, c2, '0 0 1');
    PMD_Graph(SERVER, offset, c1, c2, '0 1 0');

    if ((CVARF(fopmd_graph) & PMDG_ERROR_VIEW) &&
            (pstate_server.predict_flags & PF_PMOVE))
        PMD_Graph(ERROR_VIEW, 0, c1, c2, '1 0 1');
    if ((CVARF(fopmd_graph) & PMDG_ERROR_VEL))
        PMD_Graph(ERROR_VEL, 0, c1, c2, '1 1 0');
    if ((CVARF(fopmd_graph) & PMDG_ERROR_POS))
        PMD_Graph(ERROR_POS, 0, c1, c2, '1 0 0');

}
