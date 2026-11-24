class_name Room
extends Node2D
## A hand-built Room that fills one Floor grid cell. See GLOSSARY.md and docs/adr/0002.
## Footprint is SIZE tiles from the origin (walls inside it), with a DOOR_WIDTH door socket
## at the centre of each side: N/S gaps at x = 11..12, W/E gaps at y = 7..8.

enum Role { NORMAL, SPAWN, LADDER }

const SIZE := Vector2i(24, 16)
const DOOR_WIDTH := 2
const CORRIDOR_LENGTH := 4

@export var role: Role
