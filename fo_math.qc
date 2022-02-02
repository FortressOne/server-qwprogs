class fo_math : entity
{
    float value;
    float min_value;
    float max_value;

    float add;
    float subtract;
    float multiply;
    float divide;

    float activate_goal_no_on_max_value;
    float activate_goal_no_on_min_value;

    float perform_reset_on_max_value;
    float perform_reset_on_min_value;
    float reset_value_on_max_value;
    float reset_value_on_min_value;

    // state
    float hit_max_value;
    float hit_min_value;

    nonvirtual void (float hit_value, float activate_goal_no) ValidateValue =
    {
        entity act = world;

        // only execute once after it is past the max/min value
        if (!hit_value)
        {
            if (activate_goal_no)
            {
                act = findfloat(world, ::goal_no, activate_goal_no);
                if (act)
                    AttemptToActivate(act, other, this);
            }
        }
    };

    nonvirtual void () Process =
    {
        entity act = world;
        value = value + add;
        if (value > max_value)
        {
            ValidateValue(hit_max_value, activate_goal_no_on_max_value);
            hit_max_value = TRUE;

            if (perform_reset_on_max_value)
            {
                value = reset_value_on_max_value;
            }
        }

        act = world;
        value = value - subtract;
        if (value < min_value)
        {
            ValidateValue(hit_min_value, activate_goal_no_on_min_value);
            hit_min_value = TRUE;

            if (perform_reset_on_min_value)
                value = reset_value_on_min_value;
        }
    };
};