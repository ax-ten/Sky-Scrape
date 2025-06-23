@tool
extends _MeshAdjacencyConfiguration
class_name ModelAdjacencyConfiguration

@export var examples : Dictionary[String, PackedScene]
@export_tool_button("Train", "Control") var t = train


func train():
	pass
