/**
 * Makes runes which teleport you to random other runes when crossed
 */
/obj/item/gun/magic/wand/teleport_rune
	name = "connecting rod"
	desc = "Eliminates the space between all targeted points. Great for making your house really confusing to navigate."
	school = SCHOOL_TRANSLOCATION
	ammo_type = /obj/item/ammo_casing/magic/teleport_rune
	icon_state = "telewand"
	base_icon_state = "telewand"
	fire_sound = 'sound/effects/magic/teleport_app.ogg'
	max_charges = 12

/obj/item/gun/magic/wand/teleport_rune/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	var/obj/effect/connective_ward/rune = new(get_turf(user))
	rune.trigger_cooldown()
	rune.teleport_contents()
	charges--

/obj/item/ammo_casing/magic/teleport_rune
	projectile_type = /obj/projectile/magic/teleport_rune
	harmful = FALSE

/obj/projectile/magic/teleport_rune
	name = "bolt of connection"
	icon_state = "e_netting"
	projectile_phasing =  PASSGLASS | PASSGRILLE

/obj/projectile/magic/teleport_rune/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/turf/hit_loc = get_turf(target)
	if (iswallturf(hit_loc))
		return
	var/obj/effect/connective_ward/rune = new(hit_loc)
	rune.trigger_cooldown()
	rune.teleport_contents()

/// List of connective wards
GLOBAL_LIST_INIT(connected_wards, list())

/// If you step on this you teleport to a different one
/obj/effect/connective_ward
	name = "Connective Ward"
	desc = "This point is connected to another point. Which one? Why not find out?"
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "ward"
	density = FALSE
	anchored = TRUE
	layer = RUNE_LAYER
	///Cooldown for teleporting, shared by all runes in case they infinitely loop when receiving contents
	var/static/cooldown_time = 1 SECONDS
	/// Storage for last activated time
	var/static/last_activated_time = 0

/obj/effect/connective_ward/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, loc_connections)
	GLOB.connected_wards += src

/obj/effect/connective_ward/Destroy()
	GLOB.connected_wards -= src
	return ..()

/obj/effect/connective_ward/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if (length(GLOB.connected_wards) < 2)
		return
	if (world.time - last_activated_time < cooldown_time)
		return
	trigger_cooldown()
	teleport_contents()

/obj/effect/connective_ward/proc/trigger_cooldown()
	last_activated_time = world.time

/obj/effect/connective_ward/proc/teleport_contents()
	if (length(GLOB.connected_wards) < 2)
		return
	var/turf/my_loc =  get_turf(src)
	var/list/to_teleport = list()
	for (var/atom/movable/thing in my_loc.contents)
		if (!ismob(thing) && !isobj(thing))
			continue
		if (thing.anchored)
			continue
		if(!thing.loc)
			continue
		if (isobserver(thing))
			continue
		to_teleport += thing
	to_teleport -= src

	var/list/potential_destinations = GLOB.connected_wards.Copy()
	potential_destinations -= src
	var/turf/destination = get_turf(pick(potential_destinations))
	for (var/thing in to_teleport)
		do_teleport(thing,
			destination,
			channel = TELEPORT_CHANNEL_MAGIC,)
	playsound(src, 'sound/effects/magic/wand_teleport.ogg', 50)
	playsound(destination, 'sound/effects/magic/wand_teleport.ogg', 50)
