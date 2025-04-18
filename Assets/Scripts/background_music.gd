extends AudioStreamPlayer
@export var start : float = 3.85

func _ready() -> void:
	play(start)

func _process(delta: float) -> void:
	if self.get_playback_position() + AudioServer.get_time_since_last_mix() > 149:
		_loop()
	
func _loop() -> void:
	play(8.50)
