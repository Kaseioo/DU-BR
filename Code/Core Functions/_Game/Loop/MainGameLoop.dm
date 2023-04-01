mob/proc/cycle_energies()
    var/mob/player = src
    
    for(var/Energy/energy in player.energies)
        energy.cycle_energy()

/*
    NOTHING that goes here must have an internal loop for ticking itself.
    Every single proc must execute for a single tick.
    If it needs to have a slower tick rate, then sleep the proc before it finishes.

    Having different internal tick clocks for different procs is a recipe for disaster.
    It's very easy to forget that a proc is running on a different clock than the rest of the game.
    Most importantly, this is the smallest possible unit of time that can be used.

    WHY?
    Because we can synchronize everything to the same tick rate. Doing this should 
    reduce the possible tick imbalance that can occur when different procs are running.
*/
mob/proc/execute_player_actions()
    var/mob/player = src

    // we should remove the while loop from here and make it tick only the effect
    // removing the effect should be done in another proc (that should be more general)
    player.try_applying_burn_effect()

    // the initiate_healing proc has a while loop that executes every tick
    // it is a prime candidate to be moved to a different proc, and we probably
    // should do so. We should only alter a flag there, and the healing itself
    // should be done in another proc that gets ticked here.
    player.try_healing_combat_ko()

    player.cycle_energies()

/*
    We are going to name this LogicLoop rather than GameLoop because BYOND
    technically does that for us.

    This name also makes it clear that only logic is handled here.

    Since in the future we are probably going to have a separate proc for
    things like input handling, this makes it easier to understand what
    is going on here.
*/
proc/LogicLoop()
    while (TRUE)
        for(var/mob/player in world)
            player.execute_player_actions()

        sleep(world.tick_lag)
        //if(world.tick_usage > 80) sleep(world.tick_lag)
    

