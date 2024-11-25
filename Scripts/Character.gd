@icon("res://Assets/Art/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/knight_m_idle_anim_f0.png")
extends CharacterBody2D
class_name Character

const FRICTION: float = 0.15
@export var acceleration: int = 20
@export var max_speed: int = 100



@onready var state_machine: Node = get_node("FiniteStateMachine")
@onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")

var mov_direction: Vector2 = Vector2.ZERO # vector initialized to zero

func move() -> void:
	mov_direction = mov_direction.normalized()
	velocity += mov_direction * acceleration
