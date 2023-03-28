
proc/mainPlayerLoop()
{
    for(var/mob/player in players){
        BurnLoop(player)

        sleep(world.tick_lag)
    }
}

proc/MainGameLoop(){
    while (1){
        
        mainPlayerLoop();

        sleep(world.tick_lag);
    }
}
