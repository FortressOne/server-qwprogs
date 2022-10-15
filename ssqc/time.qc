float remote_client_time(float ct_type = CT_NOEXTERNALEFFECT) {
    float offset = self.client_ping;  // Already bounded by max_ping

    switch (ct_type) {
        case CT_SLOW_PROJECTILE:
            offset = min(offset, antilag_settings.max_projectile_slow_ping) / 2;
            break;
    }

    float target = self.client_time - offset;
    target = max(target, self.last_remote_client_time);  // prevent jitter
    self.last_remote_client_time = target;

    return target;
}

// Note: Delta has jitter of up to ~frame
inline float client_to_global_time(float ctime) {
    return time + (ctime - self.client_time);
}

// Ping corrected `time`.
float remote_time(float ct_type = CT_NOEXTERNALEFFECT) {
    return client_to_global_time(remote_client_time(ct_type));
}

void FO_CheckClientThink() {
    if (self.client_nextthink > 0 && self.client_time >= self.client_nextthink) {
        float held_client_time = self.client_time;

        self.client_time = self.client_nextthink;
        self.client_nextthink = 0;
        self.client_think();

        self.client_time = held_client_time;
    }
}

void FO_UpdateClientTime() {
    self.client_time += frametime;

    float ping = infokeyf(self, INFOKEY_P_PING) / 1000.0;
    self.client_ping = min(antilag_settings.max_ping, ping);
}