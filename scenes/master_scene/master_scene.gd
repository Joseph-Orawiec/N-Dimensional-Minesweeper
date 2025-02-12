extends CanvasLayer

@onready var world= $MineField

# Called when the node enters the scene tree for the first time.
func _ready():
	var board: Array[int] = [10, 10]
	world.new_game(board, 9)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
