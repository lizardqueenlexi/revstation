// Cadaver crates: crates that each contain one corpse, for "medical purposes".
/datum/supply_pack/medical/cadaver
	cost = CARGO_CRATE_VALUE * 5
	access_view = ACCESS_MEDICAL
	crate_type = /obj/structure/closet/crate/coffin/stasis
	crate_name = "medical cadaver crate"
	test_ignored = TRUE

	///Whether a vampire has arrived on the station this round
	var/vampire_arrived = FALSE
	///Percent chance for a medical cadaver to be replaced with a vampire
	var/vampire_chance = 1

/datum/supply_pack/medical/cadaver/generate(atom/A, datum/bank_account/paying_account, crate_override)
	. = ..()
	var/mob/living/carbon/human/corpse = locate() in .
	if(vampire_arrived || !prob(vampire_chance))
		corpse.death()
		for (var/obj/item/organ/part in corpse.organs) //each cadaver comes with a complementary set of organs, held in stasis
			part.organ_flags |= ORGAN_FROZEN
		return
	vampire_arrived = TRUE
	qdel(corpse)
	var/mob/living/carbon/human/surprise_dracula = new /mob/living/carbon/human/species/vampire(.)
	//offer control of the vampire to ghosts
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghosts_for_target(
		question = "Do you want to play as a vampire fugitive?",
		role = ROLE_FUGITIVE,
		check_jobban = ROLE_FUGITIVE,
		poll_time = 10 SECONDS,
		checked_target  = surprise_dracula,
		alert_pic  = surprise_dracula)

	if(LAZYLEN(candidates))
		var/mob/dead/observer/chosen = pick(candidates)
		surprise_dracula.key = chosen.key
		LAZYADD(surprise_dracula.mind.special_roles, ROLE_FUGITIVE)
		to_chat(surprise_dracula, span_warning("You are a vampire, freshly escaped from imprisonment by NanoTrasen's secret Occultism Department. You've managed to stow away in place of a medical cadaver, bound for the unknown reaches of the Spinward Sector. \
								You must do whatever it takes to evade capture."))
		surprise_dracula.log_message("was made into a vampire fugitive by medical cadaver crate", LOG_GAME)
	else //if no one wants to play a vampire, a completely dead skeleton shows up instead as an alternate joke
		qdel(surprise_dracula)
		var/mob/living/carbon/human/backup_skeleton = new /mob/living/carbon/human/species/skeleton(.)
		backup_skeleton.death()

/datum/supply_pack/medical/cadaver/ethereal
	name = "Medical Cadaver Crate (Ethereal)"
	desc = "A preserved medical cadaver, for dissections, spare organs, or experiments. This one is an ethereal. For legal reason, the body's crystal core has been removed."
	contains = list(/mob/living/carbon/human/species/ethereal)

// Remove the crystal core, both so the ethereal doesn't regenerate and so the crew can't bulk-order crystal cores
/datum/supply_pack/medical/cadaver/ethereal/generate(atom/A, datum/bank_account/paying_account, crate_override)
	. = ..()
	var/mob/living/carbon/human/corpse = locate() in .
	for (var/obj/item/organ/heart/ethereal/illegal_heart in corpse.organs)
		qdel(illegal_heart)

/datum/supply_pack/medical/cadaver/felinid
	name = "Medical Cadaver Crate (Felinid)"
	desc = "A preserved medical cadaver, for dissections, spare organs, or experiments. This one is a felinid."
	contains = list(/mob/living/carbon/human/species/felinid)

/datum/supply_pack/medical/cadaver/human
	name = "Medical Cadaver Crate (Human)"
	desc = "A preserved medical cadaver, for dissections, spare organs, or experiments. This one is a human."
	contains = list(/mob/living/carbon/human)

/datum/supply_pack/medical/cadaver/jelly
	name = "Medical Cadaver Crate (Jellyperson)"
	desc = "A preserved medical cadaver, for dissections, spare organs, or experiments. This one is a jellyperson."
	contains = list(/mob/living/carbon/human/species/jelly)

/datum/supply_pack/medical/cadaver/moth
	name = "Medical Cadaver Crate (Moth)"
	desc = "A preserved medical cadaver, for dissections, spare organs, or experiments. This one is a moth."
	contains = list(/mob/living/carbon/human/species/moth)

/datum/supply_pack/medical/cadaver/pod
	name = "Medical Cadaver Crate (Podperson)"
	desc = "A preserved medical cadaver, for dissections, spare organs, or experiments. This one is a podperson."
	contains = list(/mob/living/carbon/human/species/pod)

/datum/supply_pack/medical/cadaver/rat
	name = "Medical Cadaver Crate (Ratfolk)"
	desc = "A preserved medical cadaver, for dissections, spare organs, or experiments. This one is a ratfolk."
	contains = list(/mob/living/carbon/human/species/ratfolk)

/datum/supply_pack/medical/cadaver/tiziran
	name = "Medical Cadaver Crate (Tiziran)"
	desc = "A preserved medical cadaver, for dissections, spare organs, or experiments. This one is a tiziran."
	contains = list(/mob/living/carbon/human/species/lizard)

// I'm making this a subtype of coffin solely so vampires can sleep in them.
/obj/structure/closet/crate/coffin/stasis
	name = "stasis coffin"
	desc = "An advanced coffin used to keep corpses fresh for extended transport. Once opened, it will permanently stop functioning."
	icon = 'orbstation/icons/obj/medical/coffin.dmi'
	icon_state = "stasiscoffin"
	base_icon_state = "stasiscoffin"
	resistance_flags = NONE
	max_integrity = 70
	material_drop = /obj/item/stack/sheet/iron
	material_drop_amount = 5
	open_sound = 'sound/machines/closet/closet_open.ogg'
	close_sound = 'sound/machines/closet/closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	can_install_electronics = FALSE
	mob_storage_capacity = 1 //no mass stasis, sorry

	///Whether the coffin still works or not
	var/functional = TRUE

/obj/structure/closet/crate/coffin/stasis/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(!opened && functional)
		. += "stasisactive"
	if(manifest)
		. += "manifest"

/obj/structure/closet/crate/coffin/stasis/open(mob/living/user, force = FALSE, special_effects = TRUE)
	if(!functional)
		return ..()
	functional = FALSE
	for(var/mob/living/carbon/corpse in src) //unfreeze the organs of any contained carbon
		for(var/obj/item/organ/part as anything in corpse.organs)
			part.organ_flags &= ~ORGAN_FROZEN
	return ..()
