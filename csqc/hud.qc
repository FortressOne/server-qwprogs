float GetDrawPanel(string id)
{
    for(float i = 0; i < Hud_Panels.length; i++) {
        if(Hud_Panels[i].id == id) {
            DrawPanel = Hud_Panels[i];
            return i;
        }
    }
    return -1;
}

void SetDrawPanel(string id)
{
        for(float i = 0; i < Hud_Panels.length; i++) {
        if(Hud_Panels[i].id == id) {
            Hud_Panels[i] = DrawPanel;
        }
    }
}

float GetPanelById(string id) = {
    for(float i = 0; i < Hud_Panels.length; i++) {
        if(Hud_Panels[i].id == id) {
            return i;
        }
    }
    return 0;
}

void Hud_WriteCfg(string path)
{
    // this overwrites
    float filehandle;
    filehandle = fopen(path, FILE_WRITE);
    string line = "";

    for(float i = 0; i < Hud_Panels.length; i++) {
        DrawPanel = Hud_Panels[i];
        line = GetPanelString(line, Hud_Panels[i].id);
    }

    fputs(filehandle, line);
    fclose(filehandle);
}

void FO_Hud_Editor_LoadDefaultSettings()
{
    Hud_Panels[HUD_PANEL_HUDOPTIONS].drawPanel = Hud_DrawHudOptionsPanel;
    vector vsize = (vector)getproperty(VF_SCREENVSIZE);
    float width = vsize_x;
    float height = vsize_y;

    // check struct, put defaults in
    float yoffset = height - 64;

    // TODO - maybe implement these to allow for pivoting of items
/*
    vector pos, fill;
    float scale, display, Orientation;
    pos = [width - 8 - FO_HUD_CLIPSIZE_PANEL_X, height - 8 - FO_HUD_CLIPSIZE_PANEL_Y];
    scale = 1;
    display = 1;
    Orientation = FO_HUD_INSERT_BEFORE;
    fill = [FO_HUD_CLIPSIZE_PANEL_X, FO_HUD_CLIPSIZE_PANEL_Y];
    
    for(float i = 0; i < Hud_Panels.length; i++) {
        pos = [pos_x, pos_y - 2 - 24];
        Hud_Panels[i].Position = pos;
        //Hud_Panels[i].FillSize = fillSize;
        Hud_Panels[i].Scale = scale;
        Hud_Panels[i].Display = display;
        Hud_Panels[i].Orientation = Orientation;
        //pnl.Name = name;
    }
*/

    //Default menus, id, ready and MOTD to centre of the screen
    Hud_Panels[HUD_PANEL_GAME_MODE].Position = [width - Hud_Panels[HUD_PANEL_GAME_MODE].FillSize.x, 30];
    Hud_Panels[HUD_PANEL_GAME_MODE].Orientation = FO_HUD_INSERT_AFTER;
    Hud_Panels[HUD_PANEL_MOTD].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_MOTD].FillSize.x / 2), 30];
    Hud_Panels[HUD_PANEL_READY].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_READY].FillSize.x / 2), 30];
    Hud_Panels[HUD_PANEL_MENU_HINT].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_MENU].FillSize.x / 2), 80];
    Hud_Panels[HUD_PANEL_MENU_HINT].Orientation = FO_HUD_INSERT_MIDDLE;
    Hud_Panels[HUD_PANEL_MENU].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_MENU].FillSize.x / 2), 120];
    Hud_Panels[HUD_PANEL_IDENTIFY].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_IDENTIFY].FillSize.x / 2), height - 100];
    Hud_Panels[HUD_PANEL_CLIPSIZE].Position = [(width / 2) + 16, height - 50];
    Hud_Panels[HUD_PANEL_CLIPSIZE].Scale = 0.75;
    Hud_Panels[HUD_PANEL_GREN1].Position = [(width / 2) - 16 - (Hud_Panels[HUD_PANEL_GREN1].FillSize.x * 2), height - 50];
    Hud_Panels[HUD_PANEL_GREN1].Scale = 0.75;
    Hud_Panels[HUD_PANEL_GREN2].Position = [(width / 2) - 16 - Hud_Panels[HUD_PANEL_GREN2].FillSize.x * 0.75, height - 50];
    Hud_Panels[HUD_PANEL_GREN2].Scale = 0.75;
    Hud_Panels[HUD_PANEL_GRENTIMER].Position = [(width / 2) + 16, (height / 2) + 32];
    Hud_Panels[HUD_PANEL_GRENTIMER].Scale = 0.75;
    Hud_Panels[HUD_PANEL_FLAGINFO].Orientation = FO_HUD_INSERT_AFTER;
    Hud_Panels[HUD_PANEL_FLAGINFO].Position = [width - 24, (height / 2) - 8];
    Hud_Panels[HUD_PANEL_FRAGSTREAK].Display = 0;
    Hud_Panels[HUD_PANEL_CAPS].Display = 0;
    Hud_Panels[HUD_PANEL_PLAYERCLASS].Position = [0, 180];
    Hud_Panels[HUD_PANEL_SHOWSCORES].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_SHOWSCORES].FillSize.x / 2), 30];
    Hud_Panels[HUD_PANEL_SHOWSCORES].Scale = 1.00;
    Hud_Panels[HUD_PANEL_TEAM_SCORE].Position = [(width - Hud_Panels[HUD_PANEL_TEAM_SCORE].FillSize.x), 0];
    Hud_Panels[HUD_PANEL_MAP_MENU].Position = [(width / 2) - (Hud_Panels[HUD_PANEL_MAP_MENU].FillSize.x / 2), 30];
    Hud_Panels[HUD_PANEL_MAP_MENU].Scale = 1.00;
}

void FO_Hud_Editor_List_Panels() = {
    print("^1Available HUD Elements:^7\n");
    for(float i = 0; i < Hud_Panels.length; i++) {
        print(Hud_Panels[i].id, ": ", Hud_Panels[i].Name, "\n");
    }
}

string FO_Hud_Editor_Get_Panel_Setting(string panelid, string setting) = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        print("^1HUD Element^7 '", panelid, "' does not exist!\n");
        return "";
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    switch (setting) {
        case "id":
            return panel.id;
        case "name":
            return panel.Name;
        case "position":
            return vtos(panel.Position);
        case "size":
            return vtos(panel.FillSize);
        case "scale":
            return ftos(panel.Scale);
        case "textscale":
            return ftos(panel.TextScale);
        case "show":
            return ftos(panel.Display);
        case "orientation":
            return ftos(panel.Orientation);
        case "snap":
            return ftos(panel.Snap);
        default:
            print("^1Setting^7 '", setting, "' does not exist!\n");
            break;
    }
    return "";
}

void FO_Hud_Editor_Show_Panel(string panelid) = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        print("^1HUD Element^7 '", panelid, "' does not exist!\n");
        return;
    }
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    print("^1id^7: ", panel.id, "\n");
    print("\tname: ", panel.Name, "\n");
    print("\tposition: ", vtos(panel.Position), "\n");
    print("\tsize: ", vtos(panel.FillSize), "\n");
    print("\tscale: ", ftos(panel.Scale), "\n");
    print("\ttextscale: ", ftos(panel.TextScale), "\n");
    print("\tshow: ", ftos(panel.Display), "\n");
    print("\torientation: ", ftos(panel.Orientation), "\n");
    print("\tsnap: ", ftos(panel.Snap), "\n");
}

void FO_Hud_Editor_Print_Panel_Setting(string panelid, string setting) = {
    if(panelid == "help" || panelid == "?") {
        print("^1orientation^7: Extends from base to the... 0 = Left, 1 = Right, 2 = Middle (where applicable)\n");
        print("^1snap^7: 0 = None, Horzontal: 1/2/4 = Left/Centre/Right, Vertical: 8/16/32 = Top/Middle/Bottom)\n");
        return "";
    }
    if(setting == "") {
        FO_Hud_Editor_Show_Panel(panelid);
    } else {
        print(FO_Hud_Editor_Get_Panel_Setting(panelid, setting), "\n");
    }
}

void FO_Hud_Editor_Set_Panel_Setting(string panelid, string setting, string value) = {
    float id = getHudPanel(panelid);
    if(id < 0) {
        print("^1HUD Element^7 '", panelid, "' does not exist!\n");
        return;
    }
    
    float val = 0;
    
    FO_Hud_Panel* panel = getHudPanelPointer(id);
    switch (setting) {
        case "id":
            print("^5id ^1can't be changed^7!\n");
            break;
        case "name":
            print("^5name ^1can't be changed^7!\n");
            break;
        case "position":
            panel.Position = stov(value);
            break;
        case "size":
            panel.FillSize = stov(value);
            break;
        case "scale":
            panel.Scale = stof(value);
            break;
        case "textscale":
            panel.TextScale = stof(value);
            break;
        case "show":
            panel.Display = stof(value);
            break;
        case "orientation":
            panel.Orientation = stof(value);
            break;
        case "snap":
            val = stof(value);
            if(val) {
                if(val & 1 || val & 2 || val & 4) {
                    panel.Position.x = 0;
                }
                if(val & 8 || val & 16 || val & 32) {
                    panel.Position.y = 0;
                }
            } else {
                panel.Position = getPosition(id);
            }
            panel.Snap = val;
            break;
        default:
            print("^1Setting^7 '", setting, "' does not exist!\n");
            break;
    }
}

/*
 * pos = x coord of the UI box
 * width = x width of the UI box
 * iconsize = x width of the icon (text will start before/after it); offset
 * text = actual text to display
 * textsize = fontsize
 * align = alignment
 */
float GetTextAlignOffset(float pos, float width, float iconsize, string text, float textsize, float align)  {
    if(align == FO_HUD_INSERT_AFTER) {
        return pos - strlen(text) * textsize + width - iconsize;
    } else if(align == FO_HUD_INSERT_MIDDLE) {
        return pos + (width / 2) - ((strlen(text) * textsize) / 2);
    }
    return pos + iconsize;
}
//MEHT this is a sui example thing
void(string id, vector pos, vector size, string name, string command) bind_button =
{
	sui_push_frame(pos, size);
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
	string key = "A"; //sui_binder(id, [0, 0], size, name, command);
	if (sui_is_hovered(id)) sui_fill([0, 0], size, MENU_HIGHLIGHT, 0.1, 0);
	sui_text([6, 0], MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
	sui_text([-6, 0], MENU_TEXT_SMALL, key, MENU_TEXT_1, 1, 0);
	
	sui_pop_frame();
};

void (float dx, float dy) Hud_MapMenuPanel_Move = {
    FO_Hud_Panel* panel = &Hud_Panels[HUD_PANEL_MAP_MENU];
    if(
        Mouse.x > panel.Position.x && 
        Mouse.y > panel.Position.y && 
        Mouse.x < (panel.Position.x + panel.FillSize.x * panel.Scale) && 
        Mouse.y < (panel.Position.y + panel.FillSize.y * panel.Scale)
    ) {
        panel.Position.x += dx;
        panel.Position.y += dy;
    }
};

void(string panelid) Hud_DrawMapMenuPanel = {
    float id = getHudPanel(panelid);

    if(id < 0) {
        return;
    }

    FO_Hud_Panel* panel = getHudPanelPointer(id);
    local vector fillsize = panel.FillSize * panel.Scale;
    local float alpha = fo_hud_editor?0.2:0.9;
    local vector position = getPosition(id);
    if(panel.Display) {
        setcursormode(TRUE);
    }
    if (hud_panel(panelid, position, fillsize, alpha, panel.Display)) {
        // click event
        if (fo_hud_editor) {
            
        }
    }

    if(fo_hud_editor) {
        return;
    }
    
    local vector bgcolour = MENU_BG_DARK, textcolour = MENU_TEXT_1;
    local float textscale = 1, padding = 4, cnt = 0;
    local float titlesize = 12;
    local float listitemhover = FALSE;
    local vector listitemsize = [100, 10], listitempos = [0,0];
    if(panel.TextScale) {
        textscale = panel.TextScale;
    } else {
        textscale = panel.Scale;
    }
    listitemsize.y = listitemsize.y * textscale;
    titlesize = titlesize * textscale;
    padding = padding * panel.Scale;
    listitemsize.x = listitemsize.y * MAP_MAX_CHARS; //20 chars of mapname

    local vector listviewsize = [listitemsize.x, fillsize.y - padding * 3 - listitemsize.y];
    local float visiblelistitems = floor(listviewsize.y / listitemsize.y);
 
     //Window title
    sui_push_frame(position + [padding,padding], [fillsize.x - padding * 2, titlesize]);
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_text([padding, 0], [titlesize,titlesize], "Map Selection", MENU_TEXT_4, 1, 0);
    sui_pop_frame();

    //Filter textbox
    if(vote_list_filter != "") {
        sui_push_frame(position + [padding,padding], listitemsize + [0,padding]);
        //sui_border_box([0,0], listitemsize, 1, MENU_BG_DARK, 0.6, 0);
        sui_fill([0,0], listitemsize + [0,padding], MENU_BG_DARK, 0.6, 0);
        sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
        sui_text([0, 0], [listitemsize.y, listitemsize.y], vote_list_filter, MENU_TEXT_2, 1, 0);
        sui_pop_frame();
    }

    vector listoffset;
/*
	sui_list_view_begin(strcat("a", "scrl"), panel.Position + [200,4], [100, 150], [94, 10], num_mapvotes, listoffset, [0, 6]);
	vector listitem_pos = '0 0 0';
	for (float index = sui_list_item(listitem_pos); index > -1; index = sui_list_item(listitem_pos))
	{
		sui_push_frame(listitem_pos, [94, 10]);
		//bind_button(strcat("b", ftos(index)), [0, 0], [94, 24], "index is ", ftos(index));
        hud_button(strcat("b", ftos(index)), listitem_pos, [94, 24], "index is ", ftos(index));
        //drawstring(listitem_pos, strcat("a", ftos(index)), [8,8], MENU_TEXT_2, 1, 0);
    
		sui_pop_frame();
	}
	sui_list_view_end();	
*/
    //sui_scroll_view_begin("scrolltest", panel.Position + [200,4], [100,100], [100,200], listoffset, [2,6]);
    //sui_scroll_view_end();
    sui_border_box(position + [padding, padding * 2 + titlesize], listviewsize, 1, MENU_TEXT_SPEC_FO, 0.6, 0);
    if(vote_list_offset > num_mapvotes_filtered - visiblelistitems) {
        vote_list_offset = num_mapvotes_filtered - visiblelistitems;
    }
    if(vote_list_offset < 0) {
        vote_list_offset = 0;
    }
    entity mc = find(world, classname, "map_candidate_filtered");
    while(mc) {
        if(cnt >= vote_list_offset) {
            listitempos = position + [padding, padding * 2 + titlesize + listitemsize.y * (cnt - vote_list_offset)];
            if((listitempos.y + listitemsize.y + padding) > (position.y + fillsize.y)) {
                //too many to fit
                break;
            }
            listitemhover = (Mouse.x > listitempos.x && Mouse.y > listitempos.y && Mouse.x < (listitempos.x + listitemsize.x) && Mouse.y < (listitempos.y + listitemsize.y));
            if(listitemhover) {
                bgcolour = MENU_BORDER; //MENU_UNSELECTED;
            } else {
                bgcolour = MENU_BG_DARK;
            }
            if(vote_selected_index < 0) {
                vote_selected_index = 0;
            }
            if(vote_selected_index >= num_mapvotes_filtered) {
                vote_selected_index = num_mapvotes_filtered - 1;
            }
            if(vote_selected_index == cnt) {
                vote_selected_item = mc;
            }
            if(!vote_selected_item) {
                vote_selected_item = mc;
                vote_selected_index = cnt;
            }
            if(mc == vote_selected_item) {
                alpha = 1;
                bgcolour = MENU_BG_WARNING;
            } else {
                alpha = 0.4;
            }
            //sui_border_box(listitempos, listitemsize, 1, bgcolour, 0.4, 0);
            //sui_fill(listitempos, listitemsize, bgcolour, alpha, 0);
            //sui_text(listitempos, [listitemsize.y, listitemsize.y], mc.name, textcolour, alpha, 0);
            sui_push_frame(listitempos, listitemsize);
            if(current_vote && mc.owner == current_vote) {
                textcolour = MENU_TEXT_GREEN;
            } else if(mc.owner.votecount > 0) {
                textcolour = MENU_TEXT_WARNING;
            } else {
                textcolour = MENU_TEXT_1;
            }
            if(hud_colour_button(strcat("listitem",ftos(cnt)),[0,0], listitemsize, mc.owner.name, bgcolour, [listitemsize.y, listitemsize.y], textcolour, SUI_ALIGN_START, 2, alpha, alpha, 1)) {
                vote_selected_item = mc;
                vote_selected_index = cnt;
            }
            if(mc.owner.votecount > 0) {
                sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
                sui_text([padding * -1, 0], [listitemsize.y, listitemsize.y], ftos(mc.owner.votecount), MENU_TEXT_4, alpha, 0);
            }
            sui_pop_frame();
        }
        cnt++;
        mc = find(mc, classname, "map_candidate_filtered");
    }
    if(cnt < num_mapvotes_filtered) {
        //draw scrollbar here
        //sui_scrollbar("maplist_scrollbar", [listitemsize.x, fillsize.y - padding * 3 - listitemsize.y], [listitemsize.x,listitemsize.y * num_mapvotes], listoffset, [0,6]);
    }
        
    sui_border_box(position, fillsize, 1, MENU_BORDER, 0.6, 0);

    //Map heading
    vector mapheadingpos = [position.x + padding * 2 + listviewsize.x, position.y + padding * 2 + titlesize];
    float mapinfowidth = fillsize.x - (mapheadingpos.x - position.x);
    sui_push_frame(mapheadingpos, [mapinfowidth, titlesize]);
    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_text([padding, 0], [titlesize,titlesize], (vote_selected_item?vote_selected_item.owner.name:"No map selected"), MENU_TEXT_3, 1, 0);
    sui_pop_frame();
    
    if(!vote_selected_item) {
        return;
    }
    
    float current_vote_selected = FALSE;
    if(current_vote && current_vote == vote_selected_item.owner) {
        current_vote_selected = TRUE;
    }

    //Map image
    float filehandle;
    string levelshot = strcat("textures/levelshots/",vote_selected_item.owner.name,".jpg"); //need to fix extensions somehow
    filehandle = fopen(levelshot, FILE_READ);
    if (filehandle >= 0) {
        fclose(filehandle);
        ////Make it half the width of the map info area and aspect of 1.25:1 
        //vector levelshotsize = [mapinfowidth / 2, mapinfowidth * 2 / 5];
        //No, make it 16:9 and 2/3 of the width
        vector levelshotsize = [mapinfowidth * 2 / 3, mapinfowidth * 2 * 9 / (3 * 16)];
        sui_push_frame([mapheadingpos.x + mapinfowidth - levelshotsize.x - padding,mapheadingpos.y + titlesize + padding * 2], levelshotsize);
        sui_pic([0,0], levelshotsize, levelshot, [1,1,1], 1, 0);
        sui_border_box([0,0], levelshotsize, 1, MENU_TEXT_GREEN, 0.6, 0);
        sui_pop_frame();
    } else {
        //placeholder maybe?
    }

    //Map details
    float mapdetailgridindex = 0;
    sui_push_frame(mapheadingpos + [0,titlesize + padding * 2], [mapinfowidth - levelshotsize.x, titlesize]);
    if(vote_selected_item.owner.group) {
        sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
        sui_text([padding, (titlesize + padding) * mapdetailgridindex], [titlesize,titlesize], "Type:", MENU_TEXT_2, 1, 0);
        sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
        sui_text([-2 * padding, (titlesize + padding) * mapdetailgridindex], [titlesize,titlesize], vote_selected_item.owner.groupname, MENU_TEXT_2, 1, 0);
        mapdetailgridindex++;
    }
    if(vote_selected_item.owner.team_num) {
        sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
        sui_text([padding, (titlesize + padding) * mapdetailgridindex], [titlesize,titlesize], "Teams:", MENU_TEXT_2, 1, 0);
        sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
        sui_text([-2 * padding, (titlesize + padding) * mapdetailgridindex], [titlesize,titlesize], ftos(vote_selected_item.owner.team_num), MENU_TEXT_2, 1, 0);
        mapdetailgridindex++;
    }
    if(vote_selected_item.owner.min_val || vote_selected_item.owner.max_val) {
        string playernumstring = "";
        if(vote_selected_item.owner.min_val && vote_selected_item.owner.max_val) {
            if(vote_selected_item.owner.min_val == vote_selected_item.owner.max_val) {
                playernumstring = strcat(ftos(vote_selected_item.owner.min_val));
            } else {
                playernumstring = strcat(ftos(vote_selected_item.owner.min_val),"-",ftos(vote_selected_item.owner.max_val));
            }
        } else if(vote_selected_item.owner.min_val) {
            playernumstring = strcat(ftos(vote_selected_item.owner.min_val),"+");
        } else {
            playernumstring = strcat(ftos(vote_selected_item.owner.max_val),"-");
        }
        sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
        sui_text([padding, (titlesize + padding) * mapdetailgridindex], [titlesize,titlesize], "Players:", MENU_TEXT_2, 1, 0);
        sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
        sui_text([-2 * padding, (titlesize + padding) * mapdetailgridindex], [titlesize,titlesize], playernumstring, MENU_TEXT_2, 1, 0);
        mapdetailgridindex++;
    }
    sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
    sui_text([padding, (titlesize + padding) * mapdetailgridindex], [titlesize,titlesize], "Client-side:", MENU_TEXT_2, 1, 0);
    sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
    sui_text([-2 * padding, (titlesize + padding) * mapdetailgridindex], [titlesize,titlesize], vote_selected_item.owner.localmap?"\x10\x8f\x11":"\x10 \x11", MENU_TEXT_2, 1, 0);
    mapdetailgridindex++;
    if(vote_selected_item.owner.votecount) {
        if(current_vote_selected) {
            textcolour = MENU_TEXT_GREEN;
        } else {
            textcolour = MENU_TEXT_WARNING;
        }
        sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
        sui_text([padding, (titlesize + padding) * mapdetailgridindex], [titlesize,titlesize], "Votes:", textcolour, 1, 0);
        sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
        sui_text([-2 * padding, (titlesize + padding) * mapdetailgridindex], [titlesize,titlesize], strcat(ftos(vote_selected_item.owner.votecount),(current_vote_selected?" (yours)":"")), textcolour, 1, 0);
        mapdetailgridindex++;
    }
    sui_pop_frame();


    //Map description
    vector descriptionpos = [mapheadingpos.x,position.y + fillsize.y - padding * 4 - titlesize - listitemsize.y * 3]
    sui_push_frame(descriptionpos, [mapinfowidth - padding * 2, listitemsize.y * 3]);
    sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
    sui_text([padding / 2, padding / 2], [listitemsize.y,listitemsize.y], vote_selected_item.owner.description, MENU_TEXT_1, 1, 0);
    //sui_border_box([0,0], [fillsize.x - (mapheadingpos.x - panel.Position.x), listitemsize.y * 3], 1, MENU_BORDER, 0.6, 0);
    sui_border_box([0,0], [mapinfowidth - padding, listitemsize.y * 3], 1, MENU_BORDER, 0.6, 0);
    sui_pop_frame();
    
    sui_push_frame(descriptionpos + [0, listitemsize.y * 3 + padding], [mapinfowidth - padding * 2, listitemsize.y * 3]);
    sui_set_align([SUI_ALIGN_END, SUI_ALIGN_START]);
    if(current_vote_selected) {
        if(hud_colour_button("vote_button", [0,0], listitemsize + [0,padding], "Unvote", MENU_BUTTON, [listitemsize.y,listitemsize.y], MENU_TEXT_1, SUI_ALIGN_CENTER, 0, 1, 1, 0)) {
            localcmd("cmd break\n");
            //current_vote = world;
        }
    } else {
        if(hud_colour_button("vote_button", [0,0], listitemsize + [0,padding], "Vote", MENU_BUTTON, [listitemsize.y,listitemsize.y], MENU_TEXT_1, SUI_ALIGN_CENTER, 0, 1, 1, 0)) {
            localcmd("cmd votemap ", vote_selected_item.owner.name, "\n");
        }
    }
    if(hud_colour_button("change_button", [0 - listitemsize.x - padding,0], listitemsize + [0,padding], "Change Now", MENU_BUTTON, [listitemsize.y,listitemsize.y], MENU_TEXT_WARNING, SUI_ALIGN_CENTER, 0, 1, 1, 0)) {
        if(is_admin) {
            localcmd("cmd map ", vote_selected_item.owner.name, "\n");
        } else {
            localcmd("rcon map ", vote_selected_item.owner.name, "\n");
        }
    }

    sui_pop_frame();
    
}

void(string panelid) Hud_DrawTeamScorePanel = {
    float id = getHudPanel(panelid);

    if(id < 0) {
        return;
    }

    float alpha = 0;
    FO_Hud_Panel* panel = getHudPanelPointer(id);

    //vector size = getFillSize(id);
    float textScale = panel.Scale; //panel.TextScale; //panel.TextScale?panel.TextScale:panel.Scale;
    //float sizex, sizey;
    //sizex = size_x;
    //sizey = size_y;
    //vector mediumtext = MENU_TEXT_SMALL * textScale;
    local float padding = 0.5; // * textScale;

    local vector fillsize = [12,12]; // * textScale; //mediumtext;
    fillsize_x = fillsize_x * 3;
    fillsize_y = fillsize_y + padding * 2;
    panel.FillSize = fillsize;
    fillsize = fillsize * textScale;
    vector position = getPanelPosition(panel);

    if (hud_panel(panelid, position, fillsize, alpha, Hud_Panels[HUD_PANEL_TEAM_SCORE].Display))
    {
        // click event
        if (fo_hud_editor)
        {
        }
    }

    local float offset;
    local vector score_position = position;
    local string message = "";
    if(panel.Orientation == FO_HUD_INSERT_AFTER) {
        position_x = position_x - ((number_of_teams - 1) * fillsize_x);
    } else if(panel.Orientation == FO_HUD_INSERT_MIDDLE) {
        position_x = position_x - (((number_of_teams - 1) * fillsize_x) / 2);
    }
    float len;
    float textOffset;
    string val;

    for(float i = 0; i < number_of_teams; i++) {
        score_position = position;
        offset = (fillsize_x) * i;
        score_position_x = score_position_x + offset;
        //message = strcat(message, strpad(-3, ftos(TS.team1score)));
        drawfill(score_position, fillsize, TEXT_TEAM_COLOUR[i], 0.5, 0);
        val = ftos(TeamScore[i]);
        len = strlen(val);
        textOffset = (12 * textScale * (3 - len));
        Hud_DrawStringLMP(score_position + [textOffset,padding], val, 12 * textScale);
    }
};

void Hud_DrawFlagStatusBar(string panelid)
{
    vector pos;
    float sizey, sizex;
    sizey = FO_Hud_Icon_Size_y * Hud_Panels[HUD_PANEL_FLAGINFO].Scale;
    sizex = FO_Hud_Icon_Size_x * Hud_Panels[HUD_PANEL_FLAGINFO].Scale;

    float flagInfoCount = 0;
    for (float i = FlagInfoLines.length - 1; i >= 0; i--) 
    {
		if (FlagInfoLines[i].id) 
        {
            flagInfoCount++;
        }
    }
    //Show one for reference even on maps without
    if(fo_hud_editor && !flagInfoCount) {
        flagInfoCount = 1;
    }
    vector fillsize = [sizex * 4, sizey * flagInfoCount];
    Hud_Panels[HUD_PANEL_FLAGINFO].FillSize = fillsize;
    //pos = getPosition(HUD_PANEL_FLAGINFO); //Hud_Panels[HUD_PANEL_FLAGINFO].Position;
    pos = getScaledPanelPosition(getHudPanelPointer(HUD_PANEL_FLAGINFO), 1);
    float alpha = 0;
    if (hud_panel(panelid, pos, fillsize, alpha, Hud_Panels[HUD_PANEL_FLAGINFO].Display))
    {
        // click event
        if (fo_hud_editor)
        {
            
        }
    }
    
    for (float i = 0; i < flagInfoCount; i++) 
    {
		if (FlagInfoLines[i].id) 
        {
	    alpha = FlagInfoLines[i].state == FLAGINFO_HOME ? cvar("fo_hud_idle_alpha") : 1;
	    string icon = FlagInfoLines[i].icon.filename;
	    vector iconcolour = FlagInfoLines[i].icon.colour;
        float bigfont = 8 * (Hud_Panels[HUD_PANEL_FLAGINFO].TextScale ? Hud_Panels[HUD_PANEL_FLAGINFO].TextScale : Hud_Panels[HUD_PANEL_FLAGINFO].Scale);
        float bigfontvoffset = sizey / 2 - bigfont / 2; //Center text against the icon
            if (FlagInfoLines[i].state == FLAGINFO_CARRIED) 
            {
			    // drawstring([pos_x + sizex, pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].carrier, [bigfont,bigfont], '1 0 0', 1, 0);
			    drawstring([GetTextAlignOffset(pos_x,sizex,sizex,FlagInfoLines[i].carrier,bigfont,Hud_Panels[HUD_PANEL_FLAGINFO].Orientation), pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].carrier, [bigfont,bigfont], '1 0 0', 1, 0);
			} 
            else if (FlagInfoLines[i].state == FLAGINFO_DROPPED && FlagInfoLines[i].locname) 
            {
			    // drawstring([pos_x + sizex, pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].locname, [bigfont,bigfont], '1 1 1', 1, 0);
			    drawstring([GetTextAlignOffset(pos_x,sizex,sizex,FlagInfoLines[i].locname,bigfont,Hud_Panels[HUD_PANEL_FLAGINFO].Orientation), pos_y + bigfontvoffset + sizey * i, 0], FlagInfoLines[i].locname, [bigfont,bigfont], '1 1 1', 1, 0);
			}
			
            drawpic([pos_x, pos_y + sizey * i, 0], icon, [sizex, sizey, 0], iconcolour, alpha, 0);
			
            if (FlagInfoLines[i].timeleft >= 0) 
            {
			    string stime = ftos(FlagInfoLines[i].timeleft);
                float smallfont = 6 * Hud_Panels[HUD_PANEL_FLAGINFO].Scale;
			    drawstring([pos_x + sizex - stringwidth(stime, 1, [smallfont, smallfont]), pos_y + sizey * (i + 1) - smallfont, 0], stime, [smallfont, smallfont], '1 1 1', 1, 0);
			}
		}
    }
}

void Hud_ScrollPanelSelector(float num, float numlines) {
    float newpos = Hud_Panels[HUD_PANEL_HUDOPTIONS].Status + num;
    if(newpos < 1) {
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Status = 1;
    } else if(newpos > (Hud_Panels.length - numlines)) {
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Status = Hud_Panels.length - (numlines - 1);
    } else {
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Status = newpos;
    }
}

//Draw the list of all panels
void Hud_DrawHudOptionsPanelSelector() {
    if(!fo_hud_editor)
        return;
    vector pos = getPosition(HUD_PANEL_HUDOPTIONS); //Hud_Panels[HUD_PANEL_HUDOPTIONS].Position; //Start with option panel's pos
    vector size = Hud_Panels[HUD_PANEL_HUDOPTIONS].FillSize * Hud_Panels[HUD_PANEL_HUDOPTIONS].Scale; //for simplicity, use the same size as options panel
    float textsize = 8 * (Hud_Panels[HUD_PANEL_HUDOPTIONS].TextScale ? Hud_Panels[HUD_PANEL_HUDOPTIONS].TextScale : Hud_Panels[HUD_PANEL_HUDOPTIONS].Scale);
    if((pos.x + (size.x * 2)) < ScreenSize.x) {
        //If there's room on the screen, draw to the right of options panel
        pos.x = pos.x + size.x;
    } else {
        pos.x = pos.x - size.x;
    }
    
    if (hud_panel("hud_option_panel_list", pos, size, 0, 1))
    {
        // click event
    }

    float numlines = rint(size.y / (textsize + 2));
    //Need to draw scrollbar?
    if((Hud_Panels.length * (textsize + 2)) > size.y) {
        //Scrollbar buttons
        if(hud_button("hud_option_panel_list_scrollup", pos + [size.x - textsize - 2,2], [textsize, textsize], "^")) {
            Hud_ScrollPanelSelector(-1, numlines);
        }
        if(hud_button("hud_option_panel_list_scrolldown", pos + [size.x - textsize - 2, size.y - textsize - 2], [textsize, textsize], "v")) {
            Hud_ScrollPanelSelector(1, numlines);
        }
    }
    for(float i = 0,j = 0; i < min(numlines, Hud_Panels.length); i++) {
        j = i + Hud_Panels[HUD_PANEL_HUDOPTIONS].Status - 1;
        if(hud_button(strcat("hud_option_panel_list_item", ftos(i)), pos + [2, (textsize + 2) * i], [size.x - textsize - 4, textsize + 2], Hud_Panels[j].Name)) {
            Editor_SelectedPanel_Index = j;
        }
    }
}

void Hud_DrawHudOptionsPanel(string panelid, float display, string text, string icon)
{
    if(!fo_hud_editor)
        return;
    
    vector pos = getPosition(HUD_PANEL_HUDOPTIONS); //Hud_Panels[HUD_PANEL_HUDOPTIONS].Position;
    vector size = Hud_Panels[HUD_PANEL_HUDOPTIONS].FillSize * Hud_Panels[HUD_PANEL_HUDOPTIONS].Scale;
    if (hud_panel(Hud_Panels[HUD_PANEL_HUDOPTIONS].id, pos, size, 0, Hud_Panels[HUD_PANEL_HUDOPTIONS].Display))
    {
        // click event
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Status = 0;
    }
        
    FO_Hud_Panel* selectedPanel = &Hud_Panels[Editor_SelectedPanel_Index];
    
    //drawstring(pos + [4,4], selectedPanel.Name, [8,8], MENU_SELECTED, 1, 0);
    if(hud_button("hud_option_panel_list_button", pos + [4,2], [140, 10], strcat(selectedPanel.Name, " >"))) {
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Status = !Hud_Panels[HUD_PANEL_HUDOPTIONS].Status;
    }
    
    float fscale = selectedPanel.Scale;
    drawstring(pos + [4,12], strcat("Scale: ",ftos(rint(fscale * 100)), "%"), [8,8], MENU_SELECTED, 1, 0);
    hud_slider("hud_option_scale_scroll", pos + [8,24], [136,8], [0.2,5.0,24], fscale);
    if(fscale != selectedPanel.Scale) {
        Hud_Panels[Editor_SelectedPanel_Index].Scale = fscale;
    }
    float ftscale = selectedPanel.TextScale;
    drawstring(pos + [4,34], strcat("Text Scale: ",ftos(rint(ftscale * 100)), "%"), [8,8], MENU_SELECTED, 1, 0);
    hud_slider("hud_option_textscale_scroll", pos + [8,44], [136,8], [0,5.0,25], ftscale);
    if(ftscale != selectedPanel.TextScale) {
        Hud_Panels[Editor_SelectedPanel_Index].TextScale = ftscale;
    }    
    float ftextalign = selectedPanel.Orientation;
    //drawstring(pos + [4,54], strcat("Text Pos: ", selectedPanel.Orientation ? "Left" : "Right"), [8,8], MENU_SELECTED, 1, 0);
    drawstring(pos + [4,60], "Text Pos: ", [8,8], MENU_SELECTED, 1, 0);
    if(hud_button("hud_option_textalign_toggle", pos + [size.x - 6 - 56,56], [56, 16], HUD_ALIGN[selectedPanel.Orientation])) {
        Hud_Panels[Editor_SelectedPanel_Index].Orientation = (selectedPanel.Orientation + 1) % 3;
    }
    //hud_slider("hud_option_textalign_scroll", pos + [8,64], [32,8], [0,1,1], ftextalign);
    //if(ftextalign != selectedPanel.Orientation) {
    //    Hud_Panels[Editor_SelectedPanel_Index].Orientation = ftextalign;
    //}    
    if(hud_button("hud_option_show_hide_toggle", pos + [4,74], [140, 16], selectedPanel.Display ? "Hide Panel" : "Show Panel")) {
        Hud_Panels[Editor_SelectedPanel_Index].Display = !selectedPanel.Display;
    }
    drawstring(pos + [4,96],"Position: ", [8,8], MENU_SELECTED, 1, 0);
    drawstring(pos + [10,106], strcat("x: ",ftos(selectedPanel.Position.x)), [8,8], MENU_SELECTED, 1, 0);
    drawstring(pos + [10,116], strcat("y: ",ftos(selectedPanel.Position.y)), [8,8], MENU_SELECTED, 1, 0);

    local float snap = 0;
    local string ssnap;
    if(Hud_Panels[Editor_SelectedPanel_Index].Snap & 2) {
        snap = 1;
    } else if(Hud_Panels[Editor_SelectedPanel_Index].Snap & 4) {
        snap = 2;
    } else {
        snap = 0;
    }
    drawstring(pos + [4,130], "Hor. Snap: ", [8,8], MENU_SELECTED, 1, 0);
    if(hud_button("hud_option_hsnap_toggle", pos + [size.x - 6 - 56,126], [56, 16], HUD_HORIZONTAL_ALIGN[snap])) {
        snap = (snap + 1) % 3;
        Hud_Panels[Editor_SelectedPanel_Index].Position.x = 0;
        Hud_Panels[Editor_SelectedPanel_Index].Snap -= (Hud_Panels[Editor_SelectedPanel_Index].Snap & 7);
        Hud_Panels[Editor_SelectedPanel_Index].Snap += pow(2,snap);
    }
    if(Hud_Panels[Editor_SelectedPanel_Index].Snap & 16) {
        snap = 1;
    } else if(Hud_Panels[Editor_SelectedPanel_Index].Snap & 32) {
        snap = 2;
    } else {
        snap = 0;
    }
    drawstring(pos + [4,148], "Ver. Snap: ", [8,8], MENU_SELECTED, 1, 0);
    if(hud_button("hud_option_vsnap_toggle", pos + [size.x - 6 - 56,144], [56, 16], HUD_VERTICAL_ALIGN[snap])) {
        snap = (snap + 1) % 3;
        Hud_Panels[Editor_SelectedPanel_Index].Position.y = 0;
        Hud_Panels[Editor_SelectedPanel_Index].Snap -= (Hud_Panels[Editor_SelectedPanel_Index].Snap & 56);
        Hud_Panels[Editor_SelectedPanel_Index].Snap += pow(2,(snap + 3));
    }
    
    if(hud_button("hud_option_show_all_toggle", pos + [4,162], [140, 16], Hud_Panels[HUD_PANEL_HUDOPTIONS].Style ? "Show All" : "Hide Disabled")) {
        Hud_Panels[HUD_PANEL_HUDOPTIONS].Style = !Hud_Panels[HUD_PANEL_HUDOPTIONS].Style;
    }

    if(Hud_Panels[HUD_PANEL_HUDOPTIONS].Status) {
        Hud_DrawHudOptionsPanelSelector();
    }
}

void Hud_DrawClassInfoPanel(string id, float playerclass)
{
    vector pos;
    pos = getPosition(HUD_PANEL_PLAYERCLASS); //DrawPanel.Position;

    if(fo_hud_editor) {
        hud_panel(id, pos, DrawPanel.FillSize * DrawPanel.Scale, 0, DrawPanel.Display);
        drawpic(pos, "textures/wad/face1.png", FO_Hud_Icon_Size * DrawPanel.Scale, '1 1 1', 1, 0);
        return;
    }
    
    if (!fo_hud_editor && !DrawPanel.Display)
        return;

    switch (SBAR.PlayerClass)
    {
        case PC_SOLDIER:
            return;
    }

    if (SBAR.PlayerClass)
    {

        if (hud_panel(id, pos, DrawPanel.FillSize * DrawPanel.Scale, 0, DrawPanel.Display))
        {
            // click event
            if (fo_hud_editor)
            {

            }
        }

        float val;
        vector size = FO_Hud_Icon_Size * DrawPanel.Scale;
        vector fontSize = FO_Hud_Icon_Font_Size * (DrawPanel.TextScale ? DrawPanel.TextScale : DrawPanel.Scale);
        pos = [pos_x + 2, pos_y + 2, 0];
        vector basepos = pos;
        vector colour = '1 1 1';
        string icon = "";
        string msg = "";

        //icon = HudIcons[playerclass-1].icon;
        /* icon = HudIcons[playerclass+6].icon; */
        /* drawpic(pos, icon, size, '1 1 1', 1, 0); */

        float len = 0, offset = 0;

        switch (playerclass)
        {
            case PC_SCOUT:
                icon = ICON_SCOUT; //HudIcons[playerclass+6].icon;
                drawpic(pos, icon, size, '1 1 1', 1, 0);

                msg = SBAR.ScannerOn ? "Scanning" : "Offline";
                pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                if (SBAR.ScannerOn)
                {
                    msg = SBAR.ScannerRange ? strcat("Dist: ", ftos(SBAR.ScannerRange)) : "No targets";
                    pos = DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    if (SBAR.ScannerRange)
                    {
                        msg = (SBAR.ScannerTeamNo == team_no) ? "Friendly" : "Enemy";
                        msg = strcat(msg, " ", ClassToString(SBAR.ScannerPlayerClass));
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                }
                break;
            case PC_SNIPER:
                if (SBAR.SniperDam)
                {
                    icon = ICON_SNIPER; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = strcat("Dam: ", ftos(SBAR.SniperDam));
                    pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                    
                    if (SBAR.SniperMax)
                    {
                        msg = "(100%)";
                        colour = '1 0 0';
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                }
                break;
            case PC_DEMOMAN:
                if (SBAR.IsDetpacking)
                {
                    icon = ICON_DEMOMAN; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = "Setting";
                    pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);

                    msg = strcat(ftos(SBAR.DetpackLeft), " (", ftos(SBAR.IsDetpacking), ") secs left");
                    DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                }
                else if (SBAR.DetpackLeft)
                {
                    icon = ICON_DEMOMAN; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = strcat(ftos(SBAR.DetpackLeft), " secs left");
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                break;
            case PC_MEDIC:
                icon = ICON_MEDIC; //HudIcons[playerclass+6].icon;
                drawpic(pos, icon, size, '1 1 1', 1, 0);

                msg = SBAR.AuraActive ? "On" : "Off";
                pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                if (SBAR.AuraActive)
                {
                    if (SBAR.HealCount)
                    {
                        msg = strcat(ftos(SBAR.HealCount), " players healed");
                        pos = DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);

                        msg = strcat("for ", ftos(SBAR.HealAmount), " hp");
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                    else
                    {
                        if (SBAR.AuraStatus == PC_MEDIC_AURA_OUTOFPOWER)
                        {
                            msg = "Out of power";
                            DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                        }
                        else if (SBAR.AuraStatus == PC_MEDIC_AURA_RECHARGING)
                        {
                            msg = "Recharging";
                            DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                        }
                    }
                }
                break;
            case PC_HVYWEAP:
                if (SBAR.LockedCannon)
                {
                    icon = ICON_HWGUY; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = "Assault Cannon Locked";
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);    
                }
                break;
            case PC_PYRO:
                if (SBAR.AirBlast)
                {
                    icon = ICON_PYRO; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = "Airblast Cooling Down";
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);    
                }
                else if (!SBAR.AirBlast)
                {
                    icon = ICON_PYRO; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = "Airblast Ready";
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);    
                }
                break;
            case PC_SPY:
                if (SBAR.IsUndercover == 1)
                {
                    icon = ICON_SPY; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    if (SBAR.InvisOnly)
                    {
                        msg = "Invisible";
                        DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                    }
                    else
                    {
                        msg = "Undercover";
                        pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                        msg = strcat(TeamToString(SBAR.UndercoverTeam), " ", ClassToString(SBAR.UndercoverSkin));
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                }
                else if (SBAR.IsUndercover == 2)
                {
                    icon = ICON_SPY; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    if (SBAR.InvisOnly)
                    {
                        msg = "Invisible";
                        pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                        msg = strcat("In ", ftos(SBAR.UndercoverTimer), " secs");
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                    else
                    {
                        msg = "Disguising";
                        pos = DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                        if (SBAR.DisguiseTeam)
                        {
                            msg = strcat("(", TeamToString(SBAR.DisguiseTeam), SBAR.QueueSkin ? "" : ") ");
                        }
                        else if (SBAR.QueueTeam)
                        {
                            msg = strcat("(", TeamToString(SBAR.QueueTeam), " ");
                        }
                        else if (SBAR.UndercoverTeam)
                        {
                            msg = strcat(TeamToString(SBAR.UndercoverTeam), " ");
                        }
                        string msg2 = "";
                        if (SBAR.DisguiseSkin)
                        {
                            msg2 = strcat(SBAR.QueueTeam ? "" : "(", ClassToString(SBAR.DisguiseSkin), ")");
                        }
                        else if (SBAR.QueueSkin)
                        {
                            msg2 = strcat(" ", ClassToString(SBAR.QueueSkin), ")");
                        }
                        else if (SBAR.UndercoverSkin)
                        {
                            msg2 = strcat(ClassToString(SBAR.UndercoverSkin));
                        }
                        msg = strcat(msg, msg2);
                        DrawOffsetString(msg, size, fontSize, pos, basepos, TRUE, colour);
                    }
                }
                break;
            case PC_ENGINEER:
                if (SBAR.HasSentry)
                {
                    icon = ICON_ENGINEER_SG; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = strcat("L: ", ftos(SBAR.SentryLevel), " H: ", ftos(rint(SBAR.SentryHealth)), " S: ", ftos(rint(SBAR.SentryAmmoShells)), " R: ", ftos(rint(SBAR.SentryAmmoRockets)));
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                else if (SBAR.IsBuilding)
                {
                    icon = ICON_ENGINEER_SG; //HudIcons[playerclass+6].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = strcat(ftos(SBAR.BuildingPercentage), "%");
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                
                // disp
                pos = [pos_x, pos_y + size_y + 2];
                basepos = pos;
                if (SBAR.HasDispenser)
                {
                    icon = ICON_ENGINEER_DISP; //HudIcons[playerclass + 7].icon;
                    drawpic(pos, icon, size, '1 1 1', 1, 0);

                    msg = strcat("H: ", ftos(rint(SBAR.DispenserHealth)));
                    DrawOffsetString(msg, size, fontSize, pos, basepos, FALSE, colour);
                }
                break;
        }
    }
}

void Hud_DrawIdentifyPanel(string id, string identify)
{
    if (!DrawPanel.Display && !fo_hud_editor)
        return;
        
    if(fo_hud_editor && !identify) {
        identify = "<Player Name>\n<Player Class>";
    }

    vector pos;
    pos = DrawPanel.Position;

    if (hud_panel(id, pos, DrawPanel.FillSize * DrawPanel.Scale, 0, DrawPanel.Display))
    {
        // click event
        if (fo_hud_editor)
        {

        }
    }

    vector fontSize = FO_Hud_Icon_Font_Size * DrawPanel.Scale;

    float count = tokenizebyseparator(identify, "\n");
    float msgcount = 0;
    string msg = "";
    for (float f = 0; f <= count; f++)
    {
        msg = argv(f);
        // tokenize doesn't handle newlines very well
        msg = strreplace("\n", "", msg);
        msg = strtrim(msg);
        if (strlen(msg) > 0)
        {
            pos = pos + [0, (fontSize_y * msgcount), 0];
            drawstring(pos, msg, fontSize, '1 1 1', 1, 0);
            msgcount++;
        }
    }
}

void Hud_Draw(float width, float height)
{
    float offset = 0;
    for(float i = 0; i < Hud_Panels.length; i++) {
        if(sui_is_last_clicked(Hud_Panels[i].id)) {
            Editor_SelectedPanel_Index = i;
        }
        if(!Hud_Panels[HUD_PANEL_HUDOPTIONS].Style || Hud_Panels[i].Display || (fo_hud_editor && i == Editor_SelectedPanel_Index)) {
            Hud_Panels[i].drawPanel( Hud_Panels[i].id,  Hud_Panels[i].Display, Hud_Panels[i].getValue(), HudIcons[i].icon);
            //Draw panel names when editing
            if(fo_hud_editor && Hud_Panels[i].id != "hudoptionspanel") {
                switch (Hud_Panels[i].Orientation) {
                    case FO_HUD_INSERT_BEFORE:
                        offset = 2;
                        break;
                    case FO_HUD_INSERT_AFTER:
                        offset = Hud_Panels[i].FillSize.x - (strlen(Hud_Panels[i].Name) * 6) - 2;
                        break;
                    case FO_HUD_INSERT_MIDDLE:
                        offset = (Hud_Panels[i].FillSize.x / 2) - (strlen(Hud_Panels[i].Name) * 3); //because 3 = 6/2
                        break;
                }
                //drawstring(Hud_Panels[i].Position + [offset,2], Hud_Panels[i].Name, '6 6', '0 1 0', 1, 0);
                drawstring(getScaledPanelPosition(getHudPanelPointer(i),1) + [offset,2], Hud_Panels[i].Name, '6 6', '0 1 0', 1, 0);
            }
        }
    }

    HudSettings.MousePos = [Mouse.x, Mouse.y];
}
