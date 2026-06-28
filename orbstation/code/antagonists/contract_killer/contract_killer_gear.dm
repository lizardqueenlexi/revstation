/// Sets of gear summonable by the Contract Killer to aid in their kill.

/// Action that allows summoning a gear kit
/datum/action/get_killer_gear
	name = "Summon Equipment"
	desc = "Offers you a choice of three gear kits in order to carry out your assassination. The kit will show up in your hand, \
		so make sure you summon it when no one is looking."
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_HANDS_BLOCKED
	button_icon = 'icons/obj/storage/case.dmi'
	button_icon_state = "secure"

	var/list/items = list() //list of kits to offer, set when the action is granted
	var/list/kit_types = list() //associative list of kit names to kit datums

/// Set up which three kits the contract killer will be offered
/datum/action/get_killer_gear/New()
	..()

	var/list/potential_kits = list() //list of all possible kits and their weights
	var/list/equip_options = list() //list of kits that have actually been chosen

	for(var/datum/contract_killer_kit/kit as anything in subtypesof(/datum/contract_killer_kit))
		potential_kits[kit] = initial(kit.weight)

	for(var/i in 1 to 3)
		var/new_kit = pick_weight(potential_kits)
		potential_kits -= new_kit
		equip_options += new_kit

	for(var/datum/contract_killer_kit/kit as anything in equip_options)
		kit_types[initial(kit.name)] = new kit

	for(var/kit_name in kit_types)
		var/datum/contract_killer_kit/current_kit = kit_types[kit_name]
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = current_kit.icon, icon_state = current_kit.icon_state)
		option.info = span_boldnotice(current_kit.description)
		items[kit_name] = option

/datum/action/get_killer_gear/Trigger(trigger_flags)
	. = ..()

	var/selection = show_radial_menu(owner, owner, items, radius = 38, tooltips = TRUE)
	if(!selection)
		return

	var/datum/contract_killer_kit/chosen_set = kit_types[selection]
	owner.put_in_hands(new chosen_set.kit_path)
	qdel(src)

/// Datum for contract killer kits, for selection
/datum/contract_killer_kit
	/// Name of the kit
	var/name = "Contract Killer Kit"
	/// Description of the kit
	var/description = "This kit should never be offered to you."
	/// Icon of the kit
	var/icon
	/// Icon state of the kit
	var/icon_state
	/// Path to the kit item
	var/kit_path = /obj/item/storage/briefcase/secure/contract_killer
	/// Weight of the kit
	var/weight = CONTRACT_KILLER_KIT_COMMON

/// Special briefcase for contract killer gear. Disguised as a regular secure briefcase.
/obj/item/storage/briefcase/secure/contract_killer
	throwforce = 25 //it's secretly a formidible throwing weapon
	throw_speed = 1 //but also kind of a joke
	throw_range = 7

// COMMON KITS

/// A silenced Makarov with extra ammo, and some joke items
/datum/contract_killer_kit/hitman
	name = "Hitman Kit"
	description = "Kill your target with simple, yet stylish efficiency. Contains a suppressed Makarov, a spare ammo magazine, \
		and a few bonuses to help you really look the part."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "pistol"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/hitman

/obj/item/storage/briefcase/secure/contract_killer/hitman/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/suppressed(src)
	new /obj/item/ammo_box/magazine/m9mm(src)
	new /obj/item/clothing/under/suit/black(src)
	new /obj/item/clothing/suit/toggle/lawyer/black(src)
	new /obj/item/clothing/neck/tie/red(src)
	for(var/i in 1 to 3)
		new /obj/item/coin/silver(src)

/// A randomized selection of 10 knives of various usefulness
/datum/contract_killer_kit/knives
	name = "A Random Assortment of Knives and Other Sharp Objects"
	description = "Like stabbing things? Want your target to look like a pincushion? This kit contains 15 knives, tossed together \
		more or less at random. Guaranteed to always contain a couple of really nice ones."
	icon = 'icons/obj/weapons/stabby.dmi'
	icon_state = "buckknife"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/knives

/obj/item/storage/briefcase/secure/contract_killer/knives/PopulateContents()
	var/list/rare_knives = list(
		/obj/item/knife/combat,
		/obj/item/knife/bloodletter,
		/obj/item/pen/edagger,
		/obj/item/knife/rainbowknife,
	)
	var/list/uncommon_knives = list(
		/obj/item/knife/combat/survival,
		/obj/item/knife/butcher,
		/obj/item/knife/letter_opener,
		/obj/item/knife/combat/bone,
		/obj/item/knife/shiv/plastitanium,
		/obj/item/scalpel/advanced,
		/obj/item/clothing/glasses/sunglasses/gar,
		/obj/item/surgicaldrill,
	)
	var/list/common_knives = list(
		/obj/item/knife/hunting,
		/obj/item/boxcutter,
		/obj/item/knife/kitchen,
		/obj/item/knife/carp,
		/obj/item/scalpel,
		/obj/item/knife/shiv/carrot,
		/obj/item/knife/shiv,
		/obj/item/knife/shiv/titanium,
		/obj/item/knife/shiv/plasma,
	)

	for(var/i in 1 to 2) //2 really good knives
		var/new_knife = pick(rare_knives)
		new new_knife(src)

	for(var/i in 1 to 3) //3 decent knives
		var/new_knife = pick(uncommon_knives)
		new new_knife(src)

	for(var/i in 1 to 10) //10 other knives
		var/new_knife = pick(common_knives)
		new new_knife(src)

/// Chameleon gear, with the noslip chameleon shoes and an agent ID as a bonus
/datum/contract_killer_kit/spy
	name = "Disguise Kit"
	description = "Worried about getting away with your crime? Disguise your outfit however you please - they'll never know who hit them! \
		Contains a full chameleon kit, with an extra set of no-slip chameleon shoes and a customizable agent ID."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "balaclava"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/spy

/obj/item/storage/briefcase/secure/contract_killer/spy/PopulateContents()
	new /obj/item/storage/box/syndie_kit/chameleon(src)
	new /obj/item/clothing/shoes/chameleon/noslip(src)
	new /obj/item/card/id/advanced/chameleon(src)

/// A dart gun, two random poisons, antitoxin (for slimes), and a box of piercing syringes
/datum/contract_killer_kit/poison
	name = "Poisoner's Kit"
	description = "What murder could be more classic than poisoning? Contains two bottles of random poisons, a box of armor-piercing \
		syringes, a compact syringe gun, and a bottle of pentetic acid (in case you screw up, or if your target is a jellyperson)."
	icon = 'icons/obj/weapons/guns/syringegun.dmi'
	icon_state = "dartsyringegun"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/poison

/obj/item/storage/briefcase/secure/contract_killer/poison/PopulateContents()
	var/list/poisons_list = list(
		/obj/item/reagent_containers/cup/bottle/polonium,
		/obj/item/reagent_containers/cup/bottle/venom,
		/obj/item/reagent_containers/cup/bottle/fentanyl,
		/obj/item/reagent_containers/cup/bottle/spewium,
		/obj/item/reagent_containers/cup/bottle/cyanide,
		/obj/item/reagent_containers/cup/bottle/initropidril,
		/obj/item/reagent_containers/cup/bottle/pancuronium,
		/obj/item/reagent_containers/cup/bottle/sodium_thiopental,
		/obj/item/reagent_containers/cup/bottle/coniine,
		/obj/item/reagent_containers/cup/bottle/curare,
		/obj/item/reagent_containers/cup/bottle/amanitin,
	)

	new /obj/item/gun/syringe/syndicate()
	for(var/i in 1 to 2)
		var/poison = pick_n_take(poisons_list)
		new poison(src)
	new /obj/item/reagent_containers/cup/bottle/pentetic_acid(src)
	new /obj/item/storage/box/syringes/piercing(src)
	new /obj/item/gun/syringe/syndicate(src)

/// Both types of emag, a camera bug, a syndie toolbox, and advanced insuls.
/datum/contract_killer_kit/hacker
	name = "Hacker's Toolkit"
	description = "Target in an inconvenient location? With this kit, you can get wherever you need to - and get eyes on the whole station. \
		Contains advanced insulated gloves, a camera bug, an emag, a doorjack, and a set of tools."
	icon = 'icons/obj/card.dmi'
	icon_state = "emag"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/hacker

/obj/item/storage/briefcase/secure/contract_killer/hacker/PopulateContents()
	new /obj/item/clothing/gloves/chief_engineer(src)
	new /obj/item/disk/computer/syndicate/camera_app(src)
	new /obj/item/card/emag(src)
	new /obj/item/card/emag/doorjack(src)
	new /obj/item/storage/toolbox/syndicate(src) //shouldn't really fit in a briefcase, but it does anyway

// UNCOMMON KITS

/// A power fist and some oxygen tanks. Contains a power drill just for convenience.
/datum/contract_killer_kit/powerfist
	name = "Power Fist Starter Kit"
	description = "Why be subtle when you can punch your target across the room? Contains a power fist, three oxygen tanks, and a power \
		drill for making adjustments."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "powerfist"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/powerfist
	weight = CONTRACT_KILLER_KIT_UNCOMMON

/obj/item/storage/briefcase/secure/contract_killer/powerfist/PopulateContents()
	new /obj/item/melee/powerfist(src)
	for(var/i in 1 to 3)
		new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/screwdriver/power(src)

/// A briefcase with bag of holding-sized internal storage.
/datum/contract_killer_kit/holding
	name = "Briefcase of Holding"
	description = "Do you prefer on-site procurement? Are you the ultimate pack rat? Never fear - this briefcase is much bigger on the \
		inside! Store whatever you need for your secret schemes inside. WARNING: Do not place within another bluespace storage device. \
		Personal injury and instant death may occur."
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "secure"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/holding
	weight = CONTRACT_KILLER_KIT_UNCOMMON

/obj/item/storage/briefcase/secure/contract_killer/holding/Initialize(mapload)
	. = ..()

	create_storage(max_specific_storage = WEIGHT_CLASS_GIGANTIC, max_total_storage = 35, max_slots = 30, storage_type = /datum/storage/bag_of_holding)
	atom_storage.allow_big_nesting = TRUE

/obj/item/storage/briefcase/secure/contract_killer/holding/PopulateContents()
	return //contains nothing

/// A chameleon projector, and a rush gland implanter to zoom away if you get caught
/datum/contract_killer_kit/prophunt
	name = "Prop Hunter's Kit"
	description = "Why disguise as a person at all? With this kit, you can disguise as any object you can scan. They'll never suspect that the \
		potted plant was an assassin. Contains a chameleon projector. Also contains a rush gland autosurgeon, for quick getaways."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "shield0"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/prophunt
	weight = CONTRACT_KILLER_KIT_UNCOMMON

/obj/item/storage/briefcase/secure/contract_killer/prophunt/PopulateContents()
	new /obj/item/chameleon(src)
	new /obj/item/autosurgeon/rush_gland(src)

/// A ratfolk stomach, a cheese injector implant, and several wheels of cheese
/datum/contract_killer_kit/cheeserush
	name = "Cheesy Assassin's Kit"
	description = "The real key to a clean assassination is speed. They'll never get away if you bring the CHEESE RUSH to bear. Contains a cheese injector \
		implant and three cheese wheels. Also contains a ratfolk stomach for non-ratfolk assassins to get their cheese on. Implant it quickly, it \
		may go bad in there."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "cheesewheel"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/cheeserush
	weight = CONTRACT_KILLER_KIT_UNCOMMON

/obj/item/storage/briefcase/secure/contract_killer/cheeserush/PopulateContents()
	new /obj/item/autosurgeon/rat_stomach(src)
	new /obj/item/implanter/cheese(src)
	for(var/i in 1 to 3)
		new /obj/item/food/cheese/wheel(src)

/// An assortment of Lavaland and Icemoon monster parts, to craft into whatever items you like.
/datum/contract_killer_kit/viscera
	name = "Briefcase Full of Loose Viscera"
	description = "Whether miners or ashwalkers, the real champions are those who don't let anything go to waste. This bag of monster parts will \
		let you build your OWN arsenal, one piece at a time. Contains a large assortment of monster pieces for crafting, and some meat for... snacks?"
	icon = 'icons/obj/mining.dmi'
	icon_state = "sinew"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/viscera
	weight = CONTRACT_KILLER_KIT_UNCOMMON

/obj/item/storage/briefcase/secure/contract_killer/viscera
	desc = "A large briefcase with a digital locking system. It's concerningly damp."

/obj/item/storage/briefcase/secure/contract_killer/viscera/PopulateContents()
	new /obj/item/stack/sheet/bone/twelve(src)
	new /obj/item/stack/sheet/bone/eight(src)
	new /obj/item/stack/sheet/sinew/six(src)
	if(prob(50))
		new /obj/item/stack/sheet/animalhide/goliath_hide/three(src)
	else
		new /obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide/three(src)
	new /obj/item/food/meat/slab/goliath(src)
	new /obj/item/food/meat/slab/bear(src)
	if(prob(25)) //25% of the time you can make ash drake armor
		new /obj/item/stack/sheet/animalhide/ashdrake/five(src)

/obj/item/stack/sheet/bone/eight
	amount = 8

/obj/item/stack/sheet/sinew/six
	amount = 6

/obj/item/stack/sheet/animalhide/ashdrake/five
	amount = 5

/obj/item/stack/sheet/sinew/six
	amount = 6

/obj/item/stack/sheet/animalhide/goliath_hide/three
	amount = 3

/obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide/three
	amount = 3

// RARE KITS

/// A rare kit that gives a random piece of abductor/Zetan gear.
/datum/contract_killer_kit/zetan
	name = "KILLING KIT FOR STRONG ASSASSINS"
	description = "HEY BUCKAROO! LISTEN WE DON'T USUALLY DO THIS BUT WE HAVE GOT A GREAT WEAPON JUST FOR YOU TO DO YOUR KILLING. \
		A POWERFUL ZETAN WEAPON FOR ONLY THE STRONGEST ASSASSINS. DON'T TELL ANYONE, OK?"
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "shrink_ray"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/zetan
	weight = CONTRACT_KILLER_KIT_RARE

/obj/item/storage/briefcase/secure/contract_killer/zetan/PopulateContents()
	var/choice = rand(3)
	switch(choice)
		if(1)
			new /obj/item/gun/energy/shrink_ray/unrestricted(src)
		if(2)
			new /obj/item/gun/zetan_revolver(src)
			new /obj/item/clothing/gloves/color/yellow(src)
		if(3)
			new /obj/item/gun/energy/alien/unrestricted(src)

/// A rare kit that gives two random wizard items.
/datum/contract_killer_kit/wizard
	name = "Smuggled Wizard Federation Goods"
	description = "A pack of premium goods smuggled right out of the Wizard Federation. You can't tell anyone where you got these. If a wizard realizes \
		what you have here, they'll turn you into a chicken, or maybe inside-out. Keep it quiet. Contains two random wizardly items and a nice hat."
	icon = 'icons/obj/clothing/head/wizard.dmi'
	icon_state = "wizard"
	kit_path = /obj/item/storage/briefcase/secure/contract_killer/wizard
	weight = CONTRACT_KILLER_KIT_RARE

/obj/item/storage/briefcase/secure/contract_killer/wizard/PopulateContents()
	var/list/wizard_items = list(
		/obj/item/gun/magic/staff/animate/unrestricted,
		/obj/item/gun/magic/staff/chaos/unrestricted,
		/obj/item/gun/magic/wand/door,
		/obj/item/gun/magic/wand/fireball,
		/obj/item/gun/magic/wand/animate,
		/obj/item/gun/magic/wand/booze,
		/obj/item/gun/magic/wand/hallucination,
		/obj/item/gun/magic/wand/levitate,
		/obj/item/gun/magic/wand/pax,
		/obj/item/gun/magic/wand/prank,
		/obj/item/gun/magic/wand/repulse,
		/obj/item/gun/magic/wand/swap,
		/obj/item/gun/magic/wand/wound,
		/obj/item/veilrender/vealrender,
		/obj/item/veilrender/honkrender,
		/obj/item/scrying,
		/obj/item/warp_whistle,
	)
	var/list/wizard_hats = list(
		/obj/item/clothing/head/wizard,
		/obj/item/clothing/head/wizard/red,
		/obj/item/clothing/head/wizard/yellow,
		/obj/item/clothing/head/wizard/black,
		/obj/item/clothing/head/wizard/fake,
		/obj/item/clothing/head/wizard/marisa,
		/obj/item/clothing/head/wizard/tape,
	)

	for(var/i in 1 to 2)
		var/wizard_item = pick_n_take(wizard_items)
		new wizard_item(src)
	var/wizard_hat = pick(wizard_hats)
	new wizard_hat(src)

// Unique items for kits

/// An autosurgeon containing a special pre-preserved rush gland
/obj/item/autosurgeon/rush_gland
	name = "autosurgeon"
	desc = "A single use autosurgeon that contains a preserved rush gland. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/monster_core/rush_gland/preserved

/// An autosurgeon containing a ratfolk stomach. This will decay, so hopefully they use it quickly.
/obj/item/autosurgeon/rat_stomach
	name = "autosurgeon"
	desc = "A single use autosurgeon that contains a fresh ratfolk stomach. A screwdriver can be used to remove it, but implants can't be placed back in. \
		Use it quickly, as it is not immune to decay."
	uses = 1
	starting_organ = /obj/item/organ/stomach/ratfolk

// Pre-preserved monster organs, to ensure they don't decay before use
/obj/item/organ/monster_core/rush_gland/preserved/Initialize(mapload)
	. = ..()
	preserve()

/obj/item/organ/monster_core/regenerative_core/legion/preserved/Initialize(mapload)
	. = ..()
	preserve()

/obj/item/organ/monster_core/brimdust_sac/preserved/Initialize(mapload)
	. = ..()
	preserve()

// Variants of abductor weapons that have standard firing pins in them.
/obj/item/gun/energy/alien/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/energy/shrink_ray/unrestricted
	pin = /obj/item/firing_pin

/// A bottle of pentetic acid.
/obj/item/reagent_containers/cup/bottle/pentetic_acid
	name = "pentetic acid bottle"
	desc = "A small bottle. Contains pentetic acid."
	list_reagents = list(/datum/reagent/medicine/pen_acid = 30)

/// A box containing six piercing syringes.
/obj/item/storage/box/syringes/piercing
	name = "box of piercing syringes"
	desc = "A box full of armor-piercing syringes."

/obj/item/storage/box/syringes/piercing/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/syringe/piercing(src)

// A staff of animation that anyone can use.
/obj/item/gun/magic/staff/animate/unrestricted
	allow_intruder_use = TRUE

