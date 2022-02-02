class fo_logic : entity
{
    float if_goal_no;
    float if_group_no;
    string if_fieldname;
    float compare_goal_no;
    float compare_group_no;
    string compare_fieldname;

    float activate_goal_no_if_equal;
    float activate_goal_no_if_not_equal;
    float activate_goal_no_if_less_than;
    float activate_goal_no_if_greater_than;
    float activate_group_no_if_equal;
    float activate_group_no_if_not_equal;
    float activate_group_no_if_less_than;
    float activate_group_no_if_greater_than;
    float set_value_on_goal_no_if_equal;
    float set_value_on_goal_no_if_not_equal;
    float set_value_on_goal_no_if_less_than;
    float set_value_on_goal_no_if_greater_than;
    string set_from_fieldname;
    float set_from_goal_no;
    string set_to_fieldname;
    float set_to_goal_no;

    float fieldtype;
    float compare_fieldtype;
    float set_fieldnum;
    float fieldnum_used;
    .__variant fieldref;
    .__variant compare_fieldref;
    .__variant test;

    void () fo_logic =
    {
        float argc = tokenize(__fullspawndata)-1;
        for (float i = 1; i < argc;)
        {
            string field = argv(i++);
            string val = argv(i++);
            float i2 = findentityfield(strcat(this.classname, "::__m", field));
            
            if (i2)
            {
                putentityfieldstring(i2, this, val);
            }
        }

        if (!if_goal_no && !if_group_no)
        {
            bprint(PRINT_HIGH, "fo_logic entity with netname: '", this.netname, "' does not have if_goal_no or if_group_no set!\n");
            remove(this);
            return;
        }

        if (!compare_goal_no && !compare_group_no)
        {
            bprint(PRINT_HIGH, "fo_logic entity with netname: '", this.netname, "' does not have compare_goal_no or compare_group_no set!\n");
            remove(this);
            return;
        }

        if (this.if_fieldname == __NULL__)
            this.if_fieldname = "";

        if (this.if_fieldname == "")
        {
            bprint(PRINT_HIGH, "fo_logic entity with netname: '", this.netname, "' does not have fieldname set!\n");
            remove(this);
            return;
        }

        if (this.compare_fieldname == __NULL__)
            this.compare_fieldname = "";

        if (this.compare_fieldname == "")
        {
            bprint(PRINT_HIGH, "fo_logic entity with netname: '", this.netname, "' does not have compare_fieldname set!\n");
            remove(this);
            return;
        }

        if (!activate_goal_no_if_equal && !activate_goal_no_if_not_equal
            && !activate_goal_no_if_less_than && !activate_goal_no_if_greater_than
            && !activate_group_no_if_equal && !activate_group_no_if_not_equal
            && !activate_group_no_if_less_than && !activate_group_no_if_greater_than
            && (!set_to_goal_no && !set_from_goal_no))
        {
            bprint(PRINT_HIGH, "fo_logic entity with netname: '", this.netname, "' does not have any values in activate_goal_no_if_equal, activate_goal_no_if_not_equal, activate_goal_no_if_less_than, activate_goal_no_if_greater_than, activate_group_no_if_equal, activate_group_no_if_not_equal, activate_group_no_if_less_than, activate_group_no_if_greater_than,, set_to_goal_no, set_from_goal_no!\n");
            remove(this);
            return;
        }

        float fieldnum = findentityfield(this.if_fieldname);
        fieldtype = entityfieldtype(fieldnum);

        float compare_fieldnum = findentityfield(this.compare_fieldname);
        compare_fieldtype = entityfieldtype(compare_fieldnum);

        if (fieldtype != compare_fieldtype)
        {
            bprint(PRINT_HIGH, "fo_logic entity with netname: '", this.netname, "' cannot compare if_fieldname and compare_fieldname due to mismatched types!\n");
            remove(this);
            return;
        }
        fieldref = entityfieldref(fieldnum);
        compare_fieldref = entityfieldref(compare_fieldnum);

        if (this.set_to_fieldname == __NULL__)
            this.set_to_fieldname = "";

        if (this.set_to_fieldname != "")
        {
            set_fieldnum = findentityfield(this.set_to_fieldname);
            fieldnum_used = TRUE;
        }
    };

    nonvirtual void () SetValue =
    {
        if (!fieldnum_used)
            return;
        if (!set_from_goal_no)
            return;

        float fieldnum = findentityfield(this.set_from_fieldname);
        float set_fieldtype = entityfieldtype(fieldnum);
        entity from = findfloat(world, ::goal_no, set_from_goal_no);
        .__variant set_fieldref = entityfieldref(fieldnum);
        string set_value = __NULL__;
        switch (set_fieldtype)
        {
            case EV_STRING:
                set_value = from.((.string)set_fieldref);
                break;
            case EV_FLOAT:
                set_value = ftos(from.((.float)set_fieldref));
                break;
        }
        
        entity to = findfloat(world, ::goal_no, set_to_goal_no);
        float set_to_fieldnum = findentityfield(this.set_to_fieldname);
        if (!putentityfieldstring(set_to_fieldnum, to, set_value))
        {
            bprint(PRINT_HIGH, "fo_logic entity with netname: '", this.netname, "' set_value failed!\n");
        }
    };

    nonvirtual void (float gno) ActivateGoal =
    {
        if (!gno)
            return;
        
        entity act = findfloat(world, ::goal_no, gno);
        if (act)
        {
            AttemptToActivate(act, other, this);
        }
            
    };

    nonvirtual void (float gno) ActivateGroup =
    {
        if (!gno)
            return;

        entity act = findfloat(world, ::group_no, gno);
        while (act)
        {
            AttemptToActivate(act, other, this);
            act = findfloat(act, ::group_no, gno);
        }   
    };

    nonvirtual void (entity goal, entity compare_goal) CompareGoals =
    {
        entity act = world;
        switch (fieldtype)
        {
            case EV_STRING:
                string sval = goal.((.string)fieldref);
                string compare_sval = compare_goal.((.string)compare_fieldref);
                if (sval == compare_sval)
                {
                    this.SetValue();
                    this.ActivateGoal(activate_goal_no_if_equal);
                    this.ActivateGroup(activate_group_no_if_equal);
                }
                else
                {
                    this.ActivateGoal(activate_goal_no_if_not_equal);
                    this.ActivateGroup(activate_group_no_if_not_equal);
                }
                break;
            case EV_FLOAT:
                float fval = goal.((.float)fieldref);
                float compare_fval = compare_goal.((.float)compare_fieldref);

                if (fval == compare_fval)
                {
                    this.SetValue();
                    this.ActivateGoal(activate_goal_no_if_equal);
                    this.ActivateGroup(activate_group_no_if_equal);
                }
                else
                {
                    this.ActivateGoal(activate_goal_no_if_not_equal);
                    this.ActivateGroup(activate_group_no_if_not_equal);
                }

                if (fval > compare_fval)
                {
                    this.ActivateGoal(activate_goal_no_if_greater_than);
                    this.ActivateGroup(activate_group_no_if_greater_than);
                }
                else if (fval < compare_fval)
                {
                    this.ActivateGoal(activate_goal_no_if_less_than);
                    this.ActivateGroup(activate_group_no_if_less_than);
                }
                break;
            default:
                // TODO - lazy, don't want to do this right now
                bprint(PRINT_HIGH, "fo_logic entity can only compare fields that are string or float\n");
                break;
        }
    };

    nonvirtual void (entity goal) ExecuteLogic =
    {
        entity compare_goal = world;
        if (this.compare_goal_no)
        {
            compare_goal = findfloat(world, ::goal_no, compare_goal_no);
            if (compare_goal)
            {
                this.CompareGoals(goal, compare_goal);
            }
        }

        if (this.compare_group_no)
        {
            compare_goal = world;
            compare_goal = findfloat(world, ::group_no, compare_group_no);

            while (compare_goal)
            {
                this.CompareGoals(goal, compare_goal);
                compare_goal = findfloat(compare_goal, ::group_no, compare_group_no);
            }
        }
    };

    virtual void () use =
    {
        float gnum = this.if_goal_no;
        entity goal = world;

        if (gnum)
        {
            goal = findfloat(world, ::goal_no, gnum);
            if (goal)
            {
                this.ExecuteLogic(goal);
            }
        }
        
        gnum = this.if_group_no;
        if (gnum)
        {
            goal = world;
            goal = findfloat(world, ::group_no, gnum);

            while (goal)
            {
                this.ExecuteLogic(goal);
                goal = findfloat(goal, ::group_no, gnum);
            }
        }
    };
};