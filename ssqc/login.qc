void (entity player, string login, string secret) performLogin = {
	string data = strcat("login=", login);
	data = strcat(data,"&secret=");
	data = strcat(data,secret);	
	uri_get(loginUrl, 10, "application/x-www-form-urlencoded", data);
	self.login_in_progress = 1;
	dprint(infokey(self,"name"));
	dprint(" [");
	dprint(infokey(self,"ip"));
	dprint("]");
	dprint(" trying to login as ");
	dprint(login);
	dprint("\n");
}

void(float reqid, float responsecode, string resourcebody) URI_Get_Callback = {
	self.login_in_progress = 0;	
	local float csqcactive = infokeyf(self, INFOKEY_P_CSQCACTIVE);
	if (!responsecode) {		
		float num_args = tokenizebyseparator(resourcebody,";");
		self.login = argv(0);
		forceinfokey(self,"*login", self.login);
		bprint(2, infokey(self,"name"));
		bprint(2, " has logged in as \s");
		bprint(2, self.login);
		bprint(2, "\s\n");
		dprint(infokey(self,"name"));
		dprint(" logged in as ");
		dprint(self.login);
		dprint("\n");
		CenterPrint3(self, "You have logged in as ", self.login, "\n");
		if (num_args > 1) {
			if (argv(1) == "true") {
				self.is_admin = TRUE;
				Admin_Aliases ();
				bprint2 (2, self.netname, " \sgains full admin status!\s\n");
//				bprint (3, "\n");
				sprint (self, 2, "Type \scommands\s for admin commands.\n");
			}
		}
		if(self.team_no == 0 && !intermission_running ) {
			if (csqcactive)
            	Menu_Team(0);
            else
            	Menu_Team(1);
        }
	}
	else {
		dprint(infokey(self,"name"));
		dprint(" login failed: ");
		dprint(self.login);
		dprint("\n");
		CenterPrint3(self, ftos(responsecode), " - Login FAILED, invalid Login/Secret", "\n");
	}
}
