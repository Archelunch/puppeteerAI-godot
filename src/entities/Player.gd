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

func _init(player_id, player_type):
	id = player_id
	type = player_type

func choose_action_lm(current_combatant):
	var possible_actions = {}
	for action in current_combatant.get_actions():
		if action.has_max_uses() && action.current_uses > 0:
			possible_actions[action.action_name] = action
		else:
			possible_actions[action.action_name] = action
	var personal_text = Templater.get_personal(current_combatant.unit_name, current_combatant.description, current_combatant.mission, current_combatant.traits, current_combatant.get_own_health_status())
	var allies_text = ""
	var enemies_text = ""
	if possible_actions.size() != 0:
		for action in possible_actions.keys():
			var possible_targets = []
			possible_actions['targets'] = {}
			match possible_actions[action].target:
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
			for pos_target in possible_targets:
				possible_actions['targets'][pos_target.name] = pos_target
			
	else:
		# If no action could be chosen, pass the turn
		EventBus.publish("show_enemy_action", str(current_combatant.unit_name, " has no move available"))
		await get_tree().create_timer(1.2).timeout
		var combat_action = {'current': current_combatant, 'action': null, 'targets': []}
		EventBus.publish("ai_action_chosen", combat_action)
		return
	
	var action_text = Templater.get_actions(possible_actions)
	var situation_text = ""
		
	# Show the action text
	await get_tree().create_timer(0.3).timeout
	
#	EventBus.publish("show_enemy_action", str(current_combatant.unit_name, " uses ", chosen_action.action_name, "!"))
#
#	await get_tree().create_timer(0.3).timeout
#
#	if chosen_action.target.ends_with("single"):
#		var chosen_targets = [possible_targets[randi()%possible_targets.size()]]
#		var combat_action = {'current': current_combatant, 'action': chosen_action, 'targets': chosen_targets}
#		EventBus.publish("ai_action_chosen", combat_action)
#	else:
#		var combat_action = {'current': current_combatant, 'action': chosen_action, 'targets': possible_targets}
#		EventBus.publish("ai_action_chosen", combat_action)

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
