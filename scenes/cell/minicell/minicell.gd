extends Control

@onready var one = $One
@onready var ten = $Ten
@onready var hundred = $Hundred
@onready var thousand = $Thousand

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#takes anything from 0 to 9999
func set_number(n):
	# actually faster than peeling each digit with a do while
		
	n = "0000" + str(n)
	
	thousand.set_number(int(n[-4]))
	hundred.set_number(int(n[-3]))
	ten.set_number(int(n[-2]))
	one.set_number(int(n[-1]))
	
