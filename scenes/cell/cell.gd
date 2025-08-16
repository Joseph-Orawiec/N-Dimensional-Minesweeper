extends ColorRect

signal initialize
signal zero_chain
signal chord_pressed
signal chord_released
signal chord_canceled
signal flagged
signal clicked(id)
signal toggle_highlighted
signal cell_marked

enum Colors {UNKOWN, PRESSED, OPENED, FLAGGED_WRONG, BOMB}
var  colors = {Colors.UNKOWN: Color.hex(0xC6C6C6FF), Colors.PRESSED: Color.hex(0x808080FF), Colors.OPENED: Color.hex(0xFFFFFFFF),
 Colors.FLAGGED_WRONG: Color.hex(0xffa0a0FF), Colors.BOMB: Color.RED, } #basically a constant

var id: int = 0 # How many adjacent bombs
var fid: int = 0 #flagged id, id - surrounding flags
var pid: Array[int] # It's key within the cell dictionary, positional id
var is_pressed: bool = false
var is_flagged: bool = false
var is_chording: bool = false
var is_highlighted: bool = false
var is_bomb: bool = false
var has_started: bool = false
var is_mouse_on_cell: bool = false

var mark_toggle: bool = false

var pause: bool = false

@onready var cell_components = {
	"inner": $Inner, 
	"highlight": $Highlight, 
	"text container": $TextContainer, 
	"text": $TextContainer/Text, 
	"flag": $Flag, 
	"bomb": $Bomb,
	"minicell container": $MinicellContainer
	}


# Called when the node enters the scene tree for the first time.
func _ready():
	var node = $Area2D
	#node.input_event.connect(_on_area_2d_input_event)
	#node.mouse_entered.connect(_on_mouse_entered)
	#node.mouse_exited.connect(_on_mouse_exited)
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
				# if has_started is false it's not started yet, emit signal to initialize
				# as the first click is never a mine
				if has_started == false:
					initialize.emit(pid)
				# reveal cell
				click()
				
			# M2 flag cell
		if Input.is_action_just_pressed("m2"):
			if not is_flagged:
				flagged.emit(pid, true) # emit signal to increment/decrement counter
				cell_components["flag"].visible = true
				cell_components["minicell container"].reset()
			else:
				flagged.emit(pid, false)
				cell_components["flag"].visible = false
			is_flagged = not is_flagged
			
		# marking logic
		if Input.is_action_just_pressed("q"):
			cell_components["minicell container"].set_mark(7, 0)
		if Input.is_action_just_pressed("w"):
			cell_components["minicell container"].set_mark(8, 0)
		if Input.is_action_just_pressed("e"):
			cell_components["minicell container"].set_mark(9, 0)
		if Input.is_action_just_pressed("a"):
			cell_components["minicell container"].set_mark(4, 0)
		if Input.is_action_just_pressed("s"):
			cell_components["minicell container"].set_mark(5, 0)
		if Input.is_action_just_pressed("d"):
			cell_components["minicell container"].set_mark(6, 0)
		if Input.is_action_just_pressed("z"):
			cell_components["minicell container"].set_mark(1, 0)
		if Input.is_action_just_pressed("x"):
			cell_components["minicell container"].set_mark(2, 0)
		if Input.is_action_just_pressed("c"):
			cell_components["minicell container"].set_mark(3, 0)
	else:
		# check for chording logic
		if Input.is_action_pressed("chord"):
			chord_pressed.emit(pid)
			is_chording = true
		if Input.is_action_just_released("chord"): # execute chord
			is_chording = false
			chord_released.emit(pid)
		
		# marking logic
		if Input.is_action_just_pressed("q"):
			cell_marked.emit(mark_toggle, pid, 7, fid)
			mark_toggle = not mark_toggle
		if Input.is_action_just_pressed("w"):
			cell_marked.emit(mark_toggle, pid, 8, fid)
			mark_toggle = not mark_toggle
		if Input.is_action_just_pressed("e"):
			cell_marked.emit(mark_toggle, pid, 9, fid)
			mark_toggle = not mark_toggle
		if Input.is_action_just_pressed("a"):
			cell_marked.emit(mark_toggle, pid, 4, fid)
			mark_toggle = not mark_toggle
		if Input.is_action_just_pressed("s"):
			cell_marked.emit(mark_toggle, pid, 5, fid)
			mark_toggle = not mark_toggle
		if Input.is_action_just_pressed("d"):
			cell_marked.emit(mark_toggle, pid, 6, fid)
			mark_toggle = not mark_toggle
		if Input.is_action_just_pressed("z"):
			cell_marked.emit(mark_toggle, pid, 1, fid)
			mark_toggle = not mark_toggle
		if Input.is_action_just_pressed("x"):
			cell_marked.emit(mark_toggle, pid, 2, fid)
			mark_toggle = not mark_toggle
		if Input.is_action_just_pressed("c"):
			cell_marked.emit(mark_toggle, pid, 3, fid)
			mark_toggle = not mark_toggle

#region Winning and Losing
# special flag function for when a game is won, flag all other mines
func won():
	pause = true
	set_process(false)
	if is_bomb and not is_flagged:
		flagged.emit(true)
		cell_components["flag"].visible = true
		
func lost():
	pause = true
	set_process(false)
	if is_bomb and not is_pressed: # reveal mine
		cell_components["bomb"].visible = true
		cell_components["inner"].color = colors[Colors.OPENED]
	
	if is_bomb == false and is_flagged: # 
		cell_components["flag"].visible = true
		cell_components["inner"].color = colors[Colors.FLAGGED_WRONG]
	else:
		
		# click reveal logic copied
		if is_bomb == false:
			if id == 0:
				cell_components["inner"].color = colors[Colors.OPENED]
			else:
				cell_components["text container"].visible = true
				
				# https://www.desmos.com/calculator/i27t16hwwj
				var temp_color = cos((2 * PI)/80 * (id + 4))
				cell_components["inner"].color = Color(1, temp_color, temp_color)
				#cell_components["inner"].color = colors[Colors.OPENED]
				cell_components["text"].text = str(id)
#endregion

# player click
func click(is_emitting:bool = true):
	# Whenever player clicks a mine or a cell is clicked indirectly via chording or 0 chain
	if (not is_flagged) and (not is_pressed):
		cell_components["minicell container"].reset()
		is_pressed = true
		if is_bomb:
			# special bomb case
			cell_components["bomb"].visible = true
			cell_components["inner"].color = colors[Colors.BOMB]
		else:
			if id == 0 and is_bomb == false:
				cell_components["inner"].color = colors[Colors.OPENED]
			else:
				cell_components["text container"].visible = true
				
				# https://www.desmos.com/calculator/i27t16hwwj
				var temp_color = cos((2 * PI)/80 * (id + 4))
				cell_components["inner"].color = Color(1, temp_color, temp_color)
				#cell_components["inner"].color = colors[Colors.OPENED]
				cell_components["text"].text = str(id)
		
		# prevent trying to zero chain recursively as previously implemented
		if id == 0 and is_emitting and is_bomb == false:
			zero_chain.emit(pid)
		
		clicked.emit(pid)
		
		if is_bomb:
			set_process(false)

#region Chording logic
# this function is for when a neighboring cell is getting chorded, this cell needs to change asset
func chord_press():
	# Only do logic if not pressed and not flagged
	if not is_pressed and not is_flagged:
		# show about to be clicked cell sprite
		cell_components["inner"].color = colors[Colors.PRESSED]

# execute chording logic when neighboring cell was chorded
func chord_release(flags_match_id):
	# Only do logic if not pressed and not flagged, same conditions as the initial chord_press
	if not is_pressed and not is_flagged:
		if flags_match_id:
			# and only if the requirements to chord were met
			click();
		else:
			# reset texture
			cell_components["inner"].color = colors[Colors.UNKOWN]

# when a neighboring cell cancelled it's chord, reset sprite
func chord_cancel():
	if not is_pressed and not is_flagged:
		cell_components["inner"].color = colors[Colors.UNKOWN]
#endregion

# just a function dedicated to handling the highlight node
func toggle_highlight():
	cell_components['highlight'].visible = not cell_components['highlight'].visible


#region Mouse Detection
func _input(event):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if not is_mouse_on_cell:
			if get_global_rect().has_point(event.position):
				_on_mouse_entered()
		else:
			if not get_global_rect().has_point(event.position):
				_on_mouse_exited()

# handles when the cursor enters and exits
func _on_mouse_entered():
	# highlight should continue regardless
	toggle_highlight()
	toggle_highlighted.emit(pid)
	
	is_mouse_on_cell = true
	
	# start polling if mouse is on cell 
	if not pause:
		set_process(true)
	
func _on_mouse_exited():
	# highlight should continue regardless
	toggle_highlight()
	toggle_highlighted.emit(pid)
	is_mouse_on_cell = false
	
	if not pause:
		# Stop polling if mouse isn't on cell
		set_process(false)
		# only reset the sprite if it's not flagged and not already pressed 
		if not is_pressed and not is_flagged:
			cell_components["inner"].color = colors[Colors.UNKOWN]
			
		# make sure to reset cells' sprites if stopped chording (was about to but moved mouse which means there was no release)
		if is_chording:
			is_chording = false
			chord_canceled.emit(pid)
#endregion
