extends GutTest

const SEED := 1234
const PITCH := Room.SIZE + Vector2i.ONE * Room.CORRIDOR_LENGTH
const WALL_LAYERS := ["BG_Walls", "BG_Toppers", "FG_Walls", "FG_Toppers"]

var game: Node
var builder: FloorBuilder


# The real game scene, built with a fixed seed.
func before_each():
	game = load("res://Scenes/game.tscn").instantiate()
	builder = game.find_children("*", "FloorBuilder", true, false)[0]
	builder.seed_override = SEED
	add_child_autofree(game)


func _room_at(cell: Vector2i) -> Room:
	for room in builder.find_children("*", "Room", true, false):
		if room.position == Vector2(cell * PITCH * 16):
			return room
	return null


func test_builds_the_layout_for_its_seed():
	assert_eq(builder.layout.cells.size(), builder.room_count)
	for cell in builder.layout.cells:
		var room := _room_at(cell)
		assert_not_null(room, "Room at %s" % cell)
		if room:
			assert_eq(room.scene_file_path, builder.layout.room_at[cell].resource_path, "Room at %s" % cell)


func test_player_starts_at_the_spawn_rooms_player_start():
	var spawn := _room_at(builder.layout.spawn_cell)
	assert_eq(spawn.role, Room.Role.SPAWN)
	var player: Node2D = game.get_node("Player")
	assert_eq(player.global_position, spawn.get_node("PlayerStart").global_position)


func _gap(dir: Vector2i) -> Array[Vector2i]:
	var last := Room.SIZE - Vector2i.ONE
	match dir:
		Vector2i.UP: return [Vector2i(11, 0), Vector2i(12, 0), Vector2i(11, 1), Vector2i(12, 1)]
		Vector2i.DOWN: return [Vector2i(11, last.y), Vector2i(12, last.y)]
		Vector2i.LEFT: return [Vector2i(0, 7), Vector2i(0, 8)]
		_: return [Vector2i(last.x, 7), Vector2i(last.x, 8)]


func test_sealed_sockets_are_wall():
	assert_gt(builder.layout.sealed.size(), 0)
	for entry in builder.layout.sealed:
		var room := _room_at(entry[0])
		for tile in _gap(entry[1]):
			var walled := WALL_LAYERS.any(func(n): return room.find_child(n, true, false).get_cell_source_id(tile) != -1)
			assert_true(walled, "%s socket %s walled at %s" % [entry[0], entry[1], tile])


func test_every_edge_has_corridor_floor():
	var floor: TileMapLayer = builder.get_node("Corridors/Floor")
	for edge in builder.layout.edges:
		var a: Vector2i = edge[0]
		var dir: Vector2i = edge[1] - a
		# The corridor's middle tile, in Floor tiles.
		var mid := a * PITCH + (Vector2i(Room.SIZE.x + 1, 7) if dir == Vector2i.RIGHT else Vector2i(11, Room.SIZE.y + 1))
		assert_ne(floor.get_cell_source_id(mid), -1, "corridor %s" % [edge])
