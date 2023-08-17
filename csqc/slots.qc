void PushToSlotHistory(float slot) {
    if (slot_history_top >= MAX_SLOT_HISTORY_SIZE) {
        // Stack is full
        return;
    }

    slot_history_top += 1;
    slot_history[slot_history_top] = slot;
}

void RemoveFromSlotHistory(float slot) {
    if (slot_history_top == -1) {
        // Stack is empty
        return;
    }

    for (float i = slot_history_top; i >= 0; i--) {
        if (slot_history[i] == slot) {
            for (float j = i+1; j < MAX_SLOT_HISTORY_SIZE; j++) {
                slot_history[j-1] = slot_history[j];
            }

            slot_history[MAX_SLOT_HISTORY_SIZE-1] = 0;
            slot_history_top--;
            break;
        }
    }
}

void Slot_Keydown(float slot) {
    PushToSlotHistory(slot);
    localcmd(sprintf("impulse %f\n", slot));
    localcmd("+attack\n");
}

void Slot_Keyup(float slot) {
    RemoveFromSlotHistory(slot);
    if (slot_history_top >= 0) { // still holding another +slot bind
        localcmd(sprintf("impulse %f\n", slot_history[slot_history_top]));
    } else {
        if (CVARF(fo_default_weapon)) {
            localcmd(sprintf("impulse %f\n", CVARF(fo_default_weapon)));
        }
        localcmd("-attack\n");
    }
}
