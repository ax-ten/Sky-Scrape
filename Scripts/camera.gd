extends Camera3D

var player: CharacterBody3D
@export var camera_offset = Vector3(0, 6, -8)  # Imposta l'offset della telecamera (dietro e sopra il giocatore)
@export_range(0.001, 0.5, 0.01) var smooth_factor = 0.1  # Controlla la velocità di interpolazione (maggiore = più veloce)
@export var tilt = Vector3.ZERO
var rotation_offset = Vector3 (0,tilt.x,tilt.y)
@export var lookup_acceleration := 10


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	$Traffic.play(randf_range(0,192)) #parti da un punto a caso della traccia

func _process(_delta):
	# Calcola la posizione target della telecamera
	var target_position = player.position + camera_offset
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	var target_rotation = tilt
	#if player.is_looking_up:
		#target_rotation = lookuprotation_offset
	tween.tween_property(self,"rotation_degrees", target_rotation, .1* lookup_acceleration )
	#await tween
	
	
	# Interpola la posizione della telecamera tra la posizione attuale e quella di destinazione
	global_position.x = lerp(global_position.x, target_position.x, smooth_factor)
	global_position.y = lerp(global_position.y, target_position.y, smooth_factor)
	global_position.z = lerp(global_position.z, target_position.z, smooth_factor)


func loop_traffic_sound() -> void:
	$Traffic.play()
	
