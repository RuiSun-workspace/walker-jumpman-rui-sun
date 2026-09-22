extends CharacterBody2D

const Tuning = preload("res://features/player/tuning.gd")
var tuning = Tuning.new()
var enabled: bool = false
var tick: int = 0
var last_floor_tick: int = -1000
var jump_request_tick: int = -1000
var opportunity_consumed: bool = false
var require_jump_release: bool = true
var facing: float = 1.0
var jumps: int = 0
var test_control: bool = false
var test_axis: float = 0.0
var test_jump_pressed: bool = false
var test_jump_held: bool = false
## Drawing state only. Set by the session on a fatal contact and cleared by reset_at().
## Nothing in _physics_process reads these, so they cannot affect movement or collision.
var dying: bool = false
var dying_tick: int = 0
## Impact feedback, drawing state only. Nothing here feeds movement or collision.
var was_on_floor: bool = true
var takeoff_tick: int = -1000
var land_tick: int = -1000
var land_impact: float = 0.0

func _ready() -> void:
	name = "Player"
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 1.0
	var shape := RectangleShape2D.new()
	shape.size = Vector2(18, 28)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	collider.position = Vector2(0, -14)
	add_child(collider)

func reset_at(spawn: Vector2) -> void:
	position = spawn
	velocity = Vector2.ZERO
	last_floor_tick = -1000
	jump_request_tick = -1000
	opportunity_consumed = false
	require_jump_release = true
	test_jump_pressed = false
	jumps = 0
	dying = false
	dying_tick = 0
	was_on_floor = true
	takeoff_tick = -1000
	land_tick = -1000
	land_impact = 0.0
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	tick += 1
	var axis := test_axis if test_control else Input.get_axis("move_left", "move_right")
	var held := test_jump_held if test_control else Input.is_action_pressed("jump")
	var pressed := test_jump_pressed if test_control else Input.is_action_just_pressed("jump")
	test_jump_pressed = false
	if not held:
		require_jump_release = false
	if is_on_floor() and velocity.y >= 0.0:
		last_floor_tick = tick
		opportunity_consumed = false
	if pressed and not require_jump_release:
		jump_request_tick = tick
	var rate: float = tuning.acceleration if not is_zero_approx(axis) else tuning.deceleration
	velocity.x = move_toward(velocity.x, axis * tuning.speed, rate * delta)
	if not is_zero_approx(axis):
		facing = signf(axis)
	velocity.y = minf(velocity.y + tuning.gravity * delta, tuning.terminal_velocity)
	if not opportunity_consumed and tick - last_floor_tick <= tuning.coyote_ticks and tick - jump_request_tick <= tuning.buffer_ticks:
		velocity.y = tuning.jump_velocity
		opportunity_consumed = true
		jump_request_tick = -1000
		jumps += 1
	# Fall speed has to be sampled before move_and_slide resolves the landing and zeroes it.
	var approach_speed := velocity.y
	move_and_slide()
	# Drawing state only. Read in _draw() for dust and squash; never read back by physics.
	var grounded := is_on_floor()
	if was_on_floor and not grounded:
		takeoff_tick = tick
	elif not was_on_floor and grounded:
		land_tick = tick
		land_impact = clampf(approach_speed / tuning.terminal_velocity, 0.0, 1.0)
	was_on_floor = grounded
	position.x = maxf(position.x, 10.0)
	queue_redraw()

## BEACON: a one-eyed lighthouse robot. Original Godot vector drawing, no imported art.
## The collider is an 18x28 box at offset (0,-14), so local space is x[-9,9] y[-28,0].
## Every opaque part below stays inside that box. The only thing that leaves it is the
## projected light cone, drawn translucent so it reads as emitted light, not as body.
func _draw() -> void:
	var ink := Color("25354a")
	var wrecked := dying
	var steel := Color("55626d") if wrecked else Color("6d7f8e")
	var steel_hi := Color("7d8b95") if wrecked else Color("9fb1bd")
	var lamp := Color("ffc94a")
	var lamp_hot := Color("fff6d8")
	var airborne := not is_on_floor()
	var rolling := not wrecked and is_on_floor() and absf(velocity.x) > 8
	var stride := sin(float(tick) * 0.7) * 2.0 if rolling else 0.0
	var eye := Vector2(facing * 1.8, -19.5)  # y is adjusted for squash once it is known
	# Death is drawn by killing the lamp, because the lamp is the whole identity: the cone
	# goes out, the eye drops to a dim red that flickers on a three-tick beat, and the
	# antenna folds over. Not one of these moves the silhouette, so the art still matches
	# the collider on the frame Beacon dies.
	var flicker := wrecked and (dying_tick / 3) % 2 == 0
	# Landing squash. The bottom edge never moves -- only the upper body compresses, so the
	# edge the player actually reads for a landing still matches the collider exactly.
	var since_land := tick - land_tick
	var squash := 0.0
	if not wrecked and since_land >= 0 and since_land < 6:
		squash = (1.0 - float(since_land) / 6.0) * 2.5 * land_impact
	eye.y += squash * 0.85
	var eye_colour := Color("ffe08a") if airborne else lamp
	if not wrecked and since_land >= 0 and since_land < 5 and land_impact > 0.45:
		eye_colour = Color("fff6d8")
	if wrecked:
		eye_colour = Color("8d3a34") if flicker else Color("3b2f33")

	# The tracks tuck up on a jump, so the hull has to be drawn down to meet them or
	# the body reads as floating above a detached base.
	var base_top := -4.0 if airborne else -6.0

	# Light cone. Widens and reaches further while airborne; purely decorative.
	if not wrecked:
		var reach := 22.0 if airborne else 16.0
		var spread := 8.0 if airborne else 5.5
		draw_colored_polygon(PackedVector2Array([eye,
			Vector2(eye.x + facing * reach, eye.y - spread),
			Vector2(eye.x + facing * reach, eye.y + spread)]), Color(1.0, 0.79, 0.29, 0.13))

	# Track dust on take-off and on landing. Effects, not body: like the light cone these
	# are allowed outside the collider box, and they are translucent so they never read as
	# something Beacon can stand on.
	if not wrecked:
		for phase in [tick - takeoff_tick, since_land]:
			if phase >= 0 and phase < 8:
				var t := float(phase) / 8.0
				var fade := (1.0 - t) * 0.32
				draw_circle(Vector2(-7.0 - t * 6.0, -1.5), 2.0 + t * 6.5, Color(0.42, 0.47, 0.45, fade))
				draw_circle(Vector2(7.0 + t * 6.0, -1.5), 1.6 + t * 5.5, Color(0.42, 0.47, 0.45, fade))

	# Antenna: trails behind the facing direction, straightens up on a jump. Skipped while
	# wrecked, where a snapped version is drawn after the housing instead -- folding it here
	# just hid it behind the housing, which is drawn later.
	if not wrecked:
		var tip := Vector2((-facing * 0.9 if airborne else -facing * 3.0) + stride * 0.5, -26.5)
		draw_line(Vector2(0, -23.0), tip, ink, 2.0)
		draw_circle(tip, 1.5, lamp_hot if airborne else steel_hi)

	# Lamp housing, tapered outward toward the base like a lighthouse gallery. Squash drops
	# the upper body; the further above the tracks a point is, the more it moves.
	var hi := squash
	var mid := squash * 0.6
	draw_colored_polygon(PackedVector2Array([Vector2(-6,-24+hi), Vector2(6,-24+hi), Vector2(7,-15+mid), Vector2(-7,-15+mid)]), ink)
	draw_colored_polygon(PackedVector2Array([Vector2(-5,-23+hi), Vector2(5,-23+hi), Vector2(6,-16+mid), Vector2(-6,-16+mid)]), steel)

	# The single eye. Its offset and pupil are the primary left/right facing cue.
	draw_circle(eye, 4.2, ink)
	draw_circle(eye, 3.4, eye_colour)
	draw_circle(Vector2(eye.x + facing * 1.0, eye.y), 1.5, ink)
	if not wrecked:
		draw_circle(Vector2(eye.x - facing * 1.4, eye.y - 1.4), 0.9, lamp_hot)
	else:
		# Snapped mast, hinged backwards over the housing. Drawn last so it reads as broken
		# rather than disappearing behind the gallery, and its tip stays inside x[-9,9].
		var hinge := Vector2(-facing * 3.5, -20.0)
		var snapped := Vector2(-facing * 7.4, -16.6)
		draw_line(Vector2(0, -23.0), hinge, ink, 2.0)
		draw_line(hinge, snapped, ink, 2.0)
		draw_circle(snapped, 1.4, steel_hi)

	# Collar and tapered hull. The hull bottom follows base_top so the two always meet.
	draw_rect(Rect2(-8, -15 + mid, 16, 2), ink)
	draw_colored_polygon(PackedVector2Array([Vector2(-6,-14+mid), Vector2(6,-14+mid), Vector2(8.5,base_top), Vector2(-8.5,base_top)]), ink)
	draw_colored_polygon(PackedVector2Array([Vector2(-5,-13+mid), Vector2(5,-13+mid), Vector2(7.2,base_top-1), Vector2(-7.2,base_top-1)]), steel)
	draw_rect(Rect2(-2, -12 + mid * 0.5, 4, 2), Color("5a4340") if wrecked else lamp)

	# Tracked base. The top edge tucks up on a jump, but the bottom edge stays on y=0
	# so the drawn silhouette always ends exactly where the collider ends.
	draw_rect(Rect2(-9, base_top, 18, -base_top), ink)
	draw_rect(Rect2(-8, base_top + 1, 16, -base_top - 2), steel)
	# Tread marks scroll against the direction of travel, so reversing visibly reverses the
	# tracks. Driven by position.x rather than tick, and geared down to roughly 7 Hz at full
	# speed to match the starter's leg cadence: pinning them to world x for true rolling
	# without slipping cycles a 5 px pattern at 32 Hz, which just strobes.
	var roll: float = 0.0 if airborne else fposmod(-position.x * 0.22, 5.0)
	# Four marks are stepped through a 20 px cycle but only the 15 px window [-7.5, 7.5]
	# is inside the hull, so the one that has wrapped is skipped rather than drawn beside
	# Beacon as a detached line.
	for i in range(4):
		var tx: float = -12.5 + float(i) * 5.0 + roll
		if tx < -7.5 or tx > 7.5:
			continue
		draw_line(Vector2(tx, base_top + 1.5), Vector2(tx, -1.5), ink, 1.0)
	# The leading drive sprocket is the larger of the two hubs and carries the hub pin, so
	# the tracks still read left or right while Beacon is standing still between jumps.
	var hub_y := base_top / 2.0
	var drive := 2.4 if not airborne else 1.7
	var idler := 1.5 if not airborne else 1.1
	draw_circle(Vector2(-5.0, hub_y), drive if facing < 0 else idler, steel_hi)
	draw_circle(Vector2(5.0, hub_y), drive if facing > 0 else idler, steel_hi)
	draw_circle(Vector2(facing * 5.0, hub_y), 0.8, ink)
