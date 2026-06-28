/**
 * Small books that give a mood bonus to the reader, slightly higher than normal books.
 *
 * They're not granters in the traditional sense (no knowledge or spells learned here, although they do give a moodlet)
 * but the stuff set up by the granter superclass is useful here -- progress bars, effect performed when you finish, no real content, etc.
 */
/obj/item/book/granter/magazine
	name = "\improper magazine"
	starting_title = "\improper magazine" // initial name of this magazine -- mostly used for reread prevention.
	icon = 'orbstation/icons/obj/items/magazine.dmi'
	icon_state ="magazine"
	worn_icon_state = "magazine"
	desc = "A glossy magazine, full of advertisements, gossip, pictures, and maybe a few articles crammed between all that."
	attack_verb_continuous = list("slaps", "whacks", "thwaps")
	attack_verb_simple = list("slap", "whack", "thwap")

	unique = TRUE

	uses = INFINITY // we dont care how many times the magazine is read, just whether this specific person has done so.
	pages_to_mastery = 1

	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'

	var/mood_boost = 2

	var/list/emote_pool = list() // random emotes (as strings) to trigger while reading.
	// see also the list "remarks" from the superclass (a list of phrases to show the reader)
	var/emote_chance = 100 // chance to emote every time you turn a page. note that this is in PERCENT, not 0-1.

/// Called when the user starts to read the magazine.
/obj/item/book/granter/magazine/on_reading_start(mob/living/user)
	user.visible_message(span_notice("[user] starts flipping through \the [name]."), span_notice("You start flipping through \the [name]."))
	return TRUE

/// Called when the user completes the magazine.
/obj/item/book/granter/magazine/on_reading_finished(mob/living/user)
	to_chat(user, span_notice("You finish reading \the [name]!"))

	// copied from book/on_read()
	LAZYINITLIST(user.mind?.book_titles_read)
	var/has_not_read_book = isnull(user.mind?.book_titles_read[starting_title])

	// any new magazines give bonus mood
	if(has_not_read_book)
		// TODO: if a user reads two magazines in short succession, they will only receive mood boost from one
		// but be locked out of both.
		// fix this.
		user.add_mood_event(starting_title, /datum/mood_event/magazine, src)
		user.mind?.book_titles_read[starting_title] = TRUE
		return TRUE

	return FALSE

/obj/item/book/granter/magazine/turn_page(mob/living/user)
	. = ..() // super plays page turn sound, checks if interruption occurs, and displays remarks to user
	if (. && length(emote_pool) && prob(emote_chance))
		user.emote(pick(emote_pool))

/// Display a message if they've already read it.
/obj/item/book/granter/magazine/recoil(mob/living/user)
	to_chat(user, span_warning("You think you've read enough of \the [name] for now."))

///////////////////////////////////////// Mood Boost /////////////////////////////////////////


/datum/mood_event/magazine
	description = "That magazine was really interesting."
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/magazine/add_effects(obj/item/book/granter/magazine/target_mag)
	description = "\The [target_mag.name] was really interesting."
	mood_change = target_mag.mood_boost

///////////////////////////////////////// Spawner ///////////////////////////////////////////////////

/obj/effect/spawner/random/entertainment/magazine
	name = "random magazine spawner"
	loot_type_path = /obj/item/book/granter/magazine

///////////////////////////////////////// Kinds of magazine /////////////////////////////////////////

/*
	To add more magazines:
	Define name, starting_title (same as name), description, and icon_state
	Add randomized emotes and remarks to `emote_pool` and `remarks`

	New magazine will automatically give a mood boost, automatically be added to spawners, etc.
*/


/obj/item/book/granter/magazine/mothboy
	name = "Mothboys Monthly"
	starting_title = "Mothboys Monthly"
	icon_state = "mothboys"
	desc = "A saucy rag full of exposed exoskeletons, fluffy tails, and bashful antennae."
	emote_pool = list("blush")

/obj/item/book/granter/magazine/gal_geo
	name = "Galactic Geographic"
	starting_title = "Galactic Geographic"
	icon_state = "gal_geo"
	desc = "An informative publication on the flora, fauna, and peoples of the galaxy. Features large and beautiful pictures by expert photographers."

/obj/item/book/granter/magazine/pop_sci
	name = "Popular R&D"
	starting_title = "Popular R&D"
	icon_state = "pop_sci"
	desc = "A magazine focused on recent discoveries in science and engineering, written for the layman. \
			Apparently flying cars are only 20 years away, \"for real this time\"."

/obj/item/book/granter/magazine/cooking
	name = "Nanny Trasen's Kitchen"
	starting_title = "Nanny Trasen's Kitchen"
	icon_state = "cooking"
	desc = "A magazine focused on the wonders of baking."
	var/possible_spawns = list(
			/obj/item/reagent_containers/condiment/sugar,
			/obj/item/reagent_containers/condiment/flour,
			/obj/item/reagent_containers/condiment/milk,
			/obj/item/food/cookie,
			/obj/item/food/cake/birthday,
			/obj/item/food/cake/chocolate,
			/obj/item/food/pie/cream,
		)

/obj/item/book/granter/magazine/cooking/on_reading_finished(mob/living/user)
	var/is_new_to_reader = ..()

	if (is_new_to_reader)
		var/reward_type = pick(possible_spawns)
		var/obj/item/reward_instance = new reward_type(get_turf(src))
		to_chat(user, span_notice("Huh? A [reward_instance.name] fell out! How did that get in there?"))

/obj/item/book/granter/magazine/comic
	name = "It Came From Outer Space! vol. 4053"
	starting_title = "It Came From Outer Space! vol. 4053"
	icon_state = "comic"
	desc = "A cheap comic book. The titular \"it\" is a lot less scary now that it describes you and all of your coworkers."
	remarks = list("Blam!", "POW!", "BOOM!!", "Whack!", "Glorf!")

/obj/item/book/granter/magazine/yuri
	name = "Between My Claws, Sweetly"
	starting_title = "Between My Claws, Sweetly"
	desc = "A heartbreakingly beautiful romantic manga about a Tiziran princess and her human female lover, set amidst the chaos of the collapsing Tiziran Empire."
	icon_state = "yuri"
	emote_pool = list("blush", "cry")

//Flavor item for the Biodome arrivals shuttle, but I think it's funny if it still appears elsewhere.
/obj/item/book/granter/magazine/biodome
	name = "Nanotrasen 'Biodome' Travel Brochure"
	starting_title = "Nanotrasen 'Biodome' Travel Brochure"
	desc = "A somewhat tacky brochure for Nanotrasen's new line of 'Biodome'-class stations."
	icon_state = "biochure"
	pages_to_mastery = 2 //so you can see a few remarks each time
	remarks = list(
		"Now with live, open-air entertainment (entertainment is still largely clown-based)...",
		"See the dome in style with our new 'BioTube' transit system...",
		"Get all the tools you could ever need from 'The Grotto'... but watch your step! (Nanotrasen is not liable for injuries related to use of The Grotto(tm).)",
		"Take a calming river ride across the scenic Biodome Lake! (Minimum speed 70 kph).",
		"Research in style in our state-of-the-art 'VapoRnDwave' facilities!",
		"See such exciting zoo exhibits as axolotls, endangered lagomorphs, or even the rare Amoungs!",
		"Note: due to construction expenses, transfers to 'Biodome'-class stations currently comes with a 20% pay cut...",
		"Too warm? Take a trip to the wintery medical bay, kept at a bracing 62 degrees Fahrenheit (17 C) at all times...",
		"All employee breakrooms equipped with cozy fireplaces (fuel supplies minimal to prevent smoke inhalation)...",
		"There is nothing behind the walls.",
		"The captain can always watch over you with our new, patented 'OverBridge' design! Give them a wave!",
		"Climbing across the rooftops is strictly prohibited...",
		"Maybe you COULD use a vacation...",
	)

// Allows them to be cargo ordered
/datum/supply_pack/goody/magazine
	name = "Magazine"
	desc = "Contains one magazine from the Nanotrasen Magazine Library. Don't forget to subscribe to Magazines Monthly!"
	cost = PAYCHECK_CREW * 2
	contains = list(/obj/effect/spawner/random/entertainment/magazine)
