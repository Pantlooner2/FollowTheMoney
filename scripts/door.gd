class_name Door
extends Area2D

@export var connected_room : int
@export var dowse_items : Array[GameManager.ITEM_NAME]

@onready var dowse_component = $DowsingComponent
@onready var transfer_timer = $TransferTimer

func _ready():
	dowse_component.target_items = dowse_items

func _on_transfer_timer_timeout():
	GameManager.switch_rooms(connected_room)


func _on_body_entered(body):
	if body is Player:
		GameManager.pause_game()
		GameManager.fade()
		transfer_timer.start(0.5)


func _on_enable_timer_timeout():
	monitoring = true
