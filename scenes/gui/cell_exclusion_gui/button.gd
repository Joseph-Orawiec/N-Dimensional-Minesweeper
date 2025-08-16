extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	set_process(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("m1"):
		button_pressed = not button_pressed

func _on_mouse_entered():
	set_process(true)
	
func _on_mouse_exited():
	set_process(false)
#endregion
