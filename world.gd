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
const rows := 20
const columns := 10


#TileMap Variables
var tile_id : int = 0
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

# Layers
@onready var board: TileMapLayer = $Board
@onready var game: TileMapLayer = $Game

#Movement Variables
const start_position:= Vector2i(5,1)
var current_position : Vector2i
const directions : Array = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var speed: float
var steps :Array
const steps_req: int = 50

#Piece Variables
var piece_type
var next_piece_type
var rotation_index :int = 0
var active_piece: Array


func _ready() -> void:
	new_game()
	
func new_game():
	speed = 1.0
	steps = [0,0,0] # 0 - Left, 1 - Right, 2 - Down
	piece_type = pick_piece()
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0)
	create_piece()

func pick_piece():
	#randomize pickikng a piece
	var piece
	shapes.shuffle()
	if not shapes.is_empty():
		piece = shapes.pop_front()
	else:
		shapes = shapes_full.duplicate()
	return piece

func create_piece():
	#Creation of the piece in the beginning or after a piece is dropped
	#resetting variable
	steps = [0,0,0]
	current_position = start_position
	active_piece = piece_type[rotation_index] #Calling for a new active piece through pick_piece()
	draw_piece(active_piece,current_position,piece_atlas)
	
func clear_piece():
	#Erase the tiles based on the active piece
	for i in active_piece:
		game.erase_cell(current_position + i)
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("DOWN"):
		steps[2] += 10
	elif Input.is_action_pressed("LEFT"):
		steps[0] += 10
	elif Input.is_action_pressed("RIGHT"):
		steps[1] += 10
	
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

func can_move(dir):
	#Checking if we can move
	
	var cm: bool = true
	for i in active_piece:
		print(is_free(current_position + i + dir))
		if not is_free(current_position + i + dir):
			cm = false
	
	return cm

func is_free(pos):
	return board.get_cell_source_id(pos) == -1

func draw_piece(piece, pos, atlas):
	# Iterate through piece array and draw a tile at each position
	for i in piece:
		game.set_cell(pos + i,tile_id, atlas)
	
