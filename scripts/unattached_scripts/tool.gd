class_name Tool
extends Node

@export var tool_type := GameManager.TOOL_TYPE.HAND

func unequip():
	queue_free()
