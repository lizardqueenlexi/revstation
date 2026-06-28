/datum/mood_event/chew_toy
	description = "I have my mouse safely in my mouth."
	mood_change = 2
	timeout = 0

// Make the toy mouse wearable
/obj/item/toy/cattoy
	worn_icon = 'orbstation/icons/obj/items/clothing/masks_worn.dmi'
	worn_icon_state = "toy_mouse"
	desc = "A colorful toy mouse! Cats and felinids love them! Maybe they're on to something."
	slot_flags = ITEM_SLOT_MASK

//felinids like to hold the mouse
/obj/item/toy/cattoy/equipped(mob/living/wearing, slot)
	. = ..()
	if (!(slot & ITEM_SLOT_MASK))
		return
	wearing.add_mood_event("chew toy", /datum/mood_event/chew_toy)
		//felinid moodlet

/obj/item/toy/cattoy/dropped(mob/living/wearing)
	. = ..()
	wearing.clear_mood_event("chew toy")
	//felinid unmoodlet
