
mob/proc/anger_chance(mod=1)
	if(Race == "Android") return 0
	else return 100

mob/proc/Angry() if(anger>100) return 1

mob/var/tmp/list/recent_ko_reasons=new

mob/proc/InTournament()
	if(!client || !Tournament || z != 7 || !(src in All_Entrants)) return
	return 1

mob/var/tmp
	last_knocked_out_by_mob
	koCount = 0 //how many times you were ko'd this session

mob/proc/ShouldAnger(mob/target)
	var/is_able_to_anger 	= target.can_anger()
	var/is_going_to_anger 	= prob(target.anger_chance())

	var/anger_result = is_able_to_anger && is_going_to_anger
	return anger_result

mob/proc/TryToCauseAnger(mob/Attacker, mob/Victim)
	if(!Attacker || !ismob(Attacker) || hero == Victim.key)
		if(ShouldAnger(Victim) && Attacker != Victim )
			var/can_trigger_anger
			var/is_attacker_a_player 			= Attacker && ismob(Attacker) && Attacker.client
			var/attacker_caused_anger_recently 	= (Attacker.ckey in anger_reasons)
			var/has_calmed_from_anger 			= world.time > Victim.last_anger + ANGER_SYSTEM_TIME_BETWEEN_ANGERS
			var/ko_reason 						= "Unknown reason for KO"

			if(ismob(Attacker))
				if(Attacker.ckey) ko_reason = Attacker.ckey
				else ko_reason = "NPC caused KO"

			if(is_attacker_a_player && !attacker_caused_anger_recently)
				can_trigger_anger = TRUE

			if(has_calmed_from_anger || can_trigger_anger)
				Victim.anger(reason = ko_reason)
				Victim.recent_ko_reasons.Insert(1, ko_reason)
				Victim.recent_ko_reasons.len = 3
				return

mob/proc/TryToAnnounceBattlegroundsDefeat(mob/Attacker, mob/Victim)
	if(Victim.client && Victim.AtBattlegrounds())
		BattlegroundDefeat(defeater = Attacker)
		return

mob/proc/LogKoData(mob/Victim, mob/Attacker)
	if(ismob(Attacker)) 
		Victim.last_knocked_out_by_mob = Attacker

mob/proc/ResetStatsToDefault(mob/Victim)
	Victim.Health = 100
	Victim.Ki = max_ki
	Victim.BP = get_bp()
	if(Victim.BPpcnt > 100)
		Victim.BPpcnt = 100
		Victim.Aura_Overlays(remove_only=1)
	Victim.KB=0

mob/proc/StopDoingActions(mob/Victim)
	Victim.Stop_Shadow_Sparring()
	Victim.Limit_Revert()
	Victim.UltraInstinctRevert()
	Victim.God_FistStop()
	Victim.Destroy_Splitforms()
	Victim.Great_Ape_revert()
	Victim.Land()

	Victim.Action=null
	Victim.Auto_Attack=0

	if(Victim.grabbedObject)
		player_view(center=Victim) << "[Victim] is forced to release [grabbedObject]!"
		Victim.ReleaseGrab()

mob/proc/TryToRevertSSJ(mob/Victim)
	var/is_in_ssj 			= Victim.ssj > 0
	var/should_stay_in_ssj 	= FALSE

	// If the player has mastered SSJ 1, then they can stay in it while KO'd
	if(Victim.has_ss_full_power && Victim.ssj == 1)
		should_stay_in_ssj = TRUE

	if(is_in_ssj)
		if(should_stay_in_ssj) return
		else 
			Revert()

mob/proc/TryToKoNPC(mob/Attacker, mob/Victim)
	// Frozen is the NPC equivalent of being KO'd.
	// It's a state where the NPC is unable to move or attack.
	if(!Victim.Frozen)
		if(istype(Victim, /mob/new_troll))
			if("KO" in icon_states(icon)) 
				Victim.icon_state = "KO"

			Victim.KO = 1
			Victim.Health = 100
			Victim.Frozen = 1
			spawn(700)
				Victim.icon_state = initial(icon_state)
				player_view(22, src) << "[src] regains consciousness"
				Victim.Health = 100
				Victim.KO = 0
				Victim.Frozen = 0
		else
			// In this case, the NPC most probably is a Splitform
			// (take this with a grain of salt)
			SplitformDestroyedByCheck(Attacker)

			// Tens --> all other npcs currently just die instantly upon ko
			del(Victim)


mob/proc/MinimumHeal(mob/Victim)
	if(!client) // NPC
		Frozen	= FALSE
		Health 	= 100
		Ki 		= Victim.max_ki
	else
		Victim.Health = 1
		Victim.Ki = 1
		Victim.move = 1
		Victim.attacking = 0

mob/proc/TryToKillWithPoison(mob/Victim)
	// NPC's can't be poisoned
	if(istype(Victim, /mob/Enemy)) return

	if(Victim.Poisoned && prob(50)) 
		Victim.Death("Poisoned to death")

mob/proc/TryToCauseAngerDueToKo(mob/Victim)
	var/is_player = FALSE

	if(Victim.client) 
		is_player = TRUE

	if(is_player && ShouldAnger(Victim))
		Victim.anger(reason = "being ko'd so much")
		Victim.FullHeal()
		
mob/proc/KO(mob/Attacker, allow_anger=1)
	set waitfor=0
	var/mob/Victim = src
	
	if(!Victim.client || !Victim.empty_player) 
		TryToKoNPC(Attacker, Victim)

	if(Victim.KO || Victim.Safezone) return

	if(Victim.spam_killed)
		Victim.FullHeal()
		return

	if(allow_anger) 
		TryToCauseAnger(Attacker, Victim)

	TryToAnnounceBattlegroundsDefeat(Attacker, Victim)
	give_tier(Attacker)

	Victim.KO = TRUE
	Victim.icon_state = "KO"
	Victim.CheckTriggerUltraInstinct()

	LogKoData(Victim, Attacker)
	StopDoingActions(Victim)
	TryToRevertSSJ(Victim)

	// if(Attacker.sparring_mode != "Casual Spar")
	// 		Zenkai()
		

	if(alignment_on&&!InTournament()) Drop_dragonballs()


	ResetStatsToDefault(Victim)
	Cause_Combat_KO(Victim, Attacker)

	try_healing_combat_ko()
	
	if(Poisoned && prob(50)) Death("???")

mob/proc/UnKO() if(KO)
	set waitfor=0
	var/mob/Victim = src

	TryToKillWithPoison(Victim)
	MinimumHeal(Victim)
	TryToCauseAngerDueToKo(Victim)