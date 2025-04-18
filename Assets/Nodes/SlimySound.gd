extends Node

const starts = [0.17, 1.3, 2.6, 4, 5.39, 7.35, 8.6, 10.08, 11.9]
@export var duration : float = 0.7
const mushysounds : AudioStreamMP3 = preload("res://Assets/Audio/mushy_impact.mp3")

func _reproduce_random(jump=false) -> void:
	var asp = new_player(jump)
	var range_start = 4 if jump else 0
	var sound_index = starts[range_start + randi_range(0, 3)]
	add_child(asp)
	asp.play(sound_index)
	asp.get_child(0).start(duration)

static func new_player(jump=false) -> AudioStreamPlayer:
	var asp = AudioStreamPlayer.new()
	asp.stream = mushysounds
	asp.volume_db = 4 if jump else -2
	asp.pitch_scale = 1.2 if jump else 0.9
	
	var timer = Timer.new()
	timer.timeout.connect(func(): 
		asp.stop()
		timer.queue_free()
		asp.queue_free()
		)
	asp.add_child(timer)
	
	return asp
	
