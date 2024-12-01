class_name WolfStats
extends Resource

@export var wolf_type : WOLF_TYPE
@export var speed : float
@export var walk_speed : float
@export var wander_distance : float
@export var aggro_radius : float
@export var aggro_time : float
@export var attack : Attack

enum WOLF_TYPE {
	GREY,
	BLACK,
	BROWN,
}
