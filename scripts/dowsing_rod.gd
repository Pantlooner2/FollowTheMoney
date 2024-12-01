class_name DowsingRod
extends Tool

var target_item : GameManager.ITEM_NAME
var all_targets : Array[Node2D]
var current_target : Node2D
var target_dir : Vector2
var prev_rot
var hint_potency : float = 0
var bounce_enabled : bool = true
var min_timer = 2.0
var max_timer = 10.0

var max_tilt : float = 2 * PI
var max_move_skew : float = 15

@onready var rand_timer = $RandomEffectAttemptTimer

func _physics_process(delta):
	if current_target != null:
		target_dir = (GameManager.player.global_position - current_target.global_position).normalized()
	else:
		target_dir = Vector2.ZERO
	if GameManager.player.still:
		var stick_rot = self.global_rotation
		var target_rot = (-target_dir).angle()
		var stick_dir = Vector2(cos(stick_rot), sin(stick_rot)).normalized()
		if prev_rot == null:
			prev_rot = stick_rot
		if ((stick_rot < target_rot) and (target_rot < prev_rot)) or ((stick_rot > target_rot) and (target_rot > prev_rot)):
			if bounce_enabled and stick_dir.dot(-target_dir) > 0.95:
				bounce_enabled = false
				$AnimationPlayer.play("VertBob")
				$BounceCooldownTimer.start(randf_range(4, 8))
				GameManager.player.freeze_timer.start(0.3)
				GameManager.player.freeze_tool_rot = true
		prev_rot = stick_rot
	rand_timer.set_paused(GameManager.player.still)
	hint_potency = target_range()
	get_target()

func target_range():
	if current_target == null:
		return 1
	# return a float between -1 to 1 representing proximity to the correct angle
	var stick_deg = self.global_rotation
	var stick_dir = Vector2(cos(stick_deg), sin(stick_deg)).normalized()
	return target_dir.cross(stick_dir)

func get_target():
	if current_target == null and all_targets.is_empty():
		return
		
	for i in range(all_targets.size() - 1, -1, -1):
		if !is_instance_valid(all_targets[i]):
			all_targets.remove_at(i)
		elif current_target == null and is_instance_valid(all_targets[i]):
			current_target = all_targets[i]
	
	for i in all_targets:
		var target_displacement = GameManager.player.global_position - current_target.global_position
		var i_displacement = GameManager.player.global_position - i.global_position
		if i_displacement.length() < target_displacement.length():
			current_target = i

func receive_dowsables(dowsable : DowsingComponent):
	if !dowsable in all_targets:
		all_targets.append(dowsable)

func _on_random_effect_attempt_timer_timeout():
	if current_target == null:
		return
	var random = randf() * 100
	if random <= 70:
		# Tilt attempt
		GameManager.player.cur_tool_speed += hint_potency * max_tilt
	elif random <= 90:
		# Move skew attempt
		GameManager.player.move_skew = -target_dir * max_move_skew
	elif random <= 98:
		# Red Herring tilt
		$AnimationPlayer.play("RedHerringTilt")
	elif random <= 99.8:
		# Expand Rod
		$AnimationPlayer.play("elongate")
	elif random <= 100:
		# lightning
		pass
	rand_timer.start(randf_range(min_timer, max_timer))

func _on_bounce_cooldown_timer_timeout():
	bounce_enabled = true
