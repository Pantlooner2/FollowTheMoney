class_name InventoryUISlot
extends Panel

@export var sell_slot := false

@onready var item_visual : Sprite2D = $CenterContainer/Panel/ItemDisplay
@onready var slot_sprite : Sprite2D =  $Sprite2D
@onready var amount_text : Label = $CenterContainer/Panel/Label
@onready var price_text : Label = $CenterContainer/Panel/Label2

var inv_ui : InventoryUI

func update(slot : InventorySlot):
	if slot.item == null:
		item_visual.visible = false
		amount_text.visible = false
		price_text.visible = false
	else:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
		if slot.amount > 1:
			amount_text.visible = true
			amount_text.text = str(slot.amount)
		else:
			amount_text.visible = false
			amount_text.text = "0"
		if slot.item.base_price >= 1 and GameManager.display_price:
			price_text.visible = true
			price_text.text = str(slot.item.base_price)
		else:
			price_text.visible = false
			price_text.text = "0"

func _can_drop_data(at_position, data):
	var my_data = get_my_data()
	if data["player_owned"]:
		if my_data["player_owned"]:
			return true
		else:
			if my_data["sell_slot"]:
				if data["item"] != null:
					return data["item"].base_price >= 1
			return false
	else:
		if my_data["player_owned"]:
			if data["item"] != null:
				return data["item"].base_price <= GameManager.player.current_money
		return false

func _drop_data(at_position, data):
	var my_data = get_my_data()
	if data["player_owned"]:
		if my_data["player_owned"]:
			# trying to reorganize - swap both slots' items and quantities
			inv_ui.inventory.swap(data["slot_index"], my_data["slot_index"])
		elif my_data["sell_slot"]:
			# trying to sell
			if data["item"] != null:
				data["inv"].sell(data["slot_index"])
	else:
		if my_data["player_owned"]:
			# trying to buy
			inv_ui.inventory.buy(data["item"])

func _get_drag_data(at_position):
	var drag_data = get_my_data()
	var tex = TextureRect.new()
	tex.texture = item_visual.texture
	set_drag_preview(tex)
	return drag_data

func get_my_data():
	var index = inv_ui.slots.find(self)
	var slot = inv_ui.inventory.slots[index]
	var drag_data = {
		"item" : slot.item,
		"item_quantity" : slot.amount,
		"player_owned": slot.player_owned,
		"slot_index" : index,
		"sell_slot" : sell_slot,
		"inv" : inv_ui.inventory,
	}
	return drag_data
