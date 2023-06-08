@tool
extends Control

var mbtn
var lbl
var popup
# Called when the node enters the scene tree for the first time.
func _enter_tree():
	mbtn = self.find_child("mnb")
	lbl = self.find_child("lbl")
	popup = mbtn.get_popup()
	popup.id_pressed.connect(change_label)


func change_label(id):
	lbl.text = popup.get_item_text(id)

