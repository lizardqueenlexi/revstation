GLOBAL_LIST_EMPTY(journeymanstart)

/datum/antagonist/wizard_journeyman
	name = "\improper Space Wizard Journeyman"
	roundend_category = "wizards"
	antagpanel_category = "Wizard"
	pref_flag = ROLE_WIZARD
	antag_hud_name = "wizard"
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5
	ui_name = "AntagInfoWizardJourneyman"
	suicide_cry = "ARE YOU WATCHING THIS, GUYS?!"
	preview_outfit = /datum/outfit/journeyman_wizard
	show_to_ghosts = TRUE
	/// True if we want you to be granted objectives
	var/give_objectives = TRUE
	/// Gear to apply
	var/outfit_type = /datum/outfit/journeyman_wizard
	/// This mob's Grand Ritual ability
	var/datum/action/cooldown/grand_ritual/ritual = new
	/// List of names of spells for the round end report
	var/list/learned_spells = list()

/datum/antagonist/wizard_journeyman/ui_data(mob/user)
	var/list/data = list()
	data["ritual"] = list(\
		"remaining" = GRAND_RITUAL_FINALE_COUNT - ritual.times_completed,
		"next_area" = initial(ritual.target_area.name),)
	return data

/datum/antagonist/wizard_journeyman/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	ritual.Grant(current)
	current.add_faction(ROLE_WIZARD)

/datum/antagonist/wizard_journeyman/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	ritual.Remove(current)
	current.remove_faction(ROLE_WIZARD)
	UnregisterSignal(ritual, COMSIG_GRAND_RITUAL_FINAL_COMPLETE)

/// On application, teleport to lair and set up
/datum/antagonist/wizard_journeyman/on_gain()
	ritual = new(owner.current)
	RegisterSignal(ritual, GRAND_RITUAL_RUNE_DRAWN, PROC_REF(on_rune_drawn))
	RegisterSignal(ritual, COMSIG_GRAND_RITUAL_FINAL_COMPLETE, PROC_REF(on_ritual_complete))
	send_to_lair()
	equip_wizard()
	if (give_objectives)
		create_objectives()
	grant_hangover()
	. = ..()
	rename_wizard()

/// If we get this signal you just drew a rune, now listen for it being done
/datum/antagonist/wizard_journeyman/proc/on_rune_drawn(datum/action/cooldown/grand_ritual/ritual, obj/effect/grand_rune/drawn_rune)
	SIGNAL_HANDLER
	RegisterSignal(drawn_rune, COMSIG_GRAND_RUNE_COMPLETE, PROC_REF(on_rune_complete))

/// If we get this signal a ritual step finished, we want to get stronger
/datum/antagonist/wizard_journeyman/proc/on_rune_complete(obj/effect/grand_rune/finished_rune)
	SIGNAL_HANDLER
	UnregisterSignal(finished_rune, COMSIG_GRAND_RUNE_COMPLETE)
	var/list/known_spells = list()
	for (var/datum/action/cooldown/spell/spell in owner.current.actions)
		if (spell.spell_max_level <= 1 || spell.spell_level >= spell.spell_max_level)
			continue
		known_spells += spell
	if (!length(known_spells))
		return
	var/datum/action/cooldown/spell/empowered_spell = pick(known_spells)
	empowered_spell.level_spell()
	to_chat(owner, "Your knowledge of [initial(empowered_spell.name)] increases!")

/// If we receive this signal, you're done with objectives
/datum/antagonist/wizard_journeyman/proc/on_ritual_complete()
	SIGNAL_HANDLER
	var/datum/objective/custom/successful_ritual = new()
	successful_ritual.owner = owner
	successful_ritual.explanation_text = "Complete the Grand Ritual at least seven times."
	successful_ritual.completed = TRUE
	objectives = list(successful_ritual)
	UnregisterSignal(ritual, COMSIG_GRAND_RITUAL_FINAL_COMPLETE)

/// Become human and put on the robe and wizard hat
/datum/antagonist/wizard_journeyman/proc/equip_wizard()
	if (!owner)
		CRASH("Antag datum with no owner.")
	var/mob/living/carbon/human/graduate = owner.current
	if (!istype(graduate))
		return
	graduate.delete_equipment()
	// Wizards are human by default. Use the mirror if you want something else.
	graduate.set_species(/datum/species/human)
	graduate.equipOutfit(outfit_type)

/// Generate objectives
/datum/antagonist/wizard_journeyman/proc/create_objectives()
	var/can_steal = add_theft_objective()
	// If the first theft objective failed then don't try and add a second
	switch(rand((can_steal) ? 1 : 41, 100))
		if (1 to 90)
			add_theft_objective()
		if (91 to 100)
			add_diskie_objective()
	add_roundend_objective()

/**
 * Steal something
 * Returns true if we managed to generate an objective
 */
/datum/antagonist/wizard_journeyman/proc/add_theft_objective()
	var/datum/objective/steal/theft = new
	theft.owner = owner
	theft.find_target(list(owner))
	objectives += theft

	return theft.explanation_text != "Free objective"

/// Trap someone alive and well on the station
/datum/antagonist/wizard_journeyman/proc/add_maroon_objective()
	var/datum/objective/protect/protect = new
	protect.owner = owner
	protect.find_target()

	var/datum/objective/maroon/maroon = new
	maroon.owner = owner
	maroon.target = protect.target
	maroon.update_explanation_text()

	objectives += protect
	objectives += maroon

/// Get that fuckin disk
/datum/antagonist/wizard_journeyman/proc/add_diskie_objective()
	var/datum/objective/steal/theft = new
	theft.owner = owner
	theft.set_target(new /datum/objective_item/steal/nukedisc)
	objectives += theft

/// Don't die, or do
/datum/antagonist/wizard_journeyman/proc/add_roundend_objective()
	switch(rand(1,100))
		if (1 to 60)
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			objectives += escape_objective
		if (61 to 80)
			var/datum/objective/survive/survive_objective = new
			survive_objective.owner = owner
			objectives += survive_objective
		if (81 to 90)
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			objectives += hijack_objective
		else
			var/datum/objective/martyr/martyr_objective = new
			martyr_objective.owner = owner
			objectives += martyr_objective

/// Create wizard's house if it doesn't exist, then insert wizard
/datum/antagonist/wizard_journeyman/proc/send_to_lair()

	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_WIZARD_JOURNEYMAN)

	if (!owner)
		CRASH("Antag datum with no owner.")
	if (!owner.current)
		return
	if (!GLOB.journeymanstart.len)
		return
	owner.current.forceMove(pick(GLOB.journeymanstart))

/// You partied hard after graduating wizard school
/datum/antagonist/wizard_journeyman/proc/grant_hangover()
	if (!owner)
		CRASH("Antag datum with no owner.")
	var/mob/living/carbon/human/partygoer = owner.current
	if (!istype(partygoer))
		return
	partygoer.set_resting(TRUE, silent = TRUE)
	if (prob(50))
		partygoer.adjust_timed_status_effect(rand(30 SECONDS, 40 SECONDS), /datum/status_effect/drugginess)
	else
		partygoer.adjust_drunk_effect(rand(15, 25))
	partygoer.adjust_disgust(rand(5, 55))

/// The random names are pretty good but our players are better
/datum/antagonist/wizard_journeyman/proc/rename_wizard()
	set waitfor = FALSE

	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/mob/living/wiz_mob = owner.current
	var/newname = sanitize_name(reject_bad_text(tgui_input_text(wiz_mob, "You are the [name]. Would you like to change your name to something else?", "Name change", randomname, MAX_NAME_LEN)))
	if (!newname)
		newname = randomname
	wiz_mob.fully_replace_character_name(wiz_mob.real_name, newname)

/datum/antagonist/wizard_journeyman/roundend_report()
	var/list/report = list()

	report += printplayer(owner)
	report += "<br><B>Grand Rituals completed:</B> [ritual.times_completed]<br>"

	//var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		//for(var/datum/objective/objective in objectives)
		//	if(!objective.check_completion())
		//		objectives_complete = FALSE
		//		break

	/** I'm leaving this here instead of deleting it because I will want to restore it when PRing to TG
	if(objectives.len == 0 || objectives_complete)
		report += "<br><span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<br><span class='redtext big'>The [name] has failed!</span>"
	 */

	report += "<br><B>Spells chosen:</B> "
	for (var/spell in learned_spells)
		report += "- [spell]"

	return report.Join("<br>")

// Add an extra signal here
/datum/action/cooldown/grand_ritual/draw_rune(turf/target_turf)
	. = ..()
	var/obj/effect/grand_rune/new_rune = rune?.resolve()
	if (!new_rune)
		return
	SEND_SIGNAL(src, GRAND_RITUAL_RUNE_DRAWN, new_rune)
