
proc/mainPlayerLoop()
{
    for(var/mob/player in players){
        BurnLoop(player)
        player.try_healing_combat_ko()

    }
}

proc/MainGameLoop(){
    while (TRUE){
        
        mainPlayerLoop()

        sleep(world.tick_lag)
        //if(world.tick_usage > 80) sleep(world.tick_lag)
    }
}
