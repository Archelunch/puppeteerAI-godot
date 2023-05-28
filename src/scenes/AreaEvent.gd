extends Area2D

@onready var meta_dict = {
	"Town1": {"type": "town", "name": "Twilight Farm"},
	"Town2": {"type": "town", "name": "Bright Well"},
	"Town3": {"type": "town", "name": "Ironfall"},
	"Town4": {"type": "town", "name": "Dark Watch"},
	"Town5": {"type": "town", "name": "Dragon Hill"},
	"Town6": {"type": "town", "name": "Emerald Chapel"},
	"Town7": {"type": "town", "name": "Dawnfield"},
	"Town8": {"type": "town", "name": "Timberwick"},
	"Battle1": {"type": "battle", "name": "Library Of Kylar"},
	"Battle2": {"type": "battle", "name": "Temple Of Night"},
}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.area_entered.connect(_on_area_entered)
	self.area_exited.connect(_on_area_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	EventBus.publish("area_entered", meta_dict[self.name])


func _on_area_exited(area):
	EventBus.publish("area_exited", meta_dict[self.name])
