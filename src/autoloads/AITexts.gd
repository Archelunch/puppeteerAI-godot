extends Node

const own_health_check = {
	"100%": "You are totally okay and ready for battle. You don't need healing.",
	"75%": "You are slightly injured. You can continue battle without healing.",
	"40%": "You have serious wounds. You can continue battle, but healing would be awesome.",
	"0%": "You are in danger. You will probably die without healing."
}

const other_health_check = {
	"100%": "He is totally okay and ready for battle.",
	"75%": "He is slightly injured and can fight.",
	"40%": "He has serious wounds. Next attack will make him closer to death.",
	"0%": "He is in danger. He will die with next attack."
}

const mission_type = {
	"kill_bandits": "kill all bandits",
	"kill_person": "kill {name}",
	"defend_group": "survive attack of enemies",
	"protect_person": "protect {name}. You can't let him die",
}

const trait_type = {
	"kind-hearted": "You are a kind-hearted pearson. Your priority is to save your allies' lifes.",
	"cruel": "You were made for battles. Your only goal is to kill everyone.",
	"coward": "You are coward. Your own survival is your top priority.",
	"empty": ""
}
