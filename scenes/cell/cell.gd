extends ColorRect

signal initialize
signal zero_chain
signal chord_pressed
signal chord_released
signal chord_canceled
signal flagged
signal clicked(id)

var positional_id #not used by this script but the mine_field script
var id # What kind of cell it is (number or mine)
var v # It's key within the cell dictionary
var is_pressed = false
var is_flagged = false
var is_chording = false
var is_highlighted = false

var pause = false

@onready var cell_components = {"inner": $Inner, "highlight": $Highlight, "text": $CenterContainer/MineCount}

# Called when the node enters the scene tree for the first time.
func _ready():
	var node = get_node(".")
	node.mouse_entered.connect(_on_mouse_entered)
	node.mouse_exited.connect(_on_mouse_exited)
	set_process(false) 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Only care if it's not clicked yet
	if not is_pressed:
		# Only do click logic if it's not flagged as well
		if not is_flagged:
			if Input.is_action_pressed("m1"):
				# switch out the color
				cell_components["inner"].color = Assets.colors[Assets.Colors.PRESSED]
			if Input.is_action_just_released("m1"): # Clicked
					# instead of making a is_started bool, ID can take it's place
					# if null, it's not started yet, emit signal to initialize
					# as the first click is never a mine
					## Implement later
					#if id == null:
						#initialize.emit(v)
						
					# reveal cell
					#click()
					pass

# just a function dedicated to handling the highlight node
func highlight():
	if is_highlighted:
		cell_components['highlight'].visible = false
		is_highlighted = false
	else:
		cell_components['highlight'].visible = true
		is_highlighted = true

#region Mouse Detection
# handles when the cursor enters and exits
func _on_mouse_entered():
	# start polling if mouse is on cell 
	if not pause:
		highlight()
		set_process(true)
	
func _on_mouse_exited():
	if not pause:
		# Stop polling if mouse isn't on cell
		set_process(false)
		# only reset the sprite if it's not flagged and not already pressed 
		if not is_pressed and not is_flagged:
			cell_components["inner"].color = Assets.colors[Assets.Colors.UNKOWN]
			highlight()
			
		# make sure to reset cells' sprites if stopped chording (was about to but moved mouse which means there was no release)
		if is_chording:
			is_chording = false
			chord_canceled.emit(v)
#endregion
