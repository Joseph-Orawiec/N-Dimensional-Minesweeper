extends ColorRect

signal initialize
signal zero_chain
signal chord_pressed
signal chord_released
signal chord_canceled
signal flagged
signal clicked(id)
signal toggle_highlighted

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
var is_mouse_on_cell = false

var pause = false

@onready var cell_components = {"inner": $Inner, "highlight": $Highlight, "text container": $TextContainer, "text": $TextContainer/Text, 
	"flag": $Flag, "bomb": $Bomb}

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
			else:
				flagged.emit(pid, false)
				cell_components["flag"].visible = false
			is_flagged = not is_flagged
	else:
		# check for chording logic
		if Input.is_action_pressed("chord"):
			chord_pressed.emit(pid)
			is_chording = true
		if Input.is_action_just_released("chord"): # execute chord
			is_chording = false
			chord_released.emit(pid)

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
	if not is_flagged:
		if not is_pressed:
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
# This bug is awful
# if cells are off the window and offscreen off the viewports, the world "persists" outside of their contained subviewport
# containers and even the godot window. It would pick up mouse input if it's overing to the left of the window
# and cells would react, so this means mouse_entered/exit events cant be trusted and i need to write one myself
# for the longest time i thought the subviewport containers were the issue

# cells will not pickup on _input() so inputs being accepted somewhere else and i can't figure
# out how to get that input (to determine when mouse exited)
# so instead i'm going to call up to the MineField node to manage that

# Handles what mouse_entered and mouse_exited would normally do but with the nuance of the multiple viewports
func _on_area_2d_input_event(viewport, event, shape_idx):
	# loop to get parent viewport, notable viewport is the mainviewport and not what we want
	var viewport_container = get_parent()
	while not viewport_container is SubViewportContainer:
		viewport_container = viewport_container.get_parent()
	
	# verify if mouse input is WITHIN viewport bounds
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		var is_within_x_bounds: bool = (viewport_container.position.x <= event.position.x) and (event.position.x < (viewport_container.position + viewport_container.size).x)
		var is_within_y_bounds: bool = (viewport_container.position.y <= event.position.y) and (event.position.y < (viewport_container.position + viewport_container.size).y)
		
		if (is_within_x_bounds and is_within_y_bounds):
			_on_mouse_entered()
			
func _input(event):
	
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if not is_mouse_on_cell:
			if get_global_rect().has_point(event.position):
				_on_mouse_entered()
		else:
			if not get_global_rect().has_point(event.position):
				_on_mouse_exited()
	


#func _unhandled_input(event):
	#print("taking input")
	#if event is InputEventMouseMotion:
		#var new_position = event.velocity + event.position
		#print(global_position)
		#print(new_position)
		#var is_within_x_bounds = (global_position.x <= new_position.x) and (new_position.x < (global_position + size).x)
		#var is_within_y_bounds = (global_position.y <= new_position.y) and (new_position.y < (global_position + size).y)
		#if (not (is_within_x_bounds and is_within_y_bounds)):
			#_on_mouse_exited()

# viewport check?
	#var node = get_parent()
	#while not node is SubViewportContainer:
		#node = get_parent()

# handles when the cursor enters and exits
func _on_mouse_entered():
	print(get_global_position(), " enter", pid)
	# highlight should continue regardless
	toggle_highlight()
	toggle_highlighted.emit(pid)
	
	is_mouse_on_cell = true
	
	# start polling if mouse is on cell 
	if not pause:
		set_process(true)
	
func _on_mouse_exited():
	print(get_global_position(), " exit", pid)
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
