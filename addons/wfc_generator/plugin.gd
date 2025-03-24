@tool
extends EditorPlugin

var dock: Control
var inspector: EditorInspector

func _enter_tree():
	print("[PLUGIN] WFC Generator loaded")
	dock = preload("res://addons/wfc_generator/wfc_dock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	dock.visible = false

func _exit_tree():
	print("[PLUGIN] WFC Generator removed")
	remove_control_from_docks(dock)
	dock.free()

func _handles(object: Object) -> bool:
	return object is WFCGridMap
	

func _edit(object: Object) -> void:
	if object is WFCGridMap:
		dock.visible = true
		dock.set_target(object)

func _make_visible(visible: bool) -> void:
	if dock:
		dock.visible = visible
