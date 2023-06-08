@tool
extends EditorPlugin
var chat

func _enter_tree():
	chat = preload("res://addons/puppeteerAI/chat.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, chat)
	

func _exit_tree():
	remove_control_from_docks(chat)
	chat.free()
