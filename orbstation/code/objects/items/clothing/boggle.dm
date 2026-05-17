/obj/item/clothing/glasses/boggle
	name = "boggle goggles"
	desc = "Now you can put eyes on your eyes for more eye per eye."
	icon = 'orbstation/icons/obj/items/clothing/glasses.dmi'
	worn_icon = 'orbstation/icons/obj/items/clothing/glasses_worn.dmi'
	icon_state = "boggle"
	worn_icon_state = "eyeglasses"
	gender = PLURAL
	clothing_traits = list(TRAIT_NEARSIGHTED_CORRECTED)
	custom_materials = null

/datum/crafting_recipe/boggle
	name = "Boggle Goggles"
	result = /obj/item/clothing/glasses/boggle
	time = 2 SECONDS
	reqs = list(/obj/item/organ/eyes = 1, /obj/item/stack/sheet/cloth = 1)
	category = CAT_CLOTHING
	crafting_flags = parent_type::crafting_flags | CRAFT_SKIP_MATERIALS_PARITY

/datum/crafting_recipe/bogglealt
	name = "Boggle Goggles"
	result = /obj/item/clothing/glasses/boggle
	time = 2 SECONDS
	reqs = list(/obj/item/organ/eyes = 1, /obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING
	crafting_flags = parent_type::crafting_flags | CRAFT_SKIP_MATERIALS_PARITY
