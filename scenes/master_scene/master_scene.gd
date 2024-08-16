extends CanvasLayer


#@onready var world= $MineField
#@onready var camera = $CameraContainer

@onready var world= $MineField
@onready var camera = $CameraContainer
@onready var c_borders = $GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	var board: Array[int] = [10, 10, 4]
	world.new_game(board, 40)
	camera.initialize(world, board)
	c_borders.initialize(len(board))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("space"):
		
		
		var a = camera.temppp
		print()
	pass
