extends Node2D 

@export var door: Node2D  # Reference to the door node
var enemies = []  # List to store enemies in the room

func _ready() -> void:
    # Get all enemies in the "enemies" group
    enemies = get_tree().get_nodes_in_group("enemies")

    # Connect to each enemy's "enemy_died" signal
    for enemy in enemies:
        if enemy.has_signal("enemy_died"):
            enemy.connect("enemy_died", self, "_on_enemy_died")

func _on_enemy_died() -> void:
    # Check if all enemies are dead
    if all_enemies_dead():
        open_door()

# check enemy death
# need to add whether door is open

