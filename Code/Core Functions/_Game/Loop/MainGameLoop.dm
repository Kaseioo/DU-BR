// Initialize variables
var
    tick_length = world.tick_lag // The length of each tick, in seconds

// Other Loops

proc/mainPlayerLoop() // The main player loop, where every loop about the player should be placed.
{
    for(var/mob/player in players){
        // place the player loop under this for;
        BurnLoop(player)

        sleep(tick_length)
    }
}
// Main game loop
proc/MainGameLoop(){
    while (1){
        
        mainPlayerLoop();

        sleep(tick_length); // Wait for the length of each tick before running the loop again
        tick_length = world.tick_lag;
    }
}
