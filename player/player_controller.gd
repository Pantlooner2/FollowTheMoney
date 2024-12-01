class_name Player
extends CharacterBody2D

@export var player_inventory : Inventory
@export var hit : Attack

var walk_speed : float = 40.0
var upgrade_speed : float = 0.0
var added_speed : float = 0.0
var tool_distance : float = 6
var tool_base_speed : float = PI * 2
var tool_acceleration : float = PI
var tool_deccelerate_range : float = PI/6
var freeze_tool_rot = false
var current_target_item := GameManager.ITEM_NAME.SPEED_UPGRADE

var move_direction : Vector2
var move_skew : Vector2
var facing_direction : DIRECTION = DIRECTION.SOUTH
var player_state : PLAYER_STATE = PLAYER_STATE.IDLE

var cur_targeted_pickup : ItemCollectibleComponent
var cur_tool : Tool
var time_still : float
var still := false
var in_shop := false
var can_move := true
var current_money : int = 0
var selected_slot : int
var cur_tool_speed : float = 0
var cur_tool_acceleration : float = tool_acceleration

signal on_open_shop

@onready var bone_item_scene = preload("res://scenes/items/bone_item.tscn")
@onready var health_component = $HealthComponent
@onready var hitbox_component = $HitboxComponent
@onready var animationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var inv_ui : InventoryUI = $UI/InventoryUI
@onready var hotbar_ui : HotbarUI = $UI/HotbarUI
@onready var health_ui : HealthUI = $UI/HealthBarUI
@onready var item_detector = $ItemDetector
@onready var resource_detector = $ResourceDetector
@onready var hand = $ToolHolder
@onready var money_text = $UI/Money
@onready var freeze_timer = $ToolFreezeTimer
@onready var invincibility_timer = $InvincibilityTimer
@onready var disable_move_timer = $DisableMoveTimer
@onready var item_shuffle_player = $AudioPlayers/ItemShufflePlayer
@onready var item_sell_player = $AudioPlayers/ItemSellPlayer
@onready var item_buy_player = $AudioPlayers/ItemBuyPlayer
@onready var item_drop_player = $AudioPlayers/ItemDropPlayer
@onready var item_pickup_player = $AudioPlayers/ItemPickupPlayer
@onready var item_equip_player = $AudioPlayers/ItemEquipPlayer
@onready var item_use_player = $AudioPlayers/ItemUsePlayer
@onready var player_hit_player = $AudioPlayers/PlayerHitPlayer
@onready var player_footsteps_player = $AudioPlayers/PlayerFootstepsPlayer

func _init():
	GameManager.player = self

func _ready():
	health_ui.update()
	health_component.on_health_change.connect(health_ui.update)

func _physics_process(delta):
	if GameManager.paused:
		return
	
	point_hand(delta)
	move_direction = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_just_pressed("ui_inventory"):
		if inv_ui.is_open:
			inv_ui.close()
		elif !in_shop:
			inv_ui.open()
			if cur_tool != null:
				unequip()
	
	if Input.is_action_just_pressed("ui_add"):
		if cur_targeted_pickup != null:
			collect(cur_targeted_pickup)
			cur_targeted_pickup = null
		elif !inv_ui.is_open:
			on_open_shop.emit()
			if cur_tool != null and in_shop:
				unequip()
	
	if move_direction and can_move:
		player_footsteps_player.play()
		time_still = 0
		still = false
		player_state = PLAYER_STATE.WALK
		velocity = move_direction * (walk_speed + upgrade_speed + added_speed) + move_skew
		determine_move_direction()
	elif can_move:
		time_still += delta
		if time_still >= 3:
			still = true
		player_state = PLAYER_STATE.IDLE
		velocity = lerp(velocity, Vector2.ZERO + move_skew, 0.3)
	added_speed = lerp(added_speed, 0.0, 0.005)
	move_skew = lerp(move_skew, Vector2.ZERO, 0.01)
	
	if Input.is_action_just_pressed("apply_tool"):
		if cur_tool != null:
			harvest_resources(cur_tool.tool_type)
		else:
			harvest_resources(GameManager.TOOL_TYPE.HAND)
	
	if invincibility_timer.time_left > 0:
		sprite.material.set_shader_parameter("flash_value", abs(sin(8 * invincibility_timer.time_left)))
	
	if !in_shop and !inv_ui.is_open:
		select_slot(0)
		select_slot(1)
		select_slot(2)
		select_slot(3)
	
	animate_walk()
	move_and_slide()
	check_ground_items()

func select_slot(num : int):
	if Input.is_action_just_pressed("slot" + str(num + 1)):
		if hotbar_ui.inventory.slots[num].item == null:
			return
		if hotbar_ui.cur_selected_slot == hotbar_ui.slots[num]:
			unequip()
		else:
			var this_item = hotbar_ui.inventory.slots[num].item
			if this_item.is_tool:
				if cur_tool != null:
					unequip()
				select_tool(hotbar_ui.inventory.slots[num].item)
				hotbar_ui.cur_selected_slot = hotbar_ui.slots[num]
				hotbar_ui.update_slots()
			elif this_item.item_type == GameManager.ITEM_NAME.LEAF:
				added_speed = 20
				hotbar_ui.inventory.slots[num].amount -= 1
				if hotbar_ui.inventory.slots[num].amount == 0:
					hotbar_ui.inventory.slots[num].item = null
				hotbar_ui.inventory.update.emit()
			elif this_item.item_type == GameManager.ITEM_NAME.COBWEB:
				health_component.set_health(health_component.cur_health + 2)
				hotbar_ui.inventory.slots[num].amount -= 1
				if hotbar_ui.inventory.slots[num].amount == 0:
					hotbar_ui.inventory.slots[num].item = null
				hotbar_ui.inventory.update.emit()
			elif this_item.item_type == GameManager.ITEM_NAME.SPEED_UPGRADE:
				upgrade_speed += 10
				hotbar_ui.inventory.slots[num].amount -= 1
				if hotbar_ui.inventory.slots[num].amount == 0:
					hotbar_ui.inventory.slots[num].item = null
				hotbar_ui.inventory.update.emit()

func determine_move_direction():
	if move_direction.x > 0:
		facing_direction = DIRECTION.EAST
	elif move_direction.x < 0:
		facing_direction = DIRECTION.WEST
	elif move_direction.y < 0:
		facing_direction = DIRECTION.NORTH
	elif move_direction.y > 0:
		facing_direction = DIRECTION.SOUTH

func animate_walk():
	if facing_direction == DIRECTION.NORTH:
		if player_state == PLAYER_STATE.IDLE:
			animationPlayer.play("idle_up")
		elif player_state == PLAYER_STATE.WALK:
			animationPlayer.play("walk_up")
	elif facing_direction == DIRECTION.EAST:
		if player_state == PLAYER_STATE.IDLE:
			animationPlayer.play("idle_right")
		elif player_state == PLAYER_STATE.WALK:
			animationPlayer.play("walk_right")
	elif facing_direction == DIRECTION.SOUTH:
		if player_state == PLAYER_STATE.IDLE:
			animationPlayer.play("idle_down")
		elif player_state == PLAYER_STATE.WALK:
			animationPlayer.play("walk_down")
	elif facing_direction == DIRECTION.WEST:
		if player_state == PLAYER_STATE.IDLE:
			animationPlayer.play("idle_left")
		elif player_state == PLAYER_STATE.WALK:
			animationPlayer.play("walk_left")

func point_hand(delta : float):
	if freeze_tool_rot:
		return
	var mouse_dir = (get_global_mouse_position() - position).normalized()
	var accel_dir = hand.position.normalized().cross(mouse_dir)
	var final_angle = hand.global_rotation + cur_tool_speed * delta + 0.5 * cur_tool_acceleration * delta ** 2
	var final_position = Vector2(cos(final_angle), sin(final_angle)).normalized() * tool_distance
	cur_tool_acceleration = tool_acceleration * accel_dir
	if (abs(accel_dir) < tool_deccelerate_range):
		cur_tool_speed = lerp(cur_tool_speed, 0.0, 0.2)
	if (abs(cur_tool_speed) <= tool_base_speed):
		cur_tool_speed += cur_tool_acceleration
		if (abs(cur_tool_speed) > tool_base_speed):
			cur_tool_speed = tool_base_speed * sign(cur_tool_acceleration)
	hand.position = tool_distance * final_position.normalized()
	hand.look_at(hand.global_position + final_position.normalized())

func collect(item_component : ItemCollectibleComponent):
	if !player_inventory.is_full() or player_inventory.has_item(item_component.item.item_type):
		player_inventory.insert(item_component.item)
		item_component.collect()

func check_ground_items():
	if item_detector.has_overlapping_areas():
		var item : ItemCollectibleComponent
		if cur_targeted_pickup != null:
			item = cur_targeted_pickup
		for i in item_detector.get_overlapping_areas():
			if item != null:
				var newItemPos = global_position - i.global_position
				var itemPos = global_position - item.global_position
				if newItemPos.length() < itemPos.length():
					if item.highlighting:
						item.highlight()
					item = i.get_parent()
					if !item.highlighting:
						item.highlight()
			else:
				item = i.get_parent()
				if !item.highlighting:
					item.highlight()
		cur_targeted_pickup = item
	elif cur_targeted_pickup != null:
		if cur_targeted_pickup.highlighting:
			cur_targeted_pickup.highlight()
		cur_targeted_pickup = null

func harvest_resources(tool : GameManager.TOOL_TYPE):
	if !resource_detector.has_overlapping_areas():
		return
	
	for i in resource_detector.get_overlapping_areas():
		var resource = i.get_parent()
		if resource is ResourceCreatorComponent:
			resource.harvest(tool)

func select_tool(tool : InventoryItem):
	if !tool.is_tool:
		return
	tool.load_scene()
	cur_tool = tool.scene.instantiate()
	hand.add_child(cur_tool)
	if cur_tool is DowsingRod:
		cur_tool.target_item = current_target_item
		GameManager.player_dowsing.emit()

func unequip():
	hotbar_ui.cur_selected_slot = null
	hotbar_ui.update_slots()
	cur_tool.unequip()
	cur_tool = null

func toggle_hotbar():
	hotbar_ui.visible = !hotbar_ui.visible
	hotbar_ui.update_slots()

func on_hit(attack : Attack):
	player_hit_player.play()
	velocity = attack.direction * attack.damage * 100
	can_move = false
	hitbox_component.disable()
	health_component.take_damage(attack)
	invincibility_timer.start(1)
	disable_move_timer.start(0.5)
	if randi_range(1,3) <= attack.damage:
		var radian = randf_range(0, 2 * PI)
		var randVect = Vector2(50*cos(radian), 50*sin(radian))
		var instance = bone_item_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		GameManager.current_room.add_child(instance)
		instance.global_position = randVect + global_position

func die():
	GameManager.pause_game()
	var dir : String
	if facing_direction == DIRECTION.NORTH:
		dir = "up"
	elif facing_direction == DIRECTION.EAST:
		dir = "right"
	elif facing_direction == DIRECTION.SOUTH:
		dir = "down"
	elif facing_direction == DIRECTION.WEST:
		dir = "left"
	animationPlayer.play("death_"+dir)
	GameManager.display_respawn_menu()

func update_money():
	money_text.text = str(current_money)

func drop_item(item : InventoryItem):
	item.load_scene()
	if item.scene == null:
		return
	item_drop_player.play()
	var instance = item.scene.instantiate()
	instance.global_position = global_position
	GameManager.current_room.add_child(instance)

enum DIRECTION {
	NORTH,
	EAST,
	SOUTH,
	WEST,
}

enum PLAYER_STATE {
	IDLE,
	WALK,
}

func _on_tool_freeze_timer_timeout():
	freeze_tool_rot = false


func _on_invincibility_timer_timeout():
	hitbox_component.enable()
	sprite.material.set_shader_parameter("flash_value", 0.0)

func _on_disable_move_timer_timeout():
	can_move = true
