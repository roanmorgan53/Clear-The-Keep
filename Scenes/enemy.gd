@icon("res://Assets/Art/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/goblin_idle_anim_f3.png")
extends Character

# TODO: Pathfiding for the enemy
# TODO: Find a way to animate damage

@export var player: Node2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D


var health: int = 100

func _ready() -> void:
	player = get_parent().find_child("Player")

func _physics_process(delta: float) -> void:
	var dir = to_local(navigation_agent_2d.get_next_path_position()).normalized()
	velocity = dir * acceleration
	
	# implement friction
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)
	move_and_slide()
	
func make_path() -> void:
	if (player.global_position):
		navigation_agent_2d.target_position = player.global_position
	print("Making path...")
	print("Player Pos = ", navigation_agent_2d.target_position)

func _on_timer_timeout() -> void:
	make_path()
	print("Attempting to make path")
