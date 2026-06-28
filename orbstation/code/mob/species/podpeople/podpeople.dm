/datum/species/pod/get_scream_sound(mob/living/carbon/human/pod)
	return pick(
		'orbstation/sound/voice/pod/podscream1.ogg',
		'orbstation/sound/voice/pod/podscream2.ogg',
		'orbstation/sound/voice/pod/podscream3.ogg',
	)


/datum/species/pod/get_species_description()
	return "A species of sentient plants, podpeople were created by a benevolent ancient society with the aim of 'spreading and nurturing life', their seed vaults \
		being tossed to all the far corners of the system. Being dispersed across the galaxy has caused their culture to fracture somewhat, and the exact \
		meaning of their creators intent is subject to frequent debate - not including those who simply don't care to listen."

/datum/species/pod/get_species_lore()
	return list(
		"Thousands of years ago, a precursor-society dispersed seed vaults throughout the galaxy. Within, the podpeople grew, and were given a single directive - \
		to protect the seed vaults they would grow into and nurture the life held within. ....However, the brevity of such a multi-faceted task would throw a \
		wrench into the inscrutable plans of the ancients.",

		"Even with the wide dispersal of the seed vaults, podpeople have formed a culture, most certainly drawing from the internal, subconscious memories of a \
		now long-dead society. They hold life in high regard, and see it their sacred duty to return life to inhospitable environs. These are considered the \
		more 'traditionalist' beliefs, alongside a somewhat-antiquated manner of speaking and dressing.",

		"Two other primary 'factions' exist within circles of podpeople, the 'reclusives' (mockingly referred to as 'wallflowers'); who believe that their \
		priorities should remain firmly within their seed vaults, keeping what vestiges of the ancient's society remain preserved in safety. They tend to be \
		slightly more up-to-date than their traditionalist counterparts, and a little grumpier when interacting with 'new' species. ",

		"The third and most disparate 'group' would be the 'sprouts', which encompasses those who find their original purpose stifling, and seek lives outside of \
		their seed vaults. Many podpeople would not declare themselves affiliated with any of these 'groups', but they define the forces shaping the course of \
		the podpeople's future.",

		"Most find a way out of their seed vaults when some haphazard miner wanders into their vault, but as time goes on, the idea of free communication and \
		sharing of techonlogy with other species spreads further. Many podpeople now leave their vaults in groups, once again dispersed amid the galaxy. Some \
		find fulfilling lives on the frontier, as farmers, shiphands and pirates. Some, even, end up working for Nanotrasen, loathe as they are to refuse \
		willing warm bodies.",
	)

/datum/species/pod/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Light Nutrition",
			SPECIES_PERK_DESC = "Podpeople passively gain nutrition while standing in well-lit areas.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Water Blood",
			SPECIES_PERK_DESC = "Podpeople blood is water.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "leaf",
			SPECIES_PERK_NAME = "Plant Weaknesses",
			SPECIES_PERK_DESC = "Podpeople are harmed by weedkiller, and mutate rapidly when shot with a floral somatoray on mutate mode. \
			Podpeople are also delicious to goats.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Light Starvation",
			SPECIES_PERK_DESC = "Podpeople lose nutrition while standing in darkness, and take constant damage while starving.",
		),
	)

	return to_add

//podperson sprouts - the same as regular podpeople in every way, except they also heal rapidly while standing in bright light.
//These only come from reviving someone via replica pod, or being spawned via the seed vault ghost role.
/datum/species/pod/sprout
	id = SPECIES_PODPERSON_SPROUT
	examine_limb_id = SPECIES_PODPERSON

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/pod/sprout,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/pod/sprout,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/pod/sprout,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/pod/sprout,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/pod/sprout,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/pod/sprout,
	)

/obj/item/bodypart/arm/left/pod/sprout
	bodypart_effects = null

/obj/item/bodypart/arm/right/pod/sprout
	bodypart_effects = null

/obj/item/bodypart/head/pod/sprout
	bodypart_effects = null

/obj/item/bodypart/leg/left/pod/sprout
	bodypart_effects = null

/obj/item/bodypart/leg/right/pod/sprout
	bodypart_effects = null

/obj/item/bodypart/chest/pod/sprout
	bodypart_effects = null
