extends CanvasLayer


#@onready var world= $MineField
#@onready var camera = $CameraContainer

@onready var world= $MineField
@onready var camera = $CameraContainer
@onready var camera_borders = $CameraBorders

# Called when the node enters the scene tree for the first time.
func _ready():
	var board: Array[int] = [20, 20, 4]
	world.new_game(board, 40)
	print("Initializing world")
	camera.initialize(world, board)
	camera_borders.initialize(len(board))
	
func initialize_camera_borders():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("space"):
		var a = camera.cameras

	pass
