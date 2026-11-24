extends GutTest

const SEED := 1234

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
		if room.position == Room.cell_position(cell):
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
	assert_eq(player.global_position, spawn.spawn_point())


func test_sealed_sockets_are_wall():
	assert_gt(builder.layout.sealed.size(), 0)
	for entry in builder.layout.sealed:
		var room := _room_at(entry[0])
		for tile in Room.socket_cells(entry[1]):
			assert_true(room.is_wall(tile), "%s socket %s walled at %s" % [entry[0], entry[1], tile])


func test_every_edge_has_corridor_floor():
	var floor: TileMapLayer = builder.get_node("Corridors/Floor")
	for edge in builder.layout.edges:
		var from: Vector2i = edge[0]
		var dir: Vector2i = edge[1] - from
		# Two tiles out from the socket's first gap cell, in Floor tiles.
		var mid := Room.cell_origin(from) + Room.socket_cells(dir)[0] + dir * 2
		assert_ne(floor.get_cell_source_id(mid), -1, "corridor %s" % [edge])
