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

var template_personal = """You are {name}, {description}.\nYour mission is to {mission}.\n{traits}\n{health}"""
var template_others = """{name} is {status}. {health}\n"""
var action_template = """{action} {target}\n"""

func get_personal(name, description, mission, traits, health):
	return template_personal.format({"name":name, "description":description, "mission":mission, "traits":traits, "health": health})

func get_other_info(name, status, health):
	return template_others.format({"name" : name, "status" : status, "health" : health})

func get_group(group):
	var group_info = ""
	for ot in group:
		group_info+= get_other_info(ot.name, ot.status, ot.health)
	return group_info

func create_text(personal, allies, enemies):
	return template_situation.format({"personal" : personal, "allies" : allies, "enemies" : enemies})

func get_actions(action_data):
	var possible_actions = ""
	for action in action_data.keys():
		for target in action_data[action]['targets'].keys():
			possible_actions+= action_template.format({'action':action, 'target':target})
	return possible_actions

func create_situation(person, allies, enemies):
	var personal_info = get_personal(person.name, person.description, person.mission, person.traits, person.health)
	var allies_info = get_group(allies)
	var enemies_info = get_group(enemies)
	return create_text(personal_info, allies_info, enemies_info)
