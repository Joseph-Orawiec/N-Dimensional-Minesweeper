extends GridContainer

const border: PackedScene = preload("res://scenes/master_scene/camera_borders/nine_patch_rect.tscn")
@onready var main_border = border.instantiate()
var main_container = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(main_border)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func initialize(d):
	# initializes camera borders in the same way it initializes the board
	# grid containers inside grid containers
	for i in range(1, d - 1): # i is the dimension
		if i == 1: # starter case
			main_container = GridContainer.new()
			add_child(main_container)
			main_container.columns = 3
			main_container.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
			main_container.size_flags_vertical = GridContainer.SIZE_EXPAND_FILL
			main_container.add_theme_constant_override('h_separation', 0)
			main_container.add_theme_constant_override('v_separation', 0)
			
			main_border.reparent(main_container)
			for j in range(2):
				var new_border = main_border.duplicate()
				add_child(new_border)
				new_border.reparent(main_container)
				
		elif i % 2 == 1: # odd dimension
			var old_container = main_container
			main_container = GridContainer.new()
			add_child(main_container)
			main_container.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
			main_container.size_flags_vertical = GridContainer.SIZE_EXPAND_FILL
			main_container.add_theme_constant_override('h_separation', 0)
			main_container.add_theme_constant_override('v_separation', 0)
			main_container.columns = 3
			
			old_container.reparent(main_container)
			for j in range(2):
				var new_container = old_container.duplicate()
				add_child(new_container)
				new_container.reparent(main_container)
		else: # vertical dimension
			var old_container = main_container
			main_container = GridContainer.new()
			add_child(main_container)
			main_container.size_flags_horizontal = GridContainer.SIZE_EXPAND_FILL
			main_container.size_flags_vertical = GridContainer.SIZE_EXPAND_FILL
			main_container.add_theme_constant_override('h_separation', 0)
			main_container.add_theme_constant_override('v_separation', 0)
			
			old_container.reparent(main_container)
			for j in range(2): 
				var new_container = old_container.duplicate()
				add_child(new_container)
				new_container.reparent(main_container)
