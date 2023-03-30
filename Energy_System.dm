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
        quantity = 100
        maximum = 100

        modifier = 1.0
        modifier_reasons = list()

        Seal/seal = new()


    New(name, maximum = 100, modifier = 1.0)
        src.name        = name
        src.quantity     = maximum
        src.maximum     = maximum
        src.modifier    = modifier
    
    proc
        increase(amount = 1)
            if(seal.sealed) return

            quantity += amount

            if(quantity > maximum)
                quantity = maximum
        
        decrease(amount = 1)
            quantity -= amount

            if(quantity < 0)
                quantity = 0

// ############################################################################################
// Energy definitins

    
    
