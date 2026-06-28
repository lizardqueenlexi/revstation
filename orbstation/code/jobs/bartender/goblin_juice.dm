/datum/reagent/consumable/ethanol/goblin_juice
	name = "Goblin Juice"
	description = "A multicolored concoction of unknown origin. It sparks and fizzles unnervingly."
	color = "#0e7852"
	boozepwr = 15
	quality = DRINK_NICE
	taste_description = "mischief"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	overdose_threshold = 80 // causes greenification
	var/minor_overdose = 20 // causes jitters

/datum/chemical_reaction/drink/goblin_juice
	results = list(/datum/reagent/consumable/ethanol/goblin_juice = 6)
	required_reagents = list (/datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/bromine = 1, /datum/reagent/lithium = 1, /datum/reagent/iron = 1, /datum/reagent/nitrogen = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/drink/goblin_juice_2
	results = list(/datum/reagent/consumable/ethanol/goblin_juice = 6)
	required_reagents = list (/datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/oxygen = 1, /datum/reagent/bromine = 1, /datum/reagent/lithium = 1, /datum/reagent/iron = 1, /datum/reagent/nitrogen = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/reagent/consumable/ethanol/goblin_juice/overdose_process(mob/living/M, seconds_per_tick, times_fired)
	M.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)
	M.add_atom_colour(color, WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/consumable/ethanol/goblin_juice/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	M.adjust_dizzy(-10 SECONDS * REM * seconds_per_tick)
	M.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	M.AdjustSleeping(-40 * REM * seconds_per_tick)

	if(SPT_PROB(2.5, seconds_per_tick))
		M.emote("twitch")

	if (M.has_reagent(/datum/reagent/consumable/ethanol/goblin_juice, minor_overdose) && SPT_PROB(10, seconds_per_tick))
		M.set_jitter_if_lower(3 SECONDS * REM * seconds_per_tick)

	..()
	. = TRUE

/datum/glass_style/drinking_glass/goblin_juice
	required_drink_type = /datum/reagent/consumable/ethanol/goblin_juice
	name = "Goblin Juice"
	desc = "A multicolored concoction of unknown origin. It sparks and fizzles unnervingly."
	icon = 'orbstation/icons/obj/drinks.dmi'
	icon_state = "goblin_juice"
