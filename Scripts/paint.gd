@tool
extends Node
class_name Paint

@export var value: float = 1.0
@export var color: Color
@export_range(0, 1) var saturation_min: float = 0 
@export_range(0, 1) var saturation_max: float = 1 
@export_range(0, 1) var illumination_min: float = 0
@export_range(0, 1) var illumination_max: float = 1



@export_tool_button("Randomize color")
var c: Callable = func (): 
	color = _random_color()
	color.a = .5
	
func _init(passed_color: Color = _random_color()) -> void:
	color = passed_color
	color.a = .5

func _random_color():
	return Color.from_hsv(
		randf_range(0,1),
		randf_range(saturation_min,saturation_max), 
		randf_range(illumination_min,illumination_max))

func mono_gradient_texture() -> GradientTexture1D :
	var gt = GradientTexture1D.new()
	var g = Gradient.new()
	for point in g.get_point_count():
		g.set_color(point, color)
	gt.gradient = g
	return gt
