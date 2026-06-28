// Not an antagonist, but a "normal" infiltrator. Mostly for plausible deniability purposes, but you can have some fun.

/datum/job/disaster_survivor
	title = "Disaster Survivor"

/datum/round_event_control/disaster_survivor
	name = "Disaster Survivor"
	description = "A desperate survivor who spawns in a pod, and must do everything they can to stay alive."
	category = EVENT_CATEGORY_FRIENDLY //they might not be helpful but they aren't an antag
	typepath = /datum/round_event/ghost_role/disaster_survivor
	weight = 10
	earliest_start = 30 MINUTES
	max_occurrences = 1

/datum/round_event/ghost_role/disaster_survivor
	role_name = "disaster survivor"

/datum/round_event/ghost_role/disaster_survivor/spawn_role()
	spawn_infiltrator(INFIL_SPAWNER_SURVIVOR, "disaster survivor", ROLE_FUGITIVE, alert_pic = /obj/machinery/sleeper)
	return SUCCESSFUL_SPAWN

/obj/effect/mob_spawn/ghost_role/human/infiltrator/survivor
	name = "survival sleeper"
	desc = "A heavily-damaged sleeper that hasn't worked in a long time."
	prompt_name = "a disaster survivor"
	you_are_text = "You are a disaster survivor."
	flavour_text = "Blaring klaxons. Rippling explosions. The smell of ozone. Finally, cold and silence. You barely got away, but the \
		others weren't so lucky. You've been adrift for months in this tiny pod, watching your ration supplies dwindle to nothing. You can \
		see salvation ahead, though... Nanotrasen-branded salvation. Hopefully that's better than dying alone in space."
	important_text = "Use the navigation computer and shuttle console to navigate the pod to the station, and sneak your way on board. Do \
		what you have to to survive. The gear you stole from the body of one of those bastards that attacked your old home should help..."
	spawner_job_path = /datum/job/disaster_survivor

/// This infiltrator is not actually an antag, so this just prints the flavor text.
/obj/effect/mob_spawn/ghost_role/human/infiltrator/survivor/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()

	to_chat(spawned_mob, span_alert("[flavour_text]"))
	spawned_mob.set_nutrition(20) //you've been out of food for days now
	to_chat(spawned_mob, span_alert("[important_text]"))
