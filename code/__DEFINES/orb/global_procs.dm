// Initializes the global language list, if it does not already exist. Used in a couple different places.
/proc/setup_language_list()
	if(GLOB.all_languages.len)
		return
	for(var/datum/language/language as anything in subtypesof(/datum/language))
		if(!initial(language.key))
			continue

		GLOB.all_languages += language
		GLOB.language_types_by_name[initial(language.name)] = language

		var/datum/language/instance = new language
		GLOB.language_datum_instances[language] = instance
