extends StaticBody2D

## Logic that decides what each individual cell should do

signal initialize
signal zero_chain
signal chord_pressed
signal chord_released
signal chord_canceled
signal flagged
signal clicked(id)

var id # What kind of cell it is (number or mine)
var v # It's key within the cell dictionary
var is_pressed = false
var is_flagged = false
var is_chording = false

var pause = false

@onready var sprite_node = $Sprite2D # node reference to change the texture

# Called when the node enters the scene tree for the first time.
func _ready():
	# detecting mouse enter/exit, initializing signals
	var node = get_node(".")
	node.mouse_entered.connect(_on_mouse_entered)
	node.mouse_exited.connect(_on_mouse_exited)
	
	# Turn off polling initially
	set_process(false)
	# Initialize x and y
	v = Vector2(position.x / 50, position.y / 50)


func _process(delta):
	if Input.is_action_just_pressed('m1'):
		print('M1 CLICK RA')

# Signal stuff: mouse enter/leave
func _on_mouse_entered():
	set_process(true)
	print('ENTER')

func _on_mouse_exited():
	set_process(false)
	pass
