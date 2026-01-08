/datum/surgery_operation/organ/pacify
	name = "attach pacification chip"
	desc = "A surgical procedure which implants a chip into the brain, making the patient unwilling to cause direct harm. \
		This chip can only be terminated by CentCom officials following an official investigation."

/datum/surgery_operation/organ/pacify/state_check(obj/item/bodypart/limb)
	if(HAS_TRAIT(limb.owner, TRAIT_XCARD_PAX_SURGERY))
		return FALSE
	return ..()
