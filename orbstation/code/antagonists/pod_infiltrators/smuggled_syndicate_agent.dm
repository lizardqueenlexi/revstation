// Smuggled Syndicate agent: midround traitor who spawns on a pod in space and has to infiltrate the crew.

/datum/job/smuggled_agent
	title = "Smuggled Syndicate Agent"

/// Traitor subtype that is not a part of the station crew. Better equipped, but no cover identity.
/datum/antagonist/traitor/agent
	name = "\improper Smuggled Syndicate Agent"
	preview_outfit = /datum/outfit/smuggled_agent

/// Slightly truncated employer drafting - agents will ONLY be from proper Syndicate factions.
/datum/antagonist/traitor/agent/pick_employer()
	var/list/possible_employers = list()

	possible_employers.Add(GLOB.syndicate_employers)

	if(istype(ending_objective, /datum/objective/hijack))
		possible_employers -= GLOB.normal_employers
	else //escape or martyrdom
		possible_employers -= GLOB.hijack_employers

	employer = pick(possible_employers)
	traitor_flavor = strings(TRAITOR_FLAVOR_FILE, employer)

/// Agents get 25 TC and get "caught up" to the current amount of progression. Agents shouldn't be running around putting up posters and killing pets.
/datum/antagonist/traitor/agent/on_gain()
	. = ..()
	uplink_handler.telecrystals = 25
	uplink_handler.progression_points = SStraitor.current_global_progression

/obj/effect/mob_spawn/ghost_role/human/infiltrator/traitor
	name = "syndicate sleeper"
	desc = "An aging cryo sleeper in ominous red-and-black."
	prompt_name = "a smuggled syndicate agent"
	you_are_text = "You are a Syndicate agent."
	flavour_text = "You're right on time. Your dusty old pod isn't the most elegant means of infiltration, but it's definitely subtle. \
		You're here for a purpose - to disrupt Nanotrasen's operations by any means necessary. You don't have the luxury of a cover identity \
		like some of your colleagues. But you don't need it. You've come prepared."
	important_text = "Use the navigation computer and shuttle console to navigate the pod to the station, and sneak your way on board. You \
		have an implanted uplink, use it wisely."
	spawner_job_path = /datum/job/smuggled_agent

///Makes the player a special traitor with an uplink implant and a higher amount of TC than normal.
/obj/effect/mob_spawn/ghost_role/human/infiltrator/traitor/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()

	to_chat(spawned_mob, span_alert("[flavour_text]"))
	var/datum/antagonist/traitor/agent/antag_datum = new
	spawned_mob.mind.add_antag_datum(antag_datum)
	to_chat(spawned_mob, span_alert("[important_text]"))

/datum/outfit/smuggled_agent
	name = "Smuggled Syndicate Agent (preview only)"
	suit = /obj/item/clothing/suit/space/orange
	head = /obj/item/clothing/head/helmet/space/orange
	l_hand = /obj/item/gun/ballistic/rifle/sniper_rifle
