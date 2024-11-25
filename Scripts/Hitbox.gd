extends Area2D
class_name Hitbox

# Exported variables for damage and knockback force, which were previously on the Player
@export var axe_damage: int = 35
@export var knockback_force: int = 300

@onready var collision_shape: CollisionShape2D = get_child(0)  # Assuming it's the first child
var knockback_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	assert(collision_shape != null)
	monitoring = true  # Ensure the hitbox is monitoring bodies entering
	# Connect the body_entered signal to the _on_body_entered method
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Debug: Check the shape type and its size (for CapsuleShape2D)
	var shape = collision_shape.shape
	if shape is CapsuleShape2D:
		print("Hitbox is a Capsule, radius: ", shape.radius, " height: ", shape.height)

# Called when a body enters the hitbox area
func _on_body_entered(body: PhysicsBody2D) -> void:
	# Debug: Check what body is entering the hitbox
	print("Body entered hitbox: ", body.name)
	
	# Make sure the body has a `take_damage` method
	if body.has_method("take_damage"):
		print("Dealing damage to: ", body.name)
		
		# Calculate knockback direction
		knockback_direction = (body.global_position - global_position).normalized()
		print(knockback_direction)
		
		# Apply damage and knockback to the body
		body.take_damage(axe_damage, knockback_direction, knockback_force)
	else:
		print("Body doesn't have 'take_damage' method: ", body.name)
