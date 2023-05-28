extends Control

@onready var l = $Label
var tween = null

@export var travel = Vector2(0, -80)
@export var duration = 1
@export var spread = PI/2
@export var color = Color("2cb744")

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.subscribe("create_damage_label", self, "create_damage_label")

func create_damage_label(values):
	tween = create_tween()
	self.position = values['position']
	l.position.x = 0
	l.position.y = 0
	l.text = str(values['damage'])
	color = values['color']
	var movement = travel.rotated(randf_range(-spread/2, spread/2))
	l.modulate = color
	tween.tween_property(l, "position", l.position + movement, duration)
	tween.tween_property(l, "modulate:a", 0.0, duration)
	


