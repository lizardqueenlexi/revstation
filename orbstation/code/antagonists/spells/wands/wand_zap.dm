/**
 * Secretly just a taser
 */
/obj/item/gun/magic/wand/zap
	name = "wand of zapping"
	desc = "This wand overloads the nerves of your enemies with potent lightning."
	school = SCHOOL_EVOCATION
	ammo_type = /obj/item/ammo_casing/energy/electrode
	icon_state = "revivewand"
	base_icon_state = "revivewand"
	fire_sound = 'sound/items/weapons/taser.ogg'
	max_charges = 8

/obj/item/gun/magic/wand/zap/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	do_sparks(1, TRUE, src)
	user.add_mood_event("tased", /datum/mood_event/tased)
	user.apply_effects(paralyze = 10 SECONDS, stutter = 10 SECONDS, jitter = 40 SECONDS)
	SEND_SIGNAL(user, COMSIG_LIVING_MINOR_SHOCK)
	charges--
