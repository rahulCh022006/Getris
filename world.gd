extends TileMapLayer

#tetrominoes
var i_0 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
var i_90 := [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
var i_180 := [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
var i_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
var i := [i_0, i_90, i_180, i_270]

var t_0 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var t_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var t := [t_0, t_90, t_180, t_270]

var o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o := [o_0, o_90, o_180, o_270]

var z_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
var z_90 := [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var z_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var z_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var z := [z_0, z_90, z_180, z_270]

var s_0 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
var s_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var s_180 := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)]
var s_270 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var s := [s_0, s_90, s_180, s_270]

var l_0 := [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var l_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var l_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
var l_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
var l := [l_0, l_90, l_180, l_270]

var j_0 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var j_90 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
var j_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var j_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
var j := [j_0, j_90, j_180, j_270]

var shapes := [i, t, o, z, s, l, j]
var shapes_full := shapes.duplicate()

#Grid Vars
const ROWS := 20
const COLUMNS := 10
var score: int
const ACCEL: float = 0.05


#TileMap Variables
var tile_id : int = 0
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

# Layers
@onready var board: TileMapLayer = $Board
@onready var game: TileMapLayer = $Game
@onready var hud: CanvasLayer = $Hud



#Movement Variables
const start_position:= Vector2i(5,1)
var current_position : Vector2i
const directions : Array = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var speed: float
var steps :Array
const steps_req: int = 50
var game_running: bool = true

#Piece Variables
var piece_type
var next_piece_type
var rotation_index :int = 0
var active_piece: Array


func _ready() -> void:
	new_game()
	hud.get_node("NewGameButton").connect("pressed", new_game)
	hud.get_node("QuitButton").connect("pressed", quit_game)
func quit_game():
	get_tree().quit()
func new_game():
	game_running = true
	clear_panel()
	clear_board()
	score = 0
	hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	hud.get_node("GameOverLabel").hide()
	speed = 1.0
	steps = [0,0,0] # 0 - Left, 1 - Right, 2 - Down
	piece_type = pick_piece()
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0)
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	create_piece()

func pick_piece():
	shapes.shuffle()
	if not shapes.is_empty():
		return shapes.pop_front()
	else:
		shapes = shapes_full.duplicate()
		return shapes.pop_front()  # Ensure a piece is returned after duplication

func clear_board():
	for i in range(ROWS):
		for j in range(COLUMNS):
			game.erase_cell(Vector2i(j + 1, i + 1))
			board.erase_cell(Vector2i(j + 1, i + 1))

func create_piece():
	#Creation of the piece in the beginning or after a piece is dropped
	#resetting variable
	steps = [0,0,0]
	current_position = start_position
	active_piece = piece_type[rotation_index] #Calling for a new active piece through pick_piece()
	draw_piece(active_piece,current_position,piece_atlas)
	draw_piece(next_piece_type[0], Vector2i(15,6), next_piece_atlas)
	
func clear_piece():
	#Erase the tiles based on the active piece
	for i in active_piece:
		game.erase_cell(current_position + i)
	
func _process(delta: float) -> void:
	if game_running:
		if Input.is_action_pressed("DOWN"):
			steps[2] += 10
		elif Input.is_action_pressed("LEFT"):
			steps[0] += 10
		elif Input.is_action_pressed("RIGHT"):
			steps[1] += 10
		elif Input.is_action_just_pressed("DROP"):
			rotate_piece()
		
		#Movement downwards
		steps[2] += speed
		#Movement in general
		for i in range(steps.size()):
			if steps[i] > steps_req:
				move_piece(directions[i])
				steps[i] = 0

func move_piece(dir):
	if can_move(dir):
		clear_piece() #Remove the piece at the location and then
		current_position += dir #Change the position then
		draw_piece(active_piece, current_position, piece_atlas) #Draw a new piece at the new position
	else:
		if dir == Vector2i.DOWN:
			land_piece()
			check_rows()
			piece_type = next_piece_type
			piece_atlas = next_piece_atlas
			next_piece_type = pick_piece()
			next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
			clear_panel()
			create_piece()
			check_game_over()
func check_rows():
	var row: int = ROWS
	while row > 0:
		var count: int = 0
		for i in range(COLUMNS):
			if not is_free(Vector2i(i + 1,row)):
				count += 1
		if count == COLUMNS:
			shift_rows(row)
			score += 100
			speed += ACCEL
		else:
			row -= 1
	hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	print("Score: \n", score , "Speed: ", speed)
func shift_rows(row):
	var atlas
	for i in range(row, 1, -1):
		for j in range(COLUMNS):
			atlas = board.get_cell_atlas_coords(Vector2i(j + 1,i - 1))
			if atlas == Vector2i(-1,-1):
				board.erase_cell(Vector2i(j + 1, i))
			else:
				board.set_cell(Vector2i(j + 1 , i), tile_id, atlas)
func clear_panel():
	for i in range(14,19):
		for j in range(5,9):
			game.erase_cell(Vector2i(i,j))
	
func land_piece():
	for i in active_piece:
		game.erase_cell(current_position + i)
		board.set_cell(current_position + i, tile_id, piece_atlas)

func rotate_piece():
	if can_rotate():
		clear_piece()
		rotation_index = (rotation_index + 1) % 4
		active_piece = piece_type[rotation_index]
		draw_piece(active_piece, current_position, piece_atlas)

func can_move(dir):
	#Checking if we can move
	var cm: bool = true
	for i in active_piece:
		if not is_free(current_position + i + dir):
			cm = false
	return cm

func can_rotate():
	var cr :bool = true
	var temp_rotation_index := (rotation_index + 1) % 4
	for i in piece_type[temp_rotation_index]:
		if not is_free(i + current_position):
			cr = false
	return cr

func is_free(pos):
	return board.get_cell_source_id(pos) == -1

func check_game_over():
	for i in active_piece:
		if not is_free(i + current_position):
			land_piece()
			hud.get_node("GameOverLabel").show()
			game_running = false

func draw_piece(piece, pos, atlas):
	# Iterate through piece array and draw a tile at each position
	for i in piece:
		game.set_cell(pos + i,tile_id, atlas)
