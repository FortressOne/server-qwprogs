void (float tno, float scoretoadd) TeamFortress_TeamIncreaseScore;
void (float all) TeamFortress_TeamShowScores;
void () InitTrigger;
void FO_SetModel(entity e, string fomdl);

/* ====== Vote Ball ======= */

float() crandom;

void (vector o, float z) ball_kick = {

    local vector v;

    v_x = ((o_x * 1.65) + (random() * 20) );
    v_y = ((o_y * 1.65) + (random() * 20) );

    if (o_x < 0.000) {
        o_x = o_x * -1.000;
    }
    if (o_y < 0.000) {
        o_y = o_y * -1.000;
    }

    v_z = ((100 + (random() * 30))  + ((o_y + o_x) * 0.20) + (z * 2.5)  );


    self.flags = self.flags - ( self.flags & 512.000);
    self.velocity = v;

};

void (vector o) ball_fly = {
    local vector v;

    v_x = (o_x * 0.600) + (crandom() * 40);
    v_y = (o_y * 0.600) + (crandom() * 40);

    if (o_x < 0.000) {
        o_x = o_x * -1.000;
    }
    if (o_y < 0.000) {
        o_y = o_y * -1.000;
    }


    v_z = (140 + (crandom() * 40))  + ((o_y + o_x) * 0.20);

    self.flags = self.flags - ( self.flags & 512.000);
    self.velocity = v;
      

};

void () ball_touch = {
    if (self.watertype == CONTENT_LAVA) {
        /*self.velocity_x = 0;
        self.velocity_y = 100;
        self.velocity_z = 0;*/
        setorigin (self,self.oldorigin);
        return;
    }

    if (other.classname == "worldspawn") {
        return;
    }

    if (round_over) {
        return;
    }
    if (other.classname == "player") {
        self.oldenemy = other;
        ball_kick(other.velocity, (other.v_angle_x * -1.000));
        return;

    }
    self.oldenemy = other.owner;
    ball_fly(other.velocity);
    return;
};

void () ball_reset = {
   self.solid = 1.000;
   self.velocity = '0 0 0';
   self.origin = self.oldorigin;
   setorigin (self,self.origin);

   if ( !droptofloor () ) {
         dprint ("GoalItem (ball) fell out of level at ");
         dprint (vtos (self.origin));
         dprint ("\n");
         dremove (self);
         return ;
   }
};

void () item_ball = {
   self.solid = SOLID_TRIGGER;
   self.movetype = MOVETYPE_BOUNCE;
   //self.flags= FL_ITEM;

   if ( self.mdl ) {
      precache_model (self.mdl);
      precache_model2 (self.mdl);
      FO_SetModel (self,self.mdl);
   } else {
      self.mdl = "progs/lavaball.mdl";
      FO_SetModel (self,self.mdl);
   }

   if ( !self.netname ) {
      self.netname = "ball";
   }
   
   if ( (self.goal_min == '0 0 0') ) {
      self.goal_min = '-12 -12 -12';
   }
   if ( (self.goal_max == '0 0 0') ) {
      self.goal_max = '12 12 12';
   }
   setsize (self,self.goal_min,self.goal_max);

   //setsize (self,'-0 -0 -0','24 24 24');
   setorigin (self,self.origin);
   self.oldorigin = self.origin;
   self.touch = ball_touch;
};

void () soccer_goal_touch = {
   if (round_over)  return;

   if (cb_prematch) return;

     if (other.classname == "item_ball") {
        if (other.solid) {
           TeamFortress_TeamIncreaseScore (self.owned_by,self.count);
           TeamFortress_TeamShowScores (2);
           sound (self,FL_ITEM,self.noise,1,ATTN_NONE);
           //round_winner = self.pteam;
           other.solid = SOLID_NOT;
           other.nextthink = (time + 0.3);
           other.think = ball_reset;
        }
        return;
     }
};

void () info_soccer_goal = {
   if (!self.noise ) {
      self.noise = "items/tf2kfgc.wav";
   }

   precache_sound (self.noise);
  
    if (self.owned_by == 1) {
        //self.pteam = pteam1;
    }
    else if (self.owned_by == 2) {
        //self.pteam = pteam2;
    }
    else if (self.owned_by == 3) {
        //self.pteam = pteam3;
    }
    else if (self.owned_by == 4) {
        //self.pteam = pteam4;
    }
   InitTrigger();

   self.touch = soccer_goal_touch;

 };
