extends Node


const combat_units_data = {
	"leader": {
		"name": "Leader",
		"min_attack": 8,
		"max_attack": 10,
		"dexterity": 4,
		"protection": 15,
		"luck": 2,
		"max_hp": 30,
		"description": "leader of mercenaries",
		"actions": ["basic_attack", "basic_heal", "group_heal"],
		"sprite": "res://assets/sprites/Units/Boss Mythical Knight Goldnharl.png"
	},
	"junior": {
		"name": "Junior",
		"min_attack": 5,
		"max_attack": 8,
		"dexterity": 4,
		"protection": 10,
		"luck": 2,
		"max_hp": 20,
		"description": "newbie in this crew.",
		"actions": ["basic_attack", "basic_heal"],
		"sprite": "res://assets/sprites/Units/Medieval Bandit Child.png"
	},
	"rogue": {
		"name": "Rogue",
		"min_attack": 3,
		"max_attack": 5,
		"dexterity": 6,
		"protection": 10,
		"luck": 2,
		"max_hp": 10,
		"description": "professional assasin",
		"actions": ["basic_attack"],
		"sprite": "res://assets/sprites/Units/Rogue Dagger Monk.png"
	},
	"butcher": {
		"name": "Butcher",
		"min_attack": 3,
		"max_attack": 5,
		"dexterity": 2,
		"protection": 10,
		"luck": 2,
		"max_hp": 30,
		"description": "strong warrior and leader of bandits.",
		"actions": ["basic_attack"],
		"sprite": "res://assets/sprites/Units/Medieval Bandit Dagger Gun.png"
	},
	"assassin": {
		"name": "Assassin",
		"min_attack": 5,
		"max_attack": 8,
		"dexterity": 4,
		"protection": 10,
		"luck": 2,
		"max_hp": 10,
		"description": "professional assasin.",
		"actions": ["basic_attack", "group_attack"],
		"sprite": "res://assets/sprites/Units/Medieval Bandit Great Sword.png"
	},
	}

const action_data = {
	"basic_attack": {
		"name": "Basic Attack",
		"damage_percentage": 95,
		"target": Constants.ActionTarget_EnemySingle
	},
	"group_attack": {
		"name": "Group Attack",
		"damage_percentage": 50,
		"target": Constants.ActionTarget_EnemyMultiple
	},
	"basic_heal": {
		"name": "Basic Heal",
		"max_uses": 2,
		"target": Constants.ActionTarget_AllySingle,
		"effects": [{
			"type": Constants.EffectType_Heal,
			"amount": 5
		}]
	},
	"group_heal": {
		"name": "Group Heal",
		"max_uses": 1,
		"target": Constants.ActionTarget_AllyMultiple,
		"effects": [{
			"type": Constants.EffectType_Heal,
			"amount": 3
		}]
		},
	"escape": {
		"name": "Escape",
		"max_uses": 1,
		"target": Constants.ActionTarget_Self
	}
	}

const status_data = {}

const map_data = {}

const quest_data = {}

const event_data = {}
