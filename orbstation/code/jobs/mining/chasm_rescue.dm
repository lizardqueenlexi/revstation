/datum/component/chasm/proc/try_climb_out(mob/living/fallen_mob)
	if (fallen_mob.stat == DEAD)
		return
	to_chat(fallen_mob, span_warning("You begin trying to climb out of the chasm!"))
	if (!do_after(fallen_mob, 10 SECONDS, get_turf(fallen_mob),
		IGNORE_HELD_ITEM | IGNORE_INCAPACITATED | IGNORE_SLOWDOWNS, extra_checks = CALLBACK(src, PROC_REF(is_alive), fallen_mob)))
		try_climb_out(fallen_mob) // If you're not dead you're not giving in
		return

	storage.on_revive(fallen_mob) // This seems silly but it does what we want it to do

/datum/component/chasm/proc/is_alive(mob/living/fallen_mob)
	return fallen_mob.stat != DEAD
