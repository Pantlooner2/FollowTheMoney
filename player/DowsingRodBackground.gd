extends TextureRect

func _can_drop_data(at_position, data):
	if data["item"] == null:
		return false
	else:
		return true

func _drop_data(at_position, data):
	var item = data["item"]
	if item is InventoryItem:
		GameManager.player.current_target_item = item.item_type
