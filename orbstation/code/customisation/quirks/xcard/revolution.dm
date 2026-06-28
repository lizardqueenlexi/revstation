/// Checks if the given person has the xcard revolution immunity trait. If so, deals damage to them and knocks them unconscious, returning TRUE. Otherwise, returns false.
/datum/antagonist/rev/proc/check_xcard_and_apply_if_necessary(mob/living/carbon/victim, mob/aggressor)

	if (!HAS_TRAIT(victim, TRAIT_XCARD_REV_IMMUNE))
		return FALSE

	to_chat(aggressor, span_warning("[victim] manages to resist your influence through sheer force of will, but reels in pain from the psychic blast!"))

	to_chat(victim, span_hypnophrase("A wave of psychic influence rolls over you!"))
	to_chat(victim, span_hypnophrase("You reel in pain from \the [src]'s psychic blast!"))

	victim.apply_damage(40, BRUTE, BODY_ZONE_HEAD)
	victim.adjust_organ_loss(ORGAN_SLOT_BRAIN, 20)

	to_chat(victim, span_hypnophrase("You successfully shield your brain from conversion, \
										but feel darkness encroaching as the identity of your attacker fades from your memory..."))
	victim.Unconscious(60 SECONDS)

	return TRUE
