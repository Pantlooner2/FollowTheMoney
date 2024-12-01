class_name HealthUI
extends Control

@export var health : HealthComponent
@export var heart_sprite : Texture
@export var half_heart_sprite : Texture

var health_containers : Array[HealthContainer]

@onready var grid_container = $GridContainer

func _ready():
	for i in grid_container.get_children():
		if i is HealthContainer:
			health_containers.append(i)

func update():
	for i in range(1, 6):
		var heart_index = 5 - i
		if health.cur_health >= i * 2:
			health_containers[heart_index].sprite.visible = true
			health_containers[heart_index].sprite.texture = heart_sprite
		elif health.cur_health == i * 2 - 1:
			health_containers[heart_index].sprite.visible = true
			health_containers[heart_index].sprite.texture = half_heart_sprite
		else:
			health_containers[heart_index].sprite.visible = false
