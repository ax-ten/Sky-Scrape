extends Resource
class_name AdjacencyRule

# Dizionario [id_mesh, weight]
# dove weight è la probabilità relativa che un blocco venga piazzato
@export var X_pos : Dictionary[int, float] 
@export var X_neg : Dictionary[int, float] 
@export var Y_pos : Dictionary[int, float] 
@export var Y_neg : Dictionary[int, float] 
@export var Z_pos : Dictionary[int, float] 
@export var Z_neg : Dictionary[int, float] 

var directions = [X_pos, X_neg, Y_pos, Y_neg, Z_pos, Z_neg]
func _get(property: StringName):
	match property:
		"X_pos": return X_pos
		"X_neg": return X_neg
		"Y_pos": return Y_pos
		"Y_neg": return Y_neg
		"Z_pos": return Z_pos
		"Z_neg": return Z_neg
	return null

func _set(property: StringName, value):
	match property:
		"X_pos": X_pos = value
		"X_neg": X_neg = value
		"Y_pos": Y_pos = value
		"Y_neg": Y_neg = value
		"Z_pos": Z_pos = value
		"Z_neg": Z_neg = value

	return true
