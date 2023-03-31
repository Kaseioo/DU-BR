mob/proc/Cycle_Energies()
    var/mob/Player = src
    //world << "Cycling Energies for [Player]"
    for(var/Energy/energy in Player.energies)
        world << "Cycling [Player] - [energy]"
        energy.cycle_energy()
        
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
    

