/// Turns any eyewear into prescription glasses.
/obj/item/prescription_lenses
	name = "prescription lenses"
	icon = 'orbstation/icons/obj/items/accessibility.dmi'
	icon_state = "lenses"
	desc = "Use on any pair of glasses to attach corrective prescription lenses. \
		The added weight means they might fall off if you get into a scrape."
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/glass = 25)

/obj/item/prescription_lenses/interact_with_atom(obj/item/clothing/glasses/target_glasses, mob/user, list/modifiers)
	if (!istype(target_glasses))
		return
	if (!isturf(target_glasses.loc))
		user.balloon_alert(user, "put glasses down!") //They need to be outside your inventory or the trait won't apply
		return
	if (HAS_TRAIT(target_glasses, TRAIT_NEARSIGHTED_CORRECTED))
		user.balloon_alert(user, "already corrective!")
		return
	user.visible_message(span_notice("[user] starts attaching [src] to [target_glasses]."))
	if (!do_after(user, 5 SECONDS, target = target_glasses))
		user.balloon_alert(user, "interrupted!")
		return
	if (length(target_glasses.clothing_traits))
		target_glasses.clothing_traits |= TRAIT_NEARSIGHTED_CORRECTED
	else
		target_glasses.clothing_traits = list(TRAIT_NEARSIGHTED_CORRECTED)
	target_glasses.AddComponent(/datum/component/knockoff, 25, list(BODY_ZONE_PRECISE_EYES), slot_flags)
	user.balloon_alert(user, "lens added")
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/datum/crafting_recipe/prescription_lenses
	name = "Prescription Lens Kit"
	result = /obj/item/prescription_lenses
	time = 1.5 SECONDS
	reqs = list(/obj/item/clothing/glasses/regular = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	category = CAT_CLOTHING
