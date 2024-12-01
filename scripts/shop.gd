extends Node2D

var shop_open = false

@onready var animation_timer = $AnimTimer
@onready var shopkeeper_sprite = $AnimatedSprite2D
@onready var shop_inv_ui = $CanvasLayer/ShopInventoryUI
@onready var player_inv_ui = $CanvasLayer/PlayerInventoryUI

func _on_anim_timer_timeout():
	var rand_num = randi_range(0,4)
	if rand_num == 1:
		shopkeeper_sprite.play("default")
	elif rand_num == 2:
		shopkeeper_sprite.play("idle1")
	elif rand_num == 3:
		shopkeeper_sprite.play("idle2")
	elif rand_num == 4:
		shopkeeper_sprite.play("idle3")
	
	animation_timer.start(randf_range(1,2))

func open_shop():
	if shop_open:
		close_shop()
		return
	GameManager.player.toggle_hotbar()
	shop_open = true
	shop_inv_ui.visible = true
	player_inv_ui.visible = true
	GameManager.display_price = true
	GameManager.player.in_shop = true
	shop_inv_ui.update_slots()
	player_inv_ui.update_slots()

func close_shop():
	shop_open = false
	shop_inv_ui.visible = false
	player_inv_ui.visible = false
	GameManager.display_price = false
	GameManager.player.toggle_hotbar()
	GameManager.player.in_shop = false

func _on_interaction_zone_body_entered(body):
	body.on_open_shop.connect(open_shop)

func _on_interaction_zone_body_exited(body):
	body.on_open_shop.disconnect(open_shop)
	if shop_open:
		close_shop()
