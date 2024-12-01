extends Area2D

func _on_body_entered(body):
	if GameManager.player.player_inventory.has_item(GameManager.ITEM_NAME.KEY):
		get_parent().queue_free()
