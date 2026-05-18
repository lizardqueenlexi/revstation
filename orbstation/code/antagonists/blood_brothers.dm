#define COMSIG_BB_PAD_COMPLETE "bb_pad_complete"
#define COMSIG_BB_BOUNTY_SUCCESS "bb_bounty_success"

/// equipping blood brothers with new implant
/datum/antagonist/brother/on_gain()
	. = ..()
	var/datum/objective/steal/brothers/light_steal = locate() in objectives
	if(!light_steal)
		return
	var/obj/item/implant/holo_pad_projector/bb_implant = new(owner.current)
	bb_implant.brother_bounty = list(light_steal.steal_target) + light_steal.targetinfo.altitems
	bb_implant.delivery_site = team.delivery_site
	bb_implant.implant(owner.current, silent = TRUE)
	RegisterSignal(bb_implant, COMSIG_BB_BOUNTY_SUCCESS, PROC_REF(bounty_success))

/// called when objective is succeeded and lets team datum know
/datum/antagonist/brother/proc/bounty_success()
	SIGNAL_HANDLER
	var/datum/team/brother_team/the_bros = team
	the_bros.bounty_complete()

/datum/antagonist/brother/on_removal()
	var/obj/item/implant/holo_pad_projector/possible_implant = locate() in owner.current.implants
	if(possible_implant)
		qdel(possible_implant)
	return ..()

//changes to objectives.

/datum/objective/steal/brothers
	/// Where the objective is to be delivered to
	var/delivery_site
	/// Don't try to deliver these items
	var/static/list/brothers_blacklist = list(
		/datum/objective_item/steal/blackbox,
		/datum/objective_item/steal/blueprints,
		/datum/objective_item/steal/documents,
		/datum/objective_item/steal/functionalai,
		/datum/objective_item/steal/hdd_extraction,
		/datum/objective_item/steal/nukedisc,
		/datum/objective_item/steal/nuke_core,
		/datum/objective_item/steal/supermatter,
	)

/datum/objective/steal/brothers/find_target(dupe_search_range, list/blacklist)
	var/list/datum/mind/owners = get_owners()
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/approved_targets = list()
	for(var/datum/objective_item/possible_item in GLOB.possible_items)
		if(!possible_item.valid_objective_for(owners, require_owner = TRUE))
			continue
		if(possible_item.objective_type != OBJECTIVE_ITEM_TYPE_NORMAL)
			continue
		if(is_type_in_list(possible_item, brothers_blacklist))
			continue
		if(!is_unique_objective(possible_item.targetitem,dupe_search_range))
			continue
		approved_targets += possible_item
	if (length(approved_targets))
		return set_target(pick(approved_targets))
	return set_target(null)

/datum/objective/steal/brothers/set_target(datum/objective_item/item)
	. = ..()
	if(!item)
		return
	explanation_text = "Steal [targetinfo.name] and deliver it to the Syndicate by using your bounty pad projector implant at [delivery_site]."

/datum/objective/steal/heist_bros
	name = "Steal (Hard)"
	/// list of objectives that require special gear and getting to a dangerous area or target
	var/static/list/heists = list(
		/datum/objective_item/steal/supermatter,
		/datum/objective_item/steal/nuke_core,
		/datum/objective_item/steal/functionalai,
		/datum/objective_item/steal/hdd_extraction,
	)

/datum/objective/steal/heist_bros/find_target(dupe_search_range, list/blacklist)
	var/heist_target = pick(heists)
	return set_target(new heist_target)

/datum/team/brother_team
	/// Area in the station where you will use your implant to deliver your item for extra gear
	var/area/delivery_site
	/// whitelist of areas chosen because you do not have to break into them and could potentially be seen
	var/static/list/delivery_whitelist = list(
		/area/station/hallway/secondary/exit/departure_lounge,
		/area/station/hallway/secondary/entry,
		/area/station/commons/dorms,
		/area/station/commons/dorms/laundry,
		/area/station/commons/toilet,
		/area/station/commons/lounge,
		/area/station/commons/fitness,
		/area/station/commons/vacant_room/office,
		/area/station/commons/vacant_room/commissary,
		/area/station/commons/storage/tools,
		/area/station/commons/storage/primary,
		/area/station/service/cafeteria,
		/area/station/service/kitchen/diner,
		/area/station/service/library,
		/area/station/service/chapel,
		/area/station/service/hydroponics/garden,
		/area/station/holodeck,
		/area/station/hallway/secondary/exit,
		/area/station/maintenance/tram,
	)

/datum/team/brother_team/New(starting_members)
	. = ..()
	var/list/delivery_selection = list()
	for(var/area in delivery_whitelist)
		if(!(area in GLOB.the_station_areas))
			continue
		delivery_selection += area
	delivery_site = pick(delivery_selection)

/// completes objective and removes implants from all blood brothers
/datum/team/brother_team/proc/bounty_complete()
	var/datum/objective/steal/brothers/steal_objective = locate() in objectives
	if(steal_objective)
		steal_objective.completed = TRUE

	var/datum/objective/assassinate/newkill = new()
	newkill.team = src
	newkill.find_target()
	newkill.update_explanation_text()
	objectives += newkill

	for(var/datum/mind/brother in members)
		var/obj/item/implant/holo_pad_projector/possible_implant = locate() in brother.current.implants
		if(!possible_implant)
			continue
		qdel(possible_implant)
		to_chat(brother.current, span_notice("Your implant fizzles away! The Syndicate has given you a new objective."))
		var/datum/antagonist/brother/bb_datum = brother.has_antag_datum(/datum/antagonist/brother)
		bb_datum.objectives += newkill
		log_traitor("BLOOD BROTHER: [name] delivered a [steal_objective.steal_target] at [round_timestamp()].")

/// generates a light steal objective if there are no objectives and then from then on generates murder or heist objectives
/datum/team/brother_team/forge_single_objective()
	if(!length(objectives))
		var/datum/objective/steal/brothers/steal_objective = new()
		steal_objective.delivery_site = initial(delivery_site.name)
		add_objective(steal_objective, needs_target = TRUE)
		return
	forge_hard_objective()

/// generates either killing or destroying another player or a complicated steal objective
/datum/team/brother_team/proc/forge_hard_objective()
	if(prob(66))
		if(LAZYLEN(active_ais()) && prob(100/GLOB.joined_player_list.len))
			add_objective(new /datum/objective/destroy, needs_target = TRUE)
		else if(prob(30))
			add_objective(new /datum/objective/maroon, needs_target = TRUE)
		else
			add_objective(new /datum/objective/assassinate, needs_target = TRUE)
	else
		add_objective(new /datum/objective/steal/heist_bros, needs_target = TRUE)

// new blood brother items.

/// implant on blood brothers that gives them a holo bounty pad
/obj/item/implant/holo_pad_projector
	name = "holographic bounty pad projector implant"
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "bci_wireless"
	implant_color = "r"
	/// Weak reference to if the pad has been activated by this implant or not
	var/datum/weakref/active_pad
	/// Area where the implant will activate
	var/delivery_site
	///The item that the blood brother has to steal
	var/list/brother_bounty

/obj/item/implant/holo_pad_projector/activate()
	. = ..()
	var/obj/effect/holo_pad/syndie_pad = active_pad?.resolve()
	if(syndie_pad)
		qdel(syndie_pad)
		return
	if(!istype(get_area(src), delivery_site))
		imp_in.balloon_alert(imp_in, "incorrect area!")
		return
	var/turf/our_turf = get_turf(src)
	if(our_turf.is_blocked_turf(exclude_mobs = TRUE))
		imp_in.balloon_alert(imp_in, "blocked!")
		return
	var/obj/effect/holo_pad/other_pad = locate() in our_turf
	if(other_pad)
		imp_in.balloon_alert(imp_in, "already a pad there!")
		return
	syndie_pad = new(our_turf)
	syndie_pad.brother_bounty = brother_bounty
	active_pad = WEAKREF(syndie_pad)
	RegisterSignal(syndie_pad, COMSIG_BB_PAD_COMPLETE, PROC_REF(pad_completion))

/// called when holo pad collects the correct item
/obj/item/implant/holo_pad_projector/proc/pad_completion()
	SIGNAL_HANDLER
	SEND_SIGNAL(src, COMSIG_BB_BOUNTY_SUCCESS)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BB_PAD_COMPLETE)


/// syndicate holo bounty pad capable of sending items to the syndicate in exchange for some gear.
/obj/effect/holo_pad
	name = "Syndicate Bounty Pad"
	desc = "A console used to complete illegal bounties for the Syndicate."
	alpha = 150
	icon = 'icons/obj/machines/telepad.dmi'
	icon_state = "lpad-idle"
	///The item that it will accept and mark as complete
	var/list/brother_bounty

/obj/effect/holo_pad/Initialize()
	. = ..()
	add_atom_colour("#ff3737", FIXED_COLOUR_PRIORITY)
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, connections)

/obj/effect/holo_pad/proc/on_entered(datum/source, atom/movable/possible_bounty)
	SIGNAL_HANDLER
	if(!is_type_in_list(possible_bounty, brother_bounty))
		return
	// prevents steals to give double rewards
	if(istype(possible_bounty, /obj/item/mob_holder))
		return
	complete_light_steal(possible_bounty)

/// proc that fires when pad detects the correct item
/obj/effect/holo_pad/proc/complete_light_steal(atom/stolen_thing)
	qdel(stolen_thing)
	playsound(loc, 'sound/machines/wewewew.ogg', 70, TRUE)
	new /obj/effect/temp_visual/delivery_flash(loc)
	spawn_syndicrate()
	SEND_SIGNAL(src, COMSIG_BB_PAD_COMPLETE)
	qdel(src)

/// proc that generates valid traitor items for the steal objective and puts it in a crate
/obj/effect/holo_pad/proc/generate_reward_crate()
	var/list/possible_items = list()
	for(var/datum/uplink_item/item_path as anything in SStraitor.uplink_items_by_type)
		var/datum/uplink_item/uplink_item = SStraitor.uplink_items_by_type[item_path]
		if(!uplink_item.item)
			continue
		if(!(uplink_item.purchasable_from & UPLINK_TRAITORS))
			continue
		if(length(uplink_item.restricted_roles) || length(uplink_item.restricted_species))
			continue
		if(!uplink_item.surplus)
			continue
		if(uplink_item.progression_minimum)
			continue
		possible_items += uplink_item
	var/obj/structure/closet/crate/secure/syndicrate/surplus_crate = new
	var/tc_budget = 25
	while(tc_budget)
		var/datum/uplink_item/uplink_item = pick_possible_item(possible_items, tc_budget)
		if(!uplink_item)
			continue
		tc_budget -= uplink_item.cost
		new uplink_item.item(surplus_crate)
		surplus_crate.locked = FALSE
		surplus_crate.created_items = TRUE
		surplus_crate.update_appearance(UPDATE_ICON)
	return surplus_crate

/// proc that checks against probability and costs for uplink items
/obj/effect/holo_pad/proc/pick_possible_item(list/possible_items, tc_budget)
	var/datum/uplink_item/uplink_item = pick(possible_items)
	if(prob(100 - uplink_item.surplus))
		return null
	if(tc_budget < uplink_item.cost)
		return null
	return uplink_item

/// proc that calls down a syndicrate for blood brothers with 0 reputation items worth 35 TC
/obj/effect/holo_pad/proc/spawn_syndicrate()
	var/list/landing_zones = list()
	for(var/turf/possible in range(1, loc))
		if(possible.is_blocked_turf(exclude_mobs = TRUE))
			continue
		landing_zones += possible
	podspawn(list(
		"target" = length(landing_zones) ? pick(landing_zones) : loc,
		"style" = /datum/pod_style/syndicate,
		"spawn" = generate_reward_crate(),
	))

/obj/effect/temp_visual/delivery_flash
	duration = 0.8 SECONDS
	icon_state = "medi_holo"

/obj/effect/temp_visual/delivery_flash/Initialize()
	. = ..()
	add_atom_colour("#ff3737", FIXED_COLOUR_PRIORITY)

#undef COMSIG_BB_PAD_COMPLETE
#undef COMSIG_BB_BOUNTY_SUCCESS
