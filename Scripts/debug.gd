@tool
extends Control
class_name Debug

var label : Label
var info : Dictionary [String, Callable]
@export var verbose : bool = false
var NA = func(): return "N/A"

func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	label = Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(label)
	#print("PADRE: "+  + "   FIGLIO: " + label.name)
	
	update_info()
	for node in get_tree().get_nodes_in_group("Debug"):
		node.connect("changed", update_info)
	
	get_parent().remove_child.call_deferred(self)
	EditorInterface.get_editor_viewport_3d().get_child(0).add_child.call_deferred(self)
	print("[DEBUG] Aggiunto alla viewport 3D")


func update_info() -> void:
	info.clear()
	for node in get_tree().get_nodes_in_group("Debug"):
		if node.debug_info:
			info.merge(node.debug_info)
		elif verbose:
			print(node.name + "non ha il dizionario debug_info!")
	write_label()


func write_label():
	var lines := []
	for line in info:
		lines.append("%s : %s" % [line,  info.get(line, NA).call()])
	self.label.text = "\n".join(lines)
