extends Control

@onready var one = $"1"
@onready var two = $"2"
@onready var three = $"3"
@onready var six = $"6"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# expects 0-9, 10 will not work
func set_number(n: int):
	match n:
		0:
			one.visible = false
			two.visible = false
			three.visible = false
			six.visible = false
		1:
			one.visible = true
			two.visible = false
			three.visible = false
			six.visible = false
		2:
			one.visible = false
			two.visible = true
			three.visible = false
			six.visible = false
		3:
			one.visible = false
			two.visible = false
			three.visible = true
			six.visible = false
		4:
			one.visible = true
			two.visible = false
			three.visible = true
			six.visible = false
		5:
			one.visible = false
			two.visible = true
			three.visible = true
			six.visible = false
		6:
			one.visible = false
			two.visible = false
			three.visible = false
			six.visible = true
		7:
			one.visible = true
			two.visible = false
			three.visible = false
			six.visible = true
		8:
			one.visible = false
			two.visible = true
			three.visible = false
			six.visible = true
		9:
			one.visible = false
			two.visible = false
			three.visible = true
			six.visible = true
