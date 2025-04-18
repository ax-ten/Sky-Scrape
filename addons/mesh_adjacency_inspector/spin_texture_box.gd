@tool
extends Control
class_name SpinTextureBox

var index : int = -1
var min : int = -1
var max : int = 29
signal index_changed(index: int)
@export var empty :Texture2D
@export var meshlibrary : MeshLibrary = preload("res://Assets/Nodes/Palazzo/PalazzoMeshLibrary.tres")
@export var preview : TextureRect
var right_click_pending :=false
var white_border : CanvasItemMaterial = preload("res://Assets/Materiali/glowtext.tres")
var no_border := CanvasItemMaterial.new()

func _ready():
	#max = meshlibrary.get_item_list().size() -1
	connect("index_changed", set_preview)


func set_preview(i:int):
	if i > min:
		preview.texture = meshlibrary.get_item_preview(i)
	else:
		preview.texture = empty
	$Buttons/Up.disabled = i >= max
	$Buttons/Down.disabled = i <= min


func set_index(i:int) -> void:
	if i>=min and i<=max:
		index = i
		index_changed.emit(i)


func next(): set_index(index+1)
func prev(): set_index(index-1)

#const scene = preload("res://addons/mesh_adjacency_inspector/spin_texture_box.tscn")
#static func create_new(i:int) -> SpinTextureBox:
	#var spinbox = scene.instantiate()
	#spinbox.set_index(i)
	#return spinbox

#@export_tool_button("Reset Button Textures")
#var g : Callable = func():
	#$Buttons/Up.texture_normal = get_theme_icon("up", "SpinBox")
	#$Buttons/Down.texture_normal = get_theme_icon("down", "SpinBox")

func turn_red(red:bool) -> void:
	#var tween : Tween = create_tween()
	#var p = get_parent().get_parent()
	get_parent().get_parent().self_modulate = Color.RED if red else Color.WHITE
	#await tween.finished
	

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					next()
					get_viewport().set_input_as_handled()
				MOUSE_BUTTON_WHEEL_DOWN:
					prev()
					get_viewport().set_input_as_handled()
				MOUSE_BUTTON_RIGHT:
					right_click_pending = true
					get_viewport().set_input_as_handled()
					
		if event.is_released() and event.button_index == MOUSE_BUTTON_RIGHT:
			if right_click_pending:
				# Verifica se il cursore è ancora sopra questo nodo
				if Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position()):
					get_parent().get_parent().queue_free()
			right_click_pending = false
			
			get_viewport().set_input_as_handled()
		turn_red(right_click_pending)
		

			
