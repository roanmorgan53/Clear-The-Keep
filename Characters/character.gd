extends CharacterBody2D
class_name Character

const FRICTION: float = 0.15

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var acceleration = 40
var max_speed = 100

var mov_direction: Vector2 = Vector2.ZERO
var velocity1: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	velocity1 = lerp(velocity1, Vector2.ZERO, FRICTION)
	move_and_slide()

func move() -> void:
	mov_direction = mov_direction.normalized()
	velocity += mov_direction * acceleration
	
