class_name InventoryItem
extends Resource

@export var item_type : GameManager.ITEM_NAME
@export var scene_path : String
@export var is_tool : bool = false
@export var texture : Texture2D
@export var base_price : int

var scene : PackedScene

func load_scene():
	scene = load(scene_path)
