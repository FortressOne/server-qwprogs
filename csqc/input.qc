void Menu_Cancel();
void FO_Menu_Game(float);

// TRUE --> capture input
// FALSE --> pass input on
float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent = {
    if (fo_hud_editor || fo_hud_menu_active) {
        sui_input_event(evtype, scanx, chary, devid);
        float menu_mouse = (fo_hud_menu_active && (CurrentMenu.flags & FO_MENU_FLAG_USE_MOUSE));

        switch (evtype) {
            case IE_KEYDOWN:
                if (scanx == K_ESCAPE) {
                    Menu_Cancel();
                    FO_Hud_Editor_Cancel();
                    return TRUE;  // Always capture escape
                } else if (fo_hud_menu_active)
                    return fo_menu_process_input(CurrentMenu, scanx);
                break;
            case IE_MOUSEABS:
                Mouse.x = scanx;
                Mouse.y = chary;
                break;
        }

        return fo_hud_editor;  // capture iff hud-editor
    } else if(getHudPanel(HUDP_MAP_MENU)->Display) {
        sui_input_event(evtype, scanx, chary, devid);

        switch (evtype) {
            case IE_MOUSEDELTA:
                return TRUE;
            case IE_MOUSEABS:
                PrevMouse.x = Mouse.x;
                PrevMouse.y = Mouse.y;
                Mouse.x = scanx;
                Mouse.y = chary;
                if (sui_is_held(HUDP_MAP_MENU))
                    Hud_MapMenuPanel_Move(Mouse.x - PrevMouse.x, Mouse.y - PrevMouse.y);
                return TRUE;
             case IE_KEYDOWN:
                switch (scanx) {
                    case K_ESCAPE:
                        return TRUE;
                    case K_MOUSE1:
                        return TRUE;
                    case K_UPARROW:
                        vote_selected_index--;
                        vote_list_offset--;
                        return TRUE;
                    case K_DOWNARROW:
                        vote_selected_index++;
                        vote_list_offset++;
                        return TRUE;
                    case K_PGUP:
                        vote_selected_index -= 10;
                        vote_list_offset -= 10;
                        return TRUE;
                    case K_PGDN:
                        vote_selected_index +=10;
                        vote_list_offset +=10;
                        return TRUE;
                    case K_MWHEELUP:
                        vote_list_offset--;
                        return TRUE;
                    case K_MWHEELDOWN:
                        vote_list_offset++;
                        return TRUE;
                    case K_ENTER:
                        if(vote_selected_item && current_vote == vote_selected_item.owner) {
                            localcmd("cmd break\n");
                        } else {
                            localcmd("cmd votemap ", vote_selected_item.owner.name, "\n");
                        }
                        return TRUE;
                    case K_BACKSPACE:
                         if(strlen(vote_list_filter) > 0) {
                            vote_list_filter = substring(vote_list_filter, 0, strlen(vote_list_filter) - 1); 
                            ApplyMapFilter();
                        }
                        return TRUE;
                    case K_DEL: //blank it out
                        if(strlen(vote_list_filter) > 0) {
                            vote_list_filter = "";
                            ApplyMapFilter();
                        }
                        return TRUE;
                    default:
                        //48 = '0' .. 57 = '9'
                        //97 = 'a' .. 122 = 'z'
                        //45 = '-'
                        if((scanx >= 48 && scanx <= 57) || (scanx >= 97 && scanx <= 122) || scanx == 45) {
                            if(strlen(vote_list_filter) < MAP_MAX_CHARS) {
                                vote_list_filter = strcat(vote_list_filter, chr2str(chary));
                                ApplyMapFilter();
                            }
                            return TRUE;
                        }
                }
             case IE_KEYUP:
                switch (scanx) {
                    case K_ESCAPE:
                        showVoteMenu(FALSE);
                        return TRUE;
                    case K_MOUSE1:
                        return TRUE;
                }
            }
    } else {
        switch (evtype)
        {
            case IE_KEYDOWN:
                switch (scanx)
                {
                    case K_ESCAPE:
                        FO_Menu_Game(TRUE);
                        return TRUE;
                }
                break;
        }
    }

    return FALSE;
}
