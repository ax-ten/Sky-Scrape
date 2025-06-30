extends Node3D
class_name Painter

@onready var currentpaint: Paint = $Paint
@export var decalscene: PackedScene
@export var playermesh: MeshInstance3D
var player: Player

@onready var jump_particles: GPUParticles3D = $JumpParticles
@onready var walk_particles: GPUParticles3D = $WalkParticles


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func paint(scal:float = 1):
	currentpaint.value -= 0.01
	var decal = PaintDecal.create(currentpaint)
	decal.size.x *= scal
	decal.size.z *= scal
	get_tree().root.add_child(decal)
	decal.global_position = player.global_position + Vector3.DOWN/2


func _process(_delta: float) -> void:
	playermesh.mesh.material.albedo_color = currentpaint.color
	#jump_particles.draw_pass_1.material.albedo_color = currentpaint.color
	#walk_particles.draw_pass_1.material.albedo_color = currentpaint.color


func _on_landing(force:float=1) -> void:
	jump_particles.amount_ratio = force
	jump_particles.restart()


func _on_walking(start:bool) -> void:
	walk_particles.emitting = start


func _on_paint_near(area: Area3D) -> void:
	var bucket = area.get_parent() as PaintBucket
	if not bucket: return
	var tween = get_tree().create_tween()

	tween.tween_property(currentpaint, "color", bucket.paint.color, .4) 
	get_tree().get_first_node_in_group("UI").call("_on_score")
	$PickPaint.play()
	currentpaint.value = bucket.paint.value
	bucket.queue_free()
