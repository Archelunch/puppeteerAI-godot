extends Node2D

signal change_scene(new_scene_key)

@onready var text_log = $BattleUI/MarginContainer/LogBackground/Log

@export_group("Log Properties")
@export_range(0, 1) var text_timer: float = 0.8

var unit_reference = load("res://src/entities/CombatUnit.gd")

# Players
var player = null
var opponent = null

# Array of the combatants, sorted by the turn initiative, which is
# the combatant speed value plus a random value between 1 and 6
var initiative_order = []

# Turn count
var turn_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
		# Signal connection
	EventBus.subscribe("ai_action_chosen", self, "execute_action")
	EventBus.subscribe("create_popup_at", self, "create_combatant_popup_at")
	EventBus.subscribe("show_enemy_action", self, "show_text")
	
	EventBus.subscribe("remove_combatant_from_queue", self, "remove_combatant_from_queue")
	EventBus.subscribe("remove_combatant_ui", self, "remove_combatant_ui")
	
	randomize()
	text_log.visible_ratio = 0
	
	prepare_battle({
		"id": Constants.PlayerId_Player,
		"combatants": [{
			"id": "leader",
			"position": $Positions/OffenseSide/Pos1.global_position,
			"current_hp": null,
			"battle_name": Constants.default_names[0],
			"traits": AITexts.trait_type["kind-hearted"],
			"mission": AITexts.mission_type["kill_bandits"]
		}, {
			"id": "junior",
			"position": $Positions/OffenseSide/Pos2.global_position,
			"current_hp": null,
			"battle_name": Constants.default_names[1],
			"traits": AITexts.trait_type["kind-hearted"],
			"mission": AITexts.mission_type["kill_bandits"]
		}, {
			"id": "assassin",
			"position": $Positions/OffenseSide/Pos3.global_position,
			"current_hp": null,
			"battle_name": Constants.default_names[2],
			"traits": AITexts.trait_type["cruel"],
			"mission": AITexts.mission_type["kill_bandits"]
		}],
		"type": Constants.PlayerType.Player
	}, {
		"id": Constants.PlayerId_Enemy,
		"combatants": [{
			"id": "rogue",
			"position": $Positions/DeffenseSide/Pos1.global_position,
			"current_hp": null,
			"battle_name": Constants.default_names[3],
			"traits": AITexts.trait_type["cruel"],
			"mission": AITexts.mission_type["defend_group"]
		}, {
			"id": "butcher",
			"position": $Positions/DeffenseSide/Pos2.global_position,
			"current_hp": null,
			"battle_name": Constants.default_names[4],
			"traits": AITexts.trait_type["cruel"],
			"mission": AITexts.mission_type["defend_group"]
		}, {
			"id": "rogue",
			"position": $Positions/DeffenseSide/Pos3.global_position,
			"current_hp": null,
			"battle_name": Constants.default_names[5],
			"traits": AITexts.trait_type["coward"],
			"mission": AITexts.mission_type["defend_group"]
		}],
		"type": Constants.PlayerType.AI
	})
	

func prepare_battle(player_team, enemy_team):
	
	# Create the player object, necessary to identifing the combatant ownership and make the ai act up
	player = Player.new(player_team.id, player_team.type)
	opponent = Player.new(enemy_team.id, enemy_team.type)
	
	$Players.add_child(player)
	$Players.add_child(opponent)
	
	# Create the players combatant, using the fixed position in $PlayerCombatantPositions,
	# Also create their respective healthbars
	var player_combatants = []
	for combatant_number in player_team.combatants.size():
		var combatant = player_team.combatants[combatant_number]
		var combatant_pos = $Positions/OffenseSide.get_children()[combatant_number]
		var new_combatant = create_combatant(combatant_pos, combatant.id, combatant.position, combatant.current_hp, combatant.battle_name, combatant.traits, combatant.mission)
		new_combatant.player_id = player_team.id
		player_combatants.append(new_combatant)
		# HealthBar
#		var new_health_bar = health_bar_reference.instance()
#		new_health_bar.init(new_combatant)
#		new_combatant.connect("combatant_hp_changed", self, "combatant_hp_changed", [new_health_bar])
#		new_combatant.connect("status_changed", self, "status_changed", [new_health_bar])
#		new_combatant.connect("buffs_changed", self, "buffs_changed", [new_health_bar])
#		$UI/PlayerHealthBars.add_child(new_health_bar)
	
	# Create the enemy combatant,
	# Also create their respective healthbars
	var enemy_combatants = []
	for combatant_number in enemy_team.combatants.size():
		var combatant = enemy_team.combatants[combatant_number]
		var combatant_pos = $Positions/DeffenseSide.get_children()[combatant_number]
		var new_combatant = create_combatant(combatant_pos, combatant.id, combatant.position, combatant.current_hp, combatant.battle_name, combatant.traits, combatant.mission)
		new_combatant.player_id = enemy_team.id
		enemy_combatants.append(new_combatant)
		# HealthBar
#		var new_health_bar = health_bar_reference.instance()
#		new_health_bar.init(new_combatant)
#		new_combatant.connect("combatant_hp_changed", self, "combatant_hp_changed", [new_health_bar])
#		new_combatant.connect("status_changed", self, "status_changed", [new_health_bar])
#		new_combatant.connect("buffs_changed", self, "buffs_changed", [new_health_bar])
#		$UI/EnemyHealthBars.add_child(new_health_bar)
	
	# Give the combatants references to the two players
	player.combatants = player_combatants
	player.opponent_combatants = enemy_combatants
	
	opponent.combatants = enemy_combatants
	opponent.opponent_combatants = player_combatants
	
	# Start the first turn
	start_turn()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func create_combatant(combotant, combatant_id, combatant_position, current_hp = null, combatant_name = "", traits="", mission=""):
	
	if (DataBase.combat_units_data.has(combatant_id)):
		var data = DataBase.combat_units_data[combatant_id]
		combotant.init({
			"name": combatant_name,
			"max_hp": data.max_hp,
			"current_hp": data.max_hp if current_hp == null else current_hp,
			"min_attack": data.min_attack,
			"max_attack": data.max_attack,
			"dexterity": data.dexterity,
			"protection": data.protection,
			"luck": data.luck,
			"sprite": data.sprite,
			"actions": data.actions,
			"traits": traits,
			"description": data.description,
			"mission": mission
		}, combatant_position)
	return combotant


func show_text(value):
	text_log.visible_ratio = 0
	text_log.text = value
	var tween = create_tween()
	tween.tween_property(text_log, "visible_ratio", 1.1, text_timer)
	
func reset_text():
	text_log.text = ""

func start_turn():
	
	# Increse the turn counter
	turn_count += 1
#	$UI/TurnCounter.text = str("Turn: ", turn_count)
#
	show_text(str("Turn ", turn_count, " starts!"))
	await get_tree().create_timer(1.5).timeout
	
	reset_text()
	
	# Roll and assigned initiative to every active combatant
	for combatant in $Positions/OffenseSide.get_children():
		if combatant.is_dead():
			continue
		var initiative = combatant.get_initiative()
		initiative_order.append({
			"combatant": combatant,
			"initiative": initiative
		})
	for combatant in $Positions/DeffenseSide.get_children():
		if combatant.is_dead():
			continue
		var initiative = combatant.get_initiative()
		initiative_order.append({
			"combatant": combatant,
			"initiative": initiative
		})
	initiative_order.sort_custom(sort_initiative)
	
	# the first combatant Acts
	go_to_next_combatant()

# Sort initiative
func sort_initiative(comb_1, comb_2):
	if comb_1.initiative > comb_2.initiative:
		return true
	return false

func go_to_next_combatant():
	
	if (initiative_order.size() > 0):
		
		# get the current combatant
		var current_combatant = initiative_order.pop_front().combatant
		
		# show that combatant initiative hint
		
		# Check DoT status and apply them
		var totalDOTDamage = 0
#		for status in current_combatant.get_status():
#			if status.status_type == Constants.StatusType_Bleed:
#				totalDOTDamage += status.amount
#				status.apply_status(current_combatant)
#			if status.status_type == Constants.StatusType_Poison:
#				totalDOTDamage += status.amount
#				status.apply_status(current_combatant)
		
		if totalDOTDamage != 0:
			current_combatant.inflict_damage(totalDOTDamage)
			# if the combatant has been freed or has been ko between a status, pass the turn
			if !weakref(current_combatant).get_ref() || current_combatant.is_dead():
				go_to_next_combatant()
				return
			await get_tree().create_timer(1.2).timeout
#			current_combatant.emit_signal("status_changed")
		
		
		if current_combatant.player_id == player.id:
			# if it's a player combatant, show the ui
			player.choose_action(current_combatant)
		else:
			# if it's a enemy combatant, the player ai, chooses an action
			opponent.choose_action(current_combatant)
	else:
		# if no other combatant is left, start a new turn
		start_turn()

# Removes a dead combatant
func remove_combatant_from_queue(combatant):
	for initiative_object in initiative_order:
		if initiative_object.combatant == combatant:
			initiative_order.erase(initiative_object)
			
# Executes an action over an array of targets
func execute_action(params):
	var acting_combatant = params['current']
	var action = params['action']
	var targets = params['targets']
	
	reset_text()
	
	# If no action or targets are passed, skip the turn
	if action == null or targets.size() == 0:
		var label_dict = {'damage': "Pass", 'position': acting_combatant.get_target_position(), 'color': Color("3d3d3d")}
		$FloatingText.create_damage_label(label_dict)
		if !is_battle_over():
			go_to_next_combatant()
		return
	
	for target in targets:
		# if the action has damage, deal it to all the targets
		if action.damage_percentage != null:
			var flat_damage = acting_combatant.roll_attack_damage()
			var action_damage = int(float(flat_damage) * float(action.damage_percentage) / 100.0 * float(100.0 - target.get_protection()) / 100.0)
			
#			create_effect(target.global_position, load("res://src/effects/HitEffect001.tscn"))
			
			target.inflict_damage(action_damage)
		
		# if the action has effects, apply them to all the targets
		for effect in action.get_effects():
			effect.apply_to_target(target)
		for effect in action.get_self_effects():
			effect.apply_to_target(acting_combatant)
		
		if action.is_escape:
			target.die()
	
#	if weakref(acting_combatant).get_ref():
#		acting_combatant.consume_buffs()
	
	# Check if the battle is over, otherwise go to the next combatant
	if !is_battle_over():
		await get_tree().create_timer(1.2).timeout
		go_to_next_combatant()

# Check if one of the parties has been defeated
func is_battle_over():
	# Check player team
	var player_team_is_defeated = true
	for combatant in $Positions/OffenseSide.get_children():
		if combatant.player_id == player.id && !combatant.is_dead():
			player_team_is_defeated = false
	
	# Check enemy team
	var enemy_team_is_defeated = true
	for combatant in $Positions/DeffenseSide.get_children():
		if combatant.player_id != player.id && !combatant.is_dead():
			enemy_team_is_defeated = false
	
	if player_team_is_defeated && enemy_team_is_defeated:
		show_text("That's a tie!")
	elif enemy_team_is_defeated:
		show_text("You won!")
	elif player_team_is_defeated:
		show_text("You lost!")
	
	return player_team_is_defeated || enemy_team_is_defeated


