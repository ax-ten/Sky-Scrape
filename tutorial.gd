extends Node3D

var player
var puntatore
var freccia_sx
var freccia_dx

@export var max_pulse : float = 2
@export var pulse_acceleration : float = .5
@export var swipe_delta : float = .1
@export var swipe_time : float = 2
var pulsing = false
var swiping = false
var timer = 100

func _process(delta: float) -> void:
	pass

func _ready() -> void:
	freccia_sx = $FrecciaSx
	freccia_dx = $FrecciaDx
	puntatore = $Sprite3D
	player = get_tree().get_first_node_in_group("Player")

func pulse(sprite : Sprite3D, time: float) -> void:
	pulsing = true
	pass
	pulsing = false
	
func swipe(sprite : Sprite3D, swipe_direction: Vector3) -> void:
	swiping = true
	pass
	swiping = false
	
