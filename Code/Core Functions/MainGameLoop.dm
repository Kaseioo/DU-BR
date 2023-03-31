mob/proc/Cycle_Energies()
    var/mob/Player = src
    var/Energy/demonic_energy = Player.Demonic_Energy

    demonic_energy.cycle_energy()

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
    

