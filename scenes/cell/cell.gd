extends ColorRect

signal initialize
signal zero_chain
signal chord_pressed
signal chord_released
signal chord_canceled
signal flagged
signal clicked(id)
signal toggle_highlighted

enum Colors {UNKOWN, PRESSED, OPENED}
var  colors = {Colors.UNKOWN: Color.hex(0xC7C7C7FF), Colors.PRESSED: Color.hex(0x808080FF), Colors.OPENED: Color.hex(0xFFFFFFFF), } #basically a constant

var id: int = -2 # What kind of cell it is (number or mine)
var fid: int #flagged id, id - surrounding flags
var pid: Array[int] # It's key within the cell dictionary, positional id
var is_pressed: bool = false
var is_flagged: bool = false
var is_chording: bool = false
var is_highlighted: bool = false

var pause = false

@onready var cell_components = {"inner": $Inner, "highlight": $Highlight, "text container": $TextContainer, "text": $TextContainer/Text, }

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
				cell_components["inner"].color = colors[Colors.PRESSED]
			if Input.is_action_just_released("m1"): # Clicked
				# instead of making a is_started bool, ID can take it's place
				# if -2 (int's default is 0 rather than null), it's not started yet, emit signal to initialize
				# as the first click is never a mine
				if id == -2:
					initialize.emit(pid)
				
				# reveal cell
				click()

# player click
func click(is_emitting:bool = true):
	# Whenever player clicks a mine or a cell is clicked indirectly via chording or 0 chain
	if not is_flagged:
		if not is_pressed:
			is_pressed = true
			cell_components["text container"].visible = true
			cell_components["text"].text = str(id)
			cell_components["inner"].color = colors[Colors.OPENED]
			
			# prevent trying to zero chain recursively as previously implemented
			if id == 0 and is_emitting:
				zero_chain.emit(pid)
			
			clicked.emit(id)
			
			if id == -1:
				set_process(false)

# just a function dedicated to handling the highlight node
func toggle_highlight():
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
		toggle_highlight()
		toggle_highlighted.emit(pid)
		set_process(true)
	
func _on_mouse_exited():
	if not pause:
		# Stop polling if mouse isn't on cell
		set_process(false)
		# only reset the sprite if it's not flagged and not already pressed 
		if not is_pressed and not is_flagged:
			cell_components["inner"].color = colors[Colors.UNKOWN]
		
		# should do whether is pressed or not
		toggle_highlight()
		toggle_highlighted.emit(pid)
			
		# make sure to reset cells' sprites if stopped chording (was about to but moved mouse which means there was no release)
		if is_chording:
			is_chording = false
			chord_canceled.emit(pid)
#endregion
