/**
 * Scrambles the languages of someone you shoot.
 */
/obj/item/gun/magic/wand/babel
	name = "rod of babel"
	desc = "The incredible power of this wand causes victims to forget all of the languages they know, and learn a new one."
	school = SCHOOL_TRANSMUTATION
	ammo_type = /obj/item/ammo_casing/magic/babel_minor
	icon_state = "polywand"
	base_icon_state = "polywand"
	fire_sound = 'sound/effects/magic/staff_change.ogg'
	max_charges = 10

/obj/item/gun/magic/wand/babel/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	charges--
	if (HAS_TRAIT(user, TRAIT_TOWER_OF_BABEL))
		return
	user.apply_status_effect(/datum/status_effect/tower_of_babel, 3 MINUTES)

/obj/item/ammo_casing/magic/babel_minor
	projectile_type = /obj/projectile/magic/babel_minor
	harmful = FALSE

/obj/projectile/magic/babel_minor
	name = "bolt of babbling"
	icon_state = "babel"

/obj/projectile/magic/babel_minor/on_hit(mob/living/carbon/target, blocked = 0, pierce_hit)
	. = ..()
	if (!isliving(target))
		return
	if (HAS_TRAIT(target, TRAIT_TOWER_OF_BABEL))
		return
	target.apply_status_effect(/datum/status_effect/tower_of_babel/magical, 3 MINUTES)
	target.add_mood_event("curse_of_babel", /datum/mood_event/tower_of_babel)
