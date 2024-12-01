class_name DowsingComponent
extends Node2D

@export var target_items : Array[GameManager.ITEM_NAME]

signal dowsable

func _ready():
	if get_parent() is ItemCollectibleComponent:
		target_items.append(get_parent().item.item_type)
	if get_parent() is ResourceCreatorComponent:
		if get_parent().item_name != null:
			target_items.append(get_parent().item_name)
	GameManager.player_dowsing.connect(send_dowse_info.bind(GameManager.player))

func send_dowse_info(player : Player):
	var dowser = player.cur_tool
	if dowser.target_item in target_items:
		dowsable.connect(dowser.receive_dowsables.bind(self))
		dowsable.emit()
		dowsable.disconnect(dowser.receive_dowsables)
