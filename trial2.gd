@tool
extends Node3D

@export_tool_button("Generate") 
var c: Callable = func() -> void:
	generate_next_floor()

var current_floor = 0  # Tiene traccia del piano corrente

# Parametri dell'L-system
var axiom = "F"  # Partiamo con il simbolo di base
var rules = {
	"F": "FF+[+F-F-F]-[-F+F+F]"  # Regola di sostituzione per "F"
}

var iterations = 4  # Numero di iterazioni dell'L-system
var angle = 25  # Angolo di rotazione

# Funzione che genera il piano
func generate_next_floor():
	current_floor += 1
	print("Generating floor ", current_floor)
	
	# Genera la stringa L-system dopo le iterazioni
	var lsystem_string = generate_lsystem(axiom, iterations)
	
	# Ora utilizziamo la stringa per generare la geometria
	build_structure_from_lsystem(lsystem_string, current_floor)

# Generazione dell'L-system
func generate_lsystem(axiom: String, iterations: int) -> String:
	var result = axiom
	for i in range(iterations):
		var new_result = ""
		for char in result:
			if rules.has(char):
				new_result += rules[char]  # Sostituire il simbolo con la regola
			else:
				new_result += char  # Mantenere il simbolo invariato
		result = new_result
	return result

# Funzione per costruire la struttura a partire dalla stringa L-system
func build_structure_from_lsystem(lsystem_string: String, floor: int):
	var position = Vector3(0, floor * 3, 0)  # Posiziona ogni piano sopra il precedente
	var direction = Vector3(1, 0, 0)  # Direzione iniziale (andiamo in avanti)

	var stack = []  # Per memorizzare lo stato quando dobbiamo tornare indietro
	var mesh_instance = MeshInstance3D.new()

	var vertices = PackedVector3Array()  # Array di vertici (deve essere PackedVector3Array)
	var indices = PackedInt32Array()  # Array di indici (deve essere PackedInt32Array)
	var idx = 0

	for symbol in lsystem_string:
		match symbol:
			"F":
				# Aggiungi un segmento alla geometria
				var next_position = position + direction * 1.0  # Avanza di 1 unità
				vertices.append(position)
				vertices.append(next_position)

				# Connetti i vertici con un indice
				indices.append(idx)
				indices.append(idx + 1)
				idx += 2

				position = next_position  # Aggiorna la posizione
			"+":
				# Ruota a destra
				direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(angle))
			"-":
				# Ruota a sinistra
				direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(-angle))
			"[":
				# Salva lo stato della posizione e direzione
				stack.append([position, direction])  # Usa parentesi quadre per una lista
			"]":
				# Ripristina lo stato della posizione e direzione
				var state = stack.pop_back()
				position = state[0]
				direction = state[1]

	# Crea il mesh dalla geometria generata
	var array_mesh = ArrayMesh.new()
	var arrays = Array()
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = vertices  # Usa PackedVector3Array
	arrays[Mesh.ARRAY_INDEX] = indices  # Usa PackedInt32Array

	array_mesh.add_surface_from_arrays(Mesh.PrimitiveType.PRIMITIVE_LINES, arrays)
	mesh_instance.mesh = array_mesh
	add_child(mesh_instance)

	print("Built structure for floor ", floor)
