mob/proc/
    Cause_Combat_KO(mob/victim, mob/attacker)
        if(attacker.sparring_mode != LETHAL_COMBAT)
            return
        
        var/total_ko = victim.combat_ko_total
        var/cause_of_ko = "[victim] was defeated by [attacker] during a [attacker.sparring_mode_text]"

        announce_combat_message(message = cause_of_ko, center = victim)

        victim.increase_combat_ko()

    increase_combat_ko()
        var/mob/victim = src

        victim.combat_ko_total++

    decrease_combat_ko()
        var/mob/victim = src
        
        victim.combat_ko_total--

    is_out_of_combat()
        var/mob/victim = src
        var/time_since_last_attacked = world.time - victim.last_attacked_time

        if(victim.combat_ko_total >= KO_SYSTEM_UNCONSCIOUS_KO)
            return TRUE

        if(time_since_last_attacked >= KO_SYSTEM_OUT_OF_COMBAT_TIMER)
            return TRUE
        
        return FALSE

    announce_combat_message(message, mob/victim, range = 22)
        for(var/mob/observers in view(range, victim))
            if(observers.client)
                observers << message
    
    time_to_heal_ko()
        var/mob/victim = src
        var/time_to_heal = 1
        var/healing_modifier = 1
        
        if(victim.combat_ko_total >= KO_SYSTEM_UNCONSCIOUS_KO)
            time_to_heal = KO_SYSTEM_UNCONSCIOUS_KO_TIME
        else 
            time_to_heal = KO_SYSTEM_NORMAL_KO_DURATION

        time_to_heal = time_to_heal / healing_modifier

        return time_to_heal
    
    check_for_healing_modifiers()
        var/mob/victim = src
        var/time_since_last_attacked = world.time - victim.last_attacked_time

    set_healing_modifier()
        var/mob/victim = src
        var/healing_modifier = 1

        if(victim.combat_ko_total >= KO_SYSTEM_UNCONSCIOUS_KO)
            healing_modifier = KO_SYSTEM_UNCONSCIOUS_KO_HEALING_MODIFIER
        else 
            healing_modifier = KO_SYSTEM_NORMAL_KO_HEALING_MODIFIER

        return healing_modifier

    heal_combat_ko()
        var/mob/victim              = src
        var/time_to_heal            = victim.time_to_heal_ko()
        var/time_to_heal_message    = "[victim] will heal from their last Combat KO in [round(time_to_heal / 10, 1)] seconds."
        var/healed_message          = "[victim] has healed from their last Combat KO, and is now affected by [victim.combat_ko_status] Combat KO's."
        
        if(victim.is_out_of_combat())
            announce_combat_message(time_to_heal_message, victim = victim)

            var/elapsed_time = 0
            
            // We can't use Spawn() here as it is possible for the player to have their healing time reduced by external factors.
            // For example, the player could be dragged to a regenerator, have someone heal them, and so on.

            while(elapsed_time < time_to_heal)
                elapsed_time += 1

                if(victim.check_for_healing_modifiers())
                    var/new_time_to_heal        = victim.time_to_heal_ko()
                    var/percentage_healed       = (elapsed_time / time_to_heal) * 100
                    var/percentage_remaining    = 100 - percentage_healed

                    elapsed_time = (new_time_to_heal / 100) * percentage_remaining
                    time_to_heal = new_time_to_heal

                sleep(1)

            victim.decrease_combat_ko()
            announce_combat_message(healed_message, victim = victim)


