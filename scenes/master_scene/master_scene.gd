extends CanvasLayer


#@onready var world= $MineField
#@onready var camera = $CameraContainer

@onready var world= $MineField
@onready var camera = $CameraContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	var board: Array[int] = [4, 4, 4, 4]
	world.new_game(board, 10)
	camera.initialize(world, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("space"):
		print_tree_pretty()
	pass
