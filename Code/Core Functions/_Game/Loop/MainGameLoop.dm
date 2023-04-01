mob/proc/Cycle_Energies()
    var/mob/Player = src
    
    for(var/Energy/energy in Player.energies)
        world << "Cycling [energy]"
        world << "Energy: [energy.quantity]"
        energy.cycle_energy()
    sleep(30)

proc/mainPlayerLoop()
    for(var/mob/player in players)
        BurnLoop(player)
        player.try_healing_combat_ko()
        player.Cycle_Energies()

proc/MainGameLoop()
    while (TRUE)
        mainPlayerLoop()

        sleep(world.tick_lag)
        //if(world.tick_usage > 80) sleep(world.tick_lag)
    

