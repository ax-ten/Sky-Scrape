
@tool
extends Node2D

# Parametri per la griglia
@export var grid_size: int = 10  # Dimensione della cella
@export var grid_width: int = 10  # Numero di celle lungo l'asse X
@export var grid_height: int = 10  # Numero di celle lungo l'asse Z
@export var max_height: int = 5  # Altezza massima di estrusione

# Griglia 2D di valori (0 = vuoto, 1 = pieno)
var grid_data: Array

@export_tool_button("Generate") 
var c: Callable = func() -> void:
	#generate_next_floor()
	pass

# Funzione per inizializzare la griglia con valori casuali o definiti
func _ready():

	
	# Creiamo un array di dati vuoti per la griglia
	grid_data = Array()
	
	# Inizializzare la griglia 2D con valori casuali di altezza
	for i in range(grid_width):
		var row = Array()
		for j in range(grid_height):
			row.append(randi() % max_height)  # Altezza casuale tra 0 e max_height
		grid_data.append(row)

# Funzione per generare la geometria 3D
func create_3d_geometry():
	# Rimuoviamo eventuali oggetti precedenti
	for child in get_children():
		child.queue_free()
	
	# Generiamo la geometria per ogni cella della griglia
	for x in range(grid_width):
		for z in range(grid_height):
			var height = grid_data[x][z]
			if height > 0:
				# Creare un cubo per ogni cella con valore maggiore di 0
				var cube = MeshInstance3D.new()
				var cube_mesh = BoxMesh.new()  # Usa un cubo di base
				cube.mesh = cube_mesh
				
				# Posizionare il cubo in base alla griglia e all'altezza
				cube.transform.origin = Vector3(x * grid_size, height * grid_size, z * grid_size)
				
				# Aggiungi il cubo alla scena
				add_child(cube)

# Funzione che verrà chiamata quando il pulsante viene premuto
func _on_generate_button_pressed():
	create_3d_geometry()
