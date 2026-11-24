class_name FloorBuilder
extends Node2D
## Builds the Floor when it enters the tree: generates a FloorLayout, places a Room
## per cell, paints a corridor per edge, walls off sealed sockets and moves the
## Player to the Spawn Room's PlayerStart. See GLOSSARY.md and docs/adr/0003.

const PITCH := Room.SIZE + Vector2i.ONE * Room.CORRIDOR_LENGTH
const FLOOR_TILE := Vector2i(0, 0)  # source 2
const WALL := Vector2i(2, 7)  # source 0, also BG_Walls on the north side
const TOPPER_N := Vector2i(2, 0)
const TOPPER_S := Vector2i(2, 6)
const SIDE_WALL := Vector2i(8, 3)
const FLIP := 12288  # the alternative the Rooms use for east-side walls

@export var rooms: Array[PackedScene] = []
@export var room_count := 6
## 0 picks a fresh seed each Run; set it to rebuild a specific Floor.
@export var seed_override := 0
@export var player: Node2D
@export var tile_set: TileSet

var layout: FloorLayout
var _layers := {}


func _ready() -> void:
	var rooms_by_role := {}
	for scene in rooms:
		var room: Room = scene.instantiate()
		rooms_by_role.get_or_add(room.role, []).append(scene)
		room.free()
	var seed := seed_override if seed_override != 0 else randi()
	print("Floor seed: ", seed)
	layout = FloorLayout.generate(seed, rooms_by_role, room_count)

	var corridors := Node2D.new()
	corridors.name = "Corridors"
	add_child(corridors)
	for layer_name in ["Floor", "BG_Toppers", "BG_Walls", "FG_Toppers", "FG_Walls"]:
		var layer := TileMapLayer.new()
		layer.name = layer_name
		layer.tile_set = tile_set
		if layer_name.begins_with("FG"):
			layer.z_index = 2
		corridors.add_child(layer)
		_layers[layer_name] = layer

	var placed := {}
	for cell in layout.cells:
		var room: Room = layout.room_at[cell].instantiate()
		room.position = Vector2(cell * PITCH * 16)
		add_child(room)
		placed[cell] = room
	for edge in layout.edges:
		_paint_corridor(edge[0], edge[1] - edge[0])
	for entry in layout.sealed:
		_seal(placed[entry[0]], entry[1])
	if player:
		player.global_position = placed[layout.spawn_cell].get_node("PlayerStart").global_position


func _paint(layer: String, tile: Vector2i, atlas: Vector2i, source := 0, alt := 0) -> void:
	_layers[layer].set_cell(tile, source, atlas, alt)


# Corridor from cell `a` toward its RIGHT or DOWN neighbour, between the facing sockets.
func _paint_corridor(a: Vector2i, dir: Vector2i) -> void:
	var origin := a * PITCH
	for i in Room.CORRIDOR_LENGTH:
		if dir == Vector2i.RIGHT:
			var x := origin.x + Room.SIZE.x + i
			_paint("BG_Toppers", Vector2i(x, origin.y + 5), TOPPER_N)
			_paint("BG_Walls", Vector2i(x, origin.y + 6), WALL)
			_paint("Floor", Vector2i(x, origin.y + 7), FLOOR_TILE, 2)
			_paint("Floor", Vector2i(x, origin.y + 8), FLOOR_TILE, 2)
			_paint("FG_Toppers", Vector2i(x, origin.y + 8), TOPPER_S)
			_paint("FG_Walls", Vector2i(x, origin.y + 9), WALL)
		else:
			var y := origin.y + Room.SIZE.y + i
			_paint("BG_Walls", Vector2i(origin.x + 10, y), SIDE_WALL)
			_paint("Floor", Vector2i(origin.x + 11, y), FLOOR_TILE, 2)
			_paint("Floor", Vector2i(origin.x + 12, y), FLOOR_TILE, 2)
			_paint("BG_Walls", Vector2i(origin.x + 13, y), SIDE_WALL, 0, FLIP)


# Fill a socket's door gap with a copy of the Room's own wall beside it, on every layer.
func _seal(room: Room, dir: Vector2i) -> void:
	var last := Room.SIZE - Vector2i.ONE
	var gap: Array[Vector2i]
	var beside: Vector2i  # offset from a gap tile to the wall tile it copies
	match dir:
		Vector2i.UP:
			gap = [Vector2i(11, 0), Vector2i(12, 0), Vector2i(11, 1), Vector2i(12, 1)]
			beside = Vector2i(-1, 0)
		Vector2i.DOWN:
			gap = [Vector2i(11, last.y - 1), Vector2i(12, last.y - 1), Vector2i(11, last.y), Vector2i(12, last.y)]
			beside = Vector2i(-1, 0)
		Vector2i.LEFT:
			gap = [Vector2i(0, 7), Vector2i(0, 8)]
			beside = Vector2i(0, -1)
		_:
			gap = [Vector2i(last.x, 7), Vector2i(last.x, 8)]
			beside = Vector2i(0, -1)
	for layer: TileMapLayer in room.find_children("*", "TileMapLayer", true, false):
		for tile in gap:
			var from := tile + beside
			layer.set_cell(tile, layer.get_cell_source_id(from), layer.get_cell_atlas_coords(from), layer.get_cell_alternative_tile(from))
