/obj/item/slimepotion/genderchange
	desc = "An interesting chemical mix that changes the gender of what it's applied to. Can only be used on yourself."

/obj/item/slimepotion/genderchange/attack(mob/living/L, mob/user)
	if(L != user)
		to_chat(user, span_warning("You can't use this on someone else!"))
		return

	..()

/obj/item/book/bible
	name = "holy book"
	icon_state = "holybook"
	inhand_icon_state = "holybook"

// Removed reference to tiziran genocide.
/obj/item/weaponcrafting/gunkit/temperature
	desc = "A suitcase containing the necessary gun parts to tranform a standard energy gun into a temperature gun. Fantastic at birthday parties and for mowing down snowmen."

// Replaced touhou joke which wasn't very funny
/obj/item/clothing/head/costume/rabbitears
	desc = "bnuuy"

// Let's not call it that
/obj/item/book/granter/action/spell/blind/wgw/Initialize(mapload)
	. = ..()
	var/static/list/things_you_dont_want_to_read = list(
		"Nudes of the Mansus",
		"Wizards Gone Wild", // Didn't mean it at the time but this is retroactively what the initial in the typepath stands for
		"20th Century Internet Archives: Reddit",
		"Book Which Makes You Go Blind",)
	name = pick(things_you_dont_want_to_read)

// This didn't even fucking work as implemented smh
/obj/item/book/granter/action/spell/blind/wgw/recoil(mob/living/user)
	to_chat(user, span_notice("[length(remarks) ? pick(remarks) : "You keep reading..."]"))
	return ..()

/obj/item/tailclub
	desc = "Also known as the Thagomiser."

/obj/item/melee/chainofcommand/tailwhip
	name = "scaled tail whip"
	desc = "Simulates for the victim the experience of standing next to an excited Tiziran, but with none of the enjoyment."

/obj/item/melee/chainofcommand/tailwhip/kitty
	name = "cat tail whip"
	desc = "Simulates for the victim the experience of standing next to an excited Felinid, but with none of the enjoyment."

/obj/item/clothing/head/costume/lizard
	name = "reptilian cloche"
	desc = "A rather tasteless hat made out of synthesised scales."

/obj/item/clothing/shoes/cowboy/lizard
	name = "\improper Tiziran cowboy boots"
	desc = "These comfortable leather boots are popular on the dusty inland prairies of Tizira. Despite the name, there's no cows on Tizira."
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/shoes/cowboy/lizard/masterwork
	name = "fine Tiziran cowboy boots"
	desc = "While extremely comfortable, these boots were most popular in Zagoskeld at the empire's height, and were far too expensive for the working class. They're a nice color, though!"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/effect/spawner/random/clothing/lizardboots
	desc = "Finally, lizard shoes..." //I don't think this description can ever appear anyway, but just to be sure...


/obj/item/soap/omega/grind_results()
	return list(
		/datum/reagent/consumable/potato_juice = 9,
		/datum/reagent/consumable/ethanol/slimewine = 9,
		/datum/reagent/monkey_powder = 9,
		/datum/reagent/drug/krokodil = 9,
		/datum/reagent/toxin/acid/nitracid = 9,
		/datum/reagent/baldium = 9,
		/datum/reagent/consumable/ethanol/hooch = 9,
		/datum/reagent/bluespace = 9,
		/datum/reagent/drug/pumpup = 9,
		/datum/reagent/consumable/space_cola = 9
	)

//The lizard tail description referenced "lizard haters", but no one here hates lizards.
/obj/item/organ/tail/lizard
	desc = "A severed lizard tail. Did you know that lizards of many species are capable of dropping their tails through a process called autotomy? That isn't what happened here."

//Removed a reference to lizard wine, which doesn't really exist anymore.
/obj/item/organ/tail/lizard/fake
	desc = "A fabricated severed lizard tail. This one's made of synthflesh. Someone out there might whine about the distinction."

//These two used the fashy meme you'd expect.
/obj/item/clothing/head/helmet/chaplain
	desc = "Don't you think this is a bit embarrassing?"

/obj/item/clothing/suit/chaplainsuit/armor/templar
	desc = "You have chosen... poorly."

//The original description for this one was just gross.
/obj/structure/sign/poster/official/no_erp
	desc = "This poster reminds the crew that Eroticism, Raunchiness and Pornography are banned on Nanotrasen stations."

//Delete these poster if it ever appears and replace it with a random one.
/obj/structure/sign/poster/contraband/got_wood/Initialize(mapload, vol)
	. = ..()
	new /obj/structure/sign/poster/contraband/random(loc)
	return INITIALIZE_HINT_QDEL

/obj/structure/sign/poster/contraband/free_tonto/Initialize(mapload, vol)
	. = ..()
	new /obj/structure/sign/poster/contraband/random(loc)
	return INITIALIZE_HINT_QDEL

//Never spawn these posters randomly either
/obj/structure/sign/poster/random
	blacklisted_types = list(
		/obj/structure/sign/poster/traitor,
		/obj/structure/sign/poster/abductor,
		/obj/structure/sign/poster/contraband/got_wood,
		/obj/structure/sign/poster/contraband/free_tonto,
	)

/obj/structure/sign/poster/contraband/random
	blacklisted_types = list(
		/obj/structure/sign/poster/contraband/got_wood,
		/obj/structure/sign/poster/contraband/free_tonto,
	)

//Removed the word "ghetto" from item descriptions
/obj/item/flashlight/lamp/bananalamp
	desc = "Only a clown would think to make a silly banana-shaped lamp. Even has a goofy pullstring."

/obj/item/reagent_containers/hypospray/medipen/pumpup
	desc = "An improvised autoinjector filled with a cheap adrenaline shot... Great for shrugging off the effects of stunbatons."

//Removes the banana glutton from the spawnlist for now
/obj/item/grenade/spawnergrenade/clown
	spawner_type = list(/mob/living/basic/clown/fleshclown, /mob/living/basic/clown/clownhulk, /mob/living/basic/clown/longface, /mob/living/basic/clown/clownhulk/chlown, /mob/living/basic/clown/clownhulk/honkmunculus, /mob/living/basic/clown/banana, /mob/living/basic/clown/honkling, /mob/living/basic/clown/lube)

/obj/structure/spawner/clown
	mob_types = list(/mob/living/basic/clown, /mob/living/basic/clown/fleshclown, /mob/living/basic/clown/clownhulk, /mob/living/basic/clown/longface, /mob/living/basic/clown/clownhulk/chlown, /mob/living/basic/clown/clownhulk/honkmunculus, /mob/living/basic/clown/banana, /mob/living/basic/clown/honkling, /mob/living/basic/clown/lube)

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims
	name = "\improper Shady Rick's Hunger Sticks packet"
	desc = "Need a lunch break now? Eat too much and can't sample the chef's latest creation? Preparing for a hot dog eating contest? Smoke Shady Rick's Hunger Sticks and get hungry in minutes! Guaranteed results!"

/obj/item/cigarette/shadyjims
	desc = "A Shady Rick's Hunger Sticks cigarette."

// It's already a reference item. Why are they lizardskin and not snakeskin?
/obj/item/clothing/shoes/discoshoes
	name = "green snakeskin shoes"
	desc = "They may have lost some of their lustre over the years, but these green snakeskin shoes fit you perfectly."

//wow pepe the frog jokes blow
/obj/item/clothing/mask/animal/frog
	desc = "An ancient mask carved in the shape of a frog."
	animal_sounds = list("Ribbit!!", "Croak!!","R-ribbit!!","Kero-Kero!!")
	animal_sounds_alt = list("Hello my baby, hello my honey, hello my rag-time gal.")
