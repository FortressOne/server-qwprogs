#pragma target fte
string prepq3fstring (string s);
float locationMultiplier;

void loadloc() {	
	locationMultiplier = TRUE;
	local float i;
	local string ln;
	local string out;
	local float locfilehandle;

	local string path = strcat("locs/", mapname);
	path = strcat(path, ".loc");
	locfilehandle = fopen(path, FILE_READ);
	if (locfilehandle >= 0) {
		ln = fgets(locfilehandle);
		while (ln) { // test for null
			if (ln != "") // test for empty
			{
				numlocs++;
			}
			
			ln = fgets(locfilehandle);
		}
		fclose(locfilehandle);

		locs = memalloc(sizeof(*locs)*numlocs);

	    locfilehandle = fopen(path, FILE_READ);
		ln = fgets(locfilehandle);
		i = 0;
		while (ln && i < numlocs) {
			ln = strtrim(ln);
			if (ln != "")
			{
				float s1 = strstrofs(ln, " ", 0);
				float s2 = strstrofs(ln, " ", s1+1);
				float s3 = strstrofs(ln, " ", s2+1);

				local string px   = substring(ln, 0, s1);
				local string py   = substring(ln, s1+1, (s2-(s1+1)));
				local string pz   = substring(ln, s2+1, (s3-(s2+1)));

				locs[i].pos.x = stof(px);
				locs[i].pos.y = stof(py); 
				locs[i].pos.z = stof(pz);
				locs[i].desc = substring(ln, s3+1, strlen(ln)-s3+2); 
				i++;
			}
			
			ln = fgets(locfilehandle);
		}
		fclose(locfilehandle);
		out = strcat("Loaded ", mapname);
		out = strcat(out, ".loc with ");
		out = strcat(out, ftos(numlocs));
		out = strcat(out, " locations\n");
	}
	else {
		out = strcat("Couldn't find ", mapname);
		out = strcat(out, ".loc\n");

		// check for q3f target_locations
		numlocs = 0;
		entity targ;
		targ = find(world, classname, "target_location");
		while (targ)
		{
			numlocs++;
			targ = find(targ, classname, "target_location");
		}

		if (numlocs > 0)
		{
			locationMultiplier = FALSE;
			locs = memalloc(sizeof(*locs)*numlocs);
			targ = find(world, classname, "target_location");
			i = 0;
			while (targ)
			{
				locs[i].pos = targ.origin;
				locs[i].desc = strtrim(prepq3fstring(targ.message));
				i++;
				targ.nextthink = time + 0.01;
				targ.think = SUB_Remove;
				targ = find(targ, classname, "target_location");
			}

			out = "Loaded locs from target_location entities\n";
		}
	}
	dprint(out);
}

string getLocationName(vector location) {
	local float bestdist;
	local string desc;
	local float i;

	desc = "someplace";
	location = location * ((locationMultiplier == TRUE) ? 8 : 1);
	bestdist = 0;
	for (i = 0; i < numlocs; i++) {
		float dist = vlen(location - locs[i].pos);
		if (bestdist == 0) {
			bestdist = dist;
			desc = locs[i].desc;
		}
		else if (dist < bestdist) {
			bestdist = dist;
			desc = locs[i].desc;
		}
	}
	return desc;
}