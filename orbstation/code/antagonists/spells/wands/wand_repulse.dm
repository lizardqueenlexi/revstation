/**
 * Repulsion wand throws things backwards, might hurt them a lot if they ram something
 */
/obj/item/gun/magic/wand/repulse
	name = "rod of repulsion"
	desc = "A wand which blasts things away from you."
	school = SCHOOL_TRANSLOCATION
	ammo_type = /obj/item/ammo_casing/magic/repulse
	icon_state = "telewand"
	base_icon_state = "telewand"
	fire_sound = 'sound/effects/magic/repulse.ogg'
	max_charges = 12

/obj/item/gun/magic/wand/repulse/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	user.visible_message(span_warning("[user] blasts themself into the ground!"))
	user.adjust_brute_loss(30)
	user.Paralyze(10 SECONDS)

/obj/item/ammo_casing/magic/repulse
	projectile_type = /obj/projectile/magic/repulse

/obj/projectile/magic/repulse
	name = "bolt of repulsion"
	icon_state = "blastwave"

/obj/projectile/magic/repulse/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/atom/movable/victim = target
	if (!istype(victim))
		return
	var/turf/throw_target = get_edge_target_turf(src, dir)
	victim.safe_throw_at(throw_target, 5, 1, force = MOVE_FORCE_STRONG)
	var/mob/living/living_target = target
	if (!istype(living_target))
		return
	living_target.Paralyze(2 SECONDS)
