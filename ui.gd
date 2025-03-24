extends Control

var item_spawner : ItemSpawner
@export var score_label: Label
@export var default_points:= 250
var cumulative: int = 0

func _ready() -> void:
	await get_tree().process_frame
	item_spawner = get_tree().get_first_node_in_group("ItemSpawner")

func _process(_delta: float) -> void:
	var score: int = 0
	if item_spawner:
		score = int(item_spawner.z_reached*10) + cumulative
	score_label.text = str(score)
	
func _on_score(points=default_points) -> void:
	cumulative += points
