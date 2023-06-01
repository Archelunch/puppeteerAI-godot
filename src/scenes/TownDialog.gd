extends Control

@onready var town_name: Label = $MarginContainer4/MarginContainer2/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	var half_screen = get_viewport_rect().size / 4
	$MarginContainer4.offset_left = half_screen.x * $MarginContainer4.scale.x
	$MarginContainer4.offset_top = half_screen.y * $MarginContainer4.scale.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func entering_town(params):
	town_name.text = params['name']

func _on_exit_button_pressed():
	queue_free()
