/*
	Table Shuffle Code - Sayu

	Inserts a small amount of roundstart chaos to make things just a little less "same as always"
	There is a hard cap on how much chaos can be inserted per area, determined by the probability curves.
	Areas can be exempted from chaos entirely or have certain types of chaos removed.
	A few things can be "extra random" but even that is capped.

	Functionally, this file does none, some, or all of the following per area:
	* Finds all the vending machines, tables, racks, and unlocked cabinets and crates in an area, and
	* Vends some free products
	* Goes through the vended items, and items in tables, racks, and cabinets/crates, and:
		* May takes contents out of unlocked storage items (boxes, bags, belts, etc)
		* May turn food and flowers into appropriate trash
		* May drain drinks and table condiments (salt and pepper, anything in packs)
		* May disappear pills (individually)
		* May moves items onto another table or rack, or hide them in an unlocked cabinet or crate, or place them on chairs, beds, sinks, or toilets
		* May bumps items into an adjacent space, if they are still in the open (on a table, rack, vending machine, or outside a closet/crate)
		* May screw with where an item is placed on a table or rack (pixel_x/y, which items are on top, etc)
	* Logs all actions taken in "shuffle_log" area var, which can be read with the "local shuffle log" admin verb

	These options can be disabled per-area with the shuffle_options area var.
	Popular variations include "Don't screw with what's on tables or in storage", "Don't hide things in closets",
	"Don't screw with closets/crates at all", "Don't screw with racks (eg, Engineering Tech Storage)"
	Note that the code to put objects on toilets never hides objects in toilets, because nobody would think to look there ever.

	Other files of note related to this system:
	* __DEFINES/orb/table_shuffle.dm
	* table_shuffle_areas.dm
	* table_shuffle_verbs.dm
	* modules/admin/admin_verbs.dm (adding the above verbs)
*/

// Global var is named SStable_shuffle
SUBSYSTEM_DEF(table_shuffle)
	name = "Table Shuffle"
	ss_flags = SS_NO_FIRE
	dependencies = list(
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/mapping
	)

	var/total_vends = 0
	var/total_moves = 0
	var/total_decays= 0
	// These will be read from configuration
	var/vend_only = FALSE
	var/prob_min = 7.5
	var/prob_max = 77.5
	var/prob_add = 7.5
	var/prob_sub = 15
	var/prob_eat = 55
	var/prob_visual = 5
	var/vender_budget = 150

	var/high_roller_amt = 5
	var/affected_area_amt = 0 // used to compute an average later
	var/event_total = 0

	var/list/high_rollers = list()
	var/list/did_shuffle = list()

/datum/controller/subsystem/table_shuffle/Initialize()

#ifndef MAP_TEST

	if(config.Get(/datum/config_entry/flag/disable_table_shuffle))
		return SS_INIT_NO_NEED
	vend_only = config.Get(/datum/config_entry/flag/shuffle_vend_only)

	prob_min = config.Get(/datum/config_entry/number/shuffle_min_prob)
	prob_max = config.Get(/datum/config_entry/number/shuffle_max_prob)
	prob_add = config.Get(/datum/config_entry/number/shuffle_add_prob)
	prob_sub = config.Get(/datum/config_entry/number/shuffle_sub_prob)
	prob_eat = config.Get(/datum/config_entry/number/shuffle_eat_prob)
	prob_visual = config.Get(/datum/config_entry/number/shuffle_visual_prob)
	vender_budget = config.Get(/datum/config_entry/number/shuffle_vend_budget)
	high_roller_amt = config.Get(/datum/config_entry/number/shuffle_high_roller_threshold)

	for(var/area/area)
		var/events = shuffle_area(area,manual=0)
		if(events >= high_roller_amt)
			high_rollers[area] = events
		event_total += events

	// If you're looking at this line to understand what the average means,
	// note that "affected areas" only counts areas where events happened.
	// There are going to be several areas either immediately skipped or which
	// have nothing happen.
	var/msg
	if(affected_area_amt > 0)
		msg = "Table shuffle averaged [round(event_total / affected_area_amt)] events among [affected_area_amt] affected areas, [high_rollers.len] being high rollers."
	else
		if(event_total > 0) // shouldn't happen if the above doesn't
			msg = "Table shuffle had [event_total] phantom events this round."
		else
			msg = "Table shuffle had no events this round."
	to_chat(world, span_boldannounce("[msg]"))
	log_world(msg)

	// It would be better to map this in but I have zero doubts people will forget to
	// honestly it would ideally be in the librarian's protected room
	// secret occult stuff you know
	var/area/library = GLOB.areas_by_type[/area/station/service/library]
	if(library)
		var/list/candidate_tables = list()
		for(var/obj/structure/table/table in library)
			candidate_tables += table
		if(candidate_tables.len)
			var/obj/obj = pick(candidate_tables)
			if(istype(obj))
				new /obj/item/folder/shufflelog(obj.loc)

#endif
	return SS_INIT_SUCCESS

/**
 * shuffle_area(area,manual=0): determines what locations and objects in an area to pass to shuffle_decay_item()
 * controlled by table shuffle config entries (game_options.txt) and area shuffle constants (table_shuffle_areas.dm)
 * manual=1 logs shuffle as manual, manual=2 triggers maximum shuffle despite area restriction
 */

/datum/controller/subsystem/table_shuffle/proc/shuffle_area(area/area,manual = 0)
	if(!manual && (!is_station_level(area.z) || (area.shuffle_options == 0) || !prob(prob_max))) return

	var/list/table_turfs = list()
	var/list/unlocked_closets = list()
	var/list/boxes = list()
	var/list/vending = list()
	var/list/destinations = list()
	var/opt = area.shuffle_options

	var/static/list/machine_plumbing_types = list(/obj/machinery/atmospherics/components/unary/vent_scrubber,/obj/machinery/shower)

	// Machine furniture is anything that looks like you could set an object down on it, even if you can't (ie, it's flat on top)
	var/static/list/machine_furniture_types = list(/obj/machinery/biogenerator,/obj/machinery/bookbinder,/obj/machinery/chem_master,
		/obj/machinery/food_cart,/obj/machinery/icecream_vat,/obj/machinery/pdapainter,/obj/machinery/photocopier,
		/obj/machinery/pipedispenser,/obj/machinery/stasis,/obj/machinery/washing_machine,/obj/machinery/rnd/production)

	var/vend_prob = prob_min
	var/move_prob = prob_min

	if(vend_only) opt &= SHUFFLE_VEND_ONLY_MASK

	if(manual == 1)
		area.shuffle_log += "<hr>Manually started:<br>"
	else if(manual == 2)
		area.shuffle_log += "<hr>Manual Full-Shuffle:<br>"
		opt = SHUFFLE_ALL

	for(var/obj/structure/struct in area)
		if(istype(struct,/obj/structure/table) || istype(struct,/obj/structure/dresser))
			if(opt & SHUFFLE_FROM_TABLES)
				table_turfs[struct.loc] = struct
			if(opt & SHUFFLE_TO_TABLES)
				destinations[struct.loc]= struct
			if(opt & (SHUFFLE_FROM_TABLES+SHUFFLE_TO_TABLES))
				move_prob += prob_add
			if(opt & SHUFFLE_FROM_BOXES)
				for(var/obj/item/storage/box in struct.loc)
					if(istype(box,/obj/item/storage/briefcase/secure) || istype(box,/obj/item/storage/lockbox)) continue
					boxes += box
		else if(istype(struct,/obj/structure/rack))
			if(opt & SHUFFLE_FROM_RACKS)
				table_turfs[struct.loc]= struct
			if(opt & SHUFFLE_TO_RACKS)
				destinations[struct.loc] = struct
			if(opt & (SHUFFLE_FROM_RACKS + SHUFFLE_TO_RACKS))
				move_prob += prob_add
			if(opt & SHUFFLE_FROM_BOXES)
				for(var/obj/item/storage/box in struct.loc)
					if(istype(box,/obj/item/storage/briefcase/secure) || istype(box,/obj/item/storage/lockbox)) continue
					boxes += box
		else if(istype(struct,/obj/structure/closet))
			var/obj/structure/closet/closet = struct
			if(istype(closet,/obj/structure/closet/body_bag) || closet.opened || closet.secure || closet.welded || closet.locked)
				continue // oh man it would be funny if I let the contents of body bags be moved to tables, racks, or other closets
			if(opt & (SHUFFLE_FROM_CLOSETS | SHUFFLE_TO_CLOSETS))
				unlocked_closets += closet
				move_prob += prob_add
			if(opt & SHUFFLE_FROM_BOXES && (opt & SHUFFLE_FROM_CLOSETS))
				if(!closet.contents_initialized) // so glad they delayed doing this so that I could be the one to tear the shrink wrap.  sigh.
					closet.PopulateContents()
				for(var/obj/item/storage/box in closet)
					if(istype(box,/obj/item/storage/briefcase/secure) || istype(box,/obj/item/storage/lockbox)) continue
					boxes += box
		else if(istype(struct,/obj/structure/chair)) // dropped it while resting.  I'd add beds except bedsheets cover a lot.
			if(opt & SHUFFLE_TO_FURNITURE)
				move_prob += prob_add / 4 // some places have a whole lot of chairs
				destinations[struct.loc] = struct
		else if(istype(struct,/obj/structure/sink) || istype(struct,/obj/structure/toilet)) // dropped it while doing important work
			if(opt & SHUFFLE_TO_PLUMBING)
				move_prob += prob_add / 4 // not exactly a first-choice
				destinations[struct.loc] = struct
		else
			continue
	for(var/obj/machinery/mech in area)
		if(istype(mech,/obj/machinery/vending))
			vending += mech
			vend_prob += prob_add
			continue
		if(opt & SHUFFLE_TO_PLUMBING)
			var/found = 0
			for(var/t in machine_plumbing_types)
				if(istype(mech,t))
					move_prob += prob_add / 4 // not exactly a first-choice location
					destinations[mech.loc] = mech
					found = 1
					break
			if(found) continue
		if(opt & SHUFFLE_TO_FURNITURE)
			for(var/t in machine_furniture_types)
				if(istype(mech,t))
					move_prob += prob_add / 4 // not exactly a first-choice location
					destinations[mech.loc] = mech
					break

	if(!destinations.len)
		return // Boring area

	if(!manual)
		affected_area_amt++

	if(opt & SHUFFLE_EXTRA_MOVING)
		move_prob = min(prob_max,2*move_prob)

	if(opt & SHUFFLE_EXTRA_VENDING)
		vend_prob = min(prob_max,2*vend_prob)
	else
		vend_prob = min(prob_max,vend_prob)

	// I'm using a decaying probability scale to make it more likely to get anthing and less likely to get a lot
	// That means we want our lists to not be in predictable map-order or else the effect will be predictable.
	if(destinations.len > 1)
		shuffle_inplace(destinations)
	if(unlocked_closets.len > 1)
		shuffle_inplace(unlocked_closets)
	if(boxes.len > 1)
		shuffle_inplace(boxes)
	if(vending.len > 1)
		shuffle_inplace(vending)

	// A list of lists
	// Each list is formatted as [ITEMLOG_CURRENT_ITEM,ITEMLOG_ORIGINAL_LOC,ITEMLOG_ORIGINAL_ITEM,ITEMLOG_PERCENT_CONSUMED,ITEMLOG_DESTINATION_STRUCTURE]
	// dest_reference exists so if it's knocked on the floor we know what it's near.
	var/list/all_item_logs = list()

	// Cheap things in vending machines may have been bought and set down on a table or dropped next to the machine.
	if(opt & SHUFFLE_FROM_VENDING)
		for(var/obj/machinery/vending/vendor in vending)
			var/list/candidate_products = list()
			for(var/datum/data/vending_product/candy in vendor.product_records)
				if((candy.amount == 0) || (candy.price > vender_budget) || !prob(prob_max)) continue
				candidate_products += candy

			while(candidate_products.len && prob(vend_prob))
				var/datum/data/vending_product/candy = pick(candidate_products)
				if(candy.amount<=0) continue
				if(opt & SHUFFLE_EXTRA_VENDING)
					vend_prob -= prob_sub / 2
				else
					vend_prob -= prob_sub
				candy.amount--
				vendor.products[candy.product_path]--
				if(candy.amount == 0)
					candidate_products -= candy // in case we continue
				var/obj/item/item = new candy.product_path(vendor.loc)
				// [ITEMLOG_CURRENT_ITEM, ITEMLOG_ORIGINAL_LOC, ITEMLOG_ORIGINAL_ITEM, ITEMLOG_PERCENT_CONSUMED, ITEMLOG_DESTINATION_STRUCTURE]
				var/list/item_log = list(item,vendor,item,0,vendor)
				all_item_logs[item]=item_log
				if(opt & SHUFFLE_FROM_BOXES)
					if(istype(item,/obj/item/storage) && item.contents.len)
						boxes += item
				shuffle_decay_item(opt,item,table_turfs,destinations,unlocked_closets,item_log)
				if(item_log[ITEMLOG_CURRENT_ITEM] != item) // transformed
					all_item_logs -= item
					all_item_logs[item_log[ITEMLOG_CURRENT_ITEM]] = item_log

	// Unlocked closets might have objects moved or removed
	if(opt & SHUFFLE_FROM_CLOSETS)
		for(var/obj/structure/closet/closet in unlocked_closets.len)
			// Some places have a lot of full closets, lower probability
			var/closet_prob = min(prob_max,prob_min + closet.contents.len * prob_add) / 2
			if(opt & SHUFFLE_EXTRA_MOVING)
				closet_prob *= 2 // was already halved

			if(!closet.contents_initialized) // so glad they delayed doing this so that I could be the one to tear the shrink wrap.  sigh.
				closet.PopulateContents()

			while(closet.contents.len && prob(closet_prob))
				var/obj/item = pick(closet.contents)
				if(opt & SHUFFLE_FROM_BOXES)
					if(istype(item,/obj/item/storage) && item.contents.len)
						boxes += item
				item.forceMove(closet.loc)
				// [ITEMLOG_CURRENT_ITEM, ITEMLOG_ORIGINAL_LOC, ITEMLOG_ORIGINAL_ITEM, ITEMLOG_PERCENT_CONSUMED, ITEMLOG_DESTINATION_STRUCTURE]
				var/list/item_log = list(item,closet,item,0,closet)
				all_item_logs[item]=item_log
				closet_prob -= prob_sub
				move_prob -= prob_sub / 2 // This counts as half a move because we used a different seed to get there
				shuffle_decay_item(opt,item,table_turfs,destinations,unlocked_closets,item_log)
				if(item_log[ITEMLOG_CURRENT_ITEM] != item) // transformed
					all_item_logs -= item
					all_item_logs[item_log[ITEMLOG_CURRENT_ITEM]] = item_log

	// Box contents might be removed
	if(opt & SHUFFLE_FROM_BOXES)
		for(var/obj/item/storage/box in boxes)
			// Some places have a lot of full boxes, lower probability
			var/box_prob = min(prob_max,prob_min + box.contents.len * prob_add) / 2
			while(box.contents.len && prob(box_prob))
				var/obj/item = pick(box.contents)
				item.forceMove(get_turf(box))
				// We are trying to get a narrative reference point for the box's location for describe_journey
				var/atom/bloc = box.loc
				if(isturf(bloc))
					if(bloc in table_turfs)
						bloc = table_turfs[bloc]
					else if(bloc in destinations)
						bloc = destinations[bloc]
				// [ITEMLOG_CURRENT_ITEM, ITEMLOG_ORIGINAL_LOC, ITEMLOG_ORIGINAL_ITEM, ITEMLOG_PERCENT_CONSUMED, ITEMLOG_DESTINATION_STRUCTURE]
				var/list/item_log = list(item,box,item,0,bloc)
				all_item_logs[item] = item_log
				box_prob -= prob_sub
				move_prob -= prob_sub / 2
				shuffle_decay_item(opt,item,table_turfs,destinations,unlocked_closets,item_log)
				if(item_log[ITEMLOG_CURRENT_ITEM] != item) // transformed
					all_item_logs -= item
					all_item_logs[item_log[ITEMLOG_CURRENT_ITEM]] = item_log

	// Anything on a table or rack might be placed elsewhere, or fall off randomly
	var/list/candidate_items = list()
	if(opt & (SHUFFLE_FROM_TABLES|SHUFFLE_FROM_RACKS|SHUFFLE_VISUAL))
		for(var/turf/place in table_turfs)
			for(var/obj/item/item in place)
				if(item.anchored || item.density) continue
				if(opt & SHUFFLE_VISUAL)
					if(prob(prob_visual))
						item.moveToNullspace()
						item.forceMove(place) //change position in turf contents list (over/under other items)
					if(prob(prob_visual))
						item.pixel_x += rand(-8,8) // shift appearance on table/rack
						item.pixel_y += rand(-8,8)
				candidate_items += item

	// The process above created the list but also jostled things, so this is a separate logic check
	if(opt & (SHUFFLE_FROM_TABLES|SHUFFLE_FROM_RACKS))
		while(candidate_items.len && prob(move_prob))
			var/obj/item/item = pick_n_take(candidate_items)
			move_prob -= prob_sub
			var/list/item_log
			if(!(item in all_item_logs))
				// [ITEMLOG_CURRENT_ITEM, ITEMLOG_ORIGINAL_LOC, ITEMLOG_ORIGINAL_ITEM, ITEMLOG_PERCENT_CONSUMED, ITEMLOG_DESTINATION_STRUCTURE]
				item_log = all_item_logs[item] = list(item,item.loc,item,0,table_turfs[item.loc])
			else
				item_log = all_item_logs[item]
			shuffle_decay_item(opt,item,table_turfs,destinations,unlocked_closets,item_log)
			if(item_log[ITEMLOG_CURRENT_ITEM] != item) // transformed
				all_item_logs -= item
				all_item_logs[item_log[ITEMLOG_CURRENT_ITEM]] = item_log
	var/vends = 0
	var/moves = 0
	var/decays = 0
	var/non_events = 0
	var/total_events
	for(var/obj/item/item in all_item_logs)
		var/stats = describe_journey(area,item,all_item_logs[item],table_turfs,destinations)
		if(!stats)
			non_events++
			continue
		if(stats & JOURNEY_WAS_VENDED) vends++
		if(stats & JOURNEY_DID_MOVE) moves++
		if(stats & JOURNEY_WAS_CONSUMED) decays++
	total_events = all_item_logs.len - non_events
	if(total_events > 0)
		did_shuffle += area
		area.shuffle_log += "<p><b>In total, [vends] free items and [decays] consumed items out of [all_item_logs.len - non_events] events.</b></p>"
	if(!manual)
		total_vends += vends
		total_moves += moves
		total_decays += decays
		if(total_events == 0)
			affected_area_amt-- // we included it but nothing happened, don't contribute to total
	return total_events

/// extra_dirt: helper proc to spawn dirt, with some probability, and move it a little
/datum/controller/subsystem/table_shuffle/proc/extra_dirt(dirt_type, atom/loc)
	if(!prob(prob_min)) return
	step_rand(new dirt_type(loc))


/// log_decay: handles the return of obj/shuffle_decay(), called after item has moved to final location.  Returns the current object in case that has changed.
/datum/controller/subsystem/table_shuffle/proc/log_decay(opt,obj/item/item, list/item_log)
	// Check if irrelevant
	if(!(opt & SHUFFLE_DECAY) || !istype(item) || !prob(prob_eat))
		return item

	var/result = item.shuffle_decay()
	switch(result)
		if(null)
			item_log[ITEMLOG_PERCENT_CONSUMED] = ITEMLOG_CONSUMED_AND_TRANSFORMED
			return null
		if(0 to 100)
			item_log[ITEMLOG_PERCENT_CONSUMED] = result
			return item
		else
			if(istype(result,/obj))
				item_log[ITEMLOG_PERCENT_CONSUMED] = ITEMLOG_CONSUMED_AND_TRANSFORMED
				item_log[ITEMLOG_CURRENT_ITEM] = result
				return result

	CRASH("Table shuffle system has had an invalid result: [result]")


/**
 * shuffle_decay_item(): may place the item in a random closet or on random candidate turf, may call item shuffle_decay(), maintains item_log for describe_journey()
 */
/datum/controller/subsystem/table_shuffle/proc/shuffle_decay_item(opt,obj/item/item, list/source_turfs,list/candidate_turfs, list/candidate_closets,list/item_log)
	switch(pick(1,1,2,2,2,3))
		if(3)
			if(candidate_closets.len && (opt & SHUFFLE_TO_CLOSETS) )
				var/obj/O = pick(candidate_closets)
				item.forceMove(O)
				item_log[ITEMLOG_DESTINATION_STRUCTURE]=O
				item = log_decay(opt,item,item_log) // may return null
				if(isobj(item))
					item.pixel_x = 0
					item.pixel_y = 0
				return
			// otherwise fall through
		if(2)
			if(candidate_turfs.len) // This will only be full if you can shuffle to tables/racks
				var/turf/place = pick(candidate_turfs)
				if(place != item.loc)
					item.forceMove(place)
					item_log[ITEMLOG_DESTINATION_STRUCTURE] = candidate_turfs[place]
					item = log_decay(opt,item,item_log) // may return null
					if( item && (opt & SHUFFLE_VISUAL) && prob(prob_visual) )
						item.pixel_x = rand(-8,8)
						item.pixel_y = rand(-8,8)
					return
			// otherwise fall through

	var/turf/place = item.loc
	var/attempts = 2
	while(item.loc == place && attempts-- > 0) // step_rand doesn't care if it would run into a wall and fail
		step_rand(item)
	if(item.loc != place)
		// record a known thing we are on, if applicable
		if(item.loc in candidate_turfs)
			item_log[ITEMLOG_DESTINATION_STRUCTURE] = candidate_turfs[item.loc]
		else if(item.loc in source_turfs)
			item_log[ITEMLOG_DESTINATION_STRUCTURE] = source_turfs[item.loc]

		item = log_decay(opt,item,item_log) // may return null
		if( item && (opt & SHUFFLE_VISUAL) && prob(prob_visual) )
			item.pixel_x = rand(-8,8)
			item.pixel_y = rand(-8,8)

/**
 * describe_journey(): Generates debug logging and flavor text for table shuffle.
 * All table shuffle entries are stored in the area, and a series of paper logs
 * based on this may be generated by creating a /obj/item/folder/shufflelog
 */
/datum/controller/subsystem/table_shuffle/proc/describe_journey(area/area, obj/item/item, list/item_log,list/table_turfs,list/destinations)
	// journey list: [current_item, original_loc, original_item, consume_amt,dest_reference]
	// We can ignore current_item now (we needed it to track the effects of decay earlier)
	var/atom/origin = item_log[ITEMLOG_ORIGINAL_LOC]
	var/obj/item/original = item_log[ITEMLOG_ORIGINAL_ITEM]
	var/eat_amt = item_log[ITEMLOG_PERCENT_CONSUMED]
	var/atom/destination_reference = item_log[ITEMLOG_DESTINATION_STRUCTURE]
	var/atom/start_reference = null

	var/story = "<p>"
	var/journey_stats = JOURNEY_DID_MOVE

	// Easy start: vending
	if(istype(origin,/obj/machinery/vending))
		story += "<u title='[original?.type]'>[original]</u> was vended from <u title='[origin?.type]'>\the [origin]</u>. "
		journey_stats = JOURNEY_DID_MOVE | JOURNEY_WAS_VENDED
	// Complicated: Out of a box
	else if(istype(origin,/obj/item))
		// box was in closet/crate?
		if(istype(origin.loc,/obj/structure))
			story += "<u title='[original?.type]'>[original]</u> was removed from <u title='[origin?.type]'>\the [origin]</u> in <u title='[origin?.loc?.type]'>\the [origin?.loc]</u>. "
		// box was on a table/rack/etc?
		else if(isturf(origin.loc))
			if(origin.loc in table_turfs)
				start_reference = table_turfs[origin.loc]
				story += "<u title='[original?.type]'>[original]</u> was removed from <u title='[origin?.type]'>\the [origin]</u> on <u title='[start_reference?.type]'>\the [start_reference]</u>. "
			else // possibly started on something else or was vended?  May never occur
				story += "<u title='[original?.type]'>[original]</u> was removed from <u title='[origin?.type]'>\the [origin]</u>. "
		// ???
		else
			story += "<u title='[original?.type]'>[original]</u> had <u title='Not turf or recognized container'>a confusing beginning</u> on <u title='[origin?.type]'>\the [origin]</u>. "
	//Simpler: came out of a closet
	else if(istype(origin,/obj/structure)) // coming out of a closet or crate
		story += "<u title='[original?.type]'>[original]</u> was removed from <u title='[origin?.type]'>\the [origin]</u>. "
	// mostly simple: Probably started on a table/rack/etc
	else if(isturf(origin))
		if(origin in table_turfs)
			start_reference = table_turfs[origin]
			story += "<u title='[original?.type]'>[original]</u> started atop <u title='[start_reference?.type]'>\the [start_reference]</u>. "
		else
			story += "<u title='[original?.type]'>[original]</u> had <u title='Turf starting location, no reference structure'>a mysterious beginning</u> on <u title='[origin?.type]'>\the [origin]</u>. "
	else if(isnull(origin)) // this hasn't happened yet, but it's worth putting in
		story += "It turns out that <u title='[original?.type]'>\the [original]</u> was a destined hero brought here from <u title='Object started in nullspace'>another world</u>. "
	else
		story += "<u title='[original?.type]'>[original]</u> had <u title='Not turf or recognized container'>a confusing beginning</u> on <u title='[origin?.type]'>\the [origin]</u>. "

	if(eat_amt > 0)
		journey_stats += JOURNEY_WAS_CONSUMED
		if(eat_amt <= 100)
			story += "It was [eat_amt]% consumed. "
		else // value of ITEMLOG_CONSUMED_AND_TRANSFORMED (200) indicating the item was replaced / should be destroyed

			if(original != item)
				story += "It was consumed, leaving <u title='[item] ([item?.type])'>trash</u> behind. "
				qdel(original) // we kept the original until now

			else // Using the sentry value without changing the item means it disappears, we don't want to deal with nulls
				story += "It was consumed entirely."
				qdel(original)
				area.shuffle_log += story
				return journey_stats

	// I'm not implementing it right this minute but some things might mutate without being consumed, eg, latex gloves into balloons
	else if(original != item)
		story += "It was turned into <u title='[item?.type]'>\an [item]</u>. "
		qdel(original)

	var/turf/place = item.loc
	if(!isturf(place)) // Not on a turf - probably in a closet

		if(isnull(place))
			var/agent = pick("choir of angels","band of demons","posse of clowns","syndicate operative","Nanotrasen Death Squad","flying spaghetti monster","telekientic butt")
			var/safety = pick("heaven","hell","clown school","the syndicate","lavaland","the icemoon","nullspace","my butt","candy mountain")
			story += "\An [agent] whisked it away to <u title='Entity ended up in nullspace?'>[safety]</u> when nobody was looking.</p>"
		else
			story += "It got hidden in <u title='[place?.type]'>\the [place]</u>.</p>"
	// Was on a table and then knocked on the floor
	else if(place != get_turf(destination_reference))
		// It was moved to a different table before it was knocked down
		if(get_turf(destination_reference) != get_turf(origin))
			story += "It was moved to \the [destination_reference] and then knocked onto \the [item.loc].</p>"
		else // or it wasn't
			story += "It was knocked onto \the [item.loc].</p>"

	else // Still on the destination reference's turf

		// this shouldn't be, the destination reference should be set to an object
		if(isturf(destination_reference))
			story += "It <u title='reference object is a turf'>mysteriously</u> ended up on <u title='[destination_reference?.type]'>\the [destination_reference]</u>.</p>"

		// Not at the original location
		else if(place != get_turf(origin))
			if(start_reference && (start_reference.name == destination_reference.name)) // Notice if they are named the same thing
				story += "It was moved to another <u title='[destination_reference?.type]'>[destination_reference]</u>.</p>"
			else
				story += "It was moved to <u title='[destination_reference?.type]'>\the [destination_reference]</u>.</p>"

		else if(!isnull(place)) // probably vended and not moved
			story += "It was left there.</p>"
			journey_stats -= JOURNEY_DID_MOVE
			if(journey_stats == 0) // Non-event: this can happen if a non-vended item is randomly decided to move to its own location or failed to fall off a table
				return 0

		else // Can happen if the same item gets picked to move a second time after undergoing a destructive transformation
			var/agent = pick("choir of angels","band of demons","posse of clowns","syndicate operative","Nanotrasen Death Squad","flying spaghetti monster","telekientic butt")
			var/safety = pick("heaven","hell","clown school","the syndicate","lavaland","the icemoon","nullspace","my butt","candy mountain")
			story += "\An [agent] whisked it away to <u title='Entity ended up in nullspace?'>[safety]</u> when nobody was looking.</p>"
	area.shuffle_log += story
	return journey_stats
