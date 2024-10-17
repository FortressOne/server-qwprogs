float PlaceSentry(entity sentry, vector builder_org) {
    tracebox(sentry.origin, sentry.mins, sentry.maxs, sentry.origin, MOVE_NORMAL, sentry);

    if (trace_inopen)
        return (1);

    local vector start = sentry.origin;
    start_z = builder_org_z + 64;

    tracebox(start, sentry.mins, sentry.maxs, sentry.origin, MOVE_NORMAL, sentry);

    if (trace_fraction < 1.0) {
        tracebox(trace_endpos, sentry.mins, sentry.maxs, trace_endpos, MOVE_NORMAL, sentry);

        if (trace_inopen) {
            sentry.origin = trace_endpos;
            return (1);
        }
    }

    return (0);
}
