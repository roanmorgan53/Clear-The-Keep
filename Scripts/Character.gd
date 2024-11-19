@icon("res://Assets/Art/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/knight_m_idle_anim_f0.png")
extends CharacterBody2D
class_name Character

# Add variables that will assist with the physics of moving the character
const FRICTION: float = 0.15
@export var acceleration: int = 20
@export var max_speed: int = 100

@onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")

var mov_direction: Vector2 = Vector2.ZERO # vector initialized to zero

func move() -> void:
	mov_direction = mov_direction.normalized()
	velocity += mov_direction * acceleration

# A function to flash red
func flash_red() -> void:
	$AnimatedSprite2D.modulate = Color(1, 0, 0)  # Set the sprite color to red
	await get_tree().create_timer(0.1).timeout  # Wait 0.1 seconds
	$AnimatedSprite2D.modulate = Color(1, 1, 1)  # Reset the sprite color to normal

# Call this function when your character takes damage
func take_damage(amount) -> void:
	# Process damage (e.g., reduce health)
	flash_red()  # Flash red to indicate damage
