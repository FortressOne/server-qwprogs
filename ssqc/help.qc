// CLASS HELP FOR FORTRESSONE
// ==========================
// Shows class bindings for each class.

// functions by order of appearance
void () Help_Show;
void () Help_ShowScout;
void () Help_ShowSniper;
void () Help_ShowSoldier;
void () Help_ShowDemoman;
void () Help_ShowMedic;
void () Help_ShowHWGuy;
void () Help_ShowPyro;
void () Help_ShowSpy;
void () Help_ShowEngineer;

// global variables
// <none>

// shows a list of key bindings and aliases for current class
// called from weapons.qc:ImpulseCommands()
void () Help_Show = {
    if (self.playerclass == PC_SCOUT)
        Help_ShowScout();
    if (self.playerclass == PC_SNIPER)
        Help_ShowSniper();
    if (self.playerclass == PC_SOLDIER)
        Help_ShowSoldier();
    if (self.playerclass == PC_DEMOMAN)
        Help_ShowDemoman();
    if (self.playerclass == PC_MEDIC)
        Help_ShowMedic();
    if (self.playerclass == PC_HVYWEAP)
        Help_ShowHWGuy();
    if (self.playerclass == PC_PYRO)
        Help_ShowPyro();
    if (self.playerclass == PC_SPY)
        Help_ShowSpy();
    if (self.playerclass == PC_ENGINEER)
        Help_ShowEngineer();
};

void () Help_ShowScout = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Scout:\n");
    sprint(self, PRINT_HIGH, Q"\s1\s         - Equip Nailgun\n");
    sprint(self, PRINT_HIGH, Q"\s2\s         - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s4\s         - Equip Axe\n");
    sprint(self, PRINT_HIGH, Q"\se\s         - Toggle Scanner on/off\n");
    sprint(self, PRINT_HIGH, Q"\sf\s         - Throw Caltrop Canisters\n");
    sprint(self, PRINT_HIGH, Q"\smouse2\s    - Prime/throw Concussion Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Scout:\n");
    sprint(self, PRINT_HIGH, Q"\sautoscan\s  - Toggle Scanner on/off\n");
    sprint(self, PRINT_HIGH, Q"\sscansound\s - Toggle Scanner sound on/off\n");
    sprint(self, PRINT_HIGH, Q"\sscane\s     - Toggle scanning of enemies on/off\n");
    sprint(self, PRINT_HIGH, Q"\sscanf\s     - Toggle scanning of friendlies on/off\n");
};

void () Help_ShowSniper = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Sniper:\n");
    sprint(self, PRINT_HIGH, Q"\s1\s          - Equip Sniper Rifle\n");
    sprint(self, PRINT_HIGH, Q"\s2\s          - Equip Sniper Rifle on Full Auto\n");
    sprint(self, PRINT_HIGH, Q"\s2\s          - Equip Nailgun\n");
    sprint(self, PRINT_HIGH, Q"\s4\s          - Equip Axe\n");
    sprint(self, PRINT_HIGH, Q"\se\s          - Toggle zoom mode\n");
    sprint(self, PRINT_HIGH, Q"\smwheelup\s   - Zoom in (while in zoom mode)\n");
    sprint(self, PRINT_HIGH, Q"\smwheeldown\s - Zoom out (while in zoom mode)\n");
    sprint(self, PRINT_HIGH, Q"\sf\s          - Throw Flare\n");
    sprint(self, PRINT_HIGH, Q"\smouse2\s     - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Sniper:\n");
    sprint(self, PRINT_HIGH, Q"\szoomin\s     - Zoom in (for adjusting zoom while in zoom mode)\n");
    sprint(self, PRINT_HIGH, Q"\szoomout\s    - Zoom out (for adjusting zoom while in zoom mode)\n");
    sprint(self, PRINT_HIGH, "Usage: setinfo <setting> <value>\n");
};

void () Help_ShowSoldier = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Soldier:\n");
    sprint(self, PRINT_HIGH, Q"\s1\s      - Equip Rocket Launcher\n");
    sprint(self, PRINT_HIGH, Q"\s2\s      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s2\s      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s4\s      - Equip Axe\n");
    sprint(self, PRINT_HIGH, Q"\sf\s      - Prime/throw Nail/Shock Grenade\n");
    sprint(self, PRINT_HIGH, Q"\smouse2\s - Prime/throw Hand Grenade\n");
};

void () Help_ShowDemoman = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Demolitions Man:\n");
    sprint(self, PRINT_HIGH, Q"\s1\s       - Equip Grenade Launcher\n");
    sprint(self, PRINT_HIGH, Q"\s2\s       - Equip Pipebomb Launcher\n");
    sprint(self, PRINT_HIGH, Q"\s2\s       - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s4\s       - Equip Axe\n");
    sprint(self, PRINT_HIGH, Q"\s5\s       - Detpack menu\n");
    sprint(self, PRINT_HIGH, Q"\se\s       - Detonate pipebombs\n");
    sprint(self, PRINT_HIGH, Q"\sf\s       - Prime/throw Mirv Grenade\n");
    sprint(self, PRINT_HIGH, Q"\smouse2\s  - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Demolitions Man:\n");
    sprint(self, PRINT_HIGH, Q"\sdetpipe\s - Detonate pipebombs\n");
    sprint(self, PRINT_HIGH, Q"\s+det5\s   - Place detpack with 5 second timer\n");
    sprint(self, PRINT_HIGH, Q"\s+det20\s  - Place detpack with 20 second timer\n");
    sprint(self, PRINT_HIGH, Q"\s+det50\s  - Place detpack with 50 second timer\n");
    sprint(self, PRINT_HIGH, Q"\s+det255\s - Place detpack with 255 second timer\n");
};

void () Help_ShowMedic = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Combat Medic:\n");
    sprint(self, PRINT_HIGH, Q"\s1\s      - Equip Super Nailgun\n");
    sprint(self, PRINT_HIGH, Q"\s2\s      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s2\s      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s4\s      - Equip Medikit\n");
    sprint(self, PRINT_HIGH, Q"\sf\s      - Prime/throw Concussion/Blast Grenade\n");
    sprint(self, PRINT_HIGH, Q"\smouse2\s - Prime/throw Hand Grenade\n");
};

void () Help_ShowHWGuy = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Heavy Weapons Guy:\n");
    sprint(self, PRINT_HIGH, Q"\s1\s      - Equip Assault Cannon\n");
    sprint(self, PRINT_HIGH, Q"\s2\s      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s2\s      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s4\s      - Equip Axe\n");
    sprint(self, PRINT_HIGH, Q"\sf\s      - Prime/throw Mirv Grenade\n");
    sprint(self, PRINT_HIGH, Q"\smouse2\s - Prime/throw Hand Grenade\n");
};

void () Help_ShowPyro = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Pyro:\n");
    sprint(self, PRINT_HIGH, Q"\s1\s      - Equip Flamethrower\n");
    sprint(self, PRINT_HIGH, Q"\s2\s      - Equip Incendiary Cannon\n");
    sprint(self, PRINT_HIGH, Q"\s2\s      - Equip Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s4\s      - Equip Axe\n");
    sprint(self, PRINT_HIGH, Q"\sf\s      - Prime/throw Napalm Grenade\n");
    sprint(self, PRINT_HIGH, Q"\smouse2\s - Prime/throw Hand Grenade\n");
};

void () Help_ShowSpy = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Spy:\n");
    sprint(self, PRINT_HIGH, Q"\s1\s      - Equip Tranquiliser Gun\n");
    sprint(self, PRINT_HIGH, Q"\s2\s      - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s2\s      - Equip Nailgun\n");
    sprint(self, PRINT_HIGH, Q"\s4\s      - Equip Knife\n");
    sprint(self, PRINT_HIGH, Q"\s5\s      - Disguise menu\n");
    sprint(self, PRINT_HIGH, Q"\se\s      - Silently feign death\n");
    sprint(self, PRINT_HIGH, Q"\sf\s      - Prime/throw Gas Grenade\n");
    sprint(self, PRINT_HIGH, Q"\smouse2\s - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Spy:\n");
    sprint(self, PRINT_HIGH, Q"\sfeign\s  - Feign death\n");
    sprint(self, PRINT_HIGH, Q"\s+feign\s  - Hold to feign death\n");
    sprint(self, PRINT_HIGH, Q"\ssfeign\s - Silently feign death\n");
};

void () Help_ShowEngineer = {
    sprint(self, PRINT_HIGH, "\nDefault bindings for Engineer:\n");
    sprint(self, PRINT_HIGH, Q"\s1\s            - Equip Railgun\n");
    sprint(self, PRINT_HIGH, Q"\s2\s            - Equip Super Shotgun\n");
    sprint(self, PRINT_HIGH, Q"\s4\s            - Equip Spanner\n");
    sprint(self, PRINT_HIGH, Q"\s4\s            - Build/destroy menu\n");
    sprint(self, PRINT_HIGH, Q"\sf\s            - Prime/throw EMP Grenade\n");
    sprint(self, PRINT_HIGH, Q"\smouse2\s       - Prime/throw Hand Grenade\n");
    sprint(self, PRINT_HIGH, "\nClass aliases for Engineer:\n");
    sprint(self, PRINT_HIGH, Q"\sdetdispenser\s - Detonate Dispenser\n");
    sprint(self, PRINT_HIGH, Q"\sdetsentry\s    - Detonate Sentry Gun\n");
};
