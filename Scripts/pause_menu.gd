extends Control

var is_pause_menu_active = false  # Tracks whether the pause menu is active

func ready():
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	is_pause_menu_active = false  # Pause menu is no longer active

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	is_pause_menu_active = true  # Pause menu is now active

func testEsc():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()

func _on_resume_pressed():
	if is_pause_menu_active:  # Only works if the pause menu is active
		resume()

func _on_restart_pressed():
	if is_pause_menu_active:  # Only works if the pause menu is active
		get_tree().paused = false  # Ensure the game is unpaused
		$AnimationPlayer.stop()  # Stop any active animations
		$AnimationPlayer.play("RESET")  # Reset the animation to the default state
		get_tree().reload_current_scene()

func _on_quit_pressed():
	if is_pause_menu_active:  # Only works if the pause menu is active
		get_tree().quit()

func _process(delta):
	testEsc()
