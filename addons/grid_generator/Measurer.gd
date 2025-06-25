@tool

extends Node
@export_tool_button("genera e misura", "")
var mnv := measure

var current_measure:=0

var gg :GridGenerator
var algo : GenerationAlgorithm



@export var results : Array[Dictionary]
@export_category("Connessioni non rispettate")
@export_enum('1', '2', '3', '4', '5') var connessioni: int :
	set(v):
		var k = 'connessioni'
		if results.size()  == current_measure:
			results.append({k:v})
		else:
			results[current_measure].set(k, v)

@export_enum('1', '2', '3', '4', '5') var generazione: int :
	set(v):
		var k = 'generazione'
		if results.size()  == current_measure:
			results.append({k:v})
		else:
			results[current_measure].set(k, v)



func _init() -> void:
	gg = get_parent()
	algo = gg.generation

func measure():
	var start := Time.get_ticks_usec()
	gg.sg.call()
	var duration_ms := ( Time.get_ticks_usec() - start) / 1000.0
	print("Tempo di esecuzione: ", duration_ms, " ms")
		
	
