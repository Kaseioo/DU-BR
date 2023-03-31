proc/BurnLoop(var/mob/player){
// Burn loop, it loops the burn effect
    if(!player.isBurning) 
        return // Returns if the player isn't burning
    var/RegenBeforeBurn = player.regen
    while(player.BurnStack > 0){
        player << "You are burning! Burn Stack: [player.BurnStack]"
        player.Health -= 3
        player.regen = RegenBeforeBurn * 0.7
        player.BurnStack--
        if(player.Health == 0){
            player.KO("You have been knockout by the Burns, ouch!", allow_anger=1)
        }
        sleep(20)
    }
    player.regen = RegenBeforeBurn;
    player << "You aren't burning anymore."
    player.isBurning = 0 // It's necessary to stop the loop
    return
}