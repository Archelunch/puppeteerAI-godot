extends Node
class_name Player

var id : String = ""

var type = Constants.PlayerType.Player

var combatants = []

var opponent_combatants = []

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.subscribe("remove_combatant_from_queue", self, "remove_combatant")
	EventBus.subscribe("combatant_revived", self, "combatant_revived")
	EventBus.subscribe("bart_result", self, "process_llm_action")

func _init(player_id, player_type):
	id = player_id
	type = player_type

func choose_action_lm(current_combatant, command=""):
	var possible_actions = {}
	for action in current_combatant.get_actions():
		if action.has_max_uses() && action.current_uses > 0:
			possible_actions[action.action_name] = {'action': action}
		else:
			possible_actions[action.action_name] = {'action': action}
	var allies_text = ""
	var enemies_text = ""
	if possible_actions.size() != 0:
		for action in possible_actions.keys():
			var possible_targets = []
			match possible_actions[action]['action'].target:
				Constants.ActionTarget_AllySingle, Constants.ActionTarget_AllyMultiple:
					for c in combatants:
						if !c.is_dead():
							possible_targets.append(c)
				Constants.ActionTarget_EnemySingle, Constants.ActionTarget_EnemyMultiple:
					for c in opponent_combatants:
						if !c.is_dead():
							possible_targets.append(c)
				Constants.ActionTarget_Self:
					possible_targets.append(current_combatant)
			possible_actions[action]['targets'] = []
			for pos_target in possible_targets:
				var temp_dict = {'name': pos_target.unit_name, "unit": pos_target}
				
				if action == "Escape":
					temp_dict['name'] = ''
				elif pos_target.unit_name == current_combatant.unit_name:
					temp_dict['name'] = 'self'
				
				possible_actions[action]['targets'].append(temp_dict)
			
	else:
		# If no action could be chosen, pass the turn
		EventBus.publish("show_enemy_action", str(current_combatant.unit_name, " has no move available"))
		await get_tree().create_timer(1.2).timeout
		var combat_action = {'current': current_combatant, 'action': null, 'targets': []}
		EventBus.publish("ai_action_chosen", combat_action)
		return
	var action_text = Templater.get_actions(possible_actions)
	var situation_text = Templater.create_situation(current_combatant, combatants, opponent_combatants, command)
	get_parent().get_parent().get_node("AIManager").request_bart(current_combatant.unit_name, situation_text, action_text, possible_actions)
	# Show the action text
	await get_tree().create_timer(0.3).timeout


func process_llm_action(bart_response):
	var current_combatant
	for comb in combatants:
		if comb.unit_name == bart_response.unit_id:
			current_combatant = comb

	if current_combatant == null:
		return
	
	EventBus.publish("show_enemy_action", str(bart_response.unit_id, " uses ", bart_response['labels'][0], "!"))
	await get_tree().create_timer(0.3).timeout
	
	var chosen_action
	for action in current_combatant.get_actions():
		if action.action_name in bart_response['labels'][0]:
			chosen_action = action
	
	var possible_targets = []
	var target_dialogue = ""
	match chosen_action.target:
		Constants.ActionTarget_AllySingle:
			for c in combatants:
				target_dialogue = "healed him."
				if c.unit_name in bart_response['labels'][0]:
					c.set_shader_tween_heal()
					possible_targets.append(c)
		Constants.ActionTarget_AllyMultiple:
			for c in combatants:
				target_dialogue = "healed your allies."
				c.set_shader_tween_heal()
				possible_targets.append(c)
		Constants.ActionTarget_EnemySingle:
			target_dialogue = "attacked him."
			for c in opponent_combatants:
				if c.unit_name in bart_response['labels'][0]:
					c.set_shader_tween_damage()
					possible_targets.append(c)
		Constants.ActionTarget_EnemyMultiple:
			target_dialogue = "attacked all of them."
			for c in opponent_combatants:
				c.set_shader_tween_damage()
				possible_targets.append(c)
		Constants.ActionTarget_Self:
			target_dialogue = "healed yourself."
			possible_targets.append(current_combatant)
	
	var dialogue_prompt = Templater.create_dialogue(current_combatant, possible_targets[0], target_dialogue)
	get_parent().get_parent().get_node("AIManager").request_GPT(dialogue_prompt, current_combatant.unit_name, possible_targets[0].unit_name, 0.8, 15, Templater.dialogue_suffix)
	await get_tree().create_timer(1.5).timeout
	
	var combat_action
	if chosen_action.target.ends_with("single"):
		var chosen_targets = [possible_targets[0]]
		combat_action = {'current': current_combatant, 'action': chosen_action, 'targets': chosen_targets}
	else:
		combat_action = {'current': current_combatant, 'action': chosen_action, 'targets': possible_targets}
	
	
	EventBus.publish("ai_action_chosen", combat_action)
	await get_tree().create_timer(0.5).timeout

func choose_action(current_combatant):
	# Check all available actions
	var possible_actions = []
	for action in current_combatant.get_actions():
		if action.has_max_uses() && action.current_uses > 0:
			possible_actions.append(action)
		else:
			possible_actions.append(action)
	var chosen_action
	# Choose a random action
	if possible_actions.size() != 0:
		chosen_action = possible_actions[randi()%possible_actions.size()]
	else:
		# If no action could be chosen, pass the turn
		EventBus.publish("show_enemy_action", str(current_combatant.unit_name, " has no move available"))
		await get_tree().create_timer(1.2).timeout
		var combat_action = {'current': current_combatant, 'action': null, 'targets': []}
		EventBus.publish("ai_action_chosen", combat_action)
		return
	
	# Check all the available targets
	var possible_targets = []
	match chosen_action.target:
		Constants.ActionTarget_AllySingle, Constants.ActionTarget_AllyMultiple:
			for c in combatants:
				if !c.is_dead():
					possible_targets.append(c)
		Constants.ActionTarget_EnemySingle, Constants.ActionTarget_EnemyMultiple:
			for c in opponent_combatants:
				if !c.is_dead():
					possible_targets.append(c)
		Constants.ActionTarget_Self:
			possible_targets.append(current_combatant)
	
	# Show the action text
	await get_tree().create_timer(0.3).timeout
	
	EventBus.publish("show_enemy_action", str(current_combatant.unit_name, " uses ", chosen_action.action_name, "!"))
	
	await get_tree().create_timer(1.2).timeout
	
	# Execute the action
	if chosen_action.target.ends_with("single"):
		var chosen_targets = [possible_targets[randi()%possible_targets.size()]]
		var combat_action = {'current': current_combatant, 'action': chosen_action, 'targets': chosen_targets}
		EventBus.publish("ai_action_chosen", combat_action)
	else:
		var combat_action = {'current': current_combatant, 'action': chosen_action, 'targets': possible_targets}
		EventBus.publish("ai_action_chosen", combat_action)


func remove_combatant(combatant):
	if combatants.has(combatant):
		combatants.erase(combatant)
	if opponent_combatants.has(combatant):
		opponent_combatants.erase(combatant)

func combatant_revived(combatant):
	if combatant.player_id == id:
		combatants.append(combatant)
	else:
		opponent_combatants.append(combatant)
