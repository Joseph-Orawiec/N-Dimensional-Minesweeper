extends CanvasLayer


#@onready var world= $MineField
#@onready var camera = $CameraContainer

@onready var world= $MineField
@onready var camera = $CameraContainer
@onready var camera_borders = $CameraBorders

var cell_exclusion_gui = preload("res://scenes/gui/cell_exclusion_gui/cell_exclusion_gui.tscn")
var cell_exclusion_gui_node = null
var show_exclusion_gui = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var board: Array[int] = [4, 4, 4, 4]
	world.new_game(board, 10)
	print("Initializing world")
	camera.initialize(world, board)
	#camera.multicam_on()
	camera_borders.initialize(len(board))
	#camera_borders.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("space"):
		camera.multicam_off()
		camera_borders.hide()
	if Input.is_action_just_pressed("reposition_cameras"):
		camera.multicam_on()
		camera_borders.show()

func _input(event):
	pass
	#if event.is_action_pressed("f"):
		#if not show_exclusion_gui:
			#cell_exclusion_gui_node = cell_exclusion_gui.instantiate()
			#add_child(cell_exclusion_gui_node)
			#show_exclusion_gui = true
		#else:
			#remove_child(cell_exclusion_gui_node)
			#cell_exclusion_gui_node.queue_free()
			#cell_exclusion_gui_node = null
			#show_exclusion_gui = false

