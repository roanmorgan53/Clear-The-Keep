@icon("res://Assets/Art/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/knight_f_idle_anim_f0.png")
extends Character

@onready var axe: Node2D = get_node("Axe")
@onready var axe_hitbox: Area2D = get_node("Axe/Node2D/Sprite2D/Hitbox")
@onready var axe_animation_player: AnimationPlayer = axe.get_node("WeaponAnimationPlayer")
@onready var sfx_footstep: AudioStreamPlayer2D = $sfx_footstep

var knockback_direction: Vector2 = Vector2.ZERO

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

	# Set knockback direction for the axe hitbox
	axe_hitbox.knockback_direction = mouse_direction
	
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

# Handle dealing damage to enemies (called during attack)
func _damage() -> void:
	# Iterate through all bodies in the axe hitbox's collision area
	for body in axe_hitbox.get_overlapping_bodies():
		print("Body in hitbox: ", body)  # Debug line to see which bodies are detected
		# Check if the body has a method `take_damage`
		if body.has_method("take_damage"):
			print("Damage dealt to: ", body)  # Debug line to confirm take_damage is called
			# Apply damage to the body (enemy)
			body.take_damage(10, axe_hitbox.knockback_direction, 300)  # Adjust damage, knockback force as needed
