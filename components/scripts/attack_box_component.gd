extends Area2D

@export var attack : Attack

func assign_attack_dir(pos : Vector2):
	attack.direction = (pos - global_position).normalized()

func disable():
	self.set_monitoring(false)

func enable():
	self.set_monitoring(true)

func _on_area_entered(area):
	for group in get_groups():
		if str(group).begins_with("_"):
			continue
		elif area.is_in_group(group):
			return
	if area is HitboxComponent:
		assign_attack_dir(area.global_position)
		area.take_damage(attack)
