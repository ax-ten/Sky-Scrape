@tool

extends Node3D
class_name PaintBucket

@onready var paint: Paint = $Paint
@onready var paintmesh = $Pivot/PaintMesh
@export var paintmaterial: StandardMaterial3D

@export var amplitude: float = 0.1 # Altezza massima dell'oscillazione
@export var frequency: float = 0.2  # Velocità dell'oscillazione
@export var rotation_speed: float = 40 # Gradi al secondo
var time_elapsed: float = 0.0  # Tiene traccia del tempo

@export_tool_button("Reset")
var c: Callable = func():
	_ready()


func _ready() -> void:
	paint.color = paint._random_color()
	paintmaterial.albedo_color = paint.color
	paintmesh.material_override = paintmaterial
	$Pivot.quaternion = Quaternion(.271, -.024, -0.176, 0.956)


func _process(delta: float) -> void:
	time_elapsed += delta
	$Pivot.position.y = sin(time_elapsed * TAU * frequency) * amplitude+ 0.5
	$Pivot.rotate_y(deg_to_rad(rotation_speed * delta))  # Ruota attorno all'asse Y


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			on_predelete()

func on_predelete() -> void:
	pass
