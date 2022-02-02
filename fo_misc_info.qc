class fo_misc_info : entity 
{
    void () fo_misc_info =
    {
        if (this.mdl) 
        {
            precache_model(this.mdl);
            precache_model2(this.mdl);
            this.model = this.mdl;

            if (this.spawnflags & FO_MISC_INFO_NO_Z_TEST)
            {
                this.nextthink = time + .01;
            }
            else
            {
                FO_SetModel(this, this.mdl);
            }

            if (this.goal_state == TFGS_REMOVED)
                RemoveGoal(this);
        }
    };
    
    virtual void () think =
    {
        this.nextthink = time + .01;
    };
};