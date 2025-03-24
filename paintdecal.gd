
extends Decal
class_name PaintDecal

var paint: Paint
const paintdecal_scene: PackedScene = preload("res://paintDecal.tscn")


static func create(p:Paint) -> PaintDecal:
	var new_decal: PaintDecal = paintdecal_scene.instantiate()
	new_decal.paint = p
	return new_decal


func _ready() -> void:
	paint.color.a = .8
	modulate =  paint.color
