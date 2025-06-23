@tool
extends EditorPlugin

var dock: Control
var inspector: EditorInspector

var adj_config_inspector := PluginAdjacencyConfiguration.new()
#var rule_plugin := PluginTiledAdjacencyRule.new()  

var dir_inspector := DirectionInspectorPlugin.new()


func _enter_tree():
	print("[PLUGIN] WFC Generator loaded")
	add_inspector_plugin(dir_inspector)
	#dock = preload("res://addons/wfc_generator/wfc_dock.tscn").instantiate()
	#add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	#dock.visible = false
	add_inspector_plugin(adj_config_inspector)
	#add_inspector_plugin(rule_plugin) 

func _exit_tree():
	remove_inspector_plugin(dir_inspector)
	#print("[PLUGIN] WFC Generator removed")
	#remove_control_from_docks(dock)
	#dock.free()
	remove_inspector_plugin(adj_config_inspector)
	#remove_inspector_plugin(rule_plugin)

#func _handles(object: Object) -> bool:
	#return object is GridGenerator
	

#func _edit(object: Object) -> void:
	#if object is GridGenerator:
		#dock.visible = true
		#dock.set_target(object)
#
#func _make_visible(visible: bool) -> void:
	#if dock:
		#dock.visible = visible
