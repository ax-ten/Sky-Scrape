@tool
extends Node3D

class_name LSystem3D
var rules = {
	"F": "FY[XF]Z[-F]+F"
}
var axiom = "F"
var iterations = 3
var angle = 45
var structure = ""

@export_tool_button("Generate") 
var c: Callable = func() -> void:
	generate_lsystem()
	build_structure()


func generate_lsystem():
	structure = axiom
	for _i in range(iterations):
		var new_structure = ""
		for char in structure:
			if rules.has(char):
				new_structure += rules[char]
			else:
				new_structure += char
		structure = new_structure
	print("Generated Structure: ", structure)

func build_structure():
	var pos = Vector3(0, 0, 0)
	var stack = []
	var direction = Vector3.UP
	var right = Vector3.RIGHT
	var forward = Vector3.FORWARD

	for char in structure:
		if char == "F":
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = BoxMesh.new()
			mesh_instance.transform.origin = pos
			add_child(mesh_instance)
			pos += direction  # Altezza del piano
		elif char == "Y":
			pos += Vector3.UP  # Salita di un piano
		elif char == "X":
			pos += right  # Estensione laterale
		elif char == "Z":
			pos += forward  # Espansione frontale
		elif char == "[":
			stack.append([pos, direction, right, forward])
		elif char == "]":
			var state = stack.pop_back()
			pos = state[0]
			direction = state[1]
			right = state[2]
			forward = state[3]
		elif char == "+":
			direction = direction.rotated(Vector3.UP, deg_to_rad(angle))
		elif char == "-":
			direction = direction.rotated(Vector3.UP, deg_to_rad(-angle))
