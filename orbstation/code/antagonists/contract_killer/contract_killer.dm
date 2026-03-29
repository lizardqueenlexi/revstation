/// A minor antagonist with the goal to kill a single crew member. Gets a few toys to do so.
/datum/antagonist/contract_killer
	name = "Contract Killer"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	pref_flag = ROLE_CONTRACT_KILLER
	antag_hud_name = "contractkiller"
	ui_name = "AntagInfoMinor"
	show_name_in_check_antagonists = TRUE
	roundend_category = "contract killers"
	silent = FALSE
	suicide_cry = "FOR THE PAY!! Wait-"
	preview_outfit = /datum/outfit/contract_killer

/datum/antagonist/contract_killer/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/contract_killer/greet()
	owner.current.playsound_local(get_turf(owner.current), 'orbstation/sound/antag_alerts/contractkilleralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	owner.announce_objectives()

/datum/antagonist/contract_killer/forge_objectives()
	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = owner
	var/datum/mind/target_mind = kill_objective.find_target()

	// The killer must first follow their target to gather intel in order to prepare and unlock their gear.
	var/datum/objective/gather_intel/intel = new
	intel.owner = owner
	intel.target = target_mind
	intel.start_ticking()
	objectives += intel

	objectives += kill_objective // Second objective is the kill itself.

	// Finally, generate a "fluff" objective that gives extra instructions.
	var/list/potential_fluff_objs = list()

	for(var/datum/objective/contract_killer/killer_obj as anything in subtypesof(/datum/objective/contract_killer))
		potential_fluff_objs[killer_obj] = initial(killer_obj.weight)

	var/chosen_obj = pick_weight(potential_fluff_objs)
	var/datum/objective/contract_killer/fluff_obj = new chosen_obj
	fluff_obj.owner = owner
	fluff_obj.post_created(target_mind)
	objectives += fluff_obj

	for(var/datum/objective/O in objectives)
		O.update_explanation_text()

//Preferences preview icon

/datum/antagonist/contract_killer/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/killer_dummy = new
	killer_dummy.dna.features["mcolor"] = "#9c38ab"
	killer_dummy.dna.features["tail_lizard"] = "Dark Tiger"
	killer_dummy.dna.features["snout"] = "Round"
	killer_dummy.dna.features["horns"] = "Ram"
	killer_dummy.dna.features["frills"] = "Aquatic"
	killer_dummy.dna.features["spines"] = "Aquatic"
	killer_dummy.set_species(/datum/species/lizard)

	var/datum/universal_icon/killer_icon = render_preview_outfit(preview_outfit, killer_dummy)
	var/datum/universal_icon/killer_blood_icon = uni_icon('icons/effects/blood.dmi', "uniformblood")
	killer_blood_icon.blend_color(BLOOD_COLOR_RED, ICON_MULTIPLY)
	killer_icon.blend_icon(killer_blood_icon, ICON_OVERLAY)

	return finish_preview_icon(killer_icon)

/datum/outfit/contract_killer
	name = "Contract Killer (Preview only)"

	uniform = /obj/item/clothing/under/rank/civilian/hydroponics
	gloves = /obj/item/clothing/gloves/botanic_leather
	suit = /obj/item/clothing/suit/apron
	glasses = /obj/item/clothing/glasses/sunglasses
	neck = /obj/item/camera
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_hand = /obj/item/knife/kitchen

/datum/outfit/contract_killer/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/knife/kitchen/carried_knife in H.get_equipped_items(TRUE))
		carried_knife.add_mob_blood(H)
	H.regenerate_icons()
