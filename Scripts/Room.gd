class_name Room
extends Node2D
## A hand-built Room that fills one Floor grid cell. See GLOSSARY.md and docs/adr/0003.
## Footprint is SIZE tiles from the origin (walls inside it), with a DOOR_WIDTH door socket
## at the centre of each side. N/S walls are WALL_HEIGHT rows deep (topper over wall).

enum Role { NORMAL, SPAWN, LADDER }

const SIZE := Vector2i(24, 16)
const DOOR_WIDTH := 2
const CORRIDOR_LENGTH := 4
const WALL_HEIGHT := 2
const TILE_SIZE := 16
## Top-left tile of the door gaps: x for the N/S sockets, y for the W/E ones.
const DOOR := (SIZE - Vector2i.ONE * DOOR_WIDTH) / 2
## Tiles from one grid cell's origin to the next: a Room plus a corridor.
const PITCH := SIZE + Vector2i.ONE * CORRIDOR_LENGTH
const WALL_LAYERS := ["BG_Walls", "BG_Toppers", "FG_Walls", "FG_Toppers"]

@export var role: Role


## The door gap cells of the socket on side `dir`, through the full wall depth.
static func socket_cells(dir: Vector2i) -> Array[Vector2i]:
	var last := SIZE - Vector2i.ONE
	var cells: Array[Vector2i] = []
	for i in DOOR_WIDTH:
		for d in (WALL_HEIGHT if dir.y != 0 else 1):
			match dir:
				Vector2i.UP: cells.append(Vector2i(DOOR.x + i, d))
				Vector2i.DOWN: cells.append(Vector2i(DOOR.x + i, last.y - d))
				Vector2i.LEFT: cells.append(Vector2i(0, DOOR.y + i))
				_: cells.append(Vector2i(last.x, DOOR.y + i))
	return cells


## Top-left tile of the grid cell `cell`, in Floor tiles.
static func cell_origin(cell: Vector2i) -> Vector2i:
	return cell * PITCH


## Pixel position of a Room placed in grid cell `cell`.
static func cell_position(cell: Vector2i) -> Vector2:
	return Vector2(cell_origin(cell) * TILE_SIZE)


func is_wall(cell: Vector2i) -> bool:
	return WALL_LAYERS.any(func(n): return find_child(n, true, false).get_cell_source_id(cell) != -1)


## Wall off the socket on side `dir` with copies of the wall beside it, on every layer.
func seal(dir: Vector2i) -> void:
	var beside := Vector2i.LEFT if dir.y != 0 else Vector2i.UP
	for layer: TileMapLayer in find_children("*", "TileMapLayer", true, false):
		# Cells run outward along the wall, so each copies one already sealed (or the frame).
		for tile in socket_cells(dir):
			var from := tile + beside
			layer.set_cell(tile, layer.get_cell_source_id(from), layer.get_cell_atlas_coords(from), layer.get_cell_alternative_tile(from))


func spawn_point() -> Vector2:
	return get_node("PlayerStart").global_position
