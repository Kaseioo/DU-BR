Seal
    var
        sealed = FALSE
        duration = 0
        last_seal_change = 0
        seal_reason = ""
        unseal_reason = "Unsealed by default."

    proc
        Seal(reason, duration)
            src.sealed              = TRUE
            src.duration            = duration
            src.last_seal_change    = world.time
        
        Unseal(reason)
            src.sealed              = FALSE
            src.duration            =  0
            src.last_seal_change    = world.time

        Cycle_Seal()
            if(!src.sealed) return

            src.duration -= 1

            if(src.duration <= 0)
                src.Unseal("Seal duration expired.")

Energy
    var
        name        = "Default Energy"
        description = "Default Energy Description"
        current = 100
        maximum = 100

        modifier = 1.0
        modifier_reasons = list()

        Seal/energy_seal = new()


    New(name, maximum, modifier = 1.0)
        src.name        = name
        src.current     = maximum
        src.maximum     = maximum
        src.modifier    = modifier
    
    proc
        increase(amount = 1)
            if(seal_status["sealed"]) return

            current += amount

            if(current > maximum)
                current = maximum
        
        decrease(amount = 1)
            current -= amount

            if(current < 0)
                current = 0

// ############################################################################################
// Energy definitins
    
    
