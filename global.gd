extends Node

var is_mark_adding: bool = false

var exclusion_array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed("r"):
		is_mark_adding = not is_mark_adding
