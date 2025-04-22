@tool
extends Panel
class_name MeshSelector

var mesh_id = -1
var min = -1
signal on_parameters_changed(mesh_id)
@export var preview : TextureRect
var right_click_pending = false
@export var buttonup : TextureButton
@export var buttondown :TextureButton 
@export var meshlibrary : MeshLibrary = preload("res://Assets/Nodes/Palazzo/PalazzoMeshLibrary.tres")
@export var empty :Texture2D
@onready var max : int = meshlibrary.get_item_list().size() -1

signal index_changed(index: int)

func _set(property: StringName, new_meshid: Variant) -> bool:
	if property == "mesh_id" and new_meshid>=min and new_meshid<=max:
		mesh_id = new_meshid
		set_preview(mesh_id)
		on_parameters_changed.emit(new_meshid)
		return true
	return false


func set_preview(mesh_id:int):
	if mesh_id > min:
		preview.texture = meshlibrary.get_item_preview(mesh_id)
	else:
		preview.texture = empty
	buttonup.disabled = mesh_id <= min
	buttondown.disabled = mesh_id >= max


func next(): _set("mesh_id",mesh_id+1)
func prev(): _set("mesh_id",mesh_id-1)
func _on_index_changed(new_meshid: int) -> void:
	_set("mesh_id", new_meshid)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					right_click_pending = true
				elif event.is_released() and right_click_pending:
					right_click_pending = false
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
	
const scene : PackedScene = preload("res://addons/mesh_adjacency_inspector/mesh_weight_selector.tscn")
static func create_new(id:int) -> MeshSelector:
	var instance : MeshSelector = scene.instantiate() as MeshSelector
	instance._set("mesh_id",id)
	return instance
