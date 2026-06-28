// values concerning stamina loss
/// Minimum stamina damage per stamina loss burst
#define STAM_DAMAGE_MIN 1
/// Maximum stamina damage per stamina loss burst
#define STAM_DAMAGE_MAX 5
/// What percentage of ticks you'll lose stamina
#define STAM_DAMAGE_RATE 15

// values concerning the occasional burst of damage
/// How much more damage a damage burst frame does than a normal one. This effectively goes up by one every damage burst
#define DAMAGE_BURST_MUL 7
/// Percentage of ticks you'll take a damage burst on. This does not change over time
#define DAMAGE_BURST_RATE 5
/// How long you'll spend jittery after taking a bad damage burst
#define JITTER_TIME 10 SECONDS
// note that unlike tox damage, stamina damage, etc, organ damage is NOT multiplied by DAMAGE_BURST_MUL or increased by num_damage_bursts
/// Minimum organ damage taken upon a damage burst
#define ORGAN_DAMAGE_MIN 3
/// Maximum organ damage taken upon a damage burst
#define ORGAN_DAMAGE_MAX 10

/// Initial chance of a damage burst being "bad" (dealing extra damage, causing jitters, and displaying a scarier warning message)
#define BAD_BURST_CHANCE_MIN 10
/// Health value below which having lower health starts to increase the chance of having a bad damage burst
#define BAD_BURST_HEALTH_RAMP_THRESHOLD 50
/// Percentage above which having low health no longer increases the probability of a bad damage burst
#define BAD_BURST_CHANCE_SOFTCAP 60
/// Chance to scream on a bad damage burst
#define SCREAM_PROB 50

/datum/reagent/toxin/xenotoxin
	name = "Xenotoxin"
	description = "A powerful venom injected by immature xenomorphs when they fail infect a host. \
					Lingers in the system for a long time, causing the victim to continuously weaken."
	color = "#1a011c" // not sure the best color, so i went with xeno-ish purple/black
	toxpwr = 0.25 // deals low damage but spends a long, long time in your system
	ph = 1
	taste_description = "acrid bile"
	penetrates_skin = TOUCH
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

	/// number of times a damage burst has been triggered
	/// the more bursts you suffer, the more damage each one does and the higher the chance that you'll get "bad bursts" that deal extra damage
	var/num_damage_bursts = 0

/datum/reagent/toxin/xenotoxin/on_mob_life(mob/living/carbon/victim, seconds_per_tick, times_fired)
	..()

	// apply a fluctuating amount of stamina damage in little chunks over time
	if (SPT_PROB(STAM_DAMAGE_RATE, seconds_per_tick))
		victim.adjust_stamina_loss(rand(STAM_DAMAGE_MIN, STAM_DAMAGE_MAX) * REM * seconds_per_tick, 0)

	// check to see if we should apply a damage burst
	// these deal sudden, larger amounts of toxin and stamina damage, and display a warning message
	if (!SPT_PROB(DAMAGE_BURST_RATE, seconds_per_tick))
		return // early return if we fail the check
	// we didnt fail, so run the code

	/// base chance of a bad burst, which increases as victim's health decreases
	var/bad_burst_base_chance = BAD_BURST_HEALTH_RAMP_THRESHOLD - victim.health

	/// actual chance, which is clamped to a min/max and increases with the number of previous bursts
	/// note that health decreasing below a certain point will no longer increase the chance, but further bursts will
	/// always make bad ones more likely
	var/bad_burst_chance = clamp(bad_burst_base_chance, BAD_BURST_CHANCE_MIN, BAD_BURST_CHANCE_SOFTCAP) + num_damage_bursts

	if (prob(bad_burst_chance))
		to_chat(victim, span_danger("Your heartrate spikes, and it feels like acid is running through your veins!"))
		damage_burst_bad(victim, DAMAGE_BURST_MUL + num_damage_bursts, seconds_per_tick)
	else
		to_chat(victim, span_danger("Your blood hurts!"))
		damage_burst_normal(victim, DAMAGE_BURST_MUL + num_damage_bursts, seconds_per_tick)

	num_damage_bursts++

/// Apply a "damage burst", which deals increasing amounts of toxicity and stamina damage, causes breath loss, and deals a small amount of organ damage
/datum/reagent/toxin/xenotoxin/proc/damage_burst_normal(mob/living/carbon/victim, damage_mul, seconds_per_tick)

	victim.adjust_tox_loss(damage_mul * toxpwr * REM * seconds_per_tick, 0)
	victim.adjust_stamina_loss(damage_mul * rand(STAM_DAMAGE_MIN, STAM_DAMAGE_MAX) * REM * seconds_per_tick, 0)  // REM is reagent-effects-multiplier

	victim.losebreath++

	// damage a random organ, weighted heavily towards the liver
	var/obj/item/organ/organ = pick(victim.organs) // choose a random organ
	organ = pick(organ, victim.get_organ_slot(ORGAN_SLOT_LIVER)) // choose randomly between that organ and the liver
	organ.apply_organ_damage(rand(ORGAN_DAMAGE_MIN,ORGAN_DAMAGE_MAX)) // deal a small amount of random (non-increasing) damage to that organ

/// Apply a particularly bad damage burst, which does more damage than a normal one, applies jitteryness, and can cause the victim to scream
/datum/reagent/toxin/xenotoxin/proc/damage_burst_bad(mob/living/carbon/victim, damage_mul, seconds_per_tick)

	victim.set_timed_status_effect((JITTER_TIME + num_damage_bursts) * REM * seconds_per_tick, /datum/status_effect/dizziness, only_if_higher = TRUE)
	victim.set_timed_status_effect((JITTER_TIME + num_damage_bursts) * REM * seconds_per_tick, /datum/status_effect/jitter, only_if_higher = TRUE)

	if(prob(SCREAM_PROB))
		victim.emote("scream") // ow, my blood!

	// do the normal amount of damage
	damage_burst_normal(victim, damage_mul, seconds_per_tick)
	// do a little extra damage, for funsies
	damage_burst_normal(victim, damage_mul/2, seconds_per_tick)

#undef STAM_DAMAGE_MIN
#undef STAM_DAMAGE_MAX
#undef STAM_DAMAGE_RATE
#undef DAMAGE_BURST_MUL
#undef DAMAGE_BURST_RATE
#undef JITTER_TIME
#undef ORGAN_DAMAGE_MIN
#undef ORGAN_DAMAGE_MAX
#undef BAD_BURST_CHANCE_MIN
#undef BAD_BURST_HEALTH_RAMP_THRESHOLD
#undef BAD_BURST_CHANCE_SOFTCAP
#undef SCREAM_PROB
