// Saved/Loaded/Restored by Settings funcs
DEFCVAR_FLOAT(FOCMD_GRENTIMER, 2);  // Sound + Ping adjust
DEFCVAR_STRING(FOCMD_GRENTIMERSOUND, "grentimer.wav");
DEFCVAR_FLOAT(FOCMD_GRENTIMERVOLUME, 1);
DEFCVAR_FLOAT(FOCMD_JUMPVOLUME, 1);
DEFCVAR_FLOAT(FOCMD_OLDSCOREBOARD, 0);

// CVARS that just pass via regular config state.
DEFCVAR_FLOAT(fo_hud_idle_alpha, 0.3);
DEFCVAR_FLOAT(FOCMD_ADMIN_MENU_UPDATE_TIME, 2);

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


void FO_WriteSettings()
{
    // this overwrites
    float filehandle;
    filehandle = fopen(FO_CONFIG_PATH, FILE_WRITE);
    string line = FormatCfgString("", FOCMD_GRENTIMER, ftos(CVARF(FOCMD_GRENTIMER)));
    line = FormatCfgString(line, FOCMD_GRENTIMERSOUND, CVARS(FOCMD_GRENTIMERSOUND));
    line = FormatCfgString(line, FOCMD_GRENTIMERVOLUME, ftos(CVARF(FOCMD_GRENTIMERVOLUME)));
    line = FormatCfgString(line, FOCMD_JUMPVOLUME, ftos(CVARF(FOCMD_JUMPVOLUME)));
    line = FormatCfgString(line, FOCMD_OLDSCOREBOARD, ftos(CVARF(FOCMD_OLDSCOREBOARD)));
    fputs(filehandle, line);
    fclose(filehandle);
}

void FO_LoadDefaultSettings()
{
    CVARF(FOCMD_GRENTIMER) = 2;
    CVARS(FOCMD_GRENTIMERSOUND) = "grentimer.wav";
    CVARF(FOCMD_GRENTIMERVOLUME) = 1;
    CVARF(FOCMD_JUMPVOLUME) = 1;
    CVARF(FOCMD_OLDSCOREBOARD) = 0;
}

void FO_LoadSettings()
{
    FO_LoadDefaultSettings();
    
	float filehandle;
    filehandle = fopen(FO_CONFIG_PATH, FILE_READ);
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
                    case FOCMD_GRENTIMER:
                        CVARF(FOCMD_GRENTIMER) = stof(val);
                        break;
                    case FOCMD_GRENTIMERSOUND:
                        CVARS(FOCMD_GRENTIMERSOUND) = val;
                        break;
                    case FOCMD_GRENTIMERVOLUME:
                        CVARF(FOCMD_GRENTIMERVOLUME) = stof(val);
                        break;
                    case FOCMD_JUMPVOLUME:
                        CVARF(FOCMD_JUMPVOLUME) = stof(val);
                        break;
                    case FOCMD_OLDSCOREBOARD:
                        CVARF(FOCMD_OLDSCOREBOARD) = stof(val);
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
        FO_WriteSettings();
    }
}
