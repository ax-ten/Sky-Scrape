extends Node

# Pre-carica i materiali per ogni tipo di cubo
@export var material_1: Material
@export var material_2: Material
@export var material_3: Material

# Esempio di tessere (materiali per i cubi)
var tiles = [
	material_1,
	material_2,
	material_3
]

# Griglia di celle per la mappa
var grid_size = Vector2(10, 10)  # Dimensione della griglia
var grid = []

# Funzione per inizializzare la griglia con tutte le tessere possibili
func _ready():
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			# Ogni cella può contenere inizialmente tutte le tessere
			row.append([0, 1, 2])  # Indici delle tessere disponibili
		grid.append(row)
	generate_map()

# Funzione per generare la mappa
func generate_map():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			place_tile(x, y)

# Funzione per posizionare un cubo con materiale in una posizione
func place_tile(x, y):
	# Seleziona casualmente una delle tessere possibili
	var possible_tiles = grid[y][x]
	var selected_tile_index = possible_tiles[randi() % possible_tiles.size()]
	
	# Crea un MeshInstance per il cubo
	var tile_instance = MeshInstance3D.new()
	
	# Crea un cubo
	var cube_mesh = BoxMesh.new()
	tile_instance.mesh = cube_mesh
	
	# Assegna il materiale selezionato al cubo
	tile_instance.material_override = tiles[selected_tile_index]
	
	# Posiziona il cubo sulla griglia
	tile_instance.position = Vector3(x, 0, y)  # Distanza tra i cubi
	
	# Aggiungi il cubo come child della scena
	add_child(tile_instance)
