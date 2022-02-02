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