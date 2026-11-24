class_name FloorLayout
extends RefCounted
## A Floor's layout as plain data: which grid cells hold Rooms, how they connect,
## and which Room goes where. Built by generate() before any nodes exist.

# Match Room.Role order (NORMAL, SPAWN, LADDER).
const NORMAL := 0
const SPAWN := 1
const LADDER := 2
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

var cells: Array[Vector2i] = []
var edges: Array = []
var room_at: Dictionary = {}
var spawn_cell: Vector2i
var ladder_cell: Vector2i
var sealed: Array = []


static func generate(seed: int, rooms_by_role: Dictionary, room_count: int) -> FloorLayout:
	assert(room_count >= 2, "A Floor needs room for a Spawn Room and a Ladder Room")
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var layout := FloorLayout.new()
	layout.cells = _grow_cells(rng, room_count)
	layout.edges = _spanning_tree(rng, layout.cells)
	layout.spawn_cell = layout.cells[0]
	var distances := _distances(layout.edges, layout.spawn_cell)
	var farthest: int = distances.values().max()
	var candidates := layout.cells.filter(func(cell): return distances[cell] == farthest)
	layout.ladder_cell = candidates[rng.randi_range(0, candidates.size() - 1)]
	for cell in layout.cells:
		var role := NORMAL
		if cell == layout.spawn_cell:
			role = SPAWN
		elif cell == layout.ladder_cell:
			role = LADDER
		var choices: Array = rooms_by_role[role]
		layout.room_at[cell] = choices[rng.randi_range(0, choices.size() - 1)]
		for dir in DIRECTIONS:
			if [cell, cell + dir] not in layout.edges and [cell + dir, cell] not in layout.edges:
				layout.sealed.append([cell, dir])
	return layout


# A connected shape of `count` cells grown from (0, 0), which becomes the spawn cell.
static func _grow_cells(rng: RandomNumberGenerator, count: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = [Vector2i.ZERO]
	var frontier: Array[Vector2i] = []
	while cells.size() < count:
		frontier.clear()
		for cell in cells:
			for dir in DIRECTIONS:
				var next := cell + dir
				if next not in cells and next not in frontier:
					frontier.append(next)
		cells.append(frontier[rng.randi_range(0, frontier.size() - 1)])
	return cells


# Kruskal over every pair of neighbouring cells, taken in seeded random order,
# with a disjoint-set (union-find) to skip edges that would close a loop.
static func _spanning_tree(rng: RandomNumberGenerator, cells: Array[Vector2i]) -> Array:
	var candidates := []
	for cell in cells:
		for dir in [Vector2i.RIGHT, Vector2i.DOWN]:
			if cell + dir in cells:
				candidates.append([cell, cell + dir])
	# Fisher-Yates with our rng; Array.shuffle() uses the global one.
	for i in range(candidates.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap = candidates[i]
		candidates[i] = candidates[j]
		candidates[j] = swap

	var parent := {}
	for cell in cells:
		parent[cell] = cell
	var find := func(cell: Vector2i) -> Vector2i:
		while parent[cell] != cell:
			parent[cell] = parent[parent[cell]]
			cell = parent[cell]
		return cell

	var tree := []
	for edge in candidates:
		var a: Vector2i = find.call(edge[0])
		var b: Vector2i = find.call(edge[1])
		if a != b:
			parent[a] = b
			tree.append(edge)
	return tree


# Corridor steps from `start` to every cell, by breadth-first search over the tree.
static func _distances(edges: Array, start: Vector2i) -> Dictionary:
	var neighbours := {}
	for edge in edges:
		neighbours.get_or_add(edge[0], []).append(edge[1])
		neighbours.get_or_add(edge[1], []).append(edge[0])
	var distances := {start: 0}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for next in neighbours.get(cell, []):
			if next not in distances:
				distances[next] = distances[cell] + 1
				queue.append(next)
	return distances
