@icon("res://Art/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/knight_m_idle_anim_f0.png")
extends CharacterBody2D
class_name Character

# Add variables that will assist with the physics of moving the character
const FRICTION: float = 0.1
@export var acceleration: int = 20
@export var max_speed: int = 100

@onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")

var mov_direction: Vector2 = Vector2.ZERO # vector initialized to zero

func _physics_process(delta: float) -> void:
	# implement friction
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)
	move_and_slide()

func move() -> void:
	mov_direction = mov_direction.normalized()
	velocity += mov_direction * acceleration
	
