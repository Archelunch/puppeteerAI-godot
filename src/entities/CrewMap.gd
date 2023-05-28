extends Node2D

@export var moving = true
var tween: Tween = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("left_click") and self.moving:
		tween = create_tween()
		tween.tween_property(self, "position", get_global_mouse_position(), 2)
