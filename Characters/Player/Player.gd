extends Character

@onready var axe: Node2D = get_node("Axe")
@onready var axe_animation_player: AnimationPlayer = axe.get_node("WeaponAnimationPlayer")

# handle which way the character is facing based on the position of the cursor
func _process(delta: float) -> void:
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
		
	axe.rotation = mouse_direction.angle()
	if axe.scale.y == 1 and mouse_direction.x < 0:
		axe.scale.y = -1
	elif axe.scale.y == -1 and mouse_direction.x > 0:
		axe.scale.y = 1 
		
	if Input.is_action_just_pressed("attack") and not axe_animation_player.is_playing():
		axe_animation_player.play("attack")

# take in the input from the user
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
