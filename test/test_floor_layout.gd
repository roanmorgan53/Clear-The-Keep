extends GutTest

# Role ints match Room.Role order: 0 NORMAL, 1 SPAWN, 2 LADDER.
const NORMAL := 0
const SPAWN := 1
const LADDER := 2
const ROOMS := {
	NORMAL: ["two_way", "smiley_pits", "big_zombie"],
	SPAWN: ["spawn"],
	LADDER: ["ladder"],
}
const SEEDS := 200
const ROOM_COUNT := 8


func _layouts(room_count := ROOM_COUNT) -> Array:
	var layouts := []
	for s in SEEDS:
		layouts.append(FloorLayout.generate(s, ROOMS, room_count))
	return layouts


func test_floor_has_the_requested_number_of_rooms():
	for count in [2, 5, 12]:
		for layout in _layouts(count):
			assert_eq(layout.cells.size(), count)
			assert_eq(layout.room_at.size(), count)


func test_one_spawn_room_and_one_ladder_room_and_the_rest_normal():
	for layout in _layouts():
		var roles := {NORMAL: 0, SPAWN: 0, LADDER: 0}
		for cell in layout.cells:
			for role in ROOMS:
				if layout.room_at[cell] in ROOMS[role]:
					roles[role] += 1
		assert_eq(roles, {NORMAL: ROOM_COUNT - 2, SPAWN: 1, LADDER: 1})
		assert_eq(layout.room_at[layout.spawn_cell], "spawn")
		assert_eq(layout.room_at[layout.ladder_cell], "ladder")


# Corridor steps from the Spawn Room to every Room reachable from it.
func _steps_from_spawn(layout) -> Dictionary:
	var steps := {layout.spawn_cell: 0}
	var queue := [layout.spawn_cell]
	while not queue.is_empty():
		var cell = queue.pop_front()
		for edge in layout.edges:
			for i in 2:
				if edge[i] == cell and edge[1 - i] not in steps:
					steps[edge[1 - i]] = steps[cell] + 1
					queue.append(edge[1 - i])
	return steps


func test_every_room_is_reachable_from_the_spawn_room():
	for layout in _layouts():
		var reached: Array = _steps_from_spawn(layout).keys()
		reached.sort()
		var cells: Array = layout.cells.duplicate()
		cells.sort()
		assert_eq(reached, cells)


func test_connections_form_a_tree():
	# Connected (above) with room count minus one edges means no loops.
	for layout in _layouts():
		assert_eq(layout.edges.size(), ROOM_COUNT - 1)


func test_every_edge_joins_grid_neighbours_on_the_floor():
	for layout in _layouts():
		for edge in layout.edges:
			assert_has(layout.cells, edge[0])
			assert_has(layout.cells, edge[1])
			var gap: Vector2i = (edge[1] - edge[0]).abs()
			assert_true(gap == Vector2i(1, 0) or gap == Vector2i(0, 1), "%s is not a neighbour pair" % [edge])


func test_ladder_room_is_farthest_from_the_spawn_room():
	for layout in _layouts():
		var steps: Dictionary = _steps_from_spawn(layout)
		assert_eq(steps[layout.ladder_cell], steps.values().max())


func test_same_seed_gives_the_same_layout():
	for s in 50:
		var a = FloorLayout.generate(s, ROOMS, ROOM_COUNT)
		var b = FloorLayout.generate(s, ROOMS, ROOM_COUNT)
		assert_eq(a.cells, b.cells)
		assert_eq(a.edges, b.edges)
		assert_eq(a.room_at, b.room_at)
		assert_eq(a.ladder_cell, b.ladder_cell)
		assert_eq(a.sealed, b.sealed)


func test_different_seeds_give_more_than_one_layout():
	var distinct := {}
	for layout in _layouts():
		distinct[var_to_str([layout.cells, layout.edges, layout.room_at])] = true
	assert_gt(distinct.size(), 1)


func test_every_socket_is_joined_by_a_corridor_or_sealed():
	var sides := [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	for layout in _layouts():
		var joined := {}
		for edge in layout.edges:
			joined[[edge[0], edge[1] - edge[0]]] = true
			joined[[edge[1], edge[0] - edge[1]]] = true
		var sealed := {}
		for socket in layout.sealed:
			assert_false(joined.has(socket), "%s is sealed but has a corridor" % [socket])
			sealed[socket] = true
		assert_eq(sealed.size(), layout.sealed.size(), "no socket is sealed twice")
		for cell in layout.cells:
			for side in sides:
				assert_true(joined.has([cell, side]) or sealed.has([cell, side]), "%s %s is left open" % [cell, side])
