extends Camera3D

var player: CharacterBody3D
var camera_offset = Vector3(0, 6, 2)  # Imposta l'offset della telecamera (dietro e sopra il giocatore)
var smooth_factor = 0.1  # Controlla la velocità di interpolazione (maggiore = più veloce)
var rotation_offset = Vector3 (-50,0,0)
#var rotation_offset = Vector3 (-60,0,0)
@export var lookup_acceleration := 10


func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_nodes_in_group("Player")[0]

func _process(delta):
	# Calcola la posizione target della telecamera
	var target_position = player.position + camera_offset
	var tween : Tween = get_tree().create_tween()
	var target_rotation = rotation_offset
	#if player.is_looking_up:
		#target_rotation = lookuprotation_offset
	tween.tween_property(self,"rotation_degrees", target_rotation, .1* lookup_acceleration )
	await tween
		
	
	# Interpola la posizione della telecamera tra la posizione attuale e quella di destinazione
	global_position.x = lerp(global_position.x, target_position.x, smooth_factor)
	global_position.y = lerp(global_position.y, target_position.y, smooth_factor)
	global_position.z = lerp(global_position.z, target_position.z, smooth_factor)

		
	
