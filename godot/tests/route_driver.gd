extends RefCounted
## Fixed input route through the real level. No position/velocity edits.
##
## The first five marks are the starter's, unchanged, and still clear the starter's step,
## spikes and two gaps. Marks six to eleven were added for the Beacon Tower extension and
## were not guessed: each one sits inside the take-off window that tests/verify_reach.gd
## measured by sweeping the real player 2 px at a time. Measured windows, in order:
##   third slab -> approach   x 890..956   (mark 900)
##   approach -> pedestal     x 1010..1094 (mark 1020)
##   pedestal -> step one     x 1096..1162 (mark 1110)
##   step one -> step two     x 1212..1264 (mark 1220)
##   step two -> summit       x 1324..1376 (mark 1330)
##   summit -> over the gate  x 1408..1466 (mark 1420)
## The driver only ever holds right and presses jump, so it cannot stop or reverse. If a
## future edit makes a landing require backing up, this fixture will fail rather than
## silently paper over it.
var jump_marks: Array[float] = [138.0, 292.0, 424.0, 548.0, 712.0, 900.0, 1020.0, 1110.0, 1220.0, 1330.0, 1420.0]
var next_jump: int = 0

func step(player: CharacterBody2D) -> void:
	player.test_control = true
	player.test_axis = 1.0
	player.test_jump_held = false
	if next_jump < jump_marks.size() and player.position.x >= jump_marks[next_jump] and player.is_on_floor():
		player.test_jump_pressed = true
		next_jump += 1
