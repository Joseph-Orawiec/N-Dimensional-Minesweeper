extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$StaticBody2D.mouse_entered.connect(_on_static_body_2d_mouse_entered)
	$Area2D.mouse_entered.connect(_on_area_2d_mouse_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_mouse_entered():
	print('AREA2D MOUSE ENTER')
	pass # Replace with function body.

func _on_static_body_2d_mouse_entered():
	print('STATIC AAA')
	pass
	
func _input(event):
	if event.is_action_pressed("space"):
		var node = load("res://tests_during_development/cell.tscn").instantiate()
		node.position = get_global_mouse_position()
		print(node.position)
		add_child(node)
	
	if event.is_action_pressed("m1"):
		print('DP global ', get_global_mouse_position())
		print('DP local ', get_local_mouse_position())
		
