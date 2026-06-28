
ADMIN_VERB(display_shuffle_log, R_DEBUG|R_SERVER, "Local Shuffle Log", "Shows the local shuffle log", ADMIN_CATEGORY_DEBUG)
	var/area/area = get_area(usr)
	if(length(area.shuffle_log) == 0)
		if(config.Get(/datum/config_entry/flag/disable_table_shuffle))
			area.shuffle_log = "The table shuffle subsystem is disabled."
		else
			area.shuffle_log = "No events.  This may be because the probabilities are turned down, because there is nothing to shuffle or valid places to shuffle to and from, or just sheer bad luck."
	usr << browse("<u title='[area.type]'>[area]</u> Shuffle Log<br><div style='padding-left:3px;border-left:2px solid black;'>[area.shuffle_log]</div>","window=[area.type]_shuffle")

ADMIN_VERB(manual_table_shuffle, R_DEBUG|R_SERVER, "Shuffle Local Area", "Shuffles the local tables", ADMIN_CATEGORY_DEBUG)
	var/area/area = get_area(usr)
	var/tv = SStable_shuffle.total_vends
	var/tm = SStable_shuffle.total_moves
	var/td = SStable_shuffle.total_decays
	var/high = ""

	SStable_shuffle.shuffle_area(area,1)
	tv = SStable_shuffle.total_vends - tv
	tm = SStable_shuffle.total_moves - tm
	td = SStable_shuffle.total_decays - td

	if((tv + tm + td) > SStable_shuffle.high_roller_amt)
		high = "Got a high roller!  "

	if(tv > 0)
		tv = "Vended [SStable_shuffle.total_vends-tv] items. "
	else
		tv = ""
	if(tm > 0)
		tm = "Moved [SStable_shuffle.total_moves-tm] items. "
	else
		tm = ""
	if(td > 0)
		td = "[SStable_shuffle.total_decays-td] food items decayed. "
	else
		td = ""
	to_chat(usr,"Shuffled the local area. [high][tv][tm][td]")

// this overrides the shuffle_options bitfield
// depending on your probability scaling it may still underwhelm
ADMIN_VERB(extreme_table_shuffle, R_DEBUG|R_SERVER, "Shuffle Local Area (Max)", "Overrides the shuffle option bitfield", ADMIN_CATEGORY_DEBUG)
	var/area/area = get_area(usr)
	var/tv = SStable_shuffle.total_vends
	var/tm = SStable_shuffle.total_moves
	var/td = SStable_shuffle.total_decays
	var/high = ""

	SStable_shuffle.shuffle_area(area,2)
	tv = SStable_shuffle.total_vends - tv
	tm = SStable_shuffle.total_moves - tm
	td = SStable_shuffle.total_decays - td

	if((tv + tm + td) > SStable_shuffle.high_roller_amt)
		high = "Got a high roller!  "

	if(tv > 0)
		tv = "Vended [SStable_shuffle.total_vends-tv] items. "
	else
		tv = ""
	if(tm > 0)
		tm = "Moved [SStable_shuffle.total_moves-tm] items. "
	else
		tm = ""
	if(td > 0)
		td = "[SStable_shuffle.total_decays-td] food items decayed. "
	else
		td = ""
	to_chat(usr,"Shuffled the local area. [high][tv][tm][td]")

ADMIN_VERB(show_high_rollers, R_DEBUG|R_SERVER, "Shuffle show high rollers", "Display table shuffle high rollers", ADMIN_CATEGORY_DEBUG)
	if(config.Get(/datum/config_entry/flag/disable_table_shuffle))
		to_chat(usr,"Table shuffling subsystem is disabled.")
		return
	SStable_shuffle.display_high_rollers(usr)

/datum/controller/subsystem/table_shuffle/proc/display_high_rollers(mob/user)
	var/high_rollers_total = 0
	var/dat = "Probability values:<br>[prob_min] min - [prob_max] max<br>Add [prob_add], sub [prob_sub]<br>High roller threshold [high_roller_amt].<hr>"
	for(var/area/area in high_rollers)
		var/total = high_rollers[area]
		high_rollers_total += total
		dat += "<b>[area.name]</b>: [total] events<br>"
	user << browse("<h3>High Rollers List</h3><br>High rollers accounted for [high_rollers_total] of the [event_total] roundstart events.<hr>[dat]","window=tshuf_high_rollers")

/datum/controller/subsystem/table_shuffle/Topic(href,href_list)
	for(var/area_type in href_list)
		var/area/area = text2path(area_type)
		if(ispath(area) && (area in GLOB.areas_by_type))
			area = GLOB.areas_by_type[area]
			usr << browse("<u title='[area.type]'>[area]</u> Shuffle Log<br><div style='padding-left:3px;border-left:2px solid black;'>[area.shuffle_log]</div>","window=[area.type]_shuffle")
			return
	return ..()
