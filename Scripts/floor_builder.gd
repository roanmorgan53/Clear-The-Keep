class_name FloorBuilder
extends Node2D
## Builds the Floor when it enters the tree: generates a FloorLayout, places a Room
## per cell, paints a corridor per edge, walls off sealed sockets and moves the
## Player to the Spawn Room's PlayerStart. See GLOSSARY.md and docs/adr/0003.

const FLOOR_TILE := Vector2i(0, 0)  # source 2
const WALL := Vector2i(2, 7)  # source 0, also BG_Walls on the north side
const TOPPER_N := Vector2i(2, 0)
const TOPPER_S := Vector2i(2, 6)
const SIDE_WALL := Vector2i(8, 3)
# The alternative the Rooms use for east-side walls.
const FLIP := TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V

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
	if not layout:
		return

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
		room.position = Room.cell_position(cell)
		add_child(room)
		placed[cell] = room
	for edge in layout.edges:
		_paint_corridor(edge[0], edge[1] - edge[0])
	for entry in layout.sealed:
		placed[entry[0]].seal(entry[1])
	if player:
		player.global_position = placed[layout.spawn_cell].spawn_point()


func _paint(layer: String, tile: Vector2i, atlas: Vector2i, source := 0, alt := 0) -> void:
	_layers[layer].set_cell(tile, source, atlas, alt)


# Corridor from cell `from` toward its RIGHT or DOWN neighbour, between the facing sockets.
func _paint_corridor(from: Vector2i, dir: Vector2i) -> void:
	var origin := Room.cell_origin(from)
	var door := Room.DOOR
	for i in Room.CORRIDOR_LENGTH:
		if dir == Vector2i.RIGHT:
			var x := origin.x + Room.SIZE.x + i
			_paint("BG_Toppers", Vector2i(x, origin.y + door.y - Room.WALL_HEIGHT), TOPPER_N)
			_paint("BG_Walls", Vector2i(x, origin.y + door.y - 1), WALL)
			for j in Room.DOOR_WIDTH:
				_paint("Floor", Vector2i(x, origin.y + door.y + j), FLOOR_TILE, 2)
			_paint("FG_Toppers", Vector2i(x, origin.y + door.y + Room.DOOR_WIDTH - 1), TOPPER_S)
			_paint("FG_Walls", Vector2i(x, origin.y + door.y + Room.DOOR_WIDTH), WALL)
		else:
			var y := origin.y + Room.SIZE.y + i
			_paint("BG_Walls", Vector2i(origin.x + door.x - 1, y), SIDE_WALL)
			for j in Room.DOOR_WIDTH:
				_paint("Floor", Vector2i(origin.x + door.x + j, y), FLOOR_TILE, 2)
			_paint("BG_Walls", Vector2i(origin.x + door.x + Room.DOOR_WIDTH, y), SIDE_WALL, 0, FLIP)
