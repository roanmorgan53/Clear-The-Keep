@icon("res://Assets/Art/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/goblin_idle_anim_f3.png")
extends Character

@export var player: Node2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D



# Health Related
var max_health: int = 100
var current_health: int = max_health
# Damage Properties
@export var damage_amount: int = 10
@export var knockback: int = 100  # Increased knockback force
var damage_cooldown: float = 1.0  # Cooldown time between damages
var can_damage: bool = true

func _ready() -> void:
	player = get_parent().get_parent().find_child("Player")
	
	if player:
		print("Player node found and assigned")
	else:
		print("Player node not found; make sure it's named correctly in the scene")

func _physics_process(_delta: float) -> void:
	# Pathfinding movement
	if player:
		var dir = to_local(navigation_agent_2d.get_next_path_position()).normalized()
		velocity = dir * acceleration
		
		# Implement friction
		velocity = lerp(velocity, Vector2.ZERO, FRICTION)
		move_and_slide()
		
		# Check for collision or proximity with player
		if global_position.distance_to(player.global_position) < 20:  # Adjust proximity range
			damage_player()

func make_path() -> void:
	navigation_agent_2d.target_position = player.global_position

func _on_timer_timeout() -> void:
	make_path()

func damage_player() -> void:
	# Check if damage can be applied
	if can_damage and player.has_method("take_damage"):
		# Calculate knockback direction (from enemy to player)
		var knockback_direction = (player.global_position - global_position).normalized()
		
		# Apply damage and knockback to the player
		player.take_damage(damage_amount, knockback_direction, knockback)
		can_damage = false  # Disable damage temporarily
		start_damage_cooldown()

func start_damage_cooldown() -> void:
	await get_tree().create_timer(damage_cooldown).timeout
	can_damage = true
	
func flash_red() -> void:
	$AnimatedSprite2D.modulate = Color(1, 0, 0)  # Set the sprite color to red
	await get_tree().create_timer(0.1).timeout  # Wait 0.1 seconds
	$AnimatedSprite2D.modulate = Color(1, 1, 1)  # Reset the sprite color to normal

# Call this function when your character takes damage
func take_damage(dam: int, dir: Vector2, force: int) -> void:
	current_health -= dam
	velocity += dir * force  # Apply knockback using the direction and force passed in
	flash_red()  # Flash red when taking damage

	# If health is zero or below, trigger death
	if current_health <= 0:
		die()


func die() -> void:
	queue_free()
	print("Enemy Died!")
