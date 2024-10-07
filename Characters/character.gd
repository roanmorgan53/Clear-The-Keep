extends CharacterBody2D
class_name Character

# script to animate the character with the given set of images
@onready var _animated_sprite = $AnimatedSprite2D
func _process(_delta):
	if Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		_animated_sprite.play("run")
		_animated_sprite.flip_h = false
		
	elif Input.is_action_pressed("left"):
		_animated_sprite.flip_h = true
		
	else:
		_animated_sprite.stop()

@export var speed = 100

func get_input():
	var input_direction = Input.get_vector("left", "right","up", "down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
