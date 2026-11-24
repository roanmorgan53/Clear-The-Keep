extends GutTest

const ROOMS := {
	"res://Scenes/spawn_room.tscn": 1,
	"res://Scenes/two_way_room.tscn": 0,
	"res://Scenes/smiley_pits_room.tscn": 0,
	"res://Scenes/big_zombie_room.tscn": 0,
	"res://Scenes/ladder_room.tscn": 2,
}
const TEMPLATE := "res://Scenes/room_template.tscn"


# Every Room plus the template a designer copies to make a new one.
func _shaped() -> Array:
	return ROOMS.keys() + [TEMPLATE]


func test_room_template_is_a_room():
	assert_true(_room(TEMPLATE) is Room)


func _room(path: String) -> Node:
	return add_child_autofree(load(path).instantiate())


func test_every_room_declares_its_role():
	for path in ROOMS:
		var room = _room(path)
		assert_true(room is Room, path)
		assert_eq(room.role, ROOMS[path], path)


func _layers(room: Node) -> Array:
	return room.find_children("*", "TileMapLayer", true, false)


func test_every_room_fills_exactly_its_footprint():
	for path in _shaped():
		var used := Rect2i()
		for layer in _layers(_room(path)):
			if layer.get_used_cells().size() > 0:
				used = layer.get_used_rect() if used.size == Vector2i.ZERO else used.merge(layer.get_used_rect())
		assert_eq(used, Rect2i(Vector2i.ZERO, Room.SIZE), path)


func test_enemy_finds_the_player_by_group_wherever_it_sits():
	var player = add_child_autofree(load("res://Scenes/Player.tscn").instantiate())
	assert_true(player.is_in_group("player"))
	var room = _room("res://Scenes/two_way_room.tscn")
	var enemies = room.find_children("*", "CharacterBody2D", true, false)
	assert_gt(enemies.size(), 0)
	for enemy in enemies:
		assert_eq(enemy.player, player)


func _enemies(room: Node) -> Array:
	return room.find_children("*", "CharacterBody2D", true, false)


func test_spawn_room_has_a_player_start_and_no_enemies():
	var room = _room("res://Scenes/spawn_room.tscn")
	var start = room.get_node_or_null("PlayerStart")
	assert_true(start is Marker2D)
	if start:
		assert_true(_is_open_floor(room, Vector2i(start.position / 16.0)), "PlayerStart on floor")
	assert_eq(_enemies(room).size(), 0)


const LADDER := Vector2i(3, 6)  # floor_ladder in the 0x72 sheet (source 3)


func test_ladder_room_shows_a_ladder_and_has_no_enemies():
	var room = _room("res://Scenes/ladder_room.tscn")
	var ladders := []
	for layer in _layers(room):
		ladders += layer.get_used_cells_by_id(3, LADDER)
	assert_eq(ladders.size(), 1)
	for cell in ladders:
		assert_true(_is_open_floor(room, cell), "ladder on floor")
	assert_eq(_enemies(room).size(), 0)


func test_normal_rooms_start_their_enemies_on_floor_inside_the_room():
	for path in ROOMS:
		if ROOMS[path] != Room.Role.NORMAL: continue
		var room = _room(path)
		assert_gte(_enemies(room).size(), 3, path)
		for enemy in _enemies(room):
			var cell := Vector2i((enemy.position / 16.0).floor())
			assert_true(_is_open_floor(room, cell), "%s %s on floor at %s" % [path, enemy.name, cell])
			assert_eq(room.find_child("Void", true, false).get_cell_source_id(cell), -1, "%s %s not in a pit" % [path, enemy.name])


func _is_open_floor(room: Room, cell: Vector2i) -> bool:
	return room.find_child("Floor", true, false).get_cell_source_id(cell) != -1 and not room.is_wall(cell)


func test_every_room_has_four_open_door_sockets_framed_by_wall():
	assert_eq(Room.DOOR_WIDTH, 2)
	for path in _shaped():
		var room = _room(path)
		for dir in FloorLayout.DIRECTIONS:
			var socket := Room.socket_cells(dir)
			for cell in socket:
				assert_true(_is_open_floor(room, cell), "%s %s socket open at %s" % [path, dir, cell])
				# Along the wall, either side of the gap.
				var along := Vector2i(abs(dir.y), abs(dir.x))
				for frame in [cell - along, cell + along]:
					if frame not in socket:
						assert_true(room.is_wall(frame), "%s %s socket framed at %s" % [path, dir, frame])


# ADR-0003: N/S gaps at x = 11..12 through the two-row wall, W/E gaps at y = 7..8.
func test_door_sockets_sit_at_the_centre_of_each_side():
	var expected := {
		Vector2i.UP: [Vector2i(11, 0), Vector2i(11, 1), Vector2i(12, 0), Vector2i(12, 1)],
		Vector2i.DOWN: [Vector2i(11, 14), Vector2i(11, 15), Vector2i(12, 14), Vector2i(12, 15)],
		Vector2i.LEFT: [Vector2i(0, 7), Vector2i(0, 8)],
		Vector2i.RIGHT: [Vector2i(23, 7), Vector2i(23, 8)],
	}
	for dir in expected:
		var cells := Room.socket_cells(dir)
		cells.sort()
		assert_eq(cells, expected[dir], "socket %s" % dir)
