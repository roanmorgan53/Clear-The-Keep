extends Area2D
class_name Hitbox

# Export variables for damage and knockback force
@export var damage: int = 1
var knockback_direction: Vector2 = Vector2.ZERO
@export var knockback_force: int = 300

# The CollisionShape2D is assumed to be the first child of the Hitbox node
@onready var collision_shape: CollisionShape2D = get_child(0)

func _ready() -> void:
	assert(collision_shape != null)
	# Connect the body_entered signal to the _on_body_entered method
	connect("body_entered", Callable(self, "_on_body_entered"))

# Called when a body enters the hitbox area
func _on_body_entered(body: PhysicsBody2D) -> void:
	# Make sure the body has a `take_damage` method
	if body.has_method("take_damage"):
		body.take_damage(damage, knockback_direction, knockback_force)
