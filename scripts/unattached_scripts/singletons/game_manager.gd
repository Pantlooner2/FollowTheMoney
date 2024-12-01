extends Node2D

var player : Player
var camera : Camera2D
var display_price = false
var paused = true
var main_menu = true

var all_rooms : Array[PackedScene]
var current_room : Node2D
var current_room_index : int

signal player_dowsing

var main_scene
var menu_canvas
var start_menu
var start_button
var death_menu
var respawn_button
var win_menu

func _ready():
	for i in range(15):
		var room_path = "res://scenes/Rooms/room_" + str(i) + ".tscn"
		all_rooms.append(load(room_path))
	main_scene = player.get_parent()
	camera = main_scene.get_child(0)
	menu_canvas = camera.get_child(0)
	start_menu = menu_canvas.get_child(0)
	start_button = start_menu.get_child(2)
	death_menu = menu_canvas.get_child(1)
	respawn_button = death_menu.get_child(1)
	win_menu = menu_canvas.get_child(2)
	start_button.button_down.connect(start_game)
	respawn_button.button_down.connect(respawn)
	get_tree().paused

func switch_rooms(dest_room_index : int):
	var origin_room_index = current_room_index
	var new_room_instance = all_rooms[dest_room_index].instantiate()
	new_room_instance.position = Vector2.ZERO
	current_room.queue_free()
	current_room = new_room_instance
	current_room_index = dest_room_index
	main_scene.add_child(current_room)
	player.global_position = Vector2.ZERO
	for i in current_room.get_children():
		if i.name == "Doors":
			for j in i.get_children():
				if j is Door:
					if j.connected_room == origin_room_index:
						player.global_position = j.global_position
						break
	unpause_game()
	if player.cur_tool != null:
		if player.cur_tool is DowsingRod:
			player_dowsing.emit()

func pause_game():
	paused = true
	get_tree().paused = true

func unpause_game():
	paused = false
	get_tree().paused = false

func fade():
	camera.get_child(2).play("fade_in_out")

func start_game():
	if camera.get_parent() == main_scene:
		main_scene.remove_child(camera)
		player.add_child(camera)
	menu_canvas.visible = false
	start_menu.visible = false
	death_menu.visible = false
	if current_room != null:
		current_room.queue_free()
	current_room = all_rooms[4].instantiate()
	main_scene.add_child(current_room)
	current_room.global_position = Vector2.ZERO
	player.global_position = Vector2.ZERO
	current_room_index = 4
	unpause_game()

func display_respawn_menu():
	menu_canvas.visible = true
	death_menu.visible = true

func respawn():
	player.current_money -= round(player.current_money / 2)
	player.update_money()
	player.health_component.set_health(player.health_component.MAX_HEALTH)
	start_game()

func disp_win():
	pause_game()
	menu_canvas.visible = true
	win_menu.visible = true

enum TOOL_TYPE {
	PICKAXE,
	SHOVEL,
	HAND,
}

enum ITEM_NAME {
	BONE,
	BISMUTH,
	CABLE,
	CLAY,
	COBWEB,
	DIRT,
	DOWSING_ROD,
	GOLD,
	IRON,
	LEAF,
	PICK,
	PIPE,
	SHOVEL,
	STONE,
	WATCH,
	FOSSIL,
	SPEED_UPGRADE,
	KEY,
}
