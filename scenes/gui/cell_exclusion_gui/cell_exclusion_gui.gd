extends GridContainer

@onready var minicell_dict = {
	1: $"1",
	2: $"2",
	3: $"3",
	4: $"4",
	5: $"5",
	6: $"6",
	7: $"7",
	8: $"8",
	9: $"9",
}



# Called when the node enters the scene tree for the first time.
func _ready():
	for i in minicell_dict.keys():
		minicell_dict[i].toggled.connect(_on_toggled.bind(i))

func _on_toggled(is_toggled, location):
	if is_toggled:
		Global.exclusion_array.append(location)
	else:
		Global.exclusion_array.erase(location)
	print(Global.exclusion_array)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
