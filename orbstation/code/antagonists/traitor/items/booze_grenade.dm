#define BOOZENADE_CAPACITY 50

/obj/item/grenade/boozenade
	name = "booze grenade"
	desc = "A hefty grenade casing with a nozzle for pouring in ethanol products. When activated, it will disperse said \
		products as a dense cloud of smoke, rapidly intoxicating anyone who breathes it in."
	icon = 'orbstation/icons/obj/weapons/weapons.dmi'
	icon_state = "boozenade"

/obj/item/grenade/boozenade/Initialize(mapload)
	. = ..()
	create_reagents(BOOZENADE_CAPACITY, TRANSPARENT)

//Special proc to only allow booze to be poured inside. Partly copied from smoke machine.
/obj/item/grenade/boozenade/attackby(obj/item/attacking_item, mob/user, params)
	if(!is_reagent_container(attacking_item) || !attacking_item.is_open_container())
		return
	var/obj/item/reagent_containers/container = attacking_item
	for(var/reagent in container.reagents.reagent_list)
		if(!istype(reagent, /datum/reagent/consumable/ethanol))
			to_chat(user, span_notice("You can only put booze in the booze grenade!"))
			return
	var/units = container.reagents.trans_to(src, container.amount_per_transfer_from_this, transferred_by = user)
	if(units)
		to_chat(user, span_notice("You transfer [units] units of the solution to [src]."))
		return

/obj/item/grenade/boozenade/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/smoke_amount = DIAMOND_AREA(1)
	do_smoke(4, src, src,  reagents)
	reagents.remove_all(smoke_amount / 24)

	qdel(src)

/obj/item/storage/box/syndie_kit/boozenades
	name = "booze grenade box"

/obj/item/storage/box/syndie_kit/boozenades/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/boozenade(src)

/datum/uplink_item/role_restricted/booze_grenades
	name = "Box of Booze Grenades"
	desc = "A box of five empty 'booze grenades'. These insidious devices, poorly disguised as drinking flasks, will disperse smoke \
		containing whatever drinks you pour into them. Finally, a way to MAKE your customers enjoy your drinks..."
	item = /obj/item/storage/box/syndie_kit/boozenades
	cost = 4
	restricted_roles = list(JOB_BARTENDER)
	surplus = 20
	progression_minimum = 30 MINUTES

#undef BOOZENADE_CAPACITY
