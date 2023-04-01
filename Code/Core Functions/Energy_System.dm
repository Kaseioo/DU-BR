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

        Cycle_Seal(seal_change = 1)
            if(!src.sealed) return

            src.duration -= seal_change

            if(src.duration <= 0)
                src.Unseal("Seal duration expired.")

EnergySchedule
    var
        operation
        amount
        duration
        reason
    New(operation, amount = 1, duration = 1, reason)
        src.operation   = operation
        src.amount      = amount
        src.duration    = duration
        src.reason      = reason

Energy
    var
        name                    = "Default Energy"
        description             = "Default Energy Description"
        quantity                = 100
        maximum                 = 100

        modifier                = 1.0
        list/modifier_reasons   = list()
        list/schedule           = list()

        Seal/seal               = new()


    New(name, maximum = 100, modifier = 1.0)
        src.name        = name
        src.quantity    = maximum
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

        schedule_decrease(amount = 1, duration = 1, reason = "Scheduled decrease")
            if(length(schedule) > 20)
                schedule -= schedule[1]

            if(duration > 6000)         duration = 6000

            var/EnergySchedule/task = new(
                "decrease",
                amount,
                duration,
                reason
            )

            schedule.Add(task)

        schedule_increase(amount = 1, duration = 1, reason = "Scheduled increase")
            if(length(schedule) > 20)
                schedule -= schedule[1]
            if(duration > 6000)         duration = 6000
            
            var/EnergySchedule/task = new(
                "increase",
                amount,
                duration,
                reason
            )
            schedule.Add(task)

        cycle_energy()
            if(seal.sealed) 
                seal.Cycle_Seal()
                return

            for(var/EnergySchedule/task in schedule)
                var/operation   = task.operation
                var/amount      = task.amount

                if(operation == "decrease")
                    decrease(amount)

                if(operation == "increase")
                    increase(amount)

                task.duration -= 1
                if(task.duration <= 0)
                    schedule.Remove(task)
                    del(task)


            if(quantity < maximum)
                schedule_increase(0.5, reason = "Natural recovery")

// ############################################################################################
// Energy definitins

    
    
