extends CanvasLayer


#@onready var world= $MineField
#@onready var camera = $CameraContainer

@onready var world= $MineField
@onready var camera = $CameraContainer
@onready var camera_borders = $CameraBorders

# Called when the node enters the scene tree for the first time.
func _ready():
	var board: Array[int] = [3, 3, 3, 3, 3]
	world.new_game(board, 3)
	print("Initializing world")
	camera.initialize(world, board)
	camera.multicam_on()
	camera_borders.initialize(len(board))
	camera_borders.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("space"):
		camera.multicam_off()
		camera_borders.hide()
	if Input.is_action_just_pressed("reposition_cameras"):
		camera.multicam_on()
		camera_borders.show()

