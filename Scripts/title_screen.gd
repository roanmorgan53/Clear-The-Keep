@tool
extends Control

## Full-screen background image. Leave empty for the plain dark fill.
## The later in-world title scene replaces the Background layer as a whole.
@export var background: Texture2D:
	set(value):
		background = value
		if is_node_ready():
			$Background.texture = value
## Scene the Play button opens to start a new Run.
@export_file("*.tscn") var game_scene := "res://Scenes/game.tscn"


static func quit_available(is_web: bool) -> bool:
	return not is_web


func _ready() -> void:
	$Background.texture = background
	if Engine.is_editor_hint():
		return
	$Center/Menu/Quit.visible = quit_available(OS.has_feature("web"))
	$Center/Menu/Play.grab_focus()


func _on_play_pressed() -> void:
	open_scene(game_scene)


func _on_quit_pressed() -> void:
	quit_game()


# The only tree-level calls; tests stub them so nothing really changes or quits.
func open_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)


func quit_game() -> void:
	get_tree().quit()
