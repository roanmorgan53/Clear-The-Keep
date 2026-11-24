extends GutTest

const TitleScreen = preload("res://Scenes/start_screen.tscn")

var screen


func before_each():
	screen = add_child_autofree(TitleScreen.instantiate())


func test_title_is_shown_and_not_editable():
	var titles = screen.find_children("*", "Label", true, false).filter(
		func(l): return l.text == "Clear The Keep" and l.is_visible_in_tree())
	assert_eq(titles.size(), 1, "title label shown")
	assert_eq(screen.find_children("*", "TextEdit", true, false).size(), 0, "no TextEdit")
	assert_eq(screen.find_children("*", "LineEdit", true, false).size(), 0, "no LineEdit")


func _button(text):
	var found = screen.find_children("*", "Button", true, false).filter(func(b): return b.text == text)
	return found[0] if found.size() == 1 else null


func test_play_is_focused_on_open():
	assert_not_null(_button("Play"))
	assert_true(_button("Play").has_focus())


func test_play_requests_the_configured_game_scene():
	var doubled = partial_double(TitleScreen).instantiate()
	stub(doubled, "open_scene").to_do_nothing()
	doubled.game_scene = "res://Scenes/some_other.tscn"
	screen = add_child_autofree(doubled)
	_button("Play").pressed.emit()
	assert_called(doubled, "open_scene", ["res://Scenes/some_other.tscn"])


func test_play_defaults_to_the_game_scene():
	assert_eq(screen.game_scene, "res://Scenes/game.tscn")


func test_quit_requests_app_exit():
	var doubled = partial_double(TitleScreen).instantiate()
	stub(doubled, "quit_game").to_do_nothing()
	screen = add_child_autofree(doubled)
	_button("Quit").pressed.emit()
	assert_called(doubled, "quit_game")


func test_quit_is_visible_on_desktop():
	assert_true(_button("Quit").is_visible_in_tree())


func test_no_background_texture_still_fills_screen():
	assert_null(screen.background)
	var size = screen.get_viewport_rect().size
	var fills = screen.find_children("*", "ColorRect", true, false).filter(
		func(r): return r.is_visible_in_tree() and r.color.a == 1.0 and r.get_global_rect().size == size)
	assert_eq(fills.size(), 1, "opaque full-screen fallback shown")
	for t in screen.find_children("*", "TextureRect", true, false):
		assert_null(t.texture, "no texture shown when none is set")


func test_background_texture_fills_screen():
	var instance = TitleScreen.instantiate()
	instance.background = PlaceholderTexture2D.new()
	screen = add_child_autofree(instance)
	var shown = screen.find_children("*", "TextureRect", true, false).filter(
		func(t): return t.texture == instance.background and t.is_visible_in_tree())
	assert_eq(shown.size(), 1)
	assert_eq(shown[0].get_global_rect().size, screen.get_viewport_rect().size)
