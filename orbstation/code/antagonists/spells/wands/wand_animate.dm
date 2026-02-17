/**
 * Animate objects
 */
/obj/item/gun/magic/wand/animate
	name = "wand of animation"
	desc = "This wand is attuned to life and will animate effected objects into destructive servants."
	school = SCHOOL_EVOCATION
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "polywand"
	base_icon_state = "polywand"
	fire_sound = 'sound/effects/magic/staff_animation.ogg'
	max_charges = 10

/obj/item/gun/magic/wand/animate/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	to_chat(user, span_warning("You animate one of your own possessions!"))
	charges--
	var/list/possessions = user.get_equipped_items()
	if (!length(possessions))
		to_chat(user, span_notice("...but you don't have any."))
		return

	var/obj/some_item = pick(possessions)
	user.dropItemToGround(some_item)
	some_item.animate_atom_living(user)
