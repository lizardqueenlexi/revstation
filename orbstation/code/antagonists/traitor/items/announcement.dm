#define TRAITOR_ANNOUNCE_MAX_LEN 500

/datum/uplink_item/badass/announcement
	name = "Intercept Announcement System"
	desc = "When purchased, you will be able to send one message on the stations announcement system. The syndicate can only perform this hack once per agent."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 0
	restricted = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	purchase_log_vis = FALSE

/datum/uplink_item/badass/announcement/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	var/anonymize_name = tgui_alert(user, "Would you like this message to be anonymous?", "Conceal Identity", list("Yes", "No"))
	var/should_anonymize = anonymize_name != "No"
	var/announcement_text = tgui_input_text(user, "Insert message to be sent to the announcement system:", "Evil Message", "PREPARE FOR YOUR DOOM!", TRAITOR_ANNOUNCE_MAX_LEN)
	if(!announcement_text) // such as if the user hits "cancel"
		uplink_handler.item_stock[stock_key] += 1
		return source
	if(should_anonymize)
		priority_announce(text = announcement_text, title = null, sound = 'sound/announcer/announcement/announce.ogg', type = "Syndicate Captain", has_important_message = TRUE)
	else
		var/displayed_name = user.name
		var/mob/living/carbon/human/human_user = user
		if(istype(human_user))
			displayed_name = human_user.get_id_name(if_no_id = displayed_name)
		priority_announce(text = announcement_text, title = null, sound = 'sound/announcer/announcement/announce.ogg', type = null, sender_override = "[displayed_name] Announces", has_important_message = TRUE)
	log_traitor("[key_name(user)] sent a priority message via uplink containing the message: [announcement_text]")
	message_admins("[key_name(user)] sent a priority message via uplink.")
	return source //For log icon

#undef TRAITOR_ANNOUNCE_MAX_LEN
