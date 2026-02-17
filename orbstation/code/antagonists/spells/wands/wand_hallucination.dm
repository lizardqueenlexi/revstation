#define WIZARD_WAND_HALLUCINATIONS list(\
	/datum/hallucination/death,\
	/datum/hallucination/fire,\
	/datum/hallucination/oh_yeah,\
	/datum/hallucination/xeno_attack,\
	/datum/hallucination/hazard/lava,\
	/datum/hallucination/hazard/chasm,\
	/datum/hallucination/hazard/anomaly,\
	/datum/hallucination/ice,\
	/datum/hallucination/shock,\
	/datum/hallucination/delusion/preset/monkey,\
	/datum/hallucination/delusion/preset/corgi,\
	/datum/hallucination/delusion/preset/carp,\
	/datum/hallucination/delusion/preset/skeleton,\
	/datum/hallucination/delusion/preset/zombie,\
	/datum/hallucination/delusion/preset/cyborg,\
	/datum/hallucination/delusion/preset/ghost,\
	/datum/hallucination/delusion/preset/syndies,)

/**
 * Hallucination wand looks exactly like a bolt of chaos except whatever happens isn't real
 * One of the few times people might actually fall for hallucinations of being set on fire or turned into a xenomorph
 * Even if they don't, several of these are minor stuns anyway
 */
/obj/item/gun/magic/wand/hallucination
	name = "wand of chaos"
	desc = "A wand which spits bolts of hallucinogenic magic which can do almost anything, or at least make the victim think so."
	school = SCHOOL_FORBIDDEN
	ammo_type = /obj/item/ammo_casing/magic/hallucination
	icon_state = "polywand"
	base_icon_state = "polywand"
	fire_sound = 'sound/effects/magic/staff_chaos.ogg'
	max_charges = 20

/obj/item/gun/magic/wand/hallucination/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	var/datum/hallucination/picked_hallucination = pick(WIZARD_WAND_HALLUCINATIONS)
	user.cause_hallucination(picked_hallucination, "wand")
	charges--

/obj/item/ammo_casing/magic/hallucination
	projectile_type = /obj/projectile/magic/hallucination
	harmful = FALSE

/obj/projectile/magic/hallucination
	// Eagle eyed players may be aware that there's no such thing as a real bolt of chaos projectile
	name = "bolt of chaos"
	icon_state = "ice_1"

/obj/projectile/magic/hallucination/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/carbon/victim = target
	if (!istype(victim))
		return
	var/datum/hallucination/picked_hallucination = pick(WIZARD_WAND_HALLUCINATIONS)
	victim.cause_hallucination(picked_hallucination, "wand")

#undef WIZARD_WAND_HALLUCINATIONS
