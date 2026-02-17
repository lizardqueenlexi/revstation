/datum/religion_sect/rat
	name = "Rat Worship"
	desc = "Sacrifice cheese and mouse traps to grant favour. Can only heal rats with their bible, but can do so beyond death itself."
	quote = "Let's see what kind of trouble we can get ourselves into."
	tgui_icon = "cheese"
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/food/ = "(especially cheese and dairy)", /obj/item/assembly/mousetrap)
	rites_list = list(/datum/religion_rites/ratconvert, /datum/religion_rites/pied_piper, /datum/religion_rites/ratclog)
	altar_icon_state = "convertaltar-maint"

#define SOUND_SQUEAK 'sound/mobs/non-humanoids/mouse/mousesqueek.ogg'

/datum/religion_sect/rat/sect_bless(mob/living/target, mob/living/chap)
	if (!ismouse(target) && !isregalrat(target))
		return FALSE
	if(target.health >= target.maxHealth)
		return TRUE
	if (ismouse(target))
		target.fully_heal()
	else
		target.heal_overall_damage(brute = 10, burn = 10)
	target.visible_message(span_notice("[chap] heals [target] with the power of [GLOB.deity]!"))
	to_chat(target, span_boldnotice("May the power of [GLOB.deity] compel you to be healed!"))
	playsound(chap, SOUND_SQUEAK, 25, TRUE, -1)
	return TRUE

/obj/item/food/deadmouse/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BIBLE_SMACKED, PROC_REF(on_bibled))

/// When hit by a bible, check if we can spring back to life
/obj/item/food/deadmouse/proc/on_bibled(datum/source, mob/living/user, direction)
	SIGNAL_HANDLER
	if(!istype(GLOB.religious_sect, /datum/religion_sect/rat) || !user.mind?.holy_role)
		return

	INVOKE_ASYNC(src, PROC_REF(reanimate), user)
	return COMSIG_END_BIBLE_CHAIN

/// Return from the grave
/obj/item/food/deadmouse/proc/reanimate(mob/living/user)
	balloon_alert(user, "reanimating...")
	playsound(src, 'sound/effects/singlebeat.ogg', 60, TRUE)
	if(!do_after(user, 4 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return
	playsound(src, 'sound/effects/magic/magic_block_holy.ogg', 60, TRUE)
	var/mob/living/basic/mouse/new_mouse = new(get_turf(src), /* tame = */ TRUE)
	new_mouse.visible_message(span_notice("[new_mouse] miraculously springs to life!"))
	qdel(src)

#define TRAP_FAVOUR 25
#define DAIRY_BONUS_MULT 2
#define PER_NUTRIMENT_FAVOUR 1

/datum/religion_sect/rat/on_sacrifice(obj/item/I, mob/living/chap)
	if (istype(I, /obj/item/assembly/mousetrap))
		to_chat(chap, span_notice("[GLOB.deity] is pleased that this trap will trouble their children no more."))
		playsound(chap, SOUND_SQUEAK, 25, TRUE, -1)
		adjust_favor(TRAP_FAVOUR, chap)
		qdel(I)
		return TRUE

	if (IS_EDIBLE(I))
		var/obj/item/food/the_food = I
		var/datum/reagent/N = I.reagents.has_reagent(/datum/reagent/consumable/nutriment, check_subtypes = TRUE)
		var/food_favour = (N.volume + 1) * PER_NUTRIMENT_FAVOUR
		if (the_food.foodtypes & DAIRY)
			food_favour *= DAIRY_BONUS_MULT

		adjust_favor(food_favour, chap)
		to_chat(chap, span_notice("You offer [the_food] to [GLOB.deity], pleasing them."))
		playsound(chap, SOUND_SQUEAK, 25, TRUE, -1)
		qdel(I)
		return TRUE

	return

#undef TRAP_FAVOUR
#undef DAIRY_BONUS_MULT
#undef PER_NUTRIMENT_FAVOUR

/// A rite to fill people with rat spit, so rats won't attack them
/datum/religion_rites/ratconvert
	name = "Rat Monarch Blessing"
	desc = "Undergo the trial of the Rat Monarchs, after which rats will regard you as kin. Buckle a human to your altar to bless them, otherwise it will bless you."
	ritual_length = 10 SECONDS
	ritual_invocations = list("Open our eyes to see your children!",
	"Open our ears to hear your voice!")
	invoke_msg = "Open our mouths to receive your blessing!"
	favor_cost = 25

/datum/religion_rites/ratconvert/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires an altar that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("You're going to bless the one buckled on [movable_reltool]."))
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, span_warning("This rite requires an altar that individuals can be buckled to."))
			return FALSE
		to_chat(user, span_warning("You're going to bless yourself with this ritual."))
	return ..()

/datum/religion_rites/ratconvert/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE

	if (rite_target.has_faction(FACTION_RAT))
		rite_target.visible_message(span_notice("[rite_target] has already received the blessing!"))
		return FALSE

	rite_target.reagents.add_reagent(/datum/reagent/rat_holy_water, 22)
	rite_target.visible_message(span_notice("[rite_target] starts to feel strange!"))
	return TRUE

/datum/reagent/rat_holy_water
	name = "Rat Holy Water"
	description = "Something from a rat god!"
	color = "#C8C8C8"
	metabolization_rate = REAGENTS_METABOLISM
	taste_description = "something furry"

/datum/reagent/rat_holy_water/on_mob_life(mob/living/carbon/C)
	C.reagents.add_reagent(/datum/reagent/rat_spit, 2 * REAGENTS_METABOLISM)
	..()

/// A rite which makes mice or rats appear... somewhere
/datum/religion_rites/ratclog
	name = "Call Forth Rodents"
	desc = "Somewhere on the station, they will hear your call."
	ritual_length = 30 SECONDS
	ritual_invocations = list("We prey at night!",
	"We stalk at night!",
	"Scamper forth into this land of plenty ...")
	invoke_msg = "... let's see what kind of trouble we can get ourselves into!"
	favor_cost = 200

/datum/religion_rites/ratclog/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/datum/round_event_control/vent_clog/rats/event = locate(/datum/round_event_control/vent_clog/rats) in SSevents.control
	if(event.run_event())
		to_chat(user, span_notice("You hear a distant scratching and scuttling."))
		return TRUE
	to_chat(user, span_notice("It appears that no more rats are forthcoming."))
	return FALSE

/datum/round_event_control/vent_clog/rats
	name = "Rat Clog"
	typepath = /datum/round_event/vent_clog/rats
	weight = 0
	max_occurrences = 0

/datum/round_event/vent_clog/rats/setup()
	. = ..()
	maximum_spawns = rand(3,5)
	spawn_delay = rand(15,20)
	filth_spawn_types = list(
		/obj/effect/decal/cleanable/fuel_pool,
		/obj/effect/decal/cleanable/vomit,
		/obj/item/food/cheese/wedge, //it's not a decal but it IS funny
	)

/datum/round_event/vent_clog/rats/get_mob()
	var/static/list/mob_list = list(
		/mob/living/basic/mouse,
		/mob/living/basic/mouse,
		/mob/living/basic/mouse,
		/mob/living/basic/mouse/rat,
	)
	return pick(mob_list)

/datum/round_event/vent_clog/rats/announce()
	priority_announce("Rodent population explosion detected in the ventilation network. Blockage is believed to be in the [get_area_name(vent)] area.", "Infestation Alert")

/// A rite which befriends a rat or mouse, if it doesn't already have an owner
/datum/religion_rites/pied_piper
	name = "Piper's Charm"
	desc = "Whisper into the ear of a rodent placed upon your altar, persuading it to be a loyal companion."
	ritual_length = 10 SECONDS
	ritual_invocations = list("#Squeak squeak squeak.",
	"#Eek squeak eek? Squeak eek.")
	invoke_msg = "Squeak squeak eek squeak eek!"
	favor_cost = 100
	/// List of instructions we can give to a mouse
	var/static/list/mouse_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
	)

/datum/religion_rites/pied_piper/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		religious_tool.balloon_alert(user, "invalid altar!")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		religious_tool.balloon_alert(user, "no valid target!")
		return FALSE
	var/mouse_count = 0
	for (var/mob/living/basic/mouse/target_mouse in movable_reltool.buckled_mobs)
		if(target_mouse.GetComponent(/datum/component/obeys_commands))
			mouse_count++
			continue // Already converted
		to_chat(user, span_warning("You're going to bless the one buckled on [movable_reltool]."))
		return ..()
	if (mouse_count == 0)
		religious_tool.balloon_alert(user, "only works on mice!")
	else
		religious_tool.balloon_alert(user, "mouse already converted!")
	return FALSE

/datum/religion_rites/pied_piper/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/basic/mouse/rite_target
	var/mouse_count = 0
	for(var/mob/living/basic/mouse/target_mouse in movable_reltool.buckled_mobs)
		mouse_count++
		if(target_mouse.GetComponent(/datum/component/obeys_commands))
			continue
		rite_target = target_mouse
		break
	if(!rite_target)
		if (mouse_count == 0)
			religious_tool.balloon_alert(user, "mouse escaped!")
		else
			religious_tool.balloon_alert(user, "mouse already converted!")
		return FALSE

	var/list/command_list = mouse_commands.Copy()
	if (rite_target.obj_damage == 0) // This is a mouse, not a rat
		rite_target.ai_controller = new /datum/ai_controller/basic_controller/mouse_friend(rite_target)
	else
		command_list += /datum/pet_command/attack/mouse
	rite_target.AddComponent(/datum/component/obeys_commands, command_list)
	qdel(rite_target.GetComponent(/datum/component/tameable))
	rite_target.befriend(user)
	playsound(user, SOUND_SQUEAK, 25, TRUE, -1)
	rite_target.balloon_alert_to_viewers("squeak!")
	rite_target.resist_buckle()

/// Mouse AI which isn't scared of humans and can follow instructions
/datum/ai_controller/basic_controller/mouse_friend
	blackboard = list(
		BB_CURRENT_HUNTING_TARGET = null, // cheese
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // cable
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
		/datum/ai_planning_subtree/random_speech/mouse,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
	)

#undef SOUND_SQUEAK
