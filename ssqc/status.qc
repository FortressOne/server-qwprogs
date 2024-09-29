float (float tno) TeamFortress_TeamGetScore;
float () TeamFortress_TeamGetWinner;
float () TeamFortress_TeamGetSecond;
string(float num) BlueScoreToString;
string(float num) RedScoreToString;
string(float num) YellowScoreToString;
string(float num) GreenScoreToString;
string(entity pl, float csqcactive) ClipSizeToString;
string(entity pl) SniperPowerToString;
string(entity pl) DetpackToString;
string(entity pl) AuraToString;
string(entity pl) AssaultCannonToString;
string(entity pl) RangeToString;
string(entity pl) ScannerToString;
string(entity pl) DisguiseToString;
string(entity pl) SentryDetailsToString;
string(entity pl) BuildingToString;
string(float pc) TeamFortress_GetClassName;
entity(float ino) Finditem;
void () tfgoalitem_dropthink;
void () tfgoalitem_remove;
float (entity ent, string ps_short, string ps_setting, string ps_default) FO_GetUserSetting;

string (float class) CF_GetRandomClassTip {
    local string tiptype = "";
    local string line1 = "";
    local string line2 = "";
    local string line3 = "";
    local string result = "";
    local float showtips;
    local float rand;

    if (!self.tip_type) {
        rand = random();
        if (rand >= 0.8)
            self.tip_type = 1;
        else
            self.tip_type = 2;
    }

    if (self.tip_type == 1) {
        // general tip
        tiptype = Q"\sGeneral tip\s:\n";
        
        while (strlen(line1) == 0) {
            if (!self.display_tip)
                self.display_tip = ceil(random() * 14);
            if (self.display_tip == 1) {
                line1 = "Team work is the key to victory.";
            } else if (self.display_tip == 2) {
                line1 = "Bunny hopping is easy to learn but hard";
                line2 = "to master. It is vital for success.";
            } else if (self.display_tip == 3) {
                line1 = "Have a grenade (mouse2 & f) ready to";
                line2 = "throw before entering combat. Timing is";
                line3 = "key.";
            } else if (self.display_tip == 4) {
                line1 = "Jump as a hand grenade (mouse2) explodes";
                line2 = "in your hand to perform a grenade jump.";
            } else if (self.display_tip == 5) {
                line1 = "Reload your current weapon (r) and";
                line2 = "secondary weapons (g) whenever you get";
                line3 = "the chance.";
            } else if (self.display_tip == 6) {
                line1 = "Swing your melee weapon (4) to show your";
                line2 = "teammates that you're not a spy.";
            } else if (self.display_tip == 7) {
                line1 = "Kill the enemy demolitions man to";
                line2 = "destroy his pipe trap.";
            } else if (self.display_tip == 8) {
                line1 = "Discard (x) unneeded ammo to reduce the";
                line2 = "damage taken from EMP grenades.";
            } else if (self.display_tip == 9) {
                line1 = "Call your medic (v) for health or your";
                line2 = "engineer for armor.";
            } else if (self.display_tip == 10) {
                line1 = "Learn your class special (e) and class";
                line2 = "menu (5).";
            } else if (self.display_tip == 11) {
                line1 = "Type /classhelp in the console at any";
                line2 = "time to get help with your class.";
            } else if (self.display_tip == 12) {
                line1 = "Throw the flag (z) to teammates or a";
                line2 = "better position.";
            } else if (self.display_tip == 13) {
                line1 = "When your flag is about to get captured,";
                line2 = "reset your defence to stop chain";
                line3 = "captures.";
            } else if (self.display_tip == 14) {
                line1 = "Throw the flag (c) to give it to a team";
                line2 = "mate or gain valuable meters before";
                line3 = "you're fragged.";
            }
        }
    } else {
        // class tip
        tiptype = Q"\sClass tip\s:\n";

        if (class == PC_SCOUT) {
            while (strlen(line1) == 0) {
                if (!self.display_tip)
                    self.display_tip = ceil(random() * 19);
                if (self.display_tip == 1) {
                    line1 = "The scout is an excellent attacking";
                    line2 = "class due to his speed and";
                    line3 = "manoeuvrability.";
                } else if (self.display_tip == 2) {
                    line1 = "Expose enemy spies by touching them.";
                } else if (self.display_tip == 3) {
                    line1 = "Disarm detpacks by standing on them.";
                } else if (self.display_tip == 4) {
                    line1 = "With its faster rate of fire, and";
                    line2 = "greater accuracy, the shotgun (2)";
                    line3 = "is more useful over long distances.";
                } else if (self.display_tip == 5) {
                    line1 = "Drop caltrops (mouse2) to slow the";
                    line2 = "enemy down.";
                } else if (self.display_tip == 6) {
                    line1 = "The caltrop canister's (mouse2) slowing";
                    line2 = "effect can be reversed by a medic or by";
                    line3 = "picking up health.";
                } else if (self.display_tip == 7) {
                    line1 = "Use concussion grenades (f) to blast";
                    line2 = "enemies away from you and to slow them";
                    line3 = "down.";
                } else if (self.display_tip == 8) {
                    line1 = "The concussion grenade (f) effect is";
                    line2 = "active for up to 19 seconds.";
                } else if (self.display_tip == 9) {
                    line1 = "The concussion grenade (f) blast";
                    line2 = "effect is stronger toward the outside";
                    line3 = "of its blast radius.";
                } else if (self.display_tip == 10) {
                    line1 = "Concussion grenade (f) blasts will";
                    line2 = "penetrate walls. Use this to your";
                    line3 = "advantage.";
                } else if (self.display_tip == 11) {
                    line1 = "The medic recovers from concussion";
                    line2 = "grenade (f) effect twice as fast as";
                    line3 = "other classes.";
                } else if (self.display_tip == 12) {
                    line1 = "Throw a concussion grenade (f) then";
                    line2 = "position yourself for the perfect";
                    line3 = "concussion grenade jump.";
                } else if (self.display_tip == 13) {
                    line1 = "Concussion grenade (f) jumps can be";
                    line2 = "chained for great distances.";
                } else if (self.display_tip == 14) {
                    if (scoutdash) {
                        line1 = "The scout can perform a speed jump (e).";
                        line2 = "This is great for initiating a bunny";
                        line3 = "hop.";
                    } else {
                        self.display_tip = 0;
                    }
                } else if (self.display_tip == 15) {
                    if (scoutdash) {
                        line1 = "To maintain the speed from dash (e), use";
                        line2 = "strafe buttons and keep jumping.";
                    } else {
                        self.display_tip = 0;
                    }
                } else if (self.display_tip == 16) {
                    line1 = "The scanner (5) can reveal the";
                    line2 = "location of other players and the flag.";
                } else if (self.display_tip == 17) {
                    line1 = "Use the scanner menu (5) to choose from";
                    line2 = "which team to scan for players.";
                } else if (self.display_tip == 18) {
                    line1 = "The scanner (5) can detect items and";
                    line2 = "players through walls.";
                } else if (self.display_tip == 19) {
                    line1 = "The scanner (5) consumes 2 cells every";
                    line2 = "other second while active.";
                }
            }
        } else if (class == PC_SNIPER) {
            while (strlen(line1) == 0) {
                if (!self.display_tip)
                    self.display_tip = ceil(random() * 9);
                if (self.display_tip == 1) {
                    line1 = "Position yourself strategically so you";
                    line2 = "can easily take cover from incoming";
                    line3 = "fire.";
                } else if (self.display_tip == 2) {
                    line1 = "The sniper rifle (1) does more damage";
                    line2 = "the longer you hold down fire (mouse1).";
                } else if (self.display_tip == 3) {
                    line1 = "Use full auto mode sniper rifle (2) to";
                    line2 = "pick off a weak enemy.";
                } else if (self.display_tip == 4) {
                    line1 = "Head shots with the sniper rifle (1)";
                    line2 = "deal double damage.";
                } else if (self.display_tip == 5) {
                    line1 = "Leg shots with the sniper rifle (1)";
                    line2 = "slow your enemy.";
                } else if (self.display_tip == 6) {
                    line1 = "Throw flares (f) to illuminate a dark";
                    line2 = "area.";
                } else if (self.display_tip == 7) {
                    line1 = "Zoom in (e) to get a better view of";
                    line2 = "your enemies.";
                } else if (self.display_tip == 8) {
                    line1 = "Use the mouse wheel to adjust zoom";
                    line2 = "while zoomed in.";
                } else if (self.display_tip == 9) {
                    line1 = "Your mouse sensitivity will";
                    line2 = "automatically adjust to your zoom level.";
                }
            }
        } else if (class == PC_SOLDIER) {
            while (strlen(line1) == 0) {
                if (!self.display_tip)
                    self.display_tip = ceil(random() * 7);
                if (self.display_tip == 1) {
                    line1 = "Use cover to take out a sentry gun with";
                    line2 = "your rockets from distance.";
                } else if (self.display_tip == 2) {
                    line1 = "Add a rocket jump to your grenade jump";
                    line2 = "for even more distance and speed.";
                } else if (self.display_tip == 3) {
                    line1 = "Rocket jump off surfaces for a big";
                    line2 = "bunny hopping boost.";
                } else if (self.display_tip == 4) {
                    line1 = "With its faster rate of fire, and";
                    line2 = "greater accuracy, the shotgun (3) is";
                    line3 = "more useful over long distances.";
                } else if (self.display_tip == 5) {
                    line1 = "Use the super shotgun (2) to slow an";
                    line2 = "incoming enemy and the rocket launcher";
                    line3 = "to finish them off.";
                } else if (self.display_tip == 6) {
                    line1 = "Use the super shotgun (2) at very close";
                    line2 = "range to avoid splash damage.";
                } else if (self.display_tip == 7) {
                    if (nailgren_type == NGR_TYPE_LASER) {
                        line1 = "Use a shock grenade (f) to clear a small";
                    } else {
                        line1 = "Use a nail grenade (f) to clear a small";
                    }
                    line2 = "room or block a bottle neck.";
                }
            }
        } else if (class == PC_DEMOMAN) {
            while (strlen(line1) == 0) {
                if (!self.display_tip)
                    self.display_tip = ceil(random() * 6);
                if (self.display_tip == 1) {
                    line1 = "When your flag is out, cover it in pipe";
                    line2 = "grenades (2). Detonate (e) before the";
                    line3 = "enemy touches it.";
                } else if (self.display_tip == 2) {
                    line1 = "Your grenade launcher (1) and pipe";
                    line2 = "launcher (2) share a clip. Reload (r)";
                    line3 = "often.";
                } else if (self.display_tip == 3) {
                    line1 = "Lay your pipe grenades (2) in a";
                    line2 = "bottleneck and keep out of the way.";
                    line3 = "Detonate them with (e).";
                } else if (self.display_tip == 4) {
                    line1 = "With its faster rate of fire, and";
                    line2 = "greater accuracy, the shotgun (3) is";
                    line3 = "more useful over long distances.";
                } else if (self.display_tip == 5) {
                    line1 = "Use your MIRV grenades (f) to clear a";
                    line2 = "room or block a bottleneck.";
                } else if (self.display_tip == 6) {
                    line1 = "On some maps, lay your detonation";
                    line2 = "pack (5) near areas blocked by grates";
                    line3 = "to open them.";
                }
            }
        } else if (class == PC_MEDIC) {
            while (strlen(line1) == 0) {
                if (!self.display_tip)
                    self.display_tip = ceil(random() * 12);
                if (self.display_tip == 1) {
                    line1 = "The medic recovers from the effects of a";
                    line2 = "concussion grenade (f) twice as fast as";
                    line3 = "other classes.";
                } else if (self.display_tip == 2) {
                    line1 = "The medic recovers from status effects";
                    line2 = "twice as fast as other classes.";
                } else if (self.display_tip == 3) {
                    line1 = "With its faster rate of fire, and";
                    line2 = "greater accuracy, the shotgun (3) is";
                    line3 = "more useful over long distances.";
                } else if (self.display_tip == 4) {
                    line1 = "The super shotgun (2) does the most";
                    line2 = "damage at close ranges.";
                } else if (self.display_tip == 5) {
                    line1 = "Use your medikit (4) on teammates to";
                    line2 = "heal status effects and give them super";
                    line3 = "health.";
                } else if (self.display_tip == 6) {
                    line1 = "Use your medikit (4) on enemies to";
                    line2 = "infect them with a deadly and contagious";
                    line3 = "virus.";
                } else if (self.display_tip == 7) {
                    line1 = "Use concussion grenades (f) to blast";
                    line2 = "enemies away from you and to slow them";
                    line3 = "down.";
                } else if (self.display_tip == 8) {
                    line1 = "The concussion grenade (f) blast effect";
                    line2 = "is stronger toward the outside of its";
                    line3 = "blast radius.";
                } else if (self.display_tip == 9) {
                    line1 = "Concussion grenade (f) blasts will";
                    line2 = "penetrate walls. Use this to your";
                    line3 = "advantage.";
                } else if (self.display_tip == 10) {
                    line1 = "Throw a concussion grenade (f) then";
                    line2 = "position yourself for the perfect";
                    line3 = "concussion grenade jump.";
                } else if (self.display_tip == 11) {
                    line1 = "Concussion jumps can be chained for";
                    line2 = "great distances.";
                } else if (self.display_tip == 12) {
                    line1 = "Use your healing aura (e) to slowly";
                    line2 = "heal nearby teammates over time.";
                }
            }
        }  else if (class == PC_HVYWEAP) {
            while (strlen(line1) == 0) {
                if (!self.display_tip)
                    self.display_tip = ceil(random() * 8);
                if (self.display_tip == 1) {
                    line1 = "A bunny hopping heavy weapons guy is";
                    line2 = "very tough to stop with weapons.";
                } else if (self.display_tip == 2) {
                    line1 = "The heavy weapons guy is too heavy to";
                    line2 = "grenade jump very far.";
                } else if (self.display_tip == 3) {
                    line1 = "Avoid concussion grenades, they stop you";
                    line2 = "from standing still, reducing your";
                    line3 = "accuracy.";
                } else if (self.display_tip == 4) {
                    line1 = "The assault cannon takes (1) a while to";
                    line2 = "spin up, use your class special (e) to";
                    line3 = "keep it spinning.";
                } else if (self.display_tip == 5) {
                    line1 = "Stand still to increase the accuracy of";
                    line2 = "your assault cannon (1).";
                } else if (self.display_tip == 6) {
                    line1 = "With its faster rate of fire, and";
                    line2 = "greater accuracy, the shotgun (3) is";
                    line3 = "more useful over long distances.";
                } else if (self.display_tip == 7) {
                    line1 = "The super shotgun (2) does the most";
                    line2 = "damage at close ranges.";
                } else if (self.display_tip == 8) {
                    line1 = "MIRV grenades (f) are a powerful way to";
                    line2 = "clear a room or block a bottleneck.";
                }
            }
        } else if (class == PC_PYRO) {
            while (strlen(line1) == 0) {
                if (!self.display_tip)
                    self.display_tip = ceil(random() * 6);
                if (self.display_tip == 1) {
                    line1 = "Use the flame thrower (1) to set your";
                    line2 = "enemies on fire, causing them to lose";
                    line3 = "health over time.";
                } else if (self.display_tip == 2) {
                    line1 = "Use the flame thrower (1) to knock back";
                    line2 = "your enemies.";
                } else if (self.display_tip == 3) {
                    line1 = "The flame thrower (1) does not work";
                    line2 = "underwater.";
                } else if (self.display_tip == 4) {
                    line1 = "With its faster rate of fire, and";
                    line2 = "greater accuracy, the shotgun (3) is";
                    line3 = "more useful over long distances.";
                } else if (self.display_tip == 5) {
                    line1 = "Napalm grenades (f) are useful for";
                    line2 = "clearing a small room or blocking off a";
                    line3 = "bottleneck.";
                } else if (self.display_tip == 6) {
                    line1 = "The pyro's kevlar armor makes him immune";
                    line2 = "to being burned.";
                }
            }
        } else if (class == PC_SPY) {
            while (strlen(line1) == 0) {
                if (!self.display_tip)
                    self.display_tip = ceil(random() * 11);
                if (self.display_tip == 1) {
                    line1 = "Watch out for scouts, they will reveal";
                    line2 = "your true identity if they touch you.";
                } else if (self.display_tip == 2) {
                    line1 = "Using your weapon or picking up the flag";
                    line2 = "will reveal your true identity.";
                } else if (self.display_tip == 3) {
                    line1 = "The spy can throw grenades (mouse2 & f)";
                    line2 = "without revealing his true identity.";
                } else if (self.display_tip == 4) {
                    line1 = "The tranquiliser gun (1) slows your";
                    line2 = "enemies down.";
                } else if (self.display_tip == 5) {
                    line1 = "The super shotgun (2) does the most";
                    line2 = "damage at close ranges.";
                } else if (self.display_tip == 6) {
                    line1 = "With its faster rate of fire, and";
                    line2 = "greater accuracy, the shotgun (3) is";
                    line3 = "more useful over long distances.";
                } else if (self.display_tip == 7) {
                    line1 = "Knife (4) your enemy in the back for";
                    line2 = "3x damage.";
                } else if (self.display_tip == 8) {
                    line1 = "The gas grenade (f) will annoy your";
                    line2 = "enemies, causing them to hallucinate.";
                } else if (self.display_tip == 9) {
                    line1 = "The spy can disguise (5) his team and";
                    line2 = "class. Sneak past the enemy defences.";
                } else if (self.display_tip == 10) {
                    line1 = "An enemy sentry gun won't shoot you";
                    line2 = "while you are disguised (5).";
                } else if (self.display_tip == 11) {
                    line1 = "Use feign death (e) to fool your";
                    line2 = "enemies of your demise.";
                }
            }
        } else if (class == PC_ENGINEER) {
            while (strlen(line1) == 0) {
                if (!self.display_tip)
                    self.display_tip = ceil(random() * 11);
                if (self.display_tip == 1) {
                    line1 = "Watch out for spies. A sentry gun will";
                    line2 = "not shoot an enemy spy disguised as a";
                    line3 = "teammate.";
                } else if (self.display_tip == 2) {
                    line1 = "The railgun (1) is accurate on long";
                    line2 = "distances. Use it on stationary objects.";
                } else if (self.display_tip == 3) {
                    line1 = "The super shotgun (2) does the most";
                    line2 = "damage at close ranges.";
                } else if (self.display_tip == 4) {
                    line1 = "Use the spanner (4) on your sentry guns";
                    line2 = "to upgrade, repair, restock or rotate";
                    line3 = "them.";
                } else if (self.display_tip == 5) {
                    line1 = "Use the spanner (4) on your teammates";
                    line2 = "to repair their armor.";
                } else if (self.display_tip == 6) {
                    line1 = "Use the spanner (4) on your dispensers";
                    line2 = "to add ammo and armor.";
                } else if (self.display_tip == 7) {
                    line1 = "The EMP grenade (f) will explode any";
                    line2 = "nearby ammo including pipebombs on the";
                    line3 = "ground.";
                } else if (self.display_tip == 8) {
                    line1 = "The engineer can build (5) sentry guns";
                    line2 = "and ammo / armor dispensers.";
                } else if (self.display_tip == 9) {
                    line1 = "Build (5) your dispenser in a defensive";
                    line2 = "position and detonate (e) it when an";
                    line3 = "enemy is nearby.";
                } else if (self.display_tip == 10) {
                    line1 = "The more ammo in your dispenser, the";
                    line2 = "more damage it does when it is";
                    line3 = "detonated (e).";
                } else if (self.display_tip == 11) {
                    line1 = "Rockets and cells will give the most";
                    line2 = "blast damage from a detonated (e)";
                    line3 = "dispenser.";
                } else if (self.display_tip == 12) {
                    line1 = "A sentry gun can be upgraded to level 3,";
                    line2 = "giving it the ability to fire rockets.";
                } else if (self.display_tip == 13) {
                    line1 = "A sentry gun cannot be built on a moving";
                    line2 = "platform.";
                }
            }
        }
    }

    showtips = !stof(infokey(self, "dt"));
    if (showtips && classtips && self.display_tip) {
        result = strcat(tiptype, line1);
        result = strcat(result, "\n");
        result = strcat(result, line2);
        result = strcat(result, "\n");
        result = strcat(result, line3);
        result = strcat(result, "\n\n\n");
    } else {
        result = "\n\n\n\n\n\n";
    }

    return strzone(result);
};

void (entity pl, string...count) Status_Print =
{
    local float i, lines, len;
    local string s;

    // no printing while menu open
    if (pl.menu_input)
        return;

    s = "";
    for (i = 0; i < count; i++) {
        s = strcat(s, ...(i, string));
    }

    len = strlen(s);

    if (pl.StatusString)
        strunzone(pl.StatusString);
    pl.StatusString = strzone(s);

    lines = 0;
    for (i = 0; i < len; i++)
        if (substring(pl.StatusString, i, 1) == "\n")
            lines++;

    pl.StatusStringLines = lines;
    pl.StatusStringTime = time + 1.5;
    pl.StatusRefreshTime = time;
};

void (entity pl, f_void_float func, string...count) Status_Menu =
{
    local float i, lines, len;
    local string s;

    s = "";
    for (i = 0; i < count; i++) {
        s = strcat(s, ...(i, string));
    }

    len = strlen(s);

    if (pl.StatusString)
        strunzone(pl.StatusString);
    pl.StatusString = strzone(s);

    lines = 0;
    for (i = 0; i < len; i++)
        if (substring(pl.StatusString, i, 1) == "\n")
            lines++;

    pl.StatusStringLines = lines;
    pl.StatusStringTime = time + 1.5;
    pl.StatusRefreshTime = time;
    pl.menu_input = func;
    pl.impulse = 0;
};

void (entity pl) Status_Refresh =
{
    if (pl.StatusRefreshTime == time)
        return;
    pl.StatusRefreshTime = time;
};

void (entity pl, string s1) CenterPrint = {
    Status_Print(pl, s1);
};

void (entity pl, string s1, string s2) CenterPrint2 = {
    Status_Print(pl, s1, s2);
};

void (entity pl, string s1, string s2, string s3) CenterPrint3 = {
    Status_Print(pl, s1, s2, s3);
};

void (entity pl, string s1, string s2, string s3, string s4) CenterPrint4 = {
    Status_Print(pl, s1, s2, s3, s4);
};

void (entity pl, string s1, string s2, string s3, string s4, string s5) CenterPrint5 = {
    Status_Print(pl, s1, s2, s3, s4, s5);
};

void (entity pl, string s1, string s2, string s3, string s4, string s5, string s6) CenterPrint6 = {
    Status_Print(pl, s1, s2, s3, s4, s5, s6);
};

string getLocationName(vector location);

void (entity Player, float index, entity Item, float icon) InitClientFlagStatus = {
    if(!infokeyf(Player, INFOKEY_P_CSQCACTIVE) || !CF_GetSetting("ssbfi", "server_sbflaginfo", "1")) {
        return;
    }
    msg_entity = Player;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_FLAGINFOINIT);
    WriteFloat(MSG_MULTICAST, index);
    WriteFloat(MSG_MULTICAST, Item.goal_no);
    WriteString(MSG_MULTICAST, Item.mdl);
    WriteFloat(MSG_MULTICAST, Item.skin);
    WriteFloat(MSG_MULTICAST, Item.owned_by);
    WriteFloat(MSG_MULTICAST, icon);
    multicast('0 0 0', MULTICAST_ONE_R_NOSPECS); 
}

void (entity Player) InitAllStatuses = {
    entity tfdet = find(world, classname, "info_tfdetect");
    if(tfdet) {
        InitClientFlagStatus(Player, 0, Finditem(tfdet.display_item_status1), FLAGINFO_ICON_FLAG);
        InitClientFlagStatus(Player, 1, Finditem(tfdet.display_item_status2), FLAGINFO_ICON_FLAG);
        InitClientFlagStatus(Player, 2, Finditem(tfdet.display_item_status3), FLAGINFO_ICON_FLAG);
        InitClientFlagStatus(Player, 3, Finditem(tfdet.display_item_status4), FLAGINFO_ICON_FLAG);
    }
    tfdet = find(world, classname, "info_tfgoal");
    while (tfdet) {
        if (tfdet.track_goal) {
            InitClientFlagStatus(Player, -1, tfdet, FLAGINFO_ICON_BUTTON);
        }
        tfdet = find(tfdet, classname, "info_tfgoal");
    }
};

float laststate;
void (entity Player, entity Goal) UpdateClientButtonStatus = {
    if(!infokeyf(Player, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = Player;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_FLAGINFO); 
    WriteFloat(MSG_MULTICAST, Goal.goal_no);
    if(Goal.goal_no == 11) {
        if(Goal.goal_state != laststate) {
            laststate = Goal.goal_state;
        }
    }
    if(Goal.goal_state == TFGS_DELAYED) {
        WriteFloat(MSG_MULTICAST, FLAGINFO_DROPPED);
        WriteFloat(MSG_MULTICAST, rint(Goal.bubble_count - time));
        //WriteFloat(MSG_MULTICAST, FLAGINFO_NOLOCATION);
        WriteFloat(MSG_MULTICAST, FLAGINFO_LOCATION);
        WriteCoord(MSG_MULTICAST, Goal.origin_x);
        WriteCoord(MSG_MULTICAST, Goal.origin_y);
        WriteCoord(MSG_MULTICAST, Goal.origin_z);
        //WriteString(MSG_MULTICAST, getLocationName(Item.origin));
        if(Goal.team_str_moved) {
            WriteString(MSG_MULTICAST, Goal.team_str_moved);
        } else {
            WriteString(MSG_MULTICAST,"\sOffline\s");
        }
    } else {
        WriteFloat(MSG_MULTICAST, FLAGINFO_HOME);
    }
    multicast('0 0 0', MULTICAST_ONE_NOSPECS);    
}

void (entity Player, entity Item) UpdateClientFlagStatus = {
    if(!infokeyf(Player, INFOKEY_P_CSQCACTIVE))
        return;
    msg_entity = Player;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_FLAGINFO); 
    WriteFloat(MSG_MULTICAST, Item.goal_no);
    if (Item.goal_state == 1 && Item.owner != world) {
        WriteFloat(MSG_MULTICAST, FLAGINFO_CARRIED);
        if (Player == Item.owner) {
            WriteString(MSG_MULTICAST, "YOU");
        } else {
            WriteString(MSG_MULTICAST, Item.owner.netname);
        }
    } else {
        if (Item.origin != Item.oldorigin) {
            if((Item.nextthink - time) >= 0) {
                WriteFloat(MSG_MULTICAST, FLAGINFO_DROPPED);
                if(noreturn) {
                    WriteFloat(MSG_MULTICAST, -1);
                } else {
                    WriteFloat(MSG_MULTICAST, rint(Item.bubble_count - time));
                }
                if((Item.think == tfgoalitem_dropthink || Item.think == tfgoalitem_remove) && !Item.owner) {
                    WriteFloat(MSG_MULTICAST, FLAGINFO_LOCATION);
                    WriteCoord(MSG_MULTICAST, Item.origin_x);
                    WriteCoord(MSG_MULTICAST, Item.origin_y);
                    WriteCoord(MSG_MULTICAST, Item.origin_z);
                    WriteString(MSG_MULTICAST, getLocationName(Item.origin));
                } else {
                    WriteFloat(MSG_MULTICAST, FLAGINFO_NOLOCATION);
                }
            } else {
                WriteFloat(MSG_MULTICAST, FLAGINFO_RETURNING);
            }
        } else {
            WriteFloat(MSG_MULTICAST, FLAGINFO_HOME);
        }
    }
    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

string (entity Player, entity Item, float teamno) GetItemStatus = {
    local string st = "";
    switch (teamno)
    {
        case 1:
            st = "Blue Flag";
            break;
        case 2:
            st = "Red Flag";
            break;
        case 3:
            st = "Yellow Flag";
            break;
        case 4:
            st = "Green Flag";
            break;
    }
    if (Player.team_no == Item.owned_by) {
        st = strcat(Q"\x10", st ,Q"\x11");
    }
    if (Item.goal_state == 1 && Item.owner != world) {
        if (Player == Item.owner) {
            st = strcat(st, Q"\s: Carried by \sYOU");
        } else {
            st = strcat(st, Q"\s: Carried by \s", Item.owner.netname);
        }
    } else {
        if (Item.origin != Item.oldorigin) {
            //When the item is thrown, there is a touch think with a pad of 4.25s before the normal timer kicks in
            if((Item.nextthink - time) >= 0) {
                if(!noreturn) {
                    st = strcat(st, Q"\s: Return: \s", ftos(rint(Item.bubble_count - time)));
                } else {
                    st = strcat(st, Q"\s: Dropped\s");
                }
            } else {
                st = strcat(st, Q"\s: Returning\s NOW!");
            }
        } else {
            st = strcat(st, Q"\s: Safe\s");
        }
    }

    return st;
}

string GetSBClassInfo(entity pl, float csqcactive)
{
    string st1 = "";
    if (pl.playerclass == PC_SCOUT)
        st1 = ScannerToString(pl);
    else if (pl.playerclass == PC_SNIPER && (pl.tfstate & TFSTATE_AIMING))
        st1 = SniperPowerToString(pl);
    else if (pl.playerclass == PC_DEMOMAN && pl.detpack_left)
        st1 = DetpackToString(pl);
    else if (pl.playerclass == PC_MEDIC)
        st1 = AuraToString(pl);
    else if (pl.playerclass == PC_HVYWEAP)
        st1 = AssaultCannonToString(pl);
    else if (pl.playerclass == PC_SPY)
        st1 = DisguiseToString(pl);
    else if (pl.playerclass == PC_ENGINEER && pl.has_sentry)
        st1 = SentryDetailsToString(pl);
    if (pl.playerclass == PC_ENGINEER && pl.is_building)
        st1 = BuildingToString(pl);

    return st1;
}

void UpdateClientBuilding(entity pl) {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;

    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, MSG_BUILDING);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS);
}

void UpdateClientReloadSound(entity pl, float weapon) {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;

    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, MSG_RELOADSOUND);
    WriteFloat(MSG_MULTICAST, weapon);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS);
}

void UpdateClientGrenadePrimed(entity pl, float grentype, float explodes_at) = {
#if 0  // Not needed until we re-enable TFX.
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, MSG_GRENPRIMED);
    WriteEntity(MSG_MULTICAST, pl);
    WriteByte(MSG_MULTICAST, grentype);
    WriteFloat(MSG_MULTICAST, explodes_at);

    multicast('0 0 0', MULTICAST_ALL);  // Actual primer has reliable transport.
#endif
}

void UpdateClientGrenadeThrown(entity pl) = {
#if 0  // Not needed until we re-enable TFX.
    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, MSG_GRENTHROWN);
    WriteEntity(MSG_MULTICAST, pl);
    multicast('0 0 0', MULTICAST_ALL);
#endif
}

void UpdateClientIDString(entity pl) {
    string ident = time < pl.ident_time ? pl.ident_string : "";

    if (ident == "")  // No need to send null, we'll expire clientside.
        return;

    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, MSG_ID);
    WriteString(MSG_MULTICAST, ident);
    multicast('0 0 0', MULTICAST_ONE);
}

void UpdateClientStatusBar(entity pl)
{
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;
    // if we ever change to fte only, this could be changed to stats
    string msg = "";
    msg_entity = pl;

    string clipMsg = ClipSizeToString(pl, TRUE);

    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, MSG_SBAR);
    WriteString(MSG_MULTICAST, clipMsg);
    WriteFloat(MSG_MULTICAST, pl.fragstreak);
    WriteFloat(MSG_MULTICAST, pl.caps);

    WriteFloat(MSG_MULTICAST, pl.playerclass); // just in case we get a packet from "last life" after changing playerclass

    // class info
    switch (pl.playerclass)
    {
        case PC_SCOUT:
            // off, on
            WriteFloat(MSG_MULTICAST, pl.ScannerOn);
            
            if (pl.ScannerOn)
            {
                entity te;
                te = find(world, netname, "scanner");
                while ((te != world) && (te.owner != pl)) {
                    te = find(te, netname, "scanner");
                }
                WriteFloat(MSG_MULTICAST, te.health); // range to person, 0 or less if no one
                if (te.health)
                {
                    WriteFloat(MSG_MULTICAST, te.team_no);
                    WriteFloat(MSG_MULTICAST, te.playerclass);
                    WriteFloat(MSG_MULTICAST, te.tf_items_flags); // nothing, friendly, enemy
                }
            }
            break;
        case PC_SNIPER:
            float dam;
            dam = 0;
            if (sniperpower)
                dam = pl.heat;

            WriteFloat(MSG_MULTICAST, dam);
            break;
        case PC_DEMOMAN:
            WriteFloat(MSG_MULTICAST, pl.is_detpacking);
            WriteFloat(MSG_MULTICAST, pl.detpack_left);
            break;
        case PC_MEDIC:
            WriteFloat(MSG_MULTICAST, medicaura);

            if (medicaura)
            {
                WriteFloat(MSG_MULTICAST, pl.aura_active);

                if (pl.aura_active) 
                {
                    float c, a;
                    c = (time < pl.aura_healtime) ? pl.aura_healcount : 0;
                    a = (time < pl.aura_healtime) ? pl.aura_healamount : 0;
                    WriteFloat(MSG_MULTICAST, c);
                    WriteFloat(MSG_MULTICAST, a);
                    // state
                    float s = PC_MEDIC_AURA_ACTIVE;
                    if (pl.ammo_cells < ceil(PC_MEDIC_MAXAMMO_CELL / 2))
                    {
                        s = PC_MEDIC_AURA_OUTOFPOWER;
                    }
                    else if (pl.ammo_cells < floor(PC_MEDIC_MAXAMMO_CELL * 0.95))
                    {
                        s = PC_MEDIC_AURA_RECHARGING;
                    }
                    WriteFloat(MSG_MULTICAST, s);
                }
            }
            break;
        case PC_HVYWEAP:
            // ass can locked
            float l = FALSE;
            if (pl.tfstate & TFSTATE_LOCK)
            {
                l = TRUE;
            }

            WriteFloat(MSG_MULTICAST, l);
            break;
        case PC_PYRO:
            if(pl.airblast_cooldown == 1)
            {
                WriteFloat(MSG_MULTICAST, TRUE);
            }
            else if (pl.airblast_cooldown == 0)
            {
                WriteFloat(MSG_MULTICAST, FALSE);
            }
            break; 
        case PC_SPY:
            WriteFloat(MSG_MULTICAST, pl.is_undercover);
            
            if (pl.is_undercover == 1)
            {
                WriteFloat(MSG_MULTICAST, invis_only);
                WriteFloat(MSG_MULTICAST, pl.undercover_team);
                WriteFloat(MSG_MULTICAST, pl.undercover_skin);
            }
            else if (pl.is_undercover == 2)
            {
                WriteFloat(MSG_MULTICAST, invis_only);
                WriteFloat(MSG_MULTICAST, pl.undercover_timer);
                WriteFloat(MSG_MULTICAST, pl.undercover_team);
                WriteFloat(MSG_MULTICAST, pl.disguise_team);
                WriteFloat(MSG_MULTICAST, pl.queue_team);
                WriteFloat(MSG_MULTICAST, pl.undercover_skin);
                WriteFloat(MSG_MULTICAST, pl.disguise_skin);
                WriteFloat(MSG_MULTICAST, pl.queue_skin);
            }
            break;
        case PC_ENGINEER:
            // building status??
            WriteFloat(MSG_MULTICAST, pl.is_building);
            if (pl.is_building)
            {
                WriteFloat(MSG_MULTICAST, pl.building_percentage);
            }

            WriteFloat(MSG_MULTICAST, pl.has_sentry);
            if (pl.has_sentry)
            {
                WriteFloat(MSG_MULTICAST, pl.sentry_ent.weapon); // level
                WriteFloat(MSG_MULTICAST, pl.sentry_ent.health);
                WriteFloat(MSG_MULTICAST, pl.sentry_ent.ammo_shells);
                WriteFloat(MSG_MULTICAST, pl.sentry_ent.ammo_rockets);
                
            }

            WriteFloat(MSG_MULTICAST, pl.has_dispenser);
            if (pl.has_dispenser)
            {
                entity disp;
                disp = find(world, classname, "building_dispenser");
                while (disp)
                {
                    if (disp.real_owner == pl)
                    {
                        WriteFloat(MSG_MULTICAST, disp.health);
                    }
                    disp = find(disp, classname, "building_dispenser");
                }
            }
            break;
    }

    multicast('0 0 0', MULTICAST_ONE_NOSPECS); 
}

void (entity pl, float flag_team) UpdateClientFlagPickUp = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;

    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, MSG_FLAG_PICKUP);
    WriteFloat(MSG_MULTICAST, flag_team);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS);
}

void (entity pl) UpdateClientFlagDrop = {
    if(!infokeyf(pl, INFOKEY_P_CSQCACTIVE))
        return;

    msg_entity = pl;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, MSG_FLAG_DROP);
    multicast('0 0 0', MULTICAST_ONE_NOSPECS);
}

void (entity pl) RefreshStatusBar = {
    local string pad;
    local string s1 = ""; // will be used for grenade timers
    local string s2 = ""; // class line
    local string s3 = ""; // score & clip
    local string ct = ""; // class tip
    local string st1, st2, st3, st4; // status bar columns 1-4
    local string ident = "";
    local float height;
    local float i;
    local entity tfdet;  //info_tfdetect entity
    local entity te = world, tg;
    local string bi; //button info
    local float csqcactive;
    //By default, show after tips; 0/off = off; 2 = always
    local float sbflaginfostate = FO_GetUserSetting(pl, "sbflaginfo", "sbflaginfo", "on"); 
    tfdet = find(world, classname, "info_tfdetect");
   
    pad = "";

    if (pl.StatusStringLines > 0 && pl.StatusStringTime <= time && !pl.menu_input) {
        if (pl.StatusString)
            strunzone(pl.StatusString);
        pl.StatusString = string_null;
        pl.StatusStringLines = 0;
    }

    height = floor(stof(infokey(pl, "sb")));
    if (height > 300)
        height = 300;
    height = height - pl.StatusStringLines - 13;

    pl.StatusRefreshTime = time + 1.5;

    csqcactive = infokeyf(pl, INFOKEY_P_CSQCACTIVE);
    if(pl.classname == "observer" && csqcactive) {
        if (tfdet)
        {
            for (float t = 1; t <= number_of_teams; t++) 
            {
                switch (t)
                {
                    case 1:
                        te = Finditem(tfdet.display_item_status1);
                        break;
                    case 2:
                        te = Finditem(tfdet.display_item_status2);
                        break;
                    case 3:
                        te = Finditem(tfdet.display_item_status3);
                        break;
                    case 4:
                        te = Finditem(tfdet.display_item_status4);
                        break;
                }

                if (te)
                {
                    UpdateClientFlagStatus(pl, te);
                }
            }
        }
        tg = find(world, classname, "info_tfgoal");
        while (tg) {
            if (tg.track_goal) {
                UpdateClientButtonStatus(pl, tg);
            }
            tg = find(tg, classname, "info_tfgoal");
        }
        UpdateClientIDString(pl);
        
        return;
    }

    // no sbar can be displayed
    if (height <= 0 || (pl.playerclass == PC_UNDEFINED && !votemode)) {
        centerprint(pl, pl.StatusString);
        pl.StatusRefreshTime = time + 1.5;
        return;
    }

    for (i = 0; i < height; i++)
        pad = strcat(pad, "\n");
    pad = strzone(pad);


    // class tip
    if ((((time - 6) < pl.spawn_time) || ((time - 6) < pl.tip_time)) && sbflaginfostate < 2 && !csqcactive) {
        ct = CF_GetRandomClassTip(pl.playerclass);
    } else {
        pl.display_tip = 0;

        // we get flag info from tfdetect
        if (!tfdet || !sbflaginfostate)
        {
            ct = strzone("\n\n\n\n\n\n");
        }
        //else 
        if (csqcactive) // has csqc
        {
            //pl.StatusRefreshTime = time + 1;
            UpdateClientStatusBar(pl);
            UpdateClientIDString(pl);
            
            // flag info
            if (CF_GetSetting("ssbfi", "server_sbflaginfo", "1"))
            {
                if (tfdet)
                {
                    for (float t = 1; t <= number_of_teams; t++) 
                    {
                        switch (t)
                        {
                            case 1:
                                te = Finditem(tfdet.display_item_status1);
                                break;
                            case 2:
                                te = Finditem(tfdet.display_item_status2);
                                break;
                            case 3:
                                te = Finditem(tfdet.display_item_status3);
                                break;
                            case 4:
                                te = Finditem(tfdet.display_item_status4);
                                break;
                        }

                        if (te)
                        {
                            UpdateClientFlagStatus(pl, te);
                        }
                    }
                }

                tg = find(world, classname, "info_tfgoal");
                while (tg) {
                    if (tg.track_goal) {
                        UpdateClientButtonStatus(pl, tg);
                    }
                    tg = find(tg, classname, "info_tfgoal");
                }
            }
        }
        else if (CF_GetSetting("ssbfi", "server_sbflaginfo", "1")) // no csqc but has sbflaginfo on and server_sbflaginfo is enabled
        {
            ct = "";
            i = number_of_teams; // Extra newlines
            for (float t = 1; t <= number_of_teams; t++) {
                switch (t)
                {
                    case 1:
                        te = Finditem(tfdet.display_item_status1);
                        break;
                    case 2:
                        te = Finditem(tfdet.display_item_status2);
                        break;
                    case 3:
                        te = Finditem(tfdet.display_item_status3);
                        break;
                    case 4:
                        te = Finditem(tfdet.display_item_status4);
                        break;
                }

                if (te)
                {
                    if(number_of_teams < 4) {
                        ct = strcat(ct, strpadr(GetItemStatus(pl, te, t),40),"\n");
                        if((te.think == tfgoalitem_dropthink || te.think == tfgoalitem_remove) && !te.owner && (te.origin != te.oldorigin)) {
                            ct = strcat(ct, strpadr(strcat("\s Location: \s", getLocationName(te.origin)),40));
                        }
                        i += 1;
                    } else {
                        if((te.think == tfgoalitem_dropthink || te.think == tfgoalitem_remove) && !te.owner && (te.origin != te.oldorigin)) {
                            ct = strcat(ct, strpadr(strcat(GetItemStatus(pl, te, t),"\s: \s", getLocationName(te.origin)),40));
                        } else {
                            ct = strcat(ct, strpadr(GetItemStatus(pl, te, t),40));
                        }
                    }
                }
                ct = strcat(ct, "\n");
            }
            tg = find(world, classname, "info_tfgoal");
            while (tg) {
                if (tg.track_goal && i < 6 && tg.goal_state == TFGS_DELAYED) {
                    bi = "";
                    //only do this for named goals, otherwise there's no way to distinguish them (they don't ususally have owned_by or anything)
                    if(tg.netname) {
                        bi = tg.netname;
                        if(tg.team_str_moved) {
                            bi = strcat(bi,": ", tg.team_str_moved);
                        } else {
                            bi = strcat(bi,": \sOffline\s");
                        }
                        bi = strcat(bi, " ", ftos(rint(tg.bubble_count - time)));
                        ct = strcat(ct, strpadr(bi,40),"\n");
                        i += 1;
                    }
                }
                tg = find(tg, classname, "info_tfgoal");
            }
            
            for (float t = 0; t < (6 - i); t++)
                ct = strcat(ct, "\n");
            
            ct = strzone(ct);
        }
        else {
            ct = strzone("\n\n\n\n\n\n");
        }
    }

    if (!csqcactive)
    {
        // status line 1 column 1 - grenade timer
        if (pl.StatusGrenTime > 0) {
            st1 = strcat(Q"\sGrenade\s: ", ftos(pl.StatusGrenTime));
            if (pl.fragstreak > 1 && pl.caps)
                st1 = strcat(st1, " sec");
            else
                st1 = strcat(st1, " seconds");
        } else
            st1 = "";
        // status line 1 column 3 - kill streak & caps
        if (pl.fragstreak > 1) {
            st2 = Q"\sKill Streak\s: ";
            st2 = strcat(st2, strpadl(ftos(pl.fragstreak),2));
        } else
            st2 = "";
        if (pl.caps) {
            if (pl.fragstreak > 1)
                st2 = strcat(st2, "  ");
            st3 = Q"\sCaps\s: ";
            st3 = strcat(st3, strpadl(ftos(pl.caps),2));
        } else
            st3 = "";
        st2 = strcat(st2, st3);
        // status line 1
        if (pl.fragstreak > 1 && pl.caps) {
            st2 = strpadl(st2, 25);
            s1 = strpadr(st1, 15);
        } else {
            st2 = strpadl(st2, 20);
            s1 = strpadr(st1, 20);
        }
        s1 = strcat(s1, st2);
        s1 = strcat(s1, "\n");
        s1 = strzone(s1);

        // status line 2 column 1 - class specific information
        st1 = GetSBClassInfo(pl, csqcactive);
        
        // status line 2
        s2 = strpadr(st1, 40);
        s2 = strcat(s2, "\n");
        s2 = strzone(s2);

        st1 = "";
        st2 = "";

        // status line 3 column 2 - clip size
        st2 = strcat(Q"\sClip\s: ", ClipSizeToString(pl, csqcactive));

        // status line 3 column 3 - grenade 1 count
        st3 = strcat(Q"\sGren1\s: ", ftos(pl.no_grenades_1));

        // status line 3 column 4 - grenade 2 count
        st4 = strcat(Q"\sGren2\s: ", ftos(pl.no_grenades_2));

        // status line 3
        s3 = strcat(st1, st2);
        s3 = strpadr(s3, 19);
        s3 = strcat(s3, strpadl(strcat(st3, strcat("  ", st4)), 21));
        s3 = strcat(s3, "\n");
        s3 = strzone(s3);

        // identify
        if (pl.ident_string != string_null && time < pl.ident_time) {
            ident = strcat(pl.ident_string, "\n\n");
        } else {
            ident = "\n\n\n\n";
        }
    }
    centerprint(pl, pl.StatusString, pad, ident, ct, s1, s2, s3);
    strunzone(pad); strunzone(ct); strunzone(s1); strunzone(s2); strunzone(s3);
};

string(float num) BlueScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat(Q"\sBlue\s:", strpadl(ftos(floor(num)), 3));
};

string(float num) RedScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat(Q"\sRed\s :", strpadl(ftos(floor(num)), 3));
};

string(float num) YellowScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat(Q"\sYell\s:", strpadl(ftos(floor(num)), 3));
};

string(float num) GreenScoreToString =
{
    if (num > 999)
        num = 999;

    return strcat(Q"\sGren\s:", strpadl(ftos(floor(num)), 3));
};

string(entity pl, float csqcactive) ClipSizeToString =
{
    FO_WeapState ws;
    FO_FillCurrentWeapState(&ws);
    FO_WeapInfo* wi = ws->wi;

    if (!wi->needs_reload)
        return "";

    float clip_rem = min(wi->clip_size - *ws->clip_fired - pl.last_still_loading, 999);

    string st = "";
    if (csqcactive)
        st = strcat(ftos(floor(clip_rem)), "/", ftos(wi->clip_size));
    else
        st = strcat(strpadl(ftos(clip_rem), 2), "/", strpadr(ftos(wi->clip_size), 3));

    return st;
};

string(entity pl) DisguiseToString =
{
    local string st = "";
    local string skin = "";
    local string team = "";

    if (pl.is_undercover == 1) {
        if (self.items & IT_INVISIBILITY) {
            st = Q"\sInvisible\s";
        } else {
            st = Q"\sUndercover\s: ";
            if (pl.undercover_team) {
                st = strcat(st, TeamToString(pl.undercover_team));
                st = strcat(st, " ");
            }
            if (pl.undercover_skin)
                st = strcat(st, ClassToString(pl.undercover_skin));
        }
    } else if (pl.is_undercover == 2) {
        if (invis_only) {
            st = Q"\sInvisible\s in ";
            st = strcat(st, ftos(pl.undercover_timer));
            st = strcat(st, " seconds");
        } else {
            if (pl.disguise_team) {
                team = strcat(team, "(");
                team = strcat(team, TeamToString(pl.disguise_team));
                if (!pl.queue_skin)
                    team = strcat(team, ") ");
            } else if (pl.queue_team) {
                team = strcat(team, "(");
                team = strcat(team, TeamToString(pl.queue_team));
                team = strcat(team, " ");
            } else if (pl.undercover_team) {
                team = strcat(team, TeamToString(pl.undercover_team));
                team = strcat(team, " ");
            }
            if (pl.disguise_skin) {
                if (!pl.queue_team)
                    skin = strcat(skin, "(");
                skin = strcat(skin, ClassToString(pl.disguise_skin));
                skin = strcat(skin, ")");
            } else if (pl.queue_skin) {
                skin = strcat(skin, " ");
                skin = strcat(skin, ClassToString(pl.queue_skin));
                skin = strcat(skin, ")");
            } else if (pl.undercover_skin) {
                skin = strcat(skin, ClassToString(pl.undercover_skin));
            }
            st = Q"\sUndercover\s: ";
            st = strcat(st, team);
            st = strcat(st, skin);
        }
    }

    return st;
};

string(entity pl) SniperPowerToString =
{
    local string st = "";

    if (!sniperpower)
        return st;

    if (pl.heat) {
        st = Q"\spower\s: ";
        st = strcat(st, ftos(pl.heat));
        st = strcat(st, " dmg");
        if (pl.heat == PC_SNIPER_MAXDAM)
            st = strcat(st, " (max)");
    }

    return st;
};

string(entity pl) DetpackToString =
{
    local string st = "";

    if (pl.is_detpacking) {
        st = Q"\sDetpack\s: ";
        st = strcat(st, ftos(pl.detpack_left));
        st = strcat(st, " (");
        st = strcat(st, ftos(pl.is_detpacking));
        st = strcat(st, ")");
        st = strcat(st, " seconds left");
    } else if (pl.detpack_left) {
        st = Q"\sDetpack\s: ";
        st = strcat(st, ftos(pl.detpack_left));
        st = strcat(st, " seconds left");
    }

    return st;
};

string(entity pl) AuraToString =
{
    local string st;

    if (medicaura) {
        st = Q"\sHealing Aura\s: ";

        if (pl.aura_active) {
            if (time < pl.aura_healtime && pl.aura_healcount) {
                st = strcat(st, ftos(pl.aura_healcount));
                st = strcat(st, " players healed for ");
                st = strcat(st, ftos(pl.aura_healamount));
                st = strcat(st, " hp");
            }
            else if (pl.ammo_cells < ceil(PC_MEDIC_MAXAMMO_CELL / 2))
                st = strcat(st, "out of power");
            else if (pl.ammo_cells < floor(PC_MEDIC_MAXAMMO_CELL * 0.95))
                st = strcat(st, "recharging");
            else
                st = strcat(st, "on");
        } else {
            st = strcat(st, "off");
        }
    } else {
        st = "";
    }

    return st;
};

string(entity pl) AssaultCannonToString =
{
    if (FO_CurrentWeapon() == WEAP_ASSAULT_CANNON && (pl.tfstate & TFSTATE_LOCK))
        return Q"\sAssault Cannon Locked\s";
    else
        return "";
};

string(entity pl) RangeToString =
{
    local entity te;
    local float num;

    if (!pl.ScannerOn) {
        return "";
    }

    te = find(world, netname, "scanner");
    while ((te != world) && (te.owner != pl)) {
        te = find(te, netname, "scanner");
    }

    num = te.health;

    if (num <= 0) {
        return "";
    }

    if (num > 99) {
        return "99+ m";
    }

    return strcat(strpadl(ftos(floor(num)), 3), " m");
};

string(entity pl) ScannerToString =
{
    local entity te;
    local string st = "";
    local string scanfor = "";
    local string range = "";
    local float pad;

    st = Q"\sScanner\s: ";

    if (pl.ScannerOn != TRUE) {
        return strcat(st, "off");
    }

    te = find(world, netname, "scanner");
    while ((te != world) && (te.owner != pl)) {
        te = find(te, netname, "scanner");
    }

    if (te.health > 0) {
        st = strcat(st, TeamToString(te.team_no));
        st = strcat(st, " ");
        st = strcat(st, ClassToString(te.playerclass));
        st = strpadr(st, 26);
        range = Q"\srange\s: ";
        range = strcat(range, RangeToString(pl));
        pad = 40 - strlen(range);
        st = strpadr(st, pad);
        st = strcat(st, range);
    } else {
        st = strcat(st, "on");
        st = strcat(st, Q"  \sScanning\s: ");

        if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
            scanfor = "team";
        }

        if (self.tf_items_flags & NIT_SCANNER_ENEMY) {
            if (self.tf_items_flags & NIT_SCANNER_FRIENDLY) {
                scanfor = strcat(scanfor, ", ");
            }

            scanfor = strcat(scanfor, "enemy");
        }

        if (!strlen(scanfor)) {
            scanfor = "nothing";
        }

        st = strcat(st, scanfor);
    }

    return st;
};

string(entity pl) SentryDetailsToString =
{
    local string ammo    = "";
    local string shells  = "";
    local string rockets = "";
    local string hp      = "";
    local string st      = "";

    if (self.has_sentry) {
        hp = strcat(strpadl(ftos(floor(self.sentry_ent.health)), 3), " hp");
        shells = ftos(floor(self.sentry_ent.ammo_shells));

        if (self.sentry_ent.weapon == 3) {
            rockets = ftos(floor(self.sentry_ent.ammo_rockets));
            ammo = strcat(Q"  \sAmmo\s: ", strcat(shells, strcat("/", rockets)));
        } else {
            ammo = strcat(Q"  \sAmmo\s: ", shells);
        }

        st = strcat(Q"\sSentry\s: ", strcat(hp, ammo));
        st = strpadr(st, 32);
        st = strcat(st, strcat(Q"\slevel\s: ", ftos(self.sentry_ent.weapon)));
    }

    return st;
};

string(entity pl) BuildingToString ={
    local string st = "";
    local int dist_percentage;
    local string dist_string;
    local string hp;

    if (engineer_move && self.sentry_ent) {
        hp = strcat(strpadl(ftos(floor(self.sentry_ent.health)), 2), " hp");
        st = strcat(st,strcat(Q"\sSentry\s: ", hp));
        st = strpadr(st, 15);
    }

    if (!buildstatus)
        return "Building...";

    st = strcat(st, Q"\sReady\s: ");
    st = strcat(st, ftos(pl.building_percentage));
    st = strcat(st, "%");
    if (!engineer_move) { //disabling max_distance for moving engineer
        if (engineer_move) {
            dist_percentage = (vlen(self.origin - self.sentry_ent.origin)/BUILD_SENTRYGUN_MAX_DISTANCE_ENGMOVE)*100;
            st = strpadr(st, 26);
            st = strcat(st, Q"\sDistance\s:");
            dist_string = strcat(itos(dist_percentage),"%");
            dist_string = strcat(Q"\x10", dist_string ,Q"\x11");
            st = strcat(st, dist_string);
        }
    }

    return st;
};
