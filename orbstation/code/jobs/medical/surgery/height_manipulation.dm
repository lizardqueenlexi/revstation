//Surgery to change your height. Yes, this is silly.
#define LENGTHEN_SPINE "lengthen_spine"
#define SHORTEN_SPINE "shorten_spine"

/datum/surgery_operation/limb/height_manipulation
	name = "Height increase"
	desc = "An ill-advised cosmetic procedure that lengthens the spine, allowing the patient's height to be changed."
	rnd_name = "Height increase"
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NO_PATIENT_REQUIRED
	any_surgery_states_required = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED
	implements = list(
		TOOL_BONESET = 1,
		TOOL_CROWBAR = 2,
	)
	time = 4 SECONDS
	preop_sound = list(
		/obj/item = 'sound/items/tools/crowbar.ogg',
	)
	var/operation = LENGTHEN_SPINE


/datum/surgery_operation/limb/height_manipulation/get_default_radial_image()
	return image(/obj/item/bonesetter)

/datum/surgery_operation/limb/height_manipulation/all_required_strings()
	. = list()
	. += "operate on chest (target chest)"
	return ..()

/datum/surgery_operation/limb/height_manipulation/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match (bonesetter/crowbar)
	return (implements[tool.tool_behaviour])

/datum/surgery_operation/limb/height_manipulation/state_check(obj/item/bodypart/limb)
	if(!ishuman(limb.owner)) //just in case...
		return

	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE

	var/mob/living/carbon/human/patient = limb.owner

	if(operation == LENGTHEN_SPINE && patient.mob_height >= HUMAN_HEIGHT_TALLEST)
		return FALSE
	else if (operation == SHORTEN_SPINE && patient.mob_height <= HUMAN_HEIGHT_SHORTEST)
		return FALSE

	return TRUE

/datum/surgery_operation/limb/height_manipulation/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to manipulate the spine of [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins manipulate the spine of [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] begins manipulate the spine of [FORMAT_LIMB_OWNER(limb)]."),
	)
	display_pain(limb.owner, "You feel a stabbing in your spine!")

/datum/surgery_operation/limb/height_manipulation/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	if(operation == SHORTEN_SPINE)
		if(patient.mob_height <= HUMAN_HEIGHT_SHORTEST)
			to_chat(surgeon, span_warning("You don't think you can make [patient] any shorter..."))
			return
		display_results(
			surgeon,
			patient,
			span_notice("You cuts away excess bone in [patient]'s spine..."),
			span_notice("[surgeon] cuts away excess bone in [patient]'s spine with [tool]."),
			span_notice("[surgeon] cuts away excess bone in [patient]'s spine."),
		)
		display_pain(patient, "Your spine aches with pain!")
		patient.set_mob_height(patient.mob_height-2)
	else
		if(patient.mob_height >= HUMAN_HEIGHT_TALLEST)
			to_chat(surgeon, span_warning("You don't think you can make [patient] any taller..."))
			return
		display_results(
			surgeon,
			patient,
			span_notice("You stretches out [patient]'s spine..."),
			span_notice("[surgeon] stretches out [patient]'s spine with [tool]."),
			span_notice("[surgeon] stretches out [patient]'s spine."),
		)
		display_pain(patient, "You can feel your spine being stretched out!")
		patient.set_mob_height(patient.mob_height+2) //each height is 2 values apart, so this raises height by one step

/datum/surgery_operation/limb/height_manipulation/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("You hurt [FORMAT_LIMB_OWNER(limb)]'s spine!"),
		span_notice("[surgeon] unsuccessfully attempts to alter [FORMAT_LIMB_OWNER(limb)]'s spine!"),
		span_notice("[surgeon] unsuccessfully attempts to alter [FORMAT_LIMB_OWNER(limb)]'s spine!"),
	)
	limb.receive_damage(25, damage_source = tool)
	display_pain(limb.owner, "It feels like something just broke in your spine!")


/datum/surgery_operation/limb/height_manipulation/shorten
	name = "Height decrease"
	desc = "A frightening cosmetic procedure that shortens the spine, allowing the patient's height to be changed."
	rnd_name = "Height decrease"
	implements = list(
		TOOL_SAW = 1,
		/obj/item/melee/arm_blade = 1.25,
		/obj/item/fireaxe = 1.5,
		/obj/item/hatchet = 1.75,
		/obj/item/knife/butcher = 2,
	)
	preop_sound = list(
		/obj/item/circular_saw = 'sound/items/handling/surgery/saw.ogg',
		/obj/item/melee/arm_blade = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/fireaxe = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/hatchet = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/knife/butcher = 'sound/items/handling/surgery/scalpel1.ogg',
	)
	operation = SHORTEN_SPINE

/datum/surgery_operation/limb/height_manipulation/shorten/get_default_radial_image()
	return image(/obj/item/circular_saw)

/datum/surgery_operation/limb/height_manipulation/shorten/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match (saw)
	return ((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour])


// Allow it to be researched
/datum/design/surgery/height_manipulation
	name = "Height Increase"
	id = "surgery_height_manip"
	surgery = /datum/surgery_operation/limb/height_manipulation
	research_icon_state = "surgery_chest"

/datum/design/surgery/height_manipulation/shorten
	name = "Height Decrease"
	id = "surgery_height_manip_shorten"
	surgery = /datum/surgery_operation/limb/height_manipulation/shorten
	research_icon_state = "surgery_chest"

/datum/techweb_node/adv_surgery
	orb_design_ids = list(
		"surgery_height_manip",
		"surgery_height_manip_shorten"
	)

#undef LENGTHEN_SPINE
#undef SHORTEN_SPINE
