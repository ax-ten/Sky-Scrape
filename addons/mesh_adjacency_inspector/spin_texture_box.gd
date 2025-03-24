@tool
extends Control
class_name SpinTextureBox

var index : int
var min : int = -1
var max : int 
var step : int = 1
signal index_changed(index: int)

func _ready():
	index = min
	max = meshlibrary.get_item_list().size() -1
	connect("index_changed", _on_index_changed)
	_on_index_changed(index) 
	
func _on_index_changed(i):
	if i >= 0:
		$Preview.texture = meshlibrary.get_item_preview(i)
	else:
		$Preview.texture = Texture2D.new()
	$Buttons/Up.disabled = i >= max
	$Buttons/Down.disabled = i <= min
	
func next():
	index += step
	emit_signal("index_changed", index)

func prev():
	index -= step
	emit_signal("index_changed", index)

@export var meshlibrary : MeshLibrary = preload("res://PalazzoMeshLibrary.tres")

@export_tool_button("Reset Button Textures")
var g : Callable = func():
	$Buttons/Up.texture_normal = get_theme_icon("up", "SpinBox")
	#$Buttons/Up.texture_hover = get_theme_icon("up_hover", "SpinBox")
	#$Buttons/Up.texture_pressed = get_theme_icon("up_pressed", "SpinBox")
	#$Buttons/Up.texture_disabled = get_theme_icon("up_disabled", "SpinBox")
	$Buttons/Down.texture_normal = get_theme_icon("down", "SpinBox")
	#$Buttons/Down.texture_hover = get_theme_icon("down_hover", "SpinBox")
	#$Buttons/Down.texture_pressed = get_theme_icon("down_pressed", "SpinBox")
