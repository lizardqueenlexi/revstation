/datum/quirk
	///ORBSTATION: if true, this quirk will be displayed in the x-card section of the quirk list
	var/xcard_quirk = FALSE

//quirk subtype for x-card, prevents having to manually flag quirks as an x-card quirk
/datum/quirk/xcard
	xcard_quirk = TRUE
	abstract_type  = /datum/quirk/xcard
	icon = FA_ICON_X //all x-card quirks use a big "X" icon for clarity
	value = 0 //x-card quirks are always free

	var/examine_text //text when quirk owner is examined, if any

/datum/quirk/xcard/bioscrambler_immune
	name = "X-CARD: Bioscrambler"
	desc = "Your physical form is abnormally stable, preventing your limbs from being replaced by bioscrambler \
			proximity. Instead, you will suffer from a random, highly detrimental effect when you would normally \
			be bioscrambled."
	mob_trait = TRAIT_BIOSCRAMBLER_IMMUNE //this is not ONLY an x-card trait, so it does not have "XCARD" in the name

/datum/quirk/xcard/cult_convert_immune
	name = "X-CARD: Cult Conversion"
	desc = "Your powerful mental rigor prevents you from being forcefully recruited into cults. \
			Instead, those awful cultists will sacrifice you in a shower of blood and viscera!"
	mob_trait = TRAIT_XCARD_CULT_IMMUNE
	examine_text = "immune to cult conversion, and will be gibbed if attempted."

/datum/quirk/xcard/rev_convert_immune
	name = "X-CARD: Revolution Conversion"
	desc = "Your powerful mental rigor prevents you from being forcefully recruited into revolutions. \
			Instead, conversion attempts will deal brain damage and brute damage to your head."
	mob_trait = TRAIT_XCARD_REV_IMMUNE
	examine_text = "immune to revolutionary conversion, and will suffer brain damage instead."

/datum/quirk/xcard/facehugger_immune
	name = "X-CARD: Facehuggers"
	desc = "Facehuggers are unable to infect you, and will instead bite your face, injecting a unique venom."
	mob_trait = TRAIT_XCARD_XENO_IMMUNE
	examine_text = "immune to facehugger implantation, and will be injected with deadly xenotoxin instead."

/datum/quirk/xcard/eye_trauma
	name = "X-CARD: Eye Trauma"
	desc = "Various sources of eye trauma will not be applied to you. Particularly, the traitor objective to steal someone's \
	 eyes will never select you as its target, eyesnatching devices will not work on you, and the objective will \
	 not be offered to you."
	mob_trait = TRAIT_XCARD_EYE_TRAUMA
	//no need for examine text - if someone tries using an eyesnatch device on someone that isn't their target I don't know what to tell them

/datum/quirk/xcard/paradox_clone
	name = "X-CARD: Paradox Clone"
	desc = "A paradox clone of your character will never appear."
	mob_trait = TRAIT_XCARD_PARADOX_CLONE
	//this SHOULDN'T appear on examine - other players should not know that you can't have an evil twin.

/datum/quirk/xcard/pax_surgery
	name = "X-CARD: Pacification Surgery"
	desc = "Attempts to perform the pacification surgery on you will not occur. \
			Pax, the reagent with similar mechanical abilities, will still apply its effects."
	mob_trait = TRAIT_XCARD_PAX_SURGERY
	examine_text = "pacification surgery can not be performed."

/datum/quirk/xcard/hypnosis
	name = "X-CARD: Hypnosis"
	desc = "You have an iron force of will and can shrug off sources of brainwashing, \
		reducing them instead to merely a painful migraine."
	mob_trait = TRAIT_XCARD_HYPNOSIS
	examine_text = "immune to hypnotic suggestion."

/datum/quirk/xcard/uncyborgable
	name = "X-CARD: Cyborg Conversion"
	desc = "Your brain is oddly-shaped, and will not fit into cyborg bodies or AI cores. \
			(It can still be put into an MMI, and you can still become a cyborg or AI if you enter a positronic brain as a ghost.)"
	mob_trait = TRAIT_XCARD_BORG_IMMUNE
	examine_text = "cannot be made into a cyborg."

// casting the trait so it applies to the brain level
/datum/quirk/xcard/uncyborgable/add_to_holder(mob/living/new_holder, quirk_transfer, client/client_source, unique = TRUE, announce = TRUE)
	. = ..()
	if(!.)
		return
	var/obj/item/organ/brain/perfect_brain = new_holder.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!perfect_brain)
		return
	ADD_TRAIT(perfect_brain, mob_trait, QUIRK_TRAIT)
	RegisterSignal(new_holder, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(transfer_trait))

/datum/quirk/xcard/uncyborgable/proc/transfer_trait(mob/living/source, obj/item/organ/brain/new_brain)
	SIGNAL_HANDLER
	if(!istype(new_brain))
		return
	ADD_TRAIT(new_brain, mob_trait, QUIRK_TRAIT)


//proc to append x-card traits to examine text (everyone should be able to see these!)
/mob/living/carbon/proc/examine_xcards()
	var/list/xcard_list = list()
	. = list()

	for (var/datum/quirk/xcard/quirk_type as anything in subtypesof(/datum/quirk/xcard))
		if(initial(quirk_type.examine_text) && HAS_TRAIT(src, initial(quirk_type.mob_trait)))
			xcard_list += span_notice("[p_They()] [p_are()] [initial(quirk_type.examine_text)]")

	if(length(xcard_list))
		. += span_boldnotice("[p_They()] [p_have()] the following X-cards")
		. += xcard_list

//alternate mood event for the eyestab x-card
/datum/mood_event/face_stab
	description = "I just got stabbed in the face!"
	mood_change = -4
	timeout = 3 MINUTES
