extends SceneTree
## Renders BEACON in the six states the assignment asks to see: walking and standing
## in both directions, and airborne in both directions. Drives the real player with
## the same test_axis/test_jump_pressed hooks the mechanics suite uses, so these are
## engine-rendered frames of the actual game, not mock-ups.
##
## Captures happen on flat ground between the step at x=160..208 and the spikes at
## x=320, so nothing here touches a hazard or the finish.
const Game = preload("res://game/session.gd")
var game: Node2D
var output: String

func _initialize() -> void:
	call_deferred("run")

func step() -> void:
	await physics_frame
	await process_frame

func steps(n: int) -> void:
	for i in range(n):
		await step()

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(output + "/" + label + ".png")
	assert(error == OK)
	print("Captured rendered game viewport: %s  (player at %s, on_floor=%s, facing=%d)" % [
		label, game.player.position, game.player.is_on_floor(), int(game.player.facing)])

func settle_at(x: float) -> void:
	game.player.test_axis = 0.0
	game.player.position = Vector2(x, 320.0)
	game.player.velocity = Vector2.ZERO
	await steps(4)

func run() -> void:
	output = ProjectSettings.globalize_path("res://../evidence/screens/character")
	DirAccess.make_dir_recursive_absolute(output)
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	game.start_session()
	game.player.test_control = true
	await steps(3)

	await settle_at(250.0)
	game.player.test_axis = 1.0
	await steps(8)
	await capture("beacon-right-walking")

	game.player.test_axis = 0.0
	await steps(12)
	await capture("beacon-right-standing")

	await settle_at(250.0)
	game.player.test_axis = -1.0
	await steps(8)
	await capture("beacon-left-walking")

	game.player.test_axis = 0.0
	await steps(12)
	await capture("beacon-left-standing")

	await settle_at(250.0)
	game.player.test_axis = 1.0
	await steps(4)
	game.player.test_jump_pressed = true
	await steps(12)
	await capture("beacon-right-jumping")

	await settle_at(250.0)
	game.player.test_axis = -1.0
	await steps(4)
	game.player.test_jump_pressed = true
	await steps(12)
	await capture("beacon-left-jumping")

	print("BEACON STATES: 6 frames captured")
	game.queue_free()
	await process_frame
	quit()
