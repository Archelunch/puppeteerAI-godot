extends Node

"""
Personal info:
You are Mark, leader of mercenaries. 
Your task is to kill all bandits. 
You are a kind-hearted pearson. Your priority is to save your allies' lifes. 
Your health is awesome. You don't need to heal yourself. 
Allies info:
Rob is your ally, he is seriously injured and probably will die next turn. 
Enemies info:
John is a leder of bandits. He is strong. 
Jane is an archer of bandits. She is seriously injured and probably will die next turn. 
In this situation you will."""

var template_situation = """
Personal info:
{personal}
Allies info:
{allies}
Enemies info:
{enemies}
In this situation you will.
"""

var template_dialogue = '''
Instruction: based on situation generate short phrase that suits your character.
Personal info:
{personal}
Unit info:
{unit}
You {action} You said to him: " 
'''

var dialogue_suffix = '"'

var template_personal = """You are {name}, {description}.\nYour mission is to {mission}.\n{traits}\n{health}\n"""
var template_personal_leader = """You are {name}, {description}.\nYour mission is to {mission}. Your leader's command was '{order}'\n{traits}\n{health}\n"""
var template_others = """{name} is {status} {health}\n"""
var template_others_extended = """{name} is {status} {traits} {health}\n"""
var action_template = """{action} {target}"""

func get_personal(name, description, mission, traits, health, command=""):
	if command == "":
		return template_personal.format({"name":name, "description":description, "mission":mission, "traits":traits, "health": health})
	else:
		return template_personal_leader.format({"name":name, "description":description, "mission":mission, "order":command, "traits":traits, "health": health})

func get_other_info(name, status, health, traits=""):
	if traits != "":
		return template_others_extended.format({"name" : name, "status" : status, "traits": traits, "health" : health})
	return template_others.format({"name" : name, "status" : status, "health" : health})

func get_group(group, exclude=""):
	var group_info = ""
	for ot in group:
		if ot.unit_name != exclude:
			group_info+= get_other_info(ot.unit_name, ot.description, ot.get_target_health_status())
	return group_info

func create_text(personal, allies, enemies):
	return template_situation.format({"personal" : personal, "allies" : allies, "enemies" : enemies})

func get_actions(action_data):
	var possible_actions = []
	for action in action_data.keys():
		for target in action_data[action]['targets']:
			possible_actions.append(action_template.format({'action':action, 'target':target['name']}))
	return possible_actions

func create_situation(person, allies, enemies, command=""):
	var personal_info = get_personal(person.unit_name, person.description, person.mission, person.traits, person.get_own_health_status(), command)
	var allies_info = get_group(allies, person.unit_name)
	var enemies_info = get_group(enemies)
	return create_text(personal_info, allies_info, enemies_info)


func create_dialogue(person, target, action):
	var personal_info = get_personal(person.unit_name, person.description, person.mission, person.traits, person.get_own_health_status())
	var target_info = get_other_info(target.unit_name, target.description, target.get_target_health_status(), target.other_traits)
	return template_dialogue.format({"personal" : personal_info, "unit" : target_info, "action" : action})
