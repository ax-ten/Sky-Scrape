@tool
extends EditorPlugin

var inspector_plugin := PluginAdjacencyConfiguration.new()
var rule_plugin := PluginTiledAdjacencyRule.new()  

func _enter_tree():
	add_inspector_plugin(inspector_plugin)
	add_inspector_plugin(rule_plugin) 

func _exit_tree():
	remove_inspector_plugin(inspector_plugin)
	remove_inspector_plugin(rule_plugin)
