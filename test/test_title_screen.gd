extends GutTest

const TitleScreen = preload("res://Scenes/title_screen.tscn")
const TitleScreenScript = preload("res://Scripts/title_screen.gd")

var screen


func before_each():
	screen = add_child_autofree(TitleScreen.instantiate())


func _find(type: String, matches: Callable = func(_node): return true) -> Array:
	return screen.find_children("*", type, true, false).filter(matches)


func _button(text: String) -> Button:
	var found = _find("Button", func(button): return button.text == text)
	return found[0] if found.size() == 1 else null


# Replaces `screen` with a partial double whose tree-level call is stubbed out.
func _screen_with_stubbed(method: String):
	var doubled = partial_double(TitleScreen).instantiate()
	stub(doubled, method).to_do_nothing()
	return doubled


func test_title_is_shown_and_not_editable():
	var titles = _find("Label", func(label): return label.text == "Clear The Keep" and label.is_visible_in_tree())
	assert_eq(titles.size(), 1, "title label shown")
	assert_eq(_find("TextEdit").size(), 0, "no TextEdit")
	assert_eq(_find("LineEdit").size(), 0, "no LineEdit")


func test_play_is_focused_on_open():
	assert_not_null(_button("Play"))
	assert_true(_button("Play").has_focus())


func test_play_requests_the_configured_game_scene():
	var doubled = _screen_with_stubbed("open_scene")
	doubled.game_scene = "res://Scenes/some_other.tscn"
	screen = add_child_autofree(doubled)
	_button("Play").pressed.emit()
	assert_called(doubled, "open_scene", ["res://Scenes/some_other.tscn"])


func test_play_defaults_to_the_game_scene():
	assert_eq(screen.game_scene, "res://Scenes/game.tscn")


func test_quit_requests_app_exit():
	var doubled = _screen_with_stubbed("quit_game")
	screen = add_child_autofree(doubled)
	_button("Quit").pressed.emit()
	assert_called(doubled, "quit_game")


func test_quit_is_visible_on_desktop():
	assert_true(_button("Quit").is_visible_in_tree())


func test_quit_is_shown_only_where_quitting_works():
	assert_true(TitleScreenScript.quit_available(false), "desktop shows Quit")
	assert_false(TitleScreenScript.quit_available(true), "Web hides Quit")


func test_no_background_texture_still_fills_screen():
	assert_null(screen.background)
	var size = screen.get_viewport_rect().size
	var fills = _find("ColorRect", func(rect): return rect.is_visible_in_tree() and rect.color.a == 1.0 and rect.get_global_rect().size == size)
	assert_eq(fills.size(), 1, "opaque full-screen fallback shown")
	for texture_rect in _find("TextureRect"):
		assert_null(texture_rect.texture, "no texture shown when none is set")


func test_background_texture_fills_screen():
	var instance = TitleScreen.instantiate()
	instance.background = PlaceholderTexture2D.new()
	screen = add_child_autofree(instance)
	var shown = _find("TextureRect", func(texture_rect): return texture_rect.texture == instance.background and texture_rect.is_visible_in_tree())
	assert_eq(shown.size(), 1)
	assert_eq(shown[0].get_global_rect().size, screen.get_viewport_rect().size)


func test_changing_background_after_open_updates_the_screen():
	var texture = PlaceholderTexture2D.new()
	screen.background = texture
	assert_eq(_find("TextureRect", func(texture_rect): return texture_rect.texture == texture).size(), 1)
