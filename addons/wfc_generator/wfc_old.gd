#@tool
#extends GridMap
#class_name WFCGridMap
#
## Direzioni standard in 3D (non etichettate)
#const DIRECTIONS = [
	#Vector3i(0, 0, -1),   # +Z
	#Vector3i(0, 0, 1),   # -Z
	#Vector3i(0, 1, 0),   # +Y
	#Vector3i(0, -1, 0),  # -Y
	#Vector3i(1, 0, 0),   # +X
	#Vector3i(-1, 0, 0),  # -X
#]
#
#@export var x : int = 10
#@export var y : int = 10
#
#var propagation_queue: Array[Vector3i] = []
#var propagated_positions: Dictionary = {}
#
#
#@export_tool_button("Genera")
#var g : Callable = func():
	#generate(Vector3.ZERO,Vector3(x,1,y))
#
#@export_tool_button("Clear")
#var c : Callable = func():
	#clear()
#
#@export var adjacency_config: MeshAdjacencyConfiguration
#
## Mappa delle possibilità per ogni cella
## ad ogni posizione è collegato l'array di mesh_id possibili
#var possibilities : Dictionary[Vector3i, PackedInt32Array]= {}
#
#func _get_configuration_warnings():
	#if !mesh_library:
		#return ["Associa una MeshLibrary a questo nodo"]
	#elif adjacency_config.is_empty():
		#return ['Configura i collegamenti delle tessere']
	#else:
		#return []
#
#
#func generate(start: Vector3i, end: Vector3i) -> void:
	#var from = Vector3(min(start.x, end.x), min(start.y, end.y), min(start.z, end.z))
	#var   to = Vector3(max(start.x, end.x), max(start.y, end.y), max(start.z, end.z))
#
	#print("Creo la matrice di possibilità")
	#possibilities = superpositions(from, to)
#
#
	#print("Propago")
	#_propagate()
#
	#for pos in possibilities:
		#var options = possibilities[pos]
		#if options.size() == 0:
			#continue
		#var chosen = _pick_weighted_random(pos)
		#set_cell_item(pos, chosen)
	#print("impostati tutti i cell items")
#
#
#func superpositions(from: Vector3, to: Vector3) -> Dictionary:
	#var mesh_list := mesh_library.get_item_list().duplicate()
	#mesh_list.append(-1)
	#var grid : Dictionary[Vector3i, PackedInt32Array] 
	#for x in range(from.x, to.x + 1):
		#for y in range(from.y, to.y + 1):
			#for z in range(from.z, to.z + 1):
				##var pos = Vector3i(x, y, z)
				#grid[Vector3i(x, y, z)] = mesh_list
	#return grid
#
## I haven’t seen this written anywhere else, but my intuition says
 ## that following this minimal entropy heuristic probably results in
 ## fewer contradictions than randomly choosing squares to collapse.
##func lowest_entropy_cell()
#
#func _propagate() -> void:
	#if adjacency_config == null:
		#push_error("Non è caricata alcuna Configurazione di Adiacenza")
		#return
#
	#var changed = true
	#while changed:
		#changed = false
		#for pos in possibilities.keys():
			#for dir in DIRECTIONS:
				#var neighbor = pos + dir
				##se il neighbor non è nella griglia
				#if not possibilities.has(neighbor):
					#continue
#
				#var possible_here = possibilities[pos]
				#if possible_here.is_empty():
					#continue
#
				#var possible_there = possibilities[neighbor]
#
				##print("here",possible_here, " there", possible_there)
				#var filtered: Array = []
#
				#for id in possible_there:
					#var compatible = false
					#for my_id in possible_here:
						#if my_id in adjacency_config.get_compatible(id, -dir):
							#compatible = true
							#break
					#if compatible:
						#filtered.append(id)
#
				#if filtered.size() < possible_there.size():
					#possibilities[neighbor] = PackedInt32Array(filtered)
					#changed = true
#
#func _pick_weighted_random(pos: Vector3i) -> int:
	#var candidates := possibilities.get(pos, PackedInt32Array())
	#if candidates.is_empty():
		#return -1
#
	#var weights := {}
	#var total_weight := 0.0
#
	#for candidate_id in candidates:
		#var candidate_weight := 0.0
#
		#for dir in DIRECTIONS:
			#var neighbor_pos : Vector3i = pos + dir
			#if not possibilities.has(neighbor_pos):
				#continue
#
			#var neighbor_poss := possibilities[neighbor_pos]
			#if neighbor_poss.is_empty():
				#continue
#
			## Questo ID deve essere compatibile con almeno uno dei vicini
			#var compat_dict = adjacency_config.get_weighted_compatible(candidate_id, dir)
			#for neighbor_id in neighbor_poss:
				#if compat_dict.has(neighbor_id):
					#candidate_weight += float(compat_dict[neighbor_id])
#
		#if candidate_weight > 0:
			#weights[candidate_id] = candidate_weight
			#total_weight += candidate_weight
#
	#if weights.is_empty():
		#return candidates[randi() % candidates.size()]  # fallback
#
	## Scelta pesata
	#var rand_val := randf() * total_weight
	#for id in weights.keys():
		#rand_val -= weights[id]
		#if rand_val <= 0:
			#return id
#
	#return weights.keys()[0]  # fallback
