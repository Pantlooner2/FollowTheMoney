class_name ItemCollectibleComponent
extends Node2D

@export var item : InventoryItem

var highlighting = false

@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	sprite.texture = item.texture

func highlight():
	if highlighting:
		sprite.material.set_shader_parameter("progress", 0.0)
	else:
		sprite.material.set_shader_parameter("progress", 1.0)
	highlighting = !highlighting

func collect():
	get_parent().queue_free()
