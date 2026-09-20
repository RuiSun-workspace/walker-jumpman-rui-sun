extends SceneTree
## Measures, rather than assumes, whether every jump in the level is reachable.
##
## For each jump it sweeps the take-off x position in 2 px steps, runs the REAL player
## through _physics_process with the shipped tuning, and records where it actually ended
## up. No tuning value is read or written here, so a level that only passes because the
## jump was strengthened cannot pass this check.
##
## Output: a per-jump take-off window. A window of zero means the geometry is wrong and
## the geometry has to change -- that is the whole point of running this before shipping.
const Game = preload("res://game/session.gd")
var game: Node2D
var rows: Array = []
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func step() -> void:
	await physics_frame
	await process_frame

## Drops the player at `from` already at full running speed and immediately jumps.
## Returns what actually happened: landed / missed / died / wrong-height.
func attempt(from: Vector2, target: Rect2) -> String:
	if game.state != Game.State.PLAYING:
		game.restart_attempt()
		for i in range(4):
			await step()
	var p: CharacterBody2D = game.player
	p.reset_at(from)
	p.test_control = true
	p.test_axis = 1.0
	p.test_jump_held = false
	p.require_jump_release = false
	p.velocity = Vector2(160.0, 0.0)
	p.last_floor_tick = p.tick
	p.opportunity_consumed = false
	p.test_jump_pressed = true
	var airborne := false
	for i in range(140):
		await step()
		# COMPLETE is not a failure. Touching the goal ends the run just like dying ends
		# the run, and conflating the two made the summit jump read as 36/36 fatal.
		if game.state == Game.State.COMPLETE:
			return "finished"
		if game.state != Game.State.PLAYING:
			return "died"
		if not p.is_on_floor():
			airborne = true
		elif airborne:
			break
	if not airborne:
		return "never-left-ground"
	var pos: Vector2 = p.position
	if absf(pos.y - target.position.y) > 1.5:
		return "wrong-height"
	if pos.x < target.position.x - 9.0 or pos.x > target.end.x + 9.0:
		return "missed"
	return "landed"

func sweep(label: String, from_y: float, x0: float, x1: float, target: Rect2) -> void:
	var hits: Array[float] = []
	var died := 0
	var finished := 0
	var x := x0
	while x <= x1:
		var result: String = await attempt(Vector2(x, from_y), target)
		if result == "landed" or result == "finished":
			hits.append(x)
			if result == "finished":
				finished += 1
		elif result == "died":
			died += 1
		x += 2.0
	var row := {"jump": label, "target": str(target), "samples_2px": int((x1 - x0) / 2.0) + 1,
		"landed": hits.size(), "reached_goal": finished, "fatal_samples": died}
	if hits.is_empty():
		row["window"] = "NONE - unreachable"
		row["status"] = "FAIL"
		failures += 1
	else:
		row["window"] = "x %.0f..%.0f (%.0f px)" % [hits[0], hits[-1], hits[-1] - hits[0] + 2.0]
		row["contiguous"] = hits.size() == int((hits[-1] - hits[0]) / 2.0) + 1
		row["status"] = "PASS"
	rows.append(row)
	print(JSON.stringify(row))

func run() -> void:
	game = Game.new()
	game.test_mode = true
	root.add_child(game)
	game.start_session()
	game.player.test_control = true
	for i in range(3):
		await step()

	# Original section, unchanged geometry: the two starter gaps must still be crossable.
	await sweep("starter gap 1: ground -> second slab", 320.0, 380.0, 446.0, Rect2(512, 320, 224, 64))
	await sweep("starter gap 2: second slab -> third slab", 320.0, 660.0, 734.0, Rect2(784, 320, 176, 64))

	# Beacon Tower extension.
	await sweep("tower 0: third slab -> approach", 320.0, 850.0, 956.0, Rect2(1008, 320, 168, 64))
	await sweep("tower 1: approach -> pedestal", 320.0, 1010.0, 1094.0, Rect2(1104, 296, 72, 24))
	await sweep("tower 2: pedestal -> step one", 296.0, 1096.0, 1184.0, Rect2(1192, 280, 64, 16))
	await sweep("tower 3: step one -> step two", 280.0, 1186.0, 1264.0, Rect2(1304, 240, 64, 16))
	await sweep("tower 4: step two -> summit", 240.0, 1298.0, 1376.0, Rect2(1416, 200, 248, 16))
	await sweep("tower 5: summit -> over the beacon gate", 200.0, 1400.0, 1470.0, Rect2(1504, 200, 160, 16))

	# The chasm must NOT be crossable at ground level: no take-off from the approach may
	# end alive on flat ground past the lip at x=1176. If one does, the tower is optional
	# and the extension is not actually gating the finish. The target passed here is the
	# ground strip that WOULD exist across the chasm; "landed" means the gate leaked.
	# It starts at 1200, not 1176, because attempt() allows a 9 px collider overhang and
	# the approach itself ends at 1176 -- landing back home was being counted as a leak.
	var survived := 0
	var samples := 0
	var x := 1010.0
	while x <= 1166.0:
		var r: String = await attempt(Vector2(x, 320.0), Rect2(1200, 320, 400, 64))
		samples += 1
		if r == "landed":
			survived += 1
		x += 4.0
	var gate := {"jump": "chasm is not walkable", "samples_4px": samples, "reached_far_side_on_foot": survived,
		"status": "PASS" if survived == 0 else "FAIL"}
	if survived != 0:
		failures += 1
	rows.append(gate)
	print(JSON.stringify(gate))

	var report := {"scope": "Take-off window measurement with shipped tuning; not a human playtest",
		"engine": Engine.get_version_info().string,
		"tuning": {"speed": 160, "jump_velocity": -320, "gravity": 960, "coyote_ticks": 6, "buffer_ticks": 6},
		"created_at": Time.get_datetime_string_from_system(true), "results": rows, "failures": failures}
	var out := ProjectSettings.globalize_path("res://../evidence")
	DirAccess.make_dir_recursive_absolute(out)
	var file := FileAccess.open(out + "/reach-" + str(Time.get_unix_time_from_system()) + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	print("REACH CHECK: %d jumps / %d failures" % [rows.size(), failures])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
