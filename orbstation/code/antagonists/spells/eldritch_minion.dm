/**
 * A book which lets you get a little buddy from the ghost pool.
 * Designed for wizard journeyman, but a fun tool for admin events too probably.
 */
/obj/item/demonology_for_dummies
	name = "Demonology for Dummies"
	desc = "This book describes the secrets of the veil between worlds. \
		Use it to create a summoning circle, after which it will burn to ash."
	icon = 'icons/obj/antags/eldritch.dmi'
	base_icon_state = "book"
	icon_state = "book"
	worn_icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	/// Are we drawing a rune?
	var/drawing_rune = FALSE
	/// Places you can't draw a ritual circle
	var/static/list/no_draw_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/lava, /turf/open/chasm))

// Happily stolen from Violet
/obj/item/demonology_for_dummies/examine(mob/user)
	. = ..()
	var/num_ghosts = length(GLOB.current_observers_list) + length(GLOB.dead_player_list)
	var/num_orbiters = 0
	for(var/mob/dead/ghost in user.orbiters?.orbiter_list)
		if(!ghost.client) // skip over orbiters who aren't actually connected
			continue
		num_orbiters++

	. += "Faded text is written on a dusty page..."
	if (num_ghosts == 0)
		. += span_cult("The spirit world is quiet... try again later.")
	else
		. += span_cult("Spirits following you: <b>[num_orbiters] / [num_ghosts]</b>")

/obj/item/demonology_for_dummies/interact_with_atom(atom/target, mob/user, list/modifiers)
	if (drawing_rune)
		user.balloon_alert(user, "already busy!")
		return

	if (!check_allowed_items(target) || !isliving(user))
		return

	if (isturf(target))
		try_draw_rune(user, target)
		return ITEM_INTERACT_SUCCESS

/obj/item/demonology_for_dummies/proc/try_draw_rune(mob/living/user, turf/target_turf)
	for (var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if (!isopenturf(nearby_turf) || is_type_in_typecache(nearby_turf, no_draw_turfs))
			user.balloon_alert(user, "you need a clear 3x3 area!")
			return

	user.visible_message(span_notice("[user] starts mumbling and lines of fire appear on the ground!"))
	drawing_rune = TRUE
	user.balloon_alert(user, "drawing rune...")
	if (!do_after(user, 5 SECONDS, target_turf))
		user.balloon_alert(user, "interrupted!")
		drawing_rune = FALSE
		return FALSE

	user.balloon_alert(user, "rune complete")
	playsound(src, 'sound/effects/magic/staff_animation.ogg', 5, TRUE, 5)
	drawing_rune = FALSE
	user.visible_message(span_notice("[src] crumbles to dust as an unnerving sigil takes shape!"))

	new /obj/effect/demonology_rune(target_turf)
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)

/// If you click on this then you can summon a pal
/obj/effect/demonology_rune
	name = "demonology rune"
	desc = "A flowing circle of shapes and runes is etched into the floor, filled with a thick black tar-like fluid."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "transmutation_rune"
	pixel_x = -32
	pixel_y = -32
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = RUNE_LAYER
	/// Stops spam clicking
	var/is_in_use = FALSE
	/// What are we going to summon?
	var/datum/demonological_summon/chosen_minion

/obj/effect/demonology_rune/can_interact(mob/living/user)
	. = ..()
	if(!.)
		return
	if(is_in_use)
		return FALSE

/obj/effect/demonology_rune/interact(mob/living/user)
	. = ..()
	if (!chosen_minion)
		choose_minion(user)
		return

	INVOKE_ASYNC(src, PROC_REF(summon_minion), user)
	return TRUE

/// Pick a minion
/obj/effect/demonology_rune/proc/choose_minion(mob/living/user)
	var/static/list/options = list()
	var/static/list/picks_to_instances = list()

	if (length(options) == 0)
		for (var/type in subtypesof(/datum/demonological_summon))
			var/datum/demonological_summon/summon = new type()
			var/datum/radial_menu_choice/choice = summon.generate_radial_entry()
			if (!choice)
				continue
			options += list("[choice.name]" = choice)
			picks_to_instances[choice.name] = summon

	var/pick = show_radial_menu(user, user, options, require_near = TRUE, tooltips = TRUE)
	if (!pick)
		return
	chosen_minion = picks_to_instances[pick]

/// Try to make a minion, if ghosts are up for it
/obj/effect/demonology_rune/proc/summon_minion(mob/living/user)
	is_in_use = TRUE
	var/mob/summoned = chosen_minion.summon(user, get_turf(src))
	is_in_use = FALSE

	if (!summoned)
		user.balloon_alert(user, "ritual failed, no ghosts!")
		return

	user.visible_message(span_notice("[src] burns away in a flash as the [summoned.name] corporealises!"))
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)

/**
 * That's right maintainers it's three o'clock, time for another of Jac's datums to use "subtypesof" on.
 * This one represents a beastie you can make. Frankly, I only really need it for the tooltips.
 * Unfortunately I think the tooltips are important.
 */
/datum/demonological_summon
	/// Description of the beast
	var/desc
	/// Path of the beast
	var/mob_path

/datum/demonological_summon/proc/generate_radial_entry()
	if (!mob_path)
		return
	var/datum/radial_menu_choice/choice = new()
	var/mob/demon_type = mob_path
	choice.name = initial(demon_type.name)
	choice.image = image(icon = initial(demon_type.icon), icon_state = initial(demon_type.icon_state))
	choice.info = desc
	return choice

/**
 * Create a monster and try and put a ghost inside it
 * This is mostly just copied heretic code, if it ain't broke...
 */
/datum/demonological_summon/proc/summon(mob/living/user, turf/summon_location)
	var/mob/living/summoned = new mob_path(summon_location)
	summoned.alpha = 0
	ADD_TRAIT(summoned, TRAIT_NO_TRANSFORM, REF(src))
	summoned.move_resist = MOVE_FORCE_OVERPOWERING
	animate(summoned, 10 SECONDS, alpha = 155)

	message_admins("A [summoned.name] is being summoned by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(summoned)].")
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghosts_for_target(
		question = "Do you want to play as [user.real_name]'s [summoned.real_name] minion?",
		role = ROLE_SENTIENCE,
		check_jobban = ROLE_SENTIENCE,
		poll_time = 10 SECONDS,
		checked_target  = summoned,
		alert_pic  = summoned)
	if(!LAZYLEN(candidates))
		animate(summoned, 0.5 SECONDS, alpha = 0)
		QDEL_IN(summoned, 0.6 SECONDS)
		return FALSE

	var/mob/dead/observer/picked_candidate = pick(candidates)
	// Ok let's make them an interactable mob now, since we got a ghost
	summoned.alpha = 255
	REMOVE_TRAIT(summoned, TRAIT_NO_TRANSFORM, REF(src))
	summoned.move_resist = initial(summoned.move_resist)

	summoned.ghostize(FALSE)
	summoned.key = picked_candidate.key

	user.log_message("created a [summoned.name], controlled by [key_name(picked_candidate)].", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a [summoned.name], [ADMIN_LOOKUPFLW(summoned)].")

	var/datum/antagonist/heretic_monster/heretic_monster = summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	heretic_monster.set_owner(user.mind)

	return summoned

// Not sure why you'd pick this but I think it should be on the list anyway
/datum/demonological_summon/shade
	desc = "A corporeal spirit which moves very quickly and can travel gaseously through vents. A fragile scout. \
		Its fickle loyalty can be borrowed by anyone bearing a Soul Shard."
	mob_path = /mob/living/basic/shade

// I'm not including juggernaut or artificer frankly because they're just a bit boring
/datum/demonological_summon/wraith
	desc = "A shell of mystic metal animated by a bound spirit. It can move quickly and travel through walls. \
		A fragile assassin."
	mob_path = /mob/living/basic/construct/wraith/mystic

/// I suspect the most popular one
/datum/demonological_summon/prophet
	desc = "A constructed of stitched-together limbs which tumbles end-over-end. It can see and travel through walls and \
		link people together in a psychic web. A fragile scout."
	mob_path = /mob/living/basic/heretic_summon/raw_prophet

/datum/demonological_summon/rust_walker
	desc = "A mechanical beast animated by a bound spirit. It spreads rust to destroy structures and machines, and can expel rust at its enemies \
		to poison and disorient them. Heals while in rusted areas. A brawler, and not a creature of subtlety."
	mob_path = /mob/living/basic/heretic_summon/rust_walker

/datum/demonological_summon/ash_spirit
	desc = "A spirit bound in the corpses of flames. It can inflict horrible wounds and wreathe itself in flames. \
		A brawler, and not a creature of subtlety."
	mob_path = /mob/living/basic/heretic_summon/ash_spirit

/datum/demonological_summon/stalker
	desc = "A constructed of stitched-together limbs which can reshape its flesh into a disguise. It can emit energy \
		which destroys machines, and teleport a short distance. A durable ambusher. One of few summoned creatures \
		which can accompany you unobtrusively, while it takes on another form."
	mob_path = /mob/living/basic/heretic_summon/stalker

/datum/demonological_summon/maid
	desc = "A barely-tangible spirit which can see through walls and vanish into reflective surfaces. A durable scout. \
		One of few summoned creatures which can accompany you unobtrusively, while it is invisible inside the mirror world."
	mob_path = /mob/living/basic/heretic_summon/maid_in_the_mirror
