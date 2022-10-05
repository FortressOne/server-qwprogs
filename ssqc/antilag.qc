float (string ps_short, string ps_setting, string ps_default) CF_GetSetting;

void AL_ProjectProjectile (entity projectile) {
      // Project projectiles forward in time based on ping up to configurable maximum (default 100ms).    
      // Effective projection time is maximum / 2 (eg 50ms), because we assume RTT is evenly distributed in both
      // directions - and we want the server to spawn the entity in the position it would have
      // have been if it had received the message (player_ping / 2) ago. 
      local float player_ping_s = infokeyf(self, INFOKEY_P_PING) / 1000;
      
      if (player_ping_s > project_weapons_max_latency) {
          player_ping_s = project_weapons_max_latency;
      } else if (player_ping_s <= 0.0013) { // Ping 13ms or lower? Don't do anything
          return;
      }
              
      local float time_offset = (player_ping_s / 2);
      local vector projected_origin = projectile.origin + (projectile.velocity * time_offset);

      // Rewind projectile is preferable but unavailable. This would rewind and replay the projectile from origin
      // to the projected origin. Since it isn't available, we will use a traceline, without MOVE_LAGGED
      // because by tracing between old origin and projected origin we effectively have a single (last) frame 
      // rewind at the projected origin. The effect is high ping players are disadvantaged in close combat.
      // This is preferable to unhappy low ping players.
      traceline(projectile.origin, projected_origin, 0, self);

      if (trace_fraction < 1) {
          projected_origin = trace_endpos;
      }

      setorigin(projectile, projected_origin);
}

float AL_GrenadeOffset() {
    if (!project_grenades)
        return 0;

    local float offset = infokeyf(self, INFOKEY_P_PING) / 1000;
    local float smallest_grenade_think = 0.5;

    offset /= 2;
    // Make sure we'll always order before first think.
    offset = min(offset, smallest_grenade_think - 0.1);

    // Don't allow prime to move before throw (or to the same frame).
    offset = min(offset, time - (self.last_throw + 0.013));

    return offset;
}

#define DEBUG_ANTILAG 0

#if DEBUG_ANTILAG
#define printf(...) sprint(self, PRINT_HIGH, sprintf(__VA_ARGS__))
#define printd(...) dprint(sprintf(__VA_ARGS__))
#else
#define printf(...)
#define printd(...)
#endif

#define AL_MAX_REWINDS 25
#define AL_FRAME_LIMIT (1/77.0)

struct RewindSnapshot {
    float time;
    vector origin;
    vector velocity;
};

struct RewindState {
    entity owner;
    RewindSnapshot snapshot[AL_MAX_REWINDS];

    float rewound;
    vector tmp_origin;
    vector tmp_velocity;
    RewindSnapshot* rewound_from;

    float cursor;
    float cursor_limit;

    float allocated;
    RewindState* next;
    RewindState* prev;
};

RewindState* rewind_players;

RewindState* AllocRewind(entity ent) {
    RewindState* state = memalloc(sizeof(RewindState));
    state.cursor = 0;
    state.cursor_limit = time + AL_FRAME_LIMIT;
    state.owner = ent;
    return state;
}

void FreeRewind(RewindState* h) {
    memfree(h);
}


void RL_Insert(RewindState** head, RewindState* node) {
    if (!*head) {
        node->next = node->prev = node;
        *head = node;
    } else {
        node->next = *head;
        node->prev = (*head)->prev;

        (node->next)->prev = (node->prev)->next = node;
    }
}

void RL_Remove(RewindState** head, RewindState* node) {
    if (*head == node) {
        *head = __NULL__;
    } else {
        (node->next)->prev = node->prev;
        (node->prev)->next = node->next;
    }
}

#define RL_FOR_EACH(_head, _var) \
    for (RewindState* _var = _head; _var;\
        _var = _var->next != head ? _var->next : __NULL__)

RewindSnapshot* RewindLog(RewindState* target) {
    if (target->owner != self)
        error("Log mismatch\n");

    if (time > target->cursor_limit) {
        target->cursor = (target->cursor + 1) % AL_MAX_REWINDS;
        target->cursor_limit = time + AL_FRAME_LIMIT;
    }

    RewindSnapshot* snapshot = &target->snapshot[target->cursor];
    snapshot->time = time;
    snapshot->origin = target->owner.origin;
    snapshot->velocity = target->owner.velocity;

    return snapshot;
}

struct SeekResult {
    RewindSnapshot *before;
    RewindSnapshot *after;
    RewindSnapshot *nearest;
};

inline float NextIndex(float pos) { return (pos + 1) % AL_MAX_REWINDS; }
inline float Index(float pos) { return (pos + AL_MAX_REWINDS) % AL_MAX_REWINDS; }
inline float PrevIndex(float pos) { return Index(pos - 1); }

void DumpPos(RewindState* target, float pos) {
    printd(" dump %d %0.2f\n", Index(pos), target->snapshot[Index(pos)].time);
}

SeekResult SeekBasic(RewindState* target, float when) {
    SeekResult r;
    float before = 0, after = time, nearest = when + 1;

    r.before = r.after = r.nearest = __NULL__;
    for (int i = 0; i < AL_MAX_REWINDS; i++) {
        RewindSnapshot* s = &target->snapshot[i];

        if (s->time && s->time > when && s->time < after) {
            after = s->time;
            r.after = s;
        }
        if (s->time && s->time < when && s->time > before) {
            before = s->time;
            r.before = s;
        }
    }

    if (fabs(when - before) < fabs(when - after))
        r.nearest = r.before;
    else
        r.nearest = r.after;

    return r;
}

#if 0
void CompareSeek(SeekResult s1, SeekResult, s2) {
    if (before != (r.before)->time)
        error(sprintf("before mismatch w=%f seek=%f check=%f\n",
                      when, (r.before)->time, before));
    if (after != (r.after)->time)
        error(sprintf("after mismatch w=%f seek=%f check=%f\n",
                      when, (r.after)->time, after));
    if (nearest != (r.nearest)->time)
        error(sprintf("nearest mismatch w=%f seek=%f check=%f\n",
                      when, (r.nearest)->time, nearest));
}


SeekResult SeekOpt(RewindState* target, float when) {
    SeekResult r;
    r.before = r.after = r.nearest = __NULL__;

    float probe = floor((time - when) / AL_FRAME_LIMIT);
    probe = max(probe - 3, 0);
    printd(" probe = %d -> %d, %d\n",
           probe, target->cursor, Index(target->cursor - probe));

    if (probe > AL_MAX_REWINDS || probe < 0)
        return r;

    probe = 0;  // Conservative/safe for now.
    float tmp = Index(target->cursor - probe);
    printd(" t = %d c = %f\n", tmp, target->cursor);
    while (target->snapshot[tmp].time > when) {
        RewindSnapshot* snap = &target->snapshot[tmp];

        r.after = &target->snapshot[tmp];
        printd(" %d >when %0.2f\n", tmp, (r.after)->time);
        tmp = PrevIndex(tmp);
    }
    printd(" %d middle %0.2f\n", tmp, target->snapshot[tmp].time);

    if (target->snapshot[tmp].time > 0) {
        r.before = &target->snapshot[tmp];
        printd(" %d <before %0.2f\n", tmp, (r.before)->time);
    }

    DumpPos(target, tmp - 1);
    DumpPos(target, tmp);
    DumpPos(target, tmp + 1);

    r.nearest = r.after;
    if (r.before && fabs((r.before)->time - when) < fabs((r.after)->time - when))
        r.nearest = r.before;
        tmp = NextIndex(tmp);

    SeekCheck(target, when, &r);
    return r;
}
#endif

SeekResult Seek(RewindState* target, float when) {
    SeekResult r;
    r.before = r.after = r.nearest = __NULL__;

    return SeekBasic(target, when);
}

// TODO: Filter out observers, but no harm immediately.
void RL_Rewind(RewindState* head, entity exclude, float when) {
    float show_rewind_points = CF_GetSetting("rds", "rewind_debug_show", "off");

    printd("REWIND START %p\n", head);
    RL_FOR_EACH(head, rs) {
        if (rs->owner == exclude ||
            when < rs->owner->spawn_time) {  // Don't rewind to past life.
            rs->rewound = 2;
            printd("rewind skipped %s\n", exclude.netname);
            continue;
        }

        printd("start %s, %f -> %f %d\n", rs->owner.netname, time, when,
                (time - when) / AL_FRAME_LIMIT);
        SeekResult seek = Seek(rs, when);
        RewindSnapshot* near = seek.nearest;
        if (near) {
            printd("trying to rewind %s to %f, found %f\n", rs->owner.netname,
                   when, near->time);
            if (rs->rewound == 1)
                error("ALREADY REWOUND");

            rs->rewound = TRUE;
            rs->tmp_origin = rs->owner.origin;
            rs->tmp_velocity = rs->owner.velocity;
            rs->owner.origin = near->origin;
            rs->owner.velocity = near->velocity;
            rs->rewound_from = near;

            if (show_rewind_points)
                pointparticles(particleeffectnum("fo_airblast"), near->origin);
        }
    }
    printd("REWIND END\n");
}

void RL_RestorePresent(RewindState* head) {
    RL_FOR_EACH(head, rs) {
        if (rs->rewound == 1) {
            printd("restoring %s\n", rs->owner.netname);

            rs->owner.origin = rs->tmp_origin;
            rs->owner.velocity = rs->tmp_velocity;
        } else {
            printd("restore skipped %s\n", rs->owner.netname);
        }

        rs->rewound = FALSE;
        rs->rewound_from = __NULL__;
    }
}


class FOPlayer {
    RewindState* rewind_;
    void() FOPlayer = {
        rewind_ = AllocRewind(this);
        RL_Insert(&rewind_players, rewind_);
    };

    virtual void() Destroy = {
        RL_Remove(&rewind_players, rewind_);

    };

    nonvirtual void() Respawn = {

    };

    nonvirtual void() RewindUpdate = {
        RewindLog(rewind_);
    };

    void(float when) RewindExcept = {
        RL_Rewind(rewind_players, this, when);
    };

    static void (float when) RewindAll = {
        RL_Rewind(rewind_players, world, when);
    };

    static void() RestoreAll {
        RL_RestorePresent(rewind_players);
    };

    void() RestoreNow = {
        if (rewind_->rewound == 1) {
            this.origin = rewind_->tmp_origin;
            this.velocity = rewind_->tmp_velocity;
            rewind_->rewound = 2;
        }
    };

    vector() TrueOrigin = {
        if (rewind_->rewound == 1) {
            return rewind_->tmp_origin;
        } else {
            return this->origin;
        }
    };
};

float AL_RewindPlayersExceptSelf(float farthest_rewind_point) {
    // Live changeagble for now.
    float project_detpipe = CF_GetSetting("pd", "project_detpipe", "on");
    // Want to lower this in time, but good for testing.
    float project_detpipe_max_lat =
        CF_GetSetting("pdml", "project_max_latency", "500") / 1000;

    if (!project_detpipe)
        return FALSE;

    project_detpipe_max_lat = min(project_detpipe_max_lat,
                                  ((AL_MAX_REWINDS - 1)* AL_FRAME_LIMIT) * 2);

    local float rtt = infokeyf(self, INFOKEY_P_PING) / 1000;
    rtt = min(rtt, project_detpipe_max_lat);

    if (rtt < 0.013)
        return FALSE;

    float rewind_to = max(farthest_rewind_point, time - rtt / 2);

    FOPlayer fop = (FOPlayer)self;
    fop.RewindExcept(rewind_to);
    return TRUE;
}

void UnrewindPlayer(entity p) {
    FOPlayer fop = (FOPlayer)p;
    fop.RestoreNow();
}
