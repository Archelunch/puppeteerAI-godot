extends Node2D

var action_reference = load("res://src/entities/Action.tscn")
@export var unit_name = "Missing string"

var current_hp = 1
var max_hp = 1

var min_attack = 1
var max_attack = 1

var protection = 0
var dexterity = 1
var luck = 1

@export var description = ""
@export var traits = ""
@export var mission = ""

var player_id = ""

var fixed_position = Vector2.ZERO
@onready var unit_sprite = $Sprite
@onready var unit_label = $Label

signal combatant_hp_changed()
signal status_changed()
signal buffs_changed()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	fixed_position = get_global_position()

func init(data, starting_position):
	
	unit_name = data.name
	max_hp = int(data.max_hp)
	current_hp = int(data.current_hp)
	min_attack = int(data.min_attack)
	max_attack = int(data.max_attack)
	dexterity = int(data.dexterity)
	protection = int(data.protection)
	luck = int(data.luck)
	unit_label.text = unit_name
	if (data.has("sprite")):
		var sprite_texture = load(data.sprite)
		unit_sprite.set_texture(sprite_texture)
	
	description = data.description
	if (data.has("traits")):
		traits = data.traits
	if (data.has("mission")):
		mission = data.mission
	
	for action in data.actions:
		var new_action = action_reference.instantiate()
		if DataBase.action_data.has(action):
			var action_data = DataBase.action_data[action]
			new_action.init(action_data)

			$Actions.add_child(new_action)
	
	global_position = starting_position

func set_current_hint(value):
	$Sprite.visible = value
	
func is_dead():
	return current_hp <= 0
	
func get_actions():
	return $Actions.get_children()

	
func get_initiative():
	return (randi()%get_luck() + 1) + get_speed()
	
func get_maximum_attack():
	return max(1, apply_buff(max_attack, Constants.StatType_Attack))
	
func get_minimum_attack():
	return max(1, apply_buff(min_attack, Constants.StatType_Attack))
	
func get_protection():
	return clamp(apply_buff(protection, Constants.StatType_Protection), 0, 99)
	
func get_speed():
	return apply_buff(dexterity, Constants.StatType_Dexterity)
	
func get_luck():
	return apply_buff(luck, Constants.StatType_Luck)
	
func get_own_health_status():
	var hp_ratio = 1.0*current_hp/max_hp
	if hp_ratio == 1.0:
		return AITexts.own_health_check["100%"]
	elif hp_ratio >= 0.75:
		return AITexts.own_health_check["75%"]
	elif hp_ratio >= 0.4:
		return AITexts.own_health_check["40%"]
	else:
		return AITexts.own_health_check["0%"]
		
func get_target_health_status():
	var hp_ratio = 1.0*current_hp/max_hp
	if hp_ratio == 1.0:
		return AITexts.other_health_check["100%"]
	elif hp_ratio >= 0.75:
		return AITexts.other_health_check["75%"]
	elif hp_ratio >= 0.4:
		return AITexts.other_health_check["40%"]
	else:
		return AITexts.other_health_check["0%"]
	
func apply_buff(starting_amount, stat_type):
	var result = starting_amount
#	for buff in get_buffs():
#		if buff.stat_type == stat_type:
#			if buff.buff_amount_type == Constants.BuffAmountType_Flat:
#				result += buff.amount
#			elif buff.buff_amount_type == Constants.BuffAmountType_Percentage:
#				result += int(float(result) * float(buff.amount) / 100.0)
	return result

func roll_attack_damage():
	return randi()%(get_maximum_attack() - get_minimum_attack()) + get_minimum_attack()
	
	
# Let player reach negative health, so that you can heal them
func inflict_damage(damage):
	if player_id == Constants.PlayerId_Player:
		current_hp = max(-50, current_hp - damage)
		if current_hp <= 0:
			die()
			EventBus.publish("remove_combatant_from_queue", self)
	elif player_id == Constants.PlayerId_Enemy:
		current_hp = max(0, current_hp - damage)
		if current_hp == 0:
			die()
	var label_dict = {'damage': damage, 'position': global_position + Vector2(0, -20), 'color': Color("b72c69")}
	EventBus.publish("create_damage_label", label_dict)
	emit_signal("combatant_hp_changed", current_hp, max_hp)

func heal_hp(amount):
	var was_ko = current_hp <= 0
	current_hp = min(max_hp, current_hp + amount)
	if current_hp > 0:
		toggle_ko_sprite(true)
		if was_ko:
			EventBus.publish("combatant_revived", self)
	var label_dict = {'damage': amount, 'position': global_position + Vector2(0, -20), 'color': Color("2cb744")}
	EventBus.publish("create_damage_label", label_dict)
	emit_signal("combatant_hp_changed", current_hp, max_hp)

func die():
	EventBus.publish("remove_combatant_from_queue", self)
#	EventBus.publish("remove_combatant_ui", self)
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func get_target_position():
	return global_position

func toggle_ko_sprite(value):
	$Sprite.visible = value
