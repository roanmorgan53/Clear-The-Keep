@icon("res://Assets/Art/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/knight_f_idle_anim_f0.png")
extends Character

@onready var axe: Node2D = get_node("Axe")
@onready var axe_hitbox: Area2D = get_node("Axe/Node2D/Sprite2D/Hitbox")
@onready var axe_animation_player: AnimationPlayer = axe.get_node("WeaponAnimationPlayer")
@onready var sfx_footstep: AudioStreamPlayer2D = $sfx_footstep
@export var enemy: Node2D

# Health Related
var max_health: int = 100
var current_health: int = max_health



func _physics_process(_delta: float) -> void:
	# Implement friction and movement
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)
	move_and_slide()

# Handle the facing direction of the character based on mouse position
func _process(_delta: float) -> void:
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	# Flip character sprite based on the mouse direction
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	
	# Set the axe's rotation to face the mouse
	axe.rotation = mouse_direction.angle()

	# Flip axe sprite based on the mouse direction
	if axe.scale.y == 1 and mouse_direction.x < 0:
		axe.scale.y = -1
	elif axe.scale.y == -1 and mouse_direction.x > 0:
		axe.scale.y = 1 
	
	# Play attack animation when the player presses the attack button
	if Input.is_action_just_pressed("attack") and not axe_animation_player.is_playing():
		axe_animation_player.play("attack")
		_damage()  # Call _damage when attack is pressed

# Handle movement input
func get_input() -> void:
	mov_direction = Vector2.ZERO
	if Input.is_action_pressed("down"):
		mov_direction += Vector2.DOWN
	if Input.is_action_pressed("left"):
		mov_direction += Vector2.LEFT
	if Input.is_action_pressed("up"):
		mov_direction += Vector2.UP
	if Input.is_action_pressed("right"):
		mov_direction += Vector2.RIGHT
		
func move_direction(direction) -> void:
	mov_direction += direction

# Play footstep sound when moving
func play_footstep() -> void:
	sfx_footstep.play()

# Flash red when the player takes damage
func flash_red() -> void:
	if get_tree():  # Check if the scene tree exists
		$AnimatedSprite2D.modulate = Color(1, 0, 0)  # Set sprite color to red
		await get_tree().create_timer(0.1).timeout  # Wait for 0.1 seconds
		$AnimatedSprite2D.modulate = Color(1, 1, 1)  # Reset sprite color to normal
	else:
		print("Error: SceneTree is unavailable.")

# Call this function when your character takes damage
func take_damage(dam: int, dir: Vector2, force: int) -> void:
	current_health -= dam
	velocity += dir * force  # Apply knockback using the direction and force passed in
	flash_red()  # Flash red when taking damage

	# If health is zero or below, trigger death
	if current_health <= 0:
		die()

# Handle dealing damage to enemies (called during attack)
func _damage() -> void:
	var overlapping_bodies = axe_hitbox.get_overlapping_bodies()
	if overlapping_bodies.size() == 0:
		print("No enemies detected in hitbox")
		return
	
	# Iterate over all overlapping bodies and apply damage through Hitbox
	for body in overlapping_bodies:
		if body.has_method("take_damage"):
			print("Dealing damage to: ", body.name)
			# Call the take_damage method on the body, but now handled in Hitbox
			body.take_damage()  # The damage is now handled inside the Hitbox script

	print("No valid enemies found to damage.")


# Death logic when health reaches 0
func die() -> void:
	print("You Died!")
	# Fully restart the project or call respawn logic
	# For example: get_tree().reload_current_scene()
