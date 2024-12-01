class_name Inventory
extends Resource

@export var slots : Array[InventorySlot]

signal update

func insert(item : InventoryItem):
	var item_slots = slots.filter(func(slot) : return slot.item == item)
	if !item_slots.is_empty():
		item_slots[0].amount += 1
	else:
		var empty_slots = slots.filter(func(slot) : return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].amount = 1
	update.emit()

func swap(slot1 : int, slot2 : int):
	var temp_item = slots[slot1].item
	var temp_amount = slots[slot1].amount
	slots[slot1].item = slots[slot2].item
	slots[slot1].amount = slots[slot2].amount
	slots[slot2].item = temp_item
	slots[slot2].amount = temp_amount
	update.emit()

func sell(slot_index : int):
	if slots[slot_index].item == null:
		return
	GameManager.player.current_money += slots[slot_index].item.base_price * slots[slot_index].amount
	slots[slot_index].item = null
	GameManager.player.update_money()
	update.emit()

func buy(purchased_item):
	if purchased_item == null:
		return
	GameManager.player.current_money -= purchased_item.base_price
	GameManager.player.update_money()
	insert(purchased_item)
	update.emit()

func drop(index : int):
	if slots[index].item == null:
		return
	GameManager.player.drop_item(slots[index].item)
	slots[index].amount -= 1
	if slots[index].amount == 0:
		slots[index].item = null
		
	update.emit()

func has_item(item_name : GameManager.ITEM_NAME):
	for i in slots:
		if i.item.item_type == item_name:
			return true
	return false

func is_full():
	for i in slots:
		if i.item == null:
			return false
	return true
