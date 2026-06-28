#define CHEESE_RUSH_HUNGER_MODIFIER 4 // hunger increases this much faster under the effects of cheese rush

// EARS

/obj/item/organ/ears/ratfolk
	name = "rat ears"
	icon = 'orbstation/icons/mob/species/ratfolk/bodyparts.dmi'
	icon_state = "ears_item"
	visual = TRUE
	damage_multiplier = 2
	dna_block = /datum/dna_block/feature/accessory/rat_ears

	bodypart_overlay = /datum/bodypart_overlay/mutant/rat_ears

/datum/bodypart_overlay/mutant/rat_ears
	layers = EXTERNAL_FRONT | EXTERNAL_ADJACENT
	color_source = ORGAN_COLOR_INHERIT
	feature_key = FEATURE_RAT_EARS
	dyable = TRUE

	/// We dont color the inner part, which is the front layer
	var/colorless_layer = EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/rat_ears/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDEHAIR)

/datum/bodypart_overlay/mutant/rat_ears/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(draw_layer != all_layers[colorless_layer])
		return ..()
	return overlay

// EYES - better darkvision, sensitive to flash, lower health

/obj/item/organ/eyes/ratfolk
	name = "rat eyes"
	maxHealth = 0.35 * STANDARD_ORGAN_THRESHOLD // more fragile than normal eyes
	flash_protect = FLASH_PROTECTION_SENSITIVE
	color_cutoffs = list(5, 5, 5)

// STOMACH - increases movespeed temporarily when you consume cheese reagent (found in raw cheese)

/obj/item/organ/stomach/ratfolk
	name = "rat stomach"

/obj/item/organ/stomach/ratfolk/on_life(delta_time, times_fired)
	var/datum/reagent/consumable/cheese/cheese = locate(/datum/reagent/consumable/cheese) in owner.reagents.reagent_list
	if(cheese?.volume)
		cheese.volume = min(cheese.volume, 30) // let's cap the amount of cheese you can have in your stomach
		owner.apply_status_effect(/datum/status_effect/cheese_rush)
	else
		owner.remove_status_effect(/datum/status_effect/cheese_rush)
	return ..()

/obj/item/organ/stomach/ratfolk/on_mob_remove(mob/living/carbon/carbon)
	if(carbon.has_movespeed_modifier(/datum/movespeed_modifier/cheese_rush))
		to_chat(carbon, span_warning("You feel the effects of your cheese rush wear off."))
		carbon.remove_movespeed_modifier(/datum/movespeed_modifier/cheese_rush)
	return ..()

/**
 * Status effect: Increases move speed and hunger while you have cheese in you
 */
/datum/status_effect/cheese_rush
	id = "cheese_rush"
	alert_type = /atom/movable/screen/alert/status_effect/cheese_rush
	var/spawned_last_move = FALSE

/atom/movable/screen/alert/status_effect/cheese_rush
	name = "Cheese Rush"
	desc = "Your metabolism is going into overdrive, you feel dangerously cheesy!"
	icon_state = "lightningorb"

/datum/status_effect/cheese_rush/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.hunger_mod *= CHEESE_RUSH_HUNGER_MODIFIER // hunger increases faster in cheese rush mode
	owner.add_movespeed_modifier(/datum/movespeed_modifier/cheese_rush)
	to_chat(owner, span_notice("The cheese gives you a sudden burst of energy!"))

/datum/status_effect/cheese_rush/on_remove()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.hunger_mod /= CHEESE_RUSH_HUNGER_MODIFIER // hunger returns to normal
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/cheese_rush)
	to_chat(owner, span_warning("You feel the effects of your cheese rush wear off."))

/datum/movespeed_modifier/cheese_rush
	multiplicative_slowdown = -0.3

// TONGUE

/obj/item/organ/tongue/ratfolk
	name = "ratfolk tongue"
	desc = "If you look closely, you can see a fine layer of cheese dust. Or is that... brass?"
	say_mod = "squeaks"
	liked_foodtypes = FRUIT | NUTS | DAIRY
	disliked_foodtypes = CLOTH | BUGS

#undef CHEESE_RUSH_HUNGER_MODIFIER
