extends Enemy

@export var wolf_stats_path : String
var wolf_stats : WolfStats

var state := STATE.IDLE
var target_position : Vector2

var current_target : HitboxComponent = null
var can_see_target : bool = false
var dir_string : String = "down"

@onready var char_body = $CharacterBody2D
@onready var nav_agent = $CharacterBody2D/NavigationAgent2D
@onready var raycast = $CharacterBody2D/RayCast2D
@onready var aggro_circle = $CharacterBody2D/Area2D
@onready var attack_box = $CharacterBody2D/AttackBoxComponent
@onready var aggro_timer = $CharacterBody2D/AggroTimer
@onready var wander_timer = $CharacterBody2D/WanderTimer
@onready var anim_player = $CharacterBody2D/AnimationPlayer

func _ready():
	target_position = global_position
	wolf_stats = load(wolf_stats_path)
	aggro_circle.get_child(0).get_shape().set_radius(wolf_stats.aggro_radius)
	attack_box.enable()
	attack_box.attack = wolf_stats.attack

func _physics_process(_delta : float) -> void:
	var dir = char_body.to_local(nav_agent.get_next_path_position()).normalized()
	var move_speed
	if state == STATE.CHASE:
		move_speed = wolf_stats.speed
	else:
		move_speed = wolf_stats.walk_speed
	if !nav_agent.is_target_reached():
		char_body.velocity = dir * move_speed
		char_body.move_and_slide()
	else:
		char_body.velocity = lerp(char_body.velocity, Vector2.ZERO, 0.3)
	animate()

func make_path():
	if state == STATE.HOME:
		target_position = position
		if nav_agent.is_target_reached():
			state = STATE.IDLE
	elif state == STATE.WANDER:
		if current_target != null:
			state = STATE.CHASE
			return
		elif randi_range(1, 3) == 1:
			var rand_angle = randf_range(0,2*PI)
			target_position = char_body.global_position + wolf_stats.wander_distance * Vector2(cos(rand_angle), sin(rand_angle))
		if wander_timer.is_stopped():
			wander_timer.start(wolf_stats.aggro_time)
	elif state == STATE.CHASE:
		if current_target != null:
			aggro_timer.start(wolf_stats.aggro_time)
			raycast.target_position = raycast.to_local(current_target.global_position)
			raycast.force_raycast_update()
			if raycast.is_colliding():
				var col = raycast.get_collider()
				var hit_obj = col.get_parent()
				for i in hit_obj.get_children():
					if i is ItemCollectibleComponent:
						hit_obj = i
				if hit_obj is ItemCollectibleComponent:
					if hit_obj.item.item_type == GameManager.ITEM_NAME.BONE or hit_obj.item.item_type == GameManager.ITEM_NAME.FOSSIL:
						if col is HitboxComponent:
							current_target = col
							target_position = current_target.global_position
				elif hit_obj is Player:
					current_target = col
					target_position = current_target.global_position
				can_see_target = (col == current_target)
			if nav_agent.is_target_reached() and !can_see_target:
				current_target = null
				state = STATE.WANDER
		else:
			state = STATE.WANDER
			can_see_target = false
	elif state == STATE.IDLE:
		if current_target != null:
			state = STATE.CHASE
	nav_agent.target_position = target_position

func check_aggro():
	if !aggro_circle.has_overlapping_areas():
		return
	
	var possible_targets = aggro_circle.get_overlapping_areas()
	for i in possible_targets:
		var parent = i.get_parent()
		if parent.get_child(0) is ItemCollectibleComponent:
			if parent.get_child(0).item.item_type == GameManager.ITEM_NAME.BONE:
				current_target = i
		elif parent is Player:
			current_target = i

func _on_timer_timeout():
	check_aggro()
	make_path()
	hit()

func hit():
	attack_box.disable()
	attack_box.enable()

func _on_aggro_timer_timeout():
	if state != STATE.CHASE:
		return
	current_target = null
	state = STATE.WANDER

func animate():
	var angle = char_body.velocity.rotated(PI/16).angle() + PI
	if char_body.velocity.length() <= wolf_stats.walk_speed / 2 or nav_agent.is_target_reached():
		anim_player.play("idle_" + dir_string)
		return
	if angle <= PI/8:
		dir_string = "left"
	elif angle <= 3*PI/8:
		dir_string = "up_left"
	elif angle <= 5*PI/8:
		dir_string = "up"
	elif angle <= 7*PI/8:
		dir_string = "up_right"
	elif angle <= 9*PI/8:
		dir_string = "right"
	elif angle <= 11*PI/8:
		dir_string = "down_right"
	elif angle <= 13*PI/8:
		dir_string = "down"
	elif angle <= 15*PI/8:
		dir_string = "down_left"
	if state == STATE.CHASE:
		anim_player.play("chase_" + dir_string)
	elif state == STATE.WANDER or state == STATE.HOME:
		anim_player.play("walk_" + dir_string)
	else:
		anim_player.play("idle_" + dir_string)

func _on_wander_timer_timeout():
	if state != STATE.WANDER:
		return
	state = STATE.HOME
	target_position = global_position

enum STATE {
	IDLE,
	WANDER,
	CHASE,
	HOME,
}
