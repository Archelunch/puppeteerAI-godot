extends Node

@export var scene: String
@export var scene2: String
@export var fade_out_speed: float = 0.5
@export var fade_in_speed: float = 0.5
@export var fade_out_pattern: String = "fade"
@export var fade_in_pattern: String = "fade"
@export var fade_out_smoothness = 0.1 # (float, 0, 1)
@export var fade_in_smoothness = 0.1 # (float, 0, 1)
@export var fade_out_inverted: bool = false
@export var fade_in_inverted: bool = false
@export var color: Color = Color(0, 0, 0)
@export var timeout: float = 0.0
@export var clickable: bool = false
@export var add_to_back: bool = true


@onready var fade_out_options = SceneManager.create_options(fade_out_speed, fade_out_pattern, fade_out_smoothness, fade_out_inverted)
@onready var fade_in_options = SceneManager.create_options(fade_in_speed, fade_in_pattern, fade_in_smoothness, fade_in_inverted)
@onready var general_options = SceneManager.create_general_options(color, timeout, clickable, add_to_back)
@onready var enter_dialog: Control = self.get_node("EnterDialog")
@onready var crew_map: Area2D = self.get_node("CrewMap")
@onready var cur_area: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var fade_in_first_scene_options = SceneManager.create_options(1, "fade")
	var first_scene_general_options = SceneManager.create_general_options(Color(0, 0, 0), 1, false)
	SceneManager.show_first_scene(fade_in_first_scene_options, first_scene_general_options)
	# code breaks if scene is not recognizable
	SceneManager.validate_scene(scene)
	# code breaks if pattern is not recognizable
	SceneManager.validate_pattern(fade_out_pattern)
	SceneManager.validate_pattern(fade_in_pattern)
	EventBus.subscribe("area_entered", self, "entering_dialog")
	EventBus.subscribe("area_exited", self, "exiting_dialog")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("change_scene"):
		SceneManager.change_scene(scene, fade_out_options, fade_in_options, general_options)


func entering_dialog(params):
	var label: Label = self.get_node("EnterDialog/MarginContainer/VBoxContainer/Label")
	label.set_text('Do you want to enter {type} "{name}"?'.format(params))
	self.cur_area = params
	enter_dialog.visible = true
	if crew_map.tween:
		crew_map.tween.stop()


func exiting_dialog(params):
	enter_dialog.visible = false
	self.cur_area = {}

func _on_yes_button_pressed():
	if "type" in self.cur_area:
		if self.cur_area["type"] == "battle":
			SceneManager.change_scene(scene, fade_out_options, fade_in_options, general_options)
		else:
			var town_ui = SceneManager.create_scene_instance(scene2)
			self.add_child(town_ui)
			town_ui.entering_town(self.cur_area)
