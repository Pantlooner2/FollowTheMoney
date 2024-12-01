class_name HitboxComponent
extends Area2D

@export var healthComponent : HealthComponent

func disable():
	set_deferred("monitorable", false)

func enable():
	set_deferred("monitorable", true)

func take_damage(attack : Attack):
	if get_parent().has_method("on_hit"):
		get_parent().on_hit(attack)
		return
	
	healthComponent.take_damage(attack)
