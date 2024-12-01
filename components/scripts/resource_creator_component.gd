class_name ResourceCreatorComponent
extends Node2D

@export var spawned_item : PackedScene
@export var item_name : GameManager.ITEM_NAME
@export var tool_type := GameManager.TOOL_TYPE.HAND
@export var max_num_spawn : int = 1
@export var min_num_spawn : int = 1
@export var spawn_range := 15

var dirt_scene_path = "res://scenes/items/dirt_item.tscn"
var stone_scene_path = "res://scenes/items/stone_item.tscn"

func harvest(tool : GameManager.TOOL_TYPE):
	if tool == tool_type:
		var num_spawned = randi_range(min_num_spawn, max_num_spawn)
		for i in range(num_spawned):
			var length = randf_range(0, spawn_range)
			var radian = randf_range(0, 2 * PI)
			var randVect = Vector2(length*cos(radian), length*sin(radian))
			var instance = spawned_item.instantiate()
			GameManager.current_room.add_child(instance)
			instance.global_position = randVect + global_position
		if tool == GameManager.TOOL_TYPE.PICKAXE:
			for i in range(2):
				if randi_range(0,1) == 1:
					var length = randf_range(0, spawn_range)
					var radian = randf_range(0, 2 * PI)
					var randVect = Vector2(length*cos(radian), length*sin(radian))
					var instance = load(stone_scene_path).instantiate()
					GameManager.current_room.add_child(instance)
					instance.global_position = randVect + global_position
		if tool == GameManager.TOOL_TYPE.SHOVEL:
			for i in range(2):
				if randi_range(0,1) == 1:
					var length = randf_range(0, spawn_range)
					var radian = randf_range(0, 2 * PI)
					var randVect = Vector2(length*cos(radian), length*sin(radian))
					var instance = load(dirt_scene_path).instantiate()
					GameManager.current_room.add_child(instance)
					instance.global_position = randVect + global_position
	else:
		return
	
	if get_parent().has_method("die"):
		get_parent().die()
		queue_free()
	else:
		get_parent().queue_free()
