/obj/item/clothing/under/syndicateoveralls
	name = "tactical overalls"
	desc = "A non-descript and slightly suspicious pair of tactical overalls, it comes in an aesthetically pleasing bloodred."
	icon_state = "syndicate_overalls"
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/clothing_under/syndicate
	alt_covers_chest = TRUE
	icon = 'orbstation/icons/obj/items/clothing/orb_syndicate.dmi'
	worn_icon = 'orbstation/icons/obj/items/clothing/orb_syndicate_worn.dmi'

/obj/item/clothing/under/syndicateoverskirt
	name = "tactical overallskirt"
	desc = "A non-descript and slightly suspicious pair of tactical overalls, it comes in an aesthetically pleasing bloodred."
	icon_state = "syndicate_overallskirt"
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/clothing_under/syndicate
	alt_covers_chest = TRUE
	icon = 'orbstation/icons/obj/items/clothing/orb_syndicate.dmi'
	worn_icon = 'orbstation/icons/obj/items/clothing/orb_syndicate_worn.dmi'

/obj/item/clothing/under/syndicatemaid
	name = "Syndicate Maid Uniform"
	desc = "A maid uniform designed for syndicate cleaners, the tag boasts that bloodstains will always come out."
	icon_state = "syndimaid"
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/clothing_under/syndicate
	alt_covers_chest = TRUE
	icon = 'orbstation/icons/obj/items/clothing/orb_syndicate.dmi'
	worn_icon = 'orbstation/icons/obj/items/clothing/orb_syndicate_worn.dmi'

/obj/item/clothing/accessory/syndiecorset
	name = "syndicate corset"
	desc = "An insidious red corset, it really makes your features pop."
	icon_state = "syndimaid_corset"
	icon = 'orbstation/icons/obj/items/clothing/syndicate_corset.dmi'
	worn_icon = 'orbstation/icons/obj/items/clothing/syndicate_corset.dmi'
	minimize_when_attached = FALSE
	attachment_slot = null

/obj/item/clothing/gloves/syndiemaid
	name = "syndicate maid arm covers"
	desc = "Sinister cylindrical looking tubes that go over your arm, adorable in an evil way."
	icon_state = "syndimaid_arms"
	icon = 'orbstation/icons/obj/items/clothing/gloves.dmi'
	worn_icon = 'orbstation/icons/obj/items/clothing/hands.dmi'
	inhand_icon_state = null
	greyscale_colors = null

/obj/item/clothing/suit/toggle/labcoat/syndielabcoat
	name = "syndicate labcoat"
	desc = "A well tailored labcoat. The menacing black and red really reinforces your lack of ethics."
	icon_state = "labcoat_syndie"
	icon = 'orbstation/icons/obj/items/clothing/orb_labcoat.dmi'
	worn_icon = 'orbstation/icons/obj/items/clothing/orb_labcoat_worn.dmi'
	inhand_icon_state = null
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	armor_type = /datum/armor/toggle_labcoat

//The Cargo Order for said items above

/datum/supply_pack/imports/evilfashion
	name = "Serpent's Kiss Fashion Crate"
	desc = "A box of the latest in imported fashion, featuring items from Cybersun and Interdyne's joint Serpent's Kiss fashion line."
	order_flags = ORDER_CONTRABAND
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/obj/item/clothing/suit/toggle/labcoat/syndielabcoat,
		/obj/item/clothing/gloves/syndiemaid,
		/obj/item/clothing/accessory/syndiecorset,
		/obj/item/clothing/under/syndicatemaid,
		/obj/item/clothing/under/syndicateoverskirt,
		/obj/item/clothing/under/syndicateoveralls,
	)
	crate_name = "Serpent's Kiss Fashion crate"
