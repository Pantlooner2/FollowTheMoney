class_name HotbarUI
extends Control

@export var base_slot_text : Texture2D
@export var select_slot_text : Texture2D

var is_open = false
var cur_selected_slot : Panel

@onready var inventory : Inventory = preload("res://inventory/player_inventory.tres")
@onready var slots : Array = $TextureRect/GridContainer.get_children()

func _ready():
	inventory.update.connect(update_slots)
	update_slots()
	open()

func update_slots():
	for i in range(slots.size()):
		slots[i].update(inventory.slots[i])
		if slots[i] == cur_selected_slot:
			slots[i].slot_sprite.texture = select_slot_text
		else:
			slots[i].slot_sprite.texture = base_slot_text

func close():
	self.visible = false
	is_open = false

func open():
	self.visible = true
	is_open = true
