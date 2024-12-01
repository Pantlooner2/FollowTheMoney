class_name HealthComponent
extends Node2D

@export var MAX_HEALTH : int
var cur_health : int

signal on_health_change

# Called when the node enters the scene tree for the first time.
func _ready():
	cur_health = MAX_HEALTH

func set_health(health : int):
	cur_health = min(health, MAX_HEALTH)
	on_health_change.emit()

func take_damage(attack : Attack):
	cur_health -= attack.damage
	if cur_health <= 0:
		if get_parent().has_method("die"):
			get_parent().die()
		else:
			get_parent().queue_free()
	on_health_change.emit()
