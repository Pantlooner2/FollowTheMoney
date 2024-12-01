class_name InventoryUI
extends Control

@export var hotbar_UI : HotbarUI
@export var inv_path : String

var is_open = false
var inventory : Inventory

@onready var slots : Array[InventoryUISlot]

func _ready():
	inventory = load(inv_path)
	for i in $NinePatchRect/GridContainer.get_children():
		if i is InventoryUISlot:
			slots.append(i)
			i.inv_ui = self
	inventory.update.connect(update_slots)
	update_slots()
	close()

func update_slots():
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])

func close():
	self.visible = false
	is_open = false

func open():
	update_slots()
	self.visible = true
	is_open = true
