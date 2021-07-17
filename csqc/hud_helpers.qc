void Hud_WriteCfg(string path);
float GetDrawPanel(string id);
void SetDrawPanel(string id);
float GetPanelById(string id);

void FO_Hud_Editor()
{
    if (fo_hud_editor)
    {
        fo_hud_editor = FALSE;
        setcursormode(FALSE);

        Hud_WriteCfg(FO_HUD_CONFIG_PATH);
    }
    else
    {
        fo_hud_editor = TRUE;
        setcursormode(TRUE);
    }
}

float(float fo_align) fo_to_sui_aligntment = {
    switch(fo_align) {
        case HUD_ALIGN_RIGHT:
            return SUI_ALIGN_END;
        case HUD_ALIGN_LEFT:
            return SUI_ALIGN_START;
        case HUD_ALIGN_CENTER:
            return SUI_ALIGN_CENTER;
    }
    return HUD_ALIGN_CENTER;
};

void(string id, vector pos, vector size, vector minmaxsteps, __inout float value) hud_slider =
{
	sui_push_frame(pos, size);
	
	value = sui_slidercontrol(id, [0, 0], size, minmaxsteps, value, sui_slider_noop);
	float maxval = minmaxsteps[1];
	float sliderx = (value / maxval) * size_x;
	sui_fill([0, size_y * 0.25], [size_x, size_y * 0.5], MENU_BG_DARK, 1.0, 0);
	
	float is_active = sui_is_held(id) || (sui_is_hovered(id) && !sui_click_held());
	vector slider_ctrl_color = is_active ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON;
	sui_fill([sliderx - 2, 0], [4, size_y], slider_ctrl_color, 1.0, 0);
	
	sui_pop_frame();
};


vector UpdatePos(string id, vector mousepos)
{
    vector pos;
//    switch (id)
//    {
//        case "flagiconpanel":
//            if (HudSettings.MousePos != [0, 0])
//            {
//                pos = HudSettings.FlagIcon.Position + mousepos - HudSettings.MousePos;
//                HudSettings.FlagIcon.Position = pos;
//            }
//            break;

//        default:
            GetDrawPanel(id);
            pos = DrawPanel.Position + mousepos - HudSettings.MousePos;
            DrawPanel.Position = pos;
            SetDrawPanel(id);
//            break;
//    }

    return pos;
}

float(string id, vector pos, vector size, float alpha, float enabled) hud_panel =
{
    vector basecolor = MENU_BG;
    vector outlinecolour = enabled ? MENU_BORDER : MENU_UNSELECTED;

    if (fo_hud_editor)
    {
        sui_border_box(pos, size, 1, outlinecolour, 0.4, 0);
        if (sui_is_last_clicked(id))
        {
            sui_border_box(pos, size, 1, MENU_SELECTED, 0.4, 0);
        }

        if (sui_is_held(id))
        {          
            //pos = [Mouse.x, Mouse.y];
            //pos = UpdatePos(id, pos);
            UpdatePos(id, [Mouse.x, Mouse.y]);
            sui_border_box(pos, size, 1, MENU_SELECTED, 0.4, 0);
        }
        
        if (sui_is_hovered(id))
        {
            alpha = 0.6;
            basecolor = MENU_BG + MENU_HIGHLIGHT * 0.1;
            //FO_Hud_Panel hoverpanel = GetPanelById(id);
            //drawstring([Mouse.x, Mouse.y], hoverpanel.Name, '8 8', '1 0 0', 1, 0);
        }
        
        if (sui_is_held(id))
        {
            alpha = 0.6;
            basecolor = MENU_BG - MENU_DARKEN * 0.1;
        }
        // Make options panel switch back to last selected element after dragging
        if(sui_is_released(id) && id == "hudoptionspanel") {
            _last_clicked_actions[0] = Hud_Panels[Editor_SelectedPanel_Index].id;
        }
    }

    sui_push_frame(pos, size);

    sui_fill([0, 0], size, basecolor, alpha, 0);

    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_action_element([0, 0], size, id, sui_noop);
    sui_pop_frame();

    return sui_is_clicked(id);
};

// this draws backwards, haven't bothered to change as we don't use it
void Hud_DrawLargeValue(vector pos, float value, float threshhold, float size)
{
    float c;
    float len, i;
    string s;
    if (!size) size = 24;
    vector vsize = [size, size, 0];
    if (value < 0)
        value = 0;    //hrm
    s = ftos(floor(value));
    len = strlen(s);
    i = 0;
    if (value <= threshhold) {    //use alternate (red) numbers
        while(i<len) {
            i+=1;
            c = str2chr(s, len-i);
            drawpic(pos - [i * size, 0, 0], sprintf("anum_%g", c-'0'), vsize, '1 1 1', 1, 0);
        }
    } else {    //use normal numbers
        while(i<len) {
            i+=1;
            c = str2chr(s, len-i);
            drawpic(pos - [i * size, 0, 0], sprintf("num_%g", c-'0'), vsize, '1 1 1', 1, 0);
        }
    }
}

void Hud_DrawStringLMP(vector pos, string value, float size)
{
    float c;
    float len, i;
    string s;
    if (!size) size = 24;
    vector vsize = [size, size, 0];
    s = value;
    len = strlen(s);
    i = 0;

    while(i<len) {
        c = str2chr(s, i);
        if (c == 47) // "/"
        {
            // because i'm dodgy
            drawpic(pos + [i * size, 0, 0], "NUM_SLASH", vsize, '1 1 1', 1, 0);
        }
        else if (c == 37) // "%"
        {
            drawpic(pos + [i * size, 0, 0], "num_percent", vsize, '1 1 1', 1, 0);
        }
        else
        {
            drawpic(pos + [i * size, 0, 0], sprintf("num_%g", c-'0'), vsize, '1 1 1', 1, 0);
        }
        i+=1;
    }
}

string FormatCfgString(string line, string field, string value)
{
    line = strcat(line, "\n", field, ":", value);

    return line;
}

string FormatCfgVector(string line, string field, vector value)
{
    line = strcat(line, "\n", field, ":", strcat(ftos(value_x), ",", ftos(value_y)));

    return line;
}

string GetPanelString(string line, string name)
{
    line = FormatCfgVector(line, strcat(name, ".position"), DrawPanel.Position);
    line = FormatCfgString(line, strcat(name, ".scale"), ftos(DrawPanel.Scale));
    line = FormatCfgString(line, strcat(name, ".textscale"), ftos(DrawPanel.TextScale));
    line = FormatCfgString(line, strcat(name, ".display"), ftos(DrawPanel.Display));
    line = FormatCfgString(line, strcat(name, ".nodeinsertloc"), ftos(DrawPanel.Orientation));
    line = FormatCfgString(line, strcat(name, ".snap"), ftos(DrawPanel.Snap));
    line = FormatCfgString(line, strcat(name, ".style"), ftos(DrawPanel.Style));

    return line;
}

float firstrun;
void FO_Hud_Editor_LoadSettings()
{
    vector vsize = (vector)getproperty(VF_SCREENVSIZE);
    float width = vsize_x;
    float height = vsize_y;
    fo_hud_editor = FALSE;

    FO_Hud_Editor_LoadDefaultSettings();

    HudSettings.MousePos = [0, 0];
    firstrun = TRUE;

    // fte does weird stuff and writes/reads this to/from a "gamedir/data/file"
    float filehandle;
    filehandle = fopen(FO_HUD_CONFIG_PATH, FILE_READ);
	if (filehandle >= 0) {
        // get number of lines                  
        string ln;
        ln = fgets(filehandle);
        while (ln)
        {
            if (strlen(ln) > 0)
            {
                ln = strreplace("\n", "", ln);
                string val, field;

                float x = 0, y = 0;
                float count = tokenizebyseparator(ln, ":");
                field = argv(0);
                field = strtrim(field);
                val = argv(1);
                val = strtrim(val);

                switch(field)
                {

                    default:
                        count = tokenizebyseparator(field, ".");
                        string pnl;
                        pnl = argv(0);
                        GetDrawPanel(pnl);

                        switch (argv(1))
                        {
                            case "position":
                                count = tokenizebyseparator(val, ",");
                                x = stof(argv(0));
                                y = stof(argv(1));
                                DrawPanel.Position = [x, y];
                                break;
                            case "scale":
                                DrawPanel.Scale = stof(val);
                                break;
                            case "textscale":
                                DrawPanel.TextScale = stof(val);
                                break;
                            case "display":
                                DrawPanel.Display = stof(val);
                                break;
                            case "nodeinsertloc":
                                DrawPanel.Orientation = stof(val);
                                break;
                            case "snap":
                                DrawPanel.Snap = stof(val);
                                break;
                            case "style":
                                DrawPanel.Style = stof(val);
                                break;
                        }
                        
                        SetDrawPanel(pnl);
                        break;
                }
            }
            ln = fgets(filehandle);
        }
        fclose(filehandle);
    }
    else
    {
        // write a new file
        Hud_WriteCfg(FO_HUD_CONFIG_PATH);
    }
    if(Hud_Panels[HUD_PANEL_MENU].Position.x < 0) Hud_Panels[HUD_PANEL_MENU].Position.x = 10;
    if(Hud_Panels[HUD_PANEL_MENU].Position.y < 0) Hud_Panels[HUD_PANEL_MENU].Position.y = 10;
    if(Hud_Panels[HUD_PANEL_MENU].Position.x + Hud_Panels[HUD_PANEL_MENU].FillSize.x > vsize_x) Hud_Panels[HUD_PANEL_MENU].Position.x = vsize_x / 2 - Hud_Panels[HUD_PANEL_MENU].FillSize.x / 2;
    if(Hud_Panels[HUD_PANEL_MENU].Position.y + Hud_Panels[HUD_PANEL_MENU].FillSize.y > vsize_y) Hud_Panels[HUD_PANEL_MENU].Position.y = 64;


}

void GetNewPanel(vector pos, vector fillSize, float scale, float display, float orientation, string name)
{
    FO_Hud_Panel pnl;

    pnl.Position = pos;
    pnl.FillSize = fillSize;
    pnl.Scale = scale;
    pnl.Display = display;
    pnl.Orientation = orientation;
    pnl.Name = name;

    NewPanel = pnl;
}

// draws value string using lmps
void Hud_DrawPanelLMP(FO_Hud_Panel* panel, string val, string icon)
{
    if (!panel || (!panel.Display && !fo_hud_editor))
        return;
    
    vector pos;
    pos = getPanelPosition(panel); //getPosition(fid); //DrawPanel.Position;

    if (hud_panel(panel.id, pos, panel.FillSize * panel.Scale, 0, panel.Display))
    {
        // click event
        if (fo_hud_editor)
        {

        }
    }

    vector size = FO_Hud_Icon_Size * panel.Scale;
    pos = [pos_x + 2, pos_y + 2, 0];
    drawpic(pos, icon, size, '1 1 1', 1, 0);

    float len;
    len = strlen(val);
    float offset = (panel.Orientation == FO_HUD_INSERT_BEFORE) ? 2 + size_x : (2 + (size_x * len)) * -1;

    pos = [pos_x + offset, pos_y, 0];
    float textScale = panel.TextScale ? panel.TextScale : panel.Scale;
    Hud_DrawStringLMP(pos, val, 24 * textScale);
}

vector GetStringOffsetPos(string msg, vector size, vector fontSize, vector pos, vector basepos, float newline)
{
    float len, offset;
    len = strlen(msg);
    offset = (DrawPanel.Orientation == FO_HUD_INSERT_BEFORE) ? 2 + size_x : (2 + size_x + (fontSize_x * len)) * -1;
    pos = [basepos_x + offset, newline ? pos_y + 2 + ((size_y - fontSize_y) * .5) : pos_y + ((size_y - fontSize_y) * .5), 0];

    return pos;
}

vector DrawOffsetString(string msg, vector size, vector fontSize, vector pos, vector basepos, float newline, vector colour)
{
    pos = GetStringOffsetPos(msg, size, fontSize, pos, basepos, newline);
    drawstring(pos, msg, fontSize, colour, 1, 0);

    return pos;
}

void AddGrenTimer(float grentype) {
    for(float i = 0; i < FO_Hud_Grentimers.length; i++) {
        if(FO_Hud_Grentimers[i].grentype == 0) {
            FO_Hud_Grentimers[i].grentype = grentype;
            FO_Hud_Grentimers[i].icon_index = grentype;
            FO_Hud_Grentimers[i].expires = time + 3.8;
            break;
        }
    }
}
