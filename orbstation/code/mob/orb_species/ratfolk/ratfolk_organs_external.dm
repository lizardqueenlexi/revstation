// SNOUT
/obj/item/organ/snout_rat
	name = "ratfolk snout"
	desc = "Take a closer look at that snout!"
	icon_state = "snout"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SNOUT
	external_bodyshapes = BODYSHAPE_SNOUTED

	dna_block = /datum/dna_block/feature/accessory/rat_snout

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout_rat

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/snout_rat
	layers = EXTERNAL_FRONT | EXTERNAL_ADJACENT
	feature_key = FEATURE_RAT_SNOUT

	/// We dont color the inner part, which is the front layer
	var/colorless_layer = EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/snout_rat/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDESNOUT)

/datum/bodypart_overlay/mutant/snout_rat/color_image(image/overlay, draw_layer, obj/item/bodypart/limb)
	if(draw_layer != bitflag_to_layer(colorless_layer))
		return ..()
	return overlay

// TAIL

/obj/item/organ/tail/ratfolk
	name = "ratfolk tail"
	desc = "A severed rat tail."
	dna_block = /datum/dna_block/feature/accessory/rat_tail
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/rat

/datum/bodypart_overlay/mutant/tail/rat
	feature_key = FEATURE_RAT_TAIL
