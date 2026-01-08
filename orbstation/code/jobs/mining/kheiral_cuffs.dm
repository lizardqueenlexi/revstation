
/obj/item/clothing/accessory/kheiral_cuffs/connect_kheiral_network(mob/living/user)
	..()
	RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(send_death_alert)) // Orbstation


/// Registered to the COMSIG_LIVING_DEATH signal. Sends out an alert over alert_channels when the wearer dies.
/obj/item/clothing/accessory/kheiral_cuffs/proc/send_death_alert(mob/living/wearer, gibbed)
	var/area/location = get_area(wearer)
	for(var/radio_channel as anything in alert_channels)
		radio.talk_into(src, "Mining alert! [wearer ? wearer : "Someone"] has [gibbed ? "had their body destroyed" : "died"] at [location ? location : "an unknown location"]!", radio_channel)
