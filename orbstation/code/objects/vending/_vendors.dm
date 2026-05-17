// Allows inserting extra items into vending machines without editing upstream code.
// Please do not place any products in here! Those should go in other files in this folder instead.

/obj/machinery/vending
	/// Extra items to add to the products list
	var/list/orb_products = list()
	/// Extra items to add to the premium list
	var/list/orb_premium = list()
	///Extra items to add to the contraband list
	var/list/orb_contraband = list()
	/// Extra items to add to categorised lists
	var/list/orb_product_categories = list()

/obj/machinery/vending/Initialize(mapload)
	products |= orb_products
	premium |= orb_premium
	contraband |= orb_contraband
	for (var/list/orb_category in orb_product_categories)
		for (var/list/category in product_categories)
			if (orb_category["name"] != category["name"])
				continue
			category["products"] |= orb_category["products"]
			break
	return ..()
