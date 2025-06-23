@tool
extends Panel
class_name TextureSpinbox

var shown = -1
var min = -1
@onready var max : int
#@export var mesh_library_size : int = 30
#@export var meshlibrary : MeshLibrary = preload("res://Nodes/Palazzo/PalazzoMeshLibrary.tres")
@export var empty :Texture2D
@export var preview : TextureRect
var textures : Array[Texture2D]

var right_click_pending = false
@export var buttonup : TextureButton
@export var buttondown :TextureButton 

signal destroy()
signal on_parameters_changed()
signal index_changed(index: int)



func _set(property: StringName, new_shown: Variant) -> bool:
	if property == "shown":
		if new_shown>=min and new_shown<=max:
			shown = new_shown
			set_preview(new_shown)
			on_parameters_changed.emit()
		return true
	return false


func set_preview(to_show:int):
	if to_show > min:
		preview.texture = textures[to_show]
	else:
		preview.texture = empty
	buttonup.disabled = to_show <= min
	buttondown.disabled = to_show >= max


func next(): 
	_set("shown",shown+1)
func prev(): 
	_set("shown",shown-1)
	
func _on_index_changed(_shown: int) -> void:
	_set("shown", _shown)
	

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					right_click_pending = true
				elif event.is_released() and right_click_pending:
					right_click_pending = false
					destroy.emit()
					call_deferred("queue_free")
				get_viewport().set_input_as_handled()

			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					next()
					get_viewport().set_input_as_handled()

			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					prev()
					get_viewport().set_input_as_handled()


func _on_mouse_exited() -> void:
	right_click_pending = false


#func show_tooltip() -> void:
	#var tooltip := Label.new()
	#tooltip.text = 
	#var tip_timer := Timer.new()
	#tip_timer.one_shot = true



const scene : PackedScene = preload("res://addons/grid_generator/ui_components/texture_spinbox.tscn")
static func create_new(id:int, _textures:Array[Texture2D]) -> TextureSpinbox:
	var instance : TextureSpinbox = scene.instantiate() as TextureSpinbox
	instance.textures = _textures
	instance.max = len(_textures) -1
	instance._set("shown",id)
	instance.shown = id
	instance.set_preview(id)
	return instance
