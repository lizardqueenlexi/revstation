/**
 * Wand which makes you drunk, self-explanatory
 */

/obj/item/gun/magic/wand/booze
	name = "party wand"
	desc = "A wand which fills its target with copious amounts of alcohol. Use in moderation, unless you are \
		trying to give someone liver damage."
	school = SCHOOL_CONJURATION
	ammo_type = /obj/item/ammo_casing/magic/booze
	icon_state = "nothingwand"
	base_icon_state = "nothingwand"
	fire_sound = 'sound/effects/slosh.ogg'
	max_charges = 10

/obj/item/gun/magic/wand/booze/zap_self(mob/living/user, suicide = FALSE)
	playsound(user, fire_sound, 50, TRUE)
	user.log_message("zapped [user.p_them()]self with a <b>[src]</b>", LOG_ATTACK)
	user.visible_message(span_notice("[user] puts the [src] up to [user.p_their()] mouth and starts chugging!"))
	var/datum/reagent/consumable/ethanol/bacchus_blessing/booze = new()
	booze.expose_mob(user, INGEST)
	user.reagents.add_reagent(booze.type, 5)
	charges--

/obj/item/ammo_casing/magic/booze
	projectile_type = /obj/projectile/magic/booze

/obj/projectile/magic/booze
	name = "bolt of inebriation"
	icon_state = "energy"

/obj/projectile/magic/booze/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/carbon/victim = target
	if (!istype(victim))
		return
	var/datum/reagent/consumable/ethanol/bacchus_blessing/booze = new() // Only the best for wizards. Two shots is 60% liver damage.
	booze.expose_mob(victim, INGEST)
	victim.reagents.add_reagent(booze.type, 5)
