# Animation handling, and the transitions between them based on what is happening with input
extends Node
class_name FiniteStateMachine

# initialize relevant information needed to store states
var states: Dictionary = {}
var previous_state: int = -1
var internal_state: int = -1
var state: int:
	set(value):
		internal_state = value
	get:
		return internal_state

# make sure that the whole scene is loaded, then get the character and the animation player
@onready var parent : Character = get_parent()
@onready var animated_sprite: AnimatedSprite2D = parent.get_node("AnimatedSprite2D")

# practically the "main" function here, processes the state change
func _physics_process(delta: float) -> void:
	if state != -1:
		_state_logic(delta)
		var transition: int = _get_transition()
		if transition != -1:
			set_state(transition)

func _state_logic(_delta: float) -> void:
	pass

func _get_transition() -> int:
	return -1
	
func _add_state(new_state: String) -> void:
	states[new_state] = states.size()
	
func set_state(new_state: int) -> void:
	_exit_state(state)
	previous_state = state
	state = new_state
	_enter_state(previous_state, state)

func _enter_state(_previous_state: int, _new_state: int) -> void:
	pass

func _exit_state(_state_exited: int) -> void:
	pass
