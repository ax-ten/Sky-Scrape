@tool

extends Node
@export_tool_button("genera e misura", "")
var mnv := measure

var current_measure:=-1

var gg :GridGenerator
var algo : GenerationAlgorithm

@export var valutazioni_effettuate: int:
	get():
		return results.size()

@export var results : Array[Dictionary]
func add_result(k, v):
	#if results.size()-1 == current_measure:
		#results.append({k: v})
	#else:
	results[current_measure].set(k, v)

@export_category("Valutazioni")
@export_enum("apri per selezionare", "★", "★★", "★★★", "★★★★", "★★★★★")
var connessioni_rispettate := 0:
	set(v):
		connessioni_rispettate = v
		add_result("connessioni", v)

@export_enum("apri per selezionare", "★", "★★", "★★★", "★★★★", "★★★★★")
var buona_generazione := 0:
	set(v):
		buona_generazione = v
		add_result("generazione", v)

@export_enum("apri per selezionare", "★", "★★", "★★★", "★★★★", "★★★★★")
var qualità_finale := 0:
	set(v):
		qualità_finale = v
		add_result("qualita", v)
		
		
@export_category("Attenzione ")
@export_tool_button("resetta tutto", "")
var rese := func():
	results.clear()
	current_measure = -1
	buona_generazione = 0
	connessioni_rispettate = 0
	qualità_finale = 0


func _ready() -> void:
	gg = get_parent()
	algo = gg.generation

func measure():
	if not gg:
		_init()
	current_measure += 1
	buona_generazione = 0
	connessioni_rispettate = 0
	qualità_finale = 0
	gg.clear_grid.call()
	var start := Time.get_ticks_usec()
	gg.sg.call()
	var duration_ms := ( Time.get_ticks_usec() - start) / 1000.0
	print("Tempo di esecuzione: ", duration_ms, " ms")
	results.append({})
	results[current_measure].set('tempo', duration_ms)
	var classn = "MS" if algo is MSAlgorithm else "WFC"
	results[current_measure].set('algoritmo', classn)
	
