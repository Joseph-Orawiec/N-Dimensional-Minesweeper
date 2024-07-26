extends Node2D

@onready var world = $"Wallhaven-136m9w2560x1440"
@onready var canvas_layer = $CanvasLayer
@onready var camera = $CanvasLayer/CameraContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.initialize(world, 1)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("space"):
		print_tree_pretty()
	pass