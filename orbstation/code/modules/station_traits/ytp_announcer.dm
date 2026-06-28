#define STATION_TRAIT_YTP "station_trait_ytp"

/datum/centcom_announcer/ytp
	welcome_sounds = list('orbstation/sound/ai/ytp/welcome.ogg',
		'orbstation/sound/ai/ytp/welcome2.ogg',
		'orbstation/sound/ai/ytp/welcome3.ogg',)
	alert_sounds = list('orbstation/sound/ai/ytp/attention.ogg',
		'orbstation/sound/ai/ytp/attention2.ogg',
		'orbstation/sound/ai/ytp/attention3.ogg',
		'orbstation/sound/ai/ytp/attention4.ogg',
		'orbstation/sound/ai/ytp/attention5.ogg',
		'orbstation/sound/ai/ytp/attention.ogg',
		'orbstation/sound/ai/ytp/attention2.ogg',
		'orbstation/sound/ai/ytp/attention3.ogg',
		'orbstation/sound/ai/ytp/attention4.ogg',
		'orbstation/sound/ai/ytp/attention5.ogg', //duplicate entries to weight them slightly higher
		'orbstation/sound/ai/ytp/false_alerts/1.ogg',
		'orbstation/sound/ai/ytp/false_alerts/2.ogg',
		'orbstation/sound/ai/ytp/false_alerts/3.ogg',
		'orbstation/sound/ai/ytp/false_alerts/4.ogg',
		'orbstation/sound/ai/ytp/false_alerts/5.ogg')
	command_report_sounds = list('orbstation/sound/ai/ytp/commandreport.ogg',
		'orbstation/sound/ai/ytp/commandreport2.ogg',
		'orbstation/sound/ai/ytp/commandreport3.ogg')
	event_sounds = list(ANNOUNCER_AIMALF = 'orbstation/sound/ai/ytp/aimalf.ogg',
		ANNOUNCER_ALIENS = 'orbstation/sound/ai/ytp/aliens.ogg',
		ANNOUNCER_ANIMES = 'orbstation/sound/ai/ytp/animes.ogg',
		ANNOUNCER_GRANOMALIES = 'orbstation/sound/ai/ytp/granomalies.ogg',
		ANNOUNCER_INTERCEPT = 'orbstation/sound/ai/ytp/intercept.ogg',
		ANNOUNCER_IONSTORM = 'orbstation/sound/ai/ytp/ionstorm.ogg',
		ANNOUNCER_METEORS = 'orbstation/sound/ai/ytp/meteors.ogg',
		ANNOUNCER_OUTBREAK5 = 'orbstation/sound/ai/ytp/outbreak5.ogg',
		ANNOUNCER_OUTBREAK7 = 'orbstation/sound/ai/ytp/outbreak7.ogg',
		ANNOUNCER_POWEROFF = 'orbstation/sound/ai/ytp/poweroff.ogg',
		ANNOUNCER_POWERON = 'orbstation/sound/ai/ytp/poweron.ogg',
		ANNOUNCER_RADIATION = 'orbstation/sound/ai/ytp/radiation.ogg',
		ANNOUNCER_SHUTTLECALLED = 'orbstation/sound/ai/ytp/shuttlecalled.ogg',
		ANNOUNCER_SHUTTLEDOCK = 'orbstation/sound/ai/ytp/shuttledock.ogg',
		ANNOUNCER_SHUTTLERECALLED = 'orbstation/sound/ai/ytp/shuttlerecalled.ogg',
		ANNOUNCER_SPANOMALIES = 'orbstation/sound/ai/ytp/spanomalies.ogg')


/datum/station_trait/announcement_ytp
	name = "Announcement System Malfunction"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "Our announcement system is experiencing some... \"unique\"... technical difficulties."
	blacklist = list(/datum/station_trait/announcement_medbot, /datum/station_trait/announcement_intern)
	trait_to_give = STATION_TRAIT_YTP

/datum/station_trait/announcement_ytp/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/ytp

/datum/round_event_control/falsealarm/New()
	. = ..()
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_YTP))
		return
	//weight *= 3 				ough
	max_occurrences *= 2
	earliest_start *= 0.25

#undef STATION_TRAIT_YTP
