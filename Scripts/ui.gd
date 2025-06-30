extends Control

var item_spawner : ItemSpawner
@export var score_label: Label
@export var default_points:= 250
@export var pause_menu : Panel
@export var pause_button : TextureButton
@export var over_menu : Panel
@export var palazzomanager : PalazzoManager
@export var worldenvironment : WorldEnvironment
var skymaterials := [ 
	preload("res://Assets/Materiali/skyshader.tres"),
	preload("res://Assets/Materiali/simplesky.tres"),]
var sliders : Dictionary[String,HSlider]
@export var slider_container :Container
@onready var hearts 
var lifes = 3

var invulnerability := Timer.new()
var INVULNERABILITY := 2

@onready var player : Player = get_tree().get_first_node_in_group("Player")
var cumulative: int = 0
var paused := false
signal go
signal wait
var first_start = true

func _ready() -> void:
	pause_menu.visible = false
	await get_tree().process_frame
	item_spawner = get_tree().get_first_node_in_group("ItemSpawner")
	hearts = $VBoxContainer/Panel/HBoxContainer/Life.get_children()
	connect("go", func(): player.go = true)
	connect("wait", func(): player.go = false)
	for n in slider_container.get_children():
		if n is HSlider:
			n.value_changed.connect(_slide_edit.bind(n.name))
	add_child(invulnerability)
	invulnerability.one_shot=true
	

func _input(event: InputEvent) -> void:
	if first_start and event is InputEventKey and event.pressed:
		first_start = false
		$VBoxContainer/Panel/PerIniziare.visible = false
		start()
	


func _process(_delta: float) -> void:
	var score: int = 0
	if item_spawner:
		score = int(item_spawner.z_reached*10) + cumulative
	score_label.text = str(score)
	if Input.is_action_just_pressed("pause"):
		_on_pause()

func _slide_edit(value, slider_name):
	var bus = ["GeneralSlider", "MusicSlider"].find(slider_name)
	if bus == -1:
		return
	AudioServer.set_bus_volume_linear(bus, value)
	
func _on_score(points=default_points) -> void:
	cumulative += points

func _on_pause() -> void:
	#Input.mouse_mode = int(paused)
	paused = not paused
	pause_menu.visible = paused
	pause_button.button_pressed = paused
	AudioServer.set_bus_volume_linear(0, .2 if paused else 1)
	Engine.time_scale = 0 if paused else 1
	$Istruzioni.visible = false
	
func start() -> void:
	cumulative = 0
	await get_tree().create_timer(1).timeout
	var go_label = $VBoxContainer/Panel/GO
	$CountDown.play()
	for heart in hearts:
		heart.visible = true
		await get_tree().create_timer(1).timeout
	go.emit()
	go_label.visible = true
	await get_tree().create_timer(1).timeout
	go_label.visible = false
	
func _on_damage() -> void:
	if invulnerability.time_left > 0:
		#print(invulnerability.time_left)
		return
	invulnerability.start(INVULNERABILITY)
	lifes -=1
	$Hit.play()
	hearts.get(lifes).visible = false
	if lifes == 0:
		hearts.get(lifes).visible = false
		over_menu.visible = true
		Engine.time_scale = 0
		



func _on_retry() -> void:
	invulnerability.start(INVULNERABILITY)
	over_menu.visible = false
	pause_menu.visible = false
	palazzomanager._init()
	item_spawner._init()
	wait.emit()
	start()
	Engine.time_scale = 1
	lifes = 3
	cumulative = 0
	player.get_parent().respawn(true)
	
	pass # Replace with function body.


func _on_sky_toggle(toggled_on: bool) -> void:
	worldenvironment.environment.sky.sky_material = skymaterials[int(toggled_on)]


func _on_questionairre() -> void:
	OS.shell_open("https://docs.google.com/forms/d/e/1FAIpQLSchlBaHai_V656Usc7FwNt9c6WZvHdwOSje4C8nrLJTGKWNdw/viewform?usp=sharing&ouid=115925283467482932691")


func _on_quit() -> void:
	get_tree().quit()
